# 50_roundtrip — GDRE Tools 2.7.4 WRITE path, measured end-to-end (offline)

Measured 2026-11-18 on this host. GDRE `v2.7.4` (embeds `Godot Engine v4.8.dev.gh.8a459f517`),
REA 6.9.0. Nothing under the shipped game dir, `work/30_recovered` or `work/40_mod` was written;
no game binary or `.so` was executed. All GDRE/REA calls go through the wrappers in
`/media/jang/home/PortableApp/re/bin/` (which inject `--headless` — never pass it again).

## 0. Names used by every command

```sh
G=/media/jang/home/PortableApp/re/bin                 # gdre_tools, rea, godot wrappers
R=/media/jang/free/MidgardSurvivors/zen-rea/work/50_roundtrip
SRC=/media/jang/free/MidgardSurvivors/zen-rea/work/25_scripts/scripts/autoload/game_data.gd
PCK=/media/jang/free/MidgardSurvivors/midgard-survivors-midgard-survivors-linux/MidgardSurvivors.pck
RES=scripts/autoload/game_data.gdc                    # archive stores RELATIVE, unprefixed paths
```

## 1. VERBATIM command list that worked

```sh
# ---- 1. probe edit (copy, then change ONE string literal) --------------------
mkdir -p "$R"/{src,build,pck,verify,launch_test,logs}
cp "$SRC" "$R/src/game_data.gd"
# line 104, LOADING_TIPS[17]: appended " [RT-TEST]" before the closing quote

# ---- 2. compile .gd -> .gdc (rev 101) ----------------------------------------
cd "$R"
"$G/gdre_tools" --compile=src/game_data.gd --bytecode=4.5.0-stable --output=build
#   -> build/game_data.gdc ; log: "Compiling to bytecode version ebc36a7 (4.5.0-stable)"
od -A d -t x1 -N 8 build/game_data.gdc      # 47 44 53 43 65 00 00 00  = GDSC + LE 101

# ---- 3. round-trip the compile (NOTE: --decompile REQUIRES --bytecode) -------
"$G/gdre_tools" --decompile=build/game_data.gdc --bytecode=4.5.0-stable --output=verify/decompiled
diff src/game_data.gd verify/decompiled/game_data.gd && echo IDENTICAL

# ---- 4. patch a PCK ----------------------------------------------------------
# 4a. writable copy variant (what the brief asked for; costs one full pack of space)
cp "$PCK" "$R/pck/MidgardSurvivors.pck"
"$G/gdre_tools" --pck-patch=pck/MidgardSurvivors.pck \
  --patch-file="$R/build/game_data.gdc=res://scripts/autoload/game_data.gdc" \
  --output=pck/patched/MidgardSurvivors.pck                       # exit 0, ~5 s

# 4b. PREFERRED variant — patch straight off the read-only original (byte-identical
#     output, no 557 MB copy, target untouched: GDRE only reads the input):
"$G/gdre_tools" --pck-patch="$PCK" \
  --patch-file="$R/build/game_data.gdc=res://scripts/autoload/game_data.gdc" \
  --output="$R/pck/patched/MidgardSurvivors.pck"                  # same sha256

# ---- 4c. prove it landed ------------------------------------------------------
"$G/gdre_tools" --list-files=pck/patched/MidgardSurvivors.pck | tail -3   # Total files: 14383
"$G/gdre_tools" --extract=pck/patched/MidgardSurvivors.pck \
  --include='res://scripts/autoload/game_data.gdc' --output=verify/patched_member_gdre
sha256sum build/game_data.gdc verify/patched_member_gdre/scripts/autoload/game_data.gdc

# ---- 5. throwaway packs (--pck-create) ---------------------------------------
mkdir -p "$R/build/mini/sub"
printf 'hello rt\n'        > "$R/build/mini/a.txt"
printf '[application]\n\nconfig/name="mini"\n' > "$R/build/mini/project.godot"
printf 'const X = 1\n'     > "$R/build/mini/sub/b.txt"
for v in 0 1 2; do
  "$G/gdre_tools" --pck-create=build/mini --pck-version=$v --pck-engine-version=4.7.2 \
                  --output=build/mini-v$v.pck
done
# --setting:  exit 0 and session-only, nothing persisted
"$G/gdre_tools" --setting=rt_test/marker=42 --list-bytecode-versions       # exit 0
"$G/gdre_tools" --setting=rt_test_noequals  --list-bytecode-versions       # exit 1

# ---- 6. launch fixture (hardlinks, run by the USER only) ---------------------
mkdir -p "$R/launch_test/MidgardSurvivorsRT" && cd "$R/launch_test/MidgardSurvivorsRT"
T=/media/jang/free/MidgardSurvivors/midgard-survivors-midgard-survivors-linux
cp -al "$T/MidgardSurvivors.x86_64" ./MidgardSurvivorsRT.x86_64
cp -al "$T/libeosg.linux.template_release.x86_64.so" ./libeosg.linux.template_release.x86_64.so
cp -al "$T/libEOSSDK-Linux-Shipping.so" ./libEOSSDK-Linux-Shipping.so
cp -al "$R/pck/patched/MidgardSurvivors.pck" ./MidgardSurvivorsRT.pck
```

### Flag spellings that differ from intuition / from the help text

| Thing | Real spelling | Measured behaviour |
| --- | --- | --- |
| compile | `--compile=<file.gd>` + **`--bytecode=<ver>`** | `--bytecode` is mandatory ("requires --bytecode" in the main list) |
| decompile | `--decompile=<file.gdc>` + **`--bytecode=<ver>`** | WITHOUT `--bytecode`: `Error: --bytecode is required for --decompile`, **exit 255**, help section dumped. The main command list does *not* mention this requirement for `--decompile`. |
| bytecode token | `4.5.0-stable` or commit `ebc36a7` | both resolve to revision 101. GDRE's table entry is `4.5.0-stable (ebc36a7 / 2025-06-27 / Bytecode version: 101)` — the commit is **ebc36a7**, not `ebc3a7` (the brief's spelling is off by one char) |
| output | `--output=<DIR>` for `--compile`/`--decompile`; `--output=<FILE>` for `--pck-patch`/`--pck-create` | same flag, two meanings; for `--compile` it is a *directory*, files land as `<basename>.gdc` |
| patch member | `--patch-file=<local path>=<res:// path>` | `res://scripts/autoload/game_data.gdc` **works** even though the archive stores the relative, unprefixed name `scripts/autoload/game_data.gdc` — GDRE normalises it |
| single member out of a pack | `--extract=<pck> --include='res://**/*.gdc'`-style glob + `--output=<dir>` | far cheaper than `rea extract-artifact` (no 44 MB evidence JSON, no occurrence-id lookup). GDRE writes the member under its relative path + a `gdre_export.log` |
| `--gdre-version` | — | prints `Godot RE Tools v2.7.4` but **exits 1** by design; use `--help` (exit 0) |

## 2. Step 1 — the probe edit

`work/25_scripts/scripts/autoload/game_data.gd` has **no version/display_name string const**
(verified: the only top-level `const X: = "…"` entries are internal ids — `TOWER_LORD`,
`TRAINING_STAGE`, `REBIRTH_CARD`, `TOWER_WINGS`, `CHEST_DIAMOND`, `DROP_SOUND_LEGENDARY`).
Chosen instead: a string literal inside the user-visible `const LOADING_TIPS` array
(rendered on the loading screen by `scripts/ui/menus.gd:3614`).

| | |
| --- | --- |
| file | `work/50_roundtrip/src/game_data.gd` (copy of `work/25_scripts/scripts/autoload/game_data.gd`) |
| line | **104** (= `LOADING_TIPS[17]`, the last element; array spans lines 86–105) |
| before | `	["Estados: crecen con el golpe que los aplica. El veneno se acumula y crece con cada carga (ideal contra jefes y MVP), el fuego salta entre monstruos y el sangrado estalla a los 5 cortes.", ""], ` |
| after | `	["Estados: crecen con el golpe que los aplica. El veneno se acumula y crece con cada carga (ideal contra jefes y MVP), el fuego salta entre monstruos y el sangrado estalla a los 5 cortes. [RT-TEST]", ""], ` |

One character-class change only: ` [RT-TEST]` inserted before the closing quote. Const name,
type (Array of PackedStringArray-ish pairs) and every numeric const untouched. `diff` of copy
vs original = 4 lines (one hunk, line 104) — see `logs/step1_src.diff`.

## 3. Step 2 — compile, accept results

```
Input  : src/game_data.gd                                  595,856 B
Output : build/game_data.gdc                               353,245 B
Header : 47 44 53 43 | 65 00 00 00            -> 'GDSC' + LE int32 101  ✓
Original member (rea extract-artifact, occ_801dbf89e6d3…c3f80,
  --output-root=$R/verify/orig_member — must not exist, must be ABSOLUTE):
           352,812 B, header 47 44 53 43 65 00 00 00, sha256 b909a653…9e7b8
           (== work/25_scripts/.autoconverted/scripts/autoload/game_data.gdc, bit-identical)
Δ size   +433 B (0.12 %) — same ballpark ✓
```
Log: `Compiling to bytecode version ebc36a7 (4.5.0-stable)` / `Compiled src/game_data.gd to
build/game_data.gdc` / `Compilation complete`, exit 0. Not truncated.

Note: `.gdc` bodies are obfuscated by the serializer — **no** plaintext string constants are
findable with `strings`/`grep`, in the shipped file *and* in GDRE's own output (checked against a
198-byte probe compile: `probe/t.gdc`). Presence of the string must be proven by decompile (step 3).

## 4. Step 3 — round-trip, the diff (verbatim)

```
$ diff -u src/game_data.gd verify/decompiled/game_data.gd ; echo "diff exit=$?"
diff exit=0            # zero output: the files are BYTE-IDENTICAL
$ cmp src/game_data.gd verify/decompiled/game_data.gd && echo IDENTICAL
IDENTICAL
sha256 6f886c1e265cd1722fafc25c5d67e54a8367552105c7c70c2a097aa74bfd0aa3  (both files)
```
No GDRE normalizations appeared at all — decompiling GDRE's *own* compile output is an exact
fixpoint (the cosmetic `var x: =` / `-> void :` normalizations only show up when comparing
against the true upstream source, which we do not have). `[RT-TEST]` survived: 1 hit at line 104
of `verify/decompiled/game_data.gd`.

## 5. Step 4 — patch, accept results

| Check | Result |
| --- | --- |
| `--pck-patch` exit | **0** (both variants); `Patched PCK file: pck/patched/MidgardSurvivors.pck`; no error/warning lines in the 89 KB log |
| patched size | 557,358,660 B (was 557,218,016 → **+140,644 B**) |
| `--list-files=` | exit 0, `Total files: 14383` ✓ (same as original); both `res://scripts/autoload/game_data.gdc` and `…game_data.gd.remap` still listed |
| header int at 0x04 | `04 00 00 00` = **4** unchanged ✓; `GDPC` magic ✓; engine version words 0x08/0x0c/0x10 = 4/7/2 unchanged ✓; pack_flags 0x14 = `02 00 00 00` (relative paths, unencrypted) unchanged ✓ |
| bytes that DID change | 0x18 `70 00 00 00`→`80 00 00 00` (file_base 112→128) and 0x20 `d0 9a 20 21`→`20 c0 22 21` (0x21209AD0→0x2122C020) |
| `--pck-patch` off the read-only original | exit 0, sha256 **identical** to the copy-based run ✓ |
| sha256 | copy `a8d0b35b1434571d3c2cea23c9a697a6ea032300ba47d1479f7f3b640328a8b6` = shipped; patched `39726c98d8bc2d6eaac211736e68f682ee4902b90c8d588310b4197c4f4d1a73`; shipped pack after all runs `a8d0b35b…28a8b6` (unchanged) |

**Correction to the acceptance criterion as written:** `0x21209AD0` is *not* a terminator and it
does *not* sit in the tail — it is the little-endian `file_size` u64 at header offset **0x20**
(`d0 9a 20 21`), and it legitimately grows by 139,088 B when you patch a member. Real end-of-pack
signature: the **patched** pack's last 4 bytes are `47 44 50 43` (`GDPC`), while the **shipped**
pack's last 4 bytes are `00 00 00 00` (its index ends with the last entry's 16-byte MD5 + zero
padding). Both parse fine (`--list-files` exit 0, REA inspects both). Use "GDPC magic + format int
4 + `Total files: 14383` + re-extract hash" as the header test, not the 0x21209AD0 word.

### Step 4b — hash pair (member re-extracted from the PATCHED pack)

```
e34ee46a9039669a75c5d3ba16b4dd963f2ebb612c4e1bbcf9a1100c3bab1123  build/game_data.gdc
e34ee46a9039669a75c5d3ba16b4dd963f2ebb612c4e1bbcf9a1100c3bab1123  verify/patched_member_gdre/scripts/autoload/game_data.gdc
```
**Identical** ✓ (353,245 B, `GDSC`+101). Original member for contrast:
`b909a653f36b07a2313c818b0261c584b5196c7e14fee4e2cb5289f32799e7b8` (352,812 B).

REA route also proves the change indirectly and is worth recording: re-using the pre-patch
occurrence id against the patched pack fails —
`code: invalid_request … "Occurrence is not in the current artifact inventory: occ_801dbf89…
Inspect the active artifact again before selecting entries."` (exit 1) — because occurrence ids are
content-derived. `rea inspect-artifact <patched.pck> --detail summary --json` on the patched pack
exits 0 but its evidence JSON does not expose `.records[0].normalized_result.occurrences` in the
shape used for the original (`jq` → `Cannot iterate over null`); not chased further, GDRE `--extract`
is the better single-member path anyway.

## 6. Step 5 — `--pck-create` / ECFG findings (throwaway mini pack only)

`--pck-version N` is written **verbatim** as the little-endian format int at offset 4 — there is no
remapping and **no value yields format 4**:

| `--pck-version` | int32 @0x04 | engine words @0x08/0x0c/0x10 (with `--pck-engine-version=4.7.2`) |
| --- | --- | --- |
| 0 | **0** | 4 / 7 / 2 |
| 1 | **1** | 4 / 7 / 2 |
| 2 | **2** | 4 / 7 / 2 |
| 3, 4 | not accepted (help says `(0, 1, 2)`) | — |

`--pck-engine-version=x.y.z` writes major/minor/patch to header bytes 8/12/16 — proven by
`--pck-engine-version=4.5.0` → `04 00 00 00 | 05 00 00 00 | 00 00 00 00`. `--pck-version=2` also
sets header 0x1C `00 01 00 00` (=0x100), which 0/1 leave zeroed.

**Consequence: `--pck-create` cannot produce a pack with format int 4, so it cannot be used to
rebuild a drop-in replacement for `MidgardSurvivors.pck` (format 4) with GDRE 2.7.4's CLI.
`--pck-patch` is therefore the ONLY measured way to get bytes into a format-4 pack — and it
preserves format 4 and flags itself. `--pck-create` on the full 2.0 GB recovered project was
**NOT tested** (and is not usable for this target for the format reason above).** The project
settings in the shipped pack are `project.binary` (ECFG blob), and no measured command in this
toolset regenerates it: nothing in this run touched project settings.

Working command line (exact, copy-pasteable):
```sh
"$G/gdre_tools" --pck-create=build/mini --pck-version=2 --pck-engine-version=4.7.2 --output=build/mini-v2.pck
# 388-byte pack, 3 members, exit 0, log ends "Writing PCK archive... 0%"
```

`--setting=<NAME>=<VALUE>`: **exists**, is parsed before the main command runs, and does what its
help says in the weak sense (session-scoped): `--setting=rt_test/marker=42` → exit 0 and
`profile/data/godot/app_userdata/Godot RE Tools/gdre_settings.cfg` **byte-identical before/after**
(no persistence, no error even for an unknown key); `--setting=rt_test_noequals` (no `=`) →
`ERROR: invalid --setting format: must be <setting_name>=<value>`, exit 1. Whether a *real* GDRE
setting name actually changes behaviour was **not** proven — arbitrary keys are silently accepted.

## 7. Step 6 — launch fixture

`launch_test/MidgardSurvivorsRT/` (4 files, all hardlinks, link count 2):
```
MidgardSurvivorsRT.x86_64   73,519,416  (stock exe; name pair matches the .pck)
MidgardSurvivorsRT.pck     557,358,660  (the PATCHED pack)
libeosg.linux.template_release.x86_64.so  3,172,104
libEOSSDK-Linux-Shipping.so              26,680,512
```
No `addons/` or `eos/` dir: both live inside the `.pck` (`res://addons/…` ×41 incl.
`eosg.gdextension`, `res://eos/credentials.cfg`); only the two `.so` natives sit beside the exe,
exactly as shipped — and they keep their original file names because `eosg.gdextension` resolves
them by name. Instructions, what to look for, the `--tips-test`/`--last` deterministic path and the
updater caveat (`updater.gd:132-152`) are in `launch_test/RUN.txt`. **Not executed by the agent.**

## 8. Disk / space

| When | `df -B1M --output=avail /media/jang/free | tail -1` |
| --- | --- |
| session start / after step 1 | 4905 / 4903 MB |
| before the 557 MB pack copy | 4903 MB |
| after the copy | 4372 MB (−531) |
| after `--pck-patch` | 3840 MB (−532) |
| after cleanup (final) | **4370 MB** |

`du -sh` per subdir (each measured standalone; the patched pack is hardlinked between `pck/` and
`launch_test/`, so the tree total counts it once):
```
src/ 588K   build/ 388K   pck/ 532M   verify/ 1.3M   launch_test/ 631M   logs/ 1.3M   probe/ 12K
50_roundtrip total: 634M      (without hardlink dedup the dirs would sum to 1.17 GB)
```
Removed after verification (all of them byte-for-byte reproducible, each re-created by the
commands above): `pck/MidgardSurvivors.pck` (the 557 MB writable copy — redundant, step 4b proves
patching the read-only original gives the identical result), `pck/direct/` (the duplicate patched
pack, sha256-identical to `pck/patched/`), `logs/patched-inspect.json` (44.7 MB REA evidence),
`logs/app_userdata.bak` (config backup, confirmed no diff).

## 9. What is NOT proven

1. **Runtime acceptance.** No engine was executed. It is NOT proven that Godot 4.7.2 loads the
   patched pack, nor that it accepts GDRE-regenerated `.gdc` (autoload `GameData` is loaded at boot:
   if GDRE's output were rejected, the game would fail loudly at startup, not silently show the old
   tip — so a boot success is itself the test).
2. **Bytecode equivalence beyond the decompile fixpoint.** The 433-byte size delta comes from
   GDRE recompiling *its own decompiled source* (formatting, inferred types, possibly lost locals /
   constant pooling), not from the 11-char edit. Semantic equality with the original compile of
   `game_data.gd` is unproven — only "same file decompiles to a fixpoint and back-extracts
   byte-identical" is proven. Same argument applies to every other script in the pack: only
   `game_data.gdc` was round-tripped.
3. **`--pck-patch` is not in-place**: it rewrites the whole archive (new file_base 112→128, new
   index). Whether the regenerated index/MD5 table is bit-equivalent to the shipped one for the
   other 14,382 members was not checked member-by-member (count, header words and offsets were).
4. **ECFG / `project.binary`**: never regenerated; `--pck-create` cannot emit format 4 at all, so
   the "change project settings" path is still completely unmeasured.
5. `--setting=` effect on a real GDRE setting, `--pck-create` on the full project, and
   `--embed` / `--key` paths: untested.
