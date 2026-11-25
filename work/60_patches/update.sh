#!/usr/bin/env bash
# update.sh — one command after the developer ships a new official patch: ingest the layer, see what
# moved, re-apply the mod, build it. Each step is also a standalone script (see --help there).
#
#   ./update.sh                  ingest + report + apply + build   (never installs)
#   ./update.sh --dry-run        what would happen, no writes at all
#   ./update.sh --skip-sync      the layer is already ingested; report + re-apply + build
#   ./update.sh --ver 0.2.8      act on a specific version instead of the one in state.json
#   ./update.sh --install        build AND install into user://patches  (only after a play-test)
#
# Deliberately conservative: it stops at the first conflict, because a conflicted mod is a *wrong* mod,
# and it never installs something nobody has played. The full background is PATCH_SYSTEM.md §10/§19.
set -uo pipefail

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/layer_env.sh"
layer_need

VER="" DRY=0 SKIP_SYNC=0 BARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ver) VER="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --skip-sync) SKIP_SYNC=1; shift ;;
    --install) BARGS+=(--install); shift ;;
    --deep) BARGS+=(--deep); shift ;;
    -h|--help) layer_usage; exit 0 ;;
    *) die "unknown option: $1 (--help)" ;;
  esac
done
[ -n "$VER" ] || VER=$(layer_ver)
SARGS=(--ver "$VER")
[ "$DRY" = 1 ] && SARGS+=(--dry-run)

echo "=============================================================="
echo " update.sh - official patch layer $VER   ($(date '+%Y-%m-%d %H:%M'))"
echo "   live version: $(layer_ver)   mod: $MODPATCH"
echo "=============================================================="

if [ "$SKIP_SYNC" != 1 ]; then
  layer_ck "step 1/3 layer_sync.sh"
  "$W/layer_sync.sh" "${SARGS[@]}" || die "step 1 failed - nothing was applied, the tree is untouched"
  [ "$DRY" = 1 ] && { echo; echo "dry run stops here: --dry-run cannot decompile without writing. Re-run for real, or ./layer_sync.sh --dry-run to re-plan."; exit 0; }
fi

layer_ck "step 2/3 layer_diff.sh"
"$W/layer_diff.sh" --to "$VER" || die "step 2 failed"

layer_ck "step 3/3 mod_apply.sh"
AARGS=(--ver "$VER" --build)
[ "$DRY" = 1 ] && AARGS=(--ver "$VER" --dry-run)
"$W/mod_apply.sh" "${AARGS[@]}" "${BARGS[@]}"
rc=$?
case $rc in
  0) echo; echo "DONE. Play-test it:  ../../play.sh   (no arguments after --) then  ../../play.sh --probe" ;;
  3) echo; echo "STOPPED: the mod did not merge cleanly onto $VER. Resolve the marked hunks, keep the"
     echo "developer's new code and move our knobs onto it (worked example: PATCH_SYSTEM.md §19.1), then"
     echo "    ./mod_apply.sh --ver $VER --check --build" ;;
  *) echo; echo "STOPPED: mod_apply.sh exited $rc - see its message above" ;;
esac
exit $rc
