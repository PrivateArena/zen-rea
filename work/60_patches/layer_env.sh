# layer_env.sh — shared environment for the patch-layer tools. SOURCED, never run.
#
# Everything the official-update pipeline needs to know about *this* project lives here so that
# `layer_sync.sh`, `layer_diff.sh`, `mod_apply.sh`, `update.sh` and build.sh agree on it:
# where the game's live patch layer is, which version is current, where the pristine copies and the
# git baselines live, and which bytecode token the packs use.
#
# Conventions verified in PATCH_SYSTEM.md §3/§10/§19/§21 — read those before changing anything here.
#
# LAYER MODEL (as of 0.2.12, §21): the game mounts  base pack  <-  bridge_<base>_to_<bridgeVer>.pck  <-
# patch_<ver>.pck. The bridge is a *full* delta from the retail base and carries nearly every script;
# the patch pack is a small hotfix delta on top of it and may contain no scripts at all. So neither
# "the patch pack" nor "the newest bridge on disk" alone identifies a build: `layer_manifest` is the
# only correct answer, and it is read from state.json, which is what the game itself reads.

W="${LAYER_W:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"   # work/60_patches (LAYER_W: sourced from repo root)
ROOT="$(cd "$W/../.." && pwd)"                            # repo root
WORK="$ROOT/work"
LISTINGS="$WORK/logs"
ORIG="$W/orig"                                            # the ONLY pristine packs (PATCH_SYSTEM.md §14)
OUT="$W/out"
MODPATCH="$W/mod-latest.patch"
GDRE="${RE_BIN:-/media/jang/home/PortableApp/re/bin}/gdre_tools"
BYTECODE="${BYTECODE:-4.5.0-stable}"                      # == bytecode revision 101, see layer_rev
KEEP_MAX="${KEEP_MAX:-67108864}"                          # orig/ only stores packs we could rebuild from:
#  a 228 MB bridge is not worth 228 MB of our last 6 GB — its durable artifact is the tagged decompile.
APP="Midgard Survivors"
PATCHES="${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP/patches"
STATE="$PATCHES/state.json"
BASE_LAYER="$WORK/25_scripts"                             # decompiled retail pack (0.1.273)
BRIDGE_LAYER="$W/scripts_full_0.2.0"                      # decompiled bridge
GDPC_MAGIC='GDPC'
GDEC_MAGIC='GDEC'                                         # encrypted download, needs one game mount first

die() { echo "layer: $*" >&2; exit 1; }
sha256() { sha256sum "$1" | cut -d' ' -f1; }

# layer_state KEY — one value out of state.json, KEY may be dotted (version, file, base, bridge.file,
# bridge.version). jq when present, a line-oriented awk walker otherwise (state.json is flat, 2 levels).
# NOTE: the naive `sed ... | tail -1` this replaces used to pick the LAST "version" line, which happens to
# be the top-level one today — the file also contains bridge.version. Never rely on key order again.
layer_state() {
  local key="$1" v=""
  [ -f "$STATE" ] || return 0
  if command -v jq >/dev/null 2>&1; then
    v=$(jq -r "getpath(\"$key\" | split(\".\")) // \"\" | tostring" "$STATE" 2>/dev/null)
  else
    v=$(awk -v key="$key" '
      { line = $0; sub(/,[ \t]*$/, "", line)
        if (line ~ /\{[ \t]*$/) {                       # "name": {
          if (match(line, /"[^"]+"[ \t]*:[ \t]*\{/)) {
            n = substr(line, RSTART, RLENGTH); gsub(/["{ :]/, "", n); path[++depth] = n }
          next }
        if (line ~ /^[ \t]*\}/) { if (depth > 0) depth--; next }
        if (match(line, /"[^"]+"[ \t]*:[ 	]*"[^"]*"/)) {
          kv = substr(line, RSTART, RLENGTH)
          k = kv; sub(/:.*/, "", k); gsub(/[" \t]/, "", k)
          val = kv; sub(/^[^"]*"[^"]*"/, "", val); gsub(/[" \t:]/, "", val)
          p = ""; for (i = 1; i <= depth; i++) p = p path[i] "."
          p = p k
          if (p == key) { print val; exit } } }' "$STATE" 2>/dev/null)
  fi
  echo "$v"
}

# layer_ver — the version the game will actually run: state.json is authoritative (the updater rewrites
# it and deletes the pack it replaces), newest patch_*.pck on disk is the fallback.
layer_ver() {
  local v=""
  v=$(layer_state version)
  case "$v" in ''|null|"0.1.273") v="" ;; esac
  [ -n "$v" ] || v=$(ls -1t "$PATCHES"/patch_*.pck 2>/dev/null | head -1 | sed 's/.*patch_\(.*\)\.pck/\1/')
  [ -n "$v" ] || die "cannot read a version from $STATE (and no patch_*.pck in $PATCHES)"
  echo "$v"
}

# layer_pack VER — the patch pack file name for VER (state.json when VER is the live version).
layer_pack() {
  local v="$1" f=""
  [ "$v" = "$(layer_ver 2>/dev/null)" ] && f=$(layer_state file)
  case "$f" in *.pck) echo "$f"; return ;; esac
  echo "patch_$v.pck"
}

# layer_base_ver — the retail base the bridge bridges FROM (state.json `base`, else the recorded 0.1.273).
layer_base_ver() {
  local b; b=$(layer_state base)
  case "$b" in ''|null) b=0.1.273 ;; esac
  echo "$b"
}

# layer_manifest_file VER — the snapshot of a version's mount set, written by layer_sync.sh at ingest.
layer_manifest_file() { echo "$LISTINGS/layer-manifest-$1.tsv"; }

# layer_bridge_le VER — "file<TAB>version" of the newest bridge pack known to us that is not newer than
# VER (live user://patches, then orig/, then the recorded listings). Used when state.json has no bridge
# key, or when a historical version is re-read after its state.json was replaced.
layer_bridge_le() {
  local ver="$1" c f v bf="" bv=""
  for c in "$PATCHES"/bridge_*.pck "$ORIG"/bridge_*.pck; do
    [ -e "$c" ] || continue
    f="${c##*/}"; v="${f#bridge_*_to_}"; v="${v%.pck}"
    vcmp "$v" "$ver" && continue                       # newer than VER: belongs to a later build
    if [ -z "$bv" ] || vcmp "$v" "$bv"; then bv="$v"; bf="$f"; fi
  done
  if [ -z "$bf" ]; then
    for c in $(ls -1 "$LISTINGS"/bridge-*-files.txt 2>/dev/null | sort -V); do
      f="${c##*/}"; v="${f#bridge-}"; v="${v%-files.txt}"
      vcmp "$v" "$ver" && continue
      bv="$v"; bf="bridge_$(layer_base_ver)_to_$v.pck"   # name reconstructed: the bytes are gone anyway
    done
  fi
  [ -n "$bf" ] && printf '%s\t%s\n' "$bf" "$bv"
  return 0
}

# layer_manifest [VER] — "kind<TAB>file<TAB>version" for every pack the game mounts, in MOUNT ORDER
# (bridge first, patch last — last mount wins, PATCH_SYSTEM.md §5). Base is not a pack here; it is the
# retail .pck the game installs. The LIVE version's manifest comes from state.json (authoritative);
# an older version's comes from the snapshot layer_sync.sh wrote when it was ingested.
layer_manifest() {
  local ver="${1:-$(layer_ver)}" brfile="" brver="" pfile="" pver="" mf=""
  if [ "$ver" != "$(layer_ver 2>/dev/null)" ]; then
    mf=$(layer_manifest_file "$ver")
    [ -s "$mf" ] && { cat "$mf"; return; }
    pfile="patch_$ver.pck"; pver="$ver"
  else
    brfile=$(layer_state bridge.file); brver=$(layer_state bridge.version)
    pfile=$(layer_state file);          pver=$(layer_state version)
    [ -n "$pver" ] || pver="$ver"
    case "$pfile" in *.pck) : ;; *) pfile="patch_$pver.pck" ;; esac
  fi
  if [ -z "$brfile" ] || [ -z "$brver" ]; then
    IFS=$'\t' read -r brfile brver < <(layer_bridge_le "$ver" | head -1)
  fi
  [ -n "$brfile" ] && printf 'bridge\t%s\t%s\n' "$brfile" "$brver"
  printf 'patch\t%s\t%s\n' "$pfile" "$pver"
}

# layer_raw_dir KIND VER [PATCHVER] / layer_src_dir KIND VER [PATCHVER] — where a layer's extracted .gdc
# and decompiled .gd live. Patch layers keep the historical scripts_full_<ver> name. A bridge gets
# scripts_bridge_<ver>, and falls back to scripts_full_<ver> only for the pre-0.2.12 layout (the 0.2.0
# bridge, whose scripts_full_ dir is already on disk). PATCHVER matters for the new layout: if the bridge
# and the patch pack ever carry the SAME version, scripts_full_<ver> belongs to the patch, never the bridge.
layer_raw_dir() {
  if [ "$1" = bridge ]; then
    [ -d "$W/raw_bridge_$2" ] && { echo "$W/raw_bridge_$2"; return; }
    [ -n "$3" ] && [ "$2" = "$3" ] && { echo "$W/raw_bridge_$2"; return; }
    [ -d "$W/raw_$2" ] && { echo "$W/raw_$2"; return; }
    echo "$W/raw_bridge_$2"; return
  fi
  echo "$W/raw_$2"
}
layer_src_dir() {
  if [ "$1" = bridge ]; then
    [ -d "$W/scripts_bridge_$2" ] && { echo "$W/scripts_bridge_$2"; return; }
    [ -n "$3" ] && [ "$2" = "$3" ] && { echo "$W/scripts_bridge_$2"; return; }
    [ -d "$W/scripts_full_$2" ] && { echo "$W/scripts_full_$2"; return; }
    echo "$W/scripts_bridge_$2"; return
  fi
  echo "$W/scripts_full_$2"
}

# layer_listing KIND VER — the member listing file for one pack (what play.sh --layer reads).
layer_listing() { echo "$LISTINGS/$1-$2-files.txt"; }

# layer_listings VER — the member listings of every pack of a version, in mount order (may be fewer
# than the manifest if a listing was never taken).
layer_listings() {
  local kind file v f
  while IFS=$'\t' read -r kind file v; do
    f=$(layer_listing "$kind" "$v")
    [ -s "$f" ] && echo "$f"
  done < <(layer_manifest "$1")
  return 0
}

# layer_tags — every recorded baseline, oldest first (git tags are the pristine decompiles).
layer_tags() {
  git -C "$ROOT" tag -l 'v*-decompiled' | sed 's/^v\(.*\)-decompiled$/\1/' | sort -V
}

# layer_prev VER — the baseline immediately before VER (VER itself need not be tagged yet — that is the
# normal case when it is being ingested), or empty if VER is the first.
layer_prev() {
  local v="$1" p="" t
  while IFS= read -r t; do
    [ "$t" = "$v" ] && break           # not its own predecessor
    vcmp "$t" "$v" && break            # a tag newer than VER: stop, it is not our predecessor
    p="$t"
  done < <(layer_tags)
  echo "$p"
}

# layer_tree VER — the source tree of a version (the thing we edit and build).
layer_tree() { echo "$W/effective_$1"; }

# layer_tagpath VER — the tree's path inside the repo, for git plumbing.
layer_tagpath() { echo "work/60_patches/effective_$1"; }

# layer_rev FILE.gdc — bytecode revision straight off a GDSC header (bytes 5-8, little-endian).
layer_rev() {
  local f="$1"
  [ -f "$f" ] || die "layer_rev: no such file $f"
  head -c 8 "$f" | od -An -tu1 | awk '{ printf "%d\n", $5 + $6*256 + $7*65536 + $8*16777216 }'
}

# layer_magic FILE — first 4 bytes of a file, to tell GDPC from GDEC before we hand anything to GDRE.
layer_magic() { head -c 4 "$1" 2>/dev/null | tr -d '\0'; }

# layer_ck MSG — step banner.
layer_ck() { printf '\n== %s\n' "$*"; }

# layer_need — refuse to run half-way when the tooling is missing.
layer_need() {
  [ -x "$GDRE" ] || die "gdre_tools not found at $GDRE (. /media/jang/home/PortableApp/re/activate.sh)"
  git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1 || die "$ROOT is not a git repository"
}

# vcmp A B — echo 1 when version A sorts after B (state.json mixes 3-part and 4-part versions).
vcmp() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ] && [ "$1" != "$2" ] ;}
