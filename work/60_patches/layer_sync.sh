#!/usr/bin/env bash
# layer_sync.sh — turn the pack the game just downloaded into a tagged, pristine baseline tree.
#
#   ./layer_sync.sh                 ingest the version in state.json (the one the game runs)
#   ./layer_sync.sh --ver 0.2.8    ingest a specific version instead
#   ./layer_sync.sh --pack F.pck   ingest one concrete pack file (must be plaintext GDPC)
#   ./layer_sync.sh --dry-run      print the plan, write nothing
#   ./layer_sync.sh --no-commit    build the tree but leave tagging to you
#   ./layer_sync.sh --force        re-do every step of a version that is already ingested
#
# What it does, and why each step is a step (verified in PATCH_SYSTEM.md §14/§19):
#   1 copy   user://patches/patch_<ver>.pck -> orig/            (the ONLY trustworthy base for a build)
#   2 extract its .gdc members -> raw_<ver>/
#   3 decompile each .gdc one by one -> scripts_full_<ver>/     (no .remap grafting needed)
#   4 assemble effective_<ver>/ = retail base <- bridge <- every older patch layer <- this patch layer
#   5 write work/logs/patch-<ver>-files.txt                      (what play.sh --layer reads)
#   6 whitelist the tree in .gitignore, commit it, tag it v<ver>-decompiled
#
# The tag is what makes `git diff v<ver>-decompiled -- work/60_patches/effective_<ver>` equal the mod,
# so it is committed BEFORE any of our edits — never amend it afterwards.
# Nothing here writes to the game directory or to user:// (read-only on both).
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/layer_env.sh"
layer_need

VER="" PACK="" JOBS=3 DRY=0 NOCOMMIT=0 FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --ver) VER="$2"; shift 2 ;;
    --pack) PACK="$2"; shift 2 ;;
    --jobs) JOBS="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --no-commit) NOCOMMIT=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1 (--help)" ;;
  esac
done

[ -n "$VER" ] || VER=$(layer_ver)
SRC_PACK="${PACK:-$PATCHES/patch_$VER.pck}"
PACK_NAME="patch_$VER.pck"
RAW="$W/raw_$VER"
FULL="$W/scripts_full_$VER"
TREE="$W/effective_$VER"
TREE_REL=$(layer_tagpath "$VER")
TAG="v$VER-decompiled"
PREV=$(layer_prev "$VER")
LOG="$W/decompile_$VER.log"

echo "layer_sync.sh: version $VER  (state.json says $(layer_ver))"
echo "  from     $SRC_PACK"
echo "  into     $TREE  ->  tag $TAG"
echo "  baseline prev: ${PREV:-none}"
[ -f "$SRC_PACK" ] || die "no such pack: $SRC_PACK
  The updater deletes the pack it replaces, so if this is not the live one, point --pack at a copy from
  work/60_patches/orig/ (or mount the game once and copy it out of user://patches/)."

MAGIC=$(layer_magic "$SRC_PACK")
case "$MAGIC" in
  "$GDPC_MAGIC") : ;;
  "$GDEC_MAGIC") die "$SRC_PACK is an ENCRYPTED download (magic GDEC), not a mountable pack.
  The updater decrypts packs with a key in updater.gd (_decrypt), so launch the game once (./play.sh), let
  it mount the layer, then copy user://patches/$PACK_NAME again - PATCH_SYSTEM.md §19.2." ;;
  *) die "unexpected magic '$MAGIC' in $SRC_PACK (want GDPC)" ;;
esac

if [ -n "$(git -C "$ROOT" tag -l "$TAG")" ] && [ "$FORCE" != 1 ]; then
  if [ "$DRY" = 1 ]; then
    echo "  baseline $TAG already exists -> nothing to ingest. Continue from step 2: ./update.sh --skip-sync"
    exit 0
  fi
  echo "  baseline $TAG already exists and orig/$PACK_NAME is $( [ -f "$ORIG/$PACK_NAME" ] && echo present || echo MISSING)"
  die "already ingested. --force redoes the whole thing (it will not move the existing tag)."
fi
if [ -d "$TREE" ] && [ "$FORCE" != 1 ]; then
  die "$TREE exists. --force replaces it with a fresh decompile (check 'git diff $TAG' first if it is modified)."
fi
if [ "$DRY" = 1 ]; then
  echo; echo "dry run: would run steps 1-6 above; nothing written."
  exit 0
fi

# --- 1. pristine copy -------------------------------------------------------------------------
layer_ck "1/6 pristine copy of the official layer"
BASE="$ORIG/$PACK_NAME"
if [ -f "$BASE" ]; then
  if [ "$FORCE" = 1 ] && ! cmp -s "$SRC_PACK" "$BASE"; then
    die "orig/$PACK_NAME differs from $SRC_PACK.
  orig/ must hold the developers' own bytes - if a build of ours ever landed there, restore the official
  pack (see PATCH_SYSTEM.md §14) before ingesting, otherwise a mod would be built on top of a mod."
  fi
  echo "  orig/$PACK_NAME already there ($(sha256 "$BASE" | cut -c1-16)...)"
else
  mkdir -p "$ORIG"
  cp -p "$SRC_PACK" "$BASE" || die "copy failed"
  echo "  copied -> orig/$PACK_NAME"
fi
[ -f "$BASE" ] || die "still no orig/$PACK_NAME - the build step refuses any other base"
case "$(layer_magic "$BASE")" in
  "$GDPC_MAGIC") echo "  magic GDPC (plaintext pack)  sha $(sha256 "$BASE" | cut -c1-16)...  $(stat -c %s "$BASE") B" ;;
  "$GDEC_MAGIC") die "orig/$PACK_NAME is an ENCRYPTED download (magic GDEC), not a mountable pack.
  The updater decrypts packs with a key in updater.gd (_decrypt), so launch the game once (./play.sh),
  let it mount the layer, then copy user://patches/$PACK_NAME again - PATCH_SYSTEM.md §19.2." ;;
  *) die "unexpected magic in $BASE: $(layer_magic "$BASE") (want GDPC)" ;;
esac
"$GDRE" --list-files="$BASE" 2>/dev/null | grep '^res://' | sort > "$LISTINGS/patch-$VER-files.txt"
N_ALL=$(grep -c '^res://' "$LISTINGS/patch-$VER-files.txt")
N_GDC=$(grep -c '\.gdc$' "$LISTINGS/patch-$VER-files.txt")
echo "  members $N_ALL (of which $N_GDC scripts) -> work/logs/patch-$VER-files.txt"
if [ -n "$PREV" ]; then
  PREV_LIST="$LISTINGS/patch-$PREV-files.txt"
  if [ -s "$PREV_LIST" ]; then
    # older listings were written by hand (headers, unsorted) -> normalise both sides
    t1=$(mktemp); t2=$(mktemp)
    grep '^res://' "$PREV_LIST" | sort -u > "$t1"
    grep '^res://' "$LISTINGS/patch-$VER-files.txt" | sort -u > "$t2"
    echo "  vs $PREV: +$(comm -13 "$t1" "$t2" | wc -l) member(s), -$(comm -23 "$t1" "$t2" | wc -l) member(s)"
    n=$(comm -23 "$t1" "$t2" | wc -l); rm -f "$t1" "$t2"
    [ "$n" = 0 ] || echo "  NOTE: members disappeared, so the layer is NOT a superset of $PREV - check §5 layering below."
  fi
fi

# --- 2. extract -------------------------------------------------------------------------------
layer_ck "2/6 extract .gdc -> raw_$VER"
rm -rf "$RAW"
"$GDRE" --extract="$BASE" --include='*.gdc' --output="$RAW" > "$W/extract_$VER.log" 2>&1 \
  || die "extract failed, see $(basename "$W")/extract_$VER.log"
N_RAW=$(find "$RAW" -name '*.gdc' | wc -l)
[ "$N_RAW" = "$N_GDC" ] || die "extracted $N_RAW of $N_GDC scripts"
echo "  $N_RAW .gdc"

# --- 3. decompile -----------------------------------------------------------------------------
layer_ck "3/6 decompile (bytecode $BYTECODE, -P$JOBS)"
REV=$(layer_rev "$(find "$RAW" -name '*.gdc' | head -1)")
case "$REV" in
  101) [ "$BYTECODE" = "4.5.0-stable" ] && : || echo "  NOTE: rev $REV while BYTECODE=$BYTECODE" ;;
  *) die "bytecode revision $REV is not the one we know (101 = 4.5.0-stable).
  Pick the token for it in '$GDRE --list-bytecode-versions' and rerun as BYTECODE=<token> $0 --force" ;;
esac
echo "  header GDSC rev $REV OK"
rm -rf "$FULL" "$LOG"; mkdir -p "$FULL"
export RAW FULL GDRE BYTECODE LOG
find "$RAW" -name '*.gdc' -print0 | xargs -0 -P "$JOBS" -n 1 bash -c '
  g="$1"; rel="${g#"$RAW/"}"; n="$(basename "$rel" .gdc)"; d="$FULL/${rel%/*}"
  [ "$d" = "$FULL" ] && d="$FULL"
  mkdir -p "$d"
  if ! "$GDRE" --decompile="$g" --bytecode="$BYTECODE" --output="$d" >>"$LOG" 2>&1 || [ ! -s "$d/$n.gd" ]; then
    echo "FAIL $g" >> "$LOG"
  fi
' _ || die "xargs failed (gdre_tools crashing?)"
N_FAIL=$(grep -c '^FAIL' "$LOG" 2>/dev/null); N_GD=$(find "$FULL" -name '*.gd' | wc -l)
echo "  $N_GD .gd, ${N_FAIL:-0} failure(s)  (log: $(basename "$LOG"))"
[ "${N_FAIL:-0}" = 0 ] && [ "$N_GD" = "$N_RAW" ] || { grep '^FAIL' "$LOG" | sed 's/^/    /'; die "decompile incomplete"; }

# --- 4. assemble the tree ---------------------------------------------------------------------
layer_ck "4/6 assemble effective_$VER (base <- bridge <- older patches <- this patch)"
[ -d "$BASE_LAYER" ] || die "missing the retail decompile $BASE_LAYER (see work/README.md)"
LAYERS=("$BASE_LAYER")
for d in $(ls -1d "$W"/scripts_full_* 2>/dev/null | sed 's/.*scripts_full_//' | sort -V); do
  [ "$d" = "$VER" ] && continue
  # only layers at or below our version: a newer decompile would pre-date nothing and would lie
  [ "$(printf '%s\n%s\n' "$d" "$VER" | sort -V | head -1)" = "$VER" ] && [ "$d" != "$VER" ] && continue
  LAYERS+=("$W/scripts_full_$d")
done
LAYERS+=("$FULL")
rm -rf "$TREE"; mkdir -p "$TREE"
PROJ=""
for t in $(ls -1d "$W"/effective_* 2>/dev/null | sort -V); do PROJ="$t/project.godot"; done
[ -n "$PROJ" ] && [ -f "$PROJ" ] || PROJ="$BASE_LAYER/project.godot"
cp "$PROJ" "$TREE/" || die "no project.godot to copy (looked at $PROJ)"
for L in "${LAYERS[@]}"; do
  for sub in scripts addons; do
    [ -d "$L/$sub" ] || continue
    mkdir -p "$TREE/$sub"
    cp -r "$L/$sub/." "$TREE/$sub"/ || die "copy failed from $L/$sub"
  done
  echo "  + $(basename "$L")"
done
# a tree is source, not build output: drop the .gdc/.uid copies that layers and GDRE leave behind
N_JUNK=$(find "$TREE" \( -name '*.gdc' -o -name '*.uid' -o -name '*.remap' \) | wc -l)
find "$TREE" \( -name '*.gdc' -o -name '*.uid' -o -name '*.remap' \) -delete
N_TREE=$(find "$TREE" -name '*.gd' | wc -l)
echo "  $N_TREE .gd in effective_$VER (cleaned $N_JUNK binary/sidecar file(s))"

# --- 5/6. whitelist + baseline commit ---------------------------------------------------------
layer_ck "5/6 .gitignore"
RULE="!/work/60_patches/effective_$VER/"
if grep -qxF "$RULE" "$ROOT/.gitignore"; then
  echo "  already whitelisted"
else
  ln=$(grep -n '^!/work/60_patches/effective_' "$ROOT/.gitignore" | tail -1 | cut -d: -f1)
  [ -n "$ln" ] || ln=$(grep -n '^!/work/60_patches/mod-latest.patch$' "$ROOT/.gitignore" | tail -1 | cut -d: -f1)
  [ -n "$ln" ] || die "cannot find an insertion point in .gitignore"
  awk -v n="$ln" -v rule="$RULE" 'NR==n{print; print rule; next} {print}' "$ROOT/.gitignore" > "$ROOT/.gitignore.new" \
    && mv "$ROOT/.gitignore.new" "$ROOT/.gitignore"
  echo "  added $RULE at line $((ln + 1))"
fi

layer_ck "6/6 baseline commit + tag"
if [ "$NOCOMMIT" = 1 ]; then
  echo "  --no-commit: tree ready at $(basename "$TREE"), tag $TAG not created"
  exit 0
fi
git -C "$ROOT" add .gitignore "$TREE_REL" || die "git add failed"
if git -C "$ROOT" diff --cached --quiet; then
  echo "  nothing new: the fresh decompile is byte-identical to $TAG (no commit, tag untouched)"
  exit 0
fi
if git -C "$ROOT" diff --cached --name-only | grep -Ev '\.(gd|cfg|godot)$' | grep -q .; then
  git -C "$ROOT" diff --cached --name-only | grep -Ev '\.(gd|cfg|godot)$' | sed 's/^/    /'
  git -C "$ROOT" reset -q
  die "the tree contains non-text files (above) - this repo stays text-only, inspect before committing"
fi
NEW_LIST=""
if [ -n "$PREV" ]; then
  git -C "$ROOT" ls-tree -r --name-only "v$PREV-decompiled" -- "work/60_patches/effective_$PREV" \
    | sed "s#work/60_patches/effective_$PREV/##" | sort > /tmp/prev_tree.txt
  ( cd "$TREE" && find . -name '*.gd' | sed 's#^\./##' | sort ) > /tmp/new_tree.txt
  NEW_LIST=$(comm -13 /tmp/prev_tree.txt /tmp/new_tree.txt)
fi
{ echo "Decompile official patch layer $VER -> effective_$VER (pristine baseline)"
  echo
  echo "patch_$VER.pck sha $(sha256 "$BASE"), $(stat -c %s "$BASE") B, $N_ALL members, $N_GDC scripts,"
  echo "bytecode rev $REV = GDRE token $BYTECODE. $N_GD/$N_RAW decompiled, 0 failures."
  echo "Tree = $(for L in "${LAYERS[@]}"; do basename "$L"; done | tr '\n' ' ')= $N_TREE .gd."
  [ -n "$NEW_LIST" ] && echo "New scripts vs v$PREV-decompiled: $(echo "$NEW_LIST" | tr '\n' ' ')"
} > /tmp/layer_sync_msg.txt
git -C "$ROOT" commit -q -F /tmp/layer_sync_msg.txt || die "commit failed"
git -C "$ROOT" tag "$TAG" || die "tag $TAG failed"
echo "  committed + tagged $TAG  ($(git -C "$ROOT" rev-parse --short HEAD))"
[ -n "$NEW_LIST" ] && echo "  new vs $PREV: $(echo "$NEW_LIST" | tr '\n' ' ')"
echo
echo "next:  ./layer_diff.sh          (what the dev changed where our mod lives)"
echo "       ./mod_apply.sh --build   (re-apply the mod onto $TREE, then build)"
