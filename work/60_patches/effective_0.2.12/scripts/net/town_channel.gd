extends Node



















signal changed

signal logged

signal gear_in(id: int, data: Array)




const MAX_PLAYERS: = 12
const PORT: = 24690

const RATE: = 5.0

const FULL_EVERY: = 3.0

const MAX_PACKET: = 900
const LOG_MAX: = 80
const CHAT_GAP: = 0.7

const INVITE_TIME: = 60.0

const QUICK_WAIT: = 60.0
const PARTY_MAX: = 4
const FROM_CLIENT: = ["hi", "pos", "doing", "say", "to", "kick", "emo", "sync", "feat", "ho_ready"]
const FROM_HOST: = ["all", "add", "drop", "state", "doing", "said", "from", "kicked", "emoted", "aside", "bye", "feat_said", "ho_prep", "ho_go", "muted"]

const KICK_WINDOW: = 300

const DIRECT: = ["inv", "inv_no", "inv_busy", "trade", "eq_ask", "eq", "w"]

const RETRY: = 30.0



const RETRY_FAILED: = 6.0
const RETRY_MAX: = 120.0


const RETRY_ALL_FULL: = 30.0

const NEXT_MAX: = 12


const MAX_CHANNELS: = 100

const JOIN_TIMEOUT: = 20.0



const BAD_MS: = 300000
var _bad: = {}
var _trying: = 0

const QUICK_CODE_WAIT: = 30.0

var world: World

var state: = ""
var number: = 0
var error: = ""


var members: = {}

var lines: Array = []

var world_chat: Node

var invites: Array = []

var quick: = ""

var _api: = SceneMultiplayer.new()
var _host: = false
var _send_t: = 0.0
var _full_t: = 0.0
var _info_t: = 0.0
var _info_key: = ""
var _doing: = ""
var _last_pos: = []
var _pos_age: = 0.0
var _sent: = {}
var _said: = {}






const SPAM_LINES: = 5
const SPAM_WINDOW: = 8.0
const SPAM_REPEAT: = 3
const SPAM_REPEAT_WINDOW: = 30.0
const MUTE_TIME: = 60.0
const MUTE_MAX: = 600.0

var _spam: = {}
static var _my_spam: = {}

var _emoted: = {}



var _heard: = {}
var _owner_heard: = 0.0
var _presence_t: = 0.0
const STALE: = 7.0


const INFO_AGAIN: = 10.0
var _info_again_t: = INFO_AGAIN
const EMOTE_GAP: = 0.6
var _seq: = 0
var _pieces: = {}
var _sender: = 0
var _town: Town
var _lost_t: = 0.0

var _lan: = false


var _rejoin: = 0
var _auto_off: = false
var _retry_t: = 0.0

var _fails: = 0

var _all_full: = false

var _busy: = false
var _join_t: = 0.0
var _quick_t: = 0.0
var _room_addr: = ""


var _warmed: = false
var _list_cache: = []
var _list_at: = -100000


const LIST_FRESH_MS: = 180000

var _whisper_from: = 0

var _banned: = {}



var _keep_town: = false
var _keep_t: = 0.0
const KEEP_TOWN: = 6.0


const HANDOFF_TIME: = 10.0

const HANDOFF_READY_WAIT: = 3.0


const GHOST_TIME: = 8.0

var _since: = {}

var _ho_ready: = 0
var _handing: = false

var _ho_pending: MultiplayerPeer = null
var _ho_sock: = ""
var _ho_puid: = ""
var _ho_until: = 0.0

var _ho_quiet: = false


var _owner_away: = false

var _ghosts: = {}
var _ghost_until: = 0.0

var _lan_addr: = "127.0.0.1"
var _lan_port: = PORT


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

	world_chat = (load("res://scripts/net/world_chat.gd") as GDScript).new()
	world_chat.set("ch", self)
	world_chat.name = "WorldChat"
	add_child(world_chat)
	get_tree().set_multiplayer(_api, get_path())

	_api.server_relay = false
	world.net.roster_changed.connect(_follow_leader)
	world.net.roster_changed.connect(_sync_town)
	_api.peer_connected.connect(_on_peer_connected)
	_api.peer_disconnected.connect(_on_peer_disconnected)
	_api.connected_to_server.connect(_on_connected)
	_api.connection_failed.connect(_on_connection_failed)
	_api.server_disconnected.connect(_on_server_gone)




func reconnecting() -> bool:
	return state == "lost" or (_keep_town and state != "")


func is_in() -> bool:
	return state == "in" or state == "lost"


func my_id() -> int:
	if _via != 0:
		return _via_id
	return _api.get_unique_id() if _api.multiplayer_peer != null else 0


func _connected() -> bool:
	if _via != 0:
		return world.net.mode != ""
	return _api.multiplayer_peer != null and _api.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func log_line(kind: String, text: String, title: = "", sup: = "", id: = "") -> void :



	var t: = Time.get_time_dict_from_system()
	lines.append([kind, text, "%02d:%02d" % [int(t.hour), int(t.minute)], title, sup, id])
	if lines.size() > LOG_MAX:
		lines = lines.slice(lines.size() - LOG_MAX)
	logged.emit()


func name_of(id: int) -> String:
	return str(members.get(id, {}).get("name", "?"))



func title_of(id: int) -> String:
	var m: Dictionary = members.get(id, {})
	if m.is_empty() or world.titles == null:
		return ""
	return world.titles.shown_for(str(m.get("title", "")), str(m.get("tp", "")), str(m.get("tag", "")))



func support_of(id: int) -> String:
	var m: Dictionary = members.get(id, {})
	if m.is_empty() or world.titles == null or str(m.get("sup", "")) == "":
		return ""
	return world.titles.shown_for(str(m.sup), str(m.get("sp", "")), str(m.get("tag", "")))



func in_my_party(id: int) -> bool:
	var mine: = room_key()
	return mine != "" and str(members.get(id, {}).get("room", "")) == mine




func covers_party() -> bool:
	if not is_in():
		return false
	if world.net.mode == "":
		return true
	var me: = my_id()
	var here: = members.keys().filter( func(id): return int(id) != me and in_my_party(int(id))).size()
	return here >= world.net.roster.size() - 1



func room_key() -> String:
	if world.net.mode == "":
		return ""
	var eos = world.net.eos()
	if eos != null and str(eos.code) != "" and not _lan:
		return str(eos.code)
	return _room_addr






const NEW_CHANNEL_AT: = MAX_PLAYERS / 2




func list_async() -> Array:
	var eos = world.net.eos()
	var open: = {}
	if eos != null:
		open = await eos.town_list_async(MAX_CHANNELS)
	elif is_in():
		open = {number: members.size()}
	if is_in():
		open[number] = members.size()
	var nums: = []
	var crowded: = true
	for n in open:
		if int(open[n]) > 0 or (is_in() and int(n) == number):
			nums.append(int(n))
			crowded = crowded and int(open[n]) >= NEW_CHANNEL_AT
	if crowded:
		for n in range(1, MAX_CHANNELS + 1):
			if not nums.has(n):
				nums.append(n)
				break
	nums.sort()
	var out: = []
	for n in nums:
		out.append([n, int(open.get(n, 0))])
	return out



func join_async(n: int) -> bool:
	var eos = world.net.eos()
	if eos == null:
		error = tr("Los canales online necesitan Epic Online Services")
		return false
	if _busy or state == "joining":
		return false
	_busy = true
	_retry_t = RETRY
	var ok: = await _join(eos, clampi(n, 0, MAX_CHANNELS))
	_busy = false
	if not ok:
		_retry_t = _backoff(RETRY_ALL_FULL if _all_full else RETRY_FAILED)
	return ok



func _backoff(base: float) -> float:
	var t: = minf(base * pow(2.0, mini(_fails, 6)), RETRY_MAX)
	_fails += 1
	return t * randf_range(0.75, 1.25)


func _join(eos, n: int) -> bool:
	if state != "":
		await leave_async()
	error = ""
	state = "joining"
	_join_t = 0.0
	changed.emit()
	_all_full = false
	if n <= 0:
		var fresh: = not _list_cache.is_empty() and Time.get_ticks_msec() - _list_at < LIST_FRESH_MS
		n = _pick(_list_cache if fresh else await list_async())
		_list_cache = []
		if n < 0:

			_all_full = true
			error = tr("Todos los canales están llenos. Lo intento de nuevo en un rato.")
			state = ""
			changed.emit()
			return false
	if world.net.mode != "" and not _seek_skip and n > 0:

		_seek_start(n, SEEK_JOIN)
		while _seek_n > 0:
			await get_tree().create_timer(0.25, true, false, true).timeout
		if _via != 0:
			return true
		state = "joining"
	_seek_skip = false
	_trying = n

	var peer = null
	for i in NEXT_MAX:
		peer = await eos.town_join_async(n, MAX_PLAYERS)
		if peer != null or not eos.town_full or n >= MAX_CHANNELS:
			break
		n += 1
	if peer == null:
		error = str(eos.error)
		_all_full = eos.town_full and n >= MAX_CHANNELS
		state = ""
		changed.emit()
		return false
	_auto_off = false
	if not eos.town_owner_changed.is_connected(_on_owner_changed):
		eos.town_owner_changed.connect(_on_owner_changed)
		eos.town_lost.connect(_on_lobby_lost)
		eos.town_in_the_way.connect(_on_room_needs_link)
	number = n
	_start(peer, eos.town != null and eos.town.is_owner())
	return true



func join_enet(addr: String) -> bool:
	var peer: = ENetMultiplayerPeer.new()
	var ok: = peer.create_server(PORT, MAX_PLAYERS - 1) if addr == "" else peer.create_client(addr, PORT)
	if ok != OK:
		error = tr("No se pudo abrir la conexión")
		return false
	number = 1
	_lan = true
	_lan_port = PORT
	if addr != "":
		_lan_addr = addr
	_start(peer, addr == "")
	return true




func _login_paused() -> bool:
	var eos = world.net.eos()
	return eos != null and "login_paused" in eos and bool(eos.login_paused)




func _warm_up() -> void :


	if OS.has_feature("macos"):
		return
	print("TOWNCH [%d] warm up" % Time.get_ticks_msec())
	var eos = world.net.eos()
	if eos == null or not await eos.setup_async():
		return
	if state == "" and not _busy:
		_list_cache = await list_async()
		_list_at = Time.get_ticks_msec()




func _pick(list: Array) -> int:
	var best: = 0
	var best_n: = -1
	var now: = Time.get_ticks_msec()
	var taken: = {}
	for c in list:
		taken[int(c[0])] = true


		if int(_bad.get(int(c[0]), 0)) > now:
			continue
		if int(c[1]) < MAX_PLAYERS and int(c[1]) > best_n:
			best = int(c[0])
			best_n = int(c[1])
	if best > 0:
		return best

	for n in range(1, MAX_CHANNELS + 1):
		if not taken.has(n) and int(_bad.get(n, 0)) <= now:
			return n
	return -1 if list.size() >= MAX_CHANNELS else 1


func _start(peer: MultiplayerPeer, hosting: bool) -> void :
	_api.multiplayer_peer = peer
	_host = hosting
	members.clear()
	_sent.clear()
	_heard.clear()
	_owner_heard = 0.0
	_pieces.clear()
	_info_key = ""
	_info_t = 0.0
	_send_t = 0.0
	_town = null
	_doing = ""
	invites.clear()
	_since.clear()
	_ghosts.clear()
	_owner_away = false
	if _ho_pending != null:
		_ho_pending.close()
		_ho_pending = null
	state = "joining"
	_join_t = 0.0
	if hosting:
		_joined()
	changed.emit()


func _joined() -> void :
	print("TOWNCH [%d] in after %.1f s of P2P" % [Time.get_ticks_msec(), _join_t])
	state = "in"
	_lost_t = 0.0
	_fails = 0
	log_line("sys", tr("Entraste al Canal %d de Prontera.") % number)

	if world.net.is_host():
		world.net._send_roster()
	changed.emit()



func _leader_channel() -> int:
	var net: NetSync = world.net
	if not net.is_client() or net.roster.is_empty():
		return 0
	return int(net.roster[0].get("ch", 0))


func _follow_leader() -> void :
	var n: = _leader_channel()
	if n > 0 and not _busy and state != "joining" and ( not is_in() or n != number) and not _lan and not _auto_off and _in_prontera() and _seek_n == 0:
		join_async(n)



func leave_async(by_hand: = false) -> void :
	if by_hand:
		_auto_off = true
	if state == "":
		return

	if _host and not _handing:
		await _hand_off()
		if state == "":
			return
	_close()
	var eos = world.net.eos()
	if eos != null:
		await eos.town_leave_async()
	log_line("sys", tr("Saliste del canal."))
	changed.emit()


func _close() -> void :

	if _host:
		for id in _riders.keys():
			_send(int(id), "bye", [])
	_riders.clear()
	_rider_of.clear()
	_via = 0
	_via_id = 0
	if _api.multiplayer_peer != null:
		_api.multiplayer_peer.close()
	_api.multiplayer_peer = null
	state = ""
	_host = false
	members.clear()
	invites.clear()
	_rejoin = 0
	_keep_town = false
	_sync_town()

	if world.town != null and is_instance_valid(world.town):
		world.town.sync_party(world.net.roster, world.net.my_id())


func _on_owner_changed(mine: bool) -> void :
	if state == "":
		return
	var eos = world.net.eos()

	if _api.multiplayer_peer != null:
		_api.multiplayer_peer.close()
	_api.multiplayer_peer = null
	var peer = eos.town_peer() if eos != null else null
	if peer == null:
		_close()
		log_line("sys", tr("Se perdió la conexión con el canal."))
		return
	log_line("sys", tr("Reconectando con el canal..."))
	_keep_town = true
	_keep_t = 0.0
	_start(peer, mine)


func _on_lobby_lost() -> void :
	if state != "":
		_close()
		log_line("sys", tr("Se perdió la conexión con el canal."))
		changed.emit()


func _on_peer_connected(id: int) -> void :
	print("TOWNCH [%d] peer %d connected" % [Time.get_ticks_msec(), id])


func _on_peer_disconnected(id: int) -> void :
	if not _host or _riders.has(id):
		return
	_gone(id)



func _gone(id: int) -> void :
	members.erase(id)
	_since.erase(id)

	if _handing:
		return
	_said.erase(id)
	_spam.erase(id)
	for key in _pieces.keys():
		if str(key).begins_with("%d:" % id):
			_pieces.erase(key)
	for to in _peers():
		_send(to, "drop", [id])
	_sync_town()
	changed.emit()


func _on_connected() -> void :
	_info_key = ""

	if _ho_quiet:
		_ho_quiet = false
		return
	_joined()




func _on_server_gone() -> void :
	if state == "":
		return


	if _ho_pending != null:
		return
	state = "lost"
	_lost_t = 0.0
	members.clear()
	_keep_town = true
	_keep_t = 0.0
	changed.emit()


func _on_connection_failed() -> void :
	if state == "joining":
		_fail_join()
	else:
		_on_server_gone()



func _fail_join() -> void :
	if _trying > 0:
		_bad[_trying] = Time.get_ticks_msec() + BAD_MS
		print("TOWNCH ch%d unreachable: skipped for %d s" % [_trying, BAD_MS / 1000])
	_close()
	_retry_t = _backoff(RETRY_FAILED)
	error = tr("No se pudo conectar con el canal")
	var eos = world.net.eos()
	if eos != null and not _lan:
		eos.town_leave_async()
	changed.emit()


func _peers() -> Array:
	var out: Array = Array(_api.get_peers()) if _api.multiplayer_peer != null else []
	for id in _riders:
		if not out.has(id):
			out.append(id)
	return out




func _process(delta: float) -> void :
	_quick_tick()
	_ho_tick()

	if _handing:
		return
	if not _ghosts.is_empty() and Time.get_ticks_msec() / 1000.0 > _ghost_until:
		_ghosts.clear()
		_sync_town()
	if not _warmed and _joins_alone():
		_warmed = true
		_warm_up()

	_retry_t -= delta
	_via_tick(delta)
	if state == "" and not _busy and _retry_t <= 0.0 and _in_prontera() and _joins_alone() and _seek_n == 0 and not _login_paused():
		_retry_t = RETRY
		var n: = _leader_channel() if _leader_channel() > 0 else _rejoin
		_rejoin = 0
		print("TOWNCH [%d] in Prontera: joining" % Time.get_ticks_msec())
		join_async(n)
	if state == "":
		return




	if world.running or world.town == null or not is_instance_valid(world.town) or world.town.place != "prontera":
		if not _busy:
			_leave_for_run()
		return
	if state == "joining":
		_join_t += delta
	if state == "joining" and not _busy:
		if _join_t > JOIN_TIMEOUT:
			_fail_join()
		return
	if state == "lost":
		_lost_t += delta
		if _lost_t > 40.0:
			_close()
			var eos = world.net.eos()
			if eos != null:
				eos.town_leave_async()
			log_line("sys", tr("Se perdió la conexión con el canal."))
			changed.emit()
		return
	if state != "in":
		return
	if _keep_town:

		_keep_t += delta
		if _keep_t > KEEP_TOWN:
			_keep_town = false
			_sync_town()
	if world.town != _town:
		_town = world.town
		_sync_town()
	if _town == null or not is_instance_valid(_town) or _town.hero == null:
		return
	_info_t -= delta
	if _info_t <= 0.0:
		_info_t = 1.0
		_info_again_t -= 1.0
		if _info_again_t <= 0.0:
			_info_again_t = INFO_AGAIN
			_info_key = ""
		_send_info()
	_presence_t -= delta
	if _presence_t <= 0.0:
		_presence_t = 1.0
		_check_presence()
	var doing: = world.menus.mode()
	if doing != _doing:
		_doing = doing
		if _host:
			_set_doing(1, doing)
		else:
			_send(1, "doing", [doing])
	_send_t -= delta
	if _send_t > 0.0:
		return
	_send_t = 1.0 / RATE
	var h: RoVisual = _town.hero
	var me: = [snappedf(h.position.x, 0.06), snappedf(h.position.z, 0.06), h.dir, h.base_action]
	if _host:
		if members.has(1):
			members[1]["p"] = me
		_full_t -= 1.0 / RATE
		_broadcast_state(_full_t <= 0.0)
		if _full_t <= 0.0:
			_full_t = FULL_EVERY
	elif me != _last_pos or _pos_age >= 1.0:


		_last_pos = me
		_pos_age = 0.0
		_send_u(1, "pos", me)
	_pos_age += 1.0 / RATE
	var now: = Time.get_ticks_msec() / 1000.0
	var kept: = invites.filter( func(i): return float(i.until) > now)
	if kept.size() != invites.size():
		invites = kept
		changed.emit()



func _check_presence() -> void :
	var now: = Time.get_ticks_msec() / 1000.0
	if _host:
		for id in members.keys():
			if int(id) == 1:
				continue
			if not _heard.has(id):
				_heard[id] = now
			elif now - float(_heard[id]) > STALE:
				print("TOWNCH member %d silent %.0f s: gone" % [int(id), now - float(_heard[id])])
				_heard.erase(id)
				if _riders.has(id):
					_drop_rider(int(id))
				else:
					_on_peer_disconnected(int(id))
	elif members.has(1):
		if _owner_heard <= 0.0:
			_owner_heard = now
		elif now - _owner_heard > STALE:
			print("TOWNCH owner silent %.0f s: hidden" % (now - _owner_heard))
			members.erase(1)
			_sync_town()
			changed.emit()



func _on_sync() -> void :
	if _host and members.has(_sender):
		_send(_sender, "all", [members])









var _via: = 0
var _via_id: = 0

var _riders: = {}
var _rider_of: = {}

var _seek_n: = 0
var _seek_id: = 0
var _seek_until: = 0.0
var _seek_t: = 0.0
var _seek_from: = 0.0

var _seek_auto: = false
var _seek_skip: = false
const SEEK_ASIDE: = 45.0
const SEEK_JOIN: = 3.0
const VIA_SILENT: = 12.0




func _on_room_needs_link(code: = "") -> void :
	if state != "in" or _via != 0:
		return
	if _host:
		for id in members:
			var m: Dictionary = members[id]
			if int(id) != 1 and code != "" and str(m.get("room", "")) == code and bool(m.get("lead", false)):
				_send(int(id), "aside", [])
		return
	_step_aside()


func _on_aside() -> void :
	if not _host and state == "in" and _via == 0:
		_step_aside()



func _step_aside() -> void :
	var n: = number
	var id: = my_id()
	print("TOWNCH stepping aside for the room (ch%d, id %d)" % [n, id])
	_close()



	_seek_start(n, SEEK_ASIDE, id)
	_seek_auto = true
	var eos = world.net.eos()
	if eos != null and not _lan:
		await eos.town_leave_async()
	changed.emit()


func _seek_start(n: int, wait: float, id: = 0) -> void :
	_seek_n = n
	_seek_id = id if id > 1 else 1000000 + randi() % 1000000000
	_seek_until = Time.get_ticks_msec() / 1000.0 + wait
	_seek_from = Time.get_ticks_msec() / 1000.0
	_seek_t = 0.0
	_seek_auto = false


func _via_tick(delta: float) -> void :
	var net: NetSync = world.net
	var now: = Time.get_ticks_msec() / 1000.0
	if _seek_n > 0:

		if _seek_auto and net.mode == "" and now - _seek_from > 15.0:
			_seek_until = now
		if now > _seek_until:
			print("TOWNCH no owner of ch%d in the room: the usual way" % _seek_n)
			var n: = _seek_n
			_seek_n = 0
			if _seek_auto:
				_seek_auto = false
				_seek_skip = true
				_rejoin = n
				_retry_t = 0.0
		else:
			_seek_t -= delta
			if _seek_t <= 0.0:
				_seek_t = 1.0
				net.chan_hi(_seek_id, _seek_n)
	if _via != 0:
		var gone: = net.mode == "" or (net.is_host() and not net.peers.has(_via)) or (net.is_client() and _via != 1)
		if gone or (_owner_heard > 0.0 and now - _owner_heard > VIA_SILENT):
			_end_via()
	for id in _riders.keys():
		var r: = int(_riders[id])
		if net.mode == "" or (net.is_host() and not net.peers.has(r)) or (net.is_client() and r != 1) or not _host:
			_drop_rider(int(id))



func _end_via() -> void :
	print("TOWNCH channel off the room's link")
	var n: = number
	_close()
	_rejoin = n
	_retry_t = 2.0
	_seek_skip = false
	changed.emit()



func room_hi(sender: int, id: int, n: int) -> void :
	if not _host or state != "in" or n != number or id <= 1 or not _in_prontera():
		return
	if _rider_of.has(sender) and int(_rider_of[sender]) != id:
		_drop_rider(int(_rider_of[sender]))
	if members.size() >= MAX_PLAYERS and not members.has(id):
		return
	var again: = _riders.has(id)
	_riders[id] = sender
	_rider_of[sender] = id
	_heard[id] = Time.get_ticks_msec() / 1000.0
	world.net.chan_ok(sender, id, n)
	if not again:
		print("TOWNCH member %d rides the room (peer %d)" % [id, sender])

		if members.has(id):
			_send(id, "all", [members])



func room_ok(sender: int, id: int, n: int) -> void :
	if _seek_n == 0 or n != _seek_n or id != _seek_id or _via != 0:
		return
	_seek_n = 0
	_seek_auto = false
	_via = sender
	_via_id = id
	number = n
	_host = false
	members.clear()
	_sent.clear()
	_heard.clear()
	_pieces.clear()
	_owner_heard = Time.get_ticks_msec() / 1000.0
	_info_key = ""
	_info_t = 0.0
	_send_t = 0.0
	_town = null
	_doing = ""
	print("TOWNCH in ch%d through the room (peer %d)" % [n, sender])
	_joined()



func from_room(sender: int, data: PackedByteArray) -> void :
	if _via != 0 and sender == _via:
		_deliver(1, data)
	elif _host and _rider_of.has(sender):
		_deliver(int(_rider_of[sender]), data)


func _drop_rider(id: int) -> void :
	var r = _riders.get(id)
	_riders.erase(id)
	if r != null:
		_rider_of.erase(int(r))
	if _host:
		_gone(id)


func _on_bye() -> void :
	if _via != 0:
		_end_via()


func _leave_for_run() -> void :
	_busy = true
	var n: = number if not _lan else 0
	await leave_async()
	_rejoin = n

	_retry_t = 0.0
	_busy = false


func _in_prontera() -> bool:
	return world.town != null and is_instance_valid(world.town) and world.town.place == "prontera" and not world.running


func in_prontera() -> bool:
	return _in_prontera()




func _joins_alone() -> bool:
	return not _auto_off and not _lan and world.net.eos() != null and Save._name != "profile_test"



func _send_info() -> void :
	var cls: = _town.class_id


	var views: = Equipment.loadout_views(cls)
	views["shield"] = ""

	var info: = {"name": Save.char_name(cls), "class": cls, "look": Save.look(cls), "views": views, "room": room_key(), 
		"rb": Save.rebirth_looks(cls), "ra": RebirthAura.earned(cls), "lead": world.net.is_host(), "pet": Save.pet_skin(), 
		"mob": OS.has_feature("mobile") or OS.has_feature("web")}

	info["ft"] = Leaderboard.tag()

	if Town.hel_worn(cls):
		info["hw"] = true


	var hg: = int(Equipment.loadout_harmony(cls).level)
	if hg > 0:
		info["hg"] = hg
	if Save.rebirth_lv(cls) > 0:
		info["rl"] = Save.rebirth_lv(cls)


	var title: String = world.titles.active() if world.titles != null else ""
	if title != "":
		info["title"] = title
		info["tag"] = Leaderboard.tag()
		var pr: String = world.titles.proof(title)
		if pr != "":
			info["tp"] = pr


	var sup: String = world.titles.supporter() if world.titles != null else ""
	if sup != "":
		info["sup"] = sup
		info["sp"] = world.titles.proof(sup)
		info["sup_i"] = world.titles.support_icon_on()
		info["sup_a"] = world.titles.angel_aura_on()
		info["tag"] = Leaderboard.tag()


	if world.titles != null and world.titles.angel_aura_shown() and sup != "angeling":
		info["ap"] = world.titles.proof("angeling")
		info["tag"] = Leaderboard.tag()
	var key: = var_to_str(info)
	if key == _info_key:
		return
	_info_key = key
	if _host:
		_set_member(1, info)
	else:
		_send(1, "hi", [info])




func _set_member(id: int, info: Dictionary) -> void :
	var known: Dictionary = members.get(id, {})
	var fresh: = known.is_empty()
	var clean: = {"name": NameFilter.shown(NameFilter.clean(str(info.get("name", ""))).left(24)), "class": str(info.get("class", "swordsman")), 
		"look": _clean_look(info.get("look")), "views": _clean_views(info.get("views")), "room": str(info.get("room", "")).left(40)}
	if not GameData.CLASSES.has(clean["class"]):
		clean["class"] = "swordsman"
	clean["rb"] = _clean_rebirth(info.get("rb"))
	clean["ra"] = info.get("ra") is bool and bool(info.get("ra"))
	clean["lead"] = info.get("lead") is bool and bool(info.get("lead"))

	var pet = info.get("pet")
	clean["pet"] = str(pet) if pet is String and GameData.PETS.has(pet) and GameData.MONSTERS.has(pet) else ""


	var title = info.get("title")
	if title is String and GameData.TITLES.has(title):
		clean["title"] = title
		clean["tag"] = str(info.get("tag", "")).left(6)
		clean["tp"] = str(info.get("tp", "")).left(40)
	var sup = info.get("sup")
	if sup is String and sup in ["golden_poring", "angeling"]:
		clean["sup"] = sup
		clean["sp"] = str(info.get("sp", "")).left(40)
		clean["tag"] = str(info.get("tag", "")).left(6)
		clean["sup_i"] = not (info.get("sup_i") is bool) or bool(info.get("sup_i"))
		clean["sup_a"] = not (info.get("sup_a") is bool) or bool(info.get("sup_a"))
	if info.get("ap") is String and str(info.get("ap")) != "":
		clean["ap"] = str(info.get("ap")).left(40)
		clean["tag"] = str(info.get("tag", "")).left(6)
	clean["ft"] = str(info.get("ft", "")).left(5)
	clean["hw"] = info.get("hw") is bool and bool(info.get("hw"))
	clean["hg"] = clampi(int(info.get("hg")), 0, GameData.WEAPON_GRADES.size() - 1) if (info.get("hg") is int or info.get("hg") is float) else 0
	clean["rl"] = clampi(int(info.get("rl")), 0, GameData.REBIRTH_LV_MAX) if (info.get("rl") is int or info.get("rl") is float) else 0
	clean["mob"] = info.get("mob") is bool and bool(info.get("mob"))
	clean["p"] = known.get("p", [])
	clean["doing"] = known.get("doing", "")
	members[id] = clean
	if fresh:
		_since[id] = Time.get_ticks_msec()

		for g in _ghosts.values():
			if str(g.get("name", "")) == clean["name"] and g.has("age"):
				_since[id] -= int(g.age)
				break
	if fresh and id != 1:

		_send(id, "all", [members])
	for to in _peers():
		if to != id or not fresh:
			_send(to, "add", [id, clean])
	_sync_town()
	changed.emit()



static func _clean_rebirth(looks: Variant) -> Array:
	var out: = []
	if not looks is Array:
		return out
	var known: = GameData.REBIRTH_LV_LOOKS.map( func(l): return str(l.id))
	for l in looks:
		if l is String and known.has(l) and not out.has(l):
			out.append(l)
	return out



static func _clean_look(look: Variant) -> Dictionary:
	if not look is Dictionary:
		return {}
	var out: = {}
	for k in look:
		var v = look[k]
		if v is int or v is float:
			out[str(k)] = int(v)
		elif v is String or v is bool:
			out[str(k)] = v
		elif v is Array and (v as Array).all( func(e): return e is String or e is int):
			out[str(k)] = v
	return out


static func _clean_views(views: Variant) -> Dictionary:
	if not views is Dictionary:
		return {}
	var extras: = []
	if views.get("extras") is Array:
		for e in views.extras:
			if e is String and RoAssets.has_sprite(e):
				extras.append(e)
	var head: = str(views.get("head", ""))
	return {"head": head if RoAssets.has_sprite(head) else "", "extras": extras.slice(0, 6), "shield": ""}


func _on_hi(info: Dictionary) -> void :
	if members.size() >= MAX_PLAYERS and not members.has(_sender):
		return
	if _banned.has(NameFilter.shown(NameFilter.clean(str(info.get("name", ""))).left(24))):
		_do_kick(_sender, true)
		return
	_set_member(_sender, info)


func _on_pos(x: float, z: float, dir: int, action: int) -> void :
	if members.has(_sender):
		members[_sender]["p"] = [x, z, dir, action]


func _set_doing(id: int, doing: String) -> void :
	if not members.has(id):
		return
	members[id]["doing"] = doing.left(24)
	for to in _peers():
		if to != id:
			_send(to, "doing", [id, doing.left(24)])
	if _town != null and is_instance_valid(_town):
		_town.member_doing( - id, doing)


func _on_doing(a, b = null) -> void :
	if _host:
		_set_doing(_sender, str(a))
	elif members.has(int(a)):
		members[int(a)]["doing"] = str(b)
		if _town != null and is_instance_valid(_town):
			_town.member_doing( - int(a), str(b))




func _broadcast_state(full: bool) -> void :
	var ids: = PackedInt32Array()
	var out: = PackedFloat32Array()
	for id in members:
		var p: Array = members[id].get("p", [])
		if p.size() != 4:
			continue
		if not full and _sent.get(id, []) == p:
			continue
		_sent[id] = p.duplicate()
		ids.append(int(id))
		out.append_array([float(p[0]), float(p[1]), float(p[2]), float(p[3])])
	if ids.is_empty():
		return
	_place_all(ids, out)
	for to in _peers():
		_send_u(to, "state", [ids, out])


func _on_state(ids: PackedInt32Array, out: PackedFloat32Array) -> void :
	if out.size() != ids.size() * 4:
		return
	for i in ids.size():
		if members.has(ids[i]):
			members[ids[i]]["p"] = [out[i * 4], out[i * 4 + 1], int(out[i * 4 + 2]), int(out[i * 4 + 3])]
	_place_all(ids, out)


func _place_all(ids: PackedInt32Array, out: PackedFloat32Array) -> void :
	if _town == null or not is_instance_valid(_town):
		return
	var me: = my_id()
	var missing: = false
	for i in ids.size():
		if ids[i] != me and members.has(ids[i]) and not _town._party.has( - ids[i]):
			missing = true
	if missing:

		_sync_town()
	for i in ids.size():
		if ids[i] != me:
			_town.move_party_member( - ids[i], out[i * 4], out[i * 4 + 1], int(out[i * 4 + 2]), int(out[i * 4 + 3]), 
				str(members.get(ids[i], {}).get("doing", "")))


func _on_all(all: Dictionary) -> void :
	members = {}
	for id in all:
		if all[id] is Dictionary:
			members[int(id)] = all[id]
	_keep_town = false
	_sync_town()
	changed.emit()


func _on_add(id: int, info: Dictionary) -> void :
	var p = members.get(id, {}).get("p", [])
	members[id] = info
	members[id]["p"] = p
	_sync_town()
	changed.emit()


func _on_drop(id: int) -> void :
	members.erase(id)

	if id == 1:
		_owner_away = true
	_sync_town()
	changed.emit()



func _sync_town() -> void :
	if world.town == null or not is_instance_valid(world.town) or _keep_town:
		return
	var me: = my_id()
	var list: = []
	var names: = {}
	for id in members:
		if int(id) == me:
			continue
		list.append(_entry(int(id), members[id]))
		names[str(members[id].get("name", ""))] = true


	for gid in _ghosts:
		var g: Dictionary = _ghosts[gid]
		if int(gid) != me and not members.has(int(gid)) and not names.has(str(g.get("name", ""))):
			list.append(_entry(int(gid), g))
	world.town.sync_channel(list if is_in() else [])
	world.town.sync_party(world.net.roster, world.net.my_id())

	world.town.set_real_players(list.size() if is_in() else 0)



func _entry(id: int, m: Dictionary) -> Dictionary:
	var p: Array = m.get("p", [])
	return {"id": - id, "name": m.get("name", ""), "class": m.get("class", "swordsman"), "look": m.get("look", {}), 
		"views": m.get("views", {}), "party": in_my_party(id), "at": Vector3(float(p[0]), 0, float(p[1])) if p.size() == 4 else Vector3.INF, 
		"rb": _clean_rebirth(m.get("rb")), "ra": m.get("ra") is bool and bool(m.get("ra")), 
		"pet": str(m.get("pet", "")) if GameData.PETS.has(str(m.get("pet", ""))) else "", "title": title_of(id), "sup": support_of(id), 
		"sup_i": bool(m.get("sup_i", true)), "sup_a": bool(m.get("sup_a", true)), "hw": bool(m.get("hw", false)), "hg": int(m.get("hg", 0)), "rl": int(m.get("rl", 0)), 
		"ang": world.titles != null and str(m.get("ap", "")) != "" and world.titles.shown_for("angeling", str(m.ap), str(m.get("tag", ""))) == "angeling"}






func _epic():
	var eos = world.net.eos() if not _lan else null
	return eos.town_epic() if eos != null and eos.has_method("town_epic") else null








func _hand_off() -> bool:
	if not _host or state != "in" or _via != 0 or _handing:
		return false
	var ep = _epic()
	if ep == null and not _lan:
		return false
	var s: = _successor()
	if s == 0:
		return false
	var sock: String = str(ep.town_next_socket()) if ep != null else str(PORT + 1 if _lan_port == PORT else PORT)
	var user: String = str(ep.town_peer_user(_api.multiplayer_peer, s)) if ep != null else ""
	if ep != null and user == "":
		return false
	print("TOWNCH [%d] handoff to %d on %s" % [Time.get_ticks_msec(), s, sock])
	_handing = true
	_ho_ready = 0
	if ep != null:
		ep.town_handoff_to = user

	members.erase(1)
	for to in _peers():
		_send(to, "drop", [1])
	var ghosts: = members.duplicate(true)
	ghosts.erase(s)

	for id in ghosts:
		ghosts[id]["age"] = Time.get_ticks_msec() - int(_since.get(id, Time.get_ticks_msec()))
	_send(s, "ho_prep", [sock, ghosts, _banned.keys()])
	var t: = 0.0
	var told: = false
	var promoted: = ep == null
	while t < HANDOFF_TIME and state == "in":
		await get_tree().process_frame
		var dt: = get_process_delta_time()
		t += dt
		_relay_tick(dt)
		if not told and t > HANDOFF_READY_WAIT:


			break
		if not told and _ho_ready == s:
			told = true
			for to in _api.get_peers():
				if to != s and not _riders.has(to):
					_send(to, "ho_go", [sock, user, s])
			if ep != null:


				_promote(ep, user)
		if told and ep != null and not promoted:
			promoted = str(ep.town.owner_product_user_id) == user if ep.town != null else true

		if told and promoted and Array(_api.get_peers()).filter( func(id): return not _riders.has(id)).is_empty():
			break
	print("TOWNCH [%d] handoff %s after %.1f s" % [Time.get_ticks_msec(), "done" if told else "not taken", t])
	_handing = false
	return told


func _promote(ep, user: String) -> void :
	for i in 3:
		if await ep.town_promote_async(user):
			return
		await get_tree().create_timer(0.5, true, false, true).timeout



func _relay_tick(dt: float) -> void :
	_send_t -= dt
	if _send_t > 0.0:
		return
	_send_t = 1.0 / RATE
	_full_t -= 1.0 / RATE
	_broadcast_state(_full_t <= 0.0)
	if _full_t <= 0.0:
		_full_t = FULL_EVERY






func _successor() -> int:
	var best: = 0
	var best_key: = []
	var linked: = _api.get_peers()
	for id in members:
		var i: = int(id)
		if i == 1 or _riders.has(i) or not linked.has(i):
			continue
		var key: = [_room_linked(i), 1 if bool(members[id].get("mob", false)) else 0, int(_since.get(i, Time.get_ticks_msec()))]
		if best == 0 or _before(key, best_key):
			best = i
			best_key = key
	return best


static func _before(a: Array, b: Array) -> bool:
	for k in a.size():
		if int(a[k]) != int(b[k]):
			return int(a[k]) < int(b[k])
	return false




func _room_linked(id: int) -> int:
	var m: Dictionary = members.get(id, {})
	var room: = str(m.get("room", ""))
	if room == "":
		return 0
	var n: = 0
	for o in members:
		if int(o) == id or int(o) == 1:
			continue
		var om: Dictionary = members[o]
		if str(om.get("room", "")) == room and (bool(m.get("lead", false)) or bool(om.get("lead", false))):
			n += 1
	return n





func _on_ho_prep(sock = null, ghosts = null, banned = null) -> void :
	if _host or state != "in" or _via != 0 or not ghosts is Dictionary or not banned is Array:
		return
	var ep = _epic()
	var peer: MultiplayerPeer = null
	if ep != null:
		peer = ep.town_server_on(str(sock))
	elif _lan:
		var e: = ENetMultiplayerPeer.new()
		if e.create_server(int(sock), MAX_PLAYERS - 1) == OK:
			peer = e
	if peer == null:
		print("TOWNCH handoff: could not open %s" % str(sock))
		return



	var was_sock = null
	var was_to = null
	if ep != null:
		was_sock = ep.town_socket
		was_to = ep.town_handoff_to
		ep.town_socket = str(sock)
		ep.town_handoff_to = str(ep.town_my_id())
	_send(1, "ho_ready", [])

	await get_tree().create_timer(0.25, true, false, true).timeout
	if state != "in" or _host:
		peer.close()
		if ep != null:
			ep.town_socket = was_sock
			ep.town_handoff_to = was_to
		return
	print("TOWNCH [%d] handoff: this player owns the channel now (%s)" % [Time.get_ticks_msec(), str(sock)])
	var me: = my_id()
	var old: = _api.multiplayer_peer
	_api.multiplayer_peer = peer
	if old != null:
		old.close()
	_host = true
	_ghosts = {}
	for id in ghosts:
		if int(id) != me and ghosts[id] is Dictionary:
			_ghosts[int(id)] = ghosts[id]
	_ghost_until = Time.get_ticks_msec() / 1000.0 + GHOST_TIME
	for b in banned:
		_banned[str(b)] = true
	members.clear()
	_sent.clear()
	_heard.clear()
	_since.clear()
	_pieces.clear()
	_info_key = ""
	_info_t = 0.0
	if ep != null:
		ep.town_socket = str(sock)
		ep.town_handoff_to = str(ep.town_my_id())
	else:
		_lan_port = int(sock)
	_sync_town()
	changed.emit()



func _on_ho_ready() -> void :
	if _handing:
		_ho_ready = _sender




func _on_ho_go(sock = null, user = null, s_id = null) -> void :
	if _host or state != "in" or _via != 0 or _ho_pending != null:
		return
	var ep = _epic()



	var succ: Dictionary = members.get(int(s_id) if s_id != null else 0, {})
	var mine: = room_key()
	if ep != null and mine != "" and str(succ.get("room", "")) == mine and (bool(succ.get("lead", false)) or world.net.is_host()):
		print("TOWNCH handoff: the new owner is a room mate, over the room")
		ep.town_handoff_to = str(user)
		ep.town_socket = str(sock)
		_step_aside()
		return
	var peer: MultiplayerPeer = null
	if ep != null:
		ep.town_handoff_to = str(user)
		peer = ep.town_client_on(str(sock), str(user))
	elif _lan:
		var e: = ENetMultiplayerPeer.new()
		if e.create_client(_lan_addr, int(sock)) == OK:
			peer = e
	if peer == null:
		return
	_ho_pending = peer
	_ho_sock = str(sock)
	_ho_puid = str(user)
	_ho_until = Time.get_ticks_msec() / 1000.0 + HANDOFF_TIME



func _ho_tick() -> void :
	if _ho_pending == null:
		return
	_ho_pending.poll()
	var st: = _ho_pending.get_connection_status()
	if st == MultiplayerPeer.CONNECTION_CONNECTED:
		_ho_switch()
		return
	if st == MultiplayerPeer.CONNECTION_DISCONNECTED or Time.get_ticks_msec() / 1000.0 > _ho_until:
		print("TOWNCH handoff: could not link to the new owner")
		_ho_pending.close()
		_ho_pending = null
		var ep = _epic()
		if ep == null:
			if state == "in" and (_api.multiplayer_peer == null or _api.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED):
				_on_lobby_lost()
			return


		ep.town_handoff_to = ""
		ep.town_socket = _ho_sock

		ep.town_fallback_to = _ho_puid
		if ep.town != null and str(ep.town.owner_product_user_id) == _ho_puid:
			_on_owner_changed(false)


func _ho_switch() -> void :
	var peer: = _ho_pending
	_ho_pending = null
	var me: = my_id()

	_ghosts = {}
	for id in members:
		if int(id) != me and int(id) != 1:
			_ghosts[int(id)] = members[id]
	_ghost_until = Time.get_ticks_msec() / 1000.0 + GHOST_TIME
	var old: = _api.multiplayer_peer
	_ho_quiet = true
	_api.multiplayer_peer = peer
	if old != null:
		old.close()

	if not _api.get_peers().has(1):
		peer.peer_connected.emit(1)
	members.clear()
	_sent.clear()
	_pieces.clear()
	_owner_heard = 0.0
	_owner_away = false
	_info_key = ""
	_info_t = 0.0
	state = "in"
	var ep = _epic()
	if ep != null:
		ep.town_socket = _ho_sock
	else:
		_lan_port = int(_ho_sock)
	print("TOWNCH [%d] handoff: moved to the new owner" % Time.get_ticks_msec())
	_sync_town()
	changed.emit()






func say(line: String) -> bool:
	line = NameFilter.clean(line).left(120)
	if _self_muted(line.get_slice(" : ", 1) if line.contains(" : ") else line):
		return false
	log_line("all", line, world.titles.active() if world.titles != null else "", world.titles.supporter() if world.titles != null else "")
	if _host:
		_relay_said(1, line)
	else:
		_send(1, "say", [line])
	return true


func _on_say(line: String) -> void :
	var now: = Time.get_ticks_msec() / 1000.0
	if now - float(_said.get(_sender, -9.0)) < CHAT_GAP:
		return
	_said[_sender] = now

	var text: = line.get_slice(" : ", 1) if line.contains(" : ") else line
	if _spamming(_spam, _sender, text, now):
		return
	line = NameFilter.clean("%s : %s" % [name_of(_sender), text]).left(120)
	_show_said(_sender, line)
	_relay_said(_sender, line)




func _spamming(book: Dictionary, id: int, text: String, now: float) -> bool:
	var s: Dictionary = book.get(id, {"at": [], "last": "", "rep": 0, "rep_at": -99.0, "until": -1.0, "strikes": 0})
	book[id] = s
	if now < float(s.until):
		return true
	var at: Array = (s.at as Array).filter( func(t): return now - float(t) < SPAM_WINDOW)
	at.append(now)
	s.at = at
	var low: = text.strip_edges().to_lower()
	if low != "" and low == str(s.last) and now - float(s.rep_at) < SPAM_REPEAT_WINDOW:
		s.rep = int(s.rep) + 1
	else:
		s.rep = 1
		s.rep_at = now
	s.last = low
	if at.size() <= SPAM_LINES and int(s.rep) < SPAM_REPEAT:
		return false
	var secs: = minf(MUTE_MAX, MUTE_TIME * pow(2.0, int(s.strikes)))
	s.strikes = int(s.strikes) + 1
	s.until = now + secs
	s.at = []
	s.rep = 0
	if not is_same(book, _my_spam):
		if id == my_id():
			_on_muted(secs)
		else:
			_send(id, "muted", [secs])
	return true



func _self_muted(text: String) -> bool:
	var now: = Time.get_ticks_msec() / 1000.0
	var s: Dictionary = _my_spam.get(0, {})
	if not s.is_empty() and now < float(s.until):
		log_line("sys", tr("Chat silenciado por spam: %d s.") % ceili(float(s.until) - now))
		return true
	if _spamming(_my_spam, 0, text, now):
		log_line("sys", tr("Demasiados mensajes seguidos: chat silenciado %d s.") % ceili(float(_my_spam[0].until) - now))
		return true
	return false



func _on_muted(secs = 0.0) -> void :
	if not (secs is float or secs is int):
		return
	var now: = Time.get_ticks_msec() / 1000.0
	var s: Dictionary = _my_spam.get(0, {"at": [], "last": "", "rep": 0, "rep_at": -99.0, "until": -1.0, "strikes": 0})
	_my_spam[0] = s
	s.until = maxf(float(s.until), now + clampf(float(secs), 0.0, MUTE_MAX))
	log_line("sys", tr("Demasiados mensajes seguidos: chat silenciado %d s.") % ceili(float(s.until) - now))


func _relay_said(from: int, line: String) -> void :
	for to in _peers():
		if to != from:
			_send(to, "said", [from, line])


func _on_said(from: int, line: String) -> void :
	_show_said(from, NameFilter.clean(line).left(120))


func _show_said(from: int, line: String) -> void :
	log_line("all", line, title_of(from), support_of(from))
	if _town != null and is_instance_valid(_town):
		_town.party_chat( - from, line)








const FEATS: = ["refine", "socket", "grade", "gacha"]
const FEAT_GAP: = 2.0
var _feat_at: = {}


func feat(kind: String, item_id: String, value: int) -> void :
	if not kind in FEATS or not _feat_item(kind, item_id):
		return
	if not is_in():
		_show_feat(0, kind, item_id, value)
		return
	if _host:
		_show_feat(my_id(), kind, item_id, value)
		_relay_feat(my_id(), kind, item_id, value)
	else:
		_send(1, "feat", [kind, item_id, value])



func _feat_item(kind: String, item_id: String) -> bool:
	return GameData.COSMETICS.has(item_id) if kind == "gacha" else GameData.ITEMS.has(item_id)


func _on_feat(kind = null, item_id = null, value = null) -> void :
	if not kind is String or not item_id is String or not value is int:
		return
	if not kind in FEATS or not _feat_item(kind, item_id) or value < 1 or value > 20:
		return
	var now: = Time.get_ticks_msec() / 1000.0
	if now - float(_feat_at.get(_sender, -9.0)) < FEAT_GAP:
		return
	_feat_at[_sender] = now
	_show_feat(_sender, kind, item_id, value)
	_relay_feat(_sender, kind, item_id, value)


func _relay_feat(from: int, kind: String, item_id: String, value: int) -> void :
	for to in _peers():
		if to != from:
			_send(to, "feat_said", [from, kind, item_id, value])


func _on_feat_said(from = null, kind = null, item_id = null, value = null) -> void :
	if from is int and kind is String and kind in FEATS and item_id is String and _feat_item(kind, item_id) and value is int:
		_show_feat(from, kind, item_id, value)


func _show_feat(from: int, kind: String, item_id: String, value: int) -> void :
	var me: = from == 0 or (is_in() and from == my_id())
	var who: = Save.char_name(world.town.class_id if world.town != null else "") if me else name_of(from)
	if who.strip_edges() == "" or who == "?":
		return
	var named: Dictionary = GameData.COSMETICS[item_id] if kind == "gacha" else GameData.ITEMS[item_id]
	var item: = TranslationServer.translate(str(named.get("name", item_id)))
	var what: = TranslationServer.translate("¡abrió el segundo hueco de su %s!") % item
	if kind == "refine":
		what = TranslationServer.translate("¡refinó su %s a +%d!") % [item, value]
	elif kind == "grade":
		if value < 1 or value >= GameData.WEAPON_GRADES.size():
			return
		what = TranslationServer.translate("¡subió su %s a grado %s!") % [item, str(GameData.WEAPON_GRADES[value].name)]
	elif kind == "gacha":
		what = TranslationServer.translate("¡sacó %s, legendario, de la máquina gacha!") % item

	log_line("feat", "%s : ★ %s" % [who, what])
	_feat_toast("★ %s %s" % [who, what])




var _toasts: Array = []
func _feat_toast(text: String) -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var l: = UiKit.label(text, 18, Color(1.0, 0.85, 0.35), true)
	l.add_theme_color_override("font_outline_color", Color(0.2, 0.1, 0.0, 0.95))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(l)
	var view: = get_viewport().get_visible_rect().size
	l.size = Vector2(view.x, 30)
	_toasts = _toasts.filter( func(t): return is_instance_valid(t))
	while _toasts.size() >= 3:
		(_toasts.pop_front() as Node).queue_free()
	for t in _toasts:
		var lab: = (t as CanvasLayer).get_child(0) as Label
		lab.position.y -= 30.0
	_toasts.append(layer)
	l.position = Vector2(0, view.y * 0.3)
	l.modulate.a = 0.0
	var tw: = l.create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.25)
	tw.tween_interval(3.5)
	tw.tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(layer.queue_free)




func emote(idx: int) -> void :
	if not is_in():
		return
	if _host:
		_relay_emoted(1, idx)
	else:
		_send(1, "emo", [idx])


func _on_emo(idx = null) -> void :
	if not idx is int or idx < 0 or idx > 255:
		return
	var now: = Time.get_ticks_msec() / 1000.0
	if now - float(_emoted.get(_sender, -9.0)) < EMOTE_GAP:
		return
	_emoted[_sender] = now
	_show_emoted(_sender, idx)
	_relay_emoted(_sender, idx)


func _relay_emoted(from: int, idx: int) -> void :
	for to in _peers():
		if to != from:
			_send(to, "emoted", [from, idx])


func _on_emoted(from = null, idx = null) -> void :
	if from is int and idx is int and idx >= 0 and idx <= 255:
		_show_emoted(from, idx)


func _show_emoted(from: int, idx: int) -> void :
	if _town != null and is_instance_valid(_town):
		_town.party_emote( - from, idx)






func kick(id: int) -> void :
	if not Save.is_dev() or not is_in() or not members.has(id):
		return
	log_line("sys", tr("Expulsaste a %s del canal.") % name_of(id))
	if _host:
		_do_kick(id, true)
		return
	var t: = int(Time.get_unix_time_from_system())
	_send(1, "kick", [id, t, Save.dev_sign(_kick_msg(id, t))])


func _kick_msg(id: int, t: int) -> String:
	return "kick|%d|%d|%d" % [number, id, t]


func _on_kick(id, t, sig) -> void :
	if not (id is int and t is int and sig is String):
		return
	if absi(int(Time.get_unix_time_from_system()) - int(t)) > KICK_WINDOW or not Save.dev_verify(_kick_msg(id, t), sig):
		return
	_do_kick(int(id))




func _do_kick(id: int, quiet: = false) -> void :
	var who: = name_of(id)
	if who != "?" and who != "":
		_banned[who] = true
	if id == 1:
		_on_kicked()
		return
	if not quiet:
		log_line("sys", tr("%s fue expulsado del canal.") % who)
	_send(id, "kicked", [])
	get_tree().create_timer(1.5).timeout.connect( func():
		if _host and _riders.has(id):
			_drop_rider(id)
		elif _host and _api.multiplayer_peer != null and id in Array(_api.get_peers()):
			_api.multiplayer_peer.disconnect_peer(id))


func _on_kicked() -> void :
	log_line("sys", tr("Te expulsaron del canal."))
	leave_async(true)







func whisper(rest: String) -> String:
	var id: = _whisper_target(rest.strip_edges())
	if id == 0:
		log_line("sys", tr("No hay nadie con ese nombre en el canal."))
		return ""
	_whisper_to(id, rest.strip_edges().substr(name_of(id).length()))
	return name_of(id)



func reply(text: String) -> String:
	if not members.has(_whisper_from) or _whisper_from == my_id():
		log_line("sys", tr("Nadie te ha susurrado."))
		return ""
	_whisper_to(_whisper_from, text)
	return name_of(_whisper_from)


func _whisper_to(id: int, text: String) -> void :
	text = NameFilter.clean(text.strip_edges()).left(120)
	if text == "" or _self_muted(text):
		return
	direct(id, "w", [text])
	log_line("whisper", tr("(Para %s) : %s") % [name_of(id), text])


func _whisper_target(line: String) -> int:
	var low: = line.to_lower()
	var best: = 0
	var best_len: = 0
	for id in members:
		var n: = name_of(int(id)).to_lower()
		if int(id) != my_id() and n != "" and n.length() > best_len and (low == n or low.begins_with(n + " ")):
			best = int(id)
			best_len = n.length()
	return best




func direct(to: int, kind: String, args: Array) -> void :
	if not kind in DIRECT:
		return
	if _host:
		if to != 1:
			_send(to, "from", [1, kind, args])
	else:
		_send(1, "to", [to, kind, args])


func _on_to(to: int, kind: String, args: Array) -> void :
	if not kind in DIRECT:
		return

	if kind == "w":
		var now: = Time.get_ticks_msec() / 1000.0
		if now - float(_said.get(_sender, -9.0)) < CHAT_GAP:
			return
		_said[_sender] = now
		if _spamming(_spam, _sender, str(args[0]) if not args.is_empty() else "", now):
			return
	if to == 1:
		_on_direct(_sender, kind, args)
	elif members.has(to):
		_send(to, "from", [_sender, kind, args])


func _on_from(from: int, kind: String, args: Array) -> void :
	if kind in DIRECT:
		_on_direct(from, kind, args)


func _on_direct(from: int, kind: String, args: Array) -> void :
	match kind:
		"inv":
			if world.net.mode != "" or args.size() < 2:
				direct(from, "inv_busy", [])
				return
			invites = invites.filter( func(i): return int(i.from) != from)
			invites.append({"from": from, "name": name_of(from), "code": str(args[0]).left(40), 
				"until": Time.get_ticks_msec() / 1000.0 + INVITE_TIME})
			log_line("sys", tr("%s te invita a su party.") % name_of(from))
			world.play_sound("ui_click", 0.0, -4.0)
			changed.emit()
		"inv_no":
			log_line("sys", tr("%s rechazó tu invitación.") % name_of(from))
			if room_wait == "inviting":
				_wait("")
		"inv_busy":
			log_line("sys", tr("%s ya tiene party.") % name_of(from))
			if room_wait == "inviting":
				_wait("")
		"eq_ask":
			if _town != null and is_instance_valid(_town):
				var cls: String = _town.class_id
				var prof: = Player.profile_of(cls)


				var gear: Dictionary = prof.get("gear", {}).duplicate()
				var lk: = Save.look(cls)
				var shown: Dictionary = GameData.shown_job(cls, lk)
				var views: Dictionary = Equipment.loadout_views(cls)
				gear["_look"] = {"b": str(shown.body), "w": str(shown.weapon), "wf": str(shown.weapon_fx), "h": str(views.head), 
					"s": "", "x": views.extras, "cos": [], "g": str(lk.get("gender", "m")), "hr": int(lk.get("hair", 2)), 
					"hc": int(lk.get("hair_color", 0)), "c": int(lk.get("cloth", 0)), "a": RebirthAura.earned(cls), 
					"ach": roundi(Achievements.percent() * 100.0), "rlv": Save.rebirth_lv(cls)}
				direct(from, "eq", [[cls, gear, prof.get("cards", [])]])
		"eq":
			if args.size() == 1 and args[0] is Array and (args[0] as Array).size() == 3:
				gear_in.emit(from, args[0])
		"w":
			if args.size() == 1 and members.has(from):
				_whisper_from = from
				log_line("whisper", tr("(De %s) : %s") % [name_of(from), NameFilter.clean(str(args[0])).left(120)])
				world.play_sound("ui_click", 0.0, -4.0)
		"trade":
			if args.size() == 1 and args[0] is Array:
				world.menus._trade_setup()
				if world.menus.trade != null:
					world.menus.trade.net_in( - from, args[0])



func ask_gear(id: int) -> void :
	direct(id, "eq_ask", [])






func can_invite(id: int) -> bool:
	return is_in() and members.has(id) and not world.net.is_client() and not in_my_party(id)\
	and str(members[id].get("room", "")) == "" and world.net.roster.size() < PARTY_MAX





var room_wait: = ""
var room_wait_who: = ""
var _room_wait_at: = 0.0


func _wait(kind: String, who: = "") -> void :
	room_wait = kind
	room_wait_who = who
	_room_wait_at = Time.get_ticks_msec() / 1000.0



func room_waiting() -> String:
	var net: NetSync = world.net
	var waited: = Time.get_ticks_msec() / 1000.0 - _room_wait_at
	match room_wait:
		"inviting":
			if net.mode == "" or net.roster.size() > 1 or waited > INVITE_TIME:
				room_wait = ""
		"joining":
			if (net.mode == "client" and not net.roster.is_empty()) or waited > 45.0:
				room_wait = ""
		"opening":
			if waited > 20.0:
				room_wait = ""
	return room_wait


func invite_async(id: int) -> void :
	if not can_invite(id):
		return
	if world.net.mode == "":
		_wait("opening")
		if not await _open_room():
			_wait("")
			return
	direct(id, "inv", [room_key(), name_of(my_id())])
	_wait("inviting", name_of(id))
	log_line("sys", tr("Invitaste a %s a tu party.") % name_of(id))


func answer_invite(from: int, yes: bool) -> void :
	var inv: Dictionary = {}
	for i in invites:
		if int(i.from) == from:
			inv = i
	invites.erase(inv)
	changed.emit()
	if inv.is_empty():
		return
	if not yes:
		direct(from, "inv_no", [])
		return
	if world.net.mode != "":
		log_line("sys", tr("Ya estás en una party."))
		return
	_wait("joining", str(inv.name))
	if await _join_room(str(inv.code)):
		log_line("sys", tr("Te uniste a la party de %s.") % str(inv.name))
	else:
		_wait("")



func _open_room() -> bool:
	var net: NetSync = world.net
	var eos = net.eos() if not _lan else null
	if eos != null:
		var peer = await eos.host_async()
		if peer == null:
			log_line("sys", str(eos.error))
			return false
		net.host(0, peer)
		return true
	if not net.host():
		log_line("sys", tr("No se pudo abrir la sala"))
		return false
	_room_addr = "127.0.0.1:%d" % NetSync.PORT
	return true


func _join_room(code: String) -> bool:
	var net: NetSync = world.net
	var cls: = world.town.class_id if world.town != null else "swordsman"
	var eos = net.eos() if not _lan else null


	if code.contains(".") or eos == null:
		if not _lan:
			return false
		_room_addr = code
		return net.join(code.get_slice(":", 0), int(code.get_slice(":", 1)) if code.contains(":") else NetSync.PORT, cls)
	var peer = await eos.join_async(code)
	if peer == null:
		log_line("sys", str(eos.error))
		return false
	return net.join("", 0, cls, peer)





static func progress_score() -> int:
	var maps: = 0
	for sid in GameData.STAGES:
		if Save.is_stage_cleared(sid):
			maps += 1
	return maps * 100 + Save.max_danger()


func quick_start_async() -> bool:
	var eos = world.net.eos()
	if eos == null:
		error = tr("Buscar party necesita Epic Online Services")
		return false


	if quick == "done" and world.net.mode == "":
		await eos.quick_stop_async()
		quick = ""
	if quick != "" or world.net.mode != "":
		return false
	error = ""
	quick = "search"
	_quick_t = 0.0
	changed.emit()
	var shown: = Save.char_name(world.town.class_id) if world.town != null and is_instance_valid(world.town) else ""
	quick_vote_mine = ""
	if not await eos.quick_start_async(progress_score(), NameFilter.shown(NameFilter.clean(shown))):
		error = str(eos.error)
		quick = ""
		changed.emit()
		return false

	if quick != "search":
		eos.quick_stop_async()
		return false
	return true


func quick_stop() -> void :
	quick = ""
	var eos = world.net.eos()
	if eos != null:
		eos.quick_stop_async()
	changed.emit()



var quick_vote_mine: = ""

func quick_vote(vote: String) -> void :
	var eos = world.net.eos()
	if eos == null or quick != "search":
		return
	quick_vote_mine = vote
	eos.quick_vote_async(vote)
	changed.emit()


func quick_votes() -> Array:
	var eos = world.net.eos()
	return eos.quick_votes() if eos != null else []


func quick_count() -> int:
	var eos = world.net.eos()
	return eos.quick_count() if eos != null else 0


func quick_waited() -> float:
	var eos = world.net.eos()
	return eos.quick_waited() if eos != null else 0.0


func _quick_tick() -> void :
	if quick != "search":
		return
	var eos = world.net.eos()
	if eos == null or eos.quick == null:
		return

	if world.net.mode != "":
		quick_stop()
		return
	var lead: String = eos.quick_tick(QUICK_WAIT)
	if lead == "":
		return
	if eos.quick_is_me(lead):
		quick = "forming"
		_quick_lead()
	else:
		var code: String = eos.quick_code_of(lead)
		if code != "":
			quick = "forming"
			_quick_follow(code)
			return

		_quick_t += get_process_delta_time()
		if _quick_t > QUICK_CODE_WAIT:
			quick_stop()
			log_line("sys", tr("No se pudo formar la party. Prueba de nuevo."))




var quick_expect: = 0
var _quick_expect_at: = 0.0

func quick_incoming() -> int:
	var net: NetSync = world.net
	var connecting: = net.peers.size() - net.ready_peers().size() if net.is_host() else 0
	var expected: = 0
	if quick_expect > 0 and Time.get_ticks_msec() / 1000.0 - _quick_expect_at < 40.0:
		expected = maxi(0, quick_expect - (net.roster.size() - 1))
	return maxi(connecting, expected)


func _quick_lead() -> void :
	var eos = world.net.eos()
	quick_expect = maxi(0, eos.quick_count() - 1)
	_quick_expect_at = Time.get_ticks_msec() / 1000.0
	if not await _open_room():
		quick_stop()
		return
	await eos.quick_publish_async(str(eos.code))
	quick = "done"
	log_line("sys", tr("¡Party encontrada! Eres el líder: elige el mapa en el portal."))
	changed.emit()

	await get_tree().create_timer(20.0, true, false, true).timeout
	if quick == "done":
		eos.quick_stop_async()
		quick = ""


func _quick_follow(code: String) -> void :
	var eos = world.net.eos()
	var ok: = await _join_room(code)
	eos.quick_stop_async()
	quick = ""
	if ok:
		log_line("sys", tr("¡Party encontrada! El líder elige el mapa."))
	changed.emit()




func _send(id: int, kind: String, args: = []) -> void :
	if _via != 0 or _riders.has(id):
		world.net.chan_send(_via if _via != 0 else int(_riders[id]), var_to_bytes([kind, args]), true)
		return
	if not _connected():
		return
	var bytes: = var_to_bytes([kind, args])
	if bytes.size() <= MAX_PACKET:
		_m.rpc_id(id, bytes)
		return
	_seq += 1
	var n: = ceili(bytes.size() / float(MAX_PACKET))
	for i in n:
		_f.rpc_id(id, _seq, i, n, bytes.slice(i * MAX_PACKET, (i + 1) * MAX_PACKET))


func _send_u(id: int, kind: String, args: = []) -> void :
	if _via != 0 or _riders.has(id):
		world.net.chan_send(_via if _via != 0 else int(_riders[id]), var_to_bytes([kind, args]), false)
		return
	if not _connected():
		return
	var bytes: = var_to_bytes([kind, args])
	if bytes.size() > MAX_PACKET:
		_send(id, kind, args)
		return
	_u.rpc_id(id, bytes)


@rpc("any_peer", "reliable")
func _m(data: PackedByteArray) -> void :
	_deliver(_api.get_remote_sender_id(), data)


@rpc("any_peer", "reliable")
func _f(seq: int, i: int, n: int, chunk: PackedByteArray) -> void :
	var sender: = _api.get_remote_sender_id()
	var key: = "%d:%d" % [sender, seq]
	if n < 1 or n > 64 or i < 0 or i >= n:
		return
	var parts: Array = _pieces.get(key, [])
	if parts.size() != n:
		parts = []
		parts.resize(n)
	parts[i] = chunk
	_pieces[key] = parts
	if parts.any( func(c): return c == null):
		return
	_pieces.erase(key)
	var data: = PackedByteArray()
	for c in parts:
		data.append_array(c)
	_deliver(sender, data)


@rpc("any_peer", "unreliable")
func _u(data: PackedByteArray) -> void :
	_deliver(_api.get_remote_sender_id(), data)



func _deliver(sender: int, data: PackedByteArray) -> void :
	var msg = bytes_to_var(data)
	if not msg is Array or (msg as Array).size() != 2 or not msg[0] is String or not msg[1] is Array:
		return
	var kind: String = msg[0]
	if _host and not kind in FROM_CLIENT:
		return
	if not _host and (sender != 1 or not kind in FROM_HOST):
		return
	_sender = sender
	if _host:
		_heard[sender] = Time.get_ticks_msec() / 1000.0
	elif sender == 1:
		var back: = not members.has(1) and _owner_heard > 0.0 and not _owner_away
		_owner_heard = Time.get_ticks_msec() / 1000.0
		if back and state == "in":

			_send(1, "sync", [])
	callv("_on_" + kind, msg[1])
