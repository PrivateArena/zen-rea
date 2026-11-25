class_name Achievements
extends RefCounted







static func value(a: Dictionary) -> float:
	match str(a.stat):
		"cards":
			return GameData.CARDS.keys().filter( func(c): return Save.has_card(c)).size()
		"pets":

			return _pets(false).filter( func(p): return Save.has_pet(p)).size()
		"mvp_pets":
			return _pets(true).filter( func(p): return Save.has_pet(p)).size()
		"recipes":
			return GameData.RECIPES.keys().filter( func(r): return Save.recipe_known(r)).size()
		"quests":
			return GameData.QUESTS.keys().filter( func(q): return Save.quest_done(q)).size()
		"stages":
			return GameData.STAGES.keys().filter( func(s): return Save.is_stage_cleared(s)).size()
		"hard_stages":
			return GameData.STAGES.keys().filter( func(s): return Save.is_stage_hard_cleared(s)).size()
		"reborn":
			return GameData.CLASSES.keys().filter( func(c): return Save.is_reborn(c)).size()
		"class_level":

			var best: = 1
			for c in GameData.CLASSES:
				best = maxi(best, int(Save.class_progress(c).level))
				if Save.is_reborn(c):
					best = maxi(best, GameData.REBIRTH_CLASS_LEVEL)
			return best
		"classes":

			return GameData.CLASSES.keys().filter(_played).size()
		"evos", "jobs":
			return Save.seen_count(str(a.stat))
		"storage_refine":

			var top: = float(Save.stat("storage_refine"))
			for it in Save.storage():
				top = maxf(top, float(it.get("refine", 0)))
			return top
		"legendaries":
			var have: = Save.storage().filter( func(it): return Equipment.is_legendary(it)).size()
			return maxf(float(Save.stat("legendaries")), float(have))
		"entered":
			return GameData.STAGES.keys().filter( func(s): return Save.entered(s)).size()
		"regions":
			return GameData.REGIONS.keys().filter( func(r): return (GameData.REGIONS[r].stages as Array).any( func(s): return Save.is_stage_cleared(s))).size()
		"max_danger":
			return Save.max_danger()
		"tower_top":
			return Save.tower_top()
		"hel_top":
			return Save.hel_top()
		"oath_top":
			return Save.oath_top()
		"wings_top":

			var top: = 0.0
			for it in Save.storage():
				if bool(GameData.ITEMS.get(str(it.get("id", "")), {}).get("wings", false)):
					top = maxf(top, float(it.get("refine", 0)))
			return top
		"cos_legendary", "cos_unique":
			var rar: = "legendary" if str(a.stat) == "cos_legendary" else "unique"
			return Save.owned_cosmetics().filter( func(c): return str(GameData.COSMETICS.get(str(c), {}).get("rarity", "")) == rar).size()
		"plagiarized":
			return Save.plagiarized().size()

	if str(a.stat).begins_with("stage:"):
		return 1.0 if Save.is_stage_cleared(str(a.stat).trim_prefix("stage:")) else 0.0
	return float(Save.stat(str(a.stat)))



static func goal(a: Dictionary) -> float:
	if str(a.get("goal", "")) != "all":
		return float(a.goal)
	match str(a.stat):
		"cards":
			return GameData.CARDS.size()
		"pets":
			return _pets(false).size()
		"mvp_pets":
			return _pets(true).size()
		"recipes":
			return GameData.RECIPES.size()
		"quests":
			return GameData.QUESTS.size()
		"stages", "hard_stages", "entered":
			return GameData.STAGES.size()
		"regions":
			return GameData.REGIONS.size()
		"reborn":

			return GameData.CLASSES.keys().filter( func(c): return not GameData.CLASSES[c].get("no_rebirth", false)).size()
		"classes":
			return GameData.CLASSES.size()
	return 1.0


static func _played(c: String) -> bool:

	return Save.has_seen("classes", c) or float(Save.best(c).time) > 0.0 or int(Save.class_progress(c).level) > 1 or Save.is_reborn(c)


static func _pets(mvp: bool) -> Array:
	return GameData.PETS.keys().filter( func(p): return GameData.PETS[p].get("mvp", false) == mvp)


static func progress(a: Dictionary) -> float:
	return clampf(value(a) / maxf(1.0, goal(a)), 0.0, 1.0)




static func check() -> Array:
	var out: = []
	for id in GameData.ACHIEVEMENTS:
		if Save.achieved(id):
			continue
		var a: Dictionary = GameData.ACHIEVEMENTS[id]
		if value(a) >= goal(a):
			Save.complete_achievement(id, int(a.coins))
			out.append(id)
	if not out.is_empty():
		Save.flush()
	return out




static func percent() -> float:
	var ids: = counted()
	var done: = ids.filter( func(id): return Save.achieved(id)).size()
	return float(done) / maxf(1.0, ids.size())



static func counted() -> Array:
	return GameData.ACHIEVEMENTS.keys().filter( func(id): return not bool(GameData.ACHIEVEMENTS[id].get("extra", false)))


static func icon(a: Dictionary) -> Texture2D:
	var path: = "res://assets/ro/ui/skin/achievement/%s.png" % str(a.icon)
	return load(path) as Texture2D if ResourceLoader.exists(path) else null



static func coin_icon() -> Texture2D:
	var path: = "res://assets/ro/ui/skin/item_icons/poring_coin.png"
	return load(path) as Texture2D if ResourceLoader.exists(path) else null
