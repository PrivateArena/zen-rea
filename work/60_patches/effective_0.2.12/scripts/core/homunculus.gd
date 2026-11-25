class_name Homunculus
extends Node3D







var world: World
var player: Player
var kind: = ""
var visual: RoVisual
var _attack_t: = 1.0
var _heal_t: = 0.0

var slot: = 0

var _mutated: = false
var _special_t: = 0.0


var _act_t: = 0.0

var combo: = false



var puppet: = false

var net_flags: = 0

var _evolved: = false


func setup(p_world: World, p_player: Player, p_kind: String) -> void :
	world = p_world
	player = p_player
	kind = p_kind
	_look()


	var at: = player.position + Vector3(-1.0, 0, 0.8)
	position = at if world.map.is_walkable(at) else player.position
	position.y = world.map.height_at(position)
	_heal_t = float(_def().get("heal_every", 0.0))



func _look() -> void :
	if visual != null:
		visual.queue_free()
	_mutated = (net_flags & 2) != 0 if puppet else player.homun_mutated()
	_evolved = (net_flags & 1) != 0 if puppet else (player.reborn or _mutated)
	_special_t = GameData.MUTATION_SPECIAL * 0.5 + slot * 1.75
	visual = RoVisual.new()
	add_child(visual)
	var evolved: = _evolved and RoAssets.has_sprite(kind + "_h")
	visual.setup(RoAssets.sprite([kind + "_h" if evolved else kind]), Color(0.8, 0.9, 1.0), 28, 0.6)
	visual.scale = Vector3.ONE * (1.6 if _mutated else 1.3)
	visual.show_through(0.35)


func _def() -> Dictionary:
	return GameData.HOMUNCULI.get(kind, {})



func _power() -> float:
	var lv: = maxi(1, player.homun_level())



	var pw: = (1.0 + GameData.HOMUN_PER_LEVEL * (lv - 1)) * player.summon_power() * (1.0 + float(player.effects.get("homun_power", 0.0))) * GameData.HOMUN_POWER

	if _mutated:
		pw *= 1.0 + GameData.MUTATION_POWER + GameData.MUTATION_PACK * player.homun_extra.size()
	return pw


func tick(delta: float) -> void :
	if player == null or not is_instance_valid(player):
		return
	if combo:
		return
	_follow(delta)
	if _mutated != player.homun_mutated():
		_look()
		world.spawn_fx("h_levelup", position, 1.0, 1.0)
	var d: = _def()
	if _mutated:
		_special_t -= delta
		if _special_t <= 0.0 and _special(d):

			_special_t = GameData.MUTATION_SPECIAL * player.cd_for("call_homunculus")

	if d.has("heal"):
		_heal_t -= delta
		if _heal_t <= 0.0:
			_heal_t = float(d.heal_every)
			var who: Player = null
			var low: = 1.0
			for h in world.heroes:
				if h.downed or h.hp >= h.max_hp or h.position.distance_to(position) > float(d.get("heal_range", 8.0)):
					continue
				if h.hp / maxf(1.0, h.max_hp) < low:
					low = h.hp / maxf(1.0, h.max_hp)
					who = h
			if who != null:
				who.heal(who.max_hp * float(d.heal) * _power(), world, false, "homun", player)
				world.spawn_fx("holyhit", who.position, 0.8, 0.7, who)
	_attack_t -= delta
	if _attack_t > 0.0:
		return
	var target: = _prey(float(d.get("range", 6.0)) + player.summon_reach())
	if target == null:
		_attack_t = 0.3
		return

	_attack_t = float(d.every) * Doram.aspd_share(player)
	visual.face((target.position - position) * Vector3(1, 0, 1))
	visual.play(RoVisual.MOB_ATTACK, false, true)
	_act_t = 0.6
	_net_swing_out(target.position)
	world.play_sound(kind, 0.2, -10.0)

	var dmg: = player.homun_atk() * float(d.dmg) * _power() * Doram.summon_hits(player)
	world.damage_tag = kind
	world.damage_by = player
	match kind:
		"homun_amistr":

			world.spawn_fx("bowling", target.position, 0.8, 0.8)
			for e in world.enemies_in_radius(target.position, float(d.area) * sqrt(player.area_mult)):
				var away: = ((e.position - target.position) * Vector3(1, 0, 1)).normalized()
				world.damage_enemy(e, dmg, away * float(d.knock), "skill", "neutral", kind)
				if randf() < float(d.get("stun", 0.0)) and not e.dead:
					world.apply_status(e, "stun", 1.2)
		"homun_vanilmirth":

			var el: String = ["fire", "water", "wind"].pick_random()
			var fx: String = {"fire": "firehit1", "water": "icecrash", "wind": "lightning"}[el]
			world.spawn_fx(fx, target.position, 0.8, 0.9)
			for e in world.enemies_in_radius(target.position, float(d.area) * sqrt(player.area_mult)):
				world.damage_enemy(e, dmg, Vector3.ZERO, "skill", el, kind)

			if d.has("puddle"):
				var col: Color = {"fire": Color(1, 0.45, 0.15), "water": Color(0.5, 0.75, 1.0), "wind": Color(0.8, 1.0, 0.6)}[el]
				var sk: = {"name": "Vanilmirth", "shape": "square", "tick": 0.5, "element": el, "color": col, 
					"fx": {"fire": "firehit1", "water": "icecrash", "wind": "lightning"}[el], "fx_size": 0.35, "fx_intensity": 0.5}
				world.ground_zone(target.position, sk, 1.2, dmg * 0.25, 0.0, float(d.puddle))
		_:

			for i in int(d.get("hits", 1)):
				if is_instance_valid(target) and not target.dead:
					world.damage_enemy(target, dmg, Vector3.ZERO, "skill", "neutral", kind)
			world.spawn_fx("hit", target.position + Vector3(0, 0.6, 0), 0.6, 0.8)





func _prey(reach: float) -> Enemy:
	var best: Enemy = null
	for e in world.enemies_in_radius(position, reach):

		if e.dead or e.prop != "" or e.acid_until <= world.clock:
			continue
		if best == null or (e.is_boss and not best.is_boss) or (e.is_boss == best.is_boss and e.acid_frail > best.acid_frail):
			best = e
	return best if best != null else world.nearest_enemy(position, reach)






func _special(d: Dictionary) -> bool:
	var dmg: = player.homun_atk() * float(d.dmg) * _power()
	world.damage_tag = kind
	world.damage_by = player
	match kind:
		"homun_lif":
			var any: = false
			for h in world.heroes:
				if not h.downed and h.position.distance_to(position) <= 12.0:
					h.heal(h.max_hp * 0.15 * minf(_power(), 3.0), world)
					world.spawn_fx("cure", h.position, 1.0, 0.9, h)
					any = true
			if not any:
				return false
			Vfx.ring(world.fx_root, position + Vector3(0, 0.05, 0), 6.0, Color(0.6, 1.0, 0.6), 0.5)
			world.play_sound("heal", 0.1, -6.0)
		"homun_amistr":
			var near: = world.enemies_in_radius(position, 4.0)
			if near.is_empty():
				return false
			world.spawn_fx("shockwave", position, 1.3, 1.0)
			world.spawn_fx("earthhit", position, 1.2, 0.9)
			Vfx.ring(world.fx_root, position + Vector3(0, 0.05, 0), 4.0, Color(0.9, 0.75, 0.5), 0.4)
			for e in near:
				var away: = ((e.position - position) * Vector3(1, 0, 1)).normalized()
				world.damage_enemy(e, dmg * 3.0, away * 6.0, "skill", "earth", kind)
				if not e.dead:
					world.apply_status(e, "stun", 1.5)
			world.shake(0.15)
		"homun_filir":
			var best: Enemy = null
			for e in world.enemies_in_radius(position, 8.0):
				if best == null or e.max_hp > best.max_hp:
					best = e
			if best == null:
				return false
			visual.face((best.position - position) * Vector3(1, 0, 1))
			world.spawn_fx("sonicblow", best.position + Vector3(0, 0.5, 0), 1.0, 1.0)
			world.damage_enemy(best, dmg * 8.0, Vector3.ZERO, "skill", "neutral", kind)
			world.shake(0.1)
		"homun_vanilmirth":
			var near: = world.enemies_in_radius(position, 9.0)
			if near.is_empty():
				return false
			near.shuffle()
			for i in mini(6, near.size()):
				var e: Enemy = near[i]
				var el: String = ["fire", "water", "wind"].pick_random()
				var fx: String = {"fire": "firehit1", "water": "icecrash", "wind": "lightning"}[el]
				var at: = e.position
				world._own_timer(0.12 * i, func():
					world.spawn_fx(fx, at, 1.0, 1.0)
					world.damage_tag = kind
					world.damage_by = player
					for t in world.enemies_in_radius(at, float(d.area)):
						world.damage_enemy(t, dmg * 1.5, Vector3.ZERO, "skill", el, kind)
					var col: Color = {"fire": Color(1, 0.45, 0.15), "water": Color(0.5, 0.75, 1.0), "wind": Color(0.8, 1.0, 0.6)}[el]
					var sk: = {"name": "Vanilmirth", "shape": "square", "tick": 0.5, "element": el, "color": col, 
						"fx": fx, "fx_size": 0.35, "fx_intensity": 0.5}
					world.ground_zone(at, sk, 1.4, dmg * 0.3, 0.0, float(d.get("puddle", 2.5))))
	visual.play(RoVisual.MOB_ATTACK, false, true)
	_act_t = 0.6
	_net_swing_out(position + visual._face)
	world.play_sound(kind, 0.1, -6.0)
	world.spawn_fx("h_levelup", position, 0.6, 0.6)
	return true




func _follow(delta: float, catch_up: = false) -> void :
	var spot: = player.position - player.facing * 0.7 + Vector3(-1.4, 0, 0.4).rotated(Vector3.UP, slot * 2.1)

	if not world.map.is_walkable(spot):
		spot = player.position
	var to: = (spot - position) * Vector3(1, 0, 1)
	var d: = to.length()


	if d > 12.0 or not world.map.is_walkable(position):
		position = Vector3(spot.x, world.map.height_at(spot), spot.z)
	elif d > 0.4:
		var speed: = player.move_speed * 1.15 * (1.5 if d > 3.0 else 1.0)
		if catch_up:
			speed = maxf(speed, d * 3.0)
		var step: = to / d * minf(d, speed * delta)
		var p: = world.map.slide(position, step)
		position = Vector3(p.x, world.map.height_at(p), p.z)
		visual.face(to)
		if _act_t <= 0.0:
			visual.play(RoVisual.MOB_WALK)
	elif _act_t <= 0.0:
		visual.play(RoVisual.MOB_IDLE)



	_act_t = maxf(0.0, _act_t - delta)
	position.y = world.map.height_at(position)





func _net_swing_out(at: Vector3) -> void :
	if world.net.recording():
		world.net.record(["hm", player.slot, slot, at])



func net_key() -> String:
	return "%s:%d:%d" % [kind, (1 if _evolved else 0) | (2 if _mutated else 0), slot]



static func net_keys(h: Player) -> Array:
	var out: = []
	for n in [h.homun_node] + h.homun_extra_nodes:
		if is_instance_valid(n) and n is Homunculus and not (n as Node).is_queued_for_deletion():
			out.append((n as Homunculus).net_key())
	return out




static func net_sync(world: World, h: Player, keys: Array) -> void :
	if world.run_root == null or not is_instance_valid(h):
		return
	var old: Array = []
	for n in [h.homun_node] + h.homun_extra_nodes:
		if is_instance_valid(n):
			old.append(n)
	var out: Array = []
	for i in keys.size():
		var parts: = str(keys[i]).split(":")
		var kind_i: = parts[0]
		if not GameData.HOMUNCULI.has(kind_i):
			continue
		var flags: = int(parts[1]) if parts.size() > 1 else 0
		var at: = int(parts[2]) if parts.size() > 2 else i
		var n: Homunculus = null
		for o in old:
			if o is Homunculus and (o as Homunculus).puppet and o.kind == kind_i and o.slot == at:
				n = o
				break
		if n != null:
			old.erase(n)
			if n.net_flags != flags:
				n.net_flags = flags
				n._look()
		else:
			n = Homunculus.new()
			n.puppet = true
			n.net_flags = flags
			n.slot = at
			world.run_root.add_child(n)
			n.setup(world, h, kind_i)
		out.append(n)
	for o in old:
		(o as Node).queue_free()
	h.homun_node = out[0] if not out.is_empty() else null
	h.homun_extra_nodes = out.slice(1)
	if h == world.player:
		world.homun = h.homun_node



static func puppets_tick(world: World, delta: float) -> void :
	for h in world.heroes:
		if not is_instance_valid(h) or h.downed:
			continue
		for n in [h.homun_node] + h.homun_extra_nodes:
			if is_instance_valid(n) and n is Homunculus and (n as Homunculus).puppet:
				(n as Homunculus)._follow(delta, true)



static func net_swing(world: World, ev: Array) -> void :
	if ev.size() < 4 or int(ev[1]) < 0 or int(ev[1]) >= world.heroes.size():
		return
	var h: Player = world.heroes[int(ev[1])]
	if not is_instance_valid(h):
		return
	for n in [h.homun_node] + h.homun_extra_nodes:
		if is_instance_valid(n) and n is Homunculus and (n as Homunculus).puppet and n.slot == int(ev[2]):
			var hm: = n as Homunculus
			if ev[3] is Vector3:
				hm.visual.face(((ev[3] as Vector3) - hm.position) * Vector3(1, 0, 1))
			hm.visual.play(RoVisual.MOB_ATTACK, false, true)
			hm._act_t = 0.6
			return




static func net_promote(world: World) -> void :
	for h in world.heroes:
		if not is_instance_valid(h):
			continue
		var had: = false
		for n in [h.homun_node] + h.homun_extra_nodes:
			if is_instance_valid(n) and n is Homunculus and (n as Homunculus).puppet:
				had = true
				(n as Node).queue_free()
		if not had:
			continue
		h.homun_node = null
		h.homun_extra_nodes.clear()
		if h == world.player:
			world.homun = null
			if h.homun_type != "":
				world.spawn_homun(h)
