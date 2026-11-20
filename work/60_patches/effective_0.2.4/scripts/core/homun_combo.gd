extends RefCounted










const EVERY: = 10.0
const REACH: = 9.0
const RING: = 2.6
const AREA: = 3.6
const MULT: = 4.0
const STUN: = 1.6

static var _shots: = ""
static var _shot_n: = 0
static var _cycle: = 0

static var _test: = -1


static func tick(world: World, p: Player, delta: float) -> void :
	if _test < 0:
		_test = 1 if "--homcombo" in OS.get_cmdline_user_args() else 0
	var test: = _test == 1

	if test and p == world.player and p.class_id == "merchant" and not p.has_meta("homcombo_boot") and world.clock > 1.0:
		p.set_meta("homcombo_boot", true)


		if "--homcombo-clean" in OS.get_cmdline_user_args():
			GameData.set_meta("no_spawn", true)
			GameData.set_meta("tour_god", true)
			world.autopilot = false
			for e in world.enemies.duplicate():
				if is_instance_valid(e):
					e.queue_free()
			world.enemies.clear()
			if p.job2.is_empty():
				p.job_change(1)
			p.skills.clear()
			for k in 5:
				p.add_skill("call_homunculus")
			p.recompute()
			for i in 7:
				var a: = TAU * i / 7.0
				var e = world.spawn_enemy("poring", p.position + Vector3(5.5 + cos(a) * 1.6, 0, sin(a) * 1.6), true)
				if e != null:
					e.max_hp = 9000000000.0
					e.hp = 9000000000.0
					e.speed = 0.0
			world._rebuild_grid()
		if p.homun_node == null:
			p.homun_type = "homun_amistr"
			world.spawn_homun()
		for k in ["homun_filir", "homun_vanilmirth"]:
			world.spawn_homun_extra(p, k)
	if p.homun_node == null or not is_instance_valid(p.homun_node):
		return
	if not p.effects.has("lg_homun_combo") and not test:
		return
	if busy(p):
		return
	var t: = float(p.get_meta("homcombo_t", EVERY * 0.5)) - delta
	if t > 0.0:
		p.set_meta("homcombo_t", t)
		return
	var target: = _target(world, p)
	if target == null:
		p.set_meta("homcombo_t", 0.5)
		return
	p.set_meta("homcombo_t", (4.0 if test else EVERY) * p.cd_for("call_homunculus"))
	start(world, p, target)


static func busy(p: Player) -> bool:
	return bool(p.get_meta("homcombo_on", false))


static func _target(world: World, p: Player) -> Enemy:
	var best: Enemy = null
	for e in world.enemies_in_radius(p.position, REACH):
		if e.dead or e.prop != "":
			continue
		if best == null or (e.is_boss and not best.is_boss) or (e.is_boss == best.is_boss and e.hp > best.hp):
			best = e
	return best


static func _homs(p: Player) -> Array:
	var out: Array = []
	for n in [p.homun_node] + p.homun_extra_nodes:
		if n != null and is_instance_valid(n):
			out.append(n)
	return out


static func start(world: World, p: Player, target: Enemy) -> void :
	var homs: = _homs(p)
	if homs.is_empty():
		return
	p.set_meta("homcombo_on", true)
	for h in homs:
		h.combo = true
	var c: = target.position
	world.play_sound("h_levelup", 0.1, -4.0)
	var n: = homs.size()


	_cycle += 1
	var moments: = [["1_run", 0.2], ["2_circle", 0.8], ["3_leap", 1.3], ["4_impact", 1.5], ["5_after", 1.75]]
	if _cycle <= moments.size():
		_shot(world, str(moments[_cycle - 1][0]), float(moments[_cycle - 1][1]))

	for i in n:
		var h: Homunculus = homs[i]
		var ang: = TAU * i / n
		var spot: = c + Vector3(cos(ang), 0, sin(ang)) * RING
		spot.y = world.map.height_at(spot)
		h.visual.face((c - h.position) * Vector3(1, 0, 1))
		h.visual.play(RoVisual.MOB_WALK, true)
		var tw: Tween = h.create_tween()
		tw.tween_property(h, "position", spot, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var base_scale: Vector3 = h.visual.scale
		h.set_meta("combo_scale", base_scale)
		tw.parallel().tween_property(h.visual, "scale", base_scale * 1.5, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		world.spawn_fx("h_levelup", h.position, 0.5, 0.6)
		world.sprite_fx("fx_blessing", h.position, 0, 0.8, h)

	world._own_timer(0.45, func():
		if not is_instance_valid(world):
			return
		var glow: = Vfx.ground_glow(world.fx_root, c + Vector3(0, 0.05, 0), RING + 0.8, Color(0.6, 0.9, 1.0, 0.45))
		if glow != null:
			var gt: = glow.create_tween()
			gt.tween_interval(1.0)
			gt.tween_property(glow, "modulate:a", 0.0, 0.4)
			gt.tween_callback(glow.queue_free)
		for k in 3:
			Vfx.ring(world.fx_root, c + Vector3(0, 0.06, 0), RING + 0.3 + 0.3 * k, Color(0.7, 0.95, 1.0, 0.9), 0.7 + 0.15 * k)
		for i in n:
			var h: Homunculus = homs[i]
			if not is_instance_valid(h):
				continue
			var a0: = TAU * i / n
			var spin: Tween = h.create_tween()
			spin.tween_method( func(a: float):
				if is_instance_valid(h):
					var at: = c + Vector3(cos(a), 0, sin(a)) * RING
					at.y = world.map.height_at(at)
					h.position = at
					h.visual.face((c - at) * Vector3(1, 0, 1)), a0, a0 + TAU * 1.5, 0.7))

	world._own_timer(1.15, func():
		if not is_instance_valid(world):
			return
		Vfx.column(world.fx_root, c, Color(0.7, 0.95, 1.0))
		for h in homs:
			if not is_instance_valid(h):
				continue
			h.visual.play(RoVisual.MOB_ATTACK, false, true)
			var up: Tween = h.create_tween()
			up.tween_property(h, "position:y", h.position.y + 2.6, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			up.tween_property(h, "position", Vector3(c.x, world.map.height_at(c), c.z) + (h.position - c) * Vector3(0.35, 0, 0.35), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN))
	world._own_timer(1.47, func():
		if is_instance_valid(world) and world.hero_valid(p):
			_land(world, p, homs, c))

	world._own_timer(2.2, func():
		for h in homs:
			if is_instance_valid(h):
				h.combo = false
				if h.has_meta("combo_scale"):
					var back: Tween = h.visual.create_tween()
					back.tween_property(h.visual, "scale", h.get_meta("combo_scale"), 0.3)
		if is_instance_valid(p):
			p.set_meta("homcombo_on", false))


static func _land(world: World, p: Player, homs: Array, c: Vector3) -> void :
	var dmg: = 0.0
	var kinds: = {}
	for h in homs:
		if is_instance_valid(h):
			var d: Dictionary = GameData.HOMUNCULI.get(h.kind, {})
			dmg += p.homun_atk() * float(d.get("dmg", 1.0)) * float(d.get("hits", 1)) * h._power()
			kinds[h.kind] = true
	dmg *= MULT
	world.shake(0.45)

	for h in homs:
		if is_instance_valid(h):
			Vfx.column(world.fx_root, h.position, Color(0.75, 0.95, 1.0))
	world.sprite_fx("fx_blessing", c, 0, 1.6)
	world.spawn_fx("shockwave", c, 2.2, 1.0)
	world.spawn_fx("earthhit", c, 1.8, 1.0)
	world.spawn_fx("bowling", c, 1.4, 1.0)
	Vfx.quake(world.fx_root, c, AREA, Color(0.8, 0.95, 1.0, 0.9))
	Vfx.burst(world.fx_root, c + Vector3(0, 0.6, 0), AREA * 0.55, Color(0.75, 0.95, 1.0))
	Vfx.ring(world.fx_root, c + Vector3(0, 0.06, 0), AREA, Color(0.85, 1.0, 1.0, 0.95), 0.45)
	world.play_sound("homun_amistr", 0.0, -2.0)
	world.damage_tag = "homun_combo"
	world.damage_by = p
	var near: = world.enemies_in_radius(c, AREA)
	for e in near:
		var away: = ((e.position - c) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, dmg, away * 3.0, "skill", "neutral", "homun_combo")
		if kinds.has("homun_amistr") and not e.dead:
			world.apply_status(e, "stun", STUN)
	if kinds.has("homun_filir") and not near.is_empty():
		var best: Enemy = near[0]
		for e in near:
			if e.hp > best.hp:
				best = e
		if is_instance_valid(best) and not best.dead:
			world.spawn_fx("sonicblow", best.position + Vector3(0, 0.5, 0), 1.0, 1.0)
			world.damage_enemy(best, dmg, Vector3.ZERO, "skill", "neutral", "homun_combo")
	if kinds.has("homun_vanilmirth"):
		for k in 3:
			var el: String = ["fire", "water", "wind"][k]
			var at: = c + Vector3(cos(TAU * k / 3.0), 0, sin(TAU * k / 3.0)) * 1.8
			var col: Color = {"fire": Color(1, 0.45, 0.15), "water": Color(0.5, 0.75, 1.0), "wind": Color(0.8, 1.0, 0.6)}[el]
			var fx: String = {"fire": "firehit1", "water": "icecrash", "wind": "lightning"}[el]
			world.spawn_fx(fx, at, 1.0, 1.0)
			var sk: = {"name": "Vanilmirth", "shape": "square", "tick": 0.5, "element": el, "color": col, "fx": fx, "fx_size": 0.35, "fx_intensity": 0.5}
			world.ground_zone(at, sk, 1.4, dmg * 0.1, 0.0, 3.0)
	if kinds.has("homun_lif"):
		for h in world.heroes:
			if not h.downed and h.position.distance_to(c) <= 12.0:
				h.heal(h.max_hp * 0.12, world)
				world.spawn_fx("cure", h.position, 1.0, 0.9, h)


static func _shot(world: World, name: String, delay: float) -> void :
	if _shots == "":
		for a in OS.get_cmdline_user_args():
			if str(a).begins_with("--homcombo-shots="):
				_shots = str(a).substr(17)
	if _shots == "" or DisplayServer.get_name() == "headless" or _shot_n >= 21:
		return
	_shot_n += 1
	var idx: = _shot_n
	world._own_timer(delay, func():
		await RenderingServer.frame_post_draw
		if is_instance_valid(world):
			DirAccess.make_dir_recursive_absolute(_shots)
			world.get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [_shots, idx, name]))
