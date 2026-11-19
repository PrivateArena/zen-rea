class_name Pushcart
extends RoVisual








const BEHIND: = 1.35

const MIN_GAP: = 1.0


const SWING: = 260.0

const SNAP: = 4.0

const FRICTION: = 7.0

const TURN_SLACK: = 8.0

const WHEEL_RATE: = 0.3

const BUMP: = 0.035
const BUMP_EVERY: = 0.45



const SPRING: = 55.0
const DAMP: = 9.0
const STRETCH: = 1.18

var _placed: = false
var _squash: = 0.0
var _hop: = 0.0
var _fall: = 0.0
var _vel: = Vector3.ZERO
var _rolled: = 0.0
var _last_hitch: = Vector3.ZERO


static func make(parent: Node3D) -> Pushcart:
	var spr: = RoAssets.sprite(["quest_cart"])
	if spr == null:
		return null
	var cart: = Pushcart.new()
	parent.add_child(cart)


	cart.top_level = true
	cart.follow_view()
	cart.setup(spr, Color.WHITE, 20, 0.0)
	cart.play(0, true)
	return cart





func follow(body: RoVisual, _moving: bool, map: RoMap = null) -> void :
	var delta: = get_process_delta_time()
	var hitch: = (get_parent() as Node3D).global_position
	visible = body.visible
	if not _placed or global_position.distance_to(hitch) > SNAP:
		_place_behind(body, hitch)
		_last_hitch = hitch
		_ground(map, true)
		return
	var walk: = (hitch - _last_hitch) / maxf(delta, 0.0001)
	walk.y = 0.0
	_last_hitch = hitch
	var before: = global_position
	var cur: = before - hitch
	cur.y = 0.0
	if cur.length() < 0.01:
		cur = - walk.normalized() * BEHIND if walk.length() > 0.1 else Vector3(0, 0, BEHIND)


	var aim: = cur.normalized()
	if walk.length() > 0.5:
		var turn: = aim.signed_angle_to( - walk, Vector3.UP)
		var most: = deg_to_rad(SWING) * delta
		aim = aim.rotated(Vector3.UP, clampf(turn, - most, most))
	var want: = hitch + aim * BEHIND


	var pull: = want - before
	pull.y = 0.0
	_vel += pull * SPRING * delta
	_vel *= exp( - DAMP * delta)
	_vel.y = 0.0
	var pos: = before + _vel * delta
	var off: = pos - hitch
	off.y = 0.0
	var dist: = off.length()
	if dist > BEHIND * STRETCH:
		pos = hitch + off / dist * BEHIND * STRETCH
	elif dist < MIN_GAP and dist > 0.001:
		pos = hitch + off / dist * MIN_GAP


	if map != null and not map.is_walkable(pos):
		var slide_x: = Vector3(pos.x, pos.y, before.z)
		var slide_z: = Vector3(before.x, pos.y, pos.z)
		if map.is_walkable(slide_x):
			pos = slide_x
		elif map.is_walkable(slide_z):
			pos = slide_z
		else:
			pos = before.lerp(hitch, 0.25)
		_vel *= 0.3
	pos.y = before.y
	global_position = pos
	var moved: = pos - before
	moved.y = 0.0
	var speed: = moved.length() / maxf(delta, 0.0001)
	if (hitch - pos).length() > 0.05:
		_turn(hitch - pos)
	_ground(map, false)


	speed_scale = clampf(speed * WHEEL_RATE, 0.0, 2.5)
	_rolled += moved.length()
	var bump: = absf(sin(_rolled / BUMP_EVERY * PI)) * BUMP * clampf(speed / 3.0, 0.0, 1.0)
	_squash = move_toward(_squash, 0.0, delta * 3.0)
	sprite.position = RoVisual.lift + Vector3(0, bump + _hop, 0)
	sprite.scale = Vector3(1.0 + _squash * 0.6, 1.0 - _squash, 1.0)




func _ground(map: RoMap, snap: bool) -> void :
	if map == null:
		return
	var g: = map.height_at(global_position)
	if snap:
		global_position.y = g
		_hop = 0.0
		return
	var delta: = get_process_delta_time()
	var y: = global_position.y
	if g < y - 0.15:

		_fall += 18.0 * delta
		y = maxf(g, y - _fall * delta)
		if y <= g + 0.001:
			_squash = clampf(_fall * 0.03, 0.05, 0.25)
			_fall = 0.0
	else:
		_fall = 0.0
		y = lerpf(y, g, minf(1.0, delta * 18.0))
	global_position.y = y
	_hop = 0.0


func _place_behind(body: RoVisual, hitch: Vector3) -> void :

	var a: = body.dir * PI / 4.0
	global_position = hitch + Vector3(sin(a), 0.0, - cos(a)) * BEHIND
	_vel = Vector3.ZERO
	_set_dir(body.dir)
	_placed = true




func _turn(towards: Vector3) -> void :
	var want: = rad_to_deg(atan2( - towards.x, towards.z))
	var centre: = float(dir) * 45.0
	if absf(wrapf(want - centre, -180.0, 180.0)) > 22.5 + TURN_SLACK:
		_set_dir(posmod(roundi(want / 45.0), 8))


func _set_dir(d: int) -> void :
	if d != dir:
		dir = d
		_refresh()
