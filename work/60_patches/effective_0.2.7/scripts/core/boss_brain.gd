class_name BossBrain
extends RefCounted



var e: Enemy
var kind: = ""
var _timer: = 4.0
var _state: = "chase"
var _state_time: = 0.0
var _last: = ""
var _dash_dir: = Vector3.ZERO

var _dash_hit: Array = []
var _targets: Array[Vector3] = []


func _init(enemy: Enemy, p_kind: String) -> void :
	e = enemy
	kind = p_kind


func tick(delta: float, world: World) -> bool:
	_state_time -= delta
	match _state:
		"chase":
			_timer -= delta / (world.mvp_cast() if e.mvp_pace > 0.0 else 1.0)
			if _timer <= 0.0:
				_start_attack(world)
			return false
		"slam":
			e.visual.play(RoVisual.MOB_ATTACK)
			if _state_time <= 0.0:

				_drop_tells()
				for t in _targets:
					Vfx.strike_circle(world.fx_root, t, 3.5, _strike_color())

					if e.def.has("slam_fx"):
						world.spawn_fx(e.def.slam_fx, t, 1.4, 0.6)

				var struck: Array = []
				for t in _targets:
					for h in world.heroes:
						if not h.downed and not struck.has(h) and _flat_dist(h.position, t) < 3.5:
							struck.append(h)
							world.hurt_what = "Golpe aplastante"
							h.take_damage(e.damage * 1.6, world, e)
				if e.def.has("slam_sound"):
					world.play_sound(e.def.slam_sound, 0.2, -3.0)
				world.shake(0.4)
				_chase()
			return true
		"windup":
			e.visual.play(RoVisual.MOB_ATTACK)
			if _state_time <= 0.0:
				_drop_tells()
				Vfx.strike_line(world.fx_root, e.position, _dash_dir, 15.5, 2.0, _strike_color())
				_state = "dash"
				_state_time = 0.85
				_dash_hit.clear()
			return true
		"dash":
			var p: = world.map.slide(e.position, _dash_dir * 17.0 * delta)
			e.position = Vector3(p.x, world.map.height_at(p), p.z)
			e.visual.face(_dash_dir)
			for h in world.heroes:
				if not h.downed and not _dash_hit.has(h) and _flat_dist(h.position, e.position) < e.radius + 1.0:
					_dash_hit.append(h)
					world.hurt_what = "Embestida"
					h.take_damage(e.damage * 1.3, world, e)
			if _state_time <= 0.0:
				_chase()
			return true
	return false


func _start_attack(world: World) -> void :
	var options: Array[String] = []
	if kind == "summoner":
		options.append("summon")
		options.append("heal" if float(e.def.get("heal", 0.0)) > 0.0 else "charge")
	else:
		options = ["slam", "charge", "summon"]
	options.erase(_last)
	var pick: String = options.pick_random()
	_last = pick
	var enraged: = e.hp < e.max_hp * 0.5

	var foe: Player = e.hero_target if e.hero_target != null and is_instance_valid(e.hero_target) and not e.hero_target.downed else world.nearest_hero(e.position)
	if foe == null:
		foe = world.player
	match pick:
		"slam":
			_targets = [foe.position]
			if enraged:
				for i in 2:
					_targets.append(world.map.random_point_around(foe.position, 3.5))
			for t in _targets:
				_tells.append(Vfx.telegraph_circle(world.fx_root, t, 3.5, 1.1))
			_state = "slam"
			_state_time = 1.1
		"charge":
			_dash_dir = ((foe.position - e.position) * Vector3(1, 0, 1)).normalized()
			_tells.append(Vfx.telegraph_line(world.fx_root, e.position, _dash_dir, 14.5, 2.0, 0.8))
			_state = "windup"
			_state_time = 0.8
		"summon":
			var summon = e.def.get("summon", "poring")
			var mob: String = summon.pick_random() if summon is Array else str(summon)
			var count: = 6 if kind == "summoner" else (10 if enraged else 7)
			Vfx.ring(world.fx_root, e.position, 3.5, Color(0.8, 0.5, 1.0), 0.6)
			for i in count:
				var a: = TAU * i / count
				var m: = world.spawn_enemy(mob, e.position + Vector3(cos(a), 0, sin(a)) * 3.0)

				if m != null:
					m.summoned = true
			_chase()
		"heal":
			var heal: = float(e.def.get("heal", 0.04))
			e.hp = minf(e.max_hp, e.hp + e.max_hp * heal)
			Vfx.ring(world.fx_root, e.position, 2.5, Color(0.5, 1, 0.6), 0.7)
			world.number(e.position + Vector3(0, 1.5, 0), "+%d" % roundi(e.max_hp * heal), Color(0.45, 1, 0.5))
			_chase()



var _tells: Array = []


func _drop_tells() -> void :
	for n in _tells:
		if n != null and is_instance_valid(n):
			n.queue_free()
	_tells.clear()





func interrupt() -> void :
	if _state == "slam" or _state == "windup":
		_drop_tells()
		_chase()


func _strike_color() -> Color:
	return Color(e.def.get("color", Color(0.8, 0.3, 1.0))).lightened(0.25)


func _chase() -> void :
	_state = "chase"
	_timer = randf_range(2.8, 4.0) if kind != "summoner" else randf_range(5.0, 7.0)
	if e.hp < e.max_hp * 0.5:
		_timer *= 0.7


func _flat_dist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
