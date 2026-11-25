class_name StatusMarks
extends RefCounted










const ORDER: = ["poison", "burn", "bleed", "judgment", "prey", "stagger"]


const SKILL_ICON: = {"judgment": "divine_judgment", "stagger": "status_combo", "prey": "blitz_beat"}


const ICON: = 26
const GAP: = 3
const SCALE: = 0.62
const BOSS_SCALE: = 1.35


const CHIP: = 44
const HUD_SIDE: = 34.0
const CHIP_COUNT: = Color(1.0, 0.92, 0.6)
const BLEED_SHOW: = 1200


const BOSS_STATES: = [["lex_until", "lex_aeterna", "Lex Aeterna"], ["signum_until", "signum_crucis", "Signum Crucis"], 
	["acid_until", "acid_terror", "Ácido"], ["trapped_until", "beast_bane", "Trampa"]]

const BURN_STEPS: = 6
const PLATE: = Color(0.06, 0.05, 0.09, 0.8)
const POISON_COLOR: = Color(0.68, 0.8, 0.45)
const PREY_COLOR: = Color(0.85, 0.75, 0.6)
const POISON_FULL: = Color(1.0, 0.4, 0.9)

const DROP: = ["...#...", "...#...", "..###..", "..###..", ".#####.", "#######", "#######", ".#####.", "..###.."]

static var _tex: = {}
static var _icons: = {}

static var _imgs: = {}
static var _rows: = {}


const ROWS_MAX: = 600





static func set_mark(e: Enemy, kind: String, value: int, most: int) -> void :
	if e == null or not is_instance_valid(e):
		return
	if e.def.get("mvp", false):
		_set_boss(e, kind, [value, most])
		return

	var marks: Dictionary = e.get_meta("status_marks") if e.has_meta("status_marks") else {}
	var was = marks.get(kind)
	if was != null and int(was[0]) == value and int(was[1]) == most:
		return


	if _icon(kind) == null:
		return
	if was != null:
		was[0] = value
		was[1] = most
	else:
		marks[kind] = [value, most]
		e.set_meta("status_marks", marks)
	_dirty[e.get_instance_id()] = e




static func _set_boss(e: Enemy, kind: String, value: Variant) -> void :
	var now: Dictionary = e.get_meta("boss_marks") if e.has_meta("boss_marks") else {}
	if kind == "bleed":
		e.set_meta("bleed_seen", Time.get_ticks_msec() + BLEED_SHOW)
	if value == null:
		now.erase(kind)
	else:
		now[kind] = value
	e.set_meta("boss_marks", now)






static func boss_chips(e: Enemy, now: float, fight: = -1.0) -> Array:
	var out: = []
	var marks: Dictionary = e.get_meta("boss_marks") if e.has_meta("boss_marks") else {}
	for k in [["poison", "Veneno"], ["burn", "Quemadura"], ["bleed", "Sangrado"], ["judgment", "Judgment of Asgard"], ["prey", "Presa"]]:
		if marks.has(k[0]):
			out.append([_chip("skill_icons" if SKILL_ICON.has(k[0]) else "status_icons", SKILL_ICON.get(k[0], k[0]), int(marks[k[0]][0])), k[1]])
		elif k[0] == "bleed" and int(e.get_meta("bleed_seen", 0)) > Time.get_ticks_msec():
			out.append([_chip("status_icons", "bleed", 0), k[1]])
	for st in BOSS_STATES:
		var at: float = fight if st[0] in ["trapped_until", "acid_until"] and fight >= 0.0 else now
		if float(e.get(st[0])) > at:
			out.append([_chip("skill_icons", str(st[1]), 0), str(st[2])])
	if fight >= 0.0 and e.weak_until > fight:
		out.append([_chip("skill_icons", "eswoo", 0), "Alma atada"])
	if e.blind_time > 0.0:
		out.append([_chip("skill_icons", "raid", 0), "Ceguera"])
	if e.slow_time > 0.0:
		out.append([_chip("skill_icons", "quagmire", 0), "Ralentizado"])
	if e.snare_time > 0.0:
		out.append([_chip("skill_icons", "spider_web", 0), "Atrapado"])
	if e.kunai_stuck > 0:
		out.append([_chip("skill_icons", "kunai_explosion", e.kunai_stuck), "Kunai"])
	return out.filter( func(c): return c[0] != null)



static func _chip(dir: String, id: String, n: int) -> Texture2D:
	var key: = "chip:%s:%d" % [id, n]
	if _tex.has(key):
		return _tex[key]
	var path: = "res://assets/ro/ui/skin/%s/%s.png" % [dir, id]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		var icon: Image = RoAssets.image_of(path)
		icon.convert(Image.FORMAT_RGBA8)
		icon.resize(CHIP - 2, CHIP - 2, Image.INTERPOLATE_BILINEAR)
		var img: = Image.create(CHIP, CHIP, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.05, 0.04, 0.08, 0.92))
		img.blend_rect(icon, Rect2i(0, 0, CHIP - 2, CHIP - 2), Vector2i.ONE)
		for i in CHIP:
			for side in [Vector2i(i, 0), Vector2i(i, CHIP - 1), Vector2i(0, i), Vector2i(CHIP - 1, i)]:
				img.set_pixelv(side, Color(0.75, 0.62, 0.32))
		var digits: = _digits(str(n), CHIP_COUNT) if n > 0 else null
		if digits != null:
			var at: = Vector2i(CHIP, CHIP) - digits.get_size() - Vector2i(3, 3)
			img.fill_rect(Rect2i(at - Vector2i(2, 1), digits.get_size() + Vector2i(4, 2)), Color(0.03, 0.02, 0.05, 0.85))
			img.blend_rect(digits, Rect2i(Vector2i.ZERO, digits.get_size()), at)
		tex = ImageTexture.create_from_image(img)
	_tex[key] = tex
	return tex



static func shown() -> bool:
	return bool(Save.setting("status_marks", true))






const COMMON_ALPHA: = 0.55
static func notable(e: Enemy) -> bool:
	return e.is_boss or e.feroz or bool(e.def.get("elite", false))


static func shows_on(e: Enemy) -> bool:
	return shown() and (notable(e) or bool(Save.setting("status_marks_common", false)))



static func show_all(enemies: Array, on: bool) -> void :
	for e in enemies:
		if not is_instance_valid(e) or not (e as Node).has_meta("status_sprite"):
			continue
		var s = (e as Node).get_meta("status_sprite")
		if s != null and is_instance_valid(s):
			(s as Node3D).visible = on and shows_on(e)


static func clear_mark(e: Enemy, kind: String) -> void :
	if e != null and is_instance_valid(e) and e.def.get("mvp", false):
		_set_boss(e, kind, null)
		return
	if e == null or not is_instance_valid(e) or not e.has_meta("status_marks"):
		return
	var marks: Dictionary = e.get_meta("status_marks")
	if kind == "burn":
		e.burn_mark = Vector2i(-1, -1)
	if not marks.has(kind):
		return
	marks.erase(kind)
	_dirty[e.get_instance_id()] = e






static var _dirty: = {}


static func flush() -> void :
	if _dirty.is_empty():
		return
	var list: = _dirty.values()
	_dirty.clear()
	for e in list:
		if is_instance_valid(e) and e.has_meta("status_marks"):
			_redraw(e, e.get_meta("status_marks"))


static func clear_all(e: Enemy) -> void :
	if e == null or not is_instance_valid(e):
		return
	e.burn_mark = Vector2i(-1, -1)
	if e.has_meta("status_sprite"):
		var s = e.get_meta("status_sprite")
		if s != null and is_instance_valid(s):
			s.queue_free()
		e.remove_meta("status_sprite")
	if e.has_meta("status_marks"):
		e.remove_meta("status_marks")







static func _redraw(e: Enemy, marks: Dictionary) -> void :
	var parts: Array = []
	for kind in ORDER:
		if marks.has(kind):
			parts.append([kind, int(marks[kind][0]), int(marks[kind][1])])
	var s = e.get_meta("status_sprite") if e.has_meta("status_sprite") else null
	if s != null and not is_instance_valid(s):
		s = null
	if parts.is_empty():
		if s != null:
			s.queue_free()
		if e.has_meta("status_sprite"):
			e.remove_meta("status_sprite")
		return
	var tex: = _row(parts)
	if tex == null:
		return
	if s == null:
		s = Sprite3D.new()
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 15
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		s.pixel_size = GameData.PIXEL_SIZE * SCALE * (BOSS_SCALE if e.is_boss else 1.0)


		s.visible = shows_on(e)
		e.add_child(s)
		e.set_meta("status_sprite", s)
	(s as Sprite3D).modulate.a = 1.0 if notable(e) else COMMON_ALPHA
	s.texture = tex
	var head: float = (e.visual.height() if e.visual != null else 1.2) + 0.4


	var cam: = e.get_viewport().get_camera_3d() if e.is_inside_tree() else null
	if cam != null:
		var fwd: = - cam.global_basis.z
		head *= Vector2(fwd.x, fwd.z).length()
	s.position = Vector3.ZERO
	s.offset = Vector2(0.0, head / s.pixel_size)



static func _row(parts: Array) -> Texture2D:
	var key: = ""
	for pt in parts:
		key += "%s:%d:%d|" % pt
	if _rows.has(key):
		return _rows[key]
	var imgs: Array = []
	var w: = 0
	var h: = 0
	for pt in parts:
		var img: = _image(str(pt[0]), int(pt[1]), int(pt[2]))
		if img == null:
			continue
		imgs.append(img)
		w += img.get_width()
		h = maxi(h, img.get_height())
	if imgs.is_empty():
		return null
	w += GAP * (imgs.size() - 1)
	var row: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var x: = 0
	for img in imgs:

		row.blend_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(x, 0))
		x += img.get_width() + GAP
	row.generate_mipmaps()
	var tex: = ImageTexture.create_from_image(row)
	if _rows.size() >= ROWS_MAX:
		_rows.erase(_rows.keys()[0])
	_rows[key] = tex
	return tex



static func _image(kind: String, value: int, most: int) -> Image:
	var key: = "%s:%d:%d" % [kind, value, most]
	if _imgs.has(key):
		return _imgs[key]
	var icon: = _icon(kind)
	if icon == null:
		_imgs[key] = null
		return null
	var img: Image
	match kind:
		"poison":
			var col: = POISON_COLOR.lerp(POISON_FULL, clampf(float(value) / maxf(1.0, most), 0.0, 1.0))
			img = _with_plate(icon, _digits(str(value), col), col)
		"bleed":
			img = _with_plate(icon, _drops(value, most), GameData.BLEED_COLOR)
		"judgment":
			img = _with_plate(icon, _digits(str(value), GameData.JUDGMENT_COLOR), GameData.JUDGMENT_COLOR)
		"prey":

			var pc: = PREY_COLOR.lerp(Color(1.0, 0.85, 0.3), clampf(float(value) / maxf(1.0, most), 0.0, 1.0))
			img = _with_plate(icon, _digits(str(value), pc), pc)
		"stagger":

			img = _with_bar(icon, float(value) / maxf(1.0, most), Color(1.0, 0.85, 0.35))
		"burn" when most <= 0:

			img = _with_plate(icon, _digits(str(value), GameData.BURN_COLOR), GameData.BURN_COLOR)
		_:
			img = _with_bar(icon, float(value) / maxf(1.0, most), GameData.BURN_COLOR)
	_imgs[key] = img
	return img



static func _icon(kind: String) -> Image:
	if _icons.has(kind):
		return _icons[kind]
	var path: = "res://assets/ro/ui/skin/status_icons/%s.png" % kind
	if SKILL_ICON.has(kind):
		path = "res://assets/ro/ui/skin/skill_icons/%s.png" % SKILL_ICON[kind]
	var img: Image = null
	if ResourceLoader.exists(path):
		img = RoAssets.image_of(path)
		img.convert(Image.FORMAT_RGBA8)
		img.resize(ICON, ICON, Image.INTERPOLATE_BILINEAR)
	_icons[kind] = img
	return img



static func _with_plate(icon: Image, body: Image, col: Color) -> Image:
	var bw: = body.get_width() if body != null else 0
	var w: = ICON + 4 + bw + 5
	var img: = Image.create(w, ICON, false, Image.FORMAT_RGBA8)
	_plate(img, Rect2i(ICON / 2, 4, w - ICON / 2, ICON - 8), col)
	if body != null:
		img.blend_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), Vector2i(ICON + 3, (ICON - body.get_height()) / 2))
	_put_icon(img, icon)
	return img



static func _with_bar(icon: Image, left: float, col: Color) -> Image:
	var img: = Image.create(ICON, ICON + 6, false, Image.FORMAT_RGBA8)
	_put_icon(img, icon)
	var bar: = Rect2i(1, ICON + 1, ICON - 2, 5)
	_plate(img, bar, col)
	var lit: = roundi((bar.size.x - 2) * clampf(left, 0.0, 1.0))
	for x in lit:
		for y in range(1, bar.size.y - 1):
			img.set_pixel(bar.position.x + 1 + x, bar.position.y + y, col.lightened(0.25 if y == 1 else 0.0))
	return img




static func _put_icon(img: Image, icon: Image) -> void :
	img.fill_rect(Rect2i(1, 1, ICON - 2, ICON - 2), Color(0.05, 0.04, 0.07, 0.92))
	img.blend_rect(icon, Rect2i(0, 0, ICON, ICON), Vector2i.ZERO)



static func _plate(img: Image, r: Rect2i, col: Color) -> void :
	var edge: = Color(col.darkened(0.15), 0.95)
	for x in r.size.x:
		for y in r.size.y:
			var corner: = (x == 0 or x == r.size.x - 1) and (y == 0 or y == r.size.y - 1)
			if corner:
				continue
			var border: = x == 0 or y == 0 or x == r.size.x - 1 or y == r.size.y - 1
			img.set_pixel(r.position.x + x, r.position.y + y, edge if border else PLATE)




static func _digits(text: String, col: Color) -> Image:
	var src: = RoAssets.damage_image(text)
	if src == null:
		return null
	var img: Image = src.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	for x in img.get_width():
		for y in img.get_height():
			var c: = img.get_pixel(x, y)
			if c.a > 0.0:
				var k: = minf(1.0, c.get_luminance() * 1.5)
				img.set_pixel(x, y, Color(col.r * k, col.g * k, col.b * k, c.a))
	return img



static func _drops(n: int, most: int) -> Image:
	var dw: int = DROP[0].length()
	var img: = Image.create(most * (dw + 2) - 2, DROP.size(), false, Image.FORMAT_RGBA8)
	var full: = GameData.BLEED_COLOR.lerp(Color(1.0, 0.05, 0.05), clampf(float(n) / maxf(1.0, most), 0.0, 1.0))
	for i in most:
		for y in DROP.size():
			for x in dw:
				if DROP[y][x] != "#":
					continue

				var rim: bool = y == 0 or y == DROP.size() - 1 or x == 0 or x == dw - 1\
				or DROP[y][x - 1] != "#" or DROP[y][x + 1] != "#"\
				or DROP[y - 1][x] != "#" or DROP[y + 1][x] != "#"
				var c: = Color(0.6, 0.22, 0.25, 0.95) if rim else Color(0.12, 0.03, 0.05, 0.6)
				if i < n:

					c = Color(1.0, 0.75, 0.7) if (x == 2 and y == 4) or (x == 1 and y == 5) else full
				img.set_pixel(i * (dw + 2) + x, y, c)
	return img
