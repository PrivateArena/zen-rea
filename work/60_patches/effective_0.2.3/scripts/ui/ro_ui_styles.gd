extends RefCounted


const UI_ROOT: = "res://assets/ro/ui/skin/"
const THEME_ROOT: = UI_ROOT + "theme/"
const BASE_ROOT: = UI_ROOT + "basic_interface/"





static func window_box(tint: = Color(0.94, 0.95, 0.97, 0.98)) -> StyleBox:
	var s: = StyleBoxFlat.new()
	s.bg_color = Color(HUD_BODY_BG, tint.a)
	s.border_color = HUD_RIM
	s.set_border_width_all(1)
	s.set_corner_radius_all(HUD_RADIUS)
	s.set_content_margin_all(14)
	s.shadow_color = Color(0.05, 0.08, 0.2, 0.22)
	s.shadow_size = 3
	s.shadow_offset = Vector2(0, 3)
	s.anti_aliasing = true
	return s


static func button_box(state: String) -> StyleBox:
	var s: = hud_button_box("normal" if state == "disabled" else state)
	if state == "disabled":
		s.bg_color = Color(0.93, 0.94, 0.97)
		s.border_color = Color(0.82, 0.85, 0.92)
	s.content_margin_left = 8
	s.content_margin_top = 5
	s.content_margin_right = 8
	s.content_margin_bottom = 5
	return s


static func gauge_box(kind: String) -> StyleBox:
	if kind == "background":
		return hud_track(9.0)
	return hud_fill(HUD_RED if kind == "red" else HUD_BLUE, 9.0)


static func apply_button(button: Button) -> void :
	button.add_theme_stylebox_override("normal", button_box("normal"))
	button.add_theme_stylebox_override("hover", button_box("hover"))
	button.add_theme_stylebox_override("pressed", button_box("pressed"))

	button.add_theme_stylebox_override("hover_pressed", button_box("pressed"))
	button.add_theme_stylebox_override("disabled", button_box("disabled"))
	button.add_theme_color_override("font_color", HUD_TITLE_TEXT)
	button.add_theme_color_override("font_hover_color", Color(0.2, 0.32, 0.72))
	button.add_theme_color_override("font_pressed_color", Color(0.2, 0.32, 0.72))
	button.add_theme_color_override("font_hover_pressed_color", Color(0.2, 0.32, 0.72))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.57, 0.64))
	button.add_theme_font_size_override("font_size", 16)
	button.focus_mode = Control.FOCUS_ALL




static func ro_window(title: String, font: Font) -> Dictionary:
	return hud_window(title, font)






const HUD_TITLE_BG: = Color(0.8, 0.86, 0.97, 0.97)
const HUD_TITLE_LINE: = Color(0.58, 0.66, 0.86)
const HUD_TITLE_TEXT: = Color(0.12, 0.18, 0.4)
const HUD_BODY_BG: = Color(0.975, 0.98, 1.0, 0.95)
const HUD_RIM: = Color(0.7, 0.76, 0.9)
const HUD_RADIUS: = 7


static func hud_window(title: String, font: Font) -> Dictionary:
	var root: = VBoxContainer.new()
	root.add_theme_constant_override("separation", 0)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar: = PanelContainer.new()
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bs: = StyleBoxFlat.new()
	bs.bg_color = HUD_TITLE_BG
	bs.border_color = HUD_RIM
	bs.set_border_width_all(1)
	bs.border_width_bottom = 0
	bs.corner_radius_top_left = HUD_RADIUS
	bs.corner_radius_top_right = HUD_RADIUS
	bs.content_margin_left = 8
	bs.content_margin_right = 8
	bs.content_margin_top = 1
	bs.content_margin_bottom = 2
	bs.shadow_color = Color(0.05, 0.08, 0.2, 0.22)
	bs.shadow_size = 3
	bs.shadow_offset = Vector2(0, 3)
	bs.anti_aliasing = true
	bar.add_theme_stylebox_override("panel", bs)
	root.add_child(bar)
	var label: = Label.new()
	label.text = title
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", HUD_TITLE_TEXT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(label)
	var body_panel: = PanelContainer.new()
	body_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame: = StyleBoxFlat.new()
	frame.bg_color = HUD_BODY_BG
	frame.border_color = HUD_RIM
	frame.set_border_width_all(1)
	frame.corner_radius_bottom_left = HUD_RADIUS
	frame.corner_radius_bottom_right = HUD_RADIUS
	if title == "":
		frame.corner_radius_top_left = HUD_RADIUS
		frame.corner_radius_top_right = HUD_RADIUS

	frame.border_color = HUD_RIM
	frame.content_margin_left = 6
	frame.content_margin_right = 6
	frame.content_margin_top = 5
	frame.content_margin_bottom = 5
	frame.shadow_color = Color(0.05, 0.08, 0.2, 0.22)
	frame.shadow_size = 3
	frame.shadow_offset = Vector2(0, 3)
	frame.anti_aliasing = true
	body_panel.add_theme_stylebox_override("panel", frame)
	root.add_child(body_panel)
	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body_panel.add_child(body)
	return {"root": root, "body": body, "title": label}




const HUD_BLUE: = Color(0.33, 0.55, 0.95)
const HUD_RED: = Color(0.92, 0.3, 0.38)


static func hud_gauge(kind: String, width: float, height: = 9.0) -> ProgressBar:
	var b: = ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(width, height)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_theme_stylebox_override("background", hud_track(height))
	b.add_theme_stylebox_override("fill", hud_fill(HUD_RED if kind == "red" else HUD_BLUE, height))
	return b


static func hud_track(height: float) -> StyleBoxFlat:
	var back: = StyleBoxFlat.new()
	back.bg_color = Color(0.87, 0.9, 0.96)
	back.border_color = Color(0.66, 0.72, 0.87)
	back.set_border_width_all(1)
	back.set_corner_radius_all(int(ceilf(height * 0.5)))
	back.anti_aliasing = true
	return back


static func hud_fill(col: Color, height: float) -> StyleBoxFlat:
	var fill: = StyleBoxFlat.new()
	fill.bg_color = col
	fill.border_color = col.lightened(0.4)
	fill.border_width_top = 2 if height >= 8.0 else 1
	fill.set_corner_radius_all(int(ceilf(height * 0.5)))
	fill.anti_aliasing = true
	return fill



static func hud_button_box(state: String) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = Color(0.86, 0.9, 0.99) if state == "hover" else (Color(0.78, 0.84, 0.97) if state == "pressed" else Color.WHITE)
	s.border_color = Color(0.3, 0.42, 0.78) if state != "normal" else HUD_RIM
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 2
	s.content_margin_bottom = 3
	s.anti_aliasing = true
	return s




static func round_gauge(kind: String, width: float, height: float) -> ProgressBar:
	var col: = Color(0.93, 0.42, 0.55) if kind == "red" else Color(0.36, 0.58, 0.95)
	var b: = ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(width, height)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back: = StyleBoxFlat.new()
	back.bg_color = Color(0.87, 0.89, 0.95)
	back.border_color = Color(0.62, 0.68, 0.84)
	back.set_border_width_all(1)
	back.set_corner_radius_all(int(height * 0.5))
	var fill: = StyleBoxFlat.new()
	fill.bg_color = col
	fill.border_color = col.lightened(0.45)
	fill.border_width_top = 2
	fill.border_width_bottom = 1
	fill.set_corner_radius_all(int(height * 0.5))
	b.add_theme_stylebox_override("background", back)
	b.add_theme_stylebox_override("fill", fill)
	return b



static func ro_gauge(kind: String, width: float) -> ProgressBar:
	return hud_gauge(kind, width)
