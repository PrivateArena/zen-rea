#!/usr/bin/env bash
# play.sh — launch Midgard Survivors WITH the live patch layer mounted, and report which
#           version you are actually about to play.
#
# Why this script exists (verified — full findings in work/60_patches/PATCH_SYSTEM.md):
#   * The retail pack (0.1.273) is only the BASE layer. At startup the game mounts, in this order:
#         MidgardSurvivors.pck  <-  user://patches/bridge_0.1.273_to_<bridgeVer>.pck
#                               <-  user://patches/patch_<ver>.pck    (state.json names both)
#     and the LAST mounted pack wins, so the content you play is the newest patch. Since 0.2.11 the
#     bridge carries the scripts and the patch pack can be a small asset hotfix (PATCH_SYSTEM.md §21).
#   * Updater._enabled() returns false for ANY user argument after "--" (except --update-url and
#     --lang). That silently disables the updater AND both patch mounts -> you would be playing
#     0.1.273 content. So: engine flags go through --godot (safe), --user is loud and opt-in.
#   * Nothing in this script writes to the game directory or to the real user dir (read + exec).
#
# Usage
#   ./play.sh                          launch official build, patches mounted, your real profile
#   ./play.sh --status                 what is installed, which version, modded? (no launch)
#   ./play.sh --test                   --status + sha256 of the base pack too (no launch)
#   ./play.sh --probe                  proof the modded scripts really ran (user://mod_probe_*.txt)
#   ./play.sh --layer game_data.gdc    which pack owns a res:// member (layer shadow audit)
#   ./play.sh --dir DIR                launch a staged game dir instead of the retail one
#   ./play.sh --isolate              sandbox user:// into work/70_play_userdata (fresh saves,
#                                    mounts work/60_patches/out/*.pck if a mod pack was built)
#   ./play.sh --dry-run              print the command instead of running it
#   ./play.sh --godot --rendering-driver --opengl3 ...      engine args (before --)
#   ./play.sh --user --tips-test --/tmp/shots ...           user args (after --) = PATCHES OFF
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GAME_DIR="/media/jang/free/MidgardSurvivors/midgard-survivors-midgard-survivors-linux"
WORK="$ROOT/work"
LISTINGS="$WORK/logs"

APP="Midgard Survivors"
PATCHES="${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP/patches"
STATE="$PATCHES/state.json"

# One source of truth for the layer model: the same helpers the ingest/build pipeline uses.
LAYER_W="$ROOT/work/60_patches"
# shellcheck disable=SC1091
. "$LAYER_W/layer_env.sh"          # layer_state / layer_ver / layer_manifest / layer_listing / vcmp
die() { echo "play.sh: $*" >&2; exit 1; }        # layer_env defines its own; ours must win here

# Which packs is the game going to mount? state.json is authoritative (the updater rewrites it and
# DELETES the pack it replaces) - never hardcode a version or a bridge name here.
VER="$(layer_ver 2>/dev/null)"     # layer_ver: rejects the base version, falls back to the newest pack
PACK="$(layer_pack "${VER:-0.0.0}")"
LIVE="$PATCHES/$PACK"
MOD_PACK="$ROOT/work/60_patches/out/$PACK"   # output of the mod build step, when it exists

# sha256 of the pristine developer packs. Sources, in order of trust:
#   1. work/logs/layer-hashes-<ver>.txt  — recorded by layer_sync.sh at ingest, works for every pack size
#   2. work/60_patches/orig/<pack>       — the pristine bytes we kept (packs under KEEP_MAX)
# The updater wiped patches2/ on the 0.2.4 update and deletes the pack it replaces, so neither user://
# nor a previously-built pack is ever a reference. SHA_PATCH is the 0.2.3 fallback only.
SHA_BASE="a8d0b35b1434571d3c2cea23c9a697a6ea032300ba47d1479f7f3b640328a8b6"
SHA_PATCH="680b5dfd9cdc7290552c7e2b62057002ec0902a4573afb45ff74633e7af31b66"

MODE=launch DIR="$GAME_DIR" ISOLATE=0 VERIFY=0 LAYER="" DRY=0
ENGINE_ARGS=() USER_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -s|--status)  MODE=status; shift ;;
    -p|--probe)   MODE=probe; shift ;;
    -t|--test)    MODE=status; VERIFY=1; shift ;;
    -l|--layer)   MODE=layer; LAYER="${2:?--layer needs a path fragment}"; shift 2 ;;
    -d|--dir)     DIR="${2:?--dir needs a path}"; shift 2 ;;
    -i|--isolate) ISOLATE=1; shift ;;
    -n|--dry-run) DRY=1; shift ;;
    --godot)      shift; [ $# -gt 0 ] && { ENGINE_ARGS+=("$1"); shift; } ;;
    --user)       shift; [ $# -gt 0 ] && { USER_ARGS+=("$1"); shift; } ;;
    -h|--help)    layer_usage; exit 0 ;;
    *) echo "play.sh: unknown option '$1' (try --help)" >&2; exit 2 ;;
  esac
done

hr() { printf '%s\n' "--------------------------------------------------------------------------"; }

# official_sha PACK — the developer's own sha256 for a pack name, "" if we never recorded it
official_sha() {
  local name="$1" h=""
  h=$(awk -F'\t' -v n="$name" '$4 == n { print $1; exit }' "$LISTINGS"/layer-hashes-*.txt 2>/dev/null)
  [ -n "$h" ] && { echo "$h"; return; }
  local p="$LAYER_W/orig/$name"
  if [ -f "$p" ]; then sha256sum "$p" | cut -d' ' -f1; return; fi
  echo ""
}

# --- which pack owns a given res:// member --------------------------------------------------
do_layer() {
  local kind file lv spec tag f hit=0
  local -a specs=("base:$LISTINGS/pck-files.txt")
  echo "  mount order (last one wins):"
  printf '    %-9s %s\n' "base" "MidgardSurvivors.pck  (v$(layer_base_ver))"
  while IFS=$'\t' read -r kind file lv; do
    printf '    %-9s %s  (v%s)\n' "$kind" "$file" "$lv"
    specs+=("$kind:$(layer_listing "$kind" "$lv")")
  done < <(layer_manifest "${VER:-0}")
  hr
  for spec in "${specs[@]}"; do
    tag="${spec%%:*}"; f="${spec#*:}"
    if [ ! -f "$f" ]; then
      echo "  (no member listing for $tag — regenerate: gdre_tools --list-files=<pack> > $f)"
      continue
    fi
    grep -F -- "$LAYER" "$f" | sed "s|^|  ${tag^^}  |" | sort -u && hit=1
  done
  [ "$hit" = 1 ] || { echo "  '$LAYER' matches no member of any pack"; return 1; }
  hr; echo "  winner = last layer listed (patch > bridge > base). Edit THAT one, or put your file there."
}

# --- what is installed ----------------------------------------------------------------------
do_status() {
  local f h want mb hum sz base_pck="$DIR/MidgardSurvivors.pck"
  [ -f "$DIR/MidgardSurvivorsRT.pck" ] && base_pck="$DIR/MidgardSurvivorsRT.pck"
  mb=$(( $(stat -c %s "$base_pck" 2>/dev/null || echo 0) / 1048576 ))
  echo "GAME DIR      $DIR"
  echo "  base pack   ${base_pck##*/}  ${mb} MB"
  echo "USER DIR      ${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP"
  if [ -f "$STATE" ]; then
    local kind file lv
    echo "  state.json  $(tr -d '\t\n' < "$STATE")"
    echo "  ==> the game will run v${VER:-?}  (base pack alone is v$(layer_base_ver)); mount order:"
    while IFS=$'\t' read -r kind file lv; do
      printf '        %-7s %-34s (v%s)  %s
' "$kind" "$file" "$lv" \
        "$([ -f "$PATCHES/$file" ] && echo on disk || echo MISSING)"
    done < <(layer_manifest "$VER")
  else
    echo "  state.json  ABSENT -> patches not installed, the game runs stock $(layer_base_ver)"
  fi
  local verdict
  for f in "$PATCHES"/*.pck; do
    [ -e "$f" ] || { echo "  patch packs NONE"; continue; }
    sz=$(stat -c %s "$f")
    # humanised: the patch pack is now a 174 KB asset hotfix, "0 MB" would be meaningless
    if [ "$sz" -ge 1048576 ]; then hum="$((sz / 1048576)) MB"; else hum="$((sz / 1024)) KB"; fi
    h=$(sha256sum "$f" | cut -d' ' -f1)
    want="$(official_sha "${f##*/}")"
    if [ -z "$want" ]; then
      verdict="no-official-record"          # never ingested: cannot tell official from ours
    elif [ "$h" = "$want" ]; then verdict="official"; else verdict="MODIFIED_our_edit"; fi
    printf '  pack        %-34s %8s  %-18s %s...\n' "${f##*/}" "$hum" "$verdict" "${h:0:16}"
  done
  [ -f "$DIR/coop_preview.txt" ] && { hr; echo "  NOTE: coop_preview.txt next to the binary -> updater + patches DISABLED."; }
  if [ "$VERIFY" = 1 ]; then
    h=$(sha256sum "$base_pck" | cut -d' ' -f1)
    if [ "$h" = "$SHA_BASE" ]; then verdict="official, target untouched"; else verdict="CHANGED vs baseline"; fi
    hr; echo "  base pack   sha256 ${h:0:16}… -> $verdict"
  fi
  if [ -f "$MOD_PACK" ]; then
    hr; echo "  built mod pack ready: ${MOD_PACK#$WORK/}"
    echo "                  it is NOT mounted by itself: the game only reads $PATCHES"
  fi
  probe_summary
}

# --- runtime proof that the MODDED scripts really executed -----------------------------------
# Modded scripts write user://mod_probe_<name>.txt on the first relevant event (Enemy.setup spawns,
# first mechanics hit, first tower hazard) and print MODPROBE lines, which Godot also tees into
# user://logs/godot.log. Comparing their timestamps with the pack tells you whether a NEW build ran.
do_probe() {
  local u="${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP" f newest=0 stamp
  hr; echo "  probe files (written by the modded scripts from inside the game):"
  for f in "$u"/mod_probe_*.txt; do
    [ -e "$f" ] || continue
    stamp=$(date -r "$f" '+%Y-%m-%d %H:%M:%S')
    [ "$(stat -c %Y "$f")" -gt "$newest" ] && newest=$(stat -c %Y "$f")
    printf '  %s   at %s\n' "${f##*/}" "$stamp"
    sed 's/^/      /' "$f"
  done
  if [ -n "$(ls -A "$u"/logs 2>/dev/null)" ]; then
    grep -h MODPROBE "$u"/logs/*.log 2>/dev/null | tail -6 | sed 's/^/  log:  /'
  fi
  hr
  if [ "$newest" = 0 ]; then
    echo "  NO probe yet: the modded scripts have never run. Start the game with ./play.sh (no args)."
  else
    echo "  last mod activity: $(date -d "@$newest" '+%Y-%m-%d %H:%M:%S')"
    local newest_pack=0 p
    for p in "$PATCHES"/*.pck; do [ -e "$p" ] && [ "$(stat -c %Y "$p")" -gt "$newest_pack" ] && newest_pack=$(stat -c %Y "$p"); done
    if [ "$newest_pack" -gt "$newest" ]; then
      echo "  WARNING: the installed pack is NEWER than the last probe -> launch once to load the new build."
    else
      echo "  OK: the installed pack is older than the last probe, so what is installed is what is running."
    fi
  fi
}

probe_summary() {
  local u="${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP" f n=0
  for f in "$u"/mod_probe_*.txt; do [ -e "$f" ] && n=$((n + 1)); done
  hr
  if [ "$n" = 0 ]; then
    echo "  runtime proof: no mod probe file yet (the game has not run the modded scripts)"
  else
    echo "  runtime proof: $n probe file(s) in the user dir -> run ./play.sh --probe"
  fi
}

# --- run ------------------------------------------------------------------------------------
do_launch() {
  local exe env_prefix=()
  exe=$(cd "$DIR" && ls *.x86_64 2>/dev/null | head -1)
  [ -n "$exe" ] || { echo "play.sh: no .x86_64 binary in $DIR" >&2; exit 1; }
  if [ "$ISOLATE" = 1 ]; then
    local sandbox="$WORK/70_play_userdata/godot/app_userdata/$APP"
    if [ "$DRY" != 1 ]; then
      # rebuild the mount set from scratch: the updater deletes the pack it replaces, so a symlink left
      # over from an earlier isolated run would shadow the current layer with a version that no longer exists
      rm -rf "$sandbox/patches"; mkdir -p "$sandbox/patches"
      for f in "$PATCHES"/*.pck; do [ -e "$f" ] && ln -sfn "$f" "$sandbox/patches/${f##*/}"; done
      if [ -f "$MOD_PACK" ]; then
        ln -sfn "$MOD_PACK" "$sandbox/patches/$PACK"
        echo "play.sh: isolated run mounts the BUILT MOD pack instead of the official patch"
      fi
      [ -f "$STATE" ] && cp -f "$STATE" "$sandbox/state.json"
    fi
    env_prefix=(env "XDG_DATA_HOME=$WORK/70_play_userdata")
    hr
    echo "  ISOLATED user:// -> $WORK/70_play_userdata"
    echo "  your real profile.json is NOT used: progress starts from scratch, and"
    echo "  leaderboard / EOS sign-in may fall back to offline"
  fi
  if [ ${#USER_ARGS[@]} -gt 0 ]; then
    hr
    echo "  !! user args present -> Updater._enabled() = false -> PATCHES WILL NOT MOUNT:"
    echo "  !! you will be running stock 0.1.273 content, not $VER"
  fi
  hr; echo "  exec: ${env_prefix[*]:-} $DIR/$exe ${ENGINE_ARGS[*]:-} ${USER_ARGS[*]:+-- ${USER_ARGS[*]:-}}"
  if [ "$DRY" = 1 ]; then echo "  (--dry-run: nothing executed)"; exit 0; fi
  cd "$DIR" || exit 1
  if [ ${#env_prefix[@]} -gt 0 ]; then
    "${env_prefix[@]}" "./$exe" "${ENGINE_ARGS[@]}" ${USER_ARGS[@]:+-- "${USER_ARGS[@]}"}
  else
    "./$exe" "${ENGINE_ARGS[@]}" ${USER_ARGS[@]:+-- "${USER_ARGS[@]}"}
  fi
}

case "$MODE" in
  layer)  do_layer ;;
  status) do_status ;;
  probe)  do_probe ;;
  launch) do_launch ;;
esac
