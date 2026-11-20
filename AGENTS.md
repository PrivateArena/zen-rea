# AGENTS.md — Midgard Survivors RE

**Skill to load for any RE work here: `godot-re`** (`zskill -a get -i godot-re`) — it carries the
verified command recipes, the quirk table and the prohibitions. This file carries only *this
project's* state. Env docs: `/media/jang/home/PortableApp/re/PROJECT_OVERVIEW.md`.
Architecture + as-built deltas: `ARCHITECTURE_PLAN_portable-rea-re-env.md` (§11 = what actually happened).

```sh
. /media/jang/home/PortableApp/re/activate.sh    # rea / gdre_tools / godot on PATH
/media/jang/home/PortableApp/re/verify.sh --fast  # env health, non-zero on failure
```

## Target (READ-ONLY — never write here, never execute its binary)

`/media/jang/free/MidgardSurvivors/midgard-survivors-midgard-survivors-linux/`

| Fact | Value |
| --- | --- |
| `MidgardSurvivors.pck` | 557 MB, `GDPC` format **4**, `pack_flags=2` (relative names, **not encrypted**, key field zeroed), external (`embedded:false`), 14,383 members, sha256 `a8d0b35b…0328a8b6` |
| Engine | `Godot Engine v4.7.2.stable.official`; project version `0.1.273`; `.gdc` bytecode revision **101** (= GDRE token `4.5.0-stable` / commit `ebc36a7`) |
| Scripts | 131 `.gdc` (+134 `.remap`) → **131 `.gd` recovered, 0 failures** |
| `MidgardSurvivors.x86_64` | stock Godot 4.7.2 export template, stripped, no custom sections, no PCK/integrity/anti-cheat checks, aborts on `--main-pack`/`--path` (`disable_path_overrides=yes`) |
| Live patch layer (`user://patches/`) | `state.json`: base `0.1.273`, bridge `0.2.0`, **`patch_0.2.4.pck`** (official sha `a1dd53eb…`, 167 members). Packs here are unsigned-on-disk and cumulative; each update **deletes** the pack it replaces |
| Native libs | `libeosg.linux.template_release.x86_64.so` (one `T`: `eosg_library_init`), `libEOSSDK-Linux-Shipping.so` — Epic EOS GDExtension, **optional by guard** `net_sync.gd:145-153` |

**Verdict so far: no native RE needed.** All balance is client-side const tables; servers do
telemetry/leaderboard/cloud-save/update-manifest only. Consequence: `Rizin/Cutter/Ghidra` stay off
(`env_re 2` if that ever changes).

## State

| Path | Contents |
| --- | --- |
| `work/10_evidence/` | 2 REA inventory bundles (45 MB each) |
| `work/25_scripts/` | scripts-only recovery — the fast place to grep/read GDScript |
| `work/30_recovered/` | full recovered project, 2.0 GB, 26,746 files (the only copy since `40_mod` was deleted 2026-11-19) |
| `work/60_patches/` | **the live patch layer + all mod work.** `PATCH_SYSTEM.md` = findings (§7 balance map, §10 update behaviour, §14 = 0.2.4 migration runbook). `effective_0.2.4/` = the 171 `.gd` tree the game really runs (git-tracked source; `effective_0.2.3/` kept as history). `build.sh` = compile→pack→verify→install (version from `state.json`), `lint-allow.txt` = intentionally-replaced shipped lines, `mod-latest.patch` / `mod-0.2.4.patch`, `orig/` = **the only pristine pack backups** (`patch_0.2.3.pck`, `patch_0.2.4.pck`) |
| `work/50_roundtrip/` | write-path sandbox; `REPORT.md` = the verified patch recipe; `launch_test/` = ready-to-run fixture |
| `work/logs/` | `pck-files.txt`, `verify.baseline.json`, per-run logs |
| `PROJECT_OVERVIEW.md` (env) · `work/README.md` (dir map) | boot reading |

Key numbers: env 830 MB on nvme; work 2.8 GB on `/media/jang/free` (6.2 GB free after deleting
`40_mod`); `verify.sh` full = 10/10 PASS;
`pi mcp list` → `rea: connected, 255 tools`.

## Next step (in order)

1. **Play-test mod v6 on 0.2.4** *(human — `./play.sh`, no args after `--`)*: endgame HP/tower feel,
   legendary frequency (≈1 in 10 offers), and the new `×1.5` XP (~+56 levels at the 40-min mark).
   Then `./play.sh --probe` (5 probe files in `user://`) and retune `MOD_*` constants → `./build.sh --deep --install`.
2. **Runtime acceptance test of the base-pack write path** *(still pending, needs a human)*:
   `work/50_roundtrip/launch_test/MidgardSurvivorsRT/` → `./MidgardSurvivorsRT.x86_64 -- --disable-updater`.
   Look for ` [RT-TEST]` in a bottom-centre loading tip (`menus.gd:3614`, ~1 tip in 16).
   Deterministic capture: `-- --tips-test /tmp/rt_shots --last`. See `launch_test/RUN.txt`.
3. ~~**Define the change**~~ — **done 2026-11-19**: the balance lives in the patch layer
   (`patch_0.2.3.pck` replaces `game_data.gd` + 57 gameplay scripts, so base-pack edits cannot change
   it). Map = `PATCH_SYSTEM.md` §7, applied mod = §9. Line numbers there, not the 0.1.273 ones above.
4. **Project-setting edits have no GDRE path** (`--pck-version` max = format 2, and
   `project.binary`/ECFG can't be regenerated). If needed, test `godot --headless --export-pack`
   against `30_recovered` (requires authoring `export_presets.cfg` + an import pass; budget disk).
5. Still unproven: `--pck-patch` member-by-member byte equality for the other 14 382 files of the
   base pack; `--embed`, `--key`. **Proven 2026-11-19 for the patch pack**: `decompile(compile(src))`
   differs from `src` only by stripped comments, and `--pck-patch` carried all 120 untouched members
   (`decompile`-level fidelity of GDRE output vs the devs' own bytes remains untested — see §5
   `probe_fidelity/`, 194 B size delta on `game_data.gdc`).

## Run the game (human only — this agent never executes it)

```sh
./play.sh --status              # installed packs, effective version, official vs MODIFIED (sha256)
./play.sh                       # launch WITH the patch layer mounted  -> plays the newest patch
./play.sh --layer game_data.gdc # which pack owns a member (layer shadow audit)
./play.sh --isolate --dry-run   # sandboxed user:// in work/70_play_userdata, mounts work/60_patches/out/*.pck
```

`play.sh` exists because **any argument after `--` disables the updater and both patch mounts**
(`updater.gd _enabled()`), i.e. `-- --disable-updater` / `-- --tips-test …` runs stock 0.1.273 — that
is why the round-trip marker test needs it, and why mod testing must NOT use it. Engine flags before
`--` (passed with `--godot`) are safe.

## House rules

Balance work happens in `work/60_patches/`: edit `effective_<ver>/`, build with GDRE into `out/`, ship
into `user://patches/`. `40_mod` / `30_recovered` are read-only study trees. Version control is **one
repo at the project root**, text-only (GitHub-ready); tags `v<ver>-decompiled` = pristine live builds,
therefore `git diff v0.2.4-decompiled` **is** the mod. Never `git add -f` a `.pck`/`.gdc`. Never run
`rea setup`, `rea update`, `pi mcp add`, or bare `npm install` (skill §6). Recapture
`work/logs/verify.baseline.json` only after a deliberate change. Add a dated entry below whenever a
step completes.

```sh
git log --oneline | head -1                # 26e3727 unless you committed something
git status --porcelain | wc -l             # expect 0 between steps
git diff --stat v0.2.4-decompiled -- work/60_patches/effective_0.2.4   # = the mod
```

## Log

**2026-11-20 (latest)** — **Official update 0.2.3 → 0.2.4 handled; mod reinstalled as v6**
(pack `bfc81d3a…`, 168 members). The updater deleted our modded `patch_0.2.3.pck` *and* wiped
`patches2/`, so pristine packs now live only in `work/60_patches/orig/`. Decompiled the new layer
(87 scripts, `--decompile --bytecode=4.5.0-stable`, 0 failures) → `effective_0.2.4/` (171 `.gd`, 4 new:
`souls`/`soul_icon`/`perf_watch`/`bestiary`), tagged `v0.2.4-decompiled`; `mod-latest.patch` re-applied
with **0 conflicts** (dev rewrote `player.gd` 291 lines, `tower_run.gd` 51, `tower_events.gd` 4;
`enemy.gd`/`tower_traps.gd` untouched; 104 of 167 scripts unchanged). Added **`MOD_XP_MULT = 1.5`**
after proving XP is untouched by our nerfs: run XP enters only via `Player.add_xp`, per-kill XP =
`def.xp × norm.z × danger_xp(danger)` (`main.gd:5449`) with no HP/time term, and the summary's
`Class EXP` is `roundi(xp_gained)` — the 443-vs-401 comparison was pure curve concavity (both runs
≈14.6k XP/s; our rate for their 1725 s ⇒ level 402). `build.sh`/`play.sh` now derive the version from
`state.json` (`MOD_VER` overrides). New in 0.2.4 for later: `soul` equip slot, `MOB_HIT_*`/`HIT_RESIST_VIT`,
`FOCUS_*`, `HARMONY_*`, `GRADE_PITY`, gacha `epic_pity`, `OATH_CURSE_MAX` raised to `[0.4, 0.6]`,
`CROWD_FUSE_MAX = 30`.

**2026-11-20** — mod v2-v5 (all on 0.2.3, all installed then superseded by the update): global
**Mechanics damage cap** in `Player.take_damage` (`MOD_MECH_PCT_CAP 0.15` — the "Mechanics" row is every
`pierce && from == null` hit, incl. hell rain/meteors, several of which bypass `hell_hazard`); probes
rewritten to print real values (v2 shipped a literal `%.1f` because the placeholder sat inside a `const`
string — the values are now built at the print site and every format string was exercised under headless
Godot first); **level-up rarity** `MOD_CHOICE_W=[52,27,15,6]` (Legendaria 0.97 % → 6.00 % at luck 0,
2.56 % → 10.24 % at the luck ceiling — measured by replaying the extracted `_roll_rarity` 200 k× per row);
**tower wheel** re-weighted (`MOD_WHEEL_W`: each curse 8.4 % → 0.39 %, `super` 3.15 % → 28.0 %; per event
any-curse 80.7 % → 6.1 %, any-super 12.0 % → 73.2 %). Tooling: `--deep` round-trip check, `lint-allow.txt`
gate (caught a truncated-match edit), combined flags, `build.sh` version-parameterised.

**2026-11-19 (latest)** — **mod v1 built + installed** into `user://patches/patch_0.2.3.pck`
(sha `954f68c592f08da0…`, official `680b5dfd…` kept pristine in `work/60_patches/orig/`):
`MOD_TOWER_FLOOR_CAP 90` (tower HP ≤ ×189 instead of ×5.4e6 at floor 267), `MOD_TIME_SCALE_CAP 3`
(excess round-clock factor divided out, danger/hell kept), hazards capped to 10 % max HP / 4 s / 2
concurrent. Added `work/60_patches/build.sh` (git-diff-driven compile → pack → member-hash verify →
install/restore) and `mod-v1.patch`. Deleted `work/40_mod` (2.0 GB duplicate, 6.2 GB free now).
Documented update behaviour: every official update path deletes our pack — re-apply with
`patch -p4 --merge`, which was tested to stay silent over developer drift and to conflict loudly.

**2026-11-19 (later)** — Repo/launcher restructure: deleted `work/40_mod/.git` (813 MB; its content
is byte-identical to `30_recovered`, 60-file md5 sample, so the git history tracked a 2 GB duplicate).
`git init` at the **project root** with a default-deny `.gitignore`: 177 files / 5.6 MB tracked
(notes + `play.sh` + the decompiled 0.2.3 source), commit `eff3d98`, tag `v0.2.3-decompiled`.
Added `play.sh` (launch with patches / status / sha256 verify / layer-shadow query / isolated
`user://` sandbox).

**2026-11-19** — Reverse-engineered the live patch layer (`work/60_patches/PATCH_SYSTEM.md`).
`bridge_0.1.273_to_0.2.0.pck` (8 452 members) + `patch_0.2.3.pck` (123 members, incl.
`game_data.gdc`) are **plaintext GDPC v4**, mounted base→bridge→patch (`load_resource_pack` = last
mounted wins, proven in `work/logs/packorder/`); **no hash check on the on-disk packs** — only on
downloads (`updater.gd:378`). 58 + 117 pack scripts decompiled → `effective_0.2.3/`. No pck/asset
anti-tamper (only a runtime HP seal for trainers). Recommended route: **patch the patch**.
Verified too: `--pck-patch` can ADD members that no layer ships (probe `res://brand_new.txt`), which
is how a `tower_traps.gdc` override reaches the top layer.

**After any delegated task that touches `work/`:**

```sh
git log --oneline | head -1                    # unchanged unless the child committed (they must not)
git status --porcelain | wc -l                 # expect 0
git diff --stat v0.2.4-decompiled -- work/60_patches/effective_0.2.4 | tail -1   # the mod, +/- only
```
