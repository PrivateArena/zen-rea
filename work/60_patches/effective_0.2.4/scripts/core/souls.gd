extends RefCounted













const Potential = preload("res://scripts/core/potential.gd")
const PREFIX: = "soul_"



static func soul_id(unique_id: String) -> String:
	var id: = PREFIX + unique_id
	return id if GameData.ITEMS.has(id) else ""



static func is_legend_soul(id: String) -> bool:
	var d: Dictionary = GameData.ITEMS.get(id, {})
	return d.has("soul_of") and not GameData.ITEMS.get(str(d.soul_of), {}).get("unique", false)



static func legend_shop(class_id: String) -> Array:
	var out: = []
	for id in GameData.ITEMS:
		if is_legend_soul(str(id)) and class_uses(class_id, str(id)):
			out.append(str(id))
	out.sort_custom( func(a, b): return TranslationServer.translate(str(GameData.ITEMS[a].name)) < TranslationServer.translate(str(GameData.ITEMS[b].name)))
	return out




static func class_uses(class_id: String, id: String) -> bool:
	var src: = str(GameData.ITEMS.get(id, {}).get("soul_of", ""))
	var u: Dictionary = GameData.ITEMS.get(src, {})
	if u.is_empty():
		return false
	if str(u.get("slot", "")) == "weapon":
		return GameData.weapon_for_line(class_id, src)
	return not u.has("class") or str(u. class ) == class_id or (u.get("also_class", []) as Array).has(class_id)



static func buy(id: String) -> String:
	if not is_legend_soul(id):
		return "bad"
	if Save.material("legend_coin") < GameData.LEGEND_SOUL_PRICE:
		return "coins"
	if Save.storage().size() >= Save.storage_cap():
		return "full"
	for i in GameData.LEGEND_SOUL_PRICE:
		Save.use_material("legend_coin")
	Save.storage().append({"id": id, "slots": 0, "extra_slots": 0, "refine": 0, "cards": [], "lock": true, 
		"uid": "%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]})
	Save.mark_seen("items", id)
	Save.bump("souls_bought")
	Save.mark_dirty()
	Save.flush()
	return ""



static func can_turn(it: Dictionary) -> bool:
	return not it.is_empty() and GameData.ITEMS.has(str(it.get("id", ""))) and Equipment.is_unique(it)\
	and not Equipment.is_soul(it) and soul_id(str(it.id)) != "" and not bool(it.get("lent", false))



static func refund(it: Dictionary) -> Dictionary:
	var out: = {"zeny": 0, "mats": {}, "crumbs": 0, "eternal": [], "cards": []}
	var mats: Dictionary = out.mats
	var ore: = Equipment.ore_for(it)


	var base: = float(GameData.REFINE_FEE[Equipment._rate_key(it)]) * Equipment.fee_mult(it) * GameData.REFINE_FEE_MULT
	for lvl in clampi(int(it.get("refine", 0)), 0, GameData.MAX_REFINE):
		out.zeny += int(base * pow(GameData.REFINE_FEE_GROWTH, lvl))
		var m: = ore if lvl < GameData.REFINE_RICH_FROM else "enriched_" + ore
		mats[m] = int(mats.get(m, 0)) + 1

	var weapon: = Equipment.item_type(it) == "weapon"
	for i in clampi(int(it.get("extra_slots", 0)), 0, GameData.SOCKET_COST_LEGENDARY.size()):
		out.zeny += int(int(GameData.SOCKET_COST_LEGENDARY[i]) * Equipment.fee_mult(it))
		var sm: = "enriched_oridecon" if weapon else "enriched_elunium"
		mats[sm] = int(mats.get(sm, 0)) + i + 1

	var kind: = Equipment.item_type(it)
	if Equipment.gradable_kind(kind):
		for g in range(1, Equipment.grade(it) + 1):
			var c: = GameData.grade_cost(kind, g)
			out.zeny += int(c.zeny)
			mats[str(c.ore)] = int(mats.get(str(c.ore), 0)) + int(c.ori)
			if int(c.hd) > 0:
				mats[str(c.hd_ore)] = int(mats.get(str(c.hd_ore), 0)) + int(c.hd)
	out.crumbs = int(GameData.SOUL_POT_REFUND[clampi(Potential.tier(it), 0, GameData.SOUL_POT_REFUND.size() - 1)])
	out.eternal = (it.get("eternal", []) as Array).duplicate()
	out.cards = (it.get("cards", []) as Array).filter( func(c): return GameData.CARDS.has(str(c)))
	return out






static func turn(uid: String) -> Dictionary:
	var it: = Save.storage_item(uid)
	if not can_turn(it):
		return {"ok": false}
	var back: = refund(it)
	var owner: = Save.loadout_owner(uid)
	var sid: = soul_id(str(it.id))
	Save.remove_from_storage(uid)
	var soul: = {"id": sid, "slots": 0, "extra_slots": 0, "refine": 0, "cards": [], "lock": true, 
		"uid": "%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]}
	Save.storage().append(soul)
	if int(back.zeny) > 0:
		Save.add_zeny(int(back.zeny))
	for m in back.mats:
		Save.add_material(str(m), int(back.mats[m]))
	if int(back.crumbs) > 0:
		Save.add_material("star_crumb", int(back.crumbs))
	for c in back.cards:
		Save.add_card(str(c))
	if owner != "" and not Save.loadout(owner).has("soul") and GameData.soul_slot_open(owner):
		Save.set_loadout_slot(owner, "soul", str(soul.uid))
	Save.mark_seen("items", sid)
	Save.bump("souls")
	Save.mark_dirty()
	Save.flush()
	return {"ok": true, "soul": soul, "refund": back}
