extends Node3D













const SOUL: = Color(0.62, 0.82, 1.0)
const DEEP: = Color(0.32, 0.42, 0.95)
const MIST: = Color(0.7, 0.8, 0.95)


const ECHO_EVERY: = 0.07
const ECHO_MOVE: = 0.12
const ECHO_LIFE: = 0.5
const ECHO_ALPHA: = 0.32

var reach: = 1.0
var _boss: Node3D

var _fx: Node3D
var _souls: Array[Node3D] = []
var _angle: = 0.0
var _echo_t: = 0.0
var _echo_at: = Vector3.INF


func setup(boss: Node3D, p_reach: float, fx: Node3D) -> void :
	_boss = boss
	reach = p_reach
	_fx = fx


func _ready() -> void :


	process_mode = Node.PROCESS_MODE_PAUSABLE
	var prio: = GameData.MVP_UNDER_PRIORITY

	for c in _boss.get_children():
		if c is MvpAura:
			c.visible = false
	var glow: = _plane(RoAssets.radial(Color.WHITE, 128), reach * 4.6, Color(DEEP, 0.3), prio, 0.06, true)
	var rune: = _plane(RoAssets.effect_tex("mvp_rune"), reach * 4.2, Color(SOUL, 0.42), prio, 0.08, true)
	var hexa: = _plane(RoAssets.effect_tex("mvp_hexa"), reach * 2.6, Color(SOUL.lightened(0.3), 0.3), prio, 0.09, true)
	var outer: = _plane(Vfx.ring_texture(), reach * 4.5, Color(SOUL, 0.5), prio, 0.07, true)
	if rune != null:
		rune.create_tween().set_loops().tween_property(rune, "rotation:y", - TAU, 30.0).as_relative()
	if hexa != null:
		hexa.create_tween().set_loops().tween_property(hexa, "rotation:y", TAU, 14.0).as_relative()
	for mi in [glow, outer]:
		if mi == null:
			continue
		var m: StandardMaterial3D = mi.material_override
		var a: = m.albedo_color.a
		var tw: = create_tween().set_loops()
		tw.tween_property(m, "albedo_color:a", a * 0.45, 1.8).set_trans(Tween.TRANS_SINE)
		tw.tween_property(m, "albedo_color:a", a, 1.8).set_trans(Tween.TRANS_SINE)
	_mist(prio)
	for i in 3:
		_souls.append(_soul(prio + 6))
	if _boss.get("visual") is RoVisual:
		(_boss.visual as RoVisual).set_glow(Color(0.45, 0.65, 1.0, 0.55))


func _process(delta: float) -> void :
	if _boss == null or not is_instance_valid(_boss):
		return

	_angle += delta * 1.1
	var now: = Time.get_ticks_msec() * 0.001
	for i in _souls.size():
		var a: = _angle + TAU * i / _souls.size()
		var r: = reach * (1.55 + 0.15 * sin(now * 0.9 + i))
		_souls[i].position = Vector3(cos(a) * r, 1.3 + 0.45 * sin(now * 1.7 + i * 2.1), sin(a) * r)
	_echo(delta)



func _echo(delta: float) -> void :
	_echo_t -= delta
	if _echo_t > 0.0:
		return
	_echo_t = ECHO_EVERY
	var at: = _boss.global_position
	if _echo_at != Vector3.INF and _echo_at.distance_to(at) < ECHO_MOVE:
		_echo_at = at
		return
	var first: = _echo_at == Vector3.INF
	_echo_at = at
	if first or Vfx.hidden() or not (_boss.get("visual") is RoVisual):
		return
	var src: Sprite3D = (_boss.visual as RoVisual).sprite
	if src == null or src.texture == null or not src.visible:
		return
	var fx: = _fx
	if fx == null or not is_instance_valid(fx):
		return
	var s: = Sprite3D.new()
	s.texture = src.texture
	s.pixel_size = src.pixel_size
	s.centered = src.centered
	s.offset = src.offset
	s.flip_h = src.flip_h
	s.billboard = src.billboard
	s.texture_filter = src.texture_filter
	s.shaded = false
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	s.render_priority = GameData.MVP_PRIORITY - 1
	s.modulate = Color(1, 1, 1, ECHO_ALPHA)
	fx.add_child(s)
	s.global_transform = src.global_transform
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "modulate:a", 0.0, ECHO_LIFE).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "position:y", s.position.y + 0.25, ECHO_LIFE)
	tw.chain().tween_callback(s.queue_free)



func _plane(tex: Texture2D, size: float, col: Color, prio: int, lift: float, add: bool) -> MeshInstance3D:
	if tex == null:
		return null
	var mi: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * size
	mi.mesh = plane
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if add:
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_texture = tex
	m.albedo_color = col
	m.render_priority = prio
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = Vector3(0, lift, 0)
	add_child(mi)
	return mi



func _mist(prio: int) -> void :
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(1.6, 1.6)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 64)
	pm.render_priority = prio
	quad.material = pm
	p.mesh = quad
	p.amount = 18
	p.lifetime = 3.2
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	p.emission_ring_axis = Vector3.UP
	p.emission_ring_radius = reach * 0.9
	p.emission_ring_inner_radius = reach * 0.3
	p.emission_ring_height = 0.0
	p.direction = Vector3(1, 0, 0)
	p.spread = 180.0
	p.flatness = 1.0
	p.gravity = Vector3(0, 0.05, 0)
	p.initial_velocity_min = 0.5
	p.initial_velocity_max = 0.9
	p.scale_amount_min = 0.8
	p.scale_amount_max = 1.6
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(MIST, 0.0))
	ramp.add_point(0.3, Color(MIST, 0.16))
	ramp.set_color(ramp.get_point_count() - 1, Color(MIST, 0.0))
	p.color_ramp = ramp
	p.position = Vector3(0, 0.3, 0)
	add_child(p)



func _soul(prio: int) -> Node3D:
	var root: = Node3D.new()
	add_child(root)
	for k in [[1.5, Color(DEEP, 0.55)], [0.75, Color(SOUL, 0.8)], [0.3, Color(1, 1, 1, 1.0)]]:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 64)
		s.pixel_size = float(k[0]) / 64.0
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = prio
		s.modulate = k[1]
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.no_depth_test = true
		m.albedo_texture = s.texture
		m.albedo_color = k[1]
		m.render_priority = prio
		s.material_override = m
		root.add_child(s)
	var trail: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.45, 0.45)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.no_depth_test = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 32)
	pm.render_priority = prio - 1
	quad.material = pm
	trail.mesh = quad
	trail.local_coords = false
	trail.amount = 22
	trail.lifetime = 0.55
	trail.gravity = Vector3(0, 0.3, 0)
	trail.initial_velocity_min = 0.0
	trail.initial_velocity_max = 0.05
	trail.scale_amount_min = 0.7
	trail.scale_amount_max = 1.0
	var curve: = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0.1))
	trail.scale_amount_curve = curve
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(SOUL, 0.7))
	ramp.set_color(ramp.get_point_count() - 1, Color(DEEP, 0.0))
	trail.color_ramp = ramp
	root.add_child(trail)
	return root
