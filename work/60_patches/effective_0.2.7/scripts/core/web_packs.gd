extends Node
















signal progress(done: int, total: int)

const INDEX: = "res://web_packs.json"
const DIR: = "/tmp/midgard_packs/"
const TRIES: = 3



const KEEP: = {"map": 6, "bgm": 4, "late": 99}


const KEEP_TOUCH: = {"map": 2, "bgm": 2, "late": 99}
const TABLES: = {"map": "maps", "bgm": "bgm", "late": "late"}

const LATE_NEEDED: = ["late:models", "late:mobs"]

var _index: = {}
var _base: = ""
var _mounted: = {}

var _recent: Array[String] = []

var _loading: = {}
var _queue: Array = []
var _queue_busy: = false


var _http: HTTPRequest
var _done_bytes: = 0
var _total_bytes: = 0

var error: = ""


var blocking: = 0


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if FileAccess.file_exists(INDEX):
		var d = JSON.parse_string(FileAccess.get_file_as_string(INDEX))
		if d is Dictionary:
			_index = d

	for m in _index.get("maps", {}):
		RoAssets.web_maps[str(m)] = true
	RoAssets.web_late = func(key: String) -> bool:
		if ready_now(key):
			return false
		prefetch([key])
		return true
	RoAssets.web_now = mount_now

	var late: Array = LATE_NEEDED.duplicate()
	for k in _index.get("late", {}):
		if not late.has("late:" + str(k)):
			late.append("late:" + str(k))
	prefetch.call_deferred(late)

	_base = str(_index.get("url", ""))
	if _base == "" and OS.has_feature("web"):
		_base = str(JavaScriptBridge.eval("window.MIDGARD_PACKS || new URL('packs/', document.baseURI).href", true))
	DirAccess.make_dir_recursive_absolute(DIR)


func _process(_delta: float) -> void :
	if _http != null and is_instance_valid(_http) and _total_bytes > 0:
		progress.emit(_done_bytes + _http.get_downloaded_bytes(), _total_bytes)


func _entry(key: String) -> Dictionary:
	var kind: = key.get_slice(":", 0)
	var name: = key.get_slice(":", 1)
	var table: Dictionary = _index.get(str(TABLES.get(kind, "")), {})
	return table.get(name, {})




func ready_now(key: String) -> bool:
	return _mounted.has(key) or _entry(key).is_empty()


func missing(keys: Array) -> Array:
	var out: = []
	for k in keys:
		if not ready_now(str(k)) and not out.has(str(k)):
			out.append(str(k))
	return out


func size_of(keys: Array) -> int:
	var n: = 0
	for k in missing(keys):
		n += int(_entry(k).get("n", 0))
	return n




func ensure(keys: Array) -> bool:
	for k in keys:
		_touch(str(k))
	var need: = missing(keys)
	error = ""
	_done_bytes = 0
	_total_bytes = size_of(need)
	for k in need:
		if not await _fetch(k):
			error = k
			_total_bytes = 0
			return false
		_done_bytes += int(_entry(k).get("n", 0))
	_total_bytes = 0
	return true



func prefetch(keys: Array) -> void :
	for k in missing(keys):
		if not _queue.has(k):
			_queue.append(k)
	if not _queue_busy:
		_run_queue()


func _run_queue() -> void :
	_queue_busy = true
	while not _queue.is_empty():
		var k: = str(_queue.pop_front())
		await _fetch(k)
	_queue_busy = false


func _fetch(key: String) -> bool:
	if ready_now(key):
		return true

	while _loading.has(key):
		await get_tree().process_frame
	if ready_now(key):
		return true
	_loading[key] = true
	var e: = _entry(key)
	var path: = DIR + str(e.f)
	var ok: = false
	for i in TRIES:
		var http: = HTTPRequest.new()
		http.timeout = 300.0
		http.accept_gzip = false
		add_child(http)
		if _total_bytes > 0:
			_http = http
		var started: = http.request(_base + str(e.f).uri_encode())
		var res: Array = [HTTPRequest.RESULT_CANT_CONNECT, 0] if started != OK else await http.request_completed
		http.queue_free()
		if _http == http:
			_http = null


		if int(res[0]) == HTTPRequest.RESULT_SUCCESS and int(res[1]) == 200 and res.size() > 3 and (res[3] as PackedByteArray).size() == int(e.get("n", -1)):
			var f: = FileAccess.open(path, FileAccess.WRITE)
			if f != null:
				f.store_buffer(res[3])
				f.close()
				ok = true
				break
		await get_tree().create_timer(1.5 * (i + 1), true, false, true).timeout
	if ok:
		ok = _mount(key, path)
	_loading.erase(key)
	return ok


func _mount(key: String, path: String) -> bool:
	if not ProjectSettings.load_resource_pack(path):
		push_error("WebPacks: can't mount %s" % path)
		return false


	var uids_path: = "res://web_uids/%s.json" % path.get_file().get_slice(".", 0)
	if FileAccess.file_exists(uids_path):
		var uids = JSON.parse_string(FileAccess.get_file_as_string(uids_path))
		if uids is Dictionary:
			for u in uids:
				var id: = ResourceUID.text_to_id(str(u))
				if id != ResourceUID.INVALID_ID and not ResourceUID.has_id(id):
					ResourceUID.add_id(id, str(uids[u]))
	_mounted[key] = true
	_touch(key)
	_trim(key.get_slice(":", 0))
	return true


func _touch(key: String) -> void :
	if _mounted.has(key):
		_recent.erase(key)
		_recent.append(key)




func _trim(kind: String) -> void :
	var mine: = _recent.filter( func(k: String) -> bool: return k.get_slice(":", 0) == kind)
	while mine.size() > int((KEEP_TOUCH if MouseWalk.touch() else KEEP).get(kind, 4)):
		var old: String = mine.pop_front()
		_recent.erase(old)
		_mounted.erase(old)
		DirAccess.remove_absolute(DIR + str(_entry(old).get("f", "")))




func mount_now(key: String) -> bool:
	if ready_now(key) or not OS.has_feature("web"):
		_touch(key)
		return true
	var e: = _entry(key)
	var url: = _base + str(e.f).uri_encode()
	print("WebPacks: blocking fetch of %s" % key)
	blocking += 1
	var bytes = JavaScriptBridge.eval("""(function(url) {
		try {
			var x = new XMLHttpRequest();
			x.open('GET', url, false);
			x.overrideMimeType('text/plain; charset=x-user-defined');
			x.send();
			if (x.status !== 200) return null;
			var t = x.responseText, n = t.length, a = new Uint8Array(n);
			for (var i = 0; i < n; i++) a[i] = t.charCodeAt(i) & 255;
			return a.buffer;
		} catch (e) { return null; }
	})('%s')""" %url, true)
	if not bytes is PackedByteArray or (bytes as PackedByteArray).is_empty():
		push_error("WebPacks: blocking fetch failed for %s" % key)
		return false
	var path: = DIR + str(e.f)
	var f: = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(bytes)
	f.close()
	return _mount(key, path)
