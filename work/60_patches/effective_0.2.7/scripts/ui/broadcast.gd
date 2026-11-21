extends CanvasLayer















const POLL_EVERY: = 180.0
const REMIND_EVERY: = 600.0

const SPEED: = 150.0
const COLOR: = Color(1.0, 1.0, 0.0)
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")

var _http: HTTPRequest
var _poll: = 20.0
var _reminded_at: = - INF
var _seen: = {}
var _queue: Array[String] = []
var _strip: Control
var _label: Label


func _init() -> void :
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS


const WEB_CURRENT: = "https://updates.midgardsurvivors.com/web/current.json"
var _web_http: HTTPRequest


func _ready() -> void :
	var web: bool = OS.has_feature("web") and not OS.has_feature("editor") and Array(OS.get_cmdline_user_args()).filter(
		func(a): return str(a).begins_with("--")).is_empty()
	if not Updater._enabled() and not web:
		set_process(false)
		return
	_http = HTTPRequest.new()
	_http.timeout = 8.0
	_http.accept_gzip = not OS.has_feature("web")
	add_child(_http)
	_http.request_completed.connect(_on_manifest)
	if web:
		_web_http = HTTPRequest.new()
		_web_http.timeout = 8.0
		_web_http.accept_gzip = false
		add_child(_web_http)
		_web_http.request_completed.connect(_on_web_current)


func _process(delta: float) -> void :
	_poll -= delta
	if _poll <= 0.0:
		_poll = POLL_EVERY
		if _http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:

			_http.request(Updater.MANIFEST_FALLBACK if _web_http != null else Updater._manifest_url())
		if _web_http != null and _web_http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			_web_http.request(WEB_CURRENT)
	if _strip == null and not _queue.is_empty():
		_show(_queue.pop_front())
	elif _strip != null:
		_fit_strip()


func _on_manifest(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var m = JSON.parse_string(body.get_string_from_utf8())
	if not m is Dictionary:
		return
	var now: = Time.get_ticks_msec() * 0.001



	var pm: Dictionary = m
	var sec: = Updater._section()
	if sec != "" and m.get(sec) is Dictionary:
		pm = m[sec]
	var patch = pm.get("patch")

	if _web_http != null:
		patch = null


	var newer: = patch is Dictionary and str(pm.get("base", "")) == Updater._eff_base\
	and Updater._newer(str(patch.get("version", "")), Updater.version)
	var new_build: = _web_http == null and Updater._newer(str(pm.get("base", "")), Updater.version)
	if (newer or new_build) and now - _reminded_at >= REMIND_EVERY:
		_reminded_at = now
		var v: = str(patch.get("version", "")) if newer else str(pm.get("base", ""))
		say(tr("[Aviso] Hay una actualización nueva (v%s). Por favor reinicia el juego para instalarla.") % v)
	var b = m.get("broadcast")
	var bid: = str(b.get("id", "")) if b is Dictionary else ""
	var seen_ids: Array = Save.setting("broadcast_seen", [])
	if b is Dictionary and not _seen.has(bid) and not seen_ids.has(bid):
		_seen[bid] = true
		Save.set_setting("broadcast_seen", (seen_ids + [bid]).slice(-20))
		var lang: = TranslationServer.get_locale().substr(0, 2)
		var text: = str(b.get(lang, b.get("en", b.get("es", ""))))
		if text != "":
			say("[GM] " + text)




func _on_web_current(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var m = JSON.parse_string(body.get_string_from_utf8())
	if not m is Dictionary:
		return
	var now: = Time.get_ticks_msec() * 0.001
	var v: = str(m.get("version", ""))
	if Updater._newer(v, Updater.version) and now - _reminded_at >= REMIND_EVERY:
		_reminded_at = now
		say(tr("[Aviso] Hay una versión nueva del juego (v%s). Recarga la página para jugarla.") % v)



func say(text: String) -> void :
	_queue.append(text)


func _show(text: String) -> void :
	_strip = Control.new()
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strip.clip_contents = true
	add_child(_strip)
	_fit_strip()
	_build_label(text)





func _fit_strip() -> void :
	var view: = get_viewport().get_visible_rect().size
	var left: = 8.0
	var right: = view.x - 8.0
	var hud = get_parent().get("hud") if get_parent() != null else null
	if hud != null and hud.visible:
		var basic: Control = hud.get("_basic")
		if basic != null and basic.is_visible_in_tree():
			left = maxf(left, _screen_rect(basic).end.x + 8.0)

		var mm: Control = hud.get("_time_window")
		if mm != null and mm.is_visible_in_tree():
			right = minf(right, _screen_rect(mm).position.x - 8.0)
	if right - left < 240.0:
		left = 8.0
		right = view.x - 8.0
	_strip.position = Vector2(left, 6)
	_strip.size = Vector2(right - left, 26)


func _build_label(text: String) -> void :
	var bg: = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.45)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strip.add_child(bg)
	_label = Label.new()
	_label.text = text
	_label.add_theme_font_override("font", RO_FONT_BOLD)
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", COLOR)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 4)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strip.add_child(_label)
	var span: = _strip.size.x
	_label.position = Vector2(span, 2)
	var width: = RO_FONT_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	var travel: = span + width + 40.0

	var tw: = _label.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for i in 2:
		tw.tween_callback( func(): _label.position.x = span)
		tw.tween_property(_label, "position:x", - width - 40.0, travel / SPEED)
	tw.tween_callback( func():
		_strip.queue_free()
		_strip = null)



static func _screen_rect(c: Control) -> Rect2:
	var xf: = c.get_global_transform_with_canvas()
	return Rect2(xf.origin, c.size * xf.get_scale())
