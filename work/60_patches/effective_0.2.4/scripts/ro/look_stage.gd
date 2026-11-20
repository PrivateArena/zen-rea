class_name LookStage
extends SubViewport








const BACKDROPS: = {
	"prontera": [Color(0.8, 0.84, 0.92), Color(0.72, 0.71, 0.7)], 
	"field": [Color(0.58, 0.78, 0.95), Color(0.36, 0.55, 0.26)], 
	"night": [Color(0.05, 0.06, 0.14), Color(0.16, 0.18, 0.28)], 
	"valhalla": [Color(0.98, 0.88, 0.62), Color(0.86, 0.8, 0.64)], 
}

var ro: RoSprite
var dir: = 0
var _hero: Sprite3D
var _ground: Sprite3D
var _env: Environment
var _holder: Node3D
var _looks: Array = []
var _aura: = false
var _gold_aura: = false
var _dim_hero: = false

var _trail: = false
var _t: = 0.0
var _ghost_t: = 0.0




func _init(p_ro: RoSprite, px: Vector2i, zoom: = 1.0, feet: = 0.8, dim_hero: = false) -> void :
	ro = p_ro
	_dim_hero = dim_hero
	size = px
	own_world_3d = true
	transparent_bg = false
	render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var cam: = Camera3D.new()
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = px.y * GameData.PIXEL_SIZE / zoom
	var up: = Vector3(0, cos(World.CAMERA_PITCH), - sin(World.CAMERA_PITCH))
	var target: = up * (feet - 0.5) * cam.size
	var eye: = target + Vector3(0, sin(World.CAMERA_PITCH), cos(World.CAMERA_PITCH)) * 20.0
	cam.transform = Transform3D(Basis(), eye).looking_at(target, Vector3.UP)
	_env = Environment.new()
	_env.background_mode = Environment.BG_COLOR
	cam.environment = _env
	add_child(cam)
	_ground = Sprite3D.new()
	_ground.texture = RebirthAura.Preview.stone_tex()
	_ground.axis = Vector3.AXIS_Y
	_ground.shaded = false
	_ground.pixel_size = 5.0 / float(_ground.texture.get_width())
	_ground.render_priority = -10
	add_child(_ground)
	_hero = Sprite3D.new()
	_hero.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_hero.shaded = false
	_hero.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_hero.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	_hero.pixel_size = GameData.PIXEL_SIZE
	if dim_hero:
		_hero.modulate = Color(0.42, 0.45, 0.55)



	_hero.position = Vector3(0, sin(World.CAMERA_PITCH), cos(World.CAMERA_PITCH)) * 1.2
	add_child(_hero)
	backdrop("prontera")
	turn(0)




func clear() -> void :
	transparent_bg = true
	_env.background_mode = Environment.BG_CLEAR_COLOR
	_ground.visible = false


func backdrop(key: String) -> void :
	var b: Array = BACKDROPS.get(key, BACKDROPS.prontera)
	_env.background_color = b[0]
	_ground.modulate = Color(b[1], 1.0) * Color(1.3, 1.3, 1.3)



func turn(d: int) -> void :
	dir = posmod(d, RoSprite.DIRS)
	if ro == null:
		return
	var act: = RoVisual.PC_IDLE * RoSprite.DIRS + dir
	_sub = ro.anim_sub(act)
	var tex: = ro.get_frame(act, 0, _sub)
	_hero.texture = tex
	if tex != null:
		var s: = tex.get_size()

		_hero.offset = Vector2(s.x * 0.5 - ro.origin.x, ro.origin.y - s.y * 0.5)



func wear(looks: Array, aura: bool) -> void :
	if _holder != null and is_instance_valid(_holder):
		_holder.queue_free()
	_holder = Node3D.new()
	add_child(_holder)
	_looks = looks
	_trail = looks.has("trail")
	if not _trail:
		_hero.position.x = 0.0
		turn(dir)
	if aura:
		var a: = RebirthAura.new()
		a.gold = looks.has("gold")
		_holder.add_child(a)
	if not looks.is_empty():
		var f: = RebirthFlair.new()
		f.looks = looks
		f.height = (ro.origin.y if ro != null else 90.0) * GameData.PIXEL_SIZE
		_holder.add_child(f)



var _sub: = 0


func _process(delta: float) -> void :
	if ro == null:
		return
	if not _trail:
		var act: = RoVisual.PC_IDLE * RoSprite.DIRS + dir
		if ro.anim_steps(act) > 1 and ro.anim_sub(act) != _sub:
			turn(dir)
		return

	_t += delta
	_hero.position.x = sin(_t * 1.4) * 0.55
	var d: = 6 if cos(_t * 1.4) > 0.0 else 2
	var act: = RoVisual.PC_WALK * RoSprite.DIRS + d
	var n: = maxi(1, ro.frame_count(act))
	var tex: = ro.get_frame(act, int(_t * 8.0) % n)
	if tex != null:
		_hero.texture = tex
		var s: = tex.get_size()
		_hero.offset = Vector2(s.x * 0.5 - ro.origin.x, ro.origin.y - s.y * 0.5)
	_ghost_t -= delta
	if _ghost_t > 0.0 or _hero.texture == null:
		return
	_ghost_t = 0.09
	var g: = Sprite3D.new()
	g.texture = _hero.texture
	g.offset = _hero.offset
	g.pixel_size = _hero.pixel_size
	g.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	g.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	g.shaded = false
	g.modulate = Color(RebirthFlair.GOLD if _looks.has("gold") else RebirthFlair.PALE, 0.45)
	g.position = _hero.position - Vector3(0, 0, 0.01)
	add_child(g)
	var tw: = g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.35)
	tw.tween_callback(g.queue_free)


func height() -> float:
	return (ro.origin.y if ro != null else 90.0) * GameData.PIXEL_SIZE
