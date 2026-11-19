extends Node












var _fields: = {}

var _active: = 0

var _grace: = 0
var _sent: = ""
var _cb: JavaScriptObject

const JS: = "\r\n(function() {\r\n\tif (window.__msKb) return;\r\n\tvar inp = document.createElement('input');\r\n\tinp.type = 'text';\r\n\tinp.setAttribute('autocomplete', 'off');\r\n\tinp.setAttribute('autocorrect', 'off');\r\n\tinp.setAttribute('autocapitalize', 'off');\r\n\tinp.setAttribute('spellcheck', 'false');\r\n\tinp.setAttribute('enterkeyhint', 'done');\r\n\tvar s = inp.style;\r\n\ts.position = 'fixed'; s.left = '50%'; s.top = '8px'; s.transform = 'translateX(-50%)';\r\n\ts.width = 'min(520px, 90vw)'; s.height = '44px'; s.boxSizing = 'border-box';\r\n\ts.padding = '0 12px'; s.fontSize = '18px'; s.zIndex = '1000';\r\n\t// Always rendered, only hidden (see-through, not touchable): Safari\r\n\t// opens no keyboard for an input that was display:none until that very\r\n\t// tap (the box showed, the keyboard never came: an iPhone, Discord).\r\n\tvar shown = false;\r\n\tfunction look(on) {\r\n\t\tshown = on;\r\n\t\ts.opacity = on ? '1' : '0';\r\n\t\ts.pointerEvents = on ? 'auto' : 'none';\r\n\t\ts.visibility = 'visible';\r\n\t}\r\n\tlook(false);\r\n\ts.border = '2px solid #c9a85a'; s.borderRadius = '10px'; s.background = '#ffffff';\r\n\ts.color = '#111827'; s.outline = 'none'; s.boxShadow = '0 4px 18px rgba(0,0,0,.45)';\r\n\tdocument.body.appendChild(inp);\r\n\tvar kb = {fields: [], id: 0, last: 0, cb: null};\r\n\twindow.__msKb = kb;\r\n\tfunction send(o) { if (kb.cb) kb.cb(JSON.stringify(o)); }\r\n\tfunction place() {\r\n\t\tvar vv = window.visualViewport;\r\n\t\ts.top = ((vv ? vv.offsetTop : 0) + 8) + 'px';\r\n\t}\r\n\tif (window.visualViewport) {\r\n\t\twindow.visualViewport.addEventListener('resize', place);\r\n\t\twindow.visualViewport.addEventListener('scroll', place);\r\n\t}\r\n\t// Godot's own IME box (a hidden contenteditable) is focused every 100 ms\r\n\t// while a LineEdit has focus, and the canvas when it loses it: either\r\n\t// takes the focus from this input and Safari closes the keyboard (that\r\n\t// box got the focus, never a keyboard: no tap). Neither while typing here.\r\n\tfunction tame() {\r\n\t\tvar ime = document.querySelector('div.ime');\r\n\t\tif (ime && !ime.__ms) { ime.__ms = true; ime.focus = function() {}; }\r\n\t\tvar c = document.getElementById('canvas');\r\n\t\tif (c && !c.__ms) {\r\n\t\t\tc.__ms = true;\r\n\t\t\tvar f0 = c.focus;\r\n\t\t\tc.focus = function() { if (shown) return; return f0.apply(c, arguments); };\r\n\t\t}\r\n\t}\r\n\ttame();\r\n\tkb.set = function(json) { kb.fields = JSON.parse(json); tame(); };\r\n\t// The keys of an iPad's keyboard go back to the game.\r\n\tfunction back() {\r\n\t\tvar c = document.getElementById('canvas');\r\n\t\tif (c) c.focus();\r\n\t}\r\n\tkb.hide = function() {\r\n\t\tif (!shown) return;\r\n\t\tkb.id = 0;\r\n\t\tlook(false);\r\n\t\tinp.blur();\r\n\t\twindow.scrollTo(0, 0);\r\n\t\tback();\r\n\t};\r\n\tfunction tap(x, y) {\r\n\t\ttame();\r\n\t\tvar c = document.getElementById('canvas') || document.querySelector('canvas');\r\n\t\tif (!c) return;\r\n\t\tvar r = c.getBoundingClientRect();\r\n\t\tif (r.width <= 0 || r.height <= 0) return;\r\n\t\tvar nx = (x - r.left) / r.width, ny = (y - r.top) / r.height;\r\n\t\tfor (var i = kb.fields.length - 1; i >= 0; i--) {\r\n\t\t\tvar f = kb.fields[i];\r\n\t\t\tif (nx < f.x0 - 0.01 || nx > f.x1 + 0.01 || ny < f.y0 - 0.01 || ny > f.y1 + 0.01) continue;\r\n\t\t\tif (kb.id !== f.id && kb.id !== 0) send({ev: 'leave', id: kb.id, v: inp.value});\r\n\t\t\tkb.id = f.id;\r\n\t\t\tinp.type = f.secret ? 'password' : 'text';\r\n\t\t\tinp.maxLength = f.max > 0 ? f.max : 524288;\r\n\t\t\tinp.placeholder = f.hint || '';\r\n\t\t\tinp.setAttribute('inputmode', f.num ? 'numeric' : 'text');\r\n\t\t\tinp.value = f.text;\r\n\t\t\tlook(true);\r\n\t\t\tplace();\r\n\t\t\tinp.focus({preventScroll: true});\r\n\t\t\ttry { inp.setSelectionRange(inp.value.length, inp.value.length); } catch (e) {}\r\n\t\t\tsend({ev: 'open', id: f.id});\r\n\t\t\treturn true;\r\n\t\t}\r\n\t\treturn false;\r\n\t}\r\n\tfunction onTap(ev) {\r\n\t\tif (ev.target === inp) return;\r\n\t\tvar now = Date.now();\r\n\t\tif (now - kb.last < 350) return;\r\n\t\tvar p = ev.changedTouches ? ev.changedTouches[0] : ev;\r\n\t\tif (!p) return;\r\n\t\tkb.last = now;\r\n\t\t// (No mouse events after it: they would move the focus to the canvas.)\r\n\t\tif (tap(p.clientX, p.clientY) && ev.cancelable && ev.changedTouches) ev.preventDefault();\r\n\t}\r\n\twindow.addEventListener('touchend', onTap, {capture: true, passive: false});\r\n\twindow.addEventListener('pointerup', function(ev) { if (ev.pointerType === 'mouse') onTap(ev); }, true);\r\n\tinp.addEventListener('input', function() { if (kb.id) send({ev: 'text', id: kb.id, v: inp.value}); });\r\n\tinp.addEventListener('keydown', function(ev) {\r\n\t\tev.stopPropagation();\r\n\t\tif (ev.key === 'Enter') {\r\n\t\t\tev.preventDefault();\r\n\t\t\tvar id = kb.id;\r\n\t\t\tsend({ev: 'enter', id: id, v: inp.value});\r\n\t\t\tkb.hide();\r\n\t\t} else if (ev.key === 'Escape') {\r\n\t\t\tev.preventDefault();\r\n\t\t\tvar id2 = kb.id;\r\n\t\t\tkb.hide();\r\n\t\t\tsend({ev: 'close', id: id2});\r\n\t\t}\r\n\t});\r\n\tinp.addEventListener('keyup', function(ev) { ev.stopPropagation(); });\r\n\tinp.addEventListener('blur', function() {\r\n\t\tif (!shown) return;\r\n\t\tvar id = kb.id;\r\n\t\tlook(false);\r\n\t\tkb.id = 0;\r\n\t\twindow.scrollTo(0, 0);\r\n\t\tsend({ev: 'close', id: id, v: inp.value});\r\n\t\tback();\r\n\t});\r\n})();\r\n"






































































































































func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.has_feature("web"):
		set_process(false)
		return
	JavaScriptBridge.eval(JS, true)
	var kb: = JavaScriptBridge.get_interface("__msKb")
	if kb == null:
		set_process(false)
		return

	_cb = JavaScriptBridge.create_callback(_on_page)
	kb.cb = _cb
	get_tree().node_added.connect(_on_node)
	for n in get_tree().root.find_children("*", "LineEdit", true, false):
		_on_node(n)
	for n in get_tree().root.find_children("*", "TextEdit", true, false):
		_on_node(n)


func _on_node(n: Node) -> void :
	if not (n is LineEdit or n is TextEdit):
		return
	var id: = n.get_instance_id()
	if _fields.has(id):
		return
	_fields[id] = true
	n.tree_exiting.connect( func(): _fields.erase(id), CONNECT_ONE_SHOT)


func _field(id: int) -> Control:
	var o: Object = instance_from_id(id) if id != 0 else null
	return o as Control if o != null and is_instance_valid(o) else null


func _process(_delta: float) -> void :
	_push_rects()
	if _active == 0:
		return


	var f: = _field(_active)
	if _grace > 0:
		_grace -= 1
		if f != null and f.has_focus():
			_grace = 0
		return
	if f == null or not f.has_focus() or not f.is_visible_in_tree():
		_active = 0
		JavaScriptBridge.eval("window.__msKb && window.__msKb.hide()", true)



func _push_rects() -> void :
	var out: = []
	var ws: = Vector2(DisplayServer.window_get_size())
	if ws.x > 0.0 and ws.y > 0.0:
		for id in _fields:
			var c: = _field(int(id))
			if c == null or not c.is_inside_tree() or not c.is_visible_in_tree() or c.focus_mode == Control.FOCUS_NONE\
			or c.mouse_filter == Control.MOUSE_FILTER_IGNORE or not bool(c.get("editable")):
				continue
			var xf: = c.get_viewport().get_screen_transform() * c.get_global_transform_with_canvas()
			var a: = xf * Vector2.ZERO
			var b: = xf * c.size
			var r: = Rect2(a, b - a).abs()
			if r.size.x < 2.0 or r.size.y < 2.0 or not r.intersects(Rect2(Vector2.ZERO, ws)):
				continue
			var line: = c as LineEdit
			out.append({"id": int(id), "x0": snappedf(r.position.x / ws.x, 0.0001), "y0": snappedf(r.position.y / ws.y, 0.0001), 
				"x1": snappedf(r.end.x / ws.x, 0.0001), "y1": snappedf(r.end.y / ws.y, 0.0001), 
				"text": str(c.get("text")), "secret": line != null and line.secret, 
				"max": line.max_length if line != null else 0, 
				"hint": str(c.get("placeholder_text")), 
				"num": line != null and line.virtual_keyboard_type == LineEdit.KEYBOARD_TYPE_NUMBER})
	var json: = JSON.stringify(out)
	if json == _sent:
		return
	_sent = json
	JavaScriptBridge.eval("window.__msKb && window.__msKb.set(%s)" % JSON.stringify(json), true)




func _on_page(args: Array) -> void :
	if args.is_empty():
		return
	var d: Variant = JSON.parse_string(str(args[0]))
	if not (d is Dictionary):
		return
	var id: = int(d.get("id", 0))
	var f: = _field(id)
	var ev: = str(d.get("ev", ""))
	if d.has("v") and f != null:
		_write(f, str(d.v))
	match ev:
		"open":
			_active = id
			_grace = 3
		"enter":
			_active = 0
			if f is LineEdit:
				(f as LineEdit).text_submitted.emit((f as LineEdit).text)
			if f != null and is_instance_valid(f) and f.has_focus():
				f.release_focus()
		"close":
			if id == _active:
				_active = 0
			if f != null and f.has_focus():
				f.release_focus()
	_sent = ""



func _write(f: Control, v: String) -> void :
	if str(f.get("text")) == v:
		return
	if f is LineEdit:
		var e: = f as LineEdit
		e.text = v
		e.caret_column = v.length()
		e.text_changed.emit(v)
	elif f is TextEdit:
		var t: = f as TextEdit
		t.text = v
		t.set_caret_line(t.get_line_count() - 1)
		t.set_caret_column(t.get_line(t.get_line_count() - 1).length())
		t.text_changed.emit()
