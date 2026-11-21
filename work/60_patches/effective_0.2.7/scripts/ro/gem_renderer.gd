class_name GemRenderer
extends Node3D














const SHADER: = "\r\nshader_type spatial;\r\nrender_mode unshaded, cull_disabled, depth_draw_opaque;\r\n\r\nuniform sampler2D tex : source_color, filter_nearest;\r\n// Seconds between two glints of a gem and how bright the glint is.\r\nuniform float glint_every = 3.0;\r\nuniform float glint_power = 0.7;\r\n\r\nvarying float phase;\r\n\r\nvoid vertex() {\r\n\t// Billboard facing the camera, keeping the instance position.\r\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1],\r\n\t\tINV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\r\n\t// Each gem glints at its own moment (from where it lies).\r\n\tvec2 p = MODEL_MATRIX[3].xz;\r\n\tphase = fract(sin(dot(floor(p * 4.0), vec2(12.9898, 78.233))) * 43758.5453);\r\n}\r\n\r\nvoid fragment() {\r\n\tvec4 c = texture(tex, UV);\r\n\tif (c.a < 0.5) {\r\n\t\tdiscard;\r\n\t}\r\n\t// A diagonal band of light crosses the stone, on whole texels (crisp\r\n\t// as the sprite), in the first fifth of each cycle.\r\n\tvec2 size = vec2(textureSize(tex, 0));\r\n\tvec2 px = (floor(UV * size) + 0.5) / size;\r\n\tfloat t = fract(TIME / glint_every + phase);\r\n\tfloat sweep = t / 0.2 * 1.5 - 0.25;\r\n\tfloat d = abs((px.x + 1.0 - px.y) * 0.5 - sweep);\r\n\tfloat band = (t < 0.2) ? step(d, 0.09) + step(d, 0.16) * 0.45 : 0.0;\r\n\tALBEDO = c.rgb + vec3(band * glint_power);\r\n}\r\n"





































const HALO_SHADER: = "\r\nshader_type spatial;\r\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\r\n\r\nuniform sampler2D tex : filter_linear;\r\nuniform vec4 halo_color : source_color = vec4(1.0);\r\n\r\nvoid vertex() {\r\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1],\r\n\t\tINV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\r\n\t// A little behind the stone (its local Z points at the camera).\r\n\tVERTEX.z -= 0.08;\r\n}\r\n\r\nvoid fragment() {\r\n\tfloat breathe = 0.75 + 0.25 * sin(TIME * 3.0 + MODEL_MATRIX[3].x);\r\n\tALBEDO = halo_color.rgb;\r\n\tALPHA = texture(tex, UV).a * halo_color.a * breathe;\r\n}\r\n"





















const TRAIL_SHADER: = "\r\nshader_type spatial;\r\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\r\n\r\nuniform sampler2D tex : filter_linear;\r\n\r\nvoid vertex() {\r\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1],\r\n\t\tINV_VIEW_MATRIX[2], MODEL_MATRIX[3]) * mat4(MODEL_MATRIX[0], MODEL_MATRIX[1], MODEL_MATRIX[2], vec4(0.0, 0.0, 0.0, 1.0));\r\n}\r\n\r\nvoid fragment() {\r\n\tALBEDO = COLOR.rgb;\r\n\tALPHA = texture(tex, UV).a * COLOR.a;\r\n}\r\n"


















const TIER_LOOK: = [
	{"every": 3.6, "power": 0.55, "color": Color(0.45, 0.7, 1.0), "halo": 0.0, "halo_a": 0.0}, 
	{"every": 3.0, "power": 0.65, "color": Color(1.0, 0.85, 0.35), "halo": 0.0, "halo_a": 0.0}, 
	{"every": 2.3, "power": 0.8, "color": Color(1.0, 0.35, 0.3), "halo": 1.1, "halo_a": 0.35}, 
	{"every": 1.6, "power": 0.95, "color": Color(1.0, 0.82, 0.35), "halo": 1.6, "halo_a": 0.5}, 
]

const TRAIL_SIZE: = 0.32


static var plain: = false


var _looks: = {}
var _shader: Shader
var _halo_shader: Shader
var _trail: MultiMeshInstance3D
var _trail_buf: = PackedFloat32Array()






const COIN_GLOW: = Color(1.0, 0.85, 0.35, 0.6)
const COIN_GLOW_PIXEL: = 0.014

var _coins: Array = []

var _coin_mmi: Array = []
var _coin_buf: Array = [PackedFloat32Array(), PackedFloat32Array(), PackedFloat32Array()]


func _ready() -> void :
	_shader = Shader.new()
	_shader.code = SHADER
	_halo_shader = Shader.new()
	_halo_shader.code = HALO_SHADER
	var ts: = Shader.new()
	ts.code = TRAIL_SHADER
	var mat: = ShaderMaterial.new()
	mat.shader = ts
	mat.set_shader_parameter("tex", RoAssets.radial(Color.WHITE, 32))
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE * TRAIL_SIZE
	quad.material = mat
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = quad
	mm.instance_count = 0
	_trail = MultiMeshInstance3D.new()
	_trail.multimesh = mm
	_trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_trail)


func _look(key: String, tex: Texture2D, pixel_size: float, tier: int) -> Dictionary:
	if _looks.has(key):
		return _looks[key]
	var tl: Dictionary = TIER_LOOK[clampi(tier, 0, TIER_LOOK.size() - 1)]
	var mat: = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("tex", tex)
	mat.set_shader_parameter("glint_every", float(tl.every))
	mat.set_shader_parameter("glint_power", 0.0 if plain else float(tl.power))
	var quad: = QuadMesh.new()
	quad.size = Vector2(tex.get_width(), tex.get_height()) * pixel_size
	quad.material = mat
	var look: = {"mmi": _batch(quad, false), "buf": PackedFloat32Array(), "halo": null, "hbuf": PackedFloat32Array()}
	if float(tl.halo) > 0.0 and not plain:
		var hm: = ShaderMaterial.new()
		hm.shader = _halo_shader
		hm.set_shader_parameter("tex", RoAssets.radial(Color.WHITE, 64))
		hm.set_shader_parameter("halo_color", Color(tl.color, float(tl.halo_a)))
		var hq: = QuadMesh.new()
		hq.size = Vector2.ONE * float(tl.halo)
		hq.material = hm
		look.halo = _batch(hq, false)
	_looks[key] = look
	return look


func _batch(mesh: Mesh, colors: bool) -> MultiMeshInstance3D:
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = colors
	mm.mesh = mesh
	mm.instance_count = 0
	var mmi: = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	return mmi





func add_coin(node: Node3D, tex: Texture2D, pixel_sizes: Array, big: bool) -> void :
	if _coin_mmi.is_empty():
		_coin_mmi = [_coin_batch(tex, float(pixel_sizes[0])), _coin_batch(tex, float(pixel_sizes[1])), _coin_glow_batch()]
	node.set_meta("coin_big", big)
	_coins.append(node)





func _coin_batch(tex: Texture2D, pixel_size: float) -> MultiMeshInstance3D:
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mat.alpha_scissor_threshold = 0.5
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.vertex_color_is_srgb = true
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.albedo_texture = tex
	var quad: = QuadMesh.new()
	quad.size = Vector2(tex.get_width(), tex.get_height()) * pixel_size
	quad.material = mat
	return _batch(quad, false)





func _coin_glow_batch() -> MultiMeshInstance3D:
	var tex: = RoAssets.radial(Color.WHITE, 64)
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED

	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true
	mat.albedo_texture = tex
	var quad: = QuadMesh.new()
	quad.size = Vector2(tex.get_width(), tex.get_height()) * COIN_GLOW_PIXEL
	quad.material = mat
	return _batch(quad, true)




func _fill_glow(mmi: MultiMeshInstance3D, buf: PackedFloat32Array, at: Array, bounds: AABB) -> PackedFloat32Array:
	var mm: = mmi.multimesh
	var n: = at.size()
	if n > mm.instance_count:
		mm.visible_instance_count = 0
		mm.instance_count = n * 2
	if buf.size() != mm.instance_count * 16:
		buf.resize(mm.instance_count * 16)
		buf.fill(0.0)
		for i in mm.instance_count:
			var o: = i * 16
			buf[o] = 1.0
			buf[o + 5] = 1.0
			buf[o + 10] = 1.0
			buf[o + 12] = COIN_GLOW.r
			buf[o + 13] = COIN_GLOW.g
			buf[o + 14] = COIN_GLOW.b
			buf[o + 15] = COIN_GLOW.a
	for i in n:
		var pos: Vector3 = at[i]
		buf[i * 16 + 3] = pos.x
		buf[i * 16 + 7] = pos.y
		buf[i * 16 + 11] = pos.z
	if n > 0:
		mm.buffer = buf
	mm.visible_instance_count = n
	mmi.custom_aabb = bounds
	return buf


func _update_coins(bounds: AABB) -> void :
	if _coin_mmi.is_empty():
		return
	var small: Array = []
	var big: Array = []
	var all: Array = []
	var keep: = 0
	for c in _coins:

		if not is_instance_valid(c) or (c as Node).is_queued_for_deletion():
			continue
		_coins[keep] = c
		keep += 1
		var node: = c as Node3D
		if not node.is_inside_tree() or not node.is_visible_in_tree():
			continue
		var at: = node.global_position
		(big if node.get_meta("coin_big", false) else small).append(at)
		all.append(at)
	_coins.resize(keep)
	_coin_buf[0] = _fill(_coin_mmi[0], _coin_buf[0], small, bounds)
	_coin_buf[1] = _fill(_coin_mmi[1], _coin_buf[1], big, bounds)
	_coin_buf[2] = _fill_glow(_coin_mmi[2], _coin_buf[2], all, bounds)




func update(pickups: Array, looks: Dictionary, bounds: AABB) -> void :
	_update_coins(bounds)
	var by_look: = {}
	var trail: Array = []
	for p in pickups:
		if p.kind != "xp":
			continue
		var node: Node3D = p.node
		if not is_instance_valid(node) or not node.visible:
			continue
		var key: String = p.get("gem", "")
		if not by_look.has(key):
			by_look[key] = []
		by_look[key].append(node.position)
		if p.has("trail") and not plain:
			trail.append([p.trail, int(looks.get(key, [null, 0.0, 0])[2])])
	for key in looks:
		var info: Array = looks[key]
		var look: = _look(key, info[0], info[1], int(info[2]) if info.size() > 2 else 0)
		var at: Array = by_look.get(key, [])
		look.buf = _fill(look.mmi, look.buf, at, bounds)
		if look.halo != null:
			look.hbuf = _fill(look.halo, look.hbuf, at, bounds)
	_fill_trail(trail, bounds)



func _fill(mmi: MultiMeshInstance3D, buf: PackedFloat32Array, at: Array, bounds: AABB) -> PackedFloat32Array:
	var mm: = mmi.multimesh
	var n: = at.size()
	if n > mm.instance_count:
		mm.visible_instance_count = 0
		mm.instance_count = n * 2
	if buf.size() != mm.instance_count * 12:
		buf.resize(mm.instance_count * 12)
		buf.fill(0.0)
		for i in mm.instance_count:
			buf[i * 12] = 1.0
			buf[i * 12 + 5] = 1.0
			buf[i * 12 + 10] = 1.0
	for i in n:
		var pos: Vector3 = at[i]
		buf[i * 12 + 3] = pos.x
		buf[i * 12 + 7] = pos.y
		buf[i * 12 + 11] = pos.z
	if n > 0:
		mm.buffer = buf
	mm.visible_instance_count = n
	mmi.custom_aabb = bounds
	return buf




func _fill_trail(trail: Array, bounds: AABB) -> void :
	var mm: = _trail.multimesh
	var n: = 0
	for t in trail:
		n += (t[0] as Array).size()
	if n > mm.instance_count:
		mm.visible_instance_count = 0
		mm.instance_count = n * 2
	if _trail_buf.size() != mm.instance_count * 16:
		_trail_buf.resize(mm.instance_count * 16)
		_trail_buf.fill(0.0)
	var i: = 0
	for t in trail:
		var col: Color = TIER_LOOK[clampi(int(t[1]), 0, TIER_LOOK.size() - 1)].color
		var pts: Array = t[0]
		for j in pts.size():
			var pos: Vector3 = pts[j]
			var s: = 1.0 - 0.3 * j
			var o: = i * 16
			_trail_buf[o] = s
			_trail_buf[o + 5] = s
			_trail_buf[o + 10] = s
			_trail_buf[o + 3] = pos.x
			_trail_buf[o + 7] = pos.y
			_trail_buf[o + 11] = pos.z
			_trail_buf[o + 12] = col.r
			_trail_buf[o + 13] = col.g
			_trail_buf[o + 14] = col.b
			_trail_buf[o + 15] = 0.55 - 0.18 * j
			i += 1
	if n > 0:
		mm.buffer = _trail_buf
	mm.visible_instance_count = n
	_trail.custom_aabb = bounds







static func ding_stream() -> AudioStreamWAV:
	var rate: = 22050
	var length: = int(rate * 0.32)
	var data: = PackedByteArray()
	data.resize(length * 2)
	var f: = 1046.5
	for i in length:
		var t: = float(i) / rate
		var env: = minf(1.0, t / 0.003) * exp( - t / 0.085)
		var v: = sin(TAU * f * t) + 0.16 * sin(TAU * f * 2.0 * t) * exp( - t / 0.04) + 0.05 * sin(TAU * f * 3.0 * t) * exp( - t / 0.025)

		var tail: = clampf((length - i) / (rate * 0.02), 0.0, 1.0)
		data.encode_s16(i * 2, int(clampf(v * env * tail * 0.42, -1.0, 1.0) * 32767.0))
	var s: = AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo = false
	s.data = data
	return s
