extends RefCounted

















var world: World


var _shadow_t: = 0.0
var _shadows: Array = []


var fog_on: = false
var fog_center: = Vector3.ZERO
var fog_radius: = 0.0
var fog_next: = Vector3.INF
var fog_warn: = 0.0

var _fog_stay: = 0.0
var _fog_t: = 0.0
var _fog_tick: = 0.0
var _fog_paused: = false
var _fog_resend: = 0.0


var _fog_seq: = 0
var _outside: = {}
var _fog_layer: CanvasLayer
var _fog_rect: ColorRect


var _game_t: = 0.0
var game: = {}
var toy_t: = {}

var _hn: RefCounted = null


func _init(p_world: World) -> void :
	world = p_world



func reset() -> void :
	_shadow_t = GameData.HELL_SHADOW_FIRST
	_shadows.clear()
	fog_on = false
	fog_next = Vector3.INF
	_fog_t = GameData.HELL_FOG_FIRST
	_fog_paused = false
	_outside.clear()
	_game_t = GameData.MORROC_GAME_FIRST
	game = {}
	_mark_t = -1.0
	for slot in marks.keys():
		_mark_clear(int(slot))
	for p in _pools:
		if is_instance_valid(p.node):
			p.node.queue_free()
	_pools.clear()
	toy_t.clear()
	_fog_show(false)
	_gfx_clear()


func level() -> int:
	if world.tower != null or world.festival_mode or world.training:
		return 0
	return GameData.hell_level(world.danger)



func tick(delta: float) -> void :
	_tick_toys(delta)
	var h: = level()
	if h < 11 or world.player == null:
		return
	var away: = _away()
	if not away:
		_tick_shadows(delta)
	if h >= 14:
		_tick_fog(delta, away or _fog_quiet())

	if h >= 15 and not away and (world.morroc == null or world.morroc.state == "idle" or not marks.is_empty()):
		_tick_mark(delta)




func _away() -> bool:
	return world.raid.in_arena() or (world.morroc != null and str(world.morroc.state) in ["fight", "c_fight"])





func _fog_quiet() -> bool:
	return str(world.raid.state) != "idle" or (world.morroc != null and str(world.morroc.state) != "idle")



func draw_tick() -> void :
	if _hn != null:
		if world.running and world.raid.in_arena():
			_hn.draw_tick(world.get_process_delta_time())
		else:
			_hn.finish()
			_hn = null


	if not world.running and (fog_on or not game.is_empty() or _panel != null):
		fog_on = false
		fog_next = Vector3.INF
		_fog_seq = 0
		game = {}
		_gfx_clear()
		_fog_show(false)
	_gfx_tick()
	_mark_draw()

	if not game.is_empty() and world.net != null and world.net.is_client():
		game.t = maxf(0.0, float(game.t) - world.get_process_delta_time())
	if _fog_rect == null or not is_instance_valid(_fog_rect):
		return
	var on: = fog_on and world.running and not _away() and not _fog_quiet() and world.camera != null
	_fog_layer.visible = on
	if not on:
		return
	var cam: Camera3D = world.camera
	var mat: = _fog_rect.material as ShaderMaterial
	var vp: = world.get_viewport().get_visible_rect().size



	var r: = shown_radius()
	var c: = cam.unproject_position(fog_center)
	var rx: = 0.0
	var ry: = 0.0
	for k in 16:
		var a: = TAU * k / 16.0
		var d: = cam.unproject_position(fog_center + Vector3(cos(a), 0, sin(a)) * r) - c
		rx = maxf(rx, absf(d.x))
		ry = maxf(ry, absf(d.y))
	mat.set_shader_parameter("center", c / vp)
	mat.set_shader_parameter("radii", Vector2(rx, ry) / vp)


	mat.set_shader_parameter("rim_strength", smoothstep(22.0, 110.0, sqrt(rx * ry)))

	if fog_next != Vector3.INF and world.net != null and world.net.is_client():
		fog_warn = maxf(0.0, fog_warn - world.get_process_delta_time())
	if fog_next != Vector3.INF:

		var n: = cam.unproject_position(fog_next)
		var nx: = 0.0
		var ny: = 0.0
		for k in 16:
			var a: = TAU * k / 16.0
			var d: = cam.unproject_position(fog_next + Vector3(cos(a), 0, sin(a)) * fog_radius) - n
			nx = maxf(nx, absf(d.x))
			ny = maxf(ny, absf(d.y))
		mat.set_shader_parameter("next_center", n / vp)
		mat.set_shader_parameter("next_radii", Vector2(nx, ny) / vp)
		mat.set_shader_parameter("next_on", 1.0)
	else:
		mat.set_shader_parameter("next_on", 0.0)
	_fog_arrow(cam, vp)
	mat.set_shader_parameter("aspect", vp.x / maxf(1.0, vp.y))




func _tick_shadows(delta: float) -> void :
	_shadows = _shadows.filter( func(e): return is_instance_valid(e) and not e.dead)
	for e in _shadows:
		_shadow_cast(e, delta)
	if not _shadows.is_empty():
		return
	_shadow_t -= delta
	if _shadow_t > 0.0:
		return
	_shadow_t = GameData.HELL_SHADOW_EVERY * randf_range(0.9, 1.1)
	_shadow_spawn()



func _shadow_mechs(mvp: String) -> Array:
	var out: = []
	for ab in GameData.RAIDS.get(mvp, {}).get("abilities", []):
		if str(ab.get("mech", "")) in GameData.HELL_SHADOW_MECHS:
			out.append(ab)
	return out




func _shadow_spawn(mvp: = "") -> void :
	if mvp == "":
		mvp = str(world.stage.get("mvp", ""))
	if mvp == "" or not GameData.MONSTERS.has(mvp):
		return
	var mechs: = _shadow_mechs(mvp)
	if mechs.is_empty():
		return
	var ab: Dictionary = mechs.pick_random()
	var keep: = world.boss
	var e: = world.spawn_enemy(mvp, world._offscreen_point(), true)
	if e == null:
		return
	world.boss = keep if keep != null and is_instance_valid(keep) and not keep.dead else e
	e.set_meta("mvp_shadow", ab)
	e.set_meta("shadow_cd", 3.0)
	e.max_hp = maxf(e.max_hp * GameData.HELL_SHADOW_HP, _party_dps() * GameData.HELL_SHADOW_TANK)
	e.hp = e.max_hp
	dress(e)
	_shadows.append(e)
	world.spawn_fx("hell_in", e.position, 1.2, 0.9)
	world.party_announce(tr("Sombra de %s") % tr(str(e.def.name)), Color(0.75, 0.55, 1.0), 
		tr("Trae su %s: apréndela antes del MVP") % tr(str(ab.name)))
	world.play_sound("warning", 0.2, -6.0)


func _shadow_cast(e: Enemy, delta: float) -> void :

	if not game.is_empty():
		return
	var cd: = float(e.get_meta("shadow_cd", 0.0)) - delta
	if cd > 0.0:
		e.set_meta("shadow_cd", cd)
		return
	var targets: = world.alive_heroes()
	if targets.is_empty():
		return
	var p: Player = targets.pick_random()
	if e.position.distance_to(p.position) > 14.0:
		e.set_meta("shadow_cd", 0.5)
		return
	e.set_meta("shadow_cd", GameData.HELL_SHADOW_CAST_EVERY)
	var ab: Dictionary = e.get_meta("mvp_shadow")
	var cast: = maxf(0.8, float(ab.get("cast", 1.0)))
	var pct: = GameData.HELL_SHADOW_PCT * float(ab.get("dmg", 1.0))
	var from: = e.position
	world.label_over(e, tr("%s!!") % tr(str(ab.name)), Color(0.85, 0.6, 1.0))
	e.hold = cast + 0.3
	match str(ab.mech):
		"cone":
			var dir: = _dir(from, p.position)
			var r: = float(ab.get("radius", 5.0))
			var ang: = float(ab.get("angle", 1.4))
			Vfx.telegraph_cone(world.fx_root, from, dir, r, ang, cast)
			_later(cast, func():
				for h in _standing():
					var rel: Vector3 = (h.position - from) * Vector3(1, 0, 1)
					if rel.length() <= r and absf(dir.signed_angle_to(rel.normalized(), Vector3.UP)) <= ang * 0.5:
						_hit(h, pct, ab))
		"rain", "slam":
			var size: = float(ab.get("size", 2.4))
			var spots: Array = [p.position]
			for i in mini(int(ab.get("count", 3)), 4) - 1:
				spots.append(world.map.random_point_around(p.position, 3.0) if world.map != null else p.position)
			for at in spots:
				Vfx.telegraph_circle(world.fx_root, at, size, cast)
			_later(cast, func():
				for at in spots:
					world.spawn_fx(str(ab.get("fx", "firepillar")), at, size / 2.0, 0.8)
					for h in _standing():
						if _flat(h.position, at) <= size:
							_hit(h, pct, ab))
		"charge":
			var dir: = _dir(from, p.position)
			var length: = 12.0
			Vfx.telegraph_line(world.fx_root, from, dir, length, 2.0, cast)
			_later(cast, func():
				if not is_instance_valid(e) or e.dead:
					return
				var end: = from + dir * length
				if world.map == null or world.map.is_walkable(end):
					e.position = Vector3(end.x, world.map.height_at(end) if world.map != null else end.y, end.z)
				for h in _standing():
					var rel: Vector3 = (h.position - from) * Vector3(1, 0, 1)
					var along: float = rel.dot(dir)
					if along >= 0.0 and along <= length and absf(rel.dot(Vector3( - dir.z, 0, dir.x))) <= 1.0:
						_hit(h, pct, ab))
		"spokes":
			var n: = int(ab.get("count", 6))
			var w: = float(ab.get("width", 1.4))
			var base: = randf() * TAU
			var length: = 14.0
			for i in n:
				var d: = Vector3(cos(base + TAU * i / n), 0, sin(base + TAU * i / n))
				Vfx.telegraph_line(world.fx_root, from, d, length, w, cast)
			_later(cast, func():
				for h in _standing():
					var rel: Vector3 = (h.position - from) * Vector3(1, 0, 1)
					for i in n:
						var d: = Vector3(cos(base + TAU * i / n), 0, sin(base + TAU * i / n))
						var along: float = rel.dot(d)
						if along >= 0.0 and along <= length and absf(rel.dot(Vector3( - d.z, 0, d.x))) <= w * 0.5:
							_hit(h, pct, ab)
							break)


func _hit(h: Player, pct: float, ab: Dictionary) -> void :
	world.hurt_what = tr(str(ab.name))
	h.hell_hazard(world, pct)



func shadow_down(e: Enemy) -> void :
	_shadows.erase(e)
	if world.boss == e:
		world.boss = null
	world._drop_chest(e.position, GameData.CHEST_ROLLS.elite, 0)
	for h in world.heroes:
		if is_instance_valid(h) and not h.downed:
			h.heal(h.max_hp * GameData.HELL_SHADOW_HEAL, world, true, "shadow")
	world.spawn_fx("hell_in", e.position, 1.0, 0.8)
	world.party_announce(tr("¡La sombra se desvanece!"), Color(0.75, 0.55, 1.0), tr("Ya conoces su mecánica"))





func profane(at: Vector3) -> void :

	var climb = world.tower
	var hel_rule: bool = climb != null and climb.hel != null and climb.hel.has("profane")
	if level() < 13 and not hel_rule:
		return
	var st: Dictionary = TowerRun.tier_stage(climb.floor) if climb != null else world.stage
	var pool: Array = []
	for ev in st.get("events", []):
		if ev.type == "elite" and not pool.has(ev.mob):
			pool.append(ev.mob)
	if pool.is_empty():
		for sp in st.get("spawns", []):
			if not GameData.MONSTERS.get(sp.mob, {}).get("static", false):
				pool.append(str(sp.mob))
	if pool.is_empty():
		return
	var e: = world.spawn_enemy(str(pool.pick_random()), at + Vector3(2.5, 0, 0), true, true)
	if e == null:
		return
	e.set_meta("profane", true)
	e.max_hp = maxf(e.max_hp * GameData.HELL_PROFANE_HP, _party_dps() * GameData.HELL_PROFANE_TANK)
	e.hp = e.max_hp
	e.speed *= GameData.HELL_PROFANE_SPEED
	dress(e)
	var pillar: = Vfx.beam(world.fx_root, e.position, Color(0.9, 0.15, 0.2), 7.0)
	world.get_tree().create_timer(1.4, false).timeout.connect( func():
		if is_instance_valid(pillar):
			pillar.queue_free())
	Vfx.burst(world.fx_root, e.position, 2.5, Color(0.9, 0.2, 0.25))
	world.shake(0.4)
	world.play_sound("warning", 0.1, -4.0)
	world.party_announce(tr("¡El altar estaba profanado!"), Color(1.0, 0.35, 0.35), tr("Su guardián te persigue: derrótalo"))






func dress(e: Enemy) -> void :
	var c: = Color(0.55, 0.4, 0.85, 0.85) if e.has_meta("mvp_shadow") else (Color(1.0, 0.55, 0.55) if e.has_meta("profane") else Color.WHITE)
	if e.visual is RoVisual:
		(e.visual as RoVisual).tint = c
		(e.visual as RoVisual).sprite.modulate = c


func profane_down(e: Enemy) -> void :
	world._drop_chest(e.position, GameData.CHEST_ROLLS.elite, 1)
	world.party_announce(tr("¡El guardián profanado cae!"), Color(1.0, 0.6, 0.5), "")




func _tick_fog(delta: float, away: bool) -> void :
	if away:
		_fog_paused = true
		return


	if _fog_paused:
		_fog_paused = false
		if fog_on:
			fog_center = _party_center()
			fog_next = Vector3.INF
			_fog_stay = GameData.HELL_FOG_STAY
			_outside.clear()
			_fog_send()
	if not fog_on:
		_fog_t -= delta
		if _fog_t > 0.0:
			return
		fog_on = true

		fog_center = _party_center()
		fog_radius = GameData.HELL_FOG_RADIUS
		fog_next = Vector3.INF
		_fog_t = GameData.HELL_FOG_ON


		_fog_stay = GameData.HELL_FOG_STAY + FOG_CLOSE
		world.party_announce(tr("La niebla de Niflheim avanza"), Color(0.55, 0.85, 0.7), tr("Solo la luz de Yggdrasil es segura: síguela cuando se mueva"))
		world.play_sound("warning", 0.2, -6.0)
		_fog_send()
		_fog_show(true)
	_fog_t -= delta

	if _fog_t <= 0.0 and fog_next == Vector3.INF:
		fog_on = false
		_fog_t = GameData.HELL_FOG_OFF
		_outside.clear()
		for h in world.heroes:
			if is_instance_valid(h):
				h.fogged = false
		world.party_announce(tr("La niebla de Niflheim se retira"), Color(0.55, 0.85, 0.7), tr("Por un rato"))
		_fog_seq += 1
		_send(["hz", "fog_off", _fog_seq])
		_fog_show(false)
		return


	if fog_next == Vector3.INF:
		_fog_stay -= delta
		if _fog_stay <= 0.0 and _fog_t > GameData.HELL_FOG_SHRINK:
			fog_next = _fog_spot()
			fog_warn = GameData.HELL_FOG_SHRINK
			_fog_mark(fog_next)
			world.party_announce(tr("La luz de Yggdrasil se retira"), Color(1.0, 0.9, 0.5), tr("Ve al círculo nuevo"))
			_fog_send()
	else:
		fog_warn -= delta
		if fog_warn <= 0.0:
			fog_center = fog_next
			fog_next = Vector3.INF
			_fog_stay = GameData.HELL_FOG_STAY
			_fog_send()


	_fog_resend -= delta
	if _fog_resend <= 0.0:
		_fog_resend = 8.0
		_send(_fog_news(), false)

	_fog_tick -= delta
	if _fog_tick > 0.0:
		return
	_fog_tick = 1.0
	for h in world.heroes:
		if not is_instance_valid(h):
			continue
		var out: = not h.downed and not in_light(h.position)
		h.fogged = out
		if out:
			world.label_over(h, tr("¡Fuera de la luz!"), Color(0.6, 1.0, 0.85))
		if not out:
			_outside.erase(h.get_instance_id())
			continue
		var t: = float(_outside.get(h.get_instance_id(), 0.0)) + 1.0
		_outside[h.get_instance_id()] = t
		var pct: = minf(GameData.HELL_FOG_MAX, GameData.HELL_FOG_PCT + GameData.HELL_FOG_RAMP * (t - 1.0))
		world.hurt_what = tr("La niebla de Niflheim")
		h.take_damage(h.max_hp * pct, world, null, true, true)



func _fog_spot() -> Vector3:
	var at: = _party_center()
	if world.map != null:
		var p: Vector3 = world.map.find_point_around(at, GameData.HELL_FOG_MOVE * 0.7, GameData.HELL_FOG_MOVE)
		if p != Vector3.INF:
			return p
		return world.map.random_point_around(at, GameData.HELL_FOG_MOVE * 0.6)
	return at




func in_light(at: Vector3) -> bool:
	if _flat(at, fog_center) <= shown_radius():
		return true
	return fog_next != Vector3.INF and _flat(at, fog_next) <= fog_radius





func _fog_mark(at: Vector3) -> void :
	Vfx.safe_circle(world.fx_root, at, fog_radius, Color(0.8, 0.6, 1.0), GameData.HELL_FOG_SHRINK)
	var pillar: = Vfx.beam(world.fx_root, _ground(at), Color(0.85, 0.75, 1.0), 14.0)
	pillar.scale = Vector3(2.5, 1.0, 2.5)
	_later(GameData.HELL_FOG_SHRINK, func():
		if is_instance_valid(pillar):
			pillar.queue_free())




var _arrow: Polygon2D
func _fog_arrow(cam: Camera3D, vp: Vector2) -> void :
	var want: = fog_next != Vector3.INF and not cam.is_position_behind(fog_next)
	var p: = cam.unproject_position(fog_next) if want else Vector2.ZERO
	var margin: = 48.0
	var inside: = want and Rect2(Vector2(margin, margin), vp - Vector2(margin, margin) * 2.0).has_point(p)
	if not want or inside:
		if _arrow != null and is_instance_valid(_arrow):
			_arrow.visible = false
		return
	if _arrow == null or not is_instance_valid(_arrow):
		_arrow = Polygon2D.new()
		_arrow.polygon = PackedVector2Array([Vector2(22, 0), Vector2(-12, -15), Vector2(-5, 0), Vector2(-12, 15)])
		_arrow.color = Color(0.92, 0.82, 1.0)
		_fog_layer.add_child(_arrow)
	_arrow.visible = true
	var mid: = vp * 0.5
	var dir: = (p - mid).normalized()

	var reach: = minf((vp.x * 0.5 - margin) / maxf(0.001, absf(dir.x)), (vp.y * 0.5 - margin) / maxf(0.001, absf(dir.y)))
	_arrow.position = mid + dir * reach
	_arrow.rotation = dir.angle()
	var pulse: = 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.008)
	_arrow.scale = Vector2.ONE * pulse * 1.2


func _fog_send() -> void :
	_fog_seq += 1
	_send(_fog_news())


func _fog_news() -> Array:
	return ["hz", "fog", fog_center, fog_radius, fog_next if fog_next != Vector3.INF else Vector3.ZERO, fog_next != Vector3.INF, fog_warn, _fog_seq]






func _send(ev: Array, reliable: = true) -> void :
	if world.net == null or not world.net.recording():
		return

	if reliable and world.net.has_method("hell_event"):
		world.net.call("hell_event", ev)
	else:
		world.net.record(ev)




func catch_up() -> Array:
	var out: = []
	if level() < 14:
		return out
	if fog_on:
		out.append(_fog_news())
	if not game.is_empty():
		out.append(_game_news())
		out.append(_game_state())
	return out






func net_promote() -> void :
	if _hn != null:
		_hn.finish()
		_hn = null
	if not game.is_empty():
		game = {}
		_gfx_clear()
		_send(["hz", "gend"])

	_game_t = maxf(GameData.MORROC_GAME_EVERY * 0.5, GameData.MORROC_GAME_FIRST - world.time)
	_shadow_t = maxf(GameData.HELL_SHADOW_EVERY * 0.5, GameData.HELL_SHADOW_FIRST - world.time)
	_shadows.clear()
	for e in world.enemies:
		if not is_instance_valid(e) or e.dead or not e.has_meta("mvp_shadow"):
			continue

		if not e.get_meta("mvp_shadow") is Dictionary:
			var mechs: = _shadow_mechs(e.id)
			if mechs.is_empty():
				continue
			e.set_meta("mvp_shadow", mechs.pick_random())
		e.set_meta("shadow_cd", 3.0)
		_shadows.append(e)
	_outside.clear()

	_fog_seq += 1
	if fog_on:
		if fog_next == Vector3.INF:
			_fog_stay = GameData.HELL_FOG_STAY
		_fog_t = maxf(_fog_t, GameData.HELL_FOG_SHRINK + 1.0)
		_fog_send()
	else:
		_fog_t = maxf(10.0, GameData.HELL_FOG_FIRST - world.time)



func net_event(ev: Array) -> void :
	match str(ev[1]):
		"fog":
			if ev.size() > 7:
				if int(ev[7]) < _fog_seq:
					return
				_fog_seq = int(ev[7])
			fog_on = true
			fog_center = ev[2]
			fog_radius = float(ev[3])
			fog_next = ev[4] if bool(ev[5]) else Vector3.INF
			fog_warn = float(ev[6])
			_fog_show(true)
		"fog_off":
			if ev.size() > 2:
				if int(ev[2]) < _fog_seq:
					return
				_fog_seq = int(ev[2])
			fog_on = false
			fog_next = Vector3.INF
			_fog_show(false)
		"game":
			game = {"kind": str(ev[2]), "at": ev[3], "t": float(ev[4]), "time": float(ev[4]), "step": 0, 
				"seals": (ev[5] as Array).map( func(a): return {"at": a, "fill": 0.0, "broken": false}), "spots": ev[6]}
			_gfx_build()
		"gstate":
			if game.is_empty():
				return
			game.t = float(ev[2])
			game.step = int(ev[3])
			var fills: Array = ev[4]
			for i in mini(fills.size(), (game.seals as Array).size()):
				game.seals[i].broken = float(fills[i]) < 0.0
				game.seals[i].fill = maxf(0.0, float(fills[i]))
			if ev.size() > 5:
				game.lost = ev[5]
		"gend":
			game = {}
			_gfx_clear()
		"mark":
			_mark_show(int(ev[2]), float(ev[3]))
		"mlock":
			_mark_lock(int(ev[2]), ev[3])
		"mburst":
			_mark_burst_look(ev[2])
		"hn":

			if _hn == null:
				_hn = preload("res://scripts/core/hel_naght.gd").new(world)
			_hn.net_event(ev)






const FOG_FROM: = 3.5
const FOG_CLOSE: = 8.0
var _fog_since: = -1.0
func shown_radius() -> float:
	var r: = fog_radius
	if _fog_since >= 0.0:
		var k: = clampf((Time.get_ticks_msec() * 0.001 - _fog_since) / FOG_CLOSE, 0.0, 1.0)
		r = lerpf(fog_radius * FOG_FROM, fog_radius, k * k * (3.0 - 2.0 * k))
	if fog_next != Vector3.INF:
		r *= clampf(fog_warn / GameData.HELL_FOG_SHRINK, 0.0, 1.0)
	return r


func _fog_show(on: bool) -> void :
	if on and (_fog_layer == null or not is_instance_valid(_fog_layer) or not _fog_layer.visible):
		_fog_since = Time.get_ticks_msec() * 0.001
	if on and (_fog_layer == null or not is_instance_valid(_fog_layer)):
		_fog_layer = CanvasLayer.new()
		_fog_layer.layer = 1
		world.add_child(_fog_layer)
		_fog_rect = ColorRect.new()
		_fog_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mat: = ShaderMaterial.new()
		mat.shader = _fog_shader()
		_fog_rect.material = mat
		_fog_layer.add_child(_fog_rect)
	if _fog_layer != null and is_instance_valid(_fog_layer):
		_fog_layer.visible = on







static var _shader: Shader
static func _fog_shader() -> Shader:
	if _shader != null:
		return _shader
	var light: = OS.has_feature("mobile") or OS.has_feature("web")
	var head: = "\nshader_type canvas_item;\nuniform vec2 center = vec2(0.5);\nuniform vec2 radii = vec2(0.2);\nuniform vec2 next_center = vec2(0.5);\nuniform vec2 next_radii = vec2(0.2);\nuniform float next_on = 0.0;\nuniform float aspect = 1.7;\nuniform float rim_strength = 1.0;\nfloat hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }\nfloat noise(vec2 p) {\n\tvec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);\n\treturn mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);\n}\n// The edge's light at distance `d` (1 = the edge) and angle `ang`.\nfloat edge_light(float d, float ang) {\n\tfloat edge = abs(d - 1.0);\n\tif (edge > 0.1) { return 0.0; }\n\tfloat rim = 1.0 - smoothstep(0.0, 0.02, edge);\n\tfloat runes = pow(max(0.0, sin(ang * 18.0 - TIME * 2.2)), 8.0) * (1.0 - smoothstep(0.0, 0.05, edge));\n\tfloat wisp = d > 1.0 ? smoothstep(0.55, 0.9, noise(vec2(ang * 6.0, d * 10.0 - TIME * 1.4))) * (1.0 - smoothstep(0.0, 0.09, d - 1.0)) : 0.0;\n\treturn clamp(rim * 0.9 + runes * 0.8 + wisp * 0.5, 0.0, 1.0);\n}\nfloat edge_glow(float d) { return (1.0 - smoothstep(0.0, 0.1, abs(d - 1.0))) * 0.35; }\nfloat next_light(vec2 uv) {\n\tif (next_on < 0.5) { return 0.0; }\n\tvec2 nrel = (uv - next_center) / max(next_radii, vec2(0.001));\n\tfloat nd = length(nrel);\n\tif (abs(nd - 1.0) > 0.03) { return 0.0; }\n\tfloat dash = step(0.45, fract(atan(nrel.y, nrel.x) * 2.5 + TIME * 0.6));\n\treturn (1.0 - smoothstep(0.0, 0.03, abs(nd - 1.0))) * dash * (0.7 + 0.3 * sin(TIME * 6.0));\n}\n"
































	var body: = ""
	if light:
		body = "\nvoid fragment() {\n\tvec2 uv = SCREEN_UV;\n\tvec2 rel = (uv - center) / max(radii, vec2(0.001));\n\tfloat rl = length(rel);\n\tfloat ang = atan(rel.y, rel.x);\n\tfloat d = rl + 0.012 * sin(ang * 9.0 + TIME * 1.6);\n\tfloat outside = smoothstep(0.98, 1.1, d);\n\t// The next circle (marked while the light withdraws) is light too.\n\tif (next_on > 0.5) {\n\t\tfloat nd = length((uv - next_center) / max(next_radii, vec2(0.001)));\n\t\toutside = min(outside, smoothstep(0.98, 1.1, nd));\n\t}\n\tfloat n = noise(uv * vec2(aspect, 1.0) * 4.0 + vec2(TIME * 0.1, TIME * 0.04));\n\tvec3 col = mix(vec3(0.16, 0.07, 0.26), vec3(0.42, 0.26, 0.58), n);\n\tfloat a = outside * (0.55 + 0.15 * n);\n\tfloat g = edge_glow(d) * rim_strength;\n\tfloat e = edge_light(d, ang) * rim_strength;\n\tfloat nx = next_light(uv);\n\tcol = mix(col, vec3(0.92, 0.82, 1.0), max(e, nx));\n\tCOLOR = vec4(col, clamp(max(max(a, g), max(e, nx)), 0.0, 0.85));\n}\n"






















	else:
		body = "\nuniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;\nvoid fragment() {\n\tvec2 uv = SCREEN_UV;\n\tvec3 scene = texture(screen_tex, uv).rgb;\n\tvec2 rel = (uv - center) / max(radii, vec2(0.001));\n\tfloat rl = length(rel);\n\tvec3 col = scene;\n\t// The next circle (marked while the light withdraws) is light too.\n\tfloat nrl = next_on > 0.5 ? length((uv - next_center) / max(next_radii, vec2(0.001))) : 99.0;\n\tif (rl > 0.86 && nrl > 0.86) {\n\t\tfloat ang = atan(rel.y, rel.x);\n\t\t// The edge breathes and ripples a little.\n\t\tfloat d = rl + 0.012 * sin(ang * 9.0 + TIME * 1.6) + 0.006 * sin(ang * 23.0 - TIME * 2.3);\n\t\tfloat outside = min(smoothstep(0.98, 1.1, d), smoothstep(0.98, 1.1, nrl));\n\t\tif (outside > 0.0) {\n\t\t\tfloat n = noise(uv * vec2(aspect, 1.0) * 4.0 + vec2(TIME * 0.1, TIME * 0.04));\n\t\t\tfloat grey = dot(scene, vec3(0.3, 0.59, 0.11));\n\t\t\tvec3 mist = mix(vec3(0.18, 0.08, 0.3), vec3(0.5, 0.32, 0.68), n);\n\t\t\tcol = mix(scene, mix(vec3(grey) * vec3(0.55, 0.48, 0.65), mist, 0.4 + 0.25 * n), outside * 0.85);\n\t\t}\n\t\tcol = mix(col, vec3(0.75, 0.5, 1.0), edge_glow(d) * rim_strength);\n\t\tcol = mix(col, vec3(0.92, 0.82, 1.0), edge_light(d, ang) * rim_strength);\n\t}\n\tcol = mix(col, vec3(0.95, 0.85, 1.0), next_light(uv));\n\tCOLOR = vec4(col, 1.0);\n}\n"



























	_shader = Shader.new()
	_shader.code = head + body
	return _shader




func _tick_game(delta: float) -> void :
	if game.is_empty():
		_game_t -= delta
		if _game_t <= 0.0:
			_game_t = GameData.MORROC_GAME_EVERY * randf_range(0.9, 1.1)
			_game_start(str(GameData.MORROC_GAMES.pick_random()))
		return
	game.t = float(game.t) - delta
	game.tick = float(game.get("tick", 0.0)) - delta
	game.sync = float(game.get("sync", 0.0)) - delta
	match str(game.kind):
		"skulls":
			if float(game.tick) <= 0.0:
				game.tick = 0.7
				for h in _standing():
					for i in 2:
						var at: Vector3 = h.position if i == 0 else (world.map.random_point_around(h.position, 2.8) if world.map != null else h.position)
						Vfx.telegraph_circle(world.fx_root, at, 1.4, 0.95)
						_later(0.95, func():
							world.spawn_fx("firehit1", at, 0.6, 0.7)
							for hh in _standing():
								if _flat(hh.position, at) <= 1.4:
									_fail(hh, tr("¡Te tocó una calavera!")))
		"dance":
			if float(game.tick) <= 0.0:
				game.tick = 0.25
				var cr: = dance_ring(game)
				var late: = float(game.time) - float(game.t) > GameData.MORROC_DANCE_GRACE
				for h in _standing():
					var id: int = h.get_instance_id()
					if _flat(h.position, cr[0]) <= float(cr[1]) + 0.35:
						game.inside[id] = true


					elif late or game.inside.has(id):
						_fail(h, tr("¡Saliste del anillo!"))
		"seals":
			if float(game.tick) <= 0.0:
				game.tick = 0.25
				for s in game.seals:
					if bool(s.broken):
						continue
					if _standing().any( func(h): return _flat(h.position, s.at) <= GameData.MORROC_SEAL_SIZE):
						s.fill = float(s.fill) + 0.25
						if float(s.fill) >= GameData.MORROC_SEAL_TIME:
							s.broken = true
							Vfx.column(world.fx_root, s.at, Color(0.8, 0.4, 1.0))
							world.play_sound("refine_ok", 0.0, -8.0)
							game.sync = 0.0
				if game.seals.all( func(s): return bool(s.broken)):
					game.t = 0.0
					game.won_all = true
		"hop":
			if float(game.tick) <= 0.0:
				game.tick = 0.2
				var i: = int(game.step)
				if i < (game.spots as Array).size():
					var at: Vector3 = game.spots[i]
					if _standing().any( func(h): return _flat(h.position, at) <= GameData.MORROC_HOP_SIZE):
						game.step = i + 1
						Vfx.column(world.fx_root, at, Color(1.0, 0.85, 0.4))
						world.play_sound("refine_ok", 0.0, -10.0)
						game.sync = 0.0
						if int(game.step) >= (game.spots as Array).size():
							game.t = 0.0
							game.won_all = true
	if float(game.sync) <= 0.0:
		game.sync = 0.5
		_game_send_state()
	if float(game.t) <= 0.0:
		_game_end()




static func dance_ring(g: Dictionary) -> Array:
	var k: = clampf(1.0 - float(g.t) / maxf(0.1, float(g.time)), 0.0, 1.0)
	var c: Vector3 = (g.at as Vector3) + Vector3(cos(k * TAU), 0, sin(k * TAU)) * 2.6
	var r: = GameData.MORROC_DANCE_SIZE - 1.1 * absf(sin(k * PI * 2.0))
	return [c, r]



static func game_text(kind: String) -> Array:
	match kind:
		"skulls":
			return [TranslationServer.translate("Lluvia de calaveras"), TranslationServer.translate("Esquiva los círculos rojos")]
		"dance":
			return [TranslationServer.translate("Danza de calaveras"), TranslationServer.translate("Quédate dentro del anillo")]
		"seals":
			return [TranslationServer.translate("Sellos del abismo"), TranslationServer.translate("Párate dentro de cada círculo morado hasta que se llene")]
		"hop":
			return [TranslationServer.translate("Rayuela"), TranslationServer.translate("Pisa los círculos en orden")]
	return ["", ""]


func _game_start(kind: String) -> void :


	var mid: = _party_center()
	game = {"kind": kind, "t": GameData.MORROC_GAME_TIME, "time": GameData.MORROC_GAME_TIME, "tick": 1.0, "failed": {}, "inside": {}, "at": mid}
	match kind:
		"seals":
			var seals: = []
			var base: = randf() * TAU
			for i in 3:
				var a: = base + TAU * i / 3.0
				var at: = mid + Vector3(cos(a), 0, sin(a)) * 6.0
				if world.map != null and not world.map.is_walkable(at):
					at = world.map.random_point_around(mid, 5.0)
				seals.append({"at": at, "fill": 0.0, "broken": false})
			game.seals = seals
			game.t = GameData.MORROC_SEAL_GAME_TIME
			game.time = game.t
		"hop":
			var spots: = []
			var at: = mid
			for i in 5:
				var next: = world.map.find_point_around(at, 3.5, 5.0) if world.map != null else at
				at = next if next != Vector3.INF else at
				spots.append(at)
			game.spots = spots
			game.step = 0
			game.t = GameData.MORROC_HOP_TIME
			game.time = game.t


	for h in _standing():
		for e in world.enemies_in_radius(h.position, GameData.MORROC_GAME_CLEAR):
			if not e.is_boss and not e.dead:
				var away: Vector3 = ((e.position - h.position) * Vector3(1, 0, 1)).normalized()
				e.knock = away * 22.0
	var tx: = game_text(kind)
	world.party_announce(tr("¡Morroc niño quiere jugar!"), Color(0.8, 0.5, 1.0), "%s: %s" % [tx[0], tx[1]])
	world.spawn_fx("hell_in", mid + Vector3(3, 0, 0), 1.0, 0.9)
	world.play_sound("party_alarm", 0.0, -4.0)
	_send(_game_news())
	_gfx_build()



func _game_news() -> Array:
	return ["hz", "game", str(game.kind), game.at, float(game.time), game.get("seals", []).map( func(s): return s.at), game.get("spots", [])]



func calm() -> bool:
	return not game.is_empty()


func _game_send_state() -> void :
	if world.net == null or not world.net.recording():
		return
	_send(_game_state(), false)




func _game_state() -> Array:
	var fills: Array = game.get("seals", []).map( func(s): return -1.0 if bool(s.broken) else float(s.fill))
	var lost: Array = world.heroes.filter( func(h): return is_instance_valid(h) and game.get("failed", {}).has(h.get_instance_id())).map( func(h): return h.slot)
	return ["hz", "gstate", float(game.t), int(game.get("step", 0)), fills, lost]




var _gfx: Node3D
var _gfx_nodes: = {}
var _panel: CanvasLayer
var _panel_bar: ProgressBar
var _panel_text: Label
var _panel_title: Label


func _gfx_build() -> void :
	_gfx_clear()
	if game.is_empty() or world.fx_root == null:
		return


	game.at = _ground(game.at)
	for sd in game.get("seals", []):
		sd.at = _ground(sd.at)
	if game.has("spots"):
		game.spots = (game.spots as Array).map( func(a): return _ground(a))
	_gfx = Node3D.new()
	world.fx_root.add_child(_gfx)
	var purple: = Color(0.78, 0.45, 1.0)
	var gold: = Color(1.0, 0.85, 0.4)
	match str(game.kind):
		"dance":
			_gfx_nodes.disc = _decal(game.at, 1.0, Color(purple, 0.2))
			_gfx_nodes.rune = Vfx.magic_circle(_gfx, game.at, GameData.MORROC_DANCE_SIZE, Color(purple, 0.9), 0.0, "mvp_rune", 0.9, -1, true)
		"seals":
			var list: = []
			for s in game.seals:
				var rune: = Vfx.magic_circle(_gfx, s.at, GameData.MORROC_SEAL_SIZE, Color(1.0, 0.6, 1.0, 0.95), 0.0, "mvp_rune", 0.8, -1, true)
				var fill: = _decal(s.at, 0.1, Color(purple, 0.6))
				var beam: = Vfx.beam(_gfx, s.at, purple, 5.0)

				var tip: = Label3D.new()
				tip.text = tr("¡Párate aquí!")
				tip.font = UiKit.FONT_TITLE
				tip.font_size = 44
				tip.outline_size = 12
				tip.modulate = Color(1.0, 0.85, 1.0)
				tip.outline_modulate = Color(0.25, 0.05, 0.35)
				tip.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				tip.no_depth_test = true
				tip.pixel_size = 0.009
				tip.position = s.at + Vector3(0, 1.4, 0)
				_gfx.add_child(tip)
				list.append({"rune": rune, "fill": fill, "beam": beam, "tip": tip})
			_gfx_nodes.seals = list
		"hop":
			var list: = []
			for i in (game.spots as Array).size():
				var at: Vector3 = game.spots[i]
				var ring: = Vfx.magic_circle(_gfx, at, GameData.MORROC_HOP_SIZE, Color(gold, 0.95), 0.0, "mvp_rune", 0.5, -1, true)
				var lbl: = Label3D.new()
				lbl.text = str(i + 1)
				lbl.font_size = 96
				lbl.outline_size = 14
				lbl.modulate = Color(1.0, 0.92, 0.6)
				lbl.outline_modulate = Color(0.35, 0.18, 0.0)
				lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				lbl.no_depth_test = true
				lbl.pixel_size = 0.011
				lbl.position = at + Vector3(0, 0.9, 0)
				_gfx.add_child(lbl)
				list.append({"ring": ring, "label": lbl})
			_gfx_nodes.spots = list
			_gfx_nodes.beam = Vfx.beam(_gfx, game.spots[0], gold, 5.0)
	_panel_build()


func _gfx_clear() -> void :
	if _gfx != null and is_instance_valid(_gfx):
		_gfx.queue_free()
	_gfx = null
	_gfx_nodes = {}
	if _panel != null and is_instance_valid(_panel):
		_panel.queue_free()
	_panel = null





func _panel_build() -> void :
	_panel = CanvasLayer.new()
	_panel.layer = 5
	world.add_child(_panel)
	var box: = PanelContainer.new()
	var sb: = UiKit.panel_box(Color(0.16, 0.06, 0.24, 0.88), Color(0.8, 0.5, 1.0), 10, 2)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 8
	box.add_theme_stylebox_override("panel", sb)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.offset_left = 8
	box.offset_right = 300
	box.offset_top = 175
	_panel.add_child(box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	box.add_child(col)
	var tx: = game_text(str(game.kind))
	_panel_title = UiKit.label(tr("Juego de Morroc · %s") % tx[0], 15, Color(1.0, 0.85, 1.0), true)
	_panel_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_panel_title)
	_panel_text = UiKit.label(tx[1], 13, Color(0.95, 0.9, 1.0), true)
	_panel_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(_panel_text)
	_panel_bar = ProgressBar.new()
	_panel_bar.show_percentage = false
	_panel_bar.custom_minimum_size = Vector2(260, 8)
	_panel_bar.max_value = 1.0
	var bg: = StyleBoxFlat.new()
	bg.bg_color = Color(0.0, 0.0, 0.0, 0.45)
	bg.set_corner_radius_all(4)
	var fg: = StyleBoxFlat.new()
	fg.bg_color = Color(0.85, 0.55, 1.0)
	fg.set_corner_radius_all(4)
	_panel_bar.add_theme_stylebox_override("background", bg)
	_panel_bar.add_theme_stylebox_override("fill", fg)
	col.add_child(_panel_bar)



func _gfx_tick() -> void :
	if game.is_empty():
		if _gfx != null:
			_gfx_clear()
		return
	if _gfx == null or not is_instance_valid(_gfx):
		return
	var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)
	match str(game.kind):
		"dance":
			var cr: = dance_ring(game)
			var r: = float(cr[1])
			var disc: Sprite3D = _gfx_nodes.disc
			disc.position = (cr[0] as Vector3) + Vector3(0, 0.06, 0)
			disc.pixel_size = r * 2.0 / 128.0
			var rune = _gfx_nodes.rune
			if rune != null and is_instance_valid(rune):
				rune.position = Vector3((cr[0] as Vector3).x, rune.position.y, (cr[0] as Vector3).z)
				rune.scale = Vector3.ONE * (r / GameData.MORROC_DANCE_SIZE)
		"seals":
			for i in (game.seals as Array).size():
				var s: Dictionary = game.seals[i]
				var n: Dictionary = _gfx_nodes.seals[i]
				if bool(s.broken):
					for key in ["rune", "fill", "beam", "tip"]:
						if n.get(key) != null and is_instance_valid(n[key]):
							n[key].queue_free()
					continue
				var k: = clampf(float(s.fill) / GameData.MORROC_SEAL_TIME, 0.0, 1.0)
				if is_instance_valid(n.fill):
					(n.fill as Sprite3D).pixel_size = maxf(0.05, GameData.MORROC_SEAL_SIZE * k) * 2.0 / 128.0
		"hop":
			var step: = int(game.get("step", 0))
			for i in (_gfx_nodes.spots as Array).size():
				var n: Dictionary = _gfx_nodes.spots[i]
				var ring = n.ring
				var lbl: Label3D = n.label
				if ring == null or not is_instance_valid(ring):
					continue
				if i < step:
					ring.visible = false
					lbl.visible = false
				elif i == step:
					ring.visible = true
					ring.scale = Vector3.ONE * (1.0 + 0.1 * pulse)
					lbl.modulate = Color(1.0, 0.95, 0.6)
					lbl.font_size = 112
					var beam = _gfx_nodes.get("beam")
					if beam != null and is_instance_valid(beam):
						beam.position = Vector3((game.spots[i] as Vector3).x, beam.position.y, (game.spots[i] as Vector3).z)
				else:
					ring.visible = i == step + 1
					ring.scale = Vector3.ONE * 0.7
					lbl.modulate = Color(1.0, 0.92, 0.6, 0.5)
					lbl.font_size = 72
	if _panel_bar != null and is_instance_valid(_panel_bar):
		_panel_bar.value = clampf(float(game.t) / maxf(0.1, float(game.time)), 0.0, 1.0)
		var extra: = ""
		match str(game.kind):
			"seals":
				extra = "  ·  %d / 3" % game.seals.filter( func(s): return bool(s.broken)).size()
			"hop":
				extra = "  ·  %d / %d" % [int(game.get("step", 0)), (game.spots as Array).size()]
			_:
				extra = "  ·  %d s" % ceili(maxf(0.0, float(game.t)))
		var me: = world.player
		var lost: bool = me != null and (game.get("failed", {}).has(me.get_instance_id()) or (game.get("lost", []) as Array).has(me.slot))
		_panel_text.text = (tr("¡Perdiste esta! Sigue esquivando") if lost else game_text(str(game.kind))[1]) + extra


func _fail(h: Player, why: String) -> void :
	if game.is_empty():
		return
	if not game.has("failed"):
		game.failed = {}
	if game.failed.has(h.get_instance_id()):
		return
	game.failed[h.get_instance_id()] = true
	world.label_over(h, why, Color(0.85, 0.5, 1.0))


func _game_end() -> void :
	var kind: = str(game.kind)
	var winners: Array = []
	_send(["hz", "gend"])
	for h in _standing():
		var lost: bool = game.get("failed", {}).has(h.get_instance_id())

		if kind in ["seals", "hop"] and not bool(game.get("won_all", false)):
			lost = true
		if not lost:
			winners.append(h)
	game = {}
	_gfx_clear()
	if winners.is_empty():
		world.party_announce(tr("Morroc niño se ríe de ti"), Color(0.7, 0.5, 0.9), tr("Esta vez no hay juguete"))
		return

	world.party_announce(tr("¡Ganaste el juego de Morroc!"), Color(1.0, 0.8, 0.4), 
		tr("Cada ganador recibe un juguete al azar") if world.is_coop() else tr("Elige un juguete"))
	world.play_sound("job_levelup", 0.0, -6.0)
	for h in winners:
		var ids: = _toy_offer(h)
		if ids.is_empty():
			continue
		if h == world.player and not world.is_coop():
			world.menus.show_morroc_toys(ids, func(id: String): give_toy(h, id))
		else:
			give_toy(h, str(ids.pick_random()))



func _toy_offer(h: Player) -> Array:
	var ids: = GameData.MORROC_TOYS.keys().filter( func(id): return int(h.toys.get(id, 0)) < int(GameData.MORROC_TOYS[id].get("max", 3)))
	ids.shuffle()
	return ids.slice(0, 3)


func give_toy(h: Player, id: String) -> void :
	if not GameData.MORROC_TOYS.has(id):
		return
	h.toys[id] = int(h.toys.get(id, 0)) + 1
	h.recompute()
	world.label_over(h, tr(str(GameData.MORROC_TOYS[id].name)), Color(1.0, 0.8, 0.4))
	world.spawn_fx("joblvup", h.position, 1.0, 0.8, h)



func _tick_toys(delta: float) -> void :
	if not world.running:
		return
	for h in world.heroes:
		if not is_instance_valid(h) or h.downed or h.toys.is_empty():
			continue
		var id: = h.get_instance_id()
		var t: Dictionary = toy_t.get(id, {})
		toy_t[id] = t
		var rain: = int(h.toys.get("abyss_rain", 0))
		if rain > 0:
			t.rain = float(t.get("rain", 3.0)) - delta
			if float(t.rain) <= 0.0:
				t.rain = GameData.TOY_RAIN_EVERY
				_toy_rain(h, rain)
		var bones: = int(h.toys.get("bone_crown", 0))
		if bones > 0:
			t.bones = float(t.get("bones", 0.0)) - delta
			if float(t.bones) <= 0.0:
				t.bones = GameData.TOY_BONES_EVERY
				h.shield = maxf(h.shield, h.max_hp * GameData.TOY_BONES_SHIELD * bones)
		var laugh: = int(h.toys.get("laugh", 0))
		if laugh > 0:
			t.laugh = float(t.get("laugh", 0.0)) - delta
			if float(t.laugh) <= 0.0:
				t.laugh = 0.5
				for e in world.enemies_in_radius(h.position, GameData.TOY_LAUGH_RADIUS * (1.0 + 0.25 * (laugh - 1))):
					if not e.is_boss and not e.dead:
						e.slow_time = maxf(e.slow_time, 0.7)


func _toy_rain(h: Player, n: int) -> void :
	var near: = world.nearest_enemies(h.position, 9.0, 3 * n)
	if near.is_empty():
		return
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "toy_abyss_rain"
	world.damage_by = h
	for e in near:
		var at: Vector3 = e.position
		world.spawn_fx("firehit1", at, 0.6, 0.7)
		for o in world.enemies_in_radius(at, 1.5):
			if not o.dead:
				world.damage_enemy(o, GameData.U_BASE * GameData.TOY_RAIN_DMG, Vector3.ZERO, "skill", "shadow", "toy_abyss_rain")
	world.damage_tag = keep[0]
	world.damage_by = keep[1]



func on_kill(h: Player, e: Enemy) -> void :
	if h == null or h.toys.is_empty():
		return
	var rift: = int(h.toys.get("rift", 0))


	var t: Dictionary = toy_t.get(h.get_instance_id(), {})
	if rift > 0 and world.clock >= float(t.get("rift_at", 0.0)) and randf() < GameData.TOY_RIFT_CHANCE:
		t.rift_at = world.clock + GameData.TOY_RIFT_GAP
		toy_t[h.get_instance_id()] = t
		var at: = e.position
		if world.hero_fx_alpha(h) > 0.01:
			Vfx.quake(world.fx_root, at, 2.2, Color(0.6, 0.2, 0.8))
		var keep: = [world.damage_tag, world.damage_by]
		world.damage_tag = "toy_rift"
		world.damage_by = h
		for o in world.enemies_in_radius(at, 2.2):
			if o != e and not o.dead:
				world.damage_enemy(o, GameData.U_BASE * GameData.TOY_RIFT_DMG * rift, Vector3.ZERO, "skill", "shadow", "toy_rift")
		world.damage_tag = keep[0]
		world.damage_by = keep[1]
	if int(h.toys.get("poison_gift", 0)) > 0 and (e.poison_stacks > 0 or e.blood_stacks > 0):
		var o: Enemy = null
		for c in world.nearest_enemies(e.position, 4.0, 3):
			if c != e and not c.dead:
				o = c
				break
		if o == null:
			return
		var keep2: = [world.damage_tag, world.damage_by]
		world.damage_by = h
		if e.poison_stacks > 0 and e.poison_dps > 0.0:
			world.damage_tag = e.poison_tag
			world.apply_poison(o, e.poison_dps, GameData.POISON_HIT_TIME, mini(e.poison_stacks, GameData.TOY_GIFT_STACKS))
		if e.blood_stacks > 0 and e.blood > 0.0:
			world.dots.bleed_on(world, o, e.blood / maxf(1.0, e.blood_stacks) / GameData.BLEED_STORE, e.blood_tag, h, true, mini(e.blood_stacks, 3))
		world.damage_tag = keep2[0]
		world.damage_by = keep2[1]




var _mark_t: = -1.0


var marks: = {}

var _pools: Array = []
var _pool_tick: = 0.0


func _tick_mark(delta: float) -> void :
	if _mark_t < 0.0:
		_mark_t = GameData.MARK_FIRST
	_mark_t -= delta
	if _mark_t <= 0.0 and marks.is_empty():
		_mark_t = GameData.MARK_EVERY
		var who: = world.alive_heroes().filter( func(x): return is_instance_valid(x) and not x.downed)
		if not who.is_empty():
			var h: Player = who.pick_random()
			_mark_show(h.slot, GameData.MARK_FOLLOW + GameData.MARK_LOCK)
			_send(["hz", "mark", h.slot, GameData.MARK_FOLLOW + GameData.MARK_LOCK])
			world.play_sound("warning", 0.2, -4.0)
	for slot in marks.keys():
		var m: Dictionary = marks[slot]
		m.t = float(m.t) - delta
		if m.has("label") and is_instance_valid(m.get("label")):
			world.raid.head_timer_tick(m.get("sigil"), m.get("label"), float(m.t), delta)
		if m.at == Vector3.INF and float(m.t) <= GameData.MARK_LOCK:
			var h: = _hero_of(int(slot))
			var at: Vector3 = h.position if h != null else _party_center()
			_mark_lock(int(slot), at)
			_send(["hz", "mlock", int(slot), at])
		if float(m.t) <= 0.0:
			var at2: Vector3 = m.at
			_mark_clear(int(slot))
			_mark_burst(at2)


	for p in _pools.duplicate():
		if world.clock >= float(p.get("until", INF)):
			_pools.erase(p)
			if is_instance_valid(p.node):
				p.node.queue_free()

	_pool_tick -= delta
	if _pool_tick <= 0.0 and not _pools.is_empty():
		_pool_tick = 0.5
		for h in world.heroes:
			if not is_instance_valid(h) or h.downed:
				continue
			for p in _pools:
				if _flat(h.position, p.at) <= GameData.MARK_RADIUS:
					world.hurt_what = tr("Marca del Apocalipsis")
					h.take_damage(h.max_hp * GameData.MARK_POOL_PCT * 0.5, world, null, true, true)
					break


func _hero_of(slot: int) -> Player:
	for h in world.heroes:
		if is_instance_valid(h) and h.slot == slot:
			return h
	return null




func _mark_show(slot: int, time: float) -> void :
	var h: = _hero_of(slot)
	if h == null:
		return
	_mark_clear(slot)


	var ring: = _mark_disc(_ground(h.position), Color(1.0, 0.12, 0.1, 0.35), Color(1.0, 0.25, 0.15, 0.95))
	marks[slot] = {"t": time, "at": Vector3.INF, "node": ring}


	if world.net == null or not world.net.is_client():
		var holder: = Node3D.new()
		h.add_child(holder)
		var head: Dictionary = world.raid.head_timer(h, holder, Color(1.0, 0.25, 0.2))
		marks[slot]["holder"] = holder
		marks[slot]["label"] = head.label
		marks[slot]["sigil"] = head.sigil


	if h == world.player:
		world.hud.announce(tr("¡Morroc te marcó!"), Color(1.0, 0.3, 0.3), tr("Estallará donde estés: apártate"))
	if world.net == null or not world.net.is_client():
		world.label_over(h, tr("¡Marcado!"), Color(1.0, 0.35, 0.35))
		world.emote(h, "sweat", 1.5)



func _mark_lock(slot: int, at: Vector3) -> void :
	if not marks.has(slot):
		return
	marks[slot].at = at
	var ring = marks[slot].node
	if ring != null and is_instance_valid(ring):
		ring.position = _ground(at) + Vector3(0, 0.05, 0)

		(ring.get_child(0) as Sprite3D).modulate = Color(1.0, 0.1, 0.08, 0.6)
		(ring.get_child(1) as Sprite3D).modulate = Color(1.0, 0.85, 0.7, 1.0)
		ring.scale = Vector3.ONE * 1.08
	world.play_sound("beginspell", 0.0, -6.0)


func _mark_clear(slot: int) -> void :
	if marks.has(slot):
		for key in ["node", "holder", "label"]:
			var n = marks[slot].get(key)
			if n != null and is_instance_valid(n):
				n.queue_free()
		marks.erase(slot)




func _mark_disc(at: Vector3, fill: Color, rim: Color) -> Node3D:
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.position = at + Vector3(0, 0.05, 0)
	var f: = Vfx._flat(root, RoAssets.radial(Color.WHITE, 128), Vector3.ZERO, GameData.MARK_RADIUS, fill)
	f.no_depth_test = true
	f.render_priority = 6
	var r: = Vfx._flat(root, Vfx.ring_texture(), Vector3.ZERO, GameData.MARK_RADIUS, rim)
	r.no_depth_test = true
	r.render_priority = 7
	return root



func _mark_burst(at: Vector3) -> void :
	_send(["hz", "mburst", at])
	_mark_burst_look(at)
	for h in world.heroes:
		if not is_instance_valid(h) or h.downed:
			continue
		if _flat(h.position, at) <= GameData.MARK_RADIUS:
			world.hurt_what = tr("Marca del Apocalipsis")
			h.take_damage(h.max_hp * GameData.MARK_PCT, world, null, true, true)



func _mark_burst_look(at: Vector3) -> void :
	for slot in marks.keys().duplicate():
		var m: Dictionary = marks[slot]
		if m.at != Vector3.INF and _flat(m.at, at) < 0.5:
			_mark_clear(int(slot))
	Vfx.burst(world.fx_root, _ground(at), GameData.MARK_RADIUS, Color(0.85, 0.08, 0.12))
	Vfx.ring(world.fx_root, _ground(at), GameData.MARK_RADIUS * 1.2, Color(1.0, 0.3, 0.2), 0.35)
	world.spawn_fx("hell_in", _ground(at), 1.2)
	world.play_sound("critical_explosion", 0.1, -4.0)
	world.shake(0.25)

	var pool: = _mark_disc(_ground(at), Color(0.75, 0.02, 0.05, 0.8), Color(0.35, 0.0, 0.02, 1.0))


	var entry: = {"at": at, "node": pool, "until": world.clock + GameData.MARK_POOL_TIME}
	_pools.append(entry)
	if _pools.size() > GameData.MARK_POOL_MAX:
		var old: Dictionary = _pools.pop_front()
		if is_instance_valid(old.node):
			old.node.queue_free()
	var tw: = pool.create_tween()
	tw.tween_interval(GameData.MARK_POOL_TIME - 3.0)
	tw.tween_method( func(k: float):
		for c in pool.get_children():
			(c as Sprite3D).modulate.a = k * (0.8 if c.get_index() == 0 else 1.0), 1.0, 0.0, 3.0)
	tw.tween_callback( func():
		_pools.erase(entry)
		pool.queue_free())



func _mark_draw() -> void :
	if marks.is_empty():
		return
	if not world.running:
		for slot in marks.keys():
			_mark_clear(int(slot))
		return
	var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.012)
	for slot in marks.keys():
		var m: Dictionary = marks[slot]
		var ring = m.node
		if ring == null or not is_instance_valid(ring):
			continue
		if m.at == Vector3.INF:
			var h: = _hero_of(int(slot))
			if h != null:
				ring.position = _ground(h.position) + Vector3(0, 0.05, 0)
			(ring.get_child(0) as Sprite3D).modulate.a = 0.22 + 0.2 * pulse

		if world.net != null and world.net.is_client():
			m.t = maxf(0.0, float(m.t) - world.get_process_delta_time())




func _ground(at: Vector3) -> Vector3:
	return Vector3(at.x, world.map.height_at(at), at.z) if world.map != null else at



func _decal(at: Vector3, radius: float, color: Color) -> Sprite3D:
	var s: = Vfx._flat(_gfx, RoAssets.radial(Color.WHITE, 128), at, radius, color)
	s.no_depth_test = true
	s.render_priority = 6
	return s




func _party_dps() -> float:
	return world.party_dealt() / maxf(20.0, world.measure_time()) * 1.5


func _standing() -> Array:
	return world.heroes.filter( func(h): return is_instance_valid(h) and not h.downed)




func _party_center() -> Vector3:
	var list: = _standing()
	if list.size() <= 1:
		return (list[0] as Player).position if list.size() == 1 else world.player.position
	var sum: = Vector3.ZERO
	for h in list:
		sum += (h as Player).position
	var at: = sum / list.size()
	if world.map != null and not world.map.is_walkable(at):
		at = world.map.random_point_around(at, 2.0)
		if not world.map.is_walkable(at):
			at = (list[0] as Player).position
	return _ground(at)


func _later(t: float, fn: Callable) -> void :
	world.get_tree().create_timer(t, false).timeout.connect( func():
		if world.running:
			fn.call())


static func _dir(from: Vector3, to: Vector3) -> Vector3:
	var d: = (to - from) * Vector3(1, 0, 1)
	return d.normalized() if d.length() > 0.01 else Vector3(1, 0, 0)


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
