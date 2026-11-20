class_name NetSync
extends Node












signal peer_joined(id: int)

signal roster_changed

signal tower_changed

const PORT: = 24680


const SNAP_RATE: = 15.0
const MOVE_RATE: = 20.0
const TOWN_RATE: = 8.0

const POS_Q: = 16.0

const MAX_PACKET: = 900


const METER_BIG: = 4000

const MOBS_PER_PACKET: = 100

const FROM_CLIENT: = ["hello", "move", "pick_choice", "reroll", "banish", "corrupt_pick", "skill_cmd", "arrow", "zeny", "job_skill", "homun_set", "hypno_pick", "pick_job", "loot_pick", "town_pos", "town_event", "leave_run", "town_chat", "gear", 
	"pet_fetch", "tower_pick", "tower_bless", "tower_pw", "trade", "tower_spin", "tower_camp", "chan", "chan_hi", "chan_ok", "bye", "resync_ask", "auto_banish"]

const WELCOME_TIMEOUT: = 15.0
const FROM_HOST: = ["ask_hello", "welcome", "roster", "start", "changes", "snap_heroes", "snap_mobs", "fx", 
	"hero_state", "offer_choices", "offer_job", "loot_offer", "loot_result", "portal", "arena_in", "arena_out", 
	"run_end", "town_state", "town_event", "town_chat", "meter", "meter_th", "got", "raid", "announce", "karma", "kportal", "sky", "worn", "corrupt_ask", "place", "looks", "altar", "quest_st", "hypno_ask", "morroc", "tower_ask", "tower_cancel", "tower", "trade", "chan", "chan_hi", "chan_ok", "fest", "rejoin", "rejoin_wait", "succ", "hz", "resync", "resync_place"]

var world: World

var mode: = ""


var peers: = {}


var my_slot: = -1
var my_class: = ""
var roster: Array = []

var _snap_t: = 0.0
var _move_t: = 0.0
var _state_t: = 0.0
var _town_t: = 0.0
var _hello_t: = 0.0
var _meter_t: = 0.0
var _gear_t: = 0.0
var _gear_key: = ""
var _known_altars: = {}
var _quest_at: = Vector3.INF
var _quest_mark: = Vector3.INF
var _quest_label: = ""

var _emv_sent: = -2.0
var _quest_npc: Node3D

var _quest_prop_at: = Vector3.INF
var _quest_prop: Node3D
var _altars: = {}
var _next_nid: = 1
var _seq: = 0
var _pieces: = {}
var _sender: = 0
var _welcomed: = false
var _wait_t: = 0.0
var _in_run: = false

var _known_mobs: = {}
var _known_picks: = {}
var _events: Array = []


















const FX_BUDGET: = 40000
const FX_BUDGET_ALL: = 60000
const FX_BURST: = 0.2
var _fx_tokens: = 0.0
var _fx_tick_at: = 0


const MOBS_HALF_FROM: = 110
var _snap_half: = 0

var fx_shed: = 0

var _raid_events: Array = []
var _sent_state: = {}
var _asked: = {}


var _asked_at: = {}
const ASK_AGAIN_MS: = 3000

var mobs: = {}
var _mob_to: = {}






var succession: Array = []
var succ_port: = PORT
var lead_pid: = ""
var _succ_t: = 0.0
var _mig: = {}
var _host_port: = PORT


var _join_addr: = "127.0.0.1"


var _enet: = false
var _epic: = false

var _relay: = false


var _lost: = {}


const LOST_WINDOW_MS: = 10000



var _lead_left_slot: = -1
const MIG_PORT_STEP: = 2
var _dropped_test: = false
const MIG_JOIN_TIME: = 30.0
var picks: = {}
var _hero_to: = {}
var _loot_panel: LootPanel
var _loot: LootRoll

var offered: Array = []

var _starting: = false
var _held: Array = []










const RESYNC_AFTER_MS: = 3000
const RESYNC_EVERY_MS: = 8000
var _unknown: = {}
var _mob_seen: = {}
var _place_off_at: = 0
var _resync_at: = -100000

var _resync_peer: = {}


var chain_until: = 0
const CHAIN_WAIT_MS: = 3000

const PUPPET_SWING_MS: = 350


const ALLY_SHOTS_MAX: = 14



var tower_party: = {}


var _tower_pick: = {}
var _dbg_t: = 0.0





static func coop_preview() -> bool:
	return not OS.has_feature("editor") and FileAccess.file_exists(OS.get_executable_path().get_base_dir().path_join("coop_preview.txt"))


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_gone)


var _eos: Node











func eos() -> Node:
	if _eos == null:
		_eos = get_tree().root.get_node_or_null("EosNet")
		if _eos != null:
			_hook_eos()
	if _eos != null:
		return _eos
	var cfg: = relay_config()
	var url: = str(cfg.get("url", ""))
	var epic_ok: = ClassDB.class_exists("EOSGMultiplayerPeer") and get_node_or_null("/root/HAuth") != null
	if not epic_ok and url == "":
		return null
	var epic: Node = load("res://scripts/net/eos_net.gd").new() if epic_ok else null
	if url != "" and (epic == null or cfg.get("bridge", false) or cfg.get("town", false) or cfg.get("rooms", false)):
		_eos = load("res://scripts/net/relay_net.gd").new()
		_eos.setup(epic, cfg)
	else:
		_eos = epic
	_eos.name = "EosNet"
	_eos.process_mode = Node.PROCESS_MODE_ALWAYS


	var scene: = get_tree().current_scene
	if scene != null and not scene.is_node_ready():
		get_tree().root.add_child.call_deferred(_eos)
	else:
		get_tree().root.add_child(_eos)
	_hook_eos()
	return _eos


func _hook_eos() -> void :
	if _eos.has_signal("leader_away") and not _eos.leader_away.is_connected(_on_leader_away):
		_eos.leader_away.connect(_on_leader_away)




func _on_leader_away(on: bool) -> void :
	if not is_client():
		return
	var text: = tr("El líder no responde (¿escondió la pestaña del navegador?). La partida sigue cuando vuelva.") if on else tr("El líder volvió.")
	if world.channel != null:
		world.channel.log_line("sys", text)
	if world.running and world.hud != null:
		world.hud.announce(text, Color(1.0, 0.85, 0.3))






static func relay_config() -> Dictionary:
	var args: = OS.get_cmdline_user_args()
	for a in args:
		if a.begins_with("--relay="):
			var bridged: = "--relay-bridge" in args
			return {"url": a.trim_prefix("--relay="), "town": true, "rooms": not bridged, "bridge": bridged}
	var saved = Save.setting("relay_cfg", {})
	if not saved is Dictionary:
		return {}

	if OS.has_feature("web") and not bool(saved.get("web", true)):
		return {}
	return saved



func leave() -> void :
	_teardown()
	roster_changed.emit()




func _teardown() -> void :

	var hand_on: = is_host() and world.running and not _run_peers().is_empty()
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	mode = ""
	peers.clear()
	roster.clear()
	_welcomed = false
	_in_run = false
	_pieces.clear()
	_asked.clear()
	_sent_state.clear()
	tower_party.clear()
	_tower_pick.clear()

	if _banner != null and _banner.visible:
		_pause_banner(false)


		if not world.menus.is_open():
			world.get_tree().paused = false
	if world.town != null:
		world.town.clear_party()
	if _eos != null:
		_eos.leave_async(hand_on)


func _notification(what: int) -> void :

	if what == NOTIFICATION_WM_CLOSE_REQUEST:



		if is_client() and multiplayer.multiplayer_peer != null:
			send(1, "bye")
			multiplayer.multiplayer_peer.poll()
		if mode != "":
			_teardown()

		if _eos != null:
			_eos.town_leave_async()
			_eos.quick_stop_async()

		if _eos != null:
			_eos.shutdown_platform()



	if what == NOTIFICATION_EXIT_TREE and _eos != null and is_instance_valid(_eos):
		if multiplayer.multiplayer_peer != null:
			multiplayer.multiplayer_peer.close()
		_eos.leave_async()
		_eos.town_leave_async()
		_eos.quick_stop_async()


func _process(delta: float) -> void :
	if not _mig.is_empty():
		_mig_tick(delta)
	if mode == "":
		return

	if is_host() and world.running:
		host_tick(delta)
	if is_client() and not _welcomed and multiplayer.multiplayer_peer != null:


		_hello_t -= delta
		_wait_t += delta
		if _hello_t <= 0.0 and _connected():
			_send_hello()
		if _wait_t > WELCOME_TIMEOUT:
			_on_connection_failed()
			return
	if world.town != null and not world.running:
		_town_tick(delta)


func is_host() -> bool:
	return mode == "host"


func is_client() -> bool:
	return mode == "client"




func migrating() -> bool:
	return not _mig.is_empty()



func recording() -> bool:
	if mode != "host" or not world.running:
		return false


	var f: = Engine.get_process_frames()
	if f != _rec_frame:
		_rec_frame = f
		_rec_any = false
		for p in peers.values():
			if p.get("in_run", false):
				_rec_any = true
				break
	return _rec_any
var _rec_frame: = -1
var _rec_any: = false



func my_id() -> int:
	if is_host():
		return 1
	return multiplayer.get_unique_id() if _connected() else 0


func _connected() -> bool:
	return multiplayer.multiplayer_peer != null\
	and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED



func ready_peers() -> Array:
	return peers.keys().filter( func(id): return peers[id].get("ready", false))


func _run_peers() -> Array:
	return peers.keys().filter( func(id): return peers[id].get("in_run", false))






func send(id: int, kind: String, args: = []) -> void :
	if not _connected():
		return
	var bytes: = var_to_bytes([kind, args])
	if kind in ["hello", "welcome"]:
		print("NET send %s to %d: %d bytes" % [kind, id, bytes.size()])
	if bytes.size() <= MAX_PACKET:
		_m.rpc_id(id, bytes)
		return
	_seq += 1
	var n: = ceili(bytes.size() / float(MAX_PACKET))
	for i in n:
		_f.rpc_id(id, _seq, i, n, bytes.slice(i * MAX_PACKET, (i + 1) * MAX_PACKET))




func send_u(id: int, kind: String, args: = []) -> void :
	if not _connected():
		return
	var bytes: = var_to_bytes([kind, args])
	if bytes.size() > MAX_PACKET:
		send(id, kind, args)
		return
	_u.rpc_id(id, bytes)


@rpc("any_peer", "reliable")
func _m(data: PackedByteArray) -> void :
	_deliver(multiplayer.get_remote_sender_id(), data)


@rpc("any_peer", "reliable")
func _f(seq: int, i: int, n: int, chunk: PackedByteArray) -> void :
	var sender: = multiplayer.get_remote_sender_id()
	var key: = "%d:%d" % [sender, seq]
	if n < 1 or n > 256 or i < 0 or i >= n:
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
	_deliver(multiplayer.get_remote_sender_id(), data)



func _deliver(sender: int, data: PackedByteArray) -> void :
	var msg = bytes_to_var(data)
	if not msg is Array or (msg as Array).size() != 2 or not msg[0] is String or not msg[1] is Array:
		return
	var kind: String = msg[0]
	if kind in ["hello", "welcome"]:
		print("NET got %s from %d" % [kind, sender])
	if is_host() and not kind in FROM_CLIENT:
		return
	if is_client() and (sender != 1 or not kind in FROM_HOST):
		return
	if not is_host() and not is_client():
		return
	if _starting and kind != "start":
		_held.append(msg)
		return
	_sender = sender
	callv("_on_" + kind, msg[1])




func host(port: = PORT, peer: MultiplayerPeer = null) -> bool:
	if peer == null:
		var enet: = ENetMultiplayerPeer.new()
		if enet.create_server(port, 3) != OK:
			print("NET could not host on %d" % port)
			return false
		peer = enet
	_pieces.clear()
	multiplayer.multiplayer_peer = peer
	mode = "host"
	_enet = peer is ENetMultiplayerPeer
	_epic = peer.get_class() == "EOSGMultiplayerPeer"
	_relay = _is_relay(peer)
	_host_port = port
	print("NET hosting on %d" % port)
	roster_changed.emit()
	return true


func join(address: String, port: = PORT, class_id: = "swordsman", peer: MultiplayerPeer = null) -> bool:
	my_class = class_id
	if peer == null:
		var enet: = ENetMultiplayerPeer.new()
		if enet.create_client(address, port) != OK:
			print("NET could not join %s:%d" % [address, port])
			return false
		peer = enet
	_pieces.clear()
	multiplayer.multiplayer_peer = peer
	mode = "client"
	_enet = peer is ENetMultiplayerPeer
	_epic = peer.get_class() == "EOSGMultiplayerPeer"
	_relay = _is_relay(peer)
	if _enet:
		_join_addr = address
	_welcomed = false
	_hello_t = 0.0
	_wait_t = 0.0
	print("NET joining %s:%d as %s" % [address, port, class_id])
	return true


func _on_peer_connected(id: int) -> void :
	if not is_host():
		return
	print("NET peer %d connected" % id)
	_patient(id)
	if not peers.has(id):
		peers[id] = {"class": "swordsman", "name": "", "profile": {}, "ready": false}
	send(id, "ask_hello")


func _on_peer_disconnected(id: int) -> void :
	if not is_host() or not peers.has(id):
		return
	print("NET peer %d left" % id)


	if world.running and bool(peers[id].get("in_run", false)) and not peers[id].get("bye", false) and (_enet or _epic or _relay_mig()):
		var now: = Time.get_ticks_msec()
		_lost[id] = now
		for k in _lost.keys():
			if now - int(_lost[k]) > LOST_WINDOW_MS:
				_lost.erase(k)




		if _lost.size() >= 2 and _run_peers().all( func(pid): return pid == id or _lost.has(pid) or peers.get(pid, {}).get("bye", false)):
			_lost_party.call_deferred()
	var h = peers[id].get("hero")
	peers.erase(id)
	_rec_frame = -1
	_asked.erase(id)
	_sent_state.erase(id)
	for key in _pieces.keys():
		if str(key).begins_with("%d:" % id):
			_pieces.erase(key)
	if world.town != null:
		world.town.drop_party_member(id)
	_send_roster()
	if tower_party.has(id):
		tower_party.erase(id)
		tower_changed.emit()

	if h != null and is_instance_valid(h):
		_to_bot(h)



func _to_bot(h: Player) -> void :
	h.input = HeroInput.BotHero.new()

	h.set_meta("player_gone", true)
	h.set_choosing(false)




func _on_bye() -> void :
	if peers.has(_sender):
		peers[_sender]["bye"] = true



func _on_leave_run() -> void :
	var id: = _sender
	if not peers.has(id):
		return
	peers[id]["in_run"] = false
	_rec_frame = -1
	_asked.erase(id)
	_sent_state.erase(id)
	var h: = _remote_hero(id)


	send(id, "run_end", [false, _end_result(h)])
	peers[id].erase("hero")
	if h != null:

		h.set_meta("left_run", true)
		_to_bot(h)





func leave_run() -> void :
	if is_client() and _in_run:
		send(1, "leave_run")
		var t: = get_tree().create_timer(4.0, true, false, true)
		t.timeout.connect( func():
			if _in_run:
				_in_run = false
				world.running = false
				world.menus.show_class_select())


func _on_connection_failed() -> void :
	print("NET connection failed")
	if not _mig.is_empty():

		multiplayer.multiplayer_peer = null
		return
	var was: = is_client()
	_teardown()
	roster_changed.emit()
	if was and not world.running:
		world.menus.show_npc_line(tr("Lydia"), "npc_party", tr("No se pudo conectar con la sala. Revisa el código y prueba de nuevo."))


func _on_connected() -> void :
	print("NET connected as %d" % multiplayer.get_unique_id())
	_patient(1)
	_send_hello()




func _patient(id: int) -> void :
	var enet: = multiplayer.multiplayer_peer as ENetMultiplayerPeer
	if enet == null:
		return
	var p: = enet.get_peer(id)
	if p != null:
		p.set_timeout(64, 20000, 40000)


func _send_hello() -> void :
	_hello_t = 2.0
	var name: = str(Save.look(my_class).get("name", "")).strip_edges()
	if name != "":
		name = Save.char_name(my_class)
	var prof: = Player.profile_of(my_class)


	prof["pid"] = my_pid()


	prof["rk"] = my_rejoin_key()


	if not _mig.is_empty() and world.player != null and world.running:
		var snap: = RunSave.hero_snapshot(world, world.player)




		snap["xp_gained"] = world.player.xp_gained
		snap["purse"] = 0 if bool(_mig.get("was_lead", false)) else world.run_zeny
		prof["mig"] = snap
	send(1, "hello", [my_class, name if name != "" else tr(GameData.CLASSES[my_class].name), prof])



func update_class(class_id: String) -> void :
	my_class = class_id
	if is_client() and _connected():
		_send_hello()
	elif is_host():
		_send_roster()


func _on_server_gone() -> void :
	print("NET host gone")

	if _mig.has("relay") and _mig.get("relay") == null and _relay_mig():
		_migrate_relay()
		return
	if not _mig.is_empty():

		multiplayer.multiplayer_peer = null
		return
	if world.running and _in_run and _can_migrate():
		_migrate()
		return
	var was_running: = world.running and _in_run
	_teardown()
	roster_changed.emit()
	if was_running:
		world.running = false
		world.get_tree().paused = false
		world.menus.show_end(false, world.net_end_result())
	elif world.town != null:
		world.menus.show_npc_line(tr("Lydia"), "npc_party", tr("El líder cerró la sala. Puedes crear otra o unirte a una nueva."))
	_quit_if_test()






func _send_succession(leaving: = false) -> void :
	if not _enet and not _epic and not _relay:
		return
	var ep = _epic_node()
	var list: = []
	for id in _run_peers():
		var h = peers[id].get("hero")
		if h != null and is_instance_valid(h):

			list.append({"slot": int(h.slot), "pid": str(h.get_meta("net_pid", "")), 
				"user": ep.room_peer_user(multiplayer.multiplayer_peer, id) if _epic and ep != null else ""})
	list.sort_custom( func(a, b): return int(a.slot) < int(b.slot))
	succession = list
	succ_port = _host_port + MIG_PORT_STEP
	lead_pid = my_pid()

	var left_slot: = int(world.player.slot) if leaving and world.player != null else -1
	for id in _run_peers():
		send(id, "succ", [list, succ_port, lead_pid, left_slot])


func _on_succ(list: Array, port: int, lpid: String, left_slot: = -1) -> void :
	if is_client():
		succession = list
		succ_port = port
		lead_pid = lpid
		_lead_left_slot = left_slot
		var ep = _epic_node() if _epic else null
		if ep != null and not list.is_empty():
			ep.room_successor = str((list[0] as Dictionary).get("user", ""))




func _can_migrate() -> bool:
	return (_enet or _relay_mig() or (_epic and _epic_node() != null)) and ( not succession.is_empty() or _relay) and world.player != null and not world.training and _mig_place_ok()





func _mig_place_ok() -> bool:


	return world.running





func hand_off() -> bool:



	if not is_host() or not world.running or world.training or not (_enet or _epic or _relay_mig()) or _run_peers().is_empty() or not _mig_place_ok():
		return false
	_send_succession(true)
	print("NET leader leaves the run: it passes to the next leader")


	get_tree().create_timer(0.4, true, false, true).timeout.connect( func():
		_teardown()
		roster_changed.emit())
	return true




func _migrate() -> void :
	_drop_loot()

	if _banner != null and _banner.visible:
		_pause_banner(false)


		if not world.menus.is_open():
			world.get_tree().paused = false
	if _relay:
		_migrate_relay()
		return
	var first: Dictionary = succession[0]


	var mine: = int(first.get("slot", -1)) == my_slot
	print("NET leader gone: the run passes to slot %d%s" % [int(first.get("slot", -1)), " (me)" if mine else ""])
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	mode = ""
	_mig = {"t": 0.0, "retry": 1.0, "port": succ_port, "user": str(first.get("user", ""))}
	if _epic:
		_mig["sock"] = _epic_node().room_next_socket()
	var who: = ""
	for h in world.heroes:
		if is_instance_valid(h) and h.slot == int(first.get("slot", -1)):
			who = Save.char_name(h.class_id) if h == world.player else tr(h.job_name())
	world.hud.announce(tr("El líder se desconectó"), Color(1.0, 0.85, 0.3), 
		tr("Ahora lideras tú: la partida sigue.") if mine else tr("%s toma el mando: la partida sigue.") % who)
	if mine:
		_become_host()
	else:


		for nid in mobs:
			var e = mobs[nid]
			if is_instance_valid(e):
				world.enemies.erase(e)
				e.queue_free()
		mobs.clear()
		_mob_to.clear()
		_mob_seen.clear()
		_unknown.clear()
		for nid in picks:
			var pk: Dictionary = picks[nid]
			world.pickups.erase(pk)
			if pk.has("node") and is_instance_valid(pk.node):
				(pk.node as Node).queue_free()
		picks.clear()





func _migrate_relay() -> void :
	_drop_loot()
	var old = multiplayer.multiplayer_peer
	var conn = old.get("conn") if old != null else null
	print("NET leader gone (relay): waiting for the relay's new leader")
	_mig = {"t": 0.0, "retry": 0.0, "relay": conn, "sid": int(old.get("_server_id")) if old != null else 0}
	if old != null:

		old.set("owns", false)
		old.close()
	multiplayer.multiplayer_peer = null
	mode = ""
	world.hud.announce(tr("El líder se desconectó"), Color(1.0, 0.85, 0.3), tr("Esperando al líder..."))
	_mig_relay_tick()


func _mig_relay_tick() -> void :
	var conn = _mig.get("relay")
	if conn != null:
		conn.poll()
	if conn == null or str(conn.get("state")) != "in":

		if conn != null:
			conn.close()
		_mig["relay"] = null
		_mig["t"] = MIG_JOIN_TIME + 1.0
		return
	var sid: = int(conn.get("server_id"))
	if sid == 0 or sid == int(_mig.get("sid", 0)):
		return
	var ep = eos()
	if ep == null or not ep.has_method("room_view"):
		return
	var view: MultiplayerPeer = ep.room_view(conn)
	_mig["relay"] = null
	if conn.is_server():
		print("NET the relay passed the room to this game: it leads the run")
		world.hud.announce(tr("El líder se desconectó"), Color(1.0, 0.85, 0.3), tr("Ahora lideras tú: la partida sigue."))
		_mig["busy"] = true
		if not host(0, view):
			_mig.clear()
			world.running = false
			world.menus.show_end(false, world.net_end_result())
			return
		_mig.clear()
		_lost.clear()
		peers.clear()
		_known_mobs.clear()
		_known_picks.clear()
		_known_altars.clear()
		_quest_at = Vector3.INF
		_quest_prop_at = Vector3.INF
		_sent_state.clear()
		_asked.clear()
		_events.clear()
		_raid_events.clear()
		_rec_frame = -1
		world.net_promote()
		_after_promote()
		return
	print("NET the relay passed the room to %d: following it" % sid)


	for nid in mobs:
		var e = mobs[nid]
		if is_instance_valid(e):
			world.enemies.erase(e)
			e.queue_free()
	mobs.clear()
	_mob_to.clear()
	_mob_seen.clear()
	_unknown.clear()
	for nid in picks:
		var pk: Dictionary = picks[nid]
		world.pickups.erase(pk)
		if pk.has("node") and is_instance_valid(pk.node):
			(pk.node as Node).queue_free()
	picks.clear()
	if my_class == "" and world.player != null:
		my_class = world.player.class_id
	join("", 0, my_class, view)


static func _is_relay(peer: MultiplayerPeer) -> bool:
	var sc = peer.get_script() if peer != null else null
	return sc != null and str((sc as Script).resource_path).ends_with("relay_peer.gd")




func _relay_mig() -> bool:
	if not _relay:
		return false
	var p = multiplayer.multiplayer_peer
	var c = p.get("conn") if p != null else null
	return c != null and bool(c.get("mig"))



func _become_host() -> void :
	var port: = int(_mig.get("port", succ_port))
	var ok: = false
	if _epic:
		_mig["busy"] = true
		var peer = await _epic_node().room_server_async(str(_mig.get("sock", "")))
		ok = peer != null and host(0, peer)
	else:
		ok = host(port)
	if not ok:
		_mig.clear()
		world.running = false
		world.menus.show_end(false, world.net_end_result())
		return
	_mig.clear()
	_lost.clear()
	peers.clear()
	_known_mobs.clear()
	_known_picks.clear()
	_known_altars.clear()
	_quest_at = Vector3.INF
	_quest_prop_at = Vector3.INF
	_sent_state.clear()
	_asked.clear()
	_events.clear()
	_raid_events.clear()
	_rec_frame = -1
	world.net_promote()
	_after_promote()





func _after_promote() -> void :
	if _lead_left_slot < 0:
		return
	for h in world.heroes:
		if is_instance_valid(h) and h != world.player and int(h.slot) == _lead_left_slot:
			h.set_meta("left_run", true)
	_lead_left_slot = -1




func _mig_tick(delta: float) -> void :
	_mig["t"] = float(_mig.t) + delta
	if mode == "client" and _connected():
		return
	if float(_mig.t) > MIG_JOIN_TIME:
		print("NET migration: no new leader")
		var was_lead: = bool(_mig.get("was_lead", false))
		_mig.clear()
		_teardown()
		roster_changed.emit()
		if world.running and was_lead:


			world.get_tree().paused = false
			world._end_run(false)
		elif world.running:
			world.running = false
			world.get_tree().paused = false
			world.menus.show_end(false, world.net_end_result())
		return
	_mig["retry"] = float(_mig.retry) - delta
	if float(_mig.retry) > 0.0:
		return
	_mig["retry"] = 1.5
	if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		return
	if my_class == "" and world.player != null:
		my_class = world.player.class_id
	if bool(_mig.get("busy", false)):
		return
	if _mig.has("relay"):
		if _mig.get("relay") != null:
			_mig_relay_tick()
		return
	if _epic or bool(_mig.get("by_code", false)):
		_mig_join_epic()
		return
	join(_join_addr, int(_mig.port), my_class)




func _mig_join_epic() -> void :
	var ep = _epic_node()
	if ep == null and not _relay:
		return
	_mig["busy"] = true
	var peer: MultiplayerPeer = null
	if bool(_mig.get("by_code", false)):

		var by = eos() if _relay else ep
		if not _relay:
			ep.room_forget()
		peer = await by.join_async(str(_mig.get("code", "")))
	elif ep != null and str(_mig.get("user", "")) != "":
		peer = ep.room_client(str(_mig.get("sock", "")), str(_mig.get("user", "")))
	if _mig.is_empty():
		return
	_mig["busy"] = false
	if peer != null:
		join("", 0, my_class, peer)



func _epic_node():
	var n = eos()
	if n == null:
		return null
	var inner = n.get("epic")
	var e = inner if inner != null else n
	return e if e.has_method("room_server_async") else null




static func my_pid() -> String:
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--net-pid="):
			return str(arg).substr(10)
	return Leaderboard.player_id()





static func my_rejoin_key() -> String:
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--net-pid="):
			return "test-" + str(arg).substr(10)
	var k: = str(Save.setting("rejoin_key", ""))
	if k.length() < 32:
		var c: = Crypto.new()
		k = c.generate_random_bytes(16).hex_encode()
		Save.set_setting("rejoin_key", k)
	return k




func _lost_party() -> void :
	if not is_host() or succession.is_empty() or not world.running:
		return
	print("NET the party is gone at once: following the next leader")
	var port: = succ_port
	var relay_code: = str(eos().get("_code")) if _relay_mig() and eos() != null else ""
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	mode = ""
	peers.clear()
	_lost.clear()
	_drop_loot()



	_mig = {"t": 0.0, "retry": 2.0, "port": port, "was_lead": true}
	if _epic and _epic_node() != null:
		_mig["by_code"] = true
		_mig["code"] = str(_epic_node().code)
	elif relay_code != "":
		_mig["by_code"] = true
		_mig["code"] = relay_code
	world.hud.announce(tr("Se perdió la conexión con el grupo"), Color(1.0, 0.85, 0.3), tr("Volviendo a su partida..."))




func _drop_loot() -> void :
	if _loot_panel != null and is_instance_valid(_loot_panel):
		_loot_panel.queue_free()
	_loot_panel = null
	_loot = null
	if world._loot_panel != null and is_instance_valid(world._loot_panel):
		world._loot_panel.queue_free()
	world._loot_panel = null
	world._loot = null



func _quit_if_test() -> void :
	if "--net-auto" in OS.get_cmdline_user_args():
		get_tree().create_timer(1.0, true, false, true).timeout.connect(get_tree().quit)


func _on_ask_hello() -> void :
	_send_hello()


func _on_hello(class_id: String, hero_name: String, profile: Dictionary) -> void :
	var id: = _sender
	var known: Dictionary = peers.get(id, {})
	var fresh: bool = not known.get("ready", false)
	known["class"] = class_id if GameData.CLASSES.has(class_id) else "swordsman"
	known["name"] = NameFilter.shown(hero_name.left(24))
	known["profile"] = profile if profile.has("look") else {}
	known["ready"] = true
	peers[id] = known
	_rec_frame = -1
	print("NET hello from %d: %s" % [id, class_id])
	send(id, "welcome")
	_send_roster()
	if fresh:
		peer_joined.emit(id)
		_first_party_tip()
		_try_rejoin(id)









func _try_rejoin(id: int) -> void :
	if not is_host() or not world.running or world.town != null:
		return
	var pid: = str((peers[id].get("profile", {}) as Dictionary).get("pid", ""))
	var rk: = str((peers[id].get("profile", {}) as Dictionary).get("rk", ""))
	if pid == "":
		return



	var mine: = func(h: Player) -> bool:
		var want: = str(h.get_meta("net_rk", ""))
		return want == "" or want == rk


	for other in peers.keys():
		if other != id and str((peers[other].get("profile", {}) as Dictionary).get("pid", "")) == pid\
		and rk != "" and str((peers[other].get("profile", {}) as Dictionary).get("rk", "")) == rk:
			_on_peer_disconnected(other)
			if multiplayer.multiplayer_peer != null and multiplayer.multiplayer_peer.has_method("disconnect_peer"):
				multiplayer.multiplayer_peer.disconnect_peer(other)
	var snap = (peers[id].get("profile", {}) as Dictionary).get("mig")
	var has_snap: bool = snap is Dictionary and not (snap as Dictionary).is_empty()
	for h in world.heroes:
		if is_instance_valid(h) and h != world.player and h.has_meta("player_gone") and not h.has_meta("left_run")\
		and str(h.get_meta("net_pid", "")) == pid and mine.call(h)\
		and ( not has_snap or str(snap.get("class", h.class_id)) == h.class_id):


			h.set_meta("net_rk", rk)


			if has_snap:
				RunSave.apply_hero(world, snap, h, false)


				if not h.has_meta("mig_seeded"):
					h.set_meta("mig_seeded", true)
					h.xp_gained += float(snap.get("xp_gained", 0.0))
					h.purse += maxi(0, int(snap.get("purse", 0)))
				h.recompute()
			if _rejoin_ok():
				_rejoin(id, h)
			else:
				peers[id]["rejoin"] = h
				send(id, "rejoin_wait")
			return



func _rejoin_ok() -> bool:







	if world.tower != null and world.tower.hel != null:
		return false
	return world.running and world.raid.state in ["idle", "portal", "intro", "fight", "won"] and not world.morroc.active()




func _rejoin(id: int, h: Player) -> void :
	peers[id].erase("rejoin")
	peers[id]["hero"] = h
	peers[id]["class"] = h.class_id
	peers[id]["in_run"] = true
	h.input = HeroInput.Remote.new()
	h.remove_meta("player_gone")
	h.set_choosing(false)
	_rec_frame = -1
	_asked.erase(id)
	_sent_state.erase(id)
	print("NET peer %d is back in the run (slot %d)" % [id, h.slot])
	send(id, "start", [_start_info(h)])
	send(id, "rejoin", [RunSave.hero_snapshot(world, h)])
	_catch_up(id)


	if world.tower != null and not world.raid.in_arena():
		send(id, "tower", [["map", world.map.map_name, h.position]])
		world.tower._net_key = ""

	if world.raid.in_arena():
		send(id, "arena_in", [str(world.raid.data.get("arena", "")), world.raid.center, world.raid.radius, h.position])
		var evs: = [["arena", world.raid.mvp]]
		if world.raid.state == "fight":
			evs.append(["fight", world.raid.mvp])
		send(id, "raid", [evs])

	_worn_keys.clear()
	_quest_key = ""
	_send_roster()
	var who: = str(peers[id].get("name", ""))
	world.party_announce(tr("¡%s volvió a la partida!") % who if who != "" else tr("¡Un compañero volvió a la partida!"), Color(0.6, 0.9, 1.0), "")




func _rejoin_waiting() -> void :
	if not _rejoin_ok():
		return
	for id in peers.keys():
		var h = peers[id].get("rejoin")
		if h != null:
			if is_instance_valid(h) and h.has_meta("player_gone"):
				_rejoin(id, h)
			else:
				peers[id].erase("rejoin")




func _catch_up(id: int) -> void :
	var news: = []
	for e in world.enemies:
		if e.nid != 0 and _known_mobs.has(e.nid) and not e.dead:
			var m: = ["m", e.nid, e.id, e.net_special(), e.position, e.scale.x, 
				float(e.get_meta("big")) if e.has_meta("big") else 1.0, e.max_hp, e.damage, e.speed, e.xp]
			news.append(m)


			for k in world.traits.looks_of(e):
				news.append(["t", e.nid, k[0], k[1]])
	for p in world.pickups:
		if p.has("nid") and _known_picks.has(p.nid):
			var at: Vector3 = p.get("hop_to", (p.node as Node3D).position)
			news.append(["p", p.nid, p.kind, int(p.value), str(p.get("spr", "")), int(p.get("tier", 0)), 
				int(p.get("bonus", 0)), str(p.get("unique", "")), at, 


				str(p.get("id", ""))])
	for a in world.altars.waiting:
		var key: = "%s|%d|%d" % [a.id, roundi(a.pos.x * 4.0), roundi(a.pos.z * 4.0)]
		if _known_altars.has(key):
			news.append(["a", key, str(a.id), a.pos])
	if _quest_at != Vector3.INF:
		news.append(["q", str(world.quest.data.get("npc", "")), tr(str(world.quest.data.get("npc_name", ""))), _quest_at])
	if _quest_prop_at != Vector3.INF:
		news.append(["qp", str(world.quest.data.get("prop", "")), _quest_prop_at])
	if _quest_mark != Vector3.INF:
		news.append(["qm", _quest_mark, _quest_label, world.quest.marker_head()])
	if _emv_sent > -2.0:
		news.append(["emv", _emv_sent])
	var i: = 0
	while i < news.size():
		send(id, "changes", [news.slice(i, i + 25)])
		i += 25
	send(id, "karma", [world.karma.value])

	for ev in world.hell_late.catch_up():
		send(id, "hz", [ev])




func _on_rejoin(d: Dictionary) -> void :
	if not _live():
		return
	RunSave.apply_hero(world, d, world.player, false)
	world.player.recompute()
	_gear_key = ""
	print("NET back in the run: level %d, %d skills, %d in the bag" % [world.player.level, world.player.skills.size(), world.player.equipment.bag.size()])
	world.hud.announce(tr("¡De vuelta en la partida!"), Color(0.6, 0.9, 1.0), tr("Tu héroe siguió peleando con la IA mientras no estabas"))




func _on_rejoin_wait() -> void :

	if world.running:
		world.party_announce(tr("Tu grupo está en plena pelea"), Color(0.6, 0.8, 1.0), tr("Entrarás con tu héroe en cuanto vuelvan al mapa."))
		return
	if world.town != null and is_instance_valid(world.town):
		world.menus.show_npc_line(tr("Lydia"), "npc_party", tr("Tu grupo sigue en la partida, en plena pelea. Entrarás con tu héroe en cuanto vuelvan al mapa."))




func _first_party_tip() -> void :
	if Save.has_seen("tips", "party_portal") or world.town == null or not is_instance_valid(world.town):
		return
	Save.mark_seen("tips", "party_portal")
	world.channel.log_line("sys", tr("Eres el líder: cuando estén todos listos, ve al portal para elegir el mapa."))

	if str(world.menus.mode()) in ["town", "coop"]:
		world.menus.show_npc_line(tr("Lydia"), "npc_party", tr("¡Ya tienes party! Eres el líder: cuando estén todos listos, ve al portal de la plaza para elegir el mapa."))
	world.emote(world.town.hero, "go", 2.5)


func _on_welcome() -> void :
	_welcomed = true



func _send_roster() -> void :
	if not is_host():
		return
	var host_class: = world.town.class_id if world.town != null else (world.player.class_id if world.player != null else "swordsman")

	var host_name: = str(Save.look(host_class).get("name", "")).strip_edges()
	var list: = [{"id": 1, "name": Save.char_name(host_class) if host_name != "" else "", "class": host_class, "look": Save.look(host_class), 
		"views": Equipment.loadout_views(host_class), "ch": world.channel.number if world.channel.is_in() else 0, 

		"place": world.town.place if world.town != null and is_instance_valid(world.town) else "", 
		"pet": Save.pet_skin(), "hg": int(Equipment.loadout_harmony(host_class).level), "rl": Save.rebirth_lv(host_class)}]
	for id in ready_peers():
		var prof: Dictionary = peers[id].profile if peers[id].profile is Dictionary else {}
		var pcls: = str(peers[id]["class"])
		list.append({"id": id, "name": str(peers[id].name), "class": pcls, 
			"look": prof.get("look", {}), "views": Equipment.views_of(prof.get("gear", {}), pcls, prof.get("cos", {}) if prof.get("cos", {}) is Dictionary else {}, 
				prof.get("look", {}) if prof.get("look") is Dictionary else {}), 
			"pet": str(prof.get("pet_skin", prof.get("pet", ""))), 


			"hg": int(Equipment.harmony_of(prof.get("gear", {}) if prof.get("gear") is Dictionary else {}).level), 
			"rl": clampi(int(prof.get("rlv", 0)) if (prof.get("rlv") is int or prof.get("rlv") is float) else 0, 0, GameData.REBIRTH_LV_MAX)})
	roster = list
	for id in ready_peers():
		send(id, "roster", [list])
	if world.town != null:
		world.town.sync_party(list, 1)
	roster_changed.emit()


func _on_roster(list: Array) -> void :
	roster = list
	if world.town != null:
		world.town.sync_party(list, my_id())
	roster_changed.emit()
	_follow_place()




func _follow_place() -> void :
	if not is_client() or roster.is_empty() or world.running or world.town == null or not is_instance_valid(world.town):
		return
	var lead: Dictionary = roster[0] if roster[0] is Dictionary else {}
	var place: = str(lead.get("place", ""))
	if not place in ["prontera", "tower_gate"] or place == world.town.place:
		return
	if not str(world.menus.mode()) in ["town", "coop", "npc_line"]:
		return
	world.menus.show_loading(world.enter_town.bind(world.town.class_id, place), [str(GameData.TOWER_GATE.map) if place == "tower_gate" else Town.MAP])




func _town_tick(delta: float) -> void :
	_town_t -= delta
	if _town_t > 0.0:
		return
	_town_t = 1.0 / TOWN_RATE
	var hero: RoVisual = world.town.hero
	var me: = [hero.position.x, hero.position.z, hero.dir, hero.base_action, world.menus.mode()]
	if is_client() and _welcomed:
		send_u(1, "town_pos", me)
	elif is_host() and not ready_peers().is_empty():
		var all: = [[1] + me]
		for id in ready_peers():
			var t = peers[id].get("town")
			if t != null:
				all.append([id] + t)
				world.town.move_party_member(id, t[0], t[1], t[2], t[3], str(t[4]))
		for id in ready_peers():
			send_u(id, "town_state", [all])


func _on_town_pos(x: float, z: float, dir: int, action: int, doing: String) -> void :
	if peers.has(_sender):
		peers[_sender]["town"] = [x, z, dir, action, doing.left(24)]


func _on_town_state(all: Array) -> void :
	if world.town == null or world.running:
		return
	var me: = my_id()
	for t in all:
		if int(t[0]) != me and t.size() >= 6:
			world.town.move_party_member(int(t[0]), float(t[1]), float(t[2]), int(t[3]), int(t[4]), str(t[5]))




func town_event(kind: String, ok: bool) -> void :
	if is_client() and _welcomed:
		send(1, "town_event", [kind, ok])
	elif is_host():
		for id in ready_peers():
			send(id, "town_event", [1, kind, ok])




func trade_send(to: int, msg: Array) -> void :
	if is_client():
		send(1, "trade", [to, msg])
	elif is_host() and peers.has(to):
		send(to, "trade", [1, msg])



func _on_trade(a, b = null) -> void :
	if not b is Array or world.menus.trade == null:
		return
	if is_host():
		var to: = int(a)
		if to == 1:
			world.menus.trade.net_in(_sender, b)
		elif peers.has(to) and to != _sender:
			send(to, "trade", [_sender, b])
	else:
		world.menus.trade.net_in(int(a), b)





func chan_send(id: int, data: PackedByteArray, reliable: bool) -> void :
	if reliable:
		send(id, "chan", [data])
	else:
		send_u(id, "chan", [data])


func chan_hi(id: int, n: int) -> void :
	if is_client() and _welcomed:
		send(1, "chan_hi", [id, n])
	elif is_host():
		for p in ready_peers():
			send(p, "chan_hi", [id, n])


func chan_ok(to: int, id: int, n: int) -> void :
	send(to, "chan_ok", [id, n])


func _on_chan(data = null) -> void :
	if data is PackedByteArray and world.channel != null:
		world.channel.from_room(_sender, data)


func _on_chan_hi(id = null, n = null) -> void :
	if (id is int) and (n is int) and world.channel != null:
		world.channel.room_hi(_sender, id, n)


func _on_chan_ok(id = null, n = null) -> void :
	if (id is int) and (n is int) and world.channel != null:
		world.channel.room_ok(_sender, id, n)



func town_chat(line: String) -> void :
	line = line.left(120)
	if is_client() and _welcomed:
		send(1, "town_chat", [line])
	elif is_host():
		for id in ready_peers():
			send(id, "town_chat", [1, line])



func _on_town_chat(a, b = null) -> void :
	if world.town == null:
		return
	if is_host():
		var line: = NameFilter.clean(str(a)).left(120)
		world.town.party_chat(_sender, line)
		world.channel.log_line("party", line)
		for id in ready_peers():
			if id != _sender:
				send(id, "town_chat", [_sender, line])
	elif int(a) != my_id():
		var line: = NameFilter.clean(str(b)).left(120)
		world.town.party_chat(int(a), line)
		world.channel.log_line("party", line)



func _on_town_event(a, b, c = null) -> void :
	if world.town == null:
		return
	if is_host():
		var who: = _sender
		world.town.party_event(who, str(a), bool(b))
		for id in ready_peers():
			if id != who:
				send(id, "town_event", [who, str(a), bool(b)])
	else:
		if int(a) != my_id():
			world.town.party_event(int(a), str(b), bool(c))






func send_start() -> void :
	_known_mobs.clear()
	_known_picks.clear()
	_known_altars.clear()
	_quest_at = Vector3.INF
	_quest_prop_at = Vector3.INF
	_sent_state.clear()
	_asked.clear()
	_events.clear()
	_raid_events.clear()



	for id in peers:
		var h = peers[id].get("hero")
		if h != null and is_instance_valid(h):
			h.set_meta("net_pid", str((peers[id].get("profile", {}) as Dictionary).get("pid", "")))
			h.set_meta("net_rk", str((peers[id].get("profile", {}) as Dictionary).get("rk", "")))
	for id in peers:
		var h = peers[id].get("hero")
		if h == null or not is_instance_valid(h):
			continue
		peers[id]["in_run"] = true
		_rec_frame = -1
		send(id, "start", [_start_info(h)])



func _start_info(h: Player) -> Dictionary:
	var party: = []
	for ph in world.heroes:
		party.append({"slot": ph.slot, "class": ph.class_id, "path": ph.job_path, "look": ph.appearance, "pet": ph.pet_skin, 
			"aura": ph.rebirth_aura, "rlooks": ph.rebirth_looks, 

			"pid": my_pid() if ph == world.player else str(ph.get_meta("net_pid", ""))})
	var info: = {"stage": world.stage_id, "danger": world.danger, "party": party, "you": h.slot, 
		"pos": h.position, "training": world.training, "frenzy": world.frenzy, "festival": world.festival_mode, 
		"oaths": world.oaths}

	if world.tower_start > 0:
		info["tower"] = {"floor": world.tower_start, "map": TowerRun.map_of(world.tower_start), "hel": world.tower_hel}
	return info


func _on_start(info: Dictionary) -> void :

	if not _mig.is_empty():
		print("NET migrated: in the new leader's run")
	_mig.clear()
	_lost.clear()
	my_slot = int(info.you)
	_altars.clear()
	_quest_npc = null
	_quest_prop = null
	_gear_key = ""
	mobs.clear()
	_mob_to.clear()
	_mob_seen.clear()
	_unknown.clear()
	picks.clear()
	_hero_to.clear()
	_in_run = true


	_starting = true
	_held = []
	world.menus.show_loading( func():
		world.net_client_start(info)
		_starting = false
		var held: = _held
		_held = []
		for msg in held:
			_sender = 1
			callv("_on_" + str(msg[0]), msg[1]), _start_maps(info))



func _start_maps(info: Dictionary) -> Array:
	if bool(info.get("festival", false)):
		return [str(GameData.FESTIVAL_STAGE.map)]
	var climb: Dictionary = info.get("tower", {})
	if not climb.is_empty():
		return [str(climb.get("map", "")), str(GameData.TOWER_STAGE.map)]
	return [str(GameData.STAGES.get(str(info.get("stage", "")), {}).get("map", ""))]




func host_tick(delta: float) -> void :
	if mode == "host" and world.running and peers.values().any( func(pr): return pr.has("rejoin")):
		_rejoin_waiting()
	_succ_t -= delta
	if _succ_t <= 0.0 and world.running:
		_succ_t = 2.0
		_send_succession()



	if world.running and not _dropped_test:
		for arg in OS.get_cmdline_user_args():
			if str(arg).begins_with("--net-drop=") and world.time >= float(str(arg).substr(11)):
				_dropped_test = true
				print("NET test: the leader's connection drops at t=%.0f" % world.time)
				_lost_party()


			elif str(arg).begins_with("--net-drop-raid=") and world.raid.state == "fight" and world.raid._fight_t >= float(str(arg).substr(16)):
				_dropped_test = true
				print("NET test: the leader's connection drops %.0f s into the MVP fight" % world.raid._fight_t)
				_lost_party()

			elif str(arg).begins_with("--net-quit=") and world.time >= float(str(arg).substr(11)):
				_dropped_test = true
				print("NET test: the leader abandons the run at t=%.0f" % world.time)
				world.abandon_run()
				world.menus.close()
	if not recording():
		return
	_snap_t -= delta
	if _snap_t <= 0.0:
		_snap_t = 1.0 / SNAP_RATE
		_send_world()
	_state_t -= delta
	if _state_t <= 0.0:
		_state_t = 0.25
		for id in _run_peers():
			_send_hero_state(id)
			_ask_choices(id)
		_send_worn()
		_send_looks()
		_send_quest()
		_meter_t -= 0.25
		if _meter_t <= 0.0:



			var meters: = [world.meter_hero, world.meter_boss_hero]
			_meter_t = 1.0 if var_to_bytes(meters).size() < METER_BIG else 3.0
			_to_run("meter", meters)


			_to_run("meter_th", [world.meter_taken_hero, world.meter_heal_hero])
	if not _events.is_empty():
		_flush_events()
	if not _raid_events.is_empty():
		_flush_events(true)




func _flush_events(raid: = false) -> void :
	var batch: = []
	var size: = 0
	if not raid:
		var now: = Time.get_ticks_msec()
		var rate: = minf(FX_BUDGET, FX_BUDGET_ALL / float(maxi(1, _run_peers().size())))
		_fx_tokens = minf(rate * FX_BURST, _fx_tokens + rate * (now - _fx_tick_at) / 1000.0)
		_fx_tick_at = now
	for ev in (_raid_events if raid else _events):
		var n: = var_to_bytes(ev).size()
		if not raid:




			var keep: = str(ev[0]) in ["v", "f", "x"]
			if n > _fx_tokens and str(ev[0]) in LOOKS_ONLY and not keep:
				fx_shed += 1
				continue


			_fx_tokens = maxf(0.0, _fx_tokens - n) if keep else _fx_tokens - n
		if size + n > MAX_PACKET - 40 and not batch.is_empty():
			if raid:
				_to_run("raid", [batch])
			else:
				_to_run_u("fx", [batch])
			batch = []
			size = 0
		batch.append(ev)
		size += n
	if not batch.is_empty():
		if raid:
			_to_run("raid", [batch])
		else:
			_to_run_u("fx", [batch])
	if raid:
		_raid_events = []
	else:
		_events = []



func announce(title: String, color: Color, sub: = "") -> void :
	if recording():
		_to_run("announce", [title, color, sub])


func _on_announce(title: String, color: Color, sub: String) -> void :
	if _live():
		world.hud.announce(title, color, sub)


func record_raid(ev: Array) -> void :
	_raid_events.append(ev)


func _on_raid(list: Array) -> void :
	if not _live():
		return
	for ev in list:
		if ev is Array and not (ev as Array).is_empty():
			world.raid.net_event(ev)


func _to_run(kind: String, args: Array) -> void :
	for id in _run_peers():
		send(id, kind, args)


func _to_run_u(kind: String, args: Array) -> void :
	for id in _run_peers():
		send_u(id, kind, args)


func next_nid() -> int:
	_next_nid = (_next_nid % 65000) + 1
	return _next_nid




func _send_world() -> void :
	var news: = []
	var here: = {}
	for e in world.enemies:
		if e.nid == 0:
			e.nid = next_nid()
		here[e.nid] = true
		if not _known_mobs.has(e.nid):
			_known_mobs[e.nid] = e

			var m: = ["m", e.nid, e.id, e.net_special(), e.position, e.scale.x, 

				float(e.get_meta("big")) if e.has_meta("big") else 1.0, 


				e.max_hp, e.damage, e.speed, e.xp]
			news.append(m)


	if not world.traits.news.is_empty():
		news.append_array(world.traits.news)
		world.traits.news.clear()

	news.append_array(world.doram.net_news())
	for nid in _known_mobs.keys():
		if not here.has(nid):
			var e = _known_mobs[nid]
			news.append(["d" if is_instance_valid(e) and e.dead else "g", nid])
			_known_mobs.erase(nid)
	var seen: = {}
	for p in world.pickups:
		if not p.has("nid"):
			p["nid"] = next_nid()
		seen[p.nid] = true
		if not _known_picks.has(p.nid):
			_known_picks[p.nid] = true
			var at: Vector3 = p.get("hop_to", (p.node as Node3D).position)
			news.append(["p", p.nid, p.kind, int(p.value), str(p.get("spr", "")), int(p.get("tier", 0)), 
				int(p.get("bonus", 0)), str(p.get("unique", "")), at, 


				str(p.get("id", ""))])
		if p.pull and not p.has("_pull_sent"):
			p["_pull_sent"] = true
			var to = p.get("to")
			news.append(["u", p.nid, to.slot if to != null and is_instance_valid(to) else 0, p.has("fetch")])
	for nid in _known_picks.keys():
		if not seen.has(nid):
			news.append(["x", nid])
			_known_picks.erase(nid)
	var up: = {}
	for a in world.altars.waiting:
		var key: = "%s|%d|%d" % [a.id, roundi(a.pos.x * 4.0), roundi(a.pos.z * 4.0)]
		up[key] = true
		if not _known_altars.has(key):
			_known_altars[key] = true
			news.append(["a", key, str(a.id), a.pos])
	for key in _known_altars.keys():
		if not up.has(key):
			_known_altars.erase(key)
			news.append(["A", key])
	var q = world.quest.npc
	var qat: Vector3 = q.global_position if q != null and is_instance_valid(q) and q.visible else Vector3.INF
	if qat == Vector3.INF and _quest_at != Vector3.INF:
		news.append(["Q"])
		_quest_at = Vector3.INF
	elif qat != Vector3.INF and (_quest_at == Vector3.INF or qat.distance_to(_quest_at) > 0.6):
		news.append(["q", str(world.quest.data.get("npc", "")), tr(str(world.quest.data.get("npc_name", ""))), qat])
		_quest_at = qat

	var qp = world.quest.prop
	var qpat: Vector3 = qp.global_position if qp != null and is_instance_valid(qp) and qp.visible else Vector3.INF
	if qpat == Vector3.INF and _quest_prop_at != Vector3.INF:
		news.append(["QP"])
		_quest_prop_at = Vector3.INF
	elif qpat != Vector3.INF and (_quest_prop_at == Vector3.INF or qpat.distance_to(_quest_prop_at) > 0.4):
		news.append(["qp", str(world.quest.data.get("prop", "")), qpat])
		_quest_prop_at = qpat


	var qm: Vector3 = world.quest.marker() if world.quest.shows() else Vector3.INF
	var ql: String = world.quest.marker_label() if world.quest.shows() else ""
	if (qm == Vector3.INF) != (_quest_mark == Vector3.INF) or (qm != Vector3.INF and qm.distance_to(_quest_mark) > 0.6) or ql != _quest_label:
		_quest_mark = qm
		_quest_label = ql
		news.append(["qm", qm, ql, world.quest.marker_head() if qm != Vector3.INF else Vector3.INF])

	var emv: = world.endless_mvp_at()
	if absf(emv - _emv_sent) > 0.5:
		_emv_sent = emv
		news.append(["emv", emv])

	var i: = 0
	while i < news.size():
		_to_run("changes", [news.slice(i, i + 25)])
		i += 25

	var b: = StreamPeerBuffer.new()
	b.put_float(world.time)
	b.put_32(world.kills)




	b.put_u8((1 if world.get_tree().paused else 0) | (2 if world.game_fast else 0) | (4 if world.frenzy else 0) | (8 if world.raid.in_arena() else 0))
	b.put_u8(world.heroes.size())
	for h in world.heroes:
		b.put_float(h.position.x)
		b.put_float(h.position.z)
		b.put_u8(h.visual.dir if h.visual != null else 0)
		b.put_u8(h.visual.base_action if h.visual != null else 0)
		b.put_float(h.hp)
		b.put_float(h.max_hp)
		b.put_u8((1 if h.downed else 0) | (2 if h.choosing else 0) | (4 if h.shield > 0.5 and h.shield_src == "assumptio" else 0))
		b.put_u16(h.level)

		b.put_u8((h.job_path | (64 if h.dance_book() else 0)) if not h.job2.is_empty() else 255)
		b.put_u8(clampi(roundi(255.0 * h.revive_t / GameData.COOP_REVIVE_TIME), 0, 255))


		b.put_u8(h.songs_mask())
		b.put_u8(h.beat_n & 255)


	b.put_u16(map_key(world.map.map_name) if world.tower != null and not world.raid.in_arena() else 0)
	_to_run_u("snap_heroes", [b.data_array])
	var list: = world.enemies
	if list.size() > MOBS_HALF_FROM:
		_snap_half = 1 - _snap_half
		var half: Array[Enemy] = []
		for k in range(_snap_half, list.size(), 2):
			half.append(list[k])
		list = half
	i = 0
	while i < list.size():
		var m: = StreamPeerBuffer.new()
		var n: = mini(MOBS_PER_PACKET, list.size() - i)
		m.put_u16(n)
		for k in n:
			var e: Enemy = list[i + k]
			m.put_u16(e.nid)
			m.put_16(clampi(roundi(e.position.x * POS_Q), -32768, 32767))
			m.put_16(clampi(roundi(e.position.z * POS_Q), -32768, 32767))
			var v = e.visual
			m.put_u8((int(v.dir) & 7) | ((int(v.base_action) & 31) << 3))
			m.put_u8(clampi(roundi(255.0 * e.hp / maxf(1.0, e.max_hp)), 0, 255))
		_to_run_u("snap_mobs", [m.data_array])
		i += n




func _send_hero_state(id: int) -> void :
	var h = peers[id].get("hero")
	if h == null or not is_instance_valid(h):
		return
	var skills: = {}
	var cds: = {}
	for k in h.skills:
		skills[k] = int(h.skills[k].level)
		var cd: = snappedf(maxf(0.0, float(h.skills[k].cd)), 0.25)
		if cd > 0.0:
			cds[k] = cd
	var powers: = {}
	for k in h.powers:
		powers[k] = float(ceili(float(h.powers[k])))
	var st: = {"level": h.level, "xp": h.xp, "xp_need": h.xp_need, "pending": h.pending_levels, "skills": skills, 
		"stats": h.stats.duplicate(), "job": h.job_path if not h.job2.is_empty() else -1, "book": h.song_book, "zeny": world.zeny_of(h), 


		"xg": roundi(h.xp_gained), "mc": world.run_mob_coins, 
		"shield": h.shield, "homun": h.homun_type, "homx": Array(h.homun_extra), "speed": h.move_speed, 
		"forge": h.forge, "heat": snappedf(h.forge_heat, 0.05), "hb": snappedf(h.heat_level, 0.1), "rerolls": h.rerolls, "banishes": h.banishes, "banished": Array(h.banished), "lives": h.revives, 
		"pbuffs": _pbuffs(h), "cds": cds, "powers": powers, "endless": world.endless, "death": h.death_by, 



		"growth": [h.stew_kills, h.root_kills, h.lg_bash_kills, h.hel_marks, h.feathers], 

		"ocurse": snappedf(h.oath_curse, 0.01), 

		"tk": roundf(h.run_taken), "hl": roundf(h.run_healed), 


		"am": h.altar_mods.duplicate(), "ka": h.karma_altars.duplicate(), 


		"toys": h.toys.duplicate(), 



		"karma": [world.karma.boon, world.karma.boons, world.karma.hel_marks, world.karma.feathers, world.karma.path] if world.karma != null else []}
	var key: = var_to_str(st)
	if _sent_state.get(id, "") == key:
		return
	_sent_state[id] = key
	send(id, "hero_state", [st])



func _ask_choices(id: int) -> void :
	var h = peers[id].get("hero")

	if h == null or not is_instance_valid(h):
		return
	if _asked.has(id):


		if Time.get_ticks_msec() - int(_asked_at.get(id, 0)) > ASK_AGAIN_MS:
			_asked_at[id] = Time.get_ticks_msec()
			if str(_asked[id]) == "job":
				send(id, "offer_job")
			elif _asked[id] is Array:
				send(id, "offer_choices", [_asked[id]])
		return
	_asked_at[id] = Time.get_ticks_msec()
	if h.can_job_change() and not h.downed:
		_asked[id] = "job"
		send(id, "offer_job")
	elif h.pending_levels > 0:
		var choices: Array = h.build_choices()
		if choices.is_empty():
			h.pending_levels = 0
			return
		_asked[id] = choices
		send(id, "offer_choices", [choices])


func record(ev: Array) -> void :

	if Vfx.hero and str(ev[0]) in ["v", "f", "x", "ab", "B"]:

		var by = world.damage_by
		ev = ["H", ev, (by as Player).slot if by is Player and is_instance_valid(by) else -1]
	_events.append(ev)



func ref_of(n: Node) -> Array:
	if n is Player:
		return ["h", (n as Player).slot]
	if n is Enemy:
		if (n as Enemy).nid == 0:
			(n as Enemy).nid = next_nid()
		return ["m", (n as Enemy).nid]
	return []




func _remote_hero(id: int) -> Player:
	if not peers.has(id):
		return null
	var h = peers[id].get("hero")
	return h if h != null and is_instance_valid(h) else null


func _on_move(x: float, z: float, sx: float, sz: float, choosing: bool) -> void :
	var h: = _remote_hero(_sender)
	if h == null or not world.running or not (h.input is HeroInput.Remote):
		return
	var r: HeroInput.Remote = h.input
	if Time.get_ticks_msec() >= r.deaf_until:
		r.pos = Vector3(x, 0, z)
	r.stick = Vector2(sx, sz)
	r.fresh = true
	h.set_choosing(choosing and not h.downed)


func _on_pick_choice(index: int) -> void :
	var id: = _sender
	var h: = _remote_hero(id)
	if h == null or not (_asked.get(id) is Array):
		return
	var choices: Array = _asked[id]
	_asked.erase(id)
	if index < 0 or index >= choices.size() or h.pending_levels <= 0:
		return
	h.apply_choice(choices[index], world)
	h.pending_levels -= 1
	_remote_homun(id, h)
	_state_t = 0.0




func _remote_homun(id: int, h: Player) -> void :
	if h.skills.has("call_homunculus") and h.homun_type == "":
		var prof: Dictionary = peers[id].get("profile", {}) if peers.has(id) and peers[id].get("profile") is Dictionary else {}
		var pick: = str(prof.get("homun_pick", ""))
		h.homun_type = pick if GameData.HOMUNCULI.has(pick) else GameData.HOMUNCULI.keys().pick_random()
		world.spawn_homun(h)
	world.check_more_homun(h)






func send_homun(kind: String, slot: int) -> void :
	send(1, "homun_set", [kind, slot])


func _on_homun_set(kind: String, slot: int) -> void :
	var h: = _remote_hero(_sender)
	if h != null and world.running and GameData.HOMUNCULI.has(kind):
		world.swap_homun(h, slot, kind)
		_state_t = 0.0



func _pbuffs(h: Player) -> Dictionary:
	var out: = {}
	for id in h.party_buffs:
		out[id] = {"t": float(ceili(float(h.party_buffs[id].t))), "level": h.party_buffs[id].level, "power": h.party_buffs[id].power}
	return out



func _on_reroll() -> void :
	var id: = _sender
	var h: = _remote_hero(id)
	if h == null or h.rerolls <= 0 or not (_asked.get(id) is Array):
		return
	h.rerolls -= 1
	var choices: = h.build_choices()
	_asked[id] = choices
	send(id, "offer_choices", [choices])
	_state_t = 0.0




func _on_banish(index: int) -> void :
	var id: = _sender
	var h: = _remote_hero(id)
	if h == null or h.banishes <= 0 or not (_asked.get(id) is Array):
		return
	var choices: Array = (_asked[id] as Array).duplicate()
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	h.banish(choice)
	var next: = h.replacement_choice(choices.filter( func(o): return o != choice))
	if next.is_empty():
		choices.remove_at(index)
	else:
		choices[index] = next
	_asked[id] = choices
	send(id, "offer_choices", [choices])
	_state_t = 0.0




func send_auto_banish(keys: Array) -> void :
	send(1, "auto_banish", [keys])




func _on_auto_banish(keys: Array) -> void :
	var h: = _remote_hero(_sender)
	if h == null:
		return
	for key in keys:
		var k: = str(key)
		if h.banishes > 0 and k.contains(":") and not h.banished.has(k):
			h.banishes -= 1
			h.banished.append(k)
	_state_t = 0.0



func morroc_event(ev: Array) -> void :
	_to_run("morroc", [ev])


func _on_morroc(ev: Array) -> void :
	if _live():
		world.morroc.net_event(ev)




func hell_event(ev: Array) -> void :
	_to_run("hz", [ev])


func _on_hz(ev: Array) -> void :
	if _live() and ev.size() > 1:
		world.hell_late.net_event(ev)



func ask_hypno(h: Player) -> bool:
	for id in peers:
		if peers[id].get("hero") == h:
			send(id, "hypno_ask")
			return true
	return false


func _on_hypno_ask() -> void :
	if _live():
		world.altars.hypno_choose(true)


func send_hypno(old: String, id: String) -> void :
	send(1, "hypno_pick", [old, id])


func _on_hypno_pick(old: String, id: String) -> void :
	var peer: = _sender
	var h: = _remote_hero(peer)
	if h != null and world.running:
		world.altars.hypno_remote(h, old, id)




		_reask(peer, h)
		_state_t = 0.0




func _reask(peer: int, h: Player) -> void :



	if _asked.get(peer) is Array and (_asked[peer] as Array).any( func(c): return c is Dictionary and h.choice_stale(c)):
		_asked[peer] = h.build_choices()
		_asked_at[peer] = Time.get_ticks_msec()
		send(peer, "offer_choices", [_asked[peer]])




func ask_corrupt(h: Player, at: Vector3) -> bool:
	for id in peers:
		if peers[id].get("hero") == h:
			send(id, "corrupt_ask", [at, world.karma.path])
			return true
	return false


func _on_corrupt_ask(at: Vector3, path: = "") -> void :
	if not _live():
		return

	var auto: int = world.menus.corrupt_auto()
	if auto >= 0:
		send(1, "corrupt_pick", [auto == 1, at])
		return
	world.menus.show_corrupt_chest( func(): send(1, "corrupt_pick", [true, at]), func(): send(1, "corrupt_pick", [false, at]), path)


func _on_corrupt_pick(open: bool, at: Vector3) -> void :
	var h: = _remote_hero(_sender)
	if h == null or not world.running:
		return
	if open:
		world.karma.open_chest(at, h)
	else:
		world.karma.purify_chest(at, h)




func place_remote(h: Player, at: Vector3) -> void :
	for id in peers:
		if peers[id].get("hero") == h:
			send(id, "place", [at.x, at.z])
			return


func _on_place(x: float, z: float) -> void :
	if not _live() or world.player == null:
		return
	var at: = Vector3(x, 0, z)
	world.player.position = Vector3(x, world.map.height_at(at), z)



func send_job_skill(id: String) -> void :
	send(1, "job_skill", [id])


func _on_job_skill(id: String) -> void :
	var h: = _remote_hero(_sender)
	if h != null and world.running and not h.job2.is_empty():
		h.set_job_skill(id)


		_remote_homun(_sender, h)

		_reask(_sender, h)
		_state_t = 0.0



func send_zeny(z: int) -> void :
	send(1, "zeny", [z])


func _on_zeny(z: int) -> void :
	var h: = _remote_hero(_sender)
	if h != null and world.running and z > 0 and z < 10000000:
		h.purse += z



func send_skill_cmd(id: String, all: bool) -> void :
	send(1, "skill_cmd", [id, all])


func send_arrow(id: String) -> void :
	send(1, "arrow", [id])


func _on_skill_cmd(id: String, all: bool) -> void :
	var h: = _remote_hero(_sender)
	if h != null and world.running:
		world.hero_skill_switch(h, id, all)


func _on_arrow(id: String) -> void :
	var h: = _remote_hero(_sender)
	if h != null and h.quiver.has(id):
		h.arrow_id = id



func send_reroll() -> void :
	send(1, "reroll")


func send_banish(index: int) -> void :
	send(1, "banish", [index])



func _on_pet_fetch(on: bool) -> void :
	var h: = _remote_hero(_sender)
	if h != null:
		h.pet_fetch = on


func _on_pick_job(path: int, book: = -1) -> void :
	var id: = _sender
	var h: = _remote_hero(id)
	if h == null or _asked.get(id) != "job":
		return
	_asked.erase(id)

	if book >= 0:
		h.song_book = book
	h.job_change(clampi(path, 0, GameData.job_paths(h.class_id).size() - 1))
	world.job_change_show(h)
	world._on_level_up(h)
	world.check_more_homun(h)
	_state_t = 0.0


func _on_loot_pick(index: int, want: bool, done: bool) -> void :
	var h: = _remote_hero(_sender)
	if h == null or world._loot == null:
		return
	if index >= 0 and index < world._loot.items.size() and world._loot.wants(h.slot, index) != want:
		world._loot.toggle(h.slot, index)


	if index == -2:
		world._loot.standing_pass[h.slot] = true
	if done:
		world._loot.ready[h.slot] = true




func send_got(h: Player, kind: String, data) -> void :
	if not is_host():
		return
	for id in _run_peers():
		if _remote_hero(id) == h:
			send(id, "got", [kind, data])



func _meter_best(h: Player) -> float:
	var best: = 0.0
	if h.slot < world.meter_hero.size():
		for tag in world.meter_hero[h.slot]:
			best = maxf(best, float(world.meter_hero[h.slot][tag].get("max", 0.0)))
	return best


func _meter_total(h: Player) -> float:
	var total: = 0.0
	if h.slot < world.meter_hero.size():
		for tag in world.meter_hero[h.slot]:
			total += float(world.meter_hero[h.slot][tag].get("dmg", 0.0))
	return total



func is_remote(h: Player) -> bool:
	return is_host() and h != null and h.input is HeroInput.Remote



func _on_got(kind: String, data) -> void :
	if not _live():
		return
	var p: = world.player
	match kind:
		"item":
			p.equipment.receive(data)
		"bag":
			p.equipment.bag.append(data)
		"ore":
			p.equipment.ores[str(data)] = int(p.equipment.ores.get(str(data), 0)) + 1
			if GameData.ORES.has(str(data)):
				world.hud.prize(str(data), tr("+%d %s  ·  tienes %d") % [1, tr(GameData.ORES[str(data)].name), int(p.equipment.ores[str(data)])], 
					Color(GameData.ORES[str(data)].color).darkened(0.35))
		"card":
			world._take_card(str(data), p.position)
		"plagiarize":
			world.plagiarize_id(str(data))
		"arrow":
			if not p.quiver.has(str(data)):
				p.add_arrow(str(data))
			world._announce_ammo(str(data))
		"coin":

			world.found_coin()
		"finale":

			world.morroc.finale_reward()
		"material":
			Save.add_material(str(data[0]), int(data[1]))
			world.run_materials[str(data[0])] = int(world.run_materials.get(str(data[0]), 0)) + int(data[1])
			world.prize_shown(str(data[0]), int(data[1]))
		"warn":

			world.hud.alerts.warn(MvpRaid.warn_text(str(data[0]), data[3] if data.size() > 3 and data[3] is Array else []), data[1], str(data[2]))
		"guide":

			if world.raid != null:
				world.raid.net_guide(data[0], float(data[1]), data[2], float(data[3]))
		"tame":

			if GameData.PETS.has(str(data)) and not Save.has_pet(str(data)):
				world.try_tame(str(data))
		"wings":
			Save.add_tower_wings(str(data))
		"hel_rose":

			world._hel_rose_got(p)
		"unique":

			var r: = world._found_unique(str(data.id))
			world.play_sound("drop_yellow", 0.0, 0.0)

			if str(data.id) == GameData.TOWER_WINGS:
				world._open_chest_show(p.position + Vector3(0.8, 0, 0.4), 3, [r], tr("Alas de la Torre"))
	p.recompute()




var _worn_keys: = {}
func _send_worn() -> void :
	for h in world.heroes:
		if not is_instance_valid(h) or h.equipment == null:
			continue
		var worn: = {}
		for k in h.equipment.slots:
			if h.equipment.slots[k] != null:
				var it: Dictionary = h.equipment.slots[k]
				worn[k] = {"id": it.id, "refine": int(it.get("refine", 0)), "slots": int(it.get("slots", 0)), "cards": []}
				if bool(it.get("hel", false)):
					worn[k]["hel"] = true


				if Equipment.grade(it) > 0:
					worn[k]["grade"] = Equipment.grade(it)
		var key: = var_to_str(worn)
		if _worn_keys.get(h.slot, "") == key:
			continue
		_worn_keys[h.slot] = key
		_to_run("worn", [h.slot, worn])




var _quest_key: = ""
func _send_quest() -> void :
	var q: = world.quest
	var st: = [q.state, q.hp, q.max_hp, q.window()]
	var key: = var_to_str(st)
	if key == _quest_key:
		return
	_quest_key = key
	_to_run("quest_st", [st])


func _on_quest_st(st: Array) -> void :
	if not _live():
		return
	var q: = world.quest
	if q.data.is_empty() and GameData.QUESTS.has(world.stage_id):
		q.data = GameData.QUESTS[world.stage_id]
	q.state = str(st[0])
	q.hp = int(st[1])
	q.max_hp = int(st[2])
	q.net_window = st[3] if st[3] is Dictionary else {}



func altar_taken(id: String) -> void :
	_to_run("altar", [id])


func _on_altar(id: String) -> void :
	if not _live() or not GameData.ALTARS.has(id):
		return
	var al: = world.altars
	al.taken.append(id)
	var pm: Dictionary = GameData.ALTARS[id].get("mods", {})
	for k in pm:
		al.mods[k] = al.mod(k) + float(pm[k])
	world.hud.refresh_altars()




var _looks_key: = ""
func _send_looks() -> void :
	var list: = []
	for h in world.heroes:


		list.append([h.spheres, h.coins, h.ov_stage, h.ov_text, h.soul_bonds, Uniques.net_look(world, h), int(h.get_meta("lk_imp", 0)), int(h.get_meta("pal_charges", 0)), float(h.uniq.get("ov_t", 0.0))] if is_instance_valid(h) else [0, 0, 0, "", 0, [], 0, 0, 0.0])
	var key: = var_to_str(list)
	if key == _looks_key:
		return
	_looks_key = key
	_to_run("looks", [list])


func _on_looks(list: Array) -> void :
	if not _live():
		return
	for i in mini(list.size(), world.heroes.size()):
		var h: Player = world.heroes[i]
		if is_instance_valid(h):
			h.spheres = int(list[i][0])
			h.coins = int(list[i][1])

			if (list[i] as Array).size() > 3:
				h.ov_stage = int(list[i][2])
				h.ov_text = str(list[i][3])


			if (list[i] as Array).size() > 8:
				h.uniq["ov_t"] = float(list[i][8])

			if (list[i] as Array).size() > 4:
				h.soul_bonds = int(list[i][4])

			if (list[i] as Array).size() > 5 and (list[i][5] is Array):
				if not (list[i][5] as Array).is_empty() or h.uniq.has("net_u"):
					h.uniq["net_u"] = list[i][5]

			if (list[i] as Array).size() > 6:
				if int(list[i][6]) > 0:
					h.set_meta("lk_imp", int(list[i][6]))
				elif h.has_meta("lk_imp"):
					h.remove_meta("lk_imp")

			if (list[i] as Array).size() > 7:
				h.set_meta("pal_charges", int(list[i][7]))




func _on_worn(slot: int, worn: Dictionary) -> void :
	if not _live() or slot == world.player.slot:
		return
	for h in world.heroes:
		if is_instance_valid(h) and h.slot == slot and h.equipment != null:
			for k in h.equipment.slots:
				h.equipment.slots[k] = worn.get(k)
			h.recompute()




func _send_gear() -> void :
	var e: = world.player.equipment
	var st: = {"slots": e.slots, "bag": e.bag, "cards": Array(e.card_bag), "ores": e.ores}
	var key: = var_to_str(st)
	if key == _gear_key:
		return
	_gear_key = key
	send(1, "gear", [st])


func _on_gear(st: Dictionary) -> void :
	var h: = _remote_hero(_sender)
	if h == null or not world.running:
		return
	var e: = h.equipment
	for k in st.get("slots", {}):
		if e.slots.has(k):
			e.slots[k] = st.slots[k]
	e.bag = st.get("bag", [])
	e.card_bag.clear()
	for c in st.get("cards", []):
		e.card_bag.append(str(c))
	e.ores = st.get("ores", e.ores)
	h.recompute()



func send_loot(offer: LootRoll) -> void :
	_to_run("loot_offer", [offer.items, offer.tier])


func send_loot_result(results: Array) -> void :
	_to_run("loot_result", [results])



func raid_portal(at: Vector3, caption: String, color: Color) -> void :
	if recording():
		_to_run("portal", [at, caption, color])




func raid_map(arena: String, center: Vector3, radius: float) -> void :
	if not recording():
		return
	for id in _run_peers():
		var h: = _remote_hero(id)
		if h != null:
			send(id, "arena_in", [arena, center, radius, h.position])


func raid_back() -> void :
	if not recording():
		return
	for id in _run_peers():
		var h: = _remote_hero(id)
		if h != null:
			send(id, "arena_out", [h.position])




func send_end(victory: bool) -> void :
	for id in _run_peers():
		peers[id]["in_run"] = false
		_rec_frame = -1
		send(id, "run_end", [victory, _end_result(_remote_hero(id))])
		peers[id].erase("hero")


	for id in peers.keys():
		var back = peers[id].get("rejoin")
		if back is Player and is_instance_valid(back):
			_rec_frame = -1
			send(id, "run_end", [victory, _end_result(back)])
			peers[id].erase("rejoin")





func _end_result(h: Player) -> Dictionary:
	if h == null:
		return {"time": world.time, "kills": world.kills, "level": 1, "zeny": 0, "keep": []}
	var keep: = []


	for k in h.equipment.slots if not world.training else []:
		var it = h.equipment.slots[k]
		if it != null and not Equipment.is_perm(it) and not it.get("lent", false):



			var worn: Dictionary = it.duplicate(true)
			worn["_slot"] = str(k)
			keep.append(worn)
	for it in h.equipment.bag if not world.training else []:
		if not Equipment.is_perm(it) and not it.get("lent", false):
			keep.append(it.duplicate(true))
	return {"time": world.time, "kills": world.kills, "level": h.level, 
		"zeny": world.zeny_of(h), "keep": keep, "xp": h.xp_gained, "danger": world.danger, 
		"featured": world.featured, "mvps": world.run_ymir, "best_hit": _meter_best(h), "dealt": _meter_total(h), 
		"stage": world.stage_id, "hard": world.hard, "bosses": world.run_bosses, "altars": world.altars.taken.size(), 
		"quest": world.quest.result == "done", "legends": h.equipment.legend_found, 
		"ores": (h.equipment.ores_found as Dictionary).duplicate(), 

		"fell": h.downed or h.hp <= 0.0, "death_by": h.death_by.duplicate()}




func client_tick(delta: float) -> void :
	var p: = world.player
	if p == null or not _in_run:
		return

	if chain_until > 0 and Time.get_ticks_msec() > chain_until:
		chain_until = 0
		if world.menus.mode() == "level_up_pick":
			world.menus.hide_level_up()
	_dbg_t -= delta
	if _dbg_t <= 0.0 and "--net-auto" in OS.get_cmdline_user_args():
		_dbg_t = 5.0 if Array(OS.get_cmdline_user_args()).any( func(a): return str(a).begins_with("--net-shots=")) else 15.0
		print("NET client t=%.0f slot=%d lv=%d hp=%d/%d skills=%d mobs=%d drops=%d zeny=%d party=%d" % [world.time, my_slot, 
			p.level, p.hp, p.max_hp, p.skills.size(), mobs.size(), picks.size(), world.run_zeny, world.heroes.size()])
		print("NET client party pets=%s quest_mark=%s doram=%d" % [world._party_pets.values().map( func(v): return v.ro != null), world.quest.pointer(), world.doram._net.size()])
		print("NET client taken=%d healed=%d" % [int(world.meter_stats.get("taken", 0.0)), int(world.meter_stats.get("healed", 0.0))])
		print("NET client meter heal=%s taken_rows=%d" % [world.meter_heal.keys().map( func(k): return "%s:%d" % [k, int(world.meter_heal[k].dmg)]), world.meter_taken.size()])
		print("NETMEM t=%.0f static=%dMB objects=%d nodes=%d orphans=%d res=%d" % [world.time, OS.get_static_memory_usage() / 1048576, 
			Performance.get_monitor(Performance.OBJECT_COUNT), Performance.get_monitor(Performance.OBJECT_NODE_COUNT), 
			Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT), Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)])
		for a in OS.get_cmdline_user_args():
			if str(a).begins_with("--net-leave=") and world.time >= float(str(a).substr(12)):
				print("NET client leaving")
				world.abandon_run()
		for a in OS.get_cmdline_user_args():
			if str(a).begins_with("--net-shots="):
				var dir: = str(a).substr(12)
				DirAccess.make_dir_recursive_absolute(dir)
				get_viewport().get_texture().get_image().save_png("%s/client_%03d_%d.png" % [dir, int(world.time), Time.get_ticks_msec() / 1000])
	_resync_tick()
	_gear_t -= delta
	if _gear_t <= 0.0:
		_gear_t = 0.5
		_send_gear()
	_move_t -= delta
	if _move_t <= 0.0:
		_move_t = 1.0 / MOVE_RATE
		send_u(1, "move", [p.position.x, p.position.z, p._last_stick.x, p._last_stick.y, p.choosing])

	var k: = 1.0 - exp( - delta * 14.0)
	for nid in mobs:

		var e = mobs[nid]
		if is_instance_valid(e) and not e.dead and _mob_to.has(nid):


			e.position = e.position.lerp(_mob_to[nid], k)
	for h in world.heroes:
		if h != p and _hero_to.has(h.slot):
			var to: Vector3 = _hero_to[h.slot]
			h.position = h.position.lerp(Vector3(to.x, world.map.height_at(to), to.z), k)

	for nid in picks:
		var pk: Dictionary = picks[nid]
		var to = pk.get("to")
		if str(pk.get("fetch", "done")) != "done" and world._fetch_tick(pk, to, delta):
			continue
		if to != null and is_instance_valid(to):
			var node: Node3D = pk.node
			var d: Vector3 = to.position + Vector3(0, 0.5, 0) - node.position
			node.position += d.normalized() * delta * maxf(8.0, 22.0 - d.length() * 2.0) if d.length() > 0.3 else d



static func map_key(map_name: String) -> int:
	return maxi(1, map_name.hash() & 65535)




func _resync_tick() -> void :
	var now: = Time.get_ticks_msec()
	if now - _resync_at < RESYNC_EVERY_MS or world.raid.state == "intro":
		return
	var why: = ""
	for nid in _unknown.keys():
		if now - int(_unknown[nid]) > RESYNC_AFTER_MS:
			why = "unknown"

		if now - int(_unknown[nid]) > RESYNC_AFTER_MS * 4:
			_unknown.erase(nid)
	for nid in mobs:
		var e = mobs[nid]
		if is_instance_valid(e) and not e.dead and now - int(_mob_seen.get(nid, now)) > RESYNC_AFTER_MS:
			why = "ghost"
			break
	if _place_off_at > 0 and now - _place_off_at > RESYNC_AFTER_MS:
		why = "place"
	if why == "":
		return
	_resync_at = now
	_unknown.clear()
	print("NET out of step with the leader (%s): asking for the field again" % why)
	send(1, "resync_ask", [world._net_arena, map_key(world.map.map_name) if world.map != null else 0])





func _on_resync_ask(arena: bool, key: int) -> void :
	var id: = _sender
	var h: = _remote_hero(id)
	if h == null or not world.running or not bool(peers.get(id, {}).get("in_run", false)) or migrating():
		return
	var now: = Time.get_ticks_msec()
	if now - int(_resync_peer.get(id, -100000)) < RESYNC_EVERY_MS / 2:
		return
	_resync_peer[id] = now
	var alive: = []
	for e in world.enemies:
		if e.nid != 0 and _known_mobs.has(e.nid) and not e.dead:
			alive.append(e.nid)
	var drops: = []
	for pk in world.pickups:
		if pk.has("nid") and _known_picks.has(pk.nid):
			drops.append(pk.nid)
	send(id, "resync", [alive, drops])
	_catch_up(id)


	var in_arena: = world.raid.in_arena()
	var evs: = [["arena", world.raid.mvp]]
	if world.raid.state == "fight":
		evs.append(["fight", world.raid.mvp])
	var climb: String = world.map.map_name if world.tower != null and not in_arena else ""
	if in_arena != arena or (climb != "" and key != map_key(climb)):
		send(id, "resync_place", [in_arena, str(world.raid.data.get("arena", "")) if in_arena else "", world.raid.center, world.raid.radius, h.position, evs, climb])
		if world.tower != null:
			world.tower._net_key = ""
	print("NET peer %d out of step: field sent again (%d monsters, %d drops)" % [id, alive.size(), drops.size()])




func _on_resync(alive: Array, drops: Array) -> void :
	if not _live():
		return
	var keep: = {}
	for nid in alive:
		keep[int(nid)] = true
	var gone: = 0
	for nid in mobs.keys():
		if keep.has(int(nid)):
			continue
		var e = mobs[nid]
		mobs.erase(nid)
		_mob_to.erase(nid)
		_mob_seen.erase(nid)
		gone += 1
		if e != null and is_instance_valid(e):
			world.enemies.erase(e)
			e.queue_free()
	var have: = {}
	for nid in drops:
		have[int(nid)] = true
	for nid in picks.keys():
		if have.has(int(nid)):
			continue
		var pk: Dictionary = picks[nid]
		picks.erase(nid)
		world.pickups.erase(pk)
		if is_instance_valid(pk.get("node")):
			(pk.node as Node).queue_free()
	var now: = Time.get_ticks_msec()
	for nid in mobs:
		_mob_seen[nid] = now
	_unknown.clear()
	_place_off_at = 0
	print("NET field again from the leader: %d ghosts gone" % gone)



func _on_resync_place(in_arena: bool, arena: String, center: Vector3, radius: float, at: Vector3, evs: Array, climb: String) -> void :
	if not _live():
		return
	if in_arena and not world._net_arena and arena != "":
		world.net_arena_in(arena, center, radius, at)
		_on_raid(evs)
	elif not in_arena and world._net_arena:
		world.net_arena_out(at)
	elif not in_arena and climb != "" and world.tower != null and world.map != null and world.map.map_name != climb:
		world.tower.net_event(["map", climb, at])
	print("NET where the party is: arena=%s (here: arena=%s) map=%s" % [in_arena, world._net_arena, world.map.map_name if world.map != null else ""])
	_place_off_at = 0



func _live() -> bool:
	return is_client() and _in_run and world.running


func _on_changes(news: Array) -> void :
	if not _live():
		return
	for n in news:
		match str(n[0]):
			"m":
				if not mobs.has(n[1]):
					var e: = world.net_mob(str(n[2]), str(n[3]), n[4], float(n[5]), float(n[6]) if n.size() > 6 else 1.0)
					if e != null:
						e.nid = int(n[1])

						if n.size() > 10:
							e.max_hp = float(n[7])
							e.hp = e.max_hp
							e.damage = float(n[8])
							e.speed = float(n[9])
							e.xp = int(n[10])
						mobs[n[1]] = e
						_mob_to[n[1]] = n[4]
						_unknown.erase(n[1])
						_mob_seen[n[1]] = Time.get_ticks_msec()
			"ds", "dm", "dx":
				world.doram.net_in(world, n)
			"t":
				var te = mobs.get(n[1])
				if te != null and is_instance_valid(te) and n.size() > 3:
					world.traits.net_look(world, te, int(n[2]), n[3])
			"d", "g":
				var e = mobs.get(n[1])
				mobs.erase(n[1])
				_mob_to.erase(n[1])
				if e != null and is_instance_valid(e):
					world.enemies.erase(e)
					if n[0] == "d":
						e.die()
					else:
						e.queue_free()
			"p":





				if picks.has(n[1]):
					continue
				var pk: = world.net_pickup(str(n[2]), int(n[3]), str(n[4]), int(n[5]), int(n[6]), str(n[7]), n[8])
				if not pk.is_empty():
					picks[n[1]] = pk
					if n.size() > 9 and str(n[9]) != "":
						pk["id"] = str(n[9])
			"u":
				if picks.has(n[1]) and int(n[2]) < world.heroes.size():
					picks[n[1]]["to"] = world.heroes[int(n[2])]

					if n.size() > 3 and bool(n[3]):
						world.start_fetch(picks[n[1]], world.heroes[int(n[2])])
			"a":
				if not _altars.has(n[1]):
					world.altars.spawn(str(n[2]), n[3])
					if not world.altars.waiting.is_empty():
						_altars[n[1]] = world.altars.waiting.back()
			"A":
				var a: Dictionary = _altars.get(n[1], {})
				_altars.erase(n[1])
				if not a.is_empty():
					world.altars.waiting.erase(a)
					if is_instance_valid(a.node):
						(a.node as Node).queue_free()
			"q":
				_place_quest_npc(str(n[1]), str(n[2]), n[3])
			"Q":
				if _quest_npc != null and is_instance_valid(_quest_npc):
					_quest_npc.queue_free()
				_quest_npc = null
			"qp":
				_place_quest_prop(str(n[1]), n[2])
			"QP":
				if _quest_prop != null and is_instance_valid(_quest_prop):
					_quest_prop.queue_free()
				_quest_prop = null
			"emv":
				world.endless_mvp_client = float(n[1])
			"qm":
				world.quest.net_mark = n[1]
				world.quest.net_label = str(n[2])
				world.quest.net_head = n[3]
			"x":
				var pk: Dictionary = picks.get(n[1], {})
				picks.erase(n[1])
				if not pk.is_empty():
					world.pickups.erase(pk)
					if is_instance_valid(pk.node):
						(pk.node as Node).queue_free()



func _place_quest_prop(sprite: String, at: Variant) -> void :
	if not at is Vector3 or sprite == "" or not RoAssets.has_sprite(sprite):
		return
	if _quest_prop == null or not is_instance_valid(_quest_prop):
		var v: = RoVisual.new()
		world.run_root.add_child(v)
		v.setup(RoAssets.sprite([sprite]), Color(0.6, 0.45, 0.3), 36, 1.2)
		v.play(0)
		v.show_through(0.5)
		_quest_prop = v
		print("NET quest prop %s at %s" % [sprite, at])
	_quest_prop.global_position = at



func _place_quest_npc(sprite: String, shown: String, at: Vector3) -> void :
	if _quest_npc == null or not is_instance_valid(_quest_npc):
		var v: = RoVisual.new()
		world.run_root.add_child(v)


		var qd: Dictionary = world.quest.data if not world.quest.data.is_empty() else GameData.QUESTS.get(world.stage_id, {})
		var spr: RoSprite = QuestRun.npc_sprite_of(qd) if not qd.is_empty() else RoAssets.sprite([sprite])
		v.setup(spr, Color(1, 0.9, 0.7), 48, 1.0)
		v.play(RoVisual.MOB_IDLE)
		v.show_through(0.6)
		var l: = Label3D.new()
		l.text = shown
		l.font = World.RO_UI_FONT
		l.font_size = 26
		l.pixel_size = 0.012
		l.outline_size = 8
		l.outline_modulate = Color(0, 0, 0, 0.85)
		l.modulate = GameData.QUEST_COLOR
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.no_depth_test = true
		l.position = RoVisual.lift + Vector3(0, -0.25, 0)
		v.add_child(l)
		_quest_npc = v
	_quest_npc.global_position = Vector3(at.x, world.map.height_at(at), at.z)


func _on_snap_heroes(data: PackedByteArray) -> void :
	if not _live():
		return
	var b: = StreamPeerBuffer.new()
	b.data_array = data
	world.time = b.get_float()
	world.kills = b.get_32()
	var top: = b.get_u8()
	var paused: = (top & 1) != 0
	var place_arena: = (top & 8) != 0

	world.game_fast = (top & 2) != 0
	world.frenzy = (top & 4) != 0
	if paused != world.get_tree().paused:
		world.get_tree().paused = paused



	if paused != (_banner != null and _banner.visible):
		_pause_banner(paused)
	var n: = b.get_u8()
	for i in n:
		var x: = b.get_float()
		var z: = b.get_float()
		var dir: = b.get_u8()
		var action: = b.get_u8()
		var hp: = b.get_float()
		var max_hp: = b.get_float()
		var flags: = b.get_u8()
		var level: = b.get_u16()
		var job: = b.get_u8()
		var revive: = b.get_u8()
		var song_m: = b.get_u8()
		var beat: = b.get_u8()
		if i >= world.heroes.size():
			continue
		var h: Player = world.heroes[i]
		h.show_songs(song_m)
		if beat != (h.beat_n & 255):
			h.beat_n = beat
			h.set_beat(beat)
		h.revive_t = revive / 255.0 * GameData.COOP_REVIVE_TIME
		if h != world.player:
			h.level = level

			if job != 255 and h.job2.is_empty():
				h.song_book = 1 if job & 64 != 0 else 0
				h.job_change(job & 63)


		if is_finite(max_hp) and max_hp >= 1.0:
			h.max_hp = max_hp
			if h == world.player:
				h.host_max_hp = max_hp
		if is_finite(hp):
			h.hp = hp

		h.shield_src = "assumptio" if flags & 4 != 0 else ""
		var down: = flags & 1 != 0
		if down != h.downed:
			h.downed = down
			h.visual.play(RoVisual.PC_DEAD if down else RoVisual.PC_IDLE, not down, true)
		if h == world.player:


			h.net_action = action
			continue
		h.set_choosing(flags & 2 != 0)
		h.shield = maxf(h.shield, 1.0) if flags & 4 != 0 else 0.0
		h.update_glow()
		_hero_to[i] = Vector3(x, 0, z)
		if h.visual != null and not down:
			if h.visual.dir != dir:
				h.visual.dir = dir
				h.visual._refresh()



			var now: = Time.get_ticks_msec()
			var swinging: bool = h.visual.base_action >= RoVisual.PC_ATTACK and now - int(h.get_meta("swing_at", 0)) < PUPPET_SWING_MS
			if action != h.visual.base_action and not (swinging and action in [RoVisual.PC_IDLE, RoVisual.PC_READY]):
				if action >= RoVisual.PC_ATTACK:
					h.set_meta("swing_at", now)
				h.visual.play(action)


	var key: = b.get_u16() if b.get_position() + 2 <= data.size() else 0
	var here: = map_key(world.map.map_name) if world.map != null else 0
	var off: = place_arena != world._net_arena or (key != 0 and not place_arena and not world._net_arena and key != here)
	if not off:
		_place_off_at = 0
	elif _place_off_at == 0:
		_place_off_at = Time.get_ticks_msec()


var _banner: CanvasLayer




func _pause_banner(on: bool) -> void :
	if _banner == null:
		_banner = CanvasLayer.new()
		_banner.layer = 30
		_banner.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_banner)
		var shade: = ColorRect.new()
		shade.color = Color(0, 0, 0.05, 0.35)
		shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_banner.add_child(shade)
		var center: = CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_banner.add_child(center)
		var box: = PanelContainer.new()
		var st: = UiKit.panel_box(UiKit.PANEL, UiKit.GOLD, 10, 2)
		st.set_content_margin_all(18)
		box.add_theme_stylebox_override("panel", st)
		center.add_child(box)
		var col: = VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		box.add_child(col)
		var t: = UiKit.label(tr("Pausa"), 26, UiKit.GOLD, true)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(t)
		var s: = UiKit.label(tr("El líder del grupo pausó el juego"), 15, UiKit.MUTED)
		s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(s)
	_banner.visible = on


func _on_snap_mobs(data: PackedByteArray) -> void :
	if not _live():
		return
	var b: = StreamPeerBuffer.new()
	b.data_array = data
	var n: = b.get_u16()
	for i in n:
		var nid: = b.get_u16()
		var x: = b.get_16() / POS_Q
		var z: = b.get_16() / POS_Q
		var da: = b.get_u8()
		var hp: = b.get_u8()
		var e = mobs.get(nid)
		if e == null:
			if not _unknown.has(nid):
				_unknown[nid] = Time.get_ticks_msec()
			continue
		_mob_seen[nid] = Time.get_ticks_msec()
		if not is_instance_valid(e) or e.dead:
			continue
		_mob_to[nid] = Vector3(x, world.map.height_at(Vector3(x, 0, z)), z)
		e.hp = e.max_hp * hp / 255.0
		e.visual.dir = da & 7
		e.visual.play(da >> 3)






const LOOKS_ONLY: = ["H", "f", "v", "x", "p", "bo", "ob", "gz", "n", "rt", "e", "l"]


func _on_fx(list: Array) -> void :
	if not _live():
		return
	var hidden: = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED
	for ev in list:
		if ev is Array and not (ev as Array).is_empty():
			if hidden and str(ev[0]) in LOOKS_ONLY:
				continue
			world.net_fx(ev)

	world.fx_layer(0)





func _on_meter_th(taken: Dictionary, heals: Dictionary) -> void :
	if not _live():
		return
	world.meter_taken = (taken[my_slot] as Dictionary).duplicate(true) if taken.get(my_slot) is Dictionary else {}
	world.meter_heal = (heals[my_slot] as Dictionary).duplicate(true) if heals.get(my_slot) is Dictionary else {}


func _on_meter(all: Array, bosses: = {}) -> void :
	if not _live():
		return
	world.meter_hero.clear()
	for m in all:
		world.meter_hero.append(m if m is Dictionary else {})
	var mine: Dictionary = world.meter_hero[my_slot] if my_slot < world.meter_hero.size() else {}
	world.meter = mine
	world.meter_boss = bosses.get(my_slot, {})

	var st: = {"total": 0.0, "hits": 0, "crits": 0, "best": 0.0, "best_tag": ""}
	for k in mine:
		var m: Dictionary = mine[k]
		st.total += float(m.get("dmg", 0.0))
		st.hits += int(m.get("hits", 0))
		st.crits += int(m.get("crits", 0))
		if float(m.get("max", 0.0)) > st.best:
			st.best = float(m.max)
			st.best_tag = k
	world.meter_stats.merge(st, true)


func _on_hero_state(st: Dictionary) -> void :
	if _live():
		world.net_hero_state(st)


func _on_offer_choices(choices: Array) -> void :
	if _live():


		var same: = choices == offered
		offered = choices
		world.player.pending_levels = maxi(1, world.player.pending_levels)
		if same and world.menus.mode() == "level_up":
			return

		if bool(Save.setting("endless_auto_pick", false)) and not world.menus.is_open() and not world.menus.auto_pick:
			world.auto_choose_client(choices)
			return



		var m: = world.menus.mode()
		var chained: = chain_until > 0 and m == "level_up_pick"
		chain_until = 0
		if chained:
			world.menus.show_level_up(choices, true)
		elif m == "level_up" or ( not world.menus.is_open() and not bool(Save.setting("hold_levels", false))):
			world.menus.show_level_up(choices)


func _on_offer_job() -> void :

	if _live() and ( not world.menus.is_open() or world.menus.mode() in ["level_up", "level_up_pick"]):
		chain_until = 0
		world.menus.show_job_change()



func send_choice(index: int) -> void :
	send(1, "pick_choice", [index])


func send_job(path: int) -> void :
	send(1, "pick_job", [path, world.player.book_for_job()])


func _on_loot_offer(items: Array, tier: int) -> void :
	if not _live():
		return
	_loot = LootRoll.make(items, tier, world.player.position)


	if not world.menus.auto_pick:
		_loot.preset(world.player, func(id: String) -> bool: return Save.storage().any( func(st): return str(st.id) == id))
	if _loot_panel != null and is_instance_valid(_loot_panel):
		_loot_panel.queue_free()
	_loot_panel = LootPanel.new()
	world.hud.add_child(_loot_panel)
	_loot_panel.setup(world, _loot)
	_loot_panel.toggled.connect( func(i: int, on: bool): send(1, "loot_pick", [i, on, false]))
	_loot_panel.passing_all.connect( func(): send(1, "loot_pick", [-2, false, false]))
	if not world.menus.auto_pick:
		for i in _loot.items.size():
			send(1, "loot_pick", [i, _loot.wants(world.player.slot, i), false])
	_loot_panel.picked.connect( func(): send(1, "loot_pick", [-1, false, true]))
	if world.menus.auto_pick:
		_loot.auto_pick(world.player)
		for i in _loot.picks.get(world.player.slot, []):
			send(1, "loot_pick", [i, true, false])
		send(1, "loot_pick", [-1, false, true])


func _on_loot_result(results: Array) -> void :
	if not _live() or _loot_panel == null or not is_instance_valid(_loot_panel):
		return
	_loot_panel.show_rolls(results)
	_loot_panel = null
	_loot = null


func _on_portal(at: Vector3, caption: String, color: Color) -> void :
	if not _live():
		return
	world.raid.color = color
	if at == Vector3.INF:
		world.raid._clear_portal()
	else:
		world.raid._spawn_portal(at, caption)



func karma(value: int) -> void :
	if recording():
		_to_run("karma", [value])



func karma_portal(at: Vector3, side: String) -> void :
	if recording():
		_to_run("kportal", [at, side])



func sky(at: float, kind: String) -> void :
	if recording():
		_to_run("sky", [at, kind])


func _on_sky(at: float, kind: String) -> void :
	if _live():
		world.weather.apply(at, kind)


func _on_karma(value: int) -> void :
	if _live():
		world.karma.value = value


func _on_kportal(at: Vector3, side: String) -> void :
	if not _live():
		return
	if at == Vector3.INF:
		world.raid._clear_kportal()
	else:
		world.raid._spawn_kportal(at, side)


func _on_arena_in(arena: String, center: Vector3, radius: float, at: Vector3) -> void :
	if _live():
		world.net_arena_in(arena, center, radius, at)


func _on_arena_out(at: Vector3) -> void :
	if _live():
		world.net_arena_out(at)






func ask_tower(floor: int) -> void :
	tower_party.clear()
	for id in ready_peers():
		tower_party[id] = {"state": "asking"}
		send(id, "tower_ask", [floor])
	tower_changed.emit()



func cancel_tower() -> void :
	for id in tower_party:
		if peers.has(id):
			send(id, "tower_cancel")
	tower_party.clear()



func tower_ready() -> bool:
	for id in ready_peers():
		if str(tower_party.get(id, {}).get("state", "")) != "ready":
			return false
	return true




func tower_floors() -> Array:
	var out: = Save.tower_checkpoints()
	for id in ready_peers():
		var theirs: Array = peers[id].get("profile", {}).get("tower_cps", [1])
		out = out.filter( func(f): return theirs.has(f))
	return out if not out.is_empty() else [1]



func _on_tower_ask(floor: int) -> void :
	if not is_client() or _in_run:
		return
	_tower_pick.clear()
	if Save.tower_builds().is_empty():
		send(1, "tower_pick", [-2, {}, {}])

	if floor < 0:
		world.menus.show_festival_join()
	else:
		world.menus.show_tower_join(floor)



func pick_tower(index: int) -> void :
	var builds: = Save.tower_builds()
	if index < 0 or index >= builds.size():
		_tower_pick.clear()
		send(1, "tower_pick", [-1, {}, {}])
		return
	var b: Dictionary = builds[index]
	_tower_pick = {"index": index, "build": b.duplicate(true)}
	send(1, "tower_pick", [index, b, Player.profile_of(str(b.get("class", my_class)))])



func take_tower_pick() -> Dictionary:
	if _tower_pick.is_empty():
		return {}
	var want: Dictionary = _tower_pick.build
	var i: = int(_tower_pick.index)
	var builds: = Save.tower_builds()
	if i >= builds.size() or var_to_str(builds[i]) != var_to_str(want):
		i = builds.map( func(b): return var_to_str(b)).find(var_to_str(want))
	_tower_pick.clear()
	return Save.take_tower_build(i) if i >= 0 else {}


func _on_tower_pick(index: int, build: Dictionary, profile: Dictionary) -> void :
	var id: = _sender
	if not tower_party.has(id):
		return
	if index >= 0 and GameData.CLASSES.has(str(build.get("class", ""))):
		tower_party[id] = {"state": "ready", "build": build, "profile": profile if profile.has("look") else peers[id].get("profile", {})}
	else:
		tower_party[id] = {"state": "none" if index == -2 else "no"}
	tower_changed.emit()


func _on_tower_cancel() -> void :
	_tower_pick.clear()
	if not _in_run:
		world.menus.tower_called_off()





func ask_festival() -> void :
	ask_tower(-1)



func festival_pick() -> Dictionary:
	if _tower_pick.is_empty():
		return {}
	var b: Dictionary = (_tower_pick.build as Dictionary).duplicate(true)
	_tower_pick.clear()
	return b



func festival_event(ev: Array) -> void :
	if is_host():
		_to_run("fest", [ev])


func _on_fest(ev: Array) -> void :
	if _live() and world.festival != null and is_instance_valid(world.festival):
		world.festival.net_event(ev)



func tower_event(ev: Array) -> void :
	if is_host():
		_to_run("tower", [ev])



func tower_event_to(h: Player, ev: Array) -> void :
	for id in _run_peers():
		if _remote_hero(id) == h:
			send(id, "tower", [ev])


func _on_tower(ev: Array) -> void :
	if _live() and world.tower != null:
		world.tower.net_event(ev)



func send_tower_bless(id: String) -> void :
	send(1, "tower_bless", [id])


func _on_tower_spin(id: String) -> void :
	var h: = _remote_hero(_sender)
	if h != null and world.tower != null:
		world.tower._events.remote_spin(h, id)


func _on_tower_camp() -> void :
	if world.tower != null and _remote_hero(_sender) != null:
		world.tower.member_at_camp()


func _on_tower_bless(id: String) -> void :
	var h: = _remote_hero(_sender)
	if h != null and world.tower != null:
		world.tower.take_blessing(h, id)



func _on_tower_pw(power: float) -> void :
	var h: = _remote_hero(_sender)
	if h != null:
		h.tower_power = clampf(power, 0.0, 10.0)
		h.recompute()


func _on_run_end(victory: bool, result: Dictionary) -> void :
	if not _live():
		return
	_in_run = false
	_pause_banner(false)
	world.running = false
	world.get_tree().paused = false
	if _loot_panel != null and is_instance_valid(_loot_panel):
		_loot_panel.queue_free()


	if not world.training:
		Save.add_zeny(int(result.get("zeny", 0)))
	result["victory"] = victory

	var d = result.get("death_by", {})
	if bool(result.get("fell", false)) and d is Dictionary and not (d as Dictionary).is_empty():
		world.player.fell = true
		world.player.death_by = {"by": str(d.get("by", "")).left(48), "what": str(d.get("what", "")).left(64), 
			"sprite": str(d.get("sprite", "")) if GameData.MONSTERS.has(str(d.get("sprite", ""))) else ""}
	var end: = world.net_end_result(result)


	var climb: = world.tower
	if climb != null and climb.best > 0:
		end["record"] = {"floor": climb.best, "online": Leaderboard.enabled()}
		if climb.hel != null:
			world.board.submit_hel(world.player.class_id, climb.best, world.time, world.oath_points(), world.player.record_look(), true)
		else:
			world.board.submit_tower(world.player.class_id, climb.best, world.time, world.player.record_look(), true)
		_send_hello()
	world.board.log_run(world, victory)
	world.menus.show_end(victory, end)
	print("NET run over: victory=%s level=%d zeny=%d class_xp=%d class_level=%d" % [victory, int(result.get("level", 0)), 
		int(result.get("zeny", 0)), int(end.best.get("class_xp", 0)), int(end.best.get("class_level", 0))])
	_quit_if_test()
