class_name MorrocEvent
extends Node3D





















const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")


var state: = "idle"
var world: World
var data: Dictionary = GameData.MORROC
var color: Color = GameData.MORROC.color
var mvp: String = GameData.MORROC.mob
var center: = Vector3.ZERO
var radius: = 15.0
var boss: Enemy
var phase: = 0


var ymir: = 0.0
var ymir_at: = 0.0

var stats: = {"seen": false, "time": 0.0, "fails": 0, "phase": 0, "won": false}

var _planned_at: = INF
var _endless_next: = 0.0
var _last_at: = - INF
var _omen: = 0.0
var _fall: = 0.0
var _fight_t: = 0.0
var _ymir_fx: = 0.0
var _calm_damage: = 1.0
var _timers: = {}
var _cast: = {}
var _cast_bar: Label3D
var _objects: Array[Dictionary] = []

var _own: Array[Enemy] = []

var _airborne: = false

var _vuln: = 0.0
var _judge_in: = false
var _shock: = -1.0
var _tick_count: = -1
var _arena: Node3D
var _faller: RoVisual
var _layer: CanvasLayer
var _veil: TextureRect
var _count: Label
var _lights: = {}
var _env: Environment
var _env_was: = {}
var _light_tw: Tween

var finale: = false

var _finale_done: = false

var _finale_warned: = 0
var _finale_retry: = 0.0

var _finale_fails: = 0
var _finale_why: = ""

var _talk_box: Control
var _talk_text: Label
var _talk_i: = -1


var level: = 1


var beaten: = 0


func _ready() -> void :
	name = "MorrocEvent"


func active() -> bool:
	return state != "idle"




func _later(t: float, f: Callable) -> void :
	get_tree().create_timer(t, false).timeout.connect( func():
		if active():
			world.fx_layer(GameData.MVP_FX_PRIORITY)
			f.call()
			world.fx_layer(0))



func freezes_time() -> bool:
	return state != "idle"


func fighting() -> bool:
	return state == "fight"




const DAZE_MARGIN: = 6.0
func dazes(e: Enemy) -> bool:
	return state == "fight" and not _own.has(e) and _flat(e.position, center) < radius + DAZE_MARGIN




func walled(e: Enemy) -> bool:
	return state == "fight" and not _own.has(e) and _flat(e.position, center) > radius + e.radius * 0.5




func stagger_ok(e: Enemy) -> bool:
	return state == "fight" and e == boss and not _airborne and _vuln <= 0.0 and not _growing()




func finale_won() -> bool:
	return state == "won" or (finale and level > 1 and state != "idle")




func finale_due() -> bool:
	if world == null or not world.endless or world.tower != null or world.training or world.festival_mode:
		return false
	if world.autopilot and not GameData.has_meta("finale_at"):
		return false
	return finale or ( not _finale_done and world.time >= finale_at())


func finale_at() -> float:
	return float(GameData.get_meta("finale_at")) if GameData.has_meta("finale_at") else float(GameData.MORROC_FINALE.at)


func is_boss(e: Enemy) -> bool:
	return boss != null and e == boss and state != "idle"




func hero_mult(e: Enemy) -> float:
	if state != "fight":
		return 1.0
	var m: = 1.0 + GameData.RAID_YMIR_HERO_DMG * ymir
	if _vuln > 0.0 and e == boss:
		m *= 1.0 + float(data.incarnations.vuln)

	if e == boss and _growing():
		return 0.0
	return m



func hero_cd() -> float:
	return minf(GameData.RAID_YMIR_CD_MAX, 1.0 + GameData.RAID_YMIR_HERO_CD * ymir) if state == "fight" else 1.0


func ymir_mvp_mult() -> float:
	return 1.0 + GameData.RAID_YMIR_MVP_DMG * ymir


func _ymir_cast() -> float:
	return minf(GameData.RAID_YMIR_CAST_MAX, 1.0 + GameData.RAID_YMIR_MVP_CAST * ymir)



func ymir_text() -> String:
	if state != "fight" or boss == null:
		return ""
	if ymir > 0.0:
		return tr("Ymir:  tú x%s  ·  MVP x%s") % [str(snappedf(hero_mult(null), 0.1)), str(snappedf(ymir_mvp_mult(), 0.1))]
	return tr("Ymir despierta en %s") % UiKit.time_text(maxf(0.0, ymir_at - _fight_t))



func hud_state() -> String:
	match state:
		"omen", "fall":

			return ""
		"fight":
			return tr("¡Morroc!") if finale else tr("¡Satan Morroc!")
		"won":
			return tr("¡Victoria!")
	return ""





func plan() -> void :
	reset()
	_use(GameData.MORROC, false)
	_finale_done = false
	_finale_warned = 0
	_finale_retry = 0.0
	_finale_fails = 0
	_finale_why = ""
	level = 1
	beaten = 0
	stats = {"seen": false, "time": 0.0, "fails": 0, "phase": 0, "won": false}
	_planned_at = INF
	_last_at = - INF
	_endless_next = float(data.endless_every)
	if GameData.has_meta("morroc_at"):
		_planned_at = float(GameData.get_meta("morroc_at"))
	elif world.autopilot or world.showcase or world.danger < int(data.min_danger):
		return
	elif randf() < float(data.chance) * GameData.MOD_MORROC_SPAWN:
		var latest: = world.mvp_at() - float(data.mvp_gap) - float(data.omen)


		if latest > float(data.from):
			_planned_at = randf_range(float(data.from), minf(latest, float(data.from) + float(data.get("window", 1000000000.0))))





func save_state() -> Dictionary:
	return {"planned_at": _planned_at if is_finite(_planned_at) else -1.0, "last_at": _last_at if is_finite(_last_at) else -1000000000.0, 
		"endless_next": _endless_next, "finale_done": _finale_done, "stats": stats.duplicate()}


func restore_state(d: Dictionary) -> void :
	if d.is_empty():
		return
	var at: = float(d.get("planned_at", -1.0))
	_planned_at = at if at >= 0.0 else INF
	_last_at = float(d.get("last_at", -1000000000.0))
	_endless_next = float(d.get("endless_next", _endless_next))
	_finale_done = bool(d.get("finale_done", false))
	if d.get("stats") is Dictionary:
		stats.merge(d.stats, true)



func _use(d: Dictionary, is_finale: bool) -> void :
	data = d
	ymir_at = float(d.get("ymir_at", GameData.RAID_YMIR_TIME))
	color = d.color
	mvp = str(d.mob)
	finale = is_finale


func _schedule() -> void :
	if world.endless and not _finale_done and world.tower == null:
		_finale_schedule()
		if finale_due():
			return

	if world.endless and not GameData.has_meta("morroc_at") and not world.autopilot and world.danger >= int(data.min_danger) and world.time >= _endless_next\
	and world.time < finale_at() - float(data.endless_gap) * 0.5:
		_endless_next = world.time + float(data.endless_every)
		if world.time - _last_at >= float(data.endless_gap) and randf() < float(data.endless_chance) * GameData.MOD_MORROC_SPAWN:
			_planned_at = world.time
	if world.time < _planned_at:
		return
	if not world.endless and not GameData.has_meta("morroc_at")\
	and world.time > world.mvp_at() - float(data.mvp_gap) - float(data.omen):

		_planned_at = INF
		return
	if not _can_start():
		_planned_at = world.time + float(data.retry)
		return
	var spot: = _find_arena()
	if spot.is_empty():
		_planned_at = world.time + float(data.retry)
		return
	_planned_at = INF






	if not finale:
		_last_at = world.time
		stats.seen = true
		RunSave.save(world)
	_begin_omen(spot[0], spot[1])




func _finale_schedule() -> void :
	if world.net.is_client() or (world.autopilot and not GameData.has_meta("finale_at")) or world.training or world.festival_mode:
		return
	var fin: Dictionary = GameData.MORROC_FINALE
	var warns: Array = fin.warn_at
	var at: = finale_at()
	while _finale_warned < warns.size() and world.time >= at - float(warns[_finale_warned]):

		if world.time < at - float(warns[_finale_warned]) + 20.0:

			world.raid._warn(str(fin.teasers[_finale_warned]), fin.color, "warning")
		_finale_warned += 1
	if world.time < at or world.clock < _finale_retry:
		return
	_finale_retry = world.clock + float(fin.retry)




	if world.time >= at + float(fin.force_after) and _can_start(true):
		if world.boss != null and is_instance_valid(world.boss) and not world.boss.dead:
			world.banish_enemy(world.boss)
		world.boss = null
		if world.runner != null and is_instance_valid(world.runner):
			world.banish_enemy(world.runner)
		world.runner = null
	if not _can_start():
		var why: = _wait_reason()
		if why != _finale_why:
			_finale_why = why
			print("FINALE waits at %d s: %s" % [roundi(world.time), why])
		return
	_use(fin, true)
	var spot: = _find_arena()



	_finale_fails += 1 if spot.is_empty() else 0
	if spot.is_empty() and _finale_fails >= 3:
		for h in world.alive_heroes():
			spot = _find_arena(h.position, float(fin.min_radius) * (0.8 if _finale_fails < 8 else 0.6))
			if not spot.is_empty():
				break
	if spot.is_empty() and _finale_fails >= 12:
		var here: = world.player.position
		spot = [Vector3(here.x, world.map.height_at(here), here.z), maxf(12.0, _open_radius(here, float(fin.radius)))]
	if spot.is_empty():
		if _finale_fails % 4 == 1:
			world.raid._warn(UiKit.tr_later("El final de Infinito espera: busca un lugar abierto"), fin.color)
		_use(GameData.MORROC, false)
		return
	_finale_done = true
	_begin_omen(spot[0], spot[1])






func _can_start(field_ok: = false) -> bool:
	if not world.running or world.town != null or world.player == null:
		return false
	if world.net.is_client():
		return false

	if world.tower != null:
		return false
	if world.raid.active() or ( not field_ok and (world.boss != null or world.runner != null)):
		return false
	if world.quest.state in ["offer", "active"]:
		return false
	for h in world.heroes:
		if h.downed:
			return false
	return true



func _wait_reason() -> String:
	if world.raid.active():
		return "raid " + str(world.raid.state)
	if world.boss != null:
		return "boss " + (str(world.boss.id) if is_instance_valid(world.boss) else "(freed)")
	if world.runner != null:
		return "golden poring"
	if world.quest.state in ["offer", "active"]:
		return "quest"
	return "hero down" if world.heroes.any( func(h): return h.downed) else "other"




func _find_arena(near = null, min_r: = -1.0) -> Array:
	var want: = float(data.radius)
	var best: = Vector3.INF
	var best_r: = 0.0
	var at: Vector3 = world.player.position if near == null else near
	var reach: = float(data.search)
	for ring: float in [0.0, reach * 0.5, reach]:
		var n: = 1 if ring == 0.0 else 8
		for i in n:
			var a: = TAU * i / float(n)
			var c: = at + Vector3(cos(a), 0, sin(a)) * ring
			if not world.map.is_walkable(c):
				continue
			var r: = _open_radius(c, want)
			if r > best_r + 0.5:
				best_r = r
				best = c
		if best_r >= want:
			break
	if best == Vector3.INF or best_r < (min_r if min_r > 0.0 else float(data.min_radius)):
		return []
	best.y = world.map.height_at(best)
	return [best, best_r]


func _open_radius(c: Vector3, want: float) -> float:
	var r: = 2.0
	while r <= want + 0.01:
		var blocked: = 0
		for i in 24:
			var a: = TAU * i / 24.0
			if not world.map.is_walkable(c + Vector3(cos(a), 0, sin(a)) * r):
				blocked += 1



		if blocked > 6:
			return r - 2.0
		r += 2.0
	return want




func tick(delta: float) -> void :
	match state:
		"idle":
			_schedule()
		"omen":
			_tick_omen(delta)
		"fall":
			_tick_fall(delta)
		"fight":
			_tick_fight(delta)






func _dps() -> float:

	return world.tank_dps(world.party_dealt() / maxf(30.0, world.measure_time())) * 1.3




func _begin_omen(at: Vector3, r: float) -> void :
	state = "omen"
	stats.seen = true
	center = at
	radius = r
	_omen = _omen_time()
	_tick_count = -1
	_last_at = world.time
	_omen_show()
	if world.net.recording():
		world.net.morroc_event(["omen", center, radius, finale, level])




func _omen_show() -> void :
	_build_layer()
	_darken(true)
	if finale and level > 1:

		world.hud.alerts.warn(tr(str(data.again.warn)) % roman(level), color, "warning")
		world.play_music_map("finale")
	elif finale:
		world.hud.alerts.warn(tr(str(data.warn)), color, "warning")

		world.play_music_map("finale")
		_talk_show()
	else:
		world.hud.alerts.warn(tr("Una presencia maligna se aproxima...: algo terrible caerá del cielo"), color, "warning")
	world.play_mob_sound(mvp, "attack")
	world.shake(0.4)
	world.emote(world.player, "omg", 2.5)


	_arena = Node3D.new()
	world.fx_root.add_child(_arena)
	_arena.global_position = center
	var under: = GameData.MVP_UNDER_PRIORITY

	Vfx.magic_circle(_arena, Vector3.ZERO, radius * 0.98, Color(color, 0.35), 0.0, "mvp_rune", 0.08, under, true)
	Vfx.magic_circle(_arena, Vector3.ZERO, radius * 0.55, Color(color.lightened(0.2), 0.3), 0.0, "mvp_hexa", -0.15, under, true)
	var edge: = Vfx._flat(_arena, Vfx.ring_texture(), Vector3.ZERO, radius + 0.4, Color(color, 0.0))
	edge.no_depth_test = true
	edge.name = "Edge"
	var tw: = edge.create_tween().set_loops()
	tw.tween_property(edge, "modulate:a", 0.25, 1.0).set_trans(Tween.TRANS_SINE)
	tw.tween_property(edge, "modulate:a", 0.5, 1.0).set_trans(Tween.TRANS_SINE)
	var lbl: = world.raid._label(_arena, tr(str(data.caption)) if finale else tr("Satan Morroc caerá aquí"), Color(1.0, 0.55, 0.45), 1.2, 30)
	lbl.name = "Caption"


func _tick_omen(delta: float) -> void :
	_omen -= delta
	var total: = _omen_time()
	var k: = clampf(1.0 - _omen / total, 0.0, 1.0)

	_veil.modulate.a = 0.08 + 0.25 * k
	var secs: = ceili(maxf(0.0, _omen))
	_count.text = (tr(str(data.count_text)) if finale else tr("Satan Morroc desciende en  %d")) % secs
	if finale:
		_talk_tick(k)
	if secs != _tick_count:
		_tick_count = secs
		_on_second(secs)

	if randf() < delta * (1.5 + 6.0 * k):
		world.spawn_fx("hell_in", _inside(0.9), 0.7 + k * 0.4, 0.5)

	if _omen <= 0.0 and state == "omen":
		_start_fall()


func _on_second(secs: int) -> void :
	if secs <= 5 and secs > 0:
		world.play_sound("beginspell", 0.0, -6.0 + (5 - secs))
		world.shake(0.15 + 0.06 * (5 - secs))
		var tw: = _count.create_tween()
		_count.pivot_offset = _count.size * 0.5
		_count.scale = Vector2.ONE * 1.35
		tw.tween_property(_count, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if secs == 10:

		world.hud.alerts.warn(tr(str(data.warn2)) if finale else tr("El cielo se oscurece: Satan Morroc caerá en el círculo"), color)
	if secs == 3:

		Vfx.telegraph_circle(world.fx_root, center, float(data.impact), 3.0)
		world.hud.alerts.warn(tr("¡Aléjate del centro!: su caída aplasta a quien esté debajo"), Color(1, 0.35, 0.3))


func _start_fall() -> void :
	state = "fall" if not world.net.is_client() else "c_fall"
	_fall = 1.3
	if world.net.recording():
		world.net.morroc_event(["fall"])
	_count.visible = false
	_talk_hide()
	world.play_sound("beginspell", 0.0, 0.0)
	_faller = RoVisual.new()
	world.fx_root.add_child(_faller)
	_faller.setup(RoAssets.sprite([mvp]), GameData.MONSTERS[mvp].color, int(GameData.MONSTERS[mvp].size_px), 0.0)
	_faller.scale = Vector3.ONE * GameData.MVP_SCALE
	_faller.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	_faller.sprite.render_priority = GameData.MVP_PRIORITY
	_faller.play(RoVisual.MOB_ATTACK, true)
	_faller.face(Vector3(0, 0, 1))
	_faller.global_position = center + Vector3(0, 16.0, 0)
	var tw: = _faller.create_tween()
	tw.tween_property(_faller, "global_position", center, _fall).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _tick_fall(delta: float) -> void :
	_fall -= delta
	if _faller != null and is_instance_valid(_faller) and randf() < 0.5:
		_afterimage(_faller)
	if _fall <= 0.0:
		_impact()




func _impact() -> void :
	if world.net.recording():
		world.net.morroc_event(["impact"])
	_impact_show()

	for h in world.alive_heroes():
		var d: = _flat(h.position, center)
		if d < float(data.impact):
			_hit_pct(h, float(data.impact_pct))
			_push(h, _dir(center, h.position) * (float(data.impact) + 1.0 - d))
		elif d > radius - 1.0:
			Vfx.column(world.fx_root, h.position, color)
			h.position = _into_arena(_dir(center, h.position), radius - 2.0)
			Vfx.column(world.fx_root, h.position, color)
			world.play_sound("teleport", 0.1, -4.0)
	if world.pet != null:
		world.pet.position = world.player.position + Vector3(1, 0, 0.5)

	for sh in world.enemy_shots:
		if sh.has("node") and is_instance_valid(sh.node):
			sh.node.queue_free()
	world.enemy_shots.clear()
	_shock = float(data.impact)
	_spawn_boss()
	_build_arena()



func _impact_show() -> void :
	if _faller != null and is_instance_valid(_faller):
		_faller.queue_free()
	_faller = null
	world.fx_layer(GameData.MVP_FX_PRIORITY)
	world.shake(1.2)
	world.hud.flash(Color(0.6, 0.05, 0.05), 0.6)
	world.play_sound("earth_quake", 0.0, 2.0)
	world.play_sound("meteor", 0.0, 0.0)
	world.play_mob_sound(mvp, "attack")
	world.spawn_fx("hell_in", center, 2.4)
	world.spawn_fx("meteor1", center, 1.6, 0.8)
	Vfx.burst(world.fx_root, center, float(data.impact) * 1.6, color)
	for i in 4:
		Vfx.ring(world.fx_root, center, radius * (0.4 + 0.2 * i), Color(color.lightened(0.3), 0.9 - 0.15 * i), 0.45 + 0.15 * i)
	for i in 10:
		var a: = TAU * i / 10.0
		world.spawn_fx("firepillar", center + Vector3(cos(a), 0, sin(a)) * float(data.impact) * 1.3, 0.9, 0.6)
	world.fx_layer(0)


func _spawn_boss() -> void :
	boss = world.spawn_enemy(mvp, center, true)
	if boss == null:
		if finale and level > 1:

			level -= 1
			_end()
			world._end_run(true)
			return
		_end()


		_use(GameData.MORROC, false)
		return
	_own.append(boss)
	boss.brain = null



	var floor_hp: = float(data.min_hp) * GameData.danger_hp(world.danger)
	if world.is_coop():
		floor_hp *= GameData.coop_hp(world.heroes.size(), "mvp")
	boss.max_hp = maxf(floor_hp, _dps() * float(data.tank))

	boss.max_hp *= 1.0 - GameData.MORROC_HP_EASE * clampf(float(world.danger - 1) / float(GameData.DANGER_HELL10 - 1), 0.0, 1.0)

	boss.max_hp *= GameData.oath_value("tough", world.oath("tough"))
	boss.hp = boss.max_hp


	ymir_at = float(data.ymir_at)
	if world.pride_on():
		var keep: = world.pride_resist(boss.max_hp)
		if keep < 1.0:
			boss.set_meta("pride", keep)
		ymir_at = minf(ymir_at, GameData.PRIDE_YMIR)
	boss.damage *= GameData.MVP_RAID_DMG

	if finale and level > 1:
		boss.max_hp *= pow(float(data.again.hp), level - 1)
		boss.hp = boss.max_hp
		boss.damage *= pow(float(data.again.dmg), level - 1)
	_calm_damage = boss.damage

	boss.hold = 0.6
	world.boss = boss
	state = "fight"
	phase = 0
	ymir = 0.0
	_fight_t = 0.0
	_vuln = 0.0
	_judge_in = false
	_timers.clear()
	for ab in data.abilities:
		if ab.phases.has(0):
			_timers[ab.id] = float(ab.first)
	var re: = finale and level > 1
	world.raid._chat(boss, tr(str(data.again.intro if re else data.intro)))
	world.raid._announce(tr("MVP: %s") % (boss_title(boss) if re else tr(GameData.MONSTERS[mvp].name)), color.lightened(0.3), 
		tr(str(data.again.sub if re else data.sub)) if finale else tr("¡Derrótalo para que el Ragnarok espere!"))

	var near: = world.enemies.filter( func(e): return not _own.has(e))
	near.sort_custom( func(a, b): return _flat(a.position, center) < _flat(b.position, center))
	for i in mini(10, near.size()):
		if randf() < 0.7:
			world.emote(near[i], ["omg", "question", "sweat", "surprise"].pick_random(), 2.4)



func _build_arena() -> void :
	if _arena == null or not is_instance_valid(_arena):
		return
	var caption: = _arena.get_node_or_null("Caption")
	if caption != null:
		caption.queue_free()
	var edge: = _arena.get_node_or_null("Edge") as Sprite3D
	if edge != null:
		edge.modulate.a = 0.55
	for i in 24:
		var a: = TAU * i / 24.0
		var p: = Vector3(cos(a), 0, sin(a)) * (radius + 0.3)
		p.y = world.map.height_at(center + p) - center.y
		Vfx.beam(_arena, p, color, 3.2)




func _tick_fight(delta: float) -> void :
	_shockwave(delta)
	_keep_out()
	_clamp_heroes()
	if boss == null or not is_instance_valid(boss) or boss.dead:
		return
	world.fx_layer(GameData.MVP_FX_PRIORITY)
	stats.time += delta
	_tick_ymir(delta)

	if not _growing():
		_vuln = maxf(0.0, _vuln - delta)
	if not _airborne:
		_clamp(boss, radius - 1.0)
		var phases: Array = data.phases
		if phase + 1 < phases.size() and boss.hp / boss.max_hp <= float(phases[phase + 1]):
			_enter_phase(phase + 1)
	if boss.status == "stun":


		pass
	elif not _cast.is_empty():
		_cast.t -= delta

		if _cast.ab.mech == "judgement" and not _cast["in"]:
			for h in world.alive_heroes():
				var d: = _flat(h.position, boss.position)
				if d > 0.8:
					_push(h, _dir(h.position, boss.position) * minf(d - 0.8, h.move_speed * float(_cast.ab.get("pull", 0.45)) * delta))
		_update_cast_bar()
		if _cast.t <= 0.0:
			var c: = _cast
			_cast = {}
			_update_cast_bar()
			_resolve(c)
	elif not _airborne and _vuln <= 0.0 and not _objects.any( func(o): return o.kind in ["dive", "dash", "grow"]):
		var ready: Dictionary = {}
		for ab in data.abilities:
			if not ab.phases.has(phase):
				continue
			_timers[ab.id] = float(_timers.get(ab.id, ab.first)) - delta * _ymir_cast()
			if _timers[ab.id] <= 0.0 and (ready.is_empty() or _timers[ab.id] < _timers[ready.id]):
				ready = ab
		if not ready.is_empty():
			_timers[ready.id] = float(ready.every) * (0.8 if phase == data.phases.size() - 1 else 1.0)\
			* (float(GameData.HARD.raid_every) if world.hard else 1.0) * world.mvp_cast()
			_start(ready)
	_update_objects(delta)
	stats.phase = phase
	world.fx_layer(0)




func _shockwave(delta: float) -> void :
	if _shock < 0.0:
		return
	_shock += delta * 30.0
	var r: = minf(_shock, radius + 0.5)
	for e in world.enemies.duplicate():
		if _own.has(e) or e.dead:
			continue
		if _flat(e.position, center) < r:
			e.last_hit_by = world.player
			world._kill(e)
	if _shock >= radius + 0.5:
		_shock = -1.0




func _keep_out() -> void :
	if _shock >= 0.0:
		return
	for e in world.enemies:
		if _own.has(e):
			continue
		var d: = (e.position - center) * Vector3(1, 0, 1)
		var keep: = radius + e.radius + 0.2
		if d.length() < keep:
			var at: = center + (d.normalized() if d.length() > 0.01 else Vector3(1, 0, 0)) * keep
			if world.map.is_walkable(at):
				e.position = Vector3(at.x, world.map.height_at(at), at.z)


func _clamp_heroes() -> void :
	for h in world.heroes:
		_clamp(h, radius - 0.4)


func _tick_ymir(delta: float) -> void :
	_fight_t += delta

	boss.damage = _calm_damage * ymir_mvp_mult() * (1.0 + float(boss.get_meta("rage", 0.0)))
	if _fight_t < ymir_at:
		return
	if ymir <= 0.0:
		world.raid._announce(tr("¡El Corazón de Ymir despierta!"), Color(0.75, 0.45, 1.0), 
			tr("Tú y %s pegan cada vez más fuerte, pero tú creces más rápido: ¡termínalo!") % tr(GameData.MONSTERS[mvp].name))
		world.play_mob_sound(mvp, "attack")
		world.play_sound("warning", 0.0, 0.0)
		world.shake(0.8)
		Vfx.ring(world.fx_root, center + Vector3(0, 0.1, 0), radius, Color(0.6, 0.25, 1.0), 1.4)
		world.spawn_fx("joblvup", world.player.position, 1.0, 0.8, world.player)
		if _arena != null and is_instance_valid(_arena):
			Vfx.magic_circle(_arena, Vector3.ZERO, radius * 0.95, Color(0.6, 0.25, 1.0, 0.3), 0.0, "mvp_rune", 0.12)
		var glow: = Vfx.ground_glow(boss, Vector3(0, 0.05, 0), boss.radius * 3.2, Color(0.6, 0.15, 1.0, 0.7))
		glow.render_priority = GameData.MVP_UNDER_PRIORITY
		var tw: = glow.create_tween().set_loops()
		tw.tween_property(glow, "modulate:a", 0.3, 0.35).set_trans(Tween.TRANS_SINE)
		tw.tween_property(glow, "modulate:a", 0.9, 0.35).set_trans(Tween.TRANS_SINE)

	ymir += delta * GameData.ymir_rate(_fight_t - ymir_at)
	_ymir_fx -= delta
	if _ymir_fx <= 0.0:
		_ymir_fx = maxf(0.4, 1.4 - ymir * 0.01)
		world.spawn_fx("hell_in", _inside(0.9), 0.8, 0.5)


func _enter_phase(n: int) -> void :
	phase = n
	_clear_cast()
	var shouts: Array = data.phase_shouts
	if n < shouts.size() and str(shouts[n]) != "":
		world.raid._chat(boss, tr(str(shouts[n])))
	world.play_sound("warning", 0.0, -2.0)
	world.play_mob_sound(mvp, "attack")
	world.shake(0.5)
	for ab in data.abilities:
		if ab.phases.has(n) and not ab.phases.has(n - 1):
			_timers[ab.id] = float(ab.first)
	if n == 1:
		world.raid._big(tr("Fase 2"), tr("Las cuatro encarnaciones: ¡destrúyelas antes de que vuelva!"), color)
		_ascend()
	elif finale and data.has("adult"):
		world.raid._big(tr("Fase %d") % (n + 1), tr(str(data.grow)), color)
		_grow()
	else:
		world.raid._big(tr("Fase %d") % (n + 1), tr("%s se enfurece: pega más fuerte") % tr(GameData.MONSTERS[mvp].name), color)
		boss.damage *= float(data.enrage)
		Vfx.burst(world.fx_root, boss.position, 5.0, color)
		world.spawn_fx("hell_in", boss.position, 1.8)
		for h in world.alive_heroes():
			_push(h, _dir(boss.position, h.position) * 2.0)




func _start(ab: Dictionary) -> void :
	var lethal: bool = ab.get("lethal", false)
	var name_id: = str(ab.name)
	var alert: = str(ab.get("alert", ""))
	if ab.mech == "judgement":
		if phase >= 1:
			_judge_in = not _judge_in
		else:
			_judge_in = false
		if _judge_in:
			name_id = str(ab.alt)
			alert = str(ab.alt_alert)
	if alert != "":
		world.raid._warn(alert, Color(1, 0.35, 0.3) if lethal else Color(1, 0.85, 0.4), "warning" if lethal else "party_alarm")
	world.raid._shout(boss, tr("%s!!") % tr(name_id))
	var cast: = float(ab.get("cast", 0.0))
	var target: = _target_hero()
	match ab.mech:
		"cone":
			var dir: = _dir(boss.position, target.position)
			var tell: = Vfx.telegraph_cone(world.fx_root, boss.position, dir, float(ab.radius), float(ab.angle), cast)
			boss.hold = cast + 0.25
			_cast = {"ab": ab, "t": cast, "total": cast, "dir": dir, "name": name_id, "tells": [tell]}
		"spokes":

			boss.position = Vector3(center.x, world.map.height_at(center), center.z)
			var base: = randf() * TAU
			var tells: = _spokes_tell(base, int(ab.count), float(ab.width), cast)
			_begin_cast_tell(name_id, cast)
			_cast = {"ab": ab, "t": cast, "total": cast, "base": base, "name": name_id, "tells": tells}
		"judgement":
			_begin_cast_tell(name_id, cast)
			var zone: Node3D = null
			var tells: Array = []
			if _judge_in:

				tells.append(Vfx.telegraph_circle(world.fx_root, center, radius, cast))
				zone = world.raid._zone(boss.position, float(ab.safe), Color(0.55, 1.0, 0.6), "")

				for n in zone.find_children("*", "", true, false):
					if n is SpriteBase3D:
						n.render_priority = Vfx.DANGER_PRIORITY + 1
					elif n is MeshInstance3D and n.material_override is BaseMaterial3D:
						n.material_override.render_priority = Vfx.DANGER_PRIORITY + 1
			else:

				var tell: = Vfx.telegraph_circle(world.fx_root, boss.position, float(ab.out), cast)
				for n in tell.get_children():
					if n is Node3D and n.name != "Fill":
						var full: Vector3 = n.scale
						n.scale = full * 0.4
						n.create_tween().tween_property(n, "scale", full, cast * 0.9).set_trans(Tween.TRANS_SINE)
				tells.append(tell)
				world.spawn_fx("hell_in", boss.position, 1.4, 0.8)
			_cast = {"ab": ab, "t": cast, "total": cast, "in": _judge_in, "zone": zone, "at": boss.position, "name": name_id, 
				"tells": tells}
		"seal":
			var node: = Node3D.new()
			target.add_child(node)

			var head: = world.raid.head_timer(target, node, Color(0.75, 0.2, 1.0), float(ab.size), Color(0.75, 0.2, 1.0, 0.75), 1.6)
			world.spawn_fx("devil", target.position, 0.8, 0.8, target)
			world.play_sound("lex_aeterna", 0.0, -2.0)
			world.emote(target, "sweat", 1.5)
			_objects.append({"kind": "seal", "hero": target, "t": float(ab.time), "node": node, "label": head.label, "sigil": head.sigil, "ab": ab})
		"dive":
			_objects.append({"kind": "dive", "left": int(ab.count), "t": 0.0, "ab": ab})
		"volley":
			_begin_cast_tell(name_id, cast)
			_cast = {"ab": ab, "t": cast, "total": cast, "name": name_id, "tells": []}
		"orbit":
			_orbit_start(ab)



var _now_name: = ""
func _resolve(c: Dictionary) -> void :
	var ab: Dictionary = c.ab
	_now_name = str(c.get("name", ab.get("name", "")))

	world.raid._drop_tells(c.get("tells", []))
	match ab.mech:
		"cone":
			Vfx.strike_cone(world.fx_root, boss.position, c.dir, float(ab.radius), float(ab.angle), color.lightened(0.15))
			world.spawn_fx(str(ab.get("fx", "")), boss.position + (c.dir as Vector3) * float(ab.radius) * 0.45, 1.6)
			world.play_mob_sound(mvp, "attack")
			world.play_sound("brandish", 0.0, -2.0)
			for h in world.alive_heroes():
				var to: = (h.position - boss.position) * Vector3(1, 0, 1)
				if to.length() < float(ab.radius) and absf((c.dir as Vector3).signed_angle_to(to.normalized(), Vector3.UP)) < float(ab.angle) * 0.5:
					_hit_dmg(h, float(ab.dmg))
			world.shake(0.3)
		"spokes":
			_spokes_hit(float(c.base), ab)

			var base: = float(c.base) + PI / float(ab.count)
			var wave: = {"kind": "wave", "t": float(ab.wave), "base": base, "ab": ab, "tells": []}
			_objects.append(wave)

			_later(world.raid.WAVE_TELL_DELAY, func():
				if is_instance_valid(boss):
					wave.tells = _spokes_tell(base, int(ab.count), float(ab.width), maxf(0.1, float(wave.t))))
		"judgement":
			world.play_mob_sound(mvp, "attack")
			world.play_sound("meteor", 0.0, 0.0)
			world.shake(0.9)
			if c["in"]:
				for i in 8:
					world.spawn_fx("hell_in", _inside(0.85), 1.2, 0.6)
				Vfx.strike_circle(world.fx_root, center, radius, color)
			else:
				world.spawn_fx("hell_in", boss.position, 2.2)
				Vfx.strike_circle(world.fx_root, boss.position, float(ab.out), color)
			for h in world.alive_heroes():
				var d: = _flat(h.position, c.at)
				var hit: bool = d > float(ab.safe) if c["in"] else d < float(ab.out)
				if hit:
					_hit_pct(h, float(ab.pct))
				else:
					world.number(h.position + Vector3(0, 1.6, 0), tr("¡A salvo!"), Color(0.6, 1, 0.7))
			if c.zone != null and is_instance_valid(c.zone):
				world.raid._fade(c.zone, 0.4)
		"volley":
			_volley(ab)



func _spokes_tell(base: float, count: int, width: float, t: float) -> Array:
	var tells: = []
	for i in count:
		var a: = base + TAU * i / float(count)
		tells.append(Vfx.telegraph_line(world.fx_root, boss.position, Vector3(cos(a), 0, sin(a)), radius * 2.2, width, t))
	return tells


func _spokes_hit(base: float, ab: Dictionary) -> void :
	var count: = int(ab.count)
	world.play_sound("earth_quake", 0.1, -4.0)
	world.play_sound("fire_pillar", 0.1, -6.0)
	world.shake(0.4)
	for i in count:
		var a: = base + TAU * i / float(count)
		var dir: = Vector3(cos(a), 0, sin(a))

		Vfx.strike_line(world.fx_root, boss.position, dir, radius * 2.2, float(ab.width), Color(1.0, 0.4, 0.2))
		var step: = 1.5
		while step < radius * 2.0:
			var at: = boss.position + dir * step
			if _flat(at, center) > radius:
				break
			_later(step * 0.012, func(): world.spawn_fx("firepillar", at, 0.85, 0.7))
			step += 1.8
	for h in world.alive_heroes():
		var to: = (h.position - boss.position) * Vector3(1, 0, 1)
		for i in count:
			var a: = base + TAU * i / float(count)
			var dir: = Vector3(cos(a), 0, sin(a))
			var along: = to.dot(dir)
			if along > 0.0 and absf(to.cross(dir).y) < float(ab.width) * 0.5 + h.radius:
				_hit_dmg(h, float(ab.dmg))
				break





func _ascend() -> void :
	var inc: Dictionary = data.incarnations
	_drop_orbits()
	_airborne = true
	world.enemies.erase(boss)
	world.poisoned.erase(boss)
	world._grid_fresh = false
	world.dots.forget(boss)
	boss.hold = 999.0
	Vfx.column(world.fx_root, boss.position, color)
	world.spawn_fx("hell_in", boss.position, 1.8)
	world.play_mob_sound(mvp, "attack")
	var tw: Tween = boss.visual.create_tween()
	tw.tween_property(boss.visual, "position:y", 16.0, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var adds: Array = []
	for i in 4:
		var a: = TAU * (i + 0.5) / 4.0
		var at: = center + Vector3(cos(a), 0, sin(a)) * radius * 0.6
		if not world.map.is_walkable(at):
			at = world.map.random_point_around(at, 1.5)
		Vfx.magic_circle(world.fx_root, at, 1.3, Color(color.lightened(0.3), 0.85), 1.2, "mvp_hexa", 2.5)
		Vfx.column(world.fx_root, at, color)
		var e: = world.spawn_enemy("morroc_incarnation_%d" % (i + 1), at, true)
		if e == null:
			continue
		e.summoned = true
		e.max_hp = boss.max_hp * float(inc.hp)
		e.hp = e.max_hp
		e.visual.play(RoVisual.MOB_IDLE)
		_own.append(e)
		Vfx.beam(e, Vector3.ZERO, color, 14.0)
		var count: = world.raid._label(e, "", Color(1.0, 0.6, 0.5), 2.6, 36)
		count.name = "Count"
		adds.append(e)
	if not adds.is_empty():
		world.raid._chat(adds[0], tr("Nuestro señor volverá..."), Color(1.0, 0.7, 0.65))
	_objects.append({"kind": "incarn", "t": float(inc.time), "adds": adds, "rain": 1.5})


func _update_incarn(o: Dictionary, delta: float) -> bool:
	var inc: Dictionary = data.incarnations
	o.t -= delta
	var left: Array = o.adds.filter( func(e): return is_instance_valid(e) and not e.dead)
	for e in left:
		var l: = e.get_node_or_null("Count") as Label3D
		if l != null:
			l.text = "%d" % ceili(maxf(0.0, o.t))

	o.rain -= delta
	if o.rain <= 0.0:
		o.rain = float(inc.rain_every)
		for h in world.alive_heroes():
			var at: = h.position
			Vfx.telegraph_circle(world.fx_root, at, float(inc.rain_size), 1.3)
			_objects.append({"kind": "rain", "t": 1.3, "pos": at})
	if left.is_empty() or o.t <= 0.0:
		_descend(left)
		return true
	return false




func _descend(left: Array) -> void :
	var inc: Dictionary = data.incarnations
	for e in left:
		Vfx.beam_flash(world.fx_root, e.position, color, 14.0, 1.2)
		world.spawn_fx("hell_in", e.position, 1.2)
		world.banish_enemy(e)
	var n: = left.size()
	if n > 0:
		boss.hp = minf(boss.max_hp, boss.hp + boss.max_hp * float(inc.heal) * n)
		boss.set_meta("rage", float(boss.get_meta("rage", 0.0)) + 0.1 * n)
		world.number(center + Vector3(0, 3.0, 0), "+%d" % roundi(boss.max_hp * float(inc.heal) * n), Color(0.5, 1, 0.5), true)
		world.raid._warn(UiKit.tr_later("Las encarnaciones lo fortalecen: %d en pie"), Color(1, 0.35, 0.3), "warning", [n])
	else:
		world.raid._warn(UiKit.tr_later("¡Encarnaciones destruidas!: Satan Morroc caerá aturdido"), Color(0.6, 1, 0.6), "party_alarm")
	var target: = _target_hero()
	var at: Vector3 = target.position if target != null else center
	at = center + (at - center).limit_length(radius - 2.0)
	at.y = world.map.height_at(at)
	boss.position = at
	var size: = float(inc.crash_size)
	Vfx.telegraph_circle(world.fx_root, at, size, 1.3)
	var tw: Tween = boss.visual.create_tween()
	tw.tween_property(boss.visual, "position:y", 0.0, 1.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	world.play_sound("beginspell", 0.0, -2.0)
	_objects.append({"kind": "crash", "t": 1.3, "pos": at, "n": n})


func _land(o: Dictionary) -> void :
	var inc: Dictionary = data.incarnations
	_airborne = false
	boss.visual.position.y = 0.0
	if not world.enemies.has(boss):
		world.enemies.append(boss)
	world._grid_fresh = false
	boss.hold = 0.6
	var at: Vector3 = o.pos
	world.shake(1.0)
	world.play_sound("earth_quake", 0.0, 0.0)
	world.play_mob_sound(mvp, "attack")
	world.spawn_fx("hell_in", at, 2.0)
	Vfx.burst(world.fx_root, at, float(inc.crash_size) * 1.3, color)
	Vfx.ring(world.fx_root, at, float(inc.crash_size) * 1.6, Color(1, 0.85, 0.7), 0.5)
	for h in world.alive_heroes():
		var d: = _flat(h.position, at)
		if d < float(inc.crash_size):
			_hit_pct(h, float(inc.crash_pct) + float(inc.crash_extra) * int(o.n))
			_push(h, _dir(at, h.position) * (float(inc.crash_size) + 1.0 - d))
	if int(o.n) == 0:
		_vuln = float(inc.stagger)
		boss.hold = _vuln
		world.raid._shout(boss, tr("¡Aturdido!"), Color(1, 0.8, 0.4))
		world.spawn_fx("stun", boss.position, 1.4, 1.0, boss)
		world.play_sound("stun", 0.0, 0.0)
		world.side_word(boss, tr("¡Vulnerable!"), Color(1.0, 0.85, 0.3))

	for ab in data.abilities:
		_timers[ab.id] = maxf(float(_timers.get(ab.id, 0.0)), 2.5)




func _update_objects(delta: float) -> void :
	for i in range(_objects.size() - 1, -1, -1):
		if i >= _objects.size():
			continue
		var o: Dictionary = _objects[i]
		var done: = false
		_now_name = str((o.get("ab", {}) as Dictionary).get("name", ""))
		match o.kind:
			"wave":
				o.t -= delta
				if o.t <= 0.0:
					world.raid._drop_tells(o.tells)
					_spokes_hit(float(o.base), o.ab)
					done = true
			"seal":
				o.t -= delta
				var h: Player = o.hero
				if not is_instance_valid(h) or h.downed:
					done = true
				else:
					world.raid.head_timer_tick(o.sigil, o.label, float(o.t), delta)
					if o.t <= 0.0:



						var at: = h.position
						var ab: Dictionary = o.ab
						Vfx.telegraph_circle(world.fx_root, at, float(ab.size), GameData.RAID_BRAND_GRACE)
						_later(GameData.RAID_BRAND_GRACE, func(): _seal_burst(at, ab))
						done = true
				if done:
					for key in ["node", "label"]:
						if is_instance_valid(o[key]):
							o[key].queue_free()
			"pool":
				o.t -= delta
				o.tick -= delta
				if o.tick <= 0.0:
					o.tick = 0.5
					for h in world.alive_heroes():
						if _flat(h.position, o.pos) < float(o.ab.size) * 0.9:

							world.set_meta("doom_tick", true)
							_hit_pct(h, float(o.ab.pool_pct))
							world.remove_meta("doom_tick")
				if o.t <= 0.0:
					world.raid._fade(o.node, 0.5)
					done = true
			"dive":
				o.t -= delta
				if o.t <= 0.0:
					if int(o.left) <= 0:
						done = true
					else:
						o.left = int(o.left) - 1
						var target: = _target_hero()
						var dir: = _dir(boss.position, target.position if target != null else center)
						var cast: = float(o.ab.cast)
						Vfx.telegraph_line(world.fx_root, boss.position, dir, radius * 1.6, float(o.ab.width), cast)
						world.play_sound("beginspell", 0.1, -6.0)
						boss.hold = cast + 0.7
						boss.visual.face(dir)
						_objects.append({"kind": "dash", "t": cast, "go": 0.6, "dir": dir, "hit": [], "ab": o.ab})
						o.t = cast + 0.75
			"dash":
				o.t -= delta
				if o.t <= 0.0:
					if not o.has("swoosh"):
						o["swoosh"] = true
						world.play_mob_sound(mvp, "attack")
						world.play_sound("brandish", 0.0, -4.0)
					o.go -= delta
					var dir: Vector3 = o.dir
					var step: = world.map.slide(boss.position, dir * 24.0 * delta)
					boss.position = Vector3(step.x, world.map.height_at(step), step.z)
					_clamp(boss, radius - 1.0)
					if boss.visual is RoVisual:
						_afterimage(boss.visual)
					for h in world.alive_heroes():
						if not o.hit.has(h) and _flat(h.position, boss.position) < boss.radius + 1.0:
							o.hit.append(h)
							_hit_dmg(h, float(o.ab.dmg))
					done = o.go <= 0.0
			"incarn":
				done = _update_incarn(o, delta)
			"rain":
				o.t -= delta
				if o.t <= 0.0:
					var size: = float(o.get("size", data.incarnations.rain_size))
					if o.get("skull", false):
						world.spawn_fx("hell_in", o.pos, 0.9, 0.6)
						Vfx.burst(world.fx_root, o.pos, size, Color(0.7, 0.4, 1.0))
						world.play_sound("fire_pillar", 0.15, -10.0)
					else:
						world.spawn_fx("meteor1", o.pos, 1.0, 0.7)
						Vfx.burst(world.fx_root, o.pos, size, color)
						world.play_sound("meteor", 0.15, -6.0)
					for h in world.alive_heroes():
						if _flat(h.position, o.pos) < size:
							_hit_dmg(h, float(o.get("dmg", data.incarnations.rain_dmg)))
					done = true
			"orbit":
				done = _orbit_tick(o, delta)
			"grow":
				o.t -= delta
				if boss != null and is_instance_valid(boss) and boss.visual is RoVisual and randf() < 0.35:
					_afterimage(boss.visual)
				if o.t <= 0.0:
					_grown()
					done = true
			"crash":
				o.t -= delta
				if o.t <= 0.0:
					_land(o)
					done = true
		if done:
			_objects.erase(o)



func _seal_burst(at: Vector3, ab: Dictionary) -> void :


	_now_name = str(ab.get("name", ""))
	world.spawn_fx("hell_in", at, 1.4)
	Vfx.burst(world.fx_root, at, float(ab.size), Color(0.7, 0.15, 0.9))
	world.play_sound("fire_pillar", 0.0, -2.0)
	world.shake(0.4)
	for o in world.alive_heroes():
		if _flat(o.position, at) < float(ab.size):
			_hit_dmg(o, float(ab.dmg))
	var pools: = _objects.filter( func(p): return p.kind == "pool")
	if pools.size() >= int(ab.pools):
		world.raid._fade(pools[0].node, 0.4)
		_objects.erase(pools[0])
	var node: = world.raid._zone(at, float(ab.size), Color(0.75, 0.05, 0.15), "")
	world.spawn_fx("venomdust", at, 1.0, 0.6, node)
	_objects.append({"kind": "pool", "pos": at, "node": node, "t": float(ab.pool), "tick": 0.5, "ab": ab})





func on_killed(e: Enemy) -> void :
	if e != boss:
		return
	if finale:
		_finale_won(e)
		return
	stats.won = true
	var at: = e.position
	world.raid._chat(e, tr(str(data.death)))


	world.raid._announce(tr("¡Victoria!"), Color(1, 0.9, 0.4), tr("Satan Morroc ha caído: el Ragnarok tendrá que esperar"))
	world._show_mvp_banner()
	world.emote(world.player, "grats")
	world.play_sound("drop_yellow", 0.0, -2.0)
	world._drop_chest(at, int(data.chest), 3, "", true)
	var hoard: = roundi(float(data.zeny) * GameData.danger_reward(world.danger))
	var coins: = int(data.coins)
	for i in coins:
		world._runner_coins(at, floori(float(hoard) / coins) + (hoard % coins if i == 0 else 0))

	for h in world.heroes:
		h.grant_levels(GameData.MORROC_LEVELS)
		world.spawn_fx("joblvup", h.position, 1.2, 1.0, h)
		world.label_over(h, tr("+%d niveles") % GameData.MORROC_LEVELS, Color(0.7, 0.9, 1.0))
	Save.bump("satan_morroc")
	world.get_tree().create_timer(1.2, false).timeout.connect(world._pull_prizes)
	_end()



func _end() -> void :
	if world.net.recording():
		world.net.morroc_event(["end"])
	_clear_mechanics()
	for e in _own:
		if is_instance_valid(e) and e != boss and not e.dead:
			world.banish_enemy(e)
	_own.clear()
	if world.boss == boss:
		world.boss = null
	boss = null
	_airborne = false
	_shock = -1.0
	ymir = 0.0
	state = "idle"
	_talk_hide()
	_darken(false)
	if _arena != null and is_instance_valid(_arena):
		var tw: = _arena.create_tween()
		tw.tween_property(_arena, "scale", Vector3.ONE * 1.15, 0.8)
		tw.parallel().tween_property(_arena, "position:y", _arena.position.y - 0.4, 0.8)
		tw.tween_callback(_arena.queue_free)
	_arena = null
	if _layer != null and is_instance_valid(_layer):
		var lt: = _layer.create_tween()
		lt.tween_property(_veil, "modulate:a", 0.0, 1.2)
		lt.tween_callback(_layer.queue_free)
	_layer = null




func net_event(ev: Array) -> void :
	match str(ev[0]):
		"omen":
			_use(GameData.MORROC_FINALE if ev.size() > 3 and bool(ev[3]) else GameData.MORROC, ev.size() > 3 and bool(ev[3]))
			state = "c_omen"
			center = ev[1]
			radius = float(ev[2])
			level = int(ev[4]) if ev.size() > 4 else 1
			_omen = _omen_time()
			_tick_count = -1
			_omen_show()
		"fall":
			if _layer != null and is_instance_valid(_layer):
				_start_fall()
		"impact":

			if _faller != null and is_instance_valid(_faller):
				_faller.queue_free()
			_faller = null
			world.shake(1.2)
			world.hud.flash(Color(0.6, 0.05, 0.05), 0.6)
			_build_arena()
			state = "c_fight"
		"end":
			_end()
		"skull":
			_skull_fall(ev[1], float(ev[2]))
		"orbit_end":
			_drop_orbits()
		"orbit":

			var mob: = _shown_boss()
			if mob != null:
				_objects.append(_orbit_object(ev[1], ev[2], mob))



func client_tick(delta: float) -> void :
	match state:
		"c_omen":
			_tick_omen(delta)
		"c_fall":
			if _faller != null and is_instance_valid(_faller) and randf() < 0.5:
				_afterimage(_faller)
		"c_fight":

			for i in range(_objects.size() - 1, -1, -1):
				if _objects[i].kind == "orbit" and _orbit_tick(_objects[i], delta):
					_objects.remove_at(i)






func net_promote() -> void :
	if state == "idle":
		return


	var ids: = [str(data.get("mob", "")), str(data.get("adult", ""))]
	for e in world.enemies.duplicate():
		if is_instance_valid(e) and (is_boss(e) or (e.id != "" and e.id in ids)):
			world.enemies.erase(e)
			e.queue_free()
	if world.boss != null and ( not is_instance_valid(world.boss) or world.boss.is_queued_for_deletion()):
		world.boss = null
	reset()
	print("MORROC promoted: his event starts over")


func reset() -> void :
	_clear_mechanics()
	_own.clear()
	boss = null
	_airborne = false
	_shock = -1.0
	ymir = 0.0
	state = "idle"
	_talk_hide()
	_restore_light()
	for n in [_arena, _faller, _layer]:
		if n != null and is_instance_valid(n):
			n.queue_free()
	_arena = null
	_faller = null
	_layer = null


func _clear_mechanics() -> void :
	_clear_cast()
	for o in _objects:
		for key in ["node", "label"]:
			if o.has(key) and is_instance_valid(o[key]):
				o[key].queue_free()
		for sk in o.get("skulls", []):
			if is_instance_valid(sk):
				sk.queue_free()
	_objects.clear()
	_vuln = 0.0






func _begin_cast_tell(spell: String, cast: float) -> void :
	boss.hold = maxf(boss.hold, cast + 0.3)
	if boss.visual is RoVisual:
		(boss.visual as RoVisual).play(RoVisual.MOB_ATTACK, true, true)
	world.play_sound("beginspell", 0.0, -2.0)
	var under: = GameData.MVP_UNDER_PRIORITY
	Vfx.magic_circle(world.fx_root, boss.position, 3.4, Color(color.lightened(0.2), 0.75), cast + 0.3, "mvp_rune", 0.9, under)
	Vfx.magic_circle(world.fx_root, boss.position, 2.0, Color(color.lightened(0.5), 0.8), cast + 0.3, "mvp_hexa", -2.4, under)
	if _cast_bar == null or not is_instance_valid(_cast_bar):
		_cast_bar = world.raid._label(boss, "", Color(1.0, 0.9, 0.55), 3.6, 30)
	_cast_bar.set_meta("spell", tr(spell))


func _update_cast_bar() -> void :
	if _cast_bar == null or not is_instance_valid(_cast_bar):
		return
	if _cast.is_empty():
		_cast_bar.queue_free()
		_cast_bar = null
		return
	var bars: = 12
	var filled: = clampi(roundi((1.0 - _cast.t / maxf(0.01, _cast.total)) * bars), 0, bars)
	_cast_bar.text = "%s\n%s" % [str(_cast_bar.get_meta("spell", "")), "▮".repeat(filled) + "▯".repeat(bars - filled)]


func _clear_cast() -> void :
	if _cast_bar != null and is_instance_valid(_cast_bar):
		_cast_bar.queue_free()
	_cast_bar = null
	if _cast.has("zone") and _cast.zone != null and is_instance_valid(_cast.zone):
		_cast.zone.queue_free()
	_cast = {}





func dbm_entries() -> Array:
	var out: = []
	if state != "fight":
		return out
	if not _cast.is_empty():
		out.append({"name": tr("» %s") % tr(str(_cast.name)), "left": maxf(0.0, _cast.t), "total": _cast.total, 
			"lethal": _cast.ab.get("lethal", false), "now": true}.merged(MvpRaid.dbm_more(_cast.ab)))
	for o in _objects:
		match o.kind:
			"incarn":
				var n: int = o.adds.filter( func(e): return is_instance_valid(e) and not e.dead).size()
				out.append({"name": tr("Encarnaciones x%d") % n, "left": maxf(0.0, o.t), 
					"total": float(data.incarnations.time), "lethal": true, "now": true})
			"seal":
				out.append({"name": tr("Sello de la Desesperación"), "left": maxf(0.0, o.t), "total": float(o.ab.time), 
					"lethal": true, "now": true})
			"orbit":
				out.append({"name": tr(str(o.ab.name)), "left": maxf(0.0, o.t), "total": float(o.ab.time), 
					"lethal": false, "now": true})
	if _vuln > 0.0:
		out.append({"name": tr("¡Vulnerable!"), "left": _vuln, "total": float(data.incarnations.stagger), "lethal": false, "now": true})
	var next: = []
	for ab in data.abilities:
		if ab.phases.has(phase) and (_cast.is_empty() or _cast.ab != ab):
			var shown: = str(ab.name)
			if ab.mech == "judgement" and phase >= 1 and not _judge_in:
				shown = str(ab.alt)
			next.append({"name": tr(shown), "left": maxf(0.0, float(_timers.get(ab.id, ab.first))), 
				"total": float(ab.every), "lethal": ab.get("lethal", false), "now": false}.merged(MvpRaid.dbm_more(ab)))
	next.sort_custom( func(a, b): return a.left < b.left)
	out.append_array(next)
	return out.slice(0, 7)



func autopilot_goal() -> Vector3:
	var p: = world.player
	match state:
		"omen":
			if _omen < 4.0 and _flat(p.position, center) < float(data.impact) + 1.5:
				return center + _dir(center, p.position) * (float(data.impact) + 3.5)
			return Vector3.INF
		"fight":
			pass
		_:
			return Vector3.INF
	for o in _objects:
		match o.kind:
			"crash", "rain":
				var size: = float(data.incarnations.crash_size if o.kind == "crash" else o.get("size", data.incarnations.rain_size))
				if _flat(p.position, o.pos) < size + 0.8:
					return p.position + _dir(o.pos, p.position) * 3.0
			"seal":
				if o.hero == p:
					return center + _dir(center, p.position) * (radius - 1.5)
			"orbit":

				if boss != null and _flat(p.position, boss.position) < float(o.ab.far) + 1.6:
					var away: = boss.position + _dir(boss.position, p.position) * (float(o.ab.far) + 2.5)
					return center + (away - center).limit_length(radius - 1.5)
	if not _cast.is_empty():
		match _cast.ab.mech:
			"judgement":
				if _cast["in"]:
					return _cast.at
				return _cast.at + _dir(_cast.at, p.position) * (float(_cast.ab.out) + 2.0)
			"cone":
				return p.position + Vector3( - _cast.dir.z, 0, _cast.dir.x) * 3.0
			"spokes":
				return _between_spokes(float(_cast.base) + PI / float(_cast.ab.count) * 0.5, int(_cast.ab.count))
	for o in _objects:
		match o.kind:
			"wave":
				return _between_spokes(float(o.base) + PI / float(o.ab.count), int(o.ab.count))
			"dash":
				if float(o.t) > 0.0:
					return p.position + Vector3( - o.dir.z, 0, o.dir.x) * 3.0
			"incarn":
				var left: Array = o.adds.filter( func(e): return is_instance_valid(e) and not e.dead)
				if not left.is_empty():
					left.sort_custom( func(a, b): return _flat(a.position, p.position) < _flat(b.position, p.position))
					return left[0].position + _dir(left[0].position, p.position) * 1.5
	for o in _objects:
		if o.kind == "pool" and _flat(p.position, o.pos) < float(o.ab.size) + 0.5:
			return p.position + _dir(o.pos, p.position) * 3.0
	return Vector3.INF



func _between_spokes(base: float, count: int) -> Vector3:
	var p: = world.player
	var best: = Vector3.INF
	for i in count:
		var a: = base + TAU * i / float(count)
		var at: = boss.position + Vector3(cos(a), 0, sin(a)) * 4.5
		if _flat(at, center) > radius - 1.0:
			continue
		if best == Vector3.INF or _flat(at, p.position) < _flat(best, p.position):
			best = at
	return best






func _hit_pct(h: Player, pct: float) -> void :
	stats.fails += 1
	world.hurt_what = _now_name


	var ym: = minf(ymir_mvp_mult(), GameData.RAID_YMIR_TICK_MAX) if finale else ymir_mvp_mult()
	h.take_damage(h.max_hp * pct * GameData.RAID_MECH_DMG * ym, world, boss, true)


func _hit_dmg(h: Player, weight: float) -> void :
	_hit_pct(h, weight * GameData.RAID_HIT_PCT * (1.0 + GameData.RAID_HIT_PCT_DANGER * (world.danger - 1)))
	if h == world.player:
		world.hud.flash(Color(1, 0.2, 0.15), 0.35)



func _target_hero() -> Player:
	var taunted: Player = boss.taunter(world) if boss != null and is_instance_valid(boss) else null
	if taunted != null:
		return taunted
	var best: Player = world.player
	var best_d: = INF
	for h in world.alive_heroes():
		var d: = _flat(h.position, boss.position if boss != null else center)
		if d < best_d:
			best_d = d
			best = h
	return best


func _push(h: Player, by: Vector3) -> void :
	var to: = world.map.slide(h.position, by)
	var d: = (to - center) * Vector3(1, 0, 1)
	if d.length() > radius - 0.4:
		to = center + d.normalized() * (radius - 0.4)
	h.position = _safe_spot(h, to)


func _clamp(n: Node3D, r: float) -> void :
	var d: = (n.position - center) * Vector3(1, 0, 1)
	if d.length() > r:
		var at: = center + d.normalized() * r
		n.position = _held_in(n as Player, d.normalized(), r) if n is Player else Vector3(at.x, world.map.height_at(at), at.z)





func _held_in(h: Player, dir: Vector3, r: float) -> Vector3:
	var flow: = world.flow_of(h)
	for k in 9:
		var at: = center + dir * r * (1.0 - k / 8.0)
		if world.map.is_walkable(at) and (flow.reachable(at) or _line_ok(at)):
			return Vector3(at.x, world.map.height_at(at), at.z)
	var edge: = center + dir * r
	return Vector3(edge.x, world.map.height_at(edge), edge.z)







func _safe_spot(h: Player, to: Vector3) -> Vector3:
	var flow: = world.flow_of(h)
	for k in 9:
		var at: = to.lerp(h.position, k / 8.0)
		if world.map.is_walkable(at) and (flow.reachable(at) or _line_ok(at)):
			return Vector3(at.x, world.map.height_at(at), at.z)
	return h.position




func _into_arena(dir: Vector3, dist: float) -> Vector3:
	for k in 9:
		var at: = center + dir * dist * (1.0 - k / 8.0)
		if world.map.is_walkable(at) and _line_ok(at):
			return Vector3(at.x, world.map.height_at(at), at.z)
	return center




func _line_ok(at: Vector3) -> bool:
	var span: = ((at - center) * Vector3(1, 0, 1)).length()
	var n: = maxi(1, ceili(span / 0.5))
	for i in n + 1:
		if not world.map.is_walkable(center.lerp(at, i / float(n))):
			return false
	return true



func _inside(frac: float) -> Vector3:
	for tries in 12:
		var a: = randf() * TAU
		var at: = center + Vector3(cos(a), 0, sin(a)) * radius * frac * sqrt(randf())
		if world.map.is_walkable(at):
			at.y = world.map.height_at(at)
			return at
	return center



func _afterimage(v: RoVisual) -> void :
	var g: = Sprite3D.new()
	g.texture = v.sprite.texture
	g.offset = v.sprite.offset
	g.centered = false
	g.pixel_size = v.sprite.pixel_size
	g.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	g.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	g.shaded = false
	g.modulate = Color(color.lightened(0.2), 0.5)
	g.render_priority = GameData.MVP_UNDER_PRIORITY
	world.fx_root.add_child(g)
	g.global_transform = v.sprite.global_transform
	var tw: = g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.3)
	tw.tween_callback(g.queue_free)


func _dir(from: Vector3, to: Vector3) -> Vector3:
	var d: = (to - from) * Vector3(1, 0, 1)
	return d.normalized() if d.length_squared() > 0.0001 else Vector3(0, 0, 1)


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()





func _build_layer() -> void :
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()
	_layer = CanvasLayer.new()
	_layer.layer = 4
	add_child(_layer)
	var g: = Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([Color(0.2, 0.0, 0.02, 0.0), Color(0.2, 0.0, 0.02, 0.12), Color(0.12, 0.0, 0.02, 0.85)])
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.05, 0.5)
	_veil = TextureRect.new()
	_veil.texture = t
	_veil.stretch_mode = TextureRect.STRETCH_SCALE
	_veil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.modulate.a = 0.08
	_layer.add_child(_veil)
	_count = Label.new()
	_count.add_theme_font_override("font", RO_FONT_BOLD)
	_count.add_theme_font_size_override("font_size", 24)
	_count.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	_count.add_theme_color_override("font_outline_color", Color.BLACK)
	_count.add_theme_constant_override("outline_size", 6)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_count.offset_top = 250
	_count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_count)




func _darken(on: bool) -> void :
	if _env == null:
		for c in world.get_children():
			if c is WorldEnvironment:
				_env = c.environment
	if _light_tw != null:
		_light_tw.kill()
	_light_tw = create_tween().set_parallel()
	if on:
		_restore_light()
		_light_tw = create_tween().set_parallel()
		var t: = _omen_time() * 0.8
		if _env != null:
			_env_was = {"color": _env.ambient_light_color, "energy": _env.ambient_light_energy}
			_light_tw.tween_property(_env, "ambient_light_color", Color(0.55, 0.38, 0.42), t)
			_light_tw.tween_property(_env, "ambient_light_energy", _env.ambient_light_energy * 0.7, t)
		var suns: Array = world.map.find_children("*", "DirectionalLight3D", true, false)
		for c in world.get_children():
			if c is DirectionalLight3D:
				suns.append(c)
		for l: DirectionalLight3D in suns:
			_lights[l] = {"energy": l.light_energy, "color": l.light_color}
			_light_tw.tween_property(l, "light_energy", l.light_energy * 0.45, t)
			_light_tw.tween_property(l, "light_color", Color(1.0, 0.65, 0.6), t)
	else:
		if _env != null and not _env_was.is_empty():
			_light_tw.tween_property(_env, "ambient_light_color", _env_was.color, 2.0)
			_light_tw.tween_property(_env, "ambient_light_energy", _env_was.energy, 2.0)
		for l in _lights:
			if is_instance_valid(l):
				_light_tw.tween_property(l, "light_energy", _lights[l].energy, 2.0)
				_light_tw.tween_property(l, "light_color", _lights[l].color, 2.0)
		_light_tw.tween_interval(0.01)
		_env_was = {}
		_lights.clear()



func _restore_light() -> void :
	if _light_tw != null:
		_light_tw.kill()
		_light_tw = null
	if _env != null and not _env_was.is_empty():
		_env.ambient_light_color = _env_was.color
		_env.ambient_light_energy = _env_was.energy
	_env_was = {}
	for l in _lights:
		if is_instance_valid(l):
			l.light_energy = _lights[l].energy
			l.light_color = _lights[l].color
	_lights.clear()





func _growing() -> bool:
	return _objects.any( func(o): return o.kind == "grow")




func _grow() -> void :
	var t: = float(data.grow_time)
	_drop_orbits()
	boss.hold = t + 0.5
	if boss.visual is RoVisual:
		(boss.visual as RoVisual).play(RoVisual.MOB_ATTACK, true, true)
	world.play_sound("warning", 0.0, 0.0)
	world.play_mob_sound(mvp, "attack")
	world.shake(0.8)
	world.hud.flash(Color(0.4, 0.1, 0.6), 0.5)
	var at: = boss.position
	var under: = GameData.MVP_UNDER_PRIORITY
	Vfx.magic_circle(world.fx_root, at, 4.5, Color(color.lightened(0.2), 0.85), t + 0.3, "mvp_rune", 1.6, under)
	Vfx.magic_circle(world.fx_root, at, 2.6, Color(1.0, 0.35, 0.3, 0.85), t + 0.3, "mvp_hexa", -2.8, under)
	world.spawn_fx("hell_in", at, 1.8)

	for i in 6:
		var a: = TAU * i / 6.0
		var p: = at + Vector3(cos(a), 0, sin(a)) * 3.2
		_later(i * t / 7.0, func():
			Vfx.column(world.fx_root, p, color)
			world.spawn_fx("hell_in", p, 0.8, 0.6))
	_objects.append({"kind": "grow", "t": t})




func _grown() -> void :
	var kid: = boss
	if kid == null or not is_instance_valid(kid) or kid.dead:
		return
	var at: = kid.position
	var adult: = world.spawn_enemy(str(data.adult), at, true)
	if adult == null:
		kid.hold = 0.6
		return
	adult.brain = null
	adult.max_hp = kid.max_hp
	adult.hp = kid.hp
	adult.set_meta("rage", float(kid.get_meta("rage", 0.0)))
	if kid.has_meta("pride"):
		adult.set_meta("pride", float(kid.get_meta("pride")))
	adult.hold = 0.8
	_own.erase(kid)
	_own.append(adult)
	world.banish_enemy(kid)
	world.boss = adult
	boss = adult
	mvp = str(data.adult)
	_calm_damage *= float(data.enrage)

	world.shake(1.3)
	world.hud.flash(Color(0.7, 0.08, 0.1), 0.6)
	world.play_sound("earth_quake", 0.0, 0.0)
	world.play_mob_sound(mvp, "attack")
	Vfx.burst(world.fx_root, at, 6.0, Color(1.0, 0.3, 0.25))
	Vfx.beam_flash(world.fx_root, at, Color(1.0, 0.3, 0.25), 14.0, 1.2)
	for i in 3:
		Vfx.ring(world.fx_root, at, 4.0 + 3.0 * i, Color(1.0, 0.5, 0.4, 0.9 - 0.2 * i), 0.5 + 0.2 * i)
	for i in 8:
		var a: = TAU * i / 8.0
		world.spawn_fx("firepillar", at + Vector3(cos(a), 0, sin(a)) * 3.5, 0.9, 0.6)
	world.raid._chat(adult, tr(str(data.reborn)))
	var shown: = boss_title(adult)
	world.raid._announce(tr("MVP: %s") % (shown if shown != "" else tr(GameData.MONSTERS[mvp].name)), Color(1.0, 0.45, 0.4), tr(str(data.grow)))
	if ymir > 0.0:
		var glow: = Vfx.ground_glow(adult, Vector3(0, 0.05, 0), adult.radius * 3.2, Color(0.6, 0.15, 1.0, 0.7))
		glow.render_priority = GameData.MVP_UNDER_PRIORITY
	for h in world.alive_heroes():
		_push(h, _dir(at, h.position) * 2.5)
	for ab in data.abilities:
		_timers[ab.id] = maxf(float(_timers.get(ab.id, ab.first)), 2.0)




func _volley(ab: Dictionary) -> void :
	world.play_mob_sound(mvp, "attack")
	var heroes: = world.alive_heroes()
	if heroes.is_empty():
		return
	var spots: Array = []
	for h in heroes:
		spots.append(h.position)
	var tries: = 0
	while spots.size() < int(ab.count) and tries < 40:
		tries += 1
		var h: Player = heroes.pick_random()
		var a: = randf() * TAU
		var at: Vector3 = h.position + Vector3(cos(a), 0, sin(a)) * randf_range(1.8, float(ab.spread))
		at = center + (at - center).limit_length(radius - 1.0)
		if world.map.is_walkable(at):
			at.y = world.map.height_at(at)
			spots.append(at)
	for i in spots.size():
		var t: = float(ab.fall) + i * float(ab.gap)
		Vfx.telegraph_circle(world.fx_root, spots[i], float(ab.size), t)
		_skull_fall(spots[i], t)
		if world.net.recording():
			world.net.morroc_event(["skull", spots[i], t])
		_objects.append({"kind": "rain", "t": t, "pos": spots[i], "size": float(ab.size), "dmg": float(ab.dmg), "skull": true, "ab": ab})



func _skull_fall(at: Vector3, t: float) -> void :
	var v: = RoVisual.new()
	world.fx_root.add_child(v)
	v.setup(RoAssets.sprite(["flame_skull"]), Color(0.7, 0.4, 1.0), 40, 0.0)
	v.scale = Vector3.ONE * 1.3
	v.sprite.render_priority = GameData.MVP_PRIORITY
	v.play(RoVisual.MOB_WALK)
	v.face(Vector3(0, 0, 1))
	v.global_position = at + Vector3(randf_range(-2.0, 2.0), 13.0, randf_range(-1.0, 1.0))
	var tw: = v.create_tween()
	tw.tween_property(v, "global_position", at, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(v.queue_free)




func _orbit_start(ab: Dictionary) -> void :
	var base: = randf() * TAU
	world.play_sound("beginspell", 0.0, -4.0)
	Vfx.ring(world.fx_root, boss.position, float(ab.far), Color(0.7, 0.4, 1.0), float(ab.warm))
	_objects.append(_orbit_object(str(ab.id), base, boss))
	if world.net.recording():
		world.net.morroc_event(["orbit", str(ab.id), base])


func _orbit_object(ab_id: String, base: float, around: Enemy) -> Dictionary:
	var ab: Dictionary = {}
	for a in data.abilities:
		if str(a.id) == ab_id:
			ab = a
	var skulls: Array = []
	for i in int(ab.get("count", 0)):
		var v: = RoVisual.new()
		world.fx_root.add_child(v)
		v.setup(RoAssets.sprite(["flame_skull"]), Color(0.7, 0.4, 1.0), 40, 0.6)
		v.scale = Vector3.ONE * 1.3
		v.sprite.render_priority = GameData.MVP_PRIORITY
		v.play(RoVisual.MOB_WALK)
		v.global_position = around.position
		v.sprite.modulate.a = 0.0
		var glow: = Vfx.ground_glow(v, Vector3(0, -0.55, 0), 1.2, Color(0.7, 0.3, 1.0, 0.7))
		glow.render_priority = GameData.MVP_UNDER_PRIORITY
		skulls.append(v)
	return {"kind": "orbit", "t": float(ab.get("time", 0.0)), "age": 0.0, "base": base, "ab": ab, "skulls": skulls, 
		"around": around, "cool": {}}



func _orbit_tick(o: Dictionary, delta: float) -> bool:
	var around: Enemy = o.around if is_instance_valid(o.around) and not o.around.dead else null
	if around == null:

		around = _shown_boss()
		o.around = around
	o.t -= delta
	o.age += delta
	var ab: Dictionary = o.ab
	var warm: = float(ab.warm)
	var done: bool = o.t <= 0.0 or around == null
	var k: = 0.5 - 0.5 * cos(maxf(0.0, o.age - warm) * TAU / float(ab.breath))
	var r: = lerpf(float(ab.near), float(ab.far), k)
	var n: int = o.skulls.size()
	var alpha: = clampf(o.age / warm, 0.0, 1.0) * clampf(o.t / 0.5, 0.0, 1.0)
	for i in n:
		var sk: RoVisual = o.skulls[i]
		if not is_instance_valid(sk):
			continue
		if done:
			sk.queue_free()
			continue
		var a: float = float(o.base) + o.age * float(ab.spin) + TAU * i / float(n)
		var at: Vector3 = around.position + Vector3(cos(a), 0, sin(a)) * r
		at.y = world.map.height_at(at) + 0.6
		sk.global_position = at
		sk.face(Vector3( - sin(a), 0, cos(a)))
		sk.sprite.modulate.a = alpha
		if world.net.is_client() or o.age < warm or o.t < 0.3:
			continue
		for h in world.alive_heroes():
			if float(o.cool.get(h, 0.0)) <= 0.0 and _flat(h.position, at) < float(ab.hit) + h.radius:
				o.cool[h] = 0.8
				_now_name = str(ab.name)
				_hit_dmg(h, float(ab.dmg))
				world.spawn_fx("hell_in", h.position, 0.6, 0.5)
	for h in o.cool.keys():
		o.cool[h] = float(o.cool[h]) - delta
	return done




func _drop_orbits() -> void :
	for i in range(_objects.size() - 1, -1, -1):
		var o: Dictionary = _objects[i]
		if o.kind != "orbit":
			continue
		for sk in o.skulls:
			if is_instance_valid(sk):
				sk.queue_free()
		_objects.remove_at(i)
	if world.net.recording():
		world.net.morroc_event(["orbit_end"])



func _shown_boss() -> Enemy:
	if boss != null and is_instance_valid(boss) and not boss.dead:
		return boss
	for e in world.enemies:
		if is_instance_valid(e) and not e.dead and e.id in [str(data.mob), str(data.get("adult", ""))]:
			return e
	return null






func _finale_won(e: Enemy) -> void :
	stats.won = true
	beaten = maxi(beaten, level)
	var at: = e.position
	world.raid._chat(e, tr(str(data.death)))
	world.raid._announce(tr("¡Victoria!"), Color(1, 0.9, 0.4), 
		tr(str(data.again.win)) % boss_title(e) if level > 1 else tr(str(data.win)))
	world._show_mvp_banner()
	world.emote(world.player, "grats")
	world.play_sound("drop_yellow", 0.0, -2.0)
	world.hud.flash(Color(1.0, 0.95, 0.85), 0.7)
	if level > 1:
		_again_reward()
	else:
		world._drop_chest(at, int(data.chest), 3, "", true)



		if not world.pickups.is_empty() and (world.pickups.back() as Dictionary).has("satan"):
			world.pickups.back()["sure_set"] = true
		var hoard: = roundi(float(data.zeny) * GameData.danger_reward(world.danger))
		var coins: = int(data.coins)
		for i in coins:
			world._runner_coins(at, floori(float(hoard) / coins) + (hoard % coins if i == 0 else 0))
		finale_reward()
		for h in world.heroes:
			if world.net.is_remote(h):
				world.net.send_got(h, "finale", 0)


	if not world.is_coop():
		RunSave.clear()
	_end()
	state = "won"

	Vfx.ring(world.fx_root, at, radius * 2.5, Color(1.0, 0.95, 0.8), 1.4)
	world.clear_battlefield.call_deferred()
	world.get_tree().create_timer(1.2, false).timeout.connect(world._pull_prizes)
	world.get_tree().create_timer(3.0, false).timeout.connect(_finale_close.bind(0))





func finale_reward() -> void :
	var fin: Dictionary = GameData.MORROC_FINALE
	Save.bump("morroc_finale")
	var n: = int(fin.poring_coins)
	for i in n:
		world.found_coin(false)
	if world.player != null:
		world.number(world.player.position + Vector3(0, 3.2, 0), tr("+%d Poring Coins") % n, Color(1.0, 0.82, 0.3), true)
		world.play_sound("coin3", 0.0, -2.0)
	var cos_id: = str(fin.cosmetic)
	if Save.add_cosmetic(cos_id):
		world.hud.alerts.warn(tr("Nuevo cosmético: %s") % tr(str(GameData.COSMETICS[cos_id].name)), Color(0.8, 0.55, 1.0), "party_alarm")

	if not world.is_coop() and world.player != null and not world.player.tampered\
	and GameData.hell_level(world.danger) >= int(fin.title_hell):
		Save.mark_seen("titles", str(fin.title))





func _again_reward() -> void :
	var ag: Dictionary = data.again
	var ores: = int(ag.ores) * level
	world.gain_material("elunium", ores)
	world.gain_material("oridecon", ores)
	world.gain_material("star_crumb", level)
	for h in world.heroes:
		if randf() >= float(ag.coin):
			continue
		if h == world.player:
			world.found_coin()
		elif world.net.is_remote(h):
			world.net.send_got(h, "coin", 0)






func _finale_close(tries: int) -> void :
	if not world.running or state != "won":
		return
	var waiting: bool = (tries < 60 and (world.busy() or world.pickups.any( func(p): return p.kind in ["chest", "card"])))\
	or world._loot != null or not world.loot_queue.is_empty()
	if waiting:
		world._pull_prizes()
		world.get_tree().create_timer(0.5, false).timeout.connect(_finale_close.bind(tries + 1))
		return
	if world.autopilot or world.showcase:
		if level < int(GameData.get_meta("morroc_again", 0)):
			again()
		else:
			world._end_run(true)
		return
	world.menus.show_morroc_again(level + 1)




func again() -> void :
	if not world.running or state != "won":
		return
	level += 1
	state = "idle"
	_use(GameData.MORROC_FINALE, true)
	var spot: = _find_arena()
	if spot.is_empty():
		for h in world.alive_heroes():
			spot = _find_arena(h.position, float(data.min_radius) * 0.6)
			if not spot.is_empty():
				break
	if spot.is_empty():
		var here: = world.player.position
		spot = [Vector3(here.x, world.map.height_at(here), here.z), maxf(12.0, _open_radius(here, float(data.radius)))]
	print("FINALE again: Morroc %s" % roman(level))
	_begin_omen(spot[0], spot[1])




func _omen_time() -> float:
	return float(data.again.omen) if finale and level > 1 and data.has("again") else float(data.omen)




func boss_title(e: Enemy) -> String:
	if not finale or level <= 1 or e == null or not is_instance_valid(e) or not (e.id in [str(data.mob), str(data.get("adult", ""))]):
		return ""
	return "%s %s" % [tr(str(e.def.name)), roman(level)]


static func roman(n: int) -> String:
	var vals: = [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"], [50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]
	var out: = ""
	for v in vals:
		while n >= int(v[0]):
			out += str(v[1])
			n -= int(v[0])
	return out






func _talk_show() -> void :
	_talk_hide()
	if _layer == null or not is_instance_valid(_layer):
		return
	var vp: = world.get_viewport().get_visible_rect().size
	var box: = Control.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(box)
	_talk_box = box


	var art_h: = clampf(vp.y * 0.72, 260.0, 760.0)
	var art_w: = art_h * 323.0 / 492.0
	var bottom: = vp.y
	var path: = "res://assets/ro/ui/skin/illust/morocc_kid.png"
	if ResourceLoader.exists(path):
		var art: = TextureRect.new()
		art.texture = load(path)
		art_w = art_h * art.texture.get_width() / float(art.texture.get_height())
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.size = Vector2(art_w, art_h)
		art.position = Vector2( - art_w, bottom - art_h)
		box.add_child(art)
		art.create_tween().tween_property(art, "position:x", 10.0, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var panel: = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.07, 0.03, 0.12, 0.9), Color(0.62, 0.36, 1.0), 8, 2))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w: = clampf(vp.x * 0.34, 240.0, 420.0)
	panel.custom_minimum_size = Vector2(w, 0)
	panel.position = Vector2(10.0 + art_w * 0.8, vp.y * 0.86 - art_h * 0.42)
	box.add_child(panel)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)
	var who: = UiKit.label(tr(str(data.talk_name)), 15, Color(0.85, 0.65, 1.0), true)
	col.add_child(who)
	_talk_text = UiKit.label("", 14, Color(1.0, 0.96, 0.98))
	_talk_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_talk_text.custom_minimum_size = Vector2(w - 24.0, 0)
	col.add_child(_talk_text)
	panel.modulate.a = 0.0
	panel.create_tween().tween_property(panel, "modulate:a", 1.0, 0.4).set_delay(0.3)
	_talk_i = -1
	_talk_tick(0.0)




func _talk_tick(k: float) -> void :
	if _talk_text == null or not is_instance_valid(_talk_text):
		return
	var lines: Array = data.get("talk", [])
	if lines.is_empty():
		return

	var i: = clampi(floori(k * (lines.size() + 0.35)), 0, lines.size() - 1)
	if i == _talk_i:
		return
	_talk_i = i
	_talk_text.text = tr(str(lines[i]))
	_talk_text.visible_ratio = 0.0
	_talk_text.create_tween().tween_property(_talk_text, "visible_ratio", 1.0, minf(2.2, _talk_text.text.length() * 0.035))
	world.play_sound("beginspell", 0.0, -14.0)


func _talk_hide() -> void :
	if _talk_box != null and is_instance_valid(_talk_box):
		var b: = _talk_box
		var tw: = b.create_tween()
		tw.tween_property(b, "modulate:a", 0.0, 0.4)
		tw.tween_callback(b.queue_free)
	_talk_box = null
	_talk_text = null
	_talk_i = -1
