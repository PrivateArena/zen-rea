extends RefCounted




















const SOUL_FLY: = 0.3






const SOUL_FX_FULL: = 4
const SOUL_TRAIL_STEP: = 0.5
static var _soul_flying: = 0
const SOUL_DARK: = Color(0.16, 0.02, 0.26)
const SOUL_SPLASH: = 0.5
const SOUL_REACH: = 7.0
const SOUL_GAP: = 0.07
const SOUL_COL: = Color(0.7, 0.32, 1.0)
const SOUL_CORE: = Color(1.0, 0.86, 1.0)











const SOUL_REAP: = 9.0
const SOUL_RELEASE_DMG: = 0.5

const SOUL_REAP_FX_GAP: = 0.1
const LOOT_DMG: = 0.04
const LOOT_TIME: = 8.0
const STRIP_BOSS: = 0.5

const LG_STRIP_LOOT: = 5




const LG_STRIP_DS: = 0.3
const STRIP_COL: = Color(1.0, 0.78, 0.32)



static func _strongest_n(world: World, at: Vector3, reach: float, n: int) -> Array[Enemy]:
	var all: Array[Enemy] = []
	for e in world.enemies_in_radius(at, reach):
		if not e.dead and e.prop == "" and Skills.rank(world, e) > 0.0:
			all.append(e)
	all.sort_custom( func(a, b): return Skills.rank(world, a) > Skills.rank(world, b))
	return all.slice(0, n)



static func soul_breaker(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var n: = maxi(1, int(v.call("count")))
	var targets: = _strongest_n(world, p.position, float(v.call("range")), n)
	if targets.is_empty():
		return false


	var k: = 0
	while targets.size() < n:
		targets.append(targets[k])
		k += 1
	var st: = {"p": p, "tag": str(world.damage_tag), "dmg": float(v.call("damage")), 
		"area": float(v.call("area")) * p.area_mult, "el": Skills.melee_element(p, s), 
		"souls": int(s.get("souls", 0)), "hit": {}}
	p.play_attack(targets[0].position - p.position)
	world.play_skill_sound(s)
	Vfx.magic_circle(world.fx_root, p.position, 1.5, Color(SOUL_COL, 0.85), 0.45)
	Vfx.converge(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.8, SOUL_COL, 0.25)
	for i in targets.size():
		_soul_fly(world, st, p.position + Vector3(0, 1.0, 0), targets[i], SOUL_GAP * i, int(st.souls), false)


	var id: = reaper_skill(p)
	var full: = int(GameData.SKILLS[id].get("souls_max", 5)) if id != "" else 0
	if full > 0 and int(p.get_meta("sd_souls", 0)) >= full:
		p.set_meta("sd_souls", 0)
		var free: = st.duplicate()
		free["dmg"] = float(st.dmg) * SOUL_RELEASE_DMG
		free["souls"] = 0
		free["released"] = true
		free["hit"] = {}
		var more: = _strongest_n(world, p.position, float(v.call("range")) * 1.2, full)
		var j: = 0
		while not more.is_empty() and more.size() < full:
			more.append(more[j])
			j += 1
		Vfx.magic_circle(world.fx_root, p.position, 2.6, Color(SOUL_CORE, 0.9), 0.55)
		Vfx.ring(world.fx_root, p.position + Vector3(0, 0.08, 0), 3.2, SOUL_COL, 0.45)
		world.shake(0.12)
		world.play_sound("sl_soul", 0.05, -2.0, 0.9)
		for i in more.size():
			_soul_fly(world, free, p.position + Vector3(0, 1.4, 0), more[i], 0.12 + SOUL_GAP * i, 0, false)
	return true



static func _soul_fly(world: World, st: Dictionary, from: Vector3, e: Enemy, delay: float, souls: int, wisp: bool) -> void :
	var to: = e.position + Vector3(0, 0.9, 0)

	var ref: WeakRef = weakref(e)
	var p: Player = st.p
	if delay <= 0.0:
		soul_fx(world, from, e, SOUL_FLY, wisp)
	else:
		world._own_timer(delay, func():
			var t = ref.get_ref()
			if t != null and is_instance_valid(p):
				world.fx_with(world.hero_fx_alpha(p), func(): soul_fx(world, from, t, SOUL_FLY, wisp)))

	world._own_timer(delay + SOUL_FLY, func(): _soul_land(world, st, ref.get_ref() as Enemy, to, souls, wisp))


static func _soul_land(world: World, st: Dictionary, e: Enemy, at: Vector3, souls: int, wisp: bool) -> void :
	var p: Player = st.p
	if not world.running or not is_instance_valid(p):
		return
	var keep_dim: = Vfx.dim
	Vfx.dim = world.hero_fx_alpha(p)
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = str(st.tag)
	world.damage_by = p
	if is_instance_valid(e) and not e.dead:
		at = e.position + Vector3(0, 0.9, 0)
	var ground: = at - Vector3(0, 0.9, 0)
	var dmg: = float(st.dmg)
	var el: = str(st.el)


	var killed: = false
	if is_instance_valid(e) and not e.dead:
		(st.hit as Dictionary)[e.get_instance_id()] = true
		world.damage_enemy(e, dmg, ((e.position - p.position) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", el, str(st.tag))
		killed = is_instance_valid(e) and e.dead


		if not wisp and not killed and not st.get("released", false) and is_instance_valid(e) and (e.is_boss or e.feroz or e.def.get("elite", false)):
			reap(world, p, at)

	if not wisp:
		var r: = float(st.area)
		for c in world.enemies_in_radius(ground, r):
			if not c.dead and c != e:
				world.damage_enemy(c, dmg * SOUL_SPLASH, ((c.position - ground) * Vector3(1, 0, 1)).normalized() * 2.5, "skill", el, str(st.tag))
		Vfx.magic_circle(world.fx_root, ground, r, Color(SOUL_COL, 0.9), 0.6)
		Vfx.ring(world.fx_root, ground + Vector3(0, 0.05, 0), r, SOUL_COL, 0.45)
		Vfx.column(world.fx_root, ground, SOUL_COL)
		world.shake(0.08)
	soul_hit_fx(world, at, wisp)

	if souls > 0 and killed:
		var next: Enemy = null
		var score: = -1.0
		for c in world.enemies_in_radius(ground, SOUL_REACH):
			if c.dead or c.prop != "" or (st.hit as Dictionary).has(c.get_instance_id()):
				continue

			if world.raid != null and world.raid.untouchable(c):
				continue
			var sc: = Skills.rank(world, c)
			if sc > score:
				score = sc
				next = c
		if next != null:
			_soul_fly(world, st, at, next, 0.0, souls - 1, true)
	world.damage_tag = keep[0]
	world.damage_by = keep[1]
	Vfx.dim = keep_dim




static func souls_now(world: World, p: Player) -> int:
	if p.has_meta("net_souls") and world.net != null and world.net.is_client():
		return int(p.get_meta("net_souls"))
	return int(p.get_meta("sd_souls", 0))



static func reaper_skill(p: Player) -> String:
	if p.skills.has("soul_breaker_x"):
		return "soul_breaker_x"
	return "soul_breaker" if p.skills.has("soul_breaker") else ""




static func reap(world: World, p: Player, from: Vector3) -> void :
	var id: = reaper_skill(p)
	if id == "":
		return
	var n: = int(p.get_meta("sd_souls", 0))
	if n >= int(GameData.SKILLS[id].get("souls_max", 5)):
		return
	p.set_meta("sd_souls", n + 1)
	if world.clock >= float(p.get_meta("sd_wisp_at", -1.0)):
		p.set_meta("sd_wisp_at", world.clock + SOUL_REAP_FX_GAP)
		world.fx_with(world.hero_fx_alpha(p), func(): soul_fx(world, from + Vector3(0, 0.9, 0), p, SOUL_FLY * 1.6, true))



static func on_kill(world: World, killer: Player, e: Enemy) -> void :
	if reaper_skill(killer) == "" or e.prop != "":
		return
	if ((e.position - killer.position) * Vector3(1, 0, 1)).length() > SOUL_REAP:
		return
	reap(world, killer, e.position)





static func soul_hit_fx(world: World, at: Vector3, wisp: bool) -> void :

	if not wisp:
		world.spawn_fx("hell_in", at, 1.4, 1.0)
	world.play_sound("sl_soul" if wisp else "soul_strike", 0.05, -5.0 if wisp else -3.0, 1.25 if wisp else 0.8)







static func soul_fx(world: World, from: Vector3, e: Node3D, flight: float, wisp: bool) -> void :
	if world.net.recording():
		world.net.record(["sb", from, world.net.ref_of(e), flight, wisp])
	if not is_instance_valid(e) or Vfx.hidden():
		return
	var d: = Vfx.dim

	var bare: = wisp or Vfx.quality >= 1 or _soul_flying >= SOUL_FX_FULL
	var plain: = bare
	var cam: = world.camera
	var k: = 0.8 if wisp else 1.45
	var head: = Node3D.new()
	world.fx_root.add_child(head)
	head.global_position = from
	_soul_flying += 1
	head.tree_exiting.connect( func(): _soul_flying = maxi(0, _soul_flying - 1))
	var veil: Sprite3D = null
	if not bare:
		veil = _smoke(Color(SOUL_DARK, 0.7 * d))
		head.add_child(veil)
	var halo: = Vfx.streak_sprite(Color(SOUL_CORE, 0.8) if wisp else Color(SOUL_COL, 0.95))
	head.add_child(halo)
	var edge: = Vfx.streak_sprite(Color(0.96, 0.8, 1.0, 1.0))
	head.add_child(edge)
	var core: = Vfx.streak_sprite(Color.WHITE)
	head.add_child(core)
	var souls: Array[Sprite3D] = []
	for i in (0 if bare else 2):
		var w: = Vfx.streak_sprite(Color(0.75, 0.95, 1.0, 0.95))
		head.add_child(w)
		souls.append(w)
	var ref: WeakRef = weakref(e)
	var state: = {"last": from, "n": 0}
	var lift: = 1.3 if wisp else 0.35
	var fly: = func(t: float) -> void :
		if not is_instance_valid(head):
			return
		var tgt = ref.get_ref()
		var to: Vector3 = (tgt.global_position + Vector3(0, 0.9, 0)) if tgt != null and is_instance_valid(tgt) else head.global_position
		var at: = from.lerp(to, t) + Vector3(0, sin(t * PI) * lift, 0)
		var step: Vector3 = at - state.last
		head.global_position = at


		var ang: = 0.0
		if cam != null:
			var sv: = cam.global_basis.inverse() * (to - from)
			ang = atan2(sv.y, sv.x) - PI * 0.5
			var b: = cam.global_basis * Basis(Vector3(0, 0, 1), ang)
			halo.global_basis = b
			edge.global_basis = b
			core.global_basis = cam.global_basis
			for i in souls.size():
				var a: = t * TAU * 2.5 + PI * i
				souls[i].global_basis = cam.global_basis
				souls[i].position = (cam.global_basis.x * cos(a) + cam.global_basis.y * sin(a)) * 0.55 * k
		halo.scale = Vector3(1.15, 4.2, 1.0) * k
		edge.scale = Vector3(0.38, 3.0, 1.0) * k
		core.scale = Vector3.ONE * 0.75 * k
		if veil != null:
			veil.scale = Vector3.ONE * 2.6 * k
		for w in souls:
			w.scale = Vector3.ONE * 0.42 * k

		if step.length() >= SOUL_TRAIL_STEP:
			state.last = at
			state.n = int(state.n) + 1
			if not plain and Vfx.trail_ok():
				world.fx_with(d, func(): _soul_ghost(world, at, ang, k, cam, int(state.n) % 2 == 0, wisp))
	var tw: = head.create_tween()
	tw.tween_method(fly, 0.0, 1.0, flight)
	tw.tween_callback( func():
		if is_instance_valid(head):
			var end: = head.global_position
			world.fx_with(d, func(): _soul_burst(world, end, k, cam, wisp))
			head.queue_free())



static func _smoke(color: Color) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = RoAssets.radial(Color.WHITE, 64)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 4
	s.pixel_size = 1.0 / 64.0
	s.modulate = color
	return s




static func _soul_ghost(world: World, at: Vector3, ang: float, k: float, cam: Camera3D, smoke: bool, wisp: bool) -> void :
	var g: = Vfx.streak_sprite(Color(SOUL_CORE, 0.6) if wisp else Color(SOUL_COL, 0.7))
	world.fx_root.add_child(g)
	g.global_position = at
	if cam != null:
		g.global_basis = cam.global_basis * Basis(Vector3(0, 0, 1), ang)
	g.scale = Vector3(0.8, 3.2, 1.0) * k
	var tw: = g.create_tween().set_parallel()
	tw.tween_property(g, "modulate:a", 0.0, 0.32).set_ease(Tween.EASE_IN)
	tw.tween_property(g, "scale", Vector3(0.25, 2.0, 1.0) * k, 0.32)
	tw.chain().tween_callback(g.queue_free)
	if smoke and not wisp:
		var s: = _smoke(Color(SOUL_DARK, 0.45 * Vfx.dim))
		world.fx_root.add_child(s)
		s.global_position = at + Vector3(randf_range(-0.15, 0.15), randf_range(-0.1, 0.2), 0)
		s.scale = Vector3.ONE * 1.2
		var st: = s.create_tween().set_parallel()
		st.tween_property(s, "scale", Vector3.ONE * 2.6, 0.6)
		st.tween_property(s, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
		st.chain().tween_callback(s.queue_free)




static func _soul_burst(world: World, at: Vector3, k: float, cam: Camera3D, wisp: bool) -> void :

	var rays: = 3 if wisp else (7 if _soul_flying <= SOUL_FX_FULL else 4)
	var off: = randf() * TAU
	for i in rays:
		var r: = Vfx.streak_sprite(Color(SOUL_CORE, 1.0) if (wisp or i % 2 == 0) else Color(SOUL_COL, 1.0))
		world.fx_root.add_child(r)
		r.global_position = at
		var a: = off + TAU * i / rays
		if cam != null:
			r.global_basis = cam.global_basis * Basis(Vector3(0, 0, 1), a)
		r.scale = Vector3(0.4, 0.8, 1.0) * k
		var tw: = r.create_tween().set_parallel()
		tw.tween_property(r, "scale", Vector3(0.22, 6.5 if i % 2 == 0 else 4.4, 1.0) * k, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(r, "modulate:a", 0.0, 0.45).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(r.queue_free)
	var flare: = Vfx.streak_sprite(Color(1, 0.92, 1, 1))
	world.fx_root.add_child(flare)
	flare.global_position = at
	if cam != null:
		flare.global_basis = cam.global_basis
	flare.scale = Vector3.ONE * 1.6 * k
	var ft: = flare.create_tween().set_parallel()
	ft.tween_property(flare, "scale", Vector3.ONE * 5.5 * k, 0.25)
	ft.tween_property(flare, "modulate:a", 0.0, 0.4)
	ft.chain().tween_callback(flare.queue_free)
	if not wisp and Vfx.quality < 1:
		for i in 3:
			var s: = _smoke(Color(SOUL_DARK, 0.55 * Vfx.dim))
			world.fx_root.add_child(s)
			s.global_position = at + Vector3(randf_range(-0.4, 0.4), randf_range(-0.2, 0.3), randf_range(-0.4, 0.4))
			s.scale = Vector3.ONE * 1.5
			var st: = s.create_tween().set_parallel()
			st.tween_property(s, "scale", Vector3.ONE * 4.0, 0.7).set_ease(Tween.EASE_OUT)
			st.tween_property(s, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN)
			st.chain().tween_callback(s.queue_free)





static func strip_fx(world: World, at: Vector3, r: float) -> void :
	if world.net.recording():
		world.net.record(["fs", at, r])
	if Vfx.hidden():
		return
	var n: = 6 if Vfx.quality >= 1 else 12
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	root.global_position = at + Vector3(0, 0.7, 0)
	var blades: Array[Sprite3D] = []
	for i in n:
		var b: = Vfx.streak_sprite(Color(STRIP_COL, 1.0) if i % 2 == 0 else Color(1.0, 0.96, 0.82, 0.9))
		root.add_child(b)
		blades.append(b)
	var spin: = func(t: float) -> void :
		if not is_instance_valid(root):
			return
		var rad: = lerpf(0.6, r, 1.0 - pow(1.0 - t, 2.0))
		for i in blades.size():
			var a: = TAU * i / blades.size() + t * TAU * 1.25
			var b: = blades[i]
			b.position = Vector3(cos(a), 0, sin(a)) * rad

			b.global_basis = Basis(Vector3.UP, - a) * Basis(Vector3.RIGHT, - PI * 0.5)
			b.scale = Vector3(0.5, 2.6 + rad * 0.5, 1.0)
			b.modulate.a = (1.0 - t * t) * Vfx.dim * (1.0 if i % 2 == 0 else 0.85)
	var tw: = root.create_tween()
	tw.tween_method(spin, 0.0, 1.0, 0.42)
	tw.tween_callback(root.queue_free)





static func loot_fly(world: World, from: Vector3, p: Node3D, flight: float) -> void :
	if world.net.recording():
		world.net.record(["fl", from, world.net.ref_of(p), flight])
	if not is_instance_valid(p) or Vfx.hidden():
		return
	var d: = Vfx.dim
	var cam: = world.camera
	var head: = Node3D.new()
	world.fx_root.add_child(head)
	head.global_position = from
	var glow: = Vfx.streak_sprite(Color(STRIP_COL, 0.95))
	head.add_child(glow)
	var core: = Vfx.streak_sprite(Color(1, 1, 0.9, 1))
	head.add_child(core)
	var ref: WeakRef = weakref(p)
	var state: = {"last": from}
	var plain: = Vfx.quality >= 1
	var fly: = func(t: float) -> void :
		if not is_instance_valid(head):
			return
		var hero = ref.get_ref()
		var to: Vector3 = (hero.global_position + Vector3(0, 1.2, 0)) if hero != null and is_instance_valid(hero) else head.global_position
		var at: = from.lerp(to, t * t) + Vector3(0, sin(t * PI) * 1.6, 0)
		head.global_position = at
		if cam != null:
			glow.global_basis = cam.global_basis
			core.global_basis = cam.global_basis
		glow.scale = Vector3.ONE * (1.7 - 0.5 * t)
		core.scale = Vector3.ONE * 0.7
		var lp: Vector3 = state.last
		if not plain and at.distance_to(lp) >= 0.28:
			state.last = at
			world.fx_with(d, func(): _sparkle(world, at, cam))
	var tw: = head.create_tween()
	tw.tween_method(fly, 0.0, 1.0, flight)
	tw.tween_callback( func():
		if is_instance_valid(head):
			var end: = head.global_position
			world.fx_with(d, func(): _sparkle(world, end, cam, 2.6))
			head.queue_free())


static func _sparkle(world: World, at: Vector3, cam: Camera3D, size: = 0.7) -> void :
	var s: = Vfx.streak_sprite(Color(1.0, 0.9, 0.55, 0.9))
	world.fx_root.add_child(s)
	s.global_position = at
	if cam != null:
		s.global_basis = cam.global_basis * Basis(Vector3(0, 0, 1), PI * 0.25)
	s.scale = Vector3(0.3, 1.4, 1.0) * size
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "scale", Vector3(0.08, 0.3, 1.0) * size, 0.3)
	tw.chain().tween_callback(s.queue_free)



static func full_strip(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var r: = float(v.call("range")) * p.area_mult
	if not world.any_enemy_near(p.position, r):
		return false
	var dmg: = float(v.call("damage"))
	var dur: = float(v.call("duration"))
	var taken: = float(v.call("strip_taken"))
	var bosses: bool = s.get("strip_boss", false)
	var el: = Skills.melee_element(p, s)
	var n: = 0
	var shown: = 0
	for e in world.enemies_in_radius(p.position, r):
		if e.dead or e.prop != "":
			continue
		var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, dmg, away * float(s.get("knock", 2.0)), "skill", el)
		if e.dead or (e.is_boss and not bosses):
			continue
		strip(world, e, dur * (STRIP_BOSS if e.is_boss else 1.0), taken)
		n += 1
		if shown < 10:
			shown += 1
			world.spawn_fx("strip_weapon", e.position + Vector3(0, 1.0, 0), 1.25, 1.0)
			loot_fly(world, e.position + Vector3(0, 1.1, 0), p, 0.32 + 0.03 * shown)
	p.play_attack(p.facing)
	world.play_skill_sound(s)


	strip_fx(world, p.position, r)
	Vfx.magic_circle(world.fx_root, p.position, r, Color(STRIP_COL, 0.85), 0.55)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), r, STRIP_COL, 0.5)
	if n > 0:
		add_loot(world, p, n, int(s.get("loot_max", 10)) + (LG_STRIP_LOOT if p.effects.has("lg_strip_arrow") else 0))
	return true






static func arrow_strip(world: World, p: Player, e: Enemy) -> void :
	if e.dead or e.prop != "":
		return
	var sid: = "full_strip_x" if p.skills.has("full_strip_x") else "full_strip"
	var lv: = int(p.skills[sid].level) if p.skills.has(sid) else GameData.MAX_SKILL_LEVEL
	var fresh: = float(e.get_meta("strip_until", -1.0)) <= world.clock
	strip(world, e, GameData.skill_value(sid, "duration", lv) * (STRIP_BOSS if e.is_boss else 1.0), GameData.skill_value(sid, "strip_taken", lv))

	if str(p.job2.get("id", "")) == "stalker":
		var cap: = int(GameData.SKILLS[sid].get("loot_max", 10)) + LG_STRIP_LOOT
		add_loot(world, p, 1 if fresh else 0, cap)



	if fresh and world._bounce_fx_ok(2, "arrow_strip") and not Vfx.hidden():
		var at: = e.position + Vector3(0, 1.0, 0)
		world.fx_with(Vfx.dim, func(): _sparkle(world, at, world.camera, 1.8))
		loot_fly(world, at, p, 0.3)




static func strip(world: World, e: Enemy, dur: float, taken: float) -> void :
	var on: = float(e.get_meta("strip_until", -1.0)) > world.clock
	e.set_meta("strip_vuln", maxf(taken, float(e.get_meta("strip_vuln", 0.0))) if on else taken)
	e.set_meta("strip_until", maxf(world.clock + dur, float(e.get_meta("strip_until", -1.0))))


	world.blind_enemy(e, dur * (2.0 if e.is_boss else 1.0), true)





static func hit_mult(world: World, src: Player, e: Enemy, source: String) -> float:
	var m: = 1.0
	if e.has_meta("strip_until") and float(e.get_meta("strip_until")) > world.clock:
		m *= 1.0 + float(e.get_meta("strip_vuln", 0.0))
	if source == "poison" and src != null and str(src.job2.get("id", "")) == "stalker":
		m *= loot_mult(world, src)
	return m



static func add_loot(world: World, p: Player, n: int, cap: int) -> void :
	var was: = loot_now(world, p)
	var now: = mini(cap, was + n)
	p.set_meta("st_loot", now)
	p.set_meta("st_loot_cap", cap)
	p.set_meta("st_loot_until", world.clock + LOOT_TIME)
	if now == cap and was < cap:
		world.label_over(p, TranslationServer.translate("¡Botín completo!"), STRIP_COL)
		world.play_sound("steal", 0.2, -4.0, 1.1)



static func loot_now(world: World, p: Player) -> int:


	if p.has_meta("net_loot") and world.net != null and world.net.is_client():
		return int(p.get_meta("net_loot"))
	if float(p.get_meta("st_loot_until", -1.0)) <= world.clock:
		return 0
	return int(p.get_meta("st_loot", 0))


static func loot_cap(p: Player) -> int:
	if p.has_meta("st_loot_cap"):
		return int(p.get_meta("st_loot_cap"))


	var more: = LG_STRIP_LOOT if p.effects.has("lg_strip_arrow") else 0
	for id in ["full_strip_x", "full_strip"]:
		if p.skills.has(id):
			return int(GameData.SKILLS[id].get("loot_max", 10)) + more
	return 10 + more




static func loot_mult(world: World, p: Player) -> float:
	return 1.0 + LOOT_DMG * loot_now(world, p)
