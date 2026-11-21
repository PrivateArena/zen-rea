class_name Uniques
extends RefCounted










const BONE_SK: = {"plants": ["skeleton"], "color": Color(0.8, 0.8, 0.75), "tick": 0.6, "walks": true, "speed": 5.4, 
	"element": "shadow", "tag": "u_bone"}
const MAYA_SK: = {"plants": ["andre"], "color": Color(0.8, 0.55, 0.3), "tick": 0.8, "walks": true, "speed": 5.2, 
	"element": "earth", "tag": "u_maya"}
const ANTS: = ["andre", "piere", "deniro"]



static func _say(world: World, p: Player, text: String, cd_key: = "", cd: = 2.5) -> void :
	if cd_key != "":
		if world.clock < float(p.uniq.get(cd_key, -99.0)):
			return
		p.uniq[cd_key] = world.clock + cd
	world.number(p.position + Vector3(0, 2.2, 0), text, GameData.UNIQUE_COLOR, true)



static func _burst(world: World, p: Player, at: Vector3, radius: float, base: float, element: String, tag: String, 
		source: = "skill", push: = 3.0) -> Array:
	var hit: Array = []
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = tag
	world.damage_by = p
	for e in world.enemies_in_radius(at, radius):
		if e.dead:
			continue
		var away: = ((e.position - at) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, base, away * push, source, element, tag)
		hit.append(e)
	_restore(world, keep)
	return hit





static func _restore(world: World, keep: Array) -> void :
	world.damage_tag = keep[0]
	world.damage_by = keep[1]




static func on_basic_hit(world: World, p: Player, target: Enemy) -> void :
	var fx: = p.effects

	if fx.has("u_scythe"):
		p.uniq["scythe"] = int(p.uniq.get("scythe", 0)) + 1
		if int(p.uniq.scythe) >= int(fx.u_scythe):
			p.uniq.scythe = 0
			_scythe(world, p)

	if fx.has("u_quake"):
		p.uniq["quake"] = int(p.uniq.get("quake", 0)) + 1
		if int(p.uniq.quake) >= int(fx.u_quake):
			p.uniq.quake = 0
			_quake(world, p)
	if target == null or not is_instance_valid(target) or target.dead:
		return

	if fx.has("u_moon") and randf() < float(fx.u_moon):
		var keep: = [world.damage_tag, world.damage_by]
		world.damage_tag = "u_moon"
		world.damage_by = p
		world.hitscan(p, target, GameData.U_BASE * GameData.U_MOON_DMG, 5, "holy", 
			{"hit_fx": "holyhit", "hit_fx_intensity": 0.6, "knock": 0.5, "trace": Color(1.0, 0.6, 0.85)})
		_restore(world, keep)

	if fx.has("u_rail") and world.clock >= float(p.uniq.get("rail_cd", 0.0)):
		p.uniq["rail_cd"] = world.clock + GameData.U_RAIL_CD
		_rail(world, p, target, float(fx.u_rail))






static func _scythe(world: World, p: Player) -> void :
	var souls: = int(p.uniq.get("scy_souls", 0))
	if souls >= GameData.U_SCYTHE_SOULS:
		p.uniq["scy_souls"] = 0
		_blood_moon(world, p, souls)
		return
	var r: = GameData.U_SCYTHE_RADIUS * sqrt(p.area_mult)
	Vfx.arc(world.fx_root, p.position, p.facing, r, TAU, Color(0.55, 0.2, 0.75))
	Vfx.ring(world.fx_root, p.position, r, Color(0.4, 0.1, 0.55), 0.45)
	Vfx.ring(world.fx_root, p.position, r * 1.3, Color(0.85, 0.3, 1.0), 0.6)
	world.spawn_fx("brandish", p.position, 1.4, 0.9)
	world.spawn_fx("hell_in", p.position, 1.2, 0.8)
	world.play_sound("brandish", 0.2, -4.0)
	world.shake(0.25)
	var dmg: = GameData.U_BASE * GameData.U_SCYTHE_DMG * (1.0 + GameData.U_SCYTHE_SOUL_DMG * souls)
	var reaped: = _burst(world, p, p.position, r, dmg, "shadow", "u_scythe", "basic", 4.0)
	if not reaped.is_empty():
		p.heal(p.max_hp * GameData.U_SCYTHE_HEAL * mini(reaped.size(), 10), world, false, "u_scythe")

	var had: = souls
	for e in reaped:
		souls += GameData.U_SCYTHE_BOSS_SOULS if (e.is_boss or e.def.get("mvp", false)) else 1
	souls = mini(souls, GameData.U_SCYTHE_SOULS)
	p.uniq["scy_souls"] = souls
	if souls >= GameData.U_SCYTHE_SOULS and had < GameData.U_SCYTHE_SOULS:
		Vfx.ring(world.fx_root, p.position, 1.6, Color(1.0, 0.2, 0.35), 0.5)
		_say(world, p, TranslationServer.translate("¡La luna se tiñe de sangre!"), "say_moon_ready", 3.0)
	else:
		_say(world, p, TranslationServer.translate("¡Guadaña de Baphomet!"), "say_scythe", 4.0)





static func _blood_moon(world: World, p: Player, souls: int) -> void :
	var dmg: = GameData.U_BASE * GameData.U_SCYTHE_DMG * (1.0 + GameData.U_SCYTHE_SOUL_DMG * souls) * GameData.U_SCYTHE_MOON_K
	var base_r: = GameData.U_SCYTHE_RADIUS * sqrt(p.area_mult)
	Vfx.column(world.fx_root, p.position, Color(0.95, 0.15, 0.3))
	world.spawn_fx("hell_in", p.position, 1.9, 1.0)
	world.play_sound("hammer_of_god", 0.0, -5.0)
	_say(world, p, TranslationServer.translate("¡Luna Sangrienta!"), "say_blood_moon", 1.0)
	var pid: = p.get_instance_id()
	for i in 3:
		world._own_timer(GameData.U_SCYTHE_MOON_GAP * i, func():
			var p2: = instance_from_id(pid) as Player
			if p2 == null or not world.running or p2.downed:
				return
			var r: = base_r * (1.0 + 0.35 * i)
			var at: = p2.position
			var col: = Color(0.95, 0.15, 0.3).lerp(Color(0.6, 0.15, 0.9), i / 2.0)
			Vfx.arc(world.fx_root, at, p2.facing.rotated(Vector3.UP, i * 2.1), r, TAU, col)
			Vfx.burst(world.fx_root, at, r, Color(col, 0.8))
			Vfx.ring(world.fx_root, at, r * 1.15, col.lightened(0.35), 0.55)
			world.spawn_fx("brandish", at, 1.5 + 0.3 * i, 1.0)
			world.play_sound("brandish", 0.15, -3.0)
			world.shake(0.3 + 0.1 * i)
			var keep: = [world.damage_tag, world.damage_by]
			var reaped: = _burst(world, p2, at, r, dmg, "shadow", "u_scythe", "basic", 5.0)
			_restore(world, keep)
			if not reaped.is_empty():
				p2.heal(p2.max_hp * GameData.U_SCYTHE_HEAL * mini(reaped.size(), 10), world, false, "u_scythe"))





static func _quake(world: World, p: Player) -> void :
	var rage: = int(p.uniq.get("rage", 0)) + 1
	if rage >= GameData.U_QUAKE_RAGE:
		p.uniq["rage"] = 0
		_great_quake(world, p)
		return
	p.uniq["rage"] = rage



	var show: = world.clock >= float(p.uniq.get("quake_fx_at", -99.0))
	if show:
		p.uniq["quake_fx_at"] = world.clock + GameData.U_QUAKE_FX_GAP
	_fissures(world, p, GameData.U_QUAKE_FISSURES, GameData.U_QUAKE_FISSURE_LEN * sqrt(p.area_mult), false, show)
	var r: = GameData.U_QUAKE_RADIUS * sqrt(p.area_mult)
	if show:


		Vfx.quake(world.fx_root, p.position, r, GameData.U_QUAKE_COLOR)
		world.spawn_fx("shockwave", p.position, 1.3, 1.0)
		world.spawn_fx("earthhit", p.position, 1.4, 0.9)
		if not Vfx._skip(1):
			for i in 3:
				var at: = p.position + Vector3.FORWARD.rotated(Vector3.UP, TAU * (i + randf() * 0.6) / 3.0) * r * randf_range(0.45, 0.85)
				world.spawn_fx("earthhit", at, 0.8, 0.7)
		world.play_sound("earth_quake", 0.1, 0.0)
		world.play_sound("hammer_fall", 0.2, -6.0)
		world.shake(0.5)
	else:
		Vfx.ring(world.fx_root, p.position, r, Color(0.75, 0.5, 0.25), 0.35)
	for e in _burst(world, p, p.position, r, GameData.U_BASE * GameData.U_QUAKE_DMG, "earth", "u_quake", "basic", 2.0):
		if randf() < GameData.U_QUAKE_STUN:
			world.apply_status(e, "stun", 1.2)
	_say(world, p, TranslationServer.translate("¡Terremoto!"), "say_quake", 4.0)





static func _great_quake(world: World, p: Player) -> void :
	var r: = GameData.U_QUAKE_RADIUS * GameData.U_QUAKE_GREAT_R * sqrt(p.area_mult)
	p.uniq["quake_fx_at"] = world.clock + GameData.U_QUAKE_FX_GAP
	Vfx.quake(world.fx_root, p.position, r, GameData.U_QUAKE_LAVA_COLOR)
	Vfx.column(world.fx_root, p.position, Color(1.0, 0.45, 0.1))
	Vfx.burst(world.fx_root, p.position, r, Color(0.85, 0.35, 0.1))
	Vfx.ring(world.fx_root, p.position, r * 1.1, Color(1.0, 0.7, 0.3), 0.7)
	world.spawn_fx("shockwave", p.position, 2.0, 1.0)
	world.spawn_fx("firepillar", p.position, 1.4, 0.9)
	for i in 8:
		var at: = p.position + Vector3.FORWARD.rotated(Vector3.UP, TAU * (i + randf() * 0.6) / 8.0) * r * randf_range(0.4, 0.9)
		world.spawn_fx("earthhit", at, 1.0, 0.8)
	world.play_sound("earth_quake", 0.0, 2.0)
	world.play_sound("hammer_fall", 0.1, -3.0)
	world.shake(0.85)
	for e in _burst(world, p, p.position, r, GameData.U_BASE * GameData.U_QUAKE_DMG * GameData.U_QUAKE_GREAT_K, "earth", "u_quake", "basic", 4.0):
		if not e.dead:
			world.apply_status(e, "stun", GameData.U_QUAKE_GREAT_STUN)
	_fissures(world, p, GameData.U_QUAKE_GREAT_FISSURES, GameData.U_QUAKE_FISSURE_LEN * GameData.U_QUAKE_GREAT_R * sqrt(p.area_mult), true, true)
	_say(world, p, TranslationServer.translate("¡Gran Terremoto del Orc Lord!"), "say_great_quake", 1.0)






static func _fissures(world: World, p: Player, count: int, length: float, lava: bool, show: = true) -> void :
	var origin: = p.position
	var turn: = randf() * TAU
	var pid: = p.get_instance_id()
	var steps: = 7
	var dmg: = GameData.U_BASE * GameData.U_QUAKE_FISSURE_DMG * (GameData.U_QUAKE_GREAT_K * 0.5 if lava else 1.0)
	var col: = Color(1.0, 0.4, 0.05) if lava else Color(0.75, 0.5, 0.25)
	for f in count:
		var dir: = Vector3.FORWARD.rotated(Vector3.UP, turn + TAU * f / count + randf_range(-0.2, 0.2))
		var struck: = {}
		for s in steps:
			world._own_timer(0.05 * (s + 1), func():
				var p2: = instance_from_id(pid) as Player
				if p2 == null or not world.running:
					return
				var at: = origin + dir * length * (s + 1) / steps
				at.y = world.map.height_at(at)
				if show and s % 2 == 1:
					world.spawn_fx("earthhit", at, 0.75 + (0.1 if lava else 0.0), 0.75)
					if lava:
						world.spawn_fx("firehit1", at, 0.7, 0.75)
				if show and s == steps - 1:
					Vfx.ring(world.fx_root, at + Vector3(0, 0.05, 0), 1.1, col, 0.35)
				var keep: = [world.damage_tag, world.damage_by]
				world.damage_tag = "u_quake"
				world.damage_by = p2
				for e in world.enemies_in_radius(at, GameData.U_QUAKE_FISSURE_W):
					if e.dead or struck.has(e.get_instance_id()):
						continue
					struck[e.get_instance_id()] = true
					world.damage_enemy(e, dmg, Vector3.ZERO, "basic", "fire" if lava else "earth", "u_quake")
					if lava and not e.dead:
						world.dots.burn_on(world, e, GameData.U_BASE * GameData.U_QUAKE_LAVA_BURN * GameData.BURN_ONCE, "u_quake", p2)
				_restore(world, keep))


static func _rail(world: World, p: Player, target: Enemy, share: float) -> void :
	var dir: = ((target.position - p.position) * Vector3(1, 0, 1))
	if dir.length_squared() < 0.0001:
		return
	dir = dir.normalized()
	var length: = GameData.U_RAIL_LENGTH
	var width: = GameData.U_RAIL_WIDTH
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_rail"
	world.damage_by = p


	var dmg: = p.basic_atk() * p.arrow_bonus() * share
	var struck: = 0
	for e in world.enemies_in_radius(p.position + dir * length * 0.5, length * 0.5 + width):
		if e.dead:
			continue
		var to: Vector3 = (e.position - p.position) * Vector3(1, 0, 1)
		var along: = to.dot(dir)
		if along < 0.0 or along > length:
			continue
		if (to - dir * along).length() <= width + e.radius:
			world.damage_enemy(e, dmg, dir * 1.5, "basic", p.basic_element(), "u_rail")
			if struck < GameData.U_RAIL_SPARKS:
				struck += 1
				Vfx.ring(world.fx_root, e.position + Vector3(0, 0.9, 0), 0.8, Color(0.6, 0.95, 1.0), 0.2)
	_restore(world, keep)
	_beam(world, p, p.position + Vector3(0, 0.9, 0), dir, length)






static func _beam(world: World, p: Player, from: Vector3, dir: Vector3, length: float) -> void :
	var blue: = Color(0.3, 0.7, 1.0)
	_beam_part(world, from, dir, length, 0.9, Color(blue, 0.35), 0.38, 1.7)
	_beam_part(world, from, dir, length, 0.34, Color(0.55, 0.85, 1.0, 0.75), 0.28, 0.4)
	_beam_part(world, from, dir, length, 0.11, Color(1.0, 1.0, 1.0, 1.0), 0.2, 0.1)
	_helix(world, from, dir, length, Color(0.6, 0.9, 1.0, 0.9), 0.0)
	_helix(world, from, dir, length, Color(0.85, 0.6, 1.0, 0.8), PI)
	for i in 2:
		_shock_ring(world, from + dir * (0.7 + i * 1.1), dir, 0.32 + i * 0.12, Color(0.55, 0.85, 1.0, 0.6), 0.24 + i * 0.06)
	_scorch(world, Vector3(from.x, p.position.y + 0.05, from.z), dir, length)
	var end: = p.position + dir * length + Vector3(0, 0.1, 0)
	Vfx.burst(world.fx_root, p.position + dir * 0.7 + Vector3(0, 0.1, 0), 1.1, Color(0.7, 0.95, 1.0))
	Vfx.burst(world.fx_root, end, 1.2, blue)
	Vfx.ring(world.fx_root, end, 1.6, Color(0.5, 0.85, 1.0), 0.3)
	if world.clock >= float(p.uniq.get("rail_snd", 0.0)):
		p.uniq["rail_snd"] = world.clock + GameData.U_RAIL_SOUND_CD
		world.play_sound("lightning_crash", 0.1, -13.0, 1.5)


static func _beam_part(world: World, from: Vector3, dir: Vector3, length: float, width: float, color: Color, 
		life: = 0.2, grow: = 0.1) -> void :
	var m: = MeshInstance3D.new()
	var box: = BoxMesh.new()
	box.size = Vector3(width, width, length)
	m.mesh = box
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.no_depth_test = true
	mat.albedo_color = color
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	m.global_position = from + dir * length * 0.5
	m.look_at(m.global_position + dir, Vector3.UP)
	var tw: = m.create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, life)
	tw.parallel().tween_property(m, "scale", Vector3(grow, grow, 1.0), life).set_ease(Tween.EASE_IN)
	tw.tween_callback(m.queue_free)




static func _helix(world: World, from: Vector3, dir: Vector3, length: float, color: Color, phase: float, radius: = 0.32) -> void :

	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var n: = int(length * 6.0)
	for i in n + 1:
		var t: = float(i) / n
		var a: = phase + t * length * 4.5
		var radial: = Vector3(cos(a), sin(a), 0.0)
		var c: = Vector3(0, 0, - length * t)

		var w: = 0.09 * sin(t * PI) + 0.02
		st.add_vertex(c + radial * (radius - w))
		st.add_vertex(c + radial * (radius + w))
	var m: = MeshInstance3D.new()
	m.mesh = st.commit()
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.albedo_color = Color(color, color.a * Vfx.dim)
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	m.global_position = from
	m.look_at(from + dir, Vector3.UP)
	var tw: = m.create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.42)

	tw.parallel().tween_property(m, "scale", Vector3(2.0, 2.0, 1.0), 0.42).set_ease(Tween.EASE_OUT)
	tw.tween_callback(m.queue_free)



static func _shock_ring(world: World, pos: Vector3, dir: Vector3, radius: float, color: Color, life: float) -> void :
	var s: = Sprite3D.new()
	s.texture = Vfx.ring_texture()
	s.pixel_size = radius * 2.0 / float(s.texture.get_width())
	s.shaded = false
	s.no_depth_test = true
	s.double_sided = true
	s.modulate = Color(color, color.a * Vfx.dim)
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	world.fx_root.add_child(s)
	s.global_position = pos

	s.look_at(pos + dir, Vector3.UP)
	var tw: = s.create_tween()
	tw.tween_property(s, "scale", Vector3.ONE * 1.8, life).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(s, "modulate:a", 0.0, life)
	tw.tween_callback(s.queue_free)



static func _sparks(world: World, from: Vector3, dir: Vector3, length: float, color: Color) -> void :
	var cp: = CPUParticles3D.new()
	cp.emitting = false
	cp.one_shot = true
	cp.explosiveness = 0.9
	cp.amount = 18
	cp.lifetime = 0.35
	cp.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	cp.emission_box_extents = Vector3(0.1, 0.1, length * 0.5)
	cp.direction = Vector3(0, 1, 0)
	cp.spread = 180.0
	cp.initial_velocity_min = 2.0
	cp.initial_velocity_max = 5.0
	cp.gravity = Vector3(0, -6.0, 0)
	cp.scale_amount_min = 0.035
	cp.scale_amount_max = 0.07
	var quad: = QuadMesh.new()
	quad.size = Vector2(1, 1)
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.vertex_color_use_as_albedo = true
	mat.no_depth_test = true
	mat.albedo_texture = Vfx.disc_texture()
	quad.material = mat
	cp.mesh = quad
	var g: = Gradient.new()
	g.set_color(0, Color(1, 1, 1, Vfx.dim))
	g.set_color(1, Color(color, 0.0))
	cp.color_ramp = g
	world.fx_root.add_child(cp)
	cp.global_position = from + dir * length * 0.5
	cp.look_at(cp.global_position + dir, Vector3.UP)
	cp.emitting = true
	cp.finished.connect(cp.queue_free)



static func _scorch(world: World, from: Vector3, dir: Vector3, length: float) -> void :
	var m: = MeshInstance3D.new()
	var plane: = PlaneMesh.new()
	plane.size = Vector2(0.5, length)
	m.mesh = plane
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_texture = Vfx.soft_cell_texture()
	mat.albedo_color = Color(0.35, 0.7, 1.0, 0.5 * Vfx.dim)
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	m.global_position = from + dir * length * 0.5
	m.look_at(m.global_position + dir, Vector3.UP)
	var tw: = m.create_tween()
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.5)
	tw.tween_callback(m.queue_free)





static func on_kill(world: World, p: Player, e: Enemy) -> void :

	if p.effects.has("u_gloom"):
		_night_kill(world, p, e)

	if p.effects.has("u_reaper"):
		var had: = int(p.uniq.get("souls", 0))
		p.uniq["souls"] = mini(int(p.effects.u_reaper), had + 1)
		if had < int(p.effects.u_reaper) and int(p.uniq.souls) >= int(p.effects.u_reaper):
			_say(world, p, TranslationServer.translate("¡10 almas!"), "say_souls", 4.0)
			world.play_sound("lex_aeterna", 0.2, -6.0)
	if not p.effects.has("u_bone") or e.is_boss or randf() >= float(p.effects.u_bone):
		return
	if world.summons.count("u_bone", p) >= GameData.U_BONE_MAX:
		return


	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_bone"
	world.damage_by = p
	world.summons.plant(world, p, BONE_SK, 1, 1, GameData.U_BASE * GameData.U_BONE_DMG, 2.0, GameData.U_BONE_TIME, e.position)
	_restore(world, keep)
	Vfx.column(world.fx_root, e.position, Color(0.6, 0.45, 0.85))
	world.play_sound("stone_curse", 0.4, -10.0)




static func hurt(world: World, p: Player, amount: float, from: Enemy, pierce: bool) -> float:
	var fx: = p.effects

	if fx.has("u_aegis") and world.clock >= float(p.uniq.get("aegis_cd", 0.0)) and randf() < float(fx.u_aegis):
		p.uniq["aegis_cd"] = world.clock + GameData.U_AEGIS_CD
		_aegis(world, p)
		return 0.0
	if fx.has("u_turtle"):
		amount *= 1.0 - float(fx.u_turtle)

	if fx.has("u_tiger") and p.powers.has("tiger_rush") and int(p.uniq.get("tiger_n", 0)) >= GameData.U_TIGER_FURY_MAX:
		amount *= 1.0 - GameData.U_TIGER_ENDURE
	if fx.has("u_goldbug") and (from == null or pierce):
		var kept: = amount * float(fx.u_goldbug)
		amount -= kept
		if world.clock >= float(p.uniq.get("goldbug_cd", 0.0)):
			p.uniq["goldbug_cd"] = world.clock + GameData.U_GOLDBUG_CD
			var gold: = GameData.U_GOLDBUG_RADIUS * sqrt(p.area_mult)
			Vfx.burst(world.fx_root, p.position, gold, Color(1.0, 0.82, 0.3))
			Vfx.ring(world.fx_root, p.position, gold * 1.3, Color(1.0, 0.95, 0.6), 0.45)
			_burst(world, p, p.position, gold, GameData.U_BASE * GameData.U_GOLDBUG_WAVE, "neutral", "u_goldbug", "skill", 5.0)

		var sent: = p.hit_bank("goldbug", kept)
		var back: = world.nearest_enemy(p.position, 9.0) if sent > 0.0 else null
		if back != null:
			world.damage_tag = "u_goldbug"
			world.damage_by = p
			world.damage_enemy(back, sent * GameData.U_GOLDBUG_REFLECT / maxf(0.01, p.dmg_mult * p.skill_mult), Vector3.ZERO, 
				"skill", "neutral", "u_goldbug")
		world.sprite_fx("fx_shield", p.position + Vector3(0, 1.1, 0), 0, 0.8)
		_say(world, p, TranslationServer.translate("¡Reflejo dorado!"), "say_goldbug", 3.0)
	return amount



static func _aegis(world: World, p: Player) -> void :
	var r: = GameData.U_AEGIS_RADIUS * sqrt(p.area_mult)
	world.sprite_fx("fx_shield", p.position + Vector3(0, 1.1, 0), 0, 0.9)
	world.spawn_fx("holyhit", p.position + Vector3(0, 0.6, 0), 1.8, 1.0)
	Vfx.column(world.fx_root, p.position, Color(1.0, 0.92, 0.6))
	for i in 6:
		var a: = TAU * i / 6.0
		Vfx.column(world.fx_root, p.position + Vector3(cos(a), 0, sin(a)) * r * 0.7, Color(1.0, 0.92, 0.6))
	Vfx.ring(world.fx_root, p.position, r, Color(1.0, 0.9, 0.55), 0.4)
	world.play_sound("magnus", 0.3, -8.0)
	_burst(world, p, p.position, r, GameData.U_BASE * GameData.U_AEGIS_DMG, "holy", "u_aegis", "skill", 4.0)
	_say(world, p, TranslationServer.translate("¡Égida de Reginleif!"), "say_aegis", 3.0)





static func _blood_pool(world: World, p: Player, at: Vector3) -> void :
	var sr: = GameData.U_SPEAR_RADIUS * sqrt(p.area_mult)
	world.spawn_fx("lord", at, 1.2, 0.9)
	Vfx.column(world.fx_root, at, Color(0.75, 0.05, 0.12))
	Vfx.ring(world.fx_root, at, sr, Color(0.8, 0.1, 0.15), 0.35)
	world.play_sound("brandish", 0.2, -8.0)
	_burst(world, p, at, sr, GameData.U_BASE * GameData.U_SPEAR_DMG, "shadow", "u_blood", "skill", 3.0)
	var r: = GameData.U_BLOOD_RADIUS * sqrt(p.area_mult)
	var pool: = Vfx.ground_glow(world.fx_root, at + Vector3(0, 0.04, 0), r * 1.2, Color(0.55, 0.0, 0.05, 0.85))
	world.spawn_fx("hell_in", at, 0.7, 0.6)
	var tw: = pool.create_tween()
	tw.tween_interval(0.5 * GameData.U_BLOOD_TICKS)
	tw.tween_property(pool, "modulate:a", 0.0, 0.35)
	tw.tween_callback(pool.queue_free)
	for i in GameData.U_BLOOD_TICKS:
		world.get_tree().create_timer(0.5 * (i + 1), false).timeout.connect( func():
			if not is_instance_valid(p) or not world.running:
				return
			var hit: = _burst(world, p, at, r, GameData.U_BASE * GameData.U_BLOOD_DMG, "shadow", "u_blood", "skill", 0.0)
			if not hit.is_empty() and not p.downed and p.hp > 0.0:
				p.hp = minf(p.max_hp, p.hp + p.max_hp * minf(GameData.U_BLOOD_HEAL_MAX, GameData.U_BLOOD_HEAL * hit.size())))






static func after_hurt(world: World, p: Player) -> void :
	if not p.effects.has("u_tiger") or world.clock < float(p.uniq.get("tiger_cd", 0.0)):
		return
	p.uniq["tiger_cd"] = world.clock + GameData.U_TIGER_CD

	var had: = int(p.uniq.get("tiger_n", 0)) if p.powers.has("tiger_rush") else 0
	var n: = mini(GameData.U_TIGER_FURY_MAX, had + 1)
	p.uniq["tiger_n"] = n
	var gained: = int(p.uniq.get("tiger_gain", 0)) + 1 if had > 0 else 1
	p.uniq["tiger_gain"] = gained
	p.add_power("tiger_rush", GameData.U_TIGER_FURY_TIME)
	if gained % GameData.U_TIGER_ROAR_EVERY == 0:
		_tiger_roar(world, p, n >= GameData.U_TIGER_FURY_MAX)
	if n >= GameData.U_TIGER_FURY_MAX and had < GameData.U_TIGER_FURY_MAX:
		Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.4, GameData.U_TIGER_COLOR, 0.5)
		_say(world, p, TranslationServer.translate("¡Endure del tigre!"), "say_tiger_full", 4.0)
	elif had == 0:
		_say(world, p, TranslationServer.translate("¡Furia del tigre!"), "say_tiger", 5.0)




static func _tiger_roar(world: World, p: Player, full: bool) -> void :
	var roar: = GameData.U_TIGER_ROAR_RADIUS * sqrt(p.area_mult)
	Vfx.burst(world.fx_root, p.position, roar, Color(1.0, 0.55, 0.15))
	Vfx.ring(world.fx_root, p.position, roar * 1.3, Color(1.0, 0.8, 0.3), 0.4)
	world.spawn_fx("shockwave", p.position, 1.2 if full else 1.0, 0.9)
	world.play_sound("hit_fist", 0.2, -2.0)
	world.shake(0.3 if full else 0.2)
	_burst(world, p, p.position, roar, GameData.U_BASE * GameData.U_TIGER_ROAR, "neutral", "u_tiger", "skill", 4.0)
	world.emote(p, "anger", 1.5)




static func tiger_mult(p: Player) -> float:
	if not p.effects.has("u_tiger") or not p.powers.has("tiger_rush"):
		return 1.0
	return 1.0 + GameData.U_TIGER_FURY_DMG * int(p.uniq.get("tiger_n", 0))




static func on_heal(world: World, p: Player, real: float) -> void :
	if not p.effects.has("u_bishop") or real <= 0.0 or world.clock < float(p.uniq.get("bishop_cd", 0.0)):
		return
	p.uniq["bishop_cd"] = world.clock + GameData.U_BISHOP_CD
	_holy(world, p, real)




static func _holy(world: World, p: Player, real: float) -> void :

	var r: = GameData.U_BISHOP_RADIUS * p.area_mult
	world.spawn_fx("holyhit", p.position + Vector3(0, 0.6, 0), 1.6, 0.9)
	Vfx.ring(world.fx_root, p.position, r, Color(1.0, 0.95, 0.6), 0.4)
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_bishop"
	world.damage_by = p



	real = minf(real, p.max_hp * GameData.U_BISHOP_HEAL_CAP)
	for e in world.enemies_in_radius(p.position, r):
		var base: = maxf(real * float(p.effects.u_bishop), GameData.U_BASE * GameData.U_BISHOP_MIN) * (1.35 if e.element() in ["undead", "shadow"] else 1.0)
		world.damage_enemy(e, base, ((e.position - p.position) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", "holy", "u_bishop")
	_restore(world, keep)






static func try_ankh(world: World, p: Player) -> bool:
	if not ankh_ready(p):
		return false
	p.uniq["ankh_wait"] = true
	p.uniq["ankh_count"] = int(p.uniq.get("ankh_count", 0)) + 1
	p.hp = p.max_hp
	p._invuln = GameData.U_ANKH_INVULN
	p.visual.play(RoVisual.PC_IDLE, true, true)

	if p == world.player:
		world.hud.announce(TranslationServer.translate("Ankh of Osiris"), GameData.UNIQUE_COLOR, TranslationServer.translate("¡Osiris te devuelve a la vida!"))
		world.hud.flash(Color(1.0, 0.9, 0.5), 0.6)
	else:
		world.label_over(p, TranslationServer.translate("Ankh of Osiris"), GameData.UNIQUE_COLOR)
	world.shake(0.6)
	world.play_sound("assumptio", 0.0, 0.0)
	world.spawn_fx("magnus", p.position, 1.6, 1.0)
	var r: = GameData.U_ANKH_RADIUS * sqrt(p.area_mult)
	Vfx.burst(world.fx_root, p.position, r, Color(1.0, 0.9, 0.5))
	Vfx.column(world.fx_root, p.position, GameData.U_ANKH_COLOR)
	_burst(world, p, p.position, r, GameData.U_BASE * GameData.U_ANKH_DMG, "holy", "u_ankh", "skill", 12.0)
	var pid: = p.get_instance_id()
	var ticks: = roundi(GameData.U_ANKH_INVULN / GameData.U_ANKH_AURA_EVERY)
	for i in ticks:
		world._own_timer(GameData.U_ANKH_AURA_EVERY * (i + 1), func():
			var p2: = instance_from_id(pid) as Player
			if p2 == null or not world.running or p2.downed or p2.hp <= 0.0:
				return
			_ankh_judgement(world, p2))
	world._own_timer(GameData.U_ANKH_RECHARGE, func():
		var p2: = instance_from_id(pid) as Player
		if p2 == null or not world.running:
			return
		p2.uniq["ankh_wait"] = false
		if p2.effects.has("u_ankh"):
			Vfx.ring(world.fx_root, p2.position + Vector3(0, 0.05, 0), 1.6, GameData.U_ANKH_COLOR, 0.6)
			world.play_sound("heal", 0.0, -8.0)
			_say(world, p2, TranslationServer.translate("¡El Ankh vuelve a brillar!")))
	return true



static func ankh_ready(p: Player) -> bool:
	return p.effects.has("u_ankh") and not p.uniq.get("ankh_wait", false)




static func _ankh_judgement(world: World, p: Player) -> void :
	var r: = GameData.U_ANKH_AURA_RADIUS * sqrt(p.area_mult)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), r, GameData.U_ANKH_COLOR, 0.35)
	if not Vfx._skip(1):
		world.spawn_fx("holyhit", p.position + Vector3(0, 0.6, 0), 1.0, 0.6)
	_burst(world, p, p.position, r, GameData.U_BASE * GameData.U_ANKH_AURA_DMG, "holy", "u_ankh", "skill", 1.5)




static func tick(world: World, p: Player, delta: float) -> void :
	var fx: = p.effects

	if fx.has("u_orc"):
		p.uniq["orc_t"] = float(p.uniq.get("orc_t", 0.0)) - delta
		if float(p.uniq.orc_t) <= 0.0:
			p.uniq.orc_t = 0.3
			var n: = world.enemies_in_radius(p.position, GameData.U_ORC_RADIUS).size()
			p.uniq["orc_mult"] = minf(GameData.U_ORC_MAX, n * float(fx.u_orc))
	else:
		p.uniq.erase("orc_mult")

	if fx.has("u_maya"):
		p.uniq["maya_t"] = float(p.uniq.get("maya_t", 1.0)) - delta
		if float(p.uniq.maya_t) <= 0.0:
			p.uniq.maya_t = GameData.U_MAYA_EVERY
			var prey: = world.nearest_enemy(p.position, 10.0)
			if world.summons.count("u_maya", p) < int(fx.u_maya) and prey != null:
				var sk: = MAYA_SK.duplicate()
				sk.plants = [ANTS.pick_random()]
				var at: = prey.position
				world.damage_tag = "u_maya"
				world.damage_by = p
				world.summons.plant(world, p, sk, 1, 1, GameData.U_BASE * GameData.U_MAYA_DMG, 2.2, GameData.U_MAYA_TIME, at)

				world.spawn_fx("earthhit", at, 1.0, 0.9)
				Vfx.ring(world.fx_root, at, GameData.U_MAYA_BURST_RADIUS, Color(0.8, 0.55, 0.3), 0.3)
				_burst(world, p, at, GameData.U_MAYA_BURST_RADIUS, GameData.U_BASE * GameData.U_MAYA_BURST, "earth", "u_maya", "skill", 3.0)
				if not p.uniq.get("maya_said", false):
					p.uniq["maya_said"] = true
					_say(world, p, TranslationServer.translate("¡La guardia de Maya!"))

	if fx.has("u_kraken"):
		p.uniq["kraken_t"] = float(p.uniq.get("kraken_t", 1.0)) - delta
		if float(p.uniq.kraken_t) <= 0.0:
			var keep: = world.damage_tag
			p.uniq.kraken_t = float(fx.u_kraken) if Skills.cast(world, p, "kraken_huuma", 5, "u_kraken") else 0.3
			world.damage_tag = keep


	if fx.has("u_bishop"):
		p.uniq["pray_t"] = float(p.uniq.get("pray_t", GameData.U_BISHOP_PRAYER)) - delta
		if float(p.uniq.pray_t) <= 0.0:
			p.uniq.pray_t = GameData.U_BISHOP_PRAYER
			var amount: = p.max_hp * GameData.U_BISHOP_PRAYER_HEAL
			p.uniq.erase("bishop_cd")

			p.heal(amount, world)
			world.play_sound("heal", 0.3, -10.0)




	if fx.has("u_clones"):
		p.uniq["clone_t"] = float(p.uniq.get("clone_t", 2.0)) - delta
		if float(p.uniq.clone_t) <= 0.0:
			p.uniq.clone_t = 0.5
			if world.nearest_enemy(p.position, 9.0) != null:
				var bag: Array = p.uniq.get("clone_bag", [])
				if bag.is_empty():
					bag = GameData.U_CLONE_SKILLS.duplicate()
					bag.shuffle()
				var keep: = [world.damage_tag, world.damage_by]
				for sid in bag.duplicate():

					if sid == "heal" and p.hp > p.max_hp * 0.8 and bag.size() > 1:
						continue



					var nothing_to_heal: bool = str(sid) == "heal" and bag.size() == 1
					if Skills.cast(world, p, str(sid), 5, "u_clones") or nothing_to_heal:
						p.uniq.clone_t = float(fx.u_clones)
						bag.erase(sid)
						var side: = Vector3( - p.facing.z, 0, p.facing.x) * (1.2 if randf() < 0.5 else -1.2)
						world._shadow_clone(p, p.position + side, GameData.U_CLONE_COLORS.get(sid, Color(0.95, 0.55, 0.35)))
						_say(world, p, TranslationServer.translate("¡%s!") % str(GameData.U_CLONE_NAMES[sid]), "say_clone", 0.5)
						var pid: = p.get_instance_id()
						var again: = str(sid)
						world._own_timer(GameData.U_CLONE_AGAIN, func():
							var p2: = instance_from_id(pid) as Player
							if p2 != null and world.running and not p2.downed:
								var k: = [world.damage_tag, world.damage_by]
								Skills.cast(world, p2, again, 5, "u_clones")
								_restore(world, k))
						break
				p.uniq["clone_bag"] = bag
				if bag.is_empty():
					_final_experiment(world, p)
				_restore(world, keep)


	if fx.has("u_reaper") and world.clock >= float(p.uniq.get("reaper_cd", 0.0)) and world.nearest_enemy(p.position, 6.0) != null:
		on_kick(world, p)

	if fx.has("u_gift"):
		p.uniq["gift_t"] = float(p.uniq.get("gift_t", GameData.U_GIFT_EVERY)) - delta
		if float(p.uniq.gift_t) <= 0.0:
			p.uniq.gift_t = GameData.U_GIFT_EVERY
			if world.nearest_enemy(p.position, 9.0) != null:
				_gifts(world, p)
	_tick_flies(world, p, delta)
	_tick_souls(world, p)
	_draw_orbs(world.run_root, p.uniq, "orb_nodes", orb_sets(p), p.position, Vfx.dim)
	_tick_volcano(world, p, delta)
	_tick_night(world, p, delta)
	_tick_overload(world, p, delta)
	_tick_sonic(world, p)
	_tick_queen(world, p, delta)




static func _final_experiment(world: World, p: Player) -> void :
	var r: = 2.4
	Vfx.ring(world.fx_root, p.position, r, Color(0.35, 1.0, 0.8), 0.7)
	Vfx.ring(world.fx_root, p.position, r * 1.8, Color(0.6, 1.0, 0.9), 0.5)
	Vfx.column(world.fx_root, p.position, Color(0.4, 1.0, 0.85))
	world.play_sound("magnus", 0.0, -4.0)
	world.shake(0.4)
	_say(world, p, TranslationServer.translate("¡Experimento Final!"), "say_final_exp", 1.0)
	var keep: = [world.damage_tag, world.damage_by]
	var skills: Array = GameData.U_CLONE_SKILLS
	for i in skills.size():
		var sid: = str(skills[i])
		var at: = p.position + Vector3.FORWARD.rotated(Vector3.UP, TAU * i / skills.size()) * r
		world._shadow_clone(p, at, GameData.U_CLONE_COLORS.get(sid, Color(0.4, 1.0, 0.85)))
		Skills.cast(world, p, sid, 5, "u_clones")
	_restore(world, keep)





static func orb_sets(p: Player) -> Array:
	var out: = []
	if p.effects.has("u_scythe"):
		var n: = int(p.uniq.get("scy_souls", 0))
		var full: = n >= GameData.U_SCYTHE_SOULS
		out.append([n, Color(1.0, 0.18, 0.32) if full else Color(0.62, 0.28, 1.0), 1.25, 1.05, -0.0045 if full else -0.0018])
	if p.effects.has("u_quake"):
		out.append([int(p.uniq.get("rage", 0)), Color(1.0, 0.5, 0.15), 0.85, 0.3, 0.0024])


	if p.effects.has("u_tiger") and p.powers.has("tiger_rush"):
		out.append([int(p.uniq.get("tiger_n", 0)), GameData.U_TIGER_COLOR, 0.75, 0.55, 0.0038])
	if p.effects.has("u_ankh") and ankh_ready(p):
		out.append([1, GameData.U_ANKH_COLOR, 0.0, 2.35, 0.0])
	if p.effects.has("u_clones"):
		var bag: Array = p.uniq.get("clone_bag", [])
		var come: = 0 if bag.is_empty() else GameData.U_CLONE_SKILLS.size() - bag.size()
		out.append([come, Color(0.35, 1.0, 0.8), 1.0, 1.6, 0.003])
	return out





static func _draw_orbs(parent: Node, store: Dictionary, key: String, sets: Array, origin: Vector3, alpha: float) -> void :
	var nodes: Array = store.get(key, [])
	var want: = 0
	for st in sets:
		want += mini(int(st[0]), 30)
	while nodes.size() > want:
		var n = nodes.pop_back()
		if is_instance_valid(n):
			n.queue_free()
	while nodes.size() < want:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = GameData.HERO_FX_PRIORITY
		s.pixel_size = 0.6 / 32.0
		parent.add_child(s)
		nodes.append(s)
	if want <= 0:
		store.erase(key)
		return
	store[key] = nodes
	var t: = float(Time.get_ticks_msec())
	var i: = 0
	for st in sets:
		var n: = mini(int(st[0]), 30)
		for k in n:
			var a: = t * float(st[4]) + TAU * k / n
			var node: Sprite3D = nodes[i]
			i += 1
			node.modulate = Color((st[1] as Color).lightened(0.15), 0.95 * alpha)
			node.position = origin + Vector3(cos(a) * float(st[2]), float(st[3]) + sin(a * 3.0 + t * 0.002) * 0.12, sin(a) * float(st[2]))



static func _tick_souls(world: World, p: Player) -> void :
	var nodes: Array = p.uniq.get("soul_nodes", [])
	var want: = int(p.uniq.get("souls", 0)) if p.effects.has("u_reaper") else 0
	while nodes.size() > want:
		var n = nodes.pop_back()
		if is_instance_valid(n):
			n.queue_free()
	while nodes.size() < want:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = GameData.HERO_FX_PRIORITY
		s.modulate = Color(0.75, 0.55, 1.0, 0.85)
		s.pixel_size = 0.45 / 32.0
		world.run_root.add_child(s)
		nodes.append(s)
	if want <= 0:
		p.uniq.erase("soul_nodes")
		return
	p.uniq["soul_nodes"] = nodes
	var t: = Time.get_ticks_msec() * 0.0016
	for i in nodes.size():
		var a: = - t + TAU * i / nodes.size()
		nodes[i].position = p.position + Vector3(cos(a) * 1.15, 1.4 + sin(a * 3.0 + t) * 0.25, sin(a) * 1.15)




static func on_kick(world: World, p: Player) -> void :
	if not p.effects.has("u_reaper") or int(p.uniq.get("souls", 0)) < int(p.effects.u_reaper):
		return
	p.uniq["souls"] = 0
	p.uniq["reaper_cd"] = world.clock + GameData.U_REAPER_CD
	var r: = GameData.U_REAPER_RADIUS * sqrt(p.area_mult)
	world.spawn_fx("hell_in", p.position, 1.8, 1.0)
	Vfx.burst(world.fx_root, p.position, r, Color(0.55, 0.3, 0.8))
	Vfx.ring(world.fx_root, p.position, r * 1.2, Color(0.85, 0.7, 1.0), 0.5)
	Vfx.column(world.fx_root, p.position, Color(0.6, 0.4, 0.9))
	world.play_sound("hammer_of_god", 0.0, -4.0)
	world.shake(0.5)
	var keep: = [world.damage_tag, world.damage_by]
	_burst(world, p, p.position, r, GameData.U_BASE * GameData.U_REAPER_DMG, "shadow", "u_reaper", "skill", 6.0)
	_restore(world, keep)
	_say(world, p, TranslationServer.translate("¡Juicio de Thanatos!"), "say_judge", 1.0)




static func after_cast(world: World, p: Player, id: String) -> void :
	if p.effects.has("u_volcano"):
		_heat(world, p)
	if p.effects.has("u_excalibur"):
		excal_cast(world, p)
	if not p.effects.has("u_gift") or not Player.is_support(id):
		return
	if world.clock < float(p.uniq.get("gift_cd", 0.0)):
		return
	p.uniq["gift_cd"] = world.clock + GameData.U_GIFT_CD
	_gifts(world, p)


static func _gifts(world: World, p: Player) -> void :
	var foes: = world.enemies_in_radius(p.position, 9.0).filter( func(e): return not e.dead)
	foes.sort_custom( func(a, b): return p.position.distance_squared_to(a.position) < p.position.distance_squared_to(b.position))
	for i in int(p.effects.u_gift):
		var at: Vector3 = foes[i % foes.size()].position if not foes.is_empty()\
		else p.position + Vector3(cos(TAU * i / 3.0), 0, sin(TAU * i / 3.0)) * 3.0
		_gift(world, p, at, i * 0.08)
	world.play_sound("drop_yellow", 0.1, -8.0)


static func _gift(world: World, p: Player, at: Vector3, delay: float) -> void :
	var spr: = RoAssets.sprite(["gift_box"])
	var box: = Sprite3D.new()
	box.texture = spr.get_frame(0, 0) if spr != null else RoAssets.radial(Color(1, 0.3, 0.3), 16)
	box.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	box.shaded = false
	box.no_depth_test = true
	box.render_priority = 6
	box.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	box.pixel_size = GameData.PIXEL_SIZE * 1.1
	world.fx_root.add_child(box)
	var from: = p.position + Vector3(0, 1.4, 0)
	box.global_position = from
	box.visible = delay <= 0.0
	var tw: = box.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
		tw.tween_callback( func(): box.visible = true)

	tw.tween_method( func(k: float):
		box.global_position = from.lerp(at + Vector3(0, 0.4, 0), k) + Vector3(0, sin(k * PI) * 2.2, 0)
		box.rotation.z = k * TAU, 0.0, 1.0, 0.45)
	tw.tween_callback( func():
		box.queue_free()
		if not world.running or not is_instance_valid(p):
			return
		var r: = GameData.U_GIFT_RADIUS * sqrt(p.area_mult)
		Vfx.burst(world.fx_root, at, r, Color(1.0, 0.35, 0.35))
		Vfx.ring(world.fx_root, at, r * 1.2, Color(0.45, 1.0, 0.5), 0.4)
		world.spawn_fx("holyhit", at, 0.9, 0.8)
		var keep: = [world.damage_tag, world.damage_by]
		_burst(world, p, at, r, GameData.U_BASE * GameData.U_GIFT_DMG * p.support_mult, "holy", "u_gift", "skill", 2.0)
		_restore(world, keep)
		p.heal(p.max_hp * GameData.U_GIFT_HEAL * p.support_mult, world, false, "u_gift"))








static func _heat(world: World, p: Player) -> void :
	if world.clock < float(p.uniq.get("heat_gap", 0.0)):
		return
	var fury: = world.clock < float(p.uniq.get("volcano_until", 0.0))
	p.uniq["heat_gap"] = world.clock + GameData.U_VOLCANO_GAP * (GameData.U_VOLCANO_FURY_HEAT if fury else 1.0)
	p.uniq["heat"] = int(p.uniq.get("heat", 0)) + 1
	if int(p.uniq.heat) >= int(p.effects.u_volcano):
		p.uniq["heat"] = 0
		_eruption(world, p)




static func _eruption(world: World, p: Player) -> void :
	var r: = GameData.U_VOLCANO_RADIUS * sqrt(p.area_mult)
	var at: = p.position


	if world.clock >= float(p.uniq.get("volcano_until", 0.0)):
		p.uniq["volcano_until"] = world.clock + GameData.U_VOLCANO_FURY_TIME
	world.spawn_fx("firepillar", at, 1.9, 1.0)
	world.spawn_fx("meteor1", at, 1.3, 0.9)
	Vfx.column(world.fx_root, at, Color(1.0, 0.45, 0.1))
	Vfx.burst(world.fx_root, at, r, Color(1.0, 0.4, 0.08))
	Vfx.ring(world.fx_root, at, r * 1.25, Color(1.0, 0.75, 0.3), 0.55)
	Vfx.quake(world.fx_root, at, r * 0.85, Color(1.0, 0.45, 0.08))
	for i in 6:
		var a: = TAU * (i + randf() * 0.5) / 6.0
		world.spawn_fx("firehit1", at + Vector3(cos(a), 0, sin(a)) * r * randf_range(0.4, 0.85), 0.9, 0.8)
	world.play_sound("meteor", 0.2, -4.0)
	world.play_sound("fire_pillar", 0.2, -6.0)
	world.shake(0.55)
	var keep: = [world.damage_tag, world.damage_by]
	for e in _burst(world, p, at, r, GameData.U_BASE * GameData.U_VOLCANO_DMG, "fire", "u_volcano", "skill", 5.0):
		if not e.dead:
			world.dots.burn_on(world, e, GameData.U_BASE * GameData.U_VOLCANO_BURN * GameData.BURN_ONCE, "u_volcano", p)
	_restore(world, keep)
	_say(world, p, TranslationServer.translate("¡Erupción de Ifrit!"), "say_volcano", 1.0)


	var pid: = p.get_instance_id()
	for i in GameData.U_VOLCANO_TICKS:
		world.get_tree().create_timer(0.5 * (i + 1), false).timeout.connect( func():
			var p2: = instance_from_id(pid) as Player
			if p2 == null or not world.running:
				return
			var lr: = GameData.U_VOLCANO_LAVA * sqrt(p2.area_mult)
			Vfx.ring(world.fx_root, at, lr, Color(1.0, 0.35, 0.05), 0.5)
			if world._bounce_fx_ok(1, "volcano"):
				var a: = randf() * TAU
				world.spawn_fx("firehit1", at + Vector3(cos(a), 0, sin(a)) * lr * randf() * 0.8, 0.6, 0.6)
			var k: = [world.damage_tag, world.damage_by]
			_burst(world, p2, at, lr, GameData.U_BASE * GameData.U_VOLCANO_LAVA_DMG, "fire", "u_volcano", "skill", 0.0)
			_restore(world, k))




static func _tick_volcano(world: World, p: Player, delta: float) -> void :
	if not p.effects.has("u_volcano"):
		_embers(world, p, 0)
		return
	var fury: = world.clock < float(p.uniq.get("volcano_until", 0.0))
	if fury:
		p.cut_cooldowns(delta * GameData.U_VOLCANO_HASTE)
		p.uniq["fury_t"] = float(p.uniq.get("fury_t", 0.0)) - delta
		if float(p.uniq.fury_t) <= 0.0:
			p.uniq.fury_t = 0.45
			Vfx.ring(world.fx_root, p.position, 1.4, Color(1.0, 0.5, 0.12), 0.4)
			if world._bounce_fx_ok(1, "volcano"):
				world.spawn_fx("firehit1", p.position + Vector3(0, 0.3, 0), 0.45, 0.5)
	_embers(world, p, int(p.effects.u_volcano) if fury else int(p.uniq.get("heat", 0)), fury)


static func _embers(world: World, p: Player, want: int, fury: = false) -> void :
	var nodes: Array = p.uniq.get("ember_nodes", [])
	while nodes.size() > want:
		var n = nodes.pop_back()
		if is_instance_valid(n):
			n.queue_free()
	while nodes.size() < want:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = GameData.HERO_FX_PRIORITY
		s.pixel_size = 0.38 / 32.0
		world.run_root.add_child(s)
		nodes.append(s)
	if want <= 0:
		p.uniq.erase("ember_nodes")
		return
	p.uniq["ember_nodes"] = nodes
	var t: = Time.get_ticks_msec() * (0.0035 if fury else 0.0021)
	for i in nodes.size():
		var a: = t + TAU * i / nodes.size()
		nodes[i].modulate = Color(1.0, 0.75, 0.25, 0.95) if fury else Color(1.0, 0.45, 0.12, 0.85)
		nodes[i].position = p.position + Vector3(cos(a) * 1.0, 0.5 + 0.12 * (i % 3) + sin(a * 2.0 + t) * 0.15, sin(a) * 1.0)





static func net_look(world: World, p: Player) -> Array:
	var orbs: = []
	for st in orb_sets(p):
		orbs.append([int(st[0]), (st[1] as Color).to_html(), float(st[2]), float(st[3]), float(st[4])])
	if not p.effects.has("u_volcano") and not p.effects.has("u_gloom") and orbs.is_empty() and not p.effects.has("u_queen")\
	and not p.effects.has("u_flies"):
		return []
	var fury: = p.effects.has("u_volcano") and world.clock < float(p.uniq.get("volcano_until", 0.0))
	var heat: = 0
	if p.effects.has("u_volcano"):
		heat = int(p.effects.u_volcano) if fury else int(p.uniq.get("heat", 0))
	var night: = 0.0
	if p.effects.has("u_gloom") and world.clock < float(p.uniq.get("night_until", 0.0)):
		night = snappedf(GameData.U_GLOOM_RADIUS * sqrt(p.area_mult), 0.1)


	return [heat, fury, night, orbs, queen_state(p), (p.uniq.get("flies", []) as Array).size()]




static func draw_puppet(p: Player) -> void :
	var u: Array = p.uniq.get("net_u", [])
	var want: = int(u[0]) if u.size() > 2 else 0
	var fury: = u.size() > 2 and bool(u[1])
	var night: = float(u[2]) if u.size() > 2 else 0.0
	var nodes: Array = p.uniq.get("net_embers", [])
	while nodes.size() > want:
		var n = nodes.pop_back()
		if is_instance_valid(n):
			n.queue_free()
	while nodes.size() < want:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = GameData.HERO_FX_PRIORITY
		s.pixel_size = 0.38 / 32.0
		p.add_child(s)
		nodes.append(s)
	p.uniq["net_embers"] = nodes

	var sets: = []
	if u.size() > 3:
		for st in u[3]:
			sets.append([int(st[0]), Color.html(str(st[1])), float(st[2]), float(st[3]), float(st[4])])
	_draw_orbs(p, p.uniq, "net_orbs", sets, Vector3.ZERO, Vfx.dim)

	var qs: Array = u[4] if u.size() > 4 and u[4] is Array else []

	if qs.size() > 1:
		qs = [clampi(int(qs[0]), 0, GameData.U_QUEEN_CHARGE), bool(qs[1])]
	_queen_sparks(p, p.uniq, "net_queen", qs, p, Vfx.dim)

	_puppet_flies(p, clampi(int(u[5]), 0, GameData.U_FLY_MAX) if u.size() > 5 else 0)
	var t: = Time.get_ticks_msec() * (0.0035 if fury else 0.0021)
	for i in nodes.size():
		var a: = t + TAU * i / nodes.size()
		nodes[i].modulate = Color(1.0, 0.75, 0.25, 0.95 * Vfx.dim) if fury else Color(1.0, 0.45, 0.12, 0.85 * Vfx.dim)
		nodes[i].position = Vector3(cos(a) * 1.0, 0.5 + 0.12 * (i % 3) + sin(a * 2.0 + t) * 0.15, sin(a) * 1.0)

	var disc = p.uniq.get("net_night")
	if night > 0.0 and (disc == null or not is_instance_valid(disc)):
		disc = Vfx.ground_glow(p, Vector3(0, 0.01, 0), night * 1.15, Color(0.06, 0.0, 0.12, 0.0))
		p.uniq["net_night"] = disc
	if disc != null and is_instance_valid(disc):
		var to: = 0.62 * Vfx.dim if night > 0.0 else 0.0
		disc.modulate.a = move_toward(disc.modulate.a, to, 0.035)
		if night <= 0.0 and disc.modulate.a <= 0.0:
			disc.queue_free()
			p.uniq.erase("net_night")








static func _ice(world: World, p: Player, e: Enemy, element: String, tag: String) -> void :
	if tag == "u_shatter" or e.dead or e.prop != "":
		return
	if not e.is_boss and e.status == "freeze":
		e.clear_status()
		_shatter(world, p, e)
		return
	var chance: = GameData.U_SHATTER_WATER if element == "water" else GameData.U_SHATTER_FREEZE
	if world.clock >= float(p.uniq.get("freeze_gap", 0.0)) and randf() < chance:
		p.uniq["freeze_gap"] = world.clock + GameData.U_SHATTER_GAP
		world.apply_status(e, "freeze", GameData.U_SHATTER_FREEZE_TIME)



		if e.is_boss and not e.dead and world.clock >= float(p.uniq.get("shatter_boss", 0.0)):
			p.uniq["shatter_boss"] = world.clock + GameData.U_SHATTER_BOSS_CD
			_shatter(world, p, e)


static func _shatter(world: World, p: Player, e: Enemy) -> void :
	var at: = e.position
	var r: = GameData.U_SHATTER_RADIUS * sqrt(p.area_mult)
	if world._bounce_fx_ok(1, "shatter"):
		world.spawn_fx("icecrash", at, 1.0, 0.9)
		Vfx.burst(world.fx_root, at, r, Color(0.6, 0.9, 1.0))
		Vfx.ring(world.fx_root, at, r * 1.2, Color(0.85, 0.97, 1.0), 0.35)
		world.play_sound("frost_hit", 0.12, -6.0)
	var keep: = [world.damage_tag, world.damage_by]
	var hit: = _burst(world, p, at, r, GameData.U_BASE * GameData.U_SHATTER_DMG, "neutral", "u_shatter", "skill", 1.5)
	_restore(world, keep)
	for o in hit:
		if o != e and not o.dead and randf() < GameData.U_SHATTER_CHAIN:
			world.apply_status(o, "freeze", GameData.U_SHATTER_FREEZE_TIME)
	_say(world, p, TranslationServer.translate("¡Añicos!"), "say_shatter", 3.0)







static func _tick_night(world: World, p: Player, delta: float) -> void :
	var disc = p.uniq.get("night_disc")
	if not p.effects.has("u_gloom"):
		if disc != null and is_instance_valid(disc):
			disc.queue_free()
		p.uniq.erase("night_disc")
		return
	var until: = float(p.uniq.get("night_until", 0.0))

	if disc != null and is_instance_valid(disc):
		var k: = clampf((until - world.clock) / 0.5, 0.0, 1.0)
		disc.position = p.position + Vector3(0, 0.07, 0)
		disc.modulate.a = 0.62 * k * Vfx.dim
		if k <= 0.0:
			disc.queue_free()
			p.uniq.erase("night_disc")

	p.uniq["night_t"] = float(p.uniq.get("night_t", GameData.U_GLOOM_FIRST)) - delta
	if world.clock >= until:
		if float(p.uniq.night_t) > 0.0 or world.nearest_enemy(p.position, 9.0) == null:
			return
		p.uniq.night_t = GameData.U_GLOOM_EVERY
		p.uniq["night_until"] = world.clock + GameData.U_GLOOM_TIME
		p.uniq["night_end"] = world.clock + GameData.U_GLOOM_MAX
		var r0: = GameData.U_GLOOM_RADIUS * sqrt(p.area_mult)
		if p.uniq.get("night_disc") == null or not is_instance_valid(p.uniq.get("night_disc")):
			p.uniq["night_disc"] = Vfx.ground_glow(world.fx_root, p.position, r0 * 1.15, Color(0.06, 0.0, 0.12, 0.62))
		world.spawn_fx("hell_in", p.position, 1.6, 1.0)
		Vfx.burst(world.fx_root, p.position, r0, Color(0.25, 0.1, 0.4))
		world.play_sound("stone_curse", 0.3, -4.0)
		_say(world, p, TranslationServer.translate("¡Cae la noche de Gloom!"), "say_night", 2.0)
		return
	var r: = GameData.U_GLOOM_RADIUS * sqrt(p.area_mult)
	p.uniq["night_pulse"] = float(p.uniq.get("night_pulse", 0.0)) - delta
	if float(p.uniq.night_pulse) <= 0.0:
		p.uniq.night_pulse = 0.3
		Vfx.ring(world.fx_root, p.position, r, Color(0.62, 0.32, 1.0), 0.45)
		Vfx.ring(world.fx_root, p.position, r * 0.96, Color(0.2, 0.05, 0.35), 0.45)
		for e in world.enemies_in_radius(p.position, r):
			if e.dead or e.prop != "":
				continue
			e.night_until = world.clock + 0.45
			if not e.is_boss:
				e.slow_time = maxf(e.slow_time, 0.45)
		if world._bounce_fx_ok(1, "night"):
			var a: = randf() * TAU
			world.spawn_fx("hell_in", p.position + Vector3(cos(a), 0, sin(a)) * r * randf_range(0.3, 0.9), 0.5, 0.5)



static func _night_kill(world: World, p: Player, e: Enemy) -> void :
	if not p.effects.has("u_gloom") or e.night_until <= world.clock:
		return
	var until: = float(p.uniq.get("night_until", 0.0))
	if until > world.clock:
		p.uniq["night_until"] = minf(float(p.uniq.get("night_end", until)), until + GameData.U_GLOOM_KILL)






static func _tick_flies(world: World, p: Player, delta: float) -> void :
	var flies: Array = p.uniq.get("flies", [])
	var want: = fly_count(world, p)
	while flies.size() > want:
		var f = flies.pop_back()
		if is_instance_valid(f):
			f.queue_free()
	if want <= 0:
		p.uniq.erase("flies")
		if p.uniq.has("plague_nodes"):
			_plague_marks(world, p, true)
		return
	while flies.size() < want:
		flies.append(_fly_visual(world.run_root))
	p.uniq["flies"] = flies
	var a: = float(p.uniq.get("fly_a", 0.0)) + delta * 2.6
	p.uniq["fly_a"] = a
	_orbit_flies(flies, p.position, GameData.U_FLY_RADIUS * sqrt(p.area_mult), a)
	_plague_bursts(world, p, delta)
	_plague_marks(world, p, false)
	p.uniq["fly_t"] = float(p.uniq.get("fly_t", 0.0)) - delta
	if float(p.uniq.fly_t) > 0.0:
		return
	p.uniq.fly_t = GameData.U_FLY_EVERY
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_flies"
	world.damage_by = p
	var stung: = 0
	var near: = world.enemies_in_radius(p.position, GameData.U_FLY_REACH * sqrt(p.area_mult))
	var sting: = GameData.U_BASE * GameData.U_FLY_DMG
	for f in flies:
		if near.is_empty():
			break

		var e: Enemy = near.pick_random()
		if e.dead or e.prop != "":
			continue
		world._bounce_trace(f.position - Vector3(0, 0.75, 0), e.position, Color(0.75, 1.0, 0.35))

		_infest(world, p, e, int(e.get_meta("plague_depth", 0)) if _infested(world, e) else 0)
		world.damage_enemy(e, sting, Vector3.ZERO, "skill", "wind", "u_flies")
		stung += 1
	_restore(world, keep)

	if stung > 0:
		p.hp = minf(p.max_hp, p.hp + p.max_hp * GameData.U_FLY_HEAL * 0.01 * mini(stung, int(p.effects.get("u_flies", 0.0))))



static func _puppet_flies(p: Player, want: int) -> void :
	var flies: Array = p.uniq.get("net_flies", [])
	while flies.size() > want:
		var f = flies.pop_back()
		if is_instance_valid(f):
			f.queue_free()
	while flies.size() < want:
		flies.append(_fly_visual(p))
	if flies.is_empty():
		p.uniq.erase("net_flies")
		return
	p.uniq["net_flies"] = flies
	_orbit_flies(flies, Vector3.ZERO, GameData.U_FLY_RADIUS, Time.get_ticks_msec() * 0.0026)




static func fly_count(world: World, p: Player) -> int:
	var base: = int(p.effects.get("u_flies", 0.0))
	if base <= 0:
		return 0
	var brood: Array = (p.uniq.get("fly_brood", []) as Array).filter( func(t): return float(t) > world.clock)
	p.uniq["fly_brood"] = brood
	return mini(GameData.U_FLY_MAX, base + brood.size())


static func _fly_visual(parent: Node) -> RoVisual:
	var v: = RoVisual.new()
	parent.add_child(v)
	v.setup(RoAssets.sprite(["hunter_fly"]), Color(0.4, 0.4, 0.3), 20, 0.4)
	v.play(RoVisual.MOB_WALK, true)
	return v




static func _orbit_flies(flies: Array, center: Vector3, r: float, a: float) -> void :
	var outer: = flies.size() - 6
	for i in flies.size():
		var inner: = i < 6
		var n: = mini(flies.size(), 6) if inner else outer
		var t: = (a if inner else - a * 0.8) + TAU * (i if inner else i - 6) / maxi(1, n)
		var k: = 1.0 if inner else 1.5
		var at: = center + Vector3(cos(t) * r * k, 0.9 + sin(t * 2.0) * 0.2 + (0.0 if inner else 0.35), sin(t) * r * k)
		flies[i].position = at
		flies[i].face(Vector3( - sin(t), 0, cos(t)) * (1.0 if inner else -1.0))


static func _infested(world: World, e: Enemy) -> bool:
	return e.has_meta("plague_until") and float(e.get_meta("plague_until")) > world.clock



static func _infest(world: World, p: Player, e: Enemy, depth: int) -> void :
	if e.dead or e.prop != "":
		return
	var fresh: = not _infested(world, e)
	e.set_meta("plague_until", world.clock + GameData.U_PLAGUE_TIME)
	e.set_meta("plague_by", p.get_instance_id())
	e.set_meta("plague_depth", depth)
	if fresh:

		if not Vfx._skip(1):
			Vfx.ring(world.fx_root, e.position + Vector3(0, 0.05, 0), 0.7, GameData.U_PLAGUE_COLOR, 0.3)
		var list: Array = p.uniq.get("plague_list", [])
		list.append(e)
		p.uniq["plague_list"] = list





static func plague_death(world: World, e: Enemy) -> void :
	if not _infested(world, e):
		return
	e.remove_meta("plague_until")
	var p: = instance_from_id(int(e.get_meta("plague_by", 0))) as Player
	if p == null or not is_instance_valid(p) or not p.effects.has("u_flies"):
		return
	var brood: Array = (p.uniq.get("fly_brood", []) as Array).filter( func(t): return float(t) > world.clock)
	if brood.size() >= GameData.U_FLY_MAX - int(p.effects.get("u_flies", 0.0)):
		brood.sort()
		brood.pop_front()
	brood.append(world.clock + GameData.U_FLY_BROOD_TIME)
	p.uniq["fly_brood"] = brood
	var depth: = int(e.get_meta("plague_depth", 0))
	var q: Array = p.uniq.get("plague_q", [])
	if depth >= GameData.U_PLAGUE_DEPTH or q.size() >= GameData.U_PLAGUE_QUEUE:
		return
	q.append([e.position, depth, world.clock])
	p.uniq["plague_q"] = q




static func _plague_bursts(world: World, p: Player, delta: float) -> void :
	var tokens: = minf(GameData.U_PLAGUE_PER_SEC, float(p.uniq.get("plague_tok", GameData.U_PLAGUE_PER_SEC)) + delta * GameData.U_PLAGUE_PER_SEC)
	var q: Array = p.uniq.get("plague_q", [])
	var n: = 0
	while not q.is_empty() and n < GameData.U_PLAGUE_PER_FRAME and tokens >= 1.0:
		var b: Array = q.pop_front()
		if world.clock - float(b[2]) > 1.0:
			continue
		tokens -= 1.0
		n += 1
		_plague_burst(world, p, b[0], int(b[1]))
	p.uniq["plague_q"] = q
	p.uniq["plague_tok"] = tokens





static func _plague_burst(world: World, p: Player, at: Vector3, depth: int) -> void :
	var reach: = GameData.U_PLAGUE_REACH * sqrt(p.area_mult)
	var near: Array = world.nearest_enemies(at, reach, GameData.U_PLAGUE_JUMPS * 2).filter( func(o): return not o.dead and o.prop == "")
	var fresh: Array = near.filter( func(o): return not _infested(world, o))
	var old: Array = near.filter( func(o): return _infested(world, o))
	var targets: Array = (fresh + old).slice(0, GameData.U_PLAGUE_JUMPS)
	p.uniq["plague_n"] = int(p.uniq.get("plague_n", 0)) + 1


	Vfx.burst(world.fx_root, at + Vector3(0, 0.3, 0), 1.5, GameData.U_PLAGUE_COLOR)
	if targets.is_empty():
		return
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_flies"
	world.damage_by = p
	for o in targets:
		_plague_swarm(world, at, o.position)
		Vfx.ring(world.fx_root, o.position + Vector3(0, 0.05, 0), 0.9, Color(0.5, 0.65, 0.15), 0.35)
		_infest(world, p, o, depth + 1)
		world.damage_enemy(o, GameData.U_BASE * GameData.U_PLAGUE_DMG, Vector3.ZERO, "skill", "wind", "u_flies")
	_restore(world, keep)




static func _plague_swarm(world: World, from: Vector3, to: Vector3) -> void :
	if Vfx.hidden() or Vfx._skip(2):
		return
	for k in 8:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = GameData.HERO_FX_PRIORITY
		s.pixel_size = randf_range(0.36, 0.5) / 32.0
		s.modulate = (Color(0.62, 0.85, 0.15, 0.95 * Vfx.dim) if k % 3 == 0 else Color(0.08, 0.1, 0.03, 0.95 * Vfx.dim))
		world.fx_root.add_child(s)
		var mid: = (from + to) * 0.5 + Vector3(randf_range(-0.7, 0.7), 1.4 + randf() * 0.6, randf_range(-0.7, 0.7))
		s.position = from + Vector3(randf_range(-0.35, 0.35), randf_range(0.6, 1.2), randf_range(-0.35, 0.35))
		var t: = randf_range(0.26, 0.4)
		var tw: = s.create_tween()
		tw.tween_property(s, "position", mid, t * 0.5).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "position", to + Vector3(randf_range(-0.3, 0.3), 0.9, randf_range(-0.3, 0.3)), t * 0.5).set_ease(Tween.EASE_IN)
		tw.tween_property(s, "modulate:a", 0.0, 0.15)
		tw.tween_callback(s.queue_free)







const PLAGUE_PICK_GAP: = 0.2
static func _plague_marks(world: World, p: Player, clear: bool) -> void :
	var alive: = func(e): return is_instance_valid(e) and not e.dead and _infested(world, e)
	var show: Array = []
	if world.clock >= float(p.uniq.get("plague_pick_at", -1.0)):
		p.uniq["plague_pick_at"] = world.clock + PLAGUE_PICK_GAP
		var list: Array = (p.uniq.get("plague_list", []) as Array).filter(alive)
		p.uniq["plague_list"] = list
		show = list.duplicate()
		if show.size() > GameData.U_PLAGUE_MARKS:
			show.sort_custom( func(x, y): return x.position.distance_squared_to(p.position) < y.position.distance_squared_to(p.position))
			show = show.slice(0, GameData.U_PLAGUE_MARKS)
		p.uniq["plague_show"] = show
	else:
		show = (p.uniq.get("plague_show", []) as Array).filter(alive)
	if clear or Vfx.hidden():
		show = []
	var nodes: Array = p.uniq.get("plague_nodes", [])
	var want: = show.size() * 3
	while nodes.size() > want:
		var n = nodes.pop_back()
		if is_instance_valid(n):
			n.queue_free()
	while nodes.size() < want:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = GameData.HERO_FX_PRIORITY
		s.pixel_size = 0.36 / 32.0
		world.run_root.add_child(s)
		nodes.append(s)
	if nodes.is_empty():
		p.uniq.erase("plague_nodes")
		return
	p.uniq["plague_nodes"] = nodes
	var t: = Time.get_ticks_msec() * 0.006
	for i in show.size():
		var e: Enemy = show[i]
		var top: = 1.2
		if e.visual != null:
			top = e.visual.height() * ((e.visual as Node3D).scale.y if e.visual is Node3D else 1.0)
		for k in 3:
			var s: Sprite3D = nodes[i * 3 + k]
			if k == 0:


				s.pixel_size = 0.9 / 32.0
				s.modulate = Color(0.55, 0.85, 0.1, (0.3 + 0.08 * sin(t + i)) * Vfx.dim)
				s.position = e.position + Vector3(0, top * 0.5, 0)
				continue
			var a: = t * (1.0 + 0.3 * k) + PI * k + i
			s.modulate = Color(0.08, 0.1, 0.02, 0.95 * Vfx.dim)
			s.position = e.position + Vector3(cos(a) * 0.5, top * 0.85 + sin(a * 2.3) * 0.18, sin(a) * 0.5)








static func _tick_overload(world: World, p: Player, delta: float) -> void :
	if cannon(p) == "":
		if p.ov_stage != 0 or p.uniq.has("ov_energy"):
			p.uniq.erase("ov_energy")
			p.uniq.erase("ov_t")
			p.ov_stage = 0
			p.ov_text = ""
		return



	if not p.uniq.has("ov_warm") and p == world.player:
		p.uniq["ov_warm"] = true
		_overload_warm(world, p)


	p.uniq["ov_gap"] = maxf(0.0, float(p.uniq.get("ov_gap", 0.0)) - delta)
	var excal: = cannon(p) == "excal"
	var bw: = cannon(p) == "bulwark"
	if excal:
		_ex_bank(world, p, false)
	if bw and p.ov_stage < GameData.U_BW_STAGES and not p.downed:
		p.uniq["ov_t"] = float(p.uniq.get("ov_t", 0.0)) + delta / GameData.U_BW_IDLE
	var stage: = overload_stage_at(float(p.uniq.get("ov_t", 0.0)), charge_steps(p))
	var power: = overload_power(p, stage)


	if bw:

		power *= p.dmg_mult * p.skill_mult_for("u_bulwark")
	p.ov_text = (("x:" if excal else ("b:" if bw else "")) + _short(power)) if stage > 0 else ""
	if stage == p.ov_stage:
		return
	p.ov_stage = stage
	if stage <= 0:
		return
	if excal:
		_excal_level(world, p, stage)
		return
	if bw:
		_bulwark_level(world, p, stage)
		return

	var top: = stage >= GameData.U_OV_STAGES
	var col: = GameData.U_OV_GOLD if top else GameData.U_OV_BLUE
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.2 + 0.25 * stage, col, 0.45)
	if top:
		Vfx.column(world.fx_root, p.position, Color(0.75, 0.9, 1.0))
		world.play_sound("maximize_power", 0.2, -3.0, -1.0, true, true)
		_say(world, p, TranslationServer.translate("¡Cañón cargado!"))
	else:
		world.play_sound("sl_energy", 0.2, -4.0, 0.9 + 0.08 * stage)





static func overload_swing(world: World, p: Player, target: Enemy = null) -> void :


	if cannon(p) != "rail" or float(p.uniq.get("ov_gap", 0.0)) > 0.0:
		return
	p.uniq["ov_gap"] = GameData.U_OV_SWING_GAP
	p.uniq["ov_t"] = float(p.uniq.get("ov_t", 0.0)) + 1.0






static func excal_cast(world: World, p: Player) -> void :
	if cannon(p) != "excal" or world.clock < float(p.uniq.get("ex_cast_at", -1.0)):
		return
	p.uniq["ex_cast_at"] = world.clock + GameData.U_EX_CAST_GAP
	p.uniq["ov_t"] = float(p.uniq.get("ov_t", 0.0)) + 1.0






static func _ex_bank(world: World, p: Player, all: bool) -> void :
	var peaks: Dictionary = p.uniq.get("ex_peak", {})
	if peaks.is_empty():
		return
	var energy: = float(p.uniq.get("ov_energy", 0.0))
	for tag in peaks.keys():
		var pk: Array = peaks[tag]
		if all or world.clock - float(pk[0]) >= GameData.U_EX_PEAK_WINDOW:
			energy += float(pk[1]) * float(p.effects.get("u_excalibur", 1.0))
			peaks.erase(tag)
	p.uniq["ov_energy"] = energy




static func charge_steps(p: Player) -> Array:
	if _is_bulwark(p):
		return GameData.U_BW_STAGE_STEPS
	return GameData.U_EX_STAGE_CASTS if _is_excal(p) else GameData.U_OV_STAGE_SWINGS



static func overload_stage_at(t: float, steps: Array = GameData.U_OV_STAGE_SWINGS) -> int:
	var stage: = 0
	for need in steps:
		if t < float(need):
			break
		t -= float(need)
		stage += 1
	return mini(stage, GameData.U_OV_STAGES)



static func overload_part(t: float, steps: Array = GameData.U_OV_STAGE_SWINGS) -> float:
	for need in steps:
		if t < float(need):
			return t / float(need)
		t -= float(need)
	return 1.0




static func overload_power(p: Player, stage: int) -> float:
	if stage <= 0:
		return 0.0
	if cannon(p) == "bulwark":
		return bulwark_power(p, stage)
	var energy: = maxf(float(p.uniq.get("ov_energy", 0.0)), p.basic_atk() * p.arrow_bonus() * 4.0)
	var mult: Array = GameData.U_EX_MULT if cannon(p) == "excal" else GameData.U_OV_MULT
	return energy * float(mult[mini(stage, mult.size() - 1)])


static func overload_ready(p: Player) -> bool:
	return cannon(p) != "" and p.ov_stage >= 1




static func cannon(p: Player) -> String:
	if p == null or not is_instance_valid(p):
		return ""
	if p.effects.has("u_excalibur"):
		return "excal"
	if p.effects.has("u_overload"):
		return "rail"
	if p.effects.has("u_bulwark"):
		return "bulwark"
	return ""



static func _is_excal(p: Player) -> bool:
	return p.effects.has("u_excalibur") or str(p.ov_text).begins_with("x:")



static func _is_bulwark(p: Player) -> bool:
	return p.effects.has("u_bulwark") or str(p.ov_text).begins_with("b:")



static func overload_net_fx(world: World, ev: Array) -> void :
	match str(ev[1]):
		"charge":
			_overload_charge_fx(world, ev[2], int(ev[5]))
		"beam":
			_overload_beam(world, ev[2], ev[3], float(ev[4]), int(ev[5]), ev[6] if ev.size() > 6 else (ev[2] as Vector3) - Vector3(0, 0.9, 0), 
				float(ev[7]) if ev.size() > 7 else GameData.U_OV_WIDTH)
		"lks":
			preload("res://scripts/core/lord_knight.gd").slash_fx(world, ev[2], ev[3], float(ev[4]), float(ev[5]), bool(ev[6]))
		"excharge":
			_excal_charge_fx(world, ev[2], ev[3], int(ev[5]), float(ev[4]))
		"bwraise":
			_bulwark_raise_fx(world, ev[2], int(ev[3]), float(ev[4]))
		"bwslam":
			_bulwark_slam_fx(world, ev[2], float(ev[3]), int(ev[4]))
		"exwave":
			_excal_wave_fx(world, ev[2], ev[3], float(ev[4]), int(ev[5]), float(ev[6]), float(ev[7]))



static func _short(v: float) -> String:
	for pair in [[1000000000000.0, "T"], [1000000000.0, "B"], [1000000.0, "M"], [1000.0, "k"]]:
		if v >= float(pair[0]):
			var n: = v / float(pair[0])
			return ("%.1f" % n if n < 100.0 else "%d" % int(n)) + str(pair[1])
	return "%d" % int(v)






static func overload_fire(world: World, p: Player) -> void :
	if p == null or not is_instance_valid(p) or p.downed or cannon(p) == "":
		return
	if cannon(p) == "excal":
		excalibur_fire(world, p)
		return
	if cannon(p) == "bulwark":
		bulwark_fire(world, p)
		return
	if p.ov_stage < 1:
		_say(world, p, TranslationServer.translate("Cargando..."), "say_ov", 0.8)
		return
	var stage: = p.ov_stage
	var power: = overload_power(p, stage)
	p.uniq["ov_energy"] = 0.0
	p.uniq["ov_t"] = 0.0
	p.ov_stage = 0
	p.ov_text = ""
	var target: = _ov_target(world, p)
	var dir: = p.facing
	if target != null:
		var to: = (target.position - p.position) * Vector3(1, 0, 1)
		if to.length_squared() > 0.0001:
			dir = to.normalized()
	dir = (dir * Vector3(1, 0, 1)).normalized() if dir.length_squared() > 0.0001 else Vector3.FORWARD
	p.facing = dir
	p.visual.face(dir)
	p.visual.play(int(p.look.get("attack", RoVisual.PC_ATTACK)), false, true)
	p._attack_anim = GameData.U_OV_WINDUP + 0.35


	var muzzle: = muzzle_of(p, dir)
	for i in 2:
		Vfx.converge(world.fx_root, p.position + Vector3(0, 0.05, 0), 2.0 + i * 1.0, Color(GameData.U_OV_BLUE, 0.7), GameData.U_OV_WINDUP)
	world.play_sound("sl_energy", 0.0, 0.0, 0.7, true, true)
	_overload_charge_fx(world, muzzle, stage)
	if world.net.recording():
		world.net.record(["ov", "charge", muzzle, dir, 0.0, stage])
	world.get_tree().create_timer(GameData.U_OV_WINDUP, false).timeout.connect( func():
		if not is_instance_valid(p) or p.downed or not world.running:
			return

		var d: = dir
		if target != null and is_instance_valid(target) and not target.dead:
			var to2: = (target.position - p.position) * Vector3(1, 0, 1)
			if to2.length_squared() > 0.0001:
				d = to2.normalized()
		p.facing = d
		p.visual.face(d)
		_overload_shot(world, p, d, power, stage, target if target != null and is_instance_valid(target) else null))







static func bulwark_gain(world: World, p: Player, kind: String) -> void :
	if cannon(p) != "bulwark" or p.downed:
		return
	var now: = World.game_ms() * 0.001
	if now < float(p.uniq.get("bw_at", -99.0)):
		return
	p.uniq["bw_at"] = now + GameData.U_BW_GAP
	p.uniq["ov_t"] = float(p.uniq.get("ov_t", 0.0)) + float(GameData.U_BW_WEIGHT.get(kind, 0.5))



	if kind == "hit" or kind == "absorb":
		return
	if kind != "guard":
		world.sprite_fx("fx_shield", p.position + Vector3(0, 1.1, 0), 0, 0.6)
	world.play_sound("guard_block", 0.12, -16.0, 1.25 + 0.06 * p.ov_stage)





static func bulwark_power(_p: Player, stage: int) -> float:
	if stage <= 0:
		return 0.0
	return GameData.U_BASE * float(GameData.U_BW_MULT[mini(stage, GameData.U_BW_MULT.size() - 1)])




static func _bulwark_level(world: World, p: Player, stage: int) -> void :
	var top: = stage >= GameData.U_BW_STAGES
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.1 + 0.22 * stage, GameData.U_BW_GOLD if top else GameData.U_BW_BLUE, 0.45)
	if top:
		Vfx.column(world.fx_root, p.position, GameData.U_BW_PALE)
		world.play_sound("reflect_shield", 0.2, -2.0, 0.8, true, true)
		_say(world, p, TranslationServer.translate("¡Baluarte listo!"))
	else:
		world.play_sound("reflect_shield", 0.2, -8.0, 0.9 + 0.07 * stage)





static func bulwark_fire(world: World, p: Player) -> void :
	if p.ov_stage < 1:
		_say(world, p, TranslationServer.translate("Cargando..."), "say_ov", 0.8)
		return
	var stage: = p.ov_stage
	var power: = bulwark_power(p, stage)
	p.uniq["ov_energy"] = 0.0
	p.uniq["ov_t"] = 0.0
	p.ov_stage = 0
	p.ov_text = ""
	p.visual.play(RoVisual.PC_CAST, false, true)
	p._attack_anim = GameData.U_BW_WINDUP + 0.35
	p.skill_guard(GameData.U_BW_WINDUP + 0.15)
	var h: = p.visual.height() if p.visual != null else 1.6
	_bulwark_raise_fx(world, p.position, stage, h)
	if world.net.recording():
		world.net.record(["ov", "bwraise", p.position, stage, h])
	world.get_tree().create_timer(GameData.U_BW_WINDUP, false).timeout.connect( func():
		if not is_instance_valid(p) or p.downed or not world.running:
			return
		p.visual.play(int(p.look.get("attack", RoVisual.PC_ATTACK)), false, true)
		_bulwark_slam(world, p, power, stage))






static func _bulwark_slam(world: World, p: Player, power: float, stage: int) -> void :
	var at: = p.position
	var radius: = (GameData.U_BW_RADIUS + GameData.U_BW_RADIUS_STAGE * stage) * sqrt(p.area_mult)

	var bands: = []
	for b in GameData.U_BW_BANDS:
		bands.append([])
	for e in world.enemies_in_radius(at, radius):
		if e.dead:
			continue
		var d: = ((e.position - at) * Vector3(1, 0, 1)).length()
		bands[mini(GameData.U_BW_BANDS - 1, int(d / radius * GameData.U_BW_BANDS))].append(e)
	_bulwark_hit(world, p, at, bands[0], power, stage)
	for b in range(1, GameData.U_BW_BANDS):
		var group: Array = bands[b]
		if group.is_empty():
			continue
		world.get_tree().create_timer(GameData.U_BW_WAVE_TIME * float(b) / GameData.U_BW_BANDS, false).timeout.connect( func():
			if is_instance_valid(p) and world.running:
				_bulwark_hit(world, p, at, group, power, stage))
	_bulwark_slam_fx(world, at, radius, stage)
	if world.net.recording():
		world.net.record(["ov", "bwslam", at, radius, stage])
	world.shake(minf(1.0, 0.5 + 0.1 * stage), true)
	if stage >= 3 and p == world.player:
		world.hud.flash(GameData.U_BW_PALE, 0.35, 0.18 + 0.04 * stage)

	if p == world.player and not world.net.is_client() and not world._mvp_slow and Engine.time_scale > 0.2:
		var was: = Engine.time_scale
		Engine.time_scale = 0.05
		world.get_tree().create_timer(GameData.U_OV_HITSTOP + 0.02 * stage, true, false, true).timeout.connect( func():
			if Engine.time_scale < 0.06:
				Engine.time_scale = was)






static func _bulwark_hit(world: World, p: Player, at: Vector3, group: Array, power: float, stage: int) -> void :
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_bulwark"
	world.damage_by = p
	for x in group:
		if not is_instance_valid(x) or x.dead:
			continue
		var e: Enemy = x
		var to: = (e.position - at) * Vector3(1, 0, 1)
		var d: = to.length()
		var out: = to / d if d > 0.01 else Vector3(1, 0, 0).rotated(Vector3.UP, randf() * TAU)
		var core: = d <= GameData.U_BW_CORE + e.radius
		var push: = out * (8.0 + 1.5 * stage) if e.prop == "" else Vector3.ZERO
		world.damage_enemy(e, power * (GameData.U_BW_CORE_MULT if core else 1.0), push, "skill", "neutral", "u_bulwark")
		if (e.is_boss or e.def.get("elite", false)) and not e.dead:
			world.stagger.add(world, e, GameData.U_BW_STAGGER * stage, "u_bulwark", true)
	_restore(world, keep)


static var _bw_tex: Texture2D
static func _bulwark_tex() -> Texture2D:
	if _bw_tex == null:
		var path: = "res://assets/ro/ui/skin/item_icons/imperial_guard_big.png"
		_bw_tex = load(path) if ResourceLoader.exists(path) else RoAssets.radial(GameData.U_BW_BLUE, 64)
	return _bw_tex





static func _bulwark_raise_fx(world: World, at: Vector3, stage: int, h: float) -> void :


	_ex_local(world, true)
	_bulwark_raise_draw(world, at, stage, h)
	_ex_local(world, false)


static func _bulwark_raise_draw(world: World, at: Vector3, stage: int, h: float) -> void :
	world.play_sound("guard_block", 0.0, -2.0, 0.7, true, true)
	world.play_sound("sl_reflect", 0.0, -6.0, 0.9, true, true)
	if Vfx.hidden():
		return
	var s: = Sprite3D.new()
	s.texture = _bulwark_tex()
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.transparent = true
	s.no_depth_test = true
	s.render_priority = 8
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.pixel_size = (1.8 + 0.1 * stage) / 100.0
	s.modulate = Color(1, 1, 1, 0.0)
	world.fx_root.add_child(s)
	s.global_position = at + Vector3(0, h + 0.6, 0)
	s.scale = Vector3.ONE * 0.4
	var halo: = Sprite3D.new()
	halo.texture = RoAssets.radial(Color.WHITE, 128)
	halo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	halo.shaded = false
	halo.no_depth_test = true
	halo.render_priority = 7
	halo.pixel_size = 2.4 / 128.0
	halo.modulate = Color(GameData.U_BW_GOLD, 0.0)
	s.add_child(halo)
	halo.position = Vector3(0, 0, -0.01)
	var up: = GameData.U_BW_WINDUP
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "modulate:a", 1.0, up * 0.35)
	tw.tween_property(s, "scale", Vector3.ONE, up * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "global_position:y", at.y + h + 1.15, up * 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(halo, "modulate:a", 0.75, up * 0.8)
	tw.chain().tween_property(s, "global_position:y", at.y + 0.35, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_property(s, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(s.queue_free)
	for i in 2:
		Vfx.converge(world.fx_root, at + Vector3(0, 0.05, 0), 2.2 + i * 1.1, Color(GameData.U_BW_GOLD, 0.7), up)






static func _bulwark_slam_fx(world: World, at: Vector3, radius: float, stage: int) -> void :
	_ex_local(world, true)
	_bulwark_slam_draw(world, at, radius, stage)
	_ex_local(world, false)




static func _bulwark_wave(world: World, at: Vector3, r: float, col: Color, life: float) -> void :
	var s: = Vfx._flat(world.fx_root, Vfx.ring_texture(), at, r, col)
	s.no_depth_test = true
	s.render_priority = 6
	s.scale = Vector3.ONE * 0.25
	var tw: = s.create_tween().set_parallel()
	tw.tween_property(s, "scale", Vector3.ONE, life).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(s, "modulate:a", 0.0, life).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tw.chain().tween_callback(s.queue_free)


static func _bulwark_slam_draw(world: World, at: Vector3, radius: float, stage: int) -> void :
	var ground: = at + Vector3(0, 0.05, 0)
	var wave: = GameData.U_BW_WAVE_TIME


	world.play_sound("guard_block", 0.0, 4.0, 0.5, true, true)
	world.play_sound("hammer_fall", 0.0, 2.0, 0.8, true, true)
	if stage >= 3:
		world.play_sound("critical_explosion", 0.0, -1.0, 0.75, true, true)
	world.play_sound("earth_quake", 0.0, 0.0, 0.85, true, true)
	if Vfx.hidden():
		return

	Vfx.strike_circle(world.fx_root, ground, 2.0 + 0.15 * stage, GameData.U_BW_WAVE_B)

	var stamp: = Sprite3D.new()
	stamp.texture = _bulwark_tex()
	stamp.axis = Vector3.AXIS_Y
	stamp.shaded = false
	stamp.no_depth_test = true
	stamp.render_priority = 9
	stamp.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	stamp.pixel_size = (2.6 + 0.25 * stage) / 100.0
	stamp.modulate = Color(1.0, 0.95, 0.85, 0.95 * Vfx.dim)
	world.fx_root.add_child(stamp)
	stamp.global_position = ground + Vector3(0, 0.03, 0)
	stamp.rotation.y = world.camera.global_rotation.y if world.camera != null else 0.0
	stamp.scale = Vector3.ONE * 0.6
	var st: = stamp.create_tween()
	st.tween_property(stamp, "scale", Vector3.ONE * 1.1, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	st.tween_interval(0.7)
	st.tween_property(stamp, "modulate:a", 0.0, 0.6)
	st.tween_callback(stamp.queue_free)
	Vfx.magic_circle(world.fx_root, ground, radius, Color(GameData.U_BW_WAVE_A, 0.35), 0.9, "mvp_hexa", 1.4, 5, true)
	Vfx.ray_flash(world.fx_root, at + Vector3(0, 0.8, 0), world.camera.global_basis if world.camera != null else Basis(), 
		GameData.U_BW_WAVE_B, 1.2 + 0.15 * stage)

	var disc: = Vfx._flat(world.fx_root, RoAssets.radial(Color.WHITE, 128), ground, radius, Color(GameData.U_BW_FLASH, 0.45))
	disc.no_depth_test = true
	disc.render_priority = 5
	disc.scale = Vector3.ONE * 0.15
	var dt: = disc.create_tween().set_parallel()
	dt.tween_property(disc, "scale", Vector3.ONE, wave).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	dt.tween_property(disc, "modulate:a", 0.0, wave + 0.15).set_ease(Tween.EASE_IN)
	dt.chain().tween_callback(disc.queue_free)


	_bulwark_wall(world, ground, radius, Color(GameData.U_BW_WAVE_A, 0.95), wave, 1.3 + 0.12 * stage)
	_bulwark_wave(world, ground, radius, GameData.U_BW_FLASH, wave + 0.2)
	world.get_tree().create_timer(0.05, false).timeout.connect( func():
		_ex_local(world, true)
		_bulwark_wall(world, ground, radius * 0.92, Color(GameData.U_BW_WAVE_B, 0.8), wave, 0.8 + 0.08 * stage)
		_bulwark_wave(world, ground, radius * 0.9, GameData.U_BW_WAVE_B, wave + 0.15)
		_ex_local(world, false))
	world.get_tree().create_timer(0.12, false).timeout.connect( func():
		_ex_local(world, true)
		_bulwark_wave(world, ground, radius * 0.75, GameData.U_BW_WAVE_A, wave + 0.25)
		_ex_local(world, false))

	var bands: = 4
	for b in bands:
		var f: = float(b + 1) / bands
		var puffs: = 5 + (3 + stage) * (b + 1) / bands
		var dust: = GameData.U_BW_FLASH if b < bands - 1 else Color(0.85, 0.8, 0.7)
		world.get_tree().create_timer(wave * f * 0.9, false).timeout.connect( func():
			_ex_local(world, true)
			for i in puffs:
				var a: = TAU * i / puffs + randf() * 0.4
				Vfx.burst(world.fx_root, ground + Vector3(cos(a), 0, sin(a)) * radius * f * randf_range(0.85, 1.0), 
					(0.45 + 0.06 * stage) * (0.7 + 0.5 * f), dust)
			_ex_local(world, false))





static func _bulwark_wall(world: World, at: Vector3, radius: float, col: Color, life: float, h: float) -> void :
	var mi: = MeshInstance3D.new()
	var cyl: = CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = h
	cyl.cap_top = false
	cyl.cap_bottom = false
	cyl.radial_segments = 48
	cyl.rings = 1
	mi.mesh = cyl
	var mat: = Vfx.energy_material(col, true, 2.5, false, Vector2(TAU * radius, h))
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(mi)
	mi.global_position = at + Vector3(0, h * 0.5 - 0.05, 0)
	var r0: = maxf(0.6, radius * 0.08)
	mi.scale = Vector3(r0, 1.0, r0)
	var tw: = mi.create_tween().set_parallel()
	tw.tween_property(mi, "scale", Vector3(radius, 1.0, radius), life).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_method( func(a: float): mat.set_shader_parameter("alpha", a), 1.0, 0.0, life * 1.25).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(mi.queue_free)




static func _ov_length(world: World, from: Vector3, dir: Vector3) -> float:
	var hx: = world.map.width * 0.5
	var hz: = world.map.height * 0.5
	var t: = 1000000000.0
	if absf(dir.x) > 0.0001:
		t = minf(t, ((hx if dir.x > 0.0 else - hx) - from.x) / dir.x)
	if absf(dir.z) > 0.0001:
		t = minf(t, ((hz if dir.z > 0.0 else - hz) - from.z) / dir.z)
	return clampf(t, GameData.U_OV_LENGTH, GameData.U_OV_LENGTH_MAX)



static func _ov_target(world: World, p: Player) -> Enemy:
	var best: Enemy = null
	var best_k: = -1.0
	for e in world.enemies_in_radius(p.position, GameData.U_OV_RANGE):
		if e.dead or e.prop != "":
			continue
		var k: = e.hp
		if e.def.get("mvp", false):
			k += 1e+15
		elif e.is_boss:
			k += 10000000000000.0
		elif e.def.get("elite", false) or e.feroz:
			k += 100000000000.0
		if k > best_k:
			best_k = k
			best = e
	return best




static func muzzle_of(p: Player, dir: Vector3) -> Vector3:
	var h: = p.visual.height() if p.visual != null else 1.6
	return p.position + RoVisual.world_lift() + Vector3(0, h * GameData.U_OV_MUZZLE_UP, 0) + dir * GameData.U_OV_MUZZLE_AHEAD


static func _overload_shot(world: World, p: Player, dir: Vector3, power: float, stage: int, target: Enemy) -> void :
	var from: = muzzle_of(p, dir)
	var ground: = p.position + Vector3(0, 0.05, 0)

	var length: = _ov_length(world, p.position, dir)
	var width: = GameData.U_OV_WIDTH * (0.6 + 0.12 * stage) * p.area_mult
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_overload"
	world.damage_by = p
	var struck: Array = []
	for e in world.enemies_in_radius(p.position + dir * length * 0.5, length * 0.5 + width + 1.0):
		if e.dead:
			continue
		var to: Vector3 = (e.position - p.position) * Vector3(1, 0, 1)
		var along: = to.dot(dir)
		if along < -0.5 or along > length:
			continue
		if (to - dir * along).length() <= width + e.radius:
			struck.append(e)
	if target != null and not target.dead and not struck.has(target):
		struck.append(target)


	var shown: = 0
	for e in struck:
		var main: bool = e == target
		_flat_hit(world, p, e, power, dir * (6.0 + stage), main, main or shown < GameData.U_OV_NUMBERS)
		if not main:
			shown += 1
	_restore(world, keep)


	_overload_beam(world, from, dir, length, stage, ground, width)
	if world.net.recording():
		world.net.record(["ov", "beam", from, dir, length, stage, ground, width])
	var col: = GameData.U_OV_GOLD if stage >= GameData.U_OV_STAGES else GameData.U_OV_BLUE
	Vfx.ray_flash(world.fx_root, from, world.camera.global_basis, Color(0.8, 0.95, 1.0), 0.7 + 0.12 * stage)
	Vfx.burst(world.fx_root, ground + dir * 0.6, 1.4 + 0.3 * stage, col)


	var gap: = maxf(2.6, length / GameData.U_OV_BURSTS)
	var steps: = int(length / gap)
	for i in steps:
		var at: = p.position + dir * (2.4 + i * gap) + Vector3(0, 0.1, 0)
		world.get_tree().create_timer(0.025 * i, false).timeout.connect( func():
			Vfx.burst(world.fx_root, at, (0.9 + 0.12 * stage) * sqrt(p.area_mult), Color(0.55, 0.85, 1.0))
			if i % 2 == 0:
				world.spawn_fx("lightning", at, 0.7 + 0.1 * stage, 0.8))
	var end: = p.position + dir * length + Vector3(0, 0.1, 0)
	Vfx.burst(world.fx_root, end, 2.0 + 0.4 * stage, col)
	Vfx.ring(world.fx_root, end, 3.0 + 0.5 * stage, Color(0.6, 0.9, 1.0), 0.5)
	if target != null and is_instance_valid(target):
		var hit_at: = target.position + Vector3(0, 0.8, 0)
		Vfx.ray_flash(world.fx_root, hit_at, world.camera.global_basis, Color(1.0, 0.95, 0.75), 1.0 + 0.16 * stage)
		Vfx.ring(world.fx_root, target.position + Vector3(0, 0.05, 0), 2.5 + 0.5 * stage, col, 0.6)
		world.spawn_fx("rl_banishing_buster", target.position, 1.0 + 0.15 * stage, 1.0)

	world.play_sound("final_strike", 0.0, 1.0, -1.0, true, true)
	world.play_sound("lightning_crash", 0.0, -2.0, 0.8, true, true)
	if stage >= 3:
		world.play_sound("asura", 0.0, -3.0, -1.0, true, true)
	world.shake(minf(1.0, 0.35 + 0.1 * stage))

	if stage >= GameData.U_OV_STAGES and p == world.player:
		world.hud.flash(Color(0.8, 0.92, 1.0), 0.35, 0.3)


	if p == world.player and not world.net.is_client() and not world._mvp_slow and Engine.time_scale > 0.2:
		var was: = Engine.time_scale
		Engine.time_scale = 0.04
		world.get_tree().create_timer(GameData.U_OV_HITSTOP + GameData.U_OV_HITSTOP_STAGE * stage, true, false, true).timeout.connect( func():
			if Engine.time_scale < 0.05:
				Engine.time_scale = was)





static func _flat_hit(world: World, p: Player, e: Enemy, amount: float, push: Vector3, main: bool, show: = true, 
		tag: = "u_overload", gold: = GameData.U_OV_GOLD, pale: = Color(0.7, 0.92, 1.0)) -> void :
	if e.dead:
		return
	if world.morroc != null and world.morroc.fighting() and world.morroc.walled(e):
		return


	if world.morroc != null and world.morroc.is_boss(e) and world.morroc.hero_mult(e) <= 0.0:
		return
	if e.prop == "":
		var dealt: = minf(amount, maxf(e.hp, 0.0))
		var mine: bool = p == world.player or world.heroes.size() < 2
		if mine:
			world._meter_add(tag, dealt, "neutral", true, e)
		if world.heroes.size() > 1 and p.slot < world.meter_hero.size():
			world._meter_put(world.meter_hero[p.slot], tag, dealt, "neutral", true, e, p.slot)
		if dealt >= e.hp and mine and world.meter.has(tag):
			world.meter[tag].kills = int(world.meter[tag].get("kills", 0)) + 1
	else:
		push = Vector3.ZERO
	e.hurt(amount, push)
	if e.def.get("dummy", false):
		e.hp = e.max_hp
	e.last_hit_by = p
	if e.special == "runner":
		world._runner_hit(e, amount)
	var top: float = e.visual.height() * ((e.visual as Node3D).scale.y if e.visual is Node3D else 1.0)
	if not show:
		pass
	elif main or e.is_boss:
		world.number(e.position + Vector3(0, top + 0.3, 0), Leaderboard.big_digits(amount), gold, true, true, false, 1.2, false, true, true)
	else:
		world.number(e.position + Vector3(0, top, 0), Leaderboard.big_digits(amount), pale)
	if e.hp <= 0.0 and not e.dead:
		world._kill(e)




static func _overload_warm(world: World, p: Player) -> void :
	var keep: = Vfx.dim
	Vfx.dim = 0.003
	var at: = p.position + Vector3(0, 0.9, 0)
	_overload_beam(world, at, Vector3.RIGHT, 1.0, GameData.U_OV_STAGES, p.position, GameData.U_OV_WIDTH)
	_overload_charge_fx(world, at, 1)
	if cannon(p) == "excal":
		var s: = _ex_sword(world, at, 1.0)
		_ex_alpha(0.003, s)
		world.get_tree().create_timer(0.2, false).timeout.connect(s.queue_free)
		for kind in ["gather", "burst", "rise", "trail"]:
			_ex_motes(world, at + Vector3(0, -50, 0), kind, 1, 0.1)
		_ex_beam(world, at + Vector3(0, -50, 0), Vector3.RIGHT, 2.0, 1.0, 70.0, 1, 0.1)
	Vfx.dim = keep

	p.uniq["ov_ghost"] = Engine.get_process_frames()
	draw_overload(p)




static func _overload_charge_fx(world: World, muzzle: Vector3, stage: int) -> void :
	var s: = Sprite3D.new()
	s.texture = RoAssets.radial(Color.WHITE, 64)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 20
	s.modulate = Color(0.75, 0.92, 1.0, 0.0)
	s.pixel_size = 0.02
	var mat_size: = 0.7 + 0.18 * stage
	world.fx_root.add_child(s)
	s.global_position = muzzle
	s.scale = Vector3.ONE * 0.2
	var tw: = s.create_tween()
	tw.tween_property(s, "modulate:a", 0.95 * Vfx.dim, GameData.U_OV_WINDUP * 0.6)
	tw.parallel().tween_property(s, "scale", Vector3.ONE * mat_size, GameData.U_OV_WINDUP).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "modulate:a", 0.0, 0.08)
	tw.tween_callback(s.queue_free)

	Vfx.converge(world.fx_root, muzzle, 1.2 + 0.15 * stage, Color(0.6, 0.9, 1.0, 0.9), GameData.U_OV_WINDUP)
	for i in 3:
		world.get_tree().create_timer(GameData.U_OV_WINDUP * i / 3.0, false).timeout.connect( func():
			_sparks(world, muzzle, Vector3.RIGHT, 0.5, Color(0.6, 0.9, 1.0)))








static func _overload_beam(world: World, from: Vector3, dir: Vector3, length: float, stage: int, ground: Vector3, half: float) -> void :
	var top: = stage >= GameData.U_OV_STAGES
	var w: = half * 2.0
	var life: = 0.7 + 0.08 * stage

	_ribbon(world, from, dir, length, w * 2.0, Color(GameData.U_OV_GOLD if top else Color(0.35, 0.7, 1.0), 0.45), false, life + 0.2)
	_ribbon(world, from, dir, length, w * 1.15, Color(0.15, 0.5, 1.0, 0.95), false, life)
	_ribbon(world, from, dir, length, w * 0.4, Color(0.5, 0.8, 1.0, 0.75), true, life * 0.9)
	_ribbon(world, from, dir, length, w * 0.1, Color(1.0, 1.0, 1.0, 0.95), true, life * 0.8)
	_helix(world, from, dir, length, Color(0.6, 0.9, 1.0, 0.95), 0.0, half * 0.45)
	_helix(world, from, dir, length, Color(0.85, 0.6, 1.0, 0.85) if not top else Color(1.0, 0.85, 0.4, 0.9), PI, half * 0.45)
	for i in 3 + stage / 2:
		_shock_ring(world, from + dir * (0.6 + i * 1.3), dir, (0.3 + i * 0.12) * half, Color(0.6, 0.9, 1.0, 0.7), 0.3 + i * 0.05)
	_sparks(world, from, dir, length, GameData.U_OV_GOLD if top else Color(0.6, 0.9, 1.0))
	_scorch(world, ground, dir, length)




static func _ribbon(world: World, from: Vector3, dir: Vector3, length: float, width: float, color: Color, additive: bool, life: float) -> void :
	var cam: = world.camera.global_position
	var to_cam: = (cam - (from + dir * length * 0.5)).normalized()
	var side: = dir.cross(to_cam)
	if side.length_squared() < 0.0001:
		side = Vector3.UP.cross(dir)
	side = side.normalized()
	var normal: = dir.cross(side).normalized()
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)


	var d: = minf(width * 0.6, length * 0.3)
	for seg in [[0.0, d, 0.0, 1.0], [d, length, 1.0, 1.0]]:
		var z0: float = seg[0]
		var z1: float = seg[1]
		var a0: float = seg[2]
		var a1: float = seg[3]
		var quad: = [Vector3(-0.5, 0, z0), Vector3(0.5, 0, z0), Vector3(0.5, 0, z1), Vector3(-0.5, 0, z1)]
		var uvs: = [Vector2(0, z0 / length), Vector2(1, z0 / length), Vector2(1, z1 / length), Vector2(0, z1 / length)]
		var alphas: = [a0, a0, a1, a1]
		for i in [0, 1, 2, 0, 2, 3]:
			st.set_color(Color(1, 1, 1, alphas[i]))
			st.set_uv(uvs[i])
			st.add_vertex(quad[i])
	var m: = MeshInstance3D.new()
	m.mesh = st.commit()
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.render_priority = 6 if additive else 5
	mat.albedo_texture = _band_texture()
	mat.vertex_color_use_as_albedo = true
	var k: = Vfx.add_k() if additive else 1.0
	mat.albedo_color = Color(color.r * k, color.g * k, color.b * k, color.a * Vfx.dim)
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	m.global_transform = Transform3D(Basis(side, normal, dir), from)
	m.scale = Vector3(width * 0.3, 1, 1)
	var tw: = m.create_tween()


	tw.pause()
	var tree: = world.get_tree()
	tree.process_frame.connect( func():
		tree.process_frame.connect( func():
			if tw.is_valid():
				tw.play(), CONNECT_ONE_SHOT), CONNECT_ONE_SHOT)
	tw.tween_property(m, "scale:x", width, 0.06).set_ease(Tween.EASE_OUT)
	tw.tween_property(m, "scale:x", width * 0.1, life).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, life).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(m.queue_free)


static var _band_tex: Texture2D




static func _band_texture() -> Texture2D:
	if _band_tex == null:
		var img: = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		for y in 64:
			var along: = 1.0 - smoothstep(0.82, 1.0, y / 63.0)
			for x in 64:
				var u: = absf(x / 63.0 - 0.5) * 2.0
				var a: = pow(clampf(1.0 - u, 0.0, 1.0), 1.4) * along
				img.set_pixel(x, y, Color(1, 1, 1, a))
		_band_tex = ImageTexture.create_from_image(img)
	return _band_tex





static func draw_overload(p: Player) -> void :
	var stage: = p.ov_stage
	var ghost: = int(p.uniq.get("ov_ghost", -1)) == Engine.get_process_frames()
	if ghost:
		stage = maxi(stage, 1)
	var nodes: Dictionary = p.uniq.get("ov_nodes", {})
	if stage <= 0:
		if not nodes.is_empty():
			for k in nodes:
				var n = nodes[k]
				if n is Node and is_instance_valid(n):
					(n as Node).queue_free()
				elif n is Array:
					for m in n:
						if is_instance_valid(m):
							m.queue_free()
			p.uniq.erase("ov_nodes")
		return
	var top: = stage >= GameData.U_OV_STAGES
	var excal: = _is_excal(p)
	var col: = GameData.U_OV_GOLD if top else GameData.U_OV_BLUE
	if excal:
		col = GameData.U_EX_GOLD if top else GameData.U_EX_PALE.lerp(GameData.U_EX_GOLD, float(stage) / GameData.U_OV_STAGES)
	if nodes.is_empty():
		nodes = {"orbs": []}
		p.uniq["ov_nodes"] = nodes
		var ring: = Sprite3D.new()
		ring.texture = Vfx.ring_texture()
		ring.shaded = false
		ring.no_depth_test = false
		ring.render_priority = 4
		ring.pixel_size = 2.6 / float(ring.texture.get_width())
		ring.rotation_degrees.x = -90.0
		ring.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		p.add_child(ring)
		ring.position = Vector3(0, 0.06, 0)
		nodes["ring"] = ring
	var orbs: Array = nodes.orbs
	while orbs.size() < stage:


		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 64)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 20
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		s.pixel_size = 0.5 / 64.0
		var core: = Sprite3D.new()
		core.texture = s.texture
		core.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		core.shaded = false
		core.no_depth_test = true
		core.render_priority = 21
		core.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		core.pixel_size = 0.2 / 64.0
		s.add_child(core)
		s.add_child(Player._glow_quad(1.0, Color(col, 0.75)))
		p.add_child(s)
		orbs.append(s)
	while orbs.size() > stage:
		orbs.pop_back().queue_free()
	var t: = Time.get_ticks_msec() / 1000.0
	var h: = p.visual.height() if p.visual != null else 1.6
	var spin: = 1.6 + 0.5 * stage
	for i in orbs.size():
		var s: Sprite3D = orbs[i]
		var a: = t * spin + TAU * i / maxf(1.0, orbs.size())
		if excal:


			var aa: = t * (0.7 + 0.15 * stage) + TAU * i / maxf(1.0, orbs.size())
			s.position = RoVisual.lift + Vector3(cos(aa) * 0.5, h * 1.08 + sin(t * 3.0 + i) * 0.05, sin(aa) * 0.5)
			s.scale = Vector3.ONE * (0.75 + 0.25 * sin(t * 4.0 + i * 0.8))
		else:
			s.position = RoVisual.lift + Vector3(cos(a) * 0.95, h * 0.62 + sin(a * 2.0) * 0.12, sin(a) * 0.95)
		s.modulate = Color(col.darkened(0.1), 0.95 * Vfx.dim)
		(s.get_child(0) as Sprite3D).modulate = Color(1.0, 1.0, 1.0, Vfx.dim)
		var g: MeshInstance3D = s.get_child(1)
		(g.material_override as StandardMaterial3D).albedo_color = Color(col, 0.6 + (0.3 * sin(t * 6.0 + i) if top else 0.0))
	var ring: Sprite3D = nodes.ring
	ring.rotation_degrees.y = fmod(t * 90.0, 360.0)
	var pulse: = 0.5 + 0.5 * sin(t * (7.0 if top else 3.0))
	ring.modulate = Color(col, (0.45 + 0.1 * stage + (0.2 * pulse if top else 0.0)) * Vfx.dim)
	ring.scale = Vector3.ONE * (0.8 + 0.08 * stage + (0.06 * pulse if top else 0.0))

	if ghost:
		ring.modulate.a = 0.0
		for s in orbs:
			(s as Sprite3D).modulate.a = 0.0
			((s as Sprite3D).get_child(0) as Sprite3D).modulate.a = 0.0
			((s.get_child(1) as MeshInstance3D).material_override as StandardMaterial3D).albedo_color.a = 0.0






static func _excal_level(world: World, p: Player, stage: int) -> void :
	var top: = stage >= GameData.U_OV_STAGES
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.0 + 0.2 * stage, GameData.U_EX_GOLD if top else GameData.U_EX_PALE, 0.5)
	if top:
		Vfx.beam_flash(world.fx_root, p.position, GameData.U_EX_GOLD, 7.0, 1.2)
		world.play_sound("angelus", 0.2, -3.0, -1.0, true, true)
	else:
		world.play_sound("angelus", 0.2, -9.0, 0.85 + 0.06 * stage)






static func excalibur_fire(world: World, p: Player) -> void :
	if p.ov_stage < 1:
		_say(world, p, TranslationServer.translate("Cargando..."), "say_ov", 0.8)
		return
	_ex_bank(world, p, true)
	var stage: = p.ov_stage
	var power: = overload_power(p, stage)
	p.uniq["ov_energy"] = 0.0
	p.uniq["ov_t"] = 0.0
	p.ov_stage = 0
	p.ov_text = ""
	var dir: = _ex_aim(world, p, stage)
	p.facing = dir
	p.visual.face(dir)
	p.visual.play(RoVisual.PC_CAST, false, true)
	p._attack_anim = GameData.U_EX_WINDUP + 0.4
	var h: = p.visual.height() if p.visual != null else 1.6
	_excal_charge_fx(world, p.position, dir, stage, h)
	if world.net.recording():
		world.net.record(["ov", "excharge", p.position, dir, h, stage])
	world.label_over(p, "Ex...", GameData.U_EX_PALE)
	world.get_tree().create_timer(GameData.U_EX_WINDUP, false).timeout.connect( func():
		if not is_instance_valid(p) or p.downed or not world.running:
			return

		var d: = _ex_aim(world, p, stage)
		p.facing = d
		p.visual.face(d)
		p.visual.play(int(p.look.get("attack", RoVisual.PC_ATTACK)), false, true)
		_excal_shot(world, p, d, power, stage))



static func _ex_half(d: float, k: float) -> float:
	return minf(GameData.U_EX_HALF + GameData.U_EX_FLARE * maxf(0.0, d), GameData.U_EX_HALF_MAX) * k


static func _ex_k(p: Player, stage: int) -> float:
	return (0.75 + 0.05 * stage) * p.area_mult





static func _ex_aim(world: World, p: Player, stage: int) -> Vector3:
	var best: = p.facing * Vector3(1, 0, 1)
	best = best.normalized() if best.length_squared() > 0.0001 else Vector3.FORWARD
	var near: Array = world.enemies_in_radius(p.position, GameData.U_EX_AIM_RANGE).filter( func(e): return not e.dead and e.prop == "")
	if near.is_empty():
		return best



	var boss: Enemy = null
	for e in near:
		if e.is_boss and (boss == null or e.max_hp > boss.max_hp):
			boss = e
	if boss != null:
		var to_boss: Vector3 = (boss.position - p.position) * Vector3(1, 0, 1)
		if to_boss.length_squared() > 0.0001:
			return to_boss.normalized()
	var k: = _ex_k(p, stage)
	var best_score: = 0.0
	for i in GameData.U_EX_AIM_DIRS:
		var a: = TAU * i / float(GameData.U_EX_AIM_DIRS)
		var d: = Vector3(cos(a), 0, sin(a))
		var score: = 0.0
		for e in near:
			var to: Vector3 = (e.position - p.position) * Vector3(1, 0, 1)
			var along: = to.dot(d)
			if along < -0.5:
				continue
			if (to - d * along).length() <= _ex_half(along, k) + e.radius:
				if e.def.get("mvp", false):
					score += 100.0
				elif e.is_boss:
					score += 20.0
				elif e.def.get("elite", false) or e.feroz:
					score += 4.0
				else:
					score += 1.0
		if score > best_score:
			best_score = score
			best = d
	return best








static func _ex_local(world: World, on: bool) -> void :
	Vfx._quiet = on
	world._fx_local = on
	world._sound_local = on


static func _excal_charge_fx(world: World, at: Vector3, dir: Vector3, stage: int, h: float) -> void :
	_ex_local(world, true)
	_excal_charge_draw(world, at, dir, stage, h)
	_ex_local(world, false)


static func _excal_charge_draw(world: World, at: Vector3, dir: Vector3, stage: int, h: float) -> void :
	var w: = GameData.U_EX_WINDUP
	Vfx.beam_flash(world.fx_root, at, GameData.U_EX_GOLD, 9.0 + 0.5 * stage, w + 0.35)
	Vfx.magic_circle(world.fx_root, at, 1.8 + 0.15 * stage, Color(GameData.U_EX_GOLD, 0.85), w + 0.35)
	for i in 2:
		Vfx.converge(world.fx_root, at + Vector3(0, 0.05, 0), 2.6 + 0.2 * stage + i, Color(GameData.U_EX_GOLD, 0.75), w)
	var tip: = at + RoVisual.world_lift() + Vector3(0, h * 1.25, 0) - dir * 0.15
	var s: = Sprite3D.new()
	s.texture = RoAssets.radial(Color.WHITE, 64)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 20
	s.modulate = Color(GameData.U_EX_PALE, 0.0)
	s.pixel_size = 0.02
	world.fx_root.add_child(s)
	s.global_position = tip
	s.scale = Vector3.ONE * 0.2
	var tw: = s.create_tween()
	tw.tween_property(s, "modulate:a", 0.95 * Vfx.dim, w * 0.5)
	tw.parallel().tween_property(s, "scale", Vector3.ONE * (0.8 + 0.12 * stage), w).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "modulate:a", 0.0, 0.1)
	tw.tween_callback(s.queue_free)
	Vfx.converge(world.fx_root, tip, 1.0 + 0.1 * stage, Color(GameData.U_EX_GOLD, 0.9), w)
	for i in 3:
		world.get_tree().create_timer(w * i / 3.0, false).timeout.connect( func():
			_ex_local(world, true)
			_sparks(world, tip, Vector3.RIGHT, 0.6, GameData.U_EX_GOLD)
			_ex_local(world, false))




	var big: = _ex_sword_h(stage)
	var sky: = at + Vector3(0, big * 0.5 + 7.0, 0) - dir * 0.6
	var hold: = at + Vector3(0, big * 0.5 + 2.6, 0) - dir * 0.6
	var sword: = _ex_sword(world, sky, big)
	var stw: = sword.create_tween()
	stw.tween_property(sword, "global_position", hold, w).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	stw.parallel().tween_method(_ex_alpha.bind(sword), 0.0, 1.0, w * 0.6)
	stw.tween_method(_ex_alpha.bind(sword), 1.0, 0.0, 0.06)
	stw.tween_callback(sword.queue_free)
	_ex_motes(world, hold, "gather", stage, w)
	_ex_light(world, hold, 3.5 + 0.3 * stage, 9.0, w, 0.0, 0.1)
	world.play_sound("angelus", 0.0, -2.0, 0.9, true, true)
	world.get_tree().create_timer(w * 0.55, false).timeout.connect( func():
		_ex_local(world, true)
		world.play_sound("holy_cross", 0.0, -4.0, 1.1, true, true)
		_ex_local(world, false))





static func _excal_shot(world: World, p: Player, dir: Vector3, power: float, stage: int) -> void :
	var length: = _ov_length(world, p.position, dir)
	var k: = _ex_k(p, stage)
	var speed: = maxf(GameData.U_EX_SPEED, length / GameData.U_EX_TRAVEL_MAX)
	var from: = p.position + Vector3(0, 0.1, 0)

	var waves: = {}
	var reach: = _ex_half(length, k)
	for e in world.enemies_in_radius(p.position + dir * length * 0.5, length * 0.5 + reach + 1.0):
		if e.dead:
			continue
		var to: Vector3 = (e.position - p.position) * Vector3(1, 0, 1)
		var along: = to.dot(dir)
		if along < -0.5 or along > length:
			continue
		if (to - dir * along).length() <= _ex_half(along, k) + e.radius:
			var b: = int(maxf(0.0, along) / speed / 0.04)
			if not waves.has(b):
				waves[b] = []
			(waves[b] as Array).append(e)
	_excal_wave_fx(world, from, dir, length, stage, k, speed)
	if world.net.recording():
		world.net.record(["ov", "exwave", from, dir, length, stage, k, speed])
	var shown: = [0]
	var ex_scale: = maxf(1.0, p.dmg_mult * p.skill_mult_for("u_excalibur"))
	for b in waves:
		var list: Array = waves[b]
		world.get_tree().create_timer(b * 0.04, false).timeout.connect( func():
			if not is_instance_valid(p) or not world.running:
				return
			var keep: = [world.damage_tag, world.damage_by]
			world.damage_tag = "u_excalibur"
			world.damage_by = p
			for e in list:
				if not is_instance_valid(e) or e.dead:
					continue
				var big: bool = e.is_boss
				_flat_hit(world, p, e, power, dir * (5.0 + stage), big, big or shown[0] < GameData.U_OV_NUMBERS, 
					"u_excalibur", GameData.U_EX_GOLD, GameData.U_EX_PALE)






				if not e.dead:
					world.dots.burn_on(world, e, power * GameData.U_EX_BURN / ex_scale, "u_excalibur", p)
				if not big:
					shown[0] += 1
			_restore(world, keep))
	world.label_over(p, "EXCALIBUR!", GameData.U_EX_GOLD)



	world.play_sound("excaliblast", 0.0, 2.0, 1.06 - 0.02 * stage, false, true)
	world.shake(minf(1.0, 0.5 + 0.08 * stage))
	if p == world.player:
		world.hud.flash(Color(1.0, 0.93, 0.7), 0.15 + 0.03 * stage, 0.25 + 0.02 * stage)
	if p == world.player and not world.net.is_client() and not world._mvp_slow and Engine.time_scale > 0.2:
		var was: = Engine.time_scale
		Engine.time_scale = 0.05
		world.get_tree().create_timer(GameData.U_OV_HITSTOP + GameData.U_OV_HITSTOP_STAGE * stage, true, false, true).timeout.connect( func():
			if Engine.time_scale < 0.06:
				Engine.time_scale = was)








static func _excal_wave_fx(world: World, from: Vector3, dir: Vector3, length: float, stage: int, k: float, speed: float) -> void :
	_ex_local(world, true)
	_excal_wave_draw(world, from, dir, length, stage, k, speed)
	_ex_local(world, false)


static func _excal_wave_draw(world: World, from: Vector3, dir: Vector3, length: float, stage: int, k: float, speed: float) -> void :
	var top: = stage >= GameData.U_OV_STAGES
	var gold: = GameData.U_EX_GOLD
	var pale: = GameData.U_EX_PALE
	var seg: = GameData.U_EX_SEGMENT
	var n: = maxi(1, ceili(length / seg))

	var sword_every: = maxi(1, ceili(float(n) / GameData.U_EX_SWORDS))
	var life: = 0.75 + 0.05 * stage



	var big: = _ex_sword_h(stage)
	var ground: = Vector3(from.x, from.y - 0.1, from.z) + dir * 1.4
	var sword: = _ex_sword(world, ground + Vector3(0, big * 0.5 + 2.6, 0), big)
	_ex_alpha(1.0, sword)
	var tw: = sword.create_tween()
	tw.tween_property(sword, "global_position:y", ground.y + big * 0.5 - 1.3, 0.09).set_ease(Tween.EASE_IN)
	tw.tween_method(_ex_sweep.bind(sword), 0.0, 1.0, 0.3)
	tw.tween_interval(0.2 + 0.03 * stage)
	tw.tween_property(sword, "global_position:y", ground.y + big * 0.5 + 1.5, 0.55).set_ease(Tween.EASE_IN)
	tw.parallel().tween_method(_ex_alpha.bind(sword), 1.0, 0.0, 0.55)
	tw.tween_callback(sword.queue_free)
	world.get_tree().create_timer(0.09, false).timeout.connect( func():
		_ex_local(world, true)
		Vfx.ring(world.fx_root, ground, 3.0 + 0.3 * stage, pale, 0.5)
		Vfx.ring(world.fx_root, ground, 5.0 + 0.5 * stage, gold, 0.75)
		Vfx.quake(world.fx_root, ground, 2.5 + 0.25 * stage, gold)
		Vfx.burst(world.fx_root, ground, 2.0 + 0.3 * stage, pale)
		Vfx.ray_flash(world.fx_root, ground + Vector3(0, 1.5, 0), world.camera.global_basis, gold, 1.6 + 0.15 * stage)
		Vfx.beam_flash(world.fx_root, ground, pale, 12.0 + stage, 0.8)
		world.spawn_fx("holyhit", ground + Vector3(0, 0.6, 0), 1.6 + 0.1 * stage, 1.0)
		_ex_motes(world, ground + Vector3(0, 0.3, 0), "burst", stage)
		_ex_motes(world, ground, "rise", stage)
		_ex_light(world, ground + Vector3(0, 2.0, 0), 7.0 + 0.5 * stage, 12.0, 0.04, 0.12, 0.9)
		_ex_local(world, false))


	var travel: = length / speed
	var runner: = _ex_motes(world, from, "trail", stage, travel)
	var lamp: = _ex_light(world, from + Vector3(0, 1.5, 0), 3.0 + 0.2 * stage, 7.0, 0.05, travel, 0.4)
	for node in [runner, lamp]:
		var rt: = (node as Node3D).create_tween()
		rt.tween_property(node, "global_position", from + dir * length + Vector3(0, 1.5 if node == lamp else 0.0, 0), travel)
	Vfx.arc(world.fx_root, from, dir, 2.4 * sqrt(k), 2.6, pale)
	Vfx.burst(world.fx_root, from + dir * 0.8, 1.2 + 0.2 * stage, gold)
	Vfx.ray_flash(world.fx_root, from + Vector3(0, 1.0, 0), world.camera.global_basis, pale, 0.9 + 0.1 * stage)
	_ex_beam(world, from, dir, length, k, speed, stage, life)
	for i in n:
		var d0: = i * seg
		var d1: = minf(length, d0 + seg)
		var a: Vector3 = from + dir * d0
		var w0: = _ex_half(d0, k) * 2.0
		var w1: = _ex_half(d1, k) * 2.0
		world.get_tree().create_timer(d0 / speed, false).timeout.connect( func():
			_ex_local(world, true)
			if i % 3 == 0:
				Vfx.ray_flash(world.fx_root, a + Vector3(0, 0.7, 0), world.camera.global_basis, pale, 0.3 + 0.03 * stage)
			if i % 2 == 0:
				Vfx.beam_flash(world.fx_root, a, gold if not top else pale, 2.5 + w0 * 0.6, 0.7)
			if i % 3 == 1:
				world.spawn_fx("holyhit", a, 0.7 + 0.05 * stage, 0.8)


			if i % sword_every == 0:
				for j in (2 if stage >= 5 else 1):
					var off: = Vector3.UP.cross(dir).normalized() * randf_range(-0.42, 0.42) * w0
					_ex_rising_sword(world, a + dir * randf_range(0.0, d1 - d0) + off, 1.6 + 0.12 * stage + randf_range(0.0, 0.6))
			_ex_local(world, false))
	var end: = from + dir * length
	var w_end: = _ex_half(length, k)
	world.get_tree().create_timer(length / speed, false).timeout.connect( func():
		_ex_local(world, true)

		var cross_l: = 3.0 + w_end * 1.2
		var side: = Vector3.UP.cross(dir).normalized()
		_ex_band(world, end - dir * cross_l * 0.5, dir, cross_l, 1.1, 1.1, Color(pale, 0.9), true, 0.9)
		_ex_band(world, end - side * cross_l * 0.4, side, cross_l * 0.8, 1.1, 1.1, Color(pale, 0.9), true, 0.9)
		_ex_rising_sword(world, end, 3.0 + 0.2 * stage)
		_ex_motes(world, end + Vector3(0, 0.3, 0), "burst", stage)
		Vfx.burst(world.fx_root, end, 1.5 + w_end * 0.5, gold)
		Vfx.ring(world.fx_root, end, 2.0 + w_end, pale, 0.55)
		Vfx.beam_flash(world.fx_root, end, gold, 8.0 + stage * 0.5, 1.0)
		_sparks(world, end, dir, 1.5, gold)
		_ex_local(world, false))


static var _ex_beam_shader: Shader








static func _ex_beam(world: World, from: Vector3, dir: Vector3, length: float, k: float, speed: float, stage: int, life: float) -> void :
	if _ex_beam_shader == null:
		_ex_beam_shader = Shader.new()
		_ex_beam_shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled;
uniform vec4 gold : source_color = vec4(1.0, 0.84, 0.38, 1.0);
uniform vec4 pale : source_color = vec4(1.0, 0.96, 0.8, 1.0);
uniform float front = 0.0;
uniform float speed = 70.0;
uniform float life = 1.0;
uniform float fade = 0.0;
uniform float alpha = 1.0;
uniform float boost = 1.0;
""" + _EX_NOISE + "\nvoid fragment() {\n\tfloat d = UV.y;\n\tif (d > front) {\n\t\tdiscard;\n\t}\n\tfloat u = abs(UV.x * 2.0 - 1.0);\n\t// Seconds since the front passed here: it cools and narrows.\n\tfloat age = (front - d) / speed + fade * life;\n\tfloat heat = exp(-age * 3.0 / life);\n\tfloat width = mix(1.0, 0.45, clamp(age / life, 0.0, 1.0));\n\tfloat uu = u / width;\n\tif (uu > 1.0) {\n\t\tdiscard;\n\t}\n\t// Light streaming forward, fast, in long streaks.\n\tfloat n = fbm(vec2(UV.x * 5.0, d * 0.35 - TIME * 9.0));\n\tfloat streak = smoothstep(0.45, 0.85, fbm(vec2(UV.x * 11.0, d * 0.12 - TIME * 14.0)));\n\tfloat body = pow(smoothstep(1.0, 0.3, uu), 1.5) * (0.5 + 0.7 * n);\n\tfloat heart = pow(clamp(1.0 - uu * 2.6, 0.0, 1.0), 1.6) * (0.8 + 0.5 * n);\n\tfloat edge = smoothstep(0.1, 0.0, abs(uu - 0.88)) * 0.9;\n\tfloat lead = smoothstep(2.2, 0.0, front - d) * smoothstep(1.0, 0.2, uu);\n\tvec3 c = gold.rgb * (body * 0.6 + streak * 0.5) + pale.rgb * (heart * 1.4 + edge * 0.8 + lead * 1.2);\n\tALBEDO = c * boost;\n\t// (The front's very edge soft, not a cut.)\n\tfloat tip = smoothstep(0.0, 0.7, front - d);\n\tALPHA = clamp((body * 0.4 + heart * 0.9 + edge * 0.6 + streak * 0.25 + lead * 0.6) * heat * tip * alpha, 0.0, 1.0);\n}\n"






























	var side: = Vector3.UP.cross(dir).normalized()
	var rows: = clampi(ceili(length), 2, 400)
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for r in rows:
		var da: = length * r / rows
		var db: = length * (r + 1) / rows
		var ha: = _ex_half(da, k) * 1.3
		var hb: = _ex_half(db, k) * 1.3
		var quad: = [Vector3( - ha, 0, da), Vector3(ha, 0, da), Vector3(hb, 0, db), Vector3( - hb, 0, db)]
		var uvs: = [Vector2(0, da), Vector2(1, da), Vector2(1, db), Vector2(0, db)]
		for i in [0, 1, 2, 0, 2, 3]:
			st.set_uv(uvs[i])
			st.add_vertex(quad[i])
	var m: = MeshInstance3D.new()
	m.mesh = st.commit()
	var mat: = ShaderMaterial.new()
	mat.shader = _ex_beam_shader
	mat.set_shader_parameter("speed", speed)
	mat.set_shader_parameter("life", life)
	mat.set_shader_parameter("alpha", Vfx.dim)
	mat.set_shader_parameter("boost", Vfx.add_k() * (1.0 + 0.04 * stage))
	mat.render_priority = 6
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	m.global_transform = Transform3D(Basis(side, Vector3.UP, dir), from + Vector3(0, 0.02, 0))
	var travel: = length / speed
	var tw: = m.create_tween()
	tw.tween_method( func(v: float): mat.set_shader_parameter("front", v), 0.0, length, travel)
	tw.tween_method( func(v: float): mat.set_shader_parameter("fade", v), 0.0, 1.0, life)
	tw.tween_callback(m.queue_free)



static func _ex_sword_h(stage: int) -> float:
	return 6.5 + 0.45 * stage


static var _ex_sword_shader: Shader
static var _ex_halo_shader: Shader









static func _ex_sword(world: World, at: Vector3, height: float) -> MeshInstance3D:
	if _ex_sword_shader == null:
		_ex_sword_shader = Shader.new()
		_ex_sword_shader.code = """
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform sampler2D shape : source_color, filter_nearest;
uniform float alpha = 0.0;
uniform float sweep = -1.0;
uniform float hot = 1.0;
""" + _EX_NOISE + "\nvoid vertex() {\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0),\n\t\tvec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);\n\tMODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);\n}\nvoid fragment() {\n\tvec4 s = texture(shape, UV);\n\tif (s.a < 0.02) {\n\t\tdiscard;\n\t}\n\t// Light flowing from the hilt to the point, through the blade's noise.\n\tfloat n = fbm(vec2(UV.x * 4.0, UV.y * 7.0 - TIME * 2.6));\n\tfloat heart = smoothstep(0.82, 0.98, min(s.r, min(s.g, s.b)));\n\tfloat glint = sweep >= 0.0 ? smoothstep(0.07, 0.0, abs(UV.y - sweep)) : 0.0;\n\tvec3 c = s.rgb * (0.8 + 0.45 * n) + vec3(1.0, 0.95, 0.8) * (heart * hot * (0.5 + 0.9 * n) + glint * 2.2 * s.a);\n\tALBEDO = c;\n\tALPHA = s.a * alpha;\n}\n"



















		_ex_halo_shader = Shader.new()
		_ex_halo_shader.code = "\nshader_type spatial;\nrender_mode unshaded, blend_add, cull_disabled, depth_draw_never, depth_test_disabled;\nuniform vec4 tint : source_color = vec4(1.0, 0.84, 0.38, 1.0);\nuniform float alpha = 0.0;\nvoid vertex() {\n\tMODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0),\n\t\tvec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);\n\tMODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);\n}\nvoid fragment() {\n\tvec2 c = (UV - 0.5) * 2.0;\n\tfloat d = length(c);\n\tfloat glow = pow(clamp(1.0 - d, 0.0, 1.0), 2.4);\n\tfloat core = pow(clamp(1.0 - length(c * vec2(2.6, 1.0)), 0.0, 1.0), 1.5);\n\tfloat a = atan(c.y, c.x);\n\tfloat rays = pow(abs(sin(a * 5.0 + TIME * 0.9)), 18.0) * smoothstep(1.0, 0.15, d);\n\tALBEDO = tint.rgb * (glow * 0.9 + core * 0.9 + rays * 0.7);\n\tALPHA = clamp((glow * 0.6 + core * 0.7 + rays * 0.5) * alpha * tint.a, 0.0, 1.0);\n}\n"




















	var q: = QuadMesh.new()
	q.size = Vector2(height * 0.25, height)
	var m: = MeshInstance3D.new()
	m.mesh = q
	var mat: = ShaderMaterial.new()
	mat.shader = _ex_sword_shader
	mat.set_shader_parameter("shape", _ex_sword_texture())
	mat.render_priority = 9
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var hq: = QuadMesh.new()
	hq.size = Vector2(height * 0.8, height * 1.25)
	var h: = MeshInstance3D.new()
	h.mesh = hq
	var hm: = ShaderMaterial.new()
	hm.shader = _ex_halo_shader
	var kk: = Vfx.add_k()
	var gold: = GameData.U_EX_GOLD
	hm.set_shader_parameter("tint", Color(gold.r * kk, gold.g * kk, gold.b * kk, 1.0))
	hm.render_priority = 8
	h.material_override = hm
	h.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.add_child(h)
	world.fx_root.add_child(m)
	m.global_position = at
	return m



static func _ex_alpha(v: float, m: MeshInstance3D) -> void :
	if not is_instance_valid(m):
		return
	(m.material_override as ShaderMaterial).set_shader_parameter("alpha", v * Vfx.dim)
	var h: = m.get_child(0) as MeshInstance3D
	(h.material_override as ShaderMaterial).set_shader_parameter("alpha", v * 0.75 * Vfx.dim)



static func _ex_sweep(v: float, m: MeshInstance3D) -> void :
	if is_instance_valid(m):
		(m.material_override as ShaderMaterial).set_shader_parameter("sweep", v)


const _EX_NOISE: = "\nfloat hash(vec2 p) {\n\tvec3 p3 = fract(vec3(p.xyx) * 0.1031);\n\tp3 += dot(p3, p3.yzx + 33.33);\n\treturn fract((p3.x + p3.y) * p3.z);\n}\nfloat noise(vec2 p) {\n\tvec2 i = floor(p);\n\tvec2 f = fract(p);\n\tf = f * f * (3.0 - 2.0 * f);\n\treturn mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);\n}\nfloat fbm(vec2 p) {\n\tfloat s = 0.0;\n\tfloat a = 0.5;\n\tfor (int k = 0; k < 3; k++) {\n\t\ts += a * noise(p);\n\t\tp = p * 2.03 + vec2(1.7, 9.2);\n\t\ta *= 0.5;\n\t}\n\treturn s / 0.875;\n}\n"


























static func _ex_rising_sword(world: World, at: Vector3, height: float) -> void :
	var y0: = at.y - height * 0.5
	var y1: = at.y + height * 0.32
	var m: = _ex_sword(world, Vector3(at.x, y0, at.z), height)
	var tw: = m.create_tween()
	tw.tween_property(m, "global_position:y", y1, 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_method(_ex_alpha.bind(m), 0.0, 0.9, 0.06)
	tw.tween_interval(0.18)
	tw.tween_method(_ex_alpha.bind(m), 0.9, 0.0, 0.45).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(m, "global_position:y", y1 + 0.6, 0.45)
	tw.tween_callback(m.queue_free)


static var _ex_mote_mat: StandardMaterial3D
static var _ex_mote_ramp: Gradient








static func _ex_motes(world: World, at: Vector3, kind: String, stage: int, life: = 0.0) -> CPUParticles3D:
	if _ex_mote_mat == null:
		_ex_mote_mat = StandardMaterial3D.new()
		_ex_mote_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_ex_mote_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_ex_mote_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		_ex_mote_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		_ex_mote_mat.vertex_color_use_as_albedo = true
		_ex_mote_mat.no_depth_test = true
		_ex_mote_mat.render_priority = 10
		_ex_mote_mat.albedo_texture = RoAssets.radial(Color.WHITE, 32)
		_ex_mote_ramp = Gradient.new()
		_ex_mote_ramp.offsets = PackedFloat32Array([0.0, 0.25, 1.0])
		_ex_mote_ramp.colors = PackedColorArray([Color(1, 1, 0.92, 1), Color(1.0, 0.84, 0.38, 0.95), Color(1.0, 0.7, 0.2, 0)])
	var cp: = CPUParticles3D.new()
	cp.emitting = false
	var quad: = QuadMesh.new()

	quad.size = Vector2(0.14, 0.14)
	quad.material = _ex_mote_mat
	cp.mesh = quad
	cp.color_ramp = _ex_mote_ramp
	cp.local_coords = false
	var more: = 1.0 + 0.08 * stage
	match kind:
		"gather":
			cp.amount = int(40 * more)
			cp.lifetime = 0.6
			cp.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE_SURFACE
			cp.emission_sphere_radius = 4.5
			cp.gravity = Vector3.ZERO
			cp.radial_accel_min = -16.0
			cp.radial_accel_max = -10.0
			cp.tangential_accel_min = 4.0
			cp.tangential_accel_max = 8.0
			cp.scale_amount_min = 0.48
			cp.scale_amount_max = 0.96
		"burst":
			cp.one_shot = true
			cp.explosiveness = 1.0
			cp.amount = int(60 * more)
			cp.lifetime = 0.9
			cp.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
			cp.emission_sphere_radius = 0.5
			cp.direction = Vector3.UP
			cp.spread = 80.0
			cp.initial_velocity_min = 6.0
			cp.initial_velocity_max = 13.0
			cp.gravity = Vector3(0, -12.0, 0)
			cp.damping_min = 1.5
			cp.damping_max = 3.0
			cp.scale_amount_min = 0.42
			cp.scale_amount_max = 0.84
		"rise":
			cp.one_shot = true
			cp.explosiveness = 0.5
			cp.amount = int(36 * more)
			cp.lifetime = 1.5
			cp.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
			cp.emission_box_extents = Vector3(1.8, 0.1, 1.8)
			cp.direction = Vector3.UP
			cp.spread = 15.0
			cp.initial_velocity_min = 1.5
			cp.initial_velocity_max = 4.0
			cp.gravity = Vector3(0, 0.6, 0)
			cp.scale_amount_min = 0.48
			cp.scale_amount_max = 1.08
		_:
			cp.amount = int(70 * more)
			cp.lifetime = 0.9
			cp.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
			cp.emission_box_extents = Vector3(1.6 + 0.2 * stage, 0.1, 1.2)
			cp.direction = Vector3.UP
			cp.spread = 25.0
			cp.initial_velocity_min = 1.0
			cp.initial_velocity_max = 3.5
			cp.gravity = Vector3(0, 0.8, 0)
			cp.scale_amount_min = 0.42
			cp.scale_amount_max = 0.9
	world.fx_root.add_child(cp)
	cp.global_position = at
	cp.emitting = true
	var stop: = life if kind in ["gather", "trail"] else 0.0
	world.get_tree().create_timer(stop, false).timeout.connect( func():
		if is_instance_valid(cp):
			cp.emitting = false)
	world.get_tree().create_timer(stop + cp.lifetime + 0.2, false).timeout.connect( func():
		if is_instance_valid(cp):
			cp.queue_free())
	return cp




static func _ex_light(world: World, at: Vector3, energy: float, reach: float, rise: float, hold: float, fade: float) -> OmniLight3D:
	var l: = OmniLight3D.new()
	l.light_color = GameData.U_EX_GOLD
	l.omni_range = reach
	l.light_energy = 0.0
	l.shadow_enabled = false
	world.fx_root.add_child(l)
	l.global_position = at
	var tw: = l.create_tween()
	tw.tween_property(l, "light_energy", energy * Vfx.light_k() * Vfx.dim, maxf(0.01, rise))
	if hold > 0.0:
		tw.tween_interval(hold)
	tw.tween_property(l, "light_energy", 0.0, maxf(0.01, fade))
	tw.tween_callback(l.queue_free)
	return l


static var _ex_sword_tex: Texture2D




static func _ex_sword_texture() -> Texture2D:
	if _ex_sword_tex != null:
		return _ex_sword_tex
	var w: = 64
	var h: = 256
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var gold: = Color(1.0, 0.82, 0.32)
	var deep: = Color(0.8, 0.56, 0.16)
	var pale: = Color(1.0, 0.98, 0.9)
	for y in h:
		for x in w:
			var c: = Color(0, 0, 0, 0)
			var dx: = absf(x + 0.5 - w * 0.5)
			if y < 15:
				var r: = Vector2(x + 0.5 - w * 0.5, y + 0.5 - 7.5).length()
				if r < 7.0:
					c = pale if r < 3.2 else (gold if r < 5.8 else deep)
			elif y < 46:
				if dx < 4.5:
					c = Color(0.42, 0.26, 0.1) if (y / 3) % 2 == 0 else Color(0.6, 0.4, 0.16)
			elif y < 58:
				var half: = 31.0 - absf(y - 52.0) * 1.2
				if dx < half:
					c = gold if absf(y - 52.0) < 3.0 else deep
					if dx < 5.0 and absf(y - 52.0) < 3.0:
						c = pale
			else:
				var t: = float(y - 58) / float(h - 58)
				var half: = 11.5 * (1.0 if t < 0.8 else (1.0 - t) / 0.2)
				if dx < half:
					var u: = dx / maxf(half, 0.001)
					c = pale.lerp(gold, smoothstep(0.2, 0.9, u))
					if u > 0.86:
						c = deep
			img.set_pixel(x, y, c)
	_ex_sword_tex = ImageTexture.create_from_image(img)
	return _ex_sword_tex





static func _ex_band(world: World, from: Vector3, dir: Vector3, length: float, w0: float, w1: float, color: Color, additive: bool, life: float) -> void :
	var side: = Vector3.UP.cross(dir).normalized()
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var quad: = [Vector3(-0.5 * w0, 0, 0), Vector3(0.5 * w0, 0, 0), Vector3(0.5 * w1, 0, length), Vector3(-0.5 * w1, 0, length)]
	var uvs: = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	for i in [0, 1, 2, 0, 2, 3]:
		st.set_color(Color.WHITE)
		st.set_uv(uvs[i])
		st.add_vertex(quad[i])
	var m: = MeshInstance3D.new()
	m.mesh = st.commit()
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.render_priority = 6 if additive else 5
	mat.albedo_texture = _ex_band_texture()
	mat.vertex_color_use_as_albedo = true
	var kk: = Vfx.add_k() if additive else 1.0
	mat.albedo_color = Color(color.r * kk, color.g * kk, color.b * kk, color.a * Vfx.dim)
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	m.global_transform = Transform3D(Basis(side, Vector3.UP, dir), from)
	m.scale = Vector3(0.35, 1, 1)
	var tw: = m.create_tween()
	tw.tween_property(m, "scale:x", 1.0, 0.07).set_ease(Tween.EASE_OUT)
	tw.tween_property(m, "scale:x", 0.2, life).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.parallel().tween_property(mat, "albedo_color:a", 0.0, life).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(m.queue_free)


static var _ex_band_tex: Texture2D




static func _ex_band_texture() -> Texture2D:
	if _ex_band_tex == null:
		var img: = Image.create(64, 4, false, Image.FORMAT_RGBA8)
		for x in 64:
			var u: = absf(x / 63.0 - 0.5) * 2.0
			var a: = pow(clampf(1.0 - u, 0.0, 1.0), 1.3)
			for y in 4:
				img.set_pixel(x, y, Color(1, 1, 1, a))
		_ex_band_tex = ImageTexture.create_from_image(img)
	return _ex_band_tex












static func _sonic_cut(_world: World, p: Player, e: Enemy) -> void :
	var frame: = Engine.get_process_frames()
	if int(p.uniq.get("sb_seen", -1)) != frame:
		p.uniq["sb_seen"] = frame
		p.uniq["sb_hits"] = []
	(p.uniq.sb_hits as Array).append(e)



static func _sonic_swing(world: World, p: Player, hits: Array) -> void :
	hits = hits.filter( func(h): return is_instance_valid(h) and not h.dead)
	if hits.is_empty():
		return
	var mark = p.uniq.get("sb_mark")
	var valid: bool = mark != null and is_instance_valid(mark) and not mark.dead and world.clock < float(p.uniq.get("sb_until", 0.0))
	if not valid or not hits.has(mark):


		if valid and ((mark as Enemy).is_boss or not hits.any( func(h): return h.is_boss)):
			return

		var best: Enemy = null
		for h in hits:
			if best == null or (h.is_boss and not best.is_boss) or (h.is_boss == best.is_boss and h.hp > best.hp):
				best = h
		_sonic_clear(p)
		p.uniq["sb_mark"] = best
		mark = best
	var e: Enemy = mark
	p.uniq["sb_until"] = world.clock + GameData.U_SB_MARK_TIME
	var before: = int(p.uniq.get("sb_cuts", 0))
	var cuts: = mini(GameData.U_SB_CUTS, before + GameData.U_SB_PER_CAST)
	p.uniq["sb_cuts"] = cuts
	if not p.uniq.has("sb_ring"):
		p.uniq["sb_ring"] = _sonic_ring(world, e)
	var ring: Node3D = p.uniq.sb_ring
	var notches: Array = ring.get_meta("notches")

	for i in range(before, cuts):
		var n: Sprite3D = notches[i]
		n.set_meta("lit", true)
		n.scale = Vector3.ONE * 2.2
		var tw: = n.create_tween()
		tw.tween_interval(0.05 * (i - before))
		tw.tween_property(n, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Vfx.ring(world.fx_root, e.position + Vector3(0, 0.05, 0), e.radius + 0.9, Color(GameData.U_SB_LIT, 0.8), 0.25)
	if cuts >= GameData.U_SB_CUTS:
		p.uniq.erase("sb_mark")
		p.uniq.erase("sb_ring")
		p.uniq["sb_cuts"] = 0
		_sonic_burst(world, p, e, ring)



static func _sonic_clear(p: Player) -> void :
	var ring = p.uniq.get("sb_ring")
	if ring != null and is_instance_valid(ring):
		(ring as Node).queue_free()
	p.uniq.erase("sb_ring")
	p.uniq.erase("sb_mark")
	p.uniq["sb_cuts"] = 0






static func _sonic_ring(world: World, e: Enemy) -> Node3D:
	var ring: = Node3D.new()
	world.fx_root.add_child(ring)
	var r: = _seal_radius(e)
	ring.set_meta("r", r)
	var base: = Sprite3D.new()
	base.texture = Vfx.ring_texture()
	base.shaded = false
	base.no_depth_test = true
	base.render_priority = 11
	base.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	base.pixel_size = (r + 0.3) * 2.0 / float(base.texture.get_width())
	base.modulate = Color(GameData.U_SB_DARK, 0.75)

	var veil: = Sprite3D.new()
	veil.texture = RoAssets.radial(Color.WHITE, 64)
	veil.shaded = false
	veil.no_depth_test = true
	veil.render_priority = 10
	veil.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	veil.pixel_size = (r + 0.4) * 2.0 / 64.0
	veil.modulate = Color(0.18, 0.04, 0.26, 0.3)
	ring.add_child(veil)
	ring.add_child(base)
	ring.set_meta("base", base)
	var spin: = Node3D.new()
	ring.add_child(spin)
	ring.set_meta("spin", spin)
	var notches: Array = []
	for i in GameData.U_SB_CUTS:
		var a: = TAU * i / float(GameData.U_SB_CUTS)
		var n: = Sprite3D.new()
		n.texture = _slash_texture()
		n.shaded = false
		n.no_depth_test = true
		n.render_priority = 12
		n.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		n.pixel_size = 1.2 / float(n.texture.get_width())
		n.position = Vector3(cos(a), sin(a), 0.0) * r

		n.rotation.z = a + PI * 0.25
		spin.add_child(n)

		var glow: = Sprite3D.new()
		glow.texture = RoAssets.radial(Color.WHITE, 64)
		glow.shaded = false
		glow.no_depth_test = true
		glow.render_priority = 11
		glow.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		glow.pixel_size = 0.9 / 64.0
		glow.visible = false
		n.add_child(glow)
		notches.append(n)
	ring.set_meta("notches", notches)
	_seal_place(world, ring, e)
	return ring


static func _seal_radius(e: Enemy) -> float:
	var h: float = e.visual.height() * ((e.visual as Node3D).scale.y if e.visual is Node3D else 1.0) if e.visual != null else 1.2
	return clampf(h * 0.5, 0.75, 2.6)



static func _seal_place(world: World, ring: Node3D, e: Enemy) -> void :
	var r: float = ring.get_meta("r")
	ring.global_position = e.position + RoVisual.world_lift() + Vector3(0, r + 0.1, 0)
	ring.global_basis = world.camera.global_basis




static func _tick_sonic(world: World, p: Player) -> void :

	if p.uniq.has("sb_hits") and int(p.uniq.get("sb_seen", -1)) < Engine.get_process_frames():
		var hits: Array = p.uniq.sb_hits
		p.uniq.erase("sb_hits")
		_sonic_swing(world, p, hits)
	if not p.uniq.has("sb_ring"):
		return
	var mark = p.uniq.get("sb_mark")
	var ring = p.uniq.get("sb_ring")
	if mark == null or not is_instance_valid(mark) or (mark as Enemy).dead or world.clock >= float(p.uniq.get("sb_until", 0.0))\
	or ring == null or not is_instance_valid(ring) or not p.effects.has("u_sonic"):
		_sonic_clear(p)
		return
	var e: Enemy = mark
	var node: Node3D = ring
	_seal_place(world, node, e)
	var t: = Time.get_ticks_msec() / 1000.0
	(node.get_meta("spin") as Node3D).rotation.z = fmod(t * 0.9, TAU)
	var cuts: = int(p.uniq.get("sb_cuts", 0))
	var pulse: = 0.5 + 0.5 * sin(t * (4.0 + 2.0 * cuts))
	var base: Sprite3D = node.get_meta("base")
	base.modulate = Color(GameData.U_SB_DARK.lerp(GameData.U_SB_LIT, 0.08 * cuts), (0.55 + 0.3 * pulse * cuts / float(GameData.U_SB_CUTS)) * Vfx.dim)
	var notches: Array = node.get_meta("notches")
	for i in notches.size():
		var n: Sprite3D = notches[i]
		var glow: Sprite3D = n.get_child(0)
		glow.visible = i < cuts
		if i < cuts:
			n.modulate = Color(GameData.U_SB_LIT.lerp(Color.WHITE, 0.35 * pulse), Vfx.dim)
			glow.modulate = Color(GameData.U_SB_LIT, (0.35 + 0.25 * pulse) * Vfx.dim)
		else:
			n.modulate = Color(GameData.U_SB_DARK.lightened(0.35), 0.6 * Vfx.dim)




static func _sonic_burst(world: World, p: Player, e: Enemy, ring: Node3D) -> void :
	var at: = e.position
	var r: = GameData.U_SB_RADIUS * sqrt(p.area_mult)

	var notches: Array = ring.get_meta("notches")
	for i in notches.size():
		var n: Sprite3D = notches[i]
		var from: = n.global_position - Vector3(0, 0.4, 0)
		var s: = Sprite3D.new()
		s.texture = _slash_texture()
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 14
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		s.pixel_size = 1.6 / float(s.texture.get_width())
		s.rotation.z = TAU * i / float(notches.size())
		s.modulate = Color(GameData.U_SB_LIT, Vfx.dim)
		world.fx_root.add_child(s)
		s.global_position = from + Vector3(0, 0.4, 0)
		var tw: = s.create_tween()
		tw.tween_interval(0.015 * i)
		tw.tween_property(s, "global_position", at + Vector3(0, 0.9, 0), 0.16).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(s, "scale", Vector3.ONE * 1.6, 0.16)
		tw.tween_property(s, "modulate:a", 0.0, 0.08)
		tw.tween_callback(s.queue_free)
	ring.queue_free()
	world.play_sound("sonic_blow", 0.0, -2.0, 1.15)
	world.get_tree().create_timer(0.2, false).timeout.connect( func():
		if not world.running or not is_instance_valid(p):
			return
		var alive: = is_instance_valid(e) and not e.dead
		var center: = e.position if alive else at
		var keep: = [world.damage_tag, world.damage_by]
		world.damage_tag = "u_sonic"
		world.damage_by = p
		var dps: = e.poison_dps if alive else 0.0
		var dur: = e.poison_time if alive else 0.0
		var stacks: = e.poison_stacks if alive else 0
		var ticks: = 0.0
		if alive and dur > 0.0 and stacks > 0:
			ticks = minf(GameData.U_SB_TICKS_MAX, dur / 0.5) * GameData.U_SB_BURST
			world.poison_burst(e, ticks, false)
		if alive and not e.dead:
			world.damage_enemy(e, GameData.U_BASE * GameData.U_SB_DMG, Vector3.ZERO, "skill", "poison", "u_sonic")


		for o in world.enemies_in_radius(center, r):
			if o == e or o.dead:
				continue
			if dps > 0.0:
				world.apply_poison(o, dps, maxf(dur, 3.0), maxi(1, stacks / 2))
			if ticks > 0.0:
				world.poison_burst(o, ticks * GameData.U_SB_SPREAD, false)
			else:
				world.damage_enemy(o, GameData.U_BASE * GameData.U_SB_DMG * 0.5, Vector3.ZERO, "skill", "poison", "u_sonic")
		_restore(world, keep)


		var green: = GameData.U_SB_LIT
		Vfx.burst(world.fx_root, center + Vector3(0, 0.1, 0), r * 0.8, Color(green, 0.95))
		Vfx.ring(world.fx_root, center + Vector3(0, 0.08, 0), r, Color(0.75, 0.4, 1.0), 0.55)
		Vfx.ring(world.fx_root, center + Vector3(0, 0.08, 0), r * 0.55, green, 0.35)
		Vfx.ray_flash(world.fx_root, center + Vector3(0, 0.9, 0), world.camera.global_basis, Color(0.75, 1.0, 0.6), 0.9)
		world.spawn_fx("venomdust", center, 1.5 * sqrt(p.area_mult), 0.9)
		world.spawn_fx("sonicblow", center + Vector3(0, 0.6, 0), 1.5, 1.0)
		world.spawn_fx("poison", center + Vector3(0, 0.8, 0), 1.3, 1.0)
		world.play_sound("venom_dust", 0.0, -2.0)
		world.play_sound("bleed_burst", 0.0, -3.0)
		world.shake(0.35)

		if p == world.player and not world.net.is_client() and not world._mvp_slow and Engine.time_scale > 0.2:
			var was: = Engine.time_scale
			Engine.time_scale = 0.05
			world.get_tree().create_timer(GameData.U_SB_HITSTOP, true, false, true).timeout.connect( func():
				if Engine.time_scale < 0.06:
					Engine.time_scale = was))


static var _slash_tex: Texture2D



static func _slash_texture() -> Texture2D:
	if _slash_tex == null:
		var n: = 64
		var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
		var a: = Vector2(8, 56)
		var b: = Vector2(56, 8)
		var ab: = b - a
		for y in n:
			for x in n:
				var pt: = Vector2(x, y)
				var t: = clampf((pt - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
				var d: = pt.distance_to(a + ab * t)

				var w: = 0.5 + 4.5 * sin(t * PI)
				var core: = clampf(1.0 - d / w, 0.0, 1.0)
				var glow: = clampf(1.0 - d / (w * 2.6), 0.0, 1.0) * 0.45
				var alpha: = maxf(core, glow)
				img.set_pixel(x, y, Color(1, 1, 1, alpha))
		_slash_tex = ImageTexture.create_from_image(img)
	return _slash_tex







static func damage_mult(p: Player, _element: String) -> float:
	return 1.0 + float(p.uniq.get("orc_mult", 0.0)) + GameData.U_SOUL_DMG * int(p.uniq.get("souls", 0))







static func coma_hit(source: String, tag: String) -> bool:
	if source != "skill" or tag.begins_with("proc:") or tag.contains(":"):
		return false
	var sid: = GameData.skill_of_tag(tag)
	return sid != "" and bool(GameData.SKILLS[sid].get("magic", false))



static func coma_look(world: World, e: Enemy) -> void :
	world.play_sound("stone_curse", 0.3, -8.0)
	if world._bounce_fx_ok(1, "coma"):
		world.spawn_fx("hell_in", e.position, 0.8, 0.8)
		Vfx.ring(world.fx_root, e.position, 1.6, Color(0.75, 0.45, 1.0), 0.35)


static func after_damage(world: World, p: Player, e: Enemy, element: String, source: String, crit: bool, tag: String, hit: = 0.0) -> void :
	var fx: = p.effects

	if fx.has("u_shatter"):
		_ice(world, p, e, element, tag)

	if fx.has("u_sonic") and source == "skill" and tag in ["sonic_blow", "sonic_blow_x"] and not e.dead:
		_sonic_cut(world, p, e)

	if source == "basic" and fx.has("u_overload") and hit > 0.0:
		p.uniq["ov_energy"] = float(p.uniq.get("ov_energy", 0.0)) + hit * float(fx.u_overload)


	if source == "skill" and fx.has("u_excalibur") and hit > 0.0 and not tag.begins_with("proc:") and not tag.begins_with("u_"):
		var peaks: Dictionary = p.uniq.get("ex_peak", {})
		var pk: Array = peaks.get(tag, [world.clock, 0.0])
		pk[1] = maxf(float(pk[1]), hit)
		peaks[tag] = pk
		p.uniq["ex_peak"] = peaks
	if crit and fx.has("u_blood") and tag != "u_blood" and world.clock >= float(p.uniq.get("blood_cd", 0.0)):
		p.uniq["blood_cd"] = world.clock + GameData.U_BLOOD_CD
		_blood_pool(world, p, e.position)



	if crit and source == "basic" and fx.has("u_owl") and world.clock < float(p.uniq.get("owl_cd", 0.0)):
		p.uniq["owl_held"] = mini(GameData.U_OWL_HELD_MAX, int(p.uniq.get("owl_held", 0)) + 1)
	elif crit and source == "basic" and fx.has("u_owl"):
		p.uniq["owl_cd"] = world.clock + GameData.U_OWL_CD
		var held: = 1.0 + GameData.U_OWL_HELD * int(p.uniq.get("owl_held", 0))
		p.uniq["owl_held"] = 0
		var keep: = [world.damage_tag, world.damage_by]
		if not e.dead and e.prop == "":



			var sk: Dictionary = GameData.SKILLS.jupitel_thunder
			world.damage_tag = "u_owl"
			world.damage_by = p
			var jdmg: float = GameData.skill_value("jupitel_thunder", "damage", 5) * held
			var jhits: = int(GameData.skill_value("jupitel_thunder", "hits", 5))
			world.jupitel(p, e, jdmg, jhits, sk)

			var near: Array = world.enemies_in_radius(e.position, GameData.U_OWL_CHAIN_RANGE).filter(
				func(o): return o != e and not o.dead and o.prop == "")
			near.sort_custom( func(a, b): return a.position.distance_squared_to(e.position) < b.position.distance_squared_to(e.position))
			for o in near.slice(0, GameData.U_OWL_CHAIN):
				world.jupitel(p, o, jdmg * GameData.U_OWL_CHAIN_DMG, jhits, sk)

			if near.is_empty():
				for k in GameData.U_OWL_LONE:
					world.jupitel(p, e, jdmg * GameData.U_OWL_CHAIN_DMG, jhits, sk)
			world.play_skill_sound(sk)
		else:

			p.proc_bake = held
			Skills.cast(world, p, "jupitel_thunder", 5, "u_owl")
			p.proc_bake = 1.0
		_restore(world, keep)

	if fx.has("u_queen") and element == "wind" and tag != "u_queen":
		queen_wind(world, p)

	if fx.has("u_coma") and e.is_boss and not e.dead and world.clock >= e.coma_ready and coma_hit(source, tag)\
	and randf() < float(fx.u_coma):



		e.coma_until = world.clock + GameData.U_COMA_BOSS_TIME
		e.coma_ready = e.coma_until + GameData.U_COMA_BOSS_CD
		world.side_word(e, TranslationServer.translate("¡Coma! Daño x2"), Color(0.75, 0.45, 1.0))
		Vfx.ring(world.fx_root, e.position, 2.6, Color(0.75, 0.45, 1.0), GameData.U_COMA_BOSS_TIME)
		coma_look(world, e)






static func queen_state(p: Player) -> Array:
	if p.uniq.has("net_u"):
		var u: Array = p.uniq.net_u
		return u[4] if u.size() > 4 and u[4] is Array else []
	if not p.effects.has("u_queen"):
		return []
	return [int(p.uniq.get("queen_charge", 0)), int(p.uniq.get("queen_strikes", 0)) > 0]





static func queen_wind(world: World, p: Player) -> void :
	if int(p.uniq.get("queen_strikes", 0)) > 0 or world.clock < float(p.uniq.get("queen_wind_cd", -99.0)):
		return
	p.uniq["queen_wind_cd"] = world.clock + GameData.U_QUEEN_WIND_GAP
	_queen_add(world, p, 1)


static func _queen_add(world: World, p: Player, n: int) -> void :
	var was: = int(p.uniq.get("queen_charge", 0))
	var now: = mini(GameData.U_QUEEN_CHARGE, was + n)
	p.uniq["queen_charge"] = now
	if now >= GameData.U_QUEEN_CHARGE and was < GameData.U_QUEEN_CHARGE:

		Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 1.5, GameData.U_QUEEN_FULL_COLOR, 0.45)
		world.play_sound("jupitel", 0.3, -14.0, 1.4)





static func _tick_queen(world: World, p: Player, delta: float) -> void :
	if not p.effects.has("u_queen"):
		if p.uniq.has("queen_nodes"):
			_queen_sparks(world.run_root, p.uniq, "queen_nodes", [], p, Vfx.dim)
		return
	var r: = GameData.U_QUEEN_RADIUS * sqrt(p.area_mult)
	if int(p.uniq.get("queen_strikes", 0)) > 0:
		var t: = float(p.uniq.get("queen_tick", 0.0)) - delta

		var n: = 0
		while t <= 0.0 and n < 2 and int(p.uniq.queen_strikes) > 0:
			t += GameData.U_QUEEN_TICK
			n += 1
			p.uniq.queen_strikes = int(p.uniq.queen_strikes) - 1
			_queen_strike(world, p, r)
		p.uniq["queen_tick"] = t
	else:
		if p._moving:
			var walk: = float(p.uniq.get("queen_walk", 0.0)) + delta
			var n: = int(walk / GameData.U_QUEEN_STEP)
			p.uniq["queen_walk"] = walk - n * GameData.U_QUEEN_STEP
			if n > 0:
				_queen_add(world, p, n)
		if int(p.uniq.get("queen_charge", 0)) >= GameData.U_QUEEN_CHARGE and world.any_enemy_near(p.position, r):
			_queen_storm(world, p, r)
	_queen_sparks(world.run_root, p.uniq, "queen_nodes", queen_state(p), p, Vfx.dim)




static func _queen_storm(world: World, p: Player, r: float) -> void :
	p.uniq["queen_charge"] = 0
	p.uniq["queen_walk"] = 0.0
	p.uniq["queen_strikes"] = roundi(GameData.U_QUEEN_STORM / GameData.U_QUEEN_TICK)
	p.uniq["queen_tick"] = 0.0


	world.spawn_fx("lord", p.position, r / 5.0, 0.3, p)
	Vfx.column(world.fx_root, p.position, Color(0.55, 0.8, 1.0))
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), r, Color(0.8, 0.95, 1.0), 0.6)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), r * 0.55, GameData.U_QUEEN_FULL_COLOR, 0.5)
	world.play_sound("thunder", 0.2, -3.0)
	world.play_sound("lightning_crash", 0.2, -7.0)
	world.shake(0.35)
	_say(world, p, TranslationServer.translate("¡Tormenta de la Reina!"), "say_queen", 2.0)





static func _queen_strike(world: World, p: Player, r: float) -> void :
	var foes: = world.nearest_enemies(p.position, r, GameData.U_QUEEN_HITS)
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "u_queen"
	world.damage_by = p
	var dmg: = GameData.U_BASE * GameData.U_QUEEN_DMG

	var first: = randi() % maxi(1, foes.size())
	for j in mini(3, foes.size()):
		var e: Enemy = foes[(first + j * 7) % foes.size()]
		if not e.dead and world._bounce_fx_ok(3, "queen"):
			world.spawn_fx("lightning", e.position, 1.1 if e.is_boss else 0.8, 0.85)
	for e in foes:
		if e.dead:
			continue
		world.damage_enemy(e, dmg, Vector3.ZERO, "skill", "wind", "u_queen")
	_restore(world, keep)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), r, Color(0.35, 0.65, 1.0), 0.35)
	if world._bounce_fx_ok(1, "queen_sky"):
		var a: = randf() * TAU
		world.spawn_fx("lightning", p.position + Vector3(cos(a), 0, sin(a)) * r * randf_range(0.35, 0.95), 0.9, 0.75)
	world.play_sound("jupitel", 0.2, -11.0, randf_range(0.9, 1.15))







static func _queen_sparks(parent: Node, store: Dictionary, key: String, state: Array, hero: Node3D, alpha: float) -> void :
	var charge: = clampi(int(state[0]), 0, GameData.U_QUEEN_CHARGE) if state.size() > 1 and not bool(state[1]) else 0
	var want: = 0 if charge <= 0 or alpha <= 0.01 else charge + 1
	var nodes: Array = store.get(key, [])
	while nodes.size() > want:
		var n = nodes.pop_back()
		if is_instance_valid(n):
			n.queue_free()
	while nodes.size() < want:
		var mi: = MeshInstance3D.new()
		var q: = QuadMesh.new()
		q.size = Vector2.ONE
		mi.mesh = q
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.no_depth_test = true

		m.render_priority = -2 if nodes.is_empty() else GameData.HERO_FX_PRIORITY
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(mi)
		nodes.append(mi)
	if want <= 0:
		store.erase(key)
		return
	store[key] = nodes
	var cam: = hero.get_viewport().get_camera_3d()
	var right: = cam.global_basis.x if cam != null else Vector3.RIGHT
	var view: = RoVisual.lift.normalized() if RoVisual.lift.length_squared() > 0.0 else Vector3.BACK
	var vis = hero.get("visual")
	var h: float = vis.height() if vis != null and is_instance_valid(vis) else 1.6
	var full: = charge >= GameData.U_QUEEN_CHARGE
	var fill: = float(charge) / GameData.U_QUEEN_CHARGE
	var col: Color = GameData.U_QUEEN_FULL_COLOR if full else GameData.U_QUEEN_COLOR

	var base: = hero.global_position + RoVisual.lift + Vector3(0, h * 0.62, 0) - view * 0.3
	var msec: = Time.get_ticks_msec()
	var t: = msec * 0.001

	var ball: MeshInstance3D = nodes[0]
	var bm: = ball.material_override as StandardMaterial3D
	bm.albedo_texture = RoAssets.effect_tex("jupitel_%d" % (1 + (msec / 70) % 6))


	var ba: = (0.12 + 0.2 * fill + (0.08 * sin(t * 9.0) if full else 0.0)) * alpha
	bm.albedo_color = Color(col.r * ba, col.g * ba, col.b * ba, ba)
	ball.scale = Vector3.ONE * (0.6 + 0.6 * fill)
	ball.global_position = base - view * 0.1


	for k in charge:
		var s: MeshInstance3D = nodes[k + 1]
		var side: = 1.0 if k % 2 == 0 else -1.0
		var u: = fmod(floorf(k * 0.5) * 0.618 + 0.1, 1.0)
		var a: = deg_to_rad(10.0 + 155.0 * u)
		var jit: = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * (0.05 if full else 0.03)
		var at: = right * side * (0.15 + 0.8 * sin(a) + jit.x) + Vector3(0, 0.75 * cos(a) + 0.15 + jit.y, 0)
		s.global_position = base + at
		var flick: = 0.5 + 0.5 * absf(sin(t * (15.0 if full else 8.0) + k * 1.7))
		s.scale = Vector3.ONE * (0.3 + 0.12 * fill) * (0.7 + 0.5 * flick)
		var sm: = s.material_override as StandardMaterial3D
		if sm.albedo_texture == null:
			sm.albedo_texture = RoAssets.effect_tex("lv99_star")
		var sa: = (0.35 + 0.35 * flick) * alpha
		var sc: = col.lightened(0.3 * flick)
		sm.albedo_color = Color(sc.r * sa, sc.g * sa, sc.b * sa, sa)
