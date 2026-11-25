#!/usr/bin/env bash
# build.sh — turn the edited GDScript under effective_<ver>/ into a mountable top-layer patch pack.
#
#   ./build.sh              compile what changed + write out/patch_<ver>.pck  (touches nothing live)
#   ./build.sh --install    ... + back the official pack up to orig/ and install into user://patches
#   ./build.sh --deep       ... + decompile the built .gdc and list source lines it cannot show back
#   ./build.sh --restore    put the pristine official pack back (undo the mod)
#   ./build.sh --diff       show the source diff against the pristine baseline tag
#
# Source of truth  : work/60_patches/effective_<ver>/**.gd   (git-tracked)
# Baseline         : tag v<ver>-decompiled -> `git diff` IS the mod, and it drives the file list, so an
#                    edited script can never be forgotten at pack time.
# Bytecode target  : GDRE token 4.5.0-stable == revision 101, the revision this game's .gdc use.
# Pack it patches  : the OFFICIAL patch_<ver>.pck held in orig/ (never a previously modded one, else
#                    mods stack; the updater deletes the pack it replaces, so orig/ is the authority).
# Version          : taken from user://patches/state.json (override with MOD_VER=x.y.z) through the same
#                    layer_env.sh the ingest pipeline uses. state.json also carries bridge.version, so a
#                    parse that takes the LAST version line is a time bomb, not a shortcut.
set -uo pipefail

die() { echo "build.sh: $*" >&2; exit 1; }
sha() { sha256sum "$1" | cut -d' ' -f1; }

W="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$W/layer_env.sh"      # ROOT ORIG OUT PATCHES STATE GDRE BYTECODE + layer_pack/layer_ver/layer_manifest
die() { echo "build.sh: $*" >&2; exit 1; }      # layer_env defines its own; ours must win here
BUILD="$W/build"; VERIFY="$W/verify"

VER="${MOD_VER:-}"
[ -n "$VER" ] || VER=$(layer_ver 2>/dev/null)
case "$VER" in ''|*[!0-9.]*)
  die "cannot determine the current patch version from $STATE - set MOD_VER=x.y.z" ;;
esac
PACK="$(layer_pack "$VER")"
LIVE="$PATCHES/$PACK"
SRC="$W/effective_$VER"; SRCREL="${SRC#"$ROOT"/}"
BASE_TAG="${BASE_TAG:-v$VER-decompiled}"
SHA_OFFICIAL=""

require_pristine() {
  [ -f "$ORIG/$PACK" ] || die "no pristine official $PACK in $ORIG/.
  The updater replaces/deletes packs in user://, so that copy is the only trustworthy base.
  Copy it there from a fresh download (or from a pre-update backup) and rebuild - never build a mod
  on top of an already modded pack, the edits would stack."
  SHA_OFFICIAL=$(sha "$ORIG/$PACK")
}

[ -d "$SRC" ] || die "no decompiled source tree for v$VER: build $SRC (PATCH_SYSTEM.md §5) and tag it $BASE_TAG"
[ -x "$GDRE" ] || die "gdre_tools not found at $GDRE (set RE_BIN, or: . /media/jang/home/PortableApp/re/activate.sh)"

DEEP=0; INSTALL=0; ACTION=build
for a in "$@"; do
  case "$a" in
    --diff|--restore) ACTION="$a" ;;
    --install) INSTALL=1 ;;
    --deep) DEEP=1 ;;
    -h|--help) layer_usage; exit 0 ;;
    *) die "unknown option: $a" ;;
  esac
done

# --- diff -----------------------------------------------------------------------------------
if [ "$ACTION" = --diff ]; then
  [ -n "${BASE_TAG}" ] || die "no baseline tag"
  cd "$ROOT" || exit 1
  exec git diff "$BASE_TAG" -- "$SRCREL"
fi

# --- restore --------------------------------------------------------------------------------
if [ "$ACTION" = --restore ]; then
  require_pristine
  cp -f "$ORIG/$PACK" "$LIVE" || die "restore failed"
  echo "restored $LIVE  ($(stat -c %s "$LIVE") B, sha $(sha "$LIVE" | cut -c1-16)...)"
  echo "OK: byte-identical to the pristine copy in $ORIG/"
  exit 0
fi

# --- lint: no source line may simply disappear (catches truncated patches, e.g. an oldText that
#     matched only part of a line and left "3D" of "extends Node3D" stranded at the end of the patch) --
lint() {
  local rel bad=0 line allow="$W/lint-allow.txt"
  [ -f "$allow" ] || die "lint: $allow missing (list of intentionally replaced lines)"
  while IFS= read -r rel; do
    while IFS= read -r line; do
      line=${line#-}
      [ -z "${line// /}" ] && continue
      case "$line" in *"[MOD]"*) continue ;; esac
      grep -qxF -- "$line" "$allow" && continue
      if ! ( cd "$ROOT" && git diff "$BASE_TAG" -- "$rel" | grep -qF "+$line" ); then
        echo "  LINT $rel: line vanished; not re-added and not listed in lint-allow.txt: |$line|"; bad=$((bad + 1))
      fi
    done < <( cd "$ROOT" && git diff -U0 "$BASE_TAG" -- "$rel" | grep '^-[^-]' )
  done <<< "$1"
  return $bad
}

# --- which scripts did we edit? -------------------------------------------------------------
FILES=$(cd "$ROOT" && git diff --name-only "$BASE_TAG" -- "$SRCREL" | grep '\.gd$')
[ -n "$FILES" ] || die "no script differs from $BASE_TAG - nothing to build (see --diff)"
echo "== changed vs $BASE_TAG"
echo "$FILES" | sed 's|^|  |'
lint "$FILES" || die "lint failed: the mod would delete code it must not delete"
echo "  lint: every removed line is present again in the patched source"

mkdir -p "$BUILD" "$OUT" "$VERIFY"
ARGS=()
while IFS= read -r rel; do
  gd="$ROOT/$rel"
  res="res://${rel#"$SRCREL"/}"
  res="${res%.gd}.gdc"
  name=$(basename "$res")
  rm -f "$BUILD/$name"
  "$GDRE" --compile="$gd" --bytecode="$BYTECODE" --output="$BUILD" > "$BUILD/$name.log" 2>&1 \
    || die "compile failed: $rel (see $BUILD/$name.log)"
  gdc="$BUILD/$name"
  [ -f "$gdc" ] || die "no .gdc produced for $rel"
  hdr=$(head -c 5 "$gdc" | od -An -tx1 | tr -d ' \n')
  [ "$hdr" = "4744534365" ] || die "bad GDSC header/revision in $name (want 4744534365 = 'GDSC' + rev 101, got $hdr)"
  printf '  compiled %-20s %8d B  <-  source %8d B\n' "$name" "$(stat -c %s "$gdc")" "$(stat -c %s "$gd")"
  ARGS+=("--patch-file=$gdc=$res")
done <<< "$FILES"
[ ${#ARGS[@]} -gt 0 ] || die "no compiled output"

# --- pack -----------------------------------------------------------------------------------
require_pristine            # never patch a pack we already patched: always rebuild from orig/
BASEPACK="$ORIG/$PACK"
echo "== v$VER  base pack $BASEPACK  sha $(sha "$BASEPACK" | cut -c1-16)..."
rm -f "$OUT/$PACK"
"$GDRE" --pck-patch="$BASEPACK" "${ARGS[@]}" --output="$OUT/$PACK" > "$W/build.log" 2>&1 \
  || die "pck-patch failed, see $W/build.log"
[ -f "$OUT/$PACK" ] || die "pck-patch produced nothing"

# --- verify ---------------------------------------------------------------------------------
echo "== verify"
list_in=$(  "$GDRE" --list-files="$BASEPACK" 2>/dev/null)
list_out=$( "$GDRE" --list-files="$OUT/$PACK" 2>/dev/null)
n_in=$(  printf '%s\n' "$list_in"  | sed -n 's/^Total files: //p')
n_out=$( printf '%s\n' "$list_out" | sed -n 's/^Total files: //p')
new=$(printf '%s\n' "$list_out" | grep '^res://' | sort > "$VERIFY/out.txt"
      printf '%s\n' "$list_in"  | grep '^res://' | sort | comm -23 "$VERIFY/out.txt" -)
echo "  members: $n_in -> $n_out ; added:"; printf '    %s\n' "${new:-  (none)}"
rm -rf "$VERIFY/members"; mkdir -p "$VERIFY/members"
"$GDRE" --extract="$OUT/$PACK" --output="$VERIFY/members" > "$W/verify.log" 2>&1 \
  || die "extract of the built pack failed, see $W/verify.log"
bad=0
for pair in "${ARGS[@]}"; do
  pair=${pair#--patch-file=}; gdc=${pair%%=*}; res=${pair#*=}
  if [ -f "$VERIFY/members/${res#res://}" ] && [ "$(sha "$gdc")" = "$(sha "$VERIFY/members/${res#res://}")" ]; then
    printf '  member %-50s sha %s... OK\n' "$res" "$(sha "$gdc" | cut -c1-12)"
  else
    printf '  member %-50s MISSING or MISMATCH\n' "$res"; bad=$((bad + 1))
  fi
done
printf '%s\n' "$list_in" | grep '^res://' | while IFS= read -r m; do
  seen=0
  for pair in "${ARGS[@]}"; do [ "${pair#*=}" = "$m" ] && seen=1; done
  if [ "$seen" = 0 ] && [ ! -e "$VERIFY/members/${m#res://}" ]; then
    echo "  LOST original member: $m"
  fi
done > "$VERIFY/lost.txt" 2>&1
if [ -s "$VERIFY/lost.txt" ]; then echo "  $(cat "$VERIFY/lost.txt")"; bad=$((bad + 1)); fi
echo "  all other members carried over intact"
# --- mount-order audit: an override of a script no mounted pack ships is a DEAD override. It can happen
# when a layer stops shipping a file (the 0.2.11 bridge dropped nothing, but the 0.2.0-era bridge did).
# Fail CLOSED: no listings means no audit, so a build must never ship on an unaudited mount set.
echo "== shadow audit (every override must sit under something the game actually mounts)"
deal=0; LOWER="$VERIFY/lower.txt"; : > "$LOWER"
while IFS=$'\t' read -r lkind lfile lver; do
  l=$(layer_listing "$lkind" "$lver")
  if [ ! -s "$l" ]; then
    pk="$PATCHES/$lfile"; [ -f "$pk" ] || pk="$ORIG/$lfile"
    if [ -f "$pk" ]; then
      echo "  (rebuilding the missing listing work/logs/$(basename "$l"))"
      "$GDRE" --list-files="$pk" 2>/dev/null | grep '^res://' | sort > "$l"
    fi
  fi
  [ -s "$l" ] && grep '^res://' "$l" >> "$LOWER"
done < <(layer_manifest "$VER" 2>/dev/null)
[ -s "$LISTINGS/pck-files.txt" ] && grep '^res://' "$LISTINGS/pck-files.txt" >> "$LOWER" \
  || echo "  WARNING: no base-pack listing ($LISTINGS/pck-files.txt) - base-only overrides go unchecked"
if [ ! -s "$LOWER" ]; then
  echo "  CANNOT AUDIT: no member listing for any mounted pack of $VER (run layer_sync.sh) - refusing"
  die "shadow audit impossible - do NOT build blind"
fi
sort -u -o "$LOWER" "$LOWER"
for pair in "${ARGS[@]}"; do
  pair=${pair#--patch-file=}; res=${pair#*=}      # same split as the member-hash check below
  grep -qxF -- "$res" "$LOWER" && continue
  printf '  DEAD    %-46s shipped by NO mounted pack - the game would never load it\n' "$res"
  deal=$((deal + 1))
done
if [ "$deal" = 0 ]; then
  echo "  every override shadows a member of base/bridge/patch"
else
  bad=$((bad + deal))
fi
if [ "$DEEP" = 1 ]; then
  echo "== deep: decompile(compile(src)); source lines missing from the bytecode are advisory"
  echo "   (multi-line expressions are re-wrapped by the decompiler, so inspect, do not trust blindly)"
  for pair in "${ARGS[@]}"; do
    pair=${pair#--patch-file=}; gdc=${pair%%=*}; res=${pair#*=}
    n=$(basename "$res" .gdc)
    "$GDRE" --decompile="$gdc" --bytecode="$BYTECODE" --output="$VERIFY/rt/$n" > /dev/null 2>&1 || die "decompile failed for $n"
    lost=$(comm -23 <(grep -vE '^\s*#|^\s*$' "$(find "$SRC" -name "$n.gd")" | sed 's/[[:space:]]*$//' | sort) \
                    <(grep -vE '^\s*#|^\s*$' "$VERIFY/rt/$n/$n.gd" | sed 's/[[:space:]]*$//' | sort))
    if [ -n "$lost" ]; then printf '  %s: %d line(s) to inspect\n' "$n" "$(printf '%s\n' "$lost" | wc -l)"; printf '      %s\n' "$lost"; else echo "  $n: every source line present in the bytecode"; fi
  done
fi
[ "$bad" = 0 ] || die "verification found $bad problem(s) - do NOT install"
echo "  built $(stat -c %s "$OUT/$PACK") B  sha $(sha "$OUT/$PACK" | cut -c1-16)..."
# portable copy of the mod (for re-applying onto the next official build, PATCH_SYSTEM.md §10)
( cd "$ROOT" && git diff "$BASE_TAG" -- "$SRCREL" ) > "$W/mod-latest.patch"
( cd "$ROOT" && git diff "$BASE_TAG" -- "$SRCREL" ) > "$W/mod-$VER.patch"
echo "  exported the mod as $W/mod-latest.patch + mod-$VER.patch ($(wc -l < "$W/mod-latest.patch") lines)"

# --- install --------------------------------------------------------------------------------
if [ "$INSTALL" = 1 ]; then
  mkdir -p "$ORIG"
  if [ ! -f "$ORIG/$PACK" ]; then
    cp -p "$BASEPACK" "$ORIG/$PACK" && echo "== official pack backed up to $ORIG/"
  fi
  cp -f "$OUT/$PACK" "$LIVE" || die "install failed"
  echo "== installed -> $LIVE"
  echo "   undo with:  $0 --restore"
fi
echo "done. Start the game with ./play.sh  (no arguments after -- or patches will not mount)."
