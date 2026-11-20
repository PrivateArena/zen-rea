class_name PartyBar
extends CanvasLayer




var world: World
var _box: PanelContainer
var _row: HBoxContainer
var _key: = ""


func setup(p_world: World) -> void :
	world = p_world
	layer = 11
	_box = PanelContainer.new()
	var st: = UiKit.panel_box(Color(0.97, 0.98, 1.0, 0.94), UiKit.GOLD_DIM, 12)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 3
	st.content_margin_bottom = 3
	_box.add_theme_stylebox_override("panel", st)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 10)
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(_row)
	world.net.roster_changed.connect(_rebuild)
	_rebuild()



class Spinner extends Control:
	var _a: = 0.0
	func _init() -> void :
		custom_minimum_size = Vector2(16, 16)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _process(delta: float) -> void :
		_a = fposmod(_a + delta * 6.0, TAU)
		queue_redraw()
	func _draw() -> void :
		var c: = size * 0.5
		draw_arc(c, 6.0, 0.0, TAU, 32, Color(0.55, 0.62, 0.85, 0.25), 2.5, true)
		draw_arc(c, 6.0, _a, _a + 4.0, 24, Color(0.3, 0.45, 0.9), 2.5, true)




func _waiting() -> String:
	var net: NetSync = world.net
	var w: String = world.channel.room_waiting() if world.channel != null else ""
	if w != "":
		return w
	if net.mode == "client" and net.roster.is_empty():
		return "connecting"
	return ""


var _wait_key: = ""

func _process(_delta: float) -> void :
	var net: NetSync = world.net
	var waiting: = _waiting() if not world.running else ""
	var on: = not world.running and ((net.mode != "" and not net.roster.is_empty()) or waiting != "")
	_box.visible = on
	if not on:
		return
	var incoming: int = world.channel.quick_incoming() if world.channel != null and net.is_host() else 0
	var key: = waiting + str(incoming)
	if key != _wait_key:
		_wait_key = key
		_rebuild()
	var view: = get_viewport().get_visible_rect().size
	_box.position = Vector2(roundf((view.x - _box.size.x) * 0.5), 3)


func _rebuild() -> void :

	for c in _row.get_children():
		_row.remove_child(c)
		c.queue_free()
	var net: NetSync = world.net
	var eos = net._eos
	var code: = str(eos.code) if eos != null and str(eos.code) != "" else ""
	var waiting: = _waiting()
	var waited_for: String = world.channel.room_wait_who if world.channel != null else ""
	if waiting in ["opening", "joining", "connecting"] or (waiting != "" and net.roster.is_empty()):

		_row.add_child(Spinner.new())
		var what: String = {"opening": tr("Abriendo la sala..."), "joining": tr("Uniéndote a la party de %s...") % waited_for, 
			"connecting": tr("Conectando con la sala..."), "inviting": tr("Esperando a %s...") % waited_for}.get(waiting, "")
		_row.add_child(UiKit.label(what, 13, UiKit.GOLD, true))
		_box.size = Vector2.ZERO
		_box.reset_size.call_deferred()
		return
	_row.add_child(UiKit.label(tr("Sala %s") % code if code != "" else tr("Sala"), 13, UiKit.GOLD, true))
	var me: = net.my_id()
	for i in net.roster.size():
		var m: Dictionary = net.roster[i]
		_row.add_child(UiKit.label("·", 13, UiKit.MUTED))
		var cls: Dictionary = GameData.CLASSES.get(str(m["class"]), {})
		var who: = tr("Tú") if int(m.id) == me else str(m.name)
		var job: = tr(str(cls.get("name", "")))
		var l: = UiKit.label("%s%s%s" % ["★ " if i == 0 else "", who, "" if who == job else "  " + job], 13, 
			UiKit.TEXT if int(m.id) == me else UiKit.GOLD.darkened(0.2), int(m.id) == me)
		_row.add_child(l)
	_row.add_child(UiKit.label("(%d/4)" % net.roster.size(), 12, UiKit.MUTED))

	var incoming: int = world.channel.quick_incoming() if world.channel != null and net.is_host() else 0
	if incoming > 0 and waiting != "inviting":
		_row.add_child(UiKit.label("·", 13, UiKit.MUTED))
		_row.add_child(Spinner.new())
		_row.add_child(UiKit.label(tr("Entrando %d...") % incoming, 12, UiKit.MUTED))

	if waiting == "inviting":
		_row.add_child(UiKit.label("·", 13, UiKit.MUTED))
		_row.add_child(Spinner.new())
		_row.add_child(UiKit.label(tr("Esperando a %s...") % waited_for, 12, UiKit.MUTED))
	_box.size = Vector2.ZERO
	_box.reset_size.call_deferred()
