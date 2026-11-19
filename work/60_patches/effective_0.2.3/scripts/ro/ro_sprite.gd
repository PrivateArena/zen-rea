class_name RoSprite
extends RefCounted








const DIRS: = 8






var parts: Array = []


var skin: = ""
var skin_mask: RoSprite
var canvas_size: = Vector2i.ONE

var origin: = Vector2i.ZERO
var _cache: = {}


var used_ms: = 0


var _used: = {}


func _init(p_parts: Array) -> void :
	parts = p_parts

	used_ms = Time.get_ticks_msec()
	_compute_canvas()


func action_count() -> int:
	return parts[0].meta.actions.size()


func base_count() -> int:
	return int(ceil(action_count() / float(DIRS)))


func frame_count(action: int) -> int:
	return parts[0].meta.actions[_clamp_action(action)].frames.size()



func frame_delay(action: int) -> float:
	var d: float = parts[0].meta.actions[_clamp_action(action)].get("delay", 4.0)
	return maxf(d, 1.0) * 0.025







var _anim: = {}


func anim_steps(action: int) -> int:
	return int(_anim_info(action)[0])


func anim_delay(action: int) -> float:
	return float(_anim_info(action)[1])



func anim_sub(action: int) -> int:
	var info: Array = _anim_info(action)
	if int(info[0]) <= 1:
		return 0
	return int(Time.get_ticks_msec() / 1000.0 / float(info[1])) % int(info[0])





func still_sub(action: int) -> int:
	return int(_anim_info(action)[2])


func _anim_info(action: int) -> Array:
	action = _clamp_action(action)
	if _anim.has(action):
		return _anim[action]
	var info: = [1, 0.1, 0]
	var base: = action >> 3
	if base == 0 or base == 2:
		var animated: = []
		for i in range(1, parts.size()):
			var part: Dictionary = parts[i]
			if part.get("attach", "anchor") == "origin":
				continue
			var actions: Array = part.meta.actions
			var pa: Dictionary = actions[mini(action, actions.size() - 1)]
			var n: int = pa.frames.size()
			if n > 3 and n % 3 == 0 and n / 3 > int(info[0]):
				info[0] = n / 3
				info[1] = maxf(float(pa.get("delay", 4.0)), 1.0) * 0.025
			if n > 3 and n % 3 == 0:
				animated.append(pa)
		for sub in int(info[0]):
			var ok: = true
			for pa in animated:
				var per: int = pa.frames.size() / 3
				if (pa.frames[sub % per] as Dictionary).get("layers", []).is_empty():
					ok = false
			if ok:
				info[2] = sub
				break
	_anim[action] = info
	return info




func get_frame(action: int, frame: int, sub: = -1) -> Texture2D:
	action = _clamp_action(action)
	var count: = frame_count(action)
	if count == 0:
		return null
	frame = posmod(frame, count)
	var steps: = anim_steps(action)
	sub = 0 if steps <= 1 else (still_sub(action) if sub < 0 else posmod(sub, steps))
	var key: = sub * 1000000 + action * 1000 + frame
	used_ms = Time.get_ticks_msec()
	_used[key] = used_ms
	if _cache.has(key):
		return _cache[key]
	var tex: = ImageTexture.create_from_image(compose_image(action, frame, sub))
	_cache[key] = tex
	return tex



func drop_frames() -> void :
	_cache.clear()
	_used.clear()



func drop_frame(key: int) -> void :
	_cache.erase(key)
	_used.erase(key)





var _robe_cache: = {}


func robe_frame(action: int, frame: int, sub: = -1) -> Texture2D:
	var only: = []
	for i in range(1, parts.size()):
		if parts[i].get("behind", false):
			only.append(i)
	if only.is_empty() or frame_count(_clamp_action(action)) == 0:
		return null
	action = _clamp_action(action)
	frame = posmod(frame, frame_count(action))
	var steps: = anim_steps(action)
	sub = 0 if steps <= 1 else (still_sub(action) if sub < 0 else posmod(sub, steps))
	var key: = sub * 1000000 + action * 1000 + frame
	if not _robe_cache.has(key):
		if _robe_cache.size() > 160:
			_robe_cache.clear()
		_robe_cache[key] = ImageTexture.create_from_image(compose_image(action, frame, sub, only))
	return _robe_cache[key]




func compose_image(action: int, frame: int, sub: = 0, only: Array = []) -> Image:
	action = _clamp_action(action)
	frame = posmod(frame, maxi(1, frame_count(action)))
	var img: = Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	if frame_count(action) == 0:
		return img
	for d in _draws(action, frame, sub):
		if not only.is_empty() and not only.has(d.part):
			continue
		var part: Dictionary = parts[d.part]
		var rect: Array = part.meta.frames[d.ref]
		var src: Image = part.image.get_region(Rect2i(rect[0], rect[1], rect[2], rect[3]))
		if d.mirror:
			src.flip_x()
		if d.size != Vector2i(rect[2], rect[3]) and d.size.x > 0 and d.size.y > 0:
			src.resize(d.size.x, d.size.y, Image.INTERPOLATE_NEAREST)
		if d.tint != Color.WHITE:
			_tint(src, d.tint)
		img.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), d.pos + origin)
	return img






var _head_x: = {}
const HEAD_ROWS: = 14


func head_x(action: int) -> float:
	action = _clamp_action(action)
	if _head_x.has(action):
		return _head_x[action]
	var x: = 0.0
	var img: = compose_image(action, 0, still_sub(action))
	var used: = img.get_used_rect()
	if used.size.x > 0:
		var sum: = 0.0
		var n: = 0
		for py in range(used.position.y, mini(used.end.y, used.position.y + HEAD_ROWS)):
			for px in range(used.position.x, used.end.x):
				if img.get_pixel(px, py).a > 0.5:
					sum += px
					n += 1
		if n > 0:
			x = sum / n + 0.5 - origin.x
	_head_x[action] = x
	return x





func frame_key(action: int, frame: int, flip: = false, sub: = -1) -> String:
	action = _clamp_action(action)
	if frame_count(action) == 0:
		return ""
	if sub < 0:
		sub = still_sub(action)
	var out: = PackedStringArray()
	for d in _draws(action, frame, sub):
		out.append(str([d.part, d.ref, d.mirror != flip, 0.0 - d.x if flip else d.x, d.pos.y, d.size, d.tint]))
	return ";".join(out)




static func _tint(src: Image, tint: Color) -> void :
	for y in src.get_height():
		for x in src.get_width():
			var c: = src.get_pixel(x, y)
			if c.a > 0.0:
				src.set_pixel(x, y, c * tint)


func _clamp_action(action: int) -> int:
	return clampi(action, 0, action_count() - 1)





const ROBE_OVER_DIRS: = [3, 4, 5]


func _draws(action: int, frame: int, sub: = 0) -> Array:
	var out: = []
	var action_base: = action >> 3
	var death_action: = action_base == 4 or action_base == 8
	var main_frame: Dictionary = parts[0].meta.actions[action].frames[frame]
	_append_layers(out, 0, main_frame, Vector2.ZERO, death_action)
	var under: = []
	for i in range(1, parts.size()):
		var part: Dictionary = parts[i]
		var bases: Array = part.get("bases", [])
		if not bases.is_empty() and not bases.has(action_base):
			continue
		var actions: Array = part.meta.actions
		var pa: Dictionary = actions[mini(action, actions.size() - 1)]
		if pa.frames.is_empty():
			continue
		var offset: = Vector2.ZERO
		var pf: Dictionary
		if part.get("attach", "anchor") == "origin":


			pf = pa.frames[mini(frame, pa.frames.size() - 1)]
		else:
			if not main_frame.has("anchor"):
				continue
			var n: int = pa.frames.size()
			var still_base: = (action >> 3) == 0 or (action >> 3) == 2
			if still_base and n > 3 and n % 3 == 0:

				var per: = n / 3
				pf = pa.frames[clampi(frame, 0, 2) * per + posmod(sub, per)]
			else:
				pf = pa.frames[frame % n]
			if pf.has("anchor"):
				var anchor: Array = main_frame.anchor
				offset = Vector2(anchor[0] - pf.anchor[0], anchor[1] - pf.anchor[1])



		var behind: bool = part.get("behind", false) and not (part.get("back_over", false) and ROBE_OVER_DIRS.has(action & 7))
		_append_layers(under if behind else out, i, pf, offset, death_action)
	return under + out


func _append_layers(out: Array, part: int, frame: Dictionary, offset: Vector2, 
		death_action: bool) -> void :
	var frames: Array = parts[part].meta.frames
	for layer in frame.get("layers", []):
		var ref: = int(layer[2])
		if ref < 0 or ref >= frames.size():
			continue
		var rect: Array = frames[ref]
		var scale: = Vector2.ONE
		if layer.size() >= 10:
			scale = Vector2(absf(layer[8]), absf(layer[9]))





		if scale.x > 2.0 or scale.y > 2.0:
			continue



		if death_action and layer.size() >= 10 and int(layer[7]) < 255\
		and (scale.x > 1.05 or scale.y > 1.05):
			continue
		var size: = Vector2i(roundi(rect[2] * scale.x), roundi(rect[3] * scale.y))
		var center: = Vector2(layer[0], layer[1]) + offset
		var pos: = Vector2i(floori(center.x - size.x / 2.0), floori(center.y - size.y / 2.0))
		var tint: = Color.WHITE
		if layer.size() >= 8:
			tint = Color(layer[4] / 255.0, layer[5] / 255.0, layer[6] / 255.0, layer[7] / 255.0)
		out.append({"part": part, "ref": ref, "mirror": int(layer[3]) != 0, "pos": pos, "size": size, "tint": tint, "x": center.x})


func _compute_canvas() -> void :
	var min_p: = Vector2i(-8, -8)
	var max_p: = Vector2i(8, 8)
	var actions: Array = parts[0].meta.actions
	for a in actions.size():
		for f in actions[a].frames.size():
			for d in _draws(a, f) + (_sub_draws(a, f) if anim_steps(a) > 1 else []):
				min_p = Vector2i(mini(min_p.x, d.pos.x), mini(min_p.y, d.pos.y))
				max_p = Vector2i(maxi(max_p.x, d.pos.x + d.size.x), maxi(max_p.y, d.pos.y + d.size.y))

	var half: = maxi( - min_p.x, max_p.x)
	origin = Vector2i(half, - min_p.y)
	canvas_size = Vector2i(half * 2, max_p.y - min_p.y)


func _sub_draws(action: int, frame: int) -> Array:
	var out: = []
	for sub in range(1, anim_steps(action)):
		out.append_array(_draws(action, frame, sub))
	return out
