extends RefCounted













var fight: RefCounted
var raid: MvpRaid
var world: World
var cfg: Dictionary = GameData.HEL_NAGHT


var _souls: = {}
var _soul_id: = 0
var _soul_t: = 0.0
var _judge_t: = 0.0

var _judge: = {}
var _fed: = 0




var ward: = 0.0
var _dealt: Array = []
var _last_hp: = -1.0



func _init(w: World, f: RefCounted = null) -> void :
	fight = f
	world = w
	raid = w.raid
	_soul_t = float(cfg.soul_first)
	_judge_t = float(cfg.judge_first)


func begin() -> void :
	_presence()

	_send(["look"])
	raid._big(tr("NAGHT SIEGER"), tr("Tocado por Niflheim"), Color(0.7, 0.5, 1.0))
	world.get_tree().create_timer(2.5, false).timeout.connect( func():
		if world.running:
			fight._lucile(tr("¡Las almas de Niflheim lo alimentan! ¡Ponte en su camino para romperlas!")))



func tick(delta: float) -> void :
	var boss: = _boss()
	if boss == null or not is_instance_valid(boss) or boss.dead:
		return
	_presence()
	var ph: int = fight._phase_i()
	var fighting: bool = fight.state == "fight"
	_tick_ward(boss)

	if fighting:
		_soul_t -= delta
		if _soul_t <= 0.0:
			_soul_t = float((cfg.soul_every as Array)[ph])
			for i in int((cfg.soul_count as Array)[ph]):
				_add_soul()
	_tick_souls(delta, boss)

	if not _judge.is_empty():
		_tick_judge(delta)
	elif fighting and ph >= int(cfg.judge_from) and raid._cast.is_empty() and not raid.calm():
		_judge_t -= delta
		if _judge_t <= 0.0:
			_judge_t = float(cfg.judge_every) * randf_range(0.9, 1.15)
			_start_judge()



func _tick_ward(boss: Enemy) -> void :
	if _last_hp < 0.0:
		_last_hp = boss.hp
	var lost: = maxf(0.0, _last_hp - boss.hp)
	_last_hp = boss.hp
	var window: = float(cfg.ward_window)
	if lost > 0.0:
		_dealt.append([world.clock, lost])
	while not _dealt.is_empty() and world.clock - float(_dealt[0][0]) > window:
		_dealt.pop_front()
	var sum: = 0.0
	for d in _dealt:
		sum += float(d[1])
	var rate: = sum / window / maxf(1.0, boss.max_hp)
	ward = float(cfg.ward_max) * clampf(rate / float(cfg.ward_full), 0.0, 1.0)




func _add_soul() -> void :
	var a: = randf() * TAU
	var at: = raid.center + Vector3(cos(a), 0, sin(a)) * raid.radius * 0.97
	_soul_id += 1
	_make_soul(_soul_id, at)
	_send(["soul", _soul_id, at])



func _make_soul(id: int, at: Vector3) -> void :
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	var glow: = Sprite3D.new()
	glow.texture = RoAssets.radial(Color.WHITE, 64)
	glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glow.no_depth_test = true
	glow.render_priority = 16
	glow.pixel_size = 0.022
	glow.modulate = Color(0.55, 0.85, 1.0, 0.95)
	glow.position = Vector3(0, 1.1, 0)
	node.add_child(glow)
	var core: = Sprite3D.new()
	core.texture = glow.texture
	core.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	core.no_depth_test = true
	core.render_priority = 17
	core.pixel_size = 0.009
	core.modulate = Color(1, 1, 1, 1)
	core.position = glow.position
	node.add_child(core)
	var bob: = node.create_tween().set_loops()
	bob.tween_property(glow, "position:y", 1.45, 0.7).set_trans(Tween.TRANS_SINE)
	bob.tween_property(glow, "position:y", 1.1, 0.7).set_trans(Tween.TRANS_SINE)
	var bob2: = node.create_tween().set_loops()
	bob2.tween_property(core, "position:y", 1.45, 0.7).set_trans(Tween.TRANS_SINE)
	bob2.tween_property(core, "position:y", 1.1, 0.7).set_trans(Tween.TRANS_SINE)
	var ring: = Vfx.ground_glow(node, Vector3(0, 0.05, 0), float(cfg.soul_block), Color(0.5, 0.8, 1.0, 0.45))
	ring.no_depth_test = true
	var line: = _make_line(Color(0.5, 0.8, 1.0, 0.35))
	world.spawn_fx("hell_in", at, 0.7, 0.6)
	_souls[id] = {"node": node, "at": at, "line": line}


func _tick_souls(delta: float, boss: Enemy) -> void :
	var host: bool = not world.net.is_client()
	for id in _souls.keys():
		var s: Dictionary = _souls[id]
		var at: Vector3 = s.at
		var to: = (boss.position - at) * Vector3(1, 0, 1)
		var d: = to.length()
		var step: = float(cfg.soul_speed) * delta
		at = at + to.normalized() * minf(step, d) if d > 0.01 else at
		s.at = at
		if is_instance_valid(s.node):
			(s.node as Node3D).global_position = Vector3(at.x, world.map.height_at(at), at.z)
		if is_instance_valid(s.line):
			_point_line(s.line, at, boss.position)
		if not host:

			if d < 0.3:
				_soul_fx(id, true)
			continue

		for h in raid._standing():
			if raid._flat(h.position, at) < float(cfg.soul_block):
				_soul_done(id, false, h)
				break
		if _souls.has(id) and d < boss.radius + 0.8:
			_soul_done(id, true)


func _soul_done(id: int, fed: bool, by: Player = null) -> void :
	_soul_fx(id, fed)
	_send(["sdone", id, fed])
	var boss: = _boss()
	if fed and boss != null and is_instance_valid(boss):
		_fed += 1
		boss.hp = minf(boss.max_hp, boss.hp + boss.max_hp * float(cfg.soul_heal))
		if _fed <= int(cfg.soul_dmg_max):
			boss.damage *= 1.0 + float(cfg.soul_dmg)
		world.number(boss.position + Vector3(0, 3.0, 0), tr("¡Un alma lo alimenta!"), Color(0.6, 0.85, 1.0), true)
		world.play_sound("heal", 0.0, -2.0)
	elif by != null:
		world.number(by.position + Vector3(0, 2.4, 0), tr("¡Alma rota!"), Color(0.75, 0.9, 1.0))



func _soul_fx(id: int, fed: bool) -> void :
	if not _souls.has(id):
		return
	var s: Dictionary = _souls[id]
	_souls.erase(id)
	var at: Vector3 = s.at
	if is_instance_valid(s.node):
		(s.node as Node3D).queue_free()
	if is_instance_valid(s.line):
		(s.line as Node3D).queue_free()
	if fed:
		var boss: = _boss()
		if boss != null and is_instance_valid(boss):
			Vfx.column(world.fx_root, boss.position, Color(0.55, 0.8, 1.0))
	else:
		world.spawn_fx("icecrash", at, 0.9, 0.7)
		Vfx.burst(world.fx_root, at, 1.6, Color(0.7, 0.9, 1.0))
		world.play_sound("gem_ding", 0.0, -8.0)




func _start_judge() -> void :
	var a: = randf() * TAU
	var n: = Vector3(cos(a), 0, sin(a))
	var marks: = {}
	var i: = 0
	var first: = randf() < 0.5
	for h in raid._standing():
		marks[h] = "fire" if (i % 2 == 0) == first else "ice"
		i += 1
	_make_judge(n, float(cfg.judge_time))
	_judge.marks = marks

	var nodes: Array = _judge.nodes
	for h in marks:
		var kind: String = marks[h]
		var other: = "ice" if kind == "fire" else "fire"
		var node: = Node3D.new()
		h.add_child(node)
		var head: = raid.head_timer(h, node, _c(kind))
		var order: = raid._label(h, "", _c(other).lightened(0.35), -1.7, 52)
		world.spawn_fx("efst_ros_redspirit" if kind == "fire" else "efst_ros_bluespirit", h.position, 1.0, 1.0, h)
		marks[h] = {"kind": kind, "label": head.label, "sigil": head.sigil, "order": order}
		nodes.append_array([node, head.label, order])

		raid.warn_hero(h, UiKit.tr_later("¡Juicio de Hel! Marca de FUEGO: ve a la mitad de HIELO") if kind == "fire"
			else UiKit.tr_later("¡Juicio de Hel! Marca de HIELO: ve a la mitad de FUEGO"), _c(other).lightened(0.3), "warning")
	_send(["judge", n, float(cfg.judge_time)])
	raid._warn(UiKit.tr_later("¡El juicio de Hel parte la sala en fuego y hielo!"), Color(0.75, 0.55, 1.0), "party_alarm")
	world.play_sound("stone_curse", 0.0, -4.0)




func _make_judge(n: Vector3, t: float) -> void :
	_judge_clear()
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.global_position = Vector3(raid.center.x, world.map.height_at(raid.center) + 0.09, raid.center.z)
	var r: float = raid.radius
	var base_a: = atan2(n.x, n.z)
	var fire: = Vfx._fan(root, r, PI, base_a, Color(_c("fire"), 0.32), 0.0)
	var ice: = Vfx._fan(root, r, PI, base_a + PI, Color(_c("ice").lerp(Color(0.25, 0.55, 1.0), 0.5), 0.55), 0.0)
	Vfx._fan_rim(root, r, PI, base_a, Color(_c("fire").lightened(0.2), 0.9))
	Vfx._fan_rim(root, r, PI, base_a + PI, Color(_c("ice").lightened(0.2), 0.9))
	for f in [fire, ice]:
		var tw: = (f as Node3D).create_tween().set_loops()
		tw.tween_property(f, "scale", Vector3(1.0, 1.0, 1.0) * 0.97, 0.45).set_trans(Tween.TRANS_SINE)
		tw.tween_property(f, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_SINE)
	var fz: = Node3D.new()
	root.add_child(fz)
	fz.position = n * r * 0.5
	var iz: = Node3D.new()
	root.add_child(iz)
	iz.position = - n * r * 0.5
	raid._label(fz, tr("FUEGO"), _c("fire").lightened(0.3), 1.4, 64)
	raid._label(iz, tr("HIELO"), _c("ice").lightened(0.3), 1.4, 64)
	var seam: = Vfx.telegraph_line(world.fx_root, raid.center - Vector3( - n.z, 0, n.x) * r, Vector3( - n.z, 0, n.x), r * 2.0, 0.5, t)
	_judge = {"t": t, "total": t, "n": n, "nodes": [root, seam], "marks": {}}


func _tick_judge(delta: float) -> void :
	_judge.t = float(_judge.t) - delta
	var n: Vector3 = _judge.n
	var marks: Dictionary = _judge.marks
	for h in marks:
		if not is_instance_valid(h):
			continue
		var m: Dictionary = marks[h]
		raid.head_timer_tick(m.sigil, m.label, float(_judge.t), delta)
		var fire_side: bool = ((h.position - raid.center) * Vector3(1, 0, 1)).dot(n) > 0.0
		var safe: bool = fire_side != (m.kind == "fire")
		raid._set_text(m.order, tr("¡QUÉDATE!") if safe else (tr("¡AL HIELO!") if m.kind == "fire" else tr("¡AL FUEGO!")))
	if float(_judge.t) > 0.0:
		return
	if not world.net.is_client():
		var fails: = 0
		for h in marks:
			if not is_instance_valid(h) or h.downed:
				continue
			var fire_side: bool = ((h.position - raid.center) * Vector3(1, 0, 1)).dot(n) > 0.0
			if fire_side != (marks[h].kind == "fire"):
				world.spawn_fx("holyhit", h.position, 1.0, 0.9)
			else:
				fails += 1
				world.spawn_fx("firepillar" if marks[h].kind == "fire" else "icecrash", h.position, 1.6, 1.0)
				raid._now_name = tr("El juicio de Hel")
				raid._hit_pct(float(cfg.judge_pct), h)
		world.play_sound("meteor", 0.0, -2.0 if fails > 0 else -8.0)
		if fails == 0:
			raid._warn(UiKit.tr_later("¡Juicio superado!"), Color(0.6, 1, 0.6), "party_alarm")

	var r: float = raid.radius
	for k in 8:
		var a: = TAU * k / 8.0
		var at: = raid.center + Vector3(cos(a), 0, sin(a)) * r * randf_range(0.3, 0.85)
		var fire_side: bool = ((at - raid.center) * Vector3(1, 0, 1)).dot(n) > 0.0
		world.spawn_fx("firepillar" if fire_side else "icecrash", at, 1.2, 0.8)
	world.shake(0.6)
	_judge_clear()


func _judge_clear() -> void :
	for nd in _judge.get("nodes", []):
		if nd != null and is_instance_valid(nd):
			(nd as Node).queue_free()
	_judge = {}



func finish() -> void :
	if _ash != null and is_instance_valid(_ash):
		_ash.queue_free()
	_ash = null
	for id in _souls.keys():
		var s: Dictionary = _souls[id]
		for k in ["node", "line"]:
			if is_instance_valid(s[k]):
				(s[k] as Node).queue_free()
	_souls.clear()
	_judge_clear()



func _make_line(col: Color) -> MeshInstance3D:
	var mesh: = BoxMesh.new()
	mesh.size = Vector3(0.25, 0.02, 1.0)
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.albedo_color = col
	mesh.material = mat
	var line: = MeshInstance3D.new()
	line.mesh = mesh
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(line)
	return line


static func _point_line(line: MeshInstance3D, from: Vector3, to: Vector3) -> void :
	var d: = Vector3(to.x - from.x, 0, to.z - from.z)
	line.position = from + d * 0.5 + Vector3(0, 0.2, 0)
	line.rotation.y = atan2(d.x, d.z)
	line.scale.z = maxf(d.length(), 0.01)




func _presence() -> void :
	if _ash == null and raid.radius > 0.0:
		_ashes()
	var boss: = _boss()
	if boss == null or boss.dead or boss.has_meta("hel_look"):
		return
	boss.set_meta("hel_look", true)
	var look: Node3D = preload("res://scripts/ro/hel_presence.gd").new()
	look.setup(boss, boss.radius, world.fx_root)
	boss.add_child(look)




var _ash: Node3D = null
func _ashes() -> void :
	_ash = Node3D.new()
	world.fx_root.add_child(_ash)
	_ash.global_position = raid.center + Vector3(0, 7.5, 0)
	for k in [[90, 0.13, Color(0.78, 0.84, 0.95, 0.55), 7.0], [14, 0.24, Color(0.62, 0.82, 1.0, 0.9), 6.0]]:
		var p: = CPUParticles3D.new()
		var quad: = QuadMesh.new()
		quad.size = Vector2.ONE * float(k[1])
		var pm: = StandardMaterial3D.new()
		pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		pm.vertex_color_use_as_albedo = true
		pm.albedo_texture = RoAssets.radial(Color.WHITE, 32)
		pm.render_priority = GameData.MVP_UNDER_PRIORITY
		quad.material = pm
		p.mesh = quad
		p.amount = int(k[0])
		p.lifetime = float(k[3])
		p.preprocess = float(k[3])
		p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		p.emission_box_extents = Vector3(raid.radius, 0.2, raid.radius)
		p.direction = Vector3(0.3, -1, 0.1)
		p.spread = 25.0
		p.gravity = Vector3(0, -0.4, 0)
		p.initial_velocity_min = 0.4
		p.initial_velocity_max = 0.9
		var ramp: = Gradient.new()
		ramp.set_color(0, Color(k[2], 0.0))
		ramp.add_point(0.15, k[2])
		ramp.add_point(0.8, k[2])
		ramp.set_color(ramp.get_point_count() - 1, Color(k[2], 0.0))
		p.color_ramp = ramp
		_ash.add_child(p)


func _boss() -> Enemy:
	var b = fight.boss if fight != null else world.boss
	if b == null or not is_instance_valid(b):
		return null
	return b if b is Enemy else null


func _c(key: String) -> Color:
	return Color(GameData.NAGHT[key])




func _send(ev: Array) -> void :
	if world.net != null and world.net.recording():
		world.net.record(["hz", "hn"] + ev)



func net_event(ev: Array) -> void :
	match str(ev[2]):
		"soul":
			_make_soul(int(ev[3]), ev[4])
		"sdone":
			_soul_fx(int(ev[3]), bool(ev[4]))
		"judge":
			_make_judge(ev[3], float(ev[4]))
		"look":
			_presence()



func draw_tick(delta: float) -> void :
	var boss: = _boss()
	if boss != null and is_instance_valid(boss):
		_presence()
		_tick_souls(delta, boss)
	if not _judge.is_empty():
		_judge.t = float(_judge.t) - delta
		if float(_judge.t) <= -0.5:
			_judge_clear()
