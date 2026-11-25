class_name HeroDanger
extends Control





const BAR_W: = 44.0
const BAR_H: = 5.0

const LOW_HP: = 0.3
const HIT_FADE: = 2.2
const NAME_FONT = preload("res://assets/ro/fonts/SCDream4.otf")

const FORGE_H: = 3.0

var world: World
var _hit: = 0.0
var _strength: = -1.0
var _vignette: ColorRect


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette = ColorRect.new()
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat: = ShaderMaterial.new()
	var sh: = Shader.new()
	sh.code = "shader_type canvas_item;\r\nuniform float strength = 0.0;\r\nvoid fragment() {\r\n\tvec2 d = (UV - 0.5) * vec2(1.0, 0.8);\r\n\tfloat edge = smoothstep(0.28, 0.62, length(d));\r\n\tCOLOR = vec4(0.75, 0.0, 0.02, edge * strength);\r\n}"






	mat.shader = sh
	_vignette.material = mat
	add_child(_vignette)




func hurt(ratio: float) -> void :
	_hit = clampf(maxf(_hit, 0.25 + ratio * 3.0), 0.0, 0.85)


func _process(delta: float) -> void :
	_hit = maxf(0.0, _hit - delta * HIT_FADE)



	var calm: = bool(Save.setting("no_flash", false))
	if calm:
		_hit = 0.0
	var p: Player = world.player if world != null else null
	var low: = 0.0
	if p != null and world.running and p.max_hp > 0.0:
		var r: = p.hp / p.max_hp
		if r < LOW_HP and p.hp > 0.0:
			var beat: = 0.5 if calm else 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.008)
			low = lerpf(0.25, 0.55, beat) * (1.0 - r / LOW_HP * 0.5)

	var strength: = maxf(_hit, low)
	_vignette.visible = strength > 0.001
	if _vignette.visible and strength != _strength:
		(_vignette.material as ShaderMaterial).set_shader_parameter("strength", strength)
	_strength = strength
	queue_redraw()


func _draw() -> void :
	if world == null or not world.running or world.camera == null:
		return


	for h in world.heroes:
		if h != world.player and is_instance_valid(h):
			_draw_member(h)
		if is_instance_valid(h) and h.downed:
			_draw_revive(h)
	var p: Player = world.player
	if p == null or p.hp <= 0.0:
		return
	var at: = world.camera.unproject_position(p.position + RoVisual.world_lift() - Vector3(0, 0.5, 0))
	var k: = maxf(1.0, floorf(get_viewport_rect().size.y / 700.0))
	var show_bar: = bool(Save.setting("hero_hp_bar", true))
	if p.forge_on():
		_draw_forge(p, at, k, show_bar)
	if bool(Save.setting("hero_name", true)):
		var below: = (BAR_H + 4.0 + (BAR_H * 0.7 + 1.0 if p.shield > 0.0 else 0.0)) * k if show_bar else 0.0
		if p.forge_on():
			below += FORGE_H * k + k

		if Uniques.cannon(p) != "":
			below += (GameData.U_OV_GAUGE_H + 2.0) * k

		var gold: = (p.profile.get("looks", []) as Array).has("valhalla")
		var own: = Save.char_name(p.class_id)

		if NameFilter.dev_name(own):
			_draw_name(own + " · Dev", at + Vector2(0, below), k, NameFilter.DEV_COLOR)
		else:
			_draw_name(own, at + Vector2(0, below), k, GameData.REBIRTH_LV_GOLD if gold else Color(1, 0.95, 0.7))
	if not show_bar:
		return
	var w: = BAR_W * k
	var h: = BAR_H * k
	var r: = clampf(p.hp / maxf(1.0, p.max_hp), 0.0, 1.0)
	var col: = Color(0.25, 0.85, 0.3)
	if r < 0.25:
		col = Color(0.95, 0.15, 0.15) if int(Time.get_ticks_msec() / 180) % 2 == 0 else Color(1.0, 0.5, 0.4)
	elif r < 0.5:
		col = Color(0.95, 0.8, 0.2)
	var pos: = (at - Vector2(w * 0.5, 0)).floor()
	draw_rect(Rect2(pos - Vector2(k, k), Vector2(w + 2 * k, h + 2 * k)), Color(0.05, 0.05, 0.1, 0.85))
	draw_rect(Rect2(pos, Vector2(w, h)), Color(0.25, 0.1, 0.1, 0.9))
	draw_rect(Rect2(pos, Vector2(w * r, h)), col)

	if p.shield > 0.0:
		var s: = clampf(p.shield / maxf(1.0, p.shield_peak), 0.0, 1.0)
		var sp: = pos + Vector2(0, h + k)
		draw_rect(Rect2(sp - Vector2(k, 0), Vector2(w + 2 * k, h * 0.7 + k)), Color(0.05, 0.05, 0.1, 0.85))
		draw_rect(Rect2(sp, Vector2(w * s, h * 0.7)), Color(0.35, 0.6, 1.0))





func _draw_forge(p: Player, at: Vector2, k: float, show_bar: bool) -> void :
	var w: = BAR_W * k
	var pos: = (at - Vector2(w * 0.5, 0)).floor()
	var y: = pos.y
	if show_bar:
		y += BAR_H * k + k + (BAR_H * 0.7 * k + k if p.shield > 0.0 else 0.0)
	var lv: = p.forge_refine()
	var over: = lv - p.forge_safe()
	var col: = world.forge_color(p, lv)
	var heat: = clampf(p.forge_heat, 0.0, 1.0)
	var fill: = Color(1.0, 0.5, 0.12).lerp(Color(1.0, 0.95, 0.55), heat)
	if over > 0 and int(Time.get_ticks_msec() / 110) % 2 == 0:
		fill = fill.lerp(Color(1.0, 0.2, 0.1), 0.45)
	draw_rect(Rect2(Vector2(pos.x - k, y), Vector2(w + 2 * k, FORGE_H * k + k)), Color(0.05, 0.05, 0.1, 0.85))
	draw_rect(Rect2(Vector2(pos.x, y), Vector2(w, FORGE_H * k)), Color(0.2, 0.1, 0.05, 0.9))
	draw_rect(Rect2(Vector2(pos.x, y), Vector2(w * heat, FORGE_H * k)), fill)

	var size: = int(15 * k)
	var text: = "+%d" % lv
	var tw: = NAME_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var tp: = Vector2(pos.x - 4 * k - tw, y + FORGE_H * k * 0.5 + NAME_FONT.get_ascent(size) * 0.38).floor()
	if not show_bar:
		tp.y = y + NAME_FONT.get_ascent(size) * 0.5
	draw_string_outline(NAME_FONT, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, int(3 * k), Color(0, 0, 0, 0.9))
	draw_string(NAME_FONT, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

	if over >= 0 and lv < p.forge_max():

		var risk: = TranslationServer.translate("rompe %d%%") % roundi(p.forge_break_chance(lv + 1) * 100.0)
		var rs: = int(10 * k)
		var rp: = Vector2(pos.x + w + 4 * k, tp.y).floor()
		draw_string_outline(NAME_FONT, rp, risk, HORIZONTAL_ALIGNMENT_LEFT, -1, rs, int(3 * k), Color(0, 0, 0, 0.9))
		draw_string(NAME_FONT, rp, risk, HORIZONTAL_ALIGNMENT_LEFT, -1, rs, Color(1.0, 0.45, 0.35) if over > 0 else Color(1.0, 0.8, 0.5))




func _draw_member(h: Player) -> void :
	if world.camera.is_position_behind(h.position):
		return
	var k: = maxf(1.0, floorf(get_viewport_rect().size.y / 700.0))
	var at: = world.camera.unproject_position(h.position + RoVisual.world_lift() - Vector3(0, 0.5, 0))
	var w: = BAR_W * k
	var hgt: = BAR_H * k
	var pos: = (at - Vector2(w * 0.5, 0)).floor()
	var r: = clampf(h.hp / maxf(1.0, h.max_hp), 0.0, 1.0)
	draw_rect(Rect2(pos - Vector2(k, k), Vector2(w + 2 * k, hgt + 2 * k)), Color(0.05, 0.05, 0.1, 0.85))
	draw_rect(Rect2(pos, Vector2(w, hgt)), Color(0.25, 0.1, 0.1, 0.9))
	draw_rect(Rect2(pos, Vector2(w * r, hgt)), Color(0.45, 0.6, 0.65) if h.downed else Color(0.3, 0.8, 1.0))

	var shown: = str(h.appearance.get("name", "")).strip_edges()
	var job: = tr(h.job_name())
	if NameFilter.dev_name(shown):
		_draw_name("%s · Dev" % shown, at + Vector2(0, hgt + 4.0 * k), k, NameFilter.DEV_COLOR)
		return
	shown = NameFilter.shown(shown)
	_draw_name(job if shown == "" or shown == job else "%s · %s" % [shown, job], at + Vector2(0, hgt + 4.0 * k), k, 
		Color(0.7, 0.9, 1.0))




func _draw_revive(h: Player) -> void :
	if world.camera.is_position_behind(h.position):
		return
	var k: = maxf(1.0, floorf(get_viewport_rect().size.y / 700.0))
	var at: = world.camera.unproject_position(h.position + RoVisual.world_lift() + Vector3(0, 1.0, 0))
	var r: = 22.0 * k
	var p: = clampf(h.revive_t / GameData.COOP_REVIVE_TIME, 0.0, 1.0)
	draw_circle(at, r + 3 * k, Color(0, 0, 0, 0.45))
	draw_arc(at, r, 0.0, TAU, 40, Color(0.35, 0.35, 0.4, 0.9), 4.0 * k, true)
	if p > 0.0:
		var pulse: = 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.012)
		draw_arc(at, r, - PI / 2.0, - PI / 2.0 + TAU * p, 40, Color(0.45, 1.0, 0.5, pulse), 5.0 * k, true)
	var pct: = "%d%%" % roundi(p * 100.0)
	var size: = int(13 * k)
	var w: = NAME_FONT.get_string_size(pct, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var tp: = (at + Vector2( - w * 0.5, NAME_FONT.get_ascent(size) * 0.5)).floor()
	draw_string_outline(NAME_FONT, tp, pct, HORIZONTAL_ALIGNMENT_LEFT, -1, size, int(3 * k), Color(0, 0, 0, 0.9))
	draw_string(NAME_FONT, tp, pct, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.75, 1.0, 0.75) if p > 0.0 else Color(0.85, 0.85, 0.9))
	var hint: = tr("¡Levantándolo!") if p > 0.0 and h != world.player else (tr("Te están levantando") if p > 0.0
		else (tr("Párate a su lado para levantarlo") if h != world.player else tr("Caído · un aliado te levanta")))
	_draw_name(hint, at + Vector2(0, r + 6 * k), k, Color(0.75, 1.0, 0.75) if p > 0.0 else Color(1.0, 0.7, 0.65), 12)




func _draw_name(text: String, top: Vector2, k: float, color: = Color(1, 0.95, 0.7), base: = 11) -> void :
	var size: = int(base * k)
	var w: = NAME_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var at: = (top + Vector2( - w * 0.5, NAME_FONT.get_ascent(size))).floor()
	draw_string_outline(NAME_FONT, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, int(3 * k), Color(0, 0, 0, 0.85))
	draw_string(NAME_FONT, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
