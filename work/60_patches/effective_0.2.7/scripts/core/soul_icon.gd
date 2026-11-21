extends RefCounted







const SIZE: = 64
static var _cache: = {}



static func texture(unique_id: String) -> Texture2D:
	if _cache.has(unique_id):
		return _cache[unique_id]
	var d: Dictionary = GameData.ITEMS.get("soul_" + unique_id, {})
	if d.is_empty():
		return null
	var img: = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c: = Vector2(SIZE * 0.5, SIZE * 0.5)
	var r: = SIZE * 0.47


	var glow: Color = GameData.UNIQUE_COLOR if GameData.ITEMS.get(unique_id, {}).get("unique", false) else GameData.LEGENDARY_COLOR

	var heart: = Color(0.3, 0.2, 0.48).lerp(glow, 0.22)
	var edge: = Color(0.07, 0.04, 0.15).lerp(glow.darkened(0.7), 0.3)
	for y in SIZE:
		for x in SIZE:
			var k: = Vector2(x + 0.5, y + 0.5).distance_to(c) / r
			if k <= 1.0:
				var col: = heart.lerp(edge, k * k)
				col.a = 0.94
				img.set_pixel(x, y, col)


	var item_path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(GameData.ITEMS.get(unique_id, {}).get("icon", ""))
	var spr: = RoAssets.sprite([str(d.get("mvp", ""))]) if d.has("mvp") else null
	if spr != null or ( not d.has("mvp") and ResourceLoader.exists(item_path)):
		var fr: Image = spr.compose_image(0, 0, 0) if spr != null else (load(item_path) as Texture2D).get_image()
		if fr != null and not fr.is_empty():
			fr.convert(Image.FORMAT_RGBA8)
			var used: = fr.get_used_rect()
			if used.size.x > 0 and used.size.y > 0:
				fr = fr.get_region(used)
				var box: = SIZE * 0.74
				var s: = minf(box / fr.get_width(), box / fr.get_height())
				var w: = maxi(1, roundi(fr.get_width() * s))
				var h: = maxi(1, roundi(fr.get_height() * s))
				fr.resize(w, h, Image.INTERPOLATE_LANCZOS if s < 1.0 else Image.INTERPOLATE_NEAREST)
				var at: = Vector2i(roundi(c.x - w * 0.5), roundi(c.y - h * 0.5 + SIZE * 0.04))
				for y in h:
					for x in w:
						var p: = at + Vector2i(x, y)
						if p.x < 0 or p.y < 0 or p.x >= SIZE or p.y >= SIZE:
							continue
						if Vector2(p.x + 0.5, p.y + 0.5).distance_to(c) / r > 0.97:
							continue
						var src: = fr.get_pixel(x, y)
						if src.a <= 0.0:
							continue
						img.set_pixel(p.x, p.y, img.get_pixel(p.x, p.y).blend(src))

	for y in SIZE:
		for x in SIZE:
			var pos: = Vector2(x + 0.5, y + 0.5)
			var k: = pos.distance_to(c) / r
			if k > 1.0:
				continue
			var px: = img.get_pixel(x, y)
			if k > 0.86:
				var rim: = Color(glow.r, glow.g, glow.b, clampf((k - 0.86) / 0.14, 0.0, 1.0) * 0.85)
				px = px.blend(rim)
			var sheen: = pos.distance_to(c + Vector2( - r * 0.38, - r * 0.42)) / (r * 0.42)
			if sheen < 1.0:
				px = px.blend(Color(1, 1, 1, (1.0 - sheen) * 0.38))
			img.set_pixel(x, y, px)


	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % str(GameData.ITEMS.get(unique_id, {}).get("icon", ""))
	if d.has("mvp") and ResourceLoader.exists(path):
		var badge: Image = (load(path) as Texture2D).get_image()
		if badge != null and not badge.is_empty():
			badge.convert(Image.FORMAT_RGBA8)
			var bs: = roundi(SIZE * 0.36)
			badge.resize(bs, bs, Image.INTERPOLATE_NEAREST)
			var bat: = Vector2i(SIZE - bs, SIZE - bs)
			for y in bs:
				for x in bs:
					var src: = badge.get_pixel(x, y)
					if src.a > 0.0:
						img.set_pixel(bat.x + x, bat.y + y, img.get_pixel(bat.x + x, bat.y + y).blend(src))
	var tex: = ImageTexture.create_from_image(img)
	_cache[unique_id] = tex
	return tex
