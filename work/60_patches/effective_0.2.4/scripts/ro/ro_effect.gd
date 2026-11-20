class_name RoEffect
extends Node3D














const ORIGIN: = Vector2(320.0, 320.0)
const BLEND_MIX: = 0
const BLEND_ADD: = 1
const BLEND_PREMUL: = 2



static var layer: = 0

var data: Dictionary

var px_size: = 0.027
var loop: = false

var intensity: = 1.0

var follow: Node3D
var _time: = 0.0
var _layer: = 0
var _mis: = {}


var _built_f: = -1
var _built_intensity: = -1.0

static var _mats: = {}








const GROUND_LAYERS: = {
	"sanctuary": [1, 2, 3, 4], 
	"thunderstorm": [11, 12, 13], 
	"stormgust": [34, 35, 36], 
	"quagmire": [], 
}

const GROUND: = 10

const STENCIL_MOB: = 1
static var _ground_shaders: = {}



static func spawn(parent: Node, effect: String, at: Vector3, size: = 1.0, follow_node: Node3D = null) -> RoEffect:
	var d: = RoAssets.effect_data(effect)
	if d.is_empty():
		return null
	var e: = RoEffect.new()
	_ground_flags(d, effect)
	e.data = d
	e._layer = layer

	if follow_node is Player:
		e._layer = maxi(layer, GameData.HERO_FX_PRIORITY)
	e.px_size = GameData.PIXEL_SIZE * size
	e.follow = follow_node
	parent.add_child(e)
	e.global_position = at
	return e




static func _material(atlas: Texture2D, blend: int, priority: int, alpha: float) -> Material:
	var step: = clampi(roundi(alpha * 32.0), 0, 32)
	var key: = "%d:%d:%d:%d" % [atlas.get_instance_id(), blend, priority, step]
	var mat: Material = _mats.get(key)
	if mat == null:
		if blend >= GROUND:
			return _ground_material(atlas, blend - GROUND, priority, step, key)
		if blend == BLEND_ADD and RenderingServer.get_current_rendering_method() != "gl_compatibility":
			return _add_material(atlas, priority, step, key)
		mat = StandardMaterial3D.new()
		var sm: = mat as StandardMaterial3D
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm.blend_mode = [BaseMaterial3D.BLEND_MODE_MIX, BaseMaterial3D.BLEND_MODE_ADD, 
			BaseMaterial3D.BLEND_MODE_PREMULT_ALPHA][blend]
		sm.cull_mode = BaseMaterial3D.CULL_DISABLED
		sm.vertex_color_use_as_albedo = true
		sm.albedo_texture = atlas
		var k: = Vfx.add_k() if blend == BLEND_ADD else 1.0
		sm.albedo_color = Color(k, k, k, step / 32.0)
		sm.no_depth_test = true
		sm.render_priority = priority
		_mats[key] = mat
	return mat








static var _add_shader: Shader


static func _add_material(atlas: Texture2D, priority: int, step: int, key: String) -> ShaderMaterial:
	if _add_shader == null:
		_add_shader = Shader.new()
		_add_shader.code = "shader_type spatial;\r\nrender_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_add;\r\nuniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;\r\nuniform sampler2D screen : hint_screen_texture, filter_nearest;\r\nuniform float alpha = 1.0;\r\n\r\nvec3 to_srgb(vec3 c) {\r\n\tc = clamp(c, 0.0, 1.0);\r\n\treturn mix(1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, c * 12.92, vec3(lessThan(c, vec3(0.0031308))));\r\n}\r\n\r\nvec3 to_linear(vec3 c) {\r\n\treturn mix(pow((c + 0.055) / 1.055, vec3(2.4)), c / 12.92, vec3(lessThan(c, vec3(0.04045))));\r\n}\r\n\r\nvoid fragment() {\r\n\tvec4 t = texture(tex, UV) * COLOR;\r\n\tvec3 add = to_srgb(t.rgb) * t.a * alpha;\r\n\tvec3 under = texture(screen, SCREEN_UV).rgb;\r\n\tvec3 want = to_linear(min(to_srgb(under) + add, vec3(1.0)));\r\n\tALBEDO = max(want - under, vec3(0.0));\r\n\tALPHA = 1.0;\r\n}\r\n"























	var mat: = ShaderMaterial.new()
	mat.shader = _add_shader
	mat.set_shader_parameter("tex", atlas)
	mat.set_shader_parameter("alpha", step / 32.0)
	mat.render_priority = priority
	_mats[key] = mat
	return mat




static func _ground_material(atlas: Texture2D, blend: int, priority: int, step: int, key: String) -> ShaderMaterial:
	if not _ground_shaders.has(blend):
		var sh: = Shader.new()
		sh.code = """shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, %s;
stencil_mode read, compare_not_equal, %d;
uniform sampler2D tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec4 c = texture(tex, UV) * COLOR * tint;
	ALBEDO = c.rgb;
	ALPHA = c.a;
}
""" %["blend_add" if blend == BLEND_ADD else "blend_mix", STENCIL_MOB]
		_ground_shaders[blend] = sh
	var mat: = ShaderMaterial.new()
	mat.shader = _ground_shaders[blend]
	mat.set_shader_parameter("tex", atlas)
	var k: = Vfx.add_k() if blend == BLEND_ADD else 1.0
	mat.set_shader_parameter("tint", Color(k, k, k, step / 32.0))
	mat.render_priority = priority
	_mats[key] = mat
	return mat




static func _ground_flags(d: Dictionary, effect: String) -> Array:
	if d.has("_ground"):
		return d._ground
	var flags: = []
	flags.resize((d.layers as Array).size())
	flags.fill(false)
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":
		var name: = effect.get_file()
		if "bottom" in effect:
			flags.fill(true)
		elif GROUND_LAYERS.has(name):
			var only: Array = GROUND_LAYERS[name]
			for i in flags.size():
				flags[i] = only.is_empty() or only.has(i)
	d["_ground"] = flags
	return flags


func _ready() -> void :
	var keys: = [BLEND_MIX, BLEND_ADD]
	if (data.get("_ground", []) as Array).has(true):
		keys += [GROUND + BLEND_MIX, GROUND + BLEND_ADD]
	for blend in keys:
		var mi: = MeshInstance3D.new()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
		_mis[blend] = mi


func _process(delta: float) -> void :
	var t0: = Time.get_ticks_usec() if World.bench else 0
	_time += delta
	var f: = int(_time * float(data.fps))
	if f >= int(data.max_key):
		if not loop:
			queue_free()
			if World.bench:
				World.bench_fx += Time.get_ticks_usec() - t0
			return
		_time = 0.0
		f = 0
	if follow != null and is_instance_valid(follow):
		global_position = follow.global_position
	var cam: = get_viewport().get_camera_3d()
	if cam != null:

		global_basis = cam.global_basis * Basis.from_scale(Vector3(px_size, px_size, px_size))
	if intensity != _built_intensity:
		_built_intensity = intensity
		var prio: = maxi(5, _layer)
		for blend in _mis:
			(_mis[blend] as MeshInstance3D).material_override = _material(data.atlas, blend, prio, intensity)
	if f != _built_f:
		_built_f = f
		var frame: Dictionary = _frame(data, f)
		for blend in _mis:
			(_mis[blend] as MeshInstance3D).mesh = frame.get(blend)
	if World.bench:
		World.bench_fx += Time.get_ticks_usec() - t0





static func _frame(d: Dictionary, f: int) -> Dictionary:
	if not d.has("_bake"):
		d["_bake"] = {}
	var bake: Dictionary = d._bake
	if bake.has(f):
		return bake[f]
	var quads: = {BLEND_MIX: [], BLEND_ADD: [], BLEND_PREMUL: [], GROUND + BLEND_MIX: [], GROUND + BLEND_ADD: []}
	var ground: Array = d.get("_ground", [])
	var layers: Array = d.layers
	for i in layers.size():
		_sample(d, layers[i], f, quads, GROUND if i < ground.size() and ground[i] else 0)
	var out: = {}
	for blend in [BLEND_MIX, BLEND_ADD, GROUND + BLEND_MIX, GROUND + BLEND_ADD]:
		var verts: Array = quads[blend]
		if verts.is_empty():
			continue
		var pv: = PackedVector3Array()
		var uv: = PackedVector2Array()
		var col: = PackedColorArray()
		pv.resize(verts.size())
		uv.resize(verts.size())
		col.resize(verts.size())
		for i in verts.size():
			pv[i] = verts[i][0]
			uv[i] = verts[i][1]
			col[i] = verts[i][2]
		var arrays: = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = pv
		arrays[Mesh.ARRAY_TEX_UV] = uv
		arrays[Mesh.ARRAY_COLOR] = col
		var mesh: = ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		out[blend] = mesh
	bake[f] = out
	return out


static func _sample(data: Dictionary, layer: Dictionary, f: int, quads: Dictionary, on_ground: = 0) -> void :
	var keys: Array = layer.keys
	var pool: Array = layer.tex
	if pool.is_empty():
		return
	var basis_i: = -1
	var morph_i: = -1
	for i in keys.size():
		var k: Array = keys[i]
		if int(k[0]) <= f:
			if int(k[1]) == 0:
				basis_i = i
			elif int(k[1]) == 1:
				morph_i = i
	if basis_i < 0:
		return
	var b: Array = keys[basis_i]
	var pos: = Vector2(b[2], b[3])
	var xy: Array = b.slice(4, 12)
	var angle: float = b[15]
	var col: = Color(b[16], b[17], b[18], b[19])
	var tex: = int(b[12])
	if morph_i > basis_i:
		var m: Array = keys[morph_i]
		var dt: = float(f - int(b[0]))
		pos += Vector2(m[2], m[3]) * dt
		for i in 8:
			xy[i] = float(xy[i]) + float(m[4 + i]) * dt
		angle += float(m[15]) * dt
		col += Color(m[16], m[17], m[18], m[19]) * dt
		tex = _advance_texture(b, m, dt, pool.size())
	if col.a <= 0.0:
		return
	tex = clampi(tex, 0, pool.size() - 1)
	var rect: Array = data.textures[int(pool[tex])]
	var w: = float(data.w)
	var h: = float(data.h)
	var uv: = [Vector2(rect[0] / w, rect[1] / h), Vector2((rect[0] + rect[2]) / w, rect[1] / h), 
		Vector2((rect[0] + rect[2]) / w, (rect[1] + rect[3]) / h), Vector2(rect[0] / w, (rect[1] + rect[3]) / h)]
	var rad: = deg_to_rad(angle)
	var ca: = cos(rad)
	var sa: = sin(rad)
	var p: = []
	for i in 4:
		var cx: float = xy[i]
		var cy: float = xy[i + 4]
		var c: = Vector2(cx * ca - cy * sa, cx * sa + cy * ca) + pos - ORIGIN
		p.append(Vector3(c.x, - c.y, 0.0))
	var color: = Color(clampf(col.r / 255.0, 0, 1), clampf(col.g / 255.0, 0, 1), 
		clampf(col.b / 255.0, 0, 1), clampf(col.a / 255.0, 0, 1))
	var blend: = int(b[20])
	var tex_alpha: Array = data.get("tex_alpha", [])
	var gi: = int(pool[tex])
	if blend == BLEND_PREMUL or (gi < tex_alpha.size() and not tex_alpha[gi]):
		blend = BLEND_ADD
	var out: Array = quads.get(blend + on_ground, quads[BLEND_ADD + on_ground])
	for i in [0, 1, 2, 0, 2, 3]:
		out.append([p[i], uv[i], color])


static func _advance_texture(b: Array, m: Array, dt: float, n: int) -> int:
	var base: = float(b[12])
	match int(m[13]):
		1:
			return int(base + float(m[12]) * dt)
		2:
			return int(minf(base + float(m[14]) * dt, n - 1))
		3:
			return posmod(int(base + float(m[14]) * dt), n)
		4:
			return posmod(int(base - float(m[14]) * dt), n)
	return int(base)
