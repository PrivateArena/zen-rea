extends Node













const URL: = "wss://relay.midgardsurvivors.com/chat/"
const LANGS: = ["es", "en", "pt", "ru", "de", "zh_TW", "fr", "th"]
const PING_S: = 25.0
const RETRY_S: = [3.0, 8.0, 20.0, 45.0]

const MAX_TEXT: = 150
const GAP_S: = 2.0


var ch: Node
var ws: WebSocketPeer

var state: = "off"

var can_say: = false
var _lang: = ""
var _retry: = 0
var _retry_at: = 0.0
var _ping_at: = 0.0
var _said_at: = -99.0

var _ids: = {}


func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void :
	var now: = Time.get_ticks_msec() / 1000.0
	var want: = _wanted()
	if not want:
		if state != "off":
			_close()
		return
	if state == "off":
		if now >= _retry_at:
			_open()
		return
	if ws == null:
		return
	ws.poll()
	match ws.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if state == "connecting":
				state = "in"
				_retry = 0
				_hello()
			while ws.get_available_packet_count() > 0:
				var m = JSON.parse_string(ws.get_packet().get_string_from_utf8())
				if m is Dictionary:
					_on(m)
			if now >= _ping_at:
				_ping_at = now + PING_S
				ws.send_text("p")

			if _room() != _lang:
				_close()
		WebSocketPeer.STATE_CLOSED:
			_close()
			_retry_at = now + float(RETRY_S[mini(_retry, RETRY_S.size() - 1)])
			_retry += 1



func _wanted() -> bool:
	if ch == null or not ch.has_method("in_prontera") or not ch.in_prontera():
		return false
	return not bool(Save.setting("world_chat_off", false))


func _room() -> String:
	var loc: = TranslationServer.get_locale()
	if loc in LANGS:
		return loc
	var two: = loc.substr(0, 2)
	if two == "zh":
		return "zh_TW"
	return two if two in LANGS else "en"


func _open() -> void :
	_lang = _room()
	ws = WebSocketPeer.new()
	ws.inbound_buffer_size = 1 << 16

	var base: = str(GameData.get_meta("world_chat_url")) if GameData.has_meta("world_chat_url") else URL
	if ws.connect_to_url(base + _lang + "?v=" + str(Updater.version).uri_encode()) != OK:
		ws = null
		_retry_at = Time.get_ticks_msec() / 1000.0 + float(RETRY_S[mini(_retry, RETRY_S.size() - 1)])
		_retry += 1
		return
	state = "connecting"
	_ping_at = Time.get_ticks_msec() / 1000.0 + PING_S


func _close() -> void :
	if ws != null:
		ws.close()
	ws = null
	state = "off"
	can_say = false




func _hello() -> void :
	var secret: = str(Save.setting("cloud_secret", ""))
	var cloud = ch.world.get("cloud") if ch != null else null
	var logged: bool = cloud != null and cloud.has_method("user") and str(cloud.user()) != ""

	if GameData.has_meta("world_chat_secret"):
		secret = str(GameData.get_meta("world_chat_secret"))
		logged = true
	ws.send_text(JSON.stringify({"t": "hi", "s": secret if logged else "", "name": _my_name()}))


func _my_name() -> String:
	var town = ch.world.town if ch != null else null
	return Save.char_name(str(town.class_id) if town != null and is_instance_valid(town) else "")


func _on(m: Dictionary) -> void :
	match str(m.get("t", "")):
		"hi":
			can_say = bool(m.get("say", false))
			_send_feats()
		"msg":
			var who: = str(m.get("n", ""))
			if who == "" or muted(who):
				return
			var id: = str(m.get("id", ""))
			_ids[id] = who
			if _ids.size() > 300:
				_ids.erase(_ids.keys()[0])
			ch.log_line("world", "%s : %s" % [who, NameFilter.clean(str(m.get("x", "")))], "", "", id)
		"feat":
			var who: = str(m.get("n", ""))
			var title: = str(m.get("title", ""))

			if title.begins_with("wb_") and who != "" and not muted(who):
				var line: = _wb_line(who, title)
				if line != "":
					ch.log_line("wfeat", line)
				return
			if who == "" or muted(who) or not GameData.TITLES.has(title):
				return
			ch.log_line("wfeat", "%s : ★ %s" % [who, tr("¡consiguió el título «%s»!") % ch.world.titles.name_of(title)])
		"err":
			ch.log_line("sys", _why(str(m.get("e", ""))))


func _why(e: String) -> String:
	match e:
		"guest":
			return tr("Para hablar en Mundo inicia sesión con tu cuenta (Opciones > Cuenta).")
		"muted":
			return tr("Estás silenciado en Mundo por un tiempo.")
		"banned":
			return tr("No puedes hablar en Mundo.")
		"rate":
			return tr("Espera un momento antes de volver a escribir en Mundo.")
		"link":
			return tr("No se permiten enlaces en Mundo.")
		"same":
			return tr("Ya dijiste eso.")
	return tr("No se pudo enviar a Mundo.")



func say(text: String) -> bool:
	text = text.strip_edges().left(MAX_TEXT)
	if text == "":
		return false
	if state != "in" or ws == null:
		ch.log_line("sys", tr("Mundo: conectando..."))
		return false
	if not can_say:
		ch.log_line("sys", _why("guest"))
		return false
	var now: = Time.get_ticks_msec() / 1000.0
	if now - _said_at < GAP_S:
		ch.log_line("sys", _why("rate"))
		return false
	_said_at = now
	ws.send_text(JSON.stringify({"t": "say", "x": NameFilter.clean(text), "name": _my_name()}))
	return true


func muted(who: String) -> bool:
	return (Save.setting("chat_muted", []) as Array).has(who)



func set_muted(who: String, on: bool) -> void :
	var list: Array = (Save.setting("chat_muted", []) as Array).duplicate()
	list.erase(who)
	if on:
		list.append(who)
	Save.set_setting("chat_muted", list)
	ch.log_line("sys", (tr("Silenciaste a %s en Mundo.") if on else tr("%s ya no está silenciado.")) % who)


func report(id: String) -> void :
	if state != "in" or ws == null or not _ids.has(id):
		return
	ws.send_text(JSON.stringify({"t": "report", "id": id}))
	ch.log_line("sys", tr("Reporte enviado. Gracias."))



func _wb_line(who: String, code: String) -> String:
	var parts: = code.split("_")
	if parts.size() < 4:
		return ""
	var kind: = parts[1]
	var k: = int(parts[parts.size() - 1])
	var boss: = "_".join(parts.slice(2, parts.size() - 1))
	if not GameData.MONSTERS.has(boss):
		return ""
	var wb: GDScript = load("res://scripts/core/world_boss.gd")
	match kind:
		"fell":
			return "★ " + tr("¡%s derribó al Jefe del Mundo! %s renace como %s") % [who, wb.boss_name(boss, k - 1), wb.boss_name(boss, k)]
		"half":
			return "★ " + tr("El Jefe del Mundo %s está a la mitad de su vida (golpe de %s)") % [wb.boss_name(boss, k), who]
		"low":
			return "★ " + tr("¡El Jefe del Mundo %s está al 10%%! (golpe de %s)") % [wb.boss_name(boss, k), who]
	return ""




func event(code: String) -> void :
	var waiting: Array = (Save.setting("world_feats", []) as Array).duplicate()
	if not waiting.has(code):
		waiting.append(code)
	Save.set_setting("world_feats", waiting)
	if state == "in" and can_say:
		_send_feats()




func feat(title_id: String) -> void :
	if not title_id in GameData.WORLD_FEAT_TITLES:
		return
	var waiting: Array = (Save.setting("world_feats", []) as Array).duplicate()
	if not waiting.has(title_id):
		waiting.append(title_id)
	Save.set_setting("world_feats", waiting)
	if state == "in" and can_say:
		_send_feats()


func _send_feats() -> void :
	var waiting: Array = Save.setting("world_feats", []) as Array
	if waiting.is_empty() or ws == null or not can_say:
		return
	for t in waiting:
		ws.send_text(JSON.stringify({"t": "feat", "title": str(t), "name": _my_name()}))
	Save.set_setting("world_feats", [])
