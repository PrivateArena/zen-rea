class_name LootRoll
extends RefCounted







const PICK_TIME: = 20.0


const HOLD_MAX: = 45.0

static var dice: = RandomNumberGenerator.new()


var items: Array = []

var picks: = {}

var ready: = {}
var tier: = 0
var at: = Vector3.ZERO
var t: = PICK_TIME


static func make(p_items: Array, p_tier: int, p_at: Vector3) -> LootRoll:
	var o: = LootRoll.new()
	dice.randomize()
	o.items = p_items
	o.tier = p_tier
	o.at = p_at
	return o


static func is_unique(it: Dictionary) -> bool:
	return bool(Equipment.item_def(it).get("unique", false))


func wants(slot: int, index: int) -> bool:
	return (picks.get(slot, []) as Array).has(index)



func toggle(slot: int, index: int) -> void :
	var mine: Array = picks.get(slot, [])
	if mine.has(index):
		mine.erase(index)
	else:
		mine.append(index)
	picks[slot] = mine



func wanted_by(index: int) -> Array:
	var out: = []
	for slot in picks:
		if (picks[slot] as Array).has(index):
			out.append(slot)
	return out




func useful(h: Player, index: int) -> bool:
	var it: Dictionary = items[index]
	var has: = h.equipment.has_item(str(it.id)) or h.equipment.bag.any( func(b): return str(b.id) == str(it.id))
	return not has and (is_unique(it) or h.equipment.can_wear(it))




func auto_pick(h: Player) -> void :
	var mine: = []
	for i in items.size():
		if useful(h, i):
			mine.append(i)
	picks[h.slot] = mine
	ready[h.slot] = true





const AUTO_MODES: = ["", "useful", "all", "pass"]


static func auto_mode() -> String:
	var m: = str(Save.setting("loot_auto", ""))
	return m if AUTO_MODES.has(m) else ""




func auto_wants(h: Player, index: int, mode: String) -> bool:
	match mode:
		"all":
			return true
		"useful":
			return useful(h, index)
	return false


func has_unique() -> bool:
	return items.any( func(it): return is_unique(it))



func resolve() -> Array:
	var out: = []
	for i in items.size():
		var want: = wanted_by(i)
		var r: = {"item": items[i], "winner": -1, "rolls": {}, "want": want}
		if want.size() == 1:
			r.winner = want[0]
		elif want.size() > 1:
			var best: = -1
			while best < 0:
				var top: = 0
				var tied: = 0
				for s in want:
					var roll: = dice.randi_range(1, 100)
					r.rolls[s] = roll
					if roll > top:
						top = roll
						best = s
						tied = 1
					elif roll == top:
						tied += 1
				if tied > 1:
					best = -1
			r.winner = best
		out.append(r)
	return out
