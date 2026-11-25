class_name MobRenderer
extends Node3D










const BASES: = 5

const MAX_ATLAS: = 4096

const SHADER: = "\r\nshader_type spatial;\r\nrender_mode unshaded, cull_disabled, depth_draw_opaque;\r\n\r\nuniform sampler2D atlas : source_color, filter_nearest;\r\nuniform vec2 cell_uv;\r\nuniform float columns;\r\n\r\nvarying vec4 custom;\r\n\r\nvoid vertex() {\r\n\tcustom = INSTANCE_CUSTOM;\r\n\t// Billboard facing the camera, keeping the instance position and size.\r\n\tfloat size = MODEL_MATRIX[0].x;\r\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0] * size, INV_VIEW_MATRIX[1] * size,\r\n\t\tINV_VIEW_MATRIX[2] * size, MODEL_MATRIX[3]);\r\n\tfloat cell = custom.x;\r\n\t// A fraction in the cell number draws that cell mirrored.\r\n\tfloat flip = fract(cell);\r\n\tcell = floor(cell);\r\n\tvec2 cr = vec2(mod(cell, columns), floor(cell / columns));\r\n\tif (flip > 0.25) {\r\n\t\tUV.x = 1.0 - UV.x;\r\n\t}\r\n\tUV = (cr + UV) * cell_uv;\r\n}\r\n\r\nvoid fragment() {\r\n\tvec4 c = texture(atlas, UV);\r\n\tif (c.a < 0.5) {\r\n\t\tdiscard;\r\n\t}\r\n\t// Screen-door fade for dying monsters (keeps opaque sorting).\r\n\tfloat dither = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);\r\n\tif (dither > custom.z) {\r\n\t\tdiscard;\r\n\t}\r\n\t// Its family's look (Enemy.set_look) comes with the flash: look x 2 + flash.\r\n\tfloat look = floor(custom.y * 0.5 + 0.01);\r\n\tfloat hit = custom.y - look * 2.0;\r\n\t// Kyrie Eleison (the Juramentos) comes as 4 more on the family's look.\r\n\tfloat kyrie = step(3.5, look);\r\n\tlook -= kyrie * 4.0;\r\n\t// Ethereal: half there (every other pixel, in a checkerboard).\r\n\tif (look > 0.5 && look < 1.5 && mod(floor(FRAGCOORD.x) + floor(FRAGCOORD.y), 2.0) > 0.5) {\r\n\t\tdiscard;\r\n\t}\r\n\t// Status colours (Enemy._update_tint): frozen, stone, asleep, poisoned, burning, bleeding.\r\n\tvec3 col = c.rgb;\r\n\tfloat lum = dot(col, vec3(0.3, 0.59, 0.11));\r\n\tif (custom.w > 0.5 && custom.w < 1.5) {\r\n\t\tcol = mix(col, vec3(0.55, 0.85, 1.0) * (lum * 1.3 + 0.25), 0.8);\r\n\t} else if (custom.w > 1.5 && custom.w < 2.5) {\r\n\t\tcol = vec3(lum * 0.95);\r\n\t} else if (custom.w > 2.5 && custom.w < 3.5) {\r\n\t\tcol *= vec3(0.72, 0.72, 0.88);\r\n\t} else if (custom.w > 4.5 && custom.w < 5.5) {\r\n\t\t// Poisoned: the sprite's own colours, a little drained and turned\r\n\t\t// sickly olive-violet (as the client's poisoned monsters), deeper with\r\n\t\t// the stacks (the tint's fraction) and breathing slowly; no glow (a\r\n\t\t// neon green over the whole body looked artificial).\r\n\t\tfloat k = clamp((custom.w - 5.0) / 0.45, 0.0, 1.0);\r\n\t\tfloat breathe = 0.5 + 0.5 * sin(TIME * 2.2);\r\n\t\tvec3 drained = mix(vec3(lum), col, 0.65);\r\n\t\tvec3 sick = drained * vec3(0.8, 0.9, 0.72) + vec3(0.03, 0.0, 0.05);\r\n\t\tcol = mix(col, sick, 0.3 + 0.35 * k + 0.08 * breathe * k);\r\n\t} else if (custom.w > 5.5 && custom.w < 6.5) {\r\n\t\t// Burning: an orange glow that flickers.\r\n\t\tfloat f = 0.5 + 0.5 * sin(TIME * 18.0 + FRAGCOORD.y * 0.05);\r\n\t\tcol = mix(col, col * vec3(1.25, 0.75, 0.4) + vec3(0.22, 0.07, 0.0) * (0.6 + 0.4 * f), 0.65);\r\n\t} else if (custom.w > 6.5) {\r\n\t\tcol = mix(col, col * vec3(1.0, 0.5, 0.5), 0.5);\r\n\t}\r\n\tif (look > 0.5 && look < 1.5) {\r\n\t\t// Ethereal: pale and cold, breathing.\r\n\t\tfloat l2 = dot(col, vec3(0.3, 0.59, 0.11));\r\n\t\tcol = mix(col, vec3(0.62, 0.8, 1.0) * (l2 * 1.15 + 0.2), 0.45 + 0.12 * sin(TIME * 2.6));\r\n\t} else if (look > 1.5 && look < 2.5) {\r\n\t\t// Risen: drained and dark, a sickly green.\r\n\t\tfloat l2 = dot(col, vec3(0.3, 0.59, 0.11));\r\n\t\tcol = mix(vec3(l2), col, 0.35) * vec3(0.6, 0.74, 0.56);\r\n\t} else if (look > 2.5) {\r\n\t\t// Rallied by its warchief: war red.\r\n\t\tcol = col * vec3(1.2, 0.8, 0.76) + vec3(0.07, 0.0, 0.0);\r\n\t}\r\n\tif (kyrie > 0.5) {\r\n\t\t// Under Kyrie Eleison: a pale holy shine that breathes, brighter at\r\n\t\t// the edges of the sprite's light parts.\r\n\t\tfloat l3 = dot(col, vec3(0.3, 0.59, 0.11));\r\n\t\tfloat pulse = 0.5 + 0.5 * sin(TIME * 3.2 + FRAGCOORD.y * 0.03);\r\n\t\tcol = mix(col, vec3(0.86, 0.94, 1.0) * (l3 * 0.9 + 0.35), 0.38 + 0.14 * pulse);\r\n\t}\r\n\tALBEDO = mix(col, col * vec3(1.0, 0.45, 0.45), hit);\r\n}\r\n"
































































































var _kinds: = {}
var _shader: Shader

var _keep: = {}
var _next_sweep: = 0

const IDLE_FREE_MS: = 300000


const IDLE_FREE_TOUCH_MS: = 30000




var _pending: = {}
var _built: = {}
var _built_lock: = Mutex.new()



var _gl: = false


func _ready() -> void :
	_shader = Shader.new()
	_gl = RenderingServer.get_current_rendering_method() == "gl_compatibility"
	var code: = SHADER
	if RenderingServer.get_current_rendering_method() != "gl_compatibility":


		code = code.replace("depth_draw_opaque;", "depth_draw_opaque;" + char(10) + "stencil_mode write, compare_always, %d;" % RoEffect.STENCIL_MOB)
	_shader.code = code



func prepare(id: String) -> bool:
	if _kinds.has(id):
		return _kinds[id] != null
	if _pending.has(id) and int(_pending[id]) >= 0:
		WorkerThreadPool.wait_for_task_completion(int(_pending[id]))
		_finish_built()
		if _kinds.has(id):
			return _kinds[id] != null
	var ro: = RoAssets.sprite([id])
	if ro == null:
		_kinds[id] = null
		return false
	var kind: Variant = _build(id, ro)
	_kinds[id] = kind
	return kind != null





func prepare_async(id: String) -> void :
	if id == "" or _kinds.has(id) or _pending.has(id):
		return


	if OS.has_feature("web"):
		_pending[id] = -1
		RoAssets.web_later( func():
			_pending.erase(id)
			if is_instance_valid(self) and not _kinds.has(id):
				prepare(id))
		return
	_pending[id] = WorkerThreadPool.add_task( func():
		var ro: = RoAssets.sprite([id])
		var art: = _atlas_of(id, ro) if ro != null else {}
		_built_lock.lock()
		_built[id] = [ro, art]
		_built_lock.unlock())


func _exit_tree() -> void :
	for id in _pending:
		if int(_pending[id]) >= 0:
			WorkerThreadPool.wait_for_task_completion(int(_pending[id]))
	_pending.clear()



func _finish_built() -> void :
	_built_lock.lock()
	var done: = _built.duplicate()
	_built.clear()
	_built_lock.unlock()
	for id in done:
		var task = _pending.get(id)
		_pending.erase(id)
		if task != null and int(task) >= 0:
			WorkerThreadPool.wait_for_task_completion(int(task))
		if _kinds.has(id):
			continue
		var ro: RoSprite = done[id][0]
		var art: Dictionary = done[id][1]
		_kinds[id] = _kind_of(id, ro, art) if ro != null and not art.is_empty() else null


func _build(id: String, ro: RoSprite) -> Variant:
	var art: = _atlas_of(id, ro)
	return _kind_of(id, ro, art) if not art.is_empty() else null




func _atlas_of(id: String, ro: RoSprite) -> Dictionary:
	var actions: = mini(BASES * RoSprite.DIRS, ro.action_count())
	var starts: = PackedInt32Array()
	var cells: = PackedFloat32Array()
	var sources: Array[Vector2i] = []
	var seen: = {}
	for a in actions:
		starts.append(cells.size())
		for f in maxi(1, ro.frame_count(a)):
			var key: = ro.frame_key(a, f)
			if seen.has(key):
				cells.append(seen[key])
				continue
			var mirrored: = ro.frame_key(a, f, true)
			if seen.has(mirrored):
				cells.append(seen[mirrored] + 0.5)
				continue
			seen[key] = float(sources.size())
			cells.append(seen[key])
			sources.append(Vector2i(a, f))
	var total: = sources.size()
	var cell: = ro.canvas_size


	if cell.x <= 0 or cell.y <= 0 or total <= 0:
		push_warning("MobRenderer: %s has an empty canvas %s" % [id, cell])
		return {}
	var cols: = maxi(1, ceili(sqrt(float(total) * cell.y / cell.x)))
	var rows: = ceili(float(total) / cols)
	if cols * cell.x > MAX_ATLAS or rows * cell.y > MAX_ATLAS:
		return {}
	var atlas: = Image.create(cols * cell.x, rows * cell.y, false, Image.FORMAT_RGBA8)
	for i in total:
		var img: = ro.compose_image(sources[i].x, sources[i].y)
		atlas.blit_rect(img, Rect2i(Vector2i.ZERO, cell), Vector2i((i % cols) * cell.x, (i / cols) * cell.y))



	if _gl:
		atlas.convert(Image.FORMAT_RGBA4444)
	return {"atlas": atlas, "cols": cols, "rows": rows, "starts": starts, "cells": cells}



func _kind_of(id: String, ro: RoSprite, art: Dictionary) -> Dictionary:
	var cols: = int(art.cols)
	var rows: = int(art.rows)
	var cell: = ro.canvas_size
	var mat: = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("atlas", ImageTexture.create_from_image(art.atlas))
	mat.set_shader_parameter("cell_uv", Vector2(1.0 / cols, 1.0 / rows))
	mat.set_shader_parameter("columns", float(cols))
	var quad: = QuadMesh.new()
	var px: = GameData.PIXEL_SIZE
	quad.size = Vector2(cell) * px

	quad.center_offset = Vector3((cell.x * 0.5 - ro.origin.x) * px, (ro.origin.y - cell.y * 0.5) * px, 0)
	quad.material = mat
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = 64
	mm.visible_instance_count = 0
	var mmi: = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mmi)
	var tables: = MobAnim.tables(ro)
	return {"ro": ro, "mmi": mmi, "starts": art.starts, "cells": art.cells, "mobs": [], "buf": PackedFloat32Array(), 
		"seen": Time.get_ticks_msec(), "delays": tables[0], "counts": tables[1]}




func new_anim(id: String, mob: Node3D) -> MobAnim:
	var kind: Dictionary = _kinds[id]
	var anim: = MobAnim.new(kind.ro, kind.delays, kind.counts)
	anim.node = mob
	kind.mobs.append(anim)
	return anim


func untrack(id: String, anim: MobAnim) -> void :
	if _kinds.get(id) != null:
		_kinds[id].mobs.erase(anim)


func clear() -> void :
	for id in _kinds:
		if _kinds[id] != null:
			_kinds[id].mobs.clear()
			_kinds[id].mmi.multimesh.visible_instance_count = 0





func set_keep(ids: Array) -> void :
	_keep.clear()
	for id in ids:
		_keep[id] = true
	for id in _kinds.keys():
		if not _keep.has(id):
			_free(id)
	for id in ids:
		prepare(id)



func keep_more(ids: Array) -> void :
	for id in ids:
		_keep[id] = true
		prepare(id)


func _free(id: String) -> void :
	var kind = _kinds.get(id)
	_kinds.erase(id)
	if kind != null:
		if not kind.mobs.is_empty():

			_kinds[id] = kind
			return
		kind.mmi.queue_free()

	RoAssets.forget_sprite([id])




func _sweep() -> void :
	var now: = Time.get_ticks_msec()
	for id in _kinds.keys():
		var kind = _kinds[id]
		if kind != null and not _keep.has(id) and kind.mobs.is_empty() and now - int(kind.seen) > (IDLE_FREE_TOUCH_MS if MouseWalk.touch() else IDLE_FREE_MS):
			_free(id)



func update(delta: float, bounds: AABB) -> void :
	var now: = Time.get_ticks_msec()
	if not _pending.is_empty():
		_finish_built()
	if now >= _next_sweep:
		_next_sweep = now + 10000
		_sweep()
	for id in _kinds:
		var kind = _kinds[id]
		if kind == null:
			continue
		var mobs: Array = kind.mobs
		if not mobs.is_empty():
			kind.seen = now
		var mm: MultiMesh = kind.mmi.multimesh
		if mobs.size() > mm.instance_count:
			mm.visible_instance_count = 0
			mm.instance_count = mobs.size() * 2
		var starts: PackedInt32Array = kind.starts
		var cells: PackedFloat32Array = kind.cells



		var buf: PackedFloat32Array = kind.buf
		if buf.size() != mm.instance_count * 16:
			buf.resize(mm.instance_count * 16)
			buf.fill(0.0)
			for i in mm.instance_count:
				buf[i * 16] = 1.0
				buf[i * 16 + 5] = 1.0
				buf[i * 16 + 10] = 1.0
		var lift: = RoVisual.world_lift()
		var n: = 0
		for anim: MobAnim in mobs:
			anim.write(buf, n * 16, delta, lift, starts, cells)
			n += 1
		kind.buf = buf
		if n > 0:
			mm.buffer = buf
		mm.visible_instance_count = n
		kind.mmi.custom_aabb = bounds
