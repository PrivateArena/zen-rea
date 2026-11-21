extends RefCounted











const ROWS: = [["all_pct", "Todos los atributos", true], 
	["dmg", "Daño", true], ["grade_mult", "Daño del grado del arma", true], ["skill_dmg", "Daño de habilidades", true], 
	["basic_dmg", "Daño básico", true], ["proc_dmg", "Daño de procs", true], ["proc_power", "Poder de procs", true], 




	["vs_boss", "Daño a jefes, MVP y élites", true], ["vs_mvp", "Daño extra a MVP", true], ["double_cast", "Doble lanzamiento", true], 
	["double", "Golpe doble", true], ["crit", "Crítico", true], ["crit_dmg", "Daño crítico", true], 
	["aspd", "Vel. de ataque", true], ["haste", "Recarga", true], ["grade_haste", "Recarga del grado", true], 
	["area", "Área", true], ["duration", "Duración", true], ["buff_power", "Poder de bufos", true], 
	["proc_chance", "Prob. de efectos de cartas", true], 


	["skill_burn", "Probabilidad de quemar", true], ["burn_power", "Daño de quemaduras", true], 
	["bleed_hit", "Sangrado con el ataque básico", true], 





	["bleed_power", "Potencia de sangrado", true], ["bleed_dmg", "Daño de sangrado", true], ["poison_dmg", "Daño de veneno", true], 

	["poison_cap", "Cargas máx. de veneno", true], ["poison_stack", "Cargas por dosis", false], 
	["poison_growth", "Crecimiento del veneno", true], ["poison_amp", "Corrosión del veneno", true], 
	["summon_dmg", "Daño de invocaciones", true], ["falcon_dmg", "Daño del halcón", true], ["status_chance", "Probabilidad de estados", true], 
	["status_time", "Duración de estados", true], ["wing_fill", "Llenado del Aguante", true], 
	["wing_broken", "Daño a jefes aturdidos", true], 
	["max_hp_pct", "Vida máx.", true], ["grade_hp", "Vida máx. del grado", true], ["max_hp", "Vida", false], 
	["armor", "Defensa", false], ["dodge", "Evasión", true], ["grade_mech", "Menos daño de mecánicas", true], 
	["grade_hit", "Menos daño recibido", true], ["heal_power", "Curación", true], ["kill_heal", "Curación al matar", true], ["lifesteal", "Robo de vida", true], 
	["regen", "Vida/s", false], ["move", "Velocidad", true], ["loot", "Zeny", true], ["xp", "EXP", true], 
	["card", "Probabilidad de cartas", true], ["drop_find", "Probabilidad de drop", true]]


const EFFECT_ROWS: = ["proc_power", "double_cast", "buff_power", "vs_boss", "double", "burn_power", "bleed_power", "bleed_dmg", 
	"poison_dmg", "poison_cap", "poison_stack", "poison_growth", "poison_amp", "summon_dmg", "status_chance", "status_time", "wing_fill", "wing_broken", "heal_power", "lifesteal", 
	"drop_find", "proc_chance", "skill_burn", "bleed_hit", "kill_heal"]




static func _row_names() -> Array:
	return [TranslationServer.translate("Poder de procs"), TranslationServer.translate("Poder de bufos"), 
		TranslationServer.translate("Todos los atributos"), TranslationServer.translate("Daño del grado del arma"), 
		TranslationServer.translate("Golpe doble"), TranslationServer.translate("Recarga del grado"), 
		TranslationServer.translate("Daño de quemaduras"), TranslationServer.translate("Daño de sangrado"), 
		TranslationServer.translate("Potencia de sangrado"), 
		TranslationServer.translate("Daño de veneno"), TranslationServer.translate("Daño de invocaciones"), 
		TranslationServer.translate("Probabilidad de estados"), TranslationServer.translate("Duración de estados"), 
		TranslationServer.translate("Llenado del Aguante"), TranslationServer.translate("Daño a jefes aturdidos"), 
		TranslationServer.translate("Daño a jefes, MVP y élites"), TranslationServer.translate("Daño extra a MVP"), 
		TranslationServer.translate("Vida máx. del grado"), TranslationServer.translate("Menos daño de mecánicas"), 
		TranslationServer.translate("Menos daño recibido"), TranslationServer.translate("Probabilidad de cartas"), 
		TranslationServer.translate("Potencial"), TranslationServer.translate("Cargas máx. de veneno"), 
		TranslationServer.translate("Cargas por dosis"), TranslationServer.translate("Crecimiento del veneno"), 
		TranslationServer.translate("Corrosión del veneno"), TranslationServer.translate("Probabilidad de drop")]


static func _add(into: Dictionary, mods: Dictionary, share: = 1.0) -> void :
	for k in mods:
		into[k] = float(into.get(k, 0.0)) + float(mods[k]) * share



static func _shown(effects: Variant) -> Dictionary:
	var out: = {}
	if effects is Dictionary:
		for k in EFFECT_ROWS:
			if (effects as Dictionary).has(k):
				out[k] = float(effects[k])


		if (effects as Dictionary).has("u_goldbug"):
			out["grade_mech"] = float(out.get("grade_mech", 0.0)) + float(effects.u_goldbug)
	return out



static func _sources(eq: Equipment, album: Array, dishes: Array, pet: String, pacts: Array, meta: Dictionary) -> Array:
	var gear: = {}
	var pot: = {}
	var cards: = {}
	var sets: = {}
	var food: = {}
	var pet_mods: = {}
	var pact_mods: = {}
	var harm: = {}
	var harmony: = {}
	if eq != null:
		for k in eq.slots:
			var it = eq.slots[k]
			if it == null:
				continue

			var share: = eq.offhand_mult(it) if k == "shield" and Equipment.item_type(it) == "weapon" else 1.0
			_add(gear, Equipment._base_mods(it, int(it.refine)), share)
			_add(gear, _shown(Equipment.item_effects(it)), share)


			_add(gear, _shown(Equipment.trait_of(it).get("fx", {})))

			var g: = Equipment.grade(it)
			if g > 0 and Equipment.item_type(it) == "weapon":
				_add(gear, {"grade_mult": float(GameData.WEAPON_GRADES[g].dmg)}, share)
			elif g > 0 and GameData.GEAR_GRADES.has(Equipment.item_type(it)):
				var gg: Dictionary = GameData.GEAR_GRADES[Equipment.item_type(it)]
				for gk in gg.keys:
					_add(gear, {gk: float(gg.vals[g])}, share)

			if Equipment.item_def(it).get("wings", false):
				_add(gear, _shown(GameData.wing_fx(int(it.get("refine", 0)))), share)

			_add(pot, Equipment.Potential.mods(it), share)
			_add(pot, _shown(Equipment.Potential.fx(it)), share)


			var wing_k: = 0.0
			if Equipment.item_def(it).get("wings", false):
				wing_k = float(GameData.wing_fx(int(it.get("refine", 0))).get("wing_card", 0.0))
			for c in it.get("cards", []):
				if GameData.CARDS.has(c):
					for part in [GameData.CARDS[c].mods, _shown(GameData.CARDS[c].get("effects", {}))]:
						var more: = {}
						for mk in part:
							more[mk] = float(part[mk]) * (1.0 + wing_k if float(part[mk]) > 0.0 else 1.0)
						_add(cards, more, share)
		for sid in eq.active_sets(eq.socketed_cards() + album):
			_add(sets, GameData.set_part(sid).get("mods", {}))
			_add(sets, _shown(GameData.set_part(sid).get("effects", {})))

		harmony = Equipment.harmony_of(eq.slots)
		_add(harm, Equipment.harmony_mods(eq.slots, int(harmony.level)))
	for c in album:
		if GameData.CARDS.has(c):
			_add(cards, GameData.CARDS[c].mods)
			_add(cards, _shown(GameData.CARDS[c].get("effects", {})))
	for d in dishes:
		_add(food, GameData.RECIPES.get(str(d), {}).get("mods", {}))
		_add(food, _shown(GameData.RECIPES.get(str(d), {}).get("effects", {})))
	if GameData.PETS.has(pet):
		_add(pet_mods, GameData.PETS[pet].get("mods", {}))
		_add(pet_mods, _shown(GameData.PETS[pet].get("effects", {})))


	for id in pacts:
		_add(pact_mods, GameData.PACTS.get(str(id), {}).get("mods", {}))
		_add(pact_mods, _shown(GameData.PACTS.get(str(id), {}).get("effects", {})))

	return [[TranslationServer.translate("Equipo"), gear], [TranslationServer.translate("Armonía"), harm, harmony], 
		[TranslationServer.translate("Potencial"), pot], [TranslationServer.translate("Cartas"), cards], 
		[TranslationServer.translate("Sets"), sets], [TranslationServer.translate("Platos"), food], 
		[TranslationServer.translate("Mascota"), pet_mods], [TranslationServer.translate("Pactos"), pact_mods], ["Kafra", meta]]



static func of_player(p: Player) -> Array:
	return _sources(p.equipment, p.album_cards, p.dishes, p.pet_id, p.pacts, p.meta)




static func of_class(cid: String) -> Array:
	var profile: = Player.profile_of(cid)
	var eq: = Equipment.new(cid)
	var gear: Dictionary = profile.get("gear", {})
	for slot_key in gear:
		var stored: Dictionary = gear[slot_key]
		if stored.is_empty() or not GameData.ITEMS.has(str(stored.id)) or not eq.slots.has(slot_key):
			continue
		if slot_key == "weapon" and GameData.ITEMS[stored.id].slot != "weapon":
			continue
		eq.slots[slot_key] = Equipment.from_storage(stored)
	var dishes: Array = (profile.get("dishes", []) as Array).filter( func(d): return GameData.RECIPES.has(str(d)))
	return _sources(eq, profile.get("cards", []), dishes, str(profile.get("pet", "")), 
		(profile.get("pacts", []) as Array).slice(0, GameData.MAX_PACTS), profile.get("meta", {}))


static func _cell(menus: Menus, text: String, color: Color, bold: = false, right: = true) -> Label:
	var l: Label = menus._ro_text(text, 12, color, bold)
	if right:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func _value(row: Array, v: float) -> String:
	if bool(row[2]):

		if str(row[0]) == "haste":
			return "-%d%%" % roundi(v * 100.0)


		var p: = v * 100.0
		return "%+d%%" % roundi(p) if absf(p - roundf(p)) < 0.05 else "%+.1f%%" % p
	return "%+d" % roundi(v) if absf(v) >= 10.0 else "%+.1f" % v



static func open(menus: Menus, sources: Array, then: = Callable()) -> void :
	var w: Dictionary = menus._float_window(TranslationServer.translate("Resumen de bonos"), then, 0.8)


	var sheet: = PanelContainer.new()
	var paper: = StyleBoxFlat.new()
	paper.bg_color = Color(0.96, 0.97, 1.0)
	paper.set_content_margin_all(8)
	paper.set_corner_radius_all(4)
	sheet.add_theme_stylebox_override("panel", paper)
	(w.body as Control).add_child(sheet)
	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	sheet.add_child(body)


	for s in sources:
		var hs: Dictionary = s[2] if (s as Array).size() > 2 and s[2] is Dictionary else {}
		if int(hs.get("graded", 0)) <= 0:
			continue
		var hl: Array = menus._harmony_lines(hs)
		var hlab: Label = menus._ro_text(str(hl[0]) + ("  ·  " + str(hl[1]) if str(hl[1]) != "" else ""), UiKit.text_size(12, 1.15), hl[2], true)
		hlab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hlab.custom_minimum_size.x = 320
		body.add_child(hlab)
	var cols: Array = sources.filter( func(s): return ROWS.any( func(r): return absf(float((s[1] as Dictionary).get(r[0], 0.0))) >= 0.0005))
	var rows: Array = ROWS.filter( func(r): return cols.any( func(s): return absf(float((s[1] as Dictionary).get(r[0], 0.0))) >= 0.0005))
	if rows.is_empty():
		var none: Label = menus._ro_text(TranslationServer.translate("Tu equipo, tus cartas y tus platos aún no dan bonos."), 12, Color(0.27, 0.29, 0.37))
		none.custom_minimum_size.x = 320
		body.add_child(none)
	else:
		var grid: = GridContainer.new()
		grid.columns = cols.size() + 2
		grid.add_theme_constant_override("h_separation", 16)
		grid.add_theme_constant_override("v_separation", 5)


		var scroll: = ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.add_child(grid)
		body.add_child(scroll)

		var fit: = func():
			if not is_instance_valid(scroll):
				return
			var room: = menus.get_viewport().get_visible_rect().size.y - 240.0
			scroll.custom_minimum_size.y = minf(grid.get_combined_minimum_size().y, maxf(160.0, room))
			scroll.custom_minimum_size.x = grid.get_combined_minimum_size().x + 12.0
		scroll.custom_minimum_size.y = 160.0
		grid.minimum_size_changed.connect(fit)
		fit.call_deferred()
		var head: = Color(0.12, 0.25, 0.75)
		grid.add_child(_cell(menus, "", head, true, false))
		for s in cols:
			grid.add_child(_cell(menus, str(s[0]), head, true))
		grid.add_child(_cell(menus, TranslationServer.translate("Total"), Color(0.7, 0.42, 0.05), true))
		for r in rows:
			grid.add_child(_cell(menus, TranslationServer.translate(str(r[1])), Color(0.15, 0.17, 0.3), true, false))
			var total: = 0.0
			for s in cols:
				var v: = float((s[1] as Dictionary).get(r[0], 0.0))
				total += v
				if absf(v) < 0.0005:
					grid.add_child(_cell(menus, "·", Color(0.7, 0.72, 0.78)))
				else:

					var good: = v > 0.0
					grid.add_child(_cell(menus, _value(r, v), Color(0.1, 0.5, 0.2) if good else Color(0.8, 0.25, 0.2)))
			grid.add_child(_cell(menus, _value(r, total), Color(0.7, 0.42, 0.05), true))
	var note: Label = menus._ro_text(TranslationServer.translate("Tus atributos, tus habilidades y lo que ganes durante la partida suman aparte."), 10, Color(0.28, 0.3, 0.4))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = 320
	body.add_child(note)
	var foot: = HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	body.add_child(foot)
	var close: Button = menus._ro_button(TranslationServer.translate("Cerrar"), w.shut)
	foot.add_child(close)
	menus._float_show(w, close)
