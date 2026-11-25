#!/usr/bin/env bash
# mod_apply.sh — re-apply our mod (mod-latest.patch) onto a freshly decompiled layer, then prove it
# landed where it belongs. Run layer_diff.sh first to see what the developer moved.
#
#   ./mod_apply.sh                      apply onto effective_<ver> from state.json (merge mode)
#   ./mod_apply.sh --ver 0.2.8         ...or a specific layer
#   ./mod_apply.sh --tree DIR           ...or an arbitrary tree (self-test: a scratch copy, say)
#   ./mod_apply.sh --dry-run            what patch would say; writes nothing
#   ./mod_apply.sh --build              build.sh after applying            ./mod_apply.sh --deep
#   ./mod_apply.sh --build --install    and install it (only after a play-test of the previous build)
#   ./mod_apply.sh --force              apply even though the tree already carries edits
#   ./mod_apply.sh --restore            take the tree back to its pristine tag state (saves the mod first)
#
# Merge mode (`patch --merge`) is the whole point: hunks that still match go in silently, hunks whose
# surroundings the developer rewrote come out with <<<<<<< markers instead of landing somewhere wrong.
# Never accept a conflicted tree as "applied": resolve it by hand, keep the developer's new code and move
# our knob onto it (PATCH_SYSTEM.md §19.1 is a worked example), then rerun this script's checks with
# --check.
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/layer_env.sh"
layer_need

VER="" TREE="" DRY=0 FORCE=0 BUILD=0 RESTORE=0 CHECK=0 BARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ver) VER="$2"; shift 2 ;;
    --tree) TREE="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --force) FORCE=1; shift ;;
    --build) BUILD=1; shift ;;
    --deep) BUILD=1; BARGS+=(--deep); shift ;;
    --install) BUILD=1; BARGS+=(--install); shift ;;
    --restore) RESTORE=1; shift ;;
    --check) CHECK=1; shift ;;
    -h|--help) sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option: $1 (--help)" ;;
  esac
done

[ -n "$VER" ] || VER=$(layer_ver)
[ -n "$TREE" ] || TREE=$(layer_tree "$VER")
[ -d "$TREE" ] || die "no tree $TREE - run \"$W/layer_sync.sh\" --ver $VER first"
TAG="v$VER-decompiled"
TREE_REL=$(layer_tagpath "$VER")
[ -n "$(git -C "$ROOT" tag -l "$TAG")" ] || die "no baseline tag $TAG for $TREE - this tree is not a recorded pristine build"
PREV=$(layer_prev "$VER")

# --- restore ----------------------------------------------------------------------------------
if [ "$RESTORE" = 1 ]; then
  if ! git -C "$ROOT" diff --quiet "$TAG" -- "$TREE_REL"; then
    bk="$LISTINGS/mod-backup-$VER-$(date +%Y%m%d-%H%M%S).patch"
    git -C "$ROOT" diff "$TAG" -- "$TREE_REL" > "$bk"
    echo "saved the current edits -> ${bk#$ROOT/}"
  fi
  git -C "$ROOT" checkout "$TAG" -- "$TREE_REL" && echo "restored $TREE_REL to $TAG (pristine)"
  echo "note: the installed pack is untouched - use ./build.sh --restore for that"
  exit 0
fi

# --- dirty-tree guard -------------------------------------------------------------------------
if ! git -C "$ROOT" diff --quiet "$TAG" -- "$TREE_REL" && [ "$FORCE" != 1 ] && [ "$CHECK" != 1 ]; then
  echo "  $(git -C "$ROOT" diff --stat "$TAG" -- "$TREE_REL" | tail -1)"
  if [ "$DRY" = 1 ]; then
    echo "  $TREE already carries the mod - nothing to dry-run. Use --check to audit it, or --restore."
    exit 0
  fi
  die "$TREE already carries edits relative to $TAG - the mod is (or something is) already applied.
  Re-applying mod-latest.patch on top of an applied mod double-applies it. Either
  ./mod_apply.sh --restore (back up + pristine), or --force if you know what you are doing,
  or --check to just audit what is in the tree now."
fi

# --- apply ------------------------------------------------------------------------------------
if [ "$CHECK" != 1 ]; then
  layer_ck "apply $MODPATCH onto $(basename "$TREE") (patch -p4 --merge)"
  [ -f "$MODPATCH" ] || die "no $MODPATCH (build.sh exports it after every build)"
  if [ "$DRY" = 1 ]; then
    ( cd "$TREE" && patch -p4 --merge --dry-run < "$MODPATCH" )
    echo "  dry run: nothing written (rc=$?)"
    exit 0
  fi
  ( cd "$TREE" && patch -p4 --merge < "$MODPATCH" )
  case $? in
    0) echo "  applied clean - the developer did not touch our choke points" ;;
    1) echo "  applied with CONFLICTS (markers left in place, .orig backups beside the files)" ;;
    *) die "patch failed outright - nothing to trust here, inspect $(basename "$TREE")" ;;
  esac
fi

# --- audit 1: conflict markers ----------------------------------------------------------------
CONFLICTS=$(grep -rlE '^<<<<<<<' "$TREE/scripts" "$TREE/addons" 2>/dev/null)
layer_ck "audit 1/3 conflict markers"
if [ -n "$CONFLICTS" ]; then
  echo "$CONFLICTS" | sed "s#$TREE/#  #"
  echo "  -> resolve by hand: keep the developer's new code, move our knob onto it, then"
  echo "     ./mod_apply.sh --ver $VER --check   (and delete the *.gd.orig)"
else
  echo "  none"
fi

# --- audit 2: did every knob land in the function it belongs to? ------------------------------
layer_ck "audit 2/3 insertion sites"
# The mod only ever wraps an existing statement, so a MOD_ reference on an indented line marks a real
# choke point. Compare those sites against the previous layer's MODDED tree, where the same knob was
# proven to work - a moved site means the knob is now somewhere else (or dead).
enclosing() { awk -v L="$1" 'NR<=L && /^(static )?func /{f=$0} NR==L{print f}' "$2" | sed -E 's/^(static )?func ([A-Za-z_0-9]+).*/\2/'; }
SITES=$(mktemp)
git -C "$ROOT" diff "$TAG" -- "$TREE_REL" \
  | awk '/^\+\+\+ b\//{f=$2; sub(/.*effective_[0-9.]+\//,"",f); next}
         /^\+\t/ && /MOD_/ { l=$0; sub(/^\+/,"",l); print f "\t" l }' > "$SITES"
REF=""
for t in $(ls -1d "$W"/effective_* 2>/dev/null | sort -V); do
  [ "$(cd "$t" && pwd)" = "$(cd "$TREE" && pwd)" ] && continue
  [ -n "$(grep -rl 'MOD_' "$t/scripts" 2>/dev/null)" ] && REF="$t"
done
n_new=0; n_bad=0; n_ok=0
while IFS=$'\t' read -r f txt; do
  [ -f "$TREE/$f" ] || continue
  ln=$(grep -Fn -- "$txt" "$TREE/$f" | tail -1 | cut -d: -f1)
  fn=$(enclosing "$ln" "$TREE/$f")
  of=""; [ -n "$REF" ] && [ -f "$REF/$f" ] && of=$(grep -Fn -- "$txt" "$REF/$f" | tail -1 | cut -d: -f1)
  if [ -n "$of" ]; then
    ofn=$(enclosing "$of" "$REF/$f")
    if [ "$ofn" = "$fn" ]; then printf '  ok     %-24s %s()  %s\n' "$f" "$fn" "$(echo "$txt" | cut -c1-58)"; n_ok=$((n_ok+1)); continue; fi
    printf '  MOVED  %-24s %s()  (was %s() in %s)  %s\n' "$f" "${fn:-<none>}" "${ofn:-<none>}" "$(basename "$REF")" "$(echo "$txt" | cut -c1-40)"; n_bad=$((n_bad+1))
  else
    printf '  new?   %-24s %s()  %s\n' "$f" "${fn:-<none>}" "$(echo "$txt" | cut -c1-58)"
  fi
  n_new=$((n_new+1))
done < "$SITES"; rm -f "$SITES"
[ -n "$REF" ] || echo "  (no earlier layer with the mod applied to compare against - review the list above)"
[ $((n_new + n_bad + n_ok)) = 0 ] && echo "  no indented MOD_ statements found?! check the patch"
[ $n_ok = 0 ] || echo "  $n_ok knob site(s) verified in the same function as in $(basename "${REF:-?}")"

# --- audit 3: lint pre-flight -----------------------------------------------------------------
layer_ck "audit 3/3 lint-allow.txt coverage (the build.sh gate)"
missing=0
while IFS= read -r f; do
  while IFS= read -r line; do
    l=${line#-}
    [ -z "${l// /}" ] && continue
    case "$l" in const\ MOD_TAG*) continue ;; esac
    grep -qxF -- "$l" "$W/lint-allow.txt" && continue
    git -C "$ROOT" diff "$TAG" -- "$f" | grep -qF "+$l" && continue
    printf '  LINT %s\n         %s\n' "${f#*/effective_}" "$l"
    missing=$((missing+1))
  done < <( git -C "$ROOT" diff -U0 "$TAG" -- "$f" | grep '^-[^-]' )
done < <( git -C "$ROOT" diff --name-only "$TAG" -- "$TREE_REL" | grep '\.gd$' )
if [ "$missing" = 0 ]; then
  echo "  clean - build.sh lint will pass"
else
  echo "  these $missing line(s) were removed by the merge and are not accounted for. Usually that means"
  echo "  the developer rewrote the statement our knob sat in: re-point the knob at their new line, then"
  echo "  append the old line to lint-allow.txt, e.g."
  echo "    printf '\\t%s\\n' '<statement>' >> lint-allow.txt"
fi

layer_ck "summary"
echo "  tree: $(basename "$TREE")  tag: $TAG  conflicts: $(echo "$CONFLICTS" | grep -c . )  moved sites: $n_bad  lint gaps: $missing"
if [ -n "$CONFLICTS" ] || [ "$missing" != 0 ]; then
  echo "  NOT buildable yet - resolve the above first"
  exit 3
fi
[ "$BUILD" = 1 ] || { echo "  next: ./build.sh --deep   then install + play-test"; exit 0; }
layer_ck "build"
cd "$W" && exec ./build.sh "${BARGS[@]}"
