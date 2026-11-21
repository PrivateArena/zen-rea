class_name Weather
extends Node













var world: World

var clock: = 0.0


var kind: = "clear"
var _next: = 0.0
var _sync: = 0.0
var _on: = false

var _amount: = 0.0
var _want: = ""
var _flash_t: = 0.0
var _bat_t: = 0.0

var _layer: CanvasLayer
var _tint: ColorRect
var _tint_mat: ShaderMaterial
var _fx_layer: CanvasLayer
var _flash: ColorRect
var _puffs: Array[TextureRect] = []
var _bats: Array = []
var _fall: Node3D
var _rain: GPUParticles3D
var _splash: GPUParticles3D
var _snow: GPUParticles3D
var _leaves: GPUParticles3D
static var _tint_shader: Shader


func _ready() -> void :
	name = "Weather"

	_layer = CanvasLayer.new()
	_layer.layer = -3
	add_child(_layer)
	_tint = ColorRect.new()
	_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _tint_shader == null:
		_tint_shader = Shader.new()
		_tint_shader.code = "shader_type canvas_item;\r\nrender_mode blend_mul;\r\nuniform vec4 tint : source_color = vec4(1.0);\r\nuniform float edge = 0.0;\r\n// The heroes' own glow at night (screen pixels): the dark lifts around them.\r\nuniform vec2 lights[4];\r\nuniform int light_n = 0;\r\nuniform float light_r = 160.0;\r\nuniform float glow = 0.0;\r\nvoid fragment() {\r\n\t// The light's colour, a little darker towards the corners at night.\r\n\tvec2 p = UV * 2.0 - 1.0;\r\n\tfloat v = 1.0 - edge * smoothstep(0.35, 1.5, length(p * vec2(1.0, 1.2)));\r\n\tvec3 c = tint.rgb * v;\r\n\tfloat lit = 0.0;\r\n\tfor (int i = 0; i < light_n; i++) {\r\n\t\tvec2 d = (FRAGCOORD.xy - lights[i]) * vec2(1.0, 1.35);\r\n\t\tlit = max(lit, 1.0 - smoothstep(0.0, light_r, length(d)));\r\n\t}\r\n\t// A warm lantern light.\r\n\tc = mix(c, vec3(1.0, 0.95, 0.82), pow(lit, 1.6) * glow);\r\n\tCOLOR = vec4(c, 1.0);\r\n}"






















	_tint_mat = ShaderMaterial.new()
	_tint_mat.shader = _tint_shader
	_tint.material = _tint_mat
	_tint.visible = false
	_layer.add_child(_tint)

	_fx_layer = CanvasLayer.new()
	_fx_layer.layer = -2
	add_child(_fx_layer)
	for i in WEATHER_PUFFS:
		var puff: = TextureRect.new()
		puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
		puff.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		puff.stretch_mode = TextureRect.STRETCH_SCALE
		puff.visible = false
		_fx_layer.add_child(puff)
		_puffs.append(puff)
	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(0.85, 0.9, 1.0, 0.0)
	var add: = CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_flash.material = add
	_flash.visible = false
	_fx_layer.add_child(_flash)


const WEATHER_PUFFS: = 7




func reset() -> void :
	clock = randf_range(0.0, GameData.WEATHER_DAY * 0.6)
	kind = "clear"
	_want = ""
	_amount = 0.0
	_sync = 0.0
	_next = 0.0
	_bat_t = randf_range(4.0, 10.0)
	if _defs().is_empty() or world.net.is_client():
		return
	_roll()



func _defs() -> Dictionary:

	if world.festival_mode:
		return GameData.WEATHER.get("festival", {})
	return GameData.WEATHER.get(world.stage_id, {})


func _roll() -> void :
	var kinds: Array = _defs().get("kinds", ["clear"])
	var pick: = str(kinds.pick_random())


	for i in 3:
		if pick != kind:
			break
		pick = str(kinds.pick_random())
	_set_kind(pick)
	_next = randf_range(GameData.WEATHER_EVERY[0], GameData.WEATHER_EVERY[1])
	_send()


func _send() -> void :
	if world.net.is_host():
		world.net.sky(clock, _want if _want != "" else kind)
	_sync = 15.0



func apply(at: float, k: String) -> void :
	clock = at
	if k != kind and k != _want:
		_set_kind(k)



func _set_kind(k: String) -> void :
	if k == kind and _want == "":
		return
	_want = k


func _shown() -> bool:
	if world == null or not world.running or world.town != null or world.tower != null or world.map == null:
		return false
	if world.raid != null and world.raid.in_arena():
		return false
	return not _defs().is_empty() and world.map.map_name == str(world.stage.map) and bool(Save.setting("weather", true))


func _process(delta: float) -> void :
	var on: = _shown()
	if on != _on:
		_on = on
		if not on:
			_hide_all()
	if not on:
		return
	clock = fmod(clock + delta, _cycle())
	if not world.net.is_client():
		_next -= delta
		if _next <= 0.0:
			_roll()
		_sync -= delta
		if _sync <= 0.0:
			_send()

	if _want != "":
		_amount = maxf(0.0, _amount - delta / GameData.WEATHER_FADE)
		if _amount <= 0.0:
			kind = _want
			_want = ""
	elif kind != "clear":
		_amount = minf(1.0, _amount + delta / GameData.WEATHER_FADE)
	_light()
	_follow()
	_falling()
	_screen(delta)


func _cycle() -> float:
	return GameData.WEATHER_DAY + GameData.WEATHER_DUSK + GameData.WEATHER_NIGHT + GameData.WEATHER_DAWN



func night() -> float:
	if _defs().get("always_night", false):
		return 1.0
	var t: = clock
	var day: = GameData.WEATHER_DAY
	var dusk: = GameData.WEATHER_DUSK
	var nite: = GameData.WEATHER_NIGHT
	if t < day:
		return 0.0
	t -= day
	if t < dusk:
		return smoothstep(0.0, 1.0, t / dusk)
	t -= dusk
	if t < nite:
		return 1.0
	t -= nite
	return 1.0 - smoothstep(0.0, 1.0, t / GameData.WEATHER_DAWN)



func phase() -> String:
	if _defs().get("always_night", false):
		return "night"
	var t: = clock
	if t < GameData.WEATHER_DAY:
		return "day"
	t -= GameData.WEATHER_DAY
	if t < GameData.WEATHER_DUSK:
		return "dusk"
	t -= GameData.WEATHER_DUSK
	return "night" if t < GameData.WEATHER_NIGHT else "dawn"




func _light() -> void :
	var n: = night()
	var deep: = float(_defs().get("night_k", 1.0))
	var night_col: Color = GameData.WEATHER_NIGHT_TINT.lerp(Color.BLACK, (deep - 1.0) * 0.5)
	var col: = Color.WHITE
	var ph: = phase()
	if ph == "dusk" or ph == "dawn":

		var warm: Color = GameData.WEATHER_DUSK_TINT
		col = Color.WHITE.lerp(warm, minf(1.0, n * 2.0)).lerp(night_col, maxf(0.0, n * 2.0 - 1.0))
	elif n > 0.0:
		col = night_col
	var grey: float = GameData.WEATHER_GREY.get(kind, 0.0) * _amount
	col = col.lerp(Color(col.v, col.v, col.v) * 0.78, grey)
	_tint.visible = col != Color.WHITE
	_tint_mat.set_shader_parameter("tint", col)
	_tint_mat.set_shader_parameter("edge", 0.35 * n)
	_hero_glow(n)



func _hero_glow(n: float) -> void :
	var pts: = PackedVector2Array()
	if n > 0.0:
		var view: = world.get_viewport().get_visible_rect().size

		var k: = Vector2(world.get_viewport().get_final_transform().get_scale())
		for h in world.heroes:
			if pts.size() >= 4 or not is_instance_valid(h) or h.downed:
				continue
			var at: = world.camera.unproject_position(h.position + Vector3(0, 1.0, 0))
			if at.x > -200.0 and at.y > -200.0 and at.x < view.x + 200.0 and at.y < view.y + 200.0:
				pts.append(at * k)
		_tint_mat.set_shader_parameter("light_r", GameData.WEATHER_GLOW_R * view.y / 720.0 * k.y)
	var arr: Array[Vector2] = []
	for i in 4:
		arr.append(pts[i] if i < pts.size() else Vector2(-9999, -9999))
	_tint_mat.set_shader_parameter("lights", arr)
	_tint_mat.set_shader_parameter("light_n", pts.size())
	_tint_mat.set_shader_parameter("glow", GameData.WEATHER_GLOW * n)



func _follow() -> void :
	if _fall == null:
		_build_fall()
	var focus: = world.camera.position - world.cam_offset()
	_fall.position = focus


func _falling() -> void :
	var rain: = kind in ["rain", "storm"]
	_show(_rain, rain)
	_show(_splash, rain)
	_show(_snow, kind == "snow")
	_show(_leaves, kind == "leaves")
	if _snow.visible:
		var grey: bool = _defs().get("grey_snow", false)
		(_snow.draw_pass_1.surface_get_material(0) as StandardMaterial3D).albedo_color = Color(0.7, 0.7, 0.78, 0.85) if grey else Color(1, 1, 1, 0.95)


func _show(p: GPUParticles3D, on: bool) -> void :
	p.visible = on and _amount > 0.0
	p.emitting = p.visible
	p.amount_ratio = _amount


func _hide_all() -> void :
	_tint.visible = false
	_flash.visible = false
	for p in _puffs:
		p.visible = false
	for b in _bats:
		if is_instance_valid(b.node):
			b.node.queue_free()
	_bats.clear()
	if _fall != null:
		for p: GPUParticles3D in [_rain, _splash, _snow, _leaves]:
			p.emitting = false
			p.visible = false



func _screen(delta: float) -> void :
	var view: = world.get_viewport().get_visible_rect().size
	var fog: bool = kind == "fog" or (kind == "snow" and _defs().get("grey_snow", false))
	var clouds: = kind in ["clouds", "storm", "rain"]
	for i in _puffs.size():
		var puff: = _puffs[i]
		var want: bool = fog or clouds
		if not want:
			puff.visible = false
			puff.remove_meta("v")
			continue
		if not puff.has_meta("v") or puff.get_meta("fog", false) != fog:
			_new_puff(puff, view, fog, true)
		var v: Vector2 = puff.get_meta("v")
		puff.position += v * delta
		if puff.position.x > view.x + 40.0 or puff.position.y > view.y + 40.0:
			_new_puff(puff, view, fog, false)
		var a: float = puff.get_meta("a")
		puff.modulate.a = a * _amount
		puff.visible = true
	_storm(delta)
	_night_bats(delta, view)




func _new_puff(puff: TextureRect, view: Vector2, fog: bool, anywhere: bool) -> void :
	puff.texture = load("res://assets/ro/effects/tex/wx_fog.png") if fog else load("res://assets/ro/ui/sky/cloud%d.png" % [1, 2, 3, 4].pick_random())
	var s: = randf_range(0.55, 0.9) * view.y * (1.0 if fog else 1.5)
	puff.size = Vector2(s * 1.4, s)
	puff.pivot_offset = puff.size * 0.5
	if anywhere:
		puff.position = Vector2(randf_range( - s, view.x), randf_range( - s * 0.5, view.y - s * 0.5))
	elif randf() < 0.7:
		puff.position = Vector2( - s * 1.5, randf_range( - s * 0.5, view.y - s * 0.5))
	else:
		puff.position = Vector2(randf_range( - s, view.x - s), - s * 1.1)
	var wind: = Vector2(randf_range(10.0, 22.0), randf_range(2.0, 7.0)) * (0.6 if fog else 1.0)
	puff.set_meta("v", wind)
	puff.set_meta("fog", fog)
	if fog:
		puff.modulate = Color(0.92, 0.93, 1.0)
		puff.set_meta("a", randf_range(0.22, 0.38))
	else:

		puff.modulate = Color(0.02, 0.03, 0.06)
		puff.set_meta("a", randf_range(0.2, 0.28))


func _storm(delta: float) -> void :
	if kind != "storm" or _amount < 1.0:
		_flash.visible = false
		return
	_flash_t -= delta
	if _flash_t <= 0.0:
		_flash_t = randf_range(GameData.WEATHER_FLASH[0], GameData.WEATHER_FLASH[1])
		_flash.visible = true
		var tw: = _flash.create_tween()

		tw.tween_property(_flash, "color:a", 0.45, 0.05)
		tw.tween_property(_flash, "color:a", 0.05, 0.08)
		tw.tween_property(_flash, "color:a", 0.3, 0.05)
		tw.tween_property(_flash, "color:a", 0.0, 0.45)
		get_tree().create_timer(randf_range(0.4, 1.2)).timeout.connect( func():
			if _on:
				world.play_sound("thunder", 0.5, -16.0, randf_range(0.7, 0.85), false))



func _night_bats(delta: float, view: Vector2) -> void :
	for b in _bats.duplicate():
		var node: TextureRect = b.node
		if not is_instance_valid(node):
			_bats.erase(b)
			continue
		b.t += delta
		node.position += b.v * delta + Vector2(0, sin(b.t * 5.0) * 0.6)
		node.texture = load("res://assets/ro/effects/tex/wx_bat_%d.png" % (1 + int(b.t * 10.0) % 4))
		if node.position.x > view.x + 80.0 or node.position.x < -120.0:
			node.queue_free()
			_bats.erase(b)
	if not _defs().get("bats", false) or night() < 0.9:
		return
	_bat_t -= delta
	if _bat_t > 0.0:
		return
	_bat_t = randf_range(GameData.WEATHER_BATS[0], GameData.WEATHER_BATS[1])

	var left: = randf() < 0.5
	var y: = randf_range(view.y * 0.1, view.y * 0.6)
	for i in randi_range(2, 5):
		var node: = TextureRect.new()
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.texture = load("res://assets/ro/effects/tex/wx_bat_1.png")
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var s: = randf_range(26.0, 42.0)
		node.size = Vector2(s, s)
		node.flip_h = not left
		node.modulate = Color(0.1, 0.08, 0.14, 0.85)
		node.position = Vector2(-60.0 - i * randf_range(20.0, 50.0) if left else view.x + 20.0 + i * randf_range(20.0, 50.0), y + randf_range(-40.0, 40.0))
		_fx_layer.add_child(node)
		_fx_layer.move_child(node, 0)
		var speed: = randf_range(140.0, 200.0)
		_bats.append({"node": node, "v": Vector2(speed if left else - speed, randf_range(-12.0, 12.0)), "t": randf() * 3.0})



func _build_fall() -> void :
	_fall = Node3D.new()
	_fall.name = "WeatherFall"
	world.add_child(_fall)
	var box: = Vector3(GameData.WEATHER_AREA.x, 1.0, GameData.WEATHER_AREA.y)

	_rain = _particles(1500, 0.9, box, Vector3(0, 14, 0), _streak_tex(), Vector2(0.09, 1.7), Color(0.85, 0.9, 1.0, 0.75), true)
	var pm: = _rain.process_material as ParticleProcessMaterial
	pm.direction = Vector3(0.18, -1, 0.05)
	pm.spread = 2.0
	pm.initial_velocity_min = 26.0
	pm.initial_velocity_max = 32.0
	pm.gravity = Vector3.ZERO

	_splash = _particles(260, 0.35, box, Vector3(0, 0.08, 0), _ring_tex(), Vector2(0.6, 0.6), Color(0.85, 0.9, 1.0, 0.7), false)
	pm = _splash.process_material as ParticleProcessMaterial
	pm.initial_velocity_min = 0.0
	pm.initial_velocity_max = 0.0
	pm.gravity = Vector3.ZERO
	var grow: = Curve.new()
	grow.add_point(Vector2(0, 0.2))
	grow.add_point(Vector2(1, 1.0))
	var gt: = CurveTexture.new()
	gt.curve = grow
	pm.scale_curve = gt
	_fade(pm)

	_snow = _particles(380, 6.0, box, Vector3(0, 12, 0), load("res://assets/ro/effects/tex/wx_snow.png"), Vector2(0.32, 0.36), Color(1, 1, 1, 0.95), false, true)
	pm = _snow.process_material as ParticleProcessMaterial
	pm.direction = Vector3(0.3, -1, 0.1)
	pm.spread = 25.0
	pm.initial_velocity_min = 1.6
	pm.initial_velocity_max = 2.6
	pm.gravity = Vector3(0.3, -0.2, 0)
	pm.scale_min = 0.5
	pm.scale_max = 1.2
	_spin(pm, 60.0)

	_leaves = _leafy("res://assets/ro/effects/tex/wx_leaf.png", 100, box, 0.42)
	for p: GPUParticles3D in [_rain, _splash, _snow, _leaves]:
		p.emitting = false
		p.visible = false


func _leafy(tex: String, n: int, box: Vector3, size: float) -> GPUParticles3D:
	var p: = _particles(n, 7.0, box, Vector3(-6, 11, 0), load(tex), Vector2(size, size * 1.05), Color.WHITE, false, true)
	var pm: = p.process_material as ParticleProcessMaterial
	pm.direction = Vector3(1, -0.55, 0.2)
	pm.spread = 20.0
	pm.initial_velocity_min = 2.2
	pm.initial_velocity_max = 3.4
	pm.gravity = Vector3(0.4, -0.3, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.1
	_spin(pm, 180.0)
	return p


func _particles(n: int, life: float, box: Vector3, at: Vector3, tex: Texture2D, quad: Vector2, col: Color, streak: bool, sway: = false) -> GPUParticles3D:
	var p: = GPUParticles3D.new()
	p.amount = n
	p.lifetime = life
	p.preprocess = life
	p.local_coords = false
	p.visibility_aabb = AABB(Vector3( - box.x, -20, - box.z), Vector3(box.x * 2.0, 40, box.z * 2.0))
	p.position = at
	var pm: = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = box
	if sway:
		pm.turbulence_enabled = true
		pm.turbulence_noise_strength = 0.6
		pm.turbulence_noise_scale = 4.0
		pm.turbulence_influence_min = 0.05
		pm.turbulence_influence_max = 0.15
	_fade(pm)
	p.process_material = pm
	var mesh: = QuadMesh.new()
	mesh.size = quad
	if not streak and quad.x == quad.y and at.y < 1.0:

		mesh.orientation = PlaneMesh.FACE_Y
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_texture = tex
	mat.albedo_color = col
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = false
	mat.render_priority = 5
	if streak:
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	elif mesh.orientation != PlaneMesh.FACE_Y:
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mesh.material = mat
	p.draw_pass_1 = mesh
	_fall.add_child(p)
	return p



func _fade(pm: ParticleProcessMaterial) -> void :
	var g: = Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.12, 0.8, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0), Color.WHITE, Color.WHITE, Color(1, 1, 1, 0)])
	var gt: = GradientTexture1D.new()
	gt.gradient = g
	pm.color_ramp = gt


func _spin(pm: ParticleProcessMaterial, deg: float) -> void :
	pm.angle_min = -180.0
	pm.angle_max = 180.0
	pm.angular_velocity_min = - deg
	pm.angular_velocity_max = deg



static func _streak_tex() -> Texture2D:
	var g: = Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.2)])
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0.5, 0)
	t.fill_to = Vector2(0.5, 1)
	t.width = 4
	t.height = 64
	return t



static func _ring_tex() -> Texture2D:
	var g: = Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.62, 0.8, 0.95, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0), Color(1, 1, 1, 0)])
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t



func badge() -> String:
	if not _on:
		return ""
	var ph: = {"day": tr("Día"), "dusk": tr("Atardecer"), "night": tr("Noche"), "dawn": tr("Amanecer")}
	var wx: = {"clear": tr("Despejado"), "rain": tr("Lluvia"), "storm": tr("Tormenta"), "snow": tr("Nieve"), "fog": tr("Niebla"), 
		"leaves": tr("Hojas al viento"), "clouds": tr("Nublado")}
	var k: = _want if _want != "" and _amount < 0.5 else kind
	return "%s · %s" % [ph[phase()], wx.get(k, "")]
