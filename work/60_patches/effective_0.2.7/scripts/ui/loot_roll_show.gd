class_name LootRollShow
extends CanvasLayer






signal finished

const FONT = preload("res://assets/ro/fonts/SCDream6.otf")
const DIE: = 64.0

var world: World
var _queue: Array = []
var _root: Control


func setup(p_world: World, results: Array) -> void :
	world = p_world
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS



	_queue = results.filter( func(r): return not (r.rolls as Dictionary).is_empty() or (LootRoll.is_unique(r.item) and int(r.winner) >= 0))
	for r in results:
		if _queue.has(r) or int(r.winner) < 0 or int(r.winner) >= world.heroes.size():
			continue

		var h: Player = world.heroes[int(r.winner)]
		if world.net.is_client() and is_instance_valid(h):
			world.number(h.position + Vector3(0, 2.2, 0), Equipment.item_name(r.item), Equipment.item_world_color(r.item), true)
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_next.call_deferred()


func _next() -> void :
	for c in _root.get_children():
		c.queue_free()
	if _queue.is_empty():
		finished.emit()
		queue_free()
		return
	_show(_queue.pop_front())


func _show(r: Dictionary) -> void :
	var it: Dictionary = r.item
	var col: = Equipment.item_color(it)
	var unique: = LootRoll.is_unique(it)
	var dice: = not (r.rolls as Dictionary).is_empty()

	var veil: = ColorRect.new()
	veil.color = Color(0, 0, 0.04, 0.0)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(veil)
	veil.create_tween().tween_property(veil, "color:a", 0.45, 0.25)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(center)
	var col_box: = VBoxContainer.new()
	col_box.alignment = BoxContainer.ALIGNMENT_CENTER
	col_box.add_theme_constant_override("separation", 10)
	col_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(col_box)
	var title: = _label(tr("¡A los dados!") if dice else (tr("Botín único") if unique else tr("Botín legendario")), 30, 
		Color(1.0, 0.86, 0.35))
	col_box.add_child(title)

	var prize: = Control.new()
	prize.custom_minimum_size = Vector2(160, 150)

	prize.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	prize.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col_box.add_child(prize)
	var rays: = UiKit.rays(Color(col, 0.9), 260)
	rays.position = Vector2(80 - 130, 75 - 130)
	rays.pivot_offset = Vector2(130, 130)
	prize.add_child(rays)
	rays.create_tween().set_loops().tween_property(rays, "rotation", TAU, 6.0).as_relative()
	var glow: = UiKit.glow(Color(col, 0.85), 170)
	glow.position = Vector2(80 - 85, 75 - 85)
	prize.add_child(glow)
	var icon: = UiKit.icon_rect(world.menus._item_icon(Equipment.item_def(it).icon), 96)
	icon.texture_filter = RoAssets.ui_filter()
	icon.position = Vector2(80 - 48, 75 - 48)
	icon.pivot_offset = Vector2(48, 48)
	icon.scale = Vector2.ONE * 0.2
	prize.add_child(icon)
	icon.create_tween().tween_property(icon, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	col_box.add_child(_label(Equipment.item_name(it), 22, Equipment.item_world_color(it)))
	world.play_sound("drop_yellow", 0.0, -2.0)

	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col_box.add_child(row)
	var winner: = int(r.winner)
	if (r.want as Array).is_empty() or winner < 0:
		col_box.add_child(_label(tr("Nadie lo quiso: vendido para el grupo"), 16, Color(0.85, 0.85, 0.9)))
		_after(2.0)
		return
	if not dice:
		var card: = _player_card(winner, true)
		row.add_child(card)
		_crown(card)
		world.play_sound("job_levelup", 0.0, -4.0)
		_announce(winner)
		_after(2.6)
		return
	var cards: = {}
	var faces: = {}
	var order: Array = r.want
	for s in order:
		var card: = _player_card(int(s), false)
		row.add_child(card)
		cards[s] = card
		faces[s] = card.get_meta("face")

	var stop_at: = 1.2
	for s in order:
		if not (r.rolls as Dictionary).has(s):
			(faces[s] as Label).text = "—"
			cards[s].modulate = Color(1, 1, 1, 0.45)
			continue
		_tumble(faces[s], int(r.rolls[s]), stop_at)
		stop_at += 0.55
	var reveal: = create_tween()
	reveal.tween_interval(stop_at + 0.2)
	reveal.tween_callback( func():
		for s in cards:
			if int(s) != winner:
				cards[s].create_tween().tween_property(cards[s], "modulate:a", 0.45, 0.25)
		_crown(cards[winner])
		world.play_sound("job_levelup", 0.0, -2.0)
		world.play_sound("coin3", 0.0, -6.0)
		_announce(winner))
	_after(stop_at + 2.6)



func _player_card(slot: int, alone: bool) -> PanelContainer:
	var h: Player = world.heroes[slot] if slot < world.heroes.size() else null
	var card: = PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.97, 0.98, 1.0, 0.96), UiKit.GOLD_DIM, 10, 2))
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.custom_minimum_size = Vector2(140, 0)
	var v: = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var who: = world.hero_label(h) if h != null else "?"
	var shown: = str(h.appearance.get("name", "")).strip_edges() if h != null else ""
	if h != null and h != world.player and shown != "":
		who = shown

	var name: = _label(who, 17, UiKit.TEXT, false)
	v.add_child(name)
	v.add_child(_label(tr(h.job_name()) if h != null else "", 12, UiKit.MUTED, false))

	var die: = PanelContainer.new()
	die.custom_minimum_size = Vector2(DIE, DIE)
	die.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var db: = StyleBoxFlat.new()
	db.bg_color = Color(1.0, 0.98, 0.93)
	db.border_color = Color(0.82, 0.62, 0.25)
	db.set_border_width_all(3)
	db.border_width_bottom = 5
	db.set_corner_radius_all(14)
	db.shadow_color = Color(0, 0, 0, 0.3)
	db.shadow_size = 4
	db.shadow_offset = Vector2(0, 2)
	die.add_theme_stylebox_override("panel", db)
	die.mouse_filter = Control.MOUSE_FILTER_IGNORE
	die.pivot_offset = Vector2(DIE, DIE) * 0.5
	v.add_child(die)
	card.set_meta("die_box", db)
	var face: = _label("✓" if alone else "?", 30, Color(0.55, 0.32, 0.08), false)
	face.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	die.add_child(face)
	card.set_meta("face", face)
	card.set_meta("die", die)
	card.pivot_offset = Vector2(70, 60)
	card.scale = Vector2.ONE * 0.6
	card.create_tween().tween_property(card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return card




func _tumble(face: Label, value: int, total: float) -> void :
	var die: Control = face.get_parent()
	var tw: = face.create_tween()
	var t: = 0.0
	var step: = 0.045
	while t < total:
		tw.tween_callback( func():
			face.text = str(randi_range(1, 100))
			die.rotation = randf_range(-0.25, 0.25)
			world.play_sound("ui_click", 0.0, -14.0))
		tw.tween_interval(step)
		t += step
		step *= 1.09
	tw.tween_callback( func():
		face.text = str(value)
		die.rotation = 0.0
		die.scale = Vector2.ONE * 1.35
		die.create_tween().tween_property(die, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
		world.play_sound("guard_block", 0.0, -6.0))



func _crown(card: PanelContainer) -> void :
	card.add_theme_stylebox_override("panel", UiKit.panel_box(Color(1.0, 0.97, 0.85), Color(0.95, 0.72, 0.2), 10, 4))

	if card.has_meta("die_box"):
		var db: StyleBoxFlat = card.get_meta("die_box")
		db.bg_color = Color(1.0, 0.86, 0.35)
		db.border_color = Color(0.75, 0.45, 0.05)
		(card.get_meta("face") as Label).add_theme_color_override("font_color", Color(0.45, 0.22, 0.0))
	var tw: = card.create_tween()
	tw.tween_property(card, "scale", Vector2.ONE * 1.18, 0.18).set_trans(Tween.TRANS_BACK)
	tw.tween_property(card, "scale", Vector2.ONE * 1.08, 0.2)
	var v: VBoxContainer = card.get_child(0)
	var won: = _label(tr("¡Gana!"), 22, Color(0.9, 0.55, 0.05), false)
	v.add_child(won)
	won.scale = Vector2.ONE * 0.3
	won.pivot_offset = Vector2(60, 14)
	won.create_tween().tween_property(won, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

	var burst: = CPUParticles2D.new()
	burst.amount = 70
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.lifetime = 1.6
	burst.direction = Vector2(0, -1)
	burst.spread = 75.0
	burst.initial_velocity_min = 220.0
	burst.initial_velocity_max = 420.0
	burst.gravity = Vector2(0, 520)
	burst.scale_amount_min = 3.0
	burst.scale_amount_max = 6.0
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(1.0, 0.85, 0.25))
	ramp.add_point(0.3, Color(0.45, 0.8, 1.0))
	ramp.add_point(0.6, Color(1.0, 0.45, 0.6))
	ramp.set_color(ramp.get_point_count() - 1, Color(0.6, 1.0, 0.55))
	burst.color_initial_ramp = ramp
	_root.add_child(burst)
	burst.global_position = card.global_position + card.size * 0.5
	burst.emitting = true



func _announce(slot: int) -> void :
	if slot < world.heroes.size():
		var h: Player = world.heroes[slot]
		world.number(h.position + Vector3(0, 2.6, 0), tr("¡Ganó el dado!"), Color(1.0, 0.85, 0.3), true)


func _after(t: float) -> void :
	var tw: = create_tween()
	tw.tween_interval(t)
	tw.tween_callback(_next)


func _label(text: String, size: int, color: Color, outline: = true) -> Label:
	var l: = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)

	if outline:
		l.add_theme_constant_override("outline_size", 6)
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.75))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l
