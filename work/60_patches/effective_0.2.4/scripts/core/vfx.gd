class_name Vfx
extends RefCounted



static var _ring_tex: Texture2D


static var dim: = 1.0


static var hero: = false



static var foreign: = false


const DANGER_PRIORITY: = 14


static var layer: = 0



static var quality: = 0




static var fast_trim: = 0
static func _skip(level: int) -> bool:
	return layer == 0 and (quality + fast_trim >= level or hidden())




static func hidden() -> bool:
	return dim <= 0.01 and layer == 0





const TRAIL_PER_FRAME: = 16
static var _trail_frame: = -1
static var _trail_left: = 0
static func trail_ok() -> bool:
	var f: = Engine.get_process_frames()
	if f != _trail_frame:
		_trail_frame = f
		_trail_left = TRAIL_PER_FRAME
	if _trail_left <= 0:
		return false
	_trail_left -= 1
	return true
static var _disc_tex: Texture2D




const ADD_BOOST: = 1.5


static func add_k() -> float:
	return 1.0 if RenderingServer.get_current_rendering_method() == "gl_compatibility" else ADD_BOOST





const AMBIENT_BOOST: = 1.0
const SUN_BOOST: = 1.0


static func light_k() -> float:
	return 1.0 if RenderingServer.get_current_rendering_method() == "gl_compatibility" else AMBIENT_BOOST


static func sun_k() -> float:
	return 1.0 if RenderingServer.get_current_rendering_method() == "gl_compatibility" else SUN_BOOST


static func _material(color: Color, additive: = true) -> StandardMaterial3D:
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	var k: = add_k() if additive else 1.0
	m.albedo_color = Color(color.r * k, color.g * k, color.b * k, color.a * dim)
	m.vertex_color_use_as_albedo = true
	m.render_priority = layer
	return m




static var net_root: Node3D
static var net_record: Callable




static var _quiet: = false


static func _rec(parent: Node3D, ev: Array) -> void :
	if not _quiet and net_record.is_valid() and parent == net_root:
		net_record.call(["v"] + ev)


static func ring_texture() -> Texture2D:
	if _ring_tex == null:
		var g: = Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.62, 0.86, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.15), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		_ring_tex = _radial(g)
	return _ring_tex


static var _square_tex: Texture2D



static func square_texture() -> Texture2D:
	if _square_tex == null:
		var img: = Image.create(128, 128, false, Image.FORMAT_RGBA8)
		for y in 128:
			for x in 128:
				var e: = mini(mini(x, 127 - x), mini(y, 127 - y))
				var a: = 0.0
				if e < 4:
					a = 0.25 + e * 0.18
				elif e < 12:
					a = lerpf(0.95, 0.4, (e - 4) / 8.0)
				else:
					a = 0.32
				img.set_pixel(x, y, Color(1, 1, 1, a))
		_square_tex = ImageTexture.create_from_image(img)
	return _square_tex


static var _soft_cell_tex: Texture2D




static func soft_cell_texture() -> Texture2D:
	if _soft_cell_tex == null:
		var img: = Image.create(128, 128, false, Image.FORMAT_RGBA8)
		for y in 128:
			for x in 128:
				var e: = mini(mini(x, 127 - x), mini(y, 127 - y)) / 52.0
				var a: = smoothstep(0.0, 1.0, clampf(e, 0.0, 1.0))
				img.set_pixel(x, y, Color(1, 1, 1, a * 0.5))
		_soft_cell_tex = ImageTexture.create_from_image(img)
	return _soft_cell_tex


static func disc_texture() -> Texture2D:
	if _disc_tex == null:
		var g: = Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.85, 0.93, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.5), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		_disc_tex = _radial(g)
	return _disc_tex


static var _blast_tex: Texture2D
static var _column_tex: Texture2D





static func beam_texture() -> Texture2D:
	if _column_tex == null:
		var w: = 64
		var h: = 128
		var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in h:
			var v: = float(y) / float(h - 1)

			var along: = smoothstep(0.0, 0.06, v) * pow(1.0 - v, 1.4)
			for x in w:
				var u: = (float(x) + 0.5) / float(w)
				var across: = pow(sin(PI * u), 1.8)
				var core: = pow(sin(PI * u), 10.0) * 0.6
				img.set_pixel(x, y, Color(1, 1, 1, clampf(along * (across + core), 0.0, 1.0)))
		_column_tex = ImageTexture.create_from_image(img)
	return _column_tex
static var _energy_shader: Shader






static func energy_material(color: Color, curtain: = true, flow: = 1.0, polar: = false, size: = Vector2(4.0, 4.0), 
		wave: = false) -> ShaderMaterial:
	if _energy_shader == null:
		_energy_shader = Shader.new()
		_energy_shader.code = "\nshader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled;\nuniform vec4 tint : source_color = vec4(1.0);\nuniform float flow = 1.0;\nuniform float curtain = 1.0;\nuniform float alpha = 1.0;\nuniform float polar = 0.0;\n// The quad's size in metres: the noise keeps the same grain however long it\n// is (a 30 m wall stretched it into blocks).\nuniform vec2 size = vec2(4.0, 4.0);\n// A wave rolling over the ground (flat, towards UV.y 0): a foaming front\n// that bulges and breaks along its length, the water churning behind it.\nuniform float wave = 0.0;\nfloat hash(vec2 p) {\n\tvec3 p3 = fract(vec3(p.xyx) * 0.1031);\n\tp3 += dot(p3, p3.yzx + 33.33);\n\treturn fract((p3.x + p3.y) * p3.z);\n}\nfloat noise(vec2 p) {\n\tvec2 i = floor(p);\n\tvec2 f = fract(p);\n\tf = f * f * (3.0 - 2.0 * f);\n\treturn mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);\n}\nfloat fbm(vec2 p) {\n\tfloat s = 0.0;\n\tfloat a = 0.5;\n\tfor (int k = 0; k < 3; k++) {\n\t\ts += a * noise(p);\n\t\tp = p * 2.03 + vec2(1.7, 9.2);\n\t\ta *= 0.5;\n\t}\n\treturn s / 0.875;\n}\nvoid fragment() {\n\tfloat t = TIME * flow;\n\tvec2 uv = UV;\n\tvec2 m = uv * size;\n\tfloat edge = smoothstep(0.0, 0.9, m.x) * smoothstep(0.0, 0.9, size.x - m.x);\n\t// Polar (a vortex): around and inwards, twisting as it nears the middle.\n\tif (polar > 0.5) {\n\t\tvec2 c = UV - 0.5;\n\t\tfloat r = length(c) * 2.0;\n\t\tuv = vec2(atan(c.y, c.x) / 6.2832 + 0.5 + r * 0.45, r);\n\t\tm = vec2(uv.x * 9.0, uv.y * 3.5);\n\t\tedge = smoothstep(1.0, 0.9, r) * smoothstep(0.0, 0.2, r);\n\t}\n\tfloat n = fbm(vec2(m.x * 0.8 + t * 0.4, m.y * 0.8 + t * 1.5)) * 0.6\n\t\t+ fbm(vec2(m.x * 1.9 - t * 0.9, m.y * 1.5 + t * 2.6)) * 0.4;\n\tfloat body;\n\tfloat foam = 0.0;\n\tif (curtain > 0.5) {\n\t\t// Standing: a rolling crest, higher and lower along the wall, with\n\t\t// foam on it; brightest at the foot.\n\t\tfloat hgt = 1.0 - uv.y;\n\t\tfloat crest = 0.6 + 0.16 * sin(m.x * 1.2 + t * 1.6) + 0.1 * sin(m.x * 2.9 - t * 2.4) + 0.2 * (n - 0.5);\n\t\tbody = smoothstep(crest, crest - 0.3, hgt) * (0.35 + 0.65 * (1.0 - hgt));\n\t\tfoam = smoothstep(0.1, 0.0, abs(hgt - crest + 0.07)) * 0.85 + smoothstep(0.12, 0.0, hgt) * 0.5;\n\t} else if (polar > 0.5) {\n\t\tbody = 1.0;\n\t} else if (wave > 0.5) {\n\t\tfloat d = uv.y * size.y;\n\t\tfloat front = 0.7 + 0.45 * sin(m.x * 0.7 + t * 1.3) + 0.3 * sin(m.x * 1.9 - t * 1.9) + 0.6 * (n - 0.5);\n\t\tfloat behind = smoothstep(front - 0.2, front + 0.35, d) * (1.0 - smoothstep(size.y * 0.35, size.y, d));\n\t\tfoam = smoothstep(0.65, 0.0, abs(d - front - 0.15)) * (0.6 + 0.6 * n);\n\t\t// Streaks of foam left behind as it rolls.\n\t\tfoam += smoothstep(0.62, 0.8, n) * behind * 0.5;\n\t\tbody = behind;\n\t} else {\n\t\t// Flat: soft on both sides, its front and back rippling.\n\t\tfloat f = 0.2 + 0.09 * sin(m.x * 1.1 + t * 1.3) + 0.1 * (n - 0.5);\n\t\tbody = smoothstep(f - 0.15, f + 0.15, uv.y) * smoothstep(f - 0.15, f + 0.15, 1.0 - uv.y);\n\t}\n\tfloat glint = pow(n, 4.0) * 1.2;\n\tALBEDO = tint.rgb * (0.6 + 0.8 * n) + vec3(glint + foam);\n\tALPHA = clamp((body * (0.35 + 0.85 * n) + foam * body * 0.0 + foam * 0.6) * edge * tint.a * alpha, 0.0, 1.0);\n}\n"














































































	var m: = ShaderMaterial.new()
	m.shader = _energy_shader
	m.set_shader_parameter("tint", Color(color, color.a * dim))
	m.set_shader_parameter("flow", flow)
	m.set_shader_parameter("curtain", 1.0 if curtain and not polar else 0.0)
	m.set_shader_parameter("polar", 1.0 if polar else 0.0)
	m.set_shader_parameter("size", size)
	m.set_shader_parameter("wave", 1.0 if wave else 0.0)
	m.render_priority = DANGER_PRIORITY
	return m



static func blast_texture() -> Texture2D:
	if _blast_tex == null:
		var g: = Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.7, 0.9, 0.96, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 0.75), Color(1, 1, 1, 0.8), Color(1, 1, 1, 1), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0)])
		_blast_tex = _radial(g)
	return _blast_tex


static func _radial(g: Gradient) -> Texture2D:
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	t.width = 128
	t.height = 128
	return t


static func _flat(parent: Node3D, tex: Texture2D, pos: Vector3, radius: float, color: Color) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = tex
	s.axis = Vector3.AXIS_Y
	s.shaded = false
	s.modulate = Color(color, color.a * dim)
	s.pixel_size = radius * 2.0 / 128.0
	s.position = pos + Vector3(0, 0.06, 0)
	s.render_priority = layer
	parent.add_child(s)
	return s






static var batch_root: Node3D

static var _flats: Array = []
static var _flat_mmi: = {}
static var _flat_buf: = {}
const FLAT_MAX: = 512
const FLAT_START: = 32


static func _flat_add(kind: int, pos: Vector3, radius: float, color: Color, duration: float) -> void :
	if _flats.size() >= FLAT_MAX:
		_flats.pop_front()
	_flats.append([kind, pos + Vector3(0, 0.06, 0), radius, Color(color, color.a * dim), 0.0, duration, layer])


static func clear_flats() -> void :
	_flats.clear()




static func update_flat(delta: float) -> void :
	if batch_root == null or not is_instance_valid(batch_root):
		return
	var groups: = {}
	var keep: = 0
	for f in _flats:
		f[4] = float(f[4]) + delta
		if float(f[4]) >= float(f[5]):
			continue
		_flats[keep] = f
		keep += 1
		var key: int = int(f[0]) * 1000 + int(f[6])
		if not groups.has(key):
			groups[key] = []
		groups[key].append(f)
	_flats.resize(keep)
	for key in _flat_mmi.keys():
		if not groups.has(key):
			var m = _flat_mmi[key]
			if is_instance_valid(m) and (m as MultiMeshInstance3D).multimesh.visible_instance_count != 0:
				(m as MultiMeshInstance3D).multimesh.visible_instance_count = 0
	for key in groups:
		var list: Array = groups[key]
		var held = _flat_mmi.get(key)
		var mmi: MultiMeshInstance3D = held if held != null and is_instance_valid(held) else null
		if mmi == null:
			mmi = _flat_node(int(key) / 1000, int(key) % 1000)
			_flat_mmi[key] = mmi
		var mm: = mmi.multimesh


		var n: = mini(list.size(), FLAT_MAX)
		if n > mm.instance_count:
			mm.visible_instance_count = 0
			mm.instance_count = mini(FLAT_MAX, maxi(n * 2, FLAT_START))
		var buf: PackedFloat32Array = _flat_buf.get(key, PackedFloat32Array())
		if buf.size() != mm.instance_count * 16:
			buf.resize(mm.instance_count * 16)
		for i in n:
			var f: Array = list[i]
			var u: = float(f[4]) / float(f[5])
			var sc: = 1.0
			if int(f[0]) == 0:
				sc = 0.3 + 0.7 * (1.0 - pow(1.0 - u, 3.0))
			var side: = float(f[2]) * 2.0 * sc
			var p: Vector3 = f[1]
			var c: Color = f[3]
			var o: = i * 16
			buf[o] = side
			buf[o + 1] = 0.0
			buf[o + 2] = 0.0
			buf[o + 3] = p.x
			buf[o + 4] = 0.0
			buf[o + 5] = 1.0
			buf[o + 6] = 0.0
			buf[o + 7] = p.y
			buf[o + 8] = 0.0
			buf[o + 9] = 0.0
			buf[o + 10] = side
			buf[o + 11] = p.z
			buf[o + 12] = c.r
			buf[o + 13] = c.g
			buf[o + 14] = c.b
			buf[o + 15] = c.a * (1.0 - u)
		_flat_buf[key] = buf
		mm.buffer = buf
		mm.visible_instance_count = n


static func _flat_node(kind: int, priority: int) -> MultiMeshInstance3D:
	var quad: = PlaneMesh.new()
	quad.size = Vector2.ONE
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.albedo_texture = ring_texture() if kind == 0 else RoAssets.radial(Color.WHITE, 128)
	mat.render_priority = priority
	quad.material = mat
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = quad
	mm.instance_count = FLAT_START
	mm.visible_instance_count = 0
	var mmi: = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	mmi.custom_aabb = AABB(Vector3(-400, -50, -400), Vector3(800, 100, 800))
	batch_root.add_child(mmi)
	return mmi



static func ring(parent: Node3D, pos: Vector3, radius: float, color: Color, duration: = 0.4) -> void :
	_rec(parent, ["ring", pos, radius, color, duration])
	if parent == batch_root and batch_root != null:
		_flat_add(0, pos, radius, color, duration)
		return
	var s: = _flat(parent, ring_texture(), pos, radius, color)
	s.scale = Vector3.ONE * 0.3
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "scale", Vector3.ONE, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(s, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(s.queue_free)



static func safe_circle(parent: Node3D, pos: Vector3, radius: float, color: Color, duration: float) -> void :
	_rec(parent, ["safe", pos, radius, color, duration])
	var fill: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, radius, Color(color, 0.5))
	var edge: = _flat(parent, ring_texture(), pos, radius * 1.1, color)
	edge.reparent(fill)

	fill.no_depth_test = true
	edge.no_depth_test = true
	var tw: = fill.create_tween().set_loops(ceili(duration / 0.3))
	tw.tween_property(edge, "modulate:a", 0.5, 0.15)
	tw.tween_property(edge, "modulate:a", 1.0, 0.15)
	var end: = fill.create_tween()
	end.tween_interval(duration)
	end.tween_callback(fill.queue_free)



static func converge(parent: Node3D, pos: Vector3, radius: float, color: Color, duration: = 0.3) -> void :
	if _skip(1) or hidden():
		return
	var s: = _flat(parent, ring_texture(), pos, radius, Color(color, 0.0))
	s.scale = Vector3.ONE * 2.0
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "scale", Vector3.ONE, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	tw.tween_property(s, "modulate:a", color.a * dim, duration)
	tw.chain().tween_callback(s.queue_free)



static func burst(parent: Node3D, pos: Vector3, radius: float, color: Color) -> void :
	_rec(parent, ["burst", pos, radius, color])
	if _skip(1):
		return
	if parent == batch_root and batch_root != null:
		_flat_add(1, pos, radius, Color(color, 0.9), 0.35)
		ring(parent, pos, radius, color, 0.45)
		return
	var s: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, radius, Color(color, 0.9))
	var tw: = s.create_tween()
	tw.tween_property(s, "modulate:a", 0.0, 0.35)
	tw.tween_callback(s.queue_free)
	ring(parent, pos, radius, color, 0.45)


static var _crack_tex: Array = []
const CRACK_SIZE: = 256





static func quake(parent: Node3D, pos: Vector3, radius: float, color: = Color(0.85, 0.16, 0.1)) -> void :
	_rec(parent, ["quake", pos, radius, color])

	if hidden():
		return
	if _crack_tex.is_empty():
		for i in 3:
			_crack_tex.append(_crack_texture(1234 + i * 77))
	var s: = Sprite3D.new()
	s.texture = _crack_tex.pick_random()


	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	s.axis = Vector3.AXIS_Y
	s.shaded = false
	s.modulate = Color(color, color.a * dim)
	s.pixel_size = radius * 2.0 / float(CRACK_SIZE)
	s.position = pos + Vector3(0, 0.07, 0)
	s.rotation.y = randf() * TAU

	s.no_depth_test = true
	s.render_priority = layer
	parent.add_child(s)
	s.scale = Vector3.ONE * 0.35
	var tw: = s.create_tween()
	tw.tween_property(s, "scale", Vector3.ONE, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_interval(0.5)
	tw.tween_property(s, "modulate:a", 0.0, 0.55).set_ease(Tween.EASE_IN)
	tw.tween_callback(s.queue_free)

	var glow: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, radius * 0.55, Color(1.0, 0.45, 0.2, 0.55))
	var gt: = glow.create_tween()
	gt.tween_property(glow, "modulate:a", 0.0, 0.5)
	gt.tween_callback(glow.queue_free)
	_quiet = true
	ring(parent, pos, radius, Color(0.65, 0.42, 0.22), 0.5)
	if not _skip(1):
		ring(parent, pos, radius * 0.6, Color(0.9, 0.55, 0.3), 0.35)
	_quiet = false





static func _crack_texture(seed_n: int) -> Texture2D:
	var rng: = RandomNumberGenerator.new()
	rng.seed = seed_n
	var n: = CRACK_SIZE
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c: = Vector2(n, n) * 0.5
	var paths: Array = []
	var mains: = rng.randi_range(7, 9)
	for i in mains:
		var a: = TAU * (float(i) + rng.randf_range(-0.3, 0.3)) / float(mains)
		_crack_walk(rng, c, a, n * rng.randf_range(0.36, 0.47), 4.0, paths, 2)



	for pass_n in 2:
		for seg in paths:
			var w: float = float(seg[2]) * (1.0 if pass_n == 0 else 0.35) + (1.4 if pass_n == 0 else 0.0)
			var col: = Color(0.07, 0.06, 0.05, 1.0) if pass_n == 0 else Color(1, 1, 1, 1)
			_stamp_line(img, seg[0], seg[1], w, col, pass_n == 0)
	return ImageTexture.create_from_image(img)


static func _crack_walk(rng: RandomNumberGenerator, from: Vector2, angle: float, length: float, width: float, 
		out: Array, depth: int) -> void :
	var at: = from
	var a: = angle
	var step: = 7.0
	var steps: = int(length / step)
	for i in steps:
		a += rng.randf_range(-0.45, 0.45)
		var to: = at + Vector2.from_angle(a) * step
		var w: = lerpf(width, 1.2, float(i) / float(steps))
		out.append([at, to, w])
		if depth > 0 and i > 1 and rng.randf() < 0.16:
			_crack_walk(rng, to, a + rng.randf_range(0.5, 1.0) * (1.0 if rng.randf() < 0.5 else -1.0), 
				(length - i * step) * rng.randf_range(0.4, 0.7), w * 0.8, out, depth - 1)
		at = to


static func _stamp_line(img: Image, a: Vector2, b: Vector2, w: float, col: Color, under: bool) -> void :
	var n: = img.get_width()
	var r: = maxf(0.5, w * 0.5)
	var steps: = maxi(1, int(a.distance_to(b)))
	for i in steps + 1:
		var p: = a.lerp(b, float(i) / float(steps))
		for y in range(int(p.y - r - 1), int(p.y + r + 2)):
			for x in range(int(p.x - r - 1), int(p.x + r + 2)):
				if x < 0 or y < 0 or x >= n or y >= n:
					continue
				var d: = Vector2(x + 0.5, y + 0.5).distance_to(p)
				if d > r + 0.5:
					continue
				var k: = clampf(r + 0.5 - d, 0.0, 1.0)
				var old: = img.get_pixel(x, y)
				if under:

					if old.a < k:
						img.set_pixel(x, y, Color(col, k))
				else:
					img.set_pixel(x, y, old.lerp(Color(col, 1.0), k) if old.a > 0.0 else Color(col, k))



static func arc(parent: Node3D, pos: Vector3, dir: Vector3, radius: float, angle: float, color: Color) -> void :
	_rec(parent, ["arc", pos, dir, radius, angle, color])
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps: = 14
	var base: = atan2(dir.x, dir.z)
	for i in steps:
		var a0: = base - angle * 0.5 + angle * i / steps
		var a1: = base - angle * 0.5 + angle * (i + 1) / steps
		var inner: = 0.45
		var p0: = Vector3(sin(a0), 0, cos(a0))
		var p1: = Vector3(sin(a1), 0, cos(a1))
		var c_in: = Color(color, 0.0)
		var c_out: = Color(color, 0.85 * color.a)
		st.set_color(c_in);st.add_vertex(p0 * radius * inner)
		st.set_color(c_out);st.add_vertex(p0 * radius)
		st.set_color(c_out);st.add_vertex(p1 * radius)
		st.set_color(c_in);st.add_vertex(p0 * radius * inner)
		st.set_color(c_out);st.add_vertex(p1 * radius)
		st.set_color(c_in);st.add_vertex(p1 * radius * inner)
	var mi: = MeshInstance3D.new()
	mi.mesh = st.commit()
	var mat: = _material(Color.WHITE)
	mi.material_override = mat
	mi.position = pos + Vector3(0, 0.5, 0)
	parent.add_child(mi)
	var tw: = mi.create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tw.tween_callback(mi.queue_free)



static func column(parent: Node3D, pos: Vector3, color: Color) -> void :
	_rec(parent, ["column", pos, color])
	if _skip(2):
		return
	var s: = Sprite3D.new()
	var g: = Gradient.new()
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0.5, 0.0)
	t.fill_to = Vector2(1.0, 0.0)
	t.repeat = GradientTexture2D.REPEAT_MIRROR
	t.width = 16
	t.height = 256
	s.texture = t
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.shaded = false
	s.modulate = color
	s.pixel_size = 0.04
	s.centered = false
	s.offset = Vector2(-8, 0)
	s.position = pos
	s.render_priority = layer
	parent.add_child(s)
	var tw: = s.create_tween()
	tw.tween_property(s, "modulate:a", 0.0, 0.3)
	tw.tween_callback(s.queue_free)






static func telegraph_circle(parent: Node3D, pos: Vector3, radius: float, duration: float) -> Node3D:
	_rec(parent, ["tcircle", pos, radius, duration])
	var root: = Node3D.new()
	parent.add_child(root)
	var base: = _flat(root, disc_texture(), pos, radius, Color(0.55, 0.02, 0.0, 0.32))
	var edge: = _flat(root, ring_texture(), pos, radius * 1.02, Color(1.0, 0.3, 0.15, 0.95))
	var inner: = _flat(root, ring_texture(), pos, radius * 0.8, Color(1.0, 0.45, 0.25, 0.45))
	var fill: = _flat(root, disc_texture(), pos, radius, Color(1.0, 0.12, 0.05, 0.5))

	fill.name = "Fill"
	for f in [base, edge, inner, fill]:
		danger(f)
	_quiet = true
	magic_circle(root, pos, radius * 0.9, Color(1.0, 0.35, 0.2, 0.6), duration, "mvp_seal", 1.4, DANGER_PRIORITY, true)
	_quiet = false
	fill.scale = Vector3.ONE * 0.05
	var tw: = root.create_tween()
	tw.tween_property(fill, "scale", Vector3.ONE, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(root.queue_free)

	var flare: = edge.create_tween()
	flare.tween_interval(duration * 0.72)
	flare.tween_property(edge, "modulate", Color(1.0, 0.85, 0.6, 1.0), duration * 0.28)

	if duration > 0.5:
		var late: = root.create_tween()
		late.tween_interval(duration - 0.32)
		late.tween_callback( func(): converge(root, pos, radius * 1.02, Color(1.0, 0.85, 0.6, 0.95), 0.32))
	return root




static func telegraph_line(parent: Node3D, from: Vector3, dir: Vector3, length: float, width: float, duration: float) -> Node3D:
	_rec(parent, ["tline", from, dir, length, width, duration])
	var root: = Node3D.new()
	root.position = from + Vector3(0, 0.07, 0)
	root.rotation = Vector3(0, atan2( - dir.x, - dir.z), 0)
	parent.add_child(root)
	_lane(root, width, length, Color(0.6, 0.02, 0.0, 0.28), 0.0)
	var fill: = _lane(root, width, length, Color(1.0, 0.15, 0.08, 0.5), 0.001)
	fill.scale.z = 0.02
	for side in [-1.0, 1.0]:
		var e: = _lane(root, 0.1, length, Color(1.0, 0.4, 0.2, 0.95), 0.002)
		e.position.x = side * (width * 0.5 - 0.05)
	var tw: = root.create_tween()
	tw.tween_property(fill, "scale:z", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(root.queue_free)
	return root



static func _lane(parent: Node3D, width: float, length: float, color: Color, lift: float) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(width, length)
	quad.orientation = PlaneMesh.FACE_Y
	quad.center_offset = Vector3(0, 0, - length * 0.5)
	mi.mesh = quad
	mi.material_override = _danger_mat(color)
	mi.position.y = lift
	parent.add_child(mi)
	return mi


static func _danger_mat(color: Color) -> StandardMaterial3D:
	var mat: = _material(color, false)
	mat.render_priority = DANGER_PRIORITY

	mat.no_depth_test = true
	return mat



static func danger(s: SpriteBase3D) -> void :
	s.render_priority = DANGER_PRIORITY

	s.no_depth_test = true





static func warp_portal(parent: Node3D, color: Color, radius: = 1.0) -> void :
	var tex: = RoAssets.effect_tex("warp_ring")
	for i in 3:
		var mi: = MeshInstance3D.new()
		var cyl: = CylinderMesh.new()
		var r: = radius * (0.55 + i * 0.28)
		cyl.top_radius = r * 0.92
		cyl.bottom_radius = r
		cyl.height = 1.5 + 0.35 * i
		cyl.cap_top = false
		cyl.cap_bottom = false
		cyl.radial_segments = 24
		cyl.rings = 1
		mi.mesh = cyl
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.albedo_texture = tex
		m.albedo_color = Color(color.lightened(0.25 - i * 0.1), 0.95 - i * 0.2)
		m.uv1_scale = Vector3(3.0 + i, 1.0, 1.0)
		m.render_priority = 4

		m.no_depth_test = true
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = Vector3(0, cyl.height * 0.5 + 0.02, 0)
		parent.add_child(mi)
		var spin: = mi.create_tween().set_loops()
		spin.tween_property(mi, "rotation:y", TAU * (1 if i % 2 == 0 else -1), 3.0 + i).as_relative()
		var breathe: = mi.create_tween().set_loops()
		breathe.tween_property(m, "albedo_color:a", 0.35, 0.6 + i * 0.2).set_trans(Tween.TRANS_SINE)
		breathe.tween_property(m, "albedo_color:a", 0.95 - i * 0.2, 0.6 + i * 0.2).set_trans(Tween.TRANS_SINE)
	var ring: = _flat(parent, ring_texture(), Vector3(0, 0.03, 0), radius * 1.3, Color(color.lightened(0.3), 0.9))

	ring.no_depth_test = true
	var tw: = ring.create_tween().set_loops()
	tw.tween_property(ring, "scale", Vector3.ONE * 1.12, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(ring, "scale", Vector3.ONE, 0.7).set_trans(Tween.TRANS_SINE)




static func ray_flash(parent: Node3D, pos: Vector3, cam_basis: Basis, color: = Color.WHITE, size: = 1.0) -> void :
	_rec(parent, ["rays", pos, color, size])
	if _skip(1):
		return
	var tex: = RoAssets.effect_tex("ray_center")
	if tex == null:
		return
	var holder: = Node3D.new()
	parent.add_child(holder)
	holder.global_position = pos
	holder.global_basis = cam_basis
	holder.scale = Vector3.ONE * size



	var mats: Array[StandardMaterial3D] = []
	for layer in 2:
		var mat: = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.no_depth_test = true
		mat.albedo_texture = tex
		mat.albedo_color = Color(color.lerp(Color.WHITE, 0.35) if layer == 0 else color, (1.0 if layer == 0 else 0.55) * dim)
		mat.render_priority = 6
		mats.append(mat)
	var spin: = Node3D.new()
	holder.add_child(spin)
	for layer in 2:
		var n: = 16 if layer == 0 else 8
		var offset: = randf() * TAU
		for i in n:
			var arm: = Node3D.new()
			arm.rotation.z = offset + TAU * (i + randf_range(-0.3, 0.3)) / n
			spin.add_child(arm)
			var ray: = MeshInstance3D.new()
			var quad: = QuadMesh.new()
			quad.size = Vector2(1.0, 0.1 if layer == 0 else 0.34)
			quad.center_offset = Vector3(0.5, 0, 0)
			ray.mesh = quad
			ray.material_override = mats[layer]
			ray.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			ray.scale = Vector3(0.05, 1, 1)
			arm.add_child(ray)
			var reach: = randf_range(1.9, 3.1) if layer == 0 else randf_range(1.0, 1.6)
			var tw: = ray.create_tween()
			tw.tween_property(ray, "scale:x", reach, 0.32).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(ray, "scale:y", 0.35, 0.55).set_delay(0.15)
	spin.create_tween().tween_property(spin, "rotation:z", randf_range(-0.35, 0.35), 0.6)

	var core: = Sprite3D.new()
	core.texture = RoAssets.radial(Color.WHITE, 64)
	core.pixel_size = 1.9 / 64.0
	core.shaded = false
	core.no_depth_test = true
	core.render_priority = 7
	core.modulate = Color(color.lerp(Color.WHITE, 0.6), 0.95 * dim)
	core.scale = Vector3.ONE * 0.3
	holder.add_child(core)
	var ct: = core.create_tween()
	ct.tween_property(core, "scale", Vector3.ONE * 1.15, 0.08).set_ease(Tween.EASE_OUT)
	ct.tween_property(core, "modulate:a", 0.0, 0.3)

	var ring_s: = Sprite3D.new()
	ring_s.texture = ring_texture()
	ring_s.pixel_size = 1.4 / float(ring_s.texture.get_width())
	ring_s.shaded = false
	ring_s.no_depth_test = true
	ring_s.render_priority = 6
	ring_s.modulate = Color(color, 0.7 * dim)
	holder.add_child(ring_s)
	var rt: = ring_s.create_tween()
	rt.tween_property(ring_s, "scale", Vector3.ONE * 3.2, 0.4).set_ease(Tween.EASE_OUT)
	rt.parallel().tween_property(ring_s, "modulate:a", 0.0, 0.4)
	var tw: = holder.create_tween()
	for mat in mats:
		tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.5).set_delay(0.15)
	tw.tween_callback(holder.queue_free)





static func air_impact(parent: Node3D, pos: Vector3, dir: Vector3, size: float) -> void :
	_rec(parent, ["air", pos, dir, size])
	if _skip(1):
		return
	var puff: = Sprite3D.new()
	puff.texture = RoAssets.radial(Color.WHITE, 64)
	puff.pixel_size = size / 64.0
	puff.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	puff.shaded = false
	puff.no_depth_test = true
	puff.render_priority = 6
	puff.modulate = Color(1, 1, 1, 0.55 * dim)
	parent.add_child(puff)
	puff.global_position = pos
	var tw: = puff.create_tween().set_parallel()
	tw.tween_property(puff, "scale", Vector3.ONE * 1.8, 0.2)
	tw.tween_property(puff, "modulate:a", 0.0, 0.2)
	tw.chain().tween_callback(puff.queue_free)
	ring(parent, pos - Vector3(0, 0.5, 0), size, Color(0.9, 1.0, 1.0, 0.8), 0.25)
	arc(parent, pos - Vector3(0, 0.5, 0) + dir.normalized() * size * 0.3, dir, size * 1.1, 1.4, Color(0.85, 1.0, 0.95, 0.6))






static func rain_mark(parent: Node3D, pos: Vector3, radius: float, color: Color, duration: float) -> void :
	_rec(parent, ["rainmark", pos, radius, color, duration])
	var fill: = _flat(parent, disc_texture(), pos, radius, Color(color, 0.22))
	var edge: = _flat(parent, ring_texture(), pos, radius * 1.14, Color(color.lightened(0.45), 1.0))


	for f in [fill, edge]:
		f.no_depth_test = true
		f.render_priority = layer - 1
	var a_fill: = fill.modulate.a
	var a_edge: = edge.modulate.a
	fill.modulate.a = 0.0
	edge.scale = Vector3.ONE * 1.4
	edge.modulate.a = 0.0
	var tw: = fill.create_tween().set_parallel()
	tw.tween_property(fill, "modulate:a", a_fill, 0.1)
	tw.tween_property(edge, "modulate:a", a_edge, 0.1)
	tw.tween_property(edge, "scale", Vector3.ONE, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.chain().tween_interval(maxf(0.0, duration - 0.16))
	tw.chain().tween_property(fill, "modulate:a", 0.0, 0.25)
	tw.parallel().tween_property(edge, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(edge.queue_free)
	tw.chain().tween_callback(fill.queue_free)


static var _streak_mat: StandardMaterial3D




static func streak_sprite(color: Color) -> Sprite3D:
	if _streak_mat == null:
		_streak_mat = _material(Color.WHITE)
		_streak_mat.albedo_color = Color(add_k(), add_k(), add_k(), 1.0)
		_streak_mat.no_depth_test = true
		_streak_mat.albedo_texture = RoAssets.radial(Color.WHITE, 64)
		_streak_mat.render_priority = 5
	var s: = Sprite3D.new()
	s.texture = _streak_mat.albedo_texture
	s.material_override = _streak_mat
	s.shaded = false
	s.pixel_size = 1.0 / 64.0
	s.modulate = Color(color, color.a * dim)
	return s




static func volley_up(parent: Node3D, from: Vector3, color: Color, n: int) -> void :
	_rec(parent, ["volley", from, color, n])
	if _skip(1):
		return
	for i in n:
		var s: = streak_sprite(Color(color.lightened(0.55), 0.9))
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.scale = Vector3(0.1, 1.3, 1.0)
		s.position = from + Vector3(randf_range(-0.3, 0.3), randf_range(-0.2, 0.2), randf_range(-0.2, 0.2))
		parent.add_child(s)
		var a: = s.modulate.a
		s.modulate.a = 0.0
		var tw: = s.create_tween()
		tw.tween_interval(i * 0.04)
		tw.tween_property(s, "modulate:a", a, 0.0)
		tw.tween_property(s, "position:y", s.position.y + 8.0, 0.28).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(s, "modulate:a", 0.0, 0.28).set_ease(Tween.EASE_IN)
		tw.tween_callback(s.queue_free)





static func wind_shot(parent: Node3D, from: Vector3, dir: Vector3, length: float, width: float, cam_pos: Vector3) -> void :
	_rec(parent, ["wind", from, dir, length, width])
	var tex: = RoAssets.effect_tex("ray_center")
	var fwd: = dir.normalized()
	var to_cam: = (cam_pos - (from + fwd * length * 0.5)).normalized()
	var normal: = (to_cam - fwd * to_cam.dot(fwd)).normalized()
	var up: = normal.cross(fwd).normalized()
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.render_priority = 6
	if tex != null:
		mat.albedo_texture = tex
	mat.albedo_color = Color(0.9, 1.0, 0.95, 0.75 * dim)
	var holder: = Node3D.new()
	parent.add_child(holder)
	holder.global_position = from
	holder.global_basis = Basis(fwd, up, normal)

	var parts: = [[width * 0.9, 0.0, 1.0, 0.0, 0.35]]
	for i in 3:
		parts.append([randf_range(0.05, 0.1), randf_range(-0.35, 0.35) * width, randf_range(0.55, 1.0), randf_range(0.0, 0.3), 1.0])
	for part in parts:
		var mi: = MeshInstance3D.new()
		var quad: = QuadMesh.new()
		quad.size = Vector2(1.0, float(part[0]))
		quad.center_offset = Vector3(0.5, 0, 0)
		mi.mesh = quad
		var m: StandardMaterial3D = mat.duplicate()
		m.albedo_color.a *= float(part[4])
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.position = Vector3(length * float(part[3]), float(part[1]), 0)
		mi.scale = Vector3(0.05, 1, 1)
		holder.add_child(mi)
		var tw: = mi.create_tween()
		tw.tween_property(mi, "scale:x", length * float(part[2]) * (1.0 - float(part[3])), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(m, "albedo_color:a", 0.0, 0.3)
	holder.get_tree().create_timer(0.5, false).timeout.connect(holder.queue_free)

	var steps: = 3
	for i in steps:
		var at: = from - Vector3(0, 0.5, 0) + fwd * length * (i + 1) / float(steps + 1)
		var r: = maxf(0.8, width * 0.9)
		var t: = parent.get_tree().create_timer(0.025 * i, false)
		t.timeout.connect( func():
			if is_instance_valid(parent):
				arc(parent, at, fwd, r, 1.3, Color(0.7, 0.85, 0.8, 0.5)))




static func heal_light(parent: Node3D, pos: Vector3, color: = Color(0.55, 1.0, 0.6)) -> void :
	_rec(parent, ["heal", pos, color])
	if _skip(2):
		return
	var glow: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, 1.3, Color(color, 0.7))
	glow.render_priority = GameData.HERO_FX_PRIORITY
	var gt: = glow.create_tween()
	gt.tween_property(glow, "modulate:a", 0.0, 0.9)
	gt.tween_callback(glow.queue_free)
	var col: = beam(parent, pos, color, 3.2)
	(col.material_override as StandardMaterial3D).render_priority = GameData.HERO_FX_PRIORITY
	var ct: = col.create_tween()
	ct.tween_interval(0.5)
	ct.tween_callback(col.queue_free)
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.22, 0.22)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.no_depth_test = true
	pm.render_priority = GameData.HERO_FX_PRIORITY
	var tex: = RoAssets.effect_tex("lv99_bubble")
	pm.albedo_texture = tex if tex != null else RoAssets.radial(Color.WHITE, 32)
	quad.material = pm
	p.mesh = quad
	p.amount = 18
	p.lifetime = 0.9
	p.one_shot = true
	p.explosiveness = 0.6
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	p.emission_ring_axis = Vector3.UP
	p.emission_ring_radius = 0.6
	p.emission_ring_inner_radius = 0.2
	p.emission_ring_height = 0.0
	p.direction = Vector3.UP
	p.spread = 10.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 1.4
	p.initial_velocity_max = 2.4
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(color.lightened(0.4), 1.0))
	ramp.set_color(ramp.get_point_count() - 1, Color(color, 0.0))
	p.color_ramp = ramp
	p.position = pos + Vector3(0, 0.2, 0)
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)





static var _drop_tex: Texture2D
static func blood_spray(parent: Node3D, pos: Vector3, height: float, size: = 1.0) -> void :
	_rec(parent, ["blood", pos, height, size])
	if _skip(1):
		return
	var cloud: = RoAssets.effect_tex("blood_cloud")
	var at: = pos + Vector3(0, height, 0)
	if cloud != null:
		for k in 2:
			var b: = Sprite3D.new()
			b.texture = cloud
			b.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			b.shaded = false
			b.no_depth_test = true
			b.render_priority = layer + 7
			b.flip_h = k == 1
			b.modulate = Color(0.85, 0.04, 0.07, 0.95 * dim) if k == 0 else Color(0.55, 0.0, 0.03, 0.85 * dim)
			b.pixel_size = (2.4 if k == 0 else 1.7) * size / cloud.get_width()
			b.position = at + Vector3(0, 0.1 * k, 0)
			b.scale = Vector3.ONE * 0.3
			parent.add_child(b)
			var tw: = b.create_tween()
			tw.tween_interval(0.05 * k)
			tw.tween_property(b, "scale", Vector3.ONE, 0.13).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tw.tween_interval(0.06)
			tw.parallel().tween_property(b, "position:y", at.y - 0.25, 0.4)
			tw.tween_property(b, "modulate:a", 0.0, 0.3)
			tw.tween_callback(b.queue_free)
	if _drop_tex == null:
		var img: = Image.create(12, 12, false, Image.FORMAT_RGBA8)
		for y in 12:
			for x in 12:
				var d: = Vector2(x - 5.5, y - 5.5).length()
				img.set_pixel(x, y, Color(1, 1, 1, 1.0 if d < 4.6 else (0.5 if d < 5.6 else 0.0)))
		_drop_tex = ImageTexture.create_from_image(img)
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.16, 0.16) * size
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.render_priority = layer + 7
	pm.no_depth_test = true
	pm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	pm.albedo_texture = _drop_tex
	quad.material = pm
	p.mesh = quad
	p.amount = int(34 * size)
	p.lifetime = 0.8
	p.one_shot = true
	p.explosiveness = 0.95
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.25 * size
	p.direction = Vector3.UP
	p.spread = 80.0
	p.gravity = Vector3(0, -16.0, 0)
	p.initial_velocity_min = 3.0 * size
	p.initial_velocity_max = 6.5 * size
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.8
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(0.8, 0.02, 0.06, dim))
	ramp.add_point(0.7, Color(0.55, 0.0, 0.03, dim))
	ramp.set_color(ramp.get_point_count() - 1, Color(0.4, 0.0, 0.02, 0.0))
	p.color_ramp = ramp
	p.position = at
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)

	var stain: = _flat(parent, cloud if cloud != null else RoAssets.radial(Color.WHITE, 128), pos, 1.2 * size, 
		Color(0.5, 0.0, 0.04, 0.9))
	if cloud != null:
		stain.pixel_size = 2.4 * size / cloud.get_width()
	var full: = stain.pixel_size
	stain.pixel_size = full * 0.3
	var st: = stain.create_tween()
	st.tween_interval(0.12)
	st.tween_property(stain, "pixel_size", full, 0.2).set_ease(Tween.EASE_OUT)
	st.tween_interval(1.8)
	st.tween_property(stain, "modulate:a", 0.0, 1.2)
	st.tween_callback(stain.queue_free)






static func venom_spray(parent: Node3D, pos: Vector3, height: float, size: = 1.0) -> void :
	_rec(parent, ["venom", pos, height, size])
	if _skip(1):
		return

	var cloud: = RoAssets.effect_tex("wx_fog")
	var at: = pos + Vector3(0, height, 0)
	if cloud != null:
		for k in 3:
			var b: = Sprite3D.new()
			b.texture = cloud
			b.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			b.shaded = false
			b.no_depth_test = true
			b.render_priority = layer + 7
			b.flip_h = k == 1
			b.modulate = [Color(0.62, 0.76, 0.3, dim), Color(0.52, 0.34, 0.64, 0.85 * dim), Color(0.74, 0.82, 0.42, 0.75 * dim)][k]
			b.pixel_size = [2.0, 1.5, 1.1][k] * size / cloud.get_width()
			b.position = at + Vector3(0, 0.1 * k, 0)
			b.scale = Vector3.ONE * 0.3
			parent.add_child(b)
			var tw: = b.create_tween()
			tw.tween_interval(0.05 * k)
			tw.tween_property(b, "scale", Vector3.ONE * 1.15, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tw.tween_interval(0.08)
			tw.parallel().tween_property(b, "position:y", at.y + 0.35, 0.5)
			tw.tween_property(b, "modulate:a", 0.0, 0.35)
			tw.tween_callback(b.queue_free)
	if _drop_tex == null:
		var img: = Image.create(12, 12, false, Image.FORMAT_RGBA8)
		for y in 12:
			for x in 12:
				var d: = Vector2(x - 5.5, y - 5.5).length()
				img.set_pixel(x, y, Color(1, 1, 1, 1.0 if d < 4.6 else (0.5 if d < 5.6 else 0.0)))
		_drop_tex = ImageTexture.create_from_image(img)
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.16, 0.16) * size
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.render_priority = layer + 7
	pm.no_depth_test = true
	pm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	pm.albedo_texture = _drop_tex
	quad.material = pm
	p.mesh = quad
	p.amount = int(26 * size)
	p.lifetime = 0.9
	p.one_shot = true
	p.explosiveness = 0.9
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.25 * size
	p.direction = Vector3.UP
	p.spread = 70.0
	p.gravity = Vector3(0, -12.0, 0)
	p.initial_velocity_min = 2.5 * size
	p.initial_velocity_max = 5.5 * size
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.6
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(0.76, 0.86, 0.4, dim))
	ramp.add_point(0.7, Color(0.5, 0.36, 0.62, dim))
	ramp.set_color(ramp.get_point_count() - 1, Color(0.3, 0.22, 0.36, 0.0))
	p.color_ramp = ramp
	p.position = at
	parent.add_child(p)
	p.emitting = true
	p.finished.connect(p.queue_free)

	var stain: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, 1.3 * size, Color(0.36, 0.4, 0.24, 0.85))
	var full: = stain.pixel_size
	stain.pixel_size = full * 0.3
	var st: = stain.create_tween()
	st.tween_interval(0.1)
	st.tween_property(stain, "pixel_size", full, 0.25).set_ease(Tween.EASE_OUT)

	var d: = dim
	st.tween_property(stain, "modulate", Color(0.52, 0.56, 0.34, 0.9 * d), 0.4)
	st.tween_property(stain, "modulate", Color(0.36, 0.34, 0.28, 0.85 * d), 0.4)
	st.tween_interval(0.8)
	st.tween_property(stain, "modulate:a", 0.0, 1.2)
	st.tween_callback(stain.queue_free)






static func hold_dim(root: Node, d: float) -> void :
	if root == null or not is_instance_valid(root) or is_equal_approx(float(root.get_meta("dim_now", -1.0)), d):
		return
	root.set_meta("dim_now", d)
	var all: Array = [root]
	all.append_array(root.find_children("*", "", true, false))
	for n in all:
		if n is MeshInstance3D and (n as MeshInstance3D).material_override is StandardMaterial3D:
			var m: = (n as MeshInstance3D).material_override as StandardMaterial3D
			if not n.has_meta("a0"):
				n.set_meta("a0", m.albedo_color.a)
			m.albedo_color.a = float(n.get_meta("a0")) * d
		elif n is SpriteBase3D:
			if not n.has_meta("a0"):
				n.set_meta("a0", (n as SpriteBase3D).modulate.a)
			(n as SpriteBase3D).modulate.a = float(n.get_meta("a0")) * d



static func ground_glow(parent: Node3D, pos: Vector3, radius: float, color: Color) -> Sprite3D:
	return _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, radius, color)


static var _beam_tex: Texture2D




static func beam_flash(parent: Node3D, pos: Vector3, color: Color, height: float, life: = 0.9) -> MeshInstance3D:
	var mi: = beam(parent, pos, color, height)
	var mat: = mi.material_override as StandardMaterial3D
	var tw: = mi.create_tween()
	tw.tween_interval(life * 0.35)
	tw.tween_property(mat, "albedo_color:a", 0.0, life * 0.65)
	tw.tween_callback(mi.queue_free)
	return mi




static func beam(parent: Node3D, pos: Vector3, color: Color, height: float) -> MeshInstance3D:
	if _beam_tex == null:
		var img: = Image.create(16, 64, false, Image.FORMAT_RGBA8)
		for y in 64:
			var fy: = float(y) / 63.0

			var v: = pow(fy, 1.6)
			for x in 16:
				var fx: = 1.0 - absf((x + 0.5) / 8.0 - 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, v * pow(fx, 1.4)))
		_beam_tex = ImageTexture.create_from_image(img)
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.9, height)
	quad.center_offset = Vector3(0, height * 0.5, 0)
	mi.mesh = quad
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = _beam_tex


	mat.albedo_color = Color(color, 0.7 * dim)
	mat.render_priority = layer
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos
	parent.add_child(mi)
	var tw: = mi.create_tween().set_loops()
	tw.tween_property(mat, "albedo_color:a", 0.35 * dim, 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_property(mat, "albedo_color:a", 0.7 * dim, 0.8).set_trans(Tween.TRANS_SINE)
	return mi






static func telegraph_cone(parent: Node3D, pos: Vector3, dir: Vector3, radius: float, angle: float, duration: float) -> Node3D:
	_rec(parent, ["tcone", pos, dir, radius, angle, duration])
	var root: = Node3D.new()
	root.position = pos + Vector3(0, 0.08, 0)
	parent.add_child(root)
	var base_a: = atan2(dir.x, dir.z)
	_fan(root, radius, angle, base_a, Color(0.6, 0.02, 0.0, 0.3), 0.0)
	var fill: = _fan(root, radius, angle, base_a, Color(1.0, 0.15, 0.08, 0.5), 0.001)
	fill.scale = Vector3.ONE * 0.05
	var rim: = _fan_rim(root, radius, angle, base_a, Color(1.0, 0.4, 0.2, 0.95))
	var tw: = root.create_tween()
	tw.tween_property(fill, "scale", Vector3.ONE, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(root.queue_free)
	var flare: = rim.create_tween()
	flare.tween_interval(duration * 0.72)
	flare.tween_property(rim.material_override, "albedo_color", Color(1.0, 0.85, 0.6, 1.0), duration * 0.28)
	return root



static func _fan(parent: Node3D, radius: float, angle: float, base_a: float, color: Color, lift: float) -> MeshInstance3D:
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps: = 20
	for i in steps:
		var a0: = base_a - angle * 0.5 + angle * i / steps
		var a1: = base_a - angle * 0.5 + angle * (i + 1) / steps
		st.set_color(Color(1, 1, 1, 0.45))
		st.add_vertex(Vector3.ZERO)
		st.set_color(Color(1, 1, 1, 1))
		st.add_vertex(Vector3(sin(a0), 0, cos(a0)) * radius)
		st.add_vertex(Vector3(sin(a1), 0, cos(a1)) * radius)
	var mi: = MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _danger_mat(color)
	mi.position.y = lift
	parent.add_child(mi)
	return mi



static func _fan_rim(parent: Node3D, radius: float, angle: float, base_a: float, color: Color) -> MeshInstance3D:
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color.WHITE)
	var w: = 0.1
	var steps: = 20
	for i in steps:
		var o0: = Vector3(sin(base_a - angle * 0.5 + angle * i / steps), 0, cos(base_a - angle * 0.5 + angle * i / steps))
		var o1: = Vector3(sin(base_a - angle * 0.5 + angle * (i + 1) / steps), 0, cos(base_a - angle * 0.5 + angle * (i + 1) / steps))
		for v in [o0 * (radius - w), o0 * radius, o1 * radius, o0 * (radius - w), o1 * radius, o1 * (radius - w)]:
			st.add_vertex(v)
	for edge in [base_a - angle * 0.5, base_a + angle * 0.5]:
		var d: = Vector3(sin(edge), 0, cos(edge))
		var side: = Vector3(d.z, 0, - d.x) * w * 0.5
		for v in [side, d * radius + side, d * radius - side, side, d * radius - side, - side]:
			st.add_vertex(v)
	var mi: = MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = _danger_mat(color)
	mi.position.y = 0.002
	parent.add_child(mi)
	return mi







static func magic_circle(parent: Node3D, pos: Vector3, radius: float, color: Color, duration: = 0.0, 
		key: = "mvp_rune", spin: = 0.6, priority: = -1, over: = false) -> MeshInstance3D:
	var tex: = RoAssets.effect_tex(key)
	if tex == null:
		return null
	if duration > 0.0:
		_rec(parent, ["mcircle", pos, radius, color, duration, key, spin, priority, over])
	var mi: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * radius * 2.0
	mi.mesh = plane
	var mat: = _material(color)
	mat.vertex_color_use_as_albedo = false
	mat.albedo_texture = tex
	mat.render_priority = layer if priority < 0 else priority
	mat.no_depth_test = over
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos + Vector3(0, 0.09, 0)
	parent.add_child(mi)
	mi.scale = Vector3.ONE * 0.6
	mi.create_tween().tween_property(mi, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if spin != 0.0:
		mi.create_tween().set_loops().tween_property(mi, "rotation:y", TAU * signf(spin), TAU / absf(spin)).as_relative()
	if duration > 0.0:
		var a: = mat.albedo_color.a
		mat.albedo_color.a = 0.0
		var tw: = mi.create_tween()
		tw.tween_property(mat, "albedo_color:a", a, minf(0.2, duration * 0.3))
		tw.tween_interval(maxf(0.0, duration - 0.5))
		tw.tween_property(mat, "albedo_color:a", 0.0, 0.3)
		tw.tween_callback(mi.queue_free)
	return mi




static var _strike_texs: = {}




static func _strike_tex(kind: String) -> Texture2D:
	if _strike_texs.has(kind):
		return _strike_texs[kind]
	var g: = Gradient.new()
	var t: = GradientTexture2D.new()
	t.width = 64
	t.height = 64
	if kind == "across":
		g.offsets = PackedFloat32Array([0.0, 0.3, 0.5, 0.7, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.5), Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0)])
		t.fill_from = Vector2(0, 0)
		t.fill_to = Vector2(1, 0)
	else:


		var img: = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		for y in 64:
			var v: = float(y) / 63.0
			var along: = pow(v, 1.5) * smoothstep(1.0, 0.92, v)
			for x in 64:
				var u: = (float(x) + 0.5) / 64.0
				var side: = smoothstep(0.0, 0.14, u) * smoothstep(0.0, 0.14, 1.0 - u)
				img.set_pixel(x, y, Color(1, 1, 1, along * side))
		var it: = ImageTexture.create_from_image(img)
		_strike_texs[kind] = it
		return it
	t.gradient = g
	_strike_texs[kind] = t
	return t




static func _strike_strip(parent: Node3D, width: float, length: float, color: Color, tex: Texture2D, standing: = false, 
		additive: = true) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	if standing:
		q.orientation = PlaneMesh.FACE_X
		q.size = Vector2(length, width)
		q.center_offset = Vector3(0, width * 0.5, - length * 0.5)
	else:
		q.orientation = PlaneMesh.FACE_Y
		q.size = Vector2(width, length)
		q.center_offset = Vector3(0, 0, - length * 0.5)
	mi.mesh = q
	var mat: = _material(color, additive)
	mat.vertex_color_use_as_albedo = false
	mat.albedo_texture = tex
	mat.no_depth_test = not standing
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi





static func strike_line(parent: Node3D, from: Vector3, dir: Vector3, length: float, width: float, color: Color, 
		delay: = 0.0) -> void :
	_rec(parent, ["sline", from, dir, length, width, color, delay])
	var root: = Node3D.new()
	parent.add_child(root)
	root.position = from + Vector3(0, 0.08, 0)
	root.rotation = Vector3(0, atan2( - dir.x, - dir.z), 0)
	var across: = _strike_tex("across")
	var scorch: = _strike_strip(root, width * 0.9, length, Color(0.08, 0.03, 0.02, 0.55), across, false, false)
	var glow: = _strike_strip(root, width * 1.3, length, Color(color.lightened(0.2), 0.9), across)
	var core: = _strike_strip(root, width * 0.35, length, Color(color.lightened(0.75), 1.0), across)
	var curtain: = _strike_strip(root, 2.4, length, Color(color.lightened(0.35), 0.75), _strike_tex("up"), true)
	var parts: = [glow, core, curtain]
	for n in parts + [scorch]:
		n.scale = Vector3(1, 1, 0.03)
	root.visible = delay <= 0.0
	var tw: = root.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
		tw.tween_callback( func(): root.visible = true)

	tw.set_parallel()
	for n in parts + [scorch]:
		tw.tween_property(n, "scale:z", 1.0, 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(glow, "scale:x", 1.35, 0.45).set_ease(Tween.EASE_OUT)
	tw.tween_property(curtain, "scale:y", 1.5, 0.3).set_ease(Tween.EASE_OUT)

	tw.set_parallel(false)
	tw.tween_interval(0.08)
	tw.set_parallel()
	for n in parts:
		tw.tween_property(n.material_override, "albedo_color:a", 0.0, 0.38).set_ease(Tween.EASE_IN)
	tw.tween_property(scorch.material_override, "albedo_color:a", 0.0, 1.1).set_ease(Tween.EASE_IN)
	tw.set_parallel(false)
	tw.tween_callback(root.queue_free)

	var step: = 1.2
	while step < length:
		var puff: = _flat(root, RoAssets.radial(Color.WHITE, 64), Vector3(0, 0.02, - step), width * 0.75, Color(color.lightened(0.5), 0.0))
		puff.no_depth_test = true
		puff.scale = Vector3.ONE * 0.3
		var pt: = puff.create_tween()
		pt.tween_interval(maxf(0.0, delay) + step / length * 0.11)
		pt.tween_property(puff, "modulate:a", 0.9 * dim, 0.03)
		pt.parallel().tween_property(puff, "scale", Vector3.ONE * 1.2, 0.3).set_ease(Tween.EASE_OUT)
		pt.tween_property(puff, "modulate:a", 0.0, 0.25)
		step += 2.6

	if delay <= 0.0:
		_sparks(parent, from + dir * length * 0.35, length * 0.35, color, 4, dir, 1.2)




static func strike_cone(parent: Node3D, pos: Vector3, dir: Vector3, radius: float, angle: float, color: Color) -> void :
	_rec(parent, ["scone", pos, dir, radius, angle, color])
	var root: = Node3D.new()
	parent.add_child(root)
	root.position = pos + Vector3(0, 0.1, 0)
	var base_a: = atan2(dir.x, dir.z)
	var flash: = _fan(root, radius, angle, base_a, Color.WHITE, 0.0)

	var flash_mat: = _material(Color(color.lightened(0.15), 0.55))
	flash_mat.no_depth_test = true
	flash.material_override = flash_mat
	var blade: = _fan(root, radius * 1.05, 0.28, 0.0, Color.WHITE, 0.01)
	var blade_mat: = _material(Color(color.lightened(0.8), 1.0))
	blade_mat.no_depth_test = true
	blade.material_override = blade_mat
	blade.rotation.y = - angle * 0.5 + base_a
	flash.scale = Vector3.ONE * 0.4
	var tw: = root.create_tween().set_parallel()
	tw.tween_property(flash, "scale", Vector3.ONE, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(blade, "rotation:y", base_a + angle * 0.5, 0.16).set_trans(Tween.TRANS_SINE)
	tw.tween_property(flash_mat, "albedo_color:a", 0.0, 0.45).set_delay(0.1).set_ease(Tween.EASE_IN)
	tw.tween_property(blade_mat, "albedo_color:a", 0.0, 0.2).set_delay(0.14)
	tw.chain().tween_callback(root.queue_free)
	_quiet = true
	ring(parent, pos, radius * 0.95, Color(color.lightened(0.4), 0.8), 0.35)
	_quiet = false

	for k in 3:
		var a: = base_a + angle * (float(k) - 1.0) * 0.32
		var d: = Vector3(sin(a), 0, cos(a))
		var pivot: = Node3D.new()
		parent.add_child(pivot)
		pivot.position = pos + Vector3(0, 0.14, 0) + d * radius * 0.08
		pivot.rotation.y = atan2( - d.x, - d.z)
		var slash: = _strike_strip(pivot, 0.55, radius * 0.95, Color(color.lightened(0.7), 1.0), _strike_tex("across"))
		slash.scale = Vector3(1, 1, 0.05)
		var kt: = pivot.create_tween()
		kt.tween_interval(0.03 * k)
		kt.tween_property(slash, "scale:z", 1.0, 0.08).set_ease(Tween.EASE_OUT)
		kt.tween_property(slash, "scale:x", 0.15, 0.22).set_ease(Tween.EASE_IN)
		kt.parallel().tween_property(slash.material_override, "albedo_color:a", 0.0, 0.22)
		kt.tween_callback(pivot.queue_free)


	var scorch: = _fan(parent, radius, angle, base_a, Color.WHITE, 0.0)
	scorch.position = pos + Vector3(0, 0.07, 0)
	var sm: = _material(Color(0.06, 0.02, 0.02, 0.45), false)
	sm.no_depth_test = true
	scorch.material_override = sm
	var st: = scorch.create_tween()
	st.tween_interval(0.5)
	st.tween_property(sm, "albedo_color:a", 0.0, 0.7)
	st.tween_callback(scorch.queue_free)
	_sparks(parent, pos, radius * 1.15, color, 14, dir, angle)




static func strike_circle(parent: Node3D, pos: Vector3, radius: float, color: Color) -> void :
	_rec(parent, ["scircle", pos, radius, color])


	var flash: = _flat(parent, blast_texture(), pos, radius * 1.02, Color(color, 0.8))
	flash.no_depth_test = true
	flash.scale = Vector3.ONE * 0.5
	var tw: = flash.create_tween()
	tw.tween_property(flash, "scale", Vector3.ONE, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(flash, "modulate:a", 0.0, 0.35).set_ease(Tween.EASE_IN)
	tw.tween_callback(flash.queue_free)
	var heart: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, radius * 0.7, Color(color.lightened(0.7), 1.0))
	heart.no_depth_test = true
	var ht: = heart.create_tween()
	ht.tween_property(heart, "scale", Vector3.ONE * 1.3, 0.25).set_ease(Tween.EASE_OUT)
	ht.parallel().tween_property(heart, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)
	ht.tween_callback(heart.queue_free)
	var pillar: = Sprite3D.new()
	pillar.texture = beam_texture()
	pillar.flip_v = true
	pillar.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	pillar.shaded = false
	pillar.centered = false
	pillar.offset = Vector2(-32, 0)
	pillar.pixel_size = radius * 1.1 / 64.0
	pillar.scale = Vector3(1, 2.2, 1)
	pillar.modulate = Color(color.lightened(0.6), 0.85 * dim)
	pillar.render_priority = layer
	pillar.position = pos
	parent.add_child(pillar)
	var pt: = pillar.create_tween().set_parallel()
	pt.tween_property(pillar, "scale:x", 0.15, 0.4).set_ease(Tween.EASE_IN)
	pt.tween_property(pillar, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	pt.chain().tween_callback(pillar.queue_free)

	var core: = pillar.duplicate() as Sprite3D
	core.pixel_size = radius * 0.4 / 64.0
	core.scale = Vector3(1, 3.4, 1)
	core.modulate = Color(1.0, 0.98, 0.9, 0.95 * dim)
	parent.add_child(core)
	var ct: = core.create_tween().set_parallel()
	ct.tween_property(core, "scale:x", 0.05, 0.22).set_ease(Tween.EASE_IN)
	ct.tween_property(core, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)
	ct.chain().tween_callback(core.queue_free)
	_quiet = true
	ring(parent, pos, radius * 1.3, Color(1.0, 0.95, 0.8, 0.95), 0.4)
	ring(parent, pos, radius * 1.7, Color(color.lightened(0.3), 0.7), 0.6)
	_quiet = false
	_scorch(parent, pos, radius, color)
	_sparks(parent, pos, radius * 1.4, color, 10)




static func fall(parent: Node3D, pos: Vector3, radius: float, color: Color, t: = 0.18) -> void :
	_rec(parent, ["fall", pos, radius, color, t])
	var s: = Sprite3D.new()
	s.texture = beam_texture()
	s.flip_v = true
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.shaded = false
	s.centered = false
	s.offset = Vector2(-32, 0)
	s.pixel_size = clampf(radius * 0.4, 0.5, 1.6) / 64.0
	s.scale = Vector3(1, 5.0, 1)
	s.modulate = Color(color.lightened(0.55), 0.95 * dim)
	s.render_priority = layer
	s.position = pos + Vector3(0, 10.0, 0)
	parent.add_child(s)
	var head: = Sprite3D.new()
	head.texture = RoAssets.radial(Color.WHITE, 64)
	head.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	head.shaded = false
	head.pixel_size = clampf(radius * 0.9, 1.0, 3.0) / 64.0
	head.modulate = Color(color.lightened(0.8), dim)
	head.render_priority = layer
	s.add_child(head)
	var tw: = s.create_tween()
	tw.tween_property(s, "position:y", pos.y, t).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.tween_callback(s.queue_free)




static func _scorch(parent: Node3D, pos: Vector3, radius: float, color: Color, hold: = 0.5) -> void :
	var s: = _flat(parent, RoAssets.radial(Color.WHITE, 128), pos, radius * 0.95, Color(0.05, 0.02, 0.02, 0.5))
	s.no_depth_test = true
	var tw: = s.create_tween()
	tw.tween_interval(hold)
	tw.tween_property(s, "modulate:a", 0.0, 0.7)
	tw.tween_callback(s.queue_free)
	if _skip(1):
		return
	if _crack_tex.is_empty():
		for i in 3:
			_crack_tex.append(_crack_texture(1234 + i * 77))
	var c: = Sprite3D.new()
	c.texture = _crack_tex.pick_random()
	c.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	c.axis = Vector3.AXIS_Y
	c.shaded = false
	c.modulate = Color(color, 0.85 * dim)
	c.pixel_size = radius * 1.9 / float(CRACK_SIZE)
	c.position = pos + Vector3(0, 0.08, 0)
	c.rotation.y = randf() * TAU
	c.no_depth_test = true
	c.render_priority = layer
	parent.add_child(c)
	c.scale = Vector3.ONE * 0.4
	var ct: = c.create_tween()
	ct.tween_property(c, "scale", Vector3.ONE, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	ct.tween_interval(hold * 0.3)
	ct.tween_property(c, "modulate:a", 0.0, 0.45).set_ease(Tween.EASE_IN)
	ct.tween_callback(c.queue_free)


const SPARKS_PER_FRAME: = 36
static var _spark_frame: = -1
static var _spark_left: = 0




static func _sparks(parent: Node3D, pos: Vector3, reach: float, color: Color, n: int, dir: = Vector3.FORWARD, 
		spread: = TAU) -> void :
	if _skip(1):
		return


	var frame: = Engine.get_process_frames()
	if frame != _spark_frame:
		_spark_frame = frame
		_spark_left = SPARKS_PER_FRAME
	n = mini(n, _spark_left)
	_spark_left -= n
	var tex: = _strike_tex("across")
	var base: = atan2(dir.x, dir.z)
	for i in n:
		var a: = randf() * TAU if spread >= TAU else base + (randf() - 0.5) * spread
		var d: = Vector3(sin(a), 0, cos(a))
		var pivot: = Node3D.new()
		parent.add_child(pivot)
		pivot.position = pos + Vector3(0, 0.15, 0) + d * reach * 0.15
		pivot.rotation.y = atan2( - d.x, - d.z)
		var s: = _strike_strip(pivot, randf_range(0.14, 0.24), reach * randf_range(0.2, 0.34), Color(color.lightened(0.6), 1.0), tex)
		var t: = randf_range(0.22, 0.38)
		var tw: = pivot.create_tween().set_parallel()
		tw.tween_property(pivot, "position", pos + Vector3(0, 0.15, 0) + d * reach * randf_range(0.7, 1.1), t).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(s, "scale:z", 0.2, t).set_ease(Tween.EASE_IN)
		tw.tween_property(s.material_override, "albedo_color:a", 0.0, t).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(pivot.queue_free)
