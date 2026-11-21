extends RefCounted

















const ARMOR_PCT: = 0.01
const SKILLS: = ["grand_cross", "holy_cross", "gospel", "provoke", "martyrs_reckoning"]
const CHARGES: = 5
const CHARGE_GAP: = 0.4
const JUDGE_MULT: = 8.0
const JUDGE_RADIUS: = 6.0
const JUDGE_HEAL: = 0.05
const JUDGE_STUN: = 1.5
const JUDGE_POISE: = 3.0
const PROVOKED_DMG: = 0.25
const WAVE_RADIUS: = 2.6
const WAVE_MULT: = 1.5
const WAVE_GAP: = 0.3
const GOLD: = Color(1.0, 0.88, 0.5)


static func on(p: Player) -> bool:
	return p != null and is_instance_valid(p) and str(p.job2.get("id", "")) == "paladin"


static func charges(p: Player) -> int:
	return int(p.get_meta("pal_charges", 0))



static func mult(world: World, p: Player, e: Enemy, tag: String) -> float:
	var m: = 1.0
	if Player.base_skill(tag) in SKILLS:
		m *= 1.0 + ARMOR_PCT * maxf(0.0, p.armor)
	if provoked_by(world, e, p):
		m *= 1.0 + PROVOKED_DMG
	return m


static func provoked_by(world: World, e: Enemy, p: Player) -> bool:
	return e != null and is_instance_valid(e) and e.taunt_by == p and world.clock < e.taunt_until



static func charge(world: World, p: Player) -> void :
	if not on(p) or world.clock < float(p.get_meta("pal_charge_at", -99.0)):
		return
	p.set_meta("pal_charge_at", world.clock + CHARGE_GAP)
	var n: = charges(p) + 1
	if n >= CHARGES:
		p.set_meta("pal_charges", 0)
		judgment(world, p)
	else:
		p.set_meta("pal_charges", n)
		world.play_sound("guard_block", 0.1, -8.0, 1.0 + 0.1 * n)



static func judgment(world: World, p: Player) -> void :
	var at: = p.position
	judgment_fx(world, at)
	var keep: = [world.damage_tag, world.damage_by]

	world.damage_tag = "grand_cross"
	world.damage_by = p
	var dmg: = p.basic_atk() * JUDGE_MULT
	for e in world.enemies_in_radius(at, JUDGE_RADIUS * sqrt(p.area_mult)):
		if e.dead:
			continue
		var away: = ((e.position - at) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, dmg, away * 3.0, "skill", "holy", "grand_cross")
		if e.dead:
			continue
		if e.is_boss:
			world.stagger.add(world, e, JUDGE_POISE, "pal_judgment")
		else:
			world.apply_status(e, "stun", JUDGE_STUN)
	world.damage_tag = keep[0]
	world.damage_by = keep[1]
	p.heal(p.max_hp * JUDGE_HEAL, world, true, "grand_cross")
	world.label_over(p, TranslationServer.translate("¡Juicio!"), GOLD)



static func judgment_fx(world: World, at: Vector3) -> void :
	Vfx.beam_flash(world.fx_root, at, GOLD, 10.0, 1.0)

	Vfx.column(world.fx_root, at, GOLD)
	Vfx.magic_circle(world.fx_root, at, JUDGE_RADIUS, Color(GOLD, 0.8), 1.2)
	for d in [Vector3(1, 0, 0), Vector3(0, 0, 1)]:
		Vfx.strike_line(world.fx_root, at - d * JUDGE_RADIUS, d, JUDGE_RADIUS * 2.0, 2.0, GOLD)
	world.spawn_fx("red_cross", at, 2.2, 1.0)
	world.spawn_fx("holyhit", at + Vector3(0, 0.5, 0), 1.6, 1.0)
	Vfx.ring(world.fx_root, at + Vector3(0, 0.05, 0), JUDGE_RADIUS, Color(1, 1, 0.85), 0.5)
	world.play_sound("grand_cross", 0.0, 0.0, 0.85, true, true)
	world.play_sound("angelus", 0.0, -3.0, -1.0, true, true)
	world.shake(0.4)



static func martyr_wave(world: World, p: Player, target: Enemy) -> void :
	if not on(p) or not p.powers.has("martyr") or target == null or not is_instance_valid(target):
		return
	if world.clock < float(p.get_meta("pal_wave_at", -99.0)):
		return
	p.set_meta("pal_wave_at", world.clock + WAVE_GAP)
	var at: = target.position
	var r: = WAVE_RADIUS * sqrt(p.area_mult)
	var dmg: = p.basic_atk() * WAVE_MULT
	var keep: = [world.damage_tag, world.damage_by]

	world.damage_tag = "martyrs_reckoning"
	world.damage_by = p
	for e in world.enemies_in_radius(at, r):
		if not e.dead and e != target:
			world.damage_enemy(e, dmg, Vector3.ZERO, "skill", "holy", "martyrs_reckoning")
	world.damage_tag = keep[0]
	world.damage_by = keep[1]
	Vfx.ring(world.fx_root, at + Vector3(0, 0.05, 0), r, Color(GOLD, 0.85), 0.3)
	Vfx.burst(world.fx_root, at, r * 0.6, GOLD)




static func draw(p: Player) -> void :
	var n: = charges(p)
	var nodes: Array = p.get_meta("pal_nodes") if p.has_meta("pal_nodes") else []
	while nodes.size() > n:
		var s = nodes.pop_back()
		if is_instance_valid(s):
			s.queue_free()
	while nodes.size() < n:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 64)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 20
		s.pixel_size = 1.1 / 64.0
		var core: = Sprite3D.new()
		core.texture = s.texture
		core.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		core.shaded = false
		core.no_depth_test = true
		core.render_priority = 21
		core.pixel_size = 0.4 / 64.0
		s.add_child(core)
		p.add_child(s)
		nodes.append(s)
	if nodes.is_empty():
		if p.has_meta("pal_nodes"):
			p.remove_meta("pal_nodes")
		return
	p.set_meta("pal_nodes", nodes)
	var t: = Time.get_ticks_msec() / 1000.0
	var h: = p.visual.height() if p.visual != null else 1.6
	for i in nodes.size():
		var s: Sprite3D = nodes[i]
		var a: = t * 1.4 + TAU * i / float(CHARGES)
		s.position = RoVisual.lift + Vector3(cos(a) * 0.85, h * 0.75, sin(a) * 0.85)
		s.modulate = Color(GOLD, 0.9 * Vfx.dim)
		(s.get_child(0) as Sprite3D).modulate = Color(1, 1, 1, Vfx.dim)
