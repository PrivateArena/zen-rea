# Sword Wings ×2 ("+60%") — findings + farming guide

Reverse-engineered from the **installed** patch layer `effective_0.2.7/` (0.2.7 + our mod v12; the mod
touches none of the code below — see §7). Every claim is `file:line` verifiable in that tree.
Verified 2026-11-22; §11/§12 (three player-reported findings + mod v15) verified 2026-11-23 against the
same tree with mod v15 applied. Related: `PATCH_SYSTEM.md` (patch layer / mod pipeline).

---

## 0. TL;DR for the question "can I idle 5 h and *then* climb?"

**No — the clock is per-run and cannot be banked outside the tower.** Entering the tower is a brand-new
run and zeroes the clock:

```gdscript
# core/main.gd:1641  start_tower() -> ... start_run(cid)
# core/main.gd:1374  time = 0.0        (inside start_run)
```

**But you CAN idle *inside* the climb** — and that is strictly better than fighting, because the clock
is frozen on MVP floors and the speed boost is suppressed on event/boss/sign floors. Winning plan:

> Set tower speed **×2** → start the climb → clear floor 1 → **don't touch the portal** → idle with **no
> menu open** for **2 h 25 m 30 s** real time (= 17 460 game-s) → then climb to the next floor ≡ 5 (mod 10),
> **win the Emperium event** and open the diamond chest (3–10 rolls, bonus 3). ~1.7–2.5 % per roll.

---

## 1. What the item actually is

There is exactly **one** wings item in the game — no "legendary Sword Wings" exists:

```gdscript
# autoload/game_data.gd:7258  (the only "slot":"wings" entry in all 366 ITEMS)
"sword_wings": {"name": "Sword Wings", "slot": "wings", "wings": true, "rank": 99,
                "icon": "sword_wings", "view": "sword_wings", "bound": true,
    "mods": {"dmg": 0.3, "max_hp_pct": 0.3, "aspd": 0.2, "haste": 0.2, "move": 0.1, "count": 1.0}, ...}
```

No `legendary`, no `unique`, no `fixed`, no `refine`, no `purple` key. The "+60%" is a **per-instance tier
multiplier** driven by the socket count `it.slots`:

```gdscript
# core/equipment.gd:596   (_base_mods — multiplies EVERY base mod)
var mult: = float(GameData.ITEM_TIERS[clampi(int(it.slots), 0, 3)].mult)
# autoload/game_data.gd:8308-8313  ITEM_TIERS mult = 1.0 / 1.3 / 1.6 / 2.0   (index == slots)
```

| slots | mult | dmg shown | name in UI |
|---|---|---|---|
| 0 (the scripted tower-lord award) | ×1.0 | **+30 %** | — |
| 3 (**loot-pool bug**, §2) | ×2.0 | **+60 %** | "Moradas"/purple, "epic" in the Armory |
| 3 + awakened (`Wings of Hel`) | ×2.0 ×1.5 | **+90 %** | gold |

`Wings of Hel` is not an item: it is the same `sword_wings` with `hel = true` (Valkyrie, costs 1
`hel_requiem`), `HEL_WINGS_MULT = 1.5` applied **after** the tier mult —
`equipment.gd:596-603`, `save.gd:1150-1158`, `game_data.gd:7617-7619`.
Tooltip arithmetic: `menus.gd:9765` → `item_mods(it, false)` (potential excluded) → `roundi(mods.dmg*100)`.
`[5]` = `sockets()` = `slots 3 + extra_slots 1 + 1 (wing refine ≥ 5)` — `equipment.gd:472-477`.
`+10` = the Valkyrie feather ladder (`save.gd:867 refine_wings`, `WING_REFINE_MAX = 10`), which does **not**
scale the base mods; the auto-`Locked:` line comes from the load-time `_lock_refined()` migration
(`save.gd:1884-1890`, fires at `refine >= 10`).

## 2. Why a +60 % one exists at all (dev loot-pool bug, still unfixed in 0.2.7)

```gdscript
# core/equipment.gd:712-733  roll_item(): normal loot pool
var max_rank: = maxi(1, 1 + int(run_time / GameData.RANK_STEP) + bonus)     # RANK_STEP = 180.0  (:8190)
	if d.get("legendary", false) or d.get("face", false) or int(d.get("rank", 1)) > max_rank: continue
# core/equipment.gd:750-761
if bonus > 0:
	n = maxi(n, GameData.CHEST_MIN_SLOTS)          # = 3  (:9699)  -> it.slots = 3 -> mult 2.0
var pick: String = pool.pick_random()
var it: = make(pick, n)
if n >= 1 and not GameData.ITEMS[pick].get("fixed", false):
	it["trait"] = GameData.PURPLE_TRAITS.keys().pick_random()     # wings NOT excluded
```

The pool filter never excludes `wings`/`bound`, and `CHEST_MIN_SLOTS` doubles as the tier index. So a
`bonus > 0` chest rolled late enough in a run mints a tier-3 Sword Wings **with a free purple trait**
(the "◆ Serrated" on the screenshot — `can_trait` `equipment.gd:784-786` *would* refuse wings, but the
assignment above doesn't consult it; that's the fingerprint that proves the chest origin).
Checked pristine `scripts_full_0.2.4` vs `scripts_full_0.2.7`: **zero hunks** in `roll_item`, `ITEM_TIERS`,
`CHEST_MIN_SLOTS`, `_drop_chest`, `_award_tower_wings`. Nothing clamps `it.slots` on load
(`equipment.gd:203-209`, `save.gd` migrations) → **the item keeps +60 % forever.**

## 3. Why it survived "auto-sell epic/purple" (the myth, killed)

`auto_sells()` tests the instance tier, not a rarity flag — and it is only reached **if the item cannot be
equipped**:

```gdscript
# core/equipment.gd:1276-1289
	var tier: = clampi(int(it.slots), 0, 3)
	if tier == 3: return bool(Save.setting("autosell_purple", false))     # "Moradas" checkbox
# core/equipment.gd:1151-1153   (chest loot goes straight through Equipment.receive, player.gd:5439)
	if slots[key] == null and ... can_wear(it) ...:
		slots[key] = it
		return {"result": "equipped"}          # <-- returns BEFORE the sell gate at :1169
```

So: an **empty wings slot** ⇒ auto-equip ⇒ auto-sell never evaluated. `bound: true` is trade-window-only
(`bound_item` is called only from `trade.gd:208/396`, `menus.gd:28602`), and wings are explicitly exempt
from "Legendarios repetidos" (`_repeat_sells`, `equipment.gd:1033`). Once stored, `from_storage` stamps
`perm = true` → permanently unsellable (`equipment.gd:205`, `:409`, `menus.gd:24475`).

## 4. The run clock, precisely

`time` (`main.gd:474`) is game-seconds of the **current run**; `roll_item` gets it via
`main.gd:14886 → player.open_chest(count, bonus, time, …) → player.gd:5439`.

```gdscript
# core/main.gd:4508-4517  (World._process)
delta = minf(delta, 0.05 * (GameData.GAME_FAST_SPEED if fast_now else 1.0))
var frozen: = raid.freezes_time() or morroc.freezes_time()
if not frozen:
	time += delta * pace                     # pace is ALWAYS 1.0  (:309, :1410)
```

| Fact | Value / evidence |
| --- | --- |
| Accumulates while standing still | yes — no idle timer, no AFK kick, no floor deadline (`tower_run.gd` grep clean; `_floor_t0` is write-only debug) |
| Stops | any menu open (`hold_world()` → `get_tree().paused`, `main.gd:2369`; inventory `menus.gd:11518`, pause `:13439`, chest `:8062`, level-up `:6423`, wheel `:16203`, camp `:15991`), **minimising the window** (auto-ESC, `main.gd:16899-16906`) |
| Does **not** stop | minimap (`hud.gd:204`, pure HUD), losing focus (only caps FPS → keep ≥30 fps) |
| Frozen on MVP arenas | `raid.freezes_time()` (`mvp_raid.gd:119`) — every 10th tower floor has an MVP |
| Speed multiplier | `tower_speed` setting: 1 = normal, 2 = frenzy **1.3×** (`game_data.gd:12242`), 3 = **2.0×** (`:12250`), via `Engine.time_scale` (`main.gd:15484-15490`); **suppressed** on `sign`/`event`/`boss` states and Hel (`tower_run.gd:1215 fast_ok()`) |
| Set it where | tower entry screen (`menus.gd:16577-16614`); **cannot** be changed mid-climb (`main.gd:15504-15509`) |
| Cross-run banking | impossible — `time = 0.0` per `start_run` (`:1374`); tower runs are never save/resumed (`run_save.gd:66-69`) |

### Game-seconds needed (`1 + int(t/180) + bonus >= 99`)

| chest `bonus` | game-s needed | real @1× | real @1.3× | **real @2×** | also unlocked |
|---|---|---|---|---|---|
| 3 (Emperium diamond) | **17 100** | 4 h 45 m 00 s | 3 h 39 m 14 s | **2 h 22 m 30 s** | — |
| 2 (MVP kill) | 17 280 | 4 h 48 m | 3 h 42 m 55 s | 2 h 24 m 00 s | MVP chests |
| 1 (generic boss, some events) | 17 460 | 4 h 51 m | 3 h 44 m 46 s | **2 h 25 m 30 s** | boss chests |
| 0 (elite) | 17 640 | 4 h 54 m | 3 h 46 m 46 s | 2 h 27 m 00 s | *but* bonus 0 never forces slots = 3 |

**Target 17 460 game-s (2 h 25 m 30 s at ×2)** — that's the sweet spot: Emperium, MVP *and* boss chests all
qualify, and all of them carry the `bonus > 0` tier floor that produces the ×2 version.

## 5. Which chests can (and cannot) mint it

`_drop_chest(at, rolls, bonus, unique, satan, corrupt, look, treasure, valkyrie)` — `main.gd:13598`.
`treasure = true` sets `chest_legend = 1.0` (`main.gd:14877-14888`) ⇒ `roll_item` always takes the
**legendary** branch, which returns `make(pick, 0)` ⇒ **slots 0** and wings isn't in that pool.

| Source | file:line | rolls | bonus | mints ×2? |
| --- | --- |---|---|---|
| **Tower event: Emperium → diamond chest** | `tower_events.gd:341` | **3–10** | **3** | ✅ **best** |
| MVP kill (every 10th floor) | `main.gd:12159` | 3 | 2 | ✅ |
| Tower event: survive / treasure / ambush | `tower_events.gd:617 / 282 / 298` | 3 | 2 / 1 / 1 | ✅ |
| Generic boss kill | `main.gd:11963` | 3 | 1 | ✅ (needs the 17 460 s target) |
| **Naght Sieger floor-100 treasure chest** | `main.gd:12148` | 5 | 3 | ❌ forced legendary branch — but **the fight hands out Sword Wings anyway: §11.1** |
| Elite mob | `main.gd:11957` | 1 | 0 | ❌ no tier floor (mostly ×1) |
| Golden Poring (stage event) | `main.gd:11994` | 5 | 3 | ❌ **not tower-reachable** (`_run_director` returns early: `main.gd:5169-5172`) |
| Hell herald / tide, late-Hell | `main.gd:15992/16009`, `hell_late.gd:392` | 1–2 | 1 | ❌ gated off in tower (`hell_late.gd:79-83`, `_run_director`) |
| Karma corrupt chest | `karma.gd:189` | 4 | 2 | ❌ `karma.gd:155` bails when `world.tower != null` |
| Morroc / Satan chests | `morroc_event.gd:1269` | n | 3 | ❌ reset on tower entry (`main.gd:1664`) |

`chest_legend`/`chest_extra` are re-assigned and cleared around **every** chest open (`main.gd:14877-14888`),
so a prior treasure chest cannot "contaminate" your boss chests.

## 6. Odds

The pool is a flat `pool.pick_random()` — `SLOT_WEIGHTS`/`shift` bias only *how many sockets*, never
*which id*. Measured by replaying the `equipment.gd:712-733` filter over `GameData.ITEMS` (366 ids →
251 legendary + 16 face excluded → 103 left; per class after `weapon_allowed` + the weapon `×3` duplication
at `equipment.gd:729-733`):

| class | weighted entries | **P(Sword Wings) per roll** |
|---|---|---|
| swordsman | 59 | 1.69 % |
| mage | 55 | 1.82 % |
| archer | 58 | 1.72 % |
| thief / gunslinger | 52 | 1.92 % |
| acolyte | 56 | 1.79 % |
| merchant | 63 | 1.59 % |
| ninja | 65 | 1.54 % |
| super_novice / taekwon | 40 | **2.50 %** |

* A perfect Emperium chest (10 rolls) ≈ **15–22 %** per chest; expect several wins.
* No de-dup: `roll_item` is re-called per roll (`player.gd:5438-5439`) — you can roll it twice, and repeats
  are fine (each is a new instance).
* Owning one does **not** reduce the odds.
* **Super_novice/taekwon has the best per-roll odds** (fewest legal weapons → smallest pool).

## 7. Our mod's involvement

* `MOD_*` hunks: none touch `roll_item`, `slots`, `ITEM_TIERS`, `_drop_chest`, the wings award, or the clock.
  (`MOD_TIME_SCALE_CAP = 3.0` in `enemy.gd:215` only rescales **enemy HP** — not `time`. `MOD_TOWER_FLOOR_CAP
  = 90` in `tower_run.gd:8` actually makes the deep floors survivable.)
* **The 3× "+7 % to all stats" Legendary Potential lines ARE ours**: `MOD_POT_UP/MOD_POT_SAME/MOD_POT_PERFECT/
  MOD_POT_KEY_W` in `core/potential.gd`. Shipped odds would make that item `(1/18)³ × 0.2³ ≈ 1.4e-6`;
  with the mod ≈ 3.7 % of rolls.

---

## 8. The farm, step by step

1. **Class with an empty wings slot.** Guarantees auto-equip → immune to every auto-sell filter, and
   chest-rolled wings do **not** consume your per-class free Naght Sieger grant (only `_found_unique` calls
   `_wings_got` — `main.gd:12212` vs `_wings_due` `main.gd:12234-12239`). Super_novice/taekwon: +40 % odds.
2. **Uncheck "Moradas" (autosell_purple)** in Settings — **mandatory, not belt-and-braces**: the tier-3 sell
   branch has no wings exemption, it only never fires while the wings slot is empty (§11.2). `menus.gd:10555`.
3. **Set tower speed to ×2 on the tower entry screen** (`menus.gd:16577-16614`; locked mid-climb).
4. Enter the Endless Tower, **clear floor 1** (31 kills: `TOWER_KILLS 30 + 1.0×floor`), **do not enter the
   portal**. `climb` state spawns nothing and the portal never expires (`tower_run.gd:250-262, 387-428`).
5. **Idle 2 h 25 m 30 s**: no menu open, window focused (minimising auto-pauses = clock stops). Put a timer
   on 2 h 30 m. Nothing scales with elapsed time — `scale_time()` is floor-derived (`tower_run.gd:166-167`).
6. Climb to the next **floor ≡ 5 (mod 10)** → event. You want **Emperium** — with mod v15 it comes every
   ~9 floors (§12.2); on stock 0.2.7 it is ≈1 event in 6, ~every 60 floors. It's 5 × 10 s DPS checks against
   *your own measured DPS* (`tower_events.gd:208-216`), so it self-scales and stays winnable at floor 1000+:
   pass 4–5 → **12 or 16 rolls** under v15 (`MOD_EMP_PRIZES [5,7,9,12,16]`), 7 or 10 shipped
   (`TOWER_EMPERIUM_PRIZES [3,4,5,7,10]`), `tower_events.gd:488-494`.
7. Non-Emperium event floors: take the chest anyway (survive = bonus 2, treasure/ambush = bonus 1–2), open
   **every MVP chest** (bonus 2), and **every Emperium altar** you channel past (§11.3, bonus 2 + a level).
8. **Open your chests before hoarding**: ground-chest cap is 12; a 13th absorbs the oldest and clamps rolls
   to 5 (`main.gd:13680-13694`; `MAX_GROUND_CHESTS` `game_data.gd:9941`, `MAX_CHEST_ROLLS` `:9971`). Chests are **not** lost
   on floor change — `"chest"` is excluded from `TOWER_CARRY_COLLECT` and they teleport with you
   (`tower_run.gd:502-520`, `game_data.gd:4688`).
9. When it drops: **let it equip** (empty wings slot), and **keep it equipped at run end** — only 3 items can
   be banked (`KEEP_WIN = 3`, `keep_free = victory`), the rest of the bag is auto-sold
   (`main.gd:16421-16453`, `menus.gd:23300`).
10. Repeat the whole thing if you want another copy; each new climb restarts the clock from 0.

### Risk profile: essentially free

* **Dying in the tower counts as a win** (`endless = true` → `won = endless`, `main.gd:16399`) → keep screen
  with 3 free bank slots. Floors are checkpointed (`save.gd:1027-1035`) so you can re-enter high.
* The **only** true loss is **"Abandonar partida"** (`menus.gd:13548-13573`, two-click in the tower): no end
  screen, bag + equipped run items gone. Never abandon an idle-climb.
* No despawn, no AFK kick, no difficulty-from-idle, no mid-climb speed change needed.

### Tips & tricks that likely work

* **Idle early, fight late.** Fighting spends real time in frozen (MVP arena) or 1× (event/boss/sign) states —
  an idle bank is the fastest legal clock per real hour.
* **Idle *past* the target.** Every extra 180 game-s buys one more rank of headroom, so bonus-1/0 chests
  (bosses, elites) also count — much more chest volume per hour than events alone.
* **Skip the floor-100 chest hopes.** Naght Sieger's *chest* is the only one that can never roll it
  (`treasure` ⇒ legendary branch ⇒ `slots 0`). Kill him anyway: he awards a **free ×1 pair** by script (§11.1)
  — but not a ×2.
* **Want it faster?** The lever is the pool gate, not your DPS: `"rank": 99` is the only reason this needs a
  5-hour run. `MOD_ITEM_W`-style weighting (§9) makes it a normal drop.
* **Test the stats for free right now:** Kafra **Armory** → any *seen* Sword Wings is handed out at `slots = 3`
  (`menus.gd:2675 Equipment.make(id, ... else 3)`) — but it arrives `lent = true` and can never be banked
  (`save.gd:2127`, `main.gd:16428/3120`). Good for a one-run try-out of the +60 %.
* **Awakening multiplies on top:** taking a ×2 pair to the Valkyrie with a Hel Requiem (`save.gd:1150`) gives
  **+90 % dmg / +90 % HP / +60 % aspd / −60 % cd / +30 % speed** (`count` is exempt, `HEL_WINGS_KEEP`).
  Requires the Hel Tower (`tower_run.gd:98-100`), which is wall-clock gated
  (`HEL_TOWER_OPENS_AT`, `game_data.gd:119`) and is one Hel Requiems-per-class.

---

## 9. Optional: make it obtainable by design (mod v13 candidate — not built)

Cheapest change that respects `PATCH_SYSTEM.md` §14/§20 (prefer pure insertion):

1. `sword_wings` `"rank": 99` → `6` in `game_data.gd:7258` — eligibility drops to **15 game-min** at bonus 3.
   Keep `rank ≥ 6` so `score()` (`equipment.gd:1026`) doesn't treat it as trash in the bag-overflow path.
2. `const MOD_ITEM_W: = {"sword_wings": N}` next to `MOD_ALTAR_W` (`game_data.gd:8857`), honoured by
   appending `N-1` extra ids at **`equipment.gd:726` `pool.append(id)`** — reuses the shipped weapon
   duplication trick (`:730-732`), so `pool.pick_random()` (`:753`) is left untouched.
3. **Do NOT** add `"legendary": true` — that routes it to `make(pick, 0)` = `slots 0` = the boring ×1.0 version.
4. Then: comment block + baseline→new odds, bump `MOD_TAG` (literals, never placeholders),
   `./mod_apply.sh --check --build`, one `lint-allow.txt` row for the `rank` line,
   `MOD_VER=0.2.7 ./build.sh --deep`, play-test, `./update.sh --skip-sync --install`.

Open design question if we build it: cap the tier-awakening stack (`ITEM_TIERS × HEL_WINGS_MULT`) so
`+60 %` cannot become `+90 %` while we are in there.

---

## 10. mod v14 — raising the Emperium encounter rate (built, **not installed yet**)

Built 2026-11-23 into `out/patch_0.2.7.pck` (sha `6122aba72cdd3933…`, 272 members), `MOD_TAG` →
`mod-v14 … event_w=emperium9 emp_grow=1.4 emp_time=15 emp_prizes=[5,7,9,12,16]`. Four knobs, all in
`core/tower_events.gd` (the event file was otherwise pristine except our v5 wheel block):

```gdscript
const MOD_EVENT_W: = {"emperium": 9.0}      # re-weighted pick in pick() -> _event_pick(pool)
const MOD_EMP_GROW: = 1.4                   # was TOWER_EMPERIUM_GROW 1.7  (hp growth per check)
const MOD_EMP_TIME: = 15.0                  # was TOWER_EMPERIUM_TIME   10 s per check
const MOD_EMP_PRIZES: = [5, 7, 9, 12, 16]  # was TOWER_EMPERIUM_PRIZES [3, 4, 5, 7, 10]
```

| | shipped | mod v14 |
|---|---|---|
| Emperium per event floor (prev ≠ emperium) | 20 % | **69.2 %** |
| Emperium share of all event floors (never twice in a row) | 16.7 % | **40.9 %** (simulated 400 k draws) |
| floors between Emperium events | ~60 | **~24** |
| avg DPS needed to clear checks 1-5 | 0.70 / 1.19 / 2.02 / 3.44 / **5.85** × | 0.47 / 0.65 / 0.91 / 1.28 / **1.79** × |
| rolls at `_passed` = 1 / 3 / 5 | 3 / 5 / 10 | **5 / 9 / 16** |
| P(Sword Wings) per Emperium chest (mage, 1.82 %/roll) | 5.4 % | **25.5 %** |

* Why the growth matters: check HP is `max(500, avg_dps × 7) × GROW^_passed` (`tower_events.gd:363`) and the
  window was 10 s ⇒ shipped 5/5 needs **5.85× your own run-average DPS**, i.e. effectively unreachable
  except very deep where current DPS ≫ average. Most players bank `_passed = 1` = the 3-roll prize.
* Cadence untouched on purpose: event floors stay `floor % 10 == 5`, because that residue also carries the
  elite floor (`tower_run.gd:581`) and Lucile's blessing (`TOWER_BLESS_FLOOR`), and `TOWER_TIER_FLOORS`
  itself drives checkpoints/tiers/MVP/camp.
* Verify on your own climb: `user://mod_probe_events.txt` (+ `MODPROBE events:` in the log) counts the
  real draws, same pattern as the wheel probe.
* Combined with §8: idle-bank the clock (17 460 game-s) → ~1 Emperium per 24 floors → 16-roll chest at
  25 % per win ≈ a few chests. Revert any time with `./build.sh --restore`.
* Audit trail: `./mod_apply.sh --check --build --deep` → exit 0, 0 conflicts / 0 moved sites / 0 lint gaps;
  `--deep` round-trip confirms all four hooks in the shipped `.gdc` (`verify/rt/tower_events/`). Two
  `lint-allow.txt` rows added (old `MOD_TAG` v13 line, `return str(pool.pick_random())` — the one shipped
  line rewritten). Install only after a play-test: `./build.sh --install`.

---

## 11. Three player-reported findings, verified in the code (2026-11-23)

### 11.1 "The Naght Sieger floor-100 treasure chest DOES drop Sword Wings" — **confirmed**, and it is not the loot roll

Killing the tower lord on floor 100 (any `TOWER_LORD` floor, i.e. every 100th) does two things at once:

```gdscript
# core/main.gd:12147-12156
	if tower != null and e.id == GameData.TOWER_LORD:
		_drop_chest(e.position, GameData.MAX_CHEST_ROLLS, 3, "", false, false, "", true)   # the 5-roll treasure chest
		if heroes.any(_wings_due):
			get_tree().create_timer(1.6, false).timeout.connect(_award_tower_wings.bind(e.position))
		...
		party_announce(tr("¡Tesoro de la Torre!"), ..., tr("El tesoro de Naght Sieger es tuyo"))
```

`_award_tower_wings` (`main.gd:12243-12265`) is a **scripted grant**, 1.6 s after the chest lands:

* `Equipment.make(GameData.TOWER_WINGS, 0)` (`:12249`) — `slots = 0` ⇒ `ITEM_TIERS[0].mult = 1.0` ⇒ **+30 %**, the
  plain version. No trait, no purple, `bound` irrelevant.
* routed through `_found_unique` (`:12250-12252`), which opens a *second* chest-reveal window titled
  **"Alas de la Torre"** (`_open_chest_show(at, 3, [r], …)`) and stores the item to the Kafra
  (`Save.add_to_storage`, `:12215`) — this is exactly what reads as "the chest dropped the wings".
* once per **class, forever**: `_wings_due` (`main.gd:12234-12238`) refuses if the pair is already carried or
  if `Save.tower_wings()` already lists `h.class_id` (`_wings_got` `:12307-12312`); the Kafra repeats it in the
  refusal text "…cada clase las gana una sola vez" (`menus.gd:24475-24477`), and `save.gd:301-303` re-adds a
  wing the save is owed. The Hel Tower has its own second grant (`main.gd:12154`, `_award_hel_wings`).

**Reconciled with §5:** the table's ❌ is about the *chest's own 5 rolls* and it still stands — `treasure = true`
⇒ `chest_legend = 1.0` ⇒ `roll_item` takes the forced-legendary branch ⇒ `make(pick, 0)` and that pool requires
`"legendary": true`, which `sword_wings` does not have. The two never touch: the award does not consume the
chest, and the chest cannot produce wings. Consequence for the farm: killing Naght Sieger on a class that has
not been given its pair is a **free +30 % pair** and does not affect the ×2 hunt at all (§8 step 1 relies on
this: `_found_unique` is the only caller of `_wings_got`).

### 11.2 "Sword Wings is treated as Mythic" — **confirmed in the UI, absent in the data** (and the autosell reason is different)

`"Mítico"` exists exactly once in the whole build, as a *display* grade chosen before Único/Legendario:

```gdscript
# ui/menus.gd:10134-10142  (_rarity)
	if Equipment.item_def(it).get("wings", false):
		return [GameData.WINGS_COLOR, tr("Mítico")]        # checked BEFORE is_unique / is_legendary
```

`WINGS_COLOR` is violet (`game_data.gd:7596`), the same precedence is used for world/drop colours
(`equipment.gd:377-385`), and `sword_wings` is the only item with `wings: true` — so wings sit **above**
Legendary in the ladder. But there is **no `mythic`/`rarity`/`grade` field**: `is_unique()` and `is_legendary()`
are both false (`equipment.gd:413-420`).

That is why the auto-sell behaviour you saw has a different cause. The exemptions that *do* carry a wings check
(`auto_sells` `:1277-1279`, `_repeat_sells` `:1033`, `upgrade_slot` `:1195`) all sit behind `is_legendary()` or
on the "replace my equipped item" path, so they never see wings. What actually protects it:

```gdscript
# core/equipment.gd:1149        -> pre-equip sell: legendary items only, wings never qualifies
# core/equipment.gd:1151-1154  -> empty "wings" slot  -> equipped, returns BEFORE the sell gate at :1169
# core/equipment.gd:1281-1283  -> the "Moradas" branch is `if tier == 3: return autosell_purple`  (no wings test!)
```

**Foot-gun this exposes:** with the wings slot **already filled**, a second `slots = 3` pair *does* reach
`:1169` and **is sold for zeny** by "Moradas" (`autosell_purple`) — the mythic label will not save it. So §8
step 2 (uncheck Moradas) is mandatory for this farm, not optional. Only the Kafra storage path really does
guard by id (`menus.gd:24475-24477`, `:23427`, `:23481`).

### 11.3 The Emperium **altar** — the channel-on-it Emperium, and a third Sword Wings mint

`ALTARS["emperium"]` (`game_data.gd:8814-8816`, the block you quoted) is the same object as the tower trial /
the Festival emperium (`item_emperium`), dressed as an altar:

* **Channelled like every other altar**: stand inside `ALTAR_RADIUS = 1.8` and hold for `ALTAR_CHANNEL = 2.0` s
  (`altars.gd:111-142`, fill bar; `ALTAR_LIFE = 120` s before it crumbles; spawns every 60-90 game-s, max 5 up).
* `_accept` (`altars.gd:390-407`) applies `mods` — `guardians` is not a stat key, it is a trigger:
  `if d.get("mods", {}).has("guardians"): _call_guardians(a.pos)` (`:403-404`).
* `_call_guardians` (`:761-788`): `EMPERIUM_GUARDS = 5` elites drawn from the *current stage / tower-tier*
  `events` pool, announced as "Derrótala para ganar la Treasure Box del MVP y un nivel".
* Kill them all → `_check_guards` (`:791-804`): `world._drop_chest(player.position + …, GameData.CHEST_ROLLS.boss = 3, 2)`
  **+ 1 level per hero** (`h.grant_levels(1)`).

That box is **not** a `treasure` chest (`treasure = false` ⇒ `chest_legend = 0.0`, `main.gd:14879`), so all 3
rolls go through `roll_item`'s normal pool with `bonus = 2` ⇒ `n = maxi(n, CHEST_MIN_SLOTS) = 3` ⇒ **it can mint
the +60 % (tier-3, purple, free trait) Sword Wings**, exactly like §2 — as soon as
`1 + int(t/180) + 2 >= 99`, i.e. `t >= 17 280` game-s (the bonus-2 row of §4). In the tower that is reachable
with the idle-banked clock of §8, and the altar spawns there too, so it is a genuine third mint source next to
the Emperium *event* chest (§5) and any MVP chest.

It was nevertheless weighted **0.8** (3.3 % of altar spawns) by mod v11, because v11 sorted altars by their
`"bad"` text and this one's "bad" is a fight. That was the wrong axis: the fight is the *reward*. Fixed in
v15 (§12.1).

---

## 12. mod v15 — Emperium, twice as often, in two places (built `e9e9d9c422cd1297…`, **not installed**)

`MOD_TAG` → `mod-v15 … altar_emp=6.0 … event_w=emperium9 emp_every=9 …` (`player.gd:29`, `enemy.gd:218`).
v15 keeps all four v14 knobs (`MOD_EVENT_W`, `MOD_EMP_GROW`, `MOD_EMP_TIME`, `MOD_EMP_PRIZES`) unchanged and
adds two things.

### 12.1 `MOD_ALTAR_W`: emperium 0.8 → **6.0** (`autoload/game_data.gd:8857`)

Measured with the real `spawn()` roll loop over the real `ALTARS` table, 200 k spawns
(`work/logs/altar_odds/`, `python3 mk_probe.py 0.2.7 && godot --headless --path . -s res://sim.gd`;
`odds_0.2.7_v13b.txt` = the v11-v14 config, `odds_0.2.7_v15.txt` = now):

| altar | stock | mod v14 | **mod v15** | reward / debuff |
|---|---|---|---|---|
| odin | 13.61 % | 24.74 % | **20.47 %** | procs +30 % |
| thor | 13.76 % | 24.82 % | **20.34 %** | skill dmg + zeny |
| loki | 13.63 % | 24.74 % | **20.41 %** | card + legendary rolls |
| **emperium** | 13.72 % | 3.33 % | **20.39 %** | **MVP Treasure Box (3 rolls, bonus 2) + 1 level — §11.3** |
| yggdrasil | 4.12 % | 12.44 % | **10.27 %** | +1 life, +2 HP/s |
| freyja / niflheim / valkyrie | ~13.7 % each | 3.3 % each | **2.7 % each** | pure debuff sides |

Reward-pool share (the five altars that pay something) 58.9 % stock → **91.9 %**; the three that only cost you
something are down to 8.1 % combined. Total weight 24.2 → 29.4, no other id touched.

### 12.2 `MOD_EMP_EVERY = 9`: a hard cadence for the tower's Emperium trial (`core/tower_events.gd:69` + hook in `core/tower_run.gd:576`)

v14's weight could not deliver "one trial every ~9 floors" and no bigger weight can: the gate only opens on
`floor % 10 == 5` **and** `pick()` refuses the previous kind, so the densest weight-only schedule is one trial
per 2 event floors. Measured over 2 M floors with the shipped gate + the real `_event_pick`/`pick()`
(`work/logs/emp_cadence/`, same one-liner as above):

| | trial cadence | median gap | worst gap | emperium / 100 floors | other five kinds / 100 floors |
|---|---|---|---|---|---|
| shipped 0.2.7 | **59.9 floors** | 50 | 440 | 1.67 | 1.67 each |
| mod v14 (`MOD_EVENT_W` 9) | **24.4 floors** | 20 | 130 | 4.10 | 1.18 each |
| **mod v15 (weights + `MOD_EMP_EVERY` 9)** | **8.89 floors** | **9** | **9** | **11.25** | 1.75 each |

How: `emp_due(f)` keeps the floor of the last trial and answers *yes* once `MOD_EMP_EVERY` floors have passed;
`tower_run._start_floor()` asks it on **every** floor (the shipped `floor % 10 == 5` test is untouched, so the
other five kinds keep their own rhythm and actually get *more* common again — 1.18 → 1.75 per 100 floors, because
the ceiling, not the weight, now supplies the Emperium). `pick_for(floor)` returns the forced kind and also
re-arms the clock when the weighted roll happens to land on Emperium.

Two details that the measurement earned:

* **MVP floors slide *early*, not late.** A tier-top floor (`floor % 10 == 0`) is claimed by the MVP check first
  (`tower_run.gd:545`), so a due floor there is lost. Sliding to `f+1` locks the phase onto floors ending in 1
  and gives a flat **10.00 floors** per trial (measured). So `emp_due` fires at `MOD_EMP_EVERY - 1` when the next
  floor is a top floor — 8 then 9, 9, 9, … and the ceiling genuinely holds at 9.
* **The seed**: a fresh climb arms the clock from `TOWER_EVENT_AT - MOD_EMP_EVERY`, so the first trial lands on
  floor 5 — the shipped first event floor. A climb resumed from a checkpoint (entering at floor 90, say) is
  instantly "due" and opens with a trial.

Farm consequence with §8: idle-bank the clock, then a 16-roll bonus-3 diamond chest ≈ every 9 floors (25.5 %
per chest at the mage's 1.82 %/roll), plus the ~20 % of altar spawns that are now Emperium boxes.

Verify in your own climb: `user://mod_probe_events.txt` now also prints **`gap=<x> floors`** — the mean real
spacing between two Emperium trials since the game started (the probe counters are `static var`s, so it spans
climbs; the format string was exercised under headless Godot first, v2 lesson). **~9** = the cadence is firing;
**~24** = the `tower_run.gd:576` hook is not; **`n/a`** = fewer than two trials so far.

Audit: `./mod_apply.sh --check --build --deep` → exit 0, 0 conflicts / 0 moved sites / 0 lint gaps; the deep
round-trip shows every new line in the built bytecode (`tower_run: every source line present`, `tower_events`
only the known `MOD_EMP_PRIZES` re-wrap). Three `lint-allow.txt` rows added: the two shipped lines rewritten in
`tower_run.gd` (the event `elif` and the `_sign_kind` assignment) and the superseded `MOD_TAG` v14 string.
Install only after a play-test: `./build.sh --install` (or `./update.sh --skip-sync --install`).
