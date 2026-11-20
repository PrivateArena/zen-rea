extends Control




signal stopped
signal ticked

const RADIUS: = 196.0
const RIM: = 18.0
const GOLD: = Color(0.98, 0.8, 0.36)
const GOLD_DARK: = Color(0.5, 0.31, 0.1)

var entries: Array = []
var turn: = 0.0
var spinning: = false
var _shown: = -1
var _clock: = 0.0
var _won: = -1
var _won_t: = 0.0
var _total: = 0.0
var _kick: = 0.0
var _icons: = {}


func setup(list: Array) -> void :
	entries = list
	_total = 0.0
	for e in entries:
		_total += float(e.w)
		_icons[str(e.id)] = UiKit.skill_icon(str(e.icon))
	custom_minimum_size = Vector2(RADIUS + RIM + 6.0, RADIUS + RIM + 6.0) * 2.0 + Vector2(0, 22)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR



func _sector(index: int) -> Vector2:
	var a: = 0.0
	for i in index:
		a += TAU * float(entries[i].w) / _total
	var w: = TAU * float(entries[index].w) / _total
	return Vector2(a + w * 0.5, w * 0.5)


func spin(index: int) -> void :
	spinning = true
	_won = -1
	var s: = _sector(index)

	var land: = s.x + randf_range(-0.7, 0.7) * s.y
	var to: = ceilf(turn / TAU) * TAU + TAU * 7.0 - land
	var tw: = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "turn", to, 4.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tw.tween_callback( func():
		spinning = false
		_won = index
		_won_t = 0.0
		stopped.emit())


func _at_pointer() -> int:
	var a: = fposmod( - turn, TAU)
	var run: = 0.0
	for i in entries.size():
		run += TAU * float(entries[i].w) / _total
		if a < run:
			return i
	return 0


func _process(delta: float) -> void :
	_clock += delta
	_won_t += delta
	_kick = move_toward(_kick, 0.0, delta * 4.0)
	if spinning:
		var now: = _at_pointer()
		if now != _shown:
			_shown = now
			_kick = 1.0
			ticked.emit()
	queue_redraw()


func _fan(c: Vector2, from: float, w: float, r0: float, r1: float, col: Color) -> void :
	var steps: = maxi(4, int(w * 18.0))
	var pts: = PackedVector2Array()
	for k in steps + 1:
		var t: = from + w * k / steps
		pts.append(c + Vector2(cos(t), sin(t)) * r1)
	if r0 <= 0.0:
		pts.append(c)
	else:
		for k in range(steps, -1, -1):
			var t: = from + w * k / steps
			pts.append(c + Vector2(cos(t), sin(t)) * r0)
	draw_colored_polygon(pts, col)


func _draw() -> void :
	var c: = Vector2(size.x * 0.5, RADIUS + RIM + 24.0)

	for i in 4:
		var glow: = (0.1 + (0.1 if spinning else 0.0)) * (4 - i) / 4.0
		draw_circle(c, RADIUS + RIM + 12.0 + i * 9.0, Color(1.0, 0.75, 0.3, glow))

	draw_circle(c + Vector2(0, 7), RADIUS + RIM + 4.0, Color(0, 0, 0, 0.45))
	draw_circle(c, RADIUS + RIM + 3.0, GOLD_DARK)
	draw_circle(c, RADIUS + RIM, GOLD)
	draw_circle(c, RADIUS + RIM - 3.0, Color(0.72, 0.5, 0.18))
	draw_circle(c, RADIUS + 3.0, GOLD_DARK)
	var a: = turn - PI * 0.5
	for i in entries.size():
		var e: Dictionary = entries[i]
		var w: = TAU * float(e.w) / _total
		var col: Color = e.color
		var dim: = _won >= 0 and i != _won
		if dim:
			col = col.darkened(0.6)
		elif i == _won:
			col = col.lightened(0.12 + 0.14 * sin(_clock * 11.0))
		elif str(e.kind) == "super":
			col = col.lightened(0.1 * sin(_clock * 5.0))
		_fan(c, a, w, 0.0, RADIUS, col)

		_fan(c, a, w, RADIUS * 0.74, RADIUS, Color(1, 1, 1, 0.1))
		_fan(c, a, w, RADIUS * 0.94, RADIUS, Color(1, 1, 1, 0.14))
		_fan(c, a, w, 0.0, RADIUS * 0.42, Color(0, 0, 0, 0.2))
		_label(c, a + w * 0.5, w, e, dim)
		a += w
	a = turn - PI * 0.5
	for e in entries:
		draw_line(c + Vector2(cos(a), sin(a)) * 30.0, c + Vector2(cos(a), sin(a)) * RADIUS, Color(GOLD, 0.8), 2.0, true)
		a += TAU * float(e.w) / _total
	_bulbs(c)
	_hub(c)
	_pointer(c)
	if _won >= 0 and _won_t < 0.5:
		var f: = _won_t / 0.5
		draw_arc(c, RADIUS * (1.0 + f * 0.25), 0.0, TAU, 64, Color(entries[_won].color, 1.0 - f), 8.0 * (1.0 - f) + 1.0, true)




func _label(c: Vector2, mid: float, w: float, e: Dictionary, dim: bool) -> void :
	var flip: = cos(mid) < 0.0
	draw_set_transform(c, mid + (PI if flip else 0.0), Vector2.ONE)
	var font: Font = UiKit.FONT_TITLE
	var size_px: = 15 if w > 0.4 else 12
	var text: = tr(str(e.short))
	var tint: = Color(1, 1, 1, 0.45) if dim else Color.WHITE
	var width: = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	var icon_x: = RADIUS - 36.0
	var text_x: = icon_x - 8.0 - width
	if flip:
		icon_x = - RADIUS + 10.0
		text_x = icon_x + 34.0
	var y: = size_px * 0.36
	draw_string_outline(font, Vector2(text_x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, 4, Color(0, 0, 0, 0.7 if not dim else 0.3))
	draw_string(font, Vector2(text_x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, tint)
	var tex: Texture2D = _icons.get(str(e.id))
	if tex != null:
		draw_texture_rect(tex, Rect2(icon_x, -13.0, 26.0, 26.0), false, tint)
	draw_set_transform(Vector2.ZERO)




func _bulbs(c: Vector2) -> void :
	var lamps: = 36
	var speed: = 34.0 if spinning else 3.0
	for i in lamps:
		var t: = TAU * i / lamps
		var at: = c + Vector2(cos(t), sin(t)) * (RADIUS + RIM * 0.55)
		var on: = int(_clock * speed + i) % 3 == 0
		if _won >= 0 and _won_t < 1.6:
			on = int(_clock * 9.0) % 2 == 0
		if on:
			draw_circle(at, 6.5, Color(1.0, 0.9, 0.5, 0.3))
			draw_circle(at, 4.0, Color(1.0, 0.98, 0.8))
		else:
			draw_circle(at, 3.5, Color(0.42, 0.26, 0.1))


func _hub(c: Vector2) -> void :
	draw_circle(c + Vector2(0, 3), 40.0, Color(0, 0, 0, 0.4))
	draw_circle(c, 39.0, GOLD_DARK)
	draw_circle(c, 36.0, GOLD)
	draw_circle(c, 29.0, Color(0.3, 0.15, 0.42))

	var pts: = PackedVector2Array()
	for i in 10:
		var t: = turn + TAU * i / 10.0 - PI * 0.5
		pts.append(c + Vector2(cos(t), sin(t)) * (21.0 if i % 2 == 0 else 9.0))
	draw_colored_polygon(pts, GOLD)



func _pointer(c: Vector2) -> void :
	var base: = c + Vector2(0, - RADIUS - RIM - 8.0)
	var lean: = -0.42 * _kick
	draw_set_transform(base, lean, Vector2.ONE)
	var body: = PackedVector2Array([Vector2(0, 44), Vector2(-19, -2), Vector2(0, -16), Vector2(19, -2)])
	draw_colored_polygon(PackedVector2Array([Vector2(3, 47), Vector2(-16, 1), Vector2(3, -13), Vector2(22, 1)]), Color(0, 0, 0, 0.4))
	draw_colored_polygon(body, GOLD_DARK)
	draw_colored_polygon(PackedVector2Array([Vector2(0, 37), Vector2(-14, -1), Vector2(0, -11), Vector2(14, -1)]), Color(0.9, 0.15, 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 37), Vector2(-14, -1), Vector2(0, -11)]), Color(1.0, 0.42, 0.45))
	draw_circle(Vector2(0, -2), 5.0, Color(1.0, 0.95, 0.75))
	draw_set_transform(Vector2.ZERO)
