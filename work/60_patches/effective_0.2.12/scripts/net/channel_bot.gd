extends Node






const TownChannel = preload("res://scripts/net/town_channel.gd")

const ROAM: = 13.0

const SAY_EVERY: = [8.0, 25.0]
const EMOTE_EVERY: = [5.0, 15.0]
const DOING_EVERY: = [10.0, 30.0]
const DOING_FOR: = [4.0, 10.0]

const SITTER: = 0.25
const PC_SIT: = 2

var town: Town
var info: Dictionary
var center: Vector3

var heard: = 0

var _api: = SceneMultiplayer.new()
var _pos: = Vector3.ZERO
var _target: = Vector3.INF
var _wait: = 0.0
var _dir: = 0
var _action: = RoVisual.PC_IDLE
var _send_t: = 0.0
var _say_t: = 0.0
var _emote_t: = 0.0
var _doing_t: = 0.0
var _doing: = ""
var _sitter: = false


func _ready() -> void :
	get_tree().set_multiplayer(_api, get_path())
	_api.server_relay = false
	_api.connected_to_server.connect(_on_connected)
	_sitter = randf() < SITTER
	_pos = _spot()
	_say_t = randf_range(2.0, SAY_EVERY[1])
	_emote_t = randf_range(1.0, EMOTE_EVERY[1])
	_doing_t = randf_range(5.0, DOING_EVERY[1])
	connect_now()


func connect_now() -> void :
	var peer: = ENetMultiplayerPeer.new()
	if peer.create_client("127.0.0.1", TownChannel.PORT) != OK:
		push_error("CHANSTRESS bot %s: no ENet client" % info.get("name", ""))
		return
	_api.multiplayer_peer = peer



func leave() -> void :
	if _api.multiplayer_peer != null:
		_api.multiplayer_peer.close()
	_api.multiplayer_peer = null


func is_in() -> bool:
	return _api.multiplayer_peer != null and _api.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func _on_connected() -> void :
	_send("hi", [info])
	_send_pos()


func _process(delta: float) -> void :
	if not is_in():
		return
	_walk(delta)
	_send_t -= delta
	if _send_t <= 0.0:
		_send_t = 1.0 / TownChannel.RATE
		_send_pos()
	_say_t -= delta
	if _say_t <= 0.0:
		_say_t = randf_range(SAY_EVERY[0], SAY_EVERY[1])
		say()
	_emote_t -= delta
	if _emote_t <= 0.0:
		_emote_t = randf_range(EMOTE_EVERY[0], EMOTE_EVERY[1])
		emote()
	_doing_t -= delta
	if _doing_t <= 0.0:
		if _doing == "":
			_doing = GameData.TOWN_DOING.keys().pick_random()
			_doing_t = randf_range(DOING_FOR[0], DOING_FOR[1])
		else:
			_doing = ""
			_doing_t = randf_range(DOING_EVERY[0], DOING_EVERY[1])
		_send("doing", [_doing])



func say() -> void :
	var role: String = ["shouter", "idler", "walker"].pick_random()
	var line: = str(GameData.CROWD_LINES[role].pick_random())
	if line.contains("%s"):
		line = line % str(GameData.CLASSES[info["class"]].name)
	_send("say", ["%s : %s" % [info["name"], line]])


func emote() -> void :
	_send("emo", [randi_range(0, 33)])


func _walk(delta: float) -> void :
	if _target == Vector3.INF:
		_wait -= delta
		if _wait > 0.0:
			return
		_target = _spot()
	var to: = (_target - _pos) * Vector3(1, 0, 1)
	var step: = GameData.TOWN_WALK_SPEED * delta
	if to.length() <= step:
		_pos = _target
		_target = Vector3.INF
		_wait = randf_range(1.0, 6.0)
		_action = PC_SIT if _sitter and randf() < 0.5 else RoVisual.PC_IDLE
		return
	_pos += to.normalized() * step

	_dir = posmod(roundi(atan2( - to.x, to.z) / (PI / 4.0)), 8)
	_action = RoVisual.PC_WALK



func _spot() -> Vector3:
	for i in 40:
		var a: = randf() * TAU
		var p: = center + Vector3(cos(a), 0, sin(a)) * randf_range(1.0, ROAM)
		if town.world.map.is_walkable(p):
			return p
	return center


func _send_pos() -> void :
	_send_u("pos", [snappedf(_pos.x, 0.06), snappedf(_pos.z, 0.06), _dir, _action])


func _send(kind: String, args: Array) -> void :
	if is_in():
		_m.rpc_id(1, var_to_bytes([kind, args]))


func _send_u(kind: String, args: Array) -> void :
	if is_in():
		_u.rpc_id(1, var_to_bytes([kind, args]))




@rpc("any_peer", "reliable")
func _m(data: PackedByteArray) -> void :
	heard += data.size()


@rpc("any_peer", "reliable")
func _f(_seq: int, _i: int, _n: int, chunk: PackedByteArray) -> void :
	heard += chunk.size()


@rpc("any_peer", "unreliable")
func _u(data: PackedByteArray) -> void :
	heard += data.size()




static func make_info(i: int) -> Dictionary:
	var classes: Array = GameData.CLASSES.keys()
	var cls: String = classes[i % classes.size()]
	var job: Dictionary = GameData.job_looks(cls).pick_random()
	var look: Dictionary = GameData.DEFAULT_LOOK.duplicate()
	look["gender"] = "f" if randf() < 0.45 else "m"
	look["hair"] = randi_range(1, 23)
	look["hair_color"] = randi_range(0, 8)
	look["cloth"] = randi_range(0, 4)
	if job.has("job"):
		look["show"] = str(job.job.id)
	var items: = {}
	for slot in ["head", "mid", "low", "garment", "wings"]:
		var ids: Array = GameData.ITEMS.keys().filter( func(id): return str(GameData.ITEMS[id].get("slot", "")) == slot)
		if not ids.is_empty() and randf() < 0.7:
			items[slot] = Equipment.make(str(ids.pick_random()), 0)
	var rb: = []
	if randf() < 0.35:
		for l in GameData.REBIRTH_LV_LOOKS:
			if randf() < 0.3:
				rb.append(str(l.id))
	var name: = "%s%s%d" % [GameData.CROWD_NAMES_A.pick_random(), GameData.CROWD_NAMES_B.pick_random(), i]
	return {"name": name, "class": cls, "look": look, "views": Equipment.views_of(items, cls, {}, look), "room": "", 
		"rb": rb, "ra": randf() < 0.3, "lead": false, 

		"pet": str(GameData.PETS.keys().pick_random()) if randf() < 0.7 else ""}
