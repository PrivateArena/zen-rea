extends Control






signal accepted
signal declined
signal open_page

const KIT: = preload("res://scripts/ui/ui_kit.gd")






const ITCH_PAGE: = "https://nearq.itch.io/midgard-survivors"
const TAGS: = {
	"new": ["NUEVO", Color(0.25, 0.62, 0.3)], 
	"up": ["MEJORA", Color(0.28, 0.45, 0.85)], 
	"fix": ["ARREGLO", Color(0.85, 0.5, 0.12)], 
}

var _notes: Array = []
var _lang: = "es"
var _panel: PanelContainer
var _body: VBoxContainer
var _status: Label
var _bar: ProgressBar
var _buttons: HBoxContainer
var _list_box: Control
var _title: String
var _sub: String
var _full: = false




func setup(title: String, subtitle: String, notes: Array, full: bool) -> void :
	_title = title
	_sub = subtitle
	_notes = notes
	_full = full
	_lang = TranslationServer.get_locale().left(2)


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(KIT.backdrop(0.72))
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_panel = PanelContainer.new()
	var box: = KIT.panel_box(KIT.PANEL, KIT.GOLD_DIM, 8)
	box.set_content_margin_all(0)
	box.content_margin_bottom = 16
	_panel.add_theme_stylebox_override("panel", box)
	center.add_child(_panel)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	_panel.add_child(col)
	col.add_child(_header())
	var pad: = MarginContainer.new()
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 20)
	col.add_child(pad)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 10)
	pad.add_child(_body)
	_status = KIT.label("", 14, KIT.TEXT)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.visible = false
	_body.add_child(_status)
	_highlights()
	_list_box = VBoxContainer.new()
	_list_box.visible = false
	_body.add_child(_list_box)
	_bar = KIT.bar(KIT.XP, 16)
	_bar.visible = false
	_body.add_child(_bar)
	_buttons = HBoxContainer.new()
	_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	_buttons.add_theme_constant_override("separation", 8)
	_body.add_child(_buttons)
	_offer_buttons()
	get_viewport().size_changed.connect(_fit)
	_fit()
	_panel.modulate.a = 0.0
	_panel.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(_panel, "modulate:a", 1.0, 0.2)




func _header() -> Control:
	var band: = PanelContainer.new()
	var g: = Gradient.new()
	g.set_color(0, Color(0.98, 0.98, 1.0))
	g.set_color(1, Color(0.82, 0.87, 0.97))
	var gt: = GradientTexture2D.new()
	gt.gradient = g
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 64
	var st: = StyleBoxTexture.new()
	st.texture = gt
	st.content_margin_left = 20
	st.content_margin_right = 20
	st.content_margin_top = 14
	st.content_margin_bottom = 14
	band.add_theme_stylebox_override("panel", st)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	band.add_child(row)
	var logo: = TextureRect.new()
	if ResourceLoader.exists("res://assets/brand/title.png"):
		logo.texture = load("res://assets/brand/title.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	logo.custom_minimum_size = Vector2(118, 52)
	row.add_child(logo)
	var tcol: = VBoxContainer.new()
	tcol.add_theme_constant_override("separation", 2)
	tcol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(tcol)
	var t: = KIT.label(_title, 20, Color(0.14, 0.2, 0.45), true)
	tcol.add_child(t)
	var s: = KIT.label(_sub, 13, Color(0.35, 0.4, 0.6), true)
	tcol.add_child(s)
	return band



func _highlights() -> void :
	var items: Array = []
	for v in _notes:
		for it in v.get("items", []):
			items.append(it)
	if items.is_empty():
		return
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_body.add_child(box)
	for it in items.slice(0, 3):
		box.add_child(_item_row(it, true))
	if items.size() > 3:
		var more: = KIT.label(tr("…y %d novedades más") % (items.size() - 3), 12, KIT.MUTED)
		box.add_child(more)
	box.name = "Highlights"





func _item_row(it: Dictionary, short: = false) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var tag: Array = TAGS.get(str(it.get("t", "new")), TAGS.new)
	var label: String = {"NUEVO": tr("NUEVO"), "MEJORA": tr("MEJORA"), "ARREGLO": tr("ARREGLO")}[tag[0]]
	var chip: = KIT.tag(label, tag[1], 10)
	chip.custom_minimum_size.x = 78
	chip.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	row.add_child(chip)
	var say: = str(it.get(_lang, it.get("en", it.get("es", ""))))
	if short:
		say = _first_sentence(say)
	var text: = KIT.label(say, 13, KIT.TEXT)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text)
	return row


func _offer_buttons() -> void :
	for c in _buttons.get_children():
		c.queue_free()
	var go: Button = KIT.button(tr("Abrir itch.io") if _full else tr("Actualizar ahora"), true)
	go.custom_minimum_size.x = 170
	go.pressed.connect( func():
		if _full:
			open_page.emit()
			_close_game()
		else:
			accepted.emit())
	_buttons.add_child(go)
	if not _notes.is_empty():
		var notes: Button = KIT.button(tr("Ver novedades"))
		notes.pressed.connect(_toggle_notes)
		notes.name = "NotesButton"
		_buttons.add_child(notes)
	if not _full and _new_build():
		_buttons.add_child(_itch_button(false))
	var later: Button = KIT.button(tr("Ahora no"))
	later.pressed.connect( func(): declined.emit())
	_buttons.add_child(later)
	go.grab_focus.call_deferred()






func _new_build() -> bool:
	if has_meta("new_build"):
		return true
	var up: = get_node_or_null("/root/Updater")
	if up == null or up.get("_eff_base") == null or up.get("_base") == null:
		return false
	return str(up.get("_eff_base")) != str(up.get("_base"))




func _itch_button(main: bool) -> Button:
	var b: Button = KIT.button(tr("Abrir itch.io"), main)
	b.pressed.connect( func():
		OS.shell_open(ITCH_PAGE)
		_close_game())
	return b






func _close_game() -> void :
	set_status(tr("Cerrando el juego para que puedas instalar la nueva versión…"))
	for c in _buttons.get_children():
		if c is Button:
			(c as Button).disabled = true
	await get_tree().create_timer(0.6, true, false, true).timeout
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()



func _toggle_notes() -> void :
	var show: = not _list_box.visible
	_list_box.visible = show
	var hl: = _body.find_child("Highlights", false, false)
	if hl != null:
		hl.visible = not show
	var nb: = _buttons.find_child("NotesButton", false, false) as Button
	if nb != null:
		nb.text = tr("Ocultar novedades") if show else tr("Ver novedades")
	if show and _list_box.get_child_count() == 0:
		_build_list()
	_fit()


func _build_list() -> void :
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.name = "Scroll"
	_list_box.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for v in _notes:
		var card: = PanelContainer.new()
		var cb: = StyleBoxFlat.new()
		cb.bg_color = Color(0.95, 0.96, 1.0)
		cb.border_color = Color(0.72, 0.78, 0.92)
		cb.set_border_width_all(1)
		cb.border_width_left = 4
		cb.border_color = Color(0.4, 0.52, 0.85)
		cb.set_corner_radius_all(6)
		cb.set_content_margin_all(10)
		card.add_theme_stylebox_override("panel", cb)
		list.add_child(card)
		var vcol: = VBoxContainer.new()
		vcol.add_theme_constant_override("separation", 6)
		card.add_child(vcol)
		vcol.add_child(KIT.label(tr("Versión %s") % str(v.get("version", "")), 14, Color(0.2, 0.3, 0.62), true))
		for it in v.get("items", []):
			vcol.add_child(_item_row(it))



func _fit() -> void :
	var view: = get_viewport().get_visible_rect().size
	var w: = clampf(view.x - 40.0, 360.0, 640.0)
	_panel.custom_minimum_size.x = w
	var scroll: = _list_box.find_child("Scroll", false, false) as ScrollContainer
	if scroll != null:
		var content: = scroll.get_child(0) as Control
		scroll.custom_minimum_size = Vector2(w - 40.0, minf(content.get_combined_minimum_size().y, maxf(160.0, view.y * 0.5)))




func set_status(text: String) -> void :
	_status.text = text
	_status.visible = text != ""


func start_progress() -> void :
	_bar.visible = true
	_bar.value = 0
	var hl: = _body.find_child("Highlights", false, false)
	if hl != null:
		hl.visible = false
	_list_box.visible = false
	for c in _buttons.get_children():
		c.queue_free()
	var later: Button = KIT.button(tr("Jugar sin actualizar"))
	later.pressed.connect( func(): declined.emit())
	_buttons.add_child(later)
	_fit()


func set_progress(value: float, text: String) -> void :
	_bar.value = value
	set_status(text)


func failed(text: String) -> void :
	_bar.visible = false
	set_status(text)
	for c in _buttons.get_children():
		c.queue_free()
	var ok: Button = KIT.button(tr("Jugar"), true)
	ok.pressed.connect( func(): declined.emit())
	_buttons.add_child(ok)

	if not _full and _new_build():
		_buttons.add_child(_itch_button(false))
	ok.grab_focus.call_deferred()



const SHORT_MAX: = 150

static func _first_sentence(s: String) -> String:
	var cut: = s.length()
	for mark in [". ", "。", "! ", "? "]:
		var at: = s.find(mark)
		if at > 0:
			cut = mini(cut, at + 1)
	var out: = s.substr(0, cut).strip_edges()
	if out.length() > SHORT_MAX:
		out = out.substr(0, SHORT_MAX - 3).strip_edges() + "..."
	return out
