extends RefCounted
























const ARMOR_PCT: = 0.015
const SKILLS: = ["grand_cross", "holy_cross", "gospel", "provoke", "martyrs_reckoning", "shield_chain"]
const CHAIN_HOP: = 0.12
const CHAIN_REACH: = 7.0
const CHAIN_STORE: = 5
const CHAIN_BURST: = 1.5
const CHAIN_BURST_RADIUS: = 3.2
const CROSS_TIME: = 6.0
const SHIELD_GOLD: = Color(1.0, 0.82, 0.32)
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

	if p.effects.has("lg_cross_mark") and Player.base_skill(tag) == "grand_cross" and e != null and is_instance_valid(e)\
	and world.clock < float(e.get_meta("pal_cross_until", -1.0)):
		m *= 1.0 + float(p.effects.lg_cross_mark)
	return m


static func provoked_by(world: World, e: Enemy, p: Player) -> bool:
	return e != null and is_instance_valid(e) and e.taunt_by == p and world.clock < e.taunt_until



static func charge(world: World, p: Player) -> void :
	if not on(p) or world.clock < float(p.get_meta("pal_charge_at", -99.0)):
		return
	p.set_meta("pal_charge_at", world.clock + CHARGE_GAP)

	if p.skills.has("shield_chain_x"):
		p.set_meta("pal_chain_store", mini(CHAIN_STORE, int(p.get_meta("pal_chain_store", 0)) + 1))
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





static func shield_chain(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var first: = Skills.strongest(world, p.position, float(v.call("range")))
	if first == null:
		return false
	var ex: bool = s.get("evolved", false)
	var hops: = maxi(1, int(v.call("count"))) + int(p.effects.get("lg_chain", 0.0))
	if ex:
		hops += int(p.get_meta("pal_chain_store", 0))
		p.set_meta("pal_chain_store", 0)
	var st: = {"p": p, "tag": str(world.damage_tag), "left": hops, "n": 0, "hit": {}, "ex": ex, 
		"dmg": float(v.call("damage")) * p.shield_mult(float(s.get("shield_scale", 0.0))), 
		"from": p.position + Vector3(0, 1.0, 0)}
	p.play_attack(first.position - p.position)
	world.play_skill_sound(s)
	Vfx.burst(world.fx_root, p.position + Vector3(0, 1.0, 0), 0.9, SHIELD_GOLD)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.6, SHIELD_GOLD, 0.3)
	_chain_fly(world, st, first)
	return true


static func _chain_fly(world: World, st: Dictionary, e: Enemy) -> void :
	var flight: = CHAIN_HOP * (1.4 if int(st.n) == 0 else 1.0)
	shield_fly(world, st.from, e, flight, int(st.left) == 1)

	var ref: WeakRef = weakref(e)


	world._own_timer(flight, func(): _chain_land(world, st, ref.get_ref() as Enemy))


static func _chain_land(world: World, st: Dictionary, e: Enemy) -> void :
	var p: Player = st.p
	if not world.running or not is_instance_valid(p):
		return

	var keep_dim: = Vfx.dim
	Vfx.dim = world.hero_fx_alpha(p)
	_chain_step(world, st, e)
	Vfx.dim = keep_dim


static func _chain_step(world: World, st: Dictionary, e: Enemy) -> void :
	var at: Vector3 = st.from - Vector3(0, 1.0, 0)
	if is_instance_valid(e) and not e.dead:
		at = e.position
		_chain_strike(world, st, e)
	st.left = int(st.left) - 1
	st.n = int(st.n) + 1
	st.from = at + Vector3(0, 0.9, 0)
	if int(st.left) <= 0:
		return
	var next: = _chain_next(world, st, at, e)
	if next != null:
		_chain_fly(world, st, next)




static func _chain_next(world: World, st: Dictionary, at: Vector3, last: Enemy) -> Enemy:
	var best: Enemy = null
	var score: = -1.0
	for c in world.enemies_in_radius(at, CHAIN_REACH):
		if c.dead or c.prop != "":
			continue
		if (st.hit as Dictionary).has(c.get_instance_id()) and not c.is_boss and not c.def.get("elite", false):
			continue
		var sc: = Skills.rank(world, c)
		if sc > score:
			score = sc
			best = c
	if best == null and is_instance_valid(last) and not last.dead:
		best = last
	return best


static func _chain_strike(world: World, st: Dictionary, e: Enemy) -> void :
	var p: Player = st.p
	var last: = int(st.left) == 1
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = str(st.tag)
	world.damage_by = p
	var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
	var at: = e.position
	world.damage_enemy(e, float(st.dmg), away * 2.5, "skill", "neutral", str(st.tag))
	(st.hit as Dictionary)[e.get_instance_id()] = true

	if p.effects.has("lg_cross_mark") and is_instance_valid(e) and not e.dead:
		e.set_meta("pal_cross_until", world.clock + CROSS_TIME)
		world.spawn_fx("holyhit", at + Vector3(0, 0.9, 0), 0.7, 0.8)

	if last and bool(st.ex):
		var r: = CHAIN_BURST_RADIUS * sqrt(p.area_mult)
		for c in world.enemies_in_radius(at, r):
			if not c.dead and c != e:
				world.damage_enemy(c, float(st.dmg) * CHAIN_BURST, ((c.position - at) * Vector3(1, 0, 1)).normalized() * 3.0, "skill", "holy", str(st.tag))
		chain_burst_fx(world, at, r)
	world.damage_tag = keep[0]
	world.damage_by = keep[1]
	chain_hit_fx(world, at, int(st.n), last)





static func chain_hit_fx(world: World, at: Vector3, n: int, last: bool) -> void :
	var up: = at + Vector3(0, 0.9, 0)
	Vfx.burst(world.fx_root, up, 0.55 + 0.06 * mini(n, 8), SHIELD_GOLD)
	Vfx.ring(world.fx_root, at + Vector3(0, 0.05, 0), 1.1 + 0.1 * mini(n, 8), Color(1, 0.95, 0.75), 0.25)
	world.play_sound("guard_block", 0.03, -4.0, 0.9 + 0.08 * mini(n, 8))
	if last:
		Vfx.column(world.fx_root, at, SHIELD_GOLD)
		world.spawn_fx("holyhit", up, 1.3, 1.0)
		world.play_sound("holy_cross", 0.05, -2.0, 0.85)
		world.shake(0.18)


static func chain_burst_fx(world: World, at: Vector3, r: float) -> void :
	Vfx.magic_circle(world.fx_root, at, r, Color(GOLD, 0.8), 0.8)
	for d in [Vector3(1, 0, 0), Vector3(0, 0, 1)]:
		Vfx.strike_line(world.fx_root, at - d * r, d, r * 2.0, 1.4, GOLD)
	Vfx.ring(world.fx_root, at + Vector3(0, 0.05, 0), r, Color(1, 1, 0.85), 0.45)
	world.spawn_fx("red_cross", at, 1.4, 1.0)
	world.play_sound("grand_cross", 0.05, -3.0, 1.15)
	world.shake(0.3)







static func shield_fly(world: World, from: Vector3, e: Node3D, flight: float, last: bool) -> void :
	if world.net.recording():
		world.net.record(["sc", from, world.net.ref_of(e), flight, last])
	if not is_instance_valid(e) or Vfx.hidden():
		return
	var k: = 1.35 if last else 1.0


	var d: = Vfx.dim
	var plain: = Vfx.quality >= 1
	var head: = Node3D.new()
	world.fx_root.add_child(head)
	head.global_position = from


	var halo: = Vfx.streak_sprite(Color(SHIELD_GOLD, 0.75))
	head.add_child(halo)
	var core: = Vfx.streak_sprite(Color(1.0, 0.98, 0.9, 1.0))
	head.add_child(core)
	var arms: Array[Sprite3D] = []
	for i in 2:
		var arm: = Vfx.streak_sprite(Color(1.0, 0.93, 0.62, 0.95))
		head.add_child(arm)
		arms.append(arm)
	var cam: = world.camera
	var ref: WeakRef = weakref(e)
	var state: = {"last_link": from, "link": 0}
	var fly: = func(t: float) -> void :
		if not is_instance_valid(head):
			return
		var tgt = ref.get_ref()
		var to: Vector3 = (tgt.global_position + Vector3(0, 0.9, 0)) if tgt != null else head.global_position
		var at: = from.lerp(to, t) + Vector3(0, sin(t * PI) * 0.5, 0)
		head.global_position = at

		var spin: = t * TAU * 1.5
		if cam != null:
			for i in arms.size():
				arms[i].global_basis = cam.global_basis * Basis(Vector3(0, 0, 1), spin + PI * 0.5 * i)
			halo.global_basis = cam.global_basis
			core.global_basis = cam.global_basis
		for arm in arms:
			arm.scale = Vector3(0.3, 2.3, 1.0) * k
		halo.scale = Vector3.ONE * (2.8 + 0.3 * sin(t * TAU * 3.0)) * k
		core.scale = Vector3.ONE * 1.1 * k


		var lp: Vector3 = state.last_link
		var step: = at - lp
		if step.length() >= 0.32:
			state.last_link = at
			state.link = int(state.link) + 1
			if not plain:
				world.fx_with(d, func(): _chain_link(world, at, step, int(state.link) % 2 == 0, cam))
	var tw: = head.create_tween()
	tw.tween_method(fly, 0.0, 1.0, flight)
	tw.tween_callback( func():
		if is_instance_valid(head):
			var end: = head.global_position
			world.fx_with(d, func():
				if not plain:
					_chain_beam(world, from, end, k)
				_cross_flash(world, end, k, cam))
			head.queue_free())



static func _chain_link(world: World, at: Vector3, step: Vector3, across: bool, cam: Camera3D) -> void :
	var l: = Vfx.streak_sprite(Color(SHIELD_GOLD, 0.85))
	world.fx_root.add_child(l)
	l.global_position = at

	var a: = 0.0
	if cam != null:
		var s: = cam.global_basis.inverse() * step
		a = atan2(s.y, s.x) - PI * 0.5 + (PI * 0.5 if across else 0.0)
		l.global_basis = cam.global_basis * Basis(Vector3(0, 0, 1), a)
	l.scale = Vector3(0.36, 0.8, 1.0)
	var tw: = l.create_tween().set_parallel()
	tw.tween_property(l, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tw.tween_property(l, "scale", Vector3(0.18, 0.45, 1.0), 0.5)
	tw.chain().tween_callback(l.queue_free)




static func _chain_beam(world: World, a: Vector3, b: Vector3, k: float) -> void :
	var length: = a.distance_to(b)
	if length < 0.1:
		return
	var mi: = MeshInstance3D.new()
	var box: = BoxMesh.new()
	box.size = Vector3(0.14 * k, 0.14 * k, length)
	mi.mesh = box
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_color = Color(SHIELD_GOLD.r * Vfx.add_k(), SHIELD_GOLD.g * Vfx.add_k(), SHIELD_GOLD.b * Vfx.add_k(), 0.95 * Vfx.dim)
	m.no_depth_test = true
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(mi)
	mi.global_position = (a + b) * 0.5
	mi.look_at(b, Vector3.UP)
	var tw: = mi.create_tween().set_parallel()
	tw.tween_property(m, "albedo_color:a", 0.0, 0.45).set_ease(Tween.EASE_IN)
	tw.tween_property(mi, "scale", Vector3(0.3, 0.3, 1.0), 0.45)
	tw.chain().tween_callback(mi.queue_free)



static func _cross_flash(world: World, at: Vector3, k: float, cam: Camera3D) -> void :
	for i in 2:
		var arm: = Vfx.streak_sprite(Color(1.0, 0.95, 0.7, 1.0))
		world.fx_root.add_child(arm)
		arm.global_position = at
		if cam != null:
			arm.global_basis = cam.global_basis * Basis(Vector3(0, 0, 1), PI * 0.5 * i)
		arm.scale = Vector3(0.4, 1.2, 1.0) * k
		var tw: = arm.create_tween().set_parallel()
		tw.tween_property(arm, "scale", Vector3(0.22, 4.6, 1.0) * k, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(arm, "modulate:a", 0.0, 0.28).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(arm.queue_free)
	var flare: = Vfx.streak_sprite(Color(1, 1, 0.92, 1.0))
	world.fx_root.add_child(flare)
	flare.global_position = at
	if cam != null:
		flare.global_basis = cam.global_basis
	flare.scale = Vector3.ONE * 1.2 * k
	var ft: = flare.create_tween().set_parallel()
	ft.tween_property(flare, "scale", Vector3.ONE * 3.6 * k, 0.2)
	ft.tween_property(flare, "modulate:a", 0.0, 0.25)
	ft.chain().tween_callback(flare.queue_free)




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
