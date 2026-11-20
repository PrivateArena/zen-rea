extends Control













const BADGE: = Vector2(14, 11)
const BAR: = Vector2(34, 5)
const KEY: = Vector2(11, 11)
const GAP: = 3.0
const PAD: = 2.0
const NUMERALS: = ["", "1", "2", "3", "4", "5", "6", "7", "8"]

var world: World

var hud: Node
var _t: = 0.0
var _flash: = 0.0
var _pop: = 0.0
var _stage_seen: = 0
var _font: Font = UiKit.FONT_TITLE


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(PAD + BADGE.x + GAP + BAR.x + GAP + KEY.x + PAD, GameData.U_OV_GAUGE_H)
	visible = false


func _process(delta: float) -> void :
	if world == null and hud != null:
		world = hud.get("world")
	var p: Player = world.player if world != null else null
	var on: bool = p != null and is_instance_valid(p) and world.running and Uniques.cannon(p) != ""\
	and p.hp > 0.0 and world.camera != null and not world.busy()
	var cam: Camera3D = world.camera if on else null
	var feet: = Vector3.ZERO
	if on:

		feet = p.position + RoVisual.world_lift() - Vector3(0, 0.5, 0)
		on = not cam.is_position_behind(feet)
	visible = on
	if not on:
		return
	_t += delta
	if p.ov_stage > _stage_seen:
		_flash = 1.0
		_pop = 1.0
	_stage_seen = p.ov_stage
	_flash = maxf(0.0, _flash - delta * 2.5)
	_pop = maxf(0.0, _pop - delta * 3.0)

	var k: = maxf(1.0, floorf(get_viewport_rect().size.y / 700.0))
	scale = Vector2(k, k)
	var at: = cam.unproject_position(feet)
	var below: = 0.0
	if bool(Save.setting("hero_hp_bar", true)):
		below += (5.0 + 2.0 + (5.0 * 0.7 + 1.0 if p.shield > 0.0 else 0.0)) * k
	if p.forge_on():
		below += 4.0 * k
	size.x = _excal_w() if Uniques.cannon(p) == "excal" else PAD + BADGE.x + GAP + BAR.x + GAP + KEY.x + PAD
	position = Vector2(roundf(at.x - size.x * k * 0.5), roundf(at.y + below))
	queue_redraw()



static func _key_text() -> String:
	if OS.has_feature("mobile") or "--touch" in OS.get_cmdline_user_args():
		return ""
	return "LT" if not Input.get_connected_joypads().is_empty() else "R"




const EX_GEM: = 11.0
const EX_GRIP: = 5.0
const EX_GUARD: = Vector2(3, 13)
const EX_BLADE: = Vector2(48, 5)
const EX_TIP: = 6.0


func _excal_w() -> float:
	var key: = _key_text()
	return PAD + EX_GEM + EX_GRIP + EX_GUARD.x + EX_BLADE.x + EX_TIP + (GAP + KEY.x + (6.0 if key.length() > 1 else 0.0) if key != "" else 0.0) + PAD


func _draw_excal(p: Player) -> void :
	var stage: int = p.ov_stage
	var top: bool = stage >= GameData.U_OV_STAGES
	var part: = 1.0 if top else Uniques.overload_part(float(p.uniq.get("ov_t", 0.0)), Uniques.charge_steps(p))
	var gold: = GameData.U_EX_GOLD
	var pale: = GameData.U_EX_PALE
	var pulse: = 0.5 + 0.5 * sin(_t * 6.0)
	var cy: = size.y * 0.5

	var plate: = StyleBoxFlat.new()
	plate.bg_color = Color(0.1, 0.07, 0.02, 0.6)
	plate.set_corner_radius_all(3)
	plate.set_border_width_all(1)
	plate.border_color = Color(gold, 0.35 + (0.4 * pulse if top else 0.0))
	if top:
		plate.shadow_color = Color(gold, 0.5 * pulse)
		plate.shadow_size = 5
	draw_style_box(plate, Rect2(Vector2.ZERO, size))
	var x: = PAD

	var gc: = Vector2(x + EX_GEM * 0.5, cy)
	var gr: = EX_GEM * 0.5 * (1.0 + 0.4 * _pop)
	var gem: = PackedVector2Array([gc + Vector2(0, - gr), gc + Vector2(gr, 0), gc + Vector2(0, gr), gc + Vector2( - gr, 0)])
	draw_colored_polygon(gem, gold.darkened(0.35) if stage > 0 else Color(0.25, 0.2, 0.12, 0.9))
	var rim: = gem.duplicate()
	rim.append(gem[0])
	draw_polyline(rim, gold.lerp(Color.WHITE, 0.5 * _pop) if stage > 0 else Color(0.55, 0.45, 0.3), 1.0, true)
	draw_string(_font, Vector2(gc.x - gr, cy + 3.5), str(stage) if stage > 0 else "-", HORIZONTAL_ALIGNMENT_CENTER, gr * 2.0, 9, 
		Color.WHITE if stage > 0 else Color(0.7, 0.62, 0.5))
	x += EX_GEM

	draw_rect(Rect2(x, cy - 1.5, EX_GRIP, 3), Color(0.35, 0.22, 0.1))
	for i in 2:
		draw_line(Vector2(x + 1.5 + i * 2.0, cy - 1.5), Vector2(x + 0.5 + i * 2.0, cy + 1.5), Color(0.6, 0.45, 0.25), 1.0)
	x += EX_GRIP

	draw_rect(Rect2(x, cy - EX_GUARD.y * 0.5, EX_GUARD.x, EX_GUARD.y), gold.darkened(0.15))
	draw_rect(Rect2(x, cy - EX_GUARD.y * 0.5, 1, EX_GUARD.y), Color(1, 1, 1, 0.4))
	x += EX_GUARD.x

	var blade: = Rect2(x, cy - EX_BLADE.y * 0.5, EX_BLADE.x, EX_BLADE.y)
	var tip: = PackedVector2Array([Vector2(blade.end.x, blade.position.y), Vector2(blade.end.x + EX_TIP, cy), Vector2(blade.end.x, blade.end.y)])
	draw_rect(blade, Color(0.32, 0.33, 0.38, 0.95))
	draw_colored_polygon(tip, gold.lerp(Color.WHITE, 0.4 * pulse) if top else Color(0.32, 0.33, 0.38, 0.95))
	var n: = GameData.U_OV_STAGES
	var seg: = EX_BLADE.x / n
	for i in n:
		var fill: = 1.0 if i < stage else (part if i == stage else 0.0)
		if fill <= 0.0:
			continue
		var col: = pale.lerp(gold, float(i + 1) / n)
		if top:
			col = gold.lerp(Color.WHITE, 0.35 * pulse)
		draw_rect(Rect2(blade.position.x + i * seg, blade.position.y, seg * fill, blade.size.y), col if fill >= 1.0 else Color(col, 0.6))
	for i in range(1, n):
		draw_line(Vector2(blade.position.x + i * seg, blade.position.y), Vector2(blade.position.x + i * seg, blade.end.y), Color(0.1, 0.07, 0.02, 0.55), 1.0)

	draw_line(blade.position, Vector2(blade.end.x, blade.position.y), Color(1, 1, 1, 0.5), 1.0)
	draw_line(Vector2(blade.position.x, cy), Vector2(blade.end.x - 2.0, cy), Color(1, 1, 1, 0.18), 1.0)
	x = blade.end.x + EX_TIP

	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(pale, 0.35 * _flash))
		var spread: = 6.0 + 14.0 * (1.0 - _flash)
		var halo: = StyleBoxFlat.new()
		halo.draw_center = false
		halo.set_border_width_all(1)
		halo.set_corner_radius_all(6)
		halo.border_color = Color(gold.lerp(Color.WHITE, 0.4), _flash)
		draw_style_box(halo, Rect2(Vector2( - spread, - spread * 0.5), size + Vector2(spread * 2.0, spread)))
	var key: = _key_text()
	if key == "":
		return
	var kw: = KEY.x + (6.0 if key.length() > 1 else 0.0)
	var kr: = Rect2(x + GAP, (size.y - KEY.y) * 0.5, kw, KEY.y)
	var kb: = StyleBoxFlat.new()
	kb.set_corner_radius_all(3)
	kb.set_border_width_all(1)
	kb.bg_color = gold.darkened(0.6) if stage > 0 else Color(0.18, 0.14, 0.08, 0.85)
	kb.border_color = gold.lerp(Color.WHITE, 0.4 * pulse) if top else (gold if stage > 0 else Color(0.5, 0.42, 0.28))
	draw_style_box(kb, kr)
	draw_string(_font, Vector2(kr.position.x, kr.position.y + 9.0), key, HORIZONTAL_ALIGNMENT_CENTER, kw, 9 if key.length() == 1 else 7, 
		Color.WHITE if stage > 0 else Color(0.7, 0.62, 0.5))


func _draw() -> void :
	var p: Player = world.player
	if Uniques.cannon(p) == "excal":
		_draw_excal(p)
		return
	var stage: int = p.ov_stage
	var top: bool = stage >= GameData.U_OV_STAGES
	var part: = 1.0 if top else Uniques.overload_part(float(p.uniq.get("ov_t", 0.0)))

	var excal: = Uniques.cannon(p) == "excal"
	var blue: = GameData.U_EX_PALE if excal else GameData.U_OV_BLUE
	var gold: = GameData.U_EX_GOLD if excal else GameData.U_OV_GOLD
	var pulse: = 0.5 + 0.5 * sin(_t * 6.0)
	var col: = gold if top else blue.lerp(gold, float(stage) / GameData.U_OV_STAGES)

	var plate: = StyleBoxFlat.new()
	plate.bg_color = Color(0.04, 0.06, 0.12, 0.5)
	plate.set_corner_radius_all(3)
	if top:
		plate.shadow_color = Color(gold, 0.45 * pulse)
		plate.shadow_size = 4
	draw_style_box(plate, Rect2(Vector2.ZERO, size))

	var b: = Rect2(PAD, (size.y - BADGE.y) * 0.5, BADGE.x, BADGE.y)
	var grow: = 1.0 + 0.45 * _pop
	var bc: = b.get_center()
	var br: = Rect2(bc - b.size * grow * 0.5, b.size * grow)
	var bb: = StyleBoxFlat.new()
	bb.set_corner_radius_all(3)
	bb.set_border_width_all(1)
	bb.bg_color = col.darkened(0.55) if stage > 0 else Color(0.12, 0.14, 0.22, 0.8)
	bb.border_color = col.lerp(Color.WHITE, 0.5 * _pop + (0.35 * pulse if top else 0.0)) if stage > 0 else Color(0.35, 0.4, 0.55)
	draw_style_box(bb, br)
	var num: String = NUMERALS[clampi(stage, 0, NUMERALS.size() - 1)] if stage > 0 else "-"
	draw_string(_font, Vector2(br.position.x, bc.y + 3.5), num, HORIZONTAL_ALIGNMENT_CENTER, br.size.x, 9, 
		Color.WHITE if stage > 0 else Color(0.55, 0.6, 0.72))

	var r: = Rect2(b.end.x + GAP, (size.y - BAR.y) * 0.5, BAR.x, BAR.y)
	draw_rect(r, Color(0.14, 0.17, 0.28, 0.9))
	var next: = gold if stage + 1 >= GameData.U_OV_STAGES else blue.lerp(gold, float(stage + 1) / GameData.U_OV_STAGES)
	var fill_col: Color = gold.lerp(Color.WHITE, 0.3 * pulse) if top else next
	draw_rect(Rect2(r.position, Vector2(r.size.x * part, r.size.y)), fill_col)
	draw_rect(Rect2(r.position, Vector2(r.size.x * part, 1)), Color(1, 1, 1, 0.45))

	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), Color(col.lerp(Color.WHITE, 0.6), 0.35 * _flash))
		var ring: = 1.0 - _flash
		var spread: = 6.0 + 14.0 * ring
		var halo: = StyleBoxFlat.new()
		halo.draw_center = false
		halo.set_border_width_all(1)
		halo.set_corner_radius_all(6)
		halo.border_color = Color(col.lerp(Color.WHITE, 0.4), _flash)
		draw_style_box(halo, Rect2(Vector2( - spread, - spread * 0.5), size + Vector2(spread * 2.0, spread)))


	var key_text: = _key_text()
	if key_text == "":
		return
	var key: = Rect2(size.x - PAD - KEY.x, (size.y - KEY.y) * 0.5, KEY.x, KEY.y)
	var kb: = StyleBoxFlat.new()
	kb.set_corner_radius_all(3)
	kb.set_border_width_all(1)
	if stage > 0:
		kb.bg_color = col.darkened(0.5)
		kb.border_color = gold.lerp(Color.WHITE, 0.4 * pulse) if top else col
	else:
		kb.bg_color = Color(0.12, 0.14, 0.22, 0.8)
		kb.border_color = Color(0.35, 0.4, 0.55)
	draw_style_box(kb, key)
	draw_string(_font, Vector2(key.position.x, key.position.y + 9.0), key_text, HORIZONTAL_ALIGNMENT_CENTER, KEY.x, 9 if key_text.length() == 1 else 7, 
		Color.WHITE if stage > 0 else Color(0.55, 0.6, 0.72))
