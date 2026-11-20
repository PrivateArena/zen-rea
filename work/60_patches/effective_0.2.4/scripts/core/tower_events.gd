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



func pick() -> String:
	var pool: Array = GameData.TOWER_EVENTS.keys().filter( func(k): return k != kind)
	return str(pool.pick_random())


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



func _wheel_pick() -> String:
	var total: = 0.0
	for e in GameData.TOWER_WHEEL:
		total += float(e.w)
	var r: = randf() * total
	for e in GameData.TOWER_WHEEL:
		r -= float(e.w)
		if r <= 0.0:
			return str(e.id)
	return str(GameData.TOWER_WHEEL[0].id)



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
