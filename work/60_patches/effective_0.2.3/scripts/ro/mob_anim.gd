class_name MobAnim
extends RefCounted




signal finished

var ro: RoSprite

var node: Node3D


var _delays: = PackedFloat32Array()
var _counts: = PackedInt32Array()
var _last: = 0
var base_action: = 0

var dir: = 0
var _face: = Vector3.ZERO
var _face_dir: = -1
var frame: = 0
var speed_scale: = 1.0

var alpha: = 1.0
var flash_time: = 0.0

var tint: = 0.0


var look: = 0.0
var grow: = 1.0

var size: = 1.0
var shrink: = 0.0
var _time: = 0.0
var _loop: = true
var _done: = false


func _init(p_ro: RoSprite, delays: = PackedFloat32Array(), counts: = PackedInt32Array()) -> void :
	ro = p_ro
	if delays.is_empty():
		var t: = tables(p_ro)
		delays = t[0]
		counts = t[1]
	_delays = delays
	_counts = counts
	_last = mini(delays.size(), counts.size()) - 1




static func tables(p_ro: RoSprite) -> Array:
	var delays: = PackedFloat32Array()
	var counts: = PackedInt32Array()
	for a in maxi(1, p_ro.action_count()):
		delays.append(p_ro.frame_delay(a))
		counts.append(p_ro.frame_count(a))
	return [delays, counts]


func play(base: int, loop: = true, restart: = false) -> void :
	if base == base_action and not restart and not _done:
		return
	base_action = base
	_loop = loop
	_done = false
	frame = 0
	_time = 0.0


func face(v: Vector3) -> void :
	if v.length_squared() < 0.0001:
		return


	dir = posmod(roundi(atan2( - v.x, v.z) / (PI / 4.0)), 8)
	_face = Vector3(v.x, 0.0, v.z)
	_face_dir = dir


func flash() -> void :
	flash_time = 0.12


func height() -> float:
	return ro.origin.y * GameData.PIXEL_SIZE


func action() -> int:
	return base_action * RoSprite.DIRS + (dir if RoVisual.view_yaw == 0.0 else RoVisual.view_dir(dir, _face, _face_dir))


func advance(delta: float) -> void :
	flash_time -= delta
	if shrink > 0.0 or size < 1.0:
		shrink -= delta
		size = move_toward(size, GameData.SHRINK_SIZE if shrink > 0.0 else 1.0, delta * 3.0)
	if _done:
		return
	_time += delta * speed_scale
	var a: = clampi(action(), 0, _last)
	var delay: = _delays[a]
	while _time >= delay:
		_time -= delay
		frame += 1
		if frame >= _counts[a]:
			if _loop:
				frame = 0
			else:
				frame = _counts[a] - 1
				_done = true
				finished.emit()
				return





func write(buf: PackedFloat32Array, o: int, delta: float, lift: Vector3, starts: PackedInt32Array, cells: PackedFloat32Array) -> void :

	flash_time -= delta
	if shrink > 0.0 or size < 1.0:
		shrink -= delta
		size = move_toward(size, GameData.SHRINK_SIZE if shrink > 0.0 else 1.0, delta * 3.0)
	var a: = base_action * RoSprite.DIRS + (dir if RoVisual.view_yaw == 0.0 else RoVisual.view_dir(dir, _face, _face_dir))
	if not _done:
		_time += delta * speed_scale
		var k: = clampi(a, 0, _last)
		var delay: = _delays[k]
		while _time >= delay:
			_time -= delay
			frame += 1
			if frame >= _counts[k]:
				if _loop:
					frame = 0
				else:
					frame = _counts[k] - 1
					_done = true
					finished.emit()
					break
	a = mini(a, starts.size() - 1)
	var pos: = node.position
	buf[o] = size * grow
	buf[o + 3] = pos.x + lift.x
	buf[o + 7] = pos.y + lift.y
	buf[o + 11] = pos.z + lift.z
	buf[o + 12] = cells[mini(starts[a] + frame, cells.size() - 1)]
	buf[o + 13] = look + 1.0 if flash_time > 0.0 else look
	buf[o + 14] = alpha
	buf[o + 15] = tint
