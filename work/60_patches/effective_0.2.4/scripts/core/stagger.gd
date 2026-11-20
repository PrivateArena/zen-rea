extends RefCounted











const SIZE: = 40.0
const GROW: = 1.5

const PARTY: = 0.5


const STUN: = 2.5
const STUN_MAX: = 4.0
const LOCK: = 5.0

const SKILL_GAP: = 0.5

const BROKEN_DMG: = 0.3
const GOLD: = Color(1.0, 0.85, 0.35)




const THOR_SPAN: = 8.0
const THOR_TAG: = "thor_bolt"


var _of: = {}

var shown: = {}


var _dealt: = {}


func clear() -> void :
	_of.clear()
	shown.clear()
	_dealt.clear()
	_debuff_at.clear()







func on_hit(world: World, src: Player, e: Enemy, amount: float, source: String, tag: String) -> void :
	if src == null or tag == THOR_TAG or source == "poison":
		return
	var bolt: = float(src.effects.get("thor_bolt", 0.0))
	var per: = float(src.effects.get("stagger_hit", 0.0))
	if bolt <= 0.0 and per <= 0.0:
		return


	if not fits(world, e):
		return
	if bolt > 0.0 and e.is_boss:
		var id: = e.get_instance_id()
		if not _dealt.has(id):
			_dealt[id] = {}
		var mine: Dictionary = _dealt[id].get(src.get_instance_id(), {"t0": world.clock, "sum": 0.0})
		mine.sum = float(mine.sum) + maxf(0.0, amount)
		_dealt[id][src.get_instance_id()] = mine
	if per > 0.0 and (source == "basic" or source == "skill"):
		add(world, e, per, "hit:%d:%s" % [src.get_instance_id(), tag])



func _thor(world: World, e: Enemy, src: Player) -> void :
	if src == null or not is_instance_valid(src) or e.dead:
		return
	var secs: = float(src.effects.get("thor_bolt", 0.0))
	var mine = (_dealt.get(e.get_instance_id(), {}) as Dictionary).get(src.get_instance_id())
	if secs <= 0.0 or mine == null:
		return
	var dps: = float(mine.sum) / maxf(THOR_SPAN, world.clock - float(mine.t0))
	if dps <= 0.0:
		return
	thor_fx(world, e)

	if world.net != null and world.net.recording():
		world.net.record(["sgt", world.net.ref_of(e)])
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = THOR_TAG
	world.damage_by = src



	world.damage_enemy(e, dps * secs, Vector3.ZERO, "poison", "neutral", THOR_TAG)
	world.damage_tag = keep[0]
	world.damage_by = keep[1]






func thor_fx(world: World, e: Enemy, guest: = false) -> void :
	if e == null or not is_instance_valid(e):
		return
	var at: = e.position
	if guest:
		Vfx.beam_flash(world.fx_root, at, Color(0.75, 0.85, 1.0), 10.0)
		world.shake(0.35, true)
		return
	world.spawn_fx("lightning", at, 1.6, 1.0)
	world.get_tree().create_timer(0.08, false).timeout.connect( func():
		if is_instance_valid(world) and world.running:
			world.spawn_fx("lightning", at + Vector3(0.8, 0, -0.5), 1.1, 0.9))
	Vfx.beam_flash(world.fx_root, at, Color(0.75, 0.85, 1.0), 10.0)
	Vfx.burst(world.fx_root, at + Vector3(0, 1.0, 0), e.radius + 1.5, Color(0.7, 0.85, 1.0))
	world.play_sound("lightning_crash", 0.0, -1.0, -1.0, false, true)
	world.play_sound("thunder", 0.0, -3.0, -1.0, false, true)
	world.shake(0.35, true)




func fits(world: World, e: Enemy) -> bool:
	if e == null or e.dead or e.prop != "" or world.festival_mode:
		return false
	if not e.is_boss:
		return elite(world, e)



	if world.morroc != null and world.morroc.fighting() and not world.morroc.stagger_ok(e):
		return false
	if world.raid != null and world.raid.epic != null and world.raid.boss == e:
		return str(world.raid.epic.state) == "fight"
	return true






func add(world: World, e: Enemy, duration: float, key: = "", uncapped: = false) -> void :
	if not fits(world, e) or e.status == "stun":
		return

	if world.raid != null and world.raid.boss == e and (world.raid.untouchable(e) or (world.raid.has_method("calm") and world.raid.call("calm"))):
		return
	var id: = e.get_instance_id()
	if not _of.has(id):
		var size: = SIZE * (GameData.HELL_STAGGER_ELITE if not e.is_boss else 1.0)
		_of[id] = {"v": 0.0, "max": size * (1.0 + PARTY * maxi(0, world.heroes.size() - 1)), "breaks": 0, "lock": 0.0, "gaps": {}}
	var s: Dictionary = _of[id]
	if world.clock < float(s.lock):
		return
	var src: = world.acting_hero()

	var tag: = "%d|%s" % [src.get_instance_id() if src != null else 0, key if key != "" else str(world.damage_tag)]
	if world.clock < float(s.gaps.get(tag, 0.0)):
		return
	s.gaps[tag] = world.clock + SKILL_GAP
	var longer: = 1.0 + (float(src.effects.get("status_time", 0.0)) if src != null else 0.0)

	var fill: = 1.0 + (float(src.effects.get("wing_fill", 0.0)) if src != null else 0.0)

	if world.encore.on:
		fill *= world.encore.fill_mult(e)
	s.v = minf(float(s.max), float(s.v) + (duration if uncapped else minf(duration, GameData.STATUS_MAX_TIME)) * longer * fill)
	if float(s.v) < float(s.max):
		_show(world, e, float(s.v) / float(s.max), 0.0)
		return

	var stun: = minf(STUN * longer, STUN_MAX) + (float(src.effects.get("wing_stun", 0.0)) if src != null else 0.0)
	s.breaks = int(s.breaks) + 1
	s.v = 0.0
	s.max = float(s.max) * GROW
	s.lock = world.clock + stun + LOCK
	e.set_status("stun", stun)


	if world.raid != null and world.raid.boss == e:
		world.raid.interrupt()
	if e.brain != null:
		e.brain.interrupt()
	_show(world, e, 1.0, stun)


	if src != null and src == world.player and not world.training:
		Save.bump("stagger_breaks")
		if int(s.breaks) >= GameData.TITLE_BREAKS and e.def.get("mvp", false) and not world.is_coop() and not src.tampered:
			Save.mark_seen("titles", "thor_hammer")

	if src != null and float(src.effects.get("thor_bolt", 0.0)) > 0.0:
		_thor(world, e, src)




func elite(world: World, e: Enemy) -> bool:
	if e == null or e.is_boss or world.training:
		return false

	if e.def.get("elite", false) and pact_elites(world):
		return true


	if world.tower != null:
		return world.tower.hel != null and world.tower.hel.has("elites") and (e.def.get("elite", false) or e.feroz)
	return e.def.get("elite", false) and GameData.hell_level(world.danger) >= 12



static func pact_elites(world: World) -> bool:
	for h in world.heroes:
		if h != null and is_instance_valid(h) and h.effects.has("stagger_elites"):
			return true
	return false






const DEBUFF_GAP: = 3.0
func debuff(world: World, p: Player, e: Enemy, key: String) -> void :
	if p == null or not is_instance_valid(p) or e == null or not is_instance_valid(e):
		return
	var secs: = float(p.effects.get("stagger_debuff", 0.0))
	if secs <= 0.0 or not fits(world, e):
		return
	var at: = "deb:%d:%s:%d" % [p.get_instance_id(), key, e.get_instance_id()]
	if world.clock < float(_debuff_at.get(at, -100.0)):
		return
	_debuff_at[at] = world.clock + DEBUFF_GAP

	var was: = world.damage_by
	world.damage_by = p
	add(world, e, secs, "deb:" + key)
	world.damage_by = was
var _debuff_at: = {}


func _show(world: World, e: Enemy, k: float, stun: float) -> void :
	var was: = float((shown.get(e.get_instance_id(), {}) as Dictionary).get("k", 0.0))
	shown[e.get_instance_id()] = {"k": k, "until": world.clock + stun if stun > 0.0 else 0.0}
	_mark(e, k, stun)
	if stun > 0.0:
		break_fx(world, e, stun)
		_refund(world)

	if world.net != null and world.net.recording() and (stun > 0.0 or absf(k - was) >= 0.04 or k < was):
		world.net.record(["sgb", world.net.ref_of(e), k, stun])



func net_set(world: World, e: Enemy, k: float, stun: float) -> void :
	if e == null or not is_instance_valid(e):
		return
	shown[e.get_instance_id()] = {"k": k, "until": world.clock + stun if stun > 0.0 else 0.0}
	_mark(e, k, stun)
	if stun > 0.0:
		break_fx(world, e, stun, true)



static func _mark(e: Enemy, k: float, stun: float) -> void :
	if e.is_boss:
		return
	StatusMarks.set_mark(e, "stagger", StatusMarks.BURN_STEPS if stun > 0.0 else ceili(k * StatusMarks.BURN_STEPS), StatusMarks.BURN_STEPS)






func _refund(world: World) -> void :
	for h in world.heroes:
		if h != null and is_instance_valid(h) and h.effects.has("wing_break_cd"):
			h.refund_cooldowns(float(h.effects.wing_break_cd))




func gauge(world: World, e: Enemy) -> Dictionary:
	var d = shown.get(e.get_instance_id())
	if d == null:


		return {"k": 0.0 if fits(world, e) else -1.0, "broken": false}
	var broken: bool = world.clock < float(d.until)
	if not broken and float(d.until) > 0.0:
		d.k = 0.0
		d.until = 0.0
	return {"k": float(d.k), "broken": broken}








func break_fx(world: World, e: Enemy, stun: float, guest: = false) -> void :
	var at: = e.position
	var layer: = Vfx.layer
	var dim: = Vfx.dim
	Vfx.dim = 1.0
	if not guest:
		world.fx_layer(GameData.MVP_FX_PRIORITY)
		if e.is_boss:
			Vfx.ray_flash(world.fx_root, at + Vector3(0, 1.4, 0), world.camera.global_basis, GOLD, 2.4)
			Vfx.ring(world.fx_root, at + Vector3(0, 0.06, 0), e.radius + 3.6, Color(1.0, 0.95, 0.7), 0.55)
		Vfx.ring(world.fx_root, at + Vector3(0, 0.06, 0), e.radius + 1.8, GOLD, 0.45)
		Vfx.burst(world.fx_root, at + Vector3(0, 1.0, 0), e.radius + 2.0, GOLD)
	var stars: = RoEffect.spawn(world.fx_root, "stun", at + Vector3(0, e.visual.height() * 0.9, 0), 1.5, e)
	if stars != null:
		stars.loop = true
		world.get_tree().create_timer(stun, false).timeout.connect( func():
			if is_instance_valid(stars):
				stars.queue_free())
	if not guest:
		world.fx_layer(layer)
	Vfx.dim = dim
	e.visual.flash()
	if not guest:
		world.play_sound("guard_block", 0.0, 3.0 if e.is_boss else -3.0, 0.7, false, e.is_boss)
		world.play_sound("stun", 0.0, 2.0 if e.is_boss else -4.0, -1.0, false, e.is_boss)
	if not e.is_boss:
		world.shake(0.15)
		return
	world.shake(0.55, true)
	world.hud.flash(Color(1.0, 0.97, 0.85), 0.35, 0.22)
	world.hud.alerts.big(TranslationServer.translate("¡ATURDIDO!"), 
		TranslationServer.translate("%s pierde el equilibrio: ¡golpea ahora!") % TranslationServer.translate(str(e.def.name)), GOLD)

	var was: = Engine.time_scale
	if was > 0.2:
		Engine.time_scale = 0.05
		world.get_tree().create_timer(0.12, true, false, true).timeout.connect( func():
			if is_equal_approx(Engine.time_scale, 0.05):
				Engine.time_scale = was)
