class_name RunSave
extends RefCounted








const VERSION: = 1

const EVERY: = 15.0


static func path() -> String:
	return Save.PATH.get_basename() + ".run"


static func exists() -> bool:
	return not info().is_empty()



static func info() -> Dictionary:
	if not FileAccess.file_exists(path()):
		return {}
	var data = str_to_var(FileAccess.get_file_as_string(path()))
	if not data is Dictionary or int(data.get("version", 0)) != VERSION\
	or not GameData.STAGES.has(str(data.get("stage", ""))) or not GameData.CLASSES.has(str(data.get("class", ""))):
		return {}
	if _purge_iceicle_card(data):
		var f: = FileAccess.open(path(), FileAccess.WRITE)
		if f != null:
			f.store_string(var_to_str(data))
			f.close()
	return data



static func _purge_iceicle_card(value: Variant) -> bool:
	var changed: = false
	if value is Dictionary:
		if value.erase("iceicle_card"):
			changed = true
		for key in value.keys():
			var child = value[key]
			if child is Array:
				for i in range(child.size() - 1, -1, -1):
					if str(child[i]) == "iceicle_card":
						child.remove_at(i)
						changed = true
					elif _purge_iceicle_card(child[i]):
						changed = true
			elif _purge_iceicle_card(child):
				changed = true
	elif value is Array:
		for i in range(value.size() - 1, -1, -1):
			if str(value[i]) == "iceicle_card":
				value.remove_at(i)
				changed = true
			elif _purge_iceicle_card(value[i]):
				changed = true
	return changed


static func clear() -> void :
	if FileAccess.file_exists(path()):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path()))




static func save(w: World) -> bool:

	if w.player == null or not w.running or w.autopilot or w.showcase or w.raid.active() or w.morroc.active() or w.is_coop():
		return false

	if w.tower != null:
		return false
	var d: = hero_snapshot(w)
	d.merge({
		"version": VERSION, 
		"date": Time.get_datetime_string_from_system(false, true), 
		"fast": w.fast_mode, "speed": w.speed, "hard": w.hard, 
		"time": w.time, "kills": w.kills, "zeny": w.run_zeny, "event_index": w.event_index(), 
		"endless": w.endless, "endless_state": w.endless_state(), 
		"hp": w.player.hp, 

		"quest_seen": w.quest.state != "wait", 
		"xp_gained": w.player.xp_gained, 
		"meter": w.meter.duplicate(true), "meter_stats": w.meter_stats.duplicate(true), 
		"meter_boss": w.meter_boss.duplicate(true), "meter_taken": w.meter_taken.duplicate(true), 
		"picks": picks(w.player), 
	}, true)
	var tmp: = path() + ".tmp"
	var f: = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("RunSave: cannot write %s" % tmp)
		return false
	f.store_string(var_to_str(d))
	f.close()
	if FileAccess.file_exists(path()):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path()))
	DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(path()))
	return true





static func hero_snapshot(w: World, hero: Player = null) -> Dictionary:

	var p: = hero if hero != null else w.player

	var skill_levels: = []
	for id in p.skills:
		skill_levels.append([id, int(p.skills[id].level)])
	return {
		"stage": w.stage_id, "danger": w.danger, "class": p.class_id, "saved": Time.get_datetime_string_from_system(false, true), 

		"oaths": w.oaths.duplicate(), 
		"level": p.level, "xp": p.xp, "xp_need": p.xp_need, 
		"skills": skill_levels, "stats": p.stats.duplicate(), "base_stats": p.base_stats.duplicate(), "homun": p.homun_type, "homun_extra": p.homun_extra.duplicate(), "forge": p.forge, 
		"cards": Array(p.cards), "job2": not p.job2.is_empty(), "job_path": p.job_path, "book": p.song_book, 


		"album_cards": Array(p.album_cards).duplicate(), 
		"quiver": Array(p.quiver), "arrow": p.arrow_id, 

		"toys": p.toys.duplicate(), 
		"rerolls": p.rerolls, "banishes": p.banishes, "banished": Array(p.banished), "gods": w.altars.taken.duplicate(), 
		"revives": p.revives, "stew_hp": p.stew_hp, "stew_kills": p.stew_kills, "root_kills": p.root_kills, "lg_bash_kills": p.lg_bash_kills, "hel_marks": p.hel_marks, "feathers": p.feathers, "soul_bonds": p.soul_bonds, "karma": w.karma.save_state(), 
		"slots": p.equipment.slots.duplicate(true), "card_bag": Array(p.equipment.card_bag), 
		"ores": p.equipment.ores.duplicate(), "ores_found": p.equipment.ores_found.duplicate(), "bag": p.equipment.bag.duplicate(true), 
		"left_waiting": p.equipment.left_waiting, 
		"name": p.job_name(), 

		"endless_s": w.time if w.endless else 0.0, 
		"stats_v3": true, 
	}





static func stats_v3(d: Dictionary) -> Array:
	var st: = (d.stats as Dictionary).duplicate()
	var bs: = (d.get("base_stats", {}) as Dictionary).duplicate()
	if bool(d.get("stats_v3", false)):
		return [st, bs]
	var ws: = 0.0
	var wi: = 0.0
	for pair in d.get("skills", []):
		var id: = str(pair[0])
		if GameData.SKILLS.has(id) and GameData.SKILLS[id].has("damage"):
			var w: = GameData.skill_stats(id)
			ws += float(w.get("str", 0.0))
			wi += float(w.get("int", 0.0))
	if ws <= 0.0:
		return [st, bs]
	var share: = ws / (ws + wi)
	var b_int: = int(bs.get("int", 0))
	var mb: = roundi(b_int * share)
	var mr: = roundi(maxi(0, int(st.get("int", 0)) - b_int) * share)
	if mb > 0:
		bs["int"] = b_int - mb
		bs["str"] = int(bs.get("str", 0)) + mb
	st["int"] = int(st.get("int", 0)) - mb - mr
	st["str"] = int(st.get("str", 0)) + mb + mr
	return [st, bs]




static func picks(p: Player) -> Dictionary:
	return {"cards": Array(p.album_cards), "pet": p.pet_id, "pet_skin": p.pet_skin, "dishes": Array(p.dishes), "pacts": p.pacts.duplicate()}



static func resume(w: World) -> bool:
	var d: = info()
	if d.is_empty():
		return false
	w.set_stage(str(d.stage))
	w.speed = mini(3, int(d.get("speed", 2 if bool(d.fast) else 1)))
	w.hard_mode = false
	w.danger = int(d.get("danger", GameData.DANGER_HARD if bool(d.get("hard", false)) else 1))

	var auto: bool = Save.setting("endless_auto_pick", false)
	w.resume_picks = d.get("picks", {})
	w.oaths_next = (d.get("oaths", {}) as Dictionary).duplicate() if d.get("oaths", {}) is Dictionary else {}
	w.start_run(str(d["class"]))
	Save.set_setting("endless_auto_pick", auto)
	apply_hero(w, d)
	w.player.xp_gained = float(d.get("xp_gained", 0.0))
	w.player.hp = clampf(float(d.hp), 1.0, w.player.max_hp)
	w.restore_clock(float(d.time), int(d.kills), int(d.zeny), int(d.event_index), bool(d.endless), d.endless_state)
	if bool(d.get("quest_seen", false)):
		w.quest.skip()
	w.meter = (d.meter as Dictionary).duplicate(true)
	w.meter_stats = (d.meter_stats as Dictionary).duplicate(true)
	w.meter_boss = (d.get("meter_boss", {}) as Dictionary).duplicate(true)
	w.meter_taken = (d.get("meter_taken", {}) as Dictionary).duplicate(true)
	return true





static func apply_hero(w: World, d: Dictionary, p: Player = null, world_parts: = true) -> void :
	if p == null:
		p = w.player
	if bool(d.job2):

		p.song_book = int(d.get("book", -1))
		p.job_change(int(d.get("job_path", 0)))
	p.skills.clear()
	for pair in d.skills:
		if GameData.SKILLS.has(str(pair[0])):
			p.skills[str(pair[0])] = {"level": int(pair[1]), "cd": 0.5}




	if p.class_id == "super_novice":
		var mults: = 0
		for id in p.skills.keys():
			if GameData.sn_mult(str(id)):
				mults += 1
				if mults > GameData.SN_MULT_MAX:
					p.skills.erase(id)
	if p.skills.has("peco_riding"):
		p._build_visual()
	p.homun_type = str(d.get("homun", ""))
	p.homun_extra = (d.get("homun_extra", []) as Array).duplicate()
	p.forge = int(d.get("forge", 0))



	if p.homun_type != "" and not w.net.is_client():
		w.spawn_homun(p)
	var conv: = stats_v3(d)
	for k in conv[0]:
		p.stats[k] = int(conv[0][k])
	for k in conv[1]:
		p.base_stats[k] = int(conv[1][k])
	p.level = int(d.level)
	p.xp = float(d.xp)
	p.xp_need = int(d.xp_need)
	p.cards.assign(d.cards)

	if d.get("album_cards") is Array:
		p.album_cards.assign((d.album_cards as Array).filter( func(c): return GameData.CARDS.has(str(c))))
	p.equipment.slots = (d.slots as Dictionary).duplicate(true)

	for k in GameData.EQUIP_SLOTS:
		if not p.equipment.slots.has(k):
			p.equipment.slots[k] = null
	p.equipment.card_bag.assign(d.card_bag)
	p.equipment.ores = (d.ores as Dictionary).duplicate()

	p.equipment.ores_found = (d.get("ores_found", d.ores) as Dictionary).duplicate()
	p.equipment.bag = (d.get("bag", []) as Array).duplicate(true)
	p.equipment.left_waiting = d.get("left_waiting") if d.get("left_waiting") is Dictionary else null
	p.quiver.assign(d.quiver)
	if str(d.arrow) != "":
		p.set_arrow(str(d.arrow))
	for g in (d.get("gods", []) if world_parts else []):
		if GameData.ALTARS.has(str(g)):
			w.altars.take(str(g), true)
	p.toys = {}
	for id in (d.get("toys", {}) as Dictionary):
		if GameData.MORROC_TOYS.has(str(id)):
			p.toys[str(id)] = mini(int(d.toys[id]), int(GameData.MORROC_TOYS[str(id)].get("max", 3)))
	p.rerolls = int(d.rerolls)
	p.banishes = int(d.banishes)
	p.banished.assign(d.banished)
	p.revives = int(d.revives)


	p.stew_kills = int(d.get("stew_kills", roundi(float(d.get("stew_hp", 0.0)))))
	p.stew_hp = Player.stew_hp_of(p.stew_kills) if p.stew_kills > 0 else 0.0
	p.hel_marks = int(d.get("hel_marks", 0))
	p.feathers = int(d.get("feathers", 0))
	p.soul_bonds = int(d.get("soul_bonds", 0))
	p.root_kills = int(d.get("root_kills", 0)) if p.root_level() > 0 else 0
	p.root_hp = p.root_hp_of(p.root_kills)

	p.lg_bash_kills = int(d.get("lg_bash_kills", 0))
	if world_parts:
		w.karma.restore(d.get("karma", {}))
	else:


		w.karma.hero_boons(p, d.get("karma", {}))
	p.recompute()
	p.hp = p.max_hp
