extends RefCounted









const ALL: = "all"
const MEDALS: = [Color(0.95, 0.72, 0.15), Color(0.68, 0.72, 0.8), Color(0.78, 0.5, 0.28)]
const CROWN: = "res://assets/ro/ui/skin/job_icons/crown.png"

const CARD_W: = 268.0





static func groups() -> Array:
	var out: = []
	for cid in GameData.CLASSES:
		var keys: = []
		for path in GameData.job_paths(str(cid)):
			keys.append(str(path.id))
		if keys.is_empty():
			keys.append(str(cid))
		out.append({"class": str(cid), "keys": keys})
	return out



static func keys() -> Array:
	var out: = [ALL]
	for g in groups():
		out.append_array(g.keys)
	return out


static func valid(key: String) -> bool:
	return keys().has(key)



static func path_of(key: String) -> Dictionary:
	for cid in GameData.CLASSES:
		for path in GameData.job_paths(str(cid)):
			if str(path.id) == key:
				return path
	return {}


static func class_of(key: String) -> String:
	if GameData.CLASSES.has(key):
		return key
	for cid in GameData.CLASSES:
		for path in GameData.job_paths(str(cid)):
			if str(path.id) == key:
				return str(cid)
	return ""





static func default_for(class_id: String) -> String:
	if not GameData.CLASSES.has(class_id):
		return ALL
	var paths: = GameData.job_paths(class_id)
	if paths.is_empty():
		return class_id
	var show: = str(Save.look(class_id).get("show", ""))
	if show != "":
		var k: = Leaderboard.job_key(class_id, {"id": show})
		if k != "":
			return k
	return str(paths[0].id)


static func _female(key: String) -> bool:
	var cid: = class_of(key)
	return cid != "" and str(Save.look(cid).get("gender", "m")) == "f"


static func name_of(key: String) -> String:
	if key == ALL:
		return TranslationServer.translate("General")
	var path: = path_of(key)
	if not path.is_empty():
		return TranslationServer.translate(GameData.job_title(path, _female(key)))
	if GameData.CLASSES.has(key):
		var d: Dictionary = GameData.CLASSES[key]
		return TranslationServer.translate(str(d.get("name_f", d.name)) if _female(key) else str(d.name))
	return key




static func sub_of(key: String) -> String:
	if key == ALL:
		return TranslationServer.translate("Todas las clases y oficios")
	var cid: = class_of(key)
	if cid == "":
		return ""
	var path: = path_of(key)
	if path.is_empty():
		return TranslationServer.translate("Sin segundo oficio")
	var bits: = [TranslationServer.translate(str(GameData.CLASSES[cid].name))]
	var trans: Dictionary = path.get("trans", {})
	if not trans.is_empty():
		bits.append(TranslationServer.translate(GameData.job_title(trans, _female(key))))
	return "  ·  ".join(bits)




static func icon_of(key: String) -> Texture2D:
	var path_tex: = CROWN
	if key != ALL:
		var path: = path_of(key)
		var en: = GameData.job_title(path, _female(key)) if not path.is_empty() else str(GameData.CLASSES.get(key, {}).get("name", ""))
		var id = GameData.JOB_ICON_IDS.get(en, GameData.JOB_ICON_IDS.get(str(path.get("name", "")), null))
		if id == null:
			return null
		path_tex = "res://assets/ro/ui/skin/job_icons/%d.png" % int(id)
	return load(path_tex) as Texture2D if ResourceLoader.exists(path_tex) else null


static func color_of(key: String) -> Color:
	var cid: = class_of(key)
	if cid == "":
		return UiKit.GOLD
	return GameData.CLASSES[cid].get("color", UiKit.GOLD)



static func champ_of(key: String) -> String:
	var id: = "champ_" + key
	return id if GameData.TITLES.has(id) else ""







static func selector(key: String, step: Callable, open: Callable, dir: = 0, keys_hint: = true) -> Control:
	var touch: = MouseWalk.touch()
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	col.add_child(row)
	row.add_child(_arrow("‹", func(): step.call(-1), "Q"))
	var mid: = Button.new()
	mid.focus_mode = Control.FOCUS_NONE
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.custom_minimum_size = Vector2(0, 44 if touch else 38)
	mid.tooltip_text = TranslationServer.translate("Elegir el ranking de otro oficio") + ("" if touch else "  (C)")
	mid.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var ink: = color_of(key)
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1).lerp(ink, 0.07)
	sb.border_color = ink.darkened(0.15)
	sb.set_border_width_all(1)
	sb.border_width_left = 4
	sb.set_corner_radius_all(7)
	sb.content_margin_left = 6
	sb.content_margin_right = 8
	var hover: = sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(1, 1, 1).lerp(ink, 0.14)
	hover.shadow_color = Color(ink, 0.35)
	hover.shadow_size = 4
	for k in ["normal", "focus", "disabled"]:
		mid.add_theme_stylebox_override(k, sb)
	mid.add_theme_stylebox_override("hover", hover)
	mid.add_theme_stylebox_override("pressed", hover)
	mid.pressed.connect(open)
	row.add_child(mid)
	var inner: = HBoxContainer.new()
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 8
	inner.offset_right = -8
	inner.add_theme_constant_override("separation", 7)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mid.add_child(inner)
	var ic: = UiKit.icon_rect(icon_of(key), 24)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	inner.add_child(ic)
	var texts: = VBoxContainer.new()
	texts.add_theme_constant_override("separation", -3)
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(texts)
	var nm: = UiKit.label("", 14, ink.darkened(0.45), true)
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiKit.fit_dots(nm, name_of(key))
	texts.add_child(nm)
	var sub: = UiKit.label("", 10, UiKit.MUTED)
	sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiKit.fit_dots(sub, sub_of(key))
	texts.add_child(sub)
	var more: = UiKit.label("▾", 14, ink.darkened(0.3), true)
	more.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	more.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inner.add_child(more)
	row.add_child(_arrow("›", func(): step.call(1), "E"))
	if keys_hint and not touch:
		var h: = UiKit.label(TranslationServer.translate("Q / E: cambiar de oficio  ·  C: ver todos"), 9, Color(UiKit.MUTED, 0.8))
		h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(h)

	if dir != 0:
		ic.scale = Vector2(0.4, 0.4)
		_when_ready(ic, func():
			if not is_instance_valid(ic):
				return
			ic.pivot_offset = ic.size * 0.5
			var tw: = ic.create_tween()
			tw.tween_property(ic, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))
		_slide_in(texts, dir, 0.0, 18.0)
	return col


static func _arrow(text: String, fn: Callable, key_hint: String) -> Button:
	var b: = UiKit.button(text)
	var touch: = MouseWalk.touch()
	b.custom_minimum_size = Vector2(40, 44) if touch else Vector2(28, 38)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 18)
	if not touch:
		b.tooltip_text = key_hint
	b.pressed.connect(fn)
	return b







static func picker(host: Control, current: String, on_pick: Callable, click: = Callable()) -> Control:
	var touch: = MouseWalk.touch()
	var layer: = Control.new()
	layer.name = "JobPicker"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	host.add_child(layer)
	var dim: = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)
	var win: = VBoxContainer.new()
	win.add_theme_constant_override("separation", 0)
	center.add_child(win)
	win.add_child(UiKit.soft_title(TranslationServer.translate("Rankings por oficio"), 16))
	var body: = PanelContainer.new()
	body.add_theme_stylebox_override("panel", UiKit.soft_body(14))
	win.add_child(body)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	body.add_child(col)
	var view: = host.get_viewport_rect().size
	var cols: = 3 if view.x >= CARD_W * 3.0 + 120.0 else 2
	var note: = UiKit.label(TranslationServer.translate("Cada segundo oficio tiene su ranking; las clases sin segundo oficio conservan el suyo. El #1 de cada oficio en las torres gana su título de campeón cada semana."), 11, UiKit.MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = CARD_W * cols + 8.0 * (cols - 1)
	col.add_child(note)
	var closing: = [false]
	var close: = func(picked: String):
		if closing[0]:
			return
		closing[0] = true
		if click.is_valid():
			click.call()
		var tw: = layer.create_tween().set_parallel(true)
		tw.tween_property(dim, "color:a", 0.0, 0.12)
		tw.tween_property(win, "modulate:a", 0.0, 0.12)
		tw.tween_property(win, "scale", Vector2(0.96, 0.96), 0.12)
		tw.chain().tween_callback( func():
			layer.queue_free()
			if picked != "":
				on_pick.call(picked))
	var buttons: Array[Button] = []
	var first: = _pick_chip(ALL, current == ALL, true, touch)
	first.pressed.connect( func(): close.call(ALL))
	col.add_child(first)
	buttons.append(first)
	var grid: = GridContainer.new()
	grid.columns = cols
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)

	var gscroll: = ScrollContainer.new()
	gscroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	gscroll.follow_focus = true
	col.add_child(gscroll)
	gscroll.add_child(grid)

	var nav: Array = [[first]]
	var gi: = 0
	for g in groups():
		if gi % cols == 0:
			nav.append([])
		gi += 1
		var cid: String = g. class 
		var card: = PanelContainer.new()
		var cb: = StyleBoxFlat.new()
		var ink: Color = color_of(cid)
		cb.bg_color = Color(0.965, 0.972, 0.99)
		cb.border_color = Color(0.84, 0.86, 0.93)
		cb.set_border_width_all(1)
		cb.border_width_top = 3
		cb.set_corner_radius_all(7)
		cb.set_content_margin_all(6)
		card.add_theme_stylebox_override("panel", cb)
		card.custom_minimum_size.x = CARD_W

		card.draw.connect( func(): card.draw_rect(Rect2(6, 0, card.size.x - 12, 3), Color(ink, 0.85)))
		grid.add_child(card)
		var cc: = VBoxContainer.new()
		cc.add_theme_constant_override("separation", 4)
		card.add_child(cc)
		var head: = HBoxContainer.new()
		head.add_theme_constant_override("separation", 4)
		cc.add_child(head)
		var cname: = UiKit.label(TranslationServer.translate(str(GameData.CLASSES[cid].name)), 11, ink.darkened(0.4), true)
		cname.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		head.add_child(cname)
		if (g.keys as Array).size() == 1 and str(g.keys[0]) == cid:
			head.add_child(UiKit.label(TranslationServer.translate("sin segundo oficio"), 9, UiKit.MUTED))
		var jobs: = HBoxContainer.new()
		jobs.add_theme_constant_override("separation", 4)
		cc.add_child(jobs)
		for k in g.keys:
			var key: String = k
			var b: = _pick_chip(key, key == current, false, touch)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.pressed.connect( func(): close.call(key))
			jobs.add_child(b)
			buttons.append(b)
			(nav[nav.size() - 1] as Array).append(b)
	var foot: = HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	col.add_child(foot)
	if not touch:
		foot.add_child(UiKit.label(TranslationServer.translate("Flechas: moverse  ·  Enter: elegir  ·  Esc: cerrar"), 10, UiKit.MUTED))
		var sp: = Control.new()
		sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		foot.add_child(sp)
		foot.move_child(sp, 0)
	var shut: = UiKit.button(TranslationServer.translate("Cerrar"))
	shut.focus_mode = Control.FOCUS_NONE
	if touch:
		shut.custom_minimum_size = Vector2(130, 46)
	shut.pressed.connect( func(): close.call(""))
	foot.add_child(shut)
	layer.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and not win.get_global_rect().has_point(ev.global_position):
			layer.accept_event()
			close.call("")
		elif ev.is_action_pressed("ui_cancel") or (ev is InputEventKey and ev.pressed and ev.keycode == KEY_C):
			layer.accept_event()
			close.call(""))

	for b in buttons:
		b.gui_input.connect( func(ev: InputEvent):
			if ev.is_action_pressed("ui_cancel") or (ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode == KEY_C):
				b.accept_event()
				close.call(""))

	win.modulate.a = 0.0
	for b in buttons:
		b.modulate.a = 0.0
	_when_ready(win, func():
		await win.get_tree().process_frame
		if not is_instance_valid(win):
			return
		_link_focus(nav)
		var gmin: = grid.get_combined_minimum_size()
		gscroll.custom_minimum_size = Vector2(gmin.x, minf(gmin.y, maxf(160.0, view.y - (win.size.y - gscroll.size.y) - 40.0)))
		await win.get_tree().process_frame
		if not is_instance_valid(win):
			return
		win.pivot_offset = win.size * 0.5
		win.scale = Vector2(0.94, 0.94)
		var tw: = win.create_tween().set_parallel(true)
		tw.tween_property(dim, "color:a", 0.55, 0.16)
		tw.tween_property(win, "modulate:a", 1.0, 0.16)
		tw.tween_property(win, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		for i in buttons.size():
			tw.tween_property(buttons[i], "modulate:a", 1.0, 0.14).set_delay(0.04 + 0.014 * i)

		for b in buttons:
			if b.has_meta("current"):
				b.grab_focus.call_deferred()
				return
		buttons[0].grab_focus.call_deferred())
	return layer





static func _link_focus(nav: Array) -> void :
	for r in nav.size():
		var row: Array = nav[r]
		for i in row.size():
			var b: Button = row[i]
			var x: = b.get_global_rect().get_center().x
			var near: = func(other: Array) -> Button:
				var best: Button = other[0]
				for o in other:
					if absf((o as Button).get_global_rect().get_center().x - x) < absf(best.get_global_rect().get_center().x - x):
						best = o
				return best
			b.focus_neighbor_left = b.get_path_to(row[posmod(i - 1, row.size())])
			b.focus_neighbor_right = b.get_path_to(row[(i + 1) % row.size()])
			b.focus_neighbor_top = b.get_path_to(near.call(nav[posmod(r - 1, nav.size())]))
			b.focus_neighbor_bottom = b.get_path_to(near.call(nav[(r + 1) % nav.size()]))
			b.focus_previous = b.focus_neighbor_left
			b.focus_next = b.focus_neighbor_right




static func _pick_chip(key: String, on: bool, wide: bool, touch: bool) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_ALL
	b.custom_minimum_size = Vector2(0, 46 if touch else 36)
	b.clip_text = true
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if on:
		b.set_meta("current", true)
	var ink: = color_of(key) if key != ALL else Color(0.85, 0.6, 0.15)
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.96, 0.82) if on else Color(1, 1, 1)
	sb.border_color = Color(0.88, 0.62, 0.12) if on else Color(0.8, 0.83, 0.92)
	sb.set_border_width_all(2 if on else 1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	var hover: = sb.duplicate() as StyleBoxFlat
	hover.bg_color = Color(1, 1, 1).lerp(ink, 0.12) if not on else sb.bg_color
	hover.border_color = ink.darkened(0.1) if not on else sb.border_color
	hover.shadow_color = Color(ink, 0.35)
	hover.shadow_size = 4
	var focus: = hover.duplicate() as StyleBoxFlat
	focus.border_color = UiKit.GOLD
	focus.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", focus)
	b.tooltip_text = sub_of(key)
	var inner: = HBoxContainer.new()
	inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inner.offset_left = 6
	inner.offset_right = -6
	inner.add_theme_constant_override("separation", 5)
	inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wide:
		inner.alignment = BoxContainer.ALIGNMENT_CENTER
	b.add_child(inner)
	var ic: = UiKit.icon_rect(icon_of(key), 20)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	inner.add_child(ic)
	var nm: = UiKit.label("", 12, ink.darkened(0.45) if on else UiKit.TEXT, on)
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL if not wide else Control.SIZE_SHRINK_CENTER
	nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if wide:
		nm.text = name_of(key) + "  ·  " + sub_of(key)
	else:
		UiKit.fit_dots(nm, name_of(key))
	inner.add_child(nm)
	if on:
		var tick: = UiKit.label("✓", 12, Color(0.75, 0.5, 0.05), true)
		tick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inner.add_child(tick)
	return b








static func champ_strip(world: Node, key: String) -> Control:
	var tid: = champ_of(key)
	if tid == "" or world == null:
		return null
	var ink: = color_of(key)
	var box: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.985, 0.94).lerp(ink, 0.05)
	sb.border_color = Color(0.9, 0.7, 0.3, 0.9)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(7)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	box.add_theme_stylebox_override("panel", sb)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	var pct: = roundi(float(GameData.TITLES[tid].effects.get("drop_find", 0.0)) * 100.0)
	box.tooltip_text = TranslationServer.translate("Cada lunes, el #1 de la semana con este oficio (subiendo en solitario la Endless Tower o la Torre de Hel; un piso de Hel cuenta como 100 + 5 pisos) gana «%s» durante una semana: +%d%% de probabilidad de drop. Varios títulos de campeón no suman su efecto.") % [_title_name(tid), pct]
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(col)

	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(top)
	if world.get("titles") != null:
		top.add_child(world.titles.chip(tid, 10))
	var holder: = UiKit.label("...", 11, UiKit.TEXT, true)
	holder.mouse_filter = Control.MOUSE_FILTER_PASS
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	holder.clip_text = true
	top.add_child(holder)
	var drop: = UiKit.label(TranslationServer.translate("+%d%% drop · semanal") % pct, 10, Color(0.15, 0.5, 0.25), true)
	drop.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(drop)
	var lead: = UiKit.label("", 10, UiKit.MUTED)
	lead.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(lead)
	var fill: = func(d: Dictionary):
		if not is_instance_valid(holder):
			return
		if d.is_empty():
			UiKit.fit_dots(holder, TranslationServer.translate("Sin conexión"))
			holder.add_theme_color_override("font_color", UiKit.MUTED)
			lead.visible = false
			return

		var champ = d.get("champ")
		if champ is Dictionary:
			var who: = "%s %s" % [str(champ.get("name", "")), str(champ.get("tag", ""))]
			UiKit.fit_dots(holder, "♛ " + who + ("  ·  " + TranslationServer.translate("¡eres tú!") if bool(champ.get("me", false)) else ""))
			holder.tooltip_text = TranslationServer.translate("Campeón esta semana: %s") % who
			holder.add_theme_color_override("font_color", Color(0.7, 0.45, 0.0) if bool(champ.get("me", false)) else Color(0.5, 0.33, 0.02))
		else:
			UiKit.fit_dots(holder, TranslationServer.translate("Nadie tiene este título esta semana."))
			holder.add_theme_color_override("font_color", UiKit.MUTED)
		var now: Array = d.get("now", [])
		var left: = maxi(0, int(d.get("ends", 0)) - int(Time.get_unix_time_from_system()))
		var ends: = TranslationServer.translate("cambia en %d d %d h") % [left / 86400, (left % 86400) / 3600]
		if now.is_empty():
			UiKit.fit_dots(lead, TranslationServer.translate("Nadie subió las torres con este oficio esta semana: ¡el título está libre!") + "  ·  " + ends)
		else:
			var r: Dictionary = now[0]
			var me = d.get("me")
			var mine: = ""
			if me is Dictionary and int(me.get("rank", 0)) > 1:
				mine = "  ·  " + TranslationServer.translate("tú: #%d") % int(me.rank)
			UiKit.fit_dots(lead, TranslationServer.translate("Va primero: %s (%s)") % ["%s %s" % [str(r.get("name", "")), str(r.get("tag", ""))], climb_text(r)]
				+ mine + "  ·  " + ends)
		lead.visible = true

		if box.is_inside_tree():
			box.modulate = Color(1.25, 1.2, 1.0)
			box.create_tween().tween_property(box, "modulate", Color.WHITE, 0.4)
	var board = world.get("board")
	if board != null:
		board.job_week(key, fill)
	else:
		fill.call({})
	return box


static func _title_name(tid: String) -> String:
	return TranslationServer.translate(str(GameData.TITLES[tid].name)) if GameData.TITLES.has(tid) else ""



static func climb_text(r: Dictionary) -> String:
	if str(r.get("tower", "")) == "hel":
		return TranslationServer.translate("Torre de Hel %d") % int(r.get("floor", 0))
	return TranslationServer.translate("Piso %d") % int(r.get("floor", 0))






static func reveal(rows: Array, dir: = 0) -> void :
	for i in rows.size():
		var r = rows[i]
		if r is Control and is_instance_valid(r):
			_slide_in(r, dir, 0.03 * i, 16.0)




static func _slide_in(c: Control, dir: int, delay: float, dist: float) -> void :
	c.modulate.a = 0.0
	_when_ready(c, func():
		if not is_instance_valid(c):
			return


		await c.get_tree().process_frame
		if not is_instance_valid(c) or not c.is_inside_tree():
			return
		await c.get_tree().process_frame
		if not is_instance_valid(c) or not c.is_inside_tree():
			return
		var home: = c.position
		c.position = home + (Vector2(dir * dist, 0) if dir != 0 else Vector2(0, dist * 0.6))
		var tw: = c.create_tween().set_parallel(true)
		tw.tween_property(c, "modulate:a", 1.0, 0.18).set_delay(delay)
		tw.tween_property(c, "position", home, 0.24).set_delay(delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT))




static func spotlight(row: Control, scroll: ScrollContainer, sb: StyleBoxFlat) -> void :
	_when_ready(row, func():
		if not is_instance_valid(row):
			return
		await row.get_tree().process_frame
		if not is_instance_valid(row):
			return
		await row.get_tree().process_frame
		if not is_instance_valid(row) or not row.is_inside_tree():
			return
		if scroll != null and is_instance_valid(scroll) and row.is_inside_tree():
			var want: = clampi(int(row.position.y - (scroll.size.y - row.size.y) * 0.5), 0, maxi(0, int(scroll.get_v_scroll_bar().max_value - scroll.size.y)))
			scroll.create_tween().tween_property(scroll, "scroll_vertical", want, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		if sb != null:
			var base: = sb.border_color
			var tw: = row.create_tween().set_loops(3)
			tw.tween_property(sb, "border_color", Color(1.0, 0.85, 0.3), 0.35)
			tw.tween_property(sb, "border_color", base, 0.35))



static func _when_ready(c: Node, fn: Callable) -> void :
	if c.is_node_ready() and c.is_inside_tree():
		fn.call_deferred()
	else:
		c.ready.connect(fn, CONNECT_ONE_SHOT)
