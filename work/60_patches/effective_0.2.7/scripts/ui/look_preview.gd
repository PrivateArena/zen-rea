extends VBoxContainer








const SCALE: = 2.0



static var POSES: = [[UiKit.tr_later("Quieto"), 0, true], [UiKit.tr_later("Caminar"), 1, true], [UiKit.tr_later("Sentado"), 2, false], 
	[UiKit.tr_later("Combate"), 4, true], [UiKit.tr_later("Atacar"), 5, true], [UiKit.tr_later("Lanzar"), 12, true], [UiKit.tr_later("Herido"), 6, true]]

var stage_size: = Vector2(220, 260)

const FEET: = 52.0
var auto_turn: = false
var show_controls: = true
var dir: = 0
var pose: = 0

static var _saved_dir: = 0
static var _saved_pose: = 0

var _ro: RoSprite
var _stage: Control
var _pic: TextureRect
var _frame: = 0
var _t: = 0.0
var _drag_x: = 0.0
var _dragging: = false
var _turns: = 0
var _pose_buttons: Array[Button] = []



func setup(body: String, weapon: String, look: Dictionary, headgear: String, extras: Array) -> void :
	_ro = RoAssets.styled_character(body, weapon, "", [], headgear, look, "", extras)
	_outfit = body.begins_with("outfit_")
	_outfit_sits = _outfit and GameData.outfit_sits(body)





var _outfit: = false
var _outfit_sits: = false
const OUTFIT_POSES: = ["Quieto", "Caminar", "Herido"]


func _outfit_pose(name: String) -> bool:
	return OUTFIT_POSES.has(name) or (name == "Sentado" and _outfit_sits)


func _ready() -> void :
	if not auto_turn:
		dir = _saved_dir
		pose = _saved_pose
	add_theme_constant_override("separation", 6)


	var k: = minf(1.0, stage_size.y / 260.0)



	if _ro != null and _ro.origin.y > 0:
		k = minf(k, (stage_size.y - 6.0) / (float(_ro.origin.y) * SCALE + FEET))
	var feet: = FEET * k
	_stage = Control.new()
	_stage.custom_minimum_size = stage_size
	_stage.clip_contents = true
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage.mouse_default_cursor_shape = Control.CURSOR_DRAG if show_controls else Control.CURSOR_ARROW
	_stage.gui_input.connect(_on_stage_input)
	_stage.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(_stage)
	var glow: = UiKit.glow(Color(0.5, 0.6, 0.95, 0.35), stage_size.x * 0.8)
	glow.position = Vector2(stage_size.x * 0.1, stage_size.y - stage_size.x * 0.8 * 0.5 - feet - 6.0)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(glow)
	var shadow: = _Shadow.new()
	shadow.position = Vector2(stage_size.x * 0.5, stage_size.y - feet)
	_stage.add_child(shadow)
	_pic = TextureRect.new()
	_pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_pic.stretch_mode = TextureRect.STRETCH_SCALE
	_pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_pic)
	if _ro != null:
		_pic.size = Vector2(_ro.canvas_size) * SCALE * k

		_pic.position = (Vector2(stage_size.x * 0.5, stage_size.y - feet) - Vector2(_ro.origin) * SCALE * k).round()
	if show_controls:
		_build_controls()
	_show()


func _build_controls() -> void :
	var turn: = HBoxContainer.new()
	turn.alignment = BoxContainer.ALIGNMENT_CENTER
	turn.add_theme_constant_override("separation", 6)
	add_child(turn)
	var left: = UiKit.button("◀")
	left.custom_minimum_size = Vector2(40, 28)
	left.focus_mode = Control.FOCUS_NONE
	left.tooltip_text = tr("Girar")
	left.pressed.connect( func(): _turn(1))
	turn.add_child(left)
	var hint: = UiKit.label(tr("Arrastra para girar"), 10, UiKit.MUTED)
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	turn.add_child(hint)
	var right: = UiKit.button("▶")
	right.custom_minimum_size = Vector2(40, 28)
	right.focus_mode = Control.FOCUS_NONE
	right.tooltip_text = tr("Girar")
	right.pressed.connect( func(): _turn(-1))
	turn.add_child(right)
	var grid: = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(grid)
	if _outfit and not _outfit_pose(str(POSES[clampi(pose, 0, POSES.size() - 1)][0])):
		pose = 0
	for i in POSES.size():
		if _outfit and not _outfit_pose(str(POSES[i][0])):
			_pose_buttons.append(null)
			continue
		var b: = UiKit.button(tr(str(POSES[i][0])))
		b.custom_minimum_size = Vector2(56, 24)
		b.add_theme_font_size_override("font_size", 10)
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect( func():
			pose = i
			_frame = 0
			_t = 0.0
			_paint_poses()
			_show())
		grid.add_child(b)
		_pose_buttons.append(b)
	_paint_poses()


func _paint_poses() -> void :
	for i in _pose_buttons.size():
		if _pose_buttons[i] == null:
			continue
		_pose_buttons[i].modulate = Color(1.0, 0.85, 0.45) if i == pose else Color.WHITE


func _turn(step: int) -> void :
	dir = posmod(dir + step, RoSprite.DIRS)
	_show()


func _on_stage_input(event: InputEvent) -> void :
	if not show_controls:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		_drag_x = event.position.x
	elif event is InputEventScreenTouch:
		_dragging = event.pressed
		_drag_x = event.position.x
	elif (event is InputEventMouseMotion and _dragging) or event is InputEventScreenDrag:

		var dx: float = event.position.x - _drag_x
		if absf(dx) >= 28.0:
			_turn(-1 if dx > 0.0 else 1)
			_drag_x = event.position.x




func _action() -> int:
	var base: = int(POSES[clampi(pose, 0, POSES.size() - 1)][1])
	if auto_turn:
		base = 1
	var a: = base * RoSprite.DIRS + dir
	if _ro == null or _ro.frame_count(a) <= 0:
		return dir
	return a



var _sub: = 0


func _process(delta: float) -> void :
	if _ro == null:
		return
	var a: = _action()



	if not auto_turn and int(POSES[clampi(pose, 0, POSES.size() - 1)][1]) in [0, 2]:

		if _frame != 0 or (_ro.anim_steps(a) > 1 and _ro.anim_sub(a) != _sub):
			_frame = 0
			_show()
		return
	var n: = maxi(1, _ro.frame_count(a))
	_t += delta
	var step: = maxf(0.05, _ro.frame_delay(a))
	if _t < step:
		return
	_t = 0.0
	var loops: bool = auto_turn or bool(POSES[clampi(pose, 0, POSES.size() - 1)][2])
	if _frame + 1 >= n:
		if not loops:
			return
		_frame = 0
		if auto_turn:
			_turns += 1
			if _turns % 2 == 0:
				dir = posmod(dir + 1, RoSprite.DIRS)
	else:
		_frame += 1
	_show()


func _show() -> void :
	if not auto_turn:
		_saved_dir = dir
		_saved_pose = pose
	if _ro == null or _pic == null:
		return
	var a: = _action()
	_frame = clampi(_frame, 0, maxi(0, _ro.frame_count(a) - 1))
	_sub = _ro.anim_sub(a)
	_pic.texture = _ro.get_frame(a, _frame, _sub)



class _Shadow extends Node2D:
	func _draw() -> void :
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.35))
		draw_circle(Vector2.ZERO, 26.0, Color(0.2, 0.25, 0.45, 0.18))
		draw_circle(Vector2.ZERO, 17.0, Color(0.2, 0.25, 0.45, 0.16))
