#!/usr/bin/env bash
# layer_sync.sh — turn the packs the game just downloaded into a tagged, pristine baseline tree.
#
#   ./layer_sync.sh                 ingest the version in state.json (the one the game runs)
#   ./layer_sync.sh --ver 0.2.8    ingest a specific version instead
#   ./layer_sync.sh --pack F.pck   ingest one concrete pack file (must be plaintext GDPC)
#   ./layer_sync.sh --dry-run      print the plan, write nothing
#   ./layer_sync.sh --no-commit    build the tree but leave tagging to you
#   ./layer_sync.sh --force        re-do every step of a version that is already ingested
#
# What it does, and why each step is a step (verified in PATCH_SYSTEM.md §14/§19/§21):
#   1 resolve the LAYER MANIFEST: state.json says which packs the game mounts (bridge + patch). Since
#     0.2.11 the scripts live in the BRIDGE and the patch pack can be a 1-member hotfix, so "the patch
#     pack" is no longer a synonym for "the layer". Every pack in the manifest is ingested.
#   2 copy each to orig/            (up to KEEP_MAX bytes; a 228 MB bridge is not, see §21)
#   3 list members -> work/logs/<kind>-<ver>-files.txt ; hashes -> work/logs/layer-hashes-<ver>.txt
#   4 extract .gdc -> raw[_bridge]_<ver>/ ; 5 decompile -> scripts[_bridge]_<ver>/
#   6 assemble effective_<ver>/ = retail base <- bridge <- patch      (exactly the mount order)
#   7 whitelist the tree in .gitignore, commit it, tag it v<ver>-decompiled
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
    -h|--help) sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1 (--help)" ;;
  esac
done

[ -n "$VER" ] || VER=$(layer_ver)
TREE="$W/effective_$VER"
TREE_REL=$(layer_tagpath "$VER")
TAG="v$VER-decompiled"
PREV=$(layer_prev "$VER")
HASHLOG="$LISTINGS/layer-hashes-$VER.txt"

# --- the layer set to ingest ------------------------------------------------------------------
# --pack keeps the old single-pack behaviour (kind from the file name); otherwise it is the manifest.
if [ -n "$PACK" ]; then
  [ -f "$PACK" ] || die "no such pack: $PACK"
  case "${PACK##*/}" in
    bridge_*) KIND="bridge"; BVER="${PACK##*_to_}"; BVER="${BVER%.pck}"; VER="${VER:-$BVER}" ;;
    *)        KIND="patch" ;;
  esac
  MANIFEST="$KIND	${PACK##*/}	$VER"
else
  MANIFEST=$(layer_manifest "$VER")
fi
[ -n "$MANIFEST" ] || die "empty layer manifest for $VER - state.json gives no bridge/patch and none was found on disk"

echo "layer_sync.sh: version $VER  (state.json says $(layer_ver))"
echo "$MANIFEST" | while IFS=$'\t' read -r k f v; do echo "  layer  $k  $f  (v$v)"; done
echo "  into     $TREE  ->  tag $TAG"
echo "  baseline prev: ${PREV:-none}"

# resolve each manifest entry to a readable pack (live user://patches first, then orig/)
SRC_LIST=""
MISSING=0
while IFS=$'\t' read -r KIND FILE LVER; do
  SRC="$PATCHES/$FILE"
  [ -f "$SRC" ] || SRC="$ORIG/$FILE"
  if [ ! -f "$SRC" ]; then
    echo "  MISSING: no pack file for $KIND $FILE (cannot decompile it; the tree will be incomplete)" >&2
    MISSING=$((MISSING + 1)); continue
  fi
  case "$(layer_magic "$SRC")" in
    "$GDPC_MAGIC") : ;;
    "$GDEC_MAGIC") die "$SRC is an ENCRYPTED download (magic GDEC), not a mountable pack.
  The updater decrypts packs with a key in updater.gd (_decrypt), so launch the game once (./play.sh), let
  it mount the layer, then copy user://patches/$FILE again - PATCH_SYSTEM.md §19.2." ;;
    *) die "unexpected magic '$(layer_magic "$SRC")' in $SRC (want GDPC)" ;;
  esac
  SRC_LIST+="$(printf '%s\t%s\t%s\t%s' "$KIND" "$FILE" "$LVER" "$SRC")"$'\n'
done <<< "$MANIFEST"
SRC_LIST=${SRC_LIST%$'\n'}
[ -n "$SRC_LIST" ] || die "no readable plaintext pack for $VER (live: $PATCHES, pristine: $ORIG)"
# the decompile dirs are keyed by KIND+VER; PATCHVER disambiguates a bridge that shares its version with
# the patch pack (then scripts_full_<ver> is the PATCH's, and the bridge gets scripts_bridge_<ver>)
PATVER=$(printf '%s
' "$MANIFEST" | awk -F'	' '$1=="patch"{print $3; exit}')

if [ -n "$(git -C "$ROOT" tag -l "$TAG")" ] && [ "$FORCE" != 1 ]; then
  if [ "$DRY" = 1 ]; then
    echo "  baseline $TAG already exists -> nothing to ingest. Continue from step 2: ./update.sh --skip-sync"
    exit 0
  fi
  die "already ingested (tag $TAG; orig/$(layer_pack "$VER") $( [ -f "$ORIG/$(layer_pack "$VER")" ] && echo present || echo MISSING)).
  --force redoes the whole thing (it will not move the existing tag)."
fi
if [ -d "$TREE" ] && [ "$FORCE" != 1 ]; then
  die "$TREE exists. --force replaces it with a fresh decompile (check 'git diff $TAG' first if it is modified)."
fi
if [ "$DRY" = 1 ]; then
  echo; echo "dry run: would run steps 2-7 above; nothing written."
  exit 0
fi

N_ALL=0; N_GDC=0; N_GD=0; N_RAW=0; REVS=""
: > "$HASHLOG"

# ================================================================= 2..5, per layer ==============
while IFS=$'\t' read -r KIND FILE LVER SRC; do
  RAW=$(layer_raw_dir "$KIND" "$LVER" "$PATVER")
  FULL=$(layer_src_dir "$KIND" "$LVER" "$PATVER")
  LOG="$W/decompile_${KIND}_$LVER.log"
  LIST=$(layer_listing "$KIND" "$LVER")
  PACK_NAME="$FILE"
  layer_ck "layers $KIND $FILE (v$LVER)"

  # --- 2. pristine copy -------------------------------------------------------------------------
  BASE="$ORIG/$PACK_NAME"
  SZ=$(stat -c %s "$SRC" 2>/dev/null || echo 0)
  KEPT=0
  if [ -f "$BASE" ]; then
    if [ "$FORCE" = 1 ] && ! cmp -s "$SRC" "$BASE"; then
      die "orig/$PACK_NAME differs from $SRC.
  orig/ must hold the developers' own bytes - if a build of ours ever landed there, restore the official
  pack (see PATCH_SYSTEM.md §14) before ingesting, otherwise a mod would be built on top of a mod."
    fi
    KEPT=1
    echo "  orig/$PACK_NAME already there ($(sha256 "$BASE" | cut -c1-16)...)"
  elif [ "$SZ" -le "$KEEP_MAX" ]; then
    mkdir -p "$ORIG"
    cp -p "$SRC" "$BASE" || die "copy failed"
    KEPT=1
    echo "  copied -> orig/$PACK_NAME"
  else
    echo "  SKIPPED orig/ copy: $SZ B > KEEP_MAX ($KEEP_MAX) — recorded by sha256 only (work/logs/$(basename "$HASHLOG"))"
  fi
  SHA=$(sha256 "$SRC")
  printf '%s\t%s\t%s\t%s\n' "$SHA" "$SZ" "$KIND" "$PACK_NAME" >> "$HASHLOG"
  echo "  magic $(layer_magic "$SRC")  sha ${SHA:0:16}...  $SZ B"

  # --- 3. member listing ------------------------------------------------------------------------
  "$GDRE" --list-files="$SRC" 2>/dev/null | grep '^res://' | sort > "$LIST"
  M_ALL=$(grep -c '^res://' "$LIST"); M_GDC=$(grep -c '\.gdc$' "$LIST")
  echo "  members $M_ALL (of which $M_GDC scripts) -> work/logs/$(basename "$LIST")"
  N_ALL=$((N_ALL + M_ALL)); N_GDC=$((N_GDC + M_GDC))

  [ "$M_GDC" = 0 ] && { echo "  no scripts in this pack - nothing to decompile"; continue; }

  # --- 4. extract -------------------------------------------------------------------------------
  layer_ck "extract .gdc -> $(basename "$RAW")"
  [ "$FORCE" = 1 ] && rm -rf "$RAW"
  [ -d "$RAW" ] || "$GDRE" --extract="$SRC" --include='*.gdc' --output="$RAW" > "$W/extract_${KIND}_$LVER.log" 2>&1 \
    || die "extract failed, see $(basename "$W")/extract_${KIND}_$LVER.log"
  R=$(find "$RAW" -name '*.gdc' | wc -l)
  [ "$R" = "$M_GDC" ] || die "extracted $R of $M_GDC scripts from $PACK_NAME"
  echo "  $R .gdc"; N_RAW=$((N_RAW + R))

  # --- 5. decompile -----------------------------------------------------------------------------
  REV=$(layer_rev "$(find "$RAW" -name '*.gdc' | head -1)")
  REVS="$REVS $REV"
  case "$REV" in
    101) [ "$BYTECODE" = "4.5.0-stable" ] || echo "  NOTE: rev $REV while BYTECODE=$BYTECODE" ;;
    *) die "bytecode revision $REV ($PACK_NAME) is not the one we know (101 = 4.5.0-stable).
  Pick the token for it in '$GDRE --list-bytecode-versions' and rerun as BYTECODE=<token> $0 --force" ;;
  esac
  echo "  header GDSC rev $REV OK"
  if [ -d "$FULL" ] && [ "$FORCE" != 1 ] && [ "$(find "$FULL" -name '*.gd' | wc -l)" = "$R" ]; then
    echo "  already decompiled: $(basename "$FULL") ($R .gd) - reusing"; N_GD=$((N_GD + R)); continue
  fi
  layer_ck "decompile $(basename "$FULL") (bytecode $BYTECODE, -P$JOBS)"
  [ "$FORCE" = 1 ] && rm -rf "$FULL"; mkdir -p "$FULL"
  export RAW FULL GDRE BYTECODE LOG
  find "$RAW" -name '*.gdc' -print0 | xargs -0 -P "$JOBS" -n 1 bash -c '
    g="$1"; rel="${g#"$RAW/"}"; n="$(basename "$rel" .gdc)"; d="$FULL/${rel%/*}"
    [ "$d" = "$FULL" ] && d="$FULL"
    mkdir -p "$d"
    if ! "$GDRE" --decompile="$g" --bytecode="$BYTECODE" --output="$d" >>"$LOG" 2>&1 || [ ! -s "$d/$n.gd" ]; then
      echo "FAIL $g" >> "$LOG"
    fi
  ' _ || die "xargs failed (gdre_tools crashing?)"
  N_FAIL=$(grep -c '^FAIL' "$LOG" 2>/dev/null); G=$(find "$FULL" -name '*.gd' | wc -l)
  echo "  $G .gd, ${N_FAIL:-0} failure(s)  (log: $(basename "$LOG"))"
  [ "${N_FAIL:-0}" = 0 ] && [ "$G" = "$R" ] || { grep '^FAIL' "$LOG" | sed 's/^/    /'; die "decompile incomplete"; }
  N_GD=$((N_GD + G))
done <<< "$SRC_LIST"
[ "$MISSING" = 0 ] || echo "  NOTE: $MISSING manifest layer(s) were missing - the tree is NOT complete for $VER"

if [ -n "$PREV" ]; then
  t1=$(mktemp); t2=$(mktemp)
  for l in $(layer_listings "$PREV"); do grep '^res://' "$l"; done | sort -u > "$t1"
  for l in $(layer_listings "$VER");  do grep '^res://' "$l"; done | sort -u > "$t2"
  echo "  members seen by the game: $PREV $(wc -l < "$t1") -> $VER $(wc -l < "$t2")  (+$(comm -13 "$t1" "$t2" | wc -l) / -$(comm -23 "$t1" "$t2" | wc -l))"
  n=$(comm -23 "$t1" "$t2" | wc -l); rm -f "$t1" "$t2"
  [ "$n" = 0 ] || echo "  NOTE: members disappeared -> the patch pack is not a superset of $PREV; the tree follows the mount order, not history (§21)."
fi

# --- 6. assemble the tree ---------------------------------------------------------------------
layer_ck "6/7 assemble effective_$VER (base <- bridge <- patch, exactly as the game mounts them)"
[ -d "$BASE_LAYER" ] || die "missing the retail decompile $BASE_LAYER (see work/README.md)"
LAYERS=("$BASE_LAYER")
# a NEWER bridge supersedes every older one and every patch pack older than it: they are not mounted,
# so they must not be in the tree. Only state.json knows the truth -> layer_manifest, never a glob.
while IFS=$'\t' read -r KIND FILE LVER SRC; do
  d=$(layer_src_dir "$KIND" "$LVER" "$PATVER")
  [ -d "$d" ] || { echo "  SKIP $(basename "$d") (no decompile for $FILE)"; continue; }
  n=$(find "$d" -name '*.gd' 2>/dev/null | wc -l)
  [ "$n" = 0 ] && { echo "  SKIP $(basename "$d") (0 scripts)"; continue; }
  LAYERS+=("$d")
done <<< "$SRC_LIST"
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

# --- 7. whitelist + baseline commit -----------------------------------------------------------
layer_ck "manifest snapshot"
MF=$(layer_manifest_file "$VER")
mkdir -p "$LISTINGS"
printf '%s\n' "$SRC_LIST" | cut -f1-3 > "$MF"
echo "  $(wc -l < "$MF") pack(s) mounted -> work/logs/$(basename "$MF")"

layer_ck "7/7 .gitignore + baseline commit + tag"
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

if [ "$NOCOMMIT" = 1 ]; then
  echo "  --no-commit: tree ready at $(basename "$TREE"), tag $TAG not created"
  exit 0
fi
ADD=(.gitignore "$TREE_REL")
for p in "$MF" "$HASHLOG"; do
  [ -f "$p" ] || continue
  git -C "$ROOT" check-ignore -q "${p#"$ROOT"/}" && continue     # untracked-by-policy evidence (regenerable)
  ADD+=("$p")
done
git -C "$ROOT" add "${ADD[@]}" || die "git add failed"
if git -C "$ROOT" diff --cached --quiet; then
  echo "  nothing new: the fresh decompile is byte-identical to $TAG (no commit, tag untouched)"
  exit 0
fi
if git -C "$ROOT" diff --cached --name-only | grep -Ev '(\.(gd|cfg|godot|txt|tsv)|(^|/)\.gitignore)$' | grep -q .; then
  git -C "$ROOT" diff --cached --name-only | grep -Ev '(\.(gd|cfg|godot|txt|tsv)|(^|/)\.gitignore)$' | sed 's/^/    /'
  git -C "$ROOT" reset -q
  die "the tree contains non-text files (above) - this repo stays text-only, inspect before committing"
fi
NEW_LIST=""
if [ -n "$PREV" ]; then
  git -C "$ROOT" ls-tree -r --name-only "v$PREV-decompiled" -- "work/60_patches/effective_$PREV" \
    | sed "s#work/60_patches/effective_$PREV/##" | sort > /tmp/prev_tree.txt
  ( cd "$TREE" && find . -name '*.gd' | sed 's#^\./##' | sort ) > /tmp/new_tree.txt
  NEW_LIST=$(comm -13 /tmp/prev_tree.txt /tmp/new_tree.txt)
  GONE_LIST=$(comm -23 /tmp/prev_tree.txt /tmp/new_tree.txt)
fi
{ echo "Decompile official patch layer $VER -> effective_$VER (pristine baseline)"
  echo
  echo "Layer manifest (mount order):"
  printf '%s\n' "$SRC_LIST" | cut -f1-3 | while IFS=$'\t' read -r k f v; do echo "  $k  $f  (v$v)"; done
  echo "Packs: $(wc -l < "$HASHLOG") recorded in work/logs/layer-hashes-$VER.txt; scripts $N_GDC, decompiled $N_GD/$N_RAW, 0 failures."
  echo "All members: $N_ALL. Bytecode rev:${REVS} (101 = $BYTECODE)."
  echo "Tree = $(for L in "${LAYERS[@]}"; do basename "$L"; done | tr '\n' ' ')= $N_TREE .gd."
  [ -n "$NEW_LIST" ] && echo "New scripts vs v$PREV-decompiled: $(echo "$NEW_LIST" | tr '\n' ' ')"
  [ -n "${GONE_LIST:-}" ] && echo "Dropped vs v$PREV-decompiled (no longer shipped by the bridge): $(echo "$GONE_LIST" | wc -l) file(s)"
} > /tmp/layer_sync_msg.txt
git -C "$ROOT" commit -q -F /tmp/layer_sync_msg.txt || die "commit failed"
git -C "$ROOT" tag "$TAG" || die "tag $TAG failed"
echo "  committed + tagged $TAG  ($(git -C "$ROOT" rev-parse --short HEAD))"
[ -n "$NEW_LIST" ] && echo "  new vs $PREV: $(echo "$NEW_LIST" | tr '\n' ' ')"
echo
echo "next:  ./layer_diff.sh          (what the dev changed where our mod lives)"
echo "       ./mod_apply.sh --build   (re-apply the mod onto $TREE, then build)"
