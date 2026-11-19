extends RefCounted

















var world: World
var tower: Node

var rules: Array[String] = []

var exit: = Vector3.INF

var portals: Array = []
var _feroz_t: = 0.0
var _fog_tick: = 0.0
var _fog_sent: = 0.0
var _outside: = {}
var _pfill_t: = 0.0
var _pfill_key: = ""
var _shadow_due: = false


func _init(w: World, t: Node) -> void :
	world = w
	tower = t


func has(rule: String) -> bool:
	return rules.has(rule)




func floor_start(f: int, fight: bool) -> void :
	floor_over()
	exit = Vector3.INF
	if (f - 1) % GameData.HEL_TOWER_RULE_EVERY == 0:
		var left: Array = GameData.HEL_TOWER_RULES.keys().filter( func(k): return not rules.has(str(k)))
		if not left.is_empty():
			var id: = str(left.pick_random())
			rules.append(id)
			var d: Dictionary = GameData.HEL_TOWER_RULES[id]
			world.get_tree().create_timer(1.6, false).timeout.connect( func():
				if world.running:
					world.party_announce(tr("Nueva regla de Hel: %s") % tr(str(d.name)), Color(d.color), tr(str(d.desc)))
					world.play_sound("warning", 0.2, -4.0))
			_send(["rules", rules])
	_feroz_t = GameData.HEL_TOWER_FEROZ * randf_range(0.6, 1.0)
	if not fight:
		return
	if has("fog") or has("portals"):
		exit = _exit_spot()
	if has("fog"):
		var hl = world.hell_late
		hl.fog_on = true
		hl.fog_center = exit
		hl.fog_radius = GameData.HEL_FOG_FROM
		hl.fog_next = Vector3.INF
		hl._fog_send()
		hl._fog_show(true)
		_fog_sent = GameData.HEL_FOG_FROM
		_outside.clear()
	if has("portals"):
		var n: = GameData.HEL_PORTALS + (1 if f >= GameData.HEL_PORTALS_MORE else 0)
		var spots: = []
		for i in n:
			var at: = _portal_spot(spots)
			if at != Vector3.INF:
				spots.append(at)
		_open_portals(spots)
		_send(["portals", spots])
		if not spots.is_empty():
			world.party_announce(tr("¡Portales de Niflheim!"), Color(0.55, 0.9, 1.0), tr("Párate encima para cerrarlos"))
	_shadow_due = has("shadows") and f % GameData.TOWER_TIER_FLOORS == GameData.TOWER_TIER_FLOORS - 1

	if has("elites"):
		var pool: Array = []
		for ev in TowerRun.tier_stage(f).get("events", []):
			if str(ev.get("type", "")) == "elite" and GameData.MONSTERS.has(str(ev.mob)) and not pool.has(str(ev.mob)):
				pool.append(str(ev.mob))
		if not pool.is_empty():
			var at: Vector3 = tower._near_point()
			world.spawn_enemy(str(pool.pick_random()), at, true)




func floor_over() -> void :
	var hl = world.hell_late
	if hl.fog_on:
		hl.fog_on = false
		hl._fog_show(false)
		if world.net != null and world.net.recording():
			world.net.record(["hz", "fog_off"])
	for h in world.heroes:
		if is_instance_valid(h):
			h.fogged = false
	_clear_portals()
	if not portals.is_empty() or world.net.is_host():
		_send(["portals", []])
	for e in hl._shadows:
		if is_instance_valid(e) and not e.dead:
			world.banish_enemy(e)
	hl._shadows.clear()
	_shadow_due = false





func tick(delta: float, done: float, need: float) -> void :
	if world.raid.in_arena():
		return
	var hl = world.hell_late


	if not world.oaths.is_empty():
		world.oath_run.tick(world, delta)
	if tower.state == "fight":
		_feroz_t -= delta * GameData.oath_value("hunt", world.oath("hunt")) * (2.0 if world.oath("elite") >= 3 else 1.0)
		if _feroz_t <= 0.0:
			_feroz_t = GameData.HEL_TOWER_FEROZ * randf_range(0.8, 1.2)
			world._spawn_ferocious()
		if _shadow_due:
			_shadow_due = false
			var mvp: = _next_mvp()
			if mvp != "":
				hl._shadow_spawn(mvp)

				for e in hl._shadows:
					if is_instance_valid(e) and e.visual is RoVisual:
						(e.visual as RoVisual).tint = Color(0.55, 0.4, 0.85, 0.85)
						(e.visual as RoVisual).sprite.modulate = Color(0.55, 0.4, 0.85, 0.85)
	for e in hl._shadows.duplicate():
		if is_instance_valid(e) and not e.dead:
			hl._shadow_cast(e, delta)
	if has("fog") and hl.fog_on:
		_tick_fog(delta, clampf(done / maxf(1.0, need), 0.0, 1.0))
	if not portals.is_empty():
		_tick_portals(delta)



func _next_mvp() -> String:
	var f: int = tower.floor + 1
	if f % GameData.TOWER_FLOORS == 0:
		return GameData.TOWER_LORD
	return str(TowerRun.tier_stage(f).get("mvp", ""))




func _tick_fog(delta: float, k: float) -> void :
	var hl = world.hell_late
	var r: = lerpf(GameData.HEL_FOG_FROM, GameData.HEL_FOG_TO, k)
	hl.fog_radius = r

	if absf(_fog_sent - r) > 0.6:
		_fog_sent = r
		hl._fog_send()
	_fog_tick -= delta
	if _fog_tick > 0.0:
		return
	_fog_tick = 1.0
	for h in world.heroes:
		if not is_instance_valid(h):
			continue
		var out: bool = not h.downed and not hl.in_light(h.position)
		h.fogged = out
		if not out:
			_outside.erase(h.get_instance_id())
			continue
		world.label_over(h, tr("¡Fuera de la luz!"), Color(0.8, 0.65, 1.0))
		var t: = float(_outside.get(h.get_instance_id(), 0.0)) + 1.0
		_outside[h.get_instance_id()] = t
		var pct: = minf(GameData.HELL_FOG_MAX, GameData.HELL_FOG_PCT + GameData.HELL_FOG_RAMP * (t - 1.0))
		world.hurt_what = tr("La niebla de Niflheim")
		h.take_damage(h.max_hp * pct, world, null, true, true)



func _exit_spot() -> Vector3:
	var at: = _party_center()
	if world.map == null:
		return at
	var p: Vector3 = world.map.find_point_around(at, 6.0, 11.0)
	if p == Vector3.INF:
		p = world.map.random_point_around(at, 6.0)
	return Vector3(p.x, world.map.height_at(p), p.z)




func _portal_spot(taken: Array) -> Vector3:
	if world.map == null:
		return Vector3.INF
	var at: = _party_center()
	for i in 20:
		var p: Vector3 = world.map.find_point_around(at, GameData.HEL_PORTAL_DIST.x, GameData.HEL_PORTAL_DIST.y)
		if p == Vector3.INF:
			continue
		if taken.any( func(q): return _flat(q, p) < 6.0):
			continue

		if exit != Vector3.INF and has("fog") and _flat(p, exit) > GameData.HEL_FOG_FROM * 0.8:
			continue
		return Vector3(p.x, world.map.height_at(p), p.z)
	return Vector3.INF



func _open_portals(spots: Array) -> void :
	_clear_portals()
	if world.fx_root == null:
		return
	var cold: = Color(0.45, 0.85, 1.0)
	for at in spots:
		var node: = Node3D.new()
		world.fx_root.add_child(node)
		node.global_position = at
		Vfx.warp_portal(node, Color(0.4, 0.3, 0.9), 1.0)
		var rune = Vfx.magic_circle(node, Vector3.ZERO, GameData.HEL_PORTAL_REACH * 1.25, Color(cold, 0.9), 0.0, "mvp_rune", -0.7, -1, true)
		var fill: = Vfx._flat(node, RoAssets.radial(Color.WHITE, 128), Vector3(0, 0.08, 0), 0.05, Color(cold, 0.65))
		fill.no_depth_test = true
		fill.render_priority = 6
		var lbl: = Label3D.new()
		lbl.text = tr("Portal de Niflheim")
		lbl.font_size = 30
		lbl.pixel_size = 0.012
		lbl.outline_size = 8
		lbl.modulate = Color(0.8, 0.92, 1.0)
		lbl.outline_modulate = Color(0.1, 0.05, 0.3, 0.95)
		lbl.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		lbl.no_depth_test = true
		lbl.render_priority = 20
		lbl.position = Vector3(0, 2.6, 0)
		node.add_child(lbl)
		world.spawn_fx("hell_in", at, 1.0, 0.8)
		portals.append({"at": at, "fill": 0.0, "node": node, "fill_node": fill, "rune": rune, "label": lbl, "t": randf_range(0.5, 1.5)})
	if not spots.is_empty():
		world.play_sound("portal", 0.0, -2.0)


func _clear_portals() -> void :
	for p in portals:
		if p.node != null and is_instance_valid(p.node):
			p.node.queue_free()
	portals.clear()


func _tick_portals(delta: float) -> void :
	var crowd: int = roundi(mini(GameData.TOWER_CROWD_MAX, GameData.TOWER_CROWD + int(tower.floor) / 2) * 1.4)
	var changed: = false
	for i in range(portals.size() - 1, -1, -1):
		var p: Dictionary = portals[i]
		var on: = false
		for h in world.heroes:
			if is_instance_valid(h) and not h.downed and _flat(h.position, p.at) <= GameData.HEL_PORTAL_REACH:
				on = true
				break
		var was: = float(p.fill)
		p.fill = clampf(was + (delta if on else - delta * 0.5), 0.0, GameData.HEL_PORTAL_CLOSE)
		if absf(float(p.fill) - was) > 0.0:
			changed = true
		if float(p.fill) >= GameData.HEL_PORTAL_CLOSE:
			_close(i)
			continue

		p.t = float(p.t) - delta
		if float(p.t) <= 0.0:
			p.t = GameData.HEL_PORTAL_EVERY
			if world.enemies.size() < crowd and not tower._mobs.is_empty():
				for k in GameData.HEL_PORTAL_BATCH:
					var at: Vector3 = world.map.random_point_around(p.at, 1.5) if world.map != null else p.at
					world.spawn_enemy(str(tower._mobs.pick_random()), at)
				world.spawn_fx("hell_in", p.at, 0.7, 0.6)
	_show_fill()

	_pfill_t -= delta
	if changed and _pfill_t <= 0.0:
		_pfill_t = 0.25
		var fills: = portals.map( func(q): return snappedf(float(q.fill), 0.05))
		var key: = var_to_str(fills)
		if key != _pfill_key:
			_pfill_key = key
			_send(["pfill", fills])



func _close(i: int) -> void :
	var p: Dictionary = portals[i]
	var credit: = roundi(float(tower.need) * GameData.HEL_PORTAL_SHARE)
	tower._kills_at -= credit
	_close_fx(p)
	portals.remove_at(i)
	world.party_announce(tr("¡Portal cerrado!"), Color(0.6, 0.9, 1.0), tr("+%d a la cuota del piso") % credit)
	_send(["pclose", i])


func _close_fx(p: Dictionary) -> void :
	var at: Vector3 = p.at
	if p.node != null and is_instance_valid(p.node):
		var node: Node3D = p.node
		var tw: = node.create_tween()
		tw.tween_property(node, "scale", Vector3(1.4, 0.05, 1.4), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(node.queue_free)
	Vfx.burst(world.fx_root, at, 3.0, Color(0.55, 0.85, 1.0))
	Vfx.column(world.fx_root, at, Color(0.7, 0.85, 1.0))
	world.spawn_fx("angelus", at, 1.0, 0.7)
	world.play_sound("teleport", 0.0, -2.0)



func _show_fill() -> void :
	var pulse: = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)
	for p in portals:
		var k: = clampf(float(p.fill) / GameData.HEL_PORTAL_CLOSE, 0.0, 1.0)
		var fill = p.get("fill_node")
		if fill != null and is_instance_valid(fill):
			(fill as Sprite3D).pixel_size = maxf(0.05, GameData.HEL_PORTAL_REACH * 1.2 * k) * 2.0 / 128.0
			(fill as Sprite3D).modulate.a = 0.45 + 0.35 * pulse if k > 0.0 else 0.0
		var lbl = p.get("label")
		if lbl != null and is_instance_valid(lbl):
			(lbl as Label3D).text = tr("Portal de Niflheim") if k <= 0.0 else tr("Cerrando  %d%%") % roundi(k * 100.0)





func draw_tick() -> void :
	if not portals.is_empty():
		_show_fill()
	if not has("shadows") or int(tower.floor) % GameData.TOWER_TIER_FLOORS != GameData.TOWER_TIER_FLOORS - 1:
		return
	for e in world.enemies:
		if is_instance_valid(e) and not e.dead and e.is_boss and e.def.get("mvp", false) and not e.has_meta("mvp_shadow"):
			e.set_meta("mvp_shadow", true)
			var c: = Color(0.55, 0.4, 0.85, 0.85)
			if e.visual is RoVisual:
				(e.visual as RoVisual).tint = c
				(e.visual as RoVisual).sprite.modulate = c




func _send(ev: Array) -> void :
	if world.net != null and world.net.is_host() and world.is_coop():
		world.net.tower_event(["hel"] + ev)



func net_event(ev: Array) -> void :
	match str(ev[0]):
		"rules":
			rules.clear()
			for r in ev[1]:
				rules.append(str(r))
		"portals":
			_open_portals(ev[1])
		"pfill":
			var fills: Array = ev[1]
			for i in mini(fills.size(), portals.size()):
				portals[i].fill = float(fills[i])
		"pclose":
			var i: = int(ev[1])
			if i >= 0 and i < portals.size():
				_close_fx(portals[i])
				portals.remove_at(i)





func crumb_chance() -> float:
	return GameData.HEL_TOWER_CRUMB + GameData.HEL_TOWER_CRUMB_STEP * int(tower.floor) + GameData.HEL_TOWER_CRUMB_OATH * world.oath_points()



func _party_center() -> Vector3:
	var list: Array = world.heroes.filter( func(h): return is_instance_valid(h) and not h.downed)
	if list.is_empty():
		return world.player.position
	var sum: = Vector3.ZERO
	for h in list:
		sum += (h as Player).position
	var at: Vector3 = sum / list.size()
	if world.map != null and not world.map.is_walkable(at):
		at = (list[0] as Player).position
	return at


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
