class_name Valhalla
extends Node3D








const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")
const MAP: = "valkyrie"




const ARRIVE_CELL: = Vector2i(49, 9)
const PORTAL_CELL: = Vector2i(49, 66)
const DAIS_CELL: = Vector2i(49, 78)
const BACK_PORTAL_CELL: = Vector2i(49, 73)
const BACK_ARRIVE_CELL: = Vector2i(49, 62)
const VALKYRIE_CELL: = Vector2i(49, 85)


const HERO_ROWS: = [33, 38, 42, 48, 55, 59]
const HERO_COLS: = [44, 53]
const WALK_SPEED: = 5.2
const TALK_RANGE: = 2.6
const REARM_RANGE: = 3.6
const PORTAL_RANGE: = 1.1

const PORTAL_LIFT: = 0.9


const AXIS_SHIFT: = Vector3(-0.5, 0, 0)

const CHEER_RANGE: = 5.0
const CHEER_EVERY: = 2.2
const NAME_COLOR: = Color(1.0, 0.9, 0.55)

const SKY_COLOR: = Color(0.42, 0.62, 0.88)
const CLOUD_TEXTURES: = ["cloud1", "cloud2", "cloud3", "cloud4", "cloud11"]
const CLOUDS: = 46

var world: World
var class_id: = ""
var hero: RoVisual
var valkyrie: RoVisual
var _ui: CanvasLayer
var _white: ColorRect
var _caption: Label
var _dialog: Control

var _done: = false

var _control: = false
var _armed: = true
var _portal_ready: = false
var _env: Environment
var _env_saved: = {}
var _clouds: Array[Dictionary] = []

var _heroes: Array[Dictionary] = []
var _cheer_clock: = 0.0



static func start(p_world: World, p_class: String) -> void :
	if not Save.can_rebirth(p_class):
		return
	p_world.leave_town()
	p_world.running = false
	p_world.get_tree().paused = false
	p_world.hud.hide()
	p_world.menus.close()
	for c in p_world.run_root.get_children():
		c.queue_free()
	p_world.player = null
	p_world._load_map(MAP)
	var v: = Valhalla.new()
	v.world = p_world
	v.class_id = p_class
	p_world.run_root.add_child(v)
	p_world.valhalla = v
	v._run()


func _exit_tree() -> void :
	if world != null and world.mouse_walk != null and world.mouse_walk.hero_override == hero:
		world.mouse_walk.hero_override = null
	if _env != null:
		for k in _env_saved:
			_env.set(k, _env_saved[k])


func _at(cell: Vector2i) -> Vector3:
	var c: = world.map.cell_center(cell.x, cell.y)
	return Vector3(c.x, world.map.height_at(c), c.z)


func _run() -> void :
	_build_ui()
	_build_sky()
	var d: Dictionary = GameData.CLASSES[class_id]
	hero = RoVisual.new()
	add_child(hero)
	hero.setup(RoAssets.styled_character(d.body, d.get("weapon", ""), d.get("weapon_fx", ""), 
		[d.get("attack", RoVisual.PC_ATTACK)], "", Save.look(class_id)), d.color, 44)
	hero.hold_idle = true
	hero.show_through()
	hero.position = _at(ARRIVE_CELL)
	hero.face(Vector3(0, 0, -1))
	hero.play(RoVisual.PC_IDLE)
	valkyrie = RoVisual.new()
	add_child(valkyrie)
	valkyrie.setup(RoAssets.sprite(["npc_valkyrie"]), Color(1, 0.9, 0.6), 48)
	valkyrie.position = _at(VALKYRIE_CELL) + AXIS_SHIFT + _center_shift(valkyrie)
	valkyrie.face(Vector3(0, 0, 1))
	valkyrie.play(RoVisual.MOB_IDLE)
	valkyrie.sprite.no_depth_test = true
	valkyrie.sprite.render_priority = 6
	_name_label(valkyrie, tr("Valkyrie"))


	var glow: = Sprite3D.new()
	glow.texture = RoAssets.radial(Color(1.0, 0.86, 0.5), 128)
	glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glow.shaded = false
	glow.transparent = true
	glow.no_depth_test = true
	glow.render_priority = 5
	glow.pixel_size = 4.2 / 128.0
	glow.modulate = Color(1, 1, 1, 0.6)
	glow.position = RoVisual.lift + Vector3(0, 1.2, 0)
	valkyrie.add_child(glow)
	var gt: = glow.create_tween().set_loops()
	gt.tween_property(glow, "modulate:a", 0.35, 1.2).set_trans(Tween.TRANS_SINE)
	gt.tween_property(glow, "modulate:a", 0.8, 1.2).set_trans(Tween.TRANS_SINE)
	_build_heroes()
	_portal(_at(PORTAL_CELL) + AXIS_SHIFT, Color(0.75, 0.88, 1.0), tr("Valkyrie"))
	_portal(_at(BACK_PORTAL_CELL) + AXIS_SHIFT, Color(0.75, 0.88, 1.0), "")
	world.place_camera(hero.position, 42.0)
	world.mouse_walk.reset()

	world.mouse_walk.hero_override = hero
	world.play_music_map(MAP)

	world.play_sound("portal", 0.0, -2.0)
	Vfx.column(world.fx_root, hero.position, Color(0.9, 0.95, 1.0))
	var tw: = create_tween()
	tw.tween_property(_white, "color:a", 0.0, 1.2)
	tw.tween_callback( func():
		_control = true
		_show_caption(tr("Valhalla  ·  Salón del Honor")))




func _process(delta: float) -> void :
	if world == null or world.camera == null:
		return
	delta = minf(delta, 0.05)
	_update_clouds(delta)
	if _control:
		var input: = Vector2.ZERO if HeroInput.typing(world) else\
		MouseWalk.screen_to_world(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
		if input != Vector2.ZERO:
			world.mouse_walk.cancel()
		else:
			input = world.mouse_walk.input_vector(hero.position)
		var move: = Vector3(input.x, 0, input.y)
		if move.length_squared() > 0.0001:
			var p: = world.map.slide(hero.position, move * WALK_SPEED * delta)
			hero.position = Vector3(p.x, world.map.height_at(p), p.z)
			hero.face(move)
			hero.play(RoVisual.PC_WALK)
		else:
			hero.play(RoVisual.PC_IDLE)
		world.mouse_walk.update_markers()
		_check_portals()
		_check_valkyrie()
		_cheer(delta)
	world._update_camera_on(hero.position, delta)


func _unhandled_input(event: InputEvent) -> void :
	if not _control:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_decline()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

		var at: = world.camera.unproject_position(valkyrie.position + RoVisual.world_lift() + Vector3(0, 1.0, 0))
		if at.distance_to(event.position) < 46.0 * maxf(1.0, get_viewport().get_visible_rect().size.y / 720.0):
			_armed = true
			world.mouse_walk.walk_to(valkyrie.position)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if world.mouse_walk.handle_input(event):
			get_viewport().set_input_as_handled()




func _check_portals() -> void :
	var near_up: = _flat(hero.position, _at(PORTAL_CELL) + AXIS_SHIFT) <= PORTAL_RANGE
	var near_back: = _flat(hero.position, _at(BACK_PORTAL_CELL) + AXIS_SHIFT) <= PORTAL_RANGE
	if not near_up and not near_back:
		_portal_ready = true
		return
	if not _portal_ready:
		return
	_portal_ready = false
	_warp_hero(DAIS_CELL if near_up else BACK_ARRIVE_CELL)


func _warp_hero(cell: Vector2i) -> void :
	world.mouse_walk.reset()
	Vfx.column(world.fx_root, hero.position, Color(0.85, 0.92, 1.0))
	world.play_sound("portal", 0.0, 0.0)
	world.play_sound("portal", 0.0, -2.0)
	hero.position = _at(cell)
	hero.face(Vector3(0, 0, -1))
	Vfx.column(world.fx_root, hero.position, Color(0.85, 0.92, 1.0))
	world.place_camera(hero.position, 42.0)




func _cheer(delta: float) -> void :
	for h in _heroes:
		if not h.cheered and _flat(hero.position, h.node.position) <= CHEER_RANGE:
			h.cheered = true
			var node: RoVisual = h.node
			node.face(hero.position - node.position)
			world.emote(node, ["love", "grats", "love", "heh"].pick_random(), 2.0)
	_cheer_clock += delta
	if _cheer_clock >= CHEER_EVERY and not _heroes.is_empty():
		_cheer_clock = 0.0
		var h: Dictionary = _heroes.pick_random()
		if _flat(hero.position, h.node.position) <= CHEER_RANGE * 3.0:
			world.emote(h.node, ["love", "grats", "ok", "heh"].pick_random(), 1.8)


func _check_valkyrie() -> void :
	var d: = _flat(hero.position, valkyrie.position)
	if d > REARM_RANGE:
		_armed = true
	elif d <= TALK_RANGE and _armed:
		_armed = false
		_control = false
		world.mouse_walk.reset()
		hero.play(RoVisual.PC_IDLE)
		hero.face(valkyrie.position - hero.position)
		world.emote(valkyrie, "surprise", 1.4)
		_talk(0)






func _talk(page: int) -> void :
	if _done:
		return
	var high: = tr(GameData.HIGH_NAMES.get(class_id, GameData.CLASSES[class_id].name))
	var pages: = [
		tr("Bienvenido a Valhalla, el Salón del Honor, donde descansan los héroes de Midgard."), 
		tr("Has reunido los fragmentos del corazón de Ymir y has probado tu valor ante los MVP."), 
		tr("Aquí los guerreros dignos dejan atrás lo que fueron... para volver a nacer más fuertes."), 
		tr("¿Estás preparado para renacer como %s?") % high, 
	]
	var last: = page >= pages.size() - 1
	var buttons: Array = [[tr("Renacer"), _reborn], [tr("Aún no"), _not_yet]] if last\
	else [[tr("Siguiente"), func(): _talk(page + 1)]]
	_npc_window(tr("Valkyrie"), pages[mini(page, pages.size() - 1)], buttons)



func _not_yet() -> void :
	_close_dialog()
	world.emote(valkyrie, "heh", 1.6)
	_show_caption(tr("«Valhalla esperará tu regreso, guerrero.»"))
	_control = true



func _decline() -> void :
	if _done:
		return
	_done = true
	_control = false
	_close_dialog()
	world.mouse_walk.reset()
	Vfx.column(world.fx_root, hero.position, Color(0.9, 0.95, 1.0))
	world.play_sound("portal", 0.0, -2.0)
	var tw: = create_tween()
	tw.tween_interval(0.3)
	tw.tween_property(_white, "color:a", 1.0, 0.6)
	tw.tween_callback( func():
		_ui.queue_free()
		world.enter_town(class_id))




func _reborn() -> void :
	if _done:
		return
	_done = true
	_control = false
	_close_dialog()
	world.emote(valkyrie, "love", 2.4)
	world.play_sound("blessing", 0.0, -2.0)
	world.sprite_fx("fx_blessing", hero.position, 0, 1.2, hero)
	var beam: = Vfx.beam(world.fx_root, hero.position, Color(1.0, 0.9, 0.55), 14.0)
	beam.scale = Vector3(0.2, 1.0, 0.2)
	var tw: = create_tween()
	tw.tween_property(beam, "scale", Vector3(1.6, 1.0, 1.6), 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_callback( func():
		world.play_sound("angelus", 0.0, -2.0)
		hero.play(RoVisual.PC_CAST))
	tw.tween_property(hero, "position:y", hero.position.y + 2.4, 2.0).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(_white, "color:a", 1.0, 2.0).set_ease(Tween.EASE_IN)
	tw.tween_callback( func():
		Save.rebirth(class_id)
		world.play_sound("job_levelup", 0.0, 0.0)
		world.shake(0.2))
	tw.tween_interval(0.5)

	tw.tween_callback( func():
		hero.position.y = world.map.height_at(hero.position)
		hero.play(RoVisual.PC_IDLE)
		if is_instance_valid(beam):
			beam.queue_free()
		RoEffect.spawn(world.fx_root, "h_levelup", hero.position, 1.0, hero))
	tw.tween_property(_white, "color:a", 0.0, 1.0)
	tw.tween_callback( func(): _show_caption(tr("¡Has renacido!")))
	tw.tween_interval(1.8)
	tw.tween_callback( func():
		_ui.queue_free()
		world.menus._rebirth_reveal(class_id, ColorRect.new()))





func _build_heroes() -> void :
	var jobs: Array = []
	for cid in GameData.CLASSES:
		for job: Dictionary in GameData.job_paths(cid):
			jobs.append(job)
	if jobs.is_empty():
		return
	var i: = 0
	for row in HERO_ROWS:
		for col in HERO_COLS:
			var job: Dictionary = jobs[i % jobs.size()]
			var look: = {"gender": "f" if i % 3 == 1 else "m", "hair": 1 + (i * 7) % 18, "hair_color": (i * 3) % 9, "cloth": 0}
			var v: = RoVisual.new()
			add_child(v)
			v.setup(RoAssets.styled_character(str(job.body), str(job.get("weapon", "")), "", [RoVisual.PC_ATTACK], "", look), 
				Color(0.8, 0.8, 0.9), 44)
			v.position = _at(Vector2i(col, row))
			v.face(Vector3(1 if col < 49 else -1, 0, 0))

			v.hold_idle = true
			v.play(RoVisual.PC_IDLE)
			_heroes.append({"node": v, "cheered": false})
			i += 1


func _portal(at: Vector3, color: Color, caption: String) -> void :
	var p: = Node3D.new()
	add_child(p)
	p.position = at + Vector3(0, PORTAL_LIFT, 0)
	Vfx.warp_portal(p, color, 1.0)
	var glow: = Vfx.ground_glow(p, Vector3.ZERO, 1.8, Color(color, 0.5))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.2, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)
	if caption != "":
		var l: = Label3D.new()
		l.text = caption
		l.font = World.RO_UI_FONT
		l.font_size = 26
		l.pixel_size = 0.012
		l.outline_size = 8
		l.outline_modulate = Color(0, 0, 0, 0.85)
		l.modulate = Color(0.9, 0.95, 1.0)
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.no_depth_test = true
		l.render_priority = 20
		l.position = Vector3(0, 2.2, 0)
		p.add_child(l)




func _build_sky() -> void :
	for c in world.get_children():
		if c is WorldEnvironment:
			_env = (c as WorldEnvironment).environment
	if _env != null:
		for k in ["background_color", "ambient_light_energy", "ambient_light_color"]:
			_env_saved[k] = _env.get(k)
		_env.background_color = SKY_COLOR
		_env.ambient_light_color = Color(0.75, 0.78, 0.85)
		_env.ambient_light_energy = 1.25 * Vfx.light_k()
	var texs: Array[Texture2D] = []
	for n in CLOUD_TEXTURES:
		var path: = "res://assets/ro/ui/sky/%s.png" % n
		if ResourceLoader.exists(path):
			texs.append(load(path))
	if texs.is_empty():
		return
	var centre: = (_at(ARRIVE_CELL) + _at(VALKYRIE_CELL)) * 0.5
	for i in CLOUDS:
		var s: = Sprite3D.new()
		s.texture = texs[i % texs.size()]
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.transparent = true
		s.pixel_size = randf_range(0.05, 0.11)
		s.modulate = Color(1, 1, 1, randf_range(0.55, 0.9))

		var below: = i % 4 != 0
		var spread: = Vector2(randf_range(-70.0, 70.0), randf_range(-80.0, 80.0))
		if not below:
			spread.x = (35.0 + randf_range(0.0, 35.0)) * (1.0 if i % 2 == 0 else -1.0)
		s.position = centre + Vector3(spread.x, randf_range(-26.0, -10.0) if below else randf_range(-6.0, 2.0), spread.y)
		s.render_priority = -10
		add_child(s)
		_clouds.append({"node": s, "speed": randf_range(0.6, 1.6)})


func _update_clouds(delta: float) -> void :
	var centre_x: = _at(ARRIVE_CELL).x
	for c in _clouds:
		var s: Sprite3D = c.node
		s.position.x += float(c.speed) * delta
		if s.position.x > centre_x + 75.0:
			s.position.x -= 150.0




func _build_ui() -> void :
	_ui = CanvasLayer.new()
	_ui.layer = 30
	add_child(_ui)
	_white = ColorRect.new()
	_white.color = Color(1, 1, 1, 1)
	_white.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_white.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_white)
	_caption = UiKit.label("", 22, Color(1.0, 0.92, 0.6), true)
	_caption.add_theme_constant_override("outline_size", 6)
	_caption.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.02, 0.95))
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_caption.offset_top = 90
	_caption.modulate.a = 0.0
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(_caption)
	var hint: = UiKit.label(tr("WASD o clic: caminar   ·   Esc: volver a Prontera"), 13, Color.WHITE)
	hint.visible = not MouseWalk.touch()
	hint.add_theme_constant_override("outline_size", 4)
	hint.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -34
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ui.add_child(hint)


func _show_caption(text: String) -> void :
	_caption.text = text
	var tw: = _caption.create_tween()
	tw.tween_property(_caption, "modulate:a", 1.0, 0.4)
	tw.tween_interval(2.2)
	tw.tween_property(_caption, "modulate:a", 0.0, 0.6)




func _npc_window(npc_name: String, text: String, buttons: Array) -> void :
	_close_dialog()
	var win: = UiStyles.ro_window(npc_name, UiKit.FONT_TITLE)
	_dialog = win.root
	_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	var body: VBoxContainer = win.body
	var name_l: = Label.new()
	name_l.text = "[%s]" % npc_name
	name_l.add_theme_font_override("font", UiKit.FONT_TITLE)
	name_l.add_theme_font_size_override("font_size", 12)
	name_l.add_theme_color_override("font_color", Color(0.12, 0.25, 0.75))
	body.add_child(name_l)
	var t: = Label.new()
	t.text = text
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.custom_minimum_size = Vector2(360, 44)
	t.add_theme_font_override("font", UiKit.FONT_BODY)
	t.add_theme_font_size_override("font_size", 12)
	t.add_theme_color_override("font_color", Color.BLACK)
	body.add_child(t)
	var row: = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 6)
	body.add_child(row)
	var first: Button
	for b in buttons:

		var btn: Button = world.menus._ro_button(str(b[0]), b[1])
		btn.custom_minimum_size = Vector2(72, 20)
		btn.pressed.connect(world.menus.ui_click)
		row.add_child(btn)
		if first == null:
			first = btn
	_ui.add_child(_dialog)

	var view: = get_viewport().get_visible_rect().size
	var k: = clampf(floorf(view.y / 640.0), 1.0, 2.0)
	_dialog.scale = Vector2(k, k)
	var place: = func():
		if is_instance_valid(_dialog):
			var sz: = _dialog.get_combined_minimum_size() * k
			_dialog.position = Vector2(floorf((view.x - sz.x) * 0.5), floorf(view.y * 0.64))
	place.call_deferred()
	if first != null:
		first.grab_focus.call_deferred()


func _close_dialog() -> void :
	if _dialog != null and is_instance_valid(_dialog):
		_dialog.queue_free()
	_dialog = null


func _name_label(node: Node3D, text: String) -> void :
	var l: = Label3D.new()
	l.text = text
	l.font = World.RO_UI_FONT
	l.font_size = 30
	l.pixel_size = 0.012
	l.outline_size = 10
	l.outline_modulate = Color(0, 0, 0, 0.85)
	l.modulate = NAME_COLOR
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 20
	l.outline_render_priority = 19
	l.position = RoVisual.lift + Vector3(0, -0.35, 0)
	node.add_child(l)




func _center_shift(v: RoVisual) -> Vector3:
	if v.ro == null:
		return Vector3.ZERO
	var used: = v.ro.compose_image(0, 0).get_used_rect()
	if not used.has_area():
		return Vector3.ZERO
	var off: = used.position.x + used.size.x * 0.5 - v.ro.origin.x
	return Vector3( - off * GameData.PIXEL_SIZE * v.scale.x, 0, 0)


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
