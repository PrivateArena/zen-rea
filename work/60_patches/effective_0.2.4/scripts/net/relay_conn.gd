extends RefCounted











signal news(msg: Dictionary)



const PING_MS: = 5000

const FRAME_MAX: = 256 * 1024


const DROP_AT: = 512 * 1024

var ws: = WebSocketPeer.new()
var url: = ""

var state: = "connecting"


var error: = ""

var error_version: = ""
var my_id: = 0

var server_id: = 0


var mig: = false

var members: = {}

var inbox: Array = []

var away: = false

var _out: = PackedByteArray()
var _flush_due: = false
var _ping_at: = 0
var _polled: = -1
var _opened: = false
var _tls_tried: = false


func open(p_url: String) -> void :
	url = p_url
	_connect(null)


func _connect(tls: TLSOptions) -> void :
	ws = WebSocketPeer.new()
	ws.inbound_buffer_size = 1 << 22
	ws.outbound_buffer_size = 1 << 22
	ws.max_queued_packets = 8192
	var err: = ws.connect_to_url(url, tls) if tls != null else ws.connect_to_url(url)
	if err != OK:
		state = "closed"
		error = "connect"



func poll() -> void :
	var f: = Engine.get_process_frames()
	if f == _polled or state == "closed":
		return
	_polled = f
	ws.poll()
	var st: = ws.get_ready_state()
	if st == WebSocketPeer.STATE_OPEN:
		_opened = true
		var now: = Time.get_ticks_msec()
		if now - _ping_at > PING_MS:
			_ping_at = now
			ws.send_text("p")
		while ws.get_available_packet_count() > 0:
			var pkt: = ws.get_packet()
			if ws.was_string_packet():
				var text: = pkt.get_string_from_utf8()
				if text == "q":
					continue
				var m = JSON.parse_string(text)
				if m is Dictionary:
					_on_news(m)
			else:
				_on_data(pkt)
	elif st == WebSocketPeer.STATE_CLOSED:


		if not _opened and not _tls_tried and url.begins_with("wss:") and not OS.has_feature("web"):
			_tls_tried = true
			var tls: TLSOptions = Leaderboard.system_tls()
			if tls != null:
				_connect(tls)
				return
		var was: = state
		state = "closed"
		if error == "":
			error = "closed" if _opened else "connect"
		if was != "closed":
			news.emit({"t": "lost", "code": ws.get_close_code()})


func _on_news(m: Dictionary) -> void :
	match str(m.get("t", "")):
		"in":
			my_id = int(m.get("id", 0))
			server_id = int(m.get("server", 0))
			mig = bool(m.get("mig", false))
			members.clear()
			for e in m.get("members", []):
				if e is Dictionary:
					members[int(e.get("id", 0))] = bool(e.get("native", true))
			state = "in"
		"join":
			members[int(m.get("id", 0))] = bool(m.get("native", true))
		"left":
			members.erase(int(m.get("id", 0)))
		"owner":
			server_id = int(m.get("id", 0))
		"away":
			away = bool(m.get("on", false))
		"err":
			error = str(m.get("e", ""))
			error_version = str(m.get("v", ""))
		"closed":
			error = "closed"
	news.emit(m)


func _on_data(pkt: PackedByteArray) -> void :
	var o: = 0
	var n: = pkt.size()
	while o + 8 <= n:
		var from: = pkt.decode_s32(o)
		var ln: = pkt.decode_u32(o + 4)
		if o + 8 + ln > n:
			break
		inbox.append([from, pkt.slice(o + 8, o + 8 + ln)])
		o += 8 + ln




func send(targets: PackedInt32Array, payload: PackedByteArray, droppable: = false) -> void :
	if state != "in":
		return
	if droppable and ws.get_current_outbound_buffered_amount() > DROP_AT:
		return
	var head: = PackedByteArray()
	head.resize(2 + targets.size() * 4 + 4)
	head[0] = 1 if droppable else 0
	head[1] = targets.size()
	for i in targets.size():
		head.encode_s32(2 + i * 4, targets[i])
	head.encode_u32(2 + targets.size() * 4, payload.size())
	_out.append_array(head)
	_out.append_array(payload)
	if _out.size() >= FRAME_MAX:
		flush()
	elif not _flush_due:
		_flush_due = true
		flush.call_deferred()


func flush() -> void :
	_flush_due = false
	if _out.is_empty() or state != "in":
		_out.clear()
		return
	ws.send(_out)
	_out = PackedByteArray()



func send_json(m: Dictionary) -> void :
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	flush()
	ws.send_text(JSON.stringify(m))


func close() -> void :
	if state == "closed":
		return
	flush()
	state = "closed"
	if error == "":
		error = "closed"
	ws.close(1000, "bye")
	ws.poll()


func is_server() -> bool:
	return my_id != 0 and my_id == server_id



func wait_in(tree: SceneTree, seconds: = 12.0) -> bool:
	var t0: = Time.get_ticks_msec()
	while state == "connecting" and Time.get_ticks_msec() - t0 < seconds * 1000.0:
		await tree.process_frame
		poll()
	if state == "connecting":
		error = "connect"
		ws.close()
		state = "closed"
	return state == "in"
