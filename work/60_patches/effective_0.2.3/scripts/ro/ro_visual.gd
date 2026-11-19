class_name RoVisual
extends Node3D



signal finished


const PC_IDLE: = 0
const PC_WALK: = 1

const PC_READY: = 4
const PC_ATTACK: = 5
const PC_HURT: = 6
const PC_DEAD: = 8
const PC_CAST: = 12

const MOB_IDLE: = 0
const MOB_WALK: = 1
const MOB_ATTACK: = 2
const MOB_HURT: = 3
const MOB_DEAD: = 4

var ro: RoSprite
var sprite: = Sprite3D.new()


var ghost: Sprite3D

var shadow: Sprite3D

var glow: Sprite3D


var over: Sprite3D


var skin_light: Sprite3D
var skin_fx: Node3D
var base_action: = 0


var dir: = 0


var turns: = true
var speed_scale: = 1.0


var hold_idle: = false
var _frame: = 0
var _time: = 0.0


var _animated: = false
var _sub: = 0
var _loop: = true
var _done: = false
var _placeholder_time: = 0.0
var _flash: = 0.0

var tint: = Color.WHITE


var _shown: = 0
var _face: = Vector3.ZERO
var _face_dir: = -1
var _yaw_seen: = 0.0




static var lift: = Vector3.ZERO





static var view_yaw: = 0.0
const VIEW_GROUP: = "view_yaw"


func _ready() -> void :


	var p: = get_parent()
	if top_level or p == null or not p.is_in_group(VIEW_GROUP):
		follow_view()



func follow_view() -> void :
	add_to_group(VIEW_GROUP)
	rotation.y = view_yaw



static func world_lift() -> Vector3:
	return lift.rotated(Vector3.UP, view_yaw)




static func view_dir(d: int, exact: Vector3, exact_dir: int) -> int:
	if view_yaw == 0.0:
		return d
	var v: = exact if exact_dir == d else Vector3( - sin(d * PI / 4.0), 0.0, cos(d * PI / 4.0))
	v = v.rotated(Vector3.UP, - view_yaw)
	return posmod(roundi(atan2( - v.x, v.z) / (PI / 4.0)), 8)



func shown_dir() -> int:
	return view_dir(dir, _face, _face_dir) if turns else dir


func setup(p_ro: RoSprite, fallback_color: Color, fallback_px: int, shadow_size: = 1.0) -> void :
	ro = p_ro
	sprite.pixel_size = GameData.PIXEL_SIZE
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.shaded = false
	sprite.centered = false
	sprite.position = lift
	add_child(sprite)
	if ro == null:
		var tex: = RoAssets.placeholder(fallback_color, fallback_px)
		sprite.texture = tex
		sprite.offset = Vector2( - tex.get_width() / 2.0, 0)
	else:
		sprite.offset = Vector2( - ro.origin.x, ro.origin.y - ro.canvas_size.y)
		_apply_skin()
		_refresh()

	if shadow_size <= 0.0:
		return
	shadow = Sprite3D.new()
	shadow.texture = RoAssets.radial(Color(0, 0, 0, 0.45))
	shadow.pixel_size = shadow_size / 64.0
	shadow.axis = Vector3.AXIS_Y
	shadow.shaded = false
	shadow.position.y = 0.03
	shadow.render_priority = -1
	add_child(shadow)



func show_through(alpha: = 0.38, priority: = -2) -> void :
	ghost = Sprite3D.new()
	ghost.pixel_size = sprite.pixel_size
	ghost.billboard = sprite.billboard
	ghost.texture_filter = sprite.texture_filter
	ghost.shaded = false
	ghost.centered = false
	ghost.offset = sprite.offset
	ghost.no_depth_test = true
	ghost.modulate = Color(0.85, 0.92, 1.0, alpha)
	ghost.render_priority = priority
	ghost.position = lift
	ghost.texture = sprite.texture
	add_child(ghost)




func cover_aura(priority: int) -> void :
	if over != null:
		return
	over = Sprite3D.new()
	over.pixel_size = sprite.pixel_size
	over.billboard = sprite.billboard
	over.texture_filter = sprite.texture_filter
	over.shaded = false
	over.centered = false
	over.offset = sprite.offset
	over.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	over.transparent = true
	over.render_priority = priority
	over.position = lift + lift.normalized() * 0.04
	over.texture = sprite.texture
	add_child(over)





func set_glow(color: Variant) -> void :
	if color == null:
		if glow != null:
			glow.queue_free()
			glow = null
		return
	if glow == null:
		if _glow_shader == null:
			_glow_shader = Shader.new()
			_glow_shader.code = GLOW_SHADER
		glow = Sprite3D.new()
		glow.pixel_size = sprite.pixel_size * 1.12
		glow.centered = false
		glow.offset = sprite.offset
		var m: = ShaderMaterial.new()
		m.shader = _glow_shader
		m.set_shader_parameter("glow_color", color)
		m.set_shader_parameter("tex", sprite.texture)
		m.render_priority = sprite.render_priority - 1
		glow.material_override = m
		glow.position = lift
		glow.texture = sprite.texture
		add_child(glow)
		move_child(glow, 0)
		var tw: = glow.create_tween().set_loops()
		tw.tween_method( func(a: float): m.set_shader_parameter("strength", a), 1.0, 0.5, 0.6).set_trans(Tween.TRANS_SINE)
		tw.tween_method( func(a: float): m.set_shader_parameter("strength", a), 0.5, 1.0, 0.6).set_trans(Tween.TRANS_SINE)


static var _glow_shader: Shader
const GLOW_SHADER: = "\nshader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\nuniform sampler2D tex : filter_linear;\nuniform vec4 glow_color : source_color = vec4(1.0);\nuniform float strength = 1.0;\nvoid vertex() {\n\t// Facing the camera, as the sprite (its billboard).\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\n}\nvoid fragment() {\n\tvec2 px = 1.0 / vec2(textureSize(tex, 0));\n\tfloat a = 0.0;\n\tfor (int i = 0; i < 12; i++) {\n\t\tfloat ang = float(i) * 0.5236;\n\t\ta += texture(tex, UV + vec2(cos(ang), sin(ang)) * px * 2.5).a;\n\t\ta += texture(tex, UV + vec2(cos(ang), sin(ang)) * px * 1.2).a;\n\t}\n\tALBEDO = glow_color.rgb;\n\tALPHA = clamp(a / 12.0, 0.0, 1.0) * glow_color.a * strength;\n}\n"
























func action_length(base: int) -> float:
	if ro == null:
		return 0.3
	var a: = base * RoSprite.DIRS + shown_dir()
	return ro.frame_count(a) * ro.frame_delay(a)



func height() -> float:
	if ro != null:
		return ro.origin.y * GameData.PIXEL_SIZE
	return sprite.texture.get_height() * GameData.PIXEL_SIZE


func play(base: int, loop: = true, restart: = false) -> void :
	if base == base_action and not restart and not _done:
		return
	base_action = base
	_loop = loop
	_done = false
	_frame = 0
	_time = 0.0
	_refresh()
	if base == PC_CAST and skin_fx != null:
		skin_fx.call("cast")


func face(v: Vector3) -> void :
	if v.length_squared() < 0.0001:
		return


	var a: = atan2( - v.x, v.z)
	var d: = posmod(roundi(a / (PI / 4.0)), 8)
	_face = Vector3(v.x, 0.0, v.z)
	_face_dir = d
	dir = d
	if shown_dir() != _shown:
		_refresh()


func flash() -> void :
	_flash = 0.12



var _lift_seen: = Vector3.INF

func _process(delta: float) -> void :
	if _lift_seen != lift:
		if _lift_seen != Vector3.INF:
			var by: = lift - _lift_seen
			for s in [sprite, ghost, glow, over, skin_light]:
				if s != null:
					(s as Node3D).position += by
		_lift_seen = lift
	if _flash > 0.0:
		_flash -= delta
		sprite.modulate = Color(1, 0.45, 0.45) if _flash > 0.0 else tint
	if skin_light != null:
		var sm: = skin_light.material_override as ShaderMaterial
		if sm.render_priority != sprite.render_priority + 1:
			sm.render_priority = sprite.render_priority + 1
		skin_light.visible = sprite.visible
	if over != null:
		over.modulate = sprite.modulate
		over.visible = sprite.visible and visible

	if ro != null and (_yaw_seen != view_yaw or (turns and shown_dir() != _shown) or ( not turns and dir != _shown)):
		_yaw_seen = view_yaw
		_refresh()
	if ro == null:
		_animate_placeholder(delta)
		return
	if _animated and ro.anim_sub(base_action * RoSprite.DIRS + _shown) != _sub:
		_refresh()
	if _done:
		return
	if hold_idle and base_action == PC_IDLE:
		return
	_time += delta * speed_scale
	var action: = base_action * RoSprite.DIRS + _shown
	var delay: = ro.frame_delay(action)
	if _time >= delay:
		_time -= delay
		_frame += 1
		if _frame >= ro.frame_count(action):
			if _loop:
				_frame = 0
			else:
				_frame = ro.frame_count(action) - 1
				_done = true
				finished.emit()
		_refresh()


func _refresh() -> void :
	if ro == null:
		return
	_shown = shown_dir()
	var act: = base_action * RoSprite.DIRS + _shown
	_animated = ro.anim_steps(act) > 1
	_sub = ro.anim_sub(act) if _animated else 0
	sprite.texture = ro.get_frame(act, _frame, _sub)


	if over != null:
		over.texture = sprite.texture
		over.offset = sprite.offset
	if ghost != null:
		ghost.texture = sprite.texture
		ghost.offset = sprite.offset
	if glow != null:
		glow.texture = sprite.texture
		glow.offset = sprite.offset
		(glow.material_override as ShaderMaterial).set_shader_parameter("tex", sprite.texture)
	if skin_light != null:
		var mask_tex: Texture2D = ro.skin_mask.get_frame(act, _frame, _sub)
		skin_light.texture = mask_tex
		skin_light.offset = sprite.offset
		skin_light.visible = sprite.visible
		var sm: = skin_light.material_override as ShaderMaterial
		sm.set_shader_parameter("mask", mask_tex)
		if sm.render_priority != sprite.render_priority + 1:
			sm.render_priority = sprite.render_priority + 1




func _apply_skin() -> void :
	var on: bool = ro != null and ro.skin != "" and ro.skin_mask != null
	if not on:
		if skin_light != null:
			skin_light.queue_free()
			skin_light = null
		if skin_fx != null:
			skin_fx.queue_free()
			skin_fx = null
		return
	var info: Dictionary = RoAssets.Skins.info(ro.skin)
	if skin_light == null:
		if _skin_shader == null:
			_skin_shader = Shader.new()
			_skin_shader.code = SKIN_SHADER
		skin_light = Sprite3D.new()
		skin_light.pixel_size = sprite.pixel_size
		skin_light.centered = false
		var m: = ShaderMaterial.new()
		m.shader = _skin_shader
		skin_light.material_override = m

		skin_light.position = lift + (lift.normalized() * 0.02 if lift.length_squared() > 0.0001 else Vector3.ZERO)
		add_child(skin_light)
	var sm: = skin_light.material_override as ShaderMaterial
	sm.set_shader_parameter("cloth_color", info.get("color", Color(0.55, 0.45, 1.0)))
	sm.set_shader_parameter("gold_color", info.get("accent", Color(1.0, 0.85, 0.4)))
	if skin_fx == null:
		skin_fx = (load("res://scripts/ro/skin_fx.gd") as GDScript).new()
		add_child(skin_fx)
		skin_fx.call("setup", info.get("color", Color(0.55, 0.45, 1.0)), info.get("accent", Color(1.0, 0.85, 0.4)))


static var _skin_shader: Shader





const SKIN_SHADER: = "\nshader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never;\nuniform sampler2D mask : filter_nearest;\nuniform vec4 cloth_color : source_color = vec4(0.55, 0.45, 1.0, 1.0);\nuniform vec4 gold_color : source_color = vec4(1.0, 0.85, 0.4, 1.0);\nfloat hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }\nfloat vnoise(vec2 p) {\n\tvec2 i = floor(p);\n\tvec2 f = fract(p);\n\tf = f * f * (3.0 - 2.0 * f);\n\treturn mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);\n}\nfloat star(vec2 p, float cell, float chance, float seed) {\n\tvec2 c = floor(p / cell);\n\tfloat h = hash(c + seed);\n\tif (h > chance) return 0.0;\n\tvec2 sp = c * cell + floor(vec2(hash(c + seed + 1.3), hash(c + seed + 7.1)) * (cell - 2.0)) + 1.0;\n\tvec2 d = abs(p - sp);\n\tfloat tw = 0.5 + 0.5 * sin(TIME * (1.2 + 3.0 * hash(c + seed + 3.3)) + h * 40.0);\n\ttw = tw * tw * tw;\n\tfloat core = (d.x + d.y < 0.5) ? 1.0 : 0.0;\n\tfloat arm = ((d.x < 0.5 && d.y < 1.5) || (d.y < 0.5 && d.x < 1.5)) ? 1.0 : 0.0;\n\treturn core * (0.55 + 0.45 * tw) + arm * 0.9 * smoothstep(0.3, 1.0, tw);\n}\nvoid vertex() {\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);\n}\nvoid fragment() {\n\tivec2 size = textureSize(mask, 0);\n\tvec2 p = floor(UV * vec2(size));\n\tivec2 ip = ivec2(p);\n\tvec4 m = texelFetch(mask, ip, 0);\n\tfloat cloth = step(0.5, m.r) * step(0.5, m.a);\n\tfloat gold = step(0.5, m.g) * step(0.5, m.a);\n\tfloat cape = step(0.5, m.b) * step(0.5, m.a);\n\tif (cloth + gold + cape < 0.5) discard;\n\tvec3 col = vec3(0.0);\n\t// The cloth: a slow nebula and its stars.\n\tfloat n = vnoise(p * 0.07 + vec2(TIME * 0.12, TIME * 0.05)) * 0.6 + vnoise(p * 0.16 - vec2(TIME * 0.07, 0.0)) * 0.4;\n\tcol += cloth * cloth_color.rgb * smoothstep(0.35, 0.9, n) * 0.5;\n\tcol += cloth * star(p, 6.0, 0.6, 0.0) * vec3(1.0, 0.97, 1.0) * 1.2;\n\tcol += cloth * star(p, 10.0, 0.55, 17.0) * gold_color.rgb * 1.2;\n\t// The cape: deeper, fewer stars.\n\tcol += cape * cloth_color.rgb * smoothstep(0.62, 1.0, n) * 0.22;\n\tcol += cape * star(p + vec2(31.0, 7.0), 7.0, 0.45, 5.0) * vec3(0.7, 0.85, 1.0) * 1.1;\n\t// The gold: a warm glow and a shimmer sweeping across it.\n\tfloat band = fract((p.x * 0.7 + p.y) / 70.0 - TIME * 0.32);\n\tfloat sh = smoothstep(0.0, 0.05, band) * smoothstep(0.13, 0.05, band);\n\tcol += gold * (gold_color.rgb * 0.22 + vec3(1.0, 0.96, 0.75) * sh * 0.95);\n\t// The robe's edges: a gold hem below, a violet rim on the sides.\n\tfloat below = texelFetch(mask, ip + ivec2(0, 1), 0).a;\n\tfloat left = texelFetch(mask, ip + ivec2(-1, 0), 0).a;\n\tfloat right = texelFetch(mask, ip + ivec2(1, 0), 0).a;\n\tfloat hem = cloth * (1.0 - step(0.5, below));\n\tcol += hem * gold_color.rgb * (0.55 + 0.45 * sh + 0.25 * sin(TIME * 2.0 + p.x * 0.4));\n\tfloat rim = (cloth + cape) * (1.0 - step(0.5, min(left, right))) * (1.0 - hem);\n\tcol += rim * cloth_color.rgb * 0.35;\n\tALBEDO = col;\n\tALPHA = 1.0;\n}\n"
































































func _animate_placeholder(delta: float) -> void :
	_placeholder_time += delta * speed_scale
	var moving: = base_action == 1
	var s: = sin(_placeholder_time * (12.0 if moving else 4.0))
	var k: = 0.12 if moving else 0.04
	sprite.scale = Vector3(1.0 + s * k, 1.0 - s * k, 1.0)
	sprite.flip_h = dir >= 1 and dir <= 3
	if ghost != null:
		ghost.scale = sprite.scale
		ghost.flip_h = sprite.flip_h
	if not _loop and not _done:
		_done = true
		var tw: = create_tween()
		tw.tween_property(sprite, "scale", Vector3(1.4, 0.1, 1.0), 0.3)
		tw.finished.connect( func(): finished.emit())
