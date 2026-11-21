extends RefCounted








const ICON_PATH: = "res://assets/ro/ui/skin/item_icons/%s.png"
const NONE_COL: = Color(0.5, 0.54, 0.66)

const LAG_COL: = Color(0.92, 0.42, 0.08)
const FOCUS_COL: = Color(0.2, 0.45, 0.95)
const TILE: = 30.0






static func state(items: Dictionary, focus: = "", caption: = "") -> Dictionary:
	var h: = Equipment.harmony_of(items)
	var lv: = int(h.level)
	var n: = int(h.pieces)
	var top: = GameData.WEAPON_GRADES.size() - 1
	var tiles: = []
	var low: = 99
	for k in GameData.HARMONY_SLOTS:
		var it = items.get(k)
		var counted: = Equipment._harmony_piece(it)
		var icon: = ""
		if it is Dictionary and GameData.ITEMS.has(str((it as Dictionary).get("id", ""))):
			icon = str(Equipment.item_def(it).get("icon", ""))
		var g: = Equipment.grade(it) if counted else 0
		if counted:
			low = mini(low, g)
		tiles.append({"slot": k, "icon": icon, "grade": g, "counted": counted})
	var lag: = 0
	for t in tiles:
		t["lag"] = bool(t.counted) and int(t.grade) == low and n >= GameData.HARMONY_MIN_PIECES and lv < top
		if t.lag:
			lag += 1
	return {"level": lv, "pieces": n, "low": low if low < 99 else 0, "lag": lag, "low_slot": str(h.low), "tiles": tiles, "focus": focus, "caption": caption}



static func title(lv: int) -> String:
	return TranslationServer.translate("Armonía %s") % str(GameData.WEAPON_GRADES[lv].name) if lv > 0 else TranslationServer.translate("Sin armonía")


static func color(lv: int) -> Color:
	return GameData.WEAPON_GRADES[lv].color if lv > 0 else NONE_COL



static func what() -> String:
	return TranslationServer.translate("La Armonía es el grado más bajo entre tus piezas equipadas (mínimo %d, sin contar el arma): suma un %% extra a los bonos de grado de todas.")\
	%GameData.HARMONY_MIN_PIECES



static func bonus_text(lv: int) -> String:
	if lv <= 0:
		return ""
	return TranslationServer.translate("+%s%% a los bonos de grado") % GameData.grade_pct(float(GameData.HARMONY_SHARE[lv]))




static func hint_text(st: Dictionary) -> String:
	var lv: = int(st.level)
	var top: = GameData.WEAPON_GRADES.size() - 1
	if lv >= top:
		return TranslationServer.translate("Armonía máxima: todo tu equipo en grado %s") % str(GameData.WEAPON_GRADES[top].name)
	var n: = int(st.pieces)
	if n < GameData.HARMONY_MIN_PIECES:

		return TranslationServer.translate("Equipa al menos %d piezas (sin contar el arma) para tener Armonía: llevas %d") % [GameData.HARMONY_MIN_PIECES, n]
	var nx: = int(st.low) + 1
	var letter: = str(GameData.WEAPON_GRADES[nx].name)
	var pct: = GameData.grade_pct(float(GameData.HARMONY_SHARE[nx]))
	if int(st.lag) == 1:
		return TranslationServer.translate("Sube tu %s a grado %s para Armonía %s (+%s%%)") % [_slot_name(str(st.low_slot)), letter, letter, pct]

	return TranslationServer.translate("Sube a grado %s tus %d piezas más bajas para Armonía %s (+%s%%)") % [letter, int(st.lag), letter, pct]




static func hint_short(st: Dictionary) -> String:
	var lv: = int(st.level)
	var top: = GameData.WEAPON_GRADES.size() - 1
	if lv >= top:
		return TranslationServer.translate("Armonía máxima")
	if int(st.pieces) < GameData.HARMONY_MIN_PIECES:
		return TranslationServer.translate("Equipa %d+ piezas (sin el arma): llevas %d") % [GameData.HARMONY_MIN_PIECES, int(st.pieces)]
	var nx: = int(st.low) + 1
	var letter: = str(GameData.WEAPON_GRADES[nx].name)
	var pct: = GameData.grade_pct(float(GameData.HARMONY_SHARE[nx]))
	if int(st.lag) == 1:
		return TranslationServer.translate("%s a %s → Armonía %s (+%s%%)") % [_slot_name(str(st.low_slot)), letter, letter, pct]
	return TranslationServer.translate("%d piezas a %s → Armonía %s (+%s%%)") % [int(st.lag), letter, letter, pct]


static func _slot_name(slot: String) -> String:
	return TranslationServer.translate(str(GameData.SLOT_NAMES.get(slot, slot)))




static func hover_info(st: Dictionary) -> Dictionary:
	var lv: = int(st.level)
	var lines: = []
	for g in range(1, GameData.WEAPON_GRADES.size()):
		lines.append([title(g), TranslationServer.translate("+%s%% a los bonos de grado") % GameData.grade_pct(float(GameData.HARMONY_SHARE[g])), 
			GameData.WEAPON_GRADES[g].color])
	var foot: = [[title(lv) + ("  ·  " + bonus_text(lv) if lv > 0 else ""), color(lv)], [hint_text(st), LAG_COL]]
	return {"title": TranslationServer.translate("Armonía de grado"), "tag": str(st.get("caption", "")), "color": color(lv) if lv > 0 else Color(0.45, 0.52, 0.75), 
		"desc": what(), "lines": lines, "foot": foot}



static func medal(lv: int, size: = 22.0) -> PanelContainer:
	var col: = color(lv)
	var p: = PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.custom_minimum_size = Vector2(size, size)
	p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb: = StyleBoxFlat.new()
	sb.bg_color = col.darkened(0.12) if lv > 0 else Color(0.88, 0.9, 0.95)
	sb.border_color = col.darkened(0.45) if lv > 0 else NONE_COL
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(roundi(size * 0.3))
	sb.anti_aliasing = true
	p.add_theme_stylebox_override("panel", sb)
	var l: = UiKit.label(str(GameData.WEAPON_GRADES[lv].name) if lv > 0 else "-", roundi(size * 0.62), Color.WHITE if lv > 0 else NONE_COL, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if lv > 0:
		l.add_theme_color_override("font_outline_color", col.darkened(0.6))
		l.add_theme_constant_override("outline_size", 3)
	p.add_child(l)
	return p



static func help_button(st: Dictionary) -> Button:
	var b: = Button.new()
	b.text = "?"
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(19, 19)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.mouse_default_cursor_shape = Control.CURSOR_HELP
	var col: = Color(0.35, 0.45, 0.75)
	for s in ["normal", "hover", "pressed"]:
		var box: = StyleBoxFlat.new()
		box.bg_color = Color.WHITE if s == "normal" else Color.WHITE.lerp(col, 0.12)
		box.border_color = col
		box.set_border_width_all(1)
		box.set_corner_radius_all(10)
		box.anti_aliasing = true
		b.add_theme_stylebox_override(s, box)
	b.add_theme_font_override("font", UiKit.FONT_TITLE)
	b.add_theme_font_size_override("font_size", 11)
	for k in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(k, col.darkened(0.25))
	b.set_meta("hover", hover_info(st))
	b.set_meta("harmony_ui", true)
	return b











static func panel(st: Dictionary, opt: = {}) -> Control:
	var lv: = int(st.get("level", 0))
	var in_card: = opt.has("k")
	var k: = float(opt.get("k", 1.0))
	var col: = color(lv)
	var ink: = HoverCard.ink(col) if lv > 0 else Color(0.38, 0.41, 0.5)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 1)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wrap: Control = v
	if not in_card:
		var p: = PanelContainer.new()
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.97, 0.975, 1.0)
		sb.border_color = Color(col, 0.75) if lv > 0 else Color(0.78, 0.8, 0.88)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 5
		sb.content_margin_right = 4
		sb.content_margin_top = 2
		sb.content_margin_bottom = 2
		sb.anti_aliasing = true
		p.add_theme_stylebox_override("panel", sb)
		p.add_child(v)
		wrap = p
	if opt.has("width"):
		wrap.custom_minimum_size.x = float(opt.width)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(row)
	row.add_child(medal(lv, roundf(18.0 * k)))
	var name_l: = UiKit.label(title(lv), roundi(11 * k), ink, true)
	name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(name_l)
	if lv > 0:
		var b: = UiKit.label("·  " + bonus_text(lv), roundi(10 * k), Color(0.25, 0.27, 0.35))
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(b)
	var hint_l: Label = null
	if not in_card:

		var custom: Array = opt.get("hint", [])
		hint_l = UiKit.label(str(custom[0]) if not custom.is_empty() else "▸ " + hint_short(st), 10, 
			HoverCard.ink(custom[1]) if not custom.is_empty() else LAG_COL.darkened(0.25), true)
		hint_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hint_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if opt.get("two_lines", false):
			v.add_child(hint_l)
		else:
			hint_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			row.add_child(hint_l)
		if not custom.is_empty():
			hint_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		else:
			UiKit.fit_dots(hint_l)
		if opt.get("two_lines", false):
			var gap: = Control.new()
			gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(gap)
		row.add_child(help_button(st))
	elif opt.has("line"):
		var ln: Array = opt.line
		var l: = UiKit.label(str(ln[0]), roundi(10 * k), HoverCard.ink(ln[1]), true)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if opt.has("width"):
			l.custom_minimum_size.x = float(opt.width)
		v.add_child(l)
	return wrap
