class_name RebirthAura
extends Node3D
















const TICK: = 0.025

const K: = GameData.PIXEL_SIZE * 35.0

const GA_SIZE: = 100.0
const GA_DISTANCE: = 15.0


const B_G2W: = 0.22
const B_RADIUS: = 2.4 * 0.22 * 0.6
const B_SPEED: = 0.15
const B_DRIFT: = 0.15
const B_SEED_MAX: = 99.0
const B_RESET_Y: = -30.0
const B_ALPHA_OFFSET: = 20.0
const B_ALPHA_GAIN: = 30.0
const B_COLOR: = Color(80.0 / 255.0, 80.0 / 255.0, 1.0)
const B_GOLD: = Color(1.0, 0.7, 0.18)


const GA_VIEW: = 1.0
const B_RISE_VIEW: = 0.5
const ANCHOR_SIGNS: = [Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]
const ANCHOR_PHASES: = [Vector2i(0, 2), Vector2i(4, 6), Vector2i(8, 10), Vector2i(12, 14)]




static func earned(class_id: String) -> bool:
	return unlocked(class_id) and not (Save.class_progress(class_id).get("looks_off", []) as Array).has("aura")




static func unlocked(class_id: String) -> bool:
	var top: bool = Save.is_reborn(class_id) or GameData.CLASSES[class_id].get("no_rebirth", false)

	return top and (int(Save.class_progress(class_id).level) >= Save.class_max_level(class_id) or Save.rebirth_lv(class_id) > 0)



var additive: = true

var soft: = false

var gold: = false


var corrupt: = false


var rainbow: = false
var _hue: = 0.0
const C_RED: = Color(1.0, 0.12, 0.08)
const C_BLACK: = Color(0.08, 0.0, 0.02)

var _flares: Array[Dictionary] = []
var _columns: Array[Dictionary] = []
var _acc: = 0.0


func _blend() -> BaseMaterial3D.BlendMode:
	return BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX




var bubbles: = true


func _ready() -> void :
	_build_ground()
	if bubbles:
		_build_bubbles()


func _process(delta: float) -> void :
	var dt: = minf(delta, 0.25)
	if rainbow:
		_hue = fposmod(_hue + dt * 0.12, 1.0)
		for i in _flares.size():
			var fm: StandardMaterial3D = (_flares[i].node as MeshInstance3D).material_override
			fm.albedo_color = Color.from_hsv(fposmod(_hue + i * 0.5, 1.0), 0.9, 1.0, 0.9)
	_acc += dt
	while _acc >= TICK:
		_acc -= TICK
		_tick_ground()
	_tick_bubbles(dt / TICK)




func _build_ground() -> void :
	var tex: = RoAssets.effect_tex("lv99_star")
	if tex == null:
		return
	var min_size: = GA_SIZE + GA_DISTANCE
	var max_size: = GA_SIZE + GA_DISTANCE * 2.0
	for i in 2:



		var mi: = MeshInstance3D.new()
		var plane: = PlaneMesh.new()
		plane.size = Vector2.ONE
		mi.mesh = plane
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = _blend()
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.albedo_texture = RebirthFlair.gray(tex) if gold or corrupt or rainbow else tex
		m.albedo_color = Color(1.0, 0.8, 0.4, 0.8) if gold else (Color(1.0, 0.1, 0.06, 0.9) if corrupt else Color(1, 1, 1, 0.8))
		m.render_priority = -8 + i


		m.no_depth_test = true
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		mi.position = Vector3(0, 0.08, 0)
		mi.rotation.y = deg_to_rad(23.0 * i)
		add_child(mi)
		var s: = min_size if i == 0 else max_size
		_flares.append({"node": mi, "size": Vector2(s, s), "initial": Vector2(s, s), 
			"rise": 0, "dir": 1 if i == 0 else -1, "angle": i * 23})
	_apply_ground()




func _size_step(f: Dictionary) -> Vector2:
	var rise_factor: = GA_DISTANCE * 0.1 * (sin(float(f.rise)) + 1.0)
	var r: = GA_DISTANCE * 0.8 + rise_factor
	var ang: int = f.angle
	var start_x: = cos(float(ang)) * r
	ang = (ang + 90) % 360
	var end_x: = cos(float(ang)) * r
	ang = (ang + 90) % 360
	var start_y: = sin(float(ang)) * r
	ang = (ang + 90) % 360
	var end_y: = sin(float(ang)) * r
	return Vector2(absf(end_x - start_x), absf(end_y - start_y))


func _tick_ground() -> void :
	for f in _flares:
		f.rise = int(f.rise) + 3
		if int(f.rise) % 180 == 0:
			f.dir = - int(f.dir)

			if (f.dir < 0 and f.size.x < f.initial.x) or (f.dir > 0 and f.size.x > f.initial.x):
				f.size = f.initial
		if int(f.rise) >= 360:
			f.rise = int(f.rise) - 360
		var step: = _size_step(f)
		f.size += step * float(f.dir) / (GA_SIZE / 2.0)
	_apply_ground()


func _apply_ground() -> void :
	for f in _flares:
		var size: Vector2 = f.size / 35.0 * K * GA_VIEW
		(f.node as Node3D).scale = Vector3(size.x, 1.0, size.y)




func _build_bubbles() -> void :
	var tex: = RoAssets.effect_tex("lv99_bubble")
	if tex == null:
		return
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE * B_RADIUS * 2.0 * K
	for c in 4:
		var col: = {"phases": PackedFloat32Array(), "targets": PackedFloat32Array(), "anchors": []}
		for p in 16:
			col.phases.append(randf() * 360.0)
			col.targets.append(randf() * 360.0)
		for a in 4:
			var mi: = MeshInstance3D.new()
			mi.mesh = quad
			var m: = StandardMaterial3D.new()
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

			var dark: = corrupt and c % 2 == 1
			m.blend_mode = BaseMaterial3D.BLEND_MODE_MIX if dark else _blend()
			m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			m.albedo_texture = tex


			m.render_priority = GameData.HERO_FX_PRIORITY
			mi.material_override = m
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mi.visible = false
			add_child(mi)
			col.anchors.append({"node": mi, "mat": m, "pos": Vector3(0, randf() * B_SEED_MAX, 0), "dark": dark})
		_columns.append(col)


func _tick_bubbles(step: float) -> void :
	for ci in _columns.size():
		var col: Dictionary = _columns[ci]
		var phases: PackedFloat32Array = col.phases
		var targets: PackedFloat32Array = col.targets

		for i in 16:
			var diff: = fposmod(targets[i] - phases[i] + 540.0, 360.0) - 180.0
			var d: = (2.0 + randf()) * step
			if absf(diff) <= d:
				phases[i] = targets[i]
				targets[i] = randf() * 360.0
			else:
				phases[i] = fposmod(phases[i] + signf(diff) * d, 360.0)
		for ai in 4:
			var a: Dictionary = col.anchors[ai]
			var sg: Vector2i = ANCHOR_SIGNS[ai]
			var ph: Vector2i = ANCHOR_PHASES[ai]
			var pos: Vector3 = a.pos
			if pos.y < 0.0:
				pos.x += sg.x * B_DRIFT * sin(deg_to_rad(phases[ph.x])) * step
				pos.z += sg.y * B_DRIFT * sin(deg_to_rad(phases[ph.y])) * step
			pos.y -= B_SPEED * step
			if pos.y < B_RESET_Y:
				pos = Vector3(0, randf() * B_SEED_MAX, 0)
				phases[ph.x] = randf() * 360.0
				targets[ph.x] = randf() * 360.0
				phases[ph.y] = randf() * 360.0
				targets[ph.y] = randf() * 360.0
			a.pos = pos
			var node: MeshInstance3D = a.node

			var alpha: = clampf(250.0 + B_ALPHA_GAIN * (pos.y + B_ALPHA_OFFSET), 0.0, 250.0) / 255.0
			node.visible = pos.y <= 0.0 and alpha > 0.0
			if node.visible:
				node.position = Vector3(pos.x, - pos.y * B_RISE_VIEW, pos.z) * B_G2W * K + Vector3(0, 0.05, 0)


				var tone: = B_GOLD if gold else B_COLOR
				if corrupt:
					tone = C_BLACK if a.dark else C_RED
				elif rainbow:
					tone = Color.from_hsv(fposmod(_hue + ci * 0.25 + ai * 0.06, 1.0), 0.85, 1.0)
				(a.mat as StandardMaterial3D).albedo_color = Color(tone, alpha)
		col.phases = phases
		col.targets = targets




static func attach(holder: Node3D, looks: Array, earned_aura: bool) -> void :
	if earned_aura:
		var aura: = RebirthAura.new()
		aura.gold = looks.has("gold")
		holder.add_child(aura)

		var v = holder if holder is RoVisual else holder.get("visual")
		if v is RoVisual:
			(v as RoVisual).cover_aura(GameData.HERO_FX_PRIORITY + 1)
	if not looks.is_empty():
		var flair: = RebirthFlair.new()
		flair.looks = looks
		holder.add_child(flair)







class Preview extends SubViewport:
	const FEET: = Vector2(100, 112)

	const SIZE: = Vector2i(200, 150)

	const PREVIEW_SCALE: = 0.8
	static var _stone: Texture2D


	static func stone_tex() -> Texture2D:
		if _stone == null:
			var g: = Gradient.new()
			g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
			g.colors = PackedColorArray([Color(0.74, 0.73, 0.72, 1.0), Color(0.78, 0.77, 0.76, 0.8), Color(0.82, 0.81, 0.8, 0.0)])
			var t: = GradientTexture2D.new()
			t.gradient = g
			t.fill = GradientTexture2D.FILL_RADIAL
			t.fill_from = Vector2(0.5, 0.5)
			t.fill_to = Vector2(1.0, 0.5)
			t.width = 128
			t.height = 128
			_stone = t
		return _stone








	var _white: SubViewport
	var _cam: Camera3D
	var _ui_mat: Material

	var _skip: = false

	func _process(_delta: float) -> void :
		if _white == null:
			return
		_skip = not _skip
		if _skip:
			return
		render_target_update_mode = SubViewport.UPDATE_ONCE
		_white.render_target_update_mode = SubViewport.UPDATE_ONCE

	static func dual() -> bool:
		return RenderingServer.get_current_rendering_method() != "gl_compatibility"

	static func _bg_env(c: Color) -> Environment:
		var env: = Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = c
		env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
		return env


	func ui_material() -> Material:
		if _ui_mat != null:
			return _ui_mat
		if not dual():
			var m: = CanvasItemMaterial.new()
			m.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
			_ui_mat = m
			return m
		var sh: = Shader.new()



		sh.code = "shader_type canvas_item;\r\nrender_mode blend_premul_alpha;\r\nuniform sampler2D white_tex : filter_nearest;\r\nvoid fragment() {\r\n\tvec3 b = texture(TEXTURE, UV).rgb;\r\n\tvec3 w = texture(white_tex, UV).rgb;\r\n\tfloat through = clamp(dot(w - b, vec3(0.3333)) * 2.0, 0.0, 1.0);\r\n\tCOLOR = vec4(b, 1.0 - through) * COLOR.a;\r\n}"








		var sm: = ShaderMaterial.new()
		sm.shader = sh
		sm.set_shader_parameter("white_tex", _white.get_texture())
		_ui_mat = sm
		return sm



	func _make_white() -> void :
		_white = SubViewport.new()
		_white.size = size
		_white.transparent_bg = false

		_white.render_target_update_mode = SubViewport.UPDATE_ONCE
		_white.world_3d = world_3d
		var cam2: = Camera3D.new()
		cam2.projection = _cam.projection
		cam2.size = _cam.size
		cam2.transform = _cam.transform
		cam2.environment = _bg_env(Color(0.5, 0.5, 0.5))
		_white.add_child(cam2)
		add_child(_white)


	func _init(looks: Array = [], part: = "back", hero_height: = 2.4, with_aura: = true) -> void :
		size = SIZE
		transparent_bg = not dual()
		if dual():

			world_3d = World3D.new()
		else:
			own_world_3d = true



		render_target_update_mode = SubViewport.UPDATE_ONCE if dual() else SubViewport.UPDATE_ALWAYS
		var cam: = Camera3D.new()
		_cam = cam
		if dual():
			cam.environment = _bg_env(Color.BLACK)
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = size.y * GameData.PIXEL_SIZE

		var up: = Vector3(0, cos(World.CAMERA_PITCH), - sin(World.CAMERA_PITCH))
		var target: = up * (FEET.y - size.y * 0.5) * GameData.PIXEL_SIZE
		var eye: = target + Vector3(0, sin(World.CAMERA_PITCH), cos(World.CAMERA_PITCH)) * 20.0
		cam.transform = Transform3D(Basis(), eye).looking_at(target, Vector3.UP)
		add_child(cam)
		if dual():
			_make_white()



		if not looks.is_empty():
			var flair: = RebirthFlair.new()
			flair.looks = looks
			flair.part = part
			flair.height = hero_height
			add_child(flair)
		if part == "front" or not with_aura:
			return


		var ground: = Sprite3D.new()
		ground.visible = not dual()
		ground.texture = Preview.stone_tex()
		ground.axis = Vector3.AXIS_Y
		ground.shaded = false
		ground.pixel_size = 3.0 / float(ground.texture.get_width())
		ground.position = Vector3(0, 0.4, 0)
		ground.render_priority = -10
		add_child(ground)
		var aura: = RebirthAura.new()
		aura.gold = looks.has("gold")
		aura.bubbles = not dual()

		aura.scale = Vector3.ONE * PREVIEW_SCALE
		add_child(aura)
