extends Node









signal changed

const LEGACY_RECORDS: = "user://records.json"
const VERSION: = 1

const DEBOUNCE: = 2.0



var _name: = "profile"
var PATH: = "user://profile.json"
var TMP_PATH: = "user://profile.tmp"
var BACKUP_PATH: = "user://profile.bak.json"
var data: Dictionary = {}
var _dirty: = false
var _timer: = 0.0


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	var args: = OS.get_cmdline_user_args()
	if "--smoke" in args or "--towerbuff-test" in args or "--festbuff-test" in args or "--trainreset-test" in args or "--trainsafe-test" in args or "--snmult-test" in args or "--hypernovice-test" in args or "--thorset-test" in args or "--gacha-test" in args or "--web-tour" in args or "--evodup-test" in args or "--sideword-test" in args or "--unique-bench" in args or "--rail-test" in args or "--orbit-test" in args or "--towerhud-test" in args or "--seek-test" in args or "--potion-test" in args or "--critnum-test" in args or "--status-test" in args or "--karma-test" in args or "--showcase" in args or "--itch-art" in args or "--clip" in args or "--ui-tour" in args or "--album-tour" in args or "--levelup-tour" in args or "--picks-tour" in args or "--hud-tour" in args or "--menus-tour" in args or "--intro-tour" in args or "--dump-chars" in args or "--save-test" in args or "--clutter-shots" in args or "--quest-tour" in args or "--devname-test" in args or "--debug-test" in args or "--hover-test" in args or "--aura-test" in args or "--townesc-test" in args or "--elword-test" in args or "--stone-test" in args or "--claim-test" in args or "--prochit-test" in args or "--broadcast-test" in args or "--morroc-test" in args or "--guns-test" in args or "--camturn-test" in args or "--gems-test" in args or "--taekwon-test" in args or "--rebirthlv-test" in args or "--wings-test" in args or "--buyclass-test" in args or "--frenzybtn-test" in args or "--navrail-test" in args or "--legends-test" in args or "--fetch-test" in args or "--tower-test" in args or "--face-test" in args or "--naght-test" in args or "--climb-test" in args or "--pin-test" in args or "--tower-art" in args or "--fxsheet-test" in args or "--petalbum-test" in args or "--screens-test" in args or "--eternal-test" in args or "--altar-test" in args or "--records-test" in args or "--hidpi-test" in args or "--stewbuild-test" in args or "--keeptower-test" in args or "--quake-test" in args or "--touchsell-test" in args or "--festival-test" in args or "--festskills-test" in args or "--tips-test" in args or "--autoequip-test" in args or "--titles-test" in args or "--padhints-test" in args or "--padnav-test" in args or "--sagebench" in args or "--skillbench" in args or "--feat-test" in args or "--towerpace-test" in args or "--sinhands-test" in args or "--karmabar-test" in args or "--taunt-test" in args or "--itempane-test" in args or "--procrogue-test" in args or "--towertraps-test" in args or "--towerevents-test" in args or "--towerwheel-test" in args or "--atlasdemo-test" in args or "--privacy-test" in args or "--esc-test" in args or "--filter-test" in args or "--upgrades-test" in args or "--invfull-test" in args or "--hold-test" in args or "--levels-test" in args or "--portal-test" in args or "--aspd-test" in args or "--arena-map-test" in args or "--arenaflat-test" in args or "--arenasurvey-test" in args or "--crusader-test" in args or "--skillbar-test" in args or "--title-test" in args or "--jobpick-test" in args or "--mvpchest-test" in args or "--npc-test" in args or "--crit-test" in args or "--frenzy-test" in args or "--storm-test" in args or "--guard-test" in args or "--peco-test" in args or "--sig-test" in args or "--charge-test" in args or "--fists-test" in args or "--ninja-test" in args or "--falcon-test" in args or "--clownpick-test" in args or "--startpick-test" in args or "--statmax-test" in args or "--banish-test" in args or "--goldbox-test" in args or "--options-test" in args or "--banishstat-test" in args or "--batch21-test" in args or "--dual-test" in args or "--runopts-test" in args or "--coins-test" in args or "--cleave-test" in args or "--lethal-test" in args or "--combo-test" in args or "--unique-test" in args or "--meter-test" in args or "--tank-test" in args or "--rebirthui-test" in args or "--mvphp-test" in args or "--protect-test" in args or "--pacts-test" in args or "--townsound-test" in args or "--hires-test" in args or "--buffrow-test" in args or "--traps-test" in args or "--merge-test" in args or "--invcut-test" in args or "--chestglow-test" in args or "--streak-test" in args or "--questicon-test" in args or "--gallop-test" in args or "--snare-test" in args or "--shiftcmp-test" in args or "--hypnoui-test" in args or "--heat-test" in args or "--mvpfx-test" in args or "--occult-test" in args or "--monk-test" in args or "--ruwach-test" in args or "--newmaps-test" in args or "--dmg-test" in args or "--diff-test" in args or "--quests-test" in args or "--alch-test" in args or "--smith-test" in args or "--wiz-test" in args or "--hell-test" in args or "--weather-test" in args or "--mvp-icons" in args or "--revive-test" in args or "--raid-mech" in args or "--fxprobe-test" in args or "--train-test" in args or "--asura-test" in args or "--doram-test" in args or "--songs-test" in args or "--kage-test" in args or "--partyhud-test" in args or "--coopwin-test" in args or "--chef-test" in args or "--prep-test" in args or "--trailer" in args or "--procs-test" in args or "--selectfps-test" in args or "--inspect-test" in args or "--emotepick-test" in args or "--zoom-test" in args or "--opttabs-test" in args or "--loadart-test" in args or "--charpage-test" in args or "--closeup-test" in args or "--beam-test" in args or "--npcline-test" in args or "--touch-test" in args or "--chanstress" in args or Array(args).any( func(a): return str(a).begins_with("--towernet=")) or Array(args).any( func(a): return str(a).begins_with("--festnet=")) or Array(args).any( func(a): return str(a).begins_with("--chantest=")) or Array(args).any( func(a): return str(a).begins_with("--hotest=")) or Array(args).any( func(a): return str(a).begins_with("--presence=")) or Array(args).any( func(a): return str(a).begins_with("--kicktest=")) or Array(args).any( func(a): return str(a).begins_with("--tradenet=")) or Array(args).any( func(a): return str(a).begins_with("--coop")):
		_name = "profile_test"
	elif NetSync.coop_preview():


		_name = "profile_coop"
		if not FileAccess.file_exists("user://profile_coop.json") and FileAccess.file_exists("user://profile.json"):
			DirAccess.copy_absolute(ProjectSettings.globalize_path("user://profile.json"), 
				ProjectSettings.globalize_path("user://profile_coop.json"))
	elif OS.has_feature("editor"):



		_name = "profile_dev"
		if not FileAccess.file_exists("user://profile_dev.json") and FileAccess.file_exists("user://profile.json"):
			DirAccess.copy_absolute(ProjectSettings.globalize_path("user://profile.json"), 
				ProjectSettings.globalize_path("user://profile_dev.json"))
	PATH = "user://%s.json" % _name
	TMP_PATH = "user://%s.tmp" % _name
	BACKUP_PATH = "user://%s.bak.json" % _name
	if _name == "profile_test":

		data = defaults()

		data.settings["onboarded"] = true
	else:
		load_profile()
	Lang.apply_saved()


func _process(delta: float) -> void :
	if _dirty:

		_timer -= delta * (4.0 if OS.has_feature("web") else 1.0)
		if _timer <= 0.0:
			flush()


func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE\
	or what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		flush()


static func defaults() -> Dictionary:
	return {
		"version": VERSION, 
		"zeny": 0, 
		"upgrades": {}, 

		"cards": {}, 

		"card_slots": [], 

		"stages": {}, 

		"rebirths": {}, 

		"looks": {}, 

		"unlocked": {}, 

		"classes": {}, 

		"pets": {}, 
		"pet": "", 
		"records": {}, 
		"stats": {"runs": 0, "kills": 0, "mvp_kills": 0, "boss_kills": 0, "play_time": 0.0, 
			"zeny_earned": 0, "cards_found": 0}, 


		"achievements": {}, 

		"ach_claimed": {}, 
		"coins": 0, 

		"seen": {}, 
		"settings": {"music": 0.8, "sfx": 0.8}, 

		"pacts": {}, 
	}




func load_profile() -> void :
	_web_rescue_read()
	var loaded: = _read(PATH)
	if loaded.is_empty() and FileAccess.file_exists(PATH):
		push_warning("Save: profile.json unreadable, restoring the backup.")
		loaded = _read(BACKUP_PATH)
	data = _merge(defaults(), loaded)
	data.version = VERSION
	_remove_iceicle_card()
	_migrate_quests(loaded)
	_migrate_claims(loaded)
	_refund_removed_upgrades()
	_drop_removed_pacts()
	_reset_stats_v2()
	_halve_class_stats()
	_reset_stats_v3()
	_restore_lost_wings()
	_owed_hel_wings()
	own_fists()
	_migrate_quest_eternals()
	_lock_refined()
	_clamp_refines()
	if loaded.is_empty() and _name == "profile":
		_import_legacy_records()




func _remove_iceicle_card() -> void :
	if _purge_iceicle_card(data):
		mark_dirty()


func _purge_iceicle_card(value: Variant) -> bool:
	var changed: = false
	if value is Dictionary:
		if value.erase("iceicle_card"):
			changed = true
		for key in value.keys():
			var child = value[key]
			if child is Array:
				for i in range(child.size() - 1, -1, -1):
					if str(child[i]) == "iceicle_card":
						child.remove_at(i)
						changed = true
					elif _purge_iceicle_card(child[i]):
						changed = true
			elif _purge_iceicle_card(child):
				changed = true
	elif value is Array:
		for i in range(value.size() - 1, -1, -1):
			if str(value[i]) == "iceicle_card":
				value.remove_at(i)
				changed = true
			elif _purge_iceicle_card(value[i]):
				changed = true
	return changed







const SAVE_KEY: = "Mdg-sv7#Kq2Lz9pXw4Rt"


func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text: = ""
	var raw: = FileAccess.get_file_as_bytes(path)
	if raw.size() >= 4 and raw.slice(0, 4).get_string_from_ascii() == "GDEC":
		var f: = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SAVE_KEY)
		if f == null:

			push_warning("Save: %s does not open (edited?)" % path)
			return {}
		text = f.get_as_text()
		f.close()
	else:

		text = raw.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	return parsed if parsed is Dictionary else {}







func _clamp_refines() -> void :
	var found: = [0]
	_clamp_walk(data, found)
	if found[0] > 0:
		push_warning("Save: %d pieces refined past +%d (edited save)" % [found[0], GameData.MAX_REFINE])
		data["gear_edit"] = true
		mark_dirty()


func _clamp_walk(o, found: Array) -> void :
	if o is Dictionary:
		if o.has("refine") and o.has("id") and (o.refine is int or o.refine is float) and float(o.refine) > GameData.MAX_REFINE:
			o["refine"] = GameData.MAX_REFINE
			found[0] = int(found[0]) + 1


		if o.has("pot") and o.has("id") and (load("res://scripts/core/potential.gd") as GDScript).edited(o.pot):
			found[0] = int(found[0]) + 1
		for k in o:
			if k != "settings":
				_clamp_walk(o[k], found)
	elif o is Array:
		for v in o:
			_clamp_walk(v, found)



func _merge(base: Dictionary, stored: Dictionary) -> Dictionary:
	var out: = base.duplicate(true)
	for k in stored:
		if out.has(k) and out[k] is Dictionary and stored[k] is Dictionary and not out[k].is_empty():
			out[k] = _merge(out[k], stored[k])
		else:
			out[k] = stored[k]
	return out




func _owed_hel_wings() -> void :
	if not data.get("tower") is Dictionary or not (data.tower.get("hel") is Dictionary):
		return
	for cid in (_hel().get("best", {}) as Dictionary):
		if GameData.CLASSES.has(str(cid)) and hel_best(str(cid)) >= GameData.TOWER_FLOORS and not hel_wings().has(str(cid)):
			give_hel_rose(str(cid), false)





func _restore_lost_wings() -> void :
	if data.get("wings_restored", false) or not data.get("tower") is Dictionary:
		return
	data["wings_restored"] = true
	var owed: = (data.tower.get("wings", []) as Array).size() - storage().filter( func(st): return str(st.get("id", "")) == GameData.TOWER_WINGS).size()
	for i in owed:
		add_to_storage({"id": GameData.TOWER_WINGS, "slots": 0}, true)
	mark_dirty()


func _import_legacy_records() -> void :
	var legacy: = _read(LEGACY_RECORDS)
	if legacy.is_empty():
		return
	data.records = legacy
	mark_dirty()


func mark_dirty() -> void :
	_dirty = true
	_timer = DEBOUNCE
	changed.emit()



func flush() -> void :
	if not _dirty:
		return
	_dirty = false
	if OS.has_feature("web") and data.get("settings") is Dictionary:

		data.settings["save_seq"] = int(data.settings.get("save_seq", 0)) + 1
	var file: = FileAccess.open_encrypted_with_pass(TMP_PATH, FileAccess.WRITE, SAVE_KEY)
	if file == null:
		push_error("Save: cannot write %s (%s)" % [TMP_PATH, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(data))
	file.close()
	if FileAccess.file_exists(PATH):
		DirAccess.copy_absolute(PATH, BACKUP_PATH)
	var err: = DirAccess.rename_absolute(TMP_PATH, PATH)
	if err != OK:
		push_error("Save: rename failed (%s)" % error_string(err))







const WEB_RESCUE: = "midgard_rescue_"
func web_rescue_write() -> void :
	if not OS.has_feature("web") or not FileAccess.file_exists(PATH):
		return
	var win: = JavaScriptBridge.get_interface("window")
	if win == null:
		return
	JavaScriptBridge.eval("window.__midgard_put = window.__midgard_put || function(k, v) { try { localStorage.setItem(k, v); return true; } catch (e) { return false; } };", true)
	win.__midgard_put(WEB_RESCUE + _name, Marshalls.raw_to_base64(FileAccess.get_file_as_bytes(PATH)))


func _web_rescue_read() -> void :
	if not OS.has_feature("web"):
		return
	var b64: = str(JavaScriptBridge.eval("(function() { try { return localStorage.getItem('%s') || ''; } catch (e) { return ''; } })()" % (WEB_RESCUE + _name), true))
	if b64 == "" or b64 == "<null>":
		return
	var tmp: = "user://%s.rescue" % _name
	var f: = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_buffer(Marshalls.base64_to_raw(b64))
	f.close()
	var rescued: = _read(tmp)
	var mine: = _read(PATH)
	var seq: = func(d: Dictionary) -> int:
		return int((d.get("settings", {}) as Dictionary).get("save_seq", 0)) if d.get("settings") is Dictionary else 0
	if not rescued.is_empty() and int(seq.call(rescued)) > int(seq.call(mine)):
		print("Save: newer copy from the last closed tab (seq %d over %d)" % [int(seq.call(rescued)), int(seq.call(mine))])
		DirAccess.copy_absolute(tmp, PATH)
	DirAccess.remove_absolute(tmp)


func reset_profile() -> void :
	data = defaults()
	mark_dirty()
	flush()




func reset_progress() -> void :
	var settings: Dictionary = data.get("settings", {}).duplicate(true)
	data = defaults()
	data.settings = settings
	mark_dirty()
	flush()




func record(class_id: String, run_time: float, victory: bool) -> Dictionary:
	var previous: Dictionary = data.records.get(class_id, {})
	var best_time: = maxf(run_time, float(previous.get("time", 0.0)))
	var best_victory: = victory or bool(previous.get("victory", false))
	data.records[class_id] = {"time": best_time, "victory": best_victory, 
		"runs": int(previous.get("runs", 0)) + 1}
	data.stats.runs += 1
	data.stats.play_time += run_time
	mark_dirty()
	flush()
	return {"time": best_time, "victory": best_victory}


func best(class_id: String) -> Dictionary:
	var r: Dictionary = data.records.get(class_id, {})
	return {"time": float(r.get("time", 0.0)), "victory": bool(r.get("victory", false))}




func zeny() -> int:
	return int(data.zeny)


func add_zeny(amount: int) -> void :
	if amount <= 0:
		return
	data.zeny = int(data.zeny) + amount
	data.stats.zeny_earned += amount
	mark_dirty()


func spend(amount: int) -> bool:
	if amount > zeny():
		return false
	data.zeny = zeny() - amount
	data.stats["zeny_spent"] = int(data.stats.get("zeny_spent", 0)) + amount
	mark_dirty()
	flush()
	return true




func pay(amount: int) -> bool:
	if amount > zeny():
		return false
	data.zeny = zeny() - amount
	mark_dirty()
	return true





func stat(key: String) -> float:
	return float(data.stats.get(key, 0))


func bump(key: String, n: = 1.0) -> void :
	data.stats[key] = float(data.stats.get(key, 0)) + n
	mark_dirty()





func card_misses(card: String) -> int:
	var d = data.get("card_pity", {})
	return int(d.get(card, 0)) if d is Dictionary else 0


func set_card_misses(card: String, n: int) -> void :
	if not data.get("card_pity", null) is Dictionary:
		data["card_pity"] = {}
	if n <= 0:
		(data.card_pity as Dictionary).erase(card)
	else:
		data.card_pity[card] = n
	mark_dirty()



func stat_max(key: String, v: float) -> void :
	if v > stat(key):
		data.stats[key] = v
		mark_dirty()



func mark_seen(set_name: String, id: String) -> void :
	if not data.seen.has(set_name):
		data.seen[set_name] = {}
	if not data.seen[set_name].has(id):
		data.seen[set_name][id] = true
		mark_dirty()


func has_seen(set_name: String, id: String) -> bool:
	return (data.seen.get(set_name, {}) as Dictionary).has(id)


func seen_count(set_name: String) -> int:
	return (data.seen.get(set_name, {}) as Dictionary).size()


func achieved(id: String) -> bool:
	return bool(data.achievements.get(id, false))



func complete_achievement(id: String, _coins: = 0) -> void :
	data.achievements[id] = true
	mark_dirty()


func claimed(id: String) -> bool:
	return bool(data.get("ach_claimed", {}).get(id, false))



func unclaimed_achievements() -> Array:
	return GameData.ACHIEVEMENTS.keys().filter( func(id): return achieved(id) and not claimed(id))




func claim_achievement(id: String) -> int:
	if not achieved(id) or claimed(id) or not GameData.ACHIEVEMENTS.has(id):
		return 0
	if not data.has("ach_claimed"):
		data["ach_claimed"] = {}
	data.ach_claimed[id] = true
	var c: = int(GameData.ACHIEVEMENTS[id].coins)
	data.coins = int(data.coins) + c
	mark_dirty()
	return c



func _migrate_claims(loaded: Dictionary) -> void :
	if loaded.has("ach_claimed"):
		return
	data["ach_claimed"] = {}
	for id in (data.achievements as Dictionary):
		if bool(data.achievements[id]):
			data.ach_claimed[id] = true



func coins() -> int:
	return int(data.get("coins", 0))



func add_coins(n: int) -> void :
	if n <= 0:
		return
	data["coins"] = coins() + n
	mark_dirty()



func spend_coins(n: int) -> bool:
	if n < 0 or coins() < n:
		return false
	data["coins"] = coins() - n
	mark_dirty()
	return true


func add_kills(n: int) -> void :
	data.stats.kills += n
	mark_dirty()


func add_boss_kill() -> void :
	data.stats.boss_kills += 1
	mark_dirty()




func upgrade_level(id: String) -> int:
	return int(data.upgrades.get(id, 0))



func upgrade_active(id: String) -> int:
	return upgrade_level(id) if upgrade_on(id) else 0


func upgrade_on(id: String) -> bool:
	return not (setting("upgrades_off", []) as Array).has(id)



func set_upgrade_on(id: String, on: bool) -> void :
	var off: Array = (setting("upgrades_off", []) as Array).duplicate()
	off.erase(id)
	if not on:
		off.append(id)
	set_setting("upgrades_off", off)


func set_upgrade_level(id: String, level: int) -> void :
	data.upgrades[id] = level
	mark_dirty()
	flush()




func has_card(id: String) -> bool:
	return int(data.cards.get(id, 0)) > 0 or eternal(id) > 0





func eternal(id: String) -> int:
	return int(data.get("eternal", {}).get(id, 0))



func eternal_used(id: String) -> int:
	var n: = 0
	for it in storage():
		n += (it.get("eternal", []) as Array).count(id)
	return n


func eternal_free(id: String) -> int:
	return eternal(id) - eternal_used(id)



func card_copies(id: String) -> int:
	return int(data.cards.get(id, 0))



func fusible_count() -> int:
	return GameData.CARDS.keys().filter( func(c): return can_fuse(c)).size()


func can_fuse(id: String) -> bool:
	return card_copies(id) >= GameData.fuse_cost(id)



func daily_bonus_ready() -> bool:
	return str(setting("daily_run", "")) != Time.get_date_string_from_system()




func new_fusible() -> int:
	var seen: Array = setting("fuse_seen", [])
	return GameData.CARDS.keys().filter( func(c): return can_fuse(c) and not seen.has(c)).size()



func see_fusible() -> void :
	set_setting("fuse_seen", GameData.CARDS.keys().filter( func(c): return can_fuse(c)))



func fuse_card(id: String) -> bool:
	if not can_fuse(id):
		return false
	data.cards[id] = card_copies(id) - GameData.fuse_cost(id)
	if not data.has("eternal"):
		data["eternal"] = {}
	data.eternal[id] = eternal(id) + 1
	mark_dirty()
	flush()
	return true



func eternal_room(it: Dictionary) -> int:
	return Equipment.sockets(it) - (it.get("eternal", []) as Array).size()


func can_set_eternal(uid: String, id: String) -> bool:
	var it: = storage_item(uid)
	return not it.is_empty() and eternal_free(id) > 0 and eternal_room(it) > 0\
	and Equipment.card_fits(it, id)


func set_eternal(uid: String, id: String) -> bool:
	if not can_set_eternal(uid, id):
		return false
	var it: = storage_item(uid)
	if not it.has("eternal"):
		it["eternal"] = []
	it.eternal.append(id)
	mark_dirty()
	flush()
	return true


func unset_eternal_price(id: String) -> int:
	return int(GameData.ETERNAL_UNSOCKET_ZENY[GameData.card_tier(id)])



func unset_eternal(uid: String, index: int) -> bool:
	var it: = storage_item(uid)
	if it.is_empty() or index < 0 or index >= (it.get("eternal", []) as Array).size():
		return false
	if not spend(unset_eternal_price(str(it.eternal[index]))):
		return false
	it.eternal.remove_at(index)
	mark_dirty()
	flush()
	return true



func add_card(id: String) -> bool:
	if id == "":
		return false
	var count: = int(data.cards.get(id, 0))
	data.cards[id] = count + 1
	data.stats.cards_found += 1
	mark_dirty()
	flush()
	return count == 0


func equipped_cards() -> Array:
	return data.card_slots.duplicate()


func set_equipped_cards(ids: Array) -> void :
	data.card_slots = ids.duplicate()
	mark_dirty()
	flush()




func class_unlocked(class_id: String) -> bool:
	return not GameData.CLASSES[class_id].has("unlock_cost") or bool(data.get("unlocked", {}).get(class_id, false))


func unlock_class(class_id: String) -> bool:
	if class_unlocked(class_id) or not spend(int(GameData.CLASSES[class_id].unlock_cost)):
		return false
	if not data.has("unlocked"):
		data.unlocked = {}
	data.unlocked[class_id] = true
	own_fists()
	mark_dirty()
	flush()
	return true




func class_progress(class_id: String) -> Dictionary:
	var out: = {"level": 1, "xp": 0, "stats": {}}
	var stored = data.get("classes", {}).get(class_id, {})
	if stored is Dictionary:
		for k in stored:
			out[k] = stored[k]
	return out


func _set_progress(class_id: String, prog: Dictionary) -> void :
	if not data.has("classes"):
		data.classes = {}
	data.classes[class_id] = prog
	mark_dirty()



func add_class_xp(class_id: String, amount: int) -> int:
	var prog: = class_progress(class_id)
	var gained: = 0

	if rebirth_lv(class_id) > 0:
		amount = mini(amount, roundi(class_climb_xp(class_id) * GameData.REBIRTH_LV_RUN_SHARE))
	prog.xp = int(prog.xp) + amount
	while int(prog.level) < class_max_level(class_id) and int(prog.xp) >= class_xp_need(class_id, int(prog.level)):
		prog.xp = int(prog.xp) - class_xp_need(class_id, int(prog.level))
		prog.level = int(prog.level) + 1
		gained += 1
	if int(prog.level) >= class_max_level(class_id):
		prog.xp = 0
	_set_progress(class_id, prog)
	flush()
	return gained



func class_stats(class_id: String) -> Dictionary:
	return class_progress(class_id).stats


func free_points(class_id: String) -> int:
	var prog: = class_progress(class_id)
	var used: = 0
	for k in prog.stats:
		used += int(prog.stats[k])
	return stat_points(class_id) - used




func stat_points(class_id: String) -> int:
	return (points_level(class_id) - 1) / GameData.CLASS_LEVELS_PER_POINT + pact_value(class_id, "points")




func points_level(class_id: String) -> int:
	var lv: = int(class_progress(class_id).level)
	return maxi(lv, class_max_level(class_id)) if rebirth_lv(class_id) > 0 else lv




func rebirth_lv(class_id: String) -> int:
	return int(class_progress(class_id).get("rlv", 0))



func class_xp_need(class_id: String, level: int) -> int:
	var rlv: = rebirth_lv(class_id)
	var mult: float = GameData.REBIRTH_LV_XP[mini(rlv, GameData.REBIRTH_LV_MAX) - 1] if rlv > 0 else 1.0
	return roundi(GameData.class_xp_to_next(level, rlv) * mult)



func class_climb_xp(class_id: String) -> int:
	var total: = 0
	for lv in range(1, class_max_level(class_id)):
		total += class_xp_need(class_id, lv)
	return total




func rebirth_lv_ready(class_id: String) -> bool:
	var top: bool = is_reborn(class_id) or GameData.CLASSES[class_id].get("no_rebirth", false)
	return top and rebirth_lv(class_id) < GameData.REBIRTH_LV_MAX\
	and int(class_progress(class_id).level) >= class_max_level(class_id)






func wing_feathers() -> int:
	var earned: = 0
	for cid in GameData.CLASSES:
		earned += rebirth_lv(cid)
	return maxi(0, earned - int(data.get("wing_feathers_spent", 0)))




func refine_wings(uid: String) -> bool:
	var it: = storage_item(uid)
	if it.is_empty() or str(it.get("id", "")) != GameData.TOWER_WINGS or wing_feathers() <= 0:
		return false
	if int(it.get("refine", 0)) >= GameData.WING_REFINE_MAX:
		return false
	it["refine"] = int(it.get("refine", 0)) + 1
	data["wing_feathers_spent"] = int(data.get("wing_feathers_spent", 0)) + 1
	mark_dirty()
	flush()
	return true







func _tower() -> Dictionary:
	if not data.has("tower"):
		data["tower"] = {"builds": [], "best": {}, "top": 0, "rewards": []}
	return data.tower



func tower_builds() -> Array:
	return _tower().builds





const TOWER_BUILDS_MAX: = 10




const TOWER_LOCKED_MAX: = 10


func add_tower_build(snap: Dictionary) -> void :
	var b: Array = _tower().builds
	b.append(snap)

	while b.filter( func(x): return not build_locked(x)).size() > TOWER_BUILDS_MAX:
		for i in b.size():
			if not build_locked(b[i]):
				b.remove_at(i)
				break
	mark_dirty()
	flush()


func build_locked(snap: Dictionary) -> bool:
	return bool(snap.get("locked", false))


func locked_builds() -> int:
	return _tower().builds.filter( func(x): return build_locked(x)).size()



func set_build_locked(snap: Dictionary, on: bool) -> bool:
	if on and not build_locked(snap) and locked_builds() >= TOWER_LOCKED_MAX:
		return false
	if on:
		snap["locked"] = true
	else:
		snap.erase("locked")

	var b: Array = _tower().builds
	while b.filter( func(x): return not build_locked(x)).size() > TOWER_BUILDS_MAX:
		for i in b.size():
			if not build_locked(b[i]):
				b.remove_at(i)
				break
	mark_dirty()
	flush()
	return true





const BUILD_LABEL_MAX: = 24


func build_label(snap: Dictionary) -> String:
	return str(snap.get("label", ""))



func set_build_label(snap: Dictionary, text: String) -> void :
	text = text.strip_edges().left(BUILD_LABEL_MAX)
	if text == build_label(snap):
		return
	if text == "":
		snap.erase("label")
	else:
		snap["label"] = text
	mark_dirty()
	flush()



func drop_tower_build(snap: Dictionary) -> void :
	var b: Array = _tower().builds
	for i in range(b.size() - 1, -1, -1):
		if is_same(b[i], snap):
			b.remove_at(i)
			mark_dirty()
			flush()
			return



func take_tower_build(i: int) -> Dictionary:
	var b: Array = _tower().builds
	if i < 0 or i >= b.size():
		return {}
	var out: Dictionary = b[i]
	b.remove_at(i)
	mark_dirty()
	flush()
	return out




func tower_open() -> bool:
	return bool(setting("tower_unlocked", false)) or tower_top() > 0 or not tower_builds().is_empty()



func tower_ready() -> bool:
	return max_danger() >= GameData.TOWER_UNLOCK_DANGER


func unlock_tower() -> void :
	set_setting("tower_unlocked", true)


func tower_top() -> int:
	return int(_tower().top)


func tower_best(class_id: String) -> int:
	return int(_tower().best.get(class_id, 0))



func dev_tower_floors() -> void :
	unlock_tower()
	_tower().top = maxi(int(_tower().top), GameData.TOWER_FLOORS)
	mark_dirty()
	flush()




func tower_checkpoints() -> Array:
	var out: = [1]
	var f: = GameData.TOWER_TIER_FLOORS
	while f <= tower_top():
		if f < GameData.TOWER_FLOORS or f % 50 == 0:
			out.append(f + 1)
		f += GameData.TOWER_TIER_FLOORS
	return out




func tower_cleared(class_id: String, floor: int) -> String:
	var t: = _tower()
	if floor > int(t.best.get(class_id, 0)):
		t.best[class_id] = floor
	t.top = maxi(int(t.top), floor)
	var reward: = ""


	if GameData.TOWER_REWARDS.has(floor) and not _tower_floors().has(floor):
		t.rewards.append(floor)
		reward = str(GameData.TOWER_REWARDS[floor])
	mark_dirty()
	flush()
	return reward



func _tower_floors() -> Array:
	var out: = []
	for f in _tower().rewards:
		if not out.has(int(f)):
			out.append(int(f))
	return out


func _tower_rewards_of(kind: String) -> int:
	return _tower_floors().filter( func(f): return str(GameData.TOWER_REWARDS.get(f, "")) == kind).size()



func tower_wings() -> Array:
	return _tower().get("wings", [])


func add_tower_wings(class_id: String) -> void :
	var t: = _tower()
	if not t.has("wings"):
		t["wings"] = []
	if not (t.wings as Array).has(class_id):
		t.wings.append(class_id)
	mark_dirty()
	flush()



func tower_legend_slots() -> int:
	return _tower_rewards_of("legend")



func tower_power() -> float:
	return GameData.TOWER_POWER * _tower_rewards_of("power")





func _hel() -> Dictionary:
	var t: = _tower()
	if not (t.get("hel") is Dictionary):
		t["hel"] = {"best": {}, "top": 0, "rewards": []}
	return t.hel


func hel_open() -> bool:
	return hel_earned() and hel_released()



func hel_earned() -> bool:
	return tower_top() >= GameData.TOWER_FLOORS



func hel_wait() -> int:
	if is_dev():
		return 0
	return maxi(0, GameData.HEL_TOWER_OPENS_AT - int(Time.get_unix_time_from_system()))


func hel_released() -> bool:
	return hel_wait() <= 0


func hel_top() -> int:
	return int(_hel().get("top", 0))




func hel_wings() -> Array:
	return _hel().get("wings", [])




func give_hel_rose(class_id: String, now: = true) -> bool:
	var h: = _hel()
	if not h.has("wings"):
		h["wings"] = []
	if (h.wings as Array).has(class_id):
		return false
	h.wings.append(class_id)
	add_material(GameData.HEL_WINGS_ITEM, 1)
	if now:
		flush()
	return true




func awaken_wings(uid: String) -> bool:
	var it: = storage_item(uid)
	if it.is_empty() or str(it.get("id", "")) != GameData.TOWER_WINGS or bool(it.get("hel", false))\
	or not use_material(GameData.HEL_WINGS_ITEM):
		return false
	it["hel"] = true
	mark_dirty()
	flush()
	return true


func hel_best(class_id: String) -> int:
	return int((_hel().get("best", {}) as Dictionary).get(class_id, 0))



func hel_rewarded() -> Array:
	var out: = []
	for f in _hel().get("rewards", []):
		if not out.has(int(f)):
			out.append(int(f))
	return out






func hel_cleared(class_id: String, floor: int) -> Dictionary:
	var h: = _hel()
	if floor > hel_best(class_id):
		h.best[class_id] = floor
	h.top = maxi(hel_top(), floor)
	var out: = {}
	if GameData.HEL_TOWER_REWARDS.has(floor) and not hel_rewarded().has(floor):
		h.rewards.append(floor)
		out = (GameData.HEL_TOWER_REWARDS[floor] as Dictionary).duplicate()
		if out.has("crumbs"):
			add_material("star_crumb", int(out.crumbs))
		if out.has("coins"):
			add_coins(int(out.coins))
		if out.has("cosmetic"):


			var smith = load("res://scripts/ui/gacha_panel.gd")
			var lack: Array = GameData.COSMETICS.keys().filter( func(id): return not has_cosmetic(str(id)) and smith.has_art(str(id)))

			var ranks: Array = GameData.COSMETIC_RARITY.keys()
			var best_rank: = -1
			for id in lack:
				best_rank = maxi(best_rank, ranks.find(str(GameData.COSMETICS[id].get("rarity", "common"))))
			lack = lack.filter( func(id): return ranks.find(str(GameData.COSMETICS[id].get("rarity", "common"))) == best_rank)
			out.erase("cosmetic")
			if lack.is_empty():
				out["tears"] = int(out.get("tears", 0)) + GameData.HEL_TOWER_COSMETIC_TEARS
			else:
				var id: = str(lack.pick_random())
				add_cosmetic(id)
				out["cosmetic"] = id
		if out.has("tears"):
			add_material("hel_tear", int(out.tears))
		if out.has("title"):
			mark_seen("titles", str(out.title))
	mark_dirty()
	flush()
	return out




func rebirth_lv_called(class_id: String) -> bool:
	return int(class_progress(class_id).get("rlv_called", -1)) == rebirth_lv(class_id)


func mark_rebirth_lv_called(class_id: String) -> void :
	if rebirth_lv_ready(class_id) and not rebirth_lv_called(class_id):
		var prog: = class_progress(class_id)
		prog["rlv_called"] = rebirth_lv(class_id)
		_set_progress(class_id, prog)
		flush()



func take_rebirth_lv(class_id: String) -> bool:
	if not rebirth_lv_ready(class_id):
		return false
	var prog: = class_progress(class_id)
	prog["rlv"] = rebirth_lv(class_id) + 1
	prog.level = 1
	prog.xp = 0
	_set_progress(class_id, prog)
	flush()
	return true



func rebirth_looks(class_id: String) -> Array:
	var off: Array = class_progress(class_id).get("looks_off", [])
	var out: = []
	for i in mini(rebirth_lv(class_id), GameData.REBIRTH_LV_LOOKS.size()):
		var id: = str(GameData.REBIRTH_LV_LOOKS[i].id)
		if not off.has(id):
			out.append(id)
	return out


func set_rebirth_look_shown(class_id: String, id: String, on: bool) -> void :
	var prog: = class_progress(class_id)
	var off: Array = (prog.get("looks_off", []) as Array).duplicate()
	if on:
		off.erase(id)
	elif not off.has(id):
		off.append(id)
	prog["looks_off"] = off
	_set_progress(class_id, prog)




func perm_stat_max(_class_id: String) -> int:
	return GameData.STAT_HARD_CAP


func pacts(class_id: String) -> Array:



	return (data.pacts.get(class_id, []) as Array).filter( func(id): return GameData.PACTS.has(id) and GameData.pact_unlocked(str(id))).slice(0, GameData.MAX_PACTS)




func toggle_pact(class_id: String, id: String) -> void :


	var list: Array = []
	var open: = 0
	for p in (data.pacts.get(class_id, []) as Array):
		if not GameData.PACTS.has(p):
			continue
		if GameData.pact_unlocked(str(p)):
			if open >= GameData.MAX_PACTS:
				continue
			open += 1
		list.append(p)
	if list.has(id):
		list.erase(id)
		if GameData.PACTS[id].has("points"):
			set_class_stats(class_id, {})
	elif open < GameData.MAX_PACTS:
		list.append(id)
	data.pacts[class_id] = list
	mark_dirty()


func pact_value(class_id: String, key: String) -> int:
	var n: = 0
	for id in pacts(class_id):
		n += int(GameData.PACTS[id].get(key, 0))
	return n


func set_class_stats(class_id: String, stats: Dictionary) -> void :
	var prog: = class_progress(class_id)
	prog.stats = stats.duplicate()
	_set_progress(class_id, prog)


func stat_reset_cost(class_id: String) -> int:
	return GameData.STAT_RESET_COST * points_level(class_id)



func reset_class_stats(class_id: String) -> bool:
	if not spend(stat_reset_cost(class_id)):
		return false
	set_class_stats(class_id, {})
	flush()
	return true




func has_pet(id: String) -> bool:
	return bool(data.get("pets", {}).get(id, false))


func add_pet(id: String) -> void :
	if not data.has("pets"):
		data.pets = {}
	data.pets[id] = true
	if str(data.get("pet", "")) == "":
		data.pet = id
	mark_dirty()
	flush()


func active_pet() -> String:
	var id: = str(data.get("pet", ""))
	return id if has_pet(id) else ""



func plagiarized() -> Array:
	_swap_plagiarism()
	return (data.get("plagiarism", []) as Array).filter( func(id): return GameData.SKILLS.has(id))



func _swap_plagiarism() -> void :
	for key in ["plagiarism", "plagiarism_on"]:
		var ids: Array = data.get(key, [])
		for i in ids.size():
			if GameData.PLAGIARISM_SWAPS.has(ids[i]):
				var now: String = GameData.PLAGIARISM_SWAPS[ids[i]]
				ids[i] = now if not ids.has(now) else ids[i]
				mark_dirty()
	if GameData.PLAGIARISM_SWAPS.has(data.get("plagiarism_pick", "")):
		data.plagiarism_pick = GameData.PLAGIARISM_SWAPS[data.plagiarism_pick]
		mark_dirty()



func add_plagiarism(id: String) -> bool:
	if not data.has("plagiarism"):
		data.plagiarism = []
	if (data.plagiarism as Array).has(id):
		return false
	data.plagiarism.append(id)

	mark_dirty()
	return true




func plagiarism_active() -> Array:
	var have: = plagiarized()
	if not data.has("plagiarism_on"):
		return []
	return (data.plagiarism_on as Array).filter( func(id): return have.has(id))



func plagiarism_pick() -> String:
	var id: = str(data.get("plagiarism_pick", ""))
	return id if plagiarized().has(id) else ""



func set_plagiarism_pick(id: String) -> void :
	data.plagiarism_pick = "" if plagiarism_pick() == id else id
	mark_dirty()




func toggle_plagiarism(id: String) -> bool:
	var on: = plagiarism_active()
	if on.has(id):
		on.erase(id)
	elif on.size() >= GameData.PLAGIARISM_ACTIVE:
		return false
	else:
		on.append(id)
	data.plagiarism_on = on
	mark_dirty()
	return true


func set_active_pet(id: String) -> void :
	data.pet = id
	mark_dirty()




func pet_skin() -> String:
	var id: = str(data.get("pet_skin", ""))
	return id if has_pet(id) else active_pet()


func set_pet_skin(id: String) -> void :
	data.pet_skin = id
	mark_dirty()





func _cosmetics() -> Dictionary:
	if not data.get("cosmetics") is Dictionary:
		data["cosmetics"] = {"own": {}, "wear": {}}
	var c: Dictionary = data.cosmetics
	if not c.get("own") is Dictionary:
		c["own"] = {}
	if not c.get("wear") is Dictionary:
		c["wear"] = {}
	return c


func has_cosmetic(id: String) -> bool:
	return GameData.COSMETICS.has(id) and bool(_cosmetics().own.get(id, false))



func add_cosmetic(id: String) -> bool:
	if not GameData.COSMETICS.has(id) or has_cosmetic(id):
		return false
	_cosmetics().own[id] = true
	mark_dirty()
	flush()
	return true





func remove_cosmetic(id: String) -> void :
	if not has_cosmetic(id):
		return
	_cosmetics().own.erase(id)
	for c in _cosmetics().wear:
		var mine = _cosmetics().wear[c]
		if mine is Dictionary:
			for slot in mine.keys():
				if str(mine[slot]) == id:
					mine.erase(slot)
	for c in GameData.CLASSES:
		var lk: = look(c)
		if str(lk.get("show", "")) == id:
			lk.erase("show")
			set_look(c, lk)
	mark_dirty()


func owned_cosmetics() -> Array:
	return GameData.COSMETICS.keys().filter( func(id): return has_cosmetic(str(id)))





func worn_cosmetics(class_id: String) -> Dictionary:
	var out: = {}
	var wear: Dictionary = (_cosmetics().wear as Dictionary).get(class_id, {})
	for slot in wear:
		var id: = str(wear[slot])
		if id == GameData.COSMETIC_HIDE and GameData.COSMETIC_SLOTS.has(str(slot)):
			out[str(slot)] = id
		elif has_cosmetic(id) and str(GameData.COSMETICS[id].slot) == str(slot):
			out[str(slot)] = id
	return out




func wear_cosmetic(class_id: String, slot: String, id: String) -> void :
	var wear: Dictionary = _cosmetics().wear
	var mine: Dictionary = wear.get(class_id, {})
	if id == "":
		mine.erase(slot)
	elif id == GameData.COSMETIC_HIDE and GameData.COSMETIC_SLOTS.has(slot):
		mine[slot] = id
	elif has_cosmetic(id):
		mine[str(GameData.COSMETICS[id].slot)] = id
	wear[class_id] = mine
	mark_dirty()
	flush()





func look(class_id: String) -> Dictionary:
	var out: Dictionary = GameData.DEFAULT_LOOK.duplicate()
	var stored = data.get("looks", {}).get(class_id, {})
	if stored is Dictionary:
		for k in stored:
			out[k] = stored[k]
	return out


func set_look(class_id: String, value: Dictionary) -> void :
	if not data.has("looks"):
		data.looks = {}
	data.looks[class_id] = value.duplicate()
	mark_dirty()




const RENAME_EVERY: = 8 * 3600


func rename_wait(class_id: String) -> int:
	var at: = int(data.get("renamed", {}).get(class_id, 0))
	return maxi(0, at + RENAME_EVERY - int(Time.get_unix_time_from_system())) if at > 0 else 0


func mark_renamed(class_id: String) -> void :
	if not data.has("renamed"):
		data["renamed"] = {}
	data.renamed[class_id] = int(Time.get_unix_time_from_system())
	mark_dirty()







const DEV_PUBLIC: = "-----BEGIN PUBLIC KEY-----\r\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAybnzEfbMK8LKW1PAxPFQ\r\n0Y+OZ5dNDG3pYmrr8QW2+6xuh+NYq88mnru4wIer6xK30NQYtJ2tc7Vm3I1T+T1P\r\nkfu8GZ/x4p0Xv55Vdbb047uAm31Ae8fyoxD8h3QXY/sgD46cGk0yif6yg1tsV96v\r\nivRTngtjrcspJI+/5XfIFVK1rEwHl9t2DP8ieUvCWC2rjKOUr0SjQJxyAv/krTf9\r\nhFSoIXYBouZbzva0muRHExqoYDSM4LmYYLeRXODpNOFlJG8ouFCVH+keh3K0v8yp\r\nuGEzxwzTdQwLNedxe1THau3VfiO4/2ak0Qd3yAjyvAN02Nq1sM/mVS4KOTmcP3HZ\r\nFwIDAQAB\r\n-----END PUBLIC KEY-----"








var _dev: = -1
var _dev_key: CryptoKey
var _dev_pub: CryptoKey


func is_dev() -> bool:
	if _dev < 0:
		_dev = 0
		var f: = FileAccess.open("user://dev.key", FileAccess.READ)
		if f != null:
			var k: = CryptoKey.new()
			if k.load_from_string(f.get_as_text()) == OK and _pem(k.save_to_string(true)) == _pem(DEV_PUBLIC):
				_dev_key = k
				_dev = 1
	return _dev == 1



static func _pem(text: String) -> String:
	return text.replace(char(13), "").replace(char(10), "").strip_edges()



func dev_sign(msg: String) -> String:
	if not is_dev():
		return ""
	return Marshalls.raw_to_base64(Crypto.new().sign(HashingContext.HASH_SHA256, msg.sha256_buffer(), _dev_key))



func dev_verify(msg: String, sig: String) -> bool:

	if sig.length() != 344:
		return false
	if _dev_pub == null:
		_dev_pub = CryptoKey.new()
		if _dev_pub.load_from_string(DEV_PUBLIC.replace(char(13), ""), true) != OK:
			return false
	var raw: = Marshalls.base64_to_raw(sig)
	return raw.size() > 0 and Crypto.new().verify(HashingContext.HASH_SHA256, msg.sha256_buffer(), raw, _dev_pub)





var _name_ok: = {}
func char_name(class_id: String) -> String:
	var n: = str(look(class_id).name).strip_edges()

	if n == "":
		return tr("Aventurero")
	if not _name_ok.has(n):

		_name_ok[n] = NameFilter.allowed(n) and ( not NameFilter.reserved(n) or (NameFilter.dev_name(n) and is_dev()))
	return n if _name_ok[n] else tr("Aventurero")




func is_reborn(class_id: String) -> bool:
	return int(data.rebirths.get(class_id, 0)) > 0




func rebirth_stats(class_id: String) -> int:
	return GameData.REBIRTH_STAT_BONUS if is_reborn(class_id) or GameData.CLASSES[class_id].get("no_rebirth", false) else 0



func rebirth_open(class_id: String) -> bool:
	return not GameData.CLASSES[class_id].get("no_rebirth", false) and not is_reborn(class_id)


func can_rebirth(class_id: String) -> bool:
	return rebirth_open(class_id) and ymir_fragments() >= GameData.REBIRTH_FRAGMENTS\
	and int(class_progress(class_id).level) >= GameData.REBIRTH_CLASS_LEVEL



func ymir_fragments() -> int:
	return int(data.get("ymir", 0))


func add_ymir_fragment(n: = 1) -> void :
	data["ymir"] = ymir_fragments() + n
	mark_dirty()
	flush()





func rebirth(class_id: String) -> bool:
	if not can_rebirth(class_id):
		return false
	data["ymir"] = ymir_fragments() - GameData.REBIRTH_FRAGMENTS
	data.rebirths[class_id] = 1
	_set_progress(class_id, {"level": 1, "xp": 0, "stats": {}})
	add_card(GameData.REBIRTH_CARD)
	mark_dirty()
	flush()
	return true




func class_max_level(class_id: String) -> int:
	return GameData.REBIRTH_CLASS_MAX_LEVEL if is_reborn(class_id) or GameData.CLASSES[class_id].get("no_rebirth", false) else GameData.CLASS_MAX_LEVEL




func is_stage_cleared(id: String) -> bool:
	return bool(data.stages.get(id, false))



func is_stage_hard_cleared(id: String) -> bool:
	return bool(data.get("stages_hard", {}).get(id, false))


func clear_stage_hard(id: String) -> void :
	if is_stage_hard_cleared(id):
		return
	if not data.has("stages_hard"):
		data["stages_hard"] = {}
	data.stages_hard[id] = true
	mark_dirty()
	flush()






func max_danger() -> int:
	if not data.has("max_danger"):
		var n: = 1
		for sid in GameData.STAGES:
			if is_stage_cleared(sid):
				n += 1
			if is_stage_hard_cleared(sid):
				n += 1
		data["max_danger"] = clampi(n, 1, GameData.DANGER_MAX)
	return int(data.max_danger)




func beat_danger(stage_id: String, d: int) -> bool:
	if not data.has("danger_best"):
		data["danger_best"] = {}
	data.danger_best[stage_id] = maxi(int(data.danger_best.get(stage_id, 0)), d)
	var opened: = false
	if d >= max_danger() and d < GameData.DANGER_MAX:
		data.max_danger = GameData.next_danger_unlock(d)
		opened = true
	mark_dirty()
	flush()
	return opened




func stage_danger(stage_id: String) -> int:
	return int(data.get("stage_danger", {}).get(stage_id, 0))


func set_stage_danger(stage_id: String, d: int) -> void :
	if not data.has("stage_danger"):
		data["stage_danger"] = {}
	data.stage_danger[stage_id] = d
	mark_dirty()




func oaths() -> Dictionary:
	var out: = {}
	var raw: Variant = data.get("oaths", {})
	if raw is Dictionary:
		for id in raw:
			var o: Dictionary = GameData.oath_def(str(id))
			var r: = int(raw[id])
			if not o.is_empty() and r > 0:
				out[str(id)] = mini(r, (o.pts as Array).size())
	return out


func set_oath(id: String, rank: int) -> void :
	if not data.has("oaths") or not (data.oaths is Dictionary):
		data["oaths"] = {}
	if rank <= 0:
		data.oaths.erase(id)
	else:
		data.oaths[id] = rank
	mark_dirty()



func oath_best(stage_id: String) -> int:
	return int(data.get("oath_best", {}).get(stage_id, 0))



func oath_top() -> int:
	var top: = 0
	for sid in data.get("oath_best", {}):
		top = maxi(top, int(data.oath_best[sid]))
	return top




func oath_beat(stage_id: String, points: int) -> bool:
	if points <= oath_best(stage_id):
		return false
	if not data.has("oath_best") or not (data.oath_best is Dictionary):
		data["oath_best"] = {}
	data.oath_best[stage_id] = points
	mark_dirty()
	return true



func danger_best(stage_id: String) -> int:
	var best: = int(data.get("danger_best", {}).get(stage_id, 0))
	return maxi(best, 1) if best == 0 and is_stage_cleared(stage_id) else best



func entered(stage_id: String) -> bool:
	return bool(data.get("entered", {}).get(stage_id, false)) or is_stage_cleared(stage_id)


func mark_entered(stage_id: String) -> void :
	if not data.has("entered"):
		data["entered"] = {}
	if not bool(data.entered.get(stage_id, false)):
		data.entered[stage_id] = true
		mark_dirty()



func region_unlocked(region_id: String) -> bool:
	var need: = str(GameData.REGIONS[region_id].get("unlock", ""))
	if need == "":
		return true
	for sid in GameData.REGIONS[need].stages:
		if is_stage_cleared(sid):
			return true
	return false


func clear_stage(id: String) -> void :
	if is_stage_cleared(id):
		return
	data.stages[id] = true
	mark_dirty()
	flush()





func quest_done(stage_id: String) -> bool:
	return bool(data.get("quests", {}).get(stage_id, false))


func complete_quest(stage_id: String) -> void :
	if quest_done(stage_id):
		return
	if not data.has("quests"):
		data["quests"] = {}
	data.quests[stage_id] = true
	_quest_eternal(stage_id)
	mark_dirty()
	flush()




func _quest_eternal(stage_id: String) -> void :
	var rw: Dictionary = GameData.QUESTS.get(stage_id, {}).get("reward", {})
	if not rw.has("card"):
		return
	var given: Array = data.get("quest_eternals", [])
	if given.has(stage_id):
		return
	given.append(stage_id)
	data["quest_eternals"] = given
	if not data.has("eternal"):
		data["eternal"] = {}
	data.eternal[str(rw.card)] = eternal(str(rw.card)) + 1
	mark_dirty()




func _lock_refined() -> void :
	if bool(setting("lock10_done", false)):
		return
	for it in storage():
		if int(it.get("refine", 0)) >= GameData.MAX_REFINE:
			it["lock"] = true
	set_setting("lock10_done", true)



func _migrate_quest_eternals() -> void :
	for stage_id in (data.get("quests", {}) as Dictionary):
		if bool(data.quests[stage_id]):
			_quest_eternal(str(stage_id))







const REMOVED_UPGRADES: = {"skill_slot": [25000]}


func _refund_removed_upgrades() -> void :
	for id in REMOVED_UPGRADES:
		var lv: = int(data.upgrades.get(id, 0))
		if lv <= 0:
			continue
		var paid: = 0
		for i in mini(lv, (REMOVED_UPGRADES[id] as Array).size()):
			paid += int(REMOVED_UPGRADES[id][i])
		data.upgrades.erase(id)
		data.zeny = int(data.zeny) + paid
		mark_dirty()






func _reset_stats_v2() -> void :
	if data.get("stats_v2", false):
		return
	data["stats_v2"] = true
	for class_id in data.get("classes", {}):
		var prog = data.classes[class_id]
		if prog is Dictionary and not (prog.get("stats", {}) as Dictionary).is_empty():
			prog["stats"] = {}
	mark_dirty()




func _reset_stats_v3() -> void :
	if data.get("stats_v3", false):
		return
	data["stats_v3"] = true
	for class_id in data.get("classes", {}):
		var prog = data.classes[class_id]
		if prog is Dictionary and not (prog.get("stats", {}) as Dictionary).is_empty():
			prog["stats"] = {}
	mark_dirty()





func _halve_class_stats() -> void :
	if data.get("stats_half", false):
		return
	data["stats_half"] = true
	for class_id in data.get("classes", {}):
		var prog = data.classes[class_id]
		if not (prog is Dictionary) or not GameData.CLASSES.has(str(class_id)):
			continue
		var st: Dictionary = prog.get("stats", {})
		if st.is_empty():
			continue
		var half: = {}
		var used: = 0
		for k in st:
			half[k] = int(st[k]) / 2
			used += int(half[k])
		var room: = stat_points(str(class_id))
		while used > room and used > 0:
			var top: = ""
			for k in half:
				if top == "" or int(half[k]) > int(half[top]):
					top = k
			half[top] = int(half[top]) - 1
			used -= 1
		for k in half.keys():
			if int(half[k]) <= 0:
				half.erase(k)
		prog["stats"] = half
	mark_dirty()


func _drop_removed_pacts() -> void :
	for class_id in data.pacts:
		var list: Array = data.pacts[class_id]
		if list.has("discipline"):
			list.erase("discipline")
			set_class_stats(str(class_id), {})
			mark_dirty()


func _migrate_quests(_loaded: Dictionary) -> void :
	if not data.has("quests"):
		data["quests"] = {}
	if not data.has("legacy_npcs"):
		data["legacy_npcs"] = {}
	var legacy: Dictionary = data.legacy_npcs
	var changed: = false
	for npc in GameData.QUEST_NPC_UNLOCK:
		if not legacy.has(npc):
			legacy[npc] = is_stage_cleared(str(GameData.QUEST_NPC_UNLOCK[npc]))
			changed = true
	if changed:
		mark_dirty()




func kafra() -> String:
	var k: = str(setting("kafra", GameData.KAFRAS[0]))
	return k if GameData.KAFRAS.has(k) else GameData.KAFRAS[0]


func npc_unlocked(npc_id: String) -> bool:
	if not GameData.QUEST_NPC_UNLOCK.has(npc_id):
		return true
	return quest_done(str(GameData.QUEST_NPC_UNLOCK[npc_id])) or bool(data.get("legacy_npcs", {}).get(npc_id, false))




func recipe_known(id: String) -> bool:
	var stage: = str(GameData.RECIPES[id].quest)
	if quest_done(stage):
		return true
	for npc in GameData.QUEST_NPC_UNLOCK:
		if str(GameData.QUEST_NPC_UNLOCK[npc]) == stage and bool(data.get("legacy_npcs", {}).get(npc, false)):
			return true
	return false



func cook_level() -> int:
	return clampi(int(data.get("cook_level", 1)), 1, GameData.CHEF_MAX_LEVEL)



func cook_next_cost() -> int:
	return int(GameData.CHEF_LEVEL_COST.get(cook_level() + 1, 0))



func cook_upgrade() -> bool:
	var cost: = cook_next_cost()
	if cost <= 0 or not spend(cost):
		return false
	data["cook_level"] = cook_level() + 1
	mark_dirty()
	flush()
	return true




func dishes() -> Array:
	var raw: Array = data.get("dishes", [data.get("dish", "")] if str(data.get("dish", "")) != "" else [])
	var out: = []
	for id in raw.map( func(x): return GameData.RECIPE_RENAMED.get(str(x), str(x))):
		if GameData.RECIPES.has(str(id)) and recipe_known(str(id)) and not out.has(str(id)):
			out.append(str(id))
	return out.slice(0, cook_level())


func set_dishes(ids: Array) -> void :
	data["dishes"] = ids.slice(0, cook_level())
	data.erase("dish")
	mark_dirty()



func dish() -> String:
	var d: = dishes()
	return str(d[0]) if not d.is_empty() else ""



func set_dish(id: String) -> void :
	set_dishes([id])






func storage() -> Array:
	if not data.has("storage"):
		data["storage"] = []
	return data.storage


func storage_cap() -> int:

	var own: = 1 if not storage_item(FISTS_UID).is_empty() else 0
	return GameData.STORAGE_BASE + GameData.STORAGE_PER_LEVEL * upgrade_level("kafra_storage") + own








const FISTS_UID: = "fists"


func own_fists() -> Dictionary:
	var it: = storage_item(FISTS_UID)
	if it.is_empty() and class_unlocked("taekwon"):
		it = {"id": "fists", "slots": int(GameData.ITEMS.fists.fixed_slots), "extra_slots": 0, "refine": 0, "cards": [], "uid": FISTS_UID}
		storage().append(it)
		mark_dirty()
	return it


func storage_item(uid: String) -> Dictionary:
	for it in storage():
		if str(it.get("uid", "")) == uid:
			return it
	return {}





func add_to_storage(it: Dictionary, over_cap: = false) -> bool:

	if bool(it.get("lent", false)):
		return false
	if storage().size() >= storage_cap() and not over_cap:
		return false
	var copy: = {"id": str(it.id), "slots": int(it.slots), "extra_slots": int(it.get("extra_slots", 0)), "refine": 0, "cards": [], 
		"uid": "%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]}

	if GameData.PURPLE_TRAITS.has(str(it.get("trait", ""))):
		copy["trait"] = str(it. trait )
	storage().append(copy)
	mark_dirty()
	flush()
	return true




func roll_trait(uid: String) -> String:
	var it: = storage_item(uid)
	if it.is_empty() or not Equipment.can_trait(it):
		return ""
	var pool: Array = GameData.PURPLE_TRAITS.keys().filter( func(k): return str(k) != str(it.get("trait", "")))
	if not spend(Equipment.trait_price(it)):
		return ""
	it["trait"] = str(pool.pick_random())
	it["trait_rolls"] = int(it.get("trait_rolls", 0)) + 1
	mark_dirty()
	flush()
	return str(it. trait )



func remove_from_storage(uid: String) -> void :
	var list: = storage()
	for i in range(list.size() - 1, -1, -1):
		if str(list[i].get("uid", "")) == uid:
			list.remove_at(i)
	for cid in loadouts():
		var lo: Dictionary = loadouts()[cid]
		for k in lo.keys():
			if str(lo[k]) == uid:
				lo.erase(k)
	mark_dirty()
	flush()




func sn_build() -> Dictionary:
	if not data.get("sn_build") is Dictionary:
		data["sn_build"] = {"skills": ["bash"], "passives": []}

	var fit: = GameData.sn_trim(data.sn_build)
	if fit != data.sn_build:
		data["sn_build"] = fit
		mark_dirty()
	return data.sn_build


func set_sn_build(build: Dictionary) -> void :
	data["sn_build"] = GameData.sn_trim({"skills": (build.get("skills", []) as Array).duplicate(), "passives": (build.get("passives", []) as Array).duplicate()})
	mark_dirty()
	flush()


func loadouts() -> Dictionary:
	if not data.has("loadouts"):
		data["loadouts"] = {}
	return data.loadouts



func loadout(class_id: String) -> Dictionary:
	if not loadouts().has(class_id):
		loadouts()[class_id] = {}
	return loadouts()[class_id]




func loadout_pieces(class_id: String) -> int:
	return loadout(class_id).keys().filter( func(k): return not k in GameData.LOADOUT_FREE_SLOTS).size()


func loadout_cap() -> int:
	return GameData.LOADOUT_BASE + upgrade_level("kafra_cart")




func set_loadout_slot(class_id: String, slot: String, uid: String) -> void :
	if uid != "":
		for cid in loadouts():
			var lo: Dictionary = loadouts()[cid]
			for k in lo.keys():
				if str(lo[k]) == uid:
					lo.erase(k)
		loadout(class_id)[slot] = uid
	else:
		loadout(class_id).erase(slot)
	mark_dirty()
	flush()




const SETS_MAX: = 8


func sets(kind: String) -> Array:
	if not data.has("sets"):
		data["sets"] = {}
	if not data.sets.has(kind):
		data.sets[kind] = []
	return data.sets[kind]




func save_set(kind: String, set_name: String, value: Variant) -> bool:
	var list: = sets(kind)
	for s in list:
		if str(s.name) == set_name:
			s.value = value
			mark_dirty()
			flush()
			return true
	if list.size() >= SETS_MAX:
		return false
	list.append({"name": set_name, "value": value})
	mark_dirty()
	flush()
	return true


func delete_set(kind: String, index: int) -> void :
	var list: = sets(kind)
	if index >= 0 and index < list.size():
		list.remove_at(index)
		mark_dirty()
		flush()



const HISTORY_MAX: = 50


func history() -> Array:
	return data.get("history", [])


func add_history(entry: Dictionary) -> void :
	if not data.get("history") is Array:
		data["history"] = []
	data.history.push_front(entry)
	if data.history.size() > HISTORY_MAX:
		data.history.resize(HISTORY_MAX)
	mark_dirty()



func loadout_owner(uid: String) -> String:
	for cid in loadouts():
		for k in loadouts()[cid]:
			if str(loadouts()[cid][k]) == uid:
				return str(cid)
	return ""


func materials() -> Dictionary:
	if not data.has("materials"):
		data["materials"] = {}
	return data.materials


func material(id: String) -> int:
	return int(materials().get(id, 0))





func festival_daily_ready() -> bool:
	return str(data.get("festival_daily", "")) != Time.get_date_string_from_system(true)


func take_festival_daily(day: = "") -> void :
	data["festival_daily"] = day if day != "" else Time.get_date_string_from_system(true)
	mark_dirty()
	flush()


func add_material(id: String, n: = 1) -> void :
	materials()[id] = material(id) + n
	mark_dirty()


func use_material(id: String) -> bool:
	if material(id) <= 0:
		return false
	materials()[id] = material(id) - 1
	mark_dirty()
	return true


func setting(key: String, fallback: Variant = null) -> Variant:
	return data.settings.get(key, fallback)


func set_setting(key: String, value: Variant) -> void :
	data.settings[key] = value
	mark_dirty()
