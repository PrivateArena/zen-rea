class_name HoverCard
extends CanvasLayer







const RO_FONT = preload("res://assets/ro/fonts/SCDream4.otf")
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const DEFAULT_COLOR: = Color(0.95, 0.8, 0.4)
const TEXT_W: = 230.0

var _card: PanelContainer
var _owner: Control
var _key: = ""

var test_target: Control


func _init() -> void :
	layer = 125
	process_mode = Node.PROCESS_MODE_ALWAYS




static func build(info: Dictionary) -> PanelContainer:
	var col: Color = info.get("color", DEFAULT_COLOR)
	var card: = PanelContainer.new()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.985, 0.99, 1.0, 0.97)
	box.border_color = ink(col).lerp(Color.WHITE, 0.25)
	box.set_border_width_all(1)
	box.border_width_top = 3
	box.set_corner_radius_all(8)
	box.set_content_margin_all(9)
	box.shadow_color = Color(0.03, 0.06, 0.18, 0.3)
	box.shadow_size = 7
	box.shadow_offset = Vector2(0, 3)
	box.anti_aliasing = true
	card.add_theme_stylebox_override("panel", box)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(head)
	var icon: Texture2D = info.get("icon")
	if icon != null:
		var frame: = PanelContainer.new()
		var fb: = StyleBoxFlat.new()
		fb.bg_color = Color.WHITE.lerp(col, 0.12)
		fb.border_color = Color(ink(col), 0.6)
		fb.set_border_width_all(1)
		fb.set_corner_radius_all(6)
		fb.anti_aliasing = true
		fb.set_content_margin_all(3)
		frame.add_theme_stylebox_override("panel", fb)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ir: = UiKit.icon_rect(icon, float(info.get("icon_size", 30)))
		ir.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(ir)
		head.add_child(frame)
	var tbox: = VBoxContainer.new()
	tbox.add_theme_constant_override("separation", 1)
	tbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(tbox)
	var title: = label(str(info.get("title", "")), 14, ink(col), true)
	if title.get_minimum_size().x > TEXT_W + 40.0:
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.custom_minimum_size.x = TEXT_W
	tbox.add_child(title)
	if str(info.get("tag", "")) != "":
		tbox.add_child(label(str(info.tag), 10, Color(0.42, 0.45, 0.56)))
	var lines: Array = info.get("lines", [])
	if not lines.is_empty():
		var sep: = ColorRect.new()
		sep.color = Color(ink(col), 0.25)
		sep.custom_minimum_size = Vector2(0, 1)
		sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(sep)
		var grid: = GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 1)
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(grid)
		for ln in lines:
			grid.add_child(label(str(ln[0]), 11, Color(0.4, 0.43, 0.54)))
			grid.add_child(label(str(ln[1]), 11, ink(ln[2]) if ln.size() > 2 and ln[2] is Color else Color(0.1, 0.13, 0.24), true))
	if str(info.get("desc", "")) != "":
		var d: = label(str(info.desc), 11, Color(0.22, 0.25, 0.36))
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size.x = TEXT_W
		v.add_child(d)
	if info.has("set"):
		v.add_child(set_block(info.set, true))
	for f in info.get("foot", []):
		var fl: = label(str(f[0]), 10, ink(f[1]), true)
		fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		fl.custom_minimum_size.x = TEXT_W
		v.add_child(fl)
	return card




static func ink(c: Color) -> Color:
	if c.s < 0.12 and c.v > 0.7:
		return Color(0.1, 0.13, 0.24)
	var l: = c.get_luminance()
	return c.darkened(clampf((l - 0.3) * 1.1, 0.0, 0.6)) if l > 0.35 else c


const SET_GOLD: = Color(1.0, 0.78, 0.3)
const SET_ON: = Color(0.45, 1.0, 0.55)









static func set_block(info: Dictionary, light: = false) -> PanelContainer:
	var active: bool = info.get("active", false)
	var gold: = SET_GOLD.darkened(0.35) if light else SET_GOLD
	var on: = Color(0.1, 0.55, 0.2) if light else SET_ON
	var off: = Color(0.5, 0.52, 0.6) if light else Color(0.55, 0.58, 0.68)
	var box: = PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(gold, 0.1) if not active else Color(on, 0.12)
	sb.border_color = Color(gold, 0.55) if not active else Color(on, 0.8)
	sb.set_border_width_all(1)
	sb.border_width_left = 3
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(6)
	box.add_theme_stylebox_override("panel", sb)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(col)
	var pieces: Array = info.get("pieces", [])
	var have: = pieces.filter( func(pc): return pc.have).size()
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(head)
	var title: = label(TranslationServer.translate("Set: %s") % str(info.get("name", "")), 11, gold if not active else on, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	head.add_child(label("%d/%d" % [have, pieces.size()], 11, on if active else gold, true))
	for pc in pieces:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 5)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(row)


		var stored: bool = pc.get("stored", false)
		var ic: = UiKit.icon_rect(pc.icon, 18)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ic.modulate = Color.WHITE if pc.have else Color(1, 1, 1, 0.65 if stored else 0.3)
		row.add_child(ic)
		var nm: = label(str(pc.name), 10, (Color(0.15, 0.17, 0.25) if light else Color(0.95, 0.96, 1.0)) if pc.have else off, pc.have)
		nm.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(nm)
		if stored:
			var where: = label(TranslationServer.translate("en tu almacén"), 9, Color(0.25, 0.45, 0.85) if light else Color(0.6, 0.78, 1.0))
			where.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(where)



	var need: = 2 if str(info.get("desc4", "")) != "" else pieces.size()
	var bonus: = label(TranslationServer.translate("Bono (%d): %s") % [need, str(info.get("desc", ""))], 10, on if active else off, active)
	bonus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus.custom_minimum_size.x = TEXT_W - 14
	col.add_child(bonus)

	if str(info.get("desc4", "")) != "":
		var active4: bool = info.get("active4", false)
		var bonus4: = label(TranslationServer.translate("Bono (4): %s") % str(info.desc4), 10, on if active4 else off, active4)
		bonus4.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bonus4.custom_minimum_size.x = TEXT_W - 14
		col.add_child(bonus4)
	if str(info.get("here", "")) != "":
		col.add_child(label(str(info.here), 9, off))
	return box


static func label(text: String, size: int, color: Color, bold: = false) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", RO_FONT_BOLD if bold else RO_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l



static func place(card: Control, ctrl: Control) -> void :
	if card == null or not is_instance_valid(ctrl):
		return
	var view: = ctrl.get_viewport().get_visible_rect().size
	var r: = ctrl.get_global_rect()
	var sz: = card.get_combined_minimum_size() * card.scale
	var pos: = Vector2(r.position.x + r.size.x * 0.5 - sz.x * 0.5, r.position.y - sz.y - 6)
	if pos.y < 4:
		pos = Vector2(r.position.x + r.size.x * 0.5 - sz.x * 0.5, r.end.y + 6)
	pos.x = clampf(pos.x, 4, view.x - sz.x - 4)
	pos.y = clampf(pos.y, 4, view.y - sz.y - 4)
	card.position = pos.floor()



static func from_text(text: String) -> Dictionary:
	var parts: = text.split("\n", false)
	if parts.is_empty():
		return {}
	var info: = {"title": parts[0]}
	if parts.size() > 1:
		info["desc"] = "\n".join(parts.slice(1))
	return info


func _process(_delta: float) -> void :
	var c: = test_target if is_instance_valid(test_target) else get_viewport().gui_get_hovered_control()
	var target: Control = null
	var hops: = 0
	while c != null and hops < 4:


		if c.tooltip_text != "":
			c.set_meta("hover_text", c.tooltip_text)
			c.tooltip_text = ""


		if c.has_meta("hover_fn") and not c.has_meta("hover"):
			c.set_meta("hover", (c.get_meta("hover_fn") as Callable).call())
		if c.has_meta("hover") or str(c.get_meta("hover_text", "")) != "":
			target = c
			break
		c = c.get_parent() as Control
		hops += 1
	var info: Dictionary = {}
	if target != null:
		info = target.get_meta("hover") if target.has_meta("hover") else from_text(str(target.get_meta("hover_text")))
	var key: = str(info.hash()) if not info.is_empty() else ""
	if target == _owner and key == _key:
		if _card != null:
			place(_card, target)


			if not _card.visible:
				_card.visible = true
				_card.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(_card, "modulate:a", 1.0, 0.08)
		return
	_hide()
	if info.is_empty():
		return
	_owner = target
	_key = key
	_card = build(info)
	var k: = maxf(1.0, floorf(target.get_global_transform_with_canvas().get_scale().x))
	_card.scale = Vector2(k, k)
	_card.modulate.a = 0.0
	_card.visible = false
	add_child(_card)
	place(_card, target)




func _hide() -> void :
	if _card != null and is_instance_valid(_card):
		_card.queue_free()
	_card = null
	_owner = null
	_key = ""
