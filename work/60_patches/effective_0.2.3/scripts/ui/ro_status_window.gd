class_name RoStatusWindow
extends Control





const ROOT: = "res://assets/ro/ui/skin/basic_interface/"
const SIZE: = Vector2(280, 120)
const TITLE_H: = 17.0
const ROW_Y: = [6, 22, 38, 54, 70, 86]
const STATS: = ["str", "agi", "vit", "int", "dex", "luk"]

var player: Player

var show_title: = true
var _bg: Texture2D
var _title: Texture2D
var _font: Font = preload("res://assets/ro/fonts/SCDream4.otf")
var _bold: Font = preload("res://assets/ro/fonts/SCDream6.otf")


func _ready() -> void :
	var sz: = SIZE if show_title else SIZE - Vector2(0, TITLE_H)
	custom_minimum_size = sz
	size = sz
	texture_filter = RoAssets.ui_filter()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg = _load("statwin0_bg")
	_title = _load("titlebar_fix")


	var top: = TITLE_H if show_title else 0.0
	for i in STATS.size():
		_zone(Rect2(3, top + ROW_Y[i] - 1, 101, 15), STATS[i])
	for i in 4:
		_zone(Rect2(116, top + 3 + i * 16, 79, 15), ["atk", "matk", "hit", "crit"][i])
		_zone(Rect2(198, top + 3 + i * 16, 78, 15), ["def", "mdef", "flee", "aspd"][i])
	_refresh_zones()


var _zones: = {}


func _zone(r: Rect2, key: String) -> void :
	var z: = Control.new()
	z.position = r.position
	z.size = r.size
	z.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(z)
	_zones[key] = z



func _refresh_zones() -> void :
	if player == null:
		return
	for key in _zones:
		(_zones[key] as Control).set_meta("hover", _info(str(key)))


const TIP_COLOR: = Color(0.35, 0.5, 0.9)



static func _split() -> bool:
	return GameData.get_script().get_script_constant_map().has("SKILL_SCALE")




const AURA_COLOR: = Color(0.5, 0.3, 0.8)
func _aura_bonus(key: String) -> int:
	if player == null or not key in ["str", "int"]:
		return 0

	return roundi(player.buff_stat_worth(key) * GameData.RO_STAT_PER_PICK)


func _info(key: String) -> Dictionary:
	var p: = player
	var pct: = func(v: float) -> String: return "%d%%" % roundi(v * 100.0)
	if GameData.STATS.has(key):
		var s: Dictionary = GameData.STATS[key]
		var picks: = int(p.stats[key])
		var lines: = [[tr("Valor"), str(p.ro_stat(key) + _aura_bonus(key))]]
		if picks > 0:
			lines.append([tr("Puntos puestos"), "+%d" % picks])
		if _aura_bonus(key) > 0:
			lines.append([tr("Ninja Aura"), "+%d" % _aura_bonus(key), AURA_COLOR])
		return {"title": "%s  ·  %s" % [tr(str(s.name)), tr(str(s.full))], "color": TIP_COLOR, "lines": lines, "desc": tr(str(s.desc))}
	match key:
		"atk":
			return {"title": tr("Ataque"), "color": TIP_COLOR, 
				"desc": tr("El daño de tu ataque básico: el del arma más tu FUE (o tu INT, si tu clase pega con magia), por tus bonus de daño.") if _split()
					else tr("El daño de tu ataque básico: el del arma más tu FUE, por tus bonus de daño. No cambia el de tus habilidades.")}
		"matk":
			return {"title": tr("Ataque mágico"), "color": TIP_COLOR, 
				"desc": tr("INT × 2, de referencia. Lo que cuenta es la INT: sube el daño, el área y el doble lanzamiento de las habilidades mágicas.") if _split()
					else tr("INT × 2, de referencia. Lo que cuenta es la INT: sube el daño, el área y el doble lanzamiento de todas tus habilidades.")}
		"hit":
			return {"title": tr("Precisión"), "color": TIP_COLOR, 
				"desc": tr("Nivel + DES, de referencia: tus golpes no fallan nunca. Un elemento malo contra el monstruo les quita daño, pero siempre pegan.")}
		"crit":
			var lines: = [[tr("Probabilidad"), "%s  (%s 100%%)" % [pct.call(p.crit), tr("máx.")], CAP_COLOR if at_cap("crit") else null], 
				[tr("Daño crítico"), "×%.2f" % p.crit_dmg]]
			if p.crit_over > 0.0:
				lines.append([tr("Pasado del 100%"), "+%s %s" % [pct.call(p.crit_over * GameData.CRIT_OVERFLOW_DMG), tr("daño crítico")], Color(0.85, 0.5, 0.1)])
			return {"title": tr("Crítico"), "color": TIP_COLOR, "lines": lines, 
				"desc": tr("Probabilidad de golpe crítico, hasta el 100%%. Lo que pasa del 100%% no se pierde: cada 1%% de más es +%d%% de daño crítico.") % roundi(GameData.CRIT_OVERFLOW_DMG)
					+ "\n" + tr("Con daño crítico ×%s todos tus críticos son ultra (×%s); con ×%s, uno de cada 4 es letal (×%s más y explota alrededor).") % [
						str(GameData.ULTRA_CRIT_AT), str(GameData.ULTRA_CRIT_BONUS), str(GameData.LETHAL_CRIT_AT), str(GameData.LETHAL_CRIT_BONUS)]}
		"def":
			return {"title": tr("Defensa"), "color": TIP_COLOR, "lines": [[tr("Daño que te quita"), pct.call(p.damage_reduction())]], 
				"desc": tr("Reduce todo el daño que recibes: Def ÷ (Def + %d). Cada punto rinde algo menos que el anterior.") % roundi(GameData.DEF_K)}
		"mdef":
			return {"title": tr("Defensa mágica"), "color": TIP_COLOR, 
				"desc": tr("INT ÷ 2, de referencia. Contra la magia también te protege la Def.")}
		"flee":
			var lines: = [[tr("Esquiva"), "%s  (%s %s)" % [pct.call(p.dodge), tr("máx."), pct.call(GameData.FLEE_CAP)], CAP_COLOR if at_cap("flee") else null], 
				[tr("Lucky"), "%s  (%s %s)" % [pct.call(p.perfect_dodge), tr("máx."), pct.call(GameData.PERFECT_DODGE_CAP)], CAP_COLOR if at_cap("lucky") else null]]
			if p.block_chance() > 0.0:
				lines.append([tr("Bloqueo"), "%s  (%s %s)" % [pct.call(p.block_chance()), tr("máx."), pct.call(GameData.BLOCK_MAX)], CAP_COLOR if at_cap("block") else null])
			return {"title": tr("Esquiva"), "color": TIP_COLOR, "lines": lines, 
				"desc": tr("Probabilidad de que un golpe falle. Los jefes ignoran la mitad, los MVP el %s, y las mecánicas (rayos, zonas marcadas, peligros del Infierno) no se esquivan.") % pct.call(GameData.MVP_FLEE_IGNORE)
					+ "\n" + tr("El Lucky (SUE) esquiva cualquier cosa, también las mecánicas.")}
		"aspd":
			var top_aspd: = 200.0 - GameData.MIN_ATTACK_DELAY / 0.02
			var lines: = [[tr("ASPD"), "%d  (%s %d)" % [roundi(p.aspd()), tr("máx."), roundi(top_aspd)], CAP_COLOR if at_cap("aspd") else null], 
				[tr("Ataques por segundo"), "%.1f" % (1.0 / p.attack_delay())]]
			if p.swing_hits() >= 1.05:
				lines.append([tr("Golpes por ataque"), "×%.1f" % p.swing_hits(), Color(0.85, 0.5, 0.1)])
			return {"title": tr("Velocidad de ataque"), "color": TIP_COLOR, "lines": lines, 
				"desc": tr("Cuanto más cerca de 200, más rápido pega tu ataque básico. El tope es %d (un ataque cada %s s).") % [roundi(top_aspd), str(GameData.MIN_ATTACK_DELAY)]
					+ "\n" + tr("Lo que pasa del tope no se pierde: cada ataque golpea varias veces (el ×N junto al ASPD).")}
	return {}



const CAP_COLOR: = Color(0.85, 0.12, 0.12)





func at_cap(key: String) -> bool:
	var p: = player
	if p == null:
		return false
	match key:
		"crit":
			return p.crit >= 0.9995
		"flee":
			return p.dodge >= GameData.FLEE_CAP - 0.0005
		"lucky":
			return p.perfect_dodge >= GameData.PERFECT_DODGE_CAP - 0.0005
		"block":
			return p.block_chance() >= GameData.BLOCK_MAX - 0.0005
		"aspd":
			return p.attack_delay() <= GameData.MIN_ATTACK_DELAY + 1e-05
	return false


func _load(file: String) -> Texture2D:
	return Lang.ui_tex(ROOT + file + ".png")


func _draw() -> void :
	if not show_title:
		draw_set_transform(Vector2(0, - TITLE_H))


	if show_title:
		var body: = StyleBoxFlat.new()
		body.bg_color = Color(0.975, 0.98, 1.0)
		body.border_color = Color(0.7, 0.76, 0.9)
		body.set_border_width_all(1)
		body.set_corner_radius_all(7)
		body.anti_aliasing = true
		draw_style_box(body, Rect2(Vector2.ZERO, SIZE))
		var title: = StyleBoxFlat.new()
		title.bg_color = Color(0.8, 0.86, 0.97)
		title.corner_radius_top_left = 6
		title.corner_radius_top_right = 6
		title.border_color = Color(0.58, 0.66, 0.86)
		title.border_width_bottom = 1
		title.anti_aliasing = true
		draw_style_box(title, Rect2(1, 1, SIZE.x - 2, TITLE_H - 1))
		draw_string(_bold, Vector2(9, 12), tr("Estado"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.12, 0.18, 0.4))
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0.945, 0.955, 0.99)
	box.border_color = Color(0.8, 0.84, 0.93)
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.anti_aliasing = true
	for i in STATS.size():
		draw_style_box(box, Rect2(3, TITLE_H + ROW_Y[i] - 1, 101, 15))
	var line: = Color(0.84, 0.87, 0.95)
	for i in 4:
		var y: float = TITLE_H + 16 + i * 16 + 1
		draw_line(Vector2(118, y), Vector2(193, y), line, 1.0)
		draw_line(Vector2(200, y), Vector2(274, y), line, 1.0)
	draw_line(Vector2(118, TITLE_H + 81), Vector2(274, TITLE_H + 81), line, 1.0)
	draw_line(Vector2(118, TITLE_H + 97), Vector2(274, TITLE_H + 97), line, 1.0)
	if player == null:
		return
	_refresh_zones()

	var labels: = [tr("FUE"), tr("AGI"), tr("VIT"), tr("INT"), tr("DES"), tr("SUE")]
	for i in STATS.size():
		var y: float = TITLE_H + ROW_Y[i] + 10
		draw_string(_bold, Vector2(8, y), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.3, 0.38, 0.62))

		var aura: = _aura_bonus(STATS[i])
		draw_string(_font, Vector2(36, y), str(player.ro_stat(STATS[i]) + aura), HORIZONTAL_ALIGNMENT_RIGHT, 36, 11, 
			AURA_COLOR if aura > 0 else Color(0.1, 0.13, 0.24))
		var picks: = int(player.stats[STATS[i]])
		draw_string(_font, Vector2(76, y), "+%d" % picks if picks > 0 else "", HORIZONTAL_ALIGNMENT_CENTER, 12, 9, Color(0.2, 0.45, 0.2))

	var left: = [[tr("Atq"), "%d" % roundi(player.basic_atk() * player.dmg_mult * _floor_mult())], 
		[tr("Matq"), "%d" % (player.ro_stat("int") * 2)], 
		[tr("Prec"), "%d" % (player.level + player.ro_stat("dex"))], 
		[tr("Crít"), ("%d" % roundi(player.crit * 100.0)) if player.crit_over <= 0.0 else "100 +%d%%" % roundi(player.crit_over * 100.0 * GameData.CRIT_OVERFLOW_DMG)]]
	var right: = [[tr("Def"), "%d (%d%%)" % [roundi(player.armor), roundi(player.damage_reduction() * 100.0)]], 
		[tr("Mdef"), "%d" % roundi(player.ro_stat("int") / 2.0)], 
		[tr("Flee"), "%d%%" % roundi(player.dodge * 100.0)], 
		[tr("ASPD"), ("%d" % roundi(player.aspd())) if player.swing_hits() < 1.05 else
			("%d ×%.1f" if player.swing_hits() < 10.0 else "%d ×%d") % [roundi(player.aspd()), player.swing_hits()]]]

	var capped: = {3: at_cap("crit")}
	var capped_r: = {2: at_cap("flee"), 3: at_cap("aspd")}
	for i in 4:
		var y: float = TITLE_H + 16 + i * 16 - 2
		_value(Vector2(118, y), 75, left[i][0], left[i][1], CAP_COLOR if capped.get(i, false) else VALUE_COLOR)
		_value(Vector2(200, y), 74, right[i][0], right[i][1], CAP_COLOR if capped_r.get(i, false) else VALUE_COLOR)
	_value(Vector2(118, TITLE_H + 79), 156, tr("Nivel base"), str(player.level))
	_value(Vector2(118, TITLE_H + 95), 156, tr("Oficio"), player.job_name())


const VALUE_COLOR: = Color(0.1, 0.13, 0.24)


func _value(at: Vector2, width: float, label: String, value: String, color: = VALUE_COLOR) -> void :
	draw_string(_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.35, 0.37, 0.45))

	var room: = width - _font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x - 3.0
	var size: = 11
	while size > 7 and _bold.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > room:
		size -= 1
	draw_string(_bold, at, value, HORIZONTAL_ALIGNMENT_RIGHT, width, size, color)




func _floor_mult() -> float:
	var n: Node = player
	while n != null and not (n is World):
		n = n.get_parent()
	var w: = n as World
	if w != null and w.tower != null and is_instance_valid(w.tower):
		return w.tower.hero_mult()
	return 1.0
