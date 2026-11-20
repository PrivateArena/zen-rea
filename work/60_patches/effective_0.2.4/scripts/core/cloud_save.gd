extends Node
















signal changed


const DEVICE_KEYS: = ["music", "sfx", "master", "fullscreen", "vsync", "max_fps", "unfocused_fps", "save_seq", "show_fps", "screen_shake", 
	"weather", "fx_alpha", "fx_alpha_boss", "fx_quality", "num_alpha", "damage_numbers", "mute_unfocused", "camera_turn", 
	"chat_min", "meter_pos", "meter_details_pos", "meter_mode", "feedback_queue", "language", "rlv_backdrop", 
	"hero_hp_bar", "hero_name", "touch_toggle_tip", "window_size", "ui_sharp", "ui_size", 

	"quality", "fsr", "perf_mode", "perf_prev", "fx_alpha_party", "mob_shadows", 

	"rejoin_key"]



const SYNC_EVERY: = 240.0

const AFTER_RUN: = 5.0


const BACKGROUND_GAP: = 60.0






const SOON: = 20.0





const START_RETRY: = 15.0
const START_TRIES: = 6

const PREFIX: = "gza1:"

var world: Node

var status: = ""
var last_ok: = 0

var link: = {}
var _busy: = false
var _t: = 0.0
var _was_running: = false
var _dialog: CanvasLayer

var _start_pending: = false
var _start_tries: = 0

var _soon: = -1.0


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS


	Save.changed.connect( func():
		if _soon < 0.0 and linked() and _enabled() and world != null and not bool(world.get("running")):
			_soon = SOON)
	if linked() and _enabled():
		_start_pending = true
		sync_now.call_deferred(true)

		if user() == "":
			_call.call_deferred("cloud_whoami", {"p_secret": str(Save.setting("cloud_secret", ""))}, func(ok: bool, d):
				if ok and d is Dictionary and str(d.get("user", "")) != "":
					Save.set_setting("cloud_user", str(d.user))
					changed.emit())


static func _enabled() -> bool:

	return Save._name == "profile"


func linked() -> bool:
	return str(Save.setting("cloud_secret", "")) != ""


func _process(delta: float) -> void :
	var running: = bool(world.get("running"))

	if _was_running and not running:
		_t = maxf(_t, SYNC_EVERY - AFTER_RUN)
	_was_running = running

	if not linked() or _busy or status == "conflict" or status == "too_big" or not _enabled():
		return
	_t += delta

	if _soon >= 0.0:
		_soon -= delta
		if _soon < 0.0 and not running and _dirty():
			_t = 0.0
			sync_now(_start_pending)
			return

	if _start_pending and status == "offline" and not running and _start_tries < START_TRIES and _t >= START_RETRY:
		_t = 0.0
		_start_tries += 1
		sync_now(true)
		return
	if _t < SYNC_EVERY:
		return
	_t = 0.0
	if not running:
		sync_now(_start_pending)


func _notification(what: int) -> void :



	if what == NOTIFICATION_APPLICATION_RESUMED:
		if world != null and linked() and _enabled() and status != "conflict" and not bool(world.get("running")):
			_start_pending = true
			_start_tries = 0
			_t = 0.0
			if not _busy:
				sync_now(true)
		return


	if what != NOTIFICATION_APPLICATION_FOCUS_OUT and what != NOTIFICATION_APPLICATION_PAUSED:
		return

	if world == null or not linked() or _busy or status == "conflict" or status == "too_big" or not _enabled():
		return


	if bool(world.get("running")) or not _dirty():
		return
	_t = 0.0
	sync_now(false)




static func _device_key(k: String) -> bool:
	return k in DEVICE_KEYS or k.begins_with("cloud_")



static func progress(data: Dictionary) -> Dictionary:
	var d: = data.duplicate(true)
	var s: Dictionary = d.get("settings", {})
	for k in s.keys():
		if _device_key(str(k)):
			s.erase(k)
	return d



static func summary_of(data: Dictionary) -> Dictionary:
	var classes: Dictionary = data.get("classes", {})
	var best: = 0
	for c in classes.values():
		if c is Dictionary:
			best = maxi(best, int(c.get("level", 0)))
	var stats: Dictionary = data.get("stats", {})


	var cos = data.get("cosmetics", {})
	var own = cos.get("own", {}) if cos is Dictionary else {}
	var n_cos: = 0
	if own is Dictionary:
		for k in own:
			if bool(own[k]):
				n_cos += 1
	return {"play_time": roundi(float(stats.get("play_time", 0.0))), "runs": int(stats.get("runs", 0)), 
		"cosmetics": n_cos, "coins": int(data.get("coins", 0)), 
		"zeny": int(data.get("zeny", 0)), "classes": classes.size(), "best_level": best, 
		"rebirths": (data.get("rebirths", {}) as Dictionary).size(), "achievements": (data.get("achievements", {}) as Dictionary).size()}


static func _hash(data: Dictionary) -> String:
	return JSON.stringify(progress(data), "", true).sha256_text()



func _dirty() -> bool:
	return _hash(Save.data) != str(Save.setting("cloud_hash", ""))


static func _key() -> PackedByteArray:
	return Save.SAVE_KEY.sha256_buffer()


static func pack(data: Dictionary) -> String:
	var plain: = JSON.stringify(progress(data)).to_utf8_buffer()

	var size: = plain.size()
	var raw: = plain.compress(FileAccess.COMPRESSION_GZIP)
	var head: = PackedByteArray()
	head.resize(4)
	head.encode_u32(0, size)
	raw = head + raw

	var pad: = 16 - raw.size() % 16
	for i in pad:
		raw.append(pad)
	var iv: = Crypto.new().generate_random_bytes(16)
	var aes: = AESContext.new()
	aes.start(AESContext.MODE_CBC_ENCRYPT, _key(), iv)
	var enc: = aes.update(raw)
	aes.finish()
	return PREFIX + Marshalls.raw_to_base64(iv + enc)


static func unpack(text: String) -> Dictionary:
	if not text.begins_with(PREFIX):
		return {}
	var all: = Marshalls.base64_to_raw(text.substr(PREFIX.length()))
	if all.size() < 32 or (all.size() - 16) % 16 != 0:
		return {}
	var aes: = AESContext.new()
	aes.start(AESContext.MODE_CBC_DECRYPT, _key(), all.slice(0, 16))
	var raw: = aes.update(all.slice(16))
	aes.finish()
	var pad: = raw[raw.size() - 1]
	if pad < 1 or pad > 16:
		return {}
	raw = raw.slice(0, raw.size() - pad)
	var size: = raw.decode_u32(0)
	var json: = raw.slice(4).decompress(size, FileAccess.COMPRESSION_GZIP).get_string_from_utf8()
	var d = JSON.parse_string(json)
	return d if d is Dictionary else {}




func _call(fn: String, body: Dictionary, done: Callable) -> void :
	world.board._call(fn, body, done)


func _status_set(s: String) -> void :
	status = s
	if s == "ok":
		last_ok = Time.get_ticks_msec()
	_busy = s == "syncing"
	changed.emit()



func enable() -> void :
	if linked() or _busy:
		return
	_status_set("syncing")
	_call("cloud_create", {}, func(ok: bool, d):
		if not ok or not (d is Dictionary) or not d.has("secret"):
			_status_set("offline")
			return
		Save.set_setting("cloud_secret", str(d.secret))
		Save.set_setting("cloud_rev", 0)
		Save.set_setting("cloud_hash", "")
		_busy = false
		_push(0))



func make_link() -> void :
	if not linked():
		return
	_call("cloud_link_create", {"p_secret": str(Save.setting("cloud_secret", ""))}, func(ok: bool, d):
		if ok and d is Dictionary and d.has("code"):
			link = {"code": str(d.code), "until": Time.get_ticks_msec() + int(d.get("expires_in", 600)) * 1000}
		else:
			link = {"error": true}
		changed.emit())




func use_code(code: String, done: Callable) -> void :
	_call("cloud_link_use", {"p_code": code}, func(ok: bool, d):
		if not ok or not (d is Dictionary):
			done.call(Leaderboard.offline_text())
			return
		if not d.has("secret"):
			done.call(tr("Ese código no existe o ya venció."))
			return
		Save.set_setting("cloud_secret", str(d.secret))
		Save.set_setting("cloud_rev", 0)
		Save.set_setting("cloud_hash", "")
		Save.flush()
		done.call("")
		sync_now(true))






func user() -> String:
	return str(Save.setting("cloud_user", "")) if linked() else ""



static func account_error(code: String, wait: = 0) -> String:
	match code:
		"bad_name":
			return TranslationServer.translate("El usuario debe tener de 3 a 20 letras o números (también _ . -).")
		"bad_pass":
			return TranslationServer.translate("La contraseña debe tener al menos 6 caracteres.")
		"taken":
			return TranslationServer.translate("Ese usuario ya existe: elige otro.")
		"has_login":
			return TranslationServer.translate("Este dispositivo ya está en una cuenta con nombre.")
		"locked":
			return TranslationServer.translate("Demasiados intentos: espera %d min.") % maxi(1, ceili(wait / 60.0))
		"no_questions":
			return TranslationServer.translate("Esa cuenta no tiene preguntas de seguridad: escríbenos en Discord.")
		"offline":
			return Leaderboard.offline_text()
	return TranslationServer.translate("Usuario o contraseña incorrectos.")





func register(user_name: String, password: String, answers: String, done: Callable) -> void :
	_call("cloud_register", {"p_secret": str(Save.setting("cloud_secret", "")), "p_user": user_name, "p_pass": password, "p_answers": answers}, func(ok: bool, d):
		if not ok or not (d is Dictionary):
			done.call(account_error("offline"))
			return
		if not bool(d.get("ok", false)):
			done.call(account_error(str(d.get("error", "")), int(d.get("wait", 0))))
			return
		Save.set_setting("cloud_user", str(d.get("user", user_name)))
		var fresh = d.get("secret")
		if fresh != null and str(fresh) != "":
			Save.set_setting("cloud_secret", str(fresh))
			Save.set_setting("cloud_rev", 0)
			Save.set_setting("cloud_hash", "")
			Save.flush()
			done.call("")
			_push(0)
		else:
			Save.flush()
			done.call("")
			sync_now(false))





func login(user_name: String, password: String, done: Callable, answers: = "") -> void :
	var fn: = "cloud_recover" if answers != "" else "cloud_login"
	var body: = {"p_user": user_name, "p_pass": password}
	if answers != "":
		body["p_answers"] = answers
	_call(fn, body, func(ok: bool, d):
		if not ok or not (d is Dictionary):
			done.call(account_error("offline"))
			return
		if not bool(d.get("ok", false)):
			done.call(account_error(str(d.get("error", "")), int(d.get("wait", 0))))
			return
		Save.set_setting("cloud_secret", str(d.secret))
		Save.set_setting("cloud_user", str(d.get("user", user_name)))
		Save.set_setting("cloud_rev", 0)
		Save.set_setting("cloud_hash", "")
		Save.flush()
		done.call("")
		sync_now(true))




func logout() -> void :
	forget()
	Save.data.settings.erase("cloud_user")
	Save.flush()
	changed.emit()



func forget() -> void :
	var secret: = str(Save.setting("cloud_secret", ""))
	if secret != "":
		_call("cloud_forget", {"p_secret": secret}, func(_ok, _d): pass)
	for k in ["cloud_secret", "cloud_rev", "cloud_hash"]:
		Save.data.settings.erase(k)
	Save.mark_dirty()
	link = {}
	_status_set("")





func sync_now(fresh: = false) -> void :
	if not linked() or _busy:
		return
	_status_set("syncing")
	_call("cloud_head", {"p_secret": str(Save.setting("cloud_secret", ""))}, func(ok: bool, d):
		if not ok or not (d is Dictionary):
			_status_set("offline")
			return

		var start: = fresh or _start_pending
		_start_pending = false
		if d.has("error"):

			_status_set("error")
			return
		var cloud_rev: = int(d.get("rev", 0))
		var mine: = int(Save.setting("cloud_rev", 0))
		var dirty: = _dirty()
		if cloud_rev == mine:
			if dirty:
				_push(mine)
			else:
				_status_set("ok")
		elif not dirty and start and not bool(world.get("running")):
			_pull(true)
		elif _empty(Save.data) and not bool(world.get("running")):

			_pull(true)
		else:
			_status_set("conflict")
			_ask(d.get("summary", {}) if d.get("summary") is Dictionary else {}, str(d.get("device", ""))))


static func _empty(data: Dictionary) -> bool:
	var stats: Dictionary = data.get("stats", {})
	return int(stats.get("runs", 0)) == 0 and float(stats.get("play_time", 0.0)) < 120.0


func _push(base: int, then: = Callable()) -> void :
	_status_set("syncing")




	if str(Save.setting("progress_id", "")) == "":
		Save.set_setting("progress_id", _new_pid())
	var body: = {"p_secret": str(Save.setting("cloud_secret", "")), "p_data": pack(Save.data), "p_base_rev": base, 
		"p_summary": summary_of(Save.data), "p_device": OS.get_name(), "p_pid": str(Save.setting("progress_id", ""))}
	var h: = _hash(Save.data)
	_call("cloud_put", body, func(ok: bool, d):
		if not ok or not (d is Dictionary):
			_status_set("offline")
			return
		if bool(d.get("ok", false)):
			Save.set_setting("cloud_rev", int(d.rev))
			Save.set_setting("cloud_hash", h)
			Save.flush()
			_status_set("ok")
			if then.is_valid():
				then.call()
		elif bool(d.get("owned", false)):
			_owned(int(d.get("rev", 0)))
		elif bool(d.get("conflict", false)):
			_status_set("conflict")
			_ask(d.get("summary", {}) if d.get("summary") is Dictionary else {}, "")
		else:




			_status_set("too_big" if str(d.get("error", "")) == "too_big" else "error"))


static func _new_pid() -> String:
	var b: = PackedByteArray()
	for i in 16:
		b.append(randi() % 256)
	return b.hex_encode()






func _owned(rev: int) -> void :
	if rev > 0:
		_pull(true)
		return
	_keep_local()
	var keep: Dictionary = Save.data.get("settings", {})
	var fresh: = Save.defaults()
	var settings: Dictionary = fresh.get("settings", {})
	for k in keep:
		if _device_key(str(k)):
			settings[k] = keep[k]
	settings["progress_id"] = _new_pid()
	fresh["settings"] = settings
	Save.data = Save._merge(Save.defaults(), fresh)
	Save.mark_dirty()
	Save.flush()
	Save.load_profile()
	_push(-1, _restart)




func _pull(restart: bool) -> void :
	_status_set("syncing")
	_call("cloud_get", {"p_secret": str(Save.setting("cloud_secret", ""))}, func(ok: bool, d):
		if not ok or not (d is Dictionary) or not d.has("data"):


			_start_pending = _start_pending or restart
			_status_set("offline")
			return
		var cloud: = unpack(str(d.data))
		if cloud.is_empty():
			_status_set("error")
			return

		_keep_local()
		var keep: Dictionary = Save.data.get("settings", {})
		var settings: Dictionary = cloud.get("settings", {})
		for k in keep:
			if _device_key(str(k)):
				settings[k] = keep[k]
		cloud["settings"] = settings
		Save.data = Save._merge(Save.defaults(), cloud)
		Save.set_setting("cloud_rev", int(d.rev))
		Save.set_setting("cloud_hash", _hash(Save.data))
		Save.mark_dirty()
		Save.flush()

		Save.load_profile()
		_status_set("ok")
		if restart:
			_restart())






const BACKUP_DIR: = "user://cloud_backups"
const BACKUPS_KEPT: = 5


func _keep_local() -> void :
	if _empty(Save.data):
		return
	DirAccess.make_dir_recursive_absolute(BACKUP_DIR)
	var stem: = Save.PATH.get_file().get_basename()
	var path: = "%s/%s_%d.json" % [BACKUP_DIR, stem, int(Time.get_unix_time_from_system())]
	var f: = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, Save.SAVE_KEY)
	if f == null:
		push_warning("Cloud: no copy of this device's progress (%s)" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(Save.data))
	f.close()
	var files: = Array(DirAccess.get_files_at(BACKUP_DIR)).filter( func(n): return str(n).begins_with(stem + "_"))
	files.sort()
	while files.size() > BACKUPS_KEPT:
		DirAccess.remove_absolute(BACKUP_DIR.path_join(str(files.pop_front())))


func _restart() -> void :
	close_dialog()

	if has_meta("no_restart"):
		return
	get_tree().paused = false

	get_tree().reload_current_scene()






func _ask(cloud_sum: Dictionary, device: String) -> void :
	close_dialog()
	var here: = summary_of(Save.data)
	_dialog = CanvasLayer.new()
	_dialog.layer = 60
	_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_dialog)
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	_dialog.add_child(root)
	root.add_child(UiKit.backdrop(0.55))
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var panel: = PanelContainer.new()
	var box: = UiKit.panel_box(Color(0.97, 0.98, 1.0), Color(0.55, 0.65, 0.9), 12, 1)
	box.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", box)
	center.add_child(panel)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	var title: = UiKit.label(tr("Guardado en la nube"), 18, Color(0.14, 0.2, 0.45), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	var why: = UiKit.label(tr("Esta partida y la de la nube cambiaron por separado. ¿Cuál quieres conservar? La otra se reemplaza."), 13, UiKit.TEXT)
	why.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	why.custom_minimum_size.x = 520
	why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(why)
	var cols: = HBoxContainer.new()
	cols.add_theme_constant_override("separation", 14)
	cols.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(cols)
	var cloud_name: = tr("En la nube") + ((" (%s)" % device) if device != "" else "")

	cols.add_child(_side(cloud_name, cloud_sum, tr("Usar la de la nube"), func():
		close_dialog()
		_pull(true), loss_text(here, cloud_sum)))
	cols.add_child(_side(tr("En este dispositivo"), here, tr("Usar la de este dispositivo"), func():
		close_dialog()
		_push(-1), loss_text(cloud_sum, here)))
	get_tree().paused = true




func loss_text(lost: Dictionary, kept: Dictionary) -> String:
	var parts: Array[String] = []
	var reb: = int(lost.get("rebirths", 0)) - int(kept.get("rebirths", 0))
	if reb > 0:
		parts.append(tr_n("%d renacimiento", "%d renacimientos", reb) % reb)
	var secs: = int(lost.get("play_time", 0)) - int(kept.get("play_time", 0))
	if secs >= 3600:
		parts.append(tr_n("%d hora de juego", "%d horas de juego", secs / 3600) % (secs / 3600))
	elif secs >= 600:
		parts.append(tr_n("%d minuto de juego", "%d minutos de juego", secs / 60) % (secs / 60))
	var ach: = int(lost.get("achievements", 0)) - int(kept.get("achievements", 0))
	if ach > 0:
		parts.append(tr_n("%d logro", "%d logros", ach) % ach)
	var zeny: = int(lost.get("zeny", 0)) - int(kept.get("zeny", 0))
	if zeny >= 100000:
		parts.append(tr("%s zeny") % RoBasicWindow._thousands(zeny))
	var cls: = int(lost.get("classes", 0)) - int(kept.get("classes", 0))
	if cls > 0:
		parts.append(tr_n("%d clase", "%d clases", cls) % cls)
	if lost.has("cosmetics") and kept.has("cosmetics"):
		var cos: = int(lost.cosmetics) - int(kept.cosmetics)
		if cos > 0:
			parts.append(tr_n("%d cosmético", "%d cosméticos", cos) % cos)
		var coins: = int(lost.get("coins", 0)) - int(kept.get("coins", 0))
		if coins > 0:
			parts.append(tr_n("%d Poring Coin", "%d Poring Coins", coins) % coins)
	if parts.is_empty():
		return ""
	var list: = parts[0] if parts.size() == 1 else ", ".join(parts.slice(0, -1)) + tr(" y ") + parts[-1]
	return tr("Esto borra %s.") % list


func _side(title: String, s: Dictionary, choose: String, fn: Callable, loss: = "") -> Control:
	var card: = PanelContainer.new()
	var box: = UiKit.panel_box(Color.WHITE, Color(0.8, 0.84, 0.94), 10, 1)
	box.set_content_margin_all(12)
	card.add_theme_stylebox_override("panel", box)
	card.custom_minimum_size.x = 250
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	card.add_child(v)
	v.add_child(UiKit.label(title, 14, Color(0.14, 0.2, 0.45), true))
	var lines: = [
		tr("Tiempo jugado: %d h %02d min") % [int(s.get("play_time", 0)) / 3600, (int(s.get("play_time", 0)) % 3600) / 60], 
		tr("Partidas: %d") % int(s.get("runs", 0)), 
		tr("Zeny: %s") % _thousands(int(s.get("zeny", 0))), 
		tr("Clases: %d  ·  mejor nivel %d") % [int(s.get("classes", 0)), int(s.get("best_level", 0))], 
		tr("Renacimientos: %d  ·  logros %d") % [int(s.get("rebirths", 0)), int(s.get("achievements", 0))], 
	]

	if s.has("cosmetics"):
		lines.append(tr("Cosméticos: %d  ·  Poring Coins %d") % [int(s.get("cosmetics", 0)), int(s.get("coins", 0))])
	for t in lines:
		v.add_child(UiKit.label(t, 12, UiKit.TEXT))
	var b: = UiKit.button(choose, true)
	v.add_child(b)
	if loss == "":
		b.pressed.connect(fn)
		return card


	box.border_color = Color(0.85, 0.25, 0.22)
	box.set_border_width_all(2)
	var warn: = UiKit.label(loss, 12, Color(0.78, 0.12, 0.1), true)
	warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warn.custom_minimum_size.x = 226
	v.add_child(warn)
	v.move_child(warn, b.get_index())
	var armed: = [false]
	b.pressed.connect( func():
		if armed[0]:
			fn.call()
			return
		armed[0] = true
		b.text = tr("Pulsa otra vez para confirmar")
		b.get_tree().create_timer(4.0, true).timeout.connect( func():
			if is_instance_valid(b):
				armed[0] = false
				b.text = choose))
	return card


static func _thousands(n: int) -> String:
	var s: = str(absi(n))
	var out: = ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out


func close_dialog() -> void :
	if _dialog != null and is_instance_valid(_dialog):
		_dialog.queue_free()
		get_tree().paused = false
	_dialog = null
