# layer_env.sh — shared environment for the patch-layer tools. SOURCED, never run.
#
# Everything the official-update pipeline needs to know about *this* project lives here so that
# `layer_sync.sh`, `layer_diff.sh`, `mod_apply.sh`, `update.sh` and build.sh agree on it:
# where the game's live patch layer is, which version is current, where the pristine copies and the
# git baselines live, and which bytecode token the packs use.
#
# Conventions verified in PATCH_SYSTEM.md §3/§10/§19 — read those before changing anything here.

W="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"          # work/60_patches
ROOT="$(cd "$W/../.." && pwd)"                            # repo root
WORK="$ROOT/work"
LISTINGS="$WORK/logs"
ORIG="$W/orig"                                            # the ONLY pristine packs (PATCH_SYSTEM.md §14)
OUT="$W/out"
MODPATCH="$W/mod-latest.patch"
GDRE="${RE_BIN:-/media/jang/home/PortableApp/re/bin}/gdre_tools"
BYTECODE="${BYTECODE:-4.5.0-stable}"                      # == bytecode revision 101, see layer_rev
APP="Midgard Survivors"
PATCHES="${XDG_DATA_HOME:-$HOME/.local/share}/godot/app_userdata/$APP/patches"
STATE="$PATCHES/state.json"
BASE_LAYER="$WORK/25_scripts"                             # decompiled retail pack (0.1.273)
BRIDGE_LAYER="$W/scripts_full_0.2.0"                      # decompiled bridge
GDPC_MAGIC='GDPC'
GDEC_MAGIC='GDEC'                                         # encrypted download, needs one game mount first

die() { echo "layer: $*" >&2; exit 1; }
sha256() { sha256sum "$1" | cut -d' ' -f1; }

# layer_ver — the version the game will actually run: state.json is authoritative (the updater rewrites
# it and deletes the pack it replaces), newest patch_*.pck on disk is the fallback.
layer_ver() {
  local v=""
  [ -f "$STATE" ] && v=$(sed -n 's/."version": *"\([0-9][0-9.]*\)".*/\1/p' "$STATE" | tail -1)
  [ -n "$v" ] || v=$(ls -1t "$PATCHES"/patch_*.pck 2>/dev/null | head -1 | sed 's/.*patch_\(.*\)\.pck/\1/')
  [ -n "$v" ] || die "cannot read a version from $STATE (and no patch_*.pck in $PATCHES)"
  echo "$v"
}

# layer_tags — every recorded baseline, oldest first (git tags are the pristine decompiles).
layer_tags() {
  git -C "$ROOT" tag -l 'v*-decompiled' | sed 's/^v\(.*\)-decompiled$/\1/' | sort -V
}

# layer_prev VER — the baseline immediately before VER, or empty if VER is the first.
layer_prev() {
  layer_tags | awk -v v="$1" 'p != "" && $0 == v { print p } { p = $0 }'
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
