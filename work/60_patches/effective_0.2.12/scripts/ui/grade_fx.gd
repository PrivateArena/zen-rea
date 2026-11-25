extends Control









const LIFT: = 8.0
const IMPACT: = 0.3
const SLAM: = 0.6
const SLAM_IN: = 0.16
const SETTLE: = 1.0
const SETTLE_DUR: = 0.28
const LETTER_SIZE: = 64
const SPARKS: = 22

var world: Node
var ok: = true
var col: = Color.WHITE
var letter: = ""

var icon: Control

var reveal: Array = []

var corner: Control

var frame_box: StyleBoxFlat

var from_col: = Color(0.6, 0.64, 0.75)

var corner_size: = 22

var slam_sound: = "drop_purple"

var _t: = 0.0
var _dur: = 1.35
var _done: = false
var _impacted: = false
var _slammed: = false
var _base_pos: = Vector2.ZERO
var _rays: TextureRect
var _clip: Control
var _border_to: = Color.WHITE
var _sp_pos: = PackedVector2Array()
var _sp_vel: = PackedVector2Array()
var _sp_life: = PackedFloat32Array()
var _sp_age: = PackedFloat32Array()
var _sp_col: Array[Color] = []
var _font: Font = UiKit.FONT_TITLE


func _init() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)



func play(slot: Control) -> void :
	_dur = 1.35 if ok else 0.85
	_base_pos = icon.position
	_border_to = frame_box.border_color if frame_box != null else col
	if frame_box != null:
		frame_box.border_color = from_col
	for r in reveal:
		if is_instance_valid(r):
			(r as CanvasItem).modulate.a = 0.0
	slot.add_child(self)
	if ok:

		_clip = Control.new()
		_clip.clip_contents = true
		_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_clip.offset_left = 3
		_clip.offset_top = 3
		_clip.offset_right = -3
		_clip.offset_bottom = -3
		slot.add_child(_clip)
		slot.move_child(_clip, icon.get_index())
		_rays = UiKit.rays(Color(col.lightened(0.25), 0.0), 190.0)
		_rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_clip.add_child(_rays)
	_sound("refine_hammer", -4.0)


func _sound(key: String, db: float) -> void :
	if world != null and is_instance_valid(world) and RoAssets.sound(key) != null:
		world.play_sound(key, 0.0, db)


func _process(delta: float) -> void :
	if _done:
		return

	delta = minf(delta, 1.0 / 30.0)
	_t += delta
	if not is_instance_valid(icon):
		_finish_now()
		return
	if not _impacted and _t >= IMPACT:
		_impact()
	if ok and not _slammed and _t >= SLAM + SLAM_IN:
		_slammed = true
		_sound(slam_sound, -2.0)
		_add_ring(SLAM + SLAM_IN, 0.4, 20.0, 66.0, 5.0, col.lightened(0.4))
	_pose()
	_step_sparks(delta)
	queue_redraw()
	if _t >= _dur:
		_finish_now()



func _impact() -> void :
	_impacted = true
	if ok:
		_sound("refine_ok", -2.0)
		_add_ring(IMPACT, 0.45, 10.0, 80.0, 7.0, col.lightened(0.2))
		_add_ring(IMPACT + 0.09, 0.42, 8.0, 62.0, 4.0, Color(1, 1, 1))
		_spawn_sparks(true)
		if frame_box != null:
			frame_box.border_color = col.lightened(0.45)
	else:
		_sound("refine_fail", -2.0)
		_spawn_sparks(false)
		if frame_box != null:
			frame_box.border_color = Color(0.75, 0.2, 0.2)


var _rings: Array = []


func _add_ring(at: float, dur: float, r0: float, r1: float, w: float, c: Color) -> void :
	_rings.append([at, dur, r0, r1, w, c])


func _spawn_sparks(good: bool) -> void :
	var c: = size * 0.5
	var n: = SPARKS if good else 14
	_sp_pos.resize(n)
	_sp_vel.resize(n)
	_sp_life.resize(n)
	_sp_age.resize(n)
	_sp_col.clear()
	for i in n:
		var a: = TAU * float(i) / n + randf_range(-0.2, 0.2)
		if good:
			_sp_pos[i] = c + Vector2(cos(a), sin(a)) * 8.0
			_sp_vel[i] = Vector2(cos(a), sin(a)) * randf_range(110.0, 220.0) + Vector2(0, -40)
			_sp_life[i] = randf_range(0.5, 0.85)
			_sp_col.append(Color(1, 1, 1) if i % 3 == 0 else col.lightened(randf_range(0.2, 0.5)))
		else:

			_sp_pos[i] = c + Vector2(randf_range(-26, 26), randf_range(-10, 16))
			_sp_vel[i] = Vector2(randf_range(-30, 30), randf_range(-60, -20))
			_sp_life[i] = randf_range(0.4, 0.55)
			_sp_col.append(Color(0.72, 0.68, 0.7))
		_sp_age[i] = 0.0


func _step_sparks(delta: float) -> void :
	var g: = 320.0 if ok else 180.0
	for i in _sp_pos.size():
		_sp_age[i] += delta
		_sp_vel[i] = _sp_vel[i] * (1.0 - 2.2 * delta) + Vector2(0, g * delta)
		_sp_pos[i] += _sp_vel[i] * delta



func _pose() -> void :
	var off: = Vector2.ZERO
	var sc: = 1.0
	var mod: = Color.WHITE
	if _t < IMPACT:

		var k: = fmod(_t, IMPACT * 0.5) / (IMPACT * 0.5)
		off.y = sin(k * PI) * 4.0
	elif ok:
		var u: = _t - IMPACT
		var up: = ease(clampf(u / 0.18, 0.0, 1.0), 0.4)
		var down: = ease(clampf((_t - SETTLE) / SETTLE_DUR, 0.0, 1.0), -2.0)
		off.y = - LIFT * up * (1.0 - down) + sin(u * 9.0) * 1.2 * up * (1.0 - down)
		sc = 1.0 + 0.24 * up * (1.0 - clampf(u / 0.5, 0.0, 1.0)) + 0.1 * up * (1.0 - down)
		var glow: = 1.0 - clampf(u / 0.7, 0.0, 1.0)
		mod = Color(1.0 + (0.5 + col.r) * glow, 1.0 + (0.5 + col.g) * glow, 1.0 + (0.5 + col.b) * glow)
	else:
		var u: = _t - IMPACT
		var k: = clampf(u / 0.35, 0.0, 1.0)
		off.x = sin(u * 55.0) * 4.0 * (1.0 - k)
		var dark: = 1.0 - clampf(u / 0.5, 0.0, 1.0)
		mod = Color(1.0 - 0.35 * dark, 1.0 - 0.5 * dark, 1.0 - 0.5 * dark)
	icon.position = _base_pos + off
	icon.scale = Vector2(sc, sc)
	icon.modulate = mod
	if _rays != null:
		var u2: = _t - IMPACT
		var a: = clampf(u2 / 0.12, 0.0, 1.0) * (1.0 - clampf((u2 - 0.6) / 0.45, 0.0, 1.0)) if u2 > 0.0 else 0.0
		_rays.modulate.a = a * 0.95
		_rays.rotation = u2 * 1.4
		_rays.position = _clip.size * 0.5 - _rays.size * 0.5
		_rays.pivot_offset = _rays.size * 0.5


func _draw() -> void :
	var c: = size * 0.5
	var inner: = Rect2(Vector2(3, 3), size - Vector2(6, 6))

	if _impacted:
		var u: = _t - IMPACT
		var fa: = (1.0 - clampf(u / 0.28, 0.0, 1.0)) * (0.85 if ok else 0.35)
		if fa > 0.0:
			draw_rect(inner, Color(Color(1, 0.97, 0.9).lerp(col, 0.2), fa) if ok else Color(0.8, 0.15, 0.1, fa))

	for r in _rings:
		var u: float = (_t - float(r[0])) / float(r[1])
		if u < 0.0 or u > 1.0:
			continue
		var e: = ease(u, 0.35)
		var rc: Color = r[5]
		draw_arc(c, lerpf(float(r[2]), float(r[3]), e), 0.0, TAU, 48, Color(rc, (1.0 - u) * 0.95), lerpf(float(r[4]), 1.0, u), true)

	for i in _sp_pos.size():
		var life: = _sp_life[i]
		var k: = _sp_age[i] / life
		if k >= 1.0:
			continue
		var sc: Color = _sp_col[i]
		var tail: = _sp_vel[i] * 0.035
		var fade: = 1.0 - k * k


		draw_line(_sp_pos[i] - tail, _sp_pos[i], Color(sc.darkened(0.55), fade * 0.8), 4.0, true)
		draw_line(_sp_pos[i] - tail, _sp_pos[i], Color(sc, fade), 2.0, true)
	if ok:
		_draw_letter(c)





func _draw_letter(c: Vector2) -> void :
	if _t < SLAM:
		return
	var fill: = col.lightened(0.15)
	var line: = col.darkened(0.7)
	var pos: = c
	var s: = 1.0
	var a: = 1.0
	var u: = (_t - SLAM) / SLAM_IN
	if u < 1.0:
		var e: = ease(u, 2.2)
		s = lerpf(2.3, 1.0, e)
		a = clampf(u * 5.0, 0.0, 1.0)
		fill = Color.WHITE.lerp(fill, e * 0.5)
	else:
		var heat: = 1.0 - clampf((_t - SLAM - SLAM_IN) / 0.25, 0.0, 1.0)
		fill = fill.lerp(Color.WHITE, heat * 0.5)

		var b: = _t - SLAM - SLAM_IN
		s = 1.0 + 0.12 * sin(clampf(b / 0.14, 0.0, 1.0) * PI)
		var m: = clampf((_t - SETTLE) / SETTLE_DUR, 0.0, 1.0)
		if m > 0.0 and corner != null and is_instance_valid(corner):
			var to: = corner.position + corner.size * 0.5
			var em: = ease(m, -2.2)
			pos = c.lerp(to, em)
			s = lerpf(s, float(corner_size) / LETTER_SIZE, em)

		if b < 0.4:
			var k: = b / 0.4
			_letter(pos, 1.0 + 0.7 * k, Color(col.lightened(0.5), 0.6 * (1.0 - k)), Color(0, 0, 0, 0), 0)
	_letter(pos, s, Color(fill, a), Color(line, a), 10)


func _letter(at: Vector2, s: float, fill: Color, line: Color, outline: int) -> void :
	var sz: = _font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, LETTER_SIZE)
	var base: = Vector2( - sz.x * 0.5, (_font.get_ascent(LETTER_SIZE) - _font.get_descent(LETTER_SIZE)) * 0.5)
	draw_set_transform(at, 0.0, Vector2(s, s))
	if outline > 0:
		draw_string_outline(_font, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, LETTER_SIZE, outline, line)
	draw_string(_font, base, letter, HORIZONTAL_ALIGNMENT_LEFT, -1, LETTER_SIZE, fill)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed:
		finish()
		accept_event()



func finish() -> void :
	if _done:
		return
	if not _impacted:
		_sound("refine_ok" if ok else "refine_fail", -2.0)
	_finish_now()


func _finish_now() -> void :
	_done = true
	if is_instance_valid(icon):
		icon.position = _base_pos
		icon.scale = Vector2.ONE
		icon.modulate = Color.WHITE
	if frame_box != null:
		frame_box.border_color = _border_to
	for r in reveal:
		if is_instance_valid(r):
			(r as CanvasItem).modulate.a = 1.0
	if ok and _t >= _dur and corner != null and is_instance_valid(corner):

		corner.pivot_offset = corner.size * 0.5
		corner.scale = Vector2(1.3, 1.3)
		var tw: = corner.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(corner, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _clip != null and is_instance_valid(_clip):
		_clip.queue_free()
	queue_free()






static var _shine_mat: ShaderMaterial


static func shine(cell: Control) -> ColorRect:
	if _shine_mat == null:
		var sh: = Shader.new()
		sh.code = "shader_type canvas_item;\r\nrender_mode blend_mix;\r\nuniform float period = 3.5;\r\nuniform float sweep = 0.6;\r\nuniform float radius = 4.0;\r\nuniform float inset = 1.5;\r\nuniform vec4 tint : source_color = vec4(1.0, 0.72, 0.18, 1.0);\r\nuniform vec4 core : source_color = vec4(1.0, 0.98, 0.88, 1.0);\r\nvoid fragment() {\r\n\t// The rect's size in pixels (no per-cell uniform: one material for all).\r\n\tvec2 px = 1.0 / max(fwidth(UV), vec2(0.0001));\r\n\tvec2 p = UV * px;\r\n\tvec2 q = abs(p - px * 0.5) - (px * 0.5 - inset - radius);\r\n\tfloat sd = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;\r\n\tfloat mask = clamp(0.5 - sd, 0.0, 1.0);\r\n\tfloat ph = mod(TIME, period) / sweep;\r\n\tfloat w = clamp(min(px.x, px.y) * 0.24, 5.0, 16.0);\r\n\t// 0 at the lower left corner, px.x + px.y at the upper right one.\r\n\tfloat d = p.x + (px.y - p.y);\r\n\tfloat c = mix(-w * 2.0, px.x + px.y + w * 2.0, ph);\r\n\tfloat x = abs(d - c);\r\n\t// Gold edges, a white-hot core (gold reads on light cells, the core\r\n\t// on dark ones) and a thin glint trailing it.\r\n\tfloat halo = smoothstep(w, 0.0, x);\r\n\tfloat hot = smoothstep(w * 0.45, 0.0, x);\r\n\tfloat glint = smoothstep(w * 0.22, 0.0, abs(d - c + w * 1.5));\r\n\tvec3 rgb = mix(tint.rgb, core.rgb, hot);\r\n\tCOLOR = vec4(rgb, max(halo * 0.75, glint * 0.65) * mask * step(ph, 1.0));\r\n}"




























		_shine_mat = ShaderMaterial.new()
		_shine_mat.shader = sh
	var r: = ColorRect.new()
	r.material = _shine_mat
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cell.add_child(r)
	return r
