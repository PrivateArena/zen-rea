extends HBoxContainer















const Potential = preload("res://scripts/core/potential.gd")

var menus: Menus
var world: World

const STAGE: = Vector2(330, 392)

const PIECE: = Vector2(205, 196)
const PIECE_SIZE: = 64.0
const SKY: = Color(0.07, 0.06, 0.17)
const INK: = Color(0.3, 0.22, 0.55)
const GOLD: = Color(1.0, 0.8, 0.3)
const TIER_SOUND: = ["drop_blue", "drop_purple", "drop_yellow"]

var _uid: = ""
var _locks: Array = []

var _before: Array = []
var _busy: = false
var _skip: = false

var _left: VBoxContainer
var _right: VBoxContainer
var _stage: Control
var _ring: TextureRect
var _rays: TextureRect
var _halo: TextureRect
var _socket: PanelContainer
var _piece: TextureRect
var _tier_l: Label
var _crumbs_l: Label
var _bubble: Label
var _flash: ColorRect
var _banner: Label
var _astrid: TextureRect
var _spr: RoSprite
var _frame: = 0
var _frame_t: = 0.0
var _shoot_t: = 1.5
var _rows: Array = []
var _roll_b: Button


var _tears_box: HBoxContainer
var _tears_l: Label
var _tear_ask: = -1


var _roll_ask: = false


var _hold_tier: = -1
var _head: HBoxContainer


func _ready() -> void :
	add_theme_constant_override("separation", 14)
	_left = VBoxContainer.new()
	_left.add_theme_constant_override("separation", 4)
	_left.custom_minimum_size.x = 262
	add_child(_left)
	_build_stage()
	_right = VBoxContainer.new()
	_right.add_theme_constant_override("separation", 6)
	_right.custom_minimum_size = Vector2(330, STAGE.y)
	add_child(_right)

	var store: = Save.storage().filter( func(s): return not Equipment.is_soul(s))
	if not store.is_empty() and (Save.storage_item(_uid).is_empty() or Equipment.is_soul(Save.storage_item(_uid))):
		_uid = str(store[0].uid)
	_refresh(true)
	_say(_greeting())


func _process(delta: float) -> void :

	if _spr != null and _astrid != null:
		_frame_t += delta
		if _frame_t >= maxf(0.08, _spr.frame_delay(0)):
			_frame_t = 0.0
			_frame = (_frame + 1) % maxi(1, _spr.frame_count(0))
			_astrid.texture = _hd(_frame)

	_shoot_t -= delta
	if _shoot_t <= 0.0 and _stage != null:
		_shoot_t = randf_range(2.5, 5.0)
		_shooting_star()
	if _ring != null:
		_ring.rotation += delta * (1.8 if _busy else 0.25)





func _input(event: InputEvent) -> void :
	if not _busy or _skip or not is_visible_in_tree():
		return

	var mouse: bool = event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]
	var touch: bool = event is InputEventScreenTouch and event.pressed
	var key: bool = event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]
	if mouse or touch or key:
		_skip = true
		get_viewport().set_input_as_handled()




func _build_stage() -> void :
	_stage = Control.new()
	_stage.custom_minimum_size = STAGE
	_stage.clip_contents = true
	_stage.mouse_filter = Control.MOUSE_FILTER_PASS
	_stage.gui_input.connect( func(ev: InputEvent):
		if _busy and ev is InputEventMouseButton and ev.pressed:
			_skip = true)
	add_child(_stage)
	var sky: = Panel.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = SKY
	sb.border_color = Color(0.55, 0.48, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(14)
	sky.add_theme_stylebox_override("panel", sb)
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(sky)

	var dusk: = UiKit.glow(Color(0.45, 0.3, 0.85, 0.5), 420)
	dusk.position = Vector2(STAGE.x * 0.5 - 210, STAGE.y - 170)
	dusk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(dusk)
	for i in 34:
		var st: = ColorRect.new()
		var sz: = randf_range(1.0, 2.6)
		st.size = Vector2(sz, sz)
		st.position = Vector2(randf_range(8, STAGE.x - 8), randf_range(8, STAGE.y * 0.62))
		st.color = Color(1, 1, 1).lerp(Color(0.8, 0.85, 1.0), randf())
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage.add_child(st)
		var tw: = st.create_tween().set_loops()
		tw.tween_interval(randf_range(0.0, 2.0))
		tw.tween_property(st, "modulate:a", 0.15, randf_range(0.6, 1.4)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(st, "modulate:a", 1.0, randf_range(0.6, 1.4)).set_trans(Tween.TRANS_SINE)

	_rays = UiKit.rays(Color(1, 1, 1, 1), 300)
	_rays.position = PIECE - Vector2(150, 150)
	_rays.pivot_offset = Vector2(150, 150)
	_rays.modulate.a = 0.0
	_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_rays)
	_halo = UiKit.glow(Color(0.7, 0.6, 1.0, 0.7), 190)
	_halo.position = PIECE - Vector2(95, 95)
	_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_halo)
	var pulse: = _halo.create_tween().set_loops()
	pulse.tween_property(_halo, "modulate:a", 0.55, 1.3).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_halo, "modulate:a", 1.0, 1.3).set_trans(Tween.TRANS_SINE)
	_ring = TextureRect.new()
	_ring.texture = _star_ring(132)
	_ring.size = Vector2(132, 132)
	_ring.position = PIECE - Vector2(66, 66)
	_ring.pivot_offset = Vector2(66, 66)
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_ring)
	_socket = PanelContainer.new()
	_socket.custom_minimum_size = Vector2(PIECE_SIZE + 16, PIECE_SIZE + 16)
	_socket.position = PIECE - _socket.custom_minimum_size * 0.5
	_socket.pivot_offset = _socket.custom_minimum_size * 0.5
	_socket.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_socket)
	_piece = TextureRect.new()
	_piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_piece.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_piece.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_piece.custom_minimum_size = Vector2(PIECE_SIZE, PIECE_SIZE)
	_piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_socket.add_child(_piece)
	_tier_l = menus._ro_text("", 13, Color.WHITE, true)
	_tier_l.add_theme_constant_override("outline_size", 5)
	_tier_l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.15))
	_tier_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tier_l.size = Vector2(200, 20)
	_tier_l.position = Vector2(PIECE.x - 100, PIECE.y + 70)
	_tier_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_tier_l)

	_spr = RoAssets.sprite(["npc_star_smith"])
	_astrid = TextureRect.new()
	_astrid.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_astrid.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_astrid.stretch_mode = TextureRect.STRETCH_SCALE
	_astrid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _spr != null:
		var c: = Vector2(_spr.canvas_size) * 2.0
		_astrid.size = c
		_astrid.position = Vector2(4, STAGE.y - c.y - 26)
		_astrid.texture = _hd(0)
	_stage.add_child(_astrid)

	var bub: = PanelContainer.new()
	var bb: = StyleBoxFlat.new()
	bb.bg_color = Color(1, 1, 1, 0.94)
	bb.border_color = Color(0.62, 0.55, 0.95)
	bb.set_border_width_all(1)
	bb.set_corner_radius_all(9)
	bb.set_content_margin_all(7)
	bub.add_theme_stylebox_override("panel", bb)
	bub.position = Vector2(10, 10)
	bub.custom_minimum_size = Vector2(STAGE.x - 20, 0)
	bub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(bub)
	var bcol: = VBoxContainer.new()
	bcol.add_theme_constant_override("separation", 0)
	bub.add_child(bcol)
	bcol.add_child(menus._ro_text(tr("Altair"), 11, INK, true))
	_bubble = menus._ro_text("", 11, Color(0.22, 0.2, 0.3))
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.custom_minimum_size.x = STAGE.x - 40
	bcol.add_child(_bubble)

	var have: = HBoxContainer.new()
	have.add_theme_constant_override("separation", 4)
	have.position = Vector2(STAGE.x - 120, STAGE.y - 32)
	have.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(have)
	have.add_child(UiKit.icon_rect(menus._item_icon("star_crumb"), 24))
	_crumbs_l = menus._ro_text("", 14, Color(1.0, 0.92, 0.7), true)
	_crumbs_l.add_theme_constant_override("outline_size", 4)
	_crumbs_l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.15))
	have.add_child(_crumbs_l)

	_tears_box = HBoxContainer.new()
	_tears_box.add_theme_constant_override("separation", 4)
	_tears_box.position = Vector2(STAGE.x - 120, STAGE.y - 60)
	_tears_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_tears_box)
	_tears_box.add_child(UiKit.icon_rect(menus._item_icon("hel_tear"), 24))
	_tears_l = menus._ro_text("", 14, Color(0.8, 0.85, 1.0), true)
	_tears_l.add_theme_constant_override("outline_size", 4)
	_tears_l.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.15))
	_tears_box.add_child(_tears_l)


	_how_b = UiKit.button(tr("¿Cómo funciona?"))
	_how_b.add_theme_font_size_override("font_size", 11)
	_how_b.custom_minimum_size = Vector2(0, 24)

	_how_b.position = Vector2(14, STAGE.y - 44)
	_how_b.pressed.connect(_explain)
	_stage.add_child(_how_b)
	_banner = menus._ro_text("", 26, GOLD, true)
	_banner.add_theme_constant_override("outline_size", 8)
	_banner.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.2))
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.size = Vector2(STAGE.x, 40)
	_banner.position = Vector2(0, PIECE.y - 120)
	_banner.pivot_offset = Vector2(STAGE.x * 0.5, 20)
	_banner.modulate.a = 0.0
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_banner)
	_flash = ColorRect.new()
	_flash.color = Color(1, 1, 1, 0)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_flash)



static var _ring_tex: Texture2D
static func _star_ring(size: int) -> Texture2D:
	if _ring_tex != null:
		return _ring_tex
	var img: = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var c: = size * 0.5
	var r: = size * 0.46
	for k in 12:
		var a: = TAU * k / 12.0
		var p: = Vector2(c, c) + Vector2(cos(a), sin(a)) * r
		var big: = k % 3 == 0
		for dy in range(-3, 4):
			for dx in range(-3, 4):
				var on: = (dx == 0 and absi(dy) <= (3 if big else 2)) or (dy == 0 and absi(dx) <= (3 if big else 2))\
				or (big and absi(dx) == 1 and absi(dy) == 1)
				if on:
					var x: = int(p.x) + dx
					var y: = int(p.y) + dy
					if x >= 0 and y >= 0 and x < size and y < size:
						img.set_pixel(x, y, Color(1, 0.95, 0.8, 1.0 if dx == 0 or dy == 0 else 0.6))

	for i in 360:
		var a: = TAU * i / 360.0
		var x: = int(c + cos(a) * r)
		var y: = int(c + sin(a) * r)
		if img.get_pixel(x, y).a < 0.1:
			img.set_pixel(x, y, Color(0.8, 0.75, 1.0, 0.35))
	_ring_tex = ImageTexture.create_from_image(img)
	return _ring_tex



static var _frames: = {}
func _hd(f: int) -> Texture2D:
	if _frames.has(f):
		return _frames[f]
	var img: = _spr.compose_image(0, f)
	if img == null:
		return null
	img.convert(Image.FORMAT_RGBA8)
	img = _scale2x(_scale2x(img))
	img.generate_mipmaps()
	var tex: = ImageTexture.create_from_image(img)
	_frames[f] = tex
	return tex



static func _scale2x(src: Image) -> Image:
	var w: = src.get_width()
	var h: = src.get_height()
	var p: = src.get_data().to_int32_array()
	var o: = PackedInt32Array()
	o.resize(w * h * 4)
	var ow: = w * 2
	for y in h:
		var up: = maxi(y - 1, 0) * w
		var row: = y * w
		var dn: = mini(y + 1, h - 1) * w
		for x in w:
			var e: = p[row + x]
			var a: = p[up + x]
			var d: = p[dn + x]
			var c: = p[row + maxi(x - 1, 0)]
			var b: = p[row + mini(x + 1, w - 1)]
			var i: = (y * 2) * ow + x * 2
			o[i] = a if c == a and c != d and a != b else e
			o[i + 1] = b if a == b and a != c and b != d else e
			o[i + ow] = c if d == c and d != b and c != a else e
			o[i + ow + 1] = d if b == d and b != a and d != c else e
	return Image.create_from_data(ow, h * 2, false, Image.FORMAT_RGBA8, o.to_byte_array())


func _shooting_star() -> void :
	var s: = ColorRect.new()
	s.size = Vector2(26, 2)
	s.color = Color(1, 1, 1, 0.9)
	s.rotation = deg_to_rad(28)
	s.position = Vector2(randf_range(20, STAGE.x - 80), randf_range(10, 90))
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(s)
	var t: = s.create_tween().set_parallel()
	t.tween_property(s, "position", s.position + Vector2(90, 48), 0.6)
	t.tween_property(s, "modulate:a", 0.0, 0.6)
	t.chain().tween_callback(s.queue_free)




var _how: = -1
var _how_b: Button
func _how_steps() -> Array:
	return [
		tr("«Cada Star Crumb vuelve a tirar las tres líneas de la pieza. La primera vez despiertan tres líneas Raras.»"), 
		tr("«En cada tirada la pieza puede subir de rango sola: un %d%% de Raro a Épico y un %d%% de Épico a Legendario. No hace falta fijar nada, y el rango nunca baja.»") % [
			roundi(float(GameData.POTENTIAL_UP[0]) * 100.0), roundi(float(GameData.POTENTIAL_UP[1]) * 100.0)], 
		tr("«La primera línea siempre es del rango de la pieza. La segunda y la tercera tienen un %d%% de serlo; si no, salen un rango más abajo.»") % roundi(GameData.POTENTIAL_SAME * 100.0), 
		tr("«Fijar una línea la guarda tal cual en la próxima tirada, hasta dos líneas, por %d Star Crumbs más cada una. Sirve para quedarte con una buena, no para subir de rango.»") % GameData.POTENTIAL_LOCK_COST, 
		tr("«Una línea Legendaria sale perfecta, con su valor más alto, un %d%% de las veces; si no, semi perfecta.»") % roundi(GameData.POTENTIAL_PERFECT * 100.0), 
	]


func _explain() -> void :
	if _busy:
		return
	world.menus.ui_click()
	var steps: = _how_steps()
	_how += 1
	if _how >= steps.size():
		_how = -1
		_how_b.text = tr("¿Cómo funciona?")
		_say(_greeting())
		return
	_say(steps[_how])
	_how_b.text = tr("Siguiente (%d/%d)") % [_how + 1, steps.size()]


func _say(text: String) -> void :
	if _bubble != null:
		_bubble.text = text


func _greeting() -> String:
	if Save.storage().is_empty():
		return tr("«Sin equipo no hay estrellas. Guarda algo en el Almacén Kafra y tráemelo.»")
	if Save.material("star_crumb") <= 0:
		return tr("«No tienes Star Crumbs. Salen de los MVP, de la Endless Tower y de los monstruos desde Infierno 10, más con cada Juramento, muy de vez en cuando.»")
	return tr("«Cada Star Crumb despierta tres líneas al azar. A veces la pieza sube de rango: Raro, Épico... y Legendario.»")






func _refresh(stage: = false) -> void :
	_fill_left()
	_fill_right()
	if stage:
		_show_piece()
	_crumbs_l.text = "x%d" % Save.material("star_crumb")
	_tears_l.text = "x%d" % Save.material("hel_tear")
	_tears_box.visible = Save.material("hel_tear") > 0


func _fill_left() -> void :
	for c in _left.get_children():
		_left.remove_child(c)
		c.queue_free()
	var store: = Save.storage()
	_left.add_child(menus._ro_text(tr("Almacén Kafra  %d / %d") % [store.size(), Save.storage_cap()], 12, Color(0.12, 0.25, 0.75), true))
	_left.add_child(menus._store_tabs( func(): _refresh()))
	var grid: = GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	_left.add_child(menus._store_scroll(grid, 6))
	var shown: = menus._store_shown( func(s): return not Equipment.is_soul(s))
	for s_it in shown:
		var uid: = str(s_it.uid)
		var cell: = Button.new()
		cell.custom_minimum_size = Vector2(40, 40)
		cell.focus_mode = Control.FOCUS_NONE
		var sel: = uid == _uid
		var t: = Potential.tier(s_it)
		var col: = Potential.tier_color(t) if t > 0 else Equipment.item_color(s_it)
		var box: = menus._cell_box(col, sel or t > 0, 3 if sel else (2 if t > 0 else 1))
		for sn in ["normal", "hover", "pressed"]:
			cell.add_theme_stylebox_override(sn, box)
		var center: = CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(center)
		center.add_child(UiKit.icon_rect(menus._item_icon(Equipment.item_def(s_it).icon), 30))
		if t > 0:
			var star: = menus._ro_text("★", 10, col, true)
			star.add_theme_constant_override("outline_size", 3)
			star.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.2))
			star.mouse_filter = Control.MOUSE_FILTER_IGNORE
			star.position = Vector2(26, 0)
			cell.add_child(star)
		menus._owner_star(cell, uid)
		menus._set_hover(cell, menus._item_hover(s_it, menus._owner_feet(uid)))
		cell.pressed.connect( func():
			if _busy:
				return
			if _uid != uid:
				_locks = []
				_before = []
				_tear_ask = -1
				_roll_ask = false
			_uid = uid
			world.menus.ui_click()
			_refresh(true))
		grid.add_child(cell)
	for i in maxi(0, 18 - shown.size()):
		var empty: = Panel.new()
		empty.custom_minimum_size = Vector2(40, 40)
		empty.add_theme_stylebox_override("panel", menus._cell_box(Color(0.84, 0.86, 0.92), false, 1))
		empty.modulate.a = 0.7
		grid.add_child(empty)



func _show_piece() -> void :
	var it: = Save.storage_item(_uid)
	_piece.texture = menus._item_icon(Equipment.item_def(it).icon) if not it.is_empty() else null
	var t: = Potential.tier(it)
	var col: = Potential.tier_color(t) if t > 0 else Color(0.7, 0.72, 0.85)
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.1, 0.25, 0.92)
	sb.border_color = col
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(40)
	sb.set_content_margin_all(8)
	sb.shadow_color = Color(col, 0.6)
	sb.shadow_size = 10 if t > 0 else 4
	sb.anti_aliasing = true
	_socket.add_theme_stylebox_override("panel", sb)
	_halo.self_modulate = col if t > 0 else Color(0.7, 0.6, 1.0)
	_tier_l.text = (tr("Potencial %s") % Potential.tier_name(t)).to_upper() if t > 0 else (tr("Sin potencial") if not it.is_empty() else "")
	_tier_l.add_theme_color_override("font_color", col.lightened(0.2) if t > 0 else Color(0.8, 0.82, 0.95))




func _fill_right(hidden: = false) -> void :
	for c in _right.get_children():
		_right.remove_child(c)
		c.queue_free()
	_rows.clear()
	_roll_b = null
	var it: = Save.storage_item(_uid)
	if it.is_empty():
		_right.add_child(menus._ro_text(tr("Tu Almacén Kafra está vacío."), 12, Color(0.28, 0.3, 0.4)))
		return
	var t: = Potential.tier(it)
	_right.add_child(menus._ro_text(Equipment.item_name(it), 15, Equipment.item_color(it), true))
	_right.add_child(menus._owner_line(str(it.uid)))

	_head = HBoxContainer.new()
	_head.add_theme_constant_override("separation", 8)
	_right.add_child(_head)
	_fill_head(_head, _hold_tier if _hold_tier >= 0 else t)

	var lines: = Potential.lines(it)
	for i in Potential.LINES:
		var row: = _line_row(lines[i] if i < lines.size() else {}, i, i < lines.size())
		_right.add_child(row)
		_rows.append(row)
		if hidden:
			row.modulate.a = 0.0


	if not _before.is_empty() and not hidden:
		var was: = VBoxContainer.new()
		was.add_theme_constant_override("separation", 0)
		_right.add_child(was)

		was.add_child(menus._ro_text(tr("Antes:"), 11, Color(0.3, 0.32, 0.42), true))
		for l in _before:
			var bl: = menus._ro_text("· " + Potential.line_text(l), 11, Potential.tier_color(int(l.t)).darkened(0.45))

			bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			bl.custom_minimum_size.x = 320
			was.add_child(bl)
	var gap: = Control.new()
	gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right.add_child(gap)

	var locks: = _locks.filter( func(x): return int(x) < lines.size()).size()
	var cost: = Potential.cost(locks)
	var have: = Save.material("star_crumb")
	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 8)
	_right.add_child(foot)
	var price: = HBoxContainer.new()
	price.add_theme_constant_override("separation", 3)
	price.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(price)
	price.add_child(UiKit.icon_rect(menus._item_icon("star_crumb"), 22))
	var pl: = menus._ro_text(tr("%d de %d") % [cost, have], 12, INK if have >= cost else Color(0.75, 0.2, 0.2), true)
	pl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	price.add_child(pl)
	if locks > 0:
		var ll: = menus._ro_text(tr("(%d fijadas)") % locks, 10, Color(0.55, 0.42, 0.1))
		ll.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		price.add_child(ll)

	var risky: = false
	for i in lines.size():
		if not _locks.has(i) and int(lines[i].get("t", 0)) >= GameData.POTENTIAL_TIERS.size():
			risky = true
	if not risky:
		_roll_ask = false
	_roll_b = UiKit.button(tr("¿Seguro? Pierdes una Legendaria") if _roll_ask else (tr("Despertar") if t == 0 else tr("Volver a tirar")), true)
	_roll_b.custom_minimum_size = Vector2(170, 40)
	_roll_b.disabled = have < cost or _busy
	if _roll_ask:
		_roll_b.add_theme_color_override("font_color", Color(0.75, 0.2, 0.15))
		_roll_b.tooltip_text = tr("Tienes una línea Legendaria sin fijar: la nueva tirada la cambia. Fíjala o vuelve a hacer clic.")
	_roll_b.pressed.connect( func():
		if risky and not _roll_ask:
			_roll_ask = true
			world.menus.ui_click()
			_fill_right()
			return
		_roll_ask = false
		_roll(cost))
	foot.add_child(_roll_b)




func _fill_head(head: HBoxContainer, t: int) -> void :
	for c in head.get_children():
		head.remove_child(c)
		c.queue_free()
	if t > 0:
		head.add_child(_pill(Potential.tier_name(t).to_upper(), Potential.tier_color(t)))
		if t < GameData.POTENTIAL_TIERS.size():
			var up: = menus._ro_text(tr("%d%% de subir a %s en cada tirada") % [roundi(float(GameData.POTENTIAL_UP[t - 1]) * 100.0), Potential.tier_name(t + 1)], 
				10, Color(0.28, 0.3, 0.4))
			up.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			head.add_child(up)
		else:
			var pf: = menus._ro_text(tr("Cada línea Legendaria: %d%% de salir perfecta") % roundi(GameData.POTENTIAL_PERFECT * 100.0), 10, Color(0.55, 0.42, 0.1))
			pf.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			head.add_child(pf)
	else:
		var none: = menus._ro_text(tr("Sin potencial: el primer Star Crumb le da tres líneas Raras."), 11, Color(0.28, 0.3, 0.4))
		none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		none.custom_minimum_size.x = 290
		head.add_child(none)
	head.add_child(_lines_help())



func _lines_help() -> Control:
	var gap: = Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: = HBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(gap)
	var help: = UiKit.tag("?", Color(0.45, 0.52, 0.75), 11)
	help.mouse_filter = Control.MOUSE_FILTER_STOP
	help.mouse_default_cursor_shape = Control.CURSOR_HELP
	help.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var rows: = [tr("Líneas que pueden salir (Raro / Épico / Legendario / perfecta):")]
	for k in GameData.POTENTIAL_LINES:
		var vals: Array = GameData.POTENTIAL_LINES[k].vals
		var nums: = "/".join(vals.map( func(v): return str(roundi(float(v) * 100.0))))
		rows.append("· " + tr(str(GameData.POTENTIAL_LINES[k].text)) % nums)
	help.tooltip_text = "\n".join(rows)
	box.add_child(help)
	return box


func _pill(text: String, col: Color) -> PanelContainer:
	var p: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	sb.shadow_color = Color(col, 0.5)
	sb.shadow_size = 4
	p.add_theme_stylebox_override("panel", sb)
	var l: = menus._ro_text(text, 12, Color.WHITE, true)
	l.add_theme_constant_override("outline_size", 3)
	l.add_theme_color_override("font_outline_color", col.darkened(0.45))
	p.add_child(l)
	return p




func _line_row(l: Dictionary, i: int, has: bool) -> PanelContainer:
	var lt: = int(l.get("t", 0)) if has else 0
	var perfect: = has and Potential.is_perfect(l)
	var col: = Potential.tier_color(lt) if lt > 0 else Color(0.8, 0.82, 0.88)
	var row: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.95, 0.78) if perfect else (Color(col, 0.1) if lt > 0 else Color(0.96, 0.965, 0.98))
	sb.border_color = Color(col, 0.85)
	sb.set_border_width_all(2 if perfect else 1)
	sb.border_width_left = 5
	sb.set_corner_radius_all(7)
	sb.content_margin_left = 9
	sb.content_margin_right = 6
	sb.content_margin_top = 5
	sb.content_margin_bottom = 5
	if perfect:
		sb.shadow_color = Color(GOLD, 0.55)
		sb.shadow_size = 6
	row.add_theme_stylebox_override("panel", sb)
	row.custom_minimum_size = Vector2(320, 40)
	row.pivot_offset = Vector2(160, 20)
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	row.add_child(h)
	var txtcol: = VBoxContainer.new()
	txtcol.add_theme_constant_override("separation", -2)
	txtcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(txtcol)
	var txt: = menus._ro_text(Potential.line_text(l) if has else tr("Línea por despertar"), 12, 
		col.darkened(0.4) if lt > 0 else Color(0.42, 0.44, 0.52), lt > 0)
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.custom_minimum_size.x = 220
	txtcol.add_child(txt)
	if lt > 0:
		var tag: = Potential.tier_name(lt)
		if lt >= GameData.POTENTIAL_TIERS.size():
			tag = ("★ " + tr("Perfecta")) if perfect else tr("Semi perfecta")
		txtcol.add_child(menus._ro_text(tag, 9, GOLD.darkened(0.25) if perfect else col.darkened(0.2), perfect))


	if has and Potential.is_semi(l) and Save.material("hel_tear") > 0:
		var ask: = _tear_ask == i
		var tb: = UiKit.button(tr("¿Seguro?") if ask else "", ask)
		tb.icon = menus._item_icon("hel_tear")
		tb.expand_icon = false
		tb.custom_minimum_size = Vector2(70 if ask else 34, 28)
		tb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tb.tooltip_text = tr("Lágrima de Hel: esta línea Legendaria semi perfecta pasa a perfecta (tienes %d).") % Save.material("hel_tear")
		tb.disabled = _busy
		tb.pressed.connect( func():
			if _tear_ask == i:
				_use_tear(i)
			else:
				_tear_ask = i
				world.menus.ui_click()
				_fill_right())
		h.add_child(tb)
	if has:
		var locked: = _locks.has(i)
		var lock: = UiKit.button(tr("Fijada") if locked else tr("Fijar"), locked)
		lock.custom_minimum_size = Vector2(64, 28)
		lock.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lock.tooltip_text = tr("Una línea fijada se queda en la próxima tirada (+%d Star Crumbs cada una).") % GameData.POTENTIAL_LOCK_COST
		lock.disabled = _busy
		lock.pressed.connect( func():
			if _locks.has(i):
				_locks.erase(i)
			elif _locks.size() < Potential.LINES - 1:
				_locks.append(i)
			_roll_ask = false
			world.menus.ui_click()
			_fill_right())
		h.add_child(lock)
	return row




func _roll(cost: int) -> void :
	var it: = Save.storage_item(_uid)
	if _busy or it.is_empty() or Save.material("star_crumb") < cost:
		return
	var had: = Potential.has(it)
	var locks: = _locks.filter( func(x): return int(x) < Potential.lines(it).size())
	var old_tier: = Potential.tier(it)
	_before = Potential.lines(it).duplicate(true) if had else []

	Save.add_material("star_crumb", - cost)

	_how = -1
	_how_b.text = tr("¿Cómo funciona?")
	var up: = Potential.roll(it, locks)
	Save.mark_dirty()
	Save.flush()
	_busy = true
	_skip = false
	_crumbs_l.text = "x%d" % Save.material("star_crumb")
	_hold_tier = old_tier
	_fill_right(true)
	await _play(it, up or old_tier == 0, locks)
	_hold_tier = -1
	if not is_inside_tree():
		return
	_busy = false
	_refresh(true)
	_say(_comment(it, up, had))




func _use_tear(i: int) -> void :
	_tear_ask = -1
	var it: = Save.storage_item(_uid)
	if _busy or it.is_empty() or Save.material("hel_tear") <= 0 or not Potential.tear(it, i):
		_fill_right()
		return
	Save.add_material("hel_tear", -1)
	Save.mark_dirty()
	Save.flush()
	_busy = true
	_skip = false
	_fill_right()
	_tears_l.text = "x%d" % Save.material("hel_tear")
	var tear: = UiKit.icon_rect(menus._item_icon("hel_tear"), 34)
	tear.position = Vector2(PIECE.x - 17, -40)
	tear.pivot_offset = Vector2(17, 17)
	tear.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(tear)
	_sound("gem_ding", -2.0, 0.7)
	if not _skip:
		var fall: = tear.create_tween()
		fall.tween_property(tear, "position:y", PIECE.y - 17, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await _wait(0.55)
	tear.queue_free()
	if not is_inside_tree():
		return
	var cold: = Color(0.55, 0.7, 1.0)
	_flash.color = Color(0.75, 0.85, 1.0, 0.9)
	create_tween().tween_property(_flash, "color:a", 0.0, 0.6)
	_rays.modulate = Color(cold, 0.0)
	var rt: = create_tween()
	rt.tween_property(_rays, "modulate:a", 0.9, 0.2)
	rt.tween_property(_rays, "modulate", Color(GOLD, 0.3), 1.0)
	_sparks(PIECE, cold, 16)
	_sparks(PIECE, GOLD, 12)
	_sound("refine_ok", -2.0)
	_sound("levelup", -4.0)
	_banner.text = "¡%s!" % tr("Perfecta").to_upper()
	_banner.add_theme_color_override("font_color", GOLD)
	_banner.modulate.a = 1.0
	_banner.scale = Vector2(0.3, 0.3)
	var bt: = create_tween()
	bt.tween_property(_banner, "scale", Vector2(1.15, 1.15), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	bt.tween_property(_banner, "scale", Vector2.ONE, 0.15)
	bt.tween_interval(1.0)
	bt.tween_property(_banner, "modulate:a", 0.0, 0.5)
	_busy = false
	_refresh(true)
	if i < _rows.size() and is_instance_valid(_rows[i]):
		var row: Control = _rows[i]
		var glow: = row.create_tween().set_loops(4)
		glow.tween_property(row, "modulate", Color(1.35, 1.25, 0.9), 0.14)
		glow.tween_property(row, "modulate", Color.WHITE, 0.14)
	_say(tr("«Una lágrima de la reina de Niflheim... Mira cómo la línea alcanza su punto más alto.»"))


func _sound(key: String, db: = 0.0, pitch: = -1.0) -> void :
	if world != null:
		world.play_sound(key, 0.0, db, pitch, false, true)


func _wait(t: float) -> void :
	var left: = t
	while left > 0.0 and not _skip and is_inside_tree():
		await get_tree().process_frame
		if not is_inside_tree():
			return
		left -= get_process_delta_time()




func _play(it: Dictionary, new_tier: bool, locks: Array) -> void :
	var t: = Potential.tier(it)
	var col: = Potential.tier_color(t)

	var crumb: = UiKit.icon_rect(menus._item_icon("star_crumb"), 28)
	crumb.position = Vector2(STAGE.x - 112, STAGE.y - 36)
	crumb.pivot_offset = Vector2(14, 14)
	crumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(crumb)
	_sound("gem_ding", -2.0)
	if not _skip:
		var fly: = crumb.create_tween().set_parallel()
		fly.tween_property(crumb, "position", PIECE - Vector2(14, 14), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		fly.tween_property(crumb, "rotation", TAU, 0.25)
		fly.tween_property(crumb, "scale", Vector2(0.5, 0.5), 0.25)
		await _wait(0.25)
	crumb.queue_free()
	if not is_inside_tree():
		return
	_sparks(PIECE, Color(1, 0.95, 0.7), 8)


	var base: = _socket.position
	for k in 3:
		if _skip:
			break
		_sound("refine_hammer", -3.0, 0.9 + 0.1 * k)
		_socket.scale = Vector2(1.1 + 0.04 * k, 0.9 - 0.02 * k)
		create_tween().tween_property(_socket, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
		_halo.self_modulate = Color(1, 1, 1).lerp(col, (k + 1) / 3.0)
		_sparks(PIECE + Vector2(0, 20), col.lightened(0.3), 6 + k * 4)
		for j in 3 + k:
			_socket.position = base + Vector2(randf_range(-4, 4), randf_range(-2, 2)) * (1.0 + 0.4 * k)
			await _wait(0.03)
		_socket.position = base
		await _wait(0.18 if k < 2 else 0.24)
		if not is_inside_tree():
			return
	_socket.position = base
	_socket.scale = Vector2.ONE

	_show_piece()
	_flash.color = Color(col.lightened(0.6), 0.85)
	create_tween().tween_property(_flash, "color:a", 0.0, 0.5)
	_rays.modulate = Color(col, 0.0)
	var rt: = create_tween()
	rt.tween_property(_rays, "modulate:a", 0.85 if t >= 2 else 0.5, 0.2)
	rt.tween_property(_rays, "modulate:a", 0.25, 1.2)
	var spin: = _rays.create_tween().set_loops(6)
	spin.tween_property(_rays, "rotation", TAU, 5.0).from(0.0)
	_sound("refine_ok", -2.0)
	_sparks(PIECE, col, 14 + t * 6)

	_hold_tier = -1
	if _head != null and is_instance_valid(_head):
		_fill_head(_head, t)

	if new_tier:
		_banner.text = "¡%s!" % Potential.tier_name(t).to_upper()
		_banner.add_theme_color_override("font_color", col.lightened(0.15))
		_banner.modulate.a = 1.0
		_banner.scale = Vector2(0.3, 0.3)
		var bt: = create_tween()
		bt.tween_property(_banner, "scale", Vector2(1.15, 1.15), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		bt.tween_property(_banner, "scale", Vector2.ONE, 0.15)
		bt.tween_interval(1.2)
		bt.tween_property(_banner, "modulate:a", 0.0, 0.5)
		_sound(str(TIER_SOUND[t - 1]), 0.0)
		if t >= 2:
			_sound("levelup", -3.0)

		await _wait(1.1)
		if not is_inside_tree():
			return
	elif not _skip:
		await _wait(0.35)
		if not is_inside_tree():
			return


	var lines: = Potential.lines(it)
	for i in _rows.size():
		var row: PanelContainer = _rows[i]
		if not is_instance_valid(row):
			continue
		var l: Dictionary = lines[i] if i < lines.size() else {}
		var lt: = int(l.get("t", 1))
		if locks.has(i) or _skip:
			row.modulate.a = 1.0
			continue

		if lt >= GameData.POTENTIAL_TIERS.size():
			_sparks(PIECE, GOLD, 10)
			await _wait(0.15)
		var tcol: = Potential.tier_color(lt)
		row.modulate = Color(1.8, 1.8, 1.8, 1.0)
		row.scale = Vector2(1.06, 1.06)
		var home: = row.position.x
		row.position.x = home + 40.0
		var tw: = create_tween().set_parallel()
		tw.tween_property(row, "position:x", home, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(row, "modulate", Color.WHITE, 0.22)
		tw.tween_property(row, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_sparks(PIECE + Vector2(0, -10 + 18 * i), tcol.lightened(0.2), 3 + lt * 2)
		_sound(str(TIER_SOUND[clampi(lt, 1, 3) - 1]), -4.0 if lt == 1 else -1.0)
		if Potential.is_perfect(l):
			_sound("levelup", -6.0)
			var glow: = create_tween().set_loops(3)
			glow.tween_property(row, "modulate", Color(1.35, 1.25, 0.9), 0.12)
			glow.tween_property(row, "modulate", Color.WHITE, 0.12)
		await _wait(0.14 if lt < 3 else 0.22)
		if not is_inside_tree():
			return
	for row in _rows:
		if is_instance_valid(row):
			row.modulate.a = 1.0
			row.scale = Vector2.ONE


func _sparks(at: Vector2, color: Color, n: int) -> void :
	for i in n:
		var s: = ColorRect.new()
		s.color = color.lightened(randf_range(0.0, 0.5))
		s.size = Vector2.ONE * randf_range(2.0, 5.0)
		s.rotation = randf() * TAU
		s.position = at
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stage.add_child(s)
		var to: = at + Vector2.from_angle(randf() * TAU) * randf_range(40.0, 120.0)
		var tw: = s.create_tween().set_parallel()
		tw.tween_property(s, "position", to, randf_range(0.4, 0.8)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(s, "modulate:a", 0.0, 0.8).set_delay(0.2)
		tw.chain().tween_callback(s.queue_free)



func _comment(it: Dictionary, up: bool, had: bool) -> String:
	var lines: = Potential.lines(it)
	var perfect: = lines.filter( func(l): return Potential.is_perfect(l)).size()
	var legend: = lines.filter( func(l): return int(l.t) >= GameData.POTENTIAL_TIERS.size()).size()
	if legend >= 3 and perfect >= 3:
		return tr("«...Tres perfectas. En toda mi vida no había visto algo así.»")
	if legend >= 3:
		return tr("«¡Tres líneas Legendarias! Esto ya es una reliquia.»")
	if perfect > 0:
		return tr("«¡Una línea perfecta! Brilla como la estrella más alta.»")
	if up:
		return tr("«¡Mira cómo brilla! Tu pieza subió a %s.»") % Potential.tier_name(Potential.tier(it))
	if not had:
		return tr("«Tres líneas Raras despiertan. Cada Star Crumb más las vuelve a tirar.»")
	return tr("«Las estrellas se mueven... líneas nuevas.»")
