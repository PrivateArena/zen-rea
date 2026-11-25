class_name FlowField
extends RefCounted







const RADIUS: = 36
const REBUILD_EVERY: = 0.25

var map: RoMap
var _size: = RADIUS * 2 + 1
var _origin: = Vector2i.ZERO
var _center: = Vector2i(-99999, -99999)
var _dist: = PackedInt32Array()
var _queue: = PackedInt32Array()
var _timer: = 0.0

const BUILD_BUDGET: = 1400
const STEPS_X: = [1, -1, 0, 0]
const STEPS_Y: = [0, 0, 1, -1]

var _building: = false
var _b_dist: = PackedInt32Array()
var _b_origin: = Vector2i.ZERO
var _b_center: = Vector2i(-99999, -99999)
var _b_open: = false
var _head: = 0
var _tail: = 0


var _open: = false


func _init() -> void :
	_dist.resize(_size * _size)
	_b_dist.resize(_size * _size)
	_queue.resize(_size * _size)


func reset() -> void :
	_center = Vector2i(-99999, -99999)
	_open = false
	_building = false
	_dist.fill(-1)


func update(delta: float, hero: Vector3) -> void :
	if map == null:
		return


	if _building:
		_step(BUILD_BUDGET)
		return
	_timer -= delta
	if _timer > 0.0:
		return
	var c: = map.tile_of(hero)
	if c == _center:
		return
	_timer = REBUILD_EVERY
	_begin(c)



func _begin(c: Vector2i) -> void :
	_b_center = c
	_b_origin = c - Vector2i(RADIUS, RADIUS)
	_b_open = map.blocked_in(_b_origin.x, _b_origin.y, _b_origin.x + _size - 1, _b_origin.y + _size - 1) == 0
	if _b_open or not map.cell_walkable(c.x, c.y):
		_b_dist.fill(-1)
		_finish()
		return
	_b_dist.fill(-1)
	var start: = RADIUS * _size + RADIUS
	_b_dist[start] = 0
	_queue[0] = start
	_head = 0
	_tail = 1
	_building = true
	_step(BUILD_BUDGET)



func _step(budget: int) -> void :

	var walk: PackedByteArray = map._walk
	var any: = walk.is_empty()
	var mw: = map.width
	var mh: = map.height
	var ox: = _b_origin.x
	var oy: = _b_origin.y
	var size: = _size
	var head: = _head
	var tail: = _tail
	var stop: = head + budget
	while head < tail and head < stop:
		var i: = _queue[head]
		head += 1
		var lx: = i % size
		var ly: = i / size
		var nd: = _b_dist[i] + 1
		for k in 4:
			var nx: int = lx + STEPS_X[k]
			var ny: int = ly + STEPS_Y[k]
			if nx < 0 or ny < 0 or nx >= size or ny >= size:
				continue
			var j: = ny * size + nx
			if _b_dist[j] != -1:
				continue
			var gx: = ox + nx
			var gy: = oy + ny
			if gx < 1 or gy < 1 or gx >= mw - 1 or gy >= mh - 1 or not (any or walk[gy * mw + gx] == 49):
				_b_dist[j] = -2
				continue
			_b_dist[j] = nd
			_queue[tail] = j
			tail += 1
	_head = head
	_tail = tail
	if head >= tail:
		_finish()



func _finish() -> void :
	_building = false
	var d: = _dist
	_dist = _b_dist
	_b_dist = d
	_origin = _b_origin
	_center = _b_center
	_open = _b_open



func reachable(at: Vector3) -> bool:
	if map == null:
		return false
	var t: = map.tile_of(at)
	var lx: = t.x - _origin.x
	var ly: = t.y - _origin.y
	if lx < 0 or ly < 0 or lx >= _size or ly >= _size:
		return false
	if _open:
		return map.cell_walkable(t.x, t.y)
	return _dist[ly * _size + lx] >= 0





func direction(from: Vector3) -> Vector3:
	if _open:
		return Vector3.ZERO
	var t: = map.tile_of(from)
	var lx: = t.x - _origin.x
	var ly: = t.y - _origin.y
	if lx < 0 or ly < 0 or lx >= _size or ly >= _size:
		return Vector3.ZERO
	var d: = _dist[ly * _size + lx]
	if d <= 2:
		return Vector3.ZERO



	var straight: = Vector2(lx - RADIUS, ly - RADIUS).length()
	if d <= straight * 1.42 + 2.0 and not _blocked_ahead(t, Vector2(RADIUS - lx, RADIUS - ly)):
		return Vector3.ZERO
	var best: = d
	var bx: = lx
	var by: = ly
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx: int = lx + dx
			var ny: int = ly + dy
			if nx < 0 or ny < 0 or nx >= _size or ny >= _size:
				continue
			var nd: = _dist[ny * _size + nx]
			if nd < 0 or nd >= best:
				continue

			if dx != 0 and dy != 0 and (_dist[ly * _size + nx] < 0 or _dist[ny * _size + lx] < 0):
				continue
			best = nd
			bx = nx
			by = ny
	if best == d:
		return Vector3.ZERO
	var to: = map.cell_center(_origin.x + bx, _origin.y + by) - from
	to.y = 0.0
	return to.normalized() if to.length_squared() > 0.0001 else Vector3.ZERO



func _blocked_ahead(t: Vector2i, dir: Vector2) -> bool:
	if dir.length_squared() < 0.01:
		return false
	var n: = dir.normalized()
	for step in [0.7, 1.4, 2.2]:
		var c: = Vector2i(roundi(t.x + n.x * step), roundi(t.y + n.y * step))
		if c != t and not map.cell_walkable(c.x, c.y):
			return true
	return false
