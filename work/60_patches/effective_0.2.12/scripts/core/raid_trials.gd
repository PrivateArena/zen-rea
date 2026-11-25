extends RefCounted


























const LIGHT: = Color(1.0, 0.88, 0.45)
const DARK: = Color(0.62, 0.3, 0.95)
const GOOD: = Color(0.5, 1.0, 0.6)
const BAD: = Color(1.0, 0.35, 0.3)
const STEEL: = Color(0.55, 0.8, 1.0)
const HEAL: = Color(0.45, 1.0, 0.55)
const DOOM: = Color(0.85, 0.15, 0.2)
const KINDS: = ["polar", "snap", "guard", "doom", "runes", "leap"]

const LEAP_HEIGHT: = 16.0
const ABYSS: = Color(0.72, 0.25, 1.0)
const RUNE_COLORS: = [Color(1.0, 0.42, 0.36), Color(0.45, 0.7, 1.0), Color(0.55, 1.0, 0.5), Color(1.0, 0.85, 0.35), 
	Color(0.85, 0.5, 1.0), Color(0.4, 1.0, 0.95)]
const RUNE_SIGILS: = ["mvp_rune", "mvp_hexa", "mvp_seal"]
const RUNE_SIZE: = 1.4

const SNAP_WINDOW: = 0.3

var raid: MvpRaid
var world: World:
	get:
		return raid.world


func _init(r: MvpRaid) -> void :
	raid = r





func start(ab: Dictionary, p: Player) -> bool:
	match str(ab.mech):
		"polar":
			_polar_start(ab, p)
		"snap":
			_snap_start(ab)
		"guard":
			_guard_start(ab, p)
		"doom":
			_doom_start(ab)
		"runes":
			_runes_start(ab)
		"leap":
			_leap_start(ab, p)
		_:
			return false
	return true


func owns(o: Dictionary) -> bool:
	return str(o.kind) in KINDS



func update(o: Dictionary, delta: float) -> bool:
	match str(o.kind):
		"polar":
			return _polar_update(o, delta)
		"snap":
			return _snap_update(o, delta)
		"guard":
			return _guard_update(o, delta)
		"doom":
			return _doom_update(o, delta)
		"runes":
			return _runes_update(o, delta)
		"leap":
			return _leap_update(o, delta)
	return false




func hero_mult(e: Enemy) -> float:
	if e != raid.boss:
		return 1.0
	for o in raid._objects:

		if str(o.kind) == "leap" and str(o.stage) in ["rise", "air", "lock"]:
			return 0.0
		if str(o.kind) != "guard":
			continue
		var src: = world.acting_hero()
		if src == null or not is_instance_valid(src):
			return 1.0
		var to: = raid._dir(e.position, src.position)
		if absf(angle_difference(float(o.a), atan2(to.x, to.z))) < float(o.ab.get("arc", 2.6)) * 0.5:
			_guard_blocked(o, src, to)
			return float(o.ab.get("block", 0.0))
	return 1.0



func pins_boss() -> bool:
	return raid._objects.any( func(o): return str(o.get("kind", "")) == "guard")




func goal(p: Player) -> Vector3:
	for o in raid._objects:
		match str(o.kind):
			"polar":
				return o.spots[o.side]
			"snap":
				if o.stop:
					return p.position
				return p.position + Vector3(cos(world.time * 2.0), 0, sin(world.time * 2.0)) * 2.0
			"guard":
				var boss: = raid.boss
				var to: = raid._dir(boss.position, p.position)
				var off: = angle_difference(float(o.a), atan2(to.x, to.z))
				var half: = float(o.ab.get("arc", 2.6)) * 0.5
				if absf(off) < half + 0.3:
					var ta: = float(o.a) + (1.0 if off >= 0.0 else -1.0) * (half + 0.9)
					return boss.position + Vector3(sin(ta), 0, cos(ta)) * maxf(3.0, raid._flat(boss.position, p.position))
			"doom":
				if int(o.stage) == 1 and p.hp <= _doom_need(o.ab, p) * 1.05:
					var best: = Vector3.INF
					for orb in o.orbs:
						if best == Vector3.INF or raid._flat(p.position, orb.pos) < raid._flat(p.position, best):
							best = orb.pos
					if best != Vector3.INF:
						return best
			"leap":
				if str(o.stage) in ["air", "lock"]:
					var away: = raid._dir(o.at, p.position)
					if raid._flat(o.at, p.position) < float(o.ab.size) + 2.0:
						return o.at + away * (float(o.ab.size) + 3.0)
			"runes":
				if str(o.stage) == "input":
					return o.runes[int(o.order[int(o.next)])].pos
				return o.mid
	return Vector3.INF





func _log(text: String) -> void :
	if world.autopilot:
		print("  trial %s" % text)


func _time(t: float) -> float:
	return t * (GameData.RAID_GENTLE_CAST if raid.gentle else 1.0)


func _bar(left: float, total: float) -> String:
	var bars: = 12
	var filled: = clampi(roundi((1.0 - left / maxf(0.01, total)) * bars), 0, bars)
	return "▮".repeat(filled) + "▯".repeat(bars - filled)




func _charge_tell(t: float, col: Color) -> void :
	var boss: = raid.boss
	boss.hold = maxf(boss.hold, t + 0.3)
	if boss.visual is RoVisual:
		(boss.visual as RoVisual).play(RoVisual.MOB_ATTACK, true, true)
	world.play_sound("beginspell", 0.0, -2.0)
	var under: = GameData.MVP_UNDER_PRIORITY
	Vfx.ring(world.fx_root, boss.position, 2.6, Color(col, 0.9), minf(t, 1.2))
	Vfx.magic_circle(world.fx_root, boss.position, 3.4, Color(col, 0.8), t + 0.3, "mvp_rune", 0.9, under, true)
	Vfx.magic_circle(world.fx_root, boss.position, 2.0, Color(col.lightened(0.4), 0.85), t + 0.3, "mvp_hexa", -2.4, under, true)
	world.spawn_fx("lightning", boss.position, 0.8, 0.5)



func _still_boss() -> void :
	var boss: = raid.boss
	boss.hold = maxf(boss.hold, 0.3)
	boss.hit_cd = maxf(boss.hit_cd, 0.3)



func _pacify() -> void :
	for e in world.enemies:
		if is_instance_valid(e) and not e.dead:
			e.hold = maxf(e.hold, 0.3)
			e.hit_cd = maxf(e.hit_cd, 0.3)


func _under(s: GeometryInstance3D) -> void :
	if s is SpriteBase3D:
		(s as SpriteBase3D).no_depth_test = true
		(s as SpriteBase3D).render_priority = GameData.MVP_UNDER_PRIORITY




func _hero_ring(h: Player, close: float) -> Node3D:
	var node: = _make_hero_ring(h.slot, close)
	raid._reg(node, ["hring", h.slot, close])
	return node


func _make_hero_ring(slot: int, close: float) -> Node3D:
	if slot < 0 or slot >= world.heroes.size():
		return null
	var node: = Node3D.new()
	world.heroes[slot].add_child(node)
	var disc: = Vfx._flat(node, Vfx.disc_texture(), Vector3.ZERO, 1.25, Color(1, 1, 1, 0.2))
	disc.name = "Disc"
	var edge: = Vfx._flat(node, Vfx.ring_texture(), Vector3.ZERO, 1.25, Color(1, 1, 1, 0.95))
	edge.name = "Edge"
	_under(disc)
	_under(edge)
	if close > 0.0:
		var c: = Vfx._flat(node, Vfx.ring_texture(), Vector3.ZERO, 1.25, Color(1, 1, 1, 0.0))
		c.name = "Close"
		_under(c)
		c.scale = Vector3.ONE * 3.4
		var tw: = c.create_tween().set_parallel()
		tw.tween_property(c, "scale", Vector3.ONE, close)
		tw.tween_property(c, "modulate:a", 0.95, close * 0.5)
	node.set_meta("ok", true)
	_ring_paint(node)
	return node


func _ring_paint(node: Node3D) -> void :
	var col: = GOOD if bool(node.get_meta("ok", true)) else BAD
	for c in node.get_children():
		if c is Sprite3D:
			(c as Sprite3D).modulate = Color(col, (c as Sprite3D).modulate.a)


func _ring_ok(node, ok: bool) -> void :
	if node == null or not is_instance_valid(node) or bool(node.get_meta("ok", true)) == ok:
		return
	node.set_meta("ok", ok)
	_ring_paint(node)
	if node.has_meta("raid_id"):
		raid._net(["trial_ok", int(node.get_meta("raid_id")), ok])


func _fade_all(nodes: Array, t: float) -> void :
	for n in nodes:
		raid._fade(n, t)




func _side_col(side: String) -> Color:
	return LIGHT if side == "light" else DARK


func _polar_start(ab: Dictionary, p: Player) -> void :
	raid.to_center()
	var flips: bool = (ab.get("flip", []) as Array).has(raid.phase)
	var t: = _time(float(ab.get("flip_time", 7.5)) if flips else float(ab.time))
	var side: = "light" if randf() < 0.5 else "dark"
	var size: = float(ab.get("size", 2.6))



	var to: = (p.position - raid.center) * Vector3(1, 0, 1)
	var a: = atan2(to.z, to.x) if to.length() > 1.0 else randf() * TAU
	var spots: = {}
	var nodes: Array = []
	var k: = 1.0 if randf() < 0.5 else -1.0
	for s in ["light", "dark"]:
		var at: = raid._walkable(raid.center + Vector3(cos(a + 1.05 * k), 0, sin(a + 1.05 * k)) * raid.radius * 0.5)
		at.y = world.map.height_at(at)
		k = - k
		var zone: = raid._zone(at, size, _side_col(s), "")
		var deco: = _polar_deco(zone, size, s)
		if zone.has_meta("raid_id"):
			raid._reg(deco, ["polar_deco", int(zone.get_meta("raid_id")), size, s])
		raid._label(zone, tr("LUZ") if s == "light" else tr("OSCURIDAD"), _side_col(s).lightened(0.35), 3.0, 46)
		Vfx.column(world.fx_root, at, _side_col(s))
		spots[s] = at
		nodes.append(zone)
	_charge_tell(t, _side_col(side))
	var o: = {"kind": "polar", "solo": true, "ab": ab, "t": t, "total": t, "side": side, "spots": spots, "size": size, 
		"nodes": nodes, "flip": t * 0.55 if flips else -1.0, "show": str(ab.name)}
	_polar_dress(o)
	raid._objects.append(o)




func _polar_dress(o: Dictionary) -> void :
	var boss: = raid.boss
	var side: String = o.side
	var col: = _side_col(side)
	for key in ["node", "label"]:
		if o.has(key) and is_instance_valid(o[key]):
			o[key].queue_free()
	var at: = Vector3(boss.position.x, world.map.height_at(boss.position), boss.position.z)
	var aura: = _make_aura(at, side)
	raid._reg(aura, ["polar_aura", at, side])
	o["node"] = aura
	o["label"] = raid._label(boss, "", col.lightened(0.3), 3.0, 40)
	Vfx.column(world.fx_root, boss.position, col)
	world.spawn_fx("holyhit" if side == "light" else "hell_in", boss.position, 1.6, 0.9)
	world.play_sound("angelus" if side == "light" else "stone_curse", 0.0, -2.0)
	world.hud.flash(col, 0.3, 0.2)
	if side == "light":
		raid._tip(tr("%s: ¡carga LUZ, corre al pilar de luz!") % tr(str(o.ab.name)), LIGHT, "warning")
	else:
		raid._tip(tr("%s: ¡carga OSCURIDAD, corre al pilar oscuro!") % tr(str(o.ab.name)), DARK.lightened(0.25), "warning")



func _polar_deco(zone: Node3D, size: float, side: String) -> Node3D:
	var d: = Node3D.new()
	zone.add_child(d)
	var col: = _side_col(side)
	Vfx.beam(d, Vector3.ZERO, col, 8.0)
	Vfx.beam(d, Vector3.ZERO, col.lightened(0.6) if side == "light" else col.darkened(0.35), 3.5)
	var glow: = Vfx.ground_glow(d, Vector3(0, 0.02, 0), size * 1.35, Color(col, 0.45))
	_under(glow)
	Vfx.magic_circle(d, Vector3.ZERO, size * 0.82, Color(col.lightened(0.2), 0.75), 0.0, "mvp_hexa" if side == "light" else "mvp_seal", 
		1.2 if side == "light" else -1.2, GameData.MVP_UNDER_PRIORITY, true)
	return d




func _make_aura(at: Vector3, side: String) -> Node3D:
	var col: = _side_col(side)
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = at
	var tint: = Vfx._flat(node, Vfx.disc_texture(), raid.center - at, raid.radius, Color(col, 0.0))
	_under(tint)
	tint.create_tween().tween_property(tint, "modulate:a", 0.2, 0.4)
	var glow: = Vfx.ground_glow(node, Vector3(0, 0.03, 0), 4.6, Color(col, 0.75))
	_under(glow)
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.35, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.8, 0.4).set_trans(Tween.TRANS_SINE)
	Vfx.magic_circle(node, Vector3.ZERO, 4.2, Color(col.lightened(0.2), 0.8), 0.0, "mvp_rune", 1.4, GameData.MVP_UNDER_PRIORITY, true)
	Vfx.magic_circle(node, Vector3.ZERO, 2.6, Color(col.lightened(0.5), 0.85), 0.0, "mvp_hexa" if side == "light" else "mvp_seal", -2.6, 
		GameData.MVP_UNDER_PRIORITY, true)
	node.set_meta("trial", "aura")
	node.set_meta("col", col)
	return node


func _polar_update(o: Dictionary, delta: float) -> bool:
	o.t -= delta
	_still_boss()
	var side: String = o.side
	raid._set_text(o.label, "%s  %s" % [tr("¡LUZ!") if side == "light" else tr("¡OSCURIDAD!"), _bar(float(o.t), float(o.total))])
	node_tick(o.node, delta)
	if float(o.flip) > 0.0 and float(o.t) <= float(o.flip):
		o.flip = -1.0
		o.side = "dark" if side == "light" else "light"
		raid._shout(raid.boss, tr("¡Cambio!"), _side_col(o.side).lightened(0.3))
		Vfx.ring(world.fx_root, raid.boss.position, raid.radius, _side_col(o.side), 0.5)
		world.shake(0.4)
		_polar_dress(o)
		return false
	if float(o.t) > 0.0:
		return false

	var ab: Dictionary = o.ab
	var col: = _side_col(side)
	var at: Vector3 = o.spots[side]
	var other: Vector3 = o.spots["dark" if side == "light" else "light"]
	var size: = float(o.size)
	Vfx.burst(world.fx_root, raid.center, raid.radius, col)
	Vfx.ring(world.fx_root, raid.boss.position, raid.radius * 1.2, col.lightened(0.3), 0.6)
	for i in 7:
		var p: = raid._arena_point(0.95)
		if raid._flat(p, at) > size + 1.5:
			world.spawn_fx("holyhit" if side == "light" else "hell_in", p, 1.3, 0.75)
	world.play_sound("magnus" if side == "light" else "meteor", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(0.7)
	world.hud.flash(col, 0.4, 0.3)
	var held: = false
	for h in raid._standing():
		if raid._flat(h.position, at) <= size:
			held = true
			world.number(h.position + Vector3(0, 1.6, 0), tr("¡Protegido!"), col.lightened(0.4))
		else:
			if raid._flat(h.position, other) <= size:
				world.label_over(h, tr("¡Pilar equivocado!"), BAD)
			Vfx.strike_circle(world.fx_root, h.position, 2.0, col)
			raid._hit_pct(float(ab.pct), h)
	if held:
		Vfx.strike_circle(world.fx_root, at, size, col.lightened(0.4))
	_log("polar %s held=%s" % [side, held])
	_fade_all(o.nodes, 0.4)
	raid._fade(o.node, 0.3)
	raid._fade(o.label, 0.2)
	return true




func _snap_start(ab: Dictionary) -> void :
	var boss: = raid.boss
	var mode: = str(ab.get("mode", "any"))
	if mode == "any":
		mode = "stop" if randf() < 0.5 else "move"
	var stop: = mode == "stop"
	var t: = _time(float(ab.time))
	var col: = Color(1.0, 0.62, 0.3) if stop else Color(0.5, 0.9, 1.0)
	_charge_tell(t, col)
	var word: = tr("¡QUIETO!") if stop else tr("¡MUÉVETE!")
	if stop:
		raid._tip(tr("%s: ¡quédate QUIETO cuando termine de cargar!") % tr(str(ab.name)), col, "warning")
	else:
		raid._tip(tr("%s: ¡MUÉVETE cuando termine de cargar, no te pares!") % tr(str(ab.name)), col, "warning")
	var rings: = {}
	var nodes: Array = []
	for h in raid._standing():
		var ring: = _hero_ring(h, t)
		rings[h] = ring
		nodes.append(ring)
		nodes.append(raid._label(h, word, col.lightened(0.2), 2.9, 38))
	raid._objects.append({"kind": "snap", "solo": true, "ab": ab, "t": t, "total": t, "stop": stop, "col": col, "word": word, 
		"rings": rings, "hist": {}, "ok": {}, "clock": 0.0, "nodes": nodes, "label": raid._label(boss, "", col.lightened(0.2), 3.0, 44), 
		"show": str(ab.name)})


func _snap_update(o: Dictionary, delta: float) -> bool:
	o.t -= delta
	o.clock = float(o.clock) + delta
	_still_boss()
	raid._set_text(o.label, "%s\n%s" % [str(o.word), _bar(float(o.t), float(o.total))])
	var party: = raid._standing()
	var hist: Dictionary = o.hist
	for h in party:
		var trail: Array = hist.get(h, [])
		trail.append([float(o.clock), h.position])
		while trail.size() > 2 and float(o.clock) - float(trail[0][0]) > SNAP_WINDOW:
			trail.pop_front()
		hist[h] = trail
		var moved: = raid._flat(h.position, trail[0][1])
		var ok: bool = moved < 0.2 if o.stop else moved > 0.45
		o.ok[h] = ok
		_ring_ok(o.rings.get(h), ok)
	if float(o.t) > 0.0:
		return false
	var ab: Dictionary = o.ab
	var col: Color = o.col
	var boss: = raid.boss
	Vfx.ring(world.fx_root, boss.position, raid.radius * 1.3, col.lightened(0.2), 0.5)
	Vfx.strike_circle(world.fx_root, boss.position, 3.2, col)
	world.play_sound("stone_curse" if o.stop else "earth_quake", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(0.5)
	_log("snap %s ok=%s" % ["stop" if o.stop else "move", o.ok.values()])
	for h in party:
		if bool(o.ok.get(h, true)):
			Vfx.ring(world.fx_root, h.position, 1.8, GOOD, 0.4)
			world.number(h.position + Vector3(0, 1.6, 0), tr("¡Bien!"), GOOD)
			continue
		if o.stop:
			world.spawn_fx(str(ab.get("fx", "stonecurse")), h.position, 1.0, 1.0, h)
			Vfx.strike_circle(world.fx_root, h.position, 1.8, col)
			world.label_over(h, tr("¡Te moviste!"), BAD)
		else:
			Vfx.quake(world.fx_root, h.position, 2.2)
			world.spawn_fx(str(ab.get("fx", "earthhit")), h.position, 1.0, 0.9)
			world.label_over(h, tr("¡Te quedaste quieto!"), BAD)
		raid._hit_pct(float(ab.pct), h)
	_fade_all(o.nodes, 0.25)
	raid._fade(o.label, 0.2)
	return true




func _leap_start(ab: Dictionary, p: Player) -> void :
	var boss: = raid.boss
	var track: = _time(float(ab.get("track", 2.6)))
	var lock: = float(ab.get("lock", 0.8))
	boss.hold = maxf(boss.hold, 0.6 + track + lock + 0.5)
	if boss.visual is RoVisual:
		(boss.visual as RoVisual).play(RoVisual.MOB_ATTACK, true, true)

	Vfx.column(world.fx_root, boss.position, ABYSS)
	Vfx.burst(world.fx_root, boss.position, 4.0, ABYSS.lightened(0.3))
	Vfx.ring(world.fx_root, boss.position, 6.0, ABYSS, 0.6)
	world.spawn_fx("hell_in", boss.position, 1.2, 0.6)
	world.play_sound("warning", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(0.6)
	raid._tip(tr("%s: ¡su sombra te persigue! Aléjala de los demás y sal de ella antes de que caiga") % tr(str(ab.name)), ABYSS.lightened(0.3), "party_alarm")
	_log("leap start")
	var vis: = boss.visual as Node3D
	if vis != null:
		var tw: = vis.create_tween()
		tw.tween_property(vis, "position:y", LEAP_HEIGHT, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var at: = Vector3(p.position.x, world.map.height_at(p.position), p.position.z)
	var shadow: = _make_leap_shadow(float(ab.size))
	raid._reg(shadow, ["leap_shadow", float(ab.size)])
	if shadow != null:
		shadow.global_position = at
	raid._objects.append({"kind": "leap", "solo": true, "ab": ab, "stage": "rise", "t": 0.6, "track": track, "lock": lock, 
		"target": p, "at": at, "node": shadow, "sync": 0.0, "nodes": [], "show": str(ab.name), 

		"total": 0.6 + track + lock + 2.0 * float(ab.get("wave", 0.9)), "left": 0.6 + track + lock + 2.0 * float(ab.get("wave", 0.9)), 
		"label": raid._label(shadow, "", ABYSS.lightened(0.45), 1.2, 44) if shadow != null else null})



func _make_leap_shadow(size: float) -> Node3D:
	var root: = Node3D.new()
	world.fx_root.add_child(root)
	var pool: = Vfx.ground_glow(root, Vector3.ZERO, size * 1.15, Color(0.08, 0.0, 0.12, 0.85))
	pool.no_depth_test = true
	pool.render_priority = Vfx.DANGER_PRIORITY
	var glow: = Vfx.ground_glow(root, Vector3.ZERO, size, Color(ABYSS, 0.55))
	glow.no_depth_test = true
	glow.render_priority = Vfx.DANGER_PRIORITY
	var pulse: = glow.create_tween().set_loops()
	pulse.tween_property(glow, "modulate:a", 0.25, 0.35)
	pulse.tween_property(glow, "modulate:a", 0.6, 0.35)
	Vfx.magic_circle(root, Vector3.ZERO, size, Color(ABYSS.lightened(0.2), 0.85), 0.0, "mvp_rune", 1.6, Vfx.DANGER_PRIORITY, true)
	Vfx.magic_circle(root, Vector3.ZERO, size * 0.6, Color(1.0, 0.35, 0.4, 0.8), 0.0, "mvp_hexa", -2.8, Vfx.DANGER_PRIORITY, true)
	root.scale = Vector3.ONE * 0.2
	root.create_tween().tween_property(root, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	root.set_meta("trial", "leap")
	return root


func _leap_update(o: Dictionary, delta: float) -> bool:
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	var node = o.node
	o.t -= delta
	o.left = maxf(0.0, float(o.left) - delta)
	match str(o.stage):
		"rise":
			boss.hold = maxf(boss.hold, 0.3)
			if float(o.t) <= 0.0:
				o.stage = "air"
				o.t = float(o.track)
				world.play_sound("teleport", 0.0, -4.0)
		"air":
			boss.hold = maxf(boss.hold, 0.3)
			var tgt: Player = o.target
			if not is_instance_valid(tgt) or tgt.downed or tgt.hp <= 0.0:
				tgt = raid._target()
				o.target = tgt

			if tgt != null:
				var to: = Vector3(tgt.position.x, 0, tgt.position.z) - Vector3(o.at.x, 0, o.at.z)
				var step: = float(ab.get("follow", 4.5)) * delta
				if to.length() > step:
					to = to.normalized() * step
				var at: Vector3 = o.at + to
				at.y = world.map.height_at(at)
				o.at = at
			raid._set_text(o.label, tr("¡SAL DE LA SOMBRA!") + "\n" + _bar(float(o.t), float(o.track)))
			if float(o.t) <= 0.0:
				o.stage = "lock"
				o.t = float(o.lock)

				Vfx.telegraph_circle(world.fx_root, o.at, float(ab.size), float(o.lock))
				Vfx.beam_flash(world.fx_root, o.at, ABYSS.lightened(0.3), 12.0, float(o.lock) + 0.2)
				world.play_sound("beginspell", 0.0, 0.0)
		"lock":
			boss.hold = maxf(boss.hold, 0.3)
			raid._set_text(o.label, tr("¡CAE!"))
			if float(o.t) <= 0.0:
				_leap_land(o)
				o.stage = "rifts"
				o.t = float(ab.get("wave", 0.9))
				o.wave = 0
				o.base = randf() * TAU
				o.nodes = raid._spokes_tell(o.at, float(o.base), int(ab.get("rifts", 6)), float(ab.get("width", 1.8)), float(o.t))
		"rifts":
			if float(o.t) > 0.0:
				return false
			var rift: = {"count": int(ab.get("rifts", 6)), "width": float(ab.get("width", 1.8)), "dmg": float(ab.get("rift_dmg", 1.4)), 
				"fx": str(ab.get("fx", "hell_in")), "sound": "earth_quake"}
			raid._spokes_hit(o.at, float(o.base), rift)
			o.wave = int(o.wave) + 1
			if int(o.wave) >= 2:
				_log("leap over")
				return true

			o.base = float(o.base) + PI / float(rift.count)
			o.t = float(ab.get("wave", 0.9))
			o.nodes = raid._spokes_tell(o.at, float(o.base), int(rift.count), float(rift.width), float(o.t))
	if is_instance_valid(node):
		node.global_position = o.at
		o.sync = float(o.sync) - delta
		if float(o.sync) <= 0.0 and node.has_meta("raid_id"):
			o.sync = 0.1
			raid._net(["obj_at", int(node.get_meta("raid_id")), node.global_position])
	return false




func _leap_land(o: Dictionary) -> void :
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	var at: Vector3 = o.at
	boss.position = at
	var vis: = boss.visual as Node3D
	if vis != null:
		vis.position.y = LEAP_HEIGHT * 0.6
		var tw: = vis.create_tween()
		tw.tween_property(vis, "position:y", 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var size: = float(ab.size)
	Vfx.strike_circle(world.fx_root, at, size, ABYSS)
	Vfx.quake(world.fx_root, at, size * 1.3, ABYSS.darkened(0.2))
	Vfx.ring(world.fx_root, at, raid.radius * 1.4, ABYSS.lightened(0.2), 0.7)
	Vfx.ring(world.fx_root, at, size * 2.2, Color(1.0, 0.4, 0.45), 0.45)
	Vfx.burst(world.fx_root, at, size * 1.6, ABYSS.lightened(0.4))
	Vfx.column(world.fx_root, at, ABYSS)
	world.spawn_fx(str(ab.get("fx", "hell_in")), at, 1.6, 0.8)
	world.spawn_fx("earthhit", at, 1.6, 0.8)
	world.play_sound("earth_quake", 0.0, 2.0)
	world.play_sound("meteor", 0.1, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(1.3)
	var hit: = 0
	for h in raid._standing():
		if raid._flat(h.position, at) <= size + 0.3:
			raid._hit_dmg(float(ab.dmg), h)
			world.label_over(h, tr("¡Aplastado!"), BAD)
			hit += 1
	_log("leap land hit=%d" % hit)
	raid._fade(o.node, 0.25)
	raid._fade(o.label, 0.2)




func _guard_start(ab: Dictionary, p: Player) -> void :
	var boss: = raid.boss
	var arc: = float(ab.get("arc", 2.6))
	var dir: = raid._dir(boss.position, p.position)
	var node: = _make_guard(arc)
	raid._reg(node, ["guard", arc])
	node.rotation.y = atan2(dir.x, dir.z)
	var t: = float(ab.duration)
	_log("guard start")
	boss.hold = maxf(boss.hold, t)
	Vfx.column(world.fx_root, boss.position, STEEL)
	Vfx.ring(world.fx_root, boss.position, 4.0, STEEL.lightened(0.3), 0.5)
	world.play_sound("kyrie", 0.0, -2.0)
	world.play_sound("guard_block", 0.0, -2.0)
	raid._tip(tr("%s: ¡su escudo bloquea de frente! Rodéalo y pégale por la espalda") % tr(str(ab.name)), STEEL.lightened(0.2), "party_alarm")
	raid._objects.append({"kind": "guard", "ab": ab, "t": t, "total": t, "a": atan2(dir.x, dir.z), "node": node, "target": p, "at": boss.position, 
		"label": raid._label(boss, "", STEEL.lightened(0.4), 3.0, 40), "blocked": {}, "sync": 0.0, "show": str(ab.name)})





func _make_guard(arc: float) -> Node3D:
	var boss: = raid.boss
	if boss == null or not is_instance_valid(boss):
		return null
	var root: = Node3D.new()
	boss.add_child(root)
	var far: = raid.radius * 2.0
	Vfx._fan(root, far, arc, 0.0, Color(STEEL, 0.22), 0.03)
	Vfx._fan_rim(root, far, arc, 0.0, Color(STEEL.lightened(0.4), 0.75))
	Vfx._fan(root, 3.6, arc, 0.0, Color(STEEL.lightened(0.2), 0.3), 0.04)
	var n: = 7
	var r: = 3.0
	for i in n:
		var ai: = - arc * 0.5 + arc * (i + 0.5) / n
		var at: = Vector3(sin(ai), 0, cos(ai)) * r
		var q: = raid._energy_quad(root, Vector2(arc * r / n * 1.1, 2.8), at + Vector3(0, 1.4, 0), PlaneMesh.FACE_Z, 
			Color(STEEL.lightened(0.25), 0.8), 1.6)
		q.rotation.y = ai
		raid._glow_quad(root, Vector2(arc * r / n * 1.1, 0.5), at + Vector3(0, 0.06, 0), PlaneMesh.FACE_Y, Vfx.blast_texture(), 
			Color(STEEL.lightened(0.5), 0.6)).rotation.y = ai
	root.scale = Vector3.ONE * 0.3
	root.create_tween().tween_property(root, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	root.set_meta("trial", "guard")
	return root


func _guard_update(o: Dictionary, delta: float) -> bool:
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	o.t -= delta



	boss.hold = maxf(boss.hold, 0.2)
	var tgt: Player = o.target
	if not is_instance_valid(tgt) or tgt.downed or tgt.hp <= 0.0:
		tgt = raid._target()
		o.target = tgt
	var dir: = raid._dir(boss.position, tgt.position)
	o.a = rotate_toward(float(o.a), atan2(dir.x, dir.z), float(ab.get("turn", 0.9)) * delta)
	var node: Node3D = o.node
	if is_instance_valid(node):
		node.rotation.y = float(o.a)
		o.sync = float(o.sync) - delta
		if float(o.sync) <= 0.0 and node.has_meta("raid_id"):
			o.sync = 0.1
			raid._net(["trial_yaw", int(node.get_meta("raid_id")), float(o.a)])
	for h in o.blocked.keys():
		o.blocked[h] = float(o.blocked[h]) - delta
	raid._set_text(o.label, tr("Escudo al frente  ·  %d") % ceili(maxf(0.0, float(o.t))))
	if float(o.t) > 0.0:
		return false
	Vfx.ring(world.fx_root, boss.position, 4.0, STEEL.lightened(0.3), 0.4)
	_log("guard over, blocked=%d moved=%.1f" % [int(o.get("n", 0)), raid._flat(boss.position, o.get("at", boss.position))])
	world.play_sound("refine_fail", 0.1, -8.0)
	raid._fade(node, 0.3)
	raid._fade(o.label, 0.2)
	return true




func _guard_blocked(o: Dictionary, src: Player, to: Vector3) -> void :
	o["n"] = int(o.get("n", 0)) + 1
	if float(o.blocked.get(src, 0.0)) > 0.0:
		return
	o.blocked[src] = 0.7
	_log("guard blocked")
	var boss: = raid.boss
	Vfx.burst(world.fx_root, boss.position + to * 3.0 + Vector3(0, 1.0, 0), 1.0, STEEL.lightened(0.5))
	world.play_sound("guard_block", 0.3, -8.0)
	world.label_over(src, tr("¡Bloqueado! Rodéalo"), STEEL.lightened(0.4))





func _doom_need(ab: Dictionary, h: Player) -> float:
	return h.max_hp * float(ab.pct) * (GameData.RAID_GENTLE_DMG if raid.gentle else 1.0)


func _doom_start(ab: Dictionary) -> void :
	var boss: = raid.boss
	var t: = _time(float(ab.get("charge", 3.0)))
	_charge_tell(t, DOOM)
	var danger: = raid._danger_floor(t)
	raid._reg(danger, ["floor", t])
	raid._tip(tr("%s: ¡te dejará con 1 de vida! Recoge un orbe de curación antes del pulso") % tr(str(ab.name)), BAD, "warning")
	raid._objects.append({"kind": "doom", "solo": true, "calm": true, "ab": ab, "stage": 0, "t": t, "total": t, "danger": danger, 
		"label": raid._label(boss, "", Color(1.0, 0.55, 0.5), 3.0, 38), "nodes": [], "orbs": [], "rings": {}, "heads": {}, 
		"fx": 0.0, "show": str(ab.name)})


func _doom_update(o: Dictionary, delta: float) -> bool:
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	o.t -= delta
	_pacify()
	var party: = raid._standing()
	if int(o.stage) == 0:
		raid._set_text(o.label, "%s\n%s" % [tr(str(ab.name)), _bar(float(o.t), float(o.total))])
		o.fx = float(o.fx) - delta
		if float(o.fx) <= 0.0:
			o.fx = 0.3
			Vfx.converge(world.fx_root, boss.position, 5.0, Color(DOOM.lightened(0.2), 0.7), 0.45)
			world.spawn_fx("hell_in", raid._arena_point(0.9), 0.8, 0.5)
		if float(o.t) <= 0.0:
			_doom_strike(o, party)
		return false
	raid._set_text(o.label, "%s\n%s" % [tr("Pulso en %d") % ceili(maxf(0.0, float(o.t))), _bar(float(o.t), float(o.total))])
	for h in party:
		var safe: bool = h.hp > _doom_need(ab, h) * 1.05
		_ring_ok(o.rings.get(h), safe)
		var head: Dictionary = o.heads.get(h, {})
		if not head.is_empty():
			raid.head_timer_tick(head.sigil, head.label, float(o.t), delta)
		if safe:
			continue

		for i in range((o.orbs as Array).size() - 1, -1, -1):
			var orb: Dictionary = o.orbs[i]
			if raid._flat(h.position, orb.pos) < 1.3:
				h.heal(h.max_hp * float(ab.heal), world, true)
				h.hp = minf(h.max_hp, maxf(h.hp, _doom_need(ab, h) * 1.3))
				Vfx.heal_light(world.fx_root, h.position)
				world.spawn_fx("cure", h.position, 1.0, 1.0, h)
				world.play_sound("heal", 0.0, 0.0)
				raid._fade(orb.node, 0.2)
				o.orbs.remove_at(i)
				break
	if float(o.t) > 0.0:
		return false

	Vfx.ring(world.fx_root, boss.position, raid.radius * 1.3, DOOM.lightened(0.2), 0.6)
	Vfx.burst(world.fx_root, raid.center, raid.radius, DOOM)
	for i in 6:
		world.spawn_fx("hell_in", raid._arena_point(0.9), 1.2, 0.7)
	world.play_sound("meteor", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(0.8)
	world.hud.flash(DOOM, 0.4, 0.3)
	_log("doom pulse hp=%s orbs_left=%d" % [party.map( func(h): return "%d/%d" % [h.hp, h.max_hp]), (o.orbs as Array).size()])
	for h in party:
		var need: = _doom_need(ab, h)
		if h.hp > need:
			world.number(h.position + Vector3(0, 1.6, 0), tr("¡Resistido!"), GOOD)
		else:
			raid.stats.fails += 1
		world.hurt_what = str(ab.name)
		h.take_damage(need, world, boss, true)
	for orb in o.orbs:
		raid._fade(orb.node, 0.3)
	_fade_all(o.nodes, 0.25)
	raid._fade(o.get("danger"), 0.4)
	raid._fade(o.label, 0.2)
	return true




func _doom_strike(o: Dictionary, party: Array[Player]) -> void :
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	o.stage = 1
	o.t = _time(float(ab.time))
	o.total = o.t
	Vfx.burst(world.fx_root, boss.position, raid.radius, DOOM)
	world.play_sound("earth_quake", 0.0, 0.0)
	world.play_sound("warning", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(0.8)
	world.hud.flash(Color(0.5, 0.0, 0.05), 0.5, 0.4)
	var spots: Array[Vector3] = []
	for h in party:
		if h.hp > 1.0:
			h.hp = 1.0
		world.spawn_fx("hell_in", h.position, 1.2, 1.0, h)
		Vfx.strike_circle(world.fx_root, h.position, 1.8, DOOM)
		world.number(h.position + Vector3(0, 1.8, 0), tr("¡1 de vida!"), BAD, true)
		world.emote(h, "omg", 1.5)
		var ring: = _hero_ring(h, float(o.t))
		_ring_ok(ring, false)
		o.rings[h] = ring
		o.nodes.append(ring)
		var holder: = Node3D.new()
		h.add_child(holder)
		o.nodes.append(holder)
		var head: = raid.head_timer(h, holder, DOOM)
		o.heads[h] = head
		o.nodes.append(head.label)

		var out: = raid._dir(raid.center, h.position).rotated(Vector3.UP, randf_range(-1.2, 1.2))
		var at: = h.position - out * randf_range(4.5, 6.0)
		if raid._flat(at, raid.center) > raid.radius - 1.5:
			at = raid.center + raid._dir(raid.center, at) * (raid.radius - 1.5)
		spots.append(raid._walkable(at))

	spots.append(raid._arena_point(0.45, boss.position, 3.0))
	for at in spots:
		var node: = _make_heal_orb(at)
		raid._reg(node, ["heal_orb", at])
		raid._label(node, tr("Curación"), HEAL.lightened(0.5), 2.3, 30)
		Vfx.column(world.fx_root, at, HEAL)
		o.orbs.append({"pos": at, "node": node})
	world.play_sound("angelus", 0.0, -4.0)
	raid._warn(UiKit.tr_later("¡1 de vida! Recoge un orbe de curación antes del pulso"), BAD, "warning")




func _make_heal_orb(at: Vector3) -> Node3D:
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	var disc: = Vfx._flat(node, Vfx.disc_texture(), Vector3.ZERO, 1.3, Color(HEAL, 0.25))
	var edge: = Vfx._flat(node, Vfx.ring_texture(), Vector3.ZERO, 1.3, Color(HEAL.lightened(0.3), 0.95))
	_under(disc)
	_under(edge)
	var pulse: = edge.create_tween().set_loops()
	pulse.tween_property(edge, "scale", Vector3.ONE * 1.18, 0.45).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(edge, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_SINE)
	Vfx.magic_circle(node, Vector3.ZERO, 1.15, Color(HEAL.lightened(0.2), 0.7), 0.0, "mvp_seal", 1.6, GameData.MVP_UNDER_PRIORITY, true)
	Vfx.beam(node, Vector3.ZERO, HEAL, 7.0)
	var ball: = Node3D.new()
	node.add_child(ball)
	ball.position = Vector3(0, 1.0, 0)
	for layer in [[1.5, 0.4, HEAL], [0.8, 0.95, HEAL.lightened(0.6)]]:
		var glow: = Vfx.ground_glow(ball, Vector3.ZERO, float(layer[0]), Color(layer[2], float(layer[1])))
		glow.axis = Vector3.AXIS_Z
		glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		glow.no_depth_test = true
		glow.render_priority = GameData.HERO_PRIORITY
	var bob: = ball.create_tween().set_loops()
	bob.tween_property(ball, "position:y", 1.4, 0.6).set_trans(Tween.TRANS_SINE)
	bob.tween_property(ball, "position:y", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	node.scale = Vector3.ONE * 0.2
	node.create_tween().tween_property(node, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return node




func _runes_start(ab: Dictionary) -> void :
	raid.to_center()
	var boss: = raid.boss
	var n: = clampi(int(ab.get("count", 4)), 3, RUNE_COLORS.size())
	var r: = minf(raid.radius * 0.42, 5.5)
	var a0: = TAU / 8.0


	var mid: = Vector3.ZERO
	var party: = raid._standing()
	for h in party:
		mid += h.position / float(party.size())
	if party.is_empty():
		mid = raid.center
	var off: = (mid - raid.center) * Vector3(1, 0, 1)
	mid = raid.center + off.limit_length(maxf(0.0, raid.radius - r - 1.5))
	var runes: Array = []
	var nodes: Array = []
	for i in n:
		var a: = a0 + TAU * i / float(n)
		var at: = raid._walkable(mid + Vector3(cos(a), 0, sin(a)) * r)
		at.y = world.map.height_at(at)
		var node: = _make_rune(at, i)
		raid._reg(node, ["rune", at, i])
		runes.append({"pos": at, "node": node, "armed": false, "done": false})
		nodes.append(node)
	var order: Array = range(n)
	order.shuffle()
	var show: = _time(float(ab.get("show", 1.0)))
	var total: = 1.4 + show * n + float(ab.time)
	boss.hold = maxf(boss.hold, 1.0)
	if boss.visual is RoVisual:
		(boss.visual as RoVisual).play(RoVisual.MOB_ATTACK, true, true)
	Vfx.ring(world.fx_root, boss.position, raid.radius, raid.color.lightened(0.3), 0.8)
	Vfx.magic_circle(world.fx_root, Vector3(mid.x, world.map.height_at(mid), mid.z), r + 2.2, Color(raid.color.lightened(0.3), 0.35), 
		1.4 + show * n, "mvp_rune", 0.5, GameData.MVP_UNDER_PRIORITY, true)
	world.play_sound("lex_aeterna", 0.0, 0.0)
	raid._tip(tr("%s: ¡mira el orden en que se encienden las runas y písalas en ESE orden!") % tr(str(ab.name)), Color(1.0, 0.9, 0.6), 
		"warning")
	raid._objects.append({"kind": "runes", "solo": true, "calm": true, "ab": ab, "stage": "intro", "t": 1.4, "runes": runes, 
		"order": order, "k": 0, "next": 0, "show_t": show, "nodes": nodes, "mid": mid, 
		"label": raid._label(boss, tr("Memoriza el orden"), Color(1.0, 0.92, 0.7), 3.0, 40), "num": null, 
		"show": str(ab.name), "total": total, "left": total})



func _make_rune(at: Vector3, i: int) -> Node3D:
	var col: Color = RUNE_COLORS[i % RUNE_COLORS.size()]
	var node: = Node3D.new()
	world.fx_root.add_child(node)
	node.global_position = Vector3(at.x, world.map.height_at(at), at.z)
	var glow: = Vfx.ground_glow(node, Vector3(0, 0.02, 0), RUNE_SIZE * 1.9, Color(col.lightened(0.3), 0.0))
	glow.name = "Glow"
	var disc: = Vfx._flat(node, Vfx.disc_texture(), Vector3.ZERO, RUNE_SIZE, Color(col, 0.16))
	disc.name = "Disc"
	var edge: = Vfx._flat(node, Vfx.ring_texture(), Vector3.ZERO, RUNE_SIZE, Color(col, 0.55))
	edge.name = "Edge"
	for s in [glow, disc, edge]:
		_under(s)
	var sig: = Vfx.magic_circle(node, Vector3.ZERO, RUNE_SIZE * 0.86, Color(col, 0.35), 0.0, RUNE_SIGILS[i % RUNE_SIGILS.size()], 
		0.5 if i % 2 == 0 else -0.5, GameData.MVP_UNDER_PRIORITY, true)
	if sig != null:
		sig.name = "Sigil"
	var beam: = Vfx.beam(node, Vector3.ZERO, col.lightened(0.25), 6.5)
	beam.name = "Beam"
	beam.visible = false
	node.set_meta("col", col)
	node.set_meta("state", 0)
	node.scale = Vector3.ONE * 0.2
	node.create_tween().tween_property(node, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return node




func _rune_state(node: Node3D, s: int) -> void :
	if node == null or not is_instance_valid(node):
		return
	node.set_meta("state", s)
	var own: Color = node.get_meta("col", Color.WHITE)
	var col: Color = [own, own.lightened(0.35), GOOD, BAD][s]
	var k: Array = [[0.0, 0.16, 0.55, 0.35], [0.85, 0.5, 1.0, 1.0], [0.45, 0.32, 1.0, 0.85], [0.85, 0.45, 1.0, 1.0]][s]
	var i: = 0
	for part in ["Glow", "Disc", "Edge"]:
		var sp: = node.get_node_or_null(part) as Sprite3D
		if sp != null:
			sp.modulate = Color(col, float(k[i]))
		i += 1
	var sig: = node.get_node_or_null("Sigil") as MeshInstance3D
	if sig != null and sig.material_override is StandardMaterial3D:
		(sig.material_override as StandardMaterial3D).albedo_color = Color(col, float(k[3]))
	var beam: = node.get_node_or_null("Beam") as MeshInstance3D
	if beam != null:
		beam.visible = s == 1
	if s != 0:

		var tw: = node.create_tween()
		tw.tween_property(node, "scale", Vector3.ONE * 1.22, 0.1).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "scale", Vector3.ONE, 0.18)


func _set_rune(node: Node3D, s: int) -> void :
	_rune_state(node, s)
	if is_instance_valid(node) and node.has_meta("raid_id"):
		raid._net(["trial_state", int(node.get_meta("raid_id")), s])


func _runes_update(o: Dictionary, delta: float) -> bool:
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	o.t -= delta
	o.left = float(o.left) - delta
	_pacify()
	var runes: Array = o.runes
	var order: Array = o.order
	var n: = runes.size()
	match str(o.stage):
		"intro", "show":
			if float(o.t) > 0.0:
				return false
			raid._fade(o.get("num"), 0.12)
			o.num = null
			if int(o.k) >= n:

				o.stage = "input"
				o.t = float(ab.time)
				o.left = o.t
				for rn in runes:
					rn.armed = false
				Vfx.ring(world.fx_root, boss.position, raid.radius, Color(1.0, 0.92, 0.7), 0.6)
				world.play_sound("party_alarm", 0.0, 0.0)
				raid._warn(UiKit.tr_later("¡Tu turno! Pisa las runas en el mismo orden"), Color(1.0, 0.9, 0.6))
				return false
			o.stage = "show"
			var i: = int(order[int(o.k)])
			var node: Node3D = runes[i].node
			var col: Color = RUNE_COLORS[i % RUNE_COLORS.size()]
			_set_rune(node, 1)
			Vfx.column(world.fx_root, runes[i].pos, col)
			Vfx.ring(world.fx_root, runes[i].pos, RUNE_SIZE * 2.2, col.lightened(0.3), 0.5)
			world.play_sound("drop_yellow", 0.0, 2.0, 0.8 + 0.14 * int(o.k), false)
			o.num = raid._label(node, str(int(o.k) + 1), Color(1, 1, 1), 2.4, 84)
			var lit: = float(o.show_t)
			raid._later(maxf(0.2, lit - 0.2), func():
				if is_instance_valid(node) and int(node.get_meta("state", 0)) == 1:
					_set_rune(node, 0))
			raid._set_text(o.label, "%s  %d/%d" % [tr("Memoriza el orden"), int(o.k) + 1, n])
			o.k = int(o.k) + 1
			o.t = lit
			return false


	raid._set_text(o.label, tr("¡Tu turno!  %d/%d  ·  %d s") % [int(o.next), n, ceili(maxf(0.0, float(o.t)))])
	var party: = raid._standing()
	for i in n:
		var rn: Dictionary = runes[i]
		if rn.done:
			continue
		var on: = party.any( func(h): return raid._flat(h.position, rn.pos) < RUNE_SIZE)
		if not rn.armed:
			rn.armed = not party.any( func(h): return raid._flat(h.position, rn.pos) < RUNE_SIZE + 0.3)
			continue
		if not on:
			continue
		if i != int(order[int(o.next)]):
			_set_rune(rn.node, 3)
			if world.heroes.size() <= 1:
				_runes_fail(o, UiKit.tr_later("¡Orden equivocado!"))
				return true



			_log("runes wrong step (co-op): starts over")
			for h in party:
				if raid._flat(h.position, rn.pos) < RUNE_SIZE:
					Vfx.strike_circle(world.fx_root, rn.pos, RUNE_SIZE * 1.6, BAD)
					world.label_over(h, tr("¡Orden equivocado!"), BAD)
					raid._hit_pct(float(ab.pct) * 0.5, h)
			world.play_sound("refine_fail", 0.0, 0.0)
			raid._warn(UiKit.tr_later("¡Orden equivocado! Empiecen de nuevo desde la primera runa"), BAD, "warning")
			o.next = 0
			var wrong: Node3D = rn.node
			for other in runes:
				other.done = false
				other.armed = false
				if other.node != wrong:
					_set_rune(other.node, 0)
			raid._later(0.7, func():
				if is_instance_valid(wrong) and int(wrong.get_meta("state", 0)) == 3:
					_set_rune(wrong, 0))
			return false
		rn.done = true
		_set_rune(rn.node, 2)
		Vfx.column(world.fx_root, rn.pos, GOOD)
		world.spawn_fx("holyhit", rn.pos, 0.9, 0.8)
		world.play_sound("drop_yellow", 0.0, 2.0, 0.8 + 0.14 * int(o.next), false)
		world.number(rn.pos + Vector3(0, 1.6, 0), "%d/%d" % [int(o.next) + 1, n], GOOD, true)
		o.next = int(o.next) + 1
		if int(o.next) >= n:
			_runes_win(o)
			return true
	if float(o.t) <= 0.0:
		_runes_fail(o, UiKit.tr_later("¡Se acabó el tiempo!"))
		return true
	return false


func _runes_win(o: Dictionary) -> void :
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	_log("runes solved, %.1f s left" % float(o.t))
	raid._vuln = float(ab.stagger)
	raid._vuln_t = raid._vuln
	raid._vuln_k = float(ab.vuln)
	boss.hold = maxf(boss.hold, raid._vuln)

	raid._gap = maxf(raid._gap, raid._vuln * 0.7)
	Vfx.burst(world.fx_root, boss.position, 6.0, Color(1.0, 0.92, 0.7))
	Vfx.column(world.fx_root, boss.position, Color(1.0, 0.95, 0.7))
	for rn in o.runes:
		Vfx.strike_line(world.fx_root, rn.pos, raid._dir(rn.pos, boss.position), raid._flat(rn.pos, boss.position), 0.5, GOOD)
	world.spawn_fx("stun", boss.position + Vector3(0, 2.6, 0), 1.2, 1.0, boss)
	world.play_sound("hammer_fall", 0.0, -2.0)
	world.play_sound("magnus", 0.0, -4.0)
	world.shake(0.6)
	raid._big(tr("¡Secuencia correcta!"), tr("%s queda sin defensas: ¡+%d%% de daño durante %d s!") % [
		tr(str(GameData.MONSTERS[raid.mvp].name)), roundi(raid._vuln_k * 100.0), roundi(raid._vuln)], Color(1.0, 0.85, 0.4))
	_fade_all(o.nodes, 0.5)
	raid._fade(o.label, 0.2)


func _runes_fail(o: Dictionary, why: String) -> void :
	var ab: Dictionary = o.ab
	var boss: = raid.boss
	Vfx.burst(world.fx_root, raid.center, raid.radius, raid.color)
	for rn in o.runes:
		Vfx.strike_circle(world.fx_root, rn.pos, RUNE_SIZE * 2.0, BAD)
		world.spawn_fx(str(ab.get("fx", "hell_in")), rn.pos, 1.4, 0.8)
	world.spawn_fx(str(ab.get("fx", "hell_in")), boss.position, 2.0, 0.9)
	world.play_sound("meteor", 0.0, 0.0)
	world.play_mob_sound(raid.mvp, "attack")
	world.shake(0.8)
	_log("runes failed: %s (next %d)" % [why, int(o.next)])
	raid._warn(why, BAD, "warning")
	raid._hit_all(float(ab.pct))
	raid._fade(o.get("num"), 0.1)
	_fade_all(o.nodes, 0.4)
	raid._fade(o.label, 0.2)





func net_build(kind: String, a: Array) -> Node3D:
	match kind:
		"hring":
			return _make_hero_ring(int(a[0]), float(a[1]))
		"polar_deco":
			var zone = raid._nodes.get(int(a[0]))
			if zone != null and is_instance_valid(zone):
				return _polar_deco(zone, float(a[1]), str(a[2]))
		"polar_aura":
			return _make_aura(a[0], str(a[1]))
		"guard":
			return _make_guard(float(a[0]))
		"leap_shadow":
			return _make_leap_shadow(float(a[0]))
		"heal_orb":
			return _make_heal_orb(a[0])
		"rune":
			return _make_rune(a[0], int(a[1]))
	return null



func net_event(ev: Array) -> void :
	if ev.size() < 3:
		return
	var n = raid._nodes.get(int(ev[1]))
	if n == null or not is_instance_valid(n):
		return
	match str(ev[0]):
		"trial_ok":
			n.set_meta("ok", bool(ev[2]))
			_ring_paint(n)
		"trial_yaw":
			n.set_meta("to_yaw", float(ev[2]))
		"trial_state":
			_rune_state(n, int(ev[2]))




func node_tick(n, delta: float) -> void :
	if n == null or not is_instance_valid(n):
		return
	match str(n.get_meta("trial", "")):
		"aura":
			var t: = float(n.get_meta("fx_t", 0.0)) - delta
			if t <= 0.0:
				t = 0.3
				Vfx.converge(world.fx_root, n.global_position, 5.5, Color((n.get_meta("col") as Color).lightened(0.3), 0.7), 0.45)
			n.set_meta("fx_t", t)
		"guard":
			if n.has_meta("to_yaw"):
				n.rotation.y = lerp_angle(n.rotation.y, float(n.get_meta("to_yaw")), 1.0 - exp( - delta * 12.0))
