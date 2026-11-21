extends Node3D







const COLOR: = Color(1.0, 0.9, 0.62)
const CORE: = Color(1.0, 0.99, 0.94)

const STRETCH: = Vector2(1.18, 1.06)

const ALPHA: = 0.9


const RIM: = Color(1.0, 0.64, 0.1, 0.95)
const RIM_STRETCH: = Vector2(1.1, 1.04)

const SHADER: = "\nshader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\nuniform sampler2D tex : filter_linear;\nuniform vec4 glow_color : source_color = vec4(1.0);\nuniform vec4 core_color : source_color = vec4(1.0);\nuniform vec2 stretch = vec2(1.0);\nuniform float strength = 1.0;\nuniform float t = 0.0;\nuniform float rim = 0.0;\nvoid vertex() {\n\tVERTEX.xy *= stretch;\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\n}\nvoid fragment() {\n\tvec2 px = 1.0 / vec2(textureSize(tex, 0));\n\tfloat near = 0.0;\n\tfloat far = 0.0;\n\tfor (int i = 0; i < 12; i++) {\n\t\tvec2 d = vec2(cos(float(i) * 0.5236), sin(float(i) * 0.5236)) * px;\n\t\tnear += texture(tex, UV + d * 1.5).a;\n\t\tfar += texture(tex, UV + d * 4.0).a;\n\t}\n\tnear /= 12.0;\n\tfar /= 12.0;\n\t// A glimmer running out along the wings, from the back to the tips.\n\tfloat run = 0.75 + 0.25 * sin(t * 2.4 - abs(UV.x - 0.5) * 14.0);\n\tALBEDO = mix(glow_color.rgb, core_color.rgb, near);\n\tfloat a = clamp(near * 0.9 + far * 0.7, 0.0, 1.0);\n\tif (rim > 0.5) {\n\t\t// The rim: around the wings' edge, little over the wings themselves.\n\t\ta = clamp(near * 2.2 + far * 1.2, 0.0, 1.0) * (1.0 - texture(tex, UV).a * 0.75);\n\t\tALBEDO = glow_color.rgb;\n\t}\n\tALPHA = a * glow_color.a * strength * run;\n}\n"





































static var _shader: Shader
static var _rim_shader: Shader

var _light: Sprite3D
var _mat: ShaderMaterial
var _rim: Sprite3D
var _rim_mat: ShaderMaterial
var _t: = 0.0



static func set_on(visual: Node3D, on: bool) -> void :
	if visual == null or not is_instance_valid(visual):
		return
	var had: Node = visual.get_node_or_null("HelWings")
	if on and had == null:
		var w = load("res://scripts/ro/hel_wings.gd").new()
		w.name = "HelWings"
		visual.add_child(w)
	elif not on and had != null:
		had.queue_free()


func _ready() -> void :
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER
	_light = Sprite3D.new()
	_light.centered = false
	_mat = ShaderMaterial.new()
	_mat.shader = _shader
	_mat.set_shader_parameter("glow_color", Color(COLOR, ALPHA))
	_mat.set_shader_parameter("core_color", CORE)
	_mat.set_shader_parameter("stretch", STRETCH)
	_light.material_override = _mat
	add_child(_light)
	if _rim_shader == null:
		_rim_shader = Shader.new()
		_rim_shader.code = SHADER.replace("blend_add", "blend_mix")
	_rim = Sprite3D.new()
	_rim.centered = false
	_rim_mat = ShaderMaterial.new()
	_rim_mat.shader = _rim_shader
	_rim_mat.set_shader_parameter("glow_color", RIM)
	_rim_mat.set_shader_parameter("core_color", RIM)
	_rim_mat.set_shader_parameter("stretch", RIM_STRETCH)
	_rim_mat.set_shader_parameter("rim", 1.0)
	_rim.material_override = _rim_mat
	add_child(_rim)


func _process(dt: float) -> void :
	var v: = get_parent() as RoVisual
	if v == null or v.ro == null or v.sprite == null:
		_light.visible = false
		return
	var act: = v.base_action * RoSprite.DIRS + v._shown
	var tex: = v.ro.robe_frame(act, v._frame, v._sub)
	_light.visible = tex != null and v.sprite.visible and v.visible
	_rim.visible = _light.visible
	if not _light.visible:
		return
	_t += dt
	_light.texture = tex
	_light.pixel_size = v.sprite.pixel_size
	_light.offset = v.sprite.offset

	_light.position = v.sprite.position - RoVisual.lift.normalized() * 0.04
	_mat.render_priority = v.sprite.render_priority - 1
	_mat.set_shader_parameter("tex", tex)
	_mat.set_shader_parameter("t", _t)

	_mat.set_shader_parameter("strength", (0.8 + 0.2 * sin(_t * 1.3)) * Vfx.dim)
	_rim.texture = tex
	_rim.pixel_size = _light.pixel_size
	_rim.offset = _light.offset
	_rim.position = _light.position - RoVisual.lift.normalized() * 0.01
	_rim_mat.render_priority = _mat.render_priority - 1
	_rim_mat.set_shader_parameter("tex", tex)
	_rim_mat.set_shader_parameter("t", _t)
	_rim_mat.set_shader_parameter("strength", 0.85 + 0.15 * sin(_t * 1.3))
