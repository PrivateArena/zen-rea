extends Node3D







const PINK: = Color(1.0, 0.66, 0.88)

const GLOW: = Color(1.0, 0.45, 0.78)
const FEATHERS: = 8
const SPARKLES: = 8

const TOP: = 2.2
const SPREAD: = 0.75
const FALL: = 0.32
const GLOW_R: = 0.95

var _glow: MeshInstance3D
var _glow_mat: StandardMaterial3D
var _feathers: Array = []
var _sparkles: Array = []
var _t: = 0.0

static var _feather_tex: Texture2D
static var _glow_tex: Texture2D



static func set_on(holder: Node3D, on: bool) -> void :
	if holder == null or not is_instance_valid(holder):
		return
	var had: Node = holder.get_node_or_null("AngelAura")
	if on and had == null:
		var a = load("res://scripts/ro/angel_aura.gd").new()
		a.name = "AngelAura"
		holder.add_child(a)
	elif not on and had != null:
		had.queue_free()


func _ready() -> void :
	_build_glow()
	for i in FEATHERS:
		_feathers.append(_make_feather(randf() * TOP))
	var spark: = RoAssets.effect_tex("lv99_bubble")
	if spark != null:
		for i in SPARKLES:
			_sparkles.append(_make_sparkle(spark, randf()))


func _process(dt: float) -> void :
	_t += dt

	var k: = 0.5 + 0.5 * sin(_t * 1.6)
	_glow_mat.albedo_color = Color(GLOW, 0.5 + 0.25 * k)
	_glow.scale = Vector3.ONE * (1.0 + 0.06 * k)
	for f in _feathers:
		var n: MeshInstance3D = f.node
		f.y -= FALL * dt
		f.a += f.spin * dt
		if f.y < 0.05:
			_reset_feather(f, TOP)

		n.position = Vector3(f.x + sin(_t * f.sway + f.ph) * 0.18, f.y, f.z)
		n.rotation.z = sin(_t * f.sway * 1.3 + f.ph) * 0.6
		(n.material_override as StandardMaterial3D).albedo_color.a = clampf(f.y / 0.5, 0.0, 1.0) * clampf((TOP - f.y) / 0.4, 0.0, 1.0) * 0.95
	for s in _sparkles:
		var n: MeshInstance3D = s.node
		s.k += dt / s.life
		if s.k >= 1.0:
			s.k = 0.0
			s.ang = randf() * TAU
		var r: float = 0.35 + 0.25 * float(s.k)
		n.position = Vector3(cos(s.ang) * r, 0.1 + s.k * 1.7, sin(s.ang) * r)
		(n.material_override as StandardMaterial3D).albedo_color = Color(PINK.lightened(0.3), sin(s.k * PI) * 0.9)


func _build_glow() -> void :
	_glow = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * GLOW_R * 2.0
	_glow.mesh = plane
	_glow_mat = StandardMaterial3D.new()
	_glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA


	_glow_mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	_glow_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_glow_mat.albedo_texture = _glow_texture()
	_glow_mat.no_depth_test = true
	_glow_mat.render_priority = -8
	_glow.material_override = _glow_mat
	_glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_glow.position = Vector3(0, 0.08, 0)
	add_child(_glow)

	var v = get_parent() if get_parent() is RoVisual else get_parent().get("visual")
	if v is RoVisual:
		(v as RoVisual).cover_aura(GameData.HERO_FX_PRIORITY + 1)


func _make_feather(y: float) -> Dictionary:
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.17, 0.38)
	mi.mesh = quad
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.albedo_texture = _feather_texture()
	m.render_priority = GameData.HERO_FX_PRIORITY
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var f: = {"node": mi}
	_reset_feather(f, y)
	return f


func _reset_feather(f: Dictionary, y: float) -> void :
	var a: = randf() * TAU
	var r: = 0.25 + randf() * SPREAD
	f.x = cos(a) * r
	f.z = sin(a) * r
	f.y = y
	f.a = 0.0
	f.spin = randf_range(-1.0, 1.0)
	f.sway = randf_range(1.2, 2.2)
	f.ph = randf() * TAU


func _make_sparkle(tex: Texture2D, k: float) -> Dictionary:
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE * 0.22
	mi.mesh = quad
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.albedo_texture = tex
	m.render_priority = GameData.HERO_FX_PRIORITY
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return {"node": mi, "k": k, "life": randf_range(1.6, 2.6), "ang": randf() * TAU}



static func _glow_texture() -> Texture2D:
	if _glow_tex == null:
		var n: = 64
		var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d: = Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length() / (n * 0.5)
				var ring: = exp( - pow((d - 0.72) / 0.16, 2.0))
				var core: = clampf(1.0 - d, 0.0, 1.0) * 0.35
				img.set_pixel(x, y, Color(1, 1, 1, clampf(ring + core, 0.0, 1.0) * (1.0 if d < 1.0 else 0.0)))
		_glow_tex = ImageTexture.create_from_image(img)
	return _glow_tex



static func _feather_texture() -> Texture2D:
	if _feather_tex == null:
		var w: = 16
		var h: = 36
		var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in h:
			var t: = float(y) / float(h - 1)

			var half: = sin(clampf(t * 1.15, 0.0, 1.0) * PI) * (w * 0.42) * (1.0 if t < 0.9 else (1.0 - t) * 10.0)
			var bend: = sin(t * PI) * 1.5
			for x in w:
				var dx: = float(x) + 0.5 - (w * 0.5 + bend)
				if absf(dx) <= half:
					var edge: = 1.0 - absf(dx) / maxf(half, 0.01)
					var col: = Color(1, 1, 1).lerp(PINK, clampf((1.0 - t) * 0.8, 0.0, 0.6))

					if edge < 0.28:
						col = PINK.darkened(0.15)
					img.set_pixel(x, h - 1 - y, Color(col, 1.0))
				elif absf(dx) < 0.7 and t < 0.25:
					img.set_pixel(x, h - 1 - y, Color(PINK.darkened(0.1), 0.9))
		_feather_tex = ImageTexture.create_from_image(img)
	return _feather_tex
