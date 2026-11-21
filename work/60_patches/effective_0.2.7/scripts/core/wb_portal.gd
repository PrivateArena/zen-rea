extends Node3D












const REFRESH: = 60.0
const RANGE: = 0.9
const COLOR: = Color(0.95, 0.3, 0.3)

const SCALE: = 1.1



const BOARD_W: = 170
const BOARD_HEAD: = 3.4
const BOARD_GAP: = 6.0
const BOARD_NEAR: = 9.0

var town: Node
var world: World
var state: = {}
var _left: = true
var _t: = 0.0

var _boss: RoVisual
var _boss_id: = ""
var _bob: = 0.0


var _layer: CanvasLayer
var _board: PanelContainer


var _arrow: Polygon2D

var _chest: = {}

static var _claim_asked: = false


func _init(p_town: Node, p_world: World) -> void :
	town = p_town
	world = p_world


func _ready() -> void :

	var glow: = Vfx.ground_glow(self, Vector3.ZERO, 1.5, Color(COLOR, 0.45))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.18, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.45, 0.9).set_trans(Tween.TRANS_SINE)
	Vfx.magic_circle(self, Vector3.ZERO, 1.3, Color(0.55, 0.08, 0.14, 0.7), 0.0, "mvp_rune", 0.35)
	_build_board()

	var kept = Save.setting("wb_chest_show", {})
	if kept is Dictionary and not kept.is_empty():
		_chest = kept
	_ask()




func _build_board() -> void :
	_layer = CanvasLayer.new()

	_layer.layer = 0
	add_child(_layer)
	_arrow = Polygon2D.new()
	_arrow.polygon = PackedVector2Array([Vector2(0, 0), Vector2(16, 0), Vector2(8, 9)])
	_arrow.color = Color(0.85, 0.35, 0.3)
	_arrow.visible = false
	_layer.add_child(_arrow)
	var inner: = Polygon2D.new()
	inner.polygon = PackedVector2Array([Vector2(3, 0), Vector2(13, 0), Vector2(8, 5.6)])
	inner.color = Color(0.09, 0.05, 0.11, 0.92)
	_arrow.add_child(inner)



func _fill_board() -> void :
	if _board != null:
		_board.queue_free()
	var wb_script: GDScript = load("res://scripts/core/world_boss.gd")
	var panel: = PanelContainer.new()
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.05, 0.11, 0.92)
	sb.border_color = Color(0.85, 0.35, 0.3)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(6)
	sb.content_margin_left = 9
	sb.content_margin_right = 9
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 4
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size.x = BOARD_W
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.visible = false
	_layer.add_child(panel)
	_board = panel
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	panel.add_child(col)
	var head: = HBoxContainer.new()
	col.add_child(head)
	var tag: = _text(tr("JEFE DEL MUNDO"), 9, Color(1.0, 0.55, 0.4))
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(tag)
	if state.is_empty():
		col.add_child(_text(tr("Habla con nearQ"), 12, Color(1.0, 0.92, 0.78)))
	elif GameData.wb_locked(state):
		var nx = state.get("next")
		var first: = str(nx.get("boss", "")) if nx is Dictionary else ""
		if GameData.MONSTERS.has(first):
			col.add_child(_text(TranslationServer.translate(str(GameData.MONSTERS[first].name)), 14, Color(1.0, 0.93, 0.8)))
		var wait: = GameData.WB_OPENS - int(state.get("now", Time.get_unix_time_from_system()))
		col.add_child(_text(tr("Se estrena en %s") % wb_script.time_left(wait), 11, Color(1.0, 0.82, 0.4)))
		col.add_child(_text(tr("Prepara tu build"), 9, Color(0.7, 0.66, 0.78)))
		return
	else:
		var mvp: = str(state.get("boss", ""))
		var kills: = int(state.get("kills", 0))
		var need: = maxf(1.0, float(state.get("need", 1.0)))
		var hp: = maxf(0.0, need - float(state.get("into", 0.0)))
		var per: = need / float(GameData.WB_LAYERS)
		var layer: = clampi(ceili(hp / per), 1, GameData.WB_LAYERS)
		head.add_child(_text("x%d" % layer, 11, Color(1.0, 0.82, 0.4)))
		col.add_child(_text(wb_script.boss_name(mvp, kills), 14, Color(1.0, 0.93, 0.8)))
		var bar = wb_script.LayerBar.new()
		bar.custom_minimum_size = Vector2(0, 10)
		bar.layer = layer
		bar.frac = clampf((hp - (layer - 1) * per) / per, 0.0, 1.0)
		col.add_child(bar)
		var secs: = int(state.get("ends", 0)) - int(state.get("now", 0))
		col.add_child(_text(tr("Vida: %d%%  ·  cierra en %s") % [roundi(hp / need * 100.0), wb_script.time_left(secs)], 9, Color(0.86, 0.82, 0.92)))
	col.add_child(_text(tr("Entra al círculo para pelear"), 9, Color(0.7, 0.66, 0.78)))


func _text(s: String, size: int, color: Color) -> Label:
	var l: = Label.new()
	l.text = s
	l.add_theme_font_override("font", Hud.RO_FONT_BOLD)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.06))
	l.add_theme_constant_override("outline_size", 3)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l




func _ask() -> void :
	_t = REFRESH
	world.board.wb_state( func(s: Dictionary):
		if not is_instance_valid(self):
			return
		if s.is_empty() and GameData.has_meta("wb_fake"):
			s = GameData.get_meta("wb_fake")
		show_state(s)
		_maybe_claim())


func show_state(s: Dictionary) -> void :
	state = s


	var shown: = str(s.get("boss", ""))
	if GameData.wb_locked(s) and s.get("next") is Dictionary and GameData.MONSTERS.has(str(s.next.get("boss", ""))):
		shown = str(s.next.boss)


	if GameData.MONSTERS.has(shown):
		GameData.set_meta("wb_boss_now", shown)
		GameData.set_meta("wb_state_cache", s)
	_show_boss(shown)
	_fill_board()





func _place_board() -> void :
	if _board == null:
		return
	var cam: = get_viewport().get_camera_3d()


	var head: = global_position + Vector3(0, BOARD_HEAD, 0)
	if _boss != null and is_instance_valid(_boss) and cam != null:

		head = _boss.global_position + RoVisual.lift + cam.global_transform.basis.y * (_boss.height() * SCALE * 0.8)
	var hero: Node3D = town.hero
	var far: bool = hero == null or Vector2(hero.position.x - global_position.x, hero.position.z - global_position.z).length() > BOARD_NEAR
	if cam == null or far or cam.is_position_behind(head) or _window_open():
		_board.visible = false
		_arrow.visible = false
		return
	var at: = cam.unproject_position(head)
	_board.reset_size()
	var pos: = at - Vector2(_board.size.x * 0.5, _board.size.y + BOARD_GAP)

	var view: = get_viewport().get_visible_rect().size
	pos.x = clampf(pos.x, 8.0, maxf(8.0, view.x - _board.size.x - 8.0))
	pos.y = clampf(pos.y, 44.0, maxf(44.0, view.y - _board.size.y - 8.0))
	_board.position = pos.round()
	_board.visible = true

	_arrow.position = Vector2(clampf(at.x - 8.0, pos.x + 10.0, pos.x + _board.size.x - 26.0), pos.y + _board.size.y - 1.0).round()
	_arrow.visible = true



func _window_open() -> bool:
	return not (str(world.menus._mode) in ["town", "closed"])



func _show_boss(id: String) -> void :
	if id == _boss_id or not GameData.MONSTERS.has(id):
		return
	_boss_id = id
	if _boss != null:
		_boss.queue_free()
		_boss = null
	var spr: = RoAssets.sprite([id])
	if spr == null:
		return
	_boss = RoVisual.new()
	add_child(_boss)
	_boss.setup(spr, COLOR, 40)
	_boss.dir = 0
	_boss.hold_idle = true
	_boss.play(RoVisual.MOB_IDLE)
	_boss.scale = Vector3.ONE * SCALE




func _maybe_claim() -> void :
	if _claim_asked:
		return
	_claim_asked = true
	world.board.wb_claim( func(r: Dictionary):
		if r.is_empty() or not bool(r.get("ok", false)):
			return

		world.menus.wb_chest_take(r)
		_chest = r)


func _process(delta: float) -> void :
	_place_board()
	if _boss != null:
		_bob += delta
		_boss.position.y = 0.3 + sin(_bob * 1.6) * 0.1
	_t -= delta
	if _t <= 0.0:
		_ask()
	if not _chest.is_empty() and not _window_open():
		var c: = _chest
		_chest = {}
		world.menus.show_wb_chest(c)
	var hero: Node3D = town.hero
	if hero == null or _window_open():
		return
	var d: = Vector2(hero.position.x - global_position.x, hero.position.z - global_position.z).length()
	if d > RANGE * 2.0:
		_left = true
	elif d <= RANGE and _left:
		_left = false
		world.mouse_walk.reset()
		world.play_sound("portal", 0.0, 0.0)
		world.menus.show_world_boss(str(town.class_id), state)
