class_name Player
extends Node3D

# [MOD] Ceiling for "Mechanics" damage - the damage-report row that groups every pierce hit with no
# enemy behind it (hell rain, meteors, heralds, shadow-MVP mechanics, storm, Niflheim fog, Marca del
# Apocalipsis, corrupt burst, tower hazards). Those hits scale with OUR max HP and skip armour, VIT,
# Guard at full rate and the "Aguanta" one-hit save, so at ~1M HP a meteor landed 514k (0.18 pct x 3.0
# stillness stack). See work/60_patches/PATCH_SYSTEM.md §7/§11.
const MOD_MECH_PCT_CAP: = 0.15
# hits bigger than 4x max HP are the game's own executions (main.gd tour/debug kills use 1e9..1e12)
const MOD_MECH_EXECUTE_OVER: = 4.0
static var mod_mech_hits: = 0
static var mod_mech_capped: = 0
static var mod_mech_saved: = 0.0
static var mod_mech_worst: = 0.0
# [MOD] Level-up rarity weights, replacing GameData.CHOICE_RARITY w = [70, 22, 7, 1] (sum 100 -> a
# Legendaria offer is 1.0% at 0 luck, 2.7% at the luck ceiling). Probabilities are w[i]/sum(w), so
# these give 52% / 27% / 15% / 6.0% = 6x the shipped legendary rate. steps (levels granted) and the
# all_stats bonus still come from the shipped table, and luck still shifts weight out of Comun.
const MOD_CHOICE_W: = [52.0, 27.0, 15.0, 6.0]
static var mod_choice_n: = [0, 0, 0, 0]
static var mod_choice_rolls: = 0
# [MOD] Flat run-XP multiplier. Every point of run XP enters through add_xp below (kill gems, co-op
# shares, tower, net pickups), so this is the one global knob. The curve is need(L) =
# int((4+5(L-1)+1.2(L-1)^1.6)(1+(L-1)/40)) ~ L^2.6, so XP^0.29 = level: x1.5 XP is ~+56 levels at
# the Lv 443 / 40-minute mark (35.3M -> 53.0M XP), not +50%. It also raises Class Lv, because Class
# EXP is roundi(xp_gained), which this feeds. See PATCH_SYSTEM.md §14.
const MOD_XP_MULT: = 1.5
const MOD_TAG: = "mod-v13 on 0.2.7 caps: clock=3.0 tower_floor=90 trap_pct=0.10 mechanics_pct=0.15 choice_w=[52,27,15,6] xp=1.5 crumb=2.5 crumb_sites=2 pot_up=[30,18] pot_same=0.85 perfect=0.80 stats_w=12 refine=x2 grade=[1,1.15,1.5,2,2.6] altar_w=[6,3,0.8] karma_baldur=0.75 gacha_odds=[40,30,15,10,5]"


signal leveled_up
signal died


const BOW_MUZZLE_UP: = Vector3(0, 1.15, 0)
const BOW_MUZZLE_AHEAD: = 0.75



var rebirth_aura: = false
var rebirth_looks: Array = []
var class_id: = ""
var def: = {}



var input: HeroInput = HeroInput.Local.new():
	set(v):
		var was_local: = input is HeroInput.Local
		input = v


		if was_local != (v is HeroInput.Local) and not def.is_empty() and not title_effect_ids().is_empty():
			recompute()

var profile: = {}


var _last_stick: = Vector2.ZERO

var skill_off: = {}


var blinking: = 0.0


var blink_cut: = false
var net_action: = -1

var net_speed: = 0.0
var slot: = 0
var downed: = false

var revive_t: = 0.0


var choosing: = false
var _choosing_sign: Node3D

var homun_node: Homunculus


var purse: = 0

var trap_hunt_until: = 0.0
var visual: RoVisual
var radius: = 0.4

var hp: = 100.0:
	set(v):
		hp = v
		_hp_seal = v * _seal_k + _seal_c
var max_hp: = 100.0:
	set(v):
		max_hp = v
		_max_seal = v * _seal_k + _seal_c



var tampered: = false

var falls: = 0
var _seal_k: = 1.0
var _seal_c: = 0.0
var _hp_seal: = 0.0
var _max_seal: = 0.0

func _reseal() -> void :
	_seal_k = randf_range(1.37, 3.91)
	_seal_c = randf_range(-9173.0, 9173.0)
	_hp_seal = hp * _seal_k + _seal_c
	_max_seal = max_hp * _seal_k + _seal_c


func _check_seal() -> void :
	if tampered:
		return
	var a: = hp * _seal_k + _seal_c
	var b: = max_hp * _seal_k + _seal_c
	if absf(a - _hp_seal) > 1e-06 * maxf(1.0, absf(a)) or absf(b - _max_seal) > 1e-06 * maxf(1.0, absf(b)):
		tampered = true
		push_warning("run marked: HP changed outside the game")
var shield: = 0.0

var shield_peak: = 0.0

var _gryphon_at: = 0.0
var level: = 1:
	set(v):
		level = v



		if not _late_look.is_empty() and not _late_shown and level >= int(_late_look.get("level", 1)):
			_show_late_look()


var _late_look: = {}
var _late_shown: = false
var xp: = 0.0
var xp_need: = 5
var pending_levels: = 0


var skills: = {}
var stats: = {"str": 0, "agi": 0, "vit": 0, "int": 0, "dex": 0, "luk": 0}
var cards: Array[String] = []

var album_cards: Array[String] = []

var job2: = {}

var job_path: = 0


var spheres: = 0


var ov_stage: = 0
var ov_text: = ""

var coins: = 0
var _coin_nodes: Array[Sprite3D] = []


var _mirrors: Array[Sprite3D] = []
var _mirror_spin: = 0.0
var _cicada_t: = 99.0


var lg_mark: Enemy
var lg_mark_until: = 0.0
var lg_mark_fx: Node3D
var lg_bash_kills: = 0


var lg_fury: = 0
var lg_fury_until: = 0.0

var _combo_busy: = false

var combo_charges: = 0
var combo_charge_at: = -9.0


var crush_mult: = 1.0
var crush_reach: = 1.0

var homun_type: = ""

var homun_extra: Array = []



var forge: = 0
var forge_heat: = 0.0



var temper_el: = ""
var mpt_power: = 0.0

var lex_hits: = 0


var charms: Array = []
var _charm_nodes: Array[Sprite3D] = []
var forge_hit_at: = 0
var _forge_aura: Node3D
var homun_extra_nodes: Array = []

var _hindsight_cd: = 0.0
var sphere_max: = 0

var _sphere_hits: = 0.0
var _sphere_next: = 0.0



var fury_crit: = 0.0
var fury_crit_dmg: = 0.0
var fury_chain: = 0.0
var _fury_aura: Node3D
var _sphere_nodes: Array[Sprite3D] = []

var reborn: = false
var _view: = ""

var look: = {}

var appearance: = {}

var equipment: Equipment

var meta: = {}
var xp_mult: = 1.0
var loot_mult: = 1.0

var hard_loot: = 1.0

var card_mult: = 1.0

var basic_mult: = 1.0



var skill_mult: = 1.0
var skill_mult_str: = 1.0
var skill_mult_int: = 1.0

var _skill_base: = 1.0

var _skill_amp: = 1.0
var _skill_mult_cache: = {}

var proc_mult: = 1.0

var hit_proc_mult: = 1.0




var proc_int_basic: = 0.0
var proc_int_hit: = 0.0


var proc_dmg_bonus: = 0.0

var pacts: Array = []

var altar_mods: = {}




var hurt_at: = -99.0


var death_by: = {}


var fell: = false


var stored_uniques: Array = []

var _boom_at: = 0

var _heal_sum: = 0.0
var _hurt_sum: = 0.0
var _hurt_shown_at: = -100000
var _barrier_shown_at: = -100000


var host_max_hp: = 0.0




var run_taken: = 0.0
var run_healed: = 0.0



var karma_altars: Array = []

var _hp_warned: = false
var _heal_shown_at: = 0

var tower_power: = 0.0


var tower_mods: = {}



var toys: = {}
var fogged: = false

var dishes: Array = []

var effects: = {}

var pet_id: = ""

var pet_skin: = ""

var pet_fetch: = true


var party_buffs: = {}

var shield_src: = ""

var pet_skill_t: = 3.0

var quiver: Array[String] = []
var arrow_id: = ""
var _sweat_cd: = 0.0


var _legend_cd: = {}


var tongue_charge: = 0.0
var _tongue_until: = 0.0
var _tongue_now: = 1.0
var stew_hp: = 0.0

var stew_kills: = 0


var root_kills: = 0
var root_hp: = 0.0


var hel_marks: = 0
var feathers: = 0
var thor_stacks: = 0
var _thor_t: = 0.0
var active_sets: Array = []
var revives: = 0

var has_uniq: = false
var uniq: = {}


var steel_guard: = 0.0

var steel_proc: = 0.0
var martyr_pct: = 0.0
var gospel: = {}

var provoke: = {}
var _block_heal_at: = -9.0
var _preserve_at: = -9.0
var _blitz_at: = -9.0
var _blitz_saved: = 0




var _proc_next: = {}



var _hit_power: = 1.0
var _proc_saved: = {}
var proc_stack: = 1.0
var proc_bake: = 1.0


var kaiser_blast: = 0.0
var _survive_at: = -99.0


var rerolls: = 0
var banishes: = 0
var extra_choices: = 0


var oath_curse: = 0.0

var luck_mult: = 1.0

const MAX_EXTRA_CHOICES: = 1
var banished: Array[String] = []


var run_favs: Array[String] = []

var xp_gained: = 0.0

var pace_xp: = 1.0


var dmg_mult: = 1.0

var cd_mult: = 1.0
var _haste: = 0.0
var _agi_haste: = 0.0
var _grade_haste: = 0.0
var move_speed: = 4.0
var area_mult: = 1.0

var area_over: = 0.0

var spread_hits: = {}
var proj_mult: = 1.0
var crit: = 0.0

var crit_over: = 0.0

var ultra_crit: = false

var base_stats: = {}

var crit_dmg: = 1.5


var duration_mult: = 1.0

var curse: = 0.0


var doom: = false

var pride: = false


var grade_mech_cut: = 0.0
var grade_hit_cut: = 0.0


var harmony: = 0


const DOOM_TICK_MULT: = 3.0

var heal_mult: = 1.0

var vit_cut: = 0.0
var vit_heal: = 1.0

var support_mult: = 1.0

var pickup_area: = 1.0


var extra_count: = 0
var dodge: = 0.0

var perfect_dodge: = 0.0
var regen: = 0.0
var armor: = 0.0
const BASE_MAGNET: = 4.0
var magnet: = BASE_MAGNET


var _attack_timer: = 0.5

var procs: Array = []


var procs_hit: Array = []

var hit_proc_skills: = {}
var _proc_hit_cd: = {}
var aspd_bonus: = 0.0

var facing: = Vector3(0, 0, 1)



var _stance_rest: = 0.0
var dash: = {}
var aura: = {}
var mild_element: = ""
var _kaahi_cd: = 0.0

var _hunt_id: = 0
var _hunt_streak: = 0

var kick_streak: = 0

var soul_bonds: = 0
var _bond_nodes: Array[Sprite3D] = []

var _shield_stored: = 0.0
var _kick_until: = 0.0
var _union_shown: = false
var _attack_anim: = 0.0
var _attack_turn_lock: = 0.0
var _since_attack: = 10.0

var _in_combat: = false
var _moving: = false
var _invuln: = 0.0



const SKILL_GUARD_EVERY: = 2.0
var _skill_guard_t: = 0.0




var _skill_safe: = 0.0

var slip: = 0.0

var powers: = {}

var heat: = {}


var heat_base: = {}
var heat_level: = 0.0
var _heat_stage: = -1
var _heat_glow: Sprite3D


var _heat_still: = 0.0
var _heat_barrel: Sprite3D
var _heat_steamed: = false
var _heat_fx_t: = 0.0

var falcon: RoVisual
const FALCON_SPOT: = Vector3(-0.15, 3.8, 0.05)
var _falcon_away: = 0.0

var cart: Pushcart
var _vel: = Vector3.ZERO




func _init() -> void :
	_reseal()


	add_to_group(RoVisual.VIEW_GROUP)
	rotation.y = RoVisual.view_yaw


func setup(p_class: String, p_profile: = {}) -> void :
	class_id = p_class
	def = GameData.CLASSES[class_id]
	look = def
	if p_profile.is_empty():
		p_profile = Player.profile_of(class_id)
	profile = p_profile

	if def.get("custom", false):
		def = GameData.sn_def(profile.get("sn_build", {}))
		look = def
	appearance = profile.look


	var first_ammo: String = ammo().keys()[0]
	quiver = []
	for a in ammo():
		quiver.append(str(a))
	arrow_id = first_ammo
	pet_id = str(profile.pet)
	pet_skin = str(profile.get("pet_skin", pet_id))

	costume = (profile.get("cos", {}) as Dictionary).duplicate() if profile.get("cos", {}) is Dictionary else {}
	pet_fetch = bool(profile.get("pet_fetch", true))
	_late_look = {}
	_late_shown = false
	for lk in def.get("looks", []):
		if str(lk.id) == str(appearance.get("show", "")):
			_late_look = lk
	if not _late_look.is_empty() and level >= int(_late_look.get("level", 1)):
		_show_late_look()
	_build_visual()
	if def.get("cart", false):
		cart = Pushcart.make(self)
	xp_need = GameData.xp_to_next(level)

	var start_stats: Dictionary = def.get("stats", {})
	for k in start_stats:
		stats[k] = int(start_stats[k])
	reborn = bool(profile.reborn)
	for k in stats:
		stats[k] += int(profile.rebirth_stats)

	var perm: Dictionary = profile.class_stats
	for k in perm:
		stats[k] += int(perm[k])
	base_stats = stats.duplicate()
	add_skill(def.start)
	equipment = Equipment.new(class_id)

	equipment.auto_upgrade = bool(profile.get("auto_upgrade", true))


	var gear: Dictionary = profile.gear
	for slot_key in gear:
		var stored: Dictionary = gear[slot_key]
		if not stored.is_empty() and GameData.ITEMS.has(str(stored.id)) and equipment.slots.has(slot_key):

			if slot_key == "weapon" and (GameData.ITEMS[stored.id].slot != "weapon" or (class_id == "taekwon" and not equipment.usable_weapon(str(stored.id)))):
				continue
			equipment.slots[slot_key] = Equipment.from_storage(stored)

	equipment.soul_open = bool(profile.reborn) or bool(def.get("no_rebirth", false))
	if not equipment.soul_open:
		equipment.slots["soul"] = null


	var own_fists = profile.get("fists", {})
	if class_id == "taekwon" and own_fists is Dictionary and str(own_fists.get("id", "")) == "fists"\
	and (equipment.slots.weapon == null or Equipment.item_def(equipment.slots.weapon).has("fists")):
		equipment.slots.weapon = Equipment.from_storage(own_fists)



	var left: Dictionary = gear.get("shield", {})
	if not gear.has("weapon") and not left.is_empty() and GameData.ITEMS.has(str(left.id)) and GameData.ITEMS[left.id].slot == "weapon"\
	and not Equipment.left_only(left) and class_id != "taekwon" and equipment.usable_weapon(str(left.id)):
		equipment.slots.weapon = Equipment.from_storage(left)
		equipment.slots.shield = null
	meta = profile.meta
	revives = int(meta.get("revive", 0.0)) + gear_lives(false)

	pacts = (profile.pacts as Array).slice(0, GameData.MAX_PACTS)
	dishes = (profile.get("dishes", [profile.get("dish", "")]) as Array).filter( func(d): return GameData.RECIPES.has(str(d)))




	var dev: = NameFilter.dev_name(str(appearance.get("name", "")))
	rebirth_aura = bool(profile.get("aura", false))
	rebirth_looks = (profile.get("looks", []) as Array).duplicate() if profile.get("looks") is Array else []
	RebirthAura.attach(self, rebirth_looks, rebirth_aura and not dev)
	if dev:
		var dev_aura: = RebirthAura.new()
		dev_aura.rainbow = true
		add_child(dev_aura)
	rerolls = int(profile.rerolls)
	stored_uniques = (profile.get("uniques", []) as Array).duplicate()
	banishes = int(profile.banishes)




	for k in profile.get("run_bans", []):
		if banishes > 0 and not banished.has(str(k)):
			banished.append(str(k))
			banishes -= 1



	if start_skill() != str(def.start):
		skills.erase(def.start)
		if start_skill() != "":
			add_skill(start_skill())
	run_favs.assign((profile.get("run_favs", []) as Array).slice(0, GameData.RUN_FAV_MAX))

	extra_choices = mini(int(profile.sage_book), int(GameData.SAGE_UPGRADES.sage_book.max))
	for id in profile.cards:
		if GameData.CARDS.has(id):
			album_cards.append(id)
	recompute()
	hp = max_hp





static func profile_of(class_id: String) -> Dictionary:
	var gear: = {}
	var loadout: Dictionary = Save.loadout(class_id)
	for slot_key in loadout:
		var stored: = Save.storage_item(str(loadout[slot_key]))
		if not stored.is_empty():
			gear[slot_key] = stored.duplicate(true)
	var cards: = []
	for id in Save.equipped_cards().slice(0, GameData.card_slots()):
		if Save.has_card(id):
			cards.append(id)


	var look: = Save.look(class_id)
	if str(look.get("name", "")).strip_edges() != "":
		look["name"] = Save.char_name(class_id)
	return {"look": look, "pet": Save.active_pet(), "pet_skin": Save.pet_skin(), "pet_fetch": bool(Save.setting("pet_fetch", true)), 
		"cos": Save.worn_cosmetics(class_id), 
		"reborn": Save.is_reborn(class_id), 

		"rlv": Save.rebirth_lv(class_id), 
		"rebirth_stats": Save.rebirth_stats(class_id), "class_stats": Save.class_stats(class_id).duplicate(), 


		"bank": Save.zeny(), 
		"gear": gear, "fists": Save.own_fists().duplicate(true) if class_id == "taekwon" else {}, "meta": GameData.meta_mods(), "auto_upgrade": bool(Save.setting("auto_upgrade", true)), "pacts": Save.pacts(class_id).duplicate(), "dishes": Save.dishes(), 
		"aura": RebirthAura.earned(class_id), "looks": Save.rebirth_looks(class_id), "rerolls": Save.upgrade_active("magnifier"), 

		"tower_cps": Save.tower_checkpoints(), "tower_power": Save.tower_power(), "tower_builds": Save.tower_builds().size(), 
		"tower_wings": Save.tower_wings().duplicate(), "hel_wings": Save.hel_wings().duplicate(), 
		"banishes": Save.upgrade_active("fly_wing"), "sage_book": Save.upgrade_active("sage_book"), 
		"run_bans": saved_bans(class_id).slice(0, Save.upgrade_active("fly_wing")), "run_favs": saved_favs(class_id), 
		"sage_start": Save.upgrade_active("sage_start"), 
		"passive_slot": Save.upgrade_active("passive_slot"), "sage_root": Save.upgrade_active("sage_root"), "cards": cards, "homun_pick": str(Save.setting("homun_pick", "homun_lif")), 
		"uniques": Save.storage().filter( func(s): return GameData.ITEMS.get(str(s.id), {}).get("unique", false)).map( func(s): return str(s.id)), 
		"plagiarism": Save.plagiarism_active().duplicate(), 
		"plagiarism_any": [Save.plagiarism_pick()] if Save.plagiarism_pick() != "" else [], 
		"sn_build": Save.sn_build().duplicate(true) if GameData.CLASSES[class_id].get("custom", false) else {}}


func _show_late_look() -> void :
	_late_shown = true
	look = look.duplicate()
	for k in ["body", "weapon", "weapon_fx", "attack"]:
		look[k] = _late_look[k]
	if visual != null:
		_build_visual()


func _build_visual() -> void :
	if visual != null:
		visual.queue_free()
	visual = RoVisual.new()
	add_child(visual)
	_view = head_view()

	var m: = mount()
	_shield_view = "" if not m.is_empty() else shield_view()
	_extras = extra_views()
	_weapon_view = weapon_view()
	var wv: Array = _weapon_view
	visual.setup(RoAssets.styled_character(str(m.get("body", look.body)), str(m.get("weapon", wv[0])), 
		str(m.get("weapon_fx", wv[1])), 
		[int(m.get("attack", wv[2]))], _view, appearance, _shield_view, _extras), def.color, 44)



	visual.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	visual.sprite.render_priority = GameData.HERO_PRIORITY

	visual.show_through(0.6, 15)
	visual.hold_idle = true


var _shield_view: = ""
var _extras: Array = []
var _weapon_view: Array = []






func _assassin_view() -> Array:
	var hands: = []
	for it in [equipment.slots.weapon, equipment.slots.get("shield")]:
		if it != null and Equipment.item_type(it) == "weapon":
			hands.append(GameData.weapon_kind(str(it.id)))
	hands.sort_custom( func(a, b): return GameData.OFFHAND_KINDS.find(a) < GameData.OFFHAND_KINDS.find(b))
	var key: = "weapon_assassin_" + ("dual" if hands == ["dagger", "dagger"] else ("_".join(hands) if not hands.is_empty() else "dagger"))
	if not RoAssets.has_sprite(key):
		key = "weapon_assassin_dagger"
	return [key, key + "_slash", 11 if hands.size() > 1 else 10]





func weapon_view() -> Array:
	var w: = [str(look.get("weapon", "")), str(look.get("weapon_fx", "")), int(look.get("attack", RoVisual.PC_ATTACK))]

	var gun: = gun_look()
	if gun != "":
		var key: = "weapon_%s_%s" % ["rebellion" if str(job2.get("id", "")) == "rebellion" else "gun", gun]
		var female: = str(appearance.get("gender", "m")) == "f"
		if RoAssets.has_sprite(key) and ( not female or RoAssets.has_sprite(key + "_f")):
			return [key, key + "_fx", 11]
	if equipment != null and str(job2.get("id", "")) in ["assassin", "assassin_cross"] and equipment.weapon_type() != "katar":
		return _assassin_view()

	if equipment != null and equipment.slots.weapon != null:
		var kind: = GameData.weapon_kind(str(equipment.slots.weapon.id))
		if kind != own_weapon_kind():
			var job: = str(job2.get("id", "")) if not job2.is_empty() else (str(_late_look.id) if _late_shown else class_id)
			job = str(GameData.TRANS_OF.get(job, job))
			var spr: Array = (GameData.JOB_WEAPON_SPRITES.get(job, {}) as Dictionary).get(kind, [])


			var female: = str(appearance.get("gender", "m")) == "f"

			if not spr.is_empty() and (RoAssets.has_sprite(str(spr[0])) or female) and ( not female or RoAssets.has_sprite(str(spr[0]) + "_f")):
				return [str(spr[0]), str(spr[1]), int(spr[2])]
	return w



func gun_look() -> String:
	if equipment == null or equipment.slots.weapon == null:
		return ""
	return str(GameData.GUN_LOOKS.get(str(equipment.slots.weapon.id), ""))



func extra_views() -> Array:
	return Equipment.extra_views(equipment.slots, str(look.get("body", "")), costume) if equipment != null else []




func shield_view() -> String:
	var it = equipment.slots.get("shield") if equipment != null else null
	if it != null and Equipment.item_type(it) == "weapon":
		return ""
	return Equipment.shield_view_of(it, str(look.get("body", ""))) if it != null else ""



func head_view() -> String:

	var top: = Equipment.cosmetic_view(str(costume.get("top", "")))
	if top != "":
		return top

	if str(costume.get("top", "")) == GameData.COSMETIC_HIDE:
		return ""
	if equipment == null or equipment.slots.head == null:
		return ""
	return Equipment.head_view_of(equipment.slots.head)



var costume: = {}





func record_look() -> Dictionary:
	return {"b": str(look.get("body", "")), "w": str(look.get("weapon", "")), "wf": str(look.get("weapon_fx", "")), 
		"h": head_view(), "s": shield_view(), "x": extra_views(), "cos": costume.values().filter( func(c): return str(c) != GameData.COSMETIC_HIDE), 
		"g": str(appearance.get("gender", "m")), "hr": int(appearance.get("hair", 2)), 
		"hc": int(appearance.get("hair_color", 0)), "c": int(appearance.get("cloth", 0)), 
		"a": RebirthAura.earned(class_id), "ach": roundi(Achievements.percent() * 100.0), "doom": doom, "pride": pride, 
		"chk": record_check()}






func record_check() -> Dictionary:
	var st: = []
	for k in ["str", "agi", "vit", "int", "dex", "luk"]:
		st.append(int(stats.get(k, 0)))
	return {"lv": level, "st": st, "t": tampered or not stats_plausible(), "mhp": roundi(max_hp)}









func stats_plausible() -> bool:
	var total: = 0
	for k in stats:
		var v: = int(stats[k])
		if v > GameData.STAT_HARD_CAP or v > 40 + 4 * (level + 2):
			return false
		total += v
	return total <= 80 + 9 * (level + 2)


func job_name() -> String:
	if not job2.is_empty():
		return tr(GameData.job_title(job2, female()))
	return tr(GameData.HIGH_NAMES.get(class_id, def.name) if reborn else def.name)


func female() -> bool:
	return str(appearance.get("gender", "m")) == "f"




func next_job(path: = 0) -> Dictionary:
	var paths: = GameData.job_paths(class_id)
	var job: Dictionary = paths[clampi(path, 0, paths.size() - 1)].duplicate()
	if reborn and job.has("trans"):
		for k in job.trans:
			job[k] = job.trans[k]
	job.erase("trans")

	if job.has("skills_dance"):
		if dance_book():
			job.skills = job.skills_dance
		job.erase("skills_dance")

	if female() and job.has("skills_f"):
		job.skills = job.skills_f
	return job


func can_job_change() -> bool:
	return job2.is_empty() and def.has("job2") and level >= GameData.JOB_CHANGE_LEVEL




func job_change(path: = 0) -> void :
	if not job2.is_empty():
		return
	job_path = path
	song_book = book_for_job()
	job2 = next_job(path)
	equipment.book = performer()
	equipment.job_weapon(job2)

	var kept: Dictionary = profile.gear.get("weapon", {})
	if class_id == "taekwon" and not kept.is_empty() and GameData.ITEMS.has(str(kept.id)) and equipment.usable_weapon(str(kept.id))\
	and GameData.ITEMS[kept.id].slot == "weapon" and not GameData.ITEMS[kept.id].has("fists"):



		var held = equipment.slots.weapon
		if held != null:
			for i in range(int(held.get("eternal_n", 0)), held.cards.size()):
				equipment.card_bag.append(str(held.cards[i]))
		equipment.slots.weapon = Equipment.from_storage(kept)
	look = def.duplicate()
	for k in job2:
		look[k] = job2[k]
	_build_visual()
	_update_falcon()


	if job_start_skill() != "":
		add_skill(job_start_skill())
	recompute()
	hp = max_hp






func start_options() -> Array:
	var all: = (def.skills as Array).filter( func(id): return not GameData.SKILLS[id].type in GameData.START_EXCLUDED_TYPES) + _copied_attacks(def.skills)
	var left: = all.filter( func(id): return not banished.has("skill:" + str(id)))
	if not left.is_empty():
		return left



	var other: = (def.skills as Array).filter( func(id): return GameData.SKILLS.has(id) and not Player.is_passive(id)\
	and not banished.has("skill:" + str(id)))


	return other




func start_skill() -> String:
	var id: = str(def.start)
	if not banished.has("skill:" + id):
		return id
	var left: = start_options().filter( func(s): return not banished.has("skill:" + str(s)))
	return str(left[0]) if not left.is_empty() else ""



func job_start_skill() -> String:
	var id: = str(job2.get("start", ""))
	if id == "" or not banished.has("skill:" + id):
		return id
	var left: = job_start_options()

	return str(left[0]) if not left.is_empty() else ""




func job_start_options() -> Array:

	var own: = (job2.get("skills", []) as Array).filter( func(id): return GameData.SKILLS.has(id) and not Player.is_passive(id) and (GameData.SKILLS[id].get("song", false) or not GameData.SKILLS[id].type in GameData.START_EXCLUDED_TYPES))

	return (own + _copied_attacks(own).filter( func(id): return not skills.has(id)))\
	.filter( func(id): return not banished.has("skill:" + id))




func _copied_attacks(have: Array) -> Array:
	return _copied().filter( func(id): return not have.has(id) and not Player.is_passive(id)\
	and not GameData.SKILLS[id].type in GameData.START_EXCLUDED_TYPES)




func start_passive_options() -> Array:
	return (def.get("passives", []) as Array).filter( func(id): return GameData.SKILLS.has(id) and not skills.has(id)\
	and not banished.has("skill:" + id))




func job_passive_options() -> Array:
	return (job2.get("passives", []) as Array).filter( func(id): return GameData.SKILLS.has(id) and not skills.has(id) and has_needs(id)\
	and not banished.has("skill:" + id))




func set_job_skill(id: String) -> void :
	var start: = job_start_skill()
	if id == start or not GameData.SKILLS.has(id):
		return
	if skills.has(start) and int(skills[start].level) == 1:
		skills.erase(start)
	if not skills.has(id):
		add_skill(id)
	recompute()




func set_start_skill(id: String) -> void :
	var start: = start_skill()
	if id == start or not GameData.SKILLS.has(id):
		return
	if skills.has(start) and int(skills[start].level) == 1:
		skills.erase(start)
	if not skills.has(id):
		add_skill(id)
	recompute()


func skill_pool() -> Array:
	var pool: Array = def.skills + job2.get("skills", [])


	for id in _copied():
		if GameData.SKILLS[id].type != "passive" and not pool.has(id):
			pool.append(id)
	return pool





func can_copy() -> bool:
	return str(job2.get("id", "")) in GameData.COPY_JOBS or (class_id == "thief" and job2.is_empty())






func keep_build_copies() -> void :
	var own: Array = def.skills + def.get("passives", []) + job2.get("skills", []) + job2.get("passives", [])
	var copyable: = {}
	for pair in GameData.plagiarism_pairs():
		copyable[str(pair[1])] = true
	var held: Array = []
	for id in skills:
		var b: = base_skill(str(id))
		if copyable.has(b) and not own.has(b) and not held.has(b):
			held.append(b)
	if str(job2.get("id", "")) in GameData.ROGUE_JOBS:




		if has_meta("build_plag"):
			remove_meta("build_plag")
		else:
			profile["plagiarism"] = held
		return
	if not held.is_empty():
		profile["plagiarism_any"] = held.slice(0, GameData.PLAGIARISM_ANY)



func _copied() -> Array:
	var copied: Array = profile.get("plagiarism", []) if str(job2.get("id", "")) in GameData.ROGUE_JOBS\
	else profile.get("plagiarism_any", [])
	return copied.filter( func(id): return GameData.SKILLS.has(id))



func bank_zeny() -> float:
	return float(profile.get("bank", 0))



func is_plagiarized(id: String) -> bool:
	id = base_skill(id)
	return _copied().has(id) and not (def.skills + def.get("passives", []) + job2.get("skills", []) + job2.get("passives", [])).has(id)



func passive_pool() -> Array:
	var pool: Array = def.get("passives", []) + job2.get("passives", [])

	for id in _copied():
		if GameData.SKILLS[id].type == "passive" and not pool.has(id):
			pool.append(id)
	return pool




func max_passives() -> int:
	var job: = 0
	if not job2.is_empty():
		job = GameData.JOB_EXTRA_PASSIVES + (GameData.TRANS_EXTRA_PASSIVES if reborn else 0) + int(job2.get("extra_passives", 0))
	if def.has("max_passives"):
		return int(def.max_passives)
	return GameData.MAX_PASSIVES + job + mini(int(profile.get("passive_slot", 0)), int(GameData.SAGE_UPGRADES.passive_slot.max))


static func is_passive(id: String) -> bool:
	return GameData.SKILLS[id].type == "passive"



static func is_support(id: String) -> bool:
	return str(GameData.SKILLS[id].type) in GameData.SUPPORT_TYPES




func has_needs(id: String) -> bool:
	var need: = str(GameData.SKILLS[id].get("needs", ""))
	if need == "" or skills.has(need):
		return true
	var evo: Dictionary = GameData.EVOLUTIONS.get(need, {})
	return not evo.is_empty() and skills.has(str(evo.to))




func play_combo(toward: Vector3, action: int) -> void :
	if toward.length_squared() > 0.0001:
		visual.face(Vector3(toward.x, 0.0, toward.z))
		_attack_turn_lock = 0.35
	var length: = visual.action_length(action)
	var shown: = clampf(length, 0.18, 0.3)
	visual.play(action, false, true)
	visual.speed_scale = length / shown
	_attack_anim = shown
	_since_attack = 0.0




static func base_skill(id: String) -> String:
	return id.trim_suffix("_x")


func is_toggle(id: String) -> bool:
	return GameData.TOGGLE_SKILLS.has(base_skill(id))


func is_hold(id: String) -> bool:
	return GameData.HOLD_SKILLS.has(base_skill(id))


func is_off(id: String) -> bool:
	return skill_off.has(base_skill(id))




func f_skill() -> String:
	for id in skills:
		if is_hold(id):
			return id
	for id in skills:
		if is_toggle(id):
			return id
	return ""




func use_hold(world: World, id: String) -> bool:
	if not skills.has(id) or powers.has("oath_silence"):
		return false
	if base_skill(id) == "heat_barrel" and powers.has("heat_barrel"):
		powers.erase("heat_barrel")
		recompute()
		world.play_sound("guard_block", 0.0, -4.0)
		return true
	var s: Dictionary = skills[id]
	if s.cd > 0.2:
		world.number(position + Vector3(0, 2.2, 0), "%.0f s" % s.cd, Color(0.8, 0.8, 0.9))
		return false
	if Skills.cast(world, self, id, s.level):
		s.cd = GameData.skill_value(id, "cooldown", s.level) * cd_for(id)
		_after_cast(id, world)
		if has_uniq:
			Uniques.after_cast(world, self, id)
		return true
	return false





static func title_effect_ids() -> Array:
	var out: = []
	var got = Save.setting("titles_special", [])
	if got is Array:
		for g in got:
			var tid: = str(g.get("title", "")) if g is Dictionary else ""
			if GameData.TITLES.has(tid) and GameData.TITLES[tid].has("effects") and not out.has(tid) and special_title_live(g):
				out.append(tid)
	return out








static func special_title_live(g: Dictionary) -> bool:
	var tid: = str(g.get("title", ""))
	if not GameData.TITLES.has(tid) or not bool(GameData.TITLES[tid].get("temp", false)):
		return true
	var m: = RegEx.create_from_string("(\\d{4}-\\d{2})(?!\\d)").search(str(g.get("proof", "")))
	return m == null or m.get_string(1) == iso_week(int(Time.get_unix_time_from_system()) - 7 * 86400)



static func iso_week(t: int) -> String:
	var day: = t - posmod(t, 86400)
	var wd: = (int(Time.get_datetime_dict_from_unix_time(day).weekday) + 6) % 7
	var thu: = day + (3 - wd) * 86400
	var y: = int(Time.get_datetime_dict_from_unix_time(thu).year)
	var jan1: = Time.get_unix_time_from_datetime_dict({"year": y, "month": 1, "day": 1, "hour": 0, "minute": 0, "second": 0})
	return "%04d-%02d" % [y, (thu - jan1) / 604800 + 1]


func count_skills(passive: bool) -> int:
	var n: = 0
	for id in skills:
		if is_passive(id) == passive:
			n += 1
	return n







func sn_mult_full(id: String, without: = "") -> bool:
	if class_id != "super_novice" or not GameData.sn_mult(id):
		return false
	return GameData.sn_mult_count(skills.keys().filter( func(k): return k != without)) >= GameData.SN_MULT_MAX


func max_skills() -> int:
	var extra: = 0
	if not job2.is_empty():
		extra = GameData.JOB_EXTRA_SKILLS + (GameData.TRANS_EXTRA_SKILLS if reborn else 0) + int(job2.get("extra_skills", 0))
	if def.has("max_skills"):
		extra = int(def.max_skills) - GameData.MAX_SKILLS


	return maxi(1, GameData.MAX_SKILLS + extra)




func max_move_speed() -> float:
	return GameData.MOVE_SPEED_MAX_MOUNTED if not mount().is_empty() else GameData.MOVE_SPEED_MAX


func mount() -> Dictionary:
	if powers.has("union") and RoAssets.has_sprite("star_gladiator_union"):
		return {"body": "star_gladiator_union"}
	if skills.has("peco_riding") and not job2.is_empty():

		var job: = str(job2.get("id", ""))
		if GameData.MOUNTS.has(job) and RoAssets.has_sprite(str(GameData.MOUNTS[job].body)):
			var m: Dictionary = GameData.MOUNTS[job]

			if equipment != null and equipment.slots.weapon != null:
				var spr: Array = (m.get("kinds", {}) as Dictionary).get(GameData.weapon_kind(str(equipment.slots.weapon.id)), [])
				var female: = str(appearance.get("gender", "m")) == "f"
				if not spr.is_empty() and RoAssets.has_sprite(str(spr[0])) and ( not female or RoAssets.has_sprite(str(spr[0]) + "_f")):
					var held: = m.duplicate()
					held.weapon = str(spr[0])
					held.weapon_fx = str(spr[1])
					held.attack = int(spr[2])
					return held
			return m
	return {}


func add_skill(id: String) -> void :

	if evolved_from(id):
		id = str(GameData.EVOLUTIONS[id].to)
	if id == "making_arrow":
		for a in ammo():
			add_arrow(a)
	if skills.has(id):
		skills[id].level += 1
	else:
		skills[id] = {"level": 1, "cd": 0.0 if GameData.SKILLS[id].type == "passive" else 0.5}

		if id == "peco_riding" and visual != null:
			_build_visual()


func add_stat(id: String) -> void :
	stats[id] += 1
	recompute()




func add_card(id: String) -> String:
	cards.append(id)
	var slot: = equipment.add_card(id)
	recompute()
	return slot



func sell_card(id: String) -> int:
	if not equipment.card_bag.has(id):
		return 0
	equipment.card_bag.erase(id)
	cards.erase(id)
	recompute()
	return GameData.CARD_SELL_ZENY






func eff_stat(id: String) -> float:
	var base: = float(base_stats.get(id, 0))
	var run: = maxf(0.0, float(stats.get(id, 0)) - base)




	return (_capped(base) + _capped(run + buff_stat(id))) * (1.0 + float(stat_pct.get(id, 0.0)))



func buff_stat(id: String) -> float:
	return float(effects.get("aura_stats", 0.0)) if id in ["str", "int"] else 0.0



func buff_stat_worth(id: String) -> float:
	var add: = buff_stat(id)
	if add <= 0.0:
		return 0.0
	var run: = maxf(0.0, float(stats.get(id, 0)) - float(base_stats.get(id, 0)))
	return _capped(run + add) - _capped(run)



var stat_pct: = {}


var stat_cap: = float(GameData.MAX_STAT)

var vs_mvp: = 0.0




func gear_lives(in_tower: bool) -> int:
	var n: = 0
	if equipment != null:
		n = int(equipment.effects().get("lives", 0.0))
	return n * (GameData.TOWER_LIVES_MULT if in_tower else 1)


func _capped(v: float) -> float:
	return minf(v, stat_cap) + maxf(0.0, v - stat_cap) * GameData.OVERSTAT_EFF



func run_stat(id: String) -> int:
	return maxi(0, int(stats.get(id, 0)) - int(base_stats.get(id, 0)))



func has_dish(id: String) -> bool:
	return dishes.has(id)




func _drop_evolved_bases() -> void :
	for id in skills.keys():
		if evolved_from(id):
			skills.erase(id)


func recompute() -> void :
	_drop_evolved_bases()
	if equipment != null:
		equipment.fix_hands()
	var mods: = meta.duplicate()

	if equipment != null and equipment.slots.weapon != null and Equipment.item_def(equipment.slots.weapon).has("fists"):
		mods["dmg"] = float(mods.get("dmg", 0.0)) + float(Equipment.item_def(equipment.slots.weapon).fists) * level


	var gear_fx: = equipment.effects() if equipment != null else {}
	stat_cap = float(GameData.MAX_STAT) + float(gear_fx.get("wing_stat_cap", 0.0))
	var sockets: Array = equipment.socketed_cards() if equipment != null else []

	var set_ids: Array = equipment.active_sets(sockets + album_cards) if equipment != null else []
	for sid in set_ids:
		var sfx: Dictionary = GameData.set_part(sid).get("effects", {})
		for k in sfx:
			gear_fx[k] = float(gear_fx.get(k, 0.0)) + float(sfx[k])



	var card_buff: = 0.0
	for c in album_cards + sockets:
		card_buff += float(GameData.CARDS[c].get("effects", {}).get("buff_power", 0.0))
	var boost: = 1.0 + float(gear_fx.get("buff_power", 0.0)) + card_buff

	var boost_dmg: = 1.0 + (boost - 1.0) * GameData.BUFF_POWER_DMG_SHARE
	for id in powers:
		var pw: Dictionary = GameData.power_def(id).get("mods", {})
		var own: = GameData.SKILL_POWERS.has(id) or GameData.LEGEND_POWERS.has(id)
		for k in pw:
			var val: = float(pw[k])

			var gb: = grace_buff(id) * (GameData.BUFF_POWER_DMG_SHARE if k in GameData.BUFF_POWER_DMG_KEYS else 1.0)
			mods[k] = mods.get(k, 0.0) + (val * ((boost_dmg if k in GameData.BUFF_POWER_DMG_KEYS else boost) + gb) if own and val > 0.0 else val)
	if soul_bonds > 0:
		mods["dmg"] = mods.get("dmg", 0.0) + GameData.SOUL_BOND_DMG * soul_bonds
	if powers.has("heat_barrel"):
		for k in heat:
			mods[k] = mods.get(k, 0.0) + float(heat[k])
	for id in pacts:
		var pm: Dictionary = GameData.PACTS[id].get("mods", {})
		for k in pm:
			mods[k] = mods.get(k, 0.0) + float(pm[k])
	for k in altar_mods:
		mods[k] = mods.get(k, 0.0) + float(altar_mods[k])

	var toy_n: = 0
	for id in toys:
		toy_n += int(toys[id])
	for id in toys:
		var tm: Dictionary = GameData.MORROC_TOYS.get(id, {}).get("mods", {})
		for k in tm:
			mods[k] = mods.get(k, 0.0) + float(tm[k]) * int(toys[id])
	if toys.has("broken_toy"):
		mods["dmg"] = mods.get("dmg", 0.0) + GameData.TOY_BROKEN_DMG * toy_n * int(toys.broken_toy)



	mods["risk_dmg"] = float(altar_mods.get("risk_dmg", 0.0)) + float(tower_mods.get("dmg", 0.0))

	if tower_power > 0.0:
		mods["dmg"] = mods.get("dmg", 0.0) + tower_power
		mods["max_hp_pct"] = mods.get("max_hp_pct", 0.0) + tower_power
	for k in tower_mods:
		if k != "dmg":
			mods[k] = mods.get(k, 0.0) + float(tower_mods[k])

	if equipment != null:
		var lh: = int(skills.get("left_hand_mastery", {"level": 0}).level)
		equipment.offhand_share = GameData.OFFHAND_SHARE + (GameData.skill_value("left_hand_mastery", "offhand", lh) if lh > 0 else 0.0)
	var em: = equipment.mods() if equipment != null else {}
	for k in em:
		mods[k] = mods.get(k, 0.0) + em[k]
	harmony = int(Equipment.harmony_of(equipment.slots).level) if equipment != null else 0


	stat_pct = {}
	for s in stats:
		stat_pct[s] = mods.get(s + "_pct", 0.0) + mods.get("all_pct", 0.0)
	vs_mvp = mods.get("vs_mvp", 0.0)
	var tens: = float(mini(Save.tower_top(), GameData.TOWER_GEAR_TOP) / GameData.TOWER_TIER_FLOORS)
	mods["dmg"] = mods.get("dmg", 0.0) + mods.get("tower_dmg", 0.0) * tens
	mods["max_hp_pct"] = mods.get("max_hp_pct", 0.0) + mods.get("tower_hp", 0.0) * tens
	active_sets = []
	effects = {}
	if equipment != null:
		effects = gear_fx
		active_sets = set_ids
		for sid in active_sets:
			var sm: Dictionary = GameData.set_part(sid).mods
			for k in sm:
				mods[k] = mods.get(k, 0.0) + float(sm[k])

	if class_id == "merchant":
		mods["dmg"] = mods.get("dmg", 0.0) + GameData.merchant_bank_dmg(bank_zeny())
	if not job2.is_empty():
		mods["dmg"] = mods.get("dmg", 0.0) + float(job2.get("dmg_bonus", 0.0))
		mods["max_hp_pct"] = mods.get("max_hp_pct", 0.0) + float(job2.get("hp_bonus", 0.0))
	for c in album_cards:
		var card_mods: Dictionary = GameData.CARDS[c].mods
		for k in card_mods:
			mods[k] = mods.get(k, 0.0) + card_mods[k]



	if input is HeroInput.Local:
		for tid in title_effect_ids():
			var tfx: Dictionary = GameData.TITLES[tid].effects
			for k in tfx:
				effects[k] = float(effects.get(k, 0.0)) + float(tfx[k])
	if pet_id != "" and GameData.PETS.has(pet_id):
		var pm: Dictionary = GameData.PETS[pet_id].mods
		for k in pm:
			mods[k] = mods.get(k, 0.0) + float(pm[k])

	for kind in ([homun_type] + homun_extra) if homun_type != "" else []:
		var au: Dictionary = GameData.HOMUNCULI.get(str(kind), {}).get("aura", {})
		for k in au:
			var av: = float(au[k]) * (GameData.MUTATION_AURA if homun_mutated() else 1.0)

			if k in EFFECT_BONUS:
				effects[k] = float(effects.get(k, 0.0)) + av
			else:
				mods[k] = mods.get(k, 0.0) + av

	if pet_id != "" and GameData.PETS.has(pet_id):
		var pe: Dictionary = GameData.PETS[pet_id].get("effects", {})
		for k in pe:
			effects[k] = float(effects.get(k, 0.0)) + float(pe[k])

	for d in dishes:
		var r: Dictionary = GameData.RECIPES.get(str(d), {})
		for k in r.get("mods", {}):
			mods[k] = mods.get(k, 0.0) + float(r.mods[k])
		for k in r.get("effects", {}):
			effects[k] = float(effects.get(k, 0.0)) + float(r.effects[k])

	for c in album_cards + sockets:
		var ce: Dictionary = GameData.CARDS[c].get("effects", {})
		for k in ce:
			effects[k] = float(effects.get(k, 0.0)) + float(ce[k])

	for c in _wing_cards():
		var we: Dictionary = GameData.CARDS[c].get("effects", {})
		for k in we:
			if float(we[k]) > 0.0:
				effects[k] = float(effects.get(k, 0.0)) + float(we[k]) * float(gear_fx.get("wing_card", 0.0))

	for k in GameData.UPGRADE_EFFECTS:
		for fx in GameData.UPGRADE_EFFECTS[k]:
			effects[fx] = float(effects.get(fx, 0.0)) + float(mods.get(k, 0.0))
	for id in toys:
		var tf: Dictionary = GameData.MORROC_TOYS.get(id, {}).get("fx", {})
		for k in tf:
			effects[k] = float(effects.get(k, 0.0)) + float(tf[k]) * int(toys[id])

	for k in ["proc_chance", "hit_proc"]:
		if altar_mods.has(k):
			effects[k] = float(effects.get(k, 0.0)) + float(altar_mods[k])

	var riding: = not mount().is_empty()
	for id in skills:

		if GameData.SKILLS[id].get("mounted", false) and not riding:
			continue
		if GameData.SKILLS[id].get("needs_shield", false) and (equipment == null or equipment.slots.get("shield") == null):
			continue
		var needs: = str(GameData.SKILLS[id].get("needs_weapon", ""))
		if needs != "" and equipment != null and equipment.weapon_type() != needs:
			continue


		var sung: bool = GameData.SKILLS[id].get("song", false)
		if sung and not songs.has(id):
			continue
		for k in GameData.SKILLS[id].get("bonus", []):
			var val: = GameData.skill_value(id, k, skills[id].level)

			if GameData.SKILLS[id].type == "buff":


				val *= buff_mult_for(k, id)
			if sung and bis_t > 0.0:
				val *= bis_mult()
			if k in EFFECT_BONUS:
				effects[k] = float(effects.get(k, 0.0)) + val
			else:
				mods[k] = mods.get(k, 0.0) + val

	for id in party_buffs:
		var pb: Dictionary = party_buffs[id]
		if skills.has(id) and int(skills[id].level) >= int(pb.level):
			continue
		for k in GameData.SKILLS[id].get("bonus", []):
			var val: = GameData.skill_value(id, k, int(pb.level)) * float(pb.power)
			if k in EFFECT_BONUS:
				effects[k] = float(effects.get(k, 0.0)) + val
			else:
				mods[k] = mods.get(k, 0.0) + val



	if forge_on():
		var wit = equipment.slots.get("weapon") if equipment != null else null
		if wit != null and forge > 0:
			var now: = Equipment._base_mods(wit, int(wit.refine))
			var hot: = Equipment._base_mods(wit, int(wit.refine) + forge)
			for k in hot:
				mods[k] = mods.get(k, 0.0) + float(hot[k]) - float(now.get(k, 0.0))
		var lv: = forge_refine()
		mods["skill_dmg"] = mods.get("skill_dmg", 0.0) + GameData.FORGE_SKILL * lv
		mods["basic_dmg"] = mods.get("basic_dmg", 0.0) + float(effects.get("forge_basic", 0.0)) * lv


	for id in pacts:
		var pfx: Dictionary = GameData.PACTS[id].get("effects", {})
		for k in pfx:
			effects[k] = float(effects.get(k, 0.0)) + float(pfx[k])
	var devoted: = devotion_slots()
	if devoted > 0:
		var per: Dictionary = GameData.PACTS.devotion.per_free
		for k in per:
			mods[k] = mods.get(k, 0.0) + float(per[k]) * devoted
	if obsession_on():
		effects["double_cast"] = float(effects.get("double_cast", 0.0)) + float(GameData.PACTS.obsession.double_cast)
	mods["max_hp"] = mods.get("max_hp", 0.0) + stew_hp + root_hp
	var old_max: = max_hp
	_haste = GameData.DEX_HASTE * eff_stat("dex") + mods.get("haste", 0.0)
	_agi_haste = GameData.AGI_SKILL_HASTE * eff_stat("agi")

	_grade_haste = mods.get("grade_haste", 0.0)
	cd_mult = 1.0 / (1.0 + GameData.soft_haste(_haste)) / (1.0 + _grade_haste)


	grade_mech_cut = minf(0.5, mods.get("grade_mech", 0.0))
	grade_hit_cut = minf(0.5, mods.get("grade_hit", 0.0))
	move_speed = minf(max_move_speed(), def.speed * (1.0 + GameData.AGI_MOVE * eff_stat("agi") + mods.get("move", 0.0)))
	max_hp = (def.hp + GameData.VIT_FLAT_HP * eff_stat("vit") + mods.get("max_hp", 0.0))\
	* (1.0 + mods.get("max_hp_pct", 0.0) + GameData.VIT_HP_PCT * eff_stat("vit"))

	max_hp *= 1.0 + mods.get("grade_hp", 0.0)
	regen = 0.15 + 0.25 * eff_stat("vit") + float(def.get("regen", 0.0)) + mods.get("regen", 0.0)

	if feathers > 0:
		max_hp *= pow(GameData.FEATHER_HP, feathers)
		regen += max_hp * GameData.FEATHER_REGEN * feathers

	if oath_curse > 0.0:
		max_hp *= 1.0 - oath_curse

	var area_cap: = GameData.AMP_AREA_MAX if float(effects.get("amp", 0.0)) > 0.0 else GameData.AREA_MAX
	var area_raw: float = GameData.INT_AREA * maxf(eff_stat("str"), eff_stat("int")) + mods.get("area", 0.0)
	area_over = maxf(0.0, area_raw - area_cap)
	area_mult = 1.0 + minf(area_cap, area_raw)

	pickup_area = 1.0 + mods.get("area", 0.0)
	support_mult = 1.0 + GameData.DEX_SUPPORT * eff_stat("dex")
	vit_cut = minf(GameData.VIT_DMG_CUT_MAX, GameData.VIT_DMG_CUT * eff_stat("vit"))
	vit_heal = 1.0 + GameData.VIT_HEAL * eff_stat("vit")
	extra_count = int(mods.get("count", 0.0))
	proj_mult = minf(GameData.PROJ_SPEED_MAX, GameData.PROJ_SPEED_BASE + mods.get("proj_speed", 0.0))


	var lone: = free_slot_bonus()
	duration_mult = minf(1.0 + GameData.DURATION_MAX, 1.0 + GameData.DEX_DURATION * eff_stat("dex") + mods.get("duration", 0.0))
	curse = mods.get("curse", 0.0)
	doom = float(mods.get("doom", 0.0)) > 0.0

	pride = float(mods.get("pride", 0.0)) > 0.0
	if pride:
		effects["drop_find"] = float(effects.get("drop_find", 0.0)) + GameData.PRIDE_DROP
	dodge = minf(GameData.FLEE_CAP, float(def.get("dodge", 0.0)) + mods.get("dodge", 0.0) + GameData.AGI_FLEE * eff_stat("agi"))

	dodge *= 1.0 - (1.0 - luck_mult) * GameData.OATH_UNLUCKY_FLEE
	perfect_dodge = minf(GameData.PERFECT_DODGE_CAP, GameData.LUK_PERFECT_DODGE * eff_stat("luk")) * luck_mult
	armor = def.armor + mods.get("armor", 0.0)
	xp_mult = 1.0 + mods.get("xp", 0.0) + curse * GameData.CURSE_XP
	sphere_max = int(mods.get("spheres", 0.0))
	sphere_power = mods.get("sphere_power", 0.0)

	magnet = BASE_MAGNET * (1.0 + mods.get("magnet", 0.0))
	procs = []
	procs_hit = []

	var wing_left: = _wing_cards()
	var all_cards: Array = album_cards + sockets
	for i in all_cards.size():
		var c: String = all_cards[i]
		var more: = 0.0
		if i >= album_cards.size() and wing_left.has(c):
			wing_left.erase(c)
			more = float(effects.get("wing_card", 0.0))
		if GameData.CARDS[c].has("proc"):
			procs.append(_proc_more(GameData.CARDS[c].proc, more))
		if GameData.CARDS[c].has("proc_hit"):
			procs_hit.append(_proc_more(GameData.CARDS[c].proc_hit, more))
	if equipment != null:
		for k in equipment.slots:
			var it = equipment.slots[k]
			if it == null:
				continue
			var pd: = Equipment.item_def(it)

			if Equipment.is_soul(it):
				pd = GameData.ITEMS.get(str(pd.soul_of), {}) if equipment.soul_active(it) else {}
			if pd.has("proc"):
				procs.append(pd.proc)
			if pd.has("proc_hit"):
				procs_hit.append(pd.proc_hit)
	hit_proc_skills = {}
	for pr in procs_hit:
		hit_proc_skills[str(pr.skill)] = true
	has_uniq = effects.keys().any( func(k): return str(k).begins_with("u_")) or uniq.has("flies") or uniq.has("soul_nodes")\
	or uniq.has("ember_nodes") or uniq.has("night_disc") or uniq.has("orb_nodes")
	loot_mult = (1.0 + mods.get("loot", 0.0) + curse * GameData.CURSE_ZENY) * hard_loot
	card_mult = 1.0 + mods.get("card", 0.0) + GameData.CARD_LUK_BONUS * eff_stat("luk")
	if visual != null and (head_view() != _view or shield_view() != _shield_view or extra_views() != _extras
			or weapon_view() != _weapon_view):
		_build_visual()
	_last_mods = mods
	_last_lone = lone
	_counters()

	_skill_base = 1.0 + area_over * area_overflow_rate()
	var sd: float = mods.get("skill_dmg", 0.0)
	_skill_amp = maxf(0.1, 1.0 + sd * (GameData.SKILL_DMG_MULT if sd > 0.0 else 1.0))
	skill_mult_str = (_skill_base + GameData.INT_SKILL_DMG * eff_stat("str")) * _skill_amp
	skill_mult_int = (_skill_base + GameData.INT_SKILL_DMG * eff_stat("int")) * _skill_amp
	skill_mult = maxf(skill_mult_str, skill_mult_int)
	_skill_mult_cache.clear()
	proc_mult = 1.0 + GameData.STR_DMG * eff_stat("str") + mods.get("proc_dmg", 0.0)

	hit_proc_mult = 1.0 + GameData.STR_DMG * maxf(eff_stat("str"), eff_stat("vit")) + mods.get("proc_dmg", 0.0)
	proc_int_hit = GameData.STR_DMG * maxf(0.0, eff_stat("int") - maxf(eff_stat("str"), eff_stat("vit")))
	proc_dmg_bonus = mods.get("proc_dmg", 0.0)




	if not is_finite(max_hp) or max_hp < 1.0:
		if not _hp_warned:
			_hp_warned = true
			push_warning("max_hp %s: hp=%s vit=%s mods.max_hp=%s max_hp_pct=%s grade_hp=%s feathers=%s curse=%s host=%s" % [max_hp, 
				def.hp, eff_stat("vit"), mods.get("max_hp", 0.0), mods.get("max_hp_pct", 0.0), mods.get("grade_hp", 0.0), feathers, oath_curse, host_max_hp])
		max_hp = maxf(1.0, float(def.hp))
		if not is_finite(hp) or hp > max_hp or hp < 0.0:
			hp = max_hp
	if max_hp > old_max and old_max > 0.0:
		hp += max_hp - old_max
	if host_max_hp > 0.0 and is_finite(host_max_hp):
		max_hp = host_max_hp





var _last_mods: = {}
var _last_lone: = 0
func _counters() -> void :
	var mods: = _last_mods
	var lone: = _last_lone
	dmg_mult = 1.0 + mods.get("dmg", 0.0) + GameData.COIN_DMG * coins

	dmg_mult *= maxf(0.1, 1.0 + float(mods.get("risk_dmg", 0.0)))
	dmg_mult *= 1.0 + float(mods.get("grade_mult", 0.0))


	dmg_mult *= float(job2.get("dmg_more", 1.0))

	if hel_marks > 0:
		dmg_mult *= pow(GameData.HEL_MARK_DMG, hel_marks)

	if mpt_power > 0.0 and powers.has("over_thrust_x"):
		dmg_mult *= 1.0 + mpt_power
	crit = 0.03 + GameData.LUK_CRIT * eff_stat("luk") + mods.get("crit", 0.0) + (fury_crit if powers.has("critical_explosion") else 0.0) + GameData.COIN_CRIT * coins + float(GameData.PACTS.solitude.per_free.crit) * lone
	crit_dmg = 1.5 + mods.get("crit_dmg", 0.0) + GameData.LUK_CRIT_DMG * eff_stat("luk") + (fury_crit_dmg if powers.has("critical_explosion") else 0.0)

	crit_over = maxf(0.0, crit - 1.0)
	crit = minf(crit, 1.0)
	crit_dmg += crit_over * GameData.CRIT_OVERFLOW_DMG
	ultra_crit = crit_dmg >= GameData.ULTRA_CRIT_AT
	aspd_bonus = mods.get("aspd", 0.0) + (GameData.SPHERE_ASPD * spheres if sphere_max > 0 else 0.0)
	basic_mult = 1.0 + GameData.STR_DMG * basic_stat() + mods.get("basic_dmg", 0.0) + sphere_power * spheres\
	+ float(GameData.PACTS.solitude.per_free.basic_dmg) * lone
	proc_int_basic = GameData.STR_DMG * maxf(0.0, eff_stat("int") - basic_stat())


func refresh_counters() -> void :
	if _last_mods.is_empty():
		recompute()
	else:
		_counters()


func tick(delta: float, world: World) -> void :
	_check_seal()
	_attack_anim -= delta
	_since_attack += delta
	_attack_turn_lock = maxf(0.0, _attack_turn_lock - delta)
	_invuln -= delta
	_tick_powers(delta)
	_tick_legend(delta, world)

	if str(job2.get("id", "")) == "lord_knight" or has_meta("lk_imp"):
		LORD_KNIGHT.tick(world, self, delta)
	if has_dish("nine_tail_dish"):
		_tick_foxfire(world, delta)
	if has_uniq:
		Uniques.tick(world, self, delta)
	if not gospel.is_empty():
		_tick_gospel(world, delta)
	if powers.has("provoke_x"):
		_tick_provoke(world, delta)
	if not aura.is_empty():
		_tick_aura(world, delta)
	_stance_rest -= delta
	_kaahi_cd -= delta
	if powers.has("union") and hp > 1.0 and not effects.has("u_cosmos"):
		hp = maxf(1.0, hp - max_hp * GameData.UNION_DRAIN * delta)
	if falcon != null and visual != null:
		if falcon.dir != visual.dir:
			falcon.dir = visual.dir
			falcon._refresh()
		falcon.visible = _falcon_away <= 0.0
		_falcon_away -= delta

		falcon.position = FALCON_SPOT + Vector3(0, sin(Time.get_ticks_msec() * 0.004) * 0.08, 0)
	var stick: = input.move_vector(self, world)

	if choosing:
		stick = Vector2.ZERO
	_last_stick = stick
	blinking = maxf(0.0, blinking - delta)
	_skill_guard_t = maxf(0.0, _skill_guard_t - delta)
	_skill_safe = maxf(0.0, _skill_safe - delta)


	if blinking > 0.0:
		stick = Vector2.ZERO
	var move: = Vector3(stick.x, 0, stick.y)
	_moving = move.length_squared() > 0.0001
	if choosing:
		_tick_choosing(delta, world)
	_tick_heat(delta, world)
	if _moving and powers.has("sleipnir_gallop"):
		_gallop(delta, world)


	var want: = move * move_speed
	_vel = _vel.lerp(want, 1.0 - exp( - delta * 1.6)) if slip > 0.0 else want
	if not dash.is_empty():
		_tick_dash(world, delta)





		if input is HeroInput.Remote:
			var rd: = input as HeroInput.Remote
			rd.pos = position
			rd.deaf_until = Time.get_ticks_msec() + 400
			if Time.get_ticks_msec() >= rd.next_place:
				rd.next_place = Time.get_ticks_msec() + 100
				rd.placed = position
				world.net.place_remote(self, position)
	elif input is HeroInput.Remote:



		var r: = input as HeroInput.Remote
		if r.placed != Vector3.INF and Vector2(position.x - r.placed.x, position.z - r.placed.z).length() > 0.05:
			r.pos = position
			r.deaf_until = Time.get_ticks_msec() + 400

			if Time.get_ticks_msec() >= r.next_place:
				r.next_place = Time.get_ticks_msec() + 100
				r.placed = position
				world.net.place_remote(self, position)
		elif r.pos != Vector3.INF:
			position = Vector3(r.pos.x, world.map.height_at(r.pos), r.pos.z)
			r.placed = position
	elif _vel.length_squared() > 0.0004:
		var p: = world.map.slide(position, _vel * delta)
		position = Vector3(p.x, world.map.height_at(p), p.z)
	if _moving:
		facing = move.normalized()
		if _attack_anim <= 0.0:
			visual.face(move)
	_in_combat = world.any_enemy_near(position, 9.0)
	if _attack_anim <= 0.0:
		visual.speed_scale = 1.0
		if _moving:
			visual.play(RoVisual.PC_WALK)
		else:


			var bow: = str(look.get("weapon", "")).contains("bow")
			visual.play(RoVisual.PC_READY if _in_combat or bow else RoVisual.PC_IDLE)
	hp = minf(max_hp, hp + regen * heal_mult * delta)
	if cart != null:
		cart.follow(visual, _moving, world.map)

	_tick_spheres(delta)
	if _song_aura != null and is_instance_valid(_song_aura):
		Vfx.hold_dim(_song_aura, Vfx.dim)
	_tick_mirrors(delta)
	_cicada_t += delta
	_tick_coins()
	_hindsight_cd = maxf(0.0, _hindsight_cd - delta)


	if choosing:
		return
	_basic_attack(delta, world)

	_tick_songs(world, delta)


	if powers.has("oath_silence"):
		return

	if has_meta("soul_wheel"):
		World.SoulLinker.tick(world, self, delta)
	for id in skills:
		if GameData.SKILLS[id].type == "passive" or GameData.SKILLS[id].get("stance", false):
			continue
		var s: Dictionary = skills[id]

		s.cd -= delta * world.raid.ymir_hero_cd() * world.morroc.hero_cd()


		if GameData.SKILLS[id].get("song", false) and ( not songs.has(id) or GameData.SKILLS[id].type == "buff"):
			continue


		if is_off(id) or is_hold(id) or GameData.STILL_SKILLS.has(base_skill(id)):
			continue
		if s.cd <= 0.0:
			if Skills.cast(world, self, id, s.level):
				_after_cast(id, world)
				if has_uniq:
					Uniques.after_cast(world, self, id)
				if effects.has("chain_cast"):
					cut_cooldowns(float(effects.chain_cast), true)
				s.cd = GameData.skill_value(id, "cooldown", s.level) * cd_for(id)
				s["cut"] = 0.0
			elif blinking > 0.0 and GameData.SKILLS[id].type == "backstab":



				s.cd = minf(0.15, blinking)
			else:
				s.cd = 0.15




func area_overflow_rate() -> float:
	return GameData.AMP_OVERFLOW_DMG if float(effects.get("amp", 0.0)) > 0.0 else GameData.AREA_OVERFLOW_DMG






func double_cast_chance(id: = "") -> float:
	var pts: = maxf(eff_stat("str"), eff_stat("int"))
	if id != "":
		var w: = skill_weights(id)
		pts = float(w.get("str", 0.0)) * eff_stat("str") + float(w.get("int", 0.0)) * eff_stat("int")
	var sage: = 0.0
	if id != "" and float(effects.get("sage_double", 0.0)) > 0.0:



		if str(job2.get("id", "")) in ["sage", "professor"]:
			sage = float(effects.sage_double) * (GameData.SAGE_DOUBLE_PROF if str(job2.get("id", "")) == "professor" else 1.0)
		elif is_plagiarized("double_casting"):

			sage = float(effects.sage_double) * GameData.SAGE_DOUBLE_COPIED
	return minf(GameData.INT_DOUBLE_MAX, GameData.INT_DOUBLE * pts) + float(effects.get("double_cast", 0.0)) + sage





func skill_mult_for(tag: String) -> float:


	var m = _skill_mult_cache.get(tag)
	if m == null:
		var id: = GameData.skill_of_tag(tag)
		var out: = skill_mult_int if tag in GameData.MAGIC_TAGS else (maxf(skill_mult, skill_mult_int) if tag in GameData.HYBRID_TAGS else skill_mult)
		var hp_w: = 0.0
		if id != "":
			out = _skill_base
			var w: = skill_weights(id)
			for k in w:
				if k == "hp":
					hp_w += float(w[k])
				else:
					out += float(w[k]) * GameData.INT_SKILL_DMG * eff_stat(k)
			out *= _skill_amp
		m = [out, hp_w]
		_skill_mult_cache[tag] = m
	return m[0] + (m[1] * GameData.INT_SKILL_DMG * hp_stat() * _skill_amp if m[1] > 0.0 else 0.0)





func scaling_hp() -> float:
	return max_hp + maxf(0.0, shield)




func hp_stat() -> float:
	return pow(maxf(1.0, scaling_hp()), GameData.HP_STAT_POW) / GameData.HP_STAT_DIV









func haste_raw() -> float:
	return _haste + _agi_haste


func haste_effective(raw: = -1.0) -> float:
	return GameData.soft_haste(haste_raw() if raw < 0.0 else raw)




func own_buff_bonus(id: String, key: String) -> float:
	if not skills.has(id) or not GameData.SKILLS.has(id):
		return 0.0
	var val: = GameData.skill_value(id, key, int(skills[id].level))
	return val * buff_mult_for(key, id) if str(GameData.SKILLS[id].type) == "buff" else val


func cd_for(id: String) -> float:
	var h: = _haste + _agi_haste * (1.0 - float(skill_weights(id).get("int", 0.0)))


	if effects.has("lg_asura_haste") and base_skill(id) == "asura_strike" and GameData.SKILLS.has(id):
		var full: = 1.0 / (1.0 + maxf(0.0, h)) / (1.0 + _grade_haste)
		var base: = GameData.skill_value(id, "cooldown", int(skills[id].level) if skills.has(id) else 1)
		return maxf(full, GameData.ASURA_LG_MIN_CD / base) if base > GameData.ASURA_LG_MIN_CD else 1.0
	return 1.0 / (1.0 + GameData.soft_haste(h)) / (1.0 + _grade_haste)






func skill_weights(id: String) -> Dictionary:
	if is_plagiarized(id) or GameData.HIGHER_STAT_SKILLS.has(base_skill(id)):
		return {"int": 1.0} if eff_stat("int") > eff_stat("str") else {"str": 1.0}
	return GameData.skill_stats(id)




func scaling_text(id: String) -> String:
	if is_plagiarized(id) or GameData.HIGHER_STAT_SKILLS.has(base_skill(id)):
		return tr("La más alta de FUE e INT")
	return GameData.skill_scaling(id)


func _double_cast(id: String, w: World) -> void :
	var s: Dictionary = GameData.SKILLS[id]
	if not s.has("damage") or str(s.type) in ["buff", "passive", "shield", "heal", "summon"]:
		return
	var extra: = multi_casts(double_cast_chance(id))
	if extra <= 0:
		return
	var lv: = int(skills[id].level) if skills.has(id) else 1


	var words: Array = [tr("¡Doble!"), tr("¡Triple!"), tr("¡Cuádruple!")]
	var colors: Array = [Color(0.75, 0.6, 1.0), Color(0.4, 0.85, 1.0), Color(1.0, 0.78, 0.25)]
	for i in extra:
		w._own_timer(GameData.INT_DOUBLE_DELAY * (i + 1), func():
			if is_instance_valid(self) and not downed and hp > 0.0 and w.running:
				w.number(position + Vector3(0, 2.4, 0), str(words[i]), colors[i], true, false, false, 1.0, false, true, false, "", 1.1 + 0.22 * i)
				Skills.cast(w, self, id, lv))





static func multi_casts(c: float) -> int:
	if c <= 0.0:
		return 0
	var n: = floori(c)
	if randf() < c - float(n):
		n += 1
	return mini(n, GameData.MULTI_CAST_MAX)





func hit_resist() -> float:
	return minf(GameData.HIT_RESIST_MAX, GameData.HIT_RESIST_VIT * eff_stat("vit"))


func damage_reduction() -> float:
	return maxf(0.0, armor) / (maxf(0.0, armor) + GameData.DEF_K)




func block_chance() -> float:
	var base: = float(effects.get("block", 0.0))
	var r: = equipment.shield_refine() if equipment != null else -1
	if base <= 0.0 or r < 0:
		return 0.0
	return minf(GameData.BLOCK_MAX, base + GameData.BLOCK_PER_REFINE * r)




func shield_mult(per_refine: float) -> float:
	var r: = equipment.shield_refine()
	if r < 0:
		return 1.0
	return 1.0 + per_refine * r + GameData.SHIELD_RANK_DMG * (equipment.shield_rank() - 1)



func take_spheres(n: int) -> int:
	var got: = mini(n, spheres)
	spheres -= got
	if got > 0:
		refresh_counters()
	return got



var sphere_power: = 0.0




func sphere_hit() -> void :
	if spheres >= sphere_max:
		return
	_sphere_hits += 2.0 if powers.has("critical_explosion") else 1.0
	var now: = World.game_ms() * 0.001
	if _sphere_hits >= GameData.SPHERE_HITS and now >= _sphere_next:
		_sphere_hits = 0.0
		_sphere_next = now + GameData.SPHERE_GAIN_CD
		spheres += 1

		refresh_counters()





func _tick_spheres(_delta: float) -> void :
	_tick_fury()
	_tick_forge()
	_tick_charms()
	_draw_wing_glow()
	if ov_stage > 0 or uniq.has("ov_nodes"):
		Uniques.draw_overload(self)
	draw_bonds()

	if has_meta("lk_imp") or has_meta("lk_ring"):
		LORD_KNIGHT.draw(self)
	if has_meta("pal_charges") or has_meta("pal_nodes"):
		PALADIN.draw(self)
	if has_meta("lk_edge") or has_meta("lk_edge_nodes"):
		LORD_KNIGHT.draw_edge(self)
	if sphere_max <= 0:
		return
	spheres = mini(spheres, sphere_max)
	draw_spheres()




func draw_bonds() -> void :
	var n: = mini(soul_bonds, GameData.SOUL_BOND_MAX)
	while _bond_nodes.size() < n:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 32)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 15
		s.modulate = Color(0.85, 0.78, 1.0, 0.55)
		s.pixel_size = GameData.PIXEL_SIZE * 0.55
		add_child(s)
		_bond_nodes.append(s)
	while _bond_nodes.size() > n:
		_bond_nodes.pop_back().queue_free()
	if n == 0 or visual == null:
		return
	var t: = Time.get_ticks_msec() * 0.0009
	for i in n:
		var a: = t + TAU * i / float(n)
		var c: = _bond_nodes[i]
		c.position = RoVisual.lift + Vector3(cos(a) * 0.55, visual.height() + 0.25 + sin(a * 3.0 + i) * 0.06, sin(a) * 0.55)
		c.modulate.a = 0.38 + 0.2 * (0.5 + 0.5 * sin(a))




func draw_spheres() -> void :
	_draw_wing_glow()
	draw_bonds()
	if ov_stage > 0 or uniq.has("ov_nodes"):
		Uniques.draw_overload(self)
	if has_meta("lk_imp") or has_meta("lk_ring"):
		LORD_KNIGHT.draw(self)
	if has_meta("pal_charges") or has_meta("pal_nodes"):
		PALADIN.draw(self)
	if has_meta("lk_edge") or has_meta("lk_edge_nodes"):
		LORD_KNIGHT.draw_edge(self)

	if uniq.has("net_u"):
		Uniques.draw_puppet(self)
	while _sphere_nodes.size() < spheres:
		var s: = Sprite3D.new()
		s.texture = RoAssets.effect_tex("spirit_ball_1")
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR


		s.modulate = Color(0.88, 0.96, 1.0)
		s.pixel_size = GameData.PIXEL_SIZE * 0.7
		s.add_child(_glow_quad(0.5, Color(0.35, 0.65, 1.0, 0.7)))
		add_child(s)
		_sphere_nodes.append(s)
	while _sphere_nodes.size() > spheres:
		_sphere_nodes.pop_back().queue_free()
	var t: = Time.get_ticks_msec() * 0.0022
	for i in _sphere_nodes.size():
		var a: = t + TAU * i / maxf(1.0, _sphere_nodes.size())
		var c: = _sphere_nodes[i]
		var off: = Vector3(cos(a) * 0.95, visual.height() * 0.6 + sin(a * 2.0 + t) * 0.1, sin(a) * 0.95)
		var front: = sin(a) > 0.0
		if not front:
			var view: = RoVisual.lift.normalized()
			off -= view * maxf(0.0, off.dot(view) + 0.3)
		c.position = RoVisual.lift + off
		if c.no_depth_test != front or c.render_priority < 16:
			c.no_depth_test = front
			c.render_priority = 20 if front else 16
			var gm: StandardMaterial3D = (c.get_child(0) as MeshInstance3D).material_override
			gm.no_depth_test = front
			gm.render_priority = 19 if front else 15





var _wing_glow: MeshInstance3D
const HEL_LOOK: = preload("res://scripts/ro/hel_wings.gd")
var _wing_glow_col: = Color(0, 0, 0, 0)


func _draw_wing_glow() -> void :


	if visual != null:
		HEL_LOOK.set_on(visual, Equipment.hel_wings(equipment.slots.get("wings") if equipment != null else null))
	var col: = Equipment.wings_glow(equipment.slots.get("wings") if equipment != null else null)
	if col.a <= 0.0:
		if _wing_glow != null:
			_wing_glow.queue_free()
			_wing_glow = null
		return
	if _wing_glow == null or col != _wing_glow_col:
		if _wing_glow != null:
			_wing_glow.queue_free()
		_wing_glow = _glow_quad(3.6, Color(col, 0.9))
		var m: StandardMaterial3D = _wing_glow.material_override

		m.no_depth_test = true
		m.render_priority = -2
		add_child(_wing_glow)
		_wing_glow_col = col
	var t: = Time.get_ticks_msec() / 1000.0
	var view: = RoVisual.lift.normalized()
	var h: = visual.height() if visual != null else 1.6
	_wing_glow.position = RoVisual.lift + Vector3(0, h * 0.62, 0) - view * 0.35
	_wing_glow.scale = Vector3.ONE * (1.0 + 0.08 * sin(t * 2.2))
	(_wing_glow.material_override as StandardMaterial3D).albedo_color = Color(col * 1.5, (0.6 + 0.15 * sin(t * 2.2)) * Vfx.dim)



static func _glow_quad(size: float, col: Color) -> MeshInstance3D:
	var mi: = MeshInstance3D.new()
	var q: = QuadMesh.new()
	q.size = Vector2(size, size)
	mi.mesh = q
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.albedo_texture = RoAssets.radial(Color.WHITE, 64)
	m.albedo_color = col
	m.render_priority = 15
	m.no_depth_test = true
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi




func _tick_fury() -> void :
	var on: = powers.has("critical_explosion")
	if on == (_fury_aura != null):
		if on:
			var g: MeshInstance3D = _fury_aura.get_child(0)

			(g.material_override as StandardMaterial3D).albedo_color.a = (0.55 + 0.25 * sin(Time.get_ticks_msec() * 0.012)) * Vfx.dim
		return
	if not on:
		_fury_aura.queue_free()
		_fury_aura = null
		return
	_fury_aura = Node3D.new()
	add_child(_fury_aura)
	_fury_aura.position = RoVisual.lift * 0.98
	var glow: = _glow_quad(3.2, Color(1.0, 0.72, 0.2, 0.75))
	glow.position = Vector3(0, visual.height() * 0.5, 0)
	_fury_aura.add_child(glow)
	var p: = CPUParticles3D.new()
	var quad: = QuadMesh.new()
	quad.size = Vector2(0.16, 0.16)
	var pm: = StandardMaterial3D.new()
	pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	pm.vertex_color_use_as_albedo = true
	pm.albedo_texture = RoAssets.radial(Color.WHITE, 32)
	quad.material = pm
	p.mesh = quad
	p.amount = 24
	p.lifetime = 0.8
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	p.emission_ring_axis = Vector3.UP
	p.emission_ring_radius = 0.55
	p.emission_ring_inner_radius = 0.2
	p.emission_ring_height = 0.0
	p.direction = Vector3.UP
	p.spread = 8.0
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 1.6
	p.initial_velocity_max = 2.8
	var ramp: = Gradient.new()
	ramp.set_color(0, Color(1.0, 0.95, 0.6, 1.0))
	ramp.set_color(ramp.get_point_count() - 1, Color(1.0, 0.6, 0.15, 0.0))
	p.color_ramp = ramp
	_fury_aura.add_child(p)
	p.emitting = true



func combo_on() -> bool:

	return str(job2.get("id", "")) in GameData.COMBO_JOBS or pacts.has("elements")



func kunai_on() -> bool:
	return str(job2.get("id", "")) in GameData.KUNAI_JOBS



func _after_cast(id: String, world: World) -> void :
	_double_cast(id, world)
	Skills.flair(world, self, id)

	if class_id == "taekwon":
		World.SoulLinker.after_cast(world, self, id)
	if kunai_on() and GameData.SKILLS[id].get("ninjutsu", false):
		charms.append(str(GameData.SKILLS[id].get("element", "fire")))
		while charms.size() > GameData.CHARM_MAX:
			charms.pop_front()





func _tick_charms() -> void :
	while _charm_nodes.size() > charms.size():
		var gone: Sprite3D = _charm_nodes.pop_back()
		if is_instance_valid(gone):
			gone.queue_free()
	while _charm_nodes.size() < charms.size():
		var s: = Sprite3D.new()
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.texture = RoAssets.effect_tex("charm_talisman")
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
		s.pixel_size = 0.011
		add_child(s)
		s.scale = Vector3.ONE * 0.2
		s.create_tween().tween_property(s, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_charm_nodes.append(s)
	var n: = _charm_nodes.size()
	var now: = Time.get_ticks_msec() * 0.001
	for i in n:
		var s: = _charm_nodes[i]
		var el: = str(charms[i])
		if not s.has_meta("el") or str(s.get_meta("el")) != el:
			s.modulate = GameData.CHARM_TINT.get(el, Color.WHITE)
			s.set_meta("el", el)
		var a: = now * 2.2 + TAU * i / n
		var off: = Vector3(cos(a) * 0.85, visual.height() * 0.55 + sin(now * 3.0 + i) * 0.08, sin(a) * 0.85)
		var front: = sin(a) > 0.0
		if not front:

			var view: = RoVisual.lift.normalized()
			off -= view * maxf(0.0, off.dot(view) + 0.3)
		s.position = RoVisual.lift + off
		s.no_depth_test = front
		s.render_priority = 20 if front else 16







func buff_mult(id: = "") -> float:
	return (1.0 + float(effects.get("buff_power", 0.0)) + grace_buff(id)) * (1.0 + GameData.DEX_SUPPORT * eff_stat("dex"))






func buff_mult_for(key: String, id: = "") -> float:
	var dmg: = key in GameData.BUFF_POWER_DMG_KEYS
	var bp: = (float(effects.get("buff_power", 0.0)) + grace_buff(id)) * (GameData.BUFF_POWER_DMG_SHARE if dmg else 1.0)
	if key == "aura_stats":
		return 1.0 + bp

	return (1.0 + bp) * (1.0 + GameData.DEX_SUPPORT * eff_stat("dex") * (GameData.BUFF_DEX_DMG_SHARE if dmg else 1.0))






func grace_on(id: String) -> bool:
	if id == "" or not effects.has("grace_buff"):
		return false
	if is_plagiarized(id):
		return true
	if class_id == "super_novice":
		return false
	return (def.skills + def.get("passives", []) + job2.get("skills", []) + job2.get("passives", [])).has(base_skill(id))



func grace_buff(id: String) -> float:
	return float(effects.get("grace_buff", 0.0)) if grace_on(id) else 0.0



func grace_power(id: String, key: String) -> float:
	return float(effects.get(key, 0.0)) if grace_on(id) else 0.0




func debuff_mult(id: String) -> float:
	return 1.0 + (float(effects.get("grace_debuff", 0.0)) if grace_on(id) else 0.0)


func buff_boost() -> float:

	return 1.0 + float(effects.get("buff_power", 0.0))




func buff_boost_dmg() -> float:
	return 1.0 + float(effects.get("buff_power", 0.0)) * GameData.BUFF_POWER_DMG_SHARE



func forge_on() -> bool:
	return str(job2.get("id", "")) in GameData.FORGE_JOBS


func weapon_refine() -> int:
	var it = equipment.slots.get("weapon") if equipment != null else null
	return int(it.refine) if it != null else 0



func forge_refine() -> int:
	return weapon_refine() + forge


func forge_safe() -> int:
	var it = equipment.slots.get("weapon") if equipment != null else null
	return Equipment.refine_safe(it) if it != null else int(GameData.REFINE_SAFE.weapon)


func forge_max() -> int:
	return GameData.FORGE_MAX_WS if str(job2.get("id", "")) == "whitesmith" else GameData.FORGE_MAX




func forge_break_chance(to: int) -> float:
	var step: = GameData.FORGE_BREAK_WS if str(job2.get("id", "")) == "whitesmith" else GameData.FORGE_BREAK
	if powers.has("over_thrust_x"):
		step *= GameData.MPT_BREAK
	return clampf(step * (to - forge_safe()), 0.0, 0.9)




func forge_floor() -> int:
	return maxi(forge_safe(), weapon_refine())




func forge_temp_levels() -> float:
	if not forge_on():
		return 0.0
	return maxf(0.0, forge_refine() - forge_floor() + clampf(forge_heat, 0.0, 1.0))



func forge_temp() -> float:
	return clampf(forge_temp_levels() / GameData.FORGE_TEMP_FULL, 0.0, 1.0)



func tempered() -> String:
	return temper_el if temper_el != "" and powers.has("temper_" + temper_el) else ""




func _tick_forge() -> void :
	var over: = forge_refine() - forge_safe() if forge_on() else 0
	if over <= 0:
		if _forge_aura != null:
			_forge_aura.queue_free()
			_forge_aura = null
		return
	if _forge_aura == null:
		_forge_aura = Node3D.new()
		add_child(_forge_aura)
		_forge_aura.position = RoVisual.lift * 0.98
		var glow: = _glow_quad(2.4, Color(1.0, 0.5, 0.15, 0.4))
		glow.position = Vector3(0, visual.height() * 0.45, 0)
		_forge_aura.add_child(glow)
		var p: = CPUParticles3D.new()
		var quad: = QuadMesh.new()
		quad.size = Vector2(0.13, 0.13)
		var pm: = StandardMaterial3D.new()
		pm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		pm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		pm.vertex_color_use_as_albedo = true
		pm.albedo_texture = RoAssets.radial(Color.WHITE, 16)
		quad.material = pm
		p.mesh = quad
		p.amount = 28
		p.lifetime = 0.9
		p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		p.emission_sphere_radius = 0.45
		p.position = Vector3(0, visual.height() * 0.4, 0)
		p.direction = Vector3.UP
		p.spread = 25.0
		p.gravity = Vector3(0, 0.6, 0)
		p.initial_velocity_min = 0.6
		p.initial_velocity_max = 1.6
		var ramp: = Gradient.new()
		ramp.set_color(0, Color(1.0, 0.9, 0.5, 1.0))
		ramp.set_color(ramp.get_point_count() - 1, Color(1.0, 0.25, 0.05, 0.0))
		p.color_ramp = ramp
		_forge_aura.add_child(p)
		p.emitting = true
	var danger: = clampf(forge_break_chance(forge_refine() + 1) / 0.5, 0.0, 1.0)
	var col: = Color(1.0, 0.55, 0.15).lerp(Color(1.0, 0.12, 0.08), danger)
	var beat: = 0.8 + 0.2 * sin(Time.get_ticks_msec() * (0.006 + 0.018 * danger))
	var g: MeshInstance3D = _forge_aura.get_child(0)
	(g.material_override as StandardMaterial3D).albedo_color = Color(col, (0.3 + 0.45 * danger) * beat)
	(_forge_aura.get_child(1) as CPUParticles3D).speed_scale = 0.8 + 1.6 * danger




func homun_cap() -> int:
	if homun_level() <= 0:
		return 0
	return 1 + (1 if str(job2.get("id", "")) == "creator" else 0) + int(effects.get("homun_extra", 0.0)) + (1 if homun_mutated() else 0)



func homun_level() -> int:
	if skills.has("call_homunculus_x"):
		return GameData.MAX_SKILL_LEVEL + int(skills.call_homunculus_x.level)
	return int(skills.get("call_homunculus", {"level": 0}).level)



func homun_mutated() -> bool:
	return skills.has("call_homunculus_x")



func ro_stat(id: String) -> int:
	return 1 + int(stats[id]) * GameData.RO_STAT_PER_PICK




func capped_ro(id: String) -> float:
	return 1.0 + eff_stat(id) * GameData.RO_STAT_PER_PICK





func agi_aspd_cut() -> float:
	return (1.0 + eff_stat("agi") * GameData.AGI_ASPD_PER_POINT) / GameData.AGI_ASPD_DIV / 10.0



func aspd() -> float:
	var basic: Dictionary = def.basic
	var base: = float(basic.aspd) + float(weapon_feel().aspd)
	if not job2.is_empty():
		base += float(GameData.JOB_ASPD_BONUS["trans" if reborn else "job2"])
	var wd: = 200.0 - base
	var cut: = agi_aspd_cut()

	return 200.0 - wd * _keep(cut) * _keep(maxf(0.0, aspd_bonus))





static func _keep(cut: float) -> float:
	return 1.0 - cut if cut <= 0.8 else 0.2 / (1.0 + 5.0 * (cut - 0.8))



func attack_delay() -> float:
	return maxf(GameData.MIN_ATTACK_DELAY, (200.0 - aspd()) * 0.02)








func swing_hits() -> float:
	var basic: Dictionary = def.basic
	var base: = float(basic.aspd) + float(weapon_feel().aspd)
	if not job2.is_empty():
		base += float(GameData.JOB_ASPD_BONUS["trans" if reborn else "job2"])
	var cut: = agi_aspd_cut()
	var raw: = (200.0 - base) * _keep(cut) * _keep(maxf(0.0, aspd_bonus)) * 0.02
	var hits: = maxf(1.0, GameData.MIN_ATTACK_DELAY / maxf(raw, 1e-09))




	if hits > GameData.SWING_SOFT_FROM:
		hits = GameData.SWING_SOFT_FROM + pow(hits - GameData.SWING_SOFT_FROM, GameData.SWING_SOFT_POW)
	return hits




func homun_atk() -> float:
	return (float(def.basic.atk) + capped_ro("int") * GameData.BASIC_STR_ATK) * float(weapon_feel().dmg)



func basic_atk() -> float:
	var basic: Dictionary = def.basic




	var power: = maxf(capped_ro("str"), capped_ro("int")) if basic_by_int() else capped_ro("str")
	return (float(basic.atk) + power * GameData.BASIC_STR_ATK) * (1.0 + float(effects.get("aura_blade", 0.0))) * _tongue_now * float(weapon_feel().dmg)




func basic_stat() -> float:
	if basic_by_int():
		return maxf(eff_stat("str"), eff_stat("int"))
	return eff_stat("str")




func basic_by_int() -> bool:
	return skills.has("mace_mastery")





func weapon_feel() -> Dictionary:
	var none: = {"aspd": 0.0, "dmg": 1.0, "reach": 0.0}
	if equipment == null or equipment.slots.weapon == null:
		return none
	var kind: = GameData.weapon_kind(str(equipment.slots.weapon.id))
	var base: = own_weapon_kind()
	var a: Dictionary = GameData.WEAPON_KIND_ATTACK.get(kind, {})
	var b: Dictionary = GameData.WEAPON_KIND_ATTACK.get(base, {})
	if kind == base or a.is_empty() or b.is_empty():
		return none
	return {"aspd": float(a.aspd) - float(b.aspd), "dmg": float(a.dmg) / float(b.dmg), "reach": float(a.reach) - float(b.reach)}




func own_weapon_kind() -> String:
	var who: = str(job2.get("id", "")) if not job2.is_empty() else class_id
	var kinds: Array = GameData.JOB_WEAPON_KINDS.get(who, GameData.JOB_WEAPON_KINDS.get(class_id, []))
	return str(kinds[0]) if not kinds.is_empty() else ""





func ammo() -> Dictionary:
	return GameData.AMMO[def.get("ammo", "arrows")]




func can_switch_ammo() -> bool:
	return def.get("ammo", "") != "" or skills.has("making_arrow")


func add_arrow(id: String) -> bool:
	if quiver.has(id) or not ammo().has(id):
		return false
	quiver.append(id)
	return true


func set_arrow(id: String) -> void :
	if quiver.has(id):
		arrow_id = id



func cycle_arrow(step: int) -> bool:
	if not can_switch_ammo() or quiver.size() < 2:
		return false
	arrow_id = quiver[posmod(quiver.find(arrow_id) + step, quiver.size())]
	return true




func arrow_element() -> String:
	var a: = ammo_element()
	if a == "neutral" and equipment != null:
		return Equipment.weapon_element(equipment.slots.weapon)
	return a



func ammo_element() -> String:
	return str(ammo()[arrow_id].element) if ammo().has(arrow_id) else "neutral"





func arrow_bonus() -> float:
	var a: = ammo_element()
	if a == "neutral":
		return 1.0
	var m: = 1.0 + float(effects.get("arrow_dmg", 0.0))
	if equipment != null and Equipment.weapon_element(equipment.slots.weapon) == a:
		m *= 1.0 + GameData.ENDOW_MATCH
	return m




func poison_weapon() -> bool:
	return skills.has("enchant_poison") or skills.has("edp")




func basic_element() -> String:

	if mild_element != "" and powers.has("mild_wind"):
		return mild_element

	if effects.has("holy_weapon"):
		return "holy"
	if def.basic.ranged:
		return arrow_element()
	if equipment != null and equipment.slots.weapon != null:
		return Equipment.weapon_element(equipment.slots.weapon)
	return "neutral"




func summon_reach() -> float:
	return float(meta.get("reach", 0.0)) * GameData.REACH_SUMMON



func _basic_attack(delta: float, world: World) -> void :
	_attack_timer -= delta
	if _attack_timer > 0.0:
		return
	var basic: Dictionary = def.basic

	var scope: = float(meta.get("reach", 0.0))
	var reach: = float(basic.range) + float(weapon_feel().reach) + (scope * GameData.REACH_RANGED if basic.ranged else 0.6 + scope * GameData.REACH_MELEE)
	var target: = world.nearest_enemy(position, reach)




	if target == null and not basic.ranged:
		for big in world.nearest_enemies(position, reach * (1.0 + GameData.MELEE_BOSS_REACH), 8):
			if big.is_boss:
				target = big
				break
	if target == null:
		_attack_timer = 0.1
		return
	_attack_timer = attack_delay()

	if Uniques.cannon(self) != "":
		Uniques.overload_swing(world, self, target)
	var to: = (target.position - position) * Vector3(1, 0, 1)
	play_attack(to)


	var flow: = swing_hits()
	var hits: = int(flow)
	if randf() < flow - hits:
		hits += 1
	var power: = 1.0
	if hits > GameData.MAX_SWING_HITS:
		power = float(hits) / GameData.MAX_SWING_HITS
		hits = GameData.MAX_SWING_HITS
	_hit_power = power
	if has_dish("steamed_tongue"):

		var r: Dictionary = GameData.RECIPES.steamed_tongue
		var was: = tongue_charge if world.time < _tongue_until else 0.0
		tongue_charge = minf(float(r.cap), was + float(r.step))
		_tongue_until = world.time + float(r.window)
		_tongue_now = 1.0 + tongue_charge
		if tongue_charge >= float(r.cap) and was < float(r.cap):
			world.number(position + Vector3(0, 2.0, 0), tr("¡Ñam!"), Color(1.0, 0.7, 0.4), true)
	if basic.get("bullet", false):

		world.damage_tag = "basic"
		world.damage_by = self
		world.hitscan(self, target, basic_atk() * arrow_bonus() * power, basic_bounces(), basic_element(), {"basic": true})
		for i in range(1, hits):
			world.hitscan(self, target, basic_atk() * arrow_bonus() * power, basic_bounces(), basic_element(), {"basic": true}, 
				0.0, GameData.MIN_ATTACK_DELAY * i / hits)

		var extra: = _basic_extra_targets(world, target, reach)
		for k in extra.size():
			world.hitscan(self, extra[k], basic_atk() * arrow_bonus() * power * GameData.BASIC_EXTRA_DMG, basic_bounces(), basic_element(), 
				{"basic": true}, 0.0, GameData.MIN_ATTACK_DELAY * (k + 1) / (extra.size() + 1))
		world.play_sound(str(GameData.GUN_SOUNDS.get(gun_look(), basic.sound)), 0.12, -8.0)

		for i in double_hits():
			world.hitscan(self, target, basic_atk() * arrow_bonus(), 0, basic_element(), {"basic": true}, 0.0, 0.1 * (i + 1))
	elif basic.ranged:
		var dir: = to.normalized()
		var shoot: = func(d: Vector3, dmg: float, delay: float, at: Enemy):
			world.spawn_projectile({
				"source": "basic", 
				"pos": position + BOW_MUZZLE_UP + d * BOW_MUZZLE_AHEAD, "dir": d, "speed": 20.0 * proj_mult, 
				"damage": dmg, "pierce": 0, "size": 0.22, "color": Color(0.95, 0.9, 0.75), 
				"slow": 0.0, "knock": 1.0, "arrow": not basic.get("bullet", false), "delay": delay, 
				"hit_fx": "", "hit_fx_intensity": 1.0, 
				"hit_sound": basic.get("hit_sound", ""), "basic": true, "element": basic_element(), "tag": "basic", 
				"bounces": basic_bounces(), 

				"seek": at, 
			})
		for i in hits:

			var d: = dir.rotated(Vector3.UP, 0.0 if i == 0 else (0.05 if i % 2 == 1 else -0.05) * ceilf(i / 2.0))
			shoot.call(d, basic_atk() * arrow_bonus() * power, GameData.MIN_ATTACK_DELAY * i / hits, target)

		var extra: = _basic_extra_targets(world, target, reach)
		for k in extra.size():
			var e: Enemy = extra[k]
			var away: = (e.position - position) * Vector3(1, 0, 1)
			shoot.call(away.normalized() if away.length() > 0.05 else dir, basic_atk() * arrow_bonus() * power * GameData.BASIC_EXTRA_DMG, 
				GameData.MIN_ATTACK_DELAY * (k + 1) / (extra.size() + 1), e)
		world.play_sound(basic.sound, 0.25, -8.0)
	else:
		world.damage_tag = "basic"
		world.damage_by = self
		world.damage_enemy(target, basic_atk() * power, to.normalized() * 2.0, "basic", basic_element())
		world.play_sound(basic.sound, 0.12, -6.0)
		on_basic_hit(world, target)
		_cleave(world, target, reach, power)



		for i in range(1, hits):
			if target == null or not is_instance_valid(target) or target.dead:
				target = world.nearest_enemy(position, reach)
				if target == null:
					break
			world.damage_enemy(target, basic_atk() * power, Vector3.ZERO, "basic", basic_element())
			on_basic_hit(world, target)
			_cleave(world, target, reach, power)


		for i in int(meta.get("melee_hits", 0.0)) + maxi(0, extra_count - int(meta.get("count", 0.0))):
			if target == null or not is_instance_valid(target) or target.dead:
				target = world.nearest_enemy(position, reach)
				if target == null:
					break
			world.damage_enemy(target, basic_atk() * power * GameData.BASIC_EXTRA_DMG, Vector3.ZERO, "basic", basic_element())
			on_basic_hit(world, target)
			_cleave(world, target, reach, power * GameData.BASIC_EXTRA_DMG)


		for i in double_hits():
			if target == null or not is_instance_valid(target) or target.dead:
				target = world.nearest_enemy(position, reach)
				if target == null:
					break
			world.damage_enemy(target, basic_atk(), Vector3.ZERO, "basic", basic_element())
			on_basic_hit(world, target)

		var left: = equipment.offhand() if equipment != null else {}
		if not left.is_empty():
			if target == null or not is_instance_valid(target) or target.dead:
				target = world.nearest_enemy(position, reach)
			if target != null:
				world.damage_enemy(target, basic_atk() * equipment.offhand_mult(left), Vector3.ZERO, "basic", basic_element())
				on_basic_hit(world, target)
	_tongue_now = 1.0






const DOUBLE_MAX_HITS: = 9
func double_hits() -> int:
	var c: = maxf(0.0, float(effects.get("double", 0.0)))
	var n: = int(c)
	if randf() < c - float(n):
		n += 1

	var chain: = float(effects.get("lg_chain_double", 0.0))
	if n > 0 and chain > 0.0:
		while n < DOUBLE_MAX_HITS and randf() < chain:
			n += 1
	return mini(n, DOUBLE_MAX_HITS)





func _cleave(world: World, target: Enemy, reach: float, power: float) -> void :
	var extra: = agi_extra() + free_slot_bonus() + int(effects.get("cleave_extra", 0.0))
	if extra <= 0:
		return
	var sweep: = (reach + GameData.AGI_CLEAVE_SWEEP + float(effects.get("cleave_reach", 0.0))) * sqrt(area_mult)
	sweep += float(GameData.PACTS.solitude.per_free.area) * free_slot_bonus() + float(meta.get("reach", 0.0)) * GameData.REACH_SWEEP
	var share: = GameData.AGI_CLEAVE_DMG + float(effects.get("cleave_dmg", 0.0))
	var near: = world.enemies_in_radius(position, sweep).filter( func(e): return e != target)
	near.sort_custom( func(a, b): return position.distance_squared_to(a.position) < position.distance_squared_to(b.position))

	for e in near.slice(0, extra):
		world.pool_basic(e, basic_atk() * share * power, ((e.position - position) * Vector3(1, 0, 1)).normalized() * 1.2, 
			basic_element(), self)





func _basic_extra_targets(world: World, target: Enemy, reach: float) -> Array[Enemy]:
	var out: Array[Enemy] = []
	if extra_count <= 0:
		return out
	for e in world.nearest_enemies(position, reach, extra_count + 1):
		if e != target and out.size() < extra_count:
			out.append(e)
	while out.size() < extra_count:
		out.append(target)
	return out








func _wing_cards() -> Array:
	if equipment == null or equipment.slots.get("wings") == null:
		return []
	var w: Dictionary = equipment.slots.wings
	if float(GameData.wing_fx(int(w.get("refine", 0))).get("wing_card", 0.0)) <= 0.0:
		return []
	return (w.get("cards", []) as Array).duplicate()


static func _proc_more(pr: Dictionary, more: float) -> Dictionary:
	if more <= 0.0:
		return pr
	var out: = pr.duplicate()
	out["chance"] = float(pr.chance) * (1.0 + more)
	return out




func refund_cooldowns(share: float) -> void :
	for id in skills:
		if GameData.SKILLS[id].type == "passive":
			continue
		var s: Dictionary = skills[id]
		if float(s.cd) > 0.0:
			s.cd = maxf(0.0, float(s.cd) - share * GameData.skill_value(id, "cooldown", int(s.level)) * cd_for(id))


func agi_special() -> float:
	var start: = int((def.get("stats", {}) as Dictionary).get("agi", 0))
	var brought: = maxf(0.0, float(base_stats.get("agi", 0)) - start)
	return _capped(brought) + _capped(run_stat("agi"))




func agi_extra() -> int:
	return int(agi_special()) / GameData.AGI_CLEAVE_EVERY




func basic_bounces() -> int:
	return int(effects.get("bounce", 0.0)) + agi_bounces() + free_slot_bonus()




func agi_bounces() -> int:
	var agi: = agi_special()
	var n: = 0
	while agi >= agi_for_bounces(n + 1):
		n += 1
	return n



static func agi_for_bounces(n: int) -> float:
	var total: = 0
	for i in range(1, n + 1):
		total += ceili(float(i) / GameData.AGI_BOUNCE_STEP)
	return total



func free_slot_bonus() -> int:
	if not pacts.has("solitude"):
		return 0
	return free_attack_slots() * int(GameData.PACTS.solitude.per_free.targets)





func attack_skill_count() -> int:
	var attacks: = 0
	for id in skills:
		if counts_as_attack(id):
			attacks += 1
	return attacks





static func counts_as_attack(id: String) -> bool:
	var d: Dictionary = GameData.SKILLS[id]
	var t: = str(d.type)
	return t != "passive" and not t in GameData.SOLITUDE_FREE_TYPES and not d.get("combo_only", false)



func free_attack_slots() -> int:
	return maxi(0, max_skills() - attack_skill_count())



func devotion_slots() -> int:
	return free_attack_slots() if pacts.has("devotion") else 0



func obsession_on() -> bool:
	return pacts.has("obsession") and attack_skill_count() == 1




var vengeance: = 0
var _vengeance_until: = -9.0
func vengeance_mult() -> float:
	if vengeance <= 0 or World.game_ms() * 0.001 >= _vengeance_until:
		return 1.0
	return 1.0 + float(GameData.PACTS.vengeance.vengeance.per) * vengeance


func _vengeance_hit(world: World) -> void :
	var v: Dictionary = GameData.PACTS.vengeance.vengeance
	var now: = World.game_ms() * 0.001
	var had: = vengeance if now < _vengeance_until else 0
	if not hit_ready("vengeance"):
		return
	vengeance = mini(int(v.max), had + 1)
	_vengeance_until = now + float(v.time)

	if vengeance == int(v.max) and had < vengeance:
		world.label_over(self, tr("¡Venganza!"), Color(1.0, 0.35, 0.3))




func on_basic_hit(world: World, target: Enemy = null) -> void :
	world.damage_tag = "basic"
	world.damage_by = self

	if powers.has("martyr"):
		PALADIN.martyr_wave(world, self, target)
		world.damage_tag = "basic"
		world.damage_by = self
	if target != null and is_instance_valid(target) and not target.dead:

		var hs: = float(effects.get("hindsight", 0.0))
		if hs > 0.0 and _hindsight_cd <= 0.0 and randf() < hs * (1.0 + float(effects.get("proc_chance", 0.0))):
			_hindsight_cd = GameData.HINDSIGHT_CD
			var lv: = maxi(1, int(skills.get("hindsight", {"level": 1}).level))
			Skills.cast(world, self, str(GameData.HINDSIGHT_SKILLS.pick_random()), lv, "hindsight")

		var keep: = float(effects.get("plag_proc", 0.0))



		var now_s: = world.clock
		if keep > 0.0 and now_s >= _preserve_at and randf() < keep * (1.0 + float(effects.get("proc_chance", 0.0))):
			var copied: Array = (profile.get("plagiarism", []) as Array).filter( func(id): return GameData.SKILLS.has(id) and GameData.SKILLS[id].has("damage"))
			if not copied.is_empty():
				_preserve_at = now_s + GameData.PRESERVE_CD
				_proc_cast(world, str(copied.pick_random()), int(skills.get("preserve", {"level": 1}).level))


		var ab: = float(effects.get("auto_blitz", 0.0))



		var hunt: = 1.0




		var b_odds: = (ab + GameData.AUTO_BLITZ_LUK * eff_stat("luk")) * hunt * _hit_power if ab > 0.0 else 0.0
		var b_n: = mini(int(b_odds) + (1 if randf() < b_odds - int(b_odds) else 0), GameData.PROC_POWER_CASTS_MAX)
		if b_n > 0:







			if world.clock < _blitz_at:
				_blitz_saved = mini(_blitz_saved + b_n, GameData.BLITZ_SAVED_MAX)
			else:
				_blitz_saved = mini(_blitz_saved + b_n - 1, GameData.BLITZ_SAVED_MAX)
				_blitz_at = world.clock + GameData.BLITZ_GAP


				set_meta("blitz_mult", (1.0 + _blitz_saved) * GameData.proc_level_mult(level))
				_blitz_saved = 0


				set_meta("blitz_target", target)
				for bid in ["blitz_beat_x", "blitz_beat"]:
					if skills.has(bid):
						Skills.cast(world, self, bid, int(skills[bid].level), "blitz_beat")
						break
				remove_meta("blitz_target")


		var triple: = float(effects.get("triple", 0.0)) * (GameData.LG_FURY_START if effects.has("lg_berserk") else 1.0)

		triple *= 1.0 + GameData.COMBO_ASPD_START * maxf(0.0, aspd_bonus)
		if not _combo_busy and randf() < triple:
			world.monk_combo(self, target)


	if not _combo_busy and _stance_rest <= 0.0:
		var kick: = _roll_stance(false)
		if kick != "":
			world.taekwon_kick(self, target if target != null and is_instance_valid(target) and not target.dead else null, kick)
	world.damage_tag = "basic"
	world.damage_by = self
	var splash: = float(effects.get("splash", 0.0))

	if free_slot_bonus() > 0 and def.basic.get("ranged", false):
		splash = maxf(splash, 0.6 + float(GameData.PACTS.solitude.per_free.area) * free_slot_bonus())
	if splash > 0.0 and target != null:


		var weapon_boom: = float(effects.get("splash", 0.0))
		var now: = Time.get_ticks_msec()
		if weapon_boom > 0.0 and now - _boom_at >= int(GameData.SPLASH_FX_GAP * 1000.0):
			_boom_at = now
			world.spawn_fx("blastmine", target.position, clampf(weapon_boom * 0.45, 0.5, 1.0), 0.85)
			world.play_sound("forge_blast", GameData.SPLASH_FX_GAP, -17.0, randf_range(1.2, 1.4))
		for e in world.enemies_in_radius(target.position, splash):
			if e != target:
				world.pool_basic(e, basic_atk() * 0.6, Vector3.ZERO, basic_element(), self)
	if target != null and randf() < float(effects.get("stun_hit", 0.0)):
		world.apply_status(target, "stun", 1.5)
	var poison: = float(effects.get("poison_hit", 0.0))
	if poison > 0.0 and target != null:

		world.damage_tag = "poison"
		world.damage_by = self
		world.apply_poison(target, basic_atk() * poison, GameData.POISON_HIT_TIME)
		world.damage_tag = "basic"
		world.damage_by = self
	var proc_more: = 1.0 + float(effects.get("proc_chance", 0.0))

	if bis_t > 0.0 and effects.has("lg_lyre"):
		proc_more *= GameData.LG_LYRE_PROCS



	for pr in procs:
		var odds: = float(pr.chance) * proc_more * _hit_power
		var n: = mini(int(odds) + (1 if randf() < odds - int(odds) else 0), GameData.PROC_POWER_CASTS_MAX)


		if str(pr.skill) == "investigate" and effects.has("lg_kaiser"):
			kaiser_blast = splash
		for i in n:
			_proc_cast(world, str(pr.skill), int(pr.get("level", 1)))
		kaiser_blast = 0.0
	if has_uniq:
		Uniques.on_basic_hit(world, self, target)




func vit_shield_mult() -> float:
	return 1.0 + GameData.VIT_SHIELD * eff_stat("vit")


func shield_x() -> Dictionary:
	return GameData.SHIELD_X.get(shield_src, {}) if shield > 0.0 else {}



func _shield_broke(world: World, x: Dictionary) -> void :
	var col: Color = x.color
	var r: = GameData.SHIELD_BURST_RADIUS * sqrt(area_mult)
	var dmg: = _shield_stored * float(x.get("burst", 0.0))
	var src: = shield_src
	_shield_stored = 0.0
	Vfx.ring(world.fx_root, position, r * 1.25, col.lightened(0.3), 0.45)
	world.play_sound("guard_block", 0.1, -2.0)
	if x.has("heal"):
		heal(max_hp * float(x.heal), world)
	if dmg <= 0.0:
		return
	Vfx.burst(world.fx_root, position, r, col)
	world.shake(0.3)
	var tag: = world.damage_tag
	var by: = world.damage_by
	world.damage_tag = src
	world.damage_by = self
	for e in world.enemies_in_radius(position, r):
		world.damage_enemy(e, dmg, ((e.position - position) * Vector3(1, 0, 1)).normalized() * 5.0, "skill", "neutral", src)
	world.damage_tag = tag
	world.damage_by = by




func summon_power(extra: = 0.0) -> float:
	return 1.0 + float(effects.get("summon_dmg", 0.0)) + extra



func hunt_mult(e: Enemy) -> float:
	var id: = e.get_instance_id()
	_hunt_streak = mini(GameData.HUNT_MAX, _hunt_streak + 1) if id == _hunt_id else 1
	_hunt_id = id
	return 1.0 + GameData.HUNT_STEP * (_hunt_streak - 1)



func pick_limits() -> Dictionary:
	var all = Save.setting("pick_limits", {})
	var mine = all.get(class_id, {}) if all is Dictionary else {}
	return mine if mine is Dictionary else {}



func pick_order() -> Array:
	return (Save.setting("pick_order", {}) as Dictionary).get(class_id, [])




func pick_bans() -> Array:
	var all = Save.setting("pick_bans", {})
	var mine = all.get(class_id, []) if all is Dictionary else []
	return mine if mine is Array else []



func pick_fill() -> bool:
	return bool(Save.setting("pick_fill", true))




func raisable_skills() -> Array:
	var ids: Array = []
	for o in _choice_pool():
		var id: = base_skill(str(o.id))
		if ids.has(id) or banished.has(_choice_key(o)):
			continue
		if str(o.kind) == "stat" or (str(o.kind) in ["skill", "evolve"] and (skills.has(id) or skills.has(id + "_x"))):
			ids.append(id)
	var order: = pick_order()
	var first: = order.filter( func(id): return ids.has(id))
	return first + ids.filter( func(id): return not first.has(id))



func huuma_on() -> bool:
	return equipment != null and equipment.has_huuma()


func huuma_element() -> String:
	return Equipment.weapon_element(equipment.slots.weapon)



func kick_landed(world: World) -> void :
	if not effects.has("kick_fury"):
		return
	if world.time >= _kick_until:
		kick_streak = 0



	var cap: = GameData.KICK_FURY_MAX + int(effects.get("kick_cap", 0.0))
	if str(job2.get("id", "")) == "soul_linker":
		cap = maxi(cap, GameData.KICK_FURY_MAX + GameData.KICK_CAP_FISTS)
	kick_streak = mini(cap, kick_streak + 1)
	_kick_until = world.time + GameData.KICK_FURY_TIME
	if kick_streak % 5 == 0:
		world.label_over(self, tr("Racha x%d") % kick_streak, Color(1.0, 0.6, 0.3))



func kick_mult(now: float, boss: bool) -> float:
	if kick_streak <= 0 or now >= _kick_until:
		return 1.0
	return 1.0 + float(effects.get("kick_fury", 0.0)) * kick_streak * (GameData.KICK_FURY_BOSS if boss else 1.0)






func _proc_cast(world: World, skill: String, level: int, when_hit: = false) -> void :
	var cast: = skill
	if skills.has(skill + "_x"):
		cast = skill + "_x"
		level = int(skills[cast].level)
	elif skills.has(skill):
		level = maxi(level, int(skills[skill].level))





	var sk: Dictionary = GameData.SKILLS.get(cast, {})



	if not when_hit and (sk.has("damage") or str(sk.get("type", "")) == "heal"):

		var now: = World.game_ms()
		if now < int(_proc_next.get(cast, 0)):
			_proc_saved[cast] = int(_proc_saved.get(cast, 0)) + 1
			return


		var ground: = str(sk.get("type", "")) == "ground" and not sk.has("heal_amount")
		_proc_next[cast] = now + (GameData.PROC_GROUND_GAP_MS if ground else GameData.PROC_GAP_MS)
		var held: = 1.0 + int(_proc_saved.get(cast, 0))
		_proc_saved[cast] = 0


		if str(sk.get("type", "")) == "melee_arc":
			proc_stack = held
		else:
			proc_bake = held


	var tag: = world.damage_tag
	var by: = world.damage_by
	Skills.cast(world, self, cast, level, "proc:" + skill + ("@hit" if when_hit else ""))
	world.damage_tag = tag
	world.damage_by = by
	proc_stack = 1.0
	proc_bake = 1.0






func own_proc_mult(when_hit: bool, skill: String) -> float:
	var k: = proc_kind_mult(when_hit, skill)
	for id in [skill + "_x", skill]:
		if skills.has(id):



			var own: = skill_mult_for(id) * proc_stack * (1.0 + float(effects.get("proc_power", 0.0)))
			if powers.has("steel_body"):
				own *= 1.0 + steel_proc
			return maxf(k, own)
	return k







func proc_breakdown(when_hit: bool, skill: String) -> Dictionary:
	var parts: Array = []
	var magic: = skill != "" and GameData.proc_by_int(skill)
	if when_hit:
		parts.append(["hit", hit_proc_mult + (proc_int_hit if magic else 0.0)])
		var root: = GameData.PROC_HIT_HP_ROOT
		if pacts.has("retaliation"):
			root = float(GameData.PACTS.retaliation.retaliate.hp_root)
		parts.append(["hp", 1.0 + sqrt(maxf(0.0, scaling_hp())) * root])
	else:
		parts.append(["basic", basic_mult + proc_dmg_bonus + (proc_int_basic if magic else 0.0)])
	parts.append(["level", GameData.proc_level_mult(level)])
	parts.append(["proc", GameData.PROC_DMG * float(GameData.PROC_SKILL_DMG.get(skill, 1.0)) * (1.0 + float(effects.get("proc_power", 0.0)))])
	if powers.has("steel_body"):
		parts.append(["steel", 1.0 + steel_proc])
	parts.append(["dmg", dmg_mult])
	var k: = proc_kind_mult(when_hit, skill)
	var own: = own_proc_mult(when_hit, skill)
	return {"total": own * dmg_mult, "parts": parts, "own": own > k + 0.0001}




func own_auto_mult(tag: String) -> float:
	return maxf(skill_mult_for(tag), basic_mult * GameData.PROC_DMG * (1.0 + float(effects.get("proc_power", 0.0))))





func proc_kind_mult(when_hit: bool, skill: = "") -> float:
	var k: = GameData.proc_level_mult(level) * GameData.PROC_DMG * float(GameData.PROC_SKILL_DMG.get(skill, 1.0))
	k *= (1.0 + float(effects.get("proc_power", 0.0))) * proc_stack

	if powers.has("steel_body"):
		k *= 1.0 + steel_proc

	var magic: = skill != "" and GameData.proc_by_int(skill)
	if not when_hit:


		return (basic_mult + proc_dmg_bonus + (proc_int_basic if magic else 0.0)) * k
	var root: = GameData.PROC_HIT_HP_ROOT
	if pacts.has("retaliation"):
		root = float(GameData.PACTS.retaliation.retaliate.hp_root)
	return (hit_proc_mult + (proc_int_hit if magic else 0.0)) * k * (1.0 + sqrt(maxf(0.0, scaling_hp())) * root)






func proc_summary() -> Array:
	var out: Array = []
	var from: Array = []
	var sockets: Array = equipment.socketed_cards() if equipment != null else []
	for c in album_cards + sockets:
		from.append([GameData.CARDS[c].name, GameData.CARDS[c]])
	if equipment != null:
		for k in equipment.slots:
			var it = equipment.slots[k]
			if it != null:
				from.append([Equipment.item_name(it), Equipment.item_def(it)])
	for f in from:
		out.append_array(proc_entries(str(f[0]), f[1]))
	return out







func proc_entries(source: String, d: Dictionary) -> Array:
	var out: Array = []
	var on_basic: = 1.0 + float(effects.get("proc_chance", 0.0))
	if bis_t > 0.0 and effects.has("lg_lyre"):
		on_basic *= GameData.LG_LYRE_PROCS
	var on_hit: = 1.0 + float(effects.get("hit_proc", 0.0)) + float(shield_x().get("hit_proc", 0.0))
	if powers.has("gospel"):
		on_hit += GameData.GOSPEL_HIT_PROC
	if powers.has("steel_body"):
		on_hit += GameData.STEEL_HIT_PROC
	if pacts.has("retaliation"):
		on_hit += float(GameData.PACTS.retaliation.retaliate.chance)
	for key in ["proc", "proc_hit"]:
		if not d.has(key):
			continue
		var pr: Dictionary = d[key]
		var skill: = str(pr.skill)
		var base_skill: = skill
		var lv: = int(pr.get("level", 1))

		if skills.has(skill + "_x"):
			skill += "_x"
			lv = int(skills[skill].level)
		elif skills.has(skill):
			lv = maxi(lv, int(skills[skill].level))
		var odds: = float(pr.chance) * (on_basic if key == "proc" else on_hit)
		out.append({"source": source, "skill": skill, "level": lv, "when": "basic" if key == "proc" else "hit", 
			"base": float(pr.chance), "odds": odds, "chance": minf(1.0, odds), 
			"mult": dmg_mult * own_proc_mult(key == "proc_hit", base_skill)})
	return out





const PROC_HIT_CD: = GameData.HIT_ICD






var _hit_icd: = {}
func hit_ready(key: String) -> bool:
	var now: = World.game_ms()
	if now < int(_hit_icd.get(key, 0)):
		return false
	_hit_icd[key] = now + int(GameData.HIT_ICD * 1000.0)
	return true




var _hit_bank: = {}
func hit_bank(key: String, amount: float) -> float:
	var total: = float(_hit_bank.get(key, 0.0)) + amount
	if not hit_ready(key):
		_hit_bank[key] = total
		return 0.0
	_hit_bank.erase(key)
	return total


func _autocast_when_hit(world: World) -> void :
	var now: = World.game_ms() * 0.001

	var mult: = 1.0 + float(effects.get("hit_proc", 0.0))
	if powers.has("gospel"):
		mult += GameData.GOSPEL_HIT_PROC
	if powers.has("steel_body"):
		mult += GameData.STEEL_HIT_PROC
	if pacts.has("retaliation"):
		mult += float(GameData.PACTS.retaliation.retaliate.chance)
	mult += float(shield_x().get("hit_proc", 0.0))
	for pr in procs_hit:
		var key: = str(pr.skill)
		if now < float(_proc_hit_cd.get(key, 0.0)):
			continue
		if randf() < float(pr.chance) * mult:
			_proc_hit_cd[key] = now + PROC_HIT_CD
			_proc_cast(world, key, int(pr.get("level", 1)), true)
			if effects.has("hit_heal") and hp > 0.0:
				heal(max_hp * float(effects.hit_heal), world)





const ATTACK_ANIM_MIN: = 0.25
func play_attack(toward: Vector3, magic: = false) -> void :

	if _moving and _since_attack < (0.4 if class_id in ["acolyte", "taekwon"] and not magic else 0.9):
		return
	if toward.length_squared() > 0.0001 and (_moving or _attack_turn_lock <= 0.0):
		visual.face(Vector3(toward.x, 0.0, toward.z))
		_attack_turn_lock = 0.35




	if _attack_anim > 0.03:
		return

	var swing: int = int(_weapon_view[2]) if _weapon_view.size() > 2 else int(look.get("attack", RoVisual.PC_ATTACK))

	if not mount().is_empty():
		swing = int(mount().get("attack", look.get("attack", RoVisual.PC_ATTACK)))

	var poses: Array = look.get("attack_poses", [])
	if not poses.is_empty():
		swing = int(poses.pick_random())

	if magic and visual.skin_fx != null:
		visual.skin_fx.call("cast")
	var base: int = look.get("cast", swing) if magic else swing
	var length: = visual.action_length(base)


	var shown: = clampf(minf(length, attack_delay()), ATTACK_ANIM_MIN, 0.45)
	visual.play(base, false, true)
	visual.speed_scale = length / shown
	_attack_anim = shown
	_since_attack = 0.0




func _defense_pop(world: World, text: String, color: Color, sound: = "", volume: = -10.0, up: = 0.0) -> void :
	var head: = visual.height() if visual != null else 1.8
	world.number(position + Vector3(0, head + 0.9 + up, 0), text, color, true)
	if sound != "":
		world.play_sound(sound, 0.12, volume)



func _barrier_pop(world: World, text: String, volume: float, up: float) -> void :
	var now: = Time.get_ticks_msec()
	if now - _barrier_shown_at < int(GameData.BARRIER_NUMBER_GAP * 1000.0):
		world.play_sound("kyrie", 0.12, volume)
		return
	_barrier_shown_at = now
	_defense_pop(world, text, Color(0.55, 0.85, 1.0), "kyrie", volume, up)








var _hazard_at: = -99.0
var _hazard_pos: = Vector3.ZERO
var _hazard_stack: = 0
func hell_hazard(world: World, pct: float) -> void :
	var now: = World.game_ms() * 0.001
	var still: = now - _hazard_at < GameData.HELL_STILL_TIME\
	and (position - _hazard_pos).length() < GameData.HELL_STILL_DIST
	_hazard_stack = mini(_hazard_stack + 1, GameData.HELL_STILL_MAX) if still else 0
	_hazard_at = now
	_hazard_pos = position
	if _hazard_stack > 0:
		world.label_over(self, tr("¡Muévete!  x%s") % str(snappedf(1.0 + GameData.HELL_STILL_STEP * _hazard_stack, 0.1)), Color(1.0, 0.4, 0.3))
	take_damage(max_hp * pct * (1.0 + GameData.HELL_STILL_STEP * _hazard_stack), world, null, true, true)


func take_damage(amount: float, world: World, from: Enemy = null, pierce: = false, hazard: = false) -> void :
	var what: = world.hurt_what
	world.hurt_what = ""
	var sent_by: = world.hurt_mob
	world.hurt_mob = 0
	if hp <= 0.0 or choosing or GameData.has_meta("tour_god"):
		return



	var touch: = from != null and is_instance_valid(from) and from.touch_dmg > 0.0
	if _invuln > 0.0:


		if pierce:
			_defense_pop(world, tr("Inmune"), Color(0.9, 0.9, 0.95), "pressure", -12.0)
		return




	if (_skill_safe > 0.0 or blinking > 0.0) and not pierce and not hazard and not touch\
	and (from == null or not is_instance_valid(from) or not from.is_boss):
		return





	if doom and world.has_meta("doom_tick") and from != null and is_instance_valid(from) and bool(from.def.get("mvp", false)):
		amount *= DOOM_TICK_MULT
	if doom and pierce and not hazard and not touch and not world.has_meta("doom_tick")\
	and from != null and is_instance_valid(from) and bool(from.def.get("mvp", false))\
	and not has_meta("only_skill"):
		_doom_fall(world, from, what)
		return
	if is_immortal():
		_defense_pop(world, tr("Inmortal"), Color(1.0, 0.85, 0.35), "angelus", -10.0)
		return

	if shield > 0.0 and not touch and World.SoulLinker.kaite_absorb(world, self, from, what, pierce, hazard):
		_parry_credit(world, from, pierce)
		return





	var over: = 1.0
	if not pierce and not hazard and not touch:
		var kind: = World.mob_hit_kind(from) if from != null and is_instance_valid(from) else sent_by
		if kind == 3 and what != "" and what != "Disparo":
			kind = 0
		var top: = world.mob_hit_cap(kind) * (1.0 - hit_resist()) * max_hp
		if amount > top and top > 0.0:
			over = amount / top
			amount = top
	if from != null and is_instance_valid(from) and from.element() in ["undead", "shadow"]:
		amount *= 1.0 - minf(0.6, float(effects.get("undead_guard", 0.0)))


	if not hazard:
		amount *= 1.0 - (grade_mech_cut if pierce else grade_hit_cut)


	if pierce and not hazard and party_buffs.has("ens_siegfried"):
		amount *= GameData.ENS_SIEG_MECH

	if world.karma != null and world.karma.boon == "hel_pact":
		amount *= 1.0 + GameData.HEL_PACT_TAKEN * world.karma.boons


	if not touch and not hazard and effects.has("parry") and LORD_KNIGHT.parry(world, self, from, pierce):
		_invuln = 0.12
		_autocast_when_hit(world)
		return
	if not touch and randf() < perfect_dodge:
		_defense_pop(world, "Lucky", Color(1.0, 0.9, 0.45), "drop_yellow", -8.0)
		_on_dodge(world, from)

		Uniques.bulwark_gain(world, self, "lucky")
		_parry_credit(world, from, pierce)
		return
	var flee: = dodge
	var mvp: = from != null and is_instance_valid(from) and bool(from.def.get("mvp", false))
	if mvp:
		flee *= 1.0 - GameData.MVP_FLEE_IGNORE
	elif from != null and is_instance_valid(from) and from.is_boss:
		flee *= 1.0 - GameData.BOSS_FLEE_IGNORE

	if from != null and is_instance_valid(from) and from.blind_time > 0.0:
		flee = 1.0 - (1.0 - flee) * (1.0 - (GameData.BLIND_MISS_BOSS if from.is_boss else GameData.BLIND_MISS))
	if not pierce and not touch and randf() < flee:
		_defense_pop(world, "Miss", Color(0.7, 0.9, 1.0), "wind_blade", -12.0)
		_on_dodge(world, from)
		Uniques.bulwark_gain(world, self, "miss")
		_parry_credit(world, from, pierce)
		return

	if not touch and randf() < block_chance() * (GameData.HELL_BLOCK_MULT if hazard else (GameData.MECH_BLOCK_MULT if pierce else (GameData.MVP_BLOCK_MULT if mvp else 1.0))):
		_defense_pop(world, "Guard", Color(0.75, 0.85, 1.0))
		world.sprite_fx("fx_shield", position + Vector3(0, 1.1, 0), 0, 0.8)
		world.play_sound("guard_block", 0.15, -6.0)
		_invuln = 0.12

		if effects.has("block_heal") and world.time >= _block_heal_at:
			_block_heal_at = world.time + 0.5
			heal(max_hp * float(effects.block_heal), world)

		PALADIN.charge(world, self)
		Uniques.bulwark_gain(world, self, "guard")
		_parry_credit(world, from, pierce)
		_grasshopper_counter(world, from)
		_autocast_when_hit(world)
		return

	if not touch and effects.has("aegis") and float(_legend_cd.get("aegis", 0.0)) <= 0.0:
		_legend_cd["aegis"] = float(effects.aegis)
		_defense_pop(world, tr("Égida"), Color(1.0, 0.95, 0.7))
		world.aegis_burst(self)
		Uniques.bulwark_gain(world, self, "aegis")
		_parry_credit(world, from, pierce)
		_invuln = 0.12
		_autocast_when_hit(world)
		return
	if not pierce and not touch:
		amount = _ninja_evade(world, from, amount)
		if amount <= 0.0:
			Uniques.bulwark_gain(world, self, "evade")
			_parry_credit(world, from, pierce)
			return





	if from != null and is_instance_valid(from) and not from.dead and not hazard and ( not pierce or from.is_boss):
		var refl: = float(effects.get("reflect", 0.0)) + float(shield_x().get("reflect", 0.0))
		var back: = hit_bank("reflect", amount * GameData.reflect_over(over) * refl) if refl > 0.0 else 0.0

		if back > 0.0 and PALADIN.on(self) and PALADIN.provoked_by(world, from, self):
			back *= 2.0
		if back > 0.0:
			world.damage_tag = "reflect_shield"
			world.damage_by = self
			world.damage_enemy(from, back, Vector3.ZERO, "skill", "neutral", "reflect_shield")
			world.play_sound("reflect_shield", 0.2, -8.0)
			PALADIN.charge(world, self)
	if from != null and is_instance_valid(from) and not from.dead and not pierce:



		if randf() < float(effects.get("auto_counter", 0.0)) * (GameData.MVP_BLOCK_MULT if mvp else 1.0) and not from.dead and hit_ready("auto_counter"):
			world.auto_counter(self, from)
			_invuln = 0.15
			_autocast_when_hit(world)
			return
	if has_uniq and not touch:
		amount = Uniques.hurt(world, self, amount, from, pierce)

		if amount <= 0.0:
			Uniques.bulwark_gain(world, self, "aegis")
			_parry_credit(world, from, pierce)
			_invuln = 0.12
			_autocast_when_hit(world)
			return
	if not touch:
		lose_coin()
	if powers.has("steel_body"):
		amount *= 1.0 - minf(GameData.STEEL_GUARD_MAX, steel_guard)

	if has_meta("lk_edge"):
		amount *= LORD_KNIGHT.edge_taken(self)


	if not hazard and from != null and is_instance_valid(from) and from.weak_mult > 0.0 and world.clock < from.weak_until:
		amount *= 1.0 - from.weak_mult



	if _moving and not pierce and effects.has("adjust"):
		amount *= 1.0 - minf(GameData.ADJUST_MAX, float(effects.adjust))
	if not pierce:
		amount = maxf(1.0, amount * (1.0 - damage_reduction()) * (1.0 - vit_cut))


	# [MOD] apply the ceiling after all mitigation, before shields absorb, so the number the meter and
	# the run log show is the one that can actually kill. The probe reports every mechanics hit at first
	# and then every 8th, with running totals, so the file also proves the cap is engaging (or that the
	# hits were already below it).
	if pierce and from == null and amount < max_hp * MOD_MECH_EXECUTE_OVER:
		var raw: = amount
		var ceiling: = max_hp * MOD_MECH_PCT_CAP
		if raw > ceiling:
			mod_mech_capped += 1
			mod_mech_saved += raw - ceiling
			mod_mech_worst = maxf(mod_mech_worst, raw)
			amount = ceiling
		mod_mech_hits += 1
		if mod_mech_hits == 1 or mod_mech_hits % 8 == 0:
			print("MODPROBE %s mechanics hit #%d '%s': %.0f -> %.0f of max_hp %.0f (was %.2f, cap %.2f) | capped %d, avoided %.0f" % [
				MOD_TAG, mod_mech_hits, what, raw, amount, max_hp, raw / max_hp, MOD_MECH_PCT_CAP, mod_mech_capped, 
				mod_mech_saved])
			var mf: = FileAccess.open("user://mod_probe_player.txt", FileAccess.WRITE)
			if mf != null:
				mf.store_string("%s\nhits=%d\ncapped=%d\navoided_total=%.0f\nworst_hit=%.0f (%.2f of max_hp)\nlast_label=%s\nlast_hit=%.0f -> %.0f\nmax_hp=%.0f\npid=%d\nat=%s\n" % [
					MOD_TAG, mod_mech_hits, mod_mech_capped, mod_mech_saved, mod_mech_worst, mod_mech_worst / max_hp,
					what, raw, amount, max_hp, OS.get_process_id(), Time.get_datetime_string_from_system()])
				mf.close()
	if not touch and not hazard and effects.has("hit_shield") and world.clock >= _gryphon_at:

		_gryphon_at = world.clock + GameData.GRYPHON_GUARD_CD
		var top: = max_hp * GameData.GRYPHON_GUARD_MAX
		if shield < top:
			shield = minf(top, shield + max_hp * float(effects.hit_shield))
			shield_peak = maxf(shield_peak, shield)
	if touch:
		amount = minf(amount, maxf(0.0, hp - 1.0))
	elif shield > 0.0:

		var absorbed: = minf(shield, amount * (1.0 - (GameData.MVP_SHIELD_PIERCE if mvp else (GameData.HELL_SHIELD_PIERCE if hazard else 0.0))))
		var evolved: = shield_x()
		shield -= absorbed
		amount -= absorbed
		if not evolved.is_empty():
			_shield_stored += absorbed
			if shield <= 0.0:
				_shield_broke(world, evolved)
		if amount <= 0.0:
			_barrier_pop(world, tr("Absorbido"), -8.0, 0.0)
			Uniques.bulwark_gain(world, self, "absorb")
			_parry_credit(world, from, pierce)
			_autocast_when_hit(world)
			return
		_barrier_pop(world, tr("−%d escudo") % roundi(absorbed), -14.0, 0.35)
	_invuln = 0.12

	if not touch and not hazard:
		Uniques.bulwark_gain(world, self, "hit")
	if pacts.has("vengeance"):
		_vengeance_hit(world)
	run_taken += minf(amount, hp)
	if world.meter_stats.has("taken"):
		if self == world.player:
			world.meter_stats.taken += minf(amount, hp)
		world.meter_take(from, minf(amount, hp), pierce, self, amount)





	var boss_hit: = from != null and is_instance_valid(from) and from.is_boss
	var plain: = not pierce and not hazard and ( not boss_hit or what == "" or what == "Disparo")
	if plain and amount >= hp and hp >= max_hp * GameData.SURVIVE_FROM and world.clock >= _survive_at:

		_survive_at = world.clock + GameData.SURVIVE_CD
		amount = hp - max_hp * GameData.SURVIVE_HP
		_invuln = GameData.SURVIVE_GRACE
		_defense_pop(world, tr("¡Aguanta!"), Color(1.0, 0.6, 0.3), "guard_block", -6.0)
		if has_dish("rice_cake"):
			world._rice_cake_burst.call_deferred(self)
	hp -= amount
	hurt_at = world.clock
	if hp <= 0.0:
		var who: = from != null and is_instance_valid(from)
		death_by = {"by": str(from.def.name) if who else "", "what": what if what != "" else ("Golpe cuerpo a cuerpo" if who else ""), 
			"sprite": from.id if who else ""}
	visual.flash()

	if not _moving and _attack_anim <= 0.0:
		visual.play(RoVisual.PC_HURT, false, true)
		_attack_anim = 0.2
	_hurt_sum += amount
	var now: = Time.get_ticks_msec()
	if now - _hurt_shown_at >= int(GameData.HURT_NUMBER_GAP * 1000.0):
		world.number(position, str(roundi(_hurt_sum)), Color(1.0, 0.35, 0.35))
		_hurt_sum = 0.0
		_hurt_shown_at = now
	if self == world.player:
		world.hud.danger.hurt(amount / maxf(1.0, max_hp))

	if not world.oaths.is_empty() and not touch:
		world.oath_run.on_hurt(world, self, from, pierce, hazard)
	if hp > 0.0:
		_autocast_when_hit(world)
		_taekwon_hit(world, from, false)
		if has_uniq:
			Uniques.after_hurt(world, self)
	if has_dish("nine_tail_dish"):
		world.nine_tail_reflect(self, hit_bank("nine_tail", amount * float(GameData.RECIPES.nine_tail_dish.reflect)))
	_sweat_cd -= 1.0
	if hp < max_hp * 0.25 and _sweat_cd <= 0.0 and hp > 0.0:
		_sweat_cd = 30.0
		world.emote(self, "sweat")


	if effects.has("last_stand") and hp < max_hp * GameData.LAST_STAND_HP\
	and float(_legend_cd.get("last_stand", 0.0)) <= 0.0:
		_legend_cd["last_stand"] = float(effects.last_stand)
		hp = maxf(hp, 1.0) + max_hp * GameData.LAST_STAND_HP
		add_power("siegfried_token", GameData.LAST_STAND_TIME)
		world.legend_proc(self, tr("¡Einherjar!"), Color(1.0, 0.9, 0.5), "asum")
	if hp <= 0.0:

		if world.encore.siegfried_save(world, self):
			return
		if effects.has("kaizel") and float(_legend_cd.get("kaizel", 0.0)) <= 0.0:
			_kaizel(world)
			return

		if has_uniq and Uniques.try_ankh(world, self):
			return
		if revives > 0:
			_revive(world)
			return


		if world.training and not world.festival_mode:
			hp = max_hp
			world.number(position + Vector3(0, 2.4, 0), tr("¡Caíste! (entrenamiento)"), Color(1.0, 0.45, 0.4), true)
			return
		hp = 0.0
		fell = true
		visual.play(RoVisual.PC_DEAD, false, true)
		died.emit()







func _ninja_evade(world: World, from: Enemy, amount: float) -> float:
	if not _mirrors.is_empty():
		var m: Sprite3D = _mirrors.pop_back()
		world.sprite_fx("fx_kasumikiri", m.global_position + Vector3(0, 0.6, 0), 0, 0.7)
		m.queue_free()
		world.play_sound("mist_slash", 0.1, -10.0)
		if amount > max_hp * GameData.SHADOW_ABSORB_MAX:
			world.number(position + Vector3(0, 2.2, 0), tr("Sombra rota"), Color(0.65, 0.6, 1.0))
			return amount * GameData.SHADOW_ABSORB_CUT
		_invuln = 0.15
		return 0.0

	var per_min: = float(effects.get("cicada", 0.0))
	if per_min <= 0.0 or _cicada_t < maxf(2.0, 60.0 / per_min):
		return amount
	_cicada_t = 0.0
	world._shadow_clone(self, position)
	var away: = facing * -1.0
	if from != null and is_instance_valid(from):
		away = ((position - from.position) * Vector3(1, 0, 1)).normalized()

	if _last_stick.length() > 0.3:
		away = Vector3(_last_stick.x, 0.0, _last_stick.y).normalized()
	var to: = world.map.slide(position, away * 2.5)
	position = Vector3(to.x, world.map.height_at(to), to.z)
	world.number(position, tr("Utsusemi"), Color(0.75, 0.95, 0.7))
	world.play_sound("mist_slash", 0.1, -6.0)
	_invuln = 0.3
	return 0.0




func mirror_count() -> int:
	return _mirrors.size()



func mirror_nodes() -> Array:
	return _mirrors.filter( func(m): return is_instance_valid(m))


func make_mirrors(world: World, n: int) -> void :
	while _mirrors.size() < n and visual != null:
		var m: = Sprite3D.new()
		m.pixel_size = visual.sprite.pixel_size
		m.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		m.centered = false
		m.offset = visual.sprite.offset
		m.shaded = false
		m.transparent = true
		m.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		m.modulate = Color(0.6, 0.55, 1.0, 0.42)
		m.render_priority = -1
		add_child(m)
		_mirrors.append(m)
		world.sprite_fx("fx_kasumikiri", position + Vector3(0, 0.6, 0), 0, 0.6)
	_tick_mirrors(0.0)


func _tick_mirrors(delta: float) -> void :
	if _mirrors.is_empty() or visual == null:
		return
	_mirror_spin += delta * 0.9
	var n: = _mirrors.size()
	for i in n:
		var m: = _mirrors[i]
		m.texture = visual.sprite.texture
		m.offset = visual.sprite.offset
		var a: = _mirror_spin + TAU * i / n
		m.position = visual.sprite.position + Vector3(cos(a), 0, sin(a)) * 1.0






func _doom_fall(world: World, from: Enemy, what: String) -> void :
	run_taken += hp
	if world.meter_stats.has("taken"):
		if self == world.player:
			world.meter_stats.taken += hp
		world.meter_take(from, hp, true, self)
	hp = 0.0
	hurt_at = world.clock
	_invuln = 0.12
	death_by = {"by": str(from.def.name), "what": what if what != "" else GameData.DOOM_CAUSE, "sprite": from.id}
	visual.flash()
	_defense_pop(world, tr("¡Sentencia!"), Color(0.95, 0.25, 0.3), "curse", -6.0)
	if self == world.player:
		world.hud.danger.hurt(1.0)
	if effects.has("kaizel") and float(_legend_cd.get("kaizel", 0.0)) <= 0.0:
		_kaizel(world)
		return

	if has_uniq and Uniques.try_ankh(world, self):
		return
	if revives > 0:
		_revive(world)
		return
	fell = true
	visual.play(RoVisual.PC_DEAD, false, true)
	died.emit()


func _revive(world: World) -> void :
	revives -= 1
	falls += 1
	hp = max_hp * 0.5
	_invuln = 2.5
	visual.play(RoVisual.PC_IDLE, true, true)
	if self == world.player:
		world.hud.announce(tr("Yggdrasil Leaf"), Color(0.5, 1.0, 0.5), tr("¡Has resucitado!"))
	else:
		world.label_over(self, tr("Yggdrasil Leaf"), Color(0.5, 1.0, 0.5))


	world.spawn_fx("resurrection", position, 1.3, 1.0, self)
	world.spawn_fx("h_levelup", position, 1.0, 0.8, self)
	Vfx.column(world.fx_root, position, Color(0.55, 1.0, 0.6))
	world.play_sound("resurrection", 0.0, -2.0)
	world.play_sound("heal", 0.0, -6.0)
	world.shake(0.3)
	Vfx.burst(world.fx_root, position, 6.0, Color(0.6, 1.0, 0.6))
	for e in world.enemies_in_radius(position, 6.0):
		var push: = ((e.position - position) * Vector3(1, 0, 1)).normalized() * 12.0
		world.damage_enemy(e, 60.0, push, "skill", "neutral", "yggdrasil")




func _roll_stance(on_hit: bool) -> String:
	var kicks: Array = []
	for id in skills:
		var sd: Dictionary = GameData.SKILLS[id]
		if sd.get("stance", false) and bool(sd.get("on_hit", false)) == on_hit:
			kicks.append(id)
	if kicks.is_empty():
		return ""
	kicks.shuffle()
	for id in kicks:
		var chance: = GameData.skill_value(id, "stance_chance", int(skills[id].level)) + float(effects.get("stance", 0.0))
		if (powers.has("union") and not on_hit) or randf() < chance:
			return id
	return ""



func _taekwon_hit(world: World, from: Enemy, dodged: bool) -> void :
	if not dodged and effects.has("kaahi") and _kaahi_cd <= 0.0 and hp > 0.0:
		_kaahi_cd = GameData.KAAHI_CD
		heal(max_hp * float(effects.kaahi), world)
		world.sprite_fx("fx_sl_3", position, 0, 0.5, self)

		for h in world.heroes:
			if h != self and not h.downed and h.hp > 0.0 and h.position.distance_to(position) <= GameData.SOUL_LINK_RANGE:
				h.heal(h.max_hp * float(effects.kaahi) * GameData.KAAHI_PARTY, world)
	if _combo_busy or _stance_rest > 0.0 or hp <= 0.0:
		return
	var kick: = _roll_stance(true)
	if kick == "" or not hit_ready("counter_kick"):
		return
	var target: Enemy = from if from != null and is_instance_valid(from) and not from.dead else world.nearest_enemy(position, 3.0)
	if target != null:
		world.taekwon_kick(self, target, kick)




func skill_guard(t: float) -> void :
	_skill_safe = maxf(_skill_safe, t)
	if _skill_guard_t > 0.0:
		return
	_skill_guard_t = SKILL_GUARD_EVERY
	_invuln = maxf(_invuln, t)





func start_dash(world: World, to: Vector3, time: float, opts: Dictionary) -> void :

	if world.tower != null and is_instance_valid(world.tower):
		to = world.tower.inside(to)
	dash = opts.duplicate()
	dash["from"] = position
	dash["to"] = to
	dash["time"] = maxf(0.05, time)
	dash["t"] = 0.0
	dash["hit"] = {}
	dash["ghost"] = 0.0
	skill_guard(time + 0.15)
	var dir: = (to - position) * Vector3(1, 0, 1)
	if dir.length_squared() > 0.001:
		facing = dir.normalized()
		visual.face(facing)
	visual.play(int(opts.get("pose", RoVisual.PC_ATTACK)), false, true)
	visual.speed_scale = visual.action_length(int(opts.get("pose", RoVisual.PC_ATTACK))) / maxf(0.1, time)
	_attack_anim = time + 0.1


func _tick_dash(world: World, delta: float) -> void :
	dash.t = float(dash.t) + delta
	var f: = clampf(float(dash.t) / float(dash.time), 0.0, 1.0)
	var from: Vector3 = dash.from
	var to: Vector3 = dash.to
	var at: = from.lerp(to, f)
	var step: = world.map.slide(position, (at - position) * Vector3(1, 0, 1))
	position = Vector3(step.x, world.map.height_at(step), step.z)

	visual.position.y = sin(f * PI) * float(dash.get("height", 0.0))
	dash.ghost = float(dash.ghost) - delta
	if float(dash.ghost) <= 0.0:
		dash.ghost = 0.035
		world.afterimage(self, Color(dash.get("color", Color(1, 0.9, 0.7)), 0.5))
	if float(dash.get("dmg", 0.0)) > 0.0:
		world.damage_tag = str(dash.get("tag", ""))
		world.damage_by = self
		for e in world.enemies_in_radius(position, float(dash.width)):
			if dash.hit.has(e) or e.dead:
				continue
			dash.hit[e] = true
			var away: = ((e.position - position) * Vector3(1, 0, 1)).normalized()
			world.damage_enemy(e, float(dash.dmg), away * float(dash.get("knock", 3.0)), "skill", basic_element())
			world.spawn_fx("hit", e.position + Vector3(0, 0.6, 0), 0.8, 0.9)
			if dash.hit.size() <= 3:
				world.play_sound("hit_fist", 0.04, -6.0)
	if f >= 1.0:
		visual.position.y = 0.0
		var done: = dash
		dash = {}
		world.dash_landed(self, done)





func _tick_aura(world: World, delta: float) -> void :
	for kind in aura.keys():
		_tick_one_aura(world, delta, str(kind))


func _tick_one_aura(world: World, delta: float, kind: String) -> void :
	var a: Dictionary = aura[kind]
	var glow = a.get("glow")
	if not powers.has("warmth_" + kind):
		if glow != null and is_instance_valid(glow):
			glow.queue_free()
		aura.erase(kind)
		return
	if glow == null or not is_instance_valid(glow):
		var col: Color = a.color
		glow = Node3D.new()
		world.fx_root.add_child(glow)

		var was: = Vfx.dim
		Vfx.dim = 1.0


		if str(a.kind) == "sun":

			Vfx.magic_circle(glow, Vector3.ZERO, float(a.range), Color(1.0, 0.85, 0.55, 0.5), 0.0, "sun_constellation", 0.25, GameData.HERO_FX_PRIORITY - 1, true)
			Vfx.magic_circle(glow, Vector3.ZERO, float(a.range) * 0.72, Color(1.0, 0.6, 0.2, 0.36), 0.0, "sun_rays", -0.45, GameData.HERO_FX_PRIORITY - 1, true)
		else:
			Vfx.magic_circle(glow, Vector3.ZERO, float(a.range), Color(col, 0.34), 0.0, "mvp_rune", 0.6, GameData.HERO_FX_PRIORITY - 1, true)
			Vfx.magic_circle(glow, Vector3.ZERO, float(a.range) * 0.6, Color(col.lightened(0.3), 0.3), 0.0, "mvp_hexa", -1.2, GameData.HERO_FX_PRIORITY - 1, true)
		Vfx.dim = was
		a["glow"] = glow
	Vfx.hold_dim(glow, Vfx.dim)
	glow.global_position = Vector3(position.x, position.y + 0.02, position.z)
	a.t = float(a.t) - delta
	if float(a.t) > 0.0:
		return
	a.t = float(a.every)
	world.damage_tag = str(a.tag)
	world.damage_by = self
	var r: = float(a.range)
	if str(a.kind) == "sun":
		var near: = world.enemies_in_radius(position, r)
		for e in near:
			var away: = ((e.position - position) * Vector3(1, 0, 1)).normalized()
			world.damage_enemy(e, float(a.dmg), away * float(a.knock), "skill", str(a.element))
		if not near.is_empty():
			Vfx.ring(world.fx_root, position, r, Color(1.0, 0.6, 0.25, 0.7), 0.3)
			world.play_sound("fire_hit1", 0.25, -14.0)
	else:

		var near: = world.enemies_in_radius(position, r)
		if near.is_empty():
			return
		var e: Enemy = near.pick_random()
		world.star_fall(self, e.position, float(a.area), float(a.dmg), str(a.element))
	world.damage_by = null




func _kaizel(world: World) -> void :
	_legend_cd["kaizel"] = float(effects.kaizel)
	hp = max_hp * GameData.KAIZEL_HP
	_invuln = 2.0
	visual.play(RoVisual.PC_IDLE, true, true)
	world.legend_proc(self, tr("¡Kaizel!"), Color(1.0, 0.95, 0.8))
	world.play_sound("sl_soul", 0.0, -2.0)
	world.sprite_fx("fx_sl_3", position, 0, 1.0, self)
	Vfx.burst(world.fx_root, position, 5.0, Color(0.85, 0.8, 1.0))
	for e in world.enemies_in_radius(position, 5.0):
		var push: = ((e.position - position) * Vector3(1, 0, 1)).normalized() * 10.0
		world.damage_enemy(e, 40.0, push, "skill", "neutral", "kaizel")




func _update_falcon() -> void :
	if not job2.get("falcon", false):
		if falcon != null:
			falcon.queue_free()
			falcon = null
		return
	if falcon == null or not is_instance_valid(falcon):

		var spr: = RoAssets.sprite(["falcon_pet_sniper", "falcon_pet"] if reborn else ["falcon_pet"])
		if spr == null:
			return
		falcon = RoVisual.new()
		add_child(falcon)
		falcon.setup(spr, Color.WHITE, 20, 0.0)


		falcon.play(0, true)

	falcon.position = FALCON_SPOT
	falcon.scale = Vector3.ONE * 0.8




func _tick_legend(delta: float, world: World) -> void :
	for k in _legend_cd:
		_legend_cd[k] -= delta
	if thor_stacks > 0:
		_thor_t -= delta
		if _thor_t <= 0.0:
			thor_stacks = 0
	if effects.is_empty() or not world.running:
		return
	if effects.has("valhalla") and float(_legend_cd.get("valhalla", effects.valhalla)) <= 0.0:
		_legend_cd["valhalla"] = float(effects.valhalla)
		add_power("berserk_potion", GameData.VALHALLA_TIME)
		world.emote(self, "anger", 2.0)
		world.legend_proc(self, tr("¡Furia de Valhalla!"), Color(1.0, 0.4, 0.3), "firepillar")
	elif effects.has("valhalla") and not _legend_cd.has("valhalla"):
		_legend_cd["valhalla"] = float(effects.valhalla)
	if effects.has("odin_wind") and float(_legend_cd.get("odin_wind", effects.odin_wind)) <= 0.0:
		_legend_cd["odin_wind"] = float(effects.odin_wind)
		world.pull_all_pickups(Color(0.7, 0.9, 1.0))
	elif effects.has("odin_wind") and not _legend_cd.has("odin_wind"):
		_legend_cd["odin_wind"] = float(effects.odin_wind)




func _grasshopper_counter(world: World, from: Enemy) -> void :
	if not has_dish("fried_grasshopper") or from == null or not is_instance_valid(from) or from.dead:
		return
	world.damage_tag = "grasshopper"
	world.damage_by = self
	var away: = ((from.position - position) * Vector3(1, 0, 1)).normalized()
	world.damage_enemy(from, basic_atk() * float(GameData.RECIPES.fried_grasshopper.counter), away * 2.0, "basic", basic_element())
	world.spawn_fx("hit", from.position + Vector3(0, 0.7, 0), 0.8)





var _foxfire_t: = 0.0
func _tick_foxfire(world: World, delta: float) -> void :
	_foxfire_t -= delta
	if _foxfire_t > 0.0 or downed or hp <= 0.0:
		return
	var r: Dictionary = GameData.RECIPES.nine_tail_dish
	var near: = world.enemies_in_radius(position, float(r.fox_range)).filter( func(e): return not e.dead and e.prop == "")
	if near.is_empty():
		_foxfire_t = 0.3
		return
	_foxfire_t = float(r.fox_every)
	near.sort_custom( func(a, b): return a.position.distance_squared_to(position) < b.position.distance_squared_to(position))
	world.damage_tag = "nine_tail"
	world.damage_by = self
	for e in near.slice(0, int(r.fox_count)):
		world._bounce_trace(position + Vector3(0, 1.0, 0), e.position + Vector3(0, 0.6, 0), Color(1.0, 0.55, 0.2))
		world.spawn_fx("firehit1", e.position + Vector3(0, 0.5, 0), 0.5, 0.8)
		world.damage_enemy(e, basic_atk() * float(r.fox_mult), Vector3.ZERO, "basic", "fire")





func _parry_credit(world: World, from: Enemy, pierce: bool) -> void :
	if effects.has("parry"):
		LORD_KNIGHT.credit(world, self, from, pierce)



func _on_dodge(world: World, from: Enemy = null) -> void :
	_taekwon_hit(world, from, true)
	_grasshopper_counter(world, from)
	if effects.has("lg_masamune"):
		_masamune_iai(world)
	if not effects.has("wind_step"):
		return
	add_power("wind_step", 2.0)
	if float(_legend_cd.get("wind_step", 0.0)) <= 0.0:
		_legend_cd["wind_step"] = 0.5
		cut_cooldowns(GameData.WIND_STEP_CD)





func _masamune_iai(world: World) -> void :
	if float(_legend_cd.get("masamune", 0.0)) > 0.0:
		return
	_legend_cd["masamune"] = GameData.MASA_IAI_CD
	var calm: = int(uniq.get("masa_calm", 0))
	if hurt_at > float(uniq.get("masa_at", -99.0)):
		calm = 0
	uniq["masa_at"] = world.clock
	uniq["masa_calm"] = mini(calm + 1, GameData.MASA_CALM_STACKS)
	var mult: = GameData.MASA_IAI * (1.0 + GameData.MASA_CALM * calm)
	var r: = GameData.MASA_IAI_RADIUS * sqrt(area_mult)
	var keep: = [world.damage_tag, world.damage_by]
	world.damage_tag = "lg_masamune"
	world.damage_by = self
	for e in world.enemies_in_radius(position, r):
		if e.dead:
			continue
		var away: = ((e.position - position) * Vector3(1, 0, 1)).normalized()
		world.damage_enemy(e, basic_atk() * mult, away * 1.5, "basic", basic_element())
	world.damage_tag = keep[0]
	world.damage_by = keep[1]

	var col: = Color(0.78, 0.9, 1.0).lerp(Color(1.0, 1.0, 1.0), 0.2 * calm)


	world.spawn_fx("jyumonjikiri", position + Vector3(0, 0.5, 0), 0.9 + 0.12 * calm, 0.9)
	Vfx.ring(world.fx_root, position + Vector3(0, 0.05, 0), r, Color(col, 0.7), 0.25)
	Vfx.air_impact(world.fx_root, position + Vector3(0, 0.8, 0), facing, r * 0.55)
	world.play_sound("mist_slash", 0.1, -6.0, 1.0 + 0.08 * calm)



func on_crit() -> void :
	if effects.has("freya") and float(_legend_cd.get("freya", 0.0)) <= 0.0:
		_legend_cd["freya"] = GameData.FREYA_EVERY
		cut_cooldowns(float(effects.freya), true)




func gain_coin(world: World, chance: float) -> void :
	var cap: = int(effects.get("coins", 0.0))
	if cap <= 0 or coins >= cap or randf() >= chance:
		return
	coins += 1
	refresh_counters()
	world.play_sound("coin_flip", 0.15, -8.0)


func lose_coin() -> void :
	if coins > 0:
		coins -= 1
		refresh_counters()


func _tick_coins() -> void :
	var spin: = RoAssets.sprite(["fx_coin"])
	while _coin_nodes.size() < coins:
		var s: = Sprite3D.new()
		s.texture = spin.get_frame(0, 0) if spin != null else RoAssets.radial(Color(1, 0.85, 0.3), 16)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		s.pixel_size = GameData.PIXEL_SIZE * 1.7
		add_child(s)
		_coin_nodes.append(s)
	while _coin_nodes.size() > coins:
		_coin_nodes.pop_back().queue_free()
	var t: = Time.get_ticks_msec() * 0.0018

	var turn: = int(Time.get_ticks_msec() / 90)
	for i in _coin_nodes.size():
		if spin != null:
			_coin_nodes[i].texture = spin.get_frame(0, turn + i)
		var a: = - t + TAU * i / maxf(1.0, _coin_nodes.size())




		var c: = _coin_nodes[i]
		var off: = Vector3(cos(a) * 0.95, visual.height() * 0.55 + sin(a * 2.0 + t) * 0.12, sin(a) * 0.95)
		var front: = sin(a) > 0.0
		if not front:



			var view: = RoVisual.lift.normalized()
			off -= view * maxf(0.0, off.dot(view) + 0.3)
		c.position = RoVisual.lift + off
		if c.no_depth_test != front or c.render_priority < 16:
			c.no_depth_test = front
			c.render_priority = 20 if front else 16




static func stew_hp_of(kills: int) -> float:
	var r: Dictionary = GameData.RECIPES.immortal_stew
	var full: = int(r.get("full_kills", 500))
	var slow: = maxi(1, int(r.get("slow_every", 10)))
	return float(r.per_kill) * (mini(kills, full) + maxi(0, kills - full) / slow)




func stew_gain() -> void :
	stew_kills += 1
	var add: = Player.stew_hp_of(stew_kills) - stew_hp
	if add > 0.0:
		stew_hp += add
		max_hp += add
		hp += add



func root_level() -> int:
	return mini(int(profile.get("sage_root", 0)), int(GameData.SAGE_UPGRADES.sage_root.max))




func root_hp_of(kills: int) -> float:
	var u: Dictionary = GameData.SAGE_UPGRADES.sage_root
	var full: = root_level() * int(u.per_level)
	return float(mini(kills, full) + maxi(0, kills - full) / maxi(1, int(u.slow_every)))




func on_kill(stew: = true) -> void :

	if stew and has_dish("immortal_stew"):
		stew_gain()


	if root_level() > 0:
		root_kills += 1
		var grow: = root_hp_of(root_kills) - root_hp
		if grow > 0.0:
			root_hp += grow
			max_hp += grow
			hp += grow
	if effects.has("thor"):
		thor_stacks = mini(GameData.THOR_MAX, thor_stacks + 1)
		_thor_t = GameData.THOR_TIME





func cut_cooldowns(seconds: float, capped: = false) -> void :
	for id in skills:
		if GameData.SKILLS[id].type == "passive":
			continue
		var s: Dictionary = skills[id]
		if not capped:
			s.cd -= seconds
			continue
		var room: = GameData.skill_value(id, "cooldown", s.level) * cd_for(id) * GameData.CHAIN_CUT_MAX - float(s.get("cut", 0.0))
		var cut: = minf(seconds, maxf(0.0, room))
		s.cd -= cut
		s["cut"] = float(s.get("cut", 0.0)) + cut



func is_immortal() -> bool:

	return powers.has("siegfried_token") or has_meta("only_skill")





func _tick_provoke(world: World, delta: float) -> void :
	provoke.t = float(provoke.t) - delta
	if float(provoke.t) > 0.0:
		return
	provoke.t = float(provoke.pulse)
	for e in world.enemies_in_radius(position, float(provoke.range)):
		Skills.taunt(world, self, e)
	Vfx.ring(world.fx_root, position, float(provoke.range), Color(1.0, 0.45, 0.3, 0.5), 0.35)


func _tick_gospel(world: World, delta: float) -> void :
	var glow = gospel.get("glow")
	if not powers.has("gospel"):
		if glow != null and is_instance_valid(glow):
			glow.queue_free()
		gospel = {}
		return
	if glow == null or not is_instance_valid(glow):

		var was: = Vfx.dim
		Vfx.dim = 1.0
		glow = Vfx._flat(world.fx_root, Vfx.ring_texture(), position, float(gospel.range), Color(1.0, 0.9, 0.5, 0.55))
		Vfx.dim = was
		gospel["glow"] = glow
	Vfx.hold_dim(glow, Vfx.dim)
	glow.position = Vector3(position.x, position.y + 0.05, position.z)
	gospel.t = float(gospel.t) - delta
	if float(gospel.t) > 0.0:
		return
	gospel.t = float(gospel.every)
	var r: = float(gospel.range)
	var near: = world.enemies_in_radius(position, r)
	var verses: = ["heal", "might", "guard", "haste", "smite", "smite", "slow", "frail"]
	var verse: String = verses.pick_random()
	if verse in ["slow", "frail"] and near.is_empty():
		verse = "smite"
	var say: = ""

	var gives: = ""

	var party: Array = world.heroes.filter( func(h): return not h.downed and h.position.distance_to(position) <= r)
	match verse:
		"heal":
			for h in party:
				h.heal(h.max_hp * 0.08, world, false, "gospel", self)
			say = TranslationServer.translate("Gospel: curación")
			gives = TranslationServer.translate("+8% de vida")
		"might":
			for h in party:
				h.add_power("gospel_might", 5.0)
			say = TranslationServer.translate("Gospel: fuerza")
			gives = TranslationServer.translate("+25% de daño, 5 s")
		"guard":
			for h in party:
				h.add_power("gospel_guard", 5.0)
			say = TranslationServer.translate("Gospel: defensa")
			gives = TranslationServer.translate("+6 de defensa, 5 s")
		"haste":
			for h in party:
				h.add_power("gospel_haste", 5.0)
			say = TranslationServer.translate("Gospel: prisa")
			gives = TranslationServer.translate("+25% vel. de ataque, +10% al moverte, 5 s")
		"smite":
			world.damage_tag = "gospel"
			world.damage_by = self
			for e in near:
				world.damage_enemy(e, float(gospel.dmg), ((e.position - position) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", "holy", "gospel")
			world.spawn_fx("holyhit", position + Vector3(0, 0.6, 0), 1.8, 0.8)
			say = TranslationServer.translate("Gospel: castigo")
		"slow":
			for e in near:
				e.slow_time = maxf(e.slow_time, 3.0)
			say = TranslationServer.translate("Gospel: lentitud")
		"frail":
			world.signum_crucis(self, near, r, 0.2, 4.0, {"color": Color(1.0, 0.9, 0.55)})
			say = TranslationServer.translate("Gospel: debilidad")
	Vfx.ring(world.fx_root, position, r, Color(1.0, 0.92, 0.6), 0.5)


	var col: = Color(1.0, 0.92, 0.6)
	if gives != "":
		var pc: Color = GameData.LEGEND_POWERS.get("gospel_" + verse, {}).get("color", col)
		for h in party:
			world.number(h.position + Vector3(0, 2.5, 0), say, pc, true)
			world.number(h.position + Vector3(0, 2.15, 0), gives, pc, false)
	else:
		world.number(position + Vector3(0, 2.4, 0), say, col, true)
	world.play_sound("blessing", 0.4, -10.0)



const EFFECT_BONUS: = ["intimidate", "combo_dmg", "kunai_dmg", "charm_dmg", "forge_basic", "melt", "homun_power", "homun_extra", "aura_blade", "double", "poison_hit", "arrow_dmg", "kill_heal", "vs_undead", "undead_guard", "block", "hit_proc", 
	"proc_chance", "hit_heal", "status_time", "status_vuln", "kick_fury", "aura_stats", "burn_power", "skill_burn", "bleed_hit", "bleed_dmg", "poison_stack", "poison_cap", "poison_dmg", "summon_dmg", "summon_count", "sea_wave", "chain_cast", "weak_bonus", 
	"zeny_discount", "heal_power", "auto_counter", "reflect", "block_heal", "plag_proc", "proc_power", "hindsight", "sage_double", "falcon_dmg", "auto_blitz", "trap_vuln", "trap_dmg", 
	"holy_weapon", "judgment", "weapon_perfection", "triple", "chain_combo", "combo_finish", "coins", "amp", 
	"throw_dmg", "cicada", "offhand", "vs_boss", "stance", "sprint", "kaizel", "kaahi", "adjust", "cleave_extra", "cleave_reach", "cleave_dmg", "parry", "riposte"]



func receive_party_buff(id: String, level: int, power: float, t: float) -> void :
	var old: Dictionary = party_buffs.get(id, {})
	party_buffs[id] = {"t": t, "level": level, "power": power}
	if old.is_empty() or int(old.level) != level or absf(float(old.power) - power) > 0.001:
		recompute()




func add_power(id: String, duration: = -1.0) -> void :
	var had: = powers.has(id)


	var t: = (duration if duration >= 0.0 else float(GameData.power_def(id).get("duration", 0.0))) * (1.0 if GameData.HEXES.has(id) else duration_mult)
	powers[id] = maxf(float(powers.get(id, 0.0)), t)
	if not had:
		recompute()
		_power_look()



func update_glow() -> void :
	if visual == null:
		return
	var on: = shield > 0.5 and base_skill(shield_src) == "assumptio"
	if on != (visual.glow != null):
		visual.set_glow(Color(1.0, 0.97, 0.8, 0.75) if on else null)


func _tick_powers(delta: float) -> void :
	update_glow()
	if not party_buffs.is_empty():
		var gone: = false
		for id in party_buffs.keys():
			party_buffs[id].t = float(party_buffs[id].t) - delta
			if float(party_buffs[id].t) <= 0.0:
				party_buffs.erase(id)
				gone = true
		if gone:
			recompute()
	if powers.is_empty():
		return
	var ended: = false
	var keep_hp: = -1.0
	for id in powers.keys():
		powers[id] -= delta
		if powers[id] <= 0.0:
			powers.erase(id)
			ended = true


			if id == "oath_curse":
				oath_curse = 0.0
				keep_hp = hp
	if ended:
		recompute()
		if keep_hp >= 0.0:
			hp = minf(keep_hp, max_hp)
		_power_look()







const Encore = preload("res://scripts/core/encore.gd")
const LORD_KNIGHT = preload("res://scripts/core/lord_knight.gd")
const PALADIN = preload("res://scripts/core/paladin.gd")



var songs: Array = []
var song: = ""
var beat_t: = 0.0
var beat_n: = 0
var bis_t: = 0.0


var song_book: = -1

var song_cast: = 1.0

var whip_left: = 0

var bis_count: = 0
var tarot_count: = 0
var _song_linger: = 0.0
var _song_party_t: = 0.0
var _song_aura: Node3D
var _aura_mask: = -1
var _aura_beat: = -1




func book_for_job() -> int:
	if song_book >= 0:
		return song_book
	if not (input is HeroInput.Remote):
		for a in OS.get_cmdline_user_args():
			if str(a).begins_with("--bard-book="):
				return 1 if str(a).ends_with("dances") else 0
	return 1 if female() else 0


func dance_book() -> bool:
	return book_for_job() == 1



func performer() -> String:
	var j: = str(job2.get("id", ""))
	if j != "bard" and j != "clown":
		return ""
	return "dance" if dance_book() else "song"



func owned_songs() -> Array:
	var out: Array = []
	for b in GameData.SONG_ORDER:
		for id in [b + "_x", b]:
			if skills.has(id):
				out.append(id)
				break
	return out



func songs_mask() -> int:
	var m: = 0
	for id in songs:
		var i: = GameData.SONG_ORDER.find(base_skill(str(id)))
		if i >= 0:
			m |= 1 << i
	return m



func dances_playing() -> int:
	return songs.size() if performer() == "dance" else 0



func bis_mult() -> float:
	var m: = GameData.BIS_MULT
	if effects.has("lg_whip"):
		m += GameData.LG_WHIP_BIS * dances_playing()
	return m





func bis_every() -> int:
	return maxi(2, GameData.BIS_EVERY - int(effects.get("bis_faster", 0.0)))


func song_power(id: String) -> float:

	var k: = song_cast * (1.0 + float(effects.get("song_dmg", 0.0)))
	if base_skill(id) == "dissonance":
		k *= 1.0 + GameData.CHORUS_DMG * maxi(0, songs.size() - 1)
	return k




func _tick_songs(world: World, delta: float) -> void :
	var owned: = owned_songs()
	_song_linger = GameData.SONG_LINGER if _in_combat else _song_linger - delta
	var want: Array = owned if _song_linger > 0.0 else []
	if want != songs:
		var fresh: = want.filter( func(id): return not songs.has(id))
		songs = want
		song = str(songs[0]) if not songs.is_empty() else ""
		if songs.is_empty():
			bis_t = 0.0
			beat_t = 0.0
		recompute()
		show_songs(songs_mask())


		if not fresh.is_empty():
			var s: Dictionary = GameData.SKILLS[str(fresh[0])]
			if s.has("tex_fx"):
				world.rising_tex(self, str(s.tex_fx), int(s.get("tex_count", 1)))
			world.play_skill_sound(s)
			world.label_over(self, TranslationServer.translate(str(s.name)), s.color)
	if songs.is_empty():
		return
	if bis_t > 0.0:
		bis_t -= delta
		if bis_t <= 0.0:
			bis_t = 0.0
			_song_party_t = 0.0
			recompute()
	_song_party(world, delta)
	beat_t -= delta
	if beat_t <= 0.0:
		beat_t = maxf(0.05, beat_t + GameData.BEAT_TIME)
		beat_n += 1
		var bis: = beat_n % bis_every() == 0
		if bis:
			bis_t = GameData.BIS_TIME
			_song_party_t = 0.0
			recompute()
			_song_party(world, 0.0)
		set_beat(beat_n)
		Encore.beat(world, self, bis)




func vulcan_songs() -> int:
	var n: = 0
	for id in songs:
		if GameData.AV_SONGS.has(base_skill(str(id))):
			n += 1
	for b in GameData.AV_SONGS:
		if party_buffs.has(b) and not songs.any( func(id): return base_skill(str(id)) == b):
			n += 1
	return mini(n, 2)




func _song_party(world: World, delta: float) -> void :
	_song_party_t -= delta
	if _song_party_t > 0.0 or world.heroes.size() < 2:
		return
	_song_party_t = 0.5
	var bis: = bis_mult() if bis_t > 0.0 else 1.0
	for id in songs:
		var b: = base_skill(str(id))
		if not GameData.PARTY_BUFFS.has(b):
			continue
		var power: = float(GameData.PARTY_BUFFS[b]) * (1.0 + float(effects.get("buff_power", 0.0)) + grace_buff(b)) * support_mult * bis
		for h in world.heroes:
			if h == self or h.downed or h.position.distance_to(position) > GameData.SONG_PARTY_RANGE:
				continue
			h.receive_party_buff(b, int(skills[id].level), power, 1.0)





func show_songs(mask: int) -> void :
	if mask == _aura_mask and (mask == 0 or (_song_aura != null and is_instance_valid(_song_aura))):
		return
	_aura_mask = mask
	if _song_aura != null and is_instance_valid(_song_aura):
		var old: = _song_aura
		var tw: = old.create_tween()
		tw.tween_property(old, "scale", Vector3.ONE * 0.05, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(old.queue_free)
	_song_aura = null
	if mask == 0:
		return




	var root: = Node3D.new()
	add_child(root)
	var was: = Vfx.dim
	Vfx.dim = 1.0
	var n: = 0
	for i in GameData.SONG_ORDER.size():
		if mask & (1 << i) == 0:
			continue
		var a: Dictionary = GameData.SONG_AURAS[GameData.SONG_ORDER[i]]
		if n == 0:
			Vfx.ground_glow(root, Vector3.ZERO, 1.9, Color(a.glow, 0.13))
		var ring: = Node3D.new()
		ring.position.y = 0.55 + 0.38 * n
		root.add_child(ring)

		var turn: = ring.create_tween().set_loops()
		turn.tween_property(ring, "rotation:y", TAU * (1.0 if n % 2 == 0 else -1.0), 6.5 - 1.2 * n).as_relative()

		var tex: = Encore.note_tex(str(a.notes), a.color.lightened(0.3))
		var count: = 3
		var reach: = 0.85 + 0.2 * n
		for k in count:
			var s3: = Sprite3D.new()
			s3.texture = tex
			s3.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			s3.shaded = false
			s3.no_depth_test = true
			s3.render_priority = GameData.HERO_FX_PRIORITY
			s3.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			s3.pixel_size = GameData.PIXEL_SIZE
			var ang: = TAU * k / count + 0.6 * n
			s3.position = Vector3(cos(ang), 0.0, sin(ang)) * reach
			ring.add_child(s3)
			var bob: = s3.create_tween().set_loops()
			bob.tween_interval(0.12 * k)
			bob.tween_property(s3, "position:y", 0.1, 0.4).set_trans(Tween.TRANS_SINE)
			bob.tween_property(s3, "position:y", -0.06, 0.4).set_trans(Tween.TRANS_SINE)
		n += 1
	Vfx.dim = was
	Vfx.hold_dim(root, was)
	root.scale = Vector3.ONE * 0.3
	var pop: = root.create_tween()
	pop.tween_property(root, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_song_aura = root




func set_beat(n: int) -> void :
	if n == _aura_beat:
		return
	_aura_beat = n
	if _song_aura == null or not is_instance_valid(_song_aura):
		return
	var big: = n % bis_every() == 0
	var tw: = _song_aura.create_tween()
	tw.tween_property(_song_aura, "scale", Vector3.ONE * (1.22 if big else 1.06), 0.07)
	tw.tween_property(_song_aura, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_SINE)
	if big:
		for ring in _song_aura.get_children():
			for s3 in ring.get_children():
				if s3 is Sprite3D:
					var f: = (s3 as Sprite3D).create_tween()
					f.tween_property(s3, "pixel_size", GameData.PIXEL_SIZE * 1.4, 0.08)
					f.tween_property(s3, "pixel_size", GameData.PIXEL_SIZE, 0.3)



func siegfried_grace() -> void :
	_invuln = 1.2


func set_choosing(on: bool) -> void :
	if on == choosing:
		return
	choosing = on
	_choose_t = 0.0
	if not on:
		if _choosing_sign != null:
			_choosing_sign.queue_free()
			_choosing_sign = null
		return
	var gold: = Color(1.0, 0.85, 0.35)
	_choosing_sign = Node3D.new()
	add_child(_choosing_sign)
	var l: = Label3D.new()
	l.text = "✦ %s ✦" % tr("Mejorando")
	l.font = World.RO_UI_FONT
	l.font_size = 32
	l.pixel_size = 0.015
	l.outline_size = 10
	l.outline_modulate = Color(0.25, 0.12, 0.0, 0.9)
	l.modulate = Color(1.0, 0.9, 0.45)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 21
	l.outline_render_priority = 20
	l.position = RoVisual.lift + Vector3(0, 4.6, 0)
	_choosing_sign.add_child(l)
	var bob: = l.create_tween().set_loops()
	bob.tween_property(l, "scale", Vector3.ONE * 1.12, 0.45).set_trans(Tween.TRANS_SINE)
	bob.parallel().tween_property(l, "position:y", l.position.y + 0.15, 0.45).set_trans(Tween.TRANS_SINE)
	bob.tween_property(l, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_SINE)
	bob.parallel().tween_property(l, "position:y", l.position.y, 0.45).set_trans(Tween.TRANS_SINE)

	var spin: = Node3D.new()
	spin.position = Vector3(0, 1.1, 0)
	_choosing_sign.add_child(spin)
	for i in 4:
		var spark: = Sprite3D.new()
		spark.texture = RoAssets.radial(Color.WHITE, 64)
		spark.modulate = Color(1.0, 0.95, 0.6)
		spark.pixel_size = 0.75 / 64.0
		spark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		spark.shaded = false
		spark.no_depth_test = true
		spark.render_priority = GameData.HERO_FX_PRIORITY
		var a: = TAU * i / 4.0
		spark.position = Vector3(cos(a), sin(a * 2.0) * 0.25, sin(a)) * 0.95
		spin.add_child(spark)
	var turn: = spin.create_tween().set_loops()
	turn.tween_property(spin, "rotation:y", TAU, 1.6).as_relative()
	var glow: = Vfx.ground_glow(_choosing_sign, Vector3(0, 0.05, 0), 1.8, Color(gold, 0.6))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.25, 0.6)
	tw.tween_property(glow, "modulate:a", 0.65, 0.6)


var _choose_t: = 0.0
var _choose_n: = 0




func _tick_choosing(delta: float, world: World) -> void :
	_choose_t -= delta
	if _choose_t > 0.0:
		return
	_choose_t = 0.7
	_choose_n += 1
	Vfx.ring(world.fx_root, position + Vector3(0, 0.08, 0), 1.6, Color(1.0, 0.85, 0.35, 0.85), 0.6)
	if _choose_n % 4 == 1:
		world.emote(self, "idea", 1.6)




func tick_puppet(delta: float, world: World) -> void :
	var stick: = input.move_vector(self, world) if not choosing else Vector2.ZERO
	_last_stick = stick
	var move: = Vector3(stick.x, 0, stick.y)
	_moving = move.length_squared() > 0.0001
	if choosing:
		_tick_choosing(delta, world)
	if _moving:
		var p: = world.map.slide(position, move * (net_speed if net_speed > 0.0 else move_speed) * delta)
		position = Vector3(p.x, world.map.height_at(p), p.z)
		facing = move.normalized()
		visual.face(move)
		visual.play(RoVisual.PC_WALK)
	elif net_action >= 0 and net_action != RoVisual.PC_WALK:
		visual.play(net_action)
	else:
		visual.play(RoVisual.PC_READY if world.any_enemy_near(position, 9.0) else RoVisual.PC_IDLE)
	if cart != null:
		cart.follow(visual, _moving, world.map)

	draw_spheres()
	_tick_coins()
	_tick_mirrors(delta)








func _tick_heat(delta: float, world: World) -> void :
	var sid: = ""
	for id in skills:
		if base_skill(id) == "heat_barrel":
			sid = id
	if sid == "":
		if powers.has("heat_barrel"):
			powers.erase("heat_barrel")
			recompute()
		heat_level = 0.0
		if _heat_glow != null:
			_heat_glow.queue_free()
			_heat_glow = null
			_heat_stage = -1
		if _heat_barrel != null:
			_heat_barrel.queue_free()
			_heat_barrel = null
		return
	var was: = heat_level
	if _moving or downed:
		_heat_still = 0.0
		heat_level = maxf(0.0, heat_level - delta / GameData.HEAT_COOL)

		if was >= 0.5 and not _heat_steamed:
			_heat_steamed = true
			Vfx.burst(world.fx_root, Uniques.muzzle_of(self, visual._face.normalized() if visual._face.length_squared() > 0.0001 else facing), 0.7, Color(0.85, 0.85, 0.9, 0.7))
			world.play_sound("fire", 0.3, -14.0, 1.6)
	else:
		_heat_still += delta
		if _heat_still >= GameData.HEAT_DELAY:
			heat_level = minf(1.0, heat_level + delta / GameData.HEAT_RAMP)
			_heat_steamed = false

	if heat_level > 0.0 and not powers.has("heat_barrel"):
		powers["heat_barrel"] = 1000000000.0
		_heat_stage = -1
	elif heat_level <= 0.0 and powers.has("heat_barrel"):
		powers.erase("heat_barrel")
		heat = {}
		recompute()
	var stage: = roundi(heat_level * 10.0)
	if stage != _heat_stage and heat_level > 0.0:
		_heat_stage = stage

		var lv: = int(skills[sid].level)
		var sk: Dictionary = GameData.SKILLS[sid]
		var most: = int(effects.get("coins", 0.0))
		heat_base = {"aspd": (GameData.skill_value(sid, "aspd", lv) + float(sk.get("coin_aspd", 0.0)) * most) * buff_boost_dmg(), 
			"dmg": (GameData.skill_value(sid, "dmg", lv) + float(sk.get("coin_dmg", 0.0)) * most) * buff_boost_dmg()}
		var k: = GameData.HEAT_STILL_MAX * stage / 10.0
		heat = {}
		for m in heat_base:
			heat[m] = float(heat_base[m]) * k
		recompute()
	if was < 1.0 and heat_level >= 1.0:
		world.number(position + Vector3(0, 2.4, 0), tr("¡Al rojo vivo!"), Color(1.0, 0.35, 0.1), true)
		world.play_sound("fire", 0.0, -2.0)
		world.spawn_fx("firehit1", position, 0.9, 1.0)

	if heat_level > 0.0:
		if _heat_barrel == null:
			_heat_barrel = Sprite3D.new()
			_heat_barrel.texture = RoAssets.radial(Color.WHITE, 64)
			_heat_barrel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			_heat_barrel.shaded = false
			_heat_barrel.no_depth_test = true
			_heat_barrel.render_priority = 20
			_heat_barrel.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
			_heat_barrel.top_level = true
			add_child(_heat_barrel)
		var flick: = 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.03)

		_heat_barrel.global_position = Uniques.muzzle_of(self, visual._face.normalized() if visual._face.length_squared() > 0.0001 else facing)
		_heat_barrel.pixel_size = (0.3 + 0.6 * heat_level) * flick / 64.0
		var white: = clampf((heat_level - 0.75) * 4.0, 0.0, 1.0)
		_heat_barrel.modulate = Color(1.0, lerpf(0.55, 0.92, white), lerpf(0.12, 0.6, white), (0.55 + 0.45 * heat_level) * Vfx.dim)
	elif _heat_barrel != null:
		_heat_barrel.queue_free()
		_heat_barrel = null
	if heat_level <= 0.0:
		if _heat_glow != null:
			_heat_glow.queue_free()
			_heat_glow = null
		return
	var col: = Color(1.0, 0.45 - 0.25 * heat_level, 0.1)
	if _heat_glow == null:
		_heat_glow = Vfx.ground_glow(self, Vector3(0, 0.05, 0), 1.0, Color(col, 0.4))
	_heat_glow.modulate = Color(col, (0.35 + 0.55 * heat_level) * Vfx.dim)
	_heat_glow.scale = Vector3.ONE * (0.8 + 1.4 * heat_level)

	_heat_fx_t -= delta
	if _heat_fx_t <= 0.0 and heat_level > 0.15:
		_heat_fx_t = lerpf(0.45, 0.12, heat_level)
		Vfx.ring(world.fx_root, position + Vector3(0, 0.06, 0), 0.6 + 1.2 * heat_level, Color(col, 0.8), 0.3)
		if heat_level > 0.6:
			world.spawn_fx("fire", position + Vector3(randf_range(-0.6, 0.6), 0.2, randf_range(-0.6, 0.6)), 0.35, 0.7)




var _gallop_t: = 0.0
func _gallop(delta: float, world: World) -> void :
	_gallop_t -= delta
	if _gallop_t > 0.0:
		return
	_gallop_t = 0.09
	var col: Color = GameData.LEGEND_POWERS.sleipnir_gallop.color
	Vfx.ring(world.fx_root, position + Vector3(0, 0.08, 0), 0.7, Color(col, 0.75), 0.35)
	var back: = - _vel.normalized() * 0.4 if _vel.length_squared() > 0.01 else Vector3.ZERO
	Vfx.burst(world.fx_root, position + back + Vector3(0, 0.3, 0), 0.35, Color(1, 1, 1, 0.6))



func _power_look() -> void :
	if visual == null:
		return
	var col: = Color.WHITE
	for id in powers:
		if GameData.HEXES.has(id):
			col = Color(0.8, 0.65, 1.0)
	if powers.has("berserk_potion"):
		col = Color(1.0, 0.55, 0.5)
	if powers.has("siegfried_token"):
		col = Color(1.0, 0.92, 0.55)
	if powers.has("steel_body"):

		col = Color(0.62, 0.7, 0.85)
	if powers.has("sleipnir_gallop"):
		col = Color(0.85, 0.95, 1.15)
	visual.tint = col
	visual.sprite.modulate = col

	if powers.has("union") != _union_shown:
		_union_shown = powers.has("union")


		if not _union_shown and effects.has("u_cosmos") and skills.has("union"):
			skills.union.cd = GameData.skill_value("union", "cooldown", int(skills.union.level)) * cd_for("union") * GameData.U_COSMOS_COOLDOWN
		_build_visual()
		if _union_shown:
			visual.set_glow(Color(1.0, 0.85, 0.4, 0.7))






func heal(amount: float, world: World, big: = false, source: = "", healer: Player = null) -> void :
	var cast: = amount * heal_mult * vit_heal * (GameData.HELL_FOG_HEAL if fogged else 1.0)
	var real: = minf(cast, max_hp - hp)


	if has_uniq and world != null:
		Uniques.on_heal(world, self, cast)
	if real <= 0.0:
		return
	hp += real
	run_healed += real
	if world != null and world.meter_stats.has("healed") and self == world.player:
		world.meter_stats.healed += real
	if world != null:
		world.meter_heal_add(source, real, healer if healer != null else self, self)
	if world != null:
		if big:
			world.number(position + Vector3(0, 0.6, 0), str(roundi(real)), Color(0.35, 1.0, 0.4), true)
		else:


			_heal_sum += real
			var now: = Time.get_ticks_msec()
			if now - _heal_shown_at >= int(GameData.HEAL_NUMBER_GAP * 1000.0) and _heal_sum >= 1.0:
				world.number(position, "+%d" % roundi(_heal_sum), Color(0.45, 1.0, 0.5))
				_heal_sum = 0.0
				_heal_shown_at = now




func grant_levels(n: int) -> void :
	var frac: = xp / maxf(1.0, xp_need)
	for i in n:
		xp_gained += xp_need
		level += 1
		pending_levels += 1
		xp_need = GameData.xp_to_next(level)
		leveled_up.emit()
	xp = frac * xp_need


func add_xp(amount: float) -> void :
	amount *= pace_xp
	amount *= MOD_XP_MULT
	xp_gained += amount * xp_mult
	xp += amount * xp_mult
	while xp >= xp_need:
		xp -= xp_need
		level += 1
		pending_levels += 1
		xp_need = GameData.xp_to_next(level)
		leveled_up.emit()





func open_chest(count: int, bonus: int, run_time: float, plain: = 0) -> Array:
	var out: = []

	if has_dish("lucky_soup") and randf() < float(GameData.RECIPES.lucky_soup.extra_roll):
		count += 1
	for i in count:
		out.append(equipment.receive(equipment.roll_item(run_time, bonus if i < count - plain else -1)))
	recompute()
	return out






var offer: Array = []


func offered_choices() -> Array:
	if offer.is_empty():
		offer = build_choices()
	return offer


func build_choices() -> Array:
	var pool: = []

	if has_meta("only_skill"):
		for id in stats:
			pool.append({"kind": "stat", "id": id, "level": stats[id] + 1, "w": 1.0})
		pool.shuffle()
		return pool.slice(0, 3)
	pool = _choice_pool()
	pool = pool.filter( func(o): return not banished.has(_choice_key(o)))

	for o in pool:
		if str(o.kind) in ["skill", "evolve"] and run_favs.has(base_skill(str(o.id))):
			o.w = float(o.w) * GameData.RUN_FAV_WEIGHT
	return _pick_choices(pool)



func _choice_pool() -> Array:
	var pool: = []
	if count_skills(false) < max_skills():
		for id in skill_pool():
			if not skills.has(id) and not evolved_from(id) and has_needs(id) and not sn_mult_full(id):
				pool.append({"kind": "skill", "id": id, "level": 1, "w": 1.3})
	if count_skills(true) < max_passives():
		for id in passive_pool():


			if not skills.has(id) and not evolved_from(id) and has_needs(id) and not sn_mult_full(id):
				pool.append({"kind": "skill", "id": id, "level": 1, "w": 1.0})
	for id in skills:
		if GameData.SKILLS[id].get("evolved", false):
			continue
		if skills[id].level < GameData.MAX_SKILL_LEVEL:
			pool.append({"kind": "skill", "id": id, "level": skills[id].level + 1, "w": 1.5})
		elif can_evolve(id):

			pool.append({"kind": "evolve", "id": id, "to": GameData.EVOLUTIONS[id].to, "level": 10, "w": 6.0})
		elif GameData.grows_past_cap(id):
			pool.append({"kind": "skill", "id": id, "level": skills[id].level + 1, "w": GameData.OVERLEVEL_WEIGHT})

	for id in skills:
		if GameData.SKILLS[id].get("evolved", false) and GameData.grows_past_cap(id):
			pool.append({"kind": "skill", "id": id, "level": skills[id].level + 1, "w": GameData.OVERLEVEL_WEIGHT})
	for id in stats:

		if stats[id] < GameData.STAT_HARD_CAP:
			pool.append({"kind": "stat", "id": id, "level": stats[id] + 1, "w": 0.8 if run_stat(id) < stat_cap else 0.55})
	return pool


func _pick_choices(pool: Array) -> Array:
	var picks: = []
	while picks.size() < 3 + mini(extra_choices, MAX_EXTRA_CHOICES) and not pool.is_empty():
		var total: = 0.0
		for o in pool:
			total += o.w
		var r: = randf() * total
		for i in pool.size():
			r -= pool[i].w
			if r <= 0.0 or i == pool.size() - 1:
				picks.append(pool[i])
				pool.remove_at(i)
				break



	if count_skills(false) < max_skills():
		var is_new: = func(o): return o.kind == "skill" and int(o.level) == 1 and not Player.is_passive(o.id)
		var is_first: = func(o): return is_new.call(o) and (def.skills as Array).has(o.id)
		var want: Callable = is_first if pool.any(is_first) and not picks.any(is_first) else is_new
		if not picks.any(want):
			var fresh: Array = pool.filter(want)
			if not fresh.is_empty():
				var slot: = -1
				for i in range(picks.size() - 1, -1, -1):
					if picks[i].kind != "evolve" and not is_new.call(picks[i]):
						slot = i
						break
				var one: = _weighted(fresh)
				if slot >= 0:
					picks[slot] = one
				else:
					picks.append(one)

	if not picks.any( func(o): return o.kind == "stat"):
		var stats_left: = pool.filter( func(o): return o.kind == "stat")
		if not stats_left.is_empty():
			var slot: = -1
			for i in range(picks.size() - 1, -1, -1):
				if picks[i].kind != "evolve":
					slot = i
					break
			if slot >= 0 and picks.size() >= 3 + mini(extra_choices, MAX_EXTRA_CHOICES):
				picks[slot] = stats_left.pick_random()
			else:
				picks.append(stats_left.pick_random())




	if level <= GameData.EARLY_PASSIVE_LEVEL and count_skills(true) < max_passives():
		var early: = func(o): return o.kind == "skill" and int(o.level) == 1 and bool(GameData.SKILLS[o.id].get("early", false))


		var waiting: Array = []
		for id in passive_pool():
			if GameData.SKILLS[id].get("early", false) and not skills.has(id) and not evolved_from(id) and has_needs(id) and not banished.has(_choice_key({"kind": "skill", "id": id})):
				waiting.append({"kind": "skill", "id": id, "level": 1, "w": 1.0})
		if not waiting.is_empty() and not picks.any(early):
			var stats_in: = picks.filter( func(o): return o.kind == "stat").size()
			var slot: = -1
			for i in range(picks.size() - 1, -1, -1):
				var o: Dictionary = picks[i]
				var fresh_skill: bool = o.kind == "skill" and int(o.level) == 1 and not Player.is_passive(o.id)
				if o.kind != "evolve" and not fresh_skill and not (o.kind == "stat" and stats_in <= 1):
					slot = i
					break
			if slot >= 0:
				picks[slot] = waiting.pick_random()
			else:
				picks.append(waiting.pick_random())
	if picks.is_empty():
		picks.append({"kind": "potion", "id": "potion", "level": 0})
	for o in picks:
		_roll_rarity(o)
	return picks




func _roll_rarity(o: Dictionary) -> void :
	o["rarity"] = 0
	if not o.kind in ["skill", "stat"]:
		return
	var table: Array = GameData.CHOICE_RARITY
	var w: Array[float] = []
	for t in table:
		w.append(float(t.w))
	# [MOD] swap the rarity weights (the roll below, the luck shift and the tier->steps/all_stats lookup
	# all keep using the shipped table, so nothing else about the offer changes)
	if MOD_CHOICE_W.size() == w.size():
		for i in w.size():
			w[i] = float(MOD_CHOICE_W[i])
	var shift: = minf(w[0] - 20.0, GameData.CHOICE_LUK_SHIFT * eff_stat("luk"))
	w[0] -= shift
	for i in range(1, w.size()):
		w[i] += shift * w[i] / 30.0
	var total: = 0.0
	for x in w:
		total += x
	var r: = randf() * total
	var tier: = 0
	for i in w.size():
		r -= w[i]
		if r <= 0.0:
			tier = i
			break
	var cur: int = int(o.level) - 1
	var steps: = int(table[tier].steps)
	if o.kind == "stat":
		steps = mini(steps, GameData.STAT_HARD_CAP - cur)
	o["rarity"] = tier
	# [MOD] measured odds from the real run, so "is it working?" is a number and not a feeling:
	# user://mod_probe_choices.txt (also printed) shows the distribution over every roll so far.
	mod_choice_n[tier] += 1
	mod_choice_rolls += 1
	if mod_choice_rolls % 64 == 1:
		var txt: = "rolls=%d  Comun=%d  Rara=%d  Epica=%d  Legendaria=%d  P(legend)=%.1f%%  weights=%s" % [
			mod_choice_rolls, mod_choice_n[0], mod_choice_n[1], mod_choice_n[2], mod_choice_n[3], 
			100.0 * mod_choice_n[3] / mod_choice_rolls, str(MOD_CHOICE_W)]
		print("MODPROBE choices: ", txt)
		var cf: = FileAccess.open("user://mod_probe_choices.txt", FileAccess.WRITE)
		if cf != null:
			cf.store_string(txt + "\nat=" + Time.get_datetime_string_from_system() + "\n")
			cf.close()
	o["from"] = cur
	o["level"] = cur + steps



static func _weighted(list: Array) -> Dictionary:
	var total: = 0.0
	for o in list:
		total += float(o.get("w", 1.0))
	var r: = randf() * total
	for o in list:
		r -= float(o.get("w", 1.0))
		if r <= 0.0:
			return o
	return list.back()






static func saved_bans(cid: String) -> Array:
	var all = Save.setting("run_bans", {})
	return (all.get(cid, []) as Array).duplicate() if all is Dictionary and all.get(cid) is Array else []



static func saved_favs(cid: String) -> Array:
	var all = Save.setting("run_favs", {})
	return (all.get(cid, []) as Array).slice(0, GameData.RUN_FAV_MAX) if all is Dictionary and all.get(cid) is Array else []



static func _choice_key(o: Dictionary) -> String:
	return "%s:%s" % [o.kind, o.id]




func can_banish(_choice: Dictionary) -> bool:
	return true


func banish(choice: Dictionary) -> void :
	banishes -= 1
	banished.append(_choice_key(choice))




func replacement_choice(shown: Array) -> Dictionary:
	var taken: = shown.map( func(o): return _choice_key(o))
	for i in 30:
		for o in build_choices():
			if not taken.has(_choice_key(o)):
				return o
	return {}



func can_evolve(id: String) -> bool:
	if not GameData.EVOLUTIONS.has(id) or not skills.has(id) or skills[id].level < GameData.MAX_SKILL_LEVEL or evolved_from(id):
		return false
	return skills.has(str(GameData.EVOLUTIONS[id].passive))


func evolve(id: String) -> void :
	var to: String = GameData.EVOLUTIONS[id].to
	var lv: = evolved_level(id)
	skills.erase(id)

	if not skills.has(to):
		skills[to] = {"level": lv, "cd": 0.3}





func evolved_level(id: String) -> int:
	return 1 + maxi(0, int(skills[id].level) - GameData.MAX_SKILL_LEVEL) if skills.has(id) else 1



func evolved_from(id: String) -> bool:
	return GameData.EVOLUTIONS.has(id) and skills.has(str(GameData.EVOLUTIONS[id].to))







func choice_stale(choice: Dictionary) -> bool:
	var id: = str(choice.get("id", ""))
	match str(choice.get("kind", "")):
		"evolve":
			return not skills.has(id)
		"skill":
			if banished.has("skill:" + id) and not skills.has(id):
				return true
			return not skills.has(id) and not evolved_from(id) and (sn_mult_full(id)\
			or (count_skills(true) >= max_passives() if is_passive(id) else count_skills(false) >= max_skills()))
	return false


func apply_choice(choice: Dictionary, world: World) -> void :
	match choice.kind:
		"evolve":

			if not skills.has(choice.id):
				heal(max_hp * 0.4, world)
				return
			evolve(choice.id)
			recompute()
			world.play_sound("levelup")
			world.spawn_fx("joblvup", position, 1.0, 1.0, self)
		"skill":


			if banished.has("skill:" + str(choice.id)) and not skills.has(choice.id):
				heal(max_hp * 0.4, world)
				return



			if choice_stale(choice):
				heal(max_hp * 0.4, world)
				return
			for i in int(choice.level) - int(choice.get("from", int(choice.level) - 1)):
				add_skill(choice.id)
			recompute()
		"stat":
			for i in int(choice.level) - int(choice.get("from", int(choice.level) - 1)):
				add_stat(choice.id)
		_:
			heal(max_hp * 0.4, world)

	var tier: Dictionary = GameData.CHOICE_RARITY[int(choice.get("rarity", 0))]
	if tier.has("all_stats"):
		for id in stats:
			stats[id] = mini(GameData.STAT_HARD_CAP, stats[id] + int(tier.all_stats))
		recompute()
