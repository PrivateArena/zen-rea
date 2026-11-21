class_name QuestRun
extends Node











const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")

const REARM_RANGE: = 4.0

const CALL_EVERY: = 4.0

const LEAVE_AFTER: = 2.6


const FOLLOW_GAP: = 1.8
const CATCH_UP: = 14.0
const EXIT_RANGE: = 2.4

var world: World

var state: = "off"
var stage_id: = ""

var net_mark: = Vector3.INF
var net_label: = ""
var net_head: = Vector3.INF

var net_window: = {}
var data: = {}
var npc: RoVisual
var prop: RoVisual

var pos: = Vector3.INF
var hp: = 0
var max_hp: = 0
var t: = 0.0
var total: = 0.0

var result: = ""
var _wave: = 0.0
var _call: = 0.0
var _armed: = true
var _adds: Array[Enemy] = []

var exit_pos: = Vector3.INF
var _walk_t: = 0.0
var _exit: Node3D


var _guardian: Enemy
var _cage: Node3D
var _seals: Array[Vector3] = []
var _seal_nodes: Array[Node3D] = []
var _seal_i: = 0
var _hold: = 0.0
var _seal_label: Label3D
var _seal_beam: MeshInstance3D
var _boss: Enemy

var _bar: Node3D
var _bar_fill: MeshInstance3D




func reset() -> void :
	_clear()
	stage_id = world.stage_id
	data = GameData.QUESTS.get(stage_id, {})
	state = "wait" if not data.is_empty() and not Save.quest_done(stage_id) else "off"
	result = ""




func skip() -> void :
	_clear()
	state = "off"


func shows() -> bool:
	return state in ["offer", "active"]



func pointer() -> Vector3:
	if world.net.is_client():
		return net_mark
	return marker() if shows() else Vector3.INF


func pointer_label() -> String:
	return net_label if world.net.is_client() else marker_label()


func pointer_head() -> Vector3:
	return net_head if world.net.is_client() else marker_head()


func tick(delta: float) -> void :
	match state:
		"wait":
			if world.endless:
				state = "off"
			elif world.time >= float(GameData.get_meta("quest_at", GameData.QUEST_AT)) and not world.raid.active():
				_appear()
		"offer", "active":
			if world.raid.in_arena() or world.endless:
				_fail()
				return
			if not is_instance_valid(npc):
				state = "off"
				return
			if state == "offer":
				_offer_tick(delta)
			else:
				_active_tick(delta)



func end_run() -> void :
	if shows() or state == "wait":
		if shows():
			result = "failed"
		state = "off"



func npc_hit(node: Node3D) -> void :
	if state != "active" or node != _defended():
		return
	hp -= 1
	(node as RoVisual).flash()
	world.play_sound("hit", 0.15, -10.0)
	world.spawn_fx("hit", node.global_position + Vector3(randf_range(-0.4, 0.4), 0.7, randf_range(-0.3, 0.3)), 0.6, 0.8)
	_update_bar()
	if hp <= 0:
		_fail()


func objective() -> String:
	return tr(str(data.get("objective", "")))







func window() -> Dictionary:
	if world.net.is_client():
		return net_window
	var w: = {"boss": false, "count": [], "bar": [], "time": -1, "left": -1}
	if state != "active":
		return w
	match str(data.type):
		"defend", "escort":
			w.bar = ["blue", hp, max_hp, true, false]
		"hunt":
			w.bar = _foe_bar(_guardian)
		"ritual":
			var n: = int(data.circles)
			if _seal_i >= n and _boss != null:
				w.boss = true
				w.bar = _foe_bar(_boss)
			else:
				w.count = [mini(_seal_i, n), n]
				w.bar = ["blue", roundi(100.0 * _hold / maxf(0.01, _scaled("hold"))), 100, false, true]
	if str(data.type) == "escort":
		w.left = roundi(_flat(npc.global_position, exit_pos)) if is_instance_valid(npc) and exit_pos != Vector3.INF else 0
	else:
		w.time = ceili(maxf(0.0, t))
	return w



func _foe_bar(foe: Enemy) -> Array:
	if foe == null or not is_instance_valid(foe) or foe.dead:
		return []
	return ["red", ceili(100.0 * foe.hp / maxf(1.0, foe.max_hp)), 100, false, false]



func marker() -> Vector3:
	if state == "active" and exit_pos != Vector3.INF:
		return exit_pos
	if state == "active" and _guardian != null and is_instance_valid(_guardian) and not _guardian.dead:
		return _guardian.position
	if state == "active" and _boss != null and is_instance_valid(_boss) and not _boss.dead:
		return _boss.position
	if state == "active" and _seal_i < _seals.size():
		return _seals[_seal_i]
	return pos




func marker_head() -> Vector3:
	var top: = 1.0
	var foe: Enemy = null
	if state == "active" and exit_pos == Vector3.INF:
		if _guardian != null and is_instance_valid(_guardian) and not _guardian.dead:
			foe = _guardian
		elif _boss != null and is_instance_valid(_boss) and not _boss.dead:
			foe = _boss
	if foe != null:
		top = float(foe.visual.height()) if foe.visual != null and foe.visual.has_method("height") else 2.4
	elif state != "active" and npc != null and is_instance_valid(npc):
		top = world._sprite_height(npc)
	return marker() + World.view_up() * top



func marker_label() -> String:
	if state == "active":
		if exit_pos != Vector3.INF:
			return tr("Salida")
		if _guardian != null and is_instance_valid(_guardian) and not _guardian.dead:
			return tr(str(data.get("guardian_name", "")))
		if _boss != null and is_instance_valid(_boss) and not _boss.dead:
			return tr(str(data.get("boss_name", "")))
		if _seal_i < _seals.size():
			return tr("Brasero") if data.get("braziers", false) else tr("Sello")
	return tr("Quest")



func _defended() -> Node3D:
	return prop if prop != null else npc




func _appear() -> void :
	var p: = world.player
	var at: = Vector3.INF
	if data.has("spot"):

		var cell: Vector2i = data.spot
		at = world.map.cell_center(cell.x, cell.y)
		if not world.map.is_walkable(at):
			at = world.map.find_point_around(at, 0.0, 4.0)
	if at == Vector3.INF:
		at = world.map.find_point_around(p.position, float(GameData.QUEST_SPAWN_DIST[0]), float(GameData.QUEST_SPAWN_DIST[1]))
	if at == Vector3.INF:
		at = world.map.find_point_around(p.position, 6.0, 20.0)
	if at == Vector3.INF:
		state = "off"
		return
	pos = Vector3(at.x, world.map.height_at(at), at.z)
	npc = RoVisual.new()
	world.run_root.add_child(npc)
	npc.setup(_npc_sprite(), Color(1, 0.9, 0.7), 48, 1.0)
	if data.has("npc_look"):
		npc.hold_idle = true
	npc.play(RoVisual.MOB_IDLE)

	npc.show_through(0.6)
	npc.global_position = pos
	npc.face(p.position - pos)
	_label(npc, tr(str(data.npc_name)), GameData.QUEST_COLOR, -0.25, 26, false)
	if data.has("npc_title"):


		var t: = _label(npc, tr(str(data.npc_title)), Color(0.85, 0.88, 0.95), -0.25, 22, false)
		t.position += Vector3(0, - cos(World.CAMERA_PITCH), sin(World.CAMERA_PITCH)) * 0.42
	var glow: = Vfx.ground_glow(npc, Vector3(0, 0.03, 0), 1.4, Color(GameData.QUEST_COLOR, 0.6))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.3, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.8, 0.7).set_trans(Tween.TRANS_SINE)
	if data.has("prop"):
		prop = RoVisual.new()
		world.run_root.add_child(prop)
		prop.setup(RoAssets.sprite([str(data.prop)]), Color(0.6, 0.45, 0.3), 36, 1.2)
		prop.play(0)
		prop.show_through(0.5)
		var side: = world.map.slide(pos, Vector3(1.6, 0, 0.4))
		prop.global_position = Vector3(side.x, world.map.height_at(side), side.z)
	if data.get("cage", false):
		_build_cage()

	Vfx.column(world.fx_root, pos, Color(1, 0.9, 0.6))
	Vfx.magic_circle(world.fx_root, pos + Vector3(0, 0.05, 0), 1.7, Color(GameData.QUEST_COLOR, 0.7), 1.4, "mvp_hexa", 0.9)
	Vfx.ring(world.fx_root, pos + Vector3(0, 0.05, 0), 2.4, GameData.QUEST_COLOR, 0.5)
	world.play_sound("teleport", 0.0, -6.0)
	state = "offer"
	_call = 0.0
	_armed = true
	world.party_announce(tr("¡Alguien pide ayuda!"), GameData.QUEST_COLOR, 
		tr("%s · sigue la flecha o el «!» del minimapa") % tr(str(data.npc_name)))
	world.play_sound("party_alarm", 0.0, -4.0)


func _offer_tick(delta: float) -> void :
	_call -= delta
	if _call <= 0.0:
		_call = CALL_EVERY
		world.emote(npc, "help", 2.0)
		_chat(npc, tr(str(data.call)))


	var who: = world.nearest_hero(pos)
	if who == null:
		return
	var d: = _flat(who.position, pos)
	if d > REARM_RANGE:
		_armed = true
	elif d <= GameData.QUEST_TALK_RANGE and _armed and not (who == world.player and world.busy()):
		_armed = false
		npc.face(who.position - pos)
		if who == world.player:
			world.menus.show_quest_offer(self)
		else:
			accept()
			world.label_over(who, tr("¡Quest aceptada!"), GameData.QUEST_COLOR)



func accept() -> void :
	if state != "offer":
		return
	state = "active"
	total = _scaled("duration")
	t = total
	max_hp = maxi(1, roundi(_scaled("hits")))
	hp = max_hp
	_wave = 0.5
	if prop != null:
		_build_bar()
	if str(data.type) == "escort":
		_open_exit()
	elif str(data.type) == "hunt":
		_guardian = _spawn_tough(str(data.guardian), 7.0, 10.0)
	elif str(data.type) == "ritual":
		_place_seals()
	world.emote(npc, "go", 2.0)
	world.hud.announce(tr(str(data.name)), GameData.QUEST_COLOR, objective())
	world.net.announce(tr(str(data.name)), GameData.QUEST_COLOR, objective())
	world.play_sound("ui_click", 0.0, -2.0)


func _active_tick(delta: float) -> void :
	t -= delta
	_wave -= delta
	if _wave <= 0.0:
		_wave = float(data.every)
		_spawn_wave()
	match str(data.type):
		"escort":
			_follow(delta)
			if _flat(npc.global_position, exit_pos) <= EXIT_RANGE:
				_succeed()
		"hunt":
			if _guardian == null or not is_instance_valid(_guardian) or _guardian.dead:
				_succeed()
			elif t <= 0.0:
				_fail()
		"ritual":
			_ritual_tick(delta)
		_:
			if t <= 0.0:
				_succeed()




func _ritual_tick(delta: float) -> void :
	if _seal_i < _seals.size():

		var here: = world.heroes.any( func(h): return not h.downed and _flat(h.position, _seals[_seal_i]) <= GameData.QUEST_SEAL_RADIUS)
		var need: = _scaled("hold")
		_hold = clampf(_hold + (delta if here else - delta * 0.5), 0.0, need)
		if _seal_label != null and is_instance_valid(_seal_label):
			_seal_label.text = "%d%%" % roundi(100.0 * _hold / need) if _hold > 0.0 else ""

		if _seal_beam != null and is_instance_valid(_seal_beam):
			_seal_beam.scale = Vector3(1.0, maxf(0.02, _hold / need), 1.0)
		if _hold >= need:
			_break_seal()
	elif data.has("boss"):
		if _boss == null:
			_boss = _spawn_tough(str(data.boss), 5.0, 8.0)
			world.party_announce(tr(str(data.get("boss_name", ""))), Color(1.0, 0.45, 0.4), tr("¡Lo que había bajo los sellos ha despertado!"))
			world.play_sound("party_alarm", 0.0, -4.0)
		elif not is_instance_valid(_boss) or _boss.dead:
			_succeed()
			return
	else:
		_succeed()
		return
	if t <= 0.0:
		_fail()


func _place_seals() -> void :
	_seals.clear()
	var n: = int(data.circles)
	var dist: Array = GameData.QUEST_SEAL_DIST
	var start: = randf() * TAU
	for i in n:
		var a: = start + TAU * i / n
		var want: = pos + Vector3(cos(a), 0, sin(a)) * randf_range(float(dist[0]), float(dist[1]))
		var at: = world.map.find_point_around(want, 0.0, 3.0)
		if at == Vector3.INF or not world.flow.reachable(at):
			at = world.map.find_point_around(pos, float(dist[0]) * 0.6, float(dist[1]))
		if at == Vector3.INF:
			at = pos
		at = Vector3(at.x, world.map.height_at(at), at.z)
		_seals.append(at)
		var node: = Node3D.new()
		world.run_root.add_child(node)
		node.global_position = at
		var col: Color = data.get("seal_color", GameData.QUEST_COLOR)
		if data.get("braziers", false):
			var fire: = RoVisual.new()
			node.add_child(fire)
			fire.setup(RoAssets.sprite(["ritual_bonfire"]), col, 40, 0.8)
			fire.play(0)
			fire.tint = Color(0.25, 0.25, 0.3)
			fire.sprite.modulate = fire.tint
			node.set_meta("fire", fire)
		var glow: = Vfx.ground_glow(node, Vector3(0, 0.03, 0), GameData.QUEST_SEAL_RADIUS * 1.2, Color(col, 0.55))
		node.set_meta("glow", glow)


		var rune: = Vfx.magic_circle(node, Vector3(0, 0.05, 0), GameData.QUEST_SEAL_RADIUS, Color(col, 0.35), 0.0, "mvp_rune", 0.3)
		node.set_meta("rune", rune)
		node.set_meta("tether", _tether(at, pos, col))
		_seal_nodes.append(node)
	_seal_i = 0
	_hold = 0.0
	_mark_seal()



func _mark_seal() -> void :
	if _seal_i >= _seal_nodes.size():
		return
	var node: = _seal_nodes[_seal_i]
	var col: Color = data.get("seal_color", GameData.QUEST_COLOR)


	var rune = (node.get_meta("rune") if node.has_meta("rune") else null)
	if rune != null and is_instance_valid(rune):
		((rune as MeshInstance3D).material_override as StandardMaterial3D).albedo_color = Color(col, 0.85)
	var inner: = Vfx.magic_circle(node, Vector3(0, 0.07, 0), GameData.QUEST_SEAL_RADIUS * 0.6, Color(col.lightened(0.3), 0.75), 0.0, "mvp_hexa", -0.9)
	if inner != null:
		inner.set_meta("seal_fx", true)
	var edge: = Vfx.ground_glow(node, Vector3(0, 0.04, 0), GameData.QUEST_SEAL_RADIUS * 1.35, Color(col, 0.5))
	var tw: = edge.create_tween().set_loops()
	tw.tween_property(edge, "scale", Vector3.ONE * 1.12, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(edge, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_SINE)
	_seal_beam = Vfx.beam(node, Vector3.ZERO, col, 4.5)
	_seal_beam.scale = Vector3(1.0, 0.02, 1.0)
	_seal_label = _label(node, "", col, 2.2, 30)
	Vfx.ring(world.fx_root, node.global_position + Vector3(0, 0.05, 0), GameData.QUEST_SEAL_RADIUS * 1.4, col, 0.5)


func _break_seal() -> void :
	var node: = _seal_nodes[_seal_i]
	var col: Color = data.get("seal_color", GameData.QUEST_COLOR)
	for c in node.get_children():
		if c != node.get_meta("glow") and not (node.has_meta("fire") and c == node.get_meta("fire")):
			c.queue_free()
	if node.has_meta("fire"):

		var fire: RoVisual = node.get_meta("fire")
		fire.tint = Color.WHITE
		fire.sprite.modulate = Color.WHITE
		world.spawn_fx("firepillar", node.global_position, 0.6, 0.6)
	else:
		(node.get_meta("glow") as Node3D).visible = false

	var tether = (node.get_meta("tether") if node.has_meta("tether") else null)
	if tether != null and is_instance_valid(tether):
		for k in 4:
			Vfx.burst(world.fx_root, node.global_position.lerp(pos, (k + 0.5) / 4.0) + Vector3(0, 0.6, 0), 0.8, col)
		tether.queue_free()
	Vfx.burst(world.fx_root, node.global_position, 2.4, col)
	Vfx.column(world.fx_root, node.global_position, col)
	world.spawn_fx("h_levelup", node.global_position, 0.8, 0.8)
	world.shake(0.3)
	world.play_sound("job_levelup", 0.0, -6.0)
	_seal_i += 1
	_hold = 0.0
	world.number(node.global_position + Vector3(0, 1.8, 0), "%d/%d" % [_seal_i, _seals.size()], col, true)
	_mark_seal()




func _spawn_tough(id: String, near: float, far: float) -> Enemy:
	var at: = world.map.find_point_around(pos, near, far)
	if at == Vector3.INF:
		at = world.map.find_point_around(world.player.position, 6.0, 12.0)
	if at == Vector3.INF:
		return null
	var e: = world.spawn_enemy(id, at, true, bool(data.get("ferocious", false)))
	if e != null:
		if world.hard:
			e.max_hp *= float(data.get("hard", {}).get("guardian_hp", 1.0))
			e.hp = e.max_hp
		Vfx.column(world.fx_root, e.position, Color(1.0, 0.4, 0.35))

		Vfx.magic_circle(e, Vector3(0, 0.05, 0), e.radius * 2.4 + 0.6, Color(1.0, 0.3, 0.25, 0.6), 0.0, "mvp_hexa", 0.7)
		world.shake(0.4)
		world.play_sound("warning", 0.0, -8.0)
	return e




func _open_exit() -> void :
	var dist: Array = data.get("distance", [24.0, 32.0])
	var at: = Vector3.INF
	for k in [1.0, 0.75, 0.5]:
		for i in 16:
			var c: = world.map.find_point_around(pos, float(dist[0]) * k, float(dist[1]) * k)
			if c != Vector3.INF and world.flow.reachable(c):
				at = c
				break
		if at != Vector3.INF:
			break
	if at == Vector3.INF:
		at = world.map.find_point_around(pos, float(dist[0]) * 0.5, float(dist[1]))
	if at == Vector3.INF:
		at = pos

	if not world.flow.reachable(at):
		var reach: = world.map.reachable_point(at, world.player.position)
		if reach != Vector3.INF:
			at = reach
	exit_pos = Vector3(at.x, world.map.height_at(at), at.z)
	_exit = Node3D.new()
	world.run_root.add_child(_exit)
	_exit.global_position = exit_pos

	Vfx.warp_portal(_exit, GameData.QUEST_COLOR, 1.1)
	Vfx.magic_circle(_exit, Vector3(0, 0.05, 0), 1.9, Color(GameData.QUEST_COLOR, 0.55), 0.0, "mvp_hexa", 0.5)
	var glow: = Vfx.ground_glow(_exit, Vector3.ZERO, 2.2, Color(GameData.QUEST_COLOR, 0.5))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.2, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.6, 0.7).set_trans(Tween.TRANS_SINE)
	_label(_exit, tr("Salida"), GameData.QUEST_COLOR, 2.4, 30)



func _follow(delta: float) -> void :
	var to: = (world.player.position - npc.global_position) * Vector3(1, 0, 1)
	var d: = to.length()
	if d > CATCH_UP:
		var near: = world.map.find_point_around(world.player.position, 1.0, 2.5)
		if near != Vector3.INF:
			Vfx.column(world.fx_root, npc.global_position, Color(1, 0.9, 0.7))
			npc.global_position = Vector3(near.x, world.map.height_at(near), near.z)
		return
	if d > FOLLOW_GAP:

		var dir: = world.flow.direction(npc.global_position)
		if dir == Vector3.ZERO:
			dir = to / d
		var step: = world.map.slide(npc.global_position, dir * float(data.get("speed", 4.5)) * delta)
		npc.face(to)
		npc.play(RoVisual.MOB_WALK)

		_walk_t += delta
		var hop: = absf(sin(_walk_t * 11.0)) * 0.14 if npc.ro != null and npc.ro.base_count() < 2 else 0.0
		npc.global_position = Vector3(step.x, world.map.height_at(step) + hop, step.z)
	else:
		npc.play(RoVisual.MOB_IDLE)
		_walk_t = 0.0
		npc.global_position.y = world.map.height_at(npc.global_position)
	pos = npc.global_position


func _spawn_wave() -> void :
	var goal: = _defended()
	var at_hero: = str(data.type) in ["hunt", "ritual"]
	var center: = world.player.position if at_hero else goal.global_position
	var mobs: Array = data.mobs
	for i in roundi(_scaled("batch")):
		var at: = world.map.find_point_around(center, 9.0, 13.0)
		if at == Vector3.INF:
			continue
		var e: = world.spawn_enemy(str(mobs.pick_random()), at, true)
		if e != null:
			e.summoned = true
			if not at_hero:
				e.target = goal
			_adds.append(e)


func _succeed() -> void :
	state = "done"
	result = "done"
	_release_adds()
	var rw: Dictionary = data.get("reward", {})
	if rw.has("pet"):
		Save.add_pet(str(rw.pet))
	if rw.has("card"):
		Save.add_card(str(rw.card))
	Save.complete_quest(stage_id)
	world.emote(npc, "love", LEAVE_AFTER)
	_chat(npc, tr(str(data.thanks)))
	world.play_sound("job_levelup", 0.0, -2.0)
	Vfx.burst(world.fx_root, pos, 3.0, GameData.QUEST_COLOR)
	world.spawn_fx("h_levelup", pos, 1.0, 1.0)
	world.spawn_fx("h_levelup", world.player.position, 0.8, 0.9, world.player)
	Vfx.magic_circle(world.fx_root, pos + Vector3(0, 0.05, 0), 2.6, Color(GameData.QUEST_COLOR, 0.7), 1.8, "mvp_rune", 0.8)
	_free_cage()
	if _bar != null and is_instance_valid(_bar):
		_bar.queue_free()

	if exit_pos != Vector3.INF and is_instance_valid(npc):
		npc.face(exit_pos - npc.global_position)
		npc.play(RoVisual.MOB_WALK)
		var walk: = npc.create_tween()
		walk.tween_property(npc, "global_position", exit_pos, 0.8)
		walk.tween_callback( func(): npc.play(RoVisual.MOB_IDLE))
	world.hud.announce(tr("¡Quest completada!"), GameData.QUEST_COLOR, tr(str(data.name)))
	world.net.announce(tr("¡Quest completada!"), GameData.QUEST_COLOR, tr(str(data.name)))
	var shown: = data.duplicate()
	get_tree().create_timer(1.0, false).timeout.connect( func():
		if world.running:
			world.menus.show_quest_reward(shown))
	_leave(LEAVE_AFTER)


func _fail() -> void :
	state = "failed"
	result = "failed"
	_release_adds()
	if _bar != null and is_instance_valid(_bar):
		_bar.queue_free()
	if is_instance_valid(npc):
		world.emote(npc, "cry", LEAVE_AFTER)
		_chat(npc, tr(str(data.fail)), Color(0.75, 0.85, 1.0))

		npc.tint = Color(0.62, 0.64, 0.72)
		npc.sprite.modulate = npc.tint
		Vfx.ring(world.fx_root, pos + Vector3(0, 0.05, 0), 2.0, Color(0.45, 0.5, 0.65), 0.6)
		_leave(LEAVE_AFTER)
	if world.running and not world.raid.in_arena():
		world.party_announce(tr("Quest fallida"), Color(1.0, 0.45, 0.4), tr("Vuelve a intentarlo en la próxima partida"))
		world.play_sound("refine_fail", 0.0, -6.0)



func _release_adds() -> void :
	for e in _adds:
		if is_instance_valid(e):
			e.target = null
	_adds.clear()



func _leave(after: float) -> void :
	var who: Array = [npc, prop, _exit, _cage]
	who.append_array(_seal_nodes)
	_seal_nodes.clear()
	_seals.clear()
	exit_pos = Vector3.INF
	get_tree().create_timer(after, false).timeout.connect( func():
		world.play_sound("teleport", 0.0, -8.0)
		for n in who:
			if n != null and is_instance_valid(n):


				Vfx.column(world.fx_root, n.global_position, Color(1, 0.9, 0.7))
				var tw: Tween = n.create_tween().set_parallel()
				if n is RoVisual:
					tw.tween_property((n as RoVisual).sprite, "modulate:a", 0.0, 0.45)
					tw.tween_property(n, "position:y", n.position.y + 0.6, 0.45)
				else:
					tw.tween_property(n, "scale", Vector3.ONE * 0.01, 0.4)
				tw.chain().tween_callback(n.queue_free)
		pos = Vector3.INF)


func _clear() -> void :
	for n in [npc, prop, _exit, _cage, _bar] + _seal_nodes:
		if n != null and is_instance_valid(n):
			n.queue_free()
	_bar = null
	npc = null
	prop = null
	_exit = null
	_cage = null
	_seal_nodes.clear()
	_seals.clear()
	_seal_i = 0
	_hold = 0.0
	_guardian = null
	_boss = null
	pos = Vector3.INF
	exit_pos = Vector3.INF
	_adds.clear()





func autopilot_goal() -> Vector3:
	if not shows() or pos == Vector3.INF:
		return Vector3.INF
	if state == "active" and exit_pos != Vector3.INF:

		if _flat(world.player.position, npc.global_position) > 6.0:
			return npc.global_position
		return exit_pos
	if state == "active" and str(data.type) in ["hunt", "ritual"]:
		var m: = marker()
		return m if m != pos and _flat(world.player.position, m) > 0.6 else Vector3.INF
	var at: = pos if state == "offer" or prop == null else prop.global_position
	return at if _flat(world.player.position, at) > (0.5 if state == "offer" else 3.0) else Vector3.INF




func _npc_sprite() -> RoSprite:
	return npc_sprite_of(data)


static func npc_sprite_of(d: Dictionary) -> RoSprite:
	if d.has("npc_look"):
		var lk: Dictionary = d.npc_look
		return RoAssets.styled_character(str(lk.body), str(lk.get("weapon", "")), "", [RoVisual.PC_ATTACK], 
			str(lk.get("hat", "")), lk.get("look", {}))
	return RoAssets.sprite([str(d.npc)])




func _build_cage() -> void :
	_cage = Node3D.new()
	world.run_root.add_child(_cage)
	_cage.global_position = pos
	var col: = Color(0.6, 0.72, 1.0)
	Vfx.magic_circle(_cage, Vector3(0, 0.05, 0), 1.5, Color(col, 0.7), 0.0, "mvp_rune", 0.35)
	for k in 7:
		var a: = TAU * k / 7.0
		var bar: = Vfx.beam(_cage, Vector3(cos(a), 0, sin(a)) * 1.15, col.lightened(0.3), 2.8)
		bar.scale = Vector3(0.5, 1.0, 1.0)

	var lid: = Vfx.magic_circle(_cage, Vector3(0, 2.6, 0), 1.25, Color(col.lightened(0.2), 0.6), 0.0, "mvp_hexa", -0.5)
	if lid != null:
		lid.set_meta("lid", true)
	npc.tint = Color(0.72, 0.8, 1.0)
	npc.sprite.modulate = npc.tint



func _free_cage() -> void :
	if _cage == null or not is_instance_valid(_cage):
		return
	for k in 7:
		var a: = TAU * k / 7.0
		Vfx.burst(world.fx_root, pos + Vector3(cos(a), 0.9, sin(a)) * Vector3(1.15, 1, 1.15), 0.9, Color(0.7, 0.8, 1.0))
	Vfx.ring(world.fx_root, pos + Vector3(0, 0.05, 0), 2.6, Color(0.75, 0.85, 1.0), 0.5)
	world.play_sound("stone_curse", 0.0, -6.0)
	world.shake(0.3)
	_cage.queue_free()
	_cage = null
	if is_instance_valid(npc):
		npc.tint = Color.WHITE
		npc.sprite.modulate = Color.WHITE



func _tether(from: Vector3, to: Vector3, col: Color) -> MeshInstance3D:
	var a: = from + Vector3(0, 0.6, 0)
	var b: = to + Vector3(0, 0.6, 0)
	var length: = a.distance_to(b)
	if length < 0.1:
		return null
	var mi: = MeshInstance3D.new()
	var box: = BoxMesh.new()
	box.size = Vector3(0.07, 0.07, length)
	mi.mesh = box
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_color = Color(col, 0.55)
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.run_root.add_child(mi)
	mi.global_position = (a + b) * 0.5
	mi.look_at(b, Vector3.UP)
	var tw: = mi.create_tween().set_loops()
	tw.tween_property(m, "albedo_color:a", 0.25, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(m, "albedo_color:a", 0.6, 0.5).set_trans(Tween.TRANS_SINE)
	return mi



func _build_bar() -> void :
	_bar = Node3D.new()
	prop.add_child(_bar)
	_bar.position = Vector3(0, world._sprite_height(prop) + 0.35, 0)
	var back: = _bar_quad(Vector2(1.9, 0.26), Color(0.05, 0.05, 0.08, 0.9), 18)
	_bar.add_child(back)
	_bar_fill = _bar_quad(Vector2(1.8, 0.17), Color(0.35, 0.95, 0.4), 19)
	_bar.add_child(_bar_fill)
	_update_bar()


func _update_bar() -> void :
	if _bar_fill == null or not is_instance_valid(_bar_fill):
		return
	var f: = clampf(float(hp) / maxf(1.0, max_hp), 0.0, 1.0)
	(_bar_fill.mesh as QuadMesh).size.x = 1.8 * f
	(_bar_fill.mesh as QuadMesh).center_offset.x = -1.8 * (1.0 - f) * 0.5
	(_bar_fill.material_override as StandardMaterial3D).albedo_color = Color(1.0, 0.3, 0.25).lerp(Color(0.35, 0.95, 0.4), f)


func _bar_quad(size: Vector2, col: Color, priority: int) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	q.size = size
	mi.mesh = q
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.no_depth_test = true
	m.render_priority = priority
	m.albedo_color = col
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi



func _scaled(key: String) -> float:
	var v: = float(data.get(key, 0.0))
	if world.hard:
		v *= float(data.get("hard", {}).get(key, 1.0))
	return v


func _chat(node: Node3D, text: String, col: = Color(1, 1, 1)) -> void :
	if text == "" or node == null or not is_instance_valid(node):
		return
	var l: = _label(node, text, col, 3.6, 28)
	var tw: = l.create_tween()
	tw.tween_interval(3.0)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


func _label(node: Node3D, text: String, col: Color, height: float, size: = 32, outline: = true) -> Label3D:
	var l: = Label3D.new()
	l.text = text
	l.font = RO_FONT_BOLD
	l.font_size = size
	l.pixel_size = 0.012
	l.outline_size = 9 if outline else 6
	l.outline_modulate = Color(0, 0, 0, 0.9)
	l.modulate = col
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 20
	l.outline_render_priority = 19
	l.position = Vector3(0, height, 0)
	node.add_child(l)
	return l


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
