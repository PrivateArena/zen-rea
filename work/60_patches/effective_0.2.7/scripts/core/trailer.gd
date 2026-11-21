extends Node









var w: World
var opts: = {}


const PLAZA_LINES: = ["lf party Glast Heim, need 2", "anyone for Endless Tower?", "gg", "WTS Poring Card", 
	"nice wings!", "Morroc down!! gg", "who wants to farm Baphomet?", "lol", "+10 finally!!", 
	"festival run anyone?", "thx for the party", "that railgun is insane", "hi all", "brb food"]


func run(world: World, args: Array) -> void :
	w = world
	var at: = args.find("--trailer")
	var kind: = str(args[at + 1])
	if kind == "ui":
		await _ui(str(args[at + 2]), float(args[at + 3]))
		return
	var rest: Array = args.slice(at + 6)
	for a in rest:
		if "=" in str(a):
			opts[str(a).get_slice("=", 0)] = str(a).get_slice("=", 1)
	_quit_after(float(args[at + 5]))
	await _hero(str(args[at + 2]), int(args[at + 3]), str(args[at + 4]))
	await _extras()



func _process(_delta: float) -> void :
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)


func _quit_after(seconds: float) -> void :
	get_tree().create_timer(seconds, true, false, true).timeout.connect(get_tree().quit)


func _wait(t: float) -> void :
	await get_tree().create_timer(t, true, false, true).timeout


func _opt(key: String, fallback: float) -> float:
	return float(opts.get(key, fallback))




func _hero(cls: String, path: int, stage: String) -> void :
	var look: Dictionary = World.ITCH_LOOKS.get("%s:%d" % [cls, path], {})
	if not look.is_empty():
		look = look.duplicate()
		look["name"] = "Adventurer"
		Save.set_look(cls, look)
	if opts.has("reborn"):
		Save.data.rebirths[cls] = 1
	if opts.has("morroc"):
		GameData.set_meta("morroc_at", _opt("time", 330.0) + 1.5)
	else:
		GameData.set_meta("morroc_at", 1000000000.0)
	GameData.set_meta("tour_god", true)
	w.set_stage(stage)
	w.danger = int(_opt("danger", 8))
	w.start_run(cls)
	w.autopilot = true
	w.showcase = true
	w.quest.skip()
	w.menus.showcase = opts.has("menus") or opts.has("rookie")
	w.menus.auto_pick = not w.menus.showcase
	if opts.has("zoom"):
		w._cam_distance = _opt("zoom", 12.0)
	if opts.has("clean"):
		w.hud.visible = false
	var p: = w.player
	if opts.has("rookie"):
		p.level = GameData.JOB_CHANGE_LEVEL - 1
		p.xp_need = GameData.xp_to_next(p.level)
		p.xp = p.xp_need * 0.97
		for id in p.def.skills.slice(0, 4):
			for i in 3:
				p.add_skill(id)
	else:
		p.level = int(_opt("lv", 72))
		p.xp_need = GameData.xp_to_next(p.level)
		p.job_change(path)
		w.hud.bind(w)
		var ordered: Array = []
		if opts.has("start"):
			ordered = Array(str(opts.start).split(",", false))
		var rest: Array = p.skill_pool().duplicate()
		rest.reverse()
		for id in rest:
			if not ordered.has(id) and not opts.has("only"):
				ordered.append(id)
		for id in ordered:
			if not GameData.SKILLS.has(id) or GameData.SKILLS[id].type == "passive":
				continue
			if not p.skills.has(id) and p.count_skills(false) >= p.max_skills():
				continue
			for i in GameData.MAX_SKILL_LEVEL:
				p.add_skill(id)
		for s in ["str", "agi", "vit", "int", "dex", "luk"]:
			p.stats[s] = int(p.stats.get(s, 1)) + 30
		p.stats["agi"] = int(p.stats.agi) + int(_opt("agi", 0))

		if opts.has("passives"):
			for id in str(opts.passives).split(",", false):
				for i in GameData.MAX_SKILL_LEVEL:
					p.add_skill(id)

		if opts.has("gear"):
			for id in str(opts.gear).split(",", false):
				var it: = Equipment.make(id, 0)
				it["refine"] = int(_opt("refine", 0))
				p.equipment.slots[str(GameData.ITEMS[id].slot)] = it
		if opts.has("noskills"):
			for id in p.skills.keys():
				p.skills.erase(id)
	if opts.has("dmg"):
		p.altar_mods["dmg"] = _opt("dmg", 1.0)
	if opts.has("haste"):
		p.altar_mods["haste"] = _opt("haste", 0.0)
	p.recompute()
	p.hp = p.max_hp
	p.revives = 999
	w.time = _opt("time", 330.0)
	while w._event_index < w.stage.events.size() and w.stage.events[w._event_index].at < w.time - 1.0:
		w._event_index += 1



func _fill(ids: Array, count: int) -> void :
	var at: = w.player.position
	for i in count:
		var dir: = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU)
		w.spawn_enemy(ids.pick_random(), w.map.random_point_around(at + dir * randf_range(5.0, 26.0), 2.0), true)


func _extras() -> void :
	await _wait(_opt("settle", 0.4))
	if opts.has("fill"):
		_fill(Array(str(opts.get("mobs", "poring")).split(",", false)), int(_opt("fill", 200)))
	if opts.has("stroll"):
		_walk_line()
	if opts.has("levels"):
		await _wait(3.0)
		w.menus.showcase = true
		w.menus.auto_pick = false
		w.player.pending_levels = int(_opt("levels", 3))
	if opts.has("mvp"):
		w.raid.start_route(str(opts.mvp))
		w.player.hp = w.player.max_hp
	if opts.has("tower"):
		var build: = RunSave.hero_snapshot(w)
		Save.data["tower_unlocked"] = true
		Save.add_tower_build(build)
		var dmg: = _opt("dmg", 1.0)
		w.abandon_run()
		await _wait(0.2)
		w.start_tower(0, int(_opt("tower", 1)))
		w.autopilot = true
		w.showcase = true
		w.menus.auto_pick = true
		w.player.altar_mods["dmg"] = dmg
		w.player.recompute()
		w.menus.close()
		get_tree().paused = false
	if opts.has("festival"):

		Save.add_tower_build(RunSave.hero_snapshot(w))
		var fdmg: = _opt("dmg", 1.0)
		w.abandon_run()
		await _wait(0.2)
		w.start_festival(Save.tower_builds().size() - 1)
		w.autopilot = true
		w.showcase = true
		w.menus.auto_pick = true
		w.player.altar_mods["dmg"] = fdmg
		w.player.recompute()
		w.menus.close()
		get_tree().paused = false

		await _wait(0.4)
		w.menus.close()
		get_tree().paused = false
		if w.festival != null:
			w.player.position = w.festival._spot + Vector3(0, 0, 3.0)
			w.place_camera(w.player.position)
			w.festival._start_fight()
	if opts.has("cannon"):
		_cannon_loop()
	if opts.has("morroc"):

		while w.morroc.state != "omen":
			await _wait(0.2)
		w.morroc._omen = _opt("omen", 5.0)

		while w.morroc.boss == null:
			await _wait(0.1)
		w.morroc.boss.max_hp *= _opt("tough", 12.0)
		w.morroc.boss.hp = w.morroc.boss.max_hp
	if opts.has("chest"):
		await _wait(_opt("chest", 3.0))
		w.menus.auto_pick = false
		var p: = w.player
		w._open_chest_show(p.position + Vector3(2.2, 0, -0.6), 3, p.open_chest(5, 3, 600.0))
	while true:
		await _wait(0.5)
		if is_instance_valid(w.player):
			w.player.hp = w.player.max_hp





func _cannon_loop() -> void :
	await _wait(_opt("cannon", 2.0))
	var p: = w.player
	while is_instance_valid(p) and p == w.player:
		while is_instance_valid(p) and p.ov_stage < GameData.U_OV_STAGES:
			p.uniq["ov_t"] = float(p.uniq.get("ov_t", 0.0)) + _opt("cannon_step", 7.0)
			await _wait(0.2)
		await _wait(_opt("cannon_hold", 1.0))
		if not is_instance_valid(p):
			return
		w.skill_switch("u_overload")
		await _wait(_opt("cannon_gap", 4.0))





func _walk_line() -> void :
	w.autopilot = false
	var p: = w.player
	var dir: = _open_dir(Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU))
	var since_turn: = 0.0
	while is_instance_valid(p) and is_instance_valid(w.player):
		since_turn += 0.5
		if not _clear(p.position, dir) or since_turn > 3.5:
			dir = _open_dir(dir.rotated(Vector3.UP, randf_range(-0.6, 0.6)))
			since_turn = 0.0
		w.mouse_walk.walk_to(p.position + dir * 6.0)

		w.mouse_walk._mouse_mode = false
		await _wait(0.5)


func _clear(at: Vector3, d: Vector3) -> bool:
	for k in [2.0, 4.0, 7.0]:
		if not w.map.is_walkable(at + d * k):
			return false
	return true



func _open_dir(want: Vector3) -> Vector3:
	for k in [0, 1, -1, 2, -2, 3, -3, 4]:
		var d: = want.rotated(Vector3.UP, k * PI / 8.0)
		if _clear(w.player.position, d):
			return d
	return - want





func _rich_save() -> void :
	Save.add_zeny(8200000)
	Save.data["tower_unlocked"] = true
	for st in GameData.QUESTS:
		Save.complete_quest(st)
	for id in GameData.UPGRADES:
		Save.set_upgrade_level(id, mini(int(GameData.UPGRADES[id].max), 3))
	for id in GameData.SAGE_UPGRADES:
		Save.set_upgrade_level(id, mini(int(GameData.SAGE_UPGRADES[id].max), 2))
	for id in GameData.CLASSES:
		Save.data.unlocked[id] = true
		var look: Dictionary = World.ITCH_LOOKS.get("%s:0" % id, Save.look(id)).duplicate()
		look["name"] = "Adventurer"
		var jobs: Array = GameData.job_looks(id)
		if jobs.back().has("job"):
			look["show"] = str(jobs.back().job.id)
		Save.set_look(id, look)
	for id in GameData.PETS.keys().slice(0, 14):
		Save.add_pet(id)
	var pairs: = GameData.plagiarism_pairs()
	for i in range(0, pairs.size(), 2):
		Save.add_plagiarism(str(pairs[i][1]))
	Save.data["cook_level"] = 3
	Save.set_dishes(["immortal_stew", "lucky_soup", "twin_skewer"])
	for c in GameData.CARDS.keys().slice(0, 90):
		Save.data.cards[c] = 2
	for id in ["oridecon", "elunium"]:
		Save.add_material(id, 60)
	var i: = 0
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		if d.slot in ["weapon", "armor", "head", "garment", "shoes"] and not d.get("unique", false) and i < 14:
			if Save.add_to_storage(Equipment.make(id, 3)):
				Save.storage().back()["refine"] = 4 + i % 5
				i += 1


func _town_hero(cls: = "swordsman", job: = "lord_knight") -> void :
	var look: = Save.look(cls)
	look["show"] = job
	Save.set_look(cls, look)
	w.enter_town(cls)
	await _wait(0.6)



func _visit(id: String, from: = Vector3(0, 0, 6.0), hold: = 7.0) -> void :
	var town: = w.town
	var npc: = town.npc_node(id)
	if npc == null:
		await _wait(hold)
		return
	town.hero.position = npc.position + from
	w.place_camera(town.hero.position)
	await _wait(0.3)
	w.mouse_walk.walk_to(npc.position)
	for i in town._npcs.size():
		if town._npcs[i].node == npc:
			town._going_to = i
	await _wait(hold)



func _stroll(cells: Array) -> void :
	var town: = w.town
	town.hero.position = town._at(cells[0])
	w.place_camera(town.hero.position)
	await _wait(0.6)
	for c in cells.slice(1):
		w.mouse_walk.walk_to(town._at(c))
		while w.mouse_walk.active:
			for n in town._npcs:
				n.armed = false
			await _wait(0.1)
		await _wait(0.5)



func _album_scroll_box() -> ScrollContainer:
	for n in w.menus._root.find_children("*", "ScrollContainer", true, false):
		if n.is_visible_in_tree() and not n.find_children("*", "GridContainer", true, false).is_empty():
			return n
	return null


func _ui(name: String, seconds: float) -> void :
	_quit_after(seconds)
	GameData.set_meta("morroc_at", 1000000000.0)
	await _wait(0.1)
	_rich_save()
	for c in w.get_children():
		if c.get_script() != null and c.get_script().resource_path.ends_with("coffee_button.gd"):
			c.queue_free()
	match name:
		"select":
			w.menus.show_class_select()
			await _wait(1.2)
			for i in 10:
				var ev: = InputEventKey.new()
				ev.keycode = KEY_RIGHT
				ev.physical_keycode = KEY_RIGHT
				ev.pressed = true
				Input.parse_input_event(ev)
				await get_tree().process_frame
				var up: InputEventKey = ev.duplicate()
				up.pressed = false
				Input.parse_input_event(up)
				await _wait(0.8)
		"make":
			w.menus.show_char_make("swordsman")
			await _wait(1.0)
			var win: RoCharMake = w.menus._root.find_children("*", "RoCharMake", true, false).front()
			for i in 12:
				win.look.hair = (int(win.look.hair) + 3) % 18 + 1
				win.look.hair_color = (int(win.look.hair_color) + 1) % 8 + 1
				win._job = (i + 1) % win._jobs.size()
				win._refresh()
				await _wait(0.7)
		"town":
			await _town_hero()
			await _stroll([Vector2i(156, 190), Vector2i(153, 184), Vector2i(151, 179)])
		"kafra":
			await _town_hero()
			await _visit("kafra")
		"klauss":
			await _town_hero()
			await _visit("chef")
		"refiner":
			await _town_hero()
			await _visit("refiner")
		"teleport":
			await _town_hero()
			await _visit("teleport")
		"sage":
			await _town_hero()
			await _visit("sage")
		"lucile":
			await _town_hero()
			w.enter_town("swordsman", "tower_gate")
			await _wait(1.0)
			await _visit("tower")
		"worldmap":
			await _town_hero()
			w.menus.show_server_select("swordsman")
		"album":

			await _town_hero()
			w.menus._album_tab = "cards"
			w.menus.show_album()
			await _wait(0.9)
			var scroll: ScrollContainer = _album_scroll_box()
			if scroll != null:
				var tw: = create_tween()
				tw.tween_property(scroll, "scroll_vertical", 900, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				await _wait(2.6)
			for tab in ["pets", "plagio", "evo", "gear"]:
				w.menus._album_tab = tab
				w.menus._album_scroll = 0
				w.menus.show_album()
				await _wait(0.95)
		"plaza", "plazazoom":


			await _town_hero()
			if w.channel.join_enet(""):
				var Bot = load("res://scripts/net/channel_bot.gd")
				var bots: Array = []
				for i in 15:
					var bot: Node = Bot.new()
					bot.name = "Bot%d" % (i + 1)
					bot.town = w.town
					bot.center = w.town.hero.position
					bot.info = Bot.make_info(i)
					add_child(bot)
					bots.append(bot)
				w._cam_distance = 21.0
				await _wait(1.5)


				if name == "plazazoom":
					var tw: = create_tween()
					tw.tween_interval(2.0)
					tw.tween_property(w, "_cam_distance", 6.5, 2.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				var hero_walk: = [Vector3(-3, 0, 2), Vector3(2, 0, -1), Vector3(-1, 0, -3)]
				var k: = 0
				while true:
					for x in bots:
						x._say_t = 1000000000.0
					var b: Node = bots.pick_random()
					if b.is_in() and randf() < 0.6:
						b._send("say", ["%s : %s" % [b.info.name, PLAZA_LINES.pick_random()]])
					elif b.is_in():
						b.emote()
					if k % 6 == 0:
						w.mouse_walk.walk_to(w.town.hero.position + hero_walk[(k / 6) % hero_walk.size()])
						w.mouse_walk._mouse_mode = false
					k += 1
					await _wait(0.45)
		"tradeless":
			await _town_hero()
	while true:
		await _wait(1.0)
