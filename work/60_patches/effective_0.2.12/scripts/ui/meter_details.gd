class_name MeterDetails
extends CanvasLayer







const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const WIDTH: = 780.0
const LIST_W: = 380.0
const LIST_H: = 340.0

var world: World
var tab: = "damage"

var _sel: = ""
var _boss: = ""
var _win: Control
var _title: Label
var _tabs: HBoxContainer
var _reset: Button
var _bosses: HFlowContainer
var _list: VBoxContainer
var _info: VBoxContainer
var _refresh: = 0.0
var _drag: = false
var _drag_off: = Vector2.ZERO
var _icons: = {}


func _init() -> void :
	layer = 112
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _ready() -> void :
	var w: Dictionary = UiStyles.hud_window(tr("Detalles de daño"), RO_FONT_BOLD)
	_win = w.root
	_title = w.title
	_win.custom_minimum_size.x = WIDTH
	add_child(_win)

	var bar: Control = _win.get_child(0)
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	bar.gui_input.connect(_on_bar_input)
	var body: VBoxContainer = w.body
	body.add_theme_constant_override("separation", 6)
	body.get_parent().mouse_filter = Control.MOUSE_FILTER_STOP
	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 4)
	body.add_child(top)
	_tabs = HBoxContainer.new()
	_tabs.add_theme_constant_override("separation", 4)
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_tabs)
	for t in [["damage", tr("Daño")], ["boss", tr("Jefes")], ["taken", tr("Recibido")], ["heal", tr("Curación")], ["summary", tr("Resumen")]]:
		var b: = _small_button(str(t[1]))
		var key: String = t[0]
		b.pressed.connect( func(): _set_tab(key))
		b.set_meta("tab", key)
		_tabs.add_child(b)

	_reset = _small_button(tr("Reiniciar"))
	_reset.tooltip_text = tr("El daño y el DPS cuentan desde ahora. El total de la partida no cambia.")
	_reset.pressed.connect( func():
		if world != null:
			world.meter_view_reset()
			_rebuild())
	top.add_child(_reset)
	var close: = _small_button(tr("Cerrar (M)"))
	close.pressed.connect(close_window)
	top.add_child(close)
	_bosses = HFlowContainer.new()
	_bosses.add_theme_constant_override("h_separation", 4)
	_bosses.add_theme_constant_override("v_separation", 4)
	body.add_child(_bosses)
	var cols: = HBoxContainer.new()
	cols.add_theme_constant_override("separation", 8)
	body.add_child(cols)
	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(LIST_W, LIST_H)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	cols.add_child(scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 2)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)
	var info_panel: = PanelContainer.new()
	info_panel.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.96, 0.97, 1.0), Color(0.78, 0.82, 0.92), 6))
	info_panel.custom_minimum_size = Vector2(WIDTH - LIST_W - 30, LIST_H)
	cols.add_child(info_panel)

	var info_scroll: = ScrollContainer.new()
	info_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	info_scroll.custom_minimum_size.y = LIST_H - 12
	info_panel.add_child(info_scroll)

	var pad: = MarginContainer.new()
	pad.add_theme_constant_override("margin_right", 14)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_scroll.add_child(pad)
	_info = VBoxContainer.new()
	_info.add_theme_constant_override("separation", 3)
	_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(_info)
	var hint: = _text(tr("Clic en una fila: su detalle  ·  arrastra el título para mover  ·  M / Esc: cerrar"), 9, UiKit.MUTED)
	hint.visible = not MouseWalk.touch()
	body.add_child(hint)


func _small_button(text: String) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_override("font", RO_FONT_BOLD)
	b.add_theme_font_size_override("font_size", 11)
	b.custom_minimum_size = Vector2(78, 22)
	b.texture_filter = RoAssets.ui_filter()
	for state in ["normal", "hover", "pressed", "disabled"]:
		var box: = UiStyles.hud_button_box(state)
		box.content_margin_left = 8
		box.content_margin_right = 8
		box.content_margin_top = 2
		box.content_margin_bottom = 2
		b.add_theme_stylebox_override(state, box)
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(c, Color(0.12, 0.13, 0.2))
	return b



func _mark(b: Button, on: bool) -> void :
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(c, Color(0.1, 0.3, 0.85) if on else Color(0.12, 0.13, 0.2))
	b.modulate = Color(1, 1, 1) if on else Color(0.9, 0.9, 0.93)


func _text(text: String, size: = 11, color: = UiKit.TEXT, bold: = false) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", RO_FONT_BOLD if bold else UiKit.FONT_BODY)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l




func toggle(mode: = "") -> void :
	if visible:
		close_window()
	else:
		open(mode)






func open(mode: = "", focus: = -1) -> void :
	if world == null:
		return
	world.meter_focus = focus
	if mode != "":
		tab = mode
	visible = true
	_place()
	_set_tab(tab)
	if world.has_method("play_sound"):
		world.play_sound("ui_click", 0.0, -8.0)


func close_window() -> void :
	visible = false
	if world != null:
		world.calc_watch = ""


func _place() -> void :
	var view: = get_viewport().get_visible_rect().size
	var k: = maxf(1.0, floorf(view.y / 700.0))
	_win.scale = Vector2(k, k)
	_win.reset_size()
	var saved = Save.setting("meter_details_pos", [])
	var pos: = Vector2((view.x - _win.size.x * k) * 0.5, (view.y - _win.size.y * k) * 0.4)
	if saved is Array and saved.size() == 2:
		pos = Vector2(float(saved[0]) * view.x, float(saved[1]) * view.y)
	_win.position = _clamp(pos)


func _clamp(pos: Vector2) -> Vector2:
	var view: = get_viewport().get_visible_rect().size
	var s: = _win.size * _win.scale
	return Vector2(clampf(pos.x, 0.0, maxf(0.0, view.x - s.x)), clampf(pos.y, 0.0, maxf(0.0, view.y - s.y)))


func _on_bar_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_drag = event.pressed
		_drag_off = _win.get_global_mouse_position() - _win.position
		if not _drag:
			var view: = get_viewport().get_visible_rect().size
			Save.set_setting("meter_details_pos", [_win.position.x / view.x, _win.position.y / view.y])
	elif event is InputEventMouseMotion and _drag:
		_win.position = _clamp(_win.get_global_mouse_position() - _drag_off)


func _unhandled_input(event: InputEvent) -> void :
	if world == null or ( not world.running and not visible):
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		toggle()
		get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void :

	if visible and event.is_action_pressed("pause"):
		close_window()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void :
	if not visible:
		return
	_refresh -= delta
	if _refresh <= 0.0:
		_refresh = 0.5
		_rebuild()




func _set_tab(t: String) -> void :
	tab = t
	_sel = ""
	for b in _tabs.get_children():
		_mark(b, b.get_meta("tab", "") == t)
	_rebuild()


func _rows() -> Array:
	match tab:
		"boss":
			return world.meter_rows("boss", _boss)
		"taken":
			return world.meter_rows("taken")
		"heal":
			return world.meter_rows("heal")
		"summary":
			return []
	return world.meter_rows("damage")


func _label(tag: String) -> String:
	if tab == "heal":
		return world.heal_label(tag)
	return world.taken_label(tag) if tab == "taken" else world.meter_label(tag)


func _icon(tag: String) -> Texture2D:
	var key: = tab + ":" + tag
	if not _icons.has(key):
		if tab == "taken":
			var id: = tag.trim_prefix("mechanics:")
			_icons[key] = StagePreview._cropped(id) if GameData.MONSTERS.has(id) else null
		else:
			_icons[key] = world.meter_icon(tag)
	return _icons[key]


var _scroll_tab: = ""


func _keep_scroll(scroll: ScrollContainer, at: int) -> void :
	await get_tree().process_frame
	if is_instance_valid(scroll):
		scroll.scroll_vertical = at


func _rebuild() -> void :
	if world == null:
		return

	var total: = world.meter_view_total("damage")
	var titles: = {"damage": tr("Detalles de daño  ·  %s  (%s/s)") % [DamageMeter.short(total), DamageMeter.short(total / world.meter_time())], 
		"boss": tr("Daño a jefes, MVPs y élites"), "taken": tr("Daño recibido  ·  %s") % DamageMeter.short(world.meter_view_total("taken")), 
		"heal": tr("Curación que hiciste  ·  %s") % DamageMeter.short(world.meter_view_total("heal")), 
		"summary": tr("Resumen de la partida")}
	_title.text = str(titles.get(tab, ""))

	if tab == "damage" and world._meter_focus_other():
		_title.text += "  ·  " + world.hero_meter_name(world.meter_focus)
	if not world.meter_view.is_empty() and bool(world.get("running")) and tab != "summary":
		_title.text += "  ·  " + tr("desde el reinicio")

	_reset.visible = bool(world.get("running"))
	_build_bosses()



	var scroll: = _list.get_parent() as ScrollContainer
	if tab != _scroll_tab:
		_scroll_tab = tab
		_keep_scroll.call_deferred(scroll, 0)
	var rows: = _rows()
	var summary: = tab == "summary"
	_list.get_parent().visible = not summary
	_info.get_parent().get_parent().get_parent().custom_minimum_size.x = WIDTH - 20 if summary else WIDTH - LIST_W - 30

	world.calc_watch = _sel if tab in ["damage", "boss"] and bool(world.get("running")) else ""
	if summary:
		_summary()
		return

	for c in _list.get_children():
		if not c.has_meta("tag"):
			_list.remove_child(c)
			c.queue_free()
	var top: = float(rows[0].dmg) if not rows.is_empty() else 1.0
	var sum: = 0.0
	for r in rows:
		sum += float(r.dmg)
	while _list.get_child_count() > rows.size():
		var extra: = _list.get_child(_list.get_child_count() - 1)
		_list.remove_child(extra)
		extra.queue_free()
	for i in rows.size():
		if i >= _list.get_child_count():
			_list.add_child(_row())
		_fill_row(_list.get_child(i) as Button, i, rows[i], top, sum)
	if rows.is_empty():
		_list.add_child(_text(tr("Sin datos todavía."), 11, UiKit.MUTED))
	if _sel == "" and not rows.is_empty():
		_sel = str(rows[0].tag)
	_detail(rows, sum)



func _build_bosses() -> void :
	for c in _bosses.get_children():
		c.queue_free()
	_bosses.visible = tab == "boss" or (tab == "damage" and _party())
	if tab == "damage" and _party():
		_build_party()
	if tab != "boss":
		return
	var ids: = world.meter_boss.keys()
	ids.sort_custom( func(a, b): return float(world.meter_boss[a].dmg) > float(world.meter_boss[b].dmg))
	var all: = _small_button(tr("Todos"))
	all.pressed.connect( func():
		_boss = ""
		_sel = ""
		_rebuild())
	_mark(all, _boss == "")
	_bosses.add_child(all)
	for id in ids:
		var b: = _small_button("%s  %s" % [tr(str(GameData.MONSTERS[id].name)) if GameData.MONSTERS.has(id) else id, 
			DamageMeter.short(float(world.meter_boss[id].dmg))])
		b.icon = StagePreview._cropped(id)
		b.expand_icon = true
		b.custom_minimum_size = Vector2(0, 26)
		_mark(b, _boss == id)
		if bool(world.meter_boss[id].get("mvp", false)) and _boss != id:
			b.add_theme_color_override("font_color", Color(0.7, 0.15, 0.2))
		var key: String = id
		b.pressed.connect( func():
			_boss = key
			_sel = ""
			_rebuild())
		_bosses.add_child(b)
	if world.meter_boss.is_empty():
		_bosses.add_child(_text(tr("Todavía no golpeaste a ningún jefe."), 10, UiKit.MUTED))



func _party() -> bool:
	return world.heroes.size() > 1 and world.meter_hero.size() > 1






func _build_party() -> void :
	var totals: = {}
	for r in world.meter_party_rows():
		totals[int(r.slot)] = float(r.dmg)
	for h in world.heroes:
		if not is_instance_valid(h) or not totals.has(h.slot):
			continue
		var slot: int = h.slot
		var me: bool = h == world.player
		var b: = _small_button("%s  %s" % [world.hero_meter_name(slot), DamageMeter.short(float(totals[slot]))])
		b.custom_minimum_size = Vector2(0, 24)
		_mark(b, (world.meter_focus == slot) if world._meter_focus_other() else me)
		b.pressed.connect( func():
			world.meter_focus = -1 if me else slot
			_sel = ""
			_rebuild())
		_bosses.add_child(b)





func _row() -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(LIST_W - 14, 22)
	b.set_meta("tag", "")
	var bar: = ColorRect.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.position = Vector2(1, 1)
	b.add_child(bar)
	var row: = HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 3
	row.offset_right = -4
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	var ic: = TextureRect.new()
	ic.custom_minimum_size = Vector2(18, 18)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(ic)
	var name_l: = _text("", 11, Color(0.08, 0.1, 0.18))
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_l.clip_text = true
	UiKit.fit_dots(name_l)
	row.add_child(name_l)
	var val: = _text("", 11, Color.BLACK, true)
	row.add_child(val)
	b.set_meta("parts", [bar, ic, name_l, val])
	b.pressed.connect( func():
		_sel = str(b.get_meta("tag"))
		world.play_sound("ui_click", 0.0, -10.0)
		_rebuild())
	return b


func _fill_row(b: Button, i: int, r: Dictionary, top: float, sum: float) -> void :
	var tag: = str(r.tag)
	var parts: Array = b.get_meta("parts")
	var sel: = tag == _sel
	if str(b.get_meta("tag")) != tag or bool(b.get_meta("sel", false)) != sel or str(b.get_meta("tab", "")) != tab:
		b.set_meta("tag", tag)
		b.set_meta("sel", sel)
		b.set_meta("tab", tab)
		var box: = StyleBoxFlat.new()
		box.bg_color = Color(0.86, 0.9, 1.0) if sel else Color(0.93, 0.94, 0.97)
		box.border_color = Color(0.35, 0.5, 0.9) if sel else Color(0.85, 0.87, 0.92)
		box.set_border_width_all(1)
		box.set_corner_radius_all(3)
		for st in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(st, box if st != "hover" else _hover(box))
		(parts[1] as TextureRect).texture = _icon(tag)
	var bar: = parts[0] as ColorRect
	bar.color = Color(DamageMeter.ELEMENT_COLORS.get(str(r.get("el", "neutral")), DamageMeter.ELEMENT_COLORS.neutral), 0.75)
	bar.size = Vector2((LIST_W - 16) * float(r.dmg) / maxf(top, 1.0), 20)
	UiKit.fit_dots(parts[2], "%d. %s" % [i + 1, _label(tag)])
	(parts[3] as Label).text = "%s  (%d%%)" % [DamageMeter.short(float(r.dmg)), roundi(100.0 * float(r.dmg) / maxf(sum, 1.0))]


func _hover(box: StyleBoxFlat) -> StyleBoxFlat:
	var h: = box.duplicate() as StyleBoxFlat
	h.border_color = Color(0.35, 0.5, 0.9)
	return h



func _detail(rows: Array, sum: float) -> void :



	for c in _info.get_children():
		_info.remove_child(c)
		c.queue_free()
	var r: Dictionary = {}
	for o in rows:
		if str(o.tag) == _sel:
			r = o
	if r.is_empty():
		_info.add_child(_text(tr("Elige una fila."), 11, UiKit.MUTED))
		return
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	var ic: = TextureRect.new()
	ic.texture = _icon(_sel)
	ic.custom_minimum_size = Vector2(28, 28)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	head.add_child(ic)
	var nl: = _text(_label(_sel), 13, Color(0.1, 0.2, 0.6), true)
	nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nl.custom_minimum_size.x = WIDTH - LIST_W - 80
	head.add_child(nl)
	_info.add_child(head)
	var lines: Array = []
	var dmg: = float(r.dmg)
	if tab == "heal":
		var n: = int(r.get("hits", 0))
		lines = [[tr("Curado"), "%s  (%d%%)" % [DamageMeter.short(dmg), roundi(100.0 * dmg / maxf(sum, 1.0))]], 
			[tr("Curaciones"), str(n)], 
			[tr("Promedio"), DamageMeter.short(dmg / maxf(1.0, n))], 
			[tr("Por segundo"), DamageMeter.short(dmg / maxf(1.0, world.time))]]
	elif tab == "taken":
		var hits: = int(r.get("hits", 0))
		lines = [[tr("Daño recibido"), "%s  (%d%%)" % [DamageMeter.short(dmg), roundi(100.0 * dmg / maxf(sum, 1.0))]], 
			[tr("Golpes"), str(hits)], 
			[tr("Golpe máximo"), DamageMeter.short(float(r.get("max", 0.0)))], 
			[tr("Promedio"), DamageMeter.short(dmg / maxf(1.0, hits))]]
	else:
		var full: Dictionary = world.meter.get(_sel, r)
		var hits: = int(full.get("hits", 0))
		var crits: = int(full.get("crits", 0))
		var active: = maxf(1.0, world.time - float(full.get("first", 0.0)))
		lines = [[tr("Daño") if tab == "damage" else (tr("Daño a este jefe") if _boss != "" else tr("Daño a jefes")), 
				"%s  (%d%%)" % [DamageMeter.short(dmg), roundi(100.0 * dmg / maxf(sum, 1.0))]], 
			[tr("Daño total"), DamageMeter.short(float(full.get("dmg", 0.0)))], 
			[tr("DPS"), DamageMeter.short(float(full.get("dmg", 0.0)) / active)], 
			[tr("Golpes"), str(hits)], 
			[tr("Críticos"), "%d  (%d%%)" % [crits, roundi(100.0 * crits / maxf(1.0, hits))]], 
			[tr("Golpe máximo"), DamageMeter.short(float(full.get("max", 0.0)))], 
			[tr("Golpe mínimo"), DamageMeter.short(float(full.get("min", 0.0)))], 
			[tr("Promedio"), DamageMeter.short(float(full.get("dmg", 0.0)) / maxf(1.0, hits))], 
			[tr("A jefes"), "%s  (%d%%)" % [DamageMeter.short(float(full.get("boss", 0.0))), 
				roundi(100.0 * float(full.get("boss", 0.0)) / maxf(1.0, float(full.get("dmg", 0.0))))]], 
			[tr("Monstruos rematados"), str(int(full.get("kills", 0)))], 
			[tr("Elemento"), tr(str(GameData.ELEMENT_NAMES.get(str(full.get("el", "neutral")), "")))], 
			[tr("Primer golpe"), UiKit.time_text(float(full.get("first", 0.0)))]]

		var p = world.player
		if _sel.begins_with("bash") and p != null and p.effects.has("lg_bash"):
			lines.append([tr("Mysteltainn"), tr("+%d%%  (%d monstruos)") % [roundi(100.0 * GameData.lg_bash_bonus(p.lg_bash_kills)), p.lg_bash_kills]])

	if tab in ["damage", "boss"]:
		_calc_block(world.meter.get(_sel, r))
		_info.add_child(HSeparator.new())
	for l in lines:
		_info.add_child(_pair(str(l[0]), str(l[1])))





func _calc_block(full: Dictionary) -> void :
	var p = world.player
	_info.add_child(_text(tr("Cómo se calcula  ·  su último golpe"), 12, Color(0.1, 0.2, 0.6), true))
	var c: Dictionary = world.calc_last
	if not bool(world.get("running")) or p == null:
		_info.add_child(_note(tr("Durante la partida: el detalle del último golpe de esta fila.")))
		return

	var part: = _part_row(_sel)
	if part != "":
		_info.add_child(_note(part))
		return
	if c.is_empty() or world._calc_row(str(c.tag), str(c.source), str(c.element)) != _sel:
		_info.add_child(_note(tr("Esperando su próximo golpe...")))
		return
	var src: = str(c.source)
	var tag: = str(c.tag)
	_info.add_child(_factor_row(tr("Base"), _base_note(src, tag), DamageMeter.short(float(c.base))))
	_factor(tr("Contra el objetivo"), float(c.situ), tr("jefe o MVP, estados, marcas, pactos, venenos..."))
	_factor(tr("Daño"), float(c.dmg), tr("tu daño general: equipo, cartas, sets, platos, mascota..."))
	var kind: = _kind_text(p, src, tag)
	_factor(str(kind[0]), float(c.kind), str(kind[1]), true)
	_factor(tr("Elemento"), float(c.el), "%s → %s" % [tr(str(GameData.ELEMENT_NAMES.get(str(c.element), c.element))), 
		tr(str(GameData.ELEMENT_NAMES.get(str(c.target), c.target)))])
	_factor(tr("Variación"), float(c.spread), tr("cada golpe ×0,9 a ×1,1"), true)
	if float(c.crit) != 1.0:
		_factor(tr("Crítico"), float(c.crit), tr("daño crítico ×%s") % _m(float(c.crit_dmg)), true)
	_factor(tr("Partida"), float(c.rest), tr("torre, Corazón de Ymir, Peligro, Provoke, Lex Aeterna..."))
	var total: = _pair(tr("= Golpe"), DamageMeter.short(float(c.final)))
	for l in total.get_children():
		if l is Label:
			l.add_theme_color_override("font_color", Color(0.1, 0.2, 0.6))
	_info.add_child(total)

	_info.add_child(_note(tr("Crítico: %d%% de probabilidad") % roundi(minf(1.0, float(c.crit_chance)) * 100.0)))
	var active: = maxf(1.0, world.time - float(full.get("first", 0.0)))
	_info.add_child(_note(tr("%s golpes por segundo (medido)") % str(snappedf(float(full.get("hits", 0)) / active, 0.1))))



func _factor(what: String, v: float, note: String, always: = false) -> void :
	if not always and absf(v - 1.0) < 0.0005:
		return
	_info.add_child(_factor_row("× " + what, note, "×" + _m(v)))




func _factor_row(what: String, note: String, value: String) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(_text(what, 11, UiKit.TEXT))
	var n: = _text(note, 9, UiKit.MUTED)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n.custom_minimum_size.x = 40
	n.mouse_filter = Control.MOUSE_FILTER_STOP
	n.tooltip_text = note
	row.add_child(n)
	UiKit.fit_dots(n)
	row.add_child(_text(value, 11, UiKit.TEXT, true))
	return row


func _note(text: String) -> Label:
	var l: = _text(text, 9, UiKit.MUTED)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size.x = WIDTH - LIST_W - 60
	return l



static func _m(v: float) -> String:
	if v >= 1000.0:
		return DamageMeter.short(v)
	if v >= 10.0:
		return str(roundi(v))
	return str(snappedf(v, 0.01))



func _base_note(src: String, tag: String) -> String:
	if src == "basic":
		return tr("el ATK de tu ataque básico (arma, refinado, cartas)")
	if src == "poison":
		return tr("la dosis del veneno, la quemadura o el sangrado por sus cargas")
	if tag.begins_with("proc:"):
		return tr("el daño de la habilidad que lanza (su nivel)")
	if tag.begins_with("u_") or tag.begins_with("lg_"):
		return tr("el golpe de su objeto")
	if GameData.is_summon_tag(tag):
		return tr("el golpe de la invocación")
	return tr("el daño de la habilidad a su nivel")




func _part_row(tag: String) -> String:
	match tag:
		"lex_aeterna":
			return tr("Lo que Lex Aeterna sumó: el golpe de habilidad que gasta su marca se multiplica, y esa parte extra se cuenta aquí.")
		"status_combo":
			return tr("Lo que un estado sumó: un monstruo congelado o petrificado (o un jefe con su marca) recibe más de su elemento combinado; la parte por encima de su propio elemento se cuenta aquí.")
		"u_coma":
			return tr("Lo que sumó el Coma de la Lich's Bone Wand: un jefe en Coma recibe ×%s de todos, y sus golpes mágicos pueden dejar ×%s a un monstruo común; esa parte extra se cuenta aquí.") % [_m(GameData.U_COMA_BOSS_MULT), _m(GameData.U_COMA_HIT_MULT)]
	return ""





func _kind_text(p, src: String, tag: String) -> Array:
	if tag.begins_with("proc:"):
		var skill: = tag.trim_prefix("proc:").get_slice("@", 0)
		var bd: Dictionary = p.proc_breakdown(tag.ends_with("@hit"), skill)
		if bool(bd.own):
			return [tr("Lanzado solo"), tr("usa tu propia habilidad, que pega más")]
		var names: = {"basic": tr("Ataque básico + Daño de procs"), "hit": tr("FUE/VIT"), "hp": tr("Vida"), "level": tr("Nv base"), 
			"proc": tr("Procs"), "steel": "Steel Body"}
		var bits: Array[String] = []
		for part in bd.parts:
			if str(part[0]) == "dmg" or absf(float(part[1]) - 1.0) < 0.005:
				continue
			bits.append("%s ×%s" % [str(names.get(part[0], part[0])), _m(float(part[1]))])
		return [tr("Lanzado solo"), "  ·  ".join(bits)]
	if tag == "blitz_beat":
		return [tr("Lanzado solo"), tr("tu ataque básico o la habilidad, lo que pegue más")]
	if tag == "u_owl" or tag == "u_flies":
		var bd2: Dictionary = p.proc_breakdown(false, "jupitel_thunder" if tag == "u_owl" else "")
		var bits2: Array[String] = []
		var names2: = {"basic": tr("Ataque básico + Daño de procs"), "level": tr("Nv base"), "proc": tr("Procs"), "steel": "Steel Body"}
		for part in bd2.parts:
			if str(part[0]) == "dmg" or absf(float(part[1]) - 1.0) < 0.005:
				continue
			bits2.append("%s ×%s" % [str(names2.get(part[0], part[0])), _m(float(part[1]))])
		return [tr("Efecto de su objeto"), "  ·  ".join(bits2)]
	if tag in GameData.AUTOCAST_TAGS:
		var by_int: bool = tag in GameData.AUTOCAST_INT_TAGS
		var pm: float = float(p.skill_mult_int) if by_int else float(p.proc_mult)
		if not by_int and tag in GameData.AUTOCAST_MAGIC_TAGS:
			pm += GameData.STR_DMG * maxf(0.0, float(p.eff_stat("int")) - float(p.eff_stat("str")))
		return [tr("Efecto de su objeto") if tag.begins_with("u_") else tr("Lanzado solo"), tr("%s ×%s  ·  Nv base ×%s") % [tr("INT") if by_int else tr("FUE y «Daño de procs»"), _m(pm), 
			_m(GameData.proc_level_mult(int(p.level)))]]
	if GameData.is_summon_tag(tag):
		return [tr("Invocación"), tr("tu poder de invocación; más a jefes y élites, y con tu velocidad de ataque pasado el tope")]
	if src == "basic" or tag in ["poison", "burn", "bleed", "basic", ""]:
		var str_part: float = GameData.STR_DMG * float(p.basic_stat())
		var other: float = float(p.basic_mult) - 1.0 - str_part
		return [tr("Ataque básico"), tr("1 + FUE/INT +%d%% + Daño básico y otros +%d%%") % [roundi(str_part * 100.0), roundi(other * 100.0)]]
	var id: = GameData.skill_of_tag(tag)
	if id == "":

		return [tr("Efecto especial"), tr("crece como dice la ficha de su objeto o habilidad")]
	return [tr("Habilidad"), tr("%s y «Daño de habilidades»") % p.scaling_text(id)]


func _pair(k: String, v: String) -> Control:
	var row: = HBoxContainer.new()
	var kl: = _text(k, 11, UiKit.MUTED)
	kl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(kl)
	row.add_child(_text(v, 11, UiKit.TEXT, true))
	return row


func _summary() -> void :
	for c in _info.get_children():
		_info.remove_child(c)
		c.queue_free()
	var st: = world.meter_stats
	var total: = float(st.get("total", 0.0))
	var best_tag: = str(st.get("best_tag", ""))
	var hits: = int(st.get("hits", 0))
	var boss_total: = 0.0
	for id in world.meter_boss:
		boss_total += float(world.meter_boss[id].dmg)
	var lines: = [
		[tr("Tiempo"), UiKit.time_text(world.time)], 
		[tr("Daño total"), DamageMeter.short(total)], 
		[tr("DPS"), DamageMeter.short(total / maxf(1.0, world.time))], 
		[tr("Daño a jefes"), "%s  (%d%%)" % [DamageMeter.short(boss_total), roundi(100.0 * boss_total / maxf(1.0, total))]], 
		[tr("Jefes golpeados"), str(world.meter_boss.size())], 
		[tr("Golpes"), str(hits)], 
		[tr("Críticos"), "%d  (%d%%)" % [int(st.get("crits", 0)), roundi(100.0 * int(st.get("crits", 0)) / maxf(1.0, hits))]], 
		[tr("Golpe máximo"), "%s  (%s)" % [DamageMeter.short(float(st.get("best", 0.0))), world.meter_label(best_tag) if best_tag != "" else "-"]], 
		[tr("Monstruos derrotados"), str(world.kills)], 
		[tr("Daño recibido"), DamageMeter.short(float(st.get("taken", 0.0)))], 
		[tr("Curación"), DamageMeter.short(float(st.get("healed", 0.0)))], 
		[tr("Fuentes de daño"), str(world.meter.size())], 
	]
	for l in lines:
		_info.add_child(_pair(str(l[0]), str(l[1])))
