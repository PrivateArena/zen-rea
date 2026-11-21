class_name World
extends Node





const DEFAULT_STAGE: = "prontera"
const CELL: = 2.0
const CAMERA_PITCH: = deg_to_rad(52.0)


const SPRITE_LIFT: = 0.7




const LIFT_UP_MIN: = 0.3
const LIFT_MAX: = 1.9


static func sprite_lift(pitch: float) -> float:
	return clampf(LIFT_UP_MIN / maxf(sin(pitch), 0.05), SPRITE_LIFT, LIFT_MAX)
const MUSIC_DB: = -14.0

const FX_CAP: = 5

const FX_CAP_ALLY: = 2


const FX_CAP_ALLY_TOWER: = 5




func ally_fx_cap() -> int:
	return FX_CAP_ALLY_TOWER if tower != null and not str(damage_tag).begins_with("proc:") else FX_CAP_ALLY




const PROC_BOLTS_SHOWN: = 4




func _foreign_fx() -> bool:
	if Vfx.foreign:
		return true
	return Vfx.hero and heroes.size() > 1 and damage_by != null and is_instance_valid(damage_by) and damage_by != player

const SKILL_SOUND_CD: = 0.9
const UiStyles = preload("res://scripts/ui/ro_ui_styles.gd")


const TownChannel = preload("res://scripts/net/town_channel.gd")
const MobTraits = preload("res://scripts/core/mob_traits.gd")
const RO_UI_FONT = preload("res://assets/ro/fonts/SCDream4.otf")

var map: RoMap

var stage_id: = DEFAULT_STAGE
var stage: Dictionary = GameData.STAGES[DEFAULT_STAGE]
var camera: Camera3D
var run_root: Node3D
var fx_root: Node3D
var hud: Hud
var menus: Menus

var raid: MvpRaid

var morroc: MorrocEvent

var quest: QuestRun
var altars: Altars
var karma: Karma
var weather: Weather

var board: Leaderboard

var cloud: Node

var friends: Node

var titles: Node

var run_mvps: = 0

var first_mvp_time: = -1.0

var run_bosses: = 0

const METER_DOTS: = {"poison": "Veneno de %s", "burn": "Quemadura de %s", "bleed": "Sangrado de %s"}

var _shadow_hit: = false


var _ki_chaining: = false
var _ki_trace_at: = 0.0

var _shadow_trace_at: = 0.0
const SHADOW_TRACE_GAP: = 0.07

var _kunai_n: = 1

var _lethal_fx_at: = 0.0
var _lethal_spark_at: = 0.0
var _combo_word_at: = 0.0
var _lucky_chest_at: = 0.0

var flow: = FlowField.new()

var newly_unlocked: = ""

var mouse_walk: MouseWalk

var town: Town


var player: Player
var heroes: Array[Player] = []


var coop_classes: Array[String] = []

var flows: Array[FlowField] = []



var damage_by: Player:
	set(v):




		damage_by = v if v != null else _turn_hero

var _turn_hero: Player


var meter_hero: Array[Dictionary] = []
var unowned: = {}

var net: NetSync

var channel: TownChannel


var loot_queue: Array[LootRoll] = []


var held_chests: Array = []
var _loot: LootRoll
var _loot_panel: LootPanel
var _coop_down_at: = 0.0
var _coop_chest_at: = 0.0
var enemies: Array[Enemy] = []
var projectiles: Array[Dictionary] = []

var enemy_shots: Array[Dictionary] = []

var poisoned: Array = []





var meter: = {}


var crit_bonus: = 0.0
var crit_dmg_bonus: = 1.0
var damage_tag: = ""


var hurt_what: = ""


var hurt_mob: = 0
var meter_stats: = {}




var calc_watch: = ""
var calc_last: = {}

var meter_boss: = {}

var meter_boss_hero: = {}


var resume_picks: = {}

var meter_taken: = {}




var meter_taken_hero: = {}
var meter_heal_hero: = {}

var meter_details: MeterDetails

var _endless_start: = 0.0


var endless: = false



var speed: = 1
var fast_mode: bool:
	get:
		return speed > 1
	set(v):
		speed = 2 if v else 1




var corrupt_auto: = ""

var traits = MobTraits.new()

var stagger = preload("res://scripts/core/stagger.gd").new()

var perf = preload("res://scripts/core/perf_watch.gd").new()

var hell_late = preload("res://scripts/core/hell_late.gd").new(self)

const Encore = preload("res://scripts/core/encore.gd")
var encore = Encore.new()




const Oaths = preload("res://scripts/core/oaths.gd")


const Forge = preload("res://scripts/core/forge.gd")

const JobEngines = preload("res://scripts/core/job_engines.gd")
const HomunCombo = preload("res://scripts/core/homun_combo.gd")
var oaths: = {}
var oaths_next: Variant = null
var oath_run = Oaths.new()



func oath(id: String) -> int:
	return int(oaths.get(id, 0))



func oath_points() -> int:
	return GameData.oath_points(oaths)




func oath_zeny() -> float:
	return 1.0 + GameData.OATH_ZENY * oath_points()


func oath_mats() -> float:
	return 1.0 + GameData.OATH_MATS * oath_points()



func star_crumb_chance(e: Enemy) -> float:
	if e.def.get("mvp", false):
		return GameData.STAR_CRUMB_MVP
	if tower != null:

		return tower.hel.crumb_chance() if tower.hel != null else GameData.STAR_CRUMB_KILL


	var h: = GameData.hell_level(danger)
	if festival_mode or h < GameData.STAR_CRUMB_HELL_FROM:
		return 0.0
	return GameData.STAR_CRUMB_HELL + GameData.STAR_CRUMB_HELL_STEP * (h - GameData.STAR_CRUMB_HELL_FROM) + GameData.STAR_CRUMB_OATH_STEP * oath_points()



func hell_pace() -> float:
	return GameData.oath_value("hellfire", oath("hellfire"))


var hard_mode: = false
var hard: = false


var danger: = 1
var featured: = false

var _feroz_timer: = 0.0
var pace: = 1.0

var frenzy: = false
var _frenzy_scaled: = false





var game_fast: = false


var fast_now: = false

var run_fast_s: = 0.0

var _speed_applied: = 1.0




static var _game_ms: = 0.0
var _endless_next: = 0.0
var _endless_count: = 0


var _endless_rush: = -1.0


var peak_hit: = 0.0
var _endless_mix: = 0.0

var _hell_rain: = 0.0

var _storm: = 0.0

var _hell_revenge_at: = -9.0

var runner: Enemy
var _runner_timer: = 0.0


var card_memory: = {}

var run_ymir: = 0

var zeny_from: = {}

var run_materials: = {}

var run_coins: = 0

var run_mob_coins: = 0





func found_coin(show: = true) -> void :
	if training:
		return
	Save.add_coins(1)
	run_coins += 1
	if show and player != null:
		number(player.position + Vector3(0, 3.0, 0), tr("+1 Poring Coin"), Color(1.0, 0.82, 0.3), true)
		play_sound("coin3", 0.0, -2.0)
	if hud != null:
		hud.prize("poring_coin", tr("+1 Poring Coin  ·  tienes %d") % Save.coins(), Color(0.6, 0.4, 0.0))


func gain_material(id: String, n: = 1) -> void :
	if training:
		return
	Save.add_material(id, n)
	run_materials[id] = int(run_materials.get(id, 0)) + n
	prize_shown(id, n)

	if net.is_host():
		for h in heroes:
			if h != player:
				net.send_got(h, "material", [id, n])




func prize_shown(id: String, n: int) -> void :
	if hud == null or not GameData.MATERIALS.has(id):
		return
	var col: Color = UiKit.GOLD if id == "star_crumb" else (Color(0.5, 0.28, 0.78) if id == "hel_tear" else (GameData.HEL_WINGS_COLOR.darkened(0.3) if id == GameData.HEL_WINGS_ITEM else Color(0.25, 0.4, 0.7)))
	hud.prize(str(GameData.MATERIALS[id].icon), tr("+%d %s  ·  tienes %d") % [n, tr(str(GameData.MATERIALS[id].name)), Save.material(id)], col)


func add_zeny(z: int, source: String, hero: Player = null) -> void :
	if z <= 0:
		return
	if hero != null and hero != player:
		hero.purse += z
		return

	if net.is_client():
		net.send_zeny(z)
		return
	run_zeny += z


	if not training:
		Save.add_zeny(z)
	zeny_from[source] = int(zeny_from.get(source, 0)) + z




func spend_run_zeny(z: int) -> bool:
	if z <= 0:
		return true

	var h: = acting_hero()
	if h != player:
		if h.purse < z:
			return false
		h.purse -= z
		return true
	if run_zeny < z or ( not training and not Save.pay(z)):
		return false
	run_zeny -= z
	zeny_from["spent"] = int(zeny_from.get("spent", 0)) + z
	return true


var _broke_at: = -99.0



func zeny_of(h: Player) -> int:
	return run_zeny if h == player else h.purse




func broke_notice(p: Player, skill_name: = "Mammonite") -> void :

	if time < 60.0 or time - _broke_at < 8.0:
		return
	_broke_at = time
	label_over(p, tr("¡Sin zeny! %s pega menos") % tr(skill_name.trim_suffix(" EX")), Color(1.0, 0.75, 0.4))
	emote(p, "sweat")


var _stage_card_mobs: = {}

var pet: RoVisual
var pet_id: = ""

var homun: Homunculus

const STATUS_FX: = {"freeze": "freezed", "stone": "stonecurse", "stun": "stun", "sleep": "sleep"}

var special_mult: = 1.0

var smoke_stats: = {"tame_ok": 0, "tame_fail": 0, "dead": 0, "bloody": 0, "status": 0, "miss": 0, "weak": 0}
const STATUS_SOUND: = {"freeze": "frost_hit", "stone": "stone_curse", "stun": "stun"}
var pickups: Array[Dictionary] = []
var boss: Enemy

var tower: TowerRun
var time: = 0.0
var kills: = 0

var run_zeny: = 0
var _stats_banked: = false
var running: = false



var training: = false



var festival_mode: = false
var festival: Node = null
var meter_from: = 0.0




var meter_view: = {}
var autopilot: = false



const MobGrid: = preload("res://scripts/core/mob_grid.gd")

const SoulLinker: = preload("res://scripts/core/soul_linker.gd")
var mob_grid: MobGrid = MobGrid.new(self)
var _shadow_buf: = PackedFloat32Array()


const FAR_TICK_DIST: = 24.0



var _grid_fresh: = false



const REFRESH_EVERY: = 3
var frame_parity: = 0

var morroc_fight: = false
var _shadows: MultiMeshInstance3D
var mob_renderer: MobRenderer


var gem_renderer: GemRenderer
var _gem_looks: = {}
var _spawn_timers: = {}
var _event_index: = 0


var _mvp_ran_early: = false
var _shake: = 0.0
var _cam_distance: = 42.0

var _cam_off: = Vector3.ZERO

var valhalla: Node

var _turning: = false
var _turn_tween: Tween

const TURN_SPEED: = 0.008
var _numbers: = 0



var clock: = 0.0
var _number_clock: = 0.0
var _number_buckets: = {}



var _number_stacks: = {}
var _sound_players: Array[AudioStreamPlayer] = []
var _sound_last: = {}
var _smoke_seconds: = 0.0
var _smoke_ended: = false
var showcase: = false

const ITCH_LOOKS: = {
	"swordsman:0": {"gender": "m", "hair": 3, "hair_color": 4, "cloth": 1}, 
	"swordsman:1": {"gender": "f", "hair": 6, "hair_color": 6, "cloth": 2}, 
	"mage:0": {"gender": "f", "hair": 7, "hair_color": 2, "cloth": 1}, 
	"mage:1": {"gender": "m", "hair": 12, "hair_color": 5, "cloth": 3}, 
	"archer:0": {"gender": "m", "hair": 10, "hair_color": 6, "cloth": 2}, 
	"archer:1": {"gender": "f", "hair": 9, "hair_color": 1, "cloth": 1}, 
	"thief:0": {"gender": "m", "hair": 12, "hair_color": 5, "cloth": 1}, 
	"thief:1": {"gender": "f", "hair": 2, "hair_color": 7, "cloth": 3}, 
	"acolyte:0": {"gender": "f", "hair": 4, "hair_color": 3, "cloth": 2}, 
	"acolyte:1": {"gender": "m", "hair": 1, "hair_color": 8, "cloth": 1}, 
	"merchant:0": {"gender": "m", "hair": 6, "hair_color": 7, "cloth": 2}, 
	"merchant:1": {"gender": "f", "hair": 11, "hair_color": 4, "cloth": 1}, 
	"gunslinger:0": {"gender": "f", "hair": 11, "hair_color": 8, "cloth": 1}, 
}




var fx_alpha_run: = 1.0
var fx_alpha_boss: = 1.0


var fx_alpha_party: = 1.0
var own_fx_alpha: float:
	get:
		return fx_alpha_boss if raid != null and raid.in_arena() else fx_alpha_run





func hero_fx_alpha(h) -> float:
	if h == null or not is_instance_valid(h) or h == player:
		return own_fx_alpha
	return own_fx_alpha * fx_alpha_party
var _ap_dir: = Vector2.ZERO
var _ap_hold: = 0.0
var _ap_stuck_t: = 0.0
var _ap_last: = Vector3.ZERO
var _level_up_delay: = 0.0
var _music: AudioStreamPlayer
var _music_track: = ""
var _music_tween: Tween
var _slope_test: = false
var _smoke_minute: = 0



var _tower_sim: = false
var _perf: = {"pre": 0, "director": 0, "player": 0, "enemies": 0, "mobdraw": 0, "projectiles": 0, "pickups": 0, "frames": 0, 
	"grid": 0, "flow": 0, "tick": 0, "shadows": 0, "render": 0, "frame": 0, "world": 0}

static var bench: = false

static var bench_fx: = 0
static var bench_hud: = 0


var _mob_bench: = 0
var _fx_live: = {}
var _bolts: Array[Dictionary] = []

var _zones: Array[Dictionary] = []

var _traps: Array[Dictionary] = []
var _trap_sound_at: = 0.0
var _orbits: Array[Dictionary] = []

var summons: = Summons.new()

var dots: = Dots.new()


var dot_color: = Color(0, 0, 0, 0)

var dot_can_crit: = false

var doram: = Doram.new()
var _barrier: Sprite3D
var _holy_cache: = {}
var _shot_dir: = ""
var _shot_times: Array[float] = []







const BOOT_GUARD: = preload("res://scripts/core/boot_guard.gd")
const ANGLE_DEVICES: = [{"vendor": "ATI Technologies Inc.", "name": "*"}, {"vendor": "AMD", "name": "*"}, 
	{"vendor": "Advanced Micro Devices, Inc.", "name": "*"}]


func _angle_for_amd() -> bool:
	if OS.get_name() != "Windows" or OS.has_feature("editor") or RenderingServer.get_current_rendering_driver_name() != "opengl3":
		return false
	var vendor: = RenderingServer.get_video_adapter_vendor()
	if not (vendor.contains("ATI") or vendor.contains("AMD") or vendor.contains("Advanced Micro")):
		return false
	var path: = OS.get_executable_path().get_base_dir().path_join("override.cfg")


	if FileAccess.file_exists(path):
		return false
	var cfg: = ConfigFile.new()
	cfg.set_value("rendering", "gl_compatibility/force_angle_on_devices", ANGLE_DEVICES)
	if cfg.save(path) != OK:
		return false
	print("ANGLE: AMD card on OpenGL, override.cfg written, restarting")
	OS.set_restart_on_exit(true, OS.get_cmdline_args())
	get_tree().quit()
	return true


func _ready() -> void :
	if _angle_for_amd():
		return


	get_tree().create_timer(BOOT_GUARD.SAFE_SECS, true, false, true).timeout.connect(BOOT_GUARD.safe)



	get_window().title = "Midgard Survivors" + (" - Cooperativo (prueba)" if NetSync.coop_preview() else "")


	get_tree().process_frame.connect(_frenzy_time_scale)
	randomize()
	net = NetSync.new()
	net.name = "Net"
	net.world = self
	add_child(net)
	channel = TownChannel.new()
	channel.name = "Channel"
	channel.world = self
	add_child(channel)
	_start_memlog()
	var coffee: = preload("res://scripts/ui/coffee_button.gd").new()
	coffee.world = self
	add_child(coffee)
	var bar: = PartyBar.new()
	add_child(bar)
	bar.setup(self)
	Vfx.net_record = func(ev: Array):
		if net.recording():
			net.record(ev)
	for a in OS.get_cmdline_user_args():
		if str(a) == "--coop":
			coop_classes = ["swordsman"]
		elif str(a).begins_with("--coop="):
			for c in str(a).substr(7).split(",", false):
				if GameData.CLASSES.has(c):
					coop_classes.append(c)
		elif str(a).begins_with("--coop-down="):
			_coop_down_at = float(str(a).substr(12))
		elif str(a).begins_with("--mvp-at="):

			GameData.set_meta("mvp_at", float(str(a).substr(9)))
		elif str(a).begins_with("--coop-chest="):
			_coop_chest_at = float(str(a).substr(13))
		elif str(a).begins_with("--loot-auto="):

			Save.set_setting("loot_auto", str(a).substr(12))
	_build_scene()

	add_child(HoverCard.new())




	if OS.has_feature("editor"):
		add_child(load("res://scripts/ui/debug_menu.gd").new(self))
	var args: = OS.get_cmdline_user_args()
	if "--dump-chars" in args:
		_dump_chars(args[args.find("--dump-chars") + 1])
		return
	if "--evo-test" in args:
		_evo_test()
		return
	if "--web-tour" in args:
		var tour: Node = load("res://scripts/core/web_tour.gd").new()
		tour.set("world", self)
		tour.set("mode", args[args.find("--web-tour") + 1] if args.size() > args.find("--web-tour") + 1 else "")
		add_child(tour)
	if "--skill-tour" in args:
		var at_tour: = args.find("--skill-tour")
		_skill_tour(args[at_tour + 1], args[at_tour + 2] if args.size() > at_tour + 2 and not args[at_tour + 2].begins_with("--") else "")
	elif "--fx-tour" in args:
		_fx_tour(args[args.find("--fx-tour") + 1])
	elif "--quests-test" in args:
		_quests_test(args[args.find("--quests-test") + 1])
	elif "--train-test" in args:
		_train_test(args[args.find("--train-test") + 1])
	elif "--towerpace-test" in args:
		_towerpace_test()
	elif "--feat-test" in args:
		_feat_test(args[args.find("--feat-test") + 1])
	elif "--festival-test" in args:
		_festival_test(args[args.find("--festival-test") + 1])
	elif "--titles-test" in args:
		_titles_test(args[args.find("--titles-test") + 1])
	elif "--skillbench" in args:
		_skillbench()
	elif "--sagebench" in args:
		_sagebench(args[args.find("--sagebench") + 1])
	elif "--padnav-test" in args:
		_padnav_test(args[args.find("--padnav-test") + 1])
	elif "--autoequip-test" in args:
		_autoequip_test(args[args.find("--autoequip-test") + 1])
	elif "--tips-test" in args:
		_tips_test(args[args.find("--tips-test") + 1])
	elif "--padhints-test" in args:
		_padhints_test(args[args.find("--padhints-test") + 1])
	elif "--festskills-test" in args:
		var at_fs: = args.find("--festskills-test")
		_festskills_test(args[at_fs + 1] if args.size() > at_fs + 1 and not args[at_fs + 1].begins_with("--") else "")
	elif "--asura-test" in args:
		_asura_test(args[args.find("--asura-test") + 1])
	elif "--bscut-test" in args:
		_bscut_test()
	elif "--storefilter-test" in args:
		_storefilter_test(args[args.find("--storefilter-test") + 1])
	elif "--fxprobe-test" in args:
		_fxprobe_test(args[args.find("--fxprobe-test") + 1])
	elif "--mvp-icons" in args:
		var dir: String = args[args.find("--mvp-icons") + 1]
		DirAccess.make_dir_recursive_absolute(dir)
		for mob in GameData.RAIDS:
			var tex: = StagePreview._cropped(mob)
			if tex != null:
				tex.get_image().save_png("%s/%s.png" % [dir, mob])
			else:
				print("NOICON ", mob)
		get_tree().quit()
	elif "--revive-test" in args:
		_revive_test(args[args.find("--revive-test") + 1])
	elif "--downmark-test" in args:
		_downmark_test(args[args.find("--downmark-test") + 1])
	elif "--weather-test" in args:
		_weather_test(args[args.find("--weather-test") + 1])
	elif "--hell-test" in args:
		_hell_test(args[args.find("--hell-test") + 1])
	elif "--wiz-test" in args:
		_wiz_test(args[args.find("--wiz-test") + 1])
	elif "--sl-test" in args:
		_sl_test(args[args.find("--sl-test") + 1])
	elif "--sl-rework" in args:
		SoulLinker.shots_test(self, args[args.find("--sl-rework") + 1])
	elif "--sl-bench" in args:
		SoulLinker.bench(self, args)
	elif "--kage-test" in args:
		_kage_test(args[args.find("--kage-test") + 1], "--female" in args)
	elif "--smith-test" in args:
		_smith_test(args[args.find("--smith-test") + 1])
	elif "--alch-test" in args:
		_alch_test(args[args.find("--alch-test") + 1])
	elif "--diff-test" in args:
		_diff_test()
	elif "--dmg-test" in args:
		_dmg_test(args[args.find("--dmg-test") + 1])
	elif "--ui-tour" in args:
		_ui_tour(args[args.find("--ui-tour") + 1])
	elif "--raid-mech" in args:
		var at: = args.find("--raid-mech")
		_raid_mech(args[at + 1], args[at + 2], args[at + 3])
	elif "--album-tour" in args:
		_album_tour(args[args.find("--album-tour") + 1])
	elif "--levelup-tour" in args:
		_levelup_tour(args[args.find("--levelup-tour") + 1])
	elif "--picks-tour" in args:
		_picks_tour(args[args.find("--picks-tour") + 1])
	elif "--intro-tour" in args:
		_intro_tour(args[args.find("--intro-tour") + 1])
	elif "--touch-test" in args:
		_touch_test(args[args.find("--touch-test") + 1])
	elif "--inspect-test" in args:
		_inspect_test(args[args.find("--inspect-test") + 1])
	elif "--selectfps-test" in args:
		_selectfps_test()
	elif "--menus-tour" in args:
		_menus_tour(args[args.find("--menus-tour") + 1])
	elif "--hud-tour" in args:
		_hud_tour(args[args.find("--hud-tour") + 1])
	elif "--raid-tour" in args:
		var at: = args.find("--raid-tour")
		_raid_tour(args[at + 1], args[at + 2] if args.size() > at + 2 else "")
	elif "--trailer" in args:
		var shots: Node = load("res://scripts/core/trailer.gd").new()
		add_child(shots)
		shots.run(self, Array(args))
	elif "--clip" in args:
		_clip(args)
	elif "--itch-art" in args:
		_itch_art(args[args.find("--itch-art") + 1], args)
	elif "--showcase" in args:
		_showcase(args)
	elif "--gameplay-reel" in args:
		_gameplay_reel(args)
	elif "--smoke" in args:
		_start_smoke(args)
	elif Array(args).any( func(a): return str(a).begins_with("--net-town=")):
		_net_town_test(Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--tradenet=")):
		_trade_net_test(Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--festnet=")):
		_fest_net_test(Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--towernet=")):
		_tower_net_test(Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--kicktest=")):
		_kick_test(args)
	elif Array(args).any( func(a): return str(a).begins_with("--chantest=")):
		_channel_test(Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--hotest=")):
		_handoff_test(Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--coopquick=")):
		_quick_relay_test(Array(args))
	elif "--chanstress" in args:
		var stress: Node = load("res://scripts/net/channel_stress.gd").new()
		add_child(stress)
		stress.run(self, Array(args))
	elif Array(args).any( func(a): return str(a).begins_with("--net-join=")):
		_net_test_join(Array(args))
	elif "--job-shots" in args:
		var at_js: = args.find("--job-shots")
		_job_shots(args[at_js + 1], args[at_js + 2], int(args[at_js + 3]))
	elif "--clutter-shots" in args:
		var at_cs: = args.find("--clutter-shots")
		_clutter_shots(args[at_cs + 1], args[at_cs + 2], int(args[at_cs + 3]), float(args[at_cs + 4]), 
			str(args[at_cs + 5]).split(",") if args.size() > at_cs + 5 and not str(args[at_cs + 5]).begins_with("--") else [])
	elif "--emotepick-test" in args:
		_emotepick_test(args[args.find("--emotepick-test") + 1])
	elif "--zoom-test" in args:
		_zoom_test(args[args.find("--zoom-test") + 1])
	elif "--opttabs-test" in args:
		_opttabs_test(args[args.find("--opttabs-test") + 1])
	elif Array(args).any( func(a): return str(a).begins_with("--presence=")):
		_presence_test(args)
	elif "--loadart-test" in args:
		_loadart_test(args[args.find("--loadart-test") + 1])
	elif "--charpage-test" in args:
		_charpage_test(args[args.find("--charpage-test") + 1])
	elif "--closeup-test" in args:
		_closeup_test(args[args.find("--closeup-test") + 1])
	elif "--beam-test" in args:
		_beam_test(args[args.find("--beam-test") + 1])
	elif "--npcline-test" in args:
		_npcline_test(args[args.find("--npcline-test") + 1])
	elif "--town-test" in args:
		_town_test(args[args.find("--town-test") + 1])
	elif "--devname-test" in args:
		_devname_test(args[args.find("--devname-test") + 1])
	elif "--quest-tour" in args:
		_quest_tour(args[args.find("--quest-tour") + 1])
	elif "--save-test" in args:
		_save_test()
	elif "--boot-test" in args:

		menus.show_login()
		_shot_dir = args[args.find("--boot-test") + 1]
		DirAccess.make_dir_recursive_absolute(_shot_dir)
		_boot_loading()
		await get_tree().create_timer(1.2).timeout
		await _tour_shot("boot_loading")
		get_tree().quit()
	else:
		menus.show_login()










func _boot_loading() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var root: = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(root)
	var bg: = ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var pic: = TextureRect.new()
	var full: = load("res://assets/ro/ui/loading/loading00.png") as Texture2D
	if full != null:

		var cut: = AtlasTexture.new()
		cut.atlas = full
		cut.region = Rect2(0, 0, full.get_width(), full.get_height() * 438.0 / 480.0)
		pic.texture = cut
	pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(pic)
	var view: = get_viewport().get_visible_rect().size
	var k: = maxf(1.0, floorf(view.y / 700.0))

	var plate: = PanelContainer.new()
	var pb: = StyleBoxFlat.new()
	pb.bg_color = Color(0.02, 0.03, 0.08, 0.78)
	pb.border_color = Color(0.85, 0.7, 0.35, 0.8)
	pb.set_border_width_all(1)
	pb.set_corner_radius_all(4)
	pb.content_margin_left = 12
	pb.content_margin_right = 12
	pb.content_margin_top = 10
	pb.content_margin_bottom = 8
	plate.add_theme_stylebox_override("panel", pb)
	plate.scale = Vector2(k, k)
	root.add_child(plate)
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.custom_minimum_size.x = 440
	plate.add_child(box)
	var bar: = UiStyles.round_gauge("blue", 440, 14)
	box.add_child(bar)
	var head: = HBoxContainer.new()
	box.add_child(head)
	var title: = _boot_label(tr("Cargando..."), 14, Color(1.0, 0.92, 0.6))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var pct: = _boot_label("0%", 13, Color.WHITE)
	head.add_child(pct)
	plate.position = Vector2(floorf((view.x - 464.0 * k) * 0.5), view.y - 92.0 * k)

	var poring: = TextureRect.new()
	poring.texture_filter = RoAssets.ui_filter()
	poring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	poring.scale = Vector2(k, k)
	root.add_child(poring)
	var ro: = RoAssets.sprite(["poring"])
	var walk: = RoVisual.MOB_WALK * RoSprite.DIRS + 6
	menus.set_process_unhandled_input(false)
	var ids: Array = GameData.MONSTERS.keys().filter( func(id): return not GameData.MONSTERS[id].has("boss")).slice(0, 30)
	var t_start: = Time.get_ticks_msec()
	for i in ids.size():
		var t0: = Time.get_ticks_msec()
		mob_renderer.prepare(ids[i])
		bar.value = 100.0 * (i + 1) / ids.size()
		pct.text = "%d%%" % roundi(bar.value)
		if ro != null:
			var n: = maxi(1, ro.frame_count(walk))
			var f: = int((Time.get_ticks_msec() - t_start) / 90.0) % n
			poring.texture = ro.get_frame(walk, f)
			var fw: = float(ro.canvas_size.x)
			var bar_at: = plate.position + (box.position + bar.position) * k
			poring.position = Vector2(bar_at.x + 440.0 * k * bar.value / 100.0 - fw * 0.5 * k, 
				bar_at.y - (float(ro.origin.y) - 3.0) * k)

		if Time.get_ticks_msec() - t0 > 4 or i % 3 == 2:
			await get_tree().process_frame
	menus.set_process_unhandled_input(true)
	var tw: = root.create_tween()
	tw.tween_interval(0.25)
	tw.tween_property(root, "modulate:a", 0.0, 0.35)
	tw.tween_callback(layer.queue_free)


func _boot_label(text: String, size: int, color: Color) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", RO_UI_FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _build_scene() -> void :
	var env: = Environment.new()
	env.background_mode = Environment.BG_COLOR


	env.background_color = Color(0.16, 0.2, 0.11)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.58, 0.58, 0.6)
	env.ambient_light_energy = 1.0 * Vfx.light_k()
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var we: = WorldEnvironment.new()
	we.environment = env
	add_child(we)

	map = RoMap.new()
	add_child(map)
	map.load_map(stage.map)
	if not map.has_sun:
		var sun: = DirectionalLight3D.new()
		sun.rotation = Vector3(deg_to_rad(-55), deg_to_rad(-35), 0)
		sun.light_energy = 0.8 * Vfx.sun_k()
		add_child(sun)

	RoVisual.lift = Vector3(0, sin(CAMERA_PITCH), cos(CAMERA_PITCH)) * SPRITE_LIFT
	camera = Camera3D.new()
	camera.fov = 30.0
	camera.far = 600.0
	add_child(camera)
	_sky = _make_sky()
	add_child(_sky)
	mouse_walk = MouseWalk.new()
	mouse_walk.world = self
	add_child(mouse_walk)
	if MouseWalk.touch():


		add_child(load("res://scripts/ui/touch_scroll.gd").new())
		var th: Node = load("res://scripts/ui/touch_help.gd").new()
		th.world = self
		add_child(th)

	var pad: Node = load("res://scripts/core/gamepad.gd").new()
	pad.set("world", self)
	add_child(pad)
	set_meta("gamepad", pad)
	var cursor: = RoCursor.new()
	cursor.world = self
	add_child(cursor)

	run_root = Node3D.new()
	add_child(run_root)

	gem_renderer = GemRenderer.new()
	add_child(gem_renderer)
	RoAssets.register_sound("gem_ding", GemRenderer.ding_stream())
	RoAssets.register_sound("zeny_ting", World.zeny_ting_stream())
	_build_shadows()
	mob_renderer = MobRenderer.new()
	add_child(mob_renderer)


	fx_root = Node3D.new()
	add_child(fx_root)
	raid = MvpRaid.new()
	raid.world = self
	add_child(raid)
	morroc = MorrocEvent.new()
	morroc.world = self
	add_child(morroc)
	quest = QuestRun.new()
	quest.world = self
	add_child(quest)
	altars = Altars.new()
	altars.world = self
	add_child(altars)
	karma = Karma.new()
	karma.world = self
	add_child(karma)
	weather = Weather.new()
	weather.world = self
	add_child(weather)
	board = Leaderboard.new()
	add_child(board)

	cloud = load("res://scripts/core/cloud_save.gd").new()
	cloud.world = self
	add_child(cloud)
	friends = load("res://scripts/core/friends.gd").new()
	friends.world = self
	add_child(friends)
	titles = load("res://scripts/core/titles.gd").new()
	titles.world = self
	add_child(titles)

	if OS.has_feature("web"):
		web = load("res://scripts/core/web_host.gd").new()
		web.set("world", self)
		add_child(web)

	_ensure_bus("Music")
	_ensure_bus("SFX")
	for i in 10:
		var sp: = AudioStreamPlayer.new()
		sp.volume_db = -8.0

		sp.process_mode = Node.PROCESS_MODE_ALWAYS
		sp.bus = "SFX"
		add_child(sp)
		_sound_players.append(sp)
	_music = AudioStreamPlayer.new()
	_music.volume_db = MUSIC_DB
	_music.bus = "Music"
	_music.process_mode = Node.PROCESS_MODE_ALWAYS


	if OS.has_feature("web"):
		_music.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(_music)
	apply_audio_settings()
	apply_video_settings()


	Engine.physics_ticks_per_second = 10

	hud = Hud.new()
	add_child(hud)

	add_child(preload("res://scripts/ui/broadcast.gd").new())
	meter_details = MeterDetails.new()
	meter_details.world = self
	add_child(meter_details)
	menus = Menus.new()
	menus.world = self
	add_child(menus)
	place_camera(Vector3.ZERO)



func set_stage(id: String) -> void :
	if not GameData.STAGES.has(id):
		return
	stage_id = id
	stage = GameData.STAGES[id]



	if not Save.is_stage_cleared(id):
		hard_mode = false



	_stage_map_due = web != null and web.get("packs") != null and not web.packs.ready_now("map:" + str(stage.map))
	if not _stage_map_due:
		_load_map(stage.map)


var _stage_map_due: = false



func _load_map(map_name: String) -> void :


	if raid != null:
		raid.drop_field_map()

	if map.map_name == map_name and (map.real or not OS.has_feature("web")):
		return
	map.queue_free()
	map = RoMap.new()
	add_child(map)
	move_child(map, 1)
	map.load_map(map_name)




func enter_town(class_id: String, place: = "prontera") -> void :
	if tower != null:
		tower.queue_free()
		tower = null


	if net.is_client() and net._in_run and running:
		return
	_stop_song()
	leave_town()
	running = false
	karma.reset()
	training = false
	festival_mode = false
	if festival != null and is_instance_valid(festival):
		festival.queue_free()
	festival = null
	if world_boss != null and is_instance_valid(world_boss):
		world_boss.queue_free()
	world_boss = null
	morroc.reset()
	stagger.clear()
	get_tree().paused = false
	hud.hide()
	for c in run_root.get_children():
		c.queue_free()
	mob_renderer.clear()
	enemies.clear()
	_grid_fresh = false
	pickups.clear()
	projectiles.clear()
	_bouncing.clear()
	enemy_shots.clear()
	_bolts.clear()
	_zones.clear()
	_sched.clear()
	Vfx.clear_flats()
	for t in _traps:
		if is_instance_valid(t.node):
			t.node.queue_free()
	_traps.clear()
	_orbits.clear()
	summons.clear()
	doram.clear()

	_shadows.multimesh.visible_instance_count = 0
	for c in fx_root.get_children():
		c.queue_free()
	player = null
	heroes.clear()
	quest.skip()
	var town_map: String = GameData.TOWER_GATE.map if place == "tower_gate" else Town.MAP
	_load_map(town_map)
	if place == "prontera":
		Save.set_setting("town_visited", true)
	town = Town.new()
	run_root.add_child(town)
	town.setup(self, class_id, place)
	net.update_class(class_id)


	set_view_yaw(0.0)
	_cam_distance = minf(_cam_distance, TOWN_ZOOM_FAR)
	place_camera(town.hero.position)
	menus.close()
	menus.enter_town_mode()
	play_music_map(town_map)


func leave_town() -> void :
	if town == null:
		return
	town.queue_free()
	town = null
	mouse_walk.reset()
	_load_map(stage.map)



func is_stage_exported(id: String) -> bool:
	return RoAssets.map_exists(str(GameData.STAGES[id].map))


func is_stage_unlocked(id: String) -> bool:
	var need: String = GameData.STAGES[id].get("unlock", "")
	return need == "" or Save.is_stage_cleared(need)




func start_run(class_id: String, choose_start: = false) -> void :

	_homun_asks.clear()
	menus._victory_open = false


	Save.set_setting("endless_auto_pick", false)
	if tower != null:
		tower.queue_free()
		tower = null
	if festival != null and is_instance_valid(festival):
		festival.queue_free()
	festival = null
	if world_boss != null and is_instance_valid(world_boss):
		world_boss.queue_free()
	world_boss = null

	corrupt_auto = ""
	traits = MobTraits.new()
	leave_town()
	if _stage_map_due:
		_stage_map_due = false
		_load_map(stage.map)
	raid.reset()
	web_prefetch_run.call_deferred()
	morroc.reset()
	stagger.clear()
	encore.clear()
	flow.reset()
	for c in run_root.get_children():
		c.queue_free()
	mob_renderer.clear()
	for c in fx_root.get_children():
		c.queue_free()
	enemies.clear()
	_grid_fresh = false
	projectiles.clear()
	_bouncing.clear()
	_splash_acc.clear()
	poisoned.clear()
	judged.clear()
	dots.clear()
	meter.clear()
	meter_boss.clear()
	meter_boss_hero.clear()
	meter_taken.clear()
	meter_heal.clear()
	meter_taken_hero.clear()
	meter_heal_hero.clear()
	meter_stats = {"total": 0.0, "taken": 0.0, "healed": 0.0, "crits": 0, "best": 0.0, "best_tag": "", "hits": 0}
	enemy_shots.clear()
	_bolts.clear()
	_zones.clear()
	_sched.clear()
	Vfx.clear_flats()
	for t in _traps:
		if is_instance_valid(t.node):
			t.node.queue_free()
	_traps.clear()
	_orbits.clear()
	summons.clear()
	doram.clear()
	pickups.clear()





	_xp_batch = 0
	_xp_kills = 0
	_wisps = 0
	boss = null
	time = 0.0


	_combo_window = -1.0
	_combo_count = 0
	_combo_said.clear()
	_side_said.clear()
	_broke_at = -99.0
	kills = 0

	_crowd_debt = 0
	run_zeny = 0
	_stats_banked = false
	endless = false
	_endless_count = 0
	_endless_rush = -1.0
	_endless_upcoming = {}
	peak_hit = 0.0
	card_memory.clear()
	perf.reset()
	run_cards.clear()
	run_stored.clear()
	run_ymir = 0
	run_mvps = 0
	first_mvp_time = -1.0
	run_bosses = 0
	_lucky_chest_at = 0.0
	_storm = GameData.STORM_EVERY
	zeny_from.clear()
	run_materials.clear()
	run_coins = 0
	run_mob_coins = 0
	_stage_card_mobs.clear()
	_stage_card_pool.clear()
	_mix.clear()
	mob_renderer.set_keep(_run_mobs())
	pace = 1.0


	frenzy = speed > 1
	game_fast = speed >= 3
	var dr: = GameData.stage_danger_range(stage_id, Save.max_danger())
	danger = clampi(danger, dr.x, dr.y)
	if training:
		danger = 1
		frenzy = false



	if training:
		game_fast = false
	run_fast_s = 0.0
	hard = danger >= GameData.DANGER_HARD


	if oaths_next is Dictionary:
		oaths = (oaths_next as Dictionary).duplicate()
	elif danger == GameData.DANGER_MAX and tower_start == 0 and not training and not festival_mode:
		oaths = Save.oaths()
	elif tower_start > 0 and tower_hel:

		oaths = Save.oaths()
		for id in GameData.HEL_TOWER_NO_OATHS:
			oaths.erase(id)
	else:
		oaths = {}
	oaths_next = null
	oath_run.clear()
	featured = stage_id == GameData.featured_stage() and not training
	meter_from = 0.0
	meter_view = {}
	Save.mark_entered(stage_id)
	_event_index = 0
	_mvp_ran_early = false
	_spawn_timers.clear()
	_level_up_delay = 0.0
	_feroz_timer = 0.0
	_autosave = RunSave.EVERY


	if coop_classes.is_empty() and net.mode == "":
		RunSave.clear()

	player = Player.new()
	run_root.add_child(player)

	var profile: = Player.profile_of(class_id)
	profile.merge(resume_picks, true)
	resume_picks = {}
	player.setup(class_id, profile)

	player.luck_mult = GameData.oath_value("unlucky", oath("unlucky"))
	player.pace_xp = float(GameData.PACE_XP.get(roundi(pace), pace))

	player.hard_loot = GameData.danger_reward(danger) * (1.0 + GameData.FEATURED_BONUS if featured else 1.0)\
	* (1.0 + GameData.FRENZY_ZENY if frenzy and tower_start == 0 else 1.0) * oath_zeny()
	player.equipment.legend_bonus = GameData.danger_legend(danger)
	player.recompute()
	var spawn: = map.spawn_point()
	player.position = Vector3(spawn.x, map.height_at(spawn), spawn.z)
	player.leveled_up.connect(_on_level_up.bind(player))
	player.died.connect(_on_player_died.bind(player))
	if training and not festival_mode:
		_training_gear(player)
		_training_npc(player.position)
	heroes = [player]
	flows = [flow]
	Vfx.net_root = fx_root
	meter_hero = [{}]
	unowned.clear()
	loot_queue.clear()
	held_chests.clear()
	_loot = null
	if _loot_panel != null and is_instance_valid(_loot_panel):
		_loot_panel.queue_free()
	for c in coop_classes:
		_add_party_hero(c, spawn)

	if net.is_host():
		for id in net.ready_peers():
			_add_party_hero(str(net.peers[id]["class"]), spawn, net.peers[id].get("profile", {}))
			var rh: Player = heroes.back()
			rh.input = HeroInput.Remote.new()
			net.peers[id]["hero"] = rh


			var box: = int((net.peers[id].get("profile", {}) as Dictionary).get("sage_start", 0))
			if choose_start and box > 0:
				rh.pending_levels += mini(box, int(GameData.SAGE_UPGRADES.sage_start.max))
	hud.bind(self)
	hud.show()
	_spawn_pet()
	homun = null
	quest.reset()
	altars.reset()
	karma.reset()
	weather.reset()
	_hell_setup()
	runner = null
	_runner_timer = float(GameData.RUNNER.from)
	if not training:
		morroc.plan()

	hud.refresh_altars()
	_prewarm_skills()
	running = true
	get_tree().paused = false
	menus.close()
	play_music("map")
	if festival_mode:
		pass
	elif training:
		hud.announce(tr("Campo de entrenamiento"), Color(0.8, 0.65, 1.0), tr("Invoca muñecos a la izquierda y mide tu daño"))
	elif danger > 1 or featured:
		var sub: = (tr("Mapa del día: +%d%% de recompensas") % roundi(GameData.FEATURED_BONUS * 100.0)) if featured else tr("Recompensas x%s") % str(snappedf(GameData.danger_reward(danger), 0.1))
		var h: = GameData.hell_level(danger)
		if h > 0:
			var names: Array[String] = []
			for i in h:
				names.append(tr(str(GameData.HELL_FEATURES[i].name)))

			if names.size() > 5:
				var short: Array[String] = [tr("Todo lo del Infierno 5")]
				short.append_array(names.slice(5))
				names = short
			sub = " · ".join(names)
		var title: = GameData.danger_name(danger)


		if oath_points() > 0:
			title = "%s  ·  %s" % [title, tr("Juramento %d") % oath_points()]
			var sworn: Array[String] = []
			for pair in Oaths.sworn_list(oaths):
				sworn.append(tr(str(pair[0].name)) + ("" if (pair[0].pts as Array).size() == 1 else " " + "I".repeat(int(pair[1]))))
			sub = " · ".join(sworn)
		hud.announce(title, Color(0.9, 0.15, 0.2) if h > 0 else (Color(1.0, 0.5, 0.35) if hard else Color(1.0, 0.8, 0.4)), sub)

	if net.is_host() and not net.peers.is_empty():
		net.send_start()
	if net.is_client():
		return
	if choose_start or not bool(Save.setting("onboarded", false)):
		_opening_screens(choose_start)




func _prewarm_skills() -> void :
	if player == null:
		return
	var t0: = Time.get_ticks_usec()
	var ids: Array = player.skill_pool() + player.passive_pool()
	for id in ids.duplicate():
		if GameData.SKILLS.has(str(id) + "_x"):
			ids.append(str(id) + "_x")
	var seen: = {}
	for id in ids:
		if not GameData.SKILLS.has(id):
			continue
		UiKit.skill_icon(str(id))
		for v in GameData.SKILLS[id].values():


			if not (v is String) or seen.has(v) or str(v).length() < 3 or str(v) != str(v).to_lower():
				continue
			seen[v] = true
			if FileAccess.file_exists(RoAssets.ROOT + "effects/%s.json" % v):
				RoAssets.effect_data(v)
			for key in [v, v + "1", v + "2", v + "3"]:
				if ResourceLoader.exists(RoAssets.ROOT + "audio/%s.wav" % key):
					RoAssets.sound(key)

	for key in ["levelup", "job_levelup", "get_coin", "ui_click", "drop_blue", "drop_purple", "drop_yellow", 
			"enemy_hit_normal1", "enemy_hit_normal2", "enemy_hit_normal3", "enemy_hit_normal4"]:
		RoAssets.sound(key)
	RoAssets.effect_data("h_levelup")
	for el in ["normal", "fire", "wind"]:
		for k in range(1, 5):
			if ResourceLoader.exists(RoAssets.ROOT + "audio/enemy_hit_%s%d.wav" % [el, k]):
				RoAssets.sound("enemy_hit_%s%d" % [el, k])

	for mob in _run_mobs():
		for kind in ["attack", "damage", "die"]:
			var file: = RoAssets.mob_sound(mob, kind)
			if file != "":
				RoAssets.sound("mob/" + file)
	for spr in ["fx_emotion", "fx_coin", "woodbox", "steelbox", "item_potion"]:
		RoAssets.sprite([spr])
	if RoAssets._log_loads:
		print("PREWARM %d skills %.0f ms" % [ids.size(), (Time.get_ticks_usec() - t0) / 1000.0])







func start_tower(index: int, floor: int, hel: = false) -> void :
	if hel:
		floor = 1
	var build: = Save.take_tower_build(index)
	if build.is_empty():
		return
	var cid: = str(build.get("class", ""))
	if not GameData.CLASSES.has(cid):
		return
	if GameData.STAGES.has(str(build.get("stage", ""))):
		stage_id = str(build.stage)
	stage = GameData.TOWER_STAGE




	var map_speed: = speed
	speed = 1 if hel else tower_speed()
	danger = GameData.DANGER_HELL10
	if town == null:
		_load_map(stage.map)


	var party: Dictionary = net.tower_party if net.is_host() else {}
	for id in party:
		if net.peers.has(id):
			net.peers[id]["class"] = str(party[id].build.get("class", "swordsman"))
			net.peers[id]["profile"] = party[id].profile
	tower_start = floor
	tower_hel = hel
	start_run(cid)
	tower_start = 0
	tower_hel = false
	speed = map_speed


	featured = false
	danger = GameData.DANGER_HELL10
	hard = true
	_hell_setup()
	var lo: = Save.loadout(cid)
	var gear: = {}
	for slot in GameData.FACE_SLOTS:
		var stored: = Save.storage_item(str(lo.get(slot, "")))
		if not stored.is_empty():
			gear[slot] = stored
	_tower_hero(player, build, gear, Save.tower_power(), true)
	for id in party:
		var h = net.peers.get(id, {}).get("hero")
		if h != null and is_instance_valid(h):
			var prof: Dictionary = party[id].profile
			_tower_hero(h, party[id].build, prof.get("gear", {}), float(prof.get("tower_power", 0.0)), false)
	net.tower_party.clear()
	morroc.reset()
	stagger.clear()
	quest.skip()
	endless = true
	tower = TowerRun.new(self, floor)
	if hel:
		tower.make_hel()
	add_child(tower)
	if hel:
		hud.announce(tr("Torre de Hel"), Color(0.75, 0.5, 1.0), tr("Lucile: «Bajemos juntos... no te separes de mí.»"))
	else:
		hud.announce(tr("Endless Tower"), Color(0.6, 0.5, 1.0), tr("Lucile: «¡Vamos! Yo te cuido la espalda.»"))




var tower_start: = 0
var tower_hel: = false






func start_festival(index: int) -> void :
	var builds: = Save.tower_builds()
	if index < 0 or index >= builds.size():
		return
	var build: Dictionary = (builds[index] as Dictionary).duplicate(true)
	var cid: = str(build.get("class", ""))
	if not GameData.CLASSES.has(cid):
		return
	if GameData.STAGES.has(str(build.get("stage", ""))):
		stage_id = str(build.stage)
	stage = GameData.FESTIVAL_STAGE
	speed = 1
	danger = 1
	training = true
	festival_mode = true

	if town == null and (map == null or map.map_name != str(stage.map)):
		_load_map(stage.map)
	var party: Dictionary = net.tower_party if net.is_host() else {}
	for id in party:
		if net.peers.has(id):
			net.peers[id]["class"] = str(party[id].build.get("class", "swordsman"))
			net.peers[id]["profile"] = party[id].profile
	start_run(cid)
	training = true
	festival_mode = true
	_festival_hero(player, build)
	for id in party:
		var h = net.peers.get(id, {}).get("hero")
		if h != null and is_instance_valid(h):
			_festival_hero(h, party[id].build)
	net.tower_party.clear()
	morroc.reset()
	stagger.clear()
	quest.skip()
	festival = load("res://scripts/core/festival_run.gd").new(self, festival_line(build))
	add_child(festival)
	festival_index = index



var festival_index: = -1



var world_boss: Node = null

var wb_index: = -1
var wb_state: = {}




func start_world_boss(index: int, state: Dictionary) -> void :
	var builds: = Save.tower_builds()
	if index < 0 or index >= builds.size():
		return
	var mvp: = str(state.get("boss", ""))
	if not raid.supports(mvp) or GameData.wb_locked(state):
		return
	var build: Dictionary = (builds[index] as Dictionary).duplicate(true)
	var cid: = str(build.get("class", ""))
	if not GameData.CLASSES.has(cid):
		return
	stage_id = GameData.TRAINING_STAGE
	stage = GameData.STAGES[GameData.TRAINING_STAGE]
	speed = 1
	danger = GameData.WB_DANGER
	training = true
	festival_mode = true
	if town == null and (map == null or map.map_name != str(stage.map)):
		_load_map(stage.map)
	start_run(cid)
	training = true
	festival_mode = true
	danger = GameData.WB_DANGER
	_festival_hero(player, build)
	morroc.reset()
	stagger.clear()
	quest.skip()
	wb_index = index
	wb_state = state
	world_boss = load("res://scripts/core/world_boss.gd").new(self, state, festival_line(build))
	add_child(world_boss)



static func festival_line(b: Dictionary) -> String:
	var cid: = str(b.get("class", ""))
	var job: = str(b.get("name", GameData.CLASSES.get(cid, {}).get("name", cid)))
	return "%s  ·  Nv %d" % [TranslationServer.translate(job), int(b.get("level", 1))]



func _festival_hero(p: Player, b: Dictionary) -> void :
	RunSave.apply_hero(self, b, p, p == player)
	p.keep_build_copies()
	_no_build_ores(p)
	p.recompute()
	p.hp = p.max_hp




func _client_festival() -> void :
	training = true
	festival_mode = true
	var build: = net.festival_pick()
	if not build.is_empty():
		_festival_hero(player, build)
	festival = load("res://scripts/core/festival_run.gd").new(self, festival_line(build))
	festival.mirror = true
	add_child(festival)





func _client_tower(floor: int, hel: = false) -> void :
	danger = GameData.DANGER_HELL10
	hard = true
	_hell_setup()
	var build: = net.take_tower_pick()
	if not build.is_empty():
		var lo: = Save.loadout(player.class_id)
		var gear: = {}
		for slot in GameData.FACE_SLOTS:
			var stored: = Save.storage_item(str(lo.get(slot, "")))
			if not stored.is_empty():
				gear[slot] = stored
		_tower_hero(player, build, gear, Save.tower_power(), false)
	endless = true
	tower = TowerRun.new(self, floor)
	tower.mirror = true
	if hel:
		tower.make_hel()
	add_child(tower)
	if hel:
		hud.announce(tr("Torre de Hel"), Color(0.75, 0.5, 1.0), tr("Lucile: «Bajemos juntos... no os separéis de mí.»"))
	else:
		hud.announce(tr("Endless Tower"), Color(0.6, 0.5, 1.0), tr("Lucile: «¡Vamos! Yo os cuido la espalda.»"))





func _no_build_ores(p: Player) -> void :
	p.equipment.ores = {"oridecon": 0, "elunium": 0}
	p.equipment.ores_found = {"oridecon": 0, "elunium": 0}






func _lend_build_gear(p: Player) -> void :
	for k in p.equipment.slots:
		var it = p.equipment.slots[k]
		if it is Dictionary and not Equipment.is_perm(it):
			it["lent"] = true
	for it in p.equipment.bag:
		if not Equipment.is_perm(it):
			it["lent"] = true








func _drop_build_copies(p: Player) -> void :
	var seen: = {}
	for k in p.equipment.slots:
		var it = p.equipment.slots[k]
		if it is Dictionary and Equipment.is_perm(it) and str(it.get("uid", "")) != "":
			seen[str(it.uid)] = true
	var kept: Array = []
	for it in p.equipment.bag:
		var uid: = str(it.get("uid", "")) if it is Dictionary and Equipment.is_perm(it) else ""
		if uid != "" and seen.has(uid):
			continue
		if uid != "":
			seen[uid] = true
		kept.append(it)
	if kept.size() != p.equipment.bag.size():
		push_warning("tower: %d copies of stored pieces left the build's bag" % (p.equipment.bag.size() - kept.size()))
		p.equipment.bag.assign(kept)








func _tower_hero(p: Player, build: Dictionary, gear: Dictionary, power: float, world_parts: bool) -> void :
	p.hard_loot = GameData.danger_reward(danger) * oath_zeny()
	p.equipment.legend_bonus = GameData.danger_legend(danger)
	RunSave.apply_hero(self, build, p, world_parts)
	p.keep_build_copies()
	_no_build_ores(p)
	_lend_build_gear(p)
	p.revives = maxi(0, p.revives - p.gear_lives(false))
	for slot in GameData.FACE_SLOTS:
		var stored: Dictionary = gear.get(slot, {})
		if not stored.is_empty() and GameData.ITEMS.has(str(stored.get("id", ""))) and p.equipment.slots.get(slot) == null:
			p.equipment.slots[slot] = Equipment.from_storage(stored)
	_drop_build_copies(p)
	p.revives += p.gear_lives(true)
	p.tower_power = power
	p.recompute()
	p.hp = p.max_hp






func _training_gear(p: Player) -> void :
	p.equipment.bag_max = maxi(GameData.INVENTORY_MAX, p.equipment.bag.size() + GameData.TRAINING_BAG_SPARE)






static func training_own_items(p: Player, any: = false) -> Array:
	var have_uids: = {}
	var worn_ids: = {}
	for k in p.equipment.slots:
		var on = p.equipment.slots[k]
		if on != null:
			have_uids[str(on.get("uid", ""))] = true
			worn_ids[str(on.id)] = true
	for it in p.equipment.bag:
		if it is Dictionary and str(it.get("uid", "")) != "":
			have_uids[str(it.uid)] = true
	var out: Array = []
	for it in Save.storage():
		var d: = Equipment.item_def(it)

		if d.is_empty() or d.get("fixed", false) or not (any or p.equipment.can_wear(it)):
			continue
		var uid: = str(it.get("uid", ""))
		if have_uids.has(uid) if uid != "" else worn_ids.has(str(it.id)):
			continue
		out.append(it)
	return out





var _armorer: RoVisual
var _armorer_armed: = true
func _training_npc(at: Vector3) -> void :
	var spot: = map.find_point_around(at, 2.5, 3.5) if map != null else Vector3.INF
	if spot == Vector3.INF:
		spot = at + Vector3(-2.5, 0, 1.5)
	var v: = RoVisual.new()
	run_root.add_child(v)
	v.setup(RoAssets.sprite(["npc_armorer"]), Color(0.8, 0.8, 0.9), 40)
	v.position = Vector3(spot.x, map.height_at(spot), spot.z)
	v.face(at - v.position)
	v.play(RoVisual.MOB_IDLE)
	Town._name_label(v, "Hollgrehenn", tr("Armería temporal"))
	var glow: = Vfx.ground_glow(v, Vector3(0, 0.03, 0), 1.3, Color(0.9, 0.7, 0.3, 0.55))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.3, 0.9).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.75, 0.9).set_trans(Tween.TRANS_SINE)
	_armorer = v
	_armorer_armed = false


func _tick_armorer() -> void :
	if not training or _armorer == null or not is_instance_valid(_armorer) or player == null:
		return
	var d: = _flat_dist(player.position, _armorer.position)
	if d > 3.0:
		_armorer_armed = true
	elif d < 1.6 and _armorer_armed and not busy():
		_armorer_armed = false
		_armorer.face(player.position - _armorer.position)
		menus.show_armory()






var training_element: = "neutral"
var training_hit: = 1000.0


const TRAINING_HIT_EVERY: = 1.0
const TRAINING_HIT_REACH: = 4.0
const TRAINING_HIT_GLOW: = Color(1.0, 0.25, 0.2, 0.35)
const TRAINING_HITS: = [100.0, 1000.0, 10000.0, 100000.0]


func training_dummies(n: int, mvp: = false, hitter: = false) -> void :
	if not running or not training or net.is_client() or player == null:
		return
	var ahead: = player.facing if player.facing.length() > 0.1 else Vector3(0, 0, 1)
	var c: = player.position + ahead.normalized() * (3.5 if n == 1 else 6.0)
	for i in n:
		var at: = c
		if i > 0:
			var ring: = 1 if i <= 7 else 2
			var on_ring: = 7 if ring == 1 else n - 8
			var k: = (i - 1) if ring == 1 else (i - 8)
			var a: = TAU * k / maxf(1.0, on_ring)
			at = c + Vector3(cos(a), 0, sin(a)) * (1.3 * ring)
		if map != null and not map.is_walkable(at):
			var near: = map.find_point_around(at, 0.2, 2.5)
			if near == Vector3.INF:
				continue
			at = near
		var e: = spawn_enemy("training_dummy_mvp" if mvp else "training_dummy", at, true)
		if e != null:
			e.max_hp = GameData.TRAINING_DUMMY_HP
			e.hp = e.max_hp
			_dummy_element(e)
			if hitter:
				e.set_meta("training_hitter", true)
				e.set_meta("training_hit", training_hit)
				Vfx.ground_glow(e, Vector3(0, 0.03, 0), TRAINING_HIT_REACH, TRAINING_HIT_GLOW)

			if mvp:
				e.is_boss = true
	spawn_fx("h_levelup", c, 0.9, 0.8)
	play_sound("portal", 0.0, -8.0)
	_rebuild_grid()


func _dummy_element(e: Enemy) -> void :
	e.element_override = "" if training_element == "neutral" else training_element



func training_next_element() -> void :
	if net.is_client():
		return
	var order: Array = GameData.ELEMENT_ORDER
	training_element = str(order[(order.find(training_element) + 1) % order.size()])
	for e in enemies:
		if is_instance_valid(e) and e.def.get("dummy", false):
			_dummy_element(e)
	play_sound("ui_click", 0.0, -6.0)



func training_next_hit() -> void :
	if net.is_client():
		return
	training_hit = float(TRAINING_HITS[(TRAINING_HITS.find(training_hit) + 1) % TRAINING_HITS.size()])
	for e in enemies:
		if is_instance_valid(e) and e.has_meta("training_hitter"):
			e.set_meta("training_hit", training_hit)
	play_sound("ui_click", 0.0, -6.0)


func training_clear() -> void :
	if net.is_client():
		return
	for e in enemies.duplicate():
		if is_instance_valid(e) and e.def.get("dummy", false):
			banish_enemy(e)






var _training_auto: = 0
func training_levels(n: int, auto: = false) -> void :
	if not running or not training or net.is_client():
		return


	if auto:
		_training_auto = player.pending_levels + n
	else:
		_training_auto = 0
	for h in heroes:
		for k in n:
			h.level += 1
			h.pending_levels += 1
			h.xp = 0.0
			h.xp_need = GameData.xp_to_next(h.level)
			h.leveled_up.emit()






func restart_training(as_class: = "") -> void :
	if not running or not training or festival_mode or net.is_client() or player == null:
		return
	var cid: = as_class if GameData.CLASSES.has(as_class) else player.class_id
	_training_auto = 0
	if net.is_host():
		net.send_end(false)
	_bank_run(false)
	running = false
	menus.close()
	menus._start_training(cid)







var _training_build: = {}
func training_load_build(b: Dictionary) -> void :
	if not running or not training or festival_mode or world_boss != null or net.is_client() or player == null:
		return
	var cid: = str(b.get("class", ""))
	if not GameData.CLASSES.has(cid):
		return
	_training_build = b.duplicate(true)
	restart_training(cid)



func reset_meter() -> void :
	meter.clear()
	meter_boss.clear()
	meter_boss_hero.clear()
	meter_taken.clear()
	meter_heal.clear()
	meter_taken_hero.clear()
	meter_heal_hero.clear()
	meter_stats = {"total": 0.0, "taken": 0.0, "healed": 0.0, "crits": 0, "best": 0.0, "best_tag": "", "hits": 0}
	for i in meter_hero.size():
		meter_hero[i] = {}
	meter_from = time
	meter_view = {}
	play_sound("ui_click", 0.0, -6.0)



func meter_time() -> float:
	return maxf(1.0, time - (float(meter_view.t) if meter_view.has("t") and running else meter_from))




func meter_view_reset() -> void :
	var hero: = []
	for m in meter_hero:
		hero.append(_meter_amounts(m))
	var boss: = {}
	for id in meter_boss:
		boss[id] = (meter_boss[id].get("tags", {}) as Dictionary).duplicate()
	meter_view = {"t": time, "src": _meter_amounts(meter), "boss": boss, "taken": _meter_amounts(meter_taken), 
		"heal": _meter_amounts(meter_heal), "hero": hero}
	play_sound("ui_click", 0.0, -6.0)


static func _meter_amounts(d: Dictionary) -> Dictionary:
	var out: = {}
	for k in d:
		if d[k] is Dictionary:
			out[k] = [float(d[k].get("dmg", 0.0)), int(d[k].get("hits", 0))]
	return out



func meter_view_total(mode: String) -> float:
	var sum: = 0.0
	for r in meter_rows(mode):
		sum += float(r.dmg)
	return sum





func _view_rows(rows: Array, base: Dictionary) -> Array:
	var out: = []
	for r in rows:
		var b = base.get(str(r.tag))
		var row: Dictionary = r
		if b is Array and float(r.dmg) >= float(b[0]):
			row = r.duplicate()
			row.dmg = float(r.dmg) - float(b[0])
			row.hits = maxi(0, int(r.get("hits", 0)) - int(b[1]))
			row.first = maxf(float(r.get("first", 0.0)), float(meter_view.t))
		if float(row.dmg) > 0.5:
			out.append(row)
	out.sort_custom( func(a, c): return a.dmg > c.dmg)
	return out



func leave_training() -> void :
	var cid: = player.class_id if player != null else ""
	if net.is_client():
		abandon_run()
		return
	abandon_run()
	menus.close()
	if cid != "":
		enter_town(cid)




func _opening_screens(choose_start: bool) -> void :
	await get_tree().process_frame
	await get_tree().process_frame
	if not running or busy():
		return
	var onboard: = func():
		if not bool(Save.setting("onboarded", false)):
			menus.show_onboarding()
		elif choose_start and not menus.auto_pick and Save.upgrade_active("sage_start") > 0:

			player.pending_levels += mini(Save.upgrade_active("sage_start"), int(GameData.SAGE_UPGRADES.sage_start.max))
			menus.show_level_up(level_choices())
	var options: = player.start_options()
	var passives: = player.start_passive_options()

	if choose_start and options.size() + passives.size() >= 1 and not menus.auto_pick:


		var sub: = ""
		var n_bans: = player.banished.size()
		if n_bans > 0:
			sub = (tr("Una habilidad o una pasiva: el resto puede salir al subir de nivel") if not passives.is_empty()
				else tr("Las demás pueden salir al subir de nivel")) + "  ·  "\
				+ tr_n("%d destierro aplicado (Holy Water)", "%d destierros aplicados (Holy Water)", n_bans) % n_bans
		menus.show_start_skill(options, func(id: String):
			player.set_start_skill(id)
			Save.set_setting("start_skill_" + player.class_id, id)
			_after_opening_pick(onboard), "", "", "", passives, sub)
	else:
		onboard.call()





func acting_hero() -> Player:
	return damage_by if damage_by != null and is_instance_valid(damage_by) else player



func by_of(rec: Dictionary) -> Player:
	var h = rec.get("by")
	return h if h != null and is_instance_valid(h) else player



func _add_party_hero(class_id: String, at: Vector3, profile: = {}) -> void :
	var h: = Player.new()
	run_root.add_child(h)
	h.setup(class_id, profile)
	h.luck_mult = GameData.oath_value("unlucky", oath("unlucky"))
	h.slot = heroes.size()
	h.input = HeroInput.BotHero.new()
	h.pace_xp = player.pace_xp
	h.hard_loot = player.hard_loot
	h.equipment.legend_bonus = player.equipment.legend_bonus
	h.recompute()
	var pos: = map.find_point_around(at, 1.5, 3.0)
	if pos == Vector3.INF:
		pos = at
	h.position = Vector3(pos.x, map.height_at(pos), pos.z)
	h.leveled_up.connect(_on_level_up.bind(h))
	h.died.connect(_on_player_died.bind(h))
	heroes.append(h)
	meter_hero.append({})
	var f: = FlowField.new()
	f.map = map
	flows.append(f)




func _party_tag(h: Player) -> void :
	var tag: = Label3D.new()
	tag.text = tr(h.job_name())
	tag.font = RO_UI_FONT
	tag.font_size = 28
	tag.pixel_size = 0.013
	tag.outline_size = 7
	tag.outline_modulate = Color(0, 0, 0, 0.85)
	tag.modulate = Color(0.55, 0.85, 1.0)
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.no_depth_test = true
	tag.render_priority = 20
	tag.outline_render_priority = 19
	tag.position = RoVisual.lift + Vector3(0, 3.3, 0)
	h.add_child(tag)






const TITLE_NEAREST: = 4
const TITLE_EVERY: = 0.25
var _title_t: = 0.0


func _cull_titles() -> void :
	var at: Vector3 = player.position if player != null and is_instance_valid(player) else Vector3.ZERO
	var list: Array = []
	for e in enemies:
		if is_instance_valid(e) and e.title_label != null and is_instance_valid(e.title_label):
			list.append([e.position.distance_squared_to(at), e])
	if list.size() <= TITLE_NEAREST:
		for it in list:
			it[1].title_label.visible = true
		return
	list.sort_custom( func(a, b): return a[0] < b[0])
	var kinds: = {}
	for i in list.size():
		var e: Enemy = list[i][1]
		var kind: = e.special if e.special != "" else str(e.title_label.text)
		var show: = i < TITLE_NEAREST or not kinds.has(kind)
		kinds[kind] = true
		e.title_label.visible = show




func _start_memlog() -> void :
	if OS.get_cmdline_user_args().size() > 0:
		return

	if FileAccess.file_exists("user://memlog.csv"):
		DirAccess.rename_absolute("user://memlog.csv", "user://memlog_prev.csv")
	_memlog = ["clock_s,run_s,ram_mb,video_mb,objects,nodes,orphans,resources,mob_kinds,enemies,projectiles,pickups,fps"]
	var t: = Timer.new()
	t.wait_time = 60.0
	t.process_mode = Node.PROCESS_MODE_ALWAYS
	t.timeout.connect(_memlog_line)
	add_child(t)
	t.start()


var _memlog: Array[String] = []
func _memlog_line() -> void :
	_memlog.append("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d" % [Time.get_ticks_msec() / 1000, roundi(time), 
		OS.get_static_memory_usage() / 1048576, 
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / 1048576, 
		int(Performance.get_monitor(Performance.OBJECT_COUNT)), int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)), 
		int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)), int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)), 
		mob_renderer._kinds.size(), enemies.size(), projectiles.size(), pickups.size(), roundi(Engine.get_frames_per_second())])
	var f: = FileAccess.open("user://memlog.csv", FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(_memlog) + "\n")
		f.close()


func is_coop() -> bool:
	return heroes.size() > 1



func leader() -> Player:
	return heroes[0] if not heroes.is_empty() else player



const CHOOSING_MODES: = ["level_up", "level_up_pick", "job_change", "start_skill", "start_skill_pick", "tower_bless", "tower_wheel"]



func targetable(h) -> bool:
	return hero_valid(h) and not h.choosing




func hold_world() -> void :
	get_tree().paused = not is_coop()




func busy() -> bool:
	return get_tree().paused or (is_coop() and menus.is_open())



func hero_valid(h) -> bool:
	return h != null and is_instance_valid(h) and heroes.has(h) and not h.downed


func alive_heroes() -> Array[Player]:
	var out: Array[Player] = []
	for h in heroes:
		if not h.downed:
			out.append(h)
	return out



func nearest_hero(pos: Vector3) -> Player:
	var best: Player = null
	var best_d: = INF
	for h in heroes:
		if h.downed or h.choosing:
			continue
		var d: = (h.position.x - pos.x) * (h.position.x - pos.x) + (h.position.z - pos.z) * (h.position.z - pos.z)
		if d < best_d:
			best_d = d
			best = h
	return best



func flow_of(h: Player) -> FlowField:
	return flows[h.slot] if h != null and h.slot < flows.size() else flow


func _far_from_party(pos: Vector3, far2: float) -> bool:
	for h in heroes:
		if (pos.x - h.position.x) * (pos.x - h.position.x) + (pos.z - h.position.z) * (pos.z - h.position.z) <= far2:
			return false
	return true







func net_client_start(info: Dictionary) -> void :
	training = bool(info.get("training", false))
	festival_mode = bool(info.get("festival", false))
	var climb: Dictionary = info.get("tower", {})
	if festival_mode:

		stage_id = str(info.stage)
		stage = GameData.FESTIVAL_STAGE
		_load_map(str(stage.map))
	elif climb.is_empty():
		set_stage(str(info.stage))
	else:

		stage_id = str(info.stage)
		stage = GameData.TOWER_STAGE
		_load_map(str(climb.map))
	var party: Array = info.party
	var you: = int(info.you)


	danger = int(info.danger)
	oaths_next = (info.get("oaths", {}) as Dictionary).duplicate() if info.get("oaths", {}) is Dictionary else {}
	start_run(str(party[you]["class"]))
	danger = int(info.danger)


	frenzy = bool(info.get("frenzy", false))

	game_fast = false
	heroes.clear()
	flows.clear()
	meter_hero.clear()
	_net_arena = false
	for d in party:
		var h: Player
		if int(d.slot) == you:
			h = player
		else:
			h = Player.new()
			run_root.add_child(h)
			var prof: = Player.profile_of(str(d["class"]))
			if d.has("look"):
				prof.look = d.look



			prof.aura = d.get("aura") is bool and bool(d.get("aura"))
			prof.looks = (d.get("rlooks") as Array).filter( func(l): return l is String) if d.get("rlooks") is Array else []
			h.setup(str(d["class"]), prof)
			h.input = HeroInput.new()

			h.set_meta("net_pid", str(d.get("pid", "")))
		h.pet_skin = str(d.get("pet", "")) if h != player else Save.pet_skin()
		h.slot = int(d.slot)
		heroes.append(h)
		flows.append(flow)
		meter_hero.append({})
	var at: Vector3 = info.pos
	player.position = Vector3(at.x, map.height_at(at), at.z)
	if not climb.is_empty():
		_client_tower(int(climb.floor), bool(climb.get("hel", false)))
	elif festival_mode:
		_client_festival()
	spawn_party_pets()


	hud.bind(self)
	snap_camera()






func net_promote() -> void :
	_net_arena = false
	flows.clear()
	for h in heroes:
		var f: = FlowField.new()
		f.map = map
		flows.append(f)
	while meter_hero.size() < heroes.size():
		meter_hero.append({})


	for h in heroes:
		if not is_instance_valid(h):
			continue

		for n in (h.uniq.get("net_embers", []) as Array) + (h.uniq.get("net_orbs", []) as Array) + [h.uniq.get("net_night")]\
		+ (h.uniq.get("net_queen", []) as Array) + (h.uniq.get("net_flies", []) as Array):
			if n is Node and is_instance_valid(n):
				n.queue_free()
		for k in ["net_u", "net_embers", "net_night", "net_orbs", "net_queen", "net_flies"]:
			h.uniq.erase(k)
	for h in heroes:
		if h == player or not is_instance_valid(h):
			continue
		h.input = HeroInput.BotHero.new()
		h.set_meta("player_gone", true)
		h.set_choosing(false)
		if not h.has_meta("mig_hooked"):
			h.set_meta("mig_hooked", true)
			h.leveled_up.connect(_on_level_up.bind(h))
			h.died.connect(_on_player_died.bind(h))
		h.recompute()
	while _event_index < stage.events.size() and float(stage.events[_event_index].at) <= time:
		_event_index += 1
	quest.skip()


	raid.net_promote()
	if tower != null and is_instance_valid(tower):
		tower.net_promote()
	if festival != null and is_instance_valid(festival):
		festival.net_promote()
	morroc.net_promote()

	hell_late.net_promote()
	for e in enemies:
		if is_instance_valid(e) and not e.dead:
			e.hp = clampf(e.hp, 1.0, e.max_hp)


	for p in pickups.duplicate():
		if str(p.get("kind", "")) in ["tame", "branch", "power", "card", "potion"] and not p.has("id"):
			pickups.erase(p)
			if p.has("node") and is_instance_valid(p.node):
				(p.node as Node).queue_free()
	player.set_choosing(false)



	if not training and run_zeny > 0:
		Save.add_zeny(run_zeny)
	print("NET promoted: leading the run (t=%.0f, %d monsters, %d heroes)" % [time, enemies.size(), heroes.size()])



func _client_frame(delta: float) -> void :
	delta = minf(delta, 0.05 * (GameData.GAME_FAST_SPEED if fast_now else 1.0))
	_rebuild_grid()

	altars.client_tick(delta)
	if not player.downed:
		player.set_choosing(menus._mode in CHOOSING_MODES)
		Vfx.dim = own_fx_alpha
		player.tick_puppet(delta, self)
		if _net_arena:
			raid._clamp(player, raid.radius)
			raid.client_tick(delta)
		Vfx.dim = 1.0
	net.client_tick(delta)
	summons.client_tick(delta)
	_update_ghost_shots(delta)
	_update_bolts(delta)
	_update_orbits(delta)
	morroc.client_tick(delta)
	encore.client_tick(self, delta)
	for h in heroes:
		if h != player and h.choosing:
			h._tick_choosing(delta, self)

		if h != player and is_instance_valid(h):
			h.draw_spheres()
			h._tick_coins()
	_update_pet(delta)
	_grid_fresh = false
	_update_shadows()
	mob_renderer.update(delta, _shadows.custom_aabb)
	gem_renderer.update(pickups, _gem_looks, _shadows.custom_aabb)
	_update_camera(delta)
	mouse_walk.update_markers()
	_numbers = maxi(0, _numbers - 1)
	_number_clock += delta
	for key in _number_buckets.keys():
		if _number_buckets[key].until < _number_clock:
			_number_buckets.erase(key)



func net_mob(id: String, special: String, at: Vector3, size: float, big: = 1.0) -> Enemy:
	if not GameData.MONSTERS.has(id):
		return null
	var e: = Enemy.new()
	run_root.add_child(e)

	e.setup(id, 1.0, mob_renderer, -1.0, big != 1.0)

	var extra: = special.get_slice("|", 1).split(",", false) if special.contains("|") else PackedStringArray()
	special = special.get_slice("|", 0)
	if special != "" and special != "runner":
		e.make_special(special)
	for x in extra:
		if x == "kyrie":
			e.set_kyrie(true)
		elif x == "hitter":
			Vfx.ground_glow(e, Vector3(0, 0.03, 0), TRAINING_HIT_REACH, TRAINING_HIT_GLOW)
		elif x == "shadow" or x == "profane":

			e.set_meta("mvp_shadow" if x == "shadow" else "profane", true)
			hell_late.dress(e)
		elif GameData.OATH_AFFIXES.has(x):
			e.affixes.append(x)
	if not e.affixes.is_empty():
		e.add_title_line(Oaths.affix_line(e.affixes))
	e.scale = Vector3.ONE * size
	if big != 1.0 and e.visual is Node3D:

		(e.visual as Node3D).scale *= big
		if e.visual is RoVisual:
			(e.visual as RoVisual).sprite.no_depth_test = true
			(e.visual as RoVisual).sprite.render_priority = 6
	e.position = Vector3(at.x, map.height_at(at), at.z)
	enemies.append(e)

	if e.is_boss and not (e.has_meta("mvp_shadow") and boss != null and is_instance_valid(boss) and not boss.dead):
		boss = e
	return e



func net_pickup(kind: String, value: int, spr: String, tier: int, bonus: int, unique: String, at: Vector3) -> Dictionary:
	var p: = {}
	if kind == "chest":
		_drop_chest(at - Vector3(0, 0.5, 0), value, bonus if tier < 4 else 3, unique)
		p = pickups.back()
	elif kind == "xp":
		var n: = Node3D.new()
		run_root.add_child(n)
		p = {"node": n, "kind": "xp", "value": value, "pull": false}
		_gem_look(p, value)
		pickups.append(p)
	elif kind == "loot":
		var z: = _zeny_sprite(value)
		p = {"node": z, "kind": kind, "value": value, "pull": false, "spr": "zeny"}
		pickups.append(p)
	else:
		var sp: = RoAssets.sprite([spr]) if spr != "" else null
		var s: = Sprite3D.new()
		s.texture = sp.get_frame(0, 0) if sp != null else RoAssets.placeholder(Color(1, 0.85, 0.3), 16, false)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		s.pixel_size = GameData.PIXEL_SIZE * {"ore": 1.6, "loot": 1.1}.get(kind, 1.4)
		run_root.add_child(s)
		p = {"node": s, "kind": kind, "value": value, "pull": false}
		pickups.append(p)


		var mark: Array = {"card": [Color(1, 0.85, 0.3), 4.0], "tame": [Color(0.5, 1, 0.6), 3.0], 
			"branch": [Color(1, 0.35, 0.3) if spr.contains("bloody") else Color(0.75, 0.6, 1), 3.0], 
			"power": [Color(1, 0.95, 0.75), 3.5]}.get(kind, [])
		if not mark.is_empty():
			_drop_marker(s, mark[0], mark[1], -0.5)
	p.erase("hop_t")
	(p.node as Node3D).position = at
	return p



func net_fx(ev: Array) -> void :
	match str(ev[0]):
		"mvp":
			_mvp_moment(ev[1])
		"es":
			for e in enemies_in_radius(ev[1], float(ev[2])):
				e.shrink(float(ev[3]))
		"sg":
			var who = _net_node(ev[1])
			if who is Player:
				soul_ghost(who, str(ev[2]))
		"slw":
			SoulLinker.net_spirit(self, ev)
		"n":
			number(ev[1], str(ev[2]), ev[3], bool(ev[4]), bool(ev[5]), ev.size() > 6 and bool(ev[6]), 
				float(ev[7]) if ev.size() > 7 else 1.0, false, ev.size() <= 8 or bool(ev[8]), ev.size() > 9 and bool(ev[9]), 
				str(ev[10]) if ev.size() > 10 else "", float(ev[11]) if ev.size() > 11 else 1.0)
		"f":
			spawn_fx(str(ev[1]), ev[2], float(ev[3]), float(ev[4]), _net_node(ev[5]))
		"s":
			play_sound(str(ev[1]), 0.0, float(ev[2]), float(ev[3]))
		"l":
			var t: = _net_node(ev[1])
			if t != null:
				label_over(t, str(ev[2]), ev[3])
		"x":
			sprite_fx(str(ev[1]), ev[2], int(ev[3]), float(ev[4]), _net_node(ev[5]))
		"e":
			var t: = _net_node(ev[1])
			if t != null:
				emote(t, str(ev[2]), float(ev[3]))
		"v":
			_net_vfx(ev)
		"Z":
			summon_shot(str(ev[1]), ev[2], ev[3])
		"Y":
			huuma_fall(ev[1], float(ev[2]))
		"ab":
			var to: = _net_node(ev[2])
			if to != null:
				Skills.acid_bottle(self, ev[1], to, float(ev[3]))
		"bs":
			var bound: = _net_node(ev[1])
			if bound is Enemy:
				bound_seal(bound, float(ev[2]))
		"sm":
			var to: = _net_node(ev[2])
			if to != null:
				if ev.size() > 6:
					Skills.soul_missile(self, ev[1], to, float(ev[3]), float(ev[4]), ev[5], ev[6])
				else:
					Skills.soul_missile(self, ev[1], to, float(ev[3]), float(ev[4]), ev[5])
		"B":
			burn_ember(ev[1], ev[2])
		"sgb":
			stagger.net_set(self, _net_node(ev[1]) as Enemy, float(ev[2]), float(ev[3]))
		"ftp", "mpt", "aw", "mm":

			Forge.net_event(self, ev)
		"sgt":

			stagger.thor_fx(self, _net_node(ev[1]) as Enemy, true)
		"H":


			Vfx.foreign = ev.size() > 2 and int(ev[2]) >= 0 and int(ev[2]) != net.my_slot
			Vfx.dim = own_fx_alpha * (fx_alpha_party if Vfx.foreign else 1.0)
			net_fx(ev[1])
			Vfx.foreign = false
			Vfx.dim = 1.0
		"p":
			Vfx.dim = own_fx_alpha
			_net_projectile(ev[1])
			Vfx.dim = 1.0
		"bo":
			if GameData.SKILLS.has(str(ev[1])):
				Vfx.dim = own_fx_alpha
				var gb: = {"skill": GameData.SKILLS[str(ev[1])], "point": ev[2], "delay": float(ev[3]), "radius": 0.0, "ghost": true}

				if ev.size() > 5:
					gb["element"] = str(ev[4])
					gb["sky"] = ev[5]
				drop_bolt(gb)
				Vfx.dim = 1.0
		"ob":
			var oh: Player = heroes[int(ev[1])] if int(ev[1]) < heroes.size() else null
			if oh != null and GameData.SKILLS.has(str(ev[2])):
				orbit_skill(oh, GameData.SKILLS[str(ev[2])], float(ev[3]), 0.0, int(ev[4]), float(ev[5]), float(ev[6]), true)
		"tp":
			if GameData.SKILLS.has(str(ev[2])):
				place_trap(ev[1], 0.0, 0.0, GameData.SKILLS[str(ev[2])], true)
		"tg":

			var best: Sprite3D = null
			for g in _ghost_traps:
				if is_instance_valid(g) and (best == null or _flat_dist(g.global_position, ev[1]) < _flat_dist(best.global_position, ev[1])):
					best = g
			if best != null and _flat_dist(best.global_position, ev[1]) < 1.0:
				_ghost_traps.erase(best)
				best.queue_free()
		"ea":

			var s: = _enemy_arrow(ev[1], ev[2])
			var tw: = s.create_tween()
			tw.tween_property(s, "position", (ev[1] as Vector3) + (ev[2] as Vector3) * float(ev[3]) * float(ev[4]), float(ev[4]))
			tw.tween_callback(s.queue_free)
		"gz":
			if GameData.SKILLS.has(str(ev[2])):
				Vfx.foreign = ev.size() > 6 and int(ev[6]) >= 0 and int(ev[6]) != net.my_slot
				Vfx.dim = own_fx_alpha * (fx_alpha_party if Vfx.foreign else 1.0)
				ground_zone(ev[1], GameData.SKILLS[str(ev[2])], float(ev[3]), 0.0, 0.0, float(ev[4]), ev[5], null, true)
				Vfx.foreign = false
				Vfx.dim = 1.0
		"rt":
			var rt: = _net_node(ev[1])
			if rt != null:
				rising_tex(rt, str(ev[2]), int(ev[3]))
		"L":
			fx_layer(int(ev[1]))
		"pl", "plx", "pla", "plp":
			summons.net_event(self, ev)
		"ov":
			Uniques.overload_net_fx(self, ev)
		"R":
			raid.net_event(ev.slice(1))
		"hz":
			hell_late.net_event(ev)
		"bd":
			encore.net_event(self, ev)



func _net_vfx(ev: Array) -> void :
	var r: = fx_root
	match str(ev[1]):
		"ring":
			Vfx.ring(r, ev[2], float(ev[3]), ev[4], float(ev[5]))
		"burst":
			Vfx.burst(r, ev[2], float(ev[3]), ev[4])
		"arc":
			Vfx.arc(r, ev[2], ev[3], float(ev[4]), float(ev[5]), ev[6])
		"column":
			Vfx.column(r, ev[2], ev[3])
		"tcircle":
			Vfx.telegraph_circle(r, ev[2], float(ev[3]), float(ev[4]))
		"tline":
			Vfx.telegraph_line(r, ev[2], ev[3], float(ev[4]), float(ev[5]), float(ev[6]))
		"rays":
			Vfx.ray_flash(r, ev[2], camera.global_basis, ev[3], float(ev[4]) if ev.size() > 4 else 1.0)
		"air":
			Vfx.air_impact(r, ev[2], ev[3], float(ev[4]))
		"wind":
			Vfx.wind_shot(r, ev[2], ev[3], float(ev[4]), float(ev[5]), camera.global_position)
		"tcone":
			Vfx.telegraph_cone(r, ev[2], ev[3], float(ev[4]), float(ev[5]), float(ev[6]))
		"blood":
			Vfx.blood_spray(r, ev[2], float(ev[3]), float(ev[4]))
		"venom":
			Vfx.venom_spray(r, ev[2], float(ev[3]), float(ev[4]))
		"safe":
			Vfx.safe_circle(r, ev[2], float(ev[3]), ev[4], float(ev[5]))
		"sline":
			Vfx.strike_line(r, ev[2], ev[3], float(ev[4]), float(ev[5]), ev[6], float(ev[7]))
		"scone":
			Vfx.strike_cone(r, ev[2], ev[3], float(ev[4]), float(ev[5]), ev[6])
		"scircle":
			Vfx.strike_circle(r, ev[2], float(ev[3]), ev[4])
		"fall":
			Vfx.fall(r, ev[2], float(ev[3]), ev[4], float(ev[5]))
		"quake":
			Vfx.quake(r, ev[2], float(ev[3]), ev[4])
		"heal":
			Vfx.heal_light(r, ev[2], ev[3])
		"mcircle":
			Vfx.magic_circle(r, ev[2], float(ev[3]), ev[4], float(ev[5]), str(ev[6]), float(ev[7]), int(ev[8]), bool(ev[9]))
		"rainmark":
			Vfx.rain_mark(r, ev[2], float(ev[3]), ev[4], float(ev[5]))
		"volley":
			Vfx.volley_up(r, ev[2], ev[3], int(ev[4]))



const NET_SHOT_KEYS: = ["arrow", "color", "tex", "image", "trail_tint", "frames", "sprite", "size", "tex_scale", "sprite_scale", "blend", 
	"streak", "spin", "glow", "speed", "max_life", "pos", "dir", "delay"]




func skill_id_of(sk: Dictionary) -> String:
	if GameData.SKILLS.has(damage_tag) and GameData.SKILLS[damage_tag] == sk:
		return damage_tag
	for k in GameData.SKILLS:
		if GameData.SKILLS[k] == sk:
			return k
	return ""



func _enemy_arrow(at: Vector3, dir: Vector3) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = arrow_texture()
	s.modulate = Color(1.0, 0.85, 0.8)
	s.shaded = false
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.pixel_size = GameData.PIXEL_SIZE * 1.3

	s.no_depth_test = true
	s.render_priority = Vfx.DANGER_PRIORITY
	s.position = at
	fx_root.add_child(s)
	_orient_arrow(s, s.position, dir)
	return s


func _net_projectile(d: Dictionary) -> void :

	var slot: = int(d.get("slot", 0))
	if slot != net.my_slot:
		var by_h: Player = heroes[slot] if slot < heroes.size() else null
		if projectiles.filter( func(q): return q.get("by") == by_h).size() >= NetSync.ALLY_SHOTS_MAX * (2 if tower != null else 1):
			return
	var p: = d.duplicate()
	p["ghost"] = true
	p["tag"] = ""
	p["by"] = heroes[int(d.get("slot", 0))] if int(d.get("slot", 0)) < heroes.size() else player
	spawn_projectile(p)



func _update_ghost_shots(delta: float) -> void :
	for i in range(projectiles.size() - 1, -1, -1):
		var p: = projectiles[i]
		var node: Sprite3D = p.node
		if float(p.get("delay", 0.0)) > 0.0:
			p.delay -= delta
			if p.delay <= 0.0:
				p.pos = by_of(p).position + Player.BOW_MUZZLE_UP + p.dir * Player.BOW_MUZZLE_AHEAD
				node.visible = true
			continue
		p.pos += p.dir * p.speed * delta
		p.life -= delta
		node.position = p.pos
		if p.has("frames_tex"):
			var ft: Array = p.frames_tex
			(node.material_override as StandardMaterial3D).albedo_texture = ft[int((1.6 - p.life) * 20.0) % ft.size()]
		if p.arrow:
			_orient_arrow(node, p.pos, p.dir)
		if p.has("angle"):
			_spin_projectile(p, node, delta)
		if p.life <= 0.0:
			node.queue_free()
			projectiles.remove_at(i)


func _net_node(ref: Array) -> Node3D:
	if ref.size() < 2:
		return null
	if str(ref[0]) == "h":
		return heroes[int(ref[1])] if int(ref[1]) < heroes.size() else null
	var e = net.mobs.get(int(ref[1]))
	return e if e != null and is_instance_valid(e) else null



func net_hero_state(st: Dictionary) -> void :
	var p: = player
	if p == null:
		return

	if st.get("death") is Dictionary and not (st.death as Dictionary).is_empty():
		p.death_by = st.death

	if st.has("tk"):
		p.run_taken = float(st.tk)
		meter_stats["taken"] = float(st.tk)
	if st.has("hl"):
		p.run_healed = float(st.hl)
		meter_stats["healed"] = float(st.hl)

	if st.get("am") is Dictionary:
		p.altar_mods = (st.am as Dictionary).duplicate()
	if st.get("ka") is Array and karma != null and (st.ka as Array).size() != karma.my_altars.size():
		karma.my_altars.assign(st.ka)
		hud.refresh_altars()
	p.level = int(st.level)
	p.xp = float(st.xp)
	p.xp_need = int(st.xp_need)
	p.pending_levels = int(st.pending)
	var changed: = false
	if int(st.job) >= 0 and p.job2.is_empty():

		if int(st.get("book", -1)) >= 0:
			p.song_book = int(st.book)
		p.job_change(int(st.job))
		changed = true
	var skills: Dictionary = st.skills
	for k in skills:
		if not p.skills.has(k):
			p.add_skill(k)
			changed = true
		p.skills[k].level = int(skills[k])
	for k in p.skills.keys():
		if not skills.has(k):
			p.skills.erase(k)
			changed = true
	p.stats = st.stats
	p.shield = float(st.shield)


	var had_homun: = p.homun_type
	p.homun_type = str(st.homun)
	if had_homun == "" and p.homun_type != "" and not menus.auto_pick:
		_homun_asks.append(0)
	if st.get("homx") is Array:
		var hx: Array = st.homx
		if not menus.auto_pick:
			for i in range(p.homun_extra.size(), hx.size()):
				_homun_asks.append(1 + i)
		p.homun_extra = hx.duplicate()
	_client_homun_next()


	var growth: Array = st.get("growth", []) if st.get("growth") is Array else []
	if growth.size() >= 3:
		p.stew_kills = int(growth[0])
		p.stew_hp = Player.stew_hp_of(p.stew_kills) if p.stew_kills > 0 else 0.0
		p.root_kills = int(growth[1])
		p.root_hp = p.root_hp_of(p.root_kills)
		p.lg_bash_kills = int(growth[2])
	if growth.size() >= 5:
		p.hel_marks = int(growth[3])
		p.feathers = int(growth[4])

	var ks: Array = st.get("karma", []) if st.get("karma") is Array else []
	if ks.size() >= 4 and karma != null:
		karma.boon = str(ks[0])
		karma.boons = int(ks[1])
		karma.hel_marks = int(ks[2])
		karma.feathers = int(ks[3])
		if ks.size() >= 5:
			karma.path = str(ks[4])
	p.rerolls = int(st.get("rerolls", p.rerolls))

	p.party_buffs = (st.get("pbuffs", {}) as Dictionary).duplicate(true)


	var cds: Dictionary = st.get("cds", {})
	for k in p.skills:
		p.skills[k].cd = float(cds.get(k, 0.0))
	p.powers = (st.get("powers", {}) as Dictionary).duplicate()
	p.oath_curse = float(st.get("ocurse", 0.0))

	if st.get("toys") is Dictionary:
		p.toys = (st.toys as Dictionary).duplicate()
	endless = bool(st.get("endless", endless))
	p.banishes = int(st.get("banishes", p.banishes))



	if st.get("banished") is Array:
		p.banished.assign(st.banished)

	p.revives = int(st.get("lives", p.revives))

	p.forge = int(st.get("forge", 0))
	p.forge_heat = float(st.get("heat", 0.0))

	p.heat_level = float(st.get("hb", 0.0))
	run_zeny = int(st.zeny)

	p.xp_gained = float(st.get("xg", p.xp_gained))
	run_mob_coins = int(st.get("mc", run_mob_coins))
	p.recompute()
	p.net_speed = float(st.get("speed", 0.0))
	if changed:
		hud.bind(self)



func net_arena_in(arena: String, c: Vector3, r: float, at: Vector3) -> void :
	raid._clear_portal()
	raid._field_map = map
	remove_child(map)
	var m: = RoMap.new()
	add_child(m)
	move_child(m, 1)
	m.load_map(arena)
	map = m
	raid.center = c
	raid.radius = r
	if not (arena in GameData.ARENA_KEEP_PROPS):
		m.clear_props(c, r + GameData.ARENA_CLEAR_MARGIN, GameData.ARENA_CLEAR_FRONT)
	m.flatten(c, r + GameData.ARENA_FLAT_MARGIN, GameData.ARENA_FLAT_BLEND)
	_net_arena = true

	altars.set_shown(false)
	player.position = Vector3(at.x, map.height_at(at), at.z)
	snap_camera()
	play_music_map(arena)



func net_arena_out(at: Vector3) -> void :
	raid.net_leave()
	if raid._field_map != null:
		remove_child(map)
		map.queue_free()
		add_child(raid._field_map)
		move_child(raid._field_map, 1)
		map = raid._field_map
		raid._field_map = null
	_net_arena = false
	altars.set_shown(true)
	player.position = Vector3(at.x, map.height_at(at), at.z)
	snap_camera()
	play_music("map", true)


var _net_arena: = false

var _mvp_forced: = false



func net_end_result(r: = {}) -> Dictionary:
	return {"time": float(r.get("time", time)), "kills": int(r.get("kills", kills)), "level": int(r.get("level", player.level if player else 1)), 
		"class": player.job_name() if player else "", "best": _net_bank(r), "cards": [], "zeny": int(r.get("zeny", run_zeny)), 
		"sold": 0, "sold_zeny": 0, "sold_cards": 0, "cards_zeny": 0, "ymir": int(r.get("mvps", 0)), "zeny_from": {}, 

		"keep": [] if training else (r.get("keep", []) as Array).filter( func(it): return not (it is Dictionary and it.get("lent", false))), 
		"keep_free": bool(r.get("victory", false)), "materials": run_materials.duplicate(), "achievements": Achievements.check(), 
		"titles": titles.news(), "gods": [], 
		"record": {"score": 0, "mvps": 0, "online": false}}





func _net_bank(r: Dictionary) -> Dictionary:
	if player == null:
		return {}
	if _stats_banked or not r.has("xp"):
		return Save.best(player.class_id)
	_stats_banked = true

	if training:
		return Save.best(player.class_id)
	var cid: = player.class_id
	Save.add_kills(int(r.get("kills", 0)))


	Save.bump("coop_runs")

	var ores: Dictionary = r.get("ores", {}) if not training else {}
	for ore in ["oridecon", "elunium"]:
		var n: = int(ores.get(ore, 0))
		if n > 0:
			Save.add_material(ore, n)
			run_materials[ore] = int(run_materials.get(ore, 0)) + n
	meter_stats["best"] = float(r.get("best_hit", 0.0))
	meter_stats["total"] = float(r.get("dealt", meter_stats.get("total", 0.0)))
	time = float(r.get("time", time))
	player.level = maxi(player.level, int(r.get("level", 1)))
	player.equipment.legend_found = int(r.get("legends", 0))
	_track_achievements()

	var won: = bool(r.get("victory", false))
	var st: = str(r.get("stage", ""))
	if won and GameData.STAGES.has(st) and int(r.get("mvps", 0)) > 0:
		Save.clear_stage(st)
		if bool(r.get("hard", false)):
			Save.clear_stage_hard(st)
		Save.beat_danger(st, int(r.get("danger", danger)))
	for i in int(r.get("bosses", 0)):
		Save.add_boss_kill()
	if int(r.get("altars", 0)) > 0:
		Save.bump("altars", int(r.get("altars", 0)))
		Save.stat_max("altars_run", int(r.get("altars", 0)))

	if bool(r.get("quest", false)) and GameData.QUESTS.has(st) and not Save.quest_done(st):
		var rw: Dictionary = GameData.QUESTS[st].get("reward", {})
		if rw.has("pet"):
			Save.add_pet(str(rw.pet))
		if rw.has("card"):
			Save.add_card(str(rw.card))
		Save.complete_quest(st)
	var mvps: = int(r.get("mvps", 0))
	if mvps > 0:
		Save.bump("mvp_kills", mvps)
		Save.stat_max("hell_mvp", GameData.hell_level(danger))
		Save.add_ymir_fragment(mvps)


		for i in mvps:
			if randf() < GameData.MVP_COIN_CHANCE * (1.0 + float(player.effects.get("drop_find", 0.0))):
				found_coin(false)
	var before: = int(Save.class_progress(cid).level)
	var gained: = float(r.get("xp", 0.0))
	var ups: = Save.add_class_xp(cid, roundi(gained * GameData.danger_class_xp(int(r.get("danger", danger)))
		* (1.0 + GameData.FEATURED_BONUS if bool(r.get("featured", false)) else 1.0)))
	var res: = Save.record(cid, float(r.get("time", time)), bool(r.get("victory", false)))
	res["class_xp"] = roundi(gained)
	res["class_id"] = cid
	res["class_level"] = before + ups
	res["class_ups"] = ups
	Save.flush()
	return res




func _net_town_test(args: Array) -> void :
	var role: = ""
	var dir: = ""
	for a in args:
		if str(a).begins_with("--net-town="):
			role = str(a).substr(11)
	dir = str(args[args.find("--net-town=" + role) + 1])
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0).timeout
	var host: = role == "host"


	var cls: = "swordsman" if host else "mage"

	var lk: = Save.look(cls)
	lk["show"] = "lord_knight" if host else "high_wizard"
	Save.set_look(cls, lk)
	for id in (["cap", "angel_wing_ears"] if host else ["ribbon", "pipe"]):
		var have: Array = Save.storage().filter( func(x): return str(x.id) == id)
		if have.is_empty() and Save.add_to_storage(Equipment.make(id, 0)):
			have = [Save.storage().back()]
		if not have.is_empty():
			Save.set_loadout_slot(cls, str(GameData.ITEMS[id].slot), str(have[0].uid))
	enter_town(cls)
	if host:
		net.host()
	else:
		net.join(role, NetSync.PORT, "mage")
	for i in 60:
		if net.roster.size() >= 2:
			break
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(2.0).timeout
	town.hero.position += Vector3(2.0 if host else -2.0, 0, 0)
	if not host:
		menus.show_refiner()
	await get_tree().create_timer(2.0).timeout
	if not host:
		net.town_event("refine", true)
		net.town_chat("Mage : hola, vamos a Glast Heim?")
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, "host" if host else "client"])
	print("NETTOWN %s roster=%d party=%d" % [role, net.roster.size(), town._party.size()])
	await get_tree().create_timer(4.0 if host else 1.0).timeout
	get_tree().quit()





func _trade_net_test(args: Array) -> void :
	var role: = ""
	for a in args:
		if str(a).begins_with("--tradenet="):
			role = str(a).substr(11)
	var dir: = str(args[args.find("--tradenet=" + role) + 1])
	DirAccess.make_dir_recursive_absolute(dir)
	var host: = role == "host"
	var tag: = "host" if host else "client"
	await get_tree().create_timer(1.0).timeout
	for id in (["cap", "blade", "angel_wing_ears"] if host else ["ribbon", "pipe"]):
		Save.add_to_storage(Equipment.make(id, 3))
	Save.data.cards["poring_card" if host else "lunatic_card"] = 4
	Save.data["eternal"] = {"poring_card": 1} if host else {}
	if host:
		Save.storage()[0]["eternal"] = ["poring_card"]
		Save.storage()[0]["refine"] = 7
	Save.add_material("oridecon" if host else "elunium", 12)
	Save.add_zeny(50000)
	var report: = func( when : String):
		print("TRADE %s %s storage=%s cards=%s eternal=%s mats=%s zeny=%d" % [tag, when , 
			Save.storage().map( func(x): return "%s+%d%s" % [x.id, int(x.refine), x.get("eternal", [])]), 
			Save.data.cards, Save.data.get("eternal", {}), Save.materials(), Save.zeny()])
	report.call("before")
	enter_town("swordsman" if host else "mage")
	if host:
		net.host()
	else:
		net.join(role, NetSync.PORT, "mage")
	for i in 60:
		if net.roster.size() >= 2:
			break
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(2.0).timeout

	print("TRADE %s mode=%s" % [tag, menus.mode()])
	if menus.mode() != "town":
		menus.enter_town_mode()
	var t: Trade = menus.trade
	if not host:
		await get_tree().create_timer(1.5).timeout

		menus.show_trade_menu(1, Vector2(400, 300))
		await get_tree().process_frame
		var pm: PopupMenu = null
		for c in menus._root.get_children():
			if c is PopupMenu:
				pm = c
		print("TRADE client popup=", pm != null)
		if pm != null:
			pm.id_pressed.emit(0)
			pm.hide()
		else:
			t.ask(1)
	else:
		for i in 20:
			if menus.mode() == "trade_ask":
				break
			await get_tree().create_timer(0.25).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/0_ask.png" % dir)
		var other: = 0
		for m in net.roster:
			if int(m.id) != 1:
				other = int(m.id)
		t.answer(other, true)
	await get_tree().create_timer(1.5).timeout
	if host:
		t.add_item(str(Save.storage()[0].uid))
		t.add_item(str(Save.storage()[1].uid))
		t.add_card("poring_card", 2)
		t.add_mat("oridecon", 5)
		t.set_zeny(20000)
	elif menus._tr_picker == null or not is_instance_valid(menus._tr_picker):

		t.add_item(str(Save.storage()[0].uid))
		t.add_card("lunatic_card", 1)
		t.add_mat("elunium", 3)
	else:


		var click: = func(c: Control, right: = false):
			var at: = c.get_global_rect().get_center() * menus._ro_window_root.get_global_transform_with_canvas().get_scale() if false else c.get_global_rect().get_center()
			for down in [true, false]:
				var ev: = InputEventMouseButton.new()
				ev.button_index = MOUSE_BUTTON_RIGHT if right else MOUSE_BUTTON_LEFT
				ev.pressed = down
				ev.position = at
				ev.global_position = at
				Input.parse_input_event(ev)
				await get_tree().process_frame
			await get_tree().create_timer(0.3).timeout
		var first_cell: = func() -> Control:
			var grids: = menus._tr_picker.find_children("*", "GridContainer", true, false)
			return (grids[0] as GridContainer).get_child(0) if not grids.is_empty() and (grids[0] as GridContainer).get_child_count() > 0 else null
		await click.call(first_cell.call())
		await click.call(menus._tr_left.get_child(0))
		await click.call(first_cell.call())
		menus._tr_tab = "cards"
		menus._trade_picker()
		await get_tree().process_frame
		await click.call(first_cell.call(), true)
		menus._tr_tab = "mats"
		menus._trade_picker()
		await get_tree().process_frame
		await click.call(first_cell.call(), true)
		print("TRADE client clicked offer=", t.mine)
	await get_tree().create_timer(1.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/1_%s_offer.png" % [dir, tag])
	t.press_ok()
	await get_tree().create_timer(1.5).timeout
	menus._show_trade_confirm()
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/2_%s_confirm.png" % [dir, tag])
	menus._close_trade_confirm()
	if host:
		await get_tree().create_timer(1.0).timeout
	t.press_ready()
	await get_tree().create_timer(2.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/3_%s_done.png" % [dir, tag])
	report.call("after")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()







func _kick_test(args: Array) -> void :
	var role: = ""
	for a in args:
		if str(a).begins_with("--kicktest="):
			role = str(a).substr(11)

	var dev_hosts: = role in ["devhost", "victim"]
	var host: = role in ["host", "devhost"]
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	if dev_hosts:
		if host:
			Save.set_look("swordsman", {"name": "nearQhost", "gender": "m", "hair": 2, "hair_color": 1, "cloth": 0})
		else:
			Save._dev = 0
	elif host:
		Save._dev = 0
	else:
		Save.set_look("mage", {"name": "nearQtest", "gender": "m", "hair": 2, "hair_color": 1, "cloth": 0})
	var cls: = "swordsman" if host else "mage"
	enter_town(cls)
	await wait.call(1.0 if host else 3.0)
	print("KICKTEST %s is_dev=%s name=%s allowed=%s" % [role, Save.is_dev(), Save.char_name(cls), NameFilter.allowed("nearQtest")])
	channel.join_enet("" if host else "127.0.0.1")
	for i in 40:
		if channel.members.size() >= 2:
			break
		await wait.call(0.5)
	print("KICKTEST %s joined members=%d names=%s" % [role, channel.members.size(), channel.members.values().map( func(m): return m.name)])
	if role == "devhost":
		await wait.call(1.0)
		for id in channel.members:
			if int(id) != 1:
				channel.kick(int(id))
	elif not host and not dev_hosts:
		await wait.call(1.0)
		channel._send(1, "kick", [1, int(Time.get_unix_time_from_system()), "A".repeat(344)])
		await wait.call(2.0)
		print("KICKTEST join after forged: members=%d" % channel.members.size())
		channel.kick(1)
	await wait.call(6.0)
	print("KICKTEST %s end in=%s state=%s members=%d lines=%s" % [role, channel.is_in(), channel.state, channel.members.size(), 
		channel.lines.map( func(l): return str(l))])
	get_tree().quit()






func _quick_relay_test(args: Array) -> void :
	var a: = Array(args).has("--coopquick=a")
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	enter_town("swordsman" if a else "acolyte")
	await wait.call(1.0 if a else 4.0)
	await channel.join_async(1)
	for i in 30:
		if channel.members.size() >= 2:
			break
		await wait.call(0.5)
	print("QUICKTEST %s channel in=%s owner=%s members=%d" % ["a" if a else "b", channel.is_in(), channel._host, channel.members.size()])
	await wait.call(1.0 if a else 0.2)
	print("QUICKTEST %s search=%s" % ["a" if a else "b", await channel.quick_start_async()])
	channel.quick_vote("yes")
	for i in 60:
		if net.roster.size() >= 2:
			break
		await wait.call(0.5)
	print("QUICKTEST %s party mode=%s roster=%d code=%s" % ["a" if a else "b", net.mode, net.roster.size(), net.eos().code])
	await wait.call(3.0)
	if a:
		await channel.leave_async(true)
		print("QUICKTEST a left the channel")
		await wait.call(8.0)
	else:
		await wait.call(8.0)
		print("QUICKTEST b after owner left: state=%s owner=%s members=%d" % [channel.state, channel._host, channel.members.size()])
	get_tree().quit()











func _handoff_test(args: Array) -> void :
	var role: = ""
	for a in args:
		if str(a).begins_with("--hotest="):
			role = str(a).substr(9)
	var order: = ["host", "a", "b", "c"]
	var me_i: = order.find(role)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var t0: = Time.get_ticks_msec()
	var at: = func(s: float):
		while (Time.get_ticks_msec() - t0) / 1000.0 < s:
			await get_tree().create_timer(0.1, true, false, true).timeout
	await wait.call(1.0)

	for i in order.size():
		var cls: String = ["swordsman", "mage", "archer", "acolyte"][i]
		var lk: = Save.look(cls)
		lk["name"] = "Ho" + str(order[i]).capitalize()
		Save.set_look(cls, lk)
	enter_town(["swordsman", "mage", "archer", "acolyte"][me_i])
	await at.call(4.0 + 1.5 * me_i)
	channel.join_enet("" if role == "host" else "127.0.0.1")
	for i in 60:
		if channel.members.size() >= 4:
			break
		await wait.call(0.25)
	print("HOTEST %s joined members=%d" % [role, channel.members.size()])

	var seen: = {}
	var vanished: = {}
	var redrawn: = {}
	var lost: = {"n": 0}
	var leaving: = {"host": 16.0, "a": 28.0}
	var gone: = {}
	var watch: = func():
		var now: = (Time.get_ticks_msec() - t0) / 1000.0
		if channel.reconnecting():
			lost.n += 1
		var drawn: = {}
		for id in town._party:
			var m: Dictionary = town._party[id]
			if m.has("node") and is_instance_valid(m.node):
				drawn[str(m.get("name", ""))] = m.node.get_instance_id()
		for n in seen:
			if gone.has(n):
				continue
			if not drawn.has(n):
				vanished[n] = vanished.get(n, []) + [snappedf(now, 0.1)]
				print("HODBG %s %.1f vanished %s party=%s members=%s ghosts=%s coming=%s" % [role, now, n, town._party.keys().map( func(k): return [k, town._party[k].get("name", "")]), channel.members.keys().map( func(k): return [k, channel.members[k].get("name", "")]), channel._ghosts.keys(), town._coming.keys()])
			elif drawn[n] != seen[n]:
				redrawn[n] = redrawn.get(n, []) + [snappedf(now, 0.1)]
		for n in drawn:
			seen[n] = drawn[n]
		for r in leaving:
			if now >= float(leaving[r]) - 0.3:
				gone[Save.char_name(["swordsman", "mage", "archer", "acolyte"][order.find(r)])] = true
	while (Time.get_ticks_msec() - t0) / 1000.0 < 38.0:
		var now: = (Time.get_ticks_msec() - t0) / 1000.0
		if leaving.has(role) and now >= float(leaving[role]) and channel.is_in():
			print("HOTEST %s leaves (host=%s)" % [role, channel._host])
			await channel.leave_async(true)
			print("HOTEST %s left at %.1f" % [role, (Time.get_ticks_msec() - t0) / 1000.0])
		if channel.is_in():
			town.hero.position += Vector3(randf_range(-0.6, 0.6), 0, randf_range(-0.6, 0.6))
			watch.call()
		await wait.call(0.1)
	print("HOTEST %s end in=%s host=%s members=%d drawn=%d lost_frames=%d vanished=%s redrawn=%s seen=%s" % [role, channel.is_in(), channel._host, 
		channel.members.size(), town._party.size(), lost.n, vanished, redrawn, seen.keys()])

	await wait.call(3.0)
	get_tree().quit()


func _channel_test(args: Array) -> void :
	var role: = ""
	for a in args:
		if str(a).begins_with("--chantest="):
			role = str(a).substr(11)
	var dir: = str(args[args.find("--chantest=" + role) + 1])
	DirAccess.make_dir_recursive_absolute(dir)
	var host: = role == "host"
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var snap: = func(key: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [dir, role, key])
	await wait.call(1.0)
	var cls: = "swordsman" if host else "mage"
	enter_town(cls)
	await wait.call(1.0)
	if not host:
		await wait.call(2.0)

	if Array(args).any( func(a): return str(a).begins_with("--relay=")):
		if not channel.is_in():
			await channel.join_async(1)
	else:
		channel.join_enet("" if host else "127.0.0.1")
	for i in 40:
		if channel.members.size() >= 2:
			break
		await wait.call(0.5)
	print("CHANTEST %s in=%s members=%d drawn=%s" % [role, channel.is_in(), channel.members.size(), 
		town._party.keys().map( func(id): return [id, town._party[id].node.position, town._party[id].to])])
	town.hero.position += Vector3(2.0 if host else -2.0, 0, 1.0)
	await wait.call(1.5)
	var crowd: TownCrowd = town._crowd
	crowd._send_chat("hola canal desde %s" % role)
	await wait.call(1.5)
	var other_name: = ""
	for id in channel.members:
		if int(id) != channel.my_id():
			other_name = channel.name_of(int(id))
	if host:
		crowd._send_chat("/w %s psst desde host" % other_name)
	await wait.call(1.5)
	if not host:
		crowd._send_chat("/r respuesta privada")
	await wait.call(1.5)
	await snap.call("1_channel")
	if host:
		var other: = 0
		for id in channel.members:
			if int(id) != 1:
				other = int(id)
		print("CHANTEST host can_invite=%s" % channel.can_invite(other))
		menus.show_trade_menu( - other, Vector2(400, 300))
		await wait.call(0.6)
		await snap.call("2_menu")
		for c in menus._root.get_children():
			if c is PopupMenu:
				c.id_pressed.emit(3)
				c.hide()
		await wait.call(0.5)
		await snap.call("2a_whisper")
		print("CHANTEST host whisper_line=%s typing=%s" % [crowd._chat_box.text, crowd.typing()])
		crowd._close_chat()
		await menus._ask_gear(other)
		await wait.call(0.5)
		await snap.call("2b_gear")
		menus._back_to_hub()
		print("CHANTEST host crowd=%d/%d" % [town._crowd._people.size(), town._crowd._base])
		await channel.invite_async(other)
		for i in 30:
			if net.roster.size() >= 2:
				break
			await wait.call(0.5)
	else:
		menus.show_coop()
		await wait.call(0.8)
		await snap.call("1b_lydia")
		menus._coop_channels()
		await wait.call(1.0)
		await snap.call("1c_channels")
		menus._back_to_hub()
		for i in 40:
			if not channel.invites.is_empty():
				break
			await wait.call(0.5)
		await wait.call(0.5)
		await snap.call("2_invite")
		if not channel.invites.is_empty():
			channel.answer_invite(int(channel.invites[0].from), true)
		for i in 30:
			if net.roster.size() >= 2:
				break
			await wait.call(0.5)
	await wait.call(2.5)
	crowd._send_chat("%%party lista (%s)" % role)
	await wait.call(1.5)
	await snap.call("3_party")
	print("CHANTEST %s room=%s roster=%d party_mates=%s lines=%s" % [role, net.mode, net.roster.size(), 
		channel.members.keys().filter( func(id): return channel.in_my_party(int(id))), channel.lines.map( func(l): return str(l))])
	if "--via" in args:


		if not host:
			channel._step_aside()
		for i in 20:
			await wait.call(0.5)
			if i % 4 == 0:
				print("CHANTEST via %s in=%s state=%s via=%d riders=%s members=%s" % [role, channel.is_in(), channel.state, channel._via, 
					channel._riders, channel.members.keys()])
		crowd._send_chat("por el canal via sala (%s)" % role)
		town.hero.position += Vector3(-1.5 if host else 1.5, 0, -1.0)
		await wait.call(2.0)
		await snap.call("5_via")
		print("CHANTEST via %s end members=%s drawn=%s lines=%s" % [role, channel.members.keys(), town._party.keys(), 
			channel.lines.slice(-4).map( func(l): return str(l))])
	if host:

		Save.set_setting("chat_min", true)
		town._crowd._log._apply_min()
		await wait.call(0.5)
		await snap.call("3b_chat_min")
		Save.set_setting("chat_min", false)
		town._crowd._log._apply_min()
		menus.show_coop()
		await wait.call(1.0)
		await snap.call("4_lydia")
	await wait.call(4.0 if host else 2.0)
	get_tree().quit()






func _fest_net_test(args: Array) -> void :
	var role: = ""
	for a in args:
		if str(a).begins_with("--festnet="):
			role = str(a).substr(10)
	var dir: = str(args[args.find("--festnet=" + role) + 1])
	DirAccess.make_dir_recursive_absolute(dir)
	var host: = role == "host"
	var tag: = "host" if host else "client"
	await get_tree().create_timer(1.0).timeout
	var cls: = "swordsman" if host else "acolyte"
	start_run(cls)
	player.level = 40
	player.job_change(0)
	player.pending_levels = 0
	for id in player.skill_pool().slice(0, 4):
		for k in 5:
			player.add_skill(id)
	Save.data["tower"] = {"builds": [], "best": {}, "top": 20, "rewards": []}
	Save.add_tower_build(RunSave.hero_snapshot(self))
	abandon_run()
	enter_town(cls)
	if host:
		net.host()
	else:
		net.join(role, NetSync.PORT, cls)
	for i in 60:
		if net.roster.size() >= 2:
			break
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(1.5).timeout
	menus.auto_pick = true
	var snap: = func(key: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [dir, tag, key])
	if host:
		net.ask_festival()
		menus.show_festival_wait(0)
		for i in 30:
			if net.tower_ready():
				break
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(0.8).timeout
		await snap.call("1_wait")
		print("FESTNET host ready=%s" % net.tower_ready())
		start_festival(0)


		await get_tree().create_timer(float(OS.get_environment("FESTNET_WAIT")) if OS.get_environment("FESTNET_WAIT") != "" else 3.0).timeout
		festival.begin()
		await get_tree().create_timer(5.5).timeout
		autopilot = true
		player.altar_mods["dmg"] = 30.0
		player.recompute()
		await get_tree().create_timer(8.0).timeout
		await snap.call("2_fight")
		print("FESTNET host heroes=%d checks=%d score=%.0f" % [heroes.size(), festival.checks, festival.score()])
		festival.left = 0.5
		await get_tree().create_timer(4.0).timeout
		await snap.call("3_result")
		print("FESTNET host end mode=%s builds=%d" % [menus.mode(), Save.tower_builds().size()])
		await get_tree().create_timer(10.0).timeout
	else:
		for i in 40:
			if menus.mode() == "tower_join":
				break
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(1.0).timeout
		await snap.call("1_join")
		menus._festival_join_pick(0)
		for i in 40:
			if running and festival != null:
				break
			await get_tree().create_timer(0.5).timeout
		print("FESTNET client started fest=%s mirror=%s map=%s lv=%d job=%s builds=%d" % [festival != null, festival.mirror if festival != null else false, 
			map.map_name, player.level, player.job2.get("id", ""), Save.tower_builds().size()])
		autopilot = true
		await get_tree().create_timer(16.0).timeout
		await snap.call("2_fight")
		print("FESTNET client state=%s checks=%d score=%.0f" % [festival.state if festival != null else "-", festival.checks if festival != null else -1, festival.score() if festival != null else -1.0])
		for i in 80:
			if menus.mode() == "festival_result" or not running:
				break
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(2.0).timeout
		await snap.call("3_result")
		print("FESTNET client end mode=%s state=%s" % [menus.mode(), festival.state if festival != null else "-"])
	get_tree().quit()






func _tower_net_test(args: Array) -> void :
	var role: = ""
	for a in args:
		if str(a).begins_with("--towernet="):
			role = str(a).substr(11)
	var dir: = str(args[args.find("--towernet=" + role) + 1])
	DirAccess.make_dir_recursive_absolute(dir)
	var host: = role == "host"
	var tag: = "host" if host else "client"
	await get_tree().create_timer(1.0).timeout

	var cls: = "swordsman" if host else "acolyte"
	start_run(cls)
	player.level = 40
	player.job_change(0)
	for id in player.skill_pool().slice(0, 4):
		for k in 5:
			player.add_skill(id)
	Save.data["tower"] = {"builds": [], "best": {}, "top": 20, "rewards": [10, 20]}
	Save.add_tower_build(RunSave.hero_snapshot(self))
	abandon_run()
	enter_town(cls)
	if host:
		net.host()
	else:
		net.join(role, NetSync.PORT, cls)
	for i in 60:
		if net.roster.size() >= 2:
			break
		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(1.5).timeout
	autopilot = true
	menus.auto_pick = true
	var snap: = func(key: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s_%s.png" % [dir, tag, key])
	if host:
		menus.show_tower()
		await get_tree().create_timer(1.0).timeout
		await snap.call("1_lucile")
		print("TOWERNET host floors=%s" % [net.tower_floors()])
		net.ask_tower(21)
		menus.show_tower_wait(0, 21)
		for i in 30:
			if net.tower_ready():
				break
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(0.8).timeout
		await snap.call("2_wait")
		print("TOWERNET host ready=%s party=%s" % [net.tower_ready(), net.tower_party.keys()])
		start_tower(0, 21)
	else:
		for i in 40:
			if menus.mode() == "tower_join":
				break
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(1.0).timeout
		await snap.call("1_join")
		menus._tower_join_pick(21, 0)
		await get_tree().create_timer(0.8).timeout
		await snap.call("2_picked")
		for i in 40:
			if running and tower != null:
				break
			await get_tree().create_timer(0.5).timeout
		print("TOWERNET client started tower=%s builds_left=%d lv=%d job=%s skills=%d" % [tower != null, Save.tower_builds().size(), 
			player.level, player.job2, player.skills.size()])
	if "--towercamp" in args:


		for k in 20:
			if tower != null and tower.state in ["fight", "event", "boss"]:
				break
			await get_tree().create_timer(0.5).timeout
		autopilot = false
		await get_tree().create_timer(3.0).timeout
		if host:
			tower.floor = 20
			tower._cleared()
		for k in 16:
			await get_tree().create_timer(0.5).timeout
			if host:
				for h in heroes:
					h.max_hp = 10000000.0
					h.hp = h.max_hp
			elif tower._lucile != null and is_instance_valid(tower._lucile) and k < 10:
				player.position = tower._lucile.position + Vector3(0.5, 0, 0)
			print("TOWERCAMP %s k=%d state=%s talked=%s gift=%s lucile=%s" % [tag, k, tower.state, tower._camp_talked, tower._camp_gift, 
				tower._lucile != null and is_instance_valid(tower._lucile)])
		get_tree().quit()
		return
	if "--towerwheel" in args:


		for k in 20:
			if tower != null and tower.state in ["fight", "event", "boss"]:
				break
			await get_tree().create_timer(0.5).timeout
		menus.auto_pick = false
		for k in 12:
			if host:
				for h in heroes:
					h.max_hp = 10000000.0
					h.hp = h.max_hp
			await get_tree().create_timer(0.5).timeout
		if host:
			tower._events.cleanup()
			tower._start_event("wheel")
		var find_btn: = func(texts: Array) -> Button:
			var stack: Array = [menus]
			while not stack.is_empty():
				var n: Node = stack.pop_back()
				if n is Button and (n as Button).text in texts and not (n as Button).disabled and (n as Button).is_visible_in_tree():
					return n
				stack.append_array(n.get_children())
			return null
		for k in 80:
			await get_tree().create_timer(0.5).timeout
			if host:
				for h in heroes:
					h.max_hp = 10000000.0
					h.hp = h.max_hp
			if k % 6 == 0:
				print("TOWERWHEEL %s k=%d mode=%s" % [tag, k, menus.mode()])
			var b: Button = find_btn.call([tr("¡GIRAR!")])
			if b != null:
				print("TOWERWHEEL %s spins (turn) mode=%s" % [tag, menus.mode()])
				b.pressed.emit()
			if k == 8:
				await snap.call("wheel_turns")
			var end: Button = find_btn.call([tr("Seguir subiendo"), tr("Cerrar")])
			if end != null:
				print("TOWERWHEEL %s all spun buffs=%s curses=%s" % [tag, tower.wheel_buffs, tower.wheel_curses])
				await snap.call("wheel_end")
				end.pressed.emit()
				break
		await get_tree().create_timer(2.0).timeout
		print("TOWERWHEEL %s after state=%s line=%s" % [tag, tower.state, tower.hud_state()])
		get_tree().quit()
		return
	if "--towerdie" in args:

		for k in 20:
			if tower != null and tower.state in ["fight", "event", "boss"]:
				break
			await get_tree().create_timer(0.5).timeout
		if host:
			player.revives = 0
			for k in 10:
				if not player.downed:
					player._invuln = 0.0
					player.take_damage(1000000000000.0, self, null, true)
		for k in 8:
			await get_tree().create_timer(1.0).timeout
			print("TOWERDIE %s t=%d running=%s downed=%s fell=%s death_by=%s party=%s" % [tag, k, running, player.downed, player.fell, player.death_by, 
				heroes.map( func(h): return "%s%s%s" % [h.class_id, " DOWN" if h.downed else "", " BOT" if h.input is HeroInput.BotHero else ""])])
		get_tree().quit()
		return
	if "--towerev" in args:


		for k in 20:
			if tower != null and tower.state in ["fight", "event", "boss"]:
				break
			await get_tree().create_timer(0.5).timeout
		for id in ["survive", "ambush", "emperium", "treasure", "wheel"]:
			if host:
				tower._events.cleanup()
				tower._start_event(id)
			for k in 4:
				await get_tree().create_timer(1.5).timeout
				if host:
					for h in heroes:
						h.max_hp = 10000000.0
						h.hp = h.max_hp
				if host:
					print("TOWEREV host %s t=%d line=%s paused=%s menu=%s arena=%s running=%s" % [id, k, tower.hud_state(), get_tree().paused, menus.mode(), raid.in_arena(), running])
				else:
					var emp: = enemies.filter( func(e): return e.id == "item_emperium")
					print("TOWEREV client %s t=%d line=%s cage=%s emp_scale=%s" % [id, k, tower.hud_state(), 
						tower._events._mirror_look != null and is_instance_valid(tower._events._mirror_look), 
						(emp[0].visual as Node3D).scale.x if not emp.is_empty() and emp[0].visual is Node3D else -1.0])
				if k == 1:
					await snap.call("ev_" + id)
			if host:
				tower._events.cleanup()
				tower._events.done = true
			await get_tree().create_timer(1.0).timeout
		get_tree().quit()
		return

	var shot: = 0
	for i in 150:
		await get_tree().create_timer(0.5).timeout
		if not running or tower == null:
			break
		if host:
			tower.need = mini(tower.need, 6)
			for e in enemies:
				if not e.is_boss:
					e.hp = minf(e.hp, 1.0)
			for h in heroes:
				h.max_hp = 1000000.0
				h.hp = h.max_hp
			if i % 10 == 0:
				var others: = heroes.filter( func(h): return h != player).map( func(h): return "%s lv%d job=%s mods=%s" % [h.class_id, h.level, h.job2, h.tower_mods])
				print("TOWERNET host t=%d floor=%d state=%s map=%s best=%d party=%s" % [i / 2, tower.floor, tower.state, map.map_name, tower.best, others])
		elif i % 10 == 0:
			print("TOWERNET client t=%d floor=%d state=%s map=%s best=%d top=%d bless=%s line=%s" % [i / 2, tower.floor, tower.state, map.map_name, tower.best, 
				Save.tower_top(), tower.blessings, tower.hud_state()])
		if i in [20, 60, 110]:
			shot += 1
			await snap.call("3_climb%d" % shot)
		if host and tower.floor >= 28 and tower.state == "fight":
			break
	if host:
		await snap.call("4_end")
		_end_run(true)
		await get_tree().create_timer(3.0).timeout
	else:
		for i in 20:
			if not running:
				break
			await get_tree().create_timer(0.5).timeout
		await get_tree().create_timer(1.0).timeout
		await snap.call("4_end")
		print("TOWERNET client end top=%d best=%s" % [Save.tower_top(), Save.data.tower.best])
	get_tree().quit()




func _net_test_join(args: Array) -> void :
	var addr: = "127.0.0.1"
	var cls: = "swordsman"
	for a in args:
		if str(a).begins_with("--net-join="):
			addr = str(a).substr(11)
		elif str(a).begins_with("--net-class="):
			cls = str(a).substr(12)
	var port: = NetSync.PORT
	if addr.contains(":"):
		port = int(addr.get_slice(":", 1))
		addr = addr.get_slice(":", 0)
	if "--net-auto" in args:
		autopilot = true
		menus.auto_pick = true


	if addr == "relay":
		var code: = ""
		for a in args:
			if str(a).begins_with("--net-join=relay:"):
				code = str(a).substr(17)
		var code_file: = OS.get_temp_dir().path_join("midgard_relay_code.txt")
		for i in 60:
			if code != "":
				break
			if FileAccess.file_exists(code_file):
				code = FileAccess.get_file_as_string(code_file).strip_edges()
			if code == "":
				await get_tree().create_timer(0.5).timeout
		var peer = await net.eos().join_async(code)
		print("NET relay join %s: %s %s" % [code, peer != null, net.eos().error])
		if peer != null:
			net.join("", 0, cls, peer)
		return
	net.join(addr, port, cls)






func _net_test_host(args: Array) -> bool:
	if not Array(args).any( func(a): return str(a).begins_with("--relay=")):


		for a in args:
			if str(a).begins_with("--net-port="):
				return net.host(int(str(a).substr(11)))
		return net.host()
	var eos = net.eos()
	var peer: MultiplayerPeer = null
	var code_file: = OS.get_temp_dir().path_join("midgard_relay_code.txt")
	if "--bridge-enet" in args:
		var enet: = ENetMultiplayerPeer.new()
		if enet.create_server(NetSync.PORT, 3) != OK:
			return false
		var view = await eos._open_room("BRIDGE", "host", 12.0, false)
		if view == null:
			print("NET bridge failed: %s" % eos.error)
			return false
		peer = load("res://scripts/net/bridge_peer.gd").new(enet, view)
	else:
		peer = await eos.host_async()
		if peer == null:
			print("NET relay host failed: %s" % eos.error)
			return false
		var f: = FileAccess.open(code_file, FileAccess.WRITE)
		f.store_string(str(eos.code))
		f.close()
	print("NET relay hosting %s" % eos.code)
	return net.host(0, peer)






var run_cards: Array = []


var run_stored: Array = []


func _take_card(card_id: String, at: Vector3) -> void :
	if training:
		return
	emote(player, "idea")
	var slot: = player.add_card(card_id)
	var is_new: = Save.add_card(card_id)
	run_cards.append({"id": card_id, "new": is_new})



	if is_new and not menus.auto_pick:
		_card_window(card_id, true, false)
	else:
		hud.announce(tr(GameData.CARDS[card_id].name), Color(1, 1, 0.3), 
			tr(GameData.CARDS[card_id].desc) if slot != "" else tr("Sin ranura: guardada en la bolsa de cartas (Q)"))



func give_card(h: Player, card_id: String) -> void :
	h.add_card(card_id)
	number(h.position + Vector3(0, 2.2, 0), tr("Carta: %s") % tr(GameData.CARDS[card_id].name), Color(1, 0.9, 0.4), true)
	net.send_got(h, "card", card_id)




func give_item(h: Player, it: Dictionary) -> Dictionary:

	h.equipment.coins_here = h == player
	var got: = h.equipment.receive(it)
	h.recompute()
	net.send_got(h, "item", it)
	return got



func hero_label(h: Player) -> String:
	return tr("Tú") if h == player else tr(h.job_name())





func _coop_chest(p: Dictionary, _by: Player) -> bool:
	var count: = int(p.value)
	var bonus: = int(p.get("bonus", 0))
	var plain: = int(p.get("plain", 0))
	var at: = (p.node as Node3D).position
	var rolled: = []
	for h in heroes:
		var n: = count

		if h.has_dish("lucky_soup") and randf() < float(GameData.RECIPES.lucky_soup.extra_roll):
			n += 1
		for i in n:
			var it: = h.equipment.roll_item(time, bonus if i < n - plain else -1)


			var tries: = 0
			while Equipment.is_legendary(it) and not Equipment.is_unique(it) and randf() >= 1.0 / heroes.size() and tries < 6:
				it = h.equipment.roll_item(time, bonus if i < n - plain else -1)
				tries += 1
			if Equipment.is_legendary(it):
				rolled.append(it)
				continue
			var got: = give_item(h, it)
			add_zeny(int(got.zeny), "sold", h)
			_loot_toast(h, it, str(got.result))
		h.recompute()
		if bonus < 0:

			add_zeny(roundi((GameData.SMALL_CHEST_ZENY + time / 10.0) * h.loot_mult / GameData.coop_spawn(heroes.size())), "chest", h)
	var uid: = str(p.get("unique", ""))
	if uid == "" and bonus >= 0:
		uid = _roll_unique_party(GameData.UNIQUE_BOSS_CHANCE)
	if uid != "":
		rolled.append(Equipment.make(uid, 0))
	play_sound("chest_open", 0.0, 0.0)
	RoEffect.spawn(fx_root, "itempokjuk", at + Vector3(0, 0.4, 0), 1.0)
	if not rolled.is_empty():
		loot_queue.append(LootRoll.make(rolled, int(p.get("tier", 0)), at))
		_next_loot()
	return true




func _roll_unique_party(chance: float) -> String:
	var id: = GameData.unique_of_stage(stage_id)
	if id == "" or tower != null:
		return ""

	var shared: = GameData.stage_shared_uniques(stage_id)
	if shared.size() > 1:
		id = str(shared.pick_random())



	for h in heroes:
		var own: = GameData.unique_of_stage(stage_id, h.equipment.job_id)
		if own != id and not shared.has(own) and not _has_unique(h, own):
			id = own
			break
	chance *= GameData.unique_mult(danger)


	if heroes.all( func(h): return _has_unique(h, id)):
		chance *= GameData.UNIQUE_OWNED_MULT
	if GameData.has_meta("force_unique"):
		chance = 1.0
	return "" if randf() >= chance else id


func _has_unique(h: Player, id: String) -> bool:
	if h.equipment.has_item(id) or h.equipment.bag.any( func(b): return str(b.id) == id):
		return true
	if h == player:
		return Save.storage().any( func(st): return str(st.id) == id)
	return h.stored_uniques.has(id)




func _next_loot() -> void :
	if _loot != null or loot_queue.is_empty() or not running:
		return
	_loot = loot_queue.pop_front()
	_loot_held = 0.0
	for h in heroes:
		if loot_absent(h):

			_loot.ready[h.slot] = true
		elif h.input is HeroInput.BotHero or (h == player and menus.auto_pick and not OS.get_cmdline_user_args().has("--coop-manual")):
			_loot.auto_pick(h)
		else:
			_loot.preset(h, func(id: String) -> bool: return _has_unique(h, id))
	if net.is_host():
		net.send_loot(_loot)
	play_sound("drop_yellow", 0.0, -2.0)
	Vfx.burst(fx_root, _loot.at, 3.0, GameData.CHEST_COLORS[clampi(_loot.tier, 0, GameData.CHEST_COLORS.size() - 1)])
	_loot_panel = LootPanel.new()
	hud.add_child(_loot_panel)
	_loot_panel.setup(self, _loot)
	if _smoke_seconds > 0.0:
		print("COOP roll at %.1f: %s" % [time, _loot.items.map( func(it): return Equipment.item_name(it))])


var _loot_held: = 0.0




func loot_absent(h: Player) -> bool:
	return h.has_meta("player_gone")


func loot_waits_for_me() -> bool:

	var offer: LootRoll = net._loot if net.is_client() else _loot
	var panel: LootPanel = net._loot_panel if net.is_client() else _loot_panel
	return offer != null and panel != null and is_instance_valid(panel) and not panel._rolling and not offer.ready.get(player.slot, false)




func _update_loot(delta: float) -> void :
	if _loot == null or _loot_panel == null or not is_instance_valid(_loot_panel) or _loot_panel._rolling:
		return


	var busy_choosing: = heroes.any( func(h): return is_instance_valid(h) and h.choosing and not _loot.ready.get(h.slot, false))
	if busy_choosing and _loot_held < LootRoll.HOLD_MAX:
		_loot_held += delta
	else:
		_loot.t -= delta
	var all_ready: = heroes.all( func(h): return _loot.ready.get(h.slot, false) or loot_absent(h))
	if not all_ready and _loot.t > 0.0:
		return
	_resolve_loot()




func _resolve_loot() -> void :
	var offer: = _loot


	for h in heroes:
		if loot_absent(h):
			offer.picks.erase(h.slot)

	offer.give_standing_passes(heroes.filter( func(h): return not loot_absent(h)))
	var results: = offer.resolve()
	if _smoke_seconds > 0.0:
		for r in results:
			print("COOP loot %s want=%s rolls=%s -> %s" % [Equipment.item_name(r.item), r.want, r.rolls, r.winner])
	var left: = 0
	for r in results:
		var it: Dictionary = r.item
		if int(r.winner) < 0:


			left += GameData.ITEM_SELL_LEGENDARY if Equipment.legend_coins(it) > 0 else Equipment.sell_price(it)
			continue
		var h: Player = heroes[int(r.winner)]
		if LootRoll.is_unique(it) and h == player:
			_found_unique(str(it.id))
			_loot_toast(h, it, "unique")
			continue
		if LootRoll.is_unique(it) and net.is_remote(h):

			if h.equipment.can_wear(it):
				h.equipment.receive(it)
			else:
				h.equipment.bag.append(it)
			h.recompute()
			net.send_got(h, "unique", it)
			_loot_toast(h, it, "unique")
			continue
		if LootRoll.is_unique(it) and not h.equipment.can_wear(it):
			h.equipment.bag.append(it)
			h.recompute()
			net.send_got(h, "bag", it)
			continue
		var got: = give_item(h, it)
		add_zeny(int(got.zeny), "sold", h)
		_loot_toast(h, it, str(got.result))
		if str(it.id) == GameData.TOWER_WINGS:
			_wings_got(h)
	var present: = heroes.filter( func(h): return not loot_absent(h))
	if left > 0 and not present.is_empty():
		for h in present:
			add_zeny(left / present.size(), "sold", h)
	if net.is_host():
		net.send_loot_result(results)
	_loot_panel.show_rolls(results)
	_loot_panel.finished.connect( func():
		_loot = null
		_loot_panel = null
		_next_loot())


var _toasts: = {}




func _loot_toast(h: Player, it: Dictionary, result: String) -> void :
	var how: = {"equipped": tr("equipado"), "bagged": tr("a la bolsa"), "sold": tr("vendido"), "unique": tr("¡único!")}
	var text: = "%s (%s)" % [Equipment.item_name(it), how.get(result, "")]
	var col: = Equipment.item_world_color(it)
	var key: = h.get_instance_id()
	var st: Array = _toasts.get(key, [0, -1.0])
	if time > float(st[1]):
		st[0] = 0
	var n: = int(st[0])
	st[0] = n + 1
	st[1] = time + 0.4 + 0.35 * (n + 1)
	_toasts[key] = st
	var show: = func():
		if running and is_instance_valid(h):
			number(h.position + Vector3(0, 2.2, 0), text, col, true)
			if Equipment.is_legendary(it):
				emote(h, "money", 2.5)
	if n == 0:
		show.call()
	else:
		get_tree().create_timer(0.35 * n, false).timeout.connect(show)




func _update_party(delta: float) -> void :
	if not get_tree().paused:
		_update_loot(delta)
	if _coop_chest_at > 0.0 and time >= _coop_chest_at:

		_coop_chest_at = 0.0
		GameData.set_meta("force_unique", true)
		_drop_chest(player.position + Vector3(1.5, 0, 0), GameData.CHEST_ROLLS.boss, 1)
	if _coop_down_at > 0.0 and time >= _coop_down_at:

		_coop_down_at = 0.0
		heroes[1].revives = 0
		for i in 50:
			if not heroes[1].downed:
				heroes[1]._invuln = 0.0
				heroes[1].take_damage(1000000000.0, self, null, true)
		print("COOP down %s hp=%d downed=%s" % [heroes[1].class_id, heroes[1].hp, heroes[1].downed])
	for h in heroes:
		if h.downed:
			var helper: = false

			var speed: = 1.0
			for o in heroes:
				if o != h and not o.downed and o.position.distance_to(h.position) < GameData.COOP_REVIVE_RANGE:
					helper = true
					if _is_healer(o):
						speed = maxf(speed, GameData.COOP_REVIVE_HEALER)
						h.set_meta("healer_raise", true)
			h.revive_t = h.revive_t + delta * speed if helper else maxf(0.0, h.revive_t - delta)
			if helper:

				h.set_meta("revive_fx", float(h.get_meta("revive_fx", 0.0)) - delta)
				if float(h.get_meta("revive_fx")) <= 0.0:
					h.set_meta("revive_fx", 0.32)
					var k: = h.revive_t / GameData.COOP_REVIVE_TIME
					Vfx.ring(fx_root, h.position + Vector3(0, 0.08, 0), 0.6 + 1.6 * k, Color(0.55, 1.0, 0.6, 0.9), 0.4)
					play_sound("ui_click", 0.0, -14.0 + 8.0 * k)
			if h.revive_t >= GameData.COOP_REVIVE_TIME:
				_revive_hero(h)
				if _smoke_seconds > 0.0:
					print("COOP revived %s at %.1f" % [h.class_id, time])
			continue
		if h == player or not (h.input is HeroInput.BotHero):
			continue
		if h.skills.has("call_homunculus") and h.homun_type == "":
			h.homun_type = GameData.HOMUNCULI.keys().pick_random()
			spawn_homun(h)
		check_more_homun(h)
		for k in h.equipment.refinable_now():
			refine(k, h)
		if h.can_job_change():
			h.job_change(randi() % maxi(1, GameData.job_paths(h.class_id).size()))
			job_change_show(h)
			_on_level_up(h)
		elif h.pending_levels > 0:
			var choices: = h.build_choices()
			if choices.is_empty():
				h.pending_levels = 0
			else:
				h.apply_choice(Bot.pick_choice(h, choices), self)
				h.pending_levels -= 1



func fallen_ally(h: Player) -> Player:
	var best: Player = null
	for o in heroes:
		if o != h and o.downed and (best == null or o.position.distance_to(h.position) < best.position.distance_to(h.position)):
			best = o
	return best



func _is_healer(h: Player) -> bool:
	return h.skills.has("heal") or h.skills.has("sanctuary") or h.skills.has("gospel")


func _revive_hero(h: Player) -> void :
	h.downed = false
	h.revive_t = 0.0
	h.hp = h.max_hp * (GameData.COOP_REVIVE_HEALER_HP if h.get_meta("healer_raise", false) else GameData.COOP_REVIVE_HP)
	h.set_meta("healer_raise", false)
	h._invuln = GameData.COOP_REVIVE_INVULN
	h.visual.play(RoVisual.PC_IDLE)
	Vfx.column(fx_root, h.position, Color(0.7, 1.0, 0.7))
	play_sound("heal")
	label_over(h, tr("¡De pie!"), Color(0.6, 1.0, 0.6))




var _frame_us: = 0
var _frame_last_us: = 0


func _process(delta: float) -> void :

	hell_late.draw_tick()
	_title_t -= delta
	if _title_t <= 0.0:
		_title_t = TITLE_EVERY
		_cull_titles()



	var now_us: = Time.get_ticks_usec()
	if _frame_us > 0 and now_us - _frame_us > (50000 if RoAssets._log_loads else 150000):
		print("HITCH %.0f ms at t=%.1f (%s)" % [(now_us - _frame_us) / 1000.0, time, menus.mode() if running or town != null else "menu"])

	if _frame_us > 0:
		perf.frame(self, (now_us - _frame_us) / 1000000.0)
	_frame_us = now_us
	_game_ms += delta * 1000.0
	_tick_chime(delta)


	_frames_trim_t -= delta
	if _frames_trim_t <= 0.0:
		_frames_trim_t = RoAssets.FRAMES_TRIM_EVERY if running else RoAssets.FRAMES_TRIM_TOWN
		RoAssets.trim_frames()
	gem_renderer.visible = town == null and running
	if town != null:
		Vfx.batch_root = null
		town.tick(minf(delta, 0.05))
		_update_camera_on(town.hero.position, delta)
		return
	if not running:
		Vfx.batch_root = null


		if mouse_walk != null and not is_instance_valid(valhalla):
			mouse_walk.reset()
		return
	_toggle_hint_tick()
	var tp: = Time.get_ticks_usec()
	_run_sched(delta)
	_flush_xp()
	Vfx.batch_root = fx_root
	Vfx.update_flat(delta)
	_update_number_batch()


	if net.is_client() or net.migrating():
		_client_frame(delta)
		return




	delta = minf(delta, 0.05 * (GameData.GAME_FAST_SPEED if fast_now else 1.0))
	Vfx.dim = 1.0
	Vfx.hero = false

	var frozen: = raid.freezes_time() or morroc.freezes_time()
	clock += delta * pace
	if fast_now:
		run_fast_s += delta * pace
	if not frozen:
		time += delta * pace
	else:
		meter_stats["fight_s"] = float(meter_stats.get("fight_s", 0.0)) + delta * pace
	var t0: = Time.get_ticks_usec()
	_perf.pre += t0 - tp
	if not frozen:
		_run_director(delta * pace)
	elif morroc.freezes_time() and not raid.freezes_time() and not morroc.finale_won():


		_director_spawns(delta * pace)
	if _mob_bench > 0:
		_mob_bench_fill()

	traits.update(self, delta)
	var t1: = Time.get_ticks_usec()


	_rebuild_grid()
	var tg: = Time.get_ticks_usec()
	for h in heroes:
		var f: = flow_of(h)
		if f.map != map:
			f.map = map
			f.reset()
		f.update(delta, h.position)
	var tf: = Time.get_ticks_usec()


	Vfx.hero = true
	for h in heroes:
		if h.downed:
			continue
		Vfx.dim = own_fx_alpha if h == player else own_fx_alpha * fx_alpha_party
		_turn_hero = h
		damage_by = h
		h.tick(delta, self)
	_turn_hero = null
	damage_by = null
	Vfx.dim = 1.0
	Vfx.hero = false
	if heroes.size() > 1:
		player.set_choosing(menus._mode in CHOOSING_MODES and not player.downed)
		_update_party(delta)

	if heroes.size() > 1 or encore.on:
		encore.tick(self, delta)


	Vfx.hero = true
	Vfx.dim = own_fx_alpha
	_update_pet(delta)
	_tick_pet_skills(delta)
	for h in heroes:
		if h.homun_node != null and is_instance_valid(h.homun_node) and not h.downed:
			Vfx.dim = hero_fx_alpha(h)
			h.homun_node.tick(delta)
			for x in h.homun_extra_nodes:
				if is_instance_valid(x):
					x.tick(delta)

	for h in heroes:
		if not h.downed:
			Vfx.dim = hero_fx_alpha(h)
			HomunCombo.tick(self, h, delta)
	Vfx.dim = 1.0
	Vfx.hero = false
	var t2: = Time.get_ticks_usec()
	frame_parity = (frame_parity + 1) % REFRESH_EVERY


	var hx: = player.position.x
	var hz: = player.position.z
	var far2: = FAR_TICK_DIST * FAR_TICK_DIST
	var party: = heroes.size() > 1
	var lost2: = GameData.RECYCLE_DIST * GameData.RECYCLE_DIST
	morroc_fight = morroc.fighting()
	for e in enemies:
		e.frame(delta, self, hx, hz, far2, lost2, party)
	_grid_fresh = false
	damage_by = null
	var t25: = Time.get_ticks_usec()
	_update_poison(delta)
	_update_judgment()
	damage_by = null
	var tsh: = Time.get_ticks_usec()
	_update_shadows()
	var tsh2: = Time.get_ticks_usec()
	mob_renderer.update(delta, _shadows.custom_aabb)
	var t3: = Time.get_ticks_usec()
	_update_enemy_shots(delta)
	Vfx.dim = own_fx_alpha
	Vfx.hero = true
	_update_projectiles(delta)
	_flush_splash(delta)
	_flush_basic()
	_flush_shadows()
	_flush_lethal()
	_update_bolts(delta)
	_update_zones(delta)
	_update_traps(delta)
	dots.update(self, delta)
	_update_orbits(delta)
	summons.update(self, delta)
	doram.update(self, delta)
	damage_by = null
	Vfx.dim = 1.0
	Vfx.hero = false
	_update_barrier()
	var t4: = Time.get_ticks_usec()
	_update_pickups(delta)
	gem_renderer.update(pickups, _gem_looks, _shadows.custom_aabb)
	_update_props(delta)
	_tick_armorer()
	_training_picks(delta)

	if training and world_boss != null:
		raid.tick(delta)
	if not training:
		_autosave -= delta
		if _autosave <= 0.0:
			_autosave = RunSave.EVERY
			RunSave.save(self)
		raid.tick(delta)
		morroc.tick(delta)
		quest.tick(delta)
		altars.tick(delta, 0.0 if frozen else pace)
		karma.tick(delta, 0.0 if frozen else pace)
	_update_camera(delta)
	mouse_walk.update_markers()
	var t5: = Time.get_ticks_usec()
	if _smoke_seconds > 0.0:


		_perf.frame += now_us - _frame_last_us if _frame_last_us > 0 else 0
		_frame_last_us = now_us
		_perf.world += t5 - now_us
		_perf.director += t1 - t0
		_perf.player += t2 - t1
		_perf.enemies += t3 - t2
		_perf.mobdraw += t3 - t25
		_perf.projectiles += t4 - t3
		_perf.pickups += t5 - t4
		_perf.grid += tg - t1
		_perf.flow += tf - tg
		_perf.tick += t25 - t2
		_perf.shadows += tsh2 - tsh
		_perf.render += t3 - tsh2
		_perf.frames += 1
	_numbers = maxi(0, _numbers - 1)
	_number_clock += delta
	for key in _number_buckets.keys():
		if _number_buckets[key].until < _number_clock:
			_number_buckets.erase(key)
	if running and not busy() and player.can_job_change() and not player.downed and not loot_waits_for_me():
		menus.show_job_change()

	elif player.pending_levels > 0 and running and not busy() and not loot_waits_for_me():
		if _level_up_delay > 0.0:
			_level_up_delay = maxf(0.0, _level_up_delay - delta)
		elif (bool(Save.setting("endless_auto_pick", false)) or (training and _training_auto > 0)) and not menus.auto_pick:
			_auto_pick()
		elif bool(Save.setting("hold_levels", false)) and not menus.auto_pick:

			pass
		else:


			_absorb_flying_xp()
			menus.show_level_up(level_choices())
	if autopilot and player.quiver.size() > 1 and int(time * 2.0) % 6 == 0:
		_autopick_arrow()
	if autopilot:

		for k in player.equipment.refinable_now():
			refine(k)
	if not _shot_times.is_empty() and time >= _shot_times[0]:
		var st: float = _shot_times.pop_front()

		_capture("t%03d" % int(st) if st == floorf(st) else "t%03d_%02d" % [int(st), roundi(fmod(st, 1.0) * 100.0)])
	if GameData.has_meta("mvp_at") and time >= mvp_at() and raid.state == "idle" and not _mvp_forced:
		_mvp_forced = true
		raid.open_portal(stage.mvp)
	if _smoke_seconds > 0.0:
		if _quick_mvp:
			_quick_mvp_tick(delta)
		var minute: = int(time / 60.0)
		if minute > _smoke_minute:
			_smoke_minute = minute
			print("  %d:00 lv=%d kills=%d alive=%d hp=%d/%d" % [minute, player.level, kills, enemies.size(), player.hp, player.max_hp])
			for h in heroes.slice(1):
				print("    party %s lv=%d hp=%d/%d skills=%d%s" % [h.class_id, h.level, h.hp, h.max_hp, h.skills.size(), " DOWN" if h.downed else ""])
		if time >= _smoke_seconds:
			if _tower_sim and tower == null:
				_tower_sim_begin()
			else:
				_finish_smoke()




func _tower_sim_begin() -> void :
	var p: = player
	print("TOWERSIM build class=%s job=%s lv=%d hp=%d dmg=x%.2f skill=x%.2f aspd=%.0f crit=%.2f revives=%d run_t=%d kills=%d" % [
		p.class_id, p.job_name(), p.level, p.max_hp, p.dmg_mult, p.skill_mult, p.aspd(), p.crit, p.revives, time, kills])
	var sk: = []
	for id in p.skills:
		sk.append("%s%d" % [id, int(p.skills[id].level)])
	var gear: = []
	for k in p.equipment.slots:
		if p.equipment.slots[k] != null:
			gear.append(Equipment.item_name(p.equipment.slots[k]))
	print("TOWERSIM skills=%s" % [sk])
	print("TOWERSIM gear=%s cards=%s stats=%s" % [gear, p.cards, p.stats])
	GameData.remove_meta("mvp_at")
	GameData.remove_meta("morroc_at")
	var snap: = RunSave.hero_snapshot(self)
	Save.add_tower_build(snap)
	Save.unlock_tower()
	var god: = "--tower-god" in OS.get_cmdline_user_args()
	if not god:
		GameData.remove_meta("tour_god")
	var from: = 1
	var at: = Array(OS.get_cmdline_user_args()).find("--tower-from")
	if at >= 0:
		from = int(OS.get_cmdline_user_args()[at + 1])
	_smoke_seconds = 1000000000000.0
	abandon_run()
	start_tower(Save.tower_builds().size() - 1, from, "--tower-hel" in OS.get_cmdline_user_args())
	if tower != null and tower.hel != null:
		tower.floor = from
		if "--hel-all" in OS.get_cmdline_user_args():
			tower.hel.rules.assign(GameData.HEL_TOWER_RULES.keys())
	autopilot = true
	menus.auto_pick = true
	_sim_t0 = time
	print("TOWERSIM start floor=%d god=%s" % [from, god])


var _sim_t0: = 0.0


func _unhandled_input(event: InputEvent) -> void :


	if running and player != null and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB and event.shift_pressed and not held_chests.is_empty():
		open_held_chests()
		get_viewport().set_input_as_handled()
		return

	if running and player != null and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB and (player.pending_levels > 0 or not held_chests.is_empty()):
		open_held_levels()
		get_viewport().set_input_as_handled()
		return
	if running and player != null and not busy() and mouse_walk.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	if _turn_input(event):
		get_viewport().set_input_as_handled()
		return



	if running and player != null and not get_tree().paused and event is InputEventKey and event.pressed\
	and not event.echo and event.keycode == KEY_R and Uniques.cannon(player) != "":
		skill_switch("u_overload")
		get_viewport().set_input_as_handled()
		return


	if running and player != null and not get_tree().paused and event is InputEventKey and event.pressed\
	and not event.echo and event.keycode == KEY_F and player.f_skill() != "":
		skill_switch(player.f_skill(), true)
		get_viewport().set_input_as_handled()
		return
	if running and player != null and not get_tree().paused and event.is_action_pressed("pet_fetch"):
		toggle_pet_fetch()
		get_viewport().set_input_as_handled()
		return
	if running and player != null and not get_tree().paused:
		for action in ["arrow_next", "arrow_prev"]:
			if event.is_action_pressed(action):
				switch_arrow(1 if action == "arrow_next" else -1)
				get_viewport().set_input_as_handled()
				return


	if event is InputEventMouseButton and event.pressed and menus._mode in ["closed", "town"] and get_viewport().gui_get_hovered_control() == null:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(-1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(1.0)




const ZOOM_NEAR: = 9.0
const ZOOM_TILT: = 24.0
const ZOOM_FAR: = 70.0

const LOW_PITCH: = deg_to_rad(9.0)

const LOOK_RAISE: = 1.7

static var cam_pitch: = CAMERA_PITCH



func zoom_by(steps: float) -> void :
	var step: = 2.0 if _cam_distance < ZOOM_TILT or (_cam_distance <= ZOOM_TILT and steps < 0.0) else 3.0
	var previous: = _cam_distance
	_cam_distance = clampf(_cam_distance + steps * step, ZOOM_NEAR, TOWN_ZOOM_FAR if _zoom_capped() else ZOOM_FAR)
	if raid != null and raid.in_arena() and not is_equal_approx(previous, _cam_distance):
		_arena_zoom_changed = true





const TOWN_ZOOM_FAR: = 42.0


func _zoom_capped() -> bool:
	return town != null or (raid != null and raid.in_arena())





var _sky: MeshInstance3D
const SKY_SHADER: = "\r\nshader_type spatial;\r\nrender_mode unshaded, cull_front, depth_draw_never, fog_disabled, shadows_disabled;\r\nuniform vec3 ground : source_color = vec3(0.16, 0.2, 0.11);\r\nuniform vec3 haze : source_color = vec3(0.8, 0.85, 0.9);\r\nuniform vec3 zenith : source_color = vec3(0.47, 0.64, 0.88);\r\nuniform vec3 tint = vec3(1.0);\r\nvarying vec3 dir;\r\nvoid vertex() {\r\n\tdir = VERTEX;\r\n}\r\nvoid fragment() {\r\n\tfloat h = normalize(dir).y;\r\n\tvec3 c = mix(haze, zenith, smoothstep(0.0, 0.35, h));\r\n\tc = mix(ground, c, smoothstep(-0.03, 0.0, h));\r\n\tALBEDO = c * tint;\r\n}\r\n"



















func _make_sky() -> MeshInstance3D:
	var m: = MeshInstance3D.new()
	var sphere: = SphereMesh.new()
	sphere.radius = 500.0
	sphere.height = 1000.0
	sphere.radial_segments = 24
	sphere.rings = 12
	m.mesh = sphere
	var sh: = Shader.new()
	sh.code = SKY_SHADER
	var mat: = ShaderMaterial.new()
	mat.shader = sh
	mat.render_priority = -128
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	m.visible = false
	return m


func _update_sky() -> void :
	if _sky == null:
		return
	_sky.visible = cam_pitch < CAMERA_PITCH - 0.05
	if not _sky.visible:
		return
	_sky.global_position = camera.global_position

	var env: = camera.get_world_3d().environment if camera.get_world_3d() != null else null
	if env != null:
		var a: = env.ambient_light_color * env.ambient_light_energy
		var k: = clampf((a.r + a.g + a.b) / (3.0 * 0.58 * maxf(0.01, Vfx.light_k())), 0.25, 1.3)
		(_sky.material_override as ShaderMaterial).set_shader_parameter("tint", Vector3(k, k, k))


static func pitch_at(dist: float) -> float:
	return lerpf(LOW_PITCH, CAMERA_PITCH, smoothstep(ZOOM_NEAR, ZOOM_TILT, dist))


static func raise_at(dist: float) -> float:
	return LOOK_RAISE * (1.0 - smoothstep(ZOOM_NEAR, ZOOM_TILT, dist))



var _field_zoom: = -1.0


var _arena_zoom_changed: = false


func _update_camera(delta: float) -> void :
	_update_camera_on(player.position, delta)


func _update_camera_on(focus: Vector3, delta: float) -> void :



	if _cam_distance > TOWN_ZOOM_FAR and _zoom_capped():
		if town == null:
			_field_zoom = _cam_distance
			_arena_zoom_changed = false
		_cam_distance = TOWN_ZOOM_FAR
	elif _field_zoom > 0.0 and not _zoom_capped():
		if town == null and not _arena_zoom_changed and _cam_distance >= TOWN_ZOOM_FAR:
			_cam_distance = _field_zoom
		_field_zoom = -1.0
		_arena_zoom_changed = false
	elif not _zoom_capped():
		_arena_zoom_changed = false

	if RoVisual.view_yaw != 0.0 and not _turning and not camera_turns() and (_turn_tween == null or not _turn_tween.is_running()):
		set_view_yaw(0.0)


	var off: = cam_offset()
	var looked: = camera.position - _cam_off
	_cam_off = off
	camera.position = looked.lerp(focus, 1.0 - exp( - delta * 8.0)) + off
	if _shake > 0.0:
		_shake -= delta
		camera.position += camera.global_basis * Vector3(randf_range(-1, 1), randf_range(-1, 1), 0) * _shake * 1.5
	camera.look_at(camera.position - off + Vector3.UP * raise_at(_cam_distance))
	_update_sky()
	var lift: = Vector3(0, sin(cam_pitch), cos(cam_pitch)) * sprite_lift(cam_pitch)
	if not lift.is_equal_approx(RoVisual.lift):
		RoVisual.lift = lift




func cam_offset(dist: = -1.0) -> Vector3:
	var d: = _cam_distance if dist < 0.0 else dist
	var p: = pitch_at(d)
	if dist < 0.0:
		cam_pitch = p
	return Vector3(0, sin(p), cos(p)).rotated(Vector3.UP, RoVisual.view_yaw) * d + Vector3.UP * raise_at(d)



func place_camera(focus: Vector3, dist: = -1.0) -> void :
	_cam_off = cam_offset(dist)
	camera.position = focus + _cam_off
	camera.look_at(focus + Vector3.UP * raise_at(_cam_distance if dist < 0.0 else dist))



static func view_up() -> Vector3:
	return Vector3(0, cos(cam_pitch), - sin(cam_pitch)).rotated(Vector3.UP, RoVisual.view_yaw)





func camera_turns() -> bool:

	return bool(Save.setting("camera_turn", true))


func set_view_yaw(yaw: float) -> void :
	RoVisual.view_yaw = wrapf(yaw, - PI, PI)
	for n in get_tree().get_nodes_in_group(RoVisual.VIEW_GROUP):
		(n as Node3D).rotation.y = RoVisual.view_yaw




func _turn_input(event: InputEvent) -> bool:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		return false
	if MouseWalk.touch() or not camera_turns() or not (running or town != null or is_instance_valid(valhalla)) or get_tree().paused\
	or not menus._mode in ["closed", "town"] or get_viewport().gui_get_hovered_control() != null:
		return false
	if event.double_click:
		_end_turn()
		_turn_back()
		return true
	if _turn_tween != null:
		_turn_tween.kill()
	_turning = true
	return true


func _input(event: InputEvent) -> void :
	if not _turning:
		return


	if event is InputEventMouseMotion and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		_end_turn()
		return
	if event is InputEventMouseMotion:

		set_view_yaw(RoVisual.view_yaw - event.relative.x * TURN_SPEED)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
		_end_turn()
		get_viewport().set_input_as_handled()


func _end_turn() -> void :
	_turning = false



func _turn_back() -> void :
	if _turn_tween != null:
		_turn_tween.kill()
	_turn_tween = create_tween()
	_turn_tween.tween_method(set_view_yaw, RoVisual.view_yaw, 0.0, 0.25).set_trans(Tween.TRANS_SINE)




func _build_shadows() -> void :
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE
	quad.orientation = PlaneMesh.FACE_Y
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_texture = RoAssets.radial(Color(0, 0, 0, 0.45))
	mat.render_priority = -1
	quad.material = mat
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = quad
	mm.instance_count = maxi(GameData.MAX_ENEMIES, GameData.MAX_ENEMIES_COOP) + 64
	mm.visible_instance_count = 0
	_shadows = MultiMeshInstance3D.new()
	_shadows.multimesh = mm
	_shadows.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_shadows)


func _update_shadows() -> void :
	var mm: = _shadows.multimesh


	_shadows.custom_aabb = AABB(Vector3( - map.width, -50, - map.height), Vector3(map.width * 2, 100, map.height * 2))


	if not bool(Save.setting("mob_shadows", true)):
		mm.visible_instance_count = 0
		return
	var n: = mini(enemies.size(), mm.instance_count)


	if _shadow_buf.size() != mm.instance_count * 12:
		_shadow_buf.resize(mm.instance_count * 12)
		_shadow_buf.fill(0.0)
		for i in mm.instance_count:
			_shadow_buf[i * 12 + 5] = 1.0
	var buf: = _shadow_buf


	for i in n:
		var e: = enemies[i]
		var s: = e.radius * 2.4
		var p: = e.position
		var o: = i * 12
		buf[o] = s
		buf[o + 3] = p.x
		buf[o + 7] = p.y + 0.03
		buf[o + 10] = s
		buf[o + 11] = p.z
	_shadow_buf = buf
	if n > 0:
		mm.buffer = buf
	mm.visible_instance_count = n



func shake(amount: float, always: = false) -> void :
	if not always and not bool(Save.setting("screen_shake", false)):
		return
	_shake = maxf(_shake, amount)






func opening() -> float:
	if endless or tower != null or not gentle_map():
		return 0.0
	return clampf(1.0 - time / GameData.OPENING_TIME, 0.0, 1.0)



func gentle_map() -> bool:
	return int(GameData.STAGES.get(stage_id, {}).get("tier", 0)) == 1 and danger <= GameData.OPENING_DANGER






func scale_time(boss: = false) -> float:
	return tower.scale_time(boss) if tower != null else time



func _spawn_rate_now() -> float:
	var rate: = GameData.spawn_rate(time) * GameData.danger_rate(danger, GameData.hell_ramp(time)) * (1.0 + altars.mod("spawn")) * (1.0 + player.curse)
	rate *= lerpf(1.0, GameData.OPENING_RATE, opening())
	if boss != null and boss.def.get("mvp", false):
		rate *= 0.4

	if _hell_tide_t > 0.0:
		rate *= GameData.HELL_TIDE_RATE
	rate *= GameData.coop_spawn(heroes.size())
	if endless:
		rate *= 1.0 + GameData.ENDLESS_RATE_STEP * _endless_count
	return rate



func _director_spawns(delta: float, rate: = -1.0) -> void :
	if GameData.has_meta("no_spawn") or hell_late.calm():
		return
	if rate < 0.0:
		rate = _spawn_rate_now()
	var spawns: Array = stage.spawns
	for i in spawns.size():
		var s: Dictionary = spawns[i]
		if time < s.from or time > s.to:
			continue
		_spawn_timers[i] = _spawn_timers.get(i, 0.5) - delta * rate
		if _spawn_timers[i] <= 0.0:
			_spawn_timers[i] += s.every


			var kin: int = MobTraits.OF.get(s.mob, 0)
			for n in s.batch:
				if kin == MobTraits.SWARM:
					traits.pack(str(s.mob), self)
					continue
				var e: = spawn_enemy(s.mob, _offscreen_point())
				if e != null and kin == MobTraits.WARBAND and traits.leader_due(self, str(s.mob)):
					traits.crown(e, self)


func _run_director(delta: float) -> void :

	if GameData.has_meta("no_spawn") or training or tower != null:
		return
	var rate: = _spawn_rate_now()
	var events: Array = stage.events
	_director_spawns(delta, rate)
	if time >= float(GameData.FEROCIOUS.from):
		_feroz_timer -= delta
		if _feroz_timer <= 0.0:
			var every: Array = GameData.ENDLESS_FEROZ_EVERY if endless else (GameData.FEROCIOUS.every_hard if hard else GameData.FEROCIOUS.every)
			_feroz_timer = randf_range(float(every[0]), float(every[1])) / (1.0 + altars.mod("elite")) / karma.elite_mult()


			if oath("elite") >= 3:
				_feroz_timer *= 0.5
			_feroz_timer /= GameData.oath_value("hunt", oath("hunt"))
			_spawn_ferocious()
	if not oaths.is_empty():
		oath_run.tick(self, delta)
	if endless and morroc.finale_due():
		pass
	elif endless and _event_index >= events.size() and _endless_rush >= 0.0 and time >= _endless_rush:
		_endless_mvp_now()
	elif endless and _event_index >= events.size() and time >= _endless_next:
		_endless_event()
	_tick_runner(delta)
	if danger >= GameData.STORM_FROM and not raid.in_arena():
		_storm -= delta
		if _storm <= 0.0:
			_storm = GameData.STORM_EVERY * randf_range(0.85, 1.15)
			_storm_strike()
	if GameData.hell_level(danger) >= 5 and not raid.in_arena():
		_hell_rain -= delta
		if _hell_rain <= 0.0:
			_hell_rain = GameData.HELL_RAIN_EVERY * hell_pace()
			_hell_rain_fall()
	_tick_hell_late(delta)
	hell_late.tick(delta)
	if endless or GameData.hell_level(danger) >= 1:


		_endless_mix -= delta * rate * (1.0 if endless else GameData.hell_ramp(time))
		if _endless_mix <= 0.0:
			_endless_mix = GameData.ENDLESS_MIX_EVERY
			var mobs: = _mix_pool()
			if not mobs.is_empty():
				var mob: String = mobs.pick_random()
				for n in randi_range(2, 4):
					spawn_enemy(mob, _offscreen_point())


	if not _mvp_ran_early and altars.mod("mvp_early") > 0.0:
		for i in range(_event_index, events.size()):
			var mev: Dictionary = events[i]
			if mev.type == "boss" and mev.mob == stage.mvp and time >= _event_at(mev):
				_mvp_ran_early = true
				_run_event(mev)
				break
	while _event_index < events.size() and time >= _event_at(events[_event_index]):
		var ev: Dictionary = events[_event_index]
		_event_index += 1
		if _mvp_ran_early and ev.type == "boss" and ev.mob == stage.mvp:
			continue
		_run_event(ev)



func _event_at(ev: Dictionary) -> float:
	if ev.type == "boss" and ev.mob == stage.mvp:
		if GameData.has_meta("mvp_at"):
			return INF
		return float(ev.at) - altars.mod("mvp_early")
	return float(ev.at)



func mvp_at() -> float:
	if GameData.has_meta("mvp_at"):
		return float(GameData.get_meta("mvp_at"))
	return float(stage.mvp_time) - altars.mod("mvp_early")




var endless_mvp_client: = -1.0
func endless_mvp_at() -> float:
	if net.is_client():
		return endless_mvp_client
	if not endless or _event_index < stage.events.size() or morroc.finale_due():
		return -1.0
	if _endless_rush >= 0.0:
		return _endless_rush
	var every: = GameData.ENDLESS_MVP_EVERY
	var steps: = (every - (_endless_count + 1) % every) % every
	return _endless_next + steps * GameData.ENDLESS_EVERY





func rush_endless_mvp(secs: float) -> void :
	if net.is_client():
		return
	var at: = endless_mvp_at()
	if at < 0.0:
		return



	var rush: = maxf(time + 5.0, at - secs)
	if rush >= at:
		return
	_endless_rush = rush




func _endless_mvp_now() -> void :
	_endless_rush = -1.0
	var every: = GameData.ENDLESS_MVP_EVERY
	_endless_count += every - _endless_count % every
	_endless_next = time + GameData.ENDLESS_EVERY
	_run_event({"type": "boss", "mob": stage.mvp})




func _endless_event() -> void :
	_endless_next = time + GameData.ENDLESS_EVERY
	_endless_count += 1
	if _endless_count % GameData.ENDLESS_MVP_EVERY == 0:

		_endless_rush = -1.0
		_run_event({"type": "boss", "mob": stage.mvp})
		return



	var ev: Dictionary = _endless_upcoming if not _endless_upcoming.is_empty() else _endless_pick()
	_endless_upcoming = _endless_pick()
	_warm_mob(str(_endless_upcoming.get("mob", "")))
	if not ev.is_empty():
		_run_event(ev)


var _endless_upcoming: = {}


func _endless_pick() -> Dictionary:
	var pool: Array = []
	for sid in GameData.STAGES:
		var st: Dictionary = GameData.STAGES[sid]
		for ev in st.events:
			if ev.mob != st.get("mvp", "") and not GameData.MONSTERS[ev.mob].get("mvp", false):
				pool.append(ev)
	if pool.is_empty():
		pool = stage.events.filter( func(ev): return ev.mob != stage.mvp)
	return pool.pick_random() if not pool.is_empty() else {}




func _warm_mob(id: String) -> void :
	var d: Dictionary = GameData.MONSTERS.get(id, {})
	if d.is_empty():
		return
	RoAssets.preload_async([id])
	if not d.has("boss"):
		mob_renderer.prepare_async(id)
	var summon = d.get("summon", [])
	for sm in (summon if summon is Array else [summon]):
		var sd: Dictionary = GameData.MONSTERS.get(str(sm), {})
		if not sd.is_empty() and not sd.has("boss"):
			mob_renderer.prepare_async(str(sm))


var _stage_mobs: Array = []



func _is_stage_mob(id: String) -> bool:
	if _stage_card_mobs.is_empty():
		for sp in stage.spawns:
			_stage_card_mobs[sp.mob] = true
		for ev in stage.events:
			_stage_card_mobs[ev.mob] = true
		_stage_card_mobs[str(stage.get("mvp", ""))] = true
	return _stage_card_mobs.has(id)




static var _wild_mobs: = {}
func _wild_mob(id: String) -> bool:
	if _wild_mobs.is_empty():
		for sid in GameData.STAGES:
			var st: Dictionary = GameData.STAGES[sid]
			for sp in st.get("spawns", []):
				_wild_mobs[str(sp.mob)] = true
			for ev in st.get("events", []):
				_wild_mobs[str(ev.get("mob", ""))] = true
			_wild_mobs[str(st.get("mvp", ""))] = true
	return _wild_mobs.has(id)




func _is_route_mvp(e: Enemy) -> bool:
	if e.has_meta("route_mvp"):
		return true
	return karma.route != "" and not e.summoned and e.id == str(GameData.KARMA_ROUTES[karma.route].mvp)





var _stage_card_pool: = {}
func _stage_cards(boss: bool) -> Array:
	_is_stage_mob("")
	var want: = "boss" if boss else "mob"
	if not _stage_card_pool.has(want):
		var bosses: Array = []
		var mobs: Array = []
		for id in _stage_card_mobs:
			var d: Dictionary = GameData.MONSTERS.get(id, {})
			var c: = str(d.get("card", ""))
			if c == "" or not GameData.CARDS.has(c) or d.get("mvp", false):
				continue
			if d.has("boss"):
				if not bosses.has(c):
					bosses.append(c)
			elif not mobs.has(c):
				mobs.append(c)
		_stage_card_pool["boss"] = bosses if not bosses.is_empty() else mobs
		_stage_card_pool["mob"] = mobs
	return _stage_card_pool[want]





func _run_mobs() -> Array:
	var out: = []
	for list in [stage.get("spawns", []), stage.get("events", [])]:
		for sp in list:
			var id: = str(sp.get("mob", ""))
			var d: Dictionary = GameData.MONSTERS.get(id, {})
			if not d.is_empty() and not d.has("boss") and not out.has(id):
				out.append(id)

			var summon = d.get("summon", [])
			for sm in (summon if summon is Array else [summon]):
				var sd: Dictionary = GameData.MONSTERS.get(str(sm), {})
				if not sd.is_empty() and not sd.has("boss") and not out.has(str(sm)):
					out.append(str(sm))

	for id in GameData.KARMA_DEMONS:
		if GameData.MONSTERS.has(id) and not out.has(id):
			out.append(id)

	if endless or GameData.hell_level(danger) >= 1:
		for id in _mix_pool():
			if not out.has(id):
				out.append(id)
	return out





const MIX_KINDS: = 14
var _mix: Array = []


func _mix_pool() -> Array:
	if _mix.is_empty():
		var all: = _all_stage_mobs().duplicate()
		all.shuffle()
		_mix = all.slice(0, MIX_KINDS)
		mob_renderer.keep_more(_mix)
	return _mix


func _all_stage_mobs() -> Array:
	if _stage_mobs.is_empty():
		for sid in GameData.STAGES:
			for sp in GameData.STAGES[sid].spawns:
				var d: Dictionary = GameData.MONSTERS.get(sp.mob, {})
				if not d.is_empty() and not d.get("static", false) and not d.has("boss") and not _stage_mobs.has(sp.mob):
					_stage_mobs.append(sp.mob)
	return _stage_mobs


func _run_event(ev: Dictionary) -> void :
	match ev.type:
		"ring":
			for n in ev.count:
				var a: float = TAU * float(n) / float(ev.count)
				spawn_enemy(ev.mob, player.position + Vector3(cos(a), 0, sin(a)) * 15.0, true)
		"elite":
			var el: = spawn_enemy(ev.mob, _offscreen_point(), true)
			if hard:
				for n in int(GameData.HARD.elite_extra):
					spawn_enemy(ev.mob, _offscreen_point(), true)
			if el != null:
				party_announce(tr("¡%s apareció!") % tr(el.def.name), Color(1, 1, 0.3), tr("Derrótalo para conseguir un Treasure Box"))
				if boss == null:
					boss = el
		"boss":
			if ev.mob == stage.mvp and raid.supports(ev.mob) and not raid.active():

				raid.open_portal(ev.mob)
				return
			var e: = spawn_enemy(ev.mob, _offscreen_point(), true)
			if e != null:
				boss = e
				var title: String = (tr("MVP: %s") if e.def.get("mvp", false) else tr("Jefe: %s")) % tr(str(e.def.name))
				party_announce(title, Color(1, 0.55, 0.75) if e.def.get("mvp", false) else Color(1, 1, 0.3))
				emote(player, "omg")




func banish_enemy(e: Enemy) -> void :
	if not is_instance_valid(e):
		return
	enemies.erase(e)
	_grid_fresh = false
	poisoned.erase(e)
	e.dead = true
	if e == boss:
		boss = null
	Vfx.column(fx_root, e.position, Color(0.85, 0.85, 1.0))
	play_sound("teleport", 0.15, -10.0)
	e.queue_free()



func clear_battlefield() -> void :
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	enemies.clear()
	_grid_fresh = false
	mob_grid.clear()
	traits.cleared()
	poisoned.clear()
	judged.clear()
	dots.clear()
	boss = null
	for pr in projectiles:
		if is_instance_valid(pr.node):
			pr.node.queue_free()
	projectiles.clear()
	_bouncing.clear()
	for sh in enemy_shots:
		if sh.has("node") and is_instance_valid(sh.node):
			sh.node.queue_free()
	enemy_shots.clear()
	for b in _bolts:
		if b.has("node") and is_instance_valid(b.node):
			b.node.queue_free()
	_bolts.clear()



func snap_camera() -> void :
	place_camera(player.position)




func _offscreen_point() -> Vector3:
	var at: = player.position
	if heroes.size() > 1:
		var up: = alive_heroes()
		if not up.is_empty():
			at = up.pick_random().position
	var p: = map.find_point_around(at, 15.0, 22.0)
	if p == Vector3.INF:
		p = map.find_point_around(at, 10.0, 26.0)
	return p




func _spawn_ferocious() -> void :
	var cap: = int(GameData.FEROCIOUS.max_hard if hard else GameData.FEROCIOUS.max)
	if endless:
		cap = GameData.ENDLESS_FEROZ_MAX + _endless_count / 4

	cap = roundi(cap * GameData.oath_value("hunt", oath("hunt")))
	if enemies.filter( func(e): return e.feroz and not e.dead).size() >= cap:
		return
	var pool: Array[String] = []
	for s in stage.spawns:
		var d: Dictionary = GameData.MONSTERS[s.mob]
		if time >= float(s.from) and time <= float(s.to) and not d.has("boss") and not d.get("elite", false) and not d.has("prop"):
			pool.append(str(s.mob))
	if endless:

		pool.append_array(_mix_pool())
	if pool.is_empty():
		return
	spawn_enemy(pool.pick_random(), _offscreen_point(), true, true, _special_kind())



static func _special_kind() -> String:
	var total: = 0.0
	for k in GameData.SPECIAL_KINDS:
		total += float(GameData.SPECIAL_KINDS[k].w)
	var r: = randf() * total
	for k in GameData.SPECIAL_KINDS:
		r -= float(GameData.SPECIAL_KINDS[k].w)
		if r <= 0.0:
			return k
	return "feroz"


func spawn_enemy(id: String, pos: Vector3, force: = false, ferocious: = false, kind: = "") -> Enemy:
	if pos == Vector3.INF:
		return null
	var is_boss: bool = GameData.MONSTERS[id].has("boss")
	var cap: = maxi(GameData.MAX_ENEMIES, GameData.MAX_ENEMIES_COOP if not OS.has_feature("web") else 0) if heroes.size() > 1 else GameData.MAX_ENEMIES

	if tower != null:
		cap = mini(cap, GameData.CROWD_CAP_TOWER_COOP if heroes.size() > 1 else GameData.CROWD_CAP_TOWER)



	var plain: bool = not ferocious and kind == "" and not GameData.MONSTERS[id].get("elite", false)
	if not is_boss and enemies.size() >= (cap if not force or plain else cap + 40):
		if plain:
			_crowd_debt = mini(_crowd_debt + 1, GameData.CROWD_FUSE_MAX)
		return null

	var fuse: = 1
	if not force and not is_boss and not ferocious and kind == "" and not GameData.MONSTERS[id].get("elite", false)\
	and tower == null and enemies.size() >= roundi(cap * GameData.CROWD_FUSE_AT):

		var soft: = roundi(cap * GameData.CROWD_FUSE_AT)
		var need: = GameData.CROWD_FUSE + GameData.CROWD_FUSE_STEP * int((enemies.size() - soft) / maxf(1.0, cap * 0.1))
		_crowd_debt += 1
		if _crowd_debt < need:
			return null
		fuse = mini(_crowd_debt, GameData.CROWD_FUSE_MAX)
		_crowd_debt = 0

	elif tower != null and plain and not force and _crowd_debt > 0:
		fuse = mini(_crowd_debt + 1, GameData.CROWD_FUSE_MAX)
		_crowd_debt = 0
	if not map.is_walkable(pos):
		pos = map.random_point_around(pos, 1.5)
		if not map.is_walkable(pos):
			return null
	var e: = Enemy.new()
	run_root.add_child(e)
	var def: Dictionary = GameData.MONSTERS[id]
	var tough: bool = def.has("boss") or def.get("elite", false)
	var grow_t: = scale_time(def.has("boss"))
	var hp_scale: = GameData.scale_boss_hp(grow_t) if tough else GameData.scale_hp(grow_t)


	var norm: = GameData.mob_norm(id)
	var ramp: = GameData.hell_ramp(grow_t)

	var crowd: bool = not def.has("boss")

	e.setup(id, hp_scale * norm.x * GameData.danger_hp(danger, ramp, crowd, tower == null), mob_renderer, hp_scale, ferocious or kind != "")
	var own_speed: = e.speed
	e.damage *= norm.y * GameData.danger_dmg(danger, ramp, crowd)

	if crowd and not tough:
		e.damage *= lerpf(1.0, GameData.OPENING_DMG, opening())

	if def.get("mvp", false):
		e.max_hp *= GameData.mvp_danger_hp(danger)
		e.hp = e.max_hp
	e.speed *= GameData.danger_speed(danger, ramp, crowd)
	e.xp = maxi(1, roundi(e.xp * norm.z * GameData.danger_xp(danger)))
	if endless:




		var mvp: bool = def.get("mvp", false)
		e.speed *= 1.0 + (GameData.ENDLESS_SPEED_STEP if mvp else GameData.ENDLESS_MOB_SPEED_STEP) * _endless_count
		var grow: = pow(GameData.ENDLESS_HP_GROWTH if mvp else GameData.ENDLESS_MOB_HP_GROWTH, _endless_count)
		e.max_hp *= grow
		e.hp = e.max_hp
		e.damage *= pow(GameData.ENDLESS_DMG_GROWTH if mvp else GameData.ENDLESS_MOB_DMG_GROWTH, _endless_count)


		if def.get("mvp", false):
			e.max_hp *= pow(GameData.ENDLESS_MVP_GROWTH, run_ymir)
			if _endless_count >= GameData.ENDLESS_MVP_EVERY * 2:
				e.max_hp *= GameData.ENDLESS_MVP_LATER_HP
			e.hp = e.max_hp
	if tower != null:
		tower.scale_enemy(e)
	if player != null and player.curse > 0.0:
		e.max_hp *= 1.0 + player.curse

	if heroes.size() > 1:
		e.max_hp *= GameData.coop_hp(heroes.size(), "mvp" if def.get("mvp", false) else ("tough" if tough else "crowd"))
		e.hp = e.max_hp
		e.hp = e.max_hp

	if karma != null and karma.route != "":
		var kr: Dictionary = GameData.KARMA_ROUTES[karma.route]
		e.max_hp *= float(kr.foe_hp)
		e.hp = e.max_hp
		e.damage *= float(kr.foe_dmg)
		e.speed *= float(kr.foe_speed)
		if kr.get("foe_steady", false):
			e.set_meta("steady", true)



	if karma != null and tower == null and not festival_mode and (karma.hel_marks > 0 or karma.feathers > 0):
		e.max_hp *= pow(GameData.FEATHER_FOE_HP, karma.feathers)
		e.hp = e.max_hp
		e.damage *= pow(GameData.HEL_MARK_FOE_DMG, karma.hel_marks)
	if altars != null and not altars.mods.is_empty():
		e.max_hp *= 1.0 + altars.mod("enemy_hp")
		e.hp = e.max_hp
		e.damage *= 1.0 + altars.mod("enemy_dmg")
		e.speed *= 1.0 + altars.mod("enemy_speed")


	if ferocious or GameData.SPECIAL_KINDS.has(kind):
		e.make_special(kind if kind != "" else "feroz")
	if fuse > 1:

		e.set_meta("fused", fuse)
		e.max_hp *= fuse
		e.hp = e.max_hp
		e.damage *= 1.0 + GameData.CROWD_FUSE_DMG * (fuse - 1)
		e.xp *= fuse



	if def.get("mvp", false):
		e.mvp_pace = own_speed

	if e.feroz:
		e.speed = minf(e.speed, GameData.SPECIAL_SPEED_MAX)
	e.position = Vector3(pos.x, map.height_at(pos), pos.z)
	enemies.append(e)
	_grid_fresh = false
	if e.kin != 0:
		e._float_y = e.position.y

	if not oaths.is_empty():
		oath_run.on_spawn(self, e)
	return e




static func _mat_count(n: int, k: float) -> int:
	var f: = n * k
	return int(f) + (1 if randf() < f - int(f) else 0)



var _crowd_debt: = 0




func _rebuild_grid() -> void :
	if _grid_fresh:
		return
	_grid_fresh = true
	mob_grid.rebuild(enemies)


func enemies_in_radius(center: Vector3, radius: float) -> Array[Enemy]:
	return mob_grid.in_radius(center, radius)


func nearest_enemies(center: Vector3, max_range: float, count: int) -> Array[Enemy]:
	return mob_grid.nearest(center, max_range, count)



func any_enemy_near(center: Vector3, radius: float) -> bool:
	return mob_grid.any_near(center, radius)


func nearest_enemy(center: Vector3, max_range: float) -> Enemy:
	var list: = nearest_enemies(center, max_range, 1)
	return null if list.is_empty() else list[0]








func _calc_row(tag: String, source: String, element: String) -> String:
	if source != "poison":
		return tag
	var dot: = "bleed" if dot_can_crit else ("poison" if element == "poison" else ("burn" if element == "fire" else ""))
	if dot == "":
		return tag
	return dot if tag in ["", "basic", "poison", "burn", "bleed"] else "%s:%s" % [dot, tag.trim_prefix("proc:").get_slice("@", 0)]

func damage_enemy(e: Enemy, base: float, push: = Vector3.ZERO, source: = "skill", element: = "neutral", tag: = "") -> void :
	if e.dead:
		return

	var base_in: = base

	if morroc != null and morroc.fighting() and morroc.walled(e):
		return
	var src: = acting_hero()
	if tag == "":
		tag = damage_tag


	if src != null and element == "neutral" and src.temper_el != "" and (source == "basic" or source == "skill") and not tag.begins_with("proc:") and src.tempered() != "":
		element = src.temper_el




	if src != null and element == "neutral" and (source == "basic" or source == "skill") and not tag.begins_with("proc:")\
	and src.poison_weapon() and GameData.element_mult("poison", e.element()) > GameData.element_mult("neutral", e.element()):
		element = "poison"

	if src != null and src.whip_left > 0 and tag != "lg_dance_step" and (source == "basic" or source == "skill") and e.prop == "":
		Encore.whip_step(self, src, e, base_in)
	if damage_by == null and heroes.size() > 1:
		unowned[tag] = int(unowned.get(tag, 0)) + 1
	if e.prop != "":
		push = Vector3.ZERO

	if source != "poison" and src != null and e.element() in ["undead", "shadow"]:
		base *= 1.0 + float(src.effects.get("vs_undead", 0.0))



	var again: = 1.0

	if src != null and (e.is_boss or e.def.get("elite", false)):
		base *= 1.0 + float(src.effects.get("vs_boss", 0.0))
		again *= 1.0 + float(src.effects.get("vs_boss", 0.0))

		if src.doom:
			base *= 1.0 + GameData.DOOM_BOSS_DMG
			again *= 1.0 + GameData.DOOM_BOSS_DMG


	if src != null and src.vs_mvp > 0.0 and (e.def.get("mvp", false) or e.has_meta("festival")):
		base *= 1.0 + src.vs_mvp
		again *= 1.0 + src.vs_mvp


	if source == "basic" and src != null and src.powers.has("martyr") and tag == "basic":
		var martyr: float = src.scaling_hp() * src.martyr_pct
		if martyr > base:
			base = martyr

			play_sound("holy_cross", 0.18, -9.0, randf_range(0.92, 1.08))


			again = 1.0

	if src != null and tag == "throw_shuriken_x":
		base *= src.hunt_mult(e)
		if src._hunt_streak % 10 == 0:
			label_over(e, tr("Racha x%d") % src._hunt_streak, Color(1.0, 0.85, 0.3))
			Vfx.ring(fx_root, e.position, 2.0, Color(1.0, 0.85, 0.3), 0.3)
			if src._hunt_streak >= GameData.HUNT_MAX:
				Vfx.ray_flash(fx_root, e.position + Vector3(0, 1.0, 0), camera.global_basis, Color(1.0, 0.85, 0.4), 1.2)





	if src != null and src.kick_streak > 0 and source != "poison" and (src.class_id == "taekwon" or str(GameData.SKILLS.get(tag, {}).get("type", "")) in ["kick", "flying_kick"]):
		base *= src.kick_mult(time, e.is_boss)

	if e.is_boss and e.status == "stun":
		base *= 1.0 + stagger.BROKEN_DMG + (float(src.effects.get("wing_broken", 0.0)) if src != null else 0.0)


		if source == "skill" and GameData.PUNISH_SKILLS.has(tag):
			base *= 1.0 + GameData.PUNISH_DMG
			again *= 1.0 + GameData.PUNISH_DMG
			if clock >= float(e.get_meta("punish_shown", -1.0)):
				e.set_meta("punish_shown", clock + 1.0)
				label_over(e, tr("¡Castigo!"), GameData.PUNISH_COLOR)

	if src != null and src.has_uniq and source != "poison":
		base *= Uniques.damage_mult(src, element)

		base *= Uniques.tiger_mult(src)

	if src != null and not src.pacts.is_empty():
		base *= src.vengeance_mult()
		again *= src.vengeance_mult()
		if src.pacts.has("agony"):
			var ills: = (1 if e.poison_stacks > 0 and e.poison_time > 0.0 else 0) + (1 if e.burn_time > 0.0 else 0) + (1 if e.blood_time > 0.0 else 0)
			base *= 1.0 + float(GameData.PACTS.agony.per_ill) * ills
			again *= 1.0 + float(GameData.PACTS.agony.per_ill) * ills


	if e.poison_stacks > 0 and e.poison_time > 0.0:
		var corrode: = GameData.poison_corrode(e.poison_stacks, e.poison_by if hero_valid(e.poison_by) else null)
		base *= corrode
		again *= corrode

	if src != null and source != "poison":
		base *= Legends.damage_mult(self, src, e, tag)

		base *= JobEngines.mult(self, src, e, tag, source)


	if e.trapped_until > clock:
		base *= 1.0 + maxf(e.trap_vuln, float(src.effects.get("trap_vuln", 0.0)))
		again *= 1.0 + maxf(e.trap_vuln, float(src.effects.get("trap_vuln", 0.0)))


	if src != null and source != "poison" and e.has_meta("hunter_mark") and float(e.get_meta("hunter_mark")) > clock and str(src.def.get("ammo", "")) == "arrows" and _arrow_tag(tag):
		base *= 1.0 + GameData.HUNTER_MARK_DMG
		again *= 1.0 + GameData.HUNTER_MARK_DMG


	if e.acid_until > clock:
		base *= 1.0 + e.acid_frail
		again *= 1.0 + e.acid_frail

	if e.fear_until > time and source == "skill":
		base *= 1.0 + e.fear_vuln
		again *= 1.0 + e.fear_vuln
	if e.signum_until > time:
		base *= 1.0 + e.signum_frail * (GameData.SIGNUM_UNDEAD if e.element() in ["undead", "shadow"] else 1.0)
		again *= 1.0 + e.signum_frail * (GameData.SIGNUM_UNDEAD if e.element() in ["undead", "shadow"] else 1.0)

	if e.night_until > clock:
		var dark: = GameData.U_GLOOM_BOSS if e.is_boss else GameData.U_GLOOM_FRAIL
		base *= 1.0 + dark
		again *= 1.0 + dark

	var el_mult: = GameData.element_mult(element, e.element())


	if encore.on and encore.chaos_has(e):
		el_mult = maxf(el_mult, 1.0)

	if e.status != "" and float(src.effects.get("status_vuln", 0.0)) > 0.0:
		base *= 1.0 + float(src.effects.status_vuln)
		again *= 1.0 + float(src.effects.status_vuln)

	if e.status in ["freeze", "stone"]:
		el_mult = maxf(el_mult, GameData.STATUS_SHATTER)


	var boss_combo: bool = e.boss_mark != "" and e.boss_mark_until > time and GameData.STATUS_COMBO.get(e.boss_mark, "") == element
	if boss_combo:
		el_mult = maxf(el_mult, GameData.element_mult(element, GameData.STATUS_ELEMENT[e.boss_mark]))



	if float(src.effects.get("weak_bonus", 0.0)) > 0.0 and (GameData.element_mult(element, e.element()) > 1.01 or boss_combo):
		base *= 1.0 + float(src.effects.weak_bonus)



	var combo_share: = 0.0
	if source != "poison" and (boss_combo or GameData.STATUS_COMBO.get(e.status, "") == element):
		var own: = maxf(0.0, GameData.element_mult(element, e.own_element()))
		if el_mult > own + 0.01:
			combo_share = 1.0 - own / el_mult


	if element in GameData.WEB_ELEMENTS and e.web_until > time and el_mult > 0.0:
		el_mult *= GameData.WEB_FIRE

	if element == "holy" and e.judgment > 0 and clock - e.judgment_seen < GameData.JUDGMENT_FADE:
		base *= 1.0 + GameData.JUDGMENT_PER * e.judgment
	if el_mult <= 0.0:
		smoke_stats.miss += 1
		number(e.position + Vector3(0, e.visual.height() * 0.6, 0), "Miss", Color(0.75, 0.75, 0.8))
		return



	if src != null and source == "skill" and tag != "wiz_combo" and element in GameData.COMBO_ELEMENTS and src.combo_on()\
	and GameData.skill_of_tag(tag) != "" and (GameData.SKILLS[GameData.skill_of_tag(tag)].get("magic", false) or tag.begins_with("proc:")):
		_wiz_combo(src, e, element, base)

	elif src != null and source == "skill" and element == "ghost" and src.combo_on() and GameData.skill_of_tag(tag).begins_with("soul_strike"):
		Skills.soul_detonate(self, src, e, base, GameData.skill_of_tag(tag) == "soul_strike_x")

	if src != null and source == "skill" and src.kunai_on() and GameData.SKILLS.has(tag) and GameData.SKILLS[tag].get("thrown", false):
		for i in _kunai_n:
			kunai_stick(src, e)

	if src != null and (source == "basic" or source == "skill") and tag != "forge_blast" and src.forge_on():
		forge_heat(src, source)

	if source == "basic" and src != null and float(src.effects.get("melt", 0.0)) > 0.0:
		if e.acid_until <= clock:
			e.acid_frail = 0.0
			spawn_fx("melt", e.position, 0.35, 0.5)
		e.acid_frail = maxf(e.acid_frail, float(src.effects.melt))
		e.acid_until = maxf(e.acid_until, clock + GameData.MELT_TIME)

	var asleep: = e.status == "sleep" and source != "poison"
	var crit: = (source != "poison" or dot_can_crit) and source != "lethal" and (asleep or randf() < src.crit + crit_bonus)

	var kind_mult: = src.basic_mult if source == "basic" or tag in ["poison", "burn", "bleed"] else src.skill_mult_for(tag)



	if tag.begins_with("proc:"):


		kind_mult = src.own_proc_mult(tag.ends_with("@hit"), tag.trim_prefix("proc:").get_slice("@", 0))
	elif tag == "blitz_beat":
		kind_mult = src.own_auto_mult(tag)
	elif tag == "u_owl":



		kind_mult = src.proc_kind_mult(false, "jupitel_thunder")
	elif tag == "u_flies":

		kind_mult = src.proc_kind_mult(false)
	elif tag in GameData.AUTOCAST_TAGS:
		var pm: float = src.proc_mult
		if tag in GameData.AUTOCAST_MAGIC_TAGS:

			pm += GameData.STR_DMG * maxf(0.0, src.eff_stat("int") - src.eff_stat("str"))
		kind_mult = (src.skill_mult_int if tag in GameData.AUTOCAST_INT_TAGS else pm) * GameData.proc_level_mult(src.level)
	var ultra: = crit and src.ultra_crit


	var lethal: = crit and e.prop == "" and src.crit_dmg >= GameData.LETHAL_CRIT_AT and randf() < GameData.LETHAL_CRIT_CHANCE


	var lance: bool = source == "skill" and (tag == "gungnir" or (GameData.SKILLS.has(tag) and GameData.SKILLS[tag].get("lance", false)))
	if lance and not src.mount().is_empty():
		kind_mult *= GameData.MOUNT_LANCE

	if lance and src.equipment != null\
	and src.equipment.slots.weapon != null and GameData.weapon_kind(str(src.equipment.slots.weapon.id)) == "spear":
		kind_mult *= GameData.SPEAR_LANCE
	var wp: = float(src.effects.get("weapon_perfection", 0.0))
	if wp > 0.0 and e.is_boss:
		kind_mult *= 1.0 + wp



	if source == "skill" and GameData.is_summon_tag(tag):
		if e.is_boss or bool(e.def.get("elite", false)):
			kind_mult *= 1.0 + GameData.SUMMON_BOSS_DMG + float(src.effects.get("summon_boss", 0.0))
		var sw: = src.swing_hits()
		if sw > 1.0:
			kind_mult *= pow(sw, GameData.SUMMON_OVERFLOW_POW)
		var leech: = float(src.effects.get("summon_leech", 0.0))
		if leech > 0.0 and clock >= float(src.get_meta("summon_leech_at", 0.0)):
			src.set_meta("summon_leech_at", clock + 1.0 / GameData.SUMMON_LEECH_PER_S)
			src.heal(src.max_hp * leech, self, false, "summon", src)
	var spread: = 1.1 if wp > 0.0 else randf_range(0.9, 1.1)
	var amount: = base * src.dmg_mult * kind_mult * el_mult * spread * (src.crit_dmg * crit_dmg_bonus if crit else 1.0) * (GameData.ULTRA_CRIT_BONUS if ultra else 1.0)
	var amount0: = amount
	if lethal:
		amount *= GameData.LETHAL_CRIT_BONUS
	amount *= 1.0 + GameData.THOR_STACK * src.thor_stacks

	if tower == null and not festival_mode:
		amount *= 1.0 + GameData.early_danger_dmg(danger)

	if tower != null:
		amount *= tower.hero_mult()


	var ym: = raid.ymir_hero_mult()
	if ym > 1.0 and src.effects.has("wing_ymir"):
		ym = 1.0 + (ym - 1.0) * (1.0 + float(src.effects.wing_ymir))
	amount *= ym * raid.epic_mult(e) * morroc.hero_mult(e)


	if e.has_meta("pride"):
		amount *= float(e.get_meta("pride"))

	if e.taunt_vuln > 0.0 and clock < e.taunt_until:
		amount *= 1.0 + e.taunt_vuln

	if encore.on:
		amount *= encore.hit_mult(src, e, source)



	var lex_extra: = 0.0
	if e.lex_until > time and (source == "skill" or tag == "aspersio") and tag != "critical_explosion":
		lex_extra = amount * (e.lex_mult - 1.0)
		amount *= e.lex_mult
		e.lex_until = 0.0
		_lex_spent(e)


	var coma_extra: = 0.0
	if e.coma_until > clock:
		coma_extra = amount * (GameData.U_COMA_BOSS_MULT - 1.0)
		amount *= GameData.U_COMA_BOSS_MULT


	elif not e.is_boss and src != null and src.effects.has("u_coma") and Uniques.coma_hit(source, tag)\
	and randf() < float(src.effects.u_coma):
		coma_extra = amount * (GameData.U_COMA_HIT_MULT - 1.0)
		amount *= GameData.U_COMA_HIT_MULT
		side_word(e, "Coma", Color(0.75, 0.45, 1.0))
		Uniques.coma_look(self, e)

	if calc_watch != "" and src == player and calc_watch == _calc_row(tag, source, element):
		calc_last = {"base": base_in, "situ": base / maxf(base_in, 1e-06), "dmg": src.dmg_mult, "kind": kind_mult, 
			"el": el_mult, "element": element, "target": e.element(), "spread": spread, 
			"crit": (src.crit_dmg * crit_dmg_bonus * (GameData.ULTRA_CRIT_BONUS if ultra else 1.0)) if crit else 1.0, 
			"crit_chance": src.crit + crit_bonus, "crit_dmg": src.crit_dmg, "rest": amount / maxf(amount0, 1e-06), 
			"final": amount, "source": source, "tag": tag, "boss": e.is_boss, "time": time}


	if e.kyrie > 0.0:
		oath_run.kyrie_soak(self, e, amount)
		return

	if e.kin == MobTraits.SHELL and e.kin_c == 0:
		amount = traits.crack(e, amount, self)
	e.hit_el = element
	if crit:
		src.on_crit()
		src.gain_coin(self, 0.08)


		var soup: Dictionary = GameData.RECIPES.lucky_soup
		if src.has_dish("lucky_soup") and e.prop == "" and time >= _lucky_chest_at and randf() < float(soup.crit_chest):
			_lucky_chest_at = time + float(soup.crit_chest_cd)
			_drop_chest(e.position, 1, -1)

	if asleep:
		amount *= (src.crit_dmg + GameData.SLEEP_CRIT_DMG) / maxf(1.0, src.crit_dmg)
		e.sleep_hits += 1
		if e.sleep_hits >= GameData.SLEEP_HITS:
			e.clear_status()


	if world_boss != null and e == raid.boss and src != null:
		amount = world_boss.on_hit(e, amount, source, element, src)
	if e.prop == "":
		if source == "basic" and float(src.effects.get("lifesteal", 0.0)) > 0.0:
			src.hp = minf(src.max_hp, src.hp + amount * float(src.effects.lifesteal))
		var dealt: = minf(amount, maxf(e.hp, 0.0))


		var row: = tag
		if source == "poison":
			var dot: = "bleed" if dot_can_crit else ("poison" if element == "poison" else ("burn" if element == "fire" else ""))
			if dot != "":
				row = dot if tag in ["", "basic", "poison", "burn", "bleed"] else "%s:%s" % [dot, tag.trim_prefix("proc:").get_slice("@", 0)]



		var lexed: = minf(lex_extra, dealt)
		var comaed: = minf(coma_extra, dealt - lexed)
		lexed += comaed
		var combo_part: = (dealt - lexed) * combo_share
		if comaed > 0.0:
			meter_extra(src, "u_coma", comaed, element, e)
		if src == player or heroes.size() < 2:
			_meter_add(row, dealt - lexed - combo_part, element, crit, e)
			if lexed - comaed > 0.0:
				_meter_add("lex_aeterna", lexed - comaed, "holy", false, e)
			if combo_part > 0.0:
				_meter_add("status_combo", combo_part, element, false, e)
		if heroes.size() > 1 and src.slot < meter_hero.size():
			_meter_put(meter_hero[src.slot], row, dealt - lexed - combo_part, element, crit, e, src.slot)
			if lexed - comaed > 0.0:
				_meter_put(meter_hero[src.slot], "lex_aeterna", lexed - comaed, "holy", false)
			if combo_part > 0.0:
				_meter_put(meter_hero[src.slot], "status_combo", combo_part, element, false)
		if dealt >= e.hp and meter.has(row):
			meter[row].kills = int(meter[row].get("kills", 0)) + 1
		if dealt >= e.hp and heroes.size() > 1 and src.slot < meter_hero.size() and meter_hero[src.slot].has(row):
			meter_hero[src.slot][row].kills = int(meter_hero[src.slot][row].get("kills", 0)) + 1

	if src != null and src.has_meta("lk_hold"):
		push *= JobEngines.LORD_KNIGHT.HOLD_PUSH
	e.hurt(amount, push)


	if (e.is_boss or e.def.get("elite", false) or e.feroz) and e.prop == "" and src != null:
		stagger.on_hit(self, src, e, base_in, source, tag)

	if e.def.get("dummy", false):
		e.hp = e.max_hp

	if (source == "skill" or source == "basic") and e.prop == "" and src != null:
		dots.on_hit(self, src, e, base / maxf(again, 0.01), source, _gungnir_of if tag == "gungnir" and _gungnir_of != "" else tag)

	if source == "basic" and src != null and not _shadow_hit and src.skills.has("mirror_image_x") and not e.dead:
		_shadow_hit = true
		var keep_tag: = damage_tag



		var shadows: = src.mirror_nodes()


		if time >= _shadow_trace_at or _shadow_trace_at - time > SHADOW_TRACE_GAP:
			_shadow_trace_at = time + SHADOW_TRACE_GAP
			for m in shadows:
				_bounce_trace(m.global_position * Vector3(1, 0, 1) + Vector3(0, e.position.y, 0), e.position, Color(0.65, 0.6, 1.0))
		if not e.dead and not shadows.is_empty():


			var mi: Dictionary = src.skills.get("mirror_image_x", {})
			var share: = GameData.skill_value("mirror_image_x", "mult", int(mi.get("level", 1))) if not mi.is_empty() else GameData.SHADOW_STRIKE






			var key: = e.get_instance_id() * 8 + src.slot
			var acc: Array = _shadow_acc.get(key, [])
			if acc.is_empty():
				_shadow_acc[key] = [e, base_in * share * shadows.size(), element, src]
			else:
				acc[1] = float(acc[1]) + base_in * share * shadows.size()
		damage_tag = keep_tag
		_shadow_hit = false

	if crit and src != null and src.fury_chain > 0.0 and not _ki_chaining and source != "poison"\
	and not tag.begins_with("proc:") and src.powers.has("critical_explosion") and randf() < src.fury_chain:
		_ki_chain(src, e, base_in, source, element)
	if e.special == "runner":
		_runner_hit(e, amount)


	if source == "skill" and e.prop == "" and not tag.begins_with("proc:"):
		var burst: = float(src.effects.get("skill_burst", 0.0))
		if burst > 0.0 and randf() < burst:
			_skill_burst(e, base, element)

		if not _quake_echo and src != null and src.effects.has("lg_quake")\
		and GameData.skill_of_tag(tag).trim_suffix("_x") in ["earth_spike", "heavens_drive"]:
			_encyclo_echo(src, e, base_in, element, tag)
	if source != "poison":
		play_mob_sound(e.id, "damage")
		_hit_sound(element)
	var color: = Color.WHITE
	if lethal:
		color = GameData.LETHAL_CRIT_COLOR
	elif ultra:
		color = GameData.ULTRA_CRIT_COLOR
	elif crit:
		color = Color(1, 0.85, 0.3)
	elif source == "poison":
		color = dot_color if dot_color.a > 0.0 else Color(0.75, 0.5, 1.0)
	elif el_mult > 1.01:
		smoke_stats.weak += 1
		color = Color(1.0, 0.55, 0.25)
	elif el_mult < 0.99:
		color = Color(0.68, 0.7, 0.78)



	if source != "poison" and not e.is_boss and not e.def.get("mvp", false):
		peak_hit = maxf(peak_hit, amount)
	var dressed: = (ultra or lethal) and _dressed_number_ready()

	var merge_tag: = tag + ("!" if lethal else ("+" if ultra else ""))
	var num: = _merged_number(e, amount, color, crit, merge_tag) if not dressed else null
	if num == null:


		_num_priority = e.is_boss


		var zone_was: = _num_zone
		if source == "poison" and not crit:
			_num_zone = true
		var top: float = e.visual.height() * ((e.visual as Node3D).scale.y if e.visual is Node3D else 1.0)

		top += float(e.get_meta("num_lift", 0.0))
		num = number(e.position + Vector3(0, top, 0), Leaderboard.big_digits(amount), color, crit, ultra or lethal, 
			lethal, clampf(1.0 + (src.crit_dmg * crit_dmg_bonus - 1.5) * 0.08, 1.0, 1.2) if crit else 1.0, 
			source == "poison" and not crit, dressed, crit and source != "poison", 
			("magic" if _magic_hit(source, tag) else "phys") if crit and source != "poison" else "")
		_num_zone = zone_was
		if not dressed and num is Sprite3D:
			e.set_meta("num_last", num)
			e.set_meta("num_total", amount)
			e.set_meta("num_at", Time.get_ticks_msec())
			e.set_meta("num_color", color)
			e.set_meta("num_crit", crit)
			e.set_meta("num_tag", merge_tag)
	if lethal:
		_lethal_crit(e, base, element, tag)
	if source != "poison" and absf(el_mult - 1.0) > 0.01:
		_element_word(e, el_mult, num, GameData.STATUS_COMBO.get(e.status, "") == element or boss_combo)
	if src != null:
		e.last_hit_by = src
	if src != null and source != "poison":
		Legends.after_hit(self, src, e, tag)


	if e.hp > 0.0 and src != null and source == "basic" and tag == "basic" and e.lex_until <= time\
	and src.skills.has("lex_aeterna") and src.skills.has("aspersio"):
		src.lex_hits += 1
		if src.lex_hits >= GameData.LEX_BASIC_EVERY:
			src.lex_hits = 0
			var llv: = int(src.skills.lex_aeterna.level)
			e.lex_until = time + GameData.skill_value("lex_aeterna", "duration", llv)
			e.lex_mult = GameData.skill_value("lex_aeterna", "mult", llv)
			spawn_fx("lexaeterna", e.position, 0.6 if not e.is_boss else 0.85, 1.0, e)
			_skill_mark(e, "lex_aeterna", "lex_until", 0.85)
	if element == "holy" and src != null and e.hp > 0.0 and float(src.effects.get("judgment", 0.0)) > 0.0:
		_judge(e, roundi(float(src.effects.judgment)))
	if e.hp <= 0.0:
		_kill(e)
		if src != null and source != "poison":
			Legends.on_kill(self, src, e, tag, base, element)

		if src != null and source == "basic" and src.skills.has("aspersio") and not e.has_meta("festival"):
			var at: = e.position
			get_tree().create_timer(0.04, false).timeout.connect( func(): aspersio_burst(src, at))

	if src.sphere_max > 0 and source != "poison" and not tag.begins_with("asura"):
		src.sphere_hit()

	if src.has_uniq and source != "poison":
		Uniques.after_damage(self, src, e, element, source, crit, tag, amount)






const NUMBER_MERGE_MS: = 420

const NUMBER_CRIT_SCALE: = 0.8
const NUMBER_REDRAW_MS: = 90




const NUMBER_LIVE_MAX: = 28
const NUMBER_CALM: = 12
const NUMBER_SMALL: = 0.12
const NUMBER_PEAK_HALF: = 1.5
const NUMBER_STARS_MAX: = 5
const NUMBER_STAR_SHARE: = 0.35
const NUMBER_IMPORTANT: = 0.5


const NUMBER_STANDOUT: = 3.0
const NUMBER_AVG_K: = 0.05
const NUMBER_HARD_MAX: = 48


const NUMBER_TRICKLE_MS: = 110
var _num_trickle_at: = 0

var _num_priority: = false


var _num_zone: = false
var _num_avg: = 0.0
var _numbers_pruned: = -1
var _live_numbers: Array = []
var _live_stars: Array = []
var _num_peak: = 0.0
var _num_peak_at: = 0.0


func number_mode() -> String:
	var v = Save.setting("damage_numbers", true)
	if v is bool:
		return "all" if v else "none"
	return str(v)





const NUMBER_GROW: = 0.12
const NUMBER_GROW_MAX: = 1.7
func _number_size(value: float) -> float:
	return clampf(1.0 + NUMBER_GROW * (log(maxf(value, 1.0)) / log(10.0) - 3.0), 1.0, NUMBER_GROW_MAX)






const NUMBER_DRESSED_MS: = 70
var _dressed_at: = 0
func _dressed_number_ready() -> bool:
	var now: = Time.get_ticks_msec()
	if now - _dressed_at < NUMBER_DRESSED_MS:
		return false
	_dressed_at = now
	return true



func mvp_cast() -> float:

	return GameData.mvp_cast_mult(danger, _endless_count + (int(tower.floor) / 5 if tower != null else 0))\
	* GameData.oath_value("mvp_fury", oath("mvp_fury")) * (GameData.WB_EVERY if world_boss != null else 1.0)




func _prune_numbers() -> void :
	var frame: = Engine.get_process_frames()
	if frame == _numbers_pruned:
		return
	_numbers_pruned = frame
	_live_numbers = _live_numbers.filter( func(n): return is_instance_valid(n))
	_live_stars = _live_stars.filter( func(n): return is_instance_valid(n))
	if _number_stacks.size() > 64:
		for k in _number_stacks.keys():
			if not (_number_stacks[k] as Array).any( func(n): return is_instance_valid(n)):
				_number_stacks.erase(k)


func _merged_number(e: Enemy, amount: float, color: Color, crit: = false, tag: = "") -> Node3D:
	var last = (e.get_meta("num_last") if e.has_meta("num_last") else null)
	if last == null or not is_instance_valid(last) or Time.get_ticks_msec() - int(e.get_meta("num_at", 0)) > NUMBER_MERGE_MS or e.get_meta("num_color", Color.WHITE) != color or bool(e.get_meta("num_crit", false)) != crit or str(e.get_meta("num_tag", "")) != tag or number_mode() == "none":
		return null
	var total: = float(e.get_meta("num_total", 0.0)) + amount
	e.set_meta("num_total", total)
	e.set_meta("num_at", Time.get_ticks_msec())



	(last as Node3D).set_meta("total", total)
	return last








func _lethal_crit(e: Enemy, base: float, element: String, tag: String) -> void :
	smoke_stats["lethal"] = int(smoke_stats.get("lethal", 0)) + 1
	var at: = e.position



	if clock >= _lethal_spark_at:
		_lethal_spark_at = clock + 0.08
		spawn_fx("sonicblow", at + Vector3(0, 0.6, 0), 0.9, 1.0)
	var by: = damage_by
	var hit: = base * acting_hero().crit_dmg * GameData.LETHAL_SPLASH
	for o in enemies_in_radius(at, GameData.LETHAL_SPLASH_RADIUS):
		if o != e and not o.dead:






			var key: = o.get_instance_id()
			var acc: Array = _lethal_acc.get(key, [])
			if acc.is_empty():
				_lethal_acc[key] = [o, hit, ((o.position - at) * Vector3(1, 0, 1)).normalized() * 2.5, element, tag, by]
			else:
				acc[1] = float(acc[1]) + hit
	if clock >= _lethal_fx_at:
		_lethal_fx_at = clock + GameData.LETHAL_FX_CD
		play_sound("asura", 0.0, -6.0)
		shake(0.35)


		Vfx.ring(fx_root, at, GameData.LETHAL_SPLASH_RADIUS, GameData.LETHAL_CRIT_COLOR, 0.35)









var _basic_acc: = {}
var hit_weight: = 1
func pool_basic(e: Enemy, amount: float, push: Vector3, element: String, by: Player) -> void :
	if e == null or e.dead or by == null:
		return

	if GameData.has_meta("hit_pool_off"):
		var keep: = damage_by
		damage_by = by
		damage_enemy(e, amount, push, "basic", element)
		damage_by = keep
		return
	var key: = e.get_instance_id() * 8 + by.slot
	var acc: Array = _basic_acc.get(key, [])
	if acc.is_empty():
		_basic_acc[key] = [e, amount, push, element, by, 1]
		return
	acc[1] = float(acc[1]) + amount
	acc[5] = int(acc[5]) + 1


func _flush_basic() -> void :
	if _basic_acc.is_empty():
		return
	var all: = _basic_acc.values()
	_basic_acc.clear()
	var keep: = [damage_tag, damage_by]
	for acc in all:
		var o = acc[0]
		if not is_instance_valid(o) or o.dead or not is_instance_valid(acc[4]):
			continue
		damage_tag = ""
		damage_by = acc[4]
		hit_weight = int(acc[5])
		damage_enemy(o, float(acc[1]), acc[2], "basic", str(acc[3]))
		hit_weight = 1
	damage_tag = keep[0]
	damage_by = keep[1]




var _shadow_acc: = {}
func _flush_shadows() -> void :
	if _shadow_acc.is_empty():
		return
	var all: = _shadow_acc.values()
	_shadow_acc.clear()
	var keep: = [damage_tag, damage_by]
	_shadow_hit = true
	for acc in all:
		var o = acc[0]
		if not is_instance_valid(o) or o.dead or not is_instance_valid(acc[3]):
			continue
		damage_tag = "mirror_image_x"
		damage_by = acc[3]
		damage_enemy(o, float(acc[1]), Vector3.ZERO, "basic", str(acc[2]), "mirror_image_x")
	_shadow_hit = false
	damage_tag = keep[0]
	damage_by = keep[1]




var _lethal_acc: = {}
func _flush_lethal() -> void :
	if _lethal_acc.is_empty():
		return
	var all: = _lethal_acc.values()
	_lethal_acc.clear()
	var keep: = [damage_tag, damage_by]
	for acc in all:
		var o = acc[0]
		if not is_instance_valid(o) or o.dead:
			continue
		damage_tag = str(acc[4])
		damage_by = acc[5] if acc[5] != null and is_instance_valid(acc[5]) else null
		damage_enemy(o, float(acc[1]), acc[2], "lethal", str(acc[3]), str(acc[4]))
	damage_tag = keep[0]
	damage_by = keep[1]







func _ki_chain(src: Player, e: Enemy, base: float, source: String, element: String) -> void :
	var to: Enemy = null
	var best: = GameData.FURY_CHAIN_RANGE * GameData.FURY_CHAIN_RANGE
	for o in enemies_in_radius(e.position, GameData.FURY_CHAIN_RANGE):
		if o == e or o.dead or o.prop != "":
			continue
		var d: = (o.position - e.position).length_squared()
		if d < best:
			best = d
			to = o
	if to == null:
		if e.dead:
			return
		to = e

	if time >= _ki_trace_at or _ki_trace_at - time > 0.12:
		_ki_trace_at = time + 0.12
		if to != e:
			_bounce_trace(e.position, to.position, Color(1.0, 0.85, 0.35))
		Vfx.burst(fx_root, to.position + Vector3(0, 0.5, 0), 0.9, Color(1.0, 0.82, 0.3))
	var keep_tag: = damage_tag
	var keep_by: = damage_by
	damage_by = src
	_ki_chaining = true
	damage_enemy(to, base * GameData.FURY_CHAIN_DMG, Vector3.ZERO, source, element, "critical_explosion")
	_ki_chaining = false
	damage_tag = keep_tag
	damage_by = keep_by






var _asp_tokens: = GameData.ASP_TOKENS_MAX
var _asp_t: = 0.0
var _asp_fx_at: = 0.0
var _asp_ring_at: = 0.0

func aspersio_burst(src: Player, at: Vector3) -> void :
	if not running or not hero_valid(src) or not src.skills.has("aspersio"):
		return
	_asp_tokens = minf(GameData.ASP_TOKENS_MAX, _asp_tokens + (time - _asp_t) * GameData.ASP_PER_S)
	_asp_t = time
	if _asp_tokens < 1.0:
		return
	_asp_tokens -= 1.0
	var lv: = int(src.skills.aspersio.level)
	var dmg: = src.basic_atk() * GameData.skill_value("aspersio", "asp_burst", lv)
	var r: = GameData.ASP_RADIUS * sqrt(src.area_mult)
	var c: = GameData.ASP_COLOR
	if time >= _asp_fx_at:
		_asp_fx_at = time + 0.12
		spawn_fx("holyhit", at + Vector3(0, 0.6, 0), 1.3, 0.8)
		Vfx.column(fx_root, at, c)
		Vfx.burst(fx_root, at + Vector3(0, 0.5, 0), r * 0.7, c)
		Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, c, 0.45)
		shake(0.12)
		play_sound("grand_cross", 0.12, -8.0)
	var hit: = {}
	var keep_tag: = damage_tag
	var keep_by: = damage_by
	damage_tag = "aspersio"
	damage_by = src
	for o in enemies_in_radius(at, r):
		if not o.dead:
			hit[o.get_instance_id()] = true
			damage_enemy(o, dmg, ((o.position - at) * Vector3(1, 0, 1)).normalized() * 2.0, "basic", "holy", "aspersio")
	damage_tag = keep_tag
	damage_by = keep_by
	_asp_bounce(src, at, dmg * GameData.ASP_BOUNCE_DMG, int(GameData.skill_value("aspersio", "asp_bounces", lv)), hit)




func _asp_bounce(src: Player, from: Vector3, dmg: float, left: int, hit: Dictionary) -> void :
	if left <= 0:
		return
	var best: Enemy = null
	var bd: = INF
	for o in enemies_in_radius(from, GameData.ASP_BOUNCE_RANGE):
		if o.dead or hit.has(o.get_instance_id()):
			continue
		var d: = o.position.distance_squared_to(from)
		if d < bd:
			bd = d
			best = o
	if best == null:
		return
	hit[best.get_instance_id()] = true
	var to: = best.position
	var way: = (to - from) * Vector3(1, 0, 1)
	if way.length() > 0.2:
		Vfx.strike_line(fx_root, from, way.normalized(), way.length(), 0.45, GameData.ASP_COLOR)
	get_tree().create_timer(GameData.ASP_BOUNCE_DELAY, false).timeout.connect( func():
		if not running or not hero_valid(src):
			return
		if time >= _asp_ring_at:
			_asp_ring_at = time + 0.05
			Vfx.ring(fx_root, to + Vector3(0, 0.05, 0), GameData.ASP_BOUNCE_RADIUS, GameData.ASP_COLOR, 0.3)
		var kt: = damage_tag
		var kb: = damage_by
		damage_tag = "aspersio"
		damage_by = src
		for o in enemies_in_radius(to, GameData.ASP_BOUNCE_RADIUS * sqrt(src.area_mult)):
			if not o.dead:
				damage_enemy(o, dmg, Vector3.ZERO, "basic", "holy", "aspersio")
		damage_tag = kt
		damage_by = kb
		_asp_bounce(src, to, dmg, left - 1, hit))




func coin_rain(at: Vector3, reach: float) -> void :
	var now: = Time.get_ticks_msec()

	var full: = now - _coin_rain_at >= 250
	spawn_fx("steal_coin", at + Vector3(0, 0.6, 0), 1.0, 1.0)
	if not full:
		return
	_coin_rain_at = now
	Vfx.burst(fx_root, at + Vector3(0, 0.5, 0), reach * 0.6, Color(1.0, 0.85, 0.3))
	Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), reach * 0.8, Color(1.0, 0.85, 0.35), 0.3)
	for k in 6:
		var spot: = at + Vector3(randf_range(-1.6, 1.6), 0, randf_range(-1.6, 1.6))
		_own_timer(0.04 * k, func(): spawn_fx("steal_coin", spot + Vector3(0, 0.4, 0), 0.7, 0.9))
	play_sound("coin2", 0.05, -4.0)
	play_sound("get_coin", 0.1, -6.0)
	shake(0.12)
var _coin_rain_at: = 0




func spawn_homun_extra(h: Player, kind: String) -> void :
	if not GameData.HOMUNCULI.has(kind):
		return
	var node: = Homunculus.new()
	run_root.add_child(node)
	node.setup(self, h, kind)
	node.slot = 1 + h.homun_extra_nodes.size()
	h.homun_extra_nodes.append(node)
	spawn_fx("h_levelup", node.position, 0.8, 0.8)
	h.recompute()




func check_more_homun(h: Player) -> void :
	if h.homun_type == "" or 1 + h.homun_extra.size() >= h.homun_cap() or (h == player and busy()):
		return
	var left: Array = GameData.HOMUNCULI.keys().filter( func(k): return k != h.homun_type and not h.homun_extra.has(k))
	if left.is_empty():
		return
	if h != player or menus.auto_pick:
		var pick: String = left.pick_random()
		h.homun_extra.append(pick)
		spawn_homun_extra(h, pick)
		return
	menus.show_start_skill(left, func(id: String):
		player.homun_extra.append(id)
		spawn_homun_extra(player, id)
		hud.bind(self), tr("Elige otro Homúnculo"), "homun_pick2", str(left[0]))



var _homun_asks: Array = []



func _client_homun_next() -> void :
	if _homun_asks.is_empty() or not running or menus.is_open() or player == null:
		return
	var slot: = int(_homun_asks.pop_front())
	var all: Array = [player.homun_type] + player.homun_extra
	if slot >= all.size():
		return
	var mine: = str(all[slot])
	var options: Array = GameData.HOMUNCULI.keys().filter( func(k): return k == mine or not all.has(k))
	if options.size() < 2:
		_client_homun_next()
		return
	menus.show_start_skill(options, func(id: String):
		if slot == 0:
			Save.set_setting("homun_pick", id)
		if id != mine:
			net.send_homun(id, slot)
		hud.bind(self)
		_client_homun_next.call_deferred(), 
		tr("Elige tu Homúnculo") if slot == 0 else tr("Elige otro Homúnculo"), "homun_pick" if slot == 0 else "homun_pick2", mine)




func swap_homun(h: Player, slot: int, kind: String) -> void :
	var all: Array = [h.homun_type] + h.homun_extra
	if h.homun_type == "" or slot < 0 or slot >= all.size() or all.has(kind):
		return
	var node: = Homunculus.new()
	run_root.add_child(node)
	node.setup(self, h, kind)
	if slot == 0:
		if h.homun_node != null and is_instance_valid(h.homun_node):
			h.homun_node.queue_free()
		h.homun_type = kind
		h.homun_node = node
		if h == player:
			homun = node
	else:
		var i: = slot - 1
		h.homun_extra[i] = kind
		node.slot = slot
		if i < h.homun_extra_nodes.size():
			if is_instance_valid(h.homun_extra_nodes[i]):
				h.homun_extra_nodes[i].queue_free()
			h.homun_extra_nodes[i] = node
		else:
			h.homun_extra_nodes.append(node)
	spawn_fx("h_levelup", node.position, 0.8, 0.8)
	h.recompute()




func spawn_homun(hero: Player = null) -> void :
	var h: = hero if hero != null else player
	if h.homun_node != null and is_instance_valid(h.homun_node):
		h.homun_node.queue_free()
	if not GameData.HOMUNCULI.has(h.homun_type):
		return
	var node: = Homunculus.new()
	run_root.add_child(node)
	node.setup(self, h, h.homun_type)
	h.homun_node = node
	if h == player:
		homun = node
	spawn_fx("h_levelup", node.position, 0.8, 0.8)
	h.recompute()
	for kind in h.homun_extra:
		spawn_homun_extra(h, str(kind))



func _plagiarize(e: Enemy) -> void :
	plagiarize_id(e.id)




func plagiarize_id(mob_id: String) -> void :
	if player == null or not player.can_copy() or training:
		return
	var sid: = ""
	for pair in GameData.plagiarism_pairs():
		if pair[0] == mob_id and GameData.SKILLS.has(pair[1]) and Save.add_plagiarism(str(pair[1])):
			sid = str(pair[1])
			break
	if sid == "":
		return
	Save.flush()
	spawn_fx("steal_coin", player.position, 1.2, 1.0, player)
	Vfx.burst(fx_root, player.position, 5.0, Color(1.0, 0.82, 0.3))
	Vfx.column(fx_root, player.position, Color(1.0, 0.85, 0.4))
	play_sound("levelup", 0.0, -2.0)
	play_sound("drop_yellow", 0.0, -4.0)
	hud.stolen_skill(sid, mob_id)



func auto_counter(p: Player, e: Enemy) -> void :
	var to: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
	p.play_attack(to)
	spawn_fx("autocounter", e.position, 1.0, 1.0)
	play_sound("auto_counter", 0.1, -4.0)
	label_over(p, tr("¡Contraataque!"), Color(0.9, 0.92, 1.0))
	damage_tag = "auto_counter"

	var by: = damage_by
	damage_by = p
	var before: = p.crit
	p.crit = 1.0



	var over: = maxf(0.0, float(p.effects.get("auto_counter", 0.0)) - 1.0)
	damage_enemy(e, p.basic_atk() * (GameData.COUNTER_DMG + float(p.effects.get("counter_dmg", 0.0))) * (1.0 + over), to * 4.0, "basic", p.basic_element(), "auto_counter")
	p.crit = before
	damage_by = by





func taekwon_kick(p: Player, e: Enemy, id: String) -> void :

	if p.powers.has("oath_silence"):
		return
	var s: Dictionary = GameData.SKILLS[id]
	p._combo_busy = true
	_stance_sign(p, str(s.get("ready", "")))
	play_sound("tk_ready", 0.1, -12.0)
	await get_tree().create_timer(GameData.STANCE_BEAT, false).timeout
	if not hero_valid(p) or not running or not p.skills.has(id):
		if is_instance_valid(p):
			p._combo_busy = false
		return
	e = _combo_next(p, e)
	if e != null:
		p.set_meta("kick_target", e)
		_combo_word(p, tr(str(s.name)), s.color, 1)
		damage_by = p
		Skills.cast(self, p, id, int(p.skills[id].level), "stance")
		p.kick_landed(self)
		if p.has_uniq:
			Uniques.on_kick(self, p)
		damage_by = null
		p.remove_meta("kick_target")
	p._stance_rest = GameData.STANCE_REST
	p._combo_busy = false




func _stance_sign(p: Player, key: String) -> void :

	if Vfx.hidden():
		return
	var spr: = RoAssets.sprite([key]) if key != "" else null
	if spr == null:
		return
	var s: = Sprite3D.new()
	s.texture = spr.get_frame(0, 0)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 16
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.pixel_size = GameData.PIXEL_SIZE * 0.9
	p.add_child(s)
	s.position = RoVisual.lift + Vector3(0, p.visual.height() + 0.6, 0)
	s.scale = Vector3.ONE * 1.6
	var tw: = s.create_tween()
	tw.tween_property(s, "scale", Vector3.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.3)
	tw.tween_property(s, "modulate:a", 0.0, 0.25)
	tw.tween_callback(s.queue_free)



func afterimage(p: Player, col: Color) -> void :

	if Vfx.hidden():
		return
	if p.visual == null or p.visual.sprite.texture == null:
		return
	var v: RoVisual = p.visual
	var g: = Sprite3D.new()
	g.texture = v.sprite.texture
	g.offset = v.sprite.offset
	g.centered = false
	g.pixel_size = v.sprite.pixel_size
	g.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	g.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	g.shaded = false
	g.modulate = col
	g.render_priority = 5
	fx_root.add_child(g)
	g.global_transform = v.sprite.global_transform
	var tw: = g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.25)
	tw.tween_callback(g.queue_free)



func dash_landed(p: Player, d: Dictionary) -> void :
	if not hero_valid(p):
		return
	damage_tag = str(d.get("tag", ""))
	damage_by = p
	match str(d.get("kind", "")):
		"leap":
			var area: = float(d.get("land_area", 2.0))
			play_sound("tk_tumble", 0.0, -2.0)
			shake(0.3)
			spawn_fx("earthhit", p.position, area / 2.5, 0.8)
			Vfx.ring(fx_root, p.position, area, Color(0.85, 0.95, 1.0), 0.4)
			for e in enemies_in_radius(p.position, area):
				var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
				damage_enemy(e, float(d.get("land_dmg", 0.0)), away * float(d.get("knock", 6.0)), "skill", p.basic_element())
		"charge":
			_charge_landed(p, d)
		"flying":
			shake(0.2)
			Vfx.burst(fx_root, p.position, 1.4, Color(1.0, 0.85, 0.55))


			if d.get("rebound", false) and int(d.get("rebounds", 0 if d.get("rebounded", false) else 1)) > 0:
				var next: Enemy = null
				for e in enemies_in_radius(p.position, 6.0):
					if not d.hit.has(e) and not e.dead and e.prop == "":
						next = e
						break
				if next != null:
					var to: = next.position + ((next.position - p.position) * Vector3(1, 0, 1)).normalized() * 0.8
					var opts: = d.duplicate()
					opts["rebounded"] = true
					opts["rebounds"] = int(d.get("rebounds", 1)) - 1
					if p.effects.has("lg_fkick"):
						opts["dmg"] = float(d.get("dmg", 0.0)) * GameData.LG_FKICK_GROW
					opts.erase("hit")
					play_sound("tk_flying", 0.0, -4.0)
					p.start_dash(self, map.slide(p.position, (to - p.position) * Vector3(1, 0, 1)), 0.22, opts)
	damage_by = null



func star_fall(p: Player, at: Vector3, area: float, dmg: float, element: String) -> void :
	sprite_fx("fx_sl_1", at + Vector3(0, 1.2, 0), 0, 0.85)
	Vfx.column(fx_root, at, Color(1.0, 0.95, 0.6))
	var sk: = {"color": Color(1.0, 0.95, 0.6), "element": element, "sound": "sl_ping", "sound_db": -10.0}
	delayed_aoe(at, area * sqrt(p.area_mult), dmg, 0.22, sk, true)






func soul_ghost(p: Player, spirit: String) -> void :
	if net.recording():
		net.record(["sg", net.ref_of(p), spirit])

	if Vfx.hidden():
		return
	if not is_instance_valid(p):
		return
	var body: = str(GameData.SOUL_SPIRIT_BODIES.get(spirit, spirit))
	var look: = RoAssets.character(body, "head_m")
	if look == null:
		return
	var v: = RoVisual.new()
	run_root.add_child(v)
	v.setup(look, Color.WHITE, 32, 0.0)
	v.sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	v.tint = Color(0.82, 0.78, 1.0, 0.0)
	var at: = p.position + Vector3(-1.4, 0, 0.6)
	v.position = at
	v.play(RoVisual.PC_CAST, false, true)
	var tw: = v.create_tween()
	tw.tween_property(v, "tint:a", 0.85 * Vfx.dim, 0.25)
	tw.parallel().tween_property(v, "position:y", at.y + 0.35, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(0.85)
	tw.tween_property(v, "tint:a", 0.0, 0.5)
	tw.parallel().tween_property(v, "position:y", at.y + 0.9, 0.5).set_ease(Tween.EASE_IN)
	tw.tween_callback(v.queue_free)

	Vfx.magic_circle(fx_root, at + Vector3(0, 0.04, 0), 1.0, Color(0.75, 0.62, 1.0, 0.55), 1.6, "mvp_hexa", 1.2)
	Vfx.converge(fx_root, at, 1.4, Color(0.8, 0.72, 1.0, 0.6), 0.25)




func bound_seal(e: Enemy, seconds: float) -> void :
	if net.recording():
		net.record(["bs", net.ref_of(e), seconds])
	if not is_instance_valid(e) or Vfx._skip(2):
		return
	var r: = clampf(e.radius * 1.6, 0.9, 3.0)
	var c: = Vfx.magic_circle(e, Vector3(0, 0.04, 0), r, Color(0.72, 0.6, 1.0, 0.42 * Vfx.dim), 0.0, "mvp_hexa", 0.5)
	if c == null:
		return
	var tw: = c.create_tween()
	tw.tween_interval(maxf(0.1, seconds - 0.4))
	tw.tween_property(c, "transparency", 1.0, 0.4)
	tw.tween_callback(c.queue_free)


func spirit_sign(h: Player, spirit: String) -> void :

	if Vfx.hidden():
		return
	var path: = "res://assets/ro/ui/skin/skill_icons/spirit_%s.png" % spirit
	if ResourceLoader.exists(path):
		var s: = Sprite3D.new()
		s.texture = load(path)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 16
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.pixel_size = 0.03
		h.add_child(s)
		s.position = RoVisual.lift + Vector3(0, h.visual.height() + 0.5, 0)
		s.modulate.a = 0.0
		var tw: = s.create_tween()
		tw.tween_property(s, "modulate:a", 1.0, 0.2)
		tw.parallel().tween_property(s, "position:y", s.position.y + 0.8, 1.6).set_ease(Tween.EASE_OUT)
		tw.tween_property(s, "modulate:a", 0.0, 0.4)
		tw.tween_callback(s.queue_free)
	var power: Dictionary = GameData.SKILL_POWERS.get("spirit_" + spirit, {})
	if power.has("name"):
		label_over(h, "%s: %s" % [tr(str(power.name)), menus._mods_text(power.get("mods", {}))], Color(0.88, 0.8, 1.0))
	spawn_fx("cure", h.position, 1.0, 0.8, h)





func monk_combo(p: Player, e: Enemy) -> void :
	p._combo_busy = true

	var fury: = p.effects.has("lg_berserk")
	if fury:
		Legends.fury_start(self, p)

	var broke: = false

	_combo_word(p, tr("Raging Trifecta Blow"), Color(1.0, 0.92, 0.7), 0)
	await _combo_hits(p, e, 3, 1.0, "triple_attack", [RoVisual.PC_ATTACK, 10, 11])
	var chain: = float(p.effects.get("chain_combo", 0.0))
	e = _combo_next(p, e)
	broke = chain > 0.0 and not _combo_on(p, e)
	if chain > 0.0 and _combo_on(p, e):
		await get_tree().create_timer(GameData.COMBO_GAP, false).timeout
		e = _combo_next(p, e)
		broke = not _combo_on(p, e)
		if _combo_on(p, e):

			_combo_word(p, tr("Raging Quadruple Blow"), Color(1.0, 0.75, 0.4), 1)
			play_sound("chain_combo", 0.1, -2.0)
			Vfx.ring(fx_root, e.position, 1.6, Color(1.0, 0.8, 0.45), 0.3)
			await _combo_hits(p, e, 4, chain, "chain_combo", [10, 11, 10, 11])
			var finish: = float(p.effects.get("combo_finish", 0.0))
			e = _combo_next(p, e)
			broke = finish > 0.0 and not _combo_on(p, e)
			if finish > 0.0 and _combo_on(p, e):
				await get_tree().create_timer(GameData.COMBO_GAP, false).timeout
				e = _combo_next(p, e)
				broke = not _combo_on(p, e)
				if _combo_on(p, e):
					_combo_finish(p, e, finish)





			var crush: = "chain_crush_x" if p.skills.has("chain_crush_x") else ("chain_crush" if p.skills.has("chain_crush") else "")
			var charges: = _combo_charges(p)
			var far: = 1.0 + GameData.COMBO_CRUSH_AREA * charges
			var storm: = GameData.skill_value(crush, "range", int(p.skills[crush].level)) * sqrt(p.area_mult) * far if crush != "" else 0.0

			if finish > 0.0 and crush != "" and charges >= GameData.COMBO_CRUSH_AT and hero_valid(p) and running and nearest_enemy(p.position, storm) != null:
				await get_tree().create_timer(GameData.COMBO_GAP + 0.1, false).timeout
				if hero_valid(p) and running:
					_combo_word(p, "%s ×%d" % [tr("Chain Crush Combo"), charges], Color(1.0, 0.35, 0.15), 3)
					p.play_combo(p.facing, RoVisual.PC_CAST)
					play_sound("chain_combo", 0.0, 0.0, 1.25)
					play_sound("fury", 0.1, -4.0)
					shake(0.35)
					Vfx.ring(fx_root, p.position, 4.5, Color(1.0, 0.6, 0.25), 0.4)
					Vfx.burst(fx_root, p.position, 3.0, Color(1.0, 0.7, 0.3))
					p.crush_mult = (1.0 + GameData.COMBO_CRUSH_PER * charges) * pow(maxf(1.0, p.swing_hits()), GameData.COMBO_SWING_POW)
					p.crush_reach = far
					Skills.cast(self, p, crush, int(p.skills[crush].level), "combo")
					p.crush_mult = 1.0
					p.crush_reach = 1.0
					p.combo_charges = 0

					p.skills[crush].cd = GameData.skill_value(crush, "cooldown", int(p.skills[crush].level)) * p.cd_for(crush)
					damage_by = null
					if fury:
						Legends.fury_hit(self, p)
	if is_instance_valid(p):
		p._combo_busy = false
		if fury:
			Legends.fury_end(self, p, broke)



func _combo_charges(p: Player) -> int:
	if clock - p.combo_charge_at > GameData.COMBO_CHARGE_KEEP:
		p.combo_charges = 0
	return p.combo_charges



func _combo_charge(p: Player) -> void :
	p.combo_charges = mini(GameData.COMBO_CHARGE_MAX, _combo_charges(p) + 1)
	p.combo_charge_at = clock




func _combo_next(p: Player, e: Enemy) -> Enemy:
	if e != null and is_instance_valid(e) and not e.dead:
		return e
	if not hero_valid(p):
		return null

	var reach: = GameData.COMBO_REACH * (GameData.LG_FURY_REACH if p.effects.has("lg_berserk") else 1.0)
	return nearest_enemy(p.position, reach * sqrt(p.area_mult))



func _combo_on(p: Player, e: Enemy) -> bool:
	return hero_valid(p) and running and is_instance_valid(e) and not e.dead



func _combo_finish(p: Player, e: Enemy, finish: float) -> void :
	_combo_word(p, tr("Raging Thrust"), Color(1.0, 0.5, 0.2), 2)
	p.play_combo((e.position - p.position) * Vector3(1, 0, 1), RoVisual.PC_ATTACK)
	shake(0.3)
	play_sound("combo_finish", 0.1, 0.0)
	play_sound("hit_fist", 0.05, -2.0)
	spawn_fx("bowling", e.position, 1.5, 1.0)
	Vfx.ring(fx_root, e.position, 2.8, Color(1.0, 0.55, 0.2), 0.35)
	Vfx.burst(fx_root, e.position, 2.2, Color(1.0, 0.6, 0.25))
	var at: = e.position
	var charged: = (1.0 + GameData.COMBO_CHARGE_DMG * _combo_charges(p)) * pow(maxf(1.0, p.swing_hits()), GameData.COMBO_SWING_POW)
	for o in enemies_in_radius(at, 2.6 * sqrt(p.area_mult)):
		damage_tag = "combo_finish"
		damage_by = p
		var away: = ((o.position - at) * Vector3(1, 0, 1)).normalized()
		damage_enemy(o, p.basic_atk() * finish * charged, away * 6.0, "basic", p.basic_element(), "combo_finish")


	var line: = ((at - p.position) * Vector3(1, 0, 1))
	line = line.normalized() if line.length() > 0.05 else p.facing
	var long: = GameData.RAGING_LINE * sqrt(p.area_mult)
	var wide: = GameData.RAGING_LINE_WIDTH * sqrt(p.area_mult)
	Vfx.ring(fx_root, at + line * long * 0.5, wide, Color(1.0, 0.6, 0.25), 0.3)
	for o in enemies_in_radius(at + line * long * 0.5, long * 0.5 + wide):
		var rel: = (o.position - at) * Vector3(1, 0, 1)
		var along: = rel.dot(line)
		if along < 0.0 or along > long or (rel - line * along).length() > wide:
			continue
		damage_tag = "combo_finish"
		damage_by = p
		damage_enemy(o, p.basic_atk() * finish * charged * GameData.RAGING_LINE_SHARE, line * 5.0, "basic", p.basic_element(), "combo_finish")
	_combo_charge(p)
	damage_tag = "combo_finish"
	damage_by = p
	if is_instance_valid(e) and not e.dead:
		p.on_basic_hit(self, e)
	damage_by = null
	Legends.fury_hit(self, p)




func _combo_word(p: Player, text: String, color: Color, step: int) -> void :
	var l: = Label3D.new()
	l.text = text
	l.font = RO_UI_FONT
	l.font_size = 34 + step * 8
	l.pixel_size = 0.012
	l.outline_size = 10
	l.outline_modulate = Color(0.25, 0.08, 0.0, 0.95)
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 17
	l.outline_render_priority = 16
	l.position = p.position + Vector3(0, p.visual.height() + 0.9 + 0.35 * step, 0)
	l.scale = Vector3.ONE * 1.7
	fx_root.add_child(l)
	var tw: = l.create_tween().set_parallel()
	tw.tween_property(l, "scale", Vector3.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y + 0.45, 0.8).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.55)
	tw.tween_property(l, "outline_modulate:a", 0.0, 0.3).set_delay(0.55)
	tw.chain().tween_callback(l.queue_free)





func _chain_word(p: Player, n: int, col: Color) -> void :
	var old = (p.get_meta("chain_word") if p.has_meta("chain_word") else null)
	if old != null and is_instance_valid(old):
		old.queue_free()
	p.set_meta("chain_word", _chain_count(p.position + Vector3(0, p.visual.height() + 1.7, 0), n, col))



func _chain_count(at: Vector3, n: int, col: Color, small: = false, word: = "") -> Label3D:
	var step: = mini(n - 2, 6)
	var hot: = Color.WHITE.lerp(Color(1.0, 0.85, 0.25), clampf(step / 2.0, 0.0, 1.0)).lerp(Color(1.0, 0.3, 0.2), clampf((step - 2) / 3.0, 0.0, 1.0))
	var side: = camera.global_basis.x if camera != null else Vector3.RIGHT


	var size: = (0.6 + 0.03 * step) if small else (1.35 + 0.25 * step)
	var text: = "x%d" % n + ("" if word == "" else " " + word)
	var l: = _chain_label(text, size, hot, Color(col.darkened(0.75), 1.0))
	l.position = at
	l.scale = Vector3.ONE * (1.25 if small else 2.8)
	fx_root.add_child(l)
	var tw: = l.create_tween()
	tw.tween_property(l, "scale", Vector3.ONE, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position", at + side * 0.14, 0.03)
	tw.tween_property(l, "position", at - side * 0.09, 0.04)
	tw.tween_property(l, "position", at, 0.04)

	tw.tween_interval(1.1 if small else 0.3)
	tw.tween_property(l, "transparency", 1.0, 0.22)
	tw.parallel().tween_property(l, "position:y", at.y + 0.4, 0.22)
	tw.tween_callback(l.queue_free)

	var echo: = _chain_label(text, size, Color(col.lightened(0.3), 0.22 if small else 0.7), Color(0, 0, 0, 0))
	echo.position = at
	echo.render_priority = 16
	fx_root.add_child(echo)
	var et: = echo.create_tween().set_parallel()
	et.tween_property(echo, "scale", Vector3.ONE * (1.1 if small else (2.2 + 0.15 * step)), 0.3).set_ease(Tween.EASE_OUT)
	et.tween_property(echo, "transparency", 1.0, 0.3)
	et.chain().tween_callback(echo.queue_free)
	return l


func _chain_label(text: String, size: float, color: Color, outline: Color) -> Label3D:
	var l: = Label3D.new()
	l.text = text
	l.font = RO_UI_FONT
	l.font_size = 64
	l.pixel_size = 0.016 * size
	l.outline_size = 16
	l.outline_modulate = outline
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 18
	l.outline_render_priority = 17
	return l





func _combo_hits(p: Player, e: Enemy, n: int, mult: float, tag: String, poses: Array) -> void :
	for i in n:
		e = _combo_next(p, e)
		if not _combo_on(p, e):
			return
		p.play_combo((e.position - p.position) * Vector3(1, 0, 1), int(poses[i % poses.size()]))
		damage_tag = tag

		damage_by = p
		damage_enemy(e, p.basic_atk() * mult * (1.0 + GameData.COMBO_CHARGE_DMG * _combo_charges(p)) * pow(maxf(1.0, p.swing_hits()), GameData.COMBO_SWING_POW), 
			Vector3.ZERO, "basic", p.basic_element(), tag)
		_combo_charge(p)
		Legends.fury_hit(self, p)
		play_sound("hit_fist", 0.03, -6.0)
		spawn_fx("hit", e.position + Vector3(randf_range(-0.3, 0.3), 0.6, randf_range(-0.3, 0.3)), 0.7 + 0.1 * i, 0.9)
		if is_instance_valid(e) and not e.dead:
			p.on_basic_hit(self, e)
		damage_by = null
		await get_tree().create_timer(0.09, false).timeout






func _element_word(e: Enemy, mult: float, num: Node3D = null, combo: = false) -> void :
	if num == null:
		return
	var now: = Time.get_ticks_msec() * 0.001


	if not combo and now - float(e.get_meta("el_word", -9.0)) < GameData.ELEMENT_WORD_EVERY:
		return
	if combo:
		if now < _combo_word_at:
			return
		_combo_word_at = now + 0.3
	e.set_meta("el_word", now)
	var weak: = mult > 1.0
	var l: = Label3D.new()
	l.text = tr("¡Combo!") if combo else (tr("¡Eficaz!") if weak else tr("Resiste"))
	if combo:
		play_sound("lightbolt_hit1" if e.status == "freeze" else "fire_hit1", 0.35, -6.0)
	l.font = RO_UI_FONT
	l.font_size = 38 if combo else 30
	l.pixel_size = 0.013
	l.outline_size = 9
	l.outline_modulate = Color(0, 0, 0, 0.9)
	l.modulate = Color(0.45, 0.95, 1.0) if combo else (Color(1.0, 0.6, 0.2) if weak else Color(0.7, 0.74, 0.85))

	var shown: = clampf(float(Save.setting("num_alpha", 0.8)), 0.2, 1.0)
	l.modulate.a = shown
	l.outline_modulate.a *= shown
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 17
	l.outline_render_priority = 16
	l.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	var top: = 0.25
	if num is Sprite3D and (num as Sprite3D).texture != null:
		top = (num as Sprite3D).texture.get_height() * (num as Sprite3D).pixel_size * 0.5
	l.position = Vector3(0, top + 0.06, 0)
	num.add_child(l)
	var tw: = l.create_tween().set_parallel()
	tw.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.38)
	tw.tween_property(l, "outline_modulate:a", 0.0, 0.3).set_delay(0.38)




var _quake_echo: = false
func _encyclo_echo(p: Player, e: Enemy, base: float, element: String, tag: String) -> void :
	_own_timer(GameData.ENCYCLO_ECHO_DELAY, func():
		if not running or not is_instance_valid(e) or e.dead or not hero_valid(p):
			return
		var keep: = [damage_tag, damage_by]
		damage_tag = tag
		damage_by = p
		_quake_echo = true
		damage_enemy(e, base * GameData.ENCYCLO_ECHO, Vector3.ZERO, "skill", element, tag)
		_quake_echo = false
		damage_tag = keep[0]
		damage_by = keep[1]
		if _quake_fx_ok():
			Vfx.ring(fx_root, e.position + Vector3(0, 0.05, 0), 0.9 + e.radius, Color(0.75, 0.55, 0.3), 0.3))



var _quake_fx_at: = 0.0
var _quake_fx_n: = 0
func _quake_fx_ok() -> bool:
	if time - _quake_fx_at > 0.2:
		_quake_fx_at = time
		_quake_fx_n = 0
	_quake_fx_n += 1
	return _quake_fx_n <= 6





func destroyer_grenades(p: Player, around: Array, dmg: float) -> void :
	var tag: = damage_tag
	var picks: = around.filter( func(o): return is_instance_valid(o) and not o.dead and o.prop == "")
	picks.shuffle()
	var r: = GameData.DESTROYER_GRENADE_RADIUS * sqrt(p.area_mult)
	for i in mini(GameData.DESTROYER_GRENADES, picks.size()):
		var at: Vector3 = picks[i].position
		Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, Color(1.0, 0.55, 0.2), GameData.DESTROYER_FUSE)
		_own_timer(GameData.DESTROYER_FUSE + 0.06 * i, func():
			if not running or not hero_valid(p):
				return
			Vfx.burst(fx_root, at, r, Color(1.0, 0.55, 0.2))
			spawn_fx("firehit1", at, 0.9, 0.9)
			play_sound("landmine", 0.15, -5.0)
			var keep: = [damage_tag, damage_by]
			damage_tag = tag
			damage_by = p
			for o in enemies_in_radius(at, r):
				if not o.dead:
					damage_enemy(o, dmg * GameData.DESTROYER_GRENADE_DMG, ((o.position - at) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", "fire", tag)
			damage_tag = keep[0]
			damage_by = keep[1])


func _skill_burst(from: Enemy, base: float, element: String) -> void :
	var at: = from.position
	Vfx.burst(fx_root, at, GameData.SKILL_BURST_RADIUS, Color(1.0, 0.62, 0.3))
	play_sound("landmine", 0.15, -6.0)
	for o in enemies_in_radius(at, GameData.SKILL_BURST_RADIUS):
		if o != from and not o.dead:
			damage_enemy(o, base * GameData.SKILL_BURST_DMG, Vector3.ZERO, "burst", element, "burst")




func _meter_put(into: Dictionary, tag: String, dealt: float, element: String, crit: bool, e: Enemy = null, slot: = -1) -> void :
	if tag == "" or dealt <= 0.0:
		return
	var m: Dictionary = into.get(tag, {})
	if m.is_empty():
		m = {"dmg": 0.0, "hits": 0, "max": 0.0, "el": element, "first": time}
		into[tag] = m
	m.dmg += dealt
	m.hits += 1
	m.el = element
	m.max = maxf(m.max, dealt)
	m["min"] = minf(float(m.get("min", dealt)), dealt)
	m["last"] = time
	if crit:
		m["crits"] = int(m.get("crits", 0)) + 1
	if e != null and (e.is_boss or e.def.get("elite", false)):
		m["boss"] = float(m.get("boss", 0.0)) + dealt
		if not meter_boss_hero.has(slot):
			meter_boss_hero[slot] = {}
		_boss_row(meter_boss_hero[slot], e, tag, dealt)

		_focus_add(dealt)





func _focus_add(dealt: float) -> void :
	meter_stats["focus_dmg"] = float(meter_stats.get("focus_dmg", 0.0)) + dealt
	var last: = float(meter_stats.get("focus_last", -1.0))
	if last >= 0.0:
		meter_stats["focus_s"] = float(meter_stats.get("focus_s", 0.0)) + clampf(clock - last, 0.0, GameData.FOCUS_GAP)
	meter_stats["focus_last"] = clock




func focus_dps() -> float:
	var s: = float(meter_stats.get("focus_s", 0.0))
	if s < GameData.FOCUS_MIN_S:
		return -1.0
	return float(meter_stats.get("focus_dmg", 0.0)) / s





func pride_on() -> bool:
	return player != null and is_instance_valid(player) and player.pride\
	and not training and not festival_mode






func pride_resist(max_hp: float) -> float:
	if not pride_on() or max_hp <= 0.0:
		return 1.0
	var m: = 1.0
	var f: = focus_dps()
	if f > 0.0:
		m = minf(m, max_hp / (f * GameData.PRIDE_TIME))
	var best: = float(meter_stats.get("best", 0.0))
	if best > 0.0:
		m = minf(m, max_hp * GameData.PRIDE_HIT / best)
	return clampf(m, GameData.PRIDE_MIN, 1.0)




func tank_dps(dps: float) -> float:
	var f: = focus_dps()
	return dps if f <= 0.0 else minf(dps, f * GameData.FOCUS_CAP)



func _boss_row(into: Dictionary, e: Enemy, tag: String, dealt: float) -> void :
	var b: Dictionary = into.get(e.id, {})
	if b.is_empty():
		b = {"dmg": 0.0, "tags": {}, "mvp": bool(e.def.get("mvp", false))}
		into[e.id] = b
	b.dmg += dealt
	b.tags[tag] = float(b.tags.get(tag, 0.0)) + dealt




func party_dealt() -> float:
	var total: = 0.0
	for m in meter_hero:
		for k in m:
			total += float((m[k] as Dictionary).get("dmg", 0.0)) if m[k] is Dictionary else 0.0


	return maxf(maxf(0.0, total - float(meter_stats.get("free_party", 0.0))), boss_measure(float(meter_stats.get("total", 0.0))))








func measure_time() -> float:
	return time + float(meter_stats.get("fight_s", 0.0))








func boss_measure(total: float) -> float:
	return maxf(0.0, total - float(meter_stats.get("free", 0.0)))





func meter_free(src: Player, dealt: float) -> void :
	if src == null or dealt <= 0.0:
		return
	if src == player or heroes.size() < 2:
		meter_stats["free"] = float(meter_stats.get("free", 0.0)) + dealt
	if heroes.size() > 1 and src.slot < meter_hero.size():
		meter_stats["free_party"] = float(meter_stats.get("free_party", 0.0)) + dealt




func meter_extra(src: Player, tag: String, dealt: float, element: String, e: Enemy = null) -> void :
	if src == null or dealt <= 0.0:
		return
	if src == player or heroes.size() < 2:
		_meter_add(tag, dealt, element, false, e)
	if heroes.size() > 1 and src.slot < meter_hero.size():
		_meter_put(meter_hero[src.slot], tag, dealt, element, false)


func _meter_add(tag: String, dealt: float, element: String, crit: bool, e: Enemy = null) -> void :
	if tag == "" or dealt <= 0.0:
		return
	var m: Dictionary = meter.get(tag, {})
	if m.is_empty():
		m = {"dmg": 0.0, "hits": 0, "max": 0.0, "el": element, "first": time}
		meter[tag] = m
	m.dmg += dealt
	m.hits += 1
	m.el = element
	m.max = maxf(m.max, dealt)
	m["min"] = minf(float(m.get("min", dealt)), dealt)
	m["last"] = time
	if crit:
		m["crits"] = int(m.get("crits", 0)) + 1

	if e != null and (e.is_boss or e.def.get("elite", false)):
		m["boss"] = float(m.get("boss", 0.0)) + dealt
		_boss_row(meter_boss, e, tag, dealt)
		if heroes.size() < 2:
			_focus_add(dealt)
	meter_stats.total += dealt
	meter_stats.hits += 1
	if crit:
		meter_stats.crits += 1
	if dealt > meter_stats.best:
		meter_stats.best = dealt
		meter_stats.best_tag = tag






func meter_take(from: Enemy, amount: float, pierce: bool, hero: Player = null, raw: = -1.0) -> void :
	var key: = "mechanics" if pierce else "shots"
	if from != null and is_instance_valid(from):
		key = from.id if not pierce else "mechanics:" + from.id

	var rows: = meter_taken
	if hero != null and hero != player:
		if not meter_taken_hero.has(hero.slot):
			meter_taken_hero[hero.slot] = {}
		rows = meter_taken_hero[hero.slot]
	var t: Dictionary = rows.get(key, {})
	if t.is_empty():
		t = {"dmg": 0.0, "hits": 0, "max": 0.0}
		rows[key] = t
	t.dmg += amount
	t.hits += 1
	t.max = maxf(t.max, maxf(amount, raw))



var meter_focus: = -1

const PARTY_COLORS: = [Color(0.55, 0.75, 1.0), Color(0.98, 0.6, 0.4), Color(0.6, 0.9, 0.45), Color(0.9, 0.6, 0.95)]




func meter_party_rows() -> Array:
	var out: = []
	for h in heroes:
		if h.slot >= meter_hero.size():
			continue
		var total: = 0.0
		var first: = time
		for t in meter_hero[h.slot]:
			total += float(meter_hero[h.slot][t].get("dmg", 0.0))
			first = minf(first, float(meter_hero[h.slot][t].get("first", time)))
		out.append({"tag": "hero:%d" % h.slot, "dmg": total, "el": "neutral", "first": 0.0, "slot": h.slot})
	out.sort_custom( func(a, b): return a.dmg > b.dmg)
	return out



func hero_meter_name(slot: int) -> String:
	if slot >= heroes.size():
		return "?"
	var h: Player = heroes[slot]
	var shown: = str(h.appearance.get("name", "")).strip_edges()
	if shown == "":
		shown = tr(h.job_name())
	return ("%s (%s)" % [shown, tr("Tú")]) if h == player else shown





func meter_rows(mode: String, boss: = "") -> Array:
	var rows: = _meter_rows_all(mode, boss)

	if meter_view.is_empty() or not running:
		return rows
	var base: = {}
	match mode:
		"boss":
			for id in meter_view.boss:
				if boss != "" and id != boss:
					continue
				for t in meter_view.boss[id]:
					var had: Array = base.get(t, [0.0, 0])
					base[t] = [float(had[0]) + float(meter_view.boss[id][t]), 0]
		"taken":
			base = meter_view.taken
		"heal":
			base = meter_view.heal
		"party":
			for slot in (meter_view.hero as Array).size():
				var sum: = 0.0
				for t in meter_view.hero[slot]:
					sum += float(meter_view.hero[slot][t][0])
				base["hero:%d" % slot] = [sum, 0]
		_:
			base = meter_view.hero[meter_focus] if _meter_focus_other() and meter_focus < (meter_view.hero as Array).size() else meter_view.src
	return _view_rows(rows, base)



func _meter_focus_other() -> bool:
	return meter_focus >= 0 and meter_focus < meter_hero.size() and heroes.size() > 1\
	and (meter_focus >= heroes.size() or heroes[meter_focus] != player)


func _meter_rows_all(mode: String, boss: = "") -> Array:
	var out: = []
	match mode:
		"boss":
			var sums: = {}
			for id in meter_boss:
				if boss != "" and id != boss:
					continue
				for t in meter_boss[id].tags:
					sums[t] = float(sums.get(t, 0.0)) + float(meter_boss[id].tags[t])
			for t in sums:
				var m: Dictionary = meter.get(t, {}).duplicate()
				m["tag"] = t
				m["dmg"] = sums[t]
				m["el"] = m.get("el", "neutral")
				out.append(m)
		"taken":
			for k in meter_taken:
				var m: Dictionary = meter_taken[k].duplicate()
				m["tag"] = k
				m["el"] = "fire"
				out.append(m)
		"heal":
			for k in meter_heal:
				var m: Dictionary = meter_heal[k].duplicate()
				m["tag"] = k
				m["el"] = "holy"
				out.append(m)
		"party":
			return meter_party_rows()
		_:

			if meter_focus >= 0 and meter_focus < meter_hero.size() and heroes.size() > 1\
			and (meter_focus >= heroes.size() or heroes[meter_focus] != player):
				for t in meter_hero[meter_focus]:
					var m: Dictionary = meter_hero[meter_focus][t].duplicate()
					m["tag"] = t
					out.append(m)
			else:
				return meter_sorted()
	out.sort_custom( func(a, b): return a.dmg > b.dmg)
	return out




func heal_label(tag: String) -> String:
	var names: = {"potion": tr("Pociones"), "rice_cake": tr("Rice Cake"), "gospel": tr("Gospel"), "homun": tr("Homúnculo"), 
		"pet": tr("Mascota"), "self": tr("Regeneración y otros"), "other": tr("Otros"), 
		"vampire_blood": tr(str(GameData.SETS.vampire_blood.name))}
	return str(names[tag]) if names.has(tag) else meter_label(tag)


func taken_label(key: String) -> String:
	if key == "shots":
		return tr("Proyectiles y hechizos")
	if key == "mechanics":
		return tr("Mecánicas")
	var mech: = key.begins_with("mechanics:")
	var id: = key.trim_prefix("mechanics:")
	var n: = tr(str(GameData.MONSTERS[id].name)) if GameData.MONSTERS.has(id) else id
	return tr("%s (mecánicas)") % n if mech else n



func meter_sorted() -> Array:
	var out: = []
	for t in meter:
		var m: Dictionary = meter[t].duplicate()
		m["tag"] = t
		out.append(m)
	out.sort_custom( func(a, b): return a.dmg > b.dmg)
	return out


func meter_label(tag: String) -> String:
	for dot in METER_DOTS:
		if tag.begins_with(dot + ":"):

			var fmt: = tr("Veneno de %s") if dot == "poison" else (tr("Quemadura de %s") if dot == "burn" else tr("Sangrado de %s"))
			return fmt % meter_label(tag.trim_prefix(dot + ":"))
	if tag.begins_with("hero:"):
		return hero_meter_name(int(tag.trim_prefix("hero:")))
	if tag == "basic":
		return tr("Ataque básico")
	if tag == "yggdrasil":
		return tr("Yggdrasil Leaf")
	if tag == "aegis":
		return tr("Égida")
	if tag == "grasshopper":
		return tr("Contraataque")
	if tag == "nine_tail":
		return tr("Nine Tail Dish")
	if tag == "burst":
		return tr("Destroyer")
	if tag == "gungnir":
		return tr("Juicio de Odín")
	if tag == "thor_bolt":
		return tr("Ira de Thor")
	if tag == "poison":
		return tr("Veneno")
	if tag == "burn":
		return tr("Quemadura")
	if tag == "bleed":
		return tr("Sangrado")
	if GameData.UNIQUE_TAGS.has(tag):
		return tr(str(GameData.ITEMS[GameData.UNIQUE_TAGS[tag]].name))
	if tag.begins_with("toy_") and GameData.MORROC_TOYS.has(tag.trim_prefix("toy_")):
		return tr(str(GameData.MORROC_TOYS[tag.trim_prefix("toy_")].name))
	if tag.begins_with("pet:"):
		var pid: = tag.trim_prefix("pet:").get_slice(":", 0)

		var echo: = tag.trim_prefix("pet:").get_slice(":", 1)
		if GameData.SKILLS.has(echo):
			return tr("Memoria: %s") % tr(str(GameData.SKILLS[echo].name))
		return tr("Mascota: %s") % (tr(str(GameData.PETS[pid].name)) if GameData.PETS.has(pid) else pid)
	if tag.begins_with("proc:"):
		var id: = tag.trim_prefix("proc:").trim_suffix("@hit")
		var shown: = tr(GameData.SKILLS[id].name) if GameData.SKILLS.has(id) else id
		return (tr("%s (auto, al recibir)") if tag.ends_with("@hit") else tr("%s (auto)")) % shown
	return tr(GameData.SKILLS[tag].name) if GameData.SKILLS.has(tag) else tag


func meter_icon(tag: String) -> Texture2D:
	for dot in METER_DOTS:
		if tag.begins_with(dot + ":"):
			return meter_icon(tag.trim_prefix(dot + ":"))
	var path: = ""
	if tag == "basic":
		var w = player.equipment.slots.weapon if player != null else null
		if w != null:
			path = "res://assets/ro/ui/skin/item_icons/%s.png" % Equipment.item_def(w).icon
	elif tag == "yggdrasil":
		path = "res://assets/ro/ui/skin/item_icons/yggdrasil_leaf.png"
	elif tag == "burst":
		path = "res://assets/ro/ui/skin/item_icons/destroyer.png"
	elif tag == "gungnir":
		path = "res://assets/ro/ui/skin/item_icons/gungnir.png"
	elif tag == "thor_bolt":
		return UiKit.skill_icon("jupitel_thunder")
	elif tag == "grasshopper":
		path = "res://assets/ro/ui/skin/item_icons/dish_fried_grasshopper.png"
	elif tag == "poison":
		return UiKit.skill_icon("envenom")
	elif tag == "burn":
		return UiKit.skill_icon("fire_bolt")
	elif tag == "bleed":
		return UiKit.skill_icon("sonic_blow")
	elif tag == "ka_kaite" or tag == "soul_chain":
		return UiKit.skill_icon("esma")
	elif tag == "kaite_wave":
		return UiKit.skill_icon("kaite")
	elif GameData.UNIQUE_TAGS.has(tag):
		path = "res://assets/ro/ui/skin/item_icons/%s.png" % GameData.ITEMS[GameData.UNIQUE_TAGS[tag]].icon
	elif tag.begins_with("toy_") and GameData.MORROC_TOYS.has(tag.trim_prefix("toy_")):
		return UiKit.skill_icon(str(GameData.MORROC_TOYS[tag.trim_prefix("toy_")].icon))
	else:
		return UiKit.skill_icon(tag.trim_prefix("proc:").trim_suffix("@hit"))
	return load(path) as Texture2D if path != "" and ResourceLoader.exists(path) else null



var _hit_sound_at: = 0
func _hit_sound(element: String) -> void :
	var now: = Time.get_ticks_msec()
	if now - _hit_sound_at < 70:
		return
	_hit_sound_at = now
	var key: = "enemy_hit_normal%d" % randi_range(1, 4)
	if element == "fire":
		key = "enemy_hit_fire%d" % randi_range(1, 2)
	elif element == "wind":
		key = "enemy_hit_wind%d" % randi_range(1, 2)
	play_sound(key, 0.0, -9.0)




func apply_poison(e: Enemy, dps: float, duration: float, times: = 1) -> void :
	if e.dead or dps <= 0.0:
		return


	var src: = acting_hero()
	var doses: = times * (1 + int(src.effects.get("poison_stack", 0.0)) if src != null else 1)
	var cap: = roundi(GameData.POISON_MAX_STACKS * (1.0 + float(src.effects.get("poison_cap", 0.0)))) if src != null else GameData.POISON_MAX_STACKS
	var on: = e.poison_time > 0.0

	var spill: = (e.poison_stacks + doses - cap) if on else 0
	e.poison_stacks = mini(cap, e.poison_stacks + doses) if on else mini(cap, doses)
	if spill > 0 and not _poison_spilling:
		_poison_spill(e, dps, duration, cap, mini(spill, GameData.POISON_SPILL_MAX))








	var eff: = dps * _poison_mult(src, damage_tag)
	if not on or eff >= float(e.get_meta("poison_eff", 0.0)):
		e.poison_dps = dps
		e.poison_tag = damage_tag
		e.poison_by = damage_by
		e.set_meta("poison_eff", eff)
	e.poison_time = maxf(e.poison_time, duration)
	if not poisoned.has(e):
		poisoned.append(e)
		e._update_tint()
	_poison_count(e)




var _poison_spilling: = false


func _poison_spill(e: Enemy, dps: float, duration: float, cap: int, n: int) -> void :
	_poison_spilling = true
	for o in nearest_enemies(e.position, GameData.POISON_SPILL_RANGE, 6):
		if n <= 0:
			break
		if o == e or o.dead or o.prop != "" or (o.poison_time > 0.0 and o.poison_stacks >= cap):
			continue
		apply_poison(o, dps, duration, 1)
		n -= 1
	_poison_spilling = false




func _poison_mult(src: Player, tag: String) -> float:
	if src == null:
		return 1.0
	return src.basic_mult if tag in ["poison", "burn", "bleed", "basic"] else src.skill_mult_for(tag)





func _poison_count(e: Enemy) -> void :
	var cap: = float(GameData.POISON_MAX_STACKS)
	var by: Player = e.poison_by if hero_valid(e.poison_by) else player
	if by != null:
		cap *= 1.0 + float(by.effects.get("poison_cap", 0.0))
	StatusMarks.set_mark(e, "poison", e.poison_stacks, roundi(cap))
	e._update_tint()


func _poison_count_clear(e: Enemy) -> void :
	StatusMarks.clear_mark(e, "poison")








var _hint_skills: = -1


func _toggle_hint_tick() -> void :
	if player == null or player.skills.size() == _hint_skills:
		return
	_hint_skills = player.skills.size()
	var id: = player.f_skill()
	if id == "":
		return
	var base: = player.base_skill(id)
	var seen: Array = Save.setting("f_hints", [])
	if seen.has(base):
		return
	seen.append(base)
	Save.set_setting("f_hints", seen)

	hud.announce(tr(str(GameData.SKILLS[base].name)), Color(1.0, 0.85, 0.4), 
		tr("Pulsa (F) para pausarla o volver a activarla cuando quieras"))


func skill_switch(id: String, all: = false) -> void :

	if id == "u_overload" and player != null:
		if net.is_client():
			net.send_skill_cmd(id, false)
		else:
			Uniques.overload_fire(self, player)
		return
	if player == null or not player.skills.has(id):
		return

	if net.is_client():
		net.send_skill_cmd(id, all)
		if player.is_hold(id):
			return
	hero_skill_switch(player, id, all)




func hero_skill_switch(h: Player, id: String, all: = false) -> void :
	if id == "u_overload":
		if h != null and not net.is_client():
			Uniques.overload_fire(self, h)
		return
	if h == null or not h.skills.has(id):
		return
	if h.is_hold(id):
		if not net.is_client():
			h.use_hold(self, id)
		return
	if not h.is_toggle(id):
		return
	var turn_off: = not h.is_off(id)
	var ids: Array = h.skills.keys().filter( func(k): return h.is_toggle(k)) if all else [id]
	for k in ids:
		if turn_off:
			h.skill_off[Player.base_skill(k)] = true
		else:
			h.skill_off.erase(Player.base_skill(k))



	if turn_off and h.blinking > 0.0 and ids.any( func(k): return str(GameData.SKILLS[k].type) == "backstab"):
		h.blink_cut = true
		h.blinking = 0.0
	toggle_pop(h, Player.base_skill(id), not turn_off)




var _toggle_icons: = {}
func toggle_pop(h: Player, id: String, on: bool) -> void :
	var key: = "%s:%s" % [id, on]
	if not _toggle_icons.has(key):
		_toggle_icons[key] = _toggle_icon(id, on)
	var s: = Sprite3D.new()
	s.texture = _toggle_icons[key]
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 18
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.pixel_size = 0.022
	fx_root.add_child(s)
	s.global_position = h.position + Vector3(0, h.visual.height() + 1.1, 0)
	s.scale = Vector3.ONE * 0.4
	var tw: = s.create_tween()
	tw.tween_property(s, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.55)
	tw.tween_property(s, "modulate:a", 0.0, 0.3)
	tw.parallel().tween_property(s, "position:y", s.position.y + 0.5, 0.3)
	tw.tween_callback(s.queue_free)
	play_sound("ui_click" if on else "guard_block", 0.0, -3.0)




func _toggle_icon(id: String, on: bool) -> Texture2D:
	var n: = 64
	var img: = Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c: = Vector2(n, n) * 0.5 - Vector2(0.5, 0.5)
	var col: = Color(0.35, 0.95, 0.45) if on else Color(1.0, 0.25, 0.2)
	for y in n:
		for x in n:
			var d: = Vector2(x, y).distance_to(c)
			if d <= 30.0:
				img.set_pixel(x, y, Color(0.06, 0.07, 0.12, 0.85))
	var icon: = UiKit.skill_icon(id)
	if icon != null:
		var ii: = RoAssets.tex_image(icon)
		ii.convert(Image.FORMAT_RGBA8)
		ii.resize(36, 36, Image.INTERPOLATE_NEAREST)
		if not on:
			for y in ii.get_height():
				for x in ii.get_width():
					var p: = ii.get_pixel(x, y)
					var g: = p.r * 0.3 + p.g * 0.59 + p.b * 0.11
					ii.set_pixel(x, y, Color(g, g, g, p.a))
		img.blend_rect(ii, Rect2i(0, 0, 36, 36), Vector2i(14, 14))
	for y in n:
		for x in n:
			var v: = Vector2(x, y) - c
			var d: = v.length()
			var ring: = d >= 26.5 and d <= 31.0

			var slash: = not on and d < 27.0 and absf(v.x - v.y) / 1.414 < 2.6
			if ring or slash:
				img.set_pixel(x, y, col)
	return ImageTexture.create_from_image(img)



func switch_arrow(step: int) -> void :
	if not player.cycle_arrow(step):
		return

	if net.is_client():
		net.send_arrow(player.arrow_id)
	_announce_arrow()


func _announce_arrow() -> void :
	var a: Dictionary = player.ammo()[player.arrow_id]
	label_over(player, "%s  ·  %s" % [tr(a.name), tr(GameData.ELEMENT_NAMES[a.element])], Color(1, 0.95, 0.7))
	play_sound({"arrows": "bow", "kunai": "ninja_throw"}.get(player.def.get("ammo", ""), "gunfire"), 0.1, -12.0)



func _announce_ammo(got: String) -> void :
	var table: = player.ammo()
	if not table.has(got):
		return
	var how: = tr("Munición de %s infinita. Cámbiala con C / V.") if player.can_switch_ammo() else tr("Munición de %s infinita. Cámbiala con la ventana de Equipo (Q).")
	hud.announce("%s: %s" % [tr(GameData.AMMO_NAMES[player.def.ammo]), tr(table[got].name)], Color(1, 0.9, 0.6), 
		how % tr(GameData.ELEMENT_NAMES[table[got].element]))



func party_announce(title: String, color: Color, sub: = "") -> void :
	hud.announce(title, color, sub)
	net.announce(title, color, sub)



func label_over(target: Node3D, text: String, color: Color) -> void :
	if net.recording():
		net.record(["l", net.ref_of(target), text, color])

	if Vfx.hidden():
		return
	var l: = Label3D.new()
	l.text = text
	l.font = UiKit.FONT_TITLE
	l.font_size = 40
	l.pixel_size = 0.006
	l.outline_size = 10
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 16
	l.outline_render_priority = 15
	l.position = target.position + Vector3(0, 2.4, 0)
	fx_root.add_child(l)
	var tw: = l.create_tween()
	tw.tween_property(l, "position:y", l.position.y + 0.6, 0.9)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.9).set_delay(0.5)
	tw.tween_callback(l.queue_free)







static func mob_hit_kind(e: Enemy) -> int:
	if e == null or not is_instance_valid(e) or e.has_meta("training_hit"):
		return 0
	if e.is_boss or e.def.get("mvp", false):
		return 3
	return 2 if e.def.get("elite", false) else 1






func mob_hit_cap(kind: int) -> float:
	if kind <= 0:
		return INF
	var share: = GameData.mob_hit_share(danger)
	if tower != null:
		share = lerpf(share, 1.0, clampf(float(tower.eff()) / GameData.MOB_HIT_TOWER_FLOOR, 0.0, 1.0))
	elif endless:
		share += GameData.MOB_HIT_ENDLESS_STEP * _endless_count
	if kind >= 2:
		share *= GameData.MOB_HIT_TOUGH






	var past: = maxf(0.0, GameData.hell_level(danger) - 10.0) * GameData.HELL_HIT_STEP if tower == null else 0.0
	return minf(1.0, share) + past + GameData.OATH_HIT_STEP * oath_points()


func enemy_attack(e: Enemy, rng: Dictionary) -> void :
	var target: = e.hero_target.position if heroes.size() > 1 and hero_valid(e.hero_target) else player.position
	match str(rng.kind):
		"arrow":
			var dir: = ((target - e.position) * Vector3(1, 0, 1)).normalized()
			var speed: = float(rng.get("speed", 10.0))
			var life: = float(rng.range) / speed + 0.4
			var s: = _enemy_arrow(e.position + Vector3(0, 0.9, 0) + dir * 0.4, dir)
			enemy_shots.append({"node": s, "dir": dir, "speed": speed, "life": life, "damage": e.damage, "src": e, "mob": mob_hit_kind(e)})

			if net.recording():
				net.record(["ea", s.position, dir, speed, life])
		"fire_bolt":
			Vfx.telegraph_circle(fx_root, target, 1.3, 0.8)
			var dmg: = e.damage * 1.2
			var mob: = mob_hit_kind(e)
			get_tree().create_timer(0.8, false).timeout.connect( func():
				if not running:
					return
				_impact_flash("impact_fire", target)
				spawn_fx("firehit1", target, 0.5, 0.7)
				play_sound("fire_hit1", 0.1, -6.0)
				var landed: = false
				for h in heroes:
					if not h.downed and (h.position - target).length() < 1.3:
						hurt_what = "Fire Bolt"
						hurt_mob = mob
						h.take_damage(dmg, self)
						landed = true
				_shot_landed(e, landed))


func _update_enemy_shots(delta: float) -> void :
	for i in range(enemy_shots.size() - 1, -1, -1):
		var sh: = enemy_shots[i]
		var node: Sprite3D = sh.node
		node.position += sh.dir * sh.speed * delta
		_orient_arrow(node, node.position, sh.dir)
		sh.life -= delta
		var hit: = false
		for h in heroes:
			var to: = (h.position + Vector3(0, 0.9, 0)) - node.position
			if not h.downed and Vector2(to.x, to.z).length() < h.radius + 0.25:
				hit = true
				hurt_what = "Disparo"
				hurt_mob = int(sh.get("mob", 0))
				h.take_damage(sh.damage, self)
				play_sound("arrow_hit", 0.1, -8.0)
				break
		if hit or sh.life <= 0.0:
			_shot_landed(sh.get("src"), hit)
			node.queue_free()
			enemy_shots.remove_at(i)




func _shot_landed(e: Variant, landed: bool) -> void :
	if not is_instance_valid(e) or not (e is Enemy) or e.dead:
		return
	e.shots_missed = 0 if landed else e.shots_missed + 1




func apply_status(e: Enemy, kind: String, duration: float) -> void :
	if e == null or e.dead or duration <= 0.0:
		return
	if e.is_boss:

		stagger.add(self, e, duration)
		_boss_status_mark(e, kind, duration)
		return
	if stagger.elite(self, e):

		stagger.add(self, e, duration)
		return



	if e.status != "" or e.status_cd > 0.0:
		var stunned: = e.status == "stun" or (e.status == "" and e.status_cd_kind == "stun")
		if not (stunned and GameData.STATUS_COMBO.has(kind)):
			return
	if e.def.get("elite", false):
		duration *= 0.5

	duration *= cc_scale(e, "status")
	if duration <= 0.0:
		return
	var src: = acting_hero()
	var longer: = 1.0 + float(src.effects.get("status_time", 0.0)) if src != null else 1.0
	duration = minf(duration * longer, GameData.STATUS_MAX_TIME * longer)
	var fresh: = e.status != kind
	e.set_status(kind, duration)
	smoke_stats.status += 1
	if fresh:
		spawn_fx(STATUS_FX.get(kind, ""), e.position, 0.8, 1.0, e)
		play_sound(STATUS_SOUND.get(kind, ""), 0.15, -6.0)





func _boss_status_mark(e: Enemy, kind: String, duration: float) -> void :
	if not GameData.STATUS_COMBO.has(kind):
		return
	var fresh: = e.boss_mark != kind or e.boss_mark_until <= time
	e.boss_mark = kind
	e.boss_mark_until = time + minf(duration, GameData.STATUS_MAX_TIME) * 0.5
	if fresh:
		var icon_of: = {"stone": "stone_curse", "freeze": "frost_diver"}
		var key: = "boss_mark_until_icon"
		if e.has_meta(key):
			var old = e.get_meta(key)
			if old != null and is_instance_valid(old):
				old.queue_free()
			e.remove_meta(key)
		_skill_mark(e, str(icon_of[kind]), "boss_mark_until", 0.95)








func cc_scale(e: Enemy, family: String) -> float:
	if not (e.is_boss or e.feroz or e.def.get("elite", false)):
		return 1.0
	var dr: Array = e.cc_dr.get(family, [0, 0.0])
	var n: = int(dr[0]) if clock < float(dr[1]) else 0
	var share: float = GameData.CC_DR[mini(n, GameData.CC_DR.size() - 1)]
	if share <= 0.0:
		side_word(e, tr("Inmune"), Color(0.9, 0.9, 0.95))
		return 0.0
	e.cc_dr[family] = [n + 1, clock + (GameData.CC_DR_RESET_SNARE if family == "snare" else GameData.CC_DR_RESET)]
	return share




func cc_immune(e: Enemy, family: String) -> bool:
	if not (e.is_boss or e.feroz or e.def.get("elite", false)):
		return false
	var dr: Array = e.cc_dr.get(family, [0, 0.0])
	var n: = int(dr[0]) if clock < float(dr[1]) else 0
	return GameData.CC_DR[mini(n, GameData.CC_DR.size() - 1)] <= 0.0





func blind_enemy(e: Enemy, duration: float, bosses: = false) -> void :
	if e == null or e.dead or duration <= 0.0 or (e.is_boss and not bosses):
		return
	var fresh: = e.blind_time <= 0.0
	e.blind_time = maxf(e.blind_time, duration * (0.5 if e.is_boss else 1.0))
	if not fresh:
		return
	Vfx.burst(fx_root, e.position + Vector3(0, 0.6, 0), 0.8, Color(0.2, 0.1, 0.32))
	if e.is_boss:
		side_word(e, TranslationServer.translate("¡Ciego!"), Color(0.75, 0.6, 1.0))



func try_status(e: Enemy, sk: Dictionary, chance: float) -> void :

	if chance > 0.0:
		chance += float(acting_hero().effects.get("status_chance", 0.0))
	if sk.has("status") and chance > 0.0 and randf() < chance:
		apply_status(e, sk.status, float(sk.get("status_time", 2.0)) * acting_hero().duration_mult)




func _update_poison(delta: float) -> void :
	for i in range(poisoned.size() - 1, -1, -1):
		var e = poisoned[i]
		if not is_instance_valid(e):
			poisoned.remove_at(i)
			continue
		if e.dead:
			poisoned.remove_at(i)
			if e.poison_time > 0.0 and e.poison_stacks > 0:
				_poison_pop(e)
			continue
		e.poison_time -= delta
		e.poison_tick -= delta
		if e.poison_tick <= 0.0:
			e.poison_tick += 0.5
			damage_by = e.poison_by
			_poison_hit(e, 1.0, e.poison_tag)
			if not e.dead and e.poison_stacks >= GameData.POISON_FUME_AT and _poison_fx_ok(e.poison_by):
				var keep: = hero_fx_begin(e.poison_by)
				spawn_fx("poison", e.position + Vector3(0, 0.4, 0), (0.3 + 0.006 * mini(e.poison_stacks, 40)) * (1.5 if e.is_boss else 1.0), 0.55)
				hero_fx_end(keep)
		if e.poison_time <= 0.0 and i < poisoned.size():
			poisoned.remove_at(i)
			e._update_tint()
			_poison_count_clear(e)




var judged: Array = []


func _judge(e: Enemy, most: int) -> void :
	if clock - e.judgment_seen >= GameData.JUDGMENT_FADE:
		e.judgment = 0
	e.judgment_seen = clock
	if e.judgment >= most or clock - e.judgment_at < 1.0 / GameData.JUDGMENT_RATE:
		return
	e.judgment_at = clock
	e.judgment += 1
	if not judged.has(e):
		judged.append(e)
	StatusMarks.set_mark(e, "judgment", e.judgment, most)

	if e.judgment == most and _poison_fx_ok(damage_by):
		var keep: = hero_fx_begin(damage_by)
		Vfx.ring(fx_root, e.position, 1.3 if e.is_boss else 0.9, GameData.JUDGMENT_COLOR, 0.35)
		hero_fx_end(keep)



func _update_judgment() -> void :
	for i in range(judged.size() - 1, -1, -1):
		var e = judged[i]
		if not is_instance_valid(e) or e.dead:
			judged.remove_at(i)
			continue
		if clock - e.judgment_seen >= GameData.JUDGMENT_FADE:
			e.judgment = 0
			judged.remove_at(i)
			StatusMarks.clear_mark(e, "judgment")





func _poison_pop(e: Enemy) -> void :
	var stacks: = e.poison_stacks
	e.poison_time = 0.0
	e.poison_stacks = 0
	if _poison_fx_ok(e.poison_by):
		var keep: = hero_fx_begin(e.poison_by)
		var h: float = e.visual.height() if e.visual != null else 1.2
		Vfx.venom_spray(fx_root, e.position, h * 0.5, 1.4 if e.is_boss else (0.7 + 0.015 * mini(stacks, 40)))
		hero_sound("bleed_squish", 0.08, -7.0, randf_range(1.3, 1.5))
		hero_fx_end(keep)







func hero_fx_begin(by) -> Array:
	var keep: = [Vfx.dim, Vfx.hero, damage_by]
	Vfx.hero = true
	Vfx.dim = hero_fx_alpha(by)
	damage_by = by if hero_valid(by) else null
	return keep


func hero_fx_end(keep: Array) -> void :
	Vfx.dim = float(keep[0])
	Vfx.hero = bool(keep[1])
	damage_by = keep[2]




func hero_sound(key: String, min_interval: = 0.08, volume_db: = 0.0, pitch: = -1.0) -> void :
	if not Vfx.hidden():
		play_sound(key, min_interval, volume_db, pitch)
	elif net.recording():
		net.record(["s", key, volume_db, pitch])



var _pfx_at: = 0.0
var _pfx_n: = 0




func _poison_fx_ok(by = null) -> bool:
	if hero_fx_alpha(by) <= 0.01 and not net.recording():
		return false
	if time - _pfx_at > 0.25:
		_pfx_at = time
		_pfx_n = 0
	_pfx_n += 1
	return _pfx_n <= 8




func _poison_hit(e: Enemy, ticks: float, tag: String, grow_max: = INF) -> void :

	var by: Player = e.poison_by if hero_valid(e.poison_by) else player

	var growth: = GameData.POISON_GROWTH + (float(by.effects.get("poison_growth", 0.0)) if by != null else 0.0)
	var stacked: = minf(minf(grow_max, GameData.poison_grow_top(float(by.effects.get("poison_cap", 0.0)) if by != null else 0.0)), pow(growth, e.poison_stacks - 1))
	var power: = ticks * (1.0 + float(by.effects.get("poison_dmg", 0.0)) if by != null else ticks)
	damage_enemy(e, e.poison_dps * GameData.POISON_FLAT * 0.5 * stacked * power, Vector3.ZERO, "poison", "poison", tag)




func poison_burst(e: Enemy, ticks: float, show: = true) -> void :
	if e.dead or e.poison_time <= 0.0 or e.poison_stacks <= 0:
		return
	var tag: = damage_tag
	var by: = damage_by
	_poison_hit(e, ticks, tag, GameData.POISON_BURST_GROW_MAX)
	damage_tag = tag
	damage_by = by
	if show and not e.dead:
		spawn_fx("poison", e.position + Vector3(0, 0.6, 0), 0.4 + 0.01 * mini(e.poison_stacks, 30), 0.7)



func gain_zeny(z: int, at: Vector3) -> void :
	if z <= 0:
		return
	add_zeny(z, "steal", acting_hero())
	number(at + Vector3(0, 1.4, 0), "+%d z" % z, Color(1, 0.85, 0.3))







func backstab_hit(p: Player, t: Enemy, dmg: float, area: float, sk: Dictionary, delay: float) -> void :
	var tag: = damage_tag
	var by: = damage_by
	_own_timer(delay, func():
		if not running or not is_instance_valid(t) or t.dead or not is_instance_valid(p):
			return
		damage_tag = tag
		damage_by = by
		var away: = ((t.position - p.position) * Vector3(1, 0, 1))
		away = away.normalized() if away.length_squared() > 0.001 else p.facing
		var spot: = t.position + away * (t.radius + 0.6)
		_shadow_clone(p, Vector3(spot.x, t.position.y, spot.z))
		var el: = Skills.melee_element(p, sk)
		damage_enemy(t, dmg, away * float(sk.get("knock", 2.0)), "skill", el)
		for e in enemies_in_radius(t.position, area):
			if e != t:
				damage_enemy(e, dmg * 0.5, Vector3.ZERO, "skill", el)

		if sk.has("hit_sprite"):
			sprite_fx(str(sk.hit_sprite), t.position + Vector3(0, 0.8, 0), 0, 1.0)
		else:
			spawn_fx("hit", t.position + Vector3(0, 0.7, 0), 0.9)
		play_sound(str(sk.get("hit_sound_bs", "back_stab")), 0.05, -4.0))








func blink_chain(p: Player, sk: Dictionary, dmg: float, area: float, count: int, reach: float) -> bool:
	var going: = Vector3(p._last_stick.x, 0.0, p._last_stick.y)
	going = going.normalized() if going.length() > 0.3 else Vector3.ZERO
	var first: = _blink_target(p.position, going, reach, {})
	if first == null:
		return false
	var ninja: bool = sk.has("hit_sprite")
	var col: Color = Color(0.55, 0.35, 0.95) if ninja else Color(0.95, 0.25, 0.3)
	p.blinking = GameData.BLINK_GAP * count + 0.25
	p.blink_cut = false
	p.skill_guard(0.15)
	play_skill_sound(sk)
	_blink_step(p, sk, first, dmg, area, count, reach, going, {}, 0, col, ninja)
	return true




func _blink_target(from: Vector3, going: Vector3, reach: float, hit: Dictionary) -> Enemy:
	var best: Enemy = null
	var best_d: = INF
	for e in enemies_in_radius(from, reach):
		if e.dead or hit.has(e) or e.prop != "":
			continue
		var to: = (e.position - from) * Vector3(1, 0, 1)
		var d: = to.length()
		if going != Vector3.ZERO and d > 0.4 and to.normalized().dot(going) < 0.35:
			continue
		if d < best_d:
			best_d = d
			best = e
	return best


func _blink_step(p: Player, sk: Dictionary, t: Enemy, dmg: float, area: float, left: int, reach: float, 
		going: Vector3, hit: Dictionary, i: int, col: Color, ninja: bool) -> void :
	if not running or not hero_valid(p) or p.blink_cut or t == null or not is_instance_valid(t) or t.dead:
		p.blinking = minf(p.blinking, 0.1)
		return
	var old: = p.position
	var travel: = (t.position - old) * Vector3(1, 0, 1)
	travel = travel.normalized() if travel.length() > 0.05 else (going if going != Vector3.ZERO else p.facing)
	var spot: = t.position + travel * (t.radius + 0.7)
	if not map.is_walkable(spot):
		spot = t.position - travel * (t.radius + 0.5)

	_shadow_clone(p, old, col)
	_bounce_trace(old, spot, col.lightened(0.4))
	p.position = Vector3(spot.x, map.height_at(spot), spot.z)
	p.facing = - travel
	p.visual.face( - travel)
	p.play_combo( - travel, RoVisual.PC_ATTACK)
	var mult: = 1.0 + 0.18 * i


	var escalate: bool = sk.get("escalate", false)
	if escalate:

		var k: = mini(i, GameData.BACKSTAB_X_GROWTH_CAP)
		mult = pow(GameData.BACKSTAB_X_GROWTH, k)
		crit_bonus = GameData.BACKSTAB_X_CRIT * k
		crit_dmg_bonus = pow(GameData.BACKSTAB_X_CRIT_DMG, k)


	if int(hit.get(t, 0)) > 0:
		mult *= GameData.LG_BACKSTAB_REPEAT if sk.get("lone_repeat", false) else GameData.BS_REPEAT
	hit[t] = int(hit.get(t, 0)) + 1


	var fear: = float(p.effects.get("intimidate", 0.0))
	if fear > 0.0:
		t.fear_vuln = maxf(t.fear_vuln if t.fear_until > time else 0.0, fear)
		t.fear_until = time + GameData.INTIMIDATE_TIME
	damage_enemy(t, dmg * mult, travel * float(sk.get("knock", 2.0)), "skill", sk.get("element", "neutral"))
	for e in enemies_in_radius(t.position, area):
		if e != t and not e.dead:
			damage_enemy(e, dmg * mult * 0.5, Vector3.ZERO, "skill", sk.get("element", "neutral"))
	crit_bonus = 0.0
	crit_dmg_bonus = 1.0
	if escalate and i >= 2:

		Vfx.ring(fx_root, t.position + Vector3(0, 0.05, 0), 1.0 + 0.25 * i, Color(1.0, 0.35 - 0.04 * i, 0.2, 0.9), 0.3)
	if ninja:
		sprite_fx(str(sk.hit_sprite), t.position + Vector3(0, 0.8, 0), 0, 1.0 + 0.1 * i)
		spawn_fx("hit", t.position + Vector3(0, 0.7, 0), 0.7, 0.8)
		Vfx.ring(fx_root, t.position + Vector3(0, 0.05, 0), 1.3 + 0.2 * i, Color(0.45, 0.3, 0.9, 0.9), 0.25)
	else:
		spawn_fx("hit", t.position + Vector3(0, 0.7, 0), 1.0 + 0.12 * i, 1.0)
		Vfx.burst(fx_root, t.position + Vector3(0, 0.6, 0), 0.9 + 0.15 * i, Color(1.0, 0.3, 0.3))
	play_sound(str(sk.get("hit_sound_bs", "back_stab")), 0.0, -3.0, 1.0 + 0.07 * i)
	shake(0.12 + 0.04 * i)
	if i > 0:
		_chain_word(p, i + 1, col)
	var next: = _blink_target(p.position, going if going != Vector3.ZERO else travel, reach, hit) if left > 1 else null



	if next == null and left > 1 and (sk.get("lone_repeat", false) or not ninja):
		next = t if is_instance_valid(t) and not t.dead else _blink_target(p.position, Vector3.ZERO, reach, {})
	if next == null:

		Vfx.ring(fx_root, p.position + Vector3(0, 0.05, 0), 2.2 + 0.3 * i, Color(col, 0.85), 0.35)
		if i >= 2:
			shake(0.35)
			hud.flash(Color(col, 1.0), 0.15)
		p.blinking = minf(p.blinking, 0.12)
		return
	var tag: = damage_tag
	var by: = damage_by
	_own_timer(GameData.BLINK_GAP, func():
		damage_tag = tag
		damage_by = by
		_blink_step(p, sk, next, dmg, area, left - 1, reach, going, hit, i + 1, col, ninja))



func _shadow_clone(p: Player, at: Vector3, col: = Color(0.42, 0.3, 0.75)) -> void :
	if p.visual == null or p.visual.sprite.texture == null:
		return
	var c: Sprite3D = p.visual.sprite.duplicate(0)
	c.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	c.transparent = true
	c.modulate = Color(col.darkened(0.3), 0.85 * Vfx.dim)
	fx_root.add_child(c)
	c.global_position = at + (p.visual.sprite.global_position - p.global_position)
	Vfx.column(fx_root, at, Color(0.6, 0.5, 1.0))
	var tw: = c.create_tween()
	tw.tween_interval(0.12)
	tw.tween_property(c, "modulate:a", 0.0, 0.3)
	tw.tween_callback(c.queue_free)








func fx_with(d: float, fn: Callable) -> void :
	var was: = Vfx.dim
	var was_hero: = Vfx.hero
	Vfx.dim = d
	Vfx.hero = true
	fn.call()
	Vfx.dim = was
	Vfx.hero = was_hero


func _own_timer(delay: float, fn: Callable) -> void :
	_sched.append([_sched_clock + delay, fn, Vfx.dim, Vfx.hero, damage_by])
var _sched: Array = []
var _sched_clock: = 0.0






var _num_batch: Array = []
var _num_mmi: MultiMeshInstance3D
var _num_buf: = PackedFloat32Array()
const NUM_GLYPHS_MAX: = 768
const NUM_GLYPHS_START: = 64


var _burst_mmi: MultiMeshInstance3D
var _burst_buf: = PackedFloat32Array()
const NUM_BURSTS_MAX: = 64


func _update_number_batch() -> void :
	var atlas: = RoAssets.glyph_atlas()
	if atlas.is_empty() or camera == null:
		return
	if _num_mmi == null or not is_instance_valid(_num_mmi):
		_num_mmi = _number_batch_node(atlas.tex, 17, NUM_GLYPHS_START)
	var mm: = _num_mmi.multimesh
	if _num_buf.size() != NUM_GLYPHS_MAX * 20:
		_num_buf.resize(NUM_GLYPHS_MAX * 20)
	var star: = RoAssets.crit_stars()
	if star != null and (_burst_mmi == null or not is_instance_valid(_burst_mmi)):
		_burst_mmi = _number_batch_node(star, 15, NUM_BURSTS_MAX)
		_burst_buf.resize(NUM_BURSTS_MAX * 20)
	var rects: Dictionary = atlas.rects
	var asize: Vector2 = atlas.size
	var cb: = camera.global_basis
	var right: = cb.x
	var up: = cb.y
	var back: = cb.z
	var n: = 0
	var bursts: = 0
	var now: = Time.get_ticks_msec()
	var keep: = 0
	for l in _num_batch:
		if not is_instance_valid(l):
			continue
		_num_batch[keep] = l
		keep += 1
		var s: = l as Sprite3D
		var col: = s.modulate
		if col.a <= 0.003:
			continue
		var digits: = str(s.get_meta("digits", ""))


		var total_w: = 1
		var total_h: = 0
		for c in digits:
			var r: Rect2i = rects.get(c, Rect2i())
			total_w += r.size.x - 1
			total_h = maxi(total_h, r.size.y)
		var k: = s.pixel_size * s.scale.x
		var center: = s.global_position
		var x: = 0
		for c in digits:
			if n >= NUM_GLYPHS_MAX:
				break
			var r: Rect2i = rects.get(c, Rect2i())
			var gx: = (x + r.size.x * 0.5 - total_w * 0.5) * k
			var gy: = - ((total_h - r.size.y) + r.size.y * 0.5 - total_h * 0.5) * k
			var p: = center + right * gx + up * gy
			var bx: = right * (r.size.x * k)
			var by: = up * (r.size.y * k)
			var o: = n * 20
			_num_buf[o] = bx.x
			_num_buf[o + 1] = by.x
			_num_buf[o + 2] = back.x
			_num_buf[o + 3] = p.x
			_num_buf[o + 4] = bx.y
			_num_buf[o + 5] = by.y
			_num_buf[o + 6] = back.y
			_num_buf[o + 7] = p.y
			_num_buf[o + 8] = bx.z
			_num_buf[o + 9] = by.z
			_num_buf[o + 10] = back.z
			_num_buf[o + 11] = p.z
			_num_buf[o + 12] = col.r
			_num_buf[o + 13] = col.g
			_num_buf[o + 14] = col.b
			_num_buf[o + 15] = col.a
			_num_buf[o + 16] = r.position.x / asize.x
			_num_buf[o + 17] = r.position.y / asize.y
			_num_buf[o + 18] = r.size.x / asize.x
			_num_buf[o + 19] = r.size.y / asize.y
			n += 1
			x += r.size.x - 1
		if star != null and bursts < NUM_BURSTS_MAX and s.has_meta("burst"):
			_write_burst(bursts, s, star, k * maxf(total_w * 1.2 / (star.get_width() * 0.5), total_h * 2.3 / star.get_height()), 
				(now - int(s.get_meta("born", now))) * 0.001, right, up, back)
			bursts += 1
	_num_batch.resize(keep)


	if n > mm.instance_count:
		mm.visible_instance_count = 0
		mm.instance_count = mini(NUM_GLYPHS_MAX, maxi(n * 2, NUM_GLYPHS_START))
	if n > 0:
		mm.buffer = _num_buf.slice(0, mm.instance_count * 20)
	mm.visible_instance_count = n
	if _burst_mmi != null:
		if bursts > 0:
			_burst_mmi.multimesh.buffer = _burst_buf
		_burst_mmi.multimesh.visible_instance_count = bursts




func _magic_hit(source: String, tag: String) -> bool:
	if source == "basic":
		return false
	if tag in GameData.MAGIC_TAGS:
		return true
	var id: = GameData.skill_of_tag(tag)
	return id != "" and bool(GameData.SKILLS[id].get("magic", false))





func _write_burst(i: int, s: Sprite3D, star: Texture2D, fit: float, age: float, right: Vector3, up: Vector3, back: Vector3) -> void :
	var kind: = str(s.get_meta("burst"))
	var lethal: = kind == "lethal"


	var magic: bool = kind == "magic" or bool(s.get_meta("crit_magic", false))
	var col: Color = {"lethal": Color(0.85, 0.3, 0.3), "ultra": Color(1.0, 0.62, 0.25)}.get(kind, Color.WHITE)

	if magic and kind in ["lethal", "ultra"]:
		col = Color(0.45, 0.5, 1.0) if kind == "lethal" else Color(0.75, 0.9, 1.0)
	var u0: = 0.5 if magic else 0.0

	if kind in ["phys", "magic"]:
		fit *= 0.85
	if lethal and age < 0.18:
		col = Color.WHITE.lerp(col, age / 0.18)
	if lethal and age < 0.54:
		fit *= 1.0 + 0.18 * absf(sin(age * PI / 0.18))
	var turn: = deg_to_rad(30.0) * maxf(0.0, 1.0 - age / 0.12)
	var bx: = (right * cos(turn) + up * sin(turn)) * star.get_width() * 0.5 * fit
	var by: = (up * cos(turn) - right * sin(turn)) * star.get_height() * fit
	var p: = s.global_position
	var o: = i * 20
	var row: = [bx.x, by.x, back.x, p.x, bx.y, by.y, back.y, p.y, bx.z, by.z, back.z, p.z, 
		col.r, col.g, col.b, s.modulate.a, u0, 0.0, 0.5, 1.0]
	for j in 20:
		_burst_buf[o + j] = row[j]


func _number_batch_node(tex: Texture2D, priority: int, count: int) -> MultiMeshInstance3D:
	var quad: = QuadMesh.new()
	quad.size = Vector2.ONE
	var sh: = Shader.new()
	sh.code = "shader_type spatial;\r\nrender_mode unshaded, cull_disabled, depth_test_disabled, blend_mix;\r\nuniform sampler2D atlas : filter_nearest, source_color;\r\nvarying vec4 tint;\r\nvoid vertex() {\r\n\tUV = INSTANCE_CUSTOM.xy + UV * INSTANCE_CUSTOM.zw;\r\n\ttint = COLOR;\r\n}\r\nvoid fragment() {\r\n\tvec4 t = texture(atlas, UV);\r\n\tALBEDO = t.rgb * tint.rgb;\r\n\tALPHA = t.a * tint.a;\r\n}"












	var mat: = ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("atlas", tex)
	mat.render_priority = priority
	quad.material = mat
	var mm: = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = quad
	mm.instance_count = count
	mm.visible_instance_count = 0
	var mmi: = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.custom_aabb = AABB(Vector3(-400, -50, -400), Vector3(800, 100, 800))
	fx_root.add_child(mmi)
	return mmi



func _run_sched(delta: float) -> void :
	if _sched.is_empty():
		return
	_sched_clock += delta
	var due: Array = []
	var keep: = 0
	for e in _sched:
		if float(e[0]) <= _sched_clock:
			due.append(e)
		else:
			_sched[keep] = e
			keep += 1
	if due.is_empty():
		return
	_sched.resize(keep)
	if due.size() > 1:
		due.sort_custom( func(a, b): return float(a[0]) < float(b[0]))
	for e in due:
		Vfx.dim = e[2]
		Vfx.hero = e[3]
		damage_by = e[4]
		(e[1] as Callable).call()
	damage_by = null
	Vfx.dim = 1.0
	Vfx.hero = false


func delayed_aoe(at: Vector3, radius: float, dmg: float, delay: float, sk: Dictionary, with_sound: bool) -> void :
	var tag: = damage_tag
	var by: = damage_by





	var lead: = float(sk.get("fx_lead", 0.0))
	if lead > 0.0 and str(sk.get("fx", "")) != "":
		_own_timer(maxf(0.0, delay - lead), func():
			if not running:
				return
			var e: = spawn_fx(str(sk.fx), at, minf(radius / 2.5, GameData.AOE_FX_MAX), float(sk.get("fx_intensity", 1.0)))
			if e != null:
				e._time = maxf(0.0, lead - delay))
	_own_timer(delay, func():
		if not running:
			return
		damage_tag = tag
		damage_by = by
		var fx: String = sk.get("fx", "") if lead <= 0.0 else ""
		if sk.has("hit_sprite"):

			for k in int(sk.get("hit_sprites", 3)):
				var off: = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)) * radius * 0.6
				sprite_fx(str(sk.hit_sprite), at + off + Vector3(0, 0.5, 0), 0, float(sk.get("hit_sprite_size", 0.55)))
			if fx != "":
				spawn_fx(fx, at, minf(radius / 2.5, GameData.AOE_FX_MAX), float(sk.get("fx_intensity", 1.0)))
		elif fx == "" or spawn_fx(fx, at, minf(radius / 2.5, GameData.AOE_FX_MAX), float(sk.get("fx_intensity", 1.0))) == null:
			if fx == "" and lead <= 0.0:
				Vfx.burst(fx_root, at, radius, sk.color)
		if with_sound:
			play_skill_sound(sk)
		if sk.get("hit_ring", false):
			Vfx.ring(fx_root, at, radius * 1.2, sk.color, 0.25)
		if sk.get("hit_column", false):
			Vfx.column(fx_root, at, sk.color)
		if sk.get("impact_fx", false):
			Vfx.strike_circle(fx_root, at, radius, sk.color)
			Vfx.ring(fx_root, at, radius * 1.3, Color(sk.color).lightened(0.3), 0.3)
			shake(0.15)
		_rebuild_grid()
		var slow: = float(sk.get("slow", 0.0))


		var mark: = float(sk.get("mark", 0.0)) + (float(damage_by.effects.get("eswoo_vuln", 0.0)) if hero_valid(damage_by) else 0.0)
		var weak: = float(sk.get("weak", 0.0))
		var mark_t: = maxf(slow, float(sk.get("mark_time", 0.0)))
		if sk.get("shrink", false) and net.recording():
			net.record(["es", at, radius, slow])

		var el: = Skills.element_of(damage_by, sk) if hero_valid(damage_by) else str(sk.get("element", "neutral"))
		for e in enemies_in_radius(at, radius):
			damage_enemy(e, dmg, Vector3.ZERO, "skill", el)
			try_status(e, sk, float(sk.get("status_chance_now", sk.get("status_chance", 0.0))))
			if sk.get("web_fire", false):
				e.web_until = maxf(e.web_until, time + GameData.WEB_FIRE_TIME)
			if slow > 0.0:
				e.slow_time = slow
				if sk.get("shrink", false):
					e.shrink(slow)
				if mark > 0.0:
					e.taunt_vuln = maxf(e.taunt_vuln if clock < e.taunt_until else 0.0, mark)
					e.taunt_until = maxf(e.taunt_until, clock + mark_t)
				if weak > 0.0:
					var fresh: = clock >= e.weak_until
					e.weak_mult = maxf(e.weak_mult if not fresh else 0.0, weak)
					e.weak_until = maxf(e.weak_until, clock + mark_t)

					if fresh and (e.is_boss or bool(e.def.get("elite", false))):
						bound_seal(e, mark_t)
			if sk.has("poison"):
				apply_poison(e, dmg * GameData.POISON_DPS, float(sk.poison))

		if sk.has("cloud"):
			ground_zone(at, sk, radius, dmg * float(sk.cloud_dmg), 0.0, float(sk.cloud)))





func place_trap(at: Vector3, radius: float, dmg: float, sk: Dictionary, ghost: = false) -> void :
	if net.recording() and not ghost:
		var sid: = skill_id_of(sk)
		if sid != "":
			net.record(["tp", at, sid])
	if ghost:

		var g: = _trap_sprite(at, sk)
		_ghost_traps.append(g)

		var ref: WeakRef = weakref(g)
		get_tree().create_timer(GameData.TRAP_LIFE, false).timeout.connect( func():
			var n = ref.get_ref()
			for i in range(_ghost_traps.size() - 1, -1, -1):
				if not is_instance_valid(_ghost_traps[i]) or _ghost_traps[i] == n:
					_ghost_traps.remove_at(i)
			if n != null:
				n.queue_free())
		return

	var mine: = _traps.filter( func(t): return t.get("by") == damage_by)
	if mine.size() >= GameData.TRAP_MAX:
		_traps.erase(mine[0])
		_trap_gone(mine[0])
	if map != null:
		at.y = map.height_at(at)
	var s: = _trap_sprite(at, sk)


	if hero_valid(damage_by):
		dmg *= 1.0 + GameData.TRAP_LEVEL_SHARE * (GameData.proc_level_mult(damage_by.level) - 1.0)

		dmg *= (1.0 + float(damage_by.effects.get("trap_dmg", 0.0))) * GameData.TRAP_DMG_MULT
	_traps.append({"node": s, "at": at, "r": radius, "dmg": dmg, "sk": sk, "tag": damage_tag, "by": damage_by, "t": GameData.TRAP_LIFE})



var _ghost_traps: Array[Sprite3D] = []
func _trap_sprite(at: Vector3, sk: Dictionary) -> Sprite3D:
	if map != null:
		at.y = map.height_at(at)
	var s: = Sprite3D.new()
	var spr: = RoAssets.sprite([str(sk.trap)])
	s.texture = spr.get_frame(0, 0) if spr != null else RoAssets.placeholder(sk.color, 12, false)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	s.pixel_size = GameData.PIXEL_SIZE * float(sk.get("trap_size", 1.1))
	fx_root.add_child(s)
	s.global_position = at + Vector3(0, 0.25, 0)
	Vfx.ground_glow(s, Vector3(0, -0.2, 0), 0.6, Color(sk.color, 0.45))
	s.scale = Vector3.ONE * 0.3
	s.create_tween().tween_property(s, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return s





func _snare(t: Dictionary, caught: Array[Enemy], loud: bool) -> void :
	var sk: Dictionary = t.sk
	if loud:
		play_skill_sound(sk)
	spawn_fx("hit", t.at + Vector3(0, 0.4, 0), 0.8)
	if sk.has("pull"):
		for e in enemies_in_radius(t.at, float(sk.pull)):
			if not e.is_boss:
				e.knock += (t.at - e.position) * Vector3(1, 0, 1) * 6.0
	var n: = 0
	var most: = int(t.get("catch", sk.get("catch", 3)))
	for e in caught:
		if n >= most or e.dead or e.prop != "":
			continue
		var hold: = float(t.get("snare", sk.snare))
		if e.is_boss:
			if not sk.has("snare_boss"):
				continue
			hold *= float(sk.snare_boss)
		n += 1


		hold *= cc_scale(e, "snare")
		e.snare_time = maxf(e.snare_time, hold)
		damage_enemy(e, t.dmg, Vector3.ZERO, "skill", "neutral")

		if not e.dead:
			dots.bleed_on(self, e, t.dmg, damage_tag, acting_hero(), false, int(sk.bleed_stacks))
		if hold > 0.0:
			side_word(e, tr("¡Atrapado!"), Color(0.85, 0.85, 0.9))


func _trap_gone(t: Dictionary) -> void :
	if net.recording():
		net.record(["tg", t.at])
	var n: Node3D = t.node
	if is_instance_valid(n):
		var tw: = n.create_tween()
		tw.tween_property(n, "scale", Vector3.ONE * 0.01, 0.2)
		tw.tween_callback(n.queue_free)





func _trap_steps(t: Dictionary) -> bool:

	if t.get("boom", false):
		return true
	var near: = enemies_in_radius(t.at, GameData.TRAP_TRIGGER)
	if near.is_empty() or not t.sk.has("snare"):
		return not near.is_empty()
	for e in near:
		if e.is_boss and not t.sk.has("snare_boss"):
			continue
		if cc_immune(e, "snare"):
			continue
		return true
	return false




func detonate_traps(p: Player, from: Vector3, dir: Vector3, length: float, width: float) -> void :
	for t in _traps:
		if t.get("by") != p or t.get("boom", false):
			continue
		var rel: Vector3 = (t.at - from) * Vector3(1, 0, 1)
		var along: = rel.dot(dir)
		if along < 0.0 or along > length or (rel - dir * along).length() > width * 0.5 + 0.6:
			continue
		t["boom"] = true
		t["dmg"] = float(t.dmg) * GameData.SHARP_TRAP_MULT
		Vfx.burst(fx_root, t.at + Vector3(0, 0.4, 0), 1.2, Color(0.85, 0.95, 0.9))


func _update_traps(delta: float) -> void :
	for i in range(_traps.size() - 1, -1, -1):
		var t: Dictionary = _traps[i]
		t.t -= delta
		if t.t <= 0.0:
			_trap_gone(t)
			_traps.remove_at(i)
		elif _trap_steps(t):
			var keep: = damage_tag
			var keep_by: = damage_by
			damage_tag = t.tag
			damage_by = t.get("by")

			var now: = Time.get_ticks_msec() / 1000.0
			var loud: = now >= _trap_sound_at
			if loud:
				_trap_sound_at = now + 0.15
			var caught: = enemies_in_radius(t.at, t.r)
			for c in caught:
				hunter_mark(c)
			if t.sk.has("snare"):
				_snare(t, caught, loud)
			else:
				delayed_aoe(t.at, t.r, t.dmg, 0.0, t.sk, loud)

			if float(by_of(t).effects.get("trap_vuln", 0.0)) > 0.0:
				for e in caught:
					e.trapped_until = clock + GameData.TRAPPED_TIME
					e.trap_vuln = float(by_of(t).effects.get("trap_vuln", 0.0))
			damage_tag = keep
			damage_by = keep_by
			_traps.remove_at(i)


			if t.sk.has("snare") and is_instance_valid(t.node):
				if t.sk.has("jaws"):
					var node: = t.node as Sprite3D
					node.scale = Vector3(1.4, 0.5, 1.0)
					var snap: Tween = node.create_tween()
					snap.tween_property(node, "scale", Vector3(0.85, 1.2, 1.0), 0.07)
					snap.tween_property(node, "scale", Vector3.ONE, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				var tw: Tween = t.node.create_tween()
				tw.tween_interval(float(t.get("snare", t.sk.snare)) * 0.6)
				tw.tween_callback( func(): _trap_gone(t))
			elif is_instance_valid(t.node):
				t.node.queue_free()
				if net.recording():
					net.record(["tg", t.at])








func ground_zone(at: Vector3, sk: Dictionary, radius: float, dmg: float, heal: float, duration: float, 
		facing: = Vector3.ZERO, follow: Node3D = null, ghost: = false) -> void :




	var merge_id: = skill_id_of(sk) if sk.get("on_self", false) and follow == null and not ghost else ""
	if merge_id != "":
		for z in _zones:
			if str(z.get("merge", "")) == merge_id and z.get("by") == damage_by and clock - float(z.born) < GameData.ZONE_MERGE_TIME and (z.at as Vector3).distance_to(at) < radius * GameData.ZONE_MERGE_DIST:
				z.dmg = float(z.dmg) + dmg
				z.heal = float(z.heal) + heal
				z.t = maxf(float(z.t), duration)
				return


	if net.recording() and not ghost:
		var sid: = skill_id_of(sk)
		if sid != "":
			net.record(["gz", at, sid, radius, duration, facing, damage_by.slot if damage_by != null and is_instance_valid(damage_by) else -1])



	var shape: = str(sk.get("shape", "square"))
	var arm: = int(sk.get("arm", 1))
	var cell: = radius / (arm + 0.5)
	var cells: = {}
	for x in range( - arm, arm + 1):
		for y in range( - arm, arm + 1):
			var keep: = true
			match shape:
				"cross":
					keep = x == 0 or y == 0
				"gc":
					keep = x == 0 or y == 0 or (absi(x) <= 1 and absi(y) <= 1)
				"line":
					keep = y == 0
			if keep:
				cells[Vector2i(x, y)] = true
	var fwd: = facing.normalized() if facing.length_squared() > 0.0 else Vector3(0, 0, 1)
	var right: = Vector3(fwd.z, 0, - fwd.x) if facing.length_squared() > 0.0 else Vector3(1, 0, 0)
	var z: = {"at": at, "r": radius * 1.45, "dmg": dmg, "heal": heal, "t": duration, "tick": 0.05, 
		"every": float(sk.get("tick", 0.5)), "sk": sk, "tag": damage_tag, "nodes": [], "cells": cells, "cell": cell, 
		"fwd": fwd, "right": right}
	var fx_alpha: = pow(Vfx.dim, 1.6)






	var ally: = _foreign_fx()
	var look_key = [sk, ally]
	var share: = (2 if tower != null else 4) if ally else 1
	var alive: = _zone_looks.get(look_key, 0) as int
	_zone_looks[look_key] = alive + 1
	get_tree().create_timer(duration, false).timeout.connect( func():
		_zone_looks[look_key] = maxi(0, int(_zone_looks.get(look_key, 1)) - 1))


	var drawn: = not (ally and fx_alpha_party <= 0.01) and not Vfx.hidden()
	var animated: = alive * share < GameData.ZONE_FX_FULL
	_zone_relight(sk, at, cell, follow)
	var tiles: = []
	for c in cells:
		if not drawn or (alive * share >= GameData.ZONE_FX_TILES and c != Vector2i.ZERO):
			continue
		var p: Vector3 = at + right * (c.x * cell) + fwd * (c.y * cell)
		p.y = map.height_at(p) if map != null else at.y


		var soft: = shape != "gc"


		var cell_a: = (0.3 if sk.has("cloud") else 0.7) if soft else 0.9
		var tile: = Vfx._flat(fx_root, Vfx.soft_cell_texture() if soft else Vfx.square_texture(), p, 
			cell * (0.78 if soft else 0.48), Color(sk.color, cell_a))
		tile.render_priority = 3
		var base_a: = tile.modulate.a
		tile.modulate.a = 0.0
		var tw: = tile.create_tween()
		tw.tween_property(tile, "modulate:a", base_a, 0.12)
		tw.tween_property(tile, "modulate:a", base_a * 0.75, 0.35).set_trans(Tween.TRANS_SINE)
		tw.tween_property(tile, "modulate:a", base_a, 0.35).set_trans(Tween.TRANS_SINE)
		z.nodes.append(tile)
		tiles.append(tile)
		if not animated and c != Vector2i.ZERO:
			continue
		if sk.has("cell_sprite"):

			var flame: = _cell_sprite(str(sk.cell_sprite), p, fx_alpha)
			if flame != null:
				z.nodes.append(flame)
			continue


		if sk.get("fx_center", false) and c != Vector2i.ZERO:
			continue
		var e: = RoEffect.spawn(fx_root, str(sk.fx), p, float(sk.get("fx_size", 0.5)) * (1.5 if sk.get("fx_center", false) else 1.0))
		if e != null:
			e.loop = true
			e.intensity = float(sk.get("fx_intensity", 1.0)) * (1.0 if c == Vector2i.ZERO else 0.75) * fx_alpha
			z.nodes.append(e)
	if sk.has("center_fx"):
		spawn_fx(str(sk.center_fx), at, cell / 1.6, 0.45)
	if sk.has("cloud") and drawn:
		z.nodes.append_array(_venom_puffs(at, radius, duration, fx_alpha))
	if not tiles.is_empty():

		_lit_zones.append({"sk": sk, "at": at, "tiles": (z.nodes as Array).duplicate(), "follow": follow, 
			"offset": (at - follow.position) * Vector3(1, 0, 1) if follow != null else Vector3.ZERO})
	z["by"] = damage_by
	z["merge"] = merge_id


	z["born"] = clock
	if sk.has("acid"):
		z["acid"] = float(sk.get("acid_now", sk.acid))
	if follow != null:
		z["follow"] = follow
		z["offset"] = (at - follow.position) * Vector3(1, 0, 1)
	if ghost:

		get_tree().create_timer(duration, false).timeout.connect( func():
			for n in z.nodes:
				if is_instance_valid(n):
					var tw: Tween = n.create_tween()
					tw.tween_property(n, "scale", Vector3.ONE * 0.01, 0.25)
					tw.tween_callback(n.queue_free))
		return
	_zones.append(z)




func _venom_puffs(at: Vector3, radius: float, duration: float, alpha: float) -> Array:
	var out: = []


	var cols: = [Color(0.42, 0.58, 0.25), Color(0.45, 0.3, 0.52), Color(0.36, 0.5, 0.22)]
	var n: = 3 + int(radius * 0.6)
	for i in n:
		var s: = Sprite3D.new()
		s.texture = RoAssets.radial(Color.WHITE, 64)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 3
		var a: = TAU * i / n + randf_range(-0.4, 0.4)
		var d: = radius * (0.25 + 0.5 * sqrt(randf()))
		var p: = at + Vector3(cos(a) * d, 0, sin(a) * d)
		p.y = (map.height_at(p) if map != null else at.y) + randf_range(0.25, 0.7)
		s.position = p
		var size: = radius * randf_range(0.35, 0.55)
		s.pixel_size = size * 2.0 / 64.0
		var c: Color = cols[i % cols.size()]
		var top: = randf_range(0.18, 0.28) * alpha
		s.modulate = Color(c, 0.0)
		fx_root.add_child(s)

		var tw: = s.create_tween()
		tw.tween_property(s, "modulate:a", top, 0.35 + 0.05 * i)
		var sway: = s.create_tween().set_loops(maxi(1, ceili(duration / 2.4)))
		var drift: = Vector3(randf_range(-0.35, 0.35), randf_range(0.05, 0.2), randf_range(-0.35, 0.35))
		sway.tween_property(s, "position", p + drift, 1.2).set_trans(Tween.TRANS_SINE)
		sway.parallel().tween_property(s, "scale", Vector3.ONE * 1.15, 1.2).set_trans(Tween.TRANS_SINE)
		sway.tween_property(s, "position", p, 1.2).set_trans(Tween.TRANS_SINE)
		sway.parallel().tween_property(s, "scale", Vector3.ONE, 1.2).set_trans(Tween.TRANS_SINE)
		out.append(s)
	return out



var _zone_looks: = {}

var _lit_zones: = []






func _zone_relight(sk: Dictionary, at: Vector3, cell: float, follow: Node3D) -> void :
	var keep: = []
	for old in _lit_zones:
		var live: Array = (old.tiles as Array).filter( func(n): return is_instance_valid(n) and n.is_inside_tree())
		if live.is_empty():
			continue
		var fol = old.follow
		var where: Vector3 = (fol as Node3D).position + old.offset if fol != null and is_instance_valid(fol) else old.at
		if old.sk == sk and _flat_dist(where, at) < cell * 1.5:
			for n in live:
				if n is GeometryInstance3D:
					var tw: Tween = (n as Node3D).create_tween()
					tw.tween_property(n, "transparency", 1.0, 0.25)
					tw.tween_callback( func(): n.visible = false)
				else:
					n.visible = false
			continue
		old.tiles = live
		keep.append(old)
	_lit_zones = keep




func signum_crucis(p: Player, marked: Array, reach: float, frail: float, duration: float, sk: Dictionary) -> void :
	for e in marked:
		e.signum_frail = maxf(e.signum_frail, frail) if e.signum_until > time else frail
		e.signum_until = maxf(e.signum_until, time + duration)
		_skill_mark(e, "signum_crucis", "signum_until", 0.35)
		stagger.debuff(self, p, e, "signum")

	if reach > 0.0:
		spawn_fx("cross", p.position, 1.1, 0.6)
		Vfx.ring(fx_root, p.position, reach, sk.color, 0.6)
	var shown: = 0
	for e in marked:
		if shown >= 6 and not e.is_boss:
			continue
		shown += 1
		spawn_fx("holyhit", e.position + Vector3(0, 0.6, 0), 0.5 if not e.is_boss else 1.0, 0.7)






func charge_attack(p: Player, e: Enemy, dmg: float, reach: float, width: float, sk: Dictionary, chain: int) -> void :
	var from: = p.position
	var dist: = ((e.position - from) * Vector3(1, 0, 1)).length()
	var way: = ((e.position - from) * Vector3(1, 0, 1)).normalized()
	var to: = map.slide(from, way * maxf(0.0, dist - e.radius - 0.5))
	var hit_dmg: = dmg * (1.0 + clampf(dist / maxf(1.0, reach), 0.0, 1.0))
	p.start_dash(self, Vector3(to.x, map.height_at(to), to.z), clampf(dist / 30.0, 0.12, 0.35), 
		{"kind": "charge", "dmg": dmg * float(sk.get("path_share", 0.4)), "width": width, "knock": float(sk.get("knock", 10.0)) * 0.5, 
		"tag": damage_tag, "pose": RoVisual.PC_ATTACK, "color": Color(sk.color, 0.6), 
		"target": e, "hit_dmg": hit_dmg, "sk": sk, "chain": chain, "reach": reach, "power": clampf(dist / maxf(1.0, reach), 0.0, 1.0)})
	p.dash.hit[e] = true

	Vfx.strike_line(fx_root, from, way, dist, width, Color(1.0, 0.8, 0.35))
	Vfx.converge(fx_root, from + Vector3(0, 0.6, 0), 1.8, Color(1.0, 0.85, 0.5), 0.2)




func _charge_landed(p: Player, d: Dictionary) -> void :


	var t = d.get("target")
	var e: Enemy = t if is_instance_valid(t) else null
	var sk: Dictionary = d.get("sk", {})
	var power: = float(d.get("power", 0.5))
	var gold: = Color(1.0, 0.85, 0.45)
	if is_instance_valid(e) and not e.dead:
		var way: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
		damage_enemy(e, float(d.get("hit_dmg", 0.0)), way * float(sk.get("knock", 10.0)), "skill", p.basic_element())
		play_sound("spear_hit", 0.0, -2.0)
	var at: = p.position + p.facing * 0.8
	spawn_fx("hit", at + Vector3(0, 0.7, 0), 1.4, 1.0)
	spawn_fx("pierce", at + Vector3(0, 0.7, 0), 1.2 + power, 1.0)
	Vfx.ray_flash(fx_root, at + Vector3(0, 0.9, 0), camera.global_basis, gold, 1.0 + power * 0.6)
	Vfx.column(fx_root, at, gold)
	Vfx.burst(fx_root, p.position + p.facing * 0.6, 1.8 + power, Color(1.0, 0.9, 0.6))
	Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), 2.4, gold, 0.3)
	Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), 3.0 + power * 2.5, gold.lightened(0.3), 0.45)
	play_sound("brandish", 0.0, -6.0)
	shake(0.35 + power * 0.3)
	for o in enemies_in_radius(p.position + p.facing * 0.8, 1.8):
		if o != e and not o.dead:
			damage_enemy(o, float(d.get("hit_dmg", 0.0)) * 0.35, ((o.position - p.position) * Vector3(1, 0, 1)).normalized() * 5.0, "skill", p.basic_element())

	var left: = int(d.get("chain", 0))
	if left > 0:
		var next: Enemy = null
		var top: = -1.0
		for o in enemies_in_radius(p.position, float(d.get("reach", 9.0))):
			if o == e or o.dead or o.prop != "":
				continue
			var score: = Skills.rank(self, o)
			if score > top:
				top = score
				next = o
		if next != null:
			var tag: = damage_tag
			_own_timer(0.12, func():
				if running and hero_valid(p) and is_instance_valid(next) and not next.dead and p.dash.is_empty():
					damage_tag = tag
					charge_attack(p, next, float(sk.get("damage", 0.0)), float(d.get("reach", 9.0)), float(d.get("width", 1.2)), sk, left - 1)
					play_skill_sound(sk))









func spear_boomerang(p: Player, dir: Vector3, reach: float, width: float, dmg: float, sk: Dictionary, lead: = true) -> void :
	var tag: = damage_tag
	var by: = damage_by
	var dim: = Vfx.dim
	var odin: = p.effects.has("lg_gungnir")
	var spear: = Sprite3D.new()
	var spr: = RoAssets.sprite(["item_spear"])
	spear.texture = spr.get_frame(0, 0) if spr != null else RoAssets.radial(Color.WHITE, 32)
	spear.axis = Vector3.AXIS_Y
	spear.shaded = false
	spear.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	spear.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	spear.pixel_size = GameData.PIXEL_SIZE * (3.4 if odin else 2.6)
	spear.no_depth_test = true
	spear.render_priority = GameData.HERO_FX_PRIORITY
	spear.modulate = Color(1.6, 1.3, 0.55, dim) if odin else Color(1.15, 1.15, 1.25, dim)
	fx_root.add_child(spear)
	var struck: = [false]
	var trail_at: = [Vector3.INF]
	var start: = p.position + Vector3(0, 0.9, 0)
	spear.global_position = start
	var hit_out: = {}
	var hit_back: = {}
	var out_t: = clampf(reach / 20.0, 0.25, 0.6)
	var tw: = spear.create_tween()
	tw.tween_method( func(k: float):
		if not is_instance_valid(spear):
			return

		var far: = sin(k * PI)
		var home: = (p.position + Vector3(0, 0.9, 0)) if is_instance_valid(p) else start
		var outward: = k < 0.5
		var at: = (start if outward else home) + dir * reach * far
		spear.global_position = at
		spear.rotation.y = k * TAU * 4.0


		Vfx.dim = dim
		damage_tag = tag
		damage_by = by
		if odin:

			if lead and (trail_at[0] == Vector3.INF or (at - trail_at[0]).length() > 0.45):
				trail_at[0] = at
				spawn_fx("holyhit", at, 0.45, 0.5)
			if not outward and not struck[0]:
				struck[0] = true
				gungnir_strike(p, start + dir * reach, dmg, sk, lead, "gungnir", tag)
				damage_tag = tag
				damage_by = by
		var seen: = hit_out if outward else hit_back
		for e in enemies_in_radius(Vector3(at.x, p.position.y, at.z), width):
			if seen.has(e) or e.dead:
				continue
			seen[e] = true
			damage_enemy(e, dmg, dir * float(sk.get("knock", 2.0)) * (1.0 if outward else -1.0), "skill", p.basic_element())
			spawn_fx("hit", e.position + Vector3(0, 0.7, 0), 0.7, 0.8)
			play_sound("spear_hit", 0.05, -8.0)
		damage_by = null
		Vfx.dim = 1.0, 0.0, 1.0, out_t * 2.0)
	tw.tween_callback(spear.queue_free)









var _gungnir_of: = ""
func gungnir_strike(p: Player, at: Vector3, dmg: float, sk: Dictionary, full: = true, tag: = "gungnir", of: = "") -> void :
	if not running or not hero_valid(p):
		return
	var ground: = Vector3(at.x, p.position.y, at.z)
	var r: = GameData.GUNGNIR_RADIUS * sqrt(p.area_mult)
	var gold: = Color(1.0, 0.82, 0.3)
	Vfx.ring(fx_root, ground + Vector3(0, 0.05, 0), r, Color(1.0, 0.95, 0.7), 0.5)
	spawn_fx("lightning", ground, 1.4 if full else 1.0, 1.0)
	if full:
		Vfx.magic_circle(fx_root, ground, r, Color(1.0, 0.8, 0.3, 0.85), 0.9, "mvp_rune", 1.4)
		Vfx.beam_flash(fx_root, ground, Color(1.0, 0.9, 0.55), 9.0)
		Vfx.column(fx_root, ground, gold)
		Vfx.burst(fx_root, ground, r, gold)
		Vfx.quake(fx_root, ground, r * 0.8, Color(1.0, 0.78, 0.25))

		for i in 3:
			var off: = Vector3(cos(i * 2.1 + 0.4), 0, sin(i * 2.1 + 0.4)) * r * 0.6
			_own_timer(0.1 + 0.08 * i, func(): spawn_fx("lightning", ground + off, 0.9, 0.9))
		play_sound("lightning_crash", 0.0, -2.0)
		play_sound("thunder", 0.0, -4.0)
		shake(0.3)
	var keep: = [damage_tag, damage_by, _gungnir_of]
	damage_tag = tag
	damage_by = p
	_gungnir_of = of
	var hit: = 0
	for e in enemies_in_radius(ground, r):
		if e.dead:
			continue
		damage_enemy(e, dmg * GameData.GUNGNIR_MULT, ((e.position - ground) * Vector3(1, 0, 1)).normalized() * 3.0, "skill", p.basic_element())

		if hit < (6 if full else 1):
			spawn_fx("lightning", e.position, 0.7, 0.8)
		hit += 1
	damage_tag = keep[0]
	damage_by = keep[1]
	_gungnir_of = keep[2]
	if full:
		label_over(p, tr("¡Juicio de Odín!"), gold)








func _wiz_combo(p: Player, e: Enemy, element: String, base: float) -> void :
	if e.combo_mark == "" or e.combo_until <= time or e.combo_mark == element:
		combo_mark(e, element)
		return
	var pair: = [e.combo_mark, element]




	var now: = World.game_ms() / 1000.0
	if now - _combo_window > 0.1 or now < _combo_window:
		_combo_window = now
		_combo_count = 0


	if _combo_count >= GameData.COMBO_CAP:
		return
	_combo_count += 1
	_combo_clear(e)
	var kind: = "vapor" if pair.has("water") and pair.has("fire") else ("conduct" if pair.has("water") else "blaze")

	if pair.has("earth"):
		kind = "lava" if pair.has("fire") else ("mud" if pair.has("water") else "sand")
	var at: = e.position

	var dmg: = base * GameData.COMBO_MULT * (1.0 + float(p.effects.get("combo_dmg", 0.0))) * Skills.possess_mult(self, e)

	var eid: = e.get_instance_id()
	_own_timer(0.05, func(): _wiz_react(p, kind, at, dmg, eid))
var _combo_window: = -1.0
var _combo_count: = 0

const CONDUCT_ARC_MS: = 120
var _conduct_arc_at: = 0




func combo_mark(e: Enemy, el: String) -> void :
	if e.dead:
		return
	var had: = e.combo_mark if e.combo_until > time else ""
	e.combo_mark = el
	e.combo_until = time + GameData.COMBO_MARK_TIME
	if had != el:
		_combo_icon_clear(e)
		_skill_mark(e, str({"fire": "fire_bolt", "water": "frost_diver", "wind": "thunder_storm", "earth": "quagmire"}.get(el, "fire_bolt")), "combo_until", 0.55)


func _combo_clear(e: Enemy) -> void :
	e.combo_mark = ""
	e.combo_until = 0.0
	_combo_icon_clear(e)


func _combo_icon_clear(e: Enemy) -> void :
	var icon = (e.get_meta("combo_until_icon") if e.has_meta("combo_until_icon") else null)
	if icon != null and is_instance_valid(icon):
		icon.queue_free()
	if e.has_meta("combo_until_icon"):
		e.remove_meta("combo_until_icon")




func _wiz_react(p: Player, kind: String, at: Vector3, dmg: float, from_id: int) -> void :
	if not running or not hero_valid(p):
		return
	var tag: = damage_tag
	var by: = damage_by
	damage_tag = "wiz_combo"
	damage_by = p
	match kind:
		"vapor":
			var r: = GameData.COMBO_AREA * sqrt(p.area_mult)
			spawn_fx("icecrash", at, r / 2.2, 0.8)
			spawn_fx("firehit1", at, r / 2.0, 0.9)
			Vfx.burst(fx_root, at + Vector3(0, 0.5, 0), r * 0.85, Color(0.95, 0.97, 1.0))
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, Color(0.9, 0.95, 1.0), 0.35)
			for t in enemies_in_radius(at, r):
				damage_enemy(t, dmg, ((t.position - at) * Vector3(1, 0, 1)).normalized() * 3.0, "skill", "neutral", "wiz_combo")
			_combo_label(p, tr("¡Vapor!"), Color(0.85, 0.95, 1.0))
			play_sound("combo_vapor", 0.1, -7.0)
		"conduct":
			var from: = at
			var hit: = {from_id: true}





			var now: = Time.get_ticks_msec()
			var arcs: = now >= _conduct_arc_at and not Vfx._skip(1)
			if arcs:
				_conduct_arc_at = now + CONDUCT_ARC_MS
			for j in GameData.COMBO_CHAIN:
				var best: Enemy = null
				var bd: = INF
				for t in enemies_in_radius(from, GameData.COMBO_CHAIN_RANGE):
					if hit.has(t.get_instance_id()) or t.dead:
						continue
					var d: = t.position.distance_to(from)

					if t.combo_mark == "water" and t.combo_until > time:
						d *= 0.4
					if d < bd:
						bd = d
						best = t


				if best == null and j == 0:
					var first = instance_from_id(from_id)
					if first is Enemy and not (first as Enemy).dead and enemies.has(first):
						best = first
				if best == null:
					break
				hit[best.get_instance_id()] = true
				var to: = best.position
				if arcs:
					Vfx.strike_line(fx_root, from, ((to - from) * Vector3(1, 0, 1)).normalized(), from.distance_to(to), 0.35, Color(0.6, 0.8, 1.0))
				spawn_fx("lightning", to, 0.55, 0.7)
				damage_enemy(best, dmg * 0.8, Vector3.ZERO, "skill", "neutral", "wiz_combo")
				if not best.dead:
					apply_status(best, "stun", 0.5)
				from = to
			_combo_label(p, tr("¡Electrocución!"), Color(0.7, 0.85, 1.0))
			play_sound("thunder", 0.1, -12.0)
		"blaze":
			var r: = GameData.COMBO_SPREAD * sqrt(p.area_mult)
			spawn_fx("firehit1", at, r / 1.8, 1.0)
			Vfx.burst(fx_root, at + Vector3(0, 0.5, 0), r * 0.8, Color(1.0, 0.55, 0.2))
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, Color(1.0, 0.5, 0.2), 0.4)
			for t in enemies_in_radius(at, r):
				damage_enemy(t, dmg * 0.6, Vector3.ZERO, "skill", "neutral", "wiz_combo")

				if not t.dead:
					combo_mark(t, "fire")
			_combo_label(p, tr("¡Tormenta ígnea!"), Color(1.0, 0.65, 0.3))
			play_sound("fire_hit1", 0.1, -8.0)
		"lava":

			var r: = GameData.COMBO_AREA * sqrt(p.area_mult)
			spawn_fx("firepillar", at, r / 2.0, 1.0)
			spawn_fx("earthhit", at, r / 1.8, 0.9)
			Vfx.burst(fx_root, at + Vector3(0, 0.4, 0), r * 0.85, Color(1.0, 0.4, 0.1))
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, Color(0.9, 0.35, 0.1), 0.45)
			for t in enemies_in_radius(at, r):
				damage_enemy(t, dmg * GameData.COMBO_LAVA, ((t.position - at) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", "neutral", "wiz_combo")
			_combo_label(p, tr("¡Lava!"), Color(1.0, 0.5, 0.2))
			play_sound("earth_quake", 0.1, -8.0)
		"mud":

			var r: = GameData.COMBO_AREA * sqrt(p.area_mult)
			spawn_fx("quagmire", at, r / 2.0, 0.9)
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, Color(0.55, 0.42, 0.25), 0.5)
			for t in enemies_in_radius(at, r):
				damage_enemy(t, dmg * GameData.COMBO_SIDE, Vector3.ZERO, "skill", "neutral", "wiz_combo")
				if not t.dead:
					t.slow_time = maxf(t.slow_time, GameData.COMBO_MUD_SLOW)
			_combo_label(p, tr("¡Barro!"), Color(0.75, 0.6, 0.4))
			play_sound("quagmire", 0.1, -8.0)
		"sand":

			var r: = GameData.COMBO_SPREAD * sqrt(p.area_mult)
			spawn_fx("shockwave", at, r / 2.0, 0.8)
			spawn_fx("earthhit", at, r / 2.2, 0.7)
			Vfx.burst(fx_root, at + Vector3(0, 0.6, 0), r * 0.9, Color(0.95, 0.82, 0.5))
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r, Color(0.9, 0.78, 0.45), 0.4)
			for t in enemies_in_radius(at, r):
				damage_enemy(t, dmg * GameData.COMBO_SIDE, Vector3.ZERO, "skill", "neutral", "wiz_combo")
				if not t.dead:
					blind_enemy(t, GameData.COMBO_SAND_BLIND, true)
			_combo_label(p, tr("¡Tormenta de arena!"), Color(0.95, 0.85, 0.5))
			play_sound("tk_wind", 0.1, -8.0)
	damage_tag = tag
	damage_by = by





const SIDE_WORD_SIZE: = 1.3
const SIDE_WORD_GAP: = 0.2
var _side_said: = {}
var _side_way: = 1.0
func side_word(e: Enemy, text: String, color: Color) -> void :
	if time - float(_side_said.get(text, -9.0)) < SIDE_WORD_GAP:
		return
	_side_said[text] = time
	_side_way = - _side_way
	var right: = (camera.global_basis.x * Vector3(1, 0, 1)).normalized() if camera != null else Vector3.RIGHT
	var wide: float = e.radius + 1.9 + maxf(0.0, e.visual.height() * 0.15)
	var l: = number(e.position + right * wide * _side_way + Vector3(0, e.visual.height() * 0.5, 0), text, color, true)
	if l is Label3D:
		var word: = l as Label3D
		word.font_size = roundi(word.font_size * SIDE_WORD_SIZE)
		word.outline_size = roundi(word.outline_size * SIDE_WORD_SIZE)

		word.render_priority = 19
		word.outline_render_priority = 18




func _combo_label(p: Player, text: String, color: Color) -> void :
	if time - float(_combo_said.get(text, -9.0)) < 0.5:
		return
	_combo_said[text] = time
	number(p.position + Vector3(0, 2.9, 0), text, color, true)
var _combo_said: = {}




func sightrasher(p: Player, reach: float, dmg: float, sk: Dictionary, waves: int) -> void :
	var tag: = damage_tag
	p.play_attack(p.facing, true)
	for w in waves:
		var r: = reach * (1.0 + 0.45 * w)
		_own_timer(0.28 * w, func():
			if not running or not hero_valid(p):
				return
			damage_tag = tag
			var c: = p.position
			for i in 12:
				var a: = TAU * i / 12.0
				var spot: = c + Vector3(cos(a), 0, sin(a)) * r * 0.8
				_own_timer(0.015 * i, func(): spawn_fx("firehit1", spot, 0.45, 0.8))
			Vfx.ring(fx_root, c + Vector3(0, 0.05, 0), r, Color(1.0, 0.55, 0.2), 0.35)
			for e in enemies_in_radius(c, r):
				var away: = ((e.position - c) * Vector3(1, 0, 1)).normalized()
				damage_enemy(e, dmg, away * float(sk.get("knock", 7.0)), "skill", "fire")
			shake(0.08))





func gravitation(p: Player, at: Vector3, r: float, dmg: float, duration: float, sk: Dictionary) -> void :
	var tag: = damage_tag
	var fx: = str(sk.fx)
	spawn_fx(fx + "_bottom_start", at, r / 2.6, 0.9)
	spawn_fx(fx + "_start", at, r / 2.6, 1.0)
	var loops: = ceili(duration / 1.5)
	for k in loops:
		_own_timer(0.3 + 1.5 * k, func():
			if running:
				spawn_fx(fx + "_bottom_loop", at, r / 2.6, 0.9)
				spawn_fx(fx + "_loop", at, r / 2.6, 1.0))
	var ticks: = ceili(duration / 0.3)
	for k in ticks:
		_own_timer(0.3 * (k + 1), func():
			if not running or not hero_valid(p):
				return
			damage_tag = tag
			for e in enemies_in_radius(at, r * 1.35):
				var inward: = ((at - e.position) * Vector3(1, 0, 1))
				damage_enemy(e, dmg, inward.normalized() * minf(float(sk.get("pull", 5.0)), inward.length() * 3.0), "skill", "neutral"))
	if sk.has("implode"):
		_own_timer(duration + 0.3, func():
			if not running or not hero_valid(p):
				return
			damage_tag = tag
			Vfx.burst(fx_root, at + Vector3(0, 0.6, 0), r, Color(0.65, 0.45, 1.0))
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), r * 1.2, Color(0.7, 0.5, 1.0), 0.45)
			Vfx.ray_flash(fx_root, at + Vector3(0, 0.8, 0), camera.global_basis, Color(0.75, 0.55, 1.0))
			for e in enemies_in_radius(at, r * 1.2):
				damage_enemy(e, dmg * float(sk.implode), ((e.position - at) * Vector3(1, 0, 1)).normalized() * 6.0, "skill", "neutral")
			play_sound("combo_vapor", 0.05, -4.0)
			shake(0.25))




func kunai_stick(p: Player, e: Enemy) -> void :
	if e.dead:
		return
	if e.kunai_until <= time:
		e.kunai_stuck = 0
		_kunai_clear(e)
	e.kunai_until = time + GameData.KUNAI_TIME
	e.kunai_el = p.arrow_element()
	if e.kunai_stuck >= GameData.KUNAI_MAX:
		return
	e.kunai_stuck += 1
	var nodes: Array = (e.get_meta("kunai_nodes") if e.has_meta("kunai_nodes") else [])
	if nodes.size() < 4 and not Vfx.hidden():
		var s: = Sprite3D.new()
		s.texture = _kunai_tex(p)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 11
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.pixel_size = GameData.PIXEL_SIZE * 1.1
		var h: float = e.visual.height() if e.visual != null else 1.0
		s.position = Vector3(randf_range(-0.3, 0.3), h * randf_range(0.3, 0.75), 0.05)
		s.rotation.z = randf_range(-1.2, 1.2)
		e.add_child(s)
		nodes.append(s)
		e.set_meta("kunai_nodes", nodes)
	if not e.has_meta("kunai_watch"):
		e.set_meta("kunai_watch", true)
		_kunai_watch(e)


func _kunai_watch(e_in: Enemy) -> void :
	var eid: = e_in.get_instance_id()
	get_tree().create_timer(maxf(0.1, e_in.kunai_until - time + 0.05), false).timeout.connect( func():
		var e = instance_from_id(eid)
		if e == null or not is_instance_valid(e):
			return
		if e.dead or e.kunai_until <= time:
			e.kunai_stuck = 0
			_kunai_clear(e)
			e.remove_meta("kunai_watch")
		else:
			_kunai_watch(e))


func _kunai_clear(e: Enemy) -> void :
	if not e.has_meta("kunai_nodes"):
		return
	for n in e.get_meta("kunai_nodes"):
		if is_instance_valid(n):
			n.queue_free()
	e.remove_meta("kunai_nodes")



func _kunai_tex(p: Player) -> Texture2D:
	var key: = "item_" + p.arrow_id
	if not _kunai_cache.has(key):
		var spr: = RoAssets.sprite([key, "item_heat_wave_kunai", "item_shuriken"])
		_kunai_cache[key] = spr.get_frame(0, 0) if spr != null else RoAssets.radial(Color.WHITE, 16)
	return _kunai_cache[key]
var _kunai_cache: = {}




func kunai_explosion(p: Player, foes: Array, dmg: float, splash: float, sk: Dictionary) -> void :
	var tag: = damage_tag
	foes.sort_custom( func(a, b): return a.position.distance_squared_to(p.position) < b.position.distance_squared_to(p.position))
	var i: = 0
	var total: = 0
	for e in foes:
		var n: int = e.kunai_stuck
		var el: String = e.kunai_el
		e.kunai_stuck = 0
		e.kunai_until = 0.0
		_kunai_clear(e)
		var eid: int = e.get_instance_id()
		total += n
		_own_timer(0.04 * i, func():
			var e2 = instance_from_id(eid)
			if not running or e2 == null or not is_instance_valid(e2):
				return
			var en: Enemy = e2
			damage_tag = tag
			var at: Vector3 = en.position
			var fx: String = {"fire": "firehit1", "water": "icecrash", "wind": "lightning", "earth": "earthhit"}.get(el, "firehit1")
			spawn_fx(fx, at, 0.7 + 0.12 * n, 1.0)
			spawn_fx("hit", at + Vector3(0, 0.6, 0), 0.8, 0.9)
			Vfx.burst(fx_root, at + Vector3(0, 0.6, 0), 0.8 + 0.18 * n, Color(1.0, 0.7, 0.35))
			Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), 0.7 + 0.15 * n, Color(1.0, 0.6, 0.3), 0.3)
			if not en.dead:
				damage_enemy(en, dmg * n, Vector3.ZERO, "skill", el)
			if splash > 0.0:
				for t in enemies_in_radius(at, splash):
					if t != en:
						damage_enemy(t, dmg * n * 0.5, ((t.position - at) * Vector3(1, 0, 1)).normalized() * 2.0, "skill", el))
		i += 1

	label_over(p, tr("¡%d kunai!") % total, Color(1.0, 0.7, 0.35))
	Vfx.ring(fx_root, p.position, 3.0 + 0.15 * mini(total, 40), Color(1.0, 0.6, 0.3), 0.5)
	if total >= 10:
		Vfx.ray_flash(fx_root, p.position + Vector3(0, 1.0, 0), camera.global_basis, Color(1.0, 0.7, 0.35), 1.2)
	shake(minf(0.5, 0.12 + 0.015 * total))





func kaihou(p: Player, dmg: float, reach: float, sk: Dictionary) -> void :
	var tag: = damage_tag
	var held: Array = p.charms.duplicate()
	p.charms.clear()
	var triple: = held.has("fire") and held.has("water") and held.has("wind")
	if triple:
		dmg *= GameData.CHARM_TRIPLE
		forge_label(p, tr("¡Sello triple!"), Color(0.9, 0.8, 1.0), true)
	else:
		forge_label(p, "Kaihou", Color(0.9, 0.85, 1.0), false)
	p.play_attack(p.facing, true)
	play_sound("mist_slash", 0.0, -4.0)
	for k in held.size():
		var el: String = held[k]
		_own_timer(0.2 * k, func():
			if not running or not hero_valid(p):
				return
			damage_tag = tag
			match el:
				"fire":
					for j in 8:
						var a: = TAU * j / 8.0
						spawn_fx("firehit1", p.position + Vector3(cos(a), 0, sin(a)) * reach * 0.7, 0.6, 0.9)
					sprite_fx("fx_kaensin", p.position + Vector3(0, 0.5, 0), 0, 1.2)
					Vfx.ring(fx_root, p.position + Vector3(0, 0.05, 0), reach, Color(1.0, 0.5, 0.2), 0.4)
					for e in enemies_in_radius(p.position, reach):
						damage_enemy(e, dmg, ((e.position - p.position) * Vector3(1, 0, 1)).normalized() * 5.0, "skill", "fire")
					play_sound("fire_hit2", 0.05, -6.0)
				"water":
					for e in nearest_enemies(p.position, reach * 1.4, 6):
						spawn_fx("icecrash", e.position, 0.8, 0.9)
						damage_enemy(e, dmg, Vector3.ZERO, "skill", "water")
						if not e.dead and randf() < 0.35:
							apply_status(e, "freeze", 1.5)
					play_sound("cold_hit2", 0.05, -6.0)
				_:
					for e in nearest_enemies(p.position, reach * 1.4, 6):
						spawn_fx("lightning", e.position, 0.8, 0.9)
						damage_enemy(e, dmg, Vector3.ZERO, "skill", "wind")
						if not e.dead:
							apply_status(e, "stun", 1.0)
					play_sound("thunder", 0.05, -8.0)
			shake(0.1))




func forge_heat(p: Player, source: String) -> void :
	var now: = World.game_ms()
	if now - p.forge_hit_at < int(GameData.FORGE_HIT_GAP * 1000.0):
		return
	p.forge_hit_at = now
	var lv: = p.forge_refine()
	if lv >= p.forge_max():
		p.forge_heat = 1.0
		return
	p.forge_heat += (GameData.FORGE_HEAT_BASIC if source == "basic" else GameData.FORGE_HEAT_SKILL) / (1.0 + GameData.FORGE_HEAT_GROWTH * lv)
	if p.forge_heat >= 1.0:
		p.forge_heat = 0.0
		forge_up(p)





func forge_up(p: Player) -> void :
	var to: = p.forge_refine() + 1
	if randf() < p.forge_break_chance(to):
		forge_break(p, to - 1)
		return
	p.forge += 1
	p.recompute()
	var safe: = p.forge_safe()
	var col: = forge_color(p, to)
	forge_label(p, "+%d" % to, col, to > safe)
	var chest: = p.position + Vector3(0, 0.9, 0)
	Vfx.burst(fx_root, chest, 0.9 + 0.08 * maxi(0, to - safe), col)
	Vfx.air_impact(fx_root, chest, p.facing, 0.6)
	play_sound("forge_tink" if to <= safe else "forge_tink2", 0.08, -5.0)
	if to % 5 == 0:
		spawn_fx("bs_refinesuccess", p.position, 0.9, 0.9, p)
		play_sound("refine_ok", 0.0, -4.0)
		Vfx.ring(fx_root, p.position + Vector3(0, 0.05, 0), 3.0, col, 0.5)
		Vfx.ray_flash(fx_root, chest, camera.global_basis, col)
		shake(0.12)




func forge_label(p: Player, text: String, color: Color, big: bool) -> void :
	if net.recording():
		net.record(["l", net.ref_of(p), text, color])
	var l: = Label3D.new()
	l.text = text
	l.font = UiKit.FONT_TITLE
	l.font_size = 64 if big else 52
	l.pixel_size = 0.0085
	l.outline_size = 14
	l.outline_modulate = Color(0.15, 0.05, 0.0)
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 16
	l.outline_render_priority = 15
	l.position = p.position + Vector3(0, 2.5, 0)
	l.scale = Vector3.ONE * 1.8
	fx_root.add_child(l)
	var tw: = l.create_tween()
	tw.tween_property(l, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "position:y", l.position.y + 0.7, 0.8)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.8).set_delay(0.4)
	tw.tween_callback(l.queue_free)




func forge_color(p: Player, lv: int) -> Color:
	if lv <= p.forge_safe():
		return Color(1.0, 0.88, 0.4)
	return Color(1.0, 0.55, 0.2) if p.forge_break_chance(lv + 1) < 0.3 else Color(1.0, 0.25, 0.2)




func forge_break(p: Player, lv: int) -> void :
	var tag: = damage_tag
	var by: = damage_by
	damage_tag = "forge_blast"
	damage_by = p
	var reach: = (GameData.FORGE_BLAST_AREA + 0.12 * lv) * sqrt(p.area_mult)
	var dmg: = p.basic_atk() * (GameData.FORGE_BLAST + GameData.FORGE_BLAST_PER * lv)
	for e in enemies_in_radius(p.position, reach):
		var away: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
		damage_enemy(e, dmg, away * 8.0, "skill", p.basic_element(), "forge_blast")
	damage_tag = tag
	damage_by = by
	spawn_fx("blast_forge/blast_forge/blast_forge_bottom", p.position, reach / 3.2, 1.0)
	spawn_fx("blast_forge/blast_forge/blast_forge", p.position, reach / 3.2, 1.0)
	spawn_fx("bs_refinefailed", p.position, 0.8, 0.9, p)
	Vfx.burst(fx_root, p.position + Vector3(0, 0.6, 0), reach * 0.7, Color(1.0, 0.45, 0.15))
	Vfx.ring(fx_root, p.position + Vector3(0, 0.05, 0), reach, Color(1.0, 0.5, 0.2), 0.45)
	Vfx.ray_flash(fx_root, p.position + Vector3(0, 0.9, 0), camera.global_basis, Color(1.0, 0.5, 0.25), 1.3)
	forge_label(p, tr("¡Se rompe! +%d") % lv, Color(1.0, 0.3, 0.2), true)
	play_sound("forge_blast", 0.05, -2.0)
	play_sound("refine_fail", 0.0, -5.0)
	shake(0.35)
	p.forge = maxi(0, p.forge_safe() - p.weapon_refine())
	p.forge_heat = 0.0
	p.recompute()
	smoke_stats["forge_bursts"] = int(smoke_stats.get("forge_bursts", 0)) + 1


	if p.effects.has("lg_molten"):
		Forge.molten(self, p, lv)
	Forge.temper(self, p)








func axe_tornado(p: Player, reach: float, dmg: float, hits: int, sk: Dictionary, heat: = 0.0) -> void :
	var tag: = damage_tag
	var storm: = float(sk.get("storm", 0.0))
	var every: = (float(sk.get("storm_every", 0.22)) if storm > 0.0 else 0.22) / (1.0 + GameData.AT_HEAT_PACE * heat)
	var rounds: = maxi(hits, ceili(storm / every)) if storm > 0.0 else hits + roundi(GameData.AT_HEAT_HITS * heat)
	var whirl_every: = maxi(1, roundi(0.7 / every))
	var el: = p.tempered()
	if net.recording():
		net.record(["aw", net.ref_of(p), reach, every * rounds + 0.25, heat, el])
	_axe_whirl(p, reach, every * rounds + 0.25, heat, el)
	for k in rounds:
		_own_timer(every * k, func():
			if not running or not hero_valid(p):
				return
			damage_tag = tag
			if k % whirl_every == 0:
				spawn_fx("mineffect/new_axetornado/new_axetornado_bottom/new_axetornado_bottom", p.position, reach / 2.4, 0.9, p)
				if k > 0:
					play_skill_sound(sk)
			p.play_attack(p.facing.rotated(Vector3.UP, k * PI * 0.5))

			if heat > 0.4 and k % whirl_every == 0:
				Vfx.burst(fx_root, p.position + Vector3(0, 0.6, 0), reach * 0.55, Color(1.0, 0.5, 0.15).lerp(Color(1.0, 0.85, 0.4), 1.0 - heat))
			for e in enemies_in_radius(p.position, reach):
				var to: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()

				damage_enemy(e, dmg, (to.cross(Vector3.UP) - to * 0.5) * float(sk.get("knock", 1.2)), "skill", p.basic_element())
			shake(0.05))






func _axe_whirl(p: Player, reach: float, life: float, heat: = 0.0, el: = "") -> void :
	if _whirl_frames.is_empty():
		var meta: = RoAssets.effect_data("mineffect/new_axetornado/new_axetornado/new_axetornado")
		if meta.is_empty():
			return
		for r in (meta.textures as Array).slice(2):
			var at: = AtlasTexture.new()
			at.atlas = meta.atlas
			at.region = Rect2(r[0], r[1], r[2], r[3])
			_whirl_frames.append(at)
	var s: = Sprite3D.new()
	s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.shaded = false
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	s.no_depth_test = true
	s.render_priority = GameData.HERO_FX_PRIORITY
	s.texture = _whirl_frames[0]
	s.pixel_size = reach * 1.9 / 116.0
	var dim: = Vfx.dim
	var tint: = Color(1.15, 1.05, 0.95).lerp(Color(1.55, 0.78, 0.45), clampf(heat, 0.0, 1.0))
	if Forge.EL_COLOR.has(el):
		tint = tint.lerp((Forge.EL_COLOR[el] as Color) * 1.5, 0.35)
	s.modulate = Color(tint, 0.0)
	fx_root.add_child(s)
	var spin: = 30.0 * (1.0 + GameData.AT_HEAT_PACE * heat)
	var tw: = s.create_tween()
	tw.tween_method( func(t: float):
		if not is_instance_valid(s) or not is_instance_valid(p):
			return
		s.global_position = p.position + Vector3(0, reach * 1.9 * 152.0 / 116.0 * 0.42, 0)
		s.texture = _whirl_frames[int(t * spin) % _whirl_frames.size()]
		var fade: = minf(1.0, minf(t / 0.12, (life - t) / 0.2))
		s.modulate.a = clampf(fade, 0.0, 1.0) * 0.7 * dim, 0.0, life, life)
	tw.tween_callback(s.queue_free)
var _whirl_frames: Array[Texture2D] = []





func cart_cannon(p: Player, e: Enemy, dmg: float, area: float, sk: Dictionary, delay: float) -> void :
	var tag: = damage_tag
	var eid: = e.get_instance_id()
	var aim: = e.position
	_own_timer(delay, func():
		if not running or not hero_valid(p):
			return
		var by: = damage_by
		var dim: = Vfx.dim
		var foe = instance_from_id(eid)
		var target: Vector3 = foe.position if foe != null and is_instance_valid(foe) and not foe.dead else aim
		var way: = ((target - p.position) * Vector3(1, 0, 1)).normalized()
		p.play_attack(way)
		var muzzle: = p.position + way * 0.7 + Vector3(0, 0.8, 0)
		spawn_fx("mineffect/new_cart_cannon/new_cart_cannon_cast/new_cart_cannon_cast", p.position, 0.6, 0.9, p)
		spawn_fx("mineffect/new_cart_cannon/new_cart_cannon/new_cart_cannon", muzzle, 0.8, 1.0)
		var ball: = Sprite3D.new()
		ball.texture = _cannonball_tex()
		ball.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		ball.shaded = false
		ball.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		ball.pixel_size = 0.04
		ball.no_depth_test = true
		ball.render_priority = GameData.HERO_FX_PRIORITY
		ball.modulate = Color(1, 1, 1, dim)
		fx_root.add_child(ball)
		ball.global_position = muzzle
		var dist: = muzzle.distance_to(target)
		var flight: = clampf(dist / 16.0, 0.25, 0.6)
		var peak: = 0.8 + dist * 0.2
		var trail: = [0]
		var tw: = ball.create_tween()
		tw.tween_method( func(k: float):
			if not is_instance_valid(ball):
				return
			var at: = muzzle.lerp(target + Vector3(0, 0.3, 0), k) + Vector3(0, peak * 4.0 * k * (1.0 - k), 0)
			ball.global_position = at
			trail[0] += 1
			if trail[0] %3 == 0:
				Vfx.dim = dim
				Vfx.burst(fx_root, at, 0.22, Color(1.0, 0.55, 0.2))
				Vfx.dim = 1.0, 0.0, 1.0, flight)
		tw.tween_callback( func():
			ball.queue_free()
			if not running:
				return
			Vfx.dim = dim
			damage_tag = tag
			damage_by = by
			_cannon_boom(p, target, dmg, area, sk)
			damage_by = null
			Vfx.dim = 1.0))


func _cannon_boom(p: Player, at: Vector3, dmg: float, area: float, sk: Dictionary) -> void :
	spawn_fx("mineffect/new_cart_cannon/new_cart_cannon_explosion_bottom/armscannon_explosion_bottom", at, area / 2.2, 0.9)
	spawn_fx("mineffect/new_cart_cannon/new_cart_cannon_explosion/armscannon_explosion", at, area / 2.2, 1.0)
	Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), area, Color(1.0, 0.6, 0.25), 0.35)
	for t in enemies_in_radius(at, area):
		var away: = ((t.position - at) * Vector3(1, 0, 1)).normalized()
		damage_enemy(t, dmg, away * float(sk.get("knock", 4.0)), "skill", p.basic_element())
	if sk.has("burn"):
		var zone: = {"name": "Cart Cannon", "shape": "square", "tick": 0.5, "element": "fire", "color": Color(1.0, 0.45, 0.15), 
			"fx": "firehit1", "fx_size": 0.35, "fx_intensity": 0.5}
		ground_zone(at, zone, area * 0.8, dmg * 0.12, 0.0, float(sk.burn))
	play_sound("forge_blast", 0.1, -9.0)
	shake(0.1)



var _cannonball: Texture2D
func _cannonball_tex() -> Texture2D:
	if _cannonball == null:
		var img: = Image.create(12, 12, false, Image.FORMAT_RGBA8)
		for y in 12:
			for x in 12:
				var d: = Vector2(x - 5.5, y - 5.5).length()
				if d > 5.6:
					continue
				var lit: = clampf(1.0 - Vector2(x - 3.5, y - 3.5).length() / 7.0, 0.0, 1.0)
				var c: = Color(0.13, 0.13, 0.16).lerp(Color(0.7, 0.7, 0.75), lit * lit)
				img.set_pixel(x, y, Color(0.04, 0.04, 0.05) if d > 4.7 else c)
		_cannonball = ImageTexture.create_from_image(img)
	return _cannonball





func spiral_drill(p: Player, e: Enemy, dmg: float, hits: int, sk: Dictionary) -> void :
	var tag: = damage_tag
	var by: = damage_by
	var way: = ((e.position - p.position) * Vector3(1, 0, 1)).normalized()
	p.facing = way
	p.visual.face(way)
	e.snare_time = maxf(e.snare_time, (0.09 * hits + 0.3) * cc_scale(e, "root"))
	var mult: = float(sk.get("boss_mult", 1.0)) if e.is_boss else 1.0
	for k in hits:
		_own_timer(0.09 * k, func():
			if not running or not is_instance_valid(e) or e.dead or not hero_valid(p):
				return
			damage_tag = tag
			damage_by = by
			var last: = k == hits - 1
			p.play_attack(way)
			damage_enemy(e, dmg * mult, way * (float(sk.get("knock", 6.0)) if last else 0.0), "skill", p.basic_element())
			spawn_fx("pierce", e.position + Vector3(0, 0.7, 0), 0.8 + 0.06 * k, 0.9)
			play_sound("spear_hit", 0.03, -8.0, 1.0 + 0.05 * k)
			if last:
				shake(0.3)
				Vfx.burst(fx_root, e.position + Vector3(0, 0.6, 0), 1.6, Color(1.0, 0.95, 0.8))
				if sk.has("pierce_line"):
					for o in enemies_in_radius(e.position + way * float(sk.pierce_line) * 0.5, float(sk.pierce_line) * 0.5 + 0.8):
						var rel: = (o.position - e.position) * Vector3(1, 0, 1)
						if o != e and not o.dead and rel.dot(way) > 0.0 and (rel - way * rel.dot(way)).length() < 1.2:
							damage_enemy(o, dmg * 2.0, way * 6.0, "skill", p.basic_element())
					Vfx.strike_line(fx_root, e.position, way, float(sk.pierce_line), 1.0, Color(1.0, 0.95, 0.8)))






func jupitel(p: Player, e: Enemy, dmg: float, hits: int, sk: Dictionary, delay: = 0.0) -> void :
	var tag: = damage_tag
	var by: = damage_by
	var dim: = Vfx.dim
	var start: = p.position + Vector3(0, 1.1, 0)
	var ball: = Node3D.new()
	fx_root.add_child(ball)
	ball.global_position = start
	var core: = _jupitel_sprite(RoAssets.effect_tex("jupitel_center"), 1.3, Color(0.75, 0.85, 1.0, 0.75 * dim))
	ball.add_child(core)
	var frames: Array[Texture2D] = []
	for i in 6:
		var t: = RoAssets.effect_tex("jupitel_ball_%d" % (i + 1))
		if t != null:
			frames.append(t)
	var orb: = _jupitel_sprite(frames[0] if not frames.is_empty() else RoAssets.radial(Color.WHITE, 32), 1.6, Color(1, 1, 1, dim))
	ball.add_child(orb)
	var spin: = orb.create_tween().set_loops()
	if not frames.is_empty():
		spin.tween_method( func(k: float): _jset(orb, frames[int(k) % frames.size()]), 0.0, float(frames.size()), 0.25)
	var travel: = maxf(0.06, start.distance_to(e.position) / 34.0)



	var eid: = e.get_instance_id()
	var pid: = p.get_instance_id()
	var bid: = by.get_instance_id() if by != null else 0
	var fly: = ball.create_tween()
	fly.tween_interval(delay)
	fly.tween_method( func(k: float):
		var to = instance_from_id(eid)
		if to != null:
			ball.global_position = start.lerp((to as Node3D).position + Vector3(0, 0.8, 0), k), 0.0, 1.0, travel)
	fly.tween_callback( func():
		for k in hits:
			get_tree().create_timer(0.075 * k, false).timeout.connect( func():
				var en = instance_from_id(eid)
				if not running or en == null or (en as Enemy).dead:
					return
				var e2: Enemy = en
				var hero = instance_from_id(pid)
				Vfx.dim = dim
				damage_tag = tag
				damage_by = instance_from_id(bid) as Player if bid != 0 else null
				var last: = k == hits - 1
				var way: = ((e2.position - (hero as Node3D).position) * Vector3(1, 0, 1)).normalized() if hero != null else Vector3.ZERO
				damage_enemy(e2, dmg, way * (float(sk.get("knock", 6.0)) if last else 0.6), "skill", "wind")
				if is_instance_valid(ball):
					ball.global_position = e2.position + Vector3(0, 0.8, 0)
				_jupitel_hit(e2.position + Vector3(0, 0.8, 0))
				play_sound(["lightbolt_hit1", "lightbolt_hit2", "lightbolt_hit3"][k % 3], 0.05, -9.0)
				if last and not e2.dead:
					apply_status(e2, "stun", float(sk.get("stun_time", 1.0)))
				damage_by = null
				Vfx.dim = 1.0)
		var fade: = ball.create_tween()
		fade.tween_interval(0.075 * hits + 0.05)
		fade.tween_callback(ball.queue_free))



func _jupitel_hit(at: Vector3) -> void :
	var dim: = Vfx.dim
	var pang: = _jupitel_sprite(RoAssets.effect_tex("jupitel_pang"), 0.3, Color(0.85, 0.9, 1.0, 0.9 * dim))
	fx_root.add_child(pang)
	pang.global_position = at
	var pt: = pang.create_tween().set_parallel()
	pt.tween_property(pang, "scale", Vector3.ONE * 7.0, 0.1)
	pt.tween_property(pang, "modulate:a", 0.0, 0.12)
	pt.chain().tween_callback(pang.queue_free)
	var keys: = ["jupitel_blast_1", "jupitel_blast_2", "jupitel_ball_4", "jupitel_ball_5", "jupitel_ball_6"]
	var first: = RoAssets.effect_tex(keys[0])
	if first == null:
		return
	var blast: = _jupitel_sprite(first, 2.4, Color(1, 1, 1, dim))
	fx_root.add_child(blast)
	blast.global_position = at
	var bt: = blast.create_tween()
	for key in keys:
		var t: = RoAssets.effect_tex(key)
		if t != null:
			bt.tween_callback( func(): _jset(blast, t))
			bt.tween_interval(0.05)
	bt.tween_property(blast, "modulate:a", 0.0, 0.08)
	bt.tween_callback(blast.queue_free)


func _jset(s: Sprite3D, t: Texture2D) -> void :
	s.texture = t
	s.material_override = _jupitel_mat(t)



var _jup_mats: = {}
func _jupitel_mat(tex: Texture2D) -> StandardMaterial3D:
	if not _jup_mats.has(tex):
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.no_depth_test = true
		m.render_priority = GameData.HERO_FX_PRIORITY
		m.albedo_texture = tex
		m.vertex_color_use_as_albedo = true
		_jup_mats[tex] = m
	return _jup_mats[tex]


func _jupitel_sprite(tex: Texture2D, size: float, col: Color) -> Sprite3D:
	var s: = Sprite3D.new()
	s.texture = tex
	s.pixel_size = size / maxf(1.0, float(tex.get_width())) if tex != null else 0.01
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.modulate = col
	if tex != null:
		s.material_override = _jupitel_mat(tex)
	return s




func lex_aeterna(p: Player, marked: Array, mult: float, duration: float) -> void :
	for e in marked:
		e.lex_until = time + duration
		e.lex_mult = mult
		spawn_fx("lexaeterna", e.position, 0.6 if not e.is_boss else 0.85, 1.0, e)
		_skill_mark(e, "lex_aeterna", "lex_until", 0.85)
		stagger.debuff(self, p, e, "lex")
	p.play_attack(p.facing, true)



func _lex_spent(e: Enemy) -> void :
	spawn_fx("holyhit", e.position + Vector3(0, 0.8, 0), 1.0, 1.0)
	side_word(e, "Lex Aeterna!", Color(1.0, 0.95, 0.65))
	var icon = (e.get_meta("lex_until_icon") if e.has_meta("lex_until_icon") else null)
	if icon != null and is_instance_valid(icon):
		icon.queue_free()
	e.remove_meta("lex_until_icon")




func _skill_mark(e: Enemy, skill: String, prop: String, lift: float) -> void :

	if Vfx.hidden():
		return
	var key: = prop + "_icon"
	var icon = (e.get_meta(key) if e.has_meta(key) else null)
	if icon == null or not is_instance_valid(icon):
		var tex: = UiKit.skill_icon(skill)
		if tex == null:
			return
		var s: = Sprite3D.new()
		s.texture = tex
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true
		s.render_priority = 12
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.pixel_size = GameData.PIXEL_SIZE * (1.3 if e.is_boss else 0.9)
		s.modulate = Color(1.0, 0.95, 0.75, 0.9)
		s.position = Vector3(0, (e.visual.height() if e.visual != null else 1.2) + lift, 0)
		e.add_child(s)
		e.set_meta(key, s)
		s.scale = Vector3.ONE * 0.2
		var pop: = s.create_tween()
		pop.tween_property(s, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


		if e.is_boss:
			pop.tween_callback( func():
				var tw: = s.create_tween().set_loops()
				tw.tween_property(s, "scale", Vector3.ONE * 1.12, 0.5).set_trans(Tween.TRANS_SINE)
				tw.tween_property(s, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_SINE))
		_mark_watch(e, prop)




func _clear_marks(e: Enemy) -> void :
	for prop in ["signum_until", "lex_until", "combo_until", "boss_mark_until"]:
		var key: String = prop + "_icon"
		if e.has_meta(key):
			var icon = e.get_meta(key)
			if icon != null and is_instance_valid(icon):
				icon.queue_free()
			e.remove_meta(key)
	_kunai_clear(e)
	StatusMarks.clear_all(e)


func _mark_watch(e: Enemy, prop: String) -> void :
	if not is_instance_valid(e):
		return
	var key: = prop + "_icon"

	var eid: = e.get_instance_id()
	get_tree().create_timer(maxf(0.1, float(e.get(prop)) - time + 0.05), false).timeout.connect( func():
		var e2 = instance_from_id(eid)
		if e2 == null or not is_instance_valid(e2):
			return
		var en: Enemy = e2
		var icon = (en.get_meta(key) if en.has_meta(key) else null)
		if en.dead or float(en.get(prop)) <= time:
			if icon != null and is_instance_valid(icon):
				icon.queue_free()
			en.remove_meta(key)
		elif icon != null and is_instance_valid(icon):
			_mark_watch(en, prop))



func _cell_sprite(key: String, at: Vector3, alpha: float) -> RoVisual:
	var spr: = RoAssets.sprite([key])
	if spr == null:
		return null
	var v: = RoVisual.new()
	fx_root.add_child(v)
	v.setup(spr, Color.WHITE, 16, 0.0)
	v.turns = false
	v.position = at
	v.play(0, true)
	v.speed_scale = randf_range(0.85, 1.15)
	v.tint = Color(1, 1, 1, alpha)
	v.sprite.modulate = v.tint
	return v


func _on_cell(z: Dictionary, pos: Vector3) -> bool:
	var l: Vector3 = pos - z.at
	var cell: float = z.cell
	return (z.cells as Dictionary).has(Vector2i(roundi(l.dot(z.right) / cell), roundi(l.dot(z.fwd) / cell)))






func _on_cell_body(z: Dictionary, e: Enemy) -> bool:
	if _on_cell(z, e.position):
		return true
	if not e.is_boss:
		return false
	for d in [z.right, - z.right, z.fwd, - z.fwd]:
		if _on_cell(z, e.position + d * e.radius):
			return true
	return false




var _zone_clock: = 0.0






var _zone_hits: = {}


func _update_zones(delta: float) -> void :
	_zone_clock += delta
	_zone_hits.clear()
	var later: Array = []
	for i in range(_zones.size() - 1, -1, -1):
		var z: Dictionary = _zones[i]
		z.t -= delta
		z.tick -= delta

		if z.has("follow") and is_instance_valid(z.follow):
			var to: Vector3 = (z.follow as Node3D).position + z.offset
			var shift: Vector3 = (to - z.at) * Vector3(1, 0, 1)
			if shift.length_squared() > 0.0001:
				z.at += shift
				for n in z.nodes:
					if is_instance_valid(n):
						var np: Vector3 = (n as Node3D).position + shift
						np.y = map.height_at(np) + ((n as Node3D).position.y - map.height_at((n as Node3D).position))
						(n as Node3D).position = np
		if z.tick <= 0.0 and z.t > 0.0:


			var every: float = z.every
			z.tick = every - fposmod(_zone_clock, every)
			if z.tick < every * 0.5:
				z.tick += every
			damage_tag = z.tag
			damage_by = z.get("by")

			var push: Vector3 = z.fwd * float(z.sk.get("knock", 0.0))



			var sk: Dictionary = z.sk
			var molten: bool = sk.get("molten", false)
			var element = sk.get("element", "neutral")
			var zdmg: = float(z.dmg)
			var zat: Vector3 = z.at
			var zcell: float = z.cell
			var zcells: Dictionary = z.cells
			var zright: Vector3 = z.right
			var zfwd: Vector3 = z.fwd

			var leaves: bool = z.has("acid") or sk.has("zone_slow") or sk.has("combo_mark") or (sk.has("cloud") and sk.has("poison"))


			if not z.has("group"):
				var who = z.get("by")
				z["group"] = "%s|%d|%s|%s" % [str(sk.get("name", "")), who.get_instance_id() if who != null and is_instance_valid(who) else 0, str(z.tag), str(element)]
			var group: Dictionary = _zone_hits.get(z.group, {})
			if not _zone_hits.has(z.group):
				_zone_hits[z.group] = group
			for e in enemies_in_radius(zat, z.r):

				var l: Vector3 = e.position - zat
				if not zcells.has(Vector2i(roundi(l.dot(zright) / zcell), roundi(l.dot(zfwd) / zcell)))\
				and ( not e.is_boss or not _on_cell_body(z, e)):
					continue
				if molten:


					if hero_valid(z.get("by")):
						dots.burn_on(self, e, zdmg, "molten_metal", z.by)
					continue

				if push != Vector3.ZERO or e.lex_until > time:
					_num_zone = true
					damage_enemy(e, zdmg, push, "skill", element)
					_num_zone = false
					_zone_effects(z, e)
					continue
				var id: = e.get_instance_id()
				var hit = group.get(id)
				if hit == null:
					group[id] = {"e": e, "dmg": zdmg, "element": element, "tag": z.tag, "by": z.get("by")}
				else:
					hit.dmg = float(hit.dmg) + zdmg
				if leaves:
					later.append([z, e])

			if z.sk.get("bubbles", false) and randf() < 0.7:
				var a: = randf() * TAU
				var at: Vector3 = z.at + Vector3(cos(a), 0, sin(a)) * z.r * 0.45 * sqrt(randf())
				at.y = map.height_at(at)
				Vfx.dim = own_fx_alpha
				spawn_fx("poison", at + Vector3(0, 0.2, 0), 0.45, 0.55)
				Vfx.dim = 1.0
			for h in heroes:
				if z.heal > 0.0 and not h.downed and _on_cell(z, h.position):
					h.heal(z.heal + h.max_hp * z.heal * GameData.HEAL_ZONE_PCT, self, false, skill_id_of(z.sk), 
						z.by if z.get("by") != null and is_instance_valid(z.by) else null)
		if z.t <= 0.0:
			for n in z.nodes:
				if is_instance_valid(n):
					var tw: Tween = n.create_tween()
					tw.tween_property(n, "scale", Vector3.ONE * 0.01, 0.25)
					tw.tween_callback(n.queue_free)
			_zones.remove_at(i)
	for group in _zone_hits.values():
		for hit in group.values():
			var e = hit.e
			if not is_instance_valid(e) or e.dead:
				continue
			damage_tag = hit.tag
			damage_by = hit.by if hit.by != null and is_instance_valid(hit.by) else null
			_num_zone = true
			damage_enemy(e, hit.dmg, Vector3.ZERO, "skill", hit.element)
			_num_zone = false
	_zone_hits.clear()
	for pair in later:
		if is_instance_valid(pair[1]):
			_zone_effects(pair[0], pair[1])




func _zone_effects(z: Dictionary, e: Enemy) -> void :


	if z.has("acid"):
		var had: = e.acid_frail if e.acid_until > clock else 0.0
		if z.sk.has("acid_stack"):
			var cap: = GameData.ACID_STACK_CAP_BOSS if e.is_boss else GameData.ACID_STACK_CAP
			var grown: = minf(cap, maxf(had, float(z.acid)) + (float(z.sk.acid_stack) if had > 0.0 else 0.0))
			e.acid_frail = maxf(had, grown)
			e.acid_until = maxf(e.acid_until, clock + GameData.ACID_STACK_KEEP)
		else:
			e.acid_frail = maxf(had, float(z.acid))
			e.acid_until = clock + 1.5

	if z.sk.has("zone_slow"):
		e.slow_time = maxf(e.slow_time, float(z.sk.zone_slow))
	if z.sk.has("combo_mark") and not e.dead and (e.combo_until <= time or e.combo_mark == ""):
		combo_mark(e, str(z.sk.combo_mark))

	if z.sk.has("cloud") and z.sk.has("poison") and not e.dead:
		apply_poison(e, z.dmg / float(z.sk.cloud_dmg) * GameData.POISON_DPS, float(z.sk.poison))





func sprite_fx(key: String, at: Vector3, action: = 0, size: = 1.0, follow: Node3D = null) -> void :
	if net.recording():
		net.record(["x", key, at, action, size, net.ref_of(follow) if follow != null else []])
	var spr: = RoAssets.sprite([key])
	if spr == null:
		return
	var count: = spr.frame_count(action)
	if count <= 0:
		return
	var s: = Sprite3D.new()
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true

	s.render_priority = GameData.HERO_FX_PRIORITY if follow is Player else 6
	s.modulate.a = Vfx.dim
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.pixel_size = GameData.PIXEL_SIZE * size
	s.texture = spr.get_frame(action, 0)
	if follow != null:
		follow.add_child(s)
		s.position = Vector3(0, 1.3, 0)
	else:
		fx_root.add_child(s)
		s.global_position = at
	var tw: = s.create_tween()
	tw.tween_method( func(f: float): s.texture = spr.get_frame(action, mini(int(f), count - 1)), 
		0.0, float(count), spr.frame_delay(action) * count)
	tw.tween_callback(s.queue_free)



func cloak(p: Player, seconds: float) -> void :
	if p.visual == null:
		return
	var v: RoVisual = p.visual
	v.tint = Color(0.75, 0.75, 0.9, 0.35)
	v.sprite.modulate = v.tint
	get_tree().create_timer(seconds, false).timeout.connect( func():
		if is_instance_valid(v):
			v.tint = Color.WHITE
			v.sprite.modulate = v.tint)





var _opaque: = {}


func _tex_opaque(tex: Texture2D) -> bool:
	var key: = tex.get_instance_id()
	if not _opaque.has(key):
		var img: = RoAssets.tex_image(tex)
		_opaque[key] = img != null and not img.detect_alpha()
	return bool(_opaque[key])




func rising_tex(target: Node3D, key: String, count: int) -> void :
	if net.recording():
		net.record(["rt", net.ref_of(target), key, count])

	if Vfx.hidden():
		return
	var tex: = RoAssets.effect_tex(key)
	if tex == null:
		Vfx.column(fx_root, target.position, Color(0.8, 0.9, 1.0))
		return
	for i in count:
		var s: = Sprite3D.new()
		s.texture = tex
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.no_depth_test = true

		var prio: = GameData.HERO_FX_PRIORITY if target is Player else 6
		s.render_priority = prio
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.pixel_size = GameData.PIXEL_SIZE
		var mat_blend: = _tex_opaque(tex)
		if mat_blend:

			var m: = StandardMaterial3D.new()
			m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
			m.no_depth_test = true
			m.albedo_texture = tex
			m.render_priority = prio
			s.material_override = m
		var a: = TAU * i / maxi(1, count)
		var off: = Vector3(cos(a), 0, sin(a)) * (0.0 if count == 1 else 0.55)
		target.add_child(s)
		s.position = off + Vector3(0, 1.6 if count == 1 else 0.3, 0)
		s.modulate.a = 0.0
		var tw: = s.create_tween()
		tw.tween_interval(i * 0.08)
		tw.tween_property(s, "modulate:a", 1.0, 0.12)
		tw.parallel().tween_property(s, "position:y", s.position.y + (0.5 if count == 1 else 1.6), 0.8)
		tw.tween_property(s, "modulate:a", 0.0, 0.25)
		tw.tween_callback(s.queue_free)





func orbit_skill(p: Player, sk: Dictionary, radius: float, dmg: float, count: int, duration: float, size: = 1.0, ghost: = false) -> void :
	if net.recording() and not ghost:
		var sid: = skill_id_of(sk)
		if sid != "":
			net.record(["ob", p.slot, sid, radius, count, duration, size])
	var o: Dictionary = {}
	for it in _orbits:
		if it.sk == sk and it.get("by") == p:
			o = it
	if o.is_empty():
		o = {"sk": sk, "angle": 0.0, "nodes": [], "hit": {}, "by": p, "ghost": ghost}
		_orbits.append(o)
	o.merge({"r": radius, "dmg": dmg, "t": duration, "tag": damage_tag, "size": size}, true)
	while o.nodes.size() > count:
		var gone = o.nodes.pop_back()
		if is_instance_valid(gone):
			gone.queue_free()
	if not o.has("frames"):
		o["frames"] = _raw_frames(str(sk.sprite)) if sk.get("raw_frames", false) else _holy_frames(str(sk.get("sprite", "fx_sight")))
	while o.nodes.size() < count:

		var v: = Sprite3D.new()
		v.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		v.shaded = false
		v.no_depth_test = true
		v.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		v.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		v.pixel_size = GameData.PIXEL_SIZE * 2.2
		if o.frames.is_empty():
			v.texture = Vfx.disc_texture()
			v.pixel_size = 0.8 / 128.0
		v.visible = not Vfx.hidden()
		run_root.add_child(v)
		o.nodes.append(v)



func _raw_frames(key: String) -> Array:
	var out: Array = []
	var spr: = RoAssets.sprite([key])
	if spr != null:
		for f in spr.frame_count(0):
			var tex: = spr.get_frame(0, f)
			if tex != null:
				out.append(tex)
	return out




func _holy_frames(key: String) -> Array:
	if _holy_cache.has(key):
		return _holy_cache[key]
	var out: Array = []
	var spr: = RoAssets.sprite([key])
	if spr != null:
		for f in spr.frame_count(0):
			var tex: = spr.get_frame(0, f)
			if tex == null:
				continue
			var img: = spr.compose_image(0, f)
			if img.is_compressed():
				img.decompress()
			img.convert(Image.FORMAT_RGBA8)
			for y in img.get_height():
				for x in img.get_width():
					var c: = img.get_pixel(x, y)
					img.set_pixel(x, y, Color(c.b * 0.8 + 0.2 * c.g, c.g * 0.9 + 0.1, c.r, c.a))
			out.append(ImageTexture.create_from_image(img))
	_holy_cache[key] = out
	return out


const ORBIT_BODY_HALF: = 0.4
func _update_orbits(delta: float) -> void :
	for i in range(_orbits.size() - 1, -1, -1):
		var o: Dictionary = _orbits[i]
		o.t -= delta
		if o.t <= 0.0:
			for n in o.nodes:
				if is_instance_valid(n):
					n.queue_free()
			_orbits.remove_at(i)
			continue
		o.angle = fmod(o.angle + delta * float(o.sk.get("orbit_speed", 3.0)), TAU)
		var now: = Time.get_ticks_msec() * 0.001
		var n_count: int = o.nodes.size()
		var frames: Array = o.frames
		for k in n_count:
			var node: Sprite3D = o.nodes[k]
			if not is_instance_valid(node):
				continue
			if not frames.is_empty():
				node.texture = frames[int(now * 14.0 + k * 3) % frames.size()]
				node.pixel_size = GameData.PIXEL_SIZE * float(o.sk.get("sprite_px", 2.2)) * float(o.get("size", 1.0))
				if o.sk.has("tint"):
					node.modulate = o.sk.tint
			var a: float = o.angle + TAU * k / n_count
			var at: = by_of(o).position + Vector3(cos(a), 0.0, sin(a)) * float(o.r)
			node.position = at + Vector3(0, 0.6 * float(o.get("size", 1.0)), 0)

			if camera != null:
				var rel: = at - by_of(o).position
				node.visible = not Vfx.hidden() and (rel.dot( - camera.global_basis.z) <= 0.0 or absf(rel.dot(camera.global_basis.x)) > ORBIT_BODY_HALF)
			if o.get("ghost", false):
				continue
			damage_tag = o.tag
			damage_by = o.get("by")
			for e in enemies_in_radius(at, 0.9 * float(o.get("size", 1.0))):
				var key: = e.get_instance_id()
				if float(o.hit.get(key, -99.0)) + float(o.sk.get("hit_every", 0.6)) > now:
					continue
				o.hit[key] = now
				var push: = (e.position - by_of(o).position) * Vector3(1, 0, 1)
				damage_enemy(e, o.dmg, push.normalized() * float(o.sk.get("knock", 0.0)), "skill", o.sk.get("element", "neutral"))
		if o.hit.size() > 400:
			o.hit.clear()





func _update_barrier() -> void :
	if _barrier == null or not is_instance_valid(_barrier):
		_barrier = Sprite3D.new()
		_barrier.texture = Vfx.ring_texture()
		_barrier.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		_barrier.shaded = false
		_barrier.no_depth_test = true
		_barrier.render_priority = GameData.HERO_FX_PRIORITY

		_barrier.pixel_size = 3.0 / 128.0
		_barrier.modulate = Color(0.75, 0.9, 1.0, 0.0)
		run_root.add_child(_barrier)
	var full: = maxf(1.0, player.shield_peak)
	var k: = clampf(player.shield / full, 0.0, 1.0)
	_barrier.visible = player.shield > 0.5


	var h: = _sprite_height(player.visual)
	var radius: = (h * 0.5 + 0.3) / 0.86
	_barrier.pixel_size = radius * 2.0 / 128.0
	_barrier.position = player.position + RoVisual.world_lift() + Vector3(0, h * 0.5, 0)
	_barrier.modulate.a = 0.25 + 0.45 * k + 0.08 * sin(Time.get_ticks_msec() * 0.006)


var _sprite_heights: = {}


func _sprite_height(v: RoVisual) -> float:
	if v == null or v.ro == null:
		return 2.4
	var key: = v.ro.get_instance_id()
	if not _sprite_heights.has(key):
		var used: = v.ro.compose_image(0, 0).get_used_rect()
		var px: = float(v.ro.origin.y - used.position.y) if used.has_area() else float(v.ro.origin.y)
		_sprite_heights[key] = px * GameData.PIXEL_SIZE * v.scale.y
	return float(_sprite_heights[key])


static func _flat_dist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()




func drop_bolt(b: Dictionary) -> void :
	b["tag"] = damage_tag
	var sk: Dictionary = b.skill

	var tex: Texture2D = arrow_texture() if str(sk.bolt_tex) == "arrow" else RoAssets.effect_tex(sk.bolt_tex)
	b.end = b.point + Vector3(0, 0.4, 0)

	b.start = b.end + (b.sky as Vector3 if b.has("sky") else Vector3(-1.2, 9.0, 0.9))
	b.time = - float(b.delay)
	b.duration = float(sk.get("bolt_time", 0.22))
	var mi: = MeshInstance3D.new()
	var quad: = QuadMesh.new()
	var len_px: = 64.0
	if tex != null:
		len_px = maxf(tex.get_width(), tex.get_height())
		quad.size = Vector2(tex.get_width(), tex.get_height() * float(sk.get("bolt_stretch", 1.0)))\
		* GameData.PIXEL_SIZE * float(sk.get("bolt_scale", 1.0))
	else:
		quad.size = Vector2(0.3, 1.6)
	mi.mesh = quad
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD if sk.get("bolt_blend", "mix") == "add" else BaseMaterial3D.BLEND_MODE_MIX
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = tex
	mat.albedo_color.a = Vfx.dim
	mat.no_depth_test = true
	mat.render_priority = 6
	mi.material_override = mat
	mi.visible = false
	fx_root.add_child(mi)
	b.node = mi
	b["half"] = quad.size.length() * 0.5

	if sk.has("rain") and not Vfx._skip(2):
		var tip: = (sk.get("bolt_axis", Vector2(0, -1)) as Vector2).normalized()
		var st: = Vfx.streak_sprite(Color(rain_color(sk, str(b.get("element", "neutral"))).lightened(0.35), 0.55))
		st.name = "streak"
		st.rotation.z = tip.angle()
		st.scale = Vector3(float(sk.get("streak_len", 2.6)), 0.14, 1.0)
		st.position = Vector3(tip.x, tip.y, 0.0) * - (float(b.half) + float(sk.get("streak_len", 2.6)) * 0.3)
		mi.add_child(st)
	b["by"] = damage_by
	if heroes.size() > 1 and str(damage_tag).begins_with("proc:") and not b.get("ghost", false):
		var by_h = damage_by
		var shown: = _bolts.filter( func(o): return o.get("proc_shown", false) and o.get("by") == by_h).size()
		if shown >= PROC_BOLTS_SHOWN:
			b["hidden"] = true
		else:
			b["proc_shown"] = true
	_bolts.append(b)
	if net.recording() and not b.get("ghost", false) and not b.get("hidden", false):
		var sid: = skill_id_of(sk)
		if sid != "":
			net.record(["bo", sid, b.point, float(b.delay)] + ([str(b.get("element", "neutral")), b.sky] if b.has("sky") else []))


func _update_bolts(delta: float) -> void :
	for i in range(_bolts.size() - 1, -1, -1):
		var b: Dictionary = _bolts[i]
		b.time += delta
		var node: MeshInstance3D = b.node
		if b.time < 0.0:
			continue

		var tgt = b.get("target")
		if tgt != null and is_instance_valid(tgt) and not tgt.dead:
			b.end = tgt.position + Vector3(0, 0.4, 0)
		var t: = clampf(b.time / b.duration, 0.0, 1.0)
		var pos: Vector3 = b.start.lerp(b.end, t)
		node.visible = not b.get("hidden", false)
		node.position = pos
		var axis: Vector2 = b.skill.get("bolt_axis", Vector2(0, -1))
		_orient_quad(node, pos, b.end - b.start, axis)
		if t >= 1.0:
			if not b.get("ghost", false):
				_bolt_impact(b)
			if b.skill.has("rain") and not b.get("hidden", false):
				_arrow_landed(b)
			else:
				node.queue_free()
			_bolts.remove_at(i)


func _bolt_impact(b: Dictionary) -> void :
	var sk: Dictionary = b.skill
	var el: String = b.get("element", sk.get("element", "neutral"))
	damage_tag = b.get("tag", "")
	damage_by = b.get("by")
	var at: Vector3 = b.end
	var tgt = b.get("target")
	var radius: = float(b.radius)
	if radius > 0.0:
		_rebuild_grid()

		var knock: = float(sk.get("knock", 0.0))
		var mid: Vector3 = b.get("center", at)
		var cap: = int(sk.get("max_hits", 0))
		var struck: Dictionary = b.get("struck", {})
		for e in enemies_in_radius(at, radius):
			if cap > 0:
				var times: = int(struck.get(e, 0))
				if times >= cap:
					continue
				struck[e] = times + 1
			var push: = Vector3.ZERO
			if knock > 0.0:
				var away: = (e.position - mid) * Vector3(1, 0, 1)
				if away.length_squared() < 0.04:
					away = (e.position - at) * Vector3(1, 0, 1)
				if away.length_squared() > 0.0001:
					push = away.normalized() * knock
			damage_enemy(e, b.damage, push, "skill", el)
	elif tgt != null and is_instance_valid(tgt) and not tgt.dead:
		damage_enemy(tgt, b.damage, Vector3.ZERO, "skill", el)
		if float(sk.get("slow", 0.0)) > 0.0:
			tgt.slow_time = float(sk.slow)

		if sk.has("status") and not tgt.dead:
			try_status(tgt, sk, float(sk.get("status_chance", 0.0)))
	else:

		var near: = nearest_enemy(at, 1.2)
		if near != null:
			damage_enemy(near, b.damage, Vector3.ZERO, "skill", el)
	if b.get("hidden", false):
		return
	var hit_sound: String = sk.get("hit_sound", "")
	if hit_sound != "":
		var variants: = int(sk.get("hit_sound_variants", 0))
		var key: = hit_sound + (str(int(b.index) % variants + 1) if variants > 0 else "")
		play_sound(key, 0.05, -5.0)
	if sk.has("impact_tex"):
		_impact_flash(sk.impact_tex, at)




const RAIN_HIGH: = 9.0
const RAIN_SLANT: = 3.6
const RAIN_STUCK: = 0.45








func arrow_rain(p: Player, center: Vector3, sk: Dictionary, dmg: float, element: String, count: int, area: float) -> void :
	_rebuild_grid()
	var col: = rain_color(sk, element)
	var span: = float(sk.get("rain_span", 0.4))
	Vfx.rain_mark(fx_root, center, area, col, span + float(sk.get("bolt_time", 0.2)) + 0.15)
	Vfx.volley_up(fx_root, p.position + Vector3(0, 1.4, 0), col, mini(count, 7))
	var side: = (center - p.position) * Vector3(1, 0, 1)
	side = side.normalized() if side.length_squared() > 0.01 else Vector3(1, 0, 0)
	var inside: = enemies_in_radius(center, area).filter( func(e): return not e.dead)
	inside.sort_custom( func(a, b): return _flat_dist(a.position, center) < _flat_dist(b.position, center))
	var spots: Array = []
	spots.append_array(inside.slice(0, count))
	var free: = count - spots.size()
	var turn: = randf() * TAU
	for k in free:

		var r: = area * sqrt((k + 0.5) / free)
		var a: = turn + k * 2.39996
		spots.append(center + Vector3(cos(a), 0, sin(a)) * r)
	spots.shuffle()
	var hit: = float(sk.get("hit_radius", 1.0)) * sqrt(p.area_mult)
	var n: = spots.size()


	var struck: = {}
	for i in n:
		var e: Enemy = spots[i] if spots[i] is Enemy else null
		drop_bolt({"target": e, "point": e.position if e != null else spots[i], "skill": sk, "damage": dmg, 
			"element": element, "radius": hit, "center": center, "index": i, "struck": struck, 
			"delay": span * i / maxf(1.0, n - 1.0) + randf() * 0.03, 
			"sky": - side * RAIN_SLANT + Vector3(randf_range(-0.35, 0.35), RAIN_HIGH, randf_range(-0.35, 0.35))})




func rain_color(sk: Dictionary, element: String) -> Color:
	if element == "neutral" or not GameData.ELEMENT_COLORS.has(element):
		return sk.get("color", Color(1.0, 0.9, 0.6))
	return GameData.ELEMENT_COLORS[element]





func _arrow_landed(b: Dictionary) -> void :
	var node: MeshInstance3D = b.node
	var sk: Dictionary = b.skill
	var streak: = node.get_node_or_null("streak")
	if streak != null:
		streak.queue_free()
	var ground: Vector3 = b.end - Vector3(0, 0.4, 0)
	if not Vfx._skip(1):
		var col: = rain_color(sk, str(b.get("element", "neutral")))
		Vfx._quiet = true
		Vfx.burst(fx_root, ground, float(sk.get("hit_radius", 1.0)) * 0.6, Color(col.lightened(0.55), 0.7))
		Vfx._quiet = false
	if Vfx._skip(2):
		node.queue_free()
		return


	var fall: Vector3 = (b.end - b.start).normalized()
	node.position = ground - fall * (float(b.get("half", 0.5)) * 0.7)
	var mat: = node.material_override as StandardMaterial3D
	var tw: = node.create_tween()
	tw.tween_interval(RAIN_STUCK)
	tw.tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tw.tween_callback(node.queue_free)





func hitscan(p: Player, target: Enemy, dmg: float, pierce: int, element: String, sk: Dictionary, 
		status_chance: = 0.0, delay: = 0.0) -> void :
	if delay > 0.0:
		var tag: = damage_tag
		var by: = damage_by

		var ref: WeakRef = weakref(target)
		_own_timer(delay, func():
			var t = ref.get_ref()
			if running and t != null and not t.dead and hero_valid(p):
				damage_tag = tag
				damage_by = by
				hitscan(p, t, dmg, pierce, element, sk, status_chance))
		return
	var dir: = ((target.position - p.position) * Vector3(1, 0, 1)).normalized()


	_shot_tracer(p, target, sk)


	_hitscan_hit(p, target, dmg, dir, element, sk, status_chance)
	var bounces: = pierce
	if bounces > 0:
		_hitscan_bounce(p, target, dmg, bounces, element, sk, status_chance, {target: true}, 1)





const PIERCE_BURSTS_MAX: = 6
func pierce_shot(p: Player, target: Enemy, dmg: float, element: String, sk: Dictionary, length: float, width: float, 
		delay: = 0.0) -> void :
	if delay > 0.0:
		var tag: = damage_tag
		var by: = damage_by
		var ref: WeakRef = weakref(target)
		_own_timer(delay, func():
			var t = ref.get_ref()
			if running and t != null and not t.dead and hero_valid(p):
				damage_tag = tag
				damage_by = by
				pierce_shot(p, t, dmg, element, sk, length, width))
		return
	var dir: = ((target.position - p.position) * Vector3(1, 0, 1))
	if dir.length_squared() < 0.0001:
		dir = Vector3(0, 0, 1)
	dir = dir.normalized()
	var from: = p.position
	var push: = dir * float(sk.get("knock", 2.5))
	var bursts: = 0
	var struck: Array = []
	for e in enemies_in_radius(from + dir * length * 0.5, length * 0.5 + width):
		if e.dead:
			continue
		var rel: = (e.position - from) * Vector3(1, 0, 1)
		var along: = rel.dot(dir)
		if along < 0.0 or along > length or (rel - dir * along).length() > width * 0.5 + e.radius:
			continue
		struck.append(e)
	if not struck.has(target):
		struck.append(target)
	for e in struck:
		if e.dead:
			continue
		damage_enemy(e, dmg, push, "skill", element)
		if bursts < PIERCE_BURSTS_MAX and sk.get("hit_fx", "") != "":
			bursts += 1
			spawn_fx(sk.hit_fx, e.position + Vector3(0, 0.6, 0), 0.9, 1.0)
		if sk.get("status", "") != "":
			try_status(e, sk, 0.0)

	var a: = from + Vector3(0, 0.95, 0) + dir * 0.45
	var b: = from + Vector3(0, 0.95, 0) + dir * length
	var color: Color = sk.get("trace", sk.get("color", Color(0.8, 0.9, 1.0)))
	_tracer_part(a, b, 0.08, Color(1, 1, 1, 1.0), 0.2)
	_tracer_part(a, b, 0.5, Color(color, 0.55), 0.34)
	Vfx.burst(fx_root, a - Vector3(0, 0.85, 0), 0.9, color.lightened(0.3))
	Vfx.ring(fx_root, b - Vector3(0, 0.85, 0), 1.0, color, 0.25)



func _hitscan_hit(p: Player, e: Enemy, dmg: float, dir: Vector3, element: String, sk: Dictionary, status_chance: float, chain: = 0) -> void :
	if e.dead:
		return
	damage_enemy(e, dmg, dir * float(sk.get("knock", 0.5)), "basic" if sk.get("basic", false) else "skill", element)
	if sk.get("air_hit", false):
		Vfx.air_impact(fx_root, e.position + Vector3(0, 0.6, 0), dir, 0.8)
	elif sk.get("hit_fx", "") != "":

		spawn_fx(sk.hit_fx, e.position + Vector3(0, 0.6, 0), float(sk.get("hit_fx_size", 0.6 if sk.get("basic", false) else 1.0)), 
			sk.get("hit_fx_intensity", 1.0))
	elif sk.has("hit_sprite"):
		sprite_fx(str(sk.hit_sprite), e.position + Vector3(0, 0.7, 0), 0, 0.5)
	elif not sk.get("magic", false):
		spawn_fx("hit", e.position + Vector3(0, 0.7, 0), 0.7)




	if float(sk.get("impact", 0.0)) > 0.0 and Time.get_ticks_msec() >= _impact_next:

		_impact_next = Time.get_ticks_msec() + 50
		var tint: Color = sk.get("trail_tint", sk.get("color", Color.WHITE))
		Vfx.ring(fx_root, e.position + Vector3(0, 0.08, 0), float(sk.impact), Color(tint, 0.75), 0.28)
		Vfx.burst(fx_root, e.position, float(sk.impact) * 0.7, Color(tint, 0.6))
		shake(0.05 * float(sk.impact))
	if chain > 0:
		_bounce_feedback(e, chain, false)
	if sk.get("status", "") != "":
		try_status(e, sk, status_chance)
	if sk.get("basic", false):
		p.on_basic_hit(self, e)






func _bounce_target(from: Enemy, hit: Dictionary) -> Enemy:
	for reach in [4.0, 10.0, GameData.BOUNCE_RANGE]:
		var best: Enemy = null
		var best_d: = INF
		for o in enemies_in_radius(from.position, reach):
			if o == from or hit.has(o):
				continue
			var d: = from.position.distance_squared_to(o.position)
			if d < best_d:
				best_d = d
				best = o


		if best != null:
			return best
	return null




func _hitscan_bounce(p: Player, from: Enemy, dmg: float, left: int, element: String, sk: Dictionary, status_chance: float, hit: Dictionary, chain: int) -> void :
	var best: = _bounce_target(from, hit)

	if best == null and sk.get("self_bounce", false) and not from.dead:
		best = from
	if best == null:
		if chain - 1 >= GameData.BOUNCE_MARK:
			_bounce_mark(from, chain - 1)
		return
	hit[best] = true
	var a: = from.position
	if best == from:

		a = from.position + Vector3(randf_range(-1.6, 1.6), 0, randf_range(-1.6, 1.6))
	var tag: = damage_tag
	var by: = damage_by
	var ref: WeakRef = weakref(best)
	_bounce_trace(a, best.position, sk.get("trace", Color(1.0, 0.92, 0.6)))
	_own_timer(0.05, func():
		var t = ref.get_ref()
		if not running or t == null or t.dead or not hero_valid(p):
			return
		damage_tag = tag
		damage_by = by
		var d2: Vector3 = ((t.position - a) * Vector3(1, 0, 1)).normalized()
		var dmg2: = dmg * float(sk.get("bounce_grow", GameData.BOUNCE_DMG))
		_hitscan_hit(p, t, dmg2, d2, element, sk, status_chance, chain)
		if left > 1:
			_hitscan_bounce(p, t, dmg2, left - 1, element, sk, status_chance, hit, chain + 1)
		elif chain >= GameData.BOUNCE_MARK:
			_bounce_mark(t, chain))




const BOUNCE_TRACES_MAX: = 6
const BOUNCE_SPARKS_MAX: = 6
const BOUNCE_MARKS_MAX: = 1
var _bounce_fx_frame: = -1
var _bounce_fx_used: = {}
func _bounce_fx_ok(cap: int, kind: String) -> bool:
	var frame: = Engine.get_process_frames()
	if frame != _bounce_fx_frame:
		_bounce_fx_frame = frame
		_bounce_fx_used.clear()
	var n: = int(_bounce_fx_used.get(kind, 0))
	if n >= cap:
		return false
	_bounce_fx_used[kind] = n + 1
	return true




func summon_shot(kind: String, from: Vector3, to: Vector3) -> float:
	if net.recording():
		net.record(["Z", kind, from, to])
	var a: = from + Vector3(0, 0.7, 0)
	var b: = to + Vector3(0, 0.7, 0)
	var dur: = clampf(a.distance_to(b) / GameData.SUMMON_SHOT_SPEED, 0.08, 0.4)
	if not _fly_sprite(str(GameData.SUMMON_SHOTS.get(kind, "")), a, b, dur, 1.7):
		_bounce_trace(from, to, Color(1.0, 0.9, 0.6))
	return dur



func huuma_fall(at: Vector3, wait: float) -> void :
	if net.recording():
		net.record(["Y", at, wait])
	_own_timer(wait, func():
		if running:
			_fly_sprite("item_huuma", at + Vector3(2.0, 9.0, 0), at + Vector3(0, 0.4, 0), GameData.HUUMA_FALL, 3.6))




func burn_ember(from: Vector3, to: Vector3) -> void :
	if net.recording():
		net.record(["B", from, to])
	_fly_sprite("fx_kaensin", from + Vector3(0, 0.7, 0), to + Vector3(0, 0.7, 0), GameData.BURN_EMBER, 1.3)

	_own_timer(GameData.BURN_EMBER, func():
		if running:
			_fx_local = true
			Vfx._quiet = true
			spawn_fx("firepillar", to, 0.5, 0.9)
			Vfx.ring(fx_root, to, 1.1, GameData.BURN_COLOR, 0.25)
			Vfx._quiet = false
			_fx_local = false)



func _fly_sprite(key: String, a: Vector3, b: Vector3, dur: float, size: float) -> bool:
	if Vfx.hidden():
		return true
	var thrown: RoSprite = RoAssets.sprite([key])
	if thrown == null:
		return false
	var s: = Sprite3D.new()
	s.texture = thrown.get_frame(0, 0)
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	s.shaded = false
	s.pixel_size = GameData.PIXEL_SIZE * size
	s.position = a
	fx_root.add_child(s)
	var tw: = s.create_tween()
	tw.tween_method(_fly_summon_shot.bind(s, a, b), 0.0, 1.0, dur)
	tw.tween_callback(s.queue_free)
	return true


func _fly_summon_shot(k: float, s: Sprite3D, a: Vector3, b: Vector3) -> void :
	s.global_position = a.lerp(b, k) + Vector3(0, sin(k * PI) * 0.6, 0)
	s.global_basis = camera.global_basis * Basis(Vector3(0, 0, 1), k * TAU * 2.0)







const SHOT_TRACERS_MAX: = 8
func _shot_tracer(p: Player, target: Enemy, sk: Dictionary) -> void :
	if not _bounce_fx_ok(SHOT_TRACERS_MAX, "shot"):
		return
	var color: Color = sk.get("trace", sk.get("color", Color(1.0, 0.92, 0.6)))
	var from: = p.position + Vector3(0, 0.95, 0)
	var to: = target.position + Vector3(0, 0.75, 0)
	var flat: = (to - from) * Vector3(1, 0, 1)
	if flat.length() < 0.2:
		return

	from += flat.normalized() * 0.45
	var big: bool = not sk.get("basic", false)
	_tracer_part(from, to, 0.05 if big else 0.035, Color(1, 1, 1, 0.95), 0.14 if big else 0.1)
	if big:
		_tracer_part(from, to, 0.32, Color(color, 0.55), 0.26)
		Vfx.burst(fx_root, from - Vector3(0, 0.85, 0), 0.7, color.lightened(0.3))


func _tracer_part(from: Vector3, to: Vector3, width: float, color: Color, life: float) -> void :
	var length: = from.distance_to(to)
	var mi: = MeshInstance3D.new()
	var box: = BoxMesh.new()
	box.size = Vector3(width, width, length)
	mi.mesh = box
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_color = Color(color, color.a * Vfx.dim)
	m.no_depth_test = true
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fx_root.add_child(mi)
	mi.global_position = (from + to) * 0.5
	mi.look_at(to, Vector3.UP)
	var tw: = mi.create_tween()
	tw.tween_property(m, "albedo_color:a", 0.0, life)
	tw.parallel().tween_property(mi, "scale", Vector3(0.2, 0.2, 1.0), life).set_ease(Tween.EASE_IN)
	tw.tween_callback(mi.queue_free)


func _bounce_trace(a: Vector3, b: Vector3, color: Color) -> void :
	if not _bounce_fx_ok(BOUNCE_TRACES_MAX, "trace"):
		return
	var from: = a + Vector3(0, 0.75, 0)
	var to: = b + Vector3(0, 0.75, 0)
	var length: = from.distance_to(to)
	if length < 0.1:
		return
	var mi: = MeshInstance3D.new()
	var box: = BoxMesh.new()
	box.size = Vector3(0.05, 0.05, length)
	mi.mesh = box
	var m: = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_color = Color(color, 0.9 * Vfx.dim)
	m.no_depth_test = true
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fx_root.add_child(mi)
	mi.global_position = (from + to) * 0.5
	mi.look_at(to, Vector3.UP)
	var tw: = mi.create_tween()
	tw.tween_property(m, "albedo_color:a", 0.0, 0.16)
	tw.tween_callback(mi.queue_free)




func _bounce_feedback(e: Enemy, chain: int, last: bool) -> void :
	if not _bounce_fx_ok(BOUNCE_SPARKS_MAX, "spark"):
		return
	spawn_fx("hit", e.position + Vector3(randf_range(-0.15, 0.15), 0.7, 0), 0.55 + 0.05 * mini(chain, 6), 0.9)
	play_sound("arrow_hit", 0.03, -7.0 + (3.0 if last else 0.0), (0.75 if last else 1.0 + 0.07 * mini(chain, 8)))







const BOUNCE_MARKS_ALIVE: = 3
const BOUNCE_MARK_EVERY: = 1.4
var _bounce_marks: Array = []
var _bounce_mark_at: = -9.0
var _bounce_mark_n: = 0
func _bounce_mark(e: Enemy, chain: int) -> void :
	if e == null or not is_instance_valid(e):
		return
	if time >= _bounce_mark_at and time - _bounce_mark_at < BOUNCE_MARK_EVERY and chain + 1 <= _bounce_mark_n:
		return
	if not _bounce_fx_ok(BOUNCE_MARKS_MAX, "mark"):
		return
	_bounce_mark_at = time
	_bounce_mark_n = chain + 1
	_bounce_marks = _bounce_marks.filter( func(n): return is_instance_valid(n))
	while _bounce_marks.size() >= BOUNCE_MARKS_ALIVE:
		_bounce_marks.pop_front().queue_free()
	_bounce_marks.append(_chain_count(e.position + Vector3(0, e.visual.height() * 0.6 + 1.6, 0), chain + 1, Color(1.0, 0.7, 0.25), true, tr("rebotes")))




func ice_trail(from: Vector3, target: Enemy, dmg: float, sk: Dictionary, status_chance: float) -> void :
	var tex: = RoAssets.effect_tex("frost_crystal")
	var tag: = damage_tag
	var by: = damage_by
	var to: = (target.position - from) * Vector3(1, 0, 1)
	var steps: = maxi(2, int(to.length() / 0.8))
	for i in steps + 1:
		var f: = float(i) / float(steps)
		var at: = from + to * f
		at.y = map.height_at(at)
		var last: = i == steps
		var ref: WeakRef = weakref(target)
		_own_timer(0.035 * i, func():
			if not running:
				return
			if tex != null:
				_ice_crystal(tex, at, 1.6 if last else 0.75 + 0.35 * f)
			var hit: Enemy = ref.get_ref()
			if last and hit != null and not hit.dead:
				damage_tag = tag
				damage_by = by
				damage_enemy(hit, dmg, Vector3.ZERO, "skill", sk.get("element", "water"))
				try_status(hit, sk, status_chance)
				play_sound(sk.get("hit_sound", ""), 0.08, -5.0))


func _ice_crystal(tex: Texture2D, at: Vector3, size: float) -> void :
	var s: = Sprite3D.new()
	s.texture = tex
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	s.pixel_size = size / float(tex.get_width())
	s.offset = Vector2(0, tex.get_height() * 0.32)
	s.position = at
	s.render_priority = 5
	var mat: = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.albedo_texture = tex
	s.material_override = mat
	fx_root.add_child(s)
	s.scale = Vector3(0.2, 0.2, 0.2)
	var tw: = s.create_tween()
	tw.tween_property(s, "scale", Vector3.ONE, 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.35)
	tw.tween_property(s, "modulate:a", 0.0, 0.3)
	tw.tween_callback(s.queue_free)



func _impact_flash(tex_key: String, at: Vector3) -> void :
	if bool(Save.setting("no_flash", false)):
		return
	var tex: = RoAssets.effect_tex(tex_key)
	if tex == null:
		return
	var s: = Sprite3D.new()
	s.texture = tex
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = 6
	s.modulate.a = Vfx.dim
	s.pixel_size = GameData.PIXEL_SIZE
	s.position = at
	fx_root.add_child(s)
	var tw: = s.create_tween()
	tw.tween_property(s, "modulate:a", 0.0, 0.25)
	tw.tween_callback(s.queue_free)


const FALCON_DIVE_HIGH: = 8.0
const FALCON_DIVE_SCALE: = 2.0




func _falcon_impact(ground: Vector3, area: float) -> void :
	Vfx.burst(fx_root, ground + Vector3(0, 0.5, 0), area * 1.3, Color(1.0, 0.9, 0.6))
	Vfx.ring(fx_root, ground + Vector3(0, 0.05, 0), area * 1.5, Color(1.0, 0.8, 0.4), 0.35)
	Vfx.ring(fx_root, ground + Vector3(0, 0.05, 0), area * 2.2, Color(1.0, 0.95, 0.75), 0.55)
	_falcon_pillar(ground, area, 0.4)
	var tex: = RoAssets.effect_tex("lv99_star")
	if tex != null and not Vfx.hidden():
		for k in 12:
			var sp: = Sprite3D.new()
			sp.texture = tex
			sp.modulate = Color(Color(1.0, 0.9, 0.5) if k % 2 == 0 else Color(1.0, 0.65, 0.25), Vfx.dim)
			sp.pixel_size = 0.5 / tex.get_width()
			sp.material_override = _spark_mat(tex)
			sp.position = ground + Vector3(0, 0.6, 0)
			fx_root.add_child(sp)
			var a: = TAU * k / 12.0 + randf_range(-0.2, 0.2)
			var tw: = sp.create_tween().set_parallel()
			tw.tween_property(sp, "position", sp.position + Vector3(cos(a), 0.3, sin(a)) * area * randf_range(1.0, 1.6), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tw.tween_property(sp, "modulate:a", 0.0, 0.3).set_delay(0.12)
			tw.chain().tween_callback(sp.queue_free)
	shake(0.4)
	play_sound("hit_fist", 0.05, -4.0)



func _falcon_pillar(ground: Vector3, width: float, life: float) -> void :
	if Vfx.hidden():
		return
	var beam: = Vfx.beam(fx_root, ground, Color(1.0, 0.85, 0.45), FALCON_DIVE_HIGH + 1.0)
	(beam.material_override as StandardMaterial3D).billboard_keep_scale = true
	beam.scale = Vector3(width, 1, 1)
	var tw: = beam.create_tween()
	tw.tween_property(beam, "scale:x", 0.01, life).set_ease(Tween.EASE_IN)
	tw.tween_callback(beam.queue_free)





func hunter_mark(e: Enemy) -> void :
	if is_instance_valid(e) and not e.dead:
		e.set_meta("hunter_mark", clock + GameData.HUNTER_MARK_TIME)



func _arrow_tag(tag: String) -> bool:
	if tag == "basic":
		return true
	var sid: = GameData.skill_of_tag(tag)
	return sid != "" and bool(GameData.SKILLS[sid].get("uses_arrows", false))


func falcon_strike(p: Player, targets: Array, dmg: float, area: float, sk: Dictionary) -> void :
	dmg *= 1.0 + float(p.effects.get("falcon_dmg", 0.0))

	var el: = Skills.element_of(p, sk)
	dmg *= float(p.get_meta("blitz_mult", 1.0))
	p.set_meta("blitz_mult", 1.0)

	if int(p.get_meta("falcons", 0)) >= GameData.FALCONS_MAX and sk.get("type", "") != "falcon_assault":
		play_sound(sk.get("sound", ""), 0.15, -6.0)
		var hit_tag: = damage_tag
		for t in targets:
			if is_instance_valid(t):
				for e in enemies_in_radius(t.position, area):
					damage_enemy(e, dmg, Vector3.ZERO, "skill", el, hit_tag)
					hunter_mark(e)
		return
	p.set_meta("falcons", int(p.get_meta("falcons", 0)) + 1)

	var assault: bool = sk.get("type", "") == "falcon_assault"
	p._falcon_away = 0.3 + (0.45 if assault else 0.25) * targets.size()
	var tag: = damage_tag
	var by: = damage_by
	var dim: = Vfx.dim
	var spr: = RoAssets.sprite(["fx_falcon_sniper", "fx_falcon"] if p.reborn else ["fx_falcon"])
	var bird: = RoVisual.new()
	fx_root.add_child(bird)
	bird.setup(spr, Color(0.8, 0.6, 0.3), 24, 0.0)
	bird.position = p.position + Player.FALCON_SPOT
	bird.play(0, true)

	bird.sprite.no_depth_test = true
	bird.sprite.render_priority = 7
	var tw: = bird.create_tween()
	var from: = bird.position
	for t in targets:
		var at: Vector3 = t.position + Vector3(0, 1.8, 0)
		var ground: Vector3 = t.position
		if assault:

			at = ground + Vector3(0, 0.8, 0)
			var high: = ground + Vector3(0, FALCON_DIVE_HIGH, 0)
			tw.tween_callback( func():
				bird.scale = Vector3.ONE * FALCON_DIVE_SCALE
				bird.face(high - bird.position)
				fx_with(dim, func(): Vfx.converge(fx_root, ground, area * 1.3, Color(1.0, 0.8, 0.4), 0.3)))
			tw.tween_property(bird, "position", high, maxf(0.2, from.distance_to(high) / 45.0)).set_trans(Tween.TRANS_SINE)
			tw.tween_callback( func():
				bird.face(at - bird.position)
				fx_with(dim, func(): _falcon_pillar(ground, 0.6, 0.22)))
			tw.tween_property(bird, "position", at, 0.1).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		else:
			tw.tween_callback( func(): bird.face(at - bird.position))
			tw.tween_property(bird, "position", at, maxf(0.12, from.distance_to(at) / 28.0))
		tw.tween_callback( func():
			play_sound(sk.get("sound", ""), 0.1, -4.0)
			_rebuild_grid()


			var alive: bool = is_instance_valid(t) and not t.dead
			var hit_at: Vector3 = t.position if alive else ground
			var struck: = enemies_in_radius(hit_at, area)
			if alive and not struck.has(t):
				struck.append(t)



			var keep_by: = damage_by
			damage_by = by if by != null and is_instance_valid(by) else (p if is_instance_valid(p) else null)
			for e in struck:

				var boss_k: = GameData.FALCON_ASSAULT_BOSS if assault and e.is_boss and sk.get("evolved", false) else 1.0
				damage_enemy(e, dmg * boss_k, Vector3.ZERO, "skill", el, tag)
				hunter_mark(e)
			damage_by = keep_by
			if assault:
				fx_with(dim, func(): _falcon_impact(hit_at if alive else ground, area)))
		from = at
	tw.tween_callback( func():
		bird.scale = Vector3.ONE
		bird.face(p.position - bird.position))
	tw.tween_property(bird, "position", p.position + Player.FALCON_SPOT, 0.25)
	tw.tween_callback( func():
		p.set_meta("falcons", maxi(0, int(p.get_meta("falcons", 1)) - 1))
		bird.queue_free())


func _kill(e: Enemy) -> void :




	if e.dead or e.has_meta("killed"):
		return
	e.set_meta("killed", true)


	if e.def.get("dummy", false):
		e.remove_meta("killed")
		e.hp = e.max_hp
		return


	if training and not festival_mode and not e.has_meta("festival"):
		enemies.erase(e)
		_grid_fresh = false
		_clear_marks(e)
		e.die()
		return
	if e.prop != "":
		_break_prop(e)
		return


	if e.has_meta("festival"):
		enemies.erase(e)
		_grid_fresh = false
		_clear_marks(e)
		e.die()
		return

	if e.has_meta("mvp_shadow"):
		enemies.erase(e)
		_grid_fresh = false
		_clear_marks(e)
		e.die()
		hell_late.shadow_down(e)
		return








	var held: = maxi(1, int(e.get_meta("fused", 1)))
	kills += held if tower != null else 1
	var fused: = _fuse_rolls(held)
	enemies.erase(e)
	_clear_marks(e)

	if encore.on:
		encore.on_kill(self, e)
	if e.has_meta("profane"):
		hell_late.profane_down(e)

	if e.is_boss and not oaths.is_empty():
		oath_run.boss_down(self)

	var killer: Player = e.last_hit_by if hero_valid(e.last_hit_by) else player
	_grid_fresh = false


	var stew_party: = heroes.size() > 1 and killer.has_dish("immortal_stew")
	killer.on_kill( not stew_party)
	if stew_party:
		for h in heroes:
			if is_instance_valid(h):
				h.stew_gain()
	if killer.has_uniq:
		Uniques.on_kill(self, killer, e)

	if e.has_meta("plague_until"):
		Uniques.plague_death(self, e)
	if not killer.toys.is_empty():
		hell_late.on_kill(killer, e)


	if _is_route_mvp(e):
		e.set_meta("route_mvp", true)
	karma.on_kill(e, killer)
	killer.gain_coin(self, 1.0 - pow(0.75, fused))
	if float(killer.effects.get("kill_heal", 0.0)) > 0.0:
		killer.hp = minf(killer.max_hp, killer.hp + killer.max_hp * float(killer.effects.kill_heal))
	e.die()
	play_mob_sound(e.id, "die")
	if e.xp > 0:
		_soul_color = GameData.ELEMENT_COLORS.get(e.element(), Color(0.75, 0.9, 1.0))
		_drop_xp(e.position, e.xp)


	var rose: = false
	if e.kin != 0:
		rose = e.kin == MobTraits.RISE and e.has_meta("rose")
		traits.fell(e, self)
	if not rose:
		_drop_loot(e, fused)
	var card: String = e.def.get("card", "") if not rose else ""


	var prize: bool = e.def.get("elite", false) and not e.summoned


	var drop: = 1.0 + float(killer.effects.get("drop_find", 0.0))

	var mats: = drop * oath_mats()
	if prize:
		_drop_chest(e.position, GameData.CHEST_ROLLS.elite, 0)
		_drop_ore(e.position, _mat_count(1, mats))
	elif e.is_boss and not e.def.get("mvp", false) and not e.summoned:
		_drop_chest(e.position, GameData.CHEST_ROLLS.boss, 1)
		_drop_ore(e.position, _mat_count(3, mats))
		if randf() < GameData.BOSS_ENRICHED_CHANCE * GameData.danger_reward(danger) * mats:
			var mat: String = ["enriched_oridecon", "enriched_elunium"].pick_random()
			gain_material(mat)
			number(e.position + Vector3(0, 2.0, 0), tr("%s (para el refinador)") % tr(GameData.MATERIALS[mat].name), Color(0.7, 0.85, 1.0), true)
	if e.def.get("mvp", false):
		_mvp_tomb(e)
		run_mvps += 1
		if first_mvp_time < 0.0:
			first_mvp_time = time
		_fight_card(e)

		titles.mvp_feats(self)


	var crumbs: = 0 if e.summoned or training else _hits(star_crumb_chance(e) * drop, fused)
	if crumbs > 0:
		for i in crumbs:
			gain_material("star_crumb")
		number(e.position + Vector3(0, 2.2, 0), tr("¡Star Crumb!") if crumbs == 1 else "%s x%d" % [tr("¡Star Crumb!"), crumbs], GameData.POTENTIAL_TIERS[2].color, true)
		Vfx.column(fx_root, e.position, Color(0.85, 0.8, 1.0))
		play_sound("drop_purple", 0.0, -4.0)
	if e.special == "runner" and e.has_meta("treasure_floor"):

		for i in 3:
			_runner_coins(e.position, roundi(float(GameData.RUNNER.catch_zeny) * 0.05 * GameData.danger_reward(danger)))
		number(e.position + Vector3(0, 2.2, 0), tr("¡Atrapado!"), GameData.RUNNER.color, true)
		play_sound("coin1", 0.0, -2.0)
	elif e.special == "runner":

		_drop_chest(e.position, GameData.CHEST_ROLLS.golden_poring, 3)



		_drop_ore(e.position, _mat_count(GameData.GOLD_PORING_ORES, mats))
		if not training and randf() < GameData.GOLD_PORING_CRUMB * drop:
			gain_material("star_crumb")
			number(e.position + Vector3(0, 2.6, 0), tr("¡Star Crumb!"), GameData.POTENTIAL_TIERS[2].color, true)
		if not training and randf() < GameData.GOLD_PORING_COIN * drop:
			found_coin()

			if net.is_host():
				for h in heroes:
					if h != player:
						net.send_got(h, "coin", 1)

		var hoard: = roundi(float(GameData.RUNNER.catch_zeny) * GameData.danger_reward(danger))
		var coins: = int(GameData.RUNNER.catch_coins)
		for i in coins:
			_runner_coins(e.position, floori(float(hoard) / coins) + (hoard % coins if i == 0 else 0))
		number(e.position + Vector3(0, 2.2, 0), tr("¡Atrapado!"), GameData.RUNNER.color, true)
		party_announce(tr("¡Poring Dorado atrapado!"), GameData.RUNNER.color, tr("Su tesoro: +%d zeny") % roundi(hoard * killer.loot_mult))
		play_sound("coin1", 0.0, -2.0)
		play_sound("coin3", 0.0, -4.0)
		Save.bump("gold_poring")

	if GameData.hell_level(danger) >= 4 and not e.is_boss and time - _hell_revenge_at >= GameData.HELL_REVENGE_GAP\
	and randf() < GameData.HELL_REVENGE_CHANCE:
		_hell_revenge_at = time
		_hell_blast([e.position], GameData.HELL_REVENGE_SIZE, GameData.HELL_REVENGE_CAST, GameData.HELL_REVENGE_PCT, "hell_in", Color(1, 0.2, 0.05), "meteor", "Venganza de los caídos")
	_hell_rise(e)
	if not rose:
		_drop_specials(e, drop, fused)

	if not prize and not e.is_boss and not rose:
		var box_chance: float = float(GameData.FEROCIOUS.chest) if e.feroz\
		else GameData.SMALL_CHEST_CHANCE * killer.card_mult * GameData.danger_boxes(danger) * karma.box_mult()
		for i in _hits(box_chance * drop / GameData.coop_spawn(heroes.size()), fused):
			_drop_chest(e.position + Vector3(-0.5, 0, 0.3) if i == 0 else map.random_point_around(e.position, 1.2), 1, -1)
	var card_chance: float = (GameData.ELITE_CARD_CHANCE if prize else (float(GameData.FEROCIOUS.card) if e.feroz else GameData.CARD_DROP_CHANCE)) * GameData.danger_cards(danger)

	var boss_card: bool = e.is_boss and not e.summoned
	if boss_card and killer == player:
		_plagiarize(e)
	elif boss_card and killer != null and net.is_remote(killer) and killer.can_copy():

		net.send_got(killer, "plagiarize", e.id)
	if boss_card:
		card_chance = GameData.MVP_CARD_CHANCE if e.def.get("mvp", false) else GameData.BOSS_CARD_CHANCE


		if e.def.get("mvp", false) and pride_on():
			card_chance *= GameData.PRIDE_CARD









	var fight_own: = e.summoned and not _wild_mob(e.id)


	if (endless or GameData.hell_level(danger) >= 1) and not _is_stage_mob(e.id) and not _is_route_mvp(e) and not fight_own and not morroc.is_boss(e):
		var pool: = _stage_cards(e.is_boss)
		card = "" if pool.is_empty() else str(pool.pick_random())


	if not boss_card:
		card_chance /= GameData.coop_spawn(heroes.size())


	var pity: = card if boss_card and not e.def.get("mvp", false) and GameData.CARDS.has(card) and not training else ""
	var pity_at: = GameData.BOSS_CARD_PITY


	if pity == "" and e.summoned and not e.is_boss and raid.active() and not training\
	and GameData.CARDS.has(card) and card == str(e.def.get("card", "")) and not _wild_mob(e.id):
		pity = card
		pity_at = GameData.MVP_SUMMON_CARD_PITY
	var sure: = pity != "" and Save.card_misses(pity) >= pity_at
	var got: = GameData.CARDS.has(card) and not rose and (sure or randf() < card_chance * drop * (1.0 if boss_card else killer.card_mult))
	if pity != "":
		Save.set_card_misses(pity, 0 if got else Save.card_misses(pity) + 1)


	var cards_got: = 1 if got else 0
	var ores_got: = 0
	var potions_got: = 0
	for i in fused:
		if rose:
			break
		if i == 0 and got:
			continue
		if i > 0 and GameData.CARDS.has(card) and randf() < card_chance * drop * (1.0 if boss_card else killer.card_mult):
			cards_got += 1
		elif randf() < GameData.ORE_DROP_CHANCE / GameData.coop_spawn(heroes.size()) * drop * oath_mats():
			ores_got += 1
		elif randf() < GameData.POTION_DROP_CHANCE:
			potions_got += 1


	if pity != "" and cards_got > 0 and not got:
		Save.set_card_misses(pity, 0)
	for i in cards_got:
		_drop_item(e.position + Vector3(0.6, 0, 0) if i == 0 else map.random_point_around(e.position, 1.2), "card", card)
	if ores_got > 0:
		_drop_ore(e.position, ores_got)

	for i in mini(potions_got, 3):
		_drop_item(e.position if i == 0 else map.random_point_around(e.position, 1.0), "potion", "")




	if not rose and not training and not e.summoned and run_mob_coins < GameData.MOB_COIN_MAX\
	and (killer == null or killer == player or net.is_remote(killer))\
	and randf() < 1.0 - pow(1.0 - GameData.MOB_COIN_CHANCE * drop / GameData.coop_spawn(heroes.size()), fused):
		run_mob_coins += 1
		if killer == null or killer == player:
			found_coin()
		else:
			net.send_got(killer, "coin", 1)

	if morroc.is_boss(e):
		boss = null
		Save.add_boss_kill()
		run_bosses += 1
		morroc.on_killed(e)
	if e == boss:
		boss = null
		if e.is_boss:
			Save.add_boss_kill()
			run_bosses += 1
		if e.def.get("mvp", false):
			raid.on_boss_killed(e)
			var on_route: = karma.route != ""



			var uniq_id: = "" if on_route else (_roll_unique_party(GameData.UNIQUE_MVP_CHANCE) if heroes.size() > 1 else _roll_unique(GameData.UNIQUE_MVP_CHANCE))
			if uniq_id != "":
				_drop_chest(map.random_point_around(e.position, 1.2), 0, 2, uniq_id)
			if on_route:
				karma.route_won(e)
			emote(player, "grats")
			_mvp_fanfare(e.position)
			for i in 12:
				_drop_xp(map.random_point_around(e.position, 2.0), 5)


			if tower != null and e.id == GameData.TOWER_LORD:
				_drop_chest(e.position, GameData.MAX_CHEST_ROLLS, 3, "", false, false, "", true)

				if heroes.any(_wings_due):
					get_tree().create_timer(1.6, false).timeout.connect(_award_tower_wings.bind(e.position))


				if tower.hel != null and heroes.any(_hel_wings_due):
					get_tree().create_timer(3.6, false).timeout.connect(_award_hel_wings.bind(e.position))
				party_announce(tr("¡Tesoro de la Torre!"), Color(1.0, 0.85, 0.35), tr("El tesoro de Naght Sieger es tuyo"))
			else:

				_drop_chest(e.position, GameData.CHEST_ROLLS.boss, 2, "", false, false, "", false, on_route)

			if on_route and not endless:

				get_tree().create_timer(1.2, false).timeout.connect(_pull_prizes)
				get_tree().create_timer(3.0, false).timeout.connect(_victory_when_collected.bind(0))
			elif not endless:


				var region: = GameData.stage_region(stage_id)
				for rid in GameData.REGIONS:
					if str(GameData.REGIONS[rid].get("unlock", "")) == region and not Save.region_unlocked(rid):
						newly_unlocked = rid
				Save.clear_stage(stage_id)
				if hard:
					Save.clear_stage_hard(stage_id)
				if Save.beat_danger(stage_id, danger):
					get_tree().create_timer(1.6, false).timeout.connect( func():
						hud.announce(tr("¡%s desbloqueado!") % GameData.danger_name(Save.max_danger()), Color(1.0, 0.55, 0.3), tr("Elígelo en cualquier mapa")))


				get_tree().create_timer(1.2, false).timeout.connect(_pull_prizes)
				get_tree().create_timer(3.0, false).timeout.connect(_victory_when_collected.bind(0))





func _roll_unique(chance: float) -> String:
	var id: = GameData.unique_of_stage(stage_id, player.equipment.job_id if player != null else "")

	if id == "" or player == null or tower != null:
		return ""

	var shared: = GameData.stage_shared_uniques(stage_id)
	if shared.size() > 1 and shared.has(id):
		id = str(shared.pick_random())
	chance *= GameData.unique_mult(danger)


	if _has_unique(player, id):
		chance *= GameData.UNIQUE_OWNED_MULT
	if GameData.has_meta("force_unique"):
		chance = 1.0
	if randf() >= chance:
		return ""
	return id




func _found_unique(id: String) -> Dictionary:
	var it: = Equipment.make(id, 0)
	Save.mark_seen("uniques", id)
	if id == GameData.TOWER_WINGS:
		_wings_got(player)
	var stored: = Save.add_to_storage(it, true)
	if stored:
		run_stored.append(it.duplicate(true))

	var d: = Equipment.item_def(it)
	var r: = {}
	if (d.slot == "weapon" and not player.equipment.usable_weapon(id)) or (d.slot == "shield" and not player.equipment.usable_shield()):
		player.equipment.bag.append(it)
		r = {"item": it, "result": "bagged", "slot": str(d.slot), "zeny": 0}
	else:
		r = player.equipment.receive(it)
	player.recompute()
	r["stored"] = stored
	emote(player, "omg", 3.0)
	shake(0.5)
	return r



func _wings_due(h: Player) -> bool:
	var id: = GameData.TOWER_WINGS
	if h.equipment.has_item(id) or h.equipment.bag.any( func(b): return str(b.id) == id):
		return false
	return not (Save.tower_wings() if h == player else h.profile.get("tower_wings", []) as Array).has(h.class_id)




func _award_tower_wings(at: Vector3) -> void :
	if not running:
		return
	for h in heroes.duplicate():
		if not is_instance_valid(h) or not _wings_due(h):
			continue
		var it: = Equipment.make(GameData.TOWER_WINGS, 0)
		if h == player:
			var r: = _found_unique(GameData.TOWER_WINGS)
			_open_chest_show(at, 3, [r], tr("Alas de la Torre"))
		elif net.is_remote(h):
			if h.equipment.can_wear(it):
				h.equipment.receive(it)
			else:
				h.equipment.bag.append(it)
			h.recompute()
			h.profile["tower_wings"] = (h.profile.get("tower_wings", []) as Array) + [h.class_id]
			net.send_got(h, "unique", it)
		else:
			give_item(h, it)
			_wings_got(h)
		_loot_toast(h, it, "unique")
		Vfx.column(fx_root, h.position, Color(1.0, 0.9, 0.55))




func _hel_wings_due(h: Player) -> bool:
	if not is_instance_valid(h):
		return false
	return not (Save.hel_wings() if h == player else h.profile.get("hel_wings", []) as Array).has(h.class_id)




func _award_hel_wings(_at: Vector3) -> void :
	if not running:
		return
	for h in heroes.duplicate():
		if not _hel_wings_due(h):
			continue
		if h == player:
			_hel_rose_got(h)
		elif net.is_remote(h):
			h.profile["hel_wings"] = (h.profile.get("hel_wings", []) as Array) + [h.class_id]
			net.send_got(h, "hel_rose", h.class_id)
		else:
			continue
		Vfx.column(fx_root, h.position, GameData.HEL_WINGS_COLOR)



func _hel_rose_got(h: Player) -> void :
	if not Save.give_hel_rose(h.class_id):
		return
	prize_shown(GameData.HEL_WINGS_ITEM, 1)
	party_announce(tr("¡Réquiem de Hel!"), GameData.HEL_WINGS_COLOR, tr("Llévalo a la Valkyria: despierta tus Alas de Espada"))
	play_sound("drop_yellow", 0.0, 0.0)
	emote(h, "omg", 3.0)
	shake(0.4)




func _wings_got(h: Player) -> void :
	if h == player:
		Save.add_tower_wings(h.class_id)
		return
	h.profile["tower_wings"] = (h.profile.get("tower_wings", []) as Array) + [h.class_id]
	net.send_got(h, "wings", h.class_id)



func _pull_prizes() -> void :
	for p in pickups:
		if p.kind in ["chest", "card", "xp", "loot", "ore"]:
			p.pull = true



func _victory_when_collected(tries: int) -> void :
	if not running:
		return

	var waiting: = (tries < 60 and (busy() or pickups.any( func(p): return p.kind in ["chest", "card"])))\
	or _loot != null or not loot_queue.is_empty()
	if waiting:
		_pull_prizes()
		get_tree().create_timer(0.5, false).timeout.connect(_victory_when_collected.bind(tries + 1))
		return
	if menus.auto_pick and not "--endless" in OS.get_cmdline_user_args() and not GameData.has_meta("karma_test"):
		_end_run(true)
	elif raid.in_arena():
		raid.offer_exits()
	else:
		menus.show_victory_choice()



var _counted_word: Node3D = null









func number(at: Vector3, text: String, color: Color, big: = false, ultra: = false, lethal: = false, crit_k: = 1.0, grows: = false, dressed: = true, crit_size: = false, crit_kind: = "", text_k: = 1.0) -> Node3D:
	if net.recording():
		net.record(["n", at, text, color, big, ultra, lethal, crit_k, dressed, crit_size, crit_kind, text_k])


	var on_hero: = player != null and _flat_dist(at, player.position) < 0.3



	if player != null and not on_hero:
		var off: = (at - player.position) * Vector3(1, 0, 1)
		if off.length() < GameData.NUMBER_HERO_GAP:
			var away: = off.normalized() if off.length() > 0.05 else (camera.global_basis.x * Vector3(1, 0, 1)).normalized() if camera != null else Vector3.RIGHT
			at = player.position + away * GameData.NUMBER_HERO_GAP + Vector3(0, at.y - player.position.y + GameData.NUMBER_HERO_LIFT, 0)


		if camera != null:
			var right: = (camera.global_basis.x * Vector3(1, 0, 1)).normalized()
			var ahead: = ( - camera.global_basis.z * Vector3(1, 0, 1)).normalized()
			var rel: = (at - player.position) * Vector3(1, 0, 1)
			var side: = rel.dot(right)
			if absf(side) < GameData.NUMBER_HERO_SIDE and rel.dot(ahead) < GameData.NUMBER_HERO_ABOVE:
				var way: = signf(side) if absf(side) > 0.05 else (1.0 if randf() < 0.5 else -1.0)
				at += right * (way * GameData.NUMBER_HERO_SIDE - side)


	var mode: = number_mode()

	if mode == "none" and (text.is_valid_int() or text.is_valid_float()):
		return null



	var important: = _num_priority
	_num_priority = false
	if text.is_valid_int():
		var now_s: = Time.get_ticks_msec() * 0.001
		var value: = text.to_float()


		if not _num_zone:
			_num_peak = maxf(_num_peak * pow(0.5, maxf(0.0, now_s - _num_peak_at) / NUMBER_PEAK_HALF), value)
			_num_peak_at = now_s
		important = important or (value >= _num_peak * NUMBER_IMPORTANT and value >= _num_avg * NUMBER_STANDOUT)

		var now_ms: = Time.get_ticks_msec()
		if not important and not on_hero and not _num_zone and value >= _num_avg and now_ms - _num_trickle_at >= NUMBER_TRICKLE_MS:
			important = true
		if important:
			_num_trickle_at = now_ms


		if _num_zone and not important and _live_numbers.size() >= NUMBER_CALM:
			return null
		if not _num_zone:
			_num_avg = lerpf(_num_avg, value, NUMBER_AVG_K) if _num_avg > 0.0 else value

		if mode == "reduced" and not on_hero and not important and not ultra:
			return null
	_prune_numbers()

	if text.is_valid_int() and not on_hero and _live_numbers.size() >= NUMBER_HARD_MAX:
		return null
	if not on_hero and not important and (_numbers >= 36 or (_numbers >= 30 and not big)):
		return null






	var show_star: = ultra
	if text.is_valid_int() and not on_hero:
		var value: = text.to_float()
		var crowd: = _live_numbers.size()
		if not important and (crowd >= NUMBER_LIVE_MAX or (crowd >= NUMBER_CALM and value < _num_peak * NUMBER_SMALL)):
			return null
		show_star = ultra and (important or _live_stars.size() < NUMBER_STARS_MAX) and (crowd < NUMBER_CALM or value >= _num_peak * NUMBER_STAR_SHARE)
	_numbers += 1
	var key: = Vector3i(roundi(at.x * 2.0), roundi(at.y * 2.0), roundi(at.z * 2.0))
	var bucket: Dictionary = _number_buckets.get(key, {"until": -1.0, "count": 0})
	if bucket.until < _number_clock:
		bucket = {"until": _number_clock + 0.28, "count": 0}
	var stack_index: int = bucket.count
	bucket.count = stack_index + 1
	bucket.until = _number_clock + 0.28
	_number_buckets[key] = bucket



	var side_offset: = 0.0
	var rise_offset: = 0.78






	show_star = show_star and dressed
	var batched: = text.is_valid_int() and not show_star and not RoAssets.glyph_atlas().is_empty()
	var size_k: = _number_size(text.to_float()) if grows else (NUMBER_CRIT_SCALE if crit_size else 1.0)
	var tex: Texture2D = null
	if not batched:
		tex = RoAssets.damage_text(text) if text.is_valid_int() or text == "Miss" else null
	var l: Node3D
	if batched:
		var s: = Sprite3D.new()
		s.modulate = color
		if lethal:
			s.modulate = Color(1.0, 0.92, 0.2)
		elif ultra and big:
			s.modulate = Color(1.0, 0.97, 0.55)
		s.pixel_size = GameData.PIXEL_SIZE * (2.5 if lethal else (2.25 if ultra else (2.0 if big else 1.75))) * (crit_k if big else 1.0) * size_k
		if grows:
			s.set_meta("size_k", size_k)
		if ultra or lethal or crit_kind != "":
			s.set_meta("burst", "lethal" if lethal else ("ultra" if ultra else crit_kind))

			s.set_meta("crit_magic", crit_kind == "magic")
			s.set_meta("born", Time.get_ticks_msec())
		s.set_meta("digits", RoAssets.shown_digits(text))
		_num_batch.append(s)
		l = s
	elif tex != null:

		var s: = Sprite3D.new()
		s.texture = tex
		s.modulate = color

		if lethal:
			s.modulate = Color(1.0, 0.92, 0.2)
		elif ultra and big:

			s.modulate = Color(1.0, 0.97, 0.55)

		s.pixel_size = GameData.PIXEL_SIZE * (2.5 if lethal else (2.25 if ultra else (2.0 if big else 1.75))) * (crit_k if big else 1.0) * (0.6 if text == "Miss" else 1.0) * size_k
		if grows:
			s.set_meta("size_k", size_k)
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.no_depth_test = true
		s.shaded = false
		s.render_priority = 17
		if ultra:

			var glow: = Sprite3D.new()
			glow.texture = tex
			glow.modulate = Color(1.0, 0.75, 0.35, 0.45)
			glow.pixel_size = s.pixel_size * 1.18
			glow.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
			glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			glow.no_depth_test = true
			glow.shaded = false
			glow.render_priority = 16
			s.add_child(glow)
			var gt: = glow.create_tween()
			gt.tween_interval(0.6)
			gt.tween_property(glow, "modulate:a", 0.0, 0.3)
		if show_star and text != "Miss":
			_crit_dressing(s, tex, ultra, lethal, crit_kind == "magic")
			_live_stars.append(s)
		l = s
	else:
		var label: = Label3D.new()
		label.text = text
		label.font = RO_UI_FONT
		label.modulate = color
		label.outline_modulate = Color(0, 0, 0, 0.9)
		label.font_size = roundi((48 if big else 32) * clampf(text_k, 0.5, 3.0))
		label.outline_size = roundi(7 * clampf(text_k, 0.5, 3.0))
		if text_k != 1.0:
			if is_instance_valid(_counted_word) and _counted_word.position.distance_to(at) < 2.5:
				_counted_word.queue_free()
			_counted_word = label
		label.pixel_size = 0.01
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.render_priority = 17
		label.outline_render_priority = 16
		l = label
	l.position = at + Vector3(side_offset, rise_offset, 0.0)
	fx_root.add_child(l)
	if text.is_valid_int():
		_live_numbers.append(l)
	if batched or (tex != null and text != "Miss"):
		var skey: = Vector2i(roundi(at.x * 1.5), roundi(at.z * 1.5))
		var stack: Array = (_number_stacks.get(skey, []) as Array).filter( func(n): return is_instance_valid(n))

		var glyph_h: = float((RoAssets.glyph_atlas().get("size", Vector2(0, 16)) as Vector2).y) if batched else float(tex.get_height())
		var line: = glyph_h * (l as Sprite3D).pixel_size * (1.6 if show_star or ultra or lethal else 1.2)
		for n in stack:
			n.set_meta("lift", float(n.get_meta("lift", 0.0)) + line)
		stack.append(l)

		while stack.size() > 10:
			var old = stack.pop_front()
			if is_instance_valid(old):
				old.queue_free()
		_number_stacks[skey] = stack
		_cascade(l, big, ultra, lethal, -1.0 if stack_index % 2 == 1 else 1.0)
		return l

	l.scale = Vector3.ONE * (2.1 if ultra else 1.5)
	var tw: = l.create_tween().set_parallel()
	tw.tween_property(l, "scale", Vector3.ONE, 0.16 if ultra else 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK if ultra else Tween.TRANS_LINEAR)
	tw.tween_property(l, "position:y", l.position.y + (1.0 if ultra else 0.8), 0.8 if ultra else 0.62).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(l, "modulate:a", 0.0, 0.3).set_delay(0.6 if ultra else 0.38)
	tw.chain().tween_callback(l.queue_free)
	return l






func _crit_dressing(s: Sprite3D, tex: Texture2D, ultra: bool, lethal: bool, magic: = false) -> void :
	var star_tex: = RoAssets.crit_star_blue() if magic else RoAssets.msg_part(3)
	if star_tex == null:
		return
	var fit: = s.pixel_size * maxf(tex.get_width() * 1.2 / star_tex.get_width(), tex.get_height() * 2.3 / star_tex.get_height())
	var front: = Color(0.85, 0.85, 0.85)
	if lethal:
		front = Color(0.45, 0.5, 1.0) if magic else Color(0.85, 0.3, 0.3)
	elif ultra:
		front = Color(0.75, 0.9, 1.0) if magic else Color(1.0, 0.62, 0.25)


	if magic:
		var nc: = s.modulate
		front = Color(front.r / maxf(0.25, nc.r), front.g / maxf(0.25, nc.g), front.b / maxf(0.25, nc.b), front.a)
	var star: = _crit_star(s, star_tex, front, fit, 15, 1.15, lethal)
	if not (ultra or lethal):
		return

	var spin: = star.create_tween()

	for deg in ([] if magic else [30.0, 15.0]):
		var t: = RoAssets.msg_turned(3, deg)
		if t != null:
			spin.tween_callback( func():
				star.texture = t
				star.pixel_size = fit * star_tex.get_width() / t.get_width())
			spin.tween_interval(0.04)
	spin.tween_callback( func():
		star.texture = star_tex
		star.pixel_size = fit)
	if lethal:

		star.modulate = Color(2.0, 1.9, 1.8)
		star.create_tween().tween_property(star, "modulate", front, 0.18)

	var spark_tex: = RoAssets.effect_tex("lv99_star")
	if spark_tex == null:
		return
	var n: = 10 if lethal else 6
	var reach: = fit * star_tex.get_width() * 0.9
	for k in n:
		var sp: = Sprite3D.new()
		sp.texture = spark_tex
		sp.modulate = Color(1.0, 0.45, 0.3) if lethal and k % 2 == 0 else Color(1.0, 0.9, 0.5)
		sp.pixel_size = reach * 0.22 / spark_tex.get_width()
		sp.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sp.no_depth_test = true
		sp.shaded = false
		sp.render_priority = 16
		sp.material_override = _spark_mat(spark_tex)
		sp.set_meta("own_fade", true)
		s.add_child(sp)
		var a: = TAU * k / n + randf_range(-0.2, 0.2)
		var to: = Vector3(cos(a), sin(a), 0.0) * reach * randf_range(0.8, 1.2)
		var tw: = sp.create_tween().set_parallel()
		tw.tween_property(sp, "position", to, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(sp, "modulate:a", 0.0, 0.35).set_delay(0.12)
		tw.chain().tween_callback(sp.queue_free)




var _spark_material: StandardMaterial3D
func _spark_mat(tex: Texture2D) -> StandardMaterial3D:
	if _spark_material == null:
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.no_depth_test = true
		m.render_priority = 16
		m.albedo_texture = tex
		m.vertex_color_use_as_albedo = true
		_spark_material = m
	return _spark_material


func _crit_star(s: Sprite3D, tex: Texture2D, color: Color, size: float, priority: int, over: float, pulse: bool) -> Sprite3D:
	var star: = Sprite3D.new()
	star.texture = tex
	star.modulate = color
	star.pixel_size = size
	star.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	star.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	star.no_depth_test = true
	star.shaded = false
	star.render_priority = priority
	star.scale = Vector3.ONE * 0.4
	s.add_child(star)
	var st: = star.create_tween()
	st.tween_property(star, "scale", Vector3.ONE * over, 0.07).set_ease(Tween.EASE_OUT)
	st.tween_property(star, "scale", Vector3.ONE, 0.08)
	if pulse:
		for k in 3:
			st.tween_property(star, "scale", Vector3.ONE * 1.18, 0.08)
			st.tween_property(star, "scale", Vector3.ONE, 0.1)
	return star





func _cascade(l: Node3D, big: bool, ultra: bool, lethal: = false, way: = 1.0) -> void :

	var shown: = clampf(float(Save.setting("num_alpha", 0.8)), 0.2, 1.0)
	var start: = l.position
	var side: = Vector3.RIGHT
	if camera != null:
		side = camera.global_basis.x * Vector3(1, 0, 1)
		side = side.normalized() if side.length() > 0.01 else Vector3.RIGHT
	side *= randf_range(0.6, 1.2) * way


	var screen_up: = camera.global_basis.y if camera != null else Vector3.UP
	var dur: = 1.45 if lethal else (1.25 if ultra else (1.1 if big else 0.95))
	var s0: = 1.1 if ultra else 1.0



	var parts: Array = []
	var alphas: Array = []
	for n in [l] + l.get_children():
		if (n is SpriteBase3D or n is Label3D) and not n.has_meta("own_fade"):
			parts.append(n)
			alphas.append(n.modulate.a)
	var tw: = l.create_tween()
	tw.tween_method( func(t: float):

		var arc: = sin(PI * 1.5 * t)


		var lift: = float(l.get_meta("lift", 0.0))
		var lift_now: = float(l.get_meta("lift_now", 0.0))
		if lift_now < lift:
			lift_now = minf(lift, lift_now + maxf(0.05, (lift - lift_now) * 0.35))
			l.set_meta("lift_now", lift_now)
		l.position = start + side * t + Vector3(0, arc * (0.7 if arc > 0.0 else 0.5), 0) + screen_up * lift_now

		if lethal and t < 0.25:
			l.position += Vector3(randf_range(-0.07, 0.07), randf_range(-0.05, 0.05), randf_range(-0.07, 0.07)) * (1.0 - t / 0.25)
		var k: = lerpf(2.0, 1.0, t / 0.07) if t < 0.07 else lerpf(1.0, 0.5, (t - 0.07) / 0.93)
		l.scale = Vector3.ONE * s0 * k
		var fade: = clampf((t - 0.5) / 0.5, 0.0, 1.0)


		if fade > 0.0 or not l.has_meta("alpha_set"):
			l.set_meta("alpha_set", true)
			for i in parts.size():
				var g = parts[i]
				if is_instance_valid(g):
					g.modulate.a = float(alphas[i]) * (1.0 - fade * fade) * shown

		if l.has_meta("total"):
			var now: = Time.get_ticks_msec()
			if now - int(l.get_meta("drawn_at", 0)) >= NUMBER_REDRAW_MS:
				if l.has_meta("digits"):
					l.set_meta("digits", RoAssets.shown_digits(Leaderboard.big_digits(float(l.get_meta("total")))))
				else:
					var tex: = RoAssets.damage_text(Leaderboard.big_digits(float(l.get_meta("total"))))
					if tex != null and l is Sprite3D:
						(l as Sprite3D).texture = tex

				if l is Sprite3D and l.has_meta("size_k"):
					var grown: = _number_size(float(l.get_meta("total")))
					(l as Sprite3D).pixel_size *= grown / float(l.get_meta("size_k"))
					l.set_meta("size_k", grown)
				l.remove_meta("total")
				l.set_meta("drawn_at", now), 0.0, 1.0, dur)
	tw.tween_callback(l.queue_free)




func spawn_projectile(p: Dictionary) -> void :
	if not p.has("tag"):
		p["tag"] = damage_tag

	if projectiles.size() >= GameData.PROJECTILES_DRAWN_MAX and not p.get("ghost", false) and not p.get("boomerang", false):
		p.node = null
		p.life = float(p.get("max_life", 1.6))
		p.hit = {}
		if not p.has("by"):
			p["by"] = damage_by
		projectiles.append(p)
		return
	var s: = Sprite3D.new()
	var arrow_tex: Texture2D = arrow_texture() if p.arrow else null
	s.texture = arrow_tex if arrow_tex != null else RoAssets.radial(Color.WHITE, 64)
	if arrow_tex == null and str(p.get("tex", "")) == "" and str(p.get("sprite", "")) == "" and str(p.get("image", "")) == "":
		push_warning("Projectile without a client sprite (proj_tex / proj_sprite / arrow): %s" % p.get("tag", ""))

	s.modulate = Color.WHITE.lerp(p.color, 0.25) if arrow_tex != null else p.color
	var frames: Array[Texture2D] = []
	for f in int(p.get("frames", 0)):
		var t: = RoAssets.effect_tex("%s_%d" % [p.tex, f + 1])
		if t != null:
			frames.append(t)

	var thrown: RoSprite = RoAssets.sprite([str(p.get("sprite", ""))]) if str(p.get("sprite", "")) != "" else null
	if thrown != null:
		s.texture = thrown.get_frame(0, 0)
		s.modulate = Color.WHITE
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD

	var image: Texture2D = RoAssets.effect_tex(str(p.get("image", ""))) if str(p.get("image", "")) != "" else null
	if image != null:
		s.texture = image
		s.modulate = Color.WHITE
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	if not frames.is_empty():

		p.frames_tex = frames
		s.texture = frames[0]
		s.modulate = Color.WHITE
		var m: = StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		if str(p.get("blend", "add")) == "mix":

			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		else:
			m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		m.albedo_texture = frames[0]
		s.material_override = m


	s.billboard = BaseMaterial3D.BILLBOARD_DISABLED if p.arrow else BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.pixel_size = p.size * 2.0 / 64.0
	if p.has("frames_tex"):
		s.pixel_size = p.size * 2.0 * float(p.get("tex_scale", 1.0)) / float(p.frames_tex[0].get_width())
	if thrown != null:
		s.pixel_size = GameData.PIXEL_SIZE * 1.15 * float(p.get("sprite_scale", 1.0))
	if image != null:
		s.pixel_size = p.size * 2.0 * float(p.get("tex_scale", 1.0)) / float(image.get_width())
	if arrow_tex != null:
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		s.pixel_size = GameData.PIXEL_SIZE * 1.3
	elif p.arrow:
		s.scale = Vector3(2.2, 0.45, 1.0)




	var owner = p.get("by", damage_by)
	var alpha: float = hero_fx_alpha(owner) if owner is Player else Vfx.dim
	if arrow_tex == null and thrown == null and image == null:
		s.modulate.a *= sqrt(alpha)
	elif thrown != null and alpha < 0.99:
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
		s.modulate.a *= alpha
	s.position = p.pos
	if Vfx.hidden() or (Vfx.layer == 0 and alpha <= 0.01):
		p["unseen"] = true


	if thrown != null and float(p.get("sprite_scale", 1.0)) >= 2.0 and not p.get("unseen", false):
		var big: = 0
		for q in projectiles:
			if q.get("big", false):
				big += 1
		if big >= GameData.THROWN_BIG_DRAWN:
			p["unseen"] = true
		else:
			p["big"] = true
	s.visible = p.delay <= 0.0 and not p.get("unseen", false)
	fx_root.add_child(s)
	p.node = s
	if p.arrow:
		if arrow_tex != null and Color(p.get("streak", Color(0, 0, 0, 0))).a > 0.0:
			_arrow_streak(s, p.streak, p.size)
		_orient_arrow(s, p.pos, p.dir)
	p.life = float(p.get("max_life", 1.6))
	p.hit = {}
	if float(p.get("spin", 0.0)) > 0.0 and not p.get("glow", true):

		s.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		s.pixel_size *= 1.35
		p.angle = 0.0
		p.trail_t = 0.0
	elif float(p.get("spin", 0.0)) > 0.0:

		s.billboard = BaseMaterial3D.BILLBOARD_DISABLED
		s.pixel_size *= 1.35
		p.angle = 0.0
		p.trail_t = 0.0

		var glow: = Sprite3D.new()
		glow.texture = RoAssets.radial(Color.WHITE, 64)
		glow.modulate = Color(0.55, 0.75, 1.0, 0.7 * Vfx.dim)
		glow.pixel_size = 0.03
		glow.shaded = false
		glow.no_depth_test = true
		glow.render_priority = 4
		glow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		var gm: = StandardMaterial3D.new()
		gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		gm.albedo_texture = glow.texture
		gm.albedo_color = glow.modulate
		gm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		gm.no_depth_test = true
		glow.material_override = gm
		s.add_child(glow)
	if p.get("boomerang", false):
		p.out_time = float(p.get("range", 8.0)) / maxf(float(p.speed), 1.0)
		p.age = 0.0
		p.back = false
		p.life = p.out_time * 2.0 + 1.5
	if not p.has("by"):
		p["by"] = damage_by
	if net.recording() and not p.get("ghost", false):
		var look: = {"slot": by_of(p).slot}
		for k in NET_SHOT_KEYS:
			if p.has(k):
				look[k] = p[k]
		net.record(["p", look])
	projectiles.append(p)










func line_shot(p: Player, target: Enemy, dir: Vector3, length: float, width: float, dmg: float, element: String, sk: Dictionary, delay: = 0.0, blast: = 0.0) -> void :
	if delay > 0.0:
		var tag: = damage_tag
		var by: = damage_by
		var ref: WeakRef = weakref(target)
		_own_timer(delay, func():
			var t = ref.get_ref()
			if running and t != null and not t.dead and hero_valid(p):
				damage_tag = tag
				damage_by = by
				line_shot(p, t, dir, length, width, dmg, element, sk, 0.0, blast))
		return
	var from: = target.position
	var mid: = from + dir * length * 0.5
	var push: = dir * float(sk.get("knock", 1.0))
	damage_enemy(target, dmg, push, "skill", element)
	var struck: = {target: true}
	for e in enemies_in_radius(mid, length * 0.5 + width):
		if e == target:
			continue
		var rel: = (e.position - from) * Vector3(1, 0, 1)
		var along: = rel.dot(dir)
		if along < 0.0 or along > length:
			continue
		if (rel - dir * along).length() > width * 0.5 + e.radius:
			continue
		struck[e] = true
		damage_enemy(e, dmg, push, "skill", element)
	if blast > 0.0:
		for e in enemies_in_radius(from, blast):
			if not struck.has(e) and not e.dead:
				var away: = (e.position - from) * Vector3(1, 0, 1)
				damage_enemy(e, dmg, away.normalized() * float(sk.get("knock", 1.0)) if away.length_squared() > 0.0001 else push, "skill", element)
		Vfx.ring(fx_root, from + Vector3(0, 0.05, 0), blast, Color(1.0, 0.92, 0.6, 0.8), 0.3)
	play_sound(str(sk.get("hit_sound", "")), 0.1, -4.0)
	if str(sk.get("line_fx", "")) == "investigate":
		_investigate_fx(from, dir, length)
		return
	Vfx.air_impact(fx_root, from + Vector3(0, 0.6, 0), dir, 1.4 + width * 0.5)
	Vfx.wind_shot(fx_root, from + Vector3(0, 0.6, 0), dir, length, width, camera.global_position)





func _investigate_fx(at: Vector3, dir: Vector3, length: float) -> void :
	var a: = camera.unproject_position(at)
	var b: = camera.unproject_position(at + dir)
	var d: = b - a

	var action: = (0 if d.y < 0.0 else 1) if d.x >= 0.0 else (2 if d.y >= 0.0 else 3)
	sprite_fx("fx_investigate", at + Vector3(0, 0.8, 0), action, 1.35)
	spawn_fx("earthhit", at, 1.0, 0.9)



	play_sound("investigate", 0.05, 2.0)
	Vfx.ring(fx_root, at + Vector3(0, 0.05, 0), 1.6, Color(1.0, 0.9, 0.6, 0.85), 0.28)
	shake(0.12)
	var steps: = int(length / 1.3)
	for k in steps:
		var spot: = at + dir * (1.3 * (k + 1))
		get_tree().create_timer(0.035 * (k + 1), false).timeout.connect( func():
			if map != null:
				spot.y = map.height_at(spot)
			spawn_fx("earthhit", spot, 1.0 - 0.05 * k, 0.9)
			if k % 2 == 1:
				sprite_fx("fx_investigate", spot + Vector3(0, 0.8, 0), action, 1.0)
			Vfx.ring(fx_root, spot + Vector3(0, 0.05, 0), 0.8, Color(1.0, 0.88, 0.55, 0.6), 0.22))




const ARCHER_FLASH_CD: = 0.45
var _archer_flash_at: = 0.0
func archer_flash(p: Player) -> void :
	var now: = Time.get_ticks_msec() / 1000.0
	if now < _archer_flash_at:
		return
	_archer_flash_at = now + ARCHER_FLASH_CD
	Vfx.ray_flash(fx_root, p.position + Vector3(0, 1.3, 0), camera.global_basis, Color.WHITE)
	play_sound("bash", 0.1, -10.0)





var _streak_mats: = {}
func _arrow_streak(s: Sprite3D, col: Color, size: float) -> void :
	var mat: StandardMaterial3D = _streak_mats.get(col)
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.no_depth_test = true
		mat.albedo_texture = RoAssets.radial(Color.WHITE, 64)
		mat.albedo_color = Color(col, 0.35)
		_streak_mats[col] = mat

	var tip: = Vector2(-1, 1).normalized()
	var big: = clampf(size / 0.25, 1.0, 1.6)
	var q: = Sprite3D.new()
	q.texture = mat.albedo_texture
	q.material_override = mat
	q.pixel_size = 1.0 / 64.0
	q.render_priority = 4
	q.rotation.z = tip.angle()
	q.scale = Vector3(1.3 * big, 0.16 * big, 1.0)
	q.position = Vector3(tip.x, tip.y, 0.0) * -0.45 * big
	s.add_child(q)


func _orient_arrow(node: Node3D, at: Vector3, dir: Vector3) -> void :
	_orient_quad(node, at, dir, Vector2(-1, 1).normalized() if _arrow_tex != null else Vector2(-1, 0))


var _arrow_tex: Texture2D




func arrow_texture() -> Texture2D:
	if _arrow_tex == null:
		var spr: = RoAssets.sprite(["arrow_projectile"])
		var frame: Texture2D = spr.get_frame(0, 0) if spr != null else null
		if frame != null:
			var img: = spr.compose_image(0, 0)
			if img.is_compressed():
				img.decompress()
			var used: = img.get_used_rect()
			_arrow_tex = ImageTexture.create_from_image(img.get_region(used)) if used.size.x > 0 else frame
	return _arrow_tex if _arrow_tex != null else RoAssets.effect_sprite("arrowshot_projectile")




func _orient_quad(node: Node3D, at: Vector3, dir: Vector3, axis: Vector2) -> void :
	var sd: = camera.unproject_position(at + dir) - camera.unproject_position(at)
	var d: = Vector2(sd.x, - sd.y)
	if d.length_squared() < 0.0001:
		return
	var theta: = d.angle() - axis.angle()
	var scale: = node.scale
	node.global_basis = camera.global_basis * Basis(Vector3(0, 0, 1), theta)
	node.scale = scale



func _seek_free(p: Dictionary) -> Enemy:
	var best: Enemy = null
	var best_d: = INF
	for e in enemies_in_radius(p.pos, 4.0):
		if e.dead or p.hit.has(e):
			continue
		var d: float = (e.position as Vector3).distance_squared_to(p.pos)
		if d < best_d:
			best_d = d
			best = e
	return best


func _update_projectiles(delta: float) -> void :
	_update_bounces(delta)
	for i in range(projectiles.size() - 1, -1, -1):
		var p: = projectiles[i]
		if p.delay > 0.0:
			p.delay -= delta
			if p.delay <= 0.0:
				p.pos = by_of(p).position + Player.BOW_MUZZLE_UP + p.dir * Player.BOW_MUZZLE_AHEAD
				if p.node != null:
					p.node.visible = not p.get("unseen", false)
			continue


		if p.has("seek"):
			var seek = p.seek


			if seek == null or not is_instance_valid(seek) or seek.dead or p.hit.has(seek):
				seek = _seek_free(p)
				p.seek = seek
			if seek != null:
				var aim: Vector3 = (seek.position - p.pos) * Vector3(1, 0, 1)
				if aim.length() > 0.05:
					p.dir = aim.normalized()
				p.life = maxf(p.life, 0.2)
			else:
				p.erase("seek")
				p.life = minf(p.life, 0.2)
		p.pos += p.dir * p.speed * delta
		p.life -= delta
		var node: Sprite3D = p.node
		if node != null:
			node.position = p.pos
		if p.has("frames_tex"):
			var ft: Array = p.frames_tex
			(node.material_override as StandardMaterial3D).albedo_texture = ft[int((1.6 - p.life) * 20.0) % ft.size()]
		if p.arrow and node != null:
			_orient_arrow(node, p.pos, p.dir)
		if p.has("angle"):
			_spin_projectile(p, node, delta)
		if p.has("out_time"):
			p.age += delta
			if not p.back and p.age >= p.out_time:

				p.back = true
				p.hit = {}
				p.pierce = 99
			if p.back:
				var home: Vector3 = by_of(p).position + Vector3(0, 0.9, 0)
				p.dir = ((home - p.pos) * Vector3(1, 0, 1)).normalized()
				if _flat_dist(p.pos, home) < 0.7:
					p.life = 0.0
		var done: bool = p.life <= 0.0
		if not done and not p.get("ghost", false):
			for e in enemies_in_radius(p.pos, p.size):
				if p.hit.has(e):
					continue
				p.hit[e] = true
				_shot_land(p, e)
				p.pierce -= 1
				if p.pierce < 0:
					done = true
					break
		if done:
			if node != null:
				node.queue_free()
			projectiles.remove_at(i)


var _impact_next: = 0



func _shot_land(p: Dictionary, e: Enemy) -> void :
	damage_tag = p.tag
	damage_by = p.get("by")
	damage_enemy(e, p.damage, p.dir * p.knock, p.get("source", "skill"), p.get("element", "neutral"))


	var shot_sk: Dictionary = GameData.SKILLS.get(str(p.tag), {})
	if shot_sk.has("acid") and not e.dead:
		e.acid_frail = maxf(e.acid_frail if e.acid_until > clock else 0.0, float(shot_sk.acid))
		e.acid_until = maxf(e.acid_until, clock + float(shot_sk.get("acid_time", 4.0)))
	if p.get("status", "") != "" and float(p.get("status_chance", 0.0)) > 0.0 and randf() < float(p.get("status_chance", 0.0)) + float(by_of(p).effects.get("status_chance", 0.0)):
		apply_status(e, p.status, float(p.get("status_time", 2.0)))
	if not (p.get("hit_sounds", []) as Array).is_empty():
		play_sound(str(p.hit_sounds.pick_random()), 0.1, -8.0)
	elif p.get("hit_sound", "") != "":
		play_sound(p.hit_sound, 0.1, -8.0)
	if p.get("basic", false):
		by_of(p).on_basic_hit(self, e)
	var chain: = int(p.get("chain", 0))
	var more: = int(p.get("bounces", 0)) > 0
	if chain > 0:
		_bounce_feedback(e, chain, not more)
	elif p.get("arrow", false) and p.get("hit_fx", "") == "":

		spawn_fx("hit", e.position + Vector3(0, 0.7, 0), 0.5, 0.8)
	if more:
		_queue_bounce(p, e)
	elif chain >= GameData.BOUNCE_MARK:
		_bounce_mark(e, chain)
	if p.get("hit_fx", "") != "":
		spawn_fx(p.hit_fx, e.position + Vector3(0, 0.6, 0), 0.6, p.get("hit_fx_intensity", 1.0))

	if float(p.get("impact", 0.0)) > 0.0 and Time.get_ticks_msec() >= _impact_next:

		_impact_next = Time.get_ticks_msec() + 50
		Vfx.ring(fx_root, e.position + Vector3(0, 0.08, 0), float(p.impact), Color(p.trail_tint, 0.75), 0.28)
		Vfx.burst(fx_root, e.position, float(p.impact) * 0.7, Color(p.trail_tint, 0.6))
		shake(0.05 * float(p.impact))

	if p.get("finale", false):
		var col: Color = p.get("streak", Color(1.0, 0.7, 0.75))
		Vfx.ring(fx_root, e.position + Vector3(0, 0.08, 0), float(p.splash), Color(col, 0.9), 0.35)
		Vfx.burst(fx_root, e.position + Vector3(0, 0.6, 0), float(p.splash) * 0.6, Color(1.0, 0.85, 0.95))
		rising_tex(e, "melody_a" if randf() < 0.5 else "melody_b", 3)
		shake(0.08)

	if float(p.get("splash", 0.0)) > 0.0:
		var merge: bool = p.get("merge_splash", false)
		for o in enemies_in_radius(e.position, float(p.splash)):
			if o != e and not o.dead:
				if merge:
					_splash_merge(o, p.damage * 0.6, (o.position - e.position).normalized() * 2.0, p)
				else:
					damage_enemy(o, p.damage * 0.6, (o.position - e.position).normalized() * 2.0, "skill", p.get("element", "neutral"))
	if p.slow > 0.0:
		e.slow_time = p.slow






const SPLASH_MERGE_GAP: = 0.12
var _splash_acc: = {}
var _splash_t: = 0.0


func _splash_merge(o: Enemy, amount: float, push: Vector3, p: Dictionary) -> void :
	var key: = "%d|%s" % [o.get_instance_id(), p.tag]
	var acc: Array = _splash_acc.get(key, [])
	if acc.is_empty():
		_splash_acc[key] = [o, amount, push, p.tag, p.get("by"), p.get("element", "neutral"), 1]
		return
	acc[1] = float(acc[1]) + amount
	acc[2] = push
	acc[6] = int(acc[6]) + 1


func _flush_splash(delta: float) -> void :
	if _splash_acc.is_empty():
		_splash_t = SPLASH_MERGE_GAP
		return
	_splash_t -= delta
	if _splash_t > 0.0:
		return
	_splash_t = SPLASH_MERGE_GAP
	var all: = _splash_acc.values()
	_splash_acc.clear()
	var tag: = damage_tag
	var by: = damage_by
	for acc in all:
		var o = acc[0]
		if not is_instance_valid(o) or o.dead:
			continue
		damage_tag = acc[3]
		damage_by = acc[4]
		_kunai_n = mini(int(acc[6]), GameData.KUNAI_MAX)
		damage_enemy(o, float(acc[1]), acc[2], "skill", str(acc[5]))
		_kunai_n = 1
	damage_tag = tag
	damage_by = by





func _queue_bounce(p: Dictionary, from: Enemy) -> void :
	var best: = _bounce_target(from, p.hit)
	var chain: = int(p.get("chain", 0))
	if best == null:
		if chain >= GameData.BOUNCE_MARK:
			_bounce_mark(from, chain)
		return
	_ricochet(p, from.position, best.position)
	p.pos = Vector3(from.position.x, p.pos.y, from.position.z)
	p.damage = float(p.damage) * GameData.BOUNCE_DMG
	p.bounces = int(p.bounces) - 1
	p["chain"] = chain + 1
	p["next"] = best
	p["wait"] = BOUNCE_STEP
	_bouncing.append(p)


const BOUNCE_STEP: = 0.1
var _bouncing: Array[Dictionary] = []





func _ricochet(p: Dictionary, a: Vector3, b: Vector3) -> void :

	var was = p.get("node")
	if is_instance_valid(was) and not p.has("look"):
		p["look"] = {"tex": was.texture, "px": was.pixel_size, "tint": was.modulate, "mat": was.material_override, 
			"filter": was.texture_filter, "cut": was.alpha_cut}
	var look: Dictionary = p.get("look", {})
	if look.is_empty() and not p.arrow:
		return
	if Vfx.hidden():
		return
	if not _bounce_fx_ok(BOUNCE_TRACES_MAX, "trace"):
		return
	var s: = Sprite3D.new()
	s.texture = look.get("tex", arrow_texture())
	if s.texture == null:
		s.free()
		return
	s.pixel_size = look.get("px", GameData.PIXEL_SIZE * 1.3)
	s.modulate = look.get("tint", Color.WHITE)
	s.material_override = look.get("mat", null)
	s.texture_filter = look.get("filter", BaseMaterial3D.TEXTURE_FILTER_NEAREST)
	s.alpha_cut = look.get("cut", SpriteBase3D.ALPHA_CUT_DISCARD)
	s.shaded = false
	s.billboard = BaseMaterial3D.BILLBOARD_DISABLED if p.arrow else BaseMaterial3D.BILLBOARD_ENABLED
	fx_root.add_child(s)
	var from: = a + Vector3(0, 0.75, 0)
	var to: = b + Vector3(0, 0.75, 0)
	_ricochet_at(0.0, s, from, to, p.arrow)
	var tw: = s.create_tween()
	tw.tween_method(_ricochet_at.bind(s, from, to, p.arrow), 0.0, 1.0, BOUNCE_STEP)
	tw.tween_callback(s.queue_free)


func _ricochet_at(k: float, s: Sprite3D, a: Vector3, b: Vector3, arrow: bool) -> void :
	var hop: = 0.35 + a.distance_to(b) * 0.12
	s.position = a.lerp(b, k) + Vector3(0, sin(k * PI) * hop, 0)
	if arrow:

		var rise: = Vector3(0, cos(k * PI) * hop * PI, 0)
		_orient_arrow(s, s.position, (b - a) + rise)


func _update_bounces(delta: float) -> void :
	for i in range(_bouncing.size() - 1, -1, -1):
		var p: = _bouncing[i]
		p.wait = float(p.wait) - delta
		if p.wait > 0.0:
			continue
		_bouncing.remove_at(i)
		var e = p.next

		if not is_instance_valid(e) or e.dead:
			e = _seek_free(p)
		if e == null:
			continue
		p.hit[e] = true
		p.dir = ((e.position - p.pos) * Vector3(1, 0, 1)).normalized()
		_shot_land(p, e)




func _spin_projectile(p: Dictionary, node: Sprite3D, delta: float) -> void :
	p.angle += float(p.spin) * delta
	var sc: = node.scale
	node.global_basis = camera.global_basis * Basis(Vector3(0, 0, 1), p.angle)
	node.scale = sc
	p.trail_t -= delta
	if p.trail_t > 0.0:
		return
	p.trail_t = 0.03
	var g: = Sprite3D.new()
	g.texture = node.texture
	g.pixel_size = node.pixel_size
	g.shaded = false
	g.texture_filter = node.texture_filter
	g.no_depth_test = true
	g.render_priority = 5
	g.modulate = Color(p.get("trail_tint", Color(0.8, 0.9, 1.3)), 0.6 * Vfx.dim)
	fx_root.add_child(g)
	g.global_transform = node.global_transform
	var tw: = g.create_tween().set_parallel()
	tw.tween_property(g, "modulate:a", 0.0, 0.22)
	tw.tween_property(g, "scale", g.scale * 1.25, 0.22)
	tw.chain().tween_callback(g.queue_free)




func _drop_xp(at: Vector3, value: int) -> void :


	if not GameData.has_meta("xp_gems"):


		_xp_batch += value
		_xp_kills += 1
		_xp_wisp(at, _soul_color)
		return
	if pickups.size() > 350:
		var other: Dictionary = pickups.pick_random()
		if other.kind == "xp":
			other.value += value
			_gem_look(other, int(other.value))
			return

	var s: = Node3D.new()
	run_root.add_child(s)
	var p: = {"node": s, "kind": "xp", "value": value, "pull": false}
	_gem_look(p, value)
	pickups.append(p)
	var land: = map.random_point_around(at, 0.7)
	_pop(p, at + Vector3(0, 0.3, 0), Vector3(land.x, at.y + 0.3, land.z), 0.9)
	if int(p.tier) >= GameData.GEM_BOUNCE_TIER:
		p["bounce"] = true


var _xp_batch: = 0

var _xp_kills: = 0


func _flush_xp() -> void :
	if _xp_batch > 0:
		var v: = _xp_batch
		_xp_batch = 0
		var n: = _xp_kills
		_xp_kills = 0
		_collect({"kind": "xp", "value": v, "direct": true, "kills": n})




var _wisps: = 0
const WISP_MAX: = 14

var _soul_color: = Color(0.75, 0.9, 1.0)
func _xp_wisp(at: Vector3, col: = Color(0.75, 0.9, 1.0)) -> void :
	if _wisps >= WISP_MAX or not is_instance_valid(player):
		return
	_wisps += 1
	var s: = Sprite3D.new()
	s.texture = Vfx.disc_texture()
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.no_depth_test = true
	s.render_priority = GameData.HERO_FX_PRIORITY
	s.pixel_size = 0.0035
	s.modulate = Color(col.lightened(0.35), 0.95)
	fx_root.add_child(s)
	var from: = at + Vector3(0, 0.8, 0)
	s.global_position = from
	var side: = randf_range(-1.0, 1.0)
	var fly: = func(k: float):
		if not is_instance_valid(player) or not is_instance_valid(s):
			return
		var to: = player.position + Vector3(0, 0.9, 0)
		var lat: = Vector3(from.z - to.z, 0, to.x - from.x).normalized() * side * sin(k * PI) * 0.6
		s.global_position = from.lerp(to, k * k) + Vector3(0, sin(k * PI) * 1.1, 0) + lat
		s.scale = Vector3.ONE * lerpf(1.0, 0.55, k)
	var tw: = s.create_tween()
	tw.tween_method(fly, 0.0, 1.0, randf_range(0.35, 0.5))
	tw.tween_callback( func():
		_wisps -= 1
		s.queue_free())


var _gem_tex: = {}


func _gem_look(p: Dictionary, value: int) -> void :
	var tier: Array = GameData.XP_GEMS[0]
	var tier_i: = 0
	for i in GameData.XP_GEMS.size():
		if value >= int(GameData.XP_GEMS[i][0]):
			tier = GameData.XP_GEMS[i]
			tier_i = i
	p["tier"] = tier_i
	var key: String = tier[1]
	if not _gem_tex.has(key):
		var path: = "res://assets/ro/ui/skin/item_icons/%s.png" % key
		_gem_tex[key] = load(path) if ResourceLoader.exists(path) else RoAssets.radial(Color(0.45, 0.75, 1.0), 24)
	var look: = "%s@%s" % [key, tier[2]]
	if not _gem_looks.has(look):
		_gem_looks[look] = [_gem_tex[key], GameData.PIXEL_SIZE * float(tier[2]), tier_i]
	p["gem"] = look




const DROP_HOP_TIME: = 0.38
func _pop(p: Dictionary, from: Vector3, to: Vector3, height: float) -> void :
	p.hop_t = 0.0
	p.hop_from = from
	p.hop_to = to
	p.hop_h = height
	p.node.position = from



var _drop_beams: Array = []
func _drop_marker(s: Sprite3D, color: Color, beam_height: float, ground_y: float) -> void :


	_drop_beams = _drop_beams.filter( func(b): return is_instance_valid(b))

	if beam_height > 0.0 and _drop_beams.size() < GameData.DROP_BEAMS_MAX and own_fx_alpha > 0.01:
		_drop_beams.append(Vfx.beam(s, Vector3(0, ground_y, 0), color, beam_height))
	var glow: = Vfx.ground_glow(s, Vector3(0, ground_y, 0), 0.9 + beam_height * 0.12, Color(color, 0.55))
	var tw: = glow.create_tween().set_loops()
	tw.tween_property(glow, "modulate:a", 0.2, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(glow, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)






var _fx_local: = false


var _sound_local: = false
func spawn_fx(fx: String, at: Vector3, size: = 1.0, intensity: = 1.0, follow: Node3D = null) -> RoEffect:
	if net.recording() and not _fx_local:
		net.record(["f", fx, at, size, intensity, net.ref_of(follow) if follow != null else []])


	var key: = fx
	var cap: = FX_CAP

	if Vfx.hidden():
		return null
	if _foreign_fx():

		if fx_alpha_party <= 0.01:
			return null
		key = "ally:" + fx
		cap = ally_fx_cap()


	if Vfx.quality > 0 and Vfx.layer == 0:
		if Vfx.quality >= 3:
			return null
		cap = maxi(1, cap / (2 if Vfx.quality == 1 else 4))
	var live: Array = _fx_live.get(key, [])
	live = live.filter( func(n): return is_instance_valid(n))
	_fx_live[key] = live
	if live.size() >= cap:
		return null
	var e: = RoEffect.spawn(fx_root, fx, at, size, follow)
	if e != null:

		e.intensity = intensity * pow(Vfx.dim, 1.6)
		live.append(e)
	return e





func fx_layer(priority: int) -> void :
	if net.recording() and Vfx.layer != priority:
		net.record(["L", priority])
	Vfx.layer = priority
	RoEffect.layer = priority



func _show_mvp_banner() -> void :
	var spr: = RoAssets.sprite(["fx_mvp"])
	if spr == null:
		return
	var banner: = RoVisual.new()
	player.add_child(banner)
	banner.setup(spr, Color.WHITE, 32, 0.0)
	banner.turns = false

	banner.play(0, true)
	get_tree().create_timer(4.0, false).timeout.connect(banner.queue_free)


var _chests_held: = 0


func hold_chests(seconds: float) -> void :
	_chests_held = maxi(_chests_held, Time.get_ticks_msec() + roundi(seconds * 1000.0))






func _mvp_fanfare(at: Vector3) -> void :
	hold_chests(2.5)
	if net.recording():
		net.record(["mvp", at])
	_mvp_moment(at)
	play_sound("levelup", 0.0, 0.0)
	play_sound(GameData.DROP_SOUND_LEGENDARY, 0.0, 0.0)
	Vfx.ray_flash(fx_root, at + Vector3(0, 1.0, 0), camera.global_basis, Color(1.0, 0.85, 0.4), 3.0)
	for i in 3:
		_own_timer(0.1 * i, func():
			Vfx.ring(fx_root, at, 3.0 + 3.0 * i, Color(1.0, 0.85, 0.4), 0.6)
			Vfx.column(fx_root, at + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)), Color(1.0, 0.9, 0.5)))




func _mvp_moment(at: Vector3) -> void :
	hud.announce(tr("¡MVP!"), Color(1, 1, 0.3))
	_show_mvp_banner()


	var was: = Engine.time_scale if Engine.time_scale > 0.2 else _speed_applied
	_mvp_slow = true
	Engine.time_scale = 0.3
	get_tree().create_timer(0.8, true, false, true).timeout.connect( func():
		_mvp_slow = false
		Engine.time_scale = was)
	hud.flash(Color(1.0, 0.85, 0.35), 0.6, 0.45)
	shake(0.9)
	for i in 24:
		var a: = TAU * i / 24.0
		var to: = at + Vector3(cos(a), 0, sin(a)) * randf_range(2.5, 6.0)
		_fly_sprite("fx_coin", at + Vector3(0, 1.0, 0), to, randf_range(0.3, 0.55), 1.2)




func _drop_chest(at: Vector3, rolls: int, bonus: = 0, unique: = "", satan: = false, corrupt: = false, look: = "", treasure: = false, valkyrie: = false) -> void :

	if not map.is_walkable(at):
		var near: = map.find_point_around(at, 0.5, 4.0)
		at = near if near != Vector3.INF else player.position
	var tier: = clampi(bonus + 1, 0, GameData.CHEST_SPRITES.size() - 1)
	var color: Color = GameData.CHEST_COLORS[tier]
	var spr: = RoAssets.sprite(([look if look != "" else GameData.CHEST_SPRITES[tier]] if not corrupt else ["chest_corrupt", GameData.CHEST_SPRITES[tier]]) + ["chest"])
	var s: = Sprite3D.new()
	s.texture = spr.get_frame(0, 0) if spr != null else RoAssets.placeholder(Color(0.75, 0.5, 0.2), 30, false)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD


	s.pixel_size = GameData.PIXEL_SIZE * (0.62 if tier >= 3 else 1.9)
	run_root.add_child(s)

	var ghost: = Sprite3D.new()
	ghost.texture = s.texture
	ghost.pixel_size = s.pixel_size
	ghost.billboard = s.billboard
	ghost.shaded = false
	ghost.texture_filter = s.texture_filter
	ghost.no_depth_test = true
	ghost.render_priority = 6
	ghost.modulate = Color(color.lightened(0.4), 0.6)
	s.add_child(ghost)
	_drop_marker(s, color, 6.0 + tier * 2.0, -0.5)
	Vfx.ring(fx_root, at, 2.2, color, 0.8)
	if tier >= 3:


		var glow: = Color(1.0, 0.85, 0.3)
		if corrupt:


			glow = GameData.CORRUPT_COLOR

			if not RoAssets.has_sprite("chest_corrupt"):
				s.modulate = Color(0.55, 0.22, 0.28)
			ghost.modulate = Color(0.9, 0.15, 0.2, 0.75)
			Vfx.magic_circle(s, Vector3(0, -0.05, 0), 2.2, Color(0.7, 0.05, 0.1, 0.65), 0.0, "mvp_rune", 0.5)
			spawn_fx("hell_in", at, 1.2, 0.9)
		elif satan:


			glow = Color(1.0, 0.18, 0.12)
			s.modulate = Color(1.0, 0.42, 0.4)
			ghost.modulate = Color(1.0, 0.3, 0.25, 0.7)
			Vfx.magic_circle(s, Vector3(0, -0.05, 0), 2.2, Color(1.0, 0.2, 0.15, 0.6), 0.0, "mvp_rune", 0.5)
			spawn_fx("hell_in", at, 1.2, 0.9)
			for i in 4:
				var a: = TAU * i / 4.0
				spawn_fx("firepillar", at + Vector3(cos(a), 0, sin(a)) * 1.6, 0.8, 0.8)
		elif treasure:


			s.scale = Vector3.ONE * 1.5
			ghost.modulate = Color(1.0, 0.95, 0.6, 0.8)
			Vfx.magic_circle(s, Vector3(0, -0.05, 0), 3.0, Color(1.0, 0.85, 0.35, 0.7), 0.0, "mvp_rune", 0.4)
			for i in 6:
				var a: = TAU * i / 6.0
				Vfx.column(fx_root, at + Vector3(cos(a), 0, sin(a)) * 2.4, Color(1.0, 0.9, 0.5))
		Vfx.beam(s, Vector3.ZERO, glow, 9.0)
		Vfx.ring(fx_root, at, 4.5, glow.lightened(0.1), 1.0)
		Vfx.burst(fx_root, at, 3.0, glow)
		play_sound(GameData.DROP_SOUND_LEGENDARY, 0.0, -2.0)
	var p: = {"node": s, "kind": "chest", "value": rolls, "bonus": bonus, "tier": tier, "pull": false}
	if satan:
		p["satan"] = true
	if treasure:
		p["treasure"] = true
	if corrupt:
		p["corrupt"] = true
	if valkyrie:
		p["valkyrie"] = true
	if unique != "":
		p["unique"] = unique
		ghost.modulate = Color(GameData.UNIQUE_COLOR.lightened(0.3), 0.7)
		Vfx.ring(fx_root, at, 3.2, GameData.UNIQUE_COLOR, 1.2)
	var ground: = pickups.filter( func(o): return o.kind == "chest" and not o.has("unique") and not o.has("satan") and not o.has("treasure") and not o.has("corrupt"))
	if not corrupt and ground.size() >= GameData.MAX_GROUND_CHESTS and not net.is_client():



		var old: Dictionary = ground[0]
		var hb: = maxi(int(p.bonus), int(old.get("bonus", 0)))
		var plain: = 0
		for c in [p, old]:
			plain += int(c.value) if int(c.get("bonus", 0)) < hb else int(c.get("plain", 0))
		var total: = int(p.value) + int(old.value)
		p.value = mini(GameData.MAX_CHEST_ROLLS, total)
		p["plain"] = maxi(0, plain - (total - int(p.value)))
		p.bonus = hb
		pickups.erase(old)
		if is_instance_valid(old.node):
			old.node.queue_free()
	pickups.append(p)
	_pop(p, at + Vector3(0, 0.5, 0), at + Vector3(0, 0.5, 0), 2.2)
	play_sound(GameData.DROP_SOUND_LEGENDARY, 0.3, -6.0)



func _drop_ore(at: Vector3, count: int) -> void :
	for i in count:
		var ore: String = GameData.ORES.keys().pick_random()
		var spr: = RoAssets.sprite(["ore_" + ore])
		var s: = Sprite3D.new()
		s.texture = spr.get_frame(0, 0) if spr != null else RoAssets.placeholder(GameData.ORES[ore].color, 16, false)
		s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		s.shaded = false
		s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		s.pixel_size = GameData.PIXEL_SIZE * 1.6
		run_root.add_child(s)
		_drop_marker(s, GameData.ORES[ore].color, 0.0, -0.28)
		var p: = {"node": s, "kind": "ore", "id": ore, "value": 0, "pull": false, "spr": "ore_" + ore}
		pickups.append(p)
		_pop(p, at + Vector3(0, 0.3, 0), map.random_point_around(at, 1.2) + Vector3(0, 0.3, 0), 1.3)
		play_sound("drop_blue", 0.5, -10.0)





func _drop_loot(e: Enemy, fused: = 1) -> void :
	var loot: Dictionary = GameData.LOOT.get(e.id, {})
	if loot.is_empty():
		return
	var purses: = _hits(float(loot.chance), fused)
	if purses <= 0:
		return
	for i in int(loot.get("count", 1)):
		var at: = e.position if i == 0 else map.random_point_around(e.position, 1.5)
		var thin: = 1.0 if e.is_boss or e.def.get("elite", false) else GameData.crowd_zeny_mult(kills)
		var value: = maxi(1, roundi(int(loot.zeny) * (float(GameData.FEROCIOUS.zeny) if e.feroz else 1.0) * thin * purses))

		var s: = _zeny_sprite(value)
		var p: = {"node": s, "kind": "loot", "value": value, "pull": false, "spr": "zeny"}
		pickups.append(p)
		_pop(p, e.position + Vector3(0, 0.25, 0), at + Vector3(randf_range(-0.5, 0.5), 0.25, randf_range(-0.5, 0.5)), 1.0)




static func _fuse_rolls(held: int) -> int:
	var x: = 1.0 + maxi(0, held - 1) * GameData.CROWD_FUSE_LOOT
	return floori(x) + (1 if randf() < x - floorf(x) else 0)



static func _hits(p: float, n: int) -> int:
	var k: = 0
	for i in n:
		if randf() < p:
			k += 1
	return k






func _drop_specials(e: Enemy, drop: = 1.0, fused: = 1) -> void :
	if e.summoned:
		return
	var any: = func(p: float) -> float: return 1.0 - pow(1.0 - clampf(p, 0.0, 1.0), fused)




	var mvp_pet: = GameData.PETS.has(e.id) and bool(GameData.PETS[e.id].get("mvp", false))
	if GameData.PETS.has(e.id) and (_is_stage_mob(e.id) or _is_route_mvp(e) or (mvp_pet and tower != null)):
		var chance: float = any.call(float(GameData.PETS[e.id].drop) * special_mult * drop)
		if mvp_pet:
			chance *= 1.0 + GameData.HELL_EGG_STEP * GameData.hell_level(danger)

		var doomed: = GameData.DOOM_EGG if mvp_pet else 1.0
		if not Save.has_pet(e.id) and randf() < chance * (doomed if player.doom else 1.0):
			_drop_item(e.position + Vector3(-0.6, 0, 0), "tame", e.id, GameData.PETS[e.id].tame)


		for h in heroes:
			if h != player and net.is_remote(h) and randf() < chance * (doomed if h.doom else 1.0):
				net.send_got(h, "tame", e.id)
	var bloody: float = GameData.ELITE_BLOODY_CHANCE if e.def.get("elite", false) else GameData.BLOODY_BRANCH_CHANCE
	if randf() < any.call(bloody * special_mult * drop):
		_drop_item(e.position + Vector3(0, 0, 0.6), "branch", "bloody", "item_bloody_branch")
	elif randf() < any.call(GameData.DEAD_BRANCH_CHANCE * special_mult * drop):
		_drop_item(e.position + Vector3(0, 0, 0.6), "branch", "dead", "item_dead_branch")
	if e.def.get("elite", false):
		if randf() < GameData.POWER_ELITE_CHANCE:
			_drop_power(e.position + Vector3(0.6, 0, -0.4), GameData.POWER_DROPS.keys().pick_random())
	else:
		for id in GameData.POWER_DROPS:
			if randf() < any.call(float(GameData.POWER_DROPS[id].chance) * special_mult * drop):
				_drop_power(e.position + Vector3(0.6, 0, -0.4), id)
				break


func _drop_power(at: Vector3, id: String) -> void :
	_drop_item(at, "power", id, "item_" + id)



func _mvp_tomb(e: Enemy) -> void :
	var spr: = RoAssets.sprite(["mob_tomb"])
	if spr == null:
		return
	var tomb: = RoVisual.new()
	run_root.add_child(tomb)
	tomb.setup(spr, Color.GRAY, 40)
	tomb.position = e.position
	tomb.play(0, false)



func emote(target: Node3D, key: String, duration: = 1.8) -> void :
	if net.recording() and target != null:
		net.record(["e", net.ref_of(target), key, duration])
	emote_at(target, int(GameData.EMOTES.get(key, 0)), duration)



func emote_at(target: Node3D, idx: int, duration: = 1.8) -> void :
	var spr: = RoAssets.sprite(["fx_emotion"])
	if spr == null or target == null or not is_instance_valid(target):
		return
	if idx < 0 or idx >= spr.action_count():
		return
	var old = target.get_meta("emote") if target.has_meta("emote") else null
	if old != null and is_instance_valid(old):
		old.queue_free()
	var v: = RoVisual.new()
	target.add_child(v)
	v.setup(spr, Color.WHITE, 20, 0.0)
	v.sprite.no_depth_test = true
	v.sprite.render_priority = 16
	v.position = _emote_offset(target, spr, idx)
	v.turns = false
	v.dir = idx % RoSprite.DIRS
	v.play(idx / RoSprite.DIRS, true, true)
	target.set_meta("emote", v)
	var life: = v.create_tween()
	life.tween_interval(duration)
	life.tween_callback(v.queue_free)


var _emote_rects: = {}




func _emote_offset(target: Node3D, spr: RoSprite, idx: int) -> Vector3:
	var top: = 2.4
	var body = target if target is RoVisual else (target.get("visual") if "visual" in target else null)
	if body is MobAnim:

		top = (body as MobAnim).height() * (body as MobAnim).grow * 0.72
	if body is RoVisual and (body as RoVisual).ro != null:
		var ro: RoSprite = (body as RoVisual).ro
		var img: = ro.compose_image(0, 0)
		var used: = img.get_used_rect()
		top = (ro.origin.y - used.position.y) * GameData.PIXEL_SIZE * (body as Node3D).scale.y
	if not _emote_rects.has(idx):

		var best: = Rect2i()
		for f in spr.frame_count(idx):
			var u: = spr.compose_image(idx, f).get_used_rect()
			if u.get_area() > best.get_area():
				best = u
		_emote_rects[idx] = best
	var r: Rect2i = _emote_rects[idx]
	var cx: = (r.position.x + r.size.x * 0.5 - spr.origin.x) * GameData.PIXEL_SIZE
	var bottom: = (r.end.y - spr.origin.y) * GameData.PIXEL_SIZE



	var up: = Vector3(0, cos(cam_pitch), - sin(cam_pitch))
	return Vector3( - cx, 0, 0) + up * (top + 0.1 + bottom)




func use_branch(kind: String, by: Player = null) -> void :
	var who: Player = by if by != null and is_instance_valid(by) else player
	smoke_stats[kind] += 1
	emote(who, "surprise")
	if kind == "bloody":
		var id: String = GameData.BLOODY_BOSSES.pick_random()


		var at: = map.find_point_around(who.position, GameData.BRANCH_BOSS_NEAR, GameData.BRANCH_BOSS_FAR)
		if at == Vector3.INF:
			at = map.find_point_around(who.position, 7.0, GameData.BRANCH_BOSS_NEAR)
		if at == Vector3.INF:
			at = map.random_point_around(who.position, 9.0)
		at.y = map.height_at(at)
		Vfx.telegraph_circle(fx_root, at + Vector3(0, 0.05, 0), 2.2, GameData.BRANCH_BOSS_WARN)
		party_announce(tr("Bloody Branch"), Color(1, 0.35, 0.35), tr("¡Algo poderoso se acerca!"))
		get_tree().create_timer(GameData.BRANCH_BOSS_WARN, false).timeout.connect( func():
			if not running:
				return
			var b: = spawn_enemy(id, at, true)
			if b != null:


				b.xp = roundi(b.xp * (1.0 + time / GameData.BRANCH_XP_EVERY))
				if boss == null:
					boss = b
				spawn_fx("devil", at, 1.2, 1.0)
				party_announce(tr("Bloody Branch"), Color(1, 0.35, 0.35), tr("¡%s ha sido invocado!") % tr(b.def.name)))
		return
	var pool: Array = []

	var st: Dictionary = TowerRun.tier_stage(tower.floor) if tower != null else stage
	for sp in st.spawns:
		if time >= float(sp.from):
			pool.append(sp.mob)
	if pool.is_empty():
		pool.append(st.spawns[0].mob if not st.spawns.is_empty() else "poring")
	for n in GameData.DEAD_BRANCH_COUNT:
		var a: = TAU * n / float(GameData.DEAD_BRANCH_COUNT)
		var m: = spawn_enemy(pool.pick_random(), who.position + Vector3(cos(a), 0, sin(a)) * 6.0, true)
		if m != null:
			m.summoned = true
			m.xp = roundi(m.xp * (2.0 + time / GameData.BRANCH_XP_EVERY))
	party_announce(tr("Dead Branch"), Color(0.85, 0.75, 0.55), tr("¡Aparecen monstruos!"))


var _prop_timer: = 0.0
var _autosave: = RunSave.EVERY





func _update_props(delta: float) -> void :

	if raid.active() or training:
		return
	var count: = 0
	for e in enemies:
		if e.prop == "" or e.dead:
			continue
		var d: = _flat_dist(e.position, player.position)
		if d > GameData.PROP_DESPAWN_DIST:
			enemies.erase(e)
			_grid_fresh = false
			e.queue_free()
			break
		count += 1
		if d < e.radius + player.radius + 0.25:
			damage_enemy(e, e.max_hp * 2.0, Vector3.ZERO, "basic", "neutral", "prop")
	_prop_timer -= delta
	if _prop_timer > 0.0 or count >= GameData.PROP_COUNT:
		return
	_prop_timer = GameData.PROP_RESPAWN if count > GameData.PROP_COUNT / 2 else 0.5
	var at: = _prop_spot()
	if at == Vector3.INF:
		return
	var id: = "steelbox" if randf() < GameData.PROP_STEEL_CHANCE else "woodbox"
	var box: = spawn_enemy(id, at, true)
	if box != null:
		box.summoned = true
		box.max_hp *= 1.0 + time / 300.0
		box.hp = box.max_hp





func _prop_spot() -> Vector3:
	for i in 24:
		var p: = map.find_point_around(player.position, GameData.PROP_MIN_DIST, GameData.PROP_MAX_DIST)
		if p == Vector3.INF:
			continue
		var c: = map.tile_of(p)
		var ok: = true
		var h: = map.height_at(map.cell_center(c.x, c.y))
		for dx in [-1, 0, 1]:
			for dy in [-1, 0, 1]:
				if not map.cell_walkable(c.x + dx, c.y + dy)\
				or absf(map.height_at(map.cell_center(c.x + dx, c.y + dy)) - h) > 0.6:
					ok = false
		if not ok or not flow.reachable(p):
			continue
		for e in enemies:
			if e.prop != "" and _flat_dist(e.position, p) < 6.0:
				ok = false
				break
		if ok:
			var at: = map.cell_center(c.x, c.y)
			return Vector3(at.x, h, at.z)
	return Vector3.INF


func _break_prop(e: Enemy) -> void :
	enemies.erase(e)
	_grid_fresh = false
	var loot: Dictionary = GameData.PROPS[e.prop]
	play_sound("chest_open", 0.1, -6.0)
	Vfx.burst(fx_root, e.position, 1.6, e.def.color)
	e.die()

	e.create_tween().tween_callback(e.queue_free).set_delay(0.6)
	var zeny: = randi_range(int(loot.zeny[0]), int(loot.zeny[1]))
	for i in 3:
		var s: = _zeny_sprite(ceili(zeny / 3.0))
		var p: = {"node": s, "kind": "loot", "value": ceili(zeny / 3.0), "pull": false, "spr": "zeny"}
		pickups.append(p)
		var to: = map.random_point_around(e.position, 0.9)
		_pop(p, e.position + Vector3(0, 0.3, 0), to + Vector3(0, 0.25, 0), 1.2)
	if randf() < float(loot.potion):
		_drop_item(map.random_point_around(e.position, 0.8), "potion", "")
	if randf() < float(loot.power):
		_drop_power(map.random_point_around(e.position, 0.8), GameData.POWER_DROPS.keys().pick_random())
	elif randf() < float(loot.branch):
		_drop_item(map.random_point_around(e.position, 0.8), "branch", "dead", "item_dead_branch")




func legend_proc(p: Player, text: String, color: Color, fx: = "") -> void :
	number(p.position + Vector3(0, 2.0, 0), text, color, true)
	if fx != "":
		spawn_fx(fx, p.position, 1.0, 0.8, p)
	play_sound("job_levelup", 0.0, -8.0)




func nine_tail_reflect(p: Player, amount: float) -> void :
	if amount <= 0.0:
		return
	var tag: = damage_tag
	var by: = damage_by
	damage_tag = "nine_tail"
	damage_by = p
	var base: = amount / maxf(0.01, p.dmg_mult * p.skill_mult)
	for e in enemies_in_radius(p.position, float(GameData.RECIPES.nine_tail_dish.radius)):
		damage_enemy(e, base, Vector3.ZERO, "skill", "fire")
	damage_tag = tag
	damage_by = by



func aegis_burst(p: Player) -> void :
	var r: = GameData.AEGIS_RADIUS * sqrt(p.area_mult)
	sprite_fx("fx_shield", p.position + Vector3(0, 1.1, 0), 0, 1.0)
	Vfx.ring(fx_root, p.position, r, Color(1.0, 0.92, 0.6), 0.4)
	play_sound("guard_block", 0.1, -4.0)
	number(p.position + Vector3(0, 2.0, 0), tr("Égida"), Color(1.0, 0.92, 0.6))
	var tag: = damage_tag
	var by: = damage_by
	damage_tag = "aegis"
	damage_by = p
	for e in enemies_in_radius(p.position, r):
		var away: = (e.position - p.position) * Vector3(1, 0, 1)
		damage_enemy(e, p.basic_atk() * GameData.AEGIS_DMG, away.normalized() * 4.0, "skill", "holy")
	damage_tag = tag
	damage_by = by




func pull_all_pickups(color: Color) -> void :
	for p in pickups:
		if p.kind in ["xp", "loot", "ore", "potion"]:
			p.pull = true
			p.erase("hop_t")
	play_sound("get_coin", 0.0, -4.0)
	Vfx.ring(fx_root, player.position, 8.0, color, 0.6)



func use_power(id: String, by: Player = null) -> void :

	var hero: = by if by != null and is_instance_valid(by) else player
	var pw: Dictionary = GameData.POWER_DROPS[id]
	if hero == player:
		hud.announce(tr(pw.name), pw.color, tr(pw.desc))

		hud.flash(Color(pw.color, 0.35), 0.35, 0.3 * own_fx_alpha)
	else:
		label_over(hero, tr(pw.name), pw.color)





	var fx_keep: = hero_fx_begin(hero)
	_power_fx(id, pw, hero)
	hero_fx_end(fx_keep)



func _power_fx(id: String, pw: Dictionary, hero: Player) -> void :
	match str(pw.effect):
		"magnet":


			hero.add_power(id)
			spawn_fx("ac_concentration", hero.position, 1.0, 0.9, hero)

			for p in pickups:
				if p.kind != "chest" or not p.has("fetch"):
					p.pull = true
					p.erase("hop_t")
			play_sound("get_coin", 0.0, 0.0)
			Vfx.ring(fx_root, hero.position, 8.0, pw.color, 0.6)
		"immortal":
			hero.add_power(id)
			spawn_fx("asum", hero.position, 1.0, 1.0, hero)
			play_sound("levelup", 0.0, -2.0)
		"berserk":
			if hero.effects.has("valhalla"):

				hero.add_power(id, GameData.VALHALLA_POTION_TIME)
				hero.add_power("valhalla_rage", GameData.VALHALLA_POTION_TIME)
			else:
				hero.add_power(id)
			emote(hero, "anger", 2.0)
			spawn_fx("firepillar", hero.position, 1.0, 0.8, hero)
			play_sound("job_levelup", 0.0, -3.0)
		"freeze":
			spawn_fx("stormgust", hero.position, 2.2, 0.8)
			play_sound("frost_diver", 0.0, 0.0)
			for e in enemies_in_radius(hero.position, float(pw.radius)):
				if e.prop == "":
					apply_status(e, "freeze", float(pw.duration))




func try_tame(id: String) -> void :
	if training:
		return
	var pet_def: Dictionary = GameData.PETS[id]

	if Save.has_pet(id):
		number(player.position + Vector3(0, 1.6, 0), tr("Ya tienes a %s") % tr(pet_def.name), Color(1, 0.75, 0.9))
		return
	var target: Enemy = null
	var best: = 10.0
	for e in enemies:
		if e.id == id and not e.dead:
			var d: = e.position.distance_to(player.position)
			if d < best:
				best = d
				target = e
	var ok: = randf() < float(pet_def.rate)
	var finish: = func():
		if ok:
			if target != null and is_instance_valid(target) and not target.dead:


				enemies.erase(target)
				_grid_fresh = false
				target.die()
			Save.add_pet(id)
			smoke_stats.tame_ok += 1
			emote(player, "love")
			hud.announce(tr("¡Has domado a %s!") % tr(pet_def.name), Color(1, 0.7, 0.85), tr("Llévalo como mascota desde el Álbum."))
		else:
			smoke_stats.tame_fail += 1
			emote(player, "wah")
			if target != null and is_instance_valid(target) and not target.dead:
				emote(target, "sorry")
			hud.announce(tr("%s: la doma falló") % tr(pet_def.item), Color(0.8, 0.8, 0.85), tr("Sigue intentándolo."))
	if menus.auto_pick:
		play_sound("tame_ok" if ok else "tame_fail")
		finish.call()
	else:

		menus.show_taming(id, ok, finish)



var _party_pets: = {}




func _spawn_pet() -> void :
	pet = null
	pet_id = player.pet_id
	if pet_id == "" or not GameData.PETS.has(pet_id):
		pet_id = ""

	pet = _make_pet(player.pet_skin, player)
	spawn_party_pets()




func spawn_party_pets() -> void :
	for h in _party_pets:
		if is_instance_valid(_party_pets[h]):
			_party_pets[h].queue_free()
	_party_pets.clear()
	for h in heroes:
		if h == player or h.input is HeroInput.BotHero:
			continue
		var v: = _make_pet(h.pet_skin, h)
		if v != null:
			_party_pets[h] = v


func _make_pet(look: String, owner: Player) -> RoVisual:
	if look == "" or not GameData.PETS.has(look) or not GameData.MONSTERS.has(look):
		return null
	var v: = RoVisual.new()
	run_root.add_child(v)
	v.setup(RoAssets.sprite([look]), GameData.MONSTERS[look].color, 30, 0.7)
	v.position = owner.position + Vector3(1.2, 0, 1.0)

	v.show_through(0.3)
	v.play(RoVisual.MOB_IDLE)
	if GameData.PETS[look].get("mvp", false):

		v.scale = Vector3.ONE * GameData.MVP_PET_SCALE
		var aura: = MvpAura.new()
		aura.setup(GameData.RAIDS.get(look, {}).get("color", GameData.MONSTERS[look].color), 0.9)
		v.add_child(aura)
	return v







var _picks_t: = 0.0
func _training_picks(delta: float) -> void :
	_picks_t -= delta
	if _picks_t > 0.0 or not training or festival_mode or world_boss != null or net.is_client() or player == null:
		return
	_picks_t = 0.5
	if not _training_build.is_empty() and str(_training_build.get("class", "")) == player.class_id:
		var b: = _training_build
		_training_build = {}
		_training_auto = 0
		_festival_hero(player, b)
		hud.bind(self)
		hud.announce(tr("Build cargada"), Color(0.6, 0.9, 0.6), festival_line(b))
		return
	var pid: = Save.active_pet()
	var skin: = Save.pet_skin()
	var pacts: Array = Save.pacts(player.class_id).slice(0, GameData.MAX_PACTS)
	var dishes: Array = Save.dishes().filter( func(d): return GameData.RECIPES.has(str(d)))
	if pid == player.pet_id and skin == player.pet_skin and pacts == player.pacts and dishes == player.dishes:
		return
	var new_pet: = pid != player.pet_id or skin != player.pet_skin
	player.pet_id = pid
	player.pet_skin = skin
	player.pacts = pacts.duplicate()
	player.dishes = dishes.duplicate()
	player.recompute()
	if new_pet:
		if pet != null and is_instance_valid(pet):
			pet.queue_free()
		_spawn_pet()
	hud.bind(self)


func _update_pet(delta: float) -> void :
	if pet != null and is_instance_valid(pet):
		_follow_pet(pet, player, delta)
	for h in _party_pets:
		if is_instance_valid(h) and is_instance_valid(_party_pets[h]):
			_follow_pet(_party_pets[h], h, delta)


func _follow_pet(v: RoVisual, owner: Player, delta: float) -> void :

	if v.get_meta("fetching", false):
		if Time.get_ticks_msec() - int(v.get_meta("fetch_t", 0)) < 300:
			return
		v.set_meta("fetching", false)
	var spot: = owner.position - owner.facing * 1.3 + Vector3(0.6, 0, 0)
	var to: = (spot - v.position) * Vector3(1, 0, 1)
	var d: = to.length()
	var acting: = float(v.get_meta("act_t", 0.0)) > 0.0
	if acting:
		v.set_meta("act_t", float(v.get_meta("act_t")) - delta)
	if d > 12.0:
		v.position = Vector3(spot.x, map.height_at(spot), spot.z)
	elif d > 0.4:
		var step: = to / d * minf(d, owner.move_speed * 1.1 * delta * (1.5 if d > 3.0 else 1.0))
		var p: = map.slide(v.position, step)

		if (p - v.position).length_squared() < step.length_squared() * 0.04:
			p = v.position + step
		v.position = Vector3(p.x, map.height_at(p), p.z)
		v.face(to)
		if not acting:
			v.play(RoVisual.MOB_WALK)
	elif not acting:
		v.play(RoVisual.MOB_IDLE)

	v.position.y = map.height_at(v.position)



func pet_of(h: Player) -> RoVisual:
	var v = pet if h == player else _party_pets.get(h)
	return v if v != null and is_instance_valid(v) else null





func _tick_pet_skills(delta: float) -> void :
	for h in heroes:
		if h.downed or h.hp <= 0.0 or not GameData.PETS.has(h.pet_id):
			continue
		var sk: Dictionary = GameData.PETS[h.pet_id].get("skill", {})
		if sk.is_empty():
			continue
		h.pet_skill_t -= delta
		if h.pet_skill_t > 0.0:
			continue
		var v: = pet_of(h)
		var at: = v.position if v != null else h.position
		if not _pet_skill(h, sk, at):
			h.pet_skill_t = 0.5
			continue
		h.pet_skill_t = float(sk.every)
		if v != null:
			v.play(RoVisual.MOB_ATTACK, false, true)
			v.set_meta("act_t", 0.6)
		play_mob_sound(h.pet_id, "attack")
		number(at + Vector3(0, 1.6, 0), tr(str(sk.name)), GameData.RAIDS.get(h.pet_id, {}).get("color", Color(1, 0.85, 0.5)))




func _pet_skill(h: Player, sk: Dictionary, at: Vector3) -> bool:
	var tag: = "pet:" + h.pet_id
	var dmg: = float(sk.get("dmg", 0.0)) * GameData.MVP_PET_DMG * (1.0 + GameData.MVP_PET_LEVEL_DMG * (h.level - 1))
	var el: = str(sk.get("element", "neutral"))
	var col: Color = GameData.RAIDS.get(h.pet_id, {}).get("color", Color.WHITE)
	match str(sk.kind):
		"nova":
			var r: = float(sk.radius) * h.area_mult
			var hit: = enemies_in_radius(h.position, r)
			if hit.is_empty():
				return false
			spawn_fx(str(sk.fx), h.position, maxf(1.0, r / 3.0), 0.9)
			Vfx.ring(fx_root, h.position, r, col, 0.4)
			if sk.has("pull"):
				Vfx.converge(fx_root, h.position, r, col, 0.35)
			for e in hit:
				_pet_hit(h, e, dmg, el, tag, sk)
		"strikes":
			var near: = enemies_in_radius(h.position, float(sk.range))
			if near.is_empty():
				return false
			near.shuffle()

			if str(sk.get("target", "")) == "tough":
				near.sort_custom( func(a, b): return a.max_hp > b.max_hp)
			for e in near.slice(0, int(sk.count)):
				spawn_fx(str(sk.fx), e.position, 1.0, 0.8)
				_pet_hit(h, e, dmg, el, tag, sk)
		"heal", "shield":
			var tint: = Color(0.6, 1.0, 0.65) if sk.kind == "heal" else Color(0.6, 0.85, 1.0)
			for hh in heroes:
				if hh.downed or hh.hp <= 0.0 or hh.position.distance_to(h.position) > float(sk.radius):
					continue
				if sk.kind == "heal":
					hh.heal(hh.max_hp * float(sk.pct) * (1.0 + float(h.effects.get("heal_power", 0.0))), self, false, "pet", h)
				else:
					hh.shield = maxf(hh.shield, hh.max_hp * float(sk.pct) * hh.vit_shield_mult())
					hh.shield_peak = maxf(hh.shield_peak, hh.shield)
				spawn_fx(str(sk.fx), hh.position, 1.0, 0.8, hh)
			Vfx.ring(fx_root, h.position, float(sk.radius), tint, 0.5)
		"power":

			var pw: Dictionary = GameData.PET_POWERS[str(sk.power)]
			for hh in heroes:
				if hh.downed or hh.hp <= 0.0 or hh.position.distance_to(h.position) > float(sk.radius):
					continue
				hh.add_power(str(sk.power), float(sk.time))
				if sk.has("tex_fx"):
					rising_tex(hh, str(sk.tex_fx), 3)
				else:
					Vfx.column(fx_root, hh.position, pw.color)
			Vfx.ring(fx_root, h.position, float(sk.radius), pw.color, 0.5)
		"echo":


			var ids: Array = []
			for id in h.skills:
				var s: Dictionary = GameData.SKILLS[id]
				if str(s.type) in GameData.PET_ECHO_TYPES and not s.get("stance", false) and not s.get("combo_only", false)\
				and not h.is_toggle(id) and not h.is_hold(id) and not h.is_off(id):
					ids.append(id)

			if ids.is_empty() or h.powers.has("oath_silence") or not any_enemy_near(h.position, 9.0):
				return false
			ids.shuffle()
			var keep_tag: = damage_tag
			var keep_by: = damage_by
			var cast: = 0
			for id in ids:
				if cast >= int(sk.get("count", 1)):
					break


				if Skills.cast(self, h, id, int(h.skills[id].level), tag + ":" + id):
					cast += 1
					number(h.position + Vector3(0, 2.6 + 0.4 * cast, 0), tr(str(GameData.SKILLS[id].name)), Color(0.8, 0.7, 1.0))
			damage_tag = keep_tag
			damage_by = keep_by
			if cast == 0:
				return false
			spawn_fx(str(sk.fx), h.position, 0.8, 0.6)
			Vfx.column(fx_root, h.position, Color(0.75, 0.6, 1.0))
	if sk.has("extra"):
		_pet_skill(h, sk.extra, at)
	return true


func _pet_hit(h: Player, e: Enemy, dmg: float, el: String, tag: String, sk: Dictionary) -> void :
	if e.dead:
		return
	damage_by = h
	damage_tag = tag

	var flat: = (e.position - h.position) * Vector3(1, 0, 1)
	var push: = Vector3.ZERO
	if sk.has("pull") and flat.length() > 0.3:
		push = - flat.normalized() * minf(float(sk.pull), flat.length() * 3.0)
	elif sk.has("push"):
		push = (flat.normalized() if flat.length() > 0.01 else Vector3.RIGHT) * float(sk.push)
	damage_enemy(e, dmg, push, "skill", el, tag)
	if sk.has("splash"):

		for o in enemies_in_radius(e.position, float(sk.splash)):
			if o != e and not o.dead:
				var away: = (o.position - e.position) * Vector3(1, 0, 1)
				damage_enemy(o, dmg * 0.6, away.normalized() * float(sk.get("push", 0.0)) if away.length() > 0.01 else Vector3.ZERO, "skill", el, tag)
		Vfx.ring(fx_root, e.position + Vector3(0, 0.05, 0), float(sk.splash), GameData.RAIDS.get(h.pet_id, {}).get("color", Color.WHITE), 0.3)
	if not e.dead:
		if sk.has("status") and not e.is_boss:
			apply_status(e, str(sk.status), float(sk.status_time))
		match str(sk.get("dot", "")):
			"poison":
				apply_poison(e, dmg * GameData.POISON_DPS, GameData.PET_DOT_POISON_TIME)
			"burn":
				dots.burn_on(self, e, dmg * GameData.BURN_ONCE, tag, h)
			"bleed":
				dots.bleed_on(self, e, dmg, tag, h)
		if sk.has("mark"):

			e.lex_until = time + GameData.PET_MARK_TIME
			e.lex_mult = float(sk.mark)
			spawn_fx("lexaeterna", e.position, 0.6 if not e.is_boss else 0.85, 1.0, e)
			_skill_mark(e, "lex_aeterna", "lex_until", 0.85)
		if sk.has("frail"):

			e.acid_frail = maxf(e.acid_frail if e.acid_until > clock else 0.0, float(sk.frail))
			e.acid_until = maxf(e.acid_until, clock + GameData.PET_FRAIL_TIME)
		if sk.has("execute") and not e.is_boss and e.hp > 0.0 and e.hp < e.max_hp * float(sk.execute):
			side_word(e, tr("¡Rematado!"), Color(0.85, 0.5, 1.0))
			damage_enemy(e, e.hp * 8.0 / maxf(0.05, h.dmg_mult * h.skill_mult_for(tag)), Vector3.ZERO, "skill", el, tag)
		if sk.has("judge"):


			var most: = roundi(float(h.effects.get("judgment", 0.0)))
			for i in int(sk.judge):
				e.judgment_at = -100.0
				_judge(e, most)
		if sk.has("coins") and randf() < GameData.PET_COIN_CHANCE:
			_runner_coins(e.position, maxi(1, roundi(float(sk.coins) * (1.0 + 0.1 * h.level))))
	damage_by = null


func _drop_item(at: Vector3, kind: String, id: String, sprite_key: = "") -> void :
	var key: = sprite_key if sprite_key != "" else ("item_card" if kind == "card" else "item_potion")
	var spr: = RoAssets.sprite([key])
	var s: = Sprite3D.new()
	if spr != null:
		s.texture = spr.get_frame(0, 0)
	else:
		s.texture = RoAssets.placeholder(Color(0.95, 0.85, 0.5) if kind == "card" else Color(0.95, 0.25, 0.25), 22, false)
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.shaded = false
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	s.pixel_size = GameData.PIXEL_SIZE * 1.4
	run_root.add_child(s)
	var p: = {"node": s, "kind": kind, "id": id, "value": 1 if kind == "potion" else 0, "pull": false, "spr": key}
	pickups.append(p)
	_pop(p, at + Vector3(0, 0.5, 0), at + Vector3(0, 0.5, 0), 1.6)
	var marks: = {"card": [Color(1, 0.85, 0.3), 4.0, "drop_purple"], "tame": [Color(0.5, 1, 0.6), 3.0, "drop_green"], 
		"branch": [Color(1, 0.35, 0.3) if id == "bloody" else Color(0.75, 0.6, 1), 3.0, "drop_pink" if id == "bloody" else "drop_green"], 
		"power": [GameData.POWER_DROPS[id].color if GameData.POWER_DROPS.has(id) else Color.WHITE, 3.5, "drop_yellow"]}
	if marks.has(kind):
		_drop_marker(s, marks[kind][0], marks[kind][1], -0.5)
		play_sound(marks[kind][2], 0.3, -6.0)

	var hover: = s.create_tween()
	hover.tween_interval(DROP_HOP_TIME)
	hover.tween_callback( func():
		var tw: = s.create_tween().set_loops()
		tw.tween_property(s, "position:y", at.y + 0.8, 0.6).set_trans(Tween.TRANS_SINE)
		tw.tween_property(s, "position:y", at.y + 0.5, 0.6).set_trans(Tween.TRANS_SINE))


func _update_pickups(delta: float) -> void :
	_merge_t -= delta
	if _merge_t <= 0.0:
		_merge_t = GameData.PICKUP_MERGE_EVERY
		for kind in GameData.PICKUP_CAP:
			_merge_pickups(kind, int(GameData.PICKUP_CAP[kind]))

		if player.equipment.bag.size() > player.equipment.bag_max:
			add_zeny(player.equipment.fit_bag(), "sold")
	var magnet: = player.magnet * player.pickup_area
	var party: = heroes.size() > 1
	for i in range(pickups.size() - 1, -1, -1):
		var p: = pickups[i]
		var node: Node3D = p.node
		if p.has("hop_t"):
			p.hop_t += delta
			var f: = minf(1.0, p.hop_t / float(p.get("hop_dur", DROP_HOP_TIME)))
			node.position = (p.hop_from as Vector3).lerp(p.hop_to, f) + Vector3(0, sin(f * PI) * p.hop_h, 0)
			if f >= 1.0:
				p.erase("hop_t")
				if p.get("bounce", false):
					_gem_landed(p)
			continue

		if p.kind == "chest" and Time.get_ticks_msec() < _chests_held:
			continue

		if p.kind == "chest" and not p.pull:
			_try_fetch(p)
		if str(p.get("fetch", "done")) != "done" and _fetch_tick(p, p.get("to"), delta):
			continue


		var who: = player
		var mag: = magnet
		if party and p.kind in SHARED_PICKUPS:
			who = _pickup_hero(p, node.position)
			if who == null:
				continue
			mag = who.magnet * who.pickup_area
		var to: = who.position + Vector3(0, 0.5, 0) - node.position
		var d: = Vector2(to.x, to.z).length()
		var reach: = mag if p.kind in ["xp", "loot", "ore"] else item_pull(who, p.kind)
		if p.pull or d < reach:
			p.pull = true
			var step: = to.normalized()
			if p.kind == "xp":
				step = _gem_flight(p, step, d)
			node.position += step * delta * maxf(8.0, 22.0 - d * 2.0)
		if d < (GameData.CHEST_REACH if p.kind == "chest" else 0.6):


			if p.kind == "chest" and who == player and busy():
				continue
			_collect(p, who)
			node.queue_free()
			pickups.remove_at(i)



func toggle_pet_fetch() -> void :
	var on: = not bool(Save.setting("pet_fetch", true))
	Save.set_setting("pet_fetch", on)
	player.pet_fetch = on
	if net.is_client():
		net.send(1, "pet_fetch", [on])
	var v: = pet_of(player)
	var text: = (tr("Tu mascota trae los cofres lejanos") if on else tr("Tu mascota ya no trae los cofres")) if v != null\
	else tr("Sin mascota: elígela en el álbum")
	number(player.position + Vector3(0, 2.4, 0), text, Color(0.6, 0.95, 0.6) if on else Color(0.8, 0.8, 0.85), true)
	if v != null:
		emote(v, "ok" if on else "sweat", 1.4)
	ui_click_sound()


func ui_click_sound() -> void :
	play_sound("ui_click", 0.05, -4.0)





func _try_fetch(p: Dictionary) -> void :
	if p.has("hop_t") or p.has("fetch"):
		return
	var at: Vector3 = (p.node as Node3D).position
	for h in heroes:
		if h.downed or not h.pet_fetch:
			continue
		var v: = pet_of(h)
		if v == null or v.get_meta("fetching", false):
			continue
		if Vector2(h.position.x - at.x, h.position.z - at.z).length() < GameData.PET_FETCH_DIST:
			continue
		start_fetch(p, h)
		return


func start_fetch(p: Dictionary, h: Player) -> void :
	var node: Node3D = p.node
	p["fetch"] = "go"
	p["fetch_y"] = node.position.y - map.height_at(node.position)
	p["to"] = h
	p.pull = true
	var v: = pet_of(h)
	if v != null:
		v.set_meta("fetching", true)
		v.set_meta("fetch_t", Time.get_ticks_msec())
		emote(v, "go", 1.2)






func _fetch_tick(p: Dictionary, h, delta: float) -> bool:
	var v: = pet_of(h) if h != null and is_instance_valid(h) else null
	var node: Node3D = p.node
	if v == null:
		p.fetch = "done"
		return false


	var own = v.get_meta("fetch_box") if v.has_meta("fetch_box") else null
	if own != null and is_instance_valid(own) and own != node:
		p.erase("fetch")
		p.pull = false
		return false
	v.set_meta("fetch_box", node)

	p["fetch_for"] = float(p.get("fetch_for", 0.0)) + delta
	var by_hero: = Vector2(h.position.x - node.position.x, h.position.z - node.position.z).length() < GameData.CHEST_REACH * 2.0
	if by_hero or float(p.fetch_for) > GameData.PET_FETCH_MAX:
		if not by_hero:
			node.position = Vector3(h.position.x, map.height_at(h.position) + float(p.get("fetch_y", 0.0)), h.position.z)
		p.fetch = "done"
		v.remove_meta("fetch_box")
		v.set_meta("fetching", false)
		return false
	v.set_meta("fetching", true)
	v.set_meta("fetch_t", Time.get_ticks_msec())
	var back: = str(p.fetch) == "back"
	var goal: Vector3 = (h as Player).position - (h as Player).facing * 1.2 if back else node.position
	var to: = (goal - v.position) * Vector3(1, 0, 1)
	var d: = to.length()
	var step: = minf(d, GameData.PET_FETCH_SPEED * delta)
	if d > 0.01:
		v.position += to / d * step
		v.face(to)
	v.position.y = map.height_at(v.position)
	v.play(RoVisual.MOB_WALK)
	if back:
		node.position = v.position + Vector3(0, 1.3, 0)
	if d - step > 0.6:
		return true
	if not back:

		p.fetch = "back"
		play_sound("drop_blue", 0.2, -10.0)
		return true

	node.position = Vector3(v.position.x, map.height_at(v.position) + float(p.get("fetch_y", 0.0)), v.position.z)
	p.fetch = "done"
	v.remove_meta("fetch_box")
	v.set_meta("fetching", false)
	emote(v, "love", 1.4)
	return false




func _gem_landed(p: Dictionary) -> void :
	p.erase("bounce")
	var at: Vector3 = p.node.position
	p.hop_t = 0.0
	p.hop_dur = 0.22
	p.hop_from = at
	p.hop_to = at
	p.hop_h = 0.28
	if int(p.tier) >= GameData.XP_GEMS.size() - 1:
		play_sound("drop_yellow", 0.3, -12.0)
	else:
		play_sound("drop_blue", 0.25, -15.0)





func _gem_flight(p: Dictionary, dir: Vector3, d: float) -> Vector3:
	if GemRenderer.plain:
		return dir
	if not p.has("curve"):
		p["curve"] = randf_range(0.35, 0.7) * (1.0 if randf() < 0.5 else -1.0)
		p["d0"] = maxf(d, 0.5)
		p["trail"] = []
	var trail: Array = p.trail
	trail.push_front(p.node.position)
	if trail.size() > 3:
		trail.pop_back()
	var side: = Vector3( - dir.z, 0.0, dir.x) * float(p.curve) * clampf(d / float(p.d0), 0.0, 1.0)
	return (dir + side).normalized()





var _ding_step: = 0
var _ding_last: = -100000
func _gem_ding(tier: int) -> void :
	var now: = Time.get_ticks_msec()
	if now - _ding_last < int(GameData.GEM_DING_GAP * 1000.0):
		return
	var notes: Array = GameData.GEM_DING_NOTES
	_ding_step = mini(_ding_step + 1, notes.size() - 1) if now - _ding_last < int(GameData.GEM_DING_RESET * 1000.0) else 0
	_ding_last = now

	var db: = GameData.GEM_DING_DB + 1.5 * tier - (2.0 if _ding_step == notes.size() - 1 else 0.0)
	play_sound("gem_ding", 0.0, db, pow(2.0, float(notes[_ding_step]) / 12.0))
	hud.xp_glow()






const SHARED_PICKUPS: = ["xp", "loot", "ore", "potion", "chest", "card", "power", "tame", "branch"]





func item_pull(h: Player, kind: String) -> float:
	var base: = GameData.CHEST_PULL if kind == "chest" else GameData.ITEM_PULL
	var bonus: = maxf(0.0, h.magnet / Player.BASE_MAGNET - 1.0)
	var reach: = base * (1.0 + bonus * GameData.ITEM_PULL_SHARE)
	if h.powers.has("bubble_gum"):
		reach = maxf(reach, h.magnet * h.pickup_area * 2.0)
	return reach




func _pickup_hero(p: Dictionary, at: Vector3) -> Player:
	var h = p.get("to")
	if h != null and is_instance_valid(h) and not h.downed:
		return h
	var best: Player = null
	var best_d: = INF
	for o in heroes:
		if o.downed:
			continue
		var d: = Vector2(o.position.x - at.x, o.position.z - at.z).length()
		var reach: = o.magnet * o.pickup_area if p.kind in ["xp", "loot", "ore"] else item_pull(o, p.kind)
		if d < best_d and (d < reach or p.pull):
			best_d = d
			best = o
	if best != null:
		p["to"] = best
	return best


var _merge_t: = 0.0



func _merge_pickups(kind: String, cap: int) -> void :
	var lying: Array[Dictionary] = []
	for p in pickups:
		if p.kind == kind and not p.pull and not p.has("hop_t"):
			lying.append(p)
	if lying.size() <= cap:
		return
	var cell: = GameData.PICKUP_MERGE_CELL

	var gone: = {}
	var count: = lying.size()
	while count > cap and cell < 200.0:
		var keep: = {}
		for p in lying:
			var node: Node3D = p.node
			if gone.has(node.get_instance_id()):
				continue
			var key: = Vector2i(floori(node.position.x / cell), floori(node.position.z / cell))
			if not keep.has(key):
				keep[key] = p
				continue
			var big: Dictionary = keep[key]
			var small: = p
			if int(p.value) > int(big.value):
				keep[key] = p
				small = big
				big = p
			big.value = int(big.value) + int(small.value)
			gone[(small.node as Node3D).get_instance_id()] = true
			count -= 1

			_merge_slide(small.node, (big.node as Node3D).position)
		cell *= 2.0
	if gone.is_empty():
		return
	pickups.assign(pickups.filter( func(p): return not gone.has((p.node as Node3D).get_instance_id())))
	if kind == "xp" or kind == "potion":
		for p in lying:
			if gone.has((p.node as Node3D).get_instance_id()):
				continue
			if kind == "xp":
				_gem_look(p, int(p.value))
			else:
				_potion_look(p)




func _potion_look(p: Dictionary) -> void :
	var tier: = mini(int(p.value), GameData.POTION_SPRITES.size()) - 1
	var key: String = GameData.POTION_SPRITES[tier]
	var spr: = RoAssets.sprite([key])
	if spr != null and key != str(p.spr):
		p.spr = key
		var s: = p.node as Sprite3D
		s.texture = spr.get_frame(0, 0)
		s.pixel_size = GameData.PIXEL_SIZE * (1.4 + tier * 0.15)
	if int(p.value) >= GameData.POTION_HOME_AT:
		p.pull = true


func _merge_slide(node: Node3D, to: Vector3) -> void :
	if not is_instance_valid(node):
		return
	if node is Sprite3D or node.has_meta("zeny"):
		var tw: = node.create_tween()
		tw.tween_property(node, "position", to, 0.18)
		tw.tween_callback(node.queue_free)
	else:
		node.queue_free()


func _collect(p: Dictionary, hero: Player = null) -> void :
	var by: = hero if hero != null else player


	if training and str(p.get("kind", "")) in ["chest", "ore", "loot", "tame", "card"]:
		return
	match p.kind:
		"xp":
			if not p.get("direct", false):
				_gem_ding(int(p.get("tier", 0)))
			else:
				hud.xp_glow(0.12)
				hud.xp_gain(p.value * GameData.coop_xp(heroes.size()) * player.pace_xp * player.xp_mult)


			var share: = GameData.coop_xp(heroes.size())
			player.add_xp(p.value * share)
			for h in heroes:
				if h != player:
					h.add_xp(p.value * share)
		"potion":
			by.heal(by.max_hp * minf(1.0, GameData.POTION_HEAL * maxi(1, int(p.value))), self, false, "potion")
			play_sound("heal")
		"chest":

			if p.get("corrupt", false):
				karma.chest_choice((p.node as Node3D).position, by)
				return

			for h in heroes:
				h.equipment.chest_legend = GameData.SATAN_LEGEND_CHANCE if p.get("satan", false) else (1.0 if p.get("treasure", false) else 0.0)
				h.equipment.chest_extra = GameData.VALKYRIE_LEGEND_CHANCE if p.get("valkyrie", false) else 0.0
			if heroes.size() > 1 and _coop_chest(p, by):
				for h in heroes:
					h.equipment.chest_legend = 0.0
					h.equipment.chest_extra = 0.0
				return
			var results: = player.open_chest(int(p.value), int(p.get("bonus", 0)), time, int(p.get("plain", 0)))
			player.equipment.chest_legend = 0.0
			player.equipment.chest_extra = 0.0

			var uid: = str(p.get("unique", ""))
			if uid == "" and int(p.get("bonus", 0)) >= 0:
				uid = _roll_unique(GameData.UNIQUE_BOSS_CHANCE)
			if uid != "":
				results.append(_found_unique(uid))
			if int(p.get("bonus", 0)) < 0:

				var z: = roundi((GameData.SMALL_CHEST_ZENY + time / 10.0) * player.loot_mult)
				add_zeny(z, "chest")
			for r in results:
				if Equipment.is_legendary(r.item):
					emote(player, "money", 2.5)
				if int(r.zeny) > 0:
					add_zeny(int(r.zeny), "sold")
				if int(r.get("coins", 0)) > 0:
					legend_coin_note(int(r.coins))
			if results.all( func(r): return r.result == "sold"):

				var total: = 0
				for r in results:
					total += int(r.zeny)
				_sale_feedback(p.node.position, total)
			else:
				var cursed: bool = p.get("cursed", false)
				_open_chest_show(p.node.position + Vector3(0, -0.5, 0), int(p.get("tier", 0)), results, 
					tr("Cofre Corrupto") if cursed else (tr("Tesoro de la Torre") if p.has("treasure") else (tr("Tesoro de Satan Morroc") if p.has("satan") else "")), "chest_corrupt" if cursed else "")
		"ore":

			for h in heroes:
				if h != player:
					h.equipment.gain_ore(str(p.id))
					net.send_got(h, "ore", str(p.id))
			player.equipment.gain_ore(str(p.id))



			hud.prize(str(p.id), tr("+%d %s  ·  tienes %d") % [1, tr(GameData.ORES[p.id].name), int(player.equipment.ores[p.id])], 
				Color(GameData.ORES[p.id].color).darkened(0.35))
		"loot":

			var share: = 1.0 / GameData.coop_spawn(heroes.size())
			var z: = roundi(p.value * player.loot_mult * share)
			add_zeny(z, "loot")
			_zeny_chime(z)
			for h in heroes:
				if h != player:
					add_zeny(roundi(p.value * h.loot_mult * share), "loot", h)
		"tame":
			if by != player and net.is_remote(by):
				net.send_got(by, "tame", str(p.id))
			else:
				try_tame(p.id)
		"branch":
			use_branch(p.id, by)
		"power":
			use_power(p.id, by)
		"card":

			_take_card(str(p.id), (p.node as Node3D).position)
			for h in heroes:
				if h != player:
					give_card(h, str(p.id))





func _open_chest_show(at: Vector3, tier: int, results: Array, title: = "", sprite: = "") -> void :
	var color: Color = GameData.CORRUPT_COLOR if sprite == "chest_corrupt" else GameData.CHEST_COLORS[tier]
	var box_fx: = Node3D.new()
	box_fx.process_mode = Node.PROCESS_MODE_ALWAYS
	fx_root.add_child(box_fx)
	box_fx.global_position = at


	var shown: = own_fx_alpha > 0.01
	var spr: = RoAssets.sprite([sprite, "chest_npc"] if sprite != "" else ["chest_npc"]) if shown else null
	if spr != null:
		var open: = RoVisual.new()
		box_fx.add_child(open)
		open.setup(spr, Color.WHITE, 32, 0.0)
		open.turns = false
		open.play(0, true)
		open.scale = Vector3.ONE * 0.3
		open.create_tween().tween_property(open, "scale", Vector3.ONE * 1.25, 0.35)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if shown:
		RoEffect.spawn(box_fx, "itempokjuk", at + Vector3(0, 0.4, 0), 1.2)
		Vfx.burst(box_fx, Vector3.ZERO, 3.0, color)
		Vfx.ring(box_fx, Vector3.ZERO, 5.0, color, 0.8)
		_coin_fountain(box_fx, at, 12 + tier * 6)
	play_sound("chest_open", 0.0, 2.0)
	play_sound("get_coin", 0.0, -2.0)
	emote(player, "money" if tier > 0 else "heh", 2.0)
	var fade: = box_fx.create_tween()
	fade.tween_interval(4.0)
	fade.tween_property(box_fx, "scale", Vector3(1, 0.01, 1), 0.3)
	fade.tween_callback(box_fx.queue_free)
	if menus.auto_pick:
		return

	if not results.is_empty() and results.all( func(r): return str(r.result) == "sold" and bool(r.get("auto", false))):
		var z: = 0
		var coins: = 0
		for r in results:
			z += int(r.zeny)
			coins += int(r.get("coins", 0))
		if z > 0 or coins == 0:
			number(player.position + Vector3(0, 2.2, 0), tr("Cofre auto-vendido  +%d z") % z, Color(1.0, 0.82, 0.3), true)
		if coins > 0:
			legend_coin_note(coins)
		return


	if bool(Save.setting("hold_chests", false)) and not is_coop() and running:
		held_chests.append({"results": results, "tier": tier, "title": title, "sprite": sprite})
		for r in results:
			_loot_toast(player, r.item, "unique" if Equipment.is_unique(r.item) else str(r.result))
		return
	_chest_window(results, tier, title, sprite)



func open_held_chests() -> void :
	if not running or busy() or held_chests.is_empty():
		return
	var results: = []
	var tier: = 0
	for c in held_chests:
		results.append_array(c.results)
		tier = maxi(tier, int(c.tier))
	var one: Dictionary = held_chests[0]
	var title: = str(one.title) if held_chests.size() == 1 else tr_n("%d cofre guardado", "%d cofres guardados", held_chests.size()) % held_chests.size()
	var sprite: = str(one.sprite) if held_chests.size() == 1 else ""
	held_chests.clear()
	menus.show_chest(results, tier, title, sprite)




func _card_window(card_id: String, reveal: bool, choose: bool, tries: = 0) -> void :
	if not running:
		return
	if menus.is_open() and tries < 240:
		get_tree().create_timer(0.5, true).timeout.connect(_card_window.bind(card_id, reveal, choose, tries + 1))
		return
	if reveal:
		menus.show_card_reveal(card_id, ( func(): menus.show_card_choice(card_id)) if choose else Callable())
	else:
		menus.show_card_choice(card_id)





func _chest_window(results: Array, tier: int, title: String, sprite: String, tries: = 0) -> void :
	if not running:
		return
	if menus.is_open() and tries < 240:
		get_tree().create_timer(0.5, true).timeout.connect(_chest_window.bind(results, tier, title, sprite, tries + 1))
		return
	menus.chest_intro()
	get_tree().create_timer(0.35, true).timeout.connect( func():
		if running:
			menus.show_chest(results, tier, title, sprite))


var _sale_streak: = 0
var _sale_total: = 0
var _sale_time: = -10.0






func legend_coin_note(n: int) -> void :
	if player == null or n <= 0:
		return
	number(player.position + Vector3(0, 2.7, 0), "+%d %s" % [n, tr("Moneda legendaria")], Color(1.0, 0.72, 0.2), true)
	play_sound("get_coin", 0.0, -3.0)


func _sale_feedback(at: Vector3, z: int) -> void :
	if time - _sale_time > 2.0:
		_sale_streak = 0
		_sale_total = 0
	_sale_time = time
	_sale_streak += 1
	_sale_total += z

	var shown: = own_fx_alpha > 0.01
	if shown:
		Vfx.burst(fx_root, at, 1.0 + 0.15 * mini(_sale_streak, 6), Color(1, 0.85, 0.3))
		Vfx.ring(fx_root, at, 1.6, Color(1, 0.9, 0.4), 0.35)
	play_sound("get_coin", 0.0, -3.0)
	var spr: = RoAssets.sprite(["loot_gold_coin"])
	var tex: Texture2D = spr.get_frame(0, 0) if spr != null else RoAssets.radial(Color(1, 0.85, 0.3), 16)
	for i in (clampi(3 + z / 40, 3, 10) if shown else 0):
		var c: = Sprite3D.new()
		c.texture = tex
		c.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		c.shaded = false
		c.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		c.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		c.no_depth_test = true
		c.render_priority = 8
		c.pixel_size = GameData.PIXEL_SIZE * 0.9
		fx_root.add_child(c)
		var from: = at + Vector3(randf_range(-0.4, 0.4), 0.5, randf_range(-0.4, 0.4))
		var h: = randf_range(1.4, 2.4)
		c.global_position = from
		var tw: = c.create_tween()
		tw.tween_interval(i * 0.04)
		tw.tween_method( func(f: float):
			if not is_instance_valid(player):
				return
			var to: = player.position + Vector3(0, 1.0, 0)
			c.global_position = from.lerp(to, f * f) + Vector3(0, sin(f * PI) * h, 0), 0.0, 1.0, randf_range(0.45, 0.6))
		tw.tween_callback( func(): play_sound("coin%d" % randi_range(1, 3), 0.03, -9.0))
		tw.tween_callback(c.queue_free)
	var text: = "+%d z" % z if _sale_streak == 1 else tr("Venta x%d  ·  +%d z") % [_sale_streak, _sale_total]
	number(player.position + Vector3(0, 1.8, 0), text, Color(1, 0.85, 0.3), _sale_streak >= 3)
	if _sale_streak >= 3:
		emote(player, "money", 1.2)




func _coin_fountain(parent: Node3D, at: Vector3, count: int) -> void :
	var spr: = RoAssets.sprite(["loot_gold_coin"])
	var tex: Texture2D = spr.get_frame(0, 0) if spr != null else RoAssets.radial(Color(1, 0.85, 0.3), 16)
	for i in count:
		var c: = Sprite3D.new()
		c.texture = tex
		c.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		c.shaded = false
		c.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		c.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		c.pixel_size = GameData.PIXEL_SIZE * 0.9
		parent.add_child(c)
		var from: = at + Vector3(0, 0.6, 0)
		var ang: = randf() * TAU
		var to: = at + Vector3(cos(ang), 0.0, sin(ang)) * randf_range(1.0, 2.6) + Vector3(0, 0.15, 0)
		var h: = randf_range(1.8, 3.2)
		c.global_position = from
		var tw: = c.create_tween()
		tw.tween_interval(i * 0.025)
		tw.tween_method( func(f: float):
			c.global_position = from.lerp(to, f) + Vector3(0, sin(f * PI) * h, 0), 0.0, 1.0, randf_range(0.5, 0.75))
		tw.tween_callback( func(): play_sound("coin%d" % randi_range(1, 3), 0.05, -12.0))
		tw.tween_interval(0.6)
		tw.tween_property(c, "modulate:a", 0.0, 0.4)
		tw.tween_callback(c.queue_free)




var _level_flash_at: = -99.0
func _on_level_up(hero: Player) -> void :
	play_sound("levelup", 0.0, 0.0 if hero == player else -6.0)


	var seen: = hero_fx_alpha(hero) > 0.01
	if seen:
		RoEffect.spawn(fx_root, "h_levelup", hero.position, 1.0, hero)
		Vfx.ring(fx_root, hero.position, 2.0, Color(1, 1, 0.6), 0.6)



	_rebuild_grid()
	for e in enemies_in_radius(hero.position, GameData.LEVEL_UP_PUSH_RADIUS):
		if e.dead or e.is_boss:
			continue
		var away: = (e.position - hero.position) * Vector3(1, 0, 1)
		if away.length_squared() > 0.0:
			e.knock += away.normalized() * GameData.LEVEL_UP_PUSH
	if seen and time >= float(hero.get_meta("level_burst", -99.0)):
		hero.set_meta("level_burst", time + 1.2)
		Vfx.burst(fx_root, hero.position, GameData.LEVEL_UP_PUSH_RADIUS, Color(1, 0.9, 0.5))
	emote(hero, "heh", 1.2)
	if hero.has_dish("rice_cake"):
		_rice_cake_burst(hero)



	var refill: = int(hero.profile.get("rerolls", 0))
	if refill > 0 and not net.is_client() and hero.level > GameData.REROLL_REFILL_FROM and (hero.level - GameData.REROLL_REFILL_FROM) % GameData.REROLL_REFILL_EVERY == 0:
		hero.rerolls += refill
		number(hero.position + Vector3(0, 2.8, 0), tr("+%d rerolls") % refill, Color(0.6, 0.85, 1.0), true)
	if hero != player:
		return
	_level_up_delay = maxf(_level_up_delay, 0.42)

	if seen and time >= _level_flash_at:
		_level_flash_at = time + 4.0
		hud.flash(Color(1, 0.92, 0.55), 0.3, 0.1)
		shake(0.12)
	if pet != null:
		emote(pet, "love2", 1.2)






func _rice_cake_burst(hero: Player) -> void :
	var r: Dictionary = GameData.RECIPES.rice_cake
	for e in enemies_in_radius(hero.position, float(r.radius)):
		if e.dead or e.is_boss:
			continue
		var away: = (e.position - hero.position) * Vector3(1, 0, 1)
		if away.length_squared() > 0.0:
			e.knock += away.normalized() * float(r.push)
		e.snare_time = maxf(e.snare_time, float(r.get("glue", 0.0)) * cc_scale(e, "root"))
	hero.heal(hero.max_hp * float(r.heal), self, false, "rice_cake")
	Vfx.ring(fx_root, hero.position, float(r.radius), Color(1.0, 0.96, 0.82), 0.5)
	label_over(hero, tr(str(r.name)), Color(1.0, 0.92, 0.7))




func npc_hit(node: Node3D) -> void :
	raid.npc_hit(node)
	quest.npc_hit(node)




func refine(slot_key: String, hero: Player = null) -> Dictionary:
	var h: = hero if hero != null else player
	var res: = h.equipment.try_refine(slot_key, h.forge_on())
	if res.is_empty():
		return res
	h.recompute()


	play_sound("refine_hammer", 0.0, -4.0)
	var ok: bool = res.ok
	get_tree().create_timer(0.45, true).timeout.connect( func():
		if ok:
			play_sound("refine_ok" if RoAssets.sound("refine_ok") != null else "levelup", 0.0, -2.0)
		else:
			play_sound("refine_fail" if RoAssets.sound("refine_fail") != null else "cold_hit1", 0.0, -2.0)
		if not is_instance_valid(h):
			return
		var fx: = RoEffect.spawn(fx_root, "bs_refinesuccess" if ok else "bs_refinefailed", h.position, 1.0, h)
		if fx != null:
			fx.process_mode = Node.PROCESS_MODE_ALWAYS)
	return res





func critical_explosion(p: Player, sk: Dictionary) -> void :
	p.play_attack(p.facing, true)
	label_over(p, "Critical Explosion !!", Color(1.0, 0.95, 0.65))
	play_skill_sound(sk)
	var chest: = p.position + Vector3(0, 1.1, 0)
	Vfx.ray_flash(fx_root, chest, camera.global_basis, Color(1.0, 0.85, 0.35))
	Vfx.burst(fx_root, p.position, 2.6, Color(1.0, 0.8, 0.3))
	Vfx.ring(fx_root, p.position, 3.4, Color(1.0, 0.92, 0.6), 0.5)
	Vfx.column(fx_root, p.position, Color(1.0, 0.85, 0.4))
	Vfx.heal_light(fx_root, p.position, Color(1.0, 0.82, 0.3))
	shake(0.15)





func asura_strike(p: Player, reach: float, dmg: float, sk: Dictionary) -> void :

	var spheres: = p.take_spheres(99)
	dmg *= GameData.ASURA_BASE + GameData.ASURA_PER_SPHERE * spheres


	if sk.get("evolved", false):
		dmg *= 1.0 + pow(maxf(0.0, p.scaling_hp()), GameData.ASURA_X_HP_POW) * GameData.ASURA_X_HP_K
	var tag: = damage_tag
	var by: = damage_by




	var target: Enemy = null
	var ahead: = Vector3(p._last_stick.x, 0.0, p._last_stick.y)
	ahead = ahead.normalized() if ahead.length() > 0.1 else Vector3.ZERO
	for pass_i in (2 if ahead != Vector3.ZERO else 1):
		var best: = -1.0
		for e in enemies_in_radius(p.position, reach + 3.0):
			if e.dead or e.prop != "":
				continue


			if morroc.fighting() and _flat_dist(e.position, morroc.center) > morroc.radius:
				continue
			if pass_i == 0 and ahead != Vector3.ZERO:
				var to: = (e.position - p.position) * Vector3(1, 0, 1)
				if to.length() > 0.5 and to.normalized().dot(ahead) < 0.35:
					continue

			var score: = float(enemies_in_radius(e.position, 2.5).size()) - 0.3 * p.position.distance_to(e.position)
			if e.special == "runner":
				score = 5000.0
			elif e.is_boss:
				score = 1000.0 + score
			elif e.def.get("elite", false):
				score = 300.0 + score
			if score > best:
				best = score
				target = e
		if target != null:
			break
	if target != null:
		var old: = p.position
		var way: = ((target.position - old) * Vector3(1, 0, 1))
		way = way.normalized() if way.length() > 0.05 else p.facing
		var spot: = target.position - way * (target.radius + 0.6)
		if not map.is_walkable(spot):
			spot = target.position
		_shadow_clone(p, old, Color(0.75, 0.85, 1.0))
		_bounce_trace(old, spot, Color(0.85, 0.92, 1.0))
		p.position = Vector3(spot.x, map.height_at(spot), spot.z)
		p.facing = way
		p.visual.face(way)
	p.blinking = 0.55
	p.skill_guard(0.55)
	play_skill_sound(sk)
	p.play_attack(p.facing)
	label_over(p, "Asura Strike!!", Color(1.0, 0.95, 0.65))
	_asura_kanji(p.position, false)

	_own_timer(0.45, func():
		if not running or not hero_valid(p):
			return
		damage_tag = tag
		damage_by = by
		var center: = p.position
		_asura_blast(center, reach, dmg, sk, false)




		var echo: = float(p.effects.get("lg_asura_echo", 0.0))
		if echo > 0.0 and time >= float(p.get_meta("asura_echo_free", 0.0)):
			p.set_meta("asura_echo_free", time + GameData.ASURA_ECHO_DELAY)
			var ghost: = _asura_ghost(p, center)
			_own_timer(GameData.ASURA_ECHO_DELAY, func():
				if not running or not hero_valid(p):
					if ghost != null and is_instance_valid(ghost):
						ghost.queue_free()
					return
				_asura_echo(p, ghost, center, reach, dmg * echo, sk, tag, by)))



func _asura_kanji(at: Vector3, ghost: bool) -> void :

	if Vfx.hidden():
		return
	var holder: = Node3D.new()
	fx_root.add_child(holder)
	holder.global_position = at + RoVisual.world_lift()
	holder.rotation.y = RoVisual.view_yaw
	for i in 6:



		var pos: = Vector3((i - 2.5) * 3.4, 3.4, 0.0)
		for glow in [true, false]:
			var tex: = RoAssets.effect_tex(("asura_glow_%d" if glow else "asura_%d") % (i + 1))
			if tex == null:
				continue
			var s: = Sprite3D.new()
			s.texture = tex
			s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			s.shaded = false
			s.no_depth_test = true
			s.render_priority = 9 if glow else 10
			s.pixel_size = (4.9 if glow else 3.5) / 64.0
			s.modulate = Color(0.6, 0.8, 1.0, 0.0) if glow else Color(0.82, 0.88, 0.95, 0.0)
			if ghost:
				s.modulate = Color(0.55, 0.95, 1.0, 0.0) if glow else Color(0.7, 0.95, 1.0, 0.0)
			s.position = pos
			s.scale = Vector3.ONE * 1.8
			holder.add_child(s)
			var tw: = s.create_tween()
			tw.tween_interval(0.06 * i)
			tw.tween_property(s, "modulate:a", (0.75 if glow else 0.85) * (0.7 if ghost else 1.0), 0.08)
			tw.parallel().tween_property(s, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_interval(0.85 - 0.06 * i)
			tw.tween_property(s, "modulate:a", 0.0, 0.35)
	get_tree().create_timer(1.6, false).timeout.connect(holder.queue_free)





func _asura_blast(center: Vector3, reach: float, dmg: float, sk: Dictionary, ghost: bool) -> void :
	var tint: = Color(0.6, 0.95, 1.0) if ghost else Color(0.8, 0.9, 1.0)
	Vfx.burst(fx_root, center, reach, tint)
	Vfx.burst(fx_root, center, reach * 0.6, Color(1, 1, 1))
	Vfx.column(fx_root, center, Color(0.6, 0.9, 1.0) if ghost else Color(0.75, 0.85, 1.0))

	shake(0.9 if not ghost else 0.6)
	hud.flash(Color(0.85, 0.97, 1.0) if ghost else Color(0.9, 0.95, 1.0), 0.3 if ghost else 0.4)
	play_sound("fury", 0.0, -4.0)
	_rebuild_grid()
	var targets: = enemies_in_radius(center, reach)

	_asura_hits(targets, center, dmg, float(sk.knock), damage_tag, damage_by, 
		Skills.melee_element(damage_by, sk) if hero_valid(damage_by) else "neutral")


const ASURA_CHUNK: = 20


func _asura_hits(targets: Array, center: Vector3, dmg: float, knock: float, tag: String, by, el: = "neutral") -> void :
	var i: = 0
	while i < targets.size():
		if not running:
			return
		damage_tag = tag
		damage_by = by if hero_valid(by) else null
		for k in mini(ASURA_CHUNK, targets.size() - i):
			var e = targets[i + k]
			if e == null or not is_instance_valid(e) or e.dead:
				continue
			var to: Vector3 = (e.position - center) * Vector3(1, 0, 1)
			damage_enemy(e, dmg, to.normalized() * knock, "skill", el)
		i += ASURA_CHUNK
		if i < targets.size():
			await get_tree().process_frame




func _asura_ghost(p: Player, at: Vector3) -> Sprite3D:
	if p.visual == null or p.visual.sprite.texture == null:
		return null
	var c: Sprite3D = p.visual.sprite.duplicate(0)
	c.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	c.transparent = true
	c.no_depth_test = true
	c.modulate = Color(0.55, 0.9, 1.0, 0.0)
	fx_root.add_child(c)
	c.global_position = at + (p.visual.sprite.global_position - p.global_position)
	return c




func _asura_echo(p: Player, ghost: Sprite3D, center: Vector3, reach: float, dmg: float, sk: Dictionary, tag: String, by) -> void :
	if ghost != null and is_instance_valid(ghost):
		var tw: = ghost.create_tween()
		tw.tween_property(ghost, "modulate:a", 0.6 * Vfx.dim, 0.12)
		tw.tween_interval(0.55)
		tw.tween_property(ghost, "modulate:a", 0.0, 0.5)
		tw.tween_callback(ghost.queue_free)
	Vfx.column(fx_root, center, Color(0.6, 0.9, 1.0))
	play_skill_sound(sk)
	_asura_kanji(center, true)
	_own_timer(0.45, func():
		if not running:
			return
		damage_tag = tag
		damage_by = by if hero_valid(by) else null
		_asura_blast(center, reach, dmg, sk, true))


var _mvp_slow: = false


func _frenzy_time_scale() -> void :

	if _mvp_slow:
		return


	var playing: = running and not get_tree().paused

	var tower_ok: = tower == null or tower.fast_ok()
	var on: = frenzy and playing and tower_ok and not (raid != null and raid.active())\
	and not (morroc != null and morroc.active())
	_frenzy_scaled = on



	var fast: = game_fast and playing and tower_ok and not (raid != null and raid.active())\
	and not (morroc != null and morroc.active())
	fast_now = fast
	Vfx.fast_trim = 1 if fast else 0

	var want: = GameData.GAME_FAST_SPEED if fast else (GameData.FRENZY_SPEED if on else 1.0)


	if not is_equal_approx(want, _speed_applied):
		Engine.time_scale = want
		_speed_applied = want



static func game_ms() -> int:
	return int(_game_ms)





static func tower_speed() -> int:
	return clampi(int(Save.setting("tower_speed", 1)), 1, 3)


func set_tower_speed(s: int) -> void :

	if net.is_client() or (tower != null and running):
		return
	Save.set_setting("tower_speed", clampi(s, 1, 3))




func set_game_fast(on: bool) -> void :
	if net.is_client():
		return
	game_fast = on
	Save.set_setting("game_x2", on)




func _job_news() -> String:
	if player.forge_on():
		return tr("La barra naranja bajo tu vida es tu forja: tus golpes calientan el arma y al llenarse sube +1. Pasado el límite seguro puede romperse (el % es el riesgo).")
	return tr("Nuevas habilidades disponibles al subir de nivel")



func do_job_change(path: = 0) -> void :
	if net.is_client():

		net.send_job(path)
		player.job_change(path)
		hud.bind(self)
		hud.announce(tr("¡Ahora eres %s!") % player.job_name(), Color(1, 1, 0.3), _job_news())
		hud.flash(Color(1.0, 0.92, 0.5, 0.45))


		var c_options: = player.job_start_options()
		var c_passives: = player.job_passive_options()
		if c_options.size() + c_passives.size() >= 1 and not menus.auto_pick:
			var c_key: = "job_skill_" + str(player.job2.id)
			menus.show_start_skill(c_options, func(id: String):
				player.set_job_skill(id)
				Save.set_setting(c_key, id)
				net.send_job_skill(id)
				hud.bind(self)
				menus.close(), tr("Elige tu habilidad de %s") % player.job_name(), c_key, player.job_start_skill(), c_passives)
			return
		menus.close()
		return
	player.job_change(path)
	hud.bind(self)
	job_change_show(player)
	hud.announce(tr("¡Ahora eres %s!") % player.job_name(), Color(1, 1, 0.3), _job_news())

	var options: = player.job_start_options()
	var passives: = player.job_passive_options()
	if options.size() + passives.size() >= 1 and not menus.auto_pick:
		var key: = "job_skill_" + str(player.job2.id)
		menus.show_start_skill(options, func(id: String):
			player.set_job_skill(id)
			Save.set_setting(key, id)
			hud.bind(self)
			_after_opening_pick(Callable()), tr("Elige tu habilidad de %s") % player.job_name(), key, player.job_start_skill(), passives)
		return
	get_tree().paused = false
	menus.close()







func job_change_show(h: Player) -> void :
	var at: = h.position
	var gold: = Color(1.0, 0.88, 0.4)
	play_sound("job_levelup", 0.0, 0.0)
	play_sound("levelup", 0.0, -4.0)
	if spawn_fx("joblvup", at, 1.35, 1.0, h) == null:
		Vfx.column(fx_root, at, Color(1, 1, 0.7))
	spawn_fx("h_levelup", at, 1.1, 0.9, h)
	Vfx.magic_circle(fx_root, at, 3.2, Color(gold, 0.8), 2.4, "mvp_rune", 1.4, GameData.HERO_FX_PRIORITY - 2)
	Vfx.magic_circle(fx_root, at, 1.9, Color(1.0, 0.97, 0.75, 0.85), 2.4, "mvp_hexa", -2.6, GameData.HERO_FX_PRIORITY - 2)
	Vfx.column(fx_root, at, gold)
	Vfx.burst(fx_root, at, 4.5, Color(1, 0.95, 0.6))
	for i in 3:
		get_tree().create_timer(0.22 * (i + 1), false).timeout.connect( func():
			if is_instance_valid(h):
				Vfx.ring(fx_root, h.position, 2.2 + 1.6 * i, Color(gold, 0.9 - 0.2 * i), 0.55))
	get_tree().create_timer(0.35, false).timeout.connect( func():
		if is_instance_valid(h):
			spawn_fx("angelus", h.position, 0.8, 0.6, h))
	label_over(h, tr("¡%s!") % h.job_name(), gold)
	emote(h, "grats", 2.5)
	if h.visual != null:
		h.visual.flash()
		var base: = h.visual.scale
		var tw: = h.visual.create_tween()
		tw.tween_property(h.visual, "scale", base * 1.25, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(h.visual, "scale", base, 0.35).set_trans(Tween.TRANS_SINE)
	if h == player:
		hud.flash(Color(1.0, 0.92, 0.5, 0.45))
		shake(0.3)




func _after_opening_pick(then: Callable) -> void :
	hud.bind(self)
	if player.skills.has("call_homunculus") and player.homun_type == "":
		menus.show_start_skill(GameData.HOMUNCULI.keys(), func(id: String):
			player.homun_type = id
			Save.set_setting("homun_pick", id)
			spawn_homun()
			if then.is_valid():
				then.call(), tr("Elige tu Homúnculo"), "homun_pick", "homun_lif")
		return
	if then.is_valid():
		then.call()

	check_more_homun(player)




func level_choices() -> Array:
	if net.is_client():
		return net.offered
	return player.offered_choices()




func open_held_levels() -> void :

	if running and player != null and player.pending_levels <= 0:
		open_held_chests()
		return
	if not running or busy() or player.pending_levels <= 0 or level_choices().is_empty():
		return
	_absorb_flying_xp()
	menus.show_level_up(level_choices())



func _absorb_flying_xp() -> void :
	for i in range(pickups.size() - 1, -1, -1):
		var p: = pickups[i]
		if p.kind == "xp" and bool(p.get("pull", false)) and not p.has("hop_t"):
			_collect(p)
			(p.node as Node).queue_free()
			pickups.remove_at(i)


func choose(choice: Dictionary) -> void :
	if net.is_client():


		net.send_choice(net.offered.find(choice))
		net.offered = []
		if player.pending_levels > 1:


			net.chain_until = Time.get_ticks_msec() + NetSync.CHAIN_WAIT_MS
			player.pending_levels -= 1
			return
		player.pending_levels = 0
		menus.hide_level_up()
		get_tree().paused = false
		return
	player.offer = []
	player.apply_choice(choice, self)
	player.pending_levels -= 1

	if player.skills.has("call_homunculus") and player.homun_type == "" and not menus.auto_pick:
		menus.hide_level_up()
		menus.show_start_skill(GameData.HOMUNCULI.keys(), func(id: String):
			player.homun_type = id
			Save.set_setting("homun_pick", id)
			spawn_homun(), tr("Elige tu Homúnculo"), "homun_pick", "homun_lif")
		return
	if player.skills.has("call_homunculus") and player.homun_type == "":
		player.homun_type = str(Save.setting("homun_pick", "homun_lif"))
		spawn_homun()
	if player.pending_levels <= 0:

		menus.hide_level_up()
		get_tree().paused = false
		check_more_homun(player)
		return
	if player.pending_levels > 0:

		menus.show_level_up(level_choices(), true)
	else:
		menus.hide_level_up()
		get_tree().paused = false




func _auto_pick() -> void :
	var choices: = player.build_choices()
	if choices.is_empty():
		player.pending_levels = 0
		_training_auto = 0
		_auto_homun()
		return
	_training_auto = maxi(0, _training_auto - 1)
	var choice: = AutoPick.choose(choices, player.pick_order(), player.pick_limits(), player.pick_fill())
	player.apply_choice(choice, self)
	player.pending_levels -= 1
	_auto_pick_log(choice)

	for key in AutoPick.cap_bans(player, player.pick_limits(), player.pick_bans()):
		player.banishes -= 1
		player.banished.append(key)
		_auto_banish_label(key)


	player.offer = []
	var color: Color = GameData.CHOICE_RARITY[clampi(int(choice.get("rarity", 0)), 0, 3)].color
	_auto_pick_label("+ %s" % menus._choice_name(choice), color.lightened(0.35))
	play_sound("drop_green", 0.1, -10.0)


	_level_up_delay = 0.06 if training else 0.35
	_auto_homun()






func _auto_homun() -> void :
	if player.skills.has("call_homunculus") and player.homun_type == "":
		if menus.auto_pick:
			player.homun_type = str(Save.setting("homun_pick", "homun_lif"))
			spawn_homun()
		else:
			menus.show_start_skill(GameData.HOMUNCULI.keys(), func(id: String):
				player.homun_type = id
				Save.set_setting("homun_pick", id)
				spawn_homun(), tr("Elige tu Homúnculo"), "homun_pick", "homun_lif")
		return
	check_more_homun(player)



func auto_choose_client(choices: Array) -> void :
	var choice: = AutoPick.choose(choices, player.pick_order(), player.pick_limits(), player.pick_fill())
	if choice.is_empty():
		return
	var color: Color = GameData.CHOICE_RARITY[clampi(int(choice.get("rarity", 0)), 0, 3)].color
	_auto_pick_label("+ %s" % menus._choice_name(choice), color.lightened(0.35))
	play_sound("drop_green", 0.1, -10.0)
	net.send_choice(net.offered.find(choice))
	net.offered = []
	player.pending_levels = maxi(0, player.pending_levels - 1)
	_auto_pick_log(choice)



	var keys: = AutoPick.cap_bans(player, player.pick_limits(), player.pick_bans(), choice)
	if not keys.is_empty():
		net.send_auto_banish(keys)
		for key in keys:
			player.banishes -= 1
			player.banished.append(key)
			_auto_banish_label(key)



func _auto_pick_log(choice: Dictionary) -> void :
	if AutoPick.log_picks:
		print("AUTOPICK t=%.1f lv=%d pick=%s:%s Nv %s" % [time, player.level, str(choice.get("kind", "")), str(choice.get("id", "")), str(choice.get("level", ""))])




func _auto_banish_label(key: String) -> void :
	var id: = key.get_slice(":", 1)
	var shown: = id
	if key.begins_with("stat:") and GameData.STATS.has(id):
		shown = tr(str(GameData.STATS[id].name))
	elif GameData.SKILLS.has(id):
		shown = tr(str(GameData.SKILLS[id].name))
	_auto_pick_label(tr("Holy Water: %s") % shown, Color(0.6, 0.85, 1.0))
	play_sound("teleport", 0.0, -12.0)
	if AutoPick.log_picks:
		print("AUTOPICK t=%.1f banish=%s holy_water_left=%d" % [time, key, player.banishes])





func _auto_pick_label(text: String, color: Color) -> void :
	var up: = Vector3(0, cos(CAMERA_PITCH), - sin(CAMERA_PITCH))
	for c in player.get_children():
		if c.has_meta("auto_pick"):
			c.position += up * 0.5
	var l: = Label3D.new()
	l.set_meta("auto_pick", true)
	l.text = text
	l.font = UiKit.FONT_TITLE
	l.font_size = 34
	l.pixel_size = 0.014
	l.outline_size = 12
	l.outline_modulate = Color(0, 0, 0, 0.9)
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.render_priority = 20
	l.outline_render_priority = 19
	l.position = RoVisual.lift + up * (_sprite_height(player.visual) + 0.45)
	player.add_child(l)
	var tw: = l.create_tween()
	tw.tween_interval(1.3)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.parallel().tween_property(l, "outline_modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)





func feedback_context() -> Dictionary:
	var c: = {"version": str(Updater.version), "os": OS.get_name(), "lang": TranslationServer.get_locale(), 
		"screen": str(get_viewport().get_visible_rect().size), "fps": Engine.get_frames_per_second(), 
		"menu": menus.mode(), "running": running}


	c["machine"] = perf.machine()
	if running:
		c["perf"] = perf.report(self)
	if running and player != null:
		var skills: = {}
		for id in player.skills:
			skills[id] = int(player.skills[id].level)
		var gear: = {}
		for k in player.equipment.slots:
			if player.equipment.slots[k] != null:
				gear[k] = Equipment.item_name(player.equipment.slots[k])
		c.merge({"class": player.class_id, "job": str(player.job2.get("id", "")), "level": player.level, 
			"hp": "%d/%d" % [player.hp, player.max_hp], "stage": stage_id, "map": map.map_name if map != null else "", 
			"danger": danger, "time": roundi(time), "endless": endless, "speed": speed, "raid": raid.state, 
			"enemies": enemies.size(), "skills": skills, "gear": gear, "gods": altars.taken.duplicate()})
	return c




func _hell_setup() -> void :
	var h: = GameData.hell_level(danger)
	player.heal_mult = GameData.HELL_HEAL if h >= 2 else 1.0
	if h >= 3:
		altars.mods["elite"] = altars.mod("elite") + 1.0
	_hell_rain = GameData.HELL_RAIN_EVERY
	_hell_revenge_at = -9.0
	_hell_ring = GameData.HELL_RING_EVERY
	_hell_meteor = GameData.HELL_METEOR_EVERY
	_hell_herald = GameData.HELL_HERALD_EVERY * 0.6
	_hell_tide = GameData.HELL_TIDE_EVERY
	_hell_tide_t = 0.0
	_heralds = []
	_hell_rise_at = -9.0
	_storm = GameData.STORM_EVERY
	hell_late.reset()





var _hell_ring: = 0.0
var _hell_meteor: = 0.0
var _hell_herald: = 0.0
var _hell_tide: = 0.0
var _hell_tide_t: = 0.0
var _heralds: Array = []
var _hell_rise_at: = -9.0
func _tick_hell_late(delta: float) -> void :
	var h: = GameData.hell_level(danger)
	if h < 6 or raid.in_arena() or player == null:
		return
	_hell_ring -= delta
	if _hell_ring <= 0.0:
		_hell_ring = GameData.HELL_RING_EVERY * randf_range(0.9, 1.1) * hell_pace()
		_hell_ring_spawn()
	if h >= 7:
		_tick_heralds(delta)
	if h >= 8:
		_tick_tide(delta)
	if h >= 9:
		_hell_meteor -= delta
		if _hell_meteor <= 0.0:
			_hell_meteor = GameData.HELL_METEOR_EVERY * randf_range(0.85, 1.15) * hell_pace()
			_hell_meteor_fall()




func _hell_ring_spawn() -> void :
	var targets: = alive_heroes()
	if targets.is_empty():
		return
	var h: Player = targets.pick_random()
	var mobs: = _all_stage_mobs()
	if mobs.is_empty():
		return
	var mob: String = mobs.pick_random()
	var c: = h.position
	var n: = GameData.HELL_RING_COUNT
	var off: = randf() * TAU
	for i in n:
		var a: = off + TAU * i / n
		var at: = c + Vector3(cos(a), 0, sin(a)) * GameData.HELL_RING_RADIUS
		if map != null and not map.is_walkable(at):
			continue
		_own_timer(0.02 * i, func():
			if not running:
				return
			if i % 2 == 0:
				spawn_fx("hell_in", at, 0.55, 0.6)
			spawn_enemy(mob, at, true))
	Vfx.ring(fx_root, c + Vector3(0, 0.05, 0), GameData.HELL_RING_RADIUS, Color(0.6, 0.1, 0.15), 0.8)
	label_over(h, tr("¡Cerco de almas!"), Color(1.0, 0.3, 0.3))
	play_sound("warning", 0.2, -8.0)




func _tick_heralds(delta: float) -> void :
	_heralds = _heralds.filter( func(e): return is_instance_valid(e) and not e.dead)
	_hell_herald -= delta
	if _hell_herald <= 0.0:
		_hell_herald = GameData.HELL_HERALD_EVERY * randf_range(0.9, 1.1)
		_herald_spawn()
	for e in _heralds:
		var t: = float(e.get_meta("herald_fire")) - delta
		if t <= 0.0:
			t = GameData.HELL_HERALD_FIRE
			_hell_blast([e.position], GameData.HELL_HERALD_SIZE, 1.0, GameData.HELL_HERALD_PCT, "firepillar", Color(1, 0.2, 0.05), "meteor", "Heraldos de Surtr")
		e.set_meta("herald_fire", t)


func _herald_spawn() -> void :



	var mobs: = _mix_pool().filter( func(m): return not GameData.MONSTERS[m].get("elite", false))
	if mobs.is_empty():
		return
	var at: = _offscreen_point()
	if at == Vector3.INF:
		return
	var e: = spawn_enemy(mobs.pick_random(), at, true, true, "gigante")
	if e == null:
		return
	e.max_hp *= GameData.HELL_HERALD_HP
	e.hp = e.max_hp
	e.set_meta("herald", true)
	e.set_meta("herald_fire", GameData.HELL_HERALD_FIRE)
	Vfx.ground_glow(e, Vector3(0, 0.05, 0), e.radius * 4.5, Color(1.0, 0.3, 0.05, 0.85))
	_heralds.append(e)
	party_announce(tr("¡Un Heraldo de Surtr!"), Color(1.0, 0.45, 0.15), tr("Derrótalo: suelta un cofre y te cura"))
	play_sound("warning", 0.3, -6.0)




var meter_heal: = {}
func meter_heal_add(source: String, real: float, healer: Player, healed: Player) -> void :

	var rows: = meter_heal
	if healer != player:
		if healer == null or not is_instance_valid(healer) or heroes.size() < 2:
			return
		if not meter_heal_hero.has(healer.slot):
			meter_heal_hero[healer.slot] = {}
		rows = meter_heal_hero[healer.slot]
	var tag: = source if source != "" else ("self" if healed == healer else "other")
	var m: Dictionary = rows.get(tag, {"dmg": 0.0, "hits": 0})
	m.dmg = float(m.dmg) + real
	m.hits = int(m.hits) + 1
	rows[tag] = m



func _herald_down(e: Enemy) -> void :
	Save.bump("heralds")
	_drop_chest(e.position, 2, GameData.HELL_HERALD_CHEST)
	spawn_fx("firepillar", e.position, 1.4, 1.0)
	Vfx.ring(fx_root, e.position + Vector3(0, 0.05, 0), 3.0, Color(1.0, 0.6, 0.2), 0.5)
	for h in alive_heroes():
		h.heal(h.max_hp * GameData.HELL_HERALD_HEAL, self)
		spawn_fx("holyhit", h.position, 0.9, 0.8, h)
	party_announce(tr("¡Heraldo derrotado!"), Color(1.0, 0.8, 0.35), tr("Cofre y curación"))
	play_sound("levelup", 0.0, -6.0)




func _tick_tide(delta: float) -> void :
	if _hell_tide_t > 0.0:
		_hell_tide_t -= delta
		if _hell_tide_t <= 0.0 and alive_heroes().size() > 0:
			var at: = map.find_point_around(player.position, 1.5, 3.0)
			_drop_chest(at if at != Vector3.INF else player.position, 2, 1)
			party_announce(tr("¡Marea superada!"), Color(1.0, 0.8, 0.35), tr("Un cofre apareció a tu lado"))
			play_sound("levelup", 0.0, -6.0)
		return
	_hell_tide -= delta
	if _hell_tide <= 0.0:
		_hell_tide = GameData.HELL_TIDE_EVERY * randf_range(0.9, 1.1)
		_hell_tide_t = GameData.HELL_TIDE_TIME
		party_announce(tr("¡Marea infernal!"), Color(0.95, 0.2, 0.2), tr("Aguanta %d segundos") % roundi(GameData.HELL_TIDE_TIME))
		play_sound("warning", 0.3, -4.0)
		shake(0.2)


func hell_tide_on() -> bool:
	return _hell_tide_t > 0.0




func _hell_meteor_fall() -> void :
	var targets: = alive_heroes()
	if targets.is_empty():
		return
	var h: Player = targets.pick_random()
	var dir: = Vector3(1, 0, 0).rotated(Vector3.UP, randf() * TAU)
	var side: = Vector3( - dir.z, 0, dir.x)
	var length: = 22.0
	var w: = GameData.HELL_METEOR_WIDTH
	play_sound("warning", 0.3, -8.0)
	for i in GameData.HELL_METEOR_LINES:
		var offset: = (i - (GameData.HELL_METEOR_LINES - 1) * 0.5) * w * 2.2

		var d: = dir.rotated(Vector3.UP, (i - 1) * 0.35)
		var from: = h.position + side * offset - d * length * 0.5
		Vfx.telegraph_line(fx_root, from, d, length, w, GameData.HELL_METEOR_CAST)
		get_tree().create_timer(GameData.HELL_METEOR_CAST, false).timeout.connect( func():
			if not running:
				return
			Vfx.strike_line(fx_root, from, d, length, w, Color(1.0, 0.45, 0.1))
			for k in 5:
				spawn_fx("meteor1", from + d * length * (0.1 + 0.2 * k), 0.6, 0.6)
			play_sound("meteor", 0.2, -8.0)
			shake(0.15)
			for hero in heroes:
				if hero.downed:
					continue
				var rel: = (hero.position - from) * Vector3(1, 0, 1)
				var along: = rel.dot(d)
				if along >= 0.0 and along <= length and absf(rel.dot(Vector3( - d.z, 0, d.x))) < w * 0.5:
					hurt_what = "Meteoros errantes"
					hero.hell_hazard(self, GameData.HELL_METEOR_PCT))




func _hell_rise(e: Enemy) -> void :
	if e.has_meta("herald"):
		_herald_down(e)
	if e.has_meta("risen"):
		Save.bump("risen_kills")
		return
	if GameData.hell_level(danger) < 10 or e.is_boss or e.summoned or e.prop != "" or raid.in_arena()\
	or time - _hell_rise_at < GameData.HELL_RISE_GAP or randf() >= GameData.HELL_RISE_CHANCE:
		return
	_hell_rise_at = time
	var id: = e.id
	var at: = e.position
	spawn_fx("hell_in", at, 0.6, 0.7)
	_own_timer(1.0, func():
		if not running:
			return
		var r: = spawn_enemy(id, at, true)
		if r == null:
			return
		r.set_meta("risen", true)
		r.max_hp *= GameData.HELL_RISE_HP
		r.hp = r.max_hp
		r.speed *= GameData.HELL_RISE_SPEED

		if r.visual is RoVisual:
			(r.visual as RoVisual).sprite.modulate = Color(0.55, 0.4, 0.75)
		Vfx.ground_glow(r, Vector3(0, 0.04, 0), r.radius * 3.0, Color(0.55, 0.2, 0.85, 0.8))
		spawn_fx("devil", at, 0.8, 0.7))




func _hell_rain_fall() -> void :
	var spots: Array[Vector3] = [player.position]
	for i in GameData.HELL_RAIN_COUNT - 1:
		var p: = map.find_point_around(player.position, 2.5, 7.0)
		if p != Vector3.INF:
			spots.append(p)
	play_sound("warning", 0.5, -10.0)
	_hell_blast(spots, GameData.HELL_RAIN_SIZE, GameData.HELL_RAIN_CAST, GameData.HELL_RAIN_PCT, "firepillar", Color(1, 0.2, 0.05), "meteor", "Lluvia infernal")




func _storm_strike() -> void :
	play_sound("thunder", 0.5, -8.0)
	for i in GameData.STORM_BOLTS:
		get_tree().create_timer(GameData.STORM_GAP * i, false).timeout.connect( func():
			var h: Player = player if heroes.size() <= 1 else (alive_heroes().pick_random() if not alive_heroes().is_empty() else null)
			if running and h != null and not raid.in_arena():
				_hell_blast([h.position], GameData.STORM_SIZE, GameData.STORM_CAST, GameData.STORM_PCT, 
					"lightning", Color(1.0, 0.92, 0.3), "lightbolt", "Tormenta", false))






func _hell_blast(spots: Array, size: float, cast: float, pct: float, fx: String, tint: = Color(1, 0.2, 0.05), sound: = "meteor", what: = "", hazard: = true) -> void :
	var marks: Array = []
	for at in spots:
		var spot: = Vector3(at.x, map.height_at(at) + 0.06, at.z)
		var mark: = Vfx._flat(fx_root, Vfx.disc_texture(), spot, size, Color(tint, 0.0))
		Vfx.danger(mark)
		mark.create_tween().tween_property(mark, "modulate:a", 0.45, cast)
		marks.append([mark, spot])
	get_tree().create_timer(cast, false).timeout.connect( func():
		if not running:
			return
		var hit: Array[Player] = []
		for m in marks:
			if is_instance_valid(m[0]):
				m[0].queue_free()
			spawn_fx(fx, m[1], 1.2, 0.8)
			for h in heroes:
				if not h.downed and not hit.has(h) and _flat_dist(h.position, m[1]) < size:
					hit.append(h)
		play_sound(sound, 0.2, -6.0)
		for h in hit:
			hurt_what = what
			if hazard:
				h.hell_hazard(self, pct)
			else:
				h.take_damage(h.max_hp * pct, self, null, true))



func hex_player(_from: Enemy, hero: Player = null) -> void :
	var h: = hero if hero != null else player
	if h == null or h.hp <= 0.0:
		return

	var id: String = GameData.HEXES.keys().filter( func(k): return not GameData.HEXES[k].get("oath", false)).pick_random()
	var fresh: = not h.powers.has(id)
	h.add_power(id)
	if fresh:
		label_over(h, tr(str(GameData.HEXES[id].name)), Color(0.8, 0.55, 1.0))
		spawn_fx("devil", h.position, 1.0, 0.8, h)
		play_sound("warning", 0.3, -12.0)




func _tick_runner(delta: float) -> void :
	if runner != null and ( not is_instance_valid(runner) or runner.dead):
		runner = null
	if runner != null:
		runner.runner_life -= delta
		if runner.runner_life <= 0.0:

			number(runner.position + Vector3(0, 2.2, 0), tr("¡Se escapó!"), Color(1.0, 0.82, 0.3), true)
			banish_enemy(runner)
			runner = null
		return
	if raid.in_arena() or boss != null:
		return
	_runner_timer -= delta
	if _runner_timer <= 0.0:
		_runner_timer = float(GameData.RUNNER.check)
		if randf() < float(GameData.RUNNER.chance):
			spawn_runner()




func spawn_runner() -> void :
	var r: Dictionary = GameData.RUNNER

	var at: = map.find_point_around(player.position, 5.0, 7.0)
	var e: = spawn_enemy(str(r.mob), at, true, false, "runner")
	if e == null:
		return
	e.make_runner(float(r.life))

	var dps: = tank_dps(boss_measure(float(meter_stats.get("total", 0.0))) / maxf(20.0, measure_time())) * 1.5
	e.max_hp = maxf(float(r.min_hp) * GameData.danger_hp(danger), dps * float(r.tank))
	e.hp = e.max_hp
	e.speed = player.move_speed * float(r.speed)
	runner = e
	hud.alerts.warn(tr("¡Un Poring Dorado con tesoro! Golpéalo antes de que escape"), r.color, "party_alarm")




func _runner_hit(e: Enemy, amount: float) -> void :
	var r: Dictionary = GameData.RUNNER
	e.runner_calm = false
	e.runner_dmg += amount
	var step: = e.max_hp * float(r.drop_share)
	var drops: = 0
	while e.runner_dmg >= step and drops < 4:
		e.runner_dmg -= step
		drops += 1
		_runner_coins(e.position, roundi(float(r.zeny) * GameData.danger_reward(danger)))
		if randf() < float(r.box):
			_drop_chest(map.random_point_around(e.position, 1.2), 1, -1)

	if drops > 0:
		play_sound("coin%d" % randi_range(1, 3), 0.05, -6.0)
	else:
		play_sound("coin%d" % randi_range(1, 3), 0.07, -11.0)





func _fight_card(e: Enemy) -> void :
	if training or e.summoned or not GameData.RAIDS.has(e.id) or randf() >= GameData.MVP_FIGHT_CARD_CHANCE:
		return
	var cards: = []
	for ab in GameData.RAIDS[e.id].get("abilities", []):
		var mobs: = []
		for key in ["mob", "egg", "hatch"]:
			var v = ab.get(key, "")
			if v is Array:
				mobs.append_array(v)
			elif str(v) != "":
				mobs.append(str(v))
		for m in mobs:
			var card: = str(GameData.MONSTERS.get(str(m), {}).get("card", ""))
			if card != "" and GameData.CARDS.has(card) and not _wild_mob(str(m)) and not cards.has(card):
				cards.append(card)
	if cards.is_empty():
		return
	var missing: = cards.filter( func(c): return not Save.has_card(c))
	var card: String = (missing if not missing.is_empty() else cards).pick_random()
	Save.set_card_misses(card, 0)
	_drop_item(e.position + Vector3(-0.6, 0, 0), "card", card)



func drop_zeny(at: Vector3, value: int) -> void :
	_runner_coins(at, value)

	pickups.back()["spat"] = true


func _runner_coins(at: Vector3, value: int) -> void :
	var s: = _zeny_sprite(value)
	var p: = {"node": s, "kind": "loot", "value": value, "pull": false, "spr": "zeny"}
	pickups.append(p)
	_pop(p, at + Vector3(0, 0.3, 0), map.random_point_around(at, 1.4) + Vector3(0, 0.25, 0), 1.2)






const CHIME_GAP: = 0.055
const CHIME_GAP_FAST: = 0.032
const CHIME_RESET: = 0.9
const CHIME_QUEUE_MAX: = 28
const CHIME_FINALE: = 8
var _chime_queue: = 0
var _chime_step: = 0
var _chime_run: = 0
var _chime_next: = 0.0
var _chime_idle: = 0.0


func _zeny_chime(_z: int) -> void :
	_chime_queue = mini(_chime_queue + 1, CHIME_QUEUE_MAX)
	_chime_idle = 0.0


func _tick_chime(delta: float) -> void :
	_chime_next -= delta
	if _chime_queue <= 0:
		_chime_idle += delta
		if _chime_idle >= CHIME_RESET and _chime_run > 0:
			_chime_step = 0
			_chime_run = 0
		return
	if _chime_next > 0.0:
		return
	_chime_queue -= 1
	_chime_next = CHIME_GAP_FAST if _chime_queue > 4 else CHIME_GAP


	_chime_step += 1
	_chime_run += 1
	play_sound("get_coin", 0.0, -14.0, randf_range(1.12, 1.28), false)
	if _chime_queue == 0 and _chime_run >= CHIME_FINALE:

		_own_timer(0.07, func(): play_sound("get_coin", 0.0, -3.0, 1.0))




static func zeny_ting_stream() -> AudioStreamWAV:
	var rate: = 22050
	var length: = int(rate * 0.24)
	var data: = PackedByteArray()
	data.resize(length * 2)
	var f: = 1318.5
	for i in length:
		var t: = float(i) / rate
		var v: = 0.0
		for strike in [[0.0, 1.0], [0.028, 0.45]]:
			var ts: = t - float(strike[0])
			if ts < 0.0:
				continue
			var env: = minf(1.0, ts / 0.0015)
			v += float(strike[1]) * env * (sin(TAU * f * ts) * exp( - ts / 0.07)
				+ 0.5 * sin(TAU * f * 2.76 * ts) * exp( - ts / 0.035)
				+ 0.25 * sin(TAU * f * 5.4 * ts) * exp( - ts / 0.018))
		var tail: = clampf((length - i) / (rate * 0.02), 0.0, 1.0)
		data.encode_s16(i * 2, int(clampf(v * tail * 0.32, -1.0, 1.0) * 32767.0))
	var w: = AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = data
	return w





static var _coin_anim: AnimatedTexture
func _zeny_sprite(value: int) -> Node3D:
	if _coin_anim == null:
		_coin_anim = AnimatedTexture.new()
		var spr: = RoAssets.sprite(["fx_coin"])
		var n: = spr.frame_count(0) if spr != null else 0
		_coin_anim.frames = maxi(1, n)
		for i in n:
			_coin_anim.set_frame_texture(i, spr.get_frame(0, i))
			_coin_anim.set_frame_duration(i, 0.09)
		if n == 0:
			_coin_anim.set_frame_texture(0, RoAssets.radial(Color(1, 0.85, 0.3), 16))
	var s: = Node3D.new()
	s.set_meta("zeny", true)
	run_root.add_child(s)
	gem_renderer.add_coin(s, _coin_anim, [GameData.PIXEL_SIZE * 1.5, GameData.PIXEL_SIZE * 1.8], value >= 100)
	return s



func continue_endless() -> void :
	raid.leave()
	endless = true
	_endless_start = time
	_endless_next = time + GameData.ENDLESS_EVERY * 0.5
	_endless_upcoming = _endless_pick()
	_warm_mob(str(_endless_upcoming.get("mob", "")))
	party_announce(tr("Modo infinito"), Color(1, 0.7, 0.3), tr("Las oleadas no terminan: ¿hasta dónde llegas?"))
	get_tree().paused = false
	menus.close()

	if not bool(Save.setting("endless_auto_hint", false)):
		Save.set_setting("endless_auto_hint", true)
		get_tree().create_timer(3.4, false).timeout.connect( func():
			if running and endless:
				hud.alerts.warn(tr("Consejo: al subir de nivel marca «Elegir al azar» y las mejoras se eligen solas"), 
					Color(1.0, 0.85, 0.45), "party_alarm"))


func _on_player_died(hero: Player) -> void :

	if world_boss != null and is_instance_valid(world_boss) and heroes.size() <= 1:
		world_boss.hero_fell()
		return


	if heroes.size() > 1:
		hero.downed = true
		hero.revive_t = 0.0
		label_over(hero, tr("¡Caído!"), Color(1.0, 0.4, 0.35))


		var humans: = alive_heroes().filter( func(h): return not (h.input is HeroInput.BotHero))
		if hero == player and humans.is_empty() and not autopilot and net.mode != "":
			pass
		elif not alive_heroes().is_empty():
			if hero == player:
				hud.announce(tr("¡Caíste!"), Color(1.0, 0.4, 0.35), tr("Un aliado te levanta quedándose a tu lado unos segundos"))
			return

	var won: = endless
	get_tree().create_timer(1.2, false).timeout.connect( func(): _end_run(won))
	running = false


func _end_run(victory: bool) -> void :
	if net.is_host():
		net.send_end(victory)
	_stop_song()
	running = false

	karma._look()
	morroc.reset()
	stagger.clear()
	quest.end_run()

	if not bool(Save.setting("town_visited", false)):
		Save.set_setting("town_hint", true)
	if not is_coop():
		RunSave.clear()


	var keep: Array = []
	for k in player.equipment.slots if not training else []:
		var eit = player.equipment.slots[k]
		if eit != null and not Equipment.is_perm(eit) and not eit.get("lent", false):


			var worn: Dictionary = eit.duplicate(true)
			worn["_worn"] = true

			worn["_slot"] = str(k)
			keep.append(worn)
	for bit in player.equipment.bag if not training else []:
		if not Equipment.is_perm(bit) and not bit.get("lent", false):
			keep.append(bit.duplicate(true))


	for ore in ["oridecon", "elunium"] if not training else []:
		var n: = int(player.equipment.ores_found.get(ore, 0))
		if n > 0:
			Save.add_material(ore, n)
			run_materials[ore] = int(run_materials.get(ore, 0)) + n

	var sold: = 0
	var sold_zeny: = 0
	for i in range(player.equipment.bag.size() - 1, -1, -1):
		if Equipment.is_perm(player.equipment.bag[i]):
			continue


		var bit_i: Dictionary = player.equipment.bag[i]
		sold_zeny += player.equipment.sell_from_bag(i, Equipment.legend_coins(bit_i) == 0 or bit_i.get("lent", false) or training)
		sold += 1

	var sold_cards: = player.equipment.card_bag.size()
	var cards_zeny: = sold_cards * GameData.CARD_SELL_ZENY
	player.equipment.card_bag.clear()
	sold_zeny += cards_zeny
	if sold_zeny > 0:
		add_zeny(sold_zeny, "end")

	if Save.daily_bonus_ready() and run_zeny > 0:
		Save.set_setting("daily_run", Time.get_date_string_from_system())
		add_zeny(roundi(run_zeny * GameData.DAILY_FIRST_BONUS), "daily")
	var best: = _bank_run(victory)
	if not autopilot:



		if not player.tampered and not training and not player.stats_plausible():
			player.tampered = true
			push_warning("run marked: attributes past what level %d gives" % player.level)

		if player.tampered:
			pass
		elif not is_coop() and tower == null:
			board.submit(player.class_id, stage_id, time, run_zeny, danger, run_mvps, player.record_look(), frenzy, oath_points())
		elif tower != null and tower.best > 0 and tower.hel != null:

			board.submit_hel(player.class_id, tower.best, time, oath_points(), player.record_look(), is_coop())
		elif tower != null and tower.best > 0:


			board.submit_tower(player.class_id, tower.best, time, player.record_look(), is_coop())
		board.log_run(self, victory)

	var won_titles: Array = titles.after_run(self, victory) if not autopilot and not training else []
	menus.show_end(victory, {"time": time, "kills": kills, "level": player.level, 
		"class": player.job_name(), "best": best, "cards": player.cards, "zeny": run_zeny, 
		"sold": sold, "sold_zeny": sold_zeny - cards_zeny, "sold_cards": sold_cards, "cards_zeny": cards_zeny, 
		"ymir": run_ymir, "zeny_from": zeny_from.duplicate(), "keep": keep, "keep_free": victory or run_ymir > 0, 
		"materials": run_materials.duplicate(), "achievements": Achievements.check(), "titles": won_titles, "gods": altars.taken.duplicate(), 
		"record": {"score": Leaderboard.score(time, run_zeny, run_mvps, danger + oath_points()), "mvps": run_mvps, "oath": oath_points(), "online": Leaderboard.enabled() and not autopilot}
			if tower == null else {"floor": tower.best, "online": Leaderboard.enabled() and not autopilot and tower.best > 0}})
	if _smoke_seconds > 0.0:
		_finish_smoke()


func _ensure_bus(bus_name: String) -> void :
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var idx: = AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")



func apply_audio_settings() -> void :
	fx_alpha_run = clampf(float(Save.setting("fx_alpha", 1.0)), 0.0, 1.0)
	Vfx.quality = clampi(int(Save.setting("fx_quality", 0)), 0, 3)
	fx_alpha_boss = clampf(float(Save.setting("fx_alpha_boss", fx_alpha_run)), 0.0, 1.0)


	if Vfx.quality >= 3:
		fx_alpha_run = 0.0
		fx_alpha_boss = 0.0
	fx_alpha_party = clampf(float(Save.setting("fx_alpha_party", 1.0)), 0.0, 1.0)
	for pair in [["Master", "master", 1.0], ["Music", "music", 0.8], ["SFX", "sfx", 0.8]]:
		var idx: = AudioServer.get_bus_index(pair[0])
		var v: = clampf(float(Save.setting(pair[1], pair[2])), 0.0, 1.0)

		var muted: bool = v <= 0.001 or (pair[0] == "Master" and _unfocused and bool(Save.setting("mute_unfocused", false)))
		AudioServer.set_bus_mute(idx, muted)
		AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.001)))


var _unfocused: = false
var _fps_label: Label






const UI_SIZE_TOUCH_MAX: = 1.5





const QUALITY_3D: = [0.6, 0.75, 1.0]
static func quality_level() -> int:
	return clampi(int(Save.setting("quality", 1 if MouseWalk.touch() else 2)), 0, QUALITY_3D.size() - 1)






static func fsr_available() -> bool:
	return RenderingServer.get_current_rendering_method() == "forward_plus"




static func fsr_on() -> bool:
	return fsr_available() and bool(Save.setting("fsr", true)) and quality_level() < QUALITY_3D.size() - 1





const PERF_MODE: = {"quality": 0, "fx_quality": 2, "damage_numbers": "reduced", "fx_alpha_party": 0.3, "mob_shadows": false}




func perf_values() -> Dictionary:
	var saved: Dictionary = Save.data.settings
	var nums = saved.get("damage_numbers", true)
	return {"quality": clampi(int(saved.get("quality", 1 if MouseWalk.touch() else 2)), 0, QUALITY_3D.size() - 1), 
		"fx_quality": clampi(int(saved.get("fx_quality", 0)), 0, 3), 
		"damage_numbers": (("all" if nums else "none") if nums is bool else str(nums)), 
		"fx_alpha_party": clampf(float(saved.get("fx_alpha_party", 1.0)), 0.0, 1.0), 
		"mob_shadows": bool(saved.get("mob_shadows", true))}


func set_perf_mode(on: bool) -> void :
	if on == bool(Save.setting("perf_mode", false)):
		return
	if on:
		Save.set_setting("perf_prev", perf_values())
		for k in PERF_MODE:
			Save.set_setting(k, PERF_MODE[k])
	else:
		var prev = Save.setting("perf_prev", {})
		if prev is Dictionary:
			for k in PERF_MODE:
				if (prev as Dictionary).has(k):
					Save.set_setting(k, prev[k])
		Save.set_setting("perf_prev", {})
	Save.set_setting("perf_mode", on)
	apply_video_settings()
	apply_audio_settings()


var _video_applied: = false
func apply_video_settings() -> void :
	if DisplayServer.get_name() == "headless":
		return



	if OS.has_feature("web") and not _video_applied and bool(Save.setting("fullscreen", false)):
		Save.set_setting("fullscreen", false)
	_video_applied = true
	var full: = bool(Save.setting("fullscreen", false))
	var mode: = DisplayServer.window_get_mode()
	var is_full: = mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if full != is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(Save.setting("vsync", true)) else DisplayServer.VSYNC_DISABLED)
	_apply_max_fps()
	_apply_window_size(full)





	var win: = get_window()
	var base: = float(win.get_meta("ui_base", 1.0))
	var k: = base * clampf(float(Save.setting("ui_size", 1.0)), 0.7, UI_SIZE_TOUCH_MAX if MouseWalk.touch() else 1.0)
	if not is_equal_approx(win.content_scale_factor, k):
		win.content_scale_factor = k
	RoAssets.refresh_ui_scale()


	get_viewport().msaa_3d = Viewport.MSAA_DISABLED

	get_viewport().scaling_3d_scale = QUALITY_3D[quality_level()]




	get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if fsr_on() else Viewport.SCALING_3D_MODE_BILINEAR
	if web != null:
		web.call("apply_quality")
	_show_fps(bool(Save.setting("show_fps", false)))





var _window_size_shown: = ""
func _apply_window_size(full: bool) -> void :
	var want: = str(Save.setting("window_size", "auto"))
	if full or want == "auto" or want == _window_size_shown:
		if full:
			_window_size_shown = ""
		return
	var parts: = want.split("x")
	if parts.size() != 2:
		return
	var screen: = DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen()).size
	var size: = Vector2i(mini(int(parts[0]), screen.x), mini(int(parts[1]), screen.y))
	var win: = get_window()
	win.size = size
	win.move_to_center()
	_window_size_shown = want



static func window_sizes() -> Array:
	var screen: = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	var out: = []
	for s in [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]:
		if s.x <= screen.x and s.y <= screen.y:
			out.append("%dx%d" % [s.x, s.y])
	return out



func toggle_fullscreen() -> void :
	Save.set_setting("fullscreen", not bool(Save.setting("fullscreen", false)))
	apply_video_settings()



func _show_fps(on: bool) -> void :
	if not on:
		if _fps_label != null:
			_fps_label.get_parent().queue_free()
			_fps_label = null
		return
	if _fps_label != null:
		return
	var layer: = CanvasLayer.new()
	layer.layer = 120
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_fps_label = Label.new()
	_fps_label.add_theme_font_size_override("font_size", 13)
	_fps_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.6))
	_fps_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_fps_label.add_theme_constant_override("outline_size", 4)
	_fps_label.anchor_left = 1.0
	_fps_label.anchor_right = 1.0
	_fps_label.offset_left = -90
	_fps_label.offset_right = -8
	_fps_label.offset_top = 2
	_fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fps_label)
	var t: = Timer.new()
	t.wait_time = 0.5
	t.autostart = true
	t.timeout.connect( func():
		if _fps_label != null:
			_fps_label.text = "%d FPS" % Engine.get_frames_per_second())
	layer.add_child(t)
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()



func play_music(track: String, force: = false) -> void :



	var m: = str(stage.map)
	if tower != null and is_instance_valid(tower):
		m = tower.music_map()
	_play_music_stream(track, m, force)



func play_music_map(map_name: String) -> void :
	_play_music_stream("map", map_name, false)


func _play_music_stream(track: String, map_name: String, force: bool) -> void :
	var key: = track if track == "login" else "map:" + map_name
	if key == _music_track and not force:
		return
	_music_track = key

	if web != null and track != "login" and web.get("packs") != null and not web.packs.ready_now("bgm:" + map_name):
		_web_music(map_name, key)
		return
	var stream: = RoAssets.music(track, map_name)
	if _music_tween != null:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if _music.playing:
		_music_tween.tween_property(_music, "volume_db", -40.0, 0.6)
	_music_tween.tween_callback( func():
		_music.stop()
		_music.stream = stream
		if stream != null:
			_music.volume_db = -40.0
			_music.play())
	_music_tween.tween_property(_music, "volume_db", MUSIC_DB, 0.8)


func _web_music(map_name: String, key: String) -> void :
	if await web.packs.ensure(["bgm:" + map_name]) and _music_track == key:
		_music_track = ""
		_play_music_stream("map", map_name, false)




func _bank_run(victory: bool) -> Dictionary:

	if training and player != null:
		_stats_banked = true
		return Save.best(player.class_id)
	if _stats_banked or player == null:
		return Save.best(player.class_id if player != null else "")
	_stats_banked = true
	Save.add_kills(kills)

	if is_coop():
		Save.bump("coop_runs")

	if run_mvps > 0:
		Save.bump("mvp_kills", run_mvps)
		Save.stat_max("hell_mvp", GameData.hell_level(danger))
	_track_achievements()
	var before: = int(Save.class_progress(player.class_id).level)
	var ups: = Save.add_class_xp(player.class_id, roundi(player.xp_gained * GameData.danger_class_xp(danger) * (1.0 + GameData.FEATURED_BONUS if featured else 1.0)))
	var res: = Save.record(player.class_id, time, victory)
	res["class_xp"] = roundi(player.xp_gained)
	res["class_id"] = player.class_id
	res["class_level"] = before + ups
	res["class_ups"] = ups
	return res



func _track_achievements() -> void :
	if training:
		return
	Save.stat_max("run_level", player.level)
	Save.stat_max("best_hit", float(meter_stats.get("best", 0.0)))
	Save.stat_max("best_dps", float(meter_stats.get("total", 0.0)) / maxf(30.0, measure_time()))


	if endless:
		Save.stat_max("endless_best", time)
	var top: = 0
	for id in player.stats:
		top = maxi(top, int(player.stats[id]))
	Save.stat_max("best_stat", top)
	var refine: = 0
	for k in player.equipment.slots:
		var it = player.equipment.slots[k]
		if it != null:
			refine = maxi(refine, int(it.get("refine", 0)))
	Save.stat_max("best_refine", refine)
	if player.equipment.legend_found > 0:
		Save.bump("legendaries", player.equipment.legend_found)
	for id in player.skills:
		if GameData.SKILLS[id].get("evolved", false):
			Save.mark_seen("evos", id)
	if not player.job2.is_empty():
		Save.mark_seen("jobs", str(player.job2.get("id", player.job2.get("name", ""))))
	Save.mark_seen("classes", player.class_id)



func abandon_run() -> void :
	if net.is_host() and running:


		if not net.hand_off():
			net.send_end(false)
	if net.is_client():


		net.leave_run()
		return
	if running:

		if not autopilot:
			board.log_run(self, false)
		_bank_run(false)
	running = false
	if not is_coop():
		RunSave.clear()



var _update_looked: = 0

const UPDATE_RELOOK_MS: = 10 * 60 * 1000


func _recheck_update() -> void :
	if not OS.has_feature("android") or Time.get_ticks_msec() - _update_looked < UPDATE_RELOOK_MS:
		return

	var up: Node = get_node_or_null("/root/Updater")
	if up == null or running or net.mode != "" or up.get("_win") != null or not up.has_method("_ready"):
		return
	_update_looked = Time.get_ticks_msec()
	print("Updater: back in the app, looking for an update again")
	up.call("_ready")




const UNFOCUSED_FPS: = 30


func _apply_max_fps() -> void :
	var cap: = int(Save.setting("max_fps", 0))



	if cap == 0 and not bool(Save.setting("vsync", true)) and "--bench" not in OS.get_cmdline_user_args():
		cap = maxi(144, roundi(DisplayServer.screen_get_refresh_rate()) * 2)

	var bg: = int(Save.setting("unfocused_fps", UNFOCUSED_FPS))



	if bg > 0 and net != null and net.mode != "":
		bg = maxi(bg, UNFOCUSED_FPS)
	if _unfocused and bg > 0 and "--bench" not in OS.get_cmdline_user_args():
		cap = bg if cap == 0 else mini(cap, bg)
	Engine.max_fps = cap


func _notification(what: int) -> void :


	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		for down in [true, false]:
			var ev: = InputEventKey.new()
			ev.keycode = KEY_ESCAPE
			ev.physical_keycode = KEY_ESCAPE
			ev.pressed = down
			Input.parse_input_event(ev)
	if what == NOTIFICATION_APPLICATION_PAUSED:
		if running and not training and not get_tree().paused:
			for down in [true, false]:
				var ev: = InputEventKey.new()
				ev.keycode = KEY_ESCAPE
				ev.physical_keycode = KEY_ESCAPE
				ev.pressed = down
				Input.parse_input_event(ev)
		Save.flush()


	if what == NOTIFICATION_APPLICATION_RESUMED:
		_recheck_update()

	if what == NOTIFICATION_APPLICATION_PAUSED and cloud != null and cloud.linked() and not running:
		cloud.sync_now(false)



	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_EXIT_TREE:

		BOOT_GUARD.safe()
		if not is_equal_approx(_speed_applied, 1.0):
			Engine.time_scale = 1.0
			_speed_applied = 1.0
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_unfocused = what == NOTIFICATION_APPLICATION_FOCUS_OUT
		apply_audio_settings()
		_apply_max_fps()
	if what == NOTIFICATION_WM_CLOSE_REQUEST and running and not training:


		if not RunSave.save(self):
			_bank_run(false)
		Save.flush()



static func web_keys(maps: Array) -> Array:
	var out: = []
	for m in maps:
		if str(m) != "":
			out.append("map:" + str(m))
			out.append("bgm:" + str(m))
	return out




func web_ahead() -> Array:
	return web_keys([Town.MAP, str(stage.map)])




func web_own_late() -> Array:
	for id in Save.owned_cosmetics():
		if str(GameData.COSMETICS[id].get("slot", "")) == "back":
			return ["late:robes"]
	return []




func web_prefetch_run() -> void :
	if web == null or web.get("packs") == null:
		return
	var maps: = []
	if tower != null and is_instance_valid(tower):


		maps = [TowerRun.map_of(tower.floor + 5)]
	elif raid != null and raid.data is Dictionary:
		maps = [str(raid.data.get("arena", ""))]
	web.packs.prefetch(web_keys(maps))




var web: Node
func web_keep_run() -> void :
	if running and not training:
		RunSave.save(self)



func event_index() -> int:
	return _event_index


func endless_state() -> Array:
	return [_endless_next, _endless_count]



func restore_clock(t: float, kill_count: int, zeny: int, ev_index: int, is_endless: bool, endless_data: Array) -> void :
	time = t
	kills = kill_count
	run_zeny = zeny
	_event_index = clampi(ev_index, 0, stage.events.size())
	endless = is_endless

	_mvp_ran_early = is_endless
	if endless_data.size() >= 2:
		_endless_next = float(endless_data[0])
		_endless_count = int(endless_data[1])
	RunSave.save(self)









const SOUND_DUCK_MS: = 900
const SOUND_DUCK_DB: = -10.0
var _duck_until: = 0
var _sound_steal: = 0

const UI_CLICK_DB: = -5.0


func play_sound(key: String, min_interval: = 0.08, volume_db: = 0.0, pitch: = -1.0, jitter: = true, important: = false) -> void :
	if key == "":
		return
	var now: = Time.get_ticks_msec()
	if now - int(_sound_last.get(key, -100000)) < int(min_interval * 1000.0):
		return
	var stream: = RoAssets.sound(key)
	if stream == null:
		return
	if important:
		_duck_until = now + SOUND_DUCK_MS
	elif now < _duck_until:
		volume_db += SOUND_DUCK_DB
	_sound_last[key] = now
	if net.recording() and not _sound_local:
		net.record(["s", key, volume_db, pitch])



	if key == "ui_click":
		var ui: = clampf(float(Save.setting("ui_volume", 1.0)), 0.0, 1.0)
		if ui <= 0.001:
			return
		volume_db += UI_CLICK_DB + linear_to_db(ui)
	if GameData.has_meta("sound_log"):
		print("SOUND %.2f %s" % [now / 1000.0, key])
	for sp in _sound_players:
		if not sp.playing:
			sp.stream = stream
			sp.volume_db = -8.0 + volume_db
			sp.pitch_scale = (pitch * (randf_range(0.98, 1.02) if jitter else 1.0)) if pitch > 0.0 else randf_range(0.94, 1.06)
			sp.play()
			return

	if important and not _sound_players.is_empty():
		var sp: AudioStreamPlayer = _sound_players[_sound_steal % _sound_players.size()]
		_sound_steal += 1
		sp.stop()
		sp.stream = stream
		sp.volume_db = -8.0 + volume_db
		sp.pitch_scale = pitch if pitch > 0.0 else 1.0
		sp.play()


var _song_player: AudioStreamPlayer


func _stop_song() -> void :
	if _song_player != null:
		_song_player.stop()




func _play_song(key: String, volume_db: float) -> void :
	if key == "":
		return
	if _song_player == null:
		_song_player = AudioStreamPlayer.new()
		_song_player.bus = _sound_players[0].bus if not _sound_players.is_empty() else "Master"
		add_child(_song_player)
	if _song_player.playing:
		return
	var stream: = RoAssets.sound(key)
	if stream == null:
		return
	_song_player.stream = stream
	_song_player.volume_db = -10.0 + volume_db
	_song_player.play()




func play_mob_sound(mob: String, kind: String) -> void :
	var file: = RoAssets.mob_sound(mob, kind)
	if file != "":
		play_sound("mob/" + file, 0.12, -7.0)



func play_skill_sound(s: Dictionary) -> void :
	if s.get("song", false):
		_play_song(str(s.get("sound", "")), float(s.get("sound_db", -3.0)))
		return
	play_sound(s.get("sound", ""), float(s.get("sound_cd", SKILL_SOUND_CD)), float(s.get("sound_db", -3.0)))

	if s.has("sound_twice"):
		var key: = str(s.sound)
		var db: = float(s.get("sound_db", -3.0))
		get_tree().create_timer(float(s.sound_twice), false).timeout.connect( func(): play_sound(key, 0.0, db, 1.08))

	play_sound(s.get("sound_extra", ""), float(s.get("sound_cd", SKILL_SOUND_CD)), float(s.get("sound_db", -3.0)))







func _save_test() -> void :
	set_stage("payon")
	Save.data.cards["poring_card"] = 1
	Save.data.card_slots = ["poring_card"]
	Save.add_pet("poring")
	Save.set_active_pet("poring")
	start_run("archer")
	for i in 12:
		player.add_xp(player.xp_need)
	player.job_change()
	player.add_skill("double_strafe")
	player.add_stat("dex")
	player.add_card("poring_card")
	player.equipment.receive(player.equipment.roll_item(300.0, 1))
	time = 222.0
	kills = 77
	var before: = [player.level, player.skills.keys(), player.stats.dex, player.cards, player.job_name(), 
		_gear_names(), time, kills, player.album_cards, player.pet_id, player.pet_skin, player.dishes, pet_id]
	print("SAVE saved=", RunSave.save(self), " file=", RunSave.path())
	running = false

	Save.data.cards["fabre_card"] = 1
	Save.data.card_slots = ["fabre_card"]
	Save.add_pet("lunatic")
	Save.set_active_pet("lunatic")
	print("SAVE resumed=", RunSave.resume(self))
	var after: = [player.level, player.skills.keys(), player.stats.dex, player.cards, player.job_name(), 
		_gear_names(), time, kills, player.album_cards, player.pet_id, player.pet_skin, player.dishes, pet_id]
	print("SAVE before=", before)
	print("SAVE after =", after)
	print("SAVE match=", str(before) == str(after), " stage=", stage_id)
	RunSave.clear()
	get_tree().quit()


func _gear_names() -> Array:
	var out: = []
	for k in player.equipment.slots:
		if player.equipment.slots[k] != null:
			out.append(Equipment.item_name(player.equipment.slots[k]))
	out.sort()
	return out


func _stress_report() -> void :
	while is_inside_tree() and running:
		print("STRESS t=%d enemies=%d pickups=%d chests=%d nodes=%d objects=%d mem=%.0fMB vmem=%.0fMB draw=%d fps=%d" % [
			time, enemies.size(), pickups.size(), pickups.filter( func(p): return p.kind == "chest").size(), 
			Performance.get_monitor(Performance.OBJECT_NODE_COUNT), Performance.get_monitor(Performance.OBJECT_COUNT), 
			Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, 
			Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), Engine.get_frames_per_second()])
		await get_tree().create_timer(5.0, true, false, true).timeout



func _bench_report() -> void :
	var last: = _perf.duplicate()
	var vp: = get_viewport().get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	bench = true
	bench_fx = 0
	bench_hud = 0
	while is_inside_tree() and running:
		await get_tree().create_timer(5.0, true, false, true).timeout
		var n: = maxi(1, _perf.frames - int(last.frames))
		var parts: = []
		for k in ["pre", "director", "player", "enemies", "mobdraw", "projectiles", "pickups", "grid", "flow", "tick", "shadows", "render"]:
			parts.append("%s=%.2f" % [k, (_perf[k] - last[k]) / 1000.0 / n])



		var frame_ms: = float(_perf.frame - last.frame) / 1000.0 / n
		var world_ms: = float(_perf.world - last.world) / 1000.0 / n
		var fx_ms: = bench_fx / 1000.0 / n
		var hud_ms: = bench_hud / 1000.0 / n
		var render_ms: = RenderingServer.viewport_get_measured_render_time_cpu(vp) + RenderingServer.get_frame_setup_time_cpu()
		bench_fx = 0
		bench_hud = 0
		last = _perf.duplicate()
		print("BENCHFRAME t=%d frame=%.2f world=%.2f fx=%.2f hud=%.2f render_cpu=%.2f rest=%.2f gpu=%.2f" % [time, frame_ms, world_ms, 
			fx_ms, hud_ms, render_ms, frame_ms - world_ms - fx_ms - hud_ms - render_ms, RenderingServer.viewport_get_measured_render_time_gpu(vp)])
		print("BENCHDRAW t=%d %s" % [time, _draw_census()])


		print("BENCHZONES t=%d zones=%d lit=%d burning=%d bleeding=%d poisoned=%d" % [time, _zones.size(), _lit_zones.size(), 
			dots.burning.size(), dots.bleeding.size(), poisoned.size()])
		print("BENCH t=%d fps=%d proc=%.1fms draws=%d objs=%d prims=%d nodes=%d enemies=%d proj=%d pickups=%d fx=%d | %s" % [
			time, Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, 
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), 
			Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME), 
			Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), 
			Performance.get_monitor(Performance.OBJECT_NODE_COUNT), enemies.size(), projectiles.size(), pickups.size(), 
			fx_root.get_child_count(), " ".join(parts)])


		print("BENCHCACHE t=%d %s mob_kinds=%d" % [time, RoAssets.cache_report(), mob_renderer._kinds.size()])
		var rings: = [0, 0, 0, 0]
		for e in enemies:
			var d: = _flat_dist(e.position, player.position)
			rings[0 if d < 12.0 else (1 if d < 18.0 else (2 if d < FAR_TICK_DIST else 3))] += 1
		print("BENCHDIST <12=%d 12-18=%d 18-%d=%d far=%d" % [rings[0], rings[1], FAR_TICK_DIST, rings[2], rings[3]])
		print("BENCHRENDER cpu=%.2fms gpu=%.2fms setup=%.2fms" % [RenderingServer.viewport_get_measured_render_time_cpu(vp), 
			RenderingServer.viewport_get_measured_render_time_gpu(vp), RenderingServer.get_frame_setup_time_cpu()])
		print("BENCHMEM static=%dMB tex=%dMB buf=%dMB video=%dMB resources=%d" % [OS.get_static_memory_usage() / 1048576, 
			int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)) / 1048576, int(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED)) / 1048576, 
			int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / 1048576, int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))])




func _draw_census() -> String:
	var count: = {}
	var stack: Array[Node] = [self]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Node3D and not (n as Node3D).visible:
			continue
		stack.append_array(n.get_children())
		if not n is GeometryInstance3D:
			continue
		var owner_name: = "?"
		var up: = n.get_parent()
		while up != null:
			if up.get_script() != null:
				owner_name = str((up.get_script() as Script).resource_path.get_file().get_basename())
				break
			up = up.get_parent()
		var key: = "%s@%s" % [n.get_class(), owner_name]
		count[key] = int(count.get(key, 0)) + 1
	var keys: = count.keys()
	keys.sort_custom( func(a, b): return count[a] > count[b])
	var out: = []
	for k in keys.slice(0, 12):
		out.append("%s=%d" % [k, count[k]])
	return " ".join(out)




func _mob_bench_fill() -> void :
	if enemies.size() >= _mob_bench:
		return
	var pool: Array[String] = []
	for s in stage.spawns:
		var d: Dictionary = GameData.MONSTERS[s.mob]
		if not d.has("boss") and not d.get("elite", false) and not d.has("prop") and not d.get("static", false):
			pool.append(str(s.mob))
	if pool.is_empty():
		return
	for i in mini(12, _mob_bench - enemies.size()):
		var e: = spawn_enemy(pool[i % pool.size()], _offscreen_point(), true)
		if e != null:
			e.max_hp = 1e+15
			e.hp = e.max_hp



var _frames_trim_t: = 0.0





var _quick_mvp: = false
var _quick_mvp_t: = 0.0


func _quick_mvp_tick(delta: float) -> void :
	var b: Enemy = null
	if raid.state == "fight" and raid.boss != null and is_instance_valid(raid.boss):
		b = raid.boss
	elif morroc.boss != null and is_instance_valid(morroc.boss):
		b = morroc.boss
	if b == null or b.dead:
		_quick_mvp_t = 0.0
		return
	_quick_mvp_t += delta
	if _quick_mvp_t < 3.0:
		return
	_quick_mvp_t -= 0.5
	damage_by = player
	damage_enemy(b, b.max_hp * 0.4, Vector3.ZERO, "basic", "neutral")
	damage_by = null


func _start_smoke(args: Array) -> void :
	_quick_mvp = "--quick-mvp" in args
	var rest: = []
	for a in args.slice(args.find("--smoke") + 1):
		if str(a).begins_with("--"):
			break
		rest.append(a)
	var class_id: String = rest[0] if rest.size() > 0 else "mage"

	var meta_at: = args.find("--meta")
	if meta_at >= 0 and args.size() > meta_at + 1:
		for id in GameData.UPGRADES:
			Save.data.upgrades[id] = mini(int(args[meta_at + 1]), int(GameData.UPGRADES[id].max))
	if "--reborn" in args:
		Save.data.rebirths[class_id] = 1
	if "--lucky" in args:
		special_mult = 60.0


	var quest_at: = args.find("--quest-at")
	if quest_at >= 0 and args.size() > quest_at + 1:
		GameData.set_meta("quest_at", float(args[quest_at + 1]))


	GemRenderer.plain = "--plain-gems" in args

	for a in args:
		if str(a).begins_with("--sn-build="):
			var parts: = str(a).trim_prefix("--sn-build=").split("|")
			Save.set_sn_build({"skills": Array(parts[0].split(",", false)), "passives": Array(parts[1].split(",", false)) if parts.size() > 1 else []})

	if "--gems" in args:
		GameData.set_meta("xp_gems", true)

	var morroc_at: = args.find("--morroc-at")
	if morroc_at >= 0 and args.size() > morroc_at + 1:
		GameData.set_meta("morroc_at", float(args[morroc_at + 1]))

	var finale_at: = args.find("--finale-at")
	if finale_at >= 0 and args.size() > finale_at + 1:
		GameData.set_meta("finale_at", float(args[finale_at + 1]))
	var dish_at: = args.find("--dish")
	if dish_at >= 0 and args.size() > dish_at + 1:
		Save.complete_quest(str(GameData.RECIPES[str(args[dish_at + 1])].quest))
		Save.set_dish(str(args[dish_at + 1]))


	var cos_at: = args.find("--cosmetics")
	if cos_at >= 0 and args.size() > cos_at + 1:
		for cid in str(args[cos_at + 1]).split(",", false):
			Save.add_cosmetic(cid)
			Save.wear_cosmetic(class_id, str(GameData.COSMETICS.get(cid, {}).get("slot", "")), cid)
	var pet_at: = args.find("--pet")
	if pet_at >= 0 and args.size() > pet_at + 1:
		Save.add_pet(str(args[pet_at + 1]))
		Save.set_active_pet(str(args[pet_at + 1]))
	var stage_at: = args.find("--stage")
	if stage_at >= 0 and args.size() > stage_at + 1:
		set_stage(str(args[stage_at + 1]))
	_smoke_seconds = float(rest[1]) if rest.size() > 1 else 60.0
	_tower_sim = "--tower-sim" in args
	if _tower_sim:


		GameData.set_meta("mvp_at", 1000000000.0)
		GameData.set_meta("morroc_at", 1000000000.0)
	if not coop_classes.is_empty():


		var watch: = Timer.new()
		watch.wait_time = 20.0
		watch.process_mode = Node.PROCESS_MODE_ALWAYS
		watch.timeout.connect( func():
			var who: = []
			for h in heroes:
				who.append("%s%s hp=%d" % [h.class_id, " DOWN" if h.downed else "", h.hp])
			print("COOP watch t=%.0f running=%s paused=%s raid=%s menu=%s loot=%s %s" % [time, running, get_tree().paused, 
				raid.state, menus._mode, _loot != null, who]))
		add_child(watch)
		watch.start()

	if "--hard" in args:
		Save.clear_stage(stage_id)
		danger = GameData.DANGER_HARD

	var dg_at: = args.find("--danger")
	if dg_at >= 0 and args.size() > dg_at + 1:
		Save.data["max_danger"] = GameData.DANGER_MAX
		danger = int(args[dg_at + 1])

	var fx_at: = args.find("--fx")
	if fx_at >= 0 and args.size() > fx_at + 1:
		Save.set_setting("fx_alpha", float(args[fx_at + 1]))
		apply_audio_settings()
	autopilot = true

	Engine.time_scale = 1.0 if "--bench" in args else 4.0

	var speed_at: = args.find("--bench-speed")
	if speed_at >= 0 and args.size() > speed_at + 1:
		Engine.time_scale = float(args[speed_at + 1])


	if "--net-host" in args and await _net_test_host(args):
		Engine.time_scale = 1.0

		var want: = 1
		for a in args:
			if str(a).begins_with("--net-wait="):
				want = int(str(a).substr(11))
		for i in 120:
			if net.ready_peers().size() >= want:
				break
			await get_tree().create_timer(0.5).timeout
	start_run(class_id)

	if "--sl-build" in args:
		SoulLinker.sim_build(self, args)

	if "--frenzy" in args:
		frenzy = true

	if "--frenzy-x2" in args:
		frenzy = true
		game_fast = true


	var only_at: = args.find("--only-skill")
	if only_at >= 0 and args.size() > only_at + 1:
		player.skills.clear()
		for k in 5:
			player.add_skill(str(args[only_at + 1]))
		player.recompute()
		player.max_hp = 99999.0
		player.hp = 99999.0
		menus.auto_pick = true
		player.set_meta("only_skill", true)


	if "--kit-test" in args:
		Encore.test_build(self, args)

	if "--god" in args:
		GameData.set_meta("tour_god", true)
	if "--bench" in args:

		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0


		if "--bench-build" in args:
			player.job_change(0)
			for id in player.skill_pool():
				if player.count_skills(false) >= player.max_skills() and not player.skills.has(id):
					continue
				if not Player.is_passive(id):
					for k in 5:
						player.add_skill(id)
			player.recompute()


		var bow_at: = args.find("--bench-bow")
		if bow_at >= 0 and args.size() > bow_at + 1:
			if player.class_id == "archer":
				player.job_change(1)
			player.stats["agi"] = int(player.stats.get("agi", 0)) + int(args[bow_at + 1])
			player.meta["crit"] = 1.0
			player.recompute()
			print("BENCHBOW class=%s aspd=%.1f hits=%.2f bounces=%d" % [player.class_id, player.aspd(), player.swing_hits(), player.basic_bounces()])



		var bsk_at: = args.find("--bench-skills")
		if bsk_at >= 0 and args.size() > bsk_at + 1:
			if player.job2.is_empty():

				player.job_change(int(args[args.find("--bench-path") + 1]) if args.has("--bench-path") else 0)
			player.skills.clear()
			for id in str(args[bsk_at + 1]).split(",", false):
				player.skills[id] = {"level": 1 if GameData.SKILLS[id].get("evolved", false) else GameData.MAX_SKILL_LEVEL, "cd": 0.0}
			for id in player.job2.get("passives", []) + GameData.CLASSES[player.class_id].get("passives", []):
				player.skills[id] = {"level": GameData.MAX_SKILL_LEVEL, "cd": 0.0}
			player.level = 90


			if args.has("--bench-stats"):
				for kv in str(args[args.find("--bench-stats") + 1]).split(",", false):
					var pair: = kv.split("=")
					player.stats[pair[0]] = int(player.stats.get(pair[0], 0)) + int(pair[1])
			player.recompute()
			print("BENCHSKILLS cd_mult=%.2f double=%.2f " % [player.cd_mult, player.double_cast_chance()] + " job=%s aspd=%.1f skills=%s" % [player.job2.get("id", ""), player.aspd(), player.skills.keys()])

		var mb_at: = args.find("--mob-bench")
		if mb_at >= 0 and args.size() > mb_at + 1:
			_mob_bench = int(args[mb_at + 1])
			GameData.set_meta("no_spawn", true)
			GameData.set_meta("tour_god", true)
		_bench_report()

	if "--endless-now" in args:
		endless = true
		_event_index = stage.events.size()
		_endless_next = time + 5.0


	if "--stuck-boss" in args:
		var sb: = spawn_enemy("owl_duke", map.find_point_around(player.position, 30.0, 40.0), true)
		if sb != null:
			sb.speed = 0.0
			sb.max_hp = 1e+15
			sb.hp = sb.max_hp
			boss = sb

	var eq_at: = args.find("--equip")
	if eq_at >= 0 and args.size() > eq_at + 1:

		for iid in str(args[eq_at + 1]).split(","):
			var it: = Equipment.make(iid, 0)
			var slot: = str(Equipment.item_def(it).slot)
			if slot == "acc":
				slot = "acc1" if player.equipment.slots.get("acc1") == null else "acc2"
			player.equipment.slots[slot] = it
		player.recompute()
	if rest.size() > 2:
		time = float(rest[2])
		while _event_index < stage.events.size() and stage.events[_event_index].at < time - 1.0:
			_event_index += 1
		_smoke_seconds += time
		player.max_hp = 99999.0
		player.hp = 99999.0
	menus.auto_pick = true


	var chests_at: = args.find("--chests")
	if chests_at >= 0 and args.size() > chests_at + 1:
		player.max_hp = 99999.0
		player.hp = 99999.0
		for i in int(args[chests_at + 1]):
			_drop_chest(map.random_point_around(player.position, randf_range(8.0, 40.0)), 1, i % 3)
		_stress_report()

	var at: = args.find("--at")
	if at >= 0 and args.size() > at + 1:
		var xz: = str(args[at + 1]).split(",")
		var p: = Vector3(float(xz[0]), 0.0, float(xz[1]))
		player.position = Vector3(p.x, map.height_at(p), p.z)
		_slope_test = true

	var shots_at: = args.find("--shots")
	if shots_at >= 0 and args.size() > shots_at + 2:
		_shot_dir = args[shots_at + 1]
		for t in str(args[shots_at + 2]).split(","):
			_shot_times.append(float(t))






func _album_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var ids: Array = GameData.CARDS.keys()
	for i in ids.size():
		if i % 3 != 2:
			Save.data.cards[ids[i]] = 1 + i % 6
	Save.data.card_slots = [ids[0], ids[3]]
	Save.data["eternal"] = {ids[1]: 1}
	for id in GameData.PETS.keys().slice(0, 18):
		Save.add_pet(id)
	Save.set_active_pet(str(GameData.PETS.keys()[2]))
	var pairs: = GameData.plagiarism_pairs()
	for i in range(0, pairs.size(), 2):
		Save.add_plagiarism(str(pairs[i][1]))
	var got: = Save.plagiarized()
	for i in mini(2, got.size()):
		Save.toggle_plagiarism(got[i])
	if got.size() > 3:
		Save.set_plagiarism_pick(got[3])
	var items: Array = GameData.ITEMS.keys()
	for i in items.size():
		if i % 2 == 0:
			Save.mark_seen("items", items[i])
	Save.bump("kills", 1200)

	menus._run_class = "mage"
	var shots: = [["cards", "", "1_cards"], ["pets", "", "2_pets"], ["gear", "sets", "3_gear_sets"], ["gear", "legend", "4_gear_legend"], 
		["evo", "", "5_evo"], ["ach", "", "6_ach"], ["plagio", "", "7_plagio"]]
	for sh in shots:
		menus._album_tab = sh[0]
		if sh[1] != "":
			menus._gear_tab = sh[1]
		menus._album_scroll = 0
		menus.show_album()
		await wait.call(0.8)
		await _tour_shot(sh[2])
	get_tree().quit()



func _levelup_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	start_run("mage")
	await wait.call(2.0)
	player.skills["fire_bolt"] = {"level": 3, "cd": 0.0}
	player.rerolls = 2
	player.banishes = 1
	var shown: = [{"kind": "skill", "id": "fire_bolt", "level": 4, "from": 3, "rarity": 0, "w": 1.0}, 
		{"kind": "skill", "id": "fire_wall", "level": 2, "from": 0, "rarity": 1, "w": 1.0}, 
		{"kind": "skill", "id": "thunder_storm", "level": 3, "from": 0, "rarity": 2, "w": 1.0}, 
		{"kind": "skill", "id": "energy_coat", "level": 3, "from": 0, "rarity": 3, "w": 1.0}]
	var lt: = Time.get_ticks_usec()
	if "--warm" in OS.get_cmdline_user_args():
		await UiKit.warm_up(menus)
		print("LVLUP warm %.1f ms" % ((Time.get_ticks_usec() - lt) / 1000.0))
	lt = Time.get_ticks_usec()
	menus.show_level_up(shown)
	print("LVLUP build %.1f ms" % ((Time.get_ticks_usec() - lt) / 1000.0))
	await get_tree().process_frame
	print("LVLUP first frame %.1f ms" % ((Time.get_ticks_usec() - lt) / 1000.0))
	lt = Time.get_ticks_usec()
	menus.show_level_up(shown)
	await get_tree().process_frame
	print("LVLUP again %.1f ms" % ((Time.get_ticks_usec() - lt) / 1000.0))
	await wait.call(1.4)
	await _tour_shot("1_rarities")
	menus._cards[1].grab_focus()
	await wait.call(0.3)
	await _tour_shot("1b_focus")
	menus.show_level_up([{"kind": "stat", "id": "int", "level": 10, "from": 9, "rarity": 0, "w": 1.0}, 
		{"kind": "stat", "id": "dex", "level": 13, "from": 11, "rarity": 1, "w": 1.0}, 
		{"kind": "potion", "id": "potion", "w": 1.0}])
	await wait.call(1.4)
	await _tour_shot("2_stats")
	menus.show_level_up(shown)
	await wait.call(1.4)
	menus._arm_banish(true)
	await wait.call(0.3)
	await _tour_shot("3_banish")
	menus._arm_banish(false)
	player.rerolls = 0
	player.banishes = 0
	menus.show_level_up(shown.slice(0, 3))
	await wait.call(1.4)
	await _tour_shot("4_no_tools")


	player.job2 = (GameData.CLASSES.mage.job2_alt as Dictionary).trans
	player.skills["double_casting"] = {"level": 57, "cd": 0.0}
	player.recompute()
	player.effects["double_cast"] = float(player.effects.get("double_cast", 0.0)) + 0.6
	menus.show_level_up([{"kind": "skill", "id": "double_casting", "level": 58, "from": 57, "rarity": 2, "w": 1.0}])
	await wait.call(1.4)
	await _tour_shot("5_double_casting")
	get_tree().quit()




func _picks_tour(dir: String) -> void :
	_shot_dir = dir

	if "--reborn" in OS.get_cmdline_user_args():
		Save.data.rebirths["mage"] = 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	start_run("mage")
	await wait.call(2.0)
	menus.show_start_skill(player.start_options(), func(_id: String): pass)
	await wait.call(1.2)
	await _tour_shot("1_start_skill")
	menus.close()
	menus.show_start_skill(player.start_options(), func(_id: String): pass, "", "", "", ["sp_recovery", "energy_coat"])
	await wait.call(1.2)
	await _tour_shot("1b_start_passives")
	menus.close()
	var many: Array = GameData.SKILLS.keys().filter( func(k): return GameData.SKILLS[k].get("type", "") == "projectile").slice(0, 8)
	menus.show_start_skill(many, func(_id: String): pass, "", "", "", ["sp_recovery", "energy_coat", "magnum_break", "endure"])
	await wait.call(1.4)
	await _tour_shot("1c_start_many")
	menus.close()
	menus.show_job_change()
	await wait.call(1.0)
	await _tour_shot("2_job_change")
	menus.close()
	seed(7)
	menus.show_chest(player.open_chest(2, 2, 300.0), 2)
	await wait.call(3.0)
	await _tour_shot("3_chest")
	menus._close_chest()

	var boxes: Array = []
	for i in 4:
		boxes.append_array(player.open_chest(2, 2, 300.0))
	menus.show_chest(boxes, 2)
	await wait.call(1.0 + 0.4 * boxes.size())
	await _tour_shot("3b_chest_many")
	menus._close_chest()
	menus.show_card_reveal("eclipse_card")
	await wait.call(1.0)
	await _tour_shot("4_card_reveal")
	menus._close_chest()
	var wpn = player.equipment.slots.weapon
	wpn.slots = 1
	wpn.cards = ["fabre_card"]
	player.equipment.card_bag.append("wolf_card")
	menus.show_card_choice("wolf_card")
	await wait.call(0.8)
	await _tour_shot("5_card_choice")
	get_tree().quit()




func _intro_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	Save.set_setting("intro_kafra_seen", false)
	menus.show_class_select()
	await wait.call(4.0)

	for k in 30:
		await wait.call(0.1)
	await _tour_shot("1_hello")
	var yes = menus._root.find_children("*", "Button", true, false).filter( func(c): return c.text == menus.tr("Sí, porfa"))
	if not yes.is_empty():
		yes[0].pressed.emit()
	await wait.call(1.8)
	await _tour_shot("2_line")
	for i in 5:
		var b = menus._root.find_children("*", "PanelContainer", true, false).filter( func(c): return c.has_signal("finished"))
		if b.is_empty():
			break
		b[0].show_line(i + 1)
		await wait.call(1.8)
		await _tour_shot("%d_line" % (i + 3))
		if i == 1:

			get_window().size = Vector2i(1500, 860)
			await wait.call(1.5)
			await _tour_shot("%d_resized" % (i + 3))
	get_tree().quit()




func _inspect_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	enter_town("mage")
	await wait.call(1.5)
	var cls: = "mage"
	var lk: = Save.look(cls)
	var shown: Dictionary = GameData.shown_job(cls, lk)
	var views: Dictionary = Equipment.loadout_views(cls)
	var gear: = {"_look": {"b": str(shown.body), "w": str(shown.weapon), "wf": str(shown.weapon_fx), "h": "hat_apple", 
		"s": "", "x": views.extras, "cos": [], "g": "f", "hr": 5, "hc": 3, "c": 0, "a": true, "ach": 42, "rlv": 3}}
	menus.show_player_gear("Tester", [cls, gear, []])
	await wait.call(1.5)
	await _tour_shot("inspect")
	menus.show_player_gear("Old", [cls, {}, []])
	await wait.call(1.0)
	await _tour_shot("inspect_old")
	get_tree().quit()





func _selectfps_test() -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	if not Save.data.has("classes"):
		Save.data["classes"] = {}
	for cid in ["swordsman", "mage", "archer", "acolyte", "thief"]:
		var cp: = Save.class_progress(cid)
		cp["rlv"] = 10
		Save.data.classes[cid] = cp
		Save.data.rebirths[cid] = 1
	menus.show_class_select()
	await wait.call(3.0)
	for k in 3:
		await wait.call(1.0)
		print("SELECTFPS t%d fps=%d" % [k, Engine.get_frames_per_second()])
	var views: = get_tree().root.find_children("*", "SubViewport", true, false)
	print("SELECTFPS %s views=%d fps=%d" % [RenderingServer.get_current_rendering_method(), views.size(), Engine.get_frames_per_second()])
	for v in views:
		(v as SubViewport).render_target_update_mode = SubViewport.UPDATE_DISABLED
	await wait.call(2.5)
	print("SELECTFPS no previews fps=%d" % Engine.get_frames_per_second())
	get_tree().quit()




func _touch_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	if "--scroll" in OS.get_cmdline_user_args():
		await _touch_scroll_test(wait)
		get_tree().quit()
		return
	GameData.set_meta("no_spawn", true)
	start_run("swordsman")
	await wait.call(2.0)
	var x0: = player.position.x

	Save.set_setting("sticks_swapped", "--swap" in OS.get_cmdline_user_args())
	print("TOUCHTEST stick at %s, camera at %s" % [mouse_walk.stick_center(), mouse_walk.cam_stick_center()])
	var xf: = get_tree().root.get_final_transform()
	var at: Vector2 = xf * mouse_walk.stick_center()
	var down: = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = at
	Input.parse_input_event(down)
	await wait.call(0.1)
	var mv: = InputEventMouseMotion.new()
	mv.position = at + xf.basis_xform(Vector2(50, 0))
	mv.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(mv)
	await wait.call(1.0)
	await _tour_shot("touch_stick")
	print("TOUCHTEST moved x %.2f (touch=%s)" % [player.position.x - x0, MouseWalk.touch()])
	var up: = InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = at + xf.basis_xform(Vector2(50, 0))
	Input.parse_input_event(up)
	await wait.call(0.6)
	var x1: = player.position.x
	await wait.call(0.6)
	print("TOUCHTEST after release moved %.2f" % (player.position.x - x1))


	Save.set_setting("sticks_hidden", true)
	Save.set_setting("stick_free", true)
	await wait.call(0.4)
	await _tour_shot("touch_hidden")
	var fview: = get_viewport().get_visible_rect().size
	var fmid: = Vector2(fview.x * 0.25, fview.y * 0.45)
	var t0: = InputEventScreenTouch.new()
	t0.index = 0
	t0.pressed = true
	t0.position = xf * fmid
	Input.parse_input_event(t0)
	await wait.call(0.1)
	var fdrag: = InputEventScreenDrag.new()
	fdrag.index = 0
	fdrag.position = xf * (fmid + Vector2(0, -50))
	Input.parse_input_event(fdrag)
	var z0: = player.position.z
	await wait.call(1.0)
	await _tour_shot("touch_free")
	print("TOUCHTEST free stick anchor=%s moved z %.2f" % [mouse_walk._anchor, player.position.z - z0])
	t0.pressed = false
	t0.position = fdrag.position
	Input.parse_input_event(t0)
	await wait.call(0.3)
	Save.set_setting("sticks_hidden", false)
	Save.set_setting("stick_free", false)

	enter_town("swordsman")
	await wait.call(1.5)
	var crowd: TownCrowd = town._crowd
	crowd.set_meta("log_test", true)
	for i in 6:
		channel.log_line("all", "Jugador%d : hola desde el canal" % i)
	crowd.open_chat("hola")
	await wait.call(0.5)
	crowd._close_chat()
	await wait.call(0.3)
	var tx0: = town.hero.position.x
	at = xf * mouse_walk.stick_center()
	down.position = at
	Input.parse_input_event(down)
	await wait.call(0.1)
	mv.position = at + xf.basis_xform(Vector2(50, 0))
	Input.parse_input_event(mv)
	await wait.call(1.0)
	await _tour_shot("touch_town_chat")
	print("TOUCHTEST town moved x %.2f with the chat at %s" % [town.hero.position.x - tx0, crowd._log.get_global_rect()])
	up.position = mv.position
	Input.parse_input_event(up)
	crowd.open_chat("")
	await wait.call(0.5)
	await _tour_shot("touch_town_typing")
	crowd._close_chat()

	Save.set_setting("chat_min", true)
	crowd._log._apply_min()
	await wait.call(0.4)
	await _tour_shot("touch_town_chat_min")
	print("TOUCHTEST chat minimized at %s" % crowd._log.get_global_rect())
	Save.set_setting("chat_min", false)
	crowd._log._apply_min()

	var finger: = func(i: int, p: Vector2, on: bool):
		var t: = InputEventScreenTouch.new()
		t.index = i
		t.position = xf * p
		t.pressed = on
		Input.parse_input_event(t)
	var drag: = func(i: int, p: Vector2):
		var d: = InputEventScreenDrag.new()
		d.index = i
		d.position = xf * p
		Input.parse_input_event(d)
	for pair in [[200.0, 120.0], [120.0, 260.0]]:
		var d0: = _cam_distance
		var hp: = town.hero.position
		finger.call(0, Vector2(640 - pair[0], 300), true)
		finger.call(1, Vector2(640 + pair[0], 300), true)
		await wait.call(0.1)
		for k in 6:
			var w: float = lerpf(pair[0], pair[1], (k + 1) / 6.0)
			drag.call(0, Vector2(640 - w, 300))
			drag.call(1, Vector2(640 + w, 300))
			await wait.call(0.05)
		finger.call(1, Vector2(640 + pair[1], 300), false)
		finger.call(0, Vector2(640 - pair[1], 300), false)
		await wait.call(0.6)
		print("TOUCHTEST pinch %s: distance %.1f -> %.1f, hero moved %.2f" % ["together" if pair[1] < pair[0] else "apart", 
			d0, _cam_distance, town.hero.position.distance_to(hp)])
	await _tour_shot("touch_town_pinch")
	get_tree().quit()





func _touch_scroll_test(wait: Callable) -> void :
	var xf: = get_tree().root.get_final_transform()
	var press: = func(at: Vector2, on: bool):
		var e: = InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.pressed = on
		e.position = xf * at
		e.global_position = e.position
		Input.parse_input_event(e)
	var drag: = func(from: Vector2, by: Vector2):
		press.call(from, true)
		await wait.call(0.05)
		for k in 10:
			var m: = InputEventMouseMotion.new()
			m.position = xf * (from + by * (k + 1) / 10.0)
			m.global_position = m.position
			m.button_mask = MOUSE_BUTTON_MASK_LEFT
			Input.parse_input_event(m)
			await wait.call(0.016)
		press.call(from + by, false)
		await wait.call(0.05)
	var biggest: = func(root: Node) -> ScrollContainer:
		var best: ScrollContainer = null
		for n in root.find_children("*", "ScrollContainer", true, false):
			var sc: = n as ScrollContainer
			if sc.is_visible_in_tree() and (best == null or sc.get_v_scroll_bar().max_value > best.get_v_scroll_bar().max_value):
				best = sc
		return best

	var longest: = ""
	var most: = -1.0
	for tab in Menus.OPTION_TABS:
		menus.show_options(tab)
		await wait.call(0.4)
		var s: ScrollContainer = biggest.call(menus)
		if s != null and s.get_v_scroll_bar().max_value - s.get_v_scroll_bar().page > most:
			most = s.get_v_scroll_bar().max_value - s.get_v_scroll_bar().page
			longest = tab
	menus.show_options(longest)
	await wait.call(0.8)
	await _tour_shot("scroll_options_0")
	var sc: ScrollContainer = biggest.call(menus)
	var settings: Dictionary = Save.data.get("settings", {}).duplicate(true)
	var r: = sc.get_global_rect()
	var mid: = sc.get_global_transform_with_canvas() * (sc.size * Vector2(0.3, 0.6))
	var v0: = sc.scroll_vertical
	await drag.call(mid, Vector2(0, - r.size.y * 0.5))
	await wait.call(0.6)
	await _tour_shot("scroll_options_1")
	print("TOUCHSCROLL options scrolled %d -> %d (max %d), settings unchanged %s" % [v0, sc.scroll_vertical, 
		int(sc.get_v_scroll_bar().max_value - sc.get_v_scroll_bar().page), Save.data.get("settings", {}) == settings])

	var before: = sc.scroll_vertical
	await drag.call(mid, Vector2(0, r.size.y * 0.4))
	var at_lift: = sc.scroll_vertical
	await wait.call(0.5)
	print("TOUCHSCROLL flick %d -> %d at lift -> %d after" % [before, at_lift, sc.scroll_vertical])
	menus._back_to_hub()

	menus.show_server_select("swordsman")
	await wait.call(0.8)
	var ws: Control = null
	for n in menus.find_children("*", "Control", true, false):
		if n.has_method("_show_look"):
			ws = n
			break
	ws.set("_side_tab", "records")
	ws.call("_fill_side")
	await wait.call(0.4)
	var top: = []
	for i in 20:
		top.append({"rank": i + 1, "name": "Jugador%d" % i, "tag": "#%04X" % (i * 77), "class": "swordsman", 
			"score": 90000 - i * 3000, "time": 900 - i * 10, "zeny": 5000, "danger": 3, "mvps": 1, 
			"look": {"g": "m", "hr": 3, "hc": 1}})
	(ws.get("_board_show") as Callable).call({"top": top, "total": 20, "days_left": 12})
	await wait.call(0.5)
	await _tour_shot("scroll_records_0")
	var rs: ScrollContainer = biggest.call(ws)
	var kids: = ws.get_child_count()
	var rr: = rs.get_global_rect()
	var rmid: = rs.get_global_transform_with_canvas() * (rs.size * Vector2(0.5, 0.7))
	var w0: = rs.scroll_vertical
	await drag.call(rmid, Vector2(0, - rr.size.y * 0.5))
	await wait.call(0.6)
	await _tour_shot("scroll_records_1")
	print("TOUCHSCROLL records scrolled %d -> %d, opened by the drag: %s" % [w0, rs.scroll_vertical, ws.get_child_count() != kids])
	press.call(rmid, true)
	await wait.call(0.08)
	print("TOUCHSCROLL records opened on touch down: %s" % (ws.get_child_count() != kids))
	press.call(rmid, false)
	await wait.call(0.5)
	print("TOUCHSCROLL records opened by a tap: %s" % (ws.get_child_count() != kids))
	await _tour_shot("scroll_records_tap")

	GameData.set_meta("no_spawn", true)
	start_run("swordsman")
	await wait.call(2.0)
	Save.set_setting("hold_levels", true)
	player.rerolls = 2
	player.banishes = 1
	player.pending_levels = 2
	await wait.call(0.6)
	await _tour_shot("scroll_held_button")
	open_held_levels()
	await wait.call(1.0)
	await _tour_shot("scroll_held_levels")
	print("TOUCHSCROLL texts: %s | %s" % [tr("Seguir jugando  (Tab)"), tr("Abrir  (Tab)")])

	menus._resume()
	await wait.call(0.3)
	Save.set_setting("touch_toggle_tip", false)
	player.add_skill("charge_attack")
	await wait.call(1.0)
	await _tour_shot("scroll_toggle_tip")
	var tip_up: bool = hud._toggle_tip != null
	var slot_d: Dictionary = hud._skill_slots.filter( func(d): return str(d.id) == "charge_attack")[0]
	var sl: Control = slot_d.slot
	var mid_s: Vector2 = sl.get_global_transform_with_canvas() * (sl.size * 0.5)
	press.call(mid_s, true)
	await wait.call(0.05)
	press.call(mid_s, false)
	await wait.call(0.6)
	print("TOUCHSCROLL toggle tip shown %s, gone after a tap %s, skill off %s, seen %s" % [tip_up, hud._toggle_tip == null, 
		player.is_off("charge_attack"), Save.setting("touch_toggle_tip", false)])
	await _tour_shot("scroll_toggle_tap")




func _menus_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	menus.show_login()
	await wait.call(1.0)
	await _tour_shot("1_login")
	Save.data.zeny = 4321
	if not Save.data.has("classes"):
		Save.data["classes"] = {}
	for cid in ["swordsman", "mage", "archer"]:
		var cp: = Save.class_progress(cid)
		cp["rlv"] = 3
		Save.data.classes[cid] = cp
	Save.data.upgrades["kafra_storage"] = 8
	Save.data.records["swordsman"] = {"time": 1163.0, "victory": true}
	menus.show_class_select()
	await wait.call(1.0)
	await _tour_shot("2_class_select")
	menus.show_char_make("thief")
	await wait.call(0.8)
	await _tour_shot("3_char_make")
	menus.show_server_select("swordsman")
	await wait.call(0.8)
	await _tour_shot("4_server_select")

	for ws in menus.find_children("*", "Control", true, false):
		if ws.has_method("_danger_box"):
			Save.data["max_danger"] = 25
			Save.set_stage_danger(ws.stage_id, 12)
			ws._fill_side()
			await wait.call(0.5)
			await _tour_shot("4b_danger_hot")
			Save.set_stage_danger(ws.stage_id, 23)
			ws._fill_side()
			await wait.call(0.5)
			await _tour_shot("4c_danger_hell")
			break

	for ws in menus.find_children("*", "Control", true, false):
		if ws.has_method("_show_look"):
			ws._show_look({"cls": "mage", "class": "mage", "rank": 1, "score": 1234, "time": 600, "zeny": 5000, "mvps": 1, 
				"name": "Merlin", "look": {"g": "f", "hr": 5, "hc": 2, "a": true}})
			break
	await wait.call(0.8)
	await _tour_shot("5_record_look")
	menus.show_loadout("mage")
	await wait.call(0.8)
	await _tour_shot("6_loadout")
	menus.show_sage()
	await wait.call(0.8)
	await _tour_shot("7_sage")
	get_tree().quit()



func _hud_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	start_run("mage")
	await wait.call(2.0)
	for id in ["fire_bolt", "fire_wall", "cold_bolt", "thunder_storm"]:
		player.skills[id] = {"level": 3, "cd": 0.0}
	player.skills["sp_recovery"] = {"level": 2, "cd": 0.0}
	player.skills["energy_coat"] = {"level": 2, "cd": 0.0}
	player.pacts = ["frenzy", "might"]
	player.level = 14
	player.xp = player.xp_need * 0.62
	player.hp = player.max_hp * 0.7
	run_zeny = 1234
	hud.bind(self)
	await wait.call(1.5)
	await _tour_shot("1_hud")
	menus.show_equipment()
	await wait.call(0.8)
	await _tour_shot("1b_equipment")
	menus._resume()
	await wait.call(0.3)
	player.hp = player.max_hp * 0.18
	await wait.call(0.6)
	await _tour_shot("2_low_hp")
	Save.set_setting("hold_levels", true)
	player.pending_levels = 2
	await wait.call(0.6)
	await _tour_shot("3_held")
	player.pending_levels = 0

	var bid: String = GameData.MONSTERS.keys().filter( func(k): return GameData.MONSTERS[k].has("boss") and not GameData.MONSTERS[k].get("mvp", false))[0]
	boss = spawn_enemy(bid, player.position + Vector3(7, 0, 2), true)
	player.hp = player.max_hp
	autopilot = true
	for i in 12:
		spawn_enemy("poring", player.position + Vector3(randf_range(-9, 9), 0, randf_range(-9, 9)), true)
	await wait.call(6.0)
	autopilot = false
	hud.event_sign(menus.tr("Prontera Field"), "", Color(1.0, 0.85, 0.4), 4.0)
	if not hud._skill_slots.is_empty():
		var hs: Control = hud._skill_slots[0].veil.get_parent().get_parent()
		hud._show_hover(hs, hud._skill_hover(hud._skill_slots[0].id))
	await wait.call(0.5)
	await _tour_shot("4_fight")
	hud._hide_hover()

	if not meter.is_empty():
		var base: Dictionary = meter.values()[0]
		var ids: = GameData.SKILLS.keys().slice(0, 24)
		for k in ids.size():
			var m: = base.duplicate(true)
			m["dmg"] = 1000.0 * (k + 1)
			meter[ids[k]] = m
		meter_details.open("damage")
		await wait.call(0.8)
		var sc: = meter_details._list.get_parent() as ScrollContainer
		sc.scroll_vertical = 100000
		for n in 4:
			await wait.call(0.6)
			for k in ids.size():
				meter[ids[k]]["dmg"] = float(meter[ids[k]]["dmg"]) * randf_range(0.9, 1.3)
			print("METER scroll=%d" % sc.scroll_vertical)
		await _tour_shot("4b_meter_scrolled")
		meter_details.close_window()
	hud.npc_talk("", "Lydia", ["Hola, aventurero."], 3.0)
	await wait.call(0.8)
	await _tour_shot("5_talk")

	Save.set_setting("pick_order", {player.class_id: ["napalm_beat", "cold_bolt", "safety_wall", "fire_bolt"]})
	menus.show_pick_order()
	await wait.call(0.6)
	await _tour_shot("6_pick_order")

	var rows: Array = menus._root.find_children("*", "PanelContainer", true, false).filter( func(c): return c.has_meta("pick_id"))
	var before: = rows.map( func(c): return str(c.get_meta("pick_id")))
	var to_win: = func(at: Vector2) -> Vector2: return get_viewport().get_final_transform() * at
	var from_at: Vector2 = (rows.back() as Control).get_global_rect().get_center()
	var goal_at: Vector2 = (rows[0] as Control).get_global_rect().get_center() - Vector2(0, 8)
	var mv: = InputEventMouseMotion.new()
	mv.position = to_win.call(from_at)
	get_viewport().push_input(mv)
	var down: = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = to_win.call(from_at)
	get_viewport().push_input(down)
	for k in 8:
		var m: = InputEventMouseMotion.new()
		m.position = to_win.call(from_at.lerp(goal_at, (k + 1) / 8.0))
		m.button_mask = MOUSE_BUTTON_MASK_LEFT
		get_viewport().push_input(m)
		await wait.call(0.05)
	await _tour_shot("7_dragging")
	var up: = InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = to_win.call(goal_at)
	get_viewport().push_input(up)
	await wait.call(0.4)
	print("DRAG before=", before, " after=", Save.setting("pick_order", {}).get(player.class_id, []))
	await _tour_shot("8_dropped")

	menus.close()
	run_materials = {"elunium": 14, "oridecon": 8, "enriched_elunium": 2, "hd_elunium": 1}
	zeny_from = {"loot": 6982607, "chest": 859905, "sold": 51230}
	run_zeny = 7893742
	run_ymir = 1
	for i in 8:
		player.open_chest(2, 2, 300.0)


	endless = true
	player.revives = 0
	var foe: = spawn_enemy("poring", player.position + Vector3(2, 0, 0), true)
	player._invuln = 0.0
	player.take_damage(player.max_hp * 1000.0, self, foe, true)
	await wait.call(0.3)
	player.hp = 40.0
	await wait.call(2.5)
	await _tour_shot("9_end")
	get_tree().quit()


func _ui_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	menus.show_login()
	await wait.call(1.0)
	await _tour_shot("1_login")
	menus.show_options()
	await wait.call(0.5)
	await _tour_shot("1a_options")
	menus.close_options()
	Save.data.zeny = 4321
	Save.data.cards = {"poring_card": 3, "fabre_card": 1}
	Save.data.card_slots = ["poring_card"]
	Save.data.stages = {"prontera": true, "payon": true, "orc": true, "orc_dun": true, "glast": true}
	Save.data["max_danger"] = 9
	danger = 9
	fast_mode = true
	menus.show_server_select("swordsman")
	await wait.call(0.8)
	await _tour_shot("1b_server_select")
	danger = 1
	fast_mode = false
	newly_unlocked = "payon"
	menus.show_server_select()
	await wait.call(1.0)
	await _tour_shot("1b2_server_new_map")
	newly_unlocked = ""
	Save.set_setting("town_hint", true)
	menus.show_class_select()
	await wait.call(1.0)
	await _tour_shot("2_class_select")
	for w in menus.find_children("*", "RoCharSelect", true, false):
		w.select(3)
	await wait.call(0.6)
	await _tour_shot("2a_class_select_page2")
	enter_town("swordsman")
	await wait.call(1.6)
	await _tour_shot("2t_town")
	await wait.call(9.0)
	await _tour_shot("2t1_town_bubbles")
	town.hero.position = town._npcs[0].node.position + Vector3(1.5, 0, 0.5)
	await wait.call(0.8)
	await _tour_shot("2t2_town_kafra")

	menus.show_kafra_pick()
	await wait.call(0.5)
	await _tour_shot("2t2a_kafra_pick")
	Save.set_setting("kafra", "npc_kafra8")
	town.refresh_kafra()
	menus.show_kafra_talk()
	await wait.call(0.8)
	await _tour_shot("2t2b_kafra_called")
	menus.show_kafra()
	await wait.call(0.5)
	await _tour_shot("2t2c_kafra_shop")
	Save.set_setting("kafra", GameData.KAFRAS[0])
	town.refresh_kafra()
	menus.show_teleporter("swordsman")
	await wait.call(0.5)
	await _tour_shot("2t2d_teleporter")
	menus.show_coop()
	await wait.call(0.5)
	await _tour_shot("2t2e_coop")
	menus._back_to_hub()
	town.hero.position = town._portal_pos + Vector3(0, 0, -3.0)
	await wait.call(0.6)
	await _tour_shot("2t3_town_portal")
	menus.show_class_select()
	await wait.call(0.5)
	Save.set_look("thief", {"name": "Zero", "gender": "f", "hair": 7, "hair_color": 4, "cloth": 2})
	Save.data["classes"] = {"thief": {"level": 6, "xp": 1500, "stats": {"agi": 2}}}
	Save.data["pets"] = {"poring": true, "smokie": true}
	Save.data["pet"] = "poring"
	Save.set_look("mage", {"name": "Merlin", "gender": "f", "hair": 5, "hair_color": 2, "cloth": 1})
	menus.show_char_make("thief")
	await wait.call(0.8)
	await _tour_shot("2a2_char_make")
	menus.show_class_select("thief")
	await wait.call(0.6)
	await _tour_shot("2a3_class_select_styled")
	menus.show_loading( func(): pass)
	await wait.call(0.3)
	await _tour_shot("2a4_loading")
	menus.show_kafra()
	await wait.call(0.6)
	await _tour_shot("2b_kafra")
	menus.show_sage()
	await wait.call(0.6)
	await _tour_shot("2b2_sage")
	Save.toggle_pact("swordsman", "might")
	menus.show_pacts("swordsman")
	await wait.call(0.6)
	await _tour_shot("2b3_pacts")

	for iid in ["staff_of_destruction", "valkyrian_armor", "boots", "guard", "excalibur", "ring"]:
		if GameData.ITEMS.has(iid):
			Save.add_to_storage(Equipment.make(iid, 1))
	Save.set_loadout_slot("mage", "weapon", str(Save.storage()[0].uid))
	Save.add_material("oridecon", 3)
	Save.add_material("enriched_oridecon", 1)
	Save.add_material("hd_oridecon", 1)
	menus.show_loadout("mage")
	await wait.call(0.6)
	await _tour_shot("2b4_loadout")
	menus.show_refiner()
	await wait.call(0.6)
	await _tour_shot("2b5_refiner")
	Save.add_material("oridecon", 40)
	Save.add_material("enriched_elunium", 12)
	menus.show_transmute()
	await wait.call(0.6)
	await _tour_shot("2b5b_transmute")
	menus._transmute(0, 2)
	await wait.call(0.45)
	await _tour_shot("2b5c_transmute_fly")
	await wait.call(0.55)
	await _tour_shot("2b5d_transmute_burst")
	menus._run_class = "mage"
	Save.set_dish("rice_cake")
	menus.show_prep("prontera")
	await wait.call(0.6)
	await _tour_shot("2b6_prep")
	Save.toggle_pact("swordsman", "might")
	for id in GameData.SAGE_UPGRADES:
		Save.set_upgrade_level(id, 2)
	menus.show_album()
	await wait.call(0.6)
	await _tour_shot("2c_album")
	menus._album_tab = "pets"
	menus.show_album()
	await wait.call(0.5)
	await _tour_shot("2c2_album_pets")
	Save.add_pet("baphomet")
	menus._pet_tab = "mvp"
	menus.show_album()
	await wait.call(0.4)
	await _tour_shot("2c2b_album_pets_mvp")
	menus._pet_tab = "normal"
	menus._album_tab = "plagio"
	menus.show_album()
	await wait.call(0.4)
	await _tour_shot("2c2c_album_plagio")
	menus._album_tab = "evo"
	menus._evo_class = "acolyte"
	menus.show_album()
	await wait.call(0.5)
	await _tour_shot("2c3_album_evo")
	menus._album_tab = "ach"
	Save.bump("kills", 1200)
	menus.show_album()
	await wait.call(0.5)
	await _tour_shot("2c4_album_achievements")
	menus._album_tab = "cards"
	Save.data.records["mage"] = {"time": 600.0, "victory": true}
	Save.data.zeny = 15000
	Save.data["ymir"] = 2
	menus.show_rebirth("mage")
	await wait.call(0.6)
	await _tour_shot("2d_rebirth")
	Save.data["ymir"] = GameData.REBIRTH_FRAGMENTS
	Save.data.classes["mage"] = {"level": GameData.REBIRTH_CLASS_LEVEL, "xp": 0, "stats": {}}
	menus.show_rebirth("mage")
	await wait.call(0.6)
	await _tour_shot("2d2_rebirth_ready")
	menus.show_rebirth_ceremony("mage")
	await wait.call(3.0)
	await _tour_shot("2d3_ceremony")
	await wait.call(6.5)
	await _tour_shot("2d4_ceremony_rise")
	await wait.call(3.0)
	await _tour_shot("2d5_reborn")
	start_run("mage")
	print("TOUR loadout weapon=", player.equipment.slots.weapon.id, " perm=", Equipment.is_perm(player.equipment.slots.weapon))
	player.add_skill("fire_wall")
	player.add_skill("thunder_storm")
	player.add_card("poring_card")
	await wait.call(6.0)
	hud.announce("Jefe: Angeling", Color(1, 0.85, 0.4))
	boss = spawn_enemy("angeling", map.random_point_around(player.position, 6.0), true)

	for c in ["poring_card", "fabre_card", "lunatic_card", "willow_card", "eclipse_card", "mastering_card", 
			"bloody_knight_card", "drainliar_card", "poring_card", "poring_card", "angeling_card", "smokie_card"]:
		player.add_card(c)

	mouse_walk.target = player.position + Vector3(4, 0, 2)
	mouse_walk.active = true
	await wait.call(0.5)
	await _tour_shot("3_hud")
	var fz: = spawn_enemy("poring", player.position + Vector3(-3.0, 0, 1.5), true, true)
	if fz != null:
		fz.speed = 0.0
	_drop_chest(player.position + Vector3(3.0, 0, 2.0), 1, -1)
	await wait.call(0.8)
	await _tour_shot("3f_feroz_small_box")

	Save.set_setting("autosell", [0, 1, 2])
	for i in 4:
		_drop_chest(player.position + Vector3(0.3 * i, 0, 0.2), 1, -1)
	await wait.call(1.4)
	await _tour_shot("3g_autosell")
	Save.set_setting("autosell", [])
	var hp_before: = player.hp
	player.hp = player.max_hp * 0.18
	hud.danger.hurt(0.15)
	await wait.call(0.1)
	await _tour_shot("3a_low_hp")
	player.hp = hp_before
	menus.show_card_reveal("eclipse_card")
	await wait.call(1.0)
	await _tour_shot("3c_card_reveal")
	menus._close_chest()

	var wpn = player.equipment.slots.weapon
	wpn.slots = 1
	wpn.cards = ["fabre_card"]
	player.equipment.card_bag.append("wolf_card")
	menus.show_card_choice("wolf_card")
	await wait.call(0.6)
	await _tour_shot("3c2_card_choice")
	menus._close_chest()
	menus.show_equipment("weapon")
	await wait.call(0.5)
	await _tour_shot("3c3_equipment_cards")
	menus._resume()
	menus.show_start_skill(player.start_options(), func(_id: String): pass)
	await wait.call(1.2)
	await _tour_shot("3d0_start_skill")
	menus.close()
	get_tree().paused = false
	player.pacts = ["frenzy", "might"]
	hud.bind(self)
	await wait.call(0.4)
	await _tour_shot("3d1_hud_pacts")
	if not hud._skill_slots.is_empty():
		var hs: Control = hud._skill_slots[0].veil.get_parent().get_parent()
		hud._show_hover(hs, hud._skill_hover(hud._skill_slots[0].id))
		await wait.call(0.3)
		await _tour_shot("3d1b_skill_hover")
		hud._show_hover(hud._pact_row.get_child(0), hud._pact_hover("frenzy"))
		await wait.call(0.3)
		await _tour_shot("3d1c_pact_hover")
		hud._hide_hover()
	player.skills["fire_bolt"] = {"level": 5, "cd": 0.0}
	player.skills["sp_recovery"] = {"level": 1, "cd": 0.0}
	menus.show_compendium()
	await wait.call(0.6)
	await _tour_shot("3d2_compendium")
	menus.close()
	get_tree().paused = false
	menus.show_onboarding()
	await wait.call(0.8)
	await _tour_shot("3d_onboarding")
	menus._close_onboarding()
	menus.show_taming("poring", true, func(): pass)
	await wait.call(1.0)
	await _tour_shot("3e_taming_spin")
	await wait.call(2.0)
	await _tour_shot("3e2_taming_ok")
	await wait.call(1.5)
	menus.show_card_view("bloody_knight_card", 1)
	await wait.call(0.4)
	await _tour_shot("3b_card_view")
	menus.close_options()
	player.add_xp(player.xp_need)
	await wait.call(2.5)
	await _tour_shot("4_level_up")

	var shown: = player.build_choices()
	var ids: = ["fire_bolt", "fire_wall", "thunder_storm", "energy_coat"]
	for i in mini(4, shown.size()):
		shown[i] = {"kind": "skill", "id": ids[i], "level": 1 + [1, 2, 3, 3][i], "from": 1 if i < 3 else 0, "rarity": i, "w": 1.0}
	shown[0].from = 1
	menus.show_level_up(shown.slice(0, 4))
	await wait.call(1.2)
	await _tour_shot("4a_level_up_rarities")
	menus.show_level_up(shown.slice(0, 4))
	await wait.call(1.2)
	menus._arm_banish(true)
	await wait.call(0.2)
	await _tour_shot("4a1_level_up_banish")
	menus._arm_banish(false)
	var kept: = [player.rerolls, player.banishes]
	player.rerolls = 0
	player.banishes = 0
	menus.show_level_up(shown.slice(0, 4))
	await wait.call(1.2)
	await _tour_shot("4a2_level_up_no_tools")
	menus.show_level_up([{"kind": "stat", "id": "str", "level": 10, "from": 9, "rarity": 0, "w": 1.0}, 
		{"kind": "stat", "id": "vit", "level": 13, "from": 11, "rarity": 1, "w": 1.0}, 
		{"kind": "stat", "id": "agi", "level": 15, "from": 12, "rarity": 2, "w": 1.0}])
	await wait.call(1.2)
	await _tour_shot("4a3_level_up_overcap")
	player.banishes = 1
	menus.show_level_up([{"kind": "skill", "id": "back_stab", "level": 1, "from": 0, "rarity": 0, "w": 1.0}, 
		{"kind": "stat", "id": "agi", "level": 3, "from": 2, "rarity": 0, "w": 1.0}, 
		{"kind": "skill", "id": "grand_cross", "level": 2, "from": 0, "rarity": 1, "w": 1.0}, 
		{"kind": "skill", "id": "magnus_exorcismus", "level": 1, "from": 0, "rarity": 0, "w": 1.0}])
	await wait.call(0.6)
	menus._grace = 0.0
	menus._arm_banish(true)
	await wait.call(0.5)
	await _tour_shot("4a4_banish_long_texts")
	menus._arm_banish(false)
	player.rerolls = kept[0]
	player.banishes = kept[1]
	choose(player.build_choices()[0])
	player.level = GameData.JOB_CHANGE_LEVEL
	menus.show_job_change()
	await wait.call(0.8)
	await _tour_shot("4b_job_change")
	do_job_change()
	await wait.call(1.5)
	await _tour_shot("4c_after_job")



	var saved_skills: = player.skills
	player.skills = {}
	player.xp = 0.0
	player.pending_levels = 0
	var saved_magnet: = player.magnet
	player.magnet = 0.0
	await wait.call(1.5)
	for i in GameData.XP_GEMS.size():
		_drop_xp(player.position + Vector3(-5.0 + i * 1.4, 0, -5.0), int(GameData.XP_GEMS[i][0]) + 1)
	_drop_item(player.position + Vector3(2.5, 0, -5.0), "card", "poring_card")
	_drop_chest(player.position + Vector3(3.5, 0, -1.0), 2, 1)
	_drop_chest(player.position + Vector3(30.0, 0, -6.0), 1, 0)
	_drop_chest(player.position + Vector3(-12.0, 0, 30.0), 3, 2)
	await wait.call(2.0)
	await _tour_shot("4c2_drops")
	_open_chest_show(player.position + Vector3(3.5, 0, -1.0), 2, player.open_chest(2, 1, 300.0))
	await wait.call(0.45)
	await _tour_shot("4c3_chest_open")
	await wait.call(2.4)
	await _tour_shot("4d_chest")
	menus._close_chest()
	player.skills = saved_skills
	player.magnet = saved_magnet
	player.equipment.slots.weapon.refine = 8
	player.equipment.ores = {"oridecon": 3, "elunium": 2}
	player.equipment.receive(Equipment.make("cotton_shirt", 2))
	player.equipment.card_bag.append("willow_card")
	player.equipment.slots["shield"] = Equipment.make("guard", 1)
	player.equipment.slots["weapon"] = Equipment.make("sucsamad", 0)
	player.equipment.slots.weapon.refine = 8
	player.equipment.slots["acc1"] = Equipment.make("clip", 1)
	player.equipment.slots["acc2"] = Equipment.make("clip", 1)
	player.recompute()
	print("TOUR shield_view=", player.shield_view())
	menus.show_equipment("armor")
	await wait.call(0.6)
	await _tour_shot("4e_equipment")
	menus.show_equipment("weapon")
	await wait.call(0.4)
	await _tour_shot("4e2_refine")
	menus._refine("weapon")
	await wait.call(1.0)
	await _tour_shot("4e2b_refine_fx")
	menus._resume()
	await wait.call(0.4)
	await _tour_shot("4e2c_refine_hint")
	for i in 14:
		player.equipment.receive(player.equipment.roll_item(200.0 + i * 20.0, i % 2))
	menus.show_inventory(0)
	await wait.call(0.4)
	await _tour_shot("4e3_inventory")
	menus._resume()
	menus.show_pause()
	await wait.call(0.5)
	await _tour_shot("5_pause")
	get_tree().paused = false
	menus.close()
	run_ymir = 1
	player.death_by = {"by": "Baphomet", "what": "Brandish Spear", "sprite": "baphomet"}
	_end_run(false)
	await wait.call(0.6)
	await _tour_shot("6_end")
	get_tree().quit()



func _dump_chars(dir: String) -> void :


	var looks: = {}
	for class_id in GameData.CLASSES:
		var d: Dictionary = GameData.CLASSES[class_id]
		looks[class_id] = d
		for job: Dictionary in GameData.job_paths(class_id):
			var j2: Dictionary = job.duplicate()
			j2.erase("trans")
			looks[job.id] = j2
			if job.has("trans"):
				var tr: Dictionary = j2.duplicate()
				tr.body = job.trans.body
				looks[job.trans.id] = tr
	for class_id in looks:
		var d: Dictionary = looks[class_id]
		var w: Array = [d.get("weapon", ""), d.get("weapon_fx", "")]
		var ro: = RoAssets.character(d.body, "head_m", w[0], w[1], [5, 10, 11])
		var bases: = [0, 4, 5, 10, 11, 12]
		var cell: = ro.canvas_size
		var sheet: = Image.create(cell.x * 10, cell.y * bases.size(), false, Image.FORMAT_RGBA8)
		sheet.fill(Color(0.35, 0.5, 0.35))
		for r in bases.size():
			var a: int = bases[r] * 8 + 1
			for f in mini(10, ro.frame_count(a)):
				var img: = ro.compose_image(a, f)
				sheet.blend_rect(img, Rect2i(Vector2i.ZERO, cell), Vector2i(f * cell.x, r * cell.y))
		sheet.save_png("%s/%s.png" % [dir, class_id])
	get_tree().quit()




func _skill_tour(dir: String, only_class: = "") -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)

	var path: = 0
	if only_class.contains(":"):
		path = int(only_class.get_slice(":", 1))
		only_class = only_class.get_slice(":", 0)
	for class_id in GameData.CLASSES:
		if only_class != "" and class_id != only_class:
			continue
		var d: Dictionary = GameData.CLASSES[class_id]
		var job: Dictionary = GameData.job_paths(class_id)[mini(path, GameData.job_paths(class_id).size() - 1)]
		var ids: Array = d.skills + job.skills + (job.trans.skills if job.has("trans") else [])
		start_run(class_id)
		player.max_hp = 99999.0
		player.hp = 99999.0
		for id in ids:
			if not GameData.SKILLS.has(id) or GameData.SKILLS[id].type in ["heal", "passive"]:
				continue


			if player.job2.is_empty() and job.skills.has(id) and not d.skills.has(id):
				player.job_change(path)
			for e in enemies:
				e.queue_free()
			enemies.clear()
			_grid_fresh = false
			_rebuild_grid()
			for i in 8:
				var a: = TAU * i / 8.0
				var e: = spawn_enemy("poring", player.position + Vector3(cos(a) * 3.0 + 3.0, 0, sin(a) * 2.0), true)
				if e != null:
					e.max_hp = 99999.0
					e.hp = 99999.0
					e.speed = 0.0
			await wait.call(0.2)
			player.skills.clear()
			player.skills[id] = {"level": 3, "cd": 999.0}
			player.spheres = 5
			_rebuild_grid()
			Skills.cast(self, player, id, 3)
			await wait.call(float(GameData.SKILLS[id].get("tour_wait", 0.3)))
			await _tour_shot("%s_%s" % [class_id, id])

			await wait.call(0.9)
			await _tour_shot("%s_%s_b" % [class_id, id])
			await wait.call(1.2)
			await _tour_shot("%s_%s_c" % [class_id, id])
			await wait.call(0.6)
	get_tree().quit()









func _storefilter_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	Save.storage().clear()
	var per: = {}
	var n: = 0
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		var sl: = str(d.get("slot", ""))
		if sl == "" or d.get("legendary", false) or int(per.get(sl, 0)) >= 6:
			continue
		per[sl] = int(per.get(sl, 0)) + 1
		var it: = Equipment.make(str(id), 3)
		it["uid"] = "sf_%d" % n
		if n % 5 == 0:
			it["fav"] = true
		if n % 7 == 0:
			it["lock"] = true
		Save.storage().append(it)
		n += 1
	menus.show_loadout("swordsman")
	await wait.call(0.6)
	print("STOREF all=%d shown=%d" % [n, menus._store_shown().size()])
	await _tour_shot("store_all")
	menus._store_group = "fav"
	menus.show_loadout("swordsman")
	await wait.call(0.4)
	print("STOREF fav shown=%d" % menus._store_shown().size())
	await _tour_shot("store_fav")
	menus._store_slot = "weapon"
	menus.show_loadout("swordsman")
	await wait.call(0.4)
	print("STOREF fav+weapon shown=%d" % menus._store_shown().size())
	await _tour_shot("store_fav_weapon")
	menus._store_group = ""
	menus._store_fav_mode = true
	menus.show_loadout("swordsman")
	await wait.call(0.4)
	print("STOREF weapon shown=%d" % menus._store_shown().size())
	await _tour_shot("store_weapon_favmode")
	menus._store_fav_mode = false
	menus._store_slot = ""
	menus.show_refiner()
	await wait.call(0.5)
	await _tour_shot("refiner")

	var cards: = GameData.CARDS.keys().filter( func(c): return not GameData.CARDS[c].get("mvp", false))
	var with_cards: = 0
	for it in Save.storage():
		if with_cards >= 4:
			break
		if str(Equipment.item_def(it).get("slot", "")) in ["armor", "garment"]:
			it["extra_slots"] = 2
			it["eternal"] = [str(cards[0]), str(cards[1])]
			with_cards += 1
	menus._socket_uid = str(Save.storage().filter( func(it): return it.has("eternal"))[0].uid)
	menus._store_group = "eternal"
	Save.add_zeny(100000)
	var z0: = Save.zeny()
	menus.show_socket()
	await wait.call(0.5)
	await _tour_shot("socket_out_buttons")
	menus._confirm_eternal_out([Save.storage_item(menus._socket_uid)])
	await wait.call(0.4)
	await _tour_shot("socket_out_confirm_one")
	menus._confirm_eternal_out(menus._store_shown())
	await wait.call(0.4)
	await _tour_shot("socket_out_confirm_list")
	menus.show_socket()
	await wait.call(0.3)
	menus._eternal_out_all(menus._store_shown())
	await wait.call(0.4)
	await _tour_shot("socket_out_done")
	print("STOREF eternal out: left=%d paid=%d" % [Save.storage().filter( func(it): return not (it.get("eternal", []) as Array).is_empty()).size(), z0 - Save.zeny()])
	print("STOREF bare has fav=%s" % Trade._bare({"id": "x", "fav": true}).has("fav"))
	get_tree().quit()




func _bscut_test() -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	start_run("thief")
	player.max_hp = 99999.0
	player.hp = 99999.0
	player.skills["back_stab_x"] = {"level": 1, "cd": 99.0}
	print("BSCUT recipe=%s" % GameData.EVOLUTIONS.back_stab.passive)
	for cut in [false, true]:
		for e in enemies.duplicate():
			e.queue_free()
		enemies.clear()
		var row: Array = []
		for i in 10:
			var e: = spawn_enemy("poring", player.position + Vector3(2.0 + 1.5 * i, 0, 0), true)
			e.speed = 0.0
			e.max_hp = 1000000000.0
			e.hp = 1000000000.0
			row.append(e)
		_rebuild_grid()
		player._last_stick = Vector2(1, 0)
		player.skill_off.clear()
		blink_chain(player, GameData.SKILLS.back_stab_x, 10.0, 0.01, 10, 9.0)
		await wait.call(0.3)
		if cut:
			hero_skill_switch(player, "back_stab_x", true)
			print("BSCUT after F: x=%.1f blinking=%.2f off=%s stabbed=%d" % [player.position.x, player.blinking, player.is_off("back_stab_x"), row.filter( func(e): return is_instance_valid(e) and e.hp < 1000000000.0).size()])
		await wait.call(1.5)
		print("BSCUT cut=%s stabbed=%d of 10 blinking=%.2f x=%.1f" % [cut, row.filter( func(e): return is_instance_valid(e) and e.hp < 1000000000.0).size(), player.blinking, player.position.x])
	get_tree().quit()


func _asura_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	start_run("acolyte")
	player.max_hp = 99999.0
	player.hp = 99999.0
	player.skills["asura_strike"] = {"level": 5, "cd": 99.0}
	player.effects["lg_asura_echo"] = 0.5
	menus.auto_pick = true
	for i in 220:
		var a: = TAU * randf()
		var e: = spawn_enemy("poring", player.position + Vector3(cos(a), 0, sin(a)) * randf_range(1.0, 6.0), true)
		if e != null:
			e.speed = 0.0
	_rebuild_grid()
	await wait.call(0.5)
	for round_i in 2:
		var worst: = 0
		var frames: = 0
		Skills.cast(self, player, "asura_strike", 5)
		var t0: = Time.get_ticks_msec()
		var last: = Time.get_ticks_usec()
		while Time.get_ticks_msec() - t0 < 4500:
			await get_tree().process_frame
			var now: = Time.get_ticks_usec()
			worst = maxi(worst, now - last)
			if now - last > 40000:
				print("SLOW frame=%d ms=%.1f t=%d" % [frames, (now - last) / 1000.0, Time.get_ticks_msec() - t0])
			last = now
			frames += 1
			if Time.get_ticks_msec() - t0 >= 3750 and not has_meta("echo_shot_%d" % round_i):
				set_meta("echo_shot_%d" % round_i, true)
				await _tour_shot("asura_echo_%d" % round_i)
			if frames == 30:
				await _tour_shot("asura_%d" % round_i)
		print("ASURA round=%d worst_frame_ms=%.1f frames=%d enemies_left=%d" % [round_i, worst / 1000.0, frames, enemies.size()])
		for i in 220 - enemies.size():
			var a: = TAU * randf()
			var e: = spawn_enemy("poring", player.position + Vector3(cos(a), 0, sin(a)) * randf_range(1.0, 6.0), true)
			if e != null:
				e.speed = 0.0
		_rebuild_grid()
		player.skills.asura_strike.cd = 99.0
		await wait.call(0.5)
	get_tree().quit()




func _towerpace_test() -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	start_run("swordsman")
	await wait.call(1.0)
	player.level = 45
	player.job_change(0)
	player.pending_levels = 0
	player.skills["bash"] = {"level": 10, "cd": 0.0}
	player.skills["magnum_break"] = {"level": 10, "cd": 0.0}
	Save.unlock_tower()
	Save.add_tower_build(RunSave.hero_snapshot(self))
	abandon_run()
	start_tower(Save.tower_builds().size() - 1, 1)
	await wait.call(1.0)
	player.altar_mods["dmg"] = 80.0
	player.recompute()
	GameData.set_meta("tour_god", true)
	autopilot = true
	menus.auto_pick = true
	var last: = 1
	var t0: = time
	for i in 400:
		await wait.call(0.25)
		if tower != null and tower.floor != last:
			print("TOWERPACE floor %d took %.1f s" % [last, time - t0])
			last = tower.floor
			t0 = time
			if last > 5:
				break
	get_tree().quit()




func _feat_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	enter_town("swordsman")
	await wait.call(1.5)
	channel.feat("refine", "blade", 10)
	await wait.call(0.6)
	channel.feat("socket", "excalibur", 2)
	await wait.call(0.8)
	await _tour_shot("feat_0")
	print("FEAT lines=%s" % [channel.lines.slice(-2)])
	get_tree().quit()





func _festival_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	start_run("swordsman")
	await wait.call(1.0)
	player.skills["bash"] = {"level": 10, "cd": 0.0}
	player.skills["magnum_break"] = {"level": 8, "cd": 0.0}
	player.level = 45
	player.job_change(0)
	player.pending_levels = 0
	Save.add_tower_build(RunSave.hero_snapshot(self))
	abandon_run()
	enter_town("swordsman")
	await wait.call(1.0)
	town.hero.position = town._at(Vector2i(168, 182))
	await wait.call(0.8)
	await _tour_shot("fest_0_town")
	menus.show_teleporter("swordsman")
	await wait.call(0.4)
	await _tour_shot("fest_1_nearq")

	var names: = ["Kirhi", "NickSeagull", "Feigngod", "Lehinart", "Zemp", "John Xina", "Invadertim"]
	var top: = []
	for i in names.size():
		top.append({"rank": i + 1, "name": names[i], "tag": "#%04X" % (4096 + i * 1337), "class": GameData.CLASSES.keys()[i % GameData.CLASSES.size()], 
			"score": 98000000 - i * 9100000, "mvps": 22 - i, "look": {"build": "Lord Knight  ·  Nv 120"}, "me": i == 4})
	board._cache["all|emperium_festival"] = {"month": "2026-11", "days_left": 22, "total": 57, "top": top, 
		"me": {"rank": 5, "score": 61600000, "mvps": 18, "class": "swordsman"}, "_at": Time.get_ticks_msec() + 10000000}
	menus.show_festival()
	await wait.call(2.5)
	await _tour_shot("fest_2_window")
	menus._builds_manager()
	await wait.call(0.4)
	await _tour_shot("fest_3_builds")
	menus._confirm_build_delete(Save.tower_builds().back(), func(): pass)
	await wait.call(0.4)
	await _tour_shot("fest_4_delete")
	menus.close()
	start_festival(Save.tower_builds().size() - 1)
	await wait.call(3.0)
	await _tour_shot("fest_5_prep")
	menus.show_festival_ready(festival)
	await wait.call(1.2)
	await _tour_shot("fest_5b_ready")
	menus.close()
	print("FEST state=%s map=%s hero=%s spot_walk=%s lv=%d" % [festival.state, stage.map, player.position, map.is_walkable(player.position), player.level])
	festival.begin()
	await wait.call(2.2)
	await _tour_shot("fest_6_count")
	await wait.call(3.3)
	player.position = festival._spot + Vector3(3.5, 0, 2.5)
	await wait.call(0.8)
	await _tour_shot("fest_6b_first")
	_cam_distance = 10.0
	await wait.call(0.6)
	await _tour_shot("fest_6c_close")
	_cam_distance = 42.0
	var vm: Node = festival.emperium.visual
	for c in vm.get_children():
		print("FEST vis child ", c, " vis=", (c as Node3D).visible if c is Node3D else "-", " gscale=", (c as Node3D).global_transform.basis.get_scale() if c is Node3D else Vector3.ZERO)
	print("FEST emp visual=%s children=%d" % [festival.emperium.visual, (festival.emperium.visual as Node).get_child_count() if festival.emperium != null else -1])
	autopilot = true
	menus.auto_pick = true

	player.altar_mods["dmg"] = 60.0
	player.recompute()
	await wait.call(8.0)
	await _tour_shot("fest_7_fight")
	print("FEST fight checks=%d score=%.0f left=%.1f" % [festival.checks, festival.score(), festival.left])
	festival.left = 0.5
	await wait.call(3.5)
	await _tour_shot("fest_8_result")
	print("FEST end checks=%d score=%.0f mode=%s" % [festival.checks, festival.banked, menus.mode()])
	menus.close()
	leave_training()
	await wait.call(2.0)
	await _tour_shot("fest_9_back")
	print("FEST back town=%s map=%s w=%d h=%d hero=%s" % [town != null, map.map_name, map.width, map.height, town.hero.position if town != null else Vector3.ZERO])
	get_tree().quit()






func _festskills_test(only_class: = "") -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	Engine.time_scale = 3.0
	var done: = {}
	var bad: = []
	for class_id in GameData.CLASSES:
		if only_class != "" and class_id != only_class:
			continue
		var d: Dictionary = GameData.CLASSES[class_id]
		var paths: Array = GameData.job_paths(class_id)
		for path in maxi(1, paths.size()):
			start_run(class_id)
			await wait.call(0.5)
			player.reborn = true
			if not paths.is_empty():
				player.job_change(path)
			player.pending_levels = 0
			player.level = 120
			player.recompute()
			var ids: Array = (d.skills as Array).duplicate()
			if not paths.is_empty():
				var job: Dictionary = paths[path]
				ids += job.skills
				if job.has("trans"):
					ids += job.trans.get("skills", [])
			for id in ids.duplicate():
				if GameData.EVOLUTIONS.has(id):
					ids.append(str(GameData.EVOLUTIONS[id].to))
			for id in ids:
				if done.has(id) or not GameData.SKILLS.has(id) or GameData.SKILLS[id].get("type", "") in ["heal", "passive"]:
					continue
				done[id] = true
				var got: = []
				var keys: = {}
				for dist in [2.2, 5.0]:
					for emp in [true, false]:
						for e in enemies:
							e.queue_free()
						enemies.clear()
						_zones.clear()
						_grid_fresh = false
						_rebuild_grid()
						var at: = player.position + Vector3(dist, 0, 0)
						var e: Enemy = spawn_enemy("item_emperium" if emp else "poring", at, true)
						if e == null:
							got.append(-1.0)
							continue
						e.set_meta("steady", true)
						e.is_boss = true
						e.speed = 0.0
						e.max_hp = 1e+15
						e.hp = e.max_hp
						if emp:
							e.set_meta("festival", true)
							e._static = true
							e._immovable = true
						player.max_hp = 1000000000.0
						player.hp = player.max_hp
						player.spheres = 5
						player.skills.clear()
						player.skills[id] = {"level": 5, "cd": 0.0}
						reset_meter()
						await wait.call(3.0)
						var dealt: = 0.0
						for k in meter:
							if not str(k) in ["attack", "basic", "auto", ""]:
								dealt += float((meter[k] as Dictionary).get("dmg", 0.0))
								keys[str(k)] = true
						got.append(dealt)
				var line: = "FESTSKILL %s/%s %-22s near emp=%.0f poring=%.0f | far emp=%.0f poring=%.0f" % [class_id, path, id, got[0], got[1], got[2], got[3]] + " " + str(keys.keys())
				print(line)
				if (got[1] > 0.0 and got[0] <= 0.0) or (got[3] > 0.0 and got[2] <= 0.0) or (got[1] > 0.0 and got[0] < got[1] * 0.3) or (got[3] > 0.0 and got[2] < got[3] * 0.3):
					bad.append(line)
			abandon_run()
			await wait.call(0.3)
	print("FESTSKILL ---- suspicious: %d" % bad.size())
	for l in bad:
		print("FESTBAD ", l)
	get_tree().quit()






func _titles_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	Save.set_setting("titles_special", [{"title": "golden_poring", "proof": "x"}, {"title": "angeling", "proof": "v"}, {"title": "naght_bane", "proof": "y"}, {"title": "cm", "proof": "z"}, {"title": "dev", "proof": "w"}])
	for id in ["lightning", "untouchable", "bare"]:
		Save.mark_seen("titles", id)
	Save.mark_seen("title_hell_classes", "swordsman")
	Save.mark_seen("title_hell_classes", "mage")
	titles.set_active("cm")

	Save.set_setting(titles.SUPPORT_KEY, "angeling")
	print("TITLES owned=%s active=%s news=%s" % [titles.owned(), titles.active(), titles.news()])

	menus.show_class_select()
	await wait.call(0.8)
	for c in get_children():
		if c.has_method("_toggle_card") and c.get("COFFEE_URL") != null:
			c._toggle_card()
	await wait.call(0.8)
	await _tour_shot("support")
	menus.close()
	menus.show_char_make("swordsman")
	await wait.call(0.5)
	await _tour_shot("profile")
	menus.show_titles()
	await wait.call(0.6)
	await _tour_shot("picker")

	for sc in menus.find_children("*", "ScrollContainer", true, false):
		(sc as ScrollContainer).scroll_vertical = 330
	await wait.call(0.3)
	await _tour_shot("picker_locked")
	menus.close()

	for tab in ["ropa", "auras", "name", "titles"]:
		menus.show_closet("swordsman", tab)
		await wait.call(0.8)
		await _tour_shot("closet_" + tab)
		menus.close()

	var w: Dictionary = menus._float_window("chips")
	for id in GameData.TITLES:
		var r: = HBoxContainer.new()
		r.add_theme_constant_override("separation", 8)
		r.add_child(titles.chip(str(id), 9))
		r.add_child(titles.chip(str(id), 12))
		w.body.add_child(r)
	menus._float_show(w, null)
	await wait.call(0.5)
	await _tour_shot("chips")
	w.shut.call()
	enter_town("swordsman")
	await wait.call(2.5)
	var ids: = ["cm", "angeling", "tower_150", "golden_poring", "emperium"]
	var classes: = ["mage", "archer", "acolyte", "thief", "merchant"]
	var list: = []
	for i in ids.size():
		list.append({"id": - (10 + i), "name": "Tester%d" % i, "class": classes[i], "look": {}, "views": {}, "party": false, 
			"at": town.hero.position + Vector3(-5.0 + 2.5 * i, 0, 2.5 + (i % 2) * 1.5), "rb": [], "ra": false, "pet": "", "title": ids[i], 

			"sup": ["", "angeling", "", "golden_poring", ""][i]})
	town.sync_channel(list)
	channel.log_line("all", "Godar : hola a todos", "cm")
	channel.log_line("all", "Tester3 : gg", "hell_trio", "golden_poring")
	channel.log_line("all", "Tester1 : vamos a la torre?", "", "angeling")

	town._crowd._log.visible = true
	town._crowd._log._refresh()
	await wait.call(2.5)
	await _tour_shot("town")

	town._crowd._log.visible = false
	_cam_distance = 18.0
	await wait.call(1.5)
	await _tour_shot("aura_1")
	await wait.call(0.9)
	await _tour_shot("aura_2")
	_cam_distance = 42.0
	await wait.call(0.5)

	var ws = load("res://scripts/ui/world_select.gd").new()
	ws.set("world", self)
	var bw: Dictionary = menus._float_window("boards")
	for r in [{"rank": 1, "name": "Tester3", "tag": "#A1B2", "class": "thief", "score": 123456, "sup": "golden_poring", "title": "tower_150"}, 
			{"rank": 2, "name": "Tester1", "tag": "#C3D4", "class": "archer", "score": 98765, "sup": "angeling"}, 
			{"rank": 3, "name": "Otro", "tag": "#E5F6", "class": "mage", "score": 54321}]:
		var row: Control = ws._record_row(r)
		row.custom_minimum_size.x = 360
		bw.body.add_child(row)
	menus._float_show(bw, null)
	await wait.call(0.6)
	await _tour_shot("boards")
	get_tree().quit()





func _autoequip_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	Save.storage().clear()
	Save.loadouts().clear()

	var by_slot: = {}
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		if d.get("legendary", false) or d.get("fixed", false) or not d.has("slot"):
			continue
		var it: = Equipment.make(str(id), 3)
		if not (menus._class_can_use("swordsman", it) and menus._class_can_use("archer", it)):
			continue
		var s: = str(d.slot)
		if int(by_slot.get(s, 0)) >= 2:
			continue
		by_slot[s] = int(by_slot.get(s, 0)) + 1
		it["uid"] = "t_%s_%d" % [id, by_slot[s]]
		Save.storage().append(it)
		if by_slot[s] == 1 and s != "acc":
			Save.set_loadout_slot("archer", s, str(it.uid))
	var archer_before: = Save.loadout("archer").duplicate()
	print("AUTOEQ archer before: ", archer_before)
	menus.show_loadout("swordsman")
	await wait.call(0.3)
	menus._loadout_auto_ask("swordsman")
	await wait.call(0.3)
	await _tour_shot("ask")
	print("AUTOEQ plan all: ", menus._loadout_auto_plan("swordsman", true))
	print("AUTOEQ plan free: ", menus._loadout_auto_plan("swordsman", false))

	var yes: Button = null
	for b in menus._root.find_children("*", "Button", true, false):
		if (b as Button).text == tr("Equipar igual"):
			yes = b
	yes.pressed.emit()
	await wait.call(0.3)
	await _tour_shot("after")
	print("AUTOEQ sword: ", Save.loadout("swordsman"), " archer: ", Save.loadout("archer"))
	for b in menus._root.find_children("*", "Button", true, false):
		if (b as Button).text == tr("Deshacer"):
			(b as Button).pressed.emit()
			break
	await wait.call(0.3)
	print("AUTOEQ undo sword: ", Save.loadout("swordsman"), " archer: ", Save.loadout("archer"), " same=", Save.loadout("archer") == archer_before)
	get_tree().quit()



func _tips_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	for i in 4:
		if "--last" in OS.get_cmdline_user_args():
			menus.set_meta("force_tip", GameData.LOADING_TIPS.size() - 1 - i)
		menus.show_loading( func(): pass)
		await wait.call(0.4)
		await _tour_shot("tip_%d" % i)
		print("TIPS %d: %s" % [i, GameData.LOADING_TIPS[menus._last_tip][0]])
	get_tree().quit()








func _skillbench() -> void :
	var args: = OS.get_cmdline_user_args()
	var at: = args.find("--skillbench")
	var class_id: = str(args[at + 1])
	var ids: = []
	for a in args.slice(at + 2):
		if str(a).begins_with("--"):
			break
		ids.append(str(a))
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	GameData.set_meta("tour_god", true)
	GameData.set_meta("mvp_at", 1000000000.0)
	GameData.set_meta("morroc_at", 1000000000.0)
	start_run(class_id)
	await wait.call(0.5)
	for spec in ids:

		var id: = str(spec).get_slice("+", 0)
		player.skills.clear()
		for sid in str(spec).split("+"):
			player.skills[sid] = {"level": 1 if GameData.SKILLS[sid].get("evolved", false) else GameData.MAX_SKILL_LEVEL, "cd": 0.0}
		player.recompute()
		run_zeny = 1000000
		for e in enemies.duplicate():
			e.queue_free()
		enemies.clear()
		var spots: = {}
		for i in 16:
			var a: = TAU * i / 16.0
			var e: = spawn_enemy("lunatic", player.position + Vector3(cos(a), 0, sin(a)) * (2.0 + (i % 2) * 1.2), true)
			if e != null:
				e.max_hp = 1000000000000.0
				e.hp = 1000000000000.0
				e.speed = 0.0
				spots[e] = e.position
		_rebuild_grid()
		meter.clear()
		var t0: = time
		Engine.time_scale = 3.0
		while time - t0 < 30.0:
			await get_tree().process_frame

			for e in spots:
				if is_instance_valid(e):
					e.position = spots[e]
		Engine.time_scale = 1.0
		var total: = 0.0
		for r in meter_sorted():
			total += float(r.dmg)
		print("SKILLBENCH %s %s total=%d" % [class_id, spec, roundi(total)])
	get_tree().quit()







func _sagebench(dir: String) -> void :
	_shot_dir = dir
	var args: = OS.get_cmdline_user_args()
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	GameData.set_meta("tour_god", true)
	GameData.set_meta("mvp_at", 1000000000.0)
	GameData.set_meta("morroc_at", 1000000000.0)
	if "--reborn" in args:
		Save.data.rebirths["mage"] = 1
	start_run("mage")
	await wait.call(0.5)
	var path: = int(args[args.find("--path") + 1]) if args.has("--path") else 0
	player.level = 70
	player.job_change(path)
	if "--old" in args:
		player.job2 = player.job2.duplicate()
		player.job2["dmg_bonus"] = 0.27 if player.reborn else 0.12
		player.job2["passives"] = ["advanced_book", "hindsight"]
	player.skills.clear()
	var pool: Array = player.skill_pool().duplicate()
	pool.reverse()
	for id in pool:
		if Player.is_passive(id) or GameData.SKILLS[id].type in ["buff", "shield", "heal", "summon"]:
			continue
		if player.count_skills(false) >= player.max_skills():
			break
		player.skills[id] = {"level": GameData.MAX_SKILL_LEVEL, "cd": 0.0}
		if GameData.EVOLUTIONS.has(id):
			var to: = str(GameData.EVOLUTIONS[id].to)
			player.skills.erase(id)
			player.skills[to] = {"level": GameData.MAX_SKILL_LEVEL, "cd": 0.0}
	for id in player.job2.get("passives", []):
		player.skills[id] = {"level": GameData.MAX_SKILL_LEVEL, "cd": 0.0}
	player.stats["int"] = 80
	player.stats["dex"] = 30
	player.recompute()
	player.max_hp = 1000000000.0
	player.hp = 1000000000.0
	var dummies: = []
	for c in 3:
		var center: = player.position + Vector3(cos(TAU * c / 3.0), 0, sin(TAU * c / 3.0)) * 6.0
		for i in 8:
			var e: = spawn_enemy("lunatic", center + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)), true)
			if e != null:
				e.max_hp = 1000000000000.0
				e.hp = 1000000000000.0
				e.speed = 0.0
				dummies.append(e)
	_rebuild_grid()
	meter.clear()
	var t0: = time
	Engine.time_scale = 3.0
	while time - t0 < 60.0:
		await get_tree().process_frame
		player.hp = player.max_hp
	Engine.time_scale = 1.0
	var total: = 0.0
	var rows: = []
	for r in meter_sorted():
		total += float(r.dmg)
		rows.append("%s=%d" % [r.tag, roundi(r.dmg)])
	print("SAGEBENCH job=%s old=%s skills=%s dmg_bonus=%s double=%.3f total=%d" % [player.job2.get("id", ""), "--old" in args, 
		player.skills.keys(), player.job2.get("dmg_bonus", 0.0), player.double_cast_chance("earth_spike_x"), roundi(total)])
	print("SAGEBENCH rows=%s" % [rows])
	get_tree().quit()






func _padnav_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	var pad: Node = get_meta("gamepad")
	pad.set("test_pad", true)
	(pad.get("hints") as Node).set_pad(true, "Xbox Series Controller")
	var btn: = func(b: int):
		for on in [true, false]:
			var e: = InputEventJoypadButton.new()
			e.button_index = b
			e.pressed = on
			Input.parse_input_event(e)
			await get_tree().process_frame
			await get_tree().process_frame
	var mouse_to: = func(at: Vector2):
		var m: = InputEventMouseMotion.new()
		m.position = at
		m.global_position = at
		Input.parse_input_event(m)
		await get_tree().process_frame
	var named: = func(c) -> String:
		if c == null or not is_instance_valid(c):
			return "<none>"
		return "%s %s" % [c.get_class(), str(c.get("text")) if c is Button else str(c.get_path()).get_file()]

	start_run("swordsman")
	await wait.call(1.5)
	await mouse_to.call(Vector2(DisplayServer.window_get_size()) * 0.5)
	await wait.call(0.3)
	player.pending_levels = 1
	await wait.call(2.0)
	var cards: Array = menus._cards.duplicate()
	var focus: = get_viewport().gui_get_focus_owner()
	print("PADNAV levelup mode=%s cards=%d focus_is_first=%s start_is_first=%s" % [menus.mode(), cards.size(), focus == cards[0], pad.call("_start") == cards[0]])
	await _tour_shot("1_levelup")
	var e: = InputEventJoypadButton.new()
	e.button_index = JOY_BUTTON_A
	e.pressed = true
	Input.parse_input_event(e)
	await get_tree().process_frame
	print("PADNAV A on first card: ", pad.get("_nav_last") == cards[0])
	e = InputEventJoypadButton.new()
	e.button_index = JOY_BUTTON_A
	Input.parse_input_event(e)
	await wait.call(0.5)
	print("PADNAV after A mode=", menus.mode())
	menus.close()
	get_tree().paused = false

	Save.storage().clear()
	var n: = 0
	for id in GameData.ITEMS:
		var d: Dictionary = GameData.ITEMS[id]
		if d.get("legendary", false) or not d.has("slot") or n >= 14:
			continue
		var it: = Equipment.make(str(id), 3)
		it["uid"] = "pad_%d" % n
		Save.storage().append(it)
		n += 1
	menus.show_loadout("swordsman")
	await wait.call(0.5)
	print("PADNAV loadout focus: ", named.call(get_viewport().gui_get_focus_owner()))
	var reached: = {}
	var steps: = [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_DOWN]
	for k in steps.size():
		await btn.call(steps[k])
		var on = pad.get("_nav_last")
		print("PADNAV loadout step %d: %s" % [k, named.call(on)])
		if on != null:
			reached[on.get_class()] = true
		if k == 8:
			await _tour_shot("2_loadout_cell")
	print("PADNAV loadout reached: ", reached.keys())

	pad.set("_mobile", true)
	await wait.call(0.4)
	await mouse_to.call(Vector2(DisplayServer.window_get_size()) * Vector2(0.3, 0.55))
	await wait.call(0.3)
	await _tour_shot("3_mobile_pointer")
	pad.set("_mobile", false)
	menus.close()

	Save.add_zeny(5000000)
	menus.show_kafra()
	await wait.call(0.5)
	print("PADNAV kafra focus=%s start=%s" % [named.call(get_viewport().gui_get_focus_owner()), named.call(pad.call("_start"))])
	await btn.call(JOY_BUTTON_DPAD_DOWN)
	print("PADNAV kafra after down: ", named.call(pad.get("_nav_last")))
	await _tour_shot("4_kafra")
	get_tree().quit()


func _padhints_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	var hints: Node = (get_meta("gamepad") as Node).get("hints")
	hints.set_pad(true, "PS5 Controller" if "--ps" in OS.get_cmdline_user_args() else "Xbox Series Controller")
	var t: = TranslationServer.get_translation_object("en")
	var seen: = 0
	for id in t.get_message_list():
		var src: = str(id)
		var out: String = hints.convert_text(src)
		if out != src:
			seen += 1
			print("PADH %s  =>  %s" % [src, out])
	print("PADH changed %d" % seen)
	start_run("archer")
	await wait.call(1.5)
	await _tour_shot("pad_hud")
	menus.show_pause()
	await wait.call(0.6)
	await _tour_shot("pad_pause")
	menus.close()
	get_tree().paused = false
	player.pending_levels = 1
	await wait.call(1.5)
	await _tour_shot("pad_levelup")
	hints.set_pad(false)
	await wait.call(0.3)
	await _tour_shot("pad_levelup_keys")
	get_tree().quit()


func _train_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	enter_town("swordsman")
	await wait.call(1.0)
	town.hero.position = town._at(Vector2i(168, 182))
	await wait.call(0.8)
	await _tour_shot("train_town")
	menus.show_teleporter("swordsman")
	await wait.call(0.4)
	await _tour_shot("train_npc")
	menus.auto_pick = true

	Save.storage().clear()
	var stored_n: = 0
	for id in GameData.ITEMS:
		var sd: Dictionary = GameData.ITEMS[id]
		if str(sd.get("slot", "")) == "" or sd.get("legendary", false) or stored_n >= 30:
			continue
		var sit: = Equipment.make(str(id), 3)
		sit["uid"] = "tr_%d" % stored_n
		sit["refine"] = 7
		Save.storage().append(sit)
		stored_n += 1
	menus._start_training("swordsman")
	await wait.call(4.0)
	menus.close()
	get_tree().paused = false
	print("TRAIN running=%s training=%s stage=%s enemies=%d bag=%d" % [running, training, stage_id, enemies.size(), player.equipment.bag.size()])
	training_dummies(1)
	await wait.call(0.2)
	var home: Vector3 = enemies[0].position if not enemies.is_empty() else Vector3.ZERO
	for e in enemies:
		e.knock += Vector3(30, 0, 0)
	await wait.call(3.8)
	await _tour_shot("train_one")
	print("TRAIN dummy moved=%.3f" % (enemies[0].position.distance_to(home) if not enemies.is_empty() else -1.0))

	if not enemies.is_empty():
		for k in 9:
			number(enemies[0].position, str(3000000 + k * 137911), Color(1, 0.85, 0.2), true, k % 3 == 0, false, 1.4)
			await wait.call(0.07)
		await _tour_shot("train_spam")
		await wait.call(0.4)
		await _tour_shot("train_spam_b")
	print("TRAIN one dps=%.1f enemies=%d dummy_hp_ok=%s" % [float(meter_stats.get("total", 0.0)) / meter_time(), enemies.size(), str(enemies.all( func(e): return e.hp > 0.0))])
	reset_meter()
	training_dummies(GameData.TRAINING_GROUP)
	await wait.call(4.0)
	await _tour_shot("train_group")
	print("TRAIN group enemies=%d dps=%.1f" % [enemies.size(), float(meter_stats.get("total", 0.0)) / meter_time()])
	var seen_n: = 0
	for id in GameData.ITEMS:
		seen_n += 1
		if seen_n % 3 == 0 or GameData.ITEMS[id].get("legendary", false):
			Save.mark_seen("items", id)
	menus.show_armory()
	await wait.call(0.5)
	await _tour_shot("train_armory")
	menus._arm.text = "crit"
	menus._armory_fill()
	await wait.call(0.3)
	await _tour_shot("train_armory_search")
	menus._arm.text = ""
	menus._arm.rarity = "legendary"
	menus._arm.slot = "acc"
	menus._armory_fill()
	await wait.call(0.3)
	await _tour_shot("train_armory_filter")
	print("TRAIN armory rows=%d %s" % [menus._arm_list.get_child_count(), menus._arm_count.text])
	menus._armory_take("embryo")
	print("TRAIN took ", menus._arm_msg.text, " acc=", player.equipment.slots.get("acc1"), player.equipment.slots.get("acc2"))

	menus._arm.rarity = ""
	menus._arm.slot = ""
	menus._arm.src = "own"
	menus.show_armory()
	await wait.call(0.4)
	await _tour_shot("train_armory_own")
	var own_before: = World.training_own_items(player).size()
	var bag_before: = player.equipment.bag.size()
	var first: Dictionary = World.training_own_items(player)[0]
	menus._armory_take_own(first)
	await wait.call(0.3)
	await _tour_shot("train_armory_own_took")
	print("TRAIN own %d -> %d bag %d -> %d max=%d msg=%s" % [own_before, World.training_own_items(player).size(), bag_before, player.equipment.bag.size(), player.equipment.bag_max, menus._arm_msg.text])
	menus._arm.src = "armory"
	menus._resume()
	await wait.call(0.3)
	var lv: = player.level
	training_levels(10)
	await wait.call(0.5)
	print("TRAIN levels %d -> %d pending=%d" % [lv, player.level, player.pending_levels])

	var sk: = player.skills.size()
	training_levels(10, true)
	await wait.call(2.0)
	print("TRAIN auto levels -> %d pending=%d skills %d -> %d" % [player.level, player.pending_levels, sk, player.skills.size()])

	player.album_cards.append_array(["hornet_card", "argiope_card"])
	player.recompute()
	menus.show_status()
	await wait.call(0.3)
	await _tour_shot("train_status")
	print("TRAIN procs ", player.proc_summary())
	menus.close()
	get_tree().paused = false

	training_dummies(1)
	reset_meter()
	player.effects["poison_hit"] = 0.25
	await wait.call(6.0)
	print("TRAIN poison stacks=%d meter=%s" % [enemies[0].poison_stacks if not enemies.is_empty() else -1, str(meter.keys().map( func(k): return "%s=%d" % [k, roundi(float(meter[k].get("dmg", meter[k].get("total", 0.0))))]))])
	var mob: = spawn_enemy("poring", player.position + Vector3(-4, 0, -2), true)
	mob.max_hp = 100000.0
	mob.hp = mob.max_hp
	damage_tag = "poison"
	damage_by = player
	for n in 40:
		apply_poison(mob, 10.0, 6.0)
	await wait.call(0.3)
	await _tour_shot("train_poison")
	await wait.call(0.75)
	print("TRAIN poison 40 stacks on 100k hp: lost=%d" % roundi(mob.max_hp - mob.hp))
	menus.close()
	get_tree().paused = false
	training_clear()
	await wait.call(0.5)
	print("TRAIN cleared enemies=%d" % enemies.size())
	leave_training()
	await wait.call(2.0)
	print("TRAIN back town=%s running=%s training=%s" % [str(town != null), running, training])
	await _tour_shot("train_back")
	get_tree().quit()




func _fxprobe_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	_job_test_start("mage", [])
	for fx in ["stormgust", "meteor1", "lord", "thunderstorm"]:
		spawn_fx(fx, player.position + Vector3(3, 0, 0), GameData.AOE_FX_MAX, 0.5)
		for k in 3:
			await wait.call(0.25)
			await _tour_shot("probe_%s_%d" % [fx, k])
		await wait.call(1.5)
	get_tree().quit()



func _revive_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	menus.auto_pick = true
	start_run("swordsman")
	menus.close()
	get_tree().paused = false
	await wait.call(1.5)
	player.revives = 1
	player._invuln = 0.0
	player.take_damage(1000000000.0, self, null, true)
	for t in [0.15, 0.5, 1.0]:
		await wait.call(0.2 if t == 0.15 else 0.4)
		await _tour_shot("revive_%d" % roundi(t * 100.0))
	get_tree().quit()







func _downmark_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var shot: = func(label: String):
		await _tour_shot(label)
		var mm: RoMinimap = hud._minimap
		var r: = mm.get_global_rect().grow(10.0)
		var img: = get_viewport().get_texture().get_image().get_region(Rect2i(r))
		img.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
		img.save_png("%s/%s_minimap.png" % [dir, label])
		for h in heroes:
			if h != player and h.downed:
				print("DOWNMARK %s %s at=%s zoom=%.0f revive=%.2f" % [label, h.class_id, mm._mark(h.position, true), mm.zoom, h.revive_t])
	var args: = Array(OS.get_cmdline_user_args())
	if args.any( func(a): return str(a).begins_with("--net-join=")):
		_net_test_join(args)
		for i in 30:
			await wait.call(2.0)
			if running and player != null:
				print("DOWNMARK guest t=%.1f %s" % [time, heroes.map( func(h): return "%s%s" % [h.class_id, " DOWN" if h.downed else ""])])
				await shot.call("guest_%02d" % i)
		get_tree().quit()
		return
	coop_classes.assign(["archer", "acolyte"])
	menus.auto_pick = true
	start_run("swordsman")
	menus.close()
	get_tree().paused = false
	if heroes.size() < 3:
		print("DOWNMARK no party")
		get_tree().quit()
		return
	for h in heroes:
		h.max_hp = 99999.0
		h.hp = h.max_hp
	await wait.call(1.5)
	var fallen: Player = heroes[1]
	fallen.max_hp = 100.0
	fallen.revives = 0
	for i in 50:
		if not fallen.downed:
			fallen._invuln = 0.0
			fallen.take_damage(1000000000.0, self, null, true)

	fallen.position = player.position + Vector3(26, 0, -18)
	heroes[2].position = player.position + Vector3(-4, 0, 3)
	print("DOWNMARK down=%s" % fallen.downed)
	hud._minimap.zoom = 1.0
	await wait.call(0.5)
	await shot.call("1_x1")
	hud._minimap.zoom = 3.0
	fallen.position = player.position + Vector3(55, 0, -35)
	await wait.call(0.3)
	await shot.call("2_x3_edge")
	fallen.position = player.position + Vector3(26, 0, -18)
	hud._minimap.zoom = 1.0
	fallen.revive_t = GameData.COOP_REVIVE_TIME * 0.6
	await wait.call(0.05)
	await shot.call("3_getting_up")

	fallen.position = player.position + Vector3(3, 0, 0)
	await wait.call(0.3)
	await shot.call("4_in_view")
	get_tree().quit()




func _weather_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var shots: = [["prontera", "clear", 10.0], ["prontera", "clear", 140.0], ["prontera", "clear", 190.0], ["prontera", "rain", 20.0], 
		["prontera", "leaves", 20.0], ["payon", "leaves", 20.0], ["payon", "fog", 30.0], ["orc", "storm", 20.0], ["orc", "clouds", 20.0], 
		["glast", "fog", 190.0], ["niflheim", "snow", 20.0]]
	var at: = ""
	for s in shots:
		if str(s[0]) != at:
			at = str(s[0])
			set_stage(at)
			danger = 1
			menus.auto_pick = true
			start_run("swordsman")
			menus.close()
			get_tree().paused = false
			player.max_hp = 99999.0
			player.hp = 99999.0
			await wait.call(1.0)
		weather.kind = str(s[1])
		weather._want = ""
		weather._amount = 1.0
		weather._next = 999.0
		weather.clock = float(s[2])
		weather._bat_t = 0.0
		weather._flash_t = 0.0
		for e in enemies:
			e.hp = 0.0
		player.hp = player.max_hp
		await wait.call(2.5)
		await _tour_shot("wx_%s_%s_%d" % [s[0], s[1], int(s[2])])
	print("WEATHER %s %s" % [weather.badge(), str(weather.night())])
	get_tree().quit()





func _hell_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	Save.data["max_danger"] = GameData.DANGER_MAX
	Save.set_stage_danger(stage_id, GameData.DANGER_MAX)
	menus.show_server_select("swordsman")
	await wait.call(0.8)
	await _tour_shot("hell_select")
	Save.set_stage_danger(stage_id, 21)
	menus.show_server_select("swordsman")
	await wait.call(0.5)
	await _tour_shot("hell_select6")
	danger = GameData.DANGER_MAX
	menus.auto_pick = true
	start_run("swordsman")
	menus.close()
	get_tree().paused = false
	Engine.time_scale = 1.0
	player.max_hp = 99999.0
	player.hp = 99999.0
	time = 40.0
	await wait.call(0.5)
	_hell_ring_spawn()
	await wait.call(0.6)
	await _tour_shot("hell_ring")
	_hell_meteor_fall()
	await wait.call(0.6)
	await _tour_shot("hell_meteor_warn")
	await wait.call(1.0)
	await _tour_shot("hell_meteor")
	_herald_spawn()
	if not _heralds.is_empty():
		_heralds[0].position = player.position + Vector3(3.5, 0, 0)
		_heralds[0].speed = 0.0
	await wait.call(1.2)
	await _tour_shot("hell_herald")
	if not _heralds.is_empty():
		damage_enemy(_heralds[0], 1000000000000.0, Vector3.ZERO, "skill", "neutral", "test")
	await wait.call(0.4)
	await _tour_shot("hell_herald_down")
	_hell_tide = 0.0
	_tick_tide(0.01)
	print("HELL tide=%s rate=%.2f heralds=%s" % [str(hell_tide_on()), _spawn_rate_now(), str(Save.stat("heralds"))])
	var risen: = 0
	for i in 40:
		var e: = spawn_enemy("poring", player.position + Vector3(3, 0, 0), true)
		if e != null:
			_hell_rise_at = -9.0
			e.hp = 1.0
			damage_enemy(e, 99999.0, Vector3.ZERO, "skill", "neutral", "test")
	await wait.call(1.3)
	for e in enemies:
		if e.has_meta("risen"):
			risen += 1
	await _tour_shot("hell_risen")
	print("HELL risen=%d hp=%.1f danger=%s ach=%s" % [risen, GameData.danger_hp(danger, 1.0, true), GameData.danger_name(danger), str(GameData.ACHIEVEMENTS.has("hell_10"))])
	get_tree().quit()




func _job_test_start(class_id: String, skills_in: Array, female: = false) -> void :
	GameData.set_meta("no_spawn", true)
	menus.auto_pick = true
	start_run(class_id)
	menus.close()
	get_tree().paused = false
	Engine.time_scale = 1.0
	player.max_hp = 99999.0
	player.hp = 99999.0
	if female:
		player.appearance["gender"] = "f"
	player.job_change(0)
	player.skills.clear()
	for id in skills_in:
		for k in 5:
			player.add_skill(id)
	player.recompute()
	menus.close()
	get_tree().paused = false


func _test_foes(n: int, r: float, at: Vector3, hp: = 99999.0) -> void :
	for i in n:
		var a: = TAU * i / float(n)
		var e: = spawn_enemy("poring", at + Vector3(cos(a) * r, 0, sin(a) * r), true)
		if e != null:
			e.max_hp = hp
			e.hp = hp
			e.speed = 0.0
	_rebuild_grid()


func _clear_foes() -> void :
	for e in enemies.duplicate():
		if is_instance_valid(e):
			e.hp = 0.0
			e.dead = true
			e.queue_free()
	enemies.clear()
	_rebuild_grid()





func _wiz_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	_job_test_start("mage", ["soul_drain"])
	var c: = player.position + Vector3(4, 0, 0)
	_test_foes(8, 1.5, c)
	await wait.call(0.2)
	Skills.cast(self, player, "storm_gust", 5)
	await wait.call(0.8)
	await _tour_shot("wiz_marks")
	var marked: = enemies.filter( func(e): return e.combo_mark != "").size()
	Skills.cast(self, player, "fire_bolt", 5)
	await wait.call(0.25)
	await _tour_shot("wiz_vapor")
	await wait.call(0.6)
	Skills.cast(self, player, "storm_gust", 5)
	await wait.call(0.7)
	Skills.cast(self, player, "jupitel_thunder", 5)
	await wait.call(0.35)
	await _tour_shot("wiz_conduct")
	await wait.call(0.6)
	Skills.cast(self, player, "fire_bolt", 5)
	await wait.call(0.5)
	Skills.cast(self, player, "lord_of_vermilion", 5)
	await wait.call(0.3)
	await _tour_shot("wiz_blaze")
	print("WIZ marked=%d meter=%s" % [marked, str(meter.get("wiz_combo", 0))])

	_clear_foes()
	_test_foes(14, 2.4, c, 60.0)
	_test_foes(6, 1.0, c, 60.0)
	await wait.call(0.2)
	Skills.cast(self, player, "storm_gust", 1)
	await wait.call(0.5)
	var before: = enemies.size()
	Skills.cast(self, player, "meteor_storm", 5)
	await wait.call(0.5)
	await _tour_shot("wiz_chain")
	await wait.call(0.6)
	print("WIZ horde before=%d after=%d combo=%s" % [before, enemies.filter( func(e): return not e.dead).size(), str(meter.get("wiz_combo", 0))])
	_clear_foes()
	_test_foes(12, 3.5, c)
	await wait.call(0.2)
	Skills.cast(self, player, "quagmire", 5)
	await wait.call(0.8)
	await _tour_shot("wiz_quagmire")
	Skills.cast(self, player, "gravitation_field", 5)
	await wait.call(1.2)
	await _tour_shot("wiz_gravity")
	await wait.call(1.6)
	Skills.cast(self, player, "gravitation_field_x", 1)
	await wait.call(4.85)
	await _tour_shot("wiz_implode")
	_clear_foes()
	_test_foes(10, 2.0, player.position)
	await wait.call(0.2)
	Skills.cast(self, player, "sightrasher_x", 1)
	await wait.call(0.35)
	await _tour_shot("wiz_sightrasher")
	print("WIZ meter=", meter.keys())
	get_tree().quit()




func _sl_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	menus.auto_pick = true
	start_run("taekwon")
	menus.close()
	get_tree().paused = false
	Engine.time_scale = 1.0
	player.max_hp = 99999.0
	player.hp = 99999.0
	player.job_change(1)
	player.skills.clear()
	for id in ["estin", "esma", "eswoo", "kaite", "soul_link", "peaceful_break", "kaahi"]:
		for k in 5:
			player.add_skill(id)
	player.recompute()

	for id in player.skills:
		player.skills[id].cd = 1000000000.0
	menus.close()
	get_tree().paused = false
	print("SL job=%s" % player.job_name())

	var nums = Save.setting("damage_numbers", true)
	Save.data.settings["damage_numbers"] = "none"
	var c: = player.position + Vector3(2.6, 0, 0)
	_test_foes(9, 1.8, c)
	var big: = spawn_enemy(str(stage.mvp), c + Vector3(0, 0, -0.5), true)
	if big != null:
		big.max_hp = 1000000000.0
		big.hp = 1000000000.0
		big.speed = 0.0
	_rebuild_grid()
	await wait.call(0.3)
	for id in ["estin", "esma", "eswoo"]:
		Skills.cast(self, player, id, 5)
		for k in 5:
			await wait.call(0.1)
			await _tour_shot("sl_%s_%d" % [id, k])
		await wait.call(0.8)
	await _tour_shot("sl_bound")
	Skills.cast(self, player, "kaite", 5)
	await wait.call(0.1)
	await _tour_shot("sl_kaite_0")
	await wait.call(0.5)
	await _tour_shot("sl_kaite_1")
	for n in 3:
		Skills.cast(self, player, "soul_link", 5)
		for k in 3:
			await wait.call(0.25)
			await _tour_shot("sl_link%d_%d" % [n, k])
		await wait.call(0.6)
	Skills.cast(self, player, "esma_x", 1)
	for k in 4:
		await wait.call(0.15)
		await _tour_shot("sl_esma_x_%d" % k)

	player.add_skill("first_aid")
	player.skills["first_aid"].cd = 1000000000.0
	player.shield = 0.0
	player.hp = player.max_hp * 0.4
	Skills.cast(self, player, "first_aid", 5)
	for k in 5:
		await wait.call(0.12 if k < 3 else 0.4)
		await _tour_shot("sl_first_aid_%d" % k)
	print("SL bonds=%d streak=%d" % [player.soul_bonds, player.kick_streak])
	Save.data.settings["damage_numbers"] = nums
	get_tree().quit()





func _kage_test(dir: String, female: bool) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	_job_test_start("ninja", ["meikyou_shisui"], female)
	print("KAGE job=%s skills=%s" % [player.job_name(), str(player.job2.skills)])
	var c: = player.position + Vector3(3.5, 0, 0)
	_test_foes(8, 1.6, c)
	await wait.call(0.2)
	for i in 4:
		Skills.cast(self, player, "throw_shuriken", 5)
		await wait.call(0.35)
	await _tour_shot("kage_stuck")
	var stuck: = 0
	for e in enemies:
		stuck += e.kunai_stuck
	print("KAGE stuck=%d" % stuck)
	Skills.cast(self, player, "kunai_explosion", 5)
	await wait.call(0.2)
	await _tour_shot("kage_explosion")
	for id in ["flaming_petals", "freezing_spear", "lightning_crash"]:
		Skills.cast(self, player, id, 5)
		player._after_cast(id, self)
		await wait.call(0.3)
	print("KAGE charms=%s" % str(player.charms))
	await _tour_shot("kage_charms")
	Skills.cast(self, player, "kaihou", 5)
	await wait.call(0.3)
	await _tour_shot("kage_kaihou")
	await wait.call(0.5)
	await _tour_shot("kage_kaihou2")
	Skills.cast(self, player, "moonlight_fantasy_x", 1)
	await wait.call(1.0)
	await _tour_shot("kage_moon")
	Skills.cast(self, player, "kunai_explosion_x", 1)
	await wait.call(0.3)
	await _tour_shot("kage_explosion_x")
	print("KAGE meter=", meter.keys())
	get_tree().quit()





func _smith_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	menus.auto_pick = true
	start_run("merchant")
	menus.close()
	get_tree().paused = false
	print("SMITH time_scale=", Engine.time_scale)
	Engine.time_scale = 1.0
	player.max_hp = 99999.0
	player.hp = 99999.0
	player.job_change(0)
	for id in ["axe_tornado", "cart_cannon", "weaponry_research"]:
		for k in 5:
			player.add_skill(id)
	player.recompute()
	menus.close()
	get_tree().paused = false
	var foes: = func(n: int, r: float):
		for i in n:
			var a: = TAU * i / float(n)
			var e: = spawn_enemy("poring", player.position + Vector3(cos(a) * r, 0, sin(a) * r), true)
			if e != null:
				e.max_hp = 99999.0
				e.hp = 99999.0
				e.speed = 0.0
		_rebuild_grid()
	foes.call(10, 2.0)
	await wait.call(0.3)
	Skills.cast(self, player, "axe_tornado", 5)
	for i in 6:
		await wait.call(0.12)
		await _tour_shot("smith_tornado%d" % i)
	foes.call(6, 7.0)
	await wait.call(0.3)
	Skills.cast(self, player, "cart_cannon", 5)
	await wait.call(0.35)
	await _tour_shot("smith_cannon_fly")
	await wait.call(0.3)
	await _tour_shot("smith_cannon_boom")

	var safe: = player.forge_safe()
	print("SMITH safe=%d refine=%d max=%d skill_mult=%.2f" % [safe, player.forge_refine(), player.forge_max(), player.skill_mult])
	for i in 400:
		forge_heat(player, "basic")
		player.forge_hit_at = 0
		if player.forge_refine() >= safe + 3:
			break
	print("SMITH forged=%d heat=%.2f skill_mult=%.2f basic_mult=%.2f break_next=%.2f" % [player.forge_refine(), player.forge_heat, player.skill_mult, player.basic_mult, player.forge_break_chance(player.forge_refine() + 1)])
	player.forge_heat = 0.6
	await wait.call(0.6)
	await _tour_shot("smith_forge_hot")
	forge_up(player)
	await wait.call(0.15)
	await _tour_shot("smith_forge_up")
	await wait.call(0.8)
	forge_break(player, player.forge_refine())
	await wait.call(0.25)
	await _tour_shot("smith_forge_break")
	print("SMITH after_break=%d" % player.forge_refine())
	player.skills.erase("axe_tornado")
	player.skills["axe_tornado_x"] = {"level": 1, "cd": 0.3}
	Skills.cast(self, player, "axe_tornado_x", 1)
	await wait.call(1.2)
	await _tour_shot("smith_storm")
	Skills.cast(self, player, "cart_cannon_x", 1)
	await wait.call(0.9)
	await _tour_shot("smith_cannon_x")
	print("SMITH meter=", meter.keys())
	get_tree().quit()





func _alch_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	menus.auto_pick = true
	start_run("merchant")
	menus.close()
	get_tree().paused = false
	player.max_hp = 99999.0
	player.hp = 99999.0
	player.job_change(1)
	for id in ["acid_terror", "demonstration", "chemical_protection", "bioethics", "call_homunculus"]:
		for k in 5:
			player.add_skill(id)
	player.homun_type = "homun_vanilmirth"
	player.equipment.receive(Equipment.make("embryo", 0))
	player.recompute()
	spawn_homun()
	check_more_homun(player)

	player.evolve("call_homunculus")
	player.recompute()
	check_more_homun(player)
	print("ALCH cap=%d extra=%s effects=%s" % [player.homun_cap(), player.homun_extra, player.effects.get("homun_extra", 0)])
	for i in 10:
		var a: = TAU * i / 10.0
		var e: = spawn_enemy("poring", player.position + Vector3(cos(a) * 3.0 + 3.0, 0, sin(a) * 2.0), true)
		if e != null:
			e.max_hp = 99999.0
			e.hp = 99999.0
			e.speed = 0.0
	_rebuild_grid()
	await wait.call(0.3)
	Skills.cast(self, player, "acid_terror", 5)
	Skills.cast(self, player, "demonstration", 5)
	Skills.cast(self, player, "chemical_protection", 5)
	await wait.call(1.5)
	await _tour_shot("alch_ground")
	await wait.call(2.0)
	await _tour_shot("alch_homun")
	await wait.call(3.0)
	await _tour_shot("alch_mutation")
	print("ALCH mutation lv=%d cap=%d out=%d" % [player.homun_level(), player.homun_cap(), 1 + player.homun_extra_nodes.size()])
	Save.add_zeny(2000000)
	run_zeny += 5000
	Skills.cast(self, player, "mammonite_x", 1)
	await wait.call(0.15)
	await _tour_shot("mammonite_x")
	player.move_speed = 9.0
	Skills.cast(self, player, "cart_revolution_x", 1)
	await wait.call(0.15)
	await _tour_shot("cart_x")
	print("ALCH meter=", meter.keys())
	get_tree().quit()





func _diff_test() -> void :
	await get_tree().process_frame
	var bad: = 0
	for id in GameData.SKILLS:
		var sk: Dictionary = GameData.SKILLS[id]
		if str(id).begins_with("homun_") or id in ["forge_blast", "wiz_combo", "status_combo"]:
			continue
		var levels: Array = [2] if sk.get("evolved", false) else [2, 3, 4, 5, 6]
		for lv in levels:

			if lv > GameData.skill_cap(id) and not GameData.grows_past_cap(id):
				continue
			if menus._skill_diff(id, lv, lv - 1) == menus._skill_desc(id):
				print("NODIFF %s %d (%s)" % [id, lv, sk.get("type", "")])
				bad += 1
	print("NODIFF total %d" % bad)
	get_tree().quit()




func _dmg_test(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	start_run("thief")
	player.max_hp = 99999.0
	player.hp = 99999.0
	var ring: = func():
		for i in 8:
			var a: = TAU * i / 8.0
			var e: = spawn_enemy("poring", player.position + Vector3(cos(a) * 3.0 + 3.0, 0, sin(a) * 2.0), true)
			if e != null:
				e.max_hp = 99999.0
				e.hp = 99999.0
				e.speed = 0.0
		_rebuild_grid()
	ring.call()
	await wait.call(0.3)

	Skills.cast(self, player, "signum_crucis_x", 1)
	await wait.call(0.5)
	await _tour_shot("signum")

	Skills.cast(self, player, "lex_aeterna", 5)
	await wait.call(0.35)
	await _tour_shot("lex")
	await wait.call(0.6)
	await _tour_shot("lex_b")
	for e in enemies:
		damage_enemy(e, 300.0, Vector3.ZERO, "skill", "neutral", "test")
	await wait.call(0.15)
	await _tour_shot("lex_hit")

	await wait.call(1.0)
	Skills.cast(self, player, "jupitel_thunder_x", 1)
	for t in 4:
		await wait.call(0.12)
		await _tour_shot("jup_%d" % t)

	for e in enemies:
		e.position = player.position + Vector3(9.0 + enemies.find(e), 0, 0)
	_rebuild_grid()
	for k in 3:
		place_trap(player.position + Vector3(1.5 + 1.5 * k, 0, 1.0), 1.5, 50.0, GameData.SKILLS[["land_mine", "sandman", "ankle_snare"][k]])
	await wait.call(0.4)
	await _tour_shot("traps")
	for e in enemies:
		e.position = player.position + Vector3(4.5, 0, 1.0)
	_rebuild_grid()
	await wait.call(0.25)
	await _tour_shot("traps_b")

	await wait.call(0.8)
	Skills.cast(self, player, "falcon_assault", 5)
	Skills.cast(self, player, "blitz_beat", 5, "blitz_beat")
	for t in 3:
		await wait.call(0.2)
		await _tour_shot("falcon_%d" % t)

	await wait.call(0.8)
	for e in enemies:
		e.position = player.position + Vector3(3.0 + 1.3 * enemies.find(e), 0, 0.4 * (enemies.find(e) % 3) - 0.4)
	_rebuild_grid()
	player._last_stick = Vector2(1, 0)
	Skills.cast(self, player, "spear_boomerang_x", 1)
	for t in 3:
		await wait.call(0.15)
		await _tour_shot("knight_boom_%d" % t)
	await wait.call(0.6)
	player._last_stick = Vector2(1, 0)
	Skills.cast(self, player, "charge_attack", 5)
	for t in 3:
		await wait.call(0.12)
		await _tour_shot("knight_charge_%d" % t)
	await wait.call(0.6)
	Skills.cast(self, player, "spiral_pierce_x", 1)
	for t in 3:
		await wait.call(0.25)
		await _tour_shot("knight_drill_%d" % t)
	player.crit = 0.35
	for k in 3:
		for e in enemies:
			damage_enemy(e, 300.0 + 400.0 * randf(), Vector3.ZERO, "skill", ["neutral", "fire", "water"][k])
		await wait.call(0.12)
	await _tour_shot("dmg_a")
	await wait.call(0.25)
	await _tour_shot("dmg_b")
	await wait.call(0.35)
	await _tour_shot("dmg_c")

	var c0: = player.position + Vector3(-6.0, 1.0, -1.5)
	number(c0, "10300", Color(1, 0.85, 0.3), true, false, false, 1.0)
	number(c0 + Vector3(3.5, 0, 1.0), "2345", Color(1, 0.85, 0.3), true, false, false, 1.45)
	number(c0 + Vector3(7.5, 0, 0), "3456", GameData.ULTRA_CRIT_COLOR, true, true, false, 1.2)
	number(c0 + Vector3(12.0, 0, 1.0), "2450000", GameData.LETHAL_CRIT_COLOR, true, true, true, 1.45)
	await wait.call(0.2)
	await _tour_shot("dmg_tiers")
	await wait.call(1.0)

	var words_at: = player.position
	for i in 3:
		number(words_at + Vector3(0, 2.4, 0), [tr("¡Doble!"), tr("¡Triple!"), tr("¡Cuádruple!")][i], 
			[Color(0.75, 0.6, 1.0), Color(0.4, 0.85, 1.0), Color(1.0, 0.78, 0.25)][i], true, false, false, 1.0, false, true, false, "", 1.1 + 0.22 * i)
		await wait.call(0.12)
		await _tour_shot("dmg_multicast_%d" % i)
		await wait.call(GameData.INT_DOUBLE_DELAY - 0.12)
	await wait.call(1.0)
	player.crit = 0.0
	for e in enemies:
		e.position = player.position + Vector3(2.0 + 1.6 * enemies.find(e), 0, 0.3 * (enemies.find(e) % 2))
	_rebuild_grid()
	player._last_stick = Vector2(1, 0)
	var sk: Dictionary = GameData.SKILLS.back_stab


	var before: = enemies.map( func(e): return e.hp)
	line_shot(player, enemies[0], Vector3.RIGHT, 1.0, 0.3, 50.0, "neutral", GameData.SKILLS.investigate, 0.0, 6.0)
	var struck_n: = 0
	for i in enemies.size():
		if enemies[i].hp < float(before[i]) or enemies[i].dead:
			struck_n += 1
	print("DMGTEST kaiser struck=%d of %d" % [struck_n, enemies.size()])

	var keep_stats: Dictionary = player.stats.duplicate()
	player.stats["str"] = int(player.base_stats.get("str", 0)) + 10
	player.stats["int"] = int(player.base_stats.get("int", 0)) + 120
	player.recompute()
	print("DMGTEST proc int: frost_diver=%.2f bash=%.2f hit_fd=%.2f hit_bash=%.2f tip=%s / %s" % [player.proc_kind_mult(false, "frost_diver"), 
		player.proc_kind_mult(false, "bash"), player.proc_kind_mult(true, "frost_diver"), player.proc_kind_mult(true, "bash"), 
		GameData.gear_scaling({"proc": {"skill": "frost_diver"}}), GameData.gear_scaling({"proc": {"skill": "bash"}})])
	player.stats = keep_stats
	player.recompute()

	player.effects["intimidate"] = 0.35
	blink_chain(player, sk, 500.0, 1.0, 6, 14.0)
	get_tree().create_timer(1.5, true, false, true).timeout.connect( func():
		print("DMGTEST intimidated=%d" % enemies.filter( func(e): return e.fear_until > time and e.fear_vuln >= 0.35).size()))
	for t in 5:

		await wait.call(0.02)
		for f in 30:
			var cw = (player.get_meta("chain_word") if player.has_meta("chain_word") else null)
			if is_instance_valid(cw) and cw.scale.x < 1.05 and cw.transparency == 0.0:
				break
			await get_tree().process_frame
		await _tour_shot("chain_%d" % t)

	await wait.call(1.0)
	for e in enemies:
		e.position = player.position + Vector3(1.5 + 1.2 * enemies.find(e), 0, 0)
	_rebuild_grid()
	player.facing = Vector3.RIGHT
	Skills.cast(self, player, "investigate", 5)
	for t in 3:
		await wait.call(0.08)
		await _tour_shot("occult_%d" % t)
	get_tree().quit()




func _evo_test() -> void :
	await get_tree().process_frame
	GameData.set_meta("no_spawn", true)
	for base in GameData.EVOLUTIONS:
		var to: String = GameData.EVOLUTIONS[base].to
		var cls: = ""
		var path: = -1
		for cid in GameData.CLASSES:
			var d: Dictionary = GameData.CLASSES[cid]
			if d.skills.has(base):
				cls = cid
			var paths: = GameData.job_paths(cid)
			for i in paths.size():
				var job: Dictionary = paths[i]
				if job.skills.has(base) or (job.has("trans") and job.trans.skills.has(base)):
					cls = cid
					path = i
		if cls == "":
			print("EVOTEST no class for ", base)
			continue
		start_run(cls)
		player.max_hp = 99999.0
		player.hp = 99999.0
		if path >= 0:
			player.job_change(path)
		for i in 10:
			var a: = TAU * i / 10.0
			var e: = spawn_enemy("poring", player.position + Vector3(cos(a) * 3.0, 0, sin(a) * 3.0), true)
			if e != null:
				e.max_hp = 99999.0
				e.hp = 99999.0
		player.skills.clear()
		player.skills[to] = {"level": 1, "cd": 999.0}
		player.spheres = 5
		var before: = float(meter_stats.get("total", 0.0))
		for k in 3:
			Skills.cast(self, player, to, 1)
			for f in 30:
				await get_tree().process_frame
		print("EVOTEST %s (%s) dmg=%d" % [to, cls, roundi(float(meter_stats.get("total", 0.0)) - before)])
	get_tree().quit()




func _fx_tour(dir: String) -> void :
	_shot_dir = dir
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	start_run("mage")
	player.max_hp = 99999.0
	player.hp = 99999.0
	for e in enemies:
		e.queue_free()
	enemies.clear()
	_grid_fresh = false
	GameData.set_meta("no_spawn", true)
	await wait.call(0.5)
	for fx in ["pierce", "firehit1", "icecrash", "fire", "firepillar", "stormgust", "meteor1", 
			"invenom", "thief_invenom", "steal_coin", "sonicblow", "venomdust", "poison", 
			"angelus", "holyhit", "magnus", "sanctuary", "kyrie", "asum", 
			"freeze", "freezed", "freezing", "ice_status", "stun", "stonecurse", "sleep", "sandman", 
			"rl_fire_rain/fire_rain", "rl_banishing_buster/vanishing1", "rl_slugshot/slug", "rl_hamer_god/hogg"]:
		var d: = RoAssets.effect_data(fx)
		if d.is_empty():
			continue
		var length: = float(d.max_key) / float(d.fps)
		RoEffect.spawn(fx_root, fx, player.position + Vector3(2.5, 0, 0), 1.0)
		await wait.call(length * 0.4)
		await _tour_shot("fx_" + fx.replace("/", "_"))
		await wait.call(length * 0.6 + 0.1)
	_show_mvp_banner()
	await wait.call(0.5)
	await _tour_shot("fx_mvp")
	get_tree().quit()






func _raid_mech(dir: String, mvp_id: String, ab_id: String) -> void :
	_shot_dir = dir
	GameData.set_meta("tour_god", true)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout

	var any_map: = not GameData.STAGES.values().any( func(st): return st.mvp == mvp_id)
	for stage_key in GameData.STAGES:
		if GameData.STAGES[stage_key].mvp != mvp_id and not any_map:
			continue
		set_stage(stage_key)
		start_run("swordsman")
		menus.auto_pick = true
		time = float(stage.mvp_time)
		while _event_index < stage.events.size() and stage.events[_event_index].at < time + 1.0:
			_event_index += 1
		await wait.call(1.0)
		raid.open_portal(mvp_id)
		await wait.call(0.5)
		player.position = raid.portal_pos
		while raid.state != "fight":
			await wait.call(0.2)
		print("RAIDMECH arena=%s center=%s radius=%.1f" % [raid.data.arena, raid.center, raid.radius])
		for ab in raid.data.abilities:
			if ab.id == ab_id and not ab.phases.has(raid.phase):

				var ph: = int(ab.phases[0])
				raid.boss.hp = raid.boss.max_hp * (float(raid.data.phases[ph]) - 0.02)
				await wait.call(0.5)
		while raid._immune > 0.0:
			await wait.call(0.2)

		if OS.has_environment("RAID_STUN"):
			var f0: float = raid._fight_t
			raid.boss.set_status("stun", 3.0)
			await wait.call(2.0)
			print("RAIDMECH stun fight_t %.2f -> %.2f (stunned=%s)" % [f0, raid._fight_t, raid.boss.status == "stun"])
		for ab in raid.data.abilities:
			raid._timers[ab.id] = 0.3 if ab.id == ab_id else 999.0
		raid._cast = {}
		for i in (int(OS.get_environment("RAID_SHOTS")) if OS.has_environment("RAID_SHOTS") else 16):
			await wait.call(0.6)
			await _tour_shot("%s_%s_%02d" % [mvp_id, ab_id, i])
		break
	get_tree().quit()


func _raid_tour(dir: String, only: String) -> void :
	_shot_dir = dir

	GameData.set_meta("tour_god", true)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	for stage_key in GameData.STAGES:
		var mvp_id: String = GameData.STAGES[stage_key].mvp
		if (only != "" and only != mvp_id) or not raid.supports(mvp_id):
			continue
		set_stage(stage_key)
		start_run("swordsman")
		menus.auto_pick = true
		player.add_skill("magnum_break")
		player.max_hp = 999999.0
		player.hp = player.max_hp
		player.revives = 999
		time = float(stage.mvp_time)
		while _event_index < stage.events.size() and stage.events[_event_index].at < time + 1.0:
			_event_index += 1
		await wait.call(1.0)
		raid.open_portal(mvp_id)
		await wait.call(0.6)
		await _tour_shot("%s_0_alert" % mvp_id)
		await wait.call(1.0)
		await _tour_shot("%s_1_portal" % mvp_id)
		player.position = raid.portal_pos
		while raid.state != "intro":
			await wait.call(0.2)
		await wait.call(0.8)
		await _tour_shot("%s_2_arena" % mvp_id)
		while raid.state != "fight":
			await wait.call(0.2)
		await wait.call(0.5)
		await _tour_shot("%s_3_boss" % mvp_id)
		for ab in raid.data.abilities:
			if raid.state != "fight":
				break
			raid._cast = {}
			raid.boss.hp = raid.boss.max_hp
			fx_layer(GameData.MVP_FX_PRIORITY)
			raid._start(ab)
			fx_layer(0)
			await wait.call(maxf(0.6, float(ab.get("cast", 1.0)) * 0.6))
			await _tour_shot("%s_4_%s" % [mvp_id, ab.id])
			await wait.call(float(ab.get("cast", 0.0)) * 0.5 + 0.9)
			await _tour_shot("%s_4_%s_b" % [mvp_id, ab.id])
			await wait.call(1.2)
			await _tour_shot("%s_4_%s_c" % [mvp_id, ab.id])
		player.hp = player.max_hp
		raid.boss.hp = 1.0
		damage_enemy(raid.boss, 10.0)
		await wait.call(1.0)
		await _tour_shot("%s_5_victory" % mvp_id)
		await wait.call(2.6)
		menus.close()
		get_tree().paused = false
		running = false
	get_tree().quit()






func _clip(args: Array) -> void :
	var at: = args.find("--clip")
	var class_id: String = args[at + 1]
	var path: = int(args[at + 2])
	var stage_key: String = args[at + 3]
	var seconds: = float(args[at + 4])
	var flags: Array = args.slice(at + 5)
	var look: Dictionary = ITCH_LOOKS.get("%s:%d" % [class_id, path], {})
	if not look.is_empty():
		Save.set_look(class_id, look)
	if "reborn" in flags:
		Save.data.rebirths[class_id] = 1

	get_tree().create_timer(seconds, true, false, true).timeout.connect(get_tree().quit)
	set_stage(stage_key)
	start_run(class_id)
	autopilot = true
	showcase = true
	menus.showcase = "menus" in flags or "rookie" in flags
	menus.auto_pick = not menus.showcase
	for f in flags:
		if str(f).begins_with("zoom="):
			_cam_distance = float(str(f).get_slice("=", 1))
	if "clean" in flags:
		hud.visible = false
	if "rookie" in flags:
		player.level = GameData.JOB_CHANGE_LEVEL - 1
		player.xp_need = GameData.xp_to_next(player.level)
		player.xp = player.xp_need * 0.85
		for id in player.def.skills.slice(0, 4):
			for i in 3:
				player.add_skill(id)
	else:
		player.level = GameData.JOB_CHANGE_LEVEL + 12
		player.xp_need = GameData.xp_to_next(player.level)
		player.job_change(path)
		hud.bind(self)

		var pool: Array = player.skill_pool().duplicate()
		pool.reverse()
		for id in pool:
			if not GameData.SKILLS.has(id) or GameData.SKILLS[id].type == "passive":
				continue
			if not player.skills.has(id) and player.count_skills(false) >= player.max_skills():
				continue
			for i in GameData.MAX_SKILL_LEVEL:
				player.add_skill(id)
	player.recompute()
	player.hp = player.max_hp
	player.revives = 999
	time = 330.0
	while _event_index < stage.events.size() and stage.events[_event_index].at < time - 1.0:
		_event_index += 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var opened: = false
	while true:
		await wait.call(0.25)
		if not is_instance_valid(player):
			return
		if player.hp < player.max_hp * 0.5:
			player.hp = player.max_hp
		if "raid" in flags and not opened and raid.supports(stage.mvp):
			opened = true
			raid.open_portal(stage.mvp)





func _itch_art(dir: String, args: Array) -> void :
	var only: String = args[args.find("--only") + 1] if "--only" in args else ""
	for sub in ["chars", "mobs", "shots"]:
		DirAccess.make_dir_recursive_absolute("%s/%s" % [dir, sub])
	if only in ["", "chars"]:
		_itch_sprites(dir)
	if only == "" or only.begins_with("shots"):
		await _itch_shots(dir, only.get_slice(":", 1) if only.contains(":") else "")
	get_tree().quit()


func _itch_sprites(dir: String) -> void :

	var heroes: = [
		["swordsman", 0, true, {"gender": "m", "hair": 3, "hair_color": 4, "cloth": 1}, "hat_valkyrie"], 
		["swordsman", 1, false, {"gender": "f", "hair": 6, "hair_color": 6, "cloth": 2}, ""], 
		["mage", 0, true, {"gender": "f", "hair": 7, "hair_color": 2, "cloth": 1}, ""], 
		["mage", 1, false, {"gender": "m", "hair": 12, "hair_color": 5, "cloth": 3}, "hat_goggles"], 
		["archer", 0, true, {"gender": "m", "hair": 10, "hair_color": 6, "cloth": 2}, "hat_goggles"], 
		["archer", 1, true, {"gender": "f", "hair": 9, "hair_color": 1, "cloth": 1}, ""], 
		["thief", 0, true, {"gender": "m", "hair": 12, "hair_color": 5, "cloth": 1}, "hat_bandana"], 
		["thief", 1, false, {"gender": "f", "hair": 2, "hair_color": 7, "cloth": 3}, ""], 
		["acolyte", 0, true, {"gender": "f", "hair": 4, "hair_color": 3, "cloth": 2}, "hat_ribbon"], 
		["acolyte", 1, false, {"gender": "m", "hair": 1, "hair_color": 8, "cloth": 1}, ""], 
		["merchant", 0, true, {"gender": "m", "hair": 6, "hair_color": 7, "cloth": 2}, "hat_cap"], 
		["merchant", 1, false, {"gender": "f", "hair": 11, "hair_color": 4, "cloth": 1}, ""], 
		["gunslinger", 0, false, {"gender": "f", "hair": 11, "hair_color": 8, "cloth": 1}, "hat_apple"], 
	]
	var meta: = {}
	for h in heroes:
		var d: Dictionary = GameData.CLASSES[h[0]]
		var job: Dictionary = GameData.job_paths(h[0])[h[1]]
		var body: String = job.trans.body if h[2] else job.body
		var name: String = "%s_%s" % [job.trans.id if h[2] else job.id, h[3].gender]
		var ro: = RoAssets.styled_character(body, job.get("weapon", d.get("weapon", "")), 
			job.get("weapon_fx", ""), [5, 10, 11], h[4], h[3])
		if ro == null:
			print("ITCH missing ", name)
			continue
		meta[name] = {"origin": [ro.origin.x, ro.origin.y]}
		for pose in [[RoVisual.PC_READY, "ready"], [RoVisual.PC_ATTACK, "attack"], [RoVisual.PC_CAST, "cast"], [RoVisual.PC_IDLE, "idle"]]:
			for dir8 in [0, 1, 7]:
				var a: int = pose[0] * RoSprite.DIRS + dir8
				for f in ro.frame_count(a):
					ro.compose_image(a, f).save_png("%s/chars/%s_%s_d%d_f%d.png" % [dir, name, pose[1], dir8, f])
	for id in ["poring", "poporing", "drops", "marin", "lunatic", "fabre", "willow", "rocker", "smokie", "baphomet_", 
			"baphomet", "dark_lord", "eddga", "osiris", "moonlight", "orc_lord", "ork_hero", "pharaoh", 
			"ghostring", "angeling", "deviling", "zombie", "skeleton", "khalitzburg", "raydric", "mimic", "marine_sphere"]:
		if not RoAssets.has_sprite(id):
			continue
		var spr: = RoAssets.sprite([id])
		meta["mob_" + id] = {"origin": [spr.origin.x, spr.origin.y]}
		for base in [0, 1, 2]:
			for dir8 in [0, 1, 7]:
				var a: int = base * RoSprite.DIRS + dir8
				for f in spr.frame_count(a):
					spr.compose_image(a, f).save_png("%s/mobs/%s_a%d_d%d_f%d.png" % [dir, id, base, dir8, f])
	var fa: = FileAccess.open(dir + "/meta.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(meta))
	fa.close()


func _itch_shots(dir: String, only_stage: = "") -> void :
	_shot_dir = dir + "/shots"
	var wait: = func(t: float): await get_tree().create_timer(t, false).timeout

	var plan: = [["prontera", "mage", 0], ["glast", "acolyte", 0], ["payon", "archer", 0], 
		["clock_tower", "swordsman", 0], ["byalan", "thief", 0], ["niflheim", "merchant", 0], 
		["pyramid", "gunslinger", 0], ["abbey", "acolyte", 1]]
	for p in plan:
		if only_stage != "" and p[0] != only_stage:
			continue
		set_stage(p[0])
		start_run(p[1])
		autopilot = true
		menus.auto_pick = true
		player.level = GameData.JOB_CHANGE_LEVEL + 8
		player.job_change(p[2])
		for id in player.skill_pool().slice(0, 7):
			if GameData.SKILLS.has(id):
				for i in 4:
					player.add_skill(id)
		player.recompute()
		player.hp = player.max_hp
		player.revives = 999
		time = 330.0
		while _event_index < stage.events.size() and stage.events[_event_index].at < time - 1.0:
			_event_index += 1
		for k in 3:
			await wait.call(5.0)
			player.hp = player.max_hp
			await _tour_shot("%s_%s_%d" % [p[0], p[1], k])

			hud.visible = false
			await _tour_shot("%s_%s_%d_clean" % [p[0], p[1], k])
			hud.visible = true
		if p[0] in ["prontera", "glast"] and raid.supports(stage.mvp):
			raid.open_portal(stage.mvp)
			await wait.call(2.0)
			await _tour_shot("%s_raid_0" % p[0])

			var limit: = 30.0
			while raid.state != "fight" and limit > 0.0:
				await wait.call(0.3)
				limit -= 0.3
			for k in 3:
				await wait.call(3.0)
				player.hp = player.max_hp
				await _tour_shot("%s_raid_%d" % [p[0], k + 1])
		running = false






func _showcase(args: Array) -> void :
	var at: = args.find("--showcase")
	var class_id: String = args[at + 1] if args.size() > at + 1 else "acolyte"
	var stage_key: String = args[at + 2] if args.size() > at + 2 else "glast"
	var wait: = func(t: float): await get_tree().create_timer(t, false).timeout
	set_stage(stage_key)
	start_run(class_id)
	autopilot = true
	showcase = true
	menus.showcase = true
	player.level = GameData.JOB_CHANGE_LEVEL - 1
	player.xp_need = GameData.xp_to_next(player.level)
	player.xp = player.xp_need * 0.9
	for id in player.def.skills.slice(0, 5):
		for i in 3:
			player.add_skill(id)
	player.recompute()
	player.hp = player.max_hp
	player.revives = 999
	time = 300.0
	while _event_index < stage.events.size() and stage.events[_event_index].at < time - 1.0:
		_event_index += 1
	var clock: = 0.0
	while clock < 46.0:
		if clock >= 22.0 and not raid.active() and raid.supports(stage.mvp):
			raid.open_portal(stage.mvp)
		await wait.call(0.5)
		clock += 0.5
		if player.hp < player.max_hp * 0.5:
			player.hp = player.max_hp
	get_tree().quit()








func _gameplay_reel(args: Array) -> void :
	var at: = args.find("--gameplay-reel")
	var class_id: String = args[at + 1] if args.size() > at + 1 else "gunslinger"
	var path: = int(args[at + 2]) if args.size() > at + 2 else 0
	var stage_key: String = args[at + 3] if args.size() > at + 3 else "juperos"
	var look: Dictionary = ITCH_LOOKS.get("%s:%d" % [class_id, path], {})
	if not look.is_empty():
		Save.set_look(class_id, look)

	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var keep_alive: = func():
		if is_instance_valid(player) and player.hp < player.max_hp * 0.55:
			player.hp = player.max_hp
	set_stage(stage_key)
	start_run(class_id)
	autopilot = true
	showcase = true
	menus.showcase = true
	menus.auto_pick = false
	player.revives = 999
	danger = 5
	var card: = _reel_card()

	for i in 36 * 4:
		await wait.call(0.25)
		keep_alive.call()

	await _reel_fade(card, func(): _reel_jump(360.0, GameData.JOB_CHANGE_LEVEL + 6, path, 3, 10))
	for i in 35 * 4:
		await wait.call(0.25)
		keep_alive.call()

	await _reel_fade(card, func():
		_reel_jump(1200.0, GameData.JOB_CHANGE_LEVEL + 40, path, GameData.MAX_SKILL_LEVEL, 13)
		continue_endless()
		_endless_count = 6
		menus.close()
		get_tree().paused = false)
	for i in 33 * 4:
		await wait.call(0.25)
		keep_alive.call()

	await _reel_fade(card, func():
		raid.open_portal(stage.mvp)
		player.position = raid.portal_pos)
	var clock: = 0.0
	var phased: = false
	while clock < 40.0:
		await wait.call(0.25)
		keep_alive.call()
		if raid.state == "won":

			await wait.call(6.0)
			break
		if raid.state == "fight":
			clock += 0.25
			if clock < 0.3:

				raid._timers["rifts"] = 2.0
			if clock >= 14.0 and not phased and raid.boss != null and is_instance_valid(raid.boss):
				phased = true
				raid.boss.hp = raid.boss.max_hp * 0.58
				raid._timers["sweep"] = 3.0
			if clock >= 34.0 and raid.boss != null and is_instance_valid(raid.boss) and not raid.boss.dead:
				raid.boss.hp = 1.0
				damage_enemy(raid.boss, 10.0)
	await wait.call(1.0)
	get_tree().quit()



func _reel_jump(at_time: float, level: int, path: int, skill_level: int, at_danger: int) -> void :
	danger = at_danger
	menus.close()
	get_tree().paused = false
	if player.job2.is_empty():
		player.level = level
		player.job_change(path)
		hud.bind(self)
	player.level = level
	player.xp = 0.0
	player.xp_need = GameData.xp_to_next(player.level)
	var pool: Array = player.skill_pool().duplicate()
	pool.reverse()

	for star in ["hammer_of_god"]:
		if pool.has(star):
			pool.erase(star)
			pool.push_front(star)
	for id in pool:
		if not GameData.SKILLS.has(id) or GameData.SKILLS[id].type == "passive":
			continue
		if not player.skills.has(id) and player.count_skills(false) >= player.max_skills():
			continue
		while int(player.skills.get(id, {}).get("level", 0)) < skill_level:
			player.add_skill(id)

	for st in ["str", "agi", "vit", "dex", "luk"]:
		player.stats[st] = maxi(int(player.stats.get(st, 1)), level / 3)
	player.recompute()
	player.hp = player.max_hp
	for e in enemies.duplicate():
		if is_instance_valid(e) and not e.dead and not e.is_boss:
			banish_enemy(e)
	time = at_time
	while _event_index < stage.events.size() and stage.events[_event_index].at < time - 1.0:
		_event_index += 1


func _reel_card() -> Control:
	var layer: = CanvasLayer.new()
	layer.layer = 120
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var root: = ColorRect.new()
	root.color = Color.BLACK
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.modulate.a = 0.0
	layer.add_child(root)
	return root



func _reel_fade(card: Control, jump: Callable) -> void :
	var tw: = card.create_tween()
	tw.tween_property(card, "modulate:a", 1.0, 0.3)
	await tw.finished
	jump.call()
	await get_tree().create_timer(0.35, true, false, true).timeout
	var back: = card.create_tween()
	back.tween_property(card, "modulate:a", 0.0, 0.35)
	await back.finished




func _job_shots(dir: String, class_id: String, path: int) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().process_frame
	start_run(class_id)
	player.max_hp = 99999.0
	player.hp = 99999.0
	player.job_change(path)
	player.skills["call_spirits"] = {"level": 5, "cd": 0.0}
	player.recompute()
	player.spheres = player.sphere_max
	_cam_distance = 26.0
	await get_tree().create_timer(1.0).timeout
	await _tour_shot("%s_%d_idle" % [class_id, path])
	for i in 10:
		var a: = TAU * i / 10.0
		var e: = spawn_enemy("poring", player.position + Vector3(cos(a) * 3.5, 0, sin(a) * 2.5), true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 99999.0
			e.hp = 99999.0
	await get_tree().create_timer(0.3).timeout
	var job: Dictionary = player.job2
	for id in job.skills:
		player.skills[id] = {"level": 5, "cd": 999.0}
		player.spheres = player.sphere_max
		Skills.cast(self, player, id, 5)
		await get_tree().create_timer(0.25).timeout
		await _tour_shot("%s_%d_%s" % [class_id, path, id])
		await get_tree().create_timer(0.35).timeout
		await _tour_shot("%s_%d_%s_b" % [class_id, path, id])
		await get_tree().create_timer(1.0).timeout
	get_tree().quit()





func _clutter_shots(dir: String, class_id: String, path: int, alpha: float, only: Array = []) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	Save.set_setting("fx_alpha", alpha)
	apply_audio_settings()
	await get_tree().process_frame
	start_run(class_id)
	player.job_change(path)
	player.skills.clear()
	for id in (player.def.skills + player.job2.get("skills", []) if only.is_empty() else only):
		player.skills[id] = {"level": 5, "cd": randf() * 0.5}
	player.stats["int"] = GameData.MAX_STAT
	player.stats["agi"] = GameData.MAX_STAT
	player.max_hp = 99999.0
	player.recompute()
	player.hp = player.max_hp
	_cam_distance = 26.0
	for i in 40:
		var at: = map.random_point_around(player.position, 7.0)
		var e: = spawn_enemy("poring", at, true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 999999.0
			e.hp = 999999.0
	for t in [2.0, 1.0, 1.0]:
		await get_tree().create_timer(t).timeout
		player.hp = player.max_hp
		await _tour_shot("%s_%d_fx%d_%s%d" % [class_id, path, roundi(alpha * 100.0), "_".join(only), roundi(time)])
	Save.set_setting("fx_alpha", 1.0)
	get_tree().quit()






func _devname_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	for n in ["nearQurita", "NEARQ", "n3ar q", "Ne.ar.Q", "Linear", "Pepito"]:
		print("DEVNAME reserved %-12s %s  dev_name %s  shown '%s'" % [n, NameFilter.reserved(n), NameFilter.dev_name(n), NameFilter.shown(n)])
	print("DEVNAME is_dev ", Save.is_dev())
	var kt: = int(Time.get_unix_time_from_system())
	var ksig: = Save.dev_sign("kick|3|7|%d" % kt)
	print("DEVNAME sign ok %s  tampered %s  empty %s  junk %s" % [Save.dev_verify("kick|3|7|%d" % kt, ksig), 
		Save.dev_verify("kick|3|8|%d" % kt, ksig), Save.dev_verify("kick|3|7|%d" % kt, ""), Save.dev_verify("kick|3|7|%d" % kt, "abc")])
	Save.set_look("acolyte", {"name": "nearQurita", "gender": "f", "hair": 3, "hair_color": 2, "cloth": 1})
	Save.set_look("mage", {"name": "NEARQ", "gender": "m", "hair": 4, "hair_color": 1, "cloth": 0})
	print("DEVNAME char_name acolyte '%s'  mage '%s'" % [Save.char_name("acolyte"), Save.char_name("mage")])
	var keep_dev: = Save._dev
	Save._dev = 0
	Save._name_ok.clear()
	print("DEVNAME not dev: acolyte '%s'" % Save.char_name("acolyte"))
	Save._dev = keep_dev
	Save._name_ok.clear()
	enter_town("acolyte")
	await get_tree().create_timer(1.5).timeout
	var at: = town.hero.position
	town.sync_channel([
		{"id": -5, "name": "nearQastero", "class": "mage", "look": {}, "views": {}, "party": false, "at": at + Vector3(2.5, 0, 0.5)}, 
		{"id": -6, "name": "NearQ", "class": "archer", "look": {}, "views": {}, "party": false, "at": at + Vector3(-2.5, 0, 0.5)}, 
		{"id": -7, "name": "Pepito", "class": "thief", "look": {}, "views": {}, "party": false, "at": at + Vector3(0, 0, 2.5)}])
	await get_tree().create_timer(1.0).timeout
	town.party_chat(-5, "nearQastero : ¡Bienvenidos a Prontera!")
	town.party_chat(-7, "Pepito : hola!")
	channel.log_line("all", "Pepito : hola!")
	channel.log_line("all", "nearQastero : ¡Bienvenidos a Prontera!")
	channel.log_line("whisper", "(De nearQastero) : gracias por jugar")
	channel.log_line("all", "NearQ : soy el dev")
	await get_tree().create_timer(0.5).timeout
	await _tour_shot("devname_town")
	get_tree().quit()


func _emotepick_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	enter_town("acolyte")
	await get_tree().create_timer(1.5).timeout
	var t0: = Time.get_ticks_msec()
	town._crowd.set_meta("log_test", true)
	await get_tree().process_frame
	town._crowd._log.set_process(false)
	town._crowd._log.modulate.a = 1.0
	town._crowd._log.emotes.open()
	print("EMOTEPICK open %d ms, %d emotions" % [Time.get_ticks_msec() - t0, town._crowd._log.emotes.order().size()])
	await get_tree().create_timer(0.4).timeout
	await _tour_shot("picker")
	town._crowd._log.emotes.close()
	town._crowd.send_emote(18)
	await get_tree().create_timer(0.8).timeout
	await _tour_shot("heh")
	town._crowd.open_chat("/love")
	town._crowd._send_chat("/love")
	await get_tree().create_timer(0.8).timeout
	await _tour_shot("love")

	town.toggle_sit()
	await get_tree().create_timer(1.0).timeout
	await _tour_shot("sit")
	print("SIT sitting=%s action=%d" % [town.sitting, town.hero.base_action])
	get_tree().quit()


func _zoom_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	start_run("swordsman")
	await get_tree().create_timer(4.0).timeout
	for d in [9.0, 13.0, 18.0]:
		_cam_distance = d
		await get_tree().create_timer(1.0).timeout
		await _tour_shot("zoom_%02d" % int(d))
	get_tree().quit()


func _opttabs_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5).timeout
	for t in ["sound", "video", "game", "language", "controls"]:
		menus.show_options(t)
		await get_tree().create_timer(0.5).timeout
		await _tour_shot("opt_" + t)

		var sc: = menus._options.find_child("OptionsScroll", true, false) as ScrollContainer
		if t == "video" and sc != null:
			sc.scroll_vertical = 480
			await get_tree().create_timer(0.3).timeout
			await _tour_shot("opt_video_ui")
	get_tree().quit()





func _presence_test(args: Array) -> void :
	var host: = "--presence=host" in args
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await wait.call(1.0)
	enter_town("swordsman" if host else "mage")
	await wait.call(1.0)
	if host:
		channel.join_enet("")
		var t0: = Time.get_ticks_msec()
		for i in 70:
			var ids: Array = town._party.keys()
			var line: = "PRESENCE host t=%.1f members=%d drawn=%s" % [(Time.get_ticks_msec() - t0) / 1000.0, channel.members.size(), 
				ids.map( func(id): return [id, (town._party[id].node as Node3D).position.round()])]
			print(line)
			await wait.call(0.5)
		print("PRESENCE portal=%s" % town._at(Town.PORTAL_CELL).round())
	else:
		await wait.call(2.0)
		town.hero.position = town._at(Vector2i(160, 190))
		print("PRESENCE join at %s" % town.hero.position.round())
		await wait.call(0.5)
		channel.join_enet("127.0.0.1")
		await wait.call(8.0)
		print("PRESENCE join silent")
		channel.process_mode = Node.PROCESS_MODE_DISABLED
		await wait.call(11.0)
		print("PRESENCE join back")
		channel.process_mode = Node.PROCESS_MODE_INHERIT
		await wait.call(14.0)
	get_tree().quit()


func _loadart_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var t: = load("res://assets/ro/ui/loading/loading12.png") as Texture2D
	var img: = t.get_image()
	print("LOADART format=%d px=%s %s" % [img.get_format(), img.get_pixel(5, 5), img.get_pixel(600, 100)])
	var a: = RoAssets.image_of("res://assets/ro/sprites/fx_emotion.png")
	var b: = (load("res://assets/ro/sprites/fx_emotion.png") as Texture2D).get_image()
	b.convert(Image.FORMAT_RGBA8)
	var da: = a.get_data()
	var db: = b.get_data()
	var diff_a: = 0
	var diff_rgb: = 0
	for i in range(0, mini(da.size(), db.size()), 4):
		if da[i + 3] != db[i + 3]:
			diff_a += 1
		elif da[i + 3] > 0 and (da[i] != db[i] or da[i + 1] != db[i + 1] or da[i + 2] != db[i + 2]):
			diff_rgb += 1
	print("CPUIMG %s %s/%s sizes %d %d alpha_diff=%d visible_rgb_diff=%d" % [a.get_size(), a.get_format(), b.get_format(), da.size(), db.size(), diff_a, diff_rgb])
	var art: = TextureRect.new()
	art.texture = t
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	menus._root.add_child(art)
	await get_tree().create_timer(1.0).timeout
	await _tour_shot("loadart")
	get_tree().quit()



func _charpage_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	menus.show_class_select()
	await get_tree().create_timer(2.5).timeout
	var win: Node = null
	for c in menus._root.get_children():
		if c is RoCharSelect:
			win = c
	win.select(3)
	for f in 3:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/page_f%d.png" % [dir, f])
	get_tree().quit()




func _closeup_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	enter_town("acolyte")
	await get_tree().create_timer(1.0).timeout
	for n in town._npcs:
		if str(n.def.id) == "kafra":
			town.hero.position = n.node.position + Vector3(1.2, 0, 2.5)
	for d in [42.0, 18.0, 10.0]:
		_cam_distance = d
		await get_tree().create_timer(1.2).timeout
		emote(town.hero, "love", 3.0)
		town._crowd.chat(town.hero, "Aventurero : hola a todos")
		await get_tree().create_timer(0.8).timeout
		await _tour_shot("close_%02d" % int(d))
	get_tree().quit()



func _beam_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	start_run("gunslinger")
	await get_tree().create_timer(2.0).timeout
	var e: = spawn_enemy("mastering", player.position + Vector3(6, 0, -3), true)
	await get_tree().create_timer(0.5).timeout
	var d: = ((e.position - player.position) * Vector3(1, 0, 1)).normalized()
	Uniques._beam(self, player, player.position + Vector3(0, 0.9, 0), d, GameData.U_RAIL_LENGTH)
	for t in [0.02, 0.08, 0.16, 0.26]:
		await get_tree().create_timer(t).timeout
		await _tour_shot("rail_%03d" % int(t * 100))
	GameData.set_meta("tour_god", true)
	await get_tree().create_timer(1.0).timeout
	e = spawn_enemy("mastering", player.position + Vector3(6, 0, -3), true)
	await get_tree().create_timer(0.3).timeout
	var sk: Dictionary = GameData.SKILLS.banishing_buster.duplicate()
	if e != null and is_instance_valid(e):
		for k in 4:
			spawn_enemy("poring", player.position + Vector3(2.0 + k * 2.0, 0, -1.0 - k), true)
		await get_tree().create_timer(0.3).timeout
		pierce_shot(player, e, 1.0, "neutral", sk, 14.0, 1.3)
	for t in [0.02, 0.08, 0.16]:
		await get_tree().create_timer(t).timeout
		await _tour_shot("bb_%03d" % int(t * 100))
	get_tree().quit()


func _npcline_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	enter_town("acolyte")
	await get_tree().create_timer(1.5).timeout
	menus.show_npc_line(tr("Lydia"), "npc_party", tr("No se pudo conectar con la sala. Revisa el código y prueba de nuevo."))
	await get_tree().create_timer(1.0).timeout
	await _tour_shot("npcline")
	get_tree().quit()


func _town_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().process_frame
	enter_town("acolyte")
	var t: = 0.0
	for at in [0.5, 1.2, 2.5, 6.0, 10.5, 14.0]:
		await get_tree().create_timer(at - t).timeout
		t = at
		await _tour_shot("town_%04.1f" % at)

	var dist: = _cam_distance
	_cam_distance = 62.0
	town.hero.position = town._at(Vector2i(156, 184))
	await get_tree().create_timer(1.5).timeout
	await _tour_shot("town_overview")
	_cam_distance = dist

	town.hero.position = town._at(Vector2i(143, 187))
	await get_tree().create_timer(1.5).timeout
	await _tour_shot("town_forge")
	town.hero.position = town._at(Vector2i(169, 187))
	await get_tree().create_timer(1.5).timeout
	await _tour_shot("town_workshop")
	menus.show_refiner()
	await get_tree().create_timer(0.6).timeout
	await _tour_shot("town_refiner")
	get_tree().quit()







func _quests_test(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await get_tree().process_frame
	GameData.set_meta("quest_at", 0.3)
	for sid in GameData.QUESTS:
		set_stage(sid)
		start_run("swordsman")
		menus.close()
		get_tree().paused = false
		menus.auto_pick = true
		player.max_hp = 99999.0
		player.hp = 99999.0
		await wait.call(1.5)
		if not quest.shows():
			print("QTEST %s no quest (state=%s)" % [sid, quest.state])
			continue
		player.position = quest.pos + Vector3(2.5, 0, 1.5)
		snap_camera()
		await wait.call(0.5)
		await _tour_shot("%s_a_offer" % sid)
		menus._resume()
		quest.accept()
		await wait.call(2.5)
		player.hp = player.max_hp
		await _tour_shot("%s_b_active" % sid)
		if str(quest.data.type) == "ritual":
			player.position = quest._seals[0]
			snap_camera()
			await wait.call(float(quest.data.hold) * 0.5)
			await _tour_shot("%s_c_seal_half" % sid)
			await wait.call(float(quest.data.hold) * 0.6)
			await _tour_shot("%s_d_seal_broken" % sid)
		elif str(quest.data.type) == "escort":
			player.position = quest.exit_pos + Vector3(1.0, 0, 0)
			snap_camera()
			await wait.call(1.2)
			await _tour_shot("%s_c_exit" % sid)
		elif str(quest.data.type) == "hunt":
			if quest._guardian != null and is_instance_valid(quest._guardian):
				player.position = quest._guardian.position + Vector3(2.0, 0, 0)
				snap_camera()
				await wait.call(0.4)
				await _tour_shot("%s_c_guardian" % sid)
		print("QTEST %s ok type=%s" % [sid, quest.data.type])
		player.position = quest.pos + Vector3(2.5, 0, 1.5)
		snap_camera()
		quest._succeed()
		await wait.call(0.5)
		menus._resume()
		await _tour_shot("%s_e_done" % sid)
		await wait.call(3.0)
		await _tour_shot("%s_f_left" % sid)
		menus._resume()
	get_tree().quit()


func _quest_tour(dir: String) -> void :
	_shot_dir = dir
	DirAccess.make_dir_recursive_absolute(dir)
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	await get_tree().process_frame
	menus.show_server_select("mage")
	await wait.call(0.6)
	await _tour_shot("q0_stage_list")
	set_stage("prontera")
	GameData.set_meta("quest_at", 0.5)
	start_run("mage")
	await wait.call(2.0)
	await _tour_shot("q1_appear")
	player.position = quest.pos + Vector3(2.0, 0, 1.0)
	snap_camera()
	await wait.call(0.6)
	await _tour_shot("q2_offer")
	menus._resume()
	quest.accept()
	await wait.call(7.0)
	await _tour_shot("q3_active")
	quest.t = 0.05
	await wait.call(1.6)
	await _tour_shot("q4_reward")
	menus._resume()
	await wait.call(1.6)
	await _tour_shot("q4b_leaving")
	enter_town("mage")
	await wait.call(1.5)
	await _tour_shot("q5_town_chef")
	menus.show_chef()
	await wait.call(0.6)
	await _tour_shot("q6_chef")
	menus._cook("rice_cake")
	await wait.call(0.7)
	await _tour_shot("q7_cooking")
	await wait.call(1.6)
	await _tour_shot("q8_chef_done")
	menus.show_server_select("mage")
	await wait.call(0.6)
	await _tour_shot("q9_stage_list_done")
	start_run("mage")
	await wait.call(1.0)
	await _tour_shot("q10_hud_dish")
	player.add_xp(player.xp_need)
	await wait.call(0.5)
	await _tour_shot("q11_rice_cake")

	set_stage("orc_dun")
	start_run("swordsman")
	player.max_hp = 99999.0
	player.hp = 99999.0
	get_tree().paused = false
	for i in 40:
		if quest.shows():
			break
		await wait.call(0.25)
	await wait.call(0.5)
	await _tour_shot("q12_escort_appear")
	if not quest.shows():
		print("TOUR escort quest did not show: state=%s time=%.1f paused=%s" % [quest.state, time, get_tree().paused])
		get_tree().quit()
		return
	player.position = quest.pos + Vector3(1.5, 0, 1.0)
	snap_camera()
	await wait.call(0.6)
	menus._resume()
	quest.accept()
	for i in 8:
		var to: = (quest.exit_pos - player.position) * Vector3(1, 0, 1)
		var step: = map.slide(player.position, to.normalized() * minf(3.0, to.length()))
		player.position = Vector3(step.x, map.height_at(step), step.z)
		await wait.call(0.5)
	await _tour_shot("q13_escort")

	Save.complete_quest("orc_dun")
	Save.add_to_storage(Equipment.make("excalibur", 0))
	Save.add_to_storage(Equipment.make("boots", 2))
	Save.add_material("enriched_oridecon", 1)
	Save.add_material("elunium", 2)
	Save.add_zeny(30000)
	enter_town("swordsman")
	await wait.call(1.2)
	await _tour_shot("q14_town_leablem")
	menus.show_socket()
	await wait.call(0.5)
	await _tour_shot("q15_socket")
	menus._do_socket()
	await wait.call(0.8)
	await _tour_shot("q16_socket_done")
	menus._album_kind = "proc"
	menus.show_album()
	await wait.call(0.5)
	await _tour_shot("q17_album_proc")

	Save.add_to_storage(Equipment.make("blade", 1))
	var blade: Dictionary = Save.storage()[Save.storage().size() - 1]
	Save.add_material("oridecon", 3)
	menus._refine_uid = str(blade.uid)
	menus.show_refiner()
	await wait.call(0.5)
	menus._refine_mat = "oridecon"
	menus._do_refine()
	await wait.call(0.35)
	await _tour_shot("q18_refine_hammer")
	for i in 4:
		await wait.call(0.3)
		await _tour_shot("q19_refine_light_%d" % i)
	blade["refine"] = 7
	menus.show_refiner()
	await wait.call(0.3)
	menus._refine_confirm = "%s:7" % blade.uid
	menus._refine_confirm_at = Time.get_ticks_msec()
	menus.show_refiner()
	await wait.call(0.9)
	await _tour_shot("q20_refine_confirm")
	get_tree().quit()


func _tour_shot(label: String) -> void :
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [_shot_dir, label])


func _capture(label: String) -> void :
	if _shot_dir == "":
		return
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png("%s/%s_%s.png" % [_shot_dir, player.class_id, label])




func autopilot_input() -> Vector2:
	var v: = _autopilot_raw()
	if not showcase:
		return v
	_ap_hold -= get_process_delta_time()
	if v == Vector2.ZERO:
		return Vector2.ZERO
	var snapped: = Vector2.from_angle(snappedf(v.angle(), PI / 4.0))

	if not _ap_open(snapped):
		snapped = v.normalized()
	if _ap_dir == Vector2.ZERO or (_ap_hold <= 0.0 and snapped.dot(_ap_dir) < 0.99):
		_ap_dir = snapped
		_ap_hold = randf_range(0.25, 0.6)
	elif snapped.dot(_ap_dir) < -0.5 or not _ap_open(_ap_dir):
		_ap_dir = snapped
		_ap_hold = 0.3


	_ap_stuck_t += get_process_delta_time()
	if _ap_stuck_t >= 0.3:
		var moved: = (player.position - _ap_last) * Vector3(1, 0, 1)
		if v != Vector2.ZERO and moved.dot(Vector3(_ap_dir.x, 0, _ap_dir.y)) < 0.6:
			var turn: = v.normalized() if v.normalized().dot(_ap_dir) < 0.7 and _ap_open(v.normalized()) else Vector2.ZERO
			if turn == Vector2.ZERO:
				for k in [0.5, -0.5, 0.75, -0.75, 1.0]:
					var d: = _ap_dir.rotated(PI * k)
					if _ap_open(d):
						turn = d
						break
			_ap_dir = turn if turn != Vector2.ZERO else - _ap_dir
			_ap_hold = 1.2
		_ap_last = player.position
		_ap_stuck_t = 0.0
	return _ap_dir


func _ap_open(d: Vector2) -> bool:
	var p: = player.position
	var d3: = Vector3(d.x, 0, d.y)
	return map.is_walkable(p + d3 * 0.8) and map.is_walkable(p + d3 * 1.8) and map.is_walkable(p + d3 * 3.0)


func _autopilot_raw() -> Vector2:

	var fallen: = fallen_ally(player)
	if fallen != null:
		return Bot.steer(self, fallen.position)
	var goal: = raid.autopilot_goal()
	if goal == Vector3.INF:
		goal = morroc.autopilot_goal()
	if goal == Vector3.INF and tower != null and tower.state == "climb" and tower._stairs_at != Vector3.INF:
		goal = tower._stairs_at
	var altar: = Bot.altar_goal(self)
	if goal == Vector3.INF and altar != Vector3.INF:
		return Bot.steer(self, altar)
	if goal == Vector3.INF and quest.autopilot_goal() != Vector3.INF:

		return Bot.steer(self, quest.autopilot_goal())
	if goal != Vector3.INF:
		var to: = (goal - player.position) * Vector3(1, 0, 1)
		if to.length() < 0.3:
			return Vector2.ZERO
		to = to.normalized()
		return Vector2(to.x, to.z)
	if _slope_test:

		return Vector2(0, 1 if fmod(time, 4.0) < 2.0 else -1)

	return Bot.steer(self)



func _autopick_arrow() -> void :
	var near: = enemies_in_radius(player.position, 10.0)
	if near.is_empty():
		return
	var best: = player.arrow_id
	var best_score: = -1.0
	for a in player.quiver:
		var score: = 0.0
		for e in near:
			score += GameData.element_mult(player.ammo()[a].element, e.element())
		if score > best_score + 0.01:
			best_score = score
			best = a
	player.set_arrow(best)


func _finish_smoke() -> void :

	if net.is_host() and running and not net.peers.is_empty():
		if _smoke_ended:
			return
		_smoke_ended = true
		net.send_end(true)
		await get_tree().create_timer(1.5, true, false, true).timeout
	print("SMOKE class=%s time=%.1f level=%d xp_gained=%d kills=%d enemies=%d hp=%.0f skills=%s cards=%s boss=%s fps=%d" % [
		player.class_id, time, player.level, roundi(player.xp_gained), kills, enemies.size(), player.hp, 
		player.skills.keys(), player.cards, boss.id if boss else "-", Engine.get_frames_per_second()])
	print("SMOKE altars=%s" % [altars.taken])
	var gear: = []
	for k in player.equipment.slots:
		if player.equipment.slots[k] != null:
			gear.append(Equipment.item_name(player.equipment.slots[k]))
	print("SMOKE gear=%s ores=%s bag=%s zeny=%d" % [gear, player.equipment.ores, player.equipment.card_bag, run_zeny])
	print("SMOKE sets=%s procs=%d effects=%s aspd=%.0f evolved=%s" % [player.active_sets, player.procs.size(), player.effects, 
		player.aspd(), player.skills.keys().filter( func(k): return GameData.SKILLS[k].get("evolved", false))])
	print("SMOKE specials=%s pet=%s quiver=%s arrow=%s" % [smoke_stats, pet_id, player.quiver, player.arrow_id])
	if quest.stage_id != "" and GameData.QUESTS.has(quest.stage_id):
		print("SMOKE quest=%s state=%s result=%s hp=%d/%d dish=%s" % [quest.stage_id, quest.state, quest.result, 
			quest.hp, quest.max_hp, player.dishes])
	var top: = []
	for r in meter_sorted().slice(0, 6):
		top.append("%s=%d" % [r.tag, roundi(r.dmg)])
	print("SMOKE meter=%s" % [top])
	SoulLinker.sim_report(self)
	var total_dmg: = 0.0
	for r in meter_sorted():
		total_dmg += float(r.dmg)
	print("SMOKE total_dmg=%d dps=%d job=%s danger=%d" % [roundi(total_dmg), roundi(total_dmg / maxf(1.0, time)), str(player.job2.get("id", "")), danger])
	for h in (heroes if heroes.size() > 1 else []):
		var mine: Dictionary = meter_hero[h.slot]
		var total: = 0.0
		for k in mine:
			total += float(mine[k].dmg)
		var tags: = mine.keys()
		tags.sort_custom( func(a, b): return mine[a].dmg > mine[b].dmg)
		print("COOP hero %d %s lv=%d dmg=%d zeny=%d ores=%s top=%s ally_buffs=%s skills=%s" % [h.slot, h.class_id, h.level, total, zeny_of(h), h.equipment.ores, tags.slice(0, 4), h.party_buffs.keys(), h.skills.keys()])
	if heroes.size() > 1:
		print("COOP unowned=%s" % [unowned])
	if morroc.stats.seen:
		print("SMOKE morroc state=%s fight=%.0fs phase=%d fails=%d won=%s boss_hp=%s" % [morroc.state, morroc.stats.time, 
			morroc.stats.phase + 1, morroc.stats.fails, morroc.stats.won, 
			"%d%%" % roundi(100.0 * morroc.boss.hp / morroc.boss.max_hp) if morroc.boss != null and is_instance_valid(morroc.boss) else "-"])
	if raid.stats.mvp != "":
		print("SMOKE raid=%s state=%s fight=%.0fs phase=%d fails=%d boss_hp=%s" % [raid.stats.mvp, raid.state, 
			raid.stats.time, raid.stats.phase + 1, raid.stats.fails, 
			"%d%%" % roundi(100.0 * raid.boss.hp / raid.boss.max_hp) if raid.boss != null and is_instance_valid(raid.boss) else "-"])
	var n: = maxi(1, _perf.frames)
	print("PERF ms/frame: director=%.2f player=%.2f enemies=%.2f projectiles=%.2f pickups=%.2f (frames=%d)" % [
		_perf.director / 1000.0 / n, _perf.player / 1000.0 / n, _perf.enemies / 1000.0 / n, 
		_perf.projectiles / 1000.0 / n, _perf.pickups / 1000.0 / n, n])
	get_tree().quit()
