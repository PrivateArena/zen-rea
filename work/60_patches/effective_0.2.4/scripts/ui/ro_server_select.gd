class_name RoServerSelect
extends Control




signal chosen(stage_id: String)
signal cancelled
signal selection_changed(stage_id: String)

signal modes_changed

const ROOT: = "res://assets/ro/ui/skin/login_interface/"


const SIZE: = Vector2(280, 148)
const TEX_SIZE: = Vector2(280, 120)

const STRIP_H: = 30.0
const LIST_Y: = 22

const ROW_H: = 12
const HIGHLIGHT: = Color(0.74, 0.81, 0.95)

var selected: = 0
var world: World
var _ids: Array = []
var _bg: Texture2D
var _font: Font = preload("res://assets/ro/fonts/SCDream4.otf")
var _font_bold: Font = preload("res://assets/ro/fonts/SCDream6.otf")
var _speed_button: TextureButton
var _hard_button: TextureButton


func _ready() -> void :
	custom_minimum_size = SIZE
	size = SIZE
	texture_filter = RoAssets.ui_filter()
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	_bg = Lang.ui_tex(ROOT + "win_service.png")
	_ids = GameData.STAGES.keys()
	selected = maxi(0, _ids.find(world.stage_id))
	if world.newly_unlocked != "" and _ids.has(world.newly_unlocked):
		selected = _ids.find(world.newly_unlocked)
	_speed_button = _add_button("btn_speed", Vector2(SIZE.x - 146, SIZE.y - 24), _toggle_fast)
	_hard_button = _add_button("btn_hard", Vector2.ZERO, _toggle_hard)
	var hard_w: = float(_hard_button.texture_normal.get_width()) if _hard_button.texture_normal != null else 42.0
	_hard_button.position = Vector2(SIZE.x - 150 - hard_w, SIZE.y - 24)
	_refresh_speed()
	selection_changed.connect( func(_id): _refresh_speed())
	_add_button("btn_ok", Vector2(SIZE.x - 98, SIZE.y - 24), _confirm)
	_add_button("btn_cancel", Vector2(SIZE.x - 50, SIZE.y - 24), func(): cancelled.emit())



func _refresh_speed() -> void :
	var cleared: = Save.is_stage_cleared(_ids[selected])
	if _speed_button != null:
		_speed_button.visible = true
		var sp: = speed_on(world.speed, cleared)
		_speed_button.modulate = (Color(1.0, 0.6, 0.35) if sp >= 3 else Color(1.0, 0.9, 0.55)) if world.fast_mode else Color.WHITE
		_speed_button.tooltip_text = speed_tip()
		if _speed_tag == null:
			_speed_tag = Label.new()
			_speed_tag.add_theme_font_size_override("font_size", 9)
			_speed_tag.add_theme_color_override("font_color", Color(0.75, 0.15, 0.05))
			_speed_tag.add_theme_color_override("font_outline_color", Color.WHITE)
			_speed_tag.add_theme_constant_override("outline_size", 3)
			_speed_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_speed_button.add_child(_speed_tag)
			_speed_tag.position = Vector2(2, -12)
		_speed_tag.text = "x2" if sp >= 3 else ("x%s" % str(GameData.FRENZY_SPEED) if world.fast_mode else "")
	if _hard_button != null:
		_hard_button.visible = cleared
		_hard_button.modulate = Color(1.0, 0.55, 0.5) if world.hard_mode else Color.WHITE


func _add_button(tex: String, at: Vector2, callback: Callable) -> TextureButton:
	var b: = TextureButton.new()


	var t: = Lang.ui_tex(ROOT + tex + ".png")
	if t != null:
		b.texture_normal = t
	b.position = at
	b.texture_filter = RoAssets.ui_filter()
	b.pressed.connect(callback)
	add_child(b)
	return b


var _speed_tag: Label





static func speed_on(speed: int, _cleared: = true) -> int:
	return mini(speed, 3)



static func next_speed(speed: int, _cleared: = true) -> int:
	return speed_on(speed) % 3 + 1



static func speed_label(speed: int, cleared: = true) -> String:
	var now: = speed_on(speed, cleared)
	if now >= 3:
		return TranslationServer.translate("Frenesí x2 ✓")
	if now == 2:
		return TranslationServer.translate("Frenesí ✓  (otra vez: x2)")
	return TranslationServer.translate("Frenesí")




static func frenzy_pips(b: Button, speed: int) -> void :
	var old: = b.get_node_or_null("Pips")
	if old != null:
		b.remove_child(old)
		old.queue_free()
	var pips: = HBoxContainer.new()
	pips.name = "Pips"
	pips.add_theme_constant_override("separation", 3)
	pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pips.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	pips.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	pips.grow_vertical = Control.GROW_DIRECTION_BOTH
	pips.position.x -= 10
	var lit: = speed_on(speed) - 1
	for i in 2:
		var box: = Panel.new()
		box.custom_minimum_size = Vector2(6, 15)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var st: = StyleBoxFlat.new()
		st.set_corner_radius_all(2)
		st.set_border_width_all(1)
		st.border_color = Color(0.8, 0.3, 0.15)
		st.bg_color = Color(0.85, 0.35, 0.15) if i < lit else Color(1, 1, 1, 0.0)
		box.add_theme_stylebox_override("panel", st)
		pips.add_child(box)
	b.add_child(pips)


static func speed_tip() -> String:
	return TranslationServer.translate("Frenesí: la partida entera se acelera x%s. Ganas +%d%% de zeny y +15%% de puntos en los récords.") % [
		str(GameData.FRENZY_SPEED), roundi(GameData.FRENZY_ZENY * 100.0)] + "\n" + \
		TranslationServer.translate("Púlsalo otra vez para Frenesí x2: todo al doble de rápido, con los mismos premios. Las peleas con MVP, Valquirias y Satan Morroc van a velocidad normal. No se cambia en plena partida.")



func _toggle_fast() -> void :
	if true:

		world.speed = next_speed(world.speed, Save.is_stage_cleared(_ids[selected]))
		world.menus.ui_click()
		_refresh_speed()
		queue_redraw()
		modes_changed.emit()



func _toggle_hard() -> void :
	if Save.is_stage_cleared(_ids[selected]):
		world.hard_mode = not world.hard_mode
		world.menus.ui_click()
		_refresh_speed()
		queue_redraw()
		modes_changed.emit()


func _confirm() -> void :
	var id: String = _ids[selected]
	if world.is_stage_unlocked(id) and world.is_stage_exported(id):
		world.menus.ui_click()
		chosen.emit(id)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var row: = int((event.position.y - LIST_Y) / ROW_H)
		if event.position.y >= LIST_Y and row >= 0 and row < _ids.size():
			if row == selected and event.double_click:
				_confirm()
			if row != selected:
				world.menus.ui_nav()
			selected = row
			selection_changed.emit(_ids[selected])
			queue_redraw()
			accept_event()


func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not event.is_pressed():
		return
	if event.is_action_pressed("ui_up") or event.is_action_pressed("move_up"):
		selected = posmod(selected - 1, _ids.size())
		world.menus.ui_nav()
	elif event.is_action_pressed("ui_down") or event.is_action_pressed("move_down"):
		selected = posmod(selected + 1, _ids.size())
		world.menus.ui_nav()
	elif event.is_action_pressed("ui_accept"):
		_confirm()
	elif event is InputEventKey and event.keycode == KEY_X:
		_toggle_fast()
	elif event is InputEventKey and event.keycode == KEY_H:
		_toggle_hard()
	elif event.is_action_pressed("ui_cancel"):
		cancelled.emit()
	else:
		return
	selection_changed.emit(_ids[selected])
	queue_redraw()
	get_viewport().set_input_as_handled()


func _draw() -> void :
	if _bg != null:
		var top_h: = TEX_SIZE.y - STRIP_H
		draw_texture_rect_region(_bg, Rect2(0, 0, SIZE.x, top_h), Rect2(0, 0, TEX_SIZE.x, top_h))
		draw_texture_rect_region(_bg, Rect2(0, top_h, SIZE.x, SIZE.y - TEX_SIZE.y), Rect2(0, top_h - 1, TEX_SIZE.x, 1))
		draw_texture_rect_region(_bg, Rect2(0, SIZE.y - STRIP_H, SIZE.x, STRIP_H), Rect2(0, top_h, TEX_SIZE.x, STRIP_H))
	else:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color.WHITE)
	for i in _ids.size():
		var id: String = _ids[i]
		var st: Dictionary = GameData.STAGES[id]
		var y: = LIST_Y + i * ROW_H
		if i == selected:
			draw_rect(Rect2(4, y, SIZE.x - 8, ROW_H), HIGHLIGHT)
		var unlocked: = world.is_stage_unlocked(id) and world.is_stage_exported(id)
		var color: = Color.BLACK if unlocked else Color(0.55, 0.55, 0.6)
		var stage_name: = tr(str(st.name))
		draw_string(_font_bold, Vector2(10, y + 10), stage_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, color)
		var info: String = "(%s)" % st.map if unlocked else (tr("(bloqueado)") if world.is_stage_exported(id) else tr("(sin exportar)"))
		if Save.is_stage_cleared(id):
			var tags: Array[String] = []
			if i == selected and world.hard_mode:
				tags.append(tr("Difícil"))
			if i == selected and world.fast_mode:
				tags.append(tr("Frenesí x2") if speed_on(world.speed, true) >= 3 else tr("Frenesí"))
			tags.append(tr("MVP★") if Save.is_stage_hard_cleared(id) else "MVP")
			info = "%s  %s" % ["  ·  ".join(tags), info]
		draw_string(_font, Vector2(10, y + 10), info, HORIZONTAL_ALIGNMENT_RIGHT, SIZE.x - 20, 9, color)

	var sel: Dictionary = GameData.STAGES[_ids[selected]]
	var note: String = tr(str(sel.desc))
	if not world.is_stage_exported(_ids[selected]):
		note = tr("Exporta el mapa %s con tools/export_assets.py.") % sel.map
	elif not world.is_stage_unlocked(_ids[selected]):
		note = tr("Derrota al MVP de %s.") % tr(GameData.STAGES[sel.unlock].name)
	elif Save.is_stage_cleared(_ids[selected]) and not MouseWalk.touch():
		note = tr("X: x2  ·  H: difícil")
	var note_w: = SIZE.x - 156.0 - ((_hard_button.texture_normal.get_width() + 4.0) if _hard_button.visible and _hard_button.texture_normal != null else 0.0)
	draw_string(_font, Vector2(8, SIZE.y - 10), note, HORIZONTAL_ALIGNMENT_LEFT, note_w, 9, Color(0.2, 0.22, 0.3))
