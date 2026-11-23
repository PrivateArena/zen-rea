class_name Enemy
extends Node3D


var id: = ""

var nid: = 0
var def: = {}
var hp: = 1.0
var max_hp: = 1.0
var speed: = 1.0
var damage: = 1.0
var radius: = 0.4
var xp: = 1
var dead: = false
var is_boss: = false


var mvp_pace: = 0.0


var visual
var _renderer: MobRenderer
var brain: BossBrain
var knock: = Vector3.ZERO
var slow_time: = 0.0

var poison_time: = 0.0
var poison_dps: = 0.0

var poison_stacks: = 0
var poison_tick: = 0.5

var poison_tag: = ""


var poison_by: Player



var burn_dps: = 0.0

var burn_pool: = 0.0
var burn_heat: = 0
var burn_time: = 0.0
var burn_tick: = 0.5
var burn_tag: = ""
var burn_by: Player
var blood: = 0.0
var blood_stacks: = 0
var blood_time: = 0.0
var blood_tag: = ""
var blood_by: Player
var last_hit_by: Player

var status: = ""
var status_time: = 0.0


var far_dt: = 0.0
var far_skip: = false

var far_t: = 0.0


var snare_time: = 0.0
var trapped_until: = 0.0

var trap_vuln: = 0.0

var sleep_hits: = 0


var status_cd: = 0.0

var status_cd_kind: = ""


var cc_dr: = {}

var blind_time: = 0.0

var signum_until: = 0.0
var signum_frail: = 0.0


var lex_until: = 0.0
var lex_mult: = 1.0

var acid_until: = 0.0


var night_until: = 0.0

var fear_until: = 0.0
var fear_vuln: = 0.0

var web_until: = 0.0


var coma_ready: = 0.0
var coma_until: = 0.0


var judgment: = 0
var judgment_at: = -99.0
var judgment_seen: = -99.0
var acid_frail: = 0.0

var combo_mark: = ""
var combo_until: = 0.0



var boss_mark: = ""
var boss_mark_until: = 0.0

var kunai_stuck: = 0
var kunai_until: = 0.0
var kunai_el: = "neutral"

var summoned: = false

var shoot_cd: = 1.5
var hit_cd: = 0.0


var hold: = 0.0
var target: Node3D


var hero_target: Player



var taunt_by: Player
var taunt_until: = 0.0
var taunt_vuln: = 0.0

var weak_mult: = 0.0
var weak_until: = 0.0
var _retarget: = 0.0
const RETARGET: = 0.5
var attack_anim: = 0.0

var _push: = Vector3.ZERO

var _flow: = Vector3.ZERO
var _phase: = randi() % World.REFRESH_EVERY




const MobTraits = preload("res://scripts/core/mob_traits.gd")
var kin: = 0
var kin_t: = 0.0
var kin_on: = 0
var kin_c: = 0
var kin_n: = 0.0
var kin_v: = Vector3.ZERO
var kin_ref



var _ghost: = false
var _rooted: = false
var _weave: = 0.0
var knock_k: = 1.0
var _float_y: = 0.0

var hit_el: = ""

var prop: = ""



var feroz: = false
var special: = ""


var title_label: Label3D



var kyrie: = 0.0
var affixes: = PackedStringArray()
var affix_t: = {}

var _look_k: = 0
var _kyrie_on: = false


var runner_life: = 0.0
var runner_dmg: = 0.0

var runner_calm: = true
var _flee: = Vector3.ZERO
var _flee_t: = 0.0
var _stuck_t: = 0.0

var _gaze: = Vector3.ZERO
var _gaze_t: = 0.0


func _init() -> void :

	add_to_group(RoVisual.VIEW_GROUP)
	rotation.y = RoVisual.view_yaw




# [MOD] ceiling for the time-in-round scaling curve (see Enemy.setup): at most 3x the monster table
# HP/damage from the round clock. Tower-floor and hell-level growth are separate and stay as designed.
const MOD_TIME_SCALE_CAP: = 3.0
# [MOD] one-shot proof that this (patch-layer) script is the one the running process loaded.
# Enemy.setup() fires on every spawn in every mode, so the probe lands within seconds of a run start.
const MOD_TAG: = "mod-v14 on 0.2.7 caps: clock=3.0 tower_floor=90 trap_pct=0.10 mechanics_pct=0.15 choice_w=[52,27,15,6] xp=1.5 crumb=2.5 crumb_sites=2 pot_up=[30,18] pot_same=0.85 perfect=0.80 stats_w=12 refine=x2 grade=[1,1.15,1.5,2,2.6] altar_w=[6,3,0.8] karma_baldur=0.75 gacha_odds=[40,30,15,10,5] event_w=emperium9 emp_grow=1.4 emp_time=15 emp_prizes=[5,7,9,12,16]"
static var mod_probe_done: = false
static var mod_probe_spawns: = 0
static var mod_clock_capped: = 0
const NO_RANGED: = {}
var _ranged: Dictionary = NO_RANGED


var shots_missed: = 0
var _static: = false

var _immovable: = false


var touch_dmg: = 0.0
var _touch_wait: = {}


func setup(p_id: String, hp_scale: float, renderer: MobRenderer = null, time_scale: = -1.0, own_sprite: = false) -> void :
	if time_scale < 0.0:
		time_scale = hp_scale
	# [MOD] cap the time-in-round curve only (scale_hp = 1 + t/150 reaches 9.9x at 20 min, and on tower
	# floors scale_time() = 5 s per floor so it is already at 9.9x around floor 267). hp_scale also
	# carries the danger/hell/coop/karma multipliers, so those are kept: the excess time factor is
	# divided out instead of clamping the whole product, and the same cap then bounds contact damage.
	if time_scale > MOD_TIME_SCALE_CAP:
		hp_scale /= time_scale / MOD_TIME_SCALE_CAP
		time_scale = MOD_TIME_SCALE_CAP
		mod_clock_capped += 1
	id = p_id
	# [MOD] mount + effect probe: Enemy.setup() runs for every spawn in every mode, so the file appears
	# a second after a run starts, and is rewritten every 512 spawns with the running counters.
	mod_probe_spawns += 1
	if not mod_probe_done or mod_probe_spawns % 512 == 0:
		mod_probe_done = true
		print("MODPROBE enemy.gd mounted: %s pid=%d spawns=%d clock_capped=%d" % [
			MOD_TAG, OS.get_process_id(), mod_probe_spawns, mod_clock_capped])
		var mf: = FileAccess.open("user://mod_probe_enemy.txt", FileAccess.WRITE)
		if mf != null:
			mf.store_string("%s\nmonster=%s\nspawns=%d\nclock_capped=%d (%.1f%%)\npid=%d\nat=%s\n" % [
				MOD_TAG, p_id, mod_probe_spawns, mod_clock_capped, 100.0 * mod_clock_capped / mod_probe_spawns,
				OS.get_process_id(), Time.get_datetime_string_from_system()])
			mf.close()
	def = GameData.MONSTERS[id]
	cc_dr = {}

	_ranged = def.get("ranged", NO_RANGED)
	shots_missed = 0
	_static = bool(def.get("static", false))
	_immovable = bool(def.get("dummy", false))
	touch_dmg = float(def.get("touch", 0.0))
	_touch_wait = {}
	max_hp = def.hp * hp_scale
	hp = max_hp
	speed = def.speed * randf_range(0.9, 1.1)
	damage = def.damage * (1.0 + (time_scale - 1.0) * 0.6) * 1.25
	radius = def.radius
	xp = def.xp
	prop = str(def.get("prop", ""))

	var look_id: = str(def.get("sprite_of", id))
	if not def.has("boss") and prop == "" and not own_sprite and renderer != null and renderer.prepare(look_id):
		_renderer = renderer
		visual = renderer.new_anim(look_id, self)
	else:
		var v: = RoVisual.new()
		add_child(v)

		v.setup(RoAssets.sprite([look_id]), def.color, def.size_px, 0.0)
		if prop != "":
			v.show_through(0.6)
		visual = v
		if def.has("model"):
			_model_look(v, str(def.model), float(def.get("model_h", 1.0)))
	visual.play(RoVisual.MOB_WALK)

	if not _static and prop == "" and not def.has("boss") and not def.get("elite", false):
		kin = MobTraits.OF.get(id, 0)
		if kin != 0:
			MobTraits.dress(self)
	if def.has("boss"):
		is_boss = true
		brain = BossBrain.new(self, def.boss)


		if not def.get("mvp", false) and visual is RoVisual:
			if def.has("look_scale"):
				(visual as RoVisual).scale = Vector3.ONE * float(def.look_scale)
			if def.has("tint"):
				(visual as RoVisual).tint = def.tint
				(visual as RoVisual).sprite.modulate = def.tint
	if def.get("mvp", false):
		_mvp_look()




func _mvp_look() -> void :
	radius *= GameData.MVP_RADIUS
	if visual is RoVisual:
		var v: RoVisual = visual
		v.scale = Vector3.ONE * GameData.MVP_SCALE




		v.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		v.sprite.render_priority = GameData.MVP_PRIORITY
	var aura: = MvpAura.new()
	aura.setup(GameData.RAIDS.get(id, {}).get("color", def.color), radius)
	add_child(aura)

	if def.has("tint") and visual is RoVisual:
		(visual as RoVisual).tint = def.tint
		(visual as RoVisual).sprite.modulate = def.tint
	if def.get("corrupt_aura", false):
		_corrupt_aura(1.8)


func make_ferocious() -> void :
	make_special("feroz")




func make_special(kind: String) -> void :
	var k: Dictionary = GameData.SPECIAL_KINDS.get(kind, GameData.SPECIAL_KINDS.feroz)
	feroz = true
	special = kind
	max_hp *= float(k.hp)
	hp = max_hp
	damage *= float(k.dmg)
	speed *= float(k.speed)
	xp *= int(GameData.FEROCIOUS.xp)
	_dress(float(k.scale), k.tint, k.glow, TranslationServer.translate(str(k.label)) % TranslationServer.translate(str(def.name)), k.text)
	if kind == "corrupto":
		_corrupt_aura(float(k.scale))



func _corrupt_aura(size: float) -> void :
	var aura: = RebirthAura.new()
	aura.corrupt = true
	aura.scale = Vector3.ONE * size
	add_child(aura)



func make_runner(life: float) -> void :
	special = "runner"
	runner_life = life
	damage = 0.0
	radius *= float(GameData.RUNNER.scale) * 0.8
	_dress(float(GameData.RUNNER.scale), Color(1.0, 0.95, 0.7), Color(1.0, 0.8, 0.2, 0.6), TranslationServer.translate(str(def.name)), GameData.RUNNER.color)


func _dress(size: float, tint: Color, glow_color: Color, title: String, title_color: Color) -> void :
	if visual is RoVisual:
		var v: RoVisual = visual
		v.scale = Vector3.ONE * size
		v.sprite.modulate = tint
	var glow: = Vfx.ground_glow(self, Vector3(0, 0.04, 0), radius * 3.0, Color(glow_color, 0.9))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.45, 0.45).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 1.0, 0.45).set_trans(Tween.TRANS_SINE)


	var ring: = Vfx._flat(self, Vfx.ring_texture(), Vector3(0, 0.06, 0), radius * 2.4, Color(title_color, 0.95))
	var spin: = ring.create_tween().set_loops()
	spin.tween_property(ring, "rotation:y", TAU, 2.4).as_relative()
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.16, 0.16)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 32)
	quad.material = pm
	p.mesh = quad
	p.amount = 10
	p.lifetime = 1.1
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	p.emission_ring_axis = Vector3.UP
	p.emission_ring_radius = radius * 1.1
	p.emission_ring_inner_radius = radius * 0.6
	p.emission_ring_height = 0.0
	p.direction = Vector3.UP
	p.spread = 8.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 1.0
	p.initial_velocity_max = 1.8
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(title_color, 0.0))
	ramp.add_point(0.2, Color(title_color, 1.0))
	ramp.set_color(ramp.get_point_count() - 1, Color(title_color, 0.0))
	p.color_ramp = ramp
	p.position = Vector3(0, 0.2, 0)
	add_child(p)
	var l: = Label3D.new()
	l.text = title
	l.font = World.RO_UI_FONT
	l.font_size = 28
	l.pixel_size = 0.012
	l.outline_size = 8
	l.outline_modulate = Color(0, 0, 0, 0.9)
	l.modulate = title_color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 20
	l.outline_render_priority = 19

	var up: = Vector3(0, cos(World.CAMERA_PITCH), - sin(World.CAMERA_PITCH))
	l.position = RoVisual.lift + up * (visual.height() * size + 0.45)
	add_child(l)
	title_label = l




func set_look(k: int) -> void :
	_look_k = clampi(k, 0, MobTraits.LOOK_TINT.size() - 1)
	_show_look()



func set_kyrie(on: bool) -> void :
	if on == _kyrie_on:
		return
	_kyrie_on = on
	_show_look()



func _show_look() -> void :
	if visual is MobAnim:
		visual.look = (_look_k + (4 if _kyrie_on else 0)) * 2.0
	elif visual is RoVisual:
		var v: RoVisual = visual
		v.tint = MobTraits.LOOK_TINT[_look_k] * (Color(0.85, 0.95, 1.25) if _kyrie_on else Color.WHITE)
		v.sprite.modulate = v.tint




func net_special() -> String:
	var extra: = Array(affixes)
	if kyrie > 0.0:
		extra.append("kyrie")

	if has_meta("training_hitter"):
		extra.append("hitter")


	if has_meta("mvp_shadow"):
		extra.append("shadow")
	if has_meta("profane"):
		extra.append("profane")
	return special if extra.is_empty() else "%s|%s" % [special, ",".join(extra)]



func add_title_line(text: String) -> void :
	if text == "":
		return
	for c in get_children():
		if c is Label3D:
			(c as Label3D).text += "\n" + text
			return



func element() -> String:
	if status != "" and GameData.STATUS_ELEMENT.has(status):
		return GameData.STATUS_ELEMENT[status]
	return own_element()




var element_override: = ""
func own_element() -> String:
	return element_override if element_override != "" else GameData.monster_element(id)


func set_status(kind: String, duration: float) -> void :
	sleep_hits = 0
	status = kind
	status_time = duration
	_update_tint()




func _model_look(v: RoVisual, model: String, h: float) -> void :
	var path: = RoAssets.model_path(model)
	if path == "":
		return

	var pivot: = Node3D.new()
	v.add_child(pivot)
	var m: = (load(path) as PackedScene).instantiate() as Node3D
	pivot.add_child(m)
	Altars._fit_height(m, h)
	v.sprite.visible = false
	var tw: = pivot.create_tween().set_loops()
	tw.tween_property(pivot, "rotation:y", TAU, 6.0).from(0.0)




func shrink(seconds: float) -> void :
	if visual is MobAnim:
		visual.shrink = seconds


func clear_status() -> void :
	status_cd_kind = status
	status = ""
	status_time = 0.0
	status_cd = GameData.STATUS_RESIST_TIME
	_update_tint()




func _update_tint() -> void :
	var t: = 0.0
	match status:
		"freeze":
			t = 1.0
		"stone":
			t = 2.0
		"sleep":
			t = 3.0
	if t == 0.0 and burn_time > 0.0:
		t = 6.0
	elif t == 0.0 and poison_time > 0.0:

		t = 5.0 + 0.45 * clampf(float(poison_stacks) / float(GameData.POISON_MAX_STACKS), 0.0, 1.0)
	elif t == 0.0 and blood_stacks > 0:
		t = 7.0
	if visual is MobAnim:
		visual.tint = t
		visual.speed_scale = 0.0 if status in ["freeze", "stone"] else 1.0
	elif visual is RoVisual:
		visual.speed_scale = 0.0 if status in ["freeze", "stone"] else 1.0








func frame(delta: float, world: World, hx: float, hz: float, far2: float, lost2: float, party: bool) -> void :
	var ep: = position
	var d2: = (ep.x - hx) * (ep.x - hx) + (ep.z - hz) * (ep.z - hz)
	if not is_boss and d2 > far2 and ( not party or world._far_from_party(ep, far2)):
		if d2 > lost2 and not feroz and not summoned and prop == "" and ( not party or world._far_from_party(ep, lost2)):
			far_t += delta
			if far_t > GameData.RECYCLE_AFTER:
				far_t = 0.0
				var back: = world._offscreen_point()
				if back != Vector3.INF:
					position = Vector3(back.x, world.map.height_at(back), back.z)
					knock = Vector3.ZERO
					world._grid_fresh = false
		else:
			far_t = 0.0
		far_dt += delta
		if far_skip:
			far_skip = false
			return
		far_skip = true
		tick(far_dt, world)
		far_dt = 0.0
		return
	if far_dt > 0.0:

		delta += far_dt
		far_dt = 0.0
		far_skip = false
	tick(delta, world)


func tick(delta: float, world: World) -> void :
	if _immovable:

		knock = Vector3.ZERO
	hit_cd -= delta
	slow_time -= delta
	snare_time -= delta
	blind_time -= delta
	attack_anim -= delta
	status_cd -= delta

	if touch_dmg > 0.0:
		_touch_heroes(delta, world)
	if has_meta("training_hit"):
		_training_hits(delta, world)
	if status != "":

		status_time -= delta
		if status_time <= 0.0:
			clear_status()
		else:
			if kin_on != 0:
				world.traits.broken(self)
			knock = knock.move_toward(Vector3.ZERO, delta * 30.0)
			if knock.length_squared() > 0.0:
				position = world.map.step(position, knock * delta)
			return
	if _static:

		return
	if special == "runner":
		if runner_calm:
			visual.play(RoVisual.MOB_IDLE)
			return
		_run_away(delta, world)
		return
	if world.morroc_fight and world.morroc.dazes(self):
		_look_around(delta, world)
		return

	var player: Player = world.player if world.heroes.size() <= 1 else _hero(world, delta)
	if player == null:

		if attack_anim <= 0.0:
			visual.play(RoVisual.MOB_IDLE)
		return
	var goal: Node3D = player if target == null or not is_instance_valid(target) else target
	var to_player: = goal.position - position
	to_player.y = 0
	var dist: = to_player.length()
	hold -= delta
	var controlled: = (brain != null and brain.tick(delta, world)) or hold > 0.0

	var here: = position



	var turn: = _phase == world.frame_parity


	if kin != 0:
		kin_t -= delta
		if summoned or goal != player:

			if kin_on != 0:
				world.traits.broken(self)
			MobTraits.plain(self)
		elif kin_on != 0 or kin_t <= 0.0:
			if controlled:
				if kin_on != 0:
					world.traits.broken(self)
			elif world.traits.think(self, delta, world, player, to_player, dist):
				return
	var move: = Vector3.ZERO
	if not controlled:
		var spd: = speed * (0.45 if slow_time > 0.0 else 1.0)

		if world.frenzy and not is_boss:
			spd = minf(spd, player.move_speed * GameData.FRENZY_MOB_SPEED)
		if mvp_pace > 0.0:
			spd = minf(spd, maxf(mvp_pace, player.move_speed * GameData.MVP_SPEED_MAX))
		if dist > 0.01:
			move = to_player / dist * spd
			if goal == player and not _ghost:
				if turn:
					_flow = world.flow_of(player).direction(here)
				if _flow != Vector3.ZERO:
					move = _flow * spd
			if _weave != 0.0:

				move += Vector3( - move.z, 0.0, move.x) * (sin(world.clock * MobTraits.WEAVE_RATE + _weave) * MobTraits.WEAVE)


		var rng: Dictionary = _ranged
		if not rng.is_empty() and dist < float(rng.range) * 0.7 and shots_missed < GameData.RANGED_MISS_WALK:
			move = Vector3.ZERO
		if turn:
			_push = world.mob_grid.push_of(self, here.x, here.z, radius)


		var sep: = _push * 2.2
		if move != Vector3.ZERO:
			var fwd: = move.normalized()
			var back: = sep.dot(fwd)
			if back < 0.0:
				sep -= fwd * back * GameData.SEP_BACK_CUT
		move += sep.limit_length(spd * GameData.SEP_MAX_SHARE + 0.5)

	if snare_time > 0.0 or _rooted:
		move = Vector3.ZERO
	move += knock
	knock = knock.move_toward(Vector3.ZERO, delta * 30.0)
	if move.length_squared() > 0.0:
		if _ghost:


			here.x += move.x * delta
			here.z += move.z * delta
			if turn:
				_float_y = world.map.height_at(here)
			here.y = lerpf(here.y, _float_y, minf(1.0, delta * 8.0))
		else:
			here = world.map.step(here, move * delta)
		position = here

	if dist > 0.01 and (turn or attack_anim > 0.0):
		visual.face(to_player)


	if attack_anim <= 0.0 and (visual.base_action != RoVisual.MOB_WALK or visual._done):
		visual.play(RoVisual.MOB_WALK)
	var ranged: Dictionary = _ranged



	if not ranged.is_empty() and not controlled and not (world.morroc_fight and world.morroc.walled(self)):
		shoot_cd -= delta
		if shoot_cd <= 0.0 and dist <= float(ranged.range):
			shoot_cd = float(ranged.every) * randf_range(0.85, 1.15)
			attack_anim = 0.5
			visual.play(RoVisual.MOB_ATTACK, false, true)
			world.play_mob_sound(id, "attack")
			world.enemy_attack(self, ranged)
	if hit_cd > 0.0:
		return

	var bitten: Node3D = null
	if goal != player or world.heroes.size() <= 1:
		if dist < radius + player.radius:
			bitten = goal
	else:
		for h in world.heroes:
			if not h.downed and not h.choosing and Vector2(h.position.x - here.x, h.position.z - here.z).length() < radius + h.radius:
				bitten = h
				break
	if bitten == null:
		return
	hit_cd = 0.9
	attack_anim = 0.5
	visual.play(RoVisual.MOB_ATTACK, false, true)
	world.play_mob_sound(id, "attack")
	if bitten is Player:
		bitten.take_damage(damage, world, self)
		if GameData.SPECIAL_KINDS.get(special, {}).get("hex", false):
			world.hex_player(self, bitten)
	else:
		world.npc_hit(goal)






func _touch_heroes(delta: float, world: World) -> void :
	var reach: = radius * float(get_meta("big", 1.0))
	for h in world.heroes:
		var key: = h.get_instance_id()
		var wait: = maxf(0.0, float(_touch_wait.get(key, 0.0)) - delta)
		_touch_wait[key] = wait
		if wait > 0.0 or h.downed or h.choosing or h.hp <= 0.0:
			continue
		if Vector2(h.position.x - position.x, h.position.z - position.z).length() >= reach + h.radius:
			continue
		_touch_wait[key] = GameData.TOUCH_EVERY
		h.take_damage(touch_dmg, world, self)






var _train_wait: = 0.0
func _training_hits(delta: float, world: World) -> void :
	_train_wait -= delta
	if _train_wait > 0.0:
		return
	_train_wait = World.TRAINING_HIT_EVERY
	var struck: = false
	for h in world.heroes:
		if h.downed or h.choosing or h.hp <= 0.0:
			continue
		if Vector2(h.position.x - position.x, h.position.z - position.z).length() > World.TRAINING_HIT_REACH + h.radius:
			continue
		h.take_damage(float(get_meta("training_hit")), world, self)
		struck = true
	if struck:
		visual.flash()



func taunt(p: Player, until: float, vuln: float) -> void :
	taunt_by = p
	taunt_until = maxf(taunt_until, until)
	taunt_vuln = vuln
	hero_target = p
	_flow = Vector3.ZERO



func taunter(world: World) -> Player:
	return taunt_by if world.clock < taunt_until and world.targetable(taunt_by) else null




func _hero(world: World, delta: float) -> Player:
	if world.heroes.size() <= 1:
		return world.player
	var taunted: = taunter(world)
	if taunted != null:
		hero_target = taunted
		return taunted
	_retarget -= delta
	if _retarget > 0.0 and world.targetable(hero_target):
		return hero_target
	_retarget = RETARGET * randf_range(0.8, 1.2)
	var best: = world.nearest_hero(position)
	if best != hero_target and (best == null or not world.targetable(hero_target)\
	or position.distance_squared_to(best.position) < 0.5625 * position.distance_squared_to(hero_target.position)):
		hero_target = best
		_flow = Vector3.ZERO
	return hero_target





func _run_away(delta: float, world: World) -> void :
	var p: = world.nearest_hero(position) if world.heroes.size() > 1 else world.player
	if p == null:
		p = world.player
	var away: = (position - p.position) * Vector3(1, 0, 1)
	var dist: = away.length()
	away = away / dist if dist > 0.01 else Vector3(1, 0, 0)
	_flee_t -= delta
	if _flee_t <= 0.0 or _flee == Vector3.ZERO:
		_flee_t = 0.35
		var best: = - INF
		for i in 16:
			var a: = TAU * i / 16.0
			var d: = Vector3(cos(a), 0, sin(a))
			var score: = d.dot(away) * (1.0 if dist < 14.0 else 0.3) + randf() * 0.25

			var open: = 0
			for step in [1.0, 2.2, 3.6]:
				if world.map.is_walkable(position + d * step):
					open += 1
			if open < 3:
				score -= 2.0 + (3 - open)

			score += d.dot(_flee) * 0.35
			if score > best:
				best = score
				_flee = d
	var spd: = speed * (0.45 if slow_time > 0.0 else 1.0)
	var before: = position
	var move: = _flee * spd + knock
	knock = knock.move_toward(Vector3.ZERO, delta * 30.0)
	position = world.map.step(position, move * delta)

	if (position - before).length() < spd * delta * 0.3:
		_stuck_t += delta
		if _stuck_t > 0.2:
			_stuck_t = 0.0
			_flee_t = 0.0
			_flee = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	else:
		_stuck_t = 0.0
	visual.face(_flee)
	if attack_anim <= 0.0:
		visual.play(RoVisual.MOB_WALK)




func _look_around(delta: float, world: World) -> void :
	knock = knock.move_toward(Vector3.ZERO, delta * 30.0)
	if knock.length_squared() > 0.0:
		position = world.map.step(position, knock * delta)
	_gaze_t -= delta
	if _gaze_t <= 0.0:
		_gaze_t = randf_range(0.8, 2.4)
		var a: = randf() * TAU
		_gaze = Vector3(cos(a), 0, sin(a))
		visual.face(_gaze)
	if attack_anim <= 0.0:
		visual.play(RoVisual.MOB_IDLE)


func hurt(amount: float, push: Vector3) -> void :
	hp -= amount

	if not is_boss and not _immovable and not has_meta("steady"):
		var k: Dictionary = GameData.SPECIAL_KINDS.get(special, NO_RANGED) if special != "" else NO_RANGED
		var shove: = push * (0.0 if k.get("no_knock", false) else (float(GameData.FEROCIOUS.knock) if feroz else 1.0)) * knock_k

		knock = (knock + shove).limit_length(maxf(maxf(GameData.KNOCK_MIN_CAP, shove.length() * GameData.KNOCK_STACK), knock.length() if shove == Vector3.ZERO else 0.0))
	visual.flash()


func die() -> void :
	dead = true


	status = ""
	status_time = 0.0
	_update_tint()


	if not visual.finished.is_connected(_fade_out):
		visual.finished.connect(_fade_out, CONNECT_ONE_SHOT)
	visual.play(RoVisual.MOB_DEAD, false, true)


func _fade_out() -> void :
	var tw: = create_tween()
	if visual is RoVisual:
		tw.tween_property(visual.sprite, "modulate:a", 0.0, 0.3)
	else:
		tw.tween_property(visual, "alpha", 0.0, 0.3)
	tw.tween_callback(queue_free)


func _exit_tree() -> void :
	if _renderer != null:
		_renderer.untrack(str(def.get("sprite_of", id)), visual)
		_renderer = null
