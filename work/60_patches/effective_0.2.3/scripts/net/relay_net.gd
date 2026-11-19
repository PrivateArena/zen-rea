extends Node



















signal town_owner_changed(mine: bool)
signal town_lost
signal town_in_the_way(code: String)

signal leader_away(on: bool)


const CODE_LEN: = 6
const CODE_CHARS: = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const SEARCH_MAX: = 50


const QUICK_TICK_MS: = 2000

const QUICK_WAIT: = 60


var url: = ""

var epic: Node = null
var bridge: = false
var relay_town: = true

var relay_rooms: = false
var error: = ""
var town_full: = false
var logged_in: = false

var _code: = ""
var _room = null
var _town = null
var _town_conn = null
var _quick_conn = null
var _quick_state: = {}
var _quick_t0: = 0.0
var _quick_tick_at: = 0
var _http: HTTPRequest

const RelayConn: = preload("res://scripts/net/relay_conn.gd")
const RelayPeer: = preload("res://scripts/net/relay_peer.gd")
const BridgePeer: = preload("res://scripts/net/bridge_peer.gd")



class RelayTown:
	var conn

	func _init(c) -> void :
		conn = c

	func is_owner() -> bool:
		return conn.is_server()




var code: String:
	get:
		if _code != "":
			return _code
		return str(epic.code) if epic != null else ""

var town:
	get:
		if relay_town:
			return _town
		return epic.town if epic != null else null

var quick:
	get:
		if relay_town:
			return _quick_conn
		return epic.quick if epic != null else null



func setup(p_epic: Node, cfg: Dictionary) -> void :
	epic = p_epic
	url = str(cfg.get("url", "")).trim_suffix("/")
	bridge = bool(cfg.get("bridge", false))
	relay_town = epic == null or bool(cfg.get("town", false))
	relay_rooms = epic == null or bool(cfg.get("rooms", false))
	if epic != null:
		add_child(epic)
		epic.town_owner_changed.connect( func(mine: bool):
			if not relay_town:
				town_owner_changed.emit(mine))
		epic.town_lost.connect( func():
			if not relay_town:
				town_lost.emit())
		epic.town_in_the_way.connect( func(c: String): town_in_the_way.emit(c))
	_http = HTTPRequest.new()
	_http.timeout = 8.0
	_http.accept_gzip = not OS.has_feature("web")
	add_child(_http)


func _process(_delta: float) -> void :
	for c in [_room.conn if _room != null else null, _town_conn, _quick_conn]:
		if c != null:
			c.poll()




static func net_version() -> String:
	var parts: = str(Updater.version).split(".")
	return ".".join(parts.slice(0, 3))


func _query(extra: = {}) -> String:
	var q: = {"v": net_version(), "plat": OS.get_name()}
	q.merge(extra, true)
	var parts: = []
	for k in q:
		parts.append("%s=%s" % [k, str(q[k]).uri_encode()])
	return "?" + "&".join(parts)




func _tree() -> SceneTree:
	return Engine.get_main_loop() as SceneTree


func _http_base() -> String:
	return url.replace("wss://", "https://").replace("ws://", "http://")




func setup_async() -> bool:
	if epic != null and not relay_town:
		var ok: bool = await epic.setup_async()
		error = str(epic.error)
		logged_in = ok
		return ok
	if epic != null and not epic.logged_in:
		epic.setup_async()
	logged_in = url != ""
	return logged_in


func shutdown_platform() -> void :
	if epic != null:
		epic.shutdown_platform()




func host_async() -> MultiplayerPeer:
	if epic != null and not relay_rooms:
		if _room != null:
			_room.close()
			_room = null
		var peer: MultiplayerPeer = await epic.host_async()
		error = str(epic.error)
		if peer == null:
			return null
		_code = ""
		if bridge and url != "" and str(epic.code) != "":


			var view = await _open_room(str(epic.code), "host", BRIDGE_WAIT, false)
			if view != null:
				print("NET bridge open on the relay: %s" % epic.code)
				return BridgePeer.new(peer, view)
			print("NET bridge failed (%s): Epic only" % error)
			error = ""
		return peer
	await leave_async()
	for i in 3:
		var c: = ""
		for k in CODE_LEN:
			c += CODE_CHARS[randi() % CODE_CHARS.length()]
		var view = await _open_room(c, "host")
		if view != null:
			_code = c
			return view
		if _room_error != "taken":
			break
	return null


func join_async(p_code: String) -> MultiplayerPeer:
	var c: = p_code.strip_edges().to_upper()
	if epic != null and not relay_rooms and c.length() != CODE_LEN:
		var peer: MultiplayerPeer = await epic.join_async(c)
		error = str(epic.error)
		return peer
	await leave_async()
	var view = await _open_room(c, "guest")
	if view == null:
		return null
	_code = c
	return view


var _room_error: = ""


const BRIDGE_WAIT: = 4.0



func _open_room(c: String, role: String, wait: = 12.0, mig: = true):
	error = ""
	_room_error = ""
	if url == "":
		error = tr("No se pudo conectar con el servidor de grupos")
		return null
	var conn = RelayConn.new()
	var q: = {"role": role, "max": 4}
	if mig:
		q["mig"] = 1
	conn.open("%s/room/%s%s" % [url, c, _query(q)])
	if not await conn.wait_in(_tree(), wait):
		_room_error = str(conn.error)
		error = _error_text(conn)
		return null
	conn.news.connect(_on_room_news)
	var view = RelayPeer.new(conn, true)
	_room = view
	return view


func _error_text(conn) -> String:
	match str(conn.error):
		"none":
			return tr("No hay ninguna sala con ese código")
		"full":
			return tr("No se pudo entrar a la sala (¿está llena?)")
		"version":
			return tr("Esa sala es de otra versión del juego (%s). Actualicen los dos a la última.") % str(conn.error_version)
		"taken":
			return tr("No se pudo crear la sala. Prueba de nuevo.")
		"kicked":
			return tr("El líder te sacó de la sala")
	return tr("No se pudo conectar con el servidor de grupos")




func room_view(conn) -> MultiplayerPeer:
	var view = RelayPeer.new(conn, true)
	_room = view
	return view


func _on_room_news(m: Dictionary) -> void :
	if str(m.get("t", "")) == "away":
		leader_away.emit(bool(m.get("on", false)))


func leave_async(_hand_on: = false) -> void :
	var old = _room
	_room = null
	_code = ""
	if old != null:
		old.close()
	if epic != null:
		await epic.leave_async()




func town_list_async(max_channels: = 100) -> Dictionary:
	if not relay_town:
		var listed: Dictionary = await epic.town_list_async(max_channels)
		return listed
	if url == "":
		return {}
	var body = await _get_json("%s/towns/%s" % [_http_base(), net_version().uri_encode()])
	var out: = {}
	if body is Dictionary:
		for k in body:
			var n: = int(k)
			if n > 0 and n <= max_channels:
				out[n] = int(body[k])
	return out




func _get_json(u: String):
	for attempt in 2:
		if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
			_http.cancel_request()
		if attempt == 1:
			var tls: TLSOptions = Leaderboard.system_tls()
			if tls == null or OS.has_feature("web") or not u.begins_with("https:"):
				return null
			_http.set_tls_options(tls)
		if _http.request(u) != OK:
			continue
		var r: Array = await _http.request_completed
		if int(r[0]) == HTTPRequest.RESULT_SUCCESS and int(r[1]) == 200:
			return JSON.parse_string((r[3] as PackedByteArray).get_string_from_utf8())
		if int(r[0]) != HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return null
	return null


func town_join_async(n: int, max_players: int) -> MultiplayerPeer:
	town_full = false
	if not relay_town:
		var peer: MultiplayerPeer = await epic.town_join_async(n, max_players)
		town_full = bool(epic.town_full)
		error = str(epic.error)
		return peer
	if _town_conn != null:
		await town_leave_async()
	var conn = RelayConn.new()
	conn.open("%s/town/%s/%d%s" % [url, net_version().uri_encode(), n, _query({"max": max_players})])
	if not await conn.wait_in(_tree()):
		town_full = str(conn.error) == "full"
		error = tr("Ese canal está lleno") if town_full else tr("No se pudo conectar con el canal")
		return null
	_town_conn = conn
	_town = RelayTown.new(conn)
	conn.news.connect(_on_town_news.bind(conn))
	print("TOWNCH relay ch%d (owner=%s, %d in)" % [n, conn.is_server(), conn.members.size()])
	return town_peer()


func _on_town_news(m: Dictionary, conn) -> void :
	if conn != _town_conn:
		return
	match str(m.get("t", "")):
		"owner":
			town_owner_changed.emit(conn.is_server())
		"lost", "err":
			_town_conn = null
			_town = null
			town_lost.emit()




func town_peer() -> MultiplayerPeer:
	if not relay_town:
		return epic.town_peer()
	if _town_conn == null or _town_conn.state != "in":
		return null
	return RelayPeer.new(_town_conn, false)




func town_epic():
	return epic if epic != null and not relay_town else null


func town_leave_async() -> void :
	if not relay_town:
		await epic.town_leave_async()
		return
	var old = _town_conn
	_town_conn = null
	_town = null
	if old != null:
		old.close()




func quick_start_async(adv: int, shown_name: = "") -> bool:
	if not relay_town:
		var ok: bool = await epic.quick_start_async(adv, shown_name)
		error = str(epic.error)
		return ok
	if _quick_conn != null:
		await quick_stop_async()
	if url == "":
		error = tr("No se pudo conectar con el servidor de grupos")
		return false
	var conn = RelayConn.new()
	conn.open("%s/quick/%s%s" % [url, net_version().uri_encode(), 
		_query({"name": shown_name.left(24), "adv": adv, "wait": QUICK_WAIT})])

	var t0: = Time.get_ticks_msec()
	_quick_state = {}
	conn.news.connect( func(m: Dictionary):
		if str(m.get("t", "")) == "q":
			_quick_state = m
			conn.state = "in")
	while conn.state == "connecting" and Time.get_ticks_msec() - t0 < 12000:
		await _tree().process_frame
		conn.poll()
	if conn.state != "in":
		conn.close()
		error = tr("No se pudo buscar party. Prueba de nuevo.")
		return false
	_quick_conn = conn
	_quick_t0 = Time.get_ticks_msec() / 1000.0
	return true


func quick_count() -> int:
	if not relay_town:
		return epic.quick_count()
	return (_quick_state.get("members", []) as Array).size() if _quick_conn != null else 0


func quick_waited() -> float:
	if not relay_town:
		return epic.quick_waited()
	return Time.get_ticks_msec() / 1000.0 - _quick_t0


func quick_vote_async(vote: String) -> void :
	if not relay_town:
		await epic.quick_vote_async(vote)
		return
	if _quick_conn != null:
		_quick_conn.send_json({"t": "vote", "v": vote})


func quick_votes() -> Array:
	if not relay_town:
		return epic.quick_votes()
	var out: = []
	if _quick_conn == null:
		return out
	var me: = int(_quick_state.get("me", 0))
	for m in _quick_state.get("members", []):
		out.append([str(m.get("name", "")).left(24), str(m.get("go", "")), int(m.get("id", 0)) == me])
	return out



func quick_tick(wait: float) -> String:
	if not relay_town:
		return epic.quick_tick(wait)
	if _quick_conn == null:
		return ""
	var now: = Time.get_ticks_msec()
	if now - _quick_tick_at > QUICK_TICK_MS:
		_quick_tick_at = now
		_quick_conn.send_json({"t": "tick"})
	return str(_quick_state.get("lead", ""))


func quick_is_me(lead: String) -> bool:
	if not relay_town:
		return epic.quick_is_me(lead)
	return lead != "" and lead == str(int(_quick_state.get("me", 0)))


func quick_code_of(lead: String) -> String:
	if not relay_town:
		return epic.quick_code_of(lead)
	for m in _quick_state.get("members", []):
		if str(int(m.get("id", 0))) == lead:
			return str(m.get("code", ""))
	return ""


func quick_publish_async(room_code: String) -> void :
	if not relay_town:
		await epic.quick_publish_async(room_code)
		return
	if _quick_conn != null:
		_quick_conn.send_json({"t": "code", "code": room_code})


func quick_stop_async() -> void :
	if not relay_town:
		await epic.quick_stop_async()
		return
	var old = _quick_conn
	_quick_conn = null
	_quick_state = {}
	if old != null:
		old.close()
