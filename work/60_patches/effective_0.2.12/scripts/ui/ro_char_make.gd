class_name RoCharMake
extends Control







signal done(class_id: String, look: Dictionary)

const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
signal cancelled

signal titles_pressed

signal cosmetics_pressed

const ROOT: = "res://assets/ro/ui/skin/login_interface/"
const ARROW: = "res://assets/ro/ui/skin/basic_interface/arw_right.png"
const SIZE: = Vector2(576, 342)
const FEET: = Vector2(95, 216)
const HEX_CENTER: = Vector2(288, 165)
const HEX_RADIUS: = 79.0

const HEX_STATS: = ["str", "agi", "vit", "int", "dex", "luk"]
const TABLE_STATS: = ["str", "agi", "vit", "int", "dex", "luk"]
const NAVY: = Color(0.2, 0.26, 0.43)

var class_id: = ""

var name_changed: = false
var look: = {}
var _bg: Texture2D
var _sprite: RoSprite
var _dir: = 0


var _jobs: Array = []
var _job: = 0
var _job_label: Label

var _drag: = -1.0

const DRAG_STEP: = 18.0
var _name_edit: LineEdit



var _glow_a: = 0.0
var _glow_t: = 0.0
const NAME_BOX: = Rect2(60, 242, 102, 21)
var _name_warn: Label
var _values: = {}

var _perm: = {}
var _pending: = {}

const HOLD_DELAY: = 0.35
const HOLD_EVERY: = 0.05
var _hold_button: BaseButton
var _hold_call: = Callable()
var _hold_t: = 0.0
var _reset_button: Button
var titles_button: Button
var _font: Font = preload("res://assets/ro/fonts/SCDream4.otf")
var _font_bold: Font = preload("res://assets/ro/fonts/SCDream6.otf")


func _ready() -> void :
	custom_minimum_size = SIZE
	size = SIZE
	texture_filter = RoAssets.ui_filter()
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	if ResourceLoader.exists(ROOT + "win_make.png"):
		_bg = Lang.ui_tex(ROOT + "win_make.png")
	look = Save.look(class_id)

	_name_edit = LineEdit.new()

	_name_edit.gui_input.connect( func(ev: InputEvent):
		if ev.is_action_pressed("ui_cancel"):
			_name_edit.accept_event()
			cancelled.emit())


	_name_edit.position = Vector2(62, 243)
	_name_edit.size = Vector2(99, 19)
	_name_edit.clip_contents = true
	_name_edit.max_length = GameData.NAME_MAX
	_name_edit.placeholder_text = tr("Aventurero")
	_name_edit.text = str(look.name)
	_name_edit.add_theme_font_override("font", _font)
	_name_edit.add_theme_font_size_override("font_size", 11)
	_name_edit.add_theme_color_override("font_color", Color.BLACK)
	_name_edit.add_theme_color_override("font_placeholder_color", Color(0.42, 0.44, 0.5))
	_name_edit.add_theme_color_override("caret_color", Color.BLACK)
	for st in ["normal", "focus", "read_only"]:
		var box: = StyleBoxEmpty.new()
		box.content_margin_left = 3
		box.content_margin_top = 0
		box.content_margin_bottom = 0
		_name_edit.add_theme_stylebox_override(st, box)
	_name_edit.text_changed.connect( func(t: String):
		look.name = t.strip_edges()
		_name_edit.add_theme_color_override("font_color", Color.BLACK)

		queue_redraw()
		if _name_warn != null:
			_name_warn.visible = false)
	_name_edit.text_submitted.connect( func(_t: String): _accept())
	add_child(_name_edit)

	var h: = maxf(19.0, _name_edit.get_combined_minimum_size().y)
	_name_edit.size = Vector2(99, h)
	_name_edit.position = Vector2(62, roundf(252.5 - h * 0.5))

	for step in [-1, 1]:
		var tb: = TextureButton.new()
		tb.texture_normal = arrow_tex()
		tb.flip_h = step < 0
		tb.position = FEET + Vector2(-56 if step < 0 else 48, -6)
		tb.texture_filter = RoAssets.ui_filter()
		tb.tooltip_text = tr("Girar (o arrastra al personaje)")
		tb.pressed.connect(_turn.bind(step))
		add_child(tb)
	_build_jobs()
	_add_job_picker(Vector2(10, 24))
	_add_option(Vector2(10, 270), tr("Peinado"), "hair")
	_add_option(Vector2(162, 270), tr("Color pelo"), "hair_color")
	_add_option(Vector2(10, 290), tr("Ropa"), "cloth")
	_add_option(Vector2(162, 290), tr("Género"), "gender")

	var dice: = Button.new()
	dice.text = tr("Al azar")

	dice.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed", "disabled"]:
		var box: StyleBox = UiStyles.button_box(state)
		box.content_margin_left = 6
		box.content_margin_right = 6
		box.content_margin_top = 1
		box.content_margin_bottom = 1
		dice.add_theme_stylebox_override(state, box)
	dice.add_theme_color_override("font_color", UiStyles.HUD_TITLE_TEXT)
	dice.add_theme_color_override("font_hover_color", Color(0.2, 0.32, 0.72))
	dice.add_theme_font_override("font", _font)
	dice.add_theme_font_size_override("font_size", 10)

	dice.position = Vector2(166, 244)
	dice.pressed.connect(_randomize)
	add_child(dice)

	_perm = Save.class_stats(class_id)
	var arrow: Texture2D = load(ARROW) if ResourceLoader.exists(ARROW) else null
	for r in TABLE_STATS.size():
		var stat: String = TABLE_STATS[r]
		for step in [-1, 1]:
			var b: = TextureButton.new()
			b.texture_normal = arrow
			b.flip_h = step < 0
			b.position = Vector2(500 if step < 0 else 538, 41 + r * 16)
			b.texture_filter = RoAssets.ui_filter()

			b.set_meta("hover", _stat_hover(stat, tr("Quitar punto") if step < 0 else tr("Poner punto")))
			b.pressed.connect(_place.bind(stat, step))

			b.button_down.connect( func():
				_hold_button = b
				_hold_call = _place.bind(stat, step)
				_hold_t = HOLD_DELAY)
			add_child(b)
	_reset_button = Button.new()
	_reset_button.position = Vector2(409, 168)
	_reset_button.focus_mode = Control.FOCUS_NONE

	for state in ["normal", "hover", "pressed", "disabled"]:
		var box: StyleBox = UiStyles.button_box(state)
		box.content_margin_left = 6
		box.content_margin_right = 6
		box.content_margin_top = 1
		box.content_margin_bottom = 1
		_reset_button.add_theme_stylebox_override(state, box)
	_reset_button.add_theme_color_override("font_color", UiStyles.HUD_TITLE_TEXT)
	_reset_button.add_theme_color_override("font_hover_color", Color(0.2, 0.32, 0.72))
	_reset_button.add_theme_color_override("font_disabled_color", Color(0.42, 0.42, 0.48))
	_reset_button.add_theme_font_override("font", _font)
	_reset_button.add_theme_font_size_override("font_size", 10)
	_reset_button.pressed.connect(_reset_points)
	add_child(_reset_button)
	var cancel: = _add_button("btn_cancel", Vector2.ZERO, func(): cancelled.emit())
	cancel.position = Vector2(SIZE.x - 8 - cancel.size.x, SIZE.y - 24)
	var ok: = _add_button("btn_ok", Vector2.ZERO, _accept)
	ok.position = Vector2(cancel.position.x - 4 - ok.size.x, SIZE.y - 24)

	titles_button = _add_button("btn_titles", Vector2.ZERO, func(): titles_pressed.emit())
	titles_button.text = tr("Títulos")
	titles_button.size = titles_button.get_combined_minimum_size()
	titles_button.position = Vector2(409, 192)
	var cos_button: = _add_button("btn_cosmetics", Vector2.ZERO, func(): cosmetics_pressed.emit())
	cos_button.text = tr("Cosméticos")
	cos_button.size = cos_button.get_combined_minimum_size()
	cos_button.position = Vector2(titles_button.position.x + titles_button.size.x + 4, 192)


	titles_button.visible = false
	cos_button.visible = OS.has_feature("web")
	if cos_button.visible:
		cos_button.text = tr("Armario")
		cos_button.icon = load("res://assets/ro/ui/skin/item_icons/wardrobe.png") if ResourceLoader.exists("res://assets/ro/ui/skin/item_icons/wardrobe.png") else null
		cos_button.size = cos_button.get_combined_minimum_size()
		cos_button.position = Vector2(409, 192)
	_refresh()




func _stat_hover(stat: String, action: = "") -> Dictionary:
	var d: Dictionary = GameData.STATS[stat]
	var foot: = [[tr("Cada punto de clase suma 1 a este atributo al empezar cada partida con esta clase."), Color(0.7, 0.75, 0.9)]]
	if action != "":
		foot.push_front([action, Color(0.95, 0.8, 0.4)])
	return {"title": "%s · %s" % [tr(str(d.name)), tr(str(d.full))], "tag": tr("Atributo"), 
		"desc": tr("Por punto: %s") % tr(str(d.desc)), "foot": foot}



func _add_option(at: Vector2, label: String, field: String) -> void :
	var l: = Label.new()
	l.text = label
	l.position = at
	l.add_theme_font_override("font", _font_bold)
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", NAVY)
	add_child(l)
	var arrow: Texture2D = load(ARROW) if ResourceLoader.exists(ARROW) else null


	var touch: = Menus.touch_ui()
	for step in [-1, 1]:
		if touch:
			_touch_arrow(at + Vector2(62 if step < 0 else 128, -2), step, _step.bind(field, step))
			continue
		var b: = TextureButton.new()
		b.texture_normal = arrow
		b.flip_h = step < 0
		b.position = at + Vector2(70 if step < 0 else 136, 3)
		b.custom_minimum_size = Vector2(11, 11)
		b.texture_filter = RoAssets.ui_filter()
		b.pressed.connect(_step.bind(field, step))
		add_child(b)
	if field == "gender":
		var v: = Label.new()
		v.position = at + Vector2(82, 0)
		v.size = Vector2(52, 14)
		v.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_theme_font_override("font", _font)
		v.add_theme_font_size_override("font_size", 11)
		v.add_theme_color_override("font_color", Color.BLACK)
		add_child(v)
		_values[field] = v
		return

	var e: = LineEdit.new()
	e.position = at + Vector2(84, -2)
	e.size = Vector2(48, 17)
	e.alignment = HORIZONTAL_ALIGNMENT_CENTER
	e.max_length = 3
	e.select_all_on_focus = true
	e.add_theme_font_override("font", _font)
	e.add_theme_font_size_override("font_size", 11)
	e.add_theme_color_override("font_color", Color.BLACK)
	e.add_theme_color_override("caret_color", Color.BLACK)
	var idle: = StyleBoxEmpty.new()
	var focus: = StyleBoxFlat.new()
	focus.bg_color = Color(1, 1, 1, 0.9)
	focus.border_color = Color(0.45, 0.55, 0.85)
	focus.set_border_width_all(1)
	focus.set_corner_radius_all(2)
	for box in [idle, focus]:
		box.content_margin_top = 0
		box.content_margin_bottom = 0
	e.add_theme_stylebox_override("normal", idle)
	e.add_theme_stylebox_override("focus", focus)
	e.tooltip_text = tr("Escribe un número (%d-%d)") % [_range(field).x, _range(field).y]
	e.text_submitted.connect( func(_t: String): _typed(field, e))
	e.focus_exited.connect( func(): _typed(field, e))
	e.gui_input.connect( func(ev: InputEvent):
		if ev.is_action_pressed("ui_cancel"):
			e.accept_event()
			e.release_focus())
	add_child(e)

	var h: = maxf(17.0, e.get_combined_minimum_size().y)
	e.size = Vector2(48, h)
	e.position = at + Vector2(84, roundf(8.0 - h * 0.5))
	if touch:

		e.editable = false
		e.add_theme_stylebox_override("read_only", idle)
		e.add_theme_color_override("font_uneditable_color", Color.BLACK)
		e.mouse_filter = Control.MOUSE_FILTER_IGNORE
		e.focus_mode = Control.FOCUS_NONE
		e.tooltip_text = ""
		e.size.x = 44
		e.position.x = at.x + 84
	_values[field] = e





func _touch_arrow(at: Vector2, step: int, callback: Callable) -> void :
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.position = at
	b.custom_minimum_size = Vector2(22, 20)
	b.size = Vector2(22, 20)


	b.draw.connect( func():
		var c: = b.size * 0.5
		var d: = float(step)
		b.draw_colored_polygon(PackedVector2Array([c + Vector2(4.5 * d, 0), c + Vector2(-3.5 * d, -5.5), c + Vector2(-3.5 * d, 5.5)]), 
			Color(0.95, 0.97, 1.0) if b.button_pressed or b.is_pressed() else Color(0.3, 0.45, 0.85)))
	for st in ["normal", "hover", "pressed"]:
		var box: = StyleBoxFlat.new()
		box.bg_color = {"normal": Color(0.93, 0.95, 1.0), "hover": Color(0.86, 0.9, 1.0), "pressed": Color(0.4, 0.54, 0.9)}[st]
		box.border_color = Color(0.45, 0.58, 0.9)
		box.set_border_width_all(1)
		box.shadow_color = Color(0.1, 0.18, 0.45, 0.18)
		box.shadow_size = 2
		box.shadow_offset = Vector2(0, 1)
		box.set_corner_radius_all(6)
		box.anti_aliasing = true
		box.content_margin_left = 0
		box.content_margin_right = 0
		box.content_margin_top = 0
		box.content_margin_bottom = 0
		b.add_theme_stylebox_override(st, box)
	b.pressed.connect(callback)
	add_child(b)
	b.size = Vector2(22, 20)


static func arrow_tex() -> Texture2D:
	return load(ARROW) if ResourceLoader.exists(ARROW) else null



func _turn(step: int) -> void :
	_dir = posmod(_dir + step, RoSprite.DIRS)
	queue_redraw()



func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and Rect2(FEET - Vector2(40, 110), Vector2(80, 120)).has_point(event.position):
			_drag = event.position.x
			accept_event()
		elif not event.pressed:
			_drag = -1.0
	elif event is InputEventMouseMotion and _drag >= 0.0:
		while event.position.x - _drag >= DRAG_STEP:
			_drag += DRAG_STEP
			_turn(-1)
		while _drag - event.position.x >= DRAG_STEP:
			_drag -= DRAG_STEP
			_turn(1)
		accept_event()



func _add_button(tex: String, at: Vector2, callback: Callable) -> Button:
	var b: = Button.new()
	b.text = tr("OK") if tex == "btn_ok" else tr("Cancelar")
	b.focus_mode = Control.FOCUS_NONE
	for st in ["normal", "hover", "pressed", "disabled"]:
		var box: = UiStyles.button_box(st)
		box.content_margin_left = 9
		box.content_margin_right = 9
		box.content_margin_top = 1
		box.content_margin_bottom = 2
		b.add_theme_stylebox_override(st, box)
	b.add_theme_font_override("font", _font_bold if tex == "btn_ok" else _font)
	b.add_theme_font_size_override("font_size", 11)
	b.add_theme_color_override("font_color", UiStyles.HUD_TITLE_TEXT)
	b.add_theme_color_override("font_hover_color", Color(0.2, 0.32, 0.72))
	b.custom_minimum_size = Vector2(30, 20)
	b.position = at
	b.pressed.connect(callback)
	add_child(b)
	b.size = b.get_combined_minimum_size()
	return b




func _range(field: String) -> Vector2i:
	match field:
		"hair":
			return Vector2i(1, GameData.DORAM_HAIR_STYLES if GameData.is_doram_body(str(_jobs[_job].body)) else GameData.HAIR_STYLES)
		"hair_color":
			return Vector2i(0, GameData.HAIR_COLORS - 1)
		"cloth":
			return Vector2i(0, RoAssets.cloth_dyes(str(_jobs[_job].body), look.gender == "f"))
	return Vector2i.ZERO


func _step(field: String, step: int) -> void :
	if field == "gender":
		look.gender = "f" if look.gender == "m" else "m"
		look.cloth = mini(int(look.cloth), _range("cloth").y)
	else:
		var r: = _range(field)
		look[field] = posmod(int(look[field]) - r.x + step, r.y - r.x + 1) + r.x
	_refresh()


func _randomize() -> void :
	look.gender = "f" if randf() < 0.5 else "m"
	for f in ["hair", "hair_color", "cloth"]:
		var r: = _range(f)
		look[f] = randi_range(r.x, r.y)
	_refresh()



func _typed(field: String, e: LineEdit) -> void :
	var r: = _range(field)
	if e.text.strip_edges().is_valid_int():
		look[field] = clampi(e.text.strip_edges().to_int(), r.x, r.y)
	_refresh()


func _points_left() -> int:
	var used: = 0
	for k in _pending:
		used += int(_pending[k])
	return Save.free_points(class_id) - used



func _place(stat: String, step: int) -> void :
	var cur: = int(_pending.get(stat, 0))
	if step > 0:
		if _points_left() <= 0 or int(_perm.get(stat, 0)) + cur >= Save.perm_stat_max(class_id):
			return
	elif cur <= 0:
		return
	_pending[stat] = cur + step
	_refresh()


func _reset_points() -> void :
	if Save.reset_class_stats(class_id):
		_perm = {}
		_pending = {}
		_refresh()



func _build_jobs() -> void :

	_jobs = GameData.job_looks(class_id) + GameData.outfit_looks(class_id)
	var worn: Dictionary = GameData.shown_job(class_id, look)
	_job = maxi(0, _jobs.find(worn))


func _job_name(e: Dictionary) -> String:
	if e.has("job"):
		return tr(GameData.job_title(e.job, look.gender == "f"))
	return tr(str(e.name))





func _add_job_picker(at: Vector2) -> void :
	var l: = Label.new()
	l.text = tr("Te ven como")
	l.position = at
	l.add_theme_font_override("font", _font_bold)
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", NAVY)
	l.mouse_filter = Control.MOUSE_FILTER_PASS
	l.tooltip_text = tr("El oficio con el que apareces en Prontera, al elegir personaje y ante los demás jugadores.")
	add_child(l)
	var lw: = ceilf(_font_bold.get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x)
	var shift: = maxf(0.0, lw + 6.0 - 60.0)
	for step in [-1, 1]:
		if Menus.touch_ui():
			_touch_arrow(at + Vector2((56 if step < 0 else 168) + shift, -2), step, func():
				_job = posmod(_job + step, _jobs.size())
				_refresh())
			continue
		var b: = TextureButton.new()
		b.texture_normal = arrow_tex()
		b.flip_h = step < 0
		b.position = at + Vector2((60 if step < 0 else 168) + shift, 3)
		b.texture_filter = RoAssets.ui_filter()
		b.pressed.connect( func():
			_job = posmod(_job + step, _jobs.size())
			_refresh())
		add_child(b)
	_job_label = Label.new()
	_job_label.position = at + Vector2(72 + shift, 0)
	_job_label.size = Vector2(94, 14)
	_job_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_job_label.clip_text = true
	_job_label.add_theme_font_override("font", _font)
	_job_label.add_theme_font_size_override("font_size", 11)
	_job_label.add_theme_color_override("font_color", Color.BLACK)
	add_child(_job_label)


func _refresh() -> void :
	var j: Dictionary = _jobs[_job]
	_sprite = RoAssets.styled_character(j.body, j.weapon, j.weapon_fx, [j.attack], "", look)
	_job_label.text = _job_name(j)
	for f in ["hair", "hair_color", "cloth"]:
		var e: LineEdit = _values[f]
		e.text = str(int(look[f]))
		e.tooltip_text = tr("Escribe un número (%d-%d)") % [_range(f).x, _range(f).y]
	_values.gender.text = tr("Mujer") if look.gender == "f" else tr("Hombre")
	var placed: = 0
	for k in _perm:
		placed += int(_perm[k])
	_reset_button.text = tr("Reiniciar puntos (%d z)") % Save.stat_reset_cost(class_id)
	_reset_button.disabled = placed == 0 or Save.zeny() < Save.stat_reset_cost(class_id)
	queue_redraw()



func _name_warning(text: String) -> void :
	_name_edit.add_theme_color_override("font_color", Color(0.8, 0.1, 0.1))
	if _name_warn == null:
		_name_warn = Label.new()
		_name_warn.add_theme_font_override("font", _font)
		_name_warn.add_theme_font_size_override("font_size", 10)
		_name_warn.add_theme_color_override("font_color", Color(0.85, 0.1, 0.1))
		_name_warn.add_theme_color_override("font_outline_color", Color.WHITE)
		_name_warn.add_theme_constant_override("outline_size", 3)
		_name_warn.position = Vector2(12, _name_edit.position.y - 16)
		add_child(_name_warn)
	_name_warn.text = text
	_name_warn.visible = true
	var x: = _name_edit.position.x
	var tw: = _name_edit.create_tween()
	for d in [4.0, -4.0, 3.0, -3.0, 0.0]:
		tw.tween_property(_name_edit, "position:x", x + d, 0.04)
	_name_edit.grab_focus()


func _accept() -> void :
	look.name = _name_edit.text.strip_edges()

	var old_name: = str(Save.look(class_id).get("name", "")).strip_edges()
	if old_name != "" and look.name != old_name and Save.rename_wait(class_id) > 0:
		var wait: = Save.rename_wait(class_id)
		_name_warning(tr("Podrás cambiar el nombre en %d h %02d min.") % [wait / 3600, (wait % 3600) / 60])
		return
	if not NameFilter.allowed(look.name) or (NameFilter.reserved(look.name) and not (NameFilter.dev_name(look.name) and Save.is_dev())):
		_name_warning(tr("Ese nombre no está permitido."))
		return
	if old_name != "" and look.name != old_name:
		Save.mark_renamed(class_id)
		name_changed = true
	if not _pending.is_empty():
		var merged: = _perm.duplicate()
		for k in _pending:
			merged[k] = int(merged.get(k, 0)) + int(_pending[k])
		Save.set_class_stats(class_id, merged)

	if _jobs[_job].has("job"):
		look["show"] = str(_jobs[_job].job.id)
	else:
		look.erase("show")
	done.emit(class_id, look)





func _draw_frame() -> void :
	var body: = StyleBoxFlat.new()
	body.bg_color = Color(UiStyles.HUD_BODY_BG, 1.0)
	body.border_color = UiStyles.HUD_RIM
	body.set_border_width_all(1)
	body.set_corner_radius_all(9)
	body.shadow_color = Color(0.03, 0.06, 0.18, 0.3)
	body.shadow_size = 8
	body.shadow_offset = Vector2(0, 4)
	body.anti_aliasing = true
	draw_style_box(body, Rect2(Vector2.ZERO, SIZE))
	var title: = StyleBoxFlat.new()
	title.bg_color = UiStyles.HUD_TITLE_BG
	title.corner_radius_top_left = 8
	title.corner_radius_top_right = 8
	title.border_color = UiStyles.HUD_TITLE_LINE
	title.border_width_bottom = 1
	title.anti_aliasing = true
	draw_style_box(title, Rect2(1, 1, SIZE.x - 2, 18))
	draw_string(_font_bold, Vector2(10, 14), tr("Creación de personaje"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, UiStyles.HUD_TITLE_TEXT)

	draw_set_transform(FEET, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 24.0, Color(0.2, 0.25, 0.4, 0.16))
	draw_circle(Vector2.ZERO, 16.0, Color(0.2, 0.25, 0.4, 0.14))
	draw_set_transform(Vector2.ZERO)

	var hexa: = PackedVector2Array()
	for i in 7:
		var a: = - PI / 2.0 + TAU * (i % 6) / 6.0
		hexa.append(HEX_CENTER + Vector2(cos(a), sin(a)) * HEX_RADIUS)
	draw_colored_polygon(hexa, Color(0.9, 0.93, 1.0, 0.6))
	for i in 6:
		draw_line(HEX_CENTER, hexa[i], Color(0.45, 0.55, 0.85, 0.55), 1.0, true)
	draw_polyline(hexa, Color(0.4, 0.5, 0.85), 1.0, true)

	var table: = StyleBoxFlat.new()
	table.bg_color = Color(0.94, 0.955, 0.99)
	table.border_color = Color(0.8, 0.84, 0.93)
	table.set_border_width_all(1)
	table.set_corner_radius_all(7)
	table.anti_aliasing = true
	draw_style_box(table, Rect2(405, 37, 150, TABLE_STATS.size() * 16 + 4))
	for r in TABLE_STATS.size():
		var y: = 39.0 + r * 16
		if r > 0:
			draw_line(Vector2(409, y - 0.5), Vector2(551, y - 0.5), Color(0.82, 0.86, 0.94), 1.0)
		draw_string(_font_bold, Vector2(412, y + 12), tr(str(GameData.STATS[TABLE_STATS[r]].name)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 
			Color(0.3, 0.38, 0.62))

	draw_string(_font_bold, Vector2(13, 257), tr("Nombre"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, NAVY)
	if _glow_a > 0.0:

		var halo: = StyleBoxFlat.new()
		halo.bg_color = Color(1.0, 0.8, 0.3, 0.35 * _glow_a)
		halo.set_corner_radius_all(5)
		halo.shadow_color = Color(1.0, 0.76, 0.2, 0.45 * _glow_a)
		halo.shadow_size = 4
		halo.anti_aliasing = true
		draw_style_box(halo, NAME_BOX)
	var field: = StyleBoxFlat.new()
	field.bg_color = Color.WHITE
	field.border_color = UiStyles.HUD_RIM.lerp(Color(0.92, 0.66, 0.12), _glow_a)
	field.set_border_width_all(1)
	field.set_corner_radius_all(5)
	field.anti_aliasing = true
	draw_style_box(field, NAME_BOX)



	var shown_name: = str(look.get("name", "")).strip_edges()
	if shown_name == "":
		shown_name = tr("Aventurero")
	var fs: = 26
	while fs > 14 and _font_bold.get_string_size(shown_name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 210.0:
		fs -= 2
	var at: = Vector2(330, 282)
	draw_string(_font_bold, at + Vector2(1, 2), shown_name, HORIZONTAL_ALIGNMENT_CENTER, 220, fs, Color(1, 1, 1, 0.9))
	draw_string(_font_bold, at, shown_name, HORIZONTAL_ALIGNMENT_CENTER, 220, fs, Color(0.36, 0.45, 0.72))
	if GameData.CLASSES.has(class_id):
		var job: Dictionary = GameData.shown_job(class_id, look).get("job", {})

		var d: Dictionary = GameData.CLASSES[class_id]
		var seen: = tr(GameData.job_title(job, str(look.get("gender", "m")) == "f")) if job.has("name") else\
		tr(str(GameData.HIGH_NAMES.get(class_id, d.name)) if Save.is_reborn(class_id) else str(d.name))
		if seen != "":
			draw_string(_font, at + Vector2(0, 22), seen, HORIZONTAL_ALIGNMENT_CENTER, 220, 13, Color(0.42, 0.47, 0.62))
	draw_line(Vector2(8, SIZE.y - 30.5), Vector2(SIZE.x - 8, SIZE.y - 30.5), Color(0.84, 0.87, 0.95), 1.0)


func _process(delta: float) -> void :
	if _name_edit != null:
		var a: = 0.0
		if _name_edit.text.strip_edges() == "":
			_glow_t += delta
			a = 0.4 + 0.6 * (0.5 + 0.5 * sin(_glow_t * 2.6))
		if a != _glow_a:
			_glow_a = a
			queue_redraw()
	if _hold_button != null:
		if not is_instance_valid(_hold_button) or not _hold_button.is_pressed():
			_hold_button = null
		else:
			_hold_t -= delta
			while _hold_t <= 0.0:
				_hold_t += HOLD_EVERY
				_hold_call.call()


func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not event.is_pressed():
		return

	if event.is_action_pressed("ui_cancel"):
		cancelled.emit()
		get_viewport().set_input_as_handled()
		return
	if get_viewport().gui_get_focus_owner() is LineEdit:
		return
	if event.is_action_pressed("ui_accept"):
		_accept()
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		_step("hair", -1)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		_step("hair", 1)
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		_step("hair_color", 1)
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		_step("hair_color", -1)
	else:
		return
	get_viewport().set_input_as_handled()


func _draw() -> void :
	_draw_frame()
	if _sprite != null:
		var tex: = _sprite.get_frame(RoVisual.PC_IDLE * RoSprite.DIRS + _dir, 0)
		draw_texture(tex, (FEET - Vector2(_sprite.origin)).floor())
	var d: Dictionary = GameData.CLASSES[class_id]
	var stats: Dictionary = (d.get("stats", {}) as Dictionary).duplicate()
	for k in TABLE_STATS:
		stats[k] = int(stats.get(k, 0)) + int(_perm.get(k, 0)) + int(_pending.get(k, 0))
	var bonus: = Save.rebirth_stats(class_id)

	var pts: = PackedVector2Array()

	var top: = 4 + GameData.PERM_STAT_MAX + bonus
	for k in HEX_STATS:
		top = maxi(top, int(stats.get(k, 0)) + bonus + 1)
	for i in HEX_STATS.size():
		var v: = float(int(stats.get(HEX_STATS[i], 0)) + bonus + 1) / float(top)
		var a: = - PI / 2.0 + TAU * i / HEX_STATS.size()
		pts.append(HEX_CENTER + Vector2(cos(a), sin(a)) * HEX_RADIUS * clampf(v, 0.1, 1.0))
	draw_colored_polygon(pts, Color(0.35, 0.45, 0.85, 0.35))
	pts.append(pts[0])
	draw_polyline(pts, Color(0.25, 0.33, 0.7), 1.0)
	for r in TABLE_STATS.size():
		var v: int = int(stats.get(TABLE_STATS[r], 0)) + bonus
		var placed: = int(_pending.get(TABLE_STATS[r], 0))
		draw_string(_font, Vector2(462, 39 + r * 16 + 12), str(v), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 
			Color(0.1, 0.45, 0.15) if placed > 0 else Color.BLACK)

	var prog: Dictionary = Save.class_progress(class_id)
	draw_string(_font_bold, Vector2(409, 147), tr("Nv. de clase %d") % int(prog.level), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, NAVY)
	draw_string(_font, Vector2(409, 162), tr("Puntos libres: %d") % _points_left(), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 
		Color(0.75, 0.35, 0.05) if _points_left() > 0 else Color(0.27, 0.29, 0.37))

	var label: String = tr(str(GameData.HIGH_NAMES.get(class_id, d.name))) if Save.is_reborn(class_id) else tr(str(d.name))
	draw_string(_font_bold, Vector2(10, SIZE.y - 9), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, NAVY)
	if not Menus.touch_ui():
		draw_string(_font, Vector2(110, SIZE.y - 9), tr("←/→ peinado   ·   ↑/↓ color de pelo   ·   clic en un número para escribirlo"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 
			Color(0.27, 0.29, 0.37))
