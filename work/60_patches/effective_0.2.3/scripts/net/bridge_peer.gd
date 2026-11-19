extends MultiplayerPeerExtension








var native: MultiplayerPeer
var relay: MultiplayerPeer

var _by_relay: = {}
var _native: = {}


const MAX_GUESTS: = 3
var _target: = 0
var _mode: = TRANSFER_MODE_RELIABLE
var _channel: = 0
var _refuse: = false


func _init(p_native: MultiplayerPeer = null, p_relay: MultiplayerPeer = null) -> void :
	if p_native == null:
		return
	native = p_native
	relay = p_relay
	native.peer_connected.connect( func(id: int):
		if _native.size() + _by_relay.size() >= MAX_GUESTS:
			native.disconnect_peer.call_deferred(id, true)
			return
		_native[id] = true
		peer_connected.emit(id))
	native.peer_disconnected.connect( func(id: int):
		if _native.erase(id):
			peer_disconnected.emit(id))
	relay.peer_connected.connect( func(id: int):
		if _native.size() + _by_relay.size() >= MAX_GUESTS:
			relay.disconnect_peer.call_deferred(id, true)
			return
		_by_relay[id] = true
		peer_connected.emit(id))
	relay.peer_disconnected.connect( func(id: int):
		if _by_relay.erase(id):
			peer_disconnected.emit(id))



func _head() -> MultiplayerPeer:
	return native if native.get_available_packet_count() > 0 else relay


func _poll() -> void :
	native.poll()
	relay.poll()


func _get_available_packet_count() -> int:
	return native.get_available_packet_count() + relay.get_available_packet_count()


func _get_packet_peer() -> int:
	return _head().get_packet_peer()


func _get_packet_channel() -> int:
	return _head().get_packet_channel()


func _get_packet_mode() -> TransferMode:
	return _head().get_packet_mode()


func _get_packet_script() -> PackedByteArray:
	return _head().get_packet()


func _put_packet_script(buf: PackedByteArray) -> Error:
	if _target > 0:
		var side: = relay if _by_relay.has(_target) else native
		_aim(side, _target)
		return side.put_packet(buf)

	var err: = OK
	if native.get_connection_status() == CONNECTION_CONNECTED:
		_aim(native, _target)
		err = native.put_packet(buf)
	if not _by_relay.is_empty():
		_aim(relay, _target)
		relay.put_packet(buf)
	return err


func _aim(side: MultiplayerPeer, target: int) -> void :
	side.transfer_mode = _mode
	side.transfer_channel = _channel
	side.set_target_peer(target)


func _get_max_packet_size() -> int:
	return 1 << 20


func _set_target_peer(p_peer: int) -> void :
	_target = p_peer


func _get_transfer_channel() -> int:
	return _channel


func _set_transfer_channel(p_channel: int) -> void :
	_channel = p_channel


func _get_transfer_mode() -> TransferMode:
	return _mode


func _set_transfer_mode(p_mode: TransferMode) -> void :
	_mode = p_mode


func _get_unique_id() -> int:
	return 1


func _is_server() -> bool:
	return true


func _is_server_relay_supported() -> bool:
	return true


func _get_connection_status() -> ConnectionStatus:
	return native.get_connection_status()


func _set_refuse_new_connections(p_enable: bool) -> void :
	_refuse = p_enable
	native.refuse_new_connections = p_enable
	relay.refuse_new_connections = p_enable


func _is_refusing_new_connections() -> bool:
	return _refuse


func _disconnect_peer(p_peer: int, p_force: bool) -> void :
	if _by_relay.has(p_peer):
		relay.disconnect_peer(p_peer, p_force)
	else:
		native.disconnect_peer(p_peer, p_force)


func _close() -> void :
	native.close()
	relay.close()
