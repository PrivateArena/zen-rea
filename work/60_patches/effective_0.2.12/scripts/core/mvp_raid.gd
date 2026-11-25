class_name MvpRaid
extends Node3D












const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")
const SHOUT_COLOR: = Color(1.0, 0.95, 0.55)

const RAIN_FALL: = 0.2
const CHAT_COLOR: = Color(1, 1, 1)

var world: World

var state: = "idle"
var mvp: = ""

var _cast_bar: Label3D
var _cast_name: = ""
var data: = {}
var color: = Color.WHITE
var portal_pos: = Vector3.INF

var portal_sealed: = false
var center: = Vector3.ZERO
var radius: = 13.0
var boss: Enemy
var phase: = 0


var curses: = {}
var mark: = 0.0

var _portal: Node3D
var _seal_hint: = 0.0
var _return_portal: = false




var _exits_armed: = false

var _kportal: Node3D
var _kportal_pos: = Vector3.INF
var _kside: = ""
var _timers: = {}

var _cast: = {}

var _gap: = 0.0
var _intro: = 0.0


var _immune: = 0.0
var _field_map: RoMap
var _field_pos: = Vector3.ZERO
var _stash: Array[Dictionary] = []
var _arena_fx: Node3D

var _pillars: Array[Dictionary] = []
var _npc: RoVisual

var _objects: Array[Dictionary] = []
var _curse_tick: = 0.0
var _open_cache: = {}

var stats: = {"time": 0.0, "fails": 0, "phase": 0, "mvp": ""}


var ymir_at: = 0.0
var ymir: = 0.0


var ymir_gift: = 0.0


var gentle: = false
var _ymir_fx: = 0.0
var _calm_damage: = 0.0

var _fight_t: = 0.0


var epic: NaghtFight


var trials: RefCounted


var _alone_wait: = 0.0

const QUIET_KINDS: = ["puddle", "holy"]



const MOVING_MECHS: = ["charge", "spokes", "sweep", "clock"]


func _ready() -> void :
	name = "MvpRaid"
	trials = load("res://scripts/core/raid_trials.gd").new(self)




func calm() -> bool:
	return _objects.any( func(o): return o.get("calm", false))


func supports(mob: String) -> bool:
	return GameData.RAIDS.has(mob) and RoAssets.map_exists(str(GameData.RAIDS[mob].arena))


func active() -> bool:
	return state != "idle"



func freezes_time() -> bool:
	return state != "idle"


func in_arena() -> bool:
	return state in ["intro", "fight", "won"]



func hud_state() -> String:
	match state:
		"portal":
			return tr("El portal sigue sellado...") if portal_sealed else tr("¡Portal del MVP abierto!")
		"intro", "fight":
			return tr("MVP: %s") % tr(GameData.MONSTERS[mvp].name)
		"won":
			return tr("MVP derrotado")
	return ""





func open_portal(mob: String) -> void :
	world.karma.won_here = false
	mvp = mob
	data = GameData.RAIDS[mob]
	color = data.color
	state = "portal"
	for e in world.enemies.duplicate():
		if not e.is_boss and not e.def.get("elite", false):
			world.banish_enemy(e)


		elif e.has_meta("mvp_shadow"):
			world.hell_late._shadows.erase(e)
			world.banish_enemy(e)


	for p in world.pickups:
		if p.kind in ["xp", "loot", "ore", "card"]:
			p.pull = true
	portal_pos = _portal_point(world.player.position)
	_spawn_portal(portal_pos, tr("Portal: %s") % tr(GameData.MONSTERS[mob].name))
	_mvp_alert(tr(GameData.MONSTERS[mob].name), arena_title(), color)
	world.play_sound("warning", 0.0, 2.0)
	world.play_sound("portal_open", 0.0, 0.0)
	world.play_mob_sound(mob, "attack")
	world.shake(0.5)
	world.emote(world.player, "omg", 2.5)


	for p in world.heroes:
		if p.downed:
			continue
		p.add_power("sleipnir_gallop", 600.0)
		world.rising_tex(p, "agi_up", 2)
		world.spawn_fx("joblvup", p.position, 1.0, 0.8, p)
	world.play_sound("increase_agi", 0.0, 0.0)

	world.get_tree().create_timer(0.6, false).timeout.connect( func():
		if state == "portal":
			world.number(world.player.position + Vector3(0, 2.4, 0), tr("¡Galope de Sleipnir!"), 
				GameData.LEGEND_POWERS.sleipnir_gallop.color, true))


func _spawn_portal(at: Vector3, caption: String) -> void :
	_clear_portal()
	portal_pos = at
	_portal = Node3D.new()
	world.fx_root.add_child(_portal)
	_portal.global_position = Vector3(at.x, world.map.height_at(at), at.z)

	Vfx.warp_portal(_portal, color, 1.3)
	Vfx.beam(_portal, Vector3.ZERO, color, 9.0)
	Vfx.beam(_portal, Vector3.ZERO, color.lightened(0.5), 3.0)
	var glow: = Vfx.ground_glow(_portal, Vector3.ZERO, 2.4, Color(color, 0.6))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.25, 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.6, 0.6).set_trans(Tween.TRANS_SINE)
	_label(_portal, caption, Color(1, 0.9, 1), 2.6, 34)
	Vfx.burst(world.fx_root, _portal.global_position, 3.0, color)
	world.net.raid_portal(at, caption, color)



func unseal_portal() -> void :
	portal_sealed = false
	if state != "portal":
		return
	Vfx.burst(world.fx_root, portal_pos, 3.0, color)
	world.play_sound("portal_open", 0.0, 0.0)
	world.hud.alerts.warn(tr("¡El portal está abierto!"), color, "party_alarm")


func _clear_portal() -> void :
	if _portal != null and is_instance_valid(_portal):
		_portal.queue_free()
		world.net.raid_portal(Vector3.INF, "", color)
	_portal = null
	portal_pos = Vector3.INF



func _hero_at_portal() -> bool:
	for h in world.heroes:
		if not h.downed and _flat(h.position, portal_pos) < 1.2:
			return true
	return false



var _party_pos: = {}


func _enter() -> void :
	state = "loading"

	for h in world.heroes:
		if h.powers.has("sleipnir_gallop"):
			h.powers.erase("sleipnir_gallop")
			h.recompute()
			h._power_look()
	_clear_portal()
	world.play_sound("portal", 0.0, 0.0)
	world.get_tree().paused = true
	world.menus.show_loading(_build_arena, [str(data.arena)])




func _build_arena() -> void :

	_stash.clear()
	for p in world.pickups:
		p.node.visible = false
		_stash.append(p)
	world.pickups.clear()
	world.altars.set_shown(false)
	world.clear_battlefield()
	_field_pos = world.player.position
	_party_pos.clear()
	for h in world.heroes:
		_party_pos[h] = h.position
	_field_map = world.map
	world.remove_child(_field_map)
	var m: = RoMap.new()
	world.add_child(m)
	world.move_child(m, 1)
	m.load_map(data.arena)
	world.map = m
	var open: = _find_open(m, float(data.radius))
	center = open[0]
	radius = open[1]
	if not (str(data.arena) in GameData.ARENA_KEEP_PROPS):
		m.clear_props(center, radius + GameData.ARENA_CLEAR_MARGIN, GameData.ARENA_CLEAR_FRONT)

	m.flatten(center, radius + GameData.ARENA_FLAT_MARGIN, GameData.ARENA_FLAT_BLEND)
	center.y = m.height_at(center)
	var start: = center + Vector3(0, 0, radius * 0.6)
	world.player.position = Vector3(start.x, m.height_at(start), start.z)
	world.player.slip = 0.0

	for h in world.heroes:
		if h != world.player:
			var at: = start + Vector3((h.slot - (world.heroes.size() - 1) * 0.5) * 1.6, 0, 0.6)
			at = m.random_point_around(at, 0.4) if not m.is_walkable(at) else at
			h.position = Vector3(at.x, m.height_at(at), at.z)
			h.slip = 0.0
	if world.pet != null:
		world.pet.position = world.player.position + Vector3(1, 0, 0.5)
	world.snap_camera()
	world.net.raid_map(str(data.arena), center, radius)
	_net(["arena", mvp])
	_build_arena_fx()
	_spawn_pillars()
	_spawn_npc()
	world.play_music_map(data.arena)
	state = "intro"
	_intro = 3.4
	_big(arena_title(), tr("%s se acerca... ¡prepárate!") % tr(GameData.MONSTERS[mvp].name), color)
	world.get_tree().paused = false
	world.menus.close()



func _build_arena_fx() -> void :
	_arena_fx = Node3D.new()
	world.fx_root.add_child(_arena_fx)
	_arena_fx.global_position = center
	var ring: = Vfx._flat(_arena_fx, Vfx.ring_texture(), Vector3.ZERO, radius + 0.6, Color(color, 0.4))
	var tw: = ring.create_tween().set_loops()
	tw.tween_property(ring, "modulate:a", 0.22, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(ring, "modulate:a", 0.4, 1.2).set_trans(Tween.TRANS_SINE)
	for i in 20:
		var a: = TAU * i / 20.0
		var p: = Vector3(cos(a), 0, sin(a)) * (radius + 0.3)
		p.y = world.map.height_at(center + p) - center.y
		Vfx.beam(_arena_fx, p, color, 2.6)


func _spawn_pillars() -> void :
	var pd: Dictionary = data.get("pillars", {})
	for i in int(pd.get("count", 0)):
		var a: = TAU * (i + 0.5) / float(pd.count) + randf_range(-0.2, 0.2)
		_add_pillar(center + Vector3(cos(a), 0, sin(a)) * radius * 0.55)


func _add_pillar(at: Vector3) -> void :
	var pd: Dictionary = data.get("pillars", {})
	var v: = RoVisual.new()
	world.fx_root.add_child(v)
	v.setup(RoAssets.sprite([str(pd.get("sprite", "barricade"))]), Color(0.5, 0.5, 0.55), 64, 1.6)
	v.play(0, true)
	v.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	v.scale = Vector3.ONE * 0.2
	v.create_tween().tween_property(v, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pillars.append({"node": v, "pos": v.global_position, "hits": 0})
	_reg(v, ["pillar", at])


func _spawn_npc() -> void :
	var nd: Dictionary = data.get("npc", {})
	if nd.is_empty() or nd.sprite == "npc_kafra":
		return
	_npc = RoVisual.new()
	world.fx_root.add_child(_npc)
	_npc.setup(RoAssets.sprite([nd.sprite]), Color(0.9, 0.9, 1), 48, 1.0)
	_npc.play(0, true)
	_in_front(_npc)
	var at: = center + Vector3( - radius * 0.5, 0, radius * 0.3)
	_npc.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	_reg(_npc, ["npc"])

	_make_label(_npc, tr(str(nd.name)), Color(0.75, 0.9, 1.0), -0.25, 26, false)



func _npc_to(at: Vector3) -> void :
	if _npc == null:
		return
	_net(["npc_to", at])
	Vfx.column(world.fx_root, _npc.global_position, Color(0.8, 0.9, 1))
	_npc.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	Vfx.column(world.fx_root, _npc.global_position, Color(0.8, 0.9, 1))
	world.play_sound("teleport", 0.2, -8.0)




func _find_open(m: RoMap, want: float) -> Array:

	var fv = data.get("flat", false)
	var flat: bool = fv is float or bool(fv)
	var step_h: float = float(fv) if fv is float else GameData.RAID_FLAT_STEP
	var cache_key: = m.map_name + ("@flat%.1f" % step_h if flat else "")
	if _open_cache.has(cache_key):
		return _open_cache[cache_key]
	var cands: Array[Vector3] = []
	var hw: = m.width * 0.5 - 4.0
	var hh: = m.height * 0.5 - 4.0

	var step: = 2.0 if flat else 4.0
	var x: = - hw
	while x <= hw:
		var z: = - hh
		while z <= hh:
			cands.append(Vector3(x, 0, z))
			z += step
		x += step
	cands.sort_custom( func(a, b): return a.length_squared() < b.length_squared())
	var best: = Vector3.ZERO
	var best_r: = -1.0
	for c in cands:
		if not m.is_walkable(c):
			continue
		var r: = _open_radius(m, c, want, flat, step_h)
		if r > best_r:
			best_r = r
			best = c
			if r >= want:
				break
	var out: = [best, clampf(best_r, 6.0, want)]
	_open_cache[cache_key] = out
	return out




func _open_radius(m: RoMap, c: Vector3, want: float, flat: = false, step_h: = GameData.RAID_FLAT_STEP) -> float:
	var r: = 2.0
	var h0: = m.height_at(c)
	while r <= want + 0.01:
		for i in 20:
			var a: = TAU * i / 20.0
			var p: = c + Vector3(cos(a), 0, sin(a)) * r
			if not m.is_walkable(p) or (flat and absf(m.height_at(p) - h0) > step_h):
				return r - 2.0
		r += 2.0
	return want




func tick(delta: float) -> void :

	world.fx_layer(GameData.MVP_FX_PRIORITY)
	_tick_state(delta)
	world.fx_layer(0)


func _tick_state(delta: float) -> void :
	match state:
		"portal":
			_seal_hint -= delta
			if _hero_at_portal():
				if not portal_sealed:
					_enter()
				elif _seal_hint <= 0.0:
					_seal_hint = 2.5
					world.number(world.player.position + Vector3(0, 2.4, 0), tr("El portal sigue sellado..."), color, true)
		"intro":
			_clamp_all()
			_intro -= delta
			if _intro <= 0.0:
				_spawn_boss()
		"fight":
			_fight(delta)
		"won":
			_clamp_all()
			_rescue_t -= delta
			if _rescue_t <= 0.0:
				_rescue_t = 0.5
				_rescue_stranded()
			if not _exits_armed:
				_exits_armed = _return_portal and not (portal_pos != Vector3.INF and _hero_at_portal())\
				and not (_kportal_pos != Vector3.INF and _hero_near(_kportal_pos))
			elif _return_portal and portal_pos != Vector3.INF and _hero_at_portal():
				_take_exit()
			elif _kportal_pos != Vector3.INF and _hero_near(_kportal_pos):
				_clear_kportal()
				world.karma.enter_route()


func _spawn_boss() -> void :

	var at: = center - Vector3(0, 0, radius * 0.2)
	boss = world.spawn_enemy(mvp, at, true)
	if boss == null:
		state = "idle"
		return
	boss.brain = null




	var foe_hp: = 1.0 + world.altars.mod("enemy_hp")
	var altar_hp: = minf(foe_hp * (1.0 + world.altars.mod("mvp_hp")), 1.0 + GameData.ALTAR_MVP_HP_MAX) / foe_hp
	boss.max_hp *= GameData.RAID_HP_BASE * GameData.MVP_RAID_HP * altar_hp * float(data.get("boss_hp", 1.0))



	var dps: = world.tank_dps(world.party_dealt() / maxf(30.0, world.measure_time())) * 1.3
	boss.max_hp = maxf(boss.max_hp, dps * GameData.RAID_TANK * float(data.get("boss_hp", 1.0)))

	boss.max_hp *= GameData.oath_value("tough", world.oath("tough"))


	boss.max_hp *= world.kafra_walk.boss_hp_cut(mvp)
	ymir_gift = world.kafra_walk.take_ymir()
	boss.hp = boss.max_hp
	boss.damage *= GameData.MVP_RAID_DMG * float(data.get("boss_dmg", 1.0))

	gentle = world.gentle_map() and not world.endless and world.tower == null
	if gentle:
		boss.max_hp *= GameData.RAID_GENTLE_HP
		boss.hp = boss.max_hp
		boss.damage *= GameData.RAID_GENTLE_BOSS_DMG
	_calm_damage = boss.damage
	_vuln = 0.0
	_guarded = false
	_aura_t = 0.0

	if data.has("aura"):
		var au: Dictionary = data.aura
		Vfx.magic_circle(boss, Vector3.ZERO, 2.4, Color(Color(au.color), 0.35), 0.0, "mvp_hexa", 0.7, GameData.MVP_UNDER_PRIORITY, true)
		Vfx.magic_circle(boss, Vector3.ZERO, 1.5, Color(Color(au.color).lightened(0.3), 0.3), 0.0, "mvp_rune", -1.1, GameData.MVP_UNDER_PRIORITY, true)
	if data.get("epic", false):
		epic = NaghtFight.new(self)
		epic.begin()
	ymir = 0.0
	_fight_t = 0.0
	ymir_at = GameData.RAID_YMIR_TIME
	if world.endless:
		ymir_at = maxf(GameData.RAID_YMIR_MIN, ymir_at - GameData.RAID_YMIR_ENDLESS_STEP * maxi(0, world.run_ymir - 1))


	if world.pride_on():
		var keep: = world.pride_resist(boss.max_hp)
		if keep < 1.0:
			boss.set_meta("pride", keep)
		ymir_at = minf(ymir_at, GameData.PRIDE_YMIR)
	world.boss = boss
	Vfx.burst(world.fx_root, boss.position, 4.0, color)
	Vfx.column(world.fx_root, boss.position, color)
	world.play_sound("teleport", 0.0, 0.0)
	world.play_mob_sound(mvp, "attack")
	world.shake(0.6)
	_chat(boss, tr(str(data.intro)))
	_announce(tr("MVP: %s") % tr(GameData.MONSTERS[mvp].name), color.lightened(0.3))
	_net(["fight", mvp])
	phase = 0
	_timers.clear()
	for ab in data.abilities:
		if ab.phases.has(0):
			_timers[ab.id] = float(ab.first)
	state = "fight"

	if world.world_boss != null and is_instance_valid(world.world_boss):
		world.world_boss.on_boss(boss)


func _fight(delta: float) -> void :
	if boss == null or not is_instance_valid(boss) or boss.dead:
		return
	var before: = int(stats.time / 30.0)
	stats.time += delta
	if world.autopilot and int(stats.time / 30.0) > before:
		var party: = []
		for h in world.heroes.slice(1):
			party.append("%s %d/%d%s" % [h.class_id, h.hp, h.max_hp, " DOWN" if h.downed else ""])
		print("  raid %ds boss=%d%% phase=%d hp=%d/%d fails=%d %s" % [int(stats.time), roundi(100.0 * boss.hp / boss.max_hp), 
			phase + 1, world.player.hp, world.player.max_hp, stats.fails, party])


	if epic != null and epic.tick(delta):
		_clamp_all()
		_update_objects(delta)
		_update_debuffs(delta)
		return
	_vuln = maxf(0.0, _vuln - delta)
	_tick_aura(delta)
	if _immune > 0.0:
		_immune -= delta
		_clamp_all()
		_update_objects(delta)
		_update_debuffs(delta)
		return
	stats.phase = phase
	stats.mvp = mvp


	_tick_ymir(delta)
	_sync_t -= delta
	if _sync_t <= 0.0:
		_sync_t = 0.25
		_net(["dbm", dbm_entries(), _fight_t, ymir_at, ymir, phase])


	if boss.status == "stun":
		_clamp_all()
		_update_objects(delta)
		_update_debuffs(delta)
		return
	_clamp_all()
	var phases: Array = data.phases
	while phase + 1 < phases.size() and boss.hp / boss.max_hp <= float(phases[phase + 1]):
		_enter_phase(phase + 1)
	if not _cast.is_empty():
		_cast.t -= delta
		_update_cast_bar()

		if str(_cast.ab.mech) == "rain" and _cast.t <= RAIN_FALL and not _cast.has("fell"):
			_cast["fell"] = true
			for t in _cast.targets:
				Vfx.fall(world.fx_root, t, float(_cast.ab.size), _strike_color(_cast.ab), maxf(0.05, _cast.t))
		if _cast.t <= 0.0:
			var c: = _cast
			_cast = {}
			_resolve(c)
			_update_cast_bar()
			_gap = GameData.RAID_CAST_GAP
	else:
		_gap -= delta



		var anchored: = _objects.any( func(o): return str(o.get("kind", "")) in GameData.RAID_ANCHOR_KINDS)
		var ready: Dictionary = {}



		var held: = calm()
		for ab in data.abilities:
			if not ab.phases.has(phase):
				continue
			_timers[ab.id] = float(_timers.get(ab.id, ab.first)) - (0.0 if held else delta * ymir_cast())
			if anchored and str(ab.mech) in GameData.RAID_ANCHOR_MECHS:
				continue
			if str(ab.mech) in MOVING_MECHS and trials.pins_boss():
				continue
			if _timers[ab.id] <= 0.0 and (ready.is_empty() or _timers[ab.id] < _timers[ready.id]):
				ready = ab





		if not ready.is_empty() and ready.get("alone", false) and not _objects.all( func(o): return str(o.get("kind", "")) in QUIET_KINDS):
			_alone_wait += delta
			if _alone_wait > 14.0:
				_alone_wait = 0.0
				_timers[ready.id] = 10.0
			ready = {}
		else:
			_alone_wait = 0.0
		if not ready.is_empty() and _gap <= 0.0 and not _objects.any( func(o): return o.get("solo", false)):
			_timers[ready.id] = float(ready.every) * (0.8 if phase == phases.size() - 1 else 1.0)\
			* (float(GameData.HARD.raid_every) if world.hard else 1.0) * world.mvp_cast()
			_start(ready)
			_gap = GameData.RAID_CAST_GAP
	_update_objects(delta)
	_update_debuffs(delta)


func _enter_phase(n: int) -> void :
	phase = n



	_clear_cast()
	Vfx.column(world.fx_root, boss.position, color)
	var mid: = center + Vector3(0, 0, -1.0)
	boss.position = Vector3(mid.x, world.map.height_at(mid), mid.z)
	boss.hold = 2.4
	_immune = 2.4
	Vfx.ring(world.fx_root, boss.position, radius, color, 1.2)

	var under: = GameData.MVP_UNDER_PRIORITY
	Vfx.magic_circle(world.fx_root, boss.position, 5.0, Color(color.lightened(0.2), 0.7), _immune, "mvp_rune", 1.2, under, true)
	Vfx.magic_circle(world.fx_root, boss.position, 2.8, Color(color.lightened(0.5), 0.6), _immune, "mvp_hexa", -2.0, under, true)
	world.spawn_fx("hell_in", boss.position, 1.6)

	for h in world.heroes:
		h.position += _dir(boss.position, h.position) * 2.0
	var shouts: Array = data.get("phase_shouts", [])
	if n < shouts.size() and str(shouts[n]) != "":
		_chat(boss, tr(str(shouts[n])))

	_big(tr("Fase %d") % (n + 1), _phase_news(n), color)
	world.play_sound("warning", 0.0, -2.0)
	world.play_mob_sound(mvp, "attack")
	Vfx.burst(world.fx_root, boss.position, 5.0, color)
	world.shake(0.5)
	for ab in data.abilities:
		if ab.phases.has(n) and not ab.phases.has(n - 1):
			_timers[ab.id] = float(ab.first) * 0.6
	if n == data.phases.size() - 1:

		_calm_damage *= GameData.RAID_ENRAGE_DMG
		boss.damage *= GameData.RAID_ENRAGE_DMG
	if epic != null:
		epic.on_phase(n)



func _phase_news(n: int) -> String:
	var names: Array[String] = []
	for ab in data.abilities:
		if ab.phases.has(n) and not ab.phases.has(n - 1):
			names.append(tr(str(ab.name)))
	if names.is_empty():
		if n != data.phases.size() - 1:
			return ""
		return tr("%s se enfurece: pega más fuerte") % tr(str(GameData.MONSTERS[mvp].name))
	return tr("Nuevo: %s") % "  ·  ".join(names)




func _start(ab: Dictionary) -> void :

	var p: = _target()
	var lethal: bool = ab.get("lethal", false)
	if ab.has("alert"):
		_tip(tr(str(ab.alert)), Color(1, 0.35, 0.3) if lethal else Color(1, 0.85, 0.4), 
			"warning" if lethal else "party_alarm")
	if ab.mech != "summon":
		_shout(boss, tr("%s!!") % tr(str(ab.name)))

	var cast: = float(ab.get("cast", 0.0)) * (GameData.RAID_GENTLE_CAST if gentle else 1.0) * (GameData.WB_CAST_TIME if world.world_boss != null else 1.0)


	var big: bool = lethal or ab.mech in ["shield", "los", "rain", "slam", "spokes", "sweep", "volley", "puddles"]
	if big and cast >= 0.8:
		_begin_cast_tell(ab, cast)
	if _start_extra(ab, p, cast):
		return
	match ab.mech:
		"cone":
			var dir: = _dir(boss.position, p.position)
			var tell: = Vfx.telegraph_cone(world.fx_root, boss.position, dir, float(ab.radius), float(ab.angle), cast)
			boss.hold = cast + 0.2


			_cast = {"ab": ab, "t": cast, "total": cast, "dir": dir, "tells": [tell], "from": boss.position}
		"charge":
			var dir: = _dir(boss.position, p.position)
			var tell: = Vfx.telegraph_line(world.fx_root, boss.position, dir, radius * 1.4, 2.0, cast)
			boss.hold = cast + 0.9
			_cast = {"ab": ab, "t": cast, "total": cast, "dir": dir, "tells": [tell], "from": boss.position}
		"slam", "rain":
			var targets: Array[Vector3] = []
			var tells: Array = []

			var party: = _standing()
			for i in int(ab.count):
				var at: = (party[i] as Player).position if i < party.size() else (
					world.map.random_point_around(p.position, 3.5) if ab.mech == "slam" else _arena_point(1.0))
				targets.append(at)
				tells.append(Vfx.telegraph_circle(world.fx_root, at, float(ab.size), cast))
			boss.hold = cast + 0.3 if cast >= 0.8 else 0.6
			_cast = {"ab": ab, "t": cast, "total": cast, "targets": targets, "tells": tells}
		"summon":
			_chat(boss, tr("%s!") % tr(str(ab.name)))
			var mobs = ab.mob
			Vfx.ring(world.fx_root, boss.position, 4.0, color, 0.6)
			for i in int(ab.count):
				var a: = TAU * i / float(ab.count)
				var mob: String = mobs.pick_random() if mobs is Array else str(mobs)
				var at: = boss.position + Vector3(cos(a), 0, sin(a)) * 3.0

				Vfx.magic_circle(world.fx_root, at, 0.9, Color(color.lightened(0.3), 0.85), 1.1, "mvp_hexa", 2.5)
				Vfx.column(world.fx_root, at, color)
				var e: = world.spawn_enemy(mob, at, true)
				if e != null:
					e.summoned = true
		"los":
			boss.hold = cast + 0.3
			var shadows: Array = []
			for pl in _pillars:
				shadows.append(_cover_shadow(pl.pos, pl.pos - boss.position))
			Vfx.ring(world.fx_root, boss.position, 3.0, color, cast)
			_cast = {"ab": ab, "t": cast, "total": cast, "shadows": shadows}
		"shield":
			var at: = _arena_point(0.55, boss.position, 5.0)
			_npc_to(at + Vector3(0.8, 0, 0))
			if _npc != null:
				_chat(_npc, tr(str(ab.get("npc_line", ""))), Color(0.75, 0.9, 1.0))
			var zone: = _zone(at, GameData.RAID_SHIELD_RADIUS, Color(0.5, 0.8, 1.0), str(ab.get("shield_fx", "")))
			boss.hold = cast + 0.3
			_cast = {"ab": ab, "t": cast, "total": cast, "zone": zone, "at": at}
		"cleanse":
			_curse_tick = 1.0


			for h in _standing():
				curses[h] = maxf(float(curses.get(h, 0.0)), 1.0)
				_tint(h, true)
				world.emote(h, "sweat", 1.5)
			var at: = _arena_point(0.7, p.position, 5.0)
			if _npc != null:
				_npc_to(at + Vector3(0.8, 0, 0))
				_chat(_npc, tr(str(ab.get("npc_line", ""))), Color(0.75, 0.9, 1.0))
			var zone: = _zone(at, GameData.RAID_ZONE_RADIUS, Color(0.5, 1.0, 0.6), str(ab.get("zone_fx", "")))
			_objects.append({"kind": "holy", "node": zone, "pos": at, "t": 16.0, "in": {}, "ab": ab})
		"mark":
			mark = float(ab.duration)
			for h in _standing():
				world.spawn_fx(str(ab.get("fx", "")), h.position, 0.9, 1.0, h)
			world.play_sound("stone_curse", 0.0, -4.0)
			for i in int(ab.count):
				var at: = _arena_point(0.85, p.position, 4.0)
				var node: = _zone(at, 1.0, Color(0.7, 0.85, 1.0), str(ab.get("bubble_fx", "")), 1.4)
				_objects.append({"kind": "bubble", "node": node, "pos": at, "ab": ab})
		"bombs", "eggs":
			var mob: = str(ab.mob if ab.mech == "bombs" else ab.egg)
			for i in int(ab.count):
				var at: = _arena_point(0.75, boss.position, 4.0)
				var e: = world.spawn_enemy(mob, at, true)
				if e == null:
					continue
				e.max_hp = boss.max_hp * float(ab.hp)
				e.hp = e.max_hp
				e.summoned = true
				Vfx.column(world.fx_root, e.position, color)
				if ab.has("chant") and i == 0:
					_chat(e, tr(str(ab.chant)), Color(0.7, 1.0, 0.6))
				if ab.has("chant"):

					world.spawn_fx("lightning", e.position, 0.6, 0.5)
				var lbl: = _label(e, "", Color(1, 0.6, 0.4), 1.6, 40)
				_objects.append({"kind": ab.mech, "enemy": e, "t": float(ab.time), "label": lbl, "ab": ab})
		"orb":
			var start: = boss.position + _dir(boss.position, p.position) * 3.0
			var node: = _make_orb(start)
			_reg(node, ["orb", start])
			var line: = _hint_line()

			var lbl: = _label(node, tr("¡Aparece aquí!  Luego te persigue"), Color(1.0, 0.85, 0.5), 1.1, 30)

			Vfx.ring(world.fx_root, start, 2.2, color, GameData.RAID_ORB_WAKE)
			Vfx.ring(world.fx_root, start, 1.2, Color(1, 1, 1), GameData.RAID_ORB_WAKE * 0.6)
			world.play_sound("warning", 0.2, -4.0)
			_objects.append({"kind": "orb", "node": node, "t": float(ab.duration) + GameData.RAID_ORB_WAKE, "armed": 1.0 + GameData.RAID_ORB_WAKE, 
				"wake": GameData.RAID_ORB_WAKE, "line": line, "ab": ab, "label": lbl, "target": p})
		"kafra":
			var at: = _arena_point(0.5, boss.position, 5.0)
			var k: = _make_sprite("npc_kafra", Color(1, 0.8, 0.8), 48, 1.0, at)
			_reg(k, ["sprite", "npc_kafra", Color(1, 0.8, 0.8), 48, 1.0, at])
			Vfx.column(world.fx_root, k.global_position, Color(1, 0.8, 0.9))
			_chat(k, tr(str(ab.get("npc_line", ""))), Color(1, 0.85, 0.9))
			var lbl: = _label(k, "", Color(1, 1, 1), 2.6, 30)
			var obj: = {"kind": "kafra", "node": k, "t": float(ab.duration), "total": float(ab.duration), 
				"hp": int(ab.hits), "max": int(ab.hits), "label": lbl, "ab": ab, "adds": []}
			var mobs = ab.mob
			for i in int(ab.count):
				var a: = TAU * i / float(ab.count)
				var mob: String = mobs.pick_random() if mobs is Array else str(mobs)
				var e: = world.spawn_enemy(mob, center + Vector3(cos(a), 0, sin(a)) * (radius - 1.0), true)
				if e != null:
					e.summoned = true
					e.target = k
					obj.adds.append(e)
			_objects.append(obj)
		"platforms":
			var pads: Array = []
			for i in int(ab.count):
				var at: = _arena_point(0.6, Vector3.INF, 0.0, i, int(ab.count))
				var v: = _make_sprite("rock_pillar", Color(0.5, 0.45, 0.4), 40, 0.0, at)
				_reg(v, ["sprite", "rock_pillar", Color(0.5, 0.45, 0.4), 40, 0.0, at])
				var ring: = _zone(at, GameData.RAID_PLATFORM_RADIUS, Color(0.6, 1.0, 0.7), "")
				pads.append({"pos": at, "node": v, "ring": ring})
			var danger: = _danger_floor(cast)
			_reg(danger, ["floor", cast])
			_cast = {"ab": ab, "t": cast, "total": cast, "pads": pads, "danger": danger}
		"ice":
			for i in int(ab.count):
				var at: = p.position if i == 0 else _arena_point(0.7)
				var node: = _zone(at, float(ab.size), Color(0.75, 0.9, 1.0), str(ab.get("fx", "")), 1.0, true)
				_objects.append({"kind": "ice", "node": node, "pos": at, "r": float(ab.size), "t": float(ab.duration)})



var _now_name: = ""
func _resolve(c: Dictionary) -> void :
	var ab: Dictionary = c.ab
	_now_name = str(ab.get("name", ""))

	_drop_tells(c.get("tells", []))
	if _resolve_extra(c):
		return
	var party: = _standing()
	match ab.mech:
		"cone":
			var from: Vector3 = c.get("from", boss.position)
			Vfx.strike_cone(world.fx_root, from, c.dir, float(ab.radius), float(ab.angle), _strike_color(ab))
			world.spawn_fx(str(ab.get("fx", "")), from + (c.dir as Vector3) * float(ab.radius) * 0.45, 1.6)
			for k in 3:
				var side: = (c.dir as Vector3).rotated(Vector3.UP, (k - 1) * float(ab.angle) * 0.3)
				world.spawn_fx(str(ab.get("fx", "")), from + side * float(ab.radius) * 0.8, 1.0, 0.8)
			world.play_mob_sound(mvp, "attack")
			for h in party:
				var to: = (h.position - from) * Vector3(1, 0, 1)
				if to.length() < float(ab.radius) and absf((c.dir as Vector3).signed_angle_to(to.normalized(), Vector3.UP)) < float(ab.angle) * 0.5:
					_hit_dmg(float(ab.dmg), h)
			world.shake(0.3)
		"charge":


			if c.has("from"):
				boss.position = c.from
			Vfx.strike_line(world.fx_root, boss.position, c.dir, 17.0 * 0.85 + 1.0, 2.0, _strike_color(ab))
			world.spawn_fx("shockwave", boss.position, 1.0, 0.8)


			_objects.append({"kind": "dash", "solo": true, "t": 0.85, "dir": c.dir, "hit": [], "ab": ab})
		"slam", "rain":
			for t in c.targets:
				Vfx.strike_circle(world.fx_root, t, float(ab.size), _strike_color(ab))
				world.spawn_fx(str(ab.get("fx", "")), t, 1.4, 0.8)
				for h in party:
					if _flat(h.position, t) < float(ab.size):
						_hit_dmg(float(ab.dmg), h)
			world.play_sound("meteor" if ab.mech == "rain" else "bash", 0.2, -4.0)
			world.shake(0.35)
		"los":
			for s in c.shadows:
				if is_instance_valid(s):
					s.queue_free()
			world.spawn_fx(str(ab.get("fx", "")), boss.position, 2.0)
			Vfx.burst(world.fx_root, boss.position, radius, color)
			world.play_mob_sound(mvp, "attack")
			world.play_sound("meteor", 0.0, -2.0)
			world.shake(0.8)

			var used: = {}
			for h in party:
				var covered: = false
				for i in _pillars.size():
					if _blocks(_pillars[i].pos, boss.position, h.position):
						covered = true
						used[i] = true
				if covered:
					world.number(h.position + Vector3(0, 1.6, 0), tr("¡Cubierto!"), Color(0.6, 1, 0.7))
				else:
					_hit_pct(float(ab.pct), h)
			for i in used:
				_pillars[i].hits += 1
			_crumble_pillars()
		"shield":
			var zone: Node3D = c.zone


			for i in 3:
				var at: = center + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * radius * 0.7
				if _flat(at, c.at) > GameData.RAID_SHIELD_RADIUS + 2.0:
					world.spawn_fx(str(ab.get("fx", "")), at, 0.6, 0.6)
			world.play_sound("meteor", 0.0, 0.0)
			world.shake(0.6)
			for h in party:
				if _flat(h.position, c.at) > GameData.RAID_SHIELD_RADIUS:
					world.spawn_fx(str(ab.get("fx", "")), h.position, 0.4, 0.55)
					Vfx.strike_circle(world.fx_root, h.position, 2.2, _strike_color(ab))
					_hit_pct(float(ab.pct), h)
				else:

					Vfx.strike_circle(world.fx_root, c.at, GameData.RAID_SHIELD_RADIUS, Color(0.6, 0.85, 1.0))
					world.number(h.position + Vector3(0, 1.6, 0), tr("¡Protegido!"), Color(0.6, 0.9, 1))
			_fade(zone, 0.6)
		"platforms":
			_objects.append({"kind": "hazard", "t": float(ab.duration), "tick": 0.0, "pads": c.pads, 
				"danger": c.danger, "ab": ab})




func _tick_ymir(delta: float) -> void :
	_fight_t += delta
	if _fight_t < ymir_at:
		return
	if ymir <= 0.0:
		_net(["ymir"])
		_announce(tr("¡El Corazón de Ymir despierta!"), Color(0.75, 0.45, 1.0), 
			tr("Tú y %s pegan cada vez más fuerte, pero tú creces más rápido: ¡termínalo!") % tr(GameData.MONSTERS[mvp].name))
		world.play_mob_sound(mvp, "attack")
		world.play_sound("warning", 0.0, 0.0)
		world.shake(0.8)
		Vfx.ring(world.fx_root, center + Vector3(0, 0.1, 0), radius, Color(0.6, 0.25, 1.0), 1.4)
		world.spawn_fx("hell_in", boss.position, 1.6)
		world.spawn_fx("joblvup", world.player.position, 1.0, 0.8, world.player)
		if _arena_fx != null and is_instance_valid(_arena_fx):
			Vfx.magic_circle(_arena_fx, Vector3.ZERO, radius * 0.95, Color(0.6, 0.25, 1.0, 0.12), 0.0, "mvp_rune", 0.12)
		_ymir_glow()

	ymir += delta * GameData.ymir_rate(_fight_t - ymir_at)
	boss.damage = _calm_damage * ymir_mvp_mult()

	_ymir_fx -= delta
	if _ymir_fx <= 0.0:
		_ymir_fx = maxf(0.4, 1.4 - ymir * 0.01)
		world.spawn_fx("hell_in", _arena_point(0.9), 0.8, 0.5)



func _ymir_glow() -> void :
	var glow: = Vfx.ground_glow(boss, Vector3(0, 0.05, 0), boss.radius * 3.2, Color(0.6, 0.15, 1.0, 0.7))
	glow.render_priority = GameData.MVP_UNDER_PRIORITY
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.3, 0.35).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.9, 0.35).set_trans(Tween.TRANS_SINE)





func tower_mech() -> float:
	return GameData.tower_mech_mult(int(world.tower.floor)) if world.tower != null else 1.0


func ymir_mvp_mult() -> float:
	return 1.0 + GameData.RAID_YMIR_MVP_DMG * ymir



func ymir_cast() -> float:
	return minf(GameData.RAID_YMIR_CAST_MAX, 1.0 + GameData.RAID_YMIR_MVP_CAST * ymir)




func ymir_hero_mult() -> float:
	return maxf(1.0 + GameData.RAID_YMIR_HERO_DMG * ymir, ymir_gift) if state == "fight" else 1.0


func ymir_hero_cd() -> float:
	return minf(GameData.RAID_YMIR_CD_MAX, 1.0 + GameData.RAID_YMIR_HERO_CD * ymir) if state == "fight" else 1.0



func ymir_text() -> String:
	if state != "fight" or boss == null:
		return ""
	if ymir > 0.0 or ymir_gift > 0.0:
		return tr("Ymir:  tú x%s  ·  MVP x%s") % [str(snappedf(ymir_hero_mult(), 0.1)), str(snappedf(ymir_mvp_mult(), 0.1))]
	var left: = ymir_at - _fight_t
	if left <= GameData.RAID_YMIR_WARN:
		return tr("Ymir despierta en %s") % UiKit.time_text(maxf(0.0, left))
	return ""






func _hit_pct(pct: float, h: Player) -> void :
	if h == null or not is_instance_valid(h) or h.downed or h.hp <= 0.0:
		return
	stats.fails += 1
	world.hurt_what = _now_name
	h.take_damage(h.max_hp * pct * GameData.RAID_MECH_DMG * ymir_mvp_mult() * (GameData.RAID_GENTLE_DMG if gentle else 1.0) * tower_mech(), 
		world, boss, true)






func _hit_tick(pct: float, h: Player) -> void :
	if h == null or not is_instance_valid(h) or h.downed or h.hp <= 0.0:
		return
	stats.fails += 1
	world.hurt_what = _now_name

	world.set_meta("doom_tick", true)
	h.take_damage(h.max_hp * pct * GameData.RAID_MECH_DMG * minf(ymir_mvp_mult(), GameData.RAID_YMIR_TICK_MAX)
		* (GameData.RAID_GENTLE_DMG if gentle else 1.0) * tower_mech(), world, boss, true)
	world.remove_meta("doom_tick")



func _hit_all(pct: float) -> void :
	for h in _standing():
		_hit_pct(pct, h)




func _hit_dmg(weight: float, h: Player) -> void :
	_hit_pct(weight * GameData.RAID_HIT_PCT * (1.0 + GameData.RAID_HIT_PCT_DANGER * (world.danger - 1)), h)
	if h == world.player:
		world.hud.flash(Color(1, 0.2, 0.15), 0.35)



func _standing() -> Array[Player]:
	var out: Array[Player] = []
	for h in world.heroes:
		if is_instance_valid(h) and not h.downed and h.hp > 0.0:
			out.append(h)
	return out



func _target() -> Player:
	var taunted: Player = boss.taunter(world) if boss != null and is_instance_valid(boss) else null
	if taunted != null:
		return taunted
	var party: = _standing()
	return party.pick_random() if not party.is_empty() else world.player



func _tint(h: Player, on: bool) -> void :
	var col: = Color(0.7, 0.45, 0.95) if on else Color.WHITE
	if h.visual.tint == col:
		return
	h.visual.tint = col
	h.visual.sprite.modulate = col
	_net(["tint", h.slot, on])


func _crumble_pillars() -> void :
	var hits: = int(data.get("pillars", {}).get("hits", GameData.RAID_PILLAR_HITS))
	for i in range(_pillars.size() - 1, -1, -1):
		var pl: Dictionary = _pillars[i]
		if int(pl.hits) >= hits:
			Vfx.burst(world.fx_root, pl.pos, 2.0, Color(0.7, 0.6, 0.5))
			world.play_sound("refine_fail", 0.1, -6.0)
			_fade(pl.node, 0.4)
			_pillars.remove_at(i)

			_add_pillar(_arena_point(0.6, pl.pos, 5.0))




func _update_objects(delta: float) -> void :
	var party: = _standing()
	for i in range(_objects.size() - 1, -1, -1):


		if i >= _objects.size():
			continue
		var o: Dictionary = _objects[i]
		var done: = false
		_now_name = str((o.get("ab", {}) as Dictionary).get("name", ""))
		match o.kind:
			"dash":
				o.t -= delta
				var dir: Vector3 = o.dir
				var step: = world.map.slide(boss.position, dir * 17.0 * delta)
				boss.position = Vector3(step.x, world.map.height_at(step), step.z)
				boss.visual.face(dir)
				o["ghost"] = float(o.get("ghost", 0.0)) - delta
				if float(o.ghost) <= 0.0:
					o.ghost = 0.05
					_afterimage()
				for h in party:
					if not (o.hit as Array).has(h) and _flat(h.position, boss.position) < boss.radius + 1.0:
						o.hit.append(h)
						_hit_dmg(float(o.ab.dmg), h)
				done = o.t <= 0.0
			"holy":
				o.t -= delta

				var inside: Dictionary = o["in"]
				for h in party:
					if float(curses.get(h, 0.0)) <= 0.0:
						continue
					if _flat(h.position, o.pos) < GameData.RAID_ZONE_RADIUS:
						inside[h] = float(inside.get(h, 0.0)) + delta
						if float(inside[h]) >= 0.5:
							curses.erase(h)
							_tint(h, false)
							world.play_sound("heal", 0.0, -2.0)
							world.spawn_fx("cure", h.position, 1.0, 1.0, h)
							world.number(h.position + Vector3(0, 1.6, 0), tr("¡Purificado!"), Color(0.6, 1, 0.7))
				if not _cursed() or o.t <= 0.0:
					done = true
				if done:
					_fade(o.node, 0.4)
			"bubble":
				if mark > 0.0 and party.any( func(h): return _flat(h.position, o.pos) < 1.3):
					Vfx.burst(world.fx_root, o.pos, 1.8, Color(0.7, 0.85, 1))
					world.play_sound("drop_blue", 0.05, -8.0)
					world.number(o.pos + Vector3(0, 1.4, 0), tr("¡Pop!"), Color(0.7, 0.9, 1))
					_fade(o.node, 0.2)
					done = true
			"bombs", "eggs":
				var e: Enemy = o.enemy
				if not is_instance_valid(e) or e.dead:
					if o.kind == "bombs":
						world.number(o.label.global_position if is_instance_valid(o.label) else boss.position, tr("¡Desactivada!"), Color(0.6, 1, 0.7))
					done = true
				else:
					o.t -= delta
					_set_text(o.label, "%d" % ceili(o.t))
					if o.t <= 0.0:
						if o.kind == "bombs":
							world.spawn_fx("firepillar", e.position, 1.6)
							Vfx.burst(world.fx_root, e.position, 4.0, Color(1, 0.5, 0.2))
							world.play_sound("meteor", 0.0, 0.0)
							world.shake(0.7)
							_hit_all(float(o.ab.pct))
						elif o.ab.has("boss_heal"):

							boss.hp = minf(boss.max_hp, boss.hp + boss.max_hp * float(o.ab.boss_heal))
							_calm_damage *= 1.05
							boss.damage *= 1.05
							world.spawn_fx("holyhit", boss.position, 1.6)
							world.number(boss.position + Vector3(0, 2.4, 0), "+%d" % roundi(boss.max_hp * float(o.ab.boss_heal)), Color(0.5, 1, 0.5), true)
							_shout(boss, tr("¡La horda me da fuerza!"), Color(1, 0.6, 0.4))
							world.play_sound("warning", 0.3, -6.0)
						else:
							var hatch: = world.spawn_enemy(str(o.ab.hatch), e.position, true)
							if hatch != null:
								hatch.summoned = true
								_shout(hatch, tr("¡%s!") % tr(hatch.def.name), Color(1, 0.5, 0.4))
							Vfx.burst(world.fx_root, e.position, 2.5, Color(0.8, 0.3, 0.3))
							world.play_sound("warning", 0.3, -6.0)
						world.banish_enemy(e)
						done = true
			"orb":
				o.t -= delta
				o.armed -= delta
				var node: Node3D = o.node

				var tgt: Player = o.target
				if not party.has(tgt) and not party.is_empty():
					tgt = _nearest_hero(node.global_position, party)
					o.target = tgt
				var to: = (tgt.position - node.global_position) * Vector3(1, 0, 1)

				o.wake = float(o.get("wake", 0.0)) - delta
				var waking: = float(o.wake) > 0.0
				if to.length() > 0.05 and not waking:
					node.global_position += to.normalized() * tgt.move_speed * GameData.RAID_ORB_SPEED * delta
				var ground: = node.global_position
				ground.y = world.map.height_at(ground) + 1.0
				node.global_position = ground
				_aim_line(o.line, node.global_position, boss.position)
				o["sync"] = float(o.get("sync", 0.0)) - delta
				if float(o.sync) <= 0.0:
					o.sync = 0.1
					_net(["orb_at", node.get_meta("raid_id", 0), o.line.get_meta("raid_id", 0) if is_instance_valid(o.line) else 0, 
						node.global_position, boss.position])
				if waking:
					_set_text(o.label, tr("¡Aparece aquí!  Luego te persigue"))
				else:
					_set_text(o.label, tr("¡Te persigue!  Atráela a %s\nNo dejes que te toque · %d s")\
					%[tr(str(GameData.MONSTERS[mvp].name)), ceili(maxf(0.0, o.t))])
				if o.armed <= 0.0 and _flat(node.global_position, boss.position) < boss.radius + 0.8:



					boss.hold = 3.5
					boss.mark_vuln = maxf(boss.mark_vuln if world.clock < boss.mark_until else 0.0, GameData.RAID_ORB_VULN)
					boss.mark_until = maxf(boss.mark_until, world.clock + GameData.RAID_ORB_VULN_TIME)
					_shout(boss, tr("¡Aturdido!"), Color(1, 0.8, 0.4))
					world.spawn_fx(str(o.ab.get("fx", "holyhit")), boss.position, 2.0)
					Vfx.burst(world.fx_root, boss.position, 3.5, color)
					world.play_sound("stun", 0.0, 0.0)
					done = true
				elif not waking and party.any( func(h): return _flat(node.global_position, h.position) < 0.8):
					var hit: = _nearest_hero(node.global_position, party)
					Vfx.burst(world.fx_root, hit.position, 2.5, color)
					_hit_pct(float(o.ab.pct), hit)
					done = true
				elif o.t <= 0.0:
					done = true
				if done:
					_fade(node, 0.25)
					_fade(o.line, 0.1)
			"kafra":
				o.t -= delta
				var k: RoVisual = o.node
				var bars: = 10
				var filled: = clampi(roundi((1.0 - o.t / o.total) * bars), 0, bars)
				_set_text(o.label, tr("Desactivando  %s%s\n%d/%d") % ["■".repeat(filled), "□".repeat(bars - filled), o.hp, o.max])
				if o.hp <= 0:
					world.spawn_fx("firepillar", k.global_position, 1.8)
					Vfx.burst(world.fx_root, k.global_position, 6.0, Color(1, 0.5, 0.2))
					world.play_sound("meteor", 0.0, 2.0)
					world.shake(0.9)
					_hit_all(float(o.ab.pct))
					_warn(UiKit.tr_later("La Kafra cayó: ¡la bomba explotó!"), Color(1, 0.35, 0.3), "warning")
					done = true
				elif o.t <= 0.0:
					_chat(k, tr("¡Desactivada! Toma, ¡te curo!"), Color(1, 0.85, 0.9))
					for h in party:
						h.heal(h.max_hp * 0.4, world)
					world.play_sound("heal", 0.0, 0.0)
					boss.hold = 4.0
					_shout(boss, tr("¡¿Qué?!"), Color(1, 0.8, 0.4))
					_warn(UiKit.tr_later("¡Bomba desactivada! %s está aturdido"), Color(0.6, 1, 0.6), "party_alarm", [str(GameData.MONSTERS[mvp].name)])
					done = true
				if done:
					for e in o.adds:
						if is_instance_valid(e):
							e.target = null
					var tw: = k.create_tween()
					tw.tween_interval(1.5)
					tw.tween_callback( func(): Vfx.column(world.fx_root, k.global_position, Color(1, 0.8, 0.9)))
					tw.tween_callback(k.queue_free)
			"hazard":
				o.t -= delta
				o.tick -= delta
				if o.tick <= 0.0:
					o.tick = 0.5
					for n in 2:
						world.spawn_fx(str(o.ab.get("fx", "")), _arena_point(0.9), 1.0, 0.6)
					for h in party:
						var safe: = false
						for pad in o.pads:
							if _flat(h.position, pad.pos) < GameData.RAID_PLATFORM_RADIUS:
								safe = true
						if not safe:
							_hit_tick(float(o.ab.pct), h)
				if o.t <= 0.0:
					for pad in o.pads:
						_fade(pad.node, 0.4)
						_fade(pad.ring, 0.4)
					_fade(o.danger, 0.4)
					done = true
			"ice":
				o.t -= delta
				if o.t <= 0.0:
					_fade(o.node, 0.6)
					done = true
			_:
				done = _update_extra(o, delta)
		if done and i < _objects.size() and _objects[i] == o:
			_objects.remove_at(i)


	for h in world.heroes:
		var on_ice: = false
		for o in _objects:
			if o.kind == "ice" and _flat(h.position, o.pos) < float(o.r):
				on_ice = true
		h.slip = 1.0 if on_ice else 0.0


func _update_debuffs(delta: float) -> void :
	for h in curses.keys():
		if not is_instance_valid(h) or h.downed or h.hp <= 0.0:
			curses.erase(h)
			if is_instance_valid(h):
				_tint(h, false)
	if _cursed():
		_curse_tick -= delta
		if _curse_tick <= 0.0:
			_curse_tick = 1.0
			var pct: = 0.025
			for ab in data.abilities:
				if ab.mech == "cleanse":
					pct = float(ab.pct)
			for h in curses.keys():
				curses[h] = minf(float(curses[h]) + 0.35, 6.0)
				world.hurt_what = "Maldición"
				world.set_meta("doom_tick", true)
				h.take_damage(h.max_hp * pct * GameData.RAID_MECH_DMG * float(curses[h]) * tower_mech(), world, boss, true)
				world.remove_meta("doom_tick")

		var has_zone: = _objects.any( func(o): return o.kind == "holy")
		if not has_zone:
			for ab in data.abilities:
				if ab.mech == "cleanse":
					var at: = _arena_point(0.7, _target().position, 5.0)
					_objects.append({"kind": "holy", "node": _zone(at, GameData.RAID_ZONE_RADIUS, Color(0.5, 1, 0.6), str(ab.zone_fx)), 
						"pos": at, "t": 16.0, "in": {}, "ab": ab})
					break
	if mark > 0.0:
		mark -= delta
		var left: = _objects.filter( func(o): return o.kind == "bubble")
		if left.is_empty():
			mark = 0.0
			_warn(UiKit.tr_later("¡Burbujas reventadas!"), Color(0.6, 1, 0.6), "party_alarm")
		elif mark <= 0.0:
			for o in left:
				Vfx.burst(world.fx_root, o.pos, 2.5, color)
				_fade(o.node, 0.2)
				_objects.erase(o)
				_hit_all(float(o.ab.pct))
			world.play_sound("meteor", 0.0, 0.0)



func npc_hit(node: Node3D) -> void :
	for o in _objects:
		if o.kind == "kafra" and o.node == node:
			o.hp -= 1
			if o.node is RoVisual:
				o.node.flash()
			world.number(node.global_position + Vector3(0, 1.4, 0), "-1", Color(1, 0.4, 0.4))




func on_boss_killed(e: Enemy) -> void :
	if e != boss or state != "fight":
		return
	state = "won"

	_fell_at = e.position
	_reach.clear()
	_clear_mechanics()
	if epic != null:
		epic.won()

	Save.add_ymir_fragment(1)
	world.run_ymir += 1



	var ori: = world.player.refine_mats_mult() if world.player != null else 1.0
	for i in World._mat_count(GameData.MVP_ENRICHED, world.oath_mats() * ori):
		world.gain_material(["enriched_oridecon", "enriched_elunium"].pick_random())

	var drop: = 1.0 + float(world.player.effects.get("drop_find", 0.0))
	if randf() < GameData.MVP_HD_CHANCE * drop * world.oath_mats() * ori:
		world.gain_material(["hd_oridecon", "hd_elunium"].pick_random())

	if not world.training and randf() < GameData.MVP_COIN_CHANCE * drop:
		world.found_coin()
	world.number(world.player.position + Vector3(0, 2.6, 0), tr("Fragmento de Ymir  %d/%d") % [
		mini(Save.ymir_fragments(), GameData.REBIRTH_FRAGMENTS), GameData.REBIRTH_FRAGMENTS], Color(0.75, 0.9, 1.0), true)
	world.play_sound("drop_yellow", 0.0, -2.0)
	for m in world.enemies.duplicate():
		if m != boss:
			world.banish_enemy(m)
	_big(tr("¡Victoria!"), tr("%s ha caído") % tr(GameData.MONSTERS[mvp].name), Color(1, 0.9, 0.4))
	_net(["won"])
	if world.endless:

		var tw: = create_tween()
		tw.tween_interval(2.5)
		tw.tween_callback( func():
			if state == "won":
				offer_exits())






func offer_exits() -> void :
	if state != "won" or _return_portal:
		return
	_return_portal = true
	_exits_armed = false


	var gold: = Color(0.45, 0.78, 1.0)
	var keep: = color
	color = gold


	var away: = (center - _fell_at) * Vector3(1, 0, 1)
	if _fell_at == Vector3.INF or away.length() < 0.5:
		away = Vector3(0, 0, 1)
	away = away.normalized()
	var side: = away.cross(Vector3.UP).normalized()
	var spot: = center + away * radius * 0.6
	var exit_at: = spot + side * (2.6 if world.karma.can_route() else 0.0)
	_spawn_portal(_exit_spot(exit_at), tr("Volver al mapa") if world.endless else tr("Salida"))
	_map_reach()
	color = keep

	Vfx.column(world.fx_root, portal_pos, gold)
	Vfx.ring(world.fx_root, portal_pos + Vector3(0, 0.1, 0), 5.0, gold.lightened(0.3), 0.8)
	world.spawn_fx("magnus", portal_pos, 1.2, 0.8)
	world.play_sound("portal_open", 0.0, 0.0)
	world.play_sound("magnus", 0.0, -6.0)
	world.shake(0.3)
	if world.karma.can_route():
		_spawn_kportal(_exit_spot(spot - side * 2.6, portal_pos), world.karma.route_side())





var _fell_at: = Vector3.INF
var _reach: = {}
var _rescue_t: = 0.0







func _portal_point(from: Vector3) -> Vector3:
	var m: = world.map




	var base: = m.reachable_point(from, from)
	if base == Vector3.INF:
		base = from
	for i in 60:
		var a: = randf() * TAU
		var p: = base + Vector3(cos(a), 0, sin(a)) * randf_range(4.0, 6.5 + i * 0.05)
		if _portal_spot_clear(p, base) and m.can_reach(p, from):
			return p

	for i in 30:
		var a: = randf() * TAU
		var p: = base + Vector3(cos(a), 0, sin(a)) * randf_range(1.5, 3.0)
		if _portal_spot_clear(p, base) and m.can_reach(p, from):
			return p



	for i in 8:
		var a: = TAU * i / 8.0
		var p: = m.reachable_point(base + Vector3(cos(a), 0, sin(a)) * 2.5, from)
		if p != Vector3.INF and _flat(p, from) >= 1.6:
			return p

	for d in [Vector3(1.8, 0, 0), Vector3(-1.8, 0, 0), Vector3(0, 0, 1.8), Vector3(0, 0, -1.8)]:
		if m.is_walkable(base + d) and _flat(base + d, from) >= 1.6:
			return base + d
	return base if _flat(base, from) >= 1.6 else from + Vector3(1.8, 0, 0)




func _portal_spot_clear(at: Vector3, from: Vector3) -> bool:
	if not world.map.is_walkable(at):
		return false
	var ground: = world.map.height_at(at)
	if is_nan(ground) or absf(ground - world.map.height_at(from)) > 1.5:
		return false


	var same_level: = 0
	for d in [Vector2(0.8, 0.0), Vector2(-0.8, 0.0), Vector2(0.0, 0.8), Vector2(0.0, -0.8)]:
		var neighbor: = at + Vector3(d.x, 0, d.y)
		if not world.map.is_walkable(neighbor):
			continue
		var neighbor_ground: = world.map.height_at(neighbor)
		if not is_nan(neighbor_ground) and absf(neighbor_ground - ground) <= 0.65:
			same_level += 1
	return same_level >= 2


func _map_reach() -> void :
	_reach.clear()
	if portal_pos == Vector3.INF:
		return
	var m: = world.map
	var start: = m.tile_of(portal_pos)
	var c: = m.tile_of(center)
	var span: = int(ceil(radius / maxf(0.1, m.cell_center(c.x + 1, c.y).x - m.cell_center(c.x, c.y).x))) + 3
	var todo: Array[Vector2i] = [start]
	_reach[start] = true
	while not todo.is_empty():
		var t: Vector2i = todo.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
			var n: Vector2i = t + d
			if _reach.has(n) or absi(n.x - c.x) > span or absi(n.y - c.y) > span or not m.cell_walkable(n.x, n.y):
				continue
			_reach[n] = true
			todo.append(n)


func _rescue_stranded() -> void :
	if _reach.is_empty() or portal_pos == Vector3.INF:
		return
	for h in world.heroes:
		if h.downed or not is_instance_valid(h):
			continue
		if _reach.has(world.map.tile_of(h.position)):
			continue
		var at: = world.map.find_point_around(portal_pos, 1.8, 3.0)
		if at == Vector3.INF or not _reach.has(world.map.tile_of(at)):
			at = portal_pos + Vector3(1.8, 0, 0)
		Vfx.column(world.fx_root, h.position, Color(0.85, 0.9, 1.0))
		h.position = Vector3(at.x, world.map.height_at(at), at.z)
		Vfx.column(world.fx_root, h.position, Color(0.85, 0.9, 1.0))
		world.play_sound("portal", 0.0, -6.0)



func _walkable(at: Vector3) -> Vector3:
	if world.map.is_walkable(at):
		return at
	var p: = world.map.find_point_around(at, 0.5, 4.0)
	return p if p != Vector3.INF else center








func _exit_spot(at: Vector3, avoid: = Vector3.INF) -> Vector3:
	var m: = world.map
	var gate: = center + Vector3(0, 0, radius * 0.6)
	var out: = (at - center) * Vector3(1, 0, 1)
	var side: = out.normalized().cross(Vector3.UP) * 2.0 if out.length() > 0.1 else Vector3(2.0, 0, 0)
	var last: = Vector3.INF
	for k in [1.0, 0.8, 0.6, 0.4, 0.2, 0.0]:
		for s in [0.0, 1.0, -1.0]:
			var q: = m.reachable_point(center + out * k + side * s, gate, int(radius) + 8)
			if q == Vector3.INF:
				continue
			if _flat(q, center) > radius - 1.0:
				continue


			if last == Vector3.INF:
				last = q
			if avoid != Vector3.INF and _flat(q, avoid) < 3.0:
				continue
			if _pillars.any( func(pl): return is_instance_valid(pl.node) and _flat(pl.pos, q) < 1.8):
				continue
			return q
	return last if last != Vector3.INF else _walkable(at)


func _hero_near(at: Vector3) -> bool:
	for h in world.heroes:
		if not h.downed and _flat(h.position, at) < 1.2:
			return true
	return false



func _take_exit() -> void :
	_clear_kportal()
	if world.endless:
		leave()
		return
	_clear_portal()
	_return_portal = false
	world.play_sound("portal", 0.0, 0.0)
	world.menus.show_victory_choice()



func _spawn_kportal(at: Vector3, side: String) -> void :
	_clear_kportal()
	_kside = side
	_kportal_pos = at
	var r: Dictionary = GameData.KARMA_ROUTES[side]
	var col: Color = r.color
	_kportal = Node3D.new()
	world.fx_root.add_child(_kportal)
	_kportal.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	Vfx.warp_portal(_kportal, col, 1.5)
	Vfx.beam(_kportal, Vector3.ZERO, col, 11.0)
	Vfx.beam(_kportal, Vector3.ZERO, col.lightened(0.5) if side == "light" else Color(0.1, 0.0, 0.02), 4.0)
	var glow: = Vfx.ground_glow(_kportal, Vector3.ZERO, 2.8, Color(col, 0.7))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.3, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.75, 0.7).set_trans(Tween.TRANS_SINE)
	_label(_kportal, tr(str(r.portal)), col.lightened(0.35), 4.5, 36)

	_label(_kportal, tr(str(r.foes)).replace(": ", ":\n").replace(", ", ",\n"), Color.WHITE, 2.9, 26)
	Vfx.burst(world.fx_root, _kportal.global_position, 3.5, col)
	if side == "light":
		Vfx.column(world.fx_root, at, col)
		world.spawn_fx("holyhit", at + Vector3(0, 0.6, 0), 1.6, 1.0)
		world.play_sound("assumptio", 0.0, -2.0)
		world.play_sound("angelus", 0.0, -4.0)
	else:
		world.spawn_fx("hell_in", at, 1.4, 1.0)
		for i in 4:
			var a: = TAU * i / 4.0
			world.spawn_fx("firepillar", at + Vector3(cos(a), 0, sin(a)) * 1.8, 0.7, 0.8)
		world.play_sound("portal_open", 0.0, -2.0)
	world.shake(0.4)
	world.party_announce(tr(str(r.name)), col.lightened(0.2), 
		tr("La balanza abrió un portal: ¡enfréntate a %s!") % tr(GameData.MONSTERS[str(r.mvp)].name))
	world.net.karma_portal(at, side)


func _clear_kportal() -> void :
	if _kportal != null and is_instance_valid(_kportal):
		_kportal.queue_free()
		world.net.karma_portal(Vector3.INF, _kside)
	_kportal = null
	_kportal_pos = Vector3.INF




func start_route(mob: String) -> void :
	leave()
	mvp = mob
	data = GameData.RAIDS[mob]
	color = data.color
	state = "portal"
	for e in world.enemies.duplicate():
		if not e.is_boss:
			world.banish_enemy(e)
	_enter()



func leave() -> void :
	if not in_arena():
		return
	_end_epic()
	_clear_kportal()
	_clear_mechanics()
	_clear_arena()

	var carried: Array[Dictionary] = []
	for p in world.pickups:
		if p.kind in ["xp", "loot", "ore"]:
			world._collect(p)
			p.node.queue_free()
		else:
			carried.append(p)
	world.pickups.clear()
	world.clear_battlefield()
	world.remove_child(world.map)
	world.map.queue_free()
	world.add_child(_field_map)
	world.move_child(_field_map, 1)
	world.map = _field_map
	_field_map = null
	world.player.position = _field_pos
	for h in world.heroes:
		if h != world.player:
			h.position = _party_pos.get(h, _field_pos)
	_party_pos.clear()
	for p in _stash:
		p.node.visible = true
		world.pickups.append(p)
	_stash.clear()
	world.altars.set_shown(true)
	for p in carried:
		var at: = world.map.random_point_around(world.player.position, 2.0)
		p.node.position = at + Vector3(0, 0.5, 0)
		world.pickups.append(p)
	if world.pet != null:
		world.pet.position = world.player.position
	world.snap_camera()
	world.net.raid_back()
	world.play_music("map", true)
	world.play_sound("portal", 0.0, 0.0)
	state = "idle"
	mvp = ""
	boss = null






func net_promote() -> void :
	if not in_arena():
		return
	for id in _nodes:
		var n = _nodes[id]
		if n != null and is_instance_valid(n):
			n.queue_free()
	_nodes.clear()
	_waiting.clear()
	_net_dbm = []
	_cast = {}
	data = GameData.RAIDS.get(mvp, data)
	_field_pos = portal_pos if portal_pos != Vector3.INF else world.player.position
	if boss == null or not is_instance_valid(boss) or boss.dead:
		boss = world.boss if world.boss != null and is_instance_valid(world.boss) and not world.boss.dead else null
	if boss == null:

		if state != "won":
			state = "intro"
			_intro = 1.0
		return
	boss.brain = null
	_calm_damage = boss.damage
	world.boss = boss
	_vuln = 0.0
	_guarded = false
	_aura_t = 0.0
	phase = 0
	var phases: Array = data.phases
	while phase + 1 < phases.size() and boss.hp / maxf(1.0, boss.max_hp) <= float(phases[phase + 1]):
		phase += 1
	_timers.clear()
	for ab in data.abilities:
		if ab.phases.has(phase):
			_timers[ab.id] = float(ab.first)

	if bool(data.get("epic", false)) and state != "won":
		var hp: = boss.hp
		var mx: = boss.max_hp
		var dmg: = boss.damage
		epic = NaghtFight.new(self)
		epic.begin()
		boss.max_hp = mx
		boss.hp = hp
		boss.damage = dmg
		_calm_damage = dmg
	if state != "won":
		state = "fight"
	print("RAID promoted: %s phase %d, boss %.0f / %.0f" % [mvp, phase, boss.hp, boss.max_hp])




func drop_field_map() -> void :
	if _field_map != null:
		if _field_map != world.map and is_instance_valid(_field_map):
			_field_map.queue_free()
		_field_map = null




func reset() -> void :
	portal_sealed = false
	_fell_at = Vector3.INF
	_reach.clear()
	_end_epic()
	for id in _nodes:
		if is_instance_valid(_nodes[id]):
			_nodes[id].queue_free()
	_nodes.clear()
	_waiting.clear()
	_net_dbm = []
	_clear_mechanics()
	_clear_arena()
	_clear_portal()
	_clear_kportal()
	if _field_map != null:
		if world.map != _field_map:
			world.remove_child(world.map)
			world.map.queue_free()
			world.add_child(_field_map)
			world.move_child(_field_map, 1)
			world.map = _field_map
		_field_map = null
	for p in _stash:
		if is_instance_valid(p.node):
			p.node.queue_free()
	_stash.clear()
	state = "idle"
	mvp = ""
	boss = null
	_return_portal = false


func _end_epic() -> void :
	if epic != null:
		epic.finish()
		epic = null




func untouchable(e: Enemy) -> bool:
	return e == boss and state == "fight" and _guarded




func epic_mult(e: Enemy) -> float:
	var m: = epic.hero_mult(e) if epic != null and state == "fight" else 1.0


	if e == boss and state == "fight":
		if _guarded:
			return 0.0
		if _vuln > 0.0:
			m *= 1.0 + _vuln_k

		m *= trials.hero_mult(e)
	return m



func _afterimage() -> void :
	if not boss.visual is RoVisual:
		return
	var v: RoVisual = boss.visual
	var g: = Sprite3D.new()
	g.texture = v.sprite.texture
	g.offset = v.sprite.offset
	g.centered = false
	g.pixel_size = v.sprite.pixel_size
	g.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	g.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	g.shaded = false
	g.modulate = Color(color.lightened(0.3), 0.55)
	g.render_priority = GameData.MVP_UNDER_PRIORITY
	world.fx_root.add_child(g)
	g.global_transform = v.sprite.global_transform
	var tw: = g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.3)
	tw.tween_callback(g.queue_free)





func _begin_cast_tell(ab: Dictionary, cast: float) -> void :
	boss.hold = maxf(boss.hold, cast + 0.3)
	if boss.visual is RoVisual:
		(boss.visual as RoVisual).play(RoVisual.MOB_ATTACK, true, true)
	world.play_sound("beginspell", 0.0, -2.0)
	Vfx.ring(world.fx_root, boss.position, 2.6, Color(color, 0.9), cast)


	var under: = GameData.MVP_UNDER_PRIORITY
	Vfx.magic_circle(world.fx_root, boss.position, 3.2, Color(color.lightened(0.2), 0.75), cast + 0.3, "mvp_rune", 0.9, under, true)
	Vfx.magic_circle(world.fx_root, boss.position, 1.9, Color(color.lightened(0.5), 0.8), cast + 0.3, "mvp_hexa", -2.4, under, true)
	world.spawn_fx("lightning", boss.position, 0.8, 0.5)
	if _cast_bar == null or not is_instance_valid(_cast_bar):
		_cast_bar = _label(boss, "", Color(1.0, 0.9, 0.55), 3.6, 30)
	_cast_name = tr(str(ab.name))
	_update_cast_bar()


func _update_cast_bar() -> void :
	if _cast_bar == null or not is_instance_valid(_cast_bar):
		return
	if _cast.is_empty():
		_cast_bar.queue_free()
		_cast_bar = null
		return
	var bars: = 12
	var filled: = clampi(roundi((1.0 - _cast.t / maxf(0.01, _cast.total)) * bars), 0, bars)
	_set_text(_cast_bar, "%s\n%s" % [_cast_name, "▮".repeat(filled) + "▯".repeat(bars - filled)])


func _clear_cast() -> void :
	if _cast_bar != null and is_instance_valid(_cast_bar):
		_cast_bar.queue_free()
	_cast_bar = null
	if _cast.is_empty():
		return
	for s in _cast.get("shadows", []):
		if is_instance_valid(s):
			s.queue_free()
	for key in ["zone", "danger"]:
		if _cast.has(key) and is_instance_valid(_cast[key]):
			_cast[key].queue_free()
	for pad in _cast.get("pads", []):
		for key in ["node", "ring"]:
			if is_instance_valid(pad[key]):
				pad[key].queue_free()
	_cast = {}






func interrupt() -> void :
	if _cast.is_empty():
		return
	_drop_tells(_cast.get("tells", []))
	_clear_cast()
	_gap = GameData.RAID_CAST_GAP


func _clear_mechanics() -> void :
	_immune = 0.0
	_vuln = 0.0
	_guarded = false
	_clear_cast()
	for o in _objects:


		for key in ["node", "line", "danger", "label", "chains", "face"]:
			if o.has(key) and is_instance_valid(o[key]):
				o[key].queue_free()

		var tells = o.get("tells", [])
		for arr in (tells.values() if tells is Dictionary else ([tells] if tells is Array else [])):
			if arr is Array:
				_drop_tells(arr)
		for n in o.get("nodes", []):
			if is_instance_valid(n):
				n.queue_free()
		for pad in o.get("pads", []):
			for key in ["node", "ring"]:
				if is_instance_valid(pad[key]):
					pad[key].queue_free()
		if o.has("enemy") and is_instance_valid(o.enemy) and not o.enemy.dead:
			world.banish_enemy(o.enemy)
		for e in o.get("adds", []):
			if is_instance_valid(e) and not e.dead:
				world.banish_enemy(e)
	_objects.clear()
	_ice_zones.clear()
	curses.clear()
	mark = 0.0
	for h in world.heroes:
		h.slip = 0.0
		h.visual.tint = Color.WHITE
		h.visual.sprite.modulate = Color.WHITE


func _clear_arena() -> void :
	for pl in _pillars:
		if is_instance_valid(pl.node):
			pl.node.queue_free()
	_pillars.clear()
	if _npc != null and is_instance_valid(_npc):
		_npc.queue_free()
	_npc = null
	if _arena_fx != null and is_instance_valid(_arena_fx):
		_arena_fx.queue_free()
	_arena_fx = null
	_clear_portal()
	_return_portal = false










var _next_id: = 0

var _nodes: = {}
var _net_dbm: Array = []
var _sync_t: = 0.0

var _ice_zones: Array[Dictionary] = []


func _net(ev: Array) -> void :
	if not is_instance_valid(world) or world.net == null or not world.net.recording():
		return


	if str(ev[0]) in ["dbm", "orb_at", "obj_at"]:
		world.net.record(["R"] + ev)
	else:
		world.net.record_raid(ev)



func _reg(node: Node, ev: Array) -> void :
	if node == null or not world.net.recording():
		return
	_next_id += 1
	node.set_meta("raid_id", _next_id)
	_net(["obj", _next_id] + ev)
	node.tree_exiting.connect(_on_obj_gone.bind(_next_id))


func _on_obj_gone(id: int) -> void :
	_net(["free", id])



func _ref(node: Node) -> Array:
	if node == null or not world.net.recording():
		return []
	if node is Enemy or node is Player:
		return world.net.ref_of(node)
	if node.has_meta("raid_id"):
		return ["o", int(node.get_meta("raid_id"))]
	return []


func _find(ref: Array) -> Node3D:
	if ref.is_empty():
		return null
	if str(ref[0]) == "o":
		var n = _nodes.get(int(ref[1]))
		return n if n != null and is_instance_valid(n) else null
	return world._net_node(ref)




func _warn(text: String, col: Color, sound: = "", args: = []) -> void :
	world.hud.alerts.warn(warn_text(text, args), col, sound)
	_net(["warn", text, col, sound, args])




static func warn_text(text: String, args: Array) -> String:
	var t: = TranslationServer.translate(text)
	if args.is_empty():
		return t
	var a: = []
	for x in args:
		a.append(TranslationServer.translate(x) if x is String else x)
	return t % a




func warn_hero(h: Player, text: String, col: Color, sound: = "", args: = []) -> void :
	if h == world.player:
		world.hud.alerts.warn(warn_text(text, args), col, sound)
	elif world.net.is_host():
		world.net.send_got(h, "warn", [text, col, sound, args])




var _guide: = {}
func net_guide(to: Vector3, size: float, col: Color, t: float) -> void :
	if not _guide.is_empty() and is_instance_valid(_guide.line):
		_guide.line.queue_free()
	_guide = {"line": NaghtFight.make_line(world, col), "to": to, "size": size, "t": t}


func _guide_tick(delta: float) -> void :
	if _guide.is_empty():
		return
	_guide.t = float(_guide.t) - delta
	var line = _guide.line
	if float(_guide.t) <= 0.0 or not is_instance_valid(line) or world.player == null or world.player.downed:
		if is_instance_valid(line):
			line.queue_free()
		_guide = {}
		return
	var to: Vector3 = _guide.to
	NaghtFight.point_line(line, world.player.position, to, _flat(world.player.position, to) < float(_guide.size))




func _tip(text: String, col: Color, sound: = "") -> void :
	world.hud.alerts.warn(_tip_text(text), col, sound)
	_net(["tip", text, col, sound])


static func _tip_text(text: String) -> String:
	return text if bool(Save.setting("mvp_tips", true)) else text.get_slice(": ", 0)


func _big(title: String, sub: String, col: Color) -> void :
	world.hud.alerts.big(title, sub, col)
	_net(["big", title, sub, col])


func _announce(title: String, col: Color, sub: = "") -> void :
	world.hud.announce(title, col, sub)
	_net(["announce", title, col, sub])


func _mvp_alert(mvp_name: String, place: String, col: Color) -> void :
	world.hud.alerts.mvp_alert(mvp_name, place, col)
	_net(["mvp_alert", mvp_name, place, col])



func _make_orb(start: Vector3) -> Node3D:
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = start + Vector3(0, 1.0, 0)
	var glow: = Vfx.ground_glow(node, Vector3.ZERO, 0.9, Color(color.lightened(0.4), 0.9))
	glow.axis = Vector3.AXIS_Z
	glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	Vfx.beam(node, Vector3(0, -1.0, 0), color, 1.6)
	Vfx.magic_circle(node, Vector3(0, -1.0, 0), 0.9, Color(color.lightened(0.4), 0.8), 0.0, "mvp_seal", 2.0, Vfx.DANGER_PRIORITY, true)
	return node



func _make_sprite(sprite: String, tint: Color, px: int, shadow: float, at: Vector3) -> RoVisual:
	var v: = RoVisual.new()
	world.fx_root.add_child(v)
	v.setup(RoAssets.sprite([sprite]), tint, px, shadow)
	v.play(0, true)
	_in_front(v)
	v.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	return v




func _in_front(v: RoVisual) -> void :
	v.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	v.sprite.render_priority = GameData.HERO_PRIORITY



func _danger_floor(cast: float) -> Sprite3D:
	var danger: = Vfx._flat(world.fx_root, Vfx.disc_texture(), center, radius, Color(1, 0.2, 0.1, 0.0))
	Vfx.danger(danger)
	danger.create_tween().tween_property(danger, "modulate:a", 0.35, cast)
	return danger



func net_event(ev: Array) -> void :
	match str(ev[0]):
		"arena":
			mvp = str(ev[1])
			data = GameData.RAIDS[mvp]
			color = data.color
			state = "intro"
			_build_arena_fx()
		"fight":
			mvp = str(ev[1])
			state = "fight"
			boss = world.boss
		"won":
			state = "won"
			_net_dbm = []
		"ymir":
			ymir = maxf(ymir, 0.01)
			if _arena_fx != null and is_instance_valid(_arena_fx):
				Vfx.magic_circle(_arena_fx, Vector3.ZERO, radius * 0.95, Color(0.6, 0.25, 1.0, 0.12), 0.0, "mvp_rune", 0.12)
			if boss != null and is_instance_valid(boss):
				_ymir_glow()
		"dbm":
			_net_dbm = ev[1]
			_fight_t = float(ev[2])
			ymir_at = float(ev[3])
			ymir = float(ev[4])

			if ev.size() > 5:
				phase = int(ev[5])
		"warn":
			world.hud.alerts.warn(warn_text(str(ev[1]), ev[4] if ev.size() > 4 and ev[4] is Array else []), ev[2], str(ev[3]))
		"tip":
			world.hud.alerts.warn(_tip_text(str(ev[1])), ev[2], str(ev[3]))
		"big":
			world.hud.alerts.big(str(ev[1]), str(ev[2]), ev[3])
		"announce":
			world.hud.announce(str(ev[1]), ev[2], str(ev[3]))
		"mvp_alert":
			world.hud.alerts.mvp_alert(str(ev[1]), str(ev[2]), ev[3])
			world.play_sound("warning", 0.0, 2.0)
		"obj":
			var node: = _net_build(str(ev[2]), ev.slice(3))
			if node != null:
				_nodes[int(ev[1])] = node
			elif str(ev[2]) == "label":
				_waiting.append({"id": int(ev[1]), "a": ev.slice(3), "t": 2.0})
		"text":
			var l = _nodes.get(int(ev[1]))
			if l != null and is_instance_valid(l):
				(l as Label3D).text = str(ev[2])
		"fade":
			var n = _nodes.get(int(ev[1]))
			_nodes.erase(int(ev[1]))
			_forget(n)
			_fade(n, float(ev[2]))
		"free":
			var n = _nodes.get(int(ev[1]))
			_nodes.erase(int(ev[1]))
			_forget(n)
			if n != null and is_instance_valid(n):
				n.queue_free()
		"npc_to":
			_npc_to(ev[1])
		"obj_at":
			var moving = _nodes.get(int(ev[1]))
			if moving != null and is_instance_valid(moving):
				moving.set_meta("to", ev[2])
		"obj_scale":
			var growing = _nodes.get(int(ev[1]))
			if growing != null and is_instance_valid(growing):
				growing.set_meta("to_scale", float(ev[2]))
		"hour":
			var face = _nodes.get(int(ev[1]))
			if face != null and is_instance_valid(face):
				_light_hour(face, int(ev[2]), int(ev[3]))
		"tower_held":
			var tb = _nodes.get(int(ev[1]))
			if tb != null and is_instance_valid(tb):
				tb.set_meta("held", bool(ev[2]))
		"orb_at":
			var orb = _nodes.get(int(ev[1]))
			if orb != null and is_instance_valid(orb):
				orb.set_meta("to", ev[3])
			var line = _nodes.get(int(ev[2]))
			if line != null and is_instance_valid(line):
				_aim_line(line, ev[3], ev[4])
		"shout":
			var at: = _find(ev[1])
			if at != null:
				_shout(at, str(ev[2]), ev[3])
		"chat":
			var at: = _find(ev[1])
			if at != null:
				_chat(at, str(ev[2]), ev[3])
		"tint":
			var slot: = int(ev[1])
			if slot < world.heroes.size():
				_tint(world.heroes[slot], bool(ev[2]))
		_:
			trials.net_event(ev)


func _net_build(kind: String, a: Array) -> Node3D:
	match kind:
		"pillar":
			_add_pillar(a[0])
			return _pillars.back().node
		"npc":
			_spawn_npc()
			return _npc
		"sprite":
			return _make_sprite(str(a[0]), a[1], int(a[2]), float(a[3]), a[4])
		"orb":
			return _make_orb(a[0])
		"line":
			return _hint_line()
		"floor":
			return _danger_floor(float(a[0]))
		"shadow":
			return _cover_shadow(a[0], a[1])
		"zone":
			return _zone(a[0], float(a[1]), a[2], str(a[3]), float(a[4]), bool(a[5]))
		"label":
			var parent: = _find(a[0])
			if parent != null:
				return _make_label(parent, str(a[1]), a[2], float(a[3]), int(a[4]), bool(a[5]))
		"brand":
			var bearer: = _find(a[0])
			if bearer != null:
				var mark: = Node3D.new()
				bearer.add_child(mark)
				_make_brand(mark, a[1], float(a[2]), a[3], float(a[4]))
				return mark
		"wall":
			return _make_wall(a[0], a[1], float(a[2]), float(a[3]), a[4])
		"beam":
			var beam: = _make_beam(a[0], float(a[1]), float(a[2]), float(a[3]), a[4])
			beam.set_meta("spin", float(a[5]))
			beam.set_meta("len", float(a[2]))
			beam.set_meta("width", float(a[3]))
			return beam
		"chains":
			return _make_chains(a[0], a[1], float(a[2]))
		"vortex":
			return _make_vortex(a[0], float(a[1]), float(a[2]))
		"clockface":
			return _clock_face(a[0], float(a[1]))
		"tbeam":
			var z = _nodes.get(int(a[0]))
			if z != null and is_instance_valid(z):
				return _tower_beam(z, float(a[1]))
		_:
			return trials.net_build(kind, a)
	return null



var _waiting: Array[Dictionary] = []



func _forget(n) -> void :
	if n == null:
		return
	_pillars = _pillars.filter( func(pl): return pl.node != n)
	_ice_zones = _ice_zones.filter( func(z): return z.node != n)
	if n == _npc:
		_npc = null




func client_tick(delta: float) -> void :
	_guide_tick(delta)
	for i in range(_waiting.size() - 1, -1, -1):
		var w: Dictionary = _waiting[i]
		w.t -= delta
		var node: = _net_build("label", w.a)
		if node != null:
			_nodes[w.id] = node
		if node != null or w.t <= 0.0:
			_waiting.remove_at(i)
	var k: = 1.0 - exp( - delta * 12.0)
	for id in _nodes:
		var n = _nodes[id]
		if n == null or not is_instance_valid(n):
			continue
		if n.has_meta("to"):
			n.global_position = n.global_position.lerp(n.get_meta("to"), k)
		if n.has_meta("to_scale"):
			n.scale = n.scale.lerp(Vector3.ONE * float(n.get_meta("to_scale")), k)
		if n.has_meta("tower"):
			_tower_pulse(n)

		if n.has_meta("sigil") and is_instance_valid(n.get_meta("sigil")):
			(n.get_meta("sigil") as Node3D).rotation.z += delta * 2.0

		if n.has_meta("spin"):
			n.rotation.y -= float(n.get_meta("spin")) * delta
			var gt: = float(n.get_meta("ghost_t", 0.0)) - delta
			if gt <= 0.0:
				gt = 0.06
				_beam_ghost(n.global_position - Vector3(0, 0.1, 0), - n.rotation.y - PI * 0.5, float(n.get_meta("len", radius * 2.2)), 
					float(n.get_meta("width", 2.0)), color)
			n.set_meta("ghost_t", gt)
		if n.has_meta("slots"):
			_aim_chains(n, n.get_meta("at"), float(n.get_meta("reach")))
		if n.has_meta("trial"):
			trials.node_tick(n, delta)
	var p: = world.player
	var on_ice: = false
	for z in _ice_zones:
		if is_instance_valid(z.node) and _flat(p.position, z.pos) < float(z.r):
			on_ice = true
	p.slip = 1.0 if on_ice else 0.0
	for pl in _pillars:
		var d: Vector3 = (p.position - pl.pos) * Vector3(1, 0, 1)
		if d.length() < 0.8 and d.length() > 0.001:
			var at: Vector3 = pl.pos + d.normalized() * 0.8
			p.position = Vector3(at.x, world.map.height_at(at), at.z)



func net_leave() -> void :
	for id in _nodes:
		var n = _nodes[id]
		if n != null and is_instance_valid(n):
			n.queue_free()
	_nodes.clear()
	_waiting.clear()
	_net_dbm = []
	_ice_zones.clear()
	_clear_mechanics()
	_clear_arena()
	state = "idle"
	mvp = ""
	boss = null
	ymir = 0.0
	ymir_gift = 0.0






func dbm_entries() -> Array:
	var out: = []
	if state != "fight":
		return out
	if world._net_arena:
		return _net_dbm
	if not _cast.is_empty():
		out.append({"name": tr("» %s") % tr(str(_cast.ab.name)), "left": maxf(0.0, _cast.t), "total": _cast.total, 
			"lethal": _cast.ab.get("lethal", false), "now": true}.merged(dbm_more(_cast.ab)))
	var groups: = {}
	for o in _objects:
		if o.kind in ["bombs", "eggs"] and is_instance_valid(o.enemy):
			var g: Dictionary = groups.get(o.ab.id, {"n": 0, "t": 0.0, "ab": o.ab, "name": tr(str(o.enemy.def.name))})
			g.n += 1
			g.t = maxf(g.t, o.t)
			groups[o.ab.id] = g
	for g in groups.values():
		out.append({"name": "%s x%d" % [g.name, g.n], "left": maxf(0.0, g.t), "total": float(g.ab.time), 
			"lethal": true, "now": true}.merged(dbm_more(g.ab)))
	for o in _objects:
		match o.kind:
			"kafra":
				out.append({"name": tr("Kafra (%d/%d)") % [o.hp, o.max], "left": maxf(0.0, o.t), "total": o.total, 
					"lethal": true, "now": true}.merged(dbm_more(o.ab)))
			"hazard":
				out.append({"name": tr(str(o.ab.name)), "left": maxf(0.0, o.t), "total": float(o.ab.duration), 
					"lethal": true, "now": true}.merged(dbm_more(o.ab)))
			_:
				if o.has("show"):
					out.append({"name": tr(str(o.show)), "left": maxf(0.0, float(o.get("left", o.t))), "total": float(o.total), 
						"lethal": true, "now": true})
	if _cursed():
		var most: = 0.0
		for h in curses:
			most = maxf(most, float(curses[h]))
		out.append({"name": tr("Maldición x%d") % ceili(most), "left": 0.0, "total": 1.0, "lethal": true, "now": true})
	if mark > 0.0:

		var charm: = {}
		for ab in data.get("abilities", []):
			if str(ab.get("mech", "")) == "mark":
				charm = ab
		out.append({"name": tr("Encanto: revienta burbujas"), "left": mark, "total": 11.0, "lethal": true, "now": true}.merged(dbm_more(charm)).merged({"mech": "mark"}, true))
	if _vuln > 0.0:
		out.append({"name": tr("¡Vulnerable!"), "left": _vuln, "total": _vuln_t, "lethal": false, "now": true})
	if epic != null:
		out.append_array(epic.dbm())
	var next: = []
	for ab in data.abilities:
		if ab.phases.has(phase) and (_cast.is_empty() or _cast.ab != ab):
			next.append({"name": tr(str(ab.name)), "left": maxf(0.0, float(_timers.get(ab.id, ab.first))), 
				"total": float(ab.every), "lethal": ab.get("lethal", false), "now": false}.merged(dbm_more(ab)))
	next.sort_custom( func(a, b): return a.left < b.left)
	out.append_array(next)
	return out.slice(0, 7)





static func dbm_more(ab) -> Dictionary:
	if not (ab is Dictionary):
		return {}


	return {"mech": str(ab.get("mech", "")), "alert": str(ab.get("alert", "")), "key": str(ab.get("name", ""))}





func active_names() -> Array:
	var out: = []
	for en in (_net_dbm if world._net_arena else dbm_entries()):
		if bool(en.get("now", false)):
			out.append(str(en.name).trim_prefix("» "))
			if str(en.get("key", "")) != "":
				out.append(tr(str(en.key)))
	if not world._net_arena:
		for o in _objects:
			if o.has("ab") and o.ab is Dictionary:
				out.append(tr(str(o.ab.get("name", ""))))
	return out




func autopilot_goal(h: Player = null) -> Vector3:
	var p: = h if h != null else world.player
	match state:
		"portal":
			return portal_pos
		"won":
			return portal_pos if _return_portal else Vector3.INF
		"fight":
			pass
		_:
			return Vector3.INF
	if not _cast.is_empty():
		match _cast.ab.mech:
			"los":
				var best: = Vector3.INF
				for pl in _pillars:
					var spot: Vector3 = pl.pos + _dir(boss.position, pl.pos) * 1.4
					if best == Vector3.INF or _flat(p.position, spot) < _flat(p.position, best):
						best = spot
				return best
			"shield":
				return _cast.at
			"platforms":
				return _nearest(_cast.pads.map( func(pad): return pad.pos))
			"slam", "rain":
				for t in _cast.targets:
					if _flat(p.position, t) < float(_cast.ab.size) + 0.5:
						return p.position + _dir(t, p.position) * 3.0
			"cone", "charge":
				var side: = Vector3( - _cast.dir.z, 0, _cast.dir.x)
				return p.position + side * 3.0
	if epic != null:
		var own: = epic.goal(p)
		if own != Vector3.INF:
			return own
	var extra: = _extra_goal(p)
	if extra != Vector3.INF:
		return extra
	for o in _objects:
		if o.kind == "hazard":
			return _nearest(o.pads.map( func(pad): return pad.pos))
	if float(curses.get(p, 0.0)) > 0.0:
		for o in _objects:
			if o.kind == "holy":
				return o.pos
	if mark > 0.0:
		var bubbles: = _objects.filter( func(o): return o.kind == "bubble").map( func(o): return o.pos)
		if not bubbles.is_empty():
			return _nearest(bubbles)
	for o in _objects:
		match o.kind:
			"orb":
				if o.target == p:
					return boss.position + _dir(o.node.global_position, boss.position) * 2.2
			"kafra":
				return o.node.global_position + Vector3(1.2, 0, 0)
			"bombs", "eggs":
				if is_instance_valid(o.enemy):
					return o.enemy.position + _dir(o.enemy.position, p.position) * 1.5
	return Vector3.INF




const TOWER_CLAIM: = 1.0














func _start_extra(ab: Dictionary, p: Player, cast: float) -> bool:

	if str(ab.mech) in ["spokes", "sweep", "clock"]:
		to_center()
	match str(ab.mech):
		"starfall":
			_chat(boss, tr("¡Que caiga el cielo!"))
			_objects.append({"kind": "starfall", "ab": ab, "target": p, "n": 0, "t": 0.3, "show": str(ab.name), 
				"total": float(ab.step) * float(ab.count) + 1.2, "left": float(ab.step) * float(ab.count) + 1.2})
		"spokes":
			var base: = randf() * TAU
			var tells: = _spokes_tell(boss.position, base, _spoke_count(ab), float(ab.width), cast)
			boss.hold = maxf(boss.hold, cast + 0.3)
			_cast = {"ab": ab, "t": cast, "total": cast, "base": base, "from": boss.position, "tells": tells}
		"wall":
			_wall_start(ab, 0)
		"sweep":
			var a0: = atan2(p.position.z - boss.position.z, p.position.x - boss.position.x) + PI * 0.5
			var spin: = (1.0 if randf() < 0.5 else -1.0) * float(ab.turn) / float(ab.time)
			var length: = radius * 2.2

			var tells: = [Vfx.telegraph_line(world.fx_root, boss.position, Vector3(cos(a0), 0, sin(a0)), length, float(ab.width), cast)]
			var ahead: = a0 + signf(spin) * 0.6
			tells.append(Vfx.telegraph_line(world.fx_root, boss.position, Vector3(cos(ahead), 0, sin(ahead)), length * 0.5, float(ab.width) * 0.4, cast))
			boss.hold = maxf(boss.hold, cast + float(ab.time) + 0.3)
			_cast = {"ab": ab, "t": cast, "total": cast, "a0": a0, "spin": spin, "tells": tells}
		"clock":
			boss.hold = maxf(boss.hold, float(ab.step) * 13.0)
			var o: = {"kind": "clock", "solo": true, "ab": ab, "i": 0, "t": float(ab.step), "a0": randf() * TAU, "at": boss.position, 
				"hands": 2 if phase >= 2 else 1, "show": str(ab.name), "total": float(ab.step) * 12.0, "left": float(ab.step) * 12.0, 
				"tells": {}}
			o["face"] = _clock_face(boss.position, float(o.a0))
			_reg(o.face, ["clockface", boss.position, float(o.a0)])
			_clock_tell(o, 0)
			_clock_tell(o, 1)
			_objects.append(o)
		"still":
			var move: bool = str(ab.get("mode", "still")) == "move"
			var lbl: = _label(boss, tr("¡QUIETO!") if move else tr("¡NO TE DETENGAS!"), Color(1.0, 0.75, 0.3) if move else Color(0.6, 0.85, 1.0), 4.8, 44)
			var last: = {}
			for h in world.heroes:
				last[h] = h.position
			_objects.append({"kind": "still", "ab": ab, "move": move, "t": float(ab.duration), "tick": 1.0, "last": last, 
				"label": lbl, "show": str(ab.name), "total": float(ab.duration)})
		"towers":
			var n: = clampi(_standing().size(), 1, int(ab.count))
			var nodes: Array = []
			var spots: Array = []
			for i in n:
				var at: = _arena_point(0.6, Vector3.INF, 0.0, i, n) if n > 1 else _arena_point(0.55, p.position, 5.0)
				var z: = _zone(at, float(ab.size), Color(1.0, 0.85, 0.35), str(ab.get("fx", "")), 1.0)
				var lbl: = _label(z, "", Color(1.0, 0.9, 0.5), 1.4, 40)
				nodes.append(z)
				var beam: = _tower_beam(z, float(ab.size))
				if z.has_meta("raid_id"):
					_reg(beam, ["tbeam", int(z.get_meta("raid_id")), float(ab.size)])
				spots.append({"pos": at, "node": z, "label": lbl, "beam": beam})
			_objects.append({"kind": "towers", "ab": ab, "t": float(ab.time), "spots": spots, "nodes": nodes, 
				"show": str(ab.name), "total": float(ab.time)})
		"puddles":
			var targets: Array[Vector3] = []
			for h in _standing():
				targets.append(h.position)
			for i in int(ab.count) - targets.size():
				targets.append(_arena_point(0.85))
			var tells: Array = []
			for t in targets:
				tells.append(Vfx.telegraph_circle(world.fx_root, t, float(ab.size), cast))
			_cast = {"ab": ab, "t": cast, "total": cast, "targets": targets, "tells": tells}
		"volley":
			var d: = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
			var lanes: = _volley_lanes(ab)
			var first: Array = []
			var second: Array = []
			for i in lanes.size():
				(first if i % 2 == 0 else second).append(lanes[i])
			var tells: = _volley_tell(d, first, ab, cast)
			_cast = {"ab": ab, "t": cast, "total": cast, "d": d, "lanes": first, "next": second, "tells": tells}
		"tether":
			var at: = _arena_point(0.5, p.position, 4.0)
			var totem: = _make_sprite(str(ab.get("totem", "rock_pillar")), color, 48, 1.0, at)
			_reg(totem, ["sprite", str(ab.get("totem", "rock_pillar")), color, 48, 1.0, at])
			Vfx.column(world.fx_root, totem.global_position, color)
			var slots: Array = []
			for h in _standing():
				slots.append(h.slot)
			var chains: = _make_chains(totem.global_position, slots, float(ab.range))
			_reg(chains, ["chains", totem.global_position, slots, float(ab.range)])

			var reach: = _zone(totem.global_position, float(ab.range), Color(0.6, 1.0, 0.7), "")
			_objects.append({"kind": "tether", "ab": ab, "t": float(ab.duration), "tick": 0.5, "pos": totem.global_position, 
				"node": totem, "chains": chains, "nodes": [reach], "show": str(ab.name), "total": float(ab.duration)})
		"vortex":
			_vortex_start(ab)
		"brand":
			_brand_start(ab)
		"break":
			_break_start(ab)
		_:
			return trials.start(ab, p) or (epic != null and epic.start(ab, p, cast))
	return true



func _resolve_extra(c: Dictionary) -> bool:
	var ab: Dictionary = c.ab
	match str(ab.mech):
		"spokes":
			_spokes_hit(c["from"], float(c.base), ab)

			var base: = float(c.base) + PI / float(_spoke_count(ab))
			var wave: = {"kind": "spoke_wave", "t": float(ab.wave), "base": base, "from": c["from"], "ab": ab, "tells": []}
			_objects.append(wave)

			_later(WAVE_TELL_DELAY, func(): wave.tells = _spokes_tell(wave["from"], base, _spoke_count(ab), float(ab.width), 
				maxf(0.1, float(wave.t))))
		"sweep":
			var beam: = _make_beam(boss.position, float(c.a0), radius * 2.2, float(ab.width), color)
			_reg(beam, ["beam", boss.position, float(c.a0), radius * 2.2, float(ab.width), color, float(c.spin)])
			_objects.append({"kind": "sweep", "solo": true, "ab": ab, "t": float(ab.time), "a": float(c.a0), "spin": float(c.spin), 
				"node": beam, "hit": [], "fx": 0.0, "ghost": 0.0, "at": boss.position, "show": str(ab.name), "total": float(ab.time)})
			Vfx.ring(world.fx_root, boss.position, 3.0, color.lightened(0.4), 0.5)
			world.play_mob_sound(mvp, "attack")
		"puddles":
			world.play_sound("meteor", 0.2, -6.0)
			for t in c.targets:
				Vfx.strike_circle(world.fx_root, t, float(ab.size), _strike_color(ab))
				world.spawn_fx(str(ab.get("fx", "")), t, 1.0, 0.7)
				var z: = _zone(t, float(ab.size), Color(1.0, 0.35, 0.2) if str(ab.get("element", "fire")) == "fire" else Color(0.55, 1.0, 0.35), str(ab.get("fx", "")), 0.8)
				_objects.append({"kind": "puddle", "ab": ab, "pos": t, "node": z, "t": float(ab.duration), "tick": 0.5})
		"volley":
			_volley_hit(c.d, c.lanes, ab)
			var wave: = {"kind": "volley_wave", "t": float(ab.wave), "d": c.d, "lanes": c.next, "ab": ab, "tells": []}
			_objects.append(wave)
			_later(WAVE_TELL_DELAY, func(): wave.tells = _volley_tell(wave.d, wave.lanes, ab, maxf(0.1, float(wave.t))))
		_:
			return epic != null and epic.resolve(c)
	return true



func _update_extra(o: Dictionary, delta: float) -> bool:
	var party: = _standing()
	match str(o.kind):
		"spoke_wave":
			o.t -= delta
			if o.t <= 0.0:
				_drop_tells(o.tells)
				_spokes_hit(o["from"], float(o.base), o.ab)
				return true
		"volley_wave":
			o.t -= delta
			if o.t <= 0.0:
				_drop_tells(o.tells)
				_volley_hit(o.d, o.lanes, o.ab)
				return true
		"wall":
			o.t -= delta
			var k: = clampf(1.0 - o.t / float(o.total_move), 0.0, 1.0) if o.t < float(o.total_move) else 0.0
			var node: Node3D = o.node
			if o.t > float(o.total_move):
				return false
			var at: Vector3 = (o.start as Vector3) + (o.d as Vector3) * (radius * 2.0 * k)
			node.global_position = Vector3(at.x, center.y, at.z)
			o["sync"] = float(o.get("sync", 0.0)) - delta
			if float(o.sync) <= 0.0:
				o.sync = 0.1
				_net(["obj_at", int(node.get_meta("raid_id", 0)), node.global_position])
			o.fx = float(o.fx) - delta
			if o.fx <= 0.0:


				o.fx = 0.2
				for i in 2:
					var off: = randf_range( - radius, radius)
					if absf(off - float(o.gap)) > float(o.gap_w) * 0.5 + 1.0:
						world.spawn_fx(str(o.ab.get("fx", "")), at + (o.side as Vector3) * off, 0.4, 0.5)

			var depth: = radius * 2.0 * k - radius
			for h in party:
				if (o.hit as Array).has(h):
					continue
				var rel: = (h.position - center) * Vector3(1, 0, 1)
				var along: = rel.dot(o.d)
				if absf(along - depth) < 0.8:
					var off: = rel.dot(o.side)
					if absf(off - float(o.gap)) > float(o.gap_w) * 0.5:
						o.hit.append(h)
						Vfx.burst(world.fx_root, h.position, 2.0, color)
						_hit_pct(float(o.ab.pct), h)
			if o.t <= 0.0:
				_fade(node, 0.3)
				if int(o.n) + 1 < int(o.ab.count) + (1 if phase >= 2 else 0):
					_wall_start(o.ab, int(o.n) + 1)
				return true
		"starfall":
			o.t = float(o.t) - delta
			o.left = float(o.left) - delta
			if float(o.t) <= 0.0 and int(o.n) < int(o.ab.count):
				o.t = float(o.ab.step)
				o.n = int(o.n) + 1
				var tgt: Player = o.target
				if not is_instance_valid(tgt) or tgt.downed:
					tgt = _target()

				var at: = tgt.position
				var size: = float(o.ab.size)
				var tell: = Vfx.telegraph_circle(world.fx_root, at, size, 1.0)

				_later(1.0 - RAIN_FALL, func(): Vfx.fall(world.fx_root, at, size, color.lightened(0.3), RAIN_FALL))
				_later(1.0, func():
					_drop_tells([tell])
					Vfx.strike_circle(world.fx_root, at, size, color.lightened(0.3))
					world.spawn_fx(str(o.ab.get("fx", "meteor1")), at, 1.1, 0.85)
					world.play_sound("meteor", 0.15, -6.0)
					world.shake(0.25)
					for hero in _standing():
						if _flat(hero.position, at) < size:
							_hit_dmg(float(o.ab.dmg), hero))
			return float(o.left) <= 0.0
		"sweep":
			o.t -= delta
			o.a = float(o.a) + float(o.spin) * delta
			var node: Node3D = o.node
			if is_instance_valid(node):
				node.rotation.y = - float(o.a) - PI * 0.5
			var dir: = Vector3(cos(o.a), 0, sin(o.a))
			var at: Vector3 = o.at

			o.ghost = float(o.ghost) - delta
			if o.ghost <= 0.0:
				o.ghost = 0.06
				_beam_ghost(at, float(o.a), radius * 2.2, float(o.ab.width), color)
			o.fx = float(o.fx) - delta
			if o.fx <= 0.0:
				o.fx = 0.09
				for k in 2:
					world.spawn_fx(str(o.ab.get("fx", "")), at + dir * randf_range(1.5, radius * 1.4), 1.0, 0.85)
				world.spawn_fx(str(o.ab.get("fx", "")), at + dir * minf(radius * 1.15, radius * 2.2 - 1.0), 1.3, 0.9)
			for h in party:
				if (o.hit as Array).has(h):
					continue
				var rel: = (h.position - at) * Vector3(1, 0, 1)
				if rel.dot(dir) > 0.0 and absf(rel.cross(dir).y) < float(o.ab.width) * 0.5 + 0.3:
					o.hit.append(h)
					Vfx.burst(world.fx_root, h.position, 2.0, color)
					_hit_dmg(float(o.ab.dmg), h)
			if o.t <= 0.0:
				_fade(node, 0.2)
				return true
		"clock":
			o.t -= delta
			o.left = float(o.left) - delta
			if o.t <= 0.0:
				o.t = float(o.ab.step)
				_clock_hit(o, int(o.i))
				_clock_tell(o, int(o.i) + 2)
				o.i = int(o.i) + 1
				if int(o.i) >= 12:
					_fade(o.get("face"), 0.4)
					return true
		"still":
			o.t -= delta
			o.tick = float(o.tick) - delta
			if o.tick <= 0.0:
				o.tick = 1.0
				var last: Dictionary = o["last"]
				for h in party:
					var moved: = _flat(h.position, last.get(h, h.position))
					var bad: bool = moved > 1.2 if o.move else moved < 0.6
					if bad:
						world.spawn_fx(str(o.ab.get("fx", "")), h.position, 0.9, 0.8, h)
						world.label_over(h, tr("¡Quieto!") if o.move else tr("¡Muévete!"), Color(1, 0.5, 0.4))
						_hit_tick(float(o.ab.pct), h)
					else:
						Vfx.ring(world.fx_root, h.position, 1.2, Color(0.6, 1.0, 0.7, 0.8), 0.3)
					last[h] = h.position
			if o.t <= 0.0:
				_fade(o.label, 0.2)
				return true
		"towers":
			o.t -= delta
			for s in o.spots:


				var stood: = party.any( func(h): return _flat(h.position, s.pos) < float(o.ab.size))
				s["on"] = float(s.get("on", 0.0)) + delta if stood else 0.0
				if float(s.on) >= TOWER_CLAIM:
					s["claimed"] = true
				var held: = stood or bool(s.get("claimed", false))
				_set_text(s.label, "%s  %d" % [tr("¡Pisa!") if not held else "✓", ceili(maxf(0.0, o.t))])

				var beam: Sprite3D = s.get("beam")
				if beam != null and is_instance_valid(beam):
					if held != bool(beam.get_meta("held", false)) and beam.has_meta("raid_id"):
						_net(["tower_held", int(beam.get_meta("raid_id")), held])
					beam.set_meta("held", held)
					_tower_pulse(beam)
			if o.t <= 0.0:
				var empty: = 0
				for s in o.spots:
					var held: = bool(s.get("claimed", false)) or party.any( func(h): return _flat(h.position, s.pos) < float(o.ab.size))
					if held:
						world.spawn_fx("holyhit", s.pos, 1.0, 0.8)
					else:
						empty += 1
						world.spawn_fx(str(o.ab.get("fx", "")), s.pos, 1.6, 0.9)
						Vfx.burst(world.fx_root, s.pos, float(o.ab.size) * 2.5, color)
					_fade(s.node, 0.3)
				if empty > 0:
					world.shake(0.7)
					world.play_sound("meteor", 0.0, 0.0)
					_hit_all(float(o.ab.pct) * empty)
				else:
					_warn(UiKit.tr_later("¡Bien contenido!"), Color(0.6, 1, 0.6), "party_alarm")
				return true
		"puddle":
			o.t -= delta
			o.tick = float(o.tick) - delta
			if o.tick <= 0.0:
				o.tick = 0.5
				for h in party:
					if _flat(h.position, o.pos) < float(o.ab.size):
						_hit_tick(float(o.ab.pct), h)
			if o.t <= 0.0:
				_fade(o.node, 0.5)
				return true
		"tether":
			o.t -= delta
			_aim_chains(o.chains, o.pos, float(o.ab.range))
			o.tick = float(o.tick) - delta
			if o.tick <= 0.0:
				o.tick = 0.5
				for h in party:
					if _flat(h.position, o.pos) > float(o.ab.range):
						world.spawn_fx("hit", h.position + Vector3(0, 0.8, 0), 0.7, 0.8)
						_hit_tick(float(o.ab.pct), h)
			if o.t <= 0.0:
				Vfx.column(world.fx_root, o.pos, color)
				_fade(o.node, 0.3)
				_fade(o.chains, 0.2)
				_fade(o.nodes[0], 0.3)
				return true
		"vortex":
			return _vortex_update(o, delta, party)
		"brand":
			return _brand_update(o, delta)
		"break":
			return _break_update(o, delta)
		_:
			if trials.owns(o):
				return trials.update(o, delta)
			if epic != null:
				return epic.update(o, delta)
	return false









var _vuln: = 0.0
var _vuln_k: = 0.0
var _vuln_t: = 0.0
var _guarded: = false
var _aura_t: = 0.0




func _tick_aura(delta: float) -> void :
	if not data.has("aura") or boss == null or not is_instance_valid(boss) or boss.dead:
		return
	_aura_t -= delta
	if _aura_t > 0.0:
		return
	var au: Dictionary = data.aura
	_aura_t = float(au.get("every", 1.6)) * (0.5 if _vuln > 0.0 else 1.0)
	var a: = randf() * TAU
	world.spawn_fx(str(au.fx), boss.position + Vector3(cos(a), 0, sin(a)) * randf_range(0.6, 1.6), 0.7, 0.55)
func _break_start(ab: Dictionary) -> void :
	var adds: Array = []
	for i in int(ab.count):
		var a: = TAU * i / float(ab.count) + randf() * 0.4
		var at: = center + Vector3(cos(a), 0, sin(a)) * radius * 0.7
		at = _walkable(at)
		var e: = world.spawn_enemy(str(ab.mob), at, true)
		if e == null:
			continue
		e.max_hp = boss.max_hp * float(ab.hp)
		e.hp = e.max_hp
		e.summoned = true
		e.speed = 0.0

		e.set_meta("raid_guard", true)
		Vfx.column(world.fx_root, e.position, color)
		world.spawn_fx(str(ab.get("fx", "holyhit")), e.position, 1.0, 0.8)
		adds.append(e)

	var shield: = Node3D.new()
	boss.add_child(shield)
	Vfx.magic_circle(shield, Vector3.ZERO, 3.2, Color(color.lightened(0.3), 0.75), 0.0, "mvp_hexa", 1.6, Vfx.DANGER_PRIORITY, true)
	Vfx.magic_circle(shield, Vector3.ZERO, 2.0, Color(1, 1, 1, 0.5), 0.0, "mvp_rune", -2.4, Vfx.DANGER_PRIORITY, true)
	world.spawn_fx(str(ab.get("aura", "kyrie")), boss.position, 1.6, 0.9, boss)
	world.play_sound("kyrie", 0.0, -2.0)
	var lbl: = _label(boss, "", Color(1.0, 0.95, 0.75), 4.6, 46)
	boss.hold = maxf(boss.hold, float(ab.time) + 0.2)
	_objects.append({"kind": "break", "ab": ab, "t": float(ab.time), "total": float(ab.time), "adds": adds, "node": shield, 
		"label": lbl, "fx": 0.0, "show": str(ab.name)})


func _break_update(o: Dictionary, delta: float) -> bool:
	var ab: Dictionary = o.ab
	o.t -= delta
	var left: = (o.adds as Array).filter( func(e): return is_instance_valid(e) and not e.dead)
	_set_text(o.label, tr("Escudo  ·  %d") % left.size())

	_guarded = not left.is_empty() and o.t > 0.0
	o.fx = float(o.fx) - delta
	if o.fx <= 0.0:
		o.fx = 0.6
		for e: Enemy in left:

			Vfx.strike_line(world.fx_root, e.position, _dir(e.position, boss.position), _flat(e.position, boss.position), 0.35, 
				Color(color.lightened(0.3), 0.6))
	if left.is_empty():

		_vuln = float(ab.stagger)
		_vuln_t = _vuln
		_vuln_k = float(ab.vuln)
		boss.hold = maxf(boss.hold, _vuln)
		Vfx.burst(world.fx_root, boss.position, 6.0, color.lightened(0.3))
		Vfx.column(world.fx_root, boss.position, Color(1.0, 0.95, 0.7))
		world.spawn_fx("stun", boss.position + Vector3(0, 2.6, 0), 1.2, 1.0, boss)
		world.play_sound("hammer_fall", 0.0, -2.0)
		world.shake(0.6)
		_big(tr("¡Escudo roto!"), tr("%s cae aturdida: ¡+%d%% de daño durante %d s!") % [tr(str(GameData.MONSTERS[mvp].name)), roundi(_vuln_k * 100.0), roundi(_vuln)], Color(1.0, 0.85, 0.4))
		_fade(o.node, 0.3)
		_fade(o.label, 0.2)
		return true
	if o.t <= 0.0:

		for e: Enemy in left:
			world.banish_enemy(e)
		Vfx.burst(world.fx_root, boss.position, radius, color)
		world.spawn_fx(str(ab.get("fx", "holyhit")), boss.position, 2.4)
		world.play_sound("meteor", 0.0, 0.0)
		world.shake(0.8)
		_hit_all(float(ab.pct))
		_fade(o.node, 0.3)
		_fade(o.label, 0.2)
		return true
	return false







func _vortex_start(ab: Dictionary) -> void :
	boss.hold = maxf(boss.hold, float(ab.duration) + 0.3)
	var at: = Vector3(boss.position.x, world.map.height_at(boss.position), boss.position.z)
	var node: = _make_vortex(at, float(ab.size), float(ab.get("from", 1.5)))

	_reg(node, ["vortex", at, float(ab.size), float(ab.get("from", 1.5))])
	world.play_sound(str(ab.get("sound", "earth_quake")), 0.0, -2.0)
	world.shake(0.3)
	_objects.append({"kind": "vortex", "ab": ab, "t": float(ab.duration), "total": float(ab.duration), "node": node, 
		"tick": 0.5, "fx": 0.0, "show": str(ab.name)})



func _make_vortex(at: Vector3, r: float, from: float) -> Node3D:
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = at
	var disc: = Vfx._flat(node, Vfx.disc_texture(), Vector3.ZERO, r, Color(color.darkened(0.3), 0.4))
	var edge: = Vfx._flat(node, Vfx.ring_texture(), Vector3.ZERO, r * 1.02, Color(1.0, 0.35, 0.2, 0.95))
	for f in [disc, edge]:
		Vfx.danger(f)

	var swirl: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * r * 2.0
	swirl.mesh = plane
	swirl.material_override = Vfx.energy_material(Color(color.lightened(0.1), 0.7), false, 1.4, true)
	swirl.position = Vector3(0, 0.1, 0)
	node.add_child(swirl)

	Vfx.magic_circle(node, Vector3.ZERO, r * 0.95, Color(color.lightened(0.2), 0.7), 0.0, "mvp_hexa", 2.6, Vfx.DANGER_PRIORITY, true)
	Vfx.magic_circle(node, Vector3.ZERO, r * 0.6, Color(1.0, 0.4, 0.3, 0.55), 0.0, "mvp_rune", -3.4, Vfx.DANGER_PRIORITY, true)
	node.scale = Vector3.ONE * (from / r)
	return node


func _vortex_update(o: Dictionary, delta: float, party: Array[Player]) -> bool:
	var ab: Dictionary = o.ab
	o.t -= delta
	var k: = clampf(1.0 - float(o.t) / float(o.total), 0.0, 1.0)
	var r: = lerpf(float(ab.get("from", 1.5)), float(ab.size), k)
	var node: Node3D = o.node
	if is_instance_valid(node):
		node.scale = Vector3.ONE * (r / float(ab.size))
		node.global_position = Vector3(boss.position.x, world.map.height_at(boss.position), boss.position.z)
		o["sync"] = float(o.get("sync", 0.0)) - delta
		if float(o.sync) <= 0.0 and node.has_meta("raid_id"):
			o.sync = 0.1
			_net(["obj_at", int(node.get_meta("raid_id")), node.global_position])
			_net(["obj_scale", int(node.get_meta("raid_id")), node.scale.x])

	for h in party:
		var d: = _flat(h.position, boss.position)
		if d > 0.8:
			var by: = _dir(h.position, boss.position) * minf(d - 0.8, h.move_speed * float(ab.get("pull", 0.45)) * delta)
			var to: = world.map.slide(h.position, by)
			h.position = Vector3(to.x, world.map.height_at(to), to.z)
	o.fx = float(o.fx) - delta
	if o.fx <= 0.0:
		o.fx = 0.25
		var a: = randf() * TAU
		world.spawn_fx(str(ab.get("fx", "hell_in")), boss.position + Vector3(cos(a), 0, sin(a)) * r * 0.8, 0.8, 0.6)

		Vfx.converge(world.fx_root, boss.position, r, Color(color.lightened(0.4), 0.6), 0.5)
	o.tick = float(o.tick) - delta


	if o.tick <= 0.0:
		o.tick = 0.5
		if k >= float(ab.get("dmg_from", 0.0)):
			for h in party:
				if _flat(h.position, boss.position) < r:



					_hit_tick(float(ab.pct), h)
	if o.t <= 0.0:
		Vfx.strike_circle(world.fx_root, boss.position, r, color)
		_fade(node, 0.3)
		return true
	return false













func head_timer(h: Player, node: Node3D, col: Color, seal: = 0.0, seal_col: = Color.WHITE, seal_spin: = 1.8) -> Dictionary:
	var sigil: = _make_brand(node, col, seal, seal_col, seal_spin)
	var ref: = _ref(h)
	if not ref.is_empty() and node.get_parent() == h:
		_reg(node, ["brand", ref, col, seal, seal_col, seal_spin])
	var lbl: = _label(h, "", Color(1.0, 0.92, 0.85), 4.0, 54)
	lbl.outline_modulate = Color(col.darkened(0.6), 1.0)
	return {"sigil": sigil, "label": lbl}




func _make_brand(node: Node3D, col: Color, seal: float, seal_col: Color, seal_spin: float) -> Sprite3D:
	if seal > 0.0:
		Vfx.magic_circle(node, Vector3.ZERO, seal, seal_col, 0.0, "mvp_seal", seal_spin, Vfx.DANGER_PRIORITY, true)
	var sigil: = Sprite3D.new()
	sigil.texture = RoAssets.effect_tex("mvp_hexa")
	sigil.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sigil.no_depth_test = true
	sigil.render_priority = 18


	sigil.pixel_size = 0.012



	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED


	m.billboard_keep_scale = true
	m.vertex_color_is_srgb = true
	m.no_depth_test = true
	m.albedo_texture = sigil.texture
	m.vertex_color_use_as_albedo = true
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.render_priority = 18
	sigil.material_override = m
	sigil.modulate = Color(col.lightened(0.1), 1.0)
	sigil.position = Vector3(0, 4.0, 0)
	node.add_child(sigil)
	node.set_meta("sigil", sigil)
	return sigil


func head_timer_tick(sigil: Sprite3D, lbl: Label3D, left: float, delta: float) -> void :
	var t: = maxf(0.0, left)



	_set_text(lbl, str(roundi(t)))


	var beat: = fposmod(t + 0.5, 1.0)
	var hurry: = t < 1.5
	if is_instance_valid(lbl):
		lbl.scale = Vector3.ONE * (1.0 + 0.45 * pow(beat, 4.0))
		lbl.modulate = Color(1.0, 0.3, 0.25) if hurry else Color(1.0, 0.92, 0.85)
	if is_instance_valid(sigil):
		sigil.rotation.z += delta * (6.0 if hurry else 2.0)
		sigil.scale = Vector3.ONE * (1.0 + 0.15 * sin(t * 9.0))


func _brand_start(ab: Dictionary) -> void :
	var party: = _standing()
	party.shuffle()
	var col: Color = ab.get("tint", color)
	world.play_sound("lex_aeterna", 0.0, -2.0)
	for h in party.slice(0, clampi(int(ab.get("count", 1)), 1, maxi(1, party.size()))):
		var node: = Node3D.new()
		h.add_child(node)
		var head: = head_timer(h, node, col, float(ab.size), Color(col, 0.8), 1.8)
		world.spawn_fx("devil", h.position, 0.8, 0.8, h)
		world.emote(h, "sweat", 1.5)
		warn_hero(h, UiKit.tr_later("¡Te marcó! Lleva la marca lejos y deja el charco en el borde"), Color(1, 0.35, 0.3), "warning")
		_objects.append({"kind": "brand", "ab": ab, "hero": h, "t": float(ab.time), "total": float(ab.time), "node": node, 
			"label": head.label, "sigil": head.sigil, "show": str(ab.name)})


func _brand_update(o: Dictionary, delta: float) -> bool:
	var ab: Dictionary = o.ab
	var h: Player = o.hero
	o.t -= delta
	if not is_instance_valid(h) or h.downed:
		for key in ["node", "label"]:
			if is_instance_valid(o[key]):
				o[key].queue_free()
		return true
	head_timer_tick(o.sigil, o.label, float(o.t), delta)
	if o.t > 0.0:
		return false

	var at: = h.position
	var col: Color = ab.get("tint", color)
	Vfx.strike_circle(world.fx_root, at, float(ab.size), col)
	world.spawn_fx(str(ab.get("fx", "hell_in")), at, 1.2, 0.7)
	world.play_sound("meteor", 0.1, -6.0)
	var z: = _zone(at, float(ab.size), col, str(ab.get("pool_fx", "")), 0.8)

	_objects.append({"kind": "puddle", "ab": ab, "pos": at, "node": z, "t": 1000000000.0, "tick": GameData.RAID_BRAND_GRACE})
	for key in ["node", "label"]:
		if is_instance_valid(o[key]):
			o[key].queue_free()
	return true


func _spoke_count(ab: Dictionary) -> int:
	return int(ab.get("count_last", ab.count)) if phase >= data.phases.size() - 1 else int(ab.count)


func _spokes_tell(from: Vector3, base: float, count: int, width: float, t: float) -> Array:
	var tells: = []
	for i in count:
		var a: = base + TAU * i / float(count)
		tells.append(Vfx.telegraph_line(world.fx_root, from, Vector3(cos(a), 0, sin(a)), radius * 2.2, width, t))
	return tells


func _spokes_hit(from: Vector3, base: float, ab: Dictionary) -> void :
	var count: = _spoke_count(ab)
	world.play_sound(str(ab.get("sound", "meteor")), 0.1, -4.0)
	world.shake(0.4)
	var col: = _strike_color(ab)
	for i in count:
		var a: = base + TAU * i / float(count)
		var dir: = Vector3(cos(a), 0, sin(a))


		Vfx.strike_line(world.fx_root, from, dir, radius * 2.2, float(ab.width), col)
		_fx_along(str(ab.get("fx", "firepillar")), from + dir * 1.5, dir, _edge_dist(from + dir * 1.5, dir), 1.8)
	for h in _standing():
		var to: = (h.position - from) * Vector3(1, 0, 1)
		for i in count:
			var a: = base + TAU * i / float(count)
			var dir: = Vector3(cos(a), 0, sin(a))
			if to.dot(dir) > 0.0 and absf(to.cross(dir).y) < float(ab.width) * 0.5 + 0.3:
				_hit_dmg(float(ab.dmg), h)
				break



func _wall_start(ab: Dictionary, n: int) -> void :
	var d: = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
	var side: = Vector3( - d.z, 0, d.x)
	var gap: = randf_range( - radius * 0.6, radius * 0.6)
	var gap_w: = float(ab.gap)
	var start: = center - d * radius
	var node: = _make_wall(start, d, gap, gap_w, Color(ab.get("color", color)))
	_reg(node, ["wall", start, d, gap, gap_w, Color(ab.get("color", color))])
	if n > 0:
		_warn(str(ab.name), Color(1, 0.35, 0.3))
	var lead: = float(ab.get("lead", 1.4))
	var move: = radius * 2.0 / float(ab.speed)
	_objects.append({"kind": "wall", "solo": true, "ab": ab, "n": n, "d": d, "side": side, "gap": gap, "gap_w": gap_w, "start": start, 
		"node": node, "t": lead + move, "total_move": move, "hit": [], "fx": 0.0, "show": "%s %d/%d" % [tr(str(ab.name)), n + 1, int(ab.count)], 
		"total": lead + move})


func _make_wall(start: Vector3, d: Vector3, gap: float, gap_w: float, col: Color) -> Node3D:
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.global_position = Vector3(start.x, center.y, start.z)
	root.global_basis = Basis.looking_at(d, Vector3.UP)


	var left: = - radius - 1.0
	var right: = radius + 1.0
	for seg in [[left, gap - gap_w * 0.5], [gap + gap_w * 0.5, right]]:
		var w: float = float(seg[1]) - float(seg[0])
		if w <= 0.0:
			continue
		var mid: = (float(seg[0]) + float(seg[1])) * 0.5









		var water: = _energy_quad(root, Vector2(w, 5.5), Vector3(mid, 0.11, 2.2), PlaneMesh.FACE_Y, Color(col, 0.85), 1.0, false)
		water.material_override.set_shader_parameter("wave", 1.0)
		_energy_quad(root, Vector2(w, 1.6), Vector3(mid, 0.8, -0.2), PlaneMesh.FACE_Z, Color(col.lightened(0.3), 0.4), 1.4)



	var safe: = _glow_quad(root, Vector2(gap_w * 1.1, gap_w * 1.1), Vector3(gap, 0.08, 0.4), PlaneMesh.FACE_Y, RoAssets.radial(Color.WHITE, 128), 
		Color(0.45, 1.0, 0.55, 0.8))
	safe.name = "Gap"
	for side in [-1.0, 1.0]:
		var post: = Sprite3D.new()
		post.texture = Vfx.beam_texture()
		post.flip_v = true
		post.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		post.shaded = false
		post.centered = false
		post.offset = Vector2(-32, 0)
		post.pixel_size = 0.9 / 64.0
		post.scale = Vector3(1, 2.4, 1)
		post.no_depth_test = true
		post.render_priority = Vfx.DANGER_PRIORITY
		post.modulate = Color(0.85, 1.0, 0.9, 0.95)
		post.position = Vector3(gap + side * gap_w * 0.5, 0.0, -0.3)
		root.add_child(post)
		_glow_quad(root, Vector2(1.4, 1.4), Vector3(gap + side * gap_w * 0.5, 0.11, -0.3), PlaneMesh.FACE_Y, Vfx.blast_texture(), 
			Color(0.6, 1.0, 0.7, 0.6))
	return root




func _tower_beam(z: Node3D, size: float) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = Vfx.beam_texture()
	s.flip_v = true
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.shaded = false
	s.centered = false
	s.offset = Vector2(-32, 0)
	s.pixel_size = size * 1.4 / 64.0
	s.scale = Vector3(1, 3.0, 1)
	s.render_priority = Vfx.DANGER_PRIORITY
	s.modulate = Color(1.0, 0.85, 0.4, 0.9)
	s.set_meta("tower", true)
	z.add_child(s)
	return s



func _tower_pulse(beam: Sprite3D) -> void :
	var held: = bool(beam.get_meta("held", false))
	var pulse: = 0.7 + 0.3 * sin(Time.get_ticks_msec() * (0.006 if held else 0.016))
	beam.modulate = Color(0.55, 1.0, 0.6, 0.8 * pulse) if held else Color(1.0, 0.85, 0.4, 0.9 * pulse)



func _energy_quad(parent: Node3D, size: Vector2, at: Vector3, face: int, col: Color, flow: = 1.0, curtain: = true) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	q.orientation = face
	q.size = size
	mi.mesh = q
	mi.material_override = Vfx.energy_material(col, curtain, flow, false, size)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = at
	parent.add_child(mi)
	return mi


func _make_beam(from: Vector3, a: float, length: float, width: float, col: Color, alpha: = 1.0) -> Node3D:
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.global_position = Vector3(from.x, from.y + 0.1, from.z)

	_glow_quad(root, Vector2(width * 1.5, length), Vector3(0, 0, - length * 0.5), PlaneMesh.FACE_Y, _grad_tex("across"), 
		Color(col, 0.75 * alpha))
	_glow_quad(root, Vector2(width * 0.45, length), Vector3(0, 0.01, - length * 0.5), PlaneMesh.FACE_Y, _grad_tex("across"), 
		Color(col.lightened(0.75), 0.95 * alpha))
	for side in [-1.0, 1.0]:
		_glow_quad(root, Vector2(0.14, length), Vector3(side * width * 0.5, 0.02, - length * 0.5), PlaneMesh.FACE_Y, 
			_grad_tex("across"), Color(col.lightened(0.5), 0.9 * alpha))


	if alpha >= 1.0:
		_energy_quad(root, Vector2(length, 2.6), Vector3(0, 1.3, - length * 0.5), PlaneMesh.FACE_X, Color(col.lightened(0.3), 0.8), 2.2)
		_energy_quad(root, Vector2(length, width * 1.2), Vector3(0, 0.03, - length * 0.5), PlaneMesh.FACE_Y, Color(col, 0.6), 3.0, false)
		_glow_quad(root, Vector2(4.0, 4.0), Vector3(0, 0.12, 0), PlaneMesh.FACE_Y, Vfx.blast_texture(), Color(col.lightened(0.5), 0.8))
	root.rotation.y = - a - PI * 0.5
	return root



func _beam_ghost(from: Vector3, a: float, length: float, width: float, col: Color) -> void :
	var g: = _make_beam(from, a, length, width, col, 0.45)
	var tw: = g.create_tween().set_parallel()
	for mi in g.get_children():
		var mat = (mi as MeshInstance3D).material_override
		if mat is StandardMaterial3D:
			tw.tween_property(mat, "albedo_color:a", 0.0, 0.35)
		elif mat is ShaderMaterial:
			tw.tween_method( func(v: float): mat.set_shader_parameter("alpha", v), 1.0, 0.0, 0.35)
	tw.chain().tween_callback(g.queue_free)




func _glow_quad(parent: Node3D, size: Vector2, at: Vector3, face: int, tex: Texture2D, col: Color) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	q.orientation = face
	q.size = size
	mi.mesh = q
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.render_priority = Vfx.DANGER_PRIORITY
	mat.albedo_texture = tex
	mat.albedo_color = col
	mi.material_override = mat
	mi.position = at
	parent.add_child(mi)
	return mi





static var _grads: = {}
static func _grad_tex(kind: String) -> Texture2D:
	if _grads.has(kind):
		return _grads[kind]
	var g: = Gradient.new()
	var t: = GradientTexture2D.new()
	t.width = 64
	t.height = 64
	match kind:
		"across", "across_v":
			g.offsets = PackedFloat32Array([0.0, 0.35, 0.5, 0.65, 1.0])
			g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.55), Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
			t.fill_from = Vector2(0, 0)
			t.fill_to = Vector2(1, 0) if kind == "across" else Vector2(0, 1)
		"band":
			g.offsets = PackedFloat32Array([0.0, 0.12, 0.3, 1.0])
			g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0.6), Color(1, 1, 1, 0)])
			t.fill_from = Vector2(0, 0)
			t.fill_to = Vector2(0, 1)
		"up":
			g.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
			g.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.45), Color(1, 1, 1, 1)])
			t.fill_from = Vector2(0, 0)
			t.fill_to = Vector2(0, 1)
	t.gradient = g
	_grads[kind] = t
	return t



func _clock_tell(o: Dictionary, i: int) -> void :
	if i >= 12:
		return
	var tells: = []
	for k in int(o.hands):
		var a: = float(o.a0) + TAU * (i / 12.0 + k * 0.5)
		tells.append(Vfx.telegraph_cone(world.fx_root, o.at, Vector3(cos(a), 0, sin(a)), radius * 1.3, TAU / 12.0 + 0.05, 
			float(o.ab.step) * (2.0 if i > int(o.i) else 1.0)))
	o.tells[i] = tells




func _clock_face(at: Vector3, a0: float) -> Node3D:
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.global_position = Vector3(at.x, at.y + 0.1, at.z)
	var r: = radius * 1.3
	Vfx.magic_circle(root, Vector3.ZERO, r * 0.35, Color(color.lightened(0.3), 0.7), 0.0, "mvp_hexa", 0.8, Vfx.DANGER_PRIORITY, true)
	_glow_quad(root, Vector2(r * 2.0, r * 2.0), Vector3.ZERO, PlaneMesh.FACE_Y, Vfx.ring_texture(), Color(color.lightened(0.2), 0.55))
	for i in 12:
		var a: = a0 + TAU * i / 12.0
		var mark: = _glow_quad(root, Vector2(1.6, 1.6), Vector3(cos(a), 0, sin(a)) * (r - 0.9), PlaneMesh.FACE_Y, Vfx.blast_texture(), 
			Color(color.lightened(0.4), 0.45))
		mark.name = "Hour%d" % i
	return root


func _light_hour(face: Node3D, i: int, hands: int) -> void :
	for k in hands:
		var mark: = face.get_node_or_null("Hour%d" % ((i + k * 6) % 12)) as MeshInstance3D
		if mark != null:
			(mark.material_override as StandardMaterial3D).albedo_color = Color(1.0, 0.95, 0.8, 1.0)
			mark.scale = Vector3.ONE * 1.6


func _clock_hit(o: Dictionary, i: int) -> void :
	world.play_sound("stun", 0.05, -8.0)

	var face: Node3D = o.get("face")
	if face != null and is_instance_valid(face):
		_light_hour(face, i, int(o.hands))
		if face.has_meta("raid_id"):
			_net(["hour", int(face.get_meta("raid_id")), i, int(o.hands)])
	_drop_tells(o.tells.get(i, []))
	o.tells.erase(i)
	for k in int(o.hands):
		var a: = float(o.a0) + TAU * (i / 12.0 + k * 0.5)
		var dir: = Vector3(cos(a), 0, sin(a))
		Vfx.strike_cone(world.fx_root, o.at, dir, radius * 1.3, TAU / 12.0 + 0.05, _strike_color(o.ab))
		for r in [3.0, 6.0, 9.0]:
			world.spawn_fx(str(o.ab.get("fx", "")), (o.at as Vector3) + dir * r, 0.8, 0.6)
		for h in _standing():
			var rel: = (h.position - (o.at as Vector3)) * Vector3(1, 0, 1)
			if rel.length() > 0.5 and absf(dir.signed_angle_to(rel.normalized(), Vector3.UP)) < TAU / 24.0 + 0.03:
				_hit_dmg(float(o.ab.dmg), h)



const WAVE_TELL_DELAY: = 0.2




func _later(t: float, f: Callable) -> void :
	get_tree().create_timer(t, false).timeout.connect( func():
		if active():
			world.fx_layer(GameData.MVP_FX_PRIORITY)
			f.call()
			world.fx_layer(0))



func _drop_tells(tells) -> void :
	for n in tells:
		if n != null and is_instance_valid(n):
			n.queue_free()




const STRIKE_COLORS: = {"fire": Color(1.0, 0.45, 0.15), "ice": Color(0.55, 0.85, 1.0), "holy": Color(1.0, 0.92, 0.6), 
	"thunder": Color(0.75, 0.8, 1.0), "poison": Color(0.55, 0.95, 0.3), "dark": Color(0.7, 0.3, 1.0), 
	"earth": Color(0.95, 0.7, 0.35), "steel": Color(0.85, 0.9, 1.0)}
const STRIKE_FX: = {"firepillar": "fire", "firehit1": "fire", "fire_pillar": "fire", "stormgust": "ice", "frost_diver": "ice", 
	"holyhit": "holy", "holy_cross": "holy", "angelus": "holy", "lightning": "thunder", "thunder": "thunder", 
	"poisonzone": "poison", "hell_in": "dark", "curse": "dark", "earthhit": "earth", "quagmire": "earth", 
	"earth_quake": "earth", "pierce": "steel", "brandish": "steel", "stun": "steel"}


func _strike_color(ab: Dictionary) -> Color:
	if ab.has("color"):
		return Color(ab.color)
	var kind: = str(STRIKE_FX.get(str(ab.get("fx", "")), STRIKE_FX.get(str(ab.get("sound", "")), "")))
	return STRIKE_COLORS.get(kind, color.lightened(0.2))



func _edge_dist(at: Vector3, dir: Vector3) -> float:
	var rel: = (at - center) * Vector3(1, 0, 1)
	var b: = rel.dot(dir)
	return maxf(0.0, - b + sqrt(maxf(0.0, b * b - rel.length_squared() + radius * radius)))




func _fx_along(fx: String, from: Vector3, dir: Vector3, length: float, every: float, delay: = 0.0) -> void :
	var step: = 0.0
	while step <= length:
		var at: = from + dir * step
		var wait: = delay + step * 0.012
		if wait <= 0.0:
			world.spawn_fx(fx, at, 0.85, 0.75)
		else:
			_later(wait, func(): world.spawn_fx(fx, at, 0.85, 0.75))
		step += every



func _volley_lanes(ab: Dictionary) -> Array:
	var w: = float(ab.width)
	var out: = []
	var o: = - radius + w * 0.5
	while o < radius:
		out.append(o)
		o += w
	return out


func _volley_tell(d: Vector3, lanes: Array, ab: Dictionary, t: float) -> Array:
	var side: = Vector3( - d.z, 0, d.x)
	var tells: = []
	for off in lanes:
		tells.append(Vfx.telegraph_line(world.fx_root, center - d * radius + side * float(off), d, radius * 2.0, float(ab.width) * 0.92, t))
	return tells


func _volley_hit(d: Vector3, lanes: Array, ab: Dictionary) -> void :
	var side: = Vector3( - d.z, 0, d.x)
	world.play_sound(str(ab.get("sound", "meteor")), 0.1, -4.0)
	var col: = _strike_color(ab)
	for off in lanes:
		var from: = center - d * radius + side * float(off)

		var delay: = randf_range(0.0, 0.12)
		Vfx.strike_line(world.fx_root, from, d, radius * 2.0, float(ab.width) * 0.8, col, delay)
		_fx_along(str(ab.get("fx", "pierce")), from + d * 1.5, d, radius * 2.0 - 3.0, 2.4, delay)
	for h in _standing():
		var rel: = (h.position - center) * Vector3(1, 0, 1)
		var off_h: = rel.dot(side)
		for off in lanes:
			if absf(off_h - float(off)) < float(ab.width) * 0.5:
				_hit_dmg(float(ab.dmg), h)
				break



func _make_chains(at: Vector3, slots: Array, reach: float) -> Node3D:
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.set_meta("slots", slots)
	root.set_meta("at", at)
	root.set_meta("reach", reach)
	for s in slots:
		var mi: = MeshInstance3D.new()
		var q: = QuadMesh.new()
		q.size = Vector2(0.7, 1.0)
		q.orientation = PlaneMesh.FACE_Y
		q.center_offset = Vector3(0, 0, -0.5)
		mi.mesh = q
		var mat: = StandardMaterial3D.new()

		mat.albedo_texture = _chain_tex()
		mat.texture_repeat = true
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.no_depth_test = true
		mat.render_priority = Vfx.DANGER_PRIORITY
		mat.albedo_color = Color(color.lightened(0.3), 0.85)
		mi.material_override = mat
		mi.set_meta("slot", int(s))
		root.add_child(mi)
	return root


func _aim_chains(root: Node3D, at: Vector3, reach: float) -> void :
	if root == null or not is_instance_valid(root):
		return
	for mi in root.get_children():
		var slot: = int(mi.get_meta("slot", -1))
		if slot < 0 or slot >= world.heroes.size():
			continue
		var h: Player = world.heroes[slot]
		var to: = (h.position - at) * Vector3(1, 0, 1)
		mi.visible = not h.downed and to.length() > 0.2
		if not mi.visible:
			continue
		mi.global_position = Vector3(at.x, world.map.height_at(at) + 0.6, at.z)
		mi.global_basis = Basis.looking_at(to.normalized(), Vector3.UP) * Basis.from_scale(Vector3(1, 1, to.length()))
		var far: = to.length() > reach
		var mat: = mi.material_override as StandardMaterial3D
		mat.uv1_scale = Vector3(1, to.length() / 1.1, 1)

		var beat: = 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.012)
		mat.albedo_color = Color(1.0, 0.3, 0.2, beat) if far else Color(color.lightened(0.5), 1.0)



static var _chain_img: Texture2D
static func _chain_tex() -> Texture2D:
	if _chain_img != null:
		return _chain_img
	var w: = 32
	var h: = 64
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var a: = 0.0

			var dx: = (x + 0.5 - 16.0) / 11.0
			var dy: = (y + 0.5 - 18.0) / 17.0
			var d: = sqrt(dx * dx + dy * dy)
			a = maxf(a, clampf(1.0 - absf(d - 0.74) * 3.5, 0.0, 1.0))

			if absf(x + 0.5 - 16.0) < 4.5 and y >= 32 and y < 62:
				a = maxf(a, 1.0 - absf(x + 0.5 - 16.0) / 4.5)
			img.set_pixel(x, y, Color(1, 1, 1, a))
	_chain_img = ImageTexture.create_from_image(img)
	return _chain_img



func to_center() -> void :
	if _flat(boss.position, center) < 1.2:
		return
	Vfx.column(world.fx_root, boss.position, color)
	boss.position = Vector3(center.x, world.map.height_at(center), center.z)
	Vfx.column(world.fx_root, boss.position, color)
	Vfx.ring(world.fx_root, boss.position, 3.0, color.lightened(0.3), 0.4)
	world.play_sound("teleport", 0.1, -8.0)



func _extra_goal(p: Player) -> Vector3:
	var own: Vector3 = trials.goal(p)
	if own != Vector3.INF:
		return own
	if not _cast.is_empty():
		match str(_cast.ab.mech):
			"spokes":
				return _between_spokes(_cast["from"], float(_cast.base) + PI / float(_spoke_count(_cast.ab)), _spoke_count(_cast.ab), p)
			"sweep":
				var back: = float(_cast.a0) + PI
				return boss.position + Vector3(cos(back), 0, sin(back)) * 3.0
			"puddles":
				for t in _cast.targets:
					if _flat(p.position, t) < float(_cast.ab.size) + 0.5:
						return p.position + _dir(t, p.position) * 3.0
			"volley":
				var side: = Vector3( - _cast.d.z, 0, _cast.d.x)
				var lanes: Array = _cast.next
				if not lanes.is_empty():
					var best: = float(lanes[0])
					var rel: = (p.position - center).dot(side)
					for off in lanes:
						if absf(float(off) - rel) < absf(best - rel):
							best = float(off)
					return p.position + side * (best - rel)
	for o in _objects:
		match str(o.kind):
			"spoke_wave":
				return _between_spokes(o["from"], float(o.base) + PI / float(_spoke_count(o.ab)), _spoke_count(o.ab), p)
			"volley_wave":
				var side: = Vector3( - o.d.z, 0, o.d.x)
				var rel: = (p.position - center).dot(side)
				var lanes: = _volley_lanes(o.ab)
				var best: = 999.0
				for off in lanes:
					if not (o.lanes as Array).has(off) and absf(float(off) - rel) < absf(best - rel):
						best = float(off)
				return p.position + side * (best - rel)
			"wall":
				var rel: = (p.position - center) * Vector3(1, 0, 1)
				return p.position + (o.side as Vector3) * (float(o.gap) - rel.dot(o.side))
			"sweep":
				var back: = float(o.a) - signf(float(o.spin)) * 1.2
				return boss.position + Vector3(cos(back), 0, sin(back)) * 3.5
			"clock":
				var a: = float(o.a0) + TAU * (maxi(0, int(o.i) - 1) + 0.5) / 12.0
				return (o.at as Vector3) + Vector3(cos(a), 0, sin(a)) * 4.0
			"still":
				if o.move:
					return p.position
				return p.position + Vector3(cos(world.time * 2.0), 0, sin(world.time * 2.0)) * 2.0
			"towers":

				var spots: Array = o.spots
				return spots[p.slot % spots.size()].pos if p != world.player or spots.size() == 1 else _nearest(spots.map( func(s): return s.pos))
			"tether":
				if _flat(p.position, o.pos) > float(o.ab.range) * 0.7:
					return o.pos
			"puddle":
				if _flat(p.position, o.pos) < float(o.ab.size) + 0.5:
					return p.position + _dir(o.pos, p.position) * 3.0
			"brand":
				if o.hero == p:
					return center + _dir(center, p.position) * radius * 0.85
			"vortex":
				return boss.position + _dir(boss.position, p.position) * (float(o.ab.size) + 2.0)
	return Vector3.INF


func _between_spokes(from: Vector3, base: float, count: int, p: Player) -> Vector3:
	var best: = Vector3.INF
	for i in count:
		var a: = base + TAU * i / float(count)
		var at: = from + Vector3(cos(a), 0, sin(a)) * 4.5
		if _flat(at, center) > radius - 1.0:
			continue
		if best == Vector3.INF or _flat(at, p.position) < _flat(best, p.position):
			best = at
	return best




func _clamp_all() -> void :
	for h in world.heroes:
		_clamp(h, radius)
	for e in world.enemies:
		_clamp(e, radius)

	for pl in _pillars:
		for h in world.heroes:
			var d: Vector3 = (h.position - pl.pos) * Vector3(1, 0, 1)
			if d.length() < 0.8 and d.length() > 0.001:
				var at: Vector3 = pl.pos + d.normalized() * 0.8
				h.position = Vector3(at.x, world.map.height_at(at), at.z)


func _clamp(n: Node3D, r: float) -> void :
	var d: = (n.position - center) * Vector3(1, 0, 1)
	if d.length() > r:
		var at: = center + d.normalized() * r


		var k: = r
		while k > 0.5 and not world.map.is_walkable(at):
			k -= 0.5
			at = center + d.normalized() * k
		n.position = Vector3(at.x, world.map.height_at(at), at.z)




func _arena_point(frac: float, away: = Vector3.INF, min_d: = 0.0, i: = -1, n: = 1) -> Vector3:
	var best: = center
	for tries in 20:
		var a: = (TAU * (i + randf_range(-0.15, 0.15)) / float(n)) if i >= 0 else randf() * TAU
		var r: = radius * frac * (randf_range(0.5, 1.0) if i < 0 else 1.0)
		var at: = center + Vector3(cos(a), 0, sin(a)) * r
		if not world.map.is_walkable(at):
			continue
		best = at
		if away == Vector3.INF or _flat(at, away) >= min_d:
			break
	best.y = world.map.height_at(best)
	return best



func _blocks(pillar: Vector3, from: Vector3, to: Vector3) -> bool:
	var a: = Vector2(from.x, from.z)
	var b: = Vector2(to.x, to.z)
	var c: = Vector2(pillar.x, pillar.z)
	var ab: = b - a
	var t: = clampf((c - a).dot(ab) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
	return t > 0.05 and t < 1.0 and (a + ab * t).distance_to(c) < 1.1



func _cover_shadow(at: Vector3, dir: Vector3) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	q.size = Vector2(1.8, 5.0)
	q.orientation = PlaneMesh.FACE_Y
	q.center_offset = Vector3(0, 0, -2.6)
	mi.mesh = q
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(0.45, 1.0, 0.6, 0.0)
	mat.render_priority = Vfx.DANGER_PRIORITY
	mi.material_override = mat
	world.fx_root.add_child(mi)
	_reg(mi, ["shadow", at, dir])
	dir.y = 0.0
	mi.global_position = Vector3(at.x, world.map.height_at(at) + 0.1, at.z)
	if dir.length_squared() > 0.001:
		mi.global_basis = Basis.looking_at(dir.normalized(), Vector3.UP)
	mi.create_tween().tween_property(mat, "albedo_color:a", 0.38, 0.4)
	return mi




func _zone(at: Vector3, r: float, col: Color, fx: String, fx_size: = 1.0, flat_ice: = false) -> Node3D:
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	var disc: = Vfx._flat(node, Vfx.disc_texture(), Vector3.ZERO, r, Color(col, 0.55 if flat_ice else 0.22))
	var edge: = Vfx._flat(node, Vfx.ring_texture(), Vector3.ZERO, r, Color(col, 0.75))


	for f in [disc, edge]:
		f.no_depth_test = true
		f.render_priority = GameData.MVP_UNDER_PRIORITY
	var tw: = disc.create_tween().set_loops()
	tw.tween_property(disc, "modulate:a", 0.1 if not flat_ice else 0.45, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(disc, "modulate:a", 0.24 if not flat_ice else 0.6, 0.7).set_trans(Tween.TRANS_SINE)
	if not flat_ice:
		Vfx.magic_circle(node, Vector3.ZERO, r * 0.95, Color(col, 0.22), 0.0, "mvp_rune", 0.5, GameData.MVP_UNDER_PRIORITY, true)


	if not flat_ice:
		var swirl: = MeshInstance3D.new()
		var plane: = PlaneMesh.new()
		plane.size = Vector2.ONE * r * 2.0
		swirl.mesh = plane
		var mat: = Vfx.energy_material(Color(col, 0.2), false, 0.5, true)
		mat.render_priority = GameData.MVP_UNDER_PRIORITY
		swirl.material_override = mat
		swirl.position = Vector3(0, 0.08, 0)
		node.add_child(swirl)
	if fx != "":



		var was: = RoEffect.layer
		RoEffect.layer = GameData.MVP_UNDER_PRIORITY
		var look: = RoEffect.spawn(node, fx, node.global_position, fx_size)
		if look != null:
			look.intensity = 0.45
		RoEffect.layer = was
	node.scale = Vector3.ONE * 0.2
	node.create_tween().tween_property(node, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reg(node, ["zone", at, r, col, fx, fx_size, flat_ice])
	if flat_ice:
		_ice_zones.append({"node": node, "pos": at, "r": r})
	return node



func _hint_line() -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	q.size = Vector2(0.18, 1.0)
	q.orientation = PlaneMesh.FACE_Y
	q.center_offset = Vector3(0, 0, -0.5)
	mi.mesh = q
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(color.lightened(0.4), 0.6)
	mi.material_override = mat
	world.fx_root.add_child(mi)
	_reg(mi, ["line"])
	return mi


func _aim_line(line: MeshInstance3D, from: Vector3, to: Vector3) -> void :
	if not is_instance_valid(line):
		return
	var d: = (to - from) * Vector3(1, 0, 1)
	if d.length() < 0.1:
		return
	line.global_position = Vector3(from.x, world.map.height_at(from) + 0.12, from.z)
	line.global_basis = Basis.looking_at(d.normalized(), Vector3.UP) * Basis.from_scale(Vector3(1, 1, d.length()))



func _shout(node: Node3D, text: String, col: = SHOUT_COLOR) -> void :
	if node == null or not is_instance_valid(node):
		return
	_net(["shout", _ref(node), text, col])
	var l: = _make_label(node, text, col, 3.4, 44)
	var tw: = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y + 0.5, 0.25).set_ease(Tween.EASE_OUT)
	tw.tween_interval(1.4)
	tw.tween_property(l, "modulate:a", 0.0, 0.4)
	tw.tween_callback(l.queue_free)





func arena_title() -> String:
	if data.has("hel_title") and world.tower != null and world.tower.hel != null:
		return tr(str(data.hel_title))
	return tr(str(data.get("title", "")))


func _chat(node: Node3D, text: String, col: = CHAT_COLOR) -> void :
	if text == "" or node == null or not is_instance_valid(node):
		return
	_net(["chat", _ref(node), text, col])
	var line: = text
	if node is Enemy:
		line = tr("%s : %s") % [tr(str(node.def.name)), text]
	var l: = _make_label(node, line, col, 4.4, 30)

	if line.length() > 44:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.width = 560.0

	var said: = 0
	for c in node.get_children():
		if c != l and c.has_meta("chat_line") and is_instance_valid(c):
			said += 1
	l.set_meta("chat_line", true)
	l.position.y += 0.45 * said
	var tw: = l.create_tween()
	tw.tween_interval(3.2)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)




func _label(node: Node3D, text: String, col: Color, height: float, size: = 32, outline: = true) -> Label3D:
	var l: = _make_label(node, text, col, height, size, outline)
	var ref: = _ref(node)
	if not ref.is_empty():
		_reg(l, ["label", ref, text, col, height, size, outline])
	return l


func _make_label(node: Node3D, text: String, col: Color, height: float, size: = 32, outline: = true) -> Label3D:
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

	if node is Enemy and (node as Enemy).def.get("mvp", false):
		height *= GameData.MVP_SCALE
	l.position = Vector3(0, height, 0)
	node.add_child(l)
	return l


func _set_text(l: Label3D, text: String) -> void :
	if l == null or not is_instance_valid(l) or l.text == text:
		return
	l.text = text
	if l.has_meta("raid_id"):
		_net(["text", int(l.get_meta("raid_id")), text])


func _fade(node, t: float) -> void :
	if node == null or not is_instance_valid(node):
		return
	if node is Node and (node as Node).has_meta("raid_id"):
		_net(["fade", int(node.get_meta("raid_id")), t])
	var tw: Tween = node.create_tween()
	if node is Node3D:
		tw.tween_property(node, "scale", node.scale * 0.01, t)
	tw.tween_callback(node.queue_free)


func _cursed() -> bool:
	return not curses.is_empty()


func _nearest_hero(at: Vector3, party: Array[Player]) -> Player:
	var best: Player = party[0]
	for h in party:
		if _flat(h.position, at) < _flat(best.position, at):
			best = h
	return best


func _nearest(points: Array) -> Vector3:
	var best: = Vector3.INF
	for pt in points:
		if best == Vector3.INF or _flat(world.player.position, pt) < _flat(world.player.position, best):
			best = pt
	return best


func _dir(from: Vector3, to: Vector3) -> Vector3:
	var d: = (to - from) * Vector3(1, 0, 1)
	return d.normalized() if d.length_squared() > 0.0001 else Vector3(0, 0, 1)


func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
