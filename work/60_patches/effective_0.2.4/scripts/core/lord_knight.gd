extends RefCounted












const IMP_MAX: = 10
const IMP_EVERY: = 0.5
const IMP_DMG: = 0.06
const CHARGE_PER: = 0.2
const PIERCE_GAP: = 0.2
const SLASH_EVERY: = 0.3
const SLASH_DMG: = 1.2
const SLASH_LEN: = 7.5
const SLASH_W: = 2.4
const SLASH_TILT: = 0.42
const X_EVERY: = 3
const X_MULT: = 2.0
const COL: = Color(0.62, 0.85, 1.0)
const COL_X: = Color(1.0, 0.82, 0.45)


static func on(p: Player) -> bool:
	return p != null and is_instance_valid(p) and str(p.job2.get("id", "")) == "lord_knight"\
	and p.skills.has("peco_riding") and not p.mount().is_empty()


static func stacks(p: Player) -> int:
	return int(p.get_meta("lk_imp", 0))


static func _set_stacks(p: Player, n: int) -> void :
	p.set_meta("lk_imp", clampi(n, 0, IMP_MAX))



static func tick(world: World, p: Player, delta: float) -> void :
	if not on(p) or p.downed:
		if p.has_meta("lk_imp"):
			p.remove_meta("lk_imp")
		return
	var t: = float(p.get_meta("lk_imp_t", 0.0)) + delta
	if t >= IMP_EVERY:
		t -= IMP_EVERY
		var was: = stacks(p)
		_set_stacks(p, was + (1 if p._moving else -1))
		if stacks(p) == IMP_MAX and was < IMP_MAX:
			world.label_over(p, TranslationServer.translate("¡Ímpetu!"), COL_X)
			world.play_sound("maximize_power", 0.2, -4.0, 1.15)
			Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), 2.4, COL_X, 0.4)
	p.set_meta("lk_imp_t", t)
	if stacks(p) < IMP_MAX:
		return
	var s: = float(p.get_meta("lk_slash_t", 0.0)) - delta
	if s <= 0.0 and world.any_enemy_near(p.position, SLASH_LEN + 1.5):
		s = SLASH_EVERY
		_slash(world, p)
	p.set_meta("lk_slash_t", s)



static func pierce_hit(world: World, p: Player) -> void :
	if not on(p) or world.clock < float(p.get_meta("lk_pierce_at", -99.0)):
		return
	p.set_meta("lk_pierce_at", world.clock + PIERCE_GAP)
	_set_stacks(p, stacks(p) + 1)



static func mult(p: Player, tag: String) -> float:
	var n: = stacks(p)
	if n <= 0:
		return 1.0
	var m: = 1.0 + IMP_DMG * n
	if Player.base_skill(tag) == "charge_attack":
		m *= 1.0 + CHARGE_PER * n
	return m



static func _slash(world: World, p: Player) -> void :
	var k: = int(p.get_meta("lk_slash_n", 0))
	p.set_meta("lk_slash_n", k + 1)
	var dir: = p.facing * Vector3(1, 0, 1)
	dir = dir.normalized() if dir.length_squared() > 0.0001 else Vector3.FORWARD
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "aura_blade"
	world.damage_by = p
	if (k + 1) % X_EVERY == 0:

		var c: = p.position + dir * SLASH_LEN * 0.5
		for sgn in [-1.0, 1.0]:
			var d: = dir.rotated(Vector3.UP, sgn * PI * 0.25)
			var from: = c - d * SLASH_LEN * 0.5
			slash_fx(world, from, d, SLASH_LEN, SLASH_W * 1.2, true)
			_lane(world, p, from, d, X_MULT)
		world.spawn_fx("jyumonjikiri", c + Vector3(0, 0.6, 0), 1.5, 1.0)
		Vfx.ray_flash(world.fx_root, c + Vector3(0, 1.0, 0), world.camera.global_basis, COL_X, 0.9)
		world.play_sound("shadow_slash", 0.08, -5.0)
	else:
		var d: = dir.rotated(Vector3.UP, SLASH_TILT * (1.0 if k % 2 == 0 else -1.0))
		slash_fx(world, p.position, d, SLASH_LEN, SLASH_W, false)

		Vfx.arc(world.fx_root, p.position + Vector3(0, 0.7, 0), d, 2.6, 1.3, Color(COL, 0.7))
		_lane(world, p, p.position, d, 1.0)
		world.play_sound("mist_slash", 0.06, -9.0, randf_range(1.0, 1.2))
	world.damage_tag = keep[0]
	world.damage_by = keep[1]


static func _lane(world: World, p: Player, from: Vector3, dir: Vector3, mult: float) -> void :
	var dmg: = p.basic_atk() * SLASH_DMG * mult
	for e in world.enemies_in_radius(from + dir * SLASH_LEN * 0.5, SLASH_LEN * 0.5 + SLASH_W + 1.0):
		if e.dead:
			continue
		var to: Vector3 = (e.position - from) * Vector3(1, 0, 1)
		var along: = to.dot(dir)
		if along < -0.3 or along > SLASH_LEN:
			continue
		if (to - dir * along).length() <= SLASH_W * 0.5 + e.radius:
			world.damage_enemy(e, dmg, dir * 1.2, "skill", p.basic_element(), "aura_blade")




static func draw(p: Player) -> void :
	var n: = stacks(p)
	var ring: Sprite3D = p.get_meta("lk_ring") if p.has_meta("lk_ring") else null
	if n <= 0:
		if ring != null and is_instance_valid(ring):
			ring.queue_free()
		if p.has_meta("lk_ring"):
			p.remove_meta("lk_ring")
		return
	if ring == null or not is_instance_valid(ring):
		ring = Sprite3D.new()
		ring.texture = Vfx.ring_texture()
		ring.shaded = false
		ring.render_priority = 4
		ring.pixel_size = 2.4 / float(ring.texture.get_width())
		ring.rotation_degrees.x = -90.0
		ring.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		p.add_child(ring)
		ring.position = Vector3(0, 0.06, 0)
		p.set_meta("lk_ring", ring)
	var top: = n >= IMP_MAX
	var t: = Time.get_ticks_msec() / 1000.0
	var pulse: = 0.5 + 0.5 * sin(t * (9.0 if top else 4.0))
	var col: = COL_X if top else COL
	ring.modulate = Color(col, (0.2 + 0.05 * n + (0.25 * pulse if top else 0.0)) * Vfx.dim)
	ring.scale = Vector3.ONE * (0.8 + 0.04 * n + (0.08 * pulse if top else 0.0))
	ring.rotation_degrees.y = fmod(t * (220.0 if top else 60.0), 360.0)







static func slash_fx(world: World, from: Vector3, dir: Vector3, length: float, width: float, x: bool) -> void :
	if world.net.recording():
		world.net.record(["ov", "lks", from, dir, length, width, x])
	var at: = from + Vector3(0, 0.15, 0)
	if x:
		var life: = 0.4
		for layer in [[1.0, Color(COL_X, 0.75), false], [0.5, Color(COL_X.lightened(0.4), 0.95), true], [0.16, Color(1, 1, 1, 1.0), true]]:
			var w: float = width * float(layer[0])
			Uniques._ex_band(world, at, dir, length * 0.5, w * 0.15, w, layer[1], layer[2], life)
			Uniques._ex_band(world, at + dir * length * 0.5, dir, length * 0.5, w, w * 0.15, layer[1], layer[2], life)
		Uniques._sparks(world, at + dir * length * 0.9, dir, 0.8, COL_X)
		return
	_crescent(world, at, dir, width, length, Color(COL, 0.85), 1.0, false)
	_crescent(world, at, dir, width, length, Color(COL.lightened(0.5), 1.0), 0.45, true)
	_crescent(world, at, dir, width, length, Color(1, 1, 1, 1.0), 0.16, true)
	world.get_tree().create_timer(0.24, false).timeout.connect( func():
		Uniques._sparks(world, at + dir * length, dir, 0.8, COL))




const SLASH_FLY: = 0.26
static func _crescent(world: World, at: Vector3, dir: Vector3, width: float, travel: float, color: Color, thick: float, additive: bool) -> void :
	var st: = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half: = 1.15
	var r: = width * 0.6
	var th: = width * 0.28 * thick
	var n: = 14
	var outer: Array[Vector3] = []
	var inner: Array[Vector3] = []
	for i in n + 1:
		var a: = - half + 2.0 * half * i / n
		var taper: = cos(a / half * PI * 0.5)
		outer.append(Vector3(sin(a) * r, 0, cos(a) * r - r * 0.6))
		inner.append(Vector3(sin(a) * (r - th * taper), 0, cos(a) * (r - th * taper) - r * 0.6))
	for i in n:
		for v in [outer[i], outer[i + 1], inner[i + 1], outer[i], inner[i + 1], inner[i]]:
			st.set_color(Color.WHITE)
			st.add_vertex(v)
	var m: = MeshInstance3D.new()
	m.mesh = st.commit()
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if additive else BaseMaterial3D.BLEND_MODE_MIX
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.render_priority = 7 if additive else 6
	mat.vertex_color_use_as_albedo = true
	var k: = Vfx.add_k() if additive else 1.0
	mat.albedo_color = Color(color.r * k, color.g * k, color.b * k, color.a * Vfx.dim)
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.fx_root.add_child(m)
	var side: = Vector3.UP.cross(dir).normalized()
	m.global_transform = Transform3D(Basis(side, Vector3.UP, dir), at)
	var tw: = m.create_tween().set_parallel()
	tw.tween_property(m, "global_position", at + dir * travel, SLASH_FLY).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(m, "scale", Vector3.ONE * 1.7, SLASH_FLY).set_ease(Tween.EASE_OUT)
	tw.tween_property(mat, "albedo_color:a", 0.0, SLASH_FLY).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.chain().tween_callback(m.queue_free)
