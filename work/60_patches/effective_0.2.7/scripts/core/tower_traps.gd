extends RefCounted






const DODGE_HEAL: = 0.02

# [MOD] Endless Tower hazard nerf (see work/60_patches/PATCH_SYSTEM.md §7): hard ceiling on the share
# of max HP a tower hazard takes per hit, on the fastest cadence, and on how many hazards may land at
# once. Clamped again in every leaf below so no caller can bypass it.
const MOD_TRAP_PCT_CAP: = 0.1
const MOD_TRAP_EVERY_MIN: = 4.0
const MOD_TRAP_MAX: = 2
# [MOD] this file is not a member of patch_0.2.3.pck at all (it ships in the 0.2.0 bridge), so its
# presence in the top pack is the thing worth proving: the probe reports the clamped pct it will use.
static var mod_traps_probe: = false

var world: World
var _t: = 4.0
var _said: = 0


func _init(w: World) -> void :
	world = w



func floor_start() -> void :
	_t = 4.0


func tick(delta: float, at_floor: int) -> void :
	if at_floor < GameData.TOWER_TRAP_FROM:
		return
	_announce(at_floor)
	_t -= delta
	if _t > 0.0:
		return
	var up: = float(at_floor - GameData.TOWER_TRAP_FROM)


	var past: = GameData.tower_past(at_floor)
	var every: = maxf(GameData.TOWER_TRAP_EVERY_MIN, GameData.TOWER_TRAP_EVERY - up * GameData.TOWER_TRAP_EVERY_STEP)
	if past > 0:
		every = maxf(GameData.TOWER_PAST_TRAP_EVERY_MIN, every - past * GameData.TOWER_PAST_TRAP_EVERY_STEP)
	every = maxf(MOD_TRAP_EVERY_MIN, every)
	_t = every * randf_range(0.85, 1.15)
	var kinds: Array = []
	for k in GameData.TOWER_TRAPS:
		if at_floor >= int(k.from):
			kinds.append(str(k.id))
	var hero: = _hero()
	if hero == null or kinds.is_empty():
		return
	var pct: = minf(GameData.TOWER_TRAP_PCT_MAX, GameData.TOWER_TRAP_PCT + up * GameData.TOWER_TRAP_PCT_STEP)
	if past > 0:
		pct = minf(GameData.TOWER_PAST_TRAP_PCT_MAX, pct + past * GameData.TOWER_PAST_TRAP_PCT_STEP)
	pct = minf(MOD_TRAP_PCT_CAP, pct)
	if not mod_traps_probe:
		mod_traps_probe = true
		print("MODPROBE tower_traps.gd mounted: floor=%d pct clamped to %.2f (stock cap 0.30), every>=%.1fs, max %d at once, pid=%d" % [
			at_floor, pct, MOD_TRAP_EVERY_MIN, MOD_TRAP_MAX, OS.get_process_id()])
		var mf: = FileAccess.open("user://mod_probe_traps.txt", FileAccess.WRITE)
		if mf != null:
			mf.store_string("floor=%d\npct=%.3f\npid=%d\nat=%s\n" % [at_floor, pct, OS.get_process_id(), Time.get_datetime_string_from_system()])
			mf.close()
	var cast: = maxf(0.9, 1.35 - up * 0.004)
	var many: = mini(MOD_TRAP_MAX, 1 + int(at_floor >= GameData.TOWER_PAST_DOUBLE) + int(at_floor >= GameData.TOWER_PAST_TRIPLE))


	var picked: Array = []
	for n in many:
		var k: = str(kinds.pick_random())
		if n > 0 and k == "boulder" and picked.has("boulder"):
			k = "bolts"
		picked.append(k)
		_spring(k, hero if n == 0 else _hero(), up, pct, cast)


func _spring(kind: String, hero: Player, up: float, pct: float, cast: float) -> void :
	if hero == null:
		return
	match kind:
		"bolts":
			_bolts(hero, 1 + mini(4, int(up / 10.0)), pct, cast)
		"beam":
			_beams(hero, 1 + int(up >= 30 - GameData.TOWER_TRAP_FROM), pct, cast)
		"spikes":
			_spikes(hero, pct, cast)
		"boulder":
			_boulder(hero, pct, cast + 0.2)



func survive_strike(hero: Player, stage: float, pct: float, center: Vector3, radius: float) -> void :
	var cast: = 1.2 - 0.25 * stage
	match randi() % (2 if stage < 0.25 else (4 if stage < 0.5 else 5)):
		0:
			_bolts(hero, 3 + int(stage * 3.0), pct, cast)
		1:
			_beams(hero, 2, pct, cast)
		2:
			_spikes(hero, pct, cast)
		3:
			_boulder(hero, pct, cast + 0.2)
		4:
			_refuge(center, radius, pct * 1.5, cast + 0.8)



func _refuge(center: Vector3, radius: float, pct: float, cast: float) -> void :
	pct = minf(MOD_TRAP_PCT_CAP, pct)
	var size: = 2.2
	var a: = randf() * TAU
	var spot: = center + Vector3(cos(a), 0, sin(a)) * radius * randf_range(0.3, 0.65)

	for i in 8:
		if world.map.is_walkable(spot):
			break
		a += TAU / 8.0
		spot = center + Vector3(cos(a), 0, sin(a)) * radius * 0.4
	spot.y = world.map.height_at(spot)
	var col: = Color(0.4, 1.0, 0.55)
	Vfx.safe_circle(world.fx_root, spot, size, col, cast)
	world.play_sound("warning", 0.2, -8.0)
	_after(cast, func():
		Vfx.burst(world.fx_root, center + Vector3(0, 0.3, 0), radius * 1.1, Color(1.0, 0.45, 0.25))
		Vfx.ring(world.fx_root, center + Vector3(0, 0.08, 0), radius * 1.2, Color(1.0, 0.7, 0.4), 0.45)
		world.play_sound("earth_quake", 0.1, -6.0)
		world.shake(0.35)
		for h in world.alive_heroes():
			if Vector2(h.position.x - spot.x, h.position.z - spot.z).length() > size:
				world.hurt_what = tr("Estallido de la torre")
				h.take_damage(h.max_hp * pct, world, null, true))



func _announce(at_floor: int) -> void :
	for i in GameData.TOWER_TRAPS.size():
		var k: Dictionary = GameData.TOWER_TRAPS[i]
		if at_floor >= int(k.from) and i >= _said:
			_said = i + 1
			world.party_announce(tr(str(k.name)), Color(k.color), tr(str(k.hint)))


func _hero() -> Player:
	var alive: = world.alive_heroes()
	return alive.pick_random() if not alive.is_empty() else null




func _bolts(hero: Player, count: int, pct: float, cast: float) -> void :
	pct = minf(MOD_TRAP_PCT_CAP, pct)
	var spots: Array = [hero.position]
	for i in count - 1:
		var p: = world.map.find_point_around(hero.position, 2.0, 5.0)
		if p != Vector3.INF:
			spots.append(p)
	var col: = Color(0.55, 0.75, 1.0)
	world.play_sound("thunder", 0.3, -14.0)
	world._hell_blast(spots, 1.7, cast, pct, "lightning", col, "lightning_crash", tr("Rayo de la torre"))
	_after(cast, func():
		for at in spots:
			Vfx.column(world.fx_root, at, col)
			Vfx.ring(world.fx_root, at + Vector3(0, 0.08, 0), 2.2, col, 0.3)
		world.shake(0.2)
		_dodged(hero, spots[0], 1.7))



func _beams(hero: Player, count: int, pct: float, cast: float) -> void :
	pct = minf(MOD_TRAP_PCT_CAP, pct)
	var base: = randf() * TAU
	var length: = 18.0
	var width: = 1.7
	var col: = Color(0.8, 0.45, 1.0)
	var lanes: Array = []
	for i in count:
		var dir: = Vector3(cos(base + i * PI * 0.5), 0, sin(base + i * PI * 0.5))
		var from: = hero.position - dir * length * 0.5
		Vfx.telegraph_line(world.fx_root, from, dir, length, width, cast)
		lanes.append([from, dir])
	world.play_sound("warning", 0.3, -10.0)
	var marked: = hero.position
	_after(cast, func():
		var hit: Array[Player] = []
		for lane in lanes:
			Vfx.strike_line(world.fx_root, lane[0], lane[1], length, width, col)
			for k in 5:
				world.spawn_fx("lightning", lane[0] + lane[1] * length * (k + 0.5) / 5.0, 0.7, 0.8)
			for h in world.alive_heroes():
				var rel: Vector3 = (h.position - lane[0]) * Vector3(1, 0, 1)
				var along: float = rel.dot(lane[1])
				if along >= 0.0 and along <= length and absf(rel.dot(Vector3( - lane[1].z, 0, lane[1].x))) < width * 0.5 and not hit.has(h):
					hit.append(h)
		world.play_sound("lightning_crash", 0.1, -4.0)
		world.shake(0.25)
		for h in hit:
			world.hurt_what = tr("Viga arcana")
			h.take_damage(h.max_hp * pct, world, null, true)
		if not hit.has(hero):
			_dodged(hero, marked, width))



func _spikes(hero: Player, pct: float, cast: float) -> void :
	pct = minf(MOD_TRAP_PCT_CAP, pct)
	var center: = hero.position
	var turn: = randf() * TAU
	var col: = Color(0.85, 0.6, 0.3)
	for i in 10:
		var a: = turn + i * 0.9
		var at: = center + Vector3(cos(a), 0, sin(a)) * (0.4 + i * 0.55)
		if not world.map.is_walkable(at):
			continue
		_after(i * 0.13, func():
			world._hell_blast([at], 1.15, cast, pct, "earthhit", col, "earth_spike", tr("Púas de la torre"))
			_after(cast, func():
				Vfx.ring(world.fx_root, at + Vector3(0, 0.08, 0), 1.3, col, 0.25)
				world.shake(0.08)))
	_after(cast + 1.3, func():
		_dodged(hero, center, 1.5))




func _boulder(hero: Player, pct: float, cast: float) -> void :
	pct = minf(MOD_TRAP_PCT_CAP, pct)
	var dir: = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU)
	var length: = 20.0
	var width: = 2.2
	var from: = hero.position - dir * length * 0.5
	Vfx.telegraph_line(world.fx_root, from, dir, length, width, cast)
	world.play_sound("earth_quake", 0.3, -10.0)
	var speed: = 16.0
	_after(cast, func():
		world.spawn_projectile({"ghost": true, "pos": from + Vector3(0, 1.0, 0), "dir": dir, "speed": speed, "damage": 0.0, "pierce": 0, "bounces": 0, 
			"size": 0.7, "boomerang": false, "spin": 7.0, "range": length, "color": Color.WHITE, "slow": 0.0, "knock": 0.0, "arrow": false, 
			"streak": Color(0, 0, 0, 0), "delay": 0.0, "splash": 0.0, "sprite_scale": 1.0, "glow": false, "blend": "add", "hit_fx": "", 
			"hit_fx_intensity": 1.0, "hit_sound": "", "hit_sounds": [], "tex": "", "image": "boulder_x", "trail_tint": Color(1.0, 0.55, 0.25), 
			"impact": 0.0, "sprite": "", "frames": 0, "tex_scale": 1.6, "element": "neutral", "status": "", "status_chance": 0.0, 
			"status_time": 0.0, "max_life": length / speed})
		world.shake(0.15)
		var hit: = {}
		var steps: = 12
		for i in steps:
			var dist: = length * (i + 1) / float(steps)
			_after(dist / speed, func():
				var at: Vector3 = from + dir * dist
				Vfx.ring(world.fx_root, at + Vector3(0, 0.08, 0), 1.2, Color(1.0, 0.55, 0.25, 0.6), 0.25)
				for h in world.alive_heroes():
					var gap: = Vector2(h.position.x - at.x, h.position.z - at.z).length()
					if gap < width * 0.75 and not hit.has(h):
						hit[h] = true
						world.hurt_what = tr("Roca de la torre")
						h.take_damage(h.max_hp * pct, world, null, true)
						world.spawn_fx("earthhit", h.position, 0.9, 0.9))
		_after(length / speed + 0.1, func():
			world.play_sound("earth_spike", 0.1, -6.0)
			if not hit.has(hero):
				_dodged(hero, hero.position, 99.0)))



func _dodged(hero: Player, marked: Vector3, size: float) -> void :
	if not world.running or not is_instance_valid(hero) or hero.downed:
		return
	if Vector2(hero.position.x - marked.x, hero.position.z - marked.z).length() < size:
		return
	world.number(hero.position + Vector3(0, 2.8, 0), tr("¡Esquivado!"), Color(0.6, 1.0, 0.7), true)
	world.play_sound("drop_green", 0.3, -14.0)
	hero.heal(hero.max_hp * DODGE_HEAL, world)


func _after(seconds: float, what: Callable) -> void :
	if seconds <= 0.0:
		what.call()
		return
	world.get_tree().create_timer(seconds, false).timeout.connect( func():
		if world.running and world.tower != null:
			what.call())
