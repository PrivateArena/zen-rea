extends SceneTree

# Replays the roll loop of core/altars.gd spawn() (lines 240-252, verbatim structure) over the real
# ALTARS/MOD_ALTAR_W consts extracted by mk_probe.py: once with stock weights ({} override -> w
# default 1.0, yggdrasil 0.3) and once with the mod weights. 200k picks each.

func roll(ids, altars, w, n):
	var hits := {}
	for i in n:
		var total := 0.0
		for id in ids:
			total += float(w.get(id, altars[id].get("w", 1.0)))
		var r := randf() * total
		var pick := ""
		for id in ids:
			r -= float(w.get(id, altars[id].get("w", 1.0)))
			if r <= 0.0:
				pick = id
				break
		if pick == "":
			pick = ids[0]
		hits[pick] = int(hits.get(pick, 0)) + 1
	return hits


func _init():
	randomize()
	var d = load("res://altars_data.gd").new()
	var altars: Dictionary = d.ALTARS
	var ids: Array = altars.keys().filter(func(id): return not altars[id].has("npc") and not altars[id].has("karma"))
	print("rollable pool (no npc/karma ids): ", ids)
	var N := 200000
	var before = roll(ids, altars, {}, N)
	var after = roll(ids, altars, d.MOD_ALTAR_W, N)
	print("")
	print("%-10s %7s %7s %7s  %s" % ["altar", "stock%", "mod%", "ratio", "shipped bad side"])
	for id in ids:
		var b: float = 100.0 * int(before.get(id, 0)) / N
		var a: float = 100.0 * int(after.get(id, 0)) / N
		print("%-10s %6.2f  %6.2f  %6.2f  %s" % [id, b, a, a / maxf(b, 0.0001), altars[id].bad])
	var good := ["odin", "thor", "loki", "yggdrasil"]
	var good5 := ["odin", "thor", "loki", "yggdrasil", "emperium"]
	for pair in [[before, "stock"], [after, "mod  "]]:
		var s := 0
		for g in good:
			s += int(pair[0].get(g, 0))
		var s5 := 0
		for g in good5:
			s5 += int(pair[0].get(g, 0))
		# emperium counts as "useful" from mod v15 on: its payout is a 3-roll bonus-2 MVP Treasure Box + 1
		# level per hero (altars.gd:796-803), so it is grouped with the reward altars, not the pure-debuff ones.
		print("%s reward-pool share: %6.2f %% (4 altars)   %6.2f %% (5, incl. emperium)" % [pair[1], 100.0 * s / N, 100.0 * s5 / N])
	var baldur := 0
	for i in N:
		if randf() < d.MOD_KARMA_BALDUR:
			baldur += 1
	print("karma altar (one every 150-210 s from t=90): baldur %5.2f %%  hel %5.2f %%  (stock 50/50)" % [100.0 * baldur / N, 100.0 * (N - baldur) / N])
	quit()
