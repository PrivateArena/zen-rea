class_name TownCrowd
extends Node3D












const VEND_SPOTS: = [Vector2(135, 196), Vector2(139, 197), Vector2(143, 196), Vector2(137, 194), Vector2(146, 197), 
	Vector2(177, 196), Vector2(173, 197), Vector2(169, 196), Vector2(175, 194), Vector2(166, 197)]


const PARTY_SPOT: = Vector2(142, 178)

const SIGN_CHARS: = 18
const PLAZA_RADIUS: = 21.0

const CLEAR: = 2.4
const WALK_SPEED: = 3.2
const SHOUT_EVERY: = [5.0, 11.0]
const PORTAL_EVERY: = [7.0, 14.0]
const SIT: = 2


const MOBILE_MAX: = 3


const PORTAL_CLEAR: = 4.5
const NPC_CLEAR: = 3.0
const WALK_RADIUS: = 17.0


const NAME_DROP: = 0.55
const CHAT_GAP: = 0.8

const CHAT_FS: = 40
const CHAT_MAX: = 70
const TownChannel = preload("res://scripts/net/town_channel.gd")
const ChatLog = preload("res://scripts/ui/chat_log.gd")

var town: Town
var world: World
var _people: Array[Dictionary] = []
var _looks: Array = []
var _signs: CanvasLayer
var _portal_clock: = 4.0

static var _baby_gap: = 0
var _taken: Array[Vector2] = []

var _shops: Array = []

var _chat_box: LineEdit


var _target: = "channel"
var _target_button: Button
var _chat_bar: Control
const CHAT_BAR: = Vector2(420, 24)

const CHAT_EDGE: = 4.0


var _log: ChatLog

var _chat_layer: CanvasLayer
var _emote_t: = 0


var _real: = 0
var _base: = 0
var _vanish_t: = 0.0

const VANISH_EVERY: = 0.7


var _reconnect: Control
const RECONNECT_EDGE: = 56.0
const RECONNECT_FADE: = 0.25


func setup(p_town: Town) -> void :
	town = p_town
	world = p_town.world
	_signs = CanvasLayer.new()
	_signs.layer = 2
	add_child(_signs)
	_build_chat_box()
	_build_reconnect()

	var dev: = town.is_dev_hero()
	var own: = player_name_label(town.hero, Save.char_name(town.class_id) + (" · Dev" if dev else ""), 
		NameFilter.DEV_COLOR if dev else (GameData.REBIRTH_LV_GOLD if Save.rebirth_looks(town.class_id).has("valhalla") else Color(1.0, 0.95, 0.7)))

	town.hero.set_meta("name_label", own)
	_collect_looks()
	for c in GameData.TOWN_NPCS:
		_taken.append(Vector2(c.cell))
	for p in GameData.TOWN_PROPS:
		_taken.append(p.cell)
	_taken.append(Vector2(Town.PORTAL_CELL))
	_taken.append(Vector2(Town.HERO_CELL))
	_taken.append(PARTY_SPOT)
	_populate()
	_base = _people.size()



func _populate() -> void :


	var day: = Time.get_datetime_dict_from_system(true)
	seed(("%04d-%02d-%02d|%s" % [day.year, day.month, day.day, town.place]).hash())
	_spawn("chatroom", PARTY_SPOT)
	var spots: Array = VEND_SPOTS.filter( func(c): return world.map.is_walkable(_at(c)))
	spots.shuffle()
	for i in mini(randi_range(4, 6), spots.size()):
		_spawn("vendor", spots[i])
	_spawn("chatroom")
	_spawn("shouter")
	_spawn("idler")
	if randf() < 0.5:
		_spawn("walker")
	randomize()


	_baby_gap -= 1
	if (_baby_gap <= 0 and randf() < float(GameData.TOWN_BABY.chance)) or GameData.has_meta("force_baby"):
		_baby_gap = int(GameData.TOWN_BABY.gap)
		_spawn("baby", _near(Vector2(Town.HERO_CELL)))



func _collect_looks() -> void :
	for cid in GameData.CLASSES:
		var d: Dictionary = GameData.CLASSES[cid]
		_looks.append([str(d.body), str(d.get("weapon", "")), cid])
		for job: Dictionary in GameData.job_paths(cid):
			_looks.append([str(job.body), str(job.get("weapon", d.get("weapon", ""))), cid])
			if job.has("trans"):
				var tr_job: Dictionary = job.trans
				_looks.append([str(tr_job.body), str(tr_job.get("weapon", job.get("weapon", ""))), cid])


func _spawn(role: String, at: = Vector2.INF) -> Dictionary:
	var cell: = at if at != Vector2.INF else _free_cell(role)
	if cell == Vector2.INF:
		return {}
	var look: Array = [GameData.TOWN_BABY.body, "", "super_novice"] if role == "baby" else _looks.pick_random()
	var female: = randf() < 0.45
	var hats: = ["", "", "hat_apple", "hat_bandana", "hat_cap", "hat_goggles", "hat_ribbon"]
	var sprite: = RoAssets.styled_character(str(look[0]), str(look[1]), "", [RoVisual.PC_ATTACK], 
		str(hats.pick_random()), {"gender": "f" if female else "m", "hair": randi_range(1, 23), 
			"hair_color": randi_range(0, 8), "cloth": randi_range(0, 4)})
	var v: = RoVisual.new()
	add_child(v)
	v.setup(sprite, Color(0.8, 0.8, 0.9), 44)
	v.hold_idle = true
	v.position = _at(cell)
	v.face(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)))
	var name_txt: = _name()
	player_name_label(v, name_txt)
	var p: = {"node": v, "role": role, "name": name_txt, "cls": str(look[2]), "target": Vector3.INF, 
		"wait": randf_range(0.5, 4.0), "shout": randf_range(1.0, 8.0), "sign": null}
	match role:
		"vendor":
			_sit(v)
			v.face(_at(Vector2(Town.CENTER)) - v.position)
			if _shops.is_empty():
				_shops = GameData.CROWD_SHOPS.duplicate()
				_shops.shuffle()
			p.sign = _sign(tr(str(_shops.pop_back())), "sign_shop")
		"chatroom":
			_sit(v)
			p.sign = _sign(tr(str(GameData.CROWD_ROOMS.pick_random())), "sign_chat")

			for k in randi_range(1, 2):
				var next: = _near(cell)
				if next != Vector2.INF:
					var f: = _spawn("sitter", next)
					if not f.is_empty():
						f.node.face(v.position - f.node.position)
		"sitter":
			_sit(v)
		"baby":
			v.scale = Vector3.ONE * float(GameData.TOWN_BABY.scale)
			for c in v.get_children():
				if c is Label3D:
					c.scale = Vector3.ONE / v.scale.x
			p.wait = float(GameData.TOWN_BABY.time)
			p.shout = 1.0
			v.play(RoVisual.PC_IDLE)
		_:
			v.play(RoVisual.PC_IDLE)
	_people.append(p)
	return p




func set_real(n: int) -> void :
	_real = n


func _allowed() -> int:
	return maxi(0, _base - _real)


func _vanish(p: Dictionary) -> void :
	var v: RoVisual = p.node
	if is_instance_valid(v):
		Vfx.column(world.fx_root, v.position, Color(0.85, 0.92, 1.0))
		world.play_sound("portal", 0.2, -14.0)
		v.queue_free()
	if p.sign != null and is_instance_valid(p.sign):
		p.sign.queue_free()
	_people.erase(p)


func tick(delta: float) -> void :
	if _reconnect != null:
		var on: = world.channel.reconnecting() or has_meta("reconnect_test")
		_reconnect.modulate.a = move_toward(_reconnect.modulate.a, 1.0 if on else 0.0, delta / RECONNECT_FADE)
		_reconnect.visible = _reconnect.modulate.a > 0.0
	if _log != null:

		var wc: Node = world.channel.world_chat
		_log.visible = world.channel.is_in() or world.net.mode != "" or has_meta("log_test") or (wc != null and str(wc.get("state")) == "in")
	if _log != null and _log.emotes != null and ( not _log.visible or world.menus.mode() != "town"):
		_log.emotes.close()
	_vanish_t -= delta
	if _vanish_t <= 0.0 and (_real > 0 or world.net.mode != ""):

		for b in _people:
			if b.role == "baby" and is_instance_valid(b.node):
				_vanish_t = VANISH_EVERY
				_vanish(b)
				break
	if _vanish_t <= 0.0 and _people.size() > _allowed():
		_vanish_t = VANISH_EVERY

		_vanish(_people.back())
	for p in _people.duplicate():
		if not is_instance_valid(p.node):
			_people.erase(p)
			continue
		_act(p, delta)
		if p.sign != null:
			_place_sign(p)
	_portal_clock -= delta
	if _portal_clock <= 0.0:
		_portal_clock = randf_range(PORTAL_EVERY[0], PORTAL_EVERY[1])
		if randf() < 0.5:
			_send_to_portal()
		else:
			_arrive()




func _baby(p: Dictionary, delta: float) -> void :
	var v: RoVisual = p.node
	var b: Dictionary = GameData.TOWN_BABY
	p.wait -= delta
	p.shout -= delta
	if p.wait <= 0.0:
		p.role = "leaver"
		p.target = _at(Town.PORTAL_CELL)
		chat(v, "%s : %s" % [p.name, tr("bah")])
		return
	if p.shout <= 0.0:
		p.shout = randf_range(float(b.every[0]), float(b.every[1]))
		_say(p)
	var to: Vector3 = (town.hero.position - v.position) * Vector3(1, 0, 1)
	if to.length() > float(b.close):
		var at: Vector3 = v.position + to.normalized() * minf(to.length(), float(b.speed) * delta)
		v.position = Vector3(at.x, world.map.height_at(at), at.z)
		v.face(to)
		v.play(RoVisual.PC_WALK)
	else:
		v.face(to)
		v.play(RoVisual.PC_IDLE)


func _act(p: Dictionary, delta: float) -> void :
	var v: RoVisual = p.node
	if p.role == "baby":
		_baby(p, delta)
		return
	if p.role in ["shouter", "idler", "walker"]:
		p.shout -= delta
		if p.shout <= 0.0:
			p.shout = randf_range(SHOUT_EVERY[0], SHOUT_EVERY[1]) * (1.0 if p.role == "shouter" else 2.5)
			_say(p)
	if p.target != Vector3.INF:
		var to: Vector3 = (p.target - v.position) * Vector3(1, 0, 1)
		var d: = to.length()
		if d < 0.15:
			p.target = Vector3.INF
			v.play(RoVisual.PC_IDLE)
			if p.role == "leaver":
				_warp_out(p)
			return
		var step: Vector3 = to / d * minf(d, WALK_SPEED * delta)
		var at: Vector3 = v.position + step
		v.position = Vector3(at.x, world.map.height_at(at), at.z)
		v.face(to)
		v.play(RoVisual.PC_WALK)
		return
	if p.role == "walker":
		p.wait -= delta
		if p.wait <= 0.0:
			p.wait = randf_range(2.0, 6.0)
			var cell: = _free_cell("walker", v.position)
			if cell != Vector2.INF:
				p.target = _at(cell)
	elif p.role in ["shouter", "idler"] and randf() < delta * 0.05:

		v.face(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)))



func _say(p: Dictionary) -> void :
	var pool: Array = GameData.CROWD_LINES.get(p.role, GameData.CROWD_LINES.shouter)
	var line: = tr(str(pool.pick_random()))
	if line.contains("%s"):
		line = line % tr(str(GameData.CLASSES[p.cls].name))
	chat(p.node, "%s : %s" % [p.name, line])
	if randf() < 0.35:
		world.emote(p.node, ["heh", "ok", "go", "love", "sweat", "money", "question", "grats"].pick_random(), 1.6)


func _mobile() -> int:
	return _people.filter( func(p): return p.role in ["walker", "idler", "shouter", "leaver"]).size()



func _send_to_portal() -> void :
	var walkers: = _people.filter( func(p): return p.role in ["walker", "idler", "shouter"] and p.target == Vector3.INF)
	if walkers.is_empty():
		return
	var p: Dictionary = walkers.pick_random()
	p.role = "leaver"
	p.target = _at(Town.PORTAL_CELL) + Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3))
	if randf() < 0.5:
		chat(p.node, "%s : %s" % [p.name, tr(str(GameData.CROWD_LINES.leaver.pick_random()))])


func _warp_out(p: Dictionary) -> void :
	var v: RoVisual = p.node
	Vfx.column(world.fx_root, v.position, Color(0.85, 0.92, 1.0))
	world.play_sound("portal", 0.2, -14.0)
	_people.erase(p)
	v.queue_free()



func _arrive() -> void :
	if _mobile() >= MOBILE_MAX or _people.size() >= _allowed():
		return
	var p: = _spawn("walker", Vector2(Town.PORTAL_CELL) + Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)))
	if p.is_empty():
		return
	Vfx.column(world.fx_root, p.node.position, Color(0.85, 0.92, 1.0))
	world.play_sound("portal", 0.2, -14.0)
	p.wait = 0.4
	if randf() < 0.4:
		chat(p.node, "%s : %s" % [p.name, tr(str(GameData.CROWD_LINES.arrival.pick_random()))])




func _at(cell: Vector2) -> Vector3:
	var c: = world.map.cell_center(floori(cell.x), floori(cell.y)) + Vector3(fposmod(cell.x, 1.0) - 0.5, 0, 0.5 - fposmod(cell.y, 1.0))
	return Vector3(c.x, world.map.height_at(c), c.z)





func _free_cell(role: String, from: = Vector3.INF) -> Vector2:
	var portal: = Vector2(Town.PORTAL_CELL)
	for i in 60:
		var a: = randf() * TAU
		var r: = WALK_RADIUS if role == "walker" else PLAZA_RADIUS
		var c: = (Vector2(Town.CENTER) + Vector2(cos(a), sin(a)) * randf_range(4.0, r)).round()
		if not world.map.is_walkable(_at(c)) or c.distance_to(portal) < PORTAL_CLEAR:
			continue
		var ok: = true
		for n in GameData.TOWN_NPCS:
			if Vector2(n.cell).distance_to(c) < NPC_CLEAR:
				ok = false
				break
		for t in _taken:
			if ok and t.distance_to(c) < CLEAR:
				ok = false
		if ok and from != Vector3.INF:

			var f: = _cell_of(from)


			var on_portal: = f.distance_to(portal) < PORTAL_CLEAR
			if not on_portal and Geometry2D.get_closest_point_to_segment(portal, f, c).distance_to(portal) < PORTAL_CLEAR - 1.0:
				ok = false
			if on_portal and c.distance_to(portal) < f.distance_to(portal) + 3.0:
				ok = false
			for n in GameData.TOWN_NPCS:
				var nc: = Vector2(n.cell)
				if ok and Geometry2D.get_closest_point_to_segment(nc, f, c).distance_to(nc) < NPC_CLEAR - 0.5:
					ok = false
		if ok:
			if role != "walker":
				_taken.append(c)
			return c
	return Vector2.INF



func _cell_of(pos: Vector3) -> Vector2:
	var m: = world.map
	return Vector2(pos.x + m.width * 0.5, m.height * 0.5 - pos.z)



func _near(cell: Vector2) -> Vector2:
	for d in [Vector2(1, -1), Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(2, 0), Vector2(-2, 0)]:
		var c: Vector2 = cell + d
		if not world.map.is_walkable(_at(c)):
			continue
		var free: = true
		for t in _taken:
			if t.distance_to(c) < 0.9:
				free = false
				break
		if free:
			_taken.append(c)
			return c
	return Vector2.INF



func _name() -> String:
	var a: Array = GameData.CROWD_NAMES_A
	var b: Array = GameData.CROWD_NAMES_B
	match randi() % 5:
		0:
			return "%s%s" % [a.pick_random(), b.pick_random()]
		1:
			return "xX%s%sXx" % [a.pick_random(), b.pick_random()]
		2:
			return "%s%d" % [a.pick_random(), randi_range(1, 999)]
		3:
			return "%s_%s" % [str(a.pick_random()).to_lower(), str(b.pick_random()).to_lower()]
	return "%s %s" % [a.pick_random(), b.pick_random()]






static func player_name_label(node: Node3D, text: String, color: = Color.WHITE) -> Label3D:
	var l: = Label3D.new()
	l.text = text
	l.font = World.RO_UI_FONT
	l.font_size = 28
	l.pixel_size = 0.012
	l.modulate = color
	Town.readable(l)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 18
	l.outline_render_priority = 17
	l.position = RoVisual.lift + Vector3(0, - cos(World.CAMERA_PITCH), sin(World.CAMERA_PITCH)) * NAME_DROP
	l.set_meta("drop", NAME_DROP)
	node.add_child(l)
	return l



func chat(node: Node3D, text: String) -> void :
	if node == null or not is_instance_valid(node):
		return
	for c in node.get_children():
		if c.has_meta("chat"):
			c.queue_free()
	var l: = Label3D.new()
	l.set_meta("chat", true)
	l.text = text
	l.font = World.RO_UI_FONT


	l.font_size = UiKit.text_size(CHAT_FS)
	l.pixel_size = 0.012
	Town.readable(l)

	l.modulate = NameFilter.DEV_COLOR if NameFilter.dev_line(text) else Color(1, 1, 1)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 19
	l.outline_render_priority = 18
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	l.width = 420.0 * l.font_size / 28.0
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var up: = Vector3(0, cos(World.CAMERA_PITCH), - sin(World.CAMERA_PITCH))
	l.position = RoVisual.lift + up * (world._sprite_height(node as RoVisual) + CHAT_GAP)

	l.scale = Vector3.ONE / node.scale.x
	l.set_meta("base_scale", l.scale)
	l.scale *= town.label_k()
	node.add_child(l)
	var tw: = l.create_tween()
	tw.tween_interval(3.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)



func _sit(v: RoVisual) -> void :
	v.play(SIT)
	v.speed_scale = 0.0





func _sign(text: String, icon: String) -> Control:
	if text.length() > SIGN_CHARS:
		text = text.substr(0, SIGN_CHARS).strip_edges() + "..."
	var root: = Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel: = PanelContainer.new()
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(1, 1, 1, 0.97)
	box.border_color = Color(0.58, 0.62, 0.7)
	box.set_border_width_all(1)
	box.set_corner_radius_all(5)
	box.content_margin_left = 22
	box.content_margin_right = 7
	box.content_margin_top = 2
	box.content_margin_bottom = 2
	box.shadow_color = Color(0, 0, 0, 0.25)
	box.shadow_size = 2
	box.shadow_offset = Vector2(1, 1)
	panel.add_theme_stylebox_override("panel", box)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(8, 0)
	root.add_child(panel)
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", World.RO_UI_FONT)
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color.BLACK)
	panel.add_child(l)
	var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % icon
	if ResourceLoader.exists(path):
		var ic: = TextureRect.new()
		ic.texture = load(path)
		ic.texture_filter = RoAssets.ui_filter()
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ic.position = Vector2(0, -4)
		root.add_child(ic)
	panel.resized.connect( func(): root.size = panel.size + Vector2(8, 0))
	_signs.add_child(root)
	return root


func _place_sign(p: Dictionary) -> void :
	var panel: Control = p.sign
	var v: RoVisual = p.node
	var cam: = world.camera
	var head: = v.position + RoVisual.world_lift() + Vector3(0, 2.6, 0)
	var on: = world.menus.mode() == "town" and not cam.is_position_behind(head)
	panel.visible = on
	if on:
		var at: = cam.unproject_position(head)
		panel.position = (at - Vector2(panel.size.x * 0.5, panel.size.y)).floor()







func _build_chat_box() -> void :
	var top: = MouseWalk.touch()
	_chat_bar = Control.new()
	_chat_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT if top else Control.PRESET_BOTTOM_LEFT)
	_chat_bar.offset_left = CHAT_EDGE
	_chat_bar.offset_right = CHAT_EDGE + CHAT_BAR.x
	_chat_bar.offset_top = _touch_top() if top else - CHAT_EDGE - CHAT_BAR.y
	_chat_bar.offset_bottom = _touch_top() + CHAT_BAR.y if top else - CHAT_EDGE
	_chat_bar.visible = false
	_chat_layer = CanvasLayer.new()
	_chat_layer.layer = 4
	add_child(_chat_layer)
	_chat_layer.add_child(_chat_bar)
	_chat_box = LineEdit.new()
	_chat_box.max_length = CHAT_MAX
	_chat_box.placeholder_text = tr("Escribe y pulsa Enter")
	_chat_box.add_theme_font_override("font", World.RO_UI_FONT)
	_chat_box.add_theme_font_size_override("font_size", 12)
	_chat_box.add_theme_color_override("font_color", Color.WHITE)
	_chat_box.add_theme_color_override("font_placeholder_color", Color(1, 1, 1, 0.4))
	_chat_box.add_theme_color_override("caret_color", Color.WHITE)
	_chat_box.add_theme_color_override("selection_color", Color(1, 1, 1, 0.25))
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0.55)
	box.set_corner_radius_all(3)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 3
	box.content_margin_bottom = 3
	for st in ["normal", "focus", "read_only"]:
		_chat_box.add_theme_stylebox_override(st, box)
	_chat_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_chat_box.offset_left = TARGET_W + 4
	_chat_box.text_submitted.connect(_send_chat)

	_target_button = Button.new()
	_target_button.focus_mode = Control.FOCUS_NONE
	_target_button.add_theme_font_override("font", World.RO_UI_FONT)
	_target_button.add_theme_font_size_override("font_size", 11)
	_target_button.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	_target_button.offset_right = TARGET_W
	_target_button.tooltip_text = tr("Dónde se envía: tu canal o Mundo (todos los jugadores de tu idioma). Clic para cambiar.")
	_target_button.pressed.connect( func():
		_set_target("world" if _target == "channel" else "channel")
		_chat_box.grab_focus())
	_chat_bar.add_child(_target_button)
	_set_target("channel")


	_chat_box.focus_exited.connect(_close_chat)
	_chat_bar.add_child(_chat_box)
	_log = ChatLog.new()
	_log.setup(world, CHAT_BAR.x, self)
	_log.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT if top else Control.PRESET_BOTTOM_LEFT)
	_log.grow_vertical = Control.GROW_DIRECTION_END if top else Control.GROW_DIRECTION_BEGIN
	_log.offset_left = CHAT_EDGE
	_place_log()
	_log.visible = false
	_chat_layer.add_child(_log)




func _build_reconnect() -> void :
	var box: = StyleBoxFlat.new()
	box.bg_color = Color(0, 0, 0, 0.55)
	box.set_corner_radius_all(12)
	box.content_margin_left = 10
	box.content_margin_right = 14
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	var pill: = PanelContainer.new()
	pill.add_theme_stylebox_override("panel", box)
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(row)
	row.add_child(PartyBar.Spinner.new())
	var text: = Label.new()
	text.text = tr("Reconectando con el canal...")
	text.add_theme_font_override("font", World.RO_UI_FONT)
	text.add_theme_font_size_override("font_size", 12)
	text.add_theme_color_override("font_color", Color.WHITE)
	row.add_child(text)
	pill.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	pill.grow_horizontal = Control.GROW_DIRECTION_BOTH
	pill.grow_vertical = Control.GROW_DIRECTION_BEGIN
	pill.offset_bottom = - RECONNECT_EDGE
	pill.offset_top = - RECONNECT_EDGE
	pill.modulate.a = 0.0
	pill.visible = false

	var layer: = CanvasLayer.new()
	layer.layer = 6
	add_child(layer)
	layer.add_child(pill)
	_reconnect = pill



func send_emote(idx: int) -> void :
	var now: = Time.get_ticks_msec()
	if now - _emote_t < 600:
		return
	_emote_t = now
	world.emote_at(town.hero, idx, 2.0)
	if world.channel.is_in():
		world.channel.emote(idx)

	if world.net.mode != "":
		world.net.town_event("emote:%d" % idx, true)



func typing() -> bool:
	return _chat_bar != null and _chat_bar.visible


func _input(event: InputEvent) -> void :
	if typing() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close_chat()
		get_viewport().set_input_as_handled()



	elif typing() and event is InputEventMouseButton and event.pressed and not _chat_bar.get_global_rect().has_point(event.position) and not (_log != null and _log.visible and _log.get_global_rect().has_point(event.position)):
		_close_chat()

	elif typing() and event is InputEventKey and event.pressed and event.keycode in [KEY_UP, KEY_DOWN] and not _history.is_empty():
		if event.keycode == KEY_UP:
			_history_at = _history.size() - 1 if _history_at < 0 else maxi(0, _history_at - 1)
		elif _history_at >= 0:
			_history_at += 1
			if _history_at >= _history.size():
				_history_at = -1
		_chat_box.text = _history[_history_at] if _history_at >= 0 else ""
		_chat_box.caret_column = _chat_box.text.length()
		get_viewport().set_input_as_handled()




func _shortcut_input(event: InputEvent) -> void :
	if typing() and event is InputEventKey:
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void :
	if world.menus.mode() != "town" or typing():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		open_chat()
		get_viewport().set_input_as_handled()




var _whisper_name: = ""

var _history: Array[String] = []
var _history_at: = -1
const HISTORY_MAX: = 30

const EMOTE_ALIASES: = {"!": "surprise", "?": "question", "ho": "music", "lv": "love", "lv2": "love2", "swt": "sweat", 
	"ic": "idea", "$": "money", "sry": "sorry", "gg": "grats", "thx": "ok"}



const TARGET_W: = 58.0


func _set_target(t: String) -> void :
	_target = t
	if _target_button == null:
		return
	_target_button.text = tr("Mundo") if t == "world" else tr("Canal")
	var col: = Color(0.6, 1.0, 0.75) if t == "world" else Color.WHITE
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		_target_button.add_theme_color_override(k, col)
	_chat_box.placeholder_text = tr("Escribe a Mundo y pulsa Enter") if t == "world" else tr("Escribe y pulsa Enter")


func open_chat(text: = "") -> void :
	if text == "" and _whisper_name != "":
		text = "/w %s " % _whisper_name
	_history_at = -1
	_chat_bar.visible = true
	_place_log()
	_chat_box.text = text
	_chat_box.grab_focus()
	_chat_box.caret_column = text.length()





func _send_chat(text: String) -> void :
	text = text.strip_edges()
	if text != "" and (_history.is_empty() or _history[-1] != text):
		_history.append(text)
		if _history.size() > HISTORY_MAX:
			_history.pop_front()

	if text != "" and _log != null:
		_log.restore()
	var ch: TownChannel = world.channel
	if text.to_lower().begins_with("/canal") or text.to_lower().begins_with("/channel"):
		var n: = int(text.get_slice(" ", 1))
		if n > 0:
			ch.join_async(n)
		_close_chat()
		return
	var cmd: = text.get_slice(" ", 0).to_lower()

	if cmd in ["/sit", "/sentarse", "/sentar"]:
		town.toggle_sit()
		_close_chat()
		return


	var emo: = str(EMOTE_ALIASES.get(cmd.substr(1), cmd.substr(1)))
	if cmd.length() > 1 and GameData.EMOTES.has(emo) and text.get_slice_count(" ") == 1:
		send_emote(int(GameData.EMOTES[emo]))
		_close_chat()
		return
	if cmd in ["/w", "/whisper", "/r"]:
		var rest: = text.substr(cmd.length()).strip_edges()
		if not ch.is_in():
			ch.log_line("sys", tr("Los susurros son para Prontera online."))
		elif cmd == "/r":
			_whisper_name = ch.reply(rest)
		else:

			var to: = ch.whisper(rest)
			_whisper_name = to if rest.substr(to.length()).strip_edges() != "" else ""
		_close_chat()
		return

	_whisper_name = ""

	if cmd in ["/m", "/mundo", "/world"] or (_target == "world" and not text.begins_with("%")):
		var said: = text.substr(cmd.length()).strip_edges() if cmd in ["/m", "/mundo", "/world"] else text
		if said != "" and ch.world_chat != null:
			ch.world_chat.say(said)
			world.play_sound("ui_click", 0.0, -8.0)
		_close_chat()
		return
	var party: = text.begins_with("%")
	if party:
		text = text.substr(1).strip_edges()
	if text != "":
		var line: = "%s : %s" % [Save.char_name(town.class_id), NameFilter.clean(text)]
		if ch.is_in() and not party:

			if ch.say(line):
				chat(town.hero, line)
		elif world.net.mode != "":

			if not ch.is_in():
				chat(town.hero, line)
			world.net.town_chat(line)
			ch.log_line("party", line)
		elif party:
			ch.log_line("sys", tr("No estás en una party."))
		else:
			chat(town.hero, line)
		world.play_sound("ui_click", 0.0, -8.0)
	_close_chat()


func _close_chat() -> void :
	if not typing():
		return
	_chat_bar.visible = false
	_chat_box.release_focus()
	_place_log()






func _touch_top() -> float:
	var t = world.town if world != null else null
	if t != null and is_instance_valid(t) and t.get("_hud") != null and is_instance_valid(t._hud):
		var hud: Control = t._hud
		return maxf(CHAT_EDGE, hud.position.y + maxf(hud.size.y, 30.0) + 6.0)
	return 46.0


func _place_log() -> void :
	if _log == null:
		return
	var line: = CHAT_BAR.y + 2 if typing() else 0.0
	if MouseWalk.touch():
		_log.offset_top = _touch_top() + line
		_log.offset_bottom = _log.offset_top

		if _chat_bar != null:
			_chat_bar.offset_top = _touch_top()
			_chat_bar.offset_bottom = _touch_top() + CHAT_BAR.y
		return
	_log.offset_bottom = - CHAT_EDGE - line
	_log.offset_top = _log.offset_bottom
