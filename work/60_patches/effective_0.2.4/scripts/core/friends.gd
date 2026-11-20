extends Node









signal changed

var world: Node


var list: Array = []

var online: = 0
var requests: = 0

var loaded: = false
var _busy: = false



func me() -> String:
	return "%s %s" % [Save.char_name(my_class()), Leaderboard.tag()]




func my_class() -> String:
	if world == null:
		return ""
	if world.town != null and is_instance_valid(world.town):
		return str(world.town.class_id)
	if world.running and world.player != null:
		return str(world.player.class_id)
	var last: = str(RoCharSelect.last_id)
	if GameData.CLASSES.has(last):
		return last
	for id in GameData.CLASSES:
		if Save.class_unlocked(id):
			return str(id)
	return ""



func my_job() -> String:
	if world != null and world.running and world.player != null:
		return str(world.player.job2.get("id", ""))
	return ""



func on_beat(data: Dictionary) -> void :
	var o: = int(data.get("friends_online", online))
	var r: = int(data.get("requests", requests))
	if o != online or r != requests:
		online = o
		requests = r
		changed.emit()


func refresh(done: = Callable()) -> void :
	if _busy:
		return
	_busy = true
	world.board._call("friend_list", {"p_player": Leaderboard.player_id()}, func(ok: bool, data):
		_busy = false
		if ok and data is Array:
			list = data
			loaded = true

			Save.stat_max("friends", list.filter( func(f): return str(f.get("state", "")) == "friend").size())
			online = list.filter( func(f): return str(f.get("state", "")) == "friend" and bool(f.get("online", false))).size()
			requests = list.filter( func(f): return str(f.get("state", "")) == "incoming").size()
			changed.emit()
		if done.is_valid():
			done.call(ok))




func ask(text: String, done: Callable) -> void :
	var t: = text.strip_edges()
	var at: = t.rfind("#")
	if at <= 0:
		done.call("bad", "")
		return
	var who: = t.left(at).strip_edges()
	var tag: = t.substr(at + 1).strip_edges()
	if who == "" or tag.length() != 4:
		done.call("bad", "")
		return
	ask_name(who, tag, done)


func ask_name(who: String, tag: String, done: Callable) -> void :
	world.board._call("friend_request", {"p_player": Leaderboard.player_id(), "p_name": who, "p_tag": tag}, func(ok: bool, data):
		if not ok or not data is Dictionary:
			done.call("offline", "")
			return
		var shown: = "%s %s" % [str(data.get("name", who)), str(data.get("tag", "#" + tag.to_upper()))]
		done.call(str(data.get("status", "not_found")), shown)
		refresh())


func answer(id: int, accept: bool, done: = Callable()) -> void :
	world.board._call("friend_answer", {"p_player": Leaderboard.player_id(), "p_id": id, "p_accept": accept}, func(ok: bool, _data):
		refresh(done if done.is_valid() else Callable())
		if not ok and done.is_valid():
			done.call(false))


func remove(id: int, done: = Callable()) -> void :
	world.board._call("friend_remove", {"p_player": Leaderboard.player_id(), "p_id": id}, func(ok: bool, _data):
		refresh(done if done.is_valid() else Callable())
		if not ok and done.is_valid():
			done.call(false))




func where_text(f: Dictionary) -> String:
	if not bool(f.get("online", false)):
		var ago = f.get("ago")
		if ago == null:
			return tr("Sin conectarse aún")
		return tr("Visto hace %s") % ago_text(int(ago))
	match str(f.get("place", "")):
		"town":
			var ch: = int(f.get("channel", 0))
			return tr("En Prontera  ·  canal %d") % ch if ch > 0 else tr("En Prontera")
		"run":
			return tr("En partida (co-op)") if bool(f.get("coop", false)) else tr("En partida")
		"tower":
			return tr("En la Endless Tower")
	return tr("En el menú")


func ago_text(secs: int) -> String:
	if secs < 3600:
		return tr("%d min") % maxi(1, secs / 60)
	if secs < 86400:
		return tr("%d h") % (secs / 3600)
	return tr_n("%d día", "%d días", secs / 86400) % (secs / 86400)
