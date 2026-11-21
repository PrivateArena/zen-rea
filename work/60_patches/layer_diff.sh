#!/usr/bin/env bash
# layer_diff.sh — what the developer changed between two pristine patch layers, and what that means
# for our mod. Read this BEFORE re-applying the mod (mod_apply.sh) - it is the 30-second version of
# the hand comparison that made the 0.2.4 and 0.2.7 migrations safe.
#
#   ./layer_diff.sh                     newest two baselines (from the git tags)
#   ./layer_diff.sh --from 0.2.4 --to 0.2.7
#   ./layer_diff.sh --files            also list every changed script
#   ./layer_diff.sh --show FILE        unified diff of one script (scripts/core/player.gd), then exit
#
# Reports: 1) member lists of the two packs  2) script tree (same/changed/new/gone)
#          3) churn in the files our mod edits (the merge risk)  4) every balance const the mod reads
#          5) the shipped lines mod_apply rewrites (lint-allow.txt) and whether they still exist
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/layer_env.sh"
layer_need

FROM="" TO="" FILES=0 SHOW=""
while [ $# -gt 0 ]; do
  case "$1" in
    --from) FROM="$2"; shift 2 ;;
    --to) TO="$2"; shift 2 ;;
    --files) FILES=1; shift ;;
    --show) SHOW="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1 (--help)" ;;
  esac
done

TAGS=$(layer_tags)
N=$(echo "$TAGS" | wc -l)
[ -n "$TO" ] || TO=$(echo "$TAGS" | tail -1)
[ -n "$FROM" ] || FROM=$(echo "$TAGS" | tail -2 | head -1)
for v in "$FROM" "$TO"; do
  [ -n "$(git -C "$ROOT" tag -l "v$v-decompiled")" ] || die "no baseline tag v$v-decompiled (known: $(echo "$TAGS" | tr '\n' ' '))"
done
PFROM="work/60_patches/effective_$FROM"; PTO="work/60_patches/effective_$TO"

A=$(mktemp -d "${TMPDIR:-/tmp}/layerdiff.XXXXXX")
B=$(mktemp -d "${TMPDIR:-/tmp}/layerdiff.XXXXXX")
trap 'rm -rf "$A" "$B"' EXIT
git -C "$ROOT" archive "v$FROM-decompiled" "$PFROM" | tar -x -C "$A" || die "archive $FROM failed"
git -C "$ROOT" archive "v$TO-decompiled" "$PTO" | tar -x -C "$B" || die "archive $TO failed"
OLD="$A/$PFROM"; NEW="$B/$PTO"

if [ -n "$SHOW" ]; then
  diff -u "$OLD/$SHOW" "$NEW/$SHOW" | sed "1,2s#$OLD#v$FROM#;1,2s#$NEW#v$TO#"
  exit 0
fi

echo "layer_diff.sh: v$FROM-decompiled  ->  v$TO-decompiled   (both pristine, straight off the tags)"

# --- 1. pack members --------------------------------------------------------------------------
layer_ck "1/5 pack members"
LF="$LISTINGS/patch-$FROM-files.txt"; LT="$LISTINGS/patch-$TO-files.txt"
# normalise: older listings were produced before the pipeline existed (header lines, unsorted)
mf="$A/members-$FROM"; mt="$B/members-$TO"
for pair in "$LF:$mf" "$LT:$mt"; do
  src="${pair%%:*}"; dst="${pair##*:}"
  [ -s "$src" ] && grep '^res://' "$src" | sort -u > "$dst" || : > "$dst"
done
if [ -s "$mf" ] && [ -s "$mt" ]; then
  printf '  %-8s %5s members  %3s scripts\n' "$FROM" "$(wc -l < "$mf")" "$(grep -c '\.gdc$' "$mf")"
  printf '  %-8s %5s members  %3s scripts\n' "$TO"   "$(wc -l < "$mt")" "$(grep -c '\.gdc$' "$mt")"
  a=$(comm -13 "$mf" "$mt" | wc -l); d=$(comm -23 "$mf" "$mt" | wc -l)
  echo "  +$a -$d members vs $FROM"
  [ "$d" = 0 ] || { echo "  removed (the layer is NOT a superset - check the §4 layer order):"; comm -23 "$mf" "$mt" | sed 's/^/    /' | head -20; }
else
  echo "  (no listings yet - layer_sync.sh writes work/logs/patch-<ver>-files.txt)"
fi

# --- 2. script tree ---------------------------------------------------------------------------
layer_ck "2/5 script tree"
( cd "$OLD" && find . -name '*.gd' | sort ) > "$A/old.lst"
( cd "$NEW" && find . -name '*.gd' | sort ) > "$B/new.lst"
same=0; : > "$A/changed"; : > "$A/added"; : > "$A/gone"
while read -r f; do
  if ! [ -f "$OLD/$f" ]; then echo "$f" >> "$A/added"; continue; fi
  if cmp -s "$OLD/$f" "$NEW/$f"; then same=$((same+1)); else echo "$f" >> "$A/changed"; fi
done < "$B/new.lst"
comm -23 "$A/old.lst" "$B/new.lst" > "$A/gone"
printf '  same %s   changed %s   new %s   gone %s\n' "$same" "$(wc -l < "$A/changed")" \
  "$(wc -l < "$A/added")" "$(wc -l < "$A/gone")"
[ -s "$A/added" ] && { echo "  new:";   sed 's/^/    /' "$A/added"; }
[ -s "$A/gone" ]  && { echo "  gone:";  sed 's/^/    /' "$A/gone"; }
[ "$FILES" = 1 ] && { echo "  changed:"; sed 's/^/    /' "$A/changed"; }

# --- 3. our files -----------------------------------------------------------------------------
layer_ck "3/5 churn in the scripts our mod edits"
if [ ! -f "$MODPATCH" ]; then
  echo "  (no mod-latest.patch - nothing to check)"
else
  touch=$(grep '^+++ b/' "$MODPATCH" | sed 's#.*/effective_[0-9.]*/##' | sort -u)
  risky=0
  for f in $touch; do
    if ! [ -f "$NEW/$f" ]; then echo "  GONE     $f  <- our patch target no longer exists, expect a conflict"; risky=$((risky+1)); continue; fi
    if ! [ -f "$OLD/$f" ]; then echo "  NEW      $f"; continue; fi
    n=$(diff "$OLD/$f" "$NEW/$f" | grep -c '^[<>]')
    if [ "$n" = 0 ]; then printf '  %-8s %-42s unchanged by the dev\n' "-" "$f"
    else printf '  %-8s %-42s %s line(s) changed by the dev\n' "DRIFT" "$f" "$n"; risky=$((risky+1)); fi
  done
  echo "  => $risky of $(echo "$touch" | wc -l) patched scripts moved"
fi

# --- 4. the consts the mod reads --------------------------------------------------------------
layer_ck "4/5 balance consts our mod depends on"
GD_OLD="$OLD/scripts/autoload/game_data.gd"; GD_NEW="$NEW/scripts/autoload/game_data.gd"
ids=$(grep '^+' "$MODPATCH" 2>/dev/null | grep -o 'GameData\.[A-Z_0-9]\{3,\}' | cut -d. -f2 | sort -u)
[ -n "$ids" ] || echo "  (no GameData.* references found in the mod)"
moved=0
for id in $ids; do
  a=$(grep -m1 "^const $id:" "$GD_OLD" 2>/dev/null); b=$(grep -m1 "^const $id:" "$GD_NEW" 2>/dev/null)
  if [ "$a" = "$b" ]; then continue; fi
  moved=$((moved+1))
  echo "  $id"
  [ -n "$a" ] && echo "    was: ${a#const }"
  [ -n "$b" ] && echo "    now: ${b#const }"
  [ -z "$a" ] && echo "    (new const in this layer)"
done
[ "$moved" = 0 ] && echo "  every const the mod reads has the same value in both layers"

# --- 5. rewrite targets -----------------------------------------------------------------------
layer_ck "5/5 shipped lines the mod replaces (lint-allow.txt) must still exist"
miss=0
while IFS= read -r line; do
  case "$line" in ''|\#*) continue ;; esac
  case "$line" in const\ MOD_TAG*) continue ;; esac
  if ! grep -rqF -- "$line" "$NEW" 2>/dev/null; then
    # the line may legitimately have been replaced already in the PREVIOUS layer: show its status
    if grep -rqF -- "$line" "$OLD" 2>/dev/null; then
      echo "  MOVED/REWRITTEN by the dev:"; echo "    $line"; miss=$((miss+1))
    else
      echo "  unknown line in lint-allow.txt (never seen in either layer):"; echo "    $line"
    fi
  fi
done < "$W/lint-allow.txt"
[ "$miss" = 0 ] && echo "  all present - mod_apply.sh should merge without hand resolution"

layer_ck "done"
echo "next:  ./mod_apply.sh --build      (or --dry-run first; conflicts are resolved by hand, see §10)"
