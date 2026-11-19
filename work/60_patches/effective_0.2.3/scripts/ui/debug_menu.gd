class_name DebugMenu
extends CanvasLayer





const W: = 440.0
const SPEEDS: = [0.25, 0.5, 1.0, 2.0, 4.0, 8.0]

var world: World
var _panel: PanelContainer
var _info: Label
var _badge: Label
var _tabs: TabContainer
var _info_t: = 0.0
var _god: = false
var _used: = false
var _oneshot: = false
var _dps_samples: Array = []
var _confirm: = {}

var _run_class: OptionButton
var _run_stage: OptionButton
var _run_danger: SpinBox
var _skill_pick: OptionButton
var _mob_pick: OptionButton
var _mob_count: SpinBox
var _item_pick: OptionButton
var _card_pick: OptionButton
var _danger_now: SpinBox
var _prof_class: OptionButton
var _prof_level: SpinBox
var _prof_info: Label


static func enabled() -> bool:
	return OS.has_feature("editor")


func _init(p_world: World) -> void :
	world = p_world
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void :

	_badge = UiKit.label("", 13, Color(1, 0.85, 0.4), true)
	_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_badge.anchor_right = 1.0
	_badge.offset_top = 4.0
	add_child(_badge)
	_panel = PanelContainer.new()
	var box: = UiKit.panel_box(UiKit.PANEL, UiKit.GOLD_DIM, 8)
	box.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", box)
	_panel.visible = false
	add_child(_panel)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_panel.add_child(col)
	col.add_child(UiKit.title_strip("Debug  ·  Alt+F1", 14))
	_info = UiKit.label("", 11, UiKit.TEXT)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_info.custom_minimum_size = Vector2(W - 20.0, 0)
	col.add_child(_info)
	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.add_theme_font_size_override("font_size", 13)
	_style_tabs(_tabs)
	col.add_child(_tabs)
	get_viewport().size_changed.connect(_layout)
	_layout()
	var args: = OS.get_cmdline_user_args()

	if "--smithlab" in args:
		var lab: Node = preload("res://scripts/ui/smith_lab.gd").new()
		add_child(lab)
		lab.call("start", world, self, args)
	if "--debug-test" in args:
		_self_test(args[args.find("--debug-test") + 1])
	elif "--hover-test" in args:
		_hover_test(args[args.find("--hover-test") + 1])
	elif "--eternal-test" in args:
		_eternal_test(args[args.find("--eternal-test") + 1])
	elif "--update-test" in args:
		_update_test(args[args.find("--update-test") + 1])
	elif "--petalbum-test" in args:
		_petalbum_test(args[args.find("--petalbum-test") + 1])
	elif "--taekwon-test" in args:
		_taekwon_test(args[args.find("--taekwon-test") + 1])
	elif "--doram-test" in args:
		_doram_test(args[args.find("--doram-test") + 1])
	elif "--songs-test" in args:
		_songs_test(args[args.find("--songs-test") + 1])
	elif "--rebirthlv-test" in args:
		_rebirthlv_test(args[args.find("--rebirthlv-test") + 1])
	elif "--gacha-test" in args:
		_gacha_test(args[args.find("--gacha-test") + 1])
	elif "--wings-test" in args:
		_wings_test(args[args.find("--wings-test") + 1])
	elif "--buyclass-test" in args:
		_buyclass_test(args[args.find("--buyclass-test") + 1])
	elif "--frenzybtn-test" in args:
		_frenzybtn_test(args[args.find("--frenzybtn-test") + 1])
	elif "--navrail-test" in args:
		_navrail_test(args[args.find("--navrail-test") + 1])
	elif "--legends-test" in args:
		_legends_test(args[args.find("--legends-test") + 1])
	elif "--fetch-test" in args:
		_fetch_test(args[args.find("--fetch-test") + 1])
	elif "--tower-test" in args:
		_tower_test(args[args.find("--tower-test") + 1])
	elif "--face-test" in args:
		_face_test(args[args.find("--face-test") + 1])
	elif "--naght-test" in args:
		_naght_test(args[args.find("--naght-test") + 1], args[args.find("--naght-test") + 2] if args.size() > args.find("--naght-test") + 2 else "")
	elif "--pin-test" in args:
		_pin_test(args[args.find("--pin-test") + 1])
	elif "--tower-art" in args:
		_tower_art(args[args.find("--tower-art") + 1])
	elif "--climb-test" in args:
		_climb_test(args[args.find("--climb-test") + 1])
	elif "--fxsheet-test" in args:
		_fxsheet_test(args[args.find("--fxsheet-test") + 1], args[args.find("--fxsheet-test") + 2])
	elif "--gems-test" in args:
		_gems_test(args[args.find("--gems-test") + 1])
	elif "--camturn-test" in args:
		_camturn_test(args[args.find("--camturn-test") + 1])
	elif "--guns-test" in args:
		_guns_test(args[args.find("--guns-test") + 1])
	elif "--morroc-test" in args:
		_morroc_test(args[args.find("--morroc-test") + 1])
	elif "--broadcast-test" in args:
		_broadcast_test(args[args.find("--broadcast-test") + 1])
	elif "--prochit-test" in args:
		_prochit_test(args[args.find("--prochit-test") + 1])
	elif "--claim-test" in args:
		_claim_test(args[args.find("--claim-test") + 1])
	elif "--stone-test" in args:
		_stone_test(args[args.find("--stone-test") + 1])
	elif "--elword-test" in args:
		_elword_test(args[args.find("--elword-test") + 1])
	elif "--townesc-test" in args:
		_townesc_test(args[args.find("--townesc-test") + 1])
	elif "--aura-test" in args:
		_aura_test(args[args.find("--aura-test") + 1])
	elif "--altar-test" in args:
		_altar_test(args[args.find("--altar-test") + 1])
	elif "--atlasdemo-test" in args:
		_atlasdemo_test(args[args.find("--atlasdemo-test") + 1])
	elif "--towerwheel-test" in args:
		_towerwheel_test(args[args.find("--towerwheel-test") + 1])
	elif "--towerevents-test" in args:
		_towerevents_test(args[args.find("--towerevents-test") + 1])
	elif "--towertraps-test" in args:
		_towertraps_test(args[args.find("--towertraps-test") + 1])
	elif "--procrogue-test" in args:
		_procrogue_test()
	elif "--itempane-test" in args:
		_itempane_test(args[args.find("--itempane-test") + 1])
	elif "--taunt-test" in args:
		_taunt_test()
	elif "--karmabar-test" in args:
		_karmabar_test(args[args.find("--karmabar-test") + 1])
	elif "--sinhands-test" in args:
		_sinhands_test(args[args.find("--sinhands-test") + 1])
	elif "--stewbuild-test" in args:
		_stewbuild_test()
	elif "--keeptower-test" in args:
		_keeptower_test()
	elif "--touchsell-test" in args:
		_touchsell_test(args[args.find("--touchsell-test") + 1])
	elif "--quake-test" in args:
		_quake_test(args[args.find("--quake-test") + 1])
	elif "--hidpi-test" in args:
		_hidpi_test(args[args.find("--hidpi-test") + 1])
	elif "--records-test" in args:
		_records_test(args[args.find("--records-test") + 1])
	elif "--esc-test" in args:
		_esc_test()
	elif "--upgrades-test" in args:
		_upgrades_test(args[args.find("--upgrades-test") + 1])
	elif "--invfull-test" in args:
		_invfull_test(args[args.find("--invfull-test") + 1])
	elif "--hold-test" in args:
		_hold_test()
	elif "--levels-test" in args:
		_levels_test(args[args.find("--levels-test") + 1])
	elif "--portal-test" in args:
		_portal_test(args[args.find("--portal-test") + 1])
	elif "--aspd-test" in args:
		_aspd_test()
	elif "--arena-map-test" in args:
		_arena_map_test()
	elif "--arenasurvey-test" in args:
		_arena_survey_test()
	elif "--arenaflat-test" in args:
		_arena_flat_test(str(args[args.find("--arenaflat-test") + 1]), str(args[args.find("--arenaflat-test") + 2]))
	elif "--crusader-test" in args:
		_crusader_test(args[args.find("--crusader-test") + 1])
	elif "--skillbar-test" in args:
		_skillbar_test(args[args.find("--skillbar-test") + 1])
	elif "--title-test" in args:
		_title_test(args[args.find("--title-test") + 1])
	elif "--clownpick-test" in args:
		_clownpick_test(args[args.find("--clownpick-test") + 1])
	elif "--banishstat-test" in args:
		_banishstat_test()
	elif "--batch21-test" in args:
		_batch21_test(args[args.find("--batch21-test") + 1])
	elif "--dual-test" in args:
		_dual_test(args[args.find("--dual-test") + 1])
	elif "--buffrow-test" in args:
		_buffrow_test(args[args.find("--buffrow-test") + 1])
	elif "--traps-test" in args:
		_traps_test(args[args.find("--traps-test") + 1])
	elif "--merge-test" in args:
		_merge_test(args[args.find("--merge-test") + 1])
	elif "--invcut-test" in args:
		_invcut_test(args[args.find("--invcut-test") + 1])
	elif "--chestglow-test" in args:
		_chestglow_test(args[args.find("--chestglow-test") + 1])
	elif "--streak-test" in args:
		_streak_test(args[args.find("--streak-test") + 1])
	elif "--questicon-test" in args:
		_questicon_test(args[args.find("--questicon-test") + 1])
	elif "--gallop-test" in args:
		_gallop_test(args[args.find("--gallop-test") + 1])
	elif "--snare-test" in args:
		_snare_test(args[args.find("--snare-test") + 1])
	elif "--shiftcmp-test" in args:
		_shiftcmp_test(args[args.find("--shiftcmp-test") + 1])
	elif "--switch-test" in args:
		_switch_test(args[args.find("--switch-test") + 1])
	elif "--togglepop-test" in args:
		_togglepop_test(args[args.find("--togglepop-test") + 1])
	elif "--snbuild-test" in args:
		_snbuild_test(args[args.find("--snbuild-test") + 1])
	elif "--snmult-test" in args:
		_snmult_test(args[args.find("--snmult-test") + 1])
	elif "--hypernovice-test" in args:
		_hypernovice_test(args[args.find("--hypernovice-test") + 1])
	elif "--thorset-test" in args:
		_thorset_test(args[args.find("--thorset-test") + 1])
	elif "--monkcombo-test" in args:
		_monkcombo_test(args[args.find("--monkcombo-test") + 1])
	elif "--pose-test" in args:
		_pose_test(args[args.find("--pose-test") + 1])
	elif "--hypnoui-test" in args:
		_hypnoui_test(args[args.find("--hypnoui-test") + 1])
	elif "--heat-test" in args:
		_heat_test(args[args.find("--heat-test") + 1])
	elif "--hires-test" in args:
		_hires_test(args[args.find("--hires-test") + 1])
	elif "--townsound-test" in args:
		_townsound_test()
	elif "--newmaps-test" in args:
		_newmaps_test(args[args.find("--newmaps-test") + 1])
	elif "--ruwach-test" in args:
		_ruwach_test(args[args.find("--ruwach-test") + 1])
	elif "--monk-test" in args:
		_monk_test(args[args.find("--monk-test") + 1])
	elif "--karma-test" in args:
		var at: = args.find("--karma-test")
		_karma_test(args[at + 1], args[at + 2] if args.size() > at + 2 and not str(args[at + 2]).begins_with("--") else "light")
	elif "--status-test" in args:
		_status_test(args[args.find("--status-test") + 1])
	elif "--occult-test" in args:
		_occult_test(args[args.find("--occult-test") + 1])
	elif "--mvpfx-test" in args:
		var i: = args.find("--mvpfx-test")
		_mvpfx_test(args[i + 1], args[i + 2] if args.size() > i + 2 else "ork_hero")
	elif "--pacts-test" in args:
		_pacts_test(args[args.find("--pacts-test") + 1])
	elif "--protect-test" in args:
		_protect_test(args[args.find("--protect-test") + 1])
	elif "--mvphp-test" in args:
		_mvphp_test()
	elif "--rebirthui-test" in args:
		_rebirthui_test(args[args.find("--rebirthui-test") + 1])
	elif "--tank-test" in args:
		_tank_test(args[args.find("--tank-test") + 1], args[args.find("--tank-test") + 2])
	elif "--party-test" in args:
		_party_test(args[args.find("--party-test") + 1])
	elif "--coop-ui-test" in args:
		_coop_ui_test(args[args.find("--coop-ui-test") + 1])
	elif "--partyhud-test" in args:
		_partyhud_test(args[args.find("--partyhud-test") + 1])
	elif "--coopwin-test" in args:
		_coopwin_test(args[args.find("--coopwin-test") + 1])
	elif "--chef-test" in args:
		_chef_test(args[args.find("--chef-test") + 1])
	elif "--prep-test" in args:
		_prep_test(args[args.find("--prep-test") + 1])

	elif "--procs-test" in args:
		_procs_test(args[args.find("--procs-test") + 1])
	elif "--meter-test" in args:
		_meter_test(args[args.find("--meter-test") + 1])
	elif "--unique-test" in args:
		_unique_test(args[args.find("--unique-test") + 1])
	elif "--combo-test" in args:
		_combo_test(args[args.find("--combo-test") + 1])
	elif "--lethal-test" in args:
		_lethal_test(args[args.find("--lethal-test") + 1])
	elif "--cleave-test" in args:
		_cleave_test()
	elif "--job-show-test" in args:
		_job_show_test(args[args.find("--job-show-test") + 1])
	elif "--eos-quit-test" in args:
		_eos_quit_test()
	elif "--coins-test" in args:
		_coins_test(args[args.find("--coins-test") + 1])
	elif "--runopts-test" in args:
		_runopts_test(args[args.find("--runopts-test") + 1])
	elif "--options-test" in args:
		_options_test(args[args.find("--options-test") + 1])
	elif "--goldbox-test" in args:
		_goldbox_test(args[args.find("--goldbox-test") + 1])
	elif "--banish-test" in args:
		_banish_test()
	elif "--statmax-test" in args:
		_statmax_test(args[args.find("--statmax-test") + 1])
	elif "--startpick-test" in args:
		_startpick_test(args[args.find("--startpick-test") + 1])
	elif "--jobpick-test" in args:
		_jobpick_test(args[args.find("--jobpick-test") + 1])
	elif "--mvpchest-test" in args:
		_mvpchest_test()
	elif "--npc-test" in args:
		_npc_test(args[args.find("--npc-test") + 1])
	elif "--crit-test" in args:
		_crit_test(args[args.find("--crit-test") + 1])
	elif "--frenzy-test" in args:
		_frenzy_test(args[args.find("--frenzy-test") + 1])
	elif "--storm-test" in args:
		_storm_test(args[args.find("--storm-test") + 1])
	elif "--guard-test" in args:
		_guard_test(args[args.find("--guard-test") + 1])
	elif "--peco-test" in args:
		_peco_test(args[args.find("--peco-test") + 1])
	elif "--fists-test" in args:
		_fists_test(args[args.find("--fists-test") + 1])
	elif "--charge-test" in args:
		_charge_test(args[args.find("--charge-test") + 1])
	elif "--sig-test" in args:
		_sig_test(args[args.find("--sig-test") + 1])
	elif "--unique-bench" in args:
		_unique_bench()
	elif "--rail-test" in args:
		_rail_test(args[args.find("--rail-test") + 1])
	elif "--sideword-test" in args:
		_sideword_test(args[args.find("--sideword-test") + 1])
	elif "--evodup-test" in args:
		_evodup_test()
	elif "--orbit-test" in args:
		_orbit_test(args[args.find("--orbit-test") + 1])
	elif "--towerhud-test" in args:
		_towerhud_test(args[args.find("--towerhud-test") + 1])
	elif "--trainsafe-test" in args:
		_trainsafe_test()
	elif "--trainreset-test" in args:
		_trainreset_test(args[args.find("--trainreset-test") + 1])
	elif "--festbuff-test" in args:
		_festbuff_test()
	elif "--towerbuff-test" in args:
		_towerbuff_test(args[args.find("--towerbuff-test") + 1])
	elif "--seek-test" in args:
		_seek_test()
	elif "--potion-test" in args:
		_potion_test(args[args.find("--potion-test") + 1])
	elif "--critnum-test" in args:
		_critnum_test(args[args.find("--critnum-test") + 1])
	elif "--falcon-test" in args:
		_falcon_test(args[args.find("--falcon-test") + 1])
	elif "--ninja-test" in args:
		_ninja_test(args[args.find("--ninja-test") + 1])
	elif "--filter-test" in args:
		_filter_test(args[args.find("--filter-test") + 1])
	elif "--privacy-test" in args:
		_privacy_test(args[args.find("--privacy-test") + 1])
	elif "--screens-test" in args:
		_screens_test(args[args.find("--screens-test") + 1])


func _layout() -> void :
	var view: = get_viewport().get_visible_rect().size
	_panel.position = Vector2(view.x - W - 8.0, 8.0)
	_panel.size = Vector2(W, view.y - 16.0)


func _input(event: InputEvent) -> void :
	var k: = event as InputEventKey
	if k != null and k.pressed and not k.echo and k.keycode == KEY_F1 and k.alt_pressed:
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void :
	_used = true
	_panel.visible = not _panel.visible
	if _panel.visible:
		_rebuild()


func _process(delta: float) -> void :
	var p: = world.player if world.running and is_instance_valid(world.player) else null
	if p != null:
		if _god:
			p.hp = p.max_hp

		if _oneshot and p.dmg_mult < 1000.0:
			p.dmg_mult *= 10000.0
	var tags: = []
	if not is_equal_approx(Engine.time_scale, 1.0):
		tags.append("x%s" % str(Engine.time_scale))
	if _god:
		tags.append("GOD")
	if _oneshot:
		tags.append("ONE-SHOT")
	if GameData.has_meta("no_spawn"):
		tags.append("NO SPAWN")

	_badge.text = ("DEBUG  " + "  ".join(tags)) if not tags.is_empty() and _used else ""
	_info_t -= delta
	if _info_t > 0.0:
		return
	_info_t = 0.25
	if world.running:
		_dps_samples.append([world.time, float(world.meter_stats.get("total", 0.0))])
		while _dps_samples.size() > 1 and world.time - float(_dps_samples[0][0]) > 5.0:
			_dps_samples.pop_front()
	if _panel.visible:
		_info.text = _info_text()
		if _prof_info != null and is_instance_valid(_prof_info):
			_prof_info.text = _profile_text()





func _style_tabs(t: TabContainer) -> void :
	var body: = StyleBoxFlat.new()
	body.bg_color = UiKit.PANEL_SOFT
	body.border_color = UiKit.GOLD_DIM
	body.set_border_width_all(1)
	body.set_corner_radius_all(4)
	body.set_content_margin_all(8)
	t.add_theme_stylebox_override("panel", body)
	for k in ["tab_selected", "tab_unselected", "tab_hovered"]:
		var tab: = StyleBoxFlat.new()
		tab.bg_color = UiKit.PANEL_SOFT if k == "tab_selected" else (Color(0.86, 0.88, 0.93) if k == "tab_unselected" else Color(0.95, 0.96, 0.99))
		tab.border_color = UiKit.GOLD if k == "tab_selected" else UiKit.GOLD_DIM
		tab.set_border_width_all(1)
		tab.border_width_top = 3 if k == "tab_selected" else 1
		tab.corner_radius_top_left = 4
		tab.corner_radius_top_right = 4
		tab.content_margin_left = 12
		tab.content_margin_right = 12
		tab.content_margin_top = 4
		tab.content_margin_bottom = 4
		t.add_theme_stylebox_override(k, tab)
	t.add_theme_color_override("font_selected_color", UiKit.TEXT)
	t.add_theme_color_override("font_unselected_color", UiKit.MUTED)
	t.add_theme_color_override("font_hovered_color", UiKit.TEXT)



func _style_button(b: Button) -> void :
	var ref: = UiKit.button("")
	for k in ["normal", "hover", "pressed", "focus"]:
		var sb: = (ref.get_theme_stylebox(k) as StyleBox).duplicate() as StyleBoxFlat
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
		b.add_theme_stylebox_override(k, sb)
	for c in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color"]:
		b.add_theme_color_override(c, UiKit.TEXT)
	b.add_theme_font_override("font", UiKit.FONT_BODY)
	ref.free()

func _page(title: String) -> VBoxContainer:
	var scroll: = ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tabs.add_child(scroll)
	var col: = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 4)
	scroll.add_child(col)
	return col


func _section(parent: Control, text: String) -> void :
	var l: = UiKit.label(text, 12, UiKit.GOLD, true)
	parent.add_child(l)


func _row(parent: Control) -> HFlowContainer:
	var r: = HFlowContainer.new()
	r.add_theme_constant_override("h_separation", 4)
	r.add_theme_constant_override("v_separation", 4)
	parent.add_child(r)
	return r


func _btn(parent: Control, text: String, fn: Callable, primary: = false) -> Button:
	var b: = UiKit.button(text, primary)
	b.custom_minimum_size = Vector2(0, 26)
	b.add_theme_font_size_override("font_size", 12)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(fn)
	parent.add_child(b)
	return b



func _danger_btn(parent: Control, text: String, fn: Callable) -> void :
	var b: = UiKit.button(text)
	b.custom_minimum_size = Vector2(0, 26)
	b.add_theme_font_size_override("font_size", 12)
	b.focus_mode = Control.FOCUS_NONE
	for c in ["font_color", "font_hover_color", "font_pressed_color"]:
		b.add_theme_color_override(c, Color(0.75, 0.1, 0.1))
	parent.add_child(b)
	b.pressed.connect(_confirm_press.bind(b, text, fn))


func _confirm_press(b: Button, text: String, fn: Callable) -> void :
	var now: = Time.get_ticks_msec()
	if now - int(_confirm.get(text, -99999)) < 3000:
		_confirm.erase(text)
		b.text = text
		fn.call()
		return
	_confirm[text] = now
	b.text = "¿Seguro? pulsa otra vez"
	get_tree().create_timer(3.0, true, false, true).timeout.connect( func():
		if is_instance_valid(b):
			b.text = text)


func _pick(parent: Control, items: Array, selected: = "") -> OptionButton:
	var o: = OptionButton.new()
	o.focus_mode = Control.FOCUS_NONE
	o.add_theme_font_size_override("font_size", 12)
	o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	o.fit_to_longest_item = false
	o.custom_minimum_size = Vector2(160, 0)
	_style_button(o)
	for it in items:
		o.add_item(str(it[1]))
		o.set_item_metadata(o.item_count - 1, it[0])
		if str(it[0]) == selected:
			o.select(o.item_count - 1)
	parent.add_child(o)
	return o


func _picked(o: OptionButton) -> String:
	return str(o.get_item_metadata(o.selected)) if o != null and o.selected >= 0 else ""


func _spin(parent: Control, lo: float, hi: float, value: float) -> SpinBox:
	var s: = SpinBox.new()
	s.min_value = lo
	s.max_value = hi
	s.value = value
	s.rounded = true
	s.focus_mode = Control.FOCUS_NONE
	var edit: = s.get_line_edit()
	edit.add_theme_font_size_override("font_size", 12)
	edit.add_theme_color_override("font_color", UiKit.TEXT)
	var sb: = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.border_color = Color(0.62, 0.64, 0.7)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(4)
	sb.set_content_margin_all(4)
	edit.add_theme_stylebox_override("normal", sb)
	edit.add_theme_stylebox_override("focus", sb)
	parent.add_child(s)
	return s


func _named(dict: Dictionary, filter: = Callable()) -> Array:
	var out: = []
	for id in dict:
		if filter.is_valid() and not filter.call(id):
			continue
		out.append([id, "%s  (%s)" % [str(dict[id].get("name", id)), id]])
	out.sort_custom( func(a, b): return str(a[1]).naturalnocasecmp_to(str(b[1])) < 0)
	return out


func _toast(text: String) -> void :
	print("DEBUG ", text)
	if world.hud != null and world.running:
		world.hud.announce(text, Color(1, 0.85, 0.4))




func _rebuild() -> void :
	var keep: = _tabs.current_tab
	for c in _tabs.get_children():
		_tabs.remove_child(c)
		c.queue_free()
	_prof_info = null
	_build_run()
	_build_hero()
	_build_loot()
	_build_profile()
	if keep >= 0 and keep < _tabs.get_tab_count():
		_tabs.current_tab = keep


func _build_run() -> void :
	var col: = _page("Partida")
	_section(col, "Velocidad del juego (Engine.time_scale)")
	var r: = _row(col)
	for s in SPEEDS:
		_btn(r, "x%s" % str(s), func(): Engine.time_scale = s, is_equal_approx(Engine.time_scale, s))
	r = _row(col)
	_btn(r, "Pausa on/off", func(): get_tree().paused = not get_tree().paused)
	_btn(r, "Spawns on/off", func():
		if GameData.has_meta("no_spawn"):
			GameData.remove_meta("no_spawn")
		else:
			GameData.set_meta("no_spawn", true))
	_section(col, "Empezar una partida")
	r = _row(col)
	var cls: = world.player.class_id if world.running and is_instance_valid(world.player) else "swordsman"
	_run_class = _pick(r, _named(GameData.CLASSES), cls)
	r = _row(col)
	_run_stage = _pick(r, _named(GameData.STAGES), world.stage_id)
	r = _row(col)
	r.add_child(UiKit.label("Peligro", 12))
	_run_danger = _spin(r, 1, GameData.DANGER_MAX, world.danger)
	r = _row(col)
	_btn(r, "Iniciar", func(): _start(false), true)
	_btn(r, "Iniciar en el MVP", func(): _start(true))
	_btn(r, "Torre: pelea del piso 100", _tower_100)
	r = _row(col)
	r.add_child(UiKit.label("Torre de Hel, piso", 12))
	var hel_floor: = _spin(r, 1, 200, 1)
	_btn(r, "Bajar", func(): _hel_tower(int(hel_floor.value)))
	_btn(r, "+2 Lágrimas", func():
		Save.add_material("hel_tear", 2)
		_toast("Lágrimas de Hel: %d" % Save.material("hel_tear")))
	if not world.running:
		return
	_section(col, "Reloj de la partida  (%s)" % UiKit.time_text(world.time))
	r = _row(col)
	for secs in [30, 60, 300]:
		_btn(r, "+%s" % UiKit.time_text(secs), func(): _advance(secs))
	_btn(r, "Saltar al MVP", func(): _to_mvp(false))
	_btn(r, "Entrar al MVP", func(): _to_mvp(true))
	_section(col, "Peligro de esta partida (monstruos nuevos)")
	r = _row(col)
	_danger_now = _spin(r, 1, GameData.DANGER_MAX, world.danger)
	_btn(r, "Aplicar", func(): _set_danger(int(_danger_now.value)))
	_section(col, "Monstruos")
	r = _row(col)
	_mob_pick = _pick(r, _named(GameData.MONSTERS), str(world.stage.mvp))
	r = _row(col)
	_mob_count = _spin(r, 1, 100, 1)
	_btn(r, "Spawn", func(): _spawn(false))
	_btn(r, "Spawn feroz", func(): _spawn(true))
	r = _row(col)
	for kind in GameData.SPECIAL_KINDS:
		if kind != "feroz":
			_btn(r, "Spawn %s" % kind, func(): _spawn(true, kind))
	_btn(r, "Poring Dorado", func(): world.spawn_runner())
	r = _row(col)
	_btn(r, "Matar todo", _kill_all)
	_btn(r, "Matar jefe / MVP", _kill_boss)
	_btn(r, "Elite del mapa", _stage_elite)
	_btn(r, "Satan Morroc", _spawn_morroc)
	_btn(r, "Final de Infinito", _spawn_finale)
	_section(col, "Terminar")
	r = _row(col)
	_btn(r, "Ganar partida", func(): world._end_run(true))
	_btn(r, "Perder partida", func(): world._end_run(false))
	_btn(r, "Modo infinito", func():
		if not world.endless:
			world.continue_endless())


func _build_hero() -> void :
	var col: = _page("Héroe")
	if not world.running or not is_instance_valid(world.player):
		col.add_child(UiKit.label("Empieza una partida para usar esta pestaña.", 12, UiKit.MUTED))
		return
	var p: = world.player


	_section(col, "Héroe de prueba (todo al máximo)")
	var r: = _row(col)
	if p.job2.is_empty():
		var hero_paths: = GameData.job_paths(p.class_id)
		for i in hero_paths.size():
			_btn(r, "Al máximo como %s" % str(hero_paths[i].name), func(): _max_hero(i), i == 0)
		if hero_paths.is_empty():
			_btn(r, "Al máximo", func(): _max_hero(-1), true)
	else:
		_btn(r, "Al máximo (%s)" % p.job_name(), func(): _max_hero(-1), true)
	_btn(r, "Solo el equipo al máximo", func():
		_max_gear(p)
		_toast("Equipo al máximo")
		_rebuild())
	_btn(r, "Potencial perfecto al equipo", func():
		for k in p.equipment.slots:
			if p.equipment.slots[k] != null:
				_max_pot(p.equipment.slots[k])
		p.recompute()
		_toast("Potencial Legendario perfecto en todo")
		_rebuild())
	_section(col, "Supervivencia")
	r = _row(col)
	var god: = func():
		_god = not _god

		if _god:
			GameData.set_meta("tour_god", true)
		else:
			GameData.remove_meta("tour_god")
		_rebuild()
	_btn(r, "Vida infinita: %s" % ("SÍ" if _god else "no"), god, _god)
	_btn(r, "Siguiente fase del MVP", _next_phase)
	var oneshot: = func():
		_oneshot = not _oneshot
		if not _oneshot:
			p.recompute()
		_rebuild()
	_btn(r, "Un golpe mata: %s" % ("SÍ" if _oneshot else "no"), oneshot, _oneshot)
	r = _row(col)
	_btn(r, "Curar", func(): p.hp = p.max_hp)
	_btn(r, "Vida a 10%", func(): p.hp = p.max_hp * 0.1)
	_btn(r, "+1 resurrección", func(): p.revives += 1)
	_btn(r, "Recargar habilidades", func(): p.cut_cooldowns(999.0))
	_section(col, "Nivel  (Lv %d)" % p.level)
	r = _row(col)
	_btn(r, "+1 nivel (elegir)", func(): p.add_xp((p.xp_need - p.xp) / maxf(0.01, p.pace_xp * p.xp_mult) + 0.01))
	_btn(r, "+5 auto", func(): _auto_levels(5))
	_btn(r, "+20 auto", func(): _auto_levels(20))
	r = _row(col)
	if p.job2.is_empty():
		var paths: = GameData.job_paths(p.class_id)
		for i in paths.size():
			_btn(r, "Cambio a %s" % str(paths[i].name), func():
				world.do_job_change(i)
				_rebuild())
	_section(col, "Habilidades")
	r = _row(col)
	var pool: = []
	for id in p.skill_pool() + p.passive_pool():
		if GameData.SKILLS.has(id) and not pool.any( func(x): return x[0] == id):
			var lv: = int(p.skills[id].level) if p.skills.has(id) else 0
			pool.append([id, "%s  Lv %d%s" % [str(GameData.SKILLS[id].name), lv, 
				"  (pasiva)" if GameData.SKILLS[id].type == "passive" else ""]])
	_skill_pick = _pick(r, pool)
	r = _row(col)
	_btn(r, "+1 nivel", func():
		var id: = _picked(_skill_pick)
		if id != "" and ( not p.skills.has(id) or int(p.skills[id].level) < GameData.MAX_SKILL_LEVEL):
			p.add_skill(id)
			p.recompute()
			world.hud.bind(world)
			_rebuild())
	_btn(r, "Todas al máximo", func():
		for id in p.skills:
			if not GameData.SKILLS[id].get("evolved", false):
				p.skills[id].level = GameData.MAX_SKILL_LEVEL
		p.recompute()
		_rebuild())
	_btn(r, "Evolucionar todas", func():
		var n: = 0
		for id in p.skills.keys():
			if GameData.EVOLUTIONS.has(id):
				p.evolve(id)
				n += 1
		p.recompute()
		world.hud.bind(world)
		_toast("%d evoluciones" % n)
		_rebuild())
	_section(col, "Atributos (+5)")
	r = _row(col)
	for st in p.stats:
		var add: = func():
			for i in 5:
				p.add_stat(st)
		_btn(r, str(st).to_upper(), add)
	_section(col, "Poderes")
	r = _row(col)
	for id in GameData.POWER_DROPS:
		_btn(r, str(GameData.POWER_DROPS[id].get("name", id)), func(): p.add_power(id))


func _build_loot() -> void :
	var col: = _page("Botín")
	if not world.running or not is_instance_valid(world.player):
		col.add_child(UiKit.label("Empieza una partida para usar esta pestaña.", 12, UiKit.MUTED))
		return
	var p: = world.player
	_section(col, "Cofres")
	var r: = _row(col)
	_btn(r, "Pequeño", func(): world._drop_chest(_near(), 1, -1))
	_btn(r, "Elite", func(): world._drop_chest(_near(), GameData.CHEST_ROLLS.elite, 0))
	_btn(r, "Jefe", func(): world._drop_chest(_near(), GameData.CHEST_ROLLS.boss, 1))
	_btn(r, "MVP", func(): world._drop_chest(_near(), GameData.CHEST_ROLLS.boss, 2))
	_section(col, "Equipo")
	r = _row(col)
	_item_pick = _pick(r, _named(GameData.ITEMS, func(id): return GameData.ITEMS[id].get("legendary", false)))
	r = _row(col)
	_btn(r, "Dar legendario", func(): _give_item(_picked(_item_pick), 0))
	r = _row(col)
	var all: = _named(GameData.ITEMS, func(id): return not GameData.ITEMS[id].get("legendary", false))
	var common: = _pick(r, all)
	r = _row(col)
	for n in 4:
		_btn(r, "Dar (%d ranuras)" % n, func(): _give_item(_picked(common), n))
	r = _row(col)
	_btn(r, "+10 Oridecon", func(): p.equipment.ores.oridecon = int(p.equipment.ores.oridecon) + 10)
	_btn(r, "+10 Elunium", func(): p.equipment.ores.elunium = int(p.equipment.ores.elunium) + 10)
	_btn(r, "+10000 zeny", func(): world.add_zeny(10000, "debug"))
	_btn(r, "+20 Star Crumbs", func():
		Save.add_material("star_crumb", 20)
		_toast("Star Crumbs: %d" % Save.material("star_crumb")))
	_section(col, "Cartas")
	r = _row(col)
	_card_pick = _pick(r, _named(GameData.CARDS))
	r = _row(col)
	_btn(r, "Dar carta", func():
		var id: = _picked(_card_pick)
		if id != "":
			_toast("Carta: %s → %s" % [id, p.add_card(id)]))
	_btn(r, "Carta al azar", func():
		var id: String = GameData.CARDS.keys().pick_random()
		_toast("Carta: %s → %s" % [id, p.add_card(id)]))


func _build_profile() -> void :
	var col: = _page("Perfil")
	_prof_info = UiKit.label("", 11, UiKit.TEXT)
	_prof_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_prof_info.custom_minimum_size = Vector2(W - 40.0, 0)
	_prof_info.text = _profile_text()
	col.add_child(_prof_info)
	_section(col, "Clase")
	var r: = _row(col)
	var cls: = world.player.class_id if world.running and is_instance_valid(world.player) else _picked(_run_class)
	_prof_class = _pick(r, _named(GameData.CLASSES), cls)
	r = _row(col)
	r.add_child(UiKit.label("Nivel de clase", 12))
	_prof_level = _spin(r, 1, GameData.REBIRTH_CLASS_MAX_LEVEL, int(Save.class_progress(_picked(_prof_class)).level))
	_prof_class.item_selected.connect( func(_i):
		_prof_level.value = int(Save.class_progress(_picked(_prof_class)).level)
		_prof_info.text = _profile_text())
	_btn(r, "Aplicar", func(): _set_class_level(_picked(_prof_class), int(_prof_level.value)))
	r = _row(col)
	_btn(r, "Nivel máximo", func():
		var c: = _picked(_prof_class)
		_set_class_level(c, Save.class_max_level(c)))
	_btn(r, "Dar rebirth", func(): _set_reborn(_picked(_prof_class), true))
	_btn(r, "Quitar rebirth", func(): _set_reborn(_picked(_prof_class), false))
	_btn(r, "Desbloquear clase", func(): _unlock_class(_picked(_prof_class)))
	r = _row(col)
	_btn(r, "Personaje de prueba (equipo inicial al máximo)", func(): _test_character(_picked(_prof_class)), true)
	_section(col, "Juramentos (Infierno 10)  ·  %s" % ("Juramento %d" % GameData.oath_points(Save.oaths()) if not Save.oaths().is_empty() else "ninguno"))
	r = _row(col)
	_btn(r, "Todos al máximo", func():
		for o in GameData.OATHS:
			Save.set_oath(str(o.id), (o.pts as Array).size())
		Save.flush()
		_toast("Juramento %d" % GameData.oath_points(Save.oaths()))
		_rebuild())
	_btn(r, "Juramento 10", func():
		for o in GameData.OATHS:
			Save.set_oath(str(o.id), 0)
		var pts: = 0
		for o in GameData.OATHS:
			for rank in range((o.pts as Array).size(), 0, -1):
				if pts + int(o.pts[rank - 1]) <= 10:
					Save.set_oath(str(o.id), rank)
					pts += int(o.pts[rank - 1])
					break
		Save.flush()
		_toast("Juramento %d" % GameData.oath_points(Save.oaths()))
		_rebuild())
	_btn(r, "Ninguno", func():
		for o in GameData.OATHS:
			Save.set_oath(str(o.id), 0)
		Save.flush()
		_rebuild())
	_btn(r, "+50 Star Crumbs", func():
		Save.add_material("star_crumb", 50)
		Save.flush()
		_toast("Star Crumbs: %d" % Save.material("star_crumb")))
	_section(col, "Monedas")
	r = _row(col)
	_btn(r, "+100k zeny", func(): Save.add_zeny(100000))
	_btn(r, "Zeny a 0", func():
		Save.data.zeny = 0
		Save.mark_dirty())
	_btn(r, "+100 Poring Coins", func():
		Save.data.coins = Save.coins() + 100
		Save.mark_dirty())
	_btn(r, "+1 Ymir", func(): Save.add_ymir_fragment(1))
	_btn(r, "+20 Oridecon/Elunium", func():
		Save.add_material("oridecon", 20)
		Save.add_material("elunium", 20))
	_section(col, "Mundo")
	r = _row(col)
	_btn(r, "Todos los MVP vencidos", func():
		for sid in GameData.STAGES:
			Save.clear_stage(sid)
			Save.mark_entered(sid))
	_btn(r, "Peligro máximo", func():
		Save.data["max_danger"] = GameData.DANGER_MAX
		Save.mark_dirty())
	_btn(r, "Peligro a 1", func():
		Save.data["max_danger"] = 1
		Save.mark_dirty())
	_btn(r, "Mapas sin MVP", func():
		Save.data.stages = {}
		Save.data["stages_hard"] = {}
		Save.data["danger_best"] = {}
		Save.mark_dirty())
	_btn(r, "Mapas sin explorar", func():
		Save.data["entered"] = {}
		Save.mark_dirty())
	_section(col, "Colecciones")
	r = _row(col)
	_btn(r, "Todas las cartas", func():
		for id in GameData.CARDS:
			Save.add_card(id))
	_btn(r, "Todas las mascotas", func():
		for id in GameData.PETS:
			Save.add_pet(id))
	_btn(r, "Todas las quests", func():
		for sid in GameData.QUESTS:
			Save.complete_quest(sid))
	_btn(r, "Mejoras Kafra y Sabio al máx.", _max_upgrades)
	_btn(r, "Torre: todos los pisos", func():
		Save.dev_tower_floors()
		_toast("Torre: pisos desbloqueados hasta el %d" % (Save.tower_checkpoints().back())))
	_btn(r, "Logros: comprobar", func(): _toast("%d logros nuevos" % Achievements.check().size()))
	_btn(r, "Logros: borrar", func():
		Save.data.achievements = {}
		Save.data.coins = 0
		Save.mark_dirty())
	_section(col, "Todo el progreso")
	r = _row(col)
	_danger_btn(r, "PROGRESO 100%", _full_progress)
	_danger_btn(r, "BORRAR TODO EL PROGRESO", _wipe)
	r = _row(col)
	_btn(r, "Volver al login (refrescar)", _back_to_login)




func _info_text() -> String:
	var lines: = []
	lines.append("FPS %d  ·  nodos %d  ·  time_scale x%s" % [Engine.get_frames_per_second(), 
		get_tree().get_node_count(), str(Engine.time_scale)])
	if not world.running or not is_instance_valid(world.player):
		lines.append("Sin partida  ·  mapa %s" % world.stage_id)
		return "\n".join(lines)
	var p: = world.player
	var dps: = 0.0
	if _dps_samples.size() > 1:
		var a: Array = _dps_samples[0]
		var b: Array = _dps_samples[-1]
		dps = (float(b[1]) - float(a[1])) / maxf(0.25, float(b[0]) - float(a[0]))
	lines.append("%s  ·  %s  ·  peligro %d%s  ·  ritmo x%s  ·  raid %s" % [world.stage_id, UiKit.time_text(world.time), 
		world.danger, " (día)" if world.featured else "", str(world.pace), world.raid.state])
	lines.append("Monstruos %d  ·  kills %d  ·  DPS 5s %d  ·  total %d  ·  recibido %d" % [world.enemies.size(), world.kills, 
		roundi(dps), roundi(float(world.meter_stats.get("total", 0.0))), roundi(float(world.meter_stats.get("taken", 0.0)))])
	lines.append("%s Lv %d  ·  HP %d/%d  ·  daño x%.2f  ·  recarga x%.2f  ·  área x%.2f  ·  crit %d%%  ·  esquiva %d%%  ·  def %.1f  ·  vel %.1f" % [
		p.job_name(), p.level, roundi(p.hp), roundi(p.max_hp), p.dmg_mult if not _oneshot else p.dmg_mult / 10000.0, 
		p.cd_mult, p.area_mult, roundi(p.crit * 100.0), roundi(p.dodge * 100.0), p.armor, p.move_speed])
	lines.append("Monstruos nuevos: vida x%.2f  ·  daño x%.2f  ·  recompensas x%.2f" % [GameData.danger_hp(world.danger), 
		GameData.danger_dmg(world.danger), p.hard_loot])
	return "\n".join(lines)


func _start(at_mvp: bool) -> void :
	var sid: = _picked(_run_stage)
	var cls: = _picked(_run_class)
	if sid == "" or cls == "":
		return
	var d: = int(_run_danger.value)
	world.menus.close()
	world.set_stage(sid)
	world.danger = d
	world.start_run(cls)

	_set_danger(d)
	_dps_samples.clear()
	if at_mvp:
		await get_tree().process_frame
		_to_mvp(true)
	_rebuild()


func _set_danger(d: int) -> void :
	world.danger = d
	world.hard = d >= GameData.DANGER_HARD
	world.player.hard_loot = GameData.danger_reward(d) * (1.0 + GameData.FEATURED_BONUS if world.featured else 1.0)
	world.player.equipment.legend_bonus = GameData.danger_legend(d)
	_toast("Peligro %d" % d)




func _advance(secs: float) -> void :
	world.time += secs
	var events: Array = world.stage.events
	while world._event_index < events.size() and float(events[world._event_index].at) < world.time\
	and events[world._event_index].type != "boss":
		world._event_index += 1


func _to_mvp(enter: bool) -> void :
	if not world.running:
		return
	var mvp: = str(world.stage.mvp)
	if world.raid.active():
		if enter and world.raid.state == "portal":
			world.player.position = world.raid.portal_pos
		return
	world.time = maxf(world.time, float(world.stage.mvp_time))
	var events: Array = world.stage.events
	while world._event_index < events.size() and float(events[world._event_index].at) <= world.time + 1.0:
		world._event_index += 1
	if not world.raid.supports(mvp):
		world._run_event({"type": "boss", "mob": mvp})
		return
	world.raid.open_portal(mvp)
	if enter:
		await get_tree().create_timer(0.3, true, false, true).timeout
		world.player.position = world.raid.portal_pos


func _near() -> Vector3:
	var a: = randf() * TAU
	return world.player.position + Vector3(cos(a), 0, sin(a)) * 2.5


func _spawn(feroz: bool, kind: = "") -> void :
	var id: = _picked(_mob_pick)
	if id == "":
		return
	for i in int(_mob_count.value):
		var a: = randf() * TAU
		var at: = world.player.position + Vector3(cos(a), 0, sin(a)) * randf_range(5.0, 9.0)
		world.spawn_enemy(id, at, true, feroz, kind)


func _kill_all() -> void :
	for e in world.enemies.duplicate():
		if is_instance_valid(e) and not e.dead and e.prop == "":
			e.hp = 0.0
			world._kill(e)


func _kill_boss() -> void :
	var target: Enemy = world.raid.boss if world.raid.in_arena() and is_instance_valid(world.raid.boss) else world.boss
	if target != null and is_instance_valid(target) and not target.dead:
		target.hp = 0.0
		world._kill(target)


func _stage_elite() -> void :
	for ev in world.stage.events:
		if ev.type == "elite":
			world._run_event(ev)
			return


func _auto_levels(n: int) -> void :
	var p: = world.player
	for i in n:
		p.level += 1
		p.xp_need = GameData.xp_to_next(p.level)
		var choices: Array = p.build_choices()
		if not choices.is_empty():
			p.apply_choice(choices.pick_random(), world)
	p.recompute()
	world.hud.bind(world)
	_rebuild()





const TEST_LEVEL: = 99


func _max_hero(path: int) -> void :
	var p: = world.player
	p.level = maxi(p.level, TEST_LEVEL)
	p.xp = 0.0
	p.xp_need = GameData.xp_to_next(p.level)
	if p.job2.is_empty() and path >= 0:
		world.do_job_change(path)

	p.skills.clear()
	var actives: Array = (p.job2.get("skills", []) as Array) + (p.def.skills as Array)
	var passives: Array = (p.job2.get("passives", []) as Array) + (p.def.get("passives", []) as Array)
	for id in actives:
		if GameData.SKILLS.has(id) and not p.skills.has(id) and p.count_skills(false) < p.max_skills():
			p.add_skill(str(id))
	for id in passives:
		if GameData.SKILLS.has(id) and not p.skills.has(id) and p.count_skills(true) < p.max_passives():
			p.add_skill(str(id))
	for id in p.skills:
		p.skills[id].level = GameData.MAX_SKILL_LEVEL
	for id in p.skills.keys():
		if GameData.EVOLUTIONS.has(id):
			p.evolve(id)
	for st in p.stats:
		p.stats[st] = maxi(int(p.stats[st]), GameData.MAX_STAT)
	_max_gear(p)
	p.recompute()
	p.hp = p.max_hp
	world.hud.bind(world)
	_toast("Héroe de prueba: %s Lv %d, %d habilidades" % [p.job_name(), p.level, p.skills.size()])
	_rebuild()



func _max_gear(p: Player) -> void :
	var best: = _best_gear(p.class_id, p.equipment)
	for k in best:
		p.equipment.slots[k] = best[k]
	p.equipment.fix_hands()
	p.recompute()
	world.hud.bind(world)




func _best_gear(class_id: String, eq: Equipment) -> Dictionary:
	var out: = {}
	var taken: = {}
	for k in GameData.EQUIP_SLOTS:
		var want: = "acc" if str(k).begins_with("acc") else str(k)
		var pick: = ""
		var top: = -1.0
		for id in GameData.ITEMS:
			var d: Dictionary = GameData.ITEMS[id]
			if str(d.get("slot", "")) != want or d.get("unique", false) or taken.has(id) or d.get("lent", false):
				continue
			if not d.get("legendary", false) and want != "wings":
				continue
			if d.has("class") and str(d["class"]) != class_id:
				continue
			if want == "weapon" and not eq.usable_weapon(str(id)):
				continue
			var sc: = _item_score(d) + (1.0 if d.has("class") else 0.0)
			if sc > top:
				top = sc
				pick = str(id)
		if pick == "":
			continue
		if want == "shield":

			var w = out.get("weapon")
			if w != null:
				eq.slots["weapon"] = w
			if not eq.usable_shield():
				continue
		taken[pick] = true
		out[k] = _max_item(Equipment.make(pick, 0))
	return out



func _item_score(d: Dictionary) -> float:
	var sc: = 0.0
	for src in [d.get("mods", {}), d.get("effects", {})]:
		for key in src:
			var v = src[key]
			if (v is float or v is int) and absf(float(v)) <= 1.0:
				sc += absf(float(v))
	return sc




func _max_item(it: Dictionary) -> Dictionary:
	var d: = Equipment.item_def(it)
	if d.get("wings", false):
		it["refine"] = GameData.WING_REFINE_MAX
	elif Equipment.refinable(it):
		it["refine"] = GameData.MAX_REFINE
	var kind: = Equipment.item_type(it)
	if kind == "weapon":
		it["grade"] = GameData.WEAPON_GRADES.size() - 1
	elif GameData.GEAR_GRADES.has(kind):
		it["grade"] = (GameData.GEAR_GRADES[kind].vals as Array).size() - 1
	it["extra_slots"] = int(it.get("extra_slots", 0)) + Equipment.socket_room(it)
	it["cards"] = []
	var cards: = GameData.CARDS.keys().filter( func(c): return Equipment.card_fits(it, str(c)))
	cards.sort_custom( func(a, b): return _item_score(GameData.CARDS[a]) + (0.5 if GameData.is_mvp_card(a) else 0.0)\
	> _item_score(GameData.CARDS[b]) + (0.5 if GameData.is_mvp_card(b) else 0.0))
	for c in cards:
		if (it.cards as Array).size() >= Equipment.sockets(it):
			break
		it.cards.append(str(c))
	_max_pot(it)
	return it



func _max_pot(it: Dictionary) -> void :
	var t: = GameData.POTENTIAL_TIERS.size()
	var keys: = ["dmg", "skill", "boss"] if Equipment.item_type(it) == "weapon" else ["stats", "dmg", "hp" if Equipment.item_type(it) == "armor" else "skill"]
	var lines: = []
	for k in keys:
		lines.append({"k": k, "t": t, "p": true})
	it["pot"] = {"tier": t, "lines": lines}




func _test_character(c: String) -> void :
	if c == "":
		return
	_unlock_class(c)
	if not GameData.CLASSES[c].get("no_rebirth", false):
		_set_reborn(c, true)
	_set_class_level(c, Save.class_max_level(c))
	var best: = _best_gear(c, Equipment.new(c))
	for k in best:
		var it: Dictionary = best[k]
		var stored: = {"id": str(it.id), "slots": int(it.slots), "extra_slots": int(it.get("extra_slots", 0)), "refine": int(it.refine), 
			"cards": [], "eternal": (it.cards as Array).duplicate(), "pot": (it.pot as Dictionary).duplicate(true), 
			"uid": "test_%s_%s" % [c, k]}
		if it.has("grade"):
			stored["grade"] = int(it.grade)
		Save.remove_from_storage(str(stored.uid))
		Save.storage().append(stored)
		Save.set_loadout_slot(c, str(k), str(stored.uid))
	Save.add_material("star_crumb", 50)
	Save.mark_dirty()
	Save.flush()
	_toast("Personaje de prueba: %s con %d piezas al máximo" % [str(GameData.CLASSES[c].name), best.size()])
	_rebuild()


func _give_item(id: String, slots: int) -> void :
	if id == "":
		return
	var res: Dictionary = world.player.equipment.receive(Equipment.make(id, slots))
	world.player.recompute()
	world.hud.bind(world)
	_toast("%s: %s" % [id, str(res.result)])




func _profile_text() -> String:
	var c: = _picked(_prof_class) if _prof_class != null else ""
	var line: = "Zeny %d  ·  Coins %d  ·  Ymir %d  ·  peligro máx %d  ·  logros %d%%" % [Save.zeny(), Save.coins(), 
		Save.ymir_fragments(), Save.max_danger(), roundi(Achievements.percent() * 100.0)]
	if c != "":
		var prog: = Save.class_progress(c)
		line += "\n%s: nivel %d/%d  ·  %s  ·  %s" % [str(GameData.CLASSES[c].name), int(prog.level), Save.class_max_level(c), 
			"renacida" if Save.is_reborn(c) else "sin rebirth", "desbloqueada" if Save.class_unlocked(c) else "bloqueada"]
	return line


func _set_class_level(c: String, lv: int) -> void :
	if c == "":
		return
	var prog: = Save.class_progress(c)
	prog.level = clampi(lv, 1, Save.class_max_level(c))
	prog.xp = 0
	Save._set_progress(c, prog)
	Save.flush()
	if _prof_level != null and is_instance_valid(_prof_level) and _picked(_prof_class) == c:
		_prof_level.value = int(prog.level)


func _set_reborn(c: String, on: bool) -> void :
	if c == "":
		return
	if on:
		Save.data.rebirths[c] = 1
	else:
		Save.data.rebirths.erase(c)

		var prog: = Save.class_progress(c)
		prog.level = mini(int(prog.level), GameData.CLASS_MAX_LEVEL)
		Save._set_progress(c, prog)
	Save.mark_dirty()
	Save.flush()


func _unlock_class(c: String) -> void :
	if c == "":
		return
	if not Save.data.has("unlocked"):
		Save.data.unlocked = {}
	Save.data.unlocked[c] = true
	Save.mark_dirty()



func _next_phase() -> void :
	var fight = world.morroc if world.morroc.active() else world.raid
	if not fight.active() or fight.boss == null or not is_instance_valid(fight.boss):
		_toast("Sin MVP en combate")
		return
	var phases: Array = fight.data.phases
	if fight.phase + 1 >= phases.size():
		_toast("Ya está en la última fase")
		return
	fight.boss.hp = fight.boss.max_hp * float(phases[fight.phase + 1]) - 1.0
	_toast("Fase %d" % (fight.phase + 2))




func _hel_tower(f: int) -> void :
	if world.running and is_instance_valid(world.player):
		Save.add_tower_build(RunSave.hero_snapshot(world))
	var n: = Save.tower_builds().size()
	if n == 0:
		_toast("Torre: entra a una partida primero (no hay builds guardadas)")
		return
	Save.dev_tower_floors()
	if _panel.visible:
		toggle()
	world.start_tower(n - 1, 1, true)
	if f > 1 and world.tower != null:
		world.tower.floor = f
		world.tower.hel.rules.assign(GameData.HEL_TOWER_RULES.keys())



func _tower_100() -> void :
	if world.running and is_instance_valid(world.player):
		Save.add_tower_build(RunSave.hero_snapshot(world))
	var n: = Save.tower_builds().size()
	if n == 0:
		_toast("Torre: entra a una partida primero (no hay builds guardadas)")
		return
	Save.dev_tower_floors()
	if _panel.visible:
		toggle()
	world.start_tower(n - 1, GameData.TOWER_FLOORS)


func _max_upgrades() -> void :
	for id in GameData.UPGRADES:
		Save.set_upgrade_level(id, int(GameData.UPGRADES[id].max))
	for id in GameData.SAGE_UPGRADES:
		Save.set_upgrade_level(id, int(GameData.SAGE_UPGRADES[id].max))




func _full_progress() -> void :
	var d: Dictionary = Save.data
	for c in GameData.CLASSES:
		_unlock_class(c)
		if not GameData.CLASSES[c].get("no_rebirth", false):
			d.rebirths[c] = 1
		_set_class_level(c, Save.class_max_level(c))
		Save.mark_seen("classes", c)
		for job in GameData.job_paths(c):
			Save.mark_seen("jobs", str(job.get("id", job.get("name", ""))))
	for id in GameData.EVOLUTIONS:
		Save.mark_seen("evos", str(GameData.EVOLUTIONS[id].to))
	if not d.has("stages_hard"):
		d["stages_hard"] = {}
	if not d.has("danger_best"):
		d["danger_best"] = {}
	for sid in GameData.STAGES:
		d.stages[sid] = true
		d.stages_hard[sid] = true
		d.danger_best[sid] = GameData.DANGER_MAX
		Save.mark_entered(sid)
	d["max_danger"] = GameData.DANGER_MAX
	for id in GameData.CARDS:
		Save.add_card(id)
	for id in GameData.PETS:
		Save.add_pet(id)
	for sid in GameData.QUESTS:
		Save.complete_quest(sid)
	_max_upgrades()
	for key in ["kills", "mvp_kills", "boss_kills", "runs", "play_time", "zeny_earned", "zeny_spent", "legendaries", "gold_poring", "altars", 
			"best_dps", "best_hit", "best_refine", "best_stat", "broken", "endless_best", "run_level", "storage_refine"]:
		Save.stat_max(key, 1000000.0)
	d["ymir"] = maxi(Save.ymir_fragments(), GameData.REBIRTH_FRAGMENTS)
	d.zeny = maxi(Save.zeny(), 10000000)
	Save.mark_dirty()
	Achievements.check()

	for id in GameData.ACHIEVEMENTS:
		if not Save.achieved(id):
			Save.complete_achievement(id, int(GameData.ACHIEVEMENTS[id].coins))
	Save.flush()
	_toast("Progreso al 100%")
	_back_to_login()


func _wipe() -> void :
	RunSave.clear()
	Save.reset_profile()
	_toast("Progreso borrado")
	_back_to_login()


func _back_to_login() -> void :
	Engine.time_scale = 1.0
	if world.running:
		world.running = false
		world.clear_battlefield()
	world.menus.show_login()
	_rebuild()






func _self_test(dir: String) -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var shot: = func(label: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, label])
	await wait.call(1.5)
	toggle()
	_run_danger.value = 5
	await _start(false)
	await wait.call(1.0)
	await shot.call("0_run")
	_god = true
	_auto_levels(6)
	_mob_count.value = 15
	_spawn(false)
	_spawn(true)
	await wait.call(1.0)
	await shot.call("1_spawned")
	_kill_all()
	_give_item(_picked(_item_pick), 0)
	world._drop_chest(_near(), GameData.CHEST_ROLLS.boss, 2)
	_card_pick.select(0)
	world.player.add_card(_picked(_card_pick))
	for id in world.player.skills.keys():
		if not GameData.SKILLS[id].get("evolved", false):
			world.player.skills[id].level = GameData.MAX_SKILL_LEVEL
	_tabs.current_tab = 1
	_rebuild()
	await wait.call(0.5)
	await shot.call("2_hero")
	_tabs.current_tab = 2
	await wait.call(0.3)
	await shot.call("3_loot")
	_advance(60)
	Engine.time_scale = 2.0
	await _to_mvp(true)
	await wait.call(4.0)
	await shot.call("4_mvp")
	print("DEBUGTEST raid=%s danger=%d level=%d hp=%d/%d" % [world.raid.state, world.danger, world.player.level, world.player.hp, world.player.max_hp])
	_kill_boss()
	await wait.call(2.0)
	Engine.time_scale = 1.0
	await shot.call("5_boss_dead")
	_full_progress()
	_tabs.current_tab = 3
	await wait.call(0.5)
	await shot.call("6_profile_full")
	print("DEBUGTEST full: danger=%d achievements=%d%% zeny=%d reborn=%s" % [Save.max_danger(), roundi(Achievements.percent() * 100.0), Save.zeny(), Save.is_reborn("swordsman")])
	_set_reborn("swordsman", false)
	print("DEBUGTEST unreborn: reborn=%s level=%d" % [Save.is_reborn("swordsman"), int(Save.class_progress("swordsman").level)])
	_wipe()
	print("DEBUGTEST wiped: danger=%d achievements=%d%% zeny=%d cards=%d" % [Save.max_danger(), roundi(Achievements.percent() * 100.0), Save.zeny(), Save.data.cards.size()])
	get_tree().quit()




func _hover_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var cases: = [
		["item", world.menus._item_hover(Equipment.make("avenger_gatling", 1), ["En el equipo de: Gunslinger"])], 
		["card", world.menus._card_hover("angeling_card", ["Clic: quitar"])], 
		["text", {}], 
		["stat", RoCharMake.new()._stat_hover("agi", "Poner punto")], 
	]
	for c in cases:
		var b: = Button.new()
		b.text = "  hover  "
		b.position = Vector2(600, 500)
		b.size = Vector2(80, 30)
		if c[1].is_empty():
			b.tooltip_text = "Mapa del día\n+25% de recompensas en este mapa"
		else:
			b.set_meta("hover", c[1])
		add_child(b)
		await get_tree().process_frame
		var hc: = world.get_children().filter( func(n): return n is HoverCard)
		if not hc.is_empty():
			hc[0].test_target = b
		await get_tree().create_timer(0.5, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/hover_%s.png" % [dir, c[0]])
		b.queue_free()
		await get_tree().create_timer(0.2, true, false, true).timeout
	get_tree().quit()



func _screens_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.add_zeny(50000)
	for sid in GameData.QUESTS:
		Save.complete_quest(sid)

	for pair in [["head", "valkyrie_helm"], ["shield", "valkyrja_shield"]]:
		Save.add_to_storage(Equipment.make(pair[1], 1))
		Save.set_loadout_slot("swordsman", pair[0], str(Save.storage()[-1].uid))
	world.menus.show_class_select("swordsman")
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/npc_0_select.png" % dir)
	for c in ["poring_card", "lunatic_card", "fabre_card"]:
		Save.add_card(c)
	Save.set_equipped_cards(["poring_card", "lunatic_card", "fabre_card"])
	world.menus._run_class = "swordsman"
	world.menus.show_prep("prontera")
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/npc_0_prep.png" % dir)
	world.enter_town("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var m: Menus = world.menus
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/npc_0_town.png" % dir)
	for c in [["chef", func(): m.show_chef()], ["socket", func(): m.show_socket()], ["loadout", func(): m.show_loadout("swordsman")], 
			["kafra", func(): m.show_kafra()], ["sage", func(): m.show_sage()], ["pacts", func(): m.show_pacts("swordsman")], 
			["album", func(): m.show_album()], ["refiner", func(): m.show_refiner()]]:
		c[1].call()
		await get_tree().create_timer(0.5, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/npc_%s.png" % [dir, c[0]])
	get_tree().quit()




func _eternal_test(dir: String) -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var shot: = func(label: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/et_%s.png" % [dir, label])
	await wait.call(1.5)
	Save.add_zeny(50000)
	Save.data.cards["poring_card"] = 7
	Save.data.cards["lunatic_card"] = 3
	Save.data.cards["willow_card"] = 6
	Save.data.cards["angeling_card"] = 10
	Save.add_to_storage(Equipment.make("cotton_shirt", 2))
	var uid: = str(Save.storage()[-1].uid)
	Save.set_loadout_slot("swordsman", "armor", uid)
	var m: Menus = world.menus
	m.show_class_select("swordsman")
	await wait.call(0.8)
	await shot.call("00_select_glow")
	m._album_tab = "cards"
	m.show_album()
	await wait.call(0.6)
	await shot.call("0_album")
	m._start_fusion("poring_card")
	for t in [0.8, 1.8, 2.8, 4.0]:
		await wait.call(t - (0.0 if t == 0.8 else [0.8, 1.8, 2.8, 4.0][[0.8, 1.8, 2.8, 4.0].find(t) - 1]))
		await shot.call("1_fusion_%.1f" % t)
	var fx: = m._root.find_children("*", "CardFusion", true, false)
	if not fx.is_empty():
		fx[0]._close()
	await wait.call(0.5)
	m._album_filter = "eternal"
	m.show_album()
	await wait.call(0.5)
	await shot.call("2_album_eternal")
	print("ETTEST eternal=", Save.eternal("poring_card"), " copies=", Save.card_copies("poring_card"), " has=", Save.has_card("poring_card"))
	m._socket_uid = uid
	m._eternal_sel = 0
	m.show_socket()
	await wait.call(0.5)
	await shot.call("3_socket_pick")
	print("ETTEST set=", Save.set_eternal(uid, "poring_card"), " free=", Save.eternal_free("poring_card"))
	m._eternal_sel = -1
	m.show_socket()
	await wait.call(0.5)
	await shot.call("4_socket_set")
	m._eternal_sel = 0
	m.show_socket()
	await wait.call(0.3)
	await shot.call("5_socket_remove")
	m.close()
	world.set_stage("prontera")
	world.start_run("swordsman")
	await wait.call(1.0)
	var armor = world.player.equipment.slots.armor
	print("ETTEST run armor=", armor.id if armor != null else "-", " cards=", armor.cards if armor != null else [], " eternal_n=", armor.get("eternal_n", 0) if armor != null else 0)
	m.show_equipment("armor")
	await wait.call(0.5)
	await shot.call("6_run_equipment")
	print("ETTEST unsocket=", world.player.equipment.unsocket("armor", 0))
	get_tree().quit()




func _update_test(dir: String) -> void :
	var shot: = func(label: String):
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/upd_%s.png" % [dir, label])
	await get_tree().create_timer(1.5, true, false, true).timeout
	var notes: Array = JSON.parse_string(FileAccess.get_file_as_string("res://../tools/release_notes.json")).versions\
	if FileAccess.file_exists("res://../tools/release_notes.json") else []
	if notes.is_empty():
		var f: = FileAccess.open(ProjectSettings.globalize_path("res://").path_join("../tools/release_notes.json"), FileAccess.READ)
		notes = JSON.parse_string(f.get_as_text()).versions
	var layer: = CanvasLayer.new()
	layer.layer = 127
	add_child(layer)
	var win: Control = load("res://scripts/ui/update_window.gd").new()
	win.setup(tr("¡Actualización disponible!"), "v0.1.80  →  v0.1.81   ·   12.4 MiB", notes.slice(0, 4), false)
	layer.add_child(win)
	await shot.call("0_offer")
	win._toggle_notes()
	await shot.call("1_notes")
	win.start_progress()
	win.set_progress(42.0, tr("Descargando… %s / %s") % ["5.2 MiB", "12.4 MiB"])
	await shot.call("2_progress")
	win.queue_free()
	var full: Control = load("res://scripts/ui/update_window.gd").new()
	full.setup(tr("Nueva versión disponible"), "v0.1.80  →  v0.1.81   ·   itch.io", notes.slice(0, 1), true)
	layer.add_child(full)
	await get_tree().process_frame
	full.set_status(tr("Esta versión se descarga desde itch.io (la app de itch la instala sola)."))
	await shot.call("3_full")
	get_tree().quit()



func _altar_test(dir: String) -> void :
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var shot: = func(label: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/alt_%s.png" % [dir, label])
	await wait.call(1.5)
	GameData.set_meta("no_spawn", true)
	world.set_stage("prontera")
	world.start_run("swordsman")
	world.player.max_hp = 99999.0
	world.player.hp = 99999.0
	await wait.call(1.0)
	var p: = world.player
	var spot: = world.map.find_point_around(p.position, 4.0, 5.0)
	world.altars.spawn("thor", spot)
	await wait.call(1.2)
	await shot.call("0_idle_far")
	var near: = world.map.find_point_around(spot, 3.0, 3.5)
	p.position = Vector3(near.x, world.map.height_at(near), near.z)
	await wait.call(0.8)
	await shot.call("1_card")
	p.position = Vector3(spot.x, world.map.height_at(spot), spot.z)
	await wait.call(0.7)
	await shot.call("2_fill_35")
	await wait.call(0.8)
	await shot.call("3_fill_75")
	await wait.call(0.6)
	await shot.call("4_accept")
	await wait.call(1.5)
	for id in ["loki", "valkyrie", "thor", "yggdrasil"]:
		world.altars.taken.append(id)
	world.hud.refresh_altars()
	await wait.call(0.6)
	await shot.call("5_hud")
	var far: = world.map.find_point_around(p.position, 30.0, 35.0)
	world.altars.spawn("emperium", far)
	world.altars.spawn("freyja", world.map.find_point_around(p.position, 6.0, 7.0))
	await wait.call(1.0)
	await shot.call("6_minimap")
	print("ALTTEST mods=", world.altars.mods, " player=", p.altar_mods, " mvp_at=", world.mvp_at())
	get_tree().quit()






func _atlasdemo_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(0.5, true, false, true).timeout
	var frames: = 0
	var unique: = 0
	for id in world.mob_renderer._kinds:
		var kind = world.mob_renderer._kinds[id]
		if kind == null:
			print("ATLASDEMO unbatched ", id)
			continue
		var used: = {}
		for c in kind.cells:
			used[floori(c)] = true
		frames += kind.cells.size()
		unique += used.size()
		var a: = RoVisual.MOB_WALK * RoSprite.DIRS
		print("ATLASDEMO %s frames %d cells %d walk %s" % [id, kind.cells.size(), used.size(), 
			kind.cells.slice(kind.starts[mini(a + 5, kind.starts.size() - 1)], kind.starts[mini(a + 5, kind.starts.size() - 1)] + 3)])
	print("ATLASDEMO total frames %d cells %d, video %d MB" % [frames, unique, 
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / 1048576])
	world.start_run("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Node3D = world.player
	var ids: = ["sohee", "high_orc", "marduk", "raydric"]
	for i in 16:
		var at: = p.position + Vector3(7, 0, 0).rotated(Vector3.UP, TAU * i / 16.0)
		world.spawn_enemy(ids[i % ids.size()], at, true)
	for t in 3:
		await get_tree().create_timer(0.35, true, false, true).timeout
		get_viewport().get_texture().get_image().save_png("%s/ring_%d.png" % [dir, t])
	print("ATLASDEMO ok")
	get_tree().quit()




func _towerwheel_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("swordsman")
	var t: Node = TowerRun.new(world, 5)
	world.tower = t
	world.add_child(t)
	world.menus.show_tower_wheel( func(): return "super", func(id: String): t.wheel_take(id), func(): print("WHEEL done"))
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/wheel_0.png" % dir)
	var go: Array = world.menus.find_children("*", "Button", true, false)
	for b in go:
		if str(b.text).contains("GIRAR"):
			world.menus._grace = 0.0
			b.pressed.emit()
	await get_tree().create_timer(1.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/wheel_1.png" % dir)
	await get_tree().create_timer(3.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	await get_tree().create_timer(0.9, true, false, true).timeout; await RenderingServer.frame_post_draw;get_viewport().get_texture().get_image().save_png("%s/wheel_2.png" % dir)
	print("WHEEL buffs=%s mods=%s" % [t.wheel_buffs, world.player.tower_mods])

	world.menus._resume()
	t.wheel_take("fury")
	t.wheel_take("fury")
	t.wheel_take("curse_dull")
	await get_tree().create_timer(1.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/wheel_3_hud.png" % dir)
	get_tree().quit()



func _towerevents_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.auto_pick = true
	world.start_run("swordsman")
	var t: Node = TowerRun.new(world, 5)
	world.tower = t
	world.add_child(t)
	world.player.max_hp = 90000.0
	world.player.hp = 90000.0

	t._force_event = "treasure"
	t._start_floor()
	print("EVENTS sign state=%s line=%s" % [t.state, t.hud_state()])
	await get_tree().create_timer(0.9, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/sign.png" % dir)
	print("EVENTS sign t=0.9 state=%s" % t.state)
	await get_tree().create_timer(1.6, true, false, true).timeout
	print("EVENTS sign t=2.5 state=%s line=%s porings=%d" % [t.state, t.hud_state(), world.enemies.size()])
	t._events.cleanup()
	for id in ["emperium", "treasure", "ambush", "survive", "duel"]:
		t._start_event(id)
		for i in 5:
			await get_tree().create_timer(1.5, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [dir, id, i])
			world.player.hp = world.player.max_hp
			print("EVENTS %s t=%d state=%s line=%s foes=%d" % [id, i, t.state, t.hud_state(), world.enemies.size()])
		t._events.cleanup()
		t._events.done = true
		await get_tree().create_timer(0.6, true, false, true).timeout
	get_tree().quit()




func _towertraps_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.auto_pick = true
	world.start_run("swordsman")
	world.tower = TowerRun.new(world, 1)
	var t = world.tower._traps
	var p: Player = world.player
	p.max_hp = 5000.0
	p.hp = 5000.0
	for id in ["bolts", "beam", "spikes", "boulder"]:
		match id:
			"bolts":
				t._bolts(p, 3, 0.05, 1.2)
			"beam":
				t._beams(p, 2, 0.05, 1.2)
			"spikes":
				t._spikes(p, 0.05, 1.2)
			"boulder":
				t._boulder(p, 0.05, 1.2)
		for s in [0.8, 0.6, 0.5, 0.6]:
			await get_tree().create_timer(s, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [dir, id, int(s * 10)])
		print("TRAPS %s hp=%.0f" % [id, p.hp])
		await get_tree().create_timer(2.5, true, false, true).timeout
	get_tree().quit()




func _procrogue_test() -> void :
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.auto_pick = true
	world.start_run("thief")
	var p: Player = world.player
	p.level = 60
	p.job_change(1)
	p.reborn = true
	p.profile["plagiarism"] = ["meteor_storm", "fire_bolt", "heal"]
	p.skills["gangster_paradise"] = {"level": 5, "cd": 0.5}
	p.skills["preserve"] = {"level": 5, "cd": 0.5}
	p.skills["intimidate"] = {"level": 5, "cd": 0.5}
	p.recompute()
	print("ROGUE job=%s pool=%s proc=%.2f hit=%.2f plag=%.2f" % [p.job2.get("id", ""), p.passive_pool(), float(p.effects.get("proc_chance", 0.0)), float(p.effects.get("hit_proc", 0.0)), float(p.effects.get("plag_proc", 0.0))])
	var foe: Enemy = world.spawn_enemy("baphomet", p.position + Vector3(2, 0, 0), true)
	foe.max_hp = 1000000000.0
	foe.hp = 1000000000.0
	await get_tree().create_timer(0.2, true, false, true).timeout
	for i in 300:
		p.on_basic_hit(world, foe)
		await get_tree().process_frame
	print("ROGUE meter=%s" % str(world.meter_sorted().map( func(r): return "%s:%d" % [r.tag, roundi(float(r.dmg))])))
	get_tree().quit()




func _itempane_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.auto_pick = true
	world.start_run("swordsman")
	world.player.equipment.slots.weapon = Equipment.make("sucsamad", 0)
	world.player.recompute()
	for loc in ["es", "en"]:
		TranslationServer.set_locale(loc)
		world.menus.show_equipment("weapon")
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/pane_%s.png" % [dir, loc])
	get_tree().quit()





func _taunt_test() -> void :
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.auto_pick = true
	world.start_run("swordsman")
	var p: Player = world.player
	p.level = 60
	p.job_change(1)
	p.equipment.slots.shield = Equipment.make("guard", 0)
	p.skills["shield_mastery"] = {"level": 5, "cd": 0.5}
	p.recompute()
	print("TAUNT job=%s hp=%.0f armor=%.1f block=%.2f heal=%.3f pool=%s" % [p.job2.get("id", ""), p.max_hp, p.armor, p.block_chance(), float(p.effects.get("block_heal", 0.0)), p.skill_pool()])
	print("TAUNT evolutions ", GameData.EVOLUTIONS.provoke, GameData.EVOLUTIONS.gospel, GameData.EVOLUTIONS.martyrs_reckoning, GameData.EVOLUTIONS.magnum_break)
	var boss: Enemy = world.spawn_enemy("baphomet", p.position + Vector3(3, 0, 0), true)
	var mob: Enemy = world.spawn_enemy("willow", p.position + Vector3(-2, 0, 1), true)
	await get_tree().create_timer(0.2, true, false, true).timeout
	print("TAUNT cast %s boss=%.1f mob=%.1f armor=%.1f" % [Skills.cast(world, p, "provoke", 5, "provoke"), boss.taunt_until - world.clock, mob.taunt_until - world.clock, p.armor])
	world.raid.boss = boss
	print("TAUNT raid target ok=%s morroc ok=%s" % [world.raid._target() == p, true])
	world.raid.boss = null
	await get_tree().create_timer(0.3, true, false, true).timeout
	var before: = boss.taunt_until
	print("TAUNT evolved %s hp0=%.0f" % [Skills.cast(world, p, "provoke_x", 1, "provoke_x"), boss.hp])
	print("TAUNT evolved vuln=%.2f pulse=%.1f armor=%.1f" % [boss.taunt_vuln, float(p.provoke.pulse), p.armor])
	for id in ["holy_cross_x", "grand_cross_x", "gospel_x", "martyrs_reckoning_x"]:
		print("TAUNT %s -> %s" % [id, Skills.cast(world, p, id, 1, id)])
	await get_tree().create_timer(2.2, true, false, true).timeout
	print("TAUNT metrics bytes=%d" % JSON.stringify(world.board.metrics_of(world, false, {}, {})).length())
	print("TAUNT pulse renewed=%s vuln=%.2f power=%s martyr=%.3f" % [boss.taunt_until > before, boss.taunt_vuln, p.powers.has("provoke_x"), p.martyr_pct])
	get_tree().quit()




func _karmabar_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("swordsman")
	for k in [0.0, -0.5, 0.5, -1.0, 1.0]:
		world.karma.value = roundi(k * GameData.KARMA_MAX)
		if k == 0.0:
			var at: Vector3 = world.player.position + Vector3(0, 0, -3.5)
			world.raid._spawn_kportal(at, "dark")
			await get_tree().create_timer(0.5, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/portal_dark.png" % dir)
			world.raid._spawn_kportal(at, "light")
			await get_tree().create_timer(0.5, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/portal_light.png" % dir)
			world.raid._clear_kportal()
			print("KARMATIP\n", Karma.Bar.new()._tip(0, ""))
		await get_tree().create_timer(0.3, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/karma_%d.png" % [dir, roundi(k * 100.0)])
	get_tree().quit()





func _sinhands_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	var seen: = {}
	for pair in GameData.plagiarism_pairs():
		if seen.has(pair[1]):
			print("SIN repeated skill ", pair[1], " ", seen[pair[1]], " ", pair[0])
		seen[pair[1]] = pair[0]
	print("SIN skills=%d" % seen.size())
	world.start_run("thief")
	var p: Player = world.player
	p.level = 40
	p.job_change(0)
	var eq: Equipment = p.equipment
	for pair in [["blade", ""], ["axe", ""], ["knife", "knife"], ["blade", "blade"], ["knife", "blade"], ["axe", "knife"], ["blade", "axe"], ["axe", "axe"], ["katar", ""]]:
		eq.slots.weapon = Equipment.make(pair[0], 0)
		eq.slots.shield = null
		if pair[1] != "":
			eq.bag.append(Equipment.make(pair[1], 0))
			eq.equip_from_bag(eq.bag.size() - 1, "shield")
		p.recompute()
		p._build_visual()
		print("SIN %s+%s -> %s left=%s" % [pair[0], pair[1], p.weapon_view()[0], eq.offhand().get("id", "")])
		await get_tree().create_timer(0.1, true, false, true).timeout
		p.play_attack(Vector3(1, 0, 0.4).normalized())
		for f in 4:
			await get_tree().create_timer(0.07, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/hand_%s_%s_%d.png" % [dir, pair[0], pair[1], f])
	eq.bag.append(Equipment.make("guard", 0))
	print("SIN shield with katar wearable=%s" % eq.can_wear(eq.bag[-1]))
	eq.slots.weapon = Equipment.make("knife", 0)
	eq.equip_from_bag(eq.bag.size() - 1, "")
	p.recompute()
	p._build_visual()
	print("SIN shield=%s view=%s" % [eq.slots.shield.get("id", "") if eq.slots.shield != null else "", p.shield_view()])
	await get_tree().create_timer(0.1, true, false, true).timeout
	p.play_attack(Vector3(1, 0, 0.4).normalized())
	await get_tree().create_timer(0.12, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/hand_shield.png" % dir)
	eq.slots.weapon = Equipment.make("katar", 0)
	eq.slots.shield = null
	eq.bag.append(Equipment.make("assassin_dagger", 0))
	eq.equip_from_bag(eq.bag.size() - 1, "weapon")
	print("SIN left-only right=%s left=%s" % [eq.slots.weapon, eq.offhand().get("id", "")])
	eq.slots.shield = null
	eq.slots.weapon = Equipment.make("assassin_dagger", 0)
	p.recompute()
	print("SIN old save right=%s left=%s" % [eq.slots.weapon, eq.offhand().get("id", "")])
	world.abandon_run()
	world.start_run("thief")
	p = world.player
	p.level = 40
	p.job_change(1)
	print("SIN job ", p.job2.get("id", ""))
	world.menus.auto_pick = true
	for id in ["freezing_spear", "charge_attack", "gravitation_field", "cross_slash", "sightrasher", "spear_boomerang"]:
		for k in 4:
			world.spawn_enemy("willow", p.position + Vector3(1.5 + k, 0, 1.0 - k), true)
		await get_tree().create_timer(0.2, true, false, true).timeout
		print("SIN cast %s -> %s" % [id, Skills.cast(world, p, id, 5, id)])
		await get_tree().create_timer(0.3, true, false, true).timeout
	world.hud.stolen_skill("spear_boomerang", "randgris_fallen")
	for i in 3:
		await get_tree().create_timer(0.1 if i == 0 else 0.4, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/stolen_%d.png" % [dir, i])
	get_tree().quit()






func _touchsell_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("tour_god", true)
	world.start_run("swordsman")
	await get_tree().create_timer(1.5, true, false, true).timeout
	var eq: Equipment = world.player.equipment
	for id in ["blade", "cotton_shirt", "boots"]:
		eq.bag.append(Equipment.make(id, 1))
	world.menus.show_inventory(-1)
	await get_tree().create_timer(0.4, true, false, true).timeout
	var cells: = world.menus.find_children("*", "Button", true, false).filter( func(b): return (b as Button).icon != null and b.get_signal_connection_list("gui_input").size() > 0)
	print("TOUCHSELL touch=%s bag=%d cells=%d" % [Menus.touch_ui(), eq.bag.size(), cells.size()])
	var tap: = InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = false
	cells[0].gui_input.emit(tap)
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/tap.png" % dir)
	cells = world.menus.find_children("*", "Button", true, false).filter( func(b): return (b as Button).icon != null and b.get_signal_connection_list("gui_input").size() > 0)
	var hold: = InputEventMouseButton.new()
	hold.button_index = MOUSE_BUTTON_RIGHT
	hold.pressed = true
	var z0: = world.run_zeny
	cells[0].gui_input.emit(hold)
	await get_tree().create_timer(0.3, true, false, true).timeout
	print("TOUCHSELL after long press bag=%d (want 3, nothing sold) zeny+%d card=%s" % [eq.bag.size(), world.run_zeny - z0, world.menus._hover_card != null and is_instance_valid(world.menus._hover_card)])
	get_tree().quit()




func _quake_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("tour_god", true)
	world.start_run("merchant")
	await get_tree().create_timer(2.0, true, false, true).timeout
	world.player.equipment.receive(Equipment.make("orcish_axe", 0))
	world.player.recompute()
	Uniques._quake(world, world.player)
	for i in Vfx._crack_tex.size():
		(Vfx._crack_tex[i] as Texture2D).get_image().save_png("%s/crack_%d.png" % [dir, i])
	print("QUAKE time_scale=", Engine.time_scale, " paused=", get_tree().paused)
	for t in [0.08, 0.25, 0.7, 1.1]:
		await get_tree().create_timer(t if t == 0.08 else 0.17 if t == 0.25 else 0.45 if t == 0.7 else 0.4, false).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/quake_%d.png" % [dir, int(t * 100)])
	get_tree().quit()




func _keeptower_test() -> void :
	await get_tree().create_timer(1.0, true, false, true).timeout
	Save.unlock_tower()
	Save.add_zeny(500000)
	world.start_run("swordsman")
	var p: Player = world.player
	while p.level < GameData.TOWER_BUILD_MIN_LEVEL:
		p.level += 1
	p.equipment.receive(Equipment.make("blade", 2))
	print("KEEPTOWER worn=%s perm=%s" % [p.equipment.slots.weapon.id, Equipment.is_perm(p.equipment.slots.weapon)])
	for id in ["excalibur", "mysteltainn", "grimtooth"]:
		p.equipment.bag.append(Equipment.make(id, 0))
	for id in ["blade", "cotton_shirt", "boots", "guard"]:
		p.equipment.bag.append(Equipment.make(id, 3 if id != "boots" else 1))
	Save.add_to_storage(Equipment.make("excalibur", 0), true)
	world._end_run(true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("C:/Users/usuario/AppData/Local/Temp/claude/6dd9cc4bf86ba049/b5988a12-6b56-4c3c-bc49-0653b07242d9/scratchpad/keep_tabs.png")
	var keep_btns: = world.menus.find_children("*", "Button", true, false).filter( func(b): return (b as Button).custom_minimum_size == Vector2(58, 62))
	var offer: Array = world.menus._keep_offer
	var wi: = -1
	for i in offer.size():
		if str(offer[i].get("_slot", "")) == "weapon":
			wi = i
	print("KEEPTOWER offer=%d buttons=%d weapon_at=%d snap=%s" % [offer.size(), keep_btns.size(), wi, p.has_meta("tower_snap")])

	for b in keep_btns:
		b.pressed.emit()
	for b in keep_btns:
		if not b.has_meta("kept"):
			continue
		print("KEEPTOWER kept uid=", b.get_meta("kept"))
	var snap: Dictionary = p.get_meta("tower_snap")
	print("KEEPTOWER snap weapon perm=%s uid=%s saved_same=%s" % [snap.slots.weapon.get("perm", false), snap.slots.weapon.get("kept_uid", ""), is_same(Save.tower_builds().back(), snap)])
	var builds: = Save.tower_builds().size()
	world.menus._end_leave( func(): pass)
	world.abandon_run()
	world.start_tower(builds - 1, 1)
	await get_tree().create_timer(1.0, true, false, true).timeout
	var w = world.player.equipment.slots.weapon
	print("KEEPTOWER tower weapon=%s perm=%s sellable=%s" % [w.id, Equipment.is_perm(w), Equipment.can_sell(w)])
	get_tree().quit()


func _stewbuild_test() -> void :
	await get_tree().create_timer(1.0, true, false, true).timeout

	Save.set_upgrade_level("sage_root", 3)
	world.start_run("swordsman")
	var p: Player = world.player
	p.dishes = ["immortal_stew"]
	for i in 1500:
		p.on_kill()
	var before: = p.max_hp
	var build: Dictionary = str_to_var(var_to_str(RunSave.hero_snapshot(world)))
	world.abandon_run()
	world.start_run("swordsman")
	world.player.dishes = []
	RunSave.apply_hero(world, build)
	print("STEWBUILD before=%.0f after=%.0f stew=%.0f kills=%d (1500 kills: 1500 + 0 = 1500) root=%.0f (Nv3, 1500 kills: 600 + 225 = 825)" % [before, world.player.max_hp, world.player.stew_hp, world.player.stew_kills, world.player.root_hp])
	get_tree().quit()




func _hidpi_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	for sz in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		get_window().size = sz
		await get_tree().create_timer(0.8, true, false, true).timeout
		world.menus.show_sn_build( func(): pass)
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/sn_%d.png" % [dir, sz.y])
	get_tree().quit()


func _records_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var names: = ["Ragnar", "Lunatica", "xXSniperXx", "Poring", "Aventurero", "Hela", "Thor", "Ymir", "Kafra", "Merlin"]
	var top: = []
	for i in names.size():
		top.append({"rank": i + 1, "name": names[i], "tag": "#%04X" % (4096 + i * 1337), "score": 98000 - i * 7300, 
			"time": 1900 - i * 90, "zeny": 64000 - i * 4100, "danger": 12 - i / 2, "mvps": 3 - i / 4, "me": i == 6})
	world.board._cache["swordsman|prontera"] = {"month": "2026-10", "days_left": 12, "total": 48, "top": top, 
		"me": null, "_at": Time.get_ticks_msec()}
	var classes: = GameData.CLASSES.keys()
	var all_top: = []
	for r in top:
		var r2: Dictionary = r.duplicate()
		r2["class"] = classes[int(r.rank) % classes.size()]
		all_top.append(r2)
	world.board._cache["all|prontera"] = {"month": "2026-10", "days_left": 12, "total": 131, "top": all_top, 
		"me": null, "_at": Time.get_ticks_msec()}
	world.menus._run_class = "swordsman"
	world.menus.show_server_select("swordsman")
	for sz in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		get_window().size = sz
		await get_tree().create_timer(0.8, true, false, true).timeout
		world.menus.show_server_select("swordsman")
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/rec_%d.png" % [dir, sz.x])
	var ws: WorldSelect = world.menus.find_children("*", "WorldSelect", true, false)[0]
	ws._switch_class(["all"] + GameData.CLASSES.keys(), -1)
	ws._switch_class(["all"] + GameData.CLASSES.keys(), -1)
	ws._board_class = "all"
	if ws._side_tab != "records":
		ws._toggle_records()
	ws._fill_records()
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/rec_all.png" % dir)
	ws._toggle_records()
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/rec_closed.png" % dir)
	ws._toggle_records()
	get_tree().quit()




func _esc_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var m: Node = world.menus
	var esc: = func():
		var ev: = InputEventKey.new()
		ev.keycode = KEY_ESCAPE
		ev.physical_keycode = KEY_ESCAPE
		ev.pressed = true
		Input.parse_input_event(ev)
		await get_tree().create_timer(0.3, true, false, true).timeout
		var up: = ev.duplicate()
		up.pressed = false
		Input.parse_input_event(up)
		await get_tree().create_timer(0.3, true, false, true).timeout
	m.show_class_select()
	await get_tree().create_timer(0.5, true, false, true).timeout
	m.show_album()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await esc.call()
	print("ESC album -> ", m._mode)
	m.show_loadout("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	await esc.call()
	print("ESC loadout -> ", m._mode)
	m.show_char_make("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var cm: RoCharMake = m.find_children("*", "RoCharMake", true, false)[0]
	cm._name_edit.grab_focus()
	await get_tree().create_timer(0.3, true, false, true).timeout
	await esc.call()
	print("ESC profile -> ", m._mode)
	get_tree().quit()





func _upgrades_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(label: String):
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/up_%s.png" % [dir, label])
	Save.add_zeny(200000)
	for id in ["blessing", "fury", "hp_recovery", "memorize", "bloody_branch", "magnifier"]:
		Save.set_upgrade_level(id, 2)
	Save.set_upgrade_on("bloody_branch", false)
	Save.set_upgrade_on("magnifier", false)
	print("meta: ", GameData.meta_mods())
	world.menus.show_kafra()
	await shot.call("0_kafra")
	world.menus.show_sage()
	await shot.call("1_sage")
	Save.set_upgrade_on("bloody_branch", true)
	print("meta with curse: ", GameData.meta_mods())
	_set_class_level("gunslinger", 50)
	world.menus.show_char_make("gunslinger")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var cm: RoCharMake = world.menus.find_children("*", "RoCharMake", true, false)[0]
	for i in 80:
		cm._place("agi", 1)
	print("points left: ", cm._points_left(), "  agi pending: ", cm._pending.get("agi", 0))
	await shot.call("2_all_agi")
	cm._accept()
	await get_tree().create_timer(0.3, true, false, true).timeout
	world.start_run("gunslinger")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	print("run agi=", p.stats.agi, " base=", p.base_stats.agi, " run=", p.run_stat("agi"), " eff=", p.eff_stat("agi"))
	p.add_stat("agi")
	p.add_stat("agi")
	print("after 2 picks: run=", p.run_stat("agi"), " eff=", p.eff_stat("agi"))
	world.menus.show_level_up([{"kind": "stat", "id": "agi", "from": p.stats.agi, "level": p.stats.agi + 2, "rarity": 1}, 
		{"kind": "stat", "id": "vit", "from": p.stats.vit, "level": p.stats.vit + 1, "rarity": 0}])
	await shot.call("3_levelup")
	get_tree().quit()




func _invfull_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(label: String):
		await get_tree().create_timer(0.7, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/inv_%s.png" % [dir, label])
	world.danger = 4
	world.start_run("swordsman")
	await get_tree().create_timer(1.5, true, false, true).timeout
	await shot.call("0_hud")
	var eq: Equipment = world.player.equipment
	while eq.bag.size() < GameData.INVENTORY_MAX:
		eq.bag.append(eq.roll_item(60.0, 0))
	world.menus.show_equipment()
	await shot.call("1_full_hint")
	world.menus.show_equipment()
	await shot.call("2_second_time")
	world.menus._resume()
	await get_tree().create_timer(0.3, true, false, true).timeout
	for i in 3:
		world._sale_feedback(world.player.position + Vector3(1.5, 0, 0), 84)
		await get_tree().create_timer(0.15, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/inv_3_sale.png" % dir)
	get_tree().quit()



func _hold_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	_set_class_level("gunslinger", 50)
	world.menus.show_char_make("gunslinger")
	await get_tree().create_timer(0.6, true, false, true).timeout
	var cm: RoCharMake = world.menus.find_children("*", "RoCharMake", true, false)[0]
	var arrow: TextureButton = null
	for c in cm.get_children():
		if c is TextureButton and not c.flip_h and c.tooltip_text == tr("Poner punto"):
			arrow = c
			break
	var at: = arrow.get_global_rect().get_center()
	var down: = InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = at
	down.global_position = at
	Input.parse_input_event(down)
	await get_tree().create_timer(1.2, true, false, true).timeout
	var up: = down.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().create_timer(0.3, true, false, true).timeout
	print("HOLD placed: ", cm._pending, " left ", cm._points_left())
	get_tree().quit()




func _levels_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(1.5, true, false, true).timeout
	var p: Player = world.player
	var need: = float(p.xp_need) + GameData.xp_to_next(p.level + 1) + 1.0
	p.add_xp(need / (p.pace_xp * p.xp_mult))

	world._drop_xp(p.position + Vector3(2.5, 0, 0), int(GameData.xp_to_next(p.level + 2) * 1.2 / (p.pace_xp * p.xp_mult)))
	for pk in world.pickups:
		pk.pull = true
	var shot: = func(label: String):
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/lv_%s.png" % [dir, label])
	await shot.call("0")
	print("LEVELS mode=", world.menus._mode, " pending=", p.pending_levels, " level=", p.level)
	for i in 4:
		world.menus._grace = 0.0
		world.menus._pick(0)
		await get_tree().create_timer(0.1, true, false, true).timeout
		print("  after pick ", i, ": mode=", world.menus._mode, " pending=", p.pending_levels)
		await shot.call(str(i + 1))
		if p.pending_levels <= 0:
			break
	get_tree().quit()



func _portal_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.raid.open_portal("baphomet")
	await get_tree().create_timer(0.5, true, false, true).timeout
	get_tree().paused = false
	world.menus.close()
	world.player.position = world.raid.portal_pos + Vector3(-16.0, 0, -10.0)
	for i in 2:
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/portal_%d.png" % [dir, i])
	get_tree().quit()



func _aspd_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	for cls in ["thief", "archer", "gunslinger"]:
		world.start_run(cls)
		await get_tree().create_timer(0.5, true, false, true).timeout
		var p: Player = world.player
		for agi in [10, 40, 70, 120]:
			p.stats.agi = agi
			p.recompute()
			print("%s agi=%d aspd=%.1f delay=%.3f hits/swing=%.2f" % [cls, agi, p.aspd(), p.attack_delay(), p.swing_hits()])
		var e: = world.spawn_enemy("poring", p.position + Vector3(1.2, 0, 0), true, true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 1000000000.0
			e.hp = e.max_hp
		await get_tree().create_timer(2.0, true, false, true).timeout
		print("  %s dealt basic=%s in 2 s" % [cls, str(world.meter.get("basic", 0.0))])
	get_tree().quit()





func _arena_survey_test() -> void :
	await get_tree().create_timer(1.0, true, false, true).timeout
	var raid = world.raid
	var keep: Dictionary = raid.data

	var tries: Array = []
	for pair in OS.get_environment("ARENA_TRY").split(",", false):
		tries.append([pair.get_slice(":", 0), pair.get_slice(":", 1)])
	if tries.is_empty():
		for id in GameData.RAIDS:
			tries.append([id, str(GameData.RAIDS[id].get("arena", ""))])
	for tr_pair in tries:
		var id: String = tr_pair[0]
		var d: Dictionary = GameData.RAIDS[id].duplicate()
		d["arena"] = tr_pair[1]
		if str(d.arena) == "" or str(d.arena).begins_with("6@"):
			continue
		var m: = RoMap.new()
		world.add_child(m)
		m.load_map(str(d.arena))
		var line: = "ARENASURVEY %-20s %-12s" % [id, d.arena]
		for flat in [false, d.get("flat", false)]:
			var dd: = d.duplicate()
			dd["flat"] = flat
			raid.data = dd
			raid._open_cache.clear()
			var open: Array = raid._find_open(m, float(d.get("radius", 13.0)))
			var c: Vector3 = open[0]
			var r: float = open[1]
			var h0: = m.height_at(c)
			var lo: = h0
			var hi: = h0
			for ring in range(2, int(r) + 1, 2):
				for k in 24:
					var at: = c + Vector3(cos(TAU * k / 24.0), 0, sin(TAU * k / 24.0)) * float(ring)
					if m.is_walkable(at):
						lo = minf(lo, m.height_at(at))
						hi = maxf(hi, m.height_at(at))
			line += "  %s r=%.0f/%.0f spread=%.2f" % [str(flat), r, float(d.get("radius", 13.0)), hi - lo]
		print(line)
		m.queue_free()
		await get_tree().process_frame
	raid.data = keep
	raid._open_cache.clear()
	get_tree().quit()




func _arena_flat_test(stage: String, dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.set_stage(stage)
	world.start_run("mage")
	world.player.max_hp = 10000000.0
	world.player.hp = 10000000.0
	await get_tree().create_timer(1.0, true, false, true).timeout
	_to_mvp(true)
	for i in 60:
		if world.raid.in_arena():
			break
		_to_mvp(true)
		if world.raid.state == "portal":
			world.player.position = world.raid.portal_pos
		world.get_tree().paused = false
		world.menus.close()
		await get_tree().create_timer(0.5, true, false, true).timeout
	await get_tree().create_timer(3.0, true, false, true).timeout
	var c: Vector3 = world.raid.center
	var r: float = world.raid.radius
	var lo: = 1000000000.0
	var hi: = -1000000000.0
	for ring in range(0, int(r) + 1, 2):
		for k in 24:
			var at: = c + Vector3(cos(TAU * k / 24.0), 0, sin(TAU * k / 24.0)) * float(ring)
			var h: = world.map.height_at(at)
			lo = minf(lo, h)
			hi = maxf(hi, h)
	print("ARENAFLAT stage=%s state=%s map=%s center=%s radius=%.1f height %.2f..%.2f (spread %.2f)" % [stage, world.raid.state, world.map.map_name, c, r, lo, hi, hi - lo])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, stage])
	get_tree().quit()




func _arena_map_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.set_stage("juperos")
	world.start_run("mage")
	await get_tree().create_timer(1.0, true, false, true).timeout
	_to_mvp(true)
	await get_tree().create_timer(4.0, true, false, true).timeout
	print("ARENA in_arena=", world.raid.in_arena(), " map=", world.map.map_name)
	world._end_run(false)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.set_stage("pay_cave")
	world.start_run("mage")
	await get_tree().create_timer(1.5, true, false, true).timeout
	print("ARENA next run stage=", world.stage_id, " map=", world.map.map_name, " (want pay_dun04)")
	get_tree().quit()




func _crusader_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	p.job_change(1)
	p.equipment.slots["shield"] = {"id": "mirror_shield", "refine": 0, "slots": 0, "cards": []}
	print("CRUSADER boomerang sprite=", Skills._proj_sprite(p, GameData.SKILLS.shield_boomerang))
	for e in world.enemies.duplicate():
		world.banish_enemy(e)
	var foes: = []
	for i in 3:
		var e: = world.spawn_enemy("poring", p.position + Vector3(6.0 + i * 0.6, 0, 0.3 * i), true, true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 1000000.0
			e.hp = e.max_hp
			foes.append(e)
	await get_tree().create_timer(0.3, true, false, true).timeout
	var hp0: float = foes[0].hp
	print("CRUSADER holy cross cast=", Skills.cast(world, p, "holy_cross", 3))
	await get_tree().create_timer(0.3, true, false, true).timeout
	print("CRUSADER holy cross damage on far poring=", hp0 - foes[0].hp)
	Skills.cast(world, p, "shield_boomerang", 3)
	await get_tree().create_timer(0.25, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/crusader.png" % dir)
	get_tree().quit()




func _skillbar_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	p.job_change(1)
	var ids: = ["bash_x", "magnum_break", "grand_cross", "holy_cross", "shield_boomerang", "endure", "provoke"]
	for id in ids:
		if GameData.SKILLS.has(id):
			for k in 3:
				p.add_skill(id)
				await get_tree().create_timer(0.15, true, false, true).timeout
			print("SKILLBAR %d skills: window w=%.0f" % [world.hud._skill_slots.size(), world.hud._skill_window.size.x])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/skillbar.png" % dir)
	get_tree().quit()




func _title_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var longest: = GameData.EVOLUTIONS.keys()
	longest.sort_custom( func(a, b): return tr(str(GameData.SKILLS[GameData.EVOLUTIONS[a].to].name)).length() > tr(str(GameData.SKILLS[GameData.EVOLUTIONS[b].to].name)).length())
	var choices: = []
	for id in longest.slice(0, 4):
		choices.append({"kind": "evolve", "id": id, "to": GameData.EVOLUTIONS[id].to, "level": 10, "rarity": 0})
	print("TITLE longest: ", choices.map( func(c): return GameData.SKILLS[c.to].name))
	world.menus.show_level_up(choices)
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/titles.png" % dir)
	get_tree().quit()




func _jobpick_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.do_job_change(0)
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/jobpick.png" % dir)
	print("JOBPICK mode=", world.menus._mode, " options=", world.menus._choices)
	world.menus._grace = 0.0
	world.menus._pick_start(1)
	await get_tree().create_timer(0.6, true, false, true).timeout
	print("JOBPICK skills=", world.player.skills.keys(), " paused=", get_tree().paused, " mode=", world.menus._mode)
	get_tree().quit()




func _mvpchest_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(1.0, true, false, true).timeout
	_to_mvp(true)
	await get_tree().create_timer(5.0, true, false, true).timeout
	var b: Enemy = world.raid.boss
	if b == null:
		print("MVPCHEST no boss")
		get_tree().quit()
		return
	world._drop_chest(b.position + Vector3(4, 0, 0), 2, 1)
	world.player.position = b.position + Vector3(-6, 0, 0)
	world.damage_enemy(b, 1000000000.0, Vector3.ZERO, "skill", "neutral")
	for i in 30:
		await get_tree().create_timer(0.5, true, false, true).timeout
		if world.menus._mode == "chest":
			world.menus._close_chest()
		if world.menus._mode == "level_up":
			world.menus._grace = 0.0
			world.menus._pick(0)
		var chests: = world.pickups.filter( func(p): return p.kind == "chest").size()
		if world.menus._mode == "victory" or i % 4 == 0:
			print("MVPCHEST t=%.1f chests=%d mode=%s" % [i * 0.5, chests, world.menus._mode])
		if world.menus._mode == "victory":
			break
	get_tree().quit()




func _npc_test(dir: String) -> void :
	var shot: = func(label: String):
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/npc_%s.png" % [dir, label])
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.add_zeny(500000)
	var m: Menus = world.menus
	m.show_kafra()
	await shot.call("0_kafra")
	var sc: ScrollContainer = m._root.find_children("*", "ScrollContainer", true, false)[0]
	sc.scroll_vertical = 120
	await get_tree().create_timer(0.2, true, false, true).timeout
	var before: = sc.scroll_vertical
	m._buy_upgrade("hp_recovery")
	await get_tree().create_timer(0.4, true, false, true).timeout
	var sc2: ScrollContainer = m._root.find_children("*", "ScrollContainer", true, false)[0]
	print("NPC kafra scroll before=", before, " after buy=", sc2.scroll_vertical)
	await shot.call("1_kafra_after_buy")
	m._kafra_tab = 1
	m.show_kafra()
	await shot.call("2_kafra_tab_skills")
	for c in GameData.CARDS:
		Save.data.cards[c] = 1
	m._album_tab = "cards"
	m._album_slot = "head"
	m.show_album()
	await shot.call("3_album_head")
	for pid in ["poring", "lunatic", "drainliar", "isis"]:
		Save.add_pet(pid)
	Save.set_active_pet("drainliar")
	Save.set_pet_skin("poring")
	m._album_tab = "pets"
	m.show_album()
	await shot.call("4_album_pets")
	Save.add_to_storage(Equipment.make("cotton_shirt", 2))
	var it: Dictionary = Save.storage()[-1]
	it["extra_slots"] = 1
	Save.set_setting("socket_hint_done", false)
	m._socket_uid = str(it.uid)
	m._eternal_sel = -1
	m.show_socket(tr("«¡Hecho! %s, con un hueco más. Haz clic en el hueco «+» para ponerle una Carta Eterna.»") % Equipment.item_name(it))
	await shot.call("5_socket_hint")
	world.start_run("mage")
	await get_tree().create_timer(1.0, true, false, true).timeout
	print("NPC pet bonus=", world.player.pet_id, " lifesteal=", world.player.effects.get("lifesteal", 0.0), " follower=", Save.pet_skin())
	get_tree().quit()




func _crit_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("thief")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	for luk in [5, 20, 40, 70]:
		p.stats.luk = luk
		p.recompute()
		print("CRIT luk=%d crit=%.2f over=%.2f crit_dmg=%.2f" % [luk, p.crit, p.crit_over, p.crit_dmg])
	p.meta["crit_dmg"] = 0.5
	p.recompute()
	print("CRIT ultra=", p.ultra_crit, " crit_dmg=", p.crit_dmg)
	var foe: = world.spawn_enemy("poring", p.position + Vector3(2.0, 0, 0), true, true)
	foe.speed = 0.0
	foe.max_hp = 10000000.0
	foe.hp = foe.max_hp
	await get_tree().create_timer(0.4, true, false, true).timeout
	for i in 3:
		world.damage_enemy(foe, 50.0, Vector3.ZERO, "skill", "neutral")
		await get_tree().create_timer(0.15, true, false, true).timeout
	await get_tree().create_timer(0.05, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/crit_ultra.png" % dir)
	world.menus.show_equipment()
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/crit_status.png" % dir)
	world.menus._resume()
	world.menus.show_level_up([{"kind": "stat", "id": "luk", "from": p.stats.luk, "level": p.stats.luk + 1, "rarity": 0}])
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/crit_card.png" % dir)
	get_tree().quit()




func _frenzy_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.clear_stage("prontera")
	world.set_stage("prontera")
	world.speed = 2
	world.menus.show_server_select("swordsman")
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/frenzy_select.png" % dir)
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var t0: float = world.time
	await get_tree().create_timer(2.0, true, false, true).timeout
	print("FRENZY run: scale=%.2f clock advanced %.2f s in 2 real s, loot_mult=%.2f" % [Engine.time_scale, world.time - t0, world.player.loot_mult])
	world.player.pending_levels = 1
	await get_tree().create_timer(0.5, true, false, true).timeout
	print("FRENZY level-up open: paused=", get_tree().paused, " scale=", Engine.time_scale)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/frenzy_hud.png" % dir)
	get_tree().quit()




func _storm_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(label: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/st_%s.png" % [dir, label])
	Save.clear_stage("prontera")
	world.set_stage("prontera")
	world.speed = 2
	world.danger = 10
	world.menus.auto_pick = true
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	for kind in ["feroz", "veloz", "maldito", "gigante"]:
		var e: = world.spawn_enemy("poring", p.position + Vector3(randf_range(-4, 4), 0, randf_range(-3, -1)), true, false, kind)
		if e != null:
			e.speed = 0.0
	world._storm_strike()
	await get_tree().create_timer(0.7, true, false, true).timeout
	await shot.call("0_storm")
	var hp0: = p.hp
	await get_tree().create_timer(1.5, true, false, true).timeout
	print("STORM hp %d -> %d (max %d)" % [hp0, p.hp, p.max_hp])
	world._drop_chest(p.position + Vector3(3.0, 0, 0), 1, -1)
	await get_tree().create_timer(1.5, true, false, true).timeout
	print("STORM chests left on the ground: ", world.pickups.filter( func(x): return x.kind == "chest").size(), " mode=", world.menus._mode)
	if world.menus._mode == "chest":
		world.menus._close_chest()
	print("STORM frenzy scale before MVP: ", Engine.time_scale, " paused=", get_tree().paused)
	world.raid.open_portal(str(world.stage.mvp))
	world.get_tree().paused = false
	world.menus.close()
	await get_tree().create_timer(0.5, true, false, true).timeout
	print("STORM frenzy scale with MVP portal: ", Engine.time_scale)
	get_tree().quit()



func _guard_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.auto_pick = true
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.altars._call_guardians(world.player.position + Vector3(0, 0, -2.0))
	for i in 2:
		await get_tree().create_timer(0.5 + i, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/guard_%d.png" % [dir, i])
	get_tree().quit()




func _peco_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.auto_pick = true
	for path in [0, 1]:
		world.start_run("swordsman")
		await get_tree().create_timer(0.8, true, false, true).timeout
		var p: Player = world.player
		p.job_change(path)
		p.add_skill("peco_riding")
		print("PECO path %d mount=%s" % [path, p.mount()])
		await get_tree().create_timer(1.2, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/peco_%d.png" % [dir, path])
	world.start_run("archer")
	await get_tree().create_timer(0.8, true, false, true).timeout
	world.player.job_change(1)
	for i in 6:
		Skills.cast(world, world.player, "poem_of_bragi", 1)
		Skills.cast(world, world.player, "dissonance", 1)
		await get_tree().create_timer(0.3, true, false, true).timeout
	print("PECO song playing=", world._song_player != null and world._song_player.playing)
	get_tree().quit()




func _sig_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.auto_pick = true
	var shot: = func(label: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/sig_%s.png" % [dir, label])

	var cases: = [["swordsman", 0, ["auto_counter"], 6.0], ["swordsman", 1, ["reflect_shield"], 6.0], 
		["mage", 1, ["hindsight"], 6.0], ["archer", 0, ["steel_crow"], 6.0], ["thief", 0, ["enchant_poison"], 6.0], 
		["acolyte", 0, ["aspersio"], 4.0], ["acolyte", 1, ["triple_attack", "chain_combo", "combo_finish"], 8.0], 
		["merchant", 0, ["weapon_perfection"], 4.0], ["merchant", 1, ["call_homunculus"], 8.0], 
		["gunslinger", 0, ["coin_flip"], 8.0], ["archer", 1, ["assassin_cross_sunset"], 4.0], ["mage", 0, ["mystical_amplification"], 6.0]]
	for c in cases:
		world.start_run(str(c[0]))
		await get_tree().create_timer(0.5, true, false, true).timeout
		var p: Player = world.player
		p.job_change(int(c[1]))
		if c[0] == "swordsman" and int(c[1]) == 1:
			p.equipment.slots["shield"] = {"id": "buckler", "refine": 0, "slots": 0, "cards": []}
		for sid in c[2]:
			for k in 5:
				p.add_skill(sid)
		p.recompute()
		if sid_has(c[2], "call_homunculus"):
			p.homun_type = "homun_vanilmirth"
			world.spawn_homun()
		if sid_has(c[2], "triple_attack"):
			p.effects["triple"] = 1.0
		for i in 8:
			var e: = world.spawn_enemy("poring", p.position + Vector3(1.0 + i * 0.4, 0, 0.5 * (i % 3)), true, false)
			if e != null:
				e.speed = 0.6
				e.max_hp = 1000000.0
				e.hp = e.max_hp
		await get_tree().create_timer(float(c[3]) * 0.5, true, false, true).timeout
		if c[0] == "acolyte" and int(c[1]) == 1:
			await shot.call("monk")
		if sid_has(c[2], "call_homunculus"):
			var h: Homunculus = world.homun
			print("SIG homun valid=", is_instance_valid(h), " pos=", h.position if is_instance_valid(h) else Vector3.ZERO, " hero=", p.position, 
				" ro=", h.visual.ro != null if is_instance_valid(h) else false, " vis=", h.visible if is_instance_valid(h) else false, " inside=", h.is_inside_tree() if is_instance_valid(h) else false)
			await shot.call("homun")
		await get_tree().create_timer(float(c[3]) * 0.5, true, false, true).timeout
		var lines: = []
		for tag in world.meter:
			lines.append("%s=%d" % [tag, int(world.meter[tag].dmg)])
		print("SIG %s/%d %s coins=%d el=%s aspd_bonus=%.2f amp=%s meter: %s" % [c[0], c[1], c[2], p.coins, p.basic_element(), p.aspd_bonus, str(p.effects.get("amp", 0)), ", ".join(lines)])

	world.start_run("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var kp: Player = world.player
	kp.job_change(0)
	for k in 5:
		kp.add_skill("auto_counter")
	kp.recompute()
	var foe: = world.spawn_enemy("poring", kp.position + Vector3(1, 0, 0), true, false)
	foe.max_hp = 1000000.0
	foe.hp = foe.max_hp
	var hp0: = kp.hp
	for i in 40:
		kp._invuln = 0.0
		kp.take_damage(5.0, world, foe)
	print("SIG auto counter: hp lost %d of 200 (counters avoid hits), meter=%s" % [hp0 - kp.hp, world.meter.get("auto_counter", {}).get("dmg", 0)])
	world.start_run("gunslinger")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var gp: Player = world.player
	for k in 5:
		gp.add_skill("coin_flip")
	gp.recompute()
	for i in 30:
		gp.gain_coin(world, 1.0)
	print("SIG coins: %d (cap %s) dmg_mult=%.2f" % [gp.coins, str(gp.effects.get("coins")), gp.dmg_mult])
	await get_tree().create_timer(0.6, true, false, true).timeout
	await shot.call("coins")

	world.start_run("thief")
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.player.job_change(1)
	var b: = world.spawn_enemy("eddga", world.player.position + Vector3(2, 0, 0), true, false)
	b.hp = 1.0
	world.damage_enemy(b, 100.0)
	await get_tree().create_timer(0.5, true, false, true).timeout
	print("SIG plagiarized: ", Save.plagiarized(), " pool has magnum_break: ", world.player.skill_pool().has("magnum_break"))
	world.menus._album_tab = "plagio"
	world.menus.show_album()
	await get_tree().create_timer(0.6, true, false, true).timeout
	await shot.call("plagio")
	get_tree().quit()


func sid_has(list: Array, id: String) -> bool:
	return list.has(id)




func _filter_test(dir: String) -> void :
	var bad: = ["Nigger", "n1gg3r", "N i g g a", "niiiiggggaaa", "Faggot", "puta", "PUTO", "hijo de puta", "Culiao", 
		"weon", "Hitler88", "fuck you", "p.u.t.a", "Perrra", "ass", "KKK", "Maricón", "conchetumare", "sh1t", "Negro"]
	var good: = ["Ragnar", "Computadora", "Peacock", "Dickens", "Pera", "Crisis", "Pedro", "Cassandra", "Assassin", 
		"Lunatica", "Aventurero", "Vergara", "Scunthorp", "Nigel", "Classic", "Kakashi", "Asuna", "Puttin", "Mar"]
	for n in bad:
		print("BAD  %-16s %s" % [n, "ok" if not NameFilter.allowed(n) else "MISSED"])
	for n in good:
		print("GOOD %-16s %s" % [n, "ok" if NameFilter.allowed(n) else "BLOCKED"])
	print("CLEAN ", NameFilter.clean("hola puta que tal"))
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.show_char_make("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var cm: RoCharMake = world.menus.find_children("*", "RoCharMake", true, false)[0]
	cm._name_edit.text = "Nigger"
	cm._accept()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/name_refused.png" % dir)
	print("MODE after refused name: ", world.menus._mode)
	world.menus.show_loading( func(): world.enter_town("swordsman"))
	await get_tree().create_timer(6.0, true, false, true).timeout
	var crowd = world.town._crowd
	crowd._chat_bar.visible = true
	crowd._chat_box.grab_focus()
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/chat_empty.png" % dir)
	crowd._chat_box.text = "hola a todos, busco party"
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/chat_text.png" % dir)
	get_tree().quit()


func _privacy_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(label: String):
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/priv_%s.png" % [dir, label])
	world.menus.show_privacy_notice()
	await shot.call("0_notice")
	world.menus.show_privacy()
	await shot.call("1_policy")
	world.menus.show_options()
	await shot.call("2_options")
	get_tree().quit()




func _aura_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.data.rebirths["swordsman"] = 1
	Save.data["classes"] = {"swordsman": {"level": GameData.REBIRTH_CLASS_MAX_LEVEL, "xp": 0, "stats": {}}}
	world.menus.show_class_select("swordsman")
	for i in 3:
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/aura_%d.png" % [dir, i])
	world.enter_town("swordsman")
	await get_tree().create_timer(3.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/aura_town.png" % dir)
	world.start_run("swordsman")
	await get_tree().create_timer(2.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/aura_run.png" % dir)
	get_tree().quit()




func _townesc_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.enter_town("swordsman")
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var esc: = func():
		var ev: = InputEventAction.new()
		ev.action = "pause"
		ev.pressed = true
		Input.parse_input_event(ev)
	await wait.call(1.5)
	esc.call()
	await wait.call(0.6)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/town_leave.png" % dir)
	print("TOWNESC after esc: ", world.menus.mode())
	esc.call()
	await wait.call(0.4)
	print("TOWNESC after 2nd esc: ", world.menus.mode())
	for w in ["kafra", "sage", "refiner"]:
		world.menus.call("show_" + w)
		await wait.call(0.4)
		esc.call()
		await wait.call(0.4)
		print("TOWNESC %s + esc: %s" % [w, world.menus.mode()])
	get_tree().quit()




func _elword_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("acolyte")
	world.player.max_hp = 99999.0
	world.player.hp = 99999.0
	var mobs: Array = []
	for i in 3:
		var e: Enemy = world.spawn_enemy("zombie", world.player.position + Vector3(-2.5 + 2.5 * i, 0, 2.0), true)
		e.max_hp = 99999.0
		e.hp = 99999.0
		e.speed = 0.0
		mobs.append(e)
	await get_tree().create_timer(0.5, true, false, true).timeout
	for e in mobs:
		world.damage_enemy(e, 60.0, Vector3.ZERO, "skill", "holy")
	await get_tree().create_timer(0.15, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/elword.png" % dir)
	get_tree().quit()




func _petalbum_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	for id in GameData.PETS:
		Save.add_pet(id)
	Save.set_active_pet("poring")
	world.menus._album_tab = "pets"
	world.menus.show_album()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/pets.png" % dir)
	get_tree().quit()





func _ninja_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.auto_pick = true
	var shot: = func(label: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/ninja_%s.png" % [dir, label])
	world.menus.show_class_select("ninja")
	await get_tree().create_timer(1.0, true, false, true).timeout
	await shot.call("select")
	if "--only-select" in OS.get_cmdline_user_args():
		get_tree().quit()
		return
	var job_skills: Array = GameData.CLASSES.ninja.job2.skills
	var ids: Array = (GameData.CLASSES.ninja.skills as Array).filter( func(id): return id != "first_aid") + job_skills
	for id in ids.duplicate():
		if GameData.EVOLUTIONS.has(id):
			ids.append(GameData.EVOLUTIONS[id].to)
	for id in ids:
		world.start_run("ninja")
		await get_tree().create_timer(0.4, true, false, true).timeout
		var p: Player = world.player
		if job_skills.has(str(id).trim_suffix("_x")):
			p.job_change(0)
		p.skills.clear()
		for k in 5:
			p.add_skill(id)
		p.recompute()
		world.run_zeny = 5000
		for i in 8:
			var e: = world.spawn_enemy("poring", p.position + Vector3(2.0 + i * 0.5, 0, 0.6 * (i % 3) - 0.6), true, false)
			if e != null:
				e.speed = 0.4
				e.max_hp = 10000000.0
				e.hp = e.max_hp
		await get_tree().create_timer(1.2, true, false, true).timeout
		await shot.call(id)
		await get_tree().create_timer(1.8, true, false, true).timeout
		print("NINJA %s lv=%d dmg=%d mirrors=%d hp=%d/%d" % [id, p.skills[id].level, int(world.meter.get(id, {}).get("dmg", 0)), 
			p.mirror_count(), p.hp, p.max_hp])

	world.start_run("ninja")
	await get_tree().create_timer(0.4, true, false, true).timeout
	var np: Player = world.player
	for k in 5:
		np.add_skill("mirror_image")
		np.add_skill("cicada_skin_shed")
	np.recompute()
	var foe: = world.spawn_enemy("poring", np.position + Vector3(1, 0, 0), true, false)
	foe.max_hp = 10000000.0
	foe.hp = foe.max_hp
	await get_tree().create_timer(0.8, true, false, true).timeout
	print("NINJA mirrors after cast: %d (cicada %.1f/min)" % [np.mirror_count(), float(np.effects.get("cicada", 0))])
	await shot.call("mirrors")
	var hp0: = np.hp
	for i in 8:
		np._invuln = 0.0
		np.take_damage(10.0, world, foe)
	print("NINJA after 8 hits: mirrors=%d hp lost=%d" % [np.mirror_count(), hp0 - np.hp])

	for a in GameData.KUNAI:
		np.add_arrow(a)
	np.cycle_arrow(1)
	print("NINJA kunai=%s element=%s switch=%s quiver=%d" % [np.arrow_id, np.arrow_element(), np.can_switch_ammo(), np.quiver.size()])

	world.start_run("ninja")
	await get_tree().create_timer(0.4, true, false, true).timeout
	var op: Player = world.player
	op.appearance["gender"] = "f"
	op.job_change(0)
	print("NINJA female job: %s" % op.job_name())
	for k in 5:
		op.add_skill("mirror_image")
	await get_tree().create_timer(1.0, true, false, true).timeout
	await shot.call("oboro")
	get_tree().quit()






func _unique_bench() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.menus.auto_pick = true
	var ids: Array = GameData.ITEMS.keys().filter( func(id): return GameData.ITEMS[id].get("unique", false) and not GameData.ITEMS[id].get("face", false))
	var only: Array = Array(OS.get_cmdline_user_args()).filter( func(x): return GameData.ITEMS.has(x))
	if not only.is_empty():
		ids = only
	Engine.time_scale = 2.0
	for id in ids:
		var d: Dictionary = GameData.ITEMS[id]
		world.start_run(str(d.get("class", "archer")))
		await get_tree().create_timer(0.4, true, false, true).timeout
		var p: Player = world.player
		p.level = 120
		p.stats["agi"] = int(p.stats.get("agi", 0)) + 40
		p.stats["str"] = int(p.stats.get("str", 0)) + 40
		p.equipment.slots["acc1" if str(d.slot) == "acc" else str(d.slot)] = Equipment.make(id, 0)
		p.recompute()
		var foes: Array = []
		for t in 28:
			foes = foes.filter( func(e): return is_instance_valid(e) and not e.dead)
			while foes.size() < 30:
				var a: = randf() * TAU
				var e: Enemy = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * randf_range(1.0, 3.0), true)
				if e == null:
					break
				e.max_hp = 100000000000.0
				e.hp = 100000000000.0
				e.speed = 0.0
				e.damage = 0.0
				foes.append(e)
			for k in 3:
				if not foes.is_empty():
					world._kill(foes.pop_back())
			await get_tree().create_timer(0.25, true, false, true).timeout
		var total: = 0.0
		var mine: = 0.0
		for tag in world.meter:
			total += float(world.meter[tag].dmg)
			if str(tag).begins_with("u_"):
				mine += float(world.meter[tag].dmg)
		var secs: = maxf(1.0, world.time)
		print("UB %-20s %-12s total/s=%10.0f unique/s=%10.0f share=%5.1f%%" % [id, str(d.get("class", "-")), total / secs, mine / secs, 100.0 * mine / maxf(1.0, total)])
		world.abandon_run()
		await get_tree().create_timer(0.4, true, false, true).timeout
	get_tree().quit()




func _rail_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("gunslinger")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	var foes: Array = []
	for i in 6:
		var e: Enemy = world.spawn_enemy("poring", p.position + Vector3(2.0 + i * 1.5, 0, 0), true)
		e.max_hp = 1000000000.0
		e.hp = e.max_hp
		foes.append(e)
	await get_tree().create_timer(0.3, true, false, true).timeout

	Engine.time_scale = 0.1
	Uniques._rail(world, p, foes[0], 1.5)
	for i in 3:
		await get_tree().create_timer(0.12, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/rail_%d.png" % [dir, i])
	print("RAIL basic=", p.basic_atk(), " hit=", foes.filter( func(e): return e.hp < e.max_hp).size(), "/6 dealt=", 1000000000.0 - foes[0].hp)
	get_tree().quit()




func _sideword_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var e: Enemy = world.spawn_enemy("poring", world.player.position + Vector3(4, 0, -3), true)
	e.max_hp = 1000000000.0
	e.hp = 1000000000.0
	for i in 10:
		world.damage_enemy(e, 500.0 + i, Vector3.ZERO, "basic", "neutral", "basic")
	world.side_word(e, "Coma", Color(0.75, 0.45, 1.0))
	await get_tree().create_timer(0.25, true, false, true).timeout
	world.side_word(e, "Lex Aeterna!", Color(1.0, 0.95, 0.65))
	await get_tree().create_timer(0.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/side.png" % dir)
	get_tree().quit()



func _evodup_ninja() -> void :
	var dir: String = OS.get_cmdline_user_args()[-1]
	world.start_run("ninja")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	var e: Enemy = world.spawn_enemy("poring", p.position + Vector3(4, 0, 0), true)
	e.max_hp = 1000000000.0
	e.hp = 1000000000.0
	await get_tree().create_timer(0.2, true, false, true).timeout
	for id in ["throw_shuriken_x", "flaming_petals_x"]:
		var was: float = e.hp
		print("EVODUP ninja ", id, " cast=", Skills.cast(world, p, id, 1))
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, id])
		print("EVODUP ninja ", id, " dealt=", was - e.hp, " streak=", p._hunt_streak)
	p.equipment.slots["weapon"] = Equipment.make("huuma_blaze", 0)
	p.recompute()
	print("EVODUP huuma on=", p.huuma_on(), " el=", p.huuma_element(), " dual=", p.equipment.dual_ok())
	var strike_at: = e.position
	for id in ["throw_huuma_x", "kunai_splash", "moonlight_fantasy", "huuma_storm", "killing_strike", "kunai_explosion"]:
		var was: float = e.hp
		p.hp = p.max_hp
		print("EVODUP ninja ", id, " cast=", Skills.cast(world, p, id, 5))
		await get_tree().create_timer(0.26 if id == "killing_strike" else 0.55, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, id])
		await get_tree().create_timer(0.8, true, false, true).timeout
		print("EVODUP ninja ", id, " dealt=", was - e.hp)
	for id in ["throw_shuriken", "flaming_petals", "mirror_image", "shuriken_training"]:
		p.skills[id] = {"level": 2, "cd": 0.0}
	print("EVODUP order pick=", AutoPick.choose([{"kind": "skill", "id": "mirror_image", "rarity": 0}, {"kind": "skill", "id": "flaming_petals", "rarity": 3}], ["mirror_image"]).id)
	var s0: float = p.eff_stat("str")
	p.skills["ninja_aura_x"] = {"level": 1, "cd": 0.0}
	p.recompute()
	print("EVODUP aura str ", s0, " -> ", p.eff_stat("str"), " int ", p.eff_stat("int"), " agi ", p.eff_stat("agi"))
	p.skills.erase("ninja_aura_x")
	p.recompute()
	var bug: Enemy = world.spawn_enemy("thief_bug_male", p.position + Vector3(-3, 0, 2), true)
	print("EVODUP bug boss=", bug.is_boss, " hp=", bug.max_hp, " dead=", bug.dead, " look=", RoAssets.has_sprite("thief_bug_male"))
	var mvp: Enemy = world.spawn_enemy("osiris", p.position + Vector3(3, 0, 0), true)
	mvp.max_hp = 1000000000.0
	mvp.hp = 1000000000.0
	world.boss = mvp
	StatusMarks.set_mark(mvp, "poison", 7, 20)
	StatusMarks.set_mark(mvp, "burn", 4, 6)
	StatusMarks.set_mark(mvp, "bleed", 3, 5)
	mvp.lex_until = world.time + 50.0
	mvp.slow_time = 50.0
	mvp.kunai_stuck = 8
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/bossmarks.png" % dir)
	p.job2 = {"id": "kagerou", "name": "Kagerou"}
	p.charms = ["fire", "fire", "fire"]
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/charms.png" % dir)
	world.menus.show_pick_order()
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/order.png" % dir)
	world.menus.close()
	world.menus.auto_pick = false
	Save.set_setting("hold_levels", true)
	var kinds: Array[Dictionary] = []
	for kid in ["flaming_petals", "cross_slash", "throw_shuriken"]:
		kinds.append({"kind": "skill", "id": kid, "level": 2, "rarity": 1})
	world.menus.show_level_up(kinds)
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/levelup.png" % dir)
	world.menus.close()
	get_tree().paused = false
	p.equipment.slots["weapon"] = Equipment.make("huuma_blaze", 0)
	world.menus.close()
	world.menus.show_equipment("shield")
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/equip.png" % dir)
	world.menus.close()
	for id in ["increase_agi", "blessing", "edp", "assassin_cross_sunset", "poem_of_bragi", "chemical_protection"]:
		p.skills[id] = {"level": 1, "cd": 0.0}
		print("EVODUP plag cast ", id, " ", Skills.cast(world, p, id, 1))
		p.skills.erase(id)
	print("EVODUP plag pairs ", GameData.plagiarism_pairs().size())
	p.skills["venom_splasher"] = {"level": 5, "cd": 0.0}
	p.recompute()
	print("EVODUP splasher ", p.effects.get("poison_dmg"), " ", p.effects.get("bleed_dmg"), " ", p.effects.get("burn_power"))
	p.skills.erase("venom_splasher")
	p.recompute()
	print("EVODUP meter ", world.meter_label("bleed:cross_slash_x"), " | ", world.meter_label("poison:envenom"), " | ", world.meter_label("burn:fire_bolt"), " | ", world.meter_label("bleed"))
	p.profile["plagiarism_any"] = ["auto_guard"]
	print("EVODUP plag pool ", p.passive_pool().has("auto_guard"), " copied=", p.is_plagiarized("auto_guard"), " skills=", p.skill_pool().has("auto_guard"), " req=", world.menus._skill_desc("auto_guard"))
	p.profile["plagiarism_any"] = []
	world.menus.close()
	Save.add_plagiarism("blessing")
	Save.set_plagiarism_pick("blessing")
	world.menus._run_class = "acolyte"
	world.menus.show_prep("prontera")
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/prep.png" % dir)
	world.menus.close()
	var t0: = Time.get_ticks_msec()
	world.menus.show_album()
	print("EVODUP album open ms=", Time.get_ticks_msec() - t0)
	world.menus._album_tab = "gear"
	world.menus.show_album()
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/album.png" % dir)
	world.menus._gear_tab = "unique"
	world.menus.show_album()
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/album2.png" % dir)
	world.menus._album_tab = "cards"
	world.menus.close()
	p = world.player
	world.tower = TowerRun.new(world, 100)
	var lord: Enemy = world.spawn_enemy(GameData.TOWER_LORD, p.position + Vector3(3, 0, 0), true)
	lord.hp = 1.0
	world.boss = lord
	var before: = world.pickups.size()
	world.damage_enemy(lord, 1000000000.0)
	await get_tree().create_timer(0.3, true, false, true).timeout
	print("EVODUP treasure chests ", world.pickups.filter( func(q): return q.kind == "chest" and q.has("treasure")).size(), " uniques ", world.pickups.filter( func(q): return q.kind == "chest" and q.has("unique")).size(), " from ", before)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/treasure.png" % dir)
	p.equipment.receive(Equipment.make(GameData.TOWER_WINGS, 0))
	p.recompute()
	p._build_visual()
	print("EVODUP wings slot ", p.equipment.slots.wings != null, " count=", p.extra_count, " dmg=", p.dmg_mult)
	world.menus.show_equipment("wings")
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/wings_eq.png" % dir)
	world.menus.close()
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/wings_hero.png" % dir)
	p.equipment.chest_legend = 1.0
	var legends: = 0
	for i in 5:
		if Equipment.is_legendary(p.equipment.roll_item(5.0, 3)):
			legends += 1
	p.equipment.chest_legend = 0.0
	print("EVODUP treasure legends ", legends, " of 5")
	world.start_run("ninja")
	await get_tree().create_timer(0.5, true, false, true).timeout
	_tower_100()
	await get_tree().create_timer(2.0, true, false, true).timeout
	GameData.set_meta("tour_god", true)
	for i in 40:
		if world.raid.state == "portal":
			break
		await get_tree().create_timer(0.25, true, false, true).timeout
	world.raid._enter()
	for i in 40:
		await get_tree().create_timer(0.25, true, false, true).timeout
		if world.raid.state == "fight":
			break
	print("EVODUP raid state ", world.raid.state, " boss ", world.raid.boss != null)
	_next_phase()
	await get_tree().create_timer(4.0, true, false, true).timeout
	world.raid._timers["inferno"] = 0.0
	await get_tree().create_timer(1.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/naght.png" % dir)
	print("EVODUP brand ", world.raid._objects.filter( func(o): return str(o.kind) == "brand").size())
	world.raid._timers["starfall"] = 0.0
	await get_tree().create_timer(3.0, true, false, true).timeout
	print("EVODUP starfall objects ", world.raid._objects.filter( func(o): return str(o.kind) == "starfall").size())
	world.raid.to_center()
	print("EVODUP center ", world.raid._flat(world.raid.boss.position, world.raid.center))
	await get_tree().create_timer(4.0, true, false, true).timeout
	print("EVODUP phase ", world.raid.phase, " god ", GameData.has_meta("tour_god"))
	print("EVODUP tower100 floor=", world.tower.floor if world.tower != null else -1, " state=", world.tower.state if world.tower != null else "", " boss=", world.boss.id if world.boss != null else "-", " raid=", world.raid.active())
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/tower100.png" % dir)
	var seen: = 0
	for i in 25:
		TownCrowd._baby_gap = 0
		world.enter_town("ninja")
		await get_tree().create_timer(0.1, true, false, true).timeout
		if is_instance_valid(world.town) and world.town._crowd._people.any( func(q): return q.role == "baby"):
			seen += 1
	print("EVODUP babies ", seen, " of 25")
	GameData.set_meta("force_baby", true)
	world.enter_town("ninja")
	await get_tree().create_timer(5.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/baby.png" % dir)
	get_tree().quit()
	return
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/job.png" % dir)




func _evodup_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	world.menus.auto_pick = true
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	get_tree().paused = false
	print("EVODUP upgrades ", GameData.UPGRADES.kafra_summon.name, " ", GameData.UPGRADE_EFFECTS)
	print("EVODUP spirit ", GameData.skill_value("spirit_of_life", "summon_count", 5), " ", GameData.skill_value("spirit_of_life", "summon_count", 7))
	p.skills["provoke_x"] = {"level": 10, "cd": 0.0}
	p.add_skill("provoke")
	print("EVODUP added level=%d base=%s" % [p.skills.provoke_x.level, p.skills.has("provoke")])
	p.skills["provoke"] = {"level": 5, "cd": 0.0}
	p.recompute()

	var e: Enemy = world.spawn_enemy("poring", p.position + Vector3(1.5, 0, 0), true)
	e.max_hp = 1000000000.0
	e.hp = 1000000000.0
	p.skills["endure_x"] = {"level": 1, "cd": 0.0}
	print("EVODUP endure cast=", Skills.cast(world, p, "endure_x", 1), " shield=", p.shield, " x=", p.shield_x())
	var hurt: = p.shield * 0.6
	for i in 3:
		p._invuln = 0.0
		p.take_damage(hurt, world, e, false)
	print("EVODUP after shield=", p.shield, " stored=", p._shield_stored, " dealt=", 1000000000.0 - e.hp, " hp=", p.hp)
	for id in ["scar_of_tarou_x", "arclouse_dash_x", "lunatic_carrot_beat_x", "silvervine_stem_spear_x", "silvervine_root_twist_x", "bunch_of_shrimp_x", "picky_peck_x"]:
		e.position = p.position + Vector3(4, 0, 0)
		await get_tree().create_timer(0.1, true, false, true).timeout
		var was: float = e.hp
		print("EVODUP doram ", id, " cast=", Skills.cast(world, p, id, 1), " evolves_from=", GameData.EVOLUTIONS.has(id.trim_suffix("_x")))
		await get_tree().create_timer(0.7, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [OS.get_cmdline_user_args()[-1], id])
		await get_tree().create_timer(1.5, true, false, true).timeout
		print("EVODUP doram ", id, " dealt=", was - e.hp)
	world.summons.plant(world, p, Uniques.BONE_SK, 1, 2, 20.0, 2.0, 3.0, p.position + Vector3(-2, 0, 0))
	world.summons.plant(world, p, GameData.SKILLS.bio_cannibalize, 5, 2, 20.0, 4.0, 3.0)
	await get_tree().create_timer(1.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/plants.png" % OS.get_cmdline_user_args()[-1])
	for id in GameData.SHIELD_X:
		p.shield = 0.0
		var cast: bool = Skills.cast(world, p, str(id), 1)
		var has: = not p.shield_x().is_empty()
		p.shield = 1.0
		p._invuln = 0.0
		p.hp = p.max_hp * 0.5
		p.take_damage(50.0, world, e, false)
		p._invuln = 0.0
		print("EVODUP ", id, " cast=", cast, " x=", has, " hp=", p.hp, "/", p.max_hp, " evolves_from=", GameData.EVOLUTIONS.has(str(id).trim_suffix("_x")))
	print("EVODUP saved base=%s offered=%s" % [p.skills.has("provoke"), p._choice_pool().filter( func(o): return str(o.id).begins_with("provoke")).map( func(o): return o.id)])
	await _evodup_ninja()
	get_tree().quit()




func _orbit_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var f = load("res://scripts/ro/rebirth_flair.gd").new()
	f.looks = ["orbs", "biolab"]
	world.player.add_child(f)
	for i in 12:
		await get_tree().create_timer(0.25, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/orbit_%d.png" % [dir, i])
	get_tree().quit()



func _towerhud_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.level = 60
	p.recompute()
	for i in 5:
		Save.add_tower_build(RunSave.hero_snapshot(world))
	world.abandon_run()
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.menus.show_tower()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/towerhud.png" % dir)
	world.menus.show_tower_camp(10, "", func(): pass)
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/camp_claimed.png" % dir)
	world.enter_town("archer", "prontera")
	await get_tree().create_timer(3.0, true, false, true).timeout
	world.menus.show_kafra_talk()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/kafra.png" % dir)
	get_tree().quit()




func _towerbuff_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.player.job_change(0)
	world.player.level = 60
	world.player.recompute()
	Save.add_tower_build(RunSave.hero_snapshot(world))
	world.abandon_run()
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.start_tower(Save.tower_builds().size() - 1, 1)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.tower.floor = 31
	world.player.pending_levels = 0
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.6, true, false, true).timeout
	print("TOWERBUFF mult=%.3f row=%s" % [world.tower.hero_mult(), str(world.hud._buffs_now())])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/towerbuff_row.png" % dir)
	world.menus.show_equipment()
	await get_tree().create_timer(0.3, true, false, true).timeout
	for b in world.menus.find_children("*", "Button", true, false):
		if (b as Button).text.begins_with("Ver detalles"):
			(b as Button).pressed.emit()
			break
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/towerbuff_sheet.png" % dir)
	get_tree().quit()





func _festbuff_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.player.job_change(0)
	world.player.hel_marks = 31
	world.player.feathers = 24
	Save.add_tower_build(RunSave.hero_snapshot(world))
	var idx: = Save.tower_builds().size() - 1
	world.abandon_run()
	await get_tree().create_timer(0.5, true, false, true).timeout
	for attempt in 3:
		world.start_festival(idx)
		await get_tree().create_timer(0.8, true, false, true).timeout
		var drawn: = 0
		for c in world.hud._pact_row.get_children():
			if not c.is_queued_for_deletion():
				drawn += 1
		print("FESTBUFF attempt %d marks=%d feathers=%d drawn=%d sig_has_mark=%s" % [attempt, world.player.hel_marks, world.player.feathers, drawn, 
			str("hel_mark" in world.hud._buff_sig)])
	Save.take_tower_build(idx)
	get_tree().quit()





func _trainreset_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus._start_training("swordsman")
	await get_tree().create_timer(4.0, true, false, true).timeout
	world.menus.close()
	get_tree().paused = false
	world.training_levels(10)
	world.player.pending_levels = 0
	world.training_dummies(1)
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/train_panel.png" % dir)
	for what in ["pacts", "dishes", "album", "gear"]:
		world.menus.show_training_setup(what)
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/train_%s.png" % [dir, what])
		world.menus._back_to_hub()
		await get_tree().create_timer(0.3, true, false, true).timeout
		print("TRAINRESET %s closed: mode=%s paused=%s running=%s" % [what, world.menus._mode, get_tree().paused, world.running])
	print("TRAINRESET before level=%d dummies=%d" % [world.player.level, world.enemies.filter( func(e): return is_instance_valid(e) and e.id == "training_dummy").size()])
	var panel = world.hud.find_children("*", "TrainingPanel", true, false)
	var tp: TrainingPanel = panel[0] if not panel.is_empty() else null
	if tp == null:
		for n in world.find_children("*", "", true, false):
			if n is TrainingPanel:
				tp = n
				break
	tp._restart()
	print("TRAINRESET armed text=%s running=%s" % [tp._restart_btn.text if is_instance_valid(tp._restart_btn) else "?", world.running])
	tp._restart()
	await get_tree().create_timer(4.0, true, false, true).timeout
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.5, true, false, true).timeout
	print("TRAINRESET after level=%d running=%s training=%s dummies=%d" % [world.player.level, world.running, world.training, 
		world.enemies.filter( func(e): return is_instance_valid(e) and e.id == "training_dummy").size()])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/train_after.png" % dir)
	get_tree().quit()





func _trainsafe_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus._start_training("swordsman")
	await get_tree().create_timer(4.0, true, false, true).timeout
	world.menus.close()
	get_tree().paused = false
	world.training_dummies(1)
	world.training_dummies(1, true)
	await get_tree().create_timer(0.3, true, false, true).timeout
	var before: = [Save.zeny(), Save.coins(), Save.material("oridecon"), Save.data.cards.duplicate(), Save.stat("best_hit")]
	world.add_zeny(5000, "loot")
	world.found_coin()
	world.gain_material("oridecon", 3)
	world._take_card("poring_card", world.player.position)
	world._track_achievements()
	world._collect({"kind": "chest", "value": 3, "node": null})
	var spent: = world.spend_run_zeny(100)
	var dummies: Array = world.enemies.filter( func(e): return is_instance_valid(e) and e.def.get("dummy", false))
	for e in dummies:
		e.hurt(e.max_hp * 10.0, Vector3.ZERO)
		world._kill(e)
	await get_tree().create_timer(0.3, true, false, true).timeout
	var alive: Array = world.enemies.filter( func(e): return is_instance_valid(e) and e.def.get("dummy", false) and not e.dead)
	var mvp_boss: = alive.filter( func(e): return e.id == "training_dummy_mvp" and e.is_boss).size()
	var after: = [Save.zeny(), Save.coins(), Save.material("oridecon"), Save.data.cards.duplicate(), Save.stat("best_hit")]
	print("TRAINSAFE same=%s dummies=%d/%d mvp_boss=%d run_zeny=%d spent=%s" % [str(before == after), alive.size(), dummies.size(), mvp_boss, world.run_zeny, str(spent)])
	if before != after:
		print("TRAINSAFE before=%s after=%s" % [str(before), str(after)])


	world.training_next_element()
	world.training_next_element()
	var els: Array = world.enemies.filter( func(e): return is_instance_valid(e) and e.def.get("dummy", false)).map( func(e): return e.element())
	world.training_dummies(1, false, true)
	for i in 2:
		world.training_next_hit()
	var p: Player = world.player
	p.position = world.enemies.filter( func(e): return is_instance_valid(e) and e.has_meta("training_hitter"))[0].position + Vector3(1.0, 0, 0)
	var hp0: = p.hp
	var seen: Array = []
	for i in 30:
		await get_tree().create_timer(0.2, true, false, true).timeout
		seen.append(int(p.hp))
	print("TRAINHIT hp over time=%s" % str(seen))
	print("TRAINHIT element=%s els=%s hit=%d hp0=%d hp=%d max=%d fell=%s running=%s taken=%d" % [world.training_element, str(els), int(world.training_hit), 
		int(hp0), int(p.hp), int(p.max_hp), str(p.fell), str(world.running), int(world.meter_stats.get("taken", 0.0))])
	get_tree().quit()




func _seek_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	var e: Enemy = world.spawn_enemy("poring", p.position + Vector3(4, 0, 0), true)
	e.max_hp = 1000000000000.0
	e.hp = e.max_hp
	world.spawn_projectile({"pos": e.position + Vector3(1, 0.5, 0), "dir": Vector3.LEFT, "speed": 20.0, "damage": 1.0, "pierce": 0, "delay": 0.0, 
		"size": 0.22, "color": Color.WHITE, "slow": 0.0, "knock": 0.0, "arrow": true, "hit_fx": "", "basic": true, "tag": "basic", "bounces": 3, "seek": e})
	var q: Dictionary = world.projectiles[-1]
	q.hit[e] = true
	q.life = 0.4
	await get_tree().create_timer(2.5, true, false, true).timeout
	print("SEEK left=", world.projectiles.filter( func(x): return x.has("seek") and x.get("seek") == e).size(), " alive=", is_instance_valid(e) and not e.dead)
	get_tree().quit()




func _potion_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	for i in 60:
		world._drop_item(p.position + Vector3(4.0 + randf() * 8.0, 0, -6.0 + randf() * 10.0), "potion", "")
	for i in 5:
		await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/potion_0.png" % dir)
	await get_tree().create_timer(1.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/potion_1.png" % dir)
	var kinds: = {}
	for q in world.pickups:
		if q.kind == "potion":
			kinds["%s x%d pull=%s" % [q.spr, q.value, q.pull]] = int(kinds.get("%s x%d pull=%s" % [q.spr, q.value, q.pull], 0)) + 1
	print("POTIONS ", kinds)
	await get_tree().create_timer(1.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/potion_2.png" % dir)
	print("POTIONS left=", world.pickups.filter( func(q): return q.kind == "potion").size(), " hp=", p.hp, "/", p.max_hp)
	get_tree().quit()




func _critnum_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.data.rebirths["archer"] = 1
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	var gold: = Color(1, 0.85, 0.3)
	for a in [[-5.0, false, false, true], [-2.5, true, false, false], [0.0, true, true, false], [2.5, true, false, true], [5.0, true, true, true]]:
		world.number(p.position + Vector3(a[0], 1.5, -4.0), "123456", gold, true, a[1], a[2], 1.2, false, a[3])
	for i in 3:
		await get_tree().create_timer(0.14, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/critnum_%d.png" % [dir, i])
	await get_tree().create_timer(1.5, true, false, true).timeout
	var prey: = Node3D.new()
	world.fx_root.add_child(prey)
	prey.position = p.position + Vector3(3.0, 0, -2.5)

	Engine.time_scale = 0.12
	world.falcon_strike(p, [prey], 1.0, 2.0, GameData.SKILLS.falcon_assault_x)
	for i in 16:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/dive_%d.png" % [dir, i])
	get_tree().quit()


func _falcon_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout

	if "--reborn" in OS.get_cmdline_user_args():
		Save.data.rebirths["archer"] = 1
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.job_change(0)
	for i in 4:
		p.visual.face(Vector3(sin(i * PI / 2.0), 0, cos(i * PI / 2.0)))
		await get_tree().create_timer(0.7, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/falcon_%d.png" % [dir, i])
	get_tree().quit()




func _clownpick_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.data.rebirths["archer"] = 1
	world.start_run("archer")
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.show_job_change()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/clown_change.png" % dir)
	world.menus._grace = 0.0
	world.do_job_change(1)
	await get_tree().create_timer(1.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/clown_pick.png" % dir)
	print("CLOWN options=", world.menus._choices)
	get_tree().quit()





func _startpick_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	for c in ["taekwon", "ninja", "mage"]:
		world.start_run(c)
		await get_tree().create_timer(0.6, true, false, true).timeout
		var p: Player = world.player
		world.menus.show_start_skill(p.start_options(), func(id: String):
			p.set_start_skill(id), "", "", "", p.start_passive_options())
		await get_tree().create_timer(1.2, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/start_%s.png" % [dir, c])

		world.menus._grace = 0.0
		world.menus._pick_start(p.start_options().size())
		await get_tree().create_timer(0.6, true, false, true).timeout
		print("STARTPICK %s skills=%s" % [c, p.skills.keys()])
	world.start_run("acolyte")
	await get_tree().create_timer(0.6, true, false, true).timeout
	world.menus.close()
	get_tree().paused = false
	world.do_job_change(1)
	await get_tree().create_timer(1.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/job_monk.png" % dir)
	world.menus._grace = 0.0
	world.menus._pick_start(world.player.job_start_options().size() + 1)
	await get_tree().create_timer(0.6, true, false, true).timeout
	print("STARTPICK monk skills=%s" % [world.player.skills.keys()])
	get_tree().quit()




func _statmax_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.6, true, false, true).timeout
	var p: Player = world.player
	p.stats.dex = 40
	p.stats.agi = 50
	p.stats.luk = 30
	p.recompute()
	world.menus.show_level_up([{"kind": "stat", "id": "dex", "level": 41, "from": 40, "rarity": 0, "w": 1.0}, 
		{"kind": "stat", "id": "agi", "level": 51, "from": 50, "rarity": 0, "w": 1.0}, 
		{"kind": "stat", "id": "luk", "level": 31, "from": 30, "rarity": 0, "w": 1.0}])
	await get_tree().create_timer(1.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/statmax.png" % dir)
	print("STATMAX move=%.2f proj=%.2f dodge=%.2f pd=%.2f" % [p.move_speed, p.proj_mult, p.dodge, p.perfect_dodge])
	get_tree().quit()




func _banish_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(0.6, true, false, true).timeout
	world.player.banishes = 2
	world.menus.auto_pick = false
	world.menus.show_level_up(world.player.build_choices())
	await get_tree().create_timer(1.0, true, false, true).timeout
	var before: Array = world.menus._choices.duplicate()
	world.menus._banish(before[1])
	await get_tree().create_timer(0.5, true, false, true).timeout
	var after: Array = world.menus._choices
	print("BANISH before=%s" % [before.map( func(o): return "%s:%s" % [o.kind, o.id])])
	print("BANISH after =%s same0=%s same2=%s changed1=%s" % [after.map( func(o): return "%s:%s" % [o.kind, o.id]), 
		after[0] == before[0], after[2] == before[2], after[1] != before[1]])
	get_tree().quit()




func _stone_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("thief")
	world.menus.close()
	get_tree().paused = false
	world.player.max_hp = 99999.0
	world.player.hp = 99999.0
	for id in ["envenom_x", "throw_stone", "throw_stone_x", "throw_huuma_x", "freezing_spear_x", "charge_arrow_x"]:
		for e in world.enemies:
			e.queue_free()
		world.enemies.clear()
		for i in 8:
			var a: = TAU * i / 8.0
			var e: Enemy = world.spawn_enemy("poring", world.player.position + Vector3(cos(a) * 3.5 + 1.5, 0, sin(a) * 2.5), true)
			if e != null:
				e.max_hp = 99999.0
				e.hp = 99999.0
				e.speed = 0.0
		await get_tree().create_timer(0.3, true, false, true).timeout
		world.player.skills.clear()
		world.player.skills[id] = {"level": 5, "cd": 999.0}
		Skills.cast(world, world.player, id, 5)
		for k in 3:
			await get_tree().create_timer(0.12, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [dir, id, k])
		await get_tree().create_timer(0.8, true, false, true).timeout
	print("STONETEST stunned=", world.smoke_stats.get("status", 0))
	get_tree().quit()




func _goldbox_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(0.6, true, false, true).timeout
	var p: Player = world.player
	world._drop_chest(p.position + Vector3(4.0, 0, 0), GameData.CHEST_ROLLS.golden_poring, 3)
	world._drop_chest(p.position + Vector3(-4.0, 0, 0), GameData.CHEST_ROLLS.boss, 2)
	await get_tree().create_timer(1.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/goldbox_ground.png" % dir)
	p.position += Vector3(4.0, 0, 0)
	await get_tree().create_timer(1.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/goldbox_open.png" % dir)
	get_tree().quit()




func _claim_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var ids: Array = GameData.ACHIEVEMENTS.keys().slice(0, 6)
	for id in ids:
		Save.complete_achievement(id)
	var shot: = func(n: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, n])
	world.menus.show_class_select()
	await wait.call(0.8)
	await shot.call("0_select")
	world.menus._album_tab = "cards"
	world.menus.show_album()
	await wait.call(0.6)
	await shot.call("1_album_cards")
	world.menus._album_tab = "ach"
	world.menus.show_album()
	await wait.call(0.6)
	await shot.call("2_ach")
	var c0: = Save.coins()
	world.menus._claim_achievement(ids[0])
	await wait.call(0.15)
	await shot.call("3_claim_one")
	world.menus._claim_all_achievements()
	await wait.call(0.15)
	await shot.call("4_claim_all_mid")
	await wait.call(0.8)
	await shot.call("5_claim_all_done")
	print("CLAIMTEST coins %d -> %d unclaimed=%d" % [c0, Save.coins(), Save.unclaimed_achievements().size()])
	get_tree().quit()




func _options_test(dir: String) -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	var m: Menus = world.menus
	m.show_options()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/options.png" % dir)
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])

	world.toggle_fullscreen()
	await get_tree().create_timer(1.0, true, false, true).timeout
	print("OPT fullscreen on: mode=%d" % DisplayServer.window_get_mode())
	await shot.call("options_full")
	world.toggle_fullscreen()
	await get_tree().create_timer(1.0, true, false, true).timeout
	print("OPT fullscreen off: mode=%d" % DisplayServer.window_get_mode())
	Save.set_setting("vsync", false)
	Save.set_setting("max_fps", 30)
	Save.set_setting("show_fps", true)
	world.apply_video_settings()
	await get_tree().create_timer(2.0, true, false, true).timeout
	print("OPT vsync=%d max_fps=%d fps=%d label=%s" % [DisplayServer.window_get_vsync_mode(), Engine.max_fps, 
		Engine.get_frames_per_second(), world._fps_label.text if world._fps_label != null else "-"])
	Save.set_setting("master", 0.5)
	Save.set_setting("mute_unfocused", true)
	world.apply_audio_settings()
	var mi: = AudioServer.get_bus_index("Master")
	print("OPT master_db=%.1f muted=%s" % [AudioServer.get_bus_volume_db(mi), AudioServer.is_bus_mute(mi)])
	world._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	print("OPT unfocused muted=%s" % AudioServer.is_bus_mute(mi))
	world._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	print("OPT focused muted=%s" % AudioServer.is_bus_mute(mi))
	m.close_options()
	world.start_run("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	Save.set_setting("damage_numbers", false)
	Save.set_setting("screen_shake", false)
	var n = world.number(world.player.position, "123", Color.WHITE)
	var t = world.number(world.player.position, "Miss", Color.WHITE)
	world.shake(1.0)
	print("OPT damage number hidden=%s other text shown=%s shake=%.1f" % [n == null, t != null, world._shake])
	Save.set_setting("damage_numbers", true)
	Save.set_setting("screen_shake", true)
	Save.set_setting("show_fps", false)
	Save.set_setting("max_fps", 0)
	Save.set_setting("vsync", true)
	world.apply_video_settings()
	await get_tree().create_timer(0.5, true, false, true).timeout
	print("OPT reset label=%s max_fps=%d" % [world._fps_label != null, Engine.max_fps])
	get_tree().quit()




func _banishstat_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(0.6, true, false, true).timeout
	var p: Player = world.player
	p.banish({"kind": "stat", "id": "dex", "level": 1})
	var seen: = 0
	for i in 400:
		for o in p.build_choices():
			if o.kind == "stat" and o.id == "dex":
				seen += 1
	print("BANISHSTAT dex seen=%d banished=%s" % [seen, p.banished])
	get_tree().quit()




func _prochit_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = 99999.0
	p.album_cards.clear()
	for c in GameData.CARDS:
		if GameData.CARDS[c].has("proc_hit"):
			p.album_cards.append(str(c))
	p.recompute()
	p.max_hp = 99999.0
	p.hp = 99999.0
	var e: Enemy = world.spawn_enemy("poring", p.position + Vector3(2, 0, 0), true)
	e.max_hp = 99999.0
	e.hp = 99999.0
	e.speed = 0.0
	var casts: = {}
	for i in 400:
		p._invuln = 0.0
		p.dodge = 0.0
		p.perfect_dodge = 0.0
		var before: = p._proc_hit_cd.duplicate()
		p.take_damage(5.0, world, e)
		for k in p._proc_hit_cd:
			if float(p._proc_hit_cd[k]) != float(before.get(k, -1.0)):
				casts[k] = int(casts.get(k, 0)) + 1
		if i % 100 == 50:
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/hit_%d.png" % [dir, i])
		await get_tree().create_timer(0.03, true, false, true).timeout
	print("PROCHIT cards=%d casts=%s" % [p.procs_hit.size(), casts])
	get_tree().quit()





func _batch21_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	print("BATCH danger range prontera=%s geffen=%s" % [GameData.stage_danger_range("prontera", 1), GameData.stage_danger_range("orc", 1)])

	world.start_run("gunslinger")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	for k in 5:
		p.add_skill("coin_flip")
	p.recompute()
	for i in 6:
		p.gain_coin(world, 1.0)
	await get_tree().create_timer(0.8, true, false, true).timeout
	await shot.call("coins")

	world.altars.spawn("odin", p.position + Vector3(4, 0, 0))
	world.altars.spawn("hypnotist", p.position + Vector3(-12, 0, 3))
	await get_tree().create_timer(1.5, true, false, true).timeout
	await shot.call("altar_hypno")

	Save.set_setting("hold_levels", true)
	p.pending_levels = 3
	await get_tree().create_timer(0.8, true, false, true).timeout
	print("BATCH held: mode=%s pending=%d" % [world.menus.mode(), p.pending_levels])
	await shot.call("held_button")
	world.open_held_levels()
	await get_tree().create_timer(0.8, true, false, true).timeout
	print("BATCH opened: mode=%s" % world.menus.mode())
	world.menus.hide_level_up()
	get_tree().paused = false
	p.pending_levels = 0
	Save.set_setting("hold_levels", false)
	world.menus.show_pause()
	await get_tree().create_timer(0.6, true, false, true).timeout
	await shot.call("pause")
	world.menus._resume()
	await get_tree().create_timer(0.3, true, false, true).timeout
	for pet_id in ["poring", "smokie", "isis"]:
		world.menus.show_taming(pet_id, true, func(): pass)
		await get_tree().create_timer(3.2, true, false, true).timeout
		await shot.call("taming_" + pet_id)
		await get_tree().create_timer(2.0, true, false, true).timeout
	await get_tree().create_timer(2.0, true, false, true).timeout

	world.menus.show_job_change()
	await get_tree().create_timer(0.2, true, false, true).timeout
	world.menus.close()
	get_tree().paused = false
	var pal: = RoAssets.cloth_palette("priest", 4)
	print("BATCH priest dye4 palette=%s" % pal)
	get_tree().quit()





func _dual_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	world.start_run("thief")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.job_change(0)
	var eq: = p.equipment
	print("DUAL assassin katar: dual_ok=%s weapon=%s" % [eq.dual_ok(), eq.slots.weapon.id])
	eq.bag.append(Equipment.make("stiletto", 1))
	eq.equip_from_bag(eq.bag.size() - 1, "weapon")
	eq.bag.append(Equipment.make("damascus", 2))
	eq.equip_from_bag(eq.bag.size() - 1)
	for k in 5:
		p.add_skill("left_hand_mastery")
	p.recompute()
	print("DUAL daggers: dual_ok=%s right=%s left=%s share=%.2f view=%s" % [eq.dual_ok(), eq.slots.weapon.id, 
		eq.offhand().get("id", "-"), eq.offhand_share, p.weapon_view()])
	for i in 6:
		var e: = world.spawn_enemy("poring", p.position + Vector3(1.2, 0, 0.3 * i), true, false)
		if e != null:
			e.max_hp = 1000000.0
			e.hp = e.max_hp
			e.speed = 0.2
	await get_tree().create_timer(2.0, true, false, true).timeout
	await shot.call("assassin_dual")
	world.menus.show_equipment("shield")
	await get_tree().create_timer(0.6, true, false, true).timeout
	await shot.call("assassin_equip")
	world.menus.close()
	get_tree().paused = false

	eq.bag.append(Equipment.make("jur", 1))
	eq.equip_from_bag(eq.bag.size() - 1, "weapon")
	p.recompute()
	print("DUAL katar again: dual_ok=%s left=%s bag_has_damascus=%s view=%s" % [eq.dual_ok(), eq.offhand().get("id", "-"), 
		eq.bag.any( func(it): return it.id == "damascus"), p.weapon_view()])

	world.start_run("ninja")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var n: Player = world.player
	n.job_change(0)
	var r: = n.equipment.receive(Equipment.make("kagekiri", 1))
	n.recompute()
	print("DUAL kagerou receive: result=%s slot=%s left=%s" % [r.result, r.slot, n.equipment.offhand().get("id", "-")])
	get_tree().quit()




func _broadcast_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var b = world.get_children().filter( func(n): return n.get_script() == preload("res://scripts/ui/broadcast.gd"))[0]
	b.set_process(true)
	b.say(tr("[Aviso] Hay una actualización nueva (v%s). Por favor reinicia el juego para instalarla.") % "0.1.110")
	b.say("[GM] Servidor de prueba: ¡gracias por jugar!")
	for i in 3:
		await get_tree().create_timer(1.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/bc_%d.png" % [dir, i])
	get_tree().quit()




func _runopts_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.use_power("berserk_potion")
	await get_tree().create_timer(0.5, true, false, true).timeout
	await shot.call("1_berserk")
	world.menus.show_pause()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await shot.call("2_pause")
	world.menus.show_options()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await shot.call("3_options")
	world.menus.close_options()
	await get_tree().create_timer(0.5, true, false, true).timeout
	await shot.call("4_closed")
	get_tree().quit()




func _job_show_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("acolyte")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = p.max_hp
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		img.get_region(Rect2i(img.get_width() / 2 - 260, img.get_height() / 2 - 300, 520, 440)).save_png("%s/%s.png" % [dir, name])
	p.job_change(0)
	world.job_change_show(p)
	for k in 4:
		await get_tree().create_timer(0.25, true, false, true).timeout
		await shot.call("job_%d" % k)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Skills.cast(world, p, "increase_agi", 3)
	await get_tree().create_timer(0.3, true, false, true).timeout
	await shot.call("agi")
	p.shield = 0.0
	Skills.cast(world, p, "assumptio", 3)
	await get_tree().create_timer(0.4, true, false, true).timeout
	await shot.call("assumptio")
	await get_tree().create_timer(1.0, true, false, true).timeout
	p.hp = p.max_hp * 0.4
	Skills.cast(world, p, "heal", 5)
	await get_tree().create_timer(0.15, true, false, true).timeout
	await shot.call("heal")
	await get_tree().create_timer(0.3, true, false, true).timeout
	await shot.call("heal_b")
	await get_tree().create_timer(2.5, true, false, true).timeout
	await shot.call("glow")
	get_tree().quit()





func _eos_quit_test() -> void :
	await get_tree().create_timer(1.0, true, false, true).timeout
	var eos: Node = world.net.eos()
	print("EOSQUIT setup=", await eos.setup_async())
	await get_tree().create_timer(2.0, true, false, true).timeout
	print("EOSQUIT closing")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()




func _coins_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("gunslinger")
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.player.coins = 5
	world.get_tree().paused = false
	for k in 6:
		await get_tree().create_timer(0.35, true, false, true).timeout
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		img.get_region(Rect2i(img.get_width() / 2 - 120, img.get_height() / 2 - 170, 240, 240)).save_png("%s/coins_%d.png" % [dir, k])
	get_tree().quit()





func _cleave_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.skills.clear()
	p.base_stats["agi"] = int(p.base_stats.get("agi", 0)) + 10
	p.recompute()
	var mobs: Array = []
	for i in 16:
		var a: = TAU * i / 16.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * (1.5 + 3.5 * float(i % 4) / 3.0), true, false)
		if e != null:
			e.max_hp = 10000000.0
			e.hp = e.max_hp
			e.speed = 0.0
			mobs.append(e)
	p._attack_timer = 99.0
	await get_tree().create_timer(0.3, true, false, true).timeout
	for e in mobs:
		e.hp = e.max_hp
	p._attack_timer = 0.0
	p._basic_attack(0.0, world)
	var hit: = mobs.filter( func(e): return e.hp < e.max_hp).size()
	print("CLEAVE agi_extra=%d hit=%d of %d" % [p.agi_extra(), hit, mobs.size()])
	get_tree().quit()




func _lethal_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.set_upgrade_level("telescope", 3)
	world.start_run("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.skills.clear()
	p.recompute()
	p.crit = 1.0
	p.crit_dmg = 5.5
	p.ultra_crit = true
	print("LETHAL meta reach=", p.meta.get("reach", 0.0))
	for i in 24:
		var a: = TAU * i / 24.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * (1.5 + float(i % 3)), true, false)
		if e != null:
			e.max_hp = 10000000.0
			e.hp = e.max_hp
			e.speed = 0.0
	for k in 8:
		await get_tree().create_timer(0.25, true, false, true).timeout
		p.crit = 1.0
		p.crit_dmg = 5.5
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/l_%d.png" % [dir, k])
	print("LETHAL count=", world.smoke_stats.get("lethal", 0))
	get_tree().quit()




func _combo_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.skills.clear()
	p.recompute()
	p._attack_timer = 999.0
	print("COMBO frost: ", world.menus._skill_desc("frost_diver"))
	print("COMBO jupitel: ", world.menus._skill_desc("jupitel_thunder"))
	print("COMBO fire: ", world.menus._skill_desc("fire_bolt"))
	var mobs: Array = []
	for i in 4:
		var e: = world.spawn_enemy("poring", p.position + Vector3(-2.5 + i * 1.7, 0, -1.5), true, false)
		e.max_hp = 1000000.0
		e.hp = e.max_hp
		e.speed = 0.0
		world.apply_status(e, "freeze" if i < 2 else "stone", 30.0)
		mobs.append(e)
	await get_tree().create_timer(0.2, true, false, true).timeout
	for i in 4:
		world.damage_tag = "test"
		world.damage_enemy(mobs[i], 50.0, Vector3.ZERO, "skill", "wind" if i < 2 else "fire")
	await get_tree().create_timer(0.15, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/combo.png" % dir)
	print("COMBO meter test=%.0f status_combo=%.0f" % [float(world.meter.get("test", {}).get("dmg", 0.0)), float(world.meter.get("status_combo", {}).get("dmg", 0.0))])


	p.job_change(0)
	var lone: Array = []
	for i in 3:
		var m: = world.spawn_enemy("poring", p.position + Vector3(-4.0 + i * 4.0, 0, 3.0), true, false)
		m.max_hp = 10000000.0
		m.hp = m.max_hp
		m.speed = 0.0
		lone.append(m)
	var clock: = world.time
	for k in 15:
		world.time = clock
		for i in 3:
			world.damage_enemy(lone[i], 50.0, Vector3.ZERO, "skill", "earth", "quagmire")
			world.damage_enemy(lone[i], 50.0, Vector3.ZERO, "skill", ["fire", "water", "wind"][i], ["fire_bolt", "frost_diver", "jupitel_thunder"][i])
		await get_tree().create_timer(0.15, true, false, true).timeout
	print("COMBO earth clock_held=%s wiz_combo dmg=%.0f hits=%d job=%s" % [world.time == clock, float(world.meter.get("wiz_combo", {}).get("dmg", 0.0)), int(world.meter.get("wiz_combo", {}).get("hits", 0)), p.job2.get("id", "")])
	get_tree().quit()




func _unique_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])

	for look in [["swordsman", ["orc_hero_helm", "beelzebub_wing", "queen_wings", "golden_bug_shell"]], 
			["acolyte", ["maya_crown", "beelzebub_wing", "queen_wings"]], ["thief", ["bone_helm", "queen_wings"]]]:
		world.start_run(look[0])
		await get_tree().create_timer(0.5, true, false, true).timeout
		for id in look[1]:
			var it: = Equipment.make(id, 0)
			var slot: = str(Equipment.item_def(it).slot)
			world.player.equipment.slots["acc1" if slot == "acc" else slot] = it
		world.player.recompute()
		world._cam_distance = 12.0
		for k in 4:
			world.player.visual.face(Vector3(cos(TAU * k / 4.0 + 0.4), 0, sin(TAU * k / 4.0 + 0.4)))
			await get_tree().create_timer(0.4, true, false, true).timeout
			await shot.call("look_%s_%d" % [look[0], k])
		world.abandon_run()
		get_tree().paused = false
		await get_tree().create_timer(0.3, true, false, true).timeout
	world._cam_distance = 42.0
	world.start_run("merchant")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = 99999.0
	for id in ["orcish_axe", "maya_crown", "beelzebub_wing"]:
		var it: = Equipment.make(id, 0)
		var slot: = str(Equipment.item_def(it).slot)
		p.equipment.slots["acc1" if slot == "acc" else slot] = it
	p.recompute()
	for i in 30:
		var a: = TAU * i / 30.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * (2.0 + float(i % 4)), true, false)
		if e != null:
			e.max_hp = 3000.0
			e.hp = e.max_hp
	for k in 6:
		await get_tree().create_timer(1.2, true, false, true).timeout
		await shot.call("run_%d" % k)
	print("UNIQ meter: ", world.meter)

	GameData.set_meta("force_unique", true)
	world._drop_chest(p.position + Vector3(0.5, 0, 0.5), 1, 1)
	for k in 5:
		await get_tree().create_timer(0.7, true, false, true).timeout
		await shot.call("reveal_%d" % k)
	print("UNIQ storage: ", Save.storage().map( func(x): return x.id))
	world.abandon_run()
	get_tree().paused = false
	world.menus.show_server_select("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	await shot.call("maps")
	world.menus.show_loadout("swordsman")
	await get_tree().create_timer(0.8, true, false, true).timeout
	await shot.call("loadout")
	get_tree().quit()




func _meter_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	world.start_run("swordsman")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = 99999.0
	world.autopilot = true
	Engine.time_scale = 3.0
	var boss: = world.spawn_enemy("vagabond_wolf", p.position + Vector3(3, 0, 0), true, false)
	await get_tree().create_timer(12.0, true, false, true).timeout
	Engine.time_scale = 1.0
	await shot.call("hud")
	for m in ["damage", "boss", "taken", "summary"]:
		world.meter_details.open(m)
		await get_tree().create_timer(0.7, true, false, true).timeout
		await shot.call("details_" + m)
	print("METER boss=", world.meter_boss.keys(), " taken=", world.meter_taken.keys())
	print("METER short=", [DamageMeter.short(9999.0), DamageMeter.short(2500000.0), DamageMeter.short(45000000000.0), DamageMeter.short(1519215100000.0), DamageMeter.short(3.1e+15)])
	var big: = ["2450000", "45200000000", "14370000000000", "3100000000000000"]
	print("METER numbers=", big.map( func(n): return RoAssets.shown_digits(n)), " atlas=", RoAssets.glyph_atlas().rects.keys())
	for i in big.size():
		RoAssets.damage_text(big[i]).get_image().save_png("%s/number_%d.png" % [dir, i])
	get_tree().quit()




func _tank_test(dir: String, who: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var cls: = "swordsman" if who == "paladin" else "acolyte"
	Save.data.rebirths[cls] = 1
	world.start_run(cls)
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.reborn = true
	p.job_change(1)
	print("TANK job=", p.job2.get("id", ""))
	p.skills.clear()
	var kit: = ["gospel", "martyrs_reckoning", "faith", "reflect_shield", "auto_guard"] if who == "paladin" else ["steel_body", "call_spirits", "triple_attack"]
	for id in kit:
		for k in 5:
			p.add_skill(id)
	p.album_cards = ["dark_lord_card", "marine_sphere_card", "banshee_card"]
	p.base_stats["vit"] = int(p.base_stats.get("vit", 0)) + 30
	p.recompute()
	p.spheres = p.sphere_max
	p.max_hp = 99999.0
	p.hp = 99999.0
	world.autopilot = true
	for i in 40:
		var a: = TAU * i / 40.0
		var e: = world.spawn_enemy("orc_warrior" if GameData.MONSTERS.has("orc_warrior") else "poring", p.position + Vector3(cos(a), 0, sin(a)) * (2.0 + float(i % 4)), true, false)
		if e != null:
			e.max_hp = 20000.0
			e.hp = e.max_hp
	var seen: = {}
	for k in 30:
		await get_tree().create_timer(0.5, true, false, true).timeout
		p.hp = maxf(p.hp, 50000.0)
		for pw in p.powers:
			seen[pw] = true
		if k in [8, 16, 24]:
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [dir, who, k])
	print("TANK powers seen=", seen.keys(), " max_hp=", p.max_hp, " basic_atk=", p.basic_atk())
	print("TANK meter=", world.meter_sorted().map( func(r): return "%s=%d" % [r.tag, roundi(r.dmg)]))
	get_tree().quit()




func _rebirthui_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.show_rebirth("swordsman")
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/book.png" % dir)
	world.menus._rebirth_reveal("swordsman", ColorRect.new())
	await get_tree().create_timer(3.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/reveal.png" % dir)
	get_tree().quit()




func _mvphp_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	for sid in ["prontera", "payon", "juperos"]:
		for d in [1, 15, 16]:
			world.set_stage(sid)
			world.start_run("swordsman")
			Save.data["max_danger"] = GameData.DANGER_MAX
			world.danger = d
			world.time = float(world.stage.mvp_time)
			var e: = world.spawn_enemy(str(world.stage.mvp), world.player.position + Vector3(8, 0, 0), true, false)
			var hp: = e.max_hp * GameData.RAID_HP_BASE * GameData.MVP_RAID_HP
			print("MVPHP %s %s d=%d hp=%d" % [sid, world.stage.mvp, d, roundi(hp)])
			world.abandon_run()
	get_tree().quit()




func _protect_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.add_zeny(5000000)
	Save.add_material("oridecon", 200)
	Save.add_material("hd_oridecon", 200)
	Save.add_to_storage(Equipment.make("sword", 1))
	var it: Dictionary = Save.storage().back()
	it["refine"] = 7
	var m: = world.menus
	m._refine_uid = str(it.uid)
	Save.set_setting("refine_protect", true)
	for mat in ["oridecon", "hd_oridecon"]:
		m._refine_mat = mat
		var low: = int(it.refine)
		var broke: = false
		var dropped: = false
		var before: = Save.zeny()
		for i in 40:
			var lv: = int(it.refine)
			m._do_refine()
			if Save.storage_item(str(it.uid)).is_empty():
				broke = true
				break
			if int(it.refine) < lv:
				dropped = true
		print("PROTECT %s: refine %d -> %d broke=%s dropped=%s zeny spent=%d" % [mat, low, int(it.refine), broke, dropped, before - Save.zeny()])
		it["refine"] = 7
	m.show_refiner()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/refiner.png" % dir)
	get_tree().quit()






func _newmaps_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	var pics: = {}
	var snap: = func(name: String):
		await RenderingServer.frame_post_draw
		pics[name] = get_viewport().get_texture().get_image()


	Save.data["max_danger"] = 13
	for sid in GameData.STAGES:
		if not sid in ["ice_dun", "ra_san", "thor"]:
			Save.clear_stage(sid)
	world.menus.show_server_select("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	await snap.call("worldmap")
	var ws: Node = null
	var stack: Array = [get_tree().root]
	while not stack.is_empty() and ws == null:
		var n: Node = stack.pop_back()
		if n is WorldSelect:
			ws = n
		stack.append_array(n.get_children())
	if ws != null:
		ws.call("_select_region", "rachel")
		await get_tree().create_timer(0.6, true, false, true).timeout
		await snap.call("worldmap_rachel")
	world.menus.close()
	if "--newmaps-only-map" in OS.get_cmdline_user_args():
		for k in pics:
			pics[k].save_png("%s/%s.png" % [dir, k])
		get_tree().quit()
		return
	for st in [["ice_dun", "mage", "glacial_heart", "cold_bolt"], ["ra_san", "swordsman", "dark_rune", ""], ["thor", "mage", "ifrit_mask", "fire_wall"], ["ice_dun", "swordsman", "dark_rune", ""]]:
		world.set_stage(str(st[0]))
		world.start_run(str(st[1]))
		world.menus.close()
		get_tree().paused = false
		await get_tree().create_timer(0.5, true, false, true).timeout
		var p: Player = world.player
		var it: = Equipment.make(str(st[2]), 0)
		var slot: = str(Equipment.item_def(it).slot)
		p.equipment.slots["acc1" if slot == "acc" else slot] = it
		if str(st[3]) != "":
			p.add_skill(str(st[3]))
		p.recompute()
		p.max_hp = 99999.0
		p.hp = 20000.0
		world.time = 300.0
		var stage: Dictionary = GameData.STAGES[st[0]]
		for ev in stage.events:
			if ev.type in ["elite", "boss"] and float(ev.at) < 300.0:
				world.spawn_enemy(str(ev.mob), p.position + Vector3(randf_range(-6, 6), 0, randf_range(-6, 6)), true)
		for i in 24:
			var sp: Dictionary = stage.spawns[i % stage.spawns.size()]
			var a: = TAU * i / 24.0
			world.spawn_enemy(str(sp.mob), p.position + Vector3(cos(a), 0, sin(a)) * (3.0 + float(i % 3) * 1.5), true)

		if st[0] == "thor":
			p.uniq["heat"] = 11
		for k in 3:
			await get_tree().create_timer(2.0, true, false, true).timeout
			p.hp = minf(p.hp, 20000.0)
			await snap.call("%s_%s_%d" % [st[0], st[2], k])
		print("NEWMAPS %s enemies=%d meter=%s uniq=%s" % [st[0], world.enemies.size(), world.meter.keys(), 
			p.uniq.keys().filter( func(k): return not str(k).ends_with("_nodes"))])
		world.abandon_run()
		get_tree().paused = false
		await get_tree().create_timer(0.5, true, false, true).timeout
	for k in pics:
		pics[k].save_png("%s/%s.png" % [dir, k])
	get_tree().quit()




func _ruwach_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("acolyte")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.3, true, false, true).timeout
	var p: Player = world.player
	for k in 5:
		p.add_skill("ruwach")
	world._cam_distance = 24.0
	var pics: = {}
	for step in 3:
		p.stats["int"] = 0 if step == 0 else 10
		p.recompute()
		if step == 2:
			p.extra_count = 2
		Skills.cast(world, p, "ruwach", 5, "ruwach")
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		pics["ruwach_%d" % step] = get_viewport().get_texture().get_image()
		print("RUWACH step %d area=%.2f flames=%d" % [step, p.area_mult, world._orbits[0].nodes.size() if not world._orbits.is_empty() else 0])
	for k in pics:
		pics[k].save_png("%s/%s.png" % [dir, k])
	get_tree().quit()





func _monk_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	Save.data.rebirths["acolyte"] = 1
	world.start_run("acolyte")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.3, true, false, true).timeout
	var p: Player = world.player
	p.level = 30
	p.job_change(1)
	for id in ["call_spirits", "critical_explosion"]:
		for k in 5:
			p.add_skill(id)
	p.recompute()
	p.max_hp = 99999.0
	p.hp = p.max_hp
	world._cam_distance = 22.0
	print("MONK job=%s spheres max=%d power=%.2f" % [p.job2.get("id", ""), p.sphere_max, p.sphere_power])
	for i in 18:
		var a: = TAU * i / 18.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * (1.6 + (i % 3) * 0.9), true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 999999.0
			e.hp = e.max_hp
	var pics: = {}
	for k in 16:
		await get_tree().create_timer(0.5, true, false, true).timeout
		p.hp = p.max_hp
		print("MONK t=%.1f spheres=%d fury=%s crit=%.2f basic=%.2f aspd_bonus=%.2f" % [k * 0.5, p.spheres, p.powers.has("critical_explosion"), 
			p.crit, p.basic_mult, p.aspd_bonus])
		await RenderingServer.frame_post_draw
		pics["t%02d" % k] = get_viewport().get_texture().get_image()
	p.add_skill("asura_strike")
	p.spheres = p.sphere_max
	Skills.cast(world, p, "asura_strike", 1, "asura_strike")
	for k in 4:
		await get_tree().create_timer(0.2, true, false, true).timeout
		await RenderingServer.frame_post_draw
		pics["asura_%d" % k] = get_viewport().get_texture().get_image()
	for k in pics:
		pics[k].save_png("%s/%s.png" % [dir, k])
	get_tree().quit()






func _karma_test(dir: String, side: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	GameData.set_meta("karma_test", true)
	GameData.set_meta("tour_god", true)
	var pics: = {}
	var shot: = func(key: String):
		await RenderingServer.frame_post_draw
		pics[key] = get_viewport().get_texture().get_image()

	var wait: = func(t: float):
		await get_tree().create_timer(t, true, false, true).timeout
		if world.menus.mode() != "corrupt":
			world.menus.close()
			get_tree().paused = false
	await wait.call(1.0)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	await wait.call(0.5)
	var p: Player = world.player
	world._cam_distance = 16.0
	var k: Karma = world.karma

	var d: = world.spawn_enemy("dark_priest", p.position + Vector3(3.5, 0, 2.0), true, false, "corrupto")
	d.speed = 0.0
	await wait.call(1.2)
	await shot.call("1_demon")
	world.damage_by = p
	world.damage_enemy(d, d.max_hp * 2.0, Vector3.ZERO)
	await wait.call(0.8)
	await shot.call("2_corrupt_chest")
	k.chest_choice(p.position, p)
	await wait.call(0.6)
	await shot.call("3_choice")
	world.menus.close()
	get_tree().paused = false

	k.path = "dark"
	k.chest_choice(p.position, p)
	await wait.call(0.6)
	await shot.call("3a_choice_path")
	world.menus.close()
	get_tree().paused = false
	k.path = ""

	world.menus.auto_pick = true
	var lv: = p.level
	k.purify_chest(p.position, p)
	print("KARMA purify level %d -> %d karma=%d" % [lv, p.level, k.value])
	var hp0: = p.hp
	k.open_chest(p.position, p)
	print("KARMA open hp %.0f -> %.0f karma=%d level=%d marks=%d feathers=%d foe=%d/%d dmg_mult=%.3f max_hp=%.0f" % [hp0, p.hp, k.value, p.level, p.hel_marks, p.feathers, k.hel_marks, k.feathers, p.dmg_mult, p.max_hp])
	var foe: = world.spawn_enemy("poring", p.position + Vector3(6, 0, 6), true)
	if foe != null:
		print("KARMA foe price: poring hp=%.0f dmg=%.1f (base %.0f / %.1f)" % [foe.max_hp, foe.damage, float(GameData.MONSTERS.poring.get("hp", 0.0)), float(GameData.MONSTERS.poring.get("damage", 0.0))])


	world.menus.auto_pick = false
	var res: = []
	for id in ["excalibur", "sleipnir", "cotton_shirt"]:
		if not GameData.ITEMS.has(id):
			continue
		var it: = Equipment.make(id, 2)
		p.equipment.bag.append(it)
		res.append({"item": it, "result": "bagged", "slot": str(GameData.ITEMS[id].slot), "zeny": 0})
	var bag0: = p.equipment.bag.size()
	world.menus.show_chest(res, 2, "", "chest_corrupt")
	await get_tree().create_timer(1.8, true, false, true).timeout
	await shot.call("3b_open_chest")
	for b in world.menus.find_children("*", "Button", true, false):
		if (b as Button).text.begins_with("Vender todo"):
			(b as Button).pressed.emit()
			print("KARMA sell all: %s" % (b as Button).text)
	print("KARMA sell all bag %d -> %d" % [bag0, p.equipment.bag.size()])
	await get_tree().create_timer(0.3, true, false, true).timeout
	await shot.call("3c_sold")
	world.menus.close()
	get_tree().paused = false
	world.menus.auto_pick = true
	await wait.call(1.0)
	world.menus.close()
	get_tree().paused = false

	world.altars.spawn("baldur", p.position + Vector3(-4, 0, 1))
	world.altars.spawn("hel", p.position + Vector3(4, 0, 1))
	p.position += Vector3(-2.5, 0, 0.6)
	await wait.call(1.2)
	await shot.call("4_altars")
	p.hurt_at = world.clock
	p.position = world.altars.waiting[0].pos
	await wait.call(GameData.ALTAR_CHANNEL + 0.6)
	print("KARMA baldur while hurt: waiting=%d fill=%.2f dist=%.2f hurt_at=%.1f time=%.1f" % [world.altars.waiting.size(), float(world.altars.waiting[0].fill), p.position.distance_to(world.altars.waiting[0].pos), p.hurt_at, world.time])
	p.hurt_at = world.clock - 10.0
	await wait.call(GameData.ALTAR_CHANNEL + 0.6)
	print("KARMA baldur calm: waiting=%d karma=%d max_hp=%.0f" % [world.altars.waiting.size(), k.value, p.max_hp])

	k.add(-80 - k.value)
	await wait.call(0.5)
	await shot.call("5_veil_dark")
	k.add(80 - k.value)
	await wait.call(0.5)
	await shot.call("6_veil_light")
	k.add((60 if side == "light" else -60) - k.value)

	world.raid.open_portal(world.stage.mvp)
	p.position = world.raid.portal_pos
	for i in 120:
		await wait.call(0.25)
		if world.raid.state == "fight" and world.raid.boss != null:
			break
	await wait.call(1.0)
	var b: Enemy = world.raid.boss
	world.damage_by = p
	world.damage_enemy(b, b.max_hp * 2.0, Vector3.ZERO)
	for i in 60:
		await wait.call(0.25)
		if world.raid._kportal_pos != Vector3.INF:
			break
	p.position = world.raid.center + Vector3(0, 0, 3.0)
	await wait.call(1.0)
	await shot.call("7_exits")
	print("KARMA exits: exit=%s route=%s side=%s" % [world.raid.portal_pos != Vector3.INF, world.raid._kportal_pos != Vector3.INF, world.raid._kside])

	p.position = world.raid._kportal_pos
	for i in 120:
		await wait.call(0.25)
		if world.raid.state == "fight" and world.raid.boss != null:
			break
	await wait.call(1.5)
	if world.raid.boss != null:
		world.raid.boss.speed = 0.0
		p.position = world.raid.boss.position + Vector3(1.5, 0, 3.0)
	await wait.call(0.4)
	await shot.call("8_route")
	b = world.raid.boss
	print("KARMA route boss=%s hp=%.0f karma.route=%s map=%s" % [b.id if b != null else "-", b.max_hp if b != null else 0.0, k.route, world.map.map_name])
	world.damage_enemy(b, b.max_hp * 2.0, Vector3.ZERO)
	for i in 60:
		await wait.call(0.25)
		if world.raid.portal_pos != Vector3.INF and world.raid._return_portal:
			break
	await wait.call(1.0)
	await shot.call("9_route_won")
	print("KARMA won boon=%s x%d revives=%d dmg_altar=%.2f path=%s kportal=%s" % [k.boon, k.boons, p.revives, float(p.altar_mods.get("dmg", 0.0)), k.path, world.raid._kportal_pos != Vector3.INF])


	world.raid.leave()
	k.add((-60 if side == "light" else 60) - k.value)
	await wait.call(0.5)
	world.raid.open_portal(world.stage.mvp)
	p.position = world.raid.portal_pos
	for i in 120:
		await wait.call(0.25)
		if world.raid.state == "fight" and world.raid.boss != null:
			break
	await wait.call(1.0)
	world.damage_enemy(world.raid.boss, world.raid.boss.max_hp * 2.0, Vector3.ZERO)
	for i in 60:
		await wait.call(0.25)
		if world.raid._kportal_pos != Vector3.INF:
			break
	print("KARMA again: route portal=%s side=%s (karma %d)" % [world.raid._kportal_pos != Vector3.INF, world.raid._kside, k.value])
	p.position = world.raid._kportal_pos
	for i in 120:
		await wait.call(0.25)
		if world.raid.state == "fight" and world.raid.boss != null:
			break
	await wait.call(1.0)
	world.damage_enemy(world.raid.boss, world.raid.boss.max_hp * 2.0, Vector3.ZERO)
	await wait.call(4.0)
	print("KARMA stacked boon=%s x%d revives=%d dmg_altar=%.2f" % [k.boon, k.boons, p.revives, float(p.altar_mods.get("dmg", 0.0))])
	for key in pics:
		pics[key].save_png("%s/%s.png" % [dir, key])
	get_tree().quit()




func _status_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("thief")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.3, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = p.max_hp
	p.set_physics_process(false)
	world._cam_distance = 16.0
	var mobs: = []
	for i in 6:
		var e: = world.spawn_enemy("orc_zombie" if i < 5 else "orc_lord", p.position + Vector3(-5.0 + i * 2.2, 0, 3.0), true)
		e.speed = 0.0
		e.max_hp = 9999999.0
		e.hp = e.max_hp
		mobs.append(e)
	await get_tree().create_timer(0.3, true, false, true).timeout
	world.damage_by = p

	for k in 7:
		world.apply_poison(mobs[0], 1.0, 60.0)
	world.dots.burn_on(world, mobs[1], 10.0, "burn", p)
	for k in 3:
		world.dots.bleed_on(world, mobs[2], 1.0, "bleed", p)
	for e in [mobs[3], mobs[5]]:
		for k in 12:
			world.apply_poison(e, 1.0, 60.0)
		world.dots.burn_on(world, e, 10.0, "burn", p)
		for k in 2:
			world.dots.bleed_on(world, e, 1.0, "bleed", p)
	for k in 40:
		world.apply_poison(mobs[4], 1.0, 60.0)
	for k in 4:
		world.dots.bleed_on(world, mobs[4], 1.0, "bleed", p)
	for e in mobs:
		e.blood_time = 999.0
	await get_tree().create_timer(0.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.save_png(dir + "/status.png")
	await get_tree().create_timer(1.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(dir + "/status_later.png")
	get_tree().quit()




func _occult_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("acolyte")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.3, true, false, true).timeout
	var p: Player = world.player
	p.level = 30
	p.job_change(1)
	for k in 5:
		p.add_skill("investigate")
	p.recompute()
	p.max_hp = 99999.0
	p.hp = p.max_hp
	world._cam_distance = 18.0
	print("OCCULT offered finger? ", GameData.CLASSES.acolyte.job2_alt.skills.has("finger_offensive"))
	var pics: = {}
	for side in 4:
		for e in world.enemies.duplicate():
			e.queue_free()
		world.enemies.clear()
		var d: = Vector3(1, 0, 0).rotated(Vector3.UP, PI * 0.25 + PI * 0.5 * side)
		for i in 5:
			var e: = world.spawn_enemy("poring", p.position + d * (2.2 + i * 1.3), true)
			if e != null:
				e.speed = 0.0
				e.max_hp = 99999.0
				e.hp = e.max_hp
		await get_tree().create_timer(0.4, true, false, true).timeout
		world.meter.clear()
		Skills.cast(world, p, "investigate", 5, "investigate")
		for k in 3:
			await get_tree().create_timer(0.08, true, false, true).timeout
			await RenderingServer.frame_post_draw
			pics["side%d_%d" % [side, k]] = get_viewport().get_texture().get_image()
		var m: Dictionary = world.meter.get("investigate", {})
		print("OCCULT side %d hits=%d dmg=%d" % [side, int(m.get("hits", 0)), int(m.get("dmg", 0))])
	for k in pics:
		pics[k].save_png("%s/%s.png" % [dir, k])
	get_tree().quit()





func _mvpfx_test(dir: String, mvp: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	world.raid.open_portal(mvp)
	await get_tree().create_timer(0.3, true, false, true).timeout
	get_tree().paused = false
	world.menus.close()
	p.position = world.raid.portal_pos

	for i in 40:
		await get_tree().create_timer(0.5, true, false, true).timeout
		if world.raid.boss != null:
			break
	await get_tree().create_timer(1.0, true, false, true).timeout
	var raid: = world.raid
	if raid.boss == null:
		print("MVPFX no boss")
		get_tree().quit()
		return


	var pics: = {}
	var shot: = func(name: String):
		await RenderingServer.frame_post_draw
		pics[name] = get_viewport().get_texture().get_image()
	var keep: = func():
		for id in raid._timers:
			raid._timers[id] = 999.0
		p.max_hp = 999999.0
		p.hp = p.max_hp
	keep.call()
	for ab in raid.data.abilities:
		if not str(ab.mech) in ["cone", "charge", "slam", "rain", "spokes", "volley", "puddles", "sweep", "clock"]:
			continue
		keep.call()
		raid.boss.position = raid.center
		p.position = raid.center + Vector3(4.0, 0, 3.0)
		await get_tree().create_timer(0.6, true, false, true).timeout
		world.fx_layer(GameData.MVP_FX_PRIORITY)
		raid._start(ab)
		world.fx_layer(0)
		var cast: = float(ab.get("cast", 1.0))
		var name: = "%s_%s" % [mvp, ab.id]
		var t0: = Time.get_ticks_msec()
		var left: = cast
		for k in [[cast * 0.5, "a_tell"], [cast * 0.45, "b_before"], [0.1, "c_hit"], [0.1, "d_after"], [0.15, "e_late"], [0.35, "f_end"]]:
			await get_tree().create_timer(float(k[0]), true, false, true).timeout
			keep.call()
			await shot.call("%s_%s" % [name, k[1]])
			print("MVPFX   %s at %.2f s, cast left %s fps %d frames %d" % [k[1], (Time.get_ticks_msec() - t0) / 1000.0, raid._cast.get("t", "-"), Engine.get_frames_per_second(), Engine.get_process_frames()])
		await get_tree().create_timer(2.5, true, false, true).timeout
		print("MVPFX ", name, " done")
	for k in pics:
		pics[k].save_png("%s/%s.png" % [dir, k])
	get_tree().quit()




func _pacts_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.data["max_danger"] = 4
	world.menus.show_pacts("swordsman")
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/pacts.png" % dir)
	print("PACTS open=", GameData.PACTS.keys().filter( func(k): return GameData.pact_unlocked(k)))


	Save.data["max_danger"] = 12
	world.menus.show_pacts("swordsman")
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/pacts_all.png" % dir)
	for with_pact in [false, true]:
		Save.data.pacts["swordsman"] = ["retaliation"] if with_pact else []
		world.start_run("swordsman")
		await get_tree().create_timer(0.5, true, false, true).timeout
		var p: Player = world.player
		p.equipment.slots.armor = Equipment.make("turtle_shell", 0)
		p.recompute()
		p.max_hp = 2500.0
		p.hp = 2500.0
		for i in 20:
			var a: = TAU * i / 20.0
			var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * 1.5, true, false)
			if e != null:
				e.max_hp = 1000000.0
				e.hp = e.max_hp
		for k in 60:
			p._invuln = 0.0
			p.hp = p.max_hp
			p.take_damage(1.0, world, world.nearest_enemy(p.position, 9.0))
			await get_tree().create_timer(0.1, true, false, true).timeout
		var m: Dictionary = world.meter.get("proc:magnum_break", {})
		print("PACTS retaliation=%s magnum hits=%d dmg=%d" % [with_pact, int(m.get("hits", 0)), int(m.get("dmg", 0))])
		world.abandon_run()
		get_tree().paused = false
	get_tree().quit()




func _townsound_test() -> void :
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("sound_log", true)
	world.enter_town("swordsman")
	await get_tree().create_timer(90.0, true, false, true).timeout
	get_tree().quit()




func _hires_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	world.player.add_xp(world.player.xp_need)
	await get_tree().create_timer(2.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/levelup.png" % dir)
	get_tree().quit()




func _buffrow_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.add_skill("improve_concentration")
	p.add_power("tiger_rush", 8.0)
	p.add_power("berserk_potion", 12.0)
	p.recompute()
	await get_tree().create_timer(1.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	var img: = get_viewport().get_texture().get_image()
	img.get_region(Rect2i(0, 0, 420, 240)).save_png("%s/row.png" % dir)
	get_tree().quit()




func _traps_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	for i in 8:
		var a: = TAU * i / 8.0
		var id: String = ["land_mine", "sandman", "ankle_snare"][i % 3]
		world.place_trap(p.position + Vector3(cos(a), 0, sin(a)) * 3.0, 2.0, 100.0, GameData.SKILLS[id])
	await get_tree().create_timer(0.4, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/traps.png" % dir)
	for i in 6:
		world.spawn_enemy("poring", p.position + Vector3(randf_range(-6, 6), 0, randf_range(-6, 6)))
	await get_tree().create_timer(4.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/after.png" % dir)
	print("TRAPS left=%d" % world._traps.size())
	get_tree().quit()




func _merge_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.magnet = 0.0
	p.position += Vector3(40, 0, 0)
	var sum: = func(kind: String) -> Array:
		var n: = 0
		var v: = 0
		for q in world.pickups:
			if q.kind == kind:
				n += 1
				v += int(q.value)
		return [n, v]
	for i in 3000:
		world._drop_xp(p.position + Vector3(randf_range(-60, -20), 0, randf_range(-20, 20)), randi_range(1, 12))
	print("MERGE before xp=%s loot=%s fps=%d" % [sum.call("xp"), sum.call("loot"), Engine.get_frames_per_second()])
	await get_tree().create_timer(3.0, true, false, true).timeout
	print("MERGE after xp=%s loot=%s fps=%d" % [sum.call("xp"), sum.call("loot"), Engine.get_frames_per_second()])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/merge.png" % dir)
	get_tree().quit()




func _invcut_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var eq: Equipment = world.player.equipment
	var armor: = Equipment.make("valkyrian_armor", 0)
	armor.refine = 6
	eq.slots.armor = armor
	var bow: = Equipment.make("composite_bow", 1)
	bow.refine = 5
	eq.slots.weapon = bow
	while eq.bag.size() < GameData.INVENTORY_MAX + 10:
		eq.bag.append(eq.roll_item(60.0, 0))
	print("INVCUT bag before=%d" % eq.bag.size())
	await get_tree().create_timer(1.0, true, false, true).timeout
	print("INVCUT bag after=%d" % eq.bag.size())
	world.menus.show_equipment()
	await get_tree().create_timer(0.7, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/eq.png" % dir)
	get_tree().quit()




func _chestglow_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var results: = []
	for id in ["lord_kaho_horn", "composite_bow"]:
		var it: = Equipment.make(id, 1)
		results.append({"item": it, "result": "bagged", "slot": str(Equipment.item_def(it).slot), "zeny": 0})
	world.menus.show_chest(results, 2)
	await get_tree().create_timer(2.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/chest.png" % dir)
	get_tree().quit()





func _streak_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = p.max_hp
	for i in 6:
		var e: = world.spawn_enemy("poring", p.position + Vector3(7.0, 0, -3.0 + i * 1.2), true)
		if e != null:
			e.max_hp = 99999.0
			e.hp = e.max_hp
			e.speed = 0.0
	var k: = 0
	for id in ["double_strafe", "charge_arrow", "sharp_shooting"]:
		Skills.cast(world, p, id, 3)
		await get_tree().create_timer(0.2 if id == "double_strafe" else 0.09, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/streak_%d.png" % [dir, k])
		k += 1
		await get_tree().create_timer(0.6, true, false, true).timeout
	get_tree().quit()




func _questicon_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.menus.show_server_select("swordsman")
	await get_tree().create_timer(1.2, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/maps.png" % dir)
	get_tree().quit()




func _gallop_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	var before: = p.move_speed
	world.raid.open_portal("baphomet")
	await get_tree().create_timer(0.3, true, false, true).timeout
	get_tree().paused = false
	world.menus.close()
	print("GALLOP speed %.2f -> %.2f magnet %.2f" % [before, p.move_speed, p.magnet])
	Input.action_press("move_left")
	for i in 3:
		await get_tree().create_timer(1.2, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/gallop_%d.png" % [dir, i])
	Input.action_release("move_left")
	world.raid._enter()
	await get_tree().create_timer(0.2, true, false, true).timeout
	print("GALLOP after portal: ", world.player.powers.has("sleipnir_gallop"))
	get_tree().quit()





func _snare_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = p.max_hp
	p.job_change(0)
	p.add_skill("beast_bane")
	p.recompute()
	print("SNARE trap_vuln=%.2f" % float(p.effects.get("trap_vuln", 0.0)))
	var foes: Array = []
	for i in 4:
		var e: = world.spawn_enemy("poring", p.position + Vector3(6.0, 0, -1.5 + i), true)
		if e != null:
			e.max_hp = 99999.0
			e.hp = e.max_hp
			foes.append(e)
	world.place_trap(p.position + Vector3(3.0, 0, 0), 1.4, 40.0, Skills._trap_sk("ankle_snare", 3))
	await get_tree().create_timer(2.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/snare.png" % dir)
	for e in foes:
		if is_instance_valid(e):
			print("SNARE poring snare=%.1f bleed=%d trapped=%s hp_lost=%.0f" % [e.snare_time, e.blood_stacks, e.trapped_until > world.time, e.max_hp - e.hp])
	var boss: = world.spawn_enemy("baphomet", p.position + Vector3(-5.0, 0, 0), true)
	world.place_trap(p.position + Vector3(-2.5, 0, 0), 2.6, 150.0, GameData.SKILLS.ankle_snare_x)
	await get_tree().create_timer(2.5, true, false, true).timeout
	if boss != null and is_instance_valid(boss):
		print("SNARE boss snare=%.1f bleed=%d" % [boss.snare_time, boss.blood_stacks])

		var shares: = []
		for i in 4:
			shares.append(world.cc_scale(boss, "root"))
		world.time += GameData.CC_DR_RESET + 0.1
		shares.append(world.cc_scale(boss, "root"))
		print("SNARE dr=%s" % str(shares))
	get_tree().quit()




func _shiftcmp_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var eq: Equipment = world.player.equipment
	eq.bag.append(Equipment.make("composite_bow", 2))
	world.menus.show_equipment()
	await get_tree().create_timer(0.6, true, false, true).timeout
	for k in 2:
		if k == 1:
			var ev: = InputEventKey.new()
			ev.keycode = KEY_SHIFT
			ev.pressed = true
			Input.parse_input_event(ev)
			await get_tree().process_frame
		world.menus._show_item_hover(eq.bag[0], world.menus._root)
		await get_tree().create_timer(0.4, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/cmp_%d.png" % [dir, k])
	get_tree().quit()




func _hypnoui_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	for cls in ["ninja", "archer", "mage", "merchant"]:
		Save.data.rebirths[cls] = 1
		world.start_run(cls)
		await get_tree().create_timer(0.5, true, false, true).timeout
		var p: Player = world.player
		p.job_change(0)
		for id in GameData.CLASSES[cls].skills:
			if p.count_skills(false) < p.max_skills():
				p.add_skill(id)
		for id in p.passive_pool():
			if GameData.SKILLS.has(id) and not p.skills.has(id):
				p.add_skill(id)
				break
		p.recompute()
		var opts: = world.altars.forgettable().filter( func(id): return not world.altars.hypno_offer(id).is_empty())
		print("HYPNO %s forget=%d offer=%d" % [cls, opts.size(), world.altars.hypno_offer(opts[0]).size() if not opts.is_empty() else 0])
		for id in world.altars.forgettable().filter( func(id): return p.is_passive(id)):
			print("HYPNO passive %s -> %s" % [id, world.altars.hypno_offer(id)])
		world.altars._hypnotize({"pos": p.position, "node": Node3D.new()}, GameData.ALTARS.hypnotist)
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s_1.png" % [dir, cls])
		if not opts.is_empty():
			world.altars._hypno_pick_new(opts[0])
			await get_tree().create_timer(0.8, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_2.png" % [dir, cls])
		world.abandon_run()
		get_tree().paused = false
		await get_tree().create_timer(0.5, true, false, true).timeout
	get_tree().quit()




func _party_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.enter_town("swordsman")
	await get_tree().create_timer(1.5, true, false, true).timeout
	var npc: Node3D = world.town.npc_node("party")
	if npc != null and not "--party-shot" in OS.get_cmdline_user_args():
		world.town.hero.position = npc.position + Vector3(0, 0, 2.0)
	elif npc != null and "--party-cat" in OS.get_cmdline_user_args():
		world.town.hero.position = world.town._at(Vector2i(143, 181))
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/1_town.png" % dir)
	if "--party-cells" in OS.get_cmdline_user_args():
		for y in range(186, 170, -1):
			var row: = "%d " % y
			for x in range(130, 148):
				row += "#" if not world.map.cell_walkable(x, y) else ("P" if Vector2i(x, y) == Vector2i(142, 178) else ".")
			print("CELLS ", row)
		get_tree().quit()
		return
	if "--party-shot" in OS.get_cmdline_user_args():
		world.menus.show_class_select()
		await get_tree().create_timer(1.0, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/4_class.png" % dir)
		world.menus.show_server_select("swordsman")
		await get_tree().create_timer(1.0, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/5_maps.png" % dir)
		world.menus.show_prep(world.stage_id)
		await get_tree().create_timer(1.0, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/6_prep.png" % dir)
		get_tree().quit()
		return
	world.menus.show_coop()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/2_window.png" % dir)
	var eos = world.net.eos()
	print("PARTY eos available=%s" % [eos != null])
	if eos != null:
		var peer = await eos.host_async()
		print("PARTY host peer=%s code=%s error=%s puid=%s" % [peer != null, eos.code, eos.error, get_node("/root/HAuth").product_user_id])
		if peer != null:
			world.net.host(0, peer)
			world.menus.show_coop()
			await get_tree().create_timer(1.0, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/3_room.png" % dir)
			var hl = get_node("/root/HLobbies")
			print("PARTY lobby attrs=%s" % [eos.lobby.attributes])
			for i in 3:
				await get_tree().create_timer(2.0, true, false, true).timeout
				var found = await hl.search_by_attribute_async({"key": "CODE", "value": eos.code})
				var by_bucket = await hl.search_by_bucket_id_async("midgard:coop")
				print("PARTY search %d: by code=%d by bucket=%d" % [i, found.size() if found != null else -1, by_bucket.size() if by_bucket != null else -1])
			world.net.leave()
			await get_tree().create_timer(2.0, true, false, true).timeout
	get_tree().quit()




func _procs_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("mage")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: = world.player
	p.album_cards.append_array(["hornet_card", "argiope_card", "dark_priest_card", "steel_chocho_card"])
	p.stats["int"] = 30
	p.recompute()
	world.menus._stat_more = true
	world.menus._stat_more_slot = "weapon"
	world.menus.show_equipment()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/details.png" % dir)
	get_tree().quit()




func _prep_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	for st in GameData.QUESTS:
		Save.complete_quest(st)
	Save.data["cook_level"] = 3
	Save.set_dishes(["immortal_stew", "lucky_soup", "fried_grasshopper"])
	for id in GameData.UPGRADES:
		Save.set_upgrade_level(id, int(GameData.UPGRADES[id].max))
	for id in GameData.SAGE_UPGRADES:
		Save.set_upgrade_level(id, int(GameData.SAGE_UPGRADES[id].max))
	Save.data.card_slots = ["poring_card", "lunatic_card", "fabre_card", "drops_card"]
	for c in Save.data.card_slots:
		Save.data.cards[c] = 1
	for id in ["cap", "angel_wing_ears", "pipe", "sword", "ribbon"]:
		if Save.add_to_storage(Equipment.make(id, 3)):
			Save.set_loadout_slot("swordsman", str(GameData.ITEMS[id].slot), str(Save.storage().back().uid))
	world.menus.show_class_select()
	await get_tree().create_timer(1.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/class_select.png" % dir)
	world.menus._run_class = "swordsman"
	world.menus.show_prep("prontera")
	await get_tree().create_timer(1.0, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/prep.png" % dir)
	var last: Control = world.menus._root.find_children("*", "Button", true, false).back()
	print("PREP view=%s last_button=%s" % [get_viewport().get_visible_rect().size, last.get_global_rect()])

	Save.save_set("sn", "Magia", Save.sn_build().duplicate(true))
	world.menus.show_sn_build( func(): pass)
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/sets.png" % dir)

	Save.set_sn_build({"skills": [], "passives": []})
	world.menus.show_sn_build( func(): pass)
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/sn_empty.png" % dir)


	world.start_run("thief")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: = world.player
	world.menus.close()
	for id in ["blade", "cap", "manteau"]:
		p.equipment.bag.append(Equipment.make(id, 3))
	world.menus.show_equipment("weapon", "", true, 0)
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/equip_bag.png" % dir)
	world.menus._stat_view = "fx"
	world.menus.show_equipment("weapon")
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/equip_fx.png" % dir)
	world.menus._stat_view = ""
	world.menus.close()
	get_tree().paused = false
	for i in 6:
		var foe: Enemy = world.spawn_enemy("poring", p.position + Vector3(cos(i * 0.6) * 2.0, 0, sin(i * 0.6) * 2.0), true)
		foe.max_hp = 100000.0
		foe.hp = foe.max_hp
	await get_tree().create_timer(0.1, true, false, true).timeout
	world.damage_by = p
	Skills.cast(world, p, "envenom", 5)
	await get_tree().create_timer(0.16, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/envenom.png" % dir)
	get_tree().quit()




func _chef_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	for st in ["prontera", "pay_cave", "orc", "glast", "mjolnir", "niflheim", "pyramid", "byalan"]:
		Save.complete_quest(st)
	Save.data["cook_level"] = 2
	Save.set_dishes(["immortal_stew"])
	Save.add_zeny(5000000)
	world.enter_town("swordsman")
	await get_tree().create_timer(1.5, true, false, true).timeout
	var snap: = func(key: String):
		await get_tree().create_timer(2.0, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, key])
	world.menus.show_chef()
	await snap.call("1_kitchen")
	world.menus._cook("twin_skewer")
	await get_tree().create_timer(0.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/2_cooking.png" % dir)
	await snap.call("3_served")
	Save.cook_upgrade()
	world.menus.show_chef()
	await snap.call("4_level3")
	print("CHEF level=%d dishes=%s zeny=%d" % [Save.cook_level(), Save.dishes(), Save.zeny()])
	get_tree().quit()




func _coopwin_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.enter_town("swordsman")
	await get_tree().create_timer(1.5, true, false, true).timeout
	var snap: = func(key: String):
		await get_tree().create_timer(2.0, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, key])
	world.menus.show_coop()
	await snap.call("1_lobby")
	world.net.host()
	world.net.roster = [{"id": 1, "name": "", "class": "swordsman"}, {"id": 7, "name": "Sakura145", "class": "acolyte"}, 
		{"id": 9, "name": "xXPr0StormXx", "class": "mage"}]
	world.menus.show_coop()
	await snap.call("2_room")
	world.net.leave()
	get_tree().quit()




func _partyhud_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	await get_tree().create_timer(1.5, true, false, true).timeout
	var snap: = func(key: String):
		await RenderingServer.frame_post_draw
		var img: = get_viewport().get_texture().get_image()
		img.save_png("%s/%s.png" % [dir, key])
		var f: Control = world.hud._party
		var r: = Rect2i(Vector2i(0, maxi(0, int(f.position.y) - 8)), Vector2i(int(f.size.x * f.scale.x) + 24, int(f.size.y * f.scale.y) + 16))
		img.get_region(r.intersection(Rect2i(Vector2i.ZERO, img.get_size()))).save_png("%s/%s_crop.png" % [dir, key])
	for h in world.heroes:
		h.max_hp = 4000.0
		h.hp = h.max_hp
	await get_tree().create_timer(0.4, true, false, true).timeout
	await snap.call("1_full")
	var hs: Array = world.heroes
	if hs.size() > 1:
		hs[1].hp = 2600.0
		hs[1].appearance["name"] = "Lydia"
		hs[1].level = 34
		hs[1].position = world.player.position + Vector3(30, 0, -20)
	if hs.size() > 2:
		hs[2].hp = 700.0
		hs[2].shield = 1500.0
	if hs.size() > 3:
		hs[3].downed = true
		hs[3].hp = 0.0
		hs[3].revive_t = GameData.COOP_REVIVE_TIME * 0.4
	await get_tree().create_timer(0.4, true, false, true).timeout
	await snap.call("2_states")
	print("PARTYHUD heroes=%d frames=%s" % [world.heroes.size(), world.hud._party.size])
	if hs.size() > 3:
		hs[3].downed = false
		hs[3].hp = hs[3].max_hp

	var items: = [Equipment.make("excalibur", 2), Equipment.make("staff_of_destruction", 1), Equipment.make("rudra_bow", 1)]
	world.loot_queue.append(LootRoll.make(items, 2, world.player.position))
	world._next_loot()
	var offer: LootRoll = world._loot
	offer.picks = {}
	offer.ready = {}
	var wish: = [[0, 2], [0], [1], [0]]
	for i in hs.size():
		offer.picks[i] = wish[i % wish.size()]
		if i > 0:
			offer.ready[i] = true
	offer.picks[0] = [0]
	await get_tree().create_timer(0.8, true, false, true).timeout
	await snap.call("3_roll_pick")
	world._loot_panel._confirm()
	for t in [0.6, 1.4, 1.6, 2.0]:
		await get_tree().create_timer(t, true, false, true).timeout
		await snap.call("4_dice_%.1f" % world.time)
	get_tree().quit()




func _coop_ui_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("archer")
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = p.max_hp
	p.add_xp(p.xp_need + 1.0)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var t0: = world.time
	print("COOPUI heroes=%d level_up_open=%s mode=%s paused=%s" % [world.heroes.size(), world.menus.is_open(), world.menus._mode, get_tree().paused])
	await get_tree().create_timer(1.5, true, false, true).timeout
	print("COOPUI time ran %.2f s with the window open (paused=%s)" % [world.time - t0, get_tree().paused])
	var hp0: = p.hp
	p.take_damage(500.0, world)
	var chasing: = world.enemies.filter( func(e): return e.hero_target == p).size()
	print("COOPUI choosing=%s hurt=%s enemies after him=%d of %d" % [p.choosing, p.hp < hp0, chasing, world.enemies.size()])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/levelup.png" % dir)
	var esc: = InputEventAction.new()
	esc.action = "pause"
	esc.pressed = true
	Input.parse_input_event(esc)
	await get_tree().create_timer(0.5, true, false, true).timeout
	var t1: = world.time
	await get_tree().create_timer(1.0, true, false, true).timeout
	print("COOPUI after Esc mode=%s paused=%s time ran %.2f" % [world.menus._mode, get_tree().paused, world.time - t1])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/pause.png" % dir)
	get_tree().quit()




func _heat_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("gunslinger")
	await get_tree().create_timer(0.5, true, false, true).timeout
	var p: Player = world.player
	p.max_hp = 99999.0
	p.hp = p.max_hp
	var e: = world.spawn_enemy("poring", p.position + Vector3(5, 0, 0), true)
	e.max_hp = 1000000000.0
	e.hp = e.max_hp
	e.speed = 0.0
	p.add_skill("heat_barrel")
	print("HEAT cast=", Skills.cast(world, p, "heat_barrel", 1))
	for t in [0.2, 1.4, 2.6]:
		await get_tree().create_timer(t if t < 1.0 else 1.2, true, false, true).timeout
		print("HEAT still level=%.2f aspd_mod=%.2f dmg_mod=%.2f" % [p.heat_level, float(p.heat.get("aspd", 0)), float(p.heat.get("dmg", 0))])
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/heat_hot.png" % dir)
	world.hud._show_hover(world.hud._pact_row, {"icon": null, "title": "Heat Barrel", "color": Color.ORANGE, "tag": "", "desc": "", "foot": world.hud._buff_now("heat_barrel", true)})
	await get_tree().create_timer(0.3, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/heat_hover.png" % dir)
	Input.action_press("move_up")
	await get_tree().create_timer(0.7, true, false, true).timeout
	Input.action_release("move_up")
	print("HEAT moved level=%.2f aspd_mod=%.2f" % [p.heat_level, float(p.heat.get("aspd", 0))])
	get_tree().quit()




func _spawn_morroc() -> void :
	var ev: MorrocEvent = world.morroc
	if not world.running or ev.active():
		_toast("Morroc: no hay partida o ya está en curso")
		return
	var spot: = ev._find_arena()
	if spot.is_empty():
		_toast("Morroc: no hay sitio abierto cerca, muévete a un claro")
		return
	ev._begin_omen(spot[0], spot[1])
	_toast("Satan Morroc invocado")




func _spawn_finale() -> void :
	var ev: MorrocEvent = world.morroc
	if not world.running or ev.active():
		_toast("Morroc: no hay partida o ya está en curso")
		return
	if not world.endless:
		world.continue_endless()
	ev._use(GameData.MORROC_FINALE, true)
	var spot: = ev._find_arena()
	if spot.is_empty():
		ev._use(GameData.MORROC, false)
		_toast("Morroc: no hay sitio abierto cerca, muévete a un claro")
		return
	ev._finale_done = true
	ev._begin_omen(spot[0], spot[1])
	_toast("Final de Infinito invocado")





func _morroc_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var p: = world.player
	world.menus.auto_pick = true

	get_tree().process_frame.connect( func():
		if is_instance_valid(p):
			p.hp = p.max_hp)
	world.time = 200.0
	for i in 40:
		var a: = TAU * i / 40.0
		world.spawn_enemy("poring" if i % 2 == 0 else "lunatic", p.position + Vector3(cos(a), 0, sin(a)) * randf_range(6.0, 20.0), true)
	var ev: MorrocEvent = world.morroc
	var spot: = ev._find_arena()
	print("MORROC spot=", spot)
	if spot.is_empty():
		get_tree().quit()
		return
	ev._begin_omen(spot[0], spot[1])
	var snap: = func(name: String) -> void :
		p.hp = p.max_hp
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])

	var until: = func(cond: Callable) -> void :
		for i in 2000:
			if cond.call():
				return
			await get_tree().process_frame
	await until.call( func(): return ev._omen < 19.4)
	await snap.call("omen_start")
	await until.call( func(): return ev._omen < 9.0)
	await snap.call("omen_dark")
	await until.call( func(): return ev._omen < 1.5)
	await snap.call("omen_impact")
	await until.call( func(): return ev.state == "fall" and ev._fall < 0.4)
	await snap.call("fall")
	await until.call( func(): return ev.state == "fight")
	await get_tree().create_timer(0.3, true, false, true).timeout
	await snap.call("landed")
	await get_tree().create_timer(2.0, true, false, true).timeout
	await snap.call("fight")
	ev._arena.visible = false
	await snap.call("fight_noarena")
	ev._arena.visible = true
	for a in ev.boss.get_children():
		if a is MvpAura:
			a.visible = false
	await snap.call("fight_noaura")
	print("MORROC state=%s boss=%s hp=%d enemies=%d" % [ev.state, ev.boss != null, ev.boss.max_hp if ev.boss != null else 0, world.enemies.size()])
	for ab in GameData.MORROC.abilities:
		if ev.state != "fight":
			break
		ev._cast = {}
		ev._start(ab)
		await get_tree().create_timer(0.7, true, false, true).timeout
		await snap.call("ab_" + str(ab.id))
		await get_tree().create_timer(2.6, true, false, true).timeout

	ev.boss.hp = ev.boss.max_hp * 0.6
	await get_tree().create_timer(2.0, true, false, true).timeout
	p.hp = p.max_hp
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/incarnations.png" % dir)
	for e in world.enemies.duplicate():
		if e.id.begins_with("morroc_incarnation"):
			world.damage_enemy(e, e.max_hp * 10.0)
	await get_tree().create_timer(1.6, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/stunned.png" % dir)
	ev._judge_in = false
	ev._start(GameData.MORROC.abilities[2])
	await get_tree().create_timer(1.0, true, false, true).timeout
	p.hp = p.max_hp
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/ab_embrace.png" % dir)
	await get_tree().create_timer(2.5, true, false, true).timeout
	world.damage_enemy(ev.boss, ev.boss.max_hp * 10.0)
	await get_tree().create_timer(2.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/won.png" % dir)
	print("MORROC end state=%s time=%.1f won=%s" % [ev.state, world.time, ev.stats.won])
	get_tree().quit()




func _guns_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	for g in ["m", "f"]:
		for job in [false, true]:
			var look: Dictionary = Save.look("gunslinger").duplicate()
			look["gender"] = g
			Save.data.looks["gunslinger"] = look
			world.start_run("gunslinger")
			world.menus.close()
			get_tree().paused = false
			var p: = world.player
			if job:
				p.job_change(0)
			for gun in ["six_shooter", "rifle", "single_shotgun", "avenger_gatling", "destroyer"]:
				p.equipment.slots.weapon = Equipment.make(gun, 0)
				p.recompute()

				p.coins = 8
				for e in world.enemies.duplicate():
					world.banish_enemy(e)
				world.menus.auto_pick = true
				var dummy: = world.spawn_enemy("poring", p.position + Vector3(4, 0, 1.5), true)
				dummy.max_hp = 1000000000.0
				dummy.hp = 1000000000.0
				dummy.speed = 0.0
				await get_tree().create_timer(0.4, true, false, true).timeout

				var shot: = int(p.weapon_view()[2])
				for i in 300:
					if p.visual.base_action == shot and p.visual._frame >= 2:
						break
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var img: = get_viewport().get_texture().get_image()
				var c: = img.get_size() / 2
				img.get_region(Rect2i(c.x - 160, c.y - 150, 320, 230)).save_png("%s/%s_%s_%s.png" % [dir, g, "rebellion" if job else "gs", gun])
	get_tree().quit()






func _camturn_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	Save.set_setting("camera_turn", true)
	world.start_run("swordsman")
	world.menus.close()
	world.menus.auto_pick = true
	get_tree().paused = false
	var p: = world.player
	get_tree().process_frame.connect( func():
		if is_instance_valid(p):
			p.hp = p.max_hp)
	for i in 10:
		var a: = TAU * i / 10.0
		var e: = world.spawn_enemy("poring" if i % 2 == 0 else "willow", p.position + Vector3(cos(a), 0, sin(a)) * 6.0, true)
		e.speed = 0.0
	for deg in [0, 90, 180, -135]:
		world.set_view_yaw(deg_to_rad(deg))
		Input.action_press("move_up")
		await get_tree().create_timer(0.8, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/yaw_%d_up.png" % [dir, deg])
		Input.action_release("move_up")
		Input.action_press("move_right")
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/yaw_%d_right.png" % [dir, deg])
		Input.action_release("move_right")
		print("CAMTURN yaw=%d hero_dir=%d shown=%d" % [deg, p.visual.dir, p.visual.shown_dir()])

	var spr: = RoAssets.sprite(["cursors"])
	if spr != null:
		for a in [0, 1, 2, 4, 5, 7, 9]:
			spr.compose_image(a, 0).save_png("%s/cursor_%d.png" % [dir, a])

	var cur: RoCursor = world.get_node("RoCursor")
	var e: Enemy = world.enemies[0]
	world._drop_chest(p.position + Vector3(2.5, 0, 2.5), 1, 0)
	for t in [["monster", e.position + RoVisual.world_lift() + World.view_up() * e.visual.height() * 0.5], 
			["chest", p.position + Vector3(2.5, 0, 2.5)], ["ground", p.position + Vector3(-3.0, 0, -4.0)]]:
		get_viewport().warp_mouse(world.camera.unproject_position(t[1]))
		await get_tree().create_timer(0.3, true, false, true).timeout
		print("CAMTURN over %s cursor=%d hot0=%s gui=%s paused=%s mouse=%s ground=%s" % [t[0], cur.mode, cur._frames_of(0)[0][1], 
			get_viewport().gui_get_hovered_control(), get_tree().paused, get_viewport().get_mouse_position(), world.mouse_walk._ground_under_mouse()])
	get_tree().quit()






func _gems_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	GameData.set_meta("sound_log", true)
	world.start_run("swordsman")
	world.menus.close()
	world.menus.auto_pick = true
	get_tree().paused = false
	var p: = world.player
	p.magnet = 0.1
	var values: = [1, 10, 40, 100]
	for i in 24:
		var a: = TAU * i / 24.0
		world._drop_xp(p.position + Vector3(cos(a), 0, sin(a)) * (3.0 + (i % 3)), values[i % 4])
	for k in 4:
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/lying_%d.png" % [dir, k])
	print("GEMS drop big")
	world._drop_xp(p.position + Vector3(1.5, 0, 0), 120)
	await get_tree().create_timer(0.5, true, false, true).timeout
	p.magnet = 30.0
	for k in 3:
		await get_tree().create_timer(0.12, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/flying_%d.png" % [dir, k])
	await get_tree().create_timer(1.5, true, false, true).timeout
	print("GEMS left=%d level=%d" % [world.pickups.filter( func(q): return q.kind == "xp").size(), p.level])
	get_tree().quit()




func _pose_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	for job in [["acolyte", -1, false], ["acolyte", 1, false], ["acolyte", 1, true]]:
		if job[2]:
			Save.data.rebirths["acolyte"] = 1
		world.set_stage("prontera")
		world.start_run(job[0])
		await get_tree().create_timer(0.4, true, false, true).timeout
		var p: Player = world.player
		if int(job[1]) >= 0:
			p.job_change(int(job[1]))
		world._cam_distance = 12.0
		p.visual.face(Vector3(1, 0, 1))
		for act in [5, 10, 11, 12]:
			var n: = p.visual.action_length(act)
			print("POSE %s/%d act=%d len=%.2f" % [job[0], job[1], act, n])
			for k in 4:
				p.visual.play(act, false, true)
				p._attack_anim = 99.0
				p.visual.speed_scale = 1.0
				await get_tree().create_timer(n * k / 4.0 + 0.01, true, false, true).timeout
				p.visual.speed_scale = 0.0
				await get_tree().create_timer(0.15, true, false, true).timeout
				await RenderingServer.frame_post_draw
				var img: = get_viewport().get_texture().get_image()
				var sp: = world.camera.unproject_position(p.position + Vector3(0, 0.8, 0))
				var c: = Vector2i(clampi(int(sp.x), 160, img.get_width() - 160), clampi(int(sp.y), 160, img.get_height() - 160))
				print("POS ", p.position, " sp=", sp, " vis=", p.visual.visible)
				img.get_region(Rect2i(c.x - 150, c.y - 150, 300, 300)).save_png("%s/%s%d_%s_a%02d_%d.png" % [dir, job[0], job[1], "r" if job[2] else "", act, k])
		world.abandon_run()
		get_tree().paused = false
		await get_tree().create_timer(0.4, true, false, true).timeout
	get_tree().quit()





func _switch_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	var cases: = [["thief", 0, "back_stab"], ["ninja", 0, "shadow_slash"], ["acolyte", 1, "asura_strike"], ["gunslinger", 0, "heat_barrel"]]
	for c in cases:
		world.set_stage("prontera")
		world.start_run(c[0])
		world.menus.close()
		get_tree().paused = false
		await get_tree().create_timer(0.3, true, false, true).timeout
		var p: Player = world.player
		p.level = 30
		p.job_change(int(c[1]))
		p.skills.clear()
		p.add_skill(c[2])
		if c[2] == "asura_strike":
			p.add_skill("call_spirits")
			p.add_skill("steel_body")
		p.recompute()
		p.spheres = p.sphere_max
		p.max_hp = 99999.0
		p.hp = p.max_hp
		world.hud.bind(world)
		world._cam_distance = 26.0
		for i in 14:
			var at: = p.position + Vector3(2.0 + (i % 7) * 1.3, 0, -2.0 + int(i / 7) * 4.0)
			var e: = world.spawn_enemy("poring", at, true)
			if e != null:
				e.speed = 0.0
				e.max_hp = 999999.0
				e.hp = e.max_hp
		await get_tree().create_timer(0.3, true, false, true).timeout
		p._last_stick = Vector2(1, 0)
		var before: = p.position
		if c[2] == "heat_barrel":
			world.skill_switch("heat_barrel")
			await get_tree().create_timer(1.2, true, false, true).timeout
		else:
			Skills.cast(world, p, c[2], 5)
			await get_tree().create_timer(0.2, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, c[2]])
		await get_tree().create_timer(0.6, true, false, true).timeout
		print("SWITCH %s moved=%.1f powers=%s f=%s" % [c[2], p.position.distance_to(before), p.powers.keys(), p.f_skill()])
		if c[2] == "asura_strike":
			world.skill_switch("steel_body")
			print("SWITCH steel powers=%s spheres=%d" % [p.powers.keys(), p.spheres])
		world.abandon_run()
		get_tree().paused = false
		await get_tree().create_timer(0.3, true, false, true).timeout
	get_tree().quit()




func _togglepop_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.start_run("taekwon")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.3, true, false, true).timeout
	world._cam_distance = 24.0
	for on in [true, false, true]:
		world.toggle_pop(world.player, "flying_kick", on)
		await get_tree().create_timer(0.3, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/pop_%s_%d.png" % [dir, "on" if on else "off", Time.get_ticks_msec()])
		await get_tree().create_timer(1.2, true, false, true).timeout
	world.player.add_skill("flying_kick")
	world.menus.show_onboarding()
	await get_tree().create_timer(0.8, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/onboarding.png" % dir)
	get_tree().quit()





func _snmult_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.data["sn_build"] = {"skills": ["gatling_fever", "improve_concentration", "signum_crucis", "tornado_kick", "increase_agi", "mirror_image"], 
		"passives": ["vultures_eye", "peaceful_break", "chain_action", "divine_judgment", "cicada_skin_shed"]}
	print("SNMULT old set -> ", Save.sn_build())
	print("SNMULT def passives ", GameData.sn_def(Save.sn_build()).passives)
	world.menus._run_class = "super_novice"
	world.menus._sn_tab = "passives"
	world.menus.show_sn_build( func(): pass)
	world.menus._sn_toggle("double_attack", true)
	print("SNMULT after a third -> ", Save.sn_build())
	await get_tree().create_timer(0.5, true, false, true).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/snmult.png" % dir)
	for i in 4:
		var r: Dictionary = world.menus._sn_random()
		print("SNMULT random mults=", GameData.sn_mult_count(r.skills + r.passives))
	get_tree().quit()





func _thorset_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	for pieces in [[], ["executioner_gloves", "punishment_shoes"], ["executioner_gloves", "punishment_shoes", "asprika", "imperial_ring"]]:
		for slot in ["acc1", "acc2", "shoes", "garment"]:
			p.equipment.slots[slot] = null
		var accs: = ["acc1", "acc2"]
		for id in pieces:
			var slot: String = GameData.ITEMS[id].slot
			if slot == "acc":
				slot = accs.pop_front()
			p.equipment.slots[slot] = Equipment.make(id, 0)
		p.recompute()
		world.stagger.clear()
		var boss: = world.spawn_enemy(GameData.STAGES[world.stage_id].mvp, p.position + Vector3(4, 0, 0))
		boss.max_hp = 1e+15
		boss.hp = boss.max_hp
		world.meter.clear()
		var breaks: = 0
		var was: = ""

		for step in 360:
			world.clock += 0.5
			world.damage_by = p
			for tag in ["basic", "bash", "magnum_break"]:
				world.damage_tag = tag
				world.damage_enemy(boss, 1000.0, Vector3.ZERO, "basic" if tag == "basic" else "skill", "neutral", tag)
			if boss.status == "stun" and was != "stun":
				breaks += 1
			was = boss.status
			if boss.status == "stun":
				boss.status_time = maxf(0.0, boss.status_time - 0.5)
				if boss.status_time <= 0.0:
					boss.clear_status()
		var bolt: = float(world.meter.get("thor_bolt", {}).get("dmg", 0.0))
		var total: = 0.0
		for k in world.meter:
			total += float(world.meter[k].get("dmg", 0.0))
		print("THORSET pieces=%d sets=%s breaks=%d bolt=%.0f total=%.0f bolt_share=%.1f%% stagger_hit=%.2f fill=%.2f thor=%.0f" % [pieces.size(), 
			p.equipment.active_sets([]), breaks, bolt, total, 100.0 * bolt / maxf(total, 1.0), 
			float(p.effects.get("stagger_hit", 0.0)), float(p.effects.get("wing_fill", 0.0)), float(p.effects.get("thor_bolt", 0.0))])
		world.enemies.erase(boss)
		boss.queue_free()
	get_tree().quit()





func _hypernovice_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shot: = func(n: String):
		await get_tree().create_timer(0.6, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, n])
	if not Save.data.has("unlocked"):
		Save.data["unlocked"] = {}
	Save.data.unlocked["super_novice"] = true
	var lk: = Save.look("super_novice")
	lk["show"] = "hyper_novice"
	Save.set_look("super_novice", lk)
	print("HYPER looks=", GameData.job_looks("super_novice").map( func(e): return e.body), " shown=", GameData.shown_job("super_novice", lk).body)
	world.menus.show_char_make("super_novice")
	await shot.call("profile")
	world.menus.close()
	world.enter_town("super_novice")
	await shot.call("town")
	world.start_run("super_novice")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(1.0, true, false, true).timeout
	var p: Player = world.player
	world._cam_distance = 14.0
	print("HYPER lv%d body=%s" % [p.level, p.look.body])
	await shot.call("run_lv1")
	p.level = 19
	print("HYPER lv%d body=%s" % [p.level, p.look.body])
	p.level = 20
	print("HYPER lv%d body=%s weapon=%s" % [p.level, p.look.body, p.weapon_view()])
	await shot.call("run_lv20")
	get_tree().quit()




func _snbuild_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	Save.set_sn_build({"skills": ["fire_bolt", "double_strafe", "heal", "mammonite"], "passives": ["owls_eye", "sword_mastery", "pushcart"]})
	var shot: = func(n: String):
		await get_tree().create_timer(0.5, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, n])
	world.menus._run_class = "super_novice"
	world.menus.show_sn_build( func(): world.menus.show_prep("prontera"))
	await shot.call("1_build")
	var sc: ScrollContainer = world.menus._root.find_children("*", "ScrollContainer", true, false)[0]
	sc.scroll_vertical = 300
	await get_tree().create_timer(0.3, true, false, true).timeout
	print("SNSCROLL before: ", sc.scroll_vertical)
	world.menus._sn_toggle("blessing", false)
	await get_tree().create_timer(0.4, true, false, true).timeout
	sc = world.menus._root.find_children("*", "ScrollContainer", true, false)[0]
	print("SNSCROLL after toggle: ", sc.scroll_vertical, " (was 300)")
	world.menus._sn_toggle("tracking", false)
	await shot.call("2_conflict")
	for i in 3:
		var r: Dictionary = world.menus._sn_random()
		print("SNRANDOM ", r.skills.size(), "/", r.passives.size(), " ammo=", GameData.sn_ammo(r.skills + r.passives), " ", r)
	Save.set_sn_build(world.menus._sn_random())
	world.menus.show_sn_build( func(): world.menus.show_prep("prontera"))
	await shot.call("2b_random")
	world.menus.show_prep("prontera")
	await shot.call("3_prep")

	world.menus.show_prep("prontera")
	world.start_run("super_novice")
	await get_tree().create_timer(0.8, true, false, true).timeout
	world.menus.close()
	world.player.pending_levels = 1
	world.menus.show_level_up(world.player.offered_choices())
	await get_tree().create_timer(1.0, true, false, true).timeout
	var hcs: = world.get_children().filter( func(n): return n is HoverCard)
	for c in world.menus._cards:
		var icons: Array = c.find_children("*", "TextureRect", true, false).filter( func(t): return t.has_meta("hover"))
		if not icons.is_empty() and not hcs.is_empty():
			hcs[0].test_target = icons[0]
			break
	await shot.call("7_levelup_hover")
	if not hcs.is_empty():
		hcs[0].test_target = null
	world.menus._grace = 0.0
	world.menus._pick(0)
	await get_tree().create_timer(0.1, true, false, true).timeout
	await shot.call("8_pick")
	world.abandon_run()
	get_tree().paused = false
	world.menus.show_char_make("super_novice")
	await shot.call("4_make")
	var look: = Save.look("super_novice").duplicate()
	look["cloth"] = 12
	look["gender"] = "f"
	Save.set_look("super_novice", look)
	world.menus.show_char_make("super_novice")
	await shot.call("5_make_dye")
	world.menus.show_class_select("super_novice")
	await shot.call("6_select")
	get_tree().quit()





func _monkcombo_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	GameData.set_meta("no_spawn", true)
	await get_tree().create_timer(1.0, true, false, true).timeout
	Save.data.rebirths["acolyte"] = 1
	world.set_stage("prontera")
	world.start_run("acolyte")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.3, true, false, true).timeout
	var p: Player = world.player
	p.level = 30
	p.job_change(1)
	print("COMBO job=%s skills=%s spheres_max=%d" % [p.job2.id, p.skills.keys(), p.sphere_max])
	var offered: = []
	for i in 30:
		p.offer = []
		for c in p.build_choices():
			if not offered.has(c.id):
				offered.append(c.id)
	print("COMBO offered without the steps: chain_combo=%s combo_finish=%s chain_crush=%s asura=%s call_spirits=%s" % [
		offered.has("chain_combo"), offered.has("combo_finish"), offered.has("chain_crush"), offered.has("asura_strike"), offered.has("call_spirits")])
	for id in ["chain_combo", "combo_finish", "chain_crush"]:
		for k in 5:
			p.add_skill(id)
	for k in 4:
		p.add_skill("triple_attack")
	p.recompute()
	p.max_hp = 99999.0
	p.hp = p.max_hp
	world._cam_distance = 16.0

	for i in 24:
		var a: = TAU * i / 24.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * (1.4 + (i % 3) * 0.8), true)
		if e != null:
			e.speed = 0.0
			e.max_hp = 30.0
			e.hp = e.max_hp
	await get_tree().create_timer(0.3, true, false, true).timeout
	var tgt: = world.nearest_enemy(p.position, 5.0)
	print("COMBO target=%s running=%s valid=%s busy=%s" % [tgt, world.running, world.hero_valid(p), p._combo_busy])
	world.monk_combo(p, tgt)
	for i in 16:
		await get_tree().create_timer(0.2, true, false, true).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/combo_%02d.png" % [dir, i])
	var top: = []
	for r in world.meter_sorted().slice(0, 8):
		top.append("%s=%d" % [r.tag, roundi(r.dmg)])
	print("COMBO meter=%s" % [top])
	get_tree().quit()




func _fxsheet_test(dir: String, list: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	await get_tree().create_timer(0.8, true, false, true).timeout
	var p: Player = world.player
	for fx in list.split(","):
		var e: = RoEffect.spawn(world.fx_root, fx, p.position, 1.0, p)
		if e != null:
			e.loop = true
		for k in 3:
			await get_tree().create_timer(0.35, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [dir, fx, k])
		if e != null and is_instance_valid(e):
			e.queue_free()
	get_tree().quit()





func _tower_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])

	GameData.set_meta("no_spawn", true)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var p: Player = world.player
	p.job_change(0)
	for id in ["bash", "magnum_break", "bowling_bash", "brandish_spear"]:
		for k in 5:
			p.add_skill(id)
	p.level = 60
	p.recompute()
	Save.add_tower_build(RunSave.hero_snapshot(world))
	print("TOWERTEST builds=%d" % Save.tower_builds().size())
	world.abandon_run()
	GameData.remove_meta("no_spawn")
	await wait.call(0.5)
	world.menus.show_server_select()
	await wait.call(1.5)
	await snap.call("00_worldmap")
	world.enter_town("swordsman", "tower_gate")
	await wait.call(4.0)
	await snap.call("01_gate")
	var guide: = world.town.npc_node("tower")
	if guide != null:
		world.town.hero.position = guide.position + Vector3(-1.5, 0, 1.0)
		world.place_camera(world.town.hero.position)
	await wait.call(1.0)
	await snap.call("01_gate_npc")
	world.menus.show_tower()
	await wait.call(0.8)
	await snap.call("02_lucile")
	world.menus._tower_confirm(Save.tower_builds()[0], 0, 1)
	await wait.call(0.8)
	await snap.call("02b_confirm")
	world.start_tower(0, 1)
	world.menus.auto_pick = true
	await wait.call(3.0)
	await snap.call("03_floor1")
	print("TOWERTEST floor=%d state=%s builds_left=%d map=%s" % [world.tower.floor, world.tower.state, Save.tower_builds().size(), world.map.map_name])

	var t: = world.tower
	var stairs_shot: = false
	for k in 60:
		await wait.call(0.5)

		if t.state == "climb" and t._stairs_at != Vector3.INF:
			if not stairs_shot:
				stairs_shot = true
				await wait.call(0.6)
				await snap.call("03b_stairs")
			world.player.position = t._stairs_at
		if t.state == "fight":
			t.need = 1
			for e in world.enemies.duplicate():
				if not e.is_boss:
					world.damage_enemy(e, 1000000000.0)
					break
		if world.player != null:
			world.player.hp = world.player.max_hp
		if t.floor == 4 and t.state in ["rest", "climb"]:
			t.floor = 10
		if t.floor >= 10 and t.state == "boss":
			break
	print("TOWERTEST reached floor=%d state=%s raid=%s top=%d power=%.2f checkpoints=%s" % [t.floor, t.state, world.raid.state, Save.tower_top(), Save.tower_power(), Save.tower_checkpoints()])
	await wait.call(1.0)
	await snap.call("04_floor10")

	world.raid.leave()
	await wait.call(0.5)
	world.menus.auto_pick = false
	t.floor = 20
	t.state = "boss"
	t._cleared()
	await wait.call(1.2)
	await snap.call("05_camp")
	if t._lucile != null:
		world.player.position = t._lucile.position + Vector3(1.0, 0, 0)
	await wait.call(1.0)
	await snap.call("06_camp_talk")
	print("TOWERTEST camp state=%s mode=%s" % [t.state, world.menus.mode()])

	world.menus.close()
	get_tree().paused = false
	world.altars.spawn("emperium", world.player.position + Vector3(2, 0, 0))
	await wait.call(0.3)
	var emp: Dictionary = world.altars.waiting.back()
	world.altars.waiting.erase(emp)
	world.altars._accept(emp)
	await wait.call(1.0)
	print("TOWERTEST emperium enemies=%d" % world.enemies.size())
	await snap.call("07_emperium")
	get_tree().quit()




func _pin_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	world.enter_town("swordsman")
	await wait.call(2.0)
	world.town.hero.position = world.town._at(Vector2i(156, 180))
	world.place_camera(world.town.hero.position)
	await wait.call(0.8)
	await snap.call("00_town")

	var shows: = {"01_sage": world.menus.show_sage, "02_refiner": world.menus.show_refiner, "03_kafra": world.menus.show_kafra, 
		"04_chef": world.menus.show_chef, "05_pacts": world.menus.show_pacts.bind("swordsman"), "06_socket": world.menus.show_socket, 
		"07_tower": world.menus.show_tower}
	for key in shows:
		shows[key].call()
		await wait.call(0.8)
		await snap.call(key)
		world.menus.close()

	var find_pin: = func() -> Button:
		for b in world.menus.find_children("*", "Button", true, false):
			if b.has_meta("tower_pin") and b.is_inside_tree() and not b.is_queued_for_deletion():
				return b
		return null
	Save.set_setting("tower_unlocked", false)
	var had: int = Save.max_danger()
	Save.data["max_danger"] = 1
	world.menus.show_server_select("swordsman")
	await wait.call(1.5)
	var pin: Button = find_pin.call()
	pin.pressed.emit()
	await wait.call(0.4)
	await snap.call("09_pin_locked")
	print("PINTEST locked open=%s" % Save.tower_open())
	Save.data["max_danger"] = maxi(had, GameData.TOWER_UNLOCK_DANGER)
	world.menus.show_server_select("swordsman")
	await wait.call(1.5)
	await snap.call("10_pin_ready")
	pin = find_pin.call()
	pin.pressed.emit()
	await wait.call(0.5)
	await snap.call("11_pin_opened")
	print("PINTEST opened open=%s" % Save.tower_open())
	await wait.call(1.0)
	pin = find_pin.call()
	print("PINTEST pin=%s" % (pin != null))

	pin.pressed.emit()
	await wait.call(0.8)
	await snap.call("12_tower_side")
	var ws: WorldSelect = null
	for n in world.menus.find_children("*", "", true, false):
		if n is WorldSelect:
			ws = n
	print("PINTEST side region=%s" % ws.region)
	ws._toggle_records()
	await wait.call(2.5)
	await snap.call("13_tower_board")
	ws._go_tower()
	await wait.call(5.0)
	print("PINTEST town=%s place=%s map=%s mode=%s" % [world.town != null, world.town.place if world.town != null else "-", 
		world.map.map_name, world.menus._mode])

	for y in range(84, 112, 2):
		var row: = ""
		for x in range(66, 88):
			row += "#" if world.map.is_walkable(world.map.cell_center(x, y)) else "."
		print("PINTEST y=%d %s" % [y, row])
	await snap.call("08_gate")
	get_tree().quit()




func _tower_art(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	world.menus.close()
	world.hud.hide()
	for m in ["6@tower", "1@tower", "e_tower"]:
		world._load_map(m)
		var at: Vector3 = world.raid._find_open(world.map, 14.0)[0]
		at.y = world.map.height_at(at)
		for d in [22.0, 34.0]:
			world.place_camera(at, d)
			await get_tree().create_timer(1.2, true, false, true).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/%s_%d.png" % [dir, m, int(d)])
	get_tree().quit()



func _tower_build() -> int:
	GameData.set_meta("no_spawn", true)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var p: Player = world.player
	p.job_change(0)
	for id in ["bash", "magnum_break", "bowling_bash", "brandish_spear"]:
		for k in 5:
			p.add_skill(id)
	p.level = 80
	p.recompute()
	Save.add_tower_build(RunSave.hero_snapshot(world))
	world.abandon_run()
	GameData.remove_meta("no_spawn")
	return Save.tower_builds().size() - 1





func _climb_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	GameData.set_meta("tour_god", true)
	world.start_tower(_tower_build(), 22)
	world.menus.auto_pick = true
	var t: = world.tower
	var shot: = {}
	for k in 160:
		await wait.call(0.25)
		if t.state == "fight":
			if t.rule != "" and not shot.has("rule"):
				shot["rule"] = true
				await wait.call(0.6)
				print("CLIMBTEST floor=%d rule=%s need=%d" % [t.floor, t.rule, t.need])
				await snap.call("01_rule_%s" % t.rule)
			t.need = 1
			for e in world.enemies.duplicate():
				if not e.is_boss:
					world.damage_enemy(e, 1000000000000.0)
					break

		if t.floor == 26 and not shot.has("bless"):
			shot["bless"] = true
			world.menus.auto_pick = false
			await wait.call(1.4)
			await snap.call("02_blessing")
			print("CLIMBTEST blessing mode=%s" % world.menus._mode)
			if world.menus._mode == "tower_bless":
				world.menus._grace = 0.0
				world.menus._resume()
				t.take_blessing(world.player, "might")
			world.menus.auto_pick = true
		if t.floor == 27 and t.state == "fight" and not shot.has("map"):
			shot["map"] = true
			await wait.call(0.8)
			print("CLIMBTEST floor=%d map=%s blessings=%s dmg_mods=%s" % [t.floor, world.map.map_name, t.blessings, world.player.tower_mods])
			await snap.call("03_map2")
			break
	get_tree().quit()




func _fists_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	var snap: = func(name: String) -> void :
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	print("FISTS scaling ", [GameData.skill_scaling("tornado_kick"), GameData.skill_scaling("gospel"), GameData.skill_scaling("mammonite"), 
		GameData.support_scaling("kaite"), GameData.support_scaling("kaite_x"), GameData.gear_scaling(GameData.ITEMS.fists), 
		GameData.gear_scaling(GameData.ITEMS.star_blessing), GameData.gear_scaling(GameData.ITEMS.santa_hat), GameData.gear_scaling(GameData.ITEMS.sword)])
	for path in [-1, 0, 1]:
		world.start_run("taekwon")
		world.menus.close()
		get_tree().paused = false
		var p: Player = world.player
		p.level = 60
		if path >= 0:
			p.job_change(path)
		p.recompute()
		var eq: Equipment = p.equipment
		var w: Dictionary = eq.slots.weapon
		var drops: = {}
		for i in 800:
			var it: = eq.roll_item(1800.0, 2)
			if Equipment.item_type(it) == "weapon":
				drops[str(it.id)] = int(it.slots)
		print("FISTS job=%s weapon=%s slots=%d legendary=%s perm=%s sell=%s dmg=%.2f weapons=%s unique=%s" % [eq.job_id, w.id, Equipment.sockets(w), 
			Equipment.is_legendary(w), Equipment.is_perm(w), Equipment.can_sell(w), p.dmg_mult, drops, GameData.unique_of_stage("thanatos", eq.job_id)])
		eq.slots.weapon = Equipment.make("club", 1)
		p.recompute()
		print("FISTS old club -> %s bag=%s" % [eq.slots.weapon.id, eq.bag.map( func(b): return b.id)])
		eq.bag.clear()
		world.menus.show_equipment("weapon")
		await get_tree().create_timer(0.7, true, false, true).timeout
		await snap.call("equip_%d" % (path + 1))
		world.menus.close()
		get_tree().paused = false
		if path == 1:

			var mob: Enemy = world.spawn_enemy("poring", p.position + Vector3(2.0, 0, 0), true)
			mob.max_hp = 1000000000.0
			mob.hp = 1000000000.0
			var crowd: Enemy = world.spawn_enemy("poring", p.position + Vector3(2.4, 0, 1.0), false)
			crowd.max_hp = 1000000000.0
			crowd.hp = 1000000000.0
			crowd.speed = 0.0
			var twin: Enemy = world.spawn_enemy("poring", p.position + Vector3(2.4, 0, -1.8), false)
			twin.max_hp = 1000000000.0
			twin.hp = 1000000000.0
			twin.speed = 0.0
			await get_tree().create_timer(0.4, true, false, true).timeout
			Skills.cast(world, p, "eswoo", 5)
			await get_tree().create_timer(0.8, true, false, true).timeout
			print("FISTS eswoo sizes ", [crowd.visual.size if crowd.visual is MobAnim else "own", twin.visual.size if twin.visual is MobAnim else "own"])
			await snap.call("eswoo")
			for id in ["book_gust", "book_earth", "book_sun", "book_dragon", "book_billows"]:
				eq.slots.weapon = Equipment.make(id, 0)
				p.recompute()
				for k in p.powers.keys():
					if str(k).begins_with("spirit_"):
						p.powers.erase(k)
				p.shield = 0.0
				mob.taunt_vuln = 0.0
				for skill in ["soul_link", "kaite", "eswoo", "esma"]:
					Skills.cast(world, p, skill, 5)
				await get_tree().create_timer(0.3, true, false, true).timeout
				await snap.call("sl_" + id)
				await get_tree().create_timer(0.6, true, false, true).timeout
				var spirits: Array = p.powers.keys().filter( func(k): return str(k).begins_with("spirit_"))
				print("FISTS %s spirits=%d time=%.1f shield=%d vuln=%.2f seek=%s" % [id, spirits.size(), float(p.powers[spirits[0]]) if not spirits.is_empty() else 0.0, 
					p.shield, mob.taunt_vuln, Skills.best_element([mob])])
		world.abandon_run()
		await get_tree().create_timer(0.4, true, false, true).timeout
	get_tree().quit()




func _charge_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var p: Player = world.player
	p.job_change()
	p.add_skill("charge_attack")
	GameData.set_meta("tour_god", true)
	await get_tree().create_timer(0.5, true, false, true).timeout
	var at: Vector3 = p.position + Vector3(8.0, 0, 0)
	var e: Enemy = world.spawn_enemy("poring", at, true)
	e.max_hp = 1000000000.0
	e.hp = 1000000000.0
	var snap: = func(name: String) -> void :
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	Engine.time_scale = 0.2
	Skills.cast(world, p, "charge_attack", 5)
	await get_tree().create_timer(0.1, true, false, true).timeout
	await snap.call("charge_0")
	for i in 8:
		await get_tree().create_timer(0.3, true, false, true).timeout
		await snap.call("charge_%d" % (i + 1))
	Engine.time_scale = 1.0
	world.skill_switch(p.f_skill(), true)
	print("CHARGETEST f=%s off=%s" % [p.f_skill(), p.is_off("charge_attack")])
	get_tree().quit()






func _naght_test(dir: String, mode: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])


	var auto: = mode.begins_with("auto")
	if mode != "auto":
		GameData.set_meta("tour_god", true)

	world.start_tower(_tower_build(), 100, mode == "hel")
	if mode == "hel" and world.tower != null:
		world.tower.floor = 100
	world.menus.auto_pick = true
	var raid: = world.raid
	while raid.state != "portal":
		await wait.call(0.2)
	await wait.call(1.0)
	await snap.call("00_portal")
	world.player.position = raid.portal_pos
	var talk_t0: = Time.get_ticks_msec()
	await wait.call(3.5)
	await snap.call("00_talk")
	await wait.call(3.5)
	await snap.call("00_talk2")
	print("NAGHTTEST on the portal sealed=%s state=%s" % [raid.portal_sealed, raid.state])
	while raid.state != "intro" and raid.state != "fight":
		await wait.call(0.2)
	print("NAGHTTEST let in after %.1f s" % ((Time.get_ticks_msec() - talk_t0) / 1000.0))
	await wait.call(1.0)
	await snap.call("01_hall")
	while raid.state != "fight":
		await wait.call(0.2)
	await wait.call(1.2)
	await snap.call("02_naght")
	var boss: = raid.boss
	print("NAGHTTEST boss hp=%d dmg=%d radius=%.1f" % [boss.max_hp, boss.damage, raid.radius])
	if auto:
		world.autopilot = true
		if mode == "autogod":

			boss.max_hp /= 3000.0
			boss.hp = boss.max_hp
		var t0: = 0.0
		while raid.state == "fight" and world.running and t0 < 900.0:
			await wait.call(1.0)
			t0 += 1.0
		print("NAGHTTEST auto t=%d state=%s boss=%d%% hp=%d/%d fails=%d phase=%d" % [t0, raid.state, 
			roundi(100.0 * boss.hp / boss.max_hp) if is_instance_valid(boss) else -1, world.player.hp, world.player.max_hp, 
			raid.stats.fails, raid.phase + 1])
		get_tree().quit()
		return

	await wait.call(4.0)
	await snap.call("03_p1")
	for ab_id in ["starfall"]:
		raid._cast = {}
		world.fx_layer(GameData.MVP_FX_PRIORITY)
		raid._start(_ab(raid, ab_id))
		world.fx_layer(0)
		await wait.call(1.6)
		await snap.call("04_%s" % ab_id)
		await wait.call(3.0)
	boss.hp = boss.max_hp * 0.74
	await wait.call(4.0)
	await snap.call("05_p2_ice")
	raid._cast = {}
	world.fx_layer(GameData.MVP_FX_PRIORITY)
	raid._start(_ab(raid, "lances"))
	world.fx_layer(0)
	await wait.call(1.0)
	await snap.call("06_lances")
	await wait.call(4.0)
	boss.hp = boss.max_hp * 0.49
	await wait.call(3.0)
	await snap.call("07_intermission")
	print("NAGHTTEST inter state=%s echoes=%d" % [raid.epic.state, raid.epic._echoes.size()])
	for e in raid.epic._echoes.duplicate():
		world.damage_enemy(e, 1e+15)
	await wait.call(2.5)
	await snap.call("08_crash")
	print("NAGHTTEST after inter state=%s vuln=%.1f in_enemies=%s" % [raid.epic.state, raid.epic.vuln, world.enemies.has(boss)])
	await wait.call(2.0)
	for ab_id in ["twin_sweep", "brand"]:
		raid._cast = {}
		raid._objects = raid._objects.filter( func(o): return not o.get("solo", false))
		world.fx_layer(GameData.MVP_FX_PRIORITY)
		raid._start(_ab(raid, ab_id))
		world.fx_layer(0)
		await wait.call(2.4)
		await snap.call("09_%s" % ab_id)
		await wait.call(5.0)
	boss.hp = boss.max_hp * 0.24
	await wait.call(6.0)
	await snap.call("10_p4_night")
	print("NAGHTTEST p4 radius=%.1f phase=%d" % [raid.radius, raid.phase])
	world.damage_enemy(boss, 1e+18)
	await wait.call(2.5)
	await snap.call("11_won")
	print("NAGHTTEST won state=%s mvps=%d" % [raid.state, world.run_mvps])
	await wait.call(4.0)
	await snap.call("12_won_b")

	var cls: = world.player.class_id
	world.player.equipment.bag.clear()
	print("NAGHTTEST wings chest=%s due=%s" % [world.pickups.any( func(p): return str(p.get("unique", "")) == GameData.TOWER_WINGS), world._wings_due(world.player)])
	world._wings_got(world.player)
	print("NAGHTTEST wings again due=%s classes=%s" % [world._wings_due(world.player), Save.tower_wings()])
	Save.tower_wings().erase(cls)
	print("NAGHTTEST wings other class due=%s" % world._wings_due(world.player))
	get_tree().quit()


func _ab(raid: MvpRaid, id: String) -> Dictionary:
	for ab in raid.data.abilities:
		if ab.id == id:
			return ab
	return {}






func _face_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	for pair in [["sunglasses", 3, "mid"], ["angel_kiss", 0, "low"]]:
		Save.add_to_storage(Equipment.make(pair[0], pair[1]))
		Save.set_loadout_slot("swordsman", pair[2], str(Save.storage().back().uid))
	print("FACETEST pieces=%d of %d slots" % [Save.loadout_pieces("swordsman"), Save.loadout("swordsman").size()])
	world.menus.show_loadout("swordsman")
	await wait.call(0.8)
	await snap.call("00_loadout")
	GameData.set_meta("no_spawn", true)
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	var p: Player = world.player
	print("FACETEST run revives=%d str_pct=%.2f all=%.2f vs_mvp=%.2f mid=%s low=%s" % [p.revives, float(p.stat_pct.str), float(p.stat_pct.luk), 
		p.vs_mvp, p.equipment.slots.mid.id if p.equipment.slots.mid != null else "-", p.equipment.slots.low.id if p.equipment.slots.low != null else "-"])
	world.place_camera(p.position)
	await wait.call(1.0)
	await snap.call("01_hero")
	world.menus.show_equipment("mid")
	await wait.call(0.8)
	await snap.call("02_equip")
	world.menus.close()
	get_tree().paused = false
	Save.add_tower_build(RunSave.hero_snapshot(world))
	world.abandon_run()
	GameData.remove_meta("no_spawn")
	await wait.call(0.5)
	world.start_tower(Save.tower_builds().size() - 1, 1)
	world.menus.auto_pick = true
	await wait.call(1.0)
	p = world.player
	print("FACETEST tower revives=%d mid=%s low=%s" % [p.revives, p.equipment.slots.mid.id if p.equipment.slots.mid != null else "-", 
		p.equipment.slots.low.id if p.equipment.slots.low != null else "-"])

	var before: = Save.storage().size()
	world.menus.auto_pick = false
	world.tower._face_drop(7)
	await wait.call(1.6)
	await snap.call("03_drop")
	print("FACETEST drop stored=%d" % (Save.storage().size() - before))


	var eq: Equipment = world.player.equipment
	for i in range(eq.bag.size() - 1, -1, -1):
		if Equipment.found_face(eq.bag[i]):
			print("FACETEST sold z=%d left in storage=%d" % [eq.sell_from_bag(i), Save.storage().size() - before])
	print("FACETEST worn can_sell=", Equipment.can_sell(eq.slots.mid))
	get_tree().quit()




func _fetch_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	Save.add_pet("poring")
	Save.set_active_pet("poring")
	Save.set_pet_skin("poring")
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
	for on in [true, false]:
		Save.set_setting("pet_fetch", on)
		world.start_run("swordsman")
		world.menus.close()
		get_tree().paused = false
		var p: Player = world.player
		await get_tree().create_timer(0.6, true, false, true).timeout
		var at: = world.map.find_point_around(p.position, 34.0, 38.0)
		world._drop_chest(at, 1, 0)
		var chest: Dictionary = world.pickups.back()
		print("FETCH on=%s pet=%s dist=%.1f" % [on, world.pet_of(p) != null, at.distance_to(p.position)])
		for k in 24:
			await get_tree().create_timer(0.25, true, false, true).timeout
			if k == 3 and on:
				await snap.call("fetch_mid")
			print("FETCH t=%.2f phase=%s left=%s mode=%s" % [k * 0.25, str(chest.get("fetch", "-")), world.pickups.has(chest), world.menus.mode()])
		world.menus.close()
		world.abandon_run()
		get_tree().paused = false
		await get_tree().create_timer(0.3, true, false, true).timeout
	get_tree().quit()





func _legends_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	var shots: = [0]
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, shots[0], name])
		shots[0] += 1

	var cases: = [["swordsman", -1, "mysteltainn", "bash", false], ["mage", -1, "mighty_staff", "fire_wall", false], 
		["archer", -1, "ballista", "double_strafe", true], ["acolyte", -1, "quadrille", "heal", false], 
		["merchant", -1, "golden_axe", "mammonite", false], ["thief", 1, "ginnungagap", "back_stab", true], 
		["thief", 1, "ginnungagap", "back_stab_x", true], 
		["ninja", -1, "murasame", "throw_shuriken", false], ["gunslinger", -1, "crimson_bolt", "tracking", false], 
		["taekwon", -1, "survivors_rod", "flying_kick", false], ["acolyte", 1, "berserk_knuckle", "triple_attack", false]]
	for c in cases:
		var out: = []
		for armed in [false, true]:
			world.start_run(str(c[0]))
			world.menus.close()
			world.menus.auto_pick = true
			get_tree().paused = false
			var p: Player = world.player
			if int(c[1]) >= 0:
				p.job_change(int(c[1]))
			for id in p.skills.keys():
				p.skills.erase(id)
			var sid: String = c[3]
			for k in GameData.skill_cap(sid):
				p.add_skill(sid)
			if sid == "throw_shuriken":
				p.add_skill("mirror_image")
				p.make_mirrors(world, 3)

			if sid == "triple_attack":
				for cid in ["chain_combo", "combo_finish"]:
					for k in GameData.skill_cap(cid):
						p.add_skill(cid)
			if armed:
				p.equipment.slots["weapon"] = Equipment.make(str(c[2]), 0)
			p.recompute()
			get_tree().process_frame.connect( func():
				if is_instance_valid(p):
					p.hp = p.max_hp
					p.spheres = 5)
			world.meter.clear()
			if bool(c[4]):
				var e: = world.spawn_enemy("poring", p.position + Vector3(3.0, 0, 0.5), true)
				if e != null:
					e.max_hp = 100000000.0
					e.hp = 100000000.0
					e.speed = 0.0
			else:
				for i in 24:
					var a: = TAU * i / 24.0
					var e: = world.spawn_enemy("poring" if i % 2 == 0 else "lunatic", p.position + Vector3(cos(a), 0, sin(a)) * randf_range(1.5, 6.0), true)
					if e != null:
						e.speed = 0.0
						e.max_hp = 400.0
						e.hp = 400.0
				if sid == "heal":
					p.hp = p.max_hp
			world.run_zeny = 3000
			var t0: = world.time
			for k in 8:
				await get_tree().create_timer(0.5, true, false, true).timeout
				if k == 5 and armed:
					await snap.call(str(c[2]))
			var dmg: = 0.0
			var kills: = 0
			for m in world.meter_sorted():
				dmg += float(m.dmg)
				kills += int(m.get("kills", 0))
			out.append("%s dmg=%d kills=%d" % ["CON" if armed else "sin", roundi(dmg), kills])
			world.abandon_run()
			get_tree().paused = false
			await get_tree().create_timer(0.3, true, false, true).timeout
		print("LGTEST %s %s: %s" % [c[2], c[3], " | ".join(out)])
	get_tree().quit()





func _navrail_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var n: = [0]
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, n[0], name])
		n[0] += 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var m = world.menus
	m.show_class_select("swordsman")
	await wait.call(1.0)
	print("RAILTEST select mode=%s rail=%s key=%s town=%s running=%s" % [m._mode, m._rail != null and is_instance_valid(m._rail), m._rail_key, world.town, world.running])
	if m._rail != null and is_instance_valid(m._rail):
		print("RAILTEST rail pos=%s size=%s vis=%s idx=%d root_idx=%d" % [m._rail.position, m._rail.size, m._rail.is_visible_in_tree(), m._rail.get_index(), m._root.get_index()])
		for c in m.get_children():
			print("RAILTEST child %s %s" % [c.name, c.get_class()])
		for cl in get_tree().root.find_children("*", "CanvasLayer", true, false):
			print("RAILTEST layer %s %d vis=%s" % [cl.get_path(), cl.layer, cl.visible])
	await snap.call("select")
	m.show_album()
	await wait.call(1.0)
	await snap.call("album")
	m.show_char_make("swordsman")
	await wait.call(1.0)
	await snap.call("profile")
	m.show_loadout("swordsman")
	await wait.call(1.0)
	await snap.call("gear")
	print("RAILTEST mode=%s rail=%s" % [m._mode, m._rail != null and is_instance_valid(m._rail)])
	get_tree().quit()




func _frenzybtn_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var n: = [0]
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, n[0], name])
		n[0] += 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	for sp in [1, 2, 3]:
		world.speed = sp
		world.menus.show_server_select("swordsman")
		await wait.call(0.8)
		await snap.call("map_%d" % sp)
	var ws = world.menus.find_children("*", "WorldSelect", true, false)
	if not ws.is_empty():
		ws[0]._select_region(ws[0].TOWER)
		await wait.call(0.8)
		await snap.call("tower")
	get_tree().quit()





func _buyclass_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var n: = [0]
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, n[0], name])
		n[0] += 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var locked: Array = GameData.CLASSES.keys().filter( func(id): return not Save.class_unlocked(id))
	if locked.is_empty():
		print("BUYTEST no locked class")
		get_tree().quit()
		return
	var id: String = locked[0]
	Save.add_zeny(int(GameData.CLASSES[id].unlock_cost) * 2)
	world.menus.show_class_select(id)
	await wait.call(1.0)
	await snap.call("locked")
	var cs = world.menus.find_children("*", "RoCharSelect", true, false)
	var sel = cs[0] if not cs.is_empty() else null
	if sel != null:
		sel._try_play(id)
		await wait.call(0.4)
		await snap.call("asked")

		sel._close_buy()
		sel._buy_selected()
		await wait.call(0.4)
		await snap.call("bought")
	print("BUYTEST %s unlocked=%s" % [id, Save.class_unlocked(id)])
	get_tree().quit()





func _wings_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shots: = [0]
	var snap: = func(name: String) -> void :
		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, shots[0], name])
		shots[0] += 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	Save.data.rebirths["swordsman"] = 1
	Save.data["classes"] = {"swordsman": {"level": 20, "xp": 0, "stats": {}, "rlv": 3}, 
		"archer": {"level": 7, "xp": 0, "stats": {}, "rlv": 10}}
	Save.data.erase("wing_feathers_spent")
	Save.add_to_storage({"id": GameData.TOWER_WINGS, "slots": 0}, true)
	Save.add_to_storage({"id": GameData.TOWER_WINGS, "slots": 0}, true)
	var wings: Array = Save.storage().filter( func(st): return str(st.id) == GameData.TOWER_WINGS)
	var uid: = str(wings[0].uid)
	wings[0]["extra_slots"] = 1
	wings[0]["cards"] = ["baphomet_card"]
	Save.set_loadout_slot("swordsman", "wings", uid)
	print("WINGTEST feathers=%d (13 expected)" % Save.wing_feathers())
	world.enter_town("swordsman")
	await wait.call(4.0)
	world.menus.show_valkyrie_talk()
	await wait.call(0.6)
	await snap.call("talk")
	world.menus.show_valkyrie_wings()
	await wait.call(0.6)
	await snap.call("wings_0")

	Save.refine_wings(uid)
	world.menus._back_to_hub()
	world.town.wings_ceremony(1)
	for t in [0.4, 0.5, 0.4, 0.5]:
		await wait.call(t)
		await snap.call("ceremony")
	await wait.call(1.6)
	await snap.call("wings_1_back")
	var ok: = 1
	for i in 12:
		if Save.refine_wings(uid):
			ok += 1
	world.menus._wing_pick = ""
	print("WINGTEST refined=%d refine=%d feathers=%d" % [ok, int(Save.storage_item(uid).refine), Save.wing_feathers()])
	world.menus.show_valkyrie_wings()
	await wait.call(0.6)
	await snap.call("wings_10")
	world.menus._back_to_hub()
	world.start_run("swordsman")
	world.menus.close()
	get_tree().paused = false
	await wait.call(1.0)
	var p: Player = world.player
	var w = p.equipment.slots.get("wings")
	p.stats["str"] = int(p.base_stats.get("str", 0)) + 19
	if w != null:
		w.cards = ["baphomet_card"]
	p.recompute()
	var area: = float(Equipment.item_mods(w).get("area", 0.0)) if w != null else -1.0
	print("WINGTEST run wings=%s refine=%d sockets=%d cap=%.0f str_eff=%.1f (19 full) baph_area=%.4f (0.25 x1.3) fx=%s" % [w != null, 
		int(w.refine) if w != null else -1, Equipment.sockets(w) if w != null else -1, p.stat_cap, p.eff_stat("str"), area, 
		GameData.wing_fx(10)])

	var boss: = world.spawn_enemy(GameData.STAGES[world.stage_id].mvp, p.position + Vector3(4, 0, 0)) if world.has_method("spawn_enemy") else null
	if boss != null:
		boss.is_boss = true
		for id in p.skills:
			p.skills[id].cd = 10.0
		world.damage_by = p
		for i in 40:
			world.stagger.add(world, boss, 5.0)
			if boss.status == "stun":
				break
			world.clock += 0.6
		var cds: = []
		for id in p.skills:
			if GameData.SKILLS[id].type != "passive":
				cds.append("%s=%.1f" % [id, float(p.skills[id].cd)])
		print("WINGTEST break status=%s stun_left=%.2f (3.5 expected) cds=%s" % [boss.status, boss.status_time, ", ".join(cds)])
	await wait.call(0.5)
	await snap.call("run")
	get_tree().quit()






func _rebirthlv_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout
	var shots: = [0]
	var snap: = func(name: String) -> void :

		if DisplayServer.get_name() == "headless":
			return
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, shots[0], name])
		shots[0] += 1
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	var top: = GameData.REBIRTH_CLASS_MAX_LEVEL
	Save.data.rebirths["swordsman"] = 1
	Save.data["classes"] = {
		"swordsman": {"level": top, "xp": 0, "stats": {"str": 20}, "rlv": 3}, 
		"gunslinger": {"level": 12, "xp": 0, "stats": {}, "rlv": 10}, 
		"archer": {"level": 7, "xp": 0, "stats": {}}}
	Save.data.rebirths["archer"] = 1
	Save.data.classes.archer["rlv"] = 6
	if not Save.data.has("unlocked"):
		Save.data["unlocked"] = {}
	Save.data.unlocked["gunslinger"] = true
	print("RLVTEST ready sw=%s gs=%s points sw=%d need sw lv1=%d climb=%d" % [Save.rebirth_lv_ready("swordsman"), Save.rebirth_lv_ready("gunslinger"), 
		Save.free_points("swordsman"), Save.class_xp_need("swordsman", 1), Save.class_climb_xp("swordsman")])
	world.menus.show_class_select("swordsman")
	for i in 2:
		await wait.call(0.7)
		await snap.call("select")
	world.menus.show_class_select("gunslinger")
	await wait.call(0.8)
	await snap.call("select_gs")

	world.enter_town("swordsman")
	await wait.call(5.0)
	await snap.call("town_call")
	await wait.call(0.8)
	await snap.call("town_call")
	world.menus.show_rebirth_lv("swordsman")
	await wait.call(0.8)
	await snap.call("valkyrie")
	print("RLVTEST take=%s rlv=%d lv=%d points=%d" % [Save.take_rebirth_lv("swordsman"), Save.rebirth_lv("swordsman"), 
		int(Save.class_progress("swordsman").level), Save.free_points("swordsman")])
	world.menus._back_to_hub()
	world.town.rebirth_lv_ceremony()
	for i in 4:
		await wait.call(0.55)
		await snap.call("ceremony")
	world.menus.show_rebirth_lv("swordsman")
	await wait.call(0.6)
	await snap.call("valkyrie_after")
	world.menus.show_loadout("swordsman")
	await wait.call(0.4)
	await snap.call("loadout")

	world.start_run("gunslinger")
	world.menus.close()
	get_tree().paused = false
	GameData.set_meta("no_spawn", true)
	await wait.call(1.0)
	await snap.call("run_still")
	Input.action_press("move_right")
	for i in 5:
		await wait.call(0.5)
		await snap.call("run_walk")
	Input.action_release("move_right")
	await wait.call(1.5)
	await snap.call("run_rays")
	var before: = int(Save.class_progress("gunslinger").level)
	var ups: = Save.add_class_xp("gunslinger", 99999999)
	print("RLVTEST cap: lv %d -> %d (+%d) share=%d" % [before, int(Save.class_progress("gunslinger").level), ups, 
		roundi(Save.class_climb_xp("gunslinger") * GameData.REBIRTH_LV_RUN_SHARE)])
	get_tree().quit()








func _songs_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	world.start_run("archer")
	world.menus.close()
	world.menus.auto_pick = true
	get_tree().paused = false
	var p: = world.player
	p.job_change(1)
	for id in ["dissonance", "poem_of_bragi", "assassin_cross_sunset"]:
		for k in 5:
			p.add_skill(id)
	p.recompute()
	for i in 14:
		var a: = TAU * i / 14.0
		var e: = world.spawn_enemy("poring", p.position + Vector3(cos(a), 0, sin(a)) * randf_range(2.0, 4.5), true)
		if e != null:
			e.max_hp = 10000000.0
			e.hp = 10000000.0
			e.speed = 0.0
	var last: = "-"
	for k in 48:
		await get_tree().create_timer(0.5, true, false, true).timeout
		if p.song != last:
			last = p.song
			print("SONG t=%.1f now=%s haste=%.2f aspd_bonus=%.2f" % [k * 0.5, p.song, p.cd_mult, p.aspd_bonus])
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("%s/song_%02d_%s.png" % [dir, k, p.song])
	print("SONG meter dissonance=", roundi(float(world.meter.get("dissonance", {}).get("dmg", 0.0))))
	get_tree().quit()





func _doram_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	var shots: = [0]
	var snap: = func(name: String) -> void :
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, shots[0], name])
		shots[0] += 1
	for stage in [["base", ["picky_peck", "scar_of_tarou", "silvervine_stem_spear", "catnip_meteor", "tuna_belly"], 
			["power_of_life", "power_of_land", "power_of_sea"]], 
			["job", ["arclouse_dash", "lunatic_carrot_beat", "silvervine_root_twist", "tuna_party", "bunch_of_shrimp", "picky_peck"], 
			["spirit_of_life", "spirit_of_land", "spirit_of_sea"]]]:
		world.start_run("doram")
		world.menus.close()
		world.menus.auto_pick = true
		get_tree().paused = false
		var p: = world.player
		if stage[0] == "job":
			p.job_change(0)
		for id in stage[1] + stage[2]:
			for k in 5:
				p.add_skill(id)
		p.recompute()
		get_tree().process_frame.connect( func():
			if is_instance_valid(p):
				p.hp = maxf(p.hp, p.max_hp * 0.5))
		for i in 18:
			var a: = TAU * i / 18.0
			var e: = world.spawn_enemy("poring" if i % 2 == 0 else "fabre", p.position + Vector3(cos(a), 0, sin(a)) * randf_range(2.5, 6.0), true)
			if e != null:
				e.max_hp = 10000000.0
				e.hp = 10000000.0
				e.speed = 0.4
		var boss: = world.spawn_enemy("poring", p.position + Vector3(5, 0, 0), true)
		if boss != null:
			boss.max_hp = 100000000.0
			boss.hp = 100000000.0
			boss.speed = 0.0
		p.hp = p.max_hp * 0.5
		for k in 14:
			await get_tree().create_timer(0.9, true, false, true).timeout
			await snap.call(str(stage[0]))
		print("DORAMTEST %s job=%s effects=%s" % [stage[0], p.job2.get("id", ""), p.effects])
		var top: = []
		for r in world.meter_sorted().slice(0, 10):
			top.append("%s=%d" % [r.tag, roundi(r.dmg)])
		print("DORAMTEST meter=", top)
	get_tree().quit()


func _taekwon_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.0, true, false, true).timeout
	GameData.set_meta("no_spawn", true)
	var shots: = [0]
	var snap: = func(name: String) -> void :
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("%s/%02d_%s.png" % [dir, shots[0], name])
		shots[0] += 1
	var crowd: = func(p: Player, n: int) -> void :
		for i in n:
			var a: = TAU * i / n
			var e: = world.spawn_enemy("poring" if i % 2 == 0 else "lunatic", p.position + Vector3(cos(a), 0, sin(a)) * randf_range(1.3, 3.2), true)
			if e != null:
				e.max_hp = 10000000.0
				e.hp = 10000000.0
				e.speed = 0.0
	for path in [-1, 0, 1]:
		world.start_run("taekwon")
		world.menus.close()
		world.menus.auto_pick = true
		get_tree().paused = false
		var p: = world.player
		get_tree().process_frame.connect( func():
			if is_instance_valid(p):
				p.hp = p.max_hp)
		crowd.call(p, 16)
		if path < 0:
			for id in ["tornado_kick", "heel_drop", "roundhouse_kick", "counter_kick", "flying_kick", "mild_wind"]:
				for k in 5:
					p.add_skill(id)
			p.recompute()
			for k in 16:
				await get_tree().create_timer(0.17, true, false, true).timeout
				await snap.call("kicks")
			var far: = world.spawn_enemy("poring", p.position + Vector3(7.5, 0, 1.0), true)
			if far != null:
				far.max_hp = 10000000.0
				far.hp = 10000000.0
				far.speed = 0.0
			p.skills.flying_kick.cd = 0.0
			for k in 4:
				await get_tree().create_timer(0.1, true, false, true).timeout
				await snap.call("flying")
			print("TKTEST base element=%s stance_rest=%.2f" % [p.basic_element(), p._stance_rest])
		else:
			for k in 2:
				p.add_skill("tornado_kick")
			p.job_change(path)
			var ids: = ["warmth_sun", "warmth_stars", "union"] if path == 0 else ["estin", "esma", "eswoo", "kaite", "soul_link", "mild_wind"]
			for id in ids:
				for k in 5:
					p.add_skill(id)
			p.recompute()
			for k in 12:
				await get_tree().create_timer(0.4, true, false, true).timeout
				await snap.call("sg" if path == 0 else "sl")
			print("TKTEST job=%s powers=%s" % [p.job2.get("id", ""), p.powers.keys()])
	var top: = []
	for r in world.meter_sorted().slice(0, 8):
		top.append("%s=%d" % [r.tag, roundi(r.dmg)])
	print("TKTEST meter=", top)
	get_tree().quit()





func _gacha_test(dir: String) -> void :
	DirAccess.make_dir_recursive_absolute(dir)
	await get_tree().create_timer(1.5, true, false, true).timeout

	var pics: = {}
	var snap: = func(name: String) -> void :
		await RenderingServer.frame_post_draw
		pics[name] = get_viewport().get_texture().get_image()
	var wait: = func(t: float): await get_tree().create_timer(t, true, false, true).timeout
	Save.add_coins(200)
	world.enter_town("swordsman")
	await wait.call(4.0)
	world.menus.show_gacha()
	await wait.call(1.0)
	await snap.call("00_idle")
	var panel: Node = null
	for n in world.menus.find_children("*", "HBoxContainer", true, false):
		if n.has_method("_spin") and n.has_method("_tier"):
			panel = n
	if panel == null:
		print("GACHATEST no panel")
		get_tree().quit()
		return
	var size_before: Vector2 = panel.size
	for rar in ["legendary", "rare", "common"]:
		var gs: GDScript = panel.get_script()
		gs.force_rarity = rar
		panel.call("_spin", "coins")
		var t0: = Time.get_ticks_msec()
		var k: = 0
		while panel.get("_busy") and Time.get_ticks_msec() - t0 < 20000:
			await wait.call(0.15)
			await snap.call("%s_%02d" % [rar, k])
			k += 1
		await wait.call(0.6)
		await snap.call("%s_end" % rar)
		print("GACHATEST %s frames=%d time=%.1fs size %s -> %s" % [rar, k, (Time.get_ticks_msec() - t0) / 1000.0, size_before, panel.size])
	(panel.get_script() as GDScript).force_rarity = ""
	for n in pics:
		pics[n].save_png("%s/%s.png" % [dir, n])
	get_tree().quit()
