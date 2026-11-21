extends Control








signal closed

const Oaths = preload("res://scripts/core/oaths.gd")
const OATH_RED: = Color(0.62, 0.06, 0.1)

var world: World

var stage_id: = ""

var tower: = false


func _ready() -> void :
	world.menus.ui_click()
	Save.set_setting("oaths_seen", true)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	gui_input.connect(_on_oath_input)
	_fill_oaths()
	grab_focus.call_deferred()



func _on_oath_input(ev: InputEvent) -> void :
	if ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode in [KEY_ESCAPE, KEY_J, KEY_ENTER, KEY_KP_ENTER]:
		accept_event()
		_close_oaths()
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		_close_oaths()


func _close_oaths() -> void :
	if is_queued_for_deletion():
		return
	world.menus.ui_click()
	closed.emit()
	queue_free()






var _oath_sel: = "tough"
var _oath_flash: = false


func _fill_oaths() -> void :
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var view: = get_viewport_rect().size
	var dim: = ColorRect.new()
	dim.color = Color(0.05, 0.0, 0.02, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var sworn: = Save.oaths()
	var pts: = GameData.oath_points(sworn)
	var top: = GameData.oath_max_points()
	if GameData.oath_def(_oath_sel).is_empty():
		_oath_sel = str(GameData.OATHS[0].id)
	var win: = PanelContainer.new()
	var wb: = UiKit.panel_box(UiKit.PANEL, OATH_RED, 12, 2)
	wb.set_content_margin_all(14)
	wb.shadow_color = Color(0, 0, 0, 0.45)
	wb.shadow_size = 12
	win.add_theme_stylebox_override("panel", wb)
	win.mouse_filter = Control.MOUSE_FILTER_STOP
	var win_w: = minf(720.0, view.x - 32.0)
	win.custom_minimum_size = Vector2(win_w, 0)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.add_child(win)


	var inner: = win_w - 28.0
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	win.add_child(col)

	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	col.add_child(head)
	var ht: = VBoxContainer.new()
	ht.add_theme_constant_override("separation", 0)
	ht.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(ht)
	ht.add_child(UiKit.label(tr("Juramentos"), 22, OATH_RED, true))
	var sub: = UiKit.label((tr("Castigos que eliges en la Torre de Hel (y en Infierno 15). Más Juramento: más Star Crumbs y mejor puesto en su ranking.") if tower
		else tr("Castigos que eliges en Infierno 15. Cada punto sube un %s%% tu puntaje en el ranking.") % str(snappedf((Oaths.score_mult(1) - 1.0) * 100.0, 0.1))), 11, UiKit.MUTED)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size.x = inner - 190.0
	ht.add_child(sub)
	var best: = Save.oath_best(stage_id) if stage_id != "" else 0
	if best > 0:
		ht.add_child(UiKit.label(tr("Tu mejor aquí: %d") % best, 11, Color(0.45, 0.5, 0.65), true))
	var total: = PanelContainer.new()
	var tb: = StyleBoxFlat.new()
	tb.bg_color = Color(0.56, 0.06, 0.11) if pts > 0 else Color(0.93, 0.9, 0.9)
	tb.set_corner_radius_all(10)
	tb.content_margin_left = 14
	tb.content_margin_right = 14
	tb.content_margin_top = 5
	tb.content_margin_bottom = 5
	tb.shadow_color = Color(0.4, 0.0, 0.05, 0.3) if pts > 0 else Color(0, 0, 0, 0)
	tb.shadow_size = 4
	total.add_theme_stylebox_override("panel", tb)
	total.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(total)
	var tcol: = VBoxContainer.new()
	tcol.add_theme_constant_override("separation", -2)
	total.add_child(tcol)
	var big: = UiKit.label(tr("Juramento %d") % pts, 20, Color(1.0, 0.95, 0.9) if pts > 0 else UiKit.MUTED, true)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tcol.add_child(big)
	var mult: = UiKit.label(tr("Puntaje x%s") % str(snappedf(Oaths.score_mult(pts), 0.01)), 12, Color(1.0, 0.8, 0.4) if pts > 0 else UiKit.MUTED, true)
	mult.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tcol.add_child(mult)


	tcol.add_child(_oath_prizes(pts))

	col.add_child(_oath_bar(pts, top, inner))

	var split: = HBoxContainer.new()
	split.add_theme_constant_override("separation", 12)
	col.add_child(split)
	var list_w: = floorf(inner * 0.46)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 2)
	list.custom_minimum_size.x = list_w
	split.add_child(list)
	for o in GameData.OATHS:
		list.add_child(_oath_item(o, int(sworn.get(str(o.id), 0))))
	split.add_child(_oath_detail(GameData.oath_def(_oath_sel), int(sworn.get(_oath_sel, 0)), inner - list_w - 12.0))

	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 8)
	col.add_child(foot)
	var clear: = UiKit.button(tr("Quitar todos"))
	clear.disabled = sworn.is_empty()
	clear.pressed.connect( func():
		for id in Save.oaths():
			Save.set_oath(str(id), 0)
		world.menus.ui_click()
		_fill_oaths())
	foot.add_child(clear)

	var maxed: = GameData.OATHS.all( func(o): return int(sworn.get(str(o.id), 0)) >= (o.ranks as Array).size())
	var all_b: = UiKit.button(tr("Jurar todos al máximo"))
	all_b.disabled = maxed
	all_b.pressed.connect( func():
		for o in GameData.OATHS:
			Save.set_oath(str(o.id), (o.ranks as Array).size())
		world.menus.ui_click()
		world.play_sound("refine_ok", 0.0, -8.0)
		_oath_flash = true
		_fill_oaths())
	foot.add_child(all_b)
	var note: = UiKit.label(tr("Quedan jurados para tus partidas en Infierno 15 y en la Torre de Hel hasta que los quites."), 10, UiKit.MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = inner - 420.0
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	foot.add_child(note)
	var ok: = UiKit.button(tr("Listo"), true)
	ok.custom_minimum_size.x = 110
	ok.pressed.connect(_close_oaths)
	foot.add_child(ok)

	if _oath_flash:
		_oath_flash = false
		total.pivot_offset = total.get_combined_minimum_size() * 0.5
		total.scale = Vector2(1.12, 1.12)
		total.create_tween().tween_property(total, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)





func _oath_prizes(pts: int) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	var crumb0: = GameData.HEL_TOWER_CRUMB + GameData.HEL_TOWER_CRUMB_STEP * 50.0 if tower else GameData.STAR_CRUMB_HELL + GameData.STAR_CRUMB_HELL_STEP * (15 - GameData.STAR_CRUMB_HELL_FROM)
	var crumb_step: = GameData.HEL_TOWER_CRUMB_OATH if tower else GameData.STAR_CRUMB_OATH_STEP
	var lit: = pts > 0
	for e in [
			["gold_coin", 1.0 + GameData.OATH_ZENY * pts, 
				tr("Zeny: +%d%% por punto de Juramento (bolsas, cofres y ventas).") % roundi(GameData.OATH_ZENY * 100.0)], 
			["oridecon", 1.0 + GameData.OATH_MATS * pts, 
				tr("Materiales de refinado (Oridecon, Elunium, Enriched, HD): +%d%% por punto de Juramento.") % roundi(GameData.OATH_MATS * 100.0)], 
			["star_crumb", (crumb0 + crumb_step * pts) / crumb0, 
				tr("Star Crumbs: salen más seguido con cada punto de Juramento (aquí, en la Torre de Hel a mitad de subida).") if tower
				else tr("Star Crumbs: salen más seguido con cada punto de Juramento (aquí, en Infierno 15).")]]:
		var cell: = HBoxContainer.new()
		cell.add_theme_constant_override("separation", 2)
		cell.mouse_filter = Control.MOUSE_FILTER_STOP
		cell.tooltip_text = str(e[2])
		var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(e[0])
		if ResourceLoader.exists(path):
			var ic: = UiKit.icon_rect(load(path) as Texture2D, 16)
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.add_child(ic)
		var l: = UiKit.label("x%s" % str(snappedf(float(e[1]), 0.01)), 11, Color(1.0, 0.92, 0.8) if lit else UiKit.MUTED, true)
		l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(l)
		row.add_child(cell)
	return row





func _oath_bar(pts: int, top: int, width: float) -> Control:
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	var bar: = HBoxContainer.new()
	bar.add_theme_constant_override("separation", 2)
	v.add_child(bar)
	var marks: = Control.new()
	marks.custom_minimum_size = Vector2(width, 14)
	v.add_child(marks)
	var step: = (width - 2.0 * (top - 1)) / float(top)
	for i in range(1, top + 1):
		var seg: = Panel.new()
		var sb: = StyleBoxFlat.new()
		sb.bg_color = OATH_RED.lerp(Color(0.85, 0.2, 0.15), float(i) / top) if i <= pts else Color(0.9, 0.84, 0.84)
		sb.set_corner_radius_all(3)
		seg.add_theme_stylebox_override("panel", sb)
		seg.custom_minimum_size = Vector2(step, 10)
		seg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(seg)
	for tid in ["oath_10", "oath_20", "oath_max"]:
		var d: Dictionary = GameData.TITLES[tid]
		var need: = int(d.get("goal", top))
		var have: bool = world.titles != null and world.titles.has(tid)
		var reach: = pts >= need
		var l: = UiKit.label(("✓ " if have else "") + "%d · %s" % [need, tr(str(d.name))], 10, 
			OATH_RED if reach else UiKit.MUTED, reach or have)
		l.tooltip_text = tr(str(d.desc)) + ("\n" + tr("Ya lo tienes") if have else "")
		l.mouse_filter = Control.MOUSE_FILTER_STOP
		marks.add_child(l)
		var x: = (step + 2.0) * need - 2.0 - step * 0.5
		var lw: = l.get_combined_minimum_size().x
		l.position = Vector2(clampf(x - lw * 0.5, 0.0, width - lw), 0.0)
		var tick: = ColorRect.new()
		tick.color = OATH_RED if reach else Color(0.7, 0.62, 0.62)
		tick.size = Vector2(2, 4)
		tick.position = Vector2(x - 1.0, -4.0)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marks.add_child(tick)
	return v




func _oath_item(o: Dictionary, r: int) -> Button:
	var sel: = str(o.id) == _oath_sel
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = Vector2(0, 32)
	for st in ["normal", "hover", "pressed"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(1, 1, 1) if sel else (Color(1.0, 0.95, 0.95) if st == "hover" else (Color(1.0, 0.97, 0.96) if r > 0 else Color(0, 0, 0, 0)))
		sb.border_color = OATH_RED if sel else Color(0, 0, 0, 0)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(8)
		sb.anti_aliasing = true
		b.add_theme_stylebox_override(st, sb)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 6
	row.offset_right = -8
	b.add_child(row)
	if r > 0:
		var edge_r: = ColorRect.new()
		edge_r.color = OATH_RED
		edge_r.custom_minimum_size = Vector2(3, 0)
		edge_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(edge_r)
	var ic: = UiKit.icon_rect(Oaths.icon(o), 24)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ic.modulate = Color.WHITE if r > 0 or sel else Color(1, 1, 1, 0.7)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(ic)
	var n: = UiKit.label(tr(str(o.name)), 12, OATH_RED if r > 0 else UiKit.TEXT, true)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	n.clip_text = true
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(n)
	var dots: = HBoxContainer.new()
	dots.add_theme_constant_override("separation", 3)
	dots.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dots)
	for i in (o.pts as Array).size():
		var dot: = Panel.new()
		var ds: = StyleBoxFlat.new()
		ds.bg_color = OATH_RED if i < r else Color.WHITE
		ds.border_color = OATH_RED if i < r else Color(0.78, 0.6, 0.6)
		ds.set_border_width_all(1)
		ds.set_corner_radius_all(5)
		ds.anti_aliasing = true
		dot.add_theme_stylebox_override("panel", ds)
		dot.custom_minimum_size = Vector2(9, 9)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dots.add_child(dot)
	b.tooltip_text = Oaths.rank_text(o, r) if r > 0 else tr("Sin jurar")

	if tower and GameData.HEL_TOWER_NO_OATHS.has(str(o.id)):
		b.modulate = Color(1, 1, 1, 0.5)
		b.tooltip_text += "\n" + tr("No cuenta en la Torre de Hel")
	var oid: = str(o.id)
	b.pressed.connect( func():
		if _oath_sel != oid:
			_oath_sel = oid
			world.menus.ui_click()
			_fill_oaths())
	return b





func _oath_detail(o: Dictionary, r: int, width: float) -> PanelContainer:
	var box: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1)
	sb.border_color = Color(0.9, 0.76, 0.76)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(12)
	box.add_theme_stylebox_override("panel", sb)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	box.add_child(v)
	var hd: = HBoxContainer.new()
	hd.add_theme_constant_override("separation", 10)
	v.add_child(hd)
	var ic: = UiKit.icon_rect(Oaths.icon(o), 40)
	hd.add_child(ic)
	var hv: = VBoxContainer.new()
	hv.add_theme_constant_override("separation", 0)
	hv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hd.add_child(hv)
	hv.add_child(UiKit.label(tr(str(o.name)), 16, OATH_RED, true))
	hv.add_child(UiKit.label(tr("Jurado: %s") % Oaths.rank_text(o, r) if r > 0 else tr("Sin jurar"), 11, UiKit.MUTED))
	var desc: = UiKit.label(tr(str(o.desc)), 11, UiKit.TEXT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = width - 26.0
	v.add_child(desc)
	var pts: Array = o.pts
	for i in range(0, pts.size() + 1):
		var on: = i == r
		var rb: = Button.new()
		rb.focus_mode = Control.FOCUS_NONE
		rb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		rb.custom_minimum_size = Vector2(0, 30)
		for st in ["normal", "hover", "pressed"]:
			var s2: = StyleBoxFlat.new()
			s2.bg_color = OATH_RED if on else (Color(1.0, 0.94, 0.93) if st == "hover" else Color(1, 1, 1))
			s2.border_color = OATH_RED if on else Color(0.9, 0.8, 0.8)
			s2.set_border_width_all(1)
			s2.set_corner_radius_all(8)
			s2.anti_aliasing = true
			rb.add_theme_stylebox_override(st, s2)
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row.offset_left = 8
		row.offset_right = -10
		rb.add_child(row)
		var num: = UiKit.label("—" if i == 0 else "I".repeat(i), 13, Color(1.0, 0.85, 0.5) if on else OATH_RED, true)
		num.custom_minimum_size.x = 26
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(num)
		var what: = UiKit.label(tr("Sin jurar") if i == 0 else Oaths.rank_text(o, i), 12, Color.WHITE if on else (UiKit.MUTED if i == 0 else UiKit.TEXT), on)
		what.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		what.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		what.clip_text = true
		what.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(what)
		var p: = UiKit.label("0" if i == 0 else "+%d" % int(pts[i - 1]), 12, Color(1.0, 0.85, 0.5) if on else UiKit.MUTED, true)
		p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(p)
		rb.tooltip_text = tr("Sin jurar") if i == 0 else "%s\n%s" % [Oaths.rank_text(o, i), Oaths.rank_tag(o, i)]
		var oid: = str(o.id)
		var pick: = i
		rb.pressed.connect( func():
			if pick == int(Save.oaths().get(oid, 0)):
				return
			Save.set_oath(oid, pick)
			world.menus.ui_click()
			if pick > 0:
				world.play_sound("refine_ok", 0.0, -8.0)
			_oath_flash = true
			_fill_oaths())
		v.add_child(rb)
	return box
