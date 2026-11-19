class_name AutoPick
extends RefCounted












static func choose(choices: Array, order: Array = [], limits: Dictionary = {}) -> Dictionary:
	if choices.is_empty():
		return {}
	if not limits.is_empty():
		var under: = choices.filter( func(c):
			if not str(c.get("kind", "")) in ["skill", "stat"]:
				return true
			var lim: = int(limits.get(Player.base_skill(str(c.get("id", ""))), 0))
			return lim <= 0 or int(c.get("level", 0)) <= lim)
		if not under.is_empty():
			choices = under
	var best: = {}
	var at: = order.size()
	var tier: = -1
	for c in choices:
		var i: = order.find(Player.base_skill(str(c.get("id", "")))) if str(c.get("kind", "")) in ["skill", "evolve", "stat"] else -1
		if i < 0:
			continue
		var r: = int(c.get("rarity", 0))
		if r > tier or (r == tier and i < at):
			tier = r
			at = i
			best = c
	if not best.is_empty():
		return best
	var top: = 0
	for c in choices:
		top = maxi(top, int(c.get("rarity", 0)))
	return choices.filter( func(c): return int(c.get("rarity", 0)) == top).pick_random()
