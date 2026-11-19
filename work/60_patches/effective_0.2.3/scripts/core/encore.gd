extends RefCounted





















static var log_on: = "--ens-log" in OS.get_cmdline_user_args()




static func _shot(world: World, name: String, delay: = 1.0) -> void :
	var dir: = ""
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--ens-shots="):
			dir = str(a).substr(12)
	if dir == "" or DisplayServer.get_name() == "headless":
		return
	var side: = "client" if world.net != null and world.net.is_client() else "host"
	world.get_tree().create_timer(delay, true, false, true).timeout.connect( func():
		if is_instance_valid(world):
			var path: = "%s/%s_%s.png" % [dir, side, name]
			world.get_viewport().get_texture().get_image().save_png(path)
			print("ENS shot %s" % path))





static func beat(world: World, p: Player, bis: bool) -> void :
	if p.songs.is_empty():
		return

	if p.beat_n == 22 or p.beat_n == 24:
		_shot(world, "songs_%s_%d" % [p.performer(), p.beat_n], 0.0)
	var lead: = Player.base_skill(str(p.songs[p.beat_n % p.songs.size()]))
	var col: Color = (GameData.SONG_AURAS.get(lead, {}) as Dictionary).get("color", Color(0.9, 0.8, 1.0))
	_service(world, p, bis)
	if not bis:

		return
	_bis(world, p, col)




static func _service(world: World, p: Player, bis: bool) -> void :
	for id in p.songs:
		if Player.base_skill(str(id)) != "service_for_you":
			continue
		var cut: float = GameData.skill_value(str(id), "relief", int(p.skills[id].level)) * p.support_mult * (p.bis_mult() if bis else 1.0)
		p.cut_cooldowns(cut, true)
		if world.heroes.size() > 1:
			var reach: = float(GameData.SKILLS[id].get("party_range", GameData.SONG_PARTY_RANGE))
			for h in world.heroes:
				if h != p and not h.downed and h.position.distance_to(p.position) <= reach:
					h.cut_cooldowns(cut, true)


static func _bis(world: World, p: Player, col: Color) -> void :
	var m: = p.bis_mult()


	world.rising_tex(p, "melody_a" if p.beat_n % 8 == 0 else "melody_b", 5)
	world.label_over(p, TranslationServer.translate("¡Bis!"), col.lightened(0.35))
	p.bis_count += 1


	if p.songs.has("dissonance_x"):
		tarot(world, p)

	p.song_cast = m
	for id in p.songs.duplicate():
		if p.skills.has(id) and str(GameData.SKILLS[id].type) == "aoe_self":
			Skills.cast(world, p, str(id), int(p.skills[id].level))
	p.song_cast = 1.0

	for id in ["musical_strike_x", "musical_strike"]:
		if p.skills.has(id):
			Skills.cast(world, p, id, int(p.skills[id].level))
			break

	if p.effects.has("lg_lyre"):
		p.cut_cooldowns(GameData.LG_LYRE_CUT, true)
		Vfx.column(world.fx_root, p.position, Color(1.0, 0.9, 0.55))

	if p.effects.has("lg_whip"):
		p.whip_left = 1 + p.dances_playing()
	if log_on:
		print("ENS bis hero=%d mult=%.2f songs=%s beat=%d" % [p.slot, m, p.songs, p.beat_n])






static func whip_step(world: World, p: Player, e: Enemy, base: float) -> void :
	if p.bis_t <= 0.0 or p.whip_left <= 0 or base <= 0.0:
		return
	p.whip_left -= 1
	var at: = e.position
	var area: = (GameData.LG_WHIP_AREA + GameData.LG_WHIP_AREA_PER * p.dances_playing()) * sqrt(p.area_mult)
	var keep: = world.hero_fx_begin(p)
	var col: = Color(1.0, 0.55, 0.85)
	Vfx.ring(world.fx_root, at, area, Color(col, 0.95), 0.4)
	Vfx.ring(world.fx_root, at, area * 0.6, Color(1.0, 0.9, 0.95, 0.85), 0.3)
	Vfx.burst(world.fx_root, at, area * 0.7, col)
	world.hero_sound("whip_crack", 0.1, -6.0)
	for m in world.enemies_in_radius(at, area):
		var dir: = ((m.position - at) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(m, base, dir * GameData.LG_WHIP_KNOCK, "skill", "neutral", "lg_dance_step")
	world.hero_fx_end(keep)






static func tarot(world: World, p: Player, card: = "") -> void :
	var reach: = GameData.TAROT_REACH * sqrt(p.area_mult)
	var near: = world.enemies_in_radius(p.position, reach)
	if near.is_empty():
		return
	if card == "":
		card = _draw_card(false)
	var c: Dictionary = GameData.TAROT_CARDS[card]
	var target: Enemy = Skills.strongest(world, p.position, reach)
	if target == null:
		target = near[0]
	var lv: = int(p.skills["dissonance_x"].level) if p.skills.has("dissonance_x") else 1
	var hit: = GameData.skill_value("dissonance_x", "damage", lv) * p.song_power("dissonance_x")
	world.damage_tag = "dissonance_x"
	world.damage_by = p
	p.tarot_count += 1
	card_show(world, p, card, target.position)
	if p.tarot_count <= 3:
		for dl in [0.15, 0.4, 0.7]:
			_shot(world, "tarot_%d_%s_%d" % [p.tarot_count, card, roundi(dl * 100)], dl)
	var col: Color = c.color
	match card:
		"hanged_man":

			for e in near:
				world.apply_status(e, "freeze", GameData.TAROT_FREEZE)
			Vfx.ring(world.fx_root, p.position, reach, Color(col, 0.9), 0.5)
		"tower":

			var area: = GameData.TAROT_TOWER_AREA * sqrt(p.area_mult)
			Vfx.column(world.fx_root, target.position, col)
			Vfx.quake(world.fx_root, target.position, area, Color(col, 0.9))
			for e in world.enemies_in_radius(target.position, area):
				var dir: = ((e.position - target.position) * Vector3(1, 0, 1)).normalized()
				world.damage_enemy(e, hit * GameData.TAROT_TOWER_DMG, dir * 2.0, "skill", "neutral", "dissonance_x")
			world.shake(0.35)
		"temperance":

			for e in near:
				var dir: = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
				world.damage_enemy(e, hit * 0.5, dir * 3.0, "skill", "neutral", "dissonance_x")
				world.blind_enemy(e, GameData.TAROT_CONFUSE)
			for e in near.slice(0, 4):
				world.emote(e, "question", 1.4)
			world.hero_sound("tarot_confuse", 0.2, -6.0)
		"devil":

			for e in near:
				if e.acid_until <= world.clock:
					e.acid_frail = 0.0
				e.acid_frail = maxf(e.acid_frail, GameData.TAROT_DEVIL_FRAIL)
				e.acid_until = maxf(e.acid_until, world.clock + GameData.TAROT_DEVIL_TIME)
				world.damage_enemy(e, hit * GameData.TAROT_DEVIL_DMG, Vector3.ZERO, "skill", "shadow", "dissonance_x")
			Vfx.ring(world.fx_root, p.position, reach, Color(col, 0.9), 0.5)
			world.hero_sound("curse", 0.2, -6.0)
		"sun":

			for h in world.heroes:
				if not h.downed and h.position.distance_to(p.position) <= reach + 2.0:
					h.receive_party_buff("tarot_card", 1, 1.0, GameData.TAROT_SUN_TIME * p.duration_mult)
					Vfx.column(world.fx_root, h.position, col)
		"wheel":

			for i in 2:
				tarot(world, p, _draw_card(true))
	if log_on:
		print("ENS tarot hero=%d card=%s near=%d hit=%.0f" % [p.slot, card, near.size(), hit])



static func _draw_card(no_wheel: bool) -> String:
	var total: = 0.0
	for k in GameData.TAROT_CARDS:
		if not (no_wheel and k == "wheel"):
			total += float(GameData.TAROT_CARDS[k].w)
	var r: = randf() * total
	for k in GameData.TAROT_CARDS:
		if no_wheel and k == "wheel":
			continue
		r -= float(GameData.TAROT_CARDS[k].w)
		if r <= 0.0:
			return k
	return "tower"



static func card_show(world: World, p: Player, card: String, at: Vector3) -> void :
	if world.net != null and world.net.recording():
		world.net.record(["bd", "tarot", world.net.ref_of(p), card, at])
	_card_look(world, p, card, at)


static var _card_tex: = {}
static var _note_tex: = {}






static func note_tex(key: String, col: Color) -> Texture2D:
	var k: = "%s|%s" % [key, col.to_html()]
	if _note_tex.has(k):
		return _note_tex[k]
	var src: = RoAssets.effect_tex(key)
	if src == null:
		return null
	var img: = src.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var dark: = col.darkened(0.6)
	var light: = col.lightened(0.7)
	for y in img.get_height():
		for x in img.get_width():
			var c: = img.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var t: = clampf((c.get_luminance() - 0.2) / 0.8, 0.0, 1.0)
			var out: = dark.lerp(col, clampf(t * 2.0, 0.0, 1.0)) if t < 0.5 else col.lerp(light, (t - 0.5) * 2.0)
			img.set_pixel(x, y, Color(out, c.a))
	var tex: = ImageTexture.create_from_image(img)
	_note_tex[k] = tex
	return tex




static func _card_texture(card: String) -> Texture2D:
	if _card_tex.has(card):
		return _card_tex[card]
	var path: = "res://assets/brand/tarot/%s.png" % card
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_card_tex[card] = tex
	return tex




static func _card_look(world: World, p: Node3D, card: String, at: Vector3) -> void :
	if Vfx.hidden() or p == null or not is_instance_valid(p):
		return
	var c: Dictionary = GameData.TAROT_CARDS[card]
	var col: Color = c.color
	var root: = Node3D.new()
	world.fx_root.add_child(root)

	root.position = p.position + Vector3(1.4, 3.6, 0)
	var s: = Sprite3D.new()
	s.texture = _card_texture(card)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = GameData.HERO_FX_PRIORITY + 2

	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	s.pixel_size = GameData.PIXEL_SIZE * 0.55
	root.add_child(s)



	if p == world.player:
		var said: Dictionary = p.get_meta("tarot_said", {})
		if not said.has(card):
			said[card] = true
			p.set_meta("tarot_said", said)
			world.hud.announce(TranslationServer.translate(str(c.name)), col.lightened(0.2), 
				TranslationServer.translate(str(c.get("say", ""))))
	s.modulate.a = 0.0

	s.scale = Vector3(0.05, 1.0, 1.0)
	var tw: = root.create_tween()
	tw.parallel().tween_property(s, "modulate:a", maxf(0.6, Vfx.dim), 0.15)
	tw.parallel().tween_property(s, "scale", Vector3(1.0, 1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(root, "position:y", root.position.y + 0.3, 0.3)
	tw.tween_interval(0.5)

	tw.tween_property(root, "position", at + Vector3(0, 1.0, 0), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(s, "scale", Vector3(0.6, 0.6, 1.0), 0.22)
	tw.tween_callback( func():
		if is_instance_valid(world) and is_instance_valid(world.fx_root):
			var was: = Vfx._quiet
			Vfx._quiet = true
			Vfx.burst(world.fx_root, at, 2.0, col)
			Vfx.ring(world.fx_root, at, 2.4, Color(col, 0.9), 0.35)
			Vfx._quiet = was
		root.queue_free())





var cur: = {}

var on: = false
var _next: = 0
var _gap: = 0.0
var _serial: = 0
var _sieg_serial: = -1
var _apply_t: = 0.0
var _lost: = 0.0

var stats: = {}
var _t_sent: = 0.0

var _saved: = {}
var _center: = Vector3.ZERO
var _node: Node3D
var _label: Label3D
var _shown_s: = -1
var _beat_seen: = -1
var _last_time: = 0.0
var _log_t: = 0.0


func clear() -> void :
	cur = {}
	on = false
	_next = 0
	_gap = 0.0
	_saved.clear()
	_sieg_serial = -1
	_hide()




func _pair(world: World) -> Array:
	var bard: Player = null
	var dancer: Player = null
	for h in world.heroes:


		if h.downed or not is_instance_valid(h) or (h.songs.is_empty() and cur.is_empty()):
			continue
		var kind: = h.performer()
		if kind == "song" and bard == null:
			bard = h
		elif kind == "dance" and dancer == null:
			dancer = h
	if bard == null or dancer == null:
		return []
	var keep: = GameData.ENS_PAIR_RANGE + (2.0 if not cur.is_empty() else 0.0)
	if _flat(bard.position, dancer.position) > keep:
		return []
	return [bard, dancer]


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()



func tick(world: World, delta: float) -> void :
	if world.time < _last_time - 1.0:
		clear()
	_last_time = world.time
	if tether_on:
		_tether(world)
		_siegfried_test(world)
	var pair: = _pair(world)
	if not cur.is_empty():
		if pair.is_empty() or pair[0] != cur.a or pair[1] != cur.b:

			_lost += delta
			cur.t = float(cur.t) - delta
			if _lost >= GameData.ENS_LOST or float(cur.t) <= 0.0:
				if log_on:
					print("ENS lost the pair: %s" % ("apart/down" if pair.is_empty() else "another pair"))
				_end(world)
		else:
			_lost = 0.0
			cur.t = float(cur.t) - delta
			_center = (pair[0].position + pair[1].position) * 0.5
			_apply_t -= delta
			if _apply_t <= 0.0:
				_apply_t = 0.5
				_give(world)
			_t_sent -= delta
			if _t_sent <= 0.0 and world.net != null and world.net.recording():
				_t_sent = 1.0
				world.net.record(["bd", "t", snappedf(float(cur.t), 0.1)])
			if float(cur.t) <= 0.0:
				_end(world)
	elif not pair.is_empty():
		_gap -= delta
		if _gap <= 0.0:
			_start(world, pair)
	else:
		_gap = minf(_gap, 1.0)
	_draw(world)
	if log_on and not cur.is_empty():
		_log_t -= delta
		if _log_t <= 0.0:
			_log_t = 2.0
			var who: = []
			for h in world.heroes:
				who.append("%d:%s in=%s dmg=%.2f armor=%.1f" % [h.slot, h.party_buffs.keys(), _flat(h.position, _center) <= GameData.ENS_RADIUS, 
					h.dmg_mult, h.armor])
			print("ENS host %s t=%.1f %s" % [cur.id, float(cur.t), who])


func _start(world: World, pair: Array) -> void :
	var id: String = GameData.ENS_ORDER[_next % GameData.ENS_ORDER.size()]
	_next += 1
	_serial += 1
	if id == "ens_siegfried":
		_sieg_serial = _serial
	cur = {"id": id, "a": pair[0], "b": pair[1], "t": GameData.ENS_TIME, "ext": 0.0}
	on = true
	_lost = 0.0
	_apply_t = 0.0
	_t_sent = 1.0
	_center = (pair[0].position + pair[1].position) * 0.5
	if world.net != null and world.net.recording():
		world.net.record(["bd", "ens", id, (pair[0] as Player).slot, (pair[1] as Player).slot, GameData.ENS_TIME])
	_announce(world, id, true)
	_give(world)
	_shot(world, "%d_%s" % [_serial, id])
	if log_on:
		print("ENS start %s bard=%d dancer=%d at=%s" % [id, pair[0].slot, pair[1].slot, _center])




func _announce(world: World, id: String, host: bool) -> void :
	var s: Dictionary = GameData.SKILLS[id]
	world._play_song(str(s.get("sound", "")), -4.0)
	_show(world, id)
	for h in [cur.get("a"), cur.get("b")]:
		if h != null and is_instance_valid(h):
			_pop(world, h, s, host)


static func _pop(world: World, h: Node3D, s: Dictionary, say: bool) -> void :

	var was: = Vfx._quiet
	Vfx._quiet = true
	Vfx.column(world.fx_root, h.position, s.color)
	Vfx.ring(world.fx_root, h.position, 2.4, Color(s.color, 0.9), 0.5)
	Vfx._quiet = was
	if say:
		world.number(h.position + Vector3(0, 2.8, 0), TranslationServer.translate(str(s.name)), s.color, true)


func _end(world: World) -> void :
	if log_on and not cur.is_empty():
		print("ENS end %s t=%.1f ext=%.1f stats=%s" % [cur.id, float(cur.t), float(cur.ext), stats])
	cur = {}
	on = false
	_gap = GameData.ENS_GAP
	if world.net != null and world.net.recording():
		world.net.record(["bd", "end"])
	_hide()



func _give(world: World) -> void :
	for h in world.heroes:
		if h.downed or not is_instance_valid(h):
			continue
		if _flat(h.position, _center) <= GameData.ENS_RADIUS + 0.5:
			h.receive_party_buff(str(cur.id), 1, 1.0, 1.0)


func inside(at: Vector3) -> bool:
	return _flat(at, _center) <= GameData.ENS_RADIUS



func chaos_has(e: Enemy) -> bool:
	return on and str(cur.get("id", "")) == "ens_eternal_chaos" and inside(e.position)




func hit_mult(src: Player, e: Enemy, source: String) -> float:
	var k: = 1.0
	if chaos_has(e):
		k *= 1.0 + GameData.ENS_CHAOS_DMG
		if log_on:
			stats["chaos_hits"] = int(stats.get("chaos_hits", 0)) + 1
	if source == "skill" and src != null and src.party_buffs.has("ens_nibelungen"):
		k *= GameData.ENS_NIBEL_SKILL
		if log_on:
			stats["nibel_hits_slot%d" % src.slot] = int(stats.get("nibel_hits_slot%d" % src.slot, 0)) + 1
	return k



func fill_mult(e: Enemy) -> float:
	return GameData.ENS_CHAOS_FILL if chaos_has(e) else 1.0



func on_kill(world: World, e: Enemy) -> void :
	if not on or str(cur.get("id", "")) != "ens_drum" or not inside(e.position) or float(cur.ext) >= GameData.ENS_DRUM_MAX:
		return
	var more: = minf(GameData.ENS_DRUM_KILL, GameData.ENS_DRUM_MAX - float(cur.ext))
	cur.t = float(cur.t) + more
	cur.ext = float(cur.ext) + more
	if log_on:
		stats["drum_kills"] = int(stats.get("drum_kills", 0)) + 1




func siegfried_save(world: World, p: Player) -> bool:
	if not p.party_buffs.has("ens_siegfried") or _sieg_serial < 0:
		return false
	var key: = p.get_instance_id()
	if int(_saved.get(key, -1)) == _sieg_serial:
		return false
	_saved[key] = _sieg_serial
	p.hp = maxf(1.0, p.max_hp * 0.3)
	p.siegfried_grace()
	var col: Color = GameData.SKILLS.ens_siegfried.color
	Vfx.column(world.fx_root, p.position, col)
	Vfx.ring(world.fx_root, p.position, 2.6, Color(col, 0.95), 0.5)
	world.spawn_fx("angelus", p.position, 0.9, 0.8, p)
	world.label_over(p, TranslationServer.translate("¡Siegfried!"), col.lightened(0.3))
	world.play_sound("angelus", 0.1, -4.0)
	if log_on:
		print("ENS siegfried saved hero=%d hp=%.0f" % [p.slot, p.hp])
	return true





func net_event(world: World, ev: Array) -> void :
	match str(ev[1]):
		"ens":
			var a: Player = world.heroes[int(ev[3])] if int(ev[3]) < world.heroes.size() else null
			var b: Player = world.heroes[int(ev[4])] if int(ev[4]) < world.heroes.size() else null
			if a == null or b == null:
				return
			cur = {"id": str(ev[2]), "a": a, "b": b, "t": float(ev[5]), "ext": 0.0}
			on = true
			_center = (a.position + b.position) * 0.5
			_announce(world, str(ev[2]), false)
			_serial += 1
			_shot(world, "%d_%s" % [_serial, str(ev[2])])
			if log_on:
				print("ENS client start %s bard=%d dancer=%d" % [ev[2], ev[3], ev[4]])
		"t":
			if not cur.is_empty():
				cur.t = float(ev[2])
		"end":
			if log_on and not cur.is_empty():
				print("ENS client end %s" % cur.id)
			cur = {}
			on = false
			_hide()
		"tarot":
			var who: = world._net_node(ev[2])
			if who != null:
				_card_look(world, who, str(ev[3]), ev[4])
				_serial += 1
				if _serial < 12:
					_shot(world, "tarot_%d_%s" % [_serial, str(ev[3])], 0.35)
				if log_on:
					print("ENS client tarot %s" % ev[3])



func client_tick(world: World, delta: float) -> void :
	if not cur.is_empty():
		cur.t = maxf(0.0, float(cur.t) - delta)
		if is_instance_valid(cur.a) and is_instance_valid(cur.b):
			_center = (cur.a.position + cur.b.position) * 0.5
	_draw(world)
	if log_on and not cur.is_empty():
		_log_t -= delta
		if _log_t <= 0.0:
			_log_t = 2.0
			var p: = world.player
			print("ENS client %s t=%.1f me=%d pbuffs=%s dmg=%.2f armor=%.1f" % [cur.id, float(cur.t), p.slot, p.party_buffs.keys(), p.dmg_mult, p.armor])


func _show(world: World, id: String) -> void :
	_hide()
	var s: Dictionary = GameData.SKILLS[id]
	var col: Color = s.color
	_node = Node3D.new()
	world.fx_root.add_child(_node)
	_node.position = _center
	var r: = GameData.ENS_RADIUS


	Vfx.ground_glow(_node, Vector3.ZERO, r + 0.3, Color(col, 0.14))
	var ring: = Node3D.new()
	ring.position.y = 0.45
	_node.add_child(ring)
	var turn: = ring.create_tween().set_loops()
	turn.tween_property(ring, "rotation:y", TAU, 14.0).as_relative()
	var count: = 14
	for k in count:
		var tex: = note_tex("melody_a" if k % 2 == 0 else "melody_b", col.lightened(0.15))
		var n3: = Sprite3D.new()
		n3.texture = tex
		n3.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		n3.shaded = false
		n3.no_depth_test = true
		n3.render_priority = 6
		n3.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		n3.pixel_size = GameData.PIXEL_SIZE
		var ang: = TAU * k / count
		n3.position = Vector3(cos(ang), 0.0, sin(ang)) * r
		ring.add_child(n3)
		var bob: = n3.create_tween().set_loops()
		bob.tween_interval(0.07 * k)
		bob.tween_property(n3, "position:y", 0.25, 0.45).set_trans(Tween.TRANS_SINE)
		bob.tween_property(n3, "position:y", 0.0, 0.45).set_trans(Tween.TRANS_SINE)
	_label = Label3D.new()
	_label.font = UiKit.FONT_TITLE
	_label.font_size = 40
	_label.pixel_size = 0.007
	_label.outline_size = 12
	_label.modulate = col.lightened(0.35)
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	_label.render_priority = 16
	_label.outline_render_priority = 15
	_label.position = Vector3(0, 3.4, 0)
	_node.add_child(_label)
	_shown_s = -1
	_node.scale = Vector3.ONE * 0.2
	var pop: = _node.create_tween()
	pop.tween_property(_node, "scale", Vector3.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _hide() -> void :
	if _node != null and is_instance_valid(_node):
		var old: = _node
		var tw: = old.create_tween()
		tw.tween_property(old, "scale", Vector3.ONE * 0.05, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(old.queue_free)
	_node = null
	_label = null



func _draw(world: World) -> void :
	if cur.is_empty() or _node == null or not is_instance_valid(_node):
		return
	_node.position = _center
	var secs: = ceili(float(cur.t))
	if secs != _shown_s and _label != null:
		_shown_s = secs
		_label.text = "%s  %d" % [TranslationServer.translate(str(GameData.SKILLS[cur.id].name)), maxi(0, secs)]
	var a = cur.get("a")
	if a != null and is_instance_valid(a) and int(a.beat_n) != _beat_seen:
		_beat_seen = int(a.beat_n)
		var big: = _beat_seen % GameData.BIS_EVERY == 0
		var tw: = _node.create_tween()
		tw.tween_property(_node, "scale", Vector3.ONE * (1.08 if big else 1.03), 0.08)
		tw.tween_property(_node, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_SINE)







static var tether_on: = "--ens-tether" in OS.get_cmdline_user_args()




func _siegfried_test(world: World) -> void :
	if cur.is_empty() or cur.id != "ens_siegfried" or float(cur.t) > GameData.ENS_TIME - 2.0 or int(stats.get("sieg_test", -1)) == _serial:
		return
	stats["sieg_test"] = _serial
	for h in world.heroes:
		if h.downed or not h.party_buffs.has("ens_siegfried"):
			continue
		var before: = h.hp
		h.set("_invuln", 0.0)
		h.take_damage(h.hp * 3.0, world, null, true)
		print("ENS siegtest hero=%d hp %.0f -> %.0f downed=%s" % [h.slot, before, h.hp, h.downed])
		var mid: = h.hp
		h.set("_invuln", 0.0)
		h.take_damage(200.0, world, null, true)
		print("ENS siegtest hero=%d mechanic of 200 took %.0f (halved)" % [h.slot, mid - h.hp])


static func _tether(world: World) -> void :
	var me: = world.player
	for h in world.heroes:
		if h != me and not h.downed and _flat(h.position, me.position) > 4.0:
			var to: = me.position + (h.position - me.position).normalized() * 3.0
			h.position = Vector3(to.x, world.map.height_at(to), to.z)






static func test_build(world: World, args: Array) -> void :

	for a in args:
		if str(a).begins_with("--jobwin-shot="):
			_jobwin_shot(world, str(a).substr(14))
			return
	var books: = PackedStringArray()
	for a in args:
		if str(a).begins_with("--bard-books="):
			books = str(a).substr(13).split(",", false)
	var at: = args.find("--path")
	var path: = int(args[at + 1]) if at >= 0 and args.size() > at + 1 else 1
	for i in world.heroes.size():
		var h: Player = world.heroes[i]
		if i < books.size():
			h.song_book = 1 if books[i] == "dances" else 0
		h.level = 90
		h.xp = 0.0
		h.xp_need = GameData.xp_to_next(h.level)
		if h.job2.is_empty():
			h.job_change(path if h == world.player or h.class_id != "archer" else 1)
		h.skills.clear()
		for id in (h.job2.get("skills", []) as Array) + (h.def.skills as Array):
			if GameData.SKILLS.has(id) and not h.skills.has(id) and h.count_skills(false) < h.max_skills():
				h.add_skill(str(id))
		for id in (h.job2.get("passives", []) as Array) + (h.def.get("passives", []) as Array):
			if GameData.SKILLS.has(id) and not h.skills.has(id) and h.count_skills(true) < h.max_passives():
				h.add_skill(str(id))
		for id in h.skills:
			h.skills[id].level = GameData.MAX_SKILL_LEVEL
		for id in h.skills.keys():
			if GameData.EVOLUTIONS.has(id):
				h.evolve(id)
		for st in h.stats:
			h.stats[st] = 40
		h.stats["str"] = 80
		h.stats["int"] = 80
		h.recompute()
		h.hp = h.max_hp
		print("KIT hero=%d job=%s book=%s skills=%s hp=%.0f" % [h.slot, h.job_name(), h.performer(), h.skills.keys(), h.max_hp])


static func _jobwin_shot(world: World, dir: String) -> void :
	var p: = world.player
	await world.get_tree().create_timer(0.5, true, false, true).timeout
	for pick in [-1, 1, 0]:
		if pick >= 0:
			p.song_book = pick
		world.menus.auto_pick = false
		world.menus.show_job_change()
		await world.get_tree().create_timer(1.2, true, false, true).timeout
		var path: = "%s/jobwin_%s.png" % [dir, {-1: "gender", 1: "dances", 0: "songs"}[pick]]
		world.get_viewport().get_texture().get_image().save_png(path)
		print("ENS shot %s skills=%s" % [path, p.next_job(1).skills])
	world.get_tree().quit()
