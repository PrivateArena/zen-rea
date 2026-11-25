extends Node







const CHECK_EVERY: = 300.0


const RETRY_AFTER: = 15.0

var world: World
var _t: = 0.0

var _told: Array = []


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Leaderboard.enabled() and Save._name == "profile":
		claim.call_deferred()

		_t = CHECK_EVERY - 20.0


func _process(delta: float) -> void :
	if world == null:
		return
	_t += delta
	if _t >= CHECK_EVERY:
		_t = 0.0
		if not world.running and Leaderboard.enabled() and Save._name == "profile":
			claim()
	if not _told.is_empty() and not world.running and world.menus != null and world.menus.mode() in ["town", "class_select"]:
		var list: = _told.duplicate()
		_told.clear()
		_show(list)


func claim() -> void :
	if world == null or world.board == null:
		return


	Trade.purge(world)




	world.board._call("claim_gifts", {"p_player": Leaderboard.player_id(), "p_secret": str(Save.setting("cloud_secret", "")), "p_grades": true, "p_cosmetics": true}, func(ok: bool, d):
		if not ok or not d is Array:
			_t = CHECK_EVERY - RETRY_AFTER
			return
		var got: = 0
		for g in d:
			if not g is Dictionary:
				continue
			var id: = str(g.get("item", ""))

			if str(g.get("kind", "item")) == "cosmetic":
				if GameData.COSMETICS.has(id):
					Save.add_cosmetic(id)
					_told.append([id, 0, str(g.get("note", "")), 0, false, "cosmetic"])
					got += 1
				continue
			if not GameData.ITEMS.has(id):
				continue
			var refine: = clampi(int(g.get("refine", 0)), 0, GameData.MAX_REFINE)
			var grade: = clampi(int(g.get("grade", 0)), 0, GameData.WEAPON_GRADES.size() - 1)


			var own: Dictionary = {}
			if grade > 0:
				for s in Save.storage():
					if str(s.get("id", "")) == id and Equipment.grade(s) < grade and (own.is_empty() or int(s.get("refine", 0)) > int(own.get("refine", 0))):
						own = s
			if not own.is_empty():
				own["grade"] = grade
				own["refine"] = maxi(int(own.get("refine", 0)), refine)
				_told.append([id, int(own.refine), str(g.get("note", "")), grade, true])
				got += 1
				continue
			Save.add_to_storage(Equipment.make(id, 0), true)
			var st: Dictionary = Save.storage().back()
			st["refine"] = refine
			if grade > 0 and Equipment.gradable_kind(Equipment.item_type(st)):
				st["grade"] = grade
			_told.append([id, refine, str(g.get("note", "")), grade, false])
			got += 1
		if got > 0:
			Save.mark_dirty()
			Save.flush())



func _show(list: Array) -> void :
	var m = world.menus
	var w: Dictionary = m._float_window(tr("¡Un regalo para ti!"))
	var body: VBoxContainer = w.body
	body.add_theme_constant_override("separation", 8)
	for g in list:
		if g.size() > 5 and str(g[5]) == "cosmetic":
			_show_cosmetic(body, g)
			continue
		var it: = {"id": str(g[0]), "refine": int(g[1])}
		if g.size() > 3 and int(g[3]) > 0:
			it["grade"] = int(g[3])
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		body.add_child(row)
		row.add_child(UiKit.icon_rect(m._item_icon(Equipment.item_def(it).icon), 32))
		var col: = VBoxContainer.new()
		row.add_child(col)
		col.add_child(m._ro_text(Equipment.item_name(it), 13, Equipment.item_color(it), true))
		var upgraded: bool = g.size() > 4 and bool(g[4])
		var line: Label = m._ro_text(tr("Tu pieza del Almacén Kafra recibió el grado %s.") % str(GameData.WEAPON_GRADES[int(g[3])].name) if upgraded
			else tr("Llegó a tu Almacén Kafra."), 11, Color(0.27, 0.29, 0.4))
		col.add_child(line)
		if str(g[2]) != "":
			var note: Label = m._ro_text(str(g[2]), 11, Color(0.15, 0.3, 0.6))
			note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			note.custom_minimum_size.x = 300
			col.add_child(note)
	var foot: = HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	body.add_child(foot)
	var ok: Button = m._ro_button(tr("Cerrar"), w.shut)
	foot.add_child(ok)
	m._float_show(w, ok)
	world.play_sound("drop_purple", 0.0, -2.0)



func _show_cosmetic(body: VBoxContainer, g: Array) -> void :
	var m = world.menus
	var d: Dictionary = GameData.COSMETICS.get(str(g[0]), {})
	var col: = VBoxContainer.new()
	body.add_child(col)
	col.add_child(m._ro_text(tr(str(d.get("name", g[0]))), 13, Color(0.55, 0.3, 0.75), true))
	col.add_child(m._ro_text(tr("Llegó a tu armario de cosméticos."), 11, Color(0.27, 0.29, 0.4)))
	if str(g[2]) != "":
		var note: Label = m._ro_text(str(g[2]), 11, Color(0.15, 0.3, 0.6))
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.custom_minimum_size.x = 300
		col.add_child(note)
