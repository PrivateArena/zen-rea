extends Node
















































const MANIFEST_URL: = "https://updates.midgardsurvivors.com/manifest.json"
const MANIFEST_FALLBACK: = "https://raw.githubusercontent.com/Gon-Analista/midgard-survivors-updates/main/manifest.json"
const DIR: = "user://patches"
const STATE: = DIR + "/state.json"
const MANIFEST_TIMEOUT: = 8.0

const PATCH_KEY: = "MgjDAvDBYHMthDcux0-PQvBk7Afl0U-V"


var version: = ""
var _base: = ""

var _eff_base: = ""
var _state: = {}
var _http: HTTPRequest
var _layer: CanvasLayer

var _win: Control
var _was_paused: = false

var _parts: Array = []
var _part: = 0
var _done_bytes: = 0
var _total: = 0

var _bridging: = false

var _source: = MANIFEST_URL


func _init() -> void :
	_base = str(ProjectSettings.get_setting("application/config/version", "0"))
	version = _base
	_eff_base = _base



	if OS.has_feature("web") and FileAccess.file_exists("res://web_version.txt"):
		var stamped: = FileAccess.get_file_as_string("res://web_version.txt").strip_edges()
		if stamped != "":
			version = stamped
	if OS.has_feature("web"):
		_web_boot()
	if not _enabled():
		return
	_state = _read_state()
	if str(_state.get("base", "")) != _base:

		_clear_patches()
		_state = {}
		return


	var bridge: Dictionary = _state.get("bridge", {}) if _state.get("bridge") is Dictionary else {}
	if not bridge.is_empty():
		var bfile: = DIR.path_join(str(bridge.get("file", "")))
		if FileAccess.file_exists(bfile) and ProjectSettings.load_resource_pack(bfile):
			_eff_base = str(bridge.get("version", _base))
			version = _eff_base
		else:
			push_error("Updater: no se pudo montar el puente %s" % bfile)
			_clear_patches()
			_state = {}
			return
	var file: = DIR.path_join(str(_state.get("file", "")))
	if _state.has("file") and FileAccess.file_exists(file):
		if ProjectSettings.load_resource_pack(file):
			version = str(_state.get("version", _base))
		else:
			push_error("Updater: no se pudo montar el parche %s" % file)







const WEB_DIR: = "/tmp/midgard_packs/"

var web_boot_fetched: = 0


func _web_boot() -> void :
	if not FileAccess.file_exists("res://web_packs.json"):
		return
	var index = JSON.parse_string(FileAccess.get_file_as_string("res://web_packs.json"))
	if not index is Dictionary:
		return
	var base: = str(index.get("url", ""))
	if base == "":
		base = str(JavaScriptBridge.eval("window.MIDGARD_PACKS || new URL('packs/', document.baseURI).href", true))
	DirAccess.make_dir_recursive_absolute(WEB_DIR)
	for e in index.get("boot", []):
		var file: = WEB_DIR + str(e.get("f", ""))
		if not FileAccess.file_exists(file):
			web_boot_fetched += 1
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
			})('%s')""" %(base + str(e.get("f", "")).uri_encode()), true)
			if bytes is PackedByteArray and not (bytes as PackedByteArray).is_empty():
				var f: = FileAccess.open(file, FileAccess.WRITE)
				if f != null:
					f.store_buffer(bytes)
					f.close()
		if not ProjectSettings.load_resource_pack(file):
			push_error("Updater: no se pudo montar %s" % file)
			continue

		var uids_path: = "res://web_uids/%s.json" % str(e.get("f", "")).get_slice(".", 0)
		var uids = JSON.parse_string(FileAccess.get_file_as_string(uids_path)) if FileAccess.file_exists(uids_path) else null
		if uids is Dictionary:
			for u in uids:
				var id: = ResourceUID.text_to_id(str(u))
				if id != ResourceUID.INVALID_ID and not ResourceUID.has_id(id):
					ResourceUID.add_id(id, str(uids[u]))


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not _enabled():
		return
	_http = HTTPRequest.new()
	_http.timeout = MANIFEST_TIMEOUT
	add_child(_http)
	_ask_manifest()


func _ask_manifest() -> void :
	_http.request_completed.connect(_on_manifest, CONNECT_ONE_SHOT)
	if _http.request(_manifest_url()) != OK:
		_http.request_completed.disconnect(_on_manifest)
		push_warning("Updater: no se pudo consultar %s" % _manifest_url())





func _enabled() -> bool:
	if OS.has_feature("editor") or OS.has_feature("web"):
		return false
	if not OS.has_feature("pc") and not OS.has_feature("android"):
		return false




	if FileAccess.file_exists(OS.get_executable_path().get_base_dir().path_join("coop_preview.txt")):
		print("Updater: build de prueba del cooperativo, sin parches")
		return false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--") and a != "--update-url" and a != "--lang":
			return false
	return true


func _manifest_url() -> String:
	var args: = OS.get_cmdline_user_args()
	var i: = args.find("--update-url")
	return args[i + 1] if i >= 0 and i + 1 < args.size() else _source


func _on_manifest(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:

		if _source != MANIFEST_FALLBACK and _manifest_url() == _source:
			_source = MANIFEST_FALLBACK
			push_warning("Updater: %s no respondió (%d/%d), probando %s" % [MANIFEST_URL, result, code, _source])

			_ask_manifest.call_deferred()
		return
	var manifest = JSON.parse_string(body.get_string_from_utf8())
	if not manifest is Dictionary:
		push_warning("Updater: manifest.json inválido")
		return
	var section: = _section()
	if section != "":



		var mine = manifest.get(section)
		if not mine is Dictionary:
			return
		var shared_notes = manifest.get("notes")
		manifest = (mine as Dictionary).duplicate()
		if shared_notes is Array:
			manifest["notes"] = shared_notes
	var patch: Dictionary = manifest.get("patch", {}) if manifest.get("patch") is Dictionary else {}

	var notes: Array = []
	if manifest.get("notes") is Array:
		for v in manifest.notes:
			if v is Dictionary and _newer(str(v.get("version", "")), version):
				notes.append(v)
	var mbase: = str(manifest.get("base", ""))
	if mbase != _eff_base:

		if not _newer(mbase, _eff_base):
			return
		if version == mbase and _state.has("file") and not _state.has("bridge"):




			_adopt_bridge(mbase)
		else:
			var legacy: Dictionary = manifest.get("legacy", {}) if manifest.get("legacy") is Dictionary else {}
			var up = legacy.get(_base)
			if up is Dictionary and str(up.get("version", "")) == mbase:

				_open_window(tr("¡Actualización disponible!"), "v%s  →  v%s   ·   %s" % [version, mbase, 
					String.humanize_size(int(up.get("size", 0)))], notes, false)
				_win.accepted.connect( func() -> void : _download(up, true))
				_win.declined.connect(_close)
			else:
				_show_new_build(str(manifest.get("page", "")), mbase, notes)
			return
	if patch.is_empty() or not _newer(str(patch.get("version", "")), version):
		return

	_open_window(tr("¡Actualización disponible!"), "v%s  →  v%s   ·   %s" % [version, str(patch.get("version", "")), 
		String.humanize_size(int(patch.get("size", 0)))], notes, false)
	_win.accepted.connect( func() -> void : _download(patch))
	_win.declined.connect(_close)






func _section() -> String:
	if OS.has_feature("android"):
		return "android"
	if OS.has_feature("macos"):
		return "mac"
	return ""




func _adopt_bridge(build: String) -> void :
	_state = {"base": _base, "bridge": {"version": build, "file": str(_state.get("file", ""))}, "version": build}
	_eff_base = build
	var f: = FileAccess.open(STATE, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(_state, "\t"))
		f.close()


func _download(patch: Dictionary, as_bridge: = false) -> void :
	var file_name: = str(patch.get("file", "")).get_file().get_basename() + ".pck"
	if file_name == ".pck":
		return
	DirAccess.make_dir_recursive_absolute(DIR)
	var tmp: = DIR.path_join(file_name + ".part")
	_win.start_progress()
	_win.set_status(tr("Actualizando a la versión %s…") % patch.get("version", ""))
	_http.timeout = 0.0
	_parts = patch.get("parts", []) if patch.get("parts") is Array and not patch.parts.is_empty() else [patch.file]
	_part = 0
	_done_bytes = 0
	_bridging = as_bridge
	_total = int(patch.get("size", 0))
	DirAccess.remove_absolute(tmp)
	_next_part(patch, tmp, file_name)



func _next_part(patch: Dictionary, tmp: String, file_name: String) -> void :
	var piece: = tmp + str(_part)
	_http.download_file = piece
	_http.request_completed.connect(_on_part.bind(patch, tmp, file_name, piece, _bridging), CONNECT_ONE_SHOT)
	var url: = _manifest_url().get_base_dir().path_join(str(_parts[_part]))
	if _http.request(url) != OK:
		_fail()


func _process(_delta: float) -> void :
	if _win == null or _http == null or _http.get_http_client_status() != HTTPClient.STATUS_BODY:
		return
	var total: = _total if _total > 0 else _http.get_body_size()
	var got: = _done_bytes + _http.get_downloaded_bytes()
	if total > 0:
		_win.set_progress(100.0 * got / total, tr("Descargando… %s / %s") % [String.humanize_size(got), String.humanize_size(total)])


func _on_part(result: int, code: int, _headers: PackedStringArray, _body: PackedByteArray, 
		patch: Dictionary, tmp: String, file_name: String, piece: String, _as_bridge: = false) -> void :
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not _append(piece, tmp):
		DirAccess.remove_absolute(piece)
		DirAccess.remove_absolute(tmp)
		_fail()
		return
	DirAccess.remove_absolute(piece)
	_part += 1
	if _part < _parts.size():

		_next_part.call_deferred(patch, tmp, file_name)
		return
	_on_patch(patch, tmp, file_name)



func _append(piece: String, joined: String) -> bool:
	var src: = FileAccess.open(piece, FileAccess.READ)
	if src == null:
		return false
	var dst: = FileAccess.open(joined, FileAccess.READ_WRITE if FileAccess.file_exists(joined) else FileAccess.WRITE)
	if dst == null:
		return false
	dst.seek_end()
	while src.get_position() < src.get_length():
		dst.store_buffer(src.get_buffer(1 << 20))
	_done_bytes = dst.get_length()
	src.close()
	dst.close()
	return true


func _on_patch(patch: Dictionary, tmp: String, file_name: String) -> void :
	if FileAccess.get_sha256(tmp) != str(patch.get("sha256", "")).to_lower():
		push_warning("Updater: el parche descargado no coincide con su sha256")
		DirAccess.remove_absolute(tmp)
		_fail()
		return
	var ok: = _decrypt(tmp, DIR.path_join(file_name))
	DirAccess.remove_absolute(tmp)
	if not ok:
		_fail()
		return
	var old: = str(_state.get("file", ""))
	var old_bridge: = str((_state.get("bridge", {}) as Dictionary).get("file", "")) if _state.get("bridge") is Dictionary else ""
	if _bridging:


		_state = {"base": _base, "bridge": {"version": str(patch.get("version", "")), "file": file_name}, 
			"version": str(patch.get("version", ""))}
		for gone in [old, old_bridge]:
			if not gone.is_empty() and gone != file_name:
				DirAccess.remove_absolute(DIR.path_join(gone))
		old = ""
	else:
		_state = {"base": _base, "version": str(patch.get("version", "")), "file": file_name}
		if not old_bridge.is_empty():
			_state["bridge"] = _state_bridge(old_bridge)
	var f: = FileAccess.open(STATE, FileAccess.WRITE)
	if f == null:
		_fail()
		return
	f.store_string(JSON.stringify(_state, "\t"))
	f.close()
	if not old.is_empty() and old != file_name:
		DirAccess.remove_absolute(DIR.path_join(old))
	if OS.has_feature("android"):

		_win.set_progress(100.0, tr("Actualización lista. Vuelve a abrir el juego."))
		await get_tree().create_timer(2.5).timeout
		get_tree().quit()
		return

	_win.set_progress(100.0, tr("Actualización lista. Reiniciando…"))
	await get_tree().create_timer(0.8).timeout
	OS.set_restart_on_exit(true, OS.get_cmdline_args())
	get_tree().quit()



func _state_bridge(file: String) -> Dictionary:
	return {"version": _eff_base, "file": file}


func _decrypt(from: String, to: String) -> bool:
	var src: = FileAccess.open_encrypted_with_pass(from, FileAccess.READ, PATCH_KEY)
	if src == null:
		push_warning("Updater: no se pudo descifrar el parche (%s)" % error_string(FileAccess.get_open_error()))
		return false
	var data: = src.get_buffer(src.get_length())
	src.close()
	var dst: = FileAccess.open(to, FileAccess.WRITE)
	if dst == null:
		return false
	dst.store_buffer(data)
	dst.close()
	return true


func _fail() -> void :
	if _win == null:
		return
	_win.failed(tr("No se pudo descargar la actualización. Se intentará de nuevo al abrir el juego."))



func _newer(a: String, b: String) -> bool:
	var pa: = a.split(".")
	var pb: = b.split(".")
	for i in maxi(pa.size(), pb.size()):
		var x: = pa[i].to_int() if i < pa.size() else 0
		var y: = pb[i].to_int() if i < pb.size() else 0
		if x != y:
			return x > y
	return false


func _read_state() -> Dictionary:
	if not FileAccess.file_exists(STATE):
		return {}
	var data = JSON.parse_string(FileAccess.get_file_as_string(STATE))
	return data if data is Dictionary else {}


func _clear_patches() -> void :
	var d: = DirAccess.open(DIR)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)







func _show_new_build(page: String, base: String, notes: Array) -> void :
	_open_window(tr("Nueva versión disponible"), "v%s  →  v%s   ·   itch.io" % [version, base], notes, true)
	_win.set_status(tr("Descarga el APK nuevo desde itch.io e instálalo encima: no pierdes tu progreso.") if OS.has_feature("android")
		else tr("Esta versión se descarga desde itch.io (la app de itch la instala sola)."))
	_win.open_page.connect( func() -> void :
		if not page.is_empty():
			OS.shell_open(page))
	_win.declined.connect(_close)


func _open_window(title: String, subtitle: String, notes: Array, full: bool) -> void :
	_was_paused = get_tree().paused
	get_tree().paused = true
	_layer = CanvasLayer.new()
	_layer.layer = 128
	add_child(_layer)
	_win = load("res://scripts/ui/update_window.gd").new()
	_win.process_mode = Node.PROCESS_MODE_ALWAYS
	_win.setup(title, subtitle, notes, full)
	_layer.add_child(_win)


func _close() -> void :
	if _http != null:
		_http.cancel_request()
		var part: = _http.download_file
		if not part.is_empty():
			DirAccess.remove_absolute(part)
	set_process(false)
	if _layer != null:
		_layer.queue_free()
	_layer = null
	_win = null
	get_tree().paused = _was_paused
