#!/usr/bin/env python3
"""Extract the altar tables verbatim from the live build source into a standalone probe script.

game_data.gd cannot be load()ed on its own (it references the Save/World autoloads from const
expressions), so the odds probe in sim.gd needs ALTARS + MOD_ALTAR_W + MOD_KARMA_BALDUR in isolation.
Cut verbatim - never retyped - so the probe always measures the table the pack is built from.

    python3 mk_probe.py && godot --headless --path . -s res://sim.gd
"""
import io, os, sys

# which build layer to measure (default: the live one, see user://patches/state.json)
VER = sys.argv[1] if len(sys.argv) > 1 else "0.2.7"
SRC = os.path.join(os.path.dirname(__file__), "..", "..", "60_patches",
                    "effective_" + VER, "scripts", "autoload", "game_data.gd")
START, END = "const ALTARS: = {", "const MOD_KARMA_BALDUR"

src = io.open(SRC, encoding="utf-8").read()
a = src.index(START)
b = src.index("\n", src.index(END, a))
block = src[a:b]
if not block.rstrip().endswith("0.75"):
    sys.exit("probe source moved: block does not end at MOD_KARMA_BALDUR -> %r" % block[-60:])

out = os.path.join(os.path.dirname(__file__), "altars_data.gd")
with io.open(out, "w", encoding="utf-8") as fh:
    fh.write("# [PROBE] extracted verbatim from %s by mk_probe.py - do not edit\n" % os.path.relpath(SRC))
    fh.write("extends RefCounted\n" + block + "\n")
print("wrote %s (%d lines from %s)" % (out, block.count("\n") + 1, SRC))
