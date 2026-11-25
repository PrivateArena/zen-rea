extends RefCounted



















const FREEZE_S: = 0.25

const FREEZE_LIST: = 8

const HIST_MS: = 1000
const LOW_FPS: = 40.0
const LOW_FOR: = 5.0
const STEP_GAP: = 8.0
const UP_FOR: = 45.0
const WINDOW_MAX: = 1.2


const STEPS: = [
	{"mob_shadows": false, "damage_numbers": "reduced"}, 
	{"fx_quality": 1, "fx_alpha_party": 0.5}, 
	{"fx_quality": 2, "fx_alpha_party": 0.3, "quality": 1}, 
	{"quality": 0}, 
]

var frames: = 0
var secs: = 0.0
var hist: = PackedInt32Array()
var freezes: = 0
var freeze_at: Array = []
var worst: = 0.0
var mobs_max: = 0

var level: = 0
var level_max: = 0
var _locked: = 0
var _win_t: = 0.0
var _win_n: = 0
var _low_t: = 0.0
var _high_t: = 0.0
var _since_step: = 999.0
var _last_frame: = -1


func reset() -> void :
	frames = 0
	secs = 0.0
	hist = PackedInt32Array()
	hist.resize(HIST_MS + 1)
	freezes = 0
	freeze_at = []
	worst = 0.0
	mobs_max = 0
	level_max = level
	_win_t = 0.0
	_win_n = 0
	_low_t = 0.0
	_high_t = 0.0
	_last_frame = -1



func frame(world: World, dt: float) -> void :
	var now: = Engine.get_process_frames()
	var eligible: = world.running and world.town == null and not world.get_tree().paused and not world._unfocused\
	and not world.training and DisplayServer.get_name() != "headless"


	var follows: = _last_frame >= 0 and now == _last_frame + 1
	_last_frame = now if eligible else -1
	if not eligible or not follows or dt <= 0.0:
		return
	if hist.size() != HIST_MS + 1:
		reset()
	frames += 1
	secs += dt
	hist[mini(HIST_MS, int(dt * 1000.0))] += 1
	worst = maxf(worst, dt)
	mobs_max = maxi(mobs_max, world.enemies.size())
	if dt >= FREEZE_S:
		freezes += 1
		if freeze_at.size() < FREEZE_LIST:
			freeze_at.append(roundi(world.time))
	_adapt(world, dt)




static func low_fps() -> float:
	return minf(LOW_FPS, frame_cap() * 0.66)






static func frame_cap() -> float:
	var cap: = 0.0
	if OS.has_feature("web"):

		var host = load(WEB_HOST)
		cap = float(Save.setting("web_fps", host.fps_default()))
	else:
		cap = float(Engine.max_fps)
	if cap <= 0.0 and (OS.has_feature("web") or DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED):
		cap = DisplayServer.screen_get_refresh_rate()
	if cap <= 0.0:
		cap = 60.0
	return cap


const WEB_HOST: = "res://scripts/core/web_host.gd"


func _adapt(world: World, dt: float) -> void :
	_since_step += dt
	_win_t += dt
	_win_n += 1
	if _win_t < 1.0:
		return
	var fps: = _win_n / _win_t


	var span: = minf(_win_t, WINDOW_MAX)
	_win_t = 0.0
	_win_n = 0
	if not bool(Save.setting("adaptive_gfx", GameData.adaptive_gfx_default())):
		return
	var low: = low_fps()
	if fps < low:
		_low_t += span
		_high_t = 0.0
	elif fps >= low * 1.4:
		_high_t += span
		_low_t = 0.0
	else:
		_low_t = 0.0
		_high_t = 0.0
	if _low_t >= LOW_FOR and _since_step >= STEP_GAP and level < STEPS.size():
		_step(world, level + 1)
	elif _high_t >= UP_FOR and level > _locked and _since_step >= UP_FOR:
		_step(world, level - 1)


func _step(world: World, to: int) -> void :
	var down: = to > level

	if down and to <= _peak_up:
		_locked = to
	if not down:
		_peak_up = maxi(_peak_up, level)
	level = to
	level_max = maxi(level_max, level)
	_since_step = 0.0
	_low_t = 0.0
	_high_t = 0.0
	apply(world)
	if down:
		world.hud.announce(TranslationServer.translate("Gráficos adaptativos"), Color(0.75, 0.85, 1.0), 
			TranslationServer.translate("El juego iba lento: menos efectos y calidad (Opciones > Gráficos)."))
	print("ADAPTIVE level %d (fps low %.0f) at t=%.1f" % [level, low_fps(), world.time])


var _peak_up: = 0



func apply(world: World) -> void :

	for k in STEPS.reduce( func(acc, s): return acc + (s as Dictionary).keys(), []):
		Save.session_over.erase(k)
	var over: = {}
	for i in level:
		for k in STEPS[i]:
			over[k] = STEPS[i][k]

	var mine: = world.perf_values()
	for k in over.keys():
		match k:
			"fx_quality":
				over[k] = maxi(int(over[k]), int(mine.fx_quality))
			"quality":
				over[k] = mini(int(over[k]), int(mine.quality))
			"fx_alpha_party":
				over[k] = minf(float(over[k]), float(mine.fx_alpha_party))
			"damage_numbers":
				if str(mine.damage_numbers) == "none":
					over.erase(k)
			"mob_shadows":
				pass

	for k in over.keys():
		if Save.session_chosen.has(k):
			over.erase(k)
	Save.session_over.merge(over, true)
	world.apply_video_settings()
	world.apply_audio_settings()



func report(world: World) -> Dictionary:
	var fps: = frames / secs if secs > 0.0 else 0.0

	var low1: = 0.0
	if frames > 0:
		var need: = maxi(1, ceili(frames * 0.01))
		var n: = 0
		for ms in range(HIST_MS, -1, -1):
			n += hist[ms]
			if n >= need:
				low1 = 1000.0 / maxf(1.0, float(ms) + 0.5)
				break
	var r: = machine()
	r.merge({"fps": roundi(fps), "low1": roundi(low1), "worst": roundi(worst * 1000.0), "frz": freezes, "frz_at": freeze_at, 
		"mobs": mobs_max, "adapt": level_max, "q": world.quality_level(), "fxq": clampi(int(Save.setting("fx_quality", 0)), 0, 3), 
		"perf_mode": bool(Save.setting("perf_mode", false))})
	return r




static func machine() -> Dictionary:
	var mem: Dictionary = OS.get_memory_info()
	return {"r": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name().left(60), 
		"cores": OS.get_processor_count(), "ram": snappedf(float(mem.get("physical", 0)) / 1073741800.0, 0.1)}
