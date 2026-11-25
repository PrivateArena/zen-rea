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

## 14. Update 0.2.3 -> 0.2.4, as executed (2026-11-20) — §10 recipe is now PROVEN

What the updater did to us: `patch_0.2.3.pck` (our modded copy) was **deleted**, `patch_0.2.4.pck`
(12.7 MB, 167 members vs 123, nothing removed => each patch pack is cumulative over the bridge) written,
`state.json` rewritten, and the unknown directory `patches2/` — where we kept a pristine backup —
**wiped**. Lesson recorded in `play.sh`: pristine packs now live only outside `user://`, in `orig/`.

Migration commands (all of them ran clean; keep this as the runbook):

```sh
cp "$P/patches/patch_0.2.4.pck" orig/                        # pristine copy BEFORE anything else
gdre_tools --extract=orig/patch_0.2.4.pck --include='*.gdc' --output=raw_0.2.4          # 87 scripts
for g in $(find raw_0.2.4 -name '*.gdc'); do                # per-file decompile, no remap grafting
  gdre_tools --decompile="$PWD/$g" --bytecode=4.5.0-stable \
             --output="$PWD/scripts_full_0.2.4/$(dirname ${g#raw_0.2.4/})"; done        # 87/87 ok
rm -rf effective_0.2.4 && mkdir -p effective_0.2.4
cp effective_0.2.3/project.godot effective_0.2.4/
for L in ../25_scripts scripts_full_0.2.0 scripts_full_0.2.4; do
  for sub in scripts addons; do [ -d "$L/$sub" ] && cp -r "$L/$sub/." effective_0.2.4/"$sub"/; done
done                                                        # 171 .gd (4 new) => tag v0.2.4-decompiled
patch -p4 -d effective_0.2.4 --merge --dry-run < mod-latest.patch   # 0 conflicts, then for real
MOD_VER=0.2.4 ./build.sh --deep --install                   # MOD_VER only needed if state.json lags
```

Dev changes vs our tree: 104 of 167 scripts byte-identical, **63 changed, 4 new**
(`core/perf_watch`, `core/souls`, `core/soul_icon`, `ui/bestiary` + `pact_*` skill icons). Of *our* five
patched files: `enemy.gd` and `tower_traps.gd` untouched by the dev, `tower_events.gd` 4 lines,
`tower_run.gd` 51, `player.gd` 291 — and `mod-latest.patch` still applied with **zero conflicts**, which
is the payoff of keeping every mod as a pure insertion at a named choke point.

New 0.2.4 systems worth knowing before we mod further (from `game_data.gd` const diff, 667 changed lines):
souls as a 12th equip slot (`EQUIP_SLOTS` + `"soul"`, `SOUL_POT_REFUND`, `LEGEND_SOUL_PRICE`), hit-steady
`MOB_HIT_*`/`HIT_RESIST_VIT` with `MOB_HIT_TOWER_FLOOR`/`MOB_HIT_ENDLESS_STEP`, `FOCUS_*`, `HARMONY_*`
set bonus, `GRADE_PITY`/`GRADE_CHANCE_MAX`, gacha `epic_pity: 5`, and **`OATH_CURSE_MAX [0.3,0.45] ->
[0.4,0.6]`** (`oaths.gd:209` caps `oath_curse`, which is a max-HP multiplier: `max_hp *= 1 - oath_curse`,
`player.gd:1638`) — i.e. the hell-15-with-oath punishment they mention is *more* HP loss, and our
`MOD_MECH_PCT_CAP` is expressed as a fraction of that reduced pool, so it still means the same thing.
Also new: `CROWD_FUSE_MAX = 30`, which caps the fused-monster XP packing discussed in §14.1.

### 14.1 Mod v6 = v5 + `MOD_XP_MULT = 1.5` (installed, pack sha `bfc81d3a3dcaf9d0…`)

XP analysis (why the other player's 401 @ 28:45 looked "faster" than 443 @ 40:00 — it was not): the curve
`game_data.gd:11431` is `need(L) = int((4+5(L-1)+1.2(L-1)^1.6)(1+(L-1)/40))`, so cumulative XP ~ L^3.5 and
`Class EXP` on the summary is literally `roundi(player.xp_gained)` (`main.gd:16032`). Both runs measured
14.6k-14.7k XP/s; feeding our rate for his 1725 s lands on level 402. Details in §14.1 of the chat record /
`AGENTS.md`. Insertion is one line in the single writer of run XP (`player.gd:5216 add_xp`), before both
`xp_gained` and `xp` are written, so it lifts Base Lv *and* Class Lv:

| `MOD_XP_MULT` | 40-minute total XP | ≈ Base Lv | vs today |
| --- | --- | --- | --- |
| 1.25 | 44.2M | ~472 | +29 |
| **1.50** | 53.0M | **~499** | **+56** |
| 2.00 | 70.7M | ~545 | +102 |

## 15. Mod v8 — Star Potential (installed, pack sha see `./play.sh --status`)

Two independent systems. **(a) Star Crumb drops** — one roll site, `core/main.gd:11685`
`randf() < star_crumb_chance(e) * drop`, fed by `star_crumb_chance()` (`main.gd:265`): MVPs
`STAR_CRUMB_MVP 0.035`, Hel tower its own curve, otherwise `STAR_CRUMB_HELL 7.5e-5 +
STAR_CRUMB_HELL_STEP 4e-5·(hell−10) + STAR_CRUMB_OATH_STEP 1.5e-5·oath points`, and **0 below Hell 10**
(also 0 in festival mode). `MOD_CRUMB_MULT = 2.5` inserted at that single site, so MVP / Hel / hell ladder
scale together (Hell 15 without oaths 0.0275 % → 0.069 % per kill, MVP 3.5 % → 8.75 %) and the Hell-10
gate, which is the developers' farm control, is untouched.

**(b) The tier roll** — `Potential.roll()` (`core/potential.gd:124`), the only roller. Shipped:
`POTENTIAL_UP = [0.10, 0.04]` (a reroll climbs one tier with that probability, so Raro → Legendario needs
*two* successes ⇒ ~36 rolls), `POTENTIAL_SAME = 0.2` (each of lines 2 and 3 keeps the item tier with that
probability, else it drops one — a Legendario item therefore averages 1.4 legendary lines of 3, which is
the "always semi" complaint), `POTENTIAL_PERFECT = 0.2`. Replaced by `MOD_POT_UP [0.30, 0.18]`,
`MOD_POT_SAME 0.7`, `MOD_POT_PERFECT 0.3`.

**Price per reroll is deliberately NOT touched** (`potential.gd:128` still reads
`POTENTIAL_LOCK_COST = 3`, i.e. 1 / 4 / 7 / 10 crumbs per roll for 0 / 1 / 2 / 3 locks). Rationale: the
cost is the one knob that would need a rewritten shipped line *and* a re-think of every downstream price,
so keeping it shipped is the cheaper maintenance choice — the grind gets cheaper anyway because it is shorter.

Measured by executing the **real `roll()`** under Godot 4.7.2 with vanilla vs mod parameters (3 000 items
for the climb, 20 000 rolls at top tier):

| | vanilla | mod v8 |
| --- | --- | --- |
| rerolls Raro → Legendario (fresh item) | 35.7 | **10.1** |
| crumbs per item to reach Legendario — 0 / 1 / 2 / 3 locks (shipped prices) | 36 / 143 / 250 / **357** | 10 / 40 / 70 / **101** |
| legendary lines per roll at Legendario — 1/3 · 2/3 · **3/3** | 64.0 % · 31.8 % · **4.2 %** | 9.2 % · 43.0 % · **47.9 %** |
| mean legendary lines of 3 | 1.40 | **2.40** |
| perfect share of legendary lines | 20.1 % | 29.8 % |

Probe: `user://mod_probe_potential.txt` (every 8th roll) → `rolls=… tier=… legendary_lines=n/3 perfect=…
(up=[30, 18] same=0.70 perfect_p=0.30)`. Revision history: v7 additionally rewrote the lock-cost line;
reverted 2026-11-20 to keep the mod insert-only where it can be.

## 16. Mod v9 — Nakurusa refining and grading (installed, pack sha `d5979566200f1321…`)

Two mechanics, two shared choke points — both are the *displayed* number too, so no UI label can drift.

**Refining.** The chance table is `GameData.REFINE_RATES` (`game_data.gd:8051`), indexed by the item's
**current** `+N`, one row per weapon tier (`_rate_key` = `w1..w4`) plus `armor`; `MAX_REFINE 10`; failure
in the in-run path is `-1` (`equipment.gd:1613`), and `SMITH_REFINE_LUCK = 0.15` (`game_data.gd:2076`) is
*not* a rate — it is the Blacksmith/Whitesmith per-failure pity added on top (`equipment.gd:1604`, cleared
on success). Everything reads one function, `Equipment.refine_chance()` (`equipment.gd:518`): the in-run
smith roll, the Nakurusa roll (through `_ore_chance`, which then adds `ENRICHED_BONUS`/`HD_BONUS`), the
equipment-panel gauge, the refiner's `% de éxito`, and the Automatic material picker. Boosted there:
`MOD_REFINE_MULT 2.0`, `MOD_REFINE_CAP 0.85`, floored with `maxf()` so it can never be worse than shipped.
`REFINE_RATES` itself is untouched on purpose — `Equipment.refine_safe()` derives the "seguro hasta +N"
text, the ×5 protect fee trigger and the break warnings from that table.

**Grading.** One source: `GameData.grade_chance(tier, pity)` (`game_data.gd:5872`) — used by the roll
(`menus.gd:24663`), the `% de éxito` label, the post-failure hint and the hover-card pity delta. Base
`WEAPON_GRADES[].chance` = D .90 C .70 B .50 A .35 S .25 with a soft pity `GRADE_PITY 0.025`/failure,
clamped by `GRADE_CHANCE_MAX 0.75` and `GRADE_PITY_MAX 40` — no hard guarantee anywhere. **Pure insertion**
(one line before the shipped `return`) with `MOD_GRADE_MULT [1.0, 1.15, 1.5, 2.0, 2.6]` (per target tier)
and `MOD_GRADE_CAP 0.85`; the outer `maxf()` re-uses the boosted base as its floor, which is what lets the
boost pass the 0.75 cap. Prices (ore/HD/zeny) and the `GRADE_MIN_REFINE 10` gate are untouched.

Measured in real Godot 4.7.2 with the shipped tables and the patched expressions, vanilla parameters vs
mod parameters through the same code (30 000 grade rolls per tier, 3 000 random walks per refine cell):

| grade | vanilla | mod v9 |
| --- | --- | --- |
| chances D / C / B / A / S | 90 / 70 / 50 / 35 / 25 % | 90 / 80.5 / 75 / 70 / **65 %** |
| rolls per success (pity included) | 1.11 / 1.41 / 1.92 / 2.58 / **3.31** | 1.11 / 1.24 / 1.33 / 1.41 / **1.51** |
| expected cost of an S weapon | 1 324 ori + 6.6 HD + 19.9 M z | **604 ori + 3.0 HD + 9.1 M z** |

| refine, attempts `+0 → +10` (failure −1) | vanilla | mod v9 |
| --- | --- | --- |
| `w1` weapon, no smith pity / with `SMITH_REFINE_LUCK` | 46.0 / 36.3 | **15.1 / 14.3** |
| `w4` weapon or `armor`, no pity / with pity | 2 385.8 / 916.2 | **74.4 / 50.8** |
| key steps w1 +7 +8 +9 +10 | 100 / 60 / 40 / 19 % | 100 / 85 / 80 / **38 %** |
| key steps w4 +5 … +10 | 60 / 40 / 40 / 20 / 9 % | 85 / 80 / 80 / 40 / **18 %** |

The `w4`/`armor` gain is deliberately large: the walk-with-`-1` cost is exponentially sensitive to the last
steps, and 9 % was where the mechanic stopped being fun.

## 17. Mod v10 — the +7 % all-stats line (installed, pack sha `24b725993bc28142…`)

What "a perfect roll" actually is: each of the 3 lines is `{key, tier, perfect}`. `POTENTIAL_LINES`
(`game_data.gd:5755`) holds **18 kinds**, picked by `keys.pick_random()` — and only one of them, `stats`,
is "+N% a todos los atributos", with `vals: [0.02, 0.04, 0.05, 0.07]`. `Potential.value()` (`potential.gd:75`)
takes `vals[tier-1]` and steps one further **only when the line is top tier AND `p` is set**, so +5 % =
legendary-semi and **+7 % = legendary-perfect**, which is also the only difference between the two. So the
"perfect +7 all stats" outcome is three independent gates: item tier 3, the *kind* being `stats` (1/18),
and `POTENTIAL_PERFECT` (0.2). Combined at top tier: 0.53 % per line, and (1/18)³ ≈ 1/5832 for one roll with
all three — a full set is effectively unreachable, exactly the complaint.

Changes in `core/potential.gd`: `MOD_POT_PERFECT 0.8` (was 0.2; still only rolled on a top-tier line, and
Hel Tears keep converting the remaining semi ones), `MOD_POT_SAME 0.85` (was 0.2 → v7 0.7), and
`MOD_POT_KEY_W = {"stats": 12.0}` consumed by the inserted weighted picker `_pot_key()` (1 rewritten line:
`keys.pick_random()` → `_pot_key(keys)`). Every other kind keeps weight 1.0, so damage/proc/boss hunting is
untouched. The +7 value itself is the shipped `vals[3]` — no new numbers, only the gates are widened.

Measured running the real `roll()` under Godot 4.7.2 at Legendario tier (60 000 rolls; 1 500 sessions of the
way it is actually played, i.e. lock a line the moment it comes out +7 %):

| | vanilla | mod v10 |
| --- | --- | --- |
| P(one line = perfect +7 % all stats) | 0.53 % | **29.7 %** |
| P(all 3 lines of a single roll) | never in 60 000 (≤0.002 %) | 2.68 % (≈1 in 37) |
| rolls for a 3-line +7 % set, locking each hit | mean **677** (median 552, p90 1351) | mean **5.8** (median 5, p90 10) |

Add the ~10 rolls it now takes to reach Legendario tier (§15) and a full set costs a few dozen crumbs
instead of several thousand — with `MOD_CRUMB_MULT 2.5` on drops, roughly one Hell-15 run of farming.
Probe extended: `user://mod_probe_potential.txt` now prints `stats_lines=n/3  perfect_stats=n  (… stats_w=12)`.

## 18. Mod v11 — altar odds (built, pack sha `f1fc44fa1aedba9b…`)

One roll site only: `core/altars.gd spawn()` (0.2.4 lines 240-252) draws every *random* altar from
`GameData.ALTARS.keys()` **filtered to the ids that have neither `npc` nor `karma`**, weighted by
`ALTARS[id].get("w", 1.0)`. Shipped: 7 ids at `w` absent→1.0 and `yggdrasil` at 0.3 (total 7.3), and
`hypnotist` carries `w: 0.0` which is dead code because the `npc` filter already drops it.
Consequence worth knowing: **`baldur` and `hel` are not in that pool at all** — they come from the karma
timer (`core/karma.gd:167`, one altar every `KARMA_ALTAR_EVERY = [150, 210]` s from `t = 90`), as a
50/50 `pick_random()`. So "make Baldur more likely" cannot be done in the table; it is its own knob.

Changes: `MOD_ALTAR_W` (new const, `game_data.gd`, before `HYPNO_AT`) is consulted as an override at the
two `get("w", 1.0)` lines, and `MOD_KARMA_BALDUR` replaces the 50/50 pick. 2 rewritten lines in
`altars.gd`, 1 in `karma.gd`, all listed in `lint-allow.txt`; `game_data.gd` stays pure insertion.
`force`-spawned altars (net sync, debug menu) are unaffected — as intended.

Measured by replaying that exact loop with the real consts, 200 k picks each
(`work/logs/altar_odds/`, `python3 mk_probe.py && godot --headless --path . -s res://sim.gd`):

| altar | stock | mod v11 | weight | bad side (shipped) |
| --- | --- | --- | --- | --- |
| odin | 13.7 % | **24.3 %** | 1.0 → 6.0 | Más monstruos feroces (+elite) |
| thor | 13.7 % | **24.1 %** | 1.0 → 6.0 | +40 % de monstruos |
| loki | 13.7 % | **24.4 %** | 1.0 → 6.0 | monstruos +25 % velocidad |
| yggdrasil | 4.1 % | **24.2 %** | 0.3 → 6.0 | — (no downside) |
| freyja | 13.8 % | 0.8 % | 1.0 → 0.2 | monstruos +20 % daño |
| niflheim | 13.8 % | 0.8 % | 1.0 → 0.2 | monstruos +25 % vida |
| valkyrie | 13.5 % | 0.8 % | 1.0 → 0.2 | MVP 60 s antes, +25 % vida |
| emperium | 13.7 % | 0.8 % | 1.0 → 0.2 | guardia de élites |

Useful-pool share 45.2 % → **96.8 %**; karma altars Baldur/Hel 50/50 → **75/25**
(`MOD_KARMA_BALDUR 0.75`; Baldur = +10 % max HP, +5 % dmg, full heal, Valhalla route; Hel = −15 % max HP,
Niflheim route). The nerfed four are the ones whose penalty multiplies with the monster curve instead of
staying flat — and note the *good* side of niflheim/thor is what `MOD_XP_MULT` (§14.1) already covers.
Tuning: the four good weights only need to stay ≫ the four bad ones; at 6.0/0.2 a run with
`ALTAR_MAX = 5` concurrent altars effectively never sees a nerf altar.

## 19. Update 0.2.4 -> 0.2.7, as executed (2026-11-21) — second live run of the §10/§14 recipe

The updater took 0.2.5 → 0.2.6 → 0.2.7 in between, deleting every pack it replaced: `patches/` now holds
only `bridge_0.1.273_to_0.2.0.pck` (unchanged), `patch_0.2.7.pck` and `state.json`. **Our modded
`patch_0.2.4.pck` is gone**, exactly as §10 predicted; `orig/` was the only pristine copy and it was there.

```sh
cp "$P/patches/patch_0.2.7.pck" orig/                        # sha 0810d151e9c46b52…, 23 MB, 271 members
gdre_tools --extract=orig/patch_0.2.7.pck --include='*.gdc' --output=raw_0.2.7          # 101 scripts
# per-file decompile, bytecode rev read off the header first: 47 44 53 43 65 -> rev 101 -> 4.5.0-stable
for g in $(find raw_0.2.7 -name '*.gdc'); do
  gdre_tools --decompile="$PWD/$g" --bytecode=4.5.0-stable \
             --output="$PWD/scripts_full_0.2.7/$(dirname ${g#raw_0.2.7/})"; done       # 101/101, 0 fail
rm -rf effective_0.2.7 && mkdir -p effective_0.2.7 && cp effective_0.2.4/project.godot effective_0.2.7/
for L in ../25_scripts scripts_full_0.2.0 scripts_full_0.2.4 scripts_full_0.2.7; do     # base<-bridge<-patch
  for sub in scripts addons; do [ -d "$L/$sub" ] && cp -r "$L/$sub/." effective_0.2.7/"$sub"/; done
done                                                                                   # 175 .gd, tag v0.2.7-decompiled
cd effective_0.2.7 && patch -p4 --merge < ../mod-latest.patch   # 10 of 11 files clean, 1 conflict
./build.sh --deep && ./build.sh --install
```

`patch_0.2.7.pck` is a superset of `patch_0.2.4.pck` (0 members dropped, 104 added) → the layer really is
cumulative, so the tree is base ← bridge ← newest patch; the 0.2.4 decompile is only a floor.
Survey, pristine 0.2.4 tree vs pristine 0.2.7 tree: **110 of 175 scripts byte-identical, 61 changed, 4 new**
(`core/wb_portal`, `core/world_boss`, `net/world_chat`, `ui/harmony_view`).

### 19.1 The one conflict, and what it says about the mod

`main.gd` hunk #2 — the Star Crumb roll. The dev rewrote it from a single `randf()` into the fused-crowd
form, so the knob had to move onto the new expression:

```gdscript
var crumbs: = 0 if e.summoned or training else _hits(star_crumb_chance(e) * drop * MOD_CRUMB_MULT, fused)
```
`_hits(p, n)` (`main.gd:13754`) is *n* independent rolls of *p*, one per packed monster under
`CROWD_FUSE_MAX`, so multiplying the probability is the same knob as before and the Hell-10 gate is intact
(`star_crumb_chance()` returns 0 → 0 hits). Same build also added a **fourth crumb source**, `GOLD_PORING_CRUMB
= 0.05` (`main.gd:11995`, new in 0.2.7), which the old comment claimed to already cover — so `MOD_CRUMB_MULT`
is now applied at both roll sites, and the comment says so. World-boss chests hand out crumbs as a fixed
table amount (`GameData.wb_chest_items()`, `game_data.gd:378-386`, `WB_CHESTS`/`chest_wb_*`), which is a
reward rather than a roll: left alone.
Two more lines in `lint-allow.txt`; everything else in the mod is still pure insertion, and `potential.gd`
was not touched by the dev at all (its `.gdc` sha is identical to the 0.2.4 build).

Verification: lint green; `members 271 -> 272` (our added `tower_traps.gdc`), all 11 member shas match the
compiled `.gdc`, no lost member; `--deep` round-trip now reports *every source line present in the bytecode*
for all 11 files; altar odds re-measured off the new tree (`work/logs/altar_odds/odds_0.2.7.txt`): useful
pool 45.2 % → 96.8 %, Baldur/Hel 75/25, unchanged by the update. Built pack **`c632e8c42475eca2…`**
= `MOD_TAG mod-v12 on 0.2.7`, installed, `play.sh --status` → `MODIFIED_our_edit`.

### 19.2 `orig/patch_0.2.5.pck` is not a pack — packs travel encrypted

The symptom that caught it: `./play.sh --layer <member>` printed nothing for `PATCH` on 0.2.5, because
`work/logs/patch-0.2.5-files.txt` is 0 bytes. Regenerate that listing per version with
`gdre_tools --list-files=orig/patch_$VER.pck > work/logs/patch-$VER-files.txt`.
`orig/patch_0.2.5.pck` (copied 2026-11-20 from the live dir) opens in nothing: magic `GDEC`, no `res://`
strings, GDRE reports `Pack version unsupported: 4246140305`. Cause found in this layer: the dev ships the
download **encrypted** and decrypts it on disk — `updater.gd:393` calls `_decrypt()` →
`FileAccess.open_encrypted_with_pass(from, READ, PATCH_KEY)` (key is a const in `updater.gd`), and
`save.gd:207` recognises the same `GDEC` tag for cloud saves. So the 0.2.5 copy was captured *before*
decryption (a downloaded-but-unmounted artifact), not a format change: 0.2.4 and 0.2.7 in `orig/` are plain
`GDPC` v4 and both mount. **Rule for the next update: copy the pack from `user://patches/` only after the
game has mounted it once** (decrypted), and if GDRE refuses to open it, look for a `GDEC` header before
suspecting anti-tamper — `updater.gd` is the authority and it has no hash check on on-disk packs (§3 stands).

### 19.3 New in 0.2.7 (for future balance work)

World bosses (`WB_*`: `WB_TIME 180`, `WB_EVERY 0.65`, `WB_GROWTH 1.5`, `WB_DMG_GROWTH 1.15`, 6 chest grades
`wood…valhalla` granting `star_crumb` 1/2/3/6/11/15 × `WB_CHEST_MULT`), new maps `juperos_02`/`moc_pryd03`/
`prt_are01`, a combo skill system (`COMBO_*`), `PRIDE_*`, `BURN_HEAT_*`, `RAGING_LINE_*`, `PLANT_CHAIN_*`,
`REFLECT_OVER_SOFT`, `STEEL_GUARD_MAX`, `SUMMON_BOSS_DMG`/`SUMMON_LEECH_PER_S`/`SUMMON_OVERFLOW_POW`,
`HELL_HIT_STEP`/`OATH_HIT_STEP` (more monster-side scaling), `ENDOW_*` (element endowment), world chat,
`CROWD_FUSE_LOOT`. Balance nerfs we did not ask for: `KARMA_UNIQUE_CHANCE 0.06 → 0.017` (3.5× rarer unique
on the karma route) plus the new `UNIQUE_OWNED_MULT` when every hero already owns it, and
`ALTAR_MAX` now counts only non-hypnotist waiting altars (`altars.gd:159`), which slightly raises real altar
density — our `MOD_ALTAR_W` makes that more valuable, not more dangerous.

## 20. The update pipeline, scripted (2026-11-21)

> **Superseded in part by §22 (2026-11-25).** The table below still describes the four tools, but the layer
> model in `layer_env.sh` changed: it is a `state.json`-read **manifest** (`layer_manifest`,
> `layer_state`, `layer_listings`, `layer_src_dir`), not "the newest patch pack". Steps, refusals and the
> exit-3 rule are unchanged; `layer_sync.sh` now ingests every pack the manifest names and dies on a partial
> mount set. Read §22.3 for what each tool does now.

Everything §10/§14/§19 did by hand is now four scripts + one shared env file, all in this directory and
all git-tracked. They only touch `work/` and read `user://`/the game dir — the same rules as `play.sh`.

| Script | Does | Refuses / warns |
| --- | --- | --- |
| `layer_env.sh` | sourced config: paths, `layer_ver` (state.json), `layer_tags`/`layer_prev`, `layer_rev` (GDSC header), `layer_magic`, the GDPC/GDEC magics | — |
| `layer_sync.sh` | the 6 ingest steps: copy pack → `orig/`, member listing for `play.sh --layer`, extract `.gdc`, per-file decompile (parallel, `-P3`), assemble `effective_<ver>` from base ← bridge ← older patches ← newest, whitelist the tree in `.gitignore`, commit + tag `v<ver>-decompiled` | `GDEC` pack (encrypted download → §19.2), an existing tag/tree (would double-ingest; `--force` re-does but never moves a tag), a bytecode revision other than 101, a member that vanished vs the previous layer, non-text files in the tree, `.gdc`/`.uid` leftovers (deleted — the tree is source only) |
| `layer_diff.sh` | pristine-vs-pristine report from the two tags: members, same/changed/new/gone scripts, churn **per file our mod edits**, every `GameData.*` const the mod reads, and whether every `lint-allow.txt` target line still exists | prints `MOVED/REWRITTEN` for a shipped line our knob was attached to — that line *is* the future conflict |
| `mod_apply.sh` | `patch -p4 --merge` onto a tree, then three audits: conflict markers, **insertion-site check** (each indented `MOD_` statement's enclosing function vs the previous layer where the same knob was proven), lint pre-flight with the exact `lint-allow.txt` line to append | tree already modded (`--restore` backs the mod up to `work/logs/mod-backup-*.patch` first), exit **3** = needs hand resolution |
| `update.sh` | `layer_sync` → `layer_diff` → `mod_apply --build` in one go; `--dry-run`, `--skip-sync`, `--install` | stops before installing on any conflict |

The workflow for the next official update is therefore:

```sh
. /media/jang/home/PortableApp/re/activate.sh
cd work/60_patches && ./update.sh --deep          # ingest + report + re-apply + build (no install)
# if it stops with exit 3: open the marked file, keep the dev's new code, move the knob onto it, then
./mod_apply.sh --check --build                    # audits + build again
../../play.sh && ../../play.sh --probe            # human: play, then read the probe files
./update.sh --skip-sync --install                 # only after the play-test
```

Self-test on the current state (2026-11-21, no side effects): `mod_apply.sh` run against a scratch copy
of `v0.2.7-decompiled` applied `mod-latest.patch` with **0 conflicts, 0 moved sites, 0 lint gaps** and
produced a tree byte-identical to the one the installed pack was built from — so `mod-latest.patch` is
now stated in terms of 0.2.7 code, and the reports reproduce the hand analysis of §19 exactly
(`110 same / 61 changed / 4 new`, `9 of 11 patched scripts moved`, `+104 -0` members, the one rewritten
`lint-allow` line).

## 21. Mod v13 — cosmetic gacha odds + softer yggdrasil (built, pack sha `66349701ea251c9e…`)

On top of v12 (the 0.2.7 port). Two tables, one file, no new knobs:

**Gacha** — `GameData.GACHA.odds` (`game_data.gd:1525`) is rewritten in place rather than overridden by a
`MOD_*` const, because `gacha_panel.gd` reads the *same* dict twice — `roll():468` and the "Probabilidades"
list `:386` — so a single edit keeps the advertised odds equal to the real ones. `roll()` walks
unique→common subtracting each weight from `randf()`, therefore **the five values must sum to 1.00**:
above 1 the lower tiers become unreachable, below 1 the remainder leaks into common.

| tier | shipped | mod v13 | 2 M-spin replay (shipped → mod) |
| --- | --- | --- | --- |
| common | 0.69 | **0.40** | 68.98 % → 40.01 % |
| rare | 0.22 | **0.30** | 22.02 % → 29.97 % |
| epic | 0.075 | **0.15** | 7.51 % → 14.99 % |
| legendary | 0.01 | **0.10** | 1.00 % → 10.02 % |
| unique | 0.005 | **0.05** | 0.50 % → 5.02 % |

The whole 29 % cut comes out of common. E[spins] to hit legendary-or-better 66.7 → 6.7, so `pity 12` /
`epic_pity 5` are now mostly vestigial (the hard pity is weaker than the natural rate) — left alone, they
still cover the unlucky tail. `unique` = 6 gacha-eligible outfits (`outfit_santa` is `gacha:false`), so each
individual outfit is ~0.83 %/spin. The shipped odds line is in `lint-allow.txt`; `--deep` flags one line
only because the decompiler prints `0.4` where the source says `0.40`.

**Altars** — `MOD_ALTAR_W`: yggdrasil 6.0 → **3.0** (half the other good altars: it is the only rollable
altar with an empty `"bad"`, so the devs' `w: 0.3` is a deliberate scarcity signal and 3.0 is still 10× it),
odin/thor/loki 6.0 → **7.0 → 6.0** while paying for the bad altars, and the nerfed four 0.2 → **0.8**.
Final table `{odin,thor,loki} 6.0, yggdrasil 3.0, {freyja,niflheim,valkyrie,emperium} 0.8`, total weight 24.2:
**24.8 % / 24.8 % / 24.8 % / 12.4 % / 3.3 % ×4** — bad altars 3.2 % → **13.2 %** of spawns, useful pool 96.8 % → 86.8 %
(stock 45.2 %). At `ALTAR_EVERY [60,90]` a 30-min run offers ~24 altars, so ~3 of them now carry a downside
(v11/v13a: ~1). Measured with the §18 harness, captures `work/logs/altar_odds/odds_0.2.7_v13.txt` (7.0/0.2 step)
and `odds_0.2.7_v13b.txt` (final). Built pack **`66349701ea251c9e…`**, not yet installed.

---

## 22. Update 0.2.7 -> 0.2.12: the layer model changed (2026-11-25) — pipeline rework + mod v16

The biggest official update since we started modding, and the first one that broke a tool assumption. Two
things changed at once: **where the scripts live**, and **what `state.json` says**.

### 22.1 What the update actually is

| Pack | Bytes | sha256 | Members | `.gdc` |
| --- | --- | --- | --- | --- |
| `bridge_0.1.273_to_0.2.11.pck` | 228 779 464 | `20821a7255f19078…` | 9 966 (6 359 assets, 3 407 `.godot`, 191 scripts+sidecars) | **142** |
| `patch_0.2.12.pck` | 174 100 | `4317ffe53015378b…` | **1** (`res://.godot/imported/npc_kafra_goth.png-78dc3c….ctex`) | **0** |

`state.json` gained a nested key:

```json
{ "base": "0.1.273", "bridge": { "file": "bridge_0.1.273_to_0.2.11.pck", "version": "0.2.11" },
  "file": "patch_0.2.12.pck", "version": "0.2.12" }
```

So the layer that used to be "bridge 0.2.0 (8 452 members) + cumulative patch 0.2.7 (271 members)" became
**"one fat bridge that carries the whole game (including every script) + a patch pack that is a
last-mile asset hotfix"**. The 0.2.0 bridge and the 0.2.3/0.2.4/0.2.7 patch packs are gone from disk: the
updater deleted what it replaced, and a *promoted* bridge (22.2) makes the old chain moot.

Consequence for the tooling, which is why this is a section and not a footnote: **"ingest the newest
patch pack" is no longer a definition of the current build**. `layer_sync.sh` could not ingest 0.2.12 at
all (0 `.gdc` -> the bytecode-rev check dies on a missing file) and, worse, its tree assembly globbed
`scripts_full_*`, which now mixes one bridge and three obsolete patch layers. Everything in 22.3 exists to
make the mount set a fact read from the game, not an inference from directory names.

### 22.2 `updater.gd` (0.2.12) — the parts that decide our mod's lifetime

* **Mount** (`_ready():111-136`): `state.base` must equal the installed build or `_clear_patches()` wipes
  the whole `patches/` dir (`_clear_patches:522` = `DirAccess.remove` over every file). Then the bridge is
  mounted; **if mounting the bridge fails, `_clear_patches()` again** — a corrupt bridge takes our pack with
  it. Then the patch pack; a failure there is only a `push_error`.
* **No local integrity check** (unchanged): the packs on disk are never hashed, so a modded pack mounts
  silently. Downloads are encrypted (`GDEC` + `PATCH_KEY`) and hash-checked (`:378`).
* **Deletion matrix** (`_download` finish, `:441-466`) — this is what kills our pack:
  | Update shape | state.json afterwards | files deleted |
  | --- | --- | --- |
  | new patch pack | `{base, bridge?, version, file}` | the old `file` (= our modded pack) |
  | new bridge (`as_bridge`) | `{base, bridge:{new}, version: new}` | the old `file` **and** the old `bridge` |
  | `base` mismatch / bridge mount failure | `{}` | **everything** in `patches/` |
  Either way: **every official update removes our pack**, so the mod has to be re-applied and re-installed
  every time (§20 + 22.5).
* **Bridge promotion** `_adopt_bridge():337` — if the client has a patch pack and *no* bridge, and the
  manifest's `base` catches up to the installed patch version, that patch file is rewritten in state as the
  *bridge*. Harmless for us while a bridge exists (0.2.11+ always leaves one), but a reason not to keep a
  modded pack around as the only artefact of a build.
* **`legacy` table** (`:312`) — a bridge download is only offered when `manifest.legacy[base].version ==
  manifest.base`; otherwise the game shows "new build required" (a reinstall, not a patch). If that ever
  happens, our `orig/` + tagged decompile are the only copy of the layer we modded.

### 22.3 The pipeline rework (commits `1bce631`, `82e1a02`, + the review fixes in this commit)

`layer_env.sh` is now the single authority on the layer model; every other tool asks it instead of guessing:

| Helper | Gives | Replaces |
| --- | --- | --- |
| `layer_state KEY` | jq, with an awk walker fallback (handles the nested `bridge` object and compact JSON) | `sed … \| tail -1` on `version`, which only *accidentally* picked the top-level key |
| `layer_manifest [VER]` | `kind⇥file⇥version` rows in **mount order**, from `state.json` for the live version and from the snapshot written at ingest for older ones | "the newest `patch_*.pck`", `scripts_full_*` globs, hardcoded bridge names |
| `layer_src_dir` / `layer_raw_dir` `KIND VER [PATCHVER]` | decompile dirs; a bridge gets `scripts_bridge_<ver>` unless it is the legacy 0.2.0 layer, and `PATCHVER` keeps a same-version bridge+patch pair from colliding on `scripts_full_<ver>` | one name for both kinds |
| `layer_listing` / `layer_listings` | `work/logs/<kind>-<ver>-files.txt` per pack | `patch-<ver>-files.txt` as "the" listing |
| `layer_ver` / `layer_prev` / `layer_base_ver` / `vcmp` | version arithmetic incl. `0.2.12 > 0.2.7` | lexicographic assumptions |

Behaviour changes that matter at the next update:

* `layer_sync.sh` ingests **every pack in the manifest**, in order, and dies if any of them is missing
  (a partial mount set can no longer be tagged as a pristine baseline — the tag and the tracked manifest
  snapshot would then permanently record a lie).
* `orig/` keeps the **patch pack always** (it is `build.sh`'s base) and anything ≤ `KEEP_MAX` (64 MB);
  the 228 MB bridge is recorded by sha256+size in `work/logs/layer-hashes-<ver>.txt` instead of by copy —
  its durable artefact is the tagged decompile, and the volume has 6 GB free. The recorded hash always comes
  from `orig/` when we have it: after `--install` the *live* pack is our build, and hashing that would make
  `play.sh --status` certify a modded pack as official.
* `work/logs/layer-manifest-<ver>.tsv` + `layer-hashes-<ver>.txt` are **tracked in git**: the updater deletes
  the packs they describe, and the bridge is too big to keep.
* `build.sh` adds a **shadow audit**: every `.gdc` we ship must exist in a mounted lower layer, or it is a
  DEAD override the game will never load. It fails closed (no listings -> no build) and rebuilds a missing
  listing from the pack on disk.
* `play.sh` sources `layer_env.sh` (`LAYER_W` override) — `--status` prints the real mount order and a
  per-pack official/MODIFIED verdict; `--layer` walks every mounted listing; `--isolate` rebuilds its
  sandbox mount set so a deleted pack cannot leave a dangling link. `--help` is now the header block
  (`layer_usage`), because the old `sed -n '2,Np'` ranges were off by one in four of five tools.

### 22.4 The 0.2.12 migration as executed (mod **v16**, pack `55ab9e01a28f29c0…`, not installed)

```sh
. /media/jang/home/PortableApp/re/activate.sh
cd work/60_patches
./layer_sync.sh --jobs 4            # bridge 142/142 decompiled, 0 failures; patch pack: 0 scripts, skipped
./layer_diff.sh --from 0.2.7 --to 0.2.12
./mod_apply.sh --ver 0.2.12         # patch -p4 --merge -> 1 conflict
#   resolve game_data.gd by hand, delete the .gd.orig files
./mod_apply.sh --ver 0.2.12 --check && ./build.sh --deep
```

* `effective_0.2.12` = `25_scripts` (131) ← `scripts_full_0.2.11` (142) = **180 `.gd`**, tag
  `v0.2.12-decompiled`. 5 scripts new since 0.2.7 (`build_card`, `kafra_walk`, `rebel`, `thief_arts`,
  `job_board`), 0 gone; 65 scripts changed (`game_data` 1 381, `main` 1 564, `player` 681 diff lines).
  Members visible to the game: 8 630 -> 9 965.
* **One conflict**: `game_data.gd` hunk 1 (the gacha odds). 0.2.11 turned `"dupe_coins": 1` into a
  per-rarity refund dict `{"common":1,"rare":2,"epic":3,"legendary":5,"unique":5}` + `gacha_refund()`, so the
  hunk's context line no longer exists. Resolution kept **the developer's dict and `gacha_refund()`** and
  moved only the `odds` line — our odds are still the single source both `roll()` and the "Probabilidades"
  list read.
* `player.gd` hunk 2 reported *merged* (overlapping context inside `take_damage`): the mechanics cap and its
  probe are intact; reviewed line by line.
* Proof the port is a port: **all 51 knob sites** are in the same function as in the modded 0.2.7 tree
  (`mod_apply` audit 2), and the multiset of code lines the mod **adds** is identical (276 lines, 0 dropped,
  0 extra). `MOD_TAG` v15 -> `mod-v16 on 0.2.12` (both copies, `player.gd:29`, `enemy.gd:252`).
* Verification: `--deep` round-trip clean (the two flagged lines are the `0.40`/`0.4` float print and a
  trailing comment — known decompiler re-flow), shadow audit clean, 12 members, 11 `.gdc` hashes match.
* Side finding from the v15 play-test that happened just before the update (`user://mod_probe_events.txt`):
  **`gap=8.9 floors`, emperium 39/69 events (56.5 %)** — the `tower_run.gd:579` `emp_due()` hook does land and
  the §19/§21 target of ~9 floors is what the game really produced. The v15 mechanics probe on 0.2.7 logged
  688 hits / 102 capped / worst 0.50 × max_hp, so the cap engages and normal hits stay untouched.

### 22.5 Playbook for the next update (replaces the §10/§14/§19 prose where they differ)

```sh
cd work/60_patches && ./update.sh --deep        # ingest -> report -> re-apply -> build; never installs
```

Then read the report. The shape of the update decides what to expect:

| Update shape (state.json) | What `update.sh` does | What you must check |
| --- | --- | --- |
| new patch pack, same bridge | ingests bridge (already decompiled, reused) + new patch | if the new patch pack ships 0 scripts, the mod is unchanged in content — the knobs still sit in bridge scripts, so the merge is against the *bridge* layer |
| new bridge (+ patch) | ingests both; the old bridge/patch are deleted by the updater and are **not** in the tree | the 38 scripts only the base ships (addons, `flow_field`, `hero_input`, `skins`, `weather`, …) come back from `25_scripts`; `layer_diff` 2/5 "gone" must stay 0 |
| bridge newer than the top-level `version` | prints a NOTE and names the tree after `version` | that is fine: the tree content is the bridge, the tag follows what the game presents |
| `state.json` without a `bridge` key | `layer_bridge_le` reconstructs it from disk/listings | a wrong bridge name means the ingest dies, not silently mis-assembles |

Whatever the shape: `orig/` must end up holding the pristine **patch** pack (the build base) and
`work/logs/layer-manifest-<ver>.tsv` + `layer-hashes-<ver>.txt` must be committed — those two files plus the
tag are all that survives of a build once the updater has deleted the packs.
