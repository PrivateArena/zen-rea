class_name RoBasicWindow
extends Control














signal menu_pressed(button: String)

const ROOT: = "res://assets/ro/ui/skin/basic_interface/"
const BG_SIZE: = Vector2(280, 120)
const GAUGE_X: = 110.0
const GAUGE_W: = 85.0
const HP_Y: = 22.0
const SP_Y: = 43.0
const TEXT: = Color(0.1, 0.13, 0.24)
const TEXT_SOFT: = Color(0.36, 0.39, 0.5)

const TITLE_BG: = Color(0.8, 0.86, 0.97, 0.97)
const TITLE_TEXT: = Color(0.12, 0.18, 0.4)
const BODY_BG: = Color(0.975, 0.98, 1.0, 0.95)
const RIM: = Color(0.7, 0.76, 0.9)
const LINE: = Color(0.84, 0.87, 0.95)
const RADIUS: = 7
const GAUGE_BLUE: = Color(0.33, 0.55, 0.95)
const GAUGE_RED: = Color(0.92, 0.3, 0.38)


const BUTTONS: = ["equip", "option"]
const BUTTON_TEXT: = ["Equipo", "Opciones"]

var display_name: = ""
var job: = ""
var hp: = 0.0
var hp_max: = 1.0
var sp: = 0.0
var sp_max: = 0.0
var base_lv: = 1
var exp_ratio: = 0.0
var job_lv: = 1


var rebirth_lv: = 0
var gold_name: = false
var run_time: = 0.0
var kills: = 0
var zeny: = 0

var lives: = 0

var _font: Font = preload("res://assets/ro/fonts/SCDream4.otf")
var _font_bold: Font = preload("res://assets/ro/fonts/SCDream6.otf")
var _tex: = {}
var _hover: = -1
var _box: = {}


func _ready() -> void :
	custom_minimum_size = BG_SIZE
	size = BG_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	_box.body = _flat(BODY_BG, RIM, RADIUS)
	_box.body.shadow_color = Color(0.05, 0.08, 0.2, 0.22)
	_box.body.shadow_size = 3
	_box.body.shadow_offset = Vector2(0, 3)
	_box.title = _flat(TITLE_BG, Color(0.58, 0.66, 0.86), 0)
	_box.title.corner_radius_top_left = RADIUS
	_box.title.corner_radius_top_right = RADIUS
	_box.title.set_border_width_all(0)
	_box.title.border_width_bottom = 1
	_box.title.expand_margin_left = -1
	_box.title.expand_margin_right = -1
	_box.title.expand_margin_top = -1
	_box.inset = _flat(Color(0.935, 0.95, 0.985), LINE, 6)
	_box.track = UiStyles.hud_track(9.0)
	_box.blue = UiStyles.hud_fill(GAUGE_BLUE, 9.0)
	_box.red = UiStyles.hud_fill(GAUGE_RED, 9.0)
	_box.btn = UiStyles.hud_button_box("normal")
	_box.btn_on = UiStyles.hud_button_box("hover")


const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")


static func _flat(bg: Color, rim: Color, radius: int) -> StyleBoxFlat:
	var b: = StyleBoxFlat.new()
	b.bg_color = bg
	b.border_color = rim
	b.set_border_width_all(1)
	b.set_corner_radius_all(radius)
	b.anti_aliasing = true
	return b


func _load(file: String) -> Texture2D:
	return Lang.ui_tex(ROOT + file + ".png")


func _button_rect(i: int) -> Rect2:


	if MouseWalk.touch():
		return Rect2(Vector2(207, 21 + i * 40), Vector2(68, 36))
	return Rect2(Vector2(209, 23 + i * 24), Vector2(64, 20))


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		var h: = -1
		for i in BUTTONS.size():
			if _button_rect(i).has_point(event.position):
				h = i
		if h != _hover:
			_hover = h
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

		for i in BUTTONS.size():
			if _button_rect(i).has_point(event.position):
				_hover = i
				queue_redraw()
				menu_pressed.emit(BUTTONS[i])
				accept_event()
				return


func _notification(what: int) -> void :
	if what == NOTIFICATION_MOUSE_EXIT and _hover != -1:
		_hover = -1
		queue_redraw()


func _draw() -> void :


	draw_style_box(_box.body, Rect2(Vector2.ZERO, BG_SIZE))
	draw_style_box(_box.title, Rect2(0, 0, BG_SIZE.x, 17))
	_text(Vector2(10, 12), tr("Basic Info"), TITLE_TEXT, 11, true)
	draw_line(Vector2(203, 22), Vector2(203, 98), LINE, 1.0)
	draw_style_box(_box.inset, Rect2(5, 66, 196, 35))
	draw_line(Vector2(6, 103.5), Vector2(BG_SIZE.x - 6, 103.5), LINE, 1.0)


	_text(Vector2(10, 32), display_name, GameData.REBIRTH_LV_GOLD.darkened(0.3) if gold_name else TEXT, 12, true)
	_text(Vector2(10, 47), job, TEXT_SOFT, 11)


	_text(Vector2(GAUGE_X - 18, HP_Y + 8), tr("HP"), TEXT, 11, true)
	_gauge(Vector2(GAUGE_X, HP_Y), hp / maxf(hp_max, 1.0), hp < hp_max * 0.25)
	_text_centered(Vector2(GAUGE_X, HP_Y + 19), GAUGE_W, "%s / %s" % [RoAssets.short_number(roundi(hp)), RoAssets.short_number(roundi(hp_max))], TEXT, 11)
	_text(Vector2(GAUGE_X - 18, SP_Y + 8), tr("SP"), TEXT, 11, true)
	_gauge(Vector2(GAUGE_X, SP_Y), sp / sp_max if sp_max > 0.0 else 0.0, false)
	_text_centered(Vector2(GAUGE_X, SP_Y + 19), GAUGE_W, 

		"%s / %s" % [RoAssets.short_number(roundi(sp)), RoAssets.short_number(roundi(sp_max))] if sp_max > 0.0 else "- / -", TEXT, 11)


	var lv_text: = tr("Base Lv. %d") % base_lv
	_text(Vector2(12, 83), lv_text, TEXT, 11, true)


	var gx: = maxf(GAUGE_X - 30.0, 12.0 + _font_bold.get_string_size(lv_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 5.0)
	_gauge(Vector2(gx, 75), exp_ratio, false, GAUGE_W - 3.0 - (gx - (GAUGE_X - 30.0)))
	_text(Vector2(GAUGE_X + 58, 83), "%.1f%%" % (exp_ratio * 100.0), TEXT_SOFT, 10)
	var job_text: = tr("Job Lv. %d") % job_lv
	_text(Vector2(12, 95), job_text, TEXT, 11, true)
	if rebirth_lv > 0:


		var at: = Vector2(maxf(GAUGE_X - 24, 12.0 + _font_bold.get_string_size(job_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x + 10.0), 91)
		draw_texture(RebirthMarks.star_tex(true, 11), (at - Vector2(5.5, 6.0)).round())
		var rb: = GameData.rebirth_name(rebirth_lv)
		var fs: = 10
		while fs > 7 and at.x + 9.0 + _font_bold.get_string_size(rb, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 199.0:
			fs -= 1
		_text(at + Vector2(9, 4), rb, GameData.REBIRTH_LV_GOLD.darkened(0.35), fs, true)


	_text(Vector2(8, 113), tr("Tiempo : %02d:%02d") % [int(run_time / 60.0), int(run_time) % 60], TEXT, 10)
	_text(Vector2(98, 113), tr("Zeny : %s") % _thousands(zeny), TEXT, 10)
	if lives > 0:
		var lt: = tr("Vidas : %d") % lives
		_text(Vector2(BG_SIZE.x - 8.0 - _font.get_string_size(lt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x, 113), lt, GAUGE_RED.darkened(0.25), 10)


	for i in BUTTONS.size():
		var r: = _button_rect(i)
		draw_style_box(_box.btn_on if i == _hover else _box.btn, r)
		var label: = tr(BUTTON_TEXT[i])
		var fs: = 12 if MouseWalk.touch() else 10
		while fs > 7 and _font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > r.size.x - 6.0:
			fs -= 1
		draw_string(_font_bold, Vector2(r.position.x, r.position.y + r.size.y * 0.5 + 4.0), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, fs, 
			Color(0.2, 0.32, 0.72) if i == _hover else TITLE_TEXT)


static func _thousands(n: int) -> String:
	var s: = str(n)
	var out: = ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out


func _gauge(at: Vector2, ratio: float, red: bool, width: = GAUGE_W) -> void :

	draw_style_box(_box.track, Rect2(at, Vector2(width, 9)))
	ratio = clampf(ratio, 0.0, 1.0)
	var fill_w: = (width - 2.0) * ratio
	if fill_w < 1.0:
		return

	draw_style_box(_box.red if red else _box.blue, Rect2(at + Vector2(1, 1), Vector2(maxf(fill_w, 7.0), 7)))


func _text(at: Vector2, text: String, color: Color, font_size: int, bold: = false) -> void :
	draw_string(_font_bold if bold else _font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _text_centered(at: Vector2, width: float, text: String, color: Color, font_size: int) -> void :
	draw_string(_font, at, text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)
