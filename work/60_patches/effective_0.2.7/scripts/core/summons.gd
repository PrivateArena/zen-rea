class_name Summons
extends RefCounted






const MAX_PLANTS: = 14

var _plants: Array[Dictionary] = []

var _shots: Array[Dictionary] = []



var _next_id: = 0
var _ghosts: = {}
var _walk_sent: = 0.0

const NET_WALK_EVERY: = 0.12





func plant(world: World, p: Player, sk: Dictionary, level: int, count: int, dmg: float, reach: float, duration: float, 
		at: = Vector3.INF) -> void :
	dmg *= p.summon_power() * GameData.SUMMON_POWER
	var kinds: Array = sk.get("plants", [])
	var kind: = str(kinds[clampi(level - 1, 0, kinds.size() - 1)]) if not kinds.is_empty() else ""
	for i in count:



		var mine: = _plants.filter( func(pl): return pl.by == p)
		if mine.size() >= MAX_PLANTS:
			var old: Dictionary = mine[0]
			if not old.sk.get("walks", false) and is_instance_valid(old.v) and old.v.position.distance_to(p.position) <= float(old.reach):
				old.t = maxf(float(old.t), duration)
				_plants.erase(old)
				_plants.append(old)
				continue
			_plants.erase(old)
			_wither(old.v)
		var a: = randf() * TAU
		var spot: = at if at != Vector3.INF else p.position + Vector3(cos(a), 0.0, sin(a)) * randf_range(1.2, 2.6)
		if world.map != null and at == Vector3.INF:
			spot = world.map.slide(p.position, spot - p.position)
		if world.map != null:
			spot.y = world.map.height_at(spot)
		var v: = RoVisual.new()
		world.run_root.add_child(v)
		v.setup(RoAssets.sprite([kind]), sk.color, 28, 0.8)
		v.position = spot
		v.play(RoVisual.MOB_IDLE, true)

		v.scale = Vector3(1.0, 0.05, 1.0)
		v.create_tween().tween_property(v, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK)
		_next_id += 1
		_plants.append({"v": v, "kind": kind, "t": duration, "cd": 0.3 + 0.15 * i, "every": float(sk.get("tick", 1.0)), 
			"dmg": dmg, "reach": maxf(reach, GameData.SUMMON_RANGE) + p.summon_reach(), "sk": sk, "tag": world.damage_tag, "by": p, "walking": false, "id": _next_id})

		if world.net.recording():
			world.net.record(["pl", _next_id, kind, spot, sk.color, duration])



func count(tag: String, by: Player = null) -> int:
	return _plants.filter( func(pl): return str(pl.tag) == tag and (by == null or pl.by == by)).size()




func shoot(world: World, from: Vector3, target: Enemy, kind: String, dmg: float, element: String, tag: String, by: Player, 
		burst: = {}) -> void :
	_shots.append({"t": world.summon_shot(kind, from, target.position), "target": target, "dmg": dmg, "element": element, 
		"tag": tag, "by": by, "from": from, "burst": burst})


func _land(world: World, sh: Dictionary) -> void :
	var target = sh.target
	if not is_instance_valid(target) or target.dead:
		return
	world.damage_tag = sh.tag
	world.damage_by = sh.by if is_instance_valid(sh.by) else null
	var push: Vector3 = ((target.position - sh.from) * Vector3(1, 0, 1)).normalized() * 0.6
	var at: Vector3 = target.position
	world.damage_enemy(target, sh.dmg, push, "skill", sh.element)
	world.spawn_fx("hit", at + Vector3(0, 0.5, 0), 0.4, 0.6)
	if sh.burst.is_empty():
		return
	world.spawn_fx("su_scaroftarou/su_scaroftarou", at, 1.2, 1.0)
	Vfx.ring(world.fx_root, at, sh.burst.area, Color(1.0, 0.45, 0.3), 0.3)
	for e in world.enemies_in_radius(at, sh.burst.area):
		world.damage_enemy(e, sh.burst.dmg, Vector3.ZERO, "skill", sh.element)
		if not e.dead and not e.is_boss:
			world.apply_status(e, "stun", sh.burst.stun)


func update(world: World, delta: float) -> void :
	for i in range(_shots.size() - 1, -1, -1):
		var sh: Dictionary = _shots[i]
		sh.t -= delta
		if sh.t <= 0.0:
			_shots.remove_at(i)
			_land(world, sh)
	for i in range(_plants.size() - 1, -1, -1):
		var pl: Dictionary = _plants[i]
		var v: RoVisual = pl.v
		pl.t -= delta
		if pl.t <= 0.0 or not is_instance_valid(v):
			_wither(v)
			_plants.remove_at(i)
			if world.net.recording():
				world.net.record(["plx", int(pl.get("id", 0))])
			continue
		pl.cd -= delta
		if pl.sk.get("walks", false) and _walk(world, pl, delta):
			continue
		if pl.cd > 0.0:
			continue
		var target: = world.nearest_enemy(v.position, pl.reach)
		if target == null:
			pl.cd = 0.2
			continue

		pl.cd = float(pl.every) * (Doram.aspd_share(pl.by) if is_instance_valid(pl.by) else 1.0)
		v.face(target.position - v.position)
		v.play(RoVisual.MOB_ATTACK, false, true)
		v.finished.connect( func():
			if is_instance_valid(v):
				v.play(RoVisual.MOB_IDLE, true), CONNECT_ONE_SHOT)
		world.play_mob_sound(str(pl.kind), "attack")
		shoot(world, v.position, target, str(pl.kind), pl.dmg, str(pl.sk.get("element", "neutral")), str(pl.tag), pl.by)

		if str(pl.tag).begins_with("bio_cannibalize") and is_instance_valid(pl.by):
			var jumps: = GameData.PLANT_CHAIN + int(float(pl.by.effects.get("plant_chain", 0.0)))
			var hit: = [target]
			var from: Enemy = target
			for j in jumps:
				var nxt: Enemy = null
				var best: = GameData.PLANT_CHAIN_RANGE
				for o in world.enemies_in_radius(from.position, GameData.PLANT_CHAIN_RANGE):
					if o.dead or o.prop != "" or hit.has(o):
						continue
					var dd: = o.position.distance_to(from.position)
					if dd < best:
						best = dd
						nxt = o
				if nxt == null:
					break
				hit.append(nxt)
				shoot(world, from.position, nxt, str(pl.kind), float(pl.dmg) * GameData.PLANT_CHAIN_SHARE, str(pl.sk.get("element", "neutral")), str(pl.tag), pl.by)
				from = nxt
		if world.net.recording():
			world.net.record(["pla", int(pl.get("id", 0)), target.position])

	_walk_sent -= delta
	if _walk_sent <= 0.0 and world.net.recording():
		_walk_sent = NET_WALK_EVERY
		var moved: = []
		for pl in _plants:
			if pl.sk.get("walks", false) and is_instance_valid(pl.v):
				moved.append([int(pl.get("id", 0)), snappedf(pl.v.position.x, 0.05), snappedf(pl.v.position.z, 0.05), bool(pl.walking)])
		if not moved.is_empty():
			world.net.record(["plp", moved])



func net_event(world: World, ev: Array) -> void :
	match str(ev[0]):
		"pl":
			var id: = int(ev[1])
			if _ghosts.has(id):
				return
			var v: = RoVisual.new()
			world.run_root.add_child(v)
			v.setup(RoAssets.sprite([str(ev[2])]), ev[4], 28, 0.8)
			v.position = ev[3]
			v.play(RoVisual.MOB_IDLE, true)
			v.scale = Vector3(1.0, 0.05, 1.0)
			v.create_tween().tween_property(v, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK)
			_ghosts[id] = {"v": v, "t": float(ev[5]) + 1.0, "walking": false}
		"plx":
			var g: Dictionary = _ghosts.get(int(ev[1]), {})
			_ghosts.erase(int(ev[1]))
			if not g.is_empty():
				_wither(g.v)
		"pla":
			var g: Dictionary = _ghosts.get(int(ev[1]), {})
			if not g.is_empty() and is_instance_valid(g.v):
				var v: RoVisual = g.v
				v.face((ev[2] as Vector3) - v.position)
				v.play(RoVisual.MOB_ATTACK, false, true)
				v.finished.connect( func():
					if is_instance_valid(v):
						v.play(RoVisual.MOB_IDLE, true), CONNECT_ONE_SHOT)
		"plp":
			for row in ev[1]:
				var g: Dictionary = _ghosts.get(int(row[0]), {})
				if g.is_empty() or not is_instance_valid(g.v):
					continue
				var v: RoVisual = g.v
				var to: = Vector3(float(row[1]), 0.0, float(row[2]))
				to.y = world.map.height_at(to) if world.map != null else v.position.y
				g["to"] = to
				var walking: = bool(row[3])
				if walking != bool(g.walking):
					g.walking = walking
					v.play(RoVisual.MOB_WALK if walking else RoVisual.MOB_IDLE, true)




func client_tick(delta: float) -> void :
	for id in _ghosts.keys():
		var g: Dictionary = _ghosts[id]
		g.t = float(g.t) - delta
		if g.t <= 0.0 or not is_instance_valid(g.v):
			_wither(g.v)
			_ghosts.erase(id)
			continue
		if g.has("to"):
			var v: RoVisual = g.v
			var step: Vector3 = (g.to as Vector3) - v.position
			if step.length() > 0.02:
				v.face(step * Vector3(1, 0, 1))
				v.position = v.position.lerp(g.to, minf(1.0, delta * 10.0))




func _walk(world: World, pl: Dictionary, delta: float) -> bool:
	var v: RoVisual = pl.v
	var goal: = Vector3.INF

	pl["look"] = float(pl.get("look", 0.0)) - delta
	var target = pl.get("target")
	if pl.look <= 0.0 or target == null or not is_instance_valid(target) or target.dead:
		pl.look = 0.2
		target = world.nearest_enemy(v.position, 8.0)
		pl["target"] = target
	if target != null:
		if v.position.distance_to(target.position) > float(pl.reach) * 0.8:
			goal = target.position
	else:
		var hero: Player = pl.by if is_instance_valid(pl.by) else world.player
		if v.position.distance_to(hero.position) > 3.0:
			goal = hero.position
	if goal == Vector3.INF:
		if pl.walking:
			pl.walking = false
			v.play(RoVisual.MOB_IDLE, true)
		return false
	var step: = ((goal - v.position) * Vector3(1, 0, 1))
	if step.length() > 0.01:
		step = step.normalized() * float(pl.sk.get("speed", 4.5)) * delta
		var to: = world.map.slide(v.position, step) if world.map != null else v.position + step
		to.y = world.map.height_at(to) if world.map != null else to.y
		v.position = to
		v.face(step)
	if not pl.walking:
		pl.walking = true
		v.play(RoVisual.MOB_WALK, true)
	return true


func clear() -> void :
	_shots.clear()
	for pl in _plants:
		if is_instance_valid(pl.v):
			pl.v.queue_free()
	_plants.clear()
	for id in _ghosts:
		if is_instance_valid(_ghosts[id].v):
			_ghosts[id].v.queue_free()
	_ghosts.clear()


func _wither(v: RoVisual) -> void :
	if not is_instance_valid(v):
		return
	var tw: = v.create_tween()
	tw.tween_property(v, "scale", Vector3(1.0, 0.05, 1.0), 0.25)
	tw.tween_callback(v.queue_free)
