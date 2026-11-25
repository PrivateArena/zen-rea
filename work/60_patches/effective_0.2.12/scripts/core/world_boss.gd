extends Node

const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")











var world: World

var st: = {}
var build_name: = ""
var mvp: = ""

var state: = "load"
var left: = 0.0

var dealt: = 0.0

var kills0: = 0
var kills: = 0
var need: = 1.0
var boss: Enemy
var _layer: CanvasLayer
var _bar: Control
var _name_l: Label
var _layers_l: Label
var _timer_l: Label
var _dealt_l: Label
var _cond_row: HBoxContainer

var _sg_row: HBoxContainer
var _sg_bar: ProgressBar
var _sg_fill: StyleBoxFlat
var _sg_label: Label
var _ghost_t: = 0.0
var _step_t: = 0.0
var _last_pos: = Vector3.INF
var _layer_seen: = -1





var _srv_total: = -1.0
var _sync_t: = 0.0
var _syncing: = false


var _hp_l: Label
var _hp_text: = ""
var _hp_pulse: = 0.0
var _others_l: Label
var _others_t: = 0.0
var _others_sum: = 0.0
var _reborn_by_others: = false


func _init(w: World, state_in: Dictionary, name_line: = "") -> void :
	world = w
	st = state_in
	build_name = name_line
	mvp = str(st.get("boss", "baphomet"))
	kills0 = int(st.get("kills", 0))
	kills = kills0
	need = maxf(1.0, float(st.get("need", GameData.WB_BASE_HP)))
	_srv_total = float(st.get("total", -1.0)) if st.has("total") else -1.0
	_sync_t = GameData.WB_SYNC_FIRST


func _ready() -> void :
	name = "WorldBoss"

	left = float(GameData.get_meta("wb_time", GameData.WB_TIME))
	_build_ui()

	var raid: MvpRaid = world.raid
	raid.mvp = mvp


	raid.data = (GameData.RAIDS[mvp] as Dictionary).duplicate()
	raid.data["arena"] = GameData.WB_ARENA
	raid.data["radius"] = GameData.WB_ARENA_RADIUS
	raid.data["title"] = GameData.WB_ARENA_TITLE
	raid.color = raid.data.color
	raid._enter()


func _exit_tree() -> void :
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()



func conds() -> Array:
	var out: Array = []
	for c in st.get("conds", []):
		var s: = str(c)
		out.append([s.get_slice(":", 0), s.get_slice(":", 1) if s.contains(":") else ""])
	return out



static func cond_text(kind: String, arg: String) -> String:
	var el: = TranslationServer.translate(str(GameData.ELEMENT_NAMES.get(arg, arg)))
	match kind:
		"weak":
			return TranslationServer.translate("Débil a %s: +%d%% de daño") % [el, roundi((GameData.WB_WEAK - 1.0) * 100.0)]
		"immune":
			return TranslationServer.translate("Inmune a %s") % el
		"no_skills":
			return TranslationServer.translate("Sin habilidades: solo el ataque básico le hace daño")
		"no_basic":
			return TranslationServer.translate("Sin ataque básico: solo las habilidades le hacen daño")
		"favor":
			var cname: = TranslationServer.translate(str(GameData.CLASSES.get(arg, {}).get("name", arg)))
			return TranslationServer.translate("Clase favorecida: %s hace x%s, las demás x%s") % [cname, _num(GameData.WB_FAVOR), _num(GameData.WB_UNFAVOR)]
	return ""




static func boss_picture(id: String) -> Texture2D:
	var spr: = RoAssets.sprite([id])
	if spr == null:
		return null
	var tex: Texture2D = spr.get_frame(0, 0)
	var img: Image = tex.get_image() if tex != null else null
	if img == null:
		return tex
	if img.is_compressed():
		img.decompress()
	var r: = img.get_used_rect()
	if r.size.x < 2 or r.size.y < 2:
		return tex
	return ImageTexture.create_from_image(img.get_region(r))



static func _num(x: float) -> String:
	return str(int(x)) if is_equal_approx(x, roundf(x)) else str(snappedf(x, 0.01))



static func cond_chips(conds_in: Array, size: = 12, dark: = true) -> HFlowContainer:
	var chips: = HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 6)
	chips.add_theme_constant_override("v_separation", 4)
	for c in conds_in:
		var s: = str(c)
		var kind: = s.get_slice(":", 0)
		var arg: = s.get_slice(":", 1) if s.contains(":") else ""
		var chip: = PanelContainer.new()
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.14, 0.1, 0.18) if dark else Color(0.2, 0.14, 0.28)
		sb.border_color = cond_color(kind, arg)
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 9
		sb.content_margin_right = 9
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
		chip.add_theme_stylebox_override("panel", sb)
		var l: = Label.new()
		l.text = cond_text(kind, arg)
		l.add_theme_font_override("font", Hud.RO_FONT_BOLD)
		l.add_theme_font_size_override("font_size", size)
		l.add_theme_color_override("font_color", cond_color(kind, arg).lightened(0.35))
		chip.add_child(l)
		chips.add_child(chip)
	return chips



static func time_left(secs: int) -> String:
	secs = maxi(0, secs)
	if secs >= 86400:
		return "%dd %dh" % [secs / 86400, (secs % 86400) / 3600]
	return "%dh %dm" % [secs / 3600, (secs % 3600) / 60]


static func cond_color(kind: String, arg: String) -> Color:
	if kind in ["weak", "immune"]:
		return GameData.ELEMENT_COLORS.get(arg, Color(0.6, 0.6, 0.7))
	if kind == "favor":
		return Color(0.95, 0.75, 0.3)
	return Color(0.85, 0.4, 0.4)




func on_boss(e: Enemy) -> void :
	boss = e
	e.max_hp = need
	e.hp = maxf(1.0, need - float(st.get("into", 0.0)))

	e.damage *= pow(GameData.WB_DMG_GROWTH, kills0)
	e.radius *= GameData.WB_RADIUS
	e.speed *= GameData.WB_SPEED
	if e.visual is Node3D:
		(e.visual as Node3D).scale *= GameData.WB_SCALE
	var col: Color = world.raid.color
	Vfx.magic_circle(e, Vector3.ZERO, 3.6, Color(0.25, 0.05, 0.12, 0.55), 0.0, "mvp_rune", 0.35, GameData.MVP_UNDER_PRIORITY, true)
	Vfx.magic_circle(e, Vector3.ZERO, 2.4, Color(col, 0.45), 0.0, "mvp_hexa", -0.8, GameData.MVP_UNDER_PRIORITY, true)
	state = "fight"
	_banner()
	world.shake(0.9)
	world.play_sound("warning", 0.0, 2.0)
	world.play_mob_sound(mvp, "attack")



func _banner() -> void :
	world.hud.flash(Color(0.05, 0.0, 0.08, 0.7), 0.6, 0.6)
	var sub: = []
	for c in conds():
		sub.append(cond_text(c[0], c[1]))
	world.hud.announce(tr("JEFE DEL MUNDO") + "  ·  " + boss_title(), Color(1.0, 0.45, 0.35), "  ·  ".join(sub))



func boss_title() -> String:
	return boss_name(mvp, kills)


static func boss_name(id: String, k: int) -> String:
	var n: = TranslationServer.translate(str(GameData.MONSTERS.get(id, {}).get("name", id)))
	if k <= 0:
		return n
	return TranslationServer.translate("%s Renacido %s") % [n, roman(k)]


static func roman(n: int) -> String:
	var vals: = [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"], [50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]]
	var out: = ""
	for v in vals:
		while n >= int(v[0]):
			out += str(v[1])
			n -= int(v[0])
	return out




func on_hit(e: Enemy, amount: float, source: String, element: String, src: Player) -> float:
	if state != "fight":
		return amount


	if amount <= 0.0:
		return amount
	for c in conds():
		match str(c[0]):
			"weak":
				if element == str(c[1]):
					amount *= GameData.WB_WEAK
			"immune":
				if element == str(c[1]):
					amount = 0.0
			"no_skills":
				if source != "basic":
					amount = 0.0
			"no_basic":
				if source == "basic":
					amount = 0.0
			"favor":
				amount *= GameData.WB_FAVOR if src != null and src.class_id == str(c[1]) else GameData.WB_UNFAVOR
	if amount <= 0.0:
		if randf() < 0.15:
			world.number(e.position + Vector3(0, 2.6, 0), tr("Inmune"), Color(0.75, 0.75, 0.8))
		return 0.0
	dealt += amount

	_rebirths(e, amount)


	if _bar != null and (_bar as LayerBar).hit < 0.4:
		(_bar as LayerBar).hit = 1.0
	return amount




func _rebirths(e: Enemy, amount: float) -> void :
	while amount >= e.hp:
		kills += 1
		need *= GameData.WB_GROWTH
		e.max_hp = need
		e.hp += need
		e.damage *= GameData.WB_DMG_GROWTH
		_reborn()


func _reborn() -> void :
	var col: Color = world.raid.color
	Vfx.column(world.fx_root, boss.position, col)
	Vfx.burst(world.fx_root, boss.position, 6.0, Color(1.0, 0.85, 0.5))
	Vfx.ring(world.fx_root, boss.position, 8.0, col, 0.8)
	world.shake(1.0)
	world.play_sound("job_levelup", 0.0, 0.0)
	world.hud.announce(tr("¡Renació!"), Color(1.0, 0.85, 0.4), 
		boss_title() + ("  ·  " + tr("La comunidad lo derribó") if _reborn_by_others else ""))




func _sync(delta: float) -> void :
	if _srv_total < 0.0 or _syncing:
		return
	_sync_t -= delta
	if _sync_t > 0.0:
		return
	_sync_t = GameData.WB_SYNC
	_syncing = true
	world.board.wb_state( func(d: Dictionary):
		_syncing = false

		if d.is_empty() and GameData.has_meta("wb_fake"):
			d = GameData.get_meta("wb_fake")
		if state != "fight" or not d.has("total") or str(d.get("week", "")) != str(st.get("week", "")):
			return
		var total: = float(d.total)
		var got: = total - _srv_total
		if got <= 0.0:
			return
		_srv_total = total
		if boss == null or not is_instance_valid(boss) or boss.dead:
			return
		_reborn_by_others = true
		_rebirths(boss, got)
		_reborn_by_others = false
		boss.hp -= got
		_others_sum += got
		_others_t = 4.0
		if _bar != null:
			(_bar as LayerBar).hit = 1.0)



func hero_fell() -> void :
	if state == "fight":
		_finish(tr("¡Caíste!"))


func _process(delta: float) -> void :
	if world == null or not world.running or world.get_tree().paused:
		return
	if state != "fight":
		_refresh_ui()
		return
	left -= delta
	_presence(delta)
	_sync(delta)
	_hp_pulse = maxf(0.0, _hp_pulse - delta * 4.0)
	_others_t = maxf(0.0, _others_t - delta)
	_refresh_ui()
	if left <= 0.0:
		_finish(tr("¡Tiempo!"))




func _presence(delta: float) -> void :
	if boss == null or not is_instance_valid(boss) or boss.dead:
		return
	var moved: = _last_pos != Vector3.INF and boss.position.distance_squared_to(_last_pos) > 0.0004
	_last_pos = boss.position
	_ghost_t -= delta
	if moved and _ghost_t <= 0.0:
		_ghost_t = 0.09
		world.raid._afterimage()
	_step_t -= delta
	if moved and _step_t <= 0.0:
		_step_t = 0.55
		world.shake(0.12)
		Vfx.ring(world.fx_root, boss.position, 2.4, Color(0.55, 0.45, 0.4, 0.6), 0.35)


func _finish(word: String) -> void :
	state = "done"
	var res: = {"dmg": dealt, "kills0": kills0, "kills": kills, "boss": mvp, "word": word, "week": str(st.get("week", "")), 
		"time": clampi(roundi(GameData.WB_TIME - maxf(0.0, left)), 5, 240), "party": world.heroes.size() > 1, "build": build_name}
	left = 0.0
	world.hud.announce(word, Color(1.0, 0.75, 0.4), tr("Daño: %s") % Leaderboard.big_text(dealt))
	world.play_sound("job_levelup", 0.0, -2.0)
	world.raid._clear_mechanics()
	world.raid.state = "won"
	if boss != null and is_instance_valid(boss) and not boss.dead:
		boss.hold = 999.0
	world.get_tree().create_timer(1.6, false).timeout.connect( func(): world.menus.show_world_boss_result(res))




func _build_ui() -> void :
	_layer = CanvasLayer.new()
	_layer.layer = 4
	world.add_child(_layer)
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(root)
	var col: = VBoxContainer.new()
	col.anchor_left = 0.5
	col.anchor_right = 0.5
	col.offset_left = -330
	col.offset_right = 330
	col.offset_top = 10
	col.add_theme_constant_override("separation", 3)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(col)
	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(head)
	var tag: = _label(tr("JEFE DEL MUNDO"), 12, Color(1.0, 0.55, 0.4))
	head.add_child(tag)
	_name_l = _label("", 16, Color(1.0, 0.95, 0.85))
	_name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_name_l)
	_layers_l = _label("", 18, Color(1.0, 0.85, 0.4))
	head.add_child(_layers_l)
	_bar = LayerBar.new()
	_bar.custom_minimum_size = Vector2(660, 22)
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_bar)

	var nums: = HBoxContainer.new()
	nums.add_theme_constant_override("separation", 8)
	nums.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(nums)
	_others_l = _label("", 13, Color(0.75, 0.85, 1.0))
	_others_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nums.add_child(_others_l)
	_hp_l = _label("", 13, Color(1.0, 0.93, 0.8))
	nums.add_child(_hp_l)


	_sg_row = HBoxContainer.new()
	_sg_row.add_theme_constant_override("separation", 8)
	_sg_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_sg_row)
	_sg_bar = ProgressBar.new()
	_sg_bar.show_percentage = false
	_sg_bar.max_value = 1.0
	_sg_bar.custom_minimum_size = Vector2(0, 7)
	_sg_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sg_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_sg_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sg_bg: = StyleBoxFlat.new()
	sg_bg.bg_color = Color(0.1, 0.08, 0.14, 0.9)
	sg_bg.set_corner_radius_all(3)
	_sg_fill = StyleBoxFlat.new()
	_sg_fill.bg_color = Color(1.0, 0.78, 0.22)
	_sg_fill.set_corner_radius_all(3)
	_sg_bar.add_theme_stylebox_override("background", sg_bg)
	_sg_bar.add_theme_stylebox_override("fill", _sg_fill)
	_sg_row.add_child(_sg_bar)
	_sg_label = _label(tr("Aguante"), 12, Color(1.0, 0.82, 0.4))
	_sg_row.add_child(_sg_label)
	_sg_row.visible = false
	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(foot)
	_timer_l = _label("", 15, Color(0.9, 0.95, 1.0))
	foot.add_child(_timer_l)
	_dealt_l = _label("", 15, Color(1.0, 0.8, 0.5))
	_dealt_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_dealt_l)
	_cond_row = HBoxContainer.new()
	_cond_row.add_theme_constant_override("separation", 6)
	_cond_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_cond_row)
	for c in conds():
		var chip: = PanelContainer.new()
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.06, 0.12, 0.8)
		sb.border_color = cond_color(c[0], c[1])
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 6
		sb.content_margin_right = 6
		chip.add_theme_stylebox_override("panel", sb)
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(_label(cond_text(c[0], c[1]), 11, cond_color(c[0], c[1]).lightened(0.3)))
		_cond_row.add_child(chip)
	_refresh_ui()


func _label(text: String, size: int, color: Color) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", Hud.RO_FONT_BOLD)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.08, 0.95))
	l.add_theme_constant_override("outline_size", 5)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _refresh_ui() -> void :
	if _name_l == null:
		return
	_name_l.text = boss_title()
	var hp: = boss.hp if boss != null and is_instance_valid(boss) else maxf(1.0, need - float(st.get("into", 0.0)))
	var max_hp: = boss.max_hp if boss != null and is_instance_valid(boss) else need
	var per: = max_hp / float(GameData.WB_LAYERS)
	var layer: = clampi(ceili(hp / per), 1, GameData.WB_LAYERS)
	_layers_l.text = "x%d" % layer
	var bar: LayerBar = _bar
	bar.pos = clampf(hp / per, 0.0, float(GameData.WB_LAYERS))

	var txt: = tr("Vida") + "  " + full_digits(hp)
	if txt != _hp_text:

		if _hp_text != "" and _hp_pulse < 0.35:
			_hp_pulse = 1.0
		_hp_text = txt
		_hp_l.text = txt
	_hp_l.add_theme_color_override("font_color", Color(1.0, 0.93, 0.8).lerp(Color(1.0, 1.0, 1.0), _hp_pulse))
	_hp_l.scale = Vector2.ONE * (1.0 + 0.06 * _hp_pulse)
	_hp_l.pivot_offset = _hp_l.size * Vector2(1.0, 0.5)
	if _others_t > 0.0:
		_others_l.text = tr("Otros jugadores: -%s") % Leaderboard.big_text(_others_sum)
		_others_l.modulate.a = clampf(_others_t, 0.0, 1.0)
	else:
		_others_l.text = ""
		_others_sum = 0.0
	if _layer_seen != -1 and layer < _layer_seen:
		bar.flash = 1.0
		if layer % 10 == 0 and boss != null and is_instance_valid(boss):
			Vfx.column(world.fx_root, boss.position, Color(1.0, 0.9, 0.6))
			world.play_sound("guard_break", 0.0, -6.0)
	_layer_seen = layer

	if boss != null and is_instance_valid(boss) and not boss.dead:
		var sg: Dictionary = world.stagger.gauge(world, boss)
		_sg_row.visible = float(sg.k) >= 0.0
		if _sg_row.visible:
			_sg_bar.value = 0.0 if sg.broken else 1.0 - float(sg.k)
			var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.02)
			_sg_fill.bg_color = Color(1.0, 1.0, 0.85).lerp(Color(1.0, 0.78, 0.22), pulse * 0.5) if sg.broken else Color(1.0, 0.78, 0.22)
			_sg_label.text = tr("¡ROTO!") if sg.broken else tr("Aguante")
			_sg_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.25) if sg.broken else Color(1.0, 0.82, 0.4))
	_timer_l.text = "%d:%02d" % [int(maxf(0.0, left)) / 60, int(maxf(0.0, left)) % 60]
	_dealt_l.text = tr("Tu daño: %s") % Leaderboard.big_text(dealt)




static func full_digits(v: float) -> String:
	var s: = String.num(maxf(0.0, floorf(v)), 0)
	var out: = ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return s + out






class LayerBar extends Control:
	const COLORS: = [Color(0.85, 0.2, 0.25), Color(0.95, 0.55, 0.2), Color(0.9, 0.8, 0.25), Color(0.35, 0.75, 0.35), 
		Color(0.25, 0.6, 0.9), Color(0.5, 0.35, 0.85), Color(0.85, 0.35, 0.7)]

	var pos: = 100.0
	var shown: = -1.0
	var trail: = -1.0
	var _trail_wait: = 0.0
	var flash: = 0.0
	var hit: = 0.0

	func _process(delta: float) -> void :
		if shown < 0.0:
			shown = pos
			trail = pos


			queue_redraw()
		var moving: = absf(shown - pos) > 1e-05 or trail > shown + 1e-05
		shown = pos if absf(shown - pos) < 0.0005 else lerpf(shown, pos, 1.0 - exp(-8.0 * delta))
		if trail < shown:
			trail = shown
		elif trail > shown:
			if absf(shown - pos) > 0.002:
				_trail_wait = 0.35
			_trail_wait -= delta
			if _trail_wait <= 0.0:
				trail = maxf(shown, trail - maxf(0.05, (trail - shown) * 2.5) * delta)
		if flash > 0.0:
			flash = maxf(0.0, flash - delta * 3.0)
		if hit > 0.0:
			hit = maxf(0.0, hit - delta * 6.0)
		if moving or flash > 0.0 or hit > 0.0:
			queue_redraw()

	func _draw() -> void :
		var p: = maxf(shown, 0.0)
		var layer: = clampi(ceili(p - 1e-06), 1, 100)
		var frac: = clampf(p - (layer - 1), 0.0, 1.0)

		if hit > 0.0:
			draw_set_transform(Vector2(randf_range(-2.0, 2.0), randf_range(-1.0, 1.0)) * hit)
		var r: = Rect2(Vector2.ZERO, size)
		var w: = size.x - 4
		draw_rect(r, Color(0.05, 0.03, 0.08, 0.92))
		var top: Color = COLORS[layer % COLORS.size()]
		var under: Color = COLORS[(layer - 1) % COLORS.size()] if layer > 1 else Color(0.12, 0.1, 0.16)
		draw_rect(Rect2(Vector2(2, 2), size - Vector2(4, 4)), under.darkened(0.35))

		if trail > p:
			var tf: = 1.0 if ceili(trail - 1e-06) > layer else clampf(trail - (layer - 1), 0.0, 1.0)
			if tf > frac:
				draw_rect(Rect2(Vector2(2 + w * frac, 2), Vector2(w * (tf - frac), size.y - 4)), Color(1.0, 0.95, 0.85, 0.75))
		draw_rect(Rect2(Vector2(2, 2), Vector2(w * frac, size.y - 4)), top.lightened(0.25 * hit))
		draw_rect(Rect2(Vector2(2, 2), Vector2(w * frac, (size.y - 4) * 0.4)), Color(1, 1, 1, 0.18))

		if hit > 0.0:
			var x: = 2 + w * frac
			draw_rect(Rect2(Vector2(x - 3, 1), Vector2(6, size.y - 2)), Color(1, 1, 1, 0.85 * hit))
			draw_rect(Rect2(Vector2(x - 8, 0), Vector2(16, size.y)), Color(1.0, 0.9, 0.6, 0.25 * hit))
		if flash > 0.0:
			draw_rect(r, Color(1, 1, 1, 0.5 * flash))
		draw_rect(r, Color(0.95, 0.75, 0.4), false, 2.0)
		draw_set_transform(Vector2.ZERO)
