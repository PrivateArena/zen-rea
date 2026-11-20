class_name RoCursor
extends Node








const DEFAULT: = 0
const TALK: = 1
const CLICK: = 2
const ROTATE: = 4
const ATTACK: = 5
const WARP: = 7
const PICK: = 9

const LOOK_EVERY: = 0.08

const MIN_DELAY: = 0.12

const HOVER_PX: = 26.0

var world: World

var mode: = DEFAULT
var _frames: = {}
var _shown: = {}
var _time: = 0.0
var _look: = 0.0


func _ready() -> void :
	name = "RoCursor"
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void :
	_time += delta
	_look -= delta
	if _look <= 0.0:
		_look = LOOK_EVERY
		mode = _hovered()
	_show(Input.CURSOR_ARROW, mode)



	if mode == ROTATE or get_viewport().gui_get_hovered_control() != null or not _shown.has(Input.CURSOR_POINTING_HAND):
		_show(Input.CURSOR_POINTING_HAND, ROTATE if mode == ROTATE else CLICK)



func _hovered() -> int:
	if world == null:
		return DEFAULT
	if world._turning:
		return ROTATE
	if get_viewport().gui_get_hovered_control() != null or world.get_tree().paused or world.camera == null:
		return DEFAULT
	var mouse: = get_viewport().get_mouse_position()
	if world.town != null:
		return TALK if world.town.npc_at(mouse) >= 0 else DEFAULT
	if not world.running or world.player == null:
		return DEFAULT
	var ground: = world.mouse_walk._ground_under_mouse()
	if ground == Vector3.INF:
		return DEFAULT
	var portal: = world.raid.portal_pos
	if portal != Vector3.INF and _flat(ground, portal) < 1.6:
		return WARP
	var q: = world.quest
	if q != null and q.npc != null and is_instance_valid(q.npc) and q.npc.visible and _over(q.npc.position, 2.0, mouse):
		return TALK
	for p in world.pickups:
		if p.kind != "xp" and is_instance_valid(p.node) and p.node.visible and _flat(ground, p.node.global_position) < 0.9:
			return PICK
	for e in world.enemies_in_radius(ground, 4.0):
		if not e.dead and e.prop == "" and e.visual != null and _over(e.position, e.visual.height() * (GameData.MVP_SCALE if e.def.get("mvp", false) else 1.0), mouse):
			return ATTACK
	return DEFAULT



func _over(feet: Vector3, height: float, mouse: Vector2) -> bool:
	var cam: = world.camera
	var mid: = feet + RoVisual.world_lift() + World.view_up() * height * 0.5
	if cam.is_position_behind(mid):
		return false
	var k: = maxf(1.0, get_viewport().get_visible_rect().size.y / 720.0)
	var top: = cam.unproject_position(feet + RoVisual.world_lift() + World.view_up() * height)
	var low: = cam.unproject_position(feet + RoVisual.world_lift())
	var c: = cam.unproject_position(mid)
	var half: = maxf(HOVER_PX * k, low.distance_to(top) * 0.5)
	return absf(mouse.x - c.x) < maxf(HOVER_PX * k, half * 0.6) and absf(mouse.y - c.y) < half



func _show(shape: int, action: int) -> void :
	var frames: = _frames_of(action)
	if frames.is_empty():
		return





	var delay: float = maxf(float(frames[0][2]), MIN_DELAY)
	var i: = 0 if action in [DEFAULT, CLICK] else int(_time / delay) % frames.size()
	var key: = action * 1000 + i
	if _shown.get(shape, -1) == key:
		return
	_shown[shape] = key
	Input.set_custom_mouse_cursor(frames[i][0], shape, frames[i][1])




func _frames_of(action: int) -> Array:
	if _frames.has(action):
		return _frames[action]
	var out: = []
	var spr: = RoAssets.sprite(["cursors"])
	if spr != null:
		var k: = 2 if DisplayServer.screen_get_size().y >= 2000 else 1
		var delay: = spr.frame_delay(action)
		for f in spr.frame_count(action):
			var img: = spr.compose_image(action, f)
			var used: = img.get_used_rect()
			if used.size.x <= 0:
				continue
			img = img.get_region(used)

			var hot: = Vector2(spr.origin - used.position)
			if k > 1:
				img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
				hot *= k
			hot = hot.clamp(Vector2.ZERO, Vector2(img.get_size()) - Vector2.ONE)


			out.append([img, hot, delay])
	_frames[action] = out
	return out


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
