class_name RoMap
extends Node3D



const FALLBACK_SIZE: = 120


const SUN_ENERGY: = 0.75


var has_sun: = false

var map_name: = ""
var width: = FALLBACK_SIZE
var height: = FALLBACK_SIZE
var _heights: = PackedFloat32Array()
var _height_corners: = PackedFloat32Array()

var _ground: = PackedFloat32Array()
var _walk: = PackedByteArray()




static var web_fetch: = Callable()

var real: = false


func load_map(p_map_name: String) -> void :
	map_name = p_map_name

	if web_fetch.is_valid():
		web_fetch.call(map_name)
	var grid: = RoAssets.map_grid(map_name)
	if not grid.is_empty():
		width = int(grid.w)
		height = int(grid.h)
		_heights = PackedFloat32Array(grid.heights)
		if grid.has("height_corners"):
			_height_corners = PackedFloat32Array(grid.height_corners)
		if grid.has("ground"):
			_ground = PackedFloat32Array(grid.ground)
		_walk = grid.walk if grid.walk is PackedByteArray else str(grid.walk).to_ascii_buffer()
	_mesh_ok = PackedByteArray()
	var scene: = RoAssets.map_scene(map_name)
	real = scene != null
	if scene != null:
		var instance: = scene.instantiate()
		add_child(instance)
		_check_scale(instance, map_name)
		_batch_props(instance)
		for light in instance.find_children("*", "DirectionalLight3D", true, false):
			light.light_energy = SUN_ENERGY * Vfx.sun_k()
			light.shadow_enabled = false
			has_sun = true
	else:
		_build_meadow()
	if not grid.is_empty() and scene == null:
		push_warning("RoMap: grid found but no glb for %s" % map_name)








const BATCH_MIN: = 4
const BATCH_CHUNK: = 32.0
func _batch_props(root: Node) -> void :
	var by_mesh: = {}
	for m: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null or m.name == "terrain" or m.get_child_count() > 0 or m.skin != null or m.material_override != null:
			continue
		var plain: = true
		for i in m.mesh.get_surface_count():
			if m.get_surface_override_material(i) != null:
				plain = false
				break
			var mat: = m.mesh.surface_get_material(i) as BaseMaterial3D
			if mat != null and mat.transparency in [BaseMaterial3D.TRANSPARENCY_ALPHA, BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS]:
				plain = false
				break
		if not plain:
			continue
		if not by_mesh.has(m.mesh):
			by_mesh[m.mesh] = []
		by_mesh[m.mesh].append(m)
	for mesh in by_mesh:
		var list: Array = by_mesh[mesh]
		if list.size() < BATCH_MIN:
			continue
		var chunks: = {}
		for m: MeshInstance3D in list:
			var at: = m.global_position
			var key: = Vector2i(floori(at.x / BATCH_CHUNK), floori(at.z / BATCH_CHUNK))
			if not chunks.has(key):
				chunks[key] = []
			chunks[key].append(m)
		for key in chunks:
			var part: Array = chunks[key]
			var mm: = MultiMesh.new()
			mm.transform_format = MultiMesh.TRANSFORM_3D
			mm.mesh = mesh
			mm.instance_count = part.size()
			for i in part.size():
				mm.set_instance_transform(i, (part[i] as MeshInstance3D).global_transform)
			var mmi: = MultiMeshInstance3D.new()
			mmi.multimesh = mm
			var first: MeshInstance3D = part[0]
			mmi.cast_shadow = first.cast_shadow
			mmi.layers = first.layers
			add_child(mmi)
			mmi.global_transform = Transform3D.IDENTITY
			for m: MeshInstance3D in part:
				m.get_parent().remove_child(m)
				m.queue_free()




func _check_scale(instance: Node, map_name: String) -> void :
	var terrain: = instance.find_child("terrain", true, false) as MeshInstance3D
	if terrain == null or terrain.mesh == null:
		return
	var box: = terrain.mesh.get_aabb()
	var span: = box.size.x


	var centred: = absf(box.get_center().x) < 1.0 and span < width
	if absf(span - width) > 3.0 and not centred:
		push_error("RoMap: %s.glb spans %.1f units but its GAT grid is %d tiles. Re-export the map with tools/export_assets.py." % [map_name, span, width])






const MAX_CLEARED: = 14.0
func clear_props(c: Vector3, r: float, front: = 0.0) -> void :

	var near: = func(p: Vector3) -> bool: return Vector2(p.x - c.x, p.z - c.z).length() < r or (front > 0.0 and p.z > c.z and p.z - c.z < r + front and absf(p.x - c.x) < r)
	for mmi: MultiMeshInstance3D in find_children("*", "MultiMeshInstance3D", true, false):
		var mm: = mmi.multimesh
		if mm == null or mm.mesh == null:
			continue
		var box: = mm.mesh.get_aabb()
		if maxf(box.size.x, box.size.z) > MAX_CLEARED:
			continue
		for i in mm.instance_count:
			var t: = mmi.global_transform * mm.get_instance_transform(i)
			if near.call(t * box.get_center()):
				mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), t.origin - Vector3(0, 500, 0)))
	for mi: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or mi.name == "terrain" or not mi.visible:
			continue
		var box: = mi.get_aabb()
		if maxf(box.size.x, box.size.z) > MAX_CLEARED:
			continue
		if near.call(mi.global_transform * box.get_center()):
			mi.visible = false







func flatten(c: Vector3, r: float, blend: = 3.0) -> void :
	var h0: = height_at(c)
	var reach: = r + blend
	var weight: = func(x: float, z: float) -> float:
		var d: = Vector2(x - c.x, z - c.z).length()
		if d <= r:
			return 1.0
		return 0.0 if d >= reach else smoothstep(reach, r, d)
	var hw: = width * 0.5
	var hh: = height * 0.5

	var i0: = maxi(0, floori(c.x - reach + hw))
	var i1: = mini(width, ceili(c.x + reach + hw))
	var j0: = maxi(0, floori(hh - c.z - reach))
	var j1: = mini(height, ceili(hh - c.z + reach))
	if not _ground.is_empty():
		var row: = width + 1
		for j in range(j0, j1 + 1):
			for i in range(i0, i1 + 1):
				var w: float = weight.call(i - hw, hh - j)
				if w > 0.0 and j * row + i < _ground.size():
					_ground[j * row + i] = lerpf(_ground[j * row + i], h0, w)
	for j in range(j0, mini(j1, height - 1) + 1):
		for i in range(i0, mini(i1, width - 1) + 1):
			if not _heights.is_empty():
				var w: float = weight.call(i - hw, hh - j)
				if w > 0.0:
					_heights[j * width + i] = lerpf(_heights[j * width + i], h0, w)
			if not _height_corners.is_empty() and i < width - 1 and j < height - 1:

				var ci: = (j * width + i) * 4
				var at: = [Vector2(i, j), Vector2(i + 1, j), Vector2(i, j + 1), Vector2(i + 1, j + 1)]
				for k in 4:
					var w: float = weight.call(at[k].x - hw, hh - at[k].y)
					if w > 0.0:
						_height_corners[ci + k] = lerpf(_height_corners[ci + k], h0, w)
	_mesh_ok = PackedByteArray()
	var terrain: = find_child("terrain", true, false) as MeshInstance3D
	if terrain == null or not (terrain.mesh is ArrayMesh):
		return
	var xf: = terrain.global_transform
	var inv: = xf.affine_inverse()
	var up: = (inv.basis * Vector3.UP).normalized()
	var old: ArrayMesh = terrain.mesh
	var fresh: = ArrayMesh.new()
	for s in old.get_surface_count():
		var arrays: = old.surface_get_arrays(s)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals = arrays[Mesh.ARRAY_NORMAL]
		var has_n: bool = normals is PackedVector3Array and (normals as PackedVector3Array).size() == verts.size()
		for v in verts.size():
			var p: = xf * verts[v]
			if absf(p.x - c.x) > reach or absf(p.z - c.z) > reach:
				continue
			var w: float = weight.call(p.x, p.z)
			if w <= 0.0:
				continue
			p.y = lerpf(p.y, h0, w)
			verts[v] = inv * p
			if has_n:
				normals[v] = (normals[v] as Vector3).lerp(up, w).normalized()
		arrays[Mesh.ARRAY_VERTEX] = verts
		if has_n:
			arrays[Mesh.ARRAY_NORMAL] = normals
		fresh.add_surface_from_arrays(old.surface_get_primitive_type(s), arrays)
		fresh.surface_set_material(fresh.get_surface_count() - 1, old.surface_get_material(s))
	terrain.mesh = fresh


func half_size() -> Vector2:
	return Vector2(width, height) * 0.5


func _tile(pos: Vector3) -> Vector2i:
	return Vector2i(floori(pos.x + width * 0.5), floori(height * 0.5 - pos.z))


func tile_of(pos: Vector3) -> Vector2i:
	return _tile(pos)


func cell_walkable(tx: int, ty: int) -> bool:
	if tx < 1 or ty < 1 or tx >= width - 1 or ty >= height - 1:
		return false
	return _walk.is_empty() or _walk[ty * width + tx] == 49



func block_cell(tx: int, ty: int) -> void :
	if not _walk.is_empty() and tx >= 0 and ty >= 0 and tx < width and ty < height:
		_walk[ty * width + tx] = 48
		_blocked_sum = PackedInt32Array()




var _blocked_sum: = PackedInt32Array()
func blocked_in(x0: int, y0: int, x1: int, y1: int) -> int:
	if _walk.is_empty():
		return 0
	var w1: = width + 1
	if _blocked_sum.is_empty():
		_blocked_sum.resize(w1 * (height + 1))
		for y in height:
			var row: = 0
			for x in width:
				row += 0 if _walk[y * width + x] == 49 else 1
				_blocked_sum[(y + 1) * w1 + x + 1] = _blocked_sum[y * w1 + x + 1] + row

	if x0 < 1 or y0 < 1 or x1 >= width - 1 or y1 >= height - 1:
		return 1
	return _blocked_sum[(y1 + 1) * w1 + x1 + 1] - _blocked_sum[y0 * w1 + x1 + 1] - _blocked_sum[(y1 + 1) * w1 + x0] + _blocked_sum[y0 * w1 + x0]



func cell_center(tx: int, ty: int) -> Vector3:
	return Vector3(tx - width * 0.5 + 0.5, 0.0, height * 0.5 - ty - 0.5)


func is_walkable(pos: Vector3) -> bool:
	var t: = _tile(pos)
	if t.x < 1 or t.y < 1 or t.x >= width - 1 or t.y >= height - 1:
		return false
	if _walk.is_empty():
		return true
	return _walk[t.y * width + t.x] == 49




const BRIDGE_RISE: = 0.8



const WALL_RISE: = 1.5




func height_at(pos: Vector3) -> float:
	var ground: = _mesh_height(pos)
	if is_nan(ground):
		return _gat_height(pos)
	if not _height_corners.is_empty():
		var gat: = _gat_height(pos)
		if gat > ground + BRIDGE_RISE or ground > gat + WALL_RISE:
			return gat
	return ground



func _mesh_height(pos: Vector3) -> float:
	if not _ground.is_empty():
		var gx: = clampf(pos.x + width * 0.5, 0.0, width - 0.001)
		var gz: = clampf(height * 0.5 - pos.z, 0.0, height - 0.001)
		var i: = floori(gx)
		var j: = floori(gz)
		var fx: = gx - i
		var fz: = gz - j
		var row: = width + 1
		var a: = _ground[j * row + i]
		var b: = _ground[j * row + i + 1]
		var c: = _ground[(j + 1) * row + i]
		var d: = _ground[(j + 1) * row + i + 1]
		return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fz)
	return NAN



func _gat_height(pos: Vector3) -> float:
	if _heights.is_empty():
		return 0.0


	var fx: = pos.x + width * 0.5
	var fz: = height * 0.5 - pos.z
	var x0: = clampi(floori(fx), 0, width - 2)
	var z0: = clampi(floori(fz), 0, height - 2)
	var tx: = clampf(fx - x0, 0.0, 1.0)
	var tz: = clampf(fz - z0, 0.0, 1.0)
	if not _height_corners.is_empty():
		var ci: = (z0 * width + x0) * 4
		var sw: = _height_corners[ci]
		var se: = _height_corners[ci + 1]
		var nw: = _height_corners[ci + 2]
		var ne: = _height_corners[ci + 3]
		return lerpf(lerpf(sw, se, tx), lerpf(nw, ne, tx), tz)
	var a: = _heights[z0 * width + x0]
	var b: = _heights[z0 * width + x0 + 1]
	var c: = _heights[(z0 + 1) * width + x0]
	var d: = _heights[(z0 + 1) * width + x0 + 1]
	return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), tz)



func slide(from: Vector3, step: Vector3) -> Vector3:
	var to: = from + step
	if is_walkable(to):
		return to


	if not is_walkable(from):
		return to
	var x_only: = from + Vector3(step.x, 0, 0)
	if is_walkable(x_only):
		return x_only
	var z_only: = from + Vector3(0, 0, step.z)
	if is_walkable(z_only):
		return z_only
	return from





func step(from: Vector3, by: Vector3) -> Vector3:
	var to: = from + by
	var hw: = width * 0.5
	var hh: = height * 0.5
	var walk: = _walk
	var free: = walk.is_empty()
	var w: = width
	var tx: = floori(to.x + hw)
	var ty: = floori(hh - to.z)
	if tx < 1 or ty < 1 or tx >= w - 1 or ty >= height - 1 or not (free or walk[ty * w + tx] == 49):
		var fx: = floori(from.x + hw)
		var fy: = floori(hh - from.z)


		if not (fx < 1 or fy < 1 or fx >= w - 1 or fy >= height - 1 or not (free or walk[fy * w + fx] == 49)):
			if not (tx < 1 or tx >= w - 1 or not (free or walk[fy * w + tx] == 49)):
				to.z = from.z
			elif not (ty < 1 or ty >= height - 1 or not (free or walk[ty * w + fx] == 49)):
				to.x = from.x
			else:
				to = from


	if _ground.is_empty():
		to.y = _gat_height(to)
		return to
	var gx: = clampf(to.x + hw, 0.0, w - 0.001)
	var gz: = clampf(hh - to.z, 0.0, height - 0.001)
	var i: = floori(gx)
	var j: = floori(gz)
	var ax: = gx - i
	var az: = gz - j
	var row: = w + 1
	var o: = j * row + i
	var ground: = lerpf(lerpf(_ground[o], _ground[o + 1], ax), lerpf(_ground[o + row], _ground[o + row + 1], ax), az)
	if not _height_corners.is_empty():


		if _mesh_ok.size() != w * height:
			_mesh_ok.resize(w * height)
			_mesh_ok.fill(0)
		var ti: = j * w + i
		var ok: = _mesh_ok[ti]
		if ok == 0:
			ok = _tile_mesh_ok(i, j)
			_mesh_ok[ti] = ok
		if ok == 2:
			var gat: = _gat_height(to)
			if gat > ground + BRIDGE_RISE or ground > gat + WALL_RISE:
				ground = gat
	to.y = ground
	return to






var _mesh_ok: = PackedByteArray()


func _tile_mesh_ok(i: int, j: int) -> int:
	if i > width - 2 or j > height - 2:
		return 2
	var ci: = (j * width + i) * 4
	var row: = width + 1
	var o: = j * row + i
	var ground: = [_ground[o], _ground[o + 1], _ground[o + row], _ground[o + row + 1]]
	for k in 4:
		var gat: = _height_corners[ci + k]
		var m: float = ground[k]
		if gat > m + BRIDGE_RISE - 0.01 or m > gat + WALL_RISE - 0.01:
			return 2
	return 1



func random_point_around(center: Vector3, dist: float) -> Vector3:
	for i in 12:
		var a: = randf() * TAU
		var p: = center + Vector3(cos(a), 0, sin(a)) * dist * randf_range(0.9, 1.15)
		if is_walkable(p):
			return p
	return center




func find_point_around(center: Vector3, min_d: float, max_d: float) -> Vector3:
	for i in 40:
		var a: = randf() * TAU
		var p: = center + Vector3(cos(a), 0, sin(a)) * randf_range(min_d, max_d)
		if is_walkable(p):
			return p
	return Vector3.INF










const POCKET_MIN: = 48


const GROUND_SEARCH: = 16
const STEPS_X: = [1, -1, 0, 0]
const STEPS_Y: = [0, 0, 1, -1]
var _reach: = PackedByteArray()
var _reach_origin: = Vector2i.ZERO
var _reach_size: = 0
var _reach_key: = Vector4i(-1, -1, -1, -1)






func reachable_point(at: Vector3, from: Vector3, span: = 40) -> Vector3:
	if not _build_reach(from, span):
		return Vector3.INF
	var size: = _reach_size
	var t: = _tile(at) - _reach_origin
	t = Vector2i(clampi(t.x, 0, size - 1), clampi(t.y, 0, size - 1))
	var best: = Vector2i(-1, -1)
	var best_score: = INF
	var stop: = size * 2
	for r in size * 2:
		if r > stop:
			break
		for k in (1 if r == 0 else r * 8):
			var c: = t + _ring_cell(r, k)
			if c.x < 0 or c.y < 0 or c.x >= size or c.y >= size or _reach[c.y * size + c.x] != 1:
				continue
			var g: = c + _reach_origin
			var score: = Vector2(c - t).length() + (0.0 if _open_around(g.x, g.y) else 1.5)
			if score < best_score:
				best_score = score
				best = g

				stop = r + 2
	if best.x < 0:
		return Vector3.INF
	var p: = cell_center(best.x, best.y)

	if _tile(at) == best:
		p = Vector3(at.x, 0.0, at.z)
	return Vector3(p.x, height_at(p), p.z)



func can_reach(at: Vector3, from: Vector3, span: = 40) -> bool:
	if not _build_reach(from, span):
		return false
	var c: = _tile(at) - _reach_origin
	return c.x >= 0 and c.y >= 0 and c.x < _reach_size and c.y < _reach_size and _reach[c.y * _reach_size + c.x] == 1



static func _ring_cell(r: int, k: int) -> Vector2i:
	if r == 0:
		return Vector2i.ZERO
	var side: = r * 2
	var s: = k / side
	var o: = k % side
	match s:
		0:
			return Vector2i( - r + o, - r)
		1:
			return Vector2i(r, - r + o)
		2:
			return Vector2i(r - o, r)
	return Vector2i( - r, r - o)


func _open_around(tx: int, ty: int) -> bool:
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if not cell_walkable(tx + dx, ty + dy):
				return false
	return true




func _build_reach(from: Vector3, span: int) -> bool:
	var s: = _tile(from)
	var key: = Vector4i(s.x, s.y, span, Engine.get_process_frames())
	if key == _reach_key:
		return _reach_size > 0
	_reach_key = key
	_reach_size = 0
	var start: = _ground_cell(s)
	if start.x < 0:
		return false
	var size: = span * 2 + 1
	_reach_origin = start - Vector2i(span, span)
	_reach_size = size
	_reach.resize(size * size)
	_reach.fill(0)

	var walk: = _walk
	var any: = walk.is_empty()
	var ox: = _reach_origin.x
	var oy: = _reach_origin.y
	var queue: = PackedInt32Array()
	queue.resize(size * size)
	queue[0] = span * size + span
	_reach[span * size + span] = 1
	var head: = 0
	var tail: = 1
	while head < tail:
		var i: = queue[head]
		head += 1
		var lx: = i % size
		var ly: = i / size
		for k in 4:
			var nx: int = lx + STEPS_X[k]
			var ny: int = ly + STEPS_Y[k]
			if nx < 0 or ny < 0 or nx >= size or ny >= size:
				continue
			var j: = ny * size + nx
			if _reach[j] != 0:
				continue
			var gx: = ox + nx
			var gy: = oy + ny
			if gx < 1 or gy < 1 or gx >= width - 1 or gy >= height - 1 or not (any or walk[gy * width + gx] == 49):
				_reach[j] = 2
				continue
			_reach[j] = 1
			queue[tail] = j
			tail += 1
	return true




func _ground_cell(s: Vector2i) -> Vector2i:
	var first: = Vector2i(-1, -1)
	var tried: = 0
	for r in GROUND_SEARCH + 1:
		for k in (1 if r == 0 else r * 8):
			var c: = s + _ring_cell(r, k)
			if not cell_walkable(c.x, c.y):
				continue
			if first.x < 0:
				first = c
			if tried < 24:
				tried += 1
				if _pocket_ok(c):
					return c
	return first



func _pocket_ok(c: Vector2i) -> bool:
	var seen: = {c: true}
	var todo: Array[Vector2i] = [c]
	while not todo.is_empty():
		var t: Vector2i = todo.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = t + d
			if seen.has(n) or not cell_walkable(n.x, n.y):
				continue
			seen[n] = true
			if seen.size() >= POCKET_MIN:
				return true
			todo.append(n)
	return false


func spawn_point() -> Vector3:
	var p: = Vector3.ZERO
	for r in range(0, mini(width, height) >> 1, 2):
		for i in 16:
			var a: = TAU * i / 16.0
			p = Vector3(cos(a), 0, sin(a)) * r
			if is_walkable(p):
				return p
	return p


func _build_meadow() -> void :
	var size: = Vector2(width, height)
	var img: = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var noise: = FastNoiseLite.new()
	noise.frequency = 0.03
	var detail: = FastNoiseLite.new()
	detail.frequency = 0.25
	detail.seed = 7
	for y in 256:
		for x in 256:
			var n: = noise.get_noise_2d(x, y) * 0.5 + 0.5
			var dn: = detail.get_noise_2d(x, y) * 0.5 + 0.5
			var col: = Color(0.36, 0.58, 0.25).lerp(Color(0.5, 0.68, 0.3), n)
			col = col.lerp(Color(0.62, 0.55, 0.36), clampf((n - 0.78) * 4.0, 0.0, 1.0))
			img.set_pixel(x, y, col.darkened((dn - 0.5) * 0.12))
	var mat: = StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(img)
	mat.uv1_scale = Vector3(size.x / 16.0, size.y / 16.0, 1)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var plane: = PlaneMesh.new()
	plane.size = size
	var ground: = MeshInstance3D.new()
	ground.mesh = plane
	ground.material_override = mat
	add_child(ground)

	var trunk: = RoAssets.placeholder(Color(0.25, 0.45, 0.2), 90, false)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 42
	for i in 140:
		var p: = Vector3(rng.randf_range( - width, width) * 0.5, 0, rng.randf_range( - height, height) * 0.5)
		if p.length() < 12.0:
			continue
		var tree: = Sprite3D.new()
		tree.texture = trunk
		tree.pixel_size = GameData.PIXEL_SIZE * rng.randf_range(1.0, 1.6)
		tree.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		tree.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		tree.shaded = false
		tree.centered = false
		tree.offset = Vector2(-45, 0)
		tree.position = p
		add_child(tree)
