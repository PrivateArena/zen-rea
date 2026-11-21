class_name Hud
extends CanvasLayer



const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const RO_FONT = preload("res://assets/ro/fonts/SCDream4.otf")
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")

const SLOT: = 30.0
const ChestPointer = preload("res://scripts/ui/chest_pointer.gd")
const RaidAlerts = preload("res://scripts/ui/raid_alerts.gd")
const Oaths = preload("res://scripts/core/oaths.gd")

const OATH_RED: = Color(0.72, 0.1, 0.14)

var world: World
var _basic: RoBasicWindow
var _root: Control

var danger: HeroDanger
var _cards_row: Control
var _cards_title: Label



const CARDS_COLS: = 6
const CARDS_ROWS: = 2
const CARD_SIZE: = Vector2(22, 31)

var _cards_win: Control

var _quiver_win: Control
var _quiver_icon: TextureRect
var _quiver_label: Label
var _quiver_shown: = ""
var _quiver_title: Label

var _meter_win: Control

var _meter_party_set: = false
var _meter_title: Label
var _meter: DamageMeter

var _meter_press: = Vector2.INF
var _meter_drag: = false
var _meter_off: = Vector2.ZERO
const METER_MODES: = ["party", "damage", "dps", "boss", "taken", "heal"]
var _cards_count: = -1
var _timer: Label

var _oath_row: HBoxContainer
var _mvp_timer: Label

var _tower_loot: Label
var _karma_bar: Karma.Bar
var _time_window: Control
var _time_title: Label
var _minimap: RoMinimap

var _sky: Label
var _coords: Label
var _boss_panel: Control
var _boss_bar: ProgressBar
var _boss_stagger_row: HBoxContainer
var _boss_stagger: ProgressBar
var _boss_stagger_fill: StyleBoxFlat
var _boss_stagger_label: Label
const STAGGER_GOLD: = Color(1.0, 0.78, 0.22)

var _boss_face: TextureRect
var _boss_face_id: = ""
const BOSS_BAR_W: = 300
const BOSS_FACE: = 40.0

var _boss_marks: HBoxContainer
var _boss_marks_key: = ""
var _boss_label: Label


var _boss_elem: Label
var _boss_title: Label
var _boss_fury: Label

var _ymir_veil: TextureRect
var _skill_window: Control
var _skill_title: Label
var _skill_row: HBoxContainer
var _skill_slots: Array[Dictionary] = []
var _skill_signature: = ""

var _passive_window: Control
var _passive_title: Label
var _passive_row: HBoxContainer



var _pact_row: GridContainer

var _party: PartyFrames
var _training: TrainingPanel


var _buff_sig: = ""

var _buff_check: = 0.0
var _basic_sig: Array = []
var _quest_sig: = ""
var _buff_timers: = {}
var _held_button: Control
var _chest_button: Control
var _chest_count: Label
var _held_count: Label
var _held_text: Label

var _gods_shown: = 0
const BUFF_SIZE: = 20
const BUFF_GAP: = 3
const BUFF_COLUMNS: = 12
var _xp: ProgressBar
var _announce: VBoxContainer
var _announce_title: Label
var _announce_sub: Label
var _announce_tween: Tween
var _chests: Control

var alerts: Control
var _flash: ColorRect

var _powers: Label

var _refine_hint: PanelContainer


var _quest_win: Control
var _quest_name: Label
var _quest_goal: Label
var _quest_count: Label
var _quest_gauge: HBoxContainer
var _quest_caption: Label
var _quest_bar: ProgressBar
var _quest_value: Label
var _quest_clock: Label
var _quest_kind: = ""
var _refine_hint_text: Label


func _ready() -> void :
	layer = 5
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.color = Color(1, 1, 1, 0)
	_root.add_child(_flash)
	danger = HeroDanger.new()
	_root.add_child(danger)
	_build_plate()
	_build_top_center()
	_build_bottom()
	_build_announce()
	alerts = RaidAlerts.new()
	_root.add_child(alerts)

	_chests = ChestPointer.new()
	_root.add_child(_chests)




func _build_plate() -> void :
	_basic = RoBasicWindow.new()
	_basic.position = Vector2(8, 8)
	_basic.menu_pressed.connect(_on_basic_menu)
	_root.add_child(_basic)
	var cw: = UiStyles.hud_window(tr("Cartas"), RO_FONT_BOLD)
	_cards_win = cw.root
	_cards_title = cw.title


	var scroll: = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(CARDS_COLS * (CARD_SIZE.x + 3) + 4, CARDS_ROWS * (CARD_SIZE.y + 3))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	cw.body.add_child(scroll)
	_cards_row = GridContainer.new()
	(_cards_row as GridContainer).columns = CARDS_COLS
	_cards_row.add_theme_constant_override("h_separation", 3)
	_cards_row.add_theme_constant_override("v_separation", 3)
	scroll.add_child(_cards_row)
	_cards_win.visible = false
	_root.add_child(_cards_win)


func _build_top_center() -> void :

	var tw: = UiStyles.hud_window(tr("Prontera Field"), RO_FONT_BOLD)
	_time_window = tw.root
	_time_title = tw.title
	_minimap = RoMinimap.new()
	_minimap.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tw.body.add_child(_minimap)
	_coords = _ro_label("", 11)
	_coords.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tw.body.add_child(_coords)
	_sky = _ro_label("", 11)
	_sky.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tw.body.add_child(_sky)
	_time_window.custom_minimum_size.x = 0
	_root.add_child(_time_window)
	_timer = _ro_label(tr("Tiempo  %s") % "00:00", 13, true)
	tw.body.add_child(_timer)
	_oath_row = HBoxContainer.new()
	_oath_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_oath_row.add_theme_constant_override("separation", 3)
	_oath_row.visible = false
	tw.body.add_child(_oath_row)
	_mvp_timer = _ro_label("", 11)
	_mvp_timer.add_theme_color_override("font_color", Color(0.55, 0.12, 0.12))
	tw.body.add_child(_mvp_timer)

	_tower_loot = _ro_label("", 11)
	_tower_loot.add_theme_color_override("font_color", Color(0.4, 0.25, 0.7))
	_tower_loot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tower_loot.mouse_filter = Control.MOUSE_FILTER_PASS
	_tower_loot.visible = false
	tw.body.add_child(_tower_loot)

	_karma_bar = Karma.Bar.new()
	tw.body.add_child(_karma_bar)


	var mw: = UiStyles.hud_window(tr("Daño"), RO_FONT_BOLD)
	_meter_win = mw.root
	_meter_title = mw.title
	_meter = DamageMeter.new()
	_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mw.body.add_child(_meter)
	_meter_win.visible = false
	_root.add_child(_meter_win)


	_meter_win.mouse_filter = Control.MOUSE_FILTER_STOP
	_meter_win.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_meter_win.tooltip_text = tr("Clic: detalles (M)  ·  clic derecho: cambiar vista  ·  arrastra para moverlo")
	_meter_win.gui_input.connect(_on_meter_input)
	_meter.mode = str(Save.setting("meter_mode", "damage"))

	var qw: = UiStyles.hud_window(tr("Quest"), RO_FONT_BOLD)
	_quest_win = qw.root
	_quest_name = _ro_label("", 13, true)
	_quest_name.add_theme_color_override("font_color", QUEST_NAME_COLOR)
	_quest_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	qw.body.add_child(_quest_name)
	var goal: = HBoxContainer.new()
	goal.add_theme_constant_override("separation", 6)
	goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	qw.body.add_child(goal)
	_quest_goal = _ro_label("", 12)
	_quest_goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_quest_goal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal.add_child(_quest_goal)
	_quest_count = _ro_label("", 13, true)
	_quest_count.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	goal.add_child(_quest_count)
	_quest_gauge = HBoxContainer.new()
	_quest_gauge.add_theme_constant_override("separation", 5)
	_quest_gauge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	qw.body.add_child(_quest_gauge)
	_quest_caption = _ro_label("", 11, true)
	_quest_gauge.add_child(_quest_caption)
	_quest_bar = UiStyles.hud_gauge("blue", 60)
	_quest_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quest_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_quest_gauge.add_child(_quest_bar)
	_quest_value = _ro_label("", 11)
	_quest_gauge.add_child(_quest_value)
	_quest_clock = _ro_label("", 13, true)
	qw.body.add_child(_quest_clock)
	_quest_win.visible = false
	_root.add_child(_quest_win)




	var boss: = VBoxContainer.new()
	boss.add_theme_constant_override("separation", 4)
	boss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_panel = boss
	_boss_panel.visible = false
	_root.add_child(_boss_panel)
	var win: = UiStyles.hud_window(tr("Boss"), RO_FONT_BOLD)
	_boss_title = win.title
	win.root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	boss.add_child(win.root)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	win.body.add_child(row)
	_boss_face = TextureRect.new()
	_boss_face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_boss_face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_boss_face.custom_minimum_size = Vector2(BOSS_FACE, BOSS_FACE)
	_boss_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_boss_face)
	var body: = VBoxContainer.new()
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_theme_constant_override("separation", 2)
	row.add_child(body)
	var gauge: = HBoxContainer.new()
	gauge.add_theme_constant_override("separation", 8)
	body.add_child(gauge)
	_boss_bar = UiStyles.round_gauge("red", BOSS_BAR_W, 14)
	_boss_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	gauge.add_child(_boss_bar)
	_boss_label = _ro_label("", 11)
	_boss_label.custom_minimum_size.x = 34
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gauge.add_child(_boss_label)


	_boss_stagger_row = HBoxContainer.new()
	_boss_stagger_row.add_theme_constant_override("separation", 8)
	_boss_stagger_row.visible = false
	body.add_child(_boss_stagger_row)
	_boss_stagger = ProgressBar.new()
	_boss_stagger.show_percentage = false
	_boss_stagger.max_value = 1.0
	_boss_stagger.custom_minimum_size = Vector2(BOSS_BAR_W, 6)
	_boss_stagger.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sg_bg: = StyleBoxFlat.new()
	sg_bg.bg_color = Color(0.16, 0.17, 0.25)
	sg_bg.set_corner_radius_all(3)
	_boss_stagger_fill = StyleBoxFlat.new()
	_boss_stagger_fill.bg_color = STAGGER_GOLD
	_boss_stagger_fill.set_corner_radius_all(3)
	_boss_stagger.add_theme_stylebox_override("background", sg_bg)
	_boss_stagger.add_theme_stylebox_override("fill", _boss_stagger_fill)
	_boss_stagger_row.add_child(_boss_stagger)
	_boss_stagger_label = _ro_label("", 9, true)
	_boss_stagger_label.custom_minimum_size.x = 34
	_boss_stagger_row.add_child(_boss_stagger_label)
	_boss_elem = _ro_label("", 10)
	_boss_elem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_elem.add_theme_color_override("font_color", Color(0.25, 0.28, 0.45))
	body.add_child(_boss_elem)

	_boss_fury = _ro_label("", 11, true)
	_boss_fury.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


	for line in [_boss_elem, _boss_fury]:
		line.custom_minimum_size.x = BOSS_BAR_W
		line.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_boss_fury.visible = false
	body.add_child(_boss_fury)
	_boss_marks = HBoxContainer.new()
	_boss_marks.alignment = BoxContainer.ALIGNMENT_CENTER
	_boss_marks.add_theme_constant_override("separation", 4)
	_boss_marks.visible = false
	boss.add_child(_boss_marks)


func _build_bottom() -> void :

	var win: = UiStyles.hud_window(tr("Skill"), RO_FONT_BOLD)
	_skill_window = win.root
	_skill_title = win.title
	_root.add_child(_skill_window)
	_skill_row = HBoxContainer.new()
	_skill_row.add_theme_constant_override("separation", 3)

	_skill_row.alignment = BoxContainer.ALIGNMENT_CENTER
	win.body.add_child(_skill_row)
	var pw: = UiStyles.hud_window(tr("Pasivas"), RO_FONT_BOLD)
	_passive_window = pw.root
	_passive_title = pw.title
	_passive_window.visible = false
	_root.add_child(_passive_window)
	_passive_row = HBoxContainer.new()
	_passive_row.add_theme_constant_override("separation", 3)
	_passive_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pw.body.add_child(_passive_row)
	_pact_row = GridContainer.new()
	_pact_row.columns = BUFF_COLUMNS
	_pact_row.add_theme_constant_override("h_separation", BUFF_GAP)
	_pact_row.add_theme_constant_override("v_separation", BUFF_GAP)
	_pact_row.visible = false
	_root.add_child(_pact_row)
	_party = PartyFrames.new()
	_party.visible = false
	_root.add_child(_party)
	_training = TrainingPanel.new()
	_training.visible = false
	_root.add_child(_training)



	var pill: = _held_pill("sage_start", tr("Abrir  (Tab)"), func(): world.open_held_levels())
	_held_button = pill.root
	_held_count = pill.count
	_held_text = pill.text
	_held_text.text = tr("listas para elegir")
	_root.add_child(_held_button)



	var cpill: = _held_pill("chest", tr("Abrir  (Shift+Tab)"), func(): world.open_held_chests())
	_chest_button = cpill.root
	_chest_count = cpill.count
	(cpill.text as Label).text = tr("para abrir")
	_root.add_child(_chest_button)

	var gauge: Control = (load("res://scripts/ui/overload_gauge.gd") as GDScript).new()
	gauge.set("world", world)
	gauge.set("hud", self)
	_root.add_child(gauge)
	var qw: = UiStyles.hud_window(tr("Carcaj"), RO_FONT_BOLD)
	_quiver_win = qw.root
	_quiver_title = qw.title
	_quiver_win.visible = false

	_quiver_win.mouse_filter = Control.MOUSE_FILTER_STOP
	_quiver_win.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			if world.player != null and world.player.can_switch_ammo():
				world.switch_arrow(1)
			_quiver_win.accept_event())
	var qrow: = HBoxContainer.new()
	qrow.add_theme_constant_override("separation", 4)
	qw.body.add_child(qrow)
	_quiver_icon = UiKit.icon_rect(null, 24)
	qrow.add_child(_quiver_icon)
	_quiver_label = _ro_label("", 10)
	_quiver_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	qrow.add_child(_quiver_label)
	_root.add_child(_quiver_win)

	_xp = UiStyles.hud_gauge("blue", 100, 9.0)
	_xp.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_xp.offset_left = 8
	_xp.offset_right = -8
	_xp.offset_top = -15
	_xp.offset_bottom = -6


	var fill: = _xp.get_theme_stylebox("fill").duplicate()
	if fill is StyleBoxTexture:
		(fill as StyleBoxTexture).modulate_color = Color(0.8, 0.88, 1.0)
	_xp.add_theme_stylebox_override("fill", fill)


	_xp_chip = UiStyles.hud_gauge("blue", 100, 9.0)
	_xp_chip.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_xp_chip.offset_left = 8
	_xp_chip.offset_right = -8
	_xp_chip.offset_top = -15
	_xp_chip.offset_bottom = -6
	var chip: = _xp_chip.get_theme_stylebox("fill").duplicate()
	if chip is StyleBoxTexture:
		(chip as StyleBoxTexture).modulate_color = Color(1.6, 1.7, 1.9)
	elif chip is StyleBoxFlat:
		(chip as StyleBoxFlat).bg_color = Color(0.85, 0.95, 1.0)
	_xp_chip.add_theme_stylebox_override("fill", chip)
	var clear: = StyleBoxEmpty.new()
	_xp.add_theme_stylebox_override("background", clear)

	_xp_spark = CPUParticles2D.new()
	_xp_spark.amount = 26
	_xp_spark.lifetime = 0.7
	_xp_spark.emitting = false
	_xp_spark.texture = RoAssets.radial(Color.WHITE, 16)
	_xp_spark.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_xp_spark.emission_rect_extents = Vector2(6, 3)
	_xp_spark.direction = Vector2(0, -1)
	_xp_spark.spread = 35.0
	_xp_spark.gravity = Vector2(0, 30)
	_xp_spark.initial_velocity_min = 25.0
	_xp_spark.initial_velocity_max = 75.0
	_xp_spark.scale_amount_min = 0.4
	_xp_spark.scale_amount_max = 0.8
	var ramp: = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(0.85, 0.95, 1.0, 1.0), Color(0.55, 0.75, 1.0, 0.0)])
	_xp_spark.color_ramp = ramp
	var add: = CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_xp_spark.material = add
	_root.add_child(_xp_chip)
	_root.add_child(_xp)
	_root.add_child(_xp_spark)





var _hover: PanelContainer
var _hover_owner: Control


func _bind_hover(ctrl: Control, build: Callable) -> void :
	ctrl.mouse_entered.connect( func(): _show_hover(ctrl, build.call()))
	ctrl.mouse_exited.connect( func():
		if _hover_owner == ctrl:
			_hide_hover())
	ctrl.tree_exiting.connect( func():
		if _hover_owner == ctrl:
			_hide_hover())




func _show_hover(ctrl: Control, info: Dictionary) -> void :
	_hide_hover()
	_hover_owner = ctrl
	_hover = HoverCard.build(info)
	_hover.set_meta("info", info)
	_root.add_child(_hover)
	var k: = _skill_window.scale.x
	_hover.scale = Vector2(k, k)
	_hover.modulate.a = 0.0
	_hover.visible = false
	_place_hover.call_deferred(ctrl)


func _place_hover(ctrl: Control) -> void :
	if _hover == null or not is_instance_valid(ctrl):
		return
	var view: = get_viewport().get_visible_rect().size


	if not _hover.visible:
		var wider: = HoverCard.wider_card(_hover, _hover.get_meta("info", {}), view)
		if wider != null:
			wider.set_meta("info", _hover.get_meta("info", {}))
			wider.scale = _hover.scale
			wider.modulate.a = 0.0
			wider.visible = false
			_hover.queue_free()
			_hover = wider
			_root.add_child(_hover)
			_place_hover.call_deferred(ctrl)
			return
	var r: = ctrl.get_global_rect()
	var sz: = _hover.get_combined_minimum_size() * _hover.scale
	var pos: = Vector2(r.position.x + r.size.x * 0.5 - sz.x * 0.5, r.position.y - sz.y - 6)
	if pos.y < 4:

		pos = Vector2(r.end.x + 6, r.position.y)
	pos.x = clampf(pos.x, 4, view.x - sz.x - 4)
	pos.y = clampf(pos.y, 4, view.y - sz.y - 4)
	_hover.position = pos.floor()
	if not _hover.visible:
		_hover.visible = true
		_hover.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(_hover, "modulate:a", 1.0, 0.08)


func _hide_hover() -> void :
	if _hover != null and is_instance_valid(_hover):
		_hover.queue_free()
	_hover = null
	_hover_owner = null


func _skill_hover(id: String) -> Dictionary:
	var p: = world.player
	var def: Dictionary = GameData.SKILLS[id]
	var lv: = int(p.skills[id].level) if p.skills.has(id) else 1
	var passive: = Player.is_passive(id)
	var evolved: bool = def.get("evolved", false)
	var col: Color = GameData.LEGENDARY_COLOR if evolved else (Color(0.55, 0.75, 1.0) if passive else def.get("color", Color(0.95, 0.8, 0.4)))
	var shown_lv: = lv + 9 if evolved else lv
	var tag: = (tr("Evolución") if evolved else (tr("Pasiva") if passive else (tr("Apoyo") if Player.is_support(id) else tr("Habilidad"))))\
	+ "  ·  " + tr("Nv %d") % shown_lv
	if not evolved and lv <= GameData.MAX_SKILL_LEVEL:
		tag += " / %d" % GameData.MAX_SKILL_LEVEL


	var lines: = []
	var grows: = ""
	var el: = ""
	var v: = func(f: String) -> float: return GameData.skill_value(id, f, lv)
	if def.has("damage"):
		lines.append([tr("Daño"), "%d" % roundi(v.call("damage") * p.dmg_mult * p.skill_mult_for(id))])
	if def.has("damage") or GameData.SKILL_SCALE.has(id.trim_suffix("_x")):
		grows = p.scaling_text(id)
	elif str(def.type) == "buff" and def.has("bonus"):

		grows = GameData.support_scaling(id)

	if def.has("stance_chance"):
		lines.append([tr("Postura"), "%d%%" % roundi(minf(1.0, v.call("stance_chance") + float(p.effects.get("stance", 0.0))) * 100.0)])
	if def.has("count") and v.call("count") > 1.0:
		lines.append([tr("Cantidad"), str(int(v.call("count")))])
	if def.has("area"):
		lines.append([tr("Área"), str(snappedf(v.call("area") * p.area_mult, 0.1))])
	if def.has("amount"):
		lines.append([tr("Curación") if def.type == "heal" else tr("Barrera"), "%d  ·  %s" % [roundi(v.call("amount")), GameData.support_scaling(id)]])
	if def.has("heal_amount"):
		lines.append([tr("Curación"), "%d  ·  %s" % [roundi(v.call("heal_amount")), GameData.support_scaling(id)]])
	if def.has("cooldown") and not passive:

		var cd: float = v.call("cooldown") * p.cd_for(id)
		lines.append([tr("Recarga"), ("%.2f s" if cd < 1.0 else "%.1f s") % cd])
	if GameData.skill_has_element(id):
		el = Skills.shown_element(p, def)
	if def.has("status"):
		lines.append([tr("Estado"), tr(str(GameData.STATUS_NAMES[def.status])), Color(0.85, 0.75, 1.0)])
	if def.has("burn_chance"):
		lines.append([tr("Quemadura"), "%d%%" % roundi(float(def.burn_chance) * 100.0), GameData.BURN_COLOR])
	if def.has("bleed_chance"):
		lines.append([tr("Sangrado"), "%d%%" % roundi(float(def.bleed_chance) * 100.0), GameData.BLEED_COLOR.lightened(0.3)])

	if GameData.PUNISH_SKILLS.has(id):
		lines.append([tr("Castigo"), tr("+%d%% a un jefe aturdido") % roundi(GameData.PUNISH_DMG * 100.0), GameData.PUNISH_COLOR])
	var foot: = []


	if p.skills.has(id):


		var now: String = world.menus._skill_diff(id, lv, lv, true)
		if now != "":
			foot.append([tr("Ahora: %s") % now.replace("\n", "  ·  "), Color(0.5, 0.95, 0.55)])
		elif def.has("bonus"):
			foot.append_array(_buff_now(id, false))
	if GameData.EVOLUTIONS.has(id):
		var pas: = str(GameData.EVOLUTIONS[id].passive)
		var ok_lv: = lv >= GameData.MAX_SKILL_LEVEL
		var ok_pas: = p.skills.has(pas)
		var c: = Color(0.5, 0.95, 0.55) if ok_lv and ok_pas else Color(1.0, 0.8, 0.4)
		foot.append([tr("Evoluciona a %s: Nv 5 %s  ·  pasiva %s %s") % [tr(str(GameData.SKILLS[GameData.EVOLUTIONS[id].to].name)), 
			"✓" if ok_lv else "✗", tr(str(GameData.SKILLS[pas].name)), "✓" if ok_pas else "✗"], c])
	for sid in GameData.EVOLUTIONS:
		if str(GameData.EVOLUTIONS[sid].passive) == id and p.skill_pool().has(sid):
			foot.append([tr("Permite evolucionar: %s (Nv 5)") % tr(str(GameData.SKILLS[sid].name)), Color(1.0, 0.8, 0.4)])
	return {"icon": UiKit.skill_icon(id), "title": tr(str(def.name)), "color": col, "tag": tag, 
		"lines": lines, "chips": HoverCard.skill_chips(id, grows, el, Skills.arrow_chip(p, def)), 
		"desc": tr(GameData.skill_desc(id, p.def.get("custom", false))), "foot": foot}



func _dish_slot(id: String) -> PanelContainer:
	var r: Dictionary = GameData.RECIPES[id]
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(20, 20)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.985, 0.99, 1.0, 0.95)
	box.border_color = Color(1.0, 0.8, 0.35)
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	_bind_hover(slot, func(): return {"icon": _dish_icon(str(r.icon)), "title": tr(str(r.name)), 
		"color": Color(1.0, 0.8, 0.35), "tag": tr("Plato de Klaws"), "desc": tr(str(r.desc)), "foot": []})
	var tex: = _dish_icon(str(r.icon))
	if tex != null:
		var ic: = UiKit.icon_rect(tex, 16)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(ic)
	return slot


func _dish_icon(icon: String) -> Texture2D:
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % icon
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


func _pact_hover(id: String) -> Dictionary:
	var d: Dictionary = GameData.PACTS[id]
	var foot: = []
	var p: = world.player
	if id == "solitude":
		foot.append([tr("Ranuras libres ahora: %d") % p.free_slot_bonus(), Color(0.5, 0.95, 0.55)])
	elif id == "devotion":
		foot.append([tr("Ranuras libres ahora: %d") % p.devotion_slots(), Color(0.5, 0.95, 0.55)])
	elif id == "obsession":
		var n: = p.attack_skill_count()
		foot.append([tr("Activo: una sola habilidad de ataque") if n == 1 else tr_n("Inactivo: llevas %d habilidad de ataque", "Inactivo: llevas %d habilidades de ataque", n) % n, 
			Color(0.5, 0.95, 0.55) if n == 1 else Color(0.7, 0.72, 0.8)])
	elif id == "vengeance":
		foot.append([tr("Ahora: +%d%% de daño") % roundi((p.vengeance_mult() - 1.0) * 100.0), Color(1.0, 0.6, 0.45)])
	return {"icon": UiKit.skill_icon(str(d.icon)), "title": tr(str(d.name)), "color": Color(0.9, 0.3, 0.32), 
		"tag": tr("Pacto de Gray"), "desc": tr(str(d.desc)), "foot": foot}


func _card_hover(id: String, count: int) -> Dictionary:
	var c: Dictionary = GameData.CARDS[id]
	var slot: = str(c.get("type", ""))
	var tag: = tr("Carta") + (("  ·  " + tr(GameData.SLOT_NAMES[slot])) if GameData.SLOT_NAMES.has(slot) else "")
	if count > 1:
		tag += "  ·  x%d" % count
	var foot: = []
	if world.player.equipment.card_bag.has(id):
		foot.append([tr("En la bolsa: insértala con Q"), Color(1.0, 0.8, 0.4), true])



	foot.append_array(world.menus._proc_live(c))
	foot.append([tr("Clic: ver carta"), Color(0.6, 0.65, 0.78), true])
	return {"icon": RoAssets.card_art(id), "icon_size": 44, "title": tr(str(c.name)), "color": Color(0.95, 0.8, 0.4), 
		"tag": tag, "chips": HoverCard.gear_chips(c), "desc": tr(str(c.desc)), "foot": foot}


func _ro_label(text: String, size: int, bold: = false) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", RO_FONT_BOLD if bold else RO_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color.BLACK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _build_announce() -> void :
	_announce = VBoxContainer.new()
	_announce.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_announce.offset_top = 120
	_announce.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_announce)

	_announce_title = _ro_label("", 22, true)
	_announce_title.add_theme_color_override("font_outline_color", Color.BLACK)
	_announce_title.add_theme_constant_override("outline_size", 4)
	_announce_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_announce.add_child(_announce_title)
	_announce_sub = _ro_label("", 14)
	_announce_sub.add_theme_color_override("font_color", Color.WHITE)
	_announce_sub.add_theme_color_override("font_outline_color", Color.BLACK)
	_announce_sub.add_theme_constant_override("outline_size", 3)
	_announce_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_announce.add_child(_announce_sub)
	_announce.modulate.a = 0.0




func bind(p_world: World) -> void :
	danger.world = p_world
	world = p_world
	_karma_bar.world = p_world
	_party.setup(p_world)
	_training.setup(p_world)
	if world == null or world.player == null:
		return
	refresh_altars()
	_basic.display_name = Save.char_name(world.player.class_id)
	_basic.job = world.player.job_name()
	_basic.rebirth_lv = Save.rebirth_lv(world.player.class_id)
	_basic.gold_name = (world.player.profile.get("looks", []) as Array).has("valhalla")
	_minimap.world = world
	_chests.world = world
	alerts.world = world


	_time_title.text = tr(str(world.stage.name))
	_time_window.reset_size()
	_skill_signature = ""
	_cards_count = -1
	_boss_panel.visible = false
	_announce.modulate.a = 0.0
	_refresh_skills()
	_refresh_pacts()
	_refresh_oaths()




func _refresh_oaths() -> void :
	for c in _oath_row.get_children():
		_oath_row.remove_child(c)
		c.queue_free()
	var sworn: = Oaths.sworn_list(world.oaths)
	_oath_row.visible = not sworn.is_empty()
	if sworn.is_empty():
		return
	var n: = _ro_label(tr("Juramento %d") % GameData.oath_points(world.oaths), 11, true)
	n.add_theme_color_override("font_color", OATH_RED)
	n.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	n.mouse_filter = Control.MOUSE_FILTER_STOP
	var pts: = GameData.oath_points(world.oaths)
	_bind_hover(n, func(): return {"icon": UiKit.skill_icon("kyrie_eleison"), "title": tr("Juramento %d") % pts, "color": OATH_RED, 
		"tag": tr("Juramentos de esta partida"), 
		"desc": tr("Castigos elegidos en Infierno 15. Cada punto sube un %s%% tu puntaje en el ranking.") % str(snappedf((Oaths.score_mult(1) - 1.0) * 100.0, 0.1)), 
		"foot": [[tr("Puntaje x%s") % str(snappedf(Oaths.score_mult(pts), 0.01)), Color(1.0, 0.8, 0.35)]]})
	_oath_row.add_child(n)
	for pair in sworn:
		_oath_row.add_child(_oath_slot(pair[0], int(pair[1])))
	_time_window.reset_size()


func _oath_slot(o: Dictionary, r: int) -> Control:
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.94, 0.94, 0.95)
	box.border_color = OATH_RED.lightened(0.25)
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	box.shadow_color = Color(OATH_RED, 0.35)
	box.shadow_size = 2
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var tex: = Oaths.icon(o)
	if tex != null:
		var ic: = UiKit.icon_rect(tex, 16)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(ic)
	if (o.pts as Array).size() > 1:
		var l: = _ro_label("I".repeat(r), 8, true)
		l.add_theme_color_override("font_color", Color.WHITE)
		l.add_theme_color_override("font_outline_color", Color(0.35, 0.0, 0.02))
		l.add_theme_constant_override("outline_size", 3)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(l)
	_bind_hover(slot, func(): return {"icon": tex, "title": tr(str(o.name)), "color": OATH_RED, 
		"tag": Oaths.rank_tag(o, r), "desc": tr(str(o.desc)), 
		"foot": [[Oaths.rank_text(o, r), Color(1.0, 0.55, 0.5)]]})
	return slot


func _refresh_pacts() -> void :




	var now: = _buffs_now()
	_buff_sig = "" if now.is_empty() else str(now)
	for child in _pact_row.get_children():
		_pact_row.remove_child(child)
		child.queue_free()
	var pacts: Array = world.player.pacts
	var dishes: Array = world.player.dishes
	var gods: Array = (world.altars.taken if world.altars != null else []).duplicate()

	if world.karma != null:
		gods.append_array(world.karma.my_altars)
	_pact_row.visible = not pacts.is_empty() or not dishes.is_empty() or not gods.is_empty() or _buff_sig != ""
	for d in dishes:
		_pact_row.add_child(_dish_slot(str(d)))
	for id in pacts:
		var d: Dictionary = GameData.PACTS[id]
		var slot: = PanelContainer.new()
		slot.custom_minimum_size = Vector2(20, 20)
		var box: = StyleBoxFlat.new()
		box.bg_color = Color(0.985, 0.99, 1.0, 0.95)
		box.border_color = Color(0.9, 0.3, 0.32)
		box.set_border_width_all(1)
		box.set_corner_radius_all(5)
		box.anti_aliasing = true
		box.set_content_margin_all(1)
		box.shadow_color = Color(0.9, 0.2, 0.2, 0.45)
		box.shadow_size = 3
		slot.add_theme_stylebox_override("panel", box)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var pact_id: String = id
		_bind_hover(slot, func(): return _pact_hover(pact_id))
		var tex: = UiKit.skill_icon(str(d.icon))
		if tex != null:
			var r: = UiKit.icon_rect(tex, 16)
			r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(r)
		_pact_row.add_child(slot)
	_add_god_slots(gods)
	_add_buff_slots()
	_pact_row.reset_size.call_deferred()




func _buffs_now() -> Array:
	var out: Array = []
	var p: = world.player
	for id in p.skills:
		if str(GameData.SKILLS[id].type) == "buff":
			out.append(["skill", str(id)])
	for id in p.powers:
		if _power_icon(str(id)) != null:
			out.append(["power", str(id)])

	for id in p.party_buffs:
		if not p.skills.has(id) and GameData.SKILLS.has(id):
			out.append(["ally", str(id)])


	if world.tower != null:
		var times: = {}
		for id in world.tower.wheel_buffs:
			times[str(id)] = int(times.get(str(id), 0)) + 1
		for id in times:
			out.append(["wheel", id, int(times[id])])
		for c in world.tower.wheel_curses:
			out.append(["curse", str(c.id), int(c.left)])

	if p.doom:
		out.append(["doom"])

	if p.pride:
		out.append(["pride"])

	if not Uniques.queen_state(p).is_empty():
		out.append(["queen"])



	if p.hel_marks > 0:
		out.append(["karma", "hel_mark", p.hel_marks])
	if p.feathers > 0:
		out.append(["karma", "feather", p.feathers])

	if world.tower != null and is_instance_valid(world.tower) and int(world.tower.floor) > 1:
		out.append(["karma", "tower_floor", int(world.tower.floor)])
	var k: Karma = world.karma
	if world.tower != null or world.festival_mode:


		var bb = p.get_meta("build_boon", [])
		if bb is Array and bb.size() == 2 and str(bb[0]) != "" and int(bb[1]) > 0:
			out.append(["karma", str(bb[0]), int(bb[1])])
	elif k != null and k.boon != "" and k.boons > 0:
		out.append(["karma", k.boon, k.boons])
	return out



func _buff_now(id: String, timed: bool) -> Array:
	var p: = world.player
	var mods: = {}
	if timed:
		mods = p.heat if id == "heat_barrel" else GameData.power_def(id).get("mods", {})
	else:
		var lv: = int(p.skills[id].level) if p.skills.has(id) else 1
		for k in GameData.SKILLS[id].get("bonus", []):
			mods[k] = GameData.skill_value(id, k, lv) * (p.buff_mult_for(k, id) if str(GameData.SKILLS[id].type) == "buff" else 1.0)
	var text: = world.menus._mods_text(mods)
	var out: = []
	if text != "-":
		out.append([tr("Ahora: %s") % text, Color(0.5, 0.95, 0.55)])
	if id == "heat_barrel":
		out.append([tr("Calor del cañón: %d%%  ·  quieto sube, al moverte baja") % roundi(p.heat_level * 100.0), Color(1.0, 0.6, 0.3)])
	return out



func _curse_foot() -> Array:
	return [[tr("Ahora: −%d%% de vida máxima") % roundi(world.player.oath_curse * 100.0), Color(0.8, 0.55, 1.0)]]


var _power_icons: = {}
func _power_icon(id: String) -> Texture2D:
	if _power_icons.has(id):
		return _power_icons[id]
	var tex: = _power_icon_of(id)
	_power_icons[id] = tex
	return tex


func _power_icon_of(id: String) -> Texture2D:
	var skill_of: = {"steel_body": "steel_body", "martyr": "martyrs_reckoning", "gospel": "gospel", "gospel_might": "blessing", 
		"oath_silence": "lex_aeterna", "oath_curse": "signum_crucis", 
		"gospel_guard": "angelus", "gospel_haste": "increase_agi", "heat_barrel": "heat_barrel", 

		"temper_fire": "endow_blaze", "temper_water": "frost_diver", "temper_wind": "lightning_crash", "temper_earth": "power_of_land"}
	var item_of: = {"tiger_rush": "tiger_footskin", "wind_step": "valkyrian_manteau", "valhalla_rage": "valkyrie_helm", "sleipnir_gallop": "sleipnir"}
	if skill_of.has(id):
		return UiKit.skill_icon(str(skill_of[id]))

	if GameData.PET_POWERS.has(id):
		return UiKit.skill_icon(str(GameData.PET_POWERS[id].icon_skill))

	if GameData.SKILLS.has(id) and UiKit.skill_icon(id) != null:
		return UiKit.skill_icon(id)
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(item_of.get(id, id))
	return load(path) as Texture2D if ResourceLoader.exists(path) else null




func _add_buff_slots() -> void :
	_buff_timers.clear()
	for b in _buffs_now():
		if b[0] in ["wheel", "curse"]:
			_pact_row.add_child(_wheel_slot(b[0] == "curse", str(b[1]), int(b[2])))
			continue
		if b[0] == "karma":
			_pact_row.add_child(_karma_slot(str(b[1]), int(b[2])))
			continue
		if b[0] == "queen":
			_pact_row.add_child(_queen_slot())
			continue
		if b[0] == "doom":
			_pact_row.add_child(_doom_slot())
			continue
		if b[0] == "pride":
			_pact_row.add_child(_pride_slot())
			continue
		var timed: bool = b[0] == "power"
		var ally: bool = b[0] == "ally"
		var id: String = b[1]
		var col: = Color(0.45, 0.8, 1.0) if timed else (Color(0.5, 1.0, 0.6) if ally else Color(0.95, 0.8, 0.35))

		var hex: bool = timed and GameData.HEXES.has(id)
		if hex:
			col = Color(0.75, 0.45, 1.0)
		var slot: = PanelContainer.new()
		slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
		var box: = StyleBoxFlat.new()
		box.bg_color = Color(0.985, 0.99, 1.0, 0.95)
		box.border_color = col
		box.set_border_width_all(1)
		box.set_corner_radius_all(5)
		box.anti_aliasing = true
		box.set_content_margin_all(1)
		box.shadow_color = Color(col, 0.45)
		box.shadow_size = 3
		slot.add_theme_stylebox_override("panel", box)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var tex: = _power_icon(id) if timed else UiKit.skill_icon(id)
		if tex != null:
			var r: = UiKit.icon_rect(tex, 16)
			r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(r)
		if timed or ally:
			var n: = _ro_label("", 8, true)
			n.add_theme_color_override("font_color", Color.WHITE)
			n.add_theme_color_override("font_outline_color", Color.BLACK)
			n.add_theme_constant_override("outline_size", 3)

			n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			n.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(n)
			_buff_timers[id] = n
		if ally:
			_bind_hover(slot, func():
				var hv: = _skill_hover(id)
				hv.tag = tr("De un aliado")
				return hv)
		elif timed:
			_bind_hover(slot, func(): return {"icon": _power_icon(id), "title": tr(str(GameData.power_def(id).get("name", id))), 
				"color": col, "tag": tr("Juramento") if bool(GameData.power_def(id).get("oath", false)) else (tr("Maldición") if hex else tr("Efecto temporal")), 
				"desc": tr(str(GameData.power_def(id).get("desc", ""))), 
				"foot": _curse_foot() if id == "oath_curse" else _buff_now(id, true)})
		else:


			_bind_hover(slot, func(): return _skill_hover(id))
		_pact_row.add_child(slot)




func _wheel_slot(curse: bool, id: String, n: int) -> Control:
	var e: Dictionary = TowerRun.wheel_entry(id)
	var col: Color = Color(1.0, 0.35, 0.4) if curse else Color(e.get("color", Color(1.0, 0.85, 0.4))).lightened(0.25)
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.92, 0.93, 0.95) if curse else Color(0.985, 0.99, 1.0, 0.95)
	box.border_color = col
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	box.shadow_color = Color(col, 0.45)
	box.shadow_size = 3
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var tex: = UiKit.skill_icon(str(e.get("icon", "")))
	if tex != null:
		var r: = UiKit.icon_rect(tex, 16)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(r)
	if curse or n > 1:
		var l: = _ro_label(str(n) if curse else "x%d" % n, 8, true)
		l.add_theme_color_override("font_color", Color.WHITE)
		l.add_theme_color_override("font_outline_color", Color.BLACK)
		l.add_theme_constant_override("outline_size", 3)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(l)
	_bind_hover(slot, func(): return {"icon": tex, "title": tr(str(e.get("name", id))), "color": col, 
		"tag": (tr("Maldición de la ruleta  ·  %d pisos más") % n) if curse else tr("Ruleta de Lucile  ·  toda la subida"), 
		"desc": tr(str(e.get("desc", ""))), "foot": []})
	return slot






func _doom_slot() -> Control:
	var col: = Color(0.9, 0.2, 0.25)
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.94, 0.94, 0.95)
	box.border_color = col
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	box.shadow_color = Color(col, 0.45)
	box.shadow_size = 3
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var tex: Texture2D = GameData.doom_icon()
	if tex != null:
		var r: = UiKit.icon_rect(tex, 16)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(r)
	_bind_hover(slot, func(): return {"icon": tex, "title": tr("Sentencia de muerte"), "color": col, 
		"tag": tr("Maldición de la Kafra"), 
		"desc": tr("Cualquier mecánica de un MVP te derriba al instante. Solo tus resurrecciones te salvan."), 
		"foot": [[tr("+%d%% de daño a jefes y MVP  ·  el huevo del MVP cae x%d") % [roundi(GameData.DOOM_BOSS_DMG * 100.0), roundi(GameData.DOOM_EGG)], Color(0.5, 0.95, 0.55)]]})
	return slot




func _pride_slot() -> Control:
	var col: = Color(0.55, 0.3, 0.85)
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.97, 0.94, 1.0, 0.95)
	box.border_color = col
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	box.shadow_color = Color(col, 0.45)
	box.shadow_size = 3
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.set_meta("pride_slot", true)
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(GameData.UPGRADES.mvp_pride.icon)
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	if tex != null:
		var r: = UiKit.icon_rect(tex, 16)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(r)
	_bind_hover(slot, func():
		var foot: = [[tr("Carta del MVP x%d  ·  +%d%% de probabilidad de drop") % [roundi(GameData.PRIDE_CARD), roundi(GameData.PRIDE_DROP * 100.0)], Color(0.5, 0.95, 0.55)]]
		var b = world.boss
		if b != null and is_instance_valid(b) and not b.dead and b.has_meta("pride"):
			foot.append([tr("Ahora: el MVP recibe el %s%% de cada golpe") % str(snappedf(float(b.get_meta("pride")) * 100.0, 0.1)), Color(0.8, 0.6, 1.0)])
		return {"icon": tex, "title": tr("Orgullo de los MVP"), "color": col, "tag": tr("Maldición de la Kafra"), 
			"desc": tr("Los MVP resisten tu daño a un solo objetivo: aguantan al menos %d s de él y tu golpe más grande de la partida les quita como mucho el %d%% de la vida. Ymir despierta a los %d s.") % [
				roundi(GameData.PRIDE_TIME), roundi(GameData.PRIDE_HIT * 100.0), roundi(GameData.PRIDE_YMIR)], 
			"foot": foot})
	return slot




func _queen_slot() -> Control:
	var col: = GameData.U_QUEEN_COLOR
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.985, 0.99, 1.0, 0.95)
	box.border_color = col
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	box.shadow_color = Color(col, 0.45)
	box.shadow_size = 3
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var path: = "res://assets/ro/ui/skin/item_icons/queen_wings.png"
	var tex: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	if tex != null:
		var r: = UiKit.icon_rect(tex, 16)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(r)
	var n: = _ro_label("", 8, true)
	n.add_theme_color_override("font_color", Color.WHITE)
	n.add_theme_color_override("font_outline_color", Color.BLACK)
	n.add_theme_constant_override("outline_size", 3)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	n.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(n)
	_buff_timers["queen"] = n
	_bind_hover(slot, func():
		var qs: = Uniques.queen_state(world.player)
		var now: = int(qs[0]) if qs.size() > 1 else 0
		var storm: = qs.size() > 1 and bool(qs[1])
		return {"icon": tex, "title": tr("Tormenta de la Reina"), "color": col, 
			"tag": tr(str(GameData.ITEMS.queen_wings.name)), 
			"desc": tr(str(GameData.ITEMS.queen_wings.desc)), 
			"foot": [[tr("¡La tormenta ruge!") if storm else tr("Carga estática: %d / %d") % [now, GameData.U_QUEEN_CHARGE], col.darkened(0.25)]]})
	return slot


func _karma_slot(id: String, n: int) -> Control:
	var info: = _karma_hover(id, n)
	var col: Color = info.color
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.985, 0.99, 1.0, 0.95)
	box.border_color = col
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	box.set_content_margin_all(1)
	box.shadow_color = Color(col, 0.45)
	box.shadow_size = 3
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var tex: Texture2D = info.icon
	if tex != null:
		var r: = UiKit.icon_rect(tex, 16)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(r)
	var l: = _ro_label(str(n), 8, true)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 3)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(l)
	_bind_hover(slot, func(): return _karma_hover(id, n))
	return slot



func _karma_hover(id: String, n: int) -> Dictionary:
	var now: = Color(0.5, 0.95, 0.55)
	var cost: = Color(1.0, 0.5, 0.45)
	var k: Karma = world.karma


	var price: bool = k != null and world.tower == null and not world.festival_mode
	match id:
		"tower_floor":
			return {"icon": UiKit.skill_icon("loud_exclamation"), "title": tr("Fuerza de la torre"), "color": Color(0.6, 0.5, 1.0), 
				"tag": tr("Piso %d  ·  solo en la torre") % n, 
				"desc": tr("Cada piso de la Endless Tower: +%d%% de daño (se multiplica).") % roundi((GameData.TOWER_FLOOR_DMG - 1.0) * 100.0), 
				"foot": [[tr("Ahora: +%d%% de daño") % roundi((pow(GameData.TOWER_FLOOR_DMG, n - 1) - 1.0) * 100.0), now]]}
		"hel_mark":
			var foot: Array = [[tr("Ahora: +%d%% de daño") % roundi((pow(GameData.HEL_MARK_DMG, n) - 1.0) * 100.0), now]]
			if price and k.hel_marks > 0:
				foot.append([tr("Los monstruos pegan +%d%% (cofres abiertos: %d)") % [roundi((pow(GameData.HEL_MARK_FOE_DMG, k.hel_marks) - 1.0) * 100.0), k.hel_marks], cost])
			return {"icon": UiKit.skill_icon("over_thrust"), "title": tr("Marca de Hel"), "color": GameData.CORRUPT_COLOR, 
				"tag": tr("Cofres Corruptos abiertos: %d  ·  se guarda en tu build") % n, 
				"desc": tr("Cada Marca de Hel: +%d%% de daño.") % roundi((GameData.HEL_MARK_DMG - 1.0) * 100.0), "foot": foot}
		"feather":
			var foot: Array = [[tr("Ahora: +%d%% de vida y regeneras %s%% de tu vida por segundo") % [roundi((pow(GameData.FEATHER_HP, n) - 1.0) * 100.0), 
				str(snappedf(GameData.FEATHER_REGEN * n * 100.0, 0.1))], now]]
			if price and k.feathers > 0:
				foot.append([tr("Los monstruos tienen +%d%% de vida (cofres purificados: %d)") % [roundi((pow(GameData.FEATHER_FOE_HP, k.feathers) - 1.0) * 100.0), k.feathers], cost])
			return {"icon": UiKit.skill_icon("heal"), "title": tr("Pluma de Valquiria"), "color": GameData.PURE_COLOR.darkened(0.25), 
				"tag": tr("Cofres Corruptos purificados: %d  ·  se guarda en tu build") % n, 
				"desc": tr("Cada Pluma de Valquiria: +%d%% de vida y regeneración.") % roundi((GameData.FEATHER_HP - 1.0) * 100.0), "foot": foot}
		"valhalla":
			return {"icon": UiKit.skill_icon("assumptio"), "title": tr("Bendición de Valhalla"), 
				"color": Color(GameData.KARMA_ROUTES.light.color).darkened(0.25), 
				"tag": tr("Valquirias vencidas: %d  ·  toda la partida") % n, 
				"desc": tr("Por cada Valquiria vencida: %s") % tr("+1 vida, +20% de vida máxima, +20% de daño, +15% de EXP y un aura que te cura el resto de la partida"), 
				"foot": [[tr("Ahora: +%d vidas, +%d%% de vida máxima, +%d%% de daño, +%d%% de EXP y te curas %d%% de tu vida por segundo") % [GameData.VALHALLA_REVIVES * n, 
					roundi(GameData.VALHALLA_HP * n * 100.0), roundi(GameData.VALHALLA_DMG * n * 100.0), 
					roundi(GameData.VALHALLA_XP * n * 100.0), roundi(GameData.VALHALLA_REGEN * n * 100.0)], now]]}
	return {"icon": UiKit.skill_icon("soul_drain"), "title": tr("Pacto de Hel"), 
		"color": Color(GameData.KARMA_ROUTES.dark.color), 
		"tag": tr("Valquirias vencidas: %d  ·  toda la partida") % n, 
		"desc": tr("Por cada Valquiria vencida: %s") % tr("+50% de daño, recibes +20% de daño y matar te cura"), 
		"foot": [[tr("Ahora: +%d%% de daño y cada muerte te cura %d%% de tu vida") % [roundi(GameData.HEL_PACT_DMG * n * 100.0), 
			roundi(GameData.HEL_PACT_KILL_HEAL * n * 100.0)], now], 
			[tr("Recibes +%d%% de daño") % roundi(GameData.HEL_PACT_TAKEN * n * 100.0), cost]]}




func _refresh_buff_row(p: Player) -> void :
	_buff_check -= get_process_delta_time()
	if _buff_check <= 0.0:
		_buff_check = 0.2
		var now: = _buffs_now()
		var sig: = str(now)
		if now.is_empty():
			sig = ""
		if sig != _buff_sig:
			_buff_sig = sig
			_refresh_pacts()
	for id in _buff_timers:
		var l: Label = _buff_timers[id]

		if id == "queen" and is_instance_valid(l):
			var qs: = Uniques.queen_state(p)
			l.text = ("!" if bool(qs[1]) else str(int(qs[0]))) if qs.size() > 1 else ""
			continue
		if is_instance_valid(l):
			var left: float = float(p.powers[id]) if p.powers.has(id) else float((p.party_buffs.get(id, {}) as Dictionary).get("t", 0.0))

			l.text = ("%d%%" % roundi(p.heat_level * 100.0)) if id == "heat_barrel" else str(ceili(left))



func refresh_altars() -> void :
	if _pact_row == null or world == null or world.player == null:
		return
	_refresh_pacts()




func _add_god_slots(taken: Array) -> void :
	var counts: = {}
	var order: Array = []
	for id in taken:
		if not counts.has(id):
			order.append(id)
		counts[id] = int(counts.get(id, 0)) + 1
	var newest: String = taken.back() if taken.size() > _gods_shown else ""
	_gods_shown = taken.size()
	for id in order:
		var d: Dictionary = GameData.ALTARS[id]
		var slot: = PanelContainer.new()
		slot.custom_minimum_size = Vector2(BUFF_SIZE, BUFF_SIZE)
		var box: = StyleBoxFlat.new()
		box.bg_color = Color(0.985, 0.99, 1.0, 0.95)
		box.border_color = d.color
		box.set_border_width_all(1)
		box.set_corner_radius_all(5)
		box.anti_aliasing = true
		box.set_content_margin_all(1)
		box.shadow_color = Color(d.color, 0.45)
		box.shadow_size = 3
		slot.add_theme_stylebox_override("panel", box)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(d.icon)
		if ResourceLoader.exists(path):
			var r: = UiKit.icon_rect(load(path), 16)
			r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			slot.add_child(r)
		if int(counts[id]) > 1:
			var n: = _ro_label("x%d" % int(counts[id]), 8, true)
			n.add_theme_color_override("font_color", Color.WHITE)
			n.add_theme_color_override("font_outline_color", Color.BLACK)
			n.add_theme_constant_override("outline_size", 3)
			n.position = Vector2(8, 9)
			slot.add_child(n)
		var gid: String = id
		var times: int = counts[id]
		_bind_hover(slot, func(): return _altar_hover(gid, times))
		_pact_row.add_child(slot)
		if id == newest:
			slot.pivot_offset = Vector2(BUFF_SIZE, BUFF_SIZE) * 0.5
			slot.scale = Vector2(1.6, 1.6)
			slot.create_tween().tween_property(slot, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _altar_hover(id: String, times: int) -> Dictionary:
	var d: Dictionary = GameData.ALTARS[id]
	var lines: = []
	if str(d.get("bad", "")) != "":
		lines.append([tr("Precio"), tr(str(d.bad)), Color(1.0, 0.55, 0.5)])
	lines.append([tr("Don"), tr(str(d.good)), Color(0.55, 1.0, 0.6)])
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(d.icon)
	return {"icon": load(path) if ResourceLoader.exists(path) else null, "title": tr(str(d.name)), "color": d.color, 
		"tag": tr("Aceptado x%d  ·  dura toda la partida") % times, "lines": lines}




func _on_basic_menu(button: String) -> void :
	if world == null or not world.running or world.busy():
		return
	match button:
		"equip":
			world.menus.show_equipment()
		_:
			world.menus.show_pause()





var _xp_glow_v: = 0.0
func xp_glow(amount: = 0.35) -> void :
	_xp_glow_v = minf(1.0, _xp_glow_v + amount)



var _xp_chip: ProgressBar
var _xp_spark: CPUParticles2D
var _tally: = 0.0
var _tally_t: = 0.0
var _xp_shown: = 0.0
var _xp_level: = 0
func xp_gain(amount: float) -> void :
	_tally += amount
	_tally_t = 0.35




const FLASH_GAP_MS: = 1200
var _flash_at: = -100000
func flash(color: Color, duration: = 0.35, strength: = 0.3) -> void :


	if bool(Save.setting("no_flash", false)):
		return
	var now: = Time.get_ticks_msec()
	if now - _flash_at < FLASH_GAP_MS:
		return
	_flash_at = now
	_flash.color = Color(color, strength)
	var tw: = _flash.create_tween()
	tw.tween_property(_flash, "color:a", 0.0, duration).set_ease(Tween.EASE_OUT)


func clear_announce() -> void :
	if _announce_tween != null:
		_announce_tween.kill()
	_announce.modulate.a = 0.0






var _prizes: VBoxContainer
func prize(icon_id: String, text: String, color: Color) -> void :


	if _prizes == null or not is_instance_valid(_prizes):
		_prizes = VBoxContainer.new()
		_prizes.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_prizes.add_theme_constant_override("separation", 2)
		add_child(_prizes)
	_place_prizes()


	for old in _prizes.get_children():
		if str(old.get_meta("icon", "")) == icon_id:
			_prizes.remove_child(old)
			old.queue_free()
	var box: = PanelContainer.new()
	box.set_meta("icon", icon_id)

	var st: = UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 6, 1)
	st.content_margin_left = 5
	st.content_margin_right = 7
	st.content_margin_top = 1
	st.content_margin_bottom = 1
	box.add_theme_stylebox_override("panel", st)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(row)
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % icon_id
	if ResourceLoader.exists(path):
		var icon: = UiKit.icon_rect(load(path) as Texture2D, 16)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
	var label: = UiKit.label(text, 11, color, true)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	_prizes.add_child(box)

	while _prizes.get_child_count() > PRIZES_MAX:
		var old: = _prizes.get_child(0)
		_prizes.remove_child(old)
		old.queue_free()
	box.modulate.a = 0.0
	var tw: = box.create_tween()
	tw.tween_property(box, "modulate:a", 1.0, 0.12)
	tw.tween_interval(1.4)
	tw.tween_property(box, "modulate:a", 0.0, 0.35)
	tw.tween_callback(box.queue_free)



const PRIZES_MAX: = 6




func _place_prizes() -> void :
	if _prizes == null or not is_instance_valid(_prizes) or _cards_win == null:
		return
	var k: = _cards_win.scale.x
	_prizes.scale = Vector2(k, k)
	var at: = Vector2(8 + (RoBasicWindow.BG_SIZE.x + 6) * k, 8)
	if _refine_hint != null and _refine_hint.visible:
		at = _refine_hint.position + Vector2(0, (_refine_hint.size.y + 3) * _refine_hint.scale.y)
	_prizes.position = at


func announce(title: String, color: Color, subtitle: = "") -> void :
	_announce_title.text = title
	_announce_title.add_theme_color_override("font_color", color)
	_announce_sub.text = subtitle
	_announce_sub.visible = subtitle != ""


	var g = world.get_meta("gamepad") if world != null and world.has_meta("gamepad") else null
	var hints = g.get("hints") if g != null and is_instance_valid(g) else null
	if hints != null and bool(hints.get("pad_on")):
		hints._convert_node(_announce_title)
		hints._convert_node(_announce_sub)
	if _announce_tween != null:
		_announce_tween.kill()
	_announce.modulate.a = 0.0
	_announce_tween = create_tween()
	_announce_tween.tween_property(_announce, "modulate:a", 1.0, 0.2)
	_announce_tween.tween_interval(2.2)
	_announce_tween.tween_property(_announce, "modulate:a", 0.0, 0.6)


var _talks: = 0



func _pad_hints_node() -> Node:
	var g = world.get_meta("gamepad") if world != null and world.has_meta("gamepad") else null
	return g.get("hints") if g != null and is_instance_valid(g) else null




func _held_pill(icon_name: String, key_text: String, on_open: Callable) -> Dictionary:
	var hw: = UiStyles.hud_window("", RO_FONT_BOLD)
	var root: Control = hw.root
	root.get_child(0).visible = false
	root.visible = false
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	root.gui_input.connect( func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and world != null:
			on_open.call())
	var hrow: = HBoxContainer.new()
	hrow.add_theme_constant_override("separation", 6)
	hrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hw.body.add_child(hrow)

	var box: = Control.new()
	box.custom_minimum_size = Vector2(26, 26)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hrow.add_child(box)
	var glow: = UiKit.glow(Color(1.0, 0.8, 0.35, 0.8), 34)
	glow.position = Vector2(-4, -4)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(glow)
	var breathe: = glow.create_tween().set_loops()
	breathe.tween_property(glow, "modulate:a", 0.25, 0.9).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(glow, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % icon_name
	var icon: = UiKit.icon_rect(load(path) as Texture2D if ResourceLoader.exists(path) else null, 24)
	icon.position = Vector2(1, 1)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)
	var words: = VBoxContainer.new()
	words.add_theme_constant_override("separation", -2)
	words.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hrow.add_child(words)
	var count: = Label.new()
	count.add_theme_font_override("font", RO_FONT_BOLD)
	count.add_theme_font_size_override("font_size", 11)
	count.add_theme_color_override("font_color", Color(0.15, 0.2, 0.45))
	words.add_child(count)
	var text: = Label.new()
	text.add_theme_font_override("font", RO_FONT)
	text.add_theme_font_size_override("font_size", 10)
	text.add_theme_color_override("font_color", Color(0.28, 0.3, 0.4))
	words.add_child(text)

	var open: = Button.new()
	open.text = key_text
	open.focus_mode = Control.FOCUS_NONE
	open.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for st in ["normal", "hover", "pressed"]:
		var bb: StyleBox = UiStyles.hud_button_box(st)
		bb.content_margin_left = 6
		bb.content_margin_right = 6
		bb.content_margin_top = 1
		bb.content_margin_bottom = 1
		open.add_theme_stylebox_override(st, bb)
	open.add_theme_font_override("font", RO_FONT)
	open.add_theme_font_size_override("font_size", 10)
	if MouseWalk.touch():

		open.add_theme_font_size_override("font_size", 13)
		open.custom_minimum_size = Vector2(64, 28)
		for st in ["normal", "hover", "pressed"]:
			var tb: StyleBox = open.get_theme_stylebox(st)
			tb.content_margin_top = 4
			tb.content_margin_bottom = 4
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		open.add_theme_color_override(c, Color.BLACK)
	open.pressed.connect( func():
		if world != null:
			on_open.call())
	hrow.add_child(open)
	return {"root": root, "count": count, "text": text}


func _talk_fade(alpha: float) -> void :
	for c: Control in [_skill_window, _passive_window, _held_button, _chest_button, _quiver_win, _xp, _xp_chip, _meter_win]:
		c.create_tween().tween_property(c, "modulate:a", alpha, 0.25)






func npc_talk(sprite_id: String, who: String, lines: Array, per_line: = 3.2, done: = Callable(), other: = "") -> void :
	var path: = "res://assets/ro/ui/skin/illust/%s.png" % sprite_id
	if not ResourceLoader.exists(path):
		if done.is_valid():
			done.call()
		return
	_talks += 1
	_talk_fade(0.0)
	var view: = get_viewport().get_visible_rect().size
	var talk: = Control.new()
	talk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	talk.modulate.a = 0.0
	_root.add_child(talk)
	var art: = TextureRect.new()
	art.texture = load(path)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h: = minf(view.y * 0.72, float(art.texture.get_height()) * 1.25)
	art.size = Vector2(h * art.texture.get_width() / float(art.texture.get_height()), h)
	var rest: = Vector2(view.x - art.size.x - 8.0, view.y - h)
	art.position = rest + Vector2(0.0, 40.0)
	talk.add_child(art)


	var foe: TextureRect = null
	var foe_spr: RoSprite = RoAssets.sprite([other]) if other != "" else null
	if foe_spr != null:
		foe = TextureRect.new()
		foe.texture = foe_spr.get_frame(0, 0)
		foe.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		foe.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		foe.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		foe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		foe.size = foe.texture.get_size() * 2.0
		foe.position = Vector2(24.0, view.y - foe.size.y + 54.0)
		foe.modulate.a = 0.0
		talk.add_child(foe)
		talk.move_child(foe, 0)
	var box: = PanelContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var talk_box: = UiKit.panel_box(Color(0.985, 0.99, 1.0, 0.96), UiKit.SOFT_RIM, 12, 1)
	talk_box.shadow_color = Color(0.03, 0.06, 0.18, 0.3)
	talk_box.shadow_size = 6
	talk_box.shadow_offset = Vector2(0, 3)
	box.add_theme_stylebox_override("panel", talk_box)
	box.custom_minimum_size = Vector2(420.0, 84.0)
	box.position = Vector2(view.x - 436.0, view.y - 124.0)
	talk.add_child(box)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	box.add_child(col)
	var speaker: = UiKit.label(who, 14, Color(0.58, 0.36, 0.08), true)
	col.add_child(speaker)
	var text: = UiKit.label("", 15, Color(0.22, 0.16, 0.32))
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size.x = 396.0
	col.add_child(text)
	var tw: = talk.create_tween()
	tw.tween_property(talk, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(art, "position", rest, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for line in lines:
		var say: = str(line[1]) if line is Array else str(line)
		tw.tween_callback( func():
			if line is Array:
				speaker.text = str(line[0])
				speaker.add_theme_color_override("font_color", Color(0.58, 0.36, 0.08) if str(line[0]) == who else Color(0.7, 0.14, 0.12))
				art.texture = load("res://assets/ro/ui/skin/illust/%s.png" % str(line[2]))
				if foe != null:
					var speaks: = str(line[0]) != who

					box.position.x = maxf(16.0, foe.position.x + (foe.size.x - 420.0) * 0.5) if speaks else view.x - 436.0
					foe.create_tween().tween_property(foe, "modulate", Color.WHITE if speaks else Color(0.55, 0.55, 0.62, foe.modulate.a), 0.25)
			text.text = say
			text.visible_ratio = 0.0)


		tw.tween_property(text, "visible_ratio", 1.0, 0.02 * say.length())
		tw.tween_interval(maxf(per_line * 0.7 - 0.02 * say.length(), 1.1))
	tw.tween_property(talk, "modulate:a", 0.0, 0.35)
	tw.tween_callback( func():
		talk.queue_free()
		_talks -= 1
		if _talks == 0:
			_talk_fade(1.0)
		if done.is_valid():
			done.call())




func event_sign(title: String, subtitle: String, color: Color, seconds: float) -> void :
	var view: = get_viewport().get_visible_rect().size
	var band: = Control.new()
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.size = Vector2(view.x, 112.0)
	band.position = Vector2(0.0, 118.0)
	band.pivot_offset = band.size * 0.5
	band.clip_contents = true
	_root.add_child(band)
	var fade: = Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.25, 0.75, 1.0])
	fade.colors = PackedColorArray([Color(0, 0, 0, 0), Color.WHITE, Color.WHITE, Color(0, 0, 0, 0)])
	var mask: = GradientTexture1D.new()
	mask.gradient = fade
	for line in [[0.0, 112.0, Color(0.05, 0.05, 0.12, 0.88)], [0.0, 2.0, color], [110.0, 2.0, color]]:
		var strip: = TextureRect.new()
		strip.texture = mask
		strip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		strip.stretch_mode = TextureRect.STRETCH_SCALE
		strip.modulate = line[2]
		strip.position = Vector2(0.0, line[0])
		strip.size = Vector2(view.x, line[1])
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.add_child(strip)
	var words: = VBoxContainer.new()
	words.add_theme_constant_override("separation", 2)
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	words.size = band.size
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(words)
	for l in [[title, 34, color], [subtitle, 14, Color(0.88, 0.9, 1.0)]]:
		var label: = _ro_label(str(l[0]), int(l[1]), true)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", l[2])
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 5)
		words.add_child(label)
	var shine: = ColorRect.new()
	shine.color = Color(color, 0.35)
	shine.size = Vector2(70, 150)
	shine.position = Vector2(-120, -20)
	shine.rotation = 0.35
	shine.material = _add_blend()
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(shine)
	band.scale = Vector2(1.0, 0.0)
	var tw: = band.create_tween()
	tw.tween_property(band, "scale:y", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(shine, "position:x", view.x + 120.0, 0.9).set_delay(0.2)
	tw.tween_interval(maxf(0.1, seconds - 0.55))
	tw.tween_property(band, "modulate:a", 0.0, 0.3)
	tw.tween_callback(band.queue_free)




func stolen_skill(sid: String, mob_id: String) -> void :
	var view: = get_viewport().get_visible_rect().size
	var gold: = Color(1.0, 0.82, 0.3)
	var band: = Control.new()
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.size = Vector2(view.x, 112.0)
	band.position = Vector2(0.0, 118.0)
	band.pivot_offset = band.size * 0.5
	band.clip_contents = true
	_root.add_child(band)
	var fade: = Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.25, 0.75, 1.0])
	fade.colors = PackedColorArray([Color(0, 0, 0, 0), Color.WHITE, Color.WHITE, Color(0, 0, 0, 0)])
	var mask: = GradientTexture2D.new()
	mask.gradient = fade
	mask.width = 512
	mask.height = 4
	for line in [[0.0, 112.0, Color(0.05, 0.05, 0.12, 0.88)], [0.0, 2.0, gold], [110.0, 2.0, gold]]:
		var strip: = TextureRect.new()
		strip.texture = mask
		strip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		strip.stretch_mode = TextureRect.STRETCH_SCALE
		strip.modulate = line[2]
		strip.position = Vector2(0.0, line[0])
		strip.size = Vector2(view.x, line[1])
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		band.add_child(strip)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 22)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.size = band.size
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(row)
	var holder: = Control.new()
	holder.custom_minimum_size = Vector2(96, 112)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(holder)
	var sun: = TextureRect.new()
	sun.texture = RoAssets.effect_tex("sun_rays")
	sun.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sun.size = Vector2(128, 128)
	sun.position = Vector2(-16, -8)
	sun.pivot_offset = sun.size * 0.5
	sun.modulate = gold
	sun.material = _add_blend()
	sun.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(sun)
	var icon: = UiKit.icon_rect(UiKit.skill_icon(sid), 60)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	icon.position = Vector2(18, 26)
	icon.pivot_offset = Vector2(30, 30)
	holder.add_child(icon)
	var words: = VBoxContainer.new()
	words.add_theme_constant_override("separation", 0)
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	words.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(words)
	var lines: = [[tr("¡HABILIDAD ROBADA!"), 14, gold], [tr(str(GameData.SKILLS[sid].name)), 32, Color.WHITE], 
		[tr("Copiada de %s  ·  Elígela en el Álbum") % tr(str(GameData.MONSTERS[mob_id].name)), 12, Color(0.78, 0.82, 0.95)]]
	for l in lines:
		var label: = _ro_label(str(l[0]), int(l[1]), true)
		label.add_theme_color_override("font_color", l[2])
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 5)
		words.add_child(label)
	var shine: = ColorRect.new()
	shine.color = Color(1.0, 0.95, 0.75, 0.35)
	shine.size = Vector2(70, 150)
	shine.position = Vector2(-120, -20)
	shine.rotation = 0.35
	shine.material = _add_blend()
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(shine)
	band.scale = Vector2(1.0, 0.0)
	icon.scale = Vector2.ONE * 2.6
	sun.scale = Vector2.ONE * 0.3
	var tw: = band.create_tween()
	tw.tween_property(band, "scale:y", 1.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(icon, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(sun, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(shine, "position:x", view.x + 120.0, 0.9).set_delay(0.2)
	tw.tween_interval(3.4)
	tw.tween_property(band, "modulate:a", 0.0, 0.5)
	tw.tween_callback(band.queue_free)
	var spin: = sun.create_tween().set_loops()
	spin.tween_property(sun, "rotation", TAU, 7.0).as_relative()


func _add_blend() -> CanvasItemMaterial:
	var m: = CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m




func _process(delta: float) -> void :
	if world == null or world.player == null or not world.running:
		return
	if World.bench:
		var t0: = Time.get_ticks_usec()
		_tick(delta)
		World.bench_hud += Time.get_ticks_usec() - t0
	else:
		_tick(delta)


func _tick(delta: float) -> void :
	var p: = world.player
	if _xp_spark != null:
		_tally_t -= delta
		if _tally_t <= 0.0:
			_tally = 0.0
		_xp_spark.emitting = _tally_t > 0.0

		var w: = _xp_chip.size.x * clampf(float(_xp_chip.value) / maxf(1.0, float(_xp_chip.max_value)), 0.0, 1.0)
		_xp_spark.position = _xp_chip.position + Vector2(w, _xp_chip.size.y * 0.5)
	if _xp != null:
		_xp_glow_v = maxf(0.0, _xp_glow_v - delta * 1.2)
		var g: = 1.0 + 0.3 * _xp_glow_v
		_xp.modulate = Color(g * 0.95, g, g + 0.1 * _xp_glow_v, _xp.modulate.a)
	_refresh_powers(p)
	_refresh_buff_row(p)
	_refresh_refine_hint(p)
	_place_prizes()
	_refresh_quiver(p)

	_layout()
	var held: = p.pending_levels if bool(Save.setting("hold_levels", false)) else 0

	var boxes: int = world.held_chests.size() if p.pending_levels <= 0 else 0
	_held_button.visible = (held > 0 or boxes > 0) and not world.busy()


	var hints: = _pad_hints_node()
	var side: int = world.held_chests.size() if held > 0 and not (hints != null and bool(hints.get("pad_on"))) else 0
	_chest_button.visible = side > 0 and not world.busy()
	if side > 0:
		var cw: = tr_n("%d cofre guardado", "%d cofres guardados", side) % side
		if _chest_count.text != cw:
			_chest_count.text = cw
			_chest_button.reset_size()
	var held_words: = tr_n("%d mejora de nivel", "%d mejoras de nivel", held) % held if held > 0\
	else tr_n("%d cofre guardado", "%d cofres guardados", boxes) % boxes
	if (held > 0 or boxes > 0) and _held_count.text != held_words:
		_held_count.text = held_words
		_held_text.text = tr("listas para elegir") if held > 0 else tr("para abrir")
		_held_button.reset_size()
	_meter.world = world

	if world.time < 0.5:
		_meter_party_set = false
	if world.is_coop() and not _meter_party_set:
		_meter_party_set = true
		_meter.mode = "party"
	elif not world.is_coop() and _meter.mode == "party":
		_meter.mode = "damage"
	_meter_win.visible = not world.meter.is_empty() or (_meter.mode == "party" and world.meter_hero.any( func(m): return not m.is_empty()))
	if _meter_win.visible:

		var shown: = world.meter_view_total("damage" if _meter.mode == "dps" else _meter.mode)
		match _meter.mode:
			"party":
				_meter_title.text = tr("Grupo  ·  %s/s") % DamageMeter.short(shown / world.meter_time())
			"boss":
				_meter_title.text = tr("Jefes  ·  %s") % DamageMeter.short(shown)
			"taken":
				_meter_title.text = tr("Recibido  ·  %s") % DamageMeter.short(shown)
			"heal":
				_meter_title.text = tr("Curación  ·  %s") % DamageMeter.short(shown)
			"dps":
				_meter_title.text = tr("DPS  ·  %s/s") % DamageMeter.short(shown / world.meter_time())
			_:
				_meter_title.text = tr("Daño  ·  %s/s") % DamageMeter.short(shown / world.meter_time())
	_basic.hp = p.hp
	_basic.hp_max = p.max_hp
	_basic.sp = p.shield
	_basic.sp_max = _barrier_max(p)
	_basic.base_lv = p.level
	_basic.exp_ratio = p.xp / maxf(1.0, p.xp_need)


	_basic.job_lv = maxi(1, p.level - p.pending_levels)
	_basic.run_time = world.time
	_basic.kills = world.kills
	_basic.zeny = world.run_zeny
	_basic.lives = p.revives

	var bsig: = [roundi(p.hp), roundi(p.max_hp), roundi(p.shield), roundi(_basic.sp_max), p.level, roundi(_basic.exp_ratio * 1000.0), 
		_basic.job_lv, int(world.time), world.kills, world.run_zeny, p.revives]
	if bsig != _basic_sig:
		_basic_sig = bsig
		_basic.queue_redraw()

	_timer.text = (tr("Tiempo  %s") % UiKit.time_text(world.time)) + "   ·   " + GameData.danger_name(world.danger)
	var c: = _minimap.cell()
	_coords.text = "%s  (%d, %d)" % [world.map.map_name, c.x, c.y]
	var sky: = world.weather.badge() if world.weather != null else ""
	_sky.visible = sky != ""
	if sky != _sky.text:
		_sky.text = sky
		var ph: = world.weather.phase()
		_sky.add_theme_color_override("font_color", Color(0.25, 0.3, 0.6) if ph == "night" else (Color(0.7, 0.38, 0.1) if ph in ["dusk", "dawn"] else Color(0.45, 0.4, 0.1)))
	var left: = world.mvp_at() - world.time
	var state: = tr("MVP en  %s") % UiKit.time_text(left) if left > 0.0 else tr("¡El MVP está en el mapa!")
	if world.endless:
		state = tr("Modo infinito")
		var emv: float = world.endless_mvp_at()
		if emv > world.time:


			state = tr("MVP en  %s") % UiKit.time_text(emv - world.time)

		var fin: float = world.morroc.finale_at() - world.time
		if world.tower == null and not world.festival_mode and not world.training and fin <= 300.0 and (emv <= world.time or fin < emv - world.time):
			state = tr("Final en  %s") % UiKit.time_text(fin) if fin > 0.0 else tr("¡Llega el final!")
	if world.tower != null:
		state = world.tower.hud_state()
	if world.festival_mode:
		state = tr("Emperium Festival")
	elif world.training:
		state = tr("Campo de entrenamiento")
	if world.raid.active():
		state = world.raid.hud_state()
	elif world.morroc.active():
		var omen: String = world.morroc.hud_state()
		if omen != "":
			state = omen
	var place: = world.raid.arena_title() if world.raid.in_arena() else tr(str(world.stage.name))



	var hel: bool = world.tower != null and is_instance_valid(world.tower) and world.tower.hel != null
	if hel:
		place = (tr("Torre de Hel") + "  ·  " + place) if world.raid.in_arena() else tr("Torre de Hel")
	if _time_title.text != place:
		_time_title.text = place
		_time_title.add_theme_color_override("font_color", Color(0.62, 0.06, 0.12) if hel else UiStyles.HUD_TITLE_TEXT)
		_time_window.reset_size()
	_mvp_timer.text = tr("%s   ·   %d KO") % [state + ("  ·  x2" if world.fast_now else ""), world.kills]
	_tower_loot_line(p)


	if _time_window.get_combined_minimum_size().x < _time_window.size.x - 0.5:
		_time_window.reset_size()
	_xp.max_value = maxf(1.0, p.xp_need)
	_xp_chip.max_value = _xp.max_value
	_xp_chip.value = p.xp

	if p.level != _xp_level:
		_xp_level = p.level
		_xp_shown = 0.0
	if _xp_shown < p.xp:
		_xp_shown = move_toward(_xp_shown, p.xp, maxf(_xp.max_value * 0.2, (p.xp - _xp_shown) * 2.5) * get_process_delta_time())
	else:
		_xp_shown = p.xp
	_xp.value = _xp_shown

	_refresh_skills()
	_update_cooldowns()
	_refresh_cards()
	_refresh_quest()

	var boss: = world.boss

	if world.world_boss != null and is_instance_valid(world.world_boss):
		boss = null
	if boss != null and is_instance_valid(boss) and not boss.dead:
		_boss_panel.visible = true
		_boss_title.text = "%s  ·  %s" % [tr("Sombra") if boss.has_meta("mvp_shadow") else (tr("MVP") if boss.def.get("mvp", false) else tr("Boss")), tr(str(boss.def.name))]
		_boss_bar.max_value = boss.max_hp
		_boss_bar.value = boss.hp
		var sg: Dictionary = world.stagger.gauge(world, boss)
		_boss_stagger_row.visible = float(sg.k) >= 0.0
		if _boss_stagger_row.visible:

			_boss_stagger.value = 0.0 if sg.broken else 1.0 - float(sg.k)

			var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.02)
			_boss_stagger_fill.bg_color = Color(1.0, 1.0, 0.85).lerp(STAGGER_GOLD, pulse * 0.5) if sg.broken else STAGGER_GOLD
			_boss_stagger_label.text = tr("¡ROTO!") if sg.broken else tr("Aguante")
			_boss_stagger_label.add_theme_color_override("font_color", Color(0.85, 0.2, 0.1) if sg.broken else Color(0.55, 0.38, 0.05))
		if _boss_face_id != boss.id:
			_boss_face_id = boss.id
			var look: RoSprite = RoAssets.sprite([str(boss.def.get("sprite", boss.id))])
			_boss_face.texture = null
			if look != null:

				var img: = look.compose_image(0, 0)
				var used: = img.get_used_rect()
				if used.size.x > 0 and used.size.y > 0:
					_boss_face.texture = ImageTexture.create_from_image(img.get_region(used))
		_boss_label.text = "%d%%" % ceili(100.0 * boss.hp / boss.max_hp)
		var el: = boss.element()
		if str(_boss_elem.get_meta("el", "")) != el:
			_boss_elem.set_meta("el", el)
			_boss_elem.text = _boss_element_line(el)
		_show_boss_marks(boss)


		if world.net.is_client() and world.raid.state == "fight" and boss.id == world.raid.mvp:
			world.raid.boss = boss
		var fight = world.morroc if boss == world.morroc.boss else world.raid
		var ymir_line: String = fight.ymir_text() if boss == fight.boss else ""
		_boss_fury.visible = ymir_line != ""
		if ymir_line != "":
			_boss_fury.text = ymir_line
			var awake: bool = fight.ymir > 0.0
			var pulse: = 0.6 + 0.4 * absf(sin(Time.get_ticks_msec() / (220.0 if awake else 400.0)))
			if not _boss_fury.has_meta("awake") or _boss_fury.get_meta("awake") != awake:
				_boss_fury.set_meta("awake", awake)
				_boss_fury.add_theme_color_override("font_color", Color(0.5, 0.15, 0.8) if awake else Color(0.45, 0.25, 0.7))
			_boss_fury.self_modulate.a = pulse if awake else 1.0
		_refresh_ymir_veil(fight.ymir if boss == fight.boss else 0.0)
	else:
		_boss_panel.visible = false
		_refresh_ymir_veil(0.0)





func _tower_loot_line(p: Player) -> void :
	var climb = world.tower
	var on: bool = climb != null and is_instance_valid(climb)
	if _tower_loot.visible != on:
		_tower_loot.visible = on
		_time_window.reset_size()
	if not on:
		return
	var crumb: float = climb.hel.crumb_chance() if climb.hel != null else GameData.STAR_CRUMB_KILL
	var line: = tr("★ %s%%  ·  Zeny x%s  ·  EXP x%s  ·  Cartas x%s") % [_num(crumb * 100.0, 3), _num(p.loot_mult, 1), _num(p.xp_mult, 1), 
		_num(GameData.danger_cards(world.danger), 1)]
	if line == _tower_loot.text:
		return
	_tower_loot.text = line
	var tips: Array[String] = [tr("Por cada monstruo de este piso:"), 
		tr("Star Crumb: %s%%") % _num(crumb * 100.0, 3), 
		tr("Zeny x%s  ·  EXP x%s") % [_num(p.loot_mult, 2), _num(p.xp_mult, 2)], 
		tr("Cartas x%s  ·  Legendarios +%s%%") % [_num(GameData.danger_cards(world.danger), 2), _num(p.equipment.legend_bonus * 100.0, 2)]]
	if climb.hel != null:
		tips.append(tr("Torre de Hel: la Star Crumb sube con cada piso y con tu Juramento (%d)") % world.oath_points())
	_tower_loot.tooltip_text = "\n".join(tips)



static func _num(x: float, dec: int) -> String:
	var t: = String.num(x, dec)
	if t.contains("."):
		t = t.rstrip("0").rstrip(".")
	return t



func _refresh_ymir_veil(awake: float) -> void :
	if awake <= 0.0:
		if _ymir_veil != null:
			_ymir_veil.visible = false
		return
	if _ymir_veil == null:
		var g: = Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		g.colors = PackedColorArray([Color(0.3, 0.05, 0.5, 0.0), Color(0.3, 0.05, 0.5, 0.15), Color(0.25, 0.0, 0.4, 0.85)])
		var t: = GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.05, 0.5)
		_ymir_veil = TextureRect.new()
		_ymir_veil.texture = t
		_ymir_veil.stretch_mode = TextureRect.STRETCH_SCALE
		_ymir_veil.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_ymir_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_ymir_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_root.add_child(_ymir_veil)
		_root.move_child(_ymir_veil, 0)
	_ymir_veil.visible = true
	_ymir_veil.modulate.a = minf(0.85, 0.25 + awake * 0.008) * (0.85 + 0.15 * sin(Time.get_ticks_msec() / 500.0))


func _show_boss_marks(boss: Enemy) -> void :
	var chips: = StatusMarks.boss_chips(boss, world.time, world.clock)
	var key: = ""
	for c in chips:
		key += "%d," % c[0].get_instance_id()
	if key == _boss_marks_key:
		return
	_boss_marks_key = key
	for c in _boss_marks.get_children():
		c.free()
	_boss_marks.visible = not chips.is_empty()
	for c in chips:
		var t: = TextureRect.new()
		t.texture = c[0]
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.custom_minimum_size = Vector2(StatusMarks.HUD_SIDE, StatusMarks.HUD_SIDE)
		t.tooltip_text = tr(str(c[1]))
		_boss_marks.add_child(t)




func _refresh_quest() -> void :
	var q: = world.quest
	_quest_win.visible = q != null and q.shows() and not world.raid.in_arena()
	if not _quest_win.visible:
		return
	var d: Dictionary = q.data
	var w: = q.window()
	_quest_name.text = tr(str(d.name))


	var count_text: = ""
	var gauge_on: = false
	var clock_text: = ""
	if q.state == "offer":
		_quest_goal.text = tr("Habla con %s") % tr(str(d.npc_name))
	else:
		if w.get("boss", false):
			_quest_goal.text = tr("Derrota a %s") % tr(str(d.get("boss_name", "")))
		else:
			_quest_goal.text = q.objective()
		var count: Array = w.get("count", [])
		if count.size() == 2:
			count_text = "%d/%d" % [count[0], count[1]]
		var bar: Array = w.get("bar", [])
		if bar.size() == 5:
			gauge_on = true
			if bar[0] != _quest_kind:
				_quest_kind = bar[0]
				_quest_bar.add_theme_stylebox_override("fill", UiStyles.gauge_box(_quest_kind))
			_quest_bar.max_value = maxf(1.0, float(bar[2]))
			_quest_bar.value = float(bar[1])
			if bar[4]:
				_quest_caption.text = tr("Brasero") if d.get("braziers", false) else tr("Sello")
			else:
				_quest_caption.text = "HP"
			_quest_value.text = "%d / %d" % [bar[1], bar[2]] if bar[3] else "%d%%" % bar[1]
		var left: = int(w.get("left", -1))
		var secs: = int(w.get("time", -1))
		if left >= 0:
			clock_text = tr("Salida a %d pasos") % left
		elif secs >= 0:
			clock_text = tr("Tiempo  %s") % UiKit.time_text(secs)


		var clock_c: = QUEST_HURRY_COLOR if secs >= 0 and secs <= QUEST_HURRY else Color.BLACK
		if _quest_clock.get_meta("c", Color.TRANSPARENT) != clock_c:
			_quest_clock.set_meta("c", clock_c)
			_quest_clock.add_theme_color_override("font_color", clock_c)
	_quest_count.text = count_text
	_quest_gauge.visible = gauge_on
	_quest_clock.text = clock_text
	_quest_clock.visible = clock_text != ""
	var qsig: = _quest_name.text + _quest_goal.text + _quest_count.text + str(_quest_gauge.visible) + str(_quest_clock.visible)
	if qsig != _quest_sig:
		_quest_sig = qsig
		_quest_win.reset_size()



func _refresh_refine_hint(p: Player) -> void :
	if _refine_hint == null:
		_refine_hint = PanelContainer.new()
		var box: = UiKit.panel_box(Color(1.0, 0.97, 0.88, 0.95), Color(0.85, 0.66, 0.25), 8, 1)
		box.shadow_color = Color(0.05, 0.08, 0.2, 0.2)
		box.shadow_size = 3
		box.shadow_offset = Vector2(0, 2)
		box.content_margin_left = 6
		box.content_margin_right = 8
		box.content_margin_top = 2
		box.content_margin_bottom = 2
		_refine_hint.add_theme_stylebox_override("panel", box)
		_refine_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_refine_hint.add_child(row)
		var path: = "res://assets/ro/ui/skin/item_icons/oridecon.png"
		if ResourceLoader.exists(path):
			var ic: = UiKit.icon_rect(load(path) as Texture2D, 20)
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row.add_child(ic)
		_refine_hint_text = UiKit.label("", 11, UiKit.TEXT, true)
		_refine_hint_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(_refine_hint_text)
		_root.add_child(_refine_hint)
	var ready: = p.equipment.refinable_now()


	_refine_hint.visible = not ready.is_empty() and not world.raid.freezes_time() and not world.festival_mode
	if not _refine_hint.visible:
		return


	var sig: = ""
	for ore in GameData.ORES:
		sig += "%s%d;" % [ore, int(p.equipment.ores[ore])]
	if str(_refine_hint.get_meta("sig", "")) != sig:
		_refine_hint.set_meta("sig", sig)
		var row: HBoxContainer = _refine_hint.get_child(0)


		for c in row.get_children():
			row.remove_child(c)
			c.queue_free()
		_refine_hint_text = UiKit.label(tr("Refinar") if MouseWalk.touch() else tr("Q: refinar"), 11, UiKit.TEXT, true)
		_refine_hint_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(_refine_hint_text)
		for ore in GameData.ORES:
			var n: = int(p.equipment.ores[ore])
			if n <= 0:
				continue
			var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % ore
			if ResourceLoader.exists(path):
				var ic: = UiKit.icon_rect(load(path) as Texture2D, 18)
				ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
				row.add_child(ic)
			var cl: = UiKit.label("x%d" % n, 11, UiKit.TEXT, true)
			cl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(cl)
		_refine_hint.size = Vector2.ZERO
		_refine_hint.reset_size.call_deferred()
	var k: = _cards_win.scale.x
	_refine_hint.scale = Vector2(k, k)


	_refine_hint.position = Vector2(8 + (RoBasicWindow.BG_SIZE.x + 6) * k, 8)
	if _boss_panel.visible:
		var hint: = Rect2(_refine_hint.position, _refine_hint.size * k).grow(6.0)
		var boss: = Rect2(_boss_panel.position, _boss_panel.size * _boss_panel.scale)
		if hint.intersects(boss):
			_refine_hint.position = Vector2(8, _pact_row.position.y + _pact_row.size.y * _pact_row.scale.y + 6.0)
	_refine_hint.modulate.a = 0.8 + 0.2 * sin(Time.get_ticks_msec() * 0.005)


func _refresh_powers(p: Player) -> void :
	if _powers == null:
		_powers = UiKit.label("", 18, Color(1.0, 0.92, 0.6), true)
		_powers.add_theme_constant_override("outline_size", 6)
		_powers.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.02, 0.95))
		_powers.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_powers.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_root.add_child(_powers)
	var parts: Array[String] = []


	for id in p.powers:
		if id == "oath_curse":

			parts.append(tr("Maldición  −%d%% de vida") % roundi(p.oath_curse * 100.0))
		elif GameData.POWER_DROPS.has(id) or GameData.HEXES.has(id):
			parts.append(tr("%s  %d s") % [tr(GameData.power_def(id).name), ceili(float(p.powers[id]))])
	_powers.visible = not parts.is_empty()
	if _powers.visible:
		_powers.text = "   ·   ".join(parts)
		var view: = get_viewport().get_visible_rect().size
		_powers.size = Vector2(view.x, 26)


		var y: = 40.0
		if _boss_panel.visible:
			y = maxf(y, _boss_panel.position.y + _boss_panel.size.y + 6.0)
		_powers.position = Vector2(0, y)


func _refresh_quiver(p: Player) -> void :
	_quiver_win.visible = p.def.has("ammo")
	var key: = "%s|%d|%s" % [p.arrow_id, p.quiver.size(), p.can_switch_ammo()]
	if not _quiver_win.visible or key == _quiver_shown:
		return
	_quiver_shown = key
	var a: Dictionary = p.ammo()[p.arrow_id]
	_quiver_title.text = tr(GameData.AMMO_NAMES[p.def.get("ammo", "arrows")])
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % p.arrow_id
	_quiver_icon.texture = load(path) if ResourceLoader.exists(path) else null
	var hint: = (tr("toca: cambiar") if p.can_switch_ammo() else tr("Equipo")) if MouseWalk.touch()\
	else (tr("C / V cambiar") if p.can_switch_ammo() else tr("Q: Equipo"))
	_quiver_label.text = tr("%s  (%s)\n%d de %d tipos · %s") % [tr(str(a.name)), tr(GameData.ELEMENT_NAMES[a.element]), p.quiver.size(), p.ammo().size(), hint]

	_quiver_win.tooltip_text = (tr("Tienes %d de %d tipos: cada cofre tiene un %d%% de darte uno que te falte.") % [p.quiver.size(), p.ammo().size(), roundi(GameData.CHEST_ARROW_CHANCE * 100.0)])\
	if p.quiver.size() < p.ammo().size() else tr("Tienes todos los tipos.")
	_quiver_win.reset_size()



func _layout() -> void :
	var view: = get_viewport().get_visible_rect().size
	var k: = maxf(1.0, floorf(view.y / 700.0))
	_basic.scale = Vector2(k, k)
	_cards_win.scale = Vector2(k, k)
	_cards_win.position = Vector2(8, 8 + RoBasicWindow.BG_SIZE.y * k + 4)
	_skill_window.scale = Vector2(k, k)
	_skill_window.position = Vector2(roundf((view.x - _skill_window.size.x * k) * 0.5), 
		view.y - 22.0 - _skill_window.size.y * k)
	_passive_window.scale = Vector2(k, k)
	_passive_window.position = Vector2(_skill_window.position.x + (_skill_window.size.x + 6) * k, 
		view.y - 22.0 - _passive_window.size.y * k)


	_pact_row.scale = Vector2(k, k)
	var cols: = clampi(floori((RoBasicWindow.BG_SIZE.x + BUFF_GAP) / float(BUFF_SIZE + BUFF_GAP)), 1, BUFF_COLUMNS)
	if _pact_row.columns != cols:
		_pact_row.columns = cols
	_pact_row.position = Vector2(8, 8 + (RoBasicWindow.BG_SIZE.y + 4) * k)
	_party.scale = Vector2(k, k)


	_party.position = Vector2(8, roundf((view.y - _party.size.y * k) * 0.5))

	var timers: Control = alerts.get("_win")
	if timers != null and timers.visible:
		_party.position.y = maxf(_party.position.y, timers.position.y + timers.size.y * timers.scale.y + 6.0)

	_training.scale = Vector2(k, k)
	_training.position = Vector2(8, roundf(view.y * 0.36))
	if _party.visible:
		_training.position.y = maxf(_training.position.y, _party.position.y + (_party.size.y + 6) * k)
	_held_button.scale = Vector2(k, k)

	var bars_top: = _skill_window.position.y
	if _passive_window.visible:
		bars_top = minf(bars_top, _passive_window.position.y)
	if _quiver_win.visible:
		bars_top = minf(bars_top, view.y - 22.0 - _quiver_win.size.y * k)
	_held_button.position = Vector2(roundf((view.x - _held_button.size.x * k) * 0.5), bars_top - (_held_button.size.y + 14) * k)

	_chest_button.scale = Vector2(k, k)
	if _chest_button.visible:
		var both: = (_held_button.size.x + 8.0 + _chest_button.size.x) * k
		_held_button.position.x = roundf((view.x - both) * 0.5)
		_chest_button.position = Vector2(_held_button.position.x + (_held_button.size.x + 8.0) * k, _held_button.position.y)
	_quiver_win.scale = Vector2(k, k)
	var qsize: = _quiver_win.get_combined_minimum_size().max(_quiver_win.size)
	_quiver_win.position = Vector2(_skill_window.position.x - 6 - qsize.x * k, view.y - 22.0 - qsize.y * k)
	_boss_panel.scale = Vector2(k, k)
	_boss_panel.position = Vector2(roundf((view.x - _boss_panel.size.x * k) * 0.5), 8)
	_time_window.scale = Vector2(k, k)
	_time_window.position = Vector2(view.x - 8 - _time_window.size.x * k, 8)
	_meter_win.scale = Vector2(k, k)

	if _meter_win.custom_minimum_size.x != _time_window.size.x or _meter_win.size.x > _meter_win.get_combined_minimum_size().x + 0.5:
		_meter_win.custom_minimum_size.x = _time_window.size.x
		_meter_win.reset_size()
	_quest_win.scale = Vector2(k, k)
	if _quest_win.custom_minimum_size.x != _time_window.size.x or _quest_win.size.x > _quest_win.get_combined_minimum_size().x + 0.5:
		_quest_win.custom_minimum_size.x = _time_window.size.x
		_quest_win.reset_size()
	_quest_win.position = Vector2(view.x - 8 - _quest_win.size.x * k, _time_window.position.y + (_time_window.size.y + 4) * k)
	var moved = Save.setting("meter_pos", [])
	if moved is Array and moved.size() == 2:
		if not _meter_drag:
			_meter_win.position = _meter_clamp(Vector2(float(moved[0]) * view.x, float(moved[1]) * view.y))
	else:

		_meter_win.position = Vector2(_time_window.position.x, _time_window.position.y + (_time_window.size.y + 4 + QUEST_SLOT) * k)


	if _quest_win.visible and not _meter_drag:
		var q: = Rect2(_quest_win.position, _quest_win.size * k)
		var m: = Rect2(_meter_win.position, _meter_win.size * k)
		if q.intersects(m):
			_meter_win.position.y = q.end.y + 4.0




const QUEST_SLOT: = 124
const QUEST_NAME_COLOR: = Color(0.5, 0.32, 0.04)

const QUEST_HURRY: = 15
const QUEST_HURRY_COLOR: = Color(0.75, 0.1, 0.1)


func _meter_clamp(pos: Vector2) -> Vector2:
	var view: = get_viewport().get_visible_rect().size
	var s: = _meter_win.size * _meter_win.scale
	return Vector2(clampf(pos.x, 0.0, maxf(0.0, view.x - s.x)), clampf(pos.y, 0.0, maxf(0.0, view.y - s.y)))


func _on_meter_input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:

			_meter.mode = METER_MODES[(METER_MODES.find(_meter.mode) + 1) % METER_MODES.size()]
			if _meter.mode == "party" and not world.is_coop():
				_meter.mode = "damage"
			_meter._icons.clear()
			_meter._timer = 0.0
			Save.set_setting("meter_mode", _meter.mode)
			world.play_sound("ui_click", 0.0, -10.0)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_meter_press = event.global_position
				_meter_off = event.global_position - _meter_win.position
			else:
				if _meter_drag:
					var view: = get_viewport().get_visible_rect().size
					Save.set_setting("meter_pos", [_meter_win.position.x / view.x, _meter_win.position.y / view.y])
				elif _meter_press != Vector2.INF and world != null and world.meter_details != null:

					var focus: = -1
					var tab: = _meter.mode
					if tab == "dps":
						tab = "damage"
					if tab == "party":
						var local: Vector2 = _meter.get_global_transform().affine_inverse() * (event as InputEventMouseButton).global_position
						var row: = int(local.y / _meter.row_height)
						if row >= 0 and row < _meter.data.size():
							focus = int(_meter.data[row].get("slot", -1))
						tab = "damage"
					world.meter_details.open(tab, focus)
				_meter_drag = false
				_meter_press = Vector2.INF
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:

			Save.set_setting("meter_pos", [])
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _meter_press != Vector2.INF:
		if not _meter_drag and event.global_position.distance_to(_meter_press) > 5.0:
			_meter_drag = true
		if _meter_drag:
			_meter_win.position = _meter_clamp(event.global_position - _meter_off)



func _barrier_max(p: Player) -> float:
	var best: = 0.0
	for id in p.skills:
		if GameData.SKILLS[id].type == "shield":
			best = maxf(best, GameData.skill_value(id, "amount", p.skills[id].level) + p.max_hp * float(GameData.SKILLS[id].get("amount_hp", 0.0)))
	return maxf(best * p.support_mult, p.shield)


func _refresh_skills() -> void :
	if world == null or world.player == null:
		return
	var skills: Dictionary = world.player.skills
	var signature: = ""
	for id in skills:
		signature += "%s:%d;" % [id, skills[id].level]

	var p: = world.player
	signature += "|%d|%s|%s" % [p.max_skills(), ",".join(p.pacts), p.obsession_on()]
	if signature == _skill_signature:
		return
	_skill_signature = signature

	for child in _skill_row.get_children() + _passive_row.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	_skill_slots.clear()
	var passives: = 0
	for id in skills:
		if Player.is_passive(id):
			passives += 1
			_make_slot(id, skills[id].level, _passive_row)
		else:
			_skill_slots.append(_make_slot(id, skills[id].level))

	if p.pacts.has("devotion") or p.pacts.has("solitude"):
		for i in maxi(0, p.max_skills() - _skill_slots.size()):
			_pact_slot()
	_passive_window.visible = passives > 0

	_skill_row.custom_minimum_size = Vector2(SLOT, SLOT) if _skill_slots.is_empty() else Vector2.ZERO
	_passive_title.text = tr("Pasivas  %d/%d") % [passives, world.player.max_passives()]
	_skill_title.text = tr("Skills  %d/%d") % [_skill_slots.size(), world.player.max_skills()]

	_skill_window.size = Vector2.ZERO
	_passive_window.size = Vector2.ZERO
	_skill_window.reset_size.call_deferred()
	_passive_window.reset_size.call_deferred()


	_layout.call_deferred()
	_toggle_tip_check.call_deferred()





var _toggle_tip: Control


func _toggle_tip_check() -> void :
	if not MouseWalk.touch() or _toggle_tip != null or bool(Save.setting("touch_toggle_tip", false)):
		return
	if world == null or world.player == null:
		return
	var p: Player = world.player
	for d in _skill_slots:
		var id: = str(d.id)
		if not (p.is_toggle(id) or p.is_hold(id)) or not is_instance_valid(d.get("slot")):
			continue
		Save.set_setting("touch_toggle_tip", true)
		_show_toggle_tip(d.slot, id)
		return


func _show_toggle_tip(slot: Control, id: String) -> void :
	var tip: = VBoxContainer.new()
	tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip.add_theme_constant_override("separation", -2)
	var panel: = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.97, 0.86)
	sb.border_color = Color(0.88, 0.62, 0.12)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(7)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 5
	sb.content_margin_bottom = 6
	sb.shadow_color = Color(0, 0, 0, 0.25)
	sb.shadow_size = 4
	panel.add_theme_stylebox_override("panel", sb)
	tip.add_child(panel)
	var text: = UiKit.label("%s\n%s" % [tr(str(GameData.SKILLS[id].name)), tr("Toca su ícono para apagarla o prenderla")], 13, Color(0.35, 0.22, 0.0), true)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(text)

	var arrow: = Control.new()
	arrow.custom_minimum_size = Vector2(0, 9)
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tri: = Polygon2D.new()
	tri.color = Color(0.88, 0.62, 0.12)
	tri.polygon = PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(0, 9)])
	arrow.add_child(tri)
	arrow.resized.connect( func(): tri.position = Vector2(arrow.size.x * 0.5, 0))
	tip.add_child(arrow)
	_root.add_child(tip)
	_toggle_tip = tip
	_place_toggle_tip.call_deferred(slot)
	tip.modulate.a = 0.0
	var tw: = tip.create_tween()
	tw.tween_property(tip, "modulate:a", 1.0, 0.25)

	get_tree().create_timer(9.0, false).timeout.connect(_hide_toggle_tip)


func _place_toggle_tip(slot: Control) -> void :
	if _toggle_tip == null or not is_instance_valid(_toggle_tip) or not is_instance_valid(slot):
		return
	var size: = _toggle_tip.get_combined_minimum_size()
	_toggle_tip.size = size
	var inv: = _root.get_global_transform_with_canvas().affine_inverse()
	var top: Vector2 = inv * (slot.get_global_transform_with_canvas() * Vector2(slot.size.x * 0.5, 0.0))
	var view: = _root.size if _root.size.x > 0.0 else get_viewport().get_visible_rect().size
	_toggle_tip.position = Vector2(clampf(top.x - size.x * 0.5, 4.0, maxf(4.0, view.x - size.x - 4.0)), top.y - size.y - 2.0)


func _hide_toggle_tip() -> void :
	if _toggle_tip == null or not is_instance_valid(_toggle_tip):
		_toggle_tip = null
		return
	var tip: = _toggle_tip
	_toggle_tip = null
	var tw: = tip.create_tween()
	tw.tween_property(tip, "modulate:a", 0.0, 0.3)
	tw.tween_callback(tip.queue_free)


func _make_slot(id: String, level: int, row: HBoxContainer = null) -> Dictionary:
	var def: Dictionary = GameData.SKILLS[id]
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(SLOT, SLOT)
	slot.texture_filter = RoAssets.ui_filter()
	var box: = UiStyles.hud_button_box("normal")
	box.set_content_margin_all(3)
	box.shadow_color = Color(0.05, 0.08, 0.2, 0.15)
	box.shadow_size = 2
	box.shadow_offset = Vector2(0, 1)
	if def.get("evolved", false):

		var gold: = StyleBoxFlat.new()
		gold.bg_color = Color(1.0, 0.93, 0.72)
		gold.border_color = GameData.LEGENDARY_COLOR
		gold.set_border_width_all(2)
		gold.set_corner_radius_all(6)
		gold.anti_aliasing = true
		gold.shadow_color = Color(GameData.LEGENDARY_COLOR, 0.45)
		gold.shadow_size = 3
		gold.set_content_margin_all(3)
		box = gold
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	_bind_hover(slot, func(): return _skill_hover(id))

	var p: = world.player
	var row_attack: = Player.counts_as_attack(id)

	if row_attack and p.obsession_on():
		var ob: = box.duplicate() as StyleBoxFlat
		ob.border_color = PACT_OBSESSION
		ob.set_border_width_all(2)
		ob.shadow_color = Color(PACT_OBSESSION, 0.6)
		ob.shadow_size = 4
		slot.add_theme_stylebox_override("panel", ob)
	if p.is_toggle(id) or p.is_hold(id):
		slot.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				world.skill_switch(id)
				_hide_toggle_tip()
				slot.accept_event())
	(row if row != null else _skill_row).add_child(slot)
	var icon_tex: = UiKit.skill_icon(id)
	if icon_tex != null:
		slot.add_child(UiKit.icon_rect(icon_tex, 24))
	else:
		var initials: = _ro_label(tr(str(def.name)).substr(0, 2), 11, true)
		initials.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		initials.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_child(initials)

	var holder: = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(holder)
	var veil: = ColorRect.new()
	veil.color = Color(0.1, 0.12, 0.2, 0.5)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.anchor_right = 1.0
	veil.anchor_bottom = 1.0
	veil.anchor_top = 1.0
	holder.add_child(veil)


	if GameData.skill_has_element(id) and Skills.shown_element(world.player, def) != "neutral":
		var gem: = Panel.new()
		var gb: = StyleBoxFlat.new()
		gb.bg_color = GameData.ELEMENT_COLORS[Skills.shown_element(world.player, def)]
		gb.border_color = Color(0.08, 0.08, 0.12)
		gb.set_border_width_all(1)
		gb.set_corner_radius_all(4)
		gem.add_theme_stylebox_override("panel", gb)
		gem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gem.position = Vector2(-1, -1)
		gem.size = Vector2(9, 9)
		holder.add_child(gem)
	var lv: = _ro_label(str(9 + level) if def.get("evolved", false) else str(level), 9, true)
	lv.add_theme_color_override("font_color", Color.WHITE)
	lv.add_theme_color_override("font_outline_color", Color.BLACK)
	lv.add_theme_constant_override("outline_size", 3)
	lv.anchor_left = 1.0
	lv.anchor_top = 1.0
	lv.anchor_right = 1.0
	lv.anchor_bottom = 1.0


	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lv.offset_left = -40
	lv.offset_top = -9
	lv.offset_right = 3
	lv.offset_bottom = 3
	holder.add_child(lv)


	var badge: PanelContainer = null
	if p.is_toggle(id) or p.is_hold(id):
		badge = PanelContainer.new()
		var bb: = StyleBoxFlat.new()
		bb.bg_color = Color(0.06, 0.07, 0.12, 0.92)
		bb.border_color = Color(0.4, 0.9, 0.5)
		bb.set_border_width_all(1)
		bb.set_corner_radius_all(3)
		bb.content_margin_left = 1
		bb.content_margin_right = 1
		badge.add_theme_stylebox_override("panel", bb)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var key: = _ro_label("F" if not MouseWalk.touch() and p.f_skill() != "" and (p.is_hold(id) or not p.is_hold(p.f_skill())) else "•", 8, true)
		key.add_theme_color_override("font_color", Color(0.6, 1.0, 0.65))
		key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key.custom_minimum_size = Vector2(8, 9)
		badge.add_child(key)
		badge.anchor_left = 1.0
		badge.anchor_right = 1.0
		badge.offset_left = -10
		badge.offset_top = -2
		badge.offset_right = 1
		badge.offset_bottom = 9
		holder.add_child(badge)

	if row_attack and p.obsession_on():
		holder.add_child(_pact_badge("x2", PACT_OBSESSION, badge == null))

	elif not row_attack and not Player.is_passive(id) and (p.pacts.has("devotion") or p.pacts.has("solitude")):
		holder.add_child(_pact_badge(_pact_free_text(), PACT_FREE, badge == null))
	return {"id": id, "veil": veil, "badge": badge, "slot": slot}


const PACT_FREE: = Color(1.0, 0.72, 0.2)
const PACT_OBSESSION: = Color(0.72, 0.4, 1.0)




func _pact_free_text() -> String:
	if world.player.pacts.has("devotion"):
		return "+%d%%" % roundi(float(GameData.PACTS.devotion.per_free.skill_dmg) * 100.0)
	return "+%d" % int(GameData.PACTS.solitude.per_free.targets)




func _pact_badge(text: String, col: Color, right: = true) -> Control:
	var l: = _ro_label(text, 7, true)
	l.add_theme_color_override("font_color", col.lightened(0.3))
	l.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.1, 0.9))
	l.add_theme_constant_override("outline_size", 3)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if right else HORIZONTAL_ALIGNMENT_LEFT
	l.anchor_left = 1.0 if right else 0.0
	l.anchor_right = l.anchor_left
	l.offset_left = -20.0 if right else -1.0
	l.offset_right = 1.0 if right else 20.0
	l.offset_top = -3.0
	l.offset_bottom = 7.0
	return l





func _pact_slot() -> void :
	var p: = world.player
	var slot: = PanelContainer.new()
	slot.custom_minimum_size = Vector2(SLOT, SLOT)
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1.0, 0.95, 0.8, 0.55)
	box.border_color = PACT_FREE
	box.set_border_width_all(2)
	box.set_corner_radius_all(6)
	box.shadow_color = Color(PACT_FREE, 0.5)
	box.shadow_size = 3
	box.anti_aliasing = true
	box.set_content_margin_all(3)
	slot.add_theme_stylebox_override("panel", box)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	var pact: = "devotion" if p.pacts.has("devotion") else "solitude"
	var icon_tex: = UiKit.skill_icon(str(GameData.PACTS[pact].icon))
	if icon_tex != null:
		var ic: = UiKit.icon_rect(icon_tex, 22)
		ic.modulate = Color(1, 1, 1, 0.85)
		slot.add_child(ic)
	var holder: = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(holder)
	holder.add_child(_pact_badge(_pact_free_text(), PACT_FREE))
	_skill_row.add_child(slot)
	var tw: = slot.create_tween().set_loops()
	tw.tween_property(slot, "modulate", Color(1.15, 1.1, 0.95), 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(slot, "modulate", Color(0.85, 0.85, 0.85), 0.9).set_trans(Tween.TRANS_SINE)
	_bind_hover(slot, func(): return _pact_slot_hover())


func _pact_slot_hover() -> Dictionary:
	var p: = world.player
	var lines: = []
	var n: = p.free_attack_slots()
	if p.pacts.has("devotion"):
		var per: Dictionary = GameData.PACTS.devotion.per_free
		lines.append([tr("Pacto de Devoción"), tr("+%d%% daño de habilidades · %d%% recarga · +%d%% área") % [
			roundi(float(per.skill_dmg) * 100.0 * n), roundi(float(per.haste) * 100.0 * n), roundi(float(per.area) * 100.0 * n)], PACT_FREE])
	if p.pacts.has("solitude"):
		var per2: Dictionary = GameData.PACTS.solitude.per_free
		lines.append([tr("Pacto de Soledad"), tr("+%d objetivos · +%d%% daño del ataque básico") % [
			int(per2.targets) * n, roundi(float(per2.basic_dmg) * 100.0 * n)], PACT_FREE])
	return {"icon": UiKit.skill_icon(str(GameData.PACTS["devotion" if p.pacts.has("devotion") else "solitude"].icon)), 
		"title": tr("Ranura libre"), "color": PACT_FREE, 
		"tag": tr_n("%d ranura sin habilidad de ataque", "%d ranuras sin habilidad de ataque", n) % n, 
		"desc": tr("Cada ranura que no ocupa una habilidad de ataque potencia tu pacto. Los buffs, curas y escudos cuentan como libres."), 
		"lines": lines, "foot": []}


func _update_cooldowns() -> void :
	var p: = world.player
	for s in _skill_slots:
		if not p.skills.has(s.id):
			continue
		var st: Dictionary = p.skills[s.id]
		var full: = GameData.skill_value(s.id, "cooldown", st.level) * p.cd_for(s.id)

		var frac: = clampf(st.cd / maxf(full, 0.01), 0.0, 1.0) if st.cd > 0.2 else 0.0

		if GameData.SKILLS[s.id].get("stance", false):
			frac = 0.0
		var veil: ColorRect = s.veil

		var off: bool = p.is_off(s.id)

		var top: = 0.0 if off else 1.0 - frac
		if veil.anchor_top != top or veil.offset_top != 0.0:
			veil.anchor_top = top
			veil.offset_top = 0.0
		var badge = s.get("badge")
		if badge != null and is_instance_valid(badge):
			var running: bool = p.is_hold(s.id) and p.powers.has(Player.base_skill(s.id))
			var c: = Color(1.0, 0.3, 0.25) if off else (Color(1.0, 0.8, 0.3) if running else Color(0.45, 0.95, 0.5))

			if s.get("badge_c") != c:
				s["badge_c"] = c
				(badge.get_theme_stylebox("panel") as StyleBoxFlat).border_color = c
				(badge.get_child(0) as Label).add_theme_color_override("font_color", c)


func _refresh_cards() -> void :
	var cards: Array = world.player.cards
	if cards.size() == _cards_count:
		return
	_cards_count = cards.size()
	for child in _cards_row.get_children():
		child.queue_free()


	var counts: = {}
	for id in cards:
		counts[id] = int(counts.get(id, 0)) + 1
	var kinds: Array = counts.keys()
	for i in kinds.size():
		var id: String = kinds[i]
		var r: = TextureRect.new()
		r.texture = RoAssets.card_art(id)
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.custom_minimum_size = CARD_SIZE
		r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		r.mouse_filter = Control.MOUSE_FILTER_STOP
		_bind_hover(r, func(): return _card_hover(id, int(counts[id])))
		r.gui_input.connect( func(ev: InputEvent):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				world.menus.show_card_view(id, int(counts[id])))
		_cards_row.add_child(r)
		if int(counts[id]) > 1:
			var badge: = _ro_label("x%d" % counts[id], 9, true)
			badge.add_theme_color_override("font_color", Color.WHITE)
			badge.add_theme_color_override("font_outline_color", Color.BLACK)
			badge.add_theme_constant_override("outline_size", 3)
			badge.position = Vector2(6, CARD_SIZE.y - 13)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			r.add_child(badge)
	_cards_title.text = tr("Cartas  %d") % cards.size()

	_cards_win.visible = false
	_cards_win.reset_size()




func _boss_element_line(el: String) -> String:
	var best: = 1.01
	var weak: Array[String] = []
	for a in GameData.ELEMENT_ORDER:
		var m: = GameData.element_mult(str(a), el)
		if m > best + 0.001:
			best = m
			weak = [tr(str(GameData.ELEMENT_NAMES[a]))]
		elif absf(m - best) < 0.001 and m > 1.01:
			weak.append(tr(str(GameData.ELEMENT_NAMES[a])))
	var line: = tr("Elemento: %s") % tr(str(GameData.ELEMENT_NAMES.get(el, el)))
	if not weak.is_empty():
		line += "  ·  " + tr("débil a %s") % ", ".join(weak)
	return line
