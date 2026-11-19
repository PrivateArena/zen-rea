class_name Leaderboard
extends Node







signal board_ready(key: String, data: Dictionary)
signal submitted(data: Dictionary)

signal ranks_ready(data: Dictionary)

const URL: = "https://muhsglgrozsjvbpghvcf.supabase.co/rest/v1/rpc/"

const KEY: = "sb_publishable_-hYqBg98znYcMAPXZHJWfQ_q04F3v8t"
const TIMEOUT: = 8.0


var _cache: = {}

var ranks: = {}
var _ranks_at: = -100000



static func player_id() -> String:
	var id: = str(Save.setting("player_id", ""))
	if id.length() < 16:
		var c: = Crypto.new()
		id = c.generate_random_bytes(12).hex_encode()
		Save.set_setting("player_id", id)
	return id


static func tag() -> String:
	return "#" + player_id().substr(0, 4).to_upper()



static func honest() -> bool:
	return not bool(Save.data.get("gear_edit", false))


static func enabled() -> bool:

	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("--") and a != "--lang" and a != "--update-url":
			return false
	return true


func cached(class_id: String, stage_id: String) -> Dictionary:
	return _cache.get(class_id + "|" + stage_id, {})





const FESTIVAL_STAGE: = "emperium_festival"
const FESTIVAL_PARTY_STAGE: = "emperium_festival_party"


func submit_festival(class_id: String, score: int, checks: int, look: = {}, party: = false, dmg: = 0.0) -> void :
	if not enabled() or not honest() or score < 1 or not bool(Save.setting("share_records", true)):
		submitted.emit({})
		return
	var body: = {"p_class": class_id, "p_player": player_id(), "p_name": Save.char_name(class_id).strip_edges().substr(0, 24), 
		"p_tag": tag(), "p_score": score, "p_checks": checks, "p_party": party, "p_version": str(Updater.version), "p_look": look, 


		"p_dmg": maxf(dmg, float(score))}
	var stage: = FESTIVAL_PARTY_STAGE if party else FESTIVAL_STAGE
	_call("submit_festival", body, func(ok: bool, data):
		_cache.erase("all|" + stage)
		_cache.erase(class_id + "|" + stage)
		submitted.emit(data if ok and data is Dictionary and bool(data.get("ok", false)) else {}))




func claim_festival_daily(done: Callable) -> void :
	if not enabled() or Save._name != "profile":
		done.call(false, "")
		return
	_call("claim_festival_daily", {"p_player": player_id(), "p_secret": str(Save.setting("cloud_secret", ""))}, func(ok: bool, d):
		if not ok or not d is Dictionary:
			done.call(false, "")
			return
		done.call(bool(d.get("ok", false)), str(d.get("day", ""))))



func fetch(class_id: String, stage_id: String) -> void :
	var key: = class_id + "|" + stage_id
	var c: Dictionary = _cache.get(key, {})
	if not c.is_empty() and Time.get_ticks_msec() - int(c.get("_at", 0)) < 30000:
		board_ready.emit(key, c)
		return
	_call("month_board", {"p_class": class_id, "p_stage": stage_id, "p_player": player_id(), "p_limit": 10}, 
		func(ok: bool, data):
			var d: Dictionary = data if ok and data is Dictionary else {}
			if not d.is_empty():
				d["_at"] = Time.get_ticks_msec()
				_cache[key] = d
			board_ready.emit(key, d))



func fetch_ranks() -> void :
	if Time.get_ticks_msec() - _ranks_at < 30000:
		ranks_ready.emit.call_deferred(ranks)
		return
	_call("my_ranks", {"p_player": player_id()}, func(ok: bool, data):
		if ok and data is Dictionary:
			ranks = data
			_ranks_at = Time.get_ticks_msec()
		ranks_ready.emit(ranks))





func send_feedback(kind: String, message: String, context: Dictionary, shot_b64: String, done: = Callable()) -> void :
	var body: = {"p_player": player_id(), "p_kind": kind, "p_message": message.substr(0, 2000), "p_context": context, 
		"p_version": str(Updater.version)}
	if shot_b64 != "":
		body["p_shot"] = shot_b64
	_call("submit_feedback", body, func(ok: bool, data):
		var d: Dictionary = data if ok and data is Dictionary else {}
		if d.is_empty():
			body.erase("p_shot")
			var queue: Array = Save.setting("feedback_queue", [])
			if queue.size() < 10:
				queue.append(body)
				Save.set_setting("feedback_queue", queue)
		if done.is_valid():
			done.call(d))



func flush_feedback() -> void :
	var queue: Array = Save.setting("feedback_queue", [])
	if queue.is_empty() or not enabled():
		return
	Save.set_setting("feedback_queue", [])
	for body in queue:
		if body is Dictionary:
			var b: Dictionary = body
			b["p_player"] = player_id()
			_call("submit_feedback", b, func(_ok, _d): pass)


func _ready() -> void :

	process_mode = Node.PROCESS_MODE_ALWAYS
	flush_feedback.call_deferred()
	var beat: = Timer.new()
	beat.wait_time = HEARTBEAT_EVERY
	beat.timeout.connect(heartbeat)
	add_child(beat)
	beat.start()

	get_tree().create_timer(2.0, true).timeout.connect(heartbeat)





const HEARTBEAT_EVERY: = 120.0
var online: = -1
signal online_changed(n: int)

func heartbeat() -> void :
	if not enabled():
		return
	var w = get_parent()
	var place: = "menu"
	var coop: = false
	if w is World:
		var world: World = w
		if world.town != null and is_instance_valid(world.town):
			place = "town"
		elif world.running:
			place = "tower" if world.tower != null and is_instance_valid(world.tower) else "run"
		coop = world.is_coop()


	var fr: Node = w.friends if w is World and w.friends != null else null
	var channel: = 0
	if w is World and place == "town" and w.channel != null and w.channel.is_in():
		channel = int(w.channel.number)
	_call("heartbeat_v2", {"p_player": player_id(), "p_version": str(Updater.version), "p_place": place, 
		"p_platform": OS.get_name(), "p_coop": coop, "p_name": Save.char_name(fr.my_class()) if fr != null else "", 
		"p_class": fr.my_class() if fr != null else "", "p_job": fr.my_job() if fr != null else "", "p_channel": channel}, 
		func(ok: bool, data):
			if ok and data is Dictionary and data.has("online"):
				online = int(data["online"])
				online_changed.emit(online)
				if fr != null and is_instance_valid(fr):
					fr.on_beat(data))







func submit(class_id: String, stage_id: String, time_s: float, zeny: int, danger: int, mvps: int, look: = {}, frenzy: = false, oath: = 0) -> void :
	if not enabled() or not honest() or time_s < 30.0 or not bool(Save.setting("share_records", true)):
		submitted.emit({})
		return
	var name: = Save.char_name(class_id).strip_edges().substr(0, 24)
	var body: = {"p_class": class_id, "p_stage": stage_id, "p_player": player_id(), "p_name": name, 
		"p_tag": tag(), "p_time": roundi(time_s), "p_zeny": maxi(0, zeny), "p_danger": danger, "p_mvps": mvps, 
		"p_version": str(Updater.version)}
	if not look.is_empty():
		body["p_look"] = look
	if frenzy:
		body["p_frenzy"] = true
	if oath > 0:
		body["p_oath"] = oath

	_ranks_at = -100000
	_submit_record(body, class_id, stage_id)


func _submit_record(body: Dictionary, class_id: String, stage_id: String, again: = true) -> void :
	_call("submit_record", body, func(ok: bool, data):
		if not ok and again:



			_submit_record(body, class_id, stage_id, false)
			return
		if not ok and body.has("p_oath"):

			body.erase("p_oath")
			_submit_record(body, class_id, stage_id, false)
			return
		if not ok and (body.has("p_look") or body.has("p_frenzy")):

			body.erase("p_look")
			body.erase("p_frenzy")
			_call("submit_record", body, func(ok2: bool, data2):
				_cache.erase(class_id + "|" + stage_id)
				submitted.emit(data2 if ok2 and data2 is Dictionary and bool(data2.get("ok", false)) else {}))
			return
		_cache.erase(class_id + "|" + stage_id)
		submitted.emit(data if ok and data is Dictionary and bool(data.get("ok", false)) else {}))




const TOWER_STAGE: = "endless_tower"

const TOWER_PARTY_STAGE: = "endless_tower_party"





func submit_tower(class_id: String, floor: int, time_s: float, look: = {}, party: = false) -> void :
	if not enabled() or not honest() or floor < 1 or not bool(Save.setting("share_records", true)):
		submitted.emit({})
		return
	var body: = {"p_class": class_id, "p_player": player_id(), "p_name": Save.char_name(class_id).strip_edges().substr(0, 24), 
		"p_tag": tag(), "p_floor": floor, "p_time": maxi(1, roundi(time_s)), "p_version": str(Updater.version)}
	if not look.is_empty():
		body["p_look"] = look
	_ranks_at = -100000
	var stage: = TOWER_PARTY_STAGE if party else TOWER_STAGE
	_call("submit_tower_party" if party else "submit_tower", body, func(ok: bool, data):
		_cache.erase(class_id + "|" + stage)
		_cache.erase("all|" + stage)
		submitted.emit(data if ok and data is Dictionary and bool(data.get("ok", false)) else {}))





func submit_hel(class_id: String, floor: int, time_s: float, oath: = 0, look: = {}, party: = false) -> void :
	if not enabled() or not honest() or floor < 1 or not bool(Save.setting("share_records", true)):
		submitted.emit({})
		return
	var body: = {"p_class": class_id, "p_player": player_id(), "p_name": Save.char_name(class_id).strip_edges().substr(0, 24), 
		"p_tag": tag(), "p_floor": floor, "p_time": maxi(1, roundi(time_s)), "p_oath": clampi(oath, 0, 99), 
		"p_party": party, "p_version": str(Updater.version)}
	if not look.is_empty():
		body["p_look"] = look
	_ranks_at = -100000
	var stage: = GameData.HEL_TOWER_STAGE
	_call("submit_hel", body, func(ok: bool, data):
		_cache.erase(class_id + "|" + stage)
		_cache.erase("all|" + stage)
		submitted.emit(data if ok and data is Dictionary and bool(data.get("ok", false)) else {}))




func rename(class_id: String, new_name: String, done: = Callable()) -> void :
	if not enabled() or not bool(Save.setting("share_records", true)):
		return
	_call("rename_player", {"p_player": player_id(), "p_class": class_id, "p_name": new_name.strip_edges().substr(0, 24)}, 
		func(ok: bool, data):
			_cache.clear()
			if done.is_valid():
				done.call(data if ok and data is Dictionary else {}))











var _unsafe: = false
var _system: = false
static var tls_blocked: = false
static var _system_tls: TLSOptions = null



static func system_tls() -> TLSOptions:
	if _system_tls == null:
		var pem: = OS.get_system_ca_certificates()
		if pem != "":
			var cert: = X509Certificate.new()
			if cert.load_from_string(pem) == OK:
				_system_tls = TLSOptions.client(cert)
	return _system_tls

const SECRET_FIELDS: = ["p_secret", "p_pass", "p_answers", "p_code"]


static func _private(fn: String, body: Dictionary) -> bool:
	if fn.begins_with("cloud_"):
		return true
	for k in SECRET_FIELDS:
		if body.has(k):
			return true
	return false




static func offline_text(plain: = "") -> String:
	if tls_blocked:
		return TranslationServer.translate("Tu antivirus bloquea la conexión segura (análisis HTTPS): desactívalo para usar tu cuenta y la nube.")
	return plain if plain != "" else TranslationServer.translate("Sin conexión: prueba de nuevo.")






const RELAY_URL: = "https://relay.midgardsurvivors.com/sb/rest/v1/rpc/"
const UNREACHABLE: = [HTTPRequest.RESULT_CANT_CONNECT, HTTPRequest.RESULT_CANT_RESOLVE, HTTPRequest.RESULT_CONNECTION_ERROR, 
	HTTPRequest.RESULT_NO_RESPONSE, HTTPRequest.RESULT_TIMEOUT, HTTPRequest.RESULT_REQUEST_FAILED]
static var via_relay: = false






const CALLS_PER_MIN: = 30
var _calls: = {}


func _call(fn: String, body: Dictionary, done: Callable, retry: = true, relayed: = false) -> void :

	if retry and not relayed:
		var now: = Time.get_ticks_msec()
		var times: Array = (_calls.get(fn, []) as Array).filter( func(t): return now - int(t) < 60000)
		if times.size() >= CALLS_PER_MIN:
			_calls[fn] = times
			if times.size() == CALLS_PER_MIN:
				push_warning("Leaderboard: %s called too often, held back" % fn)
				times.append(now)
			done.call(false, null)
			return
		times.append(now)
		_calls[fn] = times
	relayed = relayed or via_relay
	var http: = HTTPRequest.new()
	http.timeout = TIMEOUT

	http.accept_gzip = not OS.has_feature("web")
	var private: = _private(fn, body)
	if _unsafe and not private:
		http.set_tls_options(TLSOptions.client_unsafe())
	elif _system and system_tls() != null:
		http.set_tls_options(system_tls())
	add_child(http)
	http.request_completed.connect( func(result: int, code: int, _h: PackedStringArray, raw: PackedByteArray):
		http.queue_free()
		if result == HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			if not _system and system_tls() != null:
				_system = true
				_call(fn, body, done, retry, relayed)
				return
			if private:
				tls_blocked = true
			elif retry and not _unsafe:
				_unsafe = true
				_call(fn, body, done, false, relayed)
				return
		elif UNREACHABLE.has(result):
			if not relayed:
				via_relay = true
				_call(fn, body, done, retry, true)
				return

			via_relay = false
		elif private and result == HTTPRequest.RESULT_SUCCESS:
			tls_blocked = false
		var ok: = result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300

		done.call(ok, JSON.parse_string(raw.get_string_from_utf8()) if ok and raw.size() > 0 else null), CONNECT_ONE_SHOT)
	var headers: = PackedStringArray(["apikey: " + KEY, "Content-Type: application/json"])
	if http.request((RELAY_URL if relayed else URL) + fn, headers, HTTPClient.METHOD_POST, JSON.stringify(body)) != OK:
		http.queue_free()
		done.call(false, null)




func log_run(w: World, victory: bool) -> void :


	if w.training:
		return
	_keep_history(w, victory)
	if not enabled() or not bool(Save.setting("share_stats", true)) or w.time < 30.0:
		return
	var p: = w.player
	var skills: = {}
	for id in p.skills:
		skills[id] = int(p.skills[id].level)
	var dmg: = {}
	for row in w.meter_sorted().slice(0, 8):
		dmg[str(row.tag)] = big(float(row.dmg))
	_call("log_run", {"p": {"player_id": player_id(), "version": str(Updater.version), "class_id": p.class_id, 
		"job": str(p.job2.get("id", "")), "stage_id": w.stage_id, "danger": w.danger, "speed": w.speed, "victory": victory, 
		"endless": w.endless, "time_s": roundi(w.time), "level": p.level, "kills": w.kills, "zeny": w.run_zeny, 
		"mvps": w.run_mvps, "gods": w.altars.taken, "skills": skills, "damage": dmg, 
		"taken": big(float(w.meter_stats.get("taken", 0.0)))}}, func(_ok, _d): pass)
	_call("log_run_metrics", {"p": metrics_of(w, victory, skills, dmg)}, func(_ok, _d): pass)




func _keep_history(w: World, victory: bool) -> void :
	if w.time < 30.0 or w.training or w.player == null:
		return
	var p: = w.player
	var top: = []
	for row in w.meter_sorted().slice(0, 3):
		top.append([str(row.tag), big(float(row.dmg))])
	Save.add_history({"at": int(Time.get_unix_time_from_system()), "class": p.class_id, "job": p.job_name(), "female": p.female(), 
		"stage": w.stage_id, "danger": w.danger, "victory": victory, "endless": w.endless, 
		"tower": w.tower.best if w.tower != null and is_instance_valid(w.tower) else 0, 
		"time": roundi(w.time), "level": p.level, "kills": w.kills, "zeny": w.run_zeny, "mvps": w.run_mvps, 
		"party": w.heroes.size(), "dps": big(float(w.meter_stats.get("total", 0.0)) / maxf(30.0, w.time)), 
		"best": big(float(w.meter_stats.get("best", 0.0))), "top": top})




func metrics_of(w: World, victory: bool, skills: Dictionary, dmg: Dictionary) -> Dictionary:
	var p: = w.player
	var ms: = w.meter_stats
	var gear: = {}
	for k in p.equipment.slots:
		var it = p.equipment.slots[k]
		if it != null:
			gear[k] = {"id": str(it.id), "refine": int(it.refine), "slots": int(it.slots), "cards": Array(it.cards)}
	var hits: = {}
	for row in w.meter_sorted().slice(0, 12):
		hits[str(row.tag)] = {"dmg": big(float(row.dmg)), "hits": int(row.get("hits", 0)), "max": big(float(row.get("max", 0.0))), 
			"crits": int(row.get("crits", 0)), "kills": int(row.get("kills", 0)), "boss": big(float(row.get("boss", 0.0)))}

	var mvp_dmg: = {}
	for id in w.meter_boss:
		var b: Dictionary = w.meter_boss[id]
		if bool(b.get("mvp", false)):
			for tag in b.tags:
				mvp_dmg[str(tag)] = big(float(mvp_dmg.get(str(tag), 0.0)) + float(b.tags[tag]))

	var mvp_tags: = mvp_dmg.keys()
	mvp_tags.sort_custom( func(x, y): return int(mvp_dmg[x]) > int(mvp_dmg[y]))
	for tag in mvp_tags.slice(10):
		mvp_dmg.erase(tag)
	var total: = float(ms.get("total", 0.0))
	return {"player_id": player_id(), "version": str(Updater.version), "class_id": p.class_id, 
		"job": str(p.job2.get("id", "")), "stage_id": w.stage_id, "danger": w.danger, "victory": victory, "time_s": roundi(w.time), 
		"max_hit": big(float(ms.get("best", 0.0))), "max_hit_by": str(ms.get("best_tag", "")), 
		"dps": big(total / maxf(30.0, w.time)), "total_dmg": big(total), "hits": int(ms.get("hits", 0)), "crits": int(ms.get("crits", 0)), 
		"taken": big(float(ms.get("taken", 0.0))), "healed": big(float(ms.get("healed", 0.0))), 
		"max_hp": roundi(p.max_hp), "hp": roundi(p.hp), "armor": snappedf(p.armor, 0.1), "dodge": snappedf(p.dodge, 0.001), 
		"perfect_dodge": snappedf(p.perfect_dodge, 0.001), "block": snappedf(p.block_chance(), 0.001), "crit": snappedf(p.crit, 0.001), 
		"crit_dmg": snappedf(p.crit_dmg, 0.01), "dmg_mult": snappedf(p.dmg_mult, 0.01), "move": snappedf(p.move_speed, 0.01), 
		"area": snappedf(p.area_mult, 0.01), "double_cast": snappedf(p.double_cast_chance(), 0.001), 
		"level": p.level, "kills": w.kills, "zeny": w.run_zeny, "mvps": w.run_mvps, "speed": w.speed, "endless": w.endless, 
		"reborn": p.reborn, "stats": p.stats, "skills": skills, "damage": dmg, "sources": hits, "gear": gear, 
		"cards": Array(p.cards), "dishes": p.dishes, "pet": p.pet_id, "gods": w.altars.taken, "pacts": p.pacts, "revives": p.revives, "tampered": p.tampered, "gear_edit": not honest(), 
		"karma": w.karma.value, "route": w.karma.path, "party": w.heroes.size(), "tower": w.tower.best if w.tower != null else 0, 
		"death_by": p.death_by, "mvp_dmg": mvp_dmg, 

		"x2_s": roundi(w.run_fast_s), 

		"oaths": w.oaths, "oath": w.oath_points(), 
		"mvp_time": roundi(float(w.raid.stats.get("time", 0.0))) if w.raid != null and is_instance_valid(w.raid) else 0}





const BIG_MAX: = 9e+18


static func big(v: float) -> int:
	return roundi(clampf(v, - BIG_MAX, BIG_MAX))




static func big_digits(v: float) -> String:
	if absf(v) < BIG_MAX:
		return str(roundi(v))
	return String.num(absf(v), 0)








const BIG_UNITS: = [[1.0000000000000001e+33, "Dc"], [9.999999999999999e+29, "No"], [1e+27, "Oc"], [1e+24, "Sp"], [1e+21, "Sx"], [1e+18, "Qi"], [1e+15, "Q"]]
const SCI_FROM: = 9.99995e+35





static func big_text(v: float) -> String:
	var a: = absf(v)
	if a < 1e+15:
		var s: = str(roundi(a))
		var out: = ""
		while s.length() > 3:
			out = "," + s.right(3) + out
			s = s.left(s.length() - 3)
		return ("-" if v < 0.0 else "") + s + out
	if a < SCI_FROM:

		for u in BIG_UNITS:
			if a >= float(u[0]) * 0.999995:
				return "%s%.2f%s" % ["-" if v < 0.0 else "", a / float(u[0]), u[1]]
	var e: = floori(log(absf(v)) / log(10.0))
	var m: = absf(v) / pow(10.0, e)
	if m >= 9.995:
		m /= 10.0
		e += 1
	return "%s%.2fe%d" % ["-" if v < 0.0 else "", m, e]



static func score(time_s: float, zeny: int, mvps: int, danger: int) -> int:
	return roundi((roundi(time_s) + zeny / 20.0 + mvps * 600) * (1.0 + 0.25 * (danger - 1)))
