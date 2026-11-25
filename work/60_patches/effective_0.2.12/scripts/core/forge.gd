extends RefCounted















const EL_COLOR: = {"fire": Color(1.0, 0.45, 0.15), "water": Color(0.4, 0.72, 1.0), 
	"wind": Color(0.62, 1.0, 0.42), "earth": Color(0.92, 0.7, 0.35)}

const EL_FX: = {"fire": "firepillar", "water": "icecrash", "wind": "lightning", "earth": "earthhit"}
const EL_SOUND: = {"fire": "fire_pillar", "water": "frost_hit", "wind": "thunder", "earth": "earth_quake"}
const MOLTEN_COLOR: = Color(1.0, 0.5, 0.12)





static func pick(world: World, p: Player) -> String:
	var foes: = world.enemies_in_radius(p.position, GameData.TEMPER_RANGE)
	var cur: = p.tempered()
	var best: = str(GameData.TEMPER_ELEMENTS[0])
	var top: = -1.0
	for el in GameData.TEMPER_ELEMENTS:
		var sc: = 0.001 if el == cur else 0.0
		for e in foes:
			if e.dead or e.prop != "":
				continue
			var w: = GameData.TEMPER_BOSS if e.is_boss else (GameData.TEMPER_ELITE if e.def.get("elite", false) else 1.0)
			sc += w * GameData.element_mult(el, e.element())
		if sc > top + 0.0001:
			top = sc
			best = el
	return best




static func temper(world: World, p: Player) -> void :
	if not world.hero_valid(p) or not p.forge_on():
		return
	var el: = pick(world, p)
	for k in GameData.TEMPER_ELEMENTS:
		if k != el:
			p.powers.erase("temper_" + k)
	p.temper_el = el
	p.powers.erase("temper_" + el)
	p.add_power("temper_" + el, GameData.TEMPER_TIME)
	var secs: = float(p.powers.get("temper_" + el, GameData.TEMPER_TIME))
	world.smoke_stats["temper_" + el] = int(world.smoke_stats.get("temper_" + el, 0)) + 1
	if world.net != null and world.net.recording():
		world.net.record(["ftp", world.net.ref_of(p), el, secs])
	temper_look(world, p, el, secs)
	var col: Color = EL_COLOR[el]
	var keep: = _fx_begin(world, p)
	world.spawn_fx(str(EL_FX[el]), p.position, 0.9, 0.9, p)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.06, 0), 2.6, col, 0.5)
	Vfx.burst(world.fx_root, p.position + Vector3(0, 0.9, 0), 1.4, col)
	world.play_sound(str(EL_SOUND[el]), 0.1, -6.0)
	_fx_end(world, keep)

	world._own_timer(0.8, func():
		if world.hero_valid(p):
			world.forge_label(p, temper_word(el), col, true))



static func temper_word(el: String) -> String:
	match el:
		"fire":
			return TranslationServer.translate("¡Templada en Fuego!")
		"water":
			return TranslationServer.translate("¡Templada en Agua!")
		"wind":
			return TranslationServer.translate("¡Templada en Viento!")
	return TranslationServer.translate("¡Templada en Tierra!")






static func temper_look(world: World, p: Player, el: String, secs: float) -> void :
	if p == null or not is_instance_valid(p) or p.visual == null:
		return
	var old: = p.get_node_or_null("TemperAura")
	if old != null:
		old.name = "TemperAuraOld"
		old.queue_free()
	var alpha: = world.hero_fx_alpha(p)
	if alpha <= 0.01 or not EL_COLOR.has(el):
		return
	var col: Color = EL_COLOR[el]
	var aura: = Node3D.new()
	aura.name = "TemperAura"
	p.add_child(aura)
	aura.position = RoVisual.lift * 0.98
	var h: = p.visual.height()
	var glow: = Player._glow_quad(2.6, Color(col, 0.5 * alpha))
	glow.position = Vector3(0, h * 0.45, 0)
	aura.add_child(glow)
	var ground: = Vfx.ground_glow(aura, Vector3(0, - RoVisual.lift.y * 0.98, 0), 1.25, Color(col, 0.55 * alpha))
	ground.render_priority = 3
	var sparks: = _particles(col, alpha, el)
	sparks.position = Vector3(0, h * 0.4, 0)
	aura.add_child(sparks)

	var mat: = glow.material_override as StandardMaterial3D
	var tw: = aura.create_tween().set_loops(maxi(1, ceili(secs / 0.9)))
	tw.tween_method( func(k: float):
		mat.albedo_color.a = (0.3 + 0.3 * k) * alpha, 0.0, 1.0, 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_method( func(k: float):
		mat.albedo_color.a = (0.3 + 0.3 * k) * alpha, 1.0, 0.0, 0.45).set_trans(Tween.TRANS_SINE)
	var end: = aura.create_tween()
	end.tween_interval(maxf(0.0, secs - 1.0))
	end.tween_callback( func(): sparks.emitting = false)
	end.tween_property(ground, "modulate:a", 0.0, 1.0)
	end.parallel().tween_property(aura, "scale", Vector3.ONE * 0.6, 1.0)
	end.tween_callback(aura.queue_free)


static func _particles(col: Color, alpha: float, el: String) -> CPUParticles3D:
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.15, 0.15)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 32)
	pm.no_depth_test = true
	pm.render_priority = 15
	quad.material = pm
	p.mesh = quad
	p.amount = 26
	p.lifetime = 0.9
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.5
	p.direction = Vector3.UP
	p.spread = 25.0
	p.initial_velocity_min = 0.8
	p.initial_velocity_max = 1.8
	match el:
		"fire":
			p.gravity = Vector3(0, 1.4, 0)
		"water":

			p.direction = Vector3.DOWN
			p.gravity = Vector3(0, -1.0, 0)
			p.emission_sphere_radius = 0.7
			p.position.y += 0.6
		"wind":
			p.spread = 180.0
			p.gravity = Vector3.ZERO
			p.initial_velocity_min = 2.0
			p.initial_velocity_max = 3.2
			p.lifetime = 0.5
			p.tangential_accel_min = 6.0
			p.tangential_accel_max = 9.0
		_:
			p.gravity = Vector3(0, -2.5, 0)
			p.initial_velocity_min = 1.4
			p.initial_velocity_max = 2.4
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(col.lightened(0.55), alpha))
	ramp.set_color(ramp.get_point_count() - 1, Color(col, 0.0))
	p.color_ramp = ramp
	p.emitting = true
	return p






static func vent(world: World, p: Player) -> bool:
	var lv: = p.forge_temp_levels()
	if lv < GameData.MPT_MIN:
		return false
	var power: = GameData.MPT_PER * minf(lv, GameData.MPT_CAP)
	var had: = p.powers.has("over_thrust_x")
	p.mpt_power = maxf(p.mpt_power if had else 0.0, power)
	p.forge = maxi(0, p.forge_floor() - p.weapon_refine())
	p.forge_heat = 0.0
	p.powers.erase("over_thrust_x")
	p.add_power("over_thrust_x", GameData.MPT_TIME)
	p.recompute()
	var secs: = float(p.powers.get("over_thrust_x", GameData.MPT_TIME))
	world.smoke_stats["mpt_vents"] = int(world.smoke_stats.get("mpt_vents", 0)) + 1
	world.smoke_stats["mpt_levels"] = float(world.smoke_stats.get("mpt_levels", 0.0)) + minf(lv, GameData.MPT_CAP)
	if world.net != null and world.net.recording():
		world.net.record(["mpt", world.net.ref_of(p), secs, p.mpt_power])
	vent_look(world, p, secs, p.mpt_power)
	var keep: = _fx_begin(world, p)
	var col: = Color(1.0, 0.42, 0.15)
	var chest: = p.position + Vector3(0, 0.9, 0)
	world.spawn_fx("maximizepower", p.position, 1.1, 1.0, p)
	Vfx.burst(world.fx_root, chest, 2.2 + lv * 0.15, col)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.06, 0), 3.5, Color(1.0, 0.75, 0.35), 0.5)
	Vfx.ray_flash(world.fx_root, chest, world.camera.global_basis, col, 0.9)
	world.play_sound("maximize_power", 0.1, -3.0)
	world.play_sound("forge_blast", 0.1, -9.0)
	_fx_end(world, keep)
	world.forge_label(p, TranslationServer.translate("¡Maximum Power-Thrust! +%d%%") % roundi(p.mpt_power * 100.0), Color(1.0, 0.55, 0.2), true)
	world.shake(0.25)
	temper(world, p)
	return true





static func vent_look(world: World, p: Player, secs: float, power: float) -> void :
	if p == null or not is_instance_valid(p) or p.visual == null:
		return
	var old: = p.get_node_or_null("VentAura")
	if old != null:
		old.name = "VentAuraOld"
		old.queue_free()
	var alpha: = world.hero_fx_alpha(p)
	if alpha <= 0.01:
		return
	var k: = clampf(power / (GameData.MPT_PER * GameData.MPT_CAP), 0.2, 1.0)
	var aura: = Node3D.new()
	aura.name = "VentAura"
	p.add_child(aura)
	aura.position = RoVisual.lift * 0.98
	var h: = p.visual.height()
	var glow: = Player._glow_quad(2.2 + 1.4 * k, Color(1.0, 0.3, 0.08, 0.45 * alpha))
	glow.position = Vector3(0, h * 0.5, 0)
	aura.add_child(glow)
	var embers: = _particles(Color(1.0, 0.35, 0.1), alpha, "fire")
	embers.amount = 18 + roundi(26 * k)
	embers.initial_velocity_min = 1.8
	embers.initial_velocity_max = 3.4
	embers.position = Vector3(0, h * 0.3, 0)
	aura.add_child(embers)
	var mat: = glow.material_override as StandardMaterial3D
	var tw: = aura.create_tween().set_loops(maxi(1, ceili(secs / 0.5)))
	tw.tween_method( func(t: float):
		mat.albedo_color.a = (0.25 + 0.3 * t) * alpha, 0.0, 1.0, 0.25)
	tw.tween_method( func(t: float):
		mat.albedo_color.a = (0.25 + 0.3 * t) * alpha, 1.0, 0.0, 0.25)
	var end: = aura.create_tween()
	end.tween_interval(maxf(0.0, secs - 0.8))
	end.tween_callback( func(): embers.emitting = false)
	end.tween_property(aura, "scale", Vector3.ONE * 0.5, 0.8)
	end.tween_callback(aura.queue_free)





static func slam(world: World, p: Player, hits: Array, secs: float) -> void :
	if secs <= 0.0 or not world.hero_valid(p):
		return
	var lg: = p.effects.has("lg_molten")
	var mine: = lg and on_molten(world, p.position)
	for e in hits:
		if not is_instance_valid(e) or e.dead or not (e.is_boss or world.stagger.elite(world, e)) or not world.stagger.fits(world, e):
			continue
		var twice: = mine or (lg and on_molten(world, e.position))
		var fill: = secs * (GameData.MOLTEN_STAGGER if twice else 1.0)
		world.stagger.add(world, e, fill, "hammer_fall", true)
		world.smoke_stats["hf_fill"] = float(world.smoke_stats.get("hf_fill", 0.0)) + fill
		if e.is_boss:
			var keep: = _fx_begin(world, p)
			Vfx.quake(world.fx_root, e.position, e.radius + 1.6, MOLTEN_COLOR if twice else Color(1.0, 0.85, 0.35))
			_fx_end(world, keep)





static func molten(world: World, p: Player, lv: int) -> void :
	if not world.hero_valid(p):
		return
	var keep: = _fx_begin(world, p)
	var tag: = world.damage_tag
	world.damage_tag = "molten_metal"
	var reach: = GameData.MOLTEN_RADIUS * sqrt(p.area_mult)
	var base: = p.basic_atk() * (GameData.MOLTEN_IGNITE + GameData.MOLTEN_PER * lv)
	world.ground_zone(p.position, GameData.SKILLS.molten_metal, reach, base, 0.0, GameData.MOLTEN_TIME)
	world.damage_tag = tag
	if world.net != null and world.net.recording():
		world.net.record(["mm", world.net.ref_of(p), p.position, reach, GameData.MOLTEN_TIME])
	molten_look(world, p, p.position, reach, GameData.MOLTEN_TIME)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.06, 0), reach * 1.3, MOLTEN_COLOR, 0.6)
	Vfx.quake(world.fx_root, p.position, reach * 1.2, Color(1.0, 0.35, 0.08))
	world.play_sound("fire_pillar", 0.1, -7.0)
	_fx_end(world, keep)
	world.smoke_stats["molten_pools"] = int(world.smoke_stats.get("molten_pools", 0)) + 1





static func molten_look(world: World, p: Player, at: Vector3, reach: float, secs: float) -> void :
	var alpha: = world.hero_fx_alpha(p)
	if alpha <= 0.01 or Vfx.hidden():
		return
	var pool: = Vfx.ground_glow(world.fx_root, at, reach * 1.15, Color(1.5, 0.5, 0.1, 0.8 * alpha))
	var core: = Vfx.ground_glow(world.fx_root, at, reach * 0.65, Color(1.7, 1.15, 0.45, 0.75 * alpha))
	pool.render_priority = 4
	core.render_priority = 5
	var tw: = core.create_tween().set_loops(maxi(1, ceili(secs / 0.8)))
	tw.tween_property(core, "scale", Vector3.ONE * 1.12, 0.4).set_trans(Tween.TRANS_SINE)
	tw.tween_property(core, "scale", Vector3.ONE, 0.4).set_trans(Tween.TRANS_SINE)

	var cool: = pool.create_tween()
	cool.tween_interval(maxf(0.0, secs - 1.2))
	cool.tween_property(core, "modulate", Color(1.0, 0.25, 0.05, 0.0), 0.8)
	cool.parallel().tween_property(pool, "modulate", Color(0.8, 0.15, 0.05, 0.5 * alpha), 0.8)
	cool.tween_property(pool, "modulate:a", 0.0, 0.4)
	cool.tween_callback( func():
		pool.queue_free()
		core.queue_free())


	for i in int(secs / 0.3):
		world._own_timer(0.3 * i + randf() * 0.2, func():
			if not is_instance_valid(pool):
				return
			var a: = randf() * TAU
			var spot: = at + Vector3(cos(a), 0, sin(a)) * reach * 0.8 * sqrt(randf())
			var fx: = RoEffect.spawn(world.fx_root, "firehit1", spot + Vector3(0, 0.15, 0), 0.3)
			if fx != null:
				fx.intensity = 0.6 * alpha)



static func on_molten(world: World, pos: Vector3) -> bool:
	for z in world._zones:
		if float(z.t) > 0.0 and (z.sk as Dictionary).get("molten", false) and world._on_cell(z, pos):
			return true
	return false




static func _fx_begin(world: World, p: Player) -> Array:
	var keep: = [Vfx.dim, Vfx.hero, world.damage_by]
	Vfx.hero = true
	Vfx.dim = world.hero_fx_alpha(p)
	world.damage_by = p
	return keep


static func _fx_end(world: World, keep: Array) -> void :
	Vfx.dim = float(keep[0])
	Vfx.hero = bool(keep[1])
	world.damage_by = keep[2]



static func net_event(world: World, ev: Array) -> void :
	var h = world._net_node(ev[1])
	if not (h is Player):
		return
	match str(ev[0]):
		"ftp":
			(h as Player).temper_el = str(ev[2])
			temper_look(world, h, str(ev[2]), float(ev[3]))
		"mpt":
			vent_look(world, h, float(ev[2]), float(ev[3]))
		"mm":
			molten_look(world, h, ev[2], float(ev[3]), float(ev[4]))
		"aw":
			var dim: = Vfx.dim
			Vfx.dim = world.hero_fx_alpha(h)
			world._axe_whirl(h, float(ev[2]), float(ev[3]), float(ev[4]), str(ev[5]))
			Vfx.dim = dim
