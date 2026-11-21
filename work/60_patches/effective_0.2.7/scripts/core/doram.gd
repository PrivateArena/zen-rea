class_name Doram
extends RefCounted













const MAX_PETS: = 14




const LEASH: = 12.0
const SEEK: = 9.0
const LEAVE: = 3.0

var _pets: Array = []
var _dashes: Array = []





var news: Array = []

var _tracked: = {}

var _net: = {}



func cast(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range")
	var first: = world.nearest_enemy(p.position, reach)
	if first == null:
		return false
	var power: = p.summon_power()
	var count: = maxi(1, int(v.call("count")) + int(p.effects.get("summon_count", 0.0)))
	var dmg: float = v.call("damage") * power
	match str(s.doram):
		"picky":
			for i in count:
				_spawn(world, p, s, "picky", dmg * GameData.SUMMON_POWER, v.call("duration"), _around(world, p.position, 1.0, 2.2), 0.75)
		"tarou":
			for i in count:
				_spawn(world, p, s, "tarou", dmg * GameData.SUMMON_POWER, v.call("duration"), _around(world, p.position, 0.6, 1.4), 0.8)
		"arclouse":
			_arclouse_dash(world, p, s, first, dmg * move_share(p), count, reach)
		"lunatic":
			_carrot_beat(world, p, s, reach, dmg, count, v.call("area") * sqrt(p.area_mult))
	p.play_attack(first.position - p.position, true)
	world.play_skill_sound(s)
	return true





static func aspd_share(p: Player) -> float:
	var bare: = maxf(0.1, (200.0 - float(p.def.basic.aspd)) * 0.02)
	return clampf(p.attack_delay() / bare, GameData.SUMMON_ASPD_MIN, 1.0)





static func move_share(p: Player) -> float:
	return clampf(p.move_speed / maxf(0.1, float(p.def.get("speed", 4.8))), 1.0, GameData.SUMMON_MOVE_MAX)



func _around(world: World, at: Vector3, near: float, far: float) -> Vector3:
	var a: = randf() * TAU
	var spot: = at + Vector3(cos(a), 0.0, sin(a)) * randf_range(near, far)
	if world.map != null:
		spot = world.map.slide(at, spot - at)
		spot.y = world.map.height_at(spot)
	return spot


func _spawn(world: World, p: Player, s: Dictionary, kind: String, dmg: float, duration: float, at: Vector3, size: float) -> void :
	var mine: = _pets.filter( func(pt): return pt.by == p and pt.kind == kind)
	if mine.size() >= MAX_PETS:




		var old: Dictionary = mine[mine.size() - 1]
		old.dmg = float(old.dmg) + dmg * minf(1.0, float(old.t) / maxf(0.1, duration))
		old["merged"] = int(old.get("merged", 0)) + 1
		var ov = old.v
		if is_instance_valid(ov):
			var big: = Vector3.ONE * (1.35 if kind == "picky" else 1.1) * minf(1.6, 1.0 + 0.04 * float(old.merged))
			ov.create_tween().tween_property(ov, "scale", big, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			world.spawn_fx("su_pickypeck/su_pickypeck" if kind == "picky" else "su_scaroftarou/su_scaroftarou", ov.position, 0.45, 0.7)
		return
	var v: = RoVisual.new()
	world.run_root.add_child(v)
	v.setup(RoAssets.sprite([kind]), s.color, 24, size)
	v.position = at
	v.play(RoVisual.MOB_WALK, true)
	_track(world, v, kind, s.color, size)

	v.scale = Vector3(0.3, 0.3, 0.3)

	var grown: = Vector3.ONE * (1.35 if kind == "picky" else 1.1)
	v.create_tween().tween_property(v, "scale", grown, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	world.spawn_fx("su_pickypeck/su_pickypeck" if kind == "picky" else "su_scaroftarou/su_scaroftarou", at, 0.45, 0.7)

	_pets.append({"v": v, "kind": kind, "t": duration, "cd": 0.25, "every": float(s.get("tick", 0.8)) * aspd_share(p), "dmg": dmg, 
		"sk": s, "tag": world.damage_tag, "by": p, "target": null, "look": 0.0, "latched": false, 
		"burst": float(s.get("burst", 0.0)), "area": float(s.get("area", 1.6)) * sqrt(p.area_mult)})


func update(world: World, delta: float) -> void :
	for i in range(_pets.size() - 1, -1, -1):
		var pt: Dictionary = _pets[i]
		var v = pt.v
		pt.t -= delta
		if not is_instance_valid(v):
			_pets.remove_at(i)
			continue
		if pt.t <= 0.0 or not world.hero_valid(pt.by):
			if pt.burst > 0.0 and world.hero_valid(pt.by):
				_burst(world, pt)
			_vanish(v)
			_pets.remove_at(i)
			continue


		var hero: Player = pt.by
		if _flat(v.position, hero.position) > LEASH:
			var at: = _around(world, hero.position, 1.2, 2.6)
			world.spawn_fx("su_pickypeck/su_pickypeck" if pt.kind == "picky" else "su_scaroftarou/su_scaroftarou", at, 0.4, 0.7)
			v.position = at
			pt.target = null
			pt.latched = false
		if pt.target != null and is_instance_valid(pt.target) and not _fair(world, pt.target, hero):
			pt.target = null
			pt.latched = false
		if pt.kind == "tarou":
			_tick_tarou(world, pt, delta)
		else:
			_tick_picky(world, pt, delta)
	for i in range(_dashes.size() - 1, -1, -1):
		if not _tick_dash(world, _dashes[i], delta):
			_dashes.remove_at(i)



func _tick_picky(world: World, pt: Dictionary, delta: float) -> void :
	var v: RoVisual = pt.v
	pt.cd -= delta
	pt.look -= delta
	var target = pt.target
	if pt.look <= 0.0 or target == null or not is_instance_valid(target) or target.dead:
		pt.look = 0.25

		target = _nearest(world, hero_of(pt).position, SEEK)
		pt.target = target
	var hero: Player = pt.by
	var goal: Vector3 = hero.position if target == null else target.position
	var close: = GameData.SUMMON_RANGE if target != null else 2.2
	var to: Vector3 = (goal - v.position) * Vector3(1, 0, 1)
	if to.length() > close:
		_step(world, v, to, float(pt.sk.get("speed", 5.5)), delta)
		return
	if target == null:
		v.play(RoVisual.MOB_IDLE, true)
		return
	if pt.cd > 0.0:
		return
	pt.cd = pt.every
	v.face(to)
	v.play(RoVisual.MOB_ATTACK, false, true)
	world.summons.shoot(world, v.position, target, "picky", pt.dmg, str(pt.sk.get("element", "neutral")), str(pt.tag), pt.by)
	world.play_sound("picky_hop", 0.12, -14.0)




func _tick_tarou(world: World, pt: Dictionary, delta: float) -> void :
	var v: RoVisual = pt.v
	pt.cd -= delta
	var target = pt.target
	if target == null or not is_instance_valid(target) or target.dead:
		pt.latched = false
		target = toughest(world, (pt.by as Player).position, SEEK)
		pt.target = target
	if target == null:
		var hero: Player = pt.by
		var home: Vector3 = (hero.position - v.position) * Vector3(1, 0, 1)
		if home.length() > 2.0:
			_step(world, v, home, 8.0, delta)
		else:
			v.play(RoVisual.MOB_IDLE, true)
		return
	var to: Vector3 = (target.position - v.position) * Vector3(1, 0, 1)
	if to.length() > GameData.SUMMON_RANGE:
		pt.latched = false
		_step(world, v, to, float(pt.sk.get("speed", 9.0)), delta)
		return
	if not pt.latched:
		pt.latched = true
		pt.cd = 0.0
		world.spawn_fx("su_scaroftarou/su_scaroftarou", target.position, 0.6, 0.9)
		if not target.is_boss:
			world.apply_status(target, "stun", float(pt.sk.get("stun", 0.6)))
	if pt.cd > 0.0:
		return
	pt.cd = pt.every
	v.face(to)
	v.play(RoVisual.MOB_ATTACK, false, true)

	var burst: = {}
	var every: = int(pt.sk.get("scar", 0))
	pt["blows"] = int(pt.get("blows", 0)) + 1
	if every > 0 and int(pt.blows) % every == 0:
		burst = {"dmg": pt.dmg * float(pt.sk.scar_dmg), "area": pt.area, "stun": float(pt.sk.stun)}
	world.summons.shoot(world, v.position, target, "tarou", pt.dmg, str(pt.sk.get("element", "neutral")), str(pt.tag), pt.by, burst)


func toughest(world: World, at: Vector3, reach: float) -> Enemy:
	var best: Enemy = null
	var score: = -1.0
	for e in world.enemies_in_radius(at, reach):
		if e.dead or e.prop != "" or _walled(world, e):
			continue
		var taken: = _pets.any( func(o): return o.kind == "tarou" and o.target == e)

		var sc: float = Skills.rank(world, e) - (e.hp * 0.65 if taken else 0.0)
		if sc > score:
			score = sc
			best = e
	return best


func hero_of(pt: Dictionary) -> Player:
	return pt.by





func _fair(world: World, e: Enemy, hero: Player) -> bool:
	return not e.dead and e.prop == "" and not _walled(world, e) and _flat(e.position, hero.position) <= SEEK + LEAVE


func _walled(world: World, e: Enemy) -> bool:
	return (world.morroc != null and world.morroc.walled(e)) or (world.raid != null and world.raid.untouchable(e))



func _nearest(world: World, at: Vector3, reach: float) -> Enemy:
	var best: Enemy = null
	var bd: = INF
	for e in world.enemies_in_radius(at, reach):
		if e.dead or e.prop != "" or _walled(world, e):
			continue
		var d: = (e.position - at).length_squared()
		if d < bd:
			bd = d
			best = e
	return best


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _step(world: World, v: RoVisual, to: Vector3, speed: float, delta: float) -> void :
	var move: = to.normalized() * speed * delta
	var at: = world.map.slide(v.position, move) if world.map != null else v.position + move
	if world.map != null:
		at.y = world.map.height_at(at)
	v.position = at
	v.face(to)
	if v.base_action != RoVisual.MOB_WALK:
		v.play(RoVisual.MOB_WALK, true)



func _burst(world: World, pt: Dictionary) -> void :
	var v: RoVisual = pt.v
	world.damage_tag = pt.tag
	world.damage_by = pt.by
	world.spawn_fx("su_pickypeck/su_pickypeck", v.position, 0.8, 1.0)
	Vfx.burst(world.fx_root, v.position, pt.area, Color(1.0, 0.6, 0.3))
	world.play_mob_sound(str(pt.kind), "die")
	for e in world.enemies_in_radius(v.position, pt.area):
		world.damage_enemy(e, pt.dmg * pt.burst, ((e.position - v.position) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", "fire")




func _arclouse_dash(world: World, p: Player, s: Dictionary, first: Enemy, dmg: float, count: int, reach: float) -> void :
	var dir: = ((first.position - p.position) * Vector3(1, 0, 1)).normalized()
	world.spawn_fx("su_arclousedash/su_arclousedash", p.position, 0.8, 1.0)
	world.play_mob_sound("arclouse", "attack")
	for i in count:
		var d: = dir.rotated(Vector3.UP, (i - (count - 1) * 0.5) * 0.22)
		var v: = RoVisual.new()
		world.run_root.add_child(v)
		v.setup(RoAssets.sprite(["arclouse"]), s.color, 24, 0.8)
		v.position = p.position + d * 0.6
		v.face(d)
		v.play(RoVisual.MOB_WALK, true)
		_track(world, v, "arclouse", s.color, 0.8)
		_dashes.append({"v": v, "dir": d, "left": reach * 1.3, "reach": reach * 1.3, "back": s.get("back", false), "dmg": dmg, "hit": {}, "by": p, "tag": world.damage_tag, 
			"sk": s, "run": move_share(p), "width": float(s.get("width", 0.9)) * sqrt(p.area_mult), "delay": i * 0.06})


func _tick_dash(world: World, d: Dictionary, delta: float) -> bool:
	var v = d.v
	if not is_instance_valid(v):
		return false
	if d.delay > 0.0:
		d.delay -= delta
		return true
	var step: float = float(d.sk.get("speed", 16.0)) * float(d.get("run", 1.0)) * delta
	d.left -= step
	var at: Vector3 = (v as RoVisual).position + d.dir * step
	if world.map != null:
		at.y = world.map.height_at(at)
	v.position = at
	if world.hero_valid(d.by):
		world.damage_tag = d.tag
		world.damage_by = d.by
		for e in world.enemies_in_radius(at, d.width):
			if d.hit.has(e) or e.dead:
				continue
			d.hit[e] = true
			world.damage_enemy(e, d.dmg, d.dir * 3.0, "skill", str(d.sk.get("element", "neutral")))
			world.spawn_fx("hit", e.position + Vector3(0, 0.5, 0), 0.5, 0.8)
	if d.left <= 0.0:

		if d.back:
			d.back = false
			d.left = d.reach
			d.dir = - d.dir
			d.hit = {}
			v.face(d.dir)
			return true
		_vanish(v)
		return false
	return true




func _carrot_beat(world: World, p: Player, s: Dictionary, reach: float, dmg: float, count: int, area: float) -> void :
	var near: = world.nearest_enemies(p.position, reach, 14)
	var center: Vector3 = near[0].position
	var most: = -1
	for e in near:
		var c: = world.enemies_in_radius(e.position, area).size()
		if c > most:
			most = c
			center = e.position
	world.spawn_fx("su_lunaticcarrotbeat/su_lunaticcarrotbeat", center, 1.0, 1.0)
	world.play_mob_sound("lunatic", "attack")
	for i in mini(count, 6):
		var a: = TAU * i / float(mini(count, 6))
		var v: = RoVisual.new()
		world.run_root.add_child(v)
		v.setup(RoAssets.sprite(["lunatic"]), s.color, 24, 0.7)
		var spot: = center + Vector3(cos(a), 0, sin(a)) * area * 0.9
		if world.map != null:
			spot.y = world.map.height_at(spot)
		v.position = spot
		v.face(center - spot)
		v.play(RoVisual.MOB_ATTACK, true)
		_track(world, v, "lunatic", s.color, 0.7)
		v.scale = Vector3(0.2, 0.2, 0.2)
		var tw: = v.create_tween()
		tw.tween_property(v, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK)
		tw.tween_interval(1.1)
		tw.tween_property(v, "scale", Vector3(1.0, 0.05, 1.0), 0.2)
		tw.tween_callback(v.queue_free)
	var tag: = world.damage_tag
	var by: = world.damage_by
	var hit: = float(s.get("hit_area", 1.4)) * sqrt(p.area_mult)
	var stun: = float(s.get("stun_chance", 0.0))
	for i in count:
		var spot: = center + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * area * 0.7
		world._own_timer(0.25 + i * 0.1, func():
			if not world.running or not world.hero_valid(p):
				return
			world.damage_tag = tag
			world.damage_by = by
			world.sprite_fx("fx_carrot_beat", spot, 0, 0.7)
			Vfx.ring(world.fx_root, spot, hit, Color(1.0, 0.65, 0.3), 0.3)
			for e in world.enemies_in_radius(spot, hit):
				world.damage_enemy(e, dmg, Vector3.ZERO, "skill", str(s.get("element", "neutral")))
				if stun > 0.0 and not e.is_boss and randf() < stun:
					world.apply_status(e, "stun", 1.0))




func sea_wave(world: World, p: Player, at: Vector3, amount: float) -> void :
	var k: = float(p.effects.get("sea_wave", 0.0))
	if k <= 0.0 or amount <= 0.0:
		return
	var reach: = GameData.SEA_WAVE_RADIUS * sqrt(p.area_mult)
	var keep_tag: = world.damage_tag
	var keep_by: = world.damage_by
	world.damage_tag = "spirit_of_sea"
	world.damage_by = p
	world.spawn_fx("su_freshshrimp/su_freshshrimp", at, 1.0, 1.0)
	Vfx.ring(world.fx_root, at, reach, Color(0.45, 0.8, 1.0), 0.5)
	for e in world.enemies_in_radius(at, reach):
		world.damage_enemy(e, amount * k, ((e.position - at) * Vector3(1, 0, 1)).normalized() * 3.0, "skill", "water")
	world.damage_tag = keep_tag
	world.damage_by = keep_by



func count(tag: String, by: Player = null) -> int:
	return _pets.filter( func(pt): return str(pt.tag) == tag and (by == null or pt.by == by)).size()


func clear() -> void :
	for pid in _net:
		if is_instance_valid(_net[pid]):
			_net[pid].queue_free()
	_net.clear()
	_tracked.clear()
	news.clear()
	for pt in _pets:
		if is_instance_valid(pt.v):
			pt.v.queue_free()
	for d in _dashes:
		if is_instance_valid(d.v):
			d.v.queue_free()
	_pets.clear()
	_dashes.clear()


func _vanish(v) -> void :
	if v == null or not is_instance_valid(v):
		return
	if v.has_meta("pid"):
		_untrack(int(v.get_meta("pid")))
	var tw: Tween = v.create_tween()
	tw.tween_property(v, "scale", Vector3(1.0, 0.05, 1.0), 0.2)
	tw.tween_callback(v.queue_free)




func _track(world: World, v: RoVisual, sprite: String, color: Color, size: float) -> void :
	if not world.net.recording():
		return
	var pid: = world.net.next_nid()
	v.set_meta("pid", pid)
	_tracked[pid] = {"v": v, "at": v.position, "act": v.base_action}
	news.append(["ds", pid, sprite, color.to_html(), size, v.position, v.base_action, v.get("_face")])


func _untrack(pid: int) -> void :
	if _tracked.erase(pid):
		news.append(["dx", pid])




func net_news() -> Array:
	for pid in _tracked.keys():
		var t: Dictionary = _tracked[pid]
		var v = t.v
		if not is_instance_valid(v) or v.is_queued_for_deletion():
			_untrack(pid)
			continue
		var rv: = v as RoVisual
		if rv.position.distance_squared_to(t.at) > 0.09 or rv.base_action != int(t.act):
			t.at = rv.position
			t.act = rv.base_action
			news.append(["dm", pid, rv.position, rv.base_action, rv.get("_face")])
	var out: = news
	news = []
	return out



func net_in(world: World, n: Array) -> void :
	match str(n[0]):
		"ds":
			if _net.has(n[1]) or world.run_root == null:
				return
			var v: = RoVisual.new()
			world.run_root.add_child(v)
			v.setup(RoAssets.sprite([str(n[2])]), Color.html(str(n[3])), 24, float(n[4]))
			v.position = n[5]
			v.play(int(n[6]), int(n[6]) != RoVisual.MOB_ATTACK)
			if n[7] is Vector3:
				v.face(n[7])
			v.scale = Vector3(0.3, 0.3, 0.3)
			v.create_tween().tween_property(v, "scale", Vector3.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			_net[n[1]] = v
		"dm":
			var v = _net.get(n[1])
			if v == null or not is_instance_valid(v):
				return


			if (v.position as Vector3).distance_to(n[2]) > 4.0:
				v.position = n[2]
			else:
				v.create_tween().tween_property(v, "position", n[2], 1.0 / 15.0)
			if n[4] is Vector3:
				v.face(n[4])
			v.play(int(n[3]), int(n[3]) != RoVisual.MOB_ATTACK, int(n[3]) == RoVisual.MOB_ATTACK)
		"dx":
			var v = _net.get(n[1])
			_net.erase(n[1])
			if v != null and is_instance_valid(v):
				var tw: Tween = v.create_tween()
				tw.tween_property(v, "scale", Vector3(1.0, 0.05, 1.0), 0.2)
				tw.tween_callback(v.queue_free)
