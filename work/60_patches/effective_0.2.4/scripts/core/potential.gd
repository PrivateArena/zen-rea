extends RefCounted









const LINES: = 3


static func has(it) -> bool:
	return it is Dictionary and (it as Dictionary).get("pot") is Dictionary and not (it.pot.get("lines", []) as Array).is_empty()



static func tier(it) -> int:
	return clampi(int(it.pot.get("tier", 1)), 1, GameData.POTENTIAL_TIERS.size()) if has(it) else 0


static func lines(it) -> Array:
	if not has(it):
		return []


	return (it.pot.lines as Array).filter( func(l): return l is Dictionary and GameData.POTENTIAL_LINES.has(str(l.get("k", "")))).slice(0, LINES)




static func clean(p) -> Dictionary:
	if not p is Dictionary:
		return {}
	var top: = GameData.POTENTIAL_TIERS.size()
	var out: = []
	for l in (p.get("lines", []) as Array if p.get("lines") is Array else []):
		if out.size() >= LINES:
			break
		if l is Dictionary and GameData.POTENTIAL_LINES.has(str(l.get("k", ""))):
			var line: = {"k": str(l.k), "t": clampi(int(l.get("t", 1)), 1, top)}
			if bool(l.get("p", false)):
				line["p"] = true
			out.append(line)
	if out.is_empty():
		return {}
	return {"tier": clampi(int(p.get("tier", 1)), 1, top), "lines": out}



static func edited(p) -> bool:
	if not p is Dictionary:
		return false
	var ls = p.get("lines", [])
	if not ls is Array or (ls as Array).size() > LINES:
		return true
	return int(p.get("tier", 1)) > GameData.POTENTIAL_TIERS.size()




static func value(k: String, t: int, perfect: = false) -> float:
	var vals: Array = GameData.POTENTIAL_LINES[k].vals
	var i: = clampi(t, 1, GameData.POTENTIAL_TIERS.size()) - 1
	if i >= GameData.POTENTIAL_TIERS.size() - 1 and perfect:
		i += 1
	return float(vals[mini(i, vals.size() - 1)])



static func is_perfect(l: Dictionary) -> bool:
	return int(l.get("t", 0)) >= GameData.POTENTIAL_TIERS.size() and bool(l.get("p", false))


static func line_value(l: Dictionary) -> float:
	return value(str(l.k), int(l.t), is_perfect(l))



static func mods(it) -> Dictionary:
	var out: = {}
	for l in lines(it):
		var d: Dictionary = GameData.POTENTIAL_LINES[str(l.k)]
		if d.has("mod"):
			out[str(d.mod)] = float(out.get(str(d.mod), 0.0)) + line_value(l)
	return out



static func fx(it) -> Dictionary:
	var out: = {}
	for l in lines(it):
		var d: Dictionary = GameData.POTENTIAL_LINES[str(l.k)]
		for e in d.get("fx", []):
			out[str(e)] = float(out.get(str(e), 0.0)) + line_value(l)
	return out



static func line_text(l: Dictionary) -> String:
	var d: Dictionary = GameData.POTENTIAL_LINES[str(l.k)]
	return TranslationServer.translate(str(d.text)) % str(roundi(line_value(l) * 100.0))


static func tier_name(t: int) -> String:
	return TranslationServer.translate(str(GameData.POTENTIAL_TIERS[clampi(t, 1, GameData.POTENTIAL_TIERS.size()) - 1].name))


static func tier_color(t: int) -> Color:
	return GameData.POTENTIAL_TIERS[clampi(t, 1, GameData.POTENTIAL_TIERS.size()) - 1].color



static func cost(locked: int) -> int:
	return 1 + GameData.POTENTIAL_LOCK_COST * locked







static func roll(it: Dictionary, locked: Array) -> bool:

	if Equipment.is_soul(it):
		return false
	var old: = lines(it)
	var t: = tier(it)
	var up: = false
	if t == 0:
		t = 1
	elif t < GameData.POTENTIAL_TIERS.size() and randf() < float(GameData.POTENTIAL_UP[t - 1]):
		t += 1
		up = true
	var keys: Array = GameData.POTENTIAL_LINES.keys()
	var out: = []
	for i in LINES:
		if locked.has(i) and i < old.size():
			out.append((old[i] as Dictionary).duplicate())
			continue
		var lt: = t if i == 0 or randf() < GameData.POTENTIAL_SAME else maxi(1, t - 1)
		var line: = {"k": str(keys.pick_random()), "t": lt}

		if lt >= GameData.POTENTIAL_TIERS.size():
			line["p"] = randf() < GameData.POTENTIAL_PERFECT
		out.append(line)
	it["pot"] = {"tier": t, "lines": out}

	Save.bump("pot_rolls")
	for i in out.size():
		if locked.has(i):
			continue
		if int(out[i].t) >= GameData.POTENTIAL_TIERS.size():
			Save.bump("pot_legend")
			if bool(out[i].get("p", false)):
				Save.bump("pot_perfect")
	return up




static func is_semi(l: Dictionary) -> bool:
	return int(l.get("t", 0)) >= GameData.POTENTIAL_TIERS.size() and not bool(l.get("p", false))




static func tear(it: Dictionary, i: int) -> bool:
	var ls: = lines(it)
	if i < 0 or i >= ls.size() or not is_semi(ls[i]):
		return false

	(ls[i] as Dictionary)["p"] = true
	return true
