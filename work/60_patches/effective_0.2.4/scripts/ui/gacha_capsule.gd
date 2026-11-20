extends Control








const R: = 40.0


const BOX: = Vector2(R * 4.0, R * 4.0)
const INK: = Color(0.16, 0.14, 0.22)

var rarity: = "common":
	set(v):
		rarity = v
		queue_redraw()
var tint: = Color(0.6, 0.62, 0.68):
	set(v):
		tint = v
		queue_redraw()
var glow: = 0.0:
	set(v):
		glow = v
		_halo.modulate = Color(_dome_color(), clampf(maxf(glow, open) * 0.95, 0.0, 1.0))
		_halo.visible = glow > 0.0 or open > 0.0
		queue_redraw()
var open: = 0.0:
	set(v):
		open = v
		_halo.modulate = Color(_dome_color(), clampf(maxf(glow, open) * 0.95, 0.0, 1.0))
		_halo.visible = glow > 0.0 or open > 0.0
		queue_redraw()

var inside: Texture2D:
	set(v):
		inside = v
		queue_redraw()

var _halo: TextureRect
var _t: = 0.0
var _drawn_rot: = 0.0


func _init() -> void :
	custom_minimum_size = BOX
	size = BOX
	pivot_offset = BOX * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_halo = UiKit.glow(Color.WHITE, R * 5.0)
	_halo.position = BOX * 0.5 - Vector2(R, R) * 2.5
	_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_halo.visible = false
	add_child(_halo)

	_halo.show_behind_parent = true


func _process(delta: float) -> void :
	_t += delta

	if rotation != _drawn_rot:
		_drawn_rot = rotation
		queue_redraw()
	if rarity == "legendary" and visible:
		_halo.modulate = Color(_dome_color(), _halo.modulate.a)
		queue_redraw()



func _dome_color() -> Color:
	if rarity == "legendary":
		return Color.from_hsv(fmod(_t * 0.35, 1.0), 0.55, 1.0)
	return tint


func _draw() -> void :
	var c: = BOX * 0.5 + Vector2(0, R * 0.35)
	var dome: = _dome_color()


	draw_set_transform_matrix(Transform2D( - rotation, c) * Transform2D(0.0, Vector2(1.0, 0.26), 0.0, Vector2(0, R * 1.04)))
	draw_circle(Vector2.ZERO, R * 0.95, Color(0.1, 0.05, 0.15, 0.24))
	draw_circle(Vector2.ZERO, R * 0.7, Color(0.1, 0.05, 0.15, 0.12))
	draw_set_transform(Vector2.ZERO)

	if open > 0.0:
		var l: = Color(dome.lightened(0.6), 0.55 * open)
		for i in 4:
			draw_circle(c + Vector2(0, - R * 0.1), R * (0.5 + 0.35 * i) * (0.6 + 0.4 * open), Color(l, l.a / (i + 1.5)))

	_half(c, R, false, Color(1.0, 1.0, 1.0), Color(0.74, 0.76, 0.84))
	draw_arc(c, R * 0.86, 0.35, PI - 0.35, 20, Color(0.2, 0.15, 0.35, 0.08), R * 0.2, true)
	draw_arc(c, R * 0.62, deg_to_rad(110), deg_to_rad(150), 8, Color(1, 1, 1, 0.9), 3.0, true)

	if open > 0.05:
		draw_set_transform(c, 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, R * 0.94, Color(0.86, 0.88, 0.94))
		draw_circle(Vector2.ZERO, R * 0.8, Color(dome.lightened(0.7), 0.9))
		draw_set_transform(Vector2.ZERO)

	var hinge: = c + Vector2(R * 0.92, 0)
	var ang: = - open * 1.9
	draw_set_transform(hinge, ang)
	var d: = Vector2( - R * 0.92, - open * R * 0.15)
	_half(d, R, true, dome.lightened(0.35), dome.darkened(0.3), 0.9)
	if inside != null and open < 0.5:
		var s: = R * 1.05
		draw_texture_rect(inside, Rect2(d + Vector2( - s * 0.5, - s * 0.92), Vector2(s, s * 0.8)), false, Color(1, 1, 1, 0.5 * (1.0 - open * 2.0)))

	draw_arc(d, R * 0.8, deg_to_rad(200), deg_to_rad(340), 18, Color(dome.lightened(0.6), 0.45), R * 0.12, true)

	draw_set_transform(d + Vector2( - R * 0.3, - R * 0.52), -0.5, Vector2(1.0, 0.55))
	draw_circle(Vector2.ZERO, R * 0.34, Color(1, 1, 1, 0.28))
	draw_set_transform(hinge, ang)
	draw_arc(d + Vector2( - R * 0.05, R * 0.05), R * 0.74, deg_to_rad(200), deg_to_rad(262), 12, Color(1, 1, 1, 0.9), 4.0, true)
	draw_circle(d + Vector2( - R * 0.12, - R * 0.72), R * 0.07, Color(1, 1, 1, 0.95))
	draw_circle(d + Vector2(R * 0.52, - R * 0.52), R * 0.04, Color(1, 1, 1, 0.7))
	draw_arc(d, R, PI, TAU, 28, dome.darkened(0.6), 2.5, true)
	draw_line(d + Vector2( - R, 0), d + Vector2(R, 0), dome.darkened(0.45), 4.0, true)
	draw_set_transform(Vector2.ZERO)

	if open < 0.05:

		draw_line(c + Vector2( - R + 1, 2.5), c + Vector2(R - 1, 2.5), dome.darkened(0.2), 4.0, true)
		draw_line(c + Vector2( - R, 0), c + Vector2(R, 0), INK, 2.5, true)
		draw_line(c + Vector2( - R + 3, 5.0), c + Vector2(R - 3, 5.0), Color(1, 1, 1, 0.55), 1.2, true)
	draw_arc(c, R, 0.0, PI, 28, INK, 2.5, true)

	draw_rect(Rect2(hinge + Vector2(-3, -3), Vector2(6, 6)), INK)
	draw_rect(Rect2(hinge + Vector2(-1.5, -1.5), Vector2(3, 3)), dome.lightened(0.3))




func _half(at: Vector2, r: float, upper: bool, light: Color, dark: Color, alpha: = 1.0) -> void :
	var pts: = PackedVector2Array()
	var cols: = PackedColorArray()
	var n: = 24
	var from: = PI if upper else 0.0
	for i in n + 1:
		var a: = from + PI * i / n
		var p: = Vector2(cos(a), sin(a)) * r
		pts.append(at + p)

		var k: = clampf(0.5 + 0.5 * (p.normalized().dot(Vector2(0.6, 0.8))), 0.0, 1.0)
		cols.append(Color(light.lerp(dark, k), alpha))
	draw_polygon(pts, cols)
