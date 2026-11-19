class_name UiKit
extends RefCounted





const FONT_BODY = preload("res://assets/ro/fonts/SCDream4.otf")
const FONT_TITLE = preload("res://assets/ro/fonts/SCDream6.otf")


const GOLD: = Color(0.3, 0.42, 0.78)

const GOLD_DIM: = Color(0.6, 0.67, 0.86)
const TEXT: = Color(0.1, 0.13, 0.24)
const MUTED: = Color(0.36, 0.39, 0.5)
const PANEL: = Color(0.985, 0.985, 0.99, 0.98)
const PANEL_SOFT: = Color(0.93, 0.945, 0.975, 0.98)
const HP: = Color(0.9, 0.24, 0.3)
const HP_LOW: = Color(1.0, 0.5, 0.2)
const XP: = Color(0.32, 0.62, 1.0)
const SHIELD: = Color(0.55, 0.8, 1.0)
const BOSS: = Color(0.75, 0.16, 0.22)
const GOOD: = Color(0.5, 0.95, 0.55)

static func panel_box(bg: = PANEL, border: = GOLD_DIM, radius: = 10, border_w: = 1) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.shadow_color = Color(0, 0, 0, 0.3)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 4)
	s.set_content_margin_all(14)
	s.anti_aliasing = true
	return s



static func bar_box(color: Color, radius: = 4) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = color.lightened(0.35)
	s.border_width_top = 2
	s.set_corner_radius_all(radius)
	return s


static func bar_bg(radius: = 4) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = Color(0.02, 0.02, 0.04, 0.75)
	s.border_color = Color(1, 1, 1, 0.08)
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	return s






const WARM_TEXT: = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ abcdefghijklmnñopqrstuvwxyz 0123456789 áéíóúüÁÉÍÓÚ ¡!¿?·→+-%/():.,★✓▶◀ªº"


static func warm_up(parent: Node) -> void :
	var box: = Control.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.modulate.a = 0.02
	box.z_index = -100
	parent.add_child(box)
	var tree: = parent.get_tree()
	var y: = 0.0
	var n: = 0
	for font in [FONT_BODY, FONT_TITLE]:
		for size in range(9, 23):
			for outlined in [false, true]:
				if outlined and size % 2 == 1:
					continue
				var l: = label(WARM_TEXT, size, Color.WHITE if outlined else TEXT, font == FONT_TITLE)
				l.position = Vector2(0, y)
				box.add_child(l)
				y = fmod(y + 6.0, 300.0)

				n += 1
				if n % 3 == 0:
					await tree.process_frame
					if not is_instance_valid(box):
						return

	var p: = PanelContainer.new()
	var sb: = panel_box(PANEL, SOFT_RIM, 10)
	sb.shadow_color = Color(0, 0, 0, 0.2)
	sb.shadow_size = 4
	p.add_theme_stylebox_override("panel", sb)
	p.custom_minimum_size = Vector2(40, 40)
	box.add_child(p)
	for c in GameData.CHOICE_RARITY:
		box.add_child(glow(Color(c.color, 0.55), 32))
	box.add_child(rays(Color.WHITE, 32))
	for i in 3:
		await tree.process_frame
	if is_instance_valid(box):
		box.queue_free()


static func label(text: String, size: = 15, color: = TEXT, title: = false) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", FONT_TITLE if title else FONT_BODY)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)

	if color.get_luminance() > 0.6:
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		l.add_theme_constant_override("outline_size", 4 if size >= 18 else 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func bar(color: Color, height: = 14.0) -> ProgressBar:
	var b: = ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size.y = height
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_stylebox_override("background", bar_bg())
	b.add_theme_stylebox_override("fill", bar_box(color))
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b






static func copy(text: String) -> void :
	if not OS.has_feature("web"):
		DisplayServer.clipboard_set(text)
		return
	JavaScriptBridge.eval("""(function(t) {
		var keys = ['pointerup', 'touchend', 'keydown'], done = false;
		function off() { keys.forEach(function(k) { window.removeEventListener(k, again, true); }); }
		function area() {
			var back = document.activeElement, a = document.createElement('textarea'), ok = false;
			a.value = t; a.setAttribute('readonly', ''); a.style.position = 'fixed'; a.style.opacity = '0';
			document.body.appendChild(a); a.select(); a.setSelectionRange(0, t.length);
			try { ok = document.execCommand('copy'); } catch (e) {}
			document.body.removeChild(a);
			if (back && back.focus) back.focus();
			return ok;
		}
		function again() {
			if (done) return;
			done = true; off();
			if (!area() && navigator.clipboard) navigator.clipboard.writeText(t).catch(function() {});
		}
		keys.forEach(function(k) { window.addEventListener(k, again, true); });
		if (navigator.clipboard && navigator.clipboard.writeText)
			navigator.clipboard.writeText(t).then(function() { done = true; off(); }).catch(function() {});
	})(%s)""" %JSON.stringify(text), true)










static func tr_later(msgid: String) -> String:
	return msgid


static func fit_dots(l: Label, text: Variant = null) -> void :
	l.set_meta("full", str(text) if text != null else l.text)
	l.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING

	if l.autowrap_mode == TextServer.AUTOWRAP_OFF:
		l.clip_text = true
	if not l.has_meta("dots"):
		l.set_meta("dots", true)
		l.resized.connect(_refit_dots.bind(l))
	_refit_dots(l)


static func _refit_dots(l: Label) -> void :
	var full: = str(l.get_meta("full", l.text))
	var font: = l.get_theme_font("font")
	var fs: = l.get_theme_font_size("font_size")
	var w: = l.size.x
	var lines: = l.max_lines_visible if l.autowrap_mode != TextServer.AUTOWRAP_OFF and l.max_lines_visible > 0 else 1
	var fits: = func(t: String) -> bool:
		if lines == 1:
			return font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= w
		var room: = font.get_multiline_string_size("\n".repeat(lines - 1) + "A", HORIZONTAL_ALIGNMENT_LEFT, w, fs).y
		return font.get_multiline_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, w, fs).y <= room + 0.5
	if w <= 1.0 or fits.call(full):
		l.text = full
		return

	var lo: = 0
	var hi: = full.length()
	while lo < hi:
		var mid: = (lo + hi + 1) / 2
		if fits.call(full.left(mid).strip_edges() + "..."):
			lo = mid
		else:
			hi = mid - 1
	l.text = full.left(lo).strip_edges() + "..."


static func labeled_bar(color: Color, height: = 18.0) -> Dictionary:
	var b: = bar(color, height)
	var l: = label("", 12)
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	b.add_child(l)
	return {"bar": b, "label": l}


static func button(text: String, primary: = false) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_ALL
	b.custom_minimum_size = Vector2(0, 38)
	b.add_theme_font_override("font", FONT_TITLE if primary else FONT_BODY)
	b.add_theme_font_size_override("font_size", 15)

	var normal: = StyleBoxFlat.new()
	normal.bg_color = Color(0.92, 0.94, 1.0) if primary else Color(0.985, 0.99, 1.0)
	normal.border_color = GOLD if primary else Color(0.7, 0.76, 0.9)
	normal.set_border_width_all(2 if primary else 1)
	normal.set_corner_radius_all(9)
	normal.border_width_bottom = 3
	normal.set_content_margin_all(8)
	normal.shadow_color = Color(0.03, 0.06, 0.18, 0.12)
	normal.shadow_size = 2
	normal.shadow_offset = Vector2(0, 1)
	var hover: = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(1, 1, 1)
	hover.border_color = GOLD
	hover.shadow_color = Color(GOLD, 0.3)
	hover.shadow_size = 5
	var pressed: = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.84, 0.87, 0.94)
	pressed.border_width_bottom = 1
	var focus: = normal.duplicate() as StyleBoxFlat
	focus.draw_center = false
	focus.border_color = GOLD
	focus.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)


	var hover_on: = pressed.duplicate() as StyleBoxFlat
	hover_on.border_color = GOLD
	b.add_theme_stylebox_override("hover_pressed", hover_on)
	b.add_theme_stylebox_override("focus", focus)


	var off: = normal.duplicate() as StyleBoxFlat
	off.bg_color = Color(0.93, 0.94, 0.97)
	off.border_color = Color(0.8, 0.83, 0.9)
	off.set_border_width_all(1)
	off.border_width_bottom = 2
	off.shadow_size = 0
	b.add_theme_stylebox_override("disabled", off)
	b.add_theme_color_override("font_disabled_color", Color(TEXT, 0.35))
	for c in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		b.add_theme_color_override(c, TEXT)
	b.focus_entered.connect( func():
		if b.disabled:
			b.release_focus())

	b.draw.connect( func():
		if b.disabled and b.has_focus():
			b.release_focus.call_deferred())
	return b




const SOFT_TITLE: = Color(0.8, 0.86, 0.97, 0.98)
const SOFT_RIM: = Color(0.7, 0.76, 0.9)
const SOFT_INK: = Color(0.12, 0.18, 0.4)


static func soft_title(text: String, size: = 16) -> PanelContainer:
	var bar: = PanelContainer.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s: = StyleBoxFlat.new()
	s.bg_color = SOFT_TITLE
	s.border_color = SOFT_RIM
	s.set_border_width_all(1)
	s.border_width_bottom = 0
	s.corner_radius_top_left = 10
	s.corner_radius_top_right = 10
	s.content_margin_left = 14
	s.content_margin_right = 12
	s.content_margin_top = 5
	s.content_margin_bottom = 6
	s.shadow_color = Color(0.03, 0.06, 0.18, 0.3)
	s.shadow_size = 8
	s.shadow_offset = Vector2(0, 4)
	s.anti_aliasing = true
	bar.add_theme_stylebox_override("panel", s)
	bar.add_child(label(text, size, SOFT_INK, true))
	return bar



static func soft_body(margin: = 18) -> StyleBoxFlat:
	var box: = panel_box(PANEL, SOFT_RIM, 10)
	box.corner_radius_top_left = 0
	box.corner_radius_top_right = 0
	box.set_content_margin_all(margin)
	box.shadow_color = Color(0.03, 0.06, 0.18, 0.3)
	box.shadow_size = 8
	box.shadow_offset = Vector2(0, 4)
	box.anti_aliasing = true
	return box



static func title_strip(text: String, size: = 16) -> PanelContainer:

	return soft_title(text, size)


static func _client_title_strip(text: String, size: = 16) -> PanelContainer:
	var bar: = PanelContainer.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var path: = "res://assets/ro/ui/skin/theme/titlebar.png"
	if ResourceLoader.exists(path):
		var st: = StyleBoxTexture.new()
		st.texture = load(path)
		st.texture_margin_left = 4
		st.texture_margin_right = 4
		st.content_margin_left = 12
		st.content_margin_right = 12
		st.content_margin_top = 4
		st.content_margin_bottom = 5
		bar.add_theme_stylebox_override("panel", st)
	var l: = label(text, size, Color.BLACK, true)
	bar.add_child(l)
	return bar





static func tag(text: String, color: Color, size: = 11) -> PanelContainer:
	var p: = PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s: = StyleBoxFlat.new()
	s.bg_color = Color(0.99, 0.96, 0.87) if color.a > 0.0 else Color(0, 0, 0, 0)
	s.border_color = color.darkened(0.15)
	s.set_border_width_all(1)
	s.set_corner_radius_all(2)
	s.content_margin_left = 7
	s.content_margin_right = 7
	s.content_margin_top = 1
	s.content_margin_bottom = 2
	p.add_theme_stylebox_override("panel", s)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(row)
	var l: = label(text, size, color.darkened(0.45), true)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(l)
	return p





static func element_tag(element: String, arrows: = false, size: = 11) -> PanelContainer:
	var text: = TranslationServer.translate(str(GameData.ELEMENT_NAMES.get(element, "Neutral")))
	if arrows:
		text = TranslationServer.translate("%s · flecha") % text
	var c: Color = GameData.ELEMENT_COLORS.get(element, GameData.ELEMENT_COLORS.neutral)
	var t: = tag(text, c.darkened(0.12), size)

	var sb: = (t.get_theme_stylebox("panel") as StyleBoxFlat).duplicate() as StyleBoxFlat
	sb.bg_color = c.lightened(0.45)
	sb.border_color = c.darkened(0.35)
	t.add_theme_stylebox_override("panel", sb)
	tag_label(t).add_theme_color_override("font_color", c.darkened(0.65))
	return t


static func tag_label(tag_box: PanelContainer) -> Label:
	var row: = tag_box.get_child(0)
	return row.get_child(row.get_child_count() - 1) as Label


static func tag_color(tag_box: PanelContainer, color: Color) -> void :
	var s: = (tag_box.get_theme_stylebox("panel") as StyleBoxFlat).duplicate() as StyleBoxFlat
	s.border_color = color.darkened(0.15)
	tag_box.add_theme_stylebox_override("panel", s)
	tag_label(tag_box).add_theme_color_override("font_color", color.darkened(0.45))



static var _icons: = {}
static func skill_icon(skill_id: String) -> Texture2D:
	if _icons.has(skill_id):
		return _icons[skill_id]

	var key: = skill_id.trim_suffix("_x") if skill_id.ends_with("_x") else skill_id
	var path: = "res://assets/ro/ui/skin/skill_icons/%s.png" % key
	var tex: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
	_icons[skill_id] = tex
	return tex


static func icon_rect(tex: Texture2D, size: float) -> TextureRect:
	var r: = TextureRect.new()
	r.texture = tex
	r.custom_minimum_size = Vector2(size, size)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = RoAssets.ui_filter()
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r





static var _glows: = {}


static func glow(color: Color, size: float) -> TextureRect:
	var key: = color.to_html()
	var t: GradientTexture2D = _glows.get(key)
	if t == null:
		var g: = Gradient.new()
		g.set_color(0, color)
		g.set_color(1, Color(color, 0.0))
		t = GradientTexture2D.new()
		t.gradient = g
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(0.5, 0.0)
		t.width = 128
		t.height = 128
		_glows[key] = t
	var r: = TextureRect.new()
	r.texture = t
	r.custom_minimum_size = Vector2(size, size)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


static var _shine_shader: Shader



static func eternal_shine(art: Control) -> ColorRect:
	if _shine_shader == null:
		_shine_shader = Shader.new()
		_shine_shader.code = "shader_type canvas_item;\r\nrender_mode blend_add;\r\nuniform float phase = 0.0;\r\nvoid fragment() {\r\n\tvec2 d = abs(UV - 0.5) * 2.0;\r\n\tfloat edge = max(smoothstep(0.84, 1.0, d.x), smoothstep(0.88, 1.0, d.y));\r\n\tfloat sweep = fract(TIME * 0.28 + phase) * 3.0 - 1.0;\r\n\tfloat line = abs((UV.x + UV.y * 0.55) * 0.9 - sweep);\r\n\tfloat glint = smoothstep(0.09, 0.0, line);\r\n\tfloat breathe = 0.75 + 0.25 * sin(TIME * 2.2 + phase * 6.28);\r\n\tCOLOR = vec4(1.0, 0.8, 0.38, 1.0) * (edge * 0.6 * breathe + glint * 0.5);\r\n}"











	var r: = ColorRect.new()
	var mat: = ShaderMaterial.new()
	mat.shader = _shine_shader
	mat.set_shader_parameter("phase", randf())
	r.material = mat
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.add_child(r)
	return r


static var _rays_tex: Texture2D



static func rays(color: Color, size: float) -> TextureRect:
	if _rays_tex == null:
		var n: = 160
		var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
		var c: = n * 0.5
		for y in n:
			for x in n:
				var d: = Vector2(x + 0.5 - c, y + 0.5 - c)
				var r: = d.length() / c
				if r >= 1.0:
					continue
				var spoke: = pow(maxf(0.0, cos(d.angle() * 6.0)), 5.0)
				var v: = spoke * (1.0 - r) * 1.1 + pow(1.0 - r, 3.0) * 0.5
				img.set_pixel(x, y, Color(1, 1, 1, clampf(v, 0.0, 1.0)))
		_rays_tex = ImageTexture.create_from_image(img)
	var t: = TextureRect.new()
	t.texture = _rays_tex
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.custom_minimum_size = Vector2(size, size)
	t.size = Vector2(size, size)
	t.pivot_offset = Vector2(size, size) * 0.5
	t.modulate = color
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t



static func backdrop(alpha: = 0.62) -> TextureRect:
	var g: = Gradient.new()
	g.set_color(0, Color(0.02, 0.03, 0.06, alpha * 0.55))
	g.set_color(1, Color(0.0, 0.0, 0.02, alpha))
	var t: = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.45)
	t.fill_to = Vector2(1.1, 1.1)
	var r: = TextureRect.new()
	r.texture = t
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	return r



static func pips(level: int, max_level: int, color: = GOLD) -> HBoxContainer:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in max_level:
		var pip: = PanelContainer.new()
		var s: = StyleBoxFlat.new()
		s.bg_color = color if i < level else Color(0.1, 0.15, 0.35, 0.12)
		s.set_corner_radius_all(3)
		pip.add_theme_stylebox_override("panel", s)
		pip.custom_minimum_size = Vector2(14, 6)
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(pip)
	return row


static func time_text(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds / 60.0), int(seconds) % 60]
