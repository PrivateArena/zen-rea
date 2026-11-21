class_name AutoPick
extends RefCounted













static var log_picks: bool = OS.get_cmdline_user_args().has("--autopick-log")









static func shown_level(id: String, lv: int) -> int:
	return lv + 9 if GameData.SKILLS.has(id) and GameData.SKILLS[id].get("evolved", false) else lv


static func choose(choices: Array, order: Array = [], limits: Dictionary = {}, fill: = false) -> Dictionary:
	if choices.is_empty():
		return {}
	if not limits.is_empty():
		var under: = choices.filter( func(c):
			if not str(c.get("kind", "")) in ["skill", "stat"]:
				return true
			var lim: = int(limits.get(Player.base_skill(str(c.get("id", ""))), 0))


			var learn: bool = str(c.get("kind", "")) == "skill" and int(c.get("from", int(c.get("level", 0)) - 1)) == 0
			return lim <= 0 or learn or shown_level(str(c.get("id", "")), int(c.get("level", 0))) <= lim)
		if not under.is_empty():
			choices = under
	if fill:


		for want in [ func(c): return str(c.get("kind", "")) == "skill" and int(c.get("from", int(c.get("level", 0)) - 1)) == 0, 
				func(c): return str(c.get("kind", "")) == "evolve"]:
			var some: = choices.filter(want)
			if not some.is_empty():
				return _best(some, order)
	return _best(choices, order)




static func _best(choices: Array, order: Array) -> Dictionary:
	var best: = {}
	var at: = order.size()
	var tier: = -1
	for c in choices:
		var i: = order.find(Player.base_skill(str(c.get("id", "")))) if str(c.get("kind", "")) in ["skill", "evolve", "stat"] else -1
		if i < 0:
			continue
		var r: = _tier(c)
		if r > tier or (r == tier and i < at):
			tier = r
			at = i
			best = c
	if not best.is_empty():
		return best
	var top: = 0
	for c in choices:
		top = maxi(top, _tier(c))
	return choices.filter( func(c): return _tier(c) == top).pick_random()







static func _tier(c: Dictionary) -> int:
	if str(c.get("kind", "")) == "evolve":
		return GameData.CHOICE_RARITY.size()
	return int(c.get("rarity", 0))









static func cap_bans(p: Player, limits: Dictionary, bans: Array, picked: Dictionary = {}) -> Array:
	var out: = []
	if bans.is_empty() or limits.is_empty() or p.banishes <= 0:
		return out
	var levels: = {}
	for id in p.skills:
		levels["skill:" + str(id)] = int(p.skills[id].level)
	for id in p.stats:
		levels["stat:" + str(id)] = int(p.stats[id])
	if str(picked.get("kind", "")) in ["skill", "stat"]:
		var key: = "%s:%s" % [picked.kind, picked.id]
		levels[key] = maxi(int(levels.get(key, 0)), int(picked.get("level", 0)))
	for key in levels:
		if out.size() >= p.banishes:
			break
		var id: = Player.base_skill(str(key).get_slice(":", 1))
		var lim: = int(limits.get(id, 0))
		if lim > 0 and bans.has(id) and not p.banished.has(key) and shown_level(str(key).get_slice(":", 1), int(levels[key])) >= lim:
			out.append(key)
	return out
