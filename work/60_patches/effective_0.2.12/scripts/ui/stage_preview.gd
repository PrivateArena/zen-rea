class_name StagePreview
extends PanelContainer





const MAP_SIZE: = 230.0
const PORTRAIT: = 54.0

var world: World
var _content: VBoxContainer
var _shown: = ""


func _ready() -> void :
	add_theme_stylebox_override("panel", UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 12, 2))
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_stage(id: String, celebrate: = false) -> void :
	if id == _shown and not celebrate:
		return
	_shown = id
	if _content != null:
		remove_child(_content)
		_content.queue_free()
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 8)
	add_child(_content)
	var st: Dictionary = GameData.STAGES[id]
	var unlocked: = world.is_stage_unlocked(id) and world.is_stage_exported(id)
	var cleared: = Save.is_stage_cleared(id)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	_content.add_child(head)
	var title: = UiKit.label(tr(str(st.name)), 26, UiKit.TEXT, true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	if celebrate:
		head.add_child(UiKit.tag(tr("¡NUEVO!"), Color(0.95, 0.7, 0.15)))
	elif Save.is_stage_hard_cleared(id):
		head.add_child(UiKit.tag(tr("DIFÍCIL SUPERADO"), Color(0.75, 0.25, 0.25)))
	elif cleared:
		head.add_child(UiKit.tag(tr("MVP DERROTADO"), Color(0.3, 0.65, 0.35)))
	elif not unlocked:
		head.add_child(UiKit.tag(tr("BLOQUEADO"), Color(0.5, 0.5, 0.56)))
	var index: = GameData.STAGES.keys().find(id)
	var stars: = "★".repeat(index + 1) + "☆".repeat(GameData.STAGES.size() - index - 1)
	_content.add_child(UiKit.label(tr("Dificultad  %s   ·   mapa %s") % [stars, st.map], 13, UiKit.MUTED))


	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	_content.add_child(row)
	var frame: = PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.1, 0.12, 0.2), UiKit.GOLD_DIM, 6, 2))
	row.add_child(frame)
	var holder: = Control.new()
	holder.custom_minimum_size = Vector2(MAP_SIZE, MAP_SIZE)
	holder.clip_contents = true
	frame.add_child(holder)
	if celebrate:
		var rays: = UiKit.rays(Color(1.0, 0.85, 0.35, 0.8), MAP_SIZE * 1.6)
		rays.position = Vector2(MAP_SIZE, MAP_SIZE) * -0.3
		holder.add_child(rays)
		var spin: = rays.create_tween().set_loops()
		spin.tween_property(rays, "rotation", TAU, 9.0).from(0.0)
	var map_tex: Texture2D = null
	var map_path: = "res://assets/ro/ui/map/%s.png" % st.map
	if ResourceLoader.exists(map_path):
		map_tex = load(map_path)
	var pic: = UiKit.icon_rect(map_tex, MAP_SIZE)
	pic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pic.size = Vector2(MAP_SIZE, MAP_SIZE)
	if not unlocked:
		pic.modulate = Color(0.35, 0.37, 0.45)
	holder.add_child(pic)
	if not unlocked:
		var lock: = UiKit.label(tr("Derrota al MVP de %s") % tr(GameData.STAGES[st.unlock].name) if st.unlock != "" else "", 
			14, Color.WHITE, true)
		lock.add_theme_constant_override("outline_size", 5)
		lock.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lock.size = Vector2(MAP_SIZE, MAP_SIZE)
		holder.add_child(lock)

	var mvp_col: = VBoxContainer.new()
	mvp_col.add_theme_constant_override("separation", 4)
	mvp_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(mvp_col)
	mvp_col.add_child(UiKit.label(tr("MVP"), 13, Color(0.75, 0.2, 0.25), true))
	var mvp_id: String = st.mvp
	var big: = _portrait(mvp_id, 120.0, unlocked or cleared)
	big.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mvp_col.add_child(big)
	var mvp_name: = UiKit.label(tr(str(GameData.MONSTERS[mvp_id].name)), 18, UiKit.TEXT, true)
	mvp_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mvp_col.add_child(mvp_name)
	if GameData.RAIDS.has(mvp_id):
		var arena: = UiKit.label(tr("Arena: %s") % tr(str(GameData.RAIDS[mvp_id].title)), 12, UiKit.MUTED)
		arena.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		arena.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		mvp_col.add_child(arena)
	var desc: = UiKit.label(tr(str(st.desc)), 12, UiKit.MUTED)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = 200
	mvp_col.add_child(desc)

	if GameData.QUESTS.has(id):
		_content.add_child(_quest_card(id, unlocked or cleared))


	_content.add_child(UiKit.label(tr("Monstruos"), 14, UiKit.GOLD, true))
	var mobs: = GridContainer.new()
	mobs.columns = 7
	mobs.add_theme_constant_override("h_separation", 6)
	mobs.add_theme_constant_override("v_separation", 4)
	_content.add_child(mobs)
	for mob in _monsters(st):
		var cell: = VBoxContainer.new()
		cell.add_theme_constant_override("separation", 0)
		mobs.add_child(cell)
		cell.add_child(_portrait(mob, PORTRAIT, unlocked or cleared))
		var n: = UiKit.label(tr(str(GameData.MONSTERS[mob].name)) if unlocked or cleared else "???", 10, UiKit.MUTED)
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		n.custom_minimum_size.x = PORTRAIT + 6
		n.clip_text = true
		cell.add_child(n)


	reset_size.call_deferred()

	_content.modulate.a = 0.0
	_content.position.y += 8
	var tw: = _content.create_tween().set_parallel()
	tw.tween_property(_content, "modulate:a", 1.0, 0.18)
	if celebrate:
		pic.pivot_offset = Vector2(MAP_SIZE, MAP_SIZE) * 0.5
		pic.scale = Vector2(0.6, 0.6)
		tw.tween_property(pic, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)




func _quest_card(id: String, known: bool) -> PanelContainer:
	var q: Dictionary = GameData.QUESTS[id]
	var done: = Save.quest_done(id)
	var card: = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiKit.panel_box(Color(1.0, 0.97, 0.87) if not done else Color(0.9, 0.97, 0.9), 
		Color(0.85, 0.66, 0.25) if not done else Color(0.35, 0.65, 0.4), 8, 2))
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	var spr: = RoAssets.sprite([str(q.npc)])
	if spr != null:
		var img: = spr.compose_image(0, 0)
		var used: = img.get_used_rect()
		var pic: = UiKit.icon_rect(ImageTexture.create_from_image(img.get_region(used)) if used.size.x > 0 else null, 46)
		if not known:
			pic.modulate = Color(0.05, 0.05, 0.1, 0.85)
		row.add_child(pic)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	col.add_child(head)
	var title: = UiKit.label(tr("Quest: %s") % tr(str(q.name)), 14, Color(0.55, 0.32, 0.0) if not done else Color(0.15, 0.45, 0.2), true)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	head.add_child(UiKit.tag(tr("COMPLETADA") if done else tr("PENDIENTE"), Color(0.3, 0.65, 0.35) if done else Color(0.85, 0.6, 0.15)))
	var who: = UiKit.label("%s · %s" % [tr(str(q.npc_name)), tr(str(q.objective))], 12, UiKit.MUTED)
	who.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	who.custom_minimum_size.x = 380
	col.add_child(who)
	var gifts: = HBoxContainer.new()
	gifts.add_theme_constant_override("separation", 10)
	col.add_child(gifts)
	var rw: Dictionary = q.get("reward", {})
	if rw.has("recipe"):
		var r: Dictionary = GameData.RECIPES[str(rw.recipe)]
		gifts.add_child(_gift(_icon(str(r.icon)), tr(str(r.name)), tr(str(r.desc))))
	if rw.has("unlock"):
		for n in GameData.TOWN_NPCS:
			if n.id == str(rw.unlock):
				gifts.add_child(_gift(_cropped(str(n.sprite)), tr("%s en Prontera") % tr(str(n.name)), tr(str(n.get("title", "")))))
	if rw.has("pet"):
		gifts.add_child(_gift(_cropped(str(rw.pet)), tr("Mascota: %s") % tr(str(GameData.PETS[str(rw.pet)].name)), tr(str(GameData.PETS[str(rw.pet)].desc))))
	if rw.has("card"):
		gifts.add_child(_gift(RoAssets.card_art(str(rw.card)), tr(str(GameData.CARDS[str(rw.card)].name)), tr(str(GameData.CARDS[str(rw.card)].desc))))
	return card


static func _icon(id: String) -> Texture2D:
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % id
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


func _gift(icon: Texture2D, text: String, tip: String) -> HBoxContainer:
	var g: = HBoxContainer.new()
	g.add_theme_constant_override("separation", 4)
	g.tooltip_text = tip
	g.mouse_filter = Control.MOUSE_FILTER_PASS
	if icon != null:
		var ic: = UiKit.icon_rect(icon, 22)
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		g.add_child(ic)
	var l: = UiKit.label(text, 12, UiKit.TEXT, true)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	g.add_child(l)
	return g




func _portrait(mob: String, size: float, known: bool) -> TextureRect:
	var r: = UiKit.icon_rect(_cropped(mob), size)
	if not known:
		r.modulate = Color(0.05, 0.05, 0.1, 0.85)
	return r


static var _crops: = {}


static func _cropped(mob: String) -> Texture2D:
	if _crops.has(mob):
		return _crops[mob]
	var out: Texture2D = null
	var spr: = RoAssets.sprite([mob])
	var tex: Texture2D = spr.get_frame(0, 0) if spr != null else null
	if tex != null:
		var img: = spr.compose_image(0, 0)
		if img.is_compressed():
			img.decompress()
		var used: = img.get_used_rect()
		out = ImageTexture.create_from_image(img.get_region(used)) if used.size.x > 0 else tex
	_crops[mob] = out
	return out



static func _monsters(st: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for s in st.spawns:
		if not out.has(str(s.mob)) and GameData.MONSTERS.has(str(s.mob)):
			out.append(str(s.mob))
	for ev in st.events:
		var mob: = str(ev.get("mob", ""))
		if ev.get("type", "") in ["elite", "boss"] and mob != str(st.mvp) and GameData.MONSTERS.has(mob) and not out.has(mob):
			out.append(mob)
	if out.size() > 14:
		out.resize(14)
	return out
