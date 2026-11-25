class_name MouseWalk
extends Node3D







const ARRIVE: = 0.3


const ARRIVE_STEP_MAX: = 2.0
var _last_from: = Vector3.INF
var _stuck: = 0.0
var _last_us: = 0
var _step: = 0.0

const WAKE_PIXELS: = 6.0

var world: World
var target: = Vector3.ZERO

var active: = false
var _holding: = false

var _mouse_mode: = true
var _wake_from: = Vector2.ZERO
var _hover: Sprite3D
var _dest: Sprite3D




var _stick: = false
var _anchor: = Vector2.ZERO
var _thumb: = Vector2.ZERO

var _move_finger: = -1
var _cam_finger: = -1
var _cam_thumb: = Vector2.ZERO
var _cam_moved: = false
var _cam_since: = 0
var _pad: Control



var _free: = {}
var _pinch: = 0.0
const STICK_RADIUS: = 62.0
const STICK_KNOB: = 26.0
const STICK_DEAD: = 6.0

const STICK_GRAB: = 135.0



const STICK_SIZE_DEFAULT: = 1.3



const SWIPE_START: = 14.0
const SWIPE_TURN: = 0.006
const TAP_MS: = 350

var _swipe: = {}


static func tap_walk() -> bool:
	return bool(Save.setting("tap_walk", false))


static func stick_k() -> float:
	return clampf(float(Save.setting("stick_size", STICK_SIZE_DEFAULT)), 0.8, 2.2)



static func stick_r() -> float:
	return STICK_RADIUS * stick_k()


static func stick_grab() -> float:
	return STICK_GRAB * stick_k()

const CAM_TURN_SPEED: = 2.4




func stick_center() -> Vector2:
	return _corner(sticks_swapped())



func cam_stick_center() -> Vector2:
	return _corner( not sticks_swapped())


static func sticks_swapped() -> bool:
	return bool(Save.setting("sticks_swapped", false))




static func sticks_hidden() -> bool:
	return bool(Save.setting("sticks_hidden", false))




func stick_free() -> bool:
	return bool(Save.setting("stick_free", false)) and world != null and world.town == null




func _grabs_stick(p: Vector2) -> bool:
	if p.distance_to(stick_center()) <= stick_grab():
		return true
	if not stick_free():
		return false
	if _cam_stick_on() and p.distance_to(cam_stick_center()) <= stick_grab():
		return false
	var half: = get_viewport().get_visible_rect().size.x * 0.5
	return p.x >= half if sticks_swapped() else p.x < half




func _anchor_for(p: Vector2) -> Vector2:
	return p if stick_free() and p.distance_to(stick_center()) > stick_r() else stick_center()


func _corner(right: bool) -> Vector2:
	var view: = get_viewport().get_visible_rect().size
	return Vector2(view.x - 36.0 - stick_r() if right else 36.0 + stick_r(), view.y - 44.0 - stick_r())




func _talking() -> bool:
	return world != null and world.hud != null and int(world.hud.get("_talks")) > 0


func _cam_stick_on() -> bool:
	return _stick_shown() and not _talking() and world.camera_turns()






const F_BUTTON_R: = 34.0
func f_button_on() -> bool:
	if not _stick_shown() or _talking() or (world.town != null and not world.training) or not world.running or world.player == null:
		return false
	return world.player.f_skill() != ""





func cannon_button_on() -> bool:
	if not _stick_shown() or _talking() or (world.town != null and not world.training) or not world.running or world.player == null:
		return false
	return Uniques.cannon(world.player) != ""


func cannon_button_center() -> Vector2:
	var c: = f_button_center()
	return c + Vector2(0.0, - (f_button_r() * 2.0 + 14.0)) if f_button_on() else c


func f_button_center() -> Vector2:


	var c: = cam_stick_center()
	var side: = -1.0 if not sticks_swapped() else 1.0
	return c + Vector2(side * (stick_r() + f_button_r() + 10.0), - (stick_r() * 0.75))


func f_button_r() -> float:
	return F_BUTTON_R * stick_k()


func _press_f() -> void :
	var p: Player = world.player
	if p.f_skill() != "":
		world.skill_switch(p.f_skill(), true)
	_f_flash = Time.get_ticks_msec()
	_pad.queue_redraw()


func _press_cannon() -> void :
	world.skill_switch("u_overload")
	_cannon_flash = Time.get_ticks_msec()
	_pad.queue_redraw()


var _f_flash: = -10000
var _cannon_flash: = -10000


func _stick_shown() -> bool:
	return world != null and (world.running or world.town != null or is_instance_valid(world.valhalla)) and world.menus.mode() in ["closed", "town"] and not world.get_tree().paused


static func touch() -> bool:
	if _touch < 0:
		_touch = 1 if OS.has_feature("mobile") or "--touch" in OS.get_cmdline_user_args() or _web_touch() else 0
	return _touch == 1
static var _touch: = -1




static func _web_touch() -> bool:
	if not OS.has_feature("web"):
		return false
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return true
	return bool(JavaScriptBridge.eval("matchMedia('(pointer: coarse)').matches && !matchMedia('(pointer: fine)').matches", true))


func _process(delta: float) -> void :
	if _pad == null:
		return

	if not _stick_shown():
		_stick = false
		_move_finger = -1
		_cam_finger = -1
		_free.clear()
		_swipe.clear()
		_pinch = 0.0
	elif _stick and _move_finger < 0 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_stick = false
	if _cam_finger >= 0 and not _cam_stick_on():
		_cam_finger = -1
	if _cam_finger >= 0:
		var x: = (_cam_thumb - cam_stick_center()).x
		if absf(x) > STICK_DEAD:

			var tilt: = clampf((absf(x) - STICK_DEAD) / (stick_r() - STICK_DEAD), 0.0, 1.0) * signf(x)
			world.set_view_yaw(RoVisual.view_yaw - tilt * CAM_TURN_SPEED * delta)
	_pad.queue_redraw()




func _unhandled_input(event: InputEvent) -> void :
	if _pad == null:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if not _stick_shown():
				return
			if cannon_button_on() and event.position.distance_to(cannon_button_center()) <= f_button_r() + 8.0:
				_press_cannon()
				get_viewport().set_input_as_handled()
				return
			if f_button_on() and event.position.distance_to(f_button_center()) <= f_button_r() + 8.0:
				_press_f()
				get_viewport().set_input_as_handled()
				return


			if _move_finger >= 0 and stick_free() and _thumb.distance_to(_anchor) < STICK_DEAD and not (_cam_stick_on() and event.position.distance_to(cam_stick_center()) <= stick_grab()):
				_free[_move_finger] = _thumb
				_move_finger = -1
				_stick = false
			if _move_finger < 0 and _grabs_stick(event.position):
				_move_finger = event.index
				_stick = true
				_anchor = _anchor_for(event.position)
				_thumb = event.position
				active = false
				_holding = false
			elif _cam_finger < 0 and _cam_stick_on() and event.position.distance_to(cam_stick_center()) <= stick_grab():
				_cam_finger = event.index
				_cam_thumb = event.position
				_cam_moved = false
				_cam_since = Time.get_ticks_msec()
			else:
				_free[event.index] = event.position
				_swipe[event.index] = {"at": event.position, "moved": false, "t": Time.get_ticks_msec()}
				if _free.size() == 2:

					_pinch = maxf(1.0, _pinch_span())
					active = false
					_holding = false
		else:
			var was_pinch: = _pinch > 0.0
			_free.erase(event.index)
			if _free.size() < 2:
				_pinch = 0.0
			var sw = _swipe.get(event.index)
			_swipe.erase(event.index)

			if sw != null and not sw.moved and not was_pinch and _free.is_empty() and tap_walk() and world.town == null and _stick_shown() and Time.get_ticks_msec() - int(sw.t) < TAP_MS:
				var p: = _ground_at(event.position)
				if p != Vector3.INF:
					target = p
					active = true
					_fresh_walk()
					_holding = false
					_mouse_mode = true
			if event.index == _move_finger:
				_move_finger = -1
				_stick = false
			elif event.index == _cam_finger:
				_cam_finger = -1

				if not _cam_moved and Time.get_ticks_msec() - _cam_since < 300:
					world._turn_back()
	elif event is InputEventScreenDrag:
		if _free.has(event.index):
			_free[event.index] = event.position
			var sw = _swipe.get(event.index)
			if sw != null:
				if _free.size() >= 2:
					sw.moved = true
				elif not sw.moved and event.position.distance_to(sw.at) > SWIPE_START:
					sw.moved = true
				elif sw.moved and _pinch <= 0.0 and world.camera_turns() and not _talking() and _stick_shown():

					world.set_view_yaw(RoVisual.view_yaw - event.relative.x * SWIPE_TURN)
			if _pinch > 0.0 and _free.size() >= 2:

				var span: = maxf(1.0, _pinch_span())
				world._cam_distance = clampf(world._cam_distance * _pinch / span, World.ZOOM_NEAR, World.ZOOM_FAR)
				_pinch = span
		if event.index == _move_finger:
			_thumb = event.position
		elif event.index == _cam_finger:
			_cam_thumb = event.position
			if event.position.distance_to(cam_stick_center()) > STICK_DEAD * 2.0:
				_cam_moved = true



func _pinch_span() -> float:
	var at: Array = _free.values()
	return (at[0] as Vector2).distance_to(at[1])




func _over_stick(p: Vector2) -> bool:
	return _grabs_stick(p)\
	or (_cam_stick_on() and p.distance_to(cam_stick_center()) <= stick_grab())\
	or (f_button_on() and p.distance_to(f_button_center()) <= f_button_r() + 8.0)\
	or (cannon_button_on() and p.distance_to(cannon_button_center()) <= f_button_r() + 8.0)


func _ready() -> void :
	_hover = _marker(Color(1, 1, 1, 0.85))
	_dest = _marker(Color(0.55, 1.0, 0.6, 0.95))
	if touch():
		_mouse_mode = false

		process_mode = Node.PROCESS_MODE_ALWAYS
		var layer: = CanvasLayer.new()
		layer.layer = 5
		add_child(layer)
		_pad = Control.new()
		_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_pad.set_anchors_preset(Control.PRESET_FULL_RECT)
		_pad.draw.connect(_draw_pad)
		layer.add_child(_pad)


func _draw_pad() -> void :
	if not _stick_shown():
		return
	var hidden: = sticks_hidden()
	if _stick:
		_draw_stick(_anchor, _thumb - _anchor, true)
	elif not _talking() and not hidden:
		_draw_stick(stick_center(), Vector2.ZERO, false)
	if f_button_on():
		_draw_f_button()
	if cannon_button_on():
		_draw_cannon_button()
	if _cam_stick_on() and (_cam_finger >= 0 or not hidden):
		var held: = _cam_finger >= 0
		var c: = cam_stick_center()
		_draw_stick(c, Vector2((_cam_thumb - c).x, 0.0) if held else Vector2.ZERO, held)

		var col: = Color(1, 1, 1, 0.75 if held else 0.45)
		for side in [-1.0, 1.0]:
			var tip: = c + Vector2(side * (stick_r() - 8.0), 0.0)
			var back: = tip + Vector2( - side * 12.0, 0.0)
			_pad.draw_colored_polygon(PackedVector2Array([tip, back + Vector2(0, -9), back + Vector2(0, 9)]), col)


func _draw_f_button() -> void :
	var p: Player = world.player
	var c: = f_button_center()
	var r: = f_button_r()
	var id: = p.f_skill()

	var on: = id != "" and not p.is_off(id)
	var ring: = Color(0.45, 1.0, 0.55) if on else Color(1.0, 0.45, 0.4)
	var pressed: = Time.get_ticks_msec() - _f_flash < 160
	_pad.draw_circle(c, r, Color(0, 0, 0, 0.45 if pressed else 0.3))
	_pad.draw_arc(c, r, 0.0, TAU, 48, Color(ring, 0.9), 3.0, true)
	var tex: Texture2D = UiKit.skill_icon(id) if id != "" else null
	if tex != null:
		var side: = r * 1.15
		_pad.draw_texture_rect(tex, Rect2(c - Vector2(side, side) * 0.5, Vector2(side, side)), false, Color(1, 1, 1, 1.0 if on else 0.55))
	else:
		var f: Font = ThemeDB.fallback_font
		_pad.draw_string(f, c + Vector2( - r, 8), "F", HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 26, Color.WHITE)
	if pressed:
		_pad.draw_circle(c, r, Color(1, 1, 1, 0.25))





func _draw_cannon_button() -> void :
	var p: Player = world.player
	var c: = cannon_button_center()
	var r: = f_button_r()
	var excal: = Uniques.cannon(p) == "excal"
	var stage: = p.ov_stage
	var ready: = stage >= 1
	var top: = stage >= GameData.U_OV_STAGES
	var gold: = GameData.U_EX_GOLD if excal else GameData.U_OV_GOLD
	var low: = GameData.U_EX_PALE if excal else GameData.U_OV_BLUE
	var col: = gold if top or excal else low.lerp(gold, float(stage) / GameData.U_OV_STAGES)
	var pressed: = Time.get_ticks_msec() - _cannon_flash < 160
	_pad.draw_circle(c, r, Color(0.08, 0.06, 0.0, 0.5) if excal else Color(0, 0, 0, 0.45 if pressed else 0.3))
	_pad.draw_arc(c, r, 0.0, TAU, 48, Color(col, 0.35), 3.0, true)
	var part: = float(stage) / GameData.U_OV_STAGES
	if part > 0.0:
		_pad.draw_arc(c, r, - PI * 0.5, - PI * 0.5 + TAU * part, 48, Color(col, 0.95), 4.0, true)
	if top:
		var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 160.0)
		_pad.draw_arc(c, r + 4.0, 0.0, TAU, 48, Color(gold, 0.3 + 0.4 * pulse), 2.0, true)
	var f: Font = ThemeDB.fallback_font
	var label: = str(stage) if ready else "R"
	_pad.draw_string(f, c + Vector2( - r, 9), label, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, 26, Color(1, 1, 1, 1.0 if ready else 0.5))
	if pressed:
		_pad.draw_circle(c, r, Color(1, 1, 1, 0.25))


func _draw_stick(c: Vector2, off: Vector2, held: bool) -> void :
	_pad.draw_circle(c, stick_r(), Color(0, 0, 0, 0.28 if held else 0.16))
	_pad.draw_arc(c, stick_r(), 0.0, TAU, 48, Color(1, 1, 1, 0.6 if held else 0.35), 3.0, true)
	_pad.draw_circle(c + off.limit_length(stick_r()), STICK_KNOB * stick_k(), Color(1, 1, 1, 0.65 if held else 0.35))


func _marker(col: Color) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = RoAssets.effect_tex("move_grid")
	if s.texture == null:
		s.texture = Vfx.ring_texture()
	s.axis = Vector3.AXIS_Y
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 4
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.modulate = col
	s.pixel_size = 1.0 / float(s.texture.get_width())
	s.visible = false
	add_child(s)
	return s




static func screen_to_world(v: Vector2) -> Vector2:
	if v == Vector2.ZERO or RoVisual.view_yaw == 0.0:
		return v
	var w: = Vector3(v.x, 0.0, v.y).rotated(Vector3.UP, RoVisual.view_yaw)
	return Vector2(w.x, w.z)



func cancel() -> void :
	active = false
	_holding = false
	if _mouse_mode:
		_mouse_mode = false
		_wake_from = get_viewport().get_mouse_position()




var hero_override: Node3D


func walk_to(p: Vector3) -> void :
	target = p
	active = true
	_fresh_walk()
	_holding = false
	_mouse_mode = true




func _fresh_walk() -> void :
	_last_from = Vector3.INF
	_step = 0.0
	_stuck = 0.0


func reset() -> void :
	active = false
	_fresh_walk()
	_holding = false
	_stick = false
	_move_finger = -1
	_cam_finger = -1
	if _pad != null:
		_pad.queue_redraw()
	_hover.visible = false
	_dest.visible = false





const STUCK_SPEED: = 0.6
const STUCK_TIME: = 0.25


func input_vector(from: Vector3) -> Vector2:
	if _stick:
		var v: = _thumb - _anchor
		if v.length() < STICK_DEAD:
			return Vector2.ZERO
		return screen_to_world(v.normalized())



	if _holding and not touch() and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_holding = false
	if _holding:
		var p: = _ground_under_mouse()
		if p != Vector3.INF:
			target = p

	var moved: = 0.0
	var now: = Time.get_ticks_usec()
	var dt: = clampf((now - _last_us) / 1000000.0, 0.0, 0.25)
	_last_us = now
	if _last_from != Vector3.INF:
		moved = minf(ARRIVE_STEP_MAX, Vector2(from.x - _last_from.x, from.z - _last_from.z).length())
	_last_from = from

	_step = maxf(moved, _step * 0.9)
	if not active:
		return Vector2.ZERO
	var to: = target - from
	to.y = 0.0







	var slow: = dt > 0.0 and moved / dt < STUCK_SPEED
	_stuck = _stuck + dt if to.length() < 1.5 and slow else 0.0
	if to.length() <= maxf(ARRIVE, _step * 0.6) or (_stuck >= STUCK_TIME and not _holding):
		_stuck = 0.0


		if not _holding:
			active = false
		return Vector2.ZERO
	var d: = to.normalized()
	return Vector2(d.x, d.z)


func handle_input(event: InputEvent) -> bool:
	if touch():


		var finger: = event.device == InputEvent.DEVICE_ID_EMULATION

		if finger and _pinch > 0.0 and (event is InputEventMouseButton or event is InputEventMouseMotion):
			active = false
			_holding = false
			return true
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _over_stick(event.position):
				if not finger and _move_finger < 0 and _grabs_stick(event.position):
					_stick = true
					_anchor = _anchor_for(event.position)
					_thumb = event.position
				active = false
				_holding = false
				return true
			if not event.pressed and (_stick or _cam_finger >= 0):
				if _move_finger < 0:
					_stick = false
				return true


			if world.town == null or finger:
				return false
		elif event is InputEventMouseMotion:
			if _stick or _cam_finger >= 0:
				if _move_finger < 0 and _stick:
					_thumb = event.position
				return true
			if world.town == null or finger:
				return false
	if event is InputEventMouseMotion and not _mouse_mode:
		if event.position.distance_to(_wake_from) > WAKE_PIXELS:
			_mouse_mode = true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var p: = _ground_under_mouse()
			if p == Vector3.INF:
				return false
			target = p
			active = true
			_fresh_walk()
			_holding = true
			_mouse_mode = true
			return true
		_holding = false
	return false


func update_markers() -> void :
	var over_ui: = get_viewport().gui_get_hovered_control() != null
	var p: = Vector3.INF if over_ui or not _mouse_mode else _ground_under_mouse()
	_place(_hover, p)
	_place(_dest, target if active and _mouse_mode else Vector3.INF)
	if _dest.visible:
		_dest.modulate.a = 0.6 + 0.35 * sin(Time.get_ticks_msec() * 0.012)



func _place(s: Sprite3D, p: Vector3) -> void :
	if p == Vector3.INF or world.map == null:
		s.visible = false
		return
	var cell: = world.map.tile_of(p)
	var c: = world.map.cell_center(cell.x, cell.y)
	s.global_position = Vector3(c.x, world.map.height_at(c) + 0.06, c.z)
	s.visible = true




func _ground_under_mouse() -> Vector3:
	return _ground_at(get_viewport().get_mouse_position())



func _ground_at(m: Vector2) -> Vector3:
	var cam: = world.camera
	var anchor: Node3D = hero_override if hero_override != null and is_instance_valid(hero_override) else (world.town.hero if world.town != null else world.player)
	if cam == null or world.map == null or anchor == null:
		return Vector3.INF
	var origin: = cam.project_ray_origin(m)
	var dir: = cam.project_ray_normal(m)
	if absf(dir.y) < 0.001:
		return Vector3.INF
	var h: = anchor.position.y
	var hit: = Vector3.INF
	for i in 3:
		var t: = (h - origin.y) / dir.y
		if t <= 0.0:
			return Vector3.INF
		hit = origin + dir * t
		h = world.map.height_at(hit)
	return Vector3(hit.x, h, hit.z)
