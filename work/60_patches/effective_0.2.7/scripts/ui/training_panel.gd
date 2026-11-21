class_name TrainingPanel
extends VBoxContainer






const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")

var world: World
var _built_for: = ""


const RESTART_CONFIRM: = 3.0
var _restart_btn: Button
var _element_btn: Button
var _hit_btn: Button
var _restart_armed: = 0.0



static var _folded: = -1


func setup(p_world: World) -> void :
	world = p_world
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void :
	visible = world != null and world.running and world.training and not world.festival_mode
	if not visible:
		return
	if _restart_armed > 0.0:
		_restart_armed -= delta
		if _restart_armed <= 0.0 and is_instance_valid(_restart_btn):
			_restart_btn.text = tr("Reiniciar todo")
	var who: = "client" if world.net.is_client() else "leader"
	if _built_for != who:
		_build(who)




func _restart() -> void :
	if _restart_armed <= 0.0:
		_restart_armed = RESTART_CONFIRM
		if is_instance_valid(_restart_btn):
			_restart_btn.text = tr("¿Seguro? Pulsa otra vez")
		return
	_restart_armed = 0.0
	_built_for = ""
	world.restart_training()



func _load_build() -> void :
	world.menus.ui_click()
	if Save.tower_builds().is_empty():
		world.hud.announce(tr("No tienes builds guardadas."), Color(1.0, 0.8, 0.4))
		return
	world.get_tree().paused = true
	world.menus._builds_manager( func(): world.get_tree().paused = false, func(b: Dictionary):
		_built_for = ""
		world.get_tree().paused = false
		world.training_load_build(b))




func _element_text() -> String:
	return tr("Elemento: %s") % tr(str(GameData.ELEMENT_NAMES.get(world.training_element, "Neutral")))


func _next_element() -> void :
	world.training_next_element()
	if is_instance_valid(_element_btn):
		_element_btn.text = _element_text()


func _hit_text() -> String:
	return tr("Golpe: %s") % RoBasicWindow._thousands(int(world.training_hit))


func _next_hit() -> void :
	world.training_next_hit()
	if is_instance_valid(_hit_btn):
		_hit_btn.text = _hit_text()



func _priority() -> void :
	world.menus.ui_click()
	world.get_tree().paused = true
	world.menus.show_pick_order()




func _prefs() -> void :
	world.menus.ui_click()
	world.get_tree().paused = true
	var p: Player = world.player
	Menus.RunPrefs.open(world.menus, p.class_id, false, func():
		world.get_tree().paused = false
		if not is_instance_valid(p):
			return
		p.banished.assign(Player.saved_bans(p.class_id))
		p.run_favs.assign(Player.saved_favs(p.class_id).slice(0, GameData.RUN_FAV_MAX))
		p.offer = [])


func _build(who: String) -> void :
	_built_for = who
	for c in get_children():
		c.queue_free()
	var w: = UiStyles.hud_window(tr("Entrenamiento"), FONT_BOLD)
	(w.root as Control).custom_minimum_size.x = 176
	add_child(w.root)
	var body: VBoxContainer = w.body
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	if _folded < 0:
		_folded = 1 if MouseWalk.touch() else 0
	var fold: = world.menus._ro_button((tr("Entrenamiento") + "  ▼") if _folded == 1 else (tr("Ocultar") + "  ▲"), func():
		_folded = 1 - _folded
		_build(who))
	fold.focus_mode = Control.FOCUS_NONE
	body.add_child(fold)
	if _folded == 1:
		return
	var rows: Array = []
	if who == "leader":
		rows = [
			[[tr("+1 muñeco"), func(): world.training_dummies(1)], [tr("+20 muñecos"), func(): world.training_dummies(GameData.TRAINING_GROUP)]], 
			[[tr("+1 muñeco MVP"), func(): world.training_dummies(1, true)], [tr("+1 que pega"), func(): world.training_dummies(1, false, true)]], 
			[[_element_text(), _next_element], [_hit_text(), _next_hit]], 
			[[tr("Quitar muñecos"), func(): world.training_clear()], [tr("Reiniciar daño"), func(): world.reset_meter()]], 
			[[tr("+1 nivel"), func(): world.training_levels(1)], [tr("+10 niveles"), func(): world.training_levels(10, true)]], 



			[[tr("Prioridad"), _priority], [tr("Destierros"), _prefs]], 




			[[tr("Pactos"), func(): world.menus.show_training_setup("pacts")], [tr("Platos"), func(): world.menus.show_training_setup("dishes")]], 
			[[tr("Álbum"), func(): world.menus.show_training_setup("album")], [tr("Equipo inicial"), func(): world.menus.show_training_setup("gear")]], 

			[[tr("Cargar build"), _load_build], [tr("Reiniciar todo"), _restart]], 
		]
	rows.append([[tr("Armería"), func(): world.menus.show_armory()], [tr("Equipo"), func(): world.menus.show_equipment()]])
	rows.append([[tr("Volver a Prontera"), func(): world.leave_training()]])
	for r in rows:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 3)
		body.add_child(row)
		for b in r:
			var btn: Button = world.menus._ro_button(str(b[0]), b[1])
			btn.focus_mode = Control.FOCUS_NONE
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(btn)
			if b[1] == _load_build:
				btn.tooltip_text = tr("Una build guardada (Endless Tower, Emperium Festival) en un héroe nuevo de su clase: su nivel, habilidades, estadísticas y equipo. No se gasta.")
			if b[1] == _restart:
				_restart_btn = btn
			elif b[1] == _next_element:
				_element_btn = btn
			elif b[1] == _next_hit:
				_hit_btn = btn
			if str(b[0]) == tr("+10 niveles"):
				btn.tooltip_text = tr("Se eligen solas, como con «Elegir al azar»: tu prioridad de mejoras, tus destierros y tus favoritas.")
			elif b[1] == _priority:
				btn.tooltip_text = tr("Prioridad de mejoras")
			elif b[1] == _prefs:
				btn.tooltip_text = tr("Destierros y favoritas")
	var hint: = Label.new()
	hint.text = tr("El medidor de daño (derecha) mide tu daño por segundo.") if who == "leader"\
	else tr("El líder del grupo maneja los muñecos y los niveles.")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size.x = 168
	hint.add_theme_font_override("font", UiKit.FONT_BODY)
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color(0.25, 0.25, 0.3))
	body.add_child(hint)
