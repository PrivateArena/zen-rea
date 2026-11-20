extends RefCounted



















const CELL: = 2.0
const SEP_CELL: = 1.0

const SEP_MAX_TOUCH: = 6

const BITS: = 12
const MASK: = (1 << BITS) - 1

const OFF: = 16384
const ROW: = 32768

var world: World

var mobs: Array[Enemy] = []
var px: = PackedFloat32Array()
var pz: = PackedFloat32Array()
var pr: = PackedFloat32Array()


var cells: = {}
var order: = PackedInt32Array()
var sep_cells: = {}
var sep_order: = PackedInt32Array()

var big: Array[Enemy] = []

var max_radius: = 0.4
var _keys: = PackedInt64Array()
var _sep_keys: = PackedInt64Array()


func _init(p_world: World) -> void :
	world = p_world


static func key(x: int, z: int) -> int:
	return (x + OFF) * ROW + (z + OFF)


func clear() -> void :
	mobs.clear()
	cells.clear()
	sep_cells.clear()
	big.clear()
	px.clear()
	pz.clear()
	pr.clear()
	order.clear()
	sep_order.clear()


func rebuild(list: Array[Enemy]) -> void :
	mobs = list.duplicate()
	var n: = mobs.size()
	px.resize(n)
	pz.resize(n)
	pr.resize(n)
	_keys.resize(n)
	_sep_keys.resize(n)
	big.clear()
	var top: = 0.0
	var ns: = 0
	for i in n:
		var e: Enemy = mobs[i]
		var p: = e.position
		var r: = e.radius
		px[i] = p.x
		pz[i] = p.z
		pr[i] = r
		_keys[i] = (((floori(p.x / CELL) + OFF) * ROW + floori(p.z / CELL) + OFF) << BITS) | i
		if e.is_boss:
			big.append(e)
			continue
		_sep_keys[ns] = (((floori(p.x / SEP_CELL) + OFF) * ROW + floori(p.z / SEP_CELL) + OFF) << BITS) | i
		ns += 1
		if r > top:
			top = r
	max_radius = top
	_sep_keys.resize(ns)
	_keys.sort()
	_sep_keys.sort()
	order = _runs(_keys, cells)
	sep_order = _runs(_sep_keys, sep_cells)




static func _runs(keys: PackedInt64Array, into: Dictionary) -> PackedInt32Array:
	into.clear()
	var n: = keys.size()
	var idx: = PackedInt32Array()
	idx.resize(n)
	var last: = -1
	var start: = 0
	for j in n:
		var k: = keys[j]
		idx[j] = k & MASK
		var c: = k >> BITS
		if c != last:
			if last != -1:
				into[last] = Vector2i(start, j)
			last = c
			start = j
	if last != -1:
		into[last] = Vector2i(start, n)
	return idx






func in_radius(center: Vector3, radius: float) -> Array[Enemy]:
	var out: Array[Enemy] = []
	var walled: = world.morroc != null and world.morroc.fighting()
	var r: = ceili(radius / CELL)
	var cx: = floori(center.x / CELL)
	var cz: = floori(center.z / CELL)
	for x in range(cx - r, cx + r + 1):
		var kx: = (x + OFF) * ROW + OFF
		for z in range(cz - r, cz + r + 1):
			var run = cells.get(kx + z)
			if run == null:
				continue
			for j in range(run.x, run.y):
				var e: Enemy = mobs[order[j]]


				if not is_instance_valid(e) or e.dead:
					continue
				var ep: = e.position
				var dx: = ep.x - center.x
				var dz: = ep.z - center.z
				var rr: = radius + e.radius
				if dx * dx + dz * dz <= rr * rr:
					if walled and world.morroc.walled(e):
						continue
					out.append(e)
	return out




func nearest(center: Vector3, max_range: float, count: int) -> Array[Enemy]:
	var best: Array[Enemy] = []
	var best_d: = PackedFloat32Array()
	if count <= 0:
		return best
	var boss: Enemy = world.boss
	var boss_in: = false
	var walled: = world.morroc != null and world.morroc.fighting()
	var r: = ceili(max_range / CELL)
	var cx: = floori(center.x / CELL)
	var cz: = floori(center.z / CELL)
	for x in range(cx - r, cx + r + 1):
		var kx: = (x + OFF) * ROW + OFF
		for z in range(cz - r, cz + r + 1):
			var run = cells.get(kx + z)
			if run == null:
				continue
			for j in range(run.x, run.y):
				var e: Enemy = mobs[order[j]]


				if not is_instance_valid(e) or e.dead or e.prop != "":
					continue
				var ep: = e.position
				var dx: = ep.x - center.x
				var dz: = ep.z - center.z
				var rr: = max_range + e.radius
				if dx * dx + dz * dz > rr * rr:
					continue
				if walled and world.morroc.walled(e):
					continue
				if e == boss:
					boss_in = true
				var d: = ep.distance_squared_to(center)
				var n: = best.size()
				if n >= count and d >= best_d[n - 1]:
					continue
				var at: = n
				while at > 0 and best_d[at - 1] > d:
					at -= 1
				best.insert(at, e)
				best_d.insert(at, d)
				if best.size() > count:
					best.resize(count)
					best_d.resize(count)



	if boss_in and boss.position.distance_to(center) < max_range * 0.5:
		best.erase(boss)
		best.push_front(boss)
		if best.size() > count:
			best.resize(count)
	return best



func any_near(center: Vector3, radius: float) -> bool:
	var r: = ceili(radius / CELL)
	var cx: = floori(center.x / CELL)
	var cz: = floori(center.z / CELL)
	for x in range(cx - r, cx + r + 1):
		var kx: = (x + OFF) * ROW + OFF
		for z in range(cz - r, cz + r + 1):
			var run = cells.get(kx + z)
			if run == null:
				continue
			for j in range(run.x, run.y):
				var e: Enemy = mobs[order[j]]
				if not is_instance_valid(e) or e.dead or e.prop != "":
					continue
				var ep: = e.position
				var dx: = ep.x - center.x
				var dz: = ep.z - center.z
				var rr: = radius + e.radius
				if dx * dx + dz * dz <= rr * rr:
					return true
	return false







func push_of(e: Enemy, ex: float, ez: float, er: float) -> Vector3:
	var push_x: = 0.0
	var push_z: = 0.0
	for o in big:
		if o == e:
			continue
		var op: = o.position
		var dx: = ex - op.x
		var dz: = ez - op.z
		var min_d: = er + o.radius
		var l2: = dx * dx + dz * dz
		if l2 < min_d * min_d and l2 > 1e-06:
			var l: = sqrt(l2)
			var k: = (min_d - l) / (min_d * l)
			push_x += dx * k
			push_z += dz * k
	var touching: = 0

	var reach: = er + max_radius
	for x in range(floori((ex - reach) / SEP_CELL), floori((ex + reach) / SEP_CELL) + 1):
		var kx: = (x + OFF) * ROW + OFF
		for z in range(floori((ez - reach) / SEP_CELL), floori((ez + reach) / SEP_CELL) + 1):
			var run = sep_cells.get(kx + z)
			if run == null:
				continue
			for j in range(run.x, run.y):
				var i: = sep_order[j]
				var dx: = ex - px[i]
				var dz: = ez - pz[i]
				var min_d: = er + pr[i]
				var l2: = dx * dx + dz * dz
				if l2 < min_d * min_d and l2 > 1e-06 and mobs[i] != e:
					var l: = sqrt(l2)
					var k: = (min_d - l) / (min_d * l)
					push_x += dx * k
					push_z += dz * k
					touching += 1
					if touching >= SEP_MAX_TOUCH:
						return Vector3(push_x, 0.0, push_z)
	return Vector3(push_x, 0.0, push_z)
