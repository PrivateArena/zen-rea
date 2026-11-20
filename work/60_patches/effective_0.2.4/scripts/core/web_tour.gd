extends Node








var world: World
var mode: = ""


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run()




func _to_mvp() -> void :
	var mvp: = str(world.stage.mvp)
	world.time = maxf(world.time, float(world.stage.mvp_time))
	var events: Array = world.stage.events
	while world._event_index < events.size() and float(events[world._event_index].at) <= world.time + 1.0:
		world._event_index += 1
	if not world.raid.supports(mvp):
		world._run_event({"type": "boss", "mob": mvp})
		return
	world.raid.open_portal(mvp)
	await get_tree().create_timer(0.3, true, false, true).timeout
	world.player.position = world.raid.portal_pos


func _run() -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var until: = func(cond: Callable, secs: float) -> bool:
		var left: = secs
		while left > 0.0 and not cond.call():
			await get_tree().create_timer(0.25, true, false, true).timeout
			left -= 0.25
		return cond.call()
	var packs: Node = world.web.packs if world.web != null else null
	var heap: = func() -> float:
		if OS.has_feature("web"):
			return float(JavaScriptBridge.eval("performance.memory ? performance.memory.usedJSHeapSize : 0", true)) / 1000000.0
		return OS.get_static_memory_usage() / 1000000.0
	var blocked: = func() -> int: return int(packs.blocking) if packs != null else 0
	var here: = func() -> String: return "%s real=%s" % [world.map.map_name, str(world.map.real)]
	await wait.call(2.0)
	print("WEBTOUR start mode=%s web=%s heap=%.0f" % [mode, str(packs != null), heap.call()])
	if mode == "kb":
		await _kb_test()
		return
	if mode != "flows":
		var names: Array[String] = [Town.MAP, str(GameData.TOWER_GATE.map), str(GameData.FESTIVAL_STAGE.map), Valhalla.MAP]
		for id in GameData.STAGES:
			names.append(str(GameData.STAGES[id].map))
		for mob in GameData.RAIDS:
			names.append(str(GameData.RAIDS[mob].arena))
		for band in GameData.TOWER_MAPS:
			names.append(str(band[1]))
		var seen: = {}
		var bad: = 0
		for m in names:
			if seen.has(m):
				continue
			seen[m] = true
			var t0: = Time.get_ticks_msec()
			if packs != null:
				await packs.ensure(World.web_keys([m]))
			var t1: = Time.get_ticks_msec()
			world._load_map(m)
			var t2: = Time.get_ticks_msec()
			await get_tree().process_frame
			await get_tree().process_frame
			if not world.map.real:
				bad += 1
			print("WEBTOUR map=%s real=%s music=%s fetch=%d load=%d heap=%.0f" % [m, str(world.map.real), str(RoAssets.music("map", m) != null), t1 - t0, t2 - t1, heap.call()])
		print("WEBTOUR maps done n=%d bad=%d blocked=%d" % [seen.size(), bad, blocked.call()])
	if mode != "maps":
		var cid: = "swordsman"

		world.menus.show_loading( func(): world.enter_town(cid), [Town.MAP])
		await until.call( func(): return world.town != null, 180.0)
		await wait.call(1.0)
		print("WEBTOUR town=%s map=%s blocked=%d" % [str(world.town != null), here.call(), blocked.call()])

		world.training = false
		world.set_stage("payon")
		print("WEBTOUR stage listed=%s due=%s" % [str(world.is_stage_exported("payon")), str(world._stage_map_due)])
		world.menus.show_loading( func(): world.start_run(cid))
		await until.call( func(): return world.running and world.player != null, 180.0)
		world.menus.close()
		get_tree().paused = false
		world.menus.auto_pick = true
		world.player.max_hp = 1000000000.0
		world.player.hp = 1000000000.0
		await wait.call(8.0)
		print("WEBTOUR run=%s map=%s want=%s enemies=%d blocked=%d heap=%.0f" % [str(world.running), here.call(), str(world.stage.map), world.enemies.size(), blocked.call(), heap.call()])

		Save.add_tower_build(RunSave.hero_snapshot(world))
		Save.add_tower_build(RunSave.hero_snapshot(world))

		print("WEBTOUR mvp=%s arena_known=%s" % [str(world.stage.mvp), str(world.raid.supports(str(world.stage.mvp)))])
		_to_mvp()
		await until.call( func(): return world.raid.in_arena(), 180.0)
		await wait.call(3.0)
		print("WEBTOUR arena=%s map=%s blocked=%d heap=%.0f" % [str(world.raid.in_arena()), here.call(), blocked.call(), heap.call()])
		world.raid.leave()
		await wait.call(1.5)
		print("WEBTOUR back map=%s" % here.call())
		world.abandon_run()
		await wait.call(1.0)

		world.menus.show_loading( func(): world.enter_town(cid, "tower_gate"), [str(GameData.TOWER_GATE.map)])
		await until.call( func(): return world.town != null, 180.0)
		await wait.call(1.0)
		print("WEBTOUR gate map=%s blocked=%d" % [here.call(), blocked.call()])
		world.menus.show_loading( func(): world.start_tower(0, 1), [TowerRun.map_of(1), str(GameData.TOWER_STAGE.map)])
		await until.call( func(): return world.tower != null and world.running and world.player != null, 180.0)
		world.menus.close()
		get_tree().paused = false
		world.menus.auto_pick = true
		await wait.call(3.0)
		var t: = world.tower
		print("WEBTOUR tower floor=%d map=%s blocked=%d" % [t.floor, here.call(), blocked.call()])
		var jumped: = false
		for k in 400:
			await wait.call(0.5)
			if world.tower == null or not is_instance_valid(t) or world.player == null:
				break
			world.player.max_hp = 1000000000.0
			world.player.hp = 1000000000.0
			if t.state == "climb" and t._stairs_at != Vector3.INF:
				world.player.position = t._stairs_at
			if t.state == "fight":
				t.need = 1
				for e in world.enemies.duplicate():
					if not e.is_boss:
						world.damage_enemy(e, 1000000000000.0)
						break
			if not jumped and t.floor >= 2 and t.state in ["rest", "climb"]:
				jumped = true
				t.floor = 21
			if world.map.map_name == TowerRun.map_of(26):
				break
		await wait.call(2.0)
		print("WEBTOUR tower up floor=%d map=%s want=%s blocked=%d heap=%.0f" % [t.floor if is_instance_valid(t) else -1, here.call(), TowerRun.map_of(26), blocked.call(), heap.call()])
		world.abandon_run()
		await wait.call(1.0)

		world.menus.show_loading( func(): world.start_festival(0), [str(GameData.FESTIVAL_STAGE.map)])
		await until.call( func(): return world.festival_mode and world.running and world.player != null, 180.0)
		world.menus.close()
		get_tree().paused = false
		await wait.call(4.0)
		print("WEBTOUR festival=%s map=%s blocked=%d heap=%.0f" % [str(world.festival_mode), here.call(), blocked.call(), heap.call()])
		world.abandon_run()
		await wait.call(1.0)
		world.menus.show_loading( func(): world.enter_town(cid), [Town.MAP])
		await until.call( func(): return world.town != null, 180.0)
		await wait.call(1.0)
		print("WEBTOUR town again map=%s blocked=%d heap=%.0f" % [here.call(), blocked.call(), heap.call()])
	print("WEBTOUR done blocked=%d" % blocked.call())
	if not OS.has_feature("web"):
		get_tree().quit()





func _kb_test() -> void :
	var win: CanvasLayer = load("res://scripts/ui/account_window.gd").new()
	get_tree().root.add_child(win)
	win.call("open", world, "login")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var fields: = win.find_children("*", "LineEdit", true, false)
	print("WEBTOUR kb fields=%d" % fields.size())
	if fields.is_empty():
		print("WEBTOUR done")
		return
	for f in fields:
		f.text_submitted.connect( func(t: String): print("WEBTOUR kb submitted=%s" % t))
	for i in 30:
		await get_tree().create_timer(0.5, true, false, true).timeout
		print("WEBTOUR kb " + " | ".join(fields.map( func(f: LineEdit): return "%s focus=%s" % [f.text, str(f.has_focus())])))
	print("WEBTOUR done")
