# mod v17 — MVP-card-only odds: pre-build checks (PATCH_SYSTEM.md §23)

Two independent checks on the one knob `GameData.MOD_MVP_CARD_MULT` (`game_data.gd:10553`). Both are read-only
over `work/60_patches/effective_0.2.12/`; nothing here runs the game.

## 1. `./mk_probe.py` — what the `is_mvp_card()` gate actually catches

Replicates the shipped definition (`autoload/game_data.gd:13578`: every `MONSTERS` entry with `"mvp": true`
that has a `card` field) over the decompiled live layer, then proves the two claims the mod rests on: no card
reachable from a *non*-MVP roll site is inside the boosted set, and the `sim.gd` copy of the set is current.

```
$ ./mk_probe.py
MVP monsters: 30   with a card: 26   with no card field (can never be boosted): morroc_adult, morroc_kid, naght_sieger, training_dummy_mvp
boosted card ids: 26   of those not in CARDS: none
boosted: apocalips_card, baphomet_card, beelzebub_card, dark_lord_card, eddga_card, fallen_bishop_card, gloom_card, golden_bug_card, ifrit_card, knight_of_windstorm_card, kraken_card, ktullanux_card, l_seyren_card, lord_of_death_card, maya_card, mistress_card, moonlight_card, orc_hero_card, orc_lord_card, osiris_card, owl_baron_card, randgris_fallen_card, reginleif_card, satan_morroc_card, thanatos_card, turtle_general_card

non-MVP monster cards (shipped odds kept): 160
_fight_card() raid pools inside the boosted set: NONE (correct)
elite/prize + boss + mob rolls use: CARD_DROP_CHANCE=0.00038 ELITE=0.076 BOSS=0.1425 FIGHT=0.30 (untouched)
MVP_CARD_CHANCE=0.285  HELL_SHADOW_CARD=0.25  PRIDE_CARD=2.0
MOD_MVP_CARD_MULT=2.4 -> per MVP kill 0.6840, shadow roll 0.1710
sim.gd mk_is_mvp() list == derived set: YES
```

The four MVPs with no `card` field are inside the 30 but can never be boosted. The `RAIDS` walk covers
`mob`/`egg`/`hatch` of every ability — the exact pool `main.gd:17235 _fight_card` builds — which is why that
site needed no knob, and got none.

## 2. `godot --headless --path . --script res://sim.gd` — the probe format strings

`sim.gd` holds the four `store_line()` calls of `World._take_card` verbatim (only the `GameData` lookups are
replaced by their real values, read out by `mk_probe.py`). Executed under Godot 4.7.2.stable:

```
$ godot --headless --path . --script res://sim.gd
--- user://mod_probe_cards.txt ---
mod-v17 mvp_card_mult=2.40  chance per MVP kill=0.684 (shipped 0.285)
run: hell=15  danger=30  time=2400 s  mvps_killed=26  level=400
cards this run: mvp=1  other=2  total=3
last: baphomet_card  mvp=true  new=true

mult=1.0  per MVP kill=0.285  shadow roll=0.0712  pride x2=0.570  with bubble gum (drop 2.0)=0.570
mult=2.4  per MVP kill=0.684  shadow roll=0.1710  pride x2=1.368  with bubble gum (drop 2.0)=1.368
```

The last two lines are the saturation note in §23: once the pride (×2) or Bubble Gum (×2) multiplier is on top
of 0.684 the chance passes 1.0, so those kills are guaranteed cards and the realised gain over the shipped 7/run
is slightly below the nominal 2.4×.

## Post-build checks (the ones that actually gate the pack)

```sh
cd work/60_patches
./mod_apply.sh --check            # 0 conflicts / 0 moved sites / 0 lint gaps, 51 old knob sites intact
./build.sh --deep                 # every new source line present in the compiled bytecode
```
