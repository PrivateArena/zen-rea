extends SceneTree

# mod-v17 probe check 2/2: the four store_line() calls of World._take_card, copied VERBATIM (only the
# GameData lookups are replaced by their real values, which mk_probe.py reads out of the decompiled source).
# Run every format string before shipping - mod-v2 put a literal "%.1f" in the game log this way.

func _init() -> void :
	var mvp_card_mult: = 2.4            # GameData.MOD_MVP_CARD_MULT
	var mvp_card_chance: = 0.285         # GameData.MVP_CARD_CHANCE
	var hell_shadow: = 0.25              # GameData.HELL_SHADOW_CARD
	var pride: = 2.0                     # GameData.PRIDE_CARD
	var danger: = 30                     # danger 30 == Hell 15 (DANGER_HELL_FROM = 16)
	var time: = 2400.0
	var run_mvps: = 26
	var run_cards: = [{"id": "baphomet_card", "new": true}, {"id": "hydra_card", "new": false}, 
		{"id": "poring_card", "new": false}]
	var mod_mvp: = 0
	for mod_c in run_cards:
		if mk_is_mvp(str(mod_c.get("id", ""))):
			mod_mvp += 1
	var card_id: = "baphomet_card"
	var is_new: = true
	var lvl: = 400
	var f: = FileAccess.open("user://mod_probe_cards.txt", FileAccess.WRITE)
	f.store_line("mod-v17 mvp_card_mult=%.2f  chance per MVP kill=%.3f (shipped %.3f)" % [mvp_card_mult, mvp_card_chance * mvp_card_mult, mvp_card_chance])
	f.store_line("run: hell=%d  danger=%d  time=%d s  mvps_killed=%d  level=%d" % [maxi(0, danger - 16 + 1), danger, int(time), run_mvps, lvl])
	f.store_line("cards this run: mvp=%d  other=%d  total=%d" % [mod_mvp, run_cards.size() - mod_mvp, run_cards.size()])
	f.store_line("last: %s  mvp=%s  new=%s" % [card_id, str(mk_is_mvp(card_id)), str(is_new)])
	f.close()
	print("--- user://mod_probe_cards.txt ---")
	var r: = FileAccess.open("user://mod_probe_cards.txt", FileAccess.READ)
	while not r.eof_reached():
		print(r.get_line())
	print("--- odds the knob produces ---")
	for mult in [1.0, mvp_card_mult]:
		var p: float = mvp_card_chance * mult
		print("mult=%.1f  per MVP kill=%.3f  shadow roll=%.4f  pride x2=%.3f  with bubble gum (drop 2.0)=%.3f" % [mult, p, p * hell_shadow, p * pride, p * 2.0])
	quit()


# GameData.is_mvp_card() reduced to the 26 ids mk_probe.py extracted from the live layer (the real
# function builds the same set out of MONSTERS at runtime)
static func mk_is_mvp(id: String) -> bool:
	return id in ["apocalips_card", "baphomet_card", "beelzebub_card", "dark_lord_card", "eddga_card",
		"fallen_bishop_card", "gloom_card", "golden_bug_card", "ifrit_card", "knight_of_windstorm_card",
		"kraken_card", "ktullanux_card", "l_seyren_card", "lord_of_death_card", "maya_card", "mistress_card",
		"moonlight_card", "orc_hero_card", "orc_lord_card", "osiris_card", "owl_baron_card",
		"randgris_fallen_card", "reginleif_card", "satan_morroc_card", "thanatos_card", "turtle_general_card" ]
