extends Node





const HOLD_TIME: = 0.45

const HOLD_SLOP: = 14.0

var world: Node
var _down: = false
var _fired: = false
var _t: = 0.0
var _at: = Vector2.ZERO


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

	get_window().set_meta("ui_base", ui_scale())
	get_window().content_scale_factor = ui_scale()




static func ui_scale() -> float:
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--ui-scale="):
			return clampf(float(str(a).substr(11)), 0.75, 2.0)
	if OS.has_feature("web"):

		var short_side: = float(JavaScriptBridge.eval("Math.min(screen.width, screen.height)", true))
		var inches: = short_side / 150.0 if short_side > 0.0 else 9.0
		return 1.3 if inches < 3.3 else (1.15 if inches < 4.5 else 1.0)
	var dpi: = float(DisplayServer.screen_get_dpi())
	var px: = Vector2(DisplayServer.screen_get_size())
	if dpi <= 0.0 or px.y <= 0.0:
		return 1.0

	var tall: = minf(px.x, px.y) / dpi
	if tall < 3.3:
		return 1.3
	if tall < 4.5:
		return 1.15
	return 1.0


func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:


			_down = true
			_fired = false
			_t = 0.0
			_at = event.position
		else:
			_down = false
			if _fired:

				_fired = false
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _down and event.position.distance_to(_at) > HOLD_SLOP:
		_down = false


func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_down = false


func _process(delta: float) -> void :
	if not _down or _fired:
		return
	_t += delta
	if _t < HOLD_TIME:
		return
	_fired = true
	_down = false
	for pressed in [true, false]:
		var ev: = InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_RIGHT
		ev.pressed = pressed

		var px: Vector2 = get_tree().root.get_final_transform() * _at
		ev.position = px
		ev.global_position = px
		Input.parse_input_event(ev)
	Input.vibrate_handheld(30)
