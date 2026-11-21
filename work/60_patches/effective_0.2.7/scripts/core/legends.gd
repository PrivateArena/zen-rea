class_name Legends
extends RefCounted

















static func _is_bash(tag: String) -> bool:
	return tag.trim_prefix("proc:").begins_with("bash")




static func damage_mult(world: World, p: Player, e: Enemy, tag: String) -> float:
	var m: = 1.0
	if p.effects.has("lg_track") and p.lg_mark == e and world.time < p.lg_mark_until:
		m *= 1.0 + float(p.effects.lg_track)
	if p.effects.has("lg_bash") and _is_bash(tag):
		m *= 1.0 + GameData.lg_bash_bonus(p.lg_bash_kills)
	if p.lg_fury > 0 and tag in GameData.LG_FURY_TAGS:
		m *= 1.0 + GameData.LG_FURY_STEP * p.lg_fury

	if p.effects.has("lg_soul_chain"):
		m *= World.SoulLinker.damage_mult(world, p, e, tag)
	return m




static func fury_start(world: World, p: Player) -> void :
	if p.lg_fury > 0 and world.clock > p.lg_fury_until:
		p.lg_fury = 0




static func fury_hit(world: World, p: Player) -> void :
	if not p.effects.has("lg_berserk") or p.lg_fury >= GameData.LG_FURY_MAX:
		return
	p.lg_fury += 1
	if p.lg_fury == GameData.LG_FURY_MAX:
		world.label_over(p, TranslationServer.translate("¡Berserk!"), Color(1.0, 0.3, 0.2))
		world.spawn_fx("cure", p.position, 1.0, 0.6, p)
		world.play_sound("fury", 0.1, -6.0, 1.2)




static func fury_end(world: World, p: Player, _broke: bool) -> void :
	p.lg_fury_until = world.clock + GameData.LG_FURY_WINDOW



static func after_hit(world: World, p: Player, e: Enemy, tag: String) -> void :


	if p.class_id == "taekwon":
		World.SoulLinker.after_hit(world, p, e, tag)


	if p.effects.has("lg_track") and tag.begins_with("tracking") and not e.dead:
		var live: = is_instance_valid(p.lg_mark) and not p.lg_mark.dead and world.time < p.lg_mark_until
		if not live or p.lg_mark == e:
			mark(world, p, e)



static func mark(world: World, p: Player, e: Enemy) -> void :
	var fresh: = p.lg_mark != e or world.time >= p.lg_mark_until
	p.lg_mark = e
	p.lg_mark_until = world.time + GameData.LG_TRACK_TIME
	if is_instance_valid(p.lg_mark_fx):
		if not fresh:
			return
		p.lg_mark_fx.queue_free()
	p.lg_mark_fx = Vfx.magic_circle(e, Vector3.ZERO, 0.9 + e.radius, Color(1.0, 0.25, 0.2, 0.75), GameData.LG_TRACK_TIME, "mvp_rune", 1.6, -1, true)
	if not fresh:
		return
	world.side_word(e, TranslationServer.translate("¡Marcado!"), Color(1.0, 0.4, 0.3))
	world.play_sound("guard_block", 0.2, -8.0, 1.6)



static func on_kill(world: World, p: Player, e: Enemy, tag: String, base: float, element: String) -> void :
	var fx: = p.effects

	if fx.has("lg_soul_chain"):
		World.SoulLinker.on_kill(world, p, e)


	if fx.has("lg_bash") and _is_bash(tag):
		p.lg_bash_kills += 1


		var now: = Time.get_ticks_msec()
		if now - int(p.get_meta("myst_soul", 0)) >= 120:
			p.set_meta("myst_soul", now)
			var soul: = Vector3(0, e.visual.height() * 0.6, 0)
			world._bounce_trace(e.position + soul, p.position + Vector3(0, 1.0, 0), Color(1.0, 0.75, 0.3))
		if p.lg_bash_kills % 30 == 0 and now - int(p.get_meta("myst_said", -100000)) >= 3000:
			p.set_meta("myst_said", now)
			world.number(p.position + Vector3(0, 2.4, 0), TranslationServer.translate("Mysteltainn: Bash +%d%%") % roundi(
				100.0 * GameData.lg_bash_bonus(p.lg_bash_kills)), Color(1.0, 0.75, 0.3), true)
			Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 2.2, Color(1.0, 0.75, 0.3, 0.9), 0.35)

	if fx.has("lg_mammon") and tag.begins_with("mammonite"):
		world.gain_zeny(roundi(GameData.LG_MAMMON_ZENY * p.loot_mult), e.position)

	if fx.has("lg_track") and p.lg_mark == e and world.time < p.lg_mark_until:
		var best: Enemy = null
		for o in world.enemies_in_radius(e.position, GameData.LG_TRACK_JUMP):
			if o != e and not o.dead and o.prop == "" and (best == null or o.hp > best.hp):
				best = o
		p.lg_mark = null
		if best != null:
			world._bounce_trace(e.position, best.position, Color(1.0, 0.3, 0.25))
			mark(world, p, best)


static func _nearest(world: World, at: Vector3, reach: float, skip: Enemy) -> Enemy:
	var best: Enemy = null
	var best_d: = INF
	for o in world.enemies_in_radius(at, reach):
		if o == skip or o.dead or o.prop != "":
			continue
		var d: = at.distance_squared_to(o.position)
		if d < best_d:
			best_d = d
			best = o
	return best
