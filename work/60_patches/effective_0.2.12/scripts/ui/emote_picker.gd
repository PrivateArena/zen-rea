extends Control




signal picked(idx: int)

const COLS: = 8
const CELL: = 40.0
const ROWS_SHOWN: = 4
const BUTTON: = Vector2(24, 22)


static var _icons: = {}
static var _order: Array = []

var _button: Button
var _panel: PanelContainer


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = BUTTON
	_button = Button.new()
	_button.custom_minimum_size = BUTTON
	_button.size = BUTTON
	_button.tooltip_text = tr("Emociones")
	_button.focus_mode = Control.FOCUS_NONE
	_button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_button.expand_icon = true
	_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0.55)
	box.set_corner_radius_all(3)
	box.content_margin_left = 3
	box.content_margin_right = 3
	box.content_margin_top = 3
	box.content_margin_bottom = 3
	var hover: = box.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.2, 0.25, 0.45, 0.75)
	for st in ["normal", "focus", "disabled"]:
		_button.add_theme_stylebox_override(st, box)
	for st in ["hover", "pressed"]:
		_button.add_theme_stylebox_override(st, hover)
	_button.pressed.connect(toggle)
	add_child(_button)

	_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_button.icon = smiley()


func is_open() -> bool:
	return _panel != null and is_instance_valid(_panel)


func toggle() -> void :
	if is_open():
		close()
	else:
		open()


func close() -> void :
	if is_open():
		_panel.queue_free()
	_panel = null


func open() -> void :
	close()
	if order().is_empty():
		return
	_panel = PanelContainer.new()
	var bg: = UiKit.panel_box(Color(0.975, 0.98, 1.0, 0.96), UiKit.SOFT_RIM, 8, 1)
	bg.content_margin_left = 6
	bg.content_margin_right = 6
	bg.content_margin_top = 6
	bg.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", bg)
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(COLS * CELL + 12.0, ROWS_SHOWN * CELL)
	_panel.add_child(scroll)
	var grid: = GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 0)
	scroll.add_child(grid)
	var cell_box: = StyleBoxFlat.new()
	cell_box.bg_color = Color(0, 0, 0, 0)
	var cell_hover: = StyleBoxFlat.new()
	cell_hover.bg_color = Color(0.55, 0.65, 0.95, 0.25)
	cell_hover.set_corner_radius_all(6)
	for idx in _order:
		var b: = Button.new()
		b.custom_minimum_size = Vector2(CELL, CELL)
		b.icon = _icons[idx]
		b.expand_icon = false
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		b.focus_mode = Control.FOCUS_NONE
		for st in ["normal", "focus", "disabled"]:
			b.add_theme_stylebox_override(st, cell_box)
		for st in ["hover", "pressed"]:
			b.add_theme_stylebox_override(st, cell_hover)
		b.pressed.connect( func():
			picked.emit(int(idx))
			close())
		grid.add_child(b)
	add_child(_panel)


	_panel.reset_size()
	_panel.position = Vector2(0.0, - _panel.size.y - 4.0)
	if global_position.y - _panel.size.y - 4.0 < 0.0:
		_panel.position.y = size.y + 4.0



func _input(event: InputEvent) -> void :
	if not is_open() or not (event is InputEventMouseButton and event.pressed):
		return
	var at: Vector2 = event.position
	if not _panel.get_global_rect().has_point(at) and not _button.get_global_rect().has_point(at):
		close()


static var _smiley: Texture2D


static func smiley() -> Texture2D:
	if _smiley != null:
		return _smiley
	var n: = 48
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c: = Vector2(n, n) * 0.5
	var r: = n * 0.5 - 1.5
	var ink: = Color(0.35, 0.22, 0.05)
	for y in n:
		for x in n:
			var p: = Vector2(x + 0.5, y + 0.5)
			var d: = p.distance_to(c)
			var col: = Color(0, 0, 0, 0)
			if d <= r:

				var k: = clampf((p.y - c.y) / r * 0.5 + 0.5, 0.0, 1.0)
				col = Color(1.0, 0.86, 0.3).lerp(Color(1.0, 0.7, 0.15), k)
				if d > r - 2.2:
					col = ink.lerp(col, 0.35)

			for e in [Vector2(-0.33, -0.18), Vector2(0.33, -0.18)]:
				var ec: Vector2 = c + e * r
				if Vector2((p.x - ec.x) / 0.85, (p.y - ec.y) / 1.25).length() <= r * 0.12:
					col = ink

			var m: = p - (c + Vector2(0, r * 0.02))
			var md: = m.length()
			if m.y > r * 0.12 and absf(md - r * 0.5) <= r * 0.08:
				col = ink
			if col.a > 0.0 and d > r - 0.8:
				col.a *= clampf(r + 0.5 - d, 0.0, 1.0) + 0.2
			img.set_pixel(x, y, col)
	_smiley = ImageTexture.create_from_image(img)
	return _smiley







const SHOWN: = [0, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 
	28, 29, 30, 31, 32, 33, 35, 36, 37, 38, 39, 40, 42, 43, 44, 45, 51, 52, 53, 54, 68, 69, 73, 74, 75, 76, 78, 79]


const ICON_MAX: = 34


static func order() -> Array:
	if not _order.is_empty():
		return _order
	var spr: = RoAssets.sprite(["fx_emotion"])
	if spr == null:
		return _order
	for a in SHOWN:
		if a >= spr.action_count():
			continue
		var n: = spr.frame_count(a)
		if n == 0:
			continue
		var best: Image = null
		var area: = 0
		for f in [mini(3, n - 1), n / 3, n / 2]:
			var img: = spr.compose_image(a, f)
			var u: = img.get_used_rect()
			if u.get_area() > area:
				area = u.get_area()
				best = img.get_region(u)
		if best == null or area < 40:
			continue
		var big: = maxi(best.get_width(), best.get_height())
		if big > ICON_MAX:
			var k: = float(ICON_MAX) / big
			best.resize(maxi(1, roundi(best.get_width() * k)), maxi(1, roundi(best.get_height() * k)), Image.INTERPOLATE_LANCZOS)
		_icons[a] = ImageTexture.create_from_image(best)
		_order.append(a)
	return _order
