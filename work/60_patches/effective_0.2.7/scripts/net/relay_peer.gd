extends MultiplayerPeerExtension










var conn
var owns: = true
var _server: = false

var _server_id: = 0
var _status: = CONNECTION_CONNECTING
var _target: = 0
var _mode: = TRANSFER_MODE_RELIABLE
var _channel: = 0
var _refuse: = false

var _known: = {}

var _pending: Array = []

var _in: Array = []
var _closed: = false


func _init(p_conn = null, p_owns: = true) -> void :
	if p_conn == null:
		return
	conn = p_conn
	owns = p_owns
	conn.news.connect(_on_news)
	if conn.state == "in" and conn.is_server():


		_server = true
		_server_id = conn.my_id
		_status = CONNECTION_CONNECTED
		for id in conn.members:
			if int(id) != conn.my_id:
				_pending.append(int(id))


func _on_news(m: Dictionary) -> void :
	if _closed:
		return
	var id: = int(m.get("id", 0))
	match str(m.get("t", "")):
		"join":
			if _server and _status == CONNECTION_CONNECTED:
				_add(id)
		"left":
			if _server:
				_remove(id)
			elif id == _server_id:
				_remove(1)



				if owns:
					_status = CONNECTION_DISCONNECTED
		"owner":


			if _server and id != conn.my_id:
				for k in _known.keys():
					_remove(int(k))
			elif not _server and id != _server_id:
				_remove(1)


func _add(id: int) -> void :
	if id == 0 or _known.has(id):
		return
	_known[id] = true
	peer_connected.emit(id)


func _remove(id: int) -> void :
	if not _known.has(id):
		return
	_known.erase(id)
	peer_disconnected.emit(id)


func _poll() -> void :
	if _closed or conn == null:
		return
	conn.poll()
	if _status == CONNECTION_CONNECTING:
		if conn.state == "in":
			_status = CONNECTION_CONNECTED
			_server = conn.is_server()
			_server_id = conn.server_id
			if _server:
				for id in conn.members:
					if int(id) != conn.my_id:
						_pending.append(int(id))
			else:
				_add(1)
		elif conn.state == "closed":
			_status = CONNECTION_DISCONNECTED
			return
	for id in _pending:
		if conn.members.has(id):
			_add(id)
	_pending.clear()
	for e in conn.inbox:
		var from: = int(e[0])
		if _server:
			if _known.has(from):
				_in.append(e)
		elif from == _server_id and _known.has(1):
			_in.append([1, e[1]])
	conn.inbox.clear()
	if _status == CONNECTION_CONNECTED and conn.state == "closed":
		for k in _known.keys():
			_remove(int(k))
		_status = CONNECTION_DISCONNECTED


func _get_available_packet_count() -> int:
	return _in.size()


func _get_packet_peer() -> int:
	return int(_in[0][0]) if not _in.is_empty() else 0


func _get_packet_channel() -> int:
	return 0


func _get_packet_mode() -> TransferMode:
	return TRANSFER_MODE_RELIABLE


func _get_packet_script() -> PackedByteArray:
	if _in.is_empty():
		return PackedByteArray()
	return _in.pop_front()[1]


func _put_packet_script(buf: PackedByteArray) -> Error:
	if _status != CONNECTION_CONNECTED or conn == null:
		return ERR_UNCONFIGURED
	var targets: = PackedInt32Array()
	if _server:
		if _target > 1:
			targets.append(_target)
		elif _target < 0:
			for id in _known:
				if int(id) != - _target:
					targets.append(int(id))
			if targets.is_empty():
				return OK
		elif _target == 1:
			return OK
	else:
		targets.append(_server_id)
	conn.send(targets, buf, _mode != TRANSFER_MODE_RELIABLE)
	return OK


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
	if _server:
		return 1
	return conn.my_id if conn != null and conn.my_id != 0 else 0


func _is_server() -> bool:
	return _server


func _is_server_relay_supported() -> bool:
	return true


func _get_connection_status() -> ConnectionStatus:
	return _status


func _set_refuse_new_connections(p_enable: bool) -> void :
	_refuse = p_enable


func _is_refusing_new_connections() -> bool:
	return _refuse


func _disconnect_peer(p_peer: int, _p_force: bool) -> void :
	if _server and conn != null:
		conn.send_json({"t": "kick", "id": p_peer})
		_remove(p_peer)


func _close() -> void :
	if _closed:
		return
	_closed = true
	_status = CONNECTION_DISCONNECTED
	_known.clear()
	_in.clear()
	if conn != null:
		if conn.news.is_connected(_on_news):
			conn.news.disconnect(_on_news)
		if owns:
			conn.close()
