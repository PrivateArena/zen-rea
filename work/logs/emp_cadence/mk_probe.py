#!/usr/bin/env python3
"""Extract the tower-event constants verbatim from the live build source into a standalone probe.

sim.gd replays the tower's event FLOOR GATE (core/tower_run.gd _start_floor) + the weighted pick
(core/tower_events.gd _event_pick / pick / emp_due / pick_for) outside the game, so it needs the real
numbers instead of a transcription: TOWER_EVENT_AT / _FROM, TOWER_TIER_FLOORS, the TOWER_EVENTS key
order, MOD_EVENT_W and MOD_EMP_EVERY. Cut verbatim - never retyped - so the probe always measures the
table the pack is built from.

    python3 mk_probe.py && godot --headless --path . -s res://sim.gd
"""
import io, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
W = os.path.abspath(os.path.join(HERE, "..", "..", "60_patches"))
VER = sys.argv[1] if len(sys.argv) > 1 else None
if VER is None:
    # live layer, from user://patches/state.json via layer_env.sh's rule (newest effective_*)
    cands = sorted(d for d in os.listdir(W) if d.startswith("effective_"))
    if not cands:
        sys.exit("no effective_<ver> tree under %s" % W)
    VER = cands[-1].split("_", 1)[1]
SRC = os.path.join(W, "effective_" + VER, "scripts")
GD = os.path.join(SRC, "autoload", "game_data.gd")
TE = os.path.join(SRC, "core", "tower_events.gd")

gd = io.open(GD, encoding="utf-8").read()
te = io.open(TE, encoding="utf-8").read()

out = ["# [PROBE] extracted verbatim from effective_%s by mk_probe.py - do not edit" % VER,
       "extends RefCounted"]

for pat, src, label in [
    (r"^const TOWER_EVENT_AT: = (\d+)", gd, "TOWER_EVENT_AT"),
    (r"^const TOWER_EVENT_FROM: = (\d+)", gd, "TOWER_EVENT_FROM"),
    (r"^const TOWER_TIER_FLOORS: = (\d+)", gd, "TOWER_TIER_FLOORS"),
    (r"^const TOWER_FLOORS: = (\d+)", gd, "TOWER_FLOORS"),
    (r"^const MOD_EVENT_W: = (\{.*\})", te, "MOD_EVENT_W"),
    (r"^const MOD_EMP_EVERY: = ([\d.]+)", te, "MOD_EMP_EVERY"),
]:
    m = re.search(pat, src, re.M)
    if not m:
        sys.exit("probe source moved: cannot find %s" % label)
    out.append("const %s: = %s" % (label, m.group(1)))

keys = re.search(r"^const TOWER_EVENTS: = \{(.*?)^\}", gd, re.M | re.S)
if not keys:
    sys.exit("probe source moved: cannot find TOWER_EVENTS")
ids = re.findall(r'^\t"([a-z_]+)":', keys.group(1), re.M)
out.append('const TOWER_EVENT_KEYS: = [%s]' % ", ".join('"%s"' % k for k in ids))

dst = os.path.join(HERE, "consts.gd")
io.open(dst, "w", encoding="utf-8").write("\n".join(out) + "\n")
print("wrote %s (%d consts, kinds=%s) from effective_%s"
      % (dst, len(out) - 2, ids, VER))
