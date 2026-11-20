extends Node



const ROOT: = "res://assets/ro/"

const Skins = preload("res://scripts/core/skins.gd")

var _sprites: = {}
var _placeholders: = {}
var _sounds: = {}
var _digits: = {}
var _effect_data: = {}
var _mob_sounds: = {}
var _digit_cache: = {}
var _msg: = {}
var _msg_tex: = {}
var _effect_textures: = {}
var _palettes: = {}
var _palettes_loaded: = false


var _lock: = Mutex.new()



const THAI_FONT: = "res://assets/fonts/NotoSansThai.ttf"



const CHINESE_FONT: = "res://assets/fonts/NotoSansTC-Subset.otf"


func _ready() -> void :




	var extra: Array[Font] = []
	if ThemeDB.fallback_font != null:
		extra.append(ThemeDB.fallback_font)
	for path in [THAI_FONT, CHINESE_FONT]:
		if ResourceLoader.exists(path):
			var f: = load(path) as Font
			if f != null:
				extra.append(f)
	for path in ["res://assets/ro/fonts/SCDream4.otf", "res://assets/ro/fonts/SCDream6.otf"]:
		if ResourceLoader.exists(path):
			var f: = load(path) as Font
			if f != null and not extra.is_empty() and not extra.has(f):
				f.fallbacks = extra
	get_tree().root.size_changed.connect(_apply_ui_scale)
	_fx_alpha_check()
	_apply_ui_scale()
	set_process(false)



func screen_scale() -> float:
	var root: = get_tree().root
	return maxf(0.01, float(root.size.y) / maxf(1.0, root.get_visible_rect().size.y))







func ui_smooth() -> bool:

	var settings = Save.data.get("settings", {}) if Save.data is Dictionary else {}
	match str(settings.get("ui_sharp", "smooth") if settings is Dictionary else "smooth"):
		"pixel":
			return false
		"smooth":
			return true
	var s: = screen_scale()
	return absf(s - roundf(s)) > 0.01




func ui_filter() -> CanvasItem.TextureFilter:
	return CanvasItem.TEXTURE_FILTER_LINEAR if ui_smooth() else CanvasItem.TEXTURE_FILTER_NEAREST


var _ui_k: = 1.0





func set_ui_scale(k: float) -> void :
	_ui_k = k
	_apply_ui_scale()



func refresh_ui_scale() -> void :
	_apply_ui_scale()


func _apply_ui_scale() -> void :
	var s: = screen_scale()
	var total: = _ui_k * s
	for path in ["res://assets/ro/fonts/SCDream4.otf", "res://assets/ro/fonts/SCDream6.otf"]:
		if ResourceLoader.exists(path):
			var f: = load(path) as FontFile
			if f != null:
				f.oversampling = total if absf(total - 1.0) > 0.01 else 0.0


				f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO if absf(s - roundf(s)) > 0.01 else TextServer.SUBPIXEL_POSITIONING_DISABLED
	get_tree().root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR if ui_smooth() else Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST




func _sprite_here(k: String) -> bool:
	return ResourceLoader.exists(ROOT + "sprites/%s.png" % k) and (FileAccess.file_exists(ROOT + "sprites/%s.json" % k)
		or FileAccess.file_exists(ROOT + "sprites/%s.json.gz" % k))



var _has_sprite: = {}
func has_sprite(key: String) -> bool:
	_lock.lock()
	var known = _has_sprite.get(key)
	_lock.unlock()
	if known != null:
		return known
	var k: = key.get_slice("@", 0)
	var yes: = _sprite_here(k)


	if not yes and web_now.is_valid() and GameData.MONSTERS.has(k):
		web_now.call("late:mobs")
		yes = _sprite_here(k)


	if not yes and web_late.is_valid() and k.begins_with("robe_c_") and web_late.call("late:robes"):
		return false
	_lock.lock()
	_has_sprite[key] = yes
	_lock.unlock()
	return yes





var web_late: = Callable()
var web_now: = Callable()





func sprite_json(key: String) -> String:
	var path: = ROOT + "sprites/%s.json" % key
	if FileAccess.file_exists(path):
		return FileAccess.get_file_as_string(path)
	if FileAccess.file_exists(path + ".gz"):
		return FileAccess.get_file_as_bytes(path + ".gz").decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP).get_string_from_utf8()
	return ""




func model_path(model: String) -> String:
	if web_now.is_valid():
		web_now.call("late:models")
	var path: = ROOT + "models/%s.glb" % model
	return path if ResourceLoader.exists(path) else ""





func forget_sprite(keys: Array) -> void :
	_lock.lock()
	_sprites.erase("+".join(keys))
	_lock.unlock()





var _preloading: = {}

var _preload_tasks: Array[int] = []


func preload_async(keys: Array) -> void :
	var id: = "+".join(keys)
	if _cached(id) or _preloading.has(id):
		return
	_preloading[id] = true
	if OS.has_feature("web"):
		web_later( func(): sprite(keys))
		return
	_preload_tasks.append(WorkerThreadPool.add_task( func(): sprite(keys)))





var _later: Array[Callable] = []

func web_later(fn: Callable) -> void :
	_later.append(fn)
	set_process(true)


func _process(_delta: float) -> void :
	if _later.is_empty():
		set_process(false)
		return
	var fn: Callable = _later.pop_front()
	if fn.is_valid():
		fn.call()




func collect_preloads(all: = false) -> void :
	for i in range(_preload_tasks.size() - 1, -1, -1):
		var task: = _preload_tasks[i]
		if all or WorkerThreadPool.is_task_completed(task):
			WorkerThreadPool.wait_for_task_completion(task)
			_preload_tasks.remove_at(i)


func _exit_tree() -> void :
	collect_preloads(true)


func sprite(keys: Array) -> RoSprite:
	var id: = "+".join(keys)
	if _cached(id):
		return _sprites_get(id)
	var t0: = Time.get_ticks_usec()
	var parts: = []
	for key in keys:
		var part: = _load_part(key)
		if part.is_empty():
			_sprites_set(id, null)
			return null
		parts.append(part)
	var spr: = RoSprite.new(parts)
	_sprites_set(id, spr)
	_load_log("sprite", id, t0)
	return spr








func character(body: String, head: String, weapon: = "", weapon_fx: = "", fx_bases: Array = [], headgear: = "", 
		shield: = "", extras: Array = []) -> RoSprite:
	var id: = "char:%s+%s+%s+%s+%s+%s+%s" % [body, head, weapon, weapon_fx, headgear, shield, ",".join(extras)]
	if _cached(id):
		return _sprites_get(id)
	var parts: = []
	for key in [body, head]:
		var part: = _load_part(key)
		if part.is_empty():
			_sprites_set(id, null)
			return null
		parts.append(part)


	if headgear != "":
		var hg: = _load_part(headgear)
		if not hg.is_empty():
			parts.append(hg)
	for key in extras:
		var ex: = _load_part(str(key))
		if ex.is_empty():
			continue
		if str(key).begins_with("robe_"):
			ex.attach = "origin"
			ex.behind = true


			ex.back_over = true
		parts.append(ex)
	if weapon != "":
		var w: = _load_part(weapon)
		if not w.is_empty():
			w.attach = "origin"
			parts.append(w)

	if shield != "":
		var sh: = _load_part(shield)
		if not sh.is_empty():
			sh.attach = "origin"
			parts.append(sh)
	if weapon_fx != "":
		var fx: = _load_part(weapon_fx)
		if not fx.is_empty():
			fx.attach = "origin"
			fx.bases = fx_bases
			parts.append(fx)
	var spr: = RoSprite.new(parts)
	_sprites_set(id, spr)
	return spr








const FRAMES_IDLE_MS: = 60000
const FRAMES_BUDGET_MB: = 160.0

const FRAMES_BUDGET_WEB_MB: = 64.0
const FRAMES_TRIM_EVERY: = 3.0

const FRAMES_TRIM_TOWN: = 1.0


const FRAMES_TRIM_MAX: = 120

const FRAMES_KEEP_MS: = 8000


const CHARS_FORGET_MS: = 300000






const SPRITES_FORGET_MS: = 600000
const SPRITES_FORGET_WEB_MS: = 45000
const SPRITES_FORGET_MAX: = 6


const _ONLY_CACHED: = 3









func trim_frames() -> void :
	collect_preloads()
	var now: = Time.get_ticks_msec()
	var old: = []
	var mb: = 0.0
	var freed: = 0
	var forgot: = 0
	var forget_ms: = SPRITES_FORGET_WEB_MS if OS.has_feature("web") else SPRITES_FORGET_MS
	_lock.lock()
	var ids: = _sprites.keys()
	_lock.unlock()
	for id in ids:
		_lock.lock()
		var spr = _sprites.get(id)
		_lock.unlock()
		if spr == null:
			continue
		var s: RoSprite = spr
		if str(id).begins_with("char:") and now - s.used_ms > CHARS_FORGET_MS:
			forget_sprite([id])
		elif forgot < SPRITES_FORGET_MAX and now - s.used_ms > forget_ms and s.get_reference_count() <= _ONLY_CACHED:
			forget_sprite([id])
			_preloading.erase(id)
			forgot += 1
			continue
		if s._cache.is_empty():
			continue
		if now - s.used_ms > FRAMES_IDLE_MS and freed < FRAMES_TRIM_MAX:
			freed += s._cache.size()
			s.drop_frames()
			continue
		var per: = s.canvas_size.x * s.canvas_size.y * 4 / 1048576.0
		mb += s._cache.size() * per
		for key in s._cache:
			var used: = int(s._used.get(key, 0))
			if now - used > FRAMES_KEEP_MS:
				old.append([used, s, key, per])
	var budget: = FRAMES_BUDGET_WEB_MB if OS.has_feature("web") else FRAMES_BUDGET_MB
	if mb <= budget:
		return
	old.sort_custom( func(a, b): return int(a[0]) < int(b[0]))
	for o in old:
		if mb <= budget or freed >= FRAMES_TRIM_MAX:
			break
		(o[1] as RoSprite).drop_frame(int(o[2]))
		mb -= float(o[3])
		freed += 1





func cache_report() -> String:
	_lock.lock()
	var rows: = []
	var frames: = 0
	var mb: = 0.0
	for id in _sprites:
		var spr: RoSprite = _sprites[id]
		if spr == null:
			continue
		var n: int = spr._cache.size()
		var m: = n * spr.canvas_size.x * spr.canvas_size.y * 4 / 1048576.0
		var sheets: = 0.0
		for part in spr.parts:
			var img: Image = part.get("image")
			if img != null:
				sheets += img.get_width() * img.get_height() * 4 / 1048576.0
		frames += n
		mb += m
		rows.append([id, n, m, sheets])
	_lock.unlock()
	rows.sort_custom( func(a, b): return a[2] > b[2])
	var top: = []
	for r in rows.slice(0, 6):
		top.append("%s:%d/%.0fMB" % [r[0], r[1], r[2]])
	return "sprites=%d frames=%d framesMB=%.0f effects=%d msg=%d placeholders=%d top=%s" % [_sprites.size(), frames, mb, 
		_effect_textures.size(), _msg_tex.size(), _placeholders.size(), " ".join(top)]


func _cached(id: String) -> bool:
	_lock.lock()
	var yes: = _sprites.has(id)
	_lock.unlock()
	return yes


func _sprites_get(id: String) -> RoSprite:
	_lock.lock()
	var spr: RoSprite = _sprites.get(id)
	_lock.unlock()
	return spr


func _sprites_set(id: String, spr: RoSprite) -> void :
	_lock.lock()
	_sprites[id] = spr
	_lock.unlock()



func has_palette(id: String) -> bool:
	_lock.lock()
	if not _palettes_loaded:
		_palettes_loaded = true
		var path: = ROOT + "palettes.json"
		if FileAccess.file_exists(path):
			var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
			if parsed is Dictionary:
				_palettes = parsed
	_lock.unlock()
	if id.begins_with("skin"):
		return Skins.palette(id) != ""
	return _palettes.has(id)



func cloth_dyes(body: String, female: bool) -> int:
	var key: = _gendered(body, female)
	var n: = 0
	while n < GameData.CLOTH_DYES and has_palette("body_%s_%d" % [key, n + 1]):
		n += 1
	return n




func cloth_palette(key: String, dye: int) -> String:
	var id: = "body_%s_%d" % [key, dye]
	return id if dye > 0 and has_palette(id) else ""



func _gendered(key: String, female: bool) -> String:
	if not female or key == "" or not has_sprite(key + "_f"):
		return key
	return key + "_f"




func styled_character(body: String, weapon: String, weapon_fx: String, fx_bases: Array, 
		headgear: String, look: Dictionary, shield: = "", extras: Array = []) -> RoSprite:
	var female: = str(look.get("gender", "m")) == "f"
	var g: = "f" if female else "m"
	var body_key: = _gendered(body, female)
	var cloth_pal: = cloth_palette(body_key, int(look.get("cloth", 0)))

	var skin: = str(look.get("skin", ""))
	var skin_pal: = Skins.palette_id(skin, body_key) if skin != "" else ""
	var mask_body: = ""
	if skin_pal != "":
		mask_body = body_key + "@skinmask_" + skin_pal.trim_prefix("skin_")
		body_key += "@" + skin_pal
	elif cloth_pal != "":
		body_key += "@" + cloth_pal
	var hair: = int(look.get("hair", 2))

	var race: = "doram_" if GameData.is_doram_body(body) else ""
	var head: = "head_%s%s_%d" % [race, g, hair]
	if not has_sprite(head):
		head = "head_doram_%s_1" % g if race != "" else "head_m"
	else:
		var hc: = int(look.get("hair_color", 0))
		if hc > 0 and has_palette("hair_%s%s_%d_%d" % [race, g, hair, hc]):
			head += "@hair_%s%s_%d_%d" % [race, g, hair, hc]
	var spr: = character(body_key, head, _gendered(weapon, female), _gendered(weapon_fx, female), fx_bases, 
		_gendered(headgear, female), _gendered(shield, female), extras.map( func(k): return _gendered(str(k), female)))



	if spr != null and mask_body != "" and spr.skin_mask == null:
		var dark: = func(k: String) -> String: return "" if k == "" else k.get_slice("@", 0) + "@black"
		spr.skin = skin
		spr.skin_mask = character(mask_body, dark.call(head), dark.call(_gendered(weapon, female)), dark.call(_gendered(weapon_fx, female)), fx_bases, 
			dark.call(_gendered(headgear, female)), dark.call(_gendered(shield, female)), 
			extras.map( func(k): return dark.call(_gendered(str(k), female))))
	return spr




const DYE_SKIN: = {
	"body_bard_f": {1: 1, 2: 1, 25: 1, 26: 1, 27: 1, 28: 1, 29: 1, 30: 1, 31: 1, 32: 1, 34: 1, 35: 1, 36: 1, 37: 1, 38: 1, 39: 1, 
		48: 1, 49: 1, 50: 1, 51: 1, 52: 1, 53: 1, 54: 1, 55: 1, 66: 1, 67: 1, 68: 1, 69: 1, 70: 1, 71: 1, 72: 1, 73: 1, 
		74: 1, 75: 1, 76: 1, 77: 1, 78: 1, 79: 1}, 
}




func _recolored_part(key: String) -> Dictionary:
	var base: = key.get_slice("@", 0)
	var pal_id: = key.get_slice("@", 1)
	var part: = _load_part(base)

	if pal_id == "black" and not part.is_empty():
		var dimg: Image = part.image.duplicate()
		var dpx: = dimg.get_data()
		for o in range(0, dpx.size(), 4):
			if dpx[o + 3] > 0:
				dpx[o] = 0
				dpx[o + 1] = 0
				dpx[o + 2] = 0
		part = part.duplicate()
		part.image = Image.create_from_data(dimg.get_width(), dimg.get_height(), false, Image.FORMAT_RGBA8, dpx)
		return part
	var idx_path: = ROOT + "sprites/%s.idx.png" % base
	if part.is_empty() or not has_palette(pal_id) or not ResourceLoader.exists(idx_path):
		return part
	var idx_img: = image_of(idx_path)
	if idx_img == null:
		return part
	idx_img.convert(Image.FORMAT_L8)
	var pal: PackedByteArray = (Skins.palette(pal_id) if pal_id.begins_with("skin") else str(_palettes[pal_id])).hex_decode()
	var img: Image = part.image
	if idx_img.get_size() != img.get_size():
		return part
	var px: = img.get_data()
	var ids: = idx_img.get_data()


	var cut: = pal_id.rfind("_")
	var keep: Dictionary = DYE_SKIN.get(pal_id.left(cut), {}) if cut > 0 and int(pal_id.substr(cut + 1)) <= 4 else {}
	for i in ids.size():
		var c: = ids[i]
		if c == 0 or keep.has(c):
			continue
		var o: = i * 4
		px[o] = pal[c * 3]
		px[o + 1] = pal[c * 3 + 1]
		px[o + 2] = pal[c * 3 + 2]
	part.image = Image.create_from_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, px)
	return part


func _load_part(key: String) -> Dictionary:
	if key.contains("@"):
		return _recolored_part(key)
	if not has_sprite(key):
		return {}
	var text: = sprite_json(key)
	var meta = JSON.parse_string(text)
	var img: = image_of(ROOT + "sprites/%s.png" % key)
	if not meta is Dictionary or img == null:
		push_warning("RoAssets: could not read sprite %s" % key)
		return {}
	return {"meta": meta, "image": img}







static func image_of(path: String) -> Image:
	var img: = _decode_ctex(path)
	if img == null:
		var tex: = load(path) as Texture2D
		if tex == null:
			return null
		img = tex.get_image()
		if img == null:
			return null
	if img.is_compressed():
		img.decompress()
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	return img




static func tex_image(tex: Texture2D) -> Image:
	if tex == null:
		return null
	var path: = tex.resource_path
	if path.ends_with(".png") and not path.contains("::"):
		var img: = image_of(path)
		if img != null:
			return img
	return tex.get_image()


static func _decode_ctex(path: String) -> Image:
	var imp: = ConfigFile.new()
	if imp.load(path + ".import") != OK:
		return null
	var ctex: = str(imp.get_value("remap", "path", ""))
	if ctex == "" or not ctex.ends_with(".ctex"):
		return null
	var f: = FileAccess.open(ctex, FileAccess.READ)
	if f == null or f.get_length() < 56 or f.get_buffer(4).get_string_from_ascii() != "GST2":
		return null



	f.seek(36)
	var data_format: = f.get_32()
	f.get_16()
	f.get_16()
	f.get_32()
	f.get_32()
	var size: = f.get_32()
	if size <= 0 or size > f.get_length():
		return null
	var buf: = f.get_buffer(size)
	var img: = Image.new()
	var err: = FAILED
	if data_format == 2:
		err = img.load_webp_from_buffer(buf)
	elif data_format == 1:
		err = img.load_png_from_buffer(buf)
	return img if err == OK else null





func damage_text(text: String) -> Texture2D:
	if text == "Miss":
		var miss: = sprite(["fx_miss"])
		return miss.get_frame(0, 0) if miss != null else null
	var digits: = ""
	for c in text:
		if c >= "0" and c <= "9":
			digits += c
	if digits == "":
		return null


	digits = short_digits(digits)
	if _digit_cache.has(digits):
		return _digit_cache[digits]
	if _digits.is_empty():
		_digits = _load_part("fx_numbers")
		if _digits.is_empty():
			return null
	var frames: Array = _digits.meta.frames
	var width: = 0
	var height: = 0
	for c in digits:
		var r: = _glyph_rect(frames, c)
		width += int(r[2]) - 1
		height = maxi(height, int(r[3]))
	var img: = Image.create(width + 1, height, false, Image.FORMAT_RGBA8)
	var x: = 0
	for c in digits:
		var r: = _glyph_rect(frames, c)
		var src: Image = _glyph_image(c, r)
		img.blend_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(x, height - int(r[3])))
		x += int(r[2]) - 1


	if _digit_cache.size() >= DIGIT_CACHE_MAX:
		var drop: = DIGIT_CACHE_MAX / 4
		for k in _digit_cache.keys():
			_digit_cache.erase(k)
			drop -= 1
			if drop <= 0:
				break
	var tex: = ImageTexture.create_from_image(img)
	_digit_cache[digits] = tex
	_digit_images[digits] = img
	return tex





var _digit_images: = {}


func damage_image(text: String) -> Image:
	var tex: = damage_text(text)
	if tex == null:
		return null
	var digits: = ""
	for c in text:
		if c >= "0" and c <= "9":
			digits += c
	var img: Image = _digit_images.get(short_digits(digits)) if digits != "" else null
	if img == null:
		img = tex.get_image()
	if _digit_images.size() > DIGIT_CACHE_MAX:
		_digit_images.clear()
	return img






var _glyph_atlas: = {}
func glyph_atlas() -> Dictionary:
	if not _glyph_atlas.is_empty():
		return _glyph_atlas
	if _digits.is_empty():
		_digits = _load_part("fx_numbers")
		if _digits.is_empty():
			return {}
	var frames: Array = _digits.meta.frames
	var glyphs: = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "K", "M", "."] + DRAWN_GLYPHS.keys()
	var w: = 0
	var h: = 0
	for c in glyphs:
		var r: = _glyph_rect(frames, c)
		w += int(r[2]) + 2
		h = maxi(h, int(r[3]))
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rects: = {}
	var x: = 0
	for c in glyphs:
		var r: = _glyph_rect(frames, c)
		var src: = _glyph_image(c, r)
		img.blit_rect(src, Rect2i(Vector2i.ZERO, src.get_size()), Vector2i(x, 0))
		rects[c] = Rect2i(x, 0, src.get_width(), src.get_height())
		x += src.get_width() + 2
	_glyph_atlas = {"tex": ImageTexture.create_from_image(img), "rects": rects, "size": Vector2(w, h)}
	return _glyph_atlas



func shown_digits(text: String) -> String:
	var digits: = ""
	for c in text:
		if c >= "0" and c <= "9":
			digits += c
	return short_digits(digits) if digits != "" else ""


const DIGIT_CACHE_MAX: = 4096

var _glyph_cache: = {}
func _glyph_image(c: String, r: Array) -> Image:
	if c == ".":
		return _dot_image()
	if DRAWN_GLYPHS.has(c):
		return _drawn_image(c)
	if not _glyph_cache.has(c):
		_glyph_cache[c] = _digits.image.get_region(Rect2i(r[0], r[1], r[2], r[3]))
	return _glyph_cache[c]






const DIGIT_UNITS: = ["Qi", "Sx", "Sp", "Oc", "No", "Dc"]
static func short_digits(digits: String) -> String:
	digits = digits.lstrip("0")
	if digits.length() <= 18:
		return short_number(int(digits)) if digits != "" else "0"
	var e: = digits.length() - 1

	var head: = int(digits.left(3)) + (1 if digits[3] >= "5" else 0)
	if head >= 1000:
		head = 100
		e += 1
	var h: = str(head)
	var group: = e / 3 - 6
	if group >= DIGIT_UNITS.size():
		return "%se%d" % [(h[0] + "." + h.substr(1)).rstrip("0").rstrip("."), e]
	var whole: = e % 3 + 1
	var s: = h.left(whole)
	if whole < 3:
		s = (s + "." + h.substr(whole)).rstrip("0").rstrip(".")
	return s + str(DIGIT_UNITS[group])


const NUMBER_UNITS: = [[1000000000000000, "Q"], [1000000000000, "T"], [1000000000, "B"], [1000000, "M"]]



static func short_number(v: int) -> String:
	if v < 10000:
		return str(v)

	if v >= 999500000000000000:
		return "1Qi"
	var unit: = "K"
	var f: = v / 1000.0
	for u in NUMBER_UNITS:
		if v >= u[0]:
			unit = u[1]
			f = v / float(u[0])
			break
	var s: = str(snappedf(f, 0.01 if f < 10.0 else (0.1 if f < 100.0 else 1.0)))
	if s.contains("."):
		s = s.rstrip("0").rstrip(".")
	return s + unit




func _glyph_rect(frames: Array, c: String) -> Array:
	if c == "K":
		return frames[10]
	if c == "M":
		return frames[11]
	if DRAWN_GLYPHS.has(c):
		return [0, 0, GLYPH_CELL.x, GLYPH_CELL.y]
	if c == ".":
		var d: = _dot_image()
		return [0, 0, d.get_width(), d.get_height()]
	return frames[int(c)]



const GLYPH_CELL: = Vector2i(10, 13)
const DRAWN_GLYPHS: = {
	"B": ["#####.", "##..##", "##..##", "##..##", "#####.", "##..##", "##..##", "##..##", "#####."], 
	"T": ["######", "######", "..##..", "..##..", "..##..", "..##..", "..##..", "..##..", "..##.."], 
	"Q": [".####.", "##..##", "##..##", "##..##", "##..##", "##.###", "##.###", ".####.", "...###"], 


	"S": [".####.", "##..##", "##....", ".###..", "..###.", "....##", "....##", "##..##", ".####."], 
	"O": [".####.", "##..##", "##..##", "##..##", "##..##", "##..##", "##..##", "##..##", ".####."], 
	"N": ["##..##", "###.##", "###.##", "######", "######", "##.###", "##.###", "##..##", "##..##"], 
	"D": ["####..", "##.##.", "##..##", "##..##", "##..##", "##..##", "##..##", "##.##.", "####.."], 
	"i": ["..##..", "..##..", "......", ".###..", "..##..", "..##..", "..##..", "..##..", ".####."], 
	"x": ["......", "......", "##..##", "##..##", ".####.", "..##..", ".####.", "##..##", "##..##"], 
	"p": ["......", "......", "#####.", "##..##", "##..##", "##..##", "#####.", "##....", "##...."], 
	"c": ["......", "......", ".####.", "##..##", "##....", "##....", "##....", "##..##", ".####."], 
	"o": ["......", "......", ".####.", "##..##", "##..##", "##..##", "##..##", "##..##", ".####."], 
	"e": ["......", "......", ".####.", "##..##", "##..##", "######", "##....", "##..##", ".####."], 
}
var _drawn: = {}


func _drawn_image(c: String) -> Image:
	if _drawn.has(c):
		return _drawn[c]
	var src: Image = _digits.image
	var r: Array = _digits.meta.frames[8]
	var img: = Image.create(GLYPH_CELL.x, GLYPH_CELL.y, false, Image.FORMAT_RGBA8)
	var rows: Array = DRAWN_GLYPHS[c]
	for y in rows.size():
		var light: = Color.BLACK
		for x in int(r[2]):
			var px: = src.get_pixel(int(r[0]) + x, int(r[1]) + y + 2)
			if px.a > 0.5 and px.get_luminance() > light.get_luminance():
				light = px
		for x in str(rows[y]).length():
			if str(rows[y])[x] == "#":
				img.set_pixel(x + 2, y + 2, light)
	var done: Image = img.duplicate()
	for y in GLYPH_CELL.y:
		for x in GLYPH_CELL.x:
			if img.get_pixel(x, y).a > 0.0:
				continue
			for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var n: Vector2i = Vector2i(x, y) + d
				if Rect2i(Vector2i.ZERO, GLYPH_CELL).has_point(n) and img.get_pixelv(n).a > 0.0:
					done.set_pixel(x, y, Color.BLACK)
	_drawn[c] = done
	return done




var _dot: Image
func _dot_image() -> Image:
	if _dot == null:
		var src: Image = _digits.image
		var r: Array = _digits.meta.frames[1]
		var fill: = Color(0.9, 0.9, 0.95)
		var edge: = Color(0.1, 0.1, 0.18)

		var lo: = 2.0
		var hi: = -1.0
		for y in int(r[3]):
			for x in int(r[2]):
				var px: = src.get_pixel(int(r[0]) + x, int(r[1]) + y)
				if px.a < 0.5:
					continue
				var v: = px.get_luminance()
				if v > hi:
					hi = v
					fill = px
				if v < lo:
					lo = v
					edge = px
		_dot = Image.create(5, 5, false, Image.FORMAT_RGBA8)
		for y in 5:
			for x in 5:
				var border: = x == 0 or y == 0 or x == 4 or y == 4
				var corner: = (x == 0 or x == 4) and (y == 0 or y == 4)
				if not corner:
					_dot.set_pixel(x, y, edge if border else fill)
	return _dot






var _msg_white: = {}





var _crit_stars: Texture2D
func crit_stars() -> Texture2D:
	if _crit_stars != null:
		return _crit_stars
	var tex: = msg_part(3)
	if tex == null:
		return null
	var red: = tex.get_image()
	red.convert(Image.FORMAT_RGBA8)
	var w: = red.get_width()
	var h: = red.get_height()
	var img: = Image.create(w * 2, h, false, Image.FORMAT_RGBA8)
	img.blit_rect(red, Rect2i(0, 0, w, h), Vector2i.ZERO)
	for y in h:
		for x in w:
			var c: = red.get_pixel(x, y)


			img.set_pixel(w + x, y, Color(c.b, lerpf(c.g, c.r, 0.55), c.r, c.a))
	_crit_stars = ImageTexture.create_from_image(img)
	return _crit_stars




var _crit_blue: Texture2D
func crit_star_blue() -> Texture2D:
	if _crit_blue != null:
		return _crit_blue
	var both_tex: = crit_stars()
	if both_tex == null:
		return null
	var img: = both_tex.get_image()
	var w: = img.get_width() / 2
	_crit_blue = ImageTexture.create_from_image(img.get_region(Rect2i(w, 0, w, img.get_height())))
	return _crit_blue


func msg_part_white(i: int) -> Texture2D:
	if _msg_white.has(i):
		return _msg_white[i]
	var tex: = msg_part(i)
	if tex == null:
		return null
	var img: = tex.get_image()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c: = img.get_pixel(x, y)
			var v: = maxf(c.r, maxf(c.g, c.b))
			img.set_pixel(x, y, Color(v, v, v, c.a))
	var out: = ImageTexture.create_from_image(img)
	_msg_white[i] = out
	return out


func msg_part(i: int) -> Texture2D:
	if _msg_tex.has(i):
		return _msg_tex[i]
	if _msg.is_empty():
		_msg = _load_part("fx_msg")
		if _msg.is_empty():
			return null
	var frames: Array = _msg.meta.frames
	if i >= frames.size():
		return null
	var r: Array = frames[i]
	var tex: = ImageTexture.create_from_image(_msg.image.get_region(Rect2i(r[0], r[1], r[2], r[3])))
	_msg_tex[i] = tex
	return tex




func msg_turned(i: int, deg: float) -> Texture2D:
	var key: = "%d@%d" % [i, roundi(deg)]
	if _msg_tex.has(key):
		return _msg_tex[key]
	var src: = msg_part(i)
	if src == null:
		return null
	var r: Array = _msg.meta.frames[i]
	var img: Image = _msg.image.get_region(Rect2i(r[0], r[1], r[2], r[3]))
	var side: = ceili(sqrt(img.get_width() * img.get_width() + img.get_height() * img.get_height()))
	var out: = Image.create(side, side, false, Image.FORMAT_RGBA8)
	var a: = deg_to_rad(deg)
	var c: = Vector2(side, side) * 0.5
	var sc: = Vector2(img.get_width(), img.get_height()) * 0.5
	for y in side:
		for x in side:
			var q: = (Vector2(x, y) - c).rotated( - a) + sc
			if q.x >= 0.0 and q.y >= 0.0 and q.x < img.get_width() and q.y < img.get_height():
				var px: = img.get_pixel(int(q.x), int(q.y))
				var v: = minf(1.0, px.get_luminance() * 1.8 + 0.2)
				out.set_pixel(x, y, Color(v, v, v, px.a))
	var tex: = ImageTexture.create_from_image(out)
	_msg_tex[key] = tex
	return tex



func placeholder(color: Color, size_px: int, eyes: = true) -> Texture2D:
	var id: = "%s_%d_%s" % [color.to_html(), size_px, eyes]
	if _placeholders.has(id):
		return _placeholders[id]
	var w: = size_px
	var h: = int(size_px * 1.1)
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var c: = Vector2(w / 2.0, h * 0.58)
	var r: = Vector2(w * 0.46, h * 0.42)
	var outline: = color.darkened(0.55)
	for y in h:
		for x in w:
			var p: = (Vector2(x + 0.5, y + 0.5) - c) / r
			var d: = p.length()
			if d > 1.0:
				continue
			var col: = outline if d > 0.88 else color.lerp(Color.WHITE, clampf( - p.y - p.x * 0.3, 0.0, 1.0) * 0.35)
			img.set_pixel(x, y, col)
	if eyes:
		for side in [-1, 1]:
			var e: = c + Vector2(side * w * 0.14, - h * 0.05)
			for y in range(int(e.y - h * 0.08), int(e.y + h * 0.08) + 1):
				for x in range(int(e.x - w * 0.035), int(e.x + w * 0.035) + 1):
					if x >= 0 and y >= 0 and x < w and y < h:
						img.set_pixel(x, y, Color(0.12, 0.06, 0.1))
	var tex: = ImageTexture.create_from_image(img)
	_placeholders[id] = tex
	return tex






const NO_CLIENT_ART: = ["zherlthsh_card", "khalitzburg_card", "ktullanux_card"]



func card_art(id: String) -> Texture2D:
	var path: = "res://assets/ro/ui/skin/cards/%s.png" % id
	if ResourceLoader.exists(path) and not id in NO_CLIENT_ART:
		return load(path)
	var key: = "card_art_" + id
	if _placeholders.has(key):
		return _placeholders[key]
	var img: = Image.create(150, 200, false, Image.FORMAT_RGBA8)
	for y in 200:
		var c: = Color(0.16, 0.12, 0.2).lerp(Color(0.45, 0.12, 0.14), y / 199.0)
		for x in 150:
			var edge: = x < 4 or y < 4 or x > 145 or y > 195
			img.set_pixel(x, y, Color(0.85, 0.72, 0.4) if edge else c)
	for mob in GameData.MONSTERS:
		if GameData.MONSTERS[mob].get("card", "") != id:
			continue
		var spr: = sprite([mob])
		var frame: Texture2D = spr.get_frame(0, 0) if spr != null else null
		if frame != null:
			var m: = frame.get_image()
			if m.is_compressed():
				m.decompress()
			m.convert(Image.FORMAT_RGBA8)
			var used: = m.get_used_rect()
			if used.size.x > 0:
				m = m.get_region(used)
				var k: = minf(130.0 / m.get_width(), 170.0 / m.get_height())
				m.resize(maxi(1, int(m.get_width() * k)), maxi(1, int(m.get_height() * k)), Image.INTERPOLATE_NEAREST)
				img.blend_rect(m, Rect2i(Vector2i.ZERO, m.get_size()), Vector2i((150 - m.get_width()) / 2, (200 - m.get_height()) / 2))
		break
	var tex: = ImageTexture.create_from_image(img)
	_placeholders[key] = tex
	return tex


func radial(color: Color, size_px: = 64) -> Texture2D:
	var id: = "radial_%s_%d" % [color.to_html(), size_px]
	if _placeholders.has(id):
		return _placeholders[id]
	var g: = Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color, 0.0))
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0.0)
	t.width = size_px
	t.height = size_px
	_placeholders[id] = t
	return t



func register_sound(key: String, stream: AudioStream) -> void :
	_sounds[key] = stream


func sound(key: String) -> AudioStream:
	if _sounds.has(key):
		return _sounds[key]
	var t0: = Time.get_ticks_usec()
	var path: = ROOT + "audio/%s.wav" % key
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	_sounds[key] = stream
	_load_log("sound", key, t0)
	return stream




func _load_log(kind: String, key: String, t0: int) -> void :
	var ms: = (Time.get_ticks_usec() - t0) / 1000.0
	if ms >= (1.0 if _log_loads else 30.0):
		print("LOAD %s %s %.1f ms" % [kind, key, ms])


var _log_loads: = "--load-log" in OS.get_cmdline_user_args()


var _check_fx_alpha: = "--fx-alpha-check" in OS.get_cmdline_user_args()


func _fx_alpha_check() -> void :
	if _check_fx_alpha:
		var n: = 0
		for f in DirAccess.get_files_at(ROOT + "effects"):
			if f.ends_with(".json"):
				effect_data(f.get_basename())
				n += 1
		print("FXALPHA checked %d" % n)




func music(track: String, map_name: = "") -> AudioStream:
	var file: = "login.mp3" if track == "login" else "bgm.mp3"
	if track != "login" and map_name != "" and ResourceLoader.exists(ROOT + "audio/bgm_%s.mp3" % map_name):
		file = "bgm_%s.mp3" % map_name
	var path: = ROOT + "audio/" + file
	if not ResourceLoader.exists(path):
		return null
	var stream: = load(path) as AudioStream
	if stream is AudioStreamMP3:
		stream.loop = true
	return stream



func effect_tex(key: String) -> Texture2D:
	for path in [ROOT + "effects/tex/%s.png" % key, ROOT + "effects/%s.png" % key]:
		if ResourceLoader.exists(path):
			return load(path) as Texture2D
	return null




func mob_sound(mob: String, kind: String) -> String:
	var key: = mob + ":" + kind
	if _mob_sounds.has(key):
		return _mob_sounds[key]
	var found: = ""
	var text: = sprite_json(mob) if has_sprite(mob) else ""
	var meta = JSON.parse_string(text) if text != "" else null
	if meta is Dictionary:
		for ev in meta.get("events", []):
			var name: = str(ev).get_file().to_lower()
			if name.ends_with(".wav") and ("_" + kind) in name and ResourceLoader.exists(ROOT + "audio/mob/" + name):
				found = name.get_basename()
				break
	_mob_sounds[key] = found
	return found



func effect_data(effect_name: String) -> Dictionary:
	if _effect_data.has(effect_name):
		return _effect_data[effect_name]
	var t0: = Time.get_ticks_usec()
	var meta_path: = ROOT + "effects/%s.json" % effect_name
	var atlas_path: = ROOT + "effects/%s.png" % effect_name
	var out: = {}
	if FileAccess.file_exists(meta_path) and ResourceLoader.exists(atlas_path):
		var meta = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
		if meta is Dictionary:
			out = meta
			out.atlas = load(atlas_path) as Texture2D





			if meta.has("tex_alpha") and (meta.tex_alpha as Array).size() == (meta.textures as Array).size() and not _check_fx_alpha:
				_effect_data[effect_name] = out
				_load_log("effect", effect_name, t0)
				return out
			var img: Image = tex_image(out.atlas)
			if img.is_compressed():
				img.decompress()
			var has_alpha: = []
			for r in out.textures:
				var region: = img.get_region(Rect2i(r[0], r[1], maxi(1, r[2]), maxi(1, r[3])))
				has_alpha.append(region.detect_alpha() != Image.ALPHA_NONE)
			if _check_fx_alpha and meta.has("tex_alpha") and meta.tex_alpha != has_alpha:
				print("FXALPHA mismatch %s" % effect_name)
			out.tex_alpha = has_alpha
	_effect_data[effect_name] = out
	_load_log("effect", effect_name, t0)
	return out


func effect_sprite(effect_name: String) -> Texture2D:
	if _effect_textures.has(effect_name):
		return _effect_textures[effect_name]
	var path: = ROOT + "effects/%s.png" % effect_name
	var texture: = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_effect_textures[effect_name] = texture
	return texture



func effect_texture(effect_name: String, texture_index: = 0) -> Texture2D:
	var cache_key: = "%s:%d" % [effect_name, texture_index]
	if _effect_textures.has(cache_key):
		return _effect_textures[cache_key]
	var meta_path: = ROOT + "effects/%s.json" % effect_name
	var atlas_path: = ROOT + "effects/%s.png" % effect_name
	if not FileAccess.file_exists(meta_path) or not ResourceLoader.exists(atlas_path):
		_effect_textures[cache_key] = null
		return null
	var meta = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
	if not meta is Dictionary or texture_index < 0 or texture_index >= meta.get("textures", []).size():
		_effect_textures[cache_key] = null
		return null
	var rect: Array = meta.textures[texture_index]
	var region: = AtlasTexture.new()
	region.atlas = load(atlas_path) as Texture2D
	region.region = Rect2(rect[0], rect[1], rect[2], rect[3])
	_effect_textures[cache_key] = region
	return region


func map_scene(map_name: String) -> PackedScene:
	var path: = ROOT + "maps/%s.glb" % map_name
	return load(path) if ResourceLoader.exists(path) else null




var web_maps: = {}




func map_exists(map_name: String) -> bool:
	return web_maps.has(map_name) or ResourceLoader.exists(ROOT + "maps/%s.glb" % map_name)





func map_grid(map_name: String) -> Dictionary:
	var bin: = ROOT + "maps/%s.gat" % map_name
	if FileAccess.file_exists(bin):
		return _read_grid(bin)
	var path: = ROOT + "maps/%s.gat.json" % map_name
	if not FileAccess.file_exists(path):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}


func _read_grid(path: String) -> Dictionary:
	var raw: = FileAccess.get_file_as_bytes(path).decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
	if raw.size() < 16 or raw.slice(0, 4).get_string_from_ascii() != "GAT1":
		push_error("RoAssets: bad map grid %s" % path)
		return {}
	var w: = raw.decode_u32(4)
	var h: = raw.decode_u32(8)
	var flags: = raw.decode_u32(12)
	var n: = w * h
	var at: = 16
	var out: = {"w": w, "h": h}
	out["heights"] = raw.slice(at, at + n * 4).to_float32_array()
	at += n * 4
	if flags & 1:
		out["height_corners"] = raw.slice(at, at + n * 16).to_float32_array()
		at += n * 16
	out["walk"] = raw.slice(at, at + n)
	at += n
	if flags & 2:
		var g: = raw.decode_u32(at)
		out["ground"] = raw.slice(at + 4, at + 4 + g * 4).to_float32_array()
	return out
