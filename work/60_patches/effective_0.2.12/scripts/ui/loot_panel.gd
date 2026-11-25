class_name LootPanel
extends PanelContainer








signal picked
signal finished

signal toggled(index: int, on: bool)


signal passing_all

const CARD: = Vector2(172, 50)
const ICON: = 30

const CARDS_ROW: = 5

var world: World
var offer: LootRoll
var _list: GridContainer
var _time: ProgressBar
var _hint: Label
var _ok: Button
var _modes: Array = []
var _cards: Array = []
var _refresh_t: = 0.0
var _rolling: = false


func setup(p_world: World, p_offer: LootRoll) -> void :
	world = p_world
	offer = p_offer
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel", UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 8))
	position.y = 58
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 5)
	add_child(col)

	var title: = UiKit.label(tr("Botín legendario"), 13, UiKit.GOLD.darkened(0.3), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	_hint = UiKit.label("", 11, UiKit.MUTED)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size.x = 1
	col.add_child(_hint)




	var center: = HBoxContainer.new()
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(center)
	_list = GridContainer.new()
	_list.add_theme_constant_override("h_separation", 6)
	_list.add_theme_constant_override("v_separation", 6)
	center.add_child(_list)
	for i in offer.items.size():
		var b: = _item_button(i)
		_list.add_child(b)
		_cards.append(b)
	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 6)
	col.add_child(foot)
	_time = UiKit.bar(UiKit.GOLD, 8.0)
	_time.custom_minimum_size.x = 60
	_time.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_time.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_time.max_value = LootRoll.PICK_TIME
	foot.add_child(_time)
	_ok = UiKit.button(tr("Listo"), true)
	_ok.focus_mode = Control.FOCUS_NONE
	_ok.add_theme_font_size_override("font_size", 12)
	_ok.pressed.connect(_confirm)
	foot.add_child(_ok)
	col.add_child(_mode_row())
	_refresh()


	_apply_auto.call_deferred()



func _mode_row() -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UiKit.label(tr("Siempre:"), 10, UiKit.MUTED))
	var names: = {"": tr("Elegir yo"), "useful": tr("Lo que me sirve"), "all": tr("Todo"), "pass": tr("Pasar")}
	var tips: = {"": tr("Eliges en cada tirada."), 
		"useful": tr("Pide solo lo que tu clase puede usar y no tienes; pasa lo demás."), 
		"all": tr("Pide todo: si lo quieren varios, se tiran dados."), 
		"pass": tr("Pasa todo: los demás piden primero; lo que nadie pide y te sirve es tuyo.")}
	var group: = ButtonGroup.new()
	for m in LootRoll.AUTO_MODES:
		var b: = Button.new()
		b.text = str(names[m])
		b.toggle_mode = true
		b.button_group = group
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 10)
		b.add_theme_color_override("font_color", UiKit.MUTED)
		for st in ["font_pressed_color", "font_hover_pressed_color"]:
			b.add_theme_color_override(st, UiKit.TEXT)
		var looks: = {"normal": [UiKit.PANEL_SOFT, UiKit.GOLD_DIM, 1], "hover": [Color(0.97, 0.98, 1.0), UiKit.GOLD, 1], 
			"pressed": [Color(0.86, 0.92, 1.0), UiKit.GOLD, 2], "hover_pressed": [Color(0.86, 0.92, 1.0), UiKit.GOLD, 2]}
		for k in looks:
			var sb: = UiKit.panel_box(looks[k][0], looks[k][1], 5, looks[k][2])
			sb.content_margin_left = 6
			sb.content_margin_right = 6
			sb.content_margin_top = 1
			sb.content_margin_bottom = 1
			b.add_theme_stylebox_override(k, sb)
		b.button_pressed = LootRoll.auto_mode() == m
		b.tooltip_text = str(tips[m]) + "\n" + tr("Vale para las próximas tiradas. Los únicos los eliges siempre tú.")
		var mode: String = m
		b.pressed.connect( func():
			Save.set_setting("loot_auto", mode)
			world.play_sound("click", 0.0, -8.0)
			_apply_auto())
		row.add_child(b)
		_modes.append(b)
	return row




func _apply_auto() -> void :
	var mode: = LootRoll.auto_mode()
	if mode == "" or _rolling or offer.ready.get(world.player.slot, false) or not is_instance_valid(world.player):
		return
	if mode == "pass":
		offer.standing_pass[world.player.slot] = true
		passing_all.emit()
	for i in offer.items.size():
		if LootRoll.is_unique(offer.items[i]):
			continue
		var want: = offer.auto_wants(world.player, i, mode)
		if offer.wants(world.player.slot, i) != want:
			offer.toggle(world.player.slot, i)
			toggled.emit(i, want)
	if not offer.has_unique():
		_confirm()
	else:
		_refresh()


func _item_button(i: int) -> Button:
	var it: Dictionary = offer.items[i]
	var b: = Button.new()
	b.toggle_mode = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = CARD

	var looks: = {"normal": [UiKit.PANEL_SOFT, UiKit.GOLD_DIM, 1], "hover": [Color(0.97, 0.98, 1.0), UiKit.GOLD, 1], 
		"pressed": [Color(0.86, 0.92, 1.0), UiKit.GOLD, 3], "hover_pressed": [Color(0.86, 0.92, 1.0), UiKit.GOLD, 3]}
	for k in looks:
		b.add_theme_stylebox_override(k, UiKit.panel_box(looks[k][0], looks[k][1], 6, looks[k][2]))
	var row: = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 5)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
	b.add_child(row)
	var ic: = UiKit.icon_rect(world.menus._item_icon(Equipment.item_def(it).icon), ICON)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ic)
	var info: = VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_theme_constant_override("separation", -2)
	row.add_child(info)
	var unique: = LootRoll.is_unique(it)
	var name: = UiKit.label(Equipment.item_name(it), 12, Equipment.item_color(it).darkened(0.25), true)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(name)
	var fits: = world.player.equipment.can_wear(it)
	var sub: = UiKit.label((tr("Único") + "  ·  " if unique else "") + (tr("Lo puedes usar") if fits else tr("No es de tu clase")), 
		10, UiKit.GOOD.darkened(0.35) if fits else UiKit.MUTED)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(sub)
	var who: = UiKit.label("", 10, UiKit.GOLD.darkened(0.15))
	who.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(who)
	b.set_meta("who", who)
	b.set_meta("info", info)
	b.set_meta("row", row)
	_fit(b)
	b.pressed.connect( func(): _toggle(i))


	world.menus._set_hover(b, world.menus._item_hover(it, [], [tr("Clic: lo quiero / lo paso")]))
	return b


func _toggle(i: int) -> void :
	if _rolling or offer.ready.get(world.player.slot, false):
		return
	offer.toggle(world.player.slot, i)
	toggled.emit(i, offer.wants(world.player.slot, i))
	world.play_sound("click", 0.0, -8.0)
	_refresh()


func _confirm() -> void :
	if _rolling or offer.ready.get(world.player.slot, false):
		return
	offer.ready[world.player.slot] = true
	_refresh()
	picked.emit()


func _process(delta: float) -> void :


	if size != get_combined_minimum_size():
		reset_size()
	position.x = (get_viewport_rect().size.x - size.x) * 0.5
	if _rolling:
		return
	_time.value = offer.t
	_refresh_t -= delta
	if _refresh_t <= 0.0:
		_refresh_t = 0.2
		_refresh()


func _refresh() -> void :
	var me: = world.player.slot
	var mine: Array = offer.picks.get(me, [])
	var done: bool = offer.ready.get(me, false)
	var auto: = LootRoll.auto_mode() != ""




	_hint.add_theme_color_override("font_color", UiKit.MUTED)
	if done and LootRoll.auto_mode() == "pass" and mine.is_empty():
		_hint.text = tr("Pasas todo por «Siempre: Pasar»: cámbialo abajo o en Opciones > Juego.")
		_hint.add_theme_color_override("font_color", Color(0.75, 0.2, 0.15))
	elif done:
		var got: = mine.map( func(i): return Equipment.item_name(offer.items[i]))
		_hint.text = (tr("Pides: %s") % ", ".join(got) if not got.is_empty() else tr("Pasas todo")) + "  ·  " + tr("esperando al grupo")
	elif auto and offer.has_unique():
		_hint.text = tr("Elige los únicos; lo demás ya está elegido")
	else:
		_hint.text = tr("Ya pides lo que te sirve · clic para cambiar · si lo quieren varios, dados")
	_ok.visible = not done
	_list.columns = maxi(1, _cards.size() if done else mini(CARDS_ROW, _cards.size()))
	for i in _cards.size():
		var b: Button = _cards[i]
		b.set_pressed_no_signal(mine.has(i))

		b.modulate.a = 0.45 if done and not mine.has(i) else 1.0
		var names: = []
		for s in offer.wanted_by(i):
			names.append(world.hero_label(world.heroes[s]))
		var who: = (tr("Lo quieren: %s") % ", ".join(names)) if not names.is_empty() else tr("Nadie lo pide todavía")
		(b.get_meta("who") as Label).text = who

		(b.get_meta("info") as Control).visible = not done
		_fit(b, done)

	if not done:
		var widest: = 0.0
		for b in _cards:
			widest = maxf(widest, (b as Button).custom_minimum_size.x)
		for b in _cards:
			(b as Button).custom_minimum_size.x = widest




func _fit(b: Button, folded: = false) -> void :
	var need: Vector2 = (b.get_meta("row") as Control).get_combined_minimum_size() + Vector2(10, 8)
	var least: = Vector2(ICON + 12, ICON + 12) if folded else CARD
	b.custom_minimum_size = Vector2(maxf(least.x, need.x), maxf(least.y, need.y))




func show_rolls(results: Array) -> void :
	_rolling = true
	visible = false
	var show: = LootRollShow.new()
	world.add_child(show)
	show.setup(world, results)
	show.finished.connect( func():
		finished.emit()
		queue_free())
