extends RefCounted













const FORMAT: = 1

const PACK_MARK: = "MSB1."
const ICON_ROOT: = "res://assets/ro/ui/skin/"



static func make(w: World, victory: bool) -> Dictionary:
	return new()._make(w, victory)


func _make(w: World, victory: bool) -> Dictionary:
	var p: Player = w.player
	if p == null or not is_instance_valid(p):
		return {}
	var m = w.menus
	var hud = w.hud
	var cid: = p.class_id
	var doc: = {"f": FORMAT, "ver": str(Updater.version), "lang": TranslationServer.get_locale(), "at": int(Time.get_unix_time_from_system())}

	var job_id: = str(p.job2.get("id", ""))
	doc["hero"] = {"name": Save.char_name(cid).strip_edges().substr(0, 24), "class": cid, "class_name": tr(str(p.def.get("name", cid))), 
		"job": job_id, "title": p.job_name(), "female": p.female(), "reborn": p.reborn, "rebirth": Save.rebirth_lv(cid), 
		"rebirth_name": GameData.rebirth_name(Save.rebirth_lv(cid)) if Save.rebirth_lv(cid) > 0 else "", 
		"level": p.level, "class_level": int(Save.class_progress(cid).get("level", 0)), "icon": _icon(m._friend_job_icon(cid, job_id))}
	doc["run"] = _run(w, p, victory)
	doc["stats"] = _stats(p)
	doc["sheet"] = []
	for r in m.stat_rows(p):
		doc.sheet.append([str(r[0]), str(r[1]), str(r[2]) if r.size() > 2 else "", bool(r[3]) if r.size() > 3 else false, 
			str(r[4]) if r.size() > 4 else ""])
	doc["gear"] = _gear(p, m)
	doc["start"] = _start(w, p, m)
	doc["skills"] = []
	for id in p.skills:
		if GameData.SKILLS.has(id):

			doc.skills.append({"id": str(id), "lv": int(p.skills[id].level), "evolved": bool(GameData.SKILLS[id].get("evolved", false)), 
				"off": p.skill_off.has(Player.base_skill(str(id))), "card": _c(hud._skill_hover(id))})




	hud._refresh_pacts()
	doc["buffs"] = _hud_row(hud._pact_row)
	hud._refresh_oaths()
	doc["oaths"] = _hud_row(hud._oath_row)

	var counts: = {}
	var order: = []
	for c in p.cards:
		if not counts.has(c):
			order.append(c)
		counts[c] = int(counts.get(c, 0)) + 1
	doc["cards"] = []
	for c in order:
		if GameData.CARDS.has(str(c)):
			doc.cards.append({"id": str(c), "n": int(counts[c]), "card": _c(hud._card_hover(str(c), int(counts[c])))})

	doc["album"] = []
	for c in p.album_cards:
		if GameData.CARDS.has(str(c)):
			doc.album.append({"id": str(c), "card": _c(m._card_hover(str(c)))})
	doc["extra"] = _extra(w, p, m)




	doc["copies"] = []
	for id in p._copied():
		if GameData.SKILLS.has(str(id)):
			doc.copies.append(_c(w.hud._skill_hover(str(id))))
	doc["auto"] = _auto(p)
	doc["bonus"] = _bonus(p)
	doc["dmg"] = _damage(w)
	return doc









func _auto(p: Player) -> Dictionary:
	var order: = p.pick_order()
	var limits: = p.pick_limits()
	var bans: = p.pick_bans()
	var ids: = []
	var mine: = []
	for id in p.skills:
		var b: = Player.base_skill(str(id))
		if GameData.SKILLS.has(b) and not mine.has(b):
			mine.append(b)
	for id in order:
		if (mine.has(str(id)) or GameData.STATS.has(str(id))) and not ids.has(str(id)):
			ids.append(str(id))
	for id in mine:
		if not ids.has(id):
			ids.append(id)
	for id in GameData.STATS:
		if not ids.has(str(id)):
			ids.append(str(id))
	var rows: = []
	for id in ids:
		var stat: bool = GameData.STATS.has(id)
		var out: = p.banished.has(("stat:" if stat else "skill:") + id) or p.banished.has("evolve:" + id + "_x")
		rows.append({"id": id, "name": _auto_name("stat" if stat else "skill", id), "stat": stat, 
			"icon": "" if stat else _file_icon("skill_icons", id), "lim": int(limits.get(id, 0)), "ban": bans.has(id), "out": out, 
			"fav": p.run_favs.has(id)})
	var gone: = []
	for key in p.banished:
		var kind: = str(key).get_slice(":", 0)
		var id: = str(key).get_slice(":", 1)
		gone.append({"name": _auto_name(kind, id), "icon": _file_icon("skill_icons", Player.base_skill(id)) if kind in ["skill", "evolve"] else ""})

	var favs: = []
	for id in p.run_favs:
		favs.append({"name": _auto_name("skill", str(id)), "icon": _file_icon("skill_icons", str(id))})
	return {"fill": p.pick_fill(), "custom": not order.is_empty() or not limits.is_empty() or not bans.is_empty() or not favs.is_empty(), 
		"rows": rows, "gone": gone, "favs": favs}


func _auto_name(kind: String, id: String) -> String:
	if kind == "stat" and GameData.STATS.has(id):
		return tr(str(GameData.STATS[id].get("full", GameData.STATS[id].name)))
	if GameData.SKILLS.has(id):
		return tr(str(GameData.SKILLS[id].name))
	if GameData.CARDS.has(id):
		return tr(str(GameData.CARDS[id].name))
	return id



func _run(w: World, p: Player, victory: bool) -> Dictionary:
	var tower_floor: = 0
	var hel: = false
	if w.tower != null and is_instance_valid(w.tower):
		tower_floor = int(w.tower.best)
		hel = w.tower.hel != null
	var death: = ""
	if not p.death_by.is_empty() and ( not victory or p.fell or p.hp <= 0.0 or p.downed):
		var who: = str(p.death_by.get("by", ""))
		var what: = str(p.death_by.get("what", ""))
		death = tr(who) if who != "" else (tr(what) if what != "" else tr("Los monstruos"))
		if who != "" and what != "":
			death = "%s  ·  %s" % [tr(who), tr(what)]
	var route: = str(w.karma.path) if w.karma != null else ""
	return {"stage": w.stage_id, "stage_name": tr(str(w.stage.name)), "danger": w.danger, "danger_name": GameData.danger_name(w.danger), 
		"hard": w.hard, "frenzy": w.frenzy, "endless": w.endless, "tower": tower_floor, "hel": hel, "festival": w.festival != null, 
		"victory": victory, "fell": p.fell, "time": roundi(w.time), "kills": w.kills, "zeny": w.run_zeny, "mvps": w.run_mvps, 
		"x2_s": roundi(w.run_fast_s), "party": w.heroes.size(), "route": route, "oath": w.oath_points(), "death": death}




func _stats(p: Player) -> Array:
	var out: = []
	for k in GameData.STATS:
		var d: Dictionary = GameData.STATS[k]
		out.append({"id": str(k), "name": tr(str(d.name)), "full": tr(str(d.get("full", d.name))), "value": int(p.stats.get(k, 0)), 
			"base": int(p.base_stats.get(k, 0)), "eff": roundi(p.eff_stat(str(k))), "desc": tr(str(d.get("desc", "")))})
	return out




func _gear(p: Player, m) -> Array:
	var out: = []
	for k in m.LOADOUT_ORDER:
		var it = p.equipment.slots.get(k)
		if it == null:
			continue
		var card: = _c(m._item_hover(it))

		if str(card.get("icon", "")) == "" and Equipment.is_soul(it):
			var src: Dictionary = GameData.ITEMS.get(str(Equipment.item_def(it).get("soul_of", "")), {})
			card["icon"] = "item_icons/" + str(src.get("icon", ""))
			card["soul"] = true
		var cards: = []
		for c in it.get("cards", []):
			if GameData.CARDS.has(str(c)):
				cards.append(_c(m._card_hover(str(c))))
		out.append({"slot": str(k), "slot_name": m._kafra_slot_name(str(k)), "id": str(it.get("id", "")), "refine": int(it.get("refine", 0)), 
			"sockets": Equipment.sockets(it), "eternal": int(it.get("eternal_n", 0)), "perm": Equipment.is_perm(it), "item": card, "cards": cards})
	return out






func _start(w: World, p: Player, m) -> Array:
	var out: = []
	if (w.tower != null and is_instance_valid(w.tower)) or w.festival != null or w.training:
		return out
	var lo: Dictionary = Save.loadout(p.class_id)
	for k in m.LOADOUT_ORDER:
		if not lo.has(k):
			continue
		var stored: Dictionary = Save.storage_item(str(lo[k]))
		if stored.is_empty() or not GameData.ITEMS.has(str(stored.get("id", ""))):
			continue
		var it: = Equipment.from_storage(stored)
		var cards: = []
		for c in it.get("cards", []):
			if GameData.CARDS.has(str(c)):
				cards.append(_c(m._card_hover(str(c))))
		out.append({"slot": str(k), "slot_name": m._kafra_slot_name(str(k)), "id": str(it.id), "sockets": Equipment.sockets(it), 
			"item": _c(m._item_hover(it)), "cards": cards})
	return out




func _extra(w: World, p: Player, m) -> Array:
	var out: = []
	if GameData.PETS.has(p.pet_id):
		var pet: Dictionary = GameData.PETS[p.pet_id]
		var look: = ""
		if p.pet_skin != "" and p.pet_skin != p.pet_id and GameData.PETS.has(p.pet_skin):
			look = tr("Aspecto: %s") % tr(str(GameData.PETS[p.pet_skin].name))
		out.append({"title": tr(str(pet.name)), "tag": tr("Mascota"), "icon": _file_icon("item_icons", str(pet.get("tame", ""))), 
			"rim": "#b0507a", "ink": "#7a2a50", "desc": tr(str(pet.get("desc", ""))), "foot": [[look, "#4a3f60"]] if look != "" else []})
	if p.homun_type != "" and GameData.HOMUNCULI.has(p.homun_type):
		var h: Dictionary = GameData.HOMUNCULI[p.homun_type]
		out.append({"title": tr(str(h.get("name", p.homun_type))), "tag": tr("Homúnculo"), "icon": _file_icon("skill_icons", str(h.get("icon", "call_homunculus"))), 
			"rim": "#3a6fa8", "ink": "#1f4a7a", "desc": tr(str(h.get("desc", "")))})
	for id in p.toys:
		if GameData.MORROC_TOYS.has(str(id)):
			var t: Dictionary = GameData.MORROC_TOYS[str(id)]
			out.append({"title": tr(str(t.name)) + ("  x%d" % int(p.toys[id]) if int(p.toys[id]) > 1 else ""), "tag": tr("Juguete de Morroc"), 
				"icon": _file_icon("skill_icons", str(t.get("icon", ""))), "rim": "#b03030", "ink": "#7a1818", "desc": tr(str(t.get("desc", "")))})
	if p.def.has("ammo") and p.ammo().has(p.arrow_id):
		var a: Dictionary = p.ammo()[p.arrow_id]
		var names: = []
		for q in p.quiver:
			if p.ammo().has(str(q)):
				names.append(tr(str(p.ammo()[str(q)].name)))
		var lines: = [[tr("Elemento"), tr(str(GameData.ELEMENT_NAMES.get(str(a.get("element", "neutral")), "")))]]
		if GameData.AMMO_DOT_NAMES.has(str(a.get("dot", ""))):
			lines.append([tr(str(GameData.AMMO_DOT_NAMES[str(a.dot)])), tr("%d%% por disparo") % roundi(float(GameData.AMMO_DOT[str(a.dot)]) * 100.0)])
		out.append({"title": tr(str(a.name)), "tag": tr(str(GameData.AMMO_NAMES.get(str(p.def.ammo), ""))), "icon": _file_icon("item_icons", p.arrow_id), 
			"rim": "#9a7a30", "ink": "#5a4410", "lines": lines, "desc": tr("Tipos: %s") % ", ".join(names)})
	var grown: = []
	if p.forge > 0:
		grown.append([tr("Forja"), str(p.forge)])
	if p.stew_hp > 0.0:
		grown.append([tr("Vida de Immortal Stew"), "+%d" % roundi(p.stew_hp)])
	if p.root_kills > 0:
		grown.append([tr("Vida de raíces"), "+%d" % roundi(p.root_hp)])
	if p.lg_bash_kills > 0:
		grown.append([tr("Muertes de Mysteltainn"), str(p.lg_bash_kills)])
	if p.soul_bonds > 0:
		grown.append([tr("Lazos de alma"), str(p.soul_bonds)])
	if p.revives > 0:
		grown.append([tr("Vidas extra"), str(p.revives)])
	if not grown.is_empty():
		out.append({"title": tr("Lo ganado en la partida"), "tag": "", "icon": "", "rim": "#3f8a52", "ink": "#1f5a2e", 
			"lines": grown.map( func(g): return [str(g[0]), str(g[1])])})
	return out






func _bonus(p: Player) -> Dictionary:
	var bs = load("res://scripts/ui/bonus_summary.gd")
	var sources: Array = bs.of_player(p)
	var rows_def: Array = bs.ROWS
	var cols: = sources.filter( func(s): return rows_def.any( func(rd): return absf(float((s[1] as Dictionary).get(rd[0], 0.0))) >= 0.0005))
	var out: = {"cols": cols.map( func(s): return str(s[0])), "rows": []}
	for rd in rows_def:
		var vals: = []
		var total: = 0.0
		for s in cols:
			var v: = float((s[1] as Dictionary).get(rd[0], 0.0))
			total += v
			vals.append(bs._value(rd, v) if absf(v) >= 0.0005 else "")
		if absf(total) >= 0.0005 or vals.any( func(x): return x != ""):
			out.rows.append([TranslationServer.translate(str(rd[1])), vals, bs._value(rd, total)])
	return out




func _damage(w: World) -> Dictionary:
	var st: Dictionary = w.meter_stats
	var total: = float(st.get("total", 0.0))
	var best_tag: = str(st.get("best_tag", ""))
	var d: = {"total": total, "dps": total / maxf(1.0, w.time), "best": float(st.get("best", 0.0)), 
		"best_by": w.meter_label(best_tag) if best_tag != "" else "", "hits": int(st.get("hits", 0)), "crits": int(st.get("crits", 0)), 
		"taken": float(st.get("taken", 0.0)), "healed": float(st.get("healed", 0.0))}
	d["rows"] = _meter(w, "damage")
	d["taken_rows"] = _meter(w, "taken")
	d["heal_rows"] = _meter(w, "heal")
	var bosses: = []
	for id in w.meter_boss:
		var b: Dictionary = w.meter_boss[id]
		var tags: = []
		for t in b.get("tags", {}):
			tags.append([w.meter_label(str(t)), float(b.tags[t]), _icon(w.meter_icon(str(t)))])
		tags.sort_custom( func(x, y): return float(x[1]) > float(y[1]))
		var sum: = 0.0
		for t in tags:
			sum += float(t[1])
		bosses.append({"name": tr(str(GameData.MONSTERS.get(str(id), {}).get("name", id))), "mvp": bool(b.get("mvp", false)), 
			"dmg": float(b.get("dmg", sum)), "tags": tags.slice(0, 12)})
	bosses.sort_custom( func(x, y): return float(x.dmg) > float(y.dmg))
	d["bosses"] = bosses.slice(0, 12)
	return d


func _meter(w: World, mode: String) -> Array:
	var out: = []


	for r in (w.meter_sorted() if mode == "damage" else w._meter_rows_all(mode)):
		var tag: = str(r.get("tag", ""))
		var label: String = w.taken_label(tag) if mode == "taken" else (w.heal_label(tag) if mode == "heal" else w.meter_label(tag))
		var row: = {"label": label, "dmg": float(r.get("dmg", 0.0)), "hits": int(r.get("hits", 0))}
		if mode == "damage":
			row["icon"] = _icon(w.meter_icon(tag))
			row["crits"] = int(r.get("crits", 0))
			row["max"] = float(r.get("max", 0.0))
			row["kills"] = int(r.get("kills", 0))
			row["boss"] = float(r.get("boss", 0.0))
			row["el"] = str(r.get("el", ""))
		elif mode == "taken":
			row["max"] = float(r.get("max", 0.0))
		out.append(row)
	return out



func _hud_row(row: Node) -> Array:
	var out: = []
	if row == null or not is_instance_valid(row):
		return out
	for c in row.get_children():
		if c.is_queued_for_deletion() or not c.has_meta("hover_build"):
			continue
		var info = (c.get_meta("hover_build") as Callable).call()
		if info is Dictionary and not (info as Dictionary).is_empty():
			out.append(_c(info))
	return out




func _c(info: Dictionary) -> Dictionary:


	var col: Color = info.get("color", HoverCard.DEFAULT_COLOR) if info.get("color") is Color else HoverCard.DEFAULT_COLOR
	var out: = {"title": str(info.get("title", "")), "tag": str(info.get("tag", "")), "rim": _hex(HoverCard.rim(col)), "ink": _ink(col), 
		"icon": _icon(info.get("icon")), "desc": str(info.get("desc", ""))}
	var lines: = []
	for ln in info.get("lines", []):
		var row: = [str(ln[0]), str(ln[1])]
		if ln.size() > 2 and ln[2] is Color:
			row.append(_ink(ln[2]))
		lines.append(row)
	if not lines.is_empty():
		out["lines"] = lines
	var chips: = []
	for ch in info.get("chips", []):
		var bg: Color = ch[1] if ch[1] is Color else HoverCard.CHIP_GREY
		var i: = 0
		while bg.srgb_to_linear().get_luminance() > 0.17 and i < 12:
			bg = bg.darkened(0.08)
			i += 1
		chips.append([str(ch[0]), _hex(bg)])
	if not chips.is_empty():
		out["chips"] = chips
	var foot: = []
	for f in info.get("foot", []):
		if f.size() > 2 and f[2] == true:
			continue
		foot.append([str(f[0]), _ink(f[1]) if f.size() > 1 and f[1] is Color else _hex(HoverCard.INK)])
	if not foot.is_empty():
		out["foot"] = foot
	if info.get("set") is Dictionary and not (info.set as Dictionary).is_empty():
		var s: Dictionary = info.set
		var pieces: = []
		for pc in s.get("pieces", []):
			pieces.append({"name": str(pc.get("name", "")), "icon": _icon(pc.get("icon")), "have": bool(pc.get("have", false))})
		out["set"] = {"name": str(s.get("name", "")), "build": str(s.get("build", "")), "pieces": pieces, "desc": str(s.get("desc", "")), 
			"desc4": str(s.get("desc4", "")), "active": bool(s.get("active", false)), "active4": bool(s.get("active4", false))}

	if info.get("harmony") is Dictionary and not (info.harmony as Dictionary).is_empty():
		var hinfo = load("res://scripts/ui/harmony_view.gd").hover_info(info.harmony)
		if hinfo is Dictionary and not (hinfo as Dictionary).is_empty():
			out["harmony"] = _c(hinfo)
	if info.has("icon_size"):
		out["big"] = float(info.icon_size) > 36.0
	return out




func _icon(tex) -> String:
	if not tex is Texture2D:
		return ""
	var path: = str((tex as Texture2D).resource_path)
	if not path.begins_with(ICON_ROOT):
		return ""
	return path.trim_prefix(ICON_ROOT).get_basename()


func _file_icon(folder: String, id: String) -> String:
	if id == "" or not ResourceLoader.exists(ICON_ROOT + folder + "/" + id + ".png"):
		return ""
	return folder + "/" + id


func _ink(c) -> String:
	return _hex(HoverCard.ink(c)) if c is Color else _hex(HoverCard.INK)


func _hex(c) -> String:
	return "#" + (c as Color).to_html(false) if c is Color else "#1a1f33"




static func pack(doc: Dictionary) -> String:
	if doc.is_empty():
		return ""
	var raw: = JSON.stringify(doc).to_utf8_buffer()
	var z: = raw.compress(FileAccess.COMPRESSION_GZIP)
	return PACK_MARK + Marshalls.raw_to_base64(z).replace("+", "-").replace("/", "_").trim_suffix("=").trim_suffix("=")


static func unpack(text: String) -> Dictionary:
	if not text.begins_with(PACK_MARK):
		return {}
	var b: = text.trim_prefix(PACK_MARK).replace("-", "+").replace("_", "/")
	while b.length() % 4 != 0:
		b += "="
	var z: = Marshalls.base64_to_raw(b)
	if z.is_empty():
		return {}
	var raw: = z.decompress_dynamic(4 * 1024 * 1024, FileAccess.COMPRESSION_GZIP)
	var d = JSON.parse_string(raw.get_string_from_utf8())
	return d if d is Dictionary else {}






static func _store_path() -> String:
	return Save.PATH.get_basename() + ".builds"



static var _mem: = {}
static var _mem_ms: = -100000


static func _store() -> Dictionary:
	if Time.get_ticks_msec() - _mem_ms < 3000:
		return _mem
	var d = {}
	var f: = FileAccess.open(_store_path(), FileAccess.READ)
	if f != null:
		d = JSON.parse_string(f.get_as_text())
	_mem = d if d is Dictionary else {}
	_mem_ms = Time.get_ticks_msec()
	return _mem


static func keep(at: int, packed: String) -> void :
	if packed == "":
		return
	var d: = _store()
	d[str(at)] = packed
	var alive: = {}
	for r in Save.history():
		alive[str(int(r.get("at", 0)))] = true
	alive[str(at)] = true
	for k in d.keys():
		if not alive.has(k):
			d.erase(k)
	var text: = JSON.stringify(d)
	var f: = FileAccess.open(_store_path(), FileAccess.WRITE)
	if f != null:
		f.store_string(text)
	_mem = d
	_mem_ms = Time.get_ticks_msec()


static func kept(at: int) -> String:
	return str(_store().get(str(at), ""))






const SHARE_URL: = "https://relay.midgardsurvivors.com/b"
static var _codes: = {}


static func share_url() -> String:

	for a in OS.get_cmdline_user_args():
		if a.begins_with("--relay="):
			return a.trim_prefix("--relay=").replace("wss://", "https://").replace("ws://", "http://").trim_suffix("/") + "/b"
	return SHARE_URL


static func upload(host: Node, packed: String, done: Callable) -> void :
	if _codes.has(packed):
		done.call(str(_codes[packed]))
		return
	var http: = HTTPRequest.new()
	http.timeout = 15.0
	host.add_child(http)
	http.request_completed.connect( func(result: int, status: int, _h: PackedStringArray, body: PackedByteArray):
		http.queue_free()
		var code: = ""
		if result == HTTPRequest.RESULT_SUCCESS and status == 200:
			var d = JSON.parse_string(body.get_string_from_utf8())
			if d is Dictionary:
				code = str(d.get("code", ""))
		if code != "":
			_codes[packed] = code
		done.call(code), CONNECT_ONE_SHOT)
	if http.request(share_url(), PackedStringArray(["Content-Type: text/plain; charset=utf-8"]), HTTPClient.METHOD_POST, packed) != OK:
		http.queue_free()
		done.call("")
