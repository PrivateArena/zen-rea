class_name CardFusionAll
extends Control







const MAX_COLS: = 8
const GAP: = 14.0
const GHOSTS: = 3

var world: World

var fused: Array = []
var done: Callable
var _cards: Array[TextureRect] = []
var _card_size: = Vector2(104, 144)
var _center: Vector2
var _finished: = false
var _skip: = false
var _clink: AudioStreamPlayer
var _pitch: = 0.9
var _tally: Label
var _total: = 0


func _init(p_world: World, p_fused: Array, p_done: Callable) -> void :
	world = p_world
	fused = p_fused
	done = p_done
	for f in fused:
		_total += int(f[1])
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _ready() -> void :
	var view: = get_viewport().get_visible_rect().size
	_center = view * 0.5
	var dim: = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	dim.create_tween().tween_property(dim, "color:a", 0.85, 0.25)
	var glow: = UiKit.glow(Color(GameData.ETERNAL_COLOR, 0.28), 760)
	glow.position = _center - Vector2(380, 380)
	add_child(glow)
	_clink = AudioStreamPlayer.new()
	_clink.bus = "SFX"
	_clink.volume_db = -10.0
	add_child(_clink)




	var n: = fused.size()
	var cols: = mini(n, MAX_COLS)
	var k: = 0.0
	for nc in range(1, n + 1):
		var nr: = ceili(n / float(nc))
		var kc: = minf((view.x - 160.0) / (nc * (_card_size.x + GAP)), (view.y - 260.0) / (nr * (_card_size.y + GAP)))
		if kc > k + 0.001 and (kc < 1.0 or nc <= MAX_COLS):
			k = kc
			cols = nc
	k = minf(k, 1.0)
	var rows: = ceili(n / float(cols))
	_card_size *= k
	var gap: = GAP * k
	var grid_w: = cols * _card_size.x + (cols - 1) * gap
	var grid_h: = rows * _card_size.y + (rows - 1) * gap
	var origin: = _center - Vector2(grid_w, grid_h) * 0.5 + Vector2(0, 10)
	for i in n:
		var row: = i / cols
		var in_row: = mini(cols, n - row * cols)
		var row_x: = (grid_w - (in_row * _card_size.x + (in_row - 1) * gap)) * 0.5
		var c: = _art(str(fused[i][0]), _card_size)
		c.position = origin + Vector2(row_x + (i % cols) * (_card_size.x + gap), row * (_card_size.y + gap))
		c.pivot_offset = _card_size * 0.5
		c.modulate = Color(0.55, 0.55, 0.65, 0.0)
		c.scale = Vector2(0.7, 0.7)
		add_child(c)
		_cards.append(c)
		var tw: = c.create_tween().set_parallel()
		tw.tween_property(c, "modulate:a", 1.0, 0.2).set_delay(0.02 * i)
		tw.tween_property(c, "scale", Vector2.ONE, 0.3).set_delay(0.02 * i).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tally = UiKit.label("0 / %d" % _total, 24, Color(1.0, 0.92, 0.7), true)
	_tally.add_theme_color_override("font_outline_color", Color(0.25, 0.15, 0.02))
	_tally.add_theme_constant_override("outline_size", 6)
	_tally.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tally.size = Vector2(400, 34)
	_tally.position = Vector2(_center.x - 200, origin.y + grid_h + 22)
	add_child(_tally)
	_run()


func _art(id: String, sz: Vector2) -> TextureRect:
	var t: = TextureRect.new()
	t.texture = RoAssets.card_art(id)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	t.size = sz
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _wait(t: float) -> void :
	if _skip:
		return
	await get_tree().create_timer(t, true, false, true).timeout


func _run() -> void :
	await _wait(0.45)
	var gap: = 0.32
	var done_n: = 0
	for i in _cards.size():
		var c: = _cards[i]
		var id: = str(fused[i][0])
		var times: = int(fused[i][1])
		var mid: = c.position + _card_size * 0.5

		if not _skip:
			for g in GHOSTS:
				var ghost: = _art(id, _card_size * 0.45)
				ghost.pivot_offset = ghost.size * 0.5
				var a: = TAU * g / GHOSTS + randf() * 0.6
				ghost.position = mid + Vector2(cos(a), sin(a)) * _card_size.x * 1.1 - ghost.size * 0.5
				ghost.modulate.a = 0.85
				add_child(ghost)
				var tw: = ghost.create_tween().set_parallel()
				tw.tween_property(ghost, "position", mid - ghost.size * 0.5, gap * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				tw.tween_property(ghost, "scale", Vector2(0.3, 0.3), gap * 0.7)
				tw.chain().tween_callback(ghost.queue_free)
			await _wait(gap * 0.7)
		_turn_gold(c, times)
		_ding()
		_sparks(mid, 0.55 + 0.25 * _card_size.x / 104.0)
		done_n += times
		_tally.text = "%d / %d" % [done_n, _total]

		gap = maxf(0.09, gap * 0.86)
		await _wait(gap * 0.3)
	await _wait(0.2)
	_burst()




func _turn_gold(c: TextureRect, times: int) -> void :
	c.modulate = Color.WHITE
	var frame: = Panel.new()
	var fb: = StyleBoxFlat.new()
	fb.draw_center = false
	fb.border_color = GameData.ETERNAL_COLOR
	fb.set_border_width_all(3)
	fb.set_corner_radius_all(5)
	fb.shadow_color = Color(GameData.ETERNAL_COLOR, 0.6)
	fb.shadow_size = 10
	frame.add_theme_stylebox_override("panel", fb)
	frame.size = _card_size + Vector2(8, 8)
	frame.position = Vector2(-4, -4)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(frame)
	UiKit.eternal_shine(c)
	if times > 1:
		var x: = UiKit.label("x%d" % times, 18, Color(1.0, 0.9, 0.55), true)
		x.add_theme_color_override("font_outline_color", Color(0.3, 0.16, 0.02))
		x.add_theme_constant_override("outline_size", 6)
		x.position = Vector2(_card_size.x - 30, _card_size.y - 30)
		c.add_child(x)
	var pop: = c.create_tween()
	pop.tween_property(c, "scale", Vector2(1.16, 1.16), 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(c, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)



func _ding() -> void :
	var stream: = RoAssets.sound(["coin1", "coin2", "coin3"][randi() % 3])
	if stream == null or _skip:
		return
	_clink.stream = stream
	_clink.pitch_scale = _pitch
	_clink.play()
	_pitch = minf(_pitch + 0.06, 1.9)


func _sparks(at: Vector2, k: float) -> void :
	for i in 10:
		var s: = ColorRect.new()
		s.size = Vector2(4, 4)
		s.color = Color(1.0, randf_range(0.82, 0.95), 0.55)
		s.position = at - Vector2(2, 2)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		var a: = TAU * i / 10.0 + randf() * 0.3
		var tw: = s.create_tween().set_parallel()
		tw.tween_property(s, "position", at + Vector2(cos(a), sin(a)) * 110.0 * k, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(s, "modulate:a", 0.0, 0.4)
		tw.chain().tween_callback(s.queue_free)



func _burst() -> void :
	world.play_sound("refine_ok", 0.0, 0.0)
	world.play_sound("job_levelup", 0.0, -3.0)
	var flash: = ColorRect.new()
	flash.color = Color(1, 0.97, 0.88, 1.0)
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	flash.create_tween().tween_property(flash, "color:a", 0.0, 0.6)
	var rays: = UiKit.rays(Color(GameData.ETERNAL_COLOR, 0.7), 900)
	rays.position = _center - Vector2(450, 450)
	rays.pivot_offset = Vector2(450, 450)
	add_child(rays)
	move_child(rays, 2)
	rays.create_tween().set_loops().tween_property(rays, "rotation", TAU, 12.0).as_relative()
	for i in 60:
		var s: = ColorRect.new()
		s.size = Vector2(6, 6) if randf() < 0.3 else Vector2(3, 3)
		s.color = Color(1.0, randf_range(0.8, 0.95), randf_range(0.4, 0.7))
		s.position = _center
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(s)
		var a: = randf() * TAU
		var d: = randf_range(200.0, 560.0)
		var tw: = s.create_tween().set_parallel()
		tw.tween_property(s, "position", _center + Vector2(cos(a), sin(a)) * d, randf_range(0.7, 1.2)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(s, "modulate:a", 0.0, 1.2).set_delay(0.3)
		tw.chain().tween_callback(s.queue_free)
	for c in _cards:
		var pop: = c.create_tween()
		pop.tween_property(c, "scale", Vector2(1.1, 1.1), 0.1)
		pop.tween_property(c, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	if world != null:
		world.shake(0.3)
	var top: = _cards[0].position.y if not _cards.is_empty() else _center.y
	var title: = UiKit.label(tr("¡%d CARTAS ETERNAS!") % _total if _total > 1 else tr("¡CARTA ETERNA!"), 34, Color(1.0, 0.88, 0.5), true)
	title.add_theme_color_override("font_outline_color", Color(0.3, 0.16, 0.02))
	title.add_theme_constant_override("outline_size", 9)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(700, 44)
	title.position = Vector2(_center.x - 350, top - 74)
	title.pivot_offset = Vector2(350, 22)
	title.scale = Vector2(0.4, 0.4)
	add_child(title)
	title.create_tween().tween_property(title, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tally.text = tr("Tuyas para siempre: Abstract las engarza en tu equipo del Almacén.")
	_tally.add_theme_font_size_override("font_size", 14)
	_tally.size.x = 800
	_tally.position.x = _center.x - 400
	_skip = false
	await _wait(0.6)
	var hint: = UiKit.label(tr("Toca para continuar") if MouseWalk.touch() else tr("Clic o Enter para continuar"), 12, Color(1, 1, 1, 0.75))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(400, 20)
	hint.position = Vector2(_center.x - 200, _tally.position.y + 30)
	add_child(hint)
	var blink: = hint.create_tween().set_loops()
	blink.tween_property(hint, "modulate:a", 0.35, 0.6)
	blink.tween_property(hint, "modulate:a", 1.0, 0.6)
	_finished = true


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed:
		_advance()
		accept_event()


func _unhandled_input(event: InputEvent) -> void :
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_advance()
		get_viewport().set_input_as_handled()



func _advance() -> void :
	if not _finished:
		_skip = true
		return
	_finished = false
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback( func():
		if done.is_valid():
			done.call()
		queue_free())
