class_name Equipment
extends RefCounted


const Potential = preload("res://scripts/core/potential.gd")







var class_id: = ""

var job_id: = ""


var soul_open: = true


var book: = ""

var slots: = {}

var bag: Array = []


var bag_max: int = GameData.INVENTORY_MAX

var card_bag: Array[String] = []

var legend_found: = 0

var legend_bonus: = 0.0
var ores: = {"oridecon": 0, "elunium": 0}


var ores_found: = {"oridecon": 0, "elunium": 0}

var offhand_share: = GameData.OFFHAND_SHARE



var left_waiting = null



var auto_upgrade: = true

var last_coins: = 0


var coins_here: = true


func _init(p_class: String) -> void :
	class_id = p_class
	for k in GameData.EQUIP_SLOTS:
		slots[k] = null
	slots["weapon"] = make(class_weapon(), 0)



static func head_view_of(it) -> String:
	if not it is Dictionary or it.is_empty():
		return ""
	var key: = str(item_def(it).get("view", ""))
	return key if key != "" and RoAssets.has_sprite(key) else ""




static func shield_view_of(it, body: String) -> String:
	if not it is Dictionary or it.is_empty():
		return ""
	for v in [str(item_def(it).get("view", "shield")), "shield", "buckler", "guard"]:
		var key: = "shield_%s_%s" % [v, body]
		if RoAssets.has_sprite(key):
			return key
	return ""




static func robe_view_of(it, body: String) -> String:
	if not it is Dictionary or it.is_empty():
		return ""
	var view: = str(item_def(it).get("view", ""))
	var key: = "robe_%s_%s" % [view, body]
	return key if view != "" and RoAssets.has_sprite(key) else ""






static func extra_views(items: Dictionary, body: String, costume: Dictionary = {}, alt_body: = "") -> Array:
	var out: Array = []
	for slot in ["mid", "low", "acc1", "acc2"]:
		if str(costume.get(slot, "")) == GameData.COSMETIC_HIDE:
			continue


		if slot.begins_with("acc") and str(costume.get("mid", "")) == GameData.COSMETIC_HIDE:
			continue
		var face: = cosmetic_view(str(costume[slot])) if costume.has(slot) else ""
		if face == "":
			face = head_view_of(items.get(slot))
		if face != "" and not out.has(face):
			out.append(face)


	if str(costume.get("back", "")) == GameData.COSMETIC_HIDE:
		return out
	var robe: = ""


	for b in [body, alt_body]:
		if robe != "" or b == "":
			continue
		robe = cosmetic_robe(str(costume.get("back", "")), b)
		if robe == "":
			robe = robe_view_of(items.get("wings"), b)
		if robe == "":
			robe = robe_view_of(items.get("garment"), b)
	if robe != "":
		out.append(robe)
	return out



static func cosmetic_view(id: String) -> String:
	var d: Dictionary = GameData.COSMETICS.get(id, {})
	var key: = str(d.get("view", ""))
	return key if key != "" and str(d.get("slot", "")) != "back" and RoAssets.has_sprite(key) else ""



static func cosmetic_robe(id: String, body: String) -> String:
	var d: Dictionary = GameData.COSMETICS.get(id, {})
	if str(d.get("slot", "")) != "back":
		return ""
	var key: = "robe_%s_%s" % [str(d.view), body]
	return key if RoAssets.has_sprite(key) else ""






static func loadout_views(class_id: String) -> Dictionary:
	var lo: = Save.loadout(class_id)
	var items: = {}
	for slot in lo:
		items[slot] = Save.storage_item(str(lo[slot]))
	return views_of(items, class_id, Save.worn_cosmetics(class_id), Save.look(class_id))







static func views_of(items: Dictionary, class_id: String, costume: Dictionary = {}, look = null) -> Dictionary:
	var base: = str(GameData.CLASSES.get(class_id, GameData.CLASSES.swordsman).body)
	var body: = base
	if look is Dictionary and GameData.CLASSES.has(class_id):
		body = str(GameData.shown_job(class_id, look).get("body", base))
	var sh = items.get("shield")
	var shield: = ""
	if sh is Dictionary and not (sh as Dictionary).is_empty() and item_type(sh) != "weapon":
		shield = shield_view_of(sh, body)
		if shield == "" and body != base:
			shield = shield_view_of(sh, base)
	var head = items.get("head")
	var top: = cosmetic_view(str(costume.get("top", "")))
	if top == "" and str(costume.get("top", "")) != GameData.COSMETIC_HIDE:
		top = head_view_of(head) if head is Dictionary and not (head as Dictionary).is_empty() else ""
	return {"head": top, "extras": extra_views(items, body, costume, base if body != base else ""), "shield": shield}



func gain_ore(id: String) -> void :
	ores[id] = int(ores.get(id, 0)) + 1
	ores_found[id] = int(ores_found.get(id, 0)) + 1



static func make(id: String, n_slots: int) -> Dictionary:
	var d: Dictionary = GameData.ITEMS.get(id, {})
	var it: = {"id": id, "slots": int(d.get("fixed_slots", n_slots)), "refine": 0, "cards": []}
	if d.get("fixed", false):
		it["perm"] = true
	return it




static func from_storage(stored: Dictionary) -> Dictionary:
	var it: Dictionary = stored.duplicate(true)
	it["perm"] = true
	it["slots"] = int(it.slots)
	it["refine"] = int(it.refine)

	it["cards"] = (stored.get("eternal", []) as Array).filter( func(c): return GameData.CARDS.has(c))
	it["eternal_n"] = (it.cards as Array).size()
	return it



static func is_face(it: Dictionary) -> bool:
	return bool(item_def(it).get("face", false))





static func card_kind(it: Dictionary) -> String:
	if is_face(it):
		return "" if item_type(it) == "low" else "head"
	return item_type(it)




static func card_fits(it: Dictionary, card: String) -> bool:
	if not GameData.CARDS.has(card):
		return false
	if item_def(it).get("wings", false):
		return GameData.is_mvp_card(card)
	return card_kind(it) == str(GameData.CARDS[card].get("type", ""))




static func wings_glow(it) -> Color:
	if not (it is Dictionary) or not item_def(it).get("wings", false):
		return Color(0, 0, 0, 0)
	for c in (it.get("eternal", []) as Array) + (it.get("cards", []) as Array):
		if GameData.is_mvp_card(str(c)):
			return GameData.mvp_card_color(str(c))
	return Color(0, 0, 0, 0)



static func slotless(it: Dictionary) -> bool:
	return (is_face(it) and item_type(it) == "low") or is_soul(it)


func class_weapon() -> String:
	var own: = str(GameData.CLASSES.get(class_id, {}).get("start_weapon", ""))
	if own != "":
		return own
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		if d.slot == "weapon" and d.get("class", "") == class_id:
			return id
	return "sword"


static func item_def(it: Dictionary) -> Dictionary:
	return GameData.ITEMS[it.id]



static func item_type(it: Dictionary) -> String:
	return item_def(it).slot




static func grade(it) -> int:
	if not it is Dictionary or (it as Dictionary).is_empty() or not gradable_kind(item_type(it)):
		return 0
	return clampi(int(it.get("grade", 0)), 0, GameData.WEAPON_GRADES.size() - 1)



static func grade_pity(it) -> int:
	if not it is Dictionary:
		return 0
	return clampi(int((it as Dictionary).get("grade_pity", 0)), 0, GameData.GRADE_PITY_MAX)







static func harmony_of(items: Dictionary) -> Dictionary:
	var n: = 0
	var graded: = 0
	var low: = 99
	var low_slot: = ""
	for k in GameData.HARMONY_SLOTS:
		var it = items.get(k)
		if not _harmony_piece(it):
			continue
		n += 1
		var g: = grade(it)
		if g > 0:
			graded += 1
		if g < low:
			low = g
			low_slot = k
	var lv: = low if n >= GameData.HARMONY_MIN_PIECES and low < 99 else 0
	return {"level": lv, "pieces": n, "graded": graded, "low": low_slot, "low_grade": low if low < 99 else 0}




static func _harmony_piece(it) -> bool:
	if not it is Dictionary or (it as Dictionary).is_empty() or not GameData.ITEMS.has(str((it as Dictionary).get("id", ""))):
		return false
	var kind: = item_type(it)
	return kind != "weapon" and GameData.GEAR_GRADES.has(kind) and not is_face(it)




static func harmony_mods(items: Dictionary, level: = -1) -> Dictionary:
	var out: = {}
	if level < 0:
		level = int(harmony_of(items).level)
	if level <= 0:
		return out
	var share: = float(GameData.HARMONY_SHARE[mini(level, GameData.HARMONY_SHARE.size() - 1)])
	for k in GameData.HARMONY_SLOTS:
		var it = items.get(k)
		if not _harmony_piece(it) or grade(it) <= 0:
			continue
		var gg: Dictionary = GameData.GEAR_GRADES[item_type(it)]
		for key in gg.keys:
			out[key] = float(out.get(key, 0.0)) + float(gg.vals[grade(it)]) * share
	return out



static func loadout_harmony(cid: String) -> Dictionary:
	var items: = {}
	var lo: Dictionary = Save.loadout(cid)
	for k in GameData.HARMONY_SLOTS:
		if lo.has(k):
			items[k] = Save.storage_item(str(lo[k]))
	return harmony_of(items)



static func item_name(it: Dictionary) -> String:
	var n: String = TranslationServer.translate(GameData.HEL_WINGS_NAME if hel_wings(it) else item_def(it).name)
	if int(it.refine) > 0:
		n = "+%d %s" % [it.refine, n]
	if sockets(it) > 0:
		n += " [%d]" % sockets(it)
	return n



static func hel_wings(it) -> bool:
	return it is Dictionary and bool((it as Dictionary).get("hel", false)) and item_def(it).get("wings", false)


static func item_color(it: Dictionary) -> Color:
	if hel_wings(it):
		return GameData.HEL_WINGS_COLOR
	if item_def(it).get("wings", false):
		return GameData.WINGS_COLOR
	if is_soul(it):
		return GameData.SOUL_COLOR
	if is_unique(it):
		return GameData.UNIQUE_COLOR
	if is_legendary(it):
		return GameData.LEGENDARY_COLOR
	return GameData.ITEM_TIERS[clampi(int(it.slots), 0, 3)].color




static func item_world_color(it: Dictionary) -> Color:
	if is_unique(it) or is_legendary(it) or item_def(it).get("wings", false):
		return item_color(it).lightened(0.15)
	return [Color(0.95, 0.95, 0.97), Color(0.5, 1.0, 0.55), Color(0.55, 0.78, 1.0), Color(0.88, 0.62, 1.0)][clampi(int(it.slots), 0, 3)]



static func is_perm(it: Dictionary) -> bool:
	return bool(it.get("perm", false))




static func found_face(it: Dictionary) -> bool:
	return is_perm(it) and not Save.storage_item(str(it.get("found_uid", ""))).is_empty()



static func can_sell(it: Dictionary) -> bool:
	return not is_perm(it) or found_face(it)


static func is_legendary(it: Dictionary) -> bool:
	return bool(item_def(it).get("legendary", false))




static func is_unique(it: Dictionary) -> bool:
	return bool(item_def(it).get("unique", false))



static func is_soul(it) -> bool:
	return it is Dictionary and GameData.ITEMS.get(str((it as Dictionary).get("id", "")), {}).has("soul_of")



static func item_effects(it: Dictionary) -> Dictionary:
	var d: = item_def(it)
	if d.has("soul_of"):
		return GameData.ITEMS.get(str(d.soul_of), {}).get("effects", {})
	return d.get("effects", {})



static func desc_of(it: Dictionary) -> String:
	var d: = item_def(it)
	var src: Dictionary = GameData.ITEMS.get(str(d.soul_of), d) if d.has("soul_of") else d
	return TranslationServer.translate(str(src.get("desc", "")))





func soul_active(it: Dictionary) -> bool:
	if not is_soul(it):
		return true
	if not soul_open:
		return false
	var src: = str(item_def(it).soul_of)
	var u: Dictionary = GameData.ITEMS.get(src, {})

	if has_item(src):
		return false
	if str(u.get("slot", "")) == "weapon":


		return usable_weapon(src)
	if u.has("class") and str(u. class ) != class_id and not (u.get("also_class", []) as Array).has(class_id):
		return false
	return not u.has("job") or (u.job as Array).has(job_id)



static func fee_mult(it: Dictionary) -> float:
	return GameData.UNIQUE_COST_MULT if is_unique(it) else 1.0




static func sockets(it: Dictionary) -> int:
	if slotless(it):
		return 0

	var wing: = 1 if item_def(it).get("wings", false) and int(it.get("refine", 0)) >= 5 else 0
	return int(it.slots) + int(it.get("extra_slots", 0)) + wing



static func socket_room(it: Dictionary) -> int:
	if slotless(it):
		return 0
	var cap: = GameData.SOCKET_MAX_LEGENDARY if is_legendary(it) else GameData.SOCKET_MAX_EXTRA
	return maxi(0, cap - int(it.get("extra_slots", 0)))




static func socket_price(it: Dictionary) -> Array:
	var extra: = int(it.get("extra_slots", 0))
	var weapon: = item_type(it) == "weapon"
	if is_legendary(it):
		var i: = clampi(extra, 0, GameData.SOCKET_COST_LEGENDARY.size() - 1)
		return [int(int(GameData.SOCKET_COST_LEGENDARY[i]) * fee_mult(it)), "enriched_oridecon" if weapon else "enriched_elunium", i + 1]
	return [int(GameData.SOCKET_COST[clampi(int(it.slots), 0, 3)]), "", 0]



static func socket_chance(it: Dictionary) -> float:
	if is_legendary(it):
		var i: = clampi(int(it.get("extra_slots", 0)), 0, GameData.SOCKET_CHANCE_LEGENDARY.size() - 1)
		return float(GameData.SOCKET_CHANCE_LEGENDARY[i])
	var r: = clampi(int(item_def(it).get("rank", 1)), 1, GameData.SOCKET_CHANCE.size())
	return float(GameData.SOCKET_CHANCE[r - 1])


static func free_slots(it: Dictionary) -> int:
	return sockets(it) - it.cards.size()


static func refinable(it: Dictionary) -> bool:
	return item_def(it).has("refine") and int(it.refine) < GameData.MAX_REFINE


static func ore_for(it: Dictionary) -> String:
	return "oridecon" if item_type(it) == "weapon" else "elunium"



func refinable_now() -> Array[String]:
	var out: Array[String] = []
	for k in slots:
		var it = slots[k]
		if it != null and refinable(it) and int(ores[ore_for(it)]) > 0:
			out.append(k)
	return out


static func refine_chance(it: Dictionary) -> float:
	var table: Array = GameData.REFINE_RATES[_rate_key(it)]
	return float(table[clampi(int(it.refine), 0, table.size() - 1)])



static func gradable_kind(kind: String) -> bool:
	return kind == "weapon" or GameData.GEAR_GRADES.has(kind)





static func item_mods(it: Dictionary, pot: = true) -> Dictionary:
	var out: = _base_mods(it, int(it.refine))
	if pot and it.has("pot"):
		var pm: = Potential.mods(it)
		for k in pm:
			out[k] = out.get(k, 0.0) + float(pm[k])




	if two_hands(it):
		for k in out:
			if float(out[k]) > 0.0:
				out[k] = float(out[k]) * (1.0 + GameData.TWO_HANDED_BONUS)

	var g: = grade(it)
	if g > 0 and item_type(it) == "weapon":
		out["grade_mult"] = out.get("grade_mult", 0.0) + float(GameData.WEAPON_GRADES[g].dmg)
	elif g > 0:

		var gg: Dictionary = GameData.GEAR_GRADES[item_type(it)]
		for k in gg.keys:
			out[k] = out.get(k, 0.0) + float(gg.vals[g])

	var card_k: = 1.0
	if item_def(it).get("wings", false):
		card_k += float(GameData.wing_fx(int(it.get("refine", 0))).get("wing_card", 0.0))
	for c in it.cards:
		var cm: Dictionary = GameData.CARDS[c].mods
		for k in cm:
			var v: = float(cm[k])
			out[k] = out.get(k, 0.0) + (v * card_k if v > 0.0 else v)
	return out



static func _base_mods(it: Dictionary, r: int) -> Dictionary:
	var out: = {}
	var d: = item_def(it)
	var mult: = float(GameData.ITEM_TIERS[clampi(int(it.slots), 0, 3)].mult)
	var grow: = 1.0 + GameData.REFINE_STAT_STEP * r if d.has("refine") else 1.0

	var hel: = hel_wings(it)
	for k in d.get("mods", {}):
		var v: = float(d.mods[k]) * mult
		if hel and v > 0.0 and not GameData.HEL_WINGS_KEEP.has(k):
			v *= GameData.HEL_WINGS_MULT
		var g: = grow
		if GameData.REFINE_SLOW_GROWTH.has(k) and d.has("refine"):
			g = 1.0 + GameData.REFINE_STAT_STEP * float(GameData.REFINE_SLOW_GROWTH[k]) * r

		out[k] = out.get(k, 0.0) + (v * g if v > 0.0 else v)
	for k in d.get("refine", {}):
		out[k] = out.get(k, 0.0) + float(d.refine[k]) * r
	var over: = r - refine_safe(it)
	if item_type(it) == "weapon" and over > 0:
		out["dmg"] = out.get("dmg", 0.0) + GameData.REFINE_OVER_DMG * over
	return out




static func refine_safe(it: Dictionary) -> int:

	var table: Array = GameData.REFINE_RATES[_rate_key(it)]
	var safe: = 0
	while safe < table.size() and float(table[safe]) >= 1.0:
		safe += 1
	return safe


static func _rate_key(it: Dictionary) -> String:
	return "w%d" % weapon_level(it) if item_type(it) == "weapon" else "armor"




static func weapon_level(it: Dictionary) -> int:
	var d: = item_def(it)
	if d.has("wlv"):
		return int(d.wlv)
	if d.get("legendary", false):
		return 4
	var rank: = int(d.get("rank", 1))
	if rank <= 1:
		for id in GameData.ITEMS:
			var o: Dictionary = GameData.ITEMS[id]
			if o.slot == "weapon" and o.get("class", "") == d.get("class", ""):
				return 1 if id == it.id else 2
	return mini(4, rank + 1)



static func refine_gain(it: Dictionary) -> Dictionary:
	var now: = _base_mods(it, int(it.refine))
	var nxt: = _base_mods(it, int(it.refine) + 1)
	var out: = {}
	for k in nxt:
		var dv: = float(nxt[k]) - float(now.get(k, 0.0))
		if absf(dv) > 0.0001:
			out[k] = dv
	return out



func mods() -> Dictionary:
	var out: = {}
	for k in slots:
		if slots[k] != null:
			var m: = item_mods(slots[k])
			var share: = offhand_mult(slots[k]) if k == "shield" and item_type(slots[k]) == "weapon" else 1.0
			for key in m:
				out[key] = out.get(key, 0.0) + m[key] * share

	var hm: = harmony_mods(slots)
	for key in hm:
		out[key] = out.get(key, 0.0) + float(hm[key])
	return out







var chest_legend: = 0.0


var chest_extra: = 0.0


func roll_item(run_time: float, bonus: int) -> Dictionary:

	var legend_chance: float = GameData.LEGENDARY_CHANCE + legend_bonus + chest_legend + chest_extra if bonus > 0 else (GameData.ELITE_LEGENDARY_CHANCE + legend_bonus * 0.2 if bonus == 0 else 0.0)
	var can_legend: = legend_chance > 0.0 and (run_time >= GameData.LEGENDARY_MIN_TIME or chest_legend >= 1.0)
	if can_legend and randf() < legend_chance:


		var any_class: = chest_legend > 0.0
		var treasure: = chest_legend >= 1.0
		var weapons: = []
		var others: = []
		for id in GameData.ITEMS:
			var d: Dictionary = GameData.ITEMS[id]





			if d.get("legendary", false) and not d.get("fixed", false) and not d.get("unique", false) and not d.get("face", false) and d.get("slot", "") != "soul" and (any_class or d.slot != "weapon" or usable_weapon(id)) and (any_class or d.slot != "shield" or usable_shield())\
			and (any_class or not d.has("lg_skill") or str(d.get("class", "")) == class_id)\
			and not (treasure and Save.storage().any( func(st): return str(st.id) == id)):
				(weapons if d.slot == "weapon" else others).append(id)


		var pick: = weapons if not weapons.is_empty() and (others.is_empty() or randf() < GameData.LEGENDARY_WEAPON_SHARE) else others
		if not pick.is_empty():
			legend_found += 1
			return make(pick.pick_random(), 0)
	var max_rank: = maxi(1, 1 + int(run_time / GameData.RANK_STEP) + bonus)
	var pool: = []
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		if d.get("legendary", false) or d.get("face", false) or int(d.get("rank", 1)) > max_rank:
			continue

		if d.get("purple", false) and bonus < 0:
			continue
		if d.slot == "weapon" and not GameData.weapon_allowed(class_id, job_id, id):
			continue
		if d.slot == "shield" and not usable_shield():
			continue
		pool.append(id)

		if d.slot == "weapon" and str(d.get("class", "")) == class_id and not d.get("purple", false):
			pool.append(id)
			pool.append(id)
	var weights: Array = GameData.SLOT_WEIGHTS.duplicate()
	var shift: = run_time / 160.0 + bonus
	for i in weights.size():
		weights[i] = float(weights[i]) * pow(1.6, shift * (i - 1.0) * 0.5)
	var total: = 0.0
	for w in weights:
		total += w
	var r: = randf() * total
	var n: = 0
	for i in weights.size():
		r -= weights[i]
		if r <= 0.0:
			n = i
			break

	if bonus < 0:
		n = mini(n, 1)

	if bonus > 0:
		n = maxi(n, GameData.CHEST_MIN_SLOTS)
	var pick: String = pool.pick_random()
	if GameData.ITEMS[pick].get("purple", false):
		n = 3
	var it: = make(pick, n)


	if n >= 1 and not GameData.ITEMS[pick].get("fixed", false):
		it["trait"] = GameData.PURPLE_TRAITS.keys().pick_random()
	return it




static func trait_of(it: Dictionary) -> Dictionary:
	var id: = str(it.get("trait", ""))
	if not GameData.PURPLE_TRAITS.has(id):
		return {}
	var tier: = trait_tier(it)
	return {"id": id, "name": GameData.PURPLE_TRAITS[id].name, "text": GameData.trait_text(id, tier), "fx": GameData.trait_fx(id, tier)}



static func trait_tier(it: Dictionary) -> int:
	return clampi(int(it.get("slots", 0)), 1, 3)





static func can_trait(it: Dictionary) -> bool:
	var d: = item_def(it)
	return int(it.get("slots", 0)) >= 1 and not d.get("fixed", false) and not d.get("legendary", false) and not d.get("unique", false) and not d.get("wings", false)




static func trait_price(it: Dictionary) -> int:
	var tier: = trait_tier(it)
	return int(GameData.TRAIT_ROLL_COST[tier] if int(it.get("trait_rolls", 0)) < GameData.TRAIT_ROLL_CHEAP else GameData.TRAIT_ROLL_LATE[tier])




func book_blocks(id: String) -> String:
	var need: = str(GameData.ITEMS[id].get("book", "")) if GameData.ITEMS.has(id) else ""
	return need if need != "" and need != book and GameData.weapon_allowed(class_id, job_id, id) else ""



func usable_weapon(id: String) -> bool:
	if GameData.ITEMS.has(id) and str(GameData.ITEMS[id].get("book", "")) not in ["", book]:
		return false
	return GameData.weapon_allowed(class_id, job_id, id)






func unique_blocked(it: Dictionary, slot_key: = "") -> bool:
	if not is_unique(it):
		return false
	for k in slots:
		var cur = slots[k]
		if k != slot_key and cur != null and cur != it and is_unique(cur):
			return true
	return false




func can_wear(it: Dictionary) -> bool:
	var d: = item_def(it)
	if d.has("soul_of") and not soul_open:
		return false
	if d.slot == "weapon":
		return usable_weapon(str(it.id))
	if d.slot == "shield":
		return usable_shield()
	return true



func usable_shield() -> bool:

	return class_id in GameData.SHIELD_CLASSES and not job_id in GameData.SHIELD_NO_JOBS and weapon_type() != "katar" and both_hands() == null



func dual_ok() -> bool:
	return job_id in GameData.DUAL_JOBS and weapon_type() != "katar" and not has_huuma()




func both_hands():
	if slots.weapon == null:
		return null
	return slots.weapon if GameData.two_handed(str(slots.weapon.id)) or item_def(slots.weapon).has("fists") else null




static func two_hands(it: Dictionary) -> bool:
	return item_type(it) == "weapon" and GameData.two_handed(str(it.get("id", "")))



func has_huuma() -> bool:
	return slots.weapon != null and GameData.weapon_kind(str(slots.weapon.id)) == "huuma"



func offhand_fits(it: Dictionary) -> bool:
	var d: = item_def(it)
	return dual_ok() and d.slot == "weapon" and usable_weapon(str(it.id))\
	and (str(d.get("weapon_type", "")) == "dagger" or GameData.OFFHAND_KINDS.has(GameData.weapon_kind(str(it.id))))



static func left_only(it: Dictionary) -> bool:
	return bool(item_def(it).get("left_only", false))





func fix_hands() -> void :



	var own: = str(GameData.TAEKWON_WEAPON.get(job_id, "fists"))
	if class_id == "taekwon" and slots.weapon != null and item_def(slots.weapon).has("fists") and str(slots.weapon.id) != own:
		slots.weapon = _fists_for_job(slots.weapon, own)
	elif class_id == "taekwon" and (slots.weapon == null or not usable_weapon(str(slots.weapon.id))):
		if slots.weapon != null:
			bag.append(slots.weapon)
		slots.weapon = make(own, 0)


	var left = slots.get("shield")
	if left != null and item_type(left) == "weapon" and not job_id in GameData.DUAL_JOBS:
		if left_waiting == null:
			left_waiting = left
		else:
			bag.append(left)
		slots.shield = null
	if left_waiting != null:
		if job_id in GameData.DUAL_JOBS:



			var held = slots.get("shield")
			if held != null and item_type(held) != "weapon" and not is_perm(held) and offhand_fits(left_waiting):
				bag.append(held)
				slots.shield = null
			if slots.get("shield") == null and offhand_fits(left_waiting):
				slots.shield = left_waiting
			else:
				bag.append(left_waiting)
			left_waiting = null
		elif job_id != "":
			bag.append(left_waiting)
			left_waiting = null
	if slots.weapon != null and left_only(slots.weapon) and job_id in GameData.DUAL_JOBS:
		if slots.get("shield") != null:
			bag.append(slots.shield)
		slots.shield = slots.weapon
		slots.weapon = null
	if weapon_type() == "katar" and slots.get("shield") != null:
		bag.append(slots.shield)
		slots.shield = null


	if both_hands() != null and slots.get("shield") != null and item_type(slots.shield) != "weapon":
		bag.append(slots.shield)
		slots.shield = null




	if has_huuma() and not offhand().is_empty():
		bag.append(slots.shield)
		slots.shield = null







func _fists_for_job(cur: Dictionary, id: String) -> Dictionary:
	var it: Dictionary = cur.duplicate(true)
	it["id"] = id
	it["slots"] = int(GameData.ITEMS[id].get("fixed_slots", cur.slots))
	it["perm"] = true
	var eternal_n: = int(it.get("eternal_n", 0))
	while (it.cards as Array).size() > sockets(it):
		var c: = str(it.cards.pop_back())
		if (it.cards as Array).size() >= eternal_n:
			card_bag.append(c)
	it["eternal_n"] = mini(eternal_n, (it.cards as Array).size())
	return it




func offhand() -> Dictionary:
	var it = slots.get("shield")
	return it if it != null and item_type(it) == "weapon" else {}



func offhand_mult(it: Dictionary) -> float:
	return 1.0 if item_def(it).get("offhand_full", false) else offhand_share



func shield_refine() -> int:
	return int(slots.shield.refine) if slots.get("shield") != null else -1



func shield_rank() -> int:
	var it = slots.get("shield")
	if it == null:
		return 0
	return 4 if is_legendary(it) else int(item_def(it).get("rank", 1))




func job_weapon(job: Dictionary) -> void :
	job_id = str(job.get("id", ""))

	if class_id == "taekwon":
		fix_hands()
		return
	var want: = str(job.get("weapon_item", ""))
	var cur = slots.weapon





	if cur != null and not usable_weapon(str(cur.id)):
		bag.append(cur)
		slots.weapon = make(want if want != "" and GameData.ITEMS.has(want) else class_weapon(), 0)
		return




	if want == "" or not GameData.ITEMS.has(want) or (cur != null and (cur.id != class_weapon() or is_perm(cur)))\
	or left_waiting != null or not offhand().is_empty():
		return
	var it: = make(want, int(cur.slots) if cur != null else 0)
	if cur != null:
		it.refine = cur.refine
		it.cards = cur.cards
	slots.weapon = it



func weapon_type() -> String:
	return str(item_def(slots.weapon).get("weapon_type", "")) if slots.weapon != null else ""


static func score(it: Dictionary) -> float:
	var d: = item_def(it)
	return (50.0 if d.get("legendary", false) else 0.0) + int(d.get("rank", 1)) * 8.0\
	+ int(it.slots) * 10.0 + int(it.refine) * 3.0 + it.cards.size() * 6.0





func _repeat_sells(it: Dictionary) -> bool:
	if not bool(Save.setting("autosell_owned", false)) or is_unique(it) or is_perm(it) or item_def(it).get("wings", false):
		return false
	if has_item(str(it.id)):
		return true

	return bag.any( func(b): return not is_same(b, it) and str(b.get("id", "")) == str(it.id))


func has_item(id: String) -> bool:
	for k in slots:
		if slots[k] != null and slots[k].id == id:
			return true
	return false



func effects() -> Dictionary:
	var out: = {}
	for k in slots:
		if slots[k] == null:
			continue
		var fx: Dictionary = item_effects(slots[k]) if soul_active(slots[k]) else {}
		if item_def(slots[k]).get("wings", false):
			fx = fx.duplicate()
			var wfx: = GameData.wing_fx(int(slots[k].get("refine", 0)))
			for e in wfx:
				fx[e] = float(fx.get(e, 0.0)) + float(wfx[e])
		for e in fx:
			out[e] = maxf(float(out.get(e, 0.0)), float(fx[e])) if e == "splash" else float(out.get(e, 0.0)) + float(fx[e])

		var tr_fx: Dictionary = trait_of(slots[k]).get("fx", {})
		for e in tr_fx:
			out[e] = float(out.get(e, 0.0)) + float(tr_fx[e])

		if slots[k].has("pot"):
			var pf: = Potential.fx(slots[k])
			var pk: = 1.0 + GameData.TWO_HANDED_BONUS if two_hands(slots[k]) else 1.0
			for e in pf:
				out[e] = float(out.get(e, 0.0)) + float(pf[e]) * pk
	return out





func active_sets(cards: Array) -> Array:
	var out: = []
	for id in GameData.SETS:
		var st: Dictionary = GameData.SETS[id]
		if st.has("more"):
			var worn: = GameData.set_pieces(id).filter( func(i): return has_item(i)).size()
			if worn >= 2:
				out.append(id)
			if worn >= 4:
				out.append(id + "@4")
			continue
		var ok: = true
		for item in st.get("items", []):
			if not has_item(item):
				ok = false
		for c in st.get("cards", []):
			if not cards.has(c):
				ok = false
		if ok:
			out.append(id)
	return out




static func sell_price(it: Dictionary) -> int:
	if is_legendary(it) or is_unique(it):
		return 0
	return GameData.ITEM_SELL_BASE + int(it.slots) * GameData.ITEM_SELL_PER_SLOT + int(it.refine) * 15



static func legend_coins(it: Dictionary) -> int:
	if is_unique(it):
		return int(GameData.LEGEND_COINS.unique)
	if is_legendary(it):
		return int(GameData.LEGEND_COINS.legendary)
	return 0



static func cash_in(it: Dictionary) -> int:
	var n: = legend_coins(it)
	if n > 0:
		Save.add_material("legend_coin", n)
	return n



static func price_text(it: Dictionary) -> String:
	var n: = legend_coins(it)
	if n > 0:
		return "%s x%d" % [TranslationServer.translate("Moneda legendaria"), n]
	return "%s z" % RoBasicWindow._thousands(sell_price(it))







func receive(it: Dictionary, keep: = false) -> Dictionary:

	Save.mark_seen("items", str(it.id))



	if not keep and is_legendary(it) and (auto_sells(it) or _repeat_sells(it)):
		return {"item": it, "result": "sold", "slot": _slot_for(it, true), "zeny": sell_price(it), "auto": true, "coins": _cash(it)}
	var key: = _slot_for(it, true)
	if slots[key] == null and can_wear(it) and not unique_blocked(it, key):
		slots[key] = it
		_auto_socket()
		return {"item": it, "result": "equipped", "slot": key, "zeny": 0}


	var up: = upgrade_slot(it) if auto_upgrade else ""
	if up != "":
		var old: Dictionary = slots[up]
		_move_cards(old, it)
		slots[up] = it
		fix_hands()
		_auto_socket()
		bag.append(old)
		return {"item": it, "result": "equipped", "slot": up, "zeny": fit_bag(), "replaced": old}


	if not keep and auto_sells(it):
		return {"item": it, "result": "sold", "slot": key, "zeny": sell_price(it), "auto": true, "coins": _cash(it)}
	bag.append(it)
	if bag.size() > bag_max:



		var worst: Dictionary = {} if is_legendary(it) else it
		for b in bag:
			if not is_perm(b) and not is_legendary(b) and not is_locked(b) and not set_mate(b) and (worst.is_empty() or score(b) < score(worst)):
				worst = b
		if worst.is_empty():
			return {"item": it, "result": "bagged", "slot": key, "zeny": 0}
		bag.remove_at(bag.find(worst))
		if worst == it:
			return {"item": it, "result": "sold", "slot": key, "zeny": sell_price(it)}
		return {"item": it, "result": "bagged", "slot": key, "zeny": sell_price(worst), "sold": worst}
	return {"item": it, "result": "bagged", "slot": key, "zeny": 0}







func upgrade_slot(it: Dictionary) -> String:
	if not can_wear(it) or is_face(it) or item_def(it).get("wings", false) or left_only(it):
		return ""
	var kind: = item_type(it)
	var keys: Array = ["acc1", "acc2"] if kind == "acc" else [kind]
	var best: = ""
	for k in keys:
		var cur = slots.get(k)
		if cur == null or is_perm(cur) or is_legendary(cur) or is_face(cur) or item_type(cur) != kind:
			continue
		if kind == "weapon" and GameData.weapon_kind(str(cur.id)) != GameData.weapon_kind(str(it.id)):
			continue
		if score(it) > score(cur) and (best == "" or score(cur) < score(slots[best])):
			best = k
	if best != "" and unique_blocked(it, best):
		return ""
	return best




func equip_upgrades() -> int:
	var n: = 0
	var again: = true
	while again:
		again = false
		var order: = range(bag.size())
		order.sort_custom( func(a, b): return score(bag[a]) > score(bag[b]))
		for i in order:
			var key: = upgrade_slot(bag[i])
			if key != "":
				equip_from_bag(i, key)
				n += 1
				again = true
				break
	return n





func fit_bag() -> int:
	var zeny: = 0
	while bag.size() > bag_max:
		var worst: = -1
		for i in bag.size():
			if not is_perm(bag[i]) and not is_legendary(bag[i]) and not is_locked(bag[i]) and not set_mate(bag[i]) and (worst < 0 or score(bag[i]) < score(bag[worst])):
				worst = i
		if worst < 0:
			break
		zeny += sell_from_bag(worst)
	return zeny






func set_mate(it: Dictionary) -> bool:
	var id: = str(it.get("id", ""))
	for sid in GameData.SETS:
		var pieces: Array = GameData.set_pieces(sid)
		if pieces.has(id) and pieces.any( func(p): return str(p) != id and has_item(str(p))):
			return true
	return false





static func is_locked(it: Dictionary) -> bool:
	if bool(it.get("lock", false)):
		return true


	return it.has("found_uid") and bool(Save.storage_item(str(it.found_uid)).get("lock", false))






static func auto_sells(it: Dictionary) -> bool:
	if is_legendary(it):
		return bool(Save.setting("autosell_owned", false)) and not is_unique(it) and not is_perm(it)\
		and not item_def(it).get("wings", false) and Save.storage().any( func(st): return str(st.get("id", "")) == str(it.id))
	var tier: = clampi(int(it.slots), 0, 3)
	if tier == 3:
		return bool(Save.setting("autosell_purple", false))
	for t in Save.setting("autosell", []):
		if int(t) == tier:
			return true
	return false





static func face_sells(it: Dictionary) -> bool:

	if not is_face(it) or is_unique(it):
		return false
	if bool(Save.setting("autosell_owned", false)) and Save.storage().any( func(st): return str(st.get("id", "")) == str(it.id)):
		return true
	return not is_legendary(it) and bool(Save.setting("autosell_purple", false))




func _slot_for(it: Dictionary, prefer_free: bool) -> String:
	var kind: = item_type(it)
	if left_only(it):
		return "shield"
	if kind == "weapon" and prefer_free and slots.weapon != null and slots.get("shield") == null and offhand_fits(it):
		return "shield"
	if kind != "acc":
		return kind
	if prefer_free and slots.acc1 == null:
		return "acc1"
	if prefer_free and slots.acc2 == null:
		return "acc2"
	if slots.acc1 == null or slots.acc2 == null:
		return "acc1" if slots.acc1 == null else "acc2"
	return "acc1" if score(slots.acc1) <= score(slots.acc2) else "acc2"





func equip_from_bag(index: int, slot_key: = "") -> int:
	if index < 0 or index >= bag.size() or not can_wear(bag[index]):
		return 0
	var it: Dictionary = bag[index]
	var key: = slot_key if slot_key != "" else _slot_for(it, true)
	if left_only(it):
		key = "shield"

		if weapon_type() == "katar":
			bag.append(slots.weapon)
			slots.weapon = null
	elif key == "shield" and item_type(it) == "weapon" and not offhand_fits(it):
		key = "weapon"

	if unique_blocked(it, key):
		return -1
	bag.remove_at(index)
	var moved: = 0
	if slots[key] != null:
		moved = _move_cards(slots[key], it)
		bag.insert(index, slots[key])
	slots[key] = it

	fix_hands()
	_auto_socket()
	return moved





static func _move_cards(old: Dictionary, to: Dictionary) -> int:
	var kind: = item_type(to)
	var moved: = 0
	var i: = int(old.get("eternal_n", 0))
	while i < old.cards.size() and free_slots(to) > 0:
		var c: String = old.cards[i]
		if GameData.CARDS.has(c) and GameData.CARDS[c].get("type", "") == kind:
			old.cards.remove_at(i)
			to.cards.append(c)
			moved += 1
		else:
			i += 1
	return moved





func unequip(slot_key: String) -> bool:
	if slot_key == "weapon" or slots.get(slot_key) == null or bag.size() >= bag_max:
		return false
	bag.append(slots[slot_key])
	slots[slot_key] = null
	return true



func swap_slots(a: String, b: String) -> void :
	var t = slots[a]
	slots[a] = slots[b]
	slots[b] = t



func sell_from_bag(index: int, cash: = true) -> int:
	if index < 0 or index >= bag.size():
		return 0
	var it: Dictionary = bag[index]
	if not can_sell(it):
		return 0
	if found_face(it):
		Save.remove_from_storage(str(it.found_uid))
	bag.remove_at(index)
	for c in it.cards:
		card_bag.append(c)
	last_coins = _cash(it) if cash else 0
	return sell_price(it)



func _cash(it: Dictionary) -> int:
	return cash_in(it) if coins_here else legend_coins(it)



static func is_grey(it: Dictionary) -> bool:
	return int(it.slots) == 0 and not is_legendary(it) and int(it.refine) == 0



func sell_greys() -> Dictionary:
	var zeny: = 0
	var n: = 0
	for i in range(bag.size() - 1, -1, -1):
		if is_grey(bag[i]) and not is_perm(bag[i]):
			zeny += sell_from_bag(i)
			n += 1
	return {"count": n, "zeny": zeny}





func duplicates() -> Array:
	var groups: = {}
	for i in bag.size():
		var it: Dictionary = bag[i]
		if is_perm(it) or is_legendary(it) or is_locked(it):
			continue
		var id: = str(it.id)
		if not groups.has(id):
			groups[id] = []
		groups[id].append(i)
	var out: = []
	for id in groups:
		var worn: = - INF
		for k in slots:
			if slots[k] != null and str(slots[k].id) == id:
				worn = maxf(worn, score(slots[k]))
		var idx: Array = groups[id]
		if idx.size() < 2 and worn == - INF:
			continue

		var best: = -1
		for i in idx:
			if score(bag[i]) > worn and (best < 0 or score(bag[i]) > score(bag[best])):
				best = i
		for i in idx:
			if i != best:
				out.append(i)
	return out



func sell_duplicates() -> Dictionary:
	var dup: = duplicates()
	dup.sort()
	var zeny: = 0
	for k in range(dup.size() - 1, -1, -1):
		zeny += sell_from_bag(int(dup[k]))
	return {"count": dup.size(), "zeny": zeny}




func sort_bag() -> void :
	var kinds: = ["weapon", "shield", "head", "mid", "low", "armor", "garment", "shoes", "acc", "wings", "soul"]
	var key: = func(it: Dictionary) -> Array:
		var k: = kinds.find(str(item_def(it).get("slot", "")))
		var rare: = 5 if is_unique(it) else (4 if is_legendary(it) else clampi(int(it.get("slots", 0)), 0, 3))
		return [k if k >= 0 else kinds.size(), - rare, - int(item_def(it).get("rank", 1)), str(it.id)]
	bag.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		var ka: Array = key.call(a)
		var kb: Array = key.call(b)
		if ka != kb:
			return ka < kb
		return score(a) > score(b))






func unlocked_value() -> Array:
	var n: = 0
	var z: = 0
	var coins: = 0
	for it in bag:
		if _sells_unlocked(it):
			n += 1
			z += sell_price(it)
			coins += legend_coins(it)
	return [n, z, coins]


func _sells_unlocked(it: Dictionary) -> bool:
	return not is_perm(it) and not is_locked(it) and not is_unique(it) and not is_soul(it)



func sell_unlocked() -> Dictionary:
	var zeny: = 0
	var n: = 0
	var coins: = 0
	for i in range(bag.size() - 1, -1, -1):
		if _sells_unlocked(bag[i]):
			zeny += sell_from_bag(i)
			coins += last_coins
			n += 1
	return {"count": n, "zeny": zeny, "coins": coins}



func sell_filtered() -> Dictionary:
	var zeny: = 0
	var n: = 0
	for i in range(bag.size() - 1, -1, -1):

		if (auto_sells(bag[i]) or (is_legendary(bag[i]) and _repeat_sells(bag[i]))) and not is_perm(bag[i]) and not is_locked(bag[i]):
			zeny += sell_from_bag(i)
			n += 1
	return {"count": n, "zeny": zeny}



func filtered_value() -> Array:
	var n: = 0
	var z: = 0

	var kept: = {}
	for k in slots:
		if slots[k] != null:
			kept[str(slots[k].id)] = true
	var repeats: = bool(Save.setting("autosell_owned", false))
	for it in bag:
		if is_perm(it) or is_locked(it):
			continue
		var again: = false
		if repeats and is_legendary(it) and not is_unique(it) and not item_def(it).get("wings", false):
			again = kept.has(str(it.id))
			kept[str(it.id)] = true
		if auto_sells(it) or again:
			n += 1
			z += sell_price(it)
	return [n, z]




func add_card(card: String) -> String:
	card_bag.append(card)
	return _auto_socket_card(card)


func _auto_socket() -> void :
	for c in card_bag.duplicate():
		_auto_socket_card(c)


func _auto_socket_card(card: String) -> String:
	for k in GameData.EQUIP_SLOTS:
		var it = slots[k]
		if it != null and free_slots(it) > 0 and card_fits(it, card):
			socket(card, k)
			return k
	return ""



func fitting_slots(card: String) -> Array[String]:
	var out: Array[String] = []
	for k in GameData.EQUIP_SLOTS:
		var it = slots[k]

		if it != null and sockets(it) > 0 and card_fits(it, card)\
		and (free_slots(it) > 0 or (it.cards as Array).size() > int(it.get("eternal_n", 0))):
			out.append(k)
	return out



func unsocket(slot_key: String, index: int) -> String:
	var it = slots.get(slot_key)
	if it == null or index < int(it.get("eternal_n", 0)) or index >= it.cards.size():
		return ""
	var c: String = it.cards[index]
	it.cards.remove_at(index)
	card_bag.append(c)
	return c




func swap_card(card: String, slot_key: String, index: int) -> bool:
	var it = slots.get(slot_key)
	if it == null or not card_bag.has(card) or index < int(it.get("eternal_n", 0)) or index >= it.cards.size()\
	or not card_fits(it, card):
		return false
	card_bag.erase(card)
	card_bag.append(it.cards[index])
	it.cards[index] = card
	return true


func can_socket(card: String, slot_key: String) -> bool:
	var it = slots.get(slot_key)
	return it != null and free_slots(it) > 0 and card_bag.has(card) and card_fits(it, card)


func socket(card: String, slot_key: String) -> bool:
	if not can_socket(card, slot_key):
		return false
	card_bag.erase(card)
	slots[slot_key].cards.append(card)
	return true




func try_refine(slot_key: String, smith: = false) -> Dictionary:
	var it = slots.get(slot_key)
	if it == null or not refinable(it):
		return {}
	var ore: = ore_for(it)
	if int(ores[ore]) <= 0:
		return {}
	ores[ore] = int(ores[ore]) - 1
	var from: = int(it.refine)


	var luck: = float(it.get("smith_luck", 0.0)) if smith else 0.0
	var ok: = randf() < refine_chance(it) + luck
	if ok:
		it.refine = from + 1
		it.erase("smith_luck")
		if int(it.refine) >= GameData.MAX_REFINE:
			it["lock"] = true
	elif smith:
		it["smith_luck"] = luck + GameData.SMITH_REFINE_LUCK
	else:
		it.refine = maxi(0, from - 1)
	return {"ok": ok, "from": from, "to": int(it.refine), "ore": ore}



func socketed_cards() -> Array:
	var out: = []
	for k in slots:
		if slots[k] != null:
			out.append_array(slots[k].cards)
	return out
