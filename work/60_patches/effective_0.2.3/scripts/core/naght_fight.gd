class_name NaghtFight
extends RefCounted




















var raid: MvpRaid
var world: World
var boss: Enemy
var cfg: Dictionary = GameData.NAGHT

var state: = "fight"

var stance: = "fire"
var fight_t: = 0.0
var enraged: = false

var vuln: = 0.0

var _r0: = 14.0
var _shrink: = -1.0
var _jets_t: = 4.0
var _runes_t: = 0.0
var _orbs: Array[Dictionary] = []
var _emitters: Array[Dictionary] = []
var _echoes: Array[Enemy] = []

var _echo_wait: = {}
var _inter_t: = 0.0
var _crash_t: = 0.0
var _crash_at: = Vector3.ZERO
var _aura_t: = 0.0
var _lucile_t: = 18.0
var _hall: Node3D
var _edge: Sprite3D
var _glow: Sprite3D
var _nodes: Array[Node] = []
var _hit_cd: = {}
var _env: Environment
var _env_was: = {}
var _lights: = {}
var _light_tw: Tween

var hel: RefCounted = null


func _init(r: MvpRaid) -> void :
	raid = r
	world = r.world






func begin() -> void :
	boss = raid.boss
	boss.max_hp *= float(cfg.hp)
	boss.hp = boss.max_hp
	boss.damage *= float(cfg.dmg)
	raid._calm_damage = boss.damage
	_r0 = raid.radius
	_hall = Node3D.new()
	world.fx_root.add_child(_hall)
	_hall.global_position = raid.center
	_nodes.append(_hall)

	Vfx.magic_circle(_hall, Vector3(0, 0.05, 0), raid.radius * 0.92, Color(_col("night"), 0.08), 0.0, "mvp_rune", 0.08, 
		GameData.MVP_UNDER_PRIORITY, true)
	Vfx.magic_circle(_hall, Vector3(0, 0.06, 0), raid.radius * 0.45, Color(_col("night").lightened(0.3), 0.07), 0.0, "mvp_hexa", -0.12, 
		GameData.MVP_UNDER_PRIORITY, true)

	for i in 6:
		var a: = TAU * (i + 0.5) / 6.0
		var at: = raid.center + Vector3(cos(a), 0, sin(a)) * (raid.radius + 0.4)
		at.y = world.map.height_at(at)
		var n: = Node3D.new()
		world.fx_root.add_child(n)
		n.global_position = at
		Vfx.beam(n, Vector3.ZERO, _col("fire"), 3.2)
		var g: = Vfx.ground_glow(n, Vector3(0, 0.05, 0), 1.3, Color(_col("fire"), 0.8))
		g.render_priority = GameData.MVP_UNDER_PRIORITY
		_nodes.append(n)
		_emitters.append({"pos": at, "a": a, "node": n})

	_glow = Vfx.ground_glow(boss, Vector3(0, 0.05, 0), boss.radius * 3.4, Color(_col("fire"), 0.75))
	_glow.render_priority = GameData.MVP_UNDER_PRIORITY
	var tw: = _glow.create_tween().set_loops()
	tw.tween_property(_glow, "modulate:a", 0.35, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_glow, "modulate:a", 0.95, 0.5).set_trans(Tween.TRANS_SINE)

	if world.tower != null and world.tower.hel != null:
		_night(Color(0.3, 0.38, 0.6), 0.62, Color(0.6, 0.74, 1.0), 2.5)
	else:
		_night(Color(0.42, 0.4, 0.62), 0.75, Color(0.75, 0.7, 1.0), 2.5)
	world.hud.flash(Color(1.0, 0.4, 0.3), 0.5)
	world.shake(1.0)
	world.play_sound("earth_quake", 0.0, 0.0)
	for i in 8:
		var a: = TAU * i / 8.0
		world.spawn_fx("firepillar", raid.center + Vector3(cos(a), 0, sin(a)) * raid.radius * 0.8, 1.2, 0.7)
	raid._big(tr("NAGHT SIEGER"), tr("Señor de la Endless Tower"), Color(1.0, 0.45, 0.35))
	_lucile(tr("¡Es él, el señor de la torre! ¡Cuidado con las trampas, yo te cubro!"))
	if world.tower != null and world.tower.hel != null:
		hel = preload("res://scripts/core/hel_naght.gd").new(world, self)
		hel.begin()



func on_phase(n: int) -> void :
	match n:
		1:
			_set_stance("ice")
			_lucile(tr("¡Cambió de espada! ¡Ahora es de hielo!"))
		2:
			_set_stance("twin")
			_begin_intermission()
		3:
			_set_stance("twin")


			_night(Color(0.32, 0.18, 0.28), 0.85, Color(1.0, 0.8, 0.78), 3.0)
			_shrink = 0.0
			raid._warn(UiKit.tr_later("¡La cima se derrumba! El borde arde: no te quedes atrás"), Color(1, 0.35, 0.3), "warning")
			_lucile(tr("¡La torre se cae a pedazos! ¡Es ahora o nunca!"))


func _set_stance(s: String) -> void :
	stance = s
	var c: = _stance_color()
	if _glow != null and is_instance_valid(_glow):
		_glow.modulate = Color(c, 0.8)
	world.spawn_fx("efst_ros_bluespirit" if s == "ice" else "efst_ros_redspirit", boss.position, 1.6, 1.0, boss)
	Vfx.column(world.fx_root, boss.position, c)
	world.hud.flash(c, 0.35)


func _stance_color() -> Color:
	match stance:
		"ice":
			return _col("ice")
		"twin":

			return _col("fire").lerp(_col("ice"), 0.5 + 0.5 * sin(fight_t * 3.0))
	return _col("fire")





func tick(delta: float) -> bool:
	if boss == null or not is_instance_valid(boss):
		return false
	world.fx_layer(GameData.MVP_FX_PRIORITY)
	fight_t += delta
	for k in _hit_cd.keys():
		_hit_cd[k] = float(_hit_cd[k]) - delta
	if vuln > 0.0:
		vuln -= delta
	if not enraged and fight_t >= float(cfg.enrage):
		_enrage()
	_tick_aura(delta)

	if not raid.calm():
		_tick_traps(delta)
	_tick_shrink(delta)
	_tick_lucile(delta)
	if hel != null:
		hel.tick(delta)
	var paused: = false
	match state:
		"inter":
			_tick_intermission(delta)
			paused = true
		"crash":
			_crash_t -= delta
			if _crash_t <= 0.0:
				_land()
			paused = true
	world.fx_layer(0)
	return paused


func _tick_aura(delta: float) -> void :
	_aura_t -= delta
	if _glow != null and is_instance_valid(_glow) and stance == "twin":
		_glow.modulate = Color(_stance_color(), _glow.modulate.a)
	if _aura_t > 0.0 or state != "fight":
		return
	_aura_t = 1.1

	var fx: = "icecrash" if stance == "ice" or (stance == "twin" and randf() < 0.5) else "firehit1"
	world.spawn_fx(fx, boss.position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * 1.5, 0.7, 0.45)


func _tick_lucile(delta: float) -> void :
	_lucile_t -= delta
	if _lucile_t > 0.0:
		return
	_lucile_t = randf_range(22.0, 32.0)
	var lines: Array = cfg.lucile
	_lucile(tr(str(lines.pick_random())))

	var h: = raid._target()
	if h != null and state == "fight":
		h.heal(h.max_hp * 0.08, world, true)
		Vfx.heal_light(world.fx_root, h.position)


func _phase_i() -> int:
	return clampi(raid.phase, 0, 3)




func _tick_traps(delta: float) -> void :
	var traps: Dictionary = cfg.traps
	var ph: = _phase_i()
	var jets: Dictionary = traps.jets
	if ph >= int(jets.from):
		_jets_t -= delta * (1.6 if enraged else 1.0)
		if _jets_t <= 0.0:
			_jets_t = float(jets.every[ph])
			for i in int(jets.lanes[ph]):
				_fire_jet(jets)
	var orbs: Dictionary = traps.orbs
	var want: = int(orbs.count[ph]) if ph >= int(orbs.from) else 0
	while _orbs.size() < want:
		_add_orb(orbs)
	_tick_orbs(delta, orbs)
	var runes: Dictionary = traps.runes
	if ph >= int(runes.from):
		_runes_t -= delta * (1.6 if enraged else 1.0)
		if _runes_t <= 0.0:
			_runes_t = float(runes.every[ph])
			_cast_runes(runes)



func _fire_jet(jets: Dictionary) -> void :
	var e: Dictionary = _emitters.pick_random()
	var from: Vector3 = e.pos
	var aim: = raid.center + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * raid.radius * 0.4
	var h: = raid._target()
	if h != null and randf() < 0.5:
		aim = h.position
	var dir: = raid._dir(from, aim)
	var length: = raid.radius * 2.2
	var width: = float(jets.width)
	var warn: = float(jets.warn)
	var tell: = Vfx.telegraph_line(world.fx_root, from, dir, length, width, warn)
	Vfx.burst(world.fx_root, from, 1.5, _col("fire"))
	world.play_sound("fire_pillar", 0.3, -10.0)
	raid._later(warn, func():
		raid._drop_tells([tell])
		Vfx.strike_line(world.fx_root, from, dir, length, width, _col("fire"))
		raid._fx_along("firepillar", from + dir * 0.8, dir, length - 1.0, 2.0)
		world.play_sound("fire_pillar", 0.1, -4.0)
		for hero in raid._standing():
			var rel: = (hero.position - from) * Vector3(1, 0, 1)
			var along: = rel.dot(dir)
			if along > 0.0 and along < length and absf(rel.cross(dir).y) < width * 0.5 + 0.3:
				raid._hit_dmg(float(jets.dmg), hero))


func _add_orb(orbs: Dictionary) -> void :
	var at: = raid._arena_point(0.7, raid._target().position, 6.0)
	var a: = randf() * TAU
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = at + Vector3(0, 0.9, 0)
	var glow: = Vfx.ground_glow(node, Vector3.ZERO, float(orbs.size) * 1.1, Color(_col("ice").lightened(0.3), 0.95))
	glow.axis = Vector3.AXIS_Z
	glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	Vfx.magic_circle(node, Vector3(0, -0.85, 0), float(orbs.size) * 1.2, Color(_col("ice"), 0.75), 0.0, "mvp_seal", 2.5, 
		Vfx.DANGER_PRIORITY, true)
	Vfx.beam(node, Vector3(0, -0.9, 0), _col("ice"), 1.4)
	Vfx.column(world.fx_root, at, _col("ice"))
	world.play_sound("frost_diver", 0.2, -8.0)
	_nodes.append(node)
	_orbs.append({"node": node, "vel": Vector3(cos(a), 0, sin(a)) * float(orbs.speed), "trail": 0.0})




func _tick_orbs(delta: float, orbs: Dictionary) -> void :
	var size: = float(orbs.size)
	for o in _orbs:
		var node: Node3D = o.node
		if not is_instance_valid(node):
			continue
		var at: = node.global_position + (o.vel as Vector3) * delta * (1.4 if enraged else 1.0)
		var rel: = (at - raid.center) * Vector3(1, 0, 1)
		if rel.length() > raid.radius - size:

			var nrm: = rel.normalized()
			o.vel = (o.vel as Vector3) - nrm * 2.0 * (o.vel as Vector3).dot(nrm)
			at = raid.center + nrm * (raid.radius - size)
			Vfx.burst(world.fx_root, at, 1.4, _col("ice"))
		at.y = world.map.height_at(at) + 0.9
		node.global_position = at
		o.trail = float(o.trail) - delta
		if float(o.trail) <= 0.0:
			o.trail = 0.35
			world.spawn_fx("icecrash", at - Vector3(0, 0.9, 0), 0.6, 0.45)
		for h in raid._standing():
			if raid._flat(h.position, at) < size + 0.45 and float(_hit_cd.get(h, 0.0)) <= 0.0:
				_hit_cd[h] = 1.2
				raid._hit_pct(float(orbs.pct), h)
				world.spawn_fx("freezing", h.position, 0.9, 0.9, h)
				var push: = raid._dir(at, h.position) * 2.6
				var to: = world.map.slide(h.position, push)
				h.position = Vector3(to.x, world.map.height_at(to), to.z)
				world.play_sound("frost_hit", 0.1, -4.0)



func _cast_runes(runes: Dictionary) -> void :
	var spots: Array[Vector3] = []
	var h: = raid._target()
	if h != null:
		spots.append(h.position)
	while spots.size() < int(runes.count):
		spots.append(raid._arena_point(0.9))
	var size: = float(runes.size)
	var warn: = float(runes.warn)
	var tells: Array = []
	for s in spots:
		tells.append(Vfx.telegraph_circle(world.fx_root, s, size, warn))
		Vfx.magic_circle(world.fx_root, s, size, Color(_col("night"), 0.7), warn, "mvp_hexa", 2.0, Vfx.DANGER_PRIORITY)
	raid._later(warn, func():
		raid._drop_tells(tells)
		for s in spots:
			Vfx.strike_circle(world.fx_root, s, size, _col("night").lightened(0.2))
			world.spawn_fx("hell_in", s, 1.0, 0.7)
			for hero in raid._standing():
				if raid._flat(hero.position, s) < size:
					raid._hit_dmg(float(runes.dmg), hero)
		world.play_sound("meteor", 0.2, -8.0))



func _tick_shrink(delta: float) -> void :
	if _shrink < 0.0:
		return
	_shrink = minf(1.0, _shrink + delta / float(cfg.shrink_time))
	raid.radius = lerpf(_r0, _r0 * float(cfg.shrink_to), _shrink)
	if _edge == null or not is_instance_valid(_edge):
		_edge = Vfx._flat(_hall, Vfx.ring_texture(), Vector3(0, 0.1, 0), raid.radius, Color(1.0, 0.35, 0.15, 0.6))
		_edge.no_depth_test = true
		_edge.render_priority = Vfx.DANGER_PRIORITY
	_edge.scale = Vector3.ONE * (raid.radius / _r0)
	if randf() < delta * 6.0:
		var a: = randf() * TAU
		world.spawn_fx("firepillar", raid.center + Vector3(cos(a), 0, sin(a)) * raid.radius, 0.9, 0.6)

	for e in _emitters:
		var at: = raid.center + Vector3(cos(float(e.a)), 0, sin(float(e.a))) * (raid.radius + 0.4)
		at.y = world.map.height_at(at)
		e.pos = at
		if is_instance_valid(e.node):
			(e.node as Node3D).global_position = at


func _enrage() -> void :
	enraged = true
	boss.damage *= float(cfg.enrage_dmg)
	raid._calm_damage = boss.damage
	_night(Color(0.25, 0.08, 0.12), 0.7, Color(1.0, 0.65, 0.62), 2.0)
	raid._big(tr("¡LA NOCHE ETERNA!"), tr("Naght Sieger se desata: ¡acaba ya o morirás!"), Color(1.0, 0.25, 0.25))
	raid._chat(boss, tr("Se acabó el tiempo. Ahora... la noche eterna."))
	world.play_sound("warning", 0.0, 2.0)
	world.shake(1.2)




func _begin_intermission() -> void :
	var inter: Dictionary = cfg.intermission
	state = "inter"
	_inter_t = float(inter.time)
	raid._clear_cast()

	world.enemies.erase(boss)
	world.poisoned.erase(boss)
	world._grid_fresh = false
	world.dots.forget(boss)
	boss.hold = 999.0
	Vfx.column(world.fx_root, boss.position, _col("night"))
	world.spawn_fx("hell_in", boss.position, 2.0)
	var tw: Tween = boss.visual.create_tween()
	tw.tween_property(boss.visual, "position:y", 7.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	raid._big(tr("Intermedio: las Espadas Gemelas"), tr("Derrota a los dos ecos a la vez: si uno cae solo, se levanta"), _col("night"))
	raid._chat(boss, tr("Mis espadas pelearán por mí. Ninguna cae sola."))
	_lucile(tr("¡Los dos a la vez! ¡Si uno cae solo, vuelve a levantarse!"))
	for kind in ["fire", "ice"]:
		_spawn_echo(kind)


func _spawn_echo(kind: String) -> void :
	var inter: Dictionary = cfg.intermission
	var a: = 0.0 if kind == "fire" else PI
	var at: = raid.center + Vector3(cos(a), 0, sin(a)) * raid.radius * 0.45
	if not world.map.is_walkable(at):
		at = world.map.random_point_around(at, 1.5)
	Vfx.magic_circle(world.fx_root, at, 1.6, Color(_col(kind), 0.9), 1.2, "mvp_hexa", 2.5)
	Vfx.column(world.fx_root, at, _col(kind))
	world.spawn_fx("firepillar" if kind == "fire" else "icecrash", at, 1.4)
	var e: = world.spawn_enemy("naght_echo_" + kind, at, true)
	if e == null:
		return
	e.summoned = true
	e.max_hp = boss.max_hp * float(inter.echo_hp)
	e.hp = e.max_hp
	e.damage = boss.damage * 0.7
	e.set_meta("echo", kind)
	if e.visual is RoVisual:
		(e.visual as RoVisual).sprite.modulate = _col(kind).lightened(0.25)
	var g: = Vfx.ground_glow(e, Vector3(0, 0.05, 0), 2.6, Color(_col(kind), 0.8))
	g.render_priority = GameData.MVP_UNDER_PRIORITY
	world.spawn_fx("efst_ros_redspirit" if kind == "fire" else "efst_ros_bluespirit", e.position, 1.2, 1.0, e)
	_echoes.append(e)
	raid._shout(e, tr("¡%s!") % tr(str(e.def.name)), _col(kind))


func _tick_intermission(delta: float) -> void :
	var inter: Dictionary = cfg.intermission
	_inter_t -= delta

	if randf() < delta * 0.5:
		var h: = raid._target()
		if h != null:
			var at: = h.position
			var tell: = Vfx.telegraph_circle(world.fx_root, at, 2.4, 1.2)
			raid._later(1.2, func():
				raid._drop_tells([tell])
				Vfx.strike_circle(world.fx_root, at, 2.4, _col("night"))
				world.spawn_fx("meteor1", at, 1.0, 0.8)
				for hero in raid._standing():
					if raid._flat(hero.position, at) < 2.4:
						raid._hit_dmg(1.3, hero))
	var alive: Array[Enemy] = []
	for e in _echoes:
		if is_instance_valid(e) and not e.dead:
			alive.append(e)

	for kind in _echo_wait.keys():
		_echo_wait[kind] = float(_echo_wait[kind]) - delta
		if alive.is_empty():
			break
		if float(_echo_wait[kind]) <= 0.0:
			_echo_wait.erase(kind)
			raid._warn(UiKit.tr_later("¡El eco caído se levanta! Tenían que caer juntos"), Color(1, 0.35, 0.3), "warning")
			_spawn_echo(str(kind))
	for e in _echoes.duplicate():
		if not is_instance_valid(e) or e.dead:
			_echoes.erase(e)
			if alive.size() > 0 and is_instance_valid(e):
				var kind: = str(e.get_meta("echo", "fire"))
				_echo_wait[kind] = float(inter.echo_gap)
				raid._warn(UiKit.tr_later("¡Un eco cayó! Derriba al otro en %d s"), Color(1, 0.85, 0.4), "party_alarm", [roundi(float(inter.echo_gap))])
	if alive.is_empty() and _echoes.is_empty():
		_end_intermission(true)
	elif _inter_t <= 0.0:
		_end_intermission(false)


func _end_intermission(broken: bool) -> void :
	var inter: Dictionary = cfg.intermission
	_echo_wait.clear()
	for e in _echoes:
		if is_instance_valid(e) and not e.dead:
			Vfx.beam_flash(world.fx_root, e.position, _col(str(e.get_meta("echo", "fire"))), 10.0)
			world.banish_enemy(e)
	_echoes.clear()
	if broken:
		raid._warn(UiKit.tr_later("¡Ecos destruidos! Naght Sieger cae aturdido"), Color(0.6, 1, 0.6), "party_alarm")
		_lucile(tr("¡Lo hiciste! ¡Ahora, golpéalo con todo!"))
	else:
		boss.hp = minf(boss.max_hp, boss.hp + boss.max_hp * float(inter.heal))
		boss.damage *= 1.15
		raid._calm_damage = boss.damage
		world.number(raid.center + Vector3(0, 3.0, 0), "+%d" % roundi(boss.max_hp * float(inter.heal)), Color(0.5, 1, 0.5), true)
		raid._warn(UiKit.tr_later("Las espadas vuelven a él: se cura y pega más fuerte"), Color(1, 0.35, 0.3), "warning")

	var h: = raid._target()
	var at: Vector3 = h.position if h != null else raid.center
	at = raid.center + (at - raid.center).limit_length(raid.radius - 2.0)
	at.y = world.map.height_at(at)
	boss.position = at
	_crash_at = at
	_crash_t = 1.4
	Vfx.telegraph_circle(world.fx_root, at, 4.5, 1.4)
	var tw: Tween = boss.visual.create_tween()
	tw.tween_property(boss.visual, "position:y", 0.0, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	world.play_sound("beginspell", 0.0, -2.0)
	state = "crash"
	vuln = 0.0
	_broken = broken



var _broken: = false


func _land() -> void :
	state = "fight"
	boss.visual.position.y = 0.0
	if not world.enemies.has(boss):
		world.enemies.append(boss)
	world._grid_fresh = false
	world.shake(1.2)
	world.hud.flash(Color(1, 0.6, 0.5), 0.4)
	world.play_sound("earth_quake", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.spawn_fx("hell_in", _crash_at, 2.2)
	world.spawn_fx("firepillar", _crash_at, 1.6)
	Vfx.burst(world.fx_root, _crash_at, 6.0, _col("night"))
	Vfx.ring(world.fx_root, _crash_at, 7.0, Color(1, 0.85, 0.7), 0.6)
	for hero in raid._standing():
		if raid._flat(hero.position, _crash_at) < 4.5:
			raid._hit_pct(0.3, hero)
	if _broken:
		vuln = 6.0
		boss.hold = vuln
		raid._shout(boss, tr("¡Aturdido!"), Color(1, 0.8, 0.4))
		world.spawn_fx("stun", boss.position, 1.4, 1.0, boss)
		world.side_word(boss, tr("¡Vulnerable!"), Color(1.0, 0.85, 0.3))
	else:
		boss.hold = 0.8
	for ab in raid.data.abilities:
		raid._timers[ab.id] = maxf(float(raid._timers.get(ab.id, 0.0)), 3.0)




func hero_mult(e: Enemy) -> float:
	if e != boss:
		return 1.0
	if state != "fight":
		return 0.0

	return (1.6 if vuln > 0.0 else 1.0) * (1.0 - float(hel.ward) if hel != null else 1.0)




func start(ab: Dictionary, p: Player, cast: float) -> bool:
	match str(ab.mech):
		"ns_twin_sweep":
			raid.to_center()
			var a0: = atan2(p.position.z - boss.position.z, p.position.x - boss.position.x) + PI * 0.5
			var spin: = (1.0 if randf() < 0.5 else -1.0) * float(ab.turn) / float(ab.time)
			var length: = raid.radius * 2.2
			var tells: = []
			for k in 2:
				var a: = a0 + PI * k
				tells.append(Vfx.telegraph_line(world.fx_root, boss.position, Vector3(cos(a), 0, sin(a)), length, float(ab.width), cast))
				var ahead: = a + signf(spin) * 0.6
				tells.append(Vfx.telegraph_line(world.fx_root, boss.position, Vector3(cos(ahead), 0, sin(ahead)), length * 0.5, 
					float(ab.width) * 0.4, cast))
			boss.hold = maxf(boss.hold, cast + float(ab.time) + 0.3)
			raid._cast = {"ab": ab, "t": cast, "total": cast, "a0": a0, "spin": spin, "tells": tells}
		"ns_brand":
			_brand(ab)
		_:
			return false
	return true


func resolve(c: Dictionary) -> bool:
	var ab: Dictionary = c.ab
	match str(ab.mech):
		"ns_twin_sweep":
			var nodes: Array = []
			for k in 2:
				var col: = _col("fire") if k == 0 else _col("ice")
				nodes.append(raid._make_beam(boss.position, float(c.a0) + PI * k, raid.radius * 2.2, float(ab.width), col))
			raid._objects.append({"kind": "ns_twin", "solo": true, "ab": ab, "t": float(ab.time), "a": float(c.a0), 
				"spin": float(c.spin), "nodes": nodes, "hit": [], "fx": 0.0, "ghost": 0.0, "at": boss.position, 
				"show": str(ab.name), "total": float(ab.time)})
			Vfx.ring(world.fx_root, boss.position, 3.0, Color(1, 1, 1), 0.5)
			world.play_mob_sound(raid.mvp, "attack")
			world.shake(0.4)
		_:
			return false
	return true


func update(o: Dictionary, delta: float) -> bool:
	match str(o.kind):
		"ns_twin":
			o.t = float(o.t) - delta
			o.a = float(o.a) + float(o.spin) * delta
			var at: Vector3 = o.at
			var nodes: Array = o.nodes
			for k in nodes.size():
				var n: Node3D = nodes[k]
				if is_instance_valid(n):
					n.rotation.y = - (float(o.a) + PI * k) - PI * 0.5
			o.ghost = float(o.ghost) - delta
			if float(o.ghost) <= 0.0:
				o.ghost = 0.07
				raid._beam_ghost(at, float(o.a), raid.radius * 2.2, float(o.ab.width), _col("fire"))
				raid._beam_ghost(at, float(o.a) + PI, raid.radius * 2.2, float(o.ab.width), _col("ice"))
			o.fx = float(o.fx) - delta
			if float(o.fx) <= 0.0:
				o.fx = 0.1
				for k in 2:
					var a: = float(o.a) + PI * k
					var d: = Vector3(cos(a), 0, sin(a))
					world.spawn_fx("firepillar" if k == 0 else "icecrash", at + d * randf_range(1.5, raid.radius * 1.3), 1.0, 0.8)
			for h in raid._standing():
				if (o.hit as Array).has(h):
					continue
				var rel: = (h.position - at) * Vector3(1, 0, 1)
				for k in 2:
					var a: = float(o.a) + PI * k
					var d: = Vector3(cos(a), 0, sin(a))
					if rel.dot(d) > 0.0 and absf(rel.cross(d).y) < float(o.ab.width) * 0.5 + 0.3:
						o.hit.append(h)
						Vfx.burst(world.fx_root, h.position, 2.0, _col("fire") if k == 0 else _col("ice"))
						raid._hit_dmg(float(o.ab.dmg), h)
						break
			if float(o.t) <= 0.0:
				for n in nodes:
					raid._fade(n, 0.2)
				o.nodes = []
				return true
		"ns_brand":
			o.t = float(o.t) - delta
			var marks: Dictionary = o.marks
			for h in marks:
				if not is_instance_valid(h):
					continue
				var m: Dictionary = marks[h]
				raid.head_timer_tick(m.sigil, m.label, float(o.t), delta)
				var goal: Vector3 = o.ice_at if m.kind == "fire" else o.fire_at
				var safe: bool = raid._flat(h.position, goal) < float(o.ab.size)
				raid._set_text(m.order, tr("¡QUÉDATE!") if safe else (tr("¡AL HIELO!") if m.kind == "fire" else tr("¡AL FUEGO!")))
				if m.has("line") and is_instance_valid(m.line):
					point_line(m.line, h.position, goal, safe)
			if float(o.t) <= 0.0:
				var fails: = 0
				for h in marks:
					if not is_instance_valid(h) or h.downed:
						continue

					var want: Vector3 = o.ice_at if marks[h].kind == "fire" else o.fire_at
					if raid._flat(h.position, want) < float(o.ab.size):
						world.spawn_fx("holyhit", h.position, 1.0, 0.9)
						world.number(h.position + Vector3(0, 1.6, 0), tr("¡Purificado!"), Color(0.6, 1, 0.7))
					else:
						fails += 1
						world.spawn_fx("firepillar" if marks[h].kind == "fire" else "icecrash", h.position, 1.6, 1.0)
						raid._hit_pct(float(o.ab.pct), h)
				world.play_sound("meteor", 0.0, -2.0 if fails > 0 else -8.0)
				if fails == 0:
					raid._warn(UiKit.tr_later("¡Dualidad rota!"), Color(0.6, 1, 0.6), "party_alarm")
				for n in o.nodes:
					raid._fade(n, 0.3)
				o.nodes = []
				return true
	return false




static func make_line(w: World, col: Color) -> MeshInstance3D:
	var mesh: = BoxMesh.new()
	mesh.size = Vector3(0.3, 0.02, 1.0)
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.albedo_color = Color(col.lightened(0.3), 0.75)
	mesh.material = mat
	var line: = MeshInstance3D.new()
	line.mesh = mesh
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	w.fx_root.add_child(line)
	return line


static func point_line(line: MeshInstance3D, from: Vector3, to: Vector3, safe: bool) -> void :
	line.visible = not safe
	var d: = Vector3(to.x - from.x, 0, to.z - from.z)
	line.position = from + d * 0.5 + Vector3(0, 0.2, 0)
	line.rotation.y = atan2(d.x, d.z)
	line.scale.z = maxf(d.length(), 0.01)



func _brand(ab: Dictionary) -> void :
	var fire_at: = raid._arena_point(0.65)
	var ice_at: = raid._arena_point(0.65, fire_at, raid.radius * 0.9)
	var fz: = raid._zone(fire_at, float(ab.size), _col("fire"), "firewall", 0.8)
	var iz: = raid._zone(ice_at, float(ab.size), _col("ice"), "freezing", 0.8)
	raid._label(fz, tr("FUEGO"), _col("fire").lightened(0.3), 1.4, 64)
	raid._label(iz, tr("HIELO"), _col("ice").lightened(0.3), 1.4, 64)
	var nodes: Array = [fz, iz]
	var marks: = {}
	var i: = 0
	for h in raid._standing():
		var kind: = "fire" if (i % 2 == 0) == (randf() < 0.5) else "ice"
		i += 1



		var other: = "ice" if kind == "fire" else "fire"
		var node: = Node3D.new()
		h.add_child(node)
		var head: = raid.head_timer(h, node, _col(kind))
		var order: = raid._label(h, "", _col(other).lightened(0.35), -1.7, 52)
		world.spawn_fx("efst_ros_redspirit" if kind == "fire" else "efst_ros_bluespirit", h.position, 1.0, 1.0, h)
		marks[h] = {"kind": kind, "label": head.label, "sigil": head.sigil, "order": order}
		nodes.append_array([node, head.label, order])

		raid.warn_hero(h, UiKit.tr_later("¡Te marcó el fuego! Corre al círculo de HIELO") if kind == "fire" else UiKit.tr_later("¡Te marcó el hielo! Corre al círculo de FUEGO"), 
			_col(other).lightened(0.3), "warning")
		if h == world.player:
			var line: = make_line(world, _col(other))
			marks[h]["line"] = line
			nodes.append(line)
		else:
			world.net.send_got(h, "guide", [ice_at if kind == "fire" else fire_at, float(ab.size), _col(other), float(ab.time)])
	raid._objects.append({"kind": "ns_brand", "ab": ab, "t": float(ab.time), "marks": marks, "fire_at": fire_at, "ice_at": ice_at, 
		"nodes": nodes, "show": str(ab.name), "total": float(ab.time)})
	world.play_sound("stone_curse", 0.0, -4.0)




func dbm() -> Array:
	var out: = []
	if state == "inter":
		out.append({"name": tr("Ecos de las espadas"), "left": maxf(0.0, _inter_t), "total": float(cfg.intermission.time), 
			"lethal": true, "now": true})
	if not enraged:
		var left: = float(cfg.enrage) - fight_t
		if left < 120.0:
			out.append({"name": tr("Noche eterna (enrage)"), "left": maxf(0.0, left), "total": 120.0, "lethal": true, "now": true})
	return out



func goal(p: Player) -> Vector3:
	for o in raid._objects:
		match str(o.kind):
			"ns_brand":
				var marks: Dictionary = o.marks
				if marks.has(p):
					return o.ice_at if marks[p].kind == "fire" else o.fire_at
			"ns_twin":
				var back: = float(o.a) - signf(float(o.spin)) * 1.0
				return boss.position + Vector3(cos(back), 0, sin(back)) * 3.5
	if not raid._cast.is_empty() and str(raid._cast.ab.mech) == "ns_twin_sweep":
		var back: = float(raid._cast.a0) + PI * 0.5
		return boss.position + Vector3(cos(back), 0, sin(back)) * 3.0

	for o in _orbs:
		if is_instance_valid(o.node) and raid._flat(p.position, (o.node as Node3D).global_position) < 3.0:
			return p.position + raid._dir((o.node as Node3D).global_position, p.position) * 3.0
	if state == "inter":
		for e in _echoes:
			if is_instance_valid(e) and not e.dead:
				return e.position + raid._dir(e.position, p.position) * 1.5
	return Vector3.INF





func won() -> void :
	_clear_traps()
	if hel != null:
		hel.finish()
	if _glow != null and is_instance_valid(_glow):
		_glow.queue_free()
	var at: = boss.position
	world.hold_chests(8.5)
	raid._chat(boss, tr(str(cfg.victory)))
	world.hud.flash(Color(1, 1, 1), 0.8)
	world.shake(1.4)
	world.play_sound("earth_quake", 0.0, 2.0)
	for i in 12:
		var a: = TAU * i / 12.0
		var spot: = raid.center + Vector3(cos(a), 0, sin(a)) * raid.radius * randf_range(0.3, 0.9)
		raid._later(0.12 * i, func():
			world.spawn_fx("firepillar" if i % 2 == 0 else "icecrash", spot, 1.4, 0.9)
			Vfx.column(world.fx_root, spot, _col("fire") if i % 2 == 0 else _col("ice")))
	Vfx.burst(world.fx_root, at, 9.0, Color(1, 0.9, 0.7))
	Vfx.ring(world.fx_root, at, raid.radius, Color(1, 0.95, 0.8), 1.4)
	world.spawn_fx("lord", at, 2.0)
	_night_off()
	raid._later(1.6, func():
		raid._big(tr("¡NAGHT SIEGER HA CAÍDO!"), tr("Niflheim es tuyo") if hel != null else tr("La cima de la Endless Tower es tuya"), Color(1.0, 0.85, 0.4))

		world.hud.npc_talk("tnm_lucile01", tr("Lucile"), [tr("¡Lo lograste! ¡Sabía que podías!"), 
			tr("¡Lo logramos! ¡La torre es nuestra! ...pero sigue subiendo, ¿verdad?")])
		if raid._npc != null and is_instance_valid(raid._npc):
			world.emote(raid._npc, "love", 3.0))



func finish() -> void :
	_clear_traps()
	if hel != null:
		hel.finish()
	for e in _echoes:
		if is_instance_valid(e) and not e.dead:
			world.banish_enemy(e)
	_echoes.clear()
	_restore_light()
	if boss != null and is_instance_valid(boss) and boss.visual != null:
		boss.visual.position.y = 0.0


func _clear_traps() -> void :
	for n in _nodes:
		if is_instance_valid(n):
			n.queue_free()
	_nodes.clear()
	_orbs.clear()
	_emitters.clear()
	_shrink = -1.0
	_edge = null




func _col(key: String) -> Color:
	return Color(cfg[key])


func _lucile(text: String) -> void :
	if raid._npc != null and is_instance_valid(raid._npc):
		raid._chat(raid._npc, text, Color(0.8, 0.75, 1.0))



func _night(amb: Color, amb_k: float, sun: Color, t: float) -> void :
	if _env == null:
		for c in world.get_children():
			if c is WorldEnvironment:
				_env = c.environment
	if _light_tw != null:
		_light_tw.kill()
	_light_tw = world.create_tween().set_parallel()
	if _env != null:
		if _env_was.is_empty():
			_env_was = {"color": _env.ambient_light_color, "energy": _env.ambient_light_energy}
		_light_tw.tween_property(_env, "ambient_light_color", amb, t)
		_light_tw.tween_property(_env, "ambient_light_energy", float(_env_was.energy) * amb_k, t)
	var suns: Array = world.map.find_children("*", "DirectionalLight3D", true, false)
	for c in world.get_children():
		if c is DirectionalLight3D:
			suns.append(c)
	for l: DirectionalLight3D in suns:
		if not _lights.has(l):
			_lights[l] = {"energy": l.light_energy, "color": l.light_color}
		_light_tw.tween_property(l, "light_energy", float(_lights[l].energy) * amb_k, t)
		_light_tw.tween_property(l, "light_color", sun, t)


func _night_off() -> void :
	if _light_tw != null:
		_light_tw.kill()
	_light_tw = world.create_tween().set_parallel()
	if _env != null and not _env_was.is_empty():
		_light_tw.tween_property(_env, "ambient_light_color", _env_was.color, 2.5)
		_light_tw.tween_property(_env, "ambient_light_energy", _env_was.energy, 2.5)
	for l in _lights:
		if is_instance_valid(l):
			_light_tw.tween_property(l, "light_energy", _lights[l].energy, 2.5)
			_light_tw.tween_property(l, "light_color", _lights[l].color, 2.5)
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
