extends Control














const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const RO_FONT = preload("res://assets/ro/fonts/SCDream4.otf")
const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const ROWS: = 7
const BAR_W: = 190.0
const ICON: = 18.0

const HINTS: = 2

const COUNT_FROM: = 3.0

const HOLD_MAX: = 12.0


const MECH_ICONS: = {
	"rain": "meteor_storm", "cone": "sightrasher", "charge": "charge_attack", "los": "cloaking", 
	"summon": "scream", "cleanse": "sanctuary", "wall": "fire_wall", "slam": "hammer_fall", 
	"brand": "lex_aeterna", "volley": "arrow_shower", "towers": "ruwach", "starfall": "warmth_stars", 
	"snap": "frost_diver", "shield": "kyrie_eleison", "vortex": "gravitation_field", "polar": "storm_gust", 
	"orb": "soul_strike", "mark": "signum_crucis", "tether": "soul_link", "still": "stone_curse", 
	"ice": "freezing_spear", "eggs": "bio_cannibalize", "doom": "assassin_cross_sunset", "sweep": "bowling_bash", 
	"runes": "magnus_exorcismus", "platforms": "leap", "guard": "auto_guard", "break": "pressure", 
	"bombs": "demonstration", "seal": "spell_breaker", "puddles": "venom_dust", "judgement": "grand_cross", 
	"dive": "falcon_assault", "clock": "tarot_card", "orbit": "mirror_image", "leap": "leap", 
	"kafra": "service_for_you", "spokes": "lord_of_vermilion", "hazard": "fire_rain", 
}
const DEFAULT_ICON: = "provoke"
const VIGNETTE: = "shader_type canvas_item;\nuniform float k = 0.0;\nvoid fragment() {\n\tvec2 d = UV - vec2(0.5);\n\tfloat v = smoothstep(0.58, 0.9, max(abs(d.x), abs(d.y)) * 1.6);\n\tCOLOR = vec4(0.95, 0.05, 0.05, v * k);\n}\n"

var world: World
var _win: Control
var _title: Label
var _phase: Label
var _rows: Array[Dictionary] = []
var _warn: VBoxContainer
var _warn_title: Label
var _warn_sub: Label
var _warn_tween: Tween

var _hold_name: = ""
var _hold_t: = -1.0
var _count: Label
var _count_sub: Label
var _count_box: VBoxContainer
var _count_last: = -1
var _vignette: ColorRect
var _banner: Control
var _banner_tween: Tween


func _ready() -> void :
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_vignette = ColorRect.new()
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh: = Shader.new()
	sh.code = VIGNETTE
	var mat: = ShaderMaterial.new()
	mat.shader = sh
	_vignette.material = mat
	_vignette.visible = false
	add_child(_vignette)
	var w: = UiStyles.hud_window(tr("MVP"), RO_FONT_BOLD)
	_win = w.root
	_title = w.title
	add_child(_win)
	w.body.add_theme_constant_override("separation", 3)
	_phase = _text("", 9, Color(0.35, 0.3, 0.55))
	w.body.add_child(_phase)
	for i in ROWS:
		var cell: = PanelContainer.new()
		var box: = StyleBoxFlat.new()
		box.bg_color = Color(1, 1, 1, 0)
		box.set_corner_radius_all(3)
		box.content_margin_left = 3
		box.content_margin_right = 3
		box.content_margin_top = 1
		box.content_margin_bottom = 2
		cell.add_theme_stylebox_override("panel", box)

		cell.mouse_filter = Control.MOUSE_FILTER_PASS
		w.body.add_child(cell)
		var row: = VBoxContainer.new()
		row.add_theme_constant_override("separation", 1)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(row)
		var line: = HBoxContainer.new()
		line.add_theme_constant_override("separation", 4)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(line)
		var icon: = TextureRect.new()
		icon.custom_minimum_size = Vector2(ICON, ICON)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = RoAssets.ui_filter()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		line.add_child(icon)
		var name_l: = _text("", 10, Color.BLACK)
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.custom_minimum_size.x = BAR_W - ICON - 48
		name_l.clip_text = true
		name_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(name_l)
		var deadly: = _text("!", 12, Color(0.85, 0.1, 0.1), true)
		deadly.tooltip_text = tr("Mortal si fallas")
		deadly.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(deadly)
		var secs: = _text("", 10, Color(0.2, 0.25, 0.4))
		secs.custom_minimum_size.x = 30
		secs.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		secs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line.add_child(secs)
		var bar_blue: = UiStyles.hud_gauge("blue", BAR_W, 7.0)
		var bar_red: = UiStyles.hud_gauge("red", BAR_W, 7.0)
		row.add_child(bar_blue)
		row.add_child(bar_red)
		var hint: = _text("", 9, Color(0.15, 0.25, 0.6))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.custom_minimum_size.x = BAR_W
		hint.visible = false
		row.add_child(hint)
		_rows.append({"cell": cell, "box": box, "icon": icon, "name": name_l, "deadly": deadly, "secs": secs, 
			"blue": bar_blue, "red": bar_red, "hint": hint})
	_win.visible = false

	_warn = VBoxContainer.new()
	_warn.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_warn.offset_top = 184
	_warn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_warn)
	_warn_title = _text("", 26, Color(1, 0.85, 0.3), true)
	_warn_title.add_theme_color_override("font_outline_color", Color.BLACK)
	_warn_title.add_theme_constant_override("outline_size", 6)
	_warn_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warn.add_child(_warn_title)
	_warn_sub = _text("", 15, Color.WHITE)
	_warn_sub.add_theme_color_override("font_outline_color", Color.BLACK)
	_warn_sub.add_theme_constant_override("outline_size", 4)
	_warn_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_warn.add_child(_warn_sub)
	_warn.modulate.a = 0.0



	_count_box = VBoxContainer.new()
	_count_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_count_box.offset_top = 108
	_count_box.add_theme_constant_override("separation", -6)
	_count_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_count_box)
	_count = _text("", 44, Color(1.0, 0.25, 0.2), true)
	_count.add_theme_color_override("font_outline_color", Color.BLACK)
	_count.add_theme_constant_override("outline_size", 8)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_box.add_child(_count)
	_count_sub = _text("", 14, Color(1.0, 0.85, 0.8), true)
	_count_sub.add_theme_color_override("font_outline_color", Color.BLACK)
	_count_sub.add_theme_constant_override("outline_size", 4)
	_count_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_box.add_child(_count_sub)
	_count_box.visible = false


func _text(t: String, size: int, col: Color, bold: = false) -> Label:
	var l: = Label.new()
	l.text = t
	l.add_theme_font_override("font", RO_FONT_BOLD if bold else RO_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _process(delta: float) -> void :
	if world == null or world.raid == null:
		return

	var raid = world.morroc if world.morroc != null and world.morroc.fighting() else world.raid
	var entries: Array = raid.dbm_entries()
	_win.visible = raid.state == "fight" and not entries.is_empty()
	_hold_tick(raid, delta)
	if not _win.visible:
		_count_show(null, delta)
		return
	var view: = get_viewport().get_visible_rect().size
	var k: = maxf(1.0, floorf(view.y / 700.0))
	_win.scale = Vector2(k, k)
	_win.position = Vector2(8, roundf(view.y * 0.3))
	_title.text = tr("MVP · %s") % tr(GameData.MONSTERS[raid.mvp].name)
	_phase.text = _phase_line(raid)
	_phase.visible = _phase.text != ""
	var tips: = _tips(str(raid.mvp))
	var hints: = 0
	var said: = {}
	var next_seen: = false
	var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.012)
	for i in ROWS:
		var r: Dictionary = _rows[i]
		r.cell.visible = i < entries.size()
		if i >= entries.size():
			continue
		var en: Dictionary = entries[i]
		var now: bool = en.now
		var lethal: bool = en.lethal
		var red: bool = now or (lethal and en.left < 5.0)
		if r.name.text != en.name:
			r.name.text = en.name
		r.cell.tooltip_text = str(tips.get(tr(str(en.key)) if str(en.get("key", "")) != "" else str(en.name).trim_prefix("» "), ""))
		var mech: = str(en.get("mech", ""))
		if r.get("mech") != mech:
			r["mech"] = mech
			r.icon.texture = UiKit.skill_icon(str(MECH_ICONS.get(mech, DEFAULT_ICON)))
		r.deadly.visible = lethal

		if r.get("now") != now:
			r["now"] = now
			r.name.add_theme_color_override("font_color", Color(0.7, 0.08, 0.08) if now else Color.BLACK)
			r.name.add_theme_font_override("font", RO_FONT_BOLD if now else RO_FONT)
		r.secs.text = "%.0f s" % ceilf(en.left) if en.left > 0.05 else ""
		r.blue.visible = not red
		r.red.visible = red
		var bar: ProgressBar = r.red if red else r.blue
		bar.max_value = maxf(0.1, en.total)
		bar.value = en.total - en.left if not now else en.left

		var first_next: bool = not now and not next_seen
		if not now:
			next_seen = true
		var what: = _what(en)

		var on_hint: bool = what != "" and hints < HINTS and (now or first_next) and not said.has(what)
		if on_hint:
			hints += 1
			said[what] = true
			if r.hint.text != what:
				r.hint.text = what
		r.hint.visible = on_hint

		var box: StyleBoxFlat = r.box
		if now:
			box.bg_color = Color(1.0, 0.82, 0.8, 0.45 + 0.35 * pulse)
		elif first_next:
			box.bg_color = Color(1.0, 0.95, 0.75, 0.55)
		else:
			box.bg_color = Color(1, 1, 1, 0)
	_count_show(_deadly_soon(entries), delta)




func _what(en: Dictionary) -> String:
	var alert: = str(en.get("alert", ""))
	if alert == "":
		return ""
	var t: = tr(alert)
	var parts: = t.split(": ", true, 1)
	return parts[1] if parts.size() > 1 else t



func _phase_line(raid) -> String:
	var data = raid.get("data")
	if not (data is Dictionary) or not data.has("phases"):
		return ""
	var ph: Array = data.phases
	if ph.size() < 2:
		return ""
	var n: = clampi(int(raid.get("phase")), 0, ph.size() - 1)
	var line: = tr("Fase %d de %d") % [n + 1, ph.size()]
	if n + 1 < ph.size():
		line += "  ·  " + tr("la siguiente al %d%%") % roundi(float(ph[n + 1]) * 100.0)
	return line



func _deadly_soon(entries: Array):
	var best = null
	for en in entries:
		if bool(en.lethal) and float(en.left) > 0.05 and float(en.left) <= COUNT_FROM:
			if best == null or float(en.left) < float(best.left):
				best = en
	return best



func _count_show(en, _delta: float) -> void :
	if en == null:
		_count_box.visible = false
		_vignette.visible = false
		_count_last = -1
		return
	var n: = ceili(float(en.left))
	_count_box.visible = true
	_vignette.visible = true
	var nm: = str(en.name).trim_prefix("» ")
	_count_sub.text = nm if bool(en.now) else tr("%s en camino") % nm
	if n != _count_last:
		_count_last = n
		_count.text = str(n)
		_count_box.pivot_offset = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 30)
		_count_box.scale = Vector2.ONE * 1.35
		var tw: = create_tween()
		tw.tween_property(_count_box, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if world != null:
			world.play_sound("warning", 0.2, -6.0 if n > 1 else -2.0, 1.0 + 0.15 * (3 - n))
	var frac: = float(en.left) - floorf(float(en.left))
	(_vignette.material as ShaderMaterial).set_shader_parameter("k", 0.2 + 0.3 * frac)





var _tips_of: = ""
var _tips_cache: = {}
func _tips(mvp: String) -> Dictionary:
	if mvp == _tips_of:
		return _tips_cache
	_tips_of = mvp
	_tips_cache = {}
	for ab in GameData.RAIDS.get(mvp, {}).get("abilities", []):
		var tip: = tr(str(ab.get("alert", ""))).trim_prefix(tr(str(ab.get("name", ""))) + ": ")
		if bool(ab.get("lethal", false)):
			tip += ("\n" if tip != "" else "") + tr("Mortal si fallas")
		if tip != "":
			_tips_cache[tr(str(ab.get("name", "")))] = tip
	return _tips_cache




func warn(text: String, col: Color, sound: = "") -> void :
	var parts: = text.split(": ", true, 1)
	_warn_title.text = parts[0] if parts.size() > 1 else text
	_warn_sub.text = parts[1] if parts.size() > 1 else ""
	_warn_title.add_theme_color_override("font_color", col)
	if sound != "" and world != null:
		world.play_sound(sound, 0.4, -2.0)
	if _warn_tween != null:
		_warn_tween.kill()
	_hold_name = ""
	_hold_t = -1.0
	_warn.modulate.a = 1.0
	_warn.pivot_offset = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 20)
	_warn.scale = Vector2.ONE * 1.25
	_warn_tween = create_tween()
	_warn_tween.tween_property(_warn, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_warn_tween.tween_interval(2.6)
	var key: = _warn_title.text
	_warn_tween.tween_callback( func(): _warn_settle(key))




func _warn_settle(key: String) -> void :
	var raid = _raid_now()
	if raid != null and raid.has_method("active_names") and (raid.active_names() as Array).has(key):
		_hold_name = key
		_hold_t = HOLD_MAX
		_warn_tween = create_tween()
		_warn_tween.tween_property(_warn, "scale", Vector2.ONE * 0.7, 0.25)
		_warn_tween.parallel().tween_property(_warn, "modulate:a", 0.85, 0.25)
		return
	_warn_fade()


func _warn_fade() -> void :
	_hold_name = ""
	_hold_t = -1.0
	_warn_tween = create_tween()
	_warn_tween.tween_property(_warn, "modulate:a", 0.0, 0.5)



func _hold_tick(raid, delta: float) -> void :
	if _hold_name == "":
		return
	_hold_t -= delta
	if _hold_t <= 0.0 or not raid.has_method("active_names") or not (raid.active_names() as Array).has(_hold_name):
		_warn_fade()


func _raid_now():
	if world == null:
		return null
	return world.morroc if world.morroc != null and world.morroc.fighting() else world.raid



func big(title: String, sub: String, col: Color) -> void :
	warn(title + ": " + sub if sub != "" else title, col.lightened(0.25))



func mvp_alert(mvp_name: String, place: String, col: Color) -> void :
	if _banner != null and is_instance_valid(_banner):
		_banner.queue_free()
	var view: = get_viewport().get_visible_rect().size
	_banner = Control.new()
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.position = Vector2(0, roundf(view.y * 0.2))
	_banner.size = Vector2(view.x, 104)
	add_child(_banner)
	var strip: = ColorRect.new()
	strip.color = Color(0.06, 0.0, 0.04, 0.78)
	strip.size = _banner.size
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.add_child(strip)
	for y in [0.0, _banner.size.y - 3.0]:
		var edge: = ColorRect.new()
		edge.color = col
		edge.position = Vector2(0, y)
		edge.size = Vector2(view.x, 3)
		edge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_banner.add_child(edge)
	var col_box: = VBoxContainer.new()
	col_box.size = _banner.size
	col_box.alignment = BoxContainer.ALIGNMENT_CENTER
	col_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.add_child(col_box)
	var t1: = _text(tr("¡ALERTA MVP!  %s") % mvp_name, 30, Color(1, 0.3, 0.25), true)
	t1.add_theme_color_override("font_outline_color", Color.BLACK)
	t1.add_theme_constant_override("outline_size", 6)
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_box.add_child(t1)
	var t2: = _text(tr("Se abrió un portal a %s.  El tiempo se ha detenido: entra cuando estés listo.") % place, 14, Color(1, 0.92, 0.75))
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_box.add_child(t2)
	_banner.pivot_offset = _banner.size * 0.5
	_banner.scale = Vector2(1.0, 0.05)
	if _banner_tween != null:
		_banner_tween.kill()
	_banner_tween = _banner.create_tween()
	_banner_tween.tween_property(_banner, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_banner_tween.tween_property(t1, "modulate", Color(1.6, 1.4, 1.4), 0.25)
	_banner_tween.tween_property(t1, "modulate", Color.WHITE, 0.25)
	_banner_tween.tween_property(t1, "modulate", Color(1.6, 1.4, 1.4), 0.25)
	_banner_tween.tween_property(t1, "modulate", Color.WHITE, 0.25)
	_banner_tween.tween_interval(3.2)
	_banner_tween.tween_property(_banner, "modulate:a", 0.0, 0.6)
	_banner_tween.tween_callback(_banner.queue_free)
