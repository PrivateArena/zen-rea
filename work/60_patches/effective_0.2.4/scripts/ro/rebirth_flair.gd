class_name RebirthFlair
extends Node3D



















const GOLD: = Color(1.0, 0.82, 0.35)
const PALE: = Color(0.75, 0.85, 1.0)



const BEHIND: = ["pillar", "halo", "trail", "gold", "valhalla_ground"]
const BOTH: = ["orbs", "biolab"]


const BODY_HALF: = 0.3
const BODY_FADE: = 0.3

const HALO_Y: = 0.98
const CROWN_Y: = 1.12

static var _grays: = {}




static func gray(tex: Texture2D) -> Texture2D:
	if tex == null:
		return null
	if not _grays.has(tex):
		var img: = RoAssets.tex_image(tex)
		if img == null:
			return tex
		img = img.duplicate()
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		for y in img.get_height():
			for x in img.get_width():
				var c: = img.get_pixel(x, y)
				var v: = maxf(c.r, maxf(c.g, c.b))
				img.set_pixel(x, y, Color(v, v, v, c.a))
		_grays[tex] = ImageTexture.create_from_image(img)
	return _grays[tex]

var looks: Array = []


var height: = 2.0


var part: = ""

var _sparkles: Array[Dictionary] = []
var _orbs: Array[Sprite3D] = []
var _sight: RoSprite
var _wisps: Array[Node3D] = []
var _crown: Node3D

var _head_x: = 0.0
var _halo: Sprite3D
var _t: = 0.0
var _ray_t: = 2.0
var _pillar_t: = 2.5
var _trail_t: = 0.0
var _last_pos: = Vector3.INF
var _moving: = false


func _ready() -> void :
	var gold_ground: = looks.has("valhalla") and _in_part("valhalla_ground")
	looks = looks.filter( func(id): return _in_part(str(id)))
	_find_visual()
	if looks.has("sparkles"):
		for i in 10:
			var s: = _billboard(gray(_tex("lv99_star")) if looks.has("gold") else _tex("lv99_star"), 0.42, 
				Color(GOLD.lightened(0.45) if looks.has("gold") else PALE.lightened(0.5), 0.0))
			_sparkles.append({"node": s, "phase": randf() * TAU, "speed": randf_range(1.0, 1.8)})
			_place_sparkle(_sparkles.back())
	if looks.has("biolab"):
		for i in 3:
			var w: = Node3D.new()
			add_child(w)
			_billboard(RoAssets.radial(Color.WHITE, 32), 0.75, Color(0.35, 1.0, 0.3, 0.45), w)
			_billboard(RoAssets.radial(Color.WHITE, 32), 0.24, Color(0.85, 1.0, 0.75, 1.0), w)
			_wisps.append(w)
	if looks.has("orbs"):
		_sight = RoAssets.sprite(["fx_sight"])
		for i in 2:
			var tex: Texture2D = _sight.get_frame(0, 0) if _sight != null else _tex("spirit_ball_1")
			var o: = _billboard(gray(tex) if looks.has("gold") else tex, 0.55, Color(GOLD, 1.0) if looks.has("gold") else Color.WHITE)
			o.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			if _sight != null:


				o.pixel_size = GameData.PIXEL_SIZE * 1.3
				(o.material_override as StandardMaterial3D).blend_mode = BaseMaterial3D.BLEND_MODE_MIX
			_orbs.append(o)
	if looks.has("halo"):
		_halo = Sprite3D.new()
		_halo.texture = Vfx.ring_texture()
		_halo.axis = Vector3.AXIS_Y
		_halo.shaded = false
		_halo.pixel_size = 0.66 / float(_halo.texture.get_width())
		_halo.modulate = Color(GOLD.lightened(0.25), 1.0)
		var hm: = StandardMaterial3D.new()
		hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		hm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		hm.cull_mode = BaseMaterial3D.CULL_DISABLED
		hm.albedo_texture = _halo.texture
		hm.vertex_color_use_as_albedo = true

		hm.render_priority = 0
		_halo.material_override = hm
		_halo.position = Vector3(0, height + HALO_Y, 0)
		add_child(_halo)
	if looks.has("crown"):
		_crown = Node3D.new()
		add_child(_crown)
		_crown.position = Vector3(0, height + CROWN_Y, 0)
		for i in 5:
			var a: = TAU * i / 5.0
			var st: = _billboard(gray(_tex("lv99_star")), 0.18, Color(GOLD, 0.95), _crown)
			st.position = Vector3(cos(a), 0, sin(a)) * 0.32
	if looks.has("valhalla"):
		_motes()
	if gold_ground:

		var glow: = Vfx.ground_glow(self, Vector3(0, 0.06, 0), 1.7, Color(GOLD, 0.5))
		var tw: = glow.create_tween().set_loops()
		tw.tween_property(glow, "modulate:a", 0.22, 1.1).set_trans(Tween.TRANS_SINE)
		tw.tween_property(glow, "modulate:a", 0.55, 1.1).set_trans(Tween.TRANS_SINE)


func _in_part(id: String) -> bool:
	if part == "" or BOTH.has(id):
		return true
	return BEHIND.has(id) == (part == "back") and id != "trail" and id != "gold"



func _find_visual() -> RoVisual:
	var p: = get_parent()
	var v: Variant = p if p is RoVisual else (p.get("visual") if p != null else null)
	if v is RoVisual and is_instance_valid(v):
		height = maxf(1.0, (v as RoVisual).height())
		return v
	return null


func _process(delta: float) -> void :
	_t += delta
	var vis: = _find_visual()
	if _last_pos != Vector3.INF:
		_moving = global_position.distance_squared_to(_last_pos) > 4e-06
	_last_pos = global_position
	for sp in _sparkles:
		var s: Sprite3D = sp.node
		var k: = sin(_t * float(sp.speed) + float(sp.phase))
		s.modulate.a = minf(1.0, maxf(0.0, k) * 1.3)
		s.scale = Vector3.ONE * (0.5 + 0.8 * maxf(0.0, k))

		if k < -0.95:
			_place_sparkle(sp)
	var cam: = get_viewport().get_camera_3d() if not (_orbs.is_empty() and _wisps.is_empty()) else null
	for i in _orbs.size():
		var a: = _t * 1.3 + TAU * i / _orbs.size()
		_orbs[i].position = Vector3(cos(a) * 0.85, height * 0.5 + sin(_t * 2.0 + i) * 0.08, sin(a) * 0.85)
		if _sight != null:

			var tex: = _sight.get_frame(0, int(_t * 14.0 + i * 7))
			if tex != null:
				tex = gray(tex) if looks.has("gold") else tex
				if _orbs[i].texture != tex:
					_orbs[i].texture = tex
					(_orbs[i].material_override as StandardMaterial3D).albedo_texture = tex
		_orbs[i].scale = Vector3.ONE
		_depth(_orbs[i], cam)
	for i in _wisps.size():
		var a: = - _t * 0.7 + TAU * i / _wisps.size()
		var w: = _wisps[i]
		w.position = Vector3(cos(a) * 1.0, height * (0.5 + 0.18 * sin(_t * 1.3 + i * 2.0)), sin(a) * 1.0)
		var flick: = 0.75 + 0.25 * sin(_t * 6.0 + i * 1.7) * sin(_t * 2.3 + i)
		w.scale = Vector3.ONE * flick
		_depth(w, cam)


	if (_halo != null or _crown != null) and vis != null and vis.ro != null:
		var hx: = vis.ro.head_x(vis.base_action * RoSprite.DIRS + vis._shown) * GameData.PIXEL_SIZE * vis.scale.x
		_head_x = lerpf(_head_x, hx, minf(1.0, delta * 12.0))
	if _halo != null:
		_halo.position.x = _head_x
		_halo.position.y = height + HALO_Y + sin(_t * 2.2) * 0.04
		_halo.modulate.a = 0.75 + 0.25 * sin(_t * 3.0)
	if _crown != null:
		_crown.rotation.y = _t * 0.9
		_crown.position.x = _head_x
		_crown.position.y = height + CROWN_Y
	if looks.has("rays"):
		_ray_t -= delta
		if _ray_t <= 0.0:
			_ray_t = randf_range(3.5, 5.5)
			_rays()
	if looks.has("pillar"):
		_pillar_t -= delta
		if _pillar_t <= 0.0:
			_pillar_t = randf_range(6.0, 9.0)
			_pillar()
	if looks.has("trail") and _moving and vis != null and vis.sprite.texture != null:
		_trail_t -= delta
		if _trail_t <= 0.0:
			_trail_t = 0.09
			_trail(vis)





func _depth(n: Node3D, cam: Camera3D) -> void :
	if cam == null:
		return
	var rel: = n.global_position - global_position



	var ahead: = - cam.global_basis.z * Vector3(1, 0, 1)
	var far: = (rel * Vector3(1, 0, 1)).dot(ahead) > 0.0
	if part == "front":
		n.visible = not far
	elif part == "back":
		n.visible = far
	else:





		if not n.has_meta("far") or bool(n.get_meta("far")) != far:
			n.set_meta("far", far)
			for s in ([n] + n.get_children()):
				if s is GeometryInstance3D and (s as GeometryInstance3D).material_override is StandardMaterial3D:
					var m: = (s as GeometryInstance3D).material_override as StandardMaterial3D
					m.render_priority = 0 if far else GameData.HERO_FX_PRIORITY
					m.no_depth_test = not far

		if far:
			n.scale *= clampf((absf(rel.dot(cam.global_basis.x)) - BODY_HALF) / BODY_FADE, 0.01, 1.0)



func _tex(key: String) -> Texture2D:
	var t: = RoAssets.effect_tex(key)
	return t if t != null else RoAssets.radial(Color.WHITE, 32)


func _billboard(tex: Texture2D, size: float, col: Color, parent: Node3D = null) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = tex
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.transparent = true
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	if tex != null:
		s.pixel_size = size / maxf(1.0, float(tex.get_width()))
	s.modulate = col
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.albedo_texture = tex
	mat.vertex_color_use_as_albedo = true

	mat.render_priority = GameData.HERO_FX_PRIORITY
	s.material_override = mat
	(parent if parent != null else self).add_child(s)
	return s


func _place_sparkle(sp: Dictionary) -> void :
	var a: = randf() * TAU
	(sp.node as Sprite3D).position = Vector3(cos(a) * randf_range(0.35, 0.75), randf_range(0.2, height * 0.95), sin(a) * randf_range(0.35, 0.75))
	sp.phase = randf() * TAU



func _rays() -> void :
	var cam: = get_viewport().get_camera_3d() if get_viewport() != null else null
	if cam == null:
		return
	Vfx.ray_flash(self, global_position + Vector3(0, height * 0.55, 0), cam.global_basis, 
		GOLD if looks.has("gold") else PALE, 0.75)


static var _pillar_tex: Texture2D




func _pillar() -> void :
	if _pillar_tex == null:
		var img: = Image.create(32, 128, false, Image.FORMAT_RGBA8)
		for y in 128:

			var v: = pow(float(y) / 127.0, 1.3)
			for x in 32:
				var fx: = 1.0 - absf((x + 0.5) / 16.0 - 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, v * pow(fx, 1.1)))
		_pillar_tex = ImageTexture.create_from_image(img)
	var col: = GOLD if looks.has("gold") else PALE.lightened(0.2)
	var h: = height * 2.8
	for layer in 2:
		var mi: = MeshInstance3D.new()
		var quad: = QuadMesh.new()
		quad.size = Vector2(1.5 if layer == 0 else 0.55, h)
		quad.center_offset = Vector3(0, h * 0.5, 0)
		mi.mesh = quad
		var mat: = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.albedo_texture = _pillar_tex
		mat.albedo_color = Color(col if layer == 0 else col.lightened(0.6), 0.0)
		mi.material_override = mat
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(mi)
		mi.scale = Vector3(1.0, 0.05, 1.0)
		var tw: = mi.create_tween()
		tw.tween_property(mi, "scale:y", 1.0, 0.28).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(mat, "albedo_color:a", 0.95 if layer == 0 else 0.8, 0.2)
		tw.tween_property(mat, "albedo_color:a", 0.55 if layer == 0 else 0.5, 0.45).set_trans(Tween.TRANS_SINE)
		tw.tween_property(mat, "albedo_color:a", 0.85 if layer == 0 else 0.7, 0.45).set_trans(Tween.TRANS_SINE)
		tw.tween_property(mi, "scale:x", 0.05, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.55)
		tw.tween_callback(mi.queue_free)
	Vfx.ring(self, Vector3(0, 0.05, 0), 1.6, Color(col, 0.9), 0.5)
	var glow: = Vfx.ground_glow(self, Vector3(0, 0.05, 0), 1.4, Color(col, 0.8))
	var gt: = glow.create_tween()
	gt.tween_property(glow, "modulate:a", 0.0, 1.5)
	gt.tween_callback(glow.queue_free)



func _trail(vis: RoVisual) -> void :

	var root: = get_parent().get_parent() as Node3D if get_parent() != null else null
	if vis is RoVisual and vis == get_parent():
		root = vis.get_parent() as Node3D
	if root == null:
		return
	var sprite: = vis.sprite
	var g: = Sprite3D.new()
	g.texture = sprite.texture
	g.offset = sprite.offset
	g.centered = sprite.centered
	g.render_priority = 4
	g.pixel_size = sprite.pixel_size
	g.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	g.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	g.shaded = false
	g.modulate = Color(GOLD if looks.has("gold") else PALE, 0.4)
	root.add_child(g)
	g.global_transform = sprite.global_transform
	var tw: = g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.35)
	tw.tween_callback(g.queue_free)



func _motes() -> void :
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.12, 0.12)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 16)
	quad.material = pm
	p.mesh = quad
	p.amount = 26
	p.lifetime = 2.6
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	p.emission_ring_axis = Vector3.UP
	p.emission_ring_radius = 0.6
	p.emission_ring_inner_radius = 0.15
	p.emission_ring_height = 0.0
	p.direction = Vector3.UP
	p.spread = 10.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 0.5
	p.initial_velocity_max = 1.1
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.4
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(GOLD, 0.0))
	ramp.add_point(0.2, Color(GOLD.lightened(0.3), 1.0))
	ramp.set_color(ramp.get_point_count() - 1, Color(GOLD, 0.0))
	p.color_ramp = ramp
	p.position = Vector3(0, 0.2, 0)
	add_child(p)
