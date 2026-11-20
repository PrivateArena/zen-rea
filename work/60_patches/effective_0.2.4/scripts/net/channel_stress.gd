extends Node














const Bot = preload("res://scripts/net/channel_bot.gd")
const TownChannel = preload("res://scripts/net/town_channel.gd")

const ARRIVE_GAP: = 0.12

const CAM: = 54.0

const BURST_EVERY: = 20.0

const CHURN_EVERY: = 30.0
const CHURN_BACK: = 6.0
const CHURN_SIZE: = 5

const RUN: = 60.0
const SHOTS: = [12.0, 24.0, 33.0, 45.0]



const ADOPT_AT: = 48.0


const RECONNECT_AT: = 37.0
const ENTRY_AT: = 51.0

var world: World
var _bots: Array = []
var _label: Label
var _t: = 0.0
var _stat_t: = 0.0
var _burst_t: = BURST_EVERY
var _churn_t: = CHURN_EVERY
var _worst: = 0.0
var _frames: = 0
var _fps_log: Array = []
var _worst_log: Array = []
var _up: = 0
var _down: = 0
var _heard: = 0
var _adopted: = false
var _reconnected: = false

var _entry_t: = -1.0
var _entry_worst: = 0.0


func run(p_world: World, args: Array) -> void :
	world = p_world
	var at: = args.find("--chanstress")
	var n: = TownChannel.MAX_PLAYERS
	if args.size() > at + 1 and str(args[at + 1]).is_valid_int():
		n = clampi(int(args[at + 1]), 2, TownChannel.MAX_PLAYERS)
		at += 1
	var dir: = ""
	if args.size() > at + 1 and not str(args[at + 1]).begins_with("--"):
		dir = str(args[at + 1])
		DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	world.enter_town("swordsman")
	await wait.call(1.0)
	if not world.channel.join_enet(""):
		print("CHANSTRESS no channel: %s" % world.channel.error)
		get_tree().quit(1)
		return
	world._cam_distance = CAM
	_build_label()
	print("CHANSTRESS start players=%d" % n)
	var town: Town = world.town
	for i in n - 1:
		var bot: Node = Bot.new()
		bot.name = "Bot%d" % (i + 1)
		bot.town = town
		bot.center = town.hero.position
		bot.info = Bot.make_info(i)
		add_child(bot)
		_bots.append(bot)
		await wait.call(ARRIVE_GAP)
	if dir == "":
		return
	var shot: = 0
	while _t < RUN:
		await wait.call(0.25)
		if shot < SHOTS.size() and _t >= float(SHOTS[shot]):
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/chanstress_%02d.png" % [dir, int(SHOTS[shot])])
			shot += 1
		if _t >= RECONNECT_AT and not _reconnected:
			_reconnected = true
			world.channel._keep_town = true
			world.channel._keep_t = 0.0
			await wait.call(0.8)
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/chanstress_reconnect.png" % dir)
			print("CHANSTRESS reconnect notice=%s drawn=%d" % [world.town._crowd._reconnect.visible, _drawn()])
		if _t >= ADOPT_AT and not _adopted:
			_adopted = true
			_adopt_test()
		if _t >= ENTRY_AT and _entry_t < 0.0:
			_entry_test()
	var fps: Array = _fps_log.slice(3)
	var worst: Array = _worst_log.slice(3)
	print("CHANSTRESS end players=%d members=%d drawn=%d fps_avg=%.1f fps_min=%.0f worst_ms=%.1f" % [n, 
		world.channel.members.size(), _drawn(), _avg(fps), fps.min() if not fps.is_empty() else 0.0, 
		worst.max() if not worst.is_empty() else 0.0])
	get_tree().quit()


func _process(delta: float) -> void :
	if _bots.is_empty():
		return
	_t += delta
	_frames += 1
	_worst = maxf(_worst, delta)
	if _entry_t >= 0.0 and _entry_t < 10.0:
		_entry_t += delta
		_entry_worst = maxf(_entry_worst, delta)
		if _drawn() >= world.channel.members.size() - 1:
			print("CHANSTRESS entry drawn=%d in %.2f s worst_ms=%.1f" % [_drawn(), _entry_t, _entry_worst * 1000.0])
			_entry_t = 10.0
	_burst_t -= delta
	if _burst_t <= 0.0:
		_burst_t = BURST_EVERY
		for b in _bots:
			if b.is_in():
				b.say()
				b.emote()
	_churn_t -= delta
	if _churn_t <= 0.0:
		_churn_t = CHURN_EVERY
		var out: Array = _bots.filter( func(b): return b.is_in())
		out.shuffle()
		for b in out.slice(0, CHURN_SIZE):
			b.leave()
			get_tree().create_timer(CHURN_BACK, true, false, true).timeout.connect(b.connect_now)
	_stat_t += delta
	if _stat_t >= 1.0:
		_stat()



func _stat() -> void :
	var fps: = _frames / _stat_t
	var worst_ms: = _worst * 1000.0
	var peer: = world.channel._api.multiplayer_peer as ENetMultiplayerPeer
	if peer != null and peer.host != null:
		_up = int(peer.host.pop_statistic(ENetConnection.HOST_TOTAL_SENT_DATA) / _stat_t)
		_down = int(peer.host.pop_statistic(ENetConnection.HOST_TOTAL_RECEIVED_DATA) / _stat_t)
	var heard: = 0
	for b in _bots:
		heard += int(b.heard)
	var per_bot: = (heard - _heard) / _stat_t / maxf(1.0, _bots.size())
	_heard = heard
	_fps_log.append(fps)
	_worst_log.append(worst_ms)
	var members: = world.channel.members.size()
	_label.text = "Prueba de estrés · Canal %d: %d/%d en el canal · %d dibujados · %.0f FPS (peor cuadro %.1f ms)\nDueño: sube %.1f KB/s, recibe %.1f KB/s · cada jugador recibe %.1f KB/s · cuerpos en la plaza: %d" % [
		world.channel.number, members, TownChannel.MAX_PLAYERS, _drawn(), fps, worst_ms, _up / 1024.0, _down / 1024.0, 
		per_bot / 1024.0, _bodies()]
	if int(_t) % 5 == 0:
		print("CHANSTRESS t=%.0f members=%d drawn=%d fps=%.0f worst_ms=%.1f up_kbs=%.1f down_kbs=%.1f per_player_kbs=%.1f bodies=%d" % [
			_t, members, _drawn(), fps, worst_ms, _up / 1024.0, _down / 1024.0, per_bot / 1024.0, _bodies()])
	_stat_t = 0.0
	_frames = 0
	_worst = 0.0




func _adopt_test() -> void :
	var town: Town = world.town
	var ch: = world.channel
	var before: = {}
	for id in town._party:
		if int(id) < 0:
			before[town._party[id].node] = true
	var real: Dictionary = ch.members
	var moved: = {}
	for id in real:
		moved[int(id) + 1000000 if int(id) != 1 else 1] = real[id]
	ch.members = moved
	ch._sync_town()
	var kept: = town._party.values().filter( func(m): return before.has(m.node)).size()
	var shifted: = town._party.keys().filter( func(id): return int(id) < -1000000).size()
	ch.members = real
	ch._sync_town()
	var back: = town._party.values().filter( func(m): return before.has(m.node)).size()
	print("CHANSTRESS adopt drawn=%d kept_new_ids=%d (%d moved) kept_back=%d coming=%d" % [before.size(), kept, shifted, back, 
		town._coming.size()])




func _entry_test() -> void :
	world.town.sync_channel([])
	RoAssets._lock.lock()
	for id in RoAssets._sprites.keys():
		if str(id).begins_with("char:"):
			RoAssets._sprites.erase(id)
	RoAssets._lock.unlock()
	_entry_t = 0.0
	_entry_worst = 0.0
	world.channel._sync_town()



func _drawn() -> int:
	var town: Town = world.town
	if town == null or not is_instance_valid(town):
		return 0
	return town._party.keys().filter( func(id): return int(id) < 0).size()



func _bodies() -> int:
	var town: Town = world.town
	if town == null or not is_instance_valid(town) or town._crowd == null:
		return _drawn()
	return _drawn() + town._crowd._people.size()


func _avg(a: Array) -> float:
	if a.is_empty():
		return 0.0
	var s: = 0.0
	for v in a:
		s += float(v)
	return s / a.size()


func _build_label() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(12, 8)
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("outline_size", 5)
	layer.add_child(_label)
