class_name WorldSelect
extends Control






signal chosen(stage_id: String)
signal cancelled

const MAP_TEX: = "res://assets/ro/ui/worldmap.png"
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const MAP_SIZE: = Vector2(1280, 1024)

var world: World
var region: = ""
var stage_id: = ""
var _scale: = 0.5
var _map_holder: Control
var _pins: = {}
var _side: VBoxContainer
var _side_foot: HBoxContainer
var _t: = 0.0

var _records: VBoxContainer
var class_id: = ""
var _board_key: = ""
var _board_show: = Callable()


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	if stage_id == "" or not GameData.STAGES.has(stage_id):
		stage_id = world.stage_id
	region = GameData.stage_region(stage_id)
	if region == "" or not Save.region_unlocked(region):
		region = "prontera"
		stage_id = str(GameData.REGIONS[region].stages[0])
	_clamp_danger()
	_build()
	grab_focus.call_deferred()


func _process(delta: float) -> void :
	_t += delta

	if _pins.has(region):
		var p: Control = _pins[region]
		p.scale = Vector2.ONE * (1.0 + 0.06 * sin(_t * 4.0))


func _build() -> void :
	for c in get_children():
		c.queue_free()
	_pins.clear()
	var view: = get_viewport_rect().size
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	add_child(row)

	var side_w: = clampf(view.x * 0.34, 240.0, 560.0)
	var outer_margin: = 28.0
	var map_panel: = PanelContainer.new()
	map_panel.add_theme_stylebox_override("panel", UiKit.panel_box(Color(0.12, 0.14, 0.2), UiKit.GOLD_DIM, 10, 2))
	map_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(map_panel)
	_scale = clampf(minf((view.x - side_w - outer_margin - 12.0) / MAP_SIZE.x, (view.y - 90.0) / MAP_SIZE.y), 0.12, 1.0)
	_map_holder = Control.new()
	_map_holder.custom_minimum_size = MAP_SIZE * _scale
	_map_holder.clip_contents = true
	map_panel.add_child(_map_holder)
	var tex: = TextureRect.new()
	tex.texture = load(MAP_TEX) if ResourceLoader.exists(MAP_TEX) else null
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	tex.size = MAP_SIZE * _scale
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_holder.add_child(tex)
	for rid in GameData.REGIONS:
		_map_holder.add_child(_pin(rid))
	_map_holder.add_child(_tower_pin())
	_map_holder.add_child(_city_badge())

	var side_panel: = PanelContainer.new()
	var side_box: = UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 12, 2)
	side_panel.add_theme_stylebox_override("panel", side_box)
	side_panel.custom_minimum_size = Vector2(side_w, MAP_SIZE.y * _scale)
	row.add_child(side_panel)


	var side_col: = VBoxContainer.new()
	side_col.add_theme_constant_override("separation", 8)
	side_panel.add_child(side_col)
	var side_scroll: = ScrollContainer.new()
	side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_scroll.custom_minimum_size = Vector2(0, MAP_SIZE.y * _scale - side_box.content_margin_top - side_box.content_margin_bottom - 4.0 - 44.0)
	side_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_col.add_child(side_scroll)

	_side_foot = HBoxContainer.new()
	_side_foot.add_theme_constant_override("separation", 8)
	_side_foot.custom_minimum_size = Vector2(0, 36)
	side_col.add_child(_side_foot)
	_side = VBoxContainer.new()
	_side.add_theme_constant_override("separation", 8)
	_side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_scroll.add_child(_side)
	_fill_side()

	var row_size: = Vector2(row.get_combined_minimum_size().x, MAP_SIZE.y * _scale + 4.0)
	row.position = ((view - row_size) * 0.5).floor()
	if row_size.x > view.x - outer_margin:
		var fit: = maxf(0.2, (view.x - outer_margin) / maxf(1.0, row_size.x))
		row.scale = Vector2.ONE * fit
		row.position = ((view - row_size * fit) * 0.5).floor()
	var hint: = UiKit.label(tr("Tab: región   ·   ↑/↓: mapa   ·   ←/→: peligro   ·   X: frenesí   ·   R: récords   ·   Enter: elegir   ·   Esc: volver"), 12, Color.WHITE)
	hint.add_theme_constant_override("outline_size", 4)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, view.y - 19)
	hint.size = Vector2(view.x, 20)
	hint.visible = not MouseWalk.touch()
	add_child(hint)




static var _side_tab: = "map"


func _toggle_records() -> void :
	_side_tab = "map" if _side_tab == "records" else "records"
	world.menus.ui_click()
	_fill_side()



func _side_tabs() -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	for t in [["map", tr("Mapa")], ["records", "♛ " + tr("Récords") + ("" if MouseWalk.touch() else "  (R)")]]:
		var key: String = t[0]
		var on: = _side_tab == key
		var b: = Button.new()
		b.text = t[1]
		b.focus_mode = Control.FOCUS_NONE
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_override("font", UiKit.FONT_BODY)
		b.add_theme_font_size_override("font_size", 13)
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(1.0, 0.97, 0.86) if on else Color(0.9, 0.92, 0.98)
		sb.border_color = Color(0.85, 0.6, 0.15) if on else Color(0.75, 0.78, 0.88)
		sb.set_border_width_all(1)
		sb.border_width_bottom = 0 if on else 1
		sb.border_width_top = 3 if on else 1
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		for k in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(k, sb)
		for k in ["font_color", "font_hover_color", "font_pressed_color"]:
			b.add_theme_color_override(k, Color(0.55, 0.35, 0.0) if on else UiKit.MUTED)
		b.pressed.connect( func():
			if _side_tab != key:
				_toggle_records())
		row.add_child(b)
	return row




var _board_class: = ""

var _board_dir: = 0
const JobBoard = preload("res://scripts/ui/job_board.gd")





func _fill_records() -> void :
	if _records == null:
		return
	for c in _records.get_children():
		c.queue_free()




	if _board_class == "" or (_board_class != JobBoard.ALL and GameData.CLASSES.has(_board_class) and not JobBoard.valid(_board_class)):
		_board_class = JobBoard.default_for(_board_class if GameData.CLASSES.has(_board_class) else class_id)
	if not JobBoard.valid(_board_class):
		_board_class = JobBoard.ALL
	var cid: = _board_class
	var dir: = _board_dir
	_board_dir = 0
	_records.add_child(_records_header())
	var pad: = MarginContainer.new()
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, 8)
	pad.add_theme_constant_override("margin_top", 8)
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_records.add_child(pad)
	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	pad.add_child(body)

	if region == TOWER:
		var kind: = HBoxContainer.new()
		kind.add_theme_constant_override("separation", 4)
		body.add_child(kind)

		var kinds: = [[false, tr("Solo")], [true, tr("En grupo")]]
		if Save.hel_open() or _tower_hel_board:
			kinds.append(["hel", tr("Torre de Hel")])
		for k in kinds:
			var hel_k: bool = str(k[0]) == "hel"
			var b: = UiKit.button(str(k[1]), _tower_hel_board if hel_k else ( not _tower_hel_board and _tower_party_board == bool(k[0])))
			b.focus_mode = Control.FOCUS_NONE
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var party: bool = false if hel_k else bool(k[0])
			b.pressed.connect( func():
				if _tower_party_board != party or _tower_hel_board != hel_k:
					_tower_party_board = party
					_tower_hel_board = hel_k
					world.menus.ui_click()
					_fill_records())
			kind.add_child(b)

	body.add_child(JobBoard.selector(cid, func(step: int): _switch_class(JobBoard.keys(), step), _open_job_picker, dir, false))

	var champ: = JobBoard.champ_strip(world, cid)
	if champ != null:
		body.add_child(champ)

	var mine_box: = VBoxContainer.new()
	body.add_child(mine_box)
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL





	scroll.custom_minimum_size.y = RECORDS_LIST_MIN_H
	body.add_child(scroll)
	var list: = VBoxContainer.new()
	list.add_theme_constant_override("separation", 4)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var foot: = VBoxContainer.new()
	foot.add_theme_constant_override("separation", 3)
	body.add_child(foot)


	var fresh: = [true]
	var last: = [null]
	var show: = func(d: Dictionary):
		if not is_instance_valid(list):
			return

		if last[0] is Dictionary and not d.is_empty() and d.hash() == (last[0] as Dictionary).hash():
			return
		last[0] = d
		for c in list.get_children():
			c.queue_free()
		for c in foot.get_children():
			c.queue_free()
		if is_instance_valid(mine_box):
			for c in mine_box.get_children():
				c.queue_free()


			if not d.is_empty() and not (MouseWalk.touch() and not (d.get("me") is Dictionary)):
				mine_box.add_child(_my_standing(d))
		if d.is_empty():
			list.add_child(_records_note("⚠", tr("Sin conexión: los récords no se pueden ver ahora.")))
			return
		var top: Array = d.get("top", [])
		if top.is_empty():
			list.add_child(_records_note("★", tr("Nadie todavía este mes con este oficio. ¡Sé el primero!") if cid != JobBoard.ALL else tr("Nadie todavía este mes. ¡Sé el primero!")))
		var rows: Array = []
		var mine_row: Control = null
		for r in top:
			var row: = _record_row(r)
			list.add_child(row)
			rows.append(row)
			if bool(r.get("me", false)):
				mine_row = row
		var me = d.get("me")
		if me is Dictionary and not top.any( func(r): return bool(r.get("me", false))):
			var you: = UiKit.label(tr("Tu mejor marca"), 10, UiKit.MUTED, true)
			foot.add_child(you)
			var mine: = (me as Dictionary).duplicate()
			var mcls: = str(mine.get("class", JobBoard.class_of(cid)))
			mine["name"] = Save.char_name(mcls if GameData.CLASSES.has(mcls) else class_id)
			mine["tag"] = Leaderboard.tag()
			mine["me"] = true
			var row: = _record_row(mine)
			foot.add_child(row)
			rows.append(row)
			mine_row = row
		var left: = UiKit.label(tr_n("%d jugador", "%d jugadores", int(d.get("total", 0))) % int(d.get("total", 0)), 10, UiKit.MUTED)
		left.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		foot.add_child(left)
		if _records_days != null and is_instance_valid(_records_days):
			_records_days.text = tr_n("Se reinicia en %d día", "Se reinicia en %d días", int(d.get("days_left", 0))) % int(d.get("days_left", 0))
		if fresh[0]:
			fresh[0] = false
			JobBoard.reveal(rows, dir)

			if mine_row != null:
				JobBoard.spotlight(mine_row, scroll if mine_row.get_parent() == list else null, mine_row.get_meta("sb", null))
	var bs: = _board_stage()
	var c0: = world.board.cached(cid, bs)
	if not c0.is_empty():
		show.call(c0)
	else:
		list.add_child(_records_loading())
	_board_key = cid + "|" + bs
	_board_show = show
	if not world.board.board_ready.is_connected(_on_board):
		world.board.board_ready.connect(_on_board)
	world.board.fetch(cid, bs)


var _records_days: Label




func _records_header() -> Control:
	var band: = PanelContainer.new()
	var g: = Gradient.new()
	g.set_color(0, Color(0.98, 0.98, 1.0))
	g.set_color(1, Color(0.82, 0.87, 0.97))
	var gt: = GradientTexture2D.new()
	gt.gradient = g
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 48
	var st: = StyleBoxTexture.new()
	st.texture = gt
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 8
	st.content_margin_bottom = 8
	band.add_theme_stylebox_override("panel", st)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	band.add_child(col)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	col.add_child(row)
	var cup: = UiKit.label("♛", 18, Color(1.0, 0.85, 0.35), true)
	cup.add_theme_color_override("font_outline_color", Color(0.25, 0.15, 0.0))
	cup.add_theme_constant_override("outline_size", 4)
	row.add_child(cup)
	var t: = UiKit.label(tr("Récords · %s") % (tr("Endless Tower") if region == TOWER else tr(str(GameData.STAGES[stage_id].name))), 
		15, Color(0.14, 0.2, 0.45), true)
	t.clip_text = true
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(t)


	var how: = Label.new()
	if region != TOWER:
		var q: = UiKit.button("?")
		q.custom_minimum_size = Vector2(24, 22)
		q.focus_mode = Control.FOCUS_NONE
		q.tooltip_text = rank_help()
		row.add_child(q)
		how.text = rank_help()
		how.visible = false
		how.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		how.add_theme_font_size_override("font_size", 10)
		how.add_theme_color_override("font_color", Color(0.25, 0.3, 0.5))
		q.pressed.connect( func():
			world.menus.ui_click()
			how.visible = not how.visible)
	var months: = [tr("enero"), tr("febrero"), tr("marzo"), tr("abril"), tr("mayo"), tr("junio"), tr("julio"), 
		tr("agosto"), tr("septiembre"), tr("octubre"), tr("noviembre"), tr("diciembre")]
	var now: = Time.get_datetime_dict_from_system(true)
	var sub: = HBoxContainer.new()
	col.add_child(sub)
	var m: = UiKit.label(("%s %d" % [months[int(now.month) - 1], int(now.year)]).capitalize(), 11, Color(0.35, 0.4, 0.6), true)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub.add_child(m)
	_records_days = UiKit.label("", 10, Color(0.4, 0.45, 0.62))
	sub.add_child(_records_days)
	if how.text != "":
		col.add_child(how)
	else:
		how.free()
	return band




static func rank_help() -> String:
	return TranslationServer.translate("Cómo se ordena el ranking:\n1. Arriba, las partidas de Infinito que vencieron a Morroc a los 40:00: primero por peligro + Juramento (Infierno 15 = peligro 30), después por el Morroc más alto vencido (I, II, III...) y después por puntos.\n2. Debajo, las demás partidas, por puntos.\n\nPuntos = (segundos + zeny / 20 + MVPs x 600) x (1 + 0,25 x (peligro + Juramento - 1)), x1,15 en Frenesí.\nEl Juramento solo cuenta en Infierno 15.")




func _my_standing(d: Dictionary) -> Control:
	var me = d.get("me")
	var total: = int(d.get("total", 0))
	var box: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.95, 0.78)
	sb.border_color = Color(0.88, 0.62, 0.12)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	box.add_theme_stylebox_override("panel", sb)
	var text: = ""
	if not (me is Dictionary):
		text = tr("Aún no estás en este ranking: supera un piso de la torre para entrar.") if region == TOWER\
		else tr("Aún no estás en este ranking: termina una partida aquí para entrar.")

		if not JobBoard.path_of(_board_class).is_empty():
			text = tr("Aún no estás en este ranking: sube la torre como %s para entrar.") % JobBoard.name_of(_board_class) if region == TOWER\
			else tr("Aún no estás en este ranking: termina una partida aquí como %s para entrar.") % JobBoard.name_of(_board_class)
	else:
		var rank: = int(me.get("rank", 0))
		var score: = int(me.get("score", 0))
		if rank <= 1:
			text = tr("Tú: #1 de %d  ·  ¡vas primero!") % total
		else:
			text = tr("Tú: #%d de %d") % [rank, total]
			for r in d.get("top", []):
				if int(r.get("rank", 0)) == rank - 1:
					if region == TOWER:

						var floors: = int(r.get("mvps", 0)) - int(me.get("mvps", 0))
						text += "  ·  " + (tr_n("te falta %d piso para el #%d", "te faltan %d pisos para el #%d", floors) % [floors, rank - 1]
							if floors > 0 else tr("mismo piso que el #%d: sube más rápido") % (rank - 1))
					else:

						var up: = Leaderboard.rank_parts(int(r.get("score", 0)))
						var mine: = Leaderboard.rank_parts(score)
						if up.tier == mine.tier and up.morroc == mine.morroc:
							text += "  ·  " + tr("te faltan %s pts para el #%d") % [RoBasicWindow._thousands(int(up.points) - int(mine.points) + 1), rank - 1]
						elif int(mine.morroc) == 0:
							text += "  ·  " + tr("vence el final de Infinito para el #%d") % (rank - 1)
						elif int(up.tier) > int(mine.tier):
							text += "  ·  " + tr("más peligro o Juramento para el #%d") % (rank - 1)
						else:
							text += "  ·  " + tr("vence a Morroc %s para el #%d") % [MorrocEvent.roman(int(up.morroc)), rank - 1]
					break
	var l: = UiKit.label(text, 12, Color(0.5, 0.3, 0.0), true)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(l)
	return box



func _on_ranks(d: Dictionary) -> void :
	if is_inside_tree() and d != _ranks_shown:
		_ranks_shown = d
		_fill_side.call_deferred()


var _ranks_shown: = {}
const TouchScroll: = preload("res://scripts/ui/touch_scroll.gd")

const RECORDS_LIST_MIN_H: = 150.0


func _arrow_button(text: String, fn: Callable) -> Button:
	var b: = UiKit.button(text)
	b.custom_minimum_size = Vector2(28, 26)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 16)
	b.pressed.connect(fn)
	return b


func _switch_class(keys: Array, step: int) -> void :
	_board_class = str(keys[posmod(keys.find(_board_class) + step, keys.size())])
	_board_dir = signi(step)
	world.menus.ui_click()
	_fill_records()



func _open_job_picker() -> void :
	if _records == null or find_child("JobPicker", false, false) != null:
		return
	world.menus.ui_click()
	JobBoard.picker(self, _board_class, func(key: String):
		if key != _board_class:
			var ks: = JobBoard.keys()
			_board_dir = 1 if ks.find(key) > ks.find(_board_class) else -1
			_board_class = key
			_fill_records()
		grab_focus.call_deferred(), world.menus.ui_click)



func _records_loading() -> Control:
	var box: = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	box.custom_minimum_size = Vector2(0, 150)
	var center: = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(center)
	var stage: = Control.new()
	stage.custom_minimum_size = Vector2(96, 80)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(stage)
	var poring: = TextureRect.new()
	poring.texture_filter = RoAssets.ui_filter()
	poring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	poring.scale = Vector2(2, 2)
	stage.add_child(poring)
	var ro: = RoAssets.sprite(["poring"])
	var walk: = RoVisual.MOB_WALK * RoSprite.DIRS
	var label: = UiKit.label(tr("Cargando récords..."), 13, UiKit.MUTED, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	if ro != null:
		var t0: = Time.get_ticks_msec()
		var step: = func():
			if not is_instance_valid(poring):
				return
			var t: = (Time.get_ticks_msec() - t0) / 1000.0
			poring.texture = ro.get_frame(walk, int(t / 0.09) % maxi(1, ro.frame_count(walk)))
			var hop: = absf(sin(t * 5.0)) * 14.0
			poring.position = Vector2(48.0 - ro.origin.x * 2.0, 76.0 - ro.origin.y * 2.0 - hop)
			label.modulate.a = 0.55 + 0.45 * absf(sin(t * 2.0))
		var timer: = Timer.new()
		timer.wait_time = 0.03
		timer.autostart = true
		timer.process_mode = Node.PROCESS_MODE_ALWAYS
		timer.timeout.connect(step)
		box.add_child(timer)
		step.call_deferred()
	return box


func _records_note(icon: String, text: String) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(UiKit.label(icon, 14, UiKit.GOLD, true))
	var l: = UiKit.label(text, 12, UiKit.MUTED)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	return row



func _on_board(key: String, d: Dictionary) -> void :
	if key == _board_key and _board_show.is_valid():
		_board_show.call(d)


const MEDALS: = [Color(0.95, 0.72, 0.15), Color(0.68, 0.72, 0.8), Color(0.78, 0.5, 0.28)]






func _record_day(at: int) -> String:
	var bias: = int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var days: = floori((Time.get_unix_time_from_system() + bias) / 86400.0) - floori((at + bias) / 86400.0)
	if days <= 0:
		return tr("Hoy")
	if days == 1:
		return tr("Ayer")
	return tr("Hace %d días") % days



func _record_date(at: int) -> String:
	var bias: = int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	return Time.get_datetime_string_from_unix_time(at + bias, true).substr(0, 16)


func _record_row(r: Dictionary) -> Control:
	var rank: = int(r.get("rank", 0))
	var mine: = bool(r.get("me", false))
	var box: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()

	var podium: = [Color(1.0, 0.965, 0.84), Color(0.95, 0.96, 0.985), Color(0.995, 0.95, 0.91)]
	sb.bg_color = Color(1.0, 0.95, 0.78) if mine else (podium[rank - 1] if rank >= 1 and rank <= 3 else Color(0.96, 0.97, 1.0))
	sb.border_color = Color(0.88, 0.62, 0.12) if mine else (Color(MEDALS[rank - 1], 0.8) if rank >= 1 and rank <= 3 else Color(0.84, 0.86, 0.93))
	sb.set_border_width_all(2 if mine else 1)
	sb.border_width_left = 4 if rank >= 1 and rank <= 3 else sb.border_width_left
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 6
	sb.content_margin_right = 7
	sb.content_margin_top = 3
	sb.content_margin_bottom = 4
	if rank == 1:
		sb.shadow_color = Color(MEDALS[0], 0.35)
		sb.shadow_size = 3
	box.add_theme_stylebox_override("panel", sb)
	box.set_meta("sb", sb)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	box.add_child(row)

	var badge: = PanelContainer.new()
	var bb: = StyleBoxFlat.new()
	bb.bg_color = MEDALS[rank - 1] if rank >= 1 and rank <= 3 else Color(0.86, 0.88, 0.94)
	bb.set_corner_radius_all(11)
	bb.border_color = bb.bg_color.darkened(0.35)
	bb.set_border_width_all(1)
	badge.add_theme_stylebox_override("panel", bb)
	badge.custom_minimum_size = Vector2(22, 22)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var n: = UiKit.label("%d" % rank, 11, Color.WHITE if rank <= 3 else UiKit.TEXT, true)
	if rank <= 3:
		n.add_theme_color_override("font_outline_color", bb.border_color)
		n.add_theme_constant_override("outline_size", 3)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(n)
	row.add_child(badge)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", -2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 4)
	col.add_child(top)
	var sup: = str(r.get("sup", ""))
	var who: = UiKit.label(str(r.get("name", "")), 12, world.titles.support_color(sup, false) if sup != "" and world != null and world.titles != null else UiKit.TEXT, true)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	who.custom_minimum_size.x = minf(ceilf(who.get_theme_font("font").get_string_size(who.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x) + 2.0, 96.0)
	UiKit.fit_dots(who)

	if sup != "" and world != null and world.titles != null and r.get("sup_i", true) != false:
		top.add_child(world.titles.support_badge(sup, 20.0))

	if rank == 1:
		var crown: = UiKit.label("♛", 13, MEDALS[0], true)
		crown.add_theme_color_override("font_outline_color", Color(0.45, 0.28, 0.0))
		crown.add_theme_constant_override("outline_size", 3)
		top.add_child(crown)
	top.add_child(who)
	top.add_child(UiKit.label(str(r.get("tag", "")), 9, UiKit.MUTED))


	var cls: = str(r.get("class", ""))
	var champ: = JobBoard.champ_of(Leaderboard.board_of(cls, str(r.get("job", ""))))
	var shown_title: = champ if bool(r.get("champ", false)) and champ != "" else str(r.get("title", ""))

	if GameData.TITLES.has(shown_title) and world != null and world.titles != null:

		var tgap: = MarginContainer.new()
		tgap.add_theme_constant_override("margin_left", 6)
		tgap.add_theme_constant_override("margin_right", 12)
		tgap.add_theme_constant_override("margin_top", 2)
		tgap.add_theme_constant_override("margin_bottom", 2)
		tgap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tgap.add_child(world.titles.chip(shown_title, 9))
		top.add_child(tgap)
	var tower: = region == TOWER

	var parts: = Leaderboard.rank_parts(int(r.get("score", 0)))
	if not tower and int(parts.morroc) > 0:
		var fin: = UiKit.tag("Morroc %s" % MorrocEvent.roman(int(parts.morroc)), GameData.MORROC_FINALE.color, 9)
		fin.tooltip_text = tr("Venció el final de Infinito: arriba de las partidas que no lo vencieron")
		fin.mouse_filter = Control.MOUSE_FILTER_PASS
		top.add_child(fin)
	var pts: = UiKit.label(tr("Piso %d") % int(r.get("mvps", 0)) if tower else RoBasicWindow._thousands(int(parts.points)), 
		13, Color(0.45, 0.25, 0.8) if tower else Color(0.62, 0.38, 0.0), true)
	top.add_child(pts)
	var bits: Array[String] = []

	if GameData.CLASSES.has(cls) and _board_class == JobBoard.ALL:
		var jk: = str(r.get("job", ""))
		bits.append(JobBoard.name_of(jk) if JobBoard.valid(jk) else tr(str(GameData.CLASSES[cls].name)))
	var z: = int(r.get("zeny", 0))

	bits.append(tr("Tiempo %s") % UiKit.time_text(float(r.get("time", 0))))


	var at: = int(r.get("at", 0))
	if at > 0:
		bits.append(_record_day(at))
	if not tower:
		bits.append("%s z" % RoBasicWindow._thousands(z))
		bits.append(GameData.danger_name(int(r.get("danger", 1))))

		if int(r.get("oath", 0)) > 0:
			bits.append(tr("Juramento %d") % int(r.get("oath", 0)))
		bits.append(tr_n("%d MVP", "%d MVPs", int(r.get("mvps", 0))) % int(r.get("mvps", 0)))
	if bool(r.get("frenzy", false)):
		bits.append(tr("Frenesí"))
	var stats: = UiKit.label(" · ".join(bits), 10, UiKit.MUTED)
	stats.clip_text = true
	col.add_child(stats)
	box.tooltip_text = (tr("%s %s\nPiso %d · Tiempo %s") % [str(r.get("name", "")), str(r.get("tag", "")), int(r.get("mvps", 0)), 
		UiKit.time_text(float(r.get("time", 0)))] if tower else tr("%s %s\nTiempo %s · Zeny %s · Peligro %d · MVPs %d\n%s puntos") % [str(r.get("name", "")), str(r.get("tag", "")), 
		UiKit.time_text(float(r.get("time", 0))), RoBasicWindow._thousands(int(r.get("zeny", 0))), int(r.get("danger", 1)), 
		int(r.get("mvps", 0)), RoBasicWindow._thousands(int(parts.points))]) + ("""
""" + _record_date(at) if at > 0 else "") + "\r\n"\
		+ tr("Clic: ver su personaje")

	box.mouse_filter = Control.MOUSE_FILTER_STOP
	box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var rec: = r

	var touch: = MouseWalk.touch()
	box.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed != touch and not (touch and TouchScroll.dragged):
			_show_look(rec))
	return box




func _show_look(r: Dictionary) -> void :
	world.menus.ui_click()
	var cls: = str(r.get("class", JobBoard.class_of(_board_class)))
	if not GameData.CLASSES.has(cls):
		cls = GameData.CLASSES.keys()[0]
	var look = r.get("look")
	if not (look is Dictionary) and bool(r.get("me", false)):
		look = null
	var layer: = Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var dim: = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.08, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dim)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(center)
	var win: = UiStyles.ro_window("%s  %s" % [str(r.get("name", "")), str(r.get("tag", ""))], RO_FONT_BOLD)
	win.root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(win.root)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win.body.add_child(col)
	var l: = look as Dictionary if look is Dictionary else {}

	if l.has("ach"):
		var ach: = HBoxContainer.new()
		ach.alignment = BoxContainer.ALIGNMENT_CENTER
		ach.add_theme_constant_override("separation", 6)
		ach.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var trophy_path: = "res://assets/ro/ui/skin/achievement/upper_trophy.png"
		if ResourceLoader.exists(trophy_path):
			var ti: = UiKit.icon_rect(load(trophy_path), 22)
			ti.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			ach.add_child(ti)
		var pct: = clampi(int(l.get("ach", 0)), 0, 100)
		var al: = UiKit.label(tr("Logros  %d%%") % pct, 13, Color(0.55, 0.32, 0.0), true)
		al.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ach.add_child(al)
		col.add_child(ach)
	var hero: = RecordLook.new(look, cls)
	hero.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(hero)
	var rjob: = str(r.get("job", _board_class if JobBoard.class_of(_board_class) == cls and not GameData.CLASSES.has(_board_class) else ""))
	var who: = UiKit.label((JobBoard.name_of(rjob) if JobBoard.valid(rjob) and rjob != JobBoard.ALL else tr(str(GameData.CLASSES[cls].name))) + ("  ·  " + tr("Renacido") if bool(l.get("a", false)) else ""), 12, UiKit.TEXT, true)
	who.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(who)
	var z: = int(r.get("zeny", 0))
	var line: = tr("#%d  ·  Piso %d  ·  %s") % [int(r.get("rank", 0)), int(r.get("mvps", 0)), UiKit.time_text(float(r.get("time", 0)))]\
	+ (("  ·  " + tr("Juramento %d") % int(r.get("danger", 0))) if _tower_hel_board and int(r.get("danger", 0)) > 0 else "")\
	if region == TOWER else tr("#%d  ·  %s pts  ·  %s  ·  %s z  ·  %s  ·  %d MVP") % [int(r.get("rank", 0)), RoBasicWindow._thousands(int(Leaderboard.rank_parts(int(r.get("score", 0))).points)), 
		UiKit.time_text(float(r.get("time", 0))), RoBasicWindow._thousands(z), GameData.danger_name(int(r.get("danger", 1))), int(r.get("mvps", 0))]
	var stats: = UiKit.label(line, 10, UiKit.MUTED)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(stats)
	if not (look is Dictionary):
		var old: = UiKit.label(tr("Récord anterior a los aspectos: se ve su clase inicial."), 9, UiKit.MUTED)
		old.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(old)
	var hint: = UiKit.label(tr("Clic para cerrar"), 9, UiKit.MUTED)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(hint)
	layer.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			layer.accept_event()
			layer.queue_free())





func _pin(rid: String) -> Control:
	var r: Dictionary = GameData.REGIONS[rid]
	var open: = Save.region_unlocked(rid)
	var stages: Array = r.stages
	var cleared: = stages.filter( func(s): return Save.is_stage_cleared(s)).size()
	var unexplored: = stages.filter( func(s): return not Save.entered(s)).size()
	var sel: = rid == region
	var root: = Control.new()
	root.position = (r.pos as Vector2) * _scale

	var pin_k: = clampf(_scale / 0.5, 0.72, 1.0)
	root.scale = Vector2(pin_k, pin_k)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dot: = Panel.new()
	var db: = StyleBoxFlat.new()
	db.bg_color = Color(0.95, 0.68, 0.18) if sel else (Color(0.98, 0.95, 0.85) if open else Color(0.35, 0.36, 0.4))
	db.border_color = Color(0.25, 0.15, 0.05)
	db.set_border_width_all(2)
	db.set_corner_radius_all(6)
	dot.add_theme_stylebox_override("panel", db)
	dot.size = Vector2(12, 12)
	dot.position = Vector2(-6, -6)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dot)
	var plate: = Button.new()
	plate.focus_mode = Control.FOCUS_NONE
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.95, 0.78, 0.97) if sel else (Color(0.99, 0.98, 0.94, 0.93) if open else Color(0.22, 0.23, 0.27, 0.85))
	box.border_color = Color(0.85, 0.58, 0.12) if sel else (Color(0.45, 0.35, 0.2) if open else Color(0.12, 0.12, 0.15))
	box.set_border_width_all(2 if sel else 1)
	box.set_corner_radius_all(6)
	box.content_margin_left = 6
	box.content_margin_right = 6
	box.content_margin_top = 1
	box.content_margin_bottom = 1
	for k in ["normal", "hover", "pressed", "focus"]:
		plate.add_theme_stylebox_override(k, box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", -3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(col)
	var name_l: = UiKit.label(tr(str(r.name)) if open else "???", 12, Color(0.25, 0.15, 0.05) if open else Color(0.75, 0.76, 0.8), true)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name_l)
	var info: = tr("Bloqueada")
	var info_col: = Color(0.7, 0.72, 0.76)
	if open:
		info = "MVP %d/%d" % [cleared, stages.size()]
		info_col = Color(0.45, 0.35, 0.2)
		if rid == world.newly_unlocked:
			info = tr("¡Desbloqueada!")
			info_col = Color(0.85, 0.45, 0.05)
		elif unexplored > 0:
			info = tr("¡%d sin explorar!") % unexplored
			info_col = Color(0.55, 0.3, 0.85)
		elif cleared == stages.size():
			info = "★ MVP %d/%d" % [cleared, stages.size()]
			info_col = Color(0.75, 0.5, 0.05)
	var il: = UiKit.label(info, 9, info_col, open and info_col != Color(0.45, 0.35, 0.2))
	il.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(il)


	var size: = Vector2(maxf(col.get_combined_minimum_size().x + 14.0, 70.0), 34.0)
	plate.custom_minimum_size = size
	plate.size = size
	col.position = Vector2(6, 2)
	col.size = size - Vector2(12, 2)
	var off: = Vector2.ZERO
	match str(r.get("side", "up")):
		"up":
			off = Vector2( - size.x * 0.5, - size.y - 12.0)
		"down":
			off = Vector2( - size.x * 0.5, 12.0)
		"left":
			off = Vector2( - size.x - 12.0, - size.y * 0.5)
		"right":
			off = Vector2(12.0, - size.y * 0.5)
	plate.position = off
	plate.pivot_offset = - off
	root.add_child(plate)
	if not open:
		plate.modulate = Color(1, 1, 1, 0.8)
	plate.pressed.connect( func():
		if Save.region_unlocked(rid):
			_select_region(rid)
		else:
			world.menus.ui_click())
	plate.tooltip_text = _region_tip(rid)



	if open and stages.has(GameData.featured_stage()):
		box.border_color = Color(0.95, 0.65, 0.1)
		box.set_border_width_all(2)
		var badge: = PanelContainer.new()
		var bb: = StyleBoxFlat.new()
		bb.bg_color = Color(1.0, 0.78, 0.2)
		bb.border_color = Color(0.6, 0.35, 0.0)
		bb.set_border_width_all(1)
		bb.set_corner_radius_all(8)
		bb.content_margin_left = 5
		bb.content_margin_right = 5
		bb.anti_aliasing = true
		badge.add_theme_stylebox_override("panel", bb)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bl: = UiKit.label("★ +%d%%" % roundi(GameData.FEATURED_BONUS * 100.0), 10, Color(0.35, 0.18, 0.0), true)
		bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.add_child(bl)
		plate.add_child(badge)
		var bw: = badge.get_combined_minimum_size()
		badge.position = Vector2(size.x - bw.x + 6.0, - bw.y + 6.0)
		var bob: = badge.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		bob.tween_property(badge, "position:y", badge.position.y - 2.0, 0.6)
		bob.tween_property(badge, "position:y", badge.position.y, 0.6)
		plate.tooltip_text += "\n" + tr("Mapa del día: +%d%% de recompensas") % roundi(GameData.FEATURED_BONUS * 100.0)
	_pins[rid] = plate
	return root






func _tower_pin() -> Control:
	var open: = Save.tower_open()
	var ready: = not open and Save.tower_ready()
	var root: = Control.new()
	root.position = GameData.TOWER_PIN * _scale
	root.scale = Vector2.ONE * clampf(_scale / 0.5, 0.72, 1.0)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dot: = Panel.new()
	var db: = StyleBoxFlat.new()
	db.bg_color = Color(0.62, 0.5, 1.0) if open or ready else Color(0.35, 0.36, 0.4)
	db.border_color = Color(0.15, 0.08, 0.3)
	db.set_border_width_all(2)
	db.set_corner_radius_all(6)
	dot.add_theme_stylebox_override("panel", db)
	dot.size = Vector2(12, 12)
	dot.position = Vector2(-6, -6)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(dot)
	var plate: = Button.new()
	plate.focus_mode = Control.FOCUS_NONE
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.2, 0.13, 0.36, 0.95) if open or ready else Color(0.22, 0.23, 0.27, 0.85)
	box.border_color = (Color(1.0, 0.8, 0.3) if ready else Color(0.72, 0.6, 1.0)) if open or ready else Color(0.12, 0.12, 0.15)
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	box.content_margin_left = 6
	box.content_margin_right = 6
	for k in ["normal", "hover", "pressed", "focus"]:
		plate.add_theme_stylebox_override(k, box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", -3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(col)
	var name_l: = UiKit.label(tr("Endless Tower"), 12, Color(0.95, 0.9, 1.0) if open or ready else Color(0.75, 0.76, 0.8), true)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(name_l)
	var top: = Save.tower_top()
	var info: = tr("Piso más alto: %d") % top if top > 0 else tr("¡Sin explorar!")
	var info_col: = Color(0.8, 0.72, 1.0)
	if ready:
		info = tr("¡Desbloquear!")
		info_col = Color(1.0, 0.82, 0.3)
	elif not open:
		info = tr("Bloqueada")
		info_col = Color(0.7, 0.72, 0.76)
	var il: = UiKit.label(info, 9, info_col, ready)
	il.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(il)
	var size: = Vector2(maxf(col.get_combined_minimum_size().x + 14.0, 90.0), 34.0)
	plate.custom_minimum_size = size
	plate.size = size
	col.position = Vector2(6, 2)
	col.size = size - Vector2(12, 2)


	var px: = - size.x * 0.5
	var edge: = MAP_SIZE.x * _scale - 4.0
	var right: = root.position.x + (px + size.x) * root.scale.x
	if right > edge:
		px -= (right - edge) / root.scale.x
	px = maxf(px, (4.0 - root.position.x) / root.scale.x)
	plate.position = Vector2(px, 12.0)
	root.add_child(plate)
	plate.set_meta("tower_pin", true)
	plate.tooltip_text = tr("La torre sin fin: sube con una build guardada") if open else (
		tr("¡Objetivo cumplido! Haz clic para abrir la Endless Tower") if ready else
		tr("Bloqueada: vence a un MVP en %s para abrirla") % GameData.danger_name(GameData.TOWER_UNLOCK_DANGER - 1))
	if not open:
		plate.modulate = Color(1, 1, 1, 1.0 if ready else 0.8)
		plate.pressed.connect( func():
			if not ready:

				_select_region(TOWER)
				return
			_open_tower(root))
		if ready:
			var glow: = plate.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
			glow.tween_property(plate, "modulate", Color(1.35, 1.2, 0.85), 0.5)
			glow.tween_property(plate, "modulate", Color.WHITE, 0.5)
		return root
	plate.pressed.connect( func(): _select_region(TOWER))

	_pins[TOWER] = plate
	plate.pivot_offset = plate.size * 0.5
	if region != TOWER:
		var tw: = plate.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		tw.tween_property(plate, "modulate", Color(1.15, 1.05, 1.3), 0.9)
		tw.tween_property(plate, "modulate", Color.WHITE, 0.9)
	return root




const TOWER: = "tower"



func _go_tower() -> void :

	if not Save.tower_open():
		return
	var cid: = class_id if GameData.CLASSES.has(class_id) else (RoCharSelect.last_id if GameData.CLASSES.has(RoCharSelect.last_id) else "swordsman")
	world.menus.ui_click()

	world.menus.show_loading(world.enter_town.bind(cid, "tower_gate"), [str(GameData.TOWER_GATE.map)])



func _board_stage() -> String:
	if region == TOWER:
		if _tower_hel_board:
			return GameData.HEL_TOWER_STAGE
		return Leaderboard.TOWER_PARTY_STAGE if _tower_party_board else Leaderboard.TOWER_STAGE
	return stage_id



static var _tower_party_board: = false

static var _tower_hel_board: = false







func _rank_tag(rk: int, total: int, medal: Color) -> PanelContainer:
	var t: = UiKit.tag("♛ #%d/%d" % [rk, total], medal.darkened(0.1))
	t.mouse_filter = Control.MOUSE_FILTER_PASS
	t.tooltip_text = tr("Tu puesto de este mes. Se actualiza cada minuto: un récord nuevo puede tardar hasta un minuto en aparecer aquí.")
	return t


func _fill_tower_side() -> void :
	for c in _side.get_children():
		c.queue_free()
	var top: = Save.tower_top()
	var head: = HBoxContainer.new()
	_side.add_child(head)
	var t: = UiKit.label(tr("Endless Tower"), 22, UiKit.TEXT, true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var mr = world.board.ranks.get(_board_stage())
	if mr is Dictionary:
		var rk: = int(mr.get("rank", 0))
		var medal: Color = MEDALS[rk - 1] if rk >= 1 and rk <= 3 else Color(0.45, 0.5, 0.7)
		head.add_child(_rank_tag(rk, int(mr.get("total", 0)), medal))
	head.add_child(UiKit.tag(tr("Piso más alto: %d") % top, Color(0.5, 0.35, 0.85)))
	_side.add_child(_tower_card(top))


	if not Save.tower_open() or (top == 0 and Save.tower_builds().is_empty()):
		_side.add_child(_tower_steps())
	_side.add_child(_side_tabs())
	if _side_tab == "records":
		var rec: = PanelContainer.new()
		var rbox: = UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 8, 1)
		rbox.set_content_margin_all(0)
		rbox.content_margin_bottom = 6
		rec.add_theme_stylebox_override("panel", rbox)
		rec.clip_contents = true
		rec.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_side.add_child(rec)
		_records = VBoxContainer.new()
		_records.add_theme_constant_override("separation", 0)
		rec.add_child(_records)
		_fill_records()
	else:
		_records = null
		_side.add_child(_tower_stretches(top))
		_side.add_child(_tower_facts())
	for c in _side_foot.get_children():
		c.queue_free()
	var back: = UiKit.button(tr("Volver"))
	back.pressed.connect( func(): cancelled.emit())
	_side_foot.add_child(back)


	var client: bool = world.net.is_client()
	var s: = World.tower_speed()
	var fz: = UiKit.button(tr("Frenesí") + "        ", s > 1 and not client)
	RoServerSelect.frenzy_pips(fz, 1 if client else s)
	fz.disabled = client
	fz.tooltip_text = tr("En grupo decide el líder.") if client else tr("Frenesí en la torre: la subida va x%s (púlsalo otra vez: x2). Se detiene en los pisos de evento, los MVP y la pelea final. Solo ahorra tiempo.") % str(GameData.FRENZY_SPEED)
	fz.pressed.connect( func():
		world.set_tower_speed(RoServerSelect.next_speed(World.tower_speed()))
		world.menus.ui_click()
		_fill_side())
	_side_foot.add_child(fz)
	var gap: = Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_side_foot.add_child(gap)
	var go: = UiKit.button(tr("Ir a la torre  ▶"), true)
	go.custom_minimum_size.x = 170
	go.pressed.connect(_go_tower)
	if not Save.tower_open():
		go.disabled = true
		go.tooltip_text = tr("Bloqueada: vence a un MVP en %s para abrirla") % GameData.danger_name(GameData.TOWER_UNLOCK_DANGER - 1)
	_side_foot.add_child(go)




func _tower_steps() -> Control:
	var box: = PanelContainer.new()
	var sb: = UiKit.panel_box(Color(1.0, 0.97, 0.88), Color(0.85, 0.65, 0.25), 8, 2)
	sb.set_content_margin_all(8)

	sb.shadow_size = 0
	box.add_theme_stylebox_override("panel", sb)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	box.add_child(col)
	col.add_child(UiKit.label(tr("Cómo entrar a la torre"), 14, Color(0.6, 0.38, 0.05), true))
	var unlocked: = Save.tower_open() or Save.tower_ready()
	var builds: = Save.tower_builds().size()
	var steps: = [
		[unlocked, tr("Vence al MVP de %s") % GameData.danger_name(GameData.TOWER_UNLOCK_DANGER - 1), 
			(tr("Hecho") if Save.tower_open() else tr("¡Hecho! Haz clic en la torre del mapa para abrirla.")) if unlocked
				else tr("Tu máximo ahora: %s") % GameData.danger_name(maxi(1, Save.max_danger()))], 
		[builds > 0, tr("Guarda una build"), 
			tr("Se guarda sola al terminar una partida con el héroe en Nv %d o más. Tienes %d.") % [GameData.TOWER_BUILD_MIN_LEVEL, builds]], 
		[false, tr("Ve a la torre y elige tu build con Lucile"), tr("La build se gasta al entrar.")], 
	]
	for i in steps.size():
		var done: bool = steps[i][0]
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		col.add_child(row)
		var mark: = UiKit.label("✓" if done else str(i + 1), 15, Color(0.2, 0.6, 0.25) if done else Color(0.6, 0.38, 0.05), true)
		mark.custom_minimum_size.x = 18
		mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(mark)
		var txt: = VBoxContainer.new()
		txt.add_theme_constant_override("separation", 0)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(txt)
		txt.add_child(UiKit.label(str(steps[i][1]), 13, UiKit.MUTED if done else UiKit.TEXT, not done))
		var sub: = UiKit.label(str(steps[i][2]), 11, UiKit.MUTED)
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		txt.add_child(sub)
	return box



func _tower_card(top: int) -> Control:
	var frame: = PanelContainer.new()
	var fb: = UiKit.panel_box(Color(0.1, 0.06, 0.08), Color(0.55, 0.35, 0.95), 8, 2)
	fb.set_content_margin_all(0)
	frame.add_theme_stylebox_override("panel", fb)
	var art: = TextureRect.new()
	var path: = "res://assets/ro/ui/tower_banner.png"
	if ResourceLoader.exists(path):
		art.texture = load(path)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.custom_minimum_size = Vector2(0, 112)
	art.clip_contents = true
	frame.add_child(art)
	var spr: = RoAssets.sprite(["naght_sieger"])
	if spr != null:
		var boss: = UiKit.icon_rect(spr.get_frame(0, 0), 0)
		boss.size = Vector2(spr.canvas_size) * 0.8
		boss.anchor_left = 1.0
		boss.anchor_right = 1.0
		boss.position = Vector2(-150.0, 0)
		boss.offset_left = -120.0 - spr.origin.x * 0.8
		boss.offset_top = 104.0 - spr.origin.y * 0.8
		boss.offset_right = boss.offset_left + boss.size.x
		boss.offset_bottom = boss.offset_top + boss.size.y
		art.add_child(boss)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.position = Vector2(14, 10)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.add_child(col)
	col.add_child(_shadowed(tr("ENDLESS TOWER"), 22, Color(1.0, 0.92, 0.85), true))
	col.add_child(_shadowed(tr("Sin final: cada piso, más difícil"), 12, Color(0.95, 0.8, 0.85)))
	col.add_child(_shadowed("♪ %s" % tr("Música propia en cada tramo de la torre"), 11, Color(0.85, 0.78, 1.0)))
	col.add_child(_shadowed(tr("Piso 100: Naght Sieger") if top < GameData.TOWER_FLOORS else tr("Naght Sieger vencido"), 12, 
		Color(1.0, 0.6, 0.5) if top < GameData.TOWER_FLOORS else Color(1.0, 0.85, 0.4)))
	return frame


func _shadowed(text: String, size: int, col: Color, title: = false) -> Label:
	var l: = UiKit.label(text, size, col, title)
	l.add_theme_color_override("font_outline_color", Color(0.12, 0.02, 0.06, 0.9))
	l.add_theme_constant_override("outline_size", 7 if title else 5)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l




func _tower_stretches(top: int) -> Control:
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	col.add_child(UiKit.label(tr("Tramos y sus MVP"), 12, UiKit.GOLD, true))
	var grid: = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	col.add_child(grid)
	for i in GameData.TOWER_TIERS.size():
		var first: = i * GameData.TOWER_TIER_FLOORS + 1
		var last: = first + GameData.TOWER_TIER_FLOORS - 1
		var mvp: = GameData.TOWER_LORD if last == GameData.TOWER_FLOORS else str(GameData.STAGES[GameData.TOWER_TIERS[i]].mvp)
		var seen: = top + 1 >= first
		var cell: = PanelContainer.new()
		var lord: = mvp == GameData.TOWER_LORD
		cell.add_theme_stylebox_override("panel", UiKit.panel_box(Color(1.0, 0.94, 0.92) if lord else Color(0.96, 0.97, 1.0), 
			Color(0.85, 0.35, 0.3) if lord else (Color(0.62, 0.5, 0.95) if top >= last else Color(0.82, 0.84, 0.92)), 6, 2 if lord else 1))
		var v: = VBoxContainer.new()
		v.add_theme_constant_override("separation", 0)
		cell.add_child(v)
		var pic: = UiKit.icon_rect(StagePreview._cropped(mvp), 40)
		pic.texture_filter = RoAssets.ui_filter()
		pic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if not seen:
			pic.modulate = Color(0.05, 0.05, 0.1, 0.85)
		v.add_child(pic)
		var l: = UiKit.label(("✓ " if top >= last else "") + "%d-%d" % [first, last], 10, Color(0.4, 0.25, 0.75) if top >= last else UiKit.MUTED, true)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(l)
		cell.tooltip_text = "%s  ·  %s" % [tr(str(GameData.STAGES[GameData.TOWER_TIERS[i]].name)), 
			tr("MVP: %s") % (tr(str(GameData.MONSTERS[mvp].name)) if seen else "???")]
		grid.add_child(cell)
	return col



func _tower_facts() -> Control:
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	var lines: = [
		["⚑", tr("Puntos de control cada 10 pisos (y cada 50 pasado el 100)")], 
		["✦", tr("Pisos con reglas: Horda, Furia, Fiebre de oro, Élites, Gigantes")], 
		["♥", tr("Lucile te bendice en los pisos que terminan en 5")], 
		["◆", tr("Equipo de cara morado y legendario, solo aquí")], 
		["∞", tr("Pasado el 100: todos los MVP por turnos, cada ciclo más duro")], 
		["▼", tr("Torre de Hel abierta: elígela en la ventana de Lucile") if Save.hel_open() else (tr("La Torre de Hel abre en %s") % world.menus._hel_wait_text(Save.hel_wait()) if Save.hel_earned() else tr("Supera el piso 100 para abrir la Torre de Hel"))], 
		["⚔", tr_n("Tienes %d build guardada", "Tienes %d builds guardadas", Save.tower_builds().size()) % Save.tower_builds().size()], 
	]
	for ln in lines:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var ic: = UiKit.label(str(ln[0]), 12, Color(0.55, 0.35, 0.9), true)
		ic.custom_minimum_size.x = 16
		row.add_child(ic)
		var l: = UiKit.label(str(ln[1]), 12, UiKit.TEXT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)
		col.add_child(row)
	return col



func _open_tower(old_pin: Control) -> void :
	Save.unlock_tower()
	world.play_sound("job_levelup", 0.0, 0.0)
	world.play_sound("drop_yellow", 0.0, -4.0)
	var flash: = ColorRect.new()
	flash.color = Color(0.85, 0.75, 1.0, 0.6)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	var tw: = flash.create_tween()
	tw.tween_property(flash, "color:a", 0.0, 0.6)
	tw.tween_callback(flash.queue_free)
	var pin: = _tower_pin()
	old_pin.get_parent().add_child(pin)
	old_pin.queue_free()
	pin.scale *= 0.4
	pin.create_tween().tween_property(pin, "scale", pin.scale / 0.4, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pin_note(pin, tr("¡Endless Tower desbloqueada! Lucile te espera"), Color(1.0, 0.85, 0.4))



func _pin_note(pin: Control, text: String, col: Color) -> void :
	var l: = UiKit.label(text, 12, col, true)
	l.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.2))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pin.add_child(l)

	l.position = Vector2( - l.get_combined_minimum_size().x + 50.0, 50.0)
	var tw: = l.create_tween()
	tw.tween_interval(2.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


func _region_tip(rid: String) -> String:
	var r: Dictionary = GameData.REGIONS[rid]

	if Save.region_unlocked(rid):
		return ""
	return tr("Vence a cualquier MVP de %s") % tr(str(GameData.REGIONS[str(r.unlock)].name))


func _select_region(rid: String) -> void :
	if rid == region:
		return
	region = rid
	if rid != TOWER:
		stage_id = str(GameData.REGIONS[rid].stages[0])
	world.menus.ui_click()
	_build()


func _fill_side() -> void :
	if not world.board.ranks_ready.is_connected(_on_ranks):
		world.board.ranks_ready.connect(_on_ranks)
		world.board.fetch_ranks()
	if region == TOWER:
		_fill_tower_side()
		return
	for c in _side.get_children():
		c.queue_free()
	var r: Dictionary = GameData.REGIONS[region]
	var stages: Array = r.stages
	var head: = HBoxContainer.new()
	_side.add_child(head)
	var t: = UiKit.label(tr(str(r.name)), 22, UiKit.TEXT, true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var done: = stages.filter( func(s): return Save.is_stage_cleared(s)).size()
	head.add_child(UiKit.tag(tr("MVP %d/%d") % [done, stages.size()], Color(0.3, 0.6, 0.35) if done == stages.size() else Color(0.45, 0.5, 0.65)))
	for sid in stages:
		_side.add_child(_map_card(sid))
	_side.add_child(_side_tabs())
	if _side_tab == "records":

		var rec: = PanelContainer.new()
		var rbox: = UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 8, 1)
		rbox.set_content_margin_all(0)
		rbox.content_margin_bottom = 6
		rec.add_theme_stylebox_override("panel", rbox)
		rec.clip_contents = true
		rec.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_side.add_child(rec)
		_records = VBoxContainer.new()
		_records.add_theme_constant_override("separation", 0)
		rec.add_child(_records)
		_fill_records()
	else:
		_records = null
		_side.add_child(_mvp_line(stage_id))
		var gap: = Control.new()
		gap.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_side.add_child(gap)
		_side.add_child(_danger_box())
	if world.speed > 1:
		var pace: = UiKit.label(tr("Frenesí: todo x%s más rápido · zeny +%d%%") % [
			str(GameData.GAME_FAST_SPEED if RoServerSelect.speed_on(world.speed, Save.is_stage_cleared(stage_id)) >= 3 else GameData.FRENZY_SPEED), roundi(GameData.FRENZY_ZENY * 100.0)], 11, Color(0.7, 0.2, 0.1), true)
		pace.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_side.add_child(pace)
	for c in _side_foot.get_children():
		c.queue_free()
	var footer: = _side_foot
	var back: = UiKit.button(tr("Volver"))
	back.pressed.connect( func(): cancelled.emit())
	footer.add_child(back)
	var cleared: = Save.is_stage_cleared(stage_id)


	var x2: = UiKit.button(tr("Frenesí") + "        ", world.speed > 1)


	RoServerSelect.frenzy_pips(x2, RoServerSelect.speed_on(world.speed, cleared))
	x2.tooltip_text = RoServerSelect.speed_tip()
	x2.pressed.connect( func():
		world.speed = RoServerSelect.next_speed(world.speed, cleared)
		world.menus.ui_click()
		_fill_side())
	footer.add_child(x2)


	for cid in ["bloody_branch", "doom", "mvp_pride"]:
		if Save.upgrade_level(cid) > 0:
			footer.add_child(_curse_toggle(cid))
	var gap2: = Control.new()
	gap2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(gap2)
	var go: = UiKit.button(tr("Elegir  ▶"), true)
	go.custom_minimum_size.x = 150
	go.pressed.connect( func(): chosen.emit(stage_id))
	footer.add_child(go)




func _curse_toggle(id: String) -> Button:
	var on: = Save.upgrade_on(id)
	var u: Dictionary = GameData.UPGRADES[id]
	var b: = UiKit.button("", on)
	b.icon = world.menus._upgrade_icon(id, u)
	b.expand_icon = true
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.add_theme_constant_override("icon_max_width", 24)
	b.custom_minimum_size.x = 44
	if not on:
		b.modulate = Color(1, 1, 1, 0.55)
	var lv: = Save.upgrade_level(id)
	b.tooltip_text = "%s%s  ·  %s\n%s" % [tr(str(u.name)), ("  Nv %d" % lv) if int(u.max) > 1 else "", 
		tr("Activa") if on else tr("Apagada"), tr(str(u.desc))]
	b.pressed.connect( func():
		world.menus.ui_click()
		if id == "doom" and not Save.upgrade_on(id):
			world.menus._confirm_doom(_fill_side)
			return
		Save.set_upgrade_on(id, not Save.upgrade_on(id))
		_fill_side())
	return b






func _city_badge() -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var k: = clampf(_scale / 0.5, 0.8, 1.0)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.1, 0.16, 0.3, 0.92)
	box.border_color = UiKit.GOLD_DIM
	box.set_border_width_all(2)
	box.set_corner_radius_all(8)
	box.shadow_color = Color(0, 0, 0, 0.35)
	box.shadow_size = 4
	var lit: = box.duplicate() as StyleBoxFlat
	lit.bg_color = Color(0.16, 0.24, 0.42, 0.96)
	lit.border_color = UiKit.GOLD
	for s in ["normal", "focus"]:
		b.add_theme_stylebox_override(s, box)
	for s in ["hover", "pressed"]:
		b.add_theme_stylebox_override(s, lit)
	b.tooltip_text = tr("Entrar a la ciudad sin empezar una partida.") + """
""" + tr("La plaza y sus NPC: Kafra, refinador, Sabio, Klaws...")
	var row: = HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 4
	row.offset_right = -10
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)

	var face: = Panel.new()
	var fb: = StyleBoxFlat.new()
	fb.bg_color = Color(0.95, 0.92, 0.82)
	fb.border_color = UiKit.GOLD
	fb.set_border_width_all(2)
	fb.set_corner_radius_all(16)
	face.add_theme_stylebox_override("panel", fb)
	face.custom_minimum_size = Vector2(32, 32)
	face.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	face.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(face)
	var ic: = TextureRect.new()
	ic.texture = StagePreview._cropped("npc_kafra")
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ic.offset_top = 2
	ic.offset_bottom = 10
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.add_child(ic)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", -3)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	col.add_child(UiKit.label("Prontera City", 13, Color(1.0, 0.93, 0.7), true))
	col.add_child(UiKit.label(tr("Entrar  ▶"), 10, Color(0.75, 0.82, 1.0)))

	var size: = Vector2(150.0, 42.0)
	b.custom_minimum_size = size
	b.size = size
	b.scale = Vector2.ONE * k
	b.position = Vector2(MAP_SIZE.x * _scale - size.x * k - 8.0, 8.0)
	b.pressed.connect(_go_city)
	return b



func _go_city() -> void :
	var cid: = class_id if GameData.CLASSES.has(class_id) else (RoCharSelect.last_id if GameData.CLASSES.has(RoCharSelect.last_id) else "swordsman")
	world.menus.ui_click()
	world.menus.show_loading(world.enter_town.bind(cid, "prontera"), [Town.MAP])



func _map_card(sid: String) -> Button:
	var st: Dictionary = GameData.STAGES[sid]
	var sel: = sid == stage_id
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, 62)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.97, 0.86) if sel else Color(0.95, 0.96, 1.0)
	box.border_color = Color(0.85, 0.6, 0.15) if sel else Color(0.78, 0.81, 0.9)
	box.set_border_width_all(2 if sel else 1)
	box.set_corner_radius_all(8)
	for k in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(k, box)
	b.pressed.connect( func():
		stage_id = sid
		world.menus.ui_click()
		_fill_side())
	var row: = HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 6
	row.offset_right = -6
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	var mp: = "res://assets/ro/ui/map/%s.png" % st.map
	var mini: = UiKit.icon_rect(load(mp) if ResourceLoader.exists(mp) else null, 50)
	mini.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mini.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(mini)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 0)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(col)
	col.add_child(UiKit.label(tr(str(st.name)), 15, UiKit.TEXT, true))
	col.add_child(UiKit.label("♪ %s" % str(st.get("bgm", "")), 11, Color(0.45, 0.35, 0.7)))
	col.add_child(UiKit.label(tr("MVP: %s") % tr(str(GameData.MONSTERS[str(st.mvp)].name)), 11, UiKit.MUTED))
	var tags: = VBoxContainer.new()
	tags.add_theme_constant_override("separation", 2)
	tags.alignment = BoxContainer.ALIGNMENT_CENTER
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(tags)

	var uniq: = GameData.unique_of_stage(sid)
	if uniq != "":
		var found: = Save.has_seen("uniques", uniq)
		var ui: = UiKit.icon_rect(world.menus._item_icon(str(GameData.ITEMS[uniq].icon)), 30)
		ui.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not found:
			ui.modulate = Color(0.08, 0.1, 0.18, 0.75)
		row.add_child(ui)
		row.move_child(ui, row.get_child_count() - 2)

	var mr = world.board.ranks.get(sid)
	if mr is Dictionary:
		var rk: = int(mr.get("rank", 0))
		var medal: Color = MEDALS[rk - 1] if rk >= 1 and rk <= 3 else Color(0.45, 0.5, 0.7)
		tags.add_child(_rank_tag(rk, int(mr.get("total", 0)), medal))

	if not Save.entered(sid):
		tags.add_child(UiKit.tag(tr("SIN EXPLORAR"), Color(0.6, 0.35, 0.9)))
	elif Save.is_stage_cleared(sid):
		tags.add_child(UiKit.tag(tr("MVP ✓  P%d") % Save.danger_best(sid), Color(0.3, 0.6, 0.35)))
	else:
		tags.add_child(UiKit.tag(tr("MVP PENDIENTE"), Color(0.3, 0.32, 0.42)))
	if GameData.QUESTS.has(sid) and not Save.quest_done(sid):
		tags.add_child(UiKit.tag(tr("QUEST"), Color(0.85, 0.6, 0.15)))

		var npc: = _quest_icons(sid, 30, false)
		if not npc.is_empty():
			row.add_child(npc[0])
			row.move_child(npc[0], row.get_child_count() - 2)

	if sid == GameData.featured_stage():
		var rib: = UiKit.tag("+%d%%" % roundi(GameData.FEATURED_BONUS * 100.0), Color(0.9, 0.5, 0.1))
		rib.position = Vector2(2, 34)
		rib.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(rib)
		b.tooltip_text = tr("Mapa del día: +%d%% de recompensas") % roundi(GameData.FEATURED_BONUS * 100.0)
	return b





func _quest_icons(sid: String, size: int, rewards: bool) -> Array[Control]:
	var out: Array[Control] = []
	var q: Dictionary = GameData.QUESTS.get(sid, {})
	if q.is_empty():
		return out
	var done: = Save.quest_done(sid)
	var pics: Array = [[StagePreview._cropped(str(q.get("npc", ""))), tr(str(q.get("npc_name", "")))]]
	if rewards:
		var rw: Dictionary = q.get("reward", {})
		if rw.has("recipe") and GameData.RECIPES.has(str(rw.recipe)):
			var rd: Dictionary = GameData.RECIPES[str(rw.recipe)]
			pics.append([world.menus._item_icon(str(rd.icon)), tr(str(rd.name))])
		if rw.has("pet"):
			pics.append([StagePreview._cropped(str(rw.pet)), tr(str(GameData.PETS[str(rw.pet)].name))])
		if rw.has("card"):
			pics.append([RoAssets.card_art(str(rw.card)), tr(str(GameData.CARDS[str(rw.card)].name))])
	for pic in pics:
		if pic[0] == null:
			continue
		var tex: Texture2D = pic[0]
		var r: = UiKit.icon_rect(tex, size)


		var npc: = out.is_empty() and tex.get_height() > tex.get_width() * 1.3
		if npc:
			r.custom_minimum_size = Vector2(size * 0.9, size * 1.55)
		r.texture_filter = RoAssets.ui_filter()
		r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		r.mouse_filter = Control.MOUSE_FILTER_PASS
		r.tooltip_text = str(pic[1]) if done else "???"
		if not done:


			r.modulate = Color(0.3, 0.32, 0.42) if npc else Color(0.08, 0.1, 0.18, 0.75)
		out.append(r)
	return out




func _mvp_line(sid: String) -> Control:
	var st: Dictionary = GameData.STAGES[sid]
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var mvp: = str(st.mvp)
	var known: = Save.entered(sid)
	var pic: = UiKit.icon_rect(StagePreview._cropped(mvp), 64)
	if not known:
		pic.modulate = Color(0.05, 0.05, 0.1, 0.85)
	row.add_child(pic)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(col)
	var mvp_label: = UiKit.label(tr("MVP: %s") % (tr(str(GameData.MONSTERS[mvp].name)) if known else "???"), 14, Color(0.7, 0.2, 0.25), true)
	_wrap(mvp_label)
	col.add_child(mvp_label)
	if GameData.RAIDS.has(mvp):
		col.add_child(_wrap(UiKit.label(tr("Arena: %s") % tr(str(GameData.RAIDS[mvp].title)), 11, UiKit.MUTED)))
	if sid == GameData.featured_stage():
		col.add_child(UiKit.label(tr("★ Mapa del día: +%d%% de recompensas") % roundi(GameData.FEATURED_BONUS * 100.0), 12, Color(0.85, 0.45, 0.05), true))
	if GameData.QUESTS.has(sid):
		var q: Dictionary = GameData.QUESTS[sid]
		var done: = Save.quest_done(sid)
		var ql: = UiKit.label((tr("Quest: %s  ✓") if done else tr("Quest: %s")) % tr(str(q.name)), 12, 
			Color(0.2, 0.5, 0.25) if done else Color(0.6, 0.38, 0.0), true)
		ql.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_wrap(ql)
		var qline: = HBoxContainer.new()
		qline.add_theme_constant_override("separation", 4)
		for ic in _quest_icons(sid, 22, true):
			qline.add_child(ic)
		qline.add_child(ql)
		col.add_child(qline)
	var sets_row: = _sets_line(sid)
	if sets_row != null:
		col.add_child(sets_row)


	row.add_child(_monsters_box(sid))
	return row




func _sets_line(sid: String) -> Control:
	var sets: = GameData.stage_sets(sid)
	if sets.is_empty():
		return null
	var box: = HFlowContainer.new()
	box.add_theme_constant_override("h_separation", 4)
	box.add_theme_constant_override("v_separation", 1)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(UiKit.label(tr("Sets legendarios:"), 11, UiKit.MUTED, true))
	for set_id in sets:
		var st: Dictionary = GameData.SETS[set_id]
		var item: = HBoxContainer.new()
		item.add_theme_constant_override("separation", 2)
		item.mouse_filter = Control.MOUSE_FILTER_PASS
		var others: Array = GameData.set_stages(set_id).filter( func(s): return s != sid).map( func(s): return tr(str(GameData.STAGES[s].name)))
		item.tooltip_text = tr("Set: %s") % tr(str(st.name)) + "  ·  " + tr(str(st.get("build", "")))\
		+ ("\n" + tr("También cae en: %s") % ", ".join(others) if not others.is_empty() else "")
		var ic: = UiKit.icon_rect(world.menus._item_icon(str(GameData.ITEMS[GameData.set_pieces(set_id)[0]].get("icon", ""))), 18)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(ic)
		var nm: = UiKit.label(tr(str(st.name)), 11, GameData.LEGENDARY_COLOR.darkened(0.25), true)
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(nm)
		box.add_child(item)
	return box




func _wrap(l: Label) -> Label:
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.custom_minimum_size.x = 60
	return l





const MOB_COL_W: = 104
func _monsters_box(sid: String) -> Control:
	var st: Dictionary = GameData.STAGES[sid]
	var known: = Save.entered(sid)
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	box.add_child(UiKit.label(tr("Monstruos"), 11, UiKit.MUTED, true))
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 2)
	box.add_child(grid)
	for mob in StagePreview._monsters(st):
		var item: = HBoxContainer.new()
		item.add_theme_constant_override("separation", 3)
		item.custom_minimum_size.x = MOB_COL_W
		grid.add_child(item)
		var portrait: = UiKit.icon_rect(StagePreview._cropped(mob), 22)
		if not known:
			portrait.modulate = Color(0.05, 0.05, 0.1, 0.85)
		item.add_child(portrait)
		var label: = UiKit.label(tr(str(GameData.MONSTERS[mob].name)) if known else "???", 10, UiKit.TEXT, true)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size.x = MOB_COL_W - 25
		UiKit.fit_dots(label)
		item.add_child(label)
	return box





func _clamp_danger() -> void :
	var dr: = GameData.stage_danger_range(stage_id, Save.max_danger())
	var picked: = Save.stage_danger(stage_id)
	world.danger = clampi(picked if picked > 0 else dr.x, dr.x, dr.y)





var _danger_segs: Array = []
var _danger_drag: = false



func _danger_box() -> PanelContainer:
	_clamp_danger()
	_danger_segs.clear()
	var d: = world.danger
	var dr: = GameData.stage_danger_range(stage_id, Save.max_danger())
	var lo: = dr.x
	var mx: = dr.y
	var panel: = PanelContainer.new()
	var box: = StyleBoxFlat.new()
	var hot: = d >= GameData.DANGER_HARD
	var hell: = GameData.hell_level(d) > 0
	box.bg_color = Color(1.0, 0.95, 0.95) if hell else (Color(1.0, 0.97, 0.955) if hot else Color(0.97, 0.975, 1.0))
	box.border_color = Color(0.66, 0.12, 0.18) if hell else (Color(0.86, 0.45, 0.4) if hot else Color(0.7, 0.76, 0.9))
	box.set_border_width_all(2 if hell else 1)
	box.set_corner_radius_all(10)
	box.shadow_color = Color(box.border_color, 0.2)
	box.shadow_size = 4
	box.shadow_offset = Vector2(0, 2)
	box.anti_aliasing = true
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	panel.add_child(col)
	var ink: = Color(0.55, 0.05, 0.1) if hell else (Color(0.75, 0.2, 0.15) if hot else Color(0.2, 0.25, 0.6))


	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var title: = UiKit.label(tr("Infierno") if hell else tr("Peligro"), 15, Color(0.55, 0.05, 0.1) if hell else UiKit.TEXT, true)
	title.custom_minimum_size.x = 64
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(title)

	var minus: = _danger_arrow("◀", ink)
	minus.disabled = d <= lo
	minus.pressed.connect( func(): _change_danger(-1))
	row.add_child(minus)
	var medal_box: = _danger_medal(GameData.hell_level(d) if hell else d, ink, hell)
	row.add_child(medal_box)
	var plus: = _danger_arrow("▶", ink)
	plus.disabled = d >= mx
	plus.pressed.connect( func(): _change_danger(1))
	row.add_child(plus)
	var steps: = HBoxContainer.new()
	steps.add_theme_constant_override("separation", 2)
	steps.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	steps.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	steps.alignment = BoxContainer.ALIGNMENT_END
	row.add_child(steps)


	var groups: Array = []
	for g in 2:
		var gv: = VBoxContainer.new()
		gv.add_theme_constant_override("separation", 2)
		gv.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var gr: = HBoxContainer.new()
		gr.add_theme_constant_override("separation", 2)
		gr.custom_minimum_size.y = 22
		gv.add_child(gr)
		var under: = ColorRect.new()
		under.custom_minimum_size.y = 2
		under.color = Color(0.6, 0.06, 0.1, 0.85) if g == 1 else Color(0.55, 0.6, 0.8, 0.35)
		under.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gv.add_child(under)
		if g == 1:
			gv.tooltip_text = tr("Infierno")
			gv.mouse_filter = Control.MOUSE_FILTER_PASS
			var pad: = Control.new()
			pad.custom_minimum_size = Vector2(4, 0)
			steps.add_child(pad)
		steps.add_child(gv)
		groups.append(gr)
	for i in range(1, GameData.DANGER_MAX + 1):
		var last: = GameData.DANGER_HELL_FROM - 1

		var c: = Color(0.3, 0.45, 0.85).lerp(Color(0.9, 0.25, 0.2), float(i - 1) / float(last - 1)) if i <= last\
		else Color(0.6, 0.04, 0.08).lerp(Color(0.15, 0.0, 0.05), float(i - GameData.DANGER_HELL_FROM) / float(maxi(1, GameData.DANGER_MAX - GameData.DANGER_HELL_FROM)))
		var col_i: Color
		var tip: = ""
		if i < lo:

			col_i = Color(c, 0.5).darkened(0.5)
			tip = tr("Este mapa empieza en peligro %d") % lo
		else:

			var locked: = Color(0.6, 0.25, 0.28, 0.4) if i >= GameData.DANGER_HELL_FROM else Color(0.75, 0.76, 0.8, 0.5)
			col_i = c if i <= d else (Color(c, 0.35) if i <= mx else locked)
			tip = GameData.danger_name(i) if i <= mx else tr("Bloqueado: vence a un MVP en %s") % GameData.danger_name(mx)
		var seg: = _danger_step(col_i, i == d, tip)
		seg.mouse_filter = Control.MOUSE_FILTER_STOP
		seg.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		seg.gui_input.connect(_on_danger_seg)
		_danger_segs.append([seg, i])
		(groups[1] if i >= GameData.DANGER_HELL_FROM else groups[0]).add_child(seg)



	var mon: = Color(0.72, 0.2, 0.2)
	var gold: = Color(0.72, 0.48, 0.05)
	var hp: = GameData.danger_hp(d, 1.0, true)
	var dmg: = GameData.danger_dmg(d, 1.0, true)
	var more: = roundi((GameData.danger_rate(d) - 1.0) * 100.0)
	var fast: = roundi((GameData.danger_speed(d, 1.0, true) - 1.0) * 100.0)
	var rw: = str(snappedf(GameData.danger_reward(d), 0.1))
	var cards: = str(snappedf(GameData.danger_cards(d), 0.01))
	var legend: = str(snappedf(GameData.danger_legend(d) * 100.0, 0.5))
	var uniq: = str(snappedf(GameData.unique_mult(d), 0.01))
	var mon_rows: = [
		[UiKit.skill_icon("hp_recovery"), tr("Vida"), "x" + _mult(hp), tr("Vida de los monstruos: x%s") % _mult(hp)], 
		[UiKit.skill_icon("bash"), tr("Daño"), "x" + _mult(dmg), tr("Daño de los monstruos: x%s") % _mult(dmg)], 
		[UiKit.skill_icon("mirror_image"), tr("Cantidad"), "+%d%%" % more, tr("Cantidad de monstruos: +%d%%") % more], 
		[UiKit.skill_icon("increase_agi"), tr("Velocidad"), "+%d%%" % fast, tr("Velocidad de los monstruos: +%d%%") % fast]]
	var loot_rows: = [
		[world.menus._item_icon("gold_coin"), tr("Zeny y EXP"), "x" + rw, tr("Recompensas x%s: multiplica el zeny y la EXP de clase que ganas.") % rw], 
		[world.menus._item_icon("card_slot"), tr("Cartas"), "x" + cards, tr("Cartas x%s: probabilidad de que caigan cartas.") % cards], 
		[world.menus._item_icon("chest"), tr("Legendarios"), "+%s%%" % legend, tr("Legendarios +%s%%: probabilidad extra de legendarios en cofres y élites.") % legend], 
		[world.menus._item_icon("star_blessing"), tr("Única del mapa"), "x" + uniq, tr("Únicas x%s: probabilidad de la única de este mapa.") % uniq]]
	var pair: = HBoxContainer.new()
	pair.add_theme_constant_override("separation", 6)
	pair.add_child(_info_card(tr("Monstruos"), mon, mon_rows))
	var loot: = _info_card(tr("Botín"), gold, loot_rows)
	pair.add_child(loot)
	col.add_child(pair)
	if Save.daily_bonus_ready():

		var daily: = UiKit.label("  ★ +%d%%" % roundi(GameData.DAILY_FIRST_BONUS * 100.0), 9, Color(0.85, 0.5, 0.0), true)
		daily.tooltip_text = tr("★ Primera partida del día: +%d%% de zeny al terminar") % roundi(GameData.DAILY_FIRST_BONUS * 100.0)
		daily.mouse_filter = Control.MOUSE_FILTER_STOP
		var title_row: = HBoxContainer.new()
		var title_l: Control = loot.get_child(0).get_child(0)
		loot.get_child(0).remove_child(title_l)
		title_row.add_child(title_l)
		title_row.add_child(daily)
		loot.get_child(0).add_child(title_row)
		loot.get_child(0).move_child(title_row, 0)


	var adds: Array = []
	if hell:
		for i in GameData.hell_level(d):
			var f: Dictionary = GameData.HELL_FEATURES[i]
			adds.append([_hell_icon(i), tr(str(f.name)), "%s: %s" % [tr(str(f.name)), tr(str(f.desc))]])
	elif hot:
		adds.append([UiKit.skill_icon("provoke"), tr("Élites de a dos"), tr("Élites de a dos y más monstruos especiales")])
	if d >= GameData.STORM_FROM and GameData.hell_level(d) <= 0:
		adds.append([UiKit.skill_icon("thunder_storm"), tr("Tormenta"), tr("Tormenta: de vez en cuando caen rayos donde estás")])
	if not adds.is_empty():


		var icons_only: Array = []
		if adds.size() > 10:
			icons_only = adds.slice(0, 10)
			adds = adds.slice(10)
		col.add_child(_rules_card(tr("Reglas de Infierno  ·  %d") % (adds.size() + icons_only.size()) if hell else tr("Lo que añade"), 
			mon if hell else Color(0.75, 0.35, 0.15), adds, icons_only))

	var range_tips: Array[String] = [GameData.danger_name(d)]
	if lo > 1:
		range_tips.append(tr("Peligro mínimo de este mapa: %d") % lo)
	if mx < GameData.DANGER_MAX:

		var after: = GameData.stage_danger_range_after(stage_id, d, Save.max_danger())
		if after > mx:
			var opens: = GameData.danger_name(after) if after == mx + 1 else tr("%s a %s") % [GameData.danger_name(mx + 1), GameData.danger_name(after)]
			range_tips.append(tr("Vence al MVP aquí para abrir %s") % opens)
		else:
			range_tips.append(tr("Vence al MVP en un peligro más alto para abrir más"))
	var range_tip: = "\n".join(range_tips)
	medal_box.tooltip_text = range_tip
	medal_box.mouse_filter = Control.MOUSE_FILTER_STOP
	if plus.disabled and range_tips.size() > 1:
		plus.tooltip_text = range_tips[range_tips.size() - 1]
	if minus.disabled and lo > 1:
		minus.tooltip_text = tr("Peligro mínimo de este mapa: %d") % lo
	col.add_child(row)

	if d >= GameData.DANGER_MAX:
		box.content_margin_top = 12
		var over: = Control.new()
		over.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(over)
		var seal: = _oath_seal()
		seal.anchor_left = 1.0
		seal.anchor_right = 1.0
		seal.offset_left = - SEAL - 6.0
		seal.offset_right = -6.0
		seal.offset_top = - SEAL * 0.62
		seal.offset_bottom = SEAL * 0.38
		over.add_child(seal)
	return panel




func _info_card(title: String, ink: Color, rows: Array) -> PanelContainer:
	var card: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.95)
	sb.border_color = ink.lerp(Color.WHITE, 0.6)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(7)
	sb.anti_aliasing = true
	sb.content_margin_left = 7
	sb.content_margin_right = 7
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	card.add_theme_stylebox_override("panel", sb)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	card.add_child(v)
	v.add_child(UiKit.label(title.to_upper(), 9, ink, true))
	for r in rows:
		var line: = HBoxContainer.new()
		line.add_theme_constant_override("separation", 4)
		line.tooltip_text = str(r[3])
		line.mouse_filter = Control.MOUSE_FILTER_STOP
		v.add_child(line)
		if r[0] != null:
			var ic: = UiKit.icon_rect(r[0], 16)
			ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line.add_child(ic)
		var n: = UiKit.label(str(r[1]), 10, UiKit.MUTED)
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n.clip_text = true
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(n)
		var val: = UiKit.label(str(r[2]), 11, ink.darkened(0.15), true)
		val.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(val)
	return card




func _rules_card(title: String, ink: Color, adds: Array, icons_only: Array = []) -> PanelContainer:
	var card: = _info_card(title, ink, [])
	if not icons_only.is_empty():
		var strip: = HBoxContainer.new()
		strip.add_theme_constant_override("separation", 2)
		card.get_child(0).add_child(strip)
		var lbl: = UiKit.label(tr("Infierno 1-10"), 10, UiKit.MUTED, true)
		lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		strip.add_child(lbl)
		for a in icons_only:
			var ic: = UiKit.icon_rect(a[0], 16)
			ic.tooltip_text = str(a[2])
			ic.mouse_filter = Control.MOUSE_FILTER_STOP
			strip.add_child(ic)
	var grid: = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 0)
	card.get_child(0).add_child(grid)
	for a in adds:
		var line: = HBoxContainer.new()
		line.add_theme_constant_override("separation", 4)
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.custom_minimum_size.x = 0
		line.tooltip_text = str(a[2])
		line.mouse_filter = Control.MOUSE_FILTER_STOP
		grid.add_child(line)
		var ic: = UiKit.icon_rect(a[0], 16)
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(ic)
		var n: = UiKit.label(str(a[1]), 10, UiKit.TEXT, true)
		n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n.clip_text = true
		n.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(n)
	return card



func _chip_row() -> HFlowContainer:
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 4)
	row.add_theme_constant_override("v_separation", 4)
	return row





func _mult(v: float) -> String:
	if v >= 1e+18:
		return "%.2e" % v
	if v >= 10000.0:
		return RoAssets.short_number(roundi(v))
	return str(roundi(v)) if v >= 100.0 else str(snappedf(v, 0.1))




func _icon_chip(tex: Texture2D, text: String, tip: String, ink: Color, filled: = false) -> PanelContainer:
	var chip: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.95, 0.8) if filled else Color(1, 1, 1, 0.92)
	sb.border_color = ink.lerp(Color.WHITE, 0.5)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(9)
	sb.anti_aliasing = true
	sb.content_margin_left = 4 if tex != null else 8
	sb.content_margin_right = 8
	sb.content_margin_top = 1
	sb.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", sb)
	chip.tooltip_text = tip
	chip.mouse_filter = Control.MOUSE_FILTER_STOP
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(row)
	if tex != null:
		var ic: = UiKit.icon_rect(tex, 18)
		ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(ic)
	var l: = UiKit.label(text, 12, ink.darkened(0.15), true)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	return chip




func _effect_icon(tex: Texture2D, tip: String, rim: Color) -> PanelContainer:
	var sock: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.92)
	sb.border_color = Color(rim, 0.6)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(7)
	sb.anti_aliasing = true
	sb.set_content_margin_all(2)
	sock.add_theme_stylebox_override("panel", sb)
	sock.tooltip_text = tip
	sock.mouse_filter = Control.MOUSE_FILTER_STOP
	var ic: = UiKit.icon_rect(tex, 24)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sock.add_child(ic)
	return sock



const HELL_ICONS: = ["gangster_paradise", "", "provoke", "critical_explosion", "volcano", 
	"soul_drain", "exploding_dragon", "loud_exclamation", "meteor_storm", "magnus_exorcismus", 
	"cloaking", "status_combo", "demon_bane", "sanctuary", "dissonance"]


func _hell_icon(i: int) -> Texture2D:
	if i == 1:

		return load("res://assets/ro/ui/skin/status_icons/bleed.png")
	return UiKit.skill_icon(str(HELL_ICONS[i]) if i < HELL_ICONS.size() else "magnus_exorcismus")



func _danger_arrow(text: String, ink: Color) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(30, 30)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_override("font", UiKit.FONT_TITLE)
	b.add_theme_font_size_override("font_size", 13)
	for st in ["normal", "hover", "pressed", "disabled"]:
		var sb: = StyleBoxFlat.new()
		sb.set_corner_radius_all(15)
		sb.set_border_width_all(2)
		sb.border_width_bottom = 3
		match st:
			"normal":
				sb.bg_color = Color(1, 1, 1, 0.9)
				sb.border_color = Color(ink, 0.7)
			"hover":
				sb.bg_color = Color(1.0, 0.97, 0.88)
				sb.border_color = UiKit.GOLD
			"pressed":
				sb.bg_color = Color(ink, 0.18)
				sb.border_color = ink
				sb.border_width_bottom = 2
			_:
				sb.bg_color = Color(1, 1, 1, 0.35)
				sb.border_color = Color(0.6, 0.6, 0.65, 0.4)
		b.add_theme_stylebox_override(st, sb)
	b.add_theme_color_override("font_color", ink)
	b.add_theme_color_override("font_hover_color", ink.darkened(0.2))
	b.add_theme_color_override("font_pressed_color", ink)
	b.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.65, 0.5))
	return b




func _danger_medal(n: int, ink: Color, hell: bool) -> Control:
	var medal: = PanelContainer.new()
	var mb: = StyleBoxFlat.new()
	mb.bg_color = Color(1, 1, 1, 0.85) if not hell else Color(1.0, 0.93, 0.92, 0.9)
	mb.border_color = Color(ink, 0.75)
	mb.set_border_width_all(2)
	mb.set_corner_radius_all(18)
	medal.add_theme_stylebox_override("panel", mb)
	medal.custom_minimum_size = Vector2(38, 34)
	medal.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var num: = UiKit.label("%d" % n, 18, ink, true)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	medal.add_child(num)
	return medal




func _danger_step(c: Color, current: bool, tip: String) -> Control:
	var seg: = Panel.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(2)
	if current:
		sb.border_color = Color(1, 1, 1, 0.95)
		sb.set_border_width_all(1)
		sb.shadow_color = Color(c, 0.6)
		sb.shadow_size = 3
	seg.add_theme_stylebox_override("panel", sb)
	seg.custom_minimum_size = Vector2(7, 22 if current else 14)
	seg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	seg.tooltip_text = tip
	seg.mouse_filter = Control.MOUSE_FILTER_PASS
	return seg


func _danger_rule(c: Color) -> StyleBoxLine:
	var line: = StyleBoxLine.new()
	line.color = Color(c, 0.35)
	line.thickness = 1
	return line


func _on_danger_seg(ev: InputEvent) -> void :
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed:
		_danger_drag = true
		_danger_at(ev.global_position)




func _input(event: InputEvent) -> void :
	if not _danger_drag:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_danger_drag = false
	elif event is InputEventMouseMotion:
		_danger_at(event.global_position)


func _danger_at(pos: Vector2) -> void :
	var best: = -1
	var gap: = INF
	for e in _danger_segs:
		var seg = e[0]
		if not is_instance_valid(seg) or not seg.is_visible_in_tree():
			continue
		var r: Rect2 = seg.get_global_rect()
		if absf(pos.y - r.get_center().y) > 40.0:
			continue
		var dx: = absf(pos.x - r.get_center().x)
		if dx < gap:
			gap = dx
			best = int(e[1])
	if best < 0 or gap > 30.0:
		return
	var dr: = GameData.stage_danger_range(stage_id, Save.max_danger())
	var n: = clampi(best, dr.x, dr.y)
	if n != world.danger:
		_change_danger(n - world.danger)


func _change_danger(step: int) -> void :
	var dr: = GameData.stage_danger_range(stage_id, Save.max_danger())
	var n: = clampi(world.danger + step, dr.x, dr.y)
	if n != world.danger:
		world.danger = n
		Save.set_stage_danger(stage_id, n)
		world.menus.ui_click()
		_fill_side()


func _gui_input(event: InputEvent) -> void :
	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if _oath_layer != null and is_instance_valid(_oath_layer):
		return

	if find_child("JobPicker", false, false) != null:
		return


	if _side_tab == "records" and _records != null:
		match event.keycode:
			KEY_Q, KEY_PAGEUP:
				_switch_class(JobBoard.keys(), -1)
				accept_event()
				return
			KEY_E, KEY_PAGEDOWN:
				_switch_class(JobBoard.keys(), 1)
				accept_event()
				return
			KEY_C:
				_open_job_picker()
				accept_event()
				return
	if region == TOWER:
		match event.keycode:
			KEY_R:
				_toggle_records()
			KEY_ENTER, KEY_KP_ENTER:
				_go_tower()
			KEY_TAB:
				_select_region("prontera")
			KEY_ESCAPE:
				cancelled.emit()
			_:
				return
		accept_event()
		return
	var stages: Array = GameData.REGIONS[region].stages
	match event.keycode:
		KEY_LEFT:
			_change_danger(-1)
		KEY_RIGHT:
			_change_danger(1)
		KEY_UP, KEY_DOWN:
			var i: = stages.find(stage_id) + (1 if event.keycode == KEY_DOWN else -1)
			stage_id = str(stages[posmod(i, stages.size())])
			world.menus.ui_click()
			_fill_side()
		KEY_TAB:
			var open: = GameData.REGIONS.keys().filter( func(r): return Save.region_unlocked(r))
			var k: = open.find(region) + (-1 if event.shift_pressed else 1)
			_select_region(str(open[posmod(k, open.size())]))
		KEY_R:
			_toggle_records()
		KEY_J:
			if world.danger >= GameData.DANGER_MAX and _side_tab != "records":
				_open_oaths()
		KEY_X:
			if true:
				world.speed = RoServerSelect.next_speed(world.speed, Save.is_stage_cleared(stage_id))
				world.menus.ui_click()
				_fill_side()
		KEY_ENTER, KEY_KP_ENTER:
			chosen.emit(stage_id)
		KEY_ESCAPE:
			cancelled.emit()
		_:
			return
	accept_event()




const Oaths = preload("res://scripts/core/oaths.gd")
const OATH_RED: = Color(0.62, 0.06, 0.1)

var _oath_layer: Control





const SEAL: = 54.0


func _oath_seal() -> Control:
	var sworn: = Oaths.sworn_list(Save.oaths())
	var pts: = GameData.oath_points(Save.oaths())
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = Vector2(SEAL, SEAL)
	b.pivot_offset = Vector2(SEAL, SEAL) * 0.5
	b.rotation = deg_to_rad(-8.0)
	for st in ["normal", "hover", "pressed"]:
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.64, 0.07, 0.12) if pts > 0 or not bool(Save.setting("oaths_seen", false)) else Color(0.86, 0.55, 0.55)
		if st == "hover":
			sb.bg_color = sb.bg_color.lightened(0.12)
		sb.border_color = Color(1.0, 0.72, 0.62, 0.75) if pts > 0 else Color(1, 1, 1, 0.8)
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(int(SEAL / 2.0))
		sb.anti_aliasing = true
		sb.shadow_color = Color(0.3, 0.0, 0.04, 0.45)
		sb.shadow_size = 5
		sb.shadow_offset = Vector2(0, 2)
		b.add_theme_stylebox_override(st, sb)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", -4)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.add_child(v)
	var n: = UiKit.label(str(pts) if pts > 0 else "+", 24, Color.WHITE, true)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(n)


	var rib: = PanelContainer.new()
	var rs: = StyleBoxFlat.new()
	rs.bg_color = Color(0.4, 0.02, 0.06)
	rs.border_color = Color(1.0, 0.8, 0.45)
	rs.set_border_width_all(1)
	rs.set_corner_radius_all(4)
	rs.content_margin_left = 5
	rs.content_margin_right = 5
	rs.anti_aliasing = true
	rib.add_theme_stylebox_override("panel", rs)
	rib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w: = UiKit.label(tr("Juramento") if pts > 0 else tr("Jurar"), 11, Color(1.0, 0.92, 0.82), true)
	w.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rib.add_child(w)
	b.add_child(rib)
	var rw: = rib.get_combined_minimum_size()
	rib.position = Vector2((SEAL - rw.x) * 0.5, SEAL - rw.y * 0.55)
	var tips: Array[String] = [(tr("Juramento %d") % pts) if pts > 0 else tr("Juramentos"), 
		tr("Castigos que eliges en Infierno 15: más puntaje en el ranking y títulos.")]
	for p in sworn:
		tips.append("  · %s  (%s)" % [tr(str(p[0].name)), Oaths.rank_text(p[0], int(p[1]))])
	if pts > 0:
		tips.append(tr("Puntaje x%s en el ranking") % str(snappedf(Oaths.score_mult(pts), 0.01)))
	var best: = Save.oath_best(stage_id)
	if best > 0:
		tips.append(tr("Tu mejor en este mapa: Juramento %d") % best)
	tips.append(tr("Clic (o J): elegir Juramentos") if not MouseWalk.touch() else tr("Toca para elegir Juramentos"))
	b.tooltip_text = "\n".join(tips)

	if Save.oaths().is_empty() and not bool(Save.setting("oaths_seen", false)):
		var bub: = PanelContainer.new()
		var bs: = StyleBoxFlat.new()
		bs.bg_color = Color(1.0, 0.98, 0.95)
		bs.border_color = OATH_RED
		bs.set_border_width_all(2)
		bs.set_corner_radius_all(9)
		bs.content_margin_left = 9
		bs.content_margin_right = 9
		bs.content_margin_top = 3
		bs.content_margin_bottom = 3
		bs.shadow_color = Color(0.4, 0.0, 0.05, 0.35)
		bs.shadow_size = 4
		bs.anti_aliasing = true
		bub.add_theme_stylebox_override("panel", bs)
		bub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var bl: = UiKit.label(tr("¡Nuevo! Juramentos  ▶"), 13, OATH_RED, true)
		bl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bub.add_child(bl)
		b.add_child(bub)
		var bw: = bub.get_combined_minimum_size()
		bub.position = Vector2( - bw.x - 8.0, (SEAL - bw.y) * 0.5)
		var bob: = bub.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		bob.tween_property(bub, "position:x", bub.position.x - 6.0, 0.45)
		bob.tween_property(bub, "position:x", bub.position.x, 0.45)
	b.pressed.connect(_open_oaths)
	if sworn.is_empty() and not bool(Save.setting("oaths_seen", false)):
		var tw: = b.create_tween().set_loops()
		tw.tween_property(b, "scale", Vector2(1.08, 1.08), 0.6).set_trans(Tween.TRANS_SINE)
		tw.tween_property(b, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE)
	return b


func _open_oaths() -> void :
	if _oath_layer != null and is_instance_valid(_oath_layer):
		return
	var win = (load("res://scripts/ui/oath_window.gd") as GDScript).new()
	win.world = world
	win.stage_id = stage_id
	win.closed.connect( func():
		_oath_layer = null
		_fill_side()
		grab_focus())
	_oath_layer = win
	add_child(win)



func _rank_button(text: String, pts: String, on: bool) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(40, 40)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for st in ["normal", "hover", "pressed"]:
		var sb: = StyleBoxFlat.new()
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(1)
		sb.border_width_bottom = 2
		sb.anti_aliasing = true
		if on:
			sb.bg_color = OATH_RED if st != "hover" else OATH_RED.lightened(0.15)
			sb.border_color = OATH_RED.darkened(0.3)
		else:
			sb.bg_color = Color(1, 1, 1) if st != "hover" else Color(1.0, 0.94, 0.92)
			sb.border_color = Color(0.8, 0.82, 0.9) if st != "hover" else Color(OATH_RED, 0.6)
		b.add_theme_stylebox_override(st, sb)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", -3)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	b.add_child(v)
	var ink: = Color.WHITE if on else UiKit.TEXT
	var t: = UiKit.label(text, 13, ink, true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(t)
	if pts != "":
		var p: = UiKit.label(pts, 9, Color(1.0, 0.85, 0.8) if on else UiKit.MUTED, true)
		p.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(p)
	return b
