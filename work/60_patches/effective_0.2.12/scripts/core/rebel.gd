extends RefCounted















static var _sight: Texture2D



static func gun_tag(p: Player, tag: String) -> bool:
	return p.class_id == "gunslinger" and not tag.begins_with("proc:")\
	and GameData.GUN_MARK_SKILLS.has(tag.trim_suffix("_x"))



static func after_hit(world: World, p: Player, e: Enemy, tag: String) -> void :

	if GameData.has_meta("rebel_off"):
		return

	if e.dead or e.hp <= 0.0 or e.prop != "" or not gun_tag(p, tag):
		return
	mark(world, p, e)



static func on_cast(world: World, p: Player, id: String, dmg: float, reach: float) -> void :
	if GameData.has_meta("rebel_off") or not gun_tag(p, id) or str(world.damage_tag).begins_with("proc:"):
		return

	p.set_meta("gun_cast", int(p.get_meta("gun_cast", 0)) + 1)
	if world.clock < float(p.get_meta("dragon_tail_at", -100.0)) + GameData.DRAGON_TAIL_GAP:
		return
	if world.nearest_enemy(p.position, reach + 1.0) == null:
		return
	dragon_tail(world, p, dmg)





static func mark(world: World, p: Player, e: Enemy) -> void :
	var marks: = marks_of(world, p)
	var until: = world.clock + GameData.CRIMSON_TIME
	var cast: = int(p.get_meta("gun_cast", 0))


	var cast_id: = "%d:%d" % [p.get_instance_id(), cast]
	if e.is_boss and str(e.get_meta("crimson_cast", "")) != cast_id:
		e.set_meta("crimson_cast", cast_id)
		var was: = int(e.get_meta("crimson_stacks", 0))
		e.set_meta("crimson_stacks", mini(was + 1, GameData.CRIMSON_BOSS_STACKS))
		if was + 1 >= GameData.CRIMSON_BOSS_STACKS and was < GameData.CRIMSON_BOSS_STACKS:
			world.side_word(e, TranslationServer.translate("¡Marcas al máximo!"), GameData.DRAGON_TAIL_COLOR)
	if marks.has(e):
		e.set_meta("crimson_until", until)
		return

	while marks.size() >= GameData.CRIMSON_MAX:
		unmark(marks.pop_front())
	marks.append(e)
	e.set_meta("crimson_until", until)
	e.set_meta("crimson_at", world.clock)
	_sights(world)



static func marks_of(world: World, p: Player) -> Array:
	if not p.has_meta("crimson_marks"):
		p.set_meta("crimson_marks", [])
	var marks: Array = p.get_meta("crimson_marks")
	for i in range(marks.size() - 1, -1, -1):
		var e = marks[i]
		if not is_instance_valid(e) or (e as Enemy).dead:
			marks.remove_at(i)
			continue
		if world.clock >= float((e as Enemy).get_meta("crimson_until", 0.0)):
			unmark(e)
			marks.remove_at(i)
	return marks


static func unmark(e) -> void :
	if not is_instance_valid(e):
		return
	var en: Enemy = e
	en.remove_meta("crimson_until")
	en.remove_meta("crimson_at")
	en.remove_meta("crimson_stacks")
	en.remove_meta("crimson_cast")




static func dragon_tail(world: World, p: Player, dmg: float) -> void :
	var marks: = marks_of(world, p).duplicate()


	var keep: = marks.filter( func(e): return (e as Enemy).is_boss and int((e as Enemy).get_meta("crimson_stacks", 1)) < GameData.CRIMSON_BOSS_STACKS)
	marks = marks.filter( func(e): return not keep.has(e))
	if marks.is_empty():
		return
	p.set_meta("dragon_tail_at", world.clock)
	(p.get_meta("crimson_marks") as Array).assign(keep)
	var r: = GameData.DRAGON_TAIL_RADIUS * sqrt(p.area_mult)
	var blast: = dmg * GameData.DRAGON_TAIL_MULT
	var tag: = world.damage_tag
	var by: = world.damage_by
	var shown: = 0
	for e in marks:
		var en: Enemy = e
		var at: = en.position

		var stacks: = maxi(1, int(en.get_meta("crimson_stacks", 1)))
		var boss: = en.is_boss
		unmark(en)
		world.damage_tag = "dragon_tail"
		world.damage_by = p


		for o in world.enemies_in_radius(at, r):
			if not o.dead:


				world.damage_enemy(o, blast * (GameData.DRAGON_TAIL_BOSS_MULT / GameData.DRAGON_TAIL_MULT * stacks if boss and o == en else 1.0), 
					Vector3.ZERO, "skill", "fire", "dragon_tail")


		if shown < GameData.DRAGON_TAIL_FX:
			shown += 1
			world.spawn_fx("tetravortex/tetra_01_fire_sub_explosion/tetra_01_fire_sub_expn", at + Vector3(0, 0.3, 0), r / 2.2 * (1.0 + 0.15 * (stacks - 1)), 1.0)
		Vfx.ring(world.fx_root, at + Vector3(0, 0.06, 0), r, Color(1.0, 0.3, 0.15, 0.85), 0.3)
	world.damage_tag = tag
	world.damage_by = by
	world.shake(minf(0.5, 0.08 + 0.02 * marks.size()))
	world.play_sound("fire", 0.08, -4.0, 0.8)
	if marks.size() >= 6:
		world.number(p.position + Vector3(0, 2.4, 0), TranslationServer.translate("¡Dragon Tail x%d!") % marks.size(), Color(1.0, 0.4, 0.25), true)



static func _sights(world: World) -> void :
	if world.has_meta("crimson_sights") and is_instance_valid(world.get_meta("crimson_sights")):
		return
	var s: = Sights.new()
	s.world = world
	s.tex = _sight_texture()
	world.fx_root.add_child(s)
	world.set_meta("crimson_sights", s)




class Sights extends MultiMeshInstance3D:
	const MAX: = 160
	var world: World
	var tex: Texture2D

	func _ready() -> void :
		var quad: = QuadMesh.new()
		quad.size = Vector2.ONE
		var mat: = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		mat.billboard_keep_scale = true
		mat.no_depth_test = true
		mat.render_priority = 12
		mat.albedo_texture = tex

		mat.albedo_color = Color(1, 1, 1, GameData.CRIMSON_ALPHA)
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		quad.material = mat
		var mm: = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = quad
		mm.instance_count = MAX
		mm.visible_instance_count = 0
		multimesh = mm
		top_level = true
		cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

		custom_aabb = AABB(Vector3(-5000, -50, -5000), Vector3(10000, 100, 10000))

	func _process(_delta: float) -> void :
		if world == null or not is_instance_valid(world):
			return
		var n: = 0
		if not Vfx.hidden():
			for h in world.heroes:
				if not is_instance_valid(h) or not (h as Player).has_meta("crimson_marks"):
					continue
				for e in (h as Player).get_meta("crimson_marks"):
					if n >= MAX or not is_instance_valid(e) or (e as Enemy).dead or not (e as Enemy).has_meta("crimson_until"):
						continue
					var en: Enemy = e
					if world.clock >= float(en.get_meta("crimson_until", 0.0)):
						continue
					var age: = world.clock - float(en.get_meta("crimson_at", 0.0))

					var size: = (GameData.CRIMSON_SIZE_BOSS * (1.0 + 0.12 * (int(en.get_meta("crimson_stacks", 1)) - 1)) if en.is_boss else GameData.CRIMSON_SIZE) * (1.0 + 0.8 * clampf(1.0 - age / 0.18, 0.0, 1.0))
					var at: = en.global_position + Vector3(0, (en.visual.height() if en.visual != null else 1.2) * 0.55, 0)
					multimesh.set_instance_transform(n, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * size), at))
					n += 1
		multimesh.visible_instance_count = n
		transparency = 1.0 - Vfx.dim


static func _sight_texture() -> Texture2D:
	if _sight != null:
		return _sight
	var n: = 64
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c: = Vector2(n, n) * 0.5


	var red: = Color(1.0, 0.16, 0.1)
	var rim: = Color(0.12, 0.0, 0.0)
	for y in n:
		for x in n:
			var d: = Vector2(x + 0.5, y + 0.5).distance_to(c)
			var dx: = absf(x + 0.5 - c.x)
			var dy: = absf(y + 0.5 - c.y)
			var ticks: = func(w: float) -> bool:
				return (dx < w and dy > 8.0 - w and dy < 31.0) or (dy < w and dx > 8.0 - w and dx < 31.0)
			var core: = maxf(clampf(1.0 - absf(d - 21.0) / 2.6, 0.0, 1.0), clampf(1.0 - d / 3.2, 0.0, 1.0))
			if ticks.call(2.2):
				core = 1.0
			var edge: = maxf(clampf(1.0 - absf(d - 21.0) / 4.6, 0.0, 1.0), clampf(1.0 - d / 5.0, 0.0, 1.0))
			if ticks.call(3.8):
				edge = 1.0
			if core > 0.0 or edge > 0.0:
				var col: = rim.lerp(red, core)
				img.set_pixel(x, y, Color(col, maxf(core, edge * 0.85)))
	_sight = ImageTexture.create_from_image(img)
	return _sight
