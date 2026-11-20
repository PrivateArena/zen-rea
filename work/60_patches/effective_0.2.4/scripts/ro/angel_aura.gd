extends Node3D

















const PINK: = Color(1.0, 0.66, 0.88)


const GLOW: = Color(1.0, 0.45, 0.78)
const GOLD: = Color(1.0, 0.86, 0.55)
const FEATHERS: = 9
const SPARKLES: = 10

const TOP: = 2.4
const SPREAD: = 0.8
const FALL: = 0.3
const GLOW_R: = 1.35

const SEAL_R: = 1.45
const SEAL_SPIN: = 0.35

const WAVE_EVERY: = 3.2
const WAVE_LIFE: = 1.3
var _glow: MeshInstance3D
var _glow_mat: StandardMaterial3D
var _seal: MeshInstance3D
var _seal_mat: StandardMaterial3D
var _seal_glow_mat: StandardMaterial3D
var _seal_glow: MeshInstance3D
var _wave: MeshInstance3D
var _wave_mat: StandardMaterial3D
var _wave_t: = 1.0
var _wave_clock: = 0.8
var _feathers: Array = []
var _sparkles: Array = []
var _t: = 0.0

static var _feather_tex: Texture2D
static var _glow_tex: Texture2D
static var _seal_tex: Texture2D
static var _wave_tex: Texture2D



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
	_build_ground()
	for i in FEATHERS:
		_feathers.append(_make_feather(randf() * TOP))
	var spark: = RoAssets.effect_tex("lv99_bubble")
	if spark != null:
		for i in SPARKLES:
			_sparkles.append(_make_sparkle(spark, randf()))


func _process(dt: float) -> void :
	_t += dt

	var k: = 0.5 + 0.5 * sin(_t * 1.6)
	_glow_mat.albedo_color = Color(GLOW, 0.3 + 0.15 * k)
	_glow.scale = Vector3.ONE * (1.0 + 0.06 * k)
	_seal.rotation.y = _t * SEAL_SPIN
	_seal_glow.rotation.y = _seal.rotation.y
	_seal_mat.albedo_color = Color(GLOW.darkened(0.12), 0.8 + 0.2 * k)
	_seal_glow_mat.albedo_color = Color(PINK.lightened(0.5), 0.1 + 0.3 * k)

	_wave_clock -= dt
	if _wave_clock <= 0.0:
		_wave_clock = WAVE_EVERY
		_wave_t = 0.0
		for s in _sparkles:
			if randf() < 0.5:
				s.k = 0.0
				s.ang = randf() * TAU
	if _wave_t < 1.0:
		_wave_t = minf(1.0, _wave_t + dt / WAVE_LIFE)
		var e: = 1.0 - pow(1.0 - _wave_t, 2.0)
		_wave.visible = true
		_wave.scale = Vector3.ONE * lerpf(0.35, 1.9, e)
		_wave_mat.albedo_color = Color(GLOW, 0.75 * (1.0 - _wave_t))
	else:
		_wave.visible = false
	for f in _feathers:
		var n: MeshInstance3D = f.node
		f.y -= FALL * dt
		if f.y < 0.05:
			_reset_feather(f, TOP)

		n.position = Vector3(f.x + sin(_t * f.sway + f.ph) * 0.18, f.y, f.z)
		n.rotation.z = f.tilt + sin(_t * f.sway * 1.3 + f.ph) * 0.45
		(n.material_override as StandardMaterial3D).albedo_color.a = clampf(f.y / 0.5, 0.0, 1.0) * clampf((TOP - f.y) / 0.4, 0.0, 1.0) * 0.9
	for s in _sparkles:
		var n: MeshInstance3D = s.node
		s.k += dt / s.life
		if s.k >= 1.0:
			s.k = 0.0
			s.ang = randf() * TAU
		var r: float = 0.35 + 0.3 * float(s.k)
		n.position = Vector3(cos(s.ang) * r, 0.1 + s.k * 1.9, sin(s.ang) * r)
		(n.material_override as StandardMaterial3D).albedo_color = Color(PINK.lightened(0.3), sin(s.k * PI) * 0.9)


func _build_ground() -> void :
	_glow = _flat(_glow_texture(), GLOW_R * 2.0, BaseMaterial3D.BLEND_MODE_MIX, -8)
	_glow_mat = _glow.material_override
	_glow.position.y = 0.07


	_seal = _flat(_seal_texture(), SEAL_R * 2.0, BaseMaterial3D.BLEND_MODE_MIX, -7)
	_seal_mat = _seal.material_override
	_seal.position.y = 0.08
	_seal_glow = _flat(_seal_texture(), SEAL_R * 2.0, BaseMaterial3D.BLEND_MODE_ADD, -6)
	_seal_glow_mat = _seal_glow.material_override
	_seal_glow.position.y = 0.09
	_wave = _flat(_wave_texture(), SEAL_R * 2.0, BaseMaterial3D.BLEND_MODE_MIX, -5)
	_wave_mat = _wave.material_override
	_wave.position.y = 0.1
	_wave.visible = false

	var v = get_parent() if get_parent() is RoVisual else get_parent().get("visual")
	if v is RoVisual:
		(v as RoVisual).cover_aura(GameData.HERO_FX_PRIORITY + 1)



func _flat(tex: Texture2D, size: float, blend: int, prio: int) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * size
	mi.mesh = plane
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = blend
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_texture = tex
	m.no_depth_test = true
	m.render_priority = prio
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	return mi


func _make_feather(y: float) -> Dictionary:
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.22, 0.5)
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
	f.sway = randf_range(1.2, 2.2)
	f.tilt = randf_range(-0.5, 0.5)
	f.ph = randf() * TAU


func _make_sparkle(tex: Texture2D, k: float) -> Dictionary:
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE * 0.24
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





static func _seal_texture() -> Texture2D:
	if _seal_tex == null:
		var n: = 160
		var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
		var points: Array[Vector2] = []
		for i in 8:
			points.append(Vector2.from_angle(TAU * i / 8.0) * 0.62)
		for y in n:
			for x in n:
				var p: = Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5) / (n * 0.5)
				var d: = p.length()
				if d > 1.0:
					continue
				var a: = 0.0

				a = maxf(a, 1.0 - absf(d - 0.94) / 0.034)
				a = maxf(a, 1.0 - absf(d - 0.83) / 0.02)
				var bead_ang: = fposmod(p.angle(), TAU / 36.0) - TAU / 72.0
				var bead: = Vector2(d - 0.89, bead_ang * 0.89)
				a = maxf(a, 1.0 - bead.length() / 0.03)

				a = maxf(a, 1.0 - absf(d - 0.4) / 0.024)
				a = maxf(a, (1.0 - absf(d - 0.3) / 0.014) * 0.7)

				for i in (8 if d > 0.28 and d < 0.66 else 0):
					var s0: Vector2 = points[i]
					var s1: Vector2 = points[(i + 3) % 8]
					var seg: = s1 - s0
					var t: = clampf((p - s0).dot(seg) / seg.length_squared(), 0.0, 1.0)
					var dl: = (p - (s0 + seg * t)).length()
					if dl < 0.02:
						a = maxf(a, (1.0 - dl / 0.02) * 0.85)

				if d > 0.5 and d < 0.74:
					for c in points:
						var dc: = (p - c).length()
						a = maxf(a, clampf((0.045 - dc) / 0.012, 0.0, 1.0))
						a = maxf(a, 1.0 - absf(dc - 0.075) / 0.012)
				img.set_pixel(x, y, Color(1, 1, 1, clampf(a, 0.0, 1.0)))
		_seal_tex = ImageTexture.create_from_image(img)
	return _seal_tex







static func _feather_texture() -> Texture2D:
	if _feather_tex == null:
		var w: = 32
		var h: = 72
		var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
		var edge_col: = Color(0.66, 0.54, 0.7)
		for y in h:

			var t: = 1.0 - (float(y) + 0.5) / float(h)

			var cx: = w * 0.5 + sin(t * PI * 0.9) * 3.0 - 1.5


			var body: = 0.0
			if t > 0.14:
				var u: = (t - 0.14) / 0.86
				body = sin(minf(u * 1.25, 1.0) * PI * 0.5) * sqrt(maxf(0.0, 1.0 - pow(maxf(u - 0.55, 0.0) / 0.45, 2.0)))
			var left: = body * 12.5
			var right: = body * 9.0
			for x in w:
				var dx: = float(x) + 0.5 - cx
				var a: = 0.0
				var col: = Color(1, 1, 1)
				var span: = left if dx < 0.0 else right
				if span > 0.5 and absf(dx) <= span:
					var k: = absf(dx) / span

					var barb: = 0.82 + 0.18 * cos((t * 46.0 - k * 2.4) * PI)
					a = barb

					var split: = t * 46.0 - k * 2.4
					if (dx < 0.0 and absf(split - 21.0) < 0.55 and k > 0.35) or (dx > 0.0 and absf(split - 30.0) < 0.5 and k > 0.45):
						a = 0.0

					if k > 0.72:
						col = Color(1, 1, 1).lerp(edge_col, (k - 0.72) / 0.28)
						a *= 1.0 - maxf(0.0, (k - 0.9) / 0.1) * 0.6
					col = col.lerp(PINK, clampf((0.4 - t) * 0.8, 0.0, 0.25))
				elif t < 0.2 and absf(dx) < 6.0 * (1.0 - t / 0.2) + 1.5:

					var fluff: = 0.5 + 0.5 * sin(dx * 2.3 + t * 40.0)
					a = fluff * 0.75 * (1.0 - absf(dx) / 7.5)
					col = Color(1, 1, 1).lerp(PINK, 0.35)

				if absf(dx) < 0.7 and t < 0.93:
					a = maxf(a, 0.95)
					col = Color(0.93, 0.86, 0.9) if t > 0.14 else PINK.darkened(0.05)
				if a > 0.0:
					img.set_pixel(x, y, Color(col, clampf(a, 0.0, 1.0)))
		_feather_tex = ImageTexture.create_from_image(img)
	return _feather_tex



static func _wave_texture() -> Texture2D:
	if _wave_tex == null:
		var n: = 96
		var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d: = Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length() / (n * 0.5)
				img.set_pixel(x, y, Color(1, 1, 1, exp( - pow((d - 0.9) / 0.05, 2.0)) * (1.0 if d < 1.0 else 0.0)))
		_wave_tex = ImageTexture.create_from_image(img)
	return _wave_tex
