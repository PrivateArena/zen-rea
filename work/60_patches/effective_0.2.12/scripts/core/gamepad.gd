extends Node





















var world: Node

const DEAD: = 0.22

const CURSOR_SPEED: = 820.0

const TURN_SPEED: = 2.4
const ZOOM_SPEED: = 5.0
const SCROLL_EVERY: = 0.07

var _cursor: = Vector2(-1, -1)
var _a_down: = false

var _popup_held: = {}
var _scroll_t: = 0.0
var _triggers: = {JOY_AXIS_TRIGGER_LEFT: false, JOY_AXIS_TRIGGER_RIGHT: false}

var _pad: = 0

var _nav_dir: = Vector2.ZERO
var _nav_t: = 0.0
const NAV_FIRST: = 0.38
const NAV_REPEAT: = 0.11
var _nav_last: Control


var _ov_targets: Array[Control] = []
var _ov_at: = -100000
const OVERLAY_TARGETS_MS: = 200

var hints: Node


var _synth_at: = -100000


var _mouse_win: = Vector2(-1, -1)



var _point_at: = -100000
var _focus_at: = -100000

var _mobile: = OS.has_feature("mobile")
var _overlay: Control

var test_pad: = false


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	hints = load("res://scripts/ui/pad_hints.gd").new()
	hints.set("world", world)
	add_child(hints)
	get_viewport().gui_focus_changed.connect( func(_c: Control): _focus_at = Time.get_ticks_msec())


	var layer: = CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.draw.connect(_draw_overlay)
	layer.add_child(_overlay)



func _menu_open() -> bool:
	if world == null or world.menus == null:
		return true
	if world.get_tree().paused:
		return true
	var opt = world.menus.get("_options")
	if opt != null and is_instance_valid(opt):
		return true
	return not str(world.menus.mode()) in ["closed", "town"]


func _typing() -> bool:
	return world != null and world.town != null and is_instance_valid(world.town)\
	and world.town.get("_crowd") != null and world.town._crowd.typing()


static func _stick(dev: int, x: JoyAxis, y: JoyAxis) -> Vector2:
	var v: = Vector2(Input.get_joy_axis(dev, x), Input.get_joy_axis(dev, y))
	if v.length() < DEAD:
		return Vector2.ZERO

	return v.normalized() * inverse_lerp(DEAD, 1.0, minf(v.length(), 1.0))


func _process(delta: float) -> void :
	_overlay.queue_redraw()
	var pads: = Input.get_connected_joypads()
	if pads.is_empty():
		_cursor = Vector2(-1, -1)
		return
	if not pads.has(_pad):
		_pad = pads[0]



	if _popup_pad():
		return
	var left: = _stick(_pad, JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var right: = _stick(_pad, JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	_check_triggers()
	if _menu_open():
		var v: = left
		if _nav_dir != Vector2.ZERO:
			_nav_t -= delta
			if _nav_t <= 0.0:
				_nav_t = NAV_REPEAT
				_jump(_nav_dir)
		if v != Vector2.ZERO:
			_move_cursor(v * v.length() * CURSOR_SPEED * _px_scale() * delta)
		elif not _a_down:

			_cursor = Vector2(-1, -1)
		_scroll_t -= delta
		if absf(right.y) > 0.4 and _scroll_t <= 0.0:
			_scroll_t = SCROLL_EVERY / absf(right.y)
			_wheel(MOUSE_BUTTON_WHEEL_DOWN if right.y > 0.0 else MOUSE_BUTTON_WHEEL_UP)
		return
	_nav_dir = Vector2.ZERO
	if _typing():
		return

	var turn: = right.x
	if Input.is_joy_button_pressed(_pad, JOY_BUTTON_LEFT_SHOULDER):
		turn -= 1.0
	if Input.is_joy_button_pressed(_pad, JOY_BUTTON_RIGHT_SHOULDER):
		turn += 1.0
	if turn != 0.0 and world.camera_turns():
		world.set_view_yaw(RoVisual.view_yaw - clampf(turn, -1.0, 1.0) * TURN_SPEED * delta)
	if absf(right.y) > 0.0 and absf(right.y) > absf(right.x) * 0.6:
		world.zoom_by(right.y * ZOOM_SPEED * delta)



func _popup_pad() -> bool:
	var open: = false
	for w in get_viewport().get_embedded_subwindows():
		if w is PopupMenu and w.visible:
			open = true
			break
	if not open:
		_popup_held.clear()
		return false
	var ly: = Input.get_joy_axis(_pad, JOY_AXIS_LEFT_Y)

	var now: = {
		KEY_UP: _pad_only("ui_up", JOY_BUTTON_DPAD_UP) or ly < -0.6, 
		KEY_DOWN: _pad_only("ui_down", JOY_BUTTON_DPAD_DOWN) or ly > 0.6, 
		KEY_ENTER: _pad_only("ui_accept", JOY_BUTTON_A), 
		KEY_ESCAPE: _pad_only("ui_cancel", JOY_BUTTON_B), 
	}
	if _popup_held.is_empty():


		if _a_down:
			_a_down = false
			_click(MOUSE_BUTTON_LEFT, false)
	else:
		for k in now:
			if now[k] and not bool(_popup_held.get(k, false)):
				_key(k)
	_popup_held = now
	return true



func _pad_only(action: String, b: JoyButton) -> bool:
	if not Input.is_joy_button_pressed(_pad, b):
		return false
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton and ev.button_index == b:
			return false
	return true


func _input(event: InputEvent) -> void :

	if (event is InputEventJoypadButton and event.pressed) or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.5):
		hints.set_pad(true, Input.get_joy_name(event.device))
	elif hints.pad_on and ((event is InputEventKey and event.pressed and not event.echo) or (event is InputEventMouseButton and event.pressed)) and Time.get_ticks_msec() - _synth_at > 250:
		hints.set_pad(false)
	if event is InputEventMouse:
		_mouse_win = get_viewport().get_final_transform() * (event as InputEventMouse).position

		if event is InputEventMouseMotion and Time.get_ticks_msec() - _synth_at > 250:
			_point_at = Time.get_ticks_msec()
			_nav_last = null
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		_point_at = Time.get_ticks_msec()
		_nav_last = null
	if event is InputEventJoypadMotion:
		_pad = event.device
		return
	if not event is InputEventJoypadButton:
		return
	_pad = event.device
	var b: int = event.button_index
	if b == JOY_BUTTON_START:

		return
	if _menu_open():
		get_viewport().set_input_as_handled()
		match b:
			JOY_BUTTON_A:
				if event.pressed != _a_down:



					if event.pressed:
						var start: = _start()
						if start != null and start != _nav_last:
							_go_to(start)
					_a_down = event.pressed
					_click(MOUSE_BUTTON_LEFT, event.pressed)
			JOY_BUTTON_X:
				if event.pressed and world.menus != null and str(world.menus.get("_mode")) == "chest":


					_key(KEY_F)
				elif event.pressed:
					_click(MOUSE_BUTTON_RIGHT, true)
					_click(MOUSE_BUTTON_RIGHT, false)
			JOY_BUTTON_B:
				if event.pressed:
					_key(KEY_ESCAPE)


			JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_LEFT_SHOULDER:
				if event.pressed and world.menus != null and str(world.menus.get("_mode")) == "level_up":
					_key(KEY_R if b == JOY_BUTTON_RIGHT_SHOULDER else KEY_B)
			JOY_BUTTON_Y:

				if event.pressed:
					_key(KEY_Q)
			JOY_BUTTON_BACK:
				if event.pressed:
					_key(KEY_C if world.town != null and is_instance_valid(world.town) else KEY_TAB)
			JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT:
				var dir: Vector2 = {JOY_BUTTON_DPAD_UP: Vector2.UP, JOY_BUTTON_DPAD_DOWN: Vector2.DOWN, 
					JOY_BUTTON_DPAD_LEFT: Vector2.LEFT, JOY_BUTTON_DPAD_RIGHT: Vector2.RIGHT}[b]
				if event.pressed:
					_nav_dir = dir
					_nav_t = NAV_FIRST
					_jump(dir)
				elif _nav_dir == dir:
					_nav_dir = Vector2.ZERO
		return
	if _a_down and b == JOY_BUTTON_A and not event.pressed:

		_a_down = false
		_click(MOUSE_BUTTON_LEFT, false)
	if _typing() or not event.pressed:
		return
	match b:
		JOY_BUTTON_A:
			if world.town != null and is_instance_valid(world.town):
				world.town.talk_nearest()
		JOY_BUTTON_X:

			_key(KEY_X if world.town != null and is_instance_valid(world.town) else KEY_F)
		JOY_BUTTON_Y:
			_key(KEY_Q)
		JOY_BUTTON_BACK:
			_key(KEY_C if world.town != null and is_instance_valid(world.town) else KEY_TAB)
		JOY_BUTTON_RIGHT_STICK:
			_key(KEY_G)
		JOY_BUTTON_B:

			_key(KEY_ESCAPE)
		_:
			return
	get_viewport().set_input_as_handled()




func _jump(dir: Vector2) -> void :


	var vp: = get_viewport()
	var on: Control = _start()
	var from: = _window_center(on) if on != null else _here()
	var best: Control = null
	var best_score: = INF
	for c in _targets():
		if c == on:
			continue
		var at: = _window_center(c)
		var d: = at - from
		var ahead: = d.dot(dir)
		if ahead < 6.0:
			continue
		var side: = absf(d.dot(Vector2( - dir.y, dir.x)))

		var score: = ahead + side * 2.2
		if score < best_score:
			best_score = score
			best = c
	if best == null and on == null:


		for c in _targets():
			var dd: = _window_center(c).distance_to(from)
			if dd < best_score:
				best_score = dd
				best = c
	if best == null:
		return

	var sc: = _scroll_of(best)
	if sc != null:
		sc.ensure_control_visible(best)
		await vp.get_tree().process_frame
		if not is_instance_valid(best):
			return
	_go_to(best)





func _start() -> Control:
	if _nav_last != null and is_instance_valid(_nav_last) and _nav_last.is_visible_in_tree():





		if _targets().has(_nav_last):
			return _nav_last
		_nav_last = null
	var f: = get_viewport().gui_get_focus_owner()
	if f != null and _focus_at >= _point_at and f.is_visible_in_tree() and _reachable(f, _view_size())\
	and (world == null or world.menus == null or (world.menus as Node).is_ancestor_of(f)) and _targets().has(f):
		return f
	return null




func pad_click() -> bool:
	return hints != null and hints.pad_on and Time.get_ticks_msec() - _synth_at < 250



func _go_to(c: Control) -> void :
	_nav_last = c
	if c.focus_mode != Control.FOCUS_NONE:
		c.grab_focus()
	var to: = _window_center(c)
	var was: = _here()
	_cursor = to
	_synth_at = Time.get_ticks_msec()
	Input.warp_mouse(to)
	var m: = InputEventMouseMotion.new()
	m.position = to
	m.global_position = to
	m.relative = to - was
	Input.parse_input_event(m)


	if not c.get_signal_connection_list("mouse_entered").is_empty():
		await get_tree().process_frame
		await get_tree().process_frame
		if _nav_last == c and is_instance_valid(c) and c.is_visible_in_tree():
			c.mouse_entered.emit()






func _targets() -> Array[Control]:
	var root: Node = world.menus if world != null and world.menus != null else get_tree().root
	var out: Array[Control] = _buttons_in(root)
	if out.is_empty():
		out = _buttons_in(get_tree().root)
	return out


func _buttons_in(root: Node) -> Array[Control]:
	var out: Array[Control] = []
	var view: = _view_size()
	var screen: = Rect2(Vector2.ZERO, view)
	for n in root.find_children("*", "Control", true, false):
		var c: = n as Control
		if c.mouse_filter != Control.MOUSE_FILTER_STOP or not c.is_visible_in_tree():
			continue
		var r: = _window_rect(c)

		if r.size.x >= view.x * 0.9 and r.size.y >= view.y * 0.9 and not c is BaseButton:
			out.clear()
			continue
		if not _reachable(c, view):
			continue
		if not screen.has_point(r.get_center()) and _scroll_of(c) == null:
			continue
		out.append(c)
	return out



func _reachable(c: Control, view: Vector2) -> bool:
	if c.mouse_filter == Control.MOUSE_FILTER_IGNORE or c.size.x < 4.0 or c.size.y < 4.0:
		return false
	if c is BaseButton:
		return not (c as BaseButton).disabled
	if c is ScrollContainer or c is LineEdit or c is TextEdit or c.mouse_filter != Control.MOUSE_FILTER_STOP:
		return false
	var r: = _window_rect(c)
	return r.size.x < view.x * 0.45 and r.size.y < view.y * 0.45 and not c.get_signal_connection_list("gui_input").is_empty()


func _view_size() -> Vector2:
	return Vector2(DisplayServer.window_get_size())



func _window_rect(c: Control) -> Rect2:
	var xf: = get_viewport().get_final_transform() * c.get_global_transform_with_canvas()
	return Rect2(xf.origin, xf.basis_xform(c.size))


func _scroll_of(c: Control) -> ScrollContainer:
	var n: = c.get_parent()
	while n != null:
		if n is ScrollContainer:
			return n
		n = n.get_parent()
	return null



func _window_center(c: Control) -> Vector2:
	var at: Vector2 = c.get_global_transform_with_canvas() * (c.size * 0.5)
	return get_viewport().get_final_transform() * at



func _check_triggers() -> void :
	for axis in _triggers:
		var on: = Input.get_joy_axis(_pad, axis) > 0.6
		if on and not _triggers[axis] and not _menu_open() and not _typing():
			_key(KEY_R if axis == JOY_AXIS_TRIGGER_LEFT else KEY_V)
		_triggers[axis] = on



func _px_scale() -> float:
	return maxf(0.5, float(DisplayServer.window_get_size().y) / 720.0)


func _move_cursor(by: Vector2) -> void :
	_nav_last = null
	var size: = Vector2(DisplayServer.window_get_size())
	if _cursor.x < 0.0:
		_cursor = _mouse_now().clamp(Vector2.ZERO, size - Vector2.ONE)
	var was: = _cursor
	_cursor = (_cursor + by).clamp(Vector2.ZERO, size - Vector2.ONE)
	if _cursor.round() == was.round():
		return
	_synth_at = Time.get_ticks_msec()

	_point_at = _synth_at
	Input.warp_mouse(_cursor)
	var m: = InputEventMouseMotion.new()
	m.position = _cursor
	m.global_position = _cursor
	m.relative = _cursor - was
	m.button_mask = MOUSE_BUTTON_MASK_LEFT if _a_down else 0
	Input.parse_input_event(m)


func _here() -> Vector2:

	if _nav_last != null and is_instance_valid(_nav_last) and _nav_last.is_visible_in_tree():
		return _window_center(_nav_last)
	if _cursor.x < 0.0:
		var size: = Vector2(DisplayServer.window_get_size())
		_cursor = _mouse_now().clamp(Vector2.ZERO, size - Vector2.ONE)
	return _cursor




func _mouse_now() -> Vector2:



	if _mouse_win.x >= 0.0:
		return _mouse_win
	if not _mobile:
		return Vector2(DisplayServer.mouse_get_position() - DisplayServer.window_get_position())
	return _view_size() * 0.5


func _click(button: MouseButton, pressed: bool) -> void :
	_synth_at = Time.get_ticks_msec()
	var e: = InputEventMouseButton.new()
	e.button_index = button
	e.pressed = pressed
	e.position = _here()
	e.global_position = e.position
	e.button_mask = (MOUSE_BUTTON_MASK_LEFT if button == MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_RIGHT) if pressed else 0
	Input.parse_input_event(e)


func _wheel(button: MouseButton) -> void :
	_synth_at = Time.get_ticks_msec()
	for pressed in [true, false]:
		var e: = InputEventMouseButton.new()
		e.button_index = button
		e.pressed = pressed
		e.factor = 1.0
		e.position = _here()
		e.global_position = e.position
		Input.parse_input_event(e)


func _key(code: Key) -> void :
	_synth_at = Time.get_ticks_msec()
	for pressed in [true, false]:
		var e: = InputEventKey.new()
		e.keycode = code
		e.physical_keycode = code
		e.pressed = pressed
		Input.parse_input_event(e)





func _draw_overlay() -> void :
	if hints == null or not hints.pad_on or (Input.get_connected_joypads().is_empty() and not test_pad) or not _menu_open():
		return
	var inv: = get_viewport().get_final_transform().affine_inverse()
	var on: Control = _nav_last if _nav_last != null and is_instance_valid(_nav_last) and _nav_last.is_visible_in_tree() else null
	if on == null:


		var f: = get_viewport().gui_get_focus_owner()
		if f != null and _focus_at >= _point_at and f.is_visible_in_tree() and world != null and world.menus != null and (world.menus as Node).is_ancestor_of(f) and not (f is LineEdit or f is TextEdit):


			var now: = Time.get_ticks_msec()
			if now - _ov_at > OVERLAY_TARGETS_MS:
				_ov_targets = _targets()
				_ov_at = now
			if _ov_targets.has(f):
				on = f
	if on != null:



		var r: = _window_rect(on)
		var box: = Rect2(inv * r.position, inv.basis_xform(r.size)).grow(2.0)
		var pulse: = 0.65 + 0.35 * sin(Time.get_ticks_msec() * 0.008)
		_overlay.draw_rect(box.grow(1.5), Color(0.1, 0.06, 0.0, 0.55 * pulse), false, 2.0)
		_overlay.draw_rect(box, Color(1.0, 0.82, 0.25, pulse), false, 2.0)
		return
	if not _mobile or _mouse_win.x < 0.0:
		return

	var at: = inv * _mouse_win
	var k: = maxf(1.0, _view_size().y / 720.0) / maxf(0.01, get_viewport().get_final_transform().get_scale().y)
	var pts: = PackedVector2Array([Vector2(0, 0), Vector2(0, 17), Vector2(4.5, 13), Vector2(8, 20), Vector2(10.5, 19), Vector2(7, 12), Vector2(12.5, 12)])
	for i in pts.size():
		pts[i] = at + pts[i] * k
	_overlay.draw_colored_polygon(pts, Color.WHITE)
	pts.append(pts[0])
	_overlay.draw_polyline(pts, Color(0.05, 0.05, 0.1), 1.5 * k, true)
