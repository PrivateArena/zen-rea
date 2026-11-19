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
| **`effective_0.2.3/`** | **167 `.gd` = base(0.1.273) ← bridge ← patch, the tree the shipped game really executes. Read this one — and edit THIS one: it is git-tracked, so `git diff v0.2.3-decompiled` after an edit is the whole mod.** |
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
