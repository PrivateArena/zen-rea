class_name Dots
extends RefCounted










var burning: Array = []
var bleeding: Array = []

var _spread_t: = 0.0
var _fx_at: = 0.0
var _fx_n: = 0




func on_hit(world: World, src: Player, e: Enemy, base: float, source: String, tag: String) -> void :
	if e.dead or e.hp <= 0.0 or base <= 0.0:
		return
	var burn: = 0.0
	var bleed: = 0.0
	if source == "basic":
		burn = float(src.effects.get("burn_hit", 0.0))
		bleed = float(src.effects.get("bleed_hit", 0.0))

		if burn > 0.0 and randf() < burn:
			burn_on(world, e, base, "burn", src)
		if bleed > 0.0 and randf() < bleed:
			bleed_on(world, e, base, "bleed", src)
		return
	var sk: Dictionary = GameData.SKILLS.get(tag.trim_prefix("proc:").get_slice("@", 0), {})

	burn = maxf(float(sk.get("burn_chance", 0.0)), float(src.effects.get("skill_burn", 0.0)))
	bleed = float(sk.get("bleed_chance", 0.0))
	if burn > 0.0 and randf() < burn:
		burn_on(world, e, base, tag, src)
	if bleed > 0.0 and randf() < bleed:
		bleed_on(world, e, base, tag, src, false, int(sk.get("bleed_stacks", 1)))







func burn_on(world: World, e: Enemy, base: float, tag: String, by: Player, pool: = -1.0, heat: = 0) -> void :
	var lit: = e.burn_time > 0.0
	var t: = GameData.BURN_TIME * (1.0 + float(by.effects.get("burn_time", 0.0)) if by != null else 1.0)
	var add: = pool
	if pool < 0.0:

		var power: = 1.0 + float(by.effects.get("burn_power", 0.0)) if by != null else 1.0
		add = base * GameData.BURN_IGNITE * (1.0 + GameData.BURN_MAGIC * _int_share(tag)) * power * t / GameData.BURN_TIME
	if add <= 0.0:
		return
	if not lit:
		e.burn_pool = 0.0

		e.burn_heat = maxi(heat, int(by.effects.get("burn_heat_start", 0.0)) if by != null else 0)
		e.set_meta("burn_top", 0.0)
		e.set_meta("burn_heat_at", world.clock + heat_gap(world, e))
	elif pool < 0.0 and world.clock >= float(e.get_meta("burn_heat_at", 0.0)):
		e.burn_heat += 1
		e.set_meta("burn_heat_at", world.clock + heat_gap(world, e))
	if add >= float(e.get_meta("burn_top", 0.0)):
		e.set_meta("burn_top", add)
		e.burn_tag = tag
		e.burn_by = by
	e.burn_pool += add
	e.burn_time = maxf(e.burn_time, t)
	e.set_meta("burn_full", e.burn_time)
	_burn_mark(e)
	if not lit:
		e.burn_tick = 0.5
		burning.append(e)
		e._update_tint()
		if _fx_ok(world, by):
			var keep: = world.hero_fx_begin(by)
			world.spawn_fx("firehit1", e.position + Vector3(0, 0.5, 0), 0.35, 0.6)
			world.hero_fx_end(keep)





static func heat_gap(world: World, e: Enemy) -> float:
	var gap: = GameData.BURN_HEAT_EVERY + GameData.BURN_HEAT_EVERY_PER * e.burn_heat
	return gap * (GameData.WEB_HEAT_EVERY if e.web_until > world.time else 1.0)






func bleed_on(world: World, e: Enemy, base: float, tag: String, by: Player, chained: = false, stacks: = 1) -> void :
	if e.blood_stacks <= 0:
		bleeding.append(e)
		if chained:
			e.set_meta("blood_chained", true)
	if not chained and e.has_meta("blood_chained"):
		e.remove_meta("blood_chained")

	var power: = 1.0 + float(by.effects.get("bleed_power", 0.0)) if by != null and not chained else 1.0
	e.blood += base * GameData.BLEED_STORE * stacks * power
	e.blood_stacks += stacks
	e.blood_time = GameData.BLEED_TIME
	e.blood_tag = tag
	e.blood_by = by
	e._update_tint()
	_count(e, by)

	if e.blood_stacks >= burst_at(by):
		e.blood_time = 0.0




static func _int_share(tag: String) -> float:
	if tag in GameData.MAGIC_TAGS:
		return 1.0
	var id: = GameData.skill_of_tag(tag)
	return float(GameData.skill_stats(id).get("int", 0.0)) if id != "" else 0.0




func _burn_mark(e: Enemy) -> void :
	if e.burn_heat > 0:
		StatusMarks.set_mark(e, "burn", e.burn_heat, 0)
	else:
		StatusMarks.set_mark(e, "burn", ceili(maxf(0.0, e.burn_time) / maxf(0.01, float(e.get_meta("burn_full", GameData.BURN_TIME))) * StatusMarks.BURN_STEPS), 
			StatusMarks.BURN_STEPS)



func burst_at(by: Player) -> int:
	return maxi(1, GameData.BLEED_BURST_AT - int(by.effects.get("bleed_at", 0.0)) if by != null else GameData.BLEED_BURST_AT)






func burst(world: World, e: Enemy, pool: Variant = null) -> void :
	var by: Player = e.blood_by if world.hero_valid(e.blood_by) else world.player
	var dmg: = e.blood * GameData.BLEED_BURST_MULT * (1.0 + float(by.effects.get("bleed_dmg", 0.0)) if by != null else 1.0)
	var tag: = e.blood_tag
	var at: = e.position

	var per: = e.blood / maxf(1.0, e.blood_stacks) / GameData.BLEED_STORE
	var chain: = by != null and float(by.effects.get("bleed_chain", 0.0)) > 0.0 and not e.has_meta("blood_chained")
	if e.has_meta("blood_chained"):
		e.remove_meta("blood_chained")
	e.blood = 0.0
	e.blood_stacks = 0
	e.blood_time = 0.0
	bleeding.erase(e)
	count_clear(e)
	e._update_tint()
	if dmg <= 0.0:
		return
	var keep_tag: = world.damage_tag
	var keep_by: = world.damage_by
	world.damage_by = by
	world.dot_color = GameData.BLEED_COLOR

	world.dot_can_crit = true
	if not e.dead:
		world.damage_enemy(e, dmg, Vector3.ZERO, "poison", "neutral", tag)
	for o in world.enemies_in_radius(at, GameData.BLEED_SPLASH_RANGE):
		if o == e or o.dead:
			continue
		if pool != null:
			_pool_splash(pool, o, dmg * GameData.BLEED_SPLASH, tag, by, per * GameData.BLEED_CHAIN_SHARE if chain else 0.0)
			continue
		world.damage_enemy(o, dmg * GameData.BLEED_SPLASH, Vector3.ZERO, "poison", "neutral", tag)
		if chain and not o.dead and o.hp > 0.0:
			bleed_on(world, o, per * GameData.BLEED_CHAIN_SHARE, tag, by, true)
	world.dot_can_crit = false
	world.dot_color = Color(0, 0, 0, 0)
	world.damage_tag = keep_tag
	world.damage_by = keep_by



	var heal: = float(by.effects.get("bleed_heal", 0.0)) if by != null else 0.0
	if heal > 0.0 and by.hp > 0.0:
		by.heal(by.max_hp * heal, world, false, "vampire_blood")
	if _fx_ok(world, by):
		var keep: = world.hero_fx_begin(by)
		_gore(world, at, e)
		world.hero_fx_end(keep)








func burst_many(world: World, list: Array) -> void :
	var pool: = {}
	for e in list:
		if is_instance_valid(e):
			burst(world, e, pool)
	if pool.is_empty():
		return
	var keep_tag: = world.damage_tag
	var keep_by: = world.damage_by
	world.dot_color = GameData.BLEED_COLOR
	world.dot_can_crit = true
	for s in pool.values():
		var o = s[0]
		if not is_instance_valid(o) or o.dead:
			continue
		world.damage_by = s[3]
		world.damage_enemy(o, float(s[1]), Vector3.ZERO, "poison", "neutral", str(s[2]))
		if int(s[5]) > 0 and not o.dead and o.hp > 0.0:
			bleed_on(world, o, float(s[4]) / int(s[5]), str(s[2]), s[3], true, int(s[5]))
	world.dot_can_crit = false
	world.dot_color = Color(0, 0, 0, 0)
	world.damage_tag = keep_tag
	world.damage_by = keep_by




static func _pool_splash(pool: Dictionary, o: Enemy, dmg: float, tag: String, by: Player, chain: float) -> void :
	var k: = "%d|%s" % [o.get_instance_id(), tag]
	if not pool.has(k):
		pool[k] = [o, 0.0, tag, by, 0.0, 0]
	var s: Array = pool[k]
	s[1] = float(s[1]) + dmg
	if chain > 0.0:
		s[4] = float(s[4]) + chain
		s[5] = int(s[5]) + 1




func _gore(world: World, at: Vector3, e: Enemy) -> void :
	var h: float = e.visual.height() if e.visual != null else 1.2
	var big: = 1.4 if e.is_boss else 1.0
	Vfx.blood_spray(world.fx_root, at, h * 0.55, big)
	world.hero_sound("bleed_squish", 0.05, -2.0, randf_range(0.85, 1.0))
	world.hero_sound("bleed_burst", 0.08, -6.0, randf_range(0.95, 1.1))
	if not Vfx.hidden():
		world.shake(0.06 * big)



func update(world: World, delta: float) -> void :
	_spread(world, delta)
	var crowd: = 1.0 + minf(GameData.BURN_CROWD_MAX, GameData.BURN_CROWD * burning.size())
	world.dot_color = GameData.BURN_COLOR
	for i in range(burning.size() - 1, -1, -1):
		var e = burning[i]
		if not is_instance_valid(e):
			burning.remove_at(i)
			continue
		if e.dead:

			burning.remove_at(i)
			if e.burn_time > 0.0:
				_jump(world, e)
			e.burn_time = 0.0
			continue
		e.burn_time -= delta
		e.burn_tick -= delta

		_burn_mark(e)
		if e.burn_tick <= 0.0 or e.burn_time <= 0.0:
			e.burn_tick = maxf(0.0, e.burn_tick) + 0.5


			var part: float = e.burn_pool * minf(1.0, 0.5 / maxf(0.5, e.burn_time + 0.5))
			e.burn_pool -= part
			var hot: float = 1.0 + GameData.BURN_HEAT * e.burn_heat
			e.burn_dps = part * 2.0 * hot
			world.damage_by = e.burn_by if world.hero_valid(e.burn_by) else world.player
			if part > 0.0:
				world.damage_enemy(e, part * hot * crowd, Vector3.ZERO, "poison", "fire", e.burn_tag)
		if e.burn_time <= 0.0 and i < burning.size() and burning[i] == e:
			burning.remove_at(i)
			e.burn_pool = 0.0
			e.burn_heat = 0
			e._update_tint()
			StatusMarks.clear_mark(e, "burn")
	world.dot_color = Color(0, 0, 0, 0)

	var due: Array = []
	for i in range(bleeding.size() - 1, -1, -1):
		var e = bleeding[i]
		if not is_instance_valid(e):
			bleeding.remove_at(i)
			continue
		e.blood_time -= delta

		if e.dead or e.blood_time <= 0.0:
			due.append(e)
	if not due.is_empty():
		burst_many(world, due)
	world.damage_by = null




func _spread(world: World, delta: float) -> void :
	_spread_t -= delta
	if _spread_t > 0.0 or burning.is_empty():
		return
	_spread_t = GameData.BURN_SPREAD_EVERY
	for i in mini(GameData.BURN_SPREAD_N, burning.size()):
		var e = burning[randi() % burning.size()]
		if not is_instance_valid(e) or e.dead:
			continue
		for o in world.nearest_enemies(e.position, GameData.BURN_SPREAD_RANGE, 4):
			if o != e and not o.dead and o.burn_time <= 0.0:
				var by: Player = e.burn_by if world.hero_valid(e.burn_by) else world.player
				burn_on(world, o, 0.0, e.burn_tag, by, e.burn_pool * GameData.BURN_PASS, int(e.burn_heat * GameData.BURN_PASS))
				if _fx_ok(world, by):
					var keep: = world.hero_fx_begin(by)
					world.burn_ember(e.position, o.position)
					world.hero_fx_end(keep)
				break




func _jump(world: World, e: Enemy) -> void :
	var by: Player = e.burn_by if world.hero_valid(e.burn_by) else world.player
	world.damage_by = by
	var n: = 0

	var jumps: = GameData.BURN_JUMPS + (int(by.effects.get("burn_jumps", 0.0)) if by != null else 0)
	for o in world.nearest_enemies(e.position, GameData.BURN_JUMP_RANGE, jumps + 4):
		if n >= jumps:
			break
		if o == e or o.dead or o.burn_time > 0.0:
			continue
		burn_on(world, o, 0.0, e.burn_tag, by, e.burn_pool * GameData.BURN_PASS, int(e.burn_heat * GameData.BURN_PASS))
		n += 1
		if _fx_ok(world, by):
			var keep: = world.hero_fx_begin(by)
			world.burn_ember(e.position, o.position)
			world.hero_fx_end(keep)
	var blast: = by != null and float(by.effects.get("burn_blast", 0.0)) > 0.0
	if blast:
		for o in world.enemies_in_radius(e.position, GameData.BURN_BLAST_RANGE):
			if not o.dead:
				world.damage_enemy(o, e.burn_dps * GameData.BURN_BLAST, Vector3.ZERO, "poison", "fire", e.burn_tag)
	if (n > 0 or blast) and _fx_ok(world, by):
		var keep: = world.hero_fx_begin(by)
		world.spawn_fx("tetravortex/tetra_01_fire_sub_explosion/tetra_01_fire_sub_expn", e.position + Vector3(0, 0.3, 0), 0.5 if blast else 0.3, 1.0)
		world.hero_sound("burn_jump", 0.1, -8.0 if blast else -12.0)
		world.hero_fx_end(keep)







func _fx_ok(world: World, by: Player = null) -> bool:
	if world.hero_fx_alpha(by) <= 0.01 and not world.net.recording():
		return false
	if world.time - _fx_at > 0.25:
		_fx_at = world.time
		_fx_n = 0
	_fx_n += 1
	return _fx_n <= 6




func _count(e: Enemy, by: Player) -> void :
	StatusMarks.set_mark(e, "bleed", e.blood_stacks, burst_at(by))


func count_clear(e: Enemy) -> void :
	StatusMarks.clear_mark(e, "bleed")



func forget(e: Enemy) -> void :
	burning.erase(e)
	bleeding.erase(e)
	e.burn_time = 0.0
	e.burn_pool = 0.0
	e.burn_heat = 0
	e.blood = 0.0
	e.blood_stacks = 0
	StatusMarks.clear_mark(e, "burn")
	count_clear(e)
	e._update_tint()



func clear() -> void :
	burning.clear()
	bleeding.clear()
