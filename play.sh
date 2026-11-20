#!/usr/bin/env bash
# play.sh — launch Midgard Survivors WITH the live patch layer mounted, and report which
#           version you are actually about to play.
#
# Why this script exists (verified — full findings in work/60_patches/PATCH_SYSTEM.md):
#   * The retail pack (0.1.273) is only the BASE layer. At startup the game mounts, in this order:
#         MidgardSurvivors.pck  <-  user://patches/bridge_0.1.273_to_0.2.0.pck
#                               <-  user://patches/patch_<ver>.pck   (currently patch_0.2.4.pck)
#     and the LAST mounted pack wins, so the content you play is the newest patch.
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

# Which patch pack is current? The updater rewrites state.json and DELETES the pack it replaces, so
# never hardcode this: read it from the game's own state, else take the newest patch_*.pck on disk.
VER=""
if [ -f "$STATE" ]; then
  VER=$(sed -n 's/."version": *"\([0-9][0-9.]*\)".*/\1/p' "$STATE" | tail -1)
fi
[ -n "$VER" ] || VER=$(ls -1t "$PATCHES"/patch_*.pck 2>/dev/null | head -1 | sed 's/.*patch_\(.*\)\.pck/\1/')
PACK="patch_${VER:-0.0.0}.pck"
LIVE="$PATCHES/$PACK"
MOD_PACK="$WORK/60_patches/out/$PACK"   # output of the mod build step, when it exists

# sha256 of the pristine developer packs. NOTE: the updater wiped patches2/ (an unknown directory in
# user://) on the 0.2.4 update, so the ONLY pristine copies are work/60_patches/orig/*.pck - those are
# what the verdict below is compared against, per pack. SHA_PATCH is the 0.2.3 fallback only.
SHA_BASE="a8d0b35b1434571d3c2cea23c9a697a6ea032300ba47d1479f7f3b640328a8b6"
SHA_BRIDGE="b0266960e901362fe6fcc5766fb45655c3f00a44f329a2e8b999da3ec507f028"
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
    -h|--help)    sed -n '3,27p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "play.sh: unknown option '$1' (try --help)" >&2; exit 2 ;;
  esac
done

hr() { printf '%s\n' "--------------------------------------------------------------------------"; }

# sha256 of the pristine copy we keep outside user:// (orig/), else the recorded 0.2.3 sha
pristine_sha() {
  local p="$WORK/60_patches/orig/$1"
  if [ -f "$p" ]; then sha256sum "$p" | cut -d' ' -f1; else echo "$SHA_PATCH"; fi
}

# --- which pack owns a given res:// member --------------------------------------------------
do_layer() {
  local spec tag f hit=0
  for spec in "BASE:$LISTINGS/pck-files.txt" \
              "BRIDGE:$LISTINGS/bridge-0.2.0-files.txt" \
              "PATCH:$LISTINGS/patch-${VER}-files.txt"; do
    tag="${spec%%:*}"; f="${spec#*:}"
    if [ ! -f "$f" ]; then
      echo "  (no member listing for $tag — regenerate: gdre_tools --list-files=<pack> > $f)"
      continue
    fi
    grep -F -- "$LAYER" "$f" | sed "s|^|  $tag  |" && hit=1
  done
  [ "$hit" = 1 ] || { echo "  '$LAYER' matches no member of any pack"; return 1; }
  hr; echo "  winner = last layer listed (patch > bridge > base). Edit THAT one, or put your file there."
}

# --- what is installed ----------------------------------------------------------------------
do_status() {
  local f h want mb base_pck="$DIR/MidgardSurvivors.pck"
  [ -f "$DIR/MidgardSurvivorsRT.pck" ] && base_pck="$DIR/MidgardSurvivorsRT.pck"
  mb=$(( $(stat -c %s "$base_pck" 2>/dev/null || echo 0) / 1048576 ))
  echo "GAME DIR      $DIR"
  echo "  base pack   ${base_pck##*/}  ${mb} MB"
  echo "USER DIR      ${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP"
  if [ -f "$STATE" ]; then
    local v b
    v=$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$STATE" | tail -1)
    b=$(sed -n 's/.*"base": *"\([^"]*\)".*/\1/p' "$STATE")
    echo "  state.json  $(tr -d '\t\n' < "$STATE")"
    echo "  ==> the game will run v$v   (base pack alone is v$b)"
  else
    echo "  state.json  ABSENT -> patches not installed, the game runs stock 0.1.273"
  fi
  local verdict
  for f in "$PATCHES"/*.pck; do
    [ -e "$f" ] || { echo "  patch packs NONE"; continue; }
    mb=$(( $(stat -c %s "$f") / 1048576 ))
    h=$(sha256sum "$f" | cut -d' ' -f1)
    case "${f##*/}" in
      bridge_*) want="$SHA_BRIDGE" ;;
      *)        want="$(pristine_sha "${f##*/}")" ;;
    esac
    if [ "$h" = "$want" ]; then verdict="official"; else verdict="MODIFIED_our_edit"; fi
    printf '  pack        %-34s %5d MB  %-18s %s...\n' "${f##*/}" "$mb" "$verdict" "${h:0:16}"
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
      mkdir -p "$sandbox/patches"
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
