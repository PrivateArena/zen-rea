class_name TowerRun
extends Node

# [MOD] Endless Tower nerf: floor index used for enemy HP/damage growth is clamped, so the exponential
# 1.06^floor (HP) / 1.035^floor (damage) stops compounding past MOD_TOWER_FLOOR_CAP while the hero keeps
# growing at TOWER_FLOOR_DMG. Hel floors reach eff() = 100 + 5*floor, which is what made floor ~200
# absurd; the clamp flattens that whole tail. Speed growth is deliberately left untouched.
const MOD_TOWER_FLOOR_CAP: = 90.0



















var world: World
var floor: = 1

var _from: = 1

var best: = 0



var state: = "rest"
var need: = 0

var rule: = ""


var blessings: Array[String] = []
var party_bless: = {}

var mirror: = false
var _net_done: = 0

var _net_wheel: Array = []
var _net_spun: = 0


var _bless_offer: Array = []

var _camp_shown: = ""
var _net_key: = ""
var _net_t: = 0.0
var _kills_at: = 0
var _mvps_at: = 0
var _spawn_t: = 0.0

var _opening: = 0
var _rest_t: = 0.0
var _mobs: Array = []

var _mvp_bag: Array = []
var _floor_t0: = 0.0



var _stairs: Node3D
var _stairs_at: = Vector3.INF
var _climb_t: = 0.0

var _stairs_hold: = 0.0
var _hold_pulse: = 0.0


var _lucile: RoVisual
var _traps: RefCounted
var _events: RefCounted

var wheel_buffs: Array = []
var wheel_curses: Array = []
var _camp_gift: = ""

var _camp_talked: = true

var _sign_kind: = ""
var _sign_t: = 0.0
var _force_event: = ""
var _camp_floor: = 0


var hel: RefCounted = null



func make_hel() -> void :
	hel = preload("res://scripts/core/hel_tower.gd").new(world, self)





func eff(f: = -1) -> int:
	if f < 0:
		f = floor
	return f if hel == null else GameData.HEL_TOWER_FROM + roundi(GameData.HEL_TOWER_PACE * f)




func inside(at: Vector3) -> Vector3:
	return _events.inside(at) if _events != null else at


func _init(w: World, start_floor: int) -> void :
	world = w
	_traps = preload("res://scripts/core/tower_traps.gd").new(w)
	_events = preload("res://scripts/core/tower_events.gd").new(w, self)
	floor = maxi(1, start_floor)
	_from = floor
	name = "TowerRun"


func _ready() -> void :
	_rest_t = 1.2




static func tier_of(f: int) -> int:
	return clampi(((f - 1) % GameData.TOWER_FLOORS) / GameData.TOWER_TIER_FLOORS, 0, GameData.TOWER_TIERS.size() - 1)


static func tier_stage(f: int) -> Dictionary:
	return GameData.STAGES[GameData.TOWER_TIERS[tier_of(f)]]







const TIER_MUSIC: = {"payon": "payon"}


func music_map() -> String:
	var sid: String = GameData.TOWER_TIERS[tier_of(floor)]
	return str(TIER_MUSIC.get(sid, tier_stage(floor).map))



static func map_of(f: int) -> String:
	var k: = (f - 1) % GameData.TOWER_FLOORS + 1
	for band in GameData.TOWER_MAPS:
		if k <= int(band[0]):
			return str(band[1])
	return str(GameData.TOWER_MAPS.back()[1])





func scale_time(boss: = false) -> float:
	return (eff() - 1) * (GameData.TOWER_BOSS_FLOOR_TIME if boss else GameData.TOWER_FLOOR_TIME)



static func cycle_of(f: int) -> int:
	return (f - 1) / GameData.TOWER_FLOORS




func _mvp_of(f: int) -> String:
	if f % GameData.TOWER_FLOORS == 0:
		return GameData.TOWER_LORD
	if f < GameData.TOWER_FLOORS:
		return str(tier_stage(f).get("mvp", ""))
	if _mvp_bag.is_empty():
		for id in GameData.RAIDS:
			if id != GameData.TOWER_LORD and world.raid.supports(str(id)):
				_mvp_bag.append(id)
		_mvp_bag.shuffle()
	return str(_mvp_bag.pop_back()) if not _mvp_bag.is_empty() else str(tier_stage(f).get("mvp", ""))


func _process(delta: float) -> void :
	if mirror:
		_events.mirror_tick()
		if hel != null:
			hel.draw_tick()
		if world.running and world.player != null:
			_near_lucile()
			_net_wheel_check()

			if _stairs_at != Vector3.INF:
				_stairs_hold_tick(delta, _in_stairs(world.player))
	if not _bless_offer.is_empty() and world.running and not world.get_tree().paused and world.menus.mode() == "closed":
		_show_blessing()
	if mirror or not world.running or world.player == null or world.get_tree().paused:
		return
	_sync(delta)
	if world.raid.in_arena():
		return
	match state:
		"rest":
			_rest_t -= delta



			if _rest_t > 900.0 and world.menus.mode() == "closed":
				_camp_closed(_camp_shown)
			if _rest_t <= 0.0:
				_start_floor()
		"sign":
			_sign_t -= delta
			if _sign_t <= 0.0:
				_start_event(_sign_kind)
		"event":
			_events.tick(delta, floor)
			if hel != null:
				hel.tick(delta, 0.0, 1.0)
			if _events.done:
				_cleared()
		"fight":
			_spawn(delta, 1.0)
			_traps.tick(delta, floor)
			if hel != null:
				hel.tick(delta, world.kills - _kills_at, need)
			if world.kills - _kills_at >= need:
				_cleared()
		"boss":
			if hel != null:
				hel.tick(delta, 0.0, 1.0)
			if world.raid.active():
				return
			_spawn(delta, 0.4)
			if world.run_mvps > _mvps_at:
				_cleared()
		"camp":
			_climb_t += delta
			if _lucile == null:
				_open_camp()
			_near_lucile()
			if world.autopilot and _climb_t > 1.5:
				_talk_lucile()
		"climb":
			_climb_t += delta
			_near_lucile()
			if _stairs_at == Vector3.INF:
				_open_stairs()

			var near: = false
			for h in world.heroes:
				if _in_stairs(h):
					near = true

			if _stairs_hold_tick(delta, near) or (world.autopilot and _climb_t > 1.5):
				_go_up()


func _in_stairs(h: Player) -> bool:
	return is_instance_valid(h) and not h.downed and _stairs_at != Vector3.INF and Vector2(h.position.x - _stairs_at.x, h.position.z - _stairs_at.z).length() < GameData.TOWER_STAIRS_REACH







func _stairs_hold_tick(delta: float, near: bool) -> bool:
	if not near or not world.altars.waiting.any( func(a): return is_instance_valid(a.get("node"))):
		_stairs_hold = 0.0
		return near
	if _stairs_hold <= 0.0:
		_hold_pulse = 0.0
		world.number(_stairs_at + Vector3(0, 2.4, 0), TranslationServer.translate("Hay un altar en el piso: quédate en el portal"), Color(0.85, 0.7, 1.0), true)
		world.play_sound("beginspell", 0.0, -4.0)
	_stairs_hold += delta
	_hold_pulse -= delta
	if _hold_pulse <= 0.0:
		_hold_pulse = 0.25
		var k: = minf(_stairs_hold / GameData.TOWER_STAIRS_HOLD, 1.0)
		Vfx.ring(world.fx_root, _stairs_at + Vector3(0, 0.1, 0), 0.5 + 1.2 * k, Color(0.85, 0.7, 1.0).lightened(0.3), 0.35)
		world.play_sound("ui_click", 0.0, -16.0 + 10.0 * k)
	return _stairs_hold >= GameData.TOWER_STAIRS_HOLD




func _open_camp() -> void :
	var p: = world.player
	var at: = world.map.find_point_around(p.position, 3.5, 5.5)
	if at == Vector3.INF:
		at = world.map.random_point_around(p.position, 3.0)
	_make_lucile(at, p.position)
	world.net.tower_event(["lucile", at, p.position])



func _make_lucile(at: Vector3, look: Vector3) -> void :
	_lucile = world.raid._make_sprite("npc_lucile", Color.WHITE, 44, 1.0, at)
	_lucile.face((look - at) * Vector3(1, 0, 1))
	var lbl: = Label3D.new()
	lbl.text = tr("Lucile")
	lbl.font_size = 34
	lbl.pixel_size = 0.012
	lbl.outline_size = 8
	lbl.modulate = Color(0.85, 0.95, 1.0)
	lbl.outline_modulate = Color(0.1, 0.1, 0.25, 0.9)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.render_priority = 20
	lbl.position = Vector3(0, 3.3, 0)
	_lucile.add_child(lbl)
	Vfx.magic_circle(_lucile, Vector3.ZERO, 2.2, Color(0.6, 0.9, 1.0, 0.55), 0.0, "mvp_rune", 0.5, -1, true)
	world.spawn_fx("angelus", at, 1.0, 0.7)
	world.play_sound("portal", 0.0, -4.0)
	if not mirror:
		world.hud.alerts.warn(tr("Zona de descanso: habla con Lucile"), Color(0.6, 0.9, 1.0), "party_alarm")




func _near_lucile() -> void :
	if _camp_talked or _lucile == null or not is_instance_valid(_lucile):
		return
	var p: = world.player
	if p.downed or world.menus.is_open():
		return
	if Vector2(p.position.x - _lucile.position.x, p.position.z - _lucile.position.z).length() < GameData.TOWER_CAMP_REACH:
		_talk_lucile()


func _talk_lucile() -> void :
	if _camp_talked:
		return
	_camp_talked = true
	var gift: = _camp_gift
	_camp_gift = ""
	if not mirror and state == "camp":
		state = "rest"
		_rest_t = 999.0
	elif mirror:
		world.net.send(1, "tower_camp")
	_camp_shown = gift
	world.menus.show_tower_camp(_camp_floor, gift, _camp_closed.bind(gift))


func _camp_closed(gift: String) -> void :
	_camp_shown = ""
	_gift_taken(gift)
	if not mirror and state == "rest" and _rest_t > 900.0:
		state = "climb"
		_climb_t = 0.0


func _gift_taken(gift: String) -> void :
	if gift == "power":
		world.player.tower_power = Save.tower_power()
		world.player.recompute()
		if mirror:
			world.net.send(1, "tower_pw", [Save.tower_power()])
	if gift != "":
		world.play_sound("drop_yellow", 0.0, -4.0)



func member_at_camp() -> void :
	if state == "camp":
		state = "climb"
		_climb_t = 0.0



func _camp_missed() -> void :
	if not _camp_talked and _camp_gift != "":
		_reward_shown(_camp_gift)
	_camp_talked = true
	_camp_gift = ""



func _open_stairs() -> void :
	var p: = world.player


	var at: Vector3 = hel.exit if hel != null and hel.exit != Vector3.INF else Vector3.INF
	for i in (30 if at == Vector3.INF else 0):
		var a: = - PI * 0.5 + randf_range(-0.7, 0.7) + RoVisual.view_yaw
		var d: = randf_range(GameData.TOWER_STAIRS_DIST * 0.7, GameData.TOWER_STAIRS_DIST)
		var q: = p.position + Vector3(cos(a), 0, sin(a)) * d
		if world.map.can_reach(q, p.position):
			at = q
			break
	if at == Vector3.INF:
		at = world.map.find_point_around(p.position, GameData.TOWER_STAIRS_DIST * 0.7, GameData.TOWER_STAIRS_DIST)
	if at == Vector3.INF:
		at = world.map.random_point_around(p.position, 4.0)


	var reach: = world.map.reachable_point(at, p.position)
	if reach != Vector3.INF:
		at = reach
	_make_stairs(Vector3(at.x, world.map.height_at(at), at.z))
	if hel != null:
		hel.exit = Vector3.INF

	for h in world.heroes:
		h.add_power("tower_wind", GameData.TOWER_WIND_TIME)
	world.net.tower_event(["stairs", _stairs_at, floor])



func _make_stairs(at: Vector3) -> void :
	_stairs_at = at
	_stairs = Node3D.new()
	world.fx_root.add_child(_stairs)
	_stairs.global_position = _stairs_at
	Vfx.warp_portal(_stairs, Color(0.85, 0.7, 1.0), 1.2)
	var lbl: = Label3D.new()
	lbl.text = tr("▲  Piso %d") % floor
	lbl.font_size = 44
	lbl.pixel_size = 0.012
	lbl.outline_size = 9
	lbl.modulate = Color(1.0, 0.92, 1.0)
	lbl.outline_modulate = Color(0.25, 0.1, 0.4, 0.95)
	lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lbl.no_depth_test = true
	lbl.render_priority = 20
	lbl.position = Vector3(0, 3.2, 0)
	_stairs.add_child(lbl)
	var bob: = lbl.create_tween().set_loops()
	bob.tween_property(lbl, "position:y", 3.5, 0.6).set_trans(Tween.TRANS_SINE)
	bob.tween_property(lbl, "position:y", 3.2, 0.6).set_trans(Tween.TRANS_SINE)
	Vfx.column(world.fx_root, _stairs_at, Color(0.85, 0.7, 1.0))
	world.spawn_fx("angelus", _stairs_at, 1.2, 0.7)
	world.play_sound("portal", 0.0, -2.0)
	world.hud.alerts.warn(tr("¡El camino al piso %d está abierto! Corre al portal") % floor, Color(0.85, 0.7, 1.0), "party_alarm")

	if hel != null:
		lbl.text = tr("▼  Piso %d") % floor




func _go_up() -> void :
	var p: = world.player
	Vfx.column(world.fx_root, p.position, Color(0.9, 0.8, 1.0))
	world.play_sound("teleport", 0.0, -2.0)
	_clear_marks()
	_camp_missed()
	world.net.tower_event(["up"])
	for h in world.heroes:
		h.powers.erase("tower_wind")
		h.recompute()
	var m: = map_of(floor)
	if world.map.map_name != m:
		_swap_map(m)
	else:
		_hop()
	state = "rest"
	_rest_t = GameData.TOWER_UP_PAUSE



func _clear_marks() -> void :
	if _stairs != null and is_instance_valid(_stairs):
		_stairs.queue_free()
	_stairs = null
	if _lucile != null and is_instance_valid(_lucile):
		_lucile.queue_free()
	_lucile = null
	_stairs_at = Vector3.INF
	_stairs_hold = 0.0




func _place_party(at: Vector3, map: = "") -> void :
	var p: = world.player
	p.position = Vector3(at.x, world.map.height_at(at), at.z)
	for h in world.heroes:
		if h == p:
			continue
		var q: = world.map.find_point_around(at, 1.0, 2.5)
		if q == Vector3.INF:
			q = at
		h.position = Vector3(q.x, world.map.height_at(q), q.z)
		if world.net.is_remote(h):
			world.net.tower_event_to(h, ["map", map, h.position] if map != "" else ["hop", h.position])
	if world.pet != null:
		world.pet.position = p.position + Vector3(1, 0, 0.5)
	world.snap_camera()




func _hop() -> void :
	for pk in world.pickups.duplicate():


		if pk.kind in GameData.TOWER_CARRY_COLLECT:
			world._collect(pk)
			pk.node.queue_free()
			world.pickups.erase(pk)
	world.clear_battlefield()
	var p: = world.player
	var at: = world.map.find_point_around(p.position, 12.0, 30.0)
	if at == Vector3.INF:
		at = world.map.spawn_point()
	_place_party(at)
	for pk in world.pickups:
		pk.node.position = world.map.random_point_around(p.position, 2.0) + Vector3(0, 0.5, 0)
	Vfx.column(world.fx_root, p.position, Color(0.75, 0.6, 1.0))


func _start_floor() -> void :
	world.altars.floor_over()
	_traps.floor_start()
	_wheel_floor()

	var m: = map_of(floor)
	if world.map.map_name != m:
		_swap_map(m)
	world.web_prefetch_run()

	world.play_music_map(music_map())
	var st: = tier_stage(floor)
	_mobs.clear()
	for sp in st.spawns:
		var d: Dictionary = GameData.MONSTERS.get(sp.mob, {})
		if not d.is_empty() and not d.get("static", false) and not d.has("boss") and not _mobs.has(sp.mob):
			_mobs.append(sp.mob)
	if _mobs.is_empty():
		_mobs = ["poring"]
	_kills_at = world.kills
	_mvps_at = world.run_mvps
	_floor_t0 = world.time

	world._crowd_debt = 0
	var top: = floor % GameData.TOWER_TIER_FLOORS == 0
	rule = ""
	if not top and GameData.TOWER_RULE_FLOORS.has(floor % GameData.TOWER_TIER_FLOORS):
		rule = str(GameData.TOWER_RULES.keys().pick_random())
	_apply_mods()
	need = roundi((GameData.TOWER_KILLS + GameData.TOWER_KILLS_STEP * floor) * float(_rule().get("kills", 1.0)))
	_spawn_t = 0.0
	_opening = GameData.TOWER_OPENING
	var sub: = tr(str(st.name))
	var col: = Color(0.95, 0.75, 1.0)
	var event: = {}
	if top:
		state = "boss"
		var mvp: = _mvp_of(floor)
		var lord: = mvp == GameData.TOWER_LORD
		sub = tr("¡MVP: %s!") % tr(str(GameData.MONSTERS.get(mvp, {}).get("name", mvp)))
		col = Color(1.0, 0.45, 0.4)
		if lord:
			sub = tr("La cima: ¡Naght Sieger te espera!")
			col = Color(1.0, 0.3, 0.25)
		if world.raid.supports(mvp):
			world.raid.open_portal(mvp)
			if lord:
				_lord_talk()
		elif GameData.MONSTERS.has(mvp):
			world._run_event({"type": "boss", "mob": mvp})
	# [MOD] The shipped event gate is every 10 floors (TOWER_TIER_FLOORS) and pick() never repeats a kind, so
	# MOD_EVENT_W alone could not bring the Emperium trial under ~24 floors. Also fire the sign on the floor
	# TowerEvents.emp_due() declares due (MOD_EMP_EVERY floors past the last trial): that puts the trial on a
	# ~9 floor rhythm, which is below the tier's 10 and therefore impossible from the residue alone. The
	# shipped residue-5 floors still carry the roll, so the other five kinds keep their own cadence.
	# Coop is safe: _sync() (:995-1007) is host-only and re-broadcasts state + _sign_kind every 0.25 s, so a
	# peer's own local emp_due() answer (its _emp_floor can drift, same as its discarded weighted roll did
	# before) is overwritten by the host's floor state before the floor can start.
	elif (_events != null and _events.emp_due(floor)) or (floor >= GameData.TOWER_EVENT_FROM and floor % GameData.TOWER_TIER_FLOORS == GameData.TOWER_EVENT_AT):

		_sign_kind = _force_event if _force_event != "" else _events.pick_for(floor)
		_force_event = ""
		_sign_t = GameData.TOWER_EVENT_SIGN
		state = "sign"
		event = GameData.TOWER_EVENTS[_sign_kind]
	else:
		state = "fight"

		if floor % GameData.TOWER_TIER_FLOORS == GameData.TOWER_TIER_FLOORS / 2:
			sub = tr("%s  ·  ¡élites!") % sub
			for i in 2:
				world._spawn_ferocious()
		if rule != "":
			var r: = _rule()
			sub = "%s  ·  %s" % [tr(str(r.name)), tr(str(r.desc))]
			col = Color(r.color)
			for i in int(r.get("elites", 0)):
				world._spawn_ferocious()
	var title: = tr("Piso %d") % floor
	if hel != null:
		title = tr("Torre de Hel  ·  Piso %d") % floor
	elif cycle_of(floor) > 0:
		title = tr("Piso %d  ·  Ciclo %d") % [floor, cycle_of(floor) + 1]
	if not event.is_empty():
		sub = "%s  ·  %s" % [title, tr(str(event.hint))]
		title = tr(str(event.name))
		col = Color(event.color)
		world.hud.event_sign(title, sub, col, GameData.TOWER_EVENT_SIGN)
		world.play_sound("party_alarm", 0.0, -4.0)
	else:

		if floor > 1:
			var more: = tr("×%s de daño por los pisos") % str(snappedf(hero_mult(), 0.01))
			sub = "%s  ·  %s" % [sub, more] if sub != "" else more
		world.hud.announce(title, col, sub)
	world.net.announce(title, col, sub)
	world.play_sound("portal", 0.0, -4.0)
	if hel != null:
		hel.floor_start(floor, state == "fight")




func _lord_talk() -> void :


	if hel != null:
		world.net.tower_event(["talk", "talk_hel"])
		_show_talk("talk_hel")
		return


	if Save.has_seen("tower", "naght_talk"):
		return
	Save.mark_seen("tower", "naght_talk")
	var key: = "talk" if cycle_of(floor) == 0 else "talk_again"
	world.raid.portal_sealed = true
	world.net.tower_event(["talk", key])
	_show_talk(key, world.raid.unseal_portal)


func _show_talk(key: String, done: = Callable()) -> void :
	var lines: = []
	for l in GameData.NAGHT[key]:
		lines.append([tr(str(l[0])), tr(str(l[1])), str(l[2])])

	world.hud.npc_talk("tnm_lucile01", tr("Lucile"), lines, 2.6, done, GameData.TOWER_LORD)


static func wheel_entry(id: String) -> Dictionary:
	for e in GameData.TOWER_WHEEL:
		if str(e.id) == id:
			return e
	return {}



func wheel_take(id: String) -> void :
	var e: = wheel_entry(id)
	if str(e.get("kind", "")) == "curse":
		wheel_curses.append({"id": id, "left": int(e.floors)})
	else:
		wheel_buffs.append(id)
	_wheel_sync()



func _wheel_floor() -> void :
	for c in wheel_curses:
		c.left = int(c.left) - 1
	var had: = wheel_curses.size()
	wheel_curses = wheel_curses.filter( func(c): return int(c.left) > 0)
	if had != wheel_curses.size():
		world.party_announce(tr("Maldición disipada"), Color(0.7, 0.9, 1.0), "")
		_wheel_sync()


func _wheel_sync() -> void :
	_apply_mods()
	world.net.tower_event(["wheel", wheel_buffs, wheel_curses])




func _start_event(force: = "") -> void :
	rule = ""
	var ev: String = _events.start(floor, force)
	if ev == "duel":
		state = "boss"
		var mvp: = str(tier_stage(floor).get("mvp", ""))
		if GameData.MONSTERS.has(mvp):

			var at: = world.map.find_point_around(world.player.position, 4.0, 6.0)
			var b: Enemy = world.spawn_enemy(mvp, at, true)
			if b != null:
				b.max_hp *= GameData.TOWER_DUEL_HP
				b.hp = b.max_hp

				if world.pride_on():
					var keep: = world.pride_resist(b.max_hp)
					if keep < 1.0:
						b.set_meta("pride", keep)
				world.boss = b
				Vfx.column(world.fx_root, b.position, Color(1.0, 0.55, 0.3))
				world.play_sound("warning", 0.0, -4.0)
		return
	state = "event"




func _swap_map(m: String) -> void :
	for p in world.pickups.duplicate():
		if p.kind in GameData.TOWER_CARRY_COLLECT:
			world._collect(p)
			p.node.queue_free()
			world.pickups.erase(p)
	world.clear_battlefield()
	world._load_map(m)
	world.flow.reset()
	_place_party(world.map.spawn_point(), m)
	for p in world.pickups:
		p.node.position = world.map.random_point_around(world.player.position, 2.0) + Vector3(0, 0.5, 0)
	world.play_music_map(music_map())
	Vfx.column(world.fx_root, world.player.position, Color(0.75, 0.6, 1.0))
	world.play_sound("teleport", 0.0, -2.0)




func _spawn(delta: float, mult: float) -> void :
	_spawn_t -= delta * mult
	if _spawn_t > 0.0:
		return
	_spawn_t = GameData.TOWER_SPAWN_EVERY
	var crowd: = mini(GameData.TOWER_CROWD_MAX + GameData.TOWER_CYCLE_CROWD * cycle_of(floor), 
		GameData.TOWER_CROWD + floor / 2 + GameData.TOWER_CYCLE_CROWD * cycle_of(floor))
	crowd = roundi(crowd * float(_rule().get("crowd", 1.0)))
	if world.enemies.size() >= crowd:
		return

	var n: = GameData.TOWER_SPAWN_BATCH
	if _opening > 0:
		n = mini(_opening, crowd - world.enemies.size())
		_opening = 0
	for i in n:
		world.spawn_enemy(str(_mobs.pick_random()), _near_point())




func _near_point() -> Vector3:
	var at: = world.player.position
	var up: = world.alive_heroes()
	if not up.is_empty():
		at = up.pick_random().position
	var p: = world.map.find_point_around(at, GameData.TOWER_SPAWN_NEAR.x, GameData.TOWER_SPAWN_NEAR.y) if world.map != null else Vector3.INF
	return p if p != Vector3.INF else world._offscreen_point()


func _cleared() -> void :
	state = "climb"
	_climb_t = 0.0
	_rest_t = GameData.TOWER_REST
	var cleared: = floor
	best = maxi(best, cleared)
	if world._tower_sim:
		var p: = world.player
		print("TOWERSIM floor=%d t=%d dt=%d lv=%d hp=%d/%d revives=%d mvp=%s rule=%s bless=%s" % [cleared, roundi(world.time), 
			roundi(world.time - _floor_t0), p.level, p.hp, p.max_hp, p.revives, world.raid.stats.get("mvp", "") if state == "boss" else "-", 
			rule, blessings.size()])
	if hel != null:
		hel.floor_over()

	for e in world.enemies.duplicate():
		if not e.is_boss:
			world.banish_enemy(e)
	rule = ""
	_apply_mods()
	var p: = world.player
	for h in world.heroes:
		if not h.downed:
			h.heal(h.max_hp * GameData.TOWER_REST_HEAL, world, true)

	world.net.tower_event(["floor", cleared])
	var reward: = _floor_done(cleared)
	world.play_sound("job_levelup", 0.0, -6.0)
	world.spawn_fx("joblvup", p.position, 1.0, 0.8, p)

	if cleared % GameData.TOWER_TIER_FLOORS == GameData.TOWER_BLESS_FLOOR:
		world.get_tree().create_timer(0.9, false).timeout.connect(_offer_blessing)

	if cleared % GameData.TOWER_TIER_FLOORS == 0:
		state = "camp"
		_camp_floor = cleared
		_camp_gift = reward
		_camp_talked = false
	elif reward != "":
		world.get_tree().create_timer(1.4, false).timeout.connect(_reward_shown.bind(reward))

	var chance: = GameData.TOWER_FACE_CHANCE + GameData.TOWER_FACE_STEP * cleared
	for h in world.heroes:
		if cleared % GameData.TOWER_TIER_FLOORS == 0 or randf() < chance:
			world.get_tree().create_timer(2.6 if reward != "" else 1.2, false).timeout.connect(_face_drop.bind(cleared, h))
	floor += 1




func _offer_blessing() -> void :
	if world.player == null or not world.running:
		return
	for h in world.heroes:
		var keys: = GameData.TOWER_BLESSINGS.keys()
		keys.shuffle()
		keys = keys.slice(0, 3)
		if h == world.player:
			_bless_offer = keys
			_show_blessing()
		elif world.net.is_remote(h):
			world.net.tower_event_to(h, ["bless", keys])
		else:
			take_blessing(h, str(keys.pick_random()))



func _show_blessing() -> void :
	world.menus.show_tower_blessing(_bless_offer, func(id: String):
		_bless_offer = []
		if mirror:
			blessings.append(id)
			world.net.send_tower_bless(id)
		else:
			take_blessing(world.player, id))



func take_blessing(h: Player, id: String) -> void :
	if not GameData.TOWER_BLESSINGS.has(id) or not world.heroes.has(h):
		return
	_blessings_of(h).append(id)
	_apply_mods()
	world.spawn_fx("angelus", h.position, 1.2, 1.0, h)
	if h == world.player:
		world.play_sound("heal", 0.0, -2.0)
	world.number(h.position + Vector3(0, 2.4, 0), tr(str(GameData.TOWER_BLESSINGS[id].name)), Color(0.8, 0.7, 1.0), true)


func _blessings_of(h: Player) -> Array:
	if h == world.player:
		return blessings
	if not party_bless.has(h.slot):
		party_bless[h.slot] = []
	return party_bless[h.slot]



func _apply_mods() -> void :
	var r: = _rule()
	for h in world.heroes:
		var out: = {}
		for id in _blessings_of(h):
			var m: Dictionary = GameData.TOWER_BLESSINGS[id].mods
			for k in m:
				out[k] = float(out.get(k, 0.0)) + float(m[k])
		for id in wheel_buffs + wheel_curses.map( func(c): return c.id):
			var m: Dictionary = wheel_entry(str(id)).get("mods", {})
			for k in m:
				out[k] = float(out.get(k, 0.0)) + float(m[k])
		for k in ["loot", "xp"]:
			if r.has(k):
				out[k] = float(out.get(k, 0.0)) + float(r[k])
		h.tower_mods = out
		h.recompute()


func _rule() -> Dictionary:
	return GameData.TOWER_RULES.get(rule, {})



func _reward_shown(reward: String) -> void :
	var text: = tr("Un hueco más para legendarias en el equipo inicial") if reward == "legend"\
	else tr("+%d%% de daño y de vida en la torre, para siempre") % roundi(GameData.TOWER_POWER * 100.0)
	world.hud.announce(tr("Regalo de Lucile"), Color(0.95, 0.3, 0.35), text)
	world.play_sound("drop_yellow", 0.0, -4.0)
	if reward == "power":
		world.player.tower_power = Save.tower_power()
		world.player.recompute()

		if mirror:
			world.net.send(1, "tower_pw", [Save.tower_power()])





func _face_drop(at_floor: int, h: Player = null) -> void :
	if world.player == null or not world.running:
		return
	if h == null:
		h = world.player
	if not is_instance_valid(h) or not world.heroes.has(h):
		return
	var legend_chance: = minf(GameData.TOWER_FACE_LEGEND_MAX, GameData.TOWER_FACE_LEGEND + GameData.TOWER_FACE_LEGEND_STEP * at_floor)

	var want_legend: = at_floor >= GameData.TOWER_FACE_LEGEND_FROM and (randf() < legend_chance or at_floor % GameData.TOWER_FLOORS == 0)
	want_legend = want_legend or GameData.has_meta("force_face_legend")
	var pool: = []
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		if d.get("face", false) and bool(d.get("legendary", false)) == want_legend:
			pool.append(id)
	if pool.is_empty():
		return
	var it: = Equipment.make(str(pool.pick_random()), 0 if want_legend else 3)


	if not want_legend:
		it["trait"] = GameData.PURPLE_TRAITS.keys().pick_random()
	if h != world.player:

		it["perm"] = world.net.is_remote(h)
		h.equipment.receive(it.duplicate(true))
		h.recompute()
		if world.net.is_remote(h):
			world.net.tower_event_to(h, ["face", it, want_legend])
		return
	_found_face(it, want_legend)




func _found_face(it: Dictionary, want_legend: bool) -> void :



	if Equipment.face_sells(it):
		var z: = Equipment.sell_price(it)
		var price: = Equipment.price_text(it)
		Equipment.cash_in(it)
		world.add_zeny(z, "sold")
		world._sale_feedback(world.player.position, z)
		world.number(world.player.position + Vector3(0, 2.4, 0), tr("%s auto-vendido  +%s") % [Equipment.item_name(it), price], Color(1.0, 0.82, 0.3), true)


		if world.net.is_client():
			world.net._gear_key = ""
		return
	var stored: = Save.add_to_storage(it)
	if stored:
		world.run_stored.append(it.duplicate(true))

	it["perm"] = stored
	if stored:
		it["found_uid"] = str(Save.storage().back().uid)
	var p: = world.player
	var r: = p.equipment.receive(it)
	p.recompute()

	var line: = tr("Lucile: «¡Mira lo que encontré!»") if stored else tr("¡El Almacén Kafra está lleno! Guárdalo al terminar.")
	world.number(p.position + Vector3(0, 2.4, 0), line, Color(0.8, 0.7, 1.0))
	world._open_chest_show(p.position + Vector3(0.8, 0, 0.4), 3, [r], tr("Hallazgo de Lucile"))
	world.play_sound("drop_yellow" if want_legend else "drop_purple", 0.0, -4.0)



func hero_mult() -> float:
	return pow(GameData.TOWER_FLOOR_DMG, maxi(0, eff() - 1))




func scale_enemy(e: Enemy) -> void :


	if e.prop != "":
		return
	var f: = eff() - 1
	var fg: = minf(MOD_TOWER_FLOOR_CAP, float(f))
	var mvp: bool = e.def.get("mvp", false)
	var r: = _rule()
	var growth: = pow(GameData.TOWER_MVP_HP_STEP if mvp else GameData.TOWER_HP_STEP, fg)



	var untrim: = 1.0 / GameData.HELL_HP_TRIM if GameData.hell_level(world.danger) >= GameData.HELL_HP_TRIM_FROM else 1.0
	e.max_hp *= growth * untrim * (1.0 if mvp else float(r.get("hp", 1.0)))
	e.hp = e.max_hp
	e.damage *= pow(GameData.TOWER_MVP_DMG_STEP if mvp else GameData.TOWER_DMG_STEP, fg) * (1.0 if mvp else float(r.get("dmg", 1.0)))
	e.speed *= (1.0 + minf(GameData.TOWER_SPEED_MAX, GameData.TOWER_SPEED_STEP * f) + GameData.TOWER_CYCLE_SPEED * cycle_of(floor))\
	* (1.0 if mvp else float(r.get("speed", 1.0)))
	if r.has("scale") and not mvp and e.visual is Node3D:
		(e.visual as Node3D).scale *= float(r.scale)



func _sync(delta: float) -> void :
	if not world.net.is_host() or not world.is_coop():
		return
	_net_t -= delta
	if _net_t > 0.0:
		return
	_net_t = 0.25
	var st: = [floor, state, need, world.kills - _kills_at, rule, best, _sign_kind if state == "sign" else "", 
		_events.net_info() if state == "event" else []]
	var key: = var_to_str(st)
	if key != _net_key:
		_net_key = key
		world.net.tower_event(["state"] + st)





func _open_net_wheel() -> void :
	var pick: = func() -> String:
		var id: String = _events._wheel_pick()
		world.net.send(1, "tower_spin", [id])
		return id
	world.menus.show_tower_wheel(pick, func(_id: String): pass, func(): _net_wheel = [], _net_wheel, _net_spun)





func _net_wheel_check() -> void :
	if _net_wheel.is_empty():
		return

	if state not in ["event", "sign"] or _net_spun >= _net_wheel.size():
		if world.menus.mode() != "tower_wheel":
			_net_wheel = []
		return
	if world.menus.mode() == "closed":
		_open_net_wheel()







func net_promote() -> void :
	if not mirror:
		return
	mirror = false
	world.tower_start = maxi(1, _from)
	var st: = tier_stage(floor)
	_mobs.clear()
	for sp in st.spawns:
		var d: Dictionary = GameData.MONSTERS.get(sp.mob, {})
		if not d.is_empty() and not d.get("static", false) and not d.has("boss") and not _mobs.has(sp.mob):
			_mobs.append(sp.mob)
	if _mobs.is_empty():
		_mobs = ["poring"]
	_kills_at = world.kills - _net_done
	_mvps_at = world.run_mvps
	_floor_t0 = world.time
	_spawn_t = 0.0
	_opening = 0
	match state:
		"fight", "rest":
			pass
		"climb":
			if _stairs == null or not is_instance_valid(_stairs):
				_open_stairs()
		"camp":
			if _lucile == null or not is_instance_valid(_lucile):
				_open_camp()
		_:
			_start_floor()
	print("TOWER promoted: floor %d (%s), %d / %d" % [floor, state, world.kills - _kills_at, need])


func net_event(ev: Array) -> void :
	match str(ev[0]):
		"cage":
			_events.mirror_cage(ev[1], float(ev[2]), ev[3] if ev.size() > 3 else Color(0.5, 0.8, 1.0))
		"wheel_open":

			var turns: = []
			for t in ev[1]:
				turns.append([int(t[0]), str(t[1]), int(t[0]) == world.net.my_slot])
			_net_wheel = turns
			_net_spun = 0
			_open_net_wheel()
		"wheel_spin":
			_net_spun = maxi(_net_spun, int(ev[1]) + 1)
			world.menus.tower_wheel_remote(int(ev[1]), str(ev[2]))
		"wheel":
			wheel_buffs = ev[1]
			wheel_curses = ev[2]
			_apply_mods()
		"state":
			floor = int(ev[1])
			if world.raid == null or not world.raid.in_arena():
				world.play_music_map(music_map())
			state = str(ev[2])
			need = int(ev[3])
			_net_done = int(ev[4])
			rule = str(ev[5])
			best = maxi(best, int(ev[6]))
			if ev.size() > 8:
				_sign_kind = str(ev[7])
				_events.net_take(ev[8])
		"map":
			var m: = str(ev[1])
			world.clear_battlefield()
			world._load_map(m)
			_stand(ev[2])
			world.play_music_map(music_map())
			Vfx.column(world.fx_root, world.player.position, Color(0.75, 0.6, 1.0))
			world.play_sound("teleport", 0.0, -2.0)
		"hop":
			_stand(ev[1])
			Vfx.column(world.fx_root, world.player.position, Color(0.75, 0.6, 1.0))
		"stairs":

			if _stairs != null and is_instance_valid(_stairs):
				_stairs.queue_free()
			floor = int(ev[2])
			_make_stairs(ev[1])
		"lucile":
			_clear_marks()
			_make_lucile(ev[1], ev[2])
			world.hud.alerts.warn(tr("Zona de descanso: habla con Lucile"), Color(0.6, 0.9, 1.0), "party_alarm")
		"up":
			_clear_marks()
			_camp_missed()
			world.play_sound("teleport", 0.0, -2.0)
		"floor":

			var cleared: = int(ev[1])
			best = maxi(best, cleared)
			var reward: = _floor_done(cleared)
			world.play_sound("job_levelup", 0.0, -6.0)
			if cleared % GameData.TOWER_TIER_FLOORS == 0:
				_camp_floor = cleared
				_camp_gift = reward
				_camp_talked = false
			elif reward != "":
				world.get_tree().create_timer(1.4, false).timeout.connect(_reward_shown.bind(reward))
		"bless":
			_bless_offer = ev[1]
			_show_blessing()
		"face":
			_found_face((ev[1] as Dictionary).duplicate(true), bool(ev[2]))
		"talk":

			if str(ev[1]) == "talk_hel":
				_show_talk("talk_hel")
			elif not Save.has_seen("tower", "naght_talk"):
				Save.mark_seen("tower", "naght_talk")
				_show_talk(str(ev[1]))
		"hel":
			if hel != null:
				hel.net_event(ev.slice(1))




func _floor_done(cleared: int) -> String:
	if hel != null:


		var hp: = world.player
		if cleared >= int(GameData.TITLES.doomed_hel.get("goal", 100)) and _from == 1 and hp != null and hp.doom and hp.pride and not hp.tampered:
			Save.mark_seen("titles", "doomed_hel")
		var prize: = Save.hel_cleared(world.player.class_id, cleared)
		world.hud.announce(tr("¡Piso %d superado!") % cleared, Color(0.8, 0.6, 1.0), tr("Torre de Hel"))
		if not prize.is_empty():
			world.get_tree().create_timer(1.4, false).timeout.connect(_hel_prize.bind(cleared, prize))
		return ""
	var reward: = Save.tower_cleared(world.player.class_id, cleared)
	_doom_title(cleared)
	world.hud.announce(tr("¡Piso %d superado!") % cleared, Color(1.0, 0.85, 0.4), 
		tr("Punto de control: piso %d") % (cleared + 1) if Save.tower_checkpoints().has(cleared + 1) else "")
	return reward




func _hel_prize(cleared: int, prize: Dictionary) -> void :
	if world.player == null or not world.running:
		return
	var bits: Array[String] = []
	if prize.has("crumbs"):
		bits.append(tr("%d Star Crumbs") % int(prize.crumbs))
	if prize.has("coins"):
		bits.append(tr("%d Poring Coins") % int(prize.coins))
	if prize.has("cosmetic"):
		bits.append(tr("Cosmético: %s") % tr(str(GameData.COSMETICS[str(prize.cosmetic)].name)))
	if prize.has("tears"):
		bits.append(tr("%d Lágrimas de Hel") % int(prize.tears) if int(prize.tears) > 1 else tr("1 Lágrima de Hel"))
	if prize.has("title"):
		bits.append(tr("Título: %s") % tr(str(GameData.TITLES[str(prize.title)].name)))
	world.hud.announce(tr("Premio del piso %d") % cleared, Color(0.75, 0.55, 1.0), "  ·  ".join(bits))
	world.play_sound("drop_yellow", 0.0, -4.0)
	var p: = world.player
	world.spawn_fx("angelus", p.position, 1.2, 0.9, p)
	world.number(p.position + Vector3(0, 2.6, 0), tr("Lucile: «¡Mira lo que nos dejó Niflheim!»"), Color(0.8, 0.7, 1.0), true)





func _doom_title(cleared: int) -> void :
	var p: = world.player
	if cleared >= GameData.DOOM_TOWER_FLOOR and _from == 1 and p != null and p.doom and p.pride and not p.tampered:
		Save.mark_seen("titles", "doomed")



func _stand(at: Vector3) -> void :
	world.player.position = Vector3(at.x, world.map.height_at(at), at.z)
	world.snap_camera()





func fast_ok() -> bool:
	return hel == null and not state in ["sign", "event", "boss"] and not (world.raid != null and world.raid.active())


func hud_state() -> String:
	match state:
		"sign":
			return tr("Piso %d  ·  %s") % [floor, tr(str(GameData.TOWER_EVENTS.get(_sign_kind, {}).get("name", "")))]
		"event":
			return tr("Piso %d  ·  %s") % [floor, _events.line()]
		"fight":
			var done: = _net_done if mirror else world.kills - _kills_at


			var line: = tr("Piso %d  ·  %d / %d") % [floor, mini(need, done), need]
			return line if rule == "" else "%s  ·  %s" % [line, tr(str(_rule().name))]
		"boss":
			return tr("Piso %d  ·  MVP") % floor
		"climb":
			return tr("Piso %d  ·  ¡al portal!") % floor
		"camp":
			return tr("Piso %d  ·  descanso") % (floor - 1)
	return tr("Piso %d  ·  subiendo...") % floor
