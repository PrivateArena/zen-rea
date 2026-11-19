extends Node

















const SLOP: = 16.0

const FLING_MIN: = 240.0

const FLING_DRAG: = 5.0


static var dragged: = false

var _down: = false
var _at: = Vector2.ZERO
var _last: = Vector2.ZERO
var _last_us: = 0
var _scroll: ScrollContainer
var _vertical: = true
var _active: = false
var _vel: = 0.0
var _fling: ScrollContainer


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)


func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_down = true
			_active = false
			dragged = false
			_scroll = null
			_fling = null
			_vel = 0.0
			_at = event.position
			_last = event.position
			_last_us = Time.get_ticks_usec()
		else:
			_down = false
			if _active:
				_active = false
				if absf(_vel) > FLING_MIN and is_instance_valid(_scroll):
					_fling = _scroll
		return
	if not (event is InputEventMouseMotion) or not _down:
		return
	if not _active:
		var d: Vector2 = event.position - _at
		if d.length() <= SLOP:
			return
		_vertical = absf(d.y) >= absf(d.x)
		_scroll = _scroll_under(_vertical)
		if _scroll == null:

			_down = false
			return
		_active = true
		dragged = true
		_call_off_press()
		_last = event.position
	if not is_instance_valid(_scroll) or not _scroll.is_visible_in_tree():
		_down = false
		_active = false
		return
	var scale: = _scroll.get_global_transform_with_canvas().get_scale()
	var move: float = (event.position.y - _last.y) / maxf(scale.y, 0.01) if _vertical\
	else (event.position.x - _last.x) / maxf(scale.x, 0.01)
	_push(_scroll, - move)
	var now: = Time.get_ticks_usec()
	var dt: = maxf((now - _last_us) / 1000000.0, 0.001)
	_vel = lerpf(_vel, - move / dt, 0.4)
	_last = event.position
	_last_us = now
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void :
	if _fling == null:
		return
	if not is_instance_valid(_fling) or not _fling.is_visible_in_tree() or absf(_vel) < 20.0:
		_fling = null
		return
	if not _push(_fling, _vel * delta):
		_fling = null
		return
	_vel *= exp( - FLING_DRAG * delta)



func _push(sc: ScrollContainer, by: float) -> bool:
	if _vertical:
		var before: = sc.scroll_vertical
		sc.scroll_vertical = int(roundf(before + by))
		return sc.scroll_vertical != before
	var was: = sc.scroll_horizontal
	sc.scroll_horizontal = int(roundf(was + by))
	return sc.scroll_horizontal != was



func _scroll_under(vertical: bool) -> ScrollContainer:
	var c: = get_viewport().gui_get_hovered_control()
	if c is ScrollBar or c is Slider or c is TextEdit:
		return null
	while c != null:

		if c.has_meta("no_touch_scroll"):
			return null
		if c is ScrollContainer:
			var sc: = c as ScrollContainer
			var bar: ScrollBar = sc.get_v_scroll_bar() if vertical else sc.get_h_scroll_bar()
			var mode: = sc.vertical_scroll_mode if vertical else sc.horizontal_scroll_mode
			if mode != ScrollContainer.SCROLL_MODE_DISABLED and bar.max_value - bar.page > 1.0:
				return sc
		c = c.get_parent() as Control
	return null




func _call_off_press() -> void :
	var c: = get_viewport().gui_get_hovered_control()
	while c != null and not (c is BaseButton):
		if c is ScrollContainer:
			return
		c = c.get_parent() as Control
	var b: = c as BaseButton
	if b != null and not b.disabled and not b.toggle_mode:
		b.disabled = true
		b.disabled = false



func _on_node_added(n: Node) -> void :
	if not (n is BaseButton):
		return
	var p: = n.get_parent()
	while p != null:
		if p is ScrollContainer:
			(n as BaseButton).action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			return
		p = p.get_parent()




static func _hint_re() -> RegEx:
	return RegEx.create_from_string("\\s*\\((?:Tab|TAB|Esc|ESC|Enter|ENTER|Espacio|Space|Shift|Ctrl|Alt|Supr|F\\d{1,2}|[A-Z](?: / [A-Z])?)\\)")


static func strip(text: String) -> String:
	return _hint_re().sub(text, "", true)




static func strip_key_hints() -> void :
	var re: = _hint_re()
	var es: = Translation.new()
	es.locale = "es"
	var done: = {}
	for code in TranslationServer.get_loaded_locales():
		var t: = TranslationServer.get_translation_object(code)
		if t == null or t.locale.begins_with("es"):
			continue
		for id in t.get_message_list():
			var src: = str(id)
			if re.search(src) == null:
				continue
			t.add_message(src, re.sub(str(t.get_message(src)), "", true))
			if not done.has(src):
				done[src] = true
				es.add_message(src, re.sub(src, "", true))
	var old: = TranslationServer.get_translation_object("es")
	if old != null and old.locale == "es":
		TranslationServer.remove_translation(old)
	TranslationServer.add_translation(es)
