class_name CardFusion
extends Control





const CARD_SIZE: = Vector2(180, 250)
const COPY_SIZE: = Vector2(54, 75)
const MAX_COPIES: = 10

var world: World
var card_id: = ""
var copies: = 5
var done: Callable
var _center: Vector2
var _card: TextureRect
var _count: Label
var _finished: = false


func _init(p_world: World, p_card: String, p_copies: int, p_done: Callable) -> void :
	world = p_world
	card_id = p_card
	copies = p_copies
	done = p_done
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _ready() -> void :
	var view: = get_viewport().get_visible_rect().size
	_center = view * 0.5 + Vector2(0, -10)
	var dim: = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.create_tween().tween_property(dim, "color:a", 0.82, 0.3)

	var glow: = UiKit.glow(Color(GameData.ETERNAL_COLOR, 0.35), 420)
	glow.position = _center - Vector2(210, 210)
	add_child(glow)
	_card = _art(CARD_SIZE)
	_card.position = _center - CARD_SIZE * 0.5
	_card.pivot_offset = CARD_SIZE * 0.5
	_card.scale = Vector2(0.6, 0.6)
	_card.modulate.a = 0.0
	add_child(_card)
	var intro: = _card.create_tween().set_parallel()
	intro.tween_property(_card, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.tween_property(_card, "modulate:a", 1.0, 0.25)
	_count = UiKit.label("0 / %d" % copies, 22, Color(1.0, 0.92, 0.7), true)
	_count.add_theme_color_override("font_outline_color", Color(0.25, 0.15, 0.02))
	_count.add_theme_constant_override("outline_size", 6)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count.size = Vector2(300, 30)
	_count.position = Vector2(_center.x - 150, _center.y + CARD_SIZE.y * 0.5 + 18)
	add_child(_count)
	_run()


func _art(sz: Vector2) -> TextureRect:
	var t: = TextureRect.new()
	t.texture = RoAssets.card_art(card_id)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	t.size = sz
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _wait(t: float) -> void :
	await get_tree().create_timer(t, true, false, true).timeout


func _run() -> void :
	await _wait(0.4)

	var shown: = mini(copies, MAX_COPIES)
	var ghosts: Array[TextureRect] = []
	var radius: = 230.0
	for i in shown:
		var g: = _art(COPY_SIZE)
		g.pivot_offset = COPY_SIZE * 0.5
		var a: = TAU * float(i) / shown - PI * 0.5
		g.position = _center + Vector2(cos(a), sin(a)) * radius - COPY_SIZE * 0.5
		g.modulate = Color(1, 1, 1, 0.0)
		g.scale = Vector2(0.4, 0.4)
		add_child(g)
		ghosts.append(g)
		var tw: = g.create_tween().set_parallel()
		tw.tween_property(g, "modulate:a", 0.9, 0.18)
		tw.tween_property(g, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		world.play_sound("ui_click", 0.0, -14.0)
		await _wait(0.05)
	await _wait(0.25)

	var per: = float(copies) / shown
	var gap: = 0.22
	for i in ghosts.size():
		var g: = ghosts[i]
		var tw: = g.create_tween().set_parallel()
		tw.tween_property(g, "position", _center - COPY_SIZE * 0.5, gap).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_property(g, "scale", Vector2(0.3, 0.3), gap)
		tw.tween_property(g, "rotation", randf_range(-0.6, 0.6), gap)
		await _wait(gap)
		g.queue_free()
		world.play_sound(["coin1", "coin2", "coin3"][i % 3], 0.0, -4.0 + i * 0.4)
		_count.text = "%d / %d" % [mini(copies, roundi((i + 1) * per)), copies]
		_pulse(1.0 + 0.04 + 0.01 * i)
		_spark_ring(_center, 0.6 + 0.08 * i)
		gap = maxf(0.08, gap * 0.85)
	await _wait(0.15)
	_burst()


func _pulse(peak: float) -> void :
	var tw: = _card.create_tween()
	tw.tween_property(_card, "scale", Vector2(peak, peak), 0.05)
	tw.tween_property(_card, "scale", Vector2.ONE, 0.12)



func _spark_ring(at: Vector2, k: float) -> void :
	for i in 8:
		var s: = ColorRect.new()
		s.size = Vector2(4, 4)
		s.color = Color(1.0, 0.9, 0.55)
		s.position = at - Vector2(2, 2)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		var a: = TAU * i / 8.0 + randf() * 0.3
		var tw: = s.create_tween().set_parallel()
		tw.tween_property(s, "position", at + Vector2(cos(a), sin(a)) * 90.0 * k, 0.35).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "modulate:a", 0.0, 0.35)
		tw.chain().tween_callback(s.queue_free)



func _burst() -> void :
	world.play_sound("refine_ok", 0.0, 0.0)
	world.play_sound("job_levelup", 0.0, -4.0)
	var flash: = ColorRect.new()
	flash.color = Color(1, 0.97, 0.88, 1.0)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	flash.create_tween().tween_property(flash, "color:a", 0.0, 0.6)
	var rays: = UiKit.rays(Color(GameData.ETERNAL_COLOR, 0.85), 560)
	rays.position = _center - Vector2(280, 280)
	rays.pivot_offset = Vector2(280, 280)
	add_child(rays)
	move_child(rays, _card.get_index())
	rays.create_tween().set_loops().tween_property(rays, "rotation", TAU, 8.0).as_relative()
	for i in 40:
		var s: = ColorRect.new()
		var big: = randf() < 0.3
		s.size = Vector2(6, 6) if big else Vector2(3, 3)
		s.color = Color(1.0, randf_range(0.8, 0.95), randf_range(0.4, 0.7))
		s.position = _center
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		var a: = randf() * TAU
		var d: = randf_range(140.0, 380.0)
		var tw: = s.create_tween().set_parallel()
		tw.tween_property(s, "position", _center + Vector2(cos(a), sin(a)) * d, randf_range(0.6, 1.1)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(s, "modulate:a", 0.0, 1.1).set_delay(0.3)
		tw.chain().tween_callback(s.queue_free)

	var frame: = Panel.new()
	var fb: = StyleBoxFlat.new()
	fb.draw_center = false
	fb.border_color = GameData.ETERNAL_COLOR
	fb.set_border_width_all(4)
	fb.set_corner_radius_all(6)
	fb.shadow_color = Color(GameData.ETERNAL_COLOR, 0.6)
	fb.shadow_size = 14
	frame.add_theme_stylebox_override("panel", fb)
	frame.size = CARD_SIZE + Vector2(12, 12)
	frame.position = Vector2(-6, -6)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(frame)
	UiKit.eternal_shine(_card)
	var pop: = _card.create_tween()
	pop.tween_property(_card, "scale", Vector2(1.18, 1.18), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(_card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if world != null:
		world.shake(0.25)
	_count.queue_free()
	var title: = UiKit.label(tr("¡CARTA ETERNA!"), 34, Color(1.0, 0.88, 0.5), true)
	title.add_theme_color_override("font_outline_color", Color(0.3, 0.16, 0.02))
	title.add_theme_constant_override("outline_size", 9)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(600, 44)
	title.position = Vector2(_center.x - 300, _center.y - CARD_SIZE.y * 0.5 - 70)
	title.pivot_offset = Vector2(300, 22)
	title.scale = Vector2(0.4, 0.4)
	add_child(title)
	title.create_tween().tween_property(title, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var sub: = UiKit.label(tr(str(GameData.CARDS[card_id].name)), 18, Color.WHITE, true)
	sub.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	sub.add_theme_constant_override("outline_size", 5)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.size = Vector2(600, 26)
	sub.position = Vector2(_center.x - 300, _center.y + CARD_SIZE.y * 0.5 + 14)
	add_child(sub)
	var note: = UiKit.label(tr("Ya es tuya para siempre: Abstract la engarza en tu equipo del Almacén."), 13, Color(0.9, 0.92, 1.0))
	note.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	note.add_theme_constant_override("outline_size", 4)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.size = Vector2(700, 22)
	note.position = Vector2(_center.x - 350, _center.y + CARD_SIZE.y * 0.5 + 44)
	add_child(note)
	await _wait(0.6)
	var hint: = UiKit.label(tr("Toca para continuar") if MouseWalk.touch() else tr("Clic o Enter para continuar"), 12, Color(1, 1, 1, 0.75))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(400, 20)
	hint.position = Vector2(_center.x - 200, _center.y + CARD_SIZE.y * 0.5 + 74)
	add_child(hint)
	var blink: = hint.create_tween().set_loops()
	blink.tween_property(hint, "modulate:a", 0.35, 0.6)
	blink.tween_property(hint, "modulate:a", 1.0, 0.6)
	_finished = true


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed:
		_close()
		accept_event()


func _unhandled_input(event: InputEvent) -> void :
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void :
	if not _finished:
		return
	_finished = false
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback( func():
		if done.is_valid():
			done.call()
		queue_free())
