class_name Skills
extends RefCounted











static func element_of(p: Player, s: Dictionary) -> String:
	if s.get("uses_arrows", false):
		return p.arrow_element() if not p.effects.has("holy_weapon") else "holy"

	if p.effects.has("holy_weapon") and str(s.get("element", "neutral")) == "neutral":
		return "holy"

	if s.has("elements"):
		return str((s.elements as Array).pick_random())
	return s.get("element", "neutral")




static func _proj_sprite(p: Player, s: Dictionary) -> String:
	if s.get("ammo_sprite", false) and RoAssets.has_sprite("item_" + p.arrow_id):
		return "item_" + p.arrow_id
	if s.get("boomerang", false) and p.equipment != null:
		var it = p.equipment.slots.get("shield")
		if it != null:
			var key: = "item_%s" % str(it.id)
			if RoAssets.sprite([key]) != null:
				return key
	return s.get("proj_sprite", "")


static func arrow_mult(p: Player, s: Dictionary) -> float:
	var m: = p.arrow_bonus() if s.get("uses_arrows", false) else 1.0

	if s.get("thrown", false):
		m *= 1.0 + float(p.effects.get("throw_dmg", 0.0))
	return m




static func taunt(world: World, p: Player, e: Enemy) -> void :
	var time: float = float(p.provoke.time) * (GameData.TAUNT_BOSS if e.is_boss else 1.0)
	if e.is_boss and world.clock >= e.taunt_until:
		world.side_word(e, TranslationServer.translate("¡Provocado!"), Color(1.0, 0.45, 0.3))
	e.taunt(p, world.clock + time, float(p.provoke.vuln))


static func cast(world: World, p: Player, id: String, level: int, tag: = "") -> bool:
	var s: Dictionary = GameData.SKILLS[id]

	if s.get("combo_only", false):
		if tag != "combo":
			return false
		tag = id

	if s.get("stance", false):
		if tag != "stance":
			return false
		tag = id

	world.damage_tag = tag if tag != "" else id
	world.damage_by = p
	var v: = func(field: String) -> float:
		var x: = GameData.skill_value(id, field, level)

		if field == "damage" and s.get("song", false):
			x *= p.song_power(id)
		elif field == "status_chance" and s.get("song", false):
			x *= p.song_cast


		var amp: = float(p.effects.get("amp", 0.0))
		if amp > 0.0 and s.get("magic", false) and field == "damage":
			x *= 1.0 + amp

		if tag.begins_with("proc:") and field in ["amount", "heal_amount"]:
			x *= GameData.proc_level_mult(p.level)

		if field == "damage" and s.get("ninjutsu", false) and not p.charms.is_empty():
			x *= 1.0 + (GameData.CHARM_DMG + float(p.effects.get("charm_dmg", 0.0))) * p.charms.size()


		if field == "damage" and s.has("tank_hp"):
			x += p.scaling_hp() * float(s.tank_hp) + p.armor * float(s.tank_def)


		if field == "damage" and tag.begins_with("proc:"):
			x *= p.proc_bake
		if field == "duration":
			return x * p.duration_mult
		return x + p.extra_count if field == "count" and s.has("count") else x
	match s.type:
		"melee_arc":
			return _melee_arc(world, p, s, v)
		"meteor":
			return _meteor_assault(world, p, s, v)
		"kick":
			return _kick(world, p, s, v)
		"flying_kick":
			return _flying_kick(world, p, s, v)
		"leap":
			return _leap(world, p, s, v)
		"mild_wind":
			return _mild_wind(world, p, s, v)
		"warmth":


			if p.powers.has("warmth_" + str(s.aura)) or world.nearest_enemy(p.position, v.call("range") * p.area_mult + 1.0) == null:
				return false
			p.aura[str(s.aura)] = {"kind": str(s.aura), "dmg": v.call("damage"), "range": v.call("range") * p.area_mult, 
				"every": float(s.every), "knock": float(s.get("knock", 0.0)), "area": v.call("area"), 
				"element": element_of(p, s), "color": s.color, "tag": id, "t": 0.1}
			p.add_power("warmth_" + str(s.aura), v.call("duration"))
			world.number(p.position + Vector3(0, 2.4, 0), TranslationServer.translate(str(s.name)), s.color, true)
			Vfx.burst(world.fx_root, p.position, float(p.aura[str(s.aura)].range), s.color)
			p.play_attack(p.facing, true)
			world.play_skill_sound(s)
			return true
		"union":
			if p.powers.has("union") or world.nearest_enemy(p.position, 8.0) == null:
				return false

			p.add_power("union", v.call("duration") * (GameData.U_COSMOS_DURATION if p.effects.has("u_cosmos") else 1.0))
			world.number(p.position + Vector3(0, 2.6, 0), TranslationServer.translate("¡Unión del Sol, la Luna y las Estrellas!"), s.color, true)
			world.shake(0.5)
			Vfx.column(world.fx_root, p.position, Color(1.0, 0.9, 0.5))
			Vfx.burst(world.fx_root, p.position, 4.0, s.color)
			Vfx.ring(world.fx_root, p.position, 5.0, Color(1.0, 0.95, 0.7), 0.6)
			world.spawn_fx("efst_gold_shower", p.position, 1.2, 0.9, p)
			world.play_skill_sound(s)
			world.play_sound("sg_electric", 0.0, -6.0)
			return true
		"soul_link":
			return _soul_link(world, p, s, v)
		"backstab":


			if not p.dash.is_empty() or p.blinking > 0.0:
				return false
			var stabs: = maxi(1, int(v.call("count")))


			if id.begins_with("back_stab"):
				stabs = maxi(1, stabs - p.extra_count + mini(p.extra_count, GameData.BS_EXTRA_STABS))
			var bs: = s


			if p.effects.has("lg_backstab") and id.begins_with("back_stab"):
				stabs = maxi(stabs, GameData.LG_BACKSTAB_EVOLVED if id.ends_with("_x") else GameData.LG_BACKSTAB_HITS + level)
				bs = s.duplicate()
				bs["lone_repeat"] = true



			if id == "back_stab_x":
				var luk: = float(p.eff_stat("luk"))
				var chance: = luk / (luk + GameData.BS_LUK_K)
				while randf() < chance:
					stabs += 1
					chance *= GameData.BS_LUK_FADE
			return world.blink_chain(p, bs, v.call("damage"), v.call("area") * sqrt(p.area_mult), stabs, v.call("range"))
		"aoe_self":
			return _aoe_self(world, p, s, v)
		"projectile":
			return _projectile(world, p, s, v)
		"radial":
			return _radial(world, p, s, v)
		"mirror":

			var want: = int(v.call("count")) + int(p.effects.get("mirror_extra", 0.0))
			if p.mirror_count() >= want:
				return false
			p.make_mirrors(world, want)
			world.play_skill_sound(s)
			return true
		"issen":
			return _issen(world, p, s, v)
		"aoe_target":
			return _aoe_target(world, p, s, v)
		"petal_rain":
			return _petal_rain(world, p, s, v)
		"huuma_storm":
			return _huuma_storm(world, p, s, v)
		"line":
			return _line(world, p, s, v)
		"bolt":
			return _bolt(world, p, s, v)
		"soul_strike":
			return _soul_strike(world, p, s, v)
		"falcon":
			return _falcon(world, p, s, v)
		"finger":
			return _finger(world, p, s, v)
		"asura":

			var reach: float = v.call("range") * p.area_mult
			if world.enemies_in_radius(p.position, reach).is_empty():
				return false
			world.asura_strike(p, reach, v.call("damage"), s)
			return true
		"steal":
			return _steal(world, p, s, v)
		"ice_trail":
			return _ice_trail(world, p, s, v)
		"ground":
			return _ground(world, p, s, v)
		"acid_terror":
			return _acid_terror(world, p, s, v)
		"signum":
			return _signum(world, p, s, v)
		"charge":
			return _charge(world, p, s, v)
		"boomerang":
			var going: = Vector3(p._last_stick.x, 0.0, p._last_stick.y)
			var aim: = going.normalized() if going.length() > 0.3 else Vector3.ZERO

			if p.effects.has("lg_gungnir"):
				var best: Enemy = null
				for e in world.enemies_in_radius(p.position, v.call("range") * GameData.GUNGNIR_SEEK):
					if not e.dead and e.prop == "" and (best == null or e.max_hp > best.max_hp):
						best = e
				if best != null:
					aim = ((best.position - p.position) * Vector3(1, 0, 1)).normalized()

					p.set_meta("gungnir_reach", maxf(2.5, ((best.position - p.position) * Vector3(1, 0, 1)).length()))
			if aim == Vector3.ZERO:
				var near: = world.nearest_enemy(p.position, v.call("range"))
				if near == null:
					return false
				aim = ((near.position - p.position) * Vector3(1, 0, 1)).normalized()
			var n: = maxi(1, int(v.call("count")))
			for i in n:
				var a: = (i - (n - 1) * 0.5) * 0.35
				world.spear_boomerang(p, aim.rotated(Vector3.UP, a), minf(v.call("range"), float(p.get_meta("gungnir_reach", 999.0))), v.call("width") * sqrt(p.area_mult), v.call("damage"), s, i == n / 2)
			if p.has_meta("gungnir_reach"):
				p.remove_meta("gungnir_reach")
			p.play_attack(aim)
			world.play_skill_sound(s)
			return true
		"sightrasher":
			var reach: float = v.call("range") * p.area_mult
			if world.enemies_in_radius(p.position, reach).is_empty():
				return false
			world.sightrasher(p, reach, v.call("damage"), s, int(s.get("waves", 1.0)))
			world.play_skill_sound(s)
			return true
		"gravity":

			var near: = world.nearest_enemies(p.position, v.call("range"), 14)
			if near.is_empty():
				return false
			var best: Enemy = near[0]
			var most: = -1
			for e in near:
				var c: = world.enemies_in_radius(e.position, 2.5).size()
				if c > most:
					most = c
					best = e
			world.gravitation(p, best.position, v.call("area") * sqrt(p.area_mult), v.call("damage"), v.call("duration"), s)
			world.play_skill_sound(s)
			return true
		"kunai_boom":
			var stuck: = world.enemies_in_radius(p.position, v.call("range")).filter( func(e): return not e.dead and e.kunai_stuck > 0 and e.kunai_until > world.time)
			var total: = 0
			for e in stuck:
				total += e.kunai_stuck
			if total < int(s.get("min_kunai", 3.0)):
				return false
			world.kunai_explosion(p, stuck, v.call("damage") * (1.0 + float(p.effects.get("kunai_dmg", 0.0))), float(s.get("splash", 0.0)) * sqrt(p.area_mult), s)
			world.play_skill_sound(s)
			return true
		"kaihou":
			if p.charms.size() < GameData.CHARM_MAX or world.enemies_in_radius(p.position, v.call("range") * 1.5).is_empty():
				return false
			world.kaihou(p, v.call("damage"), v.call("range") * p.area_mult, s)
			return true
		"axe_tornado":


			var heat: = p.forge_temp()
			var reach: float = v.call("range") * p.area_mult * (1.0 + float(s.get("forge_area", 0.0)) * p.forge_refine()) * (1.0 + GameData.AT_HEAT_AREA * heat)
			if world.enemies_in_radius(p.position, reach).is_empty():
				return false
			world.axe_tornado(p, reach, v.call("damage"), int(v.call("hits")), s, heat)
			world.play_skill_sound(s)
			return true
		"cart_cannon":

			var foes: = world.enemies_in_radius(p.position, v.call("range")).filter( func(e): return not e.dead and e.prop == "")
			if foes.is_empty():
				return false
			foes.sort_custom( func(a, b): return rank(world, a) > rank(world, b))
			var blast: float = v.call("area") * sqrt(p.area_mult) * (1.0 + float(s.get("forge_area", 0.0)) * p.forge_refine())
			for i in mini(foes.size(), maxi(1, int(v.call("count")))):
				world.cart_cannon(p, foes[i], v.call("damage"), blast, s, i * 0.14)
			world.play_skill_sound(s)
			return true
		"drill":
			var foes: = world.enemies_in_radius(p.position, v.call("range")).filter( func(e): return not e.dead and e.prop == "")
			if foes.is_empty():
				return false
			foes.sort_custom( func(a, b): return rank(world, a) > rank(world, b))
			world.spiral_drill(p, foes[0], v.call("damage"), int(v.call("hits")), s)

			if p.effects.has("lg_gungnir"):
				world.gungnir_strike(p, foes[0].position, v.call("damage"), s, true, "gungnir", world.damage_tag)
			world.play_skill_sound(s)
			return true
		"jupitel":

			var foes: = world.enemies_in_radius(p.position, v.call("range")).filter( func(e): return not e.dead and e.prop == "")
			if foes.is_empty():
				return false
			foes.sort_custom( func(a, b): return a.position.distance_squared_to(p.position) < b.position.distance_squared_to(p.position))
			var n: = mini(foes.size(), maxi(1, int(v.call("count"))))
			for i in n:
				world.jupitel(p, foes[i], v.call("damage"), int(v.call("hits")), s, 0.06 * i)
			p.play_attack((foes[0].position - p.position) * Vector3(1, 0, 1), true)
			world.play_skill_sound(s)
			return true
		"lex":


			var near: = world.enemies_in_radius(p.position, v.call("range")).filter( func(e): return not e.dead and e.prop == "" and e.lex_until <= world.time)
			if near.is_empty():
				return false
			near.sort_custom( func(a, b): return rank(world, a) > rank(world, b))
			world.lex_aeterna(p, near.slice(0, maxi(1, int(v.call("count")))), v.call("mult"), v.call("duration"))
			world.play_skill_sound(s)
			return true
		"fury":

			if p.powers.has("critical_explosion") or world.nearest_enemy(p.position, 8.0) == null:
				return false
			p.fury_crit = v.call("crit") * p.buff_boost_dmg()
			p.fury_crit_dmg = v.call("crit_dmg") * p.buff_boost_dmg()
			p.fury_chain = v.call("ki_chain")
			p.add_power("critical_explosion", v.call("duration"))
			p.recompute()
			world.critical_explosion(p, s)
			return true
		"steel_body":

			if p.powers.has("steel_body") or world.nearest_enemy(p.position, 6.0) == null:
				return false
			p.steel_guard = v.call("guard") * p.buff_boost()
			p.steel_proc = v.call("proc_power") * p.buff_boost()
			p.add_power("steel_body", v.call("duration"))
			world.spawn_fx("maximizepower", p.position, 1.0, 1.0, p)
			Vfx.column(world.fx_root, p.position, s.color)
			world.number(p.position + Vector3(0, 2.4, 0), "Steel Body", Color(0.75, 0.82, 0.95), true)
			world.play_skill_sound(s)
			return true
		"taunt":
			var reach: float = v.call("range") * p.area_mult
			var near: = world.enemies_in_radius(p.position, reach)
			if near.is_empty():
				return false
			var time: float = v.call("duration")
			p.provoke = {"range": reach, "time": time, "vuln": float(s.get("vuln", 0.0)), "pulse": float(s.get("pulse", 0.0)), "t": float(s.get("pulse", 0.0))}
			for e in near:
				Skills.taunt(world, p, e)
				world.damage_enemy(e, v.call("damage"), Vector3.ZERO, "skill", element_of(p, s))
			p.add_power("provoke_x" if s.get("evolved", false) else "provoke", time)
			world.number(p.position + Vector3(0, 2.4, 0), TranslationServer.translate(str(s.name)), s.color, true)
			Vfx.ring(world.fx_root, p.position, reach, Color(s.color, 0.8), 0.45)
			Vfx.burst(world.fx_root, p.position, minf(reach, 5.0), s.color)
			p.play_attack(p.facing, false)
			world.play_skill_sound(s)
			return true
		"gospel":
			if p.powers.has("gospel") or world.nearest_enemy(p.position, v.call("range")) == null:
				return false
			p.gospel = {"dmg": v.call("damage"), "range": v.call("range") * p.area_mult, "every": float(s.every), "t": 0.3}
			p.add_power("gospel", v.call("duration"))
			world.number(p.position + Vector3(0, 2.4, 0), "Gospel", s.color, true)
			world.spawn_fx("magnus", p.position, 1.2, 0.7)
			world.play_skill_sound(s)
			return true
		"sacrifice":
			if p.powers.has("martyr") or world.nearest_enemy(p.position, 4.0) == null or p.hp < p.max_hp * 0.25:
				return false
			p.hp -= p.hp * float(s.hp_cost)
			p.martyr_pct = (v.call("hp_dmg") + p.armor * float(s.get("tank_def_pct", 0.0))) * p.buff_boost_dmg()
			p.add_power("martyr", v.call("duration"))
			world.spawn_fx("red_cross", p.position, 0.8, 0.9, p)
			world.number(p.position + Vector3(0, 2.4, 0), "Martyr's Reckoning", s.color, true)
			world.play_skill_sound(s)
			return true
		"orbit":


			var f: = _huuma_form(p, s)
			var os: = s
			if not f.is_empty():

				os = s.duplicate()
				os["sprite"] = "item_huuma"
				os["sprite_px"] = float(f.px)
				os["orbit_speed"] = float(s.orbit_speed) * float(f.speed)
			world.orbit_skill(p, os, v.call("range") * p.area_mult * float(f.get("range", 1.0)), v.call("damage") * float(f.get("dmg", 1.0)), 
				maxi(1, ceili(int(v.call("count")) * float(f.get("count", 1.0)))), 
				s.cooldown + 0.4, minf(pow(p.area_mult, GameData.ORBIT_SIZE_POW), GameData.ORBIT_SIZE_MAX))
			world.play_skill_sound(s)
			return true
		"passive":

			if s.get("falcon_passive", false):
				return _falcon(world, p, s, v)

			return false
		"falcon_assault":

			var near: = world.enemies_in_radius(p.position, v.call("range")).filter( func(e): return not e.dead and e.prop == "")
			if near.is_empty():
				return false
			near.sort_custom( func(a, b): return rank(world, a) > rank(world, b))
			world.falcon_strike(p, near.slice(0, maxi(1, int(v.call("count")))), v.call("damage"), v.call("area") * sqrt(p.area_mult), s)
			return true
		"buff":


			if s.get("forge_vent", false) and p.forge_on() and not World.Forge.vent(world, p):
				return false


			if s.has("fx"):
				world.spawn_fx(s.fx, p.position, 1.0, 1.0, p)
			elif s.has("tex_fx"):
				world.rising_tex(p, str(s.tex_fx), int(s.get("tex_count", 1)))
			elif s.has("spr_fx"):
				world.sprite_fx(str(s.spr_fx), p.position, 0, float(s.get("spr_size", 1.0)), p)
			elif not s.has("cloak"):
				Vfx.column(world.fx_root, p.position, s.color)
			if s.has("cloak"):
				world.cloak(p, float(s.cloak))
			elif s.has("ring_fx"):
				Vfx.ring(world.fx_root, p.position, 1.8, s.color, 0.5)

			if not s.get("song", false):
				_party_buff(world, p, id, level, s)
			world.play_skill_sound(s)
			return true
		"heat":


			return false
		"shield":



			var amount: float = (v.call("amount") + p.max_hp * float(s.get("amount_hp", 0.0))) * p.support_mult
			if id.begins_with("kaite"):
				amount *= 1.0 + float(p.effects.get("kaite_power", 0.0))
				Vfx.magic_circle(world.fx_root, p.position, 2.4, Color(s.color, 0.8), 0.9, "mvp_hexa", -1.5)
				Vfx.ring(world.fx_root, p.position, 3.0, s.color, 0.4)

			var to: = _neediest(world, p, id in GameData.PARTY_SHIELD_SKILLS and not str(world.damage_tag).begins_with("proc:"), func(h): return h.shield / maxf(1.0, amount))


			amount *= to.vit_shield_mult()
			if to.shield > amount * 0.5:
				return false
			to.shield = maxf(to.shield, amount)
			to.shield_peak = maxf(to.shield, amount)
			to.shield_src = id
			if id.begins_with("kaite"):
				World.SoulLinker.kaite_cast(to, p)
			world.doram.sea_wave(world, p, to.position, amount)
			if s.has("fx"):
				world.spawn_fx(s.fx, to.position, float(s.get("fx_size", 1.0)), 1.0, to)
			elif s.has("tex_fx"):
				world.rising_tex(to, str(s.tex_fx), int(s.get("tex_count", 1)))
			elif s.has("spr_fx"):

				world.sprite_fx(str(s.spr_fx), to.position, 0, 1.0, to)
			if s.has("ring_fx"):
				Vfx.ring(world.fx_root, to.position, 1.8, s.color, 0.5)
			world.play_skill_sound(s)
			return true
		"heal":


			var to: = _neediest(world, p, id in GameData.PARTY_HEAL_SKILLS and not str(world.damage_tag).begins_with("proc:"), func(h): return h.hp / maxf(1.0, h.max_hp))


			var smite: bool = p.effects.has("lg_heal") and id == "heal"\
			and world.nearest_enemy(p.position, GameData.LG_HEAL_RADIUS * p.area_mult) != null


			var bandage: = 0.0
			if s.has("shield_hp"):
				bandage = p.max_hp * minf(v.call("shield_hp") * p.support_mult, GameData.FIRST_AID_SHIELD_MAX) * p.vit_shield_mult()


			var wrap: = bandage > 0.0 and p.shield < bandage * 0.5 and p.shield_x().is_empty()
			if to.hp >= to.max_hp - 1.0 and not smite and not wrap:
				return false
			if wrap:
				p.shield = maxf(p.shield, bandage)
				p.shield_peak = maxf(p.shield, bandage)
				p.shield_src = id
			if smite:

				var held: = p.proc_bake if str(world.damage_tag).begins_with("proc:") else 1.0
				_holy_burst(world, p, v.call("amount") * (1.0 + float(p.effects.get("heal_power", 0.0))) * p.support_mult * GameData.LG_HEAL_DMG * held)



			var amount: float = v.call("amount")
			var healed: float = (amount + to.max_hp * amount * GameData.HEAL_HP_PCT) * (1.0 + float(p.effects.get("heal_power", 0.0))) * p.support_mult
			to.heal(healed, world, true, id, p)

			world.doram.sea_wave(world, p, to.position, healed)

			if id in GameData.PARTY_HEAL_SKILLS:
				world.label_over(p, TranslationServer.translate("%s !!") % TranslationServer.translate(str(s.name)), Color(1.0, 0.97, 0.85))
			if s.has("fx"):
				world.spawn_fx(s.fx, to.position, 1.0, 1.0, to)
			else:

				Vfx.heal_light(world.fx_root, to.position, s.color)
			world.play_skill_sound(s)
			return true
		"doram":
			return world.doram.cast(world, p, s, v)
		"summon":
			if world.nearest_enemy(p.position, v.call("range") + 3.0) == null:
				return false


			world.summons.plant(world, p, s, level, int(v.call("count")), v.call("damage") * (1.0 + float(p.effects.get("homun_power", 0.0))), v.call("range"), v.call("duration"))
			world.play_skill_sound(s)
			return true
	return false


static func _melee_arc(world: World, p: Player, s: Dictionary, v: Callable) -> bool:



	var reach: float = v.call("range") * p.area_mult + 0.8
	var target: = world.nearest_enemy(p.position, reach + 0.3)
	if target == null:


		if s.has("wave_range"):
			return _melee_wave(world, p, s, v)
		return false
	var dir: = (target.position - p.position) * Vector3(1, 0, 1)
	dir = dir.normalized() if dir.length_squared() > 0.0 else p.facing
	var half_arc: = deg_to_rad(s.arc) * 0.5
	var hit: = false
	var dmg: float = v.call("damage") * _zeny_mult(world, p, s, v)
	var slashes: = 0
	var bursts: = 0
	var struck: Array[Vector3] = []
	var in_arc: Array[Enemy] = []
	for e in world.enemies_in_radius(p.position, reach):
		var to: = (e.position - p.position) * Vector3(1, 0, 1)
		if to.length() < 0.6 or absf(dir.signed_angle_to(to, Vector3.UP)) <= half_arc:
			in_arc.append(e)

	var bowl: bool = s.get("bowl", false)
	var packed: = _bowl_packed(in_arc) if bowl else {}
	for e in in_arc:
		var to: = (e.position - p.position) * Vector3(1, 0, 1)

		if s.has("poison_burst") and e.poison_time > 0.0:
			world.poison_burst(e, float(s.poison_burst) * p.proc_stack, bursts < 5)
			bursts += 1
		if e.dead:
			continue
		world.damage_enemy(e, dmg, to.normalized() * s.knock, "skill", s.get("element", "neutral"))
		if bowl and packed.has(e) and not e.dead:
			world.damage_enemy(e, dmg, Vector3.ZERO, "skill", s.get("element", "neutral"))
		world.try_status(e, s, v.call("status_chance"))
		if s.has("poison"):
			world.apply_poison(e, dmg * GameData.POISON_DPS, v.call("poison"), int(p.proc_stack))

		if s.has("hit_sprite") and slashes < 3:
			slashes += 1
			world.sprite_fx(str(s.hit_sprite), e.position + Vector3(0, 0.8, 0), 0, 0.9)
		if struck.size() < 4:
			struck.append(e.position)
		hit = true
	if bursts > 0:
		world.play_sound("venom_dust", 0.15, -6.0)
	if bowl and hit:
		_bowl_chain(world, p, s, in_arc, dmg)

	if hit and s.get("coin_rain", false):
		world.coin_rain(target.position if target != null else p.position + dir * 1.5, reach)


	if hit and s.get("bash_fx", false):
		var big: bool = s.get("evolved", false)
		Vfx.arc(world.fx_root, p.position, dir, reach, deg_to_rad(s.arc), Color(1.0, 0.85, 0.45, 0.8))

		if world.time >= float(p.get_meta("bash_flash", -9.0)):
			p.set_meta("bash_flash", world.time + 0.9)
			Vfx.ray_flash(world.fx_root, target.position + Vector3(0, 0.9, 0), world.camera.global_basis, Color(1.0, 0.95, 0.8))
		world.spawn_fx("hit", target.position + Vector3(0, 0.7, 0), 1.6 if big else 1.2, 1.0)
		world.shake(0.16 if big else 0.09)


	if s.get("venom_fx", false) and hit and world.time >= float(p.get_meta("venom_fx", -9.0)):
		var big: bool = s.get("evolved", false)
		p.set_meta("venom_fx", world.time + 0.3)
		Vfx.arc(world.fx_root, p.position, dir, reach, deg_to_rad(s.arc), Color(0.45, 0.72, 0.4, 0.22))
		for at in struck.slice(0, 2):
			world.spawn_fx("invenom", at + Vector3(0, 0.7, 0), 0.55, 0.35)
		if world.time >= float(p.get_meta("venom_cloud", -9.0)):
			p.set_meta("venom_cloud", world.time + (0.9 if big else 1.4))
			world.spawn_fx("venomdust", struck[0], 1.1 if big else 0.8, 0.5)


	p.play_attack(dir)
	if s.has("fx"):


		world.spawn_fx(s.fx, p.position + dir * reach * 0.4 + Vector3(0, float(s.get("fx_y", 0.0)), 0), 
			s.get("fx_size", 1.0) * p.area_mult, s.get("fx_intensity", 1.0))
	world.play_skill_sound(s)
	if hit and s.has("hit_sound"):
		world.play_sound(s.hit_sound, 0.12, -6.0)
	return true




static func _bowl_packed(list: Array[Enemy]) -> Dictionary:
	var out: = {}
	var n: = mini(list.size(), 60)
	for i in n:
		var a: = list[i]
		for j in range(i + 1, n):
			var b: = list[j]
			var gap: float = a.radius + b.radius + GameData.BOWL_CLUMP_GAP
			var d: Vector3 = (a.position - b.position) * Vector3(1, 0, 1)
			if d.length_squared() < gap * gap:
				out[a] = true
				out[b] = true
	return out




static func _bowl_chain(world: World, p: Player, s: Dictionary, sources: Array[Enemy], dmg: float) -> void :
	var length: = GameData.BOWL_CHAIN_LEN * sqrt(p.area_mult)
	var element: String = s.get("element", "neutral")
	var done: = {}
	for e in sources:
		done[e] = true
	var wave: Array = []
	for e in sources.slice(0, GameData.BOWL_CHAIN_SOURCES):
		if not is_instance_valid(e):
			continue
		var d: Vector3 = (e.position - p.position) * Vector3(1, 0, 1)
		if d.length_squared() > 0.01:
			wave.append([e.position, d.normalized()])
	var hits: = 0
	for step in (2 if s.get("evolved", false) else 1):
		var next: Array = []
		for w in wave:
			var from: Vector3 = w[0]
			var way: Vector3 = w[1]
			for o in world.enemies_in_radius(from + way * length * 0.5, length * 0.5 + 1.0):
				if done.has(o) or not is_instance_valid(o) or o.dead:
					continue
				var to: Vector3 = (o.position - from) * Vector3(1, 0, 1)
				var along: = to.dot(way)
				if along < 0.0 or along > length or (to - way * along).length() > o.radius + 0.7:
					continue
				done[o] = true
				world.damage_enemy(o, dmg * GameData.BOWL_CHAIN_SHARE, way * float(s.knock) * 0.5, "skill", element)
				if hits < 6:
					world.spawn_fx("hit", o.position + Vector3(0, 0.7, 0), 0.8, 0.8)
				hits += 1
				next.append([o.position, way])
				if hits >= GameData.BOWL_CHAIN_MAX:
					return
		wave = next




static func _melee_wave(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var far: = world.nearest_enemy(p.position, float(s.wave_range) * sqrt(p.area_mult))
	if far == null:
		return false
	var dir: = ((far.position - p.position) * Vector3(1, 0, 1)).normalized()
	var length: = p.position.distance_to(far.position) + 1.0
	var half_w: = 1.3 * sqrt(p.area_mult)
	var dmg: float = v.call("damage") * _zeny_mult(world, p, s, v)
	for e in world.enemies_in_radius(p.position, length + half_w):
		var to: = (e.position - p.position) * Vector3(1, 0, 1)
		var along: = to.dot(dir)
		if along < -0.5 or along > length or (to - dir * along).length() > half_w:
			continue
		world.damage_enemy(e, dmg, dir * s.knock, "skill", s.get("element", "neutral"))
		world.try_status(e, s, v.call("status_chance"))
	p.play_attack(dir)
	if s.has("fx"):
		var steps: = maxi(2, int(length / 2.5))
		for i in steps:
			var at: = p.position + dir * (length * (i + 1) / float(steps))
			var delay: = 0.05 * i
			if delay <= 0.0:
				world.spawn_fx(s.fx, at, s.get("fx_size", 1.0) * p.area_mult, s.get("fx_intensity", 1.0))
			else:
				world._own_timer(delay, func():
					world.spawn_fx(s.fx, at, s.get("fx_size", 1.0) * p.area_mult, s.get("fx_intensity", 1.0)))
	world.play_skill_sound(s)
	return true





static func _zeny_mult(world: World, p: Player, s: Dictionary, v: Callable) -> float:
	var mult: = 1.0


	var golden: bool = p.effects.has("lg_mammon") and str(s.name).begins_with("Mammonite")
	if golden:
		mult = (1.0 + minf(GameData.GOLDEN_AXE_RUN_MAX, world.zeny_of(p) / GameData.CART_ZENY_STEP)) * GameData.bank_mult(p.bank_zeny())
	elif s.has("zeny_cost"):
		var cost: = roundi(v.call("zeny_cost") * maxf(0.0, 1.0 - float(p.effects.get("zeny_discount", 0.0))))
		if not world.spend_run_zeny(cost):
			mult = GameData.MAMMONITE_BROKE
			world.broke_notice(p, str(s.name))
	if s.get("zeny_power", false):
		mult *= 1.0 + minf(GameData.CART_ZENY_MAX, world.zeny_of(p) / GameData.CART_ZENY_STEP)


	if s.get("bank_power", false):
		mult *= GameData.bank_mult(p.bank_zeny())
	return mult







static func _meteor_assault(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range") * p.area_mult
	if world.enemies_in_radius(p.position, reach).is_empty():
		return false
	var dmg: float = v.call("damage")
	var stun: float = v.call("status_chance")
	var blind: float = v.call("blind_chance")
	var tag: = world.damage_tag
	var by: = world.damage_by
	var col: Color = s.color
	p.play_attack(p.facing)


	col = _meteor_tone(col)
	Vfx.magic_circle(world.fx_root, p.position, reach * 0.5, Color(0.6, 0.85, 0.9, 0.35), GameData.METEOR_WINDUP + 0.3, "mvp_hexa", 2.4)
	Vfx.converge(world.fx_root, p.position + Vector3(0, 0.05, 0), reach, Color(col, 0.3), GameData.METEOR_WINDUP)
	world.spawn_fx("maximizepower", p.position, 0.7, 0.8, p)
	world._own_timer(GameData.METEOR_WINDUP, func():
		if not world.running or not world.hero_valid(p):
			return
		world.damage_tag = tag
		world.damage_by = by
		var at: = p.position
		var hits: = world.enemies_in_radius(at, reach)



		var bleeding: Array = []
		for e in hits:
			if not e.dead and e.blood_stacks > 0:
				bleeding.append(e)
		var burst: = bleeding.size()
		if burst > 0:
			world.dots.burst_many(world, bleeding)
		for e in hits:
			if e.dead:
				continue
			var away: = ((e.position - at) * Vector3(1, 0, 1))
			away = away.normalized() if away.length_squared() > 0.0001 else p.facing
			world.damage_enemy(e, dmg, away * float(s.knock), "skill", p.basic_element())
			if not e.dead:
				world.try_status(e, s, stun)
				if randf() < blind + float(p.effects.get("status_chance", 0.0)):
					world.blind_enemy(e, float(s.blind_time) * p.duration_mult)
		world.damage_tag = tag
		world.damage_by = by
		_meteor_look(world, at, reach, col, hits.slice(0, 6))
		world.play_skill_sound(s)
		if burst > 0:
			world.play_sound("bleed_burst", 0.1, -4.0)
		world.shake(0.25)


		if s.has("aftershock"):
			world._own_timer(float(s.aftershock), func():
				if not world.running or not world.hero_valid(p):
					return
				world.damage_tag = tag
				world.damage_by = by
				var at2: = p.position
				var reach2: = reach * float(s.get("aftershock_range", 1.5))
				var struck2: = world.enemies_in_radius(at2, reach2)
				var bled: Array = []
				for e in struck2:
					if e.dead:
						continue
					var away: = ((e.position - at2) * Vector3(1, 0, 1))
					away = away.normalized() if away.length_squared() > 0.0001 else p.facing
					world.damage_enemy(e, dmg * float(s.get("aftershock_dmg", 0.7)), away * float(s.knock), "skill", p.basic_element())
					if not e.dead and e.blood_stacks > 0:
						bled.append(e)

				var bursts: = bled.size()
				if bursts > 0:
					world.dots.burst_many(world, bled)
				world.damage_tag = tag
				world.damage_by = by
				_aftershock_look(world, at2, reach2, col)
				world.play_sound("magnum", 0.0, -2.0, 0.8)
				if bursts > 0:
					world.play_sound("bleed_burst", 0.1, -2.0)
				world.shake(0.35)))
	return true




static func _aftershock_look(world: World, at: Vector3, reach: float, col: Color) -> void :


	var ground: = at + Vector3(0, 0.06, 0)
	_shockwave(world, ground, reach, Color(col.darkened(0.15), 0.3), 0.45)
	Vfx.ring(world.fx_root, ground, reach, Color(col.lightened(0.2), 0.4), 0.4)
	_meteor_cracks(world, ground, reach * 0.9, Color(0.25, 0.08, 0.25, 0.22))
	if not Vfx._skip(1):
		var pillar: = Vfx.beam(world.fx_root, at, Color(col.darkened(0.1), 0.6), 2.6)
		var tw: = pillar.create_tween()
		tw.tween_property(pillar, "scale", Vector3(1.6, 1.0, 1.6), 0.3).set_ease(Tween.EASE_OUT)
		tw.tween_callback(pillar.queue_free)







static func _meteor_look(world: World, at: Vector3, reach: float, col: Color, struck: Array) -> void :
	var ground: = at + Vector3(0, 0.06, 0)
	_shockwave(world, ground, reach * 1.1, Color(col, 0.32), 0.36)
	Vfx.ring(world.fx_root, ground, reach, Color(col.lightened(0.25), 0.45), 0.35)
	Vfx.burst(world.fx_root, ground, reach * 0.3, Color(col, 0.35))
	_meteor_cracks(world, ground, reach * 0.8, Color(col.darkened(0.5), 0.22))
	Vfx.air_impact(world.fx_root, at + Vector3(0, 0.9, 0), Vector3.FORWARD, reach * 0.5)
	if not Vfx._skip(1):
		var pillar: = Vfx.beam(world.fx_root, at, Color(col.lightened(0.1), 0.65), 2.2)
		var tw: = pillar.create_tween()
		tw.tween_property(pillar, "scale", Vector3(1.6, 1.0, 1.6), 0.3).set_ease(Tween.EASE_OUT)
		tw.tween_callback(pillar.queue_free)
	for e in struck:
		if is_instance_valid(e):
			world.spawn_fx("hit", e.position + Vector3(0, 0.6, 0), 0.8, 0.9)




static func _meteor_tone(col: Color) -> Color:
	return col.lerp(Color(0.52, 0.3, 0.62), 0.45)






const METEOR_CRACK_MAX: = 4.0
const METEOR_CRACK_GAP_MS: = 1500
static var _crack_at: = -100000
static func _meteor_cracks(world: World, ground: Vector3, radius: float, col: Color) -> void :
	if Vfx._skip(1):
		return
	var now: = Time.get_ticks_msec()
	if now - _crack_at < METEOR_CRACK_GAP_MS:
		return
	_crack_at = now
	Vfx.quake(world.fx_root, ground, minf(radius, METEOR_CRACK_MAX), col)


static var _wave_tex: Texture2D




static func _shockwave(world: World, at: Vector3, radius: float, col: Color, life: float) -> void :
	if _wave_tex == null:
		var n: = 128
		var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
		for y in n:
			for x in n:
				var d: = Vector2(x + 0.5 - n * 0.5, y + 0.5 - n * 0.5).length() / (n * 0.5)

				var a: = 0.0
				if d < 1.0 and d > 0.5:
					a = pow(sin((d - 0.5) / 0.5 * PI), 1.2) * (0.6 + 0.4 * (d - 0.5) / 0.5)
				img.set_pixel(x, y, Color(1, 1, 1, a))
		_wave_tex = ImageTexture.create_from_image(img)
	var s: = Sprite3D.new()
	s.texture = _wave_tex
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 6
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	s.rotation_degrees.x = -90.0
	s.pixel_size = radius * 2.0 / 128.0
	s.modulate = Color(col, col.a * Vfx.dim)
	world.fx_root.add_child(s)
	s.global_position = at
	s.scale = Vector3.ONE * 0.25
	var tw: = s.create_tween()
	tw.tween_property(s, "scale", Vector3.ONE, life).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.parallel().tween_property(s, "modulate:a", 0.0, life).set_ease(Tween.EASE_IN)
	tw.tween_callback(s.queue_free)


static func _aoe_self(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range") * p.area_mult
	var hits: = world.enemies_in_radius(p.position, reach)
	if hits.is_empty():
		return false
	var dmg: float = v.call("damage")

	if s.has("speed_dmg"):
		dmg *= 1.0 + float(s.speed_dmg) * maxf(0.0, p.move_speed - 4.0)
	for e in hits:
		var to: = (e.position - p.position) * Vector3(1, 0, 1)
		world.damage_enemy(e, dmg, to.normalized() * s.knock, "skill", s.get("element", "neutral"))
		world.try_status(e, s, v.call("status_chance"))

		if s.has("blind_chance") and randf() < v.call("blind_chance"):
			world.blind_enemy(e, float(s.blind_time) * p.duration_mult, s.get("blind_boss", false))

	if s.has("stagger_fill"):
		World.Forge.slam(world, p, hits, v.call("stagger_fill"))
	if s.has("heal_amount"):
		p.heal(v.call("heal_amount"), world, false, world.skill_id_of(s))

	if s.get("grenades", false) and p.effects.has("lg_grenades"):
		world.destroyer_grenades(p, hits, dmg)
	p.play_attack(p.facing, s.get("magic", false))
	if s.has("spr_fx"):
		world.sprite_fx(str(s.spr_fx), p.position + Vector3(0, 0.5, 0), 0, float(s.get("spr_size", 0.9)))
		for e in hits.slice(0, 5):
			world.sprite_fx(str(s.get("hit_sprite", s.spr_fx)), e.position + Vector3(0, 0.6, 0), 0, 0.5)
	elif s.has("fx"):
		var e: = world.spawn_fx(s.fx, p.position, s.get("fx_size", reach / 6.0), s.get("fx_intensity", 1.0))

		if e != null:
			e._time = float(s.get("fx_lead", 0.0))
	else:
		Vfx.burst(world.fx_root, p.position, reach, s.color)
	if s.has("tex_fx"):

		for e in hits.slice(0, 4):
			world.rising_tex(e, str(s.tex_fx), 1)
	world.shake(0.15)
	world.play_skill_sound(s)
	return true


static func _projectile(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var count: = int(v.call("count"))


	var songs: = p.vulcan_songs() if s.has("crescendo") else 0
	count += songs
	var targets: = world.nearest_enemies(p.position, v.call("range"), 1 if s.get("same_target", false) else count)
	if targets.is_empty():
		return false

	var hunt: bool = s.get("hunt", false)
	if hunt:
		var prey: Enemy = world.doram.toughest(world, p.position, v.call("range"))
		if prey != null:
			targets = [prey]

	if str(s.get("cast_fx", "")) == "flash":
		world.archer_flash(p)
	if s.get("hitscan", false):
		var pierce: = int(v.call("pierce"))
		var sk: = s


		if p.effects.has("lg_ds") and str(s.get("cast_fx", "")) == "flash":
			pierce += GameData.LG_DS_BOUNCES
			sk = s.duplicate()
			sk["bounce_grow"] = GameData.LG_DS_GROW
			sk["self_bounce"] = true

		if s.get("pierce_line", false):
			for i in count:
				var t: Enemy = targets[i % targets.size()]
				world.pierce_shot(p, t, v.call("damage") * arrow_mult(p, s), element_of(p, s), sk, float(v.call("range")) + 2.0, 
					float(s.get("line_width", 1.3)), i * 0.12)
			p.play_attack(targets[0].position - p.position, s.get("magic", false))
			world.play_skill_sound(s)
			return true

		for i in count:
			var t: Enemy = targets[i % targets.size()]
			world.hitscan(p, t, v.call("damage") * arrow_mult(p, s), pierce, element_of(p, s), sk, 
				v.call("status_chance"), i * 0.07 if s.get("same_target", false) else 0.0)
		p.play_attack(targets[0].position - p.position, s.get("magic", false))
		world.play_skill_sound(s)
		return true

	var zeny: = _zeny_mult(world, p, s, v)
	for i in count:
		var t: Enemy = targets[i % targets.size()]
		var dir: = ((t.position - p.position) * Vector3(1, 0, 1)).normalized()
		if count > targets.size() and not hunt:
			var spread: = (i - (count - 1) / 2.0) * 0.12
			dir = dir.rotated(Vector3.UP, spread)
		var one: = _shot(p, s, v, dir, zeny, i * float(s.get("shot_gap", 0.08)) if s.get("same_target", false) else 0.0)


		if s.has("crescendo"):
			one.damage = float(one.damage) * (1.0 + float(s.crescendo) * i) * (1.0 + GameData.AV_SONG_DMG * songs)
			if i == count - 1:
				one.damage = float(one.damage) * float(s.get("finale", 1.0))
				one.splash = float(s.get("finale_area", 0.0)) * sqrt(p.area_mult)
				one["finale"] = true
		world.spawn_projectile(_huumafy(p, s, one))




	if p.effects.has("lg_mirror") and s.get("thrown", false):
		var k: = 0
		for m in p.mirror_nodes():
			var t: Enemy = targets[k % targets.size()]
			var from: Vector3 = m.global_position * Vector3(1, 0, 1) + Vector3(0, p.position.y, 0)
			var dir: = ((t.position - from) * Vector3(1, 0, 1)).normalized()
			var shot: = _shot(p, s, v, dir, zeny * GameData.LG_MIRROR_DMG * count, 0.04 + k * 0.05)
			shot.pos = from + Player.BOW_MUZZLE_UP

			shot["merge_splash"] = true
			world.spawn_projectile(shot)
			k += 1
	p.play_attack(targets[0].position - p.position, s.get("magic", false))
	world.play_skill_sound(s)
	return true





static func id_is_sharp(s: Dictionary) -> bool:
	return str(s.name).begins_with("Sharp Shooting")


static func _line(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var target: = world.nearest_enemy(p.position, v.call("range"))
	if target == null:
		return false
	var dir: = ((target.position - p.position) * Vector3(1, 0, 1)).normalized()
	var width: float = float(s.width) * p.area_mult
	var dmg: float = v.call("damage") * arrow_mult(p, s)

	var length: float = v.call("length") if s.has("length") else v.call("range")

	if id_is_sharp(s):
		length = minf(GameData.SHARP_LENGTH_MAX, length * p.area_mult)

	var blast: float = p.kaiser_blast if str(s.get("line_fx", "")) == "investigate" else 0.0
	for i in int(v.call("count")):
		var aim: = dir.rotated(Vector3.UP, (i - (int(v.call("count")) - 1) / 2.0) * 0.08)
		world.line_shot(p, target, aim, length, width, dmg, element_of(p, s), s, i * 0.12, blast)

	if id_is_sharp(s):
		world.detonate_traps(p, p.position, dir, length, width)

		if p.effects.has("lg_falken"):
			for side in [-1.0, 1.0]:
				var aim: = dir.rotated(Vector3.UP, side * GameData.LG_FALKEN_ANGLE)
				world.line_shot(p, target, aim, length, width, dmg * GameData.LG_FALKEN_SIDE, element_of(p, s), s, 0.06, blast)
				world.detonate_traps(p, p.position, aim, length, width)
	p.play_attack(target.position - p.position)
	world.play_skill_sound(s)
	return true



static func _radial(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var target: = world.nearest_enemy(p.position, v.call("range"))
	if target == null:
		return false
	var count: = maxi(1, ceili(int(v.call("count")) * float(_huuma_form(p, s).get("count", 1.0))))
	var first: = ((target.position - p.position) * Vector3(1, 0, 1)).normalized()
	for i in count:
		var shot: = _huumafy(p, s, _shot(p, s, v, first.rotated(Vector3.UP, TAU * i / count), 1.0, 0.0))

		shot["max_life"] = v.call("range") / maxf(1.0, float(shot.speed))
		world.spawn_projectile(shot)
	p.play_attack(first)
	world.play_skill_sound(s)
	return true



static func _shot(p: Player, s: Dictionary, v: Callable, dir: Vector3, mult: float, delay: float) -> Dictionary:
	return {
			"pos": p.position + Player.BOW_MUZZLE_UP + dir * Player.BOW_MUZZLE_AHEAD, 
			"dir": dir, 
			"speed": v.call("speed") * p.proj_mult, 
			"damage": v.call("damage") * mult * arrow_mult(p, s) * (p.shield_mult(float(s.shield_scale)) if s.has("shield_scale") else 1.0), 

			"pierce": int(v.call("pierce")) if s.get("boomerang", false) else 0, 
			"bounces": 0 if s.get("boomerang", false) else int(v.call("pierce")), 
			"size": s.size * sqrt(p.area_mult), 
			"boomerang": s.get("boomerang", false), 
			"spin": float(s.get("spin", 0.0)), 
			"range": v.call("range"), 
			"color": s.color, 
			"slow": s.get("slow", 0.0), 
			"knock": s.get("knock", 1.0), 
			"arrow": s.get("arrow", false), 
			"streak": s.get("streak", Color(0, 0, 0, 0)), 
			"delay": delay, 
			"splash": float(s.get("splash", 0.0)), 
			"sprite_scale": float(s.get("sprite_scale", 1.0)), 
			"glow": s.get("spin_glow", not s.get("thrown", false)), 
			"blend": s.get("proj_blend", "add"), 
			"hit_fx": s.get("hit_fx", ""), 
			"hit_fx_intensity": s.get("hit_fx_intensity", 1.0), 
			"hit_sound": s.get("hit_sound", ""), 
			"hit_sounds": s.get("hit_sounds", []), 
			"tex": s.get("proj_tex", ""), 
			"image": s.get("proj_image", ""), 
			"trail_tint": s.get("trail_tint", Color(0.8, 0.9, 1.3)), 
			"impact": float(s.get("impact", 0.0)), 
			"sprite": _proj_sprite(p, s), 
			"frames": int(s.get("proj_frames", 0)), 
			"tex_scale": float(s.get("proj_scale", 1.0)), 
			"element": element_of(p, s), 
			"status": s.get("status", ""), 
			"status_chance": v.call("status_chance"), 
			"status_time": s.get("status_time", 2.0), 
		}




static func _finger(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	if p.spheres <= 0:
		return false
	var target: = world.nearest_enemy(p.position, v.call("range"))
	if target == null:
		return false
	var n: = p.take_spheres(99)
	var shot: = s.duplicate()
	shot["same_target"] = true
	var count_v: = func(field: String) -> float: return float(n) if field == "count" else v.call(field)
	return _projectile(world, p, shot, count_v)



static func _trap_sk(id: String, level: int) -> Dictionary:
	var sk: Dictionary = GameData.SKILLS[id].duplicate()
	sk["snare"] = GameData.skill_value(id, "snare", level)
	sk["catch"] = GameData.skill_value(id, "catch", level)
	return sk



static func _huuma_form(p: Player, s: Dictionary) -> Dictionary:
	return s.get("huuma_form", {}) if p.huuma_on() else {}



static func _huumafy(p: Player, s: Dictionary, shot: Dictionary) -> Dictionary:
	var f: = _huuma_form(p, s)
	if f.is_empty():
		return shot
	shot.damage *= float(f.dmg)
	shot.size *= float(f.get("size", 1.0))
	shot.splash *= float(f.get("splash", 1.0))
	shot.sprite = "item_huuma"
	shot.sprite_scale = float(f.get("scale", shot.sprite_scale))
	shot.element = p.huuma_element()
	if f.has("pierce"):
		shot.pierce = int(f.pierce)
		shot.bounces = 0
	return shot



static func _thickest(world: World, p: Player, reach: float, area: float) -> Vector3:
	var center: = Vector3.INF
	var most: = -1
	for e in world.nearest_enemies(p.position, reach, 14):
		var c: = world.enemies_in_radius(e.position, area).size()
		if c > most:
			most = c
			center = e.position
	return center



static func _huuma_storm(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var area: float = v.call("area") * sqrt(p.area_mult)
	var center: = _thickest(world, p, v.call("range"), area)
	if center == Vector3.INF:
		return false
	var f: = _huuma_form(p, s)
	var sk: = s
	if not f.is_empty():
		sk = s.duplicate()
		sk["element"] = p.huuma_element()
	var hit: = float(s.hit_area) * sqrt(p.area_mult)
	var dmg: float = v.call("damage") * float(f.get("dmg", 1.0))
	for i in ceili(int(v.call("count")) * float(f.get("count", 1.0))):
		var spot: = center + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * area * 0.8
		world.huuma_fall(spot, i * 0.09)
		world.delayed_aoe(spot, hit, dmg, GameData.HUUMA_FALL + i * 0.09, sk, i == 0)
	p.play_attack(center - p.position, true)
	return true



static func flair(world: World, p: Player, id: String) -> void :
	var s: Dictionary = GameData.SKILLS[id]
	var f: Dictionary = s.get("flair", {})
	if f.is_empty():
		return
	var col: Color = s.color
	if f.has("ring"):
		Vfx.ring(world.fx_root, p.position, float(f.ring) * sqrt(p.area_mult), col.lightened(0.3), 0.4)
	if f.has("rays"):
		Vfx.ray_flash(world.fx_root, p.position + Vector3(0, 1.0, 0), world.camera.global_basis, col, float(f.rays))
	if f.has("column"):
		Vfx.column(world.fx_root, p.position, col)
	world.shake(float(f.get("shake", 0.0)))



static func _petal_rain(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var area: float = v.call("area") * p.area_mult
	var center: = _thickest(world, p, v.call("range"), area)
	if center == Vector3.INF:
		return false
	var hit: = float(s.hit_area) * sqrt(p.area_mult)
	for i in int(v.call("count")):
		var spot: = center + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * area * 0.7
		world.delayed_aoe(spot, hit, v.call("damage"), 0.15 + i * 0.05, s, i == 0)
	world.ground_zone(center, s, area, v.call("damage") * 0.5, 0.0, v.call("duration"))
	p.play_attack(center - p.position, true)
	return true






static func rank(world: World, e: Enemy) -> float:
	if e.has_meta("raid_guard") and not e.dead:
		return 3000000000.0 + e.hp
	if world.raid != null and world.raid.untouchable(e):
		return 0.0
	return (2.0 if e.is_boss else (1.0 if e.def.get("elite", false) else 0.0)) * 1000000000.0 + e.hp


static func _aoe_target(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var candidates: = world.enemies_in_radius(p.position, v.call("range"))
	if candidates.is_empty():
		return false
	candidates.shuffle()

	if s.has("mark"):
		candidates.sort_custom( func(a, b): return int(a.is_boss) > int(b.is_boss))

	if candidates.any( func(e): return e.has_meta("raid_guard") or world.raid.untouchable(e)):
		candidates.sort_custom( func(a, b): return rank(world, a) > rank(world, b))
	var area: float = v.call("area") * p.area_mult
	var sk: = s
	if s.has("snare"):

		sk = s.duplicate()
		sk["snare"] = v.call("snare")
		sk["catch"] = v.call("catch")
	if s.has("status"):

		sk = s.duplicate()
		sk["status_chance_now"] = v.call("status_chance")
	if s.get("kick_element", false):


		sk = sk.duplicate()
		sk["element"] = best_element(candidates) if p.effects.has("spirit_seek") else p.basic_element()

		if sk.element != "neutral":
			sk["color"] = GameData.ELEMENT_COLORS[sk.element]
	if s.has("elements"):
		sk = sk.duplicate()
		sk["element"] = element_of(p, s)

	if s.get("soul_spell", false):
		p.kick_landed(world)

	if s.get("magic", false) and not s.has("mark") and not s.has("trap") and not world.raid.active():
		candidates = spread(world, p, str(s.get("name", "")), candidates, int(v.call("count")), area)
	for i in mini(int(v.call("count")), candidates.size()):
		var at: Vector3 = candidates[i].position
		var delay: = 0.25 + i * 0.12


		if s.get("missile", false):
			soul_missile(world, p.position + Vector3(0, 1.2, 0), candidates[i], delay, 1.0 if i % 2 == 0 else -1.0, 
				Color(sk.color), Color(sk.color).lerp(Color(0.62, 0.5, 1.0), 0.65))
		elif s.get("gather", false):
			Vfx.converge(world.fx_root, at, area * 0.6, Color(Color(sk.color), 0.5), delay)
		if s.has("trap"):

			var to: = (at - p.position) * Vector3(1, 0, 1)
			var dist: = to.length()

			if dist > 2.0 and not candidates[i]._static:
				at = p.position + to / dist * maxf(1.5, dist * 0.55) + Vector3(randf_range(-0.6, 0.6), 0, randf_range(-0.6, 0.6))
			world.place_trap(at, area, v.call("damage"), sk)
		else:
			world.delayed_aoe(at, area, v.call("damage"), delay, sk, i == 0)
	if s.has("spr_fx"):

		var to: = candidates[0].position - p.position
		var dir8: = posmod(roundi(atan2( - to.x, to.z) / (PI / 4.0)), 8) if s.get("spr_dir", false) else 0
		world.sprite_fx(str(s.spr_fx), p.position + Vector3(0, 0.6, 0) + to.normalized() * 1.2, dir8, 0.9)
	p.play_attack(candidates[0].position - p.position, s.get("magic", false))
	return true







const SPREAD_MEMORY: = 0.8
static func spread(world: World, p: Player, key: String, candidates: Array[Enemy], n: int, area: float) -> Array[Enemy]:
	var gap: = area * 0.9
	var fell: Array = []
	var past = p.spread_hits.get(key)
	if past is Array and world.clock - float(past[0]) <= SPREAD_MEMORY:
		fell = (past[1] as Array).duplicate()
	var first: Array[Enemy] = []
	var rest: Array[Enemy] = []
	for e in candidates:
		var apart: = first.size() < n
		if apart:
			for q in fell:
				if e.position.distance_squared_to(q) < gap * gap:
					apart = false
					break
		if apart:
			first.append(e)
			fell.append(e.position)
		else:
			rest.append(e)

	for i in range(first.size(), mini(n, first.size() + rest.size())):
		fell.append(rest[i - first.size()].position)
	p.spread_hits[key] = [world.clock, fell]
	return first + rest





static func _neediest(world: World, p: Player, party: bool, need: Callable) -> Player:
	if not party or world.heroes.size() < 2:
		return p
	var best: = p
	for h in world.heroes:
		if h.downed or h.hp <= 0.0 or h.position.distance_to(p.position) > GameData.PARTY_HEAL_RANGE:
			continue
		if float(need.call(h)) < float(need.call(best)):
			best = h
	return best




static func _party_buff(world: World, p: Player, id: String, level: int, s: Dictionary) -> void :
	if not GameData.PARTY_BUFFS.has(id) or world.heroes.size() < 2:
		return
	var power: = float(GameData.PARTY_BUFFS[id]) * (1.0 + float(p.effects.get("buff_power", 0.0))) * p.support_mult

	var t: = float(s.get("cooldown", 10.0)) * p.cd_for(id) + GameData.PARTY_BUFF_GRACE
	for h in world.heroes:
		if h == p or h.downed or h.position.distance_to(p.position) > GameData.PARTY_BUFF_RANGE:
			continue
		var fresh: = not h.party_buffs.has(id)
		h.receive_party_buff(id, level, power, t)
		world.smoke_stats["ally_buffs"] = int(world.smoke_stats.get("ally_buffs", 0)) + 1
		if fresh:
			if s.has("fx"):
				world.spawn_fx(s.fx, h.position, 1.0, 1.0, h)
			elif s.has("tex_fx"):
				world.rising_tex(h, str(s.tex_fx), int(s.get("tex_count", 1)))
			elif s.has("spr_fx"):
				world.sprite_fx(str(s.spr_fx), h.position, 0, float(s.get("spr_size", 1.0)), h)





static func _acid_terror(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var foes: = world.enemies_in_radius(p.position, v.call("range"))
	if foes.is_empty():
		return false
	foes.sort_custom( func(a: Enemy, b: Enemy) -> bool:
		if a.is_boss != b.is_boss:
			return a.is_boss
		return a.max_hp > b.max_hp)
	var n: = mini(maxi(1, int(v.call("count"))), foes.size())
	for i in n:
		acid_hit(world, p, foes[i], v.call("damage"), maxi(1, int(v.call("hits"))), s, v.call("acid"), v.call("area") * p.area_mult, 0.09 * i)
	p.play_attack(foes[0].position - p.position)
	return true







static func acid_hit(world: World, p: Player, e: Enemy, dmg: float, hits: int, s: Dictionary, acid: float, puddle: float, delay: = 0.0) -> void :
	var tag: = world.damage_tag
	var from: = p.position + Vector3(0, 1.2, 0)
	var flight: = clampf(from.distance_to(e.position) / 18.0, 0.16, 0.42)
	var col: Color = s.get("color", Color(0.6, 1.0, 0.4))
	var gap: = float(s.get("hit_gap", 0.13))
	world._own_timer(delay, func():
		if not world.running or not is_instance_valid(e) or e.dead or not world.hero_valid(p):
			return
		acid_bottle(world, from, e, flight)
		world._own_timer(flight, func():
			if not world.running or not is_instance_valid(e) or e.dead or not world.hero_valid(p):
				return
			world.play_sound(str(s.get("sound", "acid_terror")), 0.05, float(s.get("sound_db", -6.0)))
			Vfx.burst(world.fx_root, e.position + Vector3(0, 0.6, 0), 1.2, col)
			for k in hits:
				world._own_timer(gap * k, func():
					if not world.running or not is_instance_valid(e) or e.dead or not world.hero_valid(p):
						return
					var last: = k == hits - 1
					world.damage_tag = tag
					world.damage_enemy(e, dmg, Vector3.ZERO, "skill", element_of(p, s))
					world.damage_tag = ""
					var jitter: = Vector3(randf_range(-0.25, 0.25), 0.5 + randf_range(0.0, 0.5), randf_range(-0.25, 0.25))

					var at: = e.position + jitter
					Vfx.burst(world.fx_root, at, 0.7 + 0.08 * k, col)
					Vfx.ray_flash(world.fx_root, at, world.camera.global_basis, col.lerp(Color.WHITE, 0.2), 0.55 + 0.05 * k)
					world.play_sound("envenom", 0.0, -9.0, 1.0 + 0.07 * k, false)
					if last and is_instance_valid(e) and not e.dead:
						world.shake(0.15)
						Vfx.burst(world.fx_root, e.position + Vector3(0, 0.5, 0), 1.8, col)
						e.acid_frail = maxf(e.acid_frail if e.acid_until > world.clock else 0.0, acid)
						e.acid_until = maxf(e.acid_until, world.clock + float(s.get("acid_time", 4.0)))
						var zs: = s.duplicate()
						zs["acid_now"] = acid
						world.damage_tag = tag
						world.ground_zone(e.position, zs, puddle, dmg * float(s.get("puddle_dmg", 0.3)), 0.0, float(s.get("duration", 2.0)))
						world.damage_tag = "")))




static func acid_bottle(world: World, from: Vector3, e: Node3D, flight: float) -> void :
	if world.net.recording():
		world.net.record(["ab", from, world.net.ref_of(e), flight])
	var spr: = RoAssets.sprite(["item_acid_bottle"])
	if spr == null or not is_instance_valid(e):
		return
	var b: = Sprite3D.new()
	b.texture = spr.get_frame(0, 0)
	b.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	b.shaded = false
	b.no_depth_test = true
	b.render_priority = 8
	b.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	b.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	b.pixel_size = GameData.PIXEL_SIZE * 1.1
	b.modulate.a = Vfx.dim
	world.fx_root.add_child(b)
	b.global_position = from

	var fly: = func(t: float) -> void :
		if not is_instance_valid(e) or not is_instance_valid(b):
			return
		var to: = e.global_position + Vector3(0, 0.7, 0)
		b.global_position = from.lerp(to, t) + Vector3(0, sin(t * PI) * 1.4, 0)
		b.scale = Vector3.ONE * (1.0 + 0.12 * sin(t * TAU * 2.0))
	var tw: = b.create_tween()
	tw.tween_method(fly, 0.0, 1.0, flight)
	tw.tween_callback(b.queue_free)




static func _ground(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var area: float = v.call("area") * p.area_mult
	var heal: float = v.call("heal_amount") if s.has("heal_amount") else 0.0
	var points: Array[Vector3] = []
	if s.get("wall", false):
		return _wall(world, p, s, v, area)
	if s.get("on_self", false):

		var hurt: = false
		if heal > 0.0:
			for h in world.heroes:
				if not h.downed and h.hp < h.max_hp - 1.0 and h.position.distance_to(p.position) <= area:
					hurt = true
		if not hurt and world.enemies_in_radius(p.position, area).is_empty():
			return false
		points.append(p.position)
	else:
		var candidates: = world.enemies_in_radius(p.position, v.call("range"))
		if candidates.is_empty():
			return false
		candidates.shuffle()
		if s.get("magic", false) and not world.raid.active():
			candidates = spread(world, p, str(s.get("name", "")), candidates, int(v.call("count")), area)
		for i in mini(int(v.call("count")), candidates.size()):
			points.append(candidates[i].position)
	var zs: = s
	if s.has("acid"):

		zs = s.duplicate()
		zs["acid_now"] = v.call("acid")
	for at in points:
		world.ground_zone(at, zs, area, v.call("damage"), heal, v.call("duration"))
	p.play_attack(points[0] - p.position, s.get("magic", false))
	world.play_skill_sound(s)
	return true




static func _wall(world: World, p: Player, s: Dictionary, v: Callable, area: float) -> bool:
	if p.effects.has("lg_firewall"):
		return _fire_ring(world, p, s, v, area)
	var targets: = world.nearest_enemies(p.position, v.call("range"), maxi(1, int(v.call("count"))))
	if targets.is_empty():
		return false
	for t in targets:
		var to: = (t.position - p.position) * Vector3(1, 0, 1)
		var dist: = to.length()
		var dir: = to / dist if dist > 0.01 else p.facing



		var at: = t.position if t._static else p.position + dir * clampf(dist - 1.0, 1.5, 3.5)
		world.ground_zone(at, s, area, v.call("damage"), 0.0, v.call("duration"), dir)
	p.play_attack(targets[0].position - p.position, true)
	world.play_skill_sound(s)
	return true




static func _fire_ring(world: World, p: Player, s: Dictionary, v: Callable, area: float) -> bool:
	if world.nearest_enemy(p.position, v.call("range")) == null:
		return false
	var n: = GameData.LG_RING_SEGMENTS + (2 if s.get("evolved", false) else 0)
	var radius: = GameData.LG_RING_RADIUS * sqrt(p.area_mult) * (1.25 if s.get("evolved", false) else 1.0)
	var turn: = randf() * TAU
	for i in n:
		var a: = turn + TAU * i / n
		var dir: = Vector3(cos(a), 0, sin(a))
		world.ground_zone(p.position + dir * radius, s, area, v.call("damage") * GameData.LG_RING_DMG, 0.0, 
			v.call("duration") * GameData.LG_RING_TIME, dir, p)
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), radius + 0.6, Color(1.0, 0.55, 0.2, 0.9), 0.5)
	world.spawn_fx("firehit1", p.position, radius / 2.2, 0.7)
	p.play_attack(p.facing, true)
	world.play_skill_sound(s)
	return true



static func _signum(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range") * p.area_mult
	var marked: = world.enemies_in_radius(p.position, reach)

	var bosses: Array = []
	if s.has("boss_reach"):
		for e in world.enemies_in_radius(p.position, float(s.boss_reach)):
			if e.is_boss and not e.dead:
				bosses.append(e)
				marked.erase(e)
	if marked.is_empty() and bosses.is_empty():
		return false


	world.signum_crucis(p, marked, reach, v.call("frail") * p.buff_mult_for("frail"), v.call("duration"), s)
	if not bosses.is_empty():
		world.signum_crucis(p, bosses, 0.0, v.call("frail") * float(s.get("boss_frail", 1.0)) * p.buff_mult_for("frail"), v.call("duration"), s)
	world.play_skill_sound(s)
	return true




static func _bolt(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	if s.has("rain"):
		return _arrow_shower(world, p, s, v)
	var target: = world.nearest_enemy(p.position, v.call("range"))
	if target == null:
		return false



	var el: = element_of(p, s)
	var best_d: = INF
	for e in world.enemies_in_radius(p.position, v.call("range")):
		var st: String = e.status if e.status != "" else (e.boss_mark if e.boss_mark_until > world.time else "")
		if st == "" or str(GameData.STATUS_COMBO.get(st, "")) != el or e.dead:
			continue
		var d: = p.position.distance_squared_to(e.position)
		if d < best_d:
			best_d = d
			target = e
	var count: = int(v.call("count"))

	var each: = 1.0
	if count > GameData.BOLTS_MAX:
		each = float(count) / GameData.BOLTS_MAX
		count = GameData.BOLTS_MAX
	var area: float = v.call("area") * p.area_mult if s.has("area") else 0.0
	for i in count:
		var point: = target.position
		if area > 0.0:
			var a: = randf() * TAU
			point += Vector3(cos(a), 0, sin(a)) * sqrt(randf()) * area
		world.drop_bolt({
			"target": target if area <= 0.0 else null, 
			"point": point, 
			"skill": s, 
			"damage": v.call("damage") * arrow_mult(p, s) * each, 
			"element": element_of(p, s), 
			"radius": s.get("hit_radius", 0.0), 
			"delay": i * float(s.get("bolt_gap", 0.12)), 
			"index": i, 
		})
	p.play_attack(target.position - p.position, s.get("magic", false))
	world.play_skill_sound(s)
	return true









static func _soul_strike(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range")
	var target: = strongest(world, p.position, reach)
	if target == null:
		return false
	var count: = maxi(1, int(v.call("count")))
	var dmg: float = v.call("damage")
	var el: = element_of(p, s)
	var tag: = world.damage_tag
	var gap: = float(s.get("missile_gap", 0.08))
	var flight: = float(s.get("flight", 0.42))
	var col: Color = s.get("color", Color(0.8, 0.72, 1.0))
	for i in count:

		var side: = (1.0 if i % 2 == 0 else -1.0) * (0.7 + 0.35 * float((i >> 1) % 3))
		world._own_timer(gap * i, func():
			if not world.running or not world.hero_valid(p):
				return
			var t: Enemy = target if is_instance_valid(target) and not target.dead else strongest(world, p.position, reach)
			if t == null:
				return
			var from: = p.position + Vector3(0, 1.3, 0)
			soul_missile(world, from, t, flight, side, col)
			var last: = [t.position]
			world._own_timer(flight, func():
				if not world.running or not world.hero_valid(p):
					return
				var hit: Enemy = t if is_instance_valid(t) and not t.dead else null
				if hit == null:
					hit = strongest(world, last[0], 2.5)
				if hit == null:
					return
				world.damage_tag = tag
				world.damage_enemy(hit, dmg, Vector3.ZERO, "skill", el)
				world.damage_tag = ""
				Vfx.burst(world.fx_root, hit.position + Vector3(0, 0.8, 0), 0.9, col)

				world.play_sound(str(s.get("sound", "soul_strike")), 0.1, -9.0)))

	Vfx.burst(world.fx_root, p.position + Vector3(0, 1.3, 0), 0.8, Color(1.0, 0.95, 0.8))
	p.play_attack(target.position - p.position, true)
	world.play_skill_sound(s)
	return true




static func strongest(world: World, at: Vector3, reach: float) -> Enemy:
	var best: Enemy = null
	var score: = -1.0
	for e in world.enemies_in_radius(at, reach):
		if e.dead or e.prop != "":
			continue
		var sc: = rank(world, e)
		if sc > score:
			score = sc
			best = e
	return best


static var _soul_mats: = {}




static func _soul_material(add: bool) -> StandardMaterial3D:
	if not _soul_mats.has(add):
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if add else BaseMaterial3D.BLEND_MODE_MIX
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.vertex_color_use_as_albedo = true
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.no_depth_test = true
		m.render_priority = 6 if add else 5
		m.albedo_texture = RoAssets.radial(Color.WHITE, 64)
		_soul_mats[add] = m
	return _soul_mats[add]


static func _soul_sprite(tex: Texture2D, add: bool, size: float, col: Color) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = tex
	s.material_override = _soul_material(add)
	s.pixel_size = size / 64.0
	s.modulate = col
	return s









static func soul_missile(world: World, from: Vector3, e: Node3D, flight: float, side: float, col: Color, 
		veil: = Color(1.0, 0.93, 0.72)) -> void :
	if world.net.recording():
		world.net.record(["sm", from, world.net.ref_of(e), flight, side, col, veil])
	if Vfx._skip(3) or not is_instance_valid(e):
		return
	var dim: = Vfx.dim
	var tex: = RoAssets.radial(Color.WHITE, 64)



	var m: = _soul_sprite(tex, true, 1.15, Color(veil, 0.5 * dim))
	m.add_child(_soul_sprite(tex, true, 0.7, Color(col, 0.95 * dim)))
	m.add_child(_soul_sprite(tex, true, 0.32, Color(1.0, 1.0, 1.0, dim)))
	world.fx_root.add_child(m)
	m.global_position = from
	var to0: = e.global_position + Vector3(0, 0.8, 0)
	var ahead: = ((to0 - from) * Vector3(1, 0, 1))
	ahead = ahead.normalized() if ahead.length_squared() > 0.01 else Vector3.RIGHT
	var out: = ahead.cross(Vector3.UP) * side * 1.5 + Vector3(0, 0.8 + absf(side) * 0.4, 0) - ahead * 0.5

	var seen: = [to0, 0, from]
	var trail: = not Vfx._skip(1)
	var fly: = func(k: float) -> void :
		if not is_instance_valid(m):
			return
		if is_instance_valid(e):
			seen[0] = e.global_position + Vector3(0, 0.8, 0)
		var to: Vector3 = seen[0]
		var bend: Vector3 = from + out + (to - from) * 0.35
		var u: = 1.0 - k
		m.global_position = from * u * u + bend * 2.0 * u * k + to * k * k
		if trail:


			var last: Vector3 = seen[2]
			var here: = m.global_position


			var steps: = clampi(int(last.distance_to(here) / 0.25), 1, 3)
			if Vfx._skip(2) or Vfx.foreign:
				steps = 1
			for i in steps:
				if not Vfx.trail_ok():
					break
				var at: = last.lerp(here, float(i + 1) / steps)
				var ghost: = _soul_sprite(tex, true, 0.75, Color(veil, 0.85 * dim))
				ghost.add_child(_soul_sprite(tex, true, 0.32, Color(1.0, 1.0, 1.0, 0.9 * dim)))
				world.fx_root.add_child(ghost)
				ghost.global_position = at
				var fade: = ghost.create_tween().set_parallel()
				fade.tween_property(ghost, "modulate:a", 0.0, 0.32)
				fade.tween_property(ghost, "scale", Vector3.ONE * 0.08, 0.32)
				fade.chain().tween_callback(ghost.queue_free)
			seen[2] = here
	var tw: = m.create_tween()
	tw.tween_method(fly, 0.0, 1.0, flight).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(m.queue_free)








static func soul_detonate(world: World, p: Player, e: Enemy, base: float, possess: bool) -> void :
	if e.dead or e.combo_mark == "" or e.combo_until <= world.time:
		return
	if world.clock < float(e.get_meta("soul_combo_at", -99.0)) + GameData.SOUL_COMBO_GAP:
		return
	var now: = World.game_ms() / 1000.0
	if now - world._combo_window > 0.1 or now < world._combo_window:
		world._combo_window = now
		world._combo_count = 0
	if world._combo_count >= GameData.COMBO_CAP:
		return
	world._combo_count += 1
	e.set_meta("soul_combo_at", world.clock)
	var kind: = str(GameData.SOUL_COMBO_KIND.get(e.combo_mark, "blaze"))
	world._combo_clear(e)
	var dmg: = base * GameData.SOUL_COMBO_MULT * (1.0 + float(p.effects.get("combo_dmg", 0.0))) * possess_mult(world, e)
	if possess:
		e.set_meta("soul_possess", world.clock + GameData.SOUL_POSSESS_TIME)
		var col: = Color(0.8, 0.72, 1.0)
		Vfx.ring(world.fx_root, e.position + Vector3(0, 0.06, 0), e.radius + 0.9, col, 0.5)
		Vfx.burst(world.fx_root, e.position + Vector3(0, 1.0, 0), e.radius + 0.6, col)
		world.side_word(e, TranslationServer.translate("¡Poseído!"), col)
	var at: = e.position
	var eid: = e.get_instance_id()
	world._own_timer(0.05, func(): world._wiz_react(p, kind, at, dmg, eid))




static func possess_mult(world: World, e: Enemy) -> float:
	if not e.has_meta("soul_possess"):
		return 1.0
	var until: = float(e.get_meta("soul_possess"))
	e.remove_meta("soul_possess")
	return 1.0 + GameData.SOUL_POSSESS_DMG if until > world.clock else 1.0






static func _arrow_shower(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range")
	var area: float = v.call("area") * p.area_mult
	var center: = _rain_spot(world, p, reach, area)
	if center == Vector3.INF:
		return false
	var dmg: float = v.call("damage") * arrow_mult(p, s)
	var el: = element_of(p, s)
	var count: = int(v.call("count"))


	if p.effects.has("lg_rudra"):
		s = s.duplicate()
		s["waves"] = maxi(GameData.LG_RUDRA_WAVES, int(s.get("waves", 1)))
		s["rain"] = GameData.LG_RUDRA_WAVE
		if el == "neutral":
			el = "holy"
		var under: = world.enemies_in_radius(center, area).filter( func(e): return not e.dead).size()
		if under > 0:
			p.heal(p.max_hp * GameData.LG_RUDRA_HEAL * mini(under, GameData.LG_RUDRA_MAX), world)
	world.arrow_rain(p, center, s, dmg, el, count, area)
	p.play_attack(center - p.position, false)
	world.play_skill_sound(s)
	var tag: = world.damage_tag
	for w in range(1, int(s.get("waves", 1))):
		world._own_timer(float(s.rain) * w, func():
			if not world.running or not world.hero_valid(p):
				return
			world._rebuild_grid()
			var at: = _rain_spot(world, p, reach, area)
			if at == Vector3.INF:
				return
			world.damage_tag = tag
			world.arrow_rain(p, at, s, dmg, el, count, area)
			p.play_attack(at - p.position, false)
			world.play_skill_sound(s))
	return true




static func _rain_spot(world: World, p: Player, reach: float, area: float) -> Vector3:
	var center: = _thickest(world, p, reach, area)
	if center == Vector3.INF:
		return center
	var sum: = Vector3.ZERO
	var group: = world.enemies_in_radius(center, area)
	for e in group:
		sum += e.position
	return sum / group.size() if not group.is_empty() else center




static func _ice_trail(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var targets: = world.nearest_enemies(p.position, v.call("range"), int(v.call("count")))
	if targets.is_empty():
		return false
	for t in targets:
		world.ice_trail(p.position, t, v.call("damage"), s, v.call("status_chance"))
	p.play_attack(targets[0].position - p.position, true)
	world.play_skill_sound(s)
	return true



static func _steal(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var target: = world.nearest_enemy(p.position, v.call("range"))
	if target == null:
		return false
	var dir: = (target.position - p.position) * Vector3(1, 0, 1)
	p.play_attack(dir)
	world.damage_enemy(target, v.call("damage"), dir.normalized(), "skill", s.get("element", "neutral"))
	world.gain_zeny(roundi(v.call("zeny") * p.loot_mult), target.position)
	if s.has("fx"):
		world.spawn_fx(s.fx, target.position, 1.0, 1.0)
	world.play_skill_sound(s)
	return true



static func _falcon(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var targets: = world.nearest_enemies(p.position, v.call("range"), int(v.call("count")))

	var prey = p.get_meta("blitz_target") if p.has_meta("blitz_target") else null
	if prey != null and is_instance_valid(prey) and not (prey as Enemy).dead:
		targets.erase(prey)
		targets.push_front(prey)
		if targets.size() > int(v.call("count")):
			targets.resize(int(v.call("count")))
	if targets.is_empty():
		return false
	world.falcon_strike(p, targets, v.call("damage"), v.call("area") * p.area_mult, s)
	return true





static func _issen(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var near: = world.enemies_in_radius(p.position, v.call("range"))
	if near.is_empty():
		return false
	var target: Enemy = near[0]
	for e in near:
		if (e.is_boss and not target.is_boss) or (e.is_boss == target.is_boss and e.hp > target.hp):
			target = e
	var dmg: float = v.call("damage") + (p.hp + maxf(0.0, p.shield)) * v.call("hp_power")
	p.hp = maxf(1.0, p.hp - p.hp * float(s.get("hp_cost", 0.1)))
	var dir: = ((target.position - p.position) * Vector3(1, 0, 1)).normalized()
	world.backstab_hit(p, target, dmg, v.call("area") * sqrt(p.area_mult), s, 0.0)
	_issen_show(world, target, s)
	p.play_attack(dir)
	world.play_skill_sound(s)
	return true




static func _issen_show(world: World, target: Enemy, s: Dictionary) -> void :
	var at: = target.position
	var red: = Color(0.95, 0.12, 0.15)
	var cam: = world.camera.global_basis
	world.hud.flash(red, 0.3, 0.35)
	world.side_word(target, TranslationServer.translate("¡Issen!"), Color(1.0, 0.25, 0.2))
	world.sprite_fx(str(s.spr_fx), at + Vector3(0, 1.0, 0), 0, 1.5)
	world.spawn_fx("jyumonjikiri", at + Vector3(0, 0.4, 0), 1.8, 1.0)
	Vfx.blood_spray(world.fx_root, at, 1.2, 2.0)
	Vfx.ray_flash(world.fx_root, at + Vector3(0, 1.0, 0), cam, red, 2.4)
	world.shake(0.4)
	world._own_timer(0.12, func():
		world.spawn_fx("jyumonjikiri", at + Vector3(0, 0.4, 0), 2.6, 1.0)
		Vfx.strike_circle(world.fx_root, at, 2.6, red)
		Vfx.ring(world.fx_root, at, 3.0, Color(1.0, 0.45, 0.35), 0.35))
	world._own_timer(0.24, func():
		Vfx.burst(world.fx_root, at + Vector3(0, 0.6, 0), 3.2, red)
		Vfx.ring(world.fx_root, at, 6.0, Color(1.0, 0.75, 0.6), 0.5)
		world.shake(0.6))






static func _kick(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range") * sqrt(p.area_mult)
	var target: Enemy = p.get_meta("kick_target") if p.has_meta("kick_target") else null
	if target == null or not is_instance_valid(target) or target.dead:
		target = world.nearest_enemy(p.position, reach + 0.5)
	if target == null:
		return false
	var el: = p.basic_element()
	var dmg: float = v.call("damage")
	var dir: = ((target.position - p.position) * Vector3(1, 0, 1)).normalized()
	if dir == Vector3.ZERO:
		dir = p.facing
	p.play_combo(dir, int(s.get("pose", RoVisual.PC_ATTACK)))
	world.play_skill_sound(s)
	match str(s.kick):
		"tornado":
			_tornado(world, p, s, reach, dmg, el)
			if s.get("twice", false):

				world._own_timer(0.22, func():
					if world.hero_valid(p):
						world.play_sound(str(s.sound), 0.0, -2.0)
						world.damage_by = p
						world.damage_tag = str(s.get("id", "tornado_kick_x"))
						_tornado(world, p, s, reach, dmg, el)
						world.damage_by = null)
		"heel":
			var area: float = v.call("area") * sqrt(p.area_mult)
			var at: = target.position
			world.damage_enemy(target, dmg, Vector3.ZERO, "skill", el)
			world.try_status(target, s, v.call("status_chance"))
			for e in world.enemies_in_radius(at, area):
				if e != target:
					world.damage_enemy(e, dmg * 0.5, ((e.position - at) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", el)
					world.try_status(e, s, v.call("status_chance") * 0.5)
			world.spawn_fx("earthhit", at, area / 2.0, 0.9)
			Vfx.ring(world.fx_root, at, area, s.color, 0.35)
			Vfx.burst(world.fx_root, at, area * 0.6, Color(1, 0.95, 0.8))
			world.shake(0.3)
		"round":
			var half: = deg_to_rad(float(s.arc)) * 0.5
			Vfx.arc(world.fx_root, p.position, dir, reach, deg_to_rad(float(s.arc)), Color(s.color, 0.9))
			Vfx.arc(world.fx_root, p.position, dir, reach * 0.7, deg_to_rad(float(s.arc)), Color(1, 1, 1, 0.7))
			var n: = 0
			for e in world.enemies_in_radius(p.position, reach):
				var to: = (e.position - p.position) * Vector3(1, 0, 1)
				if to.length() < 0.6 or absf(dir.signed_angle_to(to, Vector3.UP)) <= half:
					world.damage_enemy(e, dmg, to.normalized() * float(s.knock), "skill", el)
					if n < 4:
						world.spawn_fx("hit", e.position + Vector3(0, 0.6, 0), 0.9, 0.9)
					n += 1
			world.shake(0.2)
		"counter":
			var before: = p.crit
			p.crit = 1.0
			world.damage_enemy(target, dmg, dir * float(s.knock), "skill", el)
			p.crit = before
			world.spawn_fx("hit", target.position + Vector3(0, 0.7, 0), 1.2, 1.0)
			Vfx.burst(world.fx_root, target.position, 1.3, s.color)
	return true



static func _tornado(world: World, p: Player, s: Dictionary, reach: float, dmg: float, el: String) -> void :
	_spin(p)
	Vfx.ring(world.fx_root, p.position, reach, Color(1, 1, 1, 0.85), 0.35)
	Vfx.ring(world.fx_root, p.position, reach * 0.75, s.color, 0.45)
	for i in 4:
		Vfx.arc(world.fx_root, p.position, Vector3(1, 0, 0).rotated(Vector3.UP, TAU * i / 4.0), reach, 1.8, Color(s.color, 0.8))
	var n: = 0
	for e in world.enemies_in_radius(p.position, reach):
		var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, dmg, away * float(s.knock), "skill", el)
		if n < 5:
			world.spawn_fx("hit", e.position + Vector3(0, 0.6, 0), 0.8, 0.9)
		n += 1
	world.shake(0.15)



static func _spin(p: Player) -> void :
	var start: = p.facing
	var tw: = p.create_tween()
	for i in 8:
		var d: = start.rotated(Vector3.UP, TAU * (i + 1) / 8.0)
		tw.tween_callback( func():
			if is_instance_valid(p) and p.visual != null:
				p.visual.face(d))
		tw.tween_interval(0.035)




static func _flying_kick(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	if not p.dash.is_empty():
		return false
	var reach: float = v.call("range")



	var going: = Vector3(p._last_stick.x, 0.0, p._last_stick.y)
	var moving: = going.length() > 0.3
	going = going.normalized()
	var far: Enemy = null
	var far_d: = 2.5
	for e in world.enemies_in_radius(p.position, reach):
		var to_e: = (e.position - p.position) * Vector3(1, 0, 1)
		var d: = to_e.length()
		if moving and to_e.normalized().dot(going) < 0.6:
			continue
		if d > far_d:
			far_d = d
			far = e
	if far == null:
		return false
	var dir: = ((far.position - p.position) * Vector3(1, 0, 1)).normalized()
	if moving:

		dir = (going * 0.6 + dir * 0.4).normalized()
	var to: = world.map.slide(p.position, dir * (far_d + 0.8))
	var dmg: float = v.call("damage") * (1.0 + float(p.effects.get("sprint", 0.0)))
	p.start_dash(world, Vector3(to.x, world.map.height_at(to), to.z), clampf(far_d / 26.0, 0.16, 0.42), 
		{"kind": "flying", "dmg": dmg, "width": v.call("area") * sqrt(p.area_mult), "knock": float(s.knock), 
		"tag": world.damage_tag, "pose": RoVisual.PC_ATTACK, "height": 0.7, "color": Color(s.color, 0.55), 
		"rebound": s.get("rebound", false) or p.effects.has("lg_fkick"), 

		"rebounds": (1 if s.get("rebound", false) else 0) + (GameData.LG_FKICK_BOUNCES if p.effects.has("lg_fkick") else 0)})
	world.play_skill_sound(s)
	return true




static func _charge(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var reach: float = v.call("range")
	var going: = Vector3(p._last_stick.x, 0.0, p._last_stick.y)
	var moving: = going.length() > 0.3
	going = going.normalized() if moving else Vector3.ZERO
	var best: Enemy = null
	for pass_i in (2 if moving else 1):
		var top: = -1.0
		for e in world.enemies_in_radius(p.position, reach):
			if e.dead or e.prop != "":
				continue
			var to: = (e.position - p.position) * Vector3(1, 0, 1)
			if pass_i == 0 and moving and to.length() > 0.5 and to.normalized().dot(going) < 0.4:
				continue
			var score: = rank(world, e)
			if score > top:
				top = score
				best = e
		if best != null:
			break
	if best == null:
		return false
	world.charge_attack(p, best, v.call("damage"), reach, v.call("width") * sqrt(p.area_mult), s, int(s.get("chain", 0.0)))
	world.play_skill_sound(s)
	return true



static func _holy_burst(world: World, p: Player, dmg: float) -> void :
	var reach: = GameData.LG_HEAL_RADIUS * p.area_mult
	for e in world.enemies_in_radius(p.position, reach):
		var to: = (e.position - p.position) * Vector3(1, 0, 1)
		world.damage_enemy(e, dmg, to.normalized() * 2.0, "skill", "holy")
	Vfx.ring(world.fx_root, p.position + Vector3(0, 0.05, 0), reach, Color(1.0, 0.95, 0.7), 0.4)
	world.spawn_fx("holyhit", p.position, reach / 3.0, 0.9)



static func _leap(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	if not p.dash.is_empty() or p.hp > p.max_hp * 0.5:
		return false
	var near: = world.enemies_in_radius(p.position, 2.4)
	if near.size() < 3:
		return false
	var mid: = Vector3.ZERO
	for e in near:
		mid += e.position
	mid /= near.size()
	var dir: = ((p.position - mid) * Vector3(1, 0, 1)).normalized()
	if dir == Vector3.ZERO:
		dir = - p.facing
	var to: = world.map.slide(p.position, dir * v.call("range"))
	p.start_dash(world, Vector3(to.x, world.map.height_at(to), to.z), 0.42, 
		{"kind": "leap", "land_dmg": v.call("damage"), "land_area": v.call("area") * sqrt(p.area_mult), 
		"knock": float(s.knock), "tag": world.damage_tag, "pose": RoVisual.PC_READY, "height": 2.4, 
		"color": Color(s.color, 0.45)})
	world.play_skill_sound(s)
	return true




const MILD_ELEMENTS: = ["earth", "wind", "water", "fire", "ghost", "shadow", "holy"]

static func best_element(near: Array) -> String:
	var best: = ""
	var best_score: = - INF
	for el in MILD_ELEMENTS:
		var score: = 0.0
		for e in near:


			var w: = 12.0 if e.is_boss else (2.0 if e.def.get("elite", false) else 1.0)
			score += w * GameData.element_mult(el, e.element())
		if score > best_score + 0.001:
			best_score = score
			best = el
	return best


static func _mild_wind(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	var near: = world.enemies_in_radius(p.position, v.call("range"))
	if near.is_empty():
		return false
	var best: = best_element(near)
	if p.powers.has("mild_wind") and p.mild_element == best and float(p.powers.mild_wind) > 2.0:
		return false
	p.mild_element = best
	p.powers.erase("mild_wind")
	p.add_power("mild_wind", v.call("duration"))
	var idx: = MILD_ELEMENTS.find(best) + 1
	world.rising_tex(p, "hanmoon_%d" % idx, 3)
	var col: Color = s.color
	world.number(p.position + Vector3(0, 2.4, 0), "%s: %s" % [TranslationServer.translate("Mild Wind"), 
		TranslationServer.translate(str(GameData.ELEMENT_NAMES.get(best, best)))], col, true)
	p.play_attack(p.facing, true)
	world.play_skill_sound(s)
	return true






static func _soul_link(world: World, p: Player, s: Dictionary, v: Callable) -> bool:
	if world.nearest_enemy(p.position, 10.0) == null:
		return false

	var lent: Array = World.SoulLinker.next_spirits(p)
	var spirit: = str(lent[0])
	p.set_meta("spirit", spirit)
	var time: float = v.call("duration")
	var party_time: = time * (1.0 + float(p.effects.get("soul_time", 0.0)))
	for h in world.heroes:
		if h.downed or (h != p and h.position.distance_to(p.position) > GameData.SOUL_LINK_RANGE):
			continue
		for k in h.powers.keys():
			if str(k).begins_with("spirit_"):
				h.powers.erase(k)
		for one in lent:
			h.add_power("spirit_" + str(one), party_time)

		h.soul_bonds = mini(GameData.SOUL_BOND_MAX, h.soul_bonds + 1)
		h.recompute()
		World.SoulLinker.show_spirit(world, h, lent, time if h == p else party_time, h == p)
	Vfx.magic_circle(world.fx_root, p.position, 2.2, Color(s.color, 0.7), 1.2, "mvp_hexa", 1.5)
	p.play_attack(p.facing, true)
	world.play_skill_sound(s)
	if p.soul_bonds > 0:
		world.number(p.position + Vector3(0, 2.2, 0), TranslationServer.translate("Vínculo x%d") % p.soul_bonds, Color(s.color))

	var lv: = int(p.skills.soul_link.level) if p.skills.has("soul_link") else GameData.MAX_SKILL_LEVEL
	World.SoulLinker.start_wheel(p, lent, time, lv)
	return true
