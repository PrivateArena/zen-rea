class_name RoCharSelect
extends Control





signal chosen(class_id: String)
signal cancelled


signal town_pressed(class_id: String)
signal album_pressed
signal style_pressed(class_id: String)
signal gear_pressed(class_id: String)
signal friends_pressed

var world: World

const ROOT: = "res://assets/ro/ui/skin/login_interface/"
const SIZE: = Vector2(576, 358)
const SLOT_X: = [61, 223, 386]
const SLOT_Y: = 43
const SLOT_SIZE: = Vector2(130, 137)

const FEET_Y: = 160

const AURA_INSET: = 3.0
const ROW_Y: = [211, 227, 243, 259, 275, 291, 307]
const LEFT_VALUE_X: = 70
const RIGHT_VALUE_X: = 214
const STATS: = ["str", "agi", "vit", "int", "dex", "luk"]

var selected: = 0


static var last_id: = ""

var _style_button: Button

var _album_button: Button

var _town_button: Button

var friends_button: Button

var _unlock_button: Button


var _ok_button: Button
var _cancel_button: Button
var _buy_box: Control


var _rail: = false
var _gear_button: Button

var _strip_x: = 240.0
var _notice: = ""
var _notice_time: = 0.0
var _page_buttons: Array[Button] = []


var _move_buttons: Array[Button] = []
var _ids: Array = []
var _sprites: Array = []
var _frame: = 0
var _anim_time: = 0.0
var _tex: = {}
var _font: Font = preload("res://assets/ro/fonts/SCDream4.otf")
var _font_bold: Font = preload("res://assets/ro/fonts/SCDream6.otf")
var _coin_icon: TextureRect


func _ready() -> void :
	custom_minimum_size = SIZE
	size = SIZE
	texture_filter = RoAssets.ui_filter()
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	for n in ["win_select2", "box_select"]:
		var path: String = ROOT + n + ".png"
		_tex[n] = Lang.ui_tex(path)

	_ids = GameData.CLASSES.keys().filter( func(id): return Save.class_unlocked(id)) + GameData.CLASSES.keys().filter( func(id): return not Save.class_unlocked(id))
	_apply_order()
	for id in _ids:
		var d: Dictionary = GameData.CLASSES[id]
		var gear: = Equipment.loadout_views(id)
		var shown: Dictionary = GameData.shown_job(id, Save.look(id))
		_sprites.append(RoAssets.styled_character(shown.body, shown.weapon, shown.weapon_fx, 
			[shown.attack], gear.head, Save.look(id), "", gear.extras))
	var cancel: = _add_button("btn_cancel", Vector2.ZERO, func(): cancelled.emit())
	cancel.position = Vector2(SIZE.x - 8 - _button_w(cancel), SIZE.y - 24)
	var ok: = _add_button("btn_ok", Vector2.ZERO, func(): _try_play(str(_ids[selected])))
	ok.position = Vector2(cancel.position.x - 4 - _button_w(ok), SIZE.y - 24)
	_ok_x = ok.position.x
	_ok_button = ok
	_cancel_button = cancel


	var town: = _add_button("btn_town", Vector2.ZERO, _try_town)
	_town_button = town
	_album_button = _add_button("btn_album", Vector2.ZERO, func(): album_pressed.emit())

	_style_button = _add_button("btn_style", Vector2.ZERO, func(): style_pressed.emit(str(_ids[selected])))
	_unlock_button = _add_button("btn_unlock", Vector2.ZERO, _buy_selected)

	var gear: = _add_button("btn_gear", Vector2.ZERO, func(): gear_pressed.emit(str(_ids[selected])))
	_gear_button = gear
	friends_button = _add_button("btn_friends", Vector2.ZERO, func(): friends_pressed.emit())
	var x: = 8.0
	for b: Button in [town, _album_button, _style_button, gear, friends_button, _unlock_button]:
		b.position = Vector2(x, SIZE.y - 24)
		x += _button_w(b) + 4.0
	_strip_x = x

	_page_buttons.append(_add_button("btn_back", Vector2(18, 100), func(): select(posmod(_page() - 1, _pages()) * SLOT_X.size())))
	_page_buttons.append(_add_button("btn_next", Vector2(SIZE.x - 48, 100), func(): select(posmod(_page() + 1, _pages()) * SLOT_X.size())))
	for b in _page_buttons:
		b.visible = _pages() > 1




	var touch: = Menus.touch_ui()
	for d in [-1, 1]:
		var step: int = d
		var mb: = _add_button("◀" if d < 0 else "▶", Vector2.ZERO, func(): _move_selected(step))
		mb.tooltip_text = tr("Mover a la izquierda") if d < 0 else tr("Mover a la derecha")
		mb.add_theme_font_size_override("font_size", 15 if touch else 10)
		for st in ["normal", "hover", "pressed"]:
			var box: = StyleBoxFlat.new()
			box.bg_color = {"normal": Color(0.93, 0.95, 1.0), "hover": Color(0.86, 0.9, 1.0), "pressed": Color(0.4, 0.54, 0.9)}[st]
			box.border_color = Color(0.45, 0.58, 0.9)
			box.set_border_width_all(1)
			box.set_corner_radius_all(7)
			box.anti_aliasing = true
			box.shadow_color = Color(0.05, 0.1, 0.3, 0.3)
			box.shadow_size = 2
			mb.add_theme_stylebox_override(st, box)
		for c in ["font_color", "font_hover_color", "font_focus_color"]:
			mb.add_theme_color_override(c, Color(0.3, 0.45, 0.85))
		mb.add_theme_color_override("font_pressed_color", Color.WHITE)
		mb.custom_minimum_size = Vector2(38, 30) if touch else Vector2(24, 19)
		mb.size = mb.get_combined_minimum_size()

		mb.z_index = 10
		_move_buttons.append(mb)
	_place_move_buttons()
	_update_rebirth_button()


func _page() -> int:
	return selected / SLOT_X.size()


func _pages() -> int:
	return ceili(_ids.size() / float(SLOT_X.size()))



func _slot_index(i: int) -> int:
	var idx: = _page() * SLOT_X.size() + i
	return idx if idx < _ids.size() else -1


const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")

var _ok_x: = SIZE.x - 112.0



func _add_button(tex: String, at: Vector2, callback: Callable) -> Button:
	var names: = {"btn_ok": tr("OK"), "btn_cancel": tr("Cancelar"), "btn_town": tr("Prontera"), "btn_album": tr("Álbum"), 
		"btn_style": tr("Perfil"), "btn_unlock": tr("Comprar"), "btn_gear": tr("Equipo"), "btn_friends": tr("Amigos"), "btn_back": "◀", "btn_next": "▶"}
	var b: = Button.new()
	b.set_meta("key", tex)
	b.text = str(names.get(tex, tex))
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
	b.add_theme_color_override("font_pressed_color", Color(0.2, 0.32, 0.72))
	b.custom_minimum_size = Vector2(30, 20)
	b.position = at
	b.pressed.connect(callback)
	add_child(b)
	b.size = b.get_combined_minimum_size()
	return b




func set_friends(online: int, requests: int) -> void :
	if friends_button == null:
		return
	friends_button.text = tr("Amigos") + ("  ·  %d" % online if online > 0 else "")
	var col: = Color(0.75, 0.45, 0.0) if requests > 0 else UiStyles.HUD_TITLE_TEXT
	friends_button.add_theme_color_override("font_color", col)
	friends_button.tooltip_text = tr_n("%d solicitud de amistad", "%d solicitudes de amistad", requests) % requests if requests > 0 else ""
	friends_button.size = friends_button.get_combined_minimum_size()

	var x: = friends_button.position.x + friends_button.size.x + 4.0
	if _unlock_button != null:
		_unlock_button.position.x = x
		x += _button_w(_unlock_button) + 4.0

	if not _rail:
		_strip_x = x
	queue_redraw()





func use_rail() -> void :
	_rail = true
	for b in [_town_button, _album_button, _style_button, _gear_button, friends_button, _unlock_button]:
		if b != null:
			b.visible = false
	_strip_x = 8.0
	queue_redraw()



func town_hint() -> bool:
	return _town_hint()


func _town_hint() -> bool:
	return bool(Save.setting("town_hint", false)) and not bool(Save.setting("town_visited", false))




func _rebirth_hint() -> bool:
	if _ids.is_empty():
		return false
	var id: = str(_ids[selected])
	return Save.class_unlocked(id) and (Save.can_rebirth(id) or Save.rebirth_lv_ready(id))


func _button_w(b: Button) -> float:
	return b.get_combined_minimum_size().x



func _update_rebirth_button() -> void :
	if _unlock_button != null and not _ids.is_empty():
		_unlock_button.visible = not _rail and not Save.class_unlocked(str(_ids[selected]))

	if _ok_button != null and not _ids.is_empty():
		_ok_button.text = tr("OK") if Save.class_unlocked(str(_ids[selected])) else tr("Comprar")
		_ok_button.size = _ok_button.get_combined_minimum_size()
		_ok_button.position.x = _cancel_button.position.x - 4 - _ok_button.size.x
		_ok_x = _ok_button.position.x



func _try_town() -> void :
	var id: = str(_ids[selected])
	if Save.class_unlocked(id):
		if world != null:
			world.menus.ui_click()
		town_pressed.emit(id)
	else:
		_try_play(id)



func _try_play(id: String) -> void :
	if Save.class_unlocked(id):
		if world != null:
			world.menus.ui_click()
		chosen.emit(id)
	else:

		_open_buy(id)




func _open_buy(id: String) -> void :
	_close_buy()
	if world != null:
		world.menus.ui_click()
	var cost: = int(GameData.CLASSES[id].unlock_cost)
	var can: = Save.zeny() >= cost
	var box: = PanelContainer.new()
	var st: = StyleBoxFlat.new()
	st.bg_color = Color(0.97, 0.98, 1.0)
	st.border_color = Color(0.55, 0.64, 0.88)
	st.set_border_width_all(1)
	st.set_corner_radius_all(6)
	st.anti_aliasing = true
	st.shadow_color = Color(0.05, 0.1, 0.3, 0.3)
	st.shadow_size = 6
	st.set_content_margin_all(10)
	box.add_theme_stylebox_override("panel", st)
	box.z_index = 20
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	box.add_child(col)
	var title: = Label.new()
	title.text = tr("Desbloquear a %s") % tr(GameData.CLASSES[id].name)
	title.add_theme_font_override("font", _font_bold)
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(0.2, 0.28, 0.6))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var price: = Label.new()
	price.text = tr("Precio: %s z") % RoBasicWindow._thousands(cost) + "    " + tr("Tienes: %s z") % RoBasicWindow._thousands(Save.zeny())
	price.add_theme_font_override("font", _font)
	price.add_theme_font_size_override("font_size", 11)
	price.add_theme_color_override("font_color", Color(0.2, 0.22, 0.3) if can else Color(0.75, 0.2, 0.1))
	price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(price)
	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	col.add_child(row)
	var buy: = _add_button("btn_unlock", Vector2.ZERO, func():
		_close_buy()
		_buy_selected())
	buy.disabled = not can
	buy.get_parent().remove_child(buy)
	row.add_child(buy)
	var no: = _add_button("btn_cancel", Vector2.ZERO, _close_buy)
	no.get_parent().remove_child(no)
	row.add_child(no)
	add_child(box)
	box.size = box.get_combined_minimum_size()
	box.position = ((SIZE - box.size) * 0.5).floor()
	_buy_box = box


func _close_buy() -> void :
	if _buy_box != null and is_instance_valid(_buy_box):
		_buy_box.queue_free()
	_buy_box = null


func _buy_selected() -> void :
	var id: = str(_ids[selected])
	if Save.unlock_class(id):
		_show_notice(tr("¡%s desbloqueado!") % tr(GameData.CLASSES[id].name))
		_update_rebirth_button()
		_place_move_buttons()
		queue_redraw()
	else:
		_show_notice(tr("Zeny insuficiente: necesitas %s z.") % RoBasicWindow._thousands(int(GameData.CLASSES[id].unlock_cost)))


func _show_notice(text: String) -> void :
	_notice = text
	_notice_time = 2.5
	queue_redraw()


func _process(delta: float) -> void :
	if _notice_time > 0.0:
		_notice_time -= delta
		if _notice_time <= 0.0:
			queue_redraw()
	if _town_button != null and _town_hint():
		var t: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)
		_town_button.modulate = Color.WHITE.lerp(Color(1.4, 1.25, 0.7), t)
		queue_redraw()
	elif _town_button != null and _rebirth_hint():

		var t: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.005)
		_town_button.modulate = Color.WHITE.lerp(Color(1.22, 1.14, 0.82), t)
		queue_redraw()
	elif _town_button != null and _town_button.modulate != Color.WHITE:
		_town_button.modulate = Color.WHITE
		queue_redraw()

	for i in SLOT_X.size():
		var idx: = _slot_index(i)
		if idx >= 0 and _glows(str(_ids[idx])):
			queue_redraw()
			break
	if _style_button != null and not _ids.is_empty():
		var glow: = Save.free_points(str(_ids[selected])) > 0
		_style_button.modulate = Color(1.0, 0.92, 0.6).lerp(Color(1.25, 1.15, 0.75), 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006)) if glow else Color.WHITE
		_style_button.tooltip_text = tr("Tienes %d puntos de atributo sin asignar") % Save.free_points(str(_ids[selected])) if glow else ""
	if _album_button != null:

		var ready: = Save.fusible_count()
		var claims: = Save.unclaimed_achievements().size()
		_album_button.modulate = Color(1.0, 0.92, 0.6).lerp(Color(1.25, 1.15, 0.75), 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006))\
		if ready + claims > 0 else Color.WHITE
		var tips: Array[String] = []
		if ready > 0:
			tips.append(tr("¡%d cartas listas para fundir en Cartas Eternas!") % ready)
		if claims > 0:
			tips.append(tr_n("¡%d logro por reclamar!", "¡%d logros por reclamar!", claims) % claims)
		_album_button.tooltip_text = "\n".join(tips)

	var ro: RoSprite = _sprites[selected] if selected < _sprites.size() else null
	if ro == null:
		return
	_anim_time += delta
	var action: = RoVisual.PC_WALK * RoSprite.DIRS
	var delay: = ro.frame_delay(action)
	if _anim_time >= delay:
		_anim_time -= delay
		_frame = (_frame + 1) % maxi(1, ro.frame_count(action))
		queue_redraw()



func select_class(id: String) -> void :
	var i: = _ids.find(id)
	if i >= 0:
		select(i)
		last_id = id


func select(index: int) -> void :
	index = posmod(index, _ids.size())
	last_id = str(_ids[index])
	if index != selected:
		selected = index
		_frame = 0
		_close_buy()
		if world != null:
			world.menus.ui_nav()
		_update_rebirth_button()
		queue_redraw()
	_place_move_buttons()




func _apply_order() -> void :
	var order: Array = Save.setting("class_order", [])
	var open: = _ids.filter( func(id): return Save.class_unlocked(id))
	var rest: = _ids.filter( func(id): return not Save.class_unlocked(id))
	var key: = {}
	for i in open.size():
		var at: = order.find(str(open[i]))
		key[open[i]] = (at if at >= 0 else order.size()) * 1000 + i
	open.sort_custom( func(a, b): return int(key[a]) < int(key[b]))
	_ids = open + rest





func _place_move_buttons() -> void :
	if _move_buttons.size() < 2 or _ids.is_empty():
		return
	var i: = selected % SLOT_X.size()
	var open: = Save.class_unlocked(str(_ids[selected]))
	var y: = SLOT_Y + SLOT_SIZE.y - 4.0 - _move_buttons[0].size.y
	_move_buttons[0].position = Vector2(SLOT_X[i] + 4.0, y)
	_move_buttons[1].position = Vector2(SLOT_X[i] + SLOT_SIZE.x - 4.0 - _move_buttons[1].size.x, y)
	_move_buttons[0].visible = open
	_move_buttons[1].visible = open
	_move_buttons[0].disabled = selected <= 0
	_move_buttons[1].disabled = selected + 1 >= _ids.size() or not Save.class_unlocked(str(_ids[selected + 1]))



func _move_selected(step: int) -> void :
	var j: = selected + step
	if j < 0 or j >= _ids.size() or not Save.class_unlocked(str(_ids[j])) or not Save.class_unlocked(str(_ids[selected])):
		return
	var t = _ids[j]
	_ids[j] = _ids[selected]
	_ids[selected] = t
	var sp = _sprites[j]
	_sprites[j] = _sprites[selected]
	_sprites[selected] = sp
	Save.set_setting("class_order", _ids.filter( func(id): return Save.class_unlocked(id)))
	if world != null:
		world.menus.ui_click()
	select(j)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in SLOT_X.size():
			var idx: = _slot_index(i)
			if idx >= 0 and Rect2(Vector2(SLOT_X[i], SLOT_Y), SLOT_SIZE).has_point(event.position):
				if idx == selected and event.double_click:
					_try_play(str(_ids[idx]))
				select(idx)
				accept_event()
				return


func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not event.is_pressed():
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		select(selected - 1)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		select(selected + 1)
	elif event.is_action_pressed("ui_accept"):


		if _buy_box != null and is_instance_valid(_buy_box):
			_close_buy()
			_buy_selected()
		else:
			_try_play(str(_ids[selected]))
	elif event.is_action_pressed("ui_cancel"):

		if _buy_box != null and is_instance_valid(_buy_box):
			_close_buy()
		else:
			cancelled.emit()
	else:
		for i in SLOT_X.size():
			var idx: = _slot_index(i)
			if idx >= 0 and event.is_action_pressed("pick_%d" % (i + 1)):
				if idx == selected:
					_try_play(str(_ids[idx]))
				select(idx)
	get_viewport().set_input_as_handled()




var _previews: = {}



var _aura_rects: Array[TextureRect] = []
var _flair_rects: Array[TextureRect] = []


var _front: Control
var _front_draws: Array = []




func _glows(id: String) -> bool:
	return RebirthAura.earned(id) or not Save.rebirth_looks(id).is_empty()


func _preview(looks: Array, part: String, height: float, with_aura: = true) -> RebirthAura.Preview:
	var key: = "%s|%s|%d|%s" % [part, ",".join(looks), roundi(height * 20.0), with_aura]
	if not _previews.has(key):
		_previews[key] = RebirthAura.Preview.new(looks, part, height, with_aura)
		add_child(_previews[key])
	return _previews[key]




func _aura_rect() -> TextureRect:
	var clip: = Control.new()
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.clip_contents = true
	clip.size = SLOT_SIZE - Vector2(AURA_INSET, AURA_INSET) * 2.0
	add_child(clip)
	var r: = TextureRect.new()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(r)
	return r


func _show_aura(r: TextureRect, feet: Vector2, preview: SubViewport) -> void :
	var clip: Control = r.get_parent()
	r.texture = preview.get_texture()
	r.material = (preview as RebirthAura.Preview).ui_material()
	clip.position = Vector2(feet.x - SLOT_SIZE.x * 0.5 + AURA_INSET, SLOT_Y + AURA_INSET).floor()
	r.position = (feet - RebirthAura.Preview.FEET).floor() - clip.position



func _place_auras(slots: Array, front: Array) -> void :
	if _front == null:
		_front = Control.new()
		_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_front.size = SIZE
		_front.texture_filter = RoAssets.ui_filter()
		_front.draw.connect( func():
			for d in _front_draws:
				if d is Callable:
					d.call()
				else:
					_front.draw_texture(d[0], d[1]))
		add_child(_front)
	_front_draws = front
	while _aura_rects.size() < slots.size():
		_aura_rects.append(_aura_rect())
		_flair_rects.append(_aura_rect())
	for i in _aura_rects.size():
		var shown: = i < slots.size()
		var in_front: = false
		if shown:
			var feet: Vector2 = slots[i][0]
			var looks: = Save.rebirth_looks(str(slots[i][1]))
			var height: = float(slots[i][2])
			_show_aura(_aura_rects[i], feet, _preview(looks, "back", height, RebirthAura.earned(str(slots[i][1]))))

			for id in looks:
				if not RebirthFlair.BEHIND.has(id):
					in_front = true
					_show_aura(_flair_rects[i], feet, _preview(looks, "front", height))
					break

		if _aura_rects[i].get_parent().visible != shown:
			_aura_rects[i].get_parent().visible = shown
		if _flair_rects[i].get_parent().visible != in_front:
			_flair_rects[i].get_parent().visible = in_front



	var on_top: Array[Node] = [_front]
	for r in _flair_rects:
		on_top.append(r.get_parent())
	for k in on_top.size():
		var at: = get_child_count() - on_top.size() + k
		if on_top[k].get_index() != at:
			move_child(on_top[k], at)
	_front.queue_redraw()


func _draw() -> void :
	var aura_slots: Array = []
	var front: Array = []
	_draw_frame()
	for i in SLOT_X.size():
		var idx: = _slot_index(i)
		if idx < 0:
			continue
		var ro: RoSprite = _sprites[idx]
		var feet: = Vector2(SLOT_X[i] + SLOT_SIZE.x * 0.5, FEET_Y)
		if ro != null:
			var action: = (RoVisual.PC_WALK if idx == selected else RoVisual.PC_IDLE) * RoSprite.DIRS
			var tex: = ro.get_frame(action, _frame if idx == selected else 0)

			var locked: = not Save.class_unlocked(str(_ids[idx]))



			if not locked and _glows(str(_ids[idx])):
				aura_slots.append([feet, str(_ids[idx]), ro.origin.y * GameData.PIXEL_SIZE])
				front.append([tex, (feet - Vector2(ro.origin)).floor()])
			else:
				draw_texture(tex, (feet - Vector2(ro.origin)).floor(), Color(0.12, 0.14, 0.22, 0.9) if locked else Color.WHITE)
			if locked:
				draw_string(_font_bold, Vector2(SLOT_X[i], SLOT_Y + 32), "%s z" % RoBasicWindow._thousands(int(GameData.CLASSES[_ids[idx]].unlock_cost)), 
					HORIZONTAL_ALIGNMENT_CENTER, SLOT_SIZE.x, 11, Color(0.75, 0.35, 0.05))
		else:
			draw_circle(feet - Vector2(0, 30), 20, GameData.CLASSES[_ids[idx]].color)

		draw_string(_font_bold, Vector2(SLOT_X[i], SLOT_Y + SLOT_SIZE.y + 15), _class_label(str(_ids[idx])), 
			HORIZONTAL_ALIGNMENT_CENTER, SLOT_SIZE.x, 11, Color(0.2, 0.25, 0.45))


		var badge_at: = Vector2(SLOT_X[i] + SLOT_SIZE.x * 0.5, SLOT_Y + 15)
		var rlv: = Save.rebirth_lv(str(_ids[idx]))
		if rlv > 0:
			front.append( func(): draw_rebirth_badge(_front, _font_bold, badge_at, rlv))
	_place_auras.call_deferred(aura_slots, front)
	if _pages() > 1:
		draw_string(_font_bold, Vector2(12, 134), "%d / %d" % [_page() + 1, _pages()], 
			HORIZONTAL_ALIGNMENT_CENTER, 42, 11, Color(0.2, 0.25, 0.45))

	var id: String = _ids[selected]
	var d: Dictionary = GameData.CLASSES[id]
	var best: Dictionary = Save.best(id)
	var record: = (tr("Récord %s MVP") if best.victory else tr("Récord %s")) % UiKit.time_text(best.time)\
	if best.time > 0.0 else tr("Sin récord")
	var prog: Dictionary = Save.class_progress(id)
	var lv: = int(prog.level)
	var exp_text: = "%.1f %%" % (100.0 * float(prog.xp) / Save.class_xp_need(id, lv))\
	if lv < Save.class_max_level(id) else tr("MAX")
	var map_name: String = world.stage.map if world != null else "prt_fild08"
	var class_label: = _class_label(id)
	var left: = [Save.char_name(id), class_label, str(lv), exp_text, "%d" % d.hp, "-", map_name]
	for r in left.size():

		var gold: = r == 0 and Save.rebirth_looks(id).has("valhalla")
		_text(Vector2(LEFT_VALUE_X, ROW_Y[r] + 4), str(left[r]), GameData.REBIRTH_LV_GOLD.darkened(0.25) if gold else Color.BLACK, 11, gold)
	var stats: Dictionary = d.get("stats", {})
	var perm: Dictionary = Save.class_stats(id)
	for r in STATS.size():
		var v: int = int(stats.get(STATS[r], 0)) + Save.rebirth_stats(id) + int(perm.get(STATS[r], 0))
		_text(Vector2(RIGHT_VALUE_X, ROW_Y[r] + 4), str(v), Color.BLACK, 11)

	var free: = Save.free_points(id)
	_text(Vector2(RIGHT_VALUE_X - 50, ROW_Y[6] + 4), tr("Puntos libres: %d") % free, 
		Color(0.75, 0.4, 0.05) if free > 0 else Color(0.35, 0.37, 0.45), 10, free > 0)


	var won: bool = best.time > 0.0 and best.victory
	var rw: = _font_bold.get_string_size(record, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 20.0
	var pill: = StyleBoxFlat.new()
	pill.bg_color = Color(1.0, 0.97, 0.86) if won else Color(0.93, 0.945, 0.99)
	pill.border_color = Color(0.86, 0.66, 0.25) if won else Color(0.78, 0.82, 0.93)
	pill.set_border_width_all(1)
	pill.set_corner_radius_all(8)
	pill.anti_aliasing = true
	draw_style_box(pill, Rect2(roundf(440.0 - rw * 0.5), 210, rw, 17))
	draw_string(_font_bold, Vector2(330, 222), record, HORIZONTAL_ALIGNMENT_CENTER, 220, 10, 
		Color(0.55, 0.34, 0.02) if won else Color(0.3, 0.36, 0.58))

	var strip_x: = _strip_x if _rail or _unlock_button.visible else _strip_x - _button_w(_unlock_button) - 4.0

	var strip_w: = _ok_x - 4.0 - strip_x
	if _notice_time > 0.0:
		_text(Vector2(strip_x, SIZE.y - 9), _fit(_notice, strip_w), Color(0.7, 0.2, 0.1), 10)
	elif not Save.class_unlocked(id):
		_text(Vector2(strip_x, SIZE.y - 9), _fit(tr("Bloqueado  ·  %s z para desbloquear") % RoBasicWindow._thousands(int(d.unlock_cost)), strip_w), 
			Color(0.7, 0.35, 0.05), 10)
	if (_town_hint() or _rebirth_hint()) and _town_button != null and _town_button.visible:

		var bob: = 2.0 * sin(Time.get_ticks_msec() * 0.006) if _town_hint() else 1.0 * sin(Time.get_ticks_msec() * 0.004)
		var text: = tr("¡Mejora a tus héroes en Prontera!") if _town_hint() else tr("¡Puedes renacer!")
		var w: = _font_bold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 14.0
		var at: = Vector2(_town_button.position.x, _town_button.position.y - 24 + bob)
		var bub: = StyleBoxFlat.new()
		bub.bg_color = Color(1, 0.97, 0.85)
		bub.border_color = Color(0.85, 0.6, 0.2)
		bub.set_border_width_all(1)
		bub.set_corner_radius_all(6)
		bub.anti_aliasing = true
		draw_style_box(bub, Rect2(at, Vector2(w, 18)))
		draw_colored_polygon(PackedVector2Array([at + Vector2(14, 18), at + Vector2(24, 18), at + Vector2(16, 24)]), Color(1, 0.97, 0.85))
		draw_string(_font_bold, at + Vector2(7, 13), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.45, 0.25, 0.05))

	var coins: = "%d" % Save.coins()
	var cw: = _font_bold.get_string_size(coins, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	draw_string(_font_bold, Vector2(SIZE.x - 10 - cw, SIZE.y - 34), coins, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.55, 0.32, 0.0))
	if _coin_icon == null:
		_coin_icon = UiKit.icon_rect(Achievements.coin_icon(), 18)
		_coin_icon.size = Vector2(18, 18)
		_coin_icon.tooltip_text = tr("Poring Coins: moneda especial de los logros.")
		_coin_icon.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(_coin_icon)
	_coin_icon.position = Vector2(SIZE.x - 30 - cw, SIZE.y - 47)
	draw_string(_font_bold, Vector2(SIZE.x - 336 - cw, SIZE.y - 34), tr("Zeny : %s") % RoBasicWindow._thousands(Save.zeny()), 
		HORIZONTAL_ALIGNMENT_RIGHT, 300, 11, Color.BLACK)





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
	draw_string(_font_bold, Vector2(10, 14), tr("Selección de personaje"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, UiStyles.HUD_TITLE_TEXT)

	for i in SLOT_X.size():
		var on: = i == selected % SLOT_X.size() and _slot_index(i) >= 0
		var slot: = StyleBoxFlat.new()
		slot.bg_color = Color(0.9, 0.93, 1.0) if on else Color(0.955, 0.965, 0.99)
		slot.border_color = Color(0.3, 0.42, 0.78) if on else Color(0.78, 0.82, 0.92)
		slot.set_border_width_all(2 if on else 1)
		slot.set_corner_radius_all(8)
		slot.anti_aliasing = true
		if on:
			slot.shadow_color = Color(0.3, 0.42, 0.78, 0.3)
			slot.shadow_size = 6
		draw_style_box(slot, Rect2(Vector2(SLOT_X[i], SLOT_Y), SLOT_SIZE))

		var feet: = Vector2(SLOT_X[i] + SLOT_SIZE.x * 0.5, FEET_Y)
		draw_set_transform(feet, 0.0, Vector2(1.0, 0.42))
		draw_circle(Vector2.ZERO, 24.0, Color(0.2, 0.25, 0.4, 0.16))
		draw_circle(Vector2.ZERO, 16.0, Color(0.2, 0.25, 0.4, 0.14))
		draw_set_transform(Vector2.ZERO)

	var table: = StyleBoxFlat.new()
	table.bg_color = Color(0.94, 0.955, 0.99)
	table.border_color = Color(0.8, 0.84, 0.93)
	table.set_border_width_all(1)
	table.set_corner_radius_all(8)
	table.anti_aliasing = true
	draw_style_box(table, Rect2(14, ROW_Y[0] - 10, 291, ROW_Y.size() * 16 + 4))
	var labels: = [tr("Nombre"), tr("Clase"), tr("Nv."), "EXP", "HP", "SP", tr("Mapa")]
	for r in labels.size():
		var y: float = ROW_Y[r] - 8
		if r > 0:
			draw_line(Vector2(18, y - 0.5), Vector2(301, y - 0.5), Color(0.82, 0.86, 0.94), 1.0)
		draw_string(_font_bold, Vector2(20, y + 12), str(labels[r]), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.38, 0.62))
		if r < STATS.size():
			draw_string(_font_bold, Vector2(RIGHT_VALUE_X - 44, y + 12), tr(str(GameData.STATS[STATS[r]].name)), 
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.3, 0.38, 0.62))
	draw_line(Vector2(RIGHT_VALUE_X - 50, ROW_Y[0] - 8), Vector2(RIGHT_VALUE_X - 50, ROW_Y[5] + 8), Color(0.82, 0.86, 0.94), 1.0)

	var words: = tr("Selecciona\nPersonaje").split("\n")
	for k in words.size():
		var at: = Vector2(330, 264 + k * 30)
		draw_string(_font_bold, at + Vector2(1, 2), words[k], HORIZONTAL_ALIGNMENT_CENTER, 220, 26, Color(1, 1, 1, 0.9))
		draw_string(_font_bold, at, words[k], HORIZONTAL_ALIGNMENT_CENTER, 220, 26, Color(0.36, 0.45, 0.72))

	draw_line(Vector2(8, SIZE.y - 30.5), Vector2(SIZE.x - 8, SIZE.y - 30.5), Color(0.84, 0.87, 0.95), 1.0)


func _class_label(id: String) -> String:
	var d: Dictionary = GameData.CLASSES[id]
	return tr(str(GameData.HIGH_NAMES.get(id, d.name))) if Save.is_reborn(id) else tr(str(d.name))


func _fit(text: String, width: float, font_size: = 10) -> String:
	if _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= width:
		return text
	while text.length() > 1 and _font.get_string_size(text + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
		text = text.substr(0, text.length() - 1)
	return text.strip_edges() + "..."





static func draw_rebirth_badge(on: CanvasItem, font: Font, at: Vector2, rlv: int) -> void :
	var text: = GameData.rebirth_name(rlv)
	var fs: = 11

	var w: = 0.0
	for ch in text:
		w += font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var x: = roundf(at.x - w * 0.5)
	var right: = x + w
	var t: = Time.get_ticks_msec() / 1000.0

	var sweep: = fmod(t, 2.6) / 1.1 * (w + 30.0) - 15.0



	var pulse: = 0.5 + 0.5 * sin(t * 2.4)
	var start: = x

	on.draw_set_transform(Vector2(x + w * 0.5, at.y - 4.0), 0.0, Vector2(1.0, 0.3))
	for k in 6:
		var r: = w * 0.5 + 10.0 - k * 2.5
		on.draw_circle(Vector2.ZERO, r, Color(1.0, 0.8, 0.25, (0.05 + 0.04 * pulse)))
	on.draw_set_transform(Vector2.ZERO)
	on.draw_string_outline(font, Vector2(x, at.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(1, 0.99, 0.92, 0.95))
	for ch in text:
		var cw: = font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var glint: = clampf(1.0 - absf(x + cw * 0.5 - right + w - sweep) / 12.0, 0.0, 1.0)
		on.draw_string(font, Vector2(x, at.y), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 
			Color(0.62, 0.38, 0.0).lerp(Color(0.95, 0.7, 0.15), glint))
		x += cw

	for k in 2:
		var tw: = maxf(0.0, sin(t * 3.1 + k * PI))
		if tw > 0.05:
			var c: = Vector2(start - 4.0 if k == 0 else right + 4.0, at.y - 9.0 if k == 0 else at.y - 2.0)
			on.draw_colored_polygon(_star_points(c, 3.5 * tw), Color(1.0, 0.85, 0.3, tw))
			on.draw_circle(c, 0.9 * tw, Color(1, 1, 0.95, tw))


static func _star_points(c: Vector2, r: float) -> PackedVector2Array:
	var pts: = PackedVector2Array()
	for k in 10:
		var a: = - PI / 2.0 + k * PI / 5.0
		pts.append(c + Vector2(cos(a), sin(a)) * (r if k % 2 == 0 else r * 0.45))
	return pts


func _text(at: Vector2, text: String, color: Color, font_size: int, bold: = false) -> void :
	draw_string(_font_bold if bold else _font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
