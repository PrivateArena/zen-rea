extends RefCounted



















const WHEEL: = ["wizard", "knight", "priest", "assassin", "hunter", "crusader"]


const WHEEL_GAP: = 2.4

const SPIRIT_COLORS: = {"wizard": Color(0.55, 0.7, 1.0), "knight": Color(1.0, 0.7, 0.35), "priest": Color(1.0, 0.95, 0.6), 
	"assassin": Color(0.8, 0.45, 1.0), "hunter": Color(0.55, 1.0, 0.5), "crusader": Color(1.0, 0.45, 0.4)}

const TALISMAN_WINDOW: = 3.0


const KA_KAITE_MULT: = 1.2
const KA_KAITE_RADIUS: = 3.4


const KAITE_CHARGES: = 5
const KAITE_MECH_CHARGES: = 2
const KAITE_WAVE_RADIUS: = 5.5


const KAITE_SHOTS: = ["Disparo", "Fire Bolt"]


const KAAHI_HIT: = 0.15
const KAAHI_HIT_GAP: = 0.4

const SPIRIT_TAGS: = ["estin", "esma", "esma_x", "eswoo", "soul_link", "ka_kaite", "kaite_wave", "soul_chain"]



const CHAIN_REACH: = 6.5
const CHAIN_PER_SEC: = 12
const CHAIN_STAGGER: = 0.8


static var stats: = {}


static func _stat(key: String, n: = 1) -> void :
	stats[key] = int(stats.get(key, 0)) + n


static func is_spirit(tag: String) -> bool:
	return tag in SPIRIT_TAGS




static func bound(world: World, e: Enemy) -> bool:
	return e.weak_mult > 0.0 and world.clock < e.weak_until






static func next_spirits(p: Player) -> Array:
	var i: = int(p.get_meta("wheel_i", randi() % WHEEL.size()))
	var lent: = [WHEEL[i % WHEEL.size()]]
	if p.effects.has("soul_double"):
		lent.append(WHEEL[(i + 1) % WHEEL.size()])
	p.set_meta("wheel_i", (i + lent.size()) % WHEEL.size())
	return lent



static func start_wheel(p: Player, lent: Array, time: float, level: int) -> void :
	p.set_meta("soul_wheel", {"spirits": lent, "left": time, "next": 0.6, "lv": level})
	for sp in lent:
		_stat("lend_" + str(sp))



static func tick(world: World, p: Player, delta: float) -> void :
	if not p.has_meta("soul_wheel"):
		return
	var w: Dictionary = p.get_meta("soul_wheel")
	w.left = float(w.left) - delta
	if float(w.left) <= 0.0:
		p.remove_meta("soul_wheel")
		return
	w.next = float(w.next) - delta
	if float(w.next) > 0.0:
		return
	var any: = false
	var lv: = int(w.lv)
	for sp in w.spirits:
		var sid: = str(GameData.SOUL_SPIRIT_CASTS.get(sp, ""))
		if sid == "":
			continue

		var keep: = Vfx.dim
		Vfx.dim = keep * GameData.SOUL_SPIRIT_DIM
		var ok: = Skills.cast(world, p, sid, lv, "soul_link")
		Vfx.dim = keep
		if ok:
			any = true
			world.soul_ghost(p, str(sp))
			_stat("cast_" + sid)

	var gap: = WHEEL_GAP
	for sp in w.spirits:
		var sid: = str(GameData.SOUL_SPIRIT_CASTS.get(sp, ""))
		if sid != "":
			gap = maxf(gap, GameData.skill_value(sid, "cooldown", lv))

	gap /= 1.0 + float(p.effects.get("soul_time", 0.0))
	w.next = gap if any else 0.3






static func show_spirit(world: World, h: Player, lent: Array, time: float, caster: = false) -> void :
	if world.net.recording():
		world.net.record(["slw", world.net.ref_of(h), lent, time, caster])
	if not is_instance_valid(h):
		return

	for n in h.get_meta("spirit_fx", []):
		if is_instance_valid(n):
			n.queue_free()
	h.set_meta("spirit_fx", [])
	if Vfx.hidden():
		return
	var nodes: = []
	for i in lent.size():
		var sp: = str(lent[i])
		var col: Color = SPIRIT_COLORS.get(sp, Color(0.85, 0.75, 1.0))
		var path: = "res://assets/ro/ui/skin/skill_icons/spirit_%s.png" % sp
		if ResourceLoader.exists(path):
			var s: = Sprite3D.new()
			s.texture = load(path)
			s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			s.shaded = false
			s.no_depth_test = true
			s.render_priority = 9
			s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			s.pixel_size = 0.036
			h.add_child(s)


			var top: = RoVisual.lift + Vector3((i - (lent.size() - 1) * 0.5) * 1.0, h.visual.height() + 1.75, 0)
			s.position = top + Vector3(0, -0.5, 0)
			s.scale = Vector3.ONE * 1.8
			s.modulate = Color(1, 1, 1, 0)
			var tw: = s.create_tween()

			tw.tween_property(s, "modulate:a", 1.0, 0.2)
			tw.parallel().tween_property(s, "position", top, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(s, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_interval(maxf(0.1, time - 0.95))
			tw.tween_property(s, "modulate:a", 0.0, 0.4)
			tw.tween_callback(s.queue_free)
			var bob: = s.create_tween().set_loops()
			bob.tween_property(s, "offset:y", 4.0, 0.8).set_trans(Tween.TRANS_SINE)
			bob.tween_property(s, "offset:y", 0.0, 0.8).set_trans(Tween.TRANS_SINE)

			var glow: = Sprite3D.new()
			glow.texture = RoAssets.radial(Color.WHITE, 64)
			glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			glow.shaded = false
			glow.no_depth_test = true
			glow.render_priority = 8
			glow.pixel_size = 0.017
			glow.modulate = Color(col, 0.45 * Vfx.dim)
			s.add_child(glow)
			nodes.append(s)

		var ring: = Vfx.magic_circle(h, Vector3(0, 0.03, 0), 1.25 + 0.35 * i, Color(col, 0.5 * Vfx.dim), 0.0, "mvp_hexa", 0.9 * (1.0 if i == 0 else -1.0))
		if ring != null:
			var rt: = ring.create_tween()
			rt.tween_interval(maxf(0.1, time - 0.4))
			rt.tween_property(ring, "transparency", 1.0, 0.4)
			rt.tween_callback(ring.queue_free)
			nodes.append(ring)
	h.set_meta("spirit_fx", nodes)
	world.spawn_fx("cure", h.position, 1.0, 0.8, h)
	_say(h, lent, caster)





static func _say(h: Player, lent: Array, caster: bool) -> void :
	var names: = []
	var skills: = []
	for sp in lent:
		var pw: Dictionary = GameData.SKILL_POWERS.get("spirit_" + str(sp), {})
		names.append(TranslationServer.translate(str(pw.get("name", sp))))
		var sid: = str(GameData.SOUL_SPIRIT_CASTS.get(sp, ""))
		if sid != "":
			skills.append(TranslationServer.translate(str(GameData.SKILLS[sid].name)))
	var col: Color = SPIRIT_COLORS.get(str(lent[0]), Color(0.85, 0.75, 1.0))
	var l: = Label3D.new()
	l.text = TranslationServer.translate("¡%s!") % " + ".join(names)
	if caster and not skills.is_empty():
		l.text += "\n" + " + ".join(skills)
	l.font = UiKit.FONT_TITLE
	l.font_size = 52
	l.pixel_size = 0.0065
	l.outline_size = 14
	l.outline_modulate = Color(0.12, 0.06, 0.22)
	l.modulate = col.lightened(0.35)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 17
	l.outline_render_priority = 16
	h.add_child(l)
	var top: = RoVisual.lift + Vector3(0, h.visual.height() + 2.6, 0)
	l.position = top
	l.scale = Vector3.ONE * 1.4
	var tw: = l.create_tween()
	tw.tween_property(l, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", top.y + 0.5, 1.4)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.5).set_delay(1.0)
	tw.tween_callback(l.queue_free)



static func net_spirit(world: World, ev: Array) -> void :
	var who = world._net_node(ev[1])
	if who is Player:
		show_spirit(world, who, ev[2], float(ev[3]), ev.size() > 4 and bool(ev[4]))

		var args: = OS.get_cmdline_user_args()
		var at: = args.find("--sl-net")
		if at >= 0 and args.size() > at + 1:
			_stat("net_spirit")
			print("SLNET guest saw %s on hero %d (own=%s) for %.1fs" % [ev[2], (who as Player).slot, who == world.player, float(ev[3])])


			if who != world.player:
				world.player.position = (who as Player).position + Vector3(1.6, 0, 0.4)
			if int(stats.net_spirit) <= 4 and DisplayServer.get_name() != "headless":
				var n: = int(stats.net_spirit)
				world.get_tree().create_timer(0.7, false).timeout.connect( func():
					DirAccess.make_dir_recursive_absolute(str(args[at + 1]))
					world.get_viewport().get_texture().get_image().save_png("%s/guest_%d.png" % [args[at + 1], n]))





static func after_cast(world: World, p: Player, id: String) -> void :
	var b: = Player.base_skill(id)
	if not (b in ["estin", "esma", "eswoo"]):
		return
	var step: = int(p.get_meta("talisman", 0))
	var at: = float(p.get_meta("talisman_at", -99.0))
	var fresh: = world.clock - at <= TALISMAN_WINDOW
	match b:
		"estin":


			if step != 2 or not fresh:
				p.set_meta("talisman", 1)
				p.set_meta("talisman_at", world.clock)
		"esma":
			p.set_meta("talisman", 2 if step >= 1 and fresh else 0)
		"eswoo":
			p.set_meta("talisman", 0)
			if step == 2 and fresh:
				ka_kaite(world, p)




static func ka_kaite(world: World, p: Player) -> void :
	var near: = world.enemies_in_radius(p.position, 10.0)
	if near.is_empty():
		return
	var target: Enemy = null
	var best: = -1
	near.shuffle()
	for e in near.slice(0, 8):
		var n: = world.enemies_in_radius(e.position, KA_KAITE_RADIUS).size() + (100 if e.is_boss else 0)
		if n > best:
			best = n
			target = e
	var at: = target.position
	var el: = Skills.best_element(near) if p.effects.has("spirit_seek") else p.basic_element()
	var col: Color = GameData.ELEMENT_COLORS[el] if el != "neutral" else Color(0.75, 0.65, 1.0)
	var dmg: = 0.0
	for sid in ["estin", "esma", "eswoo"]:
		var own: String = sid
		if not p.skills.has(own) and p.skills.has(sid + "_x"):
			own = sid + "_x"
		if p.skills.has(own):
			dmg += GameData.skill_value(own, "damage", int(p.skills[own].level))
	dmg *= KA_KAITE_MULT
	var radius: = KA_KAITE_RADIUS * p.area_mult
	_stat("ka_kaite")
	world.label_over(p, TranslationServer.translate("¡Ka-Kaite!"), col.lightened(0.35))

	for i in 3:
		Skills.soul_missile(world, p.position + Vector3(0, 1.3, 0), target, 0.38, float(i - 1) * 1.4, col, Color(0.72, 0.6, 1.0))
	Vfx.magic_circle(world.fx_root, at, radius, Color(col, 0.75), 1.1, "mvp_hexa", 2.4)
	Vfx.converge(world.fx_root, at, radius, Color(col, 0.6), 0.38)
	world.play_sound("sl_soul", 0.2, -4.0)
	var by: = p
	world._own_timer(0.4, func():
		if not world.running or not is_instance_valid(by):
			return
		world.damage_tag = "ka_kaite"
		world.damage_by = by
		for e in world.enemies_in_radius(at, radius):
			var away: = ((e.position - at) * Vector3(1, 0, 1)).normalized()
			world.damage_enemy(e, dmg, away * 4.0, "skill", el, "ka_kaite")
		Vfx.strike_circle(world.fx_root, at, radius, col)
		Vfx.burst(world.fx_root, at, radius, col)
		Vfx.ring(world.fx_root, at, radius * 1.15, col.lightened(0.3), 0.45)
		Vfx.ring(world.fx_root, at, radius * 0.6, Color(0.8, 0.7, 1.0), 0.35)
		Vfx.column(world.fx_root, at, col.lightened(0.4))
		world.sprite_fx("fx_sl_4", at + Vector3(0, 0.6, 0), 0, 1.6)
		for k in 8:
			var a: = TAU * k / 8.0
			world.sprite_fx("fx_sl_4" if k % 2 == 0 else "fx_sl_6", at + Vector3(cos(a), 0.5, sin(a)) * radius * 0.6, 0, 0.9)
		if is_instance_valid(target) and not target.dead:
			world.label_over(target, TranslationServer.translate("¡Ka-Kaite!"), col.lightened(0.35))
		world.shake(0.3)
		world.play_sound("sl_shoot", 0.1, -2.0, 0.8))





static func kaite_cast(to: Player, by: Player) -> void :
	to.set_meta("kaite_by", by)





static func kaite_absorb(world: World, p: Player, from: Enemy, what: String, pierce: bool, hazard: bool) -> bool:
	if p.shield <= 0.0 or Player.base_skill(p.shield_src) != "kaite" or hazard:
		return false
	var mvp: = from != null and is_instance_valid(from) and bool(from.def.get("mvp", false))
	var mech: = pierce and mvp
	if not mech and (pierce or not (what in KAITE_SHOTS)):
		return false
	var charges: = int(p.get_meta("kaite_charges", 0)) + (KAITE_MECH_CHARGES if mech else 1)
	_stat("kaite_mech" if mech else "kaite_shot")
	if mech:
		p.shield = 0.0
	world.sprite_fx("fx_sl_3", p.position, 0, 0.75 if not mech else 1.1, p)
	world.play_sound("sl_reflect", 0.12, -6.0 if not mech else -2.0)
	if mech:
		world.label_over(p, TranslationServer.translate("¡Kaite!"), Color(0.8, 0.85, 1.0))
		Vfx.ring(world.fx_root, p.position, 2.2, Color(0.8, 0.85, 1.0), 0.4)
	if charges >= KAITE_CHARGES:
		p.set_meta("kaite_charges", 0)
		kaite_wave(world, p)
	else:
		p.set_meta("kaite_charges", charges)
		world.number(p.position + Vector3(0, 2.2, 0), "Kaite %d/%d" % [charges, KAITE_CHARGES], Color(0.8, 0.85, 1.0))
	p._invuln = 0.12
	return true




static func kaite_wave(world: World, p: Player) -> void :
	var by = p.get_meta("kaite_by", p)
	if not (by is Player) or not is_instance_valid(by):
		by = p
	var caster: Player = by
	var sid: = "kaite_x" if caster.skills.has("kaite_x") else "kaite"
	var lv: = int(caster.skills[sid].level) if caster.skills.has(sid) else 1
	var dmg: = GameData.skill_value(sid, "wave", lv)
	var radius: = KAITE_WAVE_RADIUS * caster.area_mult
	_stat("kaite_wave")
	world.damage_tag = "kaite_wave"
	world.damage_by = caster
	for e in world.enemies_in_radius(p.position, radius):
		var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, dmg, away * 6.0, "skill", caster.basic_element(), "kaite_wave")
	var col: = Color(0.8, 0.85, 1.0)
	world.label_over(p, TranslationServer.translate("¡Onda de Kaite!"), col)
	Vfx.magic_circle(world.fx_root, p.position, radius * 0.7, Color(col, 0.7), 0.8, "mvp_hexa", -2.0)
	Vfx.ring(world.fx_root, p.position, radius, col, 0.5)
	Vfx.ring(world.fx_root, p.position, radius * 0.65, Color(0.75, 0.62, 1.0), 0.4)
	Vfx.burst(world.fx_root, p.position, radius * 0.8, Color(col, 0.8))
	for k in 6:
		var a: = TAU * k / 6.0
		world.sprite_fx("fx_sl_7" if k % 2 == 0 else "fx_sl_6", p.position + Vector3(cos(a), 0.4, sin(a)) * radius * 0.6, 0, 0.85)
	world.shake(0.25)
	world.play_sound("sl_reflect", 0.1, 0.0, 0.7)





static func damage_mult(world: World, p: Player, e: Enemy, tag: String) -> float:
	if p.effects.has("lg_soul_chain") and is_spirit(tag) and bound(world, e):
		return 1.0 + float(p.effects.lg_soul_chain)
	return 1.0



static func after_hit(world: World, p: Player, e: Enemy, tag: String) -> void :
	if not is_spirit(tag):
		return
	if p.effects.has("kaahi") and p.hp > 0.0 and not p.downed and world.clock >= float(p.get_meta("kaahi_hit_at", -1.0)):
		p.set_meta("kaahi_hit_at", world.clock + KAAHI_HIT_GAP)
		var before: = p.hp
		p.heal(p.max_hp * float(p.effects.kaahi) * KAAHI_HIT, world)
		_stat("kaahi_heal", roundi(p.hp - before))

		if is_instance_valid(e):
			Skills.soul_missile(world, e.position + Vector3(0, 0.8, 0), p, 0.3, 1.0 if randf() < 0.5 else -1.0, 
				Color(0.55, 1.0, 0.6), Color(0.8, 1.0, 0.8))
	if p.effects.has("lg_soul_chain") and e.is_boss and not e.dead and bound(world, e):
		world.stagger.add(world, e, CHAIN_STAGGER, "soulchain:%d:%s" % [p.get_instance_id(), tag])
		_stat("chain_stagger")



static func on_kill(world: World, p: Player, e: Enemy) -> void :
	if not p.effects.has("lg_soul_chain") or not bound(world, e):
		return

	var sec: = int(world.clock)
	if int(p.get_meta("chain_sec", -1)) != sec:
		p.set_meta("chain_sec", sec)
		p.set_meta("chain_n", 0)
	if int(p.get_meta("chain_n", 0)) >= CHAIN_PER_SEC:
		return

	var best: Enemy = null
	var best_d: = INF
	for o in world.enemies_in_radius(e.position, CHAIN_REACH):
		if o == e or o.dead or o.prop != "":
			continue
		var d: = e.position.distance_squared_to(o.position) + (100.0 if bound(world, o) else 0.0)
		if d < best_d:
			best_d = d
			best = o
	if best == null:
		return
	p.set_meta("chain_n", int(p.get_meta("chain_n", 0)) + 1)
	var depth: = int(e.get_meta("soul_chain", 0)) + 1
	best.set_meta("soul_chain", depth)
	_stat("chain_jump")
	stats["chain_max"] = maxi(int(stats.get("chain_max", 0)), depth)


	var sid: = "esma_x" if p.skills.has("esma_x") else "esma"
	var lv: = int(p.skills[sid].level) if p.skills.has(sid) else 1
	var ew: = "eswoo_x" if p.skills.has("eswoo_x") else "eswoo"
	var el: = p.basic_element()
	var col: Color = GameData.ELEMENT_COLORS[el] if el != "neutral" else Color(0.7, 0.65, 1.0)
	var sk: = {"color": col, "element": el, "hit_sprite": "fx_sl_4", "hit_sprites": 1, "hit_sprite_size": 0.75, 
		"hit_column": true, "sound": "sl_shoot", "sound_db": -8.0, "slow": float(GameData.SKILLS.eswoo.slow), "shrink": true, 
		"mark": float(GameData.SKILLS.eswoo.mark), "weak": float(GameData.SKILLS.eswoo.weak), "mark_time": float(GameData.SKILLS.eswoo.mark_time)}
	if GameData.SKILLS.has(ew) and ew != "eswoo":
		sk.mark_time = float(GameData.SKILLS[ew].get("mark_time", sk.mark_time))
	Skills.soul_missile(world, e.position + Vector3(0, 0.8, 0), best, 0.3, 1.0 if depth % 2 == 0 else -1.0, col, Color(0.72, 0.6, 1.0))
	var tag: = world.damage_tag
	var by: = world.damage_by
	world.damage_tag = "soul_chain"
	world.damage_by = p
	world.delayed_aoe(best.position, GameData.skill_value(sid, "area", lv) * 0.7 * p.area_mult, GameData.skill_value(sid, "damage", lv), 
		0.32, sk, false)
	world.damage_tag = tag
	world.damage_by = by






static func sim_build(world: World, args: Array) -> void :
	stats.clear()
	var p: = world.player
	p.job_change(1)
	p.skills.clear()
	for id in ["esma", "estin", "eswoo", "kaite", "soul_link", "kaahi"]:
		p.add_skill(id)

	if "--sl-max" in args:
		for id in p.skills.keys():
			for k in GameData.MAX_SKILL_LEVEL:
				p.add_skill(id)
		for id in p.skills.keys():
			if GameData.EVOLUTIONS.has(id):
				p.evolve(id)
	var eq_at: = args.find("--sl-equip")
	if eq_at >= 0 and args.size() > eq_at + 1:
		var it: = Equipment.make(str(args[eq_at + 1]), 0)
		p.equipment.slots[str(Equipment.item_def(it).slot)] = it
	p.recompute()
	p.hp = p.max_hp
	world.hud.bind(world)
	p.set_meta("sl_sim", true)
	print("SOULSIM build job=%s skills=%s" % [p.job2.get("id", ""), p.skills.keys()])


static func sim_report(world: World) -> void :
	var p: = world.player
	if p == null or not p.has_meta("sl_sim"):
		return
	var total: = 0.0
	var rows: = world.meter_sorted()
	for r in rows:
		total += float(r.dmg)
	var share: = []
	for r in rows.slice(0, 12):
		share.append("%s=%.1f%%" % [r.tag, 100.0 * float(r.dmg) / maxf(1.0, total)])
	print("SOULSIM share=%s" % [share])
	print("SOULSIM skills=%s" % [p.skills.keys().map( func(k): return "%s:%d" % [k, int(p.skills[k].level)])])
	print("SOULSIM stats=%s" % [stats])
	print("SOULSIM end time=%.0f level=%d hp=%d/%d downed=%s revives=%d total=%d" % [world.time, p.level, p.hp, p.max_hp, p.downed, 
		int(p.revives), roundi(total)])





static func shots_test(world: World, dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	world._shot_dir = dir
	var tree: = world.get_tree()
	var wait: = func(t: float): await tree.create_timer(t, true, false, true).timeout
	var shot: = func(label: String):
		if DisplayServer.get_name() != "headless":
			await world._tour_shot(label)
	stats.clear()
	GameData.set_meta("no_spawn", true)
	world.menus.auto_pick = true
	world.start_run("taekwon")
	world.menus.close()
	tree.paused = false
	Engine.time_scale = 1.0
	await wait.call(0.5)
	world.menus.close()
	tree.paused = false
	var p: = world.player
	p.job_change(1)
	p.skills.clear()
	for id in ["estin", "esma", "eswoo", "kaite", "soul_link", "kaahi"]:
		for k in GameData.MAX_SKILL_LEVEL:
			p.add_skill(id)
	p.recompute()
	p.max_hp = 99999.0
	p.hp = 99999.0
	for id in p.skills:
		p.skills[id].cd = 1000000000.0
	world.hud.bind(world)
	var nums = Save.setting("damage_numbers", true)
	var c: = p.position + Vector3(2.8, 0, 0)
	world._test_foes(10, 2.0, c)
	var big: = world.spawn_enemy(str(world.stage.mvp), c + Vector3(0.6, 0, -0.4), true)
	if big != null:
		big.max_hp = 1000000000.0
		big.hp = 1000000000.0
		big.speed = 0.0
	world._rebuild_grid()
	await wait.call(0.4)

	for n in WHEEL.size():
		p.set_meta("wheel_i", n)
		Skills.cast(world, p, "soul_link", 5)
		await wait.call(0.25)
		await shot.call("1_wheel_%d_%s_a" % [n, WHEEL[n]])
		await wait.call(0.45)
		await shot.call("1_wheel_%d_%s_b" % [n, WHEEL[n]])
		await wait.call(1.4)
	print("SLREWORK wheel stats=%s" % [stats])
	p.remove_meta("soul_wheel")
	await wait.call(1.0)

	for id in ["estin", "esma", "eswoo"]:
		Skills.cast(world, p, id, 5)
		after_cast(world, p, id)
		await wait.call(0.25)
	await shot.call("2_kakaite_a")
	await wait.call(0.25)
	await shot.call("2_kakaite_b")
	await wait.call(0.2)
	await shot.call("2_kakaite_c")
	print("SLREWORK ka_kaite=%d meter=%d" % [int(stats.get("ka_kaite", 0)), roundi(float(world.meter.get("ka_kaite", {}).get("dmg", 0.0)))])
	await wait.call(1.0)

	p.shield = 0.0
	Skills.cast(world, p, "kaite", 5)
	await wait.call(0.3)
	var hp0: = p.hp
	for k in 3:
		world.hurt_what = "Disparo"
		p._invuln = 0.0
		p.take_damage(500.0, world, big)
		await wait.call(0.3)
	await shot.call("3_kaite_charges")
	world.hurt_what = "Golpe del MVP"
	p._invuln = 0.0
	p.take_damage(5000.0, world, big, true)
	await wait.call(0.12)
	await shot.call("3_kaite_wave_a")
	await wait.call(0.2)
	await shot.call("3_kaite_wave_b")
	print("SLREWORK kaite hp_lost=%d shield=%d stats=%s wave_meter=%d" % [roundi(hp0 - p.hp), roundi(p.shield), stats, 
		roundi(float(world.meter.get("kaite_wave", {}).get("dmg", 0.0)))])
	await wait.call(1.0)

	p.equipment.slots["weapon"] = Equipment.make("chained_souls", 0)
	p.recompute()
	p.max_hp = 99999.0
	p.hp = 99999.0
	world._clear_foes()
	if big != null and is_instance_valid(big):
		big.dead = false
	var c2: = p.position + Vector3(0, 0, 3.0)
	for i in 16:
		var a: = TAU * i / 16.0
		var e: = world.spawn_enemy("poring" if i % 2 == 0 else "lunatic", c2 + Vector3(cos(a), 0, sin(a)) * (1.2 + (i % 4) * 1.1), true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 1.0
			e.hp = 1.0
	world._rebuild_grid()
	await wait.call(0.3)

	var first: Enemy = null
	for e in world.enemies_in_radius(c2, 6.0):
		if e.prop == "" and not e.is_boss:
			e.weak_mult = 0.25
			e.weak_until = world.clock + 4.0
			e.shrink(4.0)
			if first == null:
				first = e
	if first != null:
		world.damage_tag = "esma"
		world.damage_by = p
		world.damage_enemy(first, 99999.0, Vector3.ZERO, "skill", "neutral", "esma")
		world.damage_by = null
	for k in 4:
		await wait.call(0.2)
		await shot.call("4_chain_%d" % k)
	await wait.call(1.0)
	print("SLREWORK chain jumps=%d max=%d" % [int(stats.get("chain_jump", 0)), int(stats.get("chain_max", 0))])

	var boss: = world.spawn_enemy(str(world.stage.mvp), p.position + Vector3(3.0, 0, 0), true)
	if boss != null:
		boss.max_hp = 1000000000.0
		boss.hp = 1000000000.0
		boss.speed = 0.0
		world._rebuild_grid()
		for k in 24:
			boss.weak_mult = 0.25
			boss.weak_until = world.clock + 4.0
			Skills.cast(world, p, ["estin", "esma", "eswoo"][k % 3], 5)
			await wait.call(0.55)
		await shot.call("5_mvp_aguante")
		print("SLREWORK mvp stagger=%s status=%s fills=%d" % [world.stagger._of.get(boss.get_instance_id(), {}), boss.status, int(stats.get("chain_stagger", 0))])
	print("SLREWORK done kaahi_heal=%d" % int(stats.get("kaahi_heal", 0)))
	Save.data.settings["damage_numbers"] = nums
	tree.quit()






static func bench(world: World, args: Array) -> void :
	var tree: = world.get_tree()
	var wait: = func(t: float): await tree.create_timer(t, false).timeout
	GameData.set_meta("no_spawn", true)
	GameData.set_meta("tour_god", true)
	var at: = args.find("--sl-bench")
	var cases: = str(args[at + 1]).split(",") if at >= 0 and args.size() > at + 1 and not str(args[at + 1]).begins_with("--")\
	else PackedStringArray(["taekwon:1:0", "archer:0:1", "mage:0:1"])
	var secs: = 30.0
	for c in cases:
		var parts: = c.split(":")
		var cls: = parts[0]
		Save.data.rebirths[cls] = 1 if parts.size() > 2 and parts[2] == "1" else 0
		for target in ["horde", "mvp"]:
			stats.clear()
			world.menus.auto_pick = true
			world.start_run(cls)
			await wait.call(0.3)
			world.menus.close()
			tree.paused = false
			Engine.time_scale = 4.0
			var p: = world.player
			p.level = 99
			p.job_change(int(parts[1]) if parts.size() > 1 else 0)
			p.skills.clear()
			var actives: Array = (p.job2.get("skills", []) as Array) + (p.def.skills as Array)
			var passives: Array = (p.job2.get("passives", []) as Array) + (p.def.get("passives", []) as Array)
			for id in actives:
				if GameData.SKILLS.has(id) and not p.skills.has(id) and p.count_skills(false) < p.max_skills():
					p.add_skill(str(id))
			for id in passives:
				if GameData.SKILLS.has(id) and not p.skills.has(id) and p.count_skills(true) < p.max_passives():
					p.add_skill(str(id))
			for id in p.skills:
				p.skills[id].level = GameData.MAX_SKILL_LEVEL
			for id in p.skills.keys():
				if GameData.EVOLUTIONS.has(id):
					p.evolve(id)
			for st in p.stats:
				p.stats[st] = maxi(int(p.stats[st]), GameData.MAX_STAT)
			p.recompute()
			p.hp = p.max_hp
			world.hud.bind(world)
			var c0: = p.position + Vector3(3.5, 0, 0)
			if target == "horde":
				for i in 40:
					var a: = TAU * i / 40.0
					var e: = world.spawn_enemy("poring" if i % 2 == 0 else "lunatic", c0 + Vector3(cos(a), 0, sin(a)) * (1.5 + (i % 5) * 1.3), true)
					if e != null:
						e.speed = 0.0
						e.max_hp = 1000000000.0
						e.hp = 1000000000.0
			else:
				var b: = world.spawn_enemy(str(world.stage.mvp), c0, true)
				if b != null:
					b.speed = 0.0
					b.max_hp = 1000000000000.0
					b.hp = 1000000000000.0
			world._rebuild_grid()
			world.meter.clear()
			var t0: = world.clock
			while world.clock - t0 < secs:
				await wait.call(0.5)

				p.position = Vector3(c0.x - 3.5, p.position.y, c0.z)
			var total: = 0.0
			var rows: = world.meter_sorted()
			for r in rows:
				total += float(r.dmg)
			var top: = []
			for r in rows.slice(0, 8):
				top.append("%s=%.0f%%" % [r.tag, 100.0 * float(r.dmg) / maxf(1.0, total)])
			print("SLBENCH %s job=%s %s dps=%d top=%s stats=%s" % [c, p.job2.get("id", ""), target, roundi(total / secs), top, stats])
	tree.quit()
