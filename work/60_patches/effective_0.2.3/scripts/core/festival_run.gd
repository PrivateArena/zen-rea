extends Node

const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")








var world: World

var state: = "prep"
var left: = 0.0

var checks: = 0
var banked: = 0.0
var emperium: Enemy

var build_name: = ""

var mirror: = false
var _spot: = Vector3.ZERO
var _stage: = Vector3.ZERO
var _npc: RoVisual
var _npc_armed: = true
var _fx_t: = 0.0
var _beat: = -1
var _sent_t: = 0.0

var _shown_score: = 0.0
var _hp_frac: = 1.0

var _layer: CanvasLayer
var _title: Label
var _timer: Label
var _sub: Label
var _score: Label
var _bar: ProgressBar
var _big: Label


func _init(w: World, name_line: = "") -> void :
	world = w
	build_name = name_line


func _ready() -> void :
	var m: = world.map


	_stage = _cell_point(GameData.FESTIVAL_CELL)
	_spot = _cell_point(GameData.FESTIVAL_EMPERIUM_CELL)
	for h in world.heroes:
		var at: = m.find_point_around(_spot.lerp(_stage, 0.45), 0.0, 1.5) if m != null else _spot
		if at != Vector3.INF:
			h.position = Vector3(at.x, m.height_at(at), at.z)
	if world.player != null:
		world.place_camera(world.player.position)
	_spawn_npc()
	_build_ui()
	left = GameData.FESTIVAL_PREP
	_set_state("prep")
	world.number(_npc.position + Vector3(0, 2.6, 0), tr("¡Bienvenido al festival!"), Color(1.0, 0.85, 0.4), true)
	world.play_sound("musical", 0.0, -6.0)


func _exit_tree() -> void :
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()



func _cell_point(cell: Vector2i) -> Vector3:
	var m: = world.map
	if m == null:
		return Vector3.ZERO
	var p: = m.cell_center(cell.x, cell.y)
	if not m.is_walkable(p):
		var near: = m.find_point_around(p, 0.5, 6.0)
		p = near if near != Vector3.INF else world.player.position
	p.y = m.height_at(p)
	return p



func _spawn_npc() -> void :
	var v: = RoVisual.new()
	world.run_root.add_child(v)
	v.setup(RoAssets.sprite(["npc_teleporter"]), Color(0.75, 0.6, 1.0), 40)
	var at: = _stage + Vector3(-3.0, 0, 1.5)
	if world.map != null and not world.map.is_walkable(at):
		var near: = world.map.find_point_around(_stage, 2.5, 4.0)
		if near != Vector3.INF:
			at = near
	v.position = Vector3(at.x, world.map.height_at(at) if world.map != null else at.y, at.z)
	v.face(_spot - v.position)
	v.play(RoVisual.MOB_IDLE)
	Town._name_label(v, "nearQ", tr("Emperium Festival"))
	var glow: = Vfx.ground_glow(v, Vector3(0, 0.03, 0), 1.3, Color(1.0, 0.75, 0.3, 0.6))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.3, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.75, 0.9).set_trans(Tween.TRANS_SINE)
	_npc = v




func _build_ui() -> void :
	_layer = CanvasLayer.new()
	_layer.layer = 4
	world.add_child(_layer)
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(root)


	var win: = UiStyles.hud_window(tr("Emperium Festival"), Hud.RO_FONT_BOLD)
	var panel: Control = win.root
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH


	panel.custom_minimum_size = RoBasicWindow.BG_SIZE
	panel.offset_top = 8
	root.add_child(panel)
	var strip: PanelContainer = panel.get_child(0)
	var sb: StyleBoxFlat = (strip.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	sb.bg_color = COMODO_SAND
	sb.border_color = COMODO_CORAL
	strip.add_theme_stylebox_override("panel", sb)
	var body_panel: PanelContainer = panel.get_child(1)
	var fb: StyleBoxFlat = (body_panel.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	fb.border_color = COMODO_CORAL
	body_panel.add_theme_stylebox_override("panel", fb)
	_title = win.title
	_title.add_theme_color_override("font_color", COMODO_INK)
	strip.remove_child(_title)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 5)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strip.add_child(head)
	var gem: = UiKit.icon_rect(load("res://assets/ro/ui/skin/item_icons/gem_emperium.png"), 14)
	gem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(gem)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_title)
	var where: = Label.new()
	where.text = tr("Comodo")
	where.add_theme_font_override("font", Hud.RO_FONT)
	where.add_theme_font_size_override("font_size", 10)
	where.add_theme_color_override("font_color", COMODO_CORAL.darkened(0.25))
	where.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(where)
	var col: VBoxContainer = win.body
	col.add_theme_constant_override("separation", 1)

	body_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	_timer = _hud_label("", 25, Color(0.12, 0.16, 0.4))
	col.add_child(_timer)
	_score = _hud_label("", 16, Color(0.62, 0.32, 0.12))
	col.add_child(_score)
	_bar = ProgressBar.new()
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(RoBasicWindow.BG_SIZE.x - 16.0, 8)
	_bar.max_value = 1.0
	_bar.value = 1.0
	_bar.add_theme_stylebox_override("background", UiStyles.hud_track(5.0))
	_bar.add_theme_stylebox_override("fill", UiStyles.hud_fill(COMODO_CORAL, 5.0))
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.visible = false
	col.add_child(_bar)
	_sub = _hud_label("", 11, Color(0.35, 0.4, 0.6), false)
	col.add_child(_sub)

	_big = _glow_label("", 96, Color(1.0, 0.85, 0.3))
	_big.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_big.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_big.grow_vertical = Control.GROW_DIRECTION_BOTH
	_big.add_theme_constant_override("outline_size", 14)
	_big.visible = false
	root.add_child(_big)



const COMODO_SAND: = Color(1.0, 0.9, 0.76, 0.97)
const COMODO_CORAL: = Color(0.93, 0.52, 0.36)
const COMODO_INK: = Color(0.42, 0.18, 0.12)



func _hud_label(text: String, size: int, color: Color, bold: = true) -> Label:
	var l: = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", Hud.RO_FONT_BOLD if bold else Hud.RO_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _glow_label(text: String, size: int, color: Color) -> Label:
	var l: = UiKit.label(text, size, color, true)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.05, 0.25, 0.95))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l



func _pop(text: String, color: Color, size: = 96, hold: = 0.45) -> void :
	if _big == null:
		return
	_big.text = text
	_big.add_theme_color_override("font_color", color)
	_big.add_theme_font_size_override("font_size", size)
	_big.visible = true
	_big.modulate.a = 1.0
	_big.pivot_offset = _big.size * 0.5
	_big.scale = Vector2.ONE * 1.6
	var tw: = _big.create_tween()
	tw.tween_property(_big, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(hold)
	tw.tween_property(_big, "modulate:a", 0.0, 0.3)




func net_promote() -> void :
	if not mirror:
		return
	mirror = false
	for e in world.enemies:
		if is_instance_valid(e) and not e.dead and str(e.id) == "item_emperium":
			emperium = e
	var dealt: = emperium.max_hp - emperium.hp if emperium != null and is_instance_valid(emperium) else 0.0
	banked = maxf(0.0, _shown_score - dealt)
	print("FESTIVAL promoted: %s, %.0f s left, %d broken" % [state, left, checks])


static func thousands(v: float) -> String:
	return Leaderboard.big_text(v)


func score() -> float:
	if mirror:
		return _shown_score
	var now: = banked
	if is_instance_valid(emperium) and not emperium.dead:
		now += maxf(0.0, emperium.max_hp - emperium.hp)
	return now


func _refresh_ui() -> void :
	if _timer == null:
		return
	match state:
		"prep":
			_timer.text = "%d:%02d" % [int(left) / 60, int(left) % 60]
			_score.text = build_name
			_sub.text = tr("Habla con nearQ para empezar") if not world.net.is_client() else tr("El líder empieza con nearQ")
			_bar.visible = false
		"count":
			_timer.text = str(maxi(1, ceili(left)))
			_sub.text = tr("¡Prepárate!")
		"fight":
			_timer.text = "%.1f" % maxf(0.0, left)
			_score.text = tr("Daño: %s") % thousands(score())
			_sub.text = tr("Emperium %d  ·  %s/s") % [checks + 1, thousands(score() / maxf(1.0, GameData.FESTIVAL_TIME - left))]
			_bar.visible = true
			if not mirror and is_instance_valid(emperium) and not emperium.dead:
				_hp_frac = emperium.hp / maxf(1.0, emperium.max_hp)
			_bar.value = _hp_frac
		"done":
			_timer.text = tr("¡Tiempo!")
			_score.text = tr("Daño: %s") % thousands(score())
			_sub.text = tr("%d Emperiums rotos") % checks
			_bar.visible = false




func _set_state(s: String) -> void :
	state = s
	_beat = -1
	_refresh_ui()


func _process(delta: float) -> void :
	if world == null or not world.running or world.get_tree().paused:
		return
	_ambience(delta)
	if mirror:
		if state in ["prep", "count", "fight"]:
			left -= delta
		_refresh_ui()
		_tick_beat()
		return
	match state:
		"prep":
			left -= delta
			_tick_npc()
			if left <= 0.0:
				begin()
		"count":
			left -= delta
			_tick_beat()
			if left <= 0.0:
				_start_fight()
		"fight":
			left -= delta
			_tick_beat()
			if not is_instance_valid(emperium) or emperium.dead:
				_broken()
			elif emperium.position.distance_squared_to(_spot) > 0.0001:

				emperium.position = _spot
				emperium.knock = Vector3.ZERO
			_sent_t -= delta
			if _sent_t <= 0.0:
				_sent_t = 0.5
				_send(["s", score(), _hp_frac, left])
			if left <= 0.0:
				_finish()
	_refresh_ui()



func _tick_beat() -> void :
	var n: = ceili(left)
	if n == _beat:
		return
	_beat = n
	if state == "count" and n >= 1:
		_pop(str(n), Color(1.0, 0.85, 0.3) if n > 1 else Color(1.0, 0.45, 0.35))
		world.play_sound("sl_ping", 0.0, -2.0, 0.9 + 0.08 * (GameData.FESTIVAL_COUNT - n))
	elif state == "fight" and n <= 5 and n >= 1:
		world.play_sound("warning", 0.0, -6.0, 1.2)
		_timer.add_theme_color_override("font_color", Color(0.85, 0.2, 0.15))



func _tick_npc() -> void :
	if _npc == null or not is_instance_valid(_npc) or world.player == null:
		return
	var d: = Vector2(world.player.position.x - _npc.position.x, world.player.position.z - _npc.position.z).length()
	if d > 3.0:
		_npc_armed = true
	elif d < 1.7 and _npc_armed and not world.busy():
		_npc_armed = false
		_npc.face(world.player.position - _npc.position)
		world.menus.show_festival_ready(self)



func begin() -> void :
	if mirror or state != "prep":
		return
	left = float(GameData.FESTIVAL_COUNT)

	_mark_spot()
	_set_state("count")
	_send(["count", left, _spot])
	world.play_sound("party_alarm", 0.0, -4.0)




func _mark_spot() -> void :

	Vfx.magic_circle(world.fx_root, _spot, 1.8, Color(1.0, 0.85, 0.3, 0.9), float(GameData.FESTIVAL_COUNT) + 0.3, "mvp_rune", 1.2, -1, true)
	Vfx.column(world.fx_root, _spot, Color(1.0, 0.85, 0.35))
	world.number(_spot + Vector3(0, 1.6, 0), tr("¡Aquí sale el Emperium!"), Color(1.0, 0.85, 0.4), true)


func _start_fight() -> void :
	left = GameData.FESTIVAL_TIME
	checks = 0
	banked = 0.0
	world.reset_meter()
	_set_state("fight")
	_pop(tr("¡YA!"), Color(1.0, 0.95, 0.5), 110)
	world.play_sound("portal_open", 0.0, -2.0)
	_send(["fight", left])
	_rise()



func _rise() -> void :
	var e: = world.spawn_enemy("item_emperium", _spot, true, false, "emperium")
	if e == null:
		return



	e.set_meta("festival", true)
	e.set_meta("steady", true)
	e.is_boss = true
	e._static = true
	e._immovable = true
	e.speed = 0.0
	var size: = minf(GameData.FESTIVAL_SIZE_MAX, GameData.FESTIVAL_SIZE + GameData.FESTIVAL_SIZE_STEP * checks)
	e.set_meta("big", size)
	e.max_hp = GameData.FESTIVAL_BASE_HP * pow(GameData.FESTIVAL_GROW, checks)
	e.hp = e.max_hp
	if e.visual is Node3D:
		(e.visual as Node3D).scale *= size
		if e.visual is RoVisual:
			(e.visual as RoVisual).sprite.no_depth_test = true
			(e.visual as RoVisual).sprite.render_priority = 6
	emperium = e

	e.set_meta("num_lift", GameData.FESTIVAL_NUM_LIFT)
	_hp_frac = 1.0
	var col: = Color(1.0, 0.86, 0.3)
	Vfx.column(world.fx_root, _spot, col)
	Vfx.ring(world.fx_root, _spot + Vector3(0, 0.08, 0), 1.5 + size * 0.4, col, 0.5)
	world.play_sound("portal", 0.05, -8.0, 1.0 + 0.04 * mini(checks, 20))



func _broken() -> void :
	if is_instance_valid(emperium):
		banked += emperium.max_hp
	checks += 1
	var at: = _spot
	Vfx.burst(world.fx_root, at, 2.5 + 0.3 * mini(checks, 20), Color(1.0, 0.86, 0.3))
	Vfx.ray_flash(world.fx_root, at + Vector3(0, 1.0, 0), world.camera.global_basis, Color(1.0, 0.9, 0.5), 1.0 + 0.08 * mini(checks, 20))
	world.spawn_fx("efst_gold_shower", at, 1.0 + 0.05 * mini(checks, 20), 1.0)
	for k in 6:
		var a: = TAU * k / 6.0 + randf() * 0.5
		world.spawn_fx("itempokjuk", at + Vector3(cos(a), 0, sin(a)) * 2.0, 0.6, 0.8)
	world.hud.flash(Color(1.0, 0.85, 0.4), 0.2, 0.18)
	world.play_sound("refine_ok", 0.05, -4.0, minf(2.0, 1.0 + 0.04 * checks))
	world.play_sound("coin3", 0.05, -8.0)
	world.shake(0.15)
	_pop("x%d" % checks, Color(1.0, 0.9, 0.4), 72, 0.25)
	_send(["check", checks, banked])
	_rise()


func _finish() -> void :
	left = 0.0
	if is_instance_valid(emperium) and not emperium.dead:
		banked += maxf(0.0, emperium.max_hp - emperium.hp)
		world.banish_enemy(emperium)
	emperium = null
	_set_state("done")
	_pop(tr("¡TIEMPO!"), Color(1.0, 0.6, 0.35), 96, 0.9)
	world.play_sound("job_levelup", 0.0, -2.0)
	_celebrate()


	var res: = {"score": Leaderboard.big(banked), "dmg": banked, "checks": checks, "party": world.heroes.size() > 1}
	_send(["end", res])
	world.get_tree().create_timer(1.8, false).timeout.connect( func(): world.menus.show_festival_result(res, self))



func _celebrate() -> void :
	for k in 10:
		var a: = TAU * k / 10.0
		world.spawn_fx("itempokjuk", _spot + Vector3(cos(a), 0, sin(a)) * randf_range(2.0, 5.0), 0.8, 0.9)
	world.spawn_fx("efst_gold_shower", _spot, 1.6, 1.0)



func _ambience(delta: float) -> void :
	_fx_t -= delta
	if _fx_t > 0.0:
		return
	_fx_t = randf_range(0.7, 1.6) if state != "fight" else randf_range(1.6, 3.0)
	var a: = randf() * TAU
	var at: = _spot + Vector3(cos(a), 0, sin(a)) * randf_range(6.0, 11.0)
	world.spawn_fx("itempokjuk", at, randf_range(0.6, 1.0), 0.7)
	if randf() < 0.4:
		Vfx.burst(world.fx_root, at + Vector3(0, 0.2, 0), randf_range(1.0, 2.0), 
			[Color(1.0, 0.45, 0.5), Color(0.5, 0.85, 1.0), Color(1.0, 0.9, 0.4), Color(0.7, 1.0, 0.55)].pick_random())




func _send(ev: Array) -> void :
	if not mirror and world.net.is_host():
		world.net.festival_event(ev)



func net_event(ev: Array) -> void :
	if ev.is_empty():
		return
	match str(ev[0]):
		"count":
			left = float(ev[1])

			if ev.size() > 2 and ev[2] is Vector3:
				_spot = ev[2]
				world.number(_spot + Vector3(0, 1.6, 0), tr("¡Aquí sale el Emperium!"), Color(1.0, 0.85, 0.4), true)
			_set_state("count")
			world.play_sound("party_alarm", 0.0, -4.0)
		"fight":
			left = float(ev[1])
			checks = 0
			_shown_score = 0.0
			world.reset_meter()
			_set_state("fight")
			_pop(tr("¡YA!"), Color(1.0, 0.95, 0.5), 110)
			world.play_sound("portal_open", 0.0, -2.0)
		"s":
			_shown_score = float(ev[1])
			_hp_frac = float(ev[2])
			left = float(ev[3])
		"check":
			checks = int(ev[1])
			_shown_score = float(ev[2])
			world.play_sound("refine_ok", 0.05, -4.0, minf(2.0, 1.0 + 0.04 * checks))
			world.spawn_fx("efst_gold_shower", _spot, 1.0, 1.0)
			_pop("x%d" % checks, Color(1.0, 0.9, 0.4), 72, 0.25)
		"end":
			var res: Dictionary = ev[1] if ev.size() > 1 and ev[1] is Dictionary else {}
			_shown_score = float(res.get("dmg", res.get("score", _shown_score)))
			checks = int(res.get("checks", checks))
			left = 0.0
			_set_state("done")
			_pop(tr("¡TIEMPO!"), Color(1.0, 0.6, 0.35), 96, 0.9)
			world.play_sound("job_levelup", 0.0, -2.0)
			_celebrate()
			world.get_tree().create_timer(1.8, false).timeout.connect( func(): world.menus.show_festival_result(res, self))
