# Patch system of Midgard Survivors — as reverse-engineered 2026-11-19

Subject: `/home/jang/.local/share/godot/app_userdata/Midgard Survivors/patches/` · driver script
`scripts/autoload/updater.gd` (autoload #1, present in the **base** PCK only).
Everything below was read from decompiled bytecode or measured on this host; nothing was executed
from the game binary.

## 1. What the folder actually is

| File | Bytes | sha256 (short) | Role |
| --- | --- | --- | --- |
| `bridge_0.1.273_to_0.2.0.pck` | 166 723 596 | `b0266960…` | one-shot "bridge": full content delta 0.1.273 → 0.2.0 · **8 452 members** · ships its own `res://project.binary` |
| `patch_0.2.3.pck` | 11 720 768 | `680b5dfd…` | current incremental patch 0.2.0 → 0.2.3 · **123 members** (58 `.gdc`, 25 `.ctex`, 25 `.png.import`, 7 `.po`, 2 `.json`, 3 `.remap`) |
| `state.json` | 150 | — | `{"base":"0.1.273","bridge":{"file":…,"version":"0.2.0"},"file":"patch_0.2.3.pck","version":"0.2.3"}` |

All three packs are **`GDPC` format 4, `pack_flags=2`, unencrypted** (identical 32-byte headers to
the retail PCK). They are decrypted on write: the manifest ships AES-encrypted packs and
`updater.gd:_decrypt()` (`FileAccess.open_encrypted_with_pass`, `PATCH_KEY =
"MgjDAvDBYHMthDcux0-PQvBk7Afl0U-V"`) writes the plaintext pack we see on disk.

`../patches2/` is a byte-identical hand-made duplicate (same sha256 for both packs). Nothing in the
game reads it — the updater only knows `DIR = "user://patches"`. Treat it as the pristine backup.
`../bridge_0.1.273_to_0.2.0.pck.part0` (0 B, in `app_userdata/`, not in `patches/`) is a dead
multi-part download remnant; inert.

## 2. Mount order and who wins

`Updater._init()` (runs before any other autoload, therefore always the **base** copy of the
script — an autoload resolves `res://…` before the packs that would override it are mounted):

```gd
ProjectSettings.load_resource_pack(user://patches/bridge_0.1.273_to_0.2.0.pck)   # first
ProjectSettings.load_resource_pack(user://patches/patch_0.2.3.pck)               # second
```

`load_resource_pack` pushes the pack to the **front** of the search list, so the last one mounted
shadows the earlier ones. Verified empirically on this host with two hand-made packs
(`work/logs/packorder/`, `probe.gd`, Godot 4.7.2 headless):

```
load A(…/A.pck) -> true
load B(…/B.pck) -> true
MARKER res://a.txt = LAYER_B       # later-mounted pack wins
MARKER res://only_b.txt = B_ONLY   # members unique to one layer stay visible
```

**Effective precedence for any file: `patch_0.2.3.pck` > `bridge…pck` > `MidgardSurvivors.pck` (0.1.273).**

Same probe also showed a mounted pack does **not** change running `ProjectSettings`
(`application/config/name|version` and a custom key stayed unchanged) — consistent with the game's
own bookkeeping (`_base` vs `_eff_base`), and it means the `project.binary` inside the bridge pack
never takes effect at runtime. Patches therefore cannot add autoloads or change project settings.

## 3. Integrity, tampering, and re-download behaviour

| Check | Where | Consequence |
| --- | --- | --- |
| sha256 of a **downloaded** pack | `updater.gd:378` `FileAccess.get_sha256(tmp) != patch.sha256` | download-time only, on the temp file, before `_decrypt` |
| hash of the **on-disk** pack at mount | — | **none.** `load_resource_pack` only needs a readable GDPC header → an edited pack is mounted silently |
| `state.base != ProjectSettings version` | `updater.gd:96` | `_clear_patches()` **deletes every file in `patches/`**, runs stock 0.1.273 |
| manifest version newer than local | `updater.gd:_on_manifest` | dialog → download → replaces the pack file and deletes the old one → **our edits are lost** |
| runtime "HP seal" | `player.gd:67-90 _reseal/_check_seal` | detects out-of-game HP writes (trainer) → sets `tampered`, blocks titles/feats + flags leaderboard. **Not** a file check; edited balance code is invisible to it |
| any pck/asset hash, signature, anti-cheat | — | none found across the 167-script effective tree (only `cloud_save.gd` content-hash dirty-flag + AES key derivation, and an RSA pair used for signed kick/dev messages) |

Updater off-switches (all verified in `updater.gd:_enabled()`): any CLI user-arg starting with
`--` except `--update-url`/`--lang` (that is why `-- --disable-updater` works, and also why
`-- --tips-test …` skips patches); a `coop_preview.txt` file next to the executable; macOS; web;
editor. `--update-url <url>` is honoured, so a self-hosted `manifest.json` is a supported channel.

## 4. Where the balance lives (this is the decisive fact)

`patch_0.2.3.pck` **replaces the whole gameplay script layer**:
`scripts/autoload/game_data.gdc` (the const tables: `MONSTERS`/`SKILLS`/`ITEMS`/`STAGES`), plus
`enemy`, `main`, `player`, `tower_run`, `tower_events`, `skills`, `summons`, `equipment`, `uniques`,
`trade`, `titles`, `karma`, `homunculus`, `job_engines`, `leaderboard`, `run_save`, `save`,
`net_sync`, `town`, `menus`, `hud`, … (58 scripts). The bridge replaces 117.

Consequence: **editing `game_data.gd` in the retail 0.1.273 PCK has no effect at all** — the patch
layer shadows it. Files that no patch touches (all `.tscn`/`.tres`, models, most audio, and
`project.binary`) are still served from the base PCK, so *scene* edits must go into the base pack.

Rule of thumb: **write your file into the highest layer that already ships it** — for gameplay
scripts that is `patch_0.2.3.pck`; for files only in the bridge (e.g. `tower_traps.gdc`,
`hel_tower.gd`) also put them in `patch_0.2.3.pck`, which wins by mount order.

## 5. Artifacts in this directory

| Path | Contents |
| --- | --- |
| `raw_0.2.3/`, `raw_0.2.0/` | raw `.gdc` members of the two packs (`--extract --include='*.gdc'`) |
| `base_remaps/` | the 134 `.gd.remap` files extracted from the retail PCK (needed to name the originals) |
| `merged_probe.pck`, `build_0.2.0(.pck)` | bridge/patch packs with the base remaps grafted on (`--pck-patch`) so `--recover` can decompile them |
| `scripts_full_0.2.3/` (58 `.gd`), `scripts_full_0.2.0/` (117 `.gd`) | per-layer decompiles |
| **`effective_0.2.3/`** | **167 `.gd` = base(0.1.273) ← bridge ← patch, the tree the shipped game really executes. Read this one — and edit THIS one: it is git-tracked, so `git diff v0.2.3-decompiled -- work/60_patches/effective_0.2.3` after an edit is the whole mod.** |
| `build/`, `out/` | generated: `build/*.gdc` (GDRE compile of the edited scripts) → `out/patch_0.2.3.pck` (shippable pack). Ignored by git, rebuild with the block below |
| `probe_fidelity/` | `game_data.gdc` recompiled from its own decompile (194 B / 0.05 % smaller than the shipped one → GDRE round-trip is *not* byte-provable, which is why we prefer editing small scripts) |

Recipe that produced them (GDRE only decompiles a `.gdc` when a matching `.remap` sits beside it,
hence the graft step; the 33+9 scripts that are *new* in the patches were finished one-by-one with
`--decompile=<file.gdc> --bytecode=4.5.0-stable`):

```sh
. /media/jang/home/PortableApp/re/activate.sh
G=/media/jang/home/PortableApp/re/bin; W=/media/jang/free/MidgardSurvivors/zen-rea/work
P="/home/jang/.local/share/godot/app_userdata/Midgard Survivors"
"$G/gdre_tools" --extract="$P/patches/patch_0.2.3.pck" --include='*.gdc' --output=$W/60_patches/raw_0.2.3
"$G/gdre_tools" --extract="$PCK" --include='*.remap'  --output=$W/60_patches/base_remaps      # PCK = retail pack
"$G/gdre_tools" --pck-patch="$P/patches/patch_0.2.3.pck" --patch-file=<remap>=res://<path>.gd.remap … \
                --output=$W/60_patches/merged_probe.pck
"$G/gdre_tools" --recover=$W/60_patches/merged_probe.pck --scripts-only --output=$W/60_patches/scripts_full_0.2.3
```

## 6. Mod pipeline (recommended: patch the patch)

Launcher: **`../../play.sh`** (`--status` shows the effective version and flags a MODIFIED pack by
sha256, `--layer <file>` answers "which pack owns this member", `--isolate` runs against a sandbox
`user://` so real saves are never touched). Note §3: passing anything after `--` turns patch mounting
off, so the mod must be tested without such args.

```sh
# one edited script, e.g. the balance table (edited under effective_0.2.3/, the git-tracked source)
cd $W/60_patches
mkdir -p build out
"$G/gdre_tools" --compile=effective_0.2.3/scripts/autoload/game_data.gd --bytecode=4.5.0-stable --output=build
#   -> build/game_data.gdc (GDSC rev 101)
"$G/gdre_tools" --pck-patch="$P/patches/patch_0.2.3.pck" \
   --patch-file="$PWD/build/game_data.gdc=res://scripts/autoload/game_data.gdc" \
   --output=$W/60_patches/out/patch_0.2.3.pck                          # ~11 MB, preserves format 4
# verify offline, then swap (keep the original in patches2/)
"$G/gdre_tools" --list-files=$W/60_patches/out/patch_0.2.3.pck | tail -2
"$G/gdre_tools" --extract=$W/60_patches/out/patch_0.2.3.pck --include='res://scripts/autoload/game_data.gdc' --output=verify
sha256sum build/game_data.gdc verify/scripts/autoload/game_data.gdc
```

Build the file list from git, so nothing edited can be forgotten:

```sh
cd "$W/.."                              # = zen-rea/, the git repo
ARGS=()
for gd in $(git diff --name-only v0.2.3-decompiled -- work/60_patches/effective_0.2.3 | grep '\.gd$'); do
  res="res://${gd#work/60_patches/effective_0.2.3/}"; res="${res%.gd}.gdc"
  "$G/gdre_tools" --compile="$gd" --bytecode=4.5.0-stable --output="$W/60_patches/build"
  ARGS+=("--patch-file=$W/60_patches/build/$(basename "$res")=$res")
done
"$G/gdre_tools" --pck-patch="$P/patches/patch_0.2.3.pck" "${ARGS[@]}" \
                --output="$W/60_patches/out/patch_0.2.3.pck"
```

* `--pck-patch` never touches the input file, so the live pack stays intact until we move the output
  in place deliberately (`cp out/patch_0.2.3.pck "$P/patches/"`, after backing the original up).
* Rollback: restore the backup (or delete `patches/` → the game runs stock 0.1.273 until the next
  update dialog).
* No GDRE path exists for `project.binary`/ECFG, so **project settings cannot be modded this way**;
  and patches could not change them even for the devs.
* Alternative if we want the official pack to stay byte-identical: edit the **base** pack's
  `updater.gd` to also mount `user://patches/mod.pck` *after* the official ones, then iterate on
  `mod.pck` only. Costs a full writable copy of the game directory (~1 GB, hardlinkable except the
  PCK) and one extra `--pck-patch` of the 557 MB pack. Worth it only if we expect many iterations.

## 8. Version control of this work

One repo at the project root, default-deny `.gitignore` (text only: 177 files / 5.6 MB → GitHub).
`effective_0.2.3/` is committed and tagged **`v0.2.3-decompiled`**, so the pristine live build is the
baseline and every balance edit is a reviewable `git diff` that also drives the build list above.
`work/40_mod/.git` was deleted 2026-11-19 (813 MB of objects for a 2.0 GB duplicate of
`30_recovered/`, path+size identical and a 60-file md5 sample with zero mismatches).

## 7. Balance map (v0.2.3, for the nerf work)

Scaling clock inside a round — `main.gd:4936 scale_time()` = raw elapsed seconds in a stage, or
`(eff()-1) * TOWER_FLOOR_TIME(5.0)` / `TOWER_BOSS_FLOOR_TIME(15.0)` on tower floors; consumed at
`main.gd:5429-5440`:

| Knob | v0.2.3 | Note |
| --- | --- | --- |
| `game_data.gd:11355 scale_hp` | `1.0 + t / 150.0` | crowd HP; 5× @10 min, 9× @20 min. Also drives mob damage |
| `game_data.gd:11361 scale_boss_hp` | `1.0 + t / 600.0` | boss/elite HP |
| `game_data.gd:11351 spawn_rate` | `1.0 + t / 170.0` | spawn frequency |
| `enemy.gd:240` | `damage = def.damage * (1.0 + (time_scale - 1.0) * 0.6) * 1.25` | HP curve reused as damage curve |
| `game_data.gd:44 / :60` `TOWER_HP_STEP / TOWER_DMG_STEP` | `1.06` / `1.035` per floor (`tower_run.gd:908-920`), vs player `TOWER_FLOOR_DMG 1.02` (:103) | 4 %-point/floor compounding gap |
| `game_data.gd:119 HEL_TOWER_PACE` | `5.0` | Hel tower evaluates floor `f` as `100 + 5f` (`tower_run.gd:97-100`) — the real high-floor wall |
| `game_data.gd:9791/9797 HELL_HP / HELL_HP_LATE` | `2.0` / `2.15` per hell level, `HELL_HP_SQUEEZE` (:9807) | steepest term in the game; `_LATE` + `SQUEEZE` + `TOWER_PAST_*` are all **new in the patches** |
| `game_data.gd:1613/1614 ENDLESS_MOB_HP_GROWTH / _DMG_` | `1.36` / `1.22` per 40 s endless step | |

Tower hazards ("ground strike / lightning / laser") — `scripts/core/tower_traps.gd` (bridge layer),
scheduled from `tower_run.gd:213`, active `bolts` ≥ floor 5, `beam` ≥ 12, `spikes` ≥ 20, `boulder` ≥ 28
(`game_data.gd:348-353`):

| Hazard | Line |
| --- | --- |
| lightning `Rayo de la torre` | `tower_traps.gd:142` → `world._hell_blast(spots, 1.7, cast, pct, …)` |
| ground strike `Púas de la torre` (10 blasts) | `tower_traps.gd:196` → same |
| laser `Viga arcana` | `tower_traps.gd:180` `h.take_damage(h.max_hp * pct, world, null, true)` |
| boulder `Roca de la torre` | `tower_traps.gd:234` (same shape) |
| safe-circle burst `Estallido de la torre` | `tower_traps.gd:115` (called with `pct * 1.5`) |

`_hell_blast` routes to `Player.hell_hazard` (`main.gd:15406-15407`), which lands at
`player.gd:3412`:

```gd
take_damage(max_hp * pct * (1.0 + GameData.HELL_STILL_STEP * _hazard_stack), world, null, true, true)
```

`pct` is a share of **our own max HP** — `tower_traps.gd:46-50`: `TOWER_TRAP_PCT 0.05` +
`TOWER_TRAP_PCT_STEP 0.0015 × (floor-5)` capped by `TOWER_TRAP_PCT_MAX 0.16`, then
`+ TOWER_PAST_TRAP_PCT_STEP 0.0014` per floor past 100 up to `TOWER_PAST_TRAP_PCT_MAX 0.3`;
`HELL_STILL_STEP 0.5 × HELL_STILL_MAX 4` = ×3.0 for not moving 2.5 m within 25 s ⇒ **0.9 × max_hp in
one hit**, ×(10 spikes / 5 bolts / 2 beams), with `many = 1 + past150 + past250` concurrent hazards
and a cadence that tightens to 2.0 s. Because the call passes `pierce=true, hazard=true` it skips
armour+VIT (`player.gd:3558`), skips grade mitigation (`:3459`), cuts Guard chance ×0.25
(`:3509`, `HELL_BLOCK_MULT`), pierces 60 % of shields (`:3560`, `HELL_SHIELD_PIERCE`), and is
explicitly excluded from the "¡Aguanta!" one-hit death save (`:3600-3604`).

## 9. Mod v1 — installed 2026-11-19 (built pack sha `954f68c592f08da0…`)

Trigger: a real 0.2.3 run died at **Endless Tower floor 267 to `Roca de la torre`** (22 min, Lv 460,
134.9 Qi/s, 4.6 M damage taken). Three scripts edited under `effective_0.2.3/`, nothing else touched
— `game_data.gd`, `main.gd` and `player.gd` stay byte-untouched on purpose (§5 `probe_fidelity/`).

| Knob (file) | Vanilla | Mod v1 | Why |
| --- | --- | --- | --- |
| `MOD_TOWER_FLOOR_CAP` (`core/tower_run.gd:8`) — exponent of `TOWER_HP_STEP` / `TOWER_DMG_STEP` | unbounded: floor 267 → HP ×5.4e6, dmg ×9 414 | `90.0` → past floor ~91 HP ≤ ×189, dmg ≤ ×22 | floors 1-90 stay exactly vanilla; the exponential tail (and Hel `eff() = 100 + 5f`, which is what makes a "floor 20" be evaluated as floor 200) is what is absurd. Speed growth left alone |
| `MOD_TIME_SCALE_CAP` (`core/enemy.gd:212`) — round clock `scale_hp = 1 + t/150` | floor 267 ⇒ `scale_time` 1 330 s ⇒ HP ×9.87, contact dmg ×7.90 | `3.0` ⇒ ×3.00 and ×2.75 | clamped *by dividing the excess time factor out of* `hp_scale`, so the danger/hell/coop/karma multipliers inside it are preserved; the same cap bounds `time_scale`, which feeds `damage` at `enemy.gd:243` |
| `MOD_TRAP_PCT_CAP` (`core/tower_traps.gd`) | hazard = 30 % of *our own* max HP per hit at floor 267; ×3.0 from the stillness stack ⇒ 90 % | `0.1` ⇒ 10 %, worst 30 % | clamped in `tick()` **and** in all five leaf hazards (`_bolts`, `_beams`, `_spikes`, `_boulder`, `_refuge`), so `survive_strike()` cannot bypass it |
| `MOD_TRAP_EVERY_MIN` | cadence tightens to 2.0 s past floor 100 | `4.0` s | half as many hazards |
| `MOD_TRAP_MAX` | `many` = 3 concurrent hazards ≥ floor 250 | `2` | |

Not changed (next levers if high-`danger` stages still feel unfair — all of these live in
`game_data.gd`, so using them means recompiling that 11 762-line file): `HELL_HP 2.0` /
`HELL_HP_LATE 2.15` per hell level, `DANGER_HP_CROWD(_LATE) 1.24/1.34`, `ENDLESS_MOB_HP_GROWTH 1.36`
per 40 s, `spawn_rate 1 + t/170`, `TOWER_CROWD 32`. A cheaper alternative that keeps `game_data.gd`
untouched: cap the *total* multiplier arriving in `Enemy.setup` (a `MOD_HP_SCALE_CAP` alongside
`MOD_TIME_SCALE_CAP`), which trims the hell tail without touching the tables.

Build / ship / undo (one command each, all verified offline — only the game launch is a human step):

```sh
./build.sh                 # compile changed scripts -> out/patch_0.2.3.pck + member-hash verification
./build.sh --install       # + back the official pack up to orig/ and drop it into user://patches
./build.sh --restore       # put the pristine official pack back
./build.sh --diff          # review the source changes (git diff against v0.2.3-decompiled)
```

`build.sh` derives its file list from `git diff v0.2.3-decompiled`, always patches the **official**
pack (`orig/` once it exists, so mods never stack), refuses a modded base pack, and checks that every
other member survived. Verification evidence for v1: `members 123 -> 124` (the added one is
`res://scripts/core/tower_traps.gdc`, which no layer shipped in this pack), 3/3 replaced members
sha256-match `build/*.gdc`, all 120 other members present, and `decompile(compile(source))` differs
from the source only by stripped comments — i.e. the shipped bytecode carries exactly our edit.

## 10. What happens when the developer ships an update

Nothing of ours survives an official update by design — and nothing breaks either. All three code
paths in `updater.gd` discard the mod, they never merge with it:

| Situation | Code | Effect on the installed mod |
| --- | --- | --- |
| new incremental patch (0.2.4) | `_on_patch()` → writes `patch_0.2.4.pck`, rewrites `state.json`, then `DirAccess.remove_absolute(DIR.path_join(old))` | our `patch_0.2.3.pck` **is deleted**, and the new pack replaces the files we edited → mod gone |
| new base build (`manifest.base` ≠ our `_eff_base`) with a `legacy[0.1.273]` entry | `_adopt_bridge()` / `_download(..., as_bridge = true)` | bridge replaced, old packs deleted → mod gone |
| new base build, no legacy bridge | `_show_new_build()` → itch.io download | new executable + new `MidgardSurvivors.pck`; on first run `state.base != _base` → `_clear_patches()` **wipes the whole `patches/` folder** → mod gone |
| download/manifest unreachable | `_on_manifest()` returns early | **mod stays**: packs on disk are never re-hashed, so we keep playing our build |

So the question is not *whether* we have to re-apply, but how cheaply. The mod is only a 142-line
diff (`mod-latest.patch`, regenerate after any change with
`git diff v0.2.3-decompiled -- effective_0.2.3 > mod-latest.patch`), and a diff can be **3-way merged**
onto the next decompile. Measured on this host with GNU patch 2.8.1 against a tree where a developer
had renamed `TOWER_TRAP_PCT_MAX` and inserted a line inside our target function:

```
patching file scripts/core/enemy.gd                       <- clean
patching file scripts/core/tower_run.gd                   <- clean
patching file scripts/core/tower_traps.gd
Hunk #3 NOT MERGED at 57-61, merged at 63                 <- conflict, exit code 1, <<<<<<< markers
```

i.e. silent where the code still matches, **loud** where it does not — never a half-silent build,
because `build.sh` compiles whatever is in the tree and its member-hash step reports every file.

Runbook after an update:

```sh
# 1. assemble the new tree (PATCH_SYSTEM.md §5, ~3 min): effective_0.2.4/
# 2. merge the mod into it
cd work/60_patches/effective_0.2.4 && patch -p4 --merge < ../mod-latest.patch   # -p4 -> paths relative to this dir
grep -rn '^<<<<<<<' scripts/                                               # resolve any conflict by hand
# 3. rebuild + install (BASE_TAG must point at the new pristine baseline commit)
cd .. && BASE_TAG=v0.2.4-decompiled ./build.sh --install
./play.sh --status                                                         # -> MODIFIED + new sha
```

Prefer `git apply -3` (default `-p 1`) when the new tree lives at the same path inside this repo —
then the pristine blobs from the baseline tag are the merge base.

**Making the mod survive the update itself** (optional, not currently done): the updater mounts only
`state.bridge` + `state.file`, so a third pack can only be mounted by editing `updater.gd` — which
lives in the *base* pack, so it costs a writable copy of the game directory (~634 MB, hardlinkable
except the pack) plus one `--pck-patch` of the 557 MB pack. `mod.pck` must then sit **outside**
`user://patches`, because `_clear_patches()` deletes every file in that folder; `user://mod/mod.pck`
is never touched. That buys "our layer is still mounted after their update", **not** "our layer is
still correct": our members replace whole scripts, so an old mod would *undo* their changes to those
three files until re-merged. The merge step is unavoidable either way, which is why the tracked-diff
workflow above is the primary mechanism and the custom `updater.gd` is only a convenience.

Two traps on the next update, both cheap to check:

* **Bytecode revision.** Our scripts are compiled for revision 101 (`--bytecode=4.5.0-stable`). If a
  future build bumps the export template, the packs' `.gdc` headers change and GDRE will need a new
  token. Read it straight off the new pack before compiling:
  `head -c 8 <extracted>.gdc | od -An -tu1` (bytes 5-8, little-endian) and pick the token from
  `gdre_tools --list-bytecode-versions`; `build.sh` takes it as `BYTECODE=<token> ./build.sh`.
* **`state.json` `version` vs the manifest.** While the manifest keeps offering 0.2.3, nothing is ever
  re-downloaded (`_newer()` is false), so an installed mod is stable. Only a genuinely newer version
  triggers the paths in the table above.

## 11. Mod v2 — adventure/hell "Mechanics" cap + in-game proof (installed 2026-11-19)

Evidence from a real adventure run (Thor Volcano, Hell 14, Hard, Frenzy, 40:00, Lv 519, ~1 M HP):
damage **taken** 11.4 M of which **"Mechanics" 7.1 M (62 %)**, `Hits 54`, `Max hit 514k`, `Average 131k`.

**Why "Mechanics" is a category at all** — `World.meter_take()` (`core/main.gd:7123`):

```gd
	var key: = "mechanics" if pierce else "shots"
	if from != null and is_instance_valid(from):
		key = from.id if not pierce else "mechanics:" + from.id
```

so the plain *Mecánicas* row = **every `take_damage(…, from = null, pierce = true)`** (`taken_label()`
`core/main.gd:7267`). The `hazard` flag is irrelevant to the category, it only changes in-hit math.
Ten such sites exist; only three of them pass through `Player.hell_hazard()`, so a cap there is not
enough — the choke point has to be `Player.take_damage()` itself:

| pct (share of *our* max HP) | source | route |
| --- | --- | --- |
| 0.15 hell rain (`HELL_RAIN_PCT`, every 9 s × `hell_pace()`) | `main.gd:15365` | `hell_hazard` |
| 0.18 wandering meteors (`HELL_METEOR_PCT`, every 14 s) | `main.gd:15321` | `hell_hazard` |
| 0.12 Surtr heralds (`HELL_HERALD_PCT`, 3 s each) | `main.gd:15205` | `hell_hazard` |
| 0.08 revenge of the fallen (`HELL_REVENGE_PCT`) | `main.gd:11435` | `hell_hazard` |
| 0.1 × ability dmg ⇒ 0.14-0.18 shadow-MVP mechanics (`HELL_SHADOW_PCT`, Ifrit 1.8/1.5/1.5/1.4) | `hell_late.gd:318` | `hell_hazard` |
| 0.08 storm bolts (`STORM_PCT`, 3 bolts / 12 s) | `main.gd:15409` | **direct** |
| ≤0.12 Niflheim fog, **1 Hz** (`HELL_FOG_PCT + RAMP·t` capped by `_MAX`) | `hell_late.gd:477` | **direct** |
| 0.025 pool / **0.30** burst (`MARK_POOL_PCT`, `MARK_PCT`) | `hell_late.gd:1371`, `:1459` | **direct** |
| 0.06 corrupt burst (`KARMA_ROUTES.dark.foe_burst`) | `karma.gd:287` | **direct** |
| tower hazards | `tower_traps.gd` | already capped by mod v1 leaves |

**Their 514 k is exactly the vanilla worst case:** highest `pct` available at Hell 14 is 0.18 (meteor,
or shadow `0.1 × 1.8`), times the stillness stack `1 + HELL_STILL_STEP 0.5 × HELL_STILL_MAX 4 = 3.0`
⇒ **0.54 × 1 M ≈ 540 k**; average 131 k ⇒ typical 0.08-0.18 with a 0-1 stack. No adventure hazard
ramps `pct` with time — only cadence (`hell_pace()`) and the stack. And `plain` at `player.gd:3600`
excludes pierce hits from the "¡Aguanta!" save, so nothing absorbs it: two stacked hits = death.
Worse, `player.gd:3466` multiplies hazard damage by `1 + HEL_PACT_TAKEN 0.2 × karma boons` (unbounded),
which alone can push a hit past 100 % of max HP.

**Fix (4th file: `core/player.gd`).** Ceiling applied after every mitigation and before shields absorb,
keyed on the same predicate the report uses, so it covers all ten sites and any future one:

```gd
	if pierce and from == null and amount < max_hp * MOD_MECH_EXECUTE_OVER:   # 4x: tour/debug executes use 1e9..1e12
		var ceiling: = max_hp * MOD_MECH_PCT_CAP                            # 0.15 -> 54% becomes 15%
		if amount > ceiling: amount = ceiling
```

`MOD_MECH_PCT_CAP = 0.15`, `MOD_MECH_EXECUTE_OVER = 4.0`. Consequences: worst hazard 0.54 → **0.15**
of max HP, so 4 clear hits are needed; `hel_pact` boons still multiply but the ceiling is applied after
mitigation, so a boon-scaled hit is capped too; the game's own debug/tour executions (1e9..1e12) are
untouched; ordinary enemy contact/projectiles (`from != null`) and mob specials are unaffected.
Not changed on purpose: the "¡Aguanta!" save stays excluded for hazards (that is a design decision,
available as an option if 15 % still feels unfair in bursts).

**Runtime proof that the mod is what is running.** Each patched script now reports itself once from
inside the game — `print()` reaches `user://logs/godot.log` (file logging is on by default; the game's
own `HITCH`/`LOAD` lines prove it) and a small file lands in the user dir:

| file | written when |
| --- | --- |
| `user://mod_probe_enemy.txt` | first monster spawn (any mode, seconds after a run starts) — tag + all 4 cap values |
| `user://mod_probe_player.txt` | first mechanics hit that got capped — label, hit before/after, max HP, share |
| `user://mod_probe_traps.txt` | first tower hazard (floor ≥ 5) — floor + clamped pct, proves the added member beats the bridge |

`./play.sh --probe` prints them and compares their timestamps with the installed pack, so
"did the new build actually load?" is a yes/no answer instead of a guess.

**Process lesson, kept as a gate.** The `player.gd` patch was first written with a match string that
covered only `extends Node` of `extends Node3D`, leaving `false3D` behind and silently changing the base
class. GDRE's `--compile` did **not** reject it (no project context = no full analysis); the round-trip
decompile exposed it. `build.sh` now refuses to build unless every source line that disappears is either
re-added verbatim or listed in `lint-allow.txt` (the three lines the mod genuinely rewrites), and
`--deep` decompiles the built `.gdc` and lists source lines it cannot show back.

### v3 (same session): probes that also measure the effect

The v2 probe printed `%.1f` literally (a format placeholder inside a `const` string) and only wrote a
file when a hit was actually capped - absence was therefore ambiguous. v3 (built sha `405d4f477bc5e166…`)
reports values as literals and turns the probes into counters:

* `mod_probe_enemy.txt` — rewritten every 512 spawns: `spawns=`, `clock_capped=n (%)` = how often the
  round-clock cap actually engaged.
* `mod_probe_player.txt` — first mechanics hit and every 8th: `hits`, `capped`, `avoided_total`
  (damage the cap absorbed), `worst_hit` and its share of max HP, `last_label` = the Spanish source
  name (`Meteoros errantes`, `Tormenta`, `La niebla de Niflheim`, …) so we can see *which* mechanic
  dominates instead of the aggregate "Mechanics" row.

Both blocks were executed verbatim under the real Godot 4.7.2 headless (throwaway `/tmp/probefmt`
project, code extracted from the sources with awk) before shipping — the only way to catch
format-arity mistakes, since GDRE compiles them happily and the game would just print garbage.

## 12. Mod v4 — level-up rarity (installed, pack sha `3fa02c7bff41e017…`)

**The roll.** `add_xp` → `leveled_up` (cosmetic only) → `main.gd:4492` opens the panel →
`World.level_choices()` → `Player.offered_choices()` → `build_choices()` → `_choice_pool()` →
`_pick_choices()` (weighted by entry `w`, *no rarity yet*) → then **one independent roll per card** in
`Player._roll_rarity()` (`core/player.gd:5188`), whose only randomness is a single `randf()` over
`GameData.CHOICE_RARITY`:

```gd
	const CHOICE_RARITY: = [                       # game_data.gd:8585
	{"name": "Común",      "steps": 1, "w": 70.0},
	{"name": "Rara",       "steps": 2, "w": 22.0},
	{"name": "Épica",      "steps": 3, "w": 7.0},
	{"name": "Legendaria", "steps": 3, "w": 1.0, "all_stats": 1}]
	const CHOICE_LUK_SHIFT: = 1.2
```

P(tier) = `w/Σw`, and luck moves mass out of Común (`shift = min(w0 - 20, 1.2 * eff_stat("luk"))`), so
at 0 luck a legendary is **1 %** and even at the luck ceiling only **2.7 %**. No pity, no per-run cap,
no per-stage/danger/time ramp — that 1 % is all you ever get.

**The change** is a pure insertion in `_roll_rarity`, so `game_data.gd` stays byte-untouched: the
shipped table is read, then `w` is overwritten with `MOD_CHOICE_W = [52, 27, 15, 6]`; the roll, the
luck shift, `steps` and `all_stats` still come from the shipped rows, and `rarity` still indexes
`CHOICE_RARITY`, so colours/sounds/ribbons/`Legendaria · +3` are the game's own.

Measured with the real Godot 4.7.2 runtime, replaying the extracted function body (200 000 rolls per
cell, vanilla vs mod):

| luck | vanilla | mod v4 |
| --- | --- | --- |
| 0 | 69.9 / 22.1 / 7.0 / **0.97 %** | 52.1 / 26.9 / 15.0 / **6.00 %** |
| 10 | 58.1 / 30.8 / 9.8 / 1.33 % | 37.6 / 35.2 / 19.5 / **7.76 %** |
| 20 | 46.0 / 39.6 / 12.6 / 1.83 % | 24.3 / 42.7 / 23.6 / **9.44 %** |
| ≥ ~27 (ceiling) | 22.4 / 56.8 / 18.3 / 2.56 % | 16.9 / 46.8 / 26.1 / **10.24 %** |

Your last run had LUK 131 ⇒ `eff_stat` = `_capped(base) + _capped(run)` with `MAX_STAT 10` and
`OVERSTAT_EFF 0.5` ⇒ far past the shift ceiling, so expect the bottom row: roughly **1 legendary in 10
offers** (was 1 in 40), epic+legendary ≈ 36 %.

**Side effects to know about**

1. A legendary offer also grants `all_stats: 1` = **+1 to every stat** (`player.gd:5329-5331`), so ~7 %
   of ~500 picks ≈ +35-50 to all six stats per run instead of ~5. That is the game's own reward, not a
   new mechanic — but it is the dominant power effect of this change. If it turns out too strong,
   the honest knob is `MOD_CHOICE_W` (use e.g. `[60, 27, 10, 3]` for half the rate).
2. `steps = 3` on a skill already at `MAX_SKILL_LEVEL 5` is wasted unless `grows_past_cap(id)`, so
   maxed builds will see more dud cards. Fixable later by skipping tiers 2-3 for entries at cap.
3. Scope is exactly the level-up-style flows: level-up, the Sage start box, reroll, banish replacement,
   autopick, and (in co-op) the host's rolls. **Untouched:** gear drops (`LEGENDARY_CHANCE 0.0075`,
   `ELITE_LEGENDARY_CHANCE 0.0008`, `HELL_LEGEND_EACH/_STEP`, `TOWER_FACE_LEGEND*`), gacha
   (`GACHA.odds.legendary 0.01`, pity 12), star smith, tower blessings/wheel, Morroc toys.
4. `ui/guide.gd:77` builds the help text from the shipped table, so the in-game guide will still quote
   the vanilla odds.

**New probe:** `user://mod_probe_choices.txt` (rewritten every 64 rolls) shows the measured
distribution — `rolls=… Epica=… Legendaria=… P(legend)=x.x%` — so the rate is verifiable from your own
run instead of from this table.

## 13. Mod v5 — Tower wheel rebalanced (installed, pack sha `c2900c95fb773704…`)

`GameData.TOWER_WHEEL` (`autoload/game_data.gd:298`) is a 10-slot rim rolled by the single
`TowerEvents._wheel_pick()` (`core/tower_events.gd:483`, one `randf()`), used for every spin
(`TOWER_WHEEL_SPINS = 4` per event, solo: `_wheel_turns()` returns `[]` so the loop runs 4 times), plus
the host-side timeout re-roll in `_tick_wheel`. Shipped weights: 5 buffs `w=12`, 4 curses `w=8`,
`super` `w=3` (Σ 95).

Re-weighted by id inside `_wheel_pick` via the inserted `_wheel_w()` helper (`MOD_WHEEL_W`), so the
table, the `mods`, the `floors` duration of curses and the whole UI stay as shipped. Measured with the
real Godot runtime by replaying the patched `_wheel_pick` (200 000 events × 4 spins, vanilla twin
side by side):

| slot | vanilla | mod v5 |
| --- | --- | --- |
| `super` — ¡GRACIA DE LUCILE! (+50% dmg, +40% hp, +25% aspd, +15% move, permanent) | 3.15 % | **28.04 %** |
| each buff (Furia / Corazón de hierro / Pulso veloz / Suerte / Viento) | 12.6 % | 14.1 % |
| each curse (`curse_dull` -20% dmg, `curse_frail` -20% vida, `curse_heavy` -15% mov, `curse_slow` +25% rec) | 8.4 % | **0.39 %** |
| per event (4 spins): at least one curse | **80.7 %** | **6.1 %** |
| per event: at least one super | 12.0 % | **73.2 %** |

Probe: `user://mod_probe_wheel.txt` (rewritten every 4 spins) → `spins=… super=… (P=x%) fury=… …`.
