class_name RebirthMarks
extends RefCounted






const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")

static var _stars: = {}
static var _fills: = {}



static func star_tex(on: bool, px: = 15) -> Texture2D:
	var key: = "%s_%d" % [on, px]
	if _stars.has(key):
		return _stars[key]
	var img: = Image.create(px, px, false, Image.FORMAT_RGBA8)
	var c: = Vector2(px, px) * 0.5 + Vector2(0, 0.5)
	var outer: = RoCharSelect._star_points(c, px * 0.5)
	var inner: = RoCharSelect._star_points(c + Vector2(0, 0.15), px * 0.5 - maxf(1.3, px / 9.0))
	for y in px:
		for x in px:
			var p: = Vector2(x + 0.5, y + 0.5)
			if not Geometry2D.is_point_in_polygon(p, outer):
				continue
			var col: Color
			if not Geometry2D.is_point_in_polygon(p, inner):
				col = Color(0.36, 0.18, 0.03) if on else Color(0.5, 0.53, 0.63)
			elif on:

				col = Color(1.0, 0.95, 0.62).lerp(Color(0.86, 0.5, 0.1), float(y) / px)
			else:
				col = Color(0.86, 0.88, 0.94).lerp(Color(0.74, 0.77, 0.85), float(y) / px)
			img.set_pixel(x, y, col)

	if on:
		var g: = Vector2i(roundi(c.x - px * 0.14), roundi(c.y - px * 0.16))
		img.set_pixelv(g, Color(1, 1, 0.95))
		if px >= 13:
			img.set_pixelv(g + Vector2i(1, 0), Color(1, 0.99, 0.85))
	var tex: = ImageTexture.create_from_image(img)
	_stars[key] = tex
	return tex




static func stars(rlv: int, n: int, px: = 15, scale: = 2) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", scale)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for k in n:
		var r: = TextureRect.new()
		r.texture = star_tex(k < rlv, px)
		r.custom_minimum_size = Vector2(px, px) * scale
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.texture_filter = RoAssets.ui_filter()
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(r)
		if k < rlv:
			var tw: = r.create_tween().set_loops()
			tw.tween_interval(0.25 * k)
			tw.tween_property(r, "modulate", Color(1.35, 1.3, 1.15), 0.3).set_trans(Tween.TRANS_SINE)
			tw.tween_property(r, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_SINE)
			tw.tween_interval(maxf(0.4, 0.25 * (rlv - k)) + 1.2)
	return row



static func _gold_fill(part: String) -> Texture2D:
	if _fills.has(part):
		return _fills[part]
	var src: = load(UiStyles.BASE_ROOT + "gzeblue_%s.png" % part) as Texture2D
	if src == null:
		return null
	var img: = RoAssets.tex_image(src)
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var p: = img.get_pixel(x, y)
			var v: = p.get_luminance()
			var gold: = Color(0.55, 0.3, 0.02).lerp(Color(1.0, 0.82, 0.3), clampf(v * 1.4, 0.0, 1.0))
			gold = gold.lerp(Color(1.0, 0.98, 0.85), clampf((v - 0.75) * 3.0, 0.0, 1.0))
			img.set_pixel(x, y, Color(gold, p.a))
	var tex: = ImageTexture.create_from_image(img)
	_fills[part] = tex
	return tex




static func gauge(height: = 14.0) -> Dictionary:
	var b: = ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0, height)
	b.texture_filter = RoAssets.ui_filter()
	b.add_theme_stylebox_override("background", UiStyles.gauge_box("background"))
	var fill: = _gold_fill("mid")
	if fill != null:
		var st: = StyleBoxTexture.new()
		st.texture = fill
		st.texture_margin_top = 1
		st.texture_margin_bottom = 1
		st.set_content_margin_all(0)
		b.add_theme_stylebox_override("fill", st)
	else:
		b.add_theme_stylebox_override("fill", UiStyles.gauge_box("blue"))
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l: = UiKit.label("", 11, Color(0.22, 0.13, 0.02), true)
	l.add_theme_color_override("font_outline_color", Color(1, 0.98, 0.9, 0.85))
	l.add_theme_constant_override("outline_size", 3)
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_child(l)
	return {"bar": b, "label": l}
