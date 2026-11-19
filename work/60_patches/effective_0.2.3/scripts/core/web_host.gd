extends Node










signal hidden_changed(hidden: bool)

var world: Node


var hidden: = false

var persistent: = true
var _on_hide: JavaScriptObject
var _on_show: JavaScriptObject

var packs: Node


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.has_feature("web"):
		return
	packs = load("res://scripts/core/web_packs.gd").new()
	add_child(packs)

	RoMap.web_fetch = func(map_name: String) -> void : packs.mount_now("map:" + map_name)
	persistent = OS.is_userfs_persistent()


	if MouseWalk.touch() and not Save.data.get("settings", {}).has("fx_quality"):
		Save.set_setting("fx_quality", 1)
		Save.set_setting("weather", false)
	apply_quality.call_deferred()


	if MouseWalk.touch():
		add_child(load("res://scripts/core/web_keyboard.gd").new())

	_on_hide = JavaScriptBridge.create_callback(_hide_cb)
	_on_show = JavaScriptBridge.create_callback(_show_cb)
	var win: = JavaScriptBridge.get_interface("window")
	var doc: = JavaScriptBridge.get_interface("document")
	if win == null or doc == null:
		return
	win.__midgard_hide = _on_hide
	win.__midgard_show = _on_show


	JavaScriptBridge.eval("""
		document.addEventListener('visibilitychange', function() {
			if (document.visibilityState === 'hidden') window.__midgard_hide(); else window.__midgard_show();
		});
		window.addEventListener('pagehide', function() { window.__midgard_hide(); });
		if (navigator.storage && navigator.storage.persist) { navigator.storage.persist(); }
	""", true)
	_home_hint.call_deferred()






const HOME_HINT_TIMES: = 5
const HOME_HINT_SECONDS: = 14.0
func _home_hint() -> void :
	var ios: = bool(JavaScriptBridge.eval("(/iPhone|iPad|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)) && !navigator.standalone && !matchMedia('(display-mode: fullscreen)').matches && !matchMedia('(display-mode: standalone)').matches", true))
	var shown: = int(Save.setting("ios_home_hint", 0))
	if not ios or shown >= HOME_HINT_TIMES:
		return
	Save.set_setting("ios_home_hint", shown + 1)

	await get_tree().create_timer(4.0, true, false, true).timeout
	var layer: = CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var box: = PanelContainer.new()
	box.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.06, 0.08, 0.16, 0.94), Color(1.0, 0.82, 0.4), 8, 2))
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(box)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	box.add_child(row)
	var text: = UiKit.label(tr("Pantalla completa: en Safari toca Compartir y luego «Agregar a inicio», y abre el juego desde ese ícono."), 13, Color(1.0, 0.95, 0.85))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size.x = 420
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(text)
	var ok: = UiKit.button(tr("Entendido"))
	ok.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(ok)
	var close: = func():
		if is_instance_valid(layer):
			layer.queue_free()
	ok.pressed.connect( func():

		Save.set_setting("ios_home_hint", HOME_HINT_TIMES)
		close.call())
	box.reset_size()
	box.position = Vector2((box.get_viewport_rect().size.x - box.size.x) * 0.5, 8)
	get_tree().create_timer(HOME_HINT_SECONDS, true, false, true).timeout.connect(close)








const QUALITY_DPR: = [1.5, 2.0, 3.0]
static func fps_default() -> int:
	return 30 if MouseWalk.touch() else 0


func apply_quality() -> void :
	if not OS.has_feature("web"):
		return
	var dpr: float = QUALITY_DPR[World.quality_level()]
	var fps: = int(Save.setting("web_fps", fps_default()))
	JavaScriptBridge.eval("window.__midgardDpr = %s; window.__midgardFps = %d; window.dispatchEvent(new Event('resize'));" % [str(dpr), fps], true)


func _hide_cb(_args: Array) -> void :
	if hidden:
		return
	hidden = true
	keep()
	hidden_changed.emit(true)


func _show_cb(_args: Array) -> void :
	if not hidden:
		return
	hidden = false
	hidden_changed.emit(false)




func keep() -> void :
	if world != null and is_instance_valid(world) and bool(world.get("running")) and not bool(world.get("training")):
		world.call("web_keep_run")
	Save.flush()
	Save.web_rescue_write()
