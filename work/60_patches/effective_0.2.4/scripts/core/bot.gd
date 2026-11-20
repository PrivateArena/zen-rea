class_name Bot
extends RefCounted





const DIRS: = 16
const LOOK: = 2.2
const SENSE: = 9.0


static var _prev: = {}





static func pick_choice(p: Player, choices: Array) -> Dictionary:
	var best: Dictionary = choices[0]
	var best_score: = - INF
	for c in choices:
		var s: = _score(p, c)
		if s > best_score:
			best_score = s
			best = c
	return best


static func _score(p: Player, c: Dictionary) -> float:
	var steps: = maxi(1, int(c.get("level", 1)) - int(c.get("from", int(c.get("level", 1)) - 1)))
	var bonus: = 1.0 + 0.25 * (steps - 1)
	match str(c.kind):
		"evolve":
			return 1000.0
		"potion":
			return 1.0
		"stat":
			return _stat_score(p, str(c.id)) * bonus
		"skill":
			return _skill_score(p, str(c.id), int(c.level)) * bonus
	return 0.0




static func _skill_score(p: Player, id: String, level: int) -> float:
	var d: Dictionary = GameData.SKILLS[id]
	var typ: = str(d.get("type", ""))
	var s: = 0.0
	if typ == "passive":
		s = 25.0
		for base in GameData.EVOLUTIONS:
			if str(GameData.EVOLUTIONS[base].passive) == id and p.skills.has(base):
				s = 75.0
	elif typ in ["heal", "buff", "shield"]:
		s = 35.0
		if typ == "heal" and p.hp < p.max_hp * 0.6:
			s = 55.0
	else:
		s = 55.0
		if typ in ["aoe_self", "aoe_target", "petal_rain", "ground", "orbit", "summon", "falcon", "bolt"]:
			s += 15.0
		if GameData.EVOLUTIONS.has(id):
			s += 10.0
		if p.skills.has(id):

			s += 8.0
	if level > GameData.MAX_SKILL_LEVEL:
		s *= 0.6
	return s



static func _stat_score(p: Player, id: String) -> float:
	var main: = "str"
	var top: = -1
	for k in p.def.get("stats", {}):
		if int(p.def.stats[k]) > top:
			top = int(p.def.stats[k])
			main = str(k)

	var by: = {}
	for sid in p.skills:
		if GameData.SKILLS[sid].has("damage"):
			var w: = GameData.skill_stats(sid)
			for k in w:
				var st: = "vit" if k == "hp" else str(k)
				by[st] = float(by.get(st, 0.0)) + float(w[k])
	var best: = 0.0
	for k in by:
		if float(by[k]) > best:
			best = float(by[k])
			main = str(k)

	if main == "dex":
		main = "str"
	var s: = 18.0
	if id == main:
		s = 40.0
	elif id == "agi":
		s = 28.0
	elif id == "vit":
		s = 34.0 if p.hp < p.max_hp * 0.5 else 22.0
	if p.run_stat(id) >= p.stat_cap:
		s *= 0.5
	return s




static func altar_goal(w: World) -> Vector3:
	var p: = w.player
	if p.hp < p.max_hp * 0.7 or w.raid.in_arena() or w.morroc.active():
		return Vector3.INF
	for a in w.altars.waiting:
		var d: Dictionary = GameData.ALTARS[a.id]
		if d.has("npc"):
			continue
		var free: = str(d.get("bad", "")) == ""
		if not free and w.altars.taken.size() >= 3:
			continue
		if Vector2(a.pos.x - p.position.x, a.pos.z - p.position.z).length() > 45.0:
			continue
		if w.enemies_in_radius(a.pos, 5.0).size() > 12:
			continue
		return a.pos
	return Vector3.INF







static func steer(w: World, goal: = Vector3.INF, hero: Player = null) -> Vector2:
	var p: = hero if hero != null else w.player
	var prev: Vector3 = _prev.get(p.get_instance_id(), Vector3.ZERO)
	var pos: = p.position
	var near: = w.enemies_in_radius(pos, SENSE)
	var hp_ratio: = p.hp / maxf(1.0, p.max_hp)
	var ranged: bool = p.def.basic.get("ranged", false) or p.def.has("cast")
	var target: = w.nearest_enemy(pos, 14.0)


	var bold: = not ranged and hp_ratio > 0.5
	var pack: = w.enemies_in_radius(target.position, 2.5).size() if target != null else 0
	var loot: = _loot_dir(w, pos)
	var to_goal: = Vector3.ZERO
	if goal != Vector3.INF:
		to_goal = (goal - pos) * Vector3(1, 0, 1)


		if to_goal.length() < 0.8:
			to_goal = Vector3.ZERO
	var best: = Vector3.ZERO
	var best_score: = - INF
	for i in DIRS:
		var a: = TAU * float(i) / DIRS
		var d: = Vector3(cos(a), 0, sin(a))
		var ahead: = pos + d * LOOK
		if not w.map.is_walkable(pos + d * 0.8) or not w.map.is_walkable(ahead):
			continue
		var score: = - _danger(w, near, ahead) * (0.3 if bold else 1.0)

		var room: = 0
		for k in [-1, 0, 1]:
			var b: float = a + k * 0.6
			if w.map.is_walkable(ahead + Vector3(cos(b), 0, sin(b)) * 2.5):
				room += 1
		score -= (3 - room) * 0.6
		score -= _shot_danger(w, p, d)
		if target != null:
			var to: = (target.position - pos) * Vector3(1, 0, 1)
			var dist: = to.length()
			to = to.normalized()
			if bold and pack < 7:

				score += d.dot(to) * 1.5
			elif bold and hp_ratio > 0.75:

				score += d.dot(to) * 0.9
			elif ranged and dist < 4.0:
				score -= d.dot(to) * 0.8
			elif ranged and dist > 7.0:

				score += d.dot(to) * 0.6
		if to_goal != Vector3.ZERO:
			score += d.dot(to_goal.normalized()) * (1.6 if hp_ratio > 0.4 else 0.5)
		if loot != Vector3.ZERO and near.size() < 6:
			score += d.dot(loot.normalized()) * 0.6
		score += d.dot(prev) * 0.25
		score += d.dot(( - pos * Vector3(1, 0, 1)).normalized()) * 0.05
		if score > best_score:
			best_score = score
			best = d
	if best == Vector3.ZERO:
		return Vector2.ZERO
	_prev[p.get_instance_id()] = best
	return Vector2(best.x, best.z)



static func _danger(w: World, near: Array[Enemy], at: Vector3) -> float:
	var s: = 0.0
	for e in near:
		if e.dead:
			continue
		var d: = (at - e.position) * Vector3(1, 0, 1)
		var k: = 3.0 if e.is_boss else (1.6 if e.def.get("elite", false) else 1.0)
		s += k / maxf(d.length_squared(), 0.35)
	return s



static func _shot_danger(w: World, p: Player, d: Vector3) -> float:
	var pos: = p.position
	var s: = 0.0
	for sh in w.enemy_shots:
		var node: Node3D = sh.node
		if not is_instance_valid(node):
			continue
		for t in [0.25, 0.5]:
			var me: Vector3 = pos + d * p.move_speed * t
			var it: Vector3 = node.position + sh.dir * float(sh.speed) * t
			var gap: = Vector2(me.x - it.x, me.z - it.z).length()
			if gap < 1.2:
				s += (1.2 - gap) * 4.0
	return s



static func _loot_dir(w: World, pos: Vector3) -> Vector3:
	var best: = 12.0
	var out: = Vector3.ZERO
	for pk in w.pickups:
		var to: Vector3 = (pk.node.position - pos) * Vector3(1, 0, 1)
		var l: = to.length() * (0.3 if pk.kind in ["chest", "tame", "branch", "card"] else 1.0)
		if l < best:
			best = l
			out = to
	return out
