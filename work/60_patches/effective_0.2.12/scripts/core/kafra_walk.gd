extends Node













var world: World

var kafra: = {}
var _next: = 0.0


var mvp_hp: = 0.0
var valk_hp: = 0.0
var ymir: = 0.0

var _star_hits: = {}

var _seen_looks: Array = []


func _init(w: World) -> void :
	world = w
	name = "KafraWalk"


func reset() -> void :
	_clear()
	_next = float(_val("every"))
	mvp_hp = 0.0
	valk_hp = 0.0
	ymir = 0.0
	_star_hits.clear()
	_seen_looks.clear()
	if _aura != null and is_instance_valid(_aura):
		_aura.queue_free()
	_aura = null





var emp_mult: = 1.0


func level() -> int:
	return mini(Save.upgrade_active("kafra_walk"), int(GameData.SAGE_UPGRADES.kafra_walk.max))



func _val(key: String):
	var kw: Dictionary = GameData.KAFRA_WALK
	if key == "every":
		return kw.every_lv5 if level() >= 5 else (kw.every_lv3 if level() >= 3 else kw.every)
	if level() >= 4 and (kw.strong as Dictionary).has(key):
		return kw.strong[key]
	return kw[key]


func on_here() -> bool:
	return level() > 0 and world.running and not world.training and not world.festival_mode and world.tower == null\
	and world.town == null and world.world_boss == null and not world.showcase and not world.is_coop()\
	and ( not world.autopilot or GameData.has_meta("kafra_walk_test"))


func held() -> bool:
	return world.raid.active() or world.morroc.active()


func tick(delta: float) -> void :
	_tick_star(delta)
	if not on_here():
		if not kafra.is_empty():
			_leave(false)
		return
	if held():
		if not kafra.is_empty():
			_leave(true)
		return
	if kafra.is_empty():
		_next -= delta
		if _next <= 0.0:
			_next = float(_val("every"))
			_spawn()
		return
	kafra.life -= delta
	var node: Node3D = kafra.node
	if is_instance_valid(node):
		var bang: Node3D = node.get_node_or_null("Bang")
		if bang != null:
			bang.position.y = 2.9 + 0.15 * absf(sin(Time.get_ticks_msec() * 0.006))


	var p: = world.player
	var near: = p != null and not p.downed and p.hp > 0.0\
	and Vector2(p.position.x - kafra.pos.x, p.position.z - kafra.pos.z).length() < float(GameData.KAFRA_WALK.reach)
	if not near:
		kafra["asked"] = false
	elif not bool(kafra.get("asked", false)) and not world.menus.is_open():
		kafra["asked"] = true
		world.menus.show_kafra_walk(kafra.opts)
		return
	if kafra.life <= 0.0:
		_leave(true)





func offer() -> Array:

	var n: = mini(4, int(GameData.KAFRA_WALK.options) + (1 if level() >= 2 else 0))
	var pool: Array = (GameData.KAFRA_WALK.pool as Array).filter( func(id):
		if id == "valk_half":
			return world.karma != null and world.karma.path != "" and valk_hp <= 0.0
		if id == "mvp_half":
			return mvp_hp <= 0.0
		if id == "ymir":
			return ymir <= 0.0
		if id == "golden":
			return world.runner == null or not is_instance_valid(world.runner)
		return true)
	pool.shuffle()
	return ["emperium"] + pool.slice(0, n - 1)



func opt_desc(id: String) -> String:
	var d: = TranslationServer.translate(str(GameData.KAFRA_WALK_OPTS[id].desc))
	match id:
		"emperium":
			return d % [_num(float(_val("emp_mult"))), int(_val("emp_time"))]
		"mvp_half", "valk_half":
			return d % roundi(float(_val("mvp_hp")) * 100.0)
		"ymir":
			return d % int(_val("ymir"))
		"star":
			return d % int(_val("star_time"))
	return d



static func _num(v: float) -> String:
	var t: = String.num(v, 2).trim_suffix("0").trim_suffix(".")
	var loc: = TranslationServer.get_locale()
	return t if loc.begins_with("en") or loc.begins_with("zh") or loc.begins_with("th") else t.replace(".", ",")



func pick(id: String) -> void :
	var p: = world.player
	match id:
		"emperium":
			emp_mult = float(_val("emp_mult"))
			p.add_power("kafra_emperium", float(_val("emp_time")))
			world.spawn_fx("joblvup", p.position, 1.0, 0.8, p)
			world.play_sound("increase_agi", 0.0, -2.0)
		"mvp_half":
			mvp_hp = float(_val("mvp_hp"))
		"valk_half":
			valk_hp = float(_val("mvp_hp"))
		"ymir":
			ymir = float(_val("ymir"))
		"sweep":
			_sweep()
		"golden":


			if world.runner != null and is_instance_valid(world.runner) and not world.runner.dead:
				world.runner.runner_life = float(GameData.RUNNER.life)
			else:
				world.spawn_runner()
		"star":
			p.add_power("kafra_star", float(_val("star_time")))
			_star_hits.clear()
			world.play_sound("increase_agi", 0.0, 0.0)
			world.spawn_fx("joblvup", p.position, 1.2, 1.0, p)
	if id != "emperium" and id != "star":
		world.number(p.position + Vector3(0, 2.6, 0), TranslationServer.translate(str(GameData.KAFRA_WALK_OPTS[id].name)), GameData.KAFRA_WALK.color, true)
	_leave(true, true)




func _sweep() -> void :
	var at: = world.player.position
	world.shake(0.6)
	world.play_sound("magnus", 0.0, -2.0)
	for i in 3:
		Vfx.ring(world.fx_root, at + Vector3(0, 0.1, 0), 10.0 + 12.0 * i, Color(1.0, 0.95, 0.8), 0.6 + 0.25 * i)
	world.hud.flash(Color(1.0, 0.97, 0.85), 0.4)
	for e in world.enemies.duplicate():
		if _common(e):
			world._kill(e)




func _common(e: Enemy) -> bool:
	return is_instance_valid(e) and not e.dead and not e.is_boss and not bool(e.def.get("elite", false))\
	and not bool(e.def.get("mvp", false)) and e.prop == "" and e != world.runner and e != world.antonio and e != world.boss\
	and not e.has_meta("festival")





func _tick_star(delta: float) -> void :
	var p: = world.player
	if p == null or not p.powers.has("kafra_star"):
		if _aura != null:
			_star_end()
		return


	if _aura == null or not is_instance_valid(_aura):
		_star_begin(p)
	var kw: Dictionary = GameData.KAFRA_WALK
	for e in world.enemies_in_radius(p.position, 2.2):
		if not is_instance_valid(e) or e.dead:
			continue
		var reach: = p.radius + e.radius + 0.35
		if Vector2(e.position.x - p.position.x, e.position.z - p.position.z).length() > reach:
			continue
		var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
		if _common(e):
			world.play_sound("hit", 0.1, -6.0)
			world.spawn_fx("hit", e.position + Vector3(0, 0.7, 0), 0.9)
			world._kill(e)

			var tw: = e.create_tween()
			tw.tween_property(e, "position", e.position + away * 7.0 + Vector3(0, 3.5, 0), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(e, "rotation:z", TAU * 1.5, 0.45)
		elif world.clock >= float(_star_hits.get(e.get_instance_id(), 0.0)):
			_star_hits[e.get_instance_id()] = world.clock + float(kw.star_gap)
			world.damage_by = p
			world.damage_tag = "kafra_star"
			world.damage_enemy(e, p.basic_atk() * float(kw.star_hit), away * 2.0, "skill", p.basic_element(), "kafra_star")
			world.spawn_fx("hit", e.position + Vector3(0, 1.0, 0), 1.2)




var _aura: Node3D
func _star_begin(p: Player) -> void :
	_aura = RebirthAura.new()
	_aura.gold = true
	_aura.scale = Vector3.ONE * 1.25
	p.add_child(_aura)
	world.play_sound("job_levelup", 0.0, -2.0)
	world.spawn_fx("joblvup", p.position, 1.2, 1.0, p)
	world.play_music_map(str(GameData.KAFRA_WALK.star_bgm))




func _star_end() -> void :
	if _aura != null and is_instance_valid(_aura):
		_aura.queue_free()
	_aura = null
	if world.player != null:
		world.player._power_look()
	if world.running and world._music_track == "map:" + str(GameData.KAFRA_WALK.star_bgm):
		world.play_music("map", true)



func _spawn() -> void :
	var kw: Dictionary = GameData.KAFRA_WALK
	var from: Vector3 = world.player.position
	var at: = Vector3.INF
	for k in 3:
		var near: = float(kw.dist[0]) * (1.0 if k == 0 else 0.6 if k == 1 else 0.3)
		for i in 16:
			var q: = world.map.find_point_around(from, near, float(kw.dist[1]))
			if q != Vector3.INF and world.map.can_reach(q, from):
				at = q
				break
		if at != Vector3.INF:
			break
	if at == Vector3.INF:
		_next = 5.0
		return
	at = Vector3(at.x, world.map.height_at(at), at.z)
	var look: String = (GameData.KAFRAS as Array).pick_random()
	var node: = Node3D.new()
	world.run_root.add_child(node)
	node.global_position = at
	var npc: = RoVisual.new()
	node.add_child(npc)
	npc.setup(RoAssets.sprite([look]), Color.WHITE, 20, 1.0)
	npc.play(0, true)
	npc.face(Vector3(0, 0, 1))

	var glow: = Vfx.ground_glow(node, Vector3(0, 0.05, 0), 1.6, Color(kw.color, 0.5))
	glow.name = "Glow"
	var bang: = Label3D.new()
	bang.name = "Bang"
	bang.text = "!"
	bang.font_size = 72
	bang.outline_size = 14
	bang.modulate = Color(1.0, 0.85, 0.3)
	bang.outline_modulate = Color(0.3, 0.15, 0.0)
	bang.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bang.no_depth_test = true
	bang.pixel_size = 0.01
	bang.position = Vector3(0, 2.9, 0)
	node.add_child(bang)
	Vfx.column(world.fx_root, at, Color(kw.color))
	world.play_sound("teleport", 0.0, -6.0)

	var sister: = str(GameData.KAFRA_SISTERS.get(look, ""))
	kafra = {"pos": at, "look": look, "life": float(kw.life), "node": node, "opts": offer(), 
		"sister_before": sister != "" and _seen_looks.has(sister)}
	_seen_looks.append(look)
	world.hud.alerts.warn(TranslationServer.translate("¡Una Kafra ambulante te espera en el mapa! Ve a verla"), Color(kw.color), "party_alarm")



func _leave(warp: bool, served: = false) -> void :
	if kafra.is_empty():
		return
	var node = kafra.node
	var at: Vector3 = kafra.pos
	kafra = {}
	if warp:
		Vfx.column(world.fx_root, at, Color(GameData.KAFRA_WALK.color))
		world.play_sound("teleport", 0.0, -4.0)
	if served:
		world.number(at + Vector3(0, 2.4, 0), TranslationServer.translate("¡Gracias por usar el Servicio Kafra!"), GameData.KAFRA_WALK.color, true)
	if node != null and is_instance_valid(node):
		(node as Node).queue_free()


func _clear() -> void :
	if not kafra.is_empty() and is_instance_valid(kafra.node):
		(kafra.node as Node).queue_free()
	kafra = {}



func declined() -> void :
	_leave(true)




func boss_hp_cut(mob: String) -> float:
	var valk: = false
	for r in GameData.KARMA_ROUTES.values():
		if str(r.mvp) == mob:
			valk = true
	var keep: = 1.0
	if valk and valk_hp > 0.0:
		keep = valk_hp
		valk_hp = 0.0
	elif not valk and mvp_hp > 0.0:
		keep = mvp_hp
		mvp_hp = 0.0
	return keep


func take_ymir() -> float:
	var y: = ymir
	ymir = 0.0
	return y



func pointer_label() -> String:
	return "%s  ·  %d s" % [TranslationServer.translate("Kafra"), ceili(maxf(0.0, float(kafra.life)))]


var _face_tex: = {}

func face() -> Texture2D:
	var look: = str(kafra.get("look", ""))
	if look == "":
		return null
	if not _face_tex.has(look):
		var spr: = RoAssets.sprite([look])
		var tex: Texture2D = null
		if spr != null:
			var img: = spr.compose_image(0, 0)
			var used: = img.get_used_rect()
			if used.has_area():
				img = img.get_region(used)
				var k: = minf(30.0 / img.get_width(), 30.0 / img.get_height())
				img.resize(maxi(1, int(img.get_width() * k)), maxi(1, int(img.get_height() * k)), Image.INTERPOLATE_NEAREST)
				tex = ImageTexture.create_from_image(img)
		_face_tex[look] = tex
	return _face_tex[look]
