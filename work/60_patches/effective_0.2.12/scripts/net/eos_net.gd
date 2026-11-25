extends Node





const SOCKET: = "midgard"
const BUCKET: = "midgard:coop"
const CODE_LEN: = 5
const CODE_CHARS: = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"



const TOWN_SOCKET: = "midgardtown"
const TOWN_BUCKET: = "midgard:town:"

const QUICK_BUCKET: = "midgard:quick:"
const SEARCH_MAX: = 50


signal town_owner_changed(mine: bool)

signal town_lost


signal town_in_the_way(code: String)

var logged_in: = false
var _platform_ok: = false






var login_paused: = false



static func keychain_os() -> bool:
	return OS.has_feature("macos")
var _busy: = false
var _leaving: = false
var _setting_up: = false
var lobby
var code: = ""

var error: = ""



func setup_async() -> bool:
	if logged_in:
		return true

	while _setting_up:
		await get_tree().create_timer(0.2, true, false, true).timeout
	if logged_in:
		return true
	_setting_up = true
	var t0: = Time.get_ticks_msec()
	var ok: = await _setup_once()
	print("TOWNCH [%d] epic login %d ms ok=%s" % [Time.get_ticks_msec(), Time.get_ticks_msec() - t0, ok])
	_setting_up = false
	return ok


func _setup_once() -> bool:


	HLobbies.presence_enabled = false
	var cfg: = ConfigFile.new()
	if cfg.load("res://eos/credentials.cfg") != OK:
		error = tr("Faltan las credenciales de Epic en esta versión")
		return false
	var creds: = HCredentials.new()
	for k in ["product_name", "product_id", "sandbox_id", "deployment_id", "client_id", "client_secret"]:
		creds.set(k, str(cfg.get_value("eos", k, "")))
	creds.product_version = str(ProjectSettings.get_setting("application/config/version", "1.0"))
	HPlatform.flags = EOS.Platform.PlatformFlags.DisableOverlay

	if not _platform_ok:
		if not await HPlatform.setup_eos_async(creds):
			error = tr("No se pudo iniciar Epic Online Services")
			return false
		_platform_ok = true


		EOS.Logging.set_log_level(EOS.Logging.LogCategory.P2P, EOS.Logging.LogLevel.Info)
		HPlatform.log_msg.connect( func(m):
			if "P2P" in str(m.category) or int(m.level) <= int(EOS.Logging.LogLevel.Warning):
				print("EOS %s" % str(m)))
	if not await _login_async():
		error = tr("No se pudo entrar a Epic Online Services")
		login_paused = keychain_os()
		return false
	logged_in = true
	login_paused = false


	if keychain_os() and IEOS.connect_interface_auth_expiration.is_connected(HAuth._on_connect_interface_auth_expiration):
		IEOS.connect_interface_auth_expiration.disconnect(HAuth._on_connect_interface_auth_expiration)
		IEOS.connect_interface_auth_expiration.connect(_on_auth_expiring)
	return true



func _on_auth_expiring(_data: Dictionary) -> void :
	if lobby != null or town != null:
		HAuth._connect_account_async()
	else:
		logged_in = false




func _login_async() -> bool:
	var dev: = EOS.Connect.CreateDeviceIdOptions.new()
	dev.device_model = "%s %s" % [OS.get_name(), OS.get_model_name()]
	EOS.Connect.ConnectInterface.create_device_id(dev)
	var made: Dictionary = await IEOS.connect_interface_create_device_id_callback



	if not EOS.is_success(made) and int(made.get("result_code", -1)) != EOS.Result.DuplicateNotAllowed:
		print("TOWNCH device id not saved: %s" % EOS.result_str(made))
	var opts: = EOS.Connect.LoginOptions.new()
	opts.credentials = EOS.Connect.Credentials.new()
	opts.credentials.type = EOS.ExternalCredentialType.DeviceidAccessToken
	opts.credentials.token = null
	opts.user_login_info = EOS.Connect.UserLoginInfo.new()
	var shown: = str(Save.look(str(Save.setting("last_class", "swordsman"))).get("name", "")).strip_edges().left(32)
	opts.user_login_info.display_name = shown if shown != "" else "Heroe"
	if not await HAuth.login_game_services_async(opts):
		return false


	await HAuth.login_game_services_async(opts)
	EOSGRuntime.local_product_user_id = HAuth.product_user_id
	return HAuth.product_user_id != ""



func host_async() -> MultiplayerPeer:
	if _busy:
		error = tr("Espera, la sala anterior aún se está cerrando...")
		return null
	_busy = true
	await _wait_leaving()
	var peer: = await _host_async()
	_busy = false
	return peer



func _wait_leaving() -> void :
	for i in 40:
		if not _leaving:
			return
		await get_tree().create_timer(0.25, true, false, true).timeout


func _host_async() -> MultiplayerPeer:
	if not await setup_async():
		return null

	if lobby != null:
		await leave_async()
	var o: = EOS.Lobby.CreateLobbyOptions.new()
	o.bucket_id = BUCKET
	o.max_lobby_members = 4
	o.permission_level = EOS.Lobby.LobbyPermissionLevel.PublicAdvertised
	o.local_user_id = HAuth.product_user_id
	o.presence_enabled = false


	o.disable_host_migration = false

	for i in 3:
		lobby = await HLobbies.create_lobby_async(o)
		if lobby != null:
			break
		await get_tree().create_timer(1.0, true, false, true).timeout
	if lobby == null:
		error = tr("No se pudo crear la sala (Epic no respondió). Prueba de nuevo.")
		return null
	_hook_room()
	code = ""
	for i in CODE_LEN:
		code += CODE_CHARS[randi() % CODE_CHARS.length()]
	lobby.add_attribute("CODE", code)

	var published: = false
	for i in 3:
		if await lobby.update_async():
			published = true
			break
		await get_tree().create_timer(0.8, true, false, true).timeout
	if not published:
		await leave_async()
		error = tr("No se pudo publicar la sala (Epic no respondió). Prueba de nuevo.")
		return null
	var peer: = EOSGMultiplayerPeer.new()
	if peer.create_server(SOCKET) != OK:
		error = tr("No se pudo abrir la conexión")
		return null
	_accept_late(peer)
	return peer







const ACCEPT_DELAY: = 0.5

func _accept_late(peer: EOSGMultiplayerPeer) -> void :
	peer.set_auto_accept_connection_requests(false)

	var ref: WeakRef = weakref(peer)
	peer.incoming_connection_request.connect( func(info: Dictionary):
		var who: = str(info.get("remote_user_id", ""))
		print("NET request from %s on %s" % [who, str(info.get("socket", ""))])
		get_tree().create_timer(ACCEPT_DELAY, true, false, true).timeout.connect( func():
			var p = ref.get_ref()
			if p != null and p.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
				p.accept_connection_request(who)))



func join_async(p_code: String) -> MultiplayerPeer:
	if _busy:
		error = tr("Espera, ya estoy buscando la sala...")
		return null
	_busy = true
	await _wait_leaving()
	var peer: = await _join_async(p_code)
	_busy = false
	return peer


func _join_async(p_code: String) -> MultiplayerPeer:
	if not await setup_async():
		return null
	if lobby != null:
		await leave_async()

	var found = null
	for i in 4:
		found = await HLobbies.search_by_attribute_async({"key": "CODE", "value": p_code.strip_edges().to_upper()})
		if found != null and not (found as Array).is_empty():
			break
		await get_tree().create_timer(1.5, true, false, true).timeout
	if found == null or (found as Array).is_empty():
		error = tr("No hay ninguna sala con ese código")
		return null
	lobby = await HLobbies.join_async(found[0])
	if lobby == null:
		error = tr("No se pudo entrar a la sala (¿está llena?)")
		return null
	_hook_room()
	code = p_code.to_upper()




	if town != null and (str(town.owner_product_user_id) == str(lobby.owner_product_user_id) or town.is_owner()):
		print("NET room leader linked through the channel: leaving it first")
		town_in_the_way.emit(code)
		await get_tree().create_timer(1.5, true, false, true).timeout

	room_socket = str(_value(lobby.get_attribute("SK"), SOCKET))
	var peer: = EOSGMultiplayerPeer.new()
	if peer.create_client(room_socket, lobby.owner_product_user_id) != OK:
		error = tr("No se pudo conectar con el líder")
		return null
	return peer






var room_socket: = SOCKET


var room_successor: = ""


func _hook_room() -> void :
	if lobby != null and not lobby.lobby_owner_changed.is_connected(_on_room_owner):
		lobby.lobby_owner_changed.connect(_on_room_owner)


func _on_room_owner() -> void :
	if lobby != null and lobby.is_owner() and room_successor != "" and room_successor != room_my_id():
		room_promote_async(room_successor)


func room_my_id() -> String:
	return str(HAuth.product_user_id)


func room_next_socket() -> String:
	return SOCKET + "b" if room_socket == SOCKET else SOCKET



func room_server_async(sock: String) -> MultiplayerPeer:
	var peer: = EOSGMultiplayerPeer.new()
	if peer.create_server(sock) != OK:
		return null
	_accept_late(peer)
	room_socket = sock


	if lobby != null and not lobby.is_owner():
		for i in 6:
			if lobby != null and lobby.is_owner():
				break
			await get_tree().create_timer(1.0, true, false, true).timeout
	if lobby != null and lobby.is_owner():
		lobby.add_attribute("SK", sock)
		await lobby.update_async()
	return peer





func room_forget() -> void :
	lobby = null



func room_client(sock: String, owner_id: String) -> MultiplayerPeer:
	var peer: = EOSGMultiplayerPeer.new()
	if peer.create_client(sock, owner_id) != OK:
		return null
	room_socket = sock
	return peer



func room_promote_async(user: String) -> bool:
	if lobby == null or not lobby.is_owner():
		return false
	var m = lobby.get_member_by_product_user_id(user)
	if m == null:
		return false
	return await m.promote_member_async()



func room_peer_user(peer: MultiplayerPeer, id: int) -> String:
	if peer == null or not peer.has_method("get_peer_user_id"):
		return ""
	return str(peer.call("get_peer_user_id", id))





func _notification(what: int) -> void :
	if what == NOTIFICATION_EXIT_TREE:
		shutdown_platform()





func shutdown_platform() -> void :
	if not _platform_ok:
		return
	_platform_ok = false
	logged_in = false


	var rt: = get_node_or_null("/root/EOSGRuntime")
	if rt != null:
		rt.set_process(false)
	EOS.Platform.PlatformInterface.release()
	EOS.Platform.PlatformInterface.shutdown()





func leave_async(hand_on: = false) -> void :
	if lobby == null:
		return
	if not hand_on:
		room_successor = ""

	var old = lobby
	lobby = null
	code = ""
	_leaving = true


	if old.is_owner() and (old.members.size() <= 1 or not hand_on):
		await old.destroy_async()
	else:
		await old.leave_async()
	_leaving = false





var town
var quick

var town_full: = false


var _quick_t0: = 0.0
var _quick_forming: = false
var _quick_adv: = 0
var _quick_name: = ""
var _quick_merge_at: = 0.0
var _quick_merging: = false
const QUICK_MERGE_EVERY: = 3.0





static func net_version() -> String:
	var parts: = str(Updater.version).split(".")
	return ".".join(parts.slice(0, 3))


func _town_bucket() -> String:
	return TOWN_BUCKET + net_version()


static func _value(attr: Dictionary, default: Variant = null) -> Variant:
	var v = attr.get("value", null)
	return default if v == null else v




static func town_page(n: int) -> int:
	return (n - 1) / SEARCH_MAX + 1





func town_list_async(max_channels: = 100) -> Dictionary:
	if not await setup_async():
		return {}
	HLobbies.max_search_results = SEARCH_MAX
	var out: = {}
	for pg in range(1, town_page(max_channels) + 1):
		var found = await HLobbies.search_by_attribute_async([
			{"key": EOS.Lobby.SEARCH_BUCKET_ID, "value": _town_bucket()}, {"key": "PG", "value": pg}])
		var any: = false
		for l in (found if found != null else []):
			var n: = int(_value(l.get_attribute("CH"), 0))
			if n > 0 and n <= max_channels:
				any = true
				out[n] = maxi(int(out.get(n, 0)), int(l.max_members) - int(l.available_slots))
		if not any:
			break
	return out




func town_join_async(n: int, max_players: int) -> MultiplayerPeer:
	town_full = false
	var t0: = Time.get_ticks_msec()
	if not await setup_async():
		return null
	print("TOWNCH [%d] join ch%d: setup %d ms" % [Time.get_ticks_msec(), n, Time.get_ticks_msec() - t0])
	if town != null:
		await town_leave_async()
	HLobbies.max_search_results = SEARCH_MAX
	var found = await HLobbies.search_by_attribute_async([
		{"key": EOS.Lobby.SEARCH_BUCKET_ID, "value": _town_bucket()}, {"key": "CH", "value": n}])
	print("TOWNCH search %d ms (%d found)" % [Time.get_ticks_msec() - t0, (found as Array).size() if found != null else -1])
	var lobby = null




	if found != null:
		found = (found as Array).duplicate()
		(found as Array).sort_custom( func(a, b): return str(a.lobby_id) < str(b.lobby_id))
	for l in (found if found != null else []):
		if int(l.available_slots) > 0:
			lobby = await HLobbies.join_async(l)
			if lobby != null:
				break
	if lobby == null and found != null and not (found as Array).is_empty():
		error = tr("Ese canal está lleno")
		town_full = true
		return null
	if lobby == null:
		var o: = EOS.Lobby.CreateLobbyOptions.new()
		o.bucket_id = _town_bucket()
		o.max_lobby_members = max_players
		o.permission_level = EOS.Lobby.LobbyPermissionLevel.PublicAdvertised
		o.local_user_id = HAuth.product_user_id
		o.presence_enabled = false

		o.disable_host_migration = false
		lobby = await HLobbies.create_lobby_async(o)
		if lobby == null:
			error = tr("No se pudo abrir el canal (Epic no respondió). Prueba de nuevo.")
			return null
		lobby.add_attribute("CH", n)
		lobby.add_attribute("PG", town_page(n))
		await lobby.update_async()


		var twins = await HLobbies.search_by_attribute_async([
			{"key": EOS.Lobby.SEARCH_BUCKET_ID, "value": _town_bucket()}, {"key": "CH", "value": n}])
		for l in (twins if twins != null else []):
			if str(l.lobby_id) != str(lobby.lobby_id) and str(l.lobby_id) < str(lobby.lobby_id) and int(l.available_slots) > 0:
				var other = await HLobbies.join_async(l)
				if other != null:
					await lobby.leave_async()
					lobby = other
					break
	print("TOWNCH lobby %d ms (owner=%s)" % [Time.get_ticks_msec() - t0, lobby.is_owner()])
	town = lobby
	town.lobby_owner_changed.connect(_on_town_owner)
	town.kicked_from_lobby.connect(_on_town_kicked)

	town_handoff_to = ""
	town_socket = TOWN_SOCKET if lobby.is_owner() else str(_value(lobby.get_attribute("SK"), TOWN_SOCKET))
	return town_peer()


func _on_town_owner() -> void :
	if town == null:
		return


	if town_handoff_to != "" and str(town.owner_product_user_id) == town_handoff_to:
		if town.is_owner():
			town_mark_socket_async()
		return


	if town_fallback_to != "" and str(town.owner_product_user_id) == town_fallback_to:
		town_fallback_to = ""
		town_owner_changed.emit(town.is_owner())
		return
	town_fallback_to = ""


	town_handoff_to = ""
	town_socket = TOWN_SOCKET
	if town.is_owner():
		town_mark_socket_async()
	town_owner_changed.emit(town.is_owner())


func _on_town_kicked() -> void :
	if town != null:
		town = null
		town_lost.emit()




func town_peer() -> MultiplayerPeer:
	if town == null:
		return null
	var peer: = EOSGMultiplayerPeer.new()
	if town.is_owner():
		if peer.create_server(town_socket) != OK:
			error = tr("No se pudo abrir la conexión")
			return null
		_accept_late(peer)
	elif peer.create_client(town_socket, town.owner_product_user_id) != OK:
		error = tr("No se pudo conectar con el canal")
		return null
	return peer


func town_leave_async() -> void :
	if town == null:
		return
	var old = town
	town = null
	town_socket = TOWN_SOCKET
	town_handoff_to = ""

	await old.leave_async()







var town_socket: = TOWN_SOCKET


var town_handoff_to: = ""


var town_fallback_to: = ""




func town_epic():
	return self


func town_next_socket() -> String:
	return TOWN_SOCKET + "b" if town_socket == TOWN_SOCKET else TOWN_SOCKET


func town_my_id() -> String:
	return str(HAuth.product_user_id)


func town_server_on(sock: String) -> MultiplayerPeer:
	var peer: = EOSGMultiplayerPeer.new()
	if peer.create_server(sock) != OK:
		return null
	_accept_late(peer)
	return peer


func town_client_on(sock: String, owner_id: String) -> MultiplayerPeer:
	var peer: = EOSGMultiplayerPeer.new()
	if peer.create_client(sock, owner_id) != OK:
		return null
	return peer



func town_peer_user(peer: MultiplayerPeer, id: int) -> String:
	if peer == null or not peer.has_method("get_peer_user_id"):
		return ""
	return str(peer.call("get_peer_user_id", id))



func town_promote_async(user: String) -> bool:
	if town == null or not town.is_owner():
		return false
	var m = town.get_member_by_product_user_id(user)
	if m == null:
		return false
	return await m.promote_member_async()



func town_mark_socket_async() -> void :
	if town == null or not town.is_owner():
		return
	town.add_attribute("SK", town_socket)
	await town.update_async()






func quick_start_async(adv: int, shown_name: = "") -> bool:
	if not await setup_async():
		return false
	if quick != null:
		await quick_stop_async()
	var bucket: = QUICK_BUCKET + net_version()
	var found = await HLobbies.search_by_attribute_async([
		{"key": EOS.Lobby.SEARCH_BUCKET_ID, "value": bucket}, {"key": "OPEN", "value": 1}])
	var lobby = null
	for l in (found if found != null else []):
		if int(l.available_slots) > 0:
			lobby = await HLobbies.join_async(l)
			if lobby != null:
				break
	if lobby == null:
		var o: = EOS.Lobby.CreateLobbyOptions.new()
		o.bucket_id = bucket
		o.max_lobby_members = 4
		o.permission_level = EOS.Lobby.LobbyPermissionLevel.PublicAdvertised
		o.local_user_id = HAuth.product_user_id
		o.presence_enabled = false
		o.disable_host_migration = false
		lobby = await HLobbies.create_lobby_async(o)
		if lobby == null:
			error = tr("No se pudo buscar party (Epic no respondió). Prueba de nuevo.")
			return false
		lobby.add_attribute("OPEN", 1)
	_quick_adv = adv
	_quick_name = shown_name.left(24)
	_quick_merge_at = Time.get_ticks_msec() / 1000.0 + QUICK_MERGE_EVERY
	lobby.add_current_member_attribute("ADV", adv)
	lobby.add_current_member_attribute("NAME", shown_name.left(24))
	lobby.add_current_member_attribute("GO", "")
	await lobby.update_async()
	quick = lobby
	_quick_t0 = Time.get_ticks_msec() / 1000.0
	_quick_forming = false
	return true



func quick_count() -> int:
	return quick.members.size() if quick != null else 0


func quick_waited() -> float:
	return Time.get_ticks_msec() / 1000.0 - _quick_t0




func quick_vote_async(vote: String) -> void :
	if quick == null:
		return
	quick.add_current_member_attribute("GO", vote)
	await quick.update_async()



func quick_votes() -> Array:
	var out: = []
	if quick == null:
		return out
	for m in quick.members:
		var shown: = str(_value(m.get_attribute("NAME"), "")).left(24)
		out.append([shown, str(_value(m.get_attribute("GO"), "")), str(m.product_user_id) == str(HAuth.product_user_id)])
	return out





func quick_tick(wait: float) -> String:
	if quick == null:
		return ""
	var lead: = str(_value(quick.get_attribute("LEAD"), ""))
	if lead != "":
		return lead
	var n: int = quick.members.size()
	var now: = Time.get_ticks_msec() / 1000.0
	if n == 1 and not _quick_merging and now >= _quick_merge_at:
		_quick_merge_at = now + QUICK_MERGE_EVERY
		_quick_merge_async()
	var yes: = 0
	var no: = 0
	for m in quick.members:
		var v: = str(_value(m.get_attribute("GO"), ""))
		if v == "yes":
			yes += 1
		elif v == "no":
			no += 1
	var go: = n >= 4 or (n >= 2 and yes == n) or (n >= 2 and quick_waited() >= wait and no * 2 <= n)
	if quick.is_owner() and not _quick_forming and go:
		_quick_forming = true
		var best = null
		var best_adv: = -1
		for m in quick.members:
			var adv: = int(_value(m.get_attribute("ADV"), 0))
			if adv > best_adv or (adv == best_adv and str(m.product_user_id) < str(best.product_user_id)):
				best = m
				best_adv = adv
		quick.add_attribute("OPEN", 0)
		quick.add_attribute("LEAD", str(best.product_user_id))
		quick.update_async()
	return ""



func _quick_merge_async() -> void :
	if quick == null:
		return
	_quick_merging = true
	var mine = quick
	var found = await HLobbies.search_by_attribute_async([
		{"key": EOS.Lobby.SEARCH_BUCKET_ID, "value": QUICK_BUCKET + net_version()}, {"key": "OPEN", "value": 1}])
	for l in (found if found != null else []):
		if quick != mine or quick == null or mine.members.size() > 1:
			break
		if str(l.lobby_id) == str(mine.lobby_id) or int(l.available_slots) <= 0:
			continue
		var theirs: = int(l.max_members) - int(l.available_slots)
		if theirs < 1 or (theirs == 1 and str(l.lobby_id) > str(mine.lobby_id)):
			continue
		var joined = await HLobbies.join_async(l)
		if joined == null:
			continue
		if quick != mine:

			await joined.leave_async()
			break
		joined.add_current_member_attribute("ADV", _quick_adv)
		joined.add_current_member_attribute("NAME", _quick_name)
		joined.add_current_member_attribute("GO", "")
		await joined.update_async()
		quick = joined
		print("NET quick: joined another queue")
		await mine.leave_async()
		break
	_quick_merging = false


func quick_is_me(lead: String) -> bool:
	return lead == HAuth.product_user_id



func quick_code_of(lead: String) -> String:
	if quick == null:
		return ""
	var m = quick.get_member_by_product_user_id(lead)
	return str(_value(m.get_attribute("CODE"), "")) if m != null else ""


func quick_publish_async(room_code: String) -> void :
	if quick == null:
		return
	quick.add_current_member_attribute("CODE", room_code)
	await quick.update_async()


func quick_stop_async() -> void :
	if quick == null:
		return
	var old = quick
	quick = null
	await old.leave_async()
