class_name Town
extends Node3D






const MAP: = "prontera"

const CENTER: = Vector2i(156, 184)
const RADIUS: = 25.0
const HERO_CELL: = Vector2i(156, 187)
const PORTAL_CELL: = Vector2i(156, 171)


const TALK_RANGE: = 2.2
const REARM_RANGE: = 3.4
const PORTAL_RANGE: = 1.2

const CLICK_PX: = 46.0
const NAME_COLOR: = Color(1.0, 0.9, 0.55)

const EMOTE_EVERY: = 2.4


const AGI_SPEED: = 2.0

const WALK_ANIM_AT: = 1.6

const CHANNEL_BEAMS: = 4



var world: World
var class_id: = ""

var place: = "prontera"
var hero: RoVisual

var _cart: Pushcart
var _npcs: Array[Dictionary] = []
var _portal_pos: = Vector3.ZERO

var _going_to: = -1
var _left_portal: = false
var _emote_clock: = 0.0
var _emote_turn: = 0
var _speed: = 1.0
var _crowd: TownCrowd

var _party: = {}

var _hero_pet: RoVisual
var _hero_pet_id: = ""



func _cell(key: String) -> Vector2i:
	if place == "tower_gate":
		return GameData.TOWER_GATE[key]
	return {"hero_cell": HERO_CELL, "center": CENTER, "portal_cell": PORTAL_CELL}[key]


func _radius() -> float:
	return float(GameData.TOWER_GATE.radius) if place == "tower_gate" else RADIUS


func setup(p_world: World, p_class: String, p_place: = "prontera") -> void :
	world = p_world
	class_id = p_class
	place = p_place
	var d: Dictionary = GameData.CLASSES[class_id]
	hero = RoVisual.new()
	add_child(hero)
	var gear: = Equipment.loadout_views(class_id)
	var shown: Dictionary = GameData.shown_job(class_id, Save.look(class_id))
	hero.setup(RoAssets.styled_character(shown.body, shown.weapon, shown.weapon_fx, 
		[shown.attack], gear.head, Save.look(class_id), "", gear.extras), d.color, 44)
	hero.show_through()
	hero.hold_idle = true
	hero.position = _at(_cell("hero_cell"))
	hero.face(Vector3(0, 0, 1))
	hero.play(RoVisual.PC_IDLE)


	var dev: = is_dev_hero()
	RebirthAura.attach(hero, Save.rebirth_looks(class_id), RebirthAura.earned(class_id) and not dev)
	if dev:
		_dev_aura(hero)
	if d.get("cart", false):
		_cart = Pushcart.make(hero)
	for n in (GameData.TOWER_GATE.npcs if place == "tower_gate" else _town_npcs()):
		var v: = RoVisual.new()
		add_child(v)

		if n.has("npc_look"):
			v.setup(QuestRun.npc_sprite_of(n), Color(0.8, 0.8, 0.9), 40)
			v.hold_idle = true
		else:
			v.setup(RoAssets.sprite([Save.kafra() if n.id == "kafra" else n.sprite]), Color(0.8, 0.8, 0.9), 40)
		v.position = _at(n.cell) + _center_shift(v)

		if n.has("nudge"):
			var c0: = world.map.cell_center(n.cell.x, n.cell.y)
			var c1: = world.map.cell_center(n.cell.x + 1, n.cell.y + 1)
			v.position += Vector3((c1.x - c0.x) * float(n.nudge.x), 0, (c1.z - c0.z) * float(n.nudge.y))
		v.dir = int(n.dir)
		if n.get("face_center", false):

			v.face(_at(_cell("center")) - v.position)
		v.play(RoVisual.MOB_IDLE)

		if n.get("through", false):
			v.show_through(0.6)
		_name_label(v, tr(n.name), tr(str(n.get("title", ""))))

		v.visible = Save.npc_unlocked(str(n.id))

		var glow: = Vfx.ground_glow(v, Vector3(0, 0.03, 0), 1.3, Color(n.color, 0.55))
		var tw: = glow.create_tween().set_loops()
		tw.tween_property(glow, "modulate:a", 0.3, 0.9).set_trans(Tween.TRANS_SINE)
		tw.tween_property(glow, "modulate:a", 0.75, 0.9).set_trans(Tween.TRANS_SINE)
		_npcs.append({"def": n, "node": v, "armed": true})
	_build_portal()

	if place == "prontera":
		var wbp: Node3D = load("res://scripts/core/wb_portal.gd").new(self, world)
		wbp.position = _at(GameData.WB_PORTAL_CELL) + GameData.WB_PORTAL_NUDGE
		add_child(wbp)
	_build_talk_button()
	_ensure_names()
	if place != "prontera":
		_emote_clock = -0.8
		return
	_build_props()

	_crowd = TownCrowd.new()
	add_child(_crowd)
	_crowd.setup(self)
	_build_hud()
	_emote_clock = -0.8
	get_tree().create_timer(0.7).timeout.connect(_kafra_welcome)

	if Save.rebirth_lv_ready(class_id):
		get_tree().create_timer(2.4).timeout.connect(_valkyrie_call)



func _build_props() -> void :
	for pr in GameData.TOWN_PROPS:
		var path: = RoAssets.model_path(str(pr.model))
		if path == "":
			continue

		if pr.has("npc") and not Save.npc_unlocked(str(pr.npc)):
			continue
		var node: Node3D = (load(path) as PackedScene).instantiate()
		add_child(node)

		var box: = _model_box(node)
		var k: = float(pr.h) / maxf(0.01, box.size.y)
		node.scale = Vector3.ONE * k
		node.rotation_degrees.y = float(pr.get("rot", 0.0))
		var cell: Vector2 = pr.cell
		var c: = world.map.cell_center(int(cell.x), int(cell.y)) + Vector3(fposmod(cell.x, 1.0) - 0.5, 0, 0.5 - fposmod(cell.y, 1.0))
		var foot: = (box.get_center() * k).rotated(Vector3.UP, node.rotation.y)
		node.position = Vector3(c.x - foot.x, world.map.height_at(c) - box.position.y * k, c.z - foot.z)
		world.map.block_cell(int(cell.x), int(cell.y))
		if pr.get("fire", false):
			var top: = c + Vector3(0, world.map.height_at(c) + float(pr.h) * 0.62, 0)
			var fx: = RoEffect.spawn(self, "firewall", top, 0.4)
			if fx != null:
				fx.loop = true
			var light: = OmniLight3D.new()
			light.light_color = Color(1.0, 0.6, 0.25)
			light.omni_range = 4.0
			light.light_energy = 1.2
			light.position = top + Vector3(0, 0.3, 0)
			add_child(light)
			var tw: = light.create_tween().set_loops()
			tw.tween_property(light, "light_energy", 0.8, 0.25)
			tw.tween_property(light, "light_energy", 1.3, 0.2)
		if pr.get("lamp", false):
			var lamp: = OmniLight3D.new()
			lamp.light_color = Color(1.0, 0.85, 0.6)
			lamp.omni_range = 3.5
			lamp.light_energy = 0.9
			lamp.position = node.position + Vector3(foot.x, float(pr.h) * 0.85, foot.z)
			add_child(lamp)


static func _model_box(n: Node) -> AABB:
	var out: = AABB()
	var first: = true
	for m: MeshInstance3D in n.find_children("*", "MeshInstance3D", true, false):
		var t: = Transform3D.IDENTITY
		var p: Node = m
		while p != n and p is Node3D:
			t = (p as Node3D).transform * t
			p = p.get_parent()
		var a: = t * m.get_aabb()
		out = a if first else out.merge(a)
		first = false
	return out




func _town_npcs() -> Array:
	var out: = GameData.TOWN_NPCS.duplicate()
	for n in GameData.TOWN_NPCS:
		if Save.npc_unlocked(str(n.id)):
			continue
		var title: = tr(str(n.name)) + "  ·  " + tr(str(n.get("title", "")))
		out.append({"id": "poster_" + str(n.id), "poster_of": str(n.id), "sprite": "npc_bulletin_board", 
			"name": "Se busca", "title": title, "cell": n.cell, "dir": 0, "face_center": n.get("face_center", false), 
			"color": Color(0.95, 0.78, 0.5), "lines": []})
	return out



func npc_node(id: String) -> RoVisual:
	for n in _npcs:
		if str(n.def.id) == id:
			return n.node
	return null




func _center_shift(v: RoVisual) -> Vector3:
	if v.ro == null:
		return Vector3.ZERO
	var used: = v.ro.compose_image(0, 0).get_used_rect()
	if not used.has_area():
		return Vector3.ZERO
	var off: = used.position.x + used.size.x * 0.5 - v.ro.origin.x
	return Vector3( - off * GameData.PIXEL_SIZE * v.scale.x, 0, 0)


func _at(cell: Vector2i) -> Vector3:
	var c: = world.map.cell_center(cell.x, cell.y)
	return Vector3(c.x, world.map.height_at(c), c.z)




func sync_party(list: Array, me: int) -> void :


	if world.channel.covers_party():
		list = []
	var keep: = {}
	for m in list:
		var id: = int(m.id)
		if id == me:
			continue
		keep[id] = true
		var known: Dictionary = _party.get(id, {})

		if not known.is_empty():
			known["hg"] = int(m.get("hg", 0))
			known["rl"] = clampi(int(m.get("rl", 0)), 0, GameData.REBIRTH_LV_MAX)

		if not known.is_empty() and str(known["class"]) == str(m["class"]) and known.get("views", {}) == m.get("views", {})\
		and known.get("look", {}) == m.get("look", {}):
			_set_member_pet(id, str(m.get("pet", "")))
			continue
		var at: = hero.position + Vector3(randf_range(-1.5, 1.5), 0, 1.5)
		if not known.is_empty():
			at = (known.node as Node3D).position
			(known.node as Node).queue_free()
		var node: = _party_hero(str(m["class"]), m.get("look", {}), str(m.name), at, m.get("views", {}))
		_party[id] = {"node": node, "class": str(m["class"]), "to": at, "dir": 0, "action": RoVisual.PC_IDLE, 
			"label": str(node.get_meta("label")), "doing": "", "views": m.get("views", {}), "look": m.get("look", {}), 
			"hg": int(m.get("hg", 0)), "rl": clampi(int(m.get("rl", 0)), 0, GameData.REBIRTH_LV_MAX), "pet": known.get("pet"), "pet_id": str(known.get("pet_id", ""))}
		_set_member_pet(id, str(m.get("pet", "")))
		_ensure_names()
	for id in _party.keys():
		if id > 0 and not keep.has(id):
			drop_party_member(id)







func sync_channel(list: Array) -> void :
	var keep: = {}

	var beams: = list.filter( func(m): return not _party.has(int(m.id))).size() <= CHANNEL_BEAMS

	var whole: = world.channel.covers_party()


	var listed: = {}
	for m in list:
		listed[int(m.id)] = true
	var orphans: Array = _party.keys().filter( func(id): return id < 0 and not listed.has(id))
	for m in list:
		var id: = int(m.id)
		if bool(m.party) and not whole:
			continue
		keep[id] = true
		var known: Dictionary = _party.get(id, {})

		if not known.is_empty():
			known["title"] = str(m.get("title", ""))
			known["sup"] = str(m.get("sup", ""))
			known["sup_i"] = bool(m.get("sup_i", true))
			known["sup_a"] = bool(m.get("sup_a", true))
			known["ang"] = bool(m.get("ang", false))
			known["hw"] = bool(m.get("hw", false))
			known["hg"] = int(m.get("hg", 0))
			known["rl"] = int(m.get("rl", 0))
		if not known.is_empty() and _same_look(known, m):
			_coming.erase(id)
			_set_member_pet(id, str(m.get("pet", "")))
			continue
		if known.is_empty():
			var mine: = orphans.filter( func(o): return str(_party[o].get("name", "")) == str(m.name) and _same_look(_party[o], m))
			if not mine.is_empty():
				_party[id] = _party[mine[0]]
				_party.erase(mine[0])
				orphans.erase(mine[0])
				_set_member_pet(id, str(m.get("pet", "")))
				continue


		if known.is_empty() and m.at == Vector3.INF:
			continue
		var args: = _sprite_args(str(m["class"]), m.get("look", {}), m.get("views", {}))
		var key: = var_to_str(args)
		var coming: Dictionary = _coming.get(id, {})
		if coming.is_empty() or str(coming.key) != key:
			var task: = WorkerThreadPool.add_task(RoAssets.styled_character.bindv(args), false, "member sprite")
			_tasks.append(task)
			_coming[id] = {"m": m, "key": key, "beam": known.is_empty() and beams, "doing": "", "task": task}
		else:
			coming.m = m
	for id in _coming.keys():
		if not keep.has(id):
			_coming.erase(id)
	for id in _party.keys():
		if id < 0 and not keep.has(id):
			var gone: Node3D = _party[id].node
			if world.channel.is_in() and is_instance_valid(gone):
				_warp_fx(gone.position)
			drop_party_member(id)




const ARRIVE_PER_FRAME: = 2

const ARRIVE_FADE: = 0.35

var _coming: = {}

var _tasks: Array = []



func _tick_coming() -> void :
	for t in _tasks.duplicate():
		if WorkerThreadPool.is_task_completed(t):
			WorkerThreadPool.wait_for_task_completion(t)
			_tasks.erase(t)
	if _coming.is_empty():
		return
	var ready: Array = _coming.keys().filter( func(id): return not _tasks.has(_coming[id].task))
	ready.sort_custom( func(a, b): return _coming_at(a).distance_squared_to(hero.position) < _coming_at(b).distance_squared_to(hero.position))
	for id in ready.slice(0, ARRIVE_PER_FRAME):
		var c: Dictionary = _coming[id]
		_coming.erase(id)
		_draw_member(int(id), c.m, bool(c.beam), str(c.doing))


func _coming_at(id: int) -> Vector3:
	var m: Dictionary = _coming[id].m
	return m.at if m.at != Vector3.INF else hero.position




func _draw_member(id: int, m: Dictionary, beam: bool, doing: String) -> void :
	var known: Dictionary = _party.get(id, {})
	var at: Vector3 = m.at if m.at != Vector3.INF else _at(PORTAL_CELL)
	if not known.is_empty():
		at = (known.node as Node3D).position
		(known.node as Node).queue_free()
	var node: = _party_hero(str(m["class"]), m.get("look", {}), str(m.name), at, m.get("views", {}), bool(m.party))

	if not node.has_meta("dev"):
		RebirthAura.attach(node, m.get("rb", []), bool(m.get("ra", false)))
	if known.is_empty():
		if beam:
			_warp_fx(at)
		elif node.sprite != null:
			node.sprite.modulate.a = 0.0
			node.create_tween().tween_property(node.sprite, "modulate:a", 1.0, ARRIVE_FADE)
	_party[id] = {"node": node, "class": str(m["class"]), "to": at, "dir": int(known.get("dir", m.get("dir", 0))), 
		"action": int(known.get("action", m.get("action", RoVisual.PC_IDLE))), "label": str(node.get_meta("label")), 
		"doing": str(known.get("doing", doing)), "views": m.get("views", {}), "look": m.get("look", {}), "party": bool(m.party), 
		"rb": m.get("rb", []), "ra": bool(m.get("ra", false)), "name": str(m.name), "title": str(m.get("title", "")), 
		"sup": str(m.get("sup", "")), "sup_i": bool(m.get("sup_i", true)), "sup_a": bool(m.get("sup_a", true)), "ang": bool(m.get("ang", false)), "hw": bool(m.get("hw", false)), "hg": int(m.get("hg", 0)), "rl": int(m.get("rl", 0)), "pet": known.get("pet"), "pet_id": str(known.get("pet_id", ""))}
	_set_member_pet(id, str(m.get("pet", "")))
	_ensure_names()



static func _same_look(known: Dictionary, m: Dictionary) -> bool:
	return str(known["class"]) == str(m["class"]) and known.get("views", {}) == m.get("views", {})\
	and known.get("look", {}) == m.get("look", {}) and bool(known.get("party", false)) == bool(m.party)\
	and known.get("rb", []) == m.get("rb", []) and bool(known.get("ra", false)) == bool(m.get("ra", false))




func _sprite_args(cls: String, look: Dictionary, views: Dictionary) -> Array:
	var worn: Dictionary = (look if not look.is_empty() else Save.look(cls)).duplicate(true)
	var job: Dictionary = GameData.shown_job(cls if GameData.CLASSES.has(cls) else "swordsman", worn)
	return [str(job.body), str(job.weapon), str(job.weapon_fx), [job.attack], str(views.get("head", "")), worn, 
		str(views.get("shield", "")), (views.get("extras", []) as Array).duplicate()]


func _exit_tree() -> void :
	for t in _tasks:
		WorkerThreadPool.wait_for_task_completion(t)
	_tasks.clear()



func member_doing(id: int, doing: String) -> void :
	var m: Dictionary = _party.get(id, {})
	if not m.is_empty():
		m.doing = tr(str(GameData.TOWN_DOING.get(doing, "")))
	elif _coming.has(id):
		_coming[id].doing = tr(str(GameData.TOWN_DOING.get(doing, "")))


var _dress_key: = ""
var _dress_t: = 0.0




func _check_dress(delta: float) -> void :
	_dress_t -= delta
	if _dress_t > 0.0:
		return
	_dress_t = 0.5
	var gear: = Equipment.loadout_views(class_id)
	var look: Dictionary = Save.look(class_id)
	var key: = var_to_str([gear.head, gear.extras, look])
	if key == _dress_key:
		return
	var first: = _dress_key == ""
	_dress_key = key
	if first:
		return
	_dress_hero()





func _lies_down() -> bool:
	var show: = str(Save.look(class_id).get("show", ""))
	return show.begins_with("outfit_") and not GameData.outfit_sits(show)



func _dress_hero() -> void :
	var gear: = Equipment.loadout_views(class_id)
	var look: Dictionary = Save.look(class_id)
	_dress_key = var_to_str([gear.head, gear.extras, look])
	var shown: Dictionary = GameData.shown_job(class_id, look)
	var ro: = RoAssets.styled_character(shown.body, shown.weapon, shown.weapon_fx, [shown.attack], gear.head, look, "", gear.extras)
	if ro != null:
		hero.ro = ro
		hero.sprite.offset = Vector2( - ro.origin.x, ro.origin.y - ro.canvas_size.y)
		hero._refresh()




func set_real_players(n: int) -> void :
	if _crowd != null:
		_crowd.set_real(n)



func _warp_fx(at: Vector3) -> void :
	Vfx.column(world.fx_root, at, Color(0.85, 0.92, 1.0))
	world.play_sound("portal", 0.2, -12.0)



const DEV_SCALE: = 1.3



func is_dev_hero() -> bool:
	return NameFilter.dev_name(Save.char_name(class_id)) and Save.is_dev()




func _dev_aura(v: Node3D) -> void :

	v.scale = Vector3.ONE * DEV_SCALE
	var aura: = RebirthAura.new()
	aura.rainbow = true
	v.add_child(aura)
	if v is RoVisual:
		(v as RoVisual).cover_aura(GameData.HERO_FX_PRIORITY + 1)





func _party_hero(cls: String, look: Dictionary, shown: String, at: Vector3, views: Dictionary = {}, party: = true) -> RoVisual:
	var d: Dictionary = GameData.CLASSES.get(cls, GameData.CLASSES.swordsman)
	var v: = RoVisual.new()
	add_child(v)
	var worn: Dictionary = look if not look.is_empty() else Save.look(cls)
	var job: Dictionary = GameData.shown_job(cls if GameData.CLASSES.has(cls) else "swordsman", worn)


	v.setup(RoAssets.styled_character(job.body, job.weapon, job.weapon_fx, 
		[job.attack], str(views.get("head", "")), worn, 
		str(views.get("shield", "")), views.get("extras", [])), d.color, 44)
	v.show_through()
	v.hold_idle = true
	v.position = at
	v.play(RoVisual.PC_IDLE)
	if party:
		Vfx.ground_glow(v, Vector3(0, 0.03, 0), 1.0, Color(0.55, 0.85, 1.0, 0.45))
	var dev: = NameFilter.dev_name(shown)
	shown = NameFilter.shown(shown)
	if dev:
		_dev_aura(v)
		v.set_meta("dev", true)
		v.set_meta("label", "%s · Dev" % shown)
		return v
	v.set_meta("label", tr(str(d.name)) if shown == "" or shown == tr(str(d.name)) else "%s · %s" % [shown, tr(str(d.name))])
	return v


func move_party_member(id: int, x: float, z: float, dir: int, action: int, doing: = "") -> void :
	var m: Dictionary = _party.get(id, {})
	if m.is_empty():

		if _coming.has(id):
			var c: Dictionary = _coming[id]
			c.m = c.m.duplicate()
			c.m.at = Vector3(x, 0, z)
			c.m.dir = dir
			c.m.action = action
			c.doing = tr(str(GameData.TOWN_DOING.get(doing, "")))
		return
	m.to = Vector3(x, 0, z)
	m.dir = dir
	m.action = action
	m.doing = tr(str(GameData.TOWN_DOING.get(doing, "")))


var _names: CanvasLayer




func _ensure_names() -> void :
	if _names != null:
		return
	_names = CanvasLayer.new()
	_names.layer = 4
	add_child(_names)
	var c: = PartyNames.new()
	c.town = self
	_names.add_child(c)


class PartyNames extends Control:
	const FONT = preload("res://assets/ro/fonts/SCDream4.otf")

	const TITLE_FS: = 12

	const DEV_NAME_FS: = 16
	const DEV_TITLE_FS: = 15

	const RANK_FS: = 13

	const HEAD_GAP: = 0.15
	var town: Town

	func _ready() -> void :
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _process(_delta: float) -> void :
		queue_redraw()

	func _draw() -> void :
		var cam: Camera3D = town.world.camera
		var k: = maxf(1.0, floorf(get_viewport_rect().size.y / 700.0))


		var npc_feet: Array[Vector2] = []
		var in_town: bool = town.world.menus.mode() == "town"
		var bob: = sin(Time.get_ticks_msec() / 1000.0 * 3.2) * 3.0 * k
		for i in town._npcs.size():
			var node: RoVisual = town._npcs[i].node
			if not node.visible or cam.is_position_behind(node.position):
				continue
			npc_feet.append(cam.unproject_position(node.position + RoVisual.world_lift() - Vector3(0, 0.62, 0)))




			var em = node.get_meta("emote") if node.has_meta("emote") else null
			if em != null and is_instance_valid(em):
				continue
			if in_town and town._npcs[i].def.get("event", false) and Save.festival_daily_ready():
				_event_sign(town.npc_head(i) + Vector2(0, -10.0 * k + bob), k)
			elif in_town and i != town._near:
				_marker(town.npc_head(i) + Vector2(0, -8.0 * k + bob), k, Color(town._npcs[i].def.color))

		var own: Variant = town.hero.get_meta("name_label") if town.hero.has_meta("name_label") else null
		var mine: String = town.world.titles.active() if town.world.titles != null else ""

		var my_sup: String = town.world.titles.supporter() if town.world.titles != null else ""
		if my_sup != "" and own is Label3D and is_instance_valid(own) and not town.is_dev_hero() and not cam.is_position_behind(town.hero.position):
			var lab: = own as Label3D
			lab.modulate = town.world.titles.support_color(my_sup)


			var lw: float = lab.font.get_string_size(lab.text, HORIZONTAL_ALIGNMENT_LEFT, -1, lab.font_size).x if lab.font != null else 60.0
			var left_pt: = cam.unproject_position(lab.global_position - cam.global_basis.x.normalized() * lw * lab.pixel_size * 0.5)
			if town.world.titles.support_icon_on():
				town.world.titles.draw_support_icon(self, left_pt, my_sup, 14.0 * k)
		if mine != "" and own is Label3D and is_instance_valid(own) and not cam.is_position_behind(town.hero.position):
			var at: = cam.unproject_position((own as Label3D).global_position)
			var mfs: = DEV_TITLE_FS if town.is_dev_hero() else TITLE_FS
			var th: float = town.world.titles.measure(mine, mfs, k, true).y
			town.world.titles.draw_title(self, at + Vector2(0, 8.0 * k + th * 0.5), mine, mfs, k, 1.0, true)

		if (town.own_rlv > 0 or town.own_harmony > 0) and not cam.is_position_behind(town.hero.position):
			var top: = _over_head(town.hero, town.own_looks, cam)
			_rank_line(top, town.own_rlv, town.own_harmony, k, _npc_fade(top, npc_feet, k))
		for id in town._party:
			var m: Dictionary = town._party[id]
			var v: Node3D = m.node
			if not is_instance_valid(v) or cam.is_position_behind(v.position):
				continue
			var feet: = cam.unproject_position(v.position + RoVisual.world_lift() - Vector3(0, 0.62, 0))
			var col: = Color(0.6, 0.88, 1.0) if m.get("party", true) else Color(1.0, 1.0, 1.0)


			if (m.get("rb", []) as Array).has("valhalla"):
				col = GameData.REBIRTH_LV_GOLD
			if v.get_meta("dev", false):
				col = NameFilter.DEV_COLOR
			for f in npc_feet:
				if absf(f.x - feet.x) < 70.0 * k and absf(f.y - feet.y) < 34.0 * k:
					col.a = 0.3
					break
			var is_dev: bool = v.get_meta("dev", false)
			var name_fs: = DEV_NAME_FS if is_dev else 12

			var sup: = str(m.get("sup", ""))
			if sup != "" and not is_dev:
				col = Color(town.world.titles.support_color(sup), col.a)
				var nsize: = int(name_fs * k)
				var nw: = FONT.get_string_size(str(m.label), HORIZONTAL_ALIGNMENT_LEFT, -1, nsize).x
				if m.get("sup_i", true):
					town.world.titles.draw_support_icon(self, feet + Vector2( - nw * 0.5, FONT.get_height(nsize) * 0.5), sup, FONT.get_height(nsize), col.a)

				var gp: = (feet + Vector2( - nw * 0.5, FONT.get_ascent(nsize))).floor()
				draw_string_outline(FONT, gp, str(m.label), HORIZONTAL_ALIGNMENT_LEFT, -1, nsize, int(7 * k), Color(col, 0.35 * col.a))

			if int(m.get("rl", 0)) > 0 or int(m.get("hg", 0)) > 0:
				var top: = _over_head(v as RoVisual, m.get("rb", []) if m.get("rb") is Array else [], cam)
				_rank_line(top, int(m.get("rl", 0)), int(m.get("hg", 0)), k, _npc_fade(top, npc_feet, k))
			_text(str(m.label), feet, k, col, name_fs)
			var below: = feet + Vector2(0, FONT.get_height(int(name_fs * k)) + 1.0 * k)

			var title: = str(m.get("title", ""))
			if title != "":
				var tfs: = DEV_TITLE_FS if is_dev else TITLE_FS
				var th: float = town.world.titles.measure(title, tfs, k, true).y
				town.world.titles.draw_title(self, below + Vector2(0, th * 0.5), title, tfs, k, col.a, true)
				below.y += th + 1.0 * k

			if str(m.doing) != "":
				_text(str(m.doing), below, k, Color(1.0, 0.88, 0.45, col.a), 11)



	func _npc_fade(at: Vector2, npc_feet: Array[Vector2], k: float) -> float:
		for f in npc_feet:
			if absf(f.x - at.x) < 70.0 * k and absf(f.y - at.y) < 34.0 * k:
				return 0.3
		return 1.0





	func _over_head(v: RoVisual, looks: Array, cam: Camera3D) -> Vector2:
		if v == null or not is_instance_valid(v):
			return Vector2.INF
		if v.has_meta("emote") and is_instance_valid(v.get_meta("emote")):
			return Vector2.INF
		for c in v.get_children():
			if c.has_meta("chat") and not c.is_queued_for_deletion():
				return Vector2.INF
		var base: = v.position + RoVisual.world_lift()
		var top: = cam.unproject_position(base + cam.global_basis.y.normalized() * (town.world._sprite_height(v) + HEAD_GAP))
		if looks.has("crown") or looks.has("halo"):
			top.y = minf(top.y, cam.unproject_position(base + Vector3(0, v.height() + RebirthFlair.CROWN_Y + 0.3, 0)).y)
		return top




	func _rank_line(bottom: Vector2, rlv: int, hg: int, k: float, a: float) -> void :
		if not bottom.is_finite() or k <= 0.0:
			return
		var parts: = []
		if rlv > 0:
			parts.append([GameData.rebirth_name(mini(rlv, GameData.REBIRTH_LV_MAX)), GameData.REBIRTH_LV_GOLD])
		if hg > 0 and hg < GameData.WEAPON_GRADES.size():
			parts.append([tr("Armonía %s") % str(GameData.WEAPON_GRADES[hg].name), (GameData.WEAPON_GRADES[hg].color as Color).lightened(0.15)])
		if parts.is_empty():
			return
		var size: = int(RANK_FS * k)
		var sep: = " · "
		var sep_w: = FONT.get_string_size(sep, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var w: = sep_w * (parts.size() - 1)
		for pt in parts:
			w += FONT.get_string_size(str(pt[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var p: = Vector2(bottom.x - w * 0.5, bottom.y - FONT.get_descent(size) - 1.0 * k).floor()
		for i in parts.size():
			if i > 0:
				_seg(p, sep, size, k, Color(0.85, 0.87, 0.92, a))
				p.x += sep_w
			_seg(p, str(parts[i][0]), size, k, Color(parts[i][1], a))
			p.x += FONT.get_string_size(str(parts[i][0]), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

	func _seg(p: Vector2, t: String, size: int, k: float, col: Color) -> void :


		draw_string_outline(FONT, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, int(4 * k), Color(0, 0, 0, 0.9 * col.a))
		draw_string(FONT, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


	func _marker(at: Vector2, k: float, col: Color) -> void :


		if not at.is_finite() or k <= 0.0:
			return
		var w: = 9.0 * k
		var pts: = PackedVector2Array([at + Vector2( - w, - w * 1.2), at + Vector2(w, - w * 1.2), at])
		var edge: = PackedVector2Array([at + Vector2( - w - 2.5 * k, - w * 1.2 - 2.0 * k), at + Vector2(w + 2.5 * k, - w * 1.2 - 2.0 * k), at + Vector2(0, 3.0 * k)])
		draw_colored_polygon(edge, Color(0.05, 0.06, 0.14, 0.9))
		draw_colored_polygon(pts, col.lightened(0.25))



	func _event_sign(at: Vector2, k: float) -> void :
		if not at.is_finite() or k <= 0.0:
			return
		var t: = TranslationServer.translate("DIARIO")
		var size: = int(12 * k)
		var tw: = FONT.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var r: = Rect2(at + Vector2( - tw * 0.5 - 8.0 * k, -20.0 * k), Vector2(tw + 16.0 * k, 18.0 * k))
		var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 4.0)
		var glow: = StyleBoxFlat.new()
		glow.bg_color = Color(1.0, 0.75, 0.2, 0.25 + 0.2 * pulse)
		glow.set_corner_radius_all(int(9 * k))
		draw_style_box(glow, r.grow(3.0 * k))
		var plate: = StyleBoxFlat.new()
		plate.bg_color = Color(0.98, 0.78, 0.25)
		plate.border_color = Color(0.45, 0.22, 0.05)
		plate.set_border_width_all(maxi(1, int(2 * k)))
		plate.set_corner_radius_all(int(6 * k))
		draw_style_box(plate, r)

		var tip: = PackedVector2Array([Vector2(at.x - 5.0 * k, r.end.y - 1.0), Vector2(at.x + 5.0 * k, r.end.y - 1.0), Vector2(at.x, r.end.y + 6.0 * k)])
		draw_colored_polygon(tip, Color(0.45, 0.22, 0.05))
		var p: = (Vector2(at.x - tw * 0.5, r.position.y + (r.size.y - FONT.get_height(size)) * 0.5 + FONT.get_ascent(size))).floor()
		draw_string(FONT, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0.4, 0.15, 0.02))
		for side in [-1.0, 1.0]:
			var c: = Vector2(at.x + side * (r.size.x * 0.5 + 7.0 * k), r.position.y + 3.0 * k)
			var s: = (2.5 + 2.0 * pulse) * k
			draw_line(c - Vector2(s, 0), c + Vector2(s, 0), Color(1.0, 0.95, 0.6, 0.9), maxf(1.0, k))
			draw_line(c - Vector2(0, s), c + Vector2(0, s), Color(1.0, 0.95, 0.6, 0.9), maxf(1.0, k))

	func _text(t: String, at: Vector2, k: float, col: Color, base: int) -> void :
		var size: = int(base * k)
		var w: = FONT.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var p: = (at + Vector2( - w * 0.5, FONT.get_ascent(size))).floor()
		draw_string_outline(FONT, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, int(3 * k), Color(0, 0, 0, 0.85 * col.a))
		draw_string(FONT, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)





func open_chat(text: = "") -> void :
	if _crowd != null:
		_crowd.open_chat.call_deferred(text)



func party_chat(id: int, line: String) -> void :
	var m: Dictionary = _party.get(id, {})
	if not m.is_empty() and is_instance_valid(m.node) and _crowd != null:
		_crowd.chat(m.node, line)



func party_emote(id: int, idx: int) -> void :
	var m: Dictionary = _party.get(id, {})
	if not m.is_empty() and is_instance_valid(m.node):
		world.emote_at(m.node, idx, 2.0)




func party_event(id: int, kind: String, ok: bool) -> void :
	var m: Dictionary = _party.get(id, {})
	if m.is_empty() or not is_instance_valid(m.node):
		return
	var v: Node3D = m.node
	if kind.begins_with("emote:"):
		var idx: = int(kind.substr(6))
		if idx >= 0 and idx < 256:
			world.emote_at(v, idx, 2.0)
		return
	RoEffect.spawn(world.fx_root, "bs_refinesuccess" if ok else "bs_refinefailed", v.position, 1.0, v)
	world.play_sound(("refine_ok" if RoAssets.sound("refine_ok") != null else "levelup") if ok
		else ("refine_fail" if RoAssets.sound("refine_fail") != null else "cold_hit1"), 0.1, -8.0)
	world.emote(v, "grats" if ok else "sweat", 1.8)


func drop_party_member(id: int) -> void :
	var m: Dictionary = _party.get(id, {})
	_party.erase(id)
	if not m.is_empty() and is_instance_valid(m.node):
		(m.node as Node).queue_free()
	if not m.is_empty() and m.get("pet") != null and is_instance_valid(m.pet):
		(m.pet as Node).queue_free()



func clear_party() -> void :
	for id in _party.keys():
		if id > 0:
			drop_party_member(id)



func _tick_party(delta: float) -> void :
	var k: = 1.0 - exp( - minf(delta, 0.05) * 12.0)
	for id in _party:
		var m: Dictionary = _party[id]
		var v: RoVisual = m.node
		if not is_instance_valid(v):
			continue
		var to: Vector3 = m.to
		var at: = v.position.lerp(Vector3(to.x, world.map.height_at(to), to.z), k)
		v.position = at
		if v.dir != int(m.dir):
			v.dir = int(m.dir)
			v._refresh()
		v.play(int(m.action))


		v.speed_scale = 0.0 if int(m.action) in [PC_SIT, RoVisual.PC_DEAD] else 1.0
		_fade_in_front(v)
		var pet = m.get("pet")
		if pet != null and is_instance_valid(pet):
			_pet_follow(pet, v, delta)




const PET_SCALE: = 0.55




const PET_PX: = 44.0
const PET_PX_MVP: = 68.0

const PET_SCALE_MIN: = 0.22
const PET_SCALE_MAX: = 1.0
const PET_SCALE_MAX_MVP: = 1.3
static var _pet_dims: = {}



static func pet_scale(id: String, ro: RoSprite) -> float:
	if not _pet_dims.has(id):
		var used: = ro.compose_image(0, 0).get_used_rect() if ro != null else Rect2i()
		_pet_dims[id] = maxf(float(used.size.y), float(used.size.x) * 0.8)
	var dim: float = _pet_dims[id]
	if dim <= 0.0:
		return PET_SCALE
	var mvp: bool = GameData.PETS[id].get("mvp", false)
	return clampf((PET_PX_MVP if mvp else PET_PX) / dim, PET_SCALE_MIN, PET_SCALE_MAX_MVP if mvp else PET_SCALE_MAX)

const PET_NEAR: = 1.7
const PET_JUMP: = 9.0


func _make_town_pet(id: String, at: Vector3) -> RoVisual:
	if id == "" or not GameData.PETS.has(id) or not GameData.MONSTERS.has(id) or not RoAssets.has_sprite(id):
		return null
	var v: = RoVisual.new()
	add_child(v)
	v.setup(RoAssets.sprite([id]), GameData.MONSTERS[id].color, 30, 0.5)
	v.scale = Vector3.ONE * pet_scale(id, v.ro)
	v.show_through(0.3)
	v.position = at + Vector3(PET_NEAR, 0, 0.3)
	v.position.y = world.map.height_at(v.position)
	v.play(RoVisual.MOB_IDLE)
	return v



func _set_member_pet(id: int, pet_id: String) -> void :
	var m: Dictionary = _party.get(id, {})
	if m.is_empty():
		return
	var old = m.get("pet")
	var alive: bool = old != null and is_instance_valid(old)
	if str(m.get("pet_id", "")) == pet_id and (alive or pet_id == ""):
		return
	if alive:
		(old as Node).queue_free()
	m["pet_id"] = pet_id
	m["pet"] = _make_town_pet(pet_id, (m.node as Node3D).position) if is_instance_valid(m.node) else null



func _tick_hero_pet(delta: float) -> void :
	var want: = Save.pet_skin()
	if want != _hero_pet_id or (want != "" and (_hero_pet == null or not is_instance_valid(_hero_pet))):
		_hero_pet_id = want
		if _hero_pet != null and is_instance_valid(_hero_pet):
			_hero_pet.queue_free()
		_hero_pet = _make_town_pet(want, hero.position)
	if _hero_pet != null and is_instance_valid(_hero_pet):
		_pet_follow(_hero_pet, hero, delta)




func _pet_follow(v: RoVisual, owner: Node3D, delta: float) -> void :
	var away: = (v.position - owner.position) * Vector3(1, 0, 1)
	if away.length_squared() < 0.0001:
		away = Vector3(1, 0, 0)
	var spot: = owner.position + away.normalized() * PET_NEAR
	var to: = (spot - v.position) * Vector3(1, 0, 1)
	var d: = to.length()
	if d > PET_JUMP:
		v.position = spot
	elif d > 0.12:
		var speed: = maxf(GameData.TOWN_WALK_SPEED * _speed, d * 4.0)
		v.position += to / d * minf(d, speed * delta)
		v.face(to)
		v.play(RoVisual.MOB_WALK)
	else:
		v.play(RoVisual.MOB_IDLE)
	v.position.y = world.map.height_at(v.position)





static func readable(l: Label3D) -> void :
	l.outline_size = maxi(10, roundi(l.font_size * 0.42))
	l.outline_modulate = Color(0, 0, 0, 1.0)
	l.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR



static func _name_label(node: Node3D, text: String, title: = "") -> void :
	var l: = Label3D.new()
	l.text = text
	l.font = World.RO_UI_FONT
	l.font_size = 32
	l.pixel_size = 0.012
	readable(l)
	l.modulate = NAME_COLOR
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 20
	l.outline_render_priority = 19
	l.position = RoVisual.lift + Vector3(0, -0.35, 0)
	l.set_meta("drop", 0.4)
	node.add_child(l)
	if title != "":
		var t: = Label3D.new()
		t.text = title
		t.font = World.RO_UI_FONT
		t.font_size = 27
		t.pixel_size = 0.012
		readable(t)
		t.modulate = Color(0.88, 0.9, 0.97)
		t.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		t.no_depth_test = true
		t.render_priority = 20
		t.outline_render_priority = 19

		t.position = l.position + Vector3(0, - cos(World.CAMERA_PITCH), sin(World.CAMERA_PITCH)) * 0.5
		t.set_meta("drop", 0.9)
		node.add_child(t)



func _build_portal() -> void :
	_portal_pos = _at(_cell("portal_cell"))
	var portal: = Node3D.new()
	add_child(portal)
	portal.position = _portal_pos
	var color: = Color(0.55, 0.75, 1.0)
	Vfx.warp_portal(portal, color, 1.1)
	var glow: = Vfx.ground_glow(portal, Vector3.ZERO, 2.0, Color(color, 0.5))
	glow.no_depth_test = true
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.2, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.5, 0.7).set_trans(Tween.TRANS_SINE)
	var l: = Label3D.new()
	l.text = tr("Mapa del mundo") if place == "tower_gate" else tr("¡A la aventura!")
	l.font = World.RO_UI_FONT
	l.font_size = 30
	l.pixel_size = 0.012
	l.outline_size = 8
	l.outline_modulate = Color(0, 0, 0, 0.85)
	l.modulate = Color(1.0, 0.92, 0.6)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 20
	l.outline_render_priority = 19
	l.position = Vector3(0, 2.4, 0)
	portal.add_child(l)




func refresh_kafra() -> void :
	var v: = npc_node("kafra")
	if v == null:
		return
	var spr: = RoAssets.sprite([Save.kafra()])
	if spr == null:
		return
	v.ro = spr
	v.sprite.offset = Vector2( - spr.origin.x, spr.origin.y - spr.canvas_size.y)
	v.play(RoVisual.MOB_IDLE, true, true)
	v.face(hero.position - v.position)
	Vfx.column(world.fx_root, v.position, Color(0.85, 0.85, 1.0))
	world.play_sound("teleport", 0.0, -6.0)




func _kafra_welcome() -> void :
	if not is_inside_tree() or _npcs.is_empty():
		return
	var kafra: RoVisual = _npcs[0].node
	kafra.face(hero.position - kafra.position)
	world.emote(kafra, "love", 2.2)
	world.play_sound("blessing", 0.0, -2.0)
	world.sprite_fx("fx_blessing", hero.position, 0, 1.0, hero)
	get_tree().create_timer(0.6).timeout.connect( func():
		if not is_inside_tree():
			return
		world.play_sound("increase_agi", 0.0, -2.0)
		world.rising_tex(hero, "agi_up", 1)
		_speed = AGI_SPEED)





var _label_t: = 0.0

func label_k() -> float:
	return clampf(world._cam_distance / 42.0, 0.4, 1.0)


func _scale_labels(delta: float) -> void :
	_label_t -= delta
	if _label_t > 0.0:
		return
	_label_t = 0.2
	var k: = label_k()


	var down: = Vector3(0, - cos(World.cam_pitch), sin(World.cam_pitch))
	for l: Label3D in find_children("*", "Label3D", true, false):
		if not l.has_meta("base_scale"):
			l.set_meta("base_scale", l.scale)
		l.scale = (l.get_meta("base_scale") as Vector3) * k
		if l.has_meta("drop"):
			l.position = RoVisual.lift + down * float(l.get_meta("drop")) * maxf(k, 0.7)




const PC_SIT: = 2
var sitting: = false

func toggle_sit() -> void :
	sitting = not sitting
	world.mouse_walk.cancel()
	_going_to = -1





func _rest_pose() -> void :
	if sitting:
		hero.play(RoVisual.PC_DEAD if _lies_down() else PC_SIT)
		hero.speed_scale = 0.0
	else:
		hero.play(RoVisual.PC_IDLE)
		hero.speed_scale = 1.0







const ANGEL_AURA = preload("res://scripts/ro/angel_aura.gd")
var _angel_t: = 0.0
func _tick_angel_auras(delta: float) -> void :
	_angel_t -= delta
	if _angel_t > 0.0:
		return
	_angel_t = 0.5
	if hero != null and is_instance_valid(hero):
		ANGEL_AURA.set_on(hero, world.titles != null and world.titles.angel_aura_shown())

		HEL_LOOK.set_on(hero, hel_worn(class_id))


		own_rlv = Save.rebirth_lv(class_id)
		own_looks = Save.rebirth_looks(class_id)
		own_harmony = int(Equipment.loadout_harmony(class_id).level)
	for id in _party:
		var m: Dictionary = _party[id]
		var node = m.get("node")
		if node is Node3D and is_instance_valid(node):
			ANGEL_AURA.set_on(node, (str(m.get("sup", "")) == "angeling" and bool(m.get("sup_a", true))) or bool(m.get("ang", false)))
			HEL_LOOK.set_on(node, bool(m.get("hw", false)))


const HEL_LOOK: = preload("res://scripts/ro/hel_wings.gd")


var own_rlv: = 0
var own_harmony: = 0
var own_looks: Array = []



static func hel_worn(cid: String) -> bool:
	var st: = Save.storage_item(str(Save.loadout(cid).get("wings", "")))
	return not st.is_empty() and GameData.ITEMS.has(str(st.get("id", ""))) and Equipment.hel_wings(st)


func tick(delta: float) -> void :
	_scale_labels(delta)
	_tick_hud()
	if _crowd != null:
		_crowd.tick(minf(delta, 0.05))
	_tick_coming()
	_tick_party(delta)
	_tick_hero_pet(delta)
	_check_dress(delta)
	_tick_angel_auras(delta)
	if world.menus.mode() != "town":
		_rest_pose()
		_update_talk_button()
		return
	var input: = MouseWalk.screen_to_world(Input.get_vector("move_left", "move_right", "move_up", "move_down"))

	if _crowd != null and _crowd.typing():
		input = Vector2.ZERO
	if input != Vector2.ZERO:
		world.mouse_walk.cancel()
		_going_to = -1
	else:
		input = world.mouse_walk.input_vector(hero.position)
	var move: = Vector3(input.x, 0, input.y)
	if move.length_squared() > 0.0001:
		var p: = world.map.slide(hero.position, move * GameData.TOWN_WALK_SPEED * _speed * delta)
		if _flat(p, _at(_cell("center"))) <= _radius():
			hero.position = Vector3(p.x, world.map.height_at(p), p.z)
		hero.face(move)
		sitting = false
		hero.speed_scale = maxf(1.0, _speed / WALK_ANIM_AT)
		hero.play(RoVisual.PC_WALK)
	else:
		_rest_pose()
	if _cart != null:
		_cart.follow(hero, hero.base_action == RoVisual.PC_WALK, world.map)
	world.mouse_walk.update_markers()
	_check_npcs()
	_update_talk_button()
	_check_portal()
	_update_emotes(delta)
	_tick_valkyrie(delta)





const NEAR_RANGE: = TALK_RANGE * 1.6

var _near: = -1
var _talk_button: Button

func _check_npcs() -> void :
	_near = -1
	var best_d: = NEAR_RANGE
	for i in _npcs.size():
		var n: Dictionary = _npcs[i]
		var node: RoVisual = n.node
		if not node.visible:
			continue
		var d: = _flat(hero.position, node.position)
		if _going_to == i and d <= TALK_RANGE:
			_going_to = -1
			world.mouse_walk.reset()
			_talk(n)
			return
		if d < best_d:
			best_d = d
			_near = i



func talk_nearest() -> void :
	if _near < 0 or _near >= _npcs.size():
		_check_npcs()
	if _near < 0:
		return
	_going_to = -1
	world.mouse_walk.reset()
	_talk(_npcs[_near])



func npc_head(i: int) -> Vector2:
	var node: RoVisual = _npcs[i].node
	var cam: Camera3D = world.camera
	return cam.unproject_position(node.position + RoVisual.world_lift() + cam.global_basis.y * (node.height() + 0.1))


func _build_talk_button() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_talk_button = UiKit.button("", true)
	_talk_button.focus_mode = Control.FOCUS_NONE
	_talk_button.custom_minimum_size = Vector2(0, 30)
	_talk_button.add_theme_font_size_override("font_size", 13)
	_talk_button.visible = false
	_talk_button.pressed.connect(talk_nearest)
	layer.add_child(_talk_button)


func _update_talk_button() -> void :
	if _talk_button == null:
		return
	var show: = _near >= 0 and world.menus.mode() == "town" and not world.camera.is_position_behind(_npcs[_near].node.position)
	_talk_button.visible = show
	if not show:
		return
	var key: = ""
	if not Input.get_connected_joypads().is_empty():
		key = "A  ·  "
	elif not DisplayServer.is_touchscreen_available():
		key = "E  ·  "
	_talk_button.text = key + (tr("Leer") if _npcs[_near].def.has("poster_of") else tr("Hablar"))
	_talk_button.size = _talk_button.get_combined_minimum_size()
	var head: = npc_head(_near)
	_talk_button.position = (head - Vector2(_talk_button.size.x * 0.5, _talk_button.size.y + 6.0)).floor()




const FADE_NEAR: = 1.6
const FADE_ALPHA: = 0.35

func _fade_in_front(v: RoVisual) -> void :
	var cam: Camera3D = world.camera
	var a: = 1.0
	var mine: = cam.global_position.distance_to(v.position)
	for n in _npcs:
		var node: RoVisual = n.node
		if node.visible and _flat(v.position, node.position) < FADE_NEAR\
		and mine < cam.global_position.distance_to(node.position):
			a = FADE_ALPHA
			break
	if is_equal_approx(v.tint.a, a):
		return
	v.tint = Color(v.tint, a)
	v.sprite.modulate = v.tint
	v.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD if a >= 1.0 else SpriteBase3D.ALPHA_CUT_DISABLED


func _check_portal() -> void :
	var d: = _flat(hero.position, _portal_pos)
	if d > PORTAL_RANGE * 2.0:
		_left_portal = true
	elif d <= PORTAL_RANGE and _left_portal:
		_left_portal = false
		world.mouse_walk.reset()
		world.play_sound("portal", 0.0, 0.0)
		world.menus.show_server_select(class_id)



func _talk(n: Dictionary) -> void :
	var node: RoVisual = n.node
	node.face(hero.position - node.position)
	hero.face(node.position - hero.position)
	hero.play(RoVisual.PC_IDLE)
	world.menus.ui_click()
	if n.def.has("poster_of"):
		world.menus.show_missing_poster(str(n.def.poster_of))
		return
	match str(n.def.id):
		"kafra":
			world.menus.show_kafra_talk()
		"sage":
			world.menus.show_sage()
		"pacts":
			world.menus.show_pacts(class_id)
		"chef":
			world.menus.show_chef()
		"refiner":
			world.menus.show_nakurusa()
		"gacha":
			world.menus.show_gacha()
		"socket":
			world.menus.show_abstract()
		"star_smith":
			world.menus.show_altair_talk()
		"party":
			world.menus.show_coop()
		"tower":
			world.menus.show_tower()
		"teleport":
			world.menus.show_teleporter(class_id)
		"rebirth":

			world.menus.show_valkyrie_talk()




func npc_at(pos: Vector2) -> int:
	var best: = -1
	var best_d: = CLICK_PX * maxf(1.0, get_viewport().get_visible_rect().size.y / 720.0)
	for i in _npcs.size():
		var node: RoVisual = _npcs[i].node
		if not node.visible or world.camera.is_position_behind(node.position):
			continue
		var at: = world.camera.unproject_position(node.position + RoVisual.world_lift() + Vector3(0, 1.0, 0))
		var d: = at.distance_to(pos)
		if d < best_d:
			best_d = d
			best = i
	return best



func party_at(pos: Vector2) -> int:
	var best: = 0
	var best_d: = CLICK_PX * maxf(1.0, get_viewport().get_visible_rect().size.y / 720.0)
	for id in _party:
		var node: Node3D = _party[id].node
		if not is_instance_valid(node) or world.camera.is_position_behind(node.position):
			continue
		var d: = world.camera.unproject_position(node.position + RoVisual.world_lift() + Vector3(0, 1.0, 0)).distance_to(pos)
		if d < best_d:
			best_d = d
			best = int(id)
	return best




func _unhandled_input(event: InputEvent) -> void :
	if world.menus.mode() != "town":
		return

	if event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_RIGHT or (event.button_index == MOUSE_BUTTON_LEFT and MouseWalk.touch()
				and event.position.distance_to(world.mouse_walk.stick_center()) > MouseWalk.stick_grab())):
		var who: = party_at(event.position)
		if who != 0:
			world.menus.show_trade_menu(who, event.position)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var best: = npc_at(event.position)
		if best >= 0:
			var node: RoVisual = _npcs[best].node
			_going_to = best
			if _flat(hero.position, node.position) <= TALK_RANGE:
				_check_npcs()
			else:
				world.mouse_walk.walk_to(node.position)
			get_viewport().set_input_as_handled()
			return
		if world.mouse_walk.handle_input(event):
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		if world.mouse_walk.handle_input(event):
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		world.menus.ui_click()
		world.menus.show_town_menu()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_X:
		toggle_sit()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E and _near >= 0:
		talk_nearest()
		get_viewport().set_input_as_handled()





func _update_emotes(delta: float) -> void :
	_emote_clock += delta
	if _emote_clock < EMOTE_EVERY:
		return
	_emote_clock = 0.0
	var shown: Array[int] = []
	for i in _npcs.size():

		if (_npcs[i].node as RoVisual).visible and not _npcs[i].def.has("poster_of")\
		and not (str(_npcs[i].def.id) == "rebirth" and _valkyrie_calling()):
			shown.append(i)
	if shown.is_empty():
		return
	var i: int = shown[_emote_turn % shown.size()]
	_emote_turn += 1
	world.emote(_npcs[i].node, _emote_for(i), 1.8)


func _emote_for(i: int) -> String:
	match str(_npcs[i].def.id):
		"kafra":
			for id in GameData.UPGRADES:
				var lv: = Save.upgrade_level(id)
				if lv < int(GameData.UPGRADES[id].max) and GameData.upgrade_cost(id, lv) <= Save.zeny():
					return "money"
			return ["heh", "love", "ok"].pick_random()
		"sage":
			for id in GameData.SAGE_UPGRADES:
				var lv: = Save.upgrade_level(id)
				if lv < int(GameData.SAGE_UPGRADES[id].max) and GameData.sage_cost(id, lv) <= Save.zeny():
					return "idea"
			return ["question", "hmm"].pick_random()
		"pacts":
			return ["go", "ok"].pick_random()
		"chef":
			return ["heh", "love", "music"].pick_random()
		"gacha":
			return "money" if Save.coins() >= int(GameData.GACHA.coins) else ["heh", "music"].pick_random()
		"refiner":
			return "idea" if not Save.storage().is_empty() else ["hmm", "go"].pick_random()
		"socket":
			for it in Save.storage():
				if Equipment.socket_room(it) > 0:
					return "idea"
			return ["hmm", "heh"].pick_random()
		"star_smith":
			return "idea" if Save.material("star_crumb") > 0 and not Save.storage().is_empty() else ["music", "hmm"].pick_random()
		"rebirth":
			return "surprise" if Save.can_rebirth(class_id) or Save.rebirth_lv_ready(class_id) else ["love", "music"].pick_random()
		"party":
			return "ok" if world.net.mode != "" else ["go", "heh", "music"].pick_random()
		"teleport":
			return ["go", "heh", "idea"].pick_random()
	return "heh"








const VALK_CALL_EVERY: = 1.6
var _valk_call_t: = 0.0
var _valk_call_n: = 0
var _valk_beam: Node3D


func _valkyrie_calling() -> bool:
	return Save.rebirth_lv_ready(class_id) and not Save.rebirth_lv_called(class_id)


func _valkyrie_call() -> void :
	var v: = npc_node("rebirth")
	if not is_inside_tree() or v == null or not v.visible or not Save.rebirth_lv_ready(class_id):
		return
	if _valk_beam == null:
		_valk_beam = Vfx.beam(v, Vector3.ZERO, GameData.REBIRTH_LV_GOLD, 5.0)
	if not _valkyrie_calling():
		return
	v.face(hero.position - v.position)

	world.emote(v, "surprise" if _valk_call_n % 3 == 0 else "go", VALK_CALL_EVERY - 0.1)
	_valk_call_n += 1


func _tick_valkyrie(delta: float) -> void :
	if not _valkyrie_calling():
		return
	_valk_call_t += delta
	if _valk_call_t >= VALK_CALL_EVERY:
		_valk_call_t = 0.0
		_valkyrie_call()



func refresh_rebirth_looks() -> void :
	for c in hero.get_children():
		if c is RebirthAura or c is RebirthFlair:
			c.queue_free()
	RebirthAura.attach(hero, Save.rebirth_looks(class_id), RebirthAura.earned(class_id))




func rebirth_lv_ceremony() -> void :
	var rlv: = Save.rebirth_lv(class_id)
	var v: = npc_node("rebirth")
	if v != null:
		v.face(hero.position - v.position)
		world.emote(v, "love", 2.4)
	if _valk_beam != null and is_instance_valid(_valk_beam):
		_valk_beam.queue_free()
	_valk_beam = null
	hero.face(Vector3(0, 0, 1))
	world.play_sound("blessing", 0.0, -2.0)
	world.sprite_fx("fx_blessing", hero.position, 0, 1.2, hero)
	var beam: = Vfx.beam(world.fx_root, hero.position, GameData.REBIRTH_LV_GOLD, 12.0)
	beam.scale = Vector3(0.2, 1.0, 0.2)
	var tw: = create_tween()
	tw.tween_property(beam, "scale", Vector3(1.5, 1.0, 1.5), 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_callback( func():
		world.play_sound("angelus", 0.0, -2.0)
		hero.play(RoVisual.PC_CAST))
	tw.tween_interval(1.0)
	tw.tween_callback( func():
		world.play_sound("job_levelup", 0.0, 0.0)
		world.shake(0.15)
		RoEffect.spawn(world.fx_root, "h_levelup", hero.position, 1.0, hero)
		refresh_rebirth_looks()
		hero.play(RoVisual.PC_IDLE)
		var look: Dictionary = GameData.REBIRTH_LV_LOOKS[clampi(rlv - 1, 0, GameData.REBIRTH_LV_LOOKS.size() - 1)]
		world.hud.announce(GameData.rebirth_name(rlv), GameData.REBIRTH_LV_GOLD, tr("Nuevo: %s") % tr(str(look.name))))
	tw.tween_property(beam, "scale", Vector3(0.05, 1.0, 0.05), 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(beam.queue_free)
	tw.tween_interval(0.4)
	tw.tween_callback( func():
		if v != null and is_instance_valid(v):
			_crowd.chat(v, tr("Vuelve a empezar, %s. Valhalla no olvida.") % Save.char_name(class_id)))






func wings_ceremony(r: int) -> void :
	var v: = npc_node("rebirth")
	if v != null:
		v.face(hero.position - v.position)
		world.emote(v, "love", 2.0)
	hero.face(Vector3(0, 0, 1))
	hero.play(RoVisual.PC_CAST)
	var at: = hero.position
	var gold: = GameData.REBIRTH_LV_GOLD
	world.play_sound("angelus", 0.0, -2.0)
	var dark: = _spotlight()
	Vfx.magic_circle(world.fx_root, at + Vector3(0, 0.05, 0), 2.6, Color(1.0, 0.85, 0.4, 0.9), 2.6)
	world.sprite_fx("fx_blessing", at, 0, 1.2, hero)

	var beams: Array = []
	for c in [Color(1.0, 0.78, 0.3), Color(1.0, 1.0, 0.9)]:
		var beam: = Vfx.beam(world.fx_root, at, c, 16.0)
		beam.scale = Vector3(1.6 if beams.is_empty() else 0.8, 0.02, 1.0)
		beams.append(beam)
	var tw: = create_tween()
	tw.tween_property(dark, "modulate:a", 1.0, 0.35)
	for i in beams.size():
		tw.parallel().tween_property(beams[i], "scale:y", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	for k in 5:
		tw.parallel().tween_callback( func():
			Vfx.volley_up(world.fx_root, at + Vector3(0, 0.3, 0), Color(1.0, 0.92, 0.6), 7)
			Vfx.heal_light(world.fx_root, at, Color(1.0, 0.88, 0.5))).set_delay(0.2 * k)
	tw.tween_interval(0.25)
	tw.tween_callback( func():
		world.play_sound("refine_ok", 0.0, 0.0)
		world.play_sound("job_levelup", 0.0, -3.0)
		world.shake(0.2)
		Vfx.ray_flash(world.fx_root, at + Vector3(0, 1.4, 0), world.camera.global_basis, gold, 2.6)
		Vfx.burst(world.fx_root, at + Vector3(0, 1.0, 0), 2.6, gold)
		Vfx.ring(world.fx_root, at + Vector3(0, 0.06, 0), 3.6, Color(1.0, 0.95, 0.7), 0.6)
		RoEffect.spawn(world.fx_root, "bs_refinesuccess", at, 1.2, hero)
		RoEffect.spawn(world.fx_root, "h_levelup", at, 1.0, hero)
		hero.play(RoVisual.PC_IDLE)
		world.number(at + Vector3(0, 2.6, 0), "+%d %s" % [r, tr(str(GameData.ITEMS[GameData.TOWER_WINGS].name))], 
			GameData.WINGS_COLOR.lightened(0.45), true, false, false, 1.0, false, true, false, "", 1.6)
		if v != null and is_instance_valid(v):
			_crowd.chat(v, tr(GameData.WING_LEVELS[clampi(r - 1, 0, GameData.WING_LEVELS.size() - 1)])))
	tw.tween_interval(0.8)

	tw.tween_property(dark, "modulate:a", 0.0, 0.8)
	for i in beams.size():
		tw.parallel().tween_property(beams[i], "scale:x", 0.02, 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_callback( func():
		for bm in beams:
			if is_instance_valid(bm):
				bm.queue_free()
		if is_instance_valid(dark):
			dark.get_parent().queue_free())
	tw.tween_interval(0.5)
	tw.tween_callback( func():
		if world.menus._mode == "town":
			world.menus.show_valkyrie_wings())







func hel_wings_ceremony() -> void :
	var v: = npc_node("rebirth")
	if v != null:
		v.face(hero.position - v.position)
		world.emote(v, "love", 3.0)
	hero.face(Vector3(0, 0, 1))
	hero.play(RoVisual.PC_CAST)
	var at: = hero.position
	var gold: = GameData.HEL_WINGS_COLOR
	var night: = Color(0.55, 0.28, 0.95)
	var dark: = _spotlight()

	var veil_layer: = CanvasLayer.new()
	veil_layer.layer = 3
	add_child(veil_layer)
	var veil: = ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.color = Color(0.22, 0.06, 0.36, 0.0)
	veil_layer.add_child(veil)
	world.play_sound("earth_quake", 0.0, -5.0)
	world.shake(0.3)
	Vfx.magic_circle(world.fx_root, at + Vector3(0, 0.05, 0), 3.6, Color(night, 0.9), 4.6)
	world.spawn_fx("hell_in", at, 1.4, 0.9)

	var shade: = Vfx.beam(world.fx_root, at, night, 18.0)
	shade.scale = Vector3(1.9, 0.02, 1.0)
	var tw: = create_tween()
	tw.tween_property(dark, "modulate:a", 1.0, 0.6)
	tw.parallel().tween_property(veil, "color:a", 0.32, 0.6)
	tw.parallel().tween_property(shade, "scale:y", 1.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	for k in 9:
		tw.parallel().tween_callback( func():
			var a: = randf() * TAU
			var from: = at + Vector3(cos(a), 0, sin(a)) * 2.8
			Vfx.volley_up(world.fx_root, from + Vector3(0, 0.2, 0), Color(0.7, 0.5, 1.0), 5)
			Vfx.heal_light(world.fx_root, from, Color(0.62, 0.42, 1.0))).set_delay(0.22 * k)
	tw.parallel().tween_callback( func():
		world.play_sound("angelus", 0.0, -2.0)
		world.sprite_fx("fx_blessing", at, 0, 1.4, hero)
		Vfx.magic_circle(world.fx_root, at + Vector3(0, 0.07, 0), 2.6, Color(gold, 0.95), 2.6)).set_delay(1.5)
	tw.tween_interval(0.4)

	var beams: Array = []
	tw.tween_callback( func():
		world.play_sound("excaliblast", 0.0, -1.0)
		world.play_sound("job_levelup", 0.0, -3.0)
		world.shake(0.9)
		_white_flash(gold.lightened(0.5))
		if is_instance_valid(shade):
			shade.queue_free()
		for c in [gold, Color(1.0, 1.0, 0.92)]:
			var bm: = Vfx.beam(world.fx_root, at, c, 26.0)
			bm.scale = Vector3(2.4 if beams.is_empty() else 1.1, 1.0, 1.0)
			beams.append(bm)
		Vfx.ray_flash(world.fx_root, at + Vector3(0, 1.4, 0), world.camera.global_basis, gold, 4.2)
		Vfx.column(world.fx_root, at, gold)
		for i in 3:
			Vfx.ring(world.fx_root, at + Vector3(0, 0.06, 0), 3.0 + 2.5 * i, Color(1.0, 0.9, 0.6), 0.5 + 0.25 * i)
		Vfx.burst(world.fx_root, at + Vector3(0, 1.0, 0), 3.4, gold)
		for i in 3:
			Vfx.volley_up(world.fx_root, at + Vector3(0, 0.3, 0), Color(1.0, 0.92, 0.6), 10)
		RoEffect.spawn(world.fx_root, "bs_refinesuccess", at, 1.4, hero)
		RoEffect.spawn(world.fx_root, "h_levelup", at, 1.2, hero)
		HEL_LOOK.set_on(hero, true)
		hero.play(RoVisual.PC_IDLE)
		world.number(at + Vector3(0, 2.8, 0), tr(GameData.HEL_WINGS_NAME), 
			gold.lightened(0.25), true, false, false, 1.0, false, true, false, "", 2.0)
		if v != null and is_instance_valid(v):
			_crowd.chat(v, tr("«Hel guarda lo que cae. Hoy te devuelve tus alas.»")))
	tw.tween_property(veil, "color", Color(0.4, 0.3, 0.1, 0.18), 0.4)
	tw.tween_interval(1.4)
	tw.tween_property(dark, "modulate:a", 0.0, 1.0)
	tw.parallel().tween_property(veil, "color:a", 0.0, 1.0)
	tw.parallel().tween_callback( func():
		for bm in beams:
			if is_instance_valid(bm):
				bm.create_tween().tween_property(bm, "scale:x", 0.02, 0.9).set_trans(Tween.TRANS_SINE))
	tw.tween_callback( func():
		for bm in beams:
			if is_instance_valid(bm):
				bm.queue_free()
		if is_instance_valid(dark):
			dark.get_parent().queue_free()
		veil_layer.queue_free())
	tw.tween_interval(0.4)
	tw.tween_callback( func():
		if world.menus._mode == "town":
			world.menus.show_valkyrie_wings())



func _white_flash(c: Color) -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 4
	add_child(layer)
	var r: = ColorRect.new()
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.color = Color(c, 0.75)
	layer.add_child(r)
	var tw: = r.create_tween()
	tw.tween_property(r, "color:a", 0.0, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(layer.queue_free)






const SPOT_SHADER: = "\nshader_type canvas_item;\nuniform vec2 center = vec2(0.5);\nuniform float aspect = 1.7;\nvoid fragment() {\n\tvec2 d = (UV - center) * vec2(aspect, 1.0);\n\td.y *= d.y < 0.0 ? 0.55 : 1.1;\n\tfloat a = smoothstep(0.16, 0.62, length(d));\n\tCOLOR = vec4(0.02, 0.01, 0.06, 0.66 * a * COLOR.a);\n}\n"










func _spotlight() -> ColorRect:

	var layer: = CanvasLayer.new()
	layer.layer = 3
	add_child(layer)
	var rect: = ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh: = Shader.new()
	sh.code = SPOT_SHADER
	var mat: = ShaderMaterial.new()
	mat.shader = sh
	rect.material = mat
	rect.modulate.a = 0.0
	layer.add_child(rect)
	var follow: = func():
		if not is_instance_valid(rect) or world.camera == null:
			return
		var view: = get_viewport().get_visible_rect().size
		var c: = world.camera.unproject_position(hero.position + Vector3(0, 1.0, 0))
		mat.set_shader_parameter("center", c / view)
		mat.set_shader_parameter("aspect", view.x / maxf(1.0, view.y))
	follow.call()
	get_tree().process_frame.connect(follow)
	rect.tree_exiting.connect( func():
		if get_tree().process_frame.is_connected(follow):
			get_tree().process_frame.disconnect(follow))
	return rect









func change_hero(new_class: String) -> void :
	if new_class == class_id or not GameData.CLASSES.has(new_class) or not Save.class_unlocked(new_class):
		return
	class_id = new_class
	RoCharSelect.last_id = new_class
	world.mouse_walk.reset()
	_going_to = -1
	sitting = false
	Vfx.column(world.fx_root, hero.position, GameData.REBIRTH_LV_GOLD)
	world.play_sound("teleport", 0.0, -4.0)
	var v: = npc_node("rebirth")
	if v != null:
		v.face(hero.position - v.position)
		world.emote(v, "love", 2.0)
	_dress_hero()
	if _cart != null and is_instance_valid(_cart):
		_cart.queue_free()
	_cart = Pushcart.make(hero) if GameData.CLASSES[class_id].get("cart", false) else null
	refresh_rebirth_looks()
	if is_dev_hero():
		_dev_aura(hero)
	_hero_label()
	hero.face(Vector3(0, 0, 1))
	hero.speed_scale = 1.0
	hero.play(RoVisual.PC_IDLE)
	world.sprite_fx("fx_blessing", hero.position, 0, 1.0, hero)

	if _valk_beam != null and is_instance_valid(_valk_beam):
		_valk_beam.queue_free()
	_valk_beam = null
	_valk_call_n = 0
	if Save.rebirth_lv_ready(class_id):
		get_tree().create_timer(1.2).timeout.connect(_valkyrie_call)
	if world.net.mode != "":
		world.net.update_class(class_id)
	_hud_key = ""



func refresh_hero() -> void :
	_dress_hero()
	_hero_label()
	_hud_key = ""




func _hero_label() -> void :
	var l: Variant = hero.get_meta("name_label") if hero.has_meta("name_label") else null
	if not (l is Label3D and is_instance_valid(l)):
		return
	var dev: = is_dev_hero()
	(l as Label3D).text = Save.char_name(class_id) + (" · Dev" if dev else "")
	(l as Label3D).modulate = NameFilter.DEV_COLOR if dev else\
	(GameData.REBIRTH_LV_GOLD if Save.rebirth_looks(class_id).has("valhalla") else Color(1.0, 0.95, 0.7))







var _hud: HBoxContainer
var _hud_menu: Button
var _hud_hero: Button
var _hud_chan: Button
var _hud_cos: Button
var _hud_key: = ""


func _build_hud() -> void :


	get_tree().create_timer(2.0).timeout.connect( func():
		if is_instance_valid(self) and world.town == self:
			world.menus.warm_closet(class_id))
	var layer: = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_hud = HBoxContainer.new()
	_hud.add_theme_constant_override("separation", 6)
	_hud.position = Vector2(10, 8)
	_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_hud)
	_hud_menu = _hud_pill( func(): world.menus.show_town_menu())
	_hud_menu.tooltip_text = tr("Guía, personaje, canales, amigos, opciones y salir")
	_hud.add_child(_hud_menu)
	_hud_hero = _hud_pill( func(): world.menus.show_hero_sheet())
	_hud_hero.tooltip_text = tr("Tu héroe: atributos, equipo inicial, pactos y platos")
	_hud.add_child(_hud_hero)
	_hud_chan = _hud_pill( func(): world.menus.show_channel_list())
	_hud_chan.tooltip_text = tr("Prontera online: cambiar de canal")
	_hud.add_child(_hud_chan)

	_hud_cos = _hud_pill( func():
		world.menus.ui_click()
		world.menus.show_closet(class_id))
	_hud_cos.tooltip_text = tr("Tu aspecto: cosméticos, auras, nombre y títulos")
	_hud.add_child(_hud_cos)
	_fill_pill(_hud_cos, UiKit.icon_rect(world.menus._item_icon("wardrobe"), 20), tr("Armario"), "", "")
	_hud_key = ""
	_tick_hud()




func _hud_pill(cb: Callable) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	for st in ["normal", "hover", "pressed"]:
		var bg: = Color(0.97, 0.98, 1.0, 0.92)
		if st == "hover":
			bg = Color(1.0, 1.0, 1.0, 0.98)
		elif st == "pressed":
			bg = Color(0.88, 0.92, 1.0, 0.98)
		var box: = UiKit.panel_box(bg, UiKit.GOLD_DIM if st == "normal" else UiKit.GOLD, 12)
		box.content_margin_left = 0
		box.content_margin_right = 0
		box.content_margin_top = 0
		box.content_margin_bottom = 0
		box.shadow_size = 0
		b.add_theme_stylebox_override(st, box)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	b.pressed.connect( func():
		if world.menus.mode() != "town":
			return
		world.menus.ui_click()
		cb.call())
	return b


func _fill_pill(b: Button, icon: Control, main: String, sub: String, key: String) -> void :
	var row: HBoxContainer = b.get_child(0)
	for c in row.get_children():
		row.remove_child(c)
		c.queue_free()
	if icon != null:
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
	var m: = UiKit.label(main, 13, UiKit.TEXT, true)
	m.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(m)
	if sub != "":
		var s: = UiKit.label(sub, 12, UiKit.MUTED)
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(s)
	if key != "":
		var cap: = PanelContainer.new()
		var cb: = UiKit.panel_box(UiKit.PANEL_SOFT, UiKit.GOLD_DIM, 4)
		cb.border_width_bottom = 2
		cb.shadow_size = 0
		cb.content_margin_left = 5
		cb.content_margin_right = 5
		cb.content_margin_top = 0
		cb.content_margin_bottom = 1
		cap.add_theme_stylebox_override("panel", cb)
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		cap.add_child(UiKit.label(key, 10, UiKit.TEXT, true))
		row.add_child(cap)
	var need: = row.get_combined_minimum_size()
	b.custom_minimum_size = Vector2(need.x + 7.0 + (8.0 if key != "" else 11.0), maxf(28.0, need.y + 6.0))
	b.size = b.custom_minimum_size
	row.size = need
	row.position = Vector2(7.0, roundf((b.custom_minimum_size.y - need.y) * 0.5))




func _tick_hud() -> void :
	if _hud == null:
		return
	var on: bool = world.menus.mode() == "town" and not world.running
	_hud.visible = on
	if not on:
		return
	var ch = world.channel
	var state: String = str(ch.state) if ch != null else ""
	var inside: bool = ch != null and ch.is_in()
	var pad: = not Input.get_connected_joypads().is_empty()
	var keys: = not pad and not world.menus.touch_ui()
	var key: = var_to_str([class_id, state, ch.number if inside else 0, ch.members.size() if inside else 0, keys])
	if key == _hud_key:
		return
	_hud_key = key
	var job: Texture2D = world.menus._friend_job_icon(class_id, "")
	_fill_pill(_hud_menu, null, "☰  " + tr("Menú"), "", "Esc" if keys else "")
	_fill_pill(_hud_hero, UiKit.icon_rect(job, 20) if job != null else null, tr("Personaje"), "", "C" if keys else "")
	var dot: = HudDot.new()
	dot.color = Color(0.3, 0.78, 0.4) if inside else (Color(0.95, 0.7, 0.2) if state == "joining" else Color(0.62, 0.65, 0.74))
	dot.pulse = inside
	if inside:
		_fill_pill(_hud_chan, dot, tr("Canal %d") % ch.number, "%d/%d" % [ch.members.size(), TownCrowd.TownChannel.MAX_PLAYERS], "")
	elif state == "joining":
		_fill_pill(_hud_chan, dot, tr("Entrando al canal..."), "", "")
	else:
		_fill_pill(_hud_chan, dot, tr("Sin canal"), tr("Ver canales"), "")



class HudDot extends Control:
	var color: = Color.WHITE
	var pulse: = false

	func _init() -> void :
		custom_minimum_size = Vector2(12, 12)

	func _process(_delta: float) -> void :
		if pulse:
			queue_redraw()

	func _draw() -> void :
		var c: = size * 0.5
		if pulse:
			var t: = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 2.6)
			draw_circle(c, 4.5 + 2.0 * t, Color(color, 0.25 * (1.0 - t) + 0.08))
		draw_circle(c, 4.0, color.darkened(0.25))
		draw_circle(c, 3.0, color)
		draw_circle(c + Vector2(-1, -1), 1.0, Color(1, 1, 1, 0.7))


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
