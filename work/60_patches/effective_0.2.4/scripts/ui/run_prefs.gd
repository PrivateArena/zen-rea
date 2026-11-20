extends RefCounted


















static func _class_def(cid: String) -> Dictionary:
	if GameData.CLASSES[cid].get("custom", false):
		return GameData.sn_def(Save.sn_build())
	return GameData.CLASSES[cid]





static func sections(cid: String) -> Array:
	var d: = _class_def(cid)
	var out: = []
	var stats: = []
	for id in GameData.STATS:
		stats.append("stat:" + str(id))
	out.append([TranslationServer.translate("Atributos"), stats])
	var seen: = {}
	var collect: = func(job: Dictionary) -> Array:
		var keys: = []
		for list in [job.get("skills", []), job.get("skills_f", []), job.get("passives", [])]:
			for id in list:
				var sid: = str(id)
				if seen.has(sid) or not GameData.SKILLS.has(sid) or GameData.SKILLS[sid].get("evolved", false):
					continue
				seen[sid] = true
				keys.append("skill:" + sid)
		return keys
	out.append([TranslationServer.translate(str(d.name)), collect.call(d)])
	if not d.get("custom", false):
		for path in GameData.job_paths(cid):
			var keys: Array = collect.call(path)
			var title: = TranslationServer.translate(str(path.get("name", "")))
			var trans: Dictionary = path.get("trans", {})
			if not trans.is_empty():
				keys += collect.call(trans)
				if trans.has("name"):
					title += " / " + TranslationServer.translate(str(trans.name))
			if not keys.is_empty():
				out.append([title, keys])


	var copied: Array = []
	if cid == "thief":
		copied += Save.plagiarism_active()
	if Save.plagiarism_pick() != "":
		copied.append(Save.plagiarism_pick())
	var ckeys: = []
	for id in copied:
		var sid: = str(id)
		if seen.has(sid) or not GameData.SKILLS.has(sid) or GameData.SKILLS[sid].get("evolved", false):
			continue
		seen[sid] = true
		ckeys.append("skill:" + sid)
	if not ckeys.is_empty():
		out.append(["Plagiarism", ckeys])
	return out



static func ban_cap() -> int:
	return Save.upgrade_active("fly_wing")


static func _store(key: String, cid: String, list: Array) -> void :
	var all = Save.setting(key, {})
	var d: Dictionary = (all as Dictionary).duplicate() if all is Dictionary else {}
	if list.is_empty():
		d.erase(cid)
	else:
		d[cid] = list.duplicate()
	Save.set_setting(key, d)





static func prune(cid: String) -> void :
	var listed: = {}
	for sec in sections(cid):
		for key in sec[1]:
			listed[str(key)] = true
	for key in ["run_bans", "run_favs"]:
		var all = Save.setting(key, {})
		if not (all is Dictionary and all.get(cid) is Array):
			continue
		var mine: Array = all[cid]



		var fav: bool = key == "run_favs"
		var kept: = mine.filter( func(k): return listed.has(("skill:" + str(k)) if fav else str(k)))
		if kept.size() != mine.size():
			_store(key, cid, kept)



static func prep_button(menus: Menus, cid: String) -> Button:
	prune(cid)
	var n_ban: = mini(Player.saved_bans(cid).size(), ban_cap())
	var n_fav: = Player.saved_favs(cid).size()
	var b: = UiKit.button(TranslationServer.translate("Destierros y favoritas") + ("  (%d · ★%d)" % [n_ban, n_fav] if n_ban + n_fav > 0 else ""))
	b.tooltip_text = TranslationServer.translate("Elige qué habilidades o atributos no quieres ver en esta clase (gasta tus Holy Water al empezar) y hasta %d favoritas que salen el doble de seguido.") % GameData.RUN_FAV_MAX
	b.pressed.connect( func():
		menus.ui_click()
		open(menus, cid, false, func():
			if is_instance_valid(b):
				var nb: = mini(Player.saved_bans(cid).size(), ban_cap())
				var nf: = Player.saved_favs(cid).size()
				b.text = TranslationServer.translate("Destierros y favoritas") + ("  (%d · ★%d)" % [nb, nf] if nb + nf > 0 else "")))
	return b




static func speed_button(menus: Menus) -> Button:
	var b: = UiKit.button("")
	var paint: = func():
		var on: = bool(Save.setting("game_x2", false))
		b.text = TranslationServer.translate("Velocidad x2") + (" ✓" if on else "")
		b.add_theme_color_override("font_color", Color(0.8, 0.3, 0.15) if on else UiKit.TEXT)
	paint.call()
	b.tooltip_text = _speed_tip()
	b.pressed.connect( func():
		Save.set_setting("game_x2", not bool(Save.setting("game_x2", false)))
		menus.ui_click()
		paint.call())
	return b


static func _speed_tip() -> String:
	return TranslationServer.translate("Toda la partida va el doble de rápido, el MVP también: solo ahorra tiempo. No cambia premios ni récords (cuentan el tiempo de juego). En grupo decide el líder.")





static func pause_button(menus: Menus) -> Button:
	var world: = menus.world
	var b: = Button.new()
	b.flat = true
	b.text = "★"
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color(0.85, 0.6, 0.1))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.75, 0.2))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.tooltip_text = TranslationServer.translate("Destierros y favoritas") + """
""" + TranslationServer.translate("Para tus próximas partidas con esta clase.")
	b.pressed.connect( func():
		menus.ui_click()
		open(menus, world.player.class_id, true))
	return b




static func open(menus: Menus, cid: String, in_run: bool, closed: = Callable()) -> void :
	var back: = menus._mode
	menus._mode = "run_prefs"
	prune(cid)
	var root: Control = menus._root
	var shade: = UiKit.backdrop(0.55)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shade)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var window: = VBoxContainer.new()
	window.add_theme_constant_override("separation", 0)
	center.add_child(window)
	window.add_child(UiKit.soft_title(TranslationServer.translate("Destierros y favoritas"), 17))
	var panel: = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.soft_body(14))
	window.add_child(panel)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	panel.add_child(col)
	var width: = 440.0
	var cap: = ban_cap()
	var hint: = UiKit.label(TranslationServer.translate("%s: lo desterrado no aparece al subir de nivel y cada uno gasta un Holy Water al empezar la partida. Las favoritas salen el doble de seguido.") % TranslationServer.translate(str(_class_def(cid).name)), 13, UiKit.MUTED)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size.x = width
	col.add_child(hint)
	if in_run:
		var later: = UiKit.label(TranslationServer.translate("Se aplica desde tu próxima partida."), 12, Color(0.25, 0.4, 0.8))
		later.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		later.custom_minimum_size.x = width
		col.add_child(later)
	var counts: = UiKit.label("", 13, UiKit.TEXT, true)
	counts.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	counts.custom_minimum_size.x = width
	col.add_child(counts)
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 2)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var bans: = Player.saved_bans(cid)
	var favs: = Player.saved_favs(cid)
	var fill: = [Callable()]
	fill[0] = func():
		for c in list.get_children():
			list.remove_child(c)
			c.queue_free()
		var n_ban: = bans.size()

		var no_water: String = TranslationServer.translate("Holy Water desactivada en el Sabio: actívala para que se apliquen los destierros.")\
		if Save.upgrade_level("fly_wing") > 0 else TranslationServer.translate("Sin Holy Water: cómprala al Sabio para desterrar antes de la partida.")
		var ban_line: String = TranslationServer.translate("Destierros: %d / %d (Holy Water del Sabio)") % [n_ban, cap] if cap > 0 else no_water
		if cap > 0 and n_ban > cap:
			ban_line += " " + TranslationServer.translate("(solo se aplican los primeros %d)") % cap
		counts.text = ban_line + "   ·   " + TranslationServer.translate("Favoritas: %d / %d") % [favs.size(), GameData.RUN_FAV_MAX]
		counts.add_theme_color_override("font_color", Color(0.75, 0.25, 0.2) if n_ban > cap else UiKit.TEXT)
		for sec in sections(cid):
			var head: = UiKit.label(str(sec[0]), 13, UiKit.GOLD, true)
			list.add_child(head)
			for key in sec[1]:
				list.add_child(_row(menus, str(key), bans, favs, cap, fill[0], cid))
		var view: = root.get_viewport_rect().size
		scroll.custom_minimum_size = Vector2(width, minf(list.get_combined_minimum_size().y, maxf(200.0, view.y * 0.55)))
	var buttons: = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_END
	buttons.add_theme_constant_override("separation", 8)
	col.add_child(buttons)
	var clear: = UiKit.button(TranslationServer.translate("Vaciar"))
	clear.pressed.connect( func():
		bans.clear()
		favs.clear()
		_store("run_bans", cid, bans)
		_store("run_favs", cid, favs)
		menus.ui_click()
		fill[0].call_deferred())
	buttons.add_child(clear)
	var done: = UiKit.button(TranslationServer.translate("Listo"), true)
	done.pressed.connect( func():
		shade.queue_free()
		center.queue_free()
		menus._mode = back


		var net = menus.world.net

		if net != null and net.is_client() and cid == net.my_class:
			net.update_class(net.my_class)
		if closed.is_valid():
			closed.call())
	buttons.add_child(done)
	fill[0].call()
	menus._pop_in(window)

	done.grab_focus.call_deferred()




static func _row(menus: Menus, key: String, bans: Array, favs: Array, cap: int, refill: Callable, cid: String) -> Control:
	var stat: = key.begins_with("stat:")
	var id: = key.substr(5) if stat else key.substr(6)
	var banned: = bans.has(key)
	var fav: = favs.has(id)
	var row: = PanelContainer.new()

	if not stat:
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		menus._set_hover(row, menus._pick_skill_card(id))
	var st: = StyleBoxFlat.new()
	st.bg_color = Color(1.0, 0.9, 0.88) if banned else (Color(1.0, 0.96, 0.82) if fav else Color(0.95, 0.96, 0.99))
	st.set_corner_radius_all(8)
	st.content_margin_left = 6
	st.content_margin_right = 6
	st.content_margin_top = 2
	st.content_margin_bottom = 2
	row.add_theme_stylebox_override("panel", st)
	var line: = HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	row.add_child(line)
	if stat:
		var tag: = UiKit.label(TranslationServer.translate(str(GameData.STATS[id].name)), 13, Color(0.25, 0.4, 0.8), true)
		tag.custom_minimum_size = Vector2(30, 30)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(tag)
	else:
		line.add_child(UiKit.icon_rect(UiKit.skill_icon(id), 30))
	var shown: = TranslationServer.translate(str(GameData.STATS[id].full if stat else GameData.SKILLS[id].name))
	if not stat and Player.is_passive(id):
		shown += "  " + TranslationServer.translate("(pasiva)")
	var name_l: = UiKit.label(shown, 14, UiKit.MUTED if banned else UiKit.TEXT, fav)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_l.clip_text = true
	line.add_child(name_l)
	if not stat:
		var star: = UiKit.button("★")
		star.custom_minimum_size = Vector2(40, 34)
		star.focus_mode = Control.FOCUS_NONE
		star.add_theme_color_override("font_color", Color(0.9, 0.62, 0.1) if fav else Color(0.72, 0.75, 0.85))
		star.add_theme_color_override("font_hover_color", Color(0.95, 0.7, 0.15))
		star.tooltip_text = TranslationServer.translate("Favorita: sale el doble de seguido")
		star.disabled = not fav and favs.size() >= GameData.RUN_FAV_MAX
		star.pressed.connect( func():
			if favs.has(id):
				favs.erase(id)
			elif favs.size() < GameData.RUN_FAV_MAX:
				favs.append(id)
				bans.erase(key)
				_store("run_bans", cid, bans)
			_store("run_favs", cid, favs)
			menus.ui_click()
			refill.call_deferred())
		line.add_child(star)


	var idle: = banned and bans.find(key) >= cap
	var ban: = UiKit.button(TranslationServer.translate("No se aplica") if idle
		else (TranslationServer.translate("Desterrada") if banned else TranslationServer.translate("Desterrar")))
	ban.custom_minimum_size = Vector2(112, 34)
	ban.focus_mode = Control.FOCUS_NONE
	ban.add_theme_font_size_override("font_size", 13)
	if idle:
		ban.add_theme_color_override("font_color", UiKit.MUTED)
		ban.tooltip_text = TranslationServer.translate("No te queda Holy Water para este destierro: no se aplica al empezar. Pulsa para quitarlo.")
	elif banned:
		ban.add_theme_color_override("font_color", Color(0.8, 0.2, 0.15))
	ban.disabled = not banned and bans.size() >= cap
	ban.pressed.connect( func():
		if bans.has(key):
			bans.erase(key)
		elif bans.size() < cap:
			bans.append(key)
			favs.erase(id)
			_store("run_favs", cid, favs)
		_store("run_bans", cid, bans)
		menus.ui_click()
		refill.call_deferred())
	line.add_child(ban)
	return row
