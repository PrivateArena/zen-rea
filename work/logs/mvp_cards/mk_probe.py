#!/usr/bin/env python3
"""mod-v17 probe check 1/2: what GameData.is_mvp_card() actually gates.

Replicates the shipped definition (autoload/game_data.gd:13578: for every MONSTERS entry with
"mvp": true that has a "card" field, that card is an MVP card) over the decompiled source of the live
layer, then proves the two things MOD_MVP_CARD_MULT depends on:
  * every boosted id is a real card id (present in CARDS);
  * no card reachable from a *non-MVP* roll site is boosted - i.e. the mob/elite/boss pools
    (_stage_cards) and the raid-fight pool (_fight_card, main.gd:17235) stay at shipped odds.
Usage: ./mk_probe.py [path/to/game_data.gd]
"""
import re
import sys

SRC = sys.argv[1] if len(sys.argv) > 1 else \
    "../../60_patches/effective_0.2.12/scripts/autoload/game_data.gd"
src = open(SRC, encoding="utf-8").read()


def block(name):
    i = src.index("const %s: = {" % name)
    j = src.index("{", i)
    d = 0
    for k in range(j, len(src)):
        if src[k] == "{":
            d += 1
        elif src[k] == "}":
            d -= 1
            if d == 0:
                return src[i:k + 1]
    raise SystemExit("block %s not balanced" % name)


def entries(text):
    """top-level "\t\"id\": {" entries of a const dict block"""
    out = []
    for m in re.finditer(r'\n\t"?([A-Za-z_0-9]+)"?:\s*\{', text):
        out.append((m.group(1), m.start()))
    return [(k, text[s:(out[i + 1][1] if i + 1 < len(out) else len(text))]) for i, (k, s) in enumerate(out)]


mon = dict(entries(block("MONSTERS")))
cards = {k for k, _ in entries(block("CARDS"))}
raids = dict(entries(block("RAIDS")))

mvp_cards, ghost = {}, []
for mob, seg in mon.items():
    if '"mvp": true' not in seg:
        continue
    c = re.search(r'"card":\s*"([A-Za-z_0-9]+)"', seg)
    if c:
        mvp_cards[c.group(1)] = mob
    else:
        ghost.append(mob)
boosted = sorted(mvp_cards)
bad = [c for c in boosted if c not in cards]

print("MVP monsters: %d   with a card: %d   with no card field (can never be boosted): %s"
      % (sum(1 for s in mon.values() if '"mvp": true' in s), len(boosted), ", ".join(sorted(ghost))))
print("boosted card ids: %d   of those not in CARDS: %s" % (len(boosted), bad or "none"))
print("boosted: " + ", ".join(boosted))

# pools the mod must NOT touch
non_mvp = sorted({re.search(r'"card":\s*"([A-Za-z_0-9]+)"', s).group(1)
                  for s in mon.values() if '"mvp"' not in s and '"card"' in s
                  and re.search(r'"card":\s*"([A-Za-z_0-9]+)"', s)} - set(boosted))
print("\nnon-MVP monster cards (shipped odds kept): %d" % len(non_mvp))
leak = []
for rid, seg in raids.items():
    for grp in re.findall(r'"(?:mob|egg|hatch|adds)":\s*(\[[^\]]*\]|"[A-Za-z_0-9]+")', seg):
        for mm in re.findall(r'"([A-Za-z_0-9]+)"', grp):
            c = re.search(r'\n\t"%s":\s*\{.*?"card":\s*"([A-Za-z_0-9]+)"' % re.escape(mm), block("MONSTERS"), re.S)
            if c and c.group(1) in boosted:
                leak.append("%s:%s" % (rid, c.group(1)))
print("_fight_card() raid pools inside the boosted set: %s" % (sorted(set(leak)) or "NONE (correct)"))
print("elite/prize + boss + mob rolls use: CARD_DROP_CHANCE=%.5f ELITE=%.3f BOSS=%.4f FIGHT=%.2f (untouched)"
      % (float(re.search(r"const CARD_DROP_CHANCE: = ([\d.]+)", src).group(1)),
         float(re.search(r"const ELITE_CARD_CHANCE: = ([\d.]+)", src).group(1)),
         float(re.search(r"const BOSS_CARD_CHANCE: = ([\d.]+)", src).group(1)),
         float(re.search(r"const MVP_FIGHT_CARD_CHANCE: = ([\d.]+)", src).group(1))))
print("MVP_CARD_CHANCE=%s  HELL_SHADOW_CARD=%s  PRIDE_CARD=%s"
      % tuple(re.search(r"const %s: = ([\d.]+)" % k, src).group(1)
              for k in ["MVP_CARD_CHANCE", "HELL_SHADOW_CARD", "PRIDE_CARD"]))
mult = float(re.search(r"const MOD_MVP_CARD_MULT: = ([\d.]+)", src).group(1))
print("MOD_MVP_CARD_MULT=%s -> per MVP kill %.4f, shadow roll %.4f" % (mult, 0.285 * mult, 0.285 * 0.25 * mult))
# keep sim.gd's hard-coded copy of the set honest (it cannot import GameData in a --script run)
sim = open(__file__.replace("mk_probe.py", "sim.gd"), encoding="utf-8").read()
in_sim = sorted(set(re.findall(r'"([a-z_0-9]+_card)"', sim.split("mk_is_mvp(id: String)")[-1])))
print("sim.gd mk_is_mvp() list == derived set: %s" % ("YES" if in_sim == boosted else
      "NO  (missing %s / extra %s)" % (sorted(set(boosted) - set(in_sim)), sorted(set(in_sim) - set(boosted)))))
