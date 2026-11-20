extends Control





const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const RO_FONT = preload("res://assets/ro/fonts/SCDream4.otf")
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const ROWS: = 7
const BAR_W: = 150.0

var world: World
var _win: Control
var _title: Label
var _rows: Array[Dictionary] = []
var _warn: VBoxContainer
var _warn_title: Label
var _warn_sub: Label
var _warn_tween: Tween
var _banner: Control
var _banner_tween: Tween


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w: = UiStyles.hud_window(tr("MVP"), RO_FONT_BOLD)
	_win = w.root
	_title = w.title
	add_child(_win)
	for i in ROWS:
		var row: = VBoxContainer.new()
		row.add_theme_constant_override("separation", 0)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		w.body.add_child(row)
		var line: = HBoxContainer.new()
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(line)
		var name_l: = _text("", 10, Color.BLACK)
		name_l.custom_minimum_size.x = BAR_W - 28
		name_l.clip_text = true
		line.add_child(name_l)
		var secs: = _text("", 10, Color(0.2, 0.25, 0.4))
		secs.custom_minimum_size.x = 28
		secs.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		line.add_child(secs)
		var bar_blue: = UiStyles.hud_gauge("blue", BAR_W)
		var bar_red: = UiStyles.hud_gauge("red", BAR_W)
		row.add_child(bar_blue)
		row.add_child(bar_red)
		_rows.append({"row": row, "name": name_l, "secs": secs, "blue": bar_blue, "red": bar_red})
	_win.visible = false

	_warn = VBoxContainer.new()
	_warn.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_warn.offset_top = 170
	_warn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_warn)
	_warn_title = _text("", 26, Color(1, 0.85, 0.3), true)
	_warn_title.add_theme_color_override("font_outline_color", Color.BLACK)
	_warn_title.add_theme_constant_override("outline_size", 6)
	_warn_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warn.add_child(_warn_title)
	_warn_sub = _text("", 15, Color.WHITE)
	_warn_sub.add_theme_color_override("font_outline_color", Color.BLACK)
	_warn_sub.add_theme_constant_override("outline_size", 4)
	_warn_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warn.add_child(_warn_sub)
	_warn.modulate.a = 0.0


func _text(t: String, size: int, col: Color, bold: = false) -> Label:
	var l: = Label.new()
	l.text = t
	l.add_theme_font_override("font", RO_FONT_BOLD if bold else RO_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _process(_delta: float) -> void :
	if world == null or world.raid == null:
		return

	var raid = world.morroc if world.morroc != null and world.morroc.fighting() else world.raid
	var entries: Array = raid.dbm_entries()
	_win.visible = raid.state == "fight" and not entries.is_empty()
	if not _win.visible:
		return
	var view: = get_viewport().get_visible_rect().size
	var k: = maxf(1.0, floorf(view.y / 700.0))
	_win.scale = Vector2(k, k)
	_win.position = Vector2(8, roundf(view.y * 0.32))
	_title.text = tr("MVP · %s") % tr(GameData.MONSTERS[raid.mvp].name)
	for i in ROWS:
		var r: Dictionary = _rows[i]
		r.row.visible = i < entries.size()
		if i >= entries.size():
			continue
		var en: Dictionary = entries[i]
		var red: bool = en.now or (en.lethal and en.left < 5.0)
		r.name.text = en.name

		if r.get("now") != en.now:
			r["now"] = en.now
			r.name.add_theme_color_override("font_color", Color(0.7, 0.08, 0.08) if en.now else Color.BLACK)
		r.secs.text = "%.0f s" % ceilf(en.left) if en.left > 0.05 else ""
		r.blue.visible = not red
		r.red.visible = red
		var bar: ProgressBar = r.red if red else r.blue
		bar.max_value = maxf(0.1, en.total)
		bar.value = en.total - en.left if not en.now else en.left



func warn(text: String, col: Color, sound: = "") -> void :
	var parts: = text.split(": ", true, 1)
	_warn_title.text = parts[0] if parts.size() > 1 else text
	_warn_sub.text = parts[1] if parts.size() > 1 else ""
	_warn_title.add_theme_color_override("font_color", col)
	if sound != "" and world != null:
		world.play_sound(sound, 0.4, -2.0)
	if _warn_tween != null:
		_warn_tween.kill()
	_warn.modulate.a = 1.0
	_warn.pivot_offset = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 20)
	_warn.scale = Vector2.ONE * 1.25
	_warn_tween = create_tween()
	_warn_tween.tween_property(_warn, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_warn_tween.tween_interval(2.6)
	_warn_tween.tween_property(_warn, "modulate:a", 0.0, 0.5)



func big(title: String, sub: String, col: Color) -> void :
	warn(title + ": " + sub if sub != "" else title, col.lightened(0.25))



func mvp_alert(mvp_name: String, place: String, col: Color) -> void :
	if _banner != null and is_instance_valid(_banner):
		_banner.queue_free()
	var view: = get_viewport().get_visible_rect().size
	_banner = Control.new()
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.position = Vector2(0, roundf(view.y * 0.2))
	_banner.size = Vector2(view.x, 104)
	add_child(_banner)
	var strip: = ColorRect.new()
	strip.color = Color(0.06, 0.0, 0.04, 0.78)
	strip.size = _banner.size
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.add_child(strip)
	for y in [0.0, _banner.size.y - 3.0]:
		var edge: = ColorRect.new()
		edge.color = col
		edge.position = Vector2(0, y)
		edge.size = Vector2(view.x, 3)
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_banner.add_child(edge)
	var col_box: = VBoxContainer.new()
	col_box.size = _banner.size
	col_box.alignment = BoxContainer.ALIGNMENT_CENTER
	col_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.add_child(col_box)
	var t1: = _text(tr("¡ALERTA MVP!  %s") % mvp_name, 30, Color(1, 0.3, 0.25), true)
	t1.add_theme_color_override("font_outline_color", Color.BLACK)
	t1.add_theme_constant_override("outline_size", 6)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_box.add_child(t1)
	var t2: = _text(tr("Se abrió un portal a %s.  El tiempo se ha detenido: entra cuando estés listo.") % place, 14, Color(1, 0.92, 0.75))
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_box.add_child(t2)
	_banner.pivot_offset = _banner.size * 0.5
	_banner.scale = Vector2(1.0, 0.05)
	if _banner_tween != null:
		_banner_tween.kill()
	_banner_tween = _banner.create_tween()
	_banner_tween.tween_property(_banner, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_banner_tween.tween_property(t1, "modulate", Color(1.6, 1.4, 1.4), 0.25)
	_banner_tween.tween_property(t1, "modulate", Color.WHITE, 0.25)
	_banner_tween.tween_property(t1, "modulate", Color(1.6, 1.4, 1.4), 0.25)
	_banner_tween.tween_property(t1, "modulate", Color.WHITE, 0.25)
	_banner_tween.tween_interval(3.2)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.6)
	_banner_tween.tween_callback(_banner.queue_free)
