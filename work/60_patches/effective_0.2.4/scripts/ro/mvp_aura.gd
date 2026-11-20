class_name MvpAura
extends Node3D







var color: = Color.WHITE

var reach: = 1.0
var _glow: MeshInstance3D


func setup(p_color: Color, p_reach: float) -> void :
	color = p_color
	reach = p_reach


func _ready() -> void :
	var prio: = GameData.MVP_UNDER_PRIORITY
	_glow = _plane(RoAssets.radial(Color.WHITE, 128), reach * 4.2, Color(color, 0.22), prio, 0.06)
	var rune: = _plane(RoAssets.effect_tex("mvp_rune"), reach * 3.6, Color(color.lightened(0.15), 0.3), prio, 0.08)
	var hexa: = _plane(RoAssets.effect_tex("mvp_hexa"), reach * 2.2, Color(color.lightened(0.35), 0.18), prio, 0.09)
	if rune != null:
		rune.create_tween().set_loops().tween_property(rune, "rotation:y", TAU, 26.0).as_relative()
	if hexa != null:
		hexa.create_tween().set_loops().tween_property(hexa, "rotation:y", - TAU, 18.0).as_relative()
	var mat: StandardMaterial3D = _glow.material_override
	var tw: = create_tween().set_loops()
	tw.tween_property(mat, "albedo_color:a", 0.1, 1.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(mat, "albedo_color:a", 0.22, 1.6).set_trans(Tween.TRANS_SINE)
	_motes(prio)



func _plane(tex: Texture2D, size: float, col: Color, prio: int, lift: float) -> MeshInstance3D:
	if tex == null:
		return null
	var mi: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * size
	mi.mesh = plane
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
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



func _motes(prio: int) -> void :
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.2, 0.2)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 32)
	pm.render_priority = prio
	quad.material = pm
	p.mesh = quad
	p.amount = 14
	p.lifetime = 2.2
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	p.emission_ring_axis = Vector3.UP
	p.emission_ring_radius = reach * 1.5
	p.emission_ring_inner_radius = reach * 0.7
	p.emission_ring_height = 0.0
	p.direction = Vector3.UP
	p.spread = 12.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 0.5
	p.initial_velocity_max = 1.1
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.3
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(color.lightened(0.3), 0.0))
	ramp.add_point(0.25, Color(color.lightened(0.3), 0.8))
	ramp.set_color(ramp.get_point_count() - 1, Color(color, 0.0))
	p.color_ramp = ramp
	p.position = Vector3(0, 0.15, 0)
	add_child(p)
