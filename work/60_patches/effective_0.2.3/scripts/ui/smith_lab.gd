extends Node













var world: World
var dbg: Node
var dir: = ""


func start(w: World, menu: Node, args: PackedStringArray) -> void :
	world = w
	dbg = menu
	var at: = args.find("--smithlab")
	var a: = Array(args.slice(at + 1))
	dir = str(a[0])
	DirAccess.make_dir_recursive_absolute(dir)
	var mode: = str(a[1])
	var cls: = str(a[2])
	var path: = int(a[3])
	var reborn: = int(a[4]) == 1
	var secs: = float(a[5])
	var wref: = int(a[6]) if a.size() > 6 and not str(a[6]).begins_with("--") else -1
	var equip: = str(a[7]) if a.size() > 7 and not str(a[7]).begins_with("--") else "-"
	var shots: = a.size() > 8 and str(a[8]) == "1"
	if mode == "fx":
		_fx(reborn, wref, equip)
		return
	if mode == "coop":
		_coop_host(secs, wref, equip)
		return
	if mode == "coopc":
		_coop_client(secs)
		return
	_run(mode, cls, path, reborn, secs, wref, equip, shots)






func _fx(reborn: bool, wref: int, equip: String) -> void :
	while world.player == null or not world.running:
		await _wait(0.2)
	await _wait(1.0)
	world.menus.auto_pick = true
	world.menus.close()
	get_tree().paused = false
	Engine.time_scale = 1.0
	GameData.set_meta("no_spawn", true)
	GameData.set_meta("tour_god", true)
	for e in world.enemies.duplicate():
		if is_instance_valid(e):
			world.enemies.erase(e)
			e.queue_free()
	var p: Player = world.player
	if reborn:
		Save.data.rebirths["merchant"] = 1
		p.reborn = true
	if p.job2.is_empty():
		p.job_change(0)
	p.skills.clear()
	for id in ["axe_tornado", "cart_cannon", "hammer_fall", "over_thrust", "weaponry_research", "skin_tempering", "weapon_perfection"]:
		p.skills[id] = {"level": GameData.MAX_SKILL_LEVEL, "cd": 0.0}
	for id in ["axe_tornado", "hammer_fall", "over_thrust"]:
		p.evolve(id)
	for id in p.skills:
		p.skills[id].cd = 999.0
	p.level = 90
	for k in p.equipment.slots:
		p.equipment.slots[k] = null
	p.equipment.slots["weapon"] = Equipment.make(equip if equip != "-" else "dwarven_hammer", maxi(0, wref))
	p.forge = 0
	p.recompute()
	world.hud.bind(world)
	var foes: = []
	for i in 10:
		var a: = TAU * i / 10.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * (2.2 + (i % 3) * 0.8), true)
		if e != null:
			e.max_hp = 1000000000.0
			e.hp = e.max_hp
			e.speed = 0.0
			foes.append(e)
	await _wait(1.0)

	p.forge = p.forge_floor() + 4 - p.weapon_refine()
	p.forge_heat = 0.6
	p.recompute()
	await _wait(0.8)
	await _shot("1_forge_hot")
	print("FX hot temp=%.2f levels=%.1f" % [p.forge_temp(), p.forge_temp_levels()])
	world.forge_break(p, p.forge_refine())
	await _wait(0.12)
	await _shot("2_burst")
	await _wait(0.5)
	await _shot("3_tempered")
	print("FX tempered=%s powers=%s" % [p.tempered(), p.powers.keys()])
	await _wait(1.6)
	await _shot("4_molten_burn")
	var burning: = foes.filter( func(e): return is_instance_valid(e) and e.burn_time > 0.0).size()
	print("FX burning=%d of %d heat=%s" % [burning, foes.size(), foes.map( func(e): return e.burn_heat if is_instance_valid(e) else -1)])

	await _wait(2.5)
	p.forge = p.forge_floor() + 6 - p.weapon_refine()
	p.recompute()
	var dm: = p.dmg_mult
	print("FX vent=%s mpt=%.2f dmg_mult %.2f -> %.2f refine_now=%d" % [Skills.cast(world, p, "over_thrust_x", 1), p.mpt_power, dm, p.dmg_mult, p.forge_refine()])
	await _wait(0.2)
	await _shot("5_vent")
	await _wait(1.2)
	await _shot("6_vent_aura")

	await _wait(1.0)
	print("FX at_cold temp=%.2f" % p.forge_temp())
	Skills.cast(world, p, "axe_tornado_x", 1)
	await _wait(0.6)
	await _shot("7_axe_tornado_cold")
	await _wait(3.0)
	p.forge = p.forge_floor() + 5 - p.weapon_refine()
	p.recompute()
	print("FX at_hot temp=%.2f" % p.forge_temp())
	Skills.cast(world, p, "axe_tornado_x", 1)
	await _wait(0.6)
	await _shot("8_axe_tornado_hot")
	await _wait(3.0)

	for e in foes:
		if is_instance_valid(e):
			world.enemies.erase(e)
			e.queue_free()
	var boss: = world.spawn_enemy(str(GameData.STAGES[world.stage_id].mvp), p.position + Vector3(2.0, 0, 0), true)
	boss.max_hp = 1000000000000.0
	boss.hp = boss.max_hp
	world.stagger.clear()
	p.forge = p.forge_floor() + 3 - p.weapon_refine()
	world.forge_break(p, p.forge_refine())
	await _wait(0.3)
	var before: = float((world.stagger._of.get(boss.get_instance_id(), {"v": 0.0}) as Dictionary).v)
	print("FX on_molten hero=%s boss=%s" % [World.Forge.on_molten(world, p.position), World.Forge.on_molten(world, boss.position)])
	Skills.cast(world, p, "hammer_fall_x", 1)
	var st = world.stagger._of.get(boss.get_instance_id(), {})
	print("FX slam fill before=%.1f after=%s breaks=%s status=%s" % [before, st.get("v", -1), st.get("breaks", -1), boss.status])
	await _wait(0.15)
	await _shot("9_hammer_fall_mvp")
	await _wait(1.0)
	await _shot("10_mvp_stunned")
	print("FX meter=%s" % [world.meter_sorted().slice(0, 8).map( func(r): return "%s=%d" % [r.tag, roundi(r.dmg)])])
	get_tree().quit()


func _wait(t: float) -> void :
	await get_tree().create_timer(t, true, false, true).timeout


func _shot(label: String) -> void :
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, label])


func _run(mode: String, cls: String, path: int, reborn: bool, secs: float, wref: int, equip: String, shots: bool) -> void :
	while world.player == null or not world.running:
		await _wait(0.2)
	await _wait(1.0)
	if reborn:
		Save.data.rebirths[cls] = 1
	world.menus.auto_pick = true
	world.menus.close()
	get_tree().paused = false
	var p: Player = world.player
	if reborn:
		p.reborn = true
	if p.job2.is_empty():
		p.job_change(path)
	dbg.call("_max_hero", -1)

	if equip != "-":
		p.equipment.slots["weapon"] = dbg.call("_max_item", Equipment.make(equip, 0))
	var w = p.equipment.slots.get("weapon")
	if w != null and wref >= 0:
		w["refine"] = wref
	p.forge = 0
	p.forge_heat = 0.0
	p.recompute()
	p.max_hp = 9000000000.0
	p.hp = p.max_hp
	GameData.set_meta("tour_god", true)
	world.meter.clear()
	var stats0: = world.smoke_stats.duplicate()
	print("LAB start mode=%s job=%s weapon=%s +%d safe=%d max=%d skills=%s" % [mode, p.job2.get("id", ""), str(w.id) if w != null else "-", 
		p.weapon_refine(), p.forge_safe(), p.forge_max(), p.skills.keys()])
	print("LAB stats str=%d int=%d dex=%d aspd=%.0f basic_atk=%.0f skill_mult=%.2f basic_mult=%.2f" % [p.eff_stat("str"), p.eff_stat("int"), 
		p.eff_stat("dex"), p.aspd(), p.basic_atk(), p.skill_mult, p.basic_mult])
	var boss: Enemy = null
	if mode == "mvp":
		GameData.set_meta("no_spawn", true)
		for e in world.enemies.duplicate():
			if is_instance_valid(e):
				world.enemies.erase(e)
				e.queue_free()
		world.autopilot = false
		boss = world.spawn_enemy(str(GameData.STAGES[world.stage_id].mvp), p.position + Vector3(3.5, 0, 0), true)
		boss.max_hp = 100000000000000.0
		boss.hp = boss.max_hp
		world.stagger.clear()
	else:
		world.autopilot = true
		GameData.set_meta("mvp_at", 1000000000.0)
		GameData.set_meta("morroc_at", 1000000000.0)
		world.time = 540.0
	Engine.time_scale = 4.0
	var t0: = world.clock
	var breaks: Array = []
	var last_breaks: = 0
	var last_forge: = p.forge
	var drops: = 0
	var samples: = 0
	var up: = {}
	var shot_n: = 0
	var kills0: = world.kills
	while world.clock - t0 < secs:
		await _wait(0.1)
		if not world.running:
			break
		p.hp = p.max_hp
		samples += 1
		for k in p.powers:
			up[k] = int(up.get(k, 0)) + 1
		if p.forge < last_forge:
			drops += 1
		last_forge = p.forge
		if boss != null and is_instance_valid(boss):
			boss.hp = boss.max_hp
			var st = world.stagger._of.get(boss.get_instance_id())
			if st != null and int(st.breaks) > last_breaks:
				last_breaks = int(st.breaks)
				breaks.append(snappedf(world.clock - t0, 0.1))
				if shots and breaks.size() <= 2:
					await _shot("%s_%s_break%d" % [mode, p.job2.get("id", cls), breaks.size()])
		if shots and shot_n < 6 and world.clock - t0 > (shot_n + 1) * secs / 7.0:
			shot_n += 1
			await _shot("%s_%s_%d" % [mode, p.job2.get("id", cls), shot_n])
	var span: = world.clock - t0
	var total: = 0.0
	for k in world.meter:
		total += float(world.meter[k].get("dmg", 0.0))
	print("LAB result mode=%s job=%s span=%.0f total=%.0f dps=%.0f kills=%d forge_drops=%d refine_now=%d" % [mode, p.job2.get("id", cls), 
		span, total, total / maxf(1.0, span), world.kills - kills0, drops, p.forge_refine()])
	for r in world.meter_sorted().slice(0, 12):
		print("LAB meter %s %.1f%%  %.0f" % [r.tag, 100.0 * float(r.dmg) / maxf(1.0, total), float(r.dmg)])
	if boss != null:
		var gaps: = []
		for i in breaks.size():
			gaps.append(snappedf(float(breaks[i]) - (float(breaks[i - 1]) if i > 0 else 0.0), 0.1))
		print("LAB breaks n=%d at=%s gaps=%s" % [breaks.size(), breaks, gaps])
	var upt: = {}
	for k in up:
		upt[k] = "%d%%" % roundi(100.0 * up[k] / maxf(1.0, samples))
	print("LAB uptime %s" % [upt])
	var sdiff: = {}
	for k in world.smoke_stats:
		if typeof(world.smoke_stats[k]) in [TYPE_INT, TYPE_FLOAT] and float(world.smoke_stats[k]) != float(stats0.get(k, 0)):
			sdiff[k] = float(world.smoke_stats[k]) - float(stats0.get(k, 0))
	print("LAB stats %s" % [sdiff])
	Engine.time_scale = 1.0
	get_tree().quit()







func _coop_host(secs: float, wref: int, equip: String) -> void :
	while world.heroes.size() < 2 or not world.running:
		await _wait(0.5)
	await _wait(2.0)
	GameData.set_meta("tour_god", true)
	var h: Player = world.heroes[1]
	if h.job2.is_empty():
		h.job_change(0)
	for id in ["axe_tornado", "hammer_fall", "over_thrust", "skin_tempering", "weaponry_research", "weapon_perfection"]:
		h.skills[id] = {"level": GameData.MAX_SKILL_LEVEL, "cd": 0.0}
	for id in ["axe_tornado", "hammer_fall", "over_thrust"]:
		h.evolve(id)
	h.equipment.slots["weapon"] = Equipment.make(equip if equip != "-" else "dwarven_hammer", 0)
	h.equipment.slots["weapon"]["refine"] = maxi(0, wref)
	h.level = maxi(h.level, 60)
	h.recompute()
	print("COOPLAB host guest=%s job=%s weapon=%s skills=%s" % [h.class_id, h.job2.get("id", ""), h.equipment.slots.weapon.id, h.skills.keys()])
	var t0: = world.clock
	var step: = 0
	while world.clock - t0 < secs and world.running:
		await _wait(3.0)
		if not world.hero_valid(h):
			break
		step += 1
		match step % 4:
			1:
				h.forge = h.forge_floor() + 3 - h.weapon_refine()
				world.forge_break(h, h.forge_refine())
				print("COOPLAB host burst tempered=%s" % h.tempered())
			2:
				h.forge = h.forge_floor() + 5 - h.weapon_refine()
				h.recompute()
				print("COOPLAB host vent=%s mpt=%.2f" % [World.Forge.vent(world, h), h.mpt_power])
			3:
				h.forge = h.forge_floor() + 5 - h.weapon_refine()
				h.recompute()
				world.damage_by = h
				print("COOPLAB host axe_tornado heat=%.2f cast=%s" % [h.forge_temp(), Skills.cast(world, h, "axe_tornado_x", 1)])
				world.damage_by = null
			0:
				var boss: = world.spawn_enemy(str(GameData.STAGES[world.stage_id].mvp), h.position + Vector3(1.5, 0, 0), true)
				if boss != null:
					boss.max_hp = 1000000000000.0
					boss.hp = boss.max_hp
					h.forge = h.forge_floor() + 3 - h.weapon_refine()
					world.forge_break(h, h.forge_refine())
					world.damage_by = h
					Skills.cast(world, h, "hammer_fall_x", 1)
					world.damage_by = null
					var st = world.stagger._of.get(boss.get_instance_id(), {})
					print("COOPLAB host slam on_molten=%s fill=%s" % [World.Forge.on_molten(world, h.position), st.get("v", -1)])
					world.get_tree().create_timer(2.5, false).timeout.connect( func():
						if is_instance_valid(boss):
							boss.hp = 0.0
							world.enemies.erase(boss)
							boss.queue_free())
	print("COOPLAB host done")





func _coop_client(secs: float) -> void :
	while world.player == null or not world.running:
		await _wait(0.5)
	var seen: = {}
	var t: = 0.0
	var n: = 0
	while t < secs:
		await _wait(0.25)
		t += 0.25
		var p: Player = world.player
		if p == null:
			continue
		if p.get_node_or_null("TemperAura") != null:
			seen["temper_aura:" + p.temper_el] = int(seen.get("temper_aura:" + p.temper_el, 0)) + 1
		if p.get_node_or_null("VentAura") != null:
			seen["vent_aura"] = int(seen.get("vent_aura", 0)) + 1
		for k in p.powers:
			seen["power:" + str(k)] = int(seen.get("power:" + str(k), 0)) + 1
		if int(t * 4.0) % 12 == 0:
			n += 1
			await _shot("client_%02d" % n)
	print("COOPLAB client job=%s skills=%s seen=%s" % [world.player.job2.get("id", ""), world.player.skills.keys(), seen])
	get_tree().quit()
