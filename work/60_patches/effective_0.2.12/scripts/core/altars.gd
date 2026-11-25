class_name Altars
extends Node







const RO_FONT_BOLD = preload("res://assets/ro/fonts/SCDream6.otf")

var world: World

var waiting: Array[Dictionary] = []

var taken: Array[String] = []

var mods: = {}
var _timer: = 0.0
static var _ring_shader: Shader

var _guards: Array = []

var _hypno_due: Array = []

var _floor_rose: = false


func reset() -> void :
	for a in waiting:
		if is_instance_valid(a.node):
			a.node.queue_free()
	waiting.clear()
	taken.clear()
	mods.clear()
	_guards.clear()
	_hypno_due = GameData.HYPNO_AT.duplicate()
	_floor_rose = false
	_timer = randf_range(GameData.ALTAR_EVERY[0], GameData.ALTAR_EVERY[1])


func mod(key: String) -> float:
	return float(mods.get(key, 0.0))




func set_shown(on: bool) -> void :
	for a in waiting:
		if is_instance_valid(a.node):
			a.node.visible = on





func client_tick(delta: float) -> void :
	for a: Dictionary in waiting:
		if not is_instance_valid(a.get("node")):
			continue
		var dist: = INF
		for h in world.heroes:
			if is_instance_valid(h) and not h.downed:
				dist = minf(dist, Vector2(h.position.x - a.pos.x, h.position.z - a.pos.z).length())
		var on: = dist < GameData.ALTAR_RADIUS
		var was: float = a.fill
		a.fill = clampf(a.fill + (delta if on else - delta * 1.5), 0.0, GameData.ALTAR_CHANNEL * 0.98)
		a.near = move_toward(float(a.get("near", 0.0)), 1.0 if dist < 9.0 else 0.0, delta * 3.0)
		if a.has("card") and is_instance_valid(a.card):
			for l: Label3D in a.card.get_children():
				l.modulate.a = a.near
				l.outline_modulate.a = 0.9 * a.near
			a.card.visible = a.near > 0.01
		var mat: ShaderMaterial = a.ring.material_override
		mat.set_shader_parameter("progress", a.fill / GameData.ALTAR_CHANNEL)
		mat.set_shader_parameter("near", maxf(a.near, 0.25))
		if on and was <= 0.0:
			world.play_sound("beginspell", 0.0, -4.0)
		if on:
			a.pulse = float(a.get("pulse", 0.0)) - delta
			if a.pulse <= 0.0:
				a.pulse = 0.3
				var col: Color = GameData.ALTARS[a.id].color
				Vfx.ring(world.fx_root, a.pos + Vector3(0, 0.1, 0), 0.6 + 1.6 * a.fill / GameData.ALTAR_CHANNEL, col.lightened(0.3), 0.35)
				world.play_sound("ui_click", 0.0, -16.0 + 10.0 * a.fill / GameData.ALTAR_CHANNEL)




func tick(delta: float, pace: = 1.0) -> void :


	var frozen: = world.raid.active()
	if not world.running or (frozen and world.raid.state != "portal"):
		return
	if not frozen:
		_rise(delta, pace)
	for i in range(waiting.size() - 1, -1, -1):
		var a: Dictionary = waiting[i]
		if not frozen:
			a.life -= delta

		var dist: = INF
		var near: Player = null
		for h in world.heroes:
			if not h.downed:
				var dh: = Vector2(h.position.x - a.pos.x, h.position.z - a.pos.z).length()
				if dh < dist:
					dist = dh
					near = h
		var on: = dist < GameData.ALTAR_RADIUS

		if on and GameData.ALTARS[a.id].get("calm", false) and world.clock - near.hurt_at < GameData.KARMA_CALM:
			on = false
			if world.clock >= float(a.get("calm_said", -99.0)):
				a["calm_said"] = world.clock + 2.0
				world.number(near.position + Vector3(0, 2.2, 0), TranslationServer.translate("Baldur pide calma..."), Color(GameData.ALTARS[a.id].color), true)
		a["by"] = near
		var was: float = a.fill
		a.fill = clampf(a.fill + (delta if on else - delta * 1.5), 0.0, GameData.ALTAR_CHANNEL)

		a.near = move_toward(float(a.near), 1.0 if dist < 9.0 else 0.0, delta * 3.0)
		for l: Label3D in a.card.get_children():
			l.modulate.a = a.near
			l.outline_modulate.a = 0.9 * a.near
		a.card.visible = a.near > 0.01
		var mat: ShaderMaterial = a.ring.material_override
		mat.set_shader_parameter("progress", a.fill / GameData.ALTAR_CHANNEL)
		mat.set_shader_parameter("near", maxf(a.near, 0.25))
		if on and was <= 0.0:
			world.play_sound("beginspell", 0.0, -4.0)
		if on:
			a.pulse = float(a.pulse) - delta
			if a.pulse <= 0.0:
				a.pulse = 0.3
				var col: Color = GameData.ALTARS[a.id].color
				Vfx.ring(world.fx_root, a.pos + Vector3(0, 0.1, 0), 0.6 + 1.6 * a.fill / GameData.ALTAR_CHANNEL, col.lightened(0.3), 0.35)
				world.play_sound("ui_click", 0.0, -16.0 + 10.0 * a.fill / GameData.ALTAR_CHANNEL)
		if a.fill >= GameData.ALTAR_CHANNEL:
			_accept(a)
			waiting.remove_at(i)
		elif a.life <= 0.0:
			_crumble(a)
			waiting.remove_at(i)
	_check_guards()



func _rise(delta: float, pace: float) -> void :


	var climb: = world.tower
	if climb != null and (climb.state != "fight" or _floor_rose):
		return
	var had: = waiting.size()
	_timer -= delta * pace
	if _timer <= 0.0:
		_timer = randf_range(GameData.ALTAR_EVERY[0], GameData.ALTAR_EVERY[1])


		if waiting.filter( func(w): return str(w.get("id", "")) != "hypnotist").size() < GameData.ALTAR_MAX:
			spawn()



	if climb == null:
		if not _hypno_due.is_empty() and world.time >= float(_hypno_due[0]):
			var due: = float(_hypno_due[0])
			if world.time > due + GameData.HYPNO_WINDOW:
				_hypno_due.pop_front()
			elif _hypno_ok():
				_hypno_due.pop_front()
				spawn("hypnotist")
			if _hypno_due.is_empty() and world.endless:
				_hypno_due.append(maxf(due, world.time) + GameData.HYPNO_ENDLESS_EVERY)
		elif _hypno_due.is_empty() and world.endless:
			_hypno_due.append(world.time + GameData.HYPNO_ENDLESS_EVERY)
	_floor_rose = climb != null and waiting.size() > had




const ALTAR_APART: = 9.0


const ALTAR_MIN_GAP: = 4.6



func _free_spot(any_gap: = false) -> Vector3:
	var best: = _free_spot_try(GameData.ALTAR_DIST[0], GameData.ALTAR_DIST[1], any_gap)

	if best == Vector3.INF:
		best = _free_spot_try(GameData.ALTAR_DIST[0] * 0.4, GameData.ALTAR_DIST[1], any_gap)



	if best == Vector3.INF:
		var from: = world.player.position
		for k in 8:
			var p: = world.map.reachable_point(from + Vector3(float(GameData.ALTAR_DIST[0]), 0, 0).rotated(Vector3.UP, TAU * k / 8.0 + randf() * 0.5), from)
			if p == Vector3.INF:
				continue
			if any_gap or waiting.all( func(a): return Vector2(p.x - a.pos.x, p.z - a.pos.z).length() >= ALTAR_MIN_GAP):
				best = p
				break
	return best






func _free_spot_try(near: float, far: float, any_gap: bool) -> Vector3:
	var best: = Vector3.INF
	var best_gap: = -1.0
	var from: = world.player.position
	for i in 24:
		var p: = world.map.find_point_around(from, near, far)
		if p == Vector3.INF or not world.map.can_reach(p, from):
			continue
		var gap: = INF
		for a in waiting:
			gap = minf(gap, Vector2(p.x - a.pos.x, p.z - a.pos.z).length())
		if gap >= ALTAR_APART:
			return p
		if gap > best_gap and (any_gap or gap >= ALTAR_MIN_GAP):
			best_gap = gap
			best = p
	return best



func floor_over() -> void :
	for a in waiting:
		_crumble(a)
	waiting.clear()
	_floor_rose = false



func spawn(force: = "", where: = Vector3.INF) -> void :


	var ids: = GameData.ALTARS.keys().filter( func(id): return not GameData.ALTARS[id].has("npc") and not GameData.ALTARS[id].has("karma"))
	var total: = 0.0
	for id in ids:
		total += float(GameData.MOD_ALTAR_W.get(id, GameData.ALTARS[id].get("w", 1.0)))
	var r: = randf() * total
	var pick: = ""
	for id in ids:
		r -= float(GameData.MOD_ALTAR_W.get(id, GameData.ALTARS[id].get("w", 1.0)))
		if r <= 0.0:
			pick = id
			break
	if pick == "":
		pick = ids[0]
	if force != "":
		pick = force
	var at: = where if where != Vector3.INF else _free_spot(GameData.ALTARS[pick].has("npc"))
	if at == Vector3.INF:
		return
	at = Vector3(at.x, world.map.height_at(at), at.z)
	var d: Dictionary = GameData.ALTARS[pick]
	var node: = Node3D.new()
	world.run_root.add_child(node)
	node.global_position = at
	var path: = RoAssets.model_path(str(d.get("model", "")))
	if d.has("npc"):
		var spr: = RoAssets.sprite([str(d.npc)])
		if spr != null:
			var npc: = RoVisual.new()
			node.add_child(npc)
			npc.setup(spr, Color.WHITE, 20, 1.0)
			npc.play(0, true)
			_hypno_decor(node, npc, Color(d.color))
	elif ResourceLoader.exists(path):
		var model: = (load(path) as PackedScene).instantiate() as Node3D
		node.add_child(model)
		_fit_height(model, float(d.get("height", 3.5)) * 1.4)
	if not d.has("npc"):
		var glow: = Vfx.ground_glow(node, Vector3(0, 0.04, 0), GameData.ALTAR_RADIUS * 1.3, Color(d.color, 0.55))
		var tw: = glow.create_tween().set_loops()
		tw.tween_property(glow, "modulate:a", 0.35, 0.9).set_trans(Tween.TRANS_SINE)
		tw.tween_property(glow, "modulate:a", 0.9, 0.9).set_trans(Tween.TRANS_SINE)
	var ring: = _rune_circle(Color(d.color))
	node.add_child(ring)
	var card: = _deal_card(d)
	node.add_child(card)

	node.add_to_group(RoVisual.VIEW_GROUP)
	node.rotation.y = RoVisual.view_yaw

	node.scale = Vector3(1, 0.01, 1)
	var rise: = node.create_tween()
	rise.tween_property(node, "scale", Vector3.ONE, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Vfx.ring(world.fx_root, at + Vector3(0, 0.1, 0), 3.0, Color(d.color), 0.6)
	var life: = GameData.HYPNO_LIFE if d.has("npc") else GameData.ALTAR_LIFE
	waiting.append({"id": pick, "node": node, "pos": at, "life": life, "fill": 0.0, "ring": ring, 
		"card": card, "near": 0.0, "pulse": 0.0})




func _rune_circle(col: Color) -> MeshInstance3D:
	if _ring_shader == null:
		_ring_shader = Shader.new()
		_ring_shader.code = "shader_type spatial;\nrender_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_add, shadows_disabled;\nuniform vec4 col : source_color = vec4(1.0);\nuniform float progress = 0.0;\nuniform float near = 0.0;\nvoid fragment() {\n\tvec2 p = UV * 2.0 - 1.0;\n\tfloat r = length(p);\n\tfloat a = atan(p.x, -p.y);\n\tfloat u = fract(a / 6.2831853 + 1.0);\n\tfloat ring = smoothstep(0.80, 0.84, r) * smoothstep(0.97, 0.93, r);\n\tfloat arc = ring * step(u, progress);\n\tfloat inner = smoothstep(0.60, 0.63, r) * smoothstep(0.72, 0.69, r);\n\tfloat marks = step(0.55, fract((a + TIME * (0.6 + progress * 3.0)) / 6.2831853 * 18.0));\n\tfloat glow = exp(-pow((r - 0.88) * 9.0, 2.0)) * progress;\n\tfloat core = smoothstep(0.55, 0.0, r) * progress * progress * 0.5;\n\tfloat pulse = 0.85 + 0.15 * sin(TIME * 5.0);\n\tfloat v = ring * 0.22 * near + arc * 1.3 + inner * marks * (0.18 + 0.8 * progress) * near + glow * 0.7 * pulse + core;\n\tALBEDO = mix(col.rgb, vec3(1.0), arc * 0.35 + core * 0.6);\n\tALPHA = clamp(v, 0.0, 1.0);\n}"




















	var m: = MeshInstance3D.new()
	var q: = PlaneMesh.new()
	q.size = Vector2.ONE * GameData.ALTAR_RADIUS * 2.4
	m.mesh = q
	var mat: = ShaderMaterial.new()
	mat.shader = _ring_shader
	mat.set_shader_parameter("col", col)
	mat.render_priority = -1
	m.material_override = mat
	m.position = Vector3(0, 0.08, 0)
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return m



func _deal_card(d: Dictionary) -> Node3D:
	var card: = Node3D.new()
	var up: = Vector3(0, cos(World.CAMERA_PITCH), - sin(World.CAMERA_PITCH))
	var top: = float(d.get("height", 3.5)) * 1.4 + 0.9
	var lines: = [[tr(str(d.name)), Color(d.color).lightened(0.35), 54]]
	if str(d.get("bad", "")) != "":

		lines.append([tr(str(d.bad)) if d.get("calm", false) else _signed("−", tr(str(d.bad))), Color(1.0, 0.55, 0.5), 42])
	lines.append([_signed("+", tr(str(d.good))), Color(0.55, 1.0, 0.6), 42])
	for i in lines.size():
		var l: = Label3D.new()
		l.text = lines[i][0]
		l.font = RO_FONT_BOLD
		l.font_size = lines[i][2]
		l.pixel_size = 0.012
		l.outline_size = 9
		l.outline_modulate = Color(0, 0, 0, 0.9)
		l.modulate = lines[i][1]
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.no_depth_test = true
		l.render_priority = 19
		l.outline_render_priority = 18
		l.position = up * (top - i * 0.62)
		card.add_child(l)
	card.visible = false
	return card



static func _fit_height(model: Node3D, h: float) -> void :
	var box: = AABB()
	var first: = true
	for m in model.find_children("*", "MeshInstance3D", true, false):
		var b: AABB = (m as MeshInstance3D).get_aabb()
		var t: = model.global_transform.affine_inverse() * (m as MeshInstance3D).global_transform
		b = t * b
		box = b if first else box.merge(b)
		first = false
	if first or box.size.y <= 0.01:
		return
	var k: = h / box.size.y
	model.scale = Vector3(k, k, k)
	model.position = Vector3( - box.get_center().x * k, - box.position.y * k, - box.get_center().z * k)



func _accept(a: Dictionary) -> void :
	var id: String = a.id
	var d: Dictionary = GameData.ALTARS[id]
	if d.has("npc"):
		_hypnotize(a, d)
		return

	if d.has("karma"):
		var by: Player = a.get("by") if a.get("by") != null and is_instance_valid(a.get("by")) else world.player
		world.karma.take_altar(id, by)
		_celebrate(a, d)
		return
	take(id)
	if d.get("mods", {}).has("guardians"):
		_call_guardians(a.pos)
	_celebrate(a, d)

	world.hell_late.profane(a.pos)



func take(id: String, restoring: = false) -> void :
	var d: Dictionary = GameData.ALTARS[id]
	taken.append(id)

	if world.net.recording() and not restoring:
		world.net.altar_taken(id)
	if not world.autopilot and not restoring:
		Save.bump("altars")
		Save.stat_max("altars_run", taken.size())
	var pm: Dictionary = d.get("mods", {})
	for k in pm:
		mods[k] = mod(k) + float(pm[k])


	if pm.has("mvp_early") and not restoring:
		world.rush_endless_mvp(float(pm.mvp_early))


	for p in world.heroes:
		for k in ["dmg", "max_hp_pct", "regen", "loot", "card", "xp", "crit", "crit_dmg", "proc_chance", "hit_proc", "skill_dmg", "summon_dmg"]:
			if pm.has(k):
				p.altar_mods[k] = float(p.altar_mods.get(k, 0.0)) + float(pm[k])
		if pm.has("legend"):
			p.equipment.legend_bonus += float(pm.legend)
		if pm.has("choices"):
			p.extra_choices += int(pm.choices)
		if pm.has("rerolls"):
			p.rerolls += int(pm.rerolls)
		if pm.has("banishes"):
			p.banishes += int(pm.banishes)
		p.recompute()

		if pm.has("lives") and not restoring:
			p.revives += int(pm.lives)
		if pm.has("heal") and not restoring and not p.downed:
			p.hp = p.max_hp
	world.hud.refresh_altars()


func _celebrate(a: Dictionary, d: Dictionary) -> void :

	Vfx.column(world.fx_root, a.pos, d.color)
	Vfx.burst(world.fx_root, a.pos, 4.0, d.color)
	Vfx.ring(world.fx_root, a.pos + Vector3(0, 0.1, 0), 6.0, Color(d.color).lightened(0.4), 0.7)
	if RoEffect.spawn(world.fx_root, "joblvup", a.pos, 1.0, null) == null:
		Vfx.column(world.fx_root, a.pos, Color(1, 1, 0.8))
	world.play_sound("portal_open", 0.0, -2.0)
	world.play_sound("job_levelup", 0.0, -6.0)
	world.shake(0.3)
	world.hud.flash(Color(d.color, 1.0), 0.35)
	var line: = tr(str(d.good)) if str(d.get("bad", "")) == "" or d.get("calm", false) else "%s   ·   %s" % [tr(str(d.bad)), tr(str(d.good))]
	world.party_announce(tr("%s acepta tu ofrenda") % tr(str(d.god)), Color(d.color).lightened(0.25), line)
	var node: Node3D = a.node
	var tw: = node.create_tween()
	tw.tween_property(node, "scale", Vector3(1.15, 1.15, 1.15), 0.15)
	tw.tween_property(node, "scale", Vector3(0.01, 0.01, 0.01), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(node.queue_free)


static var _spiral_shader: Shader





func _hypno_decor(node: Node3D, npc: RoVisual, col: Color) -> void :
	if _spiral_shader == null:
		_spiral_shader = Shader.new()
		_spiral_shader.code = "shader_type spatial;\nrender_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_mix, shadows_disabled;\nuniform vec4 col : source_color = vec4(1.0);\nuniform vec4 edge : source_color = vec4(1.0);\nvoid fragment() {\n\tvec2 p = UV * 2.0 - 1.0;\n\tfloat r = length(p);\n\tfloat a = atan(p.y, p.x);\n\t// Dark violet arms turning inwards, a bright line along each one.\n\tfloat s = sin(a * 3.0 + r * 13.0 - TIME * 2.4);\n\tfloat arms = smoothstep(0.1, 0.8, s);\n\tfloat line = exp(-pow((s - 0.95) * 9.0, 2.0));\n\tfloat fade = smoothstep(1.0, 0.62, r) * smoothstep(0.03, 0.2, r);\n\tfloat rim = exp(-pow((r - 0.93) * 20.0, 2.0)) * (0.7 + 0.3 * sin(TIME * 3.0));\n\tvec3 dark = col.rgb * 0.32;\n\tvec3 c = mix(dark, col.rgb * 1.3 + 0.15, line);\n\tc = mix(c, edge.rgb, rim);\n\tALBEDO = c;\n\tALPHA = clamp((arms * 0.62 + line * 0.5) * fade + rim * 0.85 + exp(-r * r * 14.0) * 0.5, 0.0, 0.95);\n}"



















	var spiral: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2.ONE * GameData.ALTAR_RADIUS * 2.9
	spiral.mesh = plane
	var mat: = ShaderMaterial.new()
	mat.shader = _spiral_shader
	mat.set_shader_parameter("col", col)
	mat.set_shader_parameter("edge", Color(0.45, 0.95, 1.0))
	mat.render_priority = -2
	spiral.material_override = mat
	spiral.position.y = 0.05
	spiral.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.add_child(spiral)

	npc.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	npc.sprite.render_priority = 2

	var lift: = npc.sprite.position
	var bob: = npc.create_tween().set_loops()
	bob.tween_property(npc.sprite, "position", lift + Vector3(0, 0.55, 0), 1.4).set_trans(Tween.TRANS_SINE)
	bob.tween_property(npc.sprite, "position", lift + Vector3(0, 0.3, 0), 1.4).set_trans(Tween.TRANS_SINE)

	var aura: = Sprite3D.new()
	aura.texture = RoAssets.radial(Color.WHITE, 128)
	aura.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	aura.shaded = false
	aura.pixel_size = 3.2 / 128.0
	aura.modulate = Color(col.darkened(0.35), 0.6)
	aura.position = Vector3(0, 1.3, 0)
	aura.render_priority = -1
	node.add_child(aura)
	var pulse: = aura.create_tween().set_loops()
	pulse.tween_property(aura, "modulate:a", 0.25, 1.1).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(aura, "modulate:a", 0.6, 1.1).set_trans(Tween.TRANS_SINE)

	var orbit: = Node3D.new()
	orbit.position = Vector3(0, 1.25, 0)
	node.add_child(orbit)
	for i in 3:
		var eye: = Sprite3D.new()
		eye.texture = RoAssets.radial(Color.WHITE, 64)
		eye.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		eye.shaded = false
		eye.pixel_size = 0.5 / 64.0
		eye.modulate = Color(0.85, 0.7, 1.0, 0.95) if i != 1 else Color(0.55, 1.0, 1.0, 0.95)
		var ang: = TAU * i / 3.0
		eye.position = Vector3(cos(ang), 0.15 * sin(ang * 2.0), sin(ang)) * 0.95
		orbit.add_child(eye)
	var spin: = orbit.create_tween().set_loops()
	spin.tween_property(orbit, "rotation:y", TAU, 3.2).as_relative()

	var mist: = CPUParticles3D.new()
	mist.amount = 26
	mist.lifetime = 2.2
	mist.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	mist.emission_ring_axis = Vector3.UP
	mist.emission_ring_radius = GameData.ALTAR_RADIUS * 1.1
	mist.emission_ring_inner_radius = 0.3
	mist.emission_ring_height = 0.1
	mist.direction = Vector3.UP
	mist.spread = 12.0
	mist.gravity = Vector3(0, 0.6, 0)
	mist.initial_velocity_min = 0.3
	mist.initial_velocity_max = 0.8
	mist.scale_amount_min = 0.5
	mist.scale_amount_max = 1.1
	var fade: = Gradient.new()
	fade.colors = PackedColorArray([Color(col.darkened(0.3), 0.0), Color(col.darkened(0.2), 0.55), Color(0.45, 0.25, 0.7, 0.0)])
	fade.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	mist.color_ramp = fade
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.45, 0.45)
	var qm: = StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	qm.vertex_color_use_as_albedo = true
	qm.albedo_texture = RoAssets.radial(Color.WHITE, 64)
	quad.material = qm
	mist.mesh = quad
	node.add_child(mist)



func forgettable(p: Player = null) -> Array:
	if p == null:
		p = world.player

	return p.skills.keys()








func hypno_offer(old: String, p: Player = null) -> Array:
	if p == null:
		p = world.player
	var gone: = [old, _base_of(old)]
	var actives: = p.skills.keys().filter( func(id): return id != old and not p.is_passive(id)).size()
	var passives: = p.skills.keys().filter( func(id): return id != old and p.is_passive(id)).size()
	var out: = p.skills.keys().filter( func(id): return id != old and not GameData.HYPNO_KEEP.has(id))
	for id in p.skill_pool() + p.passive_pool():
		if not GameData.SKILLS.has(id) or p.skills.has(id) or out.has(id) or gone.has(id) or GameData.HYPNO_KEEP.has(id)\
		or p.evolved_from(id) or not p.has_needs(id) or p.banished.has("skill:" + id) or p.sn_mult_full(id, old):
			continue
		if (passives < p.max_passives()) if p.is_passive(id) else (actives < p.max_skills()):
			out.append(id)


	var lv: = _hypno_levels(old, p)
	return out.filter( func(id): return hypno_gain(id, lv, p) > 0)




func hypno_gain(id: String, lv: int, p: Player = null) -> int:
	if p == null:
		p = world.player
	if GameData.grows_past_cap(id):
		return lv
	var now: = int(p.skills[id].level) if p.skills.has(id) else 0
	return clampi(GameData.skill_cap(id) - now, 0, lv)



func _hypno_levels(old: String, p: Player = null) -> int:
	if p == null:
		p = world.player
	return GameData.MAX_SKILL_LEVEL + int(p.skills[old].level) - 1 if GameData.SKILLS[old].get("evolved", false) else int(p.skills[old].level)


func _hypno_ok() -> bool:
	if world.autopilot or world.menus.auto_pick or waiting.any( func(a): return GameData.ALTARS[a.id].has("npc")):
		return false

	return world.heroes.any( func(h): return is_instance_valid(h) and forgettable(h).any( func(id): return not hypno_offer(id, h).is_empty()))



static func _base_of(id: String) -> String:
	for base in GameData.EVOLUTIONS:
		if str(GameData.EVOLUTIONS[base].to) == id:
			return base
	return ""





func _hypnotize(a: Dictionary, d: Dictionary) -> void :
	var col: Color = d.color
	Vfx.ring(world.fx_root, a.pos + Vector3(0, 0.1, 0), 6.0, col.lightened(0.4), 0.7)
	Vfx.burst(world.fx_root, a.pos, 3.0, col)
	world.play_sound("beginspell", 0.0, -2.0)
	world.hud.flash(Color(col, 1.0), 0.3)
	var node: Node3D = a.node
	var tw: = node.create_tween()
	tw.tween_property(node, "scale", Vector3(0.01, 1.4, 0.01), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(node.queue_free)

	var by: Player = a.get("by") if a.get("by") != null and is_instance_valid(a.get("by")) else world.player
	if by != world.player and world.net.is_host() and world.net.ask_hypno(by):
		return
	hypno_choose()




func hypno_choose(remote: = false) -> void :
	var col: Color = GameData.ALTARS.hypnotist.color
	var p: = world.player
	var options: = forgettable().filter( func(id): return not hypno_offer(id).is_empty())
	if options.is_empty():
		return
	var notes: = {}
	for id in options:
		notes[id] = tr("Nv %d") % _hypno_levels(id)
	world.menus.show_start_skill(options.filter( func(id): return not p.is_passive(id)), func(old: String): _hypno_pick_new(old, remote), 
		tr("Mírame a los ojos... ¿qué técnica olvidas?"), "hypno_none", "-", options.filter( func(id): return p.is_passive(id)), 
		tr("Se olvida para siempre en esta partida y sus niveles pasan a la habilidad o pasiva que elijas"), 
		func(): world.hud.announce(tr("El Hipnotista"), col.lightened(0.3), tr("«Otra vez será...»")), notes)


func _hypno_pick_new(old: String, remote: = false) -> void :
	var p: = world.player
	var lv: = _hypno_levels(old)
	var offer: = hypno_offer(old)

	var notes: = {}
	for id in offer:
		var now: = int(p.skills[id].level) if p.skills.has(id) else 0
		var gain: = hypno_gain(id, lv)

		notes[id] = [(tr("Nv %d → %d") % [now, now + gain]) if now > 0 else tr("Nueva  ·  Nv %d") % gain, now, now + gain]
	world.menus.show_start_skill(offer.filter( func(id): return not p.is_passive(id)), func(id: String):
			if remote:
				world.net.send_hypno(old, id)
			else:
				_hypno_learn(old, id, lv), 
		tr("Tu mente en blanco: ¿adónde van sus niveles?"), "hypno_none", "-", offer.filter( func(id): return p.is_passive(id)), 
		tr("%s (Nv %d) pasa todos sus niveles a una habilidad o pasiva, nueva o que ya tienes") % [tr(str(GameData.SKILLS[old].name)), lv], 
		Callable(), notes)


func _hypno_learn(old: String, id: String, lv: int, p: Player = null) -> void :
	if p == null:
		p = world.player
	p.skills.erase(old)
	p.banished.append("skill:" + old)

	if Player.base_skill(old) == "call_homunculus":
		for n in [p.homun_node] + p.homun_extra_nodes:
			if n != null and is_instance_valid(n):
				world.spawn_fx("h_levelup", n.position, 0.8, 0.8)
				n.queue_free()
		p.homun_node = null
		p.homun_extra_nodes.clear()
		p.homun_type = ""
		p.homun_extra.clear()
		if p == world.player:
			world.homun = null
	var base: = _base_of(old)
	if base != "":
		p.banished.append("skill:" + base)


	for i in hypno_gain(id, lv, p):
		p.add_skill(id)
	p.recompute()


	p.offer = []
	if p == world.player and world.menus.mode() == "level_up" and not world.net.is_client():
		world.menus.show_level_up(p.offered_choices(), true)
	var col: Color = GameData.ALTARS.hypnotist.color
	world.spawn_fx("joblvup", p.position, 1.0, 1.0, p)
	world.play_sound("levelup", 0.0, -4.0)
	var line: = tr("%s olvidada  ·  %s Nv %d") % [tr(str(GameData.SKILLS[old].name)), tr(str(GameData.SKILLS[id].name)), int(p.skills[id].level)]
	if p == world.player:
		world.hud.announce(tr("El Hipnotista"), col.lightened(0.3), line)
	else:
		world.label_over(p, line, col.lightened(0.3))



func hypno_remote(p: Player, old: String, id: String) -> void :
	if not p.skills.has(old) or not forgettable(p).has(old) or not hypno_offer(old, p).has(id):
		return
	_hypno_learn(old, id, _hypno_levels(old, p), p)


func _crumble(a: Dictionary) -> void :
	var node: Node3D = a.node
	var tw: = node.create_tween()
	tw.tween_property(node, "scale", Vector3(1, 0.01, 1), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(node.queue_free)



func _call_guardians(at: Vector3) -> void :
	var pool: Array = []

	var st: Dictionary = TowerRun.tier_stage(world.tower.floor) if world.tower != null else world.stage
	for ev in st.get("events", []):
		if ev.type == "elite" and not pool.has(ev.mob):
			pool.append(ev.mob)
	if pool.is_empty() and not (st.get("spawns", []) as Array).is_empty():
		pool = [str(st.spawns[0].mob)]
	if pool.is_empty():
		pool = ["orc_warrior" if GameData.MONSTERS.has("orc_warrior") else GameData.MONSTERS.keys()[0]]
	var group: = []
	for i in GameData.EMPERIUM_GUARDS:
		var ang: = TAU * i / GameData.EMPERIUM_GUARDS
		var e: = world.spawn_enemy(str(pool[i % pool.size()]), at + Vector3(cos(ang), 0, sin(ang)) * 3.5, true, true, "guardia")
		if e != null:
			group.append(e)

			var pillar: = Vfx.beam(world.fx_root, e.position, Color(1.0, 0.85, 0.3), 7.0)
			get_tree().create_timer(1.4, false).timeout.connect( func():
				if is_instance_valid(pillar):
					pillar.queue_free())
			Vfx.burst(world.fx_root, e.position, 2.0, Color(1.0, 0.85, 0.3))
	if not group.is_empty():
		_guards.append({"at": at, "foes": group})
		world.shake(0.6)
		world.play_sound("warning", 0.0, -2.0)
		world.party_announce(tr("¡La guardia del Emperium despierta!"), Color(1.0, 0.82, 0.3), tr("Derrótala para ganar la Treasure Box del MVP y un nivel"))


func _check_guards() -> void :
	for i in range(_guards.size() - 1, -1, -1):
		var g: Dictionary = _guards[i]
		if g.foes.all( func(e): return not is_instance_valid(e) or e.dead):
			_guards.remove_at(i)
			world._drop_chest(world.player.position + Vector3(1.5, 0, 0.5), GameData.CHEST_ROLLS.boss, 2)


			for h in world.heroes:
				if is_instance_valid(h):
					h.grant_levels(1)
					world.spawn_fx("joblvup", h.position, 1.2, 1.0, h)
					world.label_over(h, tr("+1 nivel"), Color(0.7, 0.9, 1.0))
			world.party_announce(tr("¡La guardia del Emperium ha caído!"), Color(1, 0.85, 0.3), tr("Treasure Box del MVP y +1 nivel"))




static func _signed(sign: String, text: String) -> String:
	if text.begins_with("+") or text.begins_with("-") or text.begins_with("−"):
		return text
	return sign + "  " + text
