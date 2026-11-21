extends Node3D





const ORBITERS: = 5
const DUST_EVERY: = 0.32
const DUST_MAX: = 14

var color: = Color(0.55, 0.45, 1.0)
var accent: = Color(1.0, 0.85, 0.4)
var _stars: Array[Sprite3D] = []
var _t: = 0.0
var _last: = Vector3.INF
var _walked: = 0.0
var _dust: = 0

const CAST_GAP_MS: = 1400
var _cast_at: = -100000

static var _star_tex: Texture2D
static var _sigil_tex: Texture2D


func setup(p_color: Color, p_accent: Color) -> void :
	color = p_color
	accent = p_accent
	for i in ORBITERS:
		var s: = _sprite(_star(), 0.018)
		s.modulate = accent if i % 2 == 0 else color.lightened(0.45)
		add_child(s)
		_stars.append(s)


func _process(delta: float) -> void :
	_t += delta
	var parent: = get_parent() as Node3D
	var hidden: bool = parent != null and not parent.visible
	for i in _stars.size():
		var s: = _stars[i]
		var k: = float(i) / _stars.size()
		var a: = _t * (0.9 + 0.25 * k) + k * TAU
		var h: = 0.55 + 0.95 * fmod(k * 1.7 + 0.15 * sin(_t * 0.8 + i), 1.0)
		s.position = Vector3(cos(a) * 0.62, h, sin(a) * 0.62 * 0.55)
		var tw: = 0.5 + 0.5 * sin(_t * (2.2 + i * 0.7) + i * 1.9)
		s.scale = Vector3.ONE * (0.55 + 0.6 * tw)
		s.modulate.a = 0.35 + 0.65 * tw
		s.visible = not hidden

	var at: = global_position
	if _last != Vector3.INF:
		_walked += Vector2(at.x - _last.x, at.z - _last.z).length()
	_last = at
	if _walked >= DUST_EVERY and not hidden:
		_walked = 0.0
		_puff(at + Vector3(randf_range(-0.25, 0.25), 0.15 + randf() * 0.3, randf_range(-0.2, 0.2)), 0.012, 0.8)



func cast() -> void :
	if get_parent() is Node3D and not (get_parent() as Node3D).visible:
		return
	var now: = Time.get_ticks_msec()
	if now - _cast_at < CAST_GAP_MS:
		return
	_cast_at = now
	var sig: = _sprite(_sigil(), 0.0105, false)
	sig.axis = Vector3.AXIS_Y
	sig.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	(sig.material_override as StandardMaterial3D).billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	sig.position = Vector3(0, 0.04, 0)
	sig.modulate = Color(color.lerp(accent, 0.35).lightened(0.35), 0.0)
	sig.scale = Vector3.ONE * 0.55
	add_child(sig)
	var tw: = sig.create_tween().set_parallel()
	tw.tween_property(sig, "scale", Vector3.ONE * 1.05, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(sig, "modulate:a", 1.0, 0.15)
	tw.tween_property(sig, "rotation:y", 0.9, 1.3)
	tw.chain().tween_property(sig, "modulate:a", 0.0, 0.7)
	tw.chain().tween_callback(sig.queue_free)
	for i in 8:
		var a: = TAU * i / 8.0
		_puff(global_position + Vector3(cos(a) * 0.7, 0.1, sin(a) * 0.7 * 0.6), 0.016, 1.1, 1.3)


func _puff(world_at: Vector3, px: float, life: float, rise: = 0.45) -> void :
	if _dust >= DUST_MAX:
		return
	_dust += 1
	var s: = _sprite(_star(), px)
	s.modulate = accent if randf() < 0.45 else color.lightened(0.5)
	add_child(s)
	s.global_position = world_at
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "position:y", s.position.y + rise, life).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "modulate:a", 0.0, life).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "scale", Vector3.ONE * 0.3, life)
	tw.chain().tween_callback( func():
		_dust -= 1
		s.queue_free())


func _sprite(tex: Texture2D, px: float, bill: = true) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = tex
	s.pixel_size = px
	s.shaded = false
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = tex
	m.vertex_color_use_as_albedo = true
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED if bill else BaseMaterial3D.BILLBOARD_DISABLED
	m.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	m.render_priority = GameData.HERO_PRIORITY + 2
	s.material_override = m
	return s



static func _star() -> Texture2D:
	if _star_tex != null:
		return _star_tex
	var n: = 15
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c: = (n - 1) / 2.0
	for y in n:
		for x in n:
			var dx: = absf(x - c)
			var dy: = absf(y - c)
			var glow: = maxf(0.0, 1.0 - Vector2(dx, dy).length() / (c + 0.5))
			var ray: = 0.0
			if dx < 0.6:
				ray = maxf(ray, 1.0 - dy / (c + 0.5))
			if dy < 0.6:
				ray = maxf(ray, 1.0 - dx / (c + 0.5))
			var a: = clampf(glow * glow * 0.6 + ray * ray, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a))
	_star_tex = ImageTexture.create_from_image(img)
	return _star_tex




static func _sigil() -> Texture2D:
	if _sigil_tex != null:
		return _sigil_tex
	var n: = 192
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c: = Vector2(n, n) * 0.5
	var put: = func(p: Vector2, a: float):
		var x: = int(p.x)
		var y: = int(p.y)
		if x >= 0 and y >= 0 and x < n and y < n:
			var old: = img.get_pixel(x, y)
			img.set_pixel(x, y, Color(1, 1, 1, maxf(old.a, a)))
	for i in 1440:
		var ang: = TAU * i / 1440.0
		var dir: = Vector2(cos(ang), sin(ang))
		for r in [93.0, 92.0, 91.0]:
			put.call(c + dir * r, 1.0)
		put.call(c + dir * 89.0, 0.5)
		for r in [75.0, 74.0]:
			put.call(c + dir * r, 0.9)
		if i % 40 < 14:
			for r in range(77, 88):
				put.call(c + dir * float(r), 0.35 if i % 40 > 3 else 0.8)
	var pts: Array[Vector2] = []
	for i in 8:
		var ang: = TAU * i / 8.0 + 0.2
		pts.append(c + Vector2(cos(ang), sin(ang)) * (60.0 if i % 2 == 0 else 38.0))
	for i in 8:
		for j in [1, 3]:
			var a: Vector2 = pts[i]
			var b: Vector2 = pts[(i + j) % 8]
			var steps: = int(a.distance_to(b))
			for s in steps:
				var q: Vector2 = a.lerp(b, float(s) / steps)
				put.call(q, 0.8)
				put.call(q + Vector2(0.7, 0.7), 0.45)
	for p in pts:
		for y in range(-4, 5):
			for x in range(-4, 5):
				var d: = Vector2(x, y).length()
				if d <= 4.0:
					put.call(p + Vector2(x, y), 1.0 - d / 5.0)
	_sigil_tex = ImageTexture.create_from_image(img)
	return _sigil_tex
