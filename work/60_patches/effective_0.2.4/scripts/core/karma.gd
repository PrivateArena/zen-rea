class_name Karma
extends Node























var world: World

var value: = 0

var route: = ""

var path: = ""


var boon: = ""
var boons: = 0

var won_here: = false

var my_altars: Array[String] = []


var hel_marks: = 0
var feathers: = 0

var _demon_t: = 0.0
var _altar_t: = 0.0
var _veil_layer: CanvasLayer
var _veil: ColorRect
var _veil_mat: ShaderMaterial
var _shown: = 0
static var _veil_shader: Shader


func _ready() -> void :
	name = "Karma"
	_veil_layer = CanvasLayer.new()

	_veil_layer.layer = -1
	add_child(_veil_layer)
	_veil = ColorRect.new()
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _veil_shader == null:
		_veil_shader = Shader.new()
		_veil_shader.code = "shader_type canvas_item;\r\nuniform vec4 col : source_color = vec4(1.0);\r\nuniform float strength = 0.0;\r\nvoid fragment() {\r\n\tvec2 p = UV * 2.0 - 1.0;\r\n\t// Only the very corners, softly (2026-11-11: the old veil, wider and\r\n\t// waving, was too much visual noise over the fight).\r\n\tfloat edge = smoothstep(0.85, 1.6, length(p * vec2(1.0, 1.25)));\r\n\tfloat pulse = 0.92 + 0.08 * sin(TIME * 1.2);\r\n\tCOLOR = vec4(col.rgb, clamp(edge * strength * pulse, 0.0, 0.4));\r\n}"










	_veil_mat = ShaderMaterial.new()
	_veil_mat.shader = _veil_shader
	_veil.material = _veil_mat
	_veil.visible = false
	_veil_layer.add_child(_veil)


func reset() -> void :
	value = 0
	route = ""
	path = ""
	boon = ""
	boons = 0
	won_here = false
	my_altars.clear()
	hel_marks = 0
	feathers = 0
	_demon_t = GameData.KARMA_DEMON_FROM
	_altar_t = GameData.KARMA_ALTAR_FROM
	_shown = 0
	_look()


func add(amount: int) -> void :
	value = clampi(value + amount, - GameData.KARMA_MAX, GameData.KARMA_MAX)
	world.net.karma(value)
	_look()



func side() -> String:
	return "light" if value > 0 else ("dark" if value < 0 else "")




func route_side() -> String:
	return path if path != "" else side()


func can_route() -> bool:
	return not won_here and route_side() != "" and not world.training and world.tower == null



func elite_mult() -> float:
	return GameData.KARMA_ELITE_MULT if value <= - GameData.KARMA_RICH else 1.0



func box_mult() -> float:
	return GameData.KARMA_BOX_MULT if value >= GameData.KARMA_RICH else 1.0




func _look() -> void :
	if _veil == null:
		return
	var k: = absi(value)
	_veil.visible = k >= GameData.KARMA_LOOK_FROM and world != null and world.running
	if not _veil.visible:
		return
	var f: = clampf(float(k - GameData.KARMA_LOOK_FROM) / float(GameData.KARMA_MAX - GameData.KARMA_LOOK_FROM), 0.0, 1.0)
	_veil_mat.set_shader_parameter("col", Color(0.55, 0.0, 0.04) if value < 0 else Color(1.0, 0.86, 0.45))
	_veil_mat.set_shader_parameter("strength", 0.15 + 0.25 * f)


func tick(delta: float, pace: float) -> void :
	if not world.running:
		_veil.visible = false
		return
	if _shown != value:
		_shown = value
		_look()
	elif not _veil.visible and absi(value) >= GameData.KARMA_LOOK_FROM:
		_look()
	_tick_boon(delta)
	if world.net.is_client() or world.training or world.tower != null or world.raid.active() or pace <= 0.0:
		return
	if world.time >= GameData.KARMA_DEMON_FROM:
		_demon_t -= delta * pace
		if _demon_t <= 0.0:
			_demon_t = randf_range(GameData.KARMA_DEMON_EVERY[0], GameData.KARMA_DEMON_EVERY[1])
			_spawn_demon()
	if world.time >= GameData.KARMA_ALTAR_FROM:
		_altar_t -= delta * pace
		if _altar_t <= 0.0:
			_altar_t = randf_range(GameData.KARMA_ALTAR_EVERY[0], GameData.KARMA_ALTAR_EVERY[1])
			if not world.altars.waiting.any( func(a): return GameData.ALTARS[a.id].has("karma")):
				world.altars.spawn(["baldur", "hel"].pick_random())




func _spawn_demon() -> void :
	if world.enemies.any( func(e): return e.special == "corrupto" and not e.dead):
		return
	var e: = world.spawn_enemy(str(GameData.KARMA_DEMONS.pick_random()), world._offscreen_point(), true, false, "corrupto")
	if e == null:
		return
	world.play_sound("curse", 0.0, -8.0)
	world.party_announce(TranslationServer.translate("¡Un demonio corrupto se acerca!"), GameData.CORRUPT_COLOR, 
		TranslationServer.translate("Véncelo: deja un Cofre Corrupto"))




func on_kill(e: Enemy, killer: Player) -> void :
	if route != "" and float(GameData.KARMA_ROUTES[route].get("foe_burst", 0.0)) > 0.0 and not e.is_boss:
		_burst(e.position, float(GameData.KARMA_ROUTES[route].foe_burst))
	if e.special == "corrupto" and not e.summoned:
		world._drop_chest(e.position, GameData.CORRUPT_CHEST_ROLLS, GameData.CORRUPT_CHEST_BONUS, "", false, true)
	if killer != null and is_instance_valid(killer) and not killer.downed:

		var n: int = boons if boon == "hel_pact" else 0
		n = maxi(n, int(killer.get_meta("hel_boons", 0)))
		if n > 0:
			killer.hp = minf(killer.max_hp, killer.hp + killer.max_hp * GameData.HEL_PACT_KILL_HEAL * n)




func chest_choice(at: Vector3, by: Player) -> void :
	if world.autopilot or world.menus.auto_pick:
		if randf() < 0.5:
			open_chest(at, by)
		else:
			purify_chest(at, by)
		return

	if by == null or by == world.player:
		var auto: int = world.menus.corrupt_auto()
		if auto >= 0:
			if auto == 1:
				open_chest(at, by)
			else:
				purify_chest(at, by)
			return

	if world.net.is_host() and by != null and by != world.player and world.net.ask_corrupt(by, at):
		return



	if by != null and is_instance_valid(by) and by != world.player:
		if randf() < 0.5:
			open_chest(at, by)
		else:
			purify_chest(at, by)
		return
	world.menus.show_corrupt_chest( func(): open_chest(at, by), func(): purify_chest(at, by), path)



func open_chest(at: Vector3, by: Player) -> void :
	if by == null or not is_instance_valid(by):
		by = world.player
	by.hp = maxf(1.0, by.hp - by.max_hp * GameData.CORRUPT_CHEST_HP)
	by.visual.flash()
	world.number(by.position + Vector3(0, 2.0, 0), TranslationServer.translate("−25% vida"), GameData.CORRUPT_COLOR, true)
	add( - GameData.KARMA_CHEST)
	world.spawn_fx("hell_in", at, 1.2, 1.0)
	Vfx.burst(world.fx_root, at, 3.0, GameData.CORRUPT_COLOR)
	world.play_sound("fire_pillar", 0.0, -2.0)

	if by == world.player:
		world.hud.flash(Color(GameData.CORRUPT_COLOR, 1.0), 0.3)
		world.shake(0.4)


	by.hel_marks += 1
	hel_marks += 1
	by.recompute()
	_level_up(by)
	world.label_over(by, TranslationServer.translate("Marca de Hel x%d  ·  +1 nivel") % by.hel_marks, GameData.CORRUPT_COLOR)



func purify_chest(at: Vector3, by: Player) -> void :
	if by == null or not is_instance_valid(by):
		by = world.player
	add(GameData.KARMA_CHEST)
	world.spawn_fx("holyhit", at + Vector3(0, 0.6, 0), 1.6, 1.0)
	Vfx.column(world.fx_root, at, GameData.PURE_COLOR)
	Vfx.burst(world.fx_root, at, 3.0, GameData.PURE_COLOR)
	world.play_sound("angelus", 0.0, -2.0)
	if by == world.player:
		world.hud.flash(Color(GameData.PURE_COLOR, 1.0), 0.25)


	by.feathers += 1
	feathers += 1
	by.recompute()
	_level_up(by)
	world.label_over(by, TranslationServer.translate("Pluma de Valquiria x%d  ·  +1 nivel") % by.feathers, GameData.PURE_COLOR)



func _level_up(by: Player) -> void :
	var need: = maxf(0.0, by.xp_need - by.xp) / maxf(0.0001, by.pace_xp * by.xp_mult)
	by.add_xp(need + 0.001)




func _burst(at: Vector3, pct: float) -> void :
	var r: = GameData.KARMA_BURST_RADIUS
	Vfx.ring(world.fx_root, at + Vector3(0, 0.08, 0), r, GameData.CORRUPT_COLOR, GameData.KARMA_BURST_DELAY)
	var warn: = Vfx.ground_glow(world.fx_root, at + Vector3(0, 0.05, 0), r * 1.1, Color(GameData.CORRUPT_COLOR, 0.45))
	world.get_tree().create_timer(GameData.KARMA_BURST_DELAY, false).timeout.connect( func():
		if is_instance_valid(warn):
			warn.queue_free()
		if not world.running:
			return
		world.spawn_fx("hell_in", at, 0.7, 0.8)
		for h in world.heroes:
			if not h.downed and h.hp > 0.0 and Vector2(h.position.x - at.x, h.position.z - at.z).length() < r:
				world.hurt_what = "Estallido corrupto"
				h.take_damage(h.max_hp * pct, world, null, true))





func take_altar(id: String, by: Player, restoring: = false) -> void :
	var d: Dictionary = GameData.ALTARS[id]
	var pm: Dictionary = d.get("mods", {})
	for k in ["dmg", "max_hp_pct"]:
		if pm.has(k):

			var key: String = "risk_dmg" if k == "dmg" else k
			by.altar_mods[key] = float(by.altar_mods.get(key, 0.0)) + float(pm[k])
	by.recompute()

	by.karma_altars.append(id)
	if by == world.player:
		my_altars.append(id)
		world.hud.refresh_altars()
	if restoring:
		return
	if pm.has("heal") and not by.downed:
		by.hp = by.max_hp
	by.hp = minf(by.hp, by.max_hp)
	add(GameData.KARMA_ALTAR * int(d.karma))





func enter_route() -> void :
	if not can_route():
		return
	route = route_side()
	path = route
	world.raid.start_route(str(GameData.KARMA_ROUTES[route].mvp))
	var kr: Dictionary = GameData.KARMA_ROUTES[route]
	world.get_tree().create_timer(4.0, false).timeout.connect( func():
		if route != "":
			world.hud.alerts.warn(TranslationServer.translate(str(kr.foes)), Color(kr.color).lightened(0.2), "warning"))



func route_won(e: Enemy) -> void :
	var r: Dictionary = GameData.KARMA_ROUTES[route]
	var uid: = str(r.unique)
	var p: = world.player


	var chance: = GameData.KARMA_UNIQUE_CHANCE * GameData.unique_mult(world.danger)
	if GameData.has_meta("force_unique"):
		chance = 1.0


	if randf() < chance:
		world._drop_chest(world.map.random_point_around(e.position, 1.2), 0, 2, uid)
	boon = str(r.boon)
	boons += 1
	won_here = true
	for h in world.heroes:
		if boon == "valhalla":
			h.revives += GameData.VALHALLA_REVIVES
			h.altar_mods["xp"] = float(h.altar_mods.get("xp", 0.0)) + GameData.VALHALLA_XP
			h.altar_mods["max_hp_pct"] = float(h.altar_mods.get("max_hp_pct", 0.0)) + GameData.VALHALLA_HP
			h.altar_mods["risk_dmg"] = float(h.altar_mods.get("risk_dmg", 0.0)) + GameData.VALHALLA_DMG
			h.recompute()
		else:
			h.altar_mods["risk_dmg"] = float(h.altar_mods.get("risk_dmg", 0.0)) + GameData.HEL_PACT_DMG
			h.recompute()
	var light: = boon == "valhalla"
	var title: = TranslationServer.translate("Bendición de Valhalla") if light else TranslationServer.translate("Pacto de Hel")
	if boons > 1:
		title = "%s  x%d" % [title, boons]
	world.party_announce(title, Color(r.color).lightened(0.2), 
		TranslationServer.translate("+1 vida, +20% de vida máxima, +20% de daño, +15% de EXP y un aura que te cura el resto de la partida") if light
			else TranslationServer.translate("+50% de daño, recibes +20% de daño y matar te cura"))
	route = ""


func _tick_boon(delta: float) -> void :
	for h in world.heroes:
		if h.downed or h.hp <= 0.0:
			continue


		var n: int = boons if boon == "valhalla" else 0
		n = maxi(n, int(h.get_meta("valhalla_boons", 0)))
		if n > 0:
			h.hp = minf(h.max_hp, h.hp + h.max_hp * GameData.VALHALLA_REGEN * n * delta)




func save_state() -> Dictionary:
	return {"value": value, "path": path, "boon": boon, "boons": boons, "altars": Array(my_altars), "hel_marks": hel_marks, "feathers": feathers}


func restore(d: Dictionary) -> void :
	value = int(d.get("value", 0))
	path = str(d.get("path", ""))
	boon = str(d.get("boon", ""))
	boons = int(d.get("boons", 1 if boon != "" else 0))
	hel_marks = int(d.get("hel_marks", 0))
	feathers = int(d.get("feathers", 0))
	for id in d.get("altars", []):
		if GameData.ALTARS.has(str(id)):
			take_altar(str(id), world.player, true)
	hero_boons(world.player, d)
	_look()





func hero_boons(h: Player, d: Dictionary) -> void :
	var b: = str(d.get("boon", ""))
	var n: = int(d.get("boons", 1 if b != "" else 0))



	h.set_meta("build_boon", [b, n])
	if b == "hel_pact":
		h.altar_mods["risk_dmg"] = float(h.altar_mods.get("risk_dmg", 0.0)) + GameData.HEL_PACT_DMG * n
		h.recompute()

		if h != world.player:
			h.set_meta("hel_boons", n)
	elif b == "valhalla":
		h.altar_mods["xp"] = float(h.altar_mods.get("xp", 0.0)) + GameData.VALHALLA_XP * n
		h.altar_mods["max_hp_pct"] = float(h.altar_mods.get("max_hp_pct", 0.0)) + GameData.VALHALLA_HP * n
		h.altar_mods["risk_dmg"] = float(h.altar_mods.get("risk_dmg", 0.0)) + GameData.VALHALLA_DMG * n
		h.recompute()
		if h != world.player:
			h.set_meta("valhalla_boons", n)





class Bar extends Control:
	var world: World
	var _drawn: = 999
	var _path: = "-"

	func _init() -> void :
		custom_minimum_size = Vector2(0, 16)
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		mouse_filter = Control.MOUSE_FILTER_PASS

	func _process(_d: float) -> void :
		var k: Karma = null if world == null else world.karma
		var v: = 0 if k == null else k.value
		var path: = "" if k == null else k.path
		if v != _drawn or path != _path:
			_drawn = v
			_path = path
			queue_redraw()
			tooltip_text = _tip(v, path)

	func _tip(v: int, path: String) -> String:
		var lean: = tr("En equilibrio") if v == 0 else (tr("Valhalla %d") % v if v > 0 else tr("Niflheim %d") % - v)
		var lines: Array[String] = [tr("Balanza de Midgard: %s") % lean, 
			tr("Purificar un Cofre Corrupto y los altares de Baldur la inclinan hacia Valhalla; abrir el cofre y los altares de Hel, hacia Niflheim."), 
			tr("Tras vencer al MVP se abre el portal de su lado: Valhalla → Valkyrie Reginleif, Niflheim → Randgris Caída (en equilibrio, ninguno)."), 
			tr("Muy inclinada, el mapa lo nota: más cajas con Valhalla, más Feroces con Niflheim.")]
		if path != "":
			lines.append(tr("Tu ruta ya está elegida: %s.") % ("Valhalla" if path == "light" else "Niflheim"))

		for side in ["light", "dark"]:
			if path == "" or path == side:
				lines.append("")
				lines.append(tr(str(GameData.KARMA_ROUTES[side].name)))
				lines.append(tr(str(GameData.KARMA_ROUTES[side].foes)))
				lines.append(tr("Por cada Valquiria vencida: %s") % (tr("+1 vida, +15% de EXP y un aura que te cura el resto de la partida") if side == "light"
					else tr("+50% de daño, recibes +20% de daño y matar te cura")))
		return """
""".join(lines)



	func _draw() -> void :
		var x0: = 16.0
		var w: = size.x - 32.0
		var y: = 7.0
		var h: = 6.0
		var mid: = x0 + w * 0.5
		var dark: = Color(0.72, 0.1, 0.16)
		var light: = Color(0.3, 0.55, 0.95)


		var well: = StyleBoxFlat.new()
		well.bg_color = Color(0.87, 0.9, 0.96)
		well.border_color = Color(0.66, 0.72, 0.87)
		well.set_border_width_all(1)
		well.set_corner_radius_all(4)
		well.anti_aliasing = true
		draw_style_box(well, Rect2(x0 - 1.0, y - 1.0, w + 2.0, h + 2.0))
		var f: = clampf(float(_drawn) / GameData.KARMA_MAX, -1.0, 1.0)
		var nx: = roundf(mid + w * 0.5 * f)
		if f != 0.0:
			var col: = dark if f < 0.0 else light
			var r: = Rect2(minf(mid, nx), y, absf(nx - mid), h)
			draw_rect(r, col)
			draw_rect(Rect2(r.position.x, y, r.size.x, 2.0), col.lightened(0.35))
			draw_rect(Rect2(r.position.x, y + h - 1.0, r.size.x, 1.0), col.darkened(0.3))

		for t in [-1.0, 1.0]:
			var tx: float = roundf(mid + w * 0.5 * t * float(GameData.KARMA_LOOK_FROM) / GameData.KARMA_MAX)
			draw_rect(Rect2(tx, y, 1.0, h), Color(0.4, 0.46, 0.62, 0.35))
		draw_rect(Rect2(roundf(mid), y - 1.0, 1.0, h + 2.0), Color(0.3, 0.38, 0.6, 0.8))

		for side in [["karma_cursed", 0.0], ["karma_holy", size.x - 12.0]]:
			var spr: = RoAssets.sprite([str(side[0])])
			if spr != null:
				draw_texture_rect(spr.get_frame(0, 0), Rect2(float(side[1]), 3.0, 12.0, 12.0), false)

		var tip: = Vector2(nx + 0.5, y + 2.0)
		var pts: = PackedVector2Array([tip, tip + Vector2(4.0, -6.0), tip + Vector2(-4.0, -6.0)])
		draw_colored_polygon(pts, Color(1, 1, 1))
		pts.append(pts[0])
		draw_polyline(pts, Color(0.1, 0.1, 0.16), 1.0)
