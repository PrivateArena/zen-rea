class_name Trade
extends RefCounted








const Potential = preload("res://scripts/core/potential.gd")


const MAX_ENTRIES: = 12

var world: World

var partner: = 0
var partner_name: = ""

var state: = ""

var mine: = _empty()

var theirs: = _empty()
var my_ok: = false
var their_ok: = false

var their_eter: = false

var _asked_eter: = {}
var my_ready: = false
var their_ready: = false




var _v2: = false

var _gave: = false
var _got: = false





var _outbox: = {}

const OUT_TRIES: = 120



const OUT_KEY: = "trade_out"


const SEEN_KEY: = "trade_seen"
const SEEN_KEEP: = 100


var _last_partner: = 0

var _recent: = {}

var _seen: = {}











const TAKE_KEY: = "trade_take"

var checking: = false

var fail_note: = ""

signal changed

signal ended(why: String)


func _init(p_world: World) -> void :
	world = p_world
	world.net.roster_changed.connect(_check_partner)
	world.channel.changed.connect(_check_partner)


static func _empty() -> Dictionary:
	return {"items": [], "cards": {}, "mats": {}, "zeny": 0, "cos": [], "eter": {}}


func active() -> bool:
	return state != ""


func _reset() -> void :
	partner = 0
	partner_name = ""
	state = ""
	mine = _empty()
	theirs = _empty()
	my_ok = false
	their_ok = false
	their_eter = false
	my_ready = false
	their_ready = false
	_v2 = false
	_gave = false
	_got = false




func _send(id: int, msg: Array) -> void :
	if id < 0:
		world.channel.direct( - id, "trade", [msg])
	else:
		world.net.trade_send(id, msg)


func _present(id: int) -> bool:
	if id < 0:
		return world.channel.is_in() and world.channel.members.has( - id)
	return world.net.roster.any( func(m): return int(m.id) == id)



func name_of(id: int) -> String:
	if id < 0:
		return world.channel.name_of( - id)
	for m in world.net.roster:
		if int(m.id) == id:
			var n: = str(m.get("name", ""))
			return n if n != "" else tr(str(GameData.CLASSES.get(str(m["class"]), {}).get("name", "?")))
	return "?"



func can_trade() -> bool:
	return (world.net.mode != "" or world.channel.is_in()) and world.town != null and not world.running




func ask(id: int) -> void :
	if active() or not can_trade():
		return
	_reset()
	fail_note = ""
	partner = id
	_last_partner = id
	_recent[id] = true
	partner_name = name_of(id)
	state = "asking"

	_send(id, ["ask", {"eter": 1}])
	changed.emit()



func answer(id: int, yes: bool) -> void :
	if not yes:
		_send(id, ["no"])
		return
	_reset()
	fail_note = ""
	partner = id
	_last_partner = id
	_recent[id] = true
	partner_name = name_of(id)
	their_eter = bool(_asked_eter.get(id, false))
	_asked_eter.erase(id)
	state = "open"
	_send(id, ["yes", {"eter": 1}])
	changed.emit()


func cancel() -> void :
	if not active():
		return
	_send(partner, ["cancel"])
	_end("cancel")


func _end(why: String) -> void :
	_reset()
	ended.emit(why)


func _check_partner() -> void :
	if not active():
		return
	if not can_trade() or not _present(partner):
		_end("left")




func entries(side: Dictionary) -> int:
	return (side.items as Array).size() + (side.cards as Dictionary).size() + (side.mats as Dictionary).size()\
	+ (side.get("cos", []) as Array).size() + (side.get("eter", {}) as Dictionary).size()



func cards_left(id: String) -> int:
	return Save.card_copies(id) - int(mine.cards.get(id, 0))



func eternal_left(id: String) -> int:
	return Save.eternal_free(id) - int(mine.eter.get(id, 0))


func mats_left(id: String) -> int:
	return Save.material(id) - int(mine.mats.get(id, 0))


func add_item(uid: String) -> void :
	if my_ok or mine.items.has(uid) or Save.storage_item(uid).is_empty() or entries(mine) >= MAX_ENTRIES:
		return
	if GameData.bound_item(str(Save.storage_item(uid).get("id", ""))) or Equipment.is_locked(Save.storage_item(uid)):
		return
	mine.items.append(uid)
	_send_offer()


func add_card(id: String, n: = 1) -> void :
	n = mini(n, cards_left(id))
	if my_ok or n <= 0 or ( not mine.cards.has(id) and entries(mine) >= MAX_ENTRIES):
		return
	mine.cards[id] = int(mine.cards.get(id, 0)) + n
	_send_offer()



func add_eternal(id: String, n: = 1) -> void :
	n = mini(n, eternal_left(id))
	if my_ok or not their_eter or n <= 0 or ( not mine.eter.has(id) and entries(mine) >= MAX_ENTRIES):
		return
	mine.eter[id] = int(mine.eter.get(id, 0)) + n
	_send_offer()



func add_cos(id: String) -> void :
	if my_ok or (mine.cos as Array).has(id) or not Save.has_cosmetic(id) or entries(mine) >= MAX_ENTRIES:
		return
	mine.cos.append(id)
	_send_offer()


func add_mat(id: String, n: = 1) -> void :
	if GameData.MATERIALS.get(id, {}).get("bound", false):
		return
	n = mini(n, mats_left(id))
	if my_ok or n <= 0 or ( not mine.mats.has(id) and entries(mine) >= MAX_ENTRIES):
		return
	mine.mats[id] = int(mine.mats.get(id, 0)) + n
	_send_offer()




func take_back(kind: String, key: String, n: = -1) -> void :
	if my_ok:
		return
	if kind == "items" or kind == "cos":
		mine[kind].erase(key)
	else:
		var left: = 0 if n < 0 else int(mine[kind].get(key, 0)) - n
		if left > 0:
			mine[kind][key] = left
		else:
			mine[kind].erase(key)
	_send_offer()


func set_zeny(z: int) -> void :
	if my_ok:
		return
	z = clampi(z, 0, Save.zeny())
	if z != int(mine.zeny):
		mine.zeny = z
		_send_offer()


func _send_offer() -> void :
	var items: = []
	for uid in mine.items:
		var it: = Save.storage_item(str(uid))
		if not it.is_empty():
			items.append(_bare(it))
	_send(partner, ["offer", {"items": items, "cards": mine.cards.duplicate(), "mats": mine.mats.duplicate(), "zeny": int(mine.zeny), 
		"cos": (mine.cos as Array).duplicate(), "eter": (mine.eter as Dictionary).duplicate()}])
	changed.emit()



func press_ok() -> void :
	if state != "open" or my_ok:
		return
	my_ok = true
	_send(partner, ["ok"])
	changed.emit()



func blocked() -> String:

	var room: = Save.storage_cap() - Save.storage_used() + (mine.items as Array).filter( func(x): return Equipment.shelf_of(x) == "").size()
	var coming: = (theirs.items as Array).filter( func(x): return Equipment.shelf_of(x) == "").size()
	if coming > room:
		return tr("No te cabe en el Almacén Kafra: libera %d espacio(s).") % (coming - room)

	for c in theirs.get("cos", []):
		if Save.has_cosmetic(str(c)):
			return tr("Ya tienes %s: pídele que lo quite.") % tr(str(GameData.COSMETICS[str(c)].name))
	return ""



func press_ready() -> void :
	if state != "open" or not my_ok or not their_ok or my_ready or checking or blocked() != "" or not _still_mine():
		return
	my_ready = true
	_send(partner, ["ready", 2])
	changed.emit()
	if their_ready:
		_finish()





func net_in(from: int, msg: Array) -> void :
	if msg.is_empty():
		return
	var op: = str(msg[0])


	if op == "sent":
		if msg.size() < 3 or not msg[2] is Dictionary:
			return
		var nonce: = str(msg[1])
		var seen: = _seen.has(nonce) or (Save.data.get(SEEN_KEY, []) as Array).has(nonce)
		if not seen and from != partner and from != _last_partner and not _recent.has(from):


			_send(from, ["sent_no", nonce])
			return
		if not seen:
			_seen[nonce] = true
			var kept: Array = (Save.data.get(SEEN_KEY, []) as Array).duplicate()
			kept.append(nonce)
			Save.data[SEEN_KEY] = kept.slice(maxi(0, kept.size() - SEEN_KEEP))
			var got: = _clean(msg[2])
			_take_in(got)
			_ledger_take(nonce, _tids(got.items))
		_send(from, ["got", nonce])
		if active() and from == partner:
			_got = true
			if _gave:
				_end("done")
		return
	if op == "got":
		if msg.size() > 1:
			_delivered(str(msg[1]))
		return
	if op == "sent_no":
		if msg.size() > 1:
			_bounced(str(msg[1]))
		return
	if op == "ask":
		if active() or not can_trade() or world.menus.mode() != "town":
			_send(from, ["busy"])
		else:
			_asked_eter[from] = msg.size() > 1 and msg[1] is Dictionary and int(msg[1].get("eter", 0)) > 0
			world.menus.show_trade_ask(from, name_of(from))
		return
	if from != partner:
		return
	match op:
		"yes":
			if state == "asking":
				their_eter = msg.size() > 1 and msg[1] is Dictionary and int(msg[1].get("eter", 0)) > 0
				state = "open"
				changed.emit()
		"no":
			_end("refused")
		"busy":
			_end("busy")
		"cancel":
			_end("left")
		"offer":
			if state == "open" and not their_ok and msg.size() > 1 and msg[1] is Dictionary:
				theirs = _clean(msg[1])
				changed.emit()
		"ok":
			their_ok = true
			changed.emit()
		"ready":
			their_ready = true
			_v2 = msg.size() > 1 and int(msg[1]) >= 2
			changed.emit()
			if my_ready:
				_finish()



func _clean(o: Dictionary) -> Dictionary:
	var out: = _empty()
	for it in o.get("items", []):
		if it is Dictionary and GameData.ITEMS.has(str(it.get("id", ""))) and not GameData.bound_item(str(it.get("id", ""))) and (out.items as Array).size() < MAX_ENTRIES:
			out.items.append(it)
	var cards = o.get("cards", {})
	if cards is Dictionary:
		for c in cards:
			if GameData.CARDS.has(str(c)) and int(cards[c]) > 0:
				out.cards[str(c)] = int(cards[c])
	var mats = o.get("mats", {})
	if mats is Dictionary:
		for k in mats:
			if GameData.MATERIALS.has(str(k)) and int(mats[k]) > 0 and not GameData.MATERIALS[str(k)].get("bound", false):
				out.mats[str(k)] = int(mats[k])
	out.zeny = maxi(0, int(o.get("zeny", 0)))
	var eter = o.get("eter", {})
	if eter is Dictionary:
		for c in eter:
			if GameData.CARDS.has(str(c)) and int(eter[c]) > 0 and (out.eter as Dictionary).size() < MAX_ENTRIES:
				out.eter[str(c)] = mini(int(eter[c]), 999)
	var cos = o.get("cos", [])
	if cos is Array:
		for c in cos:
			if GameData.COSMETICS.has(str(c)) and not (out.cos as Array).has(str(c)) and (out.cos as Array).size() < MAX_ENTRIES:
				out.cos.append(str(c))
	return out








func _finish() -> void :

	if not _still_mine():
		_send(partner, ["cancel"])
		_end("failed")
		return
	var nonce: = "%d_%d" % [Time.get_ticks_usec(), randi()]
	if (mine.items as Array).is_empty() or checking or not ledger_on():
		if not checking:
			_finish_now(nonce)
		return


	var tids: = []
	var names: = []
	for uid in mine.items:
		var it: = Save.storage_item(str(uid))
		tids.append(tid_of(it))
		names.append(str(it.get("id", "")))
	checking = true
	fail_note = ""
	changed.emit()
	var me: = self
	var who: = partner
	world.board._call("trade_give", _ledger_body({"p_nonce": nonce, "p_tids": tids, "p_items": names}), func(ok: bool, data):
		me.checking = false
		var yes: bool = ok and data is Dictionary and bool(data.get("ok", false))
		if yes and me.active() and me.partner == who:
			me._finish_now(nonce)
			return
		if yes:

			me._ledger_take(nonce, tids)
			return
		var refused: Array = data.get("refused", []) if data is Dictionary and data.get("refused") is Array else []
		for it in Save.storage().duplicate():
			if it is Dictionary and refused.has(tid_of(it)):
				Save.remove_from_storage(str(it.get("uid", "")))
		me.fail_note = "dupe" if not refused.is_empty() else "unchecked"
		if me.active():
			me._send(me.partner, ["cancel"])
			me._end("failed"))



func _finish_now(nonce: String) -> void :
	var gone: = _snapshot()
	_give_out()
	if not _v2:
		_take_in(theirs)
		_end("done")
		return
	_gave = true
	var out: Dictionary = Save.data.get(OUT_KEY, {}) if Save.data.get(OUT_KEY) is Dictionary else {}
	out[nonce] = {"gone": gone, "to": partner_name, "at": Time.get_datetime_string_from_system(true)}
	Save.data[OUT_KEY] = out
	Save.mark_dirty()
	Save.flush()
	_outbox[nonce] = true
	_resend(partner, ["sent", nonce, gone], nonce, OUT_TRIES)
	if _got:
		_end("done")
	else:
		changed.emit()


		var me: = self
		world.get_tree().create_timer(15.0, true, false, true).timeout.connect( func():
			if me.active() and me._gave and not me._got:
				me._end("done"))




static func _bare(it: Dictionary) -> Dictionary:
	var c: = it.duplicate(true)
	c.erase("fav")
	c["tid"] = tid_of(it)
	return c





static func tid_of(it: Dictionary) -> String:
	var t: = str(it.get("tid", ""))
	if t != "":
		return t
	return "%s:%s" % [Leaderboard.player_id(), str(it.get("uid", ""))]




static func ledger_key() -> String:
	var k: = str(Save.setting("trade_key", ""))
	if k.length() < 32:
		k = Crypto.new().generate_random_bytes(16).hex_encode()
		Save.set_setting("trade_key", k)
	return k








static func ledger_on() -> bool:
	return Save._name == "profile" or GameData.has_meta("ledger_test")


static func _ledger_body(extra: Dictionary) -> Dictionary:
	var b: = {"p_player": Leaderboard.player_id(), "p_key": ledger_key()}
	b.merge(extra)
	return b




func _ledger_take(nonce: String, tids: Array) -> void :
	if tids.is_empty() or not ledger_on():
		return
	var pend: Dictionary = Save.data.get(TAKE_KEY, {}) if Save.data.get(TAKE_KEY) is Dictionary else {}
	pend[nonce] = tids
	Save.data[TAKE_KEY] = pend
	Save.mark_dirty()
	_take_call(world, nonce, tids)


static func _take_call(w: World, nonce: String, tids: Array) -> void :
	w.board._call("trade_take", _ledger_body({"p_nonce": nonce, "p_tids": tids}), func(ok: bool, data):
		if ok and data is Dictionary and bool(data.get("ok", false)):
			var pend = Save.data.get(TAKE_KEY)
			if pend is Dictionary:
				(pend as Dictionary).erase(nonce)
				Save.mark_dirty())






static func purge(w: World, done: = Callable()) -> void :
	if not ledger_on() or (Save._name != "profile" and not GameData.has_meta("ledger_test")):
		if done.is_valid():
			done.call(0)
		return
	var pend = Save.data.get(TAKE_KEY)
	if pend is Dictionary:
		for nonce in (pend as Dictionary).keys():
			_take_call(w, str(nonce), pend[nonce])
	var tids: = []
	for it in Save.storage():
		if it is Dictionary and str(it.get("uid", "")) != "":
			tids.append(tid_of(it))
	if tids.is_empty():
		if done.is_valid():
			done.call(0)
		return
	w.board._call("trade_check", _ledger_body({"p_tids": tids}), func(ok: bool, data):
		var n: = 0
		if ok and data is Dictionary and bool(data.get("ok", false)):
			var gone: Array = data.get("gone", []) if data.get("gone") is Array else []
			for it in Save.storage().duplicate():
				if it is Dictionary and gone.has(tid_of(it)):
					Save.remove_from_storage(str(it.get("uid", "")))
					n += 1
			if n > 0:
				print("TRADE ledger: %d piece(s) out of the storage (someone else's now)" % n)
				if w.hud != null and is_instance_valid(w.hud) and w.hud.visible:
					w.hud.alerts.warn(TranslationServer.translate("%d pieza(s) del almacén ya eran de otro jugador por un intercambio: se quitaron.") % n, 
						Color(1.0, 0.55, 0.4), "warning")
		if done.is_valid():
			done.call(n))



func _snapshot() -> Dictionary:
	var items: = []
	for uid in mine.items:
		var it: = Save.storage_item(str(uid))
		if not it.is_empty():
			items.append(_bare(it))
	return {"items": items, "cards": mine.cards.duplicate(), "mats": mine.mats.duplicate(), "zeny": int(mine.zeny), 
		"cos": (mine.cos as Array).duplicate(), "eter": (mine.eter as Dictionary).duplicate()}




func _resend(to: int, msg: Array, nonce: String, tries: int) -> void :
	if not _outbox.has(nonce) or tries <= 0:
		return
	if _present(to):
		_send(to, msg)
	else:
		tries += 1
	var me: = self
	world.get_tree().create_timer(1.5, true, false, true).timeout.connect( func(): me._resend(to, msg, nonce, tries - 1))



func _delivered(nonce: String) -> void :
	_outbox.erase(nonce)
	var out = Save.data.get(OUT_KEY)
	if out is Dictionary and (out as Dictionary).has(nonce):
		(out as Dictionary).erase(nonce)
		Save.mark_dirty()
		Save.flush()



func _bounced(nonce: String) -> void :
	var out = Save.data.get(OUT_KEY)
	if not (out is Dictionary) or not (out as Dictionary).has(nonce):
		return
	var back = out[nonce].get("gone") if out[nonce] is Dictionary else null
	_outbox.erase(nonce)
	(out as Dictionary).erase(nonce)
	if back is Dictionary:
		var again: = _clean(back)
		_take_in(again)

		_ledger_take(nonce, _tids(again.items))
		world.hud.announce(tr("Intercambio devuelto"), Color(1.0, 0.8, 0.4), tr("No llegó al otro jugador: lo que diste volvió a ti."))
	Save.mark_dirty()
	Save.flush()




func _give_out() -> void :
	var d: Dictionary = Save.data
	if not d.has("eternal"):
		d["eternal"] = {}
	for uid in mine.items:
		var it: = Save.storage_item(str(uid))
		for c in it.get("eternal", []):
			d.eternal[c] = maxi(0, Save.eternal(str(c)) - 1)
		Save.remove_from_storage(str(uid))
	for c in mine.cards:
		d.cards[c] = Save.card_copies(c) - int(mine.cards[c])
		if not Save.has_card(c):
			d.card_slots.erase(c)
	for k in mine.mats:
		Save.materials()[k] = Save.material(k) - int(mine.mats[k])
	d.zeny = Save.zeny() - int(mine.zeny)
	for c in mine.cos:
		Save.remove_cosmetic(str(c))
	for c in mine.eter:
		d.eternal[c] = maxi(0, Save.eternal(str(c)) - int(mine.eter[c]))
	Save.mark_dirty()
	Save.flush()



func _take_in(side: Dictionary) -> void :
	var d: Dictionary = Save.data
	if not d.has("eternal"):
		d["eternal"] = {}
	var n: = 0
	for src in side.items:
		n += 1
		var it: = {"id": str(src.id), "slots": int(src.get("slots", 0)), "extra_slots": int(src.get("extra_slots", 0)), 
			"refine": clampi(int(src.get("refine", 0)), 0, GameData.MAX_REFINE), "cards": [], 
			"uid": "%d_%d_t%d" % [Time.get_unix_time_from_system(), randi() % 100000, n]}

		var tid: = str(src.get("tid", ""))
		if tid.length() >= 4 and tid.length() <= 100:
			it["tid"] = tid


		var grade: = clampi(int(src.get("grade", 0)), 0, GameData.WEAPON_GRADES.size() - 1)
		if grade > 0:
			it["grade"] = grade


		var pity: = clampi(int(src.get("grade_pity", 0)), 0, GameData.GRADE_PITY_MAX)
		if pity > 0 and grade < GameData.WEAPON_GRADES.size() - 1:
			it["grade_pity"] = pity



		if GameData.PURPLE_TRAITS.has(str(src.get("trait", ""))):
			it["trait"] = str(src. trait )

		if int(src.get("trait_rolls", 0)) > 0:
			it["trait_rolls"] = clampi(int(src.trait_rolls), 0, 999)
		var pot: = Potential.clean(src.get("pot"))
		if not pot.is_empty():
			it["pot"] = pot
		var et: Array = (src.get("eternal", []) as Array).filter( func(c): return GameData.CARDS.has(str(c)))
		if not et.is_empty():
			it["eternal"] = et.map( func(c): return str(c))
			for c in it.eternal:
				d.eternal[c] = Save.eternal(c) + 1
		Save.storage().append(it)

		Save.mark_seen("items", str(it.id))
		if GameData.ITEMS.get(str(it.id), {}).get("unique", false):
			Save.mark_seen("uniques", str(it.id))
	for c in side.cards:
		d.cards[c] = Save.card_copies(c) + int(side.cards[c])
	for k in side.mats:
		Save.add_material(k, int(side.mats[k]))
	d.zeny = Save.zeny() + int(side.zeny)
	for c in side.get("cos", []):
		Save.add_cosmetic(str(c))
	for c in side.get("eter", {}):
		d.eternal[c] = Save.eternal(str(c)) + int(side.eter[c])
	Save.mark_dirty()
	Save.flush()
	world.play_sound("drop_purple", 0.0, -4.0)



static func _tids(items: Array) -> Array:
	var out: = []
	for it in items:
		if it is Dictionary and str(it.get("tid", "")) != "":
			out.append(str(it.tid))
	return out


func _still_mine() -> bool:
	for uid in mine.items:
		if Save.storage_item(str(uid)).is_empty():
			return false
	for c in mine.cards:
		if Save.card_copies(c) < int(mine.cards[c]):
			return false
	for k in mine.mats:
		if Save.material(k) < int(mine.mats[k]):
			return false
	for c in mine.cos:
		if not Save.has_cosmetic(str(c)):
			return false
	for c in mine.eter:
		if Save.eternal_free(str(c)) < int(mine.eter[c]):
			return false
	return Save.zeny() >= int(mine.zeny) and blocked() == ""
