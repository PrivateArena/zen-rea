extends RefCounted












const MobTraits = preload("res://scripts/core/mob_traits.gd")


var _affixed: Array = []

var _kyrie_word_at: = 0.0
var _kyrie_break_at: = 0.0
var _drain_fx_at: = 0.0

var _lex_at: = {}
var _curse_at: = {}


func clear() -> void :
	_affixed.clear()
	_lex_at.clear()
	_curse_at.clear()
	_kyrie_word_at = 0.0
	_kyrie_break_at = 0.0
	_drain_fx_at = 0.0






func on_spawn(w: World, e: Enemy) -> void :



	var hr: = w.oath("tough")
	if hr > 0 and e.prop == "" and not bool(e.def.get("dummy", false)) and not bool(e.def.get("mvp", false)):
		e.max_hp *= GameData.oath_value("tough", hr)
		e.hp = e.max_hp
	var kr: = w.oath("kyrie")
	if kr > 0 and not e.is_boss and e.prop == "" and not bool(e.def.get("elite", false))\
	and not bool(e.def.get("dummy", false)) and e.special != "runner" and e.id != str(GameData.RUNNER.mob)\
	and randf() < GameData.oath_value("kyrie", kr, 0.0):

		e.kyrie = e.max_hp * GameData.OATH_KYRIE
		e.set_kyrie(true)
	var er: = w.oath("elite")
	if er > 0 and e.feroz and not e.is_boss and e.special not in ["runner", "corrupto", "guardia"]:
		var pool: Array = GameData.OATH_AFFIXES.keys()
		pool.shuffle()
		var n: = int(GameData.oath_value("elite", er, 0.0))
		for a in pool.slice(0, n):
			_learn(e, str(a))
		e.add_title_line(affix_line(e.affixes))
		_affixed.append(e)



func _learn(e: Enemy, a: String) -> void :
	var d: Dictionary = GameData.OATH_AFFIXES[a]
	e.affixes.append(a)
	if d.has("every"):
		e.affix_t[a] = float(d.every) * randf_range(0.5, 1.0)
	if a == "power_up":
		e.damage *= float(d.dmg)



static func affix_line(affixes: PackedStringArray) -> String:
	var names: Array[String] = []
	for a in affixes:
		if GameData.OATH_AFFIXES.has(a):
			names.append(TranslationServer.translate(str(GameData.OATH_AFFIXES[a].name)))
	return " · ".join(names)



func tick(w: World, delta: float) -> void :
	if _affixed.is_empty():
		return
	_affixed = _affixed.filter( func(e): return is_instance_valid(e) and not e.dead)


	if w.raid.in_arena() or (w.morroc != null and w.morroc.fighting()):
		return
	for e in _affixed:
		for a in e.affix_t.keys():
			e.affix_t[a] = float(e.affix_t[a]) - delta
			if float(e.affix_t[a]) > 0.0:
				continue
			e.affix_t[a] = float(GameData.OATH_AFFIXES[a].every) * randf_range(0.85, 1.15)
			match str(a):
				"heal":
					_heal(w, e)
				"teleport":
					_teleport(w, e)
				"summon":
					_summon(w, e)



func _heal(w: World, e: Enemy) -> void :
	var d: Dictionary = GameData.OATH_AFFIXES.heal
	var healed: = false
	for m in w.enemies_in_radius(e.position, float(d.reach)):
		if m.dead or m.is_boss or m.prop != "" or m.hp >= m.max_hp:
			continue
		m.hp = minf(m.max_hp, m.hp + m.max_hp * float(d.heal))
		healed = true
	if not healed:
		return
	w.spawn_fx("cure", e.position, 1.3, 0.9, e)
	Vfx.ring(w.fx_root, e.position + Vector3(0, 0.05, 0), float(d.reach), Color(d.color, 0.7), 0.5)
	w.label_over(e, "Heal", d.color)
	w.play_sound("heal", 0.3, -12.0)



func _teleport(w: World, e: Enemy) -> void :
	var d: Dictionary = GameData.OATH_AFFIXES.teleport
	var h: = w.nearest_hero(e.position)
	if h == null or Vector2(h.position.x - e.position.x, h.position.z - e.position.z).length() < float(d.far):
		return
	var a: = randf() * TAU
	var at: = h.position + Vector3(cos(a), 0.0, sin(a)) * float(d.near)
	if w.map == null or not w.map.is_walkable(at):
		return
	at = Vector3(at.x, w.map.height_at(at), at.z)
	w.spawn_fx("hell_in", e.position, 0.6, 0.7)
	e.position = at
	e.knock = Vector3.ZERO
	w.traits.tell(w, e, MobTraits.NET_JUMP, at)
	MobTraits.emerge(e, w, at)
	w.spawn_fx("hell_in", at, 0.7, 0.8)
	w.label_over(e, "Teleport", d.color)
	w.play_sound("teleport", 0.4, -10.0)



func _summon(w: World, e: Enemy) -> void :
	var d: Dictionary = GameData.OATH_AFFIXES.summon
	var slaves: Array = (e.get_meta("slaves", []) as Array).filter( func(s): return is_instance_valid(s) and not s.dead)
	var room: = int(d.max) - slaves.size()
	if room <= 0:
		e.set_meta("slaves", slaves)
		return
	for i in mini(int(d.count), room):
		var a: = TAU * float(i) / float(d.count) + randf() * 0.6
		var s: = w.spawn_enemy(e.id, e.position + Vector3(cos(a), 0.0, sin(a)) * 1.6, true)
		if s != null:
			s.summoned = true
			slaves.append(s)
	e.set_meta("slaves", slaves)
	w.spawn_fx("hell_in", e.position, 0.9, 0.8)
	w.label_over(e, "Summon Slave", d.color)
	w.play_sound("portal", 0.4, -12.0)





func kyrie_soak(w: World, e: Enemy, amount: float) -> void :
	e.kyrie -= amount
	if e.kyrie > 0.0:
		if w.clock >= _kyrie_word_at:
			_kyrie_word_at = w.clock + 0.3
			w.number(e.position + Vector3(0, e.visual.height() * 0.6, 0), "Kyrie", Color(0.8, 0.92, 1.0))
		return
	e.kyrie = 0.0
	e.set_kyrie(false)
	w.traits.tell(w, e, MobTraits.NET_KYRIE, false)
	if w.clock >= _kyrie_break_at:
		_kyrie_break_at = w.clock + 0.12
		Vfx.burst(w.fx_root, e.position + Vector3(0, 0.6, 0), 0.9, Color(0.85, 0.95, 1.0, 0.9))
		w.play_sound("guard_block", 0.12, -12.0)





func on_hurt(w: World, h: Player, from: Enemy, pierce: bool, hazard: bool) -> void :
	if from == null or not is_instance_valid(from) or hazard or h.hp <= 0.0:
		return
	var key: = h.get_instance_id()

	var lr: = w.oath("lex")
	if lr > 0 and not pierce and w.clock >= float(_lex_at.get(key, 0.0)) and randf() < GameData.OATH_SILENCE_CHANCE:
		_lex_at[key] = w.clock + GameData.oath_value("lex", lr, 10.0)
		var fresh: = not h.powers.has("oath_silence")

		h.powers["oath_silence"] = GameData.OATH_SILENCE
		h._power_look()
		if fresh:
			w.label_over(h, TranslationServer.translate("¡Lex Divina!"), Color(0.8, 0.6, 1.0))
			w.spawn_fx("lexaeterna", h.position, 0.8, 1.0, h)
			w.play_sound("lex_aeterna", 0.3, -8.0)

	var cr: = w.oath("curse")
	if cr > 0:
		h.powers["oath_curse"] = GameData.OATH_CURSE_HOLD
		var cap: = float(GameData.OATH_CURSE_MAX[mini(cr, GameData.OATH_CURSE_MAX.size()) - 1])
		if h.oath_curse < cap and w.clock >= float(_curse_at.get(key, 0.0)):
			_curse_at[key] = w.clock + GameData.OATH_CURSE_GAP
			var first: = h.oath_curse <= 0.0
			h.oath_curse = minf(cap, h.oath_curse + GameData.oath_value("curse", cr, 0.0))
			h.recompute()
			h.hp = minf(h.hp, h.max_hp)
			h._power_look()
			if first:
				w.label_over(h, TranslationServer.translate("¡Maldición!"), Color(0.75, 0.45, 1.0))
				w.spawn_fx("devil", h.position, 0.8, 0.7, h)
				w.play_sound("curse", 0.3, -10.0)

	if from.affixes.has("drain") and not from.dead:
		from.hp = minf(from.max_hp, from.hp + from.max_hp * float(GameData.OATH_AFFIXES.drain.heal))
		if w.clock >= _drain_fx_at:
			_drain_fx_at = w.clock + 0.4
			w.spawn_fx("hit", from.position, 0.6, 0.8)
			w.number(from.position + Vector3(0, from.visual.height() * 0.6, 0), "Blood Drain", GameData.OATH_AFFIXES.drain.color)



func boss_down(w: World) -> void :
	for h in w.heroes:
		if is_instance_valid(h) and h.oath_curse > 0.0:
			lift_curse(h)
			w.label_over(h, TranslationServer.translate("Maldición rota"), Color(0.85, 0.8, 1.0))


static func lift_curse(h: Player) -> void :


	var was: = h.hp
	h.powers.erase("oath_curse")
	h.oath_curse = 0.0
	h.recompute()
	h.hp = minf(was, h.max_hp)
	h._power_look()





static func sworn_list(sworn: Dictionary) -> Array:
	var out: = []
	for o in GameData.OATHS:
		var r: = int(sworn.get(str(o.id), 0))
		if r > 0:
			out.append([o, mini(r, (o.pts as Array).size())])
	return out



static func rank_text(o: Dictionary, r: int) -> String:
	var ranks: Array = o.ranks
	return TranslationServer.translate(str(ranks[clampi(r, 1, ranks.size()) - 1]))



static func rank_tag(o: Dictionary, r: int) -> String:
	var pts: = int((o.pts as Array)[clampi(r, 1, (o.pts as Array).size()) - 1])
	if (o.pts as Array).size() == 1:
		return TranslationServer.translate("%d puntos") % pts
	return TranslationServer.translate("Rango %d/%d  ·  %d puntos") % [r, (o.pts as Array).size(), pts]




static func score_mult(points: int) -> float:
	var base: = 1.0 + 0.25 * (GameData.DANGER_MAX - 1)
	return (base + 0.25 * points) / base


static func icon(o: Dictionary) -> Texture2D:
	return UiKit.skill_icon(str(o.icon))
