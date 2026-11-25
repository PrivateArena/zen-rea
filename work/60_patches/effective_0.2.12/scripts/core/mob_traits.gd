extends RefCounted















const NONE: = 0
const GLUTTON: = 1
const CHARGE: = 2
const RISE: = 3
const SWARM: = 4
const GHOST: = 5
const WARBAND: = 6
const SHELL: = 7
const BLAST: = 8
const ROOT: = 9



const OF: = {
	"poring": GLUTTON, "poporing": GLUTTON, "smokie": GLUTTON, "mystcase": GLUTTON, "magmaring": GLUTTON, 
	"wolf": CHARGE, "bigfoot": CHARGE, "hell_poodle": CHARGE, "matyr": CHARGE, "minorous": CHARGE, 
	"garm_baby": CHARGE, "baphomet_jr": CHARGE, "vanberk": CHARGE, 
	"zombie": RISE, "ghoul": RISE, "mummy": RISE, "orc_zombie": RISE, "ragged_zombie": RISE, 
	"zombie_slaughter": RISE, "munak": RISE, "bon_gun": RISE, 
	"thief_bug": SWARM, "tarou": SWARM, "cramp": SWARM, "andre": SWARM, "piere": SWARM, "deniro": SWARM, 
	"kukre": SWARM, "hornet": SWARM, "steel_chocho": SWARM, "hunter_fly": SWARM, "drainliar": SWARM, 
	"rideword": SWARM, "punk": SWARM, 
	"whisper": GHOST, "quve": GHOST, "flame_skull": GHOST, "wraith": GHOST, "banshee": GHOST, "horong": GHOST, 
	"blazer": GHOST, "hodremlin": GHOST, 
	"orc_baby": WARBAND, "ork_warrior": WARBAND, "orc_lady": WARBAND, "orc_archer": WARBAND, "zenorc": WARBAND, 
	"solider": SHELL, "permeter": SHELL, "freezer": SHELL, "heater": SHELL, "vadon": SHELL, 
	"venatu": BLAST, "venatu_1": BLAST, "dimik": BLAST, "dimik_1": BLAST, "alarm": BLAST, "clock": BLAST, 
	"cruiser": BLAST, "explosion": BLAST, 
	"hydra": ROOT, "iceicle": ROOT, 
}


const LOOK_PLAIN: = 0
const LOOK_GHOST: = 1
const LOOK_RISEN: = 2
const LOOK_RALLY: = 3

const LOOK_TINT: = [Color.WHITE, Color(0.8, 0.92, 1.0, 0.6), Color(0.52, 0.62, 0.5), Color(1.0, 0.78, 0.74)]



const GLUTTON_LOOK: = 0.5
const GLUTTON_REACH: = 4.5
const GLUTTON_MAX: = 5
const GLUTTON_GROW: = 0.14
const GLUTTON_BACK: = 1.5
const GLUTTON_CHASE: = 3.0
const GLUTTON_HASTE: = 1.25
const FOOD_EVERY: = 0.3



const CHARGE_LOOK: = 0.35
const CHARGE_MIN: = 3.0
const CHARGE_MAX: = 7.5
const CHARGE_WIND: = 0.75
const CHARGE_SPEED: = 11.0
const CHARGE_TIME: = 0.62
const CHARGE_DMG: = 1.25
const CHARGE_DAZE: = 1.4
const CHARGE_REST: = [5.0, 8.0]
const CHARGE_AT_ONCE: = 3


const RISE_CHANCE: = 0.4
const RISE_AFTER: = 1.3
const RISE_HP: = 0.5
const RISE_AT_ONCE: = 10
const RISE_DENY: = ["holy", "fire"]


const SWARM_PACK: = 5
const SWARM_PACK_EARLY: = 2
const SWARM_EARLY: = 30.0
const SWARM_WAIT: = 7.0
const SWARM_SPREAD: = 1.8
const SWARM_KNOCK: = 1.6
const FLYERS: = {"hornet": true, "steel_chocho": true, "hunter_fly": true, "drainliar": true, "rideword": true, "punk": true}
const WEAVE: = 0.7
const WEAVE_RATE: = 6.0



const WARBAND_FROM: = 40.0
const WARBAND_EVERY: = 28.0
const WARBAND_LEADERS: = 2
const LEADERS: = {"ork_warrior": true, "orc_lady": true, "zenorc": true}
const LEADER_HP: = 6.0
const LEADER_DMG: = 1.25
const LEADER_XP: = 6
const LEADER_SIZE: = 1.35
const LEADER_KNOCK: = 0.35
const LEADER_COINS: = 4
const LEADER_ZENY: = 3.0
const RALLY_LOOK: = 0.5
const RALLY_R: = 7.0
const RALLY_SPEED: = 1.25
const ROUT_R: = 9.0
const ROUT_SLOW: = 4.0
const ROUT_PUSH: = 9.0


const SHELL_HIT: = 0.3



const BLAST_R: = 2.0
const BLAST_FUSE: = 0.9
const BLAST_DMG: = 1.5
const BLAST_MOB: = 0.35

const BLAST_TOUGH: = 0.25
const BLAST_GAP: = 0.4
const BLAST_AT_ONCE: = 4


const ROOT_LOOK: = 1.0
const ROOT_FAR: = 10.5
const ROOT_NEAR: = [5.0, 7.5]
const ROOT_EMERGE: = 0.9

const ROOT_REST: = 6.0
const ROOT_SHOT: = {"kind": "arrow", "range": 8.5, "every": 3.2, "speed": 9.0}


const NET_LOOK: = 0
const NET_GROW: = 1
const NET_CROWN: = 2
const NET_JUMP: = 3

const NET_KYRIE: = 4





var now: = 0.0

var _chargers: Array[Enemy] = []

var _food: Array[Dictionary] = []
var _food_at: = -9.0

var _emote_at: = 0.0
var _word_at: = 0.0

var _rising: Array = []

var _blasts: Array = []
var _blast_at: = -9.0

var _packs: = {}

var leaders: Array[Enemy] = []
var _leader_at: = 0.0


var news: Array = []



static func dress(e: Enemy) -> void :
	e.kin_t = randf_range(0.3, 1.2)
	match e.kin:
		SWARM:
			e.knock_k = SWARM_KNOCK
			if FLYERS.has(e.id):
				e._weave = randf_range(0.5, TAU)
		GHOST:
			e._ghost = true
			e.knock_k = 0.0
			e.set_look(LOOK_GHOST)
		ROOT:
			e._rooted = true
			e._immovable = true
			e._ranged = ROOT_SHOT




func think(e: Enemy, delta: float, world: World, hero: Player, to: Vector3, dist: float) -> bool:
	match e.kin:
		GLUTTON:
			return _glutton(e, delta, world)
		CHARGE:
			return _charge(e, delta, world, to, dist)
		WARBAND:
			_rally(e, world)
		ROOT:
			_root(e, world, hero, dist)
		_:

			e.kin_t = 1000000000.0
	return false





static func plain(e: Enemy) -> void :
	if e.kin == ROOT:
		e._rooted = false
		e._immovable = false
		e._ranged = e.def.get("ranged", Enemy.NO_RANGED)
	e.kin = NONE
	e.kin_on = 0
	e.kin_ref = null




func broken(e: Enemy) -> void :
	if e.kin == CHARGE:
		_charge_end(e)
	elif e.kin == GLUTTON:
		e.kin_on = 0
		e.kin_ref = null



func update(world: World, delta: float) -> void :
	now += delta


	if world.raid.freezes_time() or (world.tower != null and world.tower.state != "fight"):
		if not (_rising.is_empty() and _blasts.is_empty() and _packs.is_empty()):
			_rising.clear()
			_blasts.clear()
			_packs.clear()
		return
	if not _rising.is_empty() and now >= float(_rising[0][0]):
		var r: Array = _rising.pop_front()
		_rise(world, str(r[1]), r[2])
	if not _blasts.is_empty() and now >= float(_blasts[0][0]):
		var b: Array = _blasts.pop_front()
		_burst(world, b[1], float(b[2]), float(b[3]) if b.size() > 3 else 0.0)
	if not _packs.is_empty():
		for id in _packs:
			var p: Array = _packs[id]
			if int(p[0]) >= (SWARM_PACK_EARLY if world.time < SWARM_EARLY else SWARM_PACK) or now - float(p[1]) >= SWARM_WAIT:
				_packs.erase(id)
				_send_pack(world, str(id), int(p[0]))

				break




func cleared() -> void :
	_rising.clear()
	_blasts.clear()
	_packs.clear()
	_chargers.clear()
	leaders.clear()
	_food.clear()
	news.clear()



func fell(e: Enemy, world: World) -> void :


	var dim: = Vfx.dim
	var hero: = Vfx.hero
	Vfx.dim = 1.0
	Vfx.hero = false
	_fell(e, world)
	Vfx.dim = dim
	Vfx.hero = hero


func _fell(e: Enemy, world: World) -> void :
	match e.kin:
		GLUTTON:
			if e.kin_n > 0.0:
				world.drop_zeny(e.position, roundi(e.kin_n * GLUTTON_BACK))
				world.spawn_fx("steal_coin", e.position, 0.7, 0.8)
		CHARGE:
			_chargers.erase(e)
		RISE:
			_fallen(e, world)
		WARBAND:
			if leaders.has(e):
				_rout(e, world)
		BLAST:
			_arm(e, world)




func _glutton(e: Enemy, delta: float, world: World) -> bool:
	if e.kin_on == 0:
		if e.kin_c >= GLUTTON_MAX:
			e.kin_t = 1000000000.0
			return false
		e.kin_t = GLUTTON_LOOK * randf_range(0.8, 1.2)
		var p: = _food_near(e.position, world)
		if p.is_empty():
			return false
		e.kin_ref = p
		e.kin_on = 1
		e.kin_t = GLUTTON_CHASE
		return false
	var food = e.kin_ref
	if not (food is Dictionary) or bool(food.pull) or not is_instance_valid(food.node) or e.kin_t <= 0.0:
		e.kin_on = 0
		e.kin_ref = null
		e.kin_t = GLUTTON_LOOK
		return false
	var at: Vector3 = (food.node as Node3D).position
	var to: = Vector3(at.x - e.position.x, 0.0, at.z - e.position.z)
	var d: = to.length()
	if d < e.radius + 0.25:
		_eat(e, food, world)
		return false
	var spd: = e.speed * GLUTTON_HASTE * (0.45 if e.slow_time > 0.0 else 1.0)
	_walk(e, world, Vector3.ZERO if e.snare_time > 0.0 else to / d * spd, delta)
	e.visual.face(to)
	if e.attack_anim <= 0.0 and (e.visual.base_action != RoVisual.MOB_WALK or e.visual._done):
		e.visual.play(RoVisual.MOB_WALK)
	return true




func _food_near(at: Vector3, world: World) -> Dictionary:
	if now - _food_at >= FOOD_EVERY:
		_food_at = now
		_food.clear()
		for p in world.pickups:

			if p.kind == "loot" and not p.pull and not p.has("hop_t") and not p.has("fetch") and not p.has("spat"):
				_food.append(p)
	var best: = {}
	var best_d: = GLUTTON_REACH * GLUTTON_REACH
	for p in _food:
		if p.pull or not is_instance_valid(p.node):
			continue
		var q: Vector3 = (p.node as Node3D).position
		var d: = (q.x - at.x) * (q.x - at.x) + (q.z - at.z) * (q.z - at.z)
		if d < best_d:
			best_d = d
			best = p
	return best


func _eat(e: Enemy, food: Dictionary, world: World) -> void :
	e.kin_on = 0
	e.kin_ref = null
	e.kin_t = GLUTTON_LOOK

	food.pull = true

	for i in world.pickups.size():
		if is_same(world.pickups[i], food):
			world.pickups.remove_at(i)
			break
	(food.node as Node3D).queue_free()
	e.kin_n += float(food.value)
	e.kin_c += 1
	_grow(e, 1.0 + GLUTTON_GROW * e.kin_c)
	_tell(world, e, NET_GROW, 1.0 + GLUTTON_GROW * e.kin_c)
	if now >= _emote_at:
		_emote_at = now + 0.6
		world.emote(e, "money", 1.3)
		world.play_sound("get_coin", 0.3, -10.0)



static func _grow(e: Enemy, k: float) -> void :
	if e.visual is MobAnim:
		(e.visual as MobAnim).grow = k
	elif e.visual is RoVisual:
		var base: = float(GameData.SPECIAL_KINDS.get(e.special, {}).get("scale", 1.0))
		(e.visual as RoVisual).scale = Vector3.ONE * base * k




func _charge(e: Enemy, delta: float, world: World, to: Vector3, dist: float) -> bool:
	match e.kin_on:
		0:
			e.kin_t = CHARGE_LOOK
			if now < e.kin_n or dist < CHARGE_MIN or dist > CHARGE_MAX or e.slow_time > 0.0 or e.snare_time > 0.0:
				return false

			for i in range(_chargers.size() - 1, -1, -1):
				if not is_instance_valid(_chargers[i]) or _chargers[i].dead or _chargers[i].kin_on == 0:
					_chargers.remove_at(i)
			if _chargers.size() >= CHARGE_AT_ONCE:
				return false
			_chargers.append(e)
			e.kin_on = 1
			e.kin_t = CHARGE_WIND
			e.kin_v = to / dist
			e.knock = Vector3.ZERO
			Vfx.telegraph_line(world.fx_root, e.position, e.kin_v, CHARGE_SPEED * CHARGE_TIME + e.radius, e.radius * 2.0 + 0.5, CHARGE_WIND)
			world.emote(e, "surprise", CHARGE_WIND)
			e.visual.face(to)
			e.visual.play(RoVisual.MOB_IDLE)
			return true
		1:

			e.knock = Vector3.ZERO
			if fmod(e.kin_t, 0.24) < 0.1:
				e.visual.flash()
			if e.kin_t <= 0.0:
				e.kin_on = 2
				e.kin_t = CHARGE_TIME
				e.visual.speed_scale = 2.4
				e.visual.play(RoVisual.MOB_WALK, true, true)
				world.play_mob_sound(e.id, "attack")
			return true
		2:
			e.knock = Vector3.ZERO
			var from: = e.position
			var here: = world.map.step(from, e.kin_v * CHARGE_SPEED * delta)
			e.position = here

			for h in world.heroes:
				if h.downed or h.choosing:
					continue
				var dx: = h.position.x - here.x
				var dz: = h.position.z - here.z
				var reach: = e.radius + h.radius + 0.1
				if dx * dx + dz * dz < reach * reach:
					e.hit_cd = 0.9
					e.attack_anim = 0.5
					e.visual.play(RoVisual.MOB_ATTACK, false, true)
					h.take_damage(e.damage * CHARGE_DMG, world, e)
					_charge_end(e)
					e.kin_n = now + randf_range(float(CHARGE_REST[0]), float(CHARGE_REST[1]))
					return true

			var run: = Vector2(here.x - from.x, here.z - from.z).length()
			if e.kin_t <= 0.0 or run < CHARGE_SPEED * delta * 0.3:
				_charge_end(e)
				e.kin_n = now + randf_range(float(CHARGE_REST[0]), float(CHARGE_REST[1]))

				e.status_cd = 0.0
				world.apply_status(e, "stun", CHARGE_DAZE)
			return true
	return false


func _charge_end(e: Enemy) -> void :
	e.kin_on = 0
	e.kin_t = CHARGE_LOOK
	if e.visual.speed_scale > 1.0:
		e.visual.speed_scale = 1.0
	_chargers.erase(e)




func _fallen(e: Enemy, world: World) -> void :
	if e.has_meta("rose") or e.has_meta("risen") or e.summoned or e.feroz or _rising.size() >= RISE_AT_ONCE:
		return

	if GameData.hell_level(world.danger) >= 10 or world.raid.in_arena() or RISE_DENY.has(e.hit_el) or randf() >= RISE_CHANCE:
		return
	_rising.append([now + RISE_AFTER, e.id, e.position])

	Vfx.ring(world.fx_root, e.position, 0.9, Color(0.6, 0.95, 0.55, 0.9), 0.6)


func _rise(world: World, id: String, at: Vector3) -> void :
	if not world.running:
		return
	var r: = world.spawn_enemy(id, at, true)
	if r == null:
		return
	r.set_meta("rose", true)
	r.max_hp *= RISE_HP
	r.hp = r.max_hp
	r.xp = maxi(1, r.xp / 2)
	r.set_look(LOOK_RISEN)
	Vfx.burst(world.fx_root, at, 0.9, Color(0.5, 0.85, 0.45, 0.8))
	world.spawn_fx("earthhit", at, 0.5, 0.7)
	_tell(world, r, NET_LOOK, LOOK_RISEN)





func pack(id: String, world: World) -> void :
	if _packs.has(id):
		_packs[id][0] += 1
	else:
		_packs[id] = [1, now]


func _send_pack(world: World, id: String, n: int) -> void :
	var at: = world._offscreen_point()
	if at == Vector3.INF:
		return
	for i in n:
		world.spawn_enemy(id, at if i == 0 else world.map.random_point_around(at, SWARM_SPREAD))





func leader_due(world: World, id: String) -> bool:
	if not LEADERS.has(id) or world.time < WARBAND_FROM or now < _leader_at:
		return false
	for i in range(leaders.size() - 1, -1, -1):
		if not is_instance_valid(leaders[i]) or leaders[i].dead:
			leaders.remove_at(i)
	return leaders.size() < WARBAND_LEADERS


func crown(e: Enemy, world: World) -> void :
	_leader_at = now + WARBAND_EVERY
	leaders.append(e)


	e.kin_c = 2
	e.kin_t = 1000000000.0
	e.max_hp *= LEADER_HP
	e.hp = e.max_hp
	e.damage *= LEADER_DMG
	e.xp *= LEADER_XP
	e.knock_k = LEADER_KNOCK
	crown_look(e)
	_tell(world, e, NET_CROWN, 0.0)




static func crown_look(e: Enemy) -> void :
	e._dress(LEADER_SIZE, Color.WHITE, Color(1.0, 0.45, 0.15, 0.6), TranslationServer.translate("Caudillo"), Color(1.0, 0.62, 0.25))
	_grow(e, LEADER_SIZE)


func _rally(e: Enemy, world: World) -> void :
	if e.kin_c == 2:
		e.kin_t = 1000000000.0
		return
	e.kin_t = RALLY_LOOK
	var near: = false
	for l in leaders:
		if is_instance_valid(l) and not l.dead:
			var dx: = l.position.x - e.position.x
			var dz: = l.position.z - e.position.z
			if dx * dx + dz * dz < RALLY_R * RALLY_R:
				near = true
				break
	if near == (e.kin_c == 1):
		if leaders.is_empty():

			e.kin_t = RALLY_LOOK * 3.0
		return
	_set_rally(e, near, world)


func _set_rally(e: Enemy, on: bool, world: World) -> void :
	e.kin_c = 1 if on else 0
	e.speed = e.speed * RALLY_SPEED if on else e.speed / RALLY_SPEED
	e.set_look(LOOK_RALLY if on else LOOK_PLAIN)
	_tell(world, e, NET_LOOK, LOOK_RALLY if on else LOOK_PLAIN)



func _rout(e: Enemy, world: World) -> void :
	leaders.erase(e)
	var at: = e.position
	for o in world.enemies_in_radius(at, ROUT_R):
		if not is_instance_valid(o) or o.dead or o.kin != WARBAND or o.kin_c == 2:
			continue
		if o.kin_c == 1:
			_set_rally(o, false, world)
		o.slow_time = ROUT_SLOW
		o.kin_t = ROUT_SLOW
		var away: = Vector3(o.position.x - at.x, 0.0, o.position.z - at.z)
		if away.length_squared() > 0.01:
			o.knock += away.normalized() * ROUT_PUSH
	Vfx.burst(world.fx_root, at, ROUT_R * 0.5, Color(1.0, 0.6, 0.25, 0.7))
	world.number(at + Vector3(0, 2.2, 0), TranslationServer.translate("¡Desbandada!"), Color(1.0, 0.7, 0.3), true)
	world.play_sound("party_alarm", 0.5, -8.0)
	var zeny: = float(GameData.LOOT.get(e.id, {}).get("zeny", 1)) * LEADER_ZENY
	for i in LEADER_COINS:
		world.drop_zeny(at, maxi(1, roundi(zeny)))





func crack(e: Enemy, amount: float, world: World) -> float:

	e.kin_c = 1
	var cap: = e.max_hp * SHELL_HIT
	if amount <= cap:
		return amount
	if now >= _word_at:
		_word_at = now + 0.25
		world.number(e.position + Vector3(0, e.visual.height() + 0.5, 0), TranslationServer.translate("¡Crac!"), Color(0.8, 0.86, 0.95))
		world.play_sound("guard_block", 0.2, -9.0)
	return cap




func _arm(e: Enemy, world: World) -> void :
	if e.summoned or now - _blast_at < BLAST_GAP or _blasts.size() >= BLAST_AT_ONCE:
		return
	_blast_at = now
	_blasts.append([now + BLAST_FUSE, e.position, e.damage * BLAST_DMG, e.max_hp])
	Vfx.telegraph_circle(world.fx_root, e.position, BLAST_R, BLAST_FUSE)


func _burst(world: World, at: Vector3, damage: float, own_hp: = 0.0) -> void :
	if not world.running:
		return
	Vfx.burst(world.fx_root, at, BLAST_R, Color(1.0, 0.6, 0.2, 0.9))
	world.spawn_fx("blastmine", at, 0.8, 0.9)


	world._grid_fresh = false
	world._rebuild_grid()
	world.play_sound("landmine", 0.12, -7.0)
	for h in world.heroes:
		if h.downed:
			continue
		var dx: = h.position.x - at.x
		var dz: = h.position.z - at.z
		if dx * dx + dz * dz < BLAST_R * BLAST_R:
			world.hurt_what = "Explosión"
			world.hurt_mob = 1
			h.take_damage(damage, world)



	for o in world.enemies_in_radius(at, BLAST_R):
		if not is_instance_valid(o) or o.dead or o.is_boss or o.prop != "" or o._static or o._immovable\
		or o.special == "runner" or o.has_meta("festival"):
			continue
		var away: = Vector3(o.position.x - at.x, 0.0, o.position.z - at.z)
		var share: = BLAST_MOB * (BLAST_TOUGH if o.feroz or o.def.get("elite", false) else 1.0)
		o.hurt(own_hp * share, away.normalized() * 6.0 if away.length_squared() > 0.01 else Vector3.ZERO)
		if o.hp <= 0.0:
			world._kill(o)




func _root(e: Enemy, world: World, hero: Player, dist: float) -> void :
	e.kin_t = ROOT_LOOK
	if dist < ROOT_FAR or hero == null or now < e.kin_n:
		e.kin_c = 0
		return

	e.kin_c += 1
	if e.kin_c < 2:
		return
	e.kin_c = 0
	var p: = world.map.find_point_around(hero.position, float(ROOT_NEAR[0]), float(ROOT_NEAR[1]))
	if p == Vector3.INF:
		return
	var to: = Vector3(p.x, world.map.height_at(p), p.z)
	e.position = to
	world._grid_fresh = false
	e.kin_n = now + ROOT_REST
	e.hold = ROOT_EMERGE
	e.shoot_cd = maxf(e.shoot_cd, ROOT_EMERGE + 0.4)
	emerge(e, world, to)
	_tell(world, e, NET_JUMP, to)




static func emerge(e: Enemy, world: World, at: Vector3) -> void :
	Vfx.ring(world.fx_root, at, 1.1, Color(0.55, 0.8, 1.0, 0.9), 0.5)
	world.spawn_fx("earthhit", at, 0.5, 0.7)
	fade_in(e)


static func fade_in(e: Enemy) -> void :
	if e.visual is MobAnim:
		(e.visual as MobAnim).alpha = 0.0
		e.create_tween().tween_property(e.visual, "alpha", 1.0, ROOT_EMERGE * 0.7)





static func _walk(e: Enemy, world: World, vel: Vector3, delta: float) -> void :
	vel += e.knock
	e.knock = e.knock.move_toward(Vector3.ZERO, delta * 30.0)
	if vel.length_squared() > 0.0:
		e.position = world.map.step(e.position, vel * delta)




func tell(world: World, e: Enemy, what: int, value: Variant) -> void :
	_tell(world, e, what, value)




func looks_of(e: Enemy) -> Array:
	var out: = []
	if e.kin == WARBAND and e.kin_c == 2:
		out.append([NET_CROWN, 0.0])
	elif e.kin == GLUTTON and e.kin_c > 0:
		out.append([NET_GROW, 1.0 + GLUTTON_GROW * e.kin_c])
	if e._look_k != LOOK_PLAIN:
		out.append([NET_LOOK, e._look_k])
	return out


func _tell(world: World, e: Enemy, what: int, value: Variant) -> void :
	if world.net.recording():
		news.append(["t", world.net.ref_of(e)[1], what, value])



static func net_look(world: World, e: Enemy, code: int, value: Variant) -> void :
	if e == null or not is_instance_valid(e):
		return
	match code:
		NET_LOOK:
			e.set_look(int(value))
		NET_GROW:
			_grow(e, float(value))
		NET_CROWN:
			crown_look(e)
		NET_KYRIE:
			e.set_kyrie(bool(value))
		NET_JUMP:
			if value is Vector3:
				e.position = value
				world.net._mob_to[e.nid] = value
				fade_in(e)





static func texts() -> Array:
	return [
		[GLUTTON, TranslationServer.translate("Glotón"), 
			TranslationServer.translate("Se come el zeny que dejas en el suelo y engorda con cada bocado. Al caer lo suelta todo, y la mitad más: un Poring gordo es una hucha.")], 
		[CHARGE, TranslationServer.translate("Embestida"), 
			TranslationServer.translate("Se detiene, marca una línea roja y carga por ella. Sal de la línea: si no acierta a nadie, queda aturdido un momento.")], 
		[RISE, TranslationServer.translate("Se levanta"), 
			TranslationServer.translate("Al caer puede volver a levantarse una vez, más oscuro y con la mitad de vida. Si el golpe final es de Sagrado o de Fuego, no se levanta.")], 
		[SWARM, TranslationServer.translate("Enjambre"), 
			TranslationServer.translate("No llegan de uno en uno: se juntan fuera de la vista y entran todos a la vez por un lado. Pesan poco: cualquier empujón los manda lejos, y un golpe de área se lleva al grupo entero.")], 
		[GHOST, TranslationServer.translate("Etéreo"), 
			TranslationServer.translate("Atraviesa muros y precipicios, siempre en línea recta hacia ti, y tus golpes no lo empujan.")], 
		[WARBAND, TranslationServer.translate("Horda de guerra"), 
			TranslationServer.translate("De vez en cuando llega un Caudillo: más grande y resistente, y los orcos que tiene cerca corren más. Al caer, los suyos se desbandan (lentos unos segundos) y suelta su bolsa de zeny.")], 
		[SHELL, TranslationServer.translate("Caparazón"), 
			TranslationServer.translate("El primer golpe que recibe solo rompe su coraza: nunca le quita más del 30% de la vida. Los golpes rápidos y los daños por tiempo lo abren antes que un único golpe enorme.")], 
		[BLAST, TranslationServer.translate("Autodestrucción"), 
			TranslationServer.translate("Al caer puede dejar un círculo rojo que estalla en un instante. A ti te hace daño; a los monstruos que pille, mucho más: haz que estalle entre ellos.")], 
		[ROOT, TranslationServer.translate("Enraizado"), 
			TranslationServer.translate("No camina: dispara desde donde está. Si te alejas, se hunde y vuelve a salir del suelo cerca de ti.")], 
	]



static func guide() -> Array:
	var out: = []
	for r in texts():
		var names: = []
		for id in OF:
			if OF[id] == r[0] and GameData.MONSTERS.has(id):
				names.append(TranslationServer.translate(str(GameData.MONSTERS[id].name)))
		out.append([str(r[1]), str(r[2]), ", ".join(names)])
	return out
