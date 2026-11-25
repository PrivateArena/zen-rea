extends RefCounted








var world: World
var tower: Node
var kind: = ""
var done: = false
var _left: = 0.0
var _t: = 0.0
var _wave: = 0
var _caught: = 0
var _total: = 0
var _porings: Array = []
var _foes: Array = []
var _hit_mark: = {}
var _center: = Vector3.INF
var _radius: = 0.0
var _cage: Node3D
var _mirror_at: = Vector3.INF
var _mirror_r: = 0.0
var _mirror_look: Node3D
var _emperium: Enemy
var _passed: = 0


var _turns: Array = []
var _spin_i: = 0
var _spin_wait: = 0.0


func _init(w: World, t: Node) -> void :
	world = w
	tower = t



# [MOD] Tower event floors (floor % 10 == 5) picked uniformly over GameData.TOWER_EVENTS minus the
# previous kind: 1/5 = 20% Emperium per event floor, 0% on the floor right after one, i.e. 1/6 = 16.7%
# of event floors in the long run -> one Emperium every ~60 floors. Emperium is the only event that pays
# a bonus-3 diamond chest (_prize: 3/4/5/7/10 rolls, the ONLY bonus-3 source inside the tower); treasure
# and survive top out at bonus 2, ambush at 1, duel pays through the MVP kill (main.gd:12159, 3 rolls)
# and wheel pays no chest at all. Weighted by id, unlisted kinds keep weight 1.0 and the shipped "never
# twice in a row" filter is kept, so emperium 9.0 -> 9/13 = 69.2% per event floor, 40.9% long run = one
# every ~24 floors; the other five 1/13 = 7.7% each (was 20%/16.7%). Re-weighting is the cheap lever,
# not more event floors: that same residue also carries the elite floor (tower_run.gd:586) and the Lucile
# blessing (TOWER_BLESS_FLOOR), and TOWER_TIER_FLOORS itself drives checkpoints, tiers, MVP and camp.
# v15 keeps this weight as-is and adds the hard cadence floor below, because the two caps above are what
# the weight is up against: it cannot make a trial appear on a floor the gate does not offer.
const MOD_EVENT_W: = {"emperium": 9.0}
# [MOD] Emperium trial CADENCE (a ceiling, not a chance): at least one trial every MOD_EMP_EVERY floors.
# Weights alone cannot reach the 9 floors asked for - the shipped gate only offers floor % 10 == 5, and
# pick() refuses to repeat a kind, so even an infinite weight lands one trial per 2 event floors (measured
# v14: 24.46 floors). TOWER_TIER_FLOORS itself cannot move (checkpoints/tiers/MVP/camp), so tower_run.gd
# now asks emp_due(floor) on EVERY floor: the first floor MOD_EMP_EVERY floors past the last trial becomes an
# Emperium floor, and the shipped residue-5 floors keep the other five kinds (their roll is unaffected).
# If that floor is a tier-top MVP floor - checked first, tower_run.gd:545 - the trial comes one floor EARLY
# instead of sliding late: sliding late locks the phase onto floors ending in 1 and gives a flat 10.00. Real
# numbers over 2 M floors with the shipped gate + the real pick() (work/logs/emp_cadence/sim.gd):
# shipped 59.9 -> v14 (weights only) 24.4 -> v15 8.89 floors per trial (median 9, min 8, worst 9 = the
# ceiling holds), 56.3% of event floors, and the other five kinds come back to 1.75 per 100 floors (v14 had
# starved them to 1.18; shipped is 1.67) because the ceiling, not the roll, now supplies the Emperium.
# MOD_EMP_EVERY = 0 -> v14 behaviour.
const MOD_EMP_EVERY: = 9
# [MOD] Emperium test. The check HP is derived from your OWN measured average DPS -- hp = max(500,
# avg_dps * TOWER_EMPERIUM_DPS 7) * TOWER_EMPERIUM_GROW^_passed -- and must die inside
# TOWER_EMPERIUM_TIME 10 s, so clearing check k costs current_dps >= avg_dps * 0.7 * 1.7^(k-1) =
# 0.70 / 1.19 / 2.02 / 3.44 / 5.85. Early-mid in a climb current ~= avg, so players bank _passed = 1 and
# the 3-roll prize; only a very deep climb (where avg lags far behind) ever reaches the 7/10 rungs.
# MOD_EMP_GROW 1.4 + MOD_EMP_TIME 15.0 -> 0.47 / 0.65 / 0.91 / 1.28 / 1.79 of avg_dps: 5/5 becomes a
# mid-climb achievement instead of an endgame one, and it stays a race rather than a giveaway.
# MOD_EMP_PRIZES [5,7,9,12,16] (was [3,4,5,7,10]) raises the reward at the _passed you actually reach;
# rolls > 5 is not clamped when the chest opens (only past the 12-chest ground cap, main.gd:13691). At
# the measured 1.82%/roll of a Sword Wings in a deep-run chest (SWORD_WINGS_FARM_GUIDE.md §6), 16 rolls
# = 25.5% for one, vs 5.4% under the shipped 3-roll prize.
const MOD_EMP_GROW: = 1.4
const MOD_EMP_TIME: = 15.0
const MOD_EMP_PRIZES: = [5, 7, 9, 12, 16]
static var mod_event_n: = {}
static var mod_event_rolls: = 0
# [MOD] measured trial-to-trial spacing of the REAL game (not just of the odds sim) -> the probe line.
static var mod_emp_floors: = 0.0
static var mod_emp_gaps: = 0
# [MOD] floor the last Emperium trial ran on -> the MOD_EMP_EVERY ceiling. -1 = not yet this climb; the lazy
# seed (TOWER_EVENT_AT - MOD_EMP_EVERY) makes a fresh climb's first trial land on the shipped first event
# floor, 5. Set on forced AND on rolled trials, so a lucky roll pushes the next forced one back.
var _emp_floor: = -1


func _event_w(k: String) -> float:
	return float(MOD_EVENT_W.get(k, 1.0))


func _event_pick(pool: Array) -> String:
	var total: = 0.0
	for k in pool:
		total += _event_w(str(k))
	var r: = randf() * total
	for k in pool:
		r -= _event_w(str(k))
		if r <= 0.0:
			return _event_note(str(k))
	return _event_note(str(pool[0]))


# [MOD] measured event odds -> user://mod_probe_events.txt (also printed), so the new numbers above are
# checkable from your own climb.
func _event_note(k: String) -> String:
	mod_event_rolls += 1
	mod_event_n[k] = int(mod_event_n.get(k, 0)) + 1
	if mod_event_rolls % 4 == 1:
		var s: = "events=%d  emperium=%d (P=%.1f%%)  gap=%.1f floors  " % [mod_event_rolls, int(mod_event_n.get("emperium", 0)), 
			100.0 * int(mod_event_n.get("emperium", 0)) / maxf(1.0, mod_event_rolls), mod_emp_floors / maxf(1.0, float(mod_emp_gaps))]
		for key in mod_event_n.keys():
			if str(key) == "emperium":
				continue
			s += "%s=%d " % [key, mod_event_n[key]]
		print("MODPROBE events: ", s)
		var f: = FileAccess.open("user://mod_probe_events.txt", FileAccess.WRITE)
		if f != null:
			f.store_string(s + "\nat=" + Time.get_datetime_string_from_system() + "\n")
			f.close()
	return k


func pick() -> String:
	var pool: Array = GameData.TOWER_EVENTS.keys().filter( func(k): return k != kind)
	return _event_pick(pool)


# [MOD] asked on every floor by tower_run.gd _start_floor() (:576): yes => this floor is past the ceiling and
# must carry an Emperium trial. Deliberately does NOT care what the previous kind was: with MOD_EMP_EVERY 9
# two forced trials can never be adjacent anyway, and the shipped "never twice in a row" filter in pick()
# keeps the residue-5 floors varied on their own.
func emp_due(f: int) -> bool:
	if MOD_EMP_EVERY <= 0:
		return false
	if _emp_floor < 0:
		_emp_floor = GameData.TOWER_EVENT_AT - MOD_EMP_EVERY
	var d: = f - _emp_floor
	if d >= MOD_EMP_EVERY:
		return true
	# d == MOD_EMP_EVERY - 1: the due floor is the next one. TowerRun reserves every TOWER_TIER_FLOORS-th
	# floor for the MVP (_start_floor checks `top` first, tower_run.gd:545), and a trial lost there slides to
	# f+1 -- which with a 9 floor period locks the phase onto floors ending in 1 and turns every gap into 10
	# (measured). So come one floor EARLY instead: 8 then 9, 9, 9, ..., never a locked 10.
	if d == MOD_EMP_EVERY - 1:
		return (f + 1) % GameData.TOWER_TIER_FLOORS == 0
	return false


# [MOD] the entry point tower_run.gd now calls: the ceiling first, else the weighted roll. Records the floor
# either way, so the clock restarts from whichever trial you actually got.
func pick_for(f: int) -> String:
	var k: = ""
	if emp_due(f):
		k = _event_note("emperium")
	else:
		k = pick()
	if k == "emperium":
		# [MOD] cadence probe: the REAL spacing between two Emperium trials, averaged into the `gap=` field of
		# _event_note. Static like the counters there, so it spans the game process, not one climb - and a new
		# climb cannot inject a bogus gap, because its floors start below the previous _emp_floor. Read it as:
		# ~9 floors = MOD_EMP_EVERY is firing; ~24 = the tower_run.gd:576 hook did not land.
		if _emp_floor >= 0 and f > _emp_floor:
			mod_emp_floors += float(f - _emp_floor)
			mod_emp_gaps += 1
		_emp_floor = f
	return k


func start(at_floor: int, force: = "") -> String:
	kind = force if force != "" else pick()
	done = false
	_t = 0.0
	_wave = 0
	match kind:
		"treasure":
			_start_treasure(at_floor)
		"ambush":
			_lock(9.0, Color(1.0, 0.35, 0.25))
			_left = 3.0
		"emperium":
			_passed = 0
			_rise_emperium()
		"wheel":
			_start_wheel()
		"survive":
			_lock(9.5, Color(0.5, 0.8, 1.0))
			_left = float(GameData.TOWER_SURVIVE_TIME)
			_t = -2.0
			for h in world.heroes:
				_hit_mark[h] = h.hurt_at
	return kind



func line() -> String:
	match kind:
		"treasure":
			return tr("Poring Dorados %d / %d  ·  %ds") % [_caught, _total, ceili(_left)]
		"ambush":
			return tr("Emboscada  ·  oleada %d / %d") % [mini(_wave, GameData.TOWER_AMBUSH_WAVES), GameData.TOWER_AMBUSH_WAVES]
		"survive":
			return tr("¡Sobrevive!  ·  %ds") % ceili(maxf(0.0, _left))
		"wheel":
			return tr("La ruleta de Lucile")
		"emperium":
			return tr("Emperium  ·  prueba %d / %d  ·  %ds") % [mini(_passed + 1, GameData.TOWER_EMPERIUM_CHECKS), GameData.TOWER_EMPERIUM_CHECKS, ceili(maxf(0.0, _left))]
	return ""


func tick(delta: float, at_floor: int) -> void :
	_hold()
	match kind:
		"treasure":
			_tick_treasure(delta)
		"ambush":
			_tick_ambush(delta, at_floor)
		"survive":
			_tick_survive(delta, at_floor)
		"emperium":
			_tick_emperium(delta)
		"wheel":
			_tick_wheel(delta)




func mirror_cage(at: Vector3, r: float, col: = Color(0.5, 0.8, 1.0)) -> void :
	_mirror_at = at
	_mirror_r = r
	if _mirror_look != null and is_instance_valid(_mirror_look):
		_mirror_look.queue_free()
	_mirror_look = _cage_look(at, r, col) if r > 0.0 else null



func net_info() -> Array:
	return [kind, _caught, _total, _wave, ceili(maxf(0.0, _left)), _passed]



func net_take(info: Array) -> void :
	if info.size() < 6:
		return
	kind = str(info[0])
	_caught = int(info[1])
	_total = int(info[2])
	_wave = int(info[3])
	_left = float(info[4])
	_passed = int(info[5])


func mirror_tick() -> void :
	if _mirror_r > 0.0 and world.player != null:
		_clamp(world.player, _mirror_at, _mirror_r)





func inside(at: Vector3) -> Vector3:
	var c: = _center if _radius > 0.0 else _mirror_at
	var r: = _radius if _radius > 0.0 else _mirror_r
	if r <= 0.0 or c == Vector3.INF:
		return at
	var d: = (at - c) * Vector3(1, 0, 1)
	if d.length() <= r - 0.4:
		return at
	var to: = c + d.normalized() * (r - 0.4)
	return Vector3(to.x, world.map.height_at(to), to.z)





func _lock(radius: float, col: Color) -> void :



	var from: = world.player.position
	var best: = from
	var score: = -1.0
	var spots: Array = [from]
	for i in 28:
		spots.append(world.map.random_point_around(from, 3.0 if i < 10 else 7.0))
	for s in spots:
		var n: = 0
		for i in 24:
			var a: = TAU * i / 24.0
			for k in [0.35, 0.7, 1.0]:
				if world.map.is_walkable(s + Vector3(cos(a), 0, sin(a)) * radius * k):
					n += 1
		var sc: float = n - (s - from).length() * 0.15
		if sc > score:
			score = sc
			best = s
	_center = best
	_radius = radius
	_cage = _cage_look(best, radius, col)
	Vfx.ring(world.fx_root, best, radius, col, 0.8)
	Vfx.burst(world.fx_root, best, radius * 0.6, col)
	world.play_sound("portal", 0.0, -2.0)
	world.shake(0.25)
	world.net.tower_event(["cage", best, radius, col])




func _cage_look(at: Vector3, radius: float, col: Color) -> Node3D:
	var n: = Node3D.new()
	world.fx_root.add_child(n)
	n.global_position = Vector3(at.x, world.map.height_at(at) + 0.05, at.z)
	Vfx.magic_circle(n, Vector3.ZERO, radius, Color(col, 0.42), 0.0, "mvp_rune", 0.2, -1, false)
	return n


func _hold() -> void :
	if _radius <= 0.0:
		return
	for h in world.heroes:
		_clamp(h, _center, _radius)


func _clamp(h: Player, at: Vector3, r: float) -> void :
	var d: = (h.position - at) * Vector3(1, 0, 1)
	if d.length() > r - 0.4:
		var to: = at + d.normalized() * (r - 0.4)
		h.position = Vector3(to.x, world.map.height_at(to), to.z)


func _unlock() -> void :
	if _cage != null and is_instance_valid(_cage):
		Vfx.ring(world.fx_root, _center, _radius, Color(1.0, 0.95, 0.7), 0.6)
		_cage.queue_free()
	_cage = null
	if _radius > 0.0:
		world.net.tower_event(["cage", Vector3.ZERO, 0.0])
	_radius = 0.0



func _finish(rolls: int, bonus: int, title: = "", sub: = "", look: = "") -> void :
	_unlock()
	done = true
	if rolls > 0:
		var at: = world.map.find_point_around(world.player.position, 1.5, 3.0)
		world._drop_chest(at if at != Vector3.INF else world.player.position, rolls, bonus, "", false, false, look)
	if title != "":
		world.party_announce(title, Color(1.0, 0.85, 0.35), sub)
	world.play_sound("levelup", 0.0, -4.0)
	Vfx.column(world.fx_root, world.player.position, Color(1.0, 0.9, 0.5))



func cleanup() -> void :
	_unlock()
	for e in _porings:
		if is_instance_valid(e) and not e.dead:
			world.banish_enemy(e)
	_porings.clear()
	_foes.clear()




func _start_treasure(at_floor: int) -> void :
	_total = mini(10, 5 + at_floor / 15)
	_left = float(GameData.TOWER_TREASURE_TIME)
	_caught = 0
	_porings.clear()
	var n: = world.heroes.size()
	var dps: = world.tank_dps(world.party_dealt() / maxf(20.0, world.measure_time())) / n
	for i in _total:
		var at: = world.map.find_point_around(world.player.position, 5.0, 11.0)
		if at == Vector3.INF:
			continue
		var e: Enemy = world.spawn_enemy(str(GameData.RUNNER.mob), at, true, false, "runner")
		if e == null:
			continue
		e.make_runner(float(GameData.RUNNER.life))
		e.set_meta("treasure_floor", true)



		e.max_hp = maxf(maxf(200.0, dps * GameData.TOWER_TREASURE_DPS_SECS), world.peak_hit * GameData.TOWER_TREASURE_HITS) * GameData.coop_hp(n, "tough")
		e.hp = e.max_hp
		e.speed = world.player.move_speed * 0.74
		_porings.append(e)
		world.spawn_fx("itempokjuk", at, 0.8, 0.8)
	_total = _porings.size()


func _tick_treasure(delta: float) -> void :
	_left -= delta
	var alive: = 0
	for e in _porings:
		if is_instance_valid(e) and not e.dead:
			alive += 1
	_caught = _total - alive
	if alive > 0 and _left > 0.0:
		return
	cleanup()
	if _caught >= _total and _total > 0:
		_finish(GameData.CHEST_ROLLS.boss, 2, tr("¡Todos atrapados!"), tr("El tesoro entero es tuyo"))
	elif _caught * 2 >= _total:
		_finish(GameData.CHEST_ROLLS.boss, 1, tr("¡Buen botín!"), tr("%d de %d atrapados") % [_caught, _total])
	else:
		_finish(GameData.CHEST_ROLLS.elite, 0, tr("Se escaparon..."), tr("%d de %d atrapados") % [_caught, _total])




func _tick_ambush(delta: float, at_floor: int) -> void :
	_foes = _foes.filter( func(e): return is_instance_valid(e) and not e.dead)
	_left -= delta
	if _left > 0.0 or ( not _foes.is_empty() and _left > - GameData.TOWER_AMBUSH_WAVE_TIME):
		return
	if _wave >= GameData.TOWER_AMBUSH_WAVES:
		if _foes.is_empty():
			_finish(GameData.CHEST_ROLLS.boss, 1, tr("¡Emboscada superada!"), tr("El círculo se abre"))
		elif _left < - GameData.TOWER_AMBUSH_STUCK:
			_ambush_gather()
		return
	_wave += 1
	world.party_announce(tr("Oleada %d / %d") % [_wave, GameData.TOWER_AMBUSH_WAVES], Color(1.0, 0.45, 0.35), "")
	_left = 2.0
	var mobs: Array = tower._mobs if not tower._mobs.is_empty() else ["poring"]
	var count: int = roundi((6 + _wave * 2 + mini(10, at_floor / 10)) * GameData.coop_spawn(world.heroes.size()))
	world.play_sound("warning", 0.2, -6.0)
	for i in count:
		var a: = TAU * i / count
		var at: = _center + Vector3(cos(a), 0, sin(a)) * (_radius - 1.5)
		if not world.map.is_walkable(at):
			at = world.map.random_point_around(_center, 4.0)
		world.spawn_fx("hell_in", at, 0.5, 0.7)
		var e: Enemy = world.spawn_enemy(str(mobs.pick_random()), at, true, i < _wave)
		if e != null:
			_foes.append(e)






var _gather_at: = 0.0
func _ambush_gather() -> void :
	if world.time < _gather_at:
		return
	_gather_at = world.time + 5.0
	for f in _foes:
		var e: Enemy = f
		var out: bool = _radius > 0.0 and ((e.position - _center) * Vector3(1, 0, 1)).length() > _radius - 0.5
		if not out and world.map.can_reach(e.position, _center):
			continue
		var at: = world.map.reachable_point(_center + Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)) * (_radius * 0.5), _center)
		if at == Vector3.INF:
			at = _center
		world.spawn_fx("hell_in", at, 0.5, 0.7)
		e.position = Vector3(at.x, world.map.height_at(at), at.z)





func _rise_emperium() -> void :
	var at: = world.map.find_point_around(world.player.position, 2.5, 4.0)
	if at == Vector3.INF:
		at = world.player.position + Vector3(2.5, 0, 0)
	_emperium = world.spawn_enemy("item_emperium", at, true, false, "emperium")
	if _emperium == null:
		_finish(0, 0)
		return
	var dps: = world.party_dealt() / maxf(30.0, world.measure_time())
	if dps <= 0.0:
		dps = float(world.meter_stats.get("total", 0.0)) / maxf(30.0, world.measure_time())

	dps = world.tank_dps(dps)
	_emperium.set_meta("steady", true)

	_emperium._static = true
	_emperium._immovable = true
	_emperium.speed = 0.0

	_emperium.set_meta("big", 1.2 + 0.2 * _passed)
	_emperium.max_hp = maxf(500.0, dps * GameData.TOWER_EMPERIUM_DPS) * pow(GameData.TOWER_EMPERIUM_GROW, _passed)
	_emperium.hp = _emperium.max_hp
	_left = GameData.TOWER_EMPERIUM_TIME
	# [MOD] re-state the two shipped lines with our own growth/window (see MOD_EMP_* above); hp is set
	# from max_hp on the line below, and scale_enemy already ran at spawn, so nothing re-scales after.
	_emperium.max_hp = maxf(500.0, dps * GameData.TOWER_EMPERIUM_DPS) * pow(MOD_EMP_GROW, _passed)
	_emperium.hp = _emperium.max_hp
	_left = MOD_EMP_TIME
	if _emperium.visual is Node3D:

		(_emperium.visual as Node3D).scale *= 1.2 + 0.2 * _passed
		if _emperium.visual is RoVisual:

			(_emperium.visual as RoVisual).sprite.no_depth_test = true
			(_emperium.visual as RoVisual).sprite.render_priority = 6
	var col: = Color(1.0, 0.86, 0.3)
	Vfx.column(world.fx_root, at, col)
	Vfx.ring(world.fx_root, at + Vector3(0, 0.08, 0), 3.0 + _passed, col, 0.6)
	world.spawn_fx("holyhit", at, 1.2 + 0.2 * _passed, 0.9)
	world.play_sound("portal", 0.0, -2.0, 1.0 + 0.08 * _passed)
	world.shake(0.15 + 0.05 * _passed)


func _tick_emperium(delta: float) -> void :
	if is_instance_valid(_emperium) and not _emperium.dead and _emperium.hp > 0.0:
		var before: = ceili(_left)
		_left -= delta

		if ceili(_left) != before and _left <= 3.0 and _left > 0.0:
			world.play_sound("warning", 0.2, -8.0, 1.2)
			Vfx.ring(world.fx_root, _emperium.position + Vector3(0, 0.08, 0), 3.5, Color(1.0, 0.4, 0.3), 0.5)
		if _left > 0.0:
			return

		var at: = _emperium.position
		world.banish_enemy(_emperium)
		world.number(at + Vector3(0, 2.6, 0), tr("¡Fallaste la prueba!"), Color(1.0, 0.4, 0.3), true)
		_prize()
		return
	_passed += 1
	var at: = world.player.position
	if is_instance_valid(_emperium):
		at = _emperium.position
	Vfx.burst(world.fx_root, at, 4.0 + _passed, Color(1.0, 0.86, 0.3))
	Vfx.ray_flash(world.fx_root, at + Vector3(0, 1.0, 0), world.camera.global_basis, Color(1.0, 0.9, 0.5), 1.0 + 0.3 * _passed)
	for k in 8:
		var a: = TAU * k / 8.0
		world.spawn_fx("itempokjuk", at + Vector3(cos(a), 0, sin(a)) * 1.6, 0.6, 0.7)
	world.spawn_fx("bs_refinesuccess", at, 1.2, 1.0)
	world.hud.flash(Color(1.0, 0.85, 0.4), 0.3)
	world.play_sound("drop_yellow", 0.0, -2.0, 1.0 + 0.1 * _passed)
	world.play_sound("levelup", 0.0, -3.0, 1.0 + 0.08 * _passed)
	world.shake(0.25)
	world.party_announce(tr("¡Prueba %d superada!") % _passed, Color(1.0, 0.86, 0.3), "")
	if _passed >= GameData.TOWER_EMPERIUM_CHECKS:
		_prize()
	else:
		_rise_emperium()


func _prize() -> void :
	if _passed <= 0:
		_finish(0, 0, tr("Sin premio"), tr("El Emperium resistió"))
		return
	var rolls: = int(GameData.TOWER_EMPERIUM_PRIZES[mini(_passed, GameData.TOWER_EMPERIUM_PRIZES.size()) - 1])
	rolls = int(MOD_EMP_PRIZES[clampi(_passed, 1, MOD_EMP_PRIZES.size()) - 1])	# [MOD] was [3,4,5,7,10]
	_finish(rolls, 3, tr("¡%d de %d pruebas!") % [_passed, GameData.TOWER_EMPERIUM_CHECKS], tr("Cofre de diamante: %d objetos") % rolls, GameData.CHEST_DIAMOND)




func _start_wheel() -> void :
	world.play_sound("portal", 0.0, -2.0)
	Vfx.column(world.fx_root, world.player.position, Color(0.95, 0.55, 1.0))
	_turns = _wheel_turns()
	_spin_i = 0
	_spin_wait = 0.0
	if not _turns.is_empty():

		world.net.tower_event(["wheel_open", _turns.map( func(t): return [t[0], t[1]])])
	_open_wheel()


func _open_wheel() -> void :
	world.menus.show_tower_wheel(_wheel_pick, _spun, func(): done = true, _turns, _spin_i)




func _wheel_turns() -> Array:
	var humans: = world.heroes.filter( func(h): return h == world.player or world.net.is_remote(h))
	if humans.size() <= 1:
		return []
	var out: = []
	for i in GameData.TOWER_WHEEL_SPINS:
		var h: Player = humans[i % humans.size()]
		out.append([h.slot, _hero_label(h), h == world.player])
	return out


func _hero_label(h: Player) -> String:
	if h == world.player:
		return Save.char_name(h.class_id)
	for id in world.net.peers:
		if world.net.peers[id].get("hero") == h:
			var n: = str(world.net.peers[id].get("name", ""))
			if n != "":
				return n
	return tr(h.job_name())



func _spun(id: String) -> void :
	tower.wheel_take(id)
	_wheel_show(id)
	if not _turns.is_empty():
		world.net.tower_event(["wheel_spin", _spin_i, id])
	_spin_i += 1
	_spin_wait = 0.0



func remote_spin(h: Player, id: String) -> void :
	if kind != "wheel" or done or _spin_i >= _turns.size() or TowerRun.wheel_entry(id).is_empty():
		return
	if int(_turns[_spin_i][0]) != h.slot or bool(_turns[_spin_i][2]):
		return
	_member_spun(id)


func _member_spun(id: String) -> void :
	var i: = _spin_i
	tower.wheel_take(id)
	_wheel_show(id)
	world.net.tower_event(["wheel_spin", i, id])
	world.menus.tower_wheel_remote(i, id)
	_spin_i += 1
	_spin_wait = 0.0



func _tick_wheel(delta: float) -> void :
	if done:
		return



	if world.menus.mode() == "closed":
		if _spin_i >= (_turns.size() if not _turns.is_empty() else GameData.TOWER_WHEEL_SPINS):
			done = true
		else:
			_open_wheel()
		return
	if _turns.is_empty() or _spin_i >= _turns.size() or bool(_turns[_spin_i][2]):
		return
	_spin_wait += delta
	var slot: = int(_turns[_spin_i][0])
	var h: Player = null
	for o in world.heroes:
		if o.slot == slot:
			h = o
	if h == null or not world.net.is_remote(h) or _spin_wait > GameData.TOWER_WHEEL_TURN_WAIT:
		_member_spun(_wheel_pick())



# [MOD] The wheel is 4 spins per event and 33.7% of the rim is curses - Filo mellado (-20% dao),
# Carne fragil (-20% vida), Pies de plomo (-15% mov), Mente nublada (+25% recarga) at w=8 each, while
# the single super slot (dmg +50%, hp +40%, aspd +25%, move +15%, permanent) sits at 3/95 = 3.2%.
# Re-weighted by id: buffs 12 -> 18, super 3 -> 36 (12x), curses 8 -> 0.5. Curses keep their shipped
# meaning (they expire after `floors` floors), they just became noise. Sum 128 -> per spin:
# super 28.1%, each buff 14.1%, each curse 0.39% (any curse 1.6%, was 33.7%).
const MOD_WHEEL_W: = {"fury": 18.0, "iron": 18.0, "swift": 18.0, "luck": 18.0, "wind": 18.0, 
	"super": 36.0, "curse_dull": 0.5, "curse_frail": 0.5, "curse_heavy": 0.5, "curse_slow": 0.5}
static var mod_wheel_n: = {}
static var mod_wheel_rolls: = 0


func _wheel_w(e: Dictionary) -> float:
	return float(MOD_WHEEL_W.get(str(e.id), float(e.w)))


func _wheel_pick() -> String:
	var total: = 0.0
	for e in GameData.TOWER_WHEEL:
		total += _wheel_w(e)
	var r: = randf() * total
	for e in GameData.TOWER_WHEEL:
		r -= _wheel_w(e)
		if r <= 0.0:
			return _wheel_note(str(e.id))
	return str(GameData.TOWER_WHEEL[0].id)


# [MOD] measured rim statistics -> user://mod_probe_wheel.txt (also printed), so the new odds are
# verifiable from your own spins instead of from the comment above.
func _wheel_note(id: String) -> String:
	mod_wheel_rolls += 1
	mod_wheel_n[id] = int(mod_wheel_n.get(id, 0)) + 1
	if mod_wheel_rolls % 4 == 1:
		var s: = "spins=%d  super=%d (P=%.1f%%) " % [mod_wheel_rolls, int(mod_wheel_n.get("super", 0)), 
			100.0 * int(mod_wheel_n.get("super", 0)) / mod_wheel_rolls]
		for k in mod_wheel_n.keys():
			if str(k) == "super":
				continue
			s += "%s=%d " % [k, mod_wheel_n[k]]
		print("MODPROBE wheel: ", s)
		var f: = FileAccess.open("user://mod_probe_wheel.txt", FileAccess.WRITE)
		if f != null:
			f.store_string(s + "\nat=" + Time.get_datetime_string_from_system() + "\n")
			f.close()
	return id



func _wheel_show(id: String) -> void :
	var e: Dictionary = tower.wheel_entry(id)
	var col: Color = e.color
	var kind_of: = str(e.kind)
	for h in world.alive_heroes():
		if kind_of == "curse":
			world.spawn_fx("devil", h.position, 1.0, 0.9, h)
		else:
			Vfx.column(world.fx_root, h.position, col.lightened(0.3))
			world.spawn_fx("angelus", h.position, 1.2, 1.0, h)
		if kind_of == "super":
			Vfx.ray_flash(world.fx_root, h.position + Vector3(0, 1.0, 0), world.camera.global_basis, Color(1.0, 0.9, 0.4), 2.2)
			Vfx.burst(world.fx_root, h.position, 7.0, Color(1.0, 0.85, 0.3))
	if kind_of == "super":
		world.shake(0.5)
		world.hud.flash(Color(1.0, 0.9, 0.4), 0.6)




func _tick_survive(delta: float, at_floor: int) -> void :
	_left -= delta
	_t += delta
	if _left <= 0.0:
		_end_survive()
		return
	var gap: = maxf(1.3, 2.3 - at_floor * 0.01) / GameData.coop_spawn(world.alive_heroes().size())
	if _t < gap:
		return
	_t = 0.0
	var hero: Array = world.alive_heroes()
	if hero.is_empty():
		return
	var stage: = 1.0 - _left / float(GameData.TOWER_SURVIVE_TIME)


	tower._traps.survive_strike(hero.pick_random(), stage, minf(0.12, 0.05 + at_floor * 0.0008), _center, _radius)


func _end_survive() -> void :
	var clean: = true
	for h in world.heroes:
		if h.hurt_at != float(_hit_mark.get(h, h.hurt_at)):
			clean = false
	if clean:
		_finish(GameData.CHEST_ROLLS.boss, 2, tr("¡Intocable!"), tr("Ni un rasguño: premio mayor"))
	else:
		_finish(GameData.CHEST_ROLLS.boss, 1, tr("¡Sobreviviste!"), tr("El círculo se abre"))
