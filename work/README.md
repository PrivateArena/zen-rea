# work/ — durable outputs for the Midgard Survivors RE run

Plan: `../ARCHITECTURE_PLAN_portable-rea-re-env.md` §3 (WORK zone), §5 rows 12–13, §6 steps 10–11.

Everything in this tree is *derived* from one read-only input and can be deleted and
regenerated. The input is never written to:

    TARGET (read-only)  /media/jang/free/MidgardSurvivors/midgard-survivors-midgard-survivors-linux/MidgardSurvivors.pck
                        557,218,016 B · GDPC pack_format 4 · 14383 members · 131 `.gdc`

Tools are invoked only through the wrappers in `/media/jang/home/PortableApp/re/bin/`
(`rea`, `gdre_tools`, `godot`). Those wrappers re-point `HOME`/`XDG_*`/`TMPDIR` into
`re/profile/`, so no run ever touches the OS partition. `re/bin/gdre_tools` already injects
`--headless`; do **not** pass it again.

## Directory map

| Dir | Holds | Written by | Regenerable with |
| --- | --- | --- | --- |
| `10_evidence/` | REA evidence JSON, one file per run, timestamped name: `pck-<UTC %Y%m%dT%H%M%S>.json` | `re/bin/rea inspect-artifact … --evidence_output` | re-run item 11.1 (a second run must use a *new* timestamp — REA never overwrites) |
| `20_extracted/` | **intentionally EMPTY** — the landing dir for raw `gdre_tools --extract` output (unmodified members: `.gdc`, `.remap`, `.ctex`, …) | `re/bin/gdre_tools --extract=<PCK> --output=…` | re-run `--extract` |
| `25_scripts/` | scripts-only decompile: 131 `.gd` + 131 `.gd.uid` + `project.godot`, `.godot/` cache, `gdre_export.log`, and `.autoconverted/` holding the 131 original `.gdc`. No `.remap` survives — GDRE consumes them | `re/bin/gdre_tools --recover=<PCK> --scripts-only --output=…` | re-run item 11.4 |
| `30_recovered/` | full recovered project (scenes, resources, imported assets) — the runnable Godot project | `re/bin/gdre_tools --recover=<PCK> --output=…` | re-run item 11.5 (space-gated; staged as `30_recovered.tmp` and `mv`d only on exit 0) |
| `40_mod/` | `git`-baseline copy of `30_recovered/`; the **only** place edits happen | `cp -a` + `git init` (item 11.6) | re-run item 11.6 |
| `logs/` | captured stdout/stderr of every tool: `pck-files.txt`, per-step `.log`, plus scratch like `one-gdc/` | all three wrappers, shell redirection | re-run the corresponding step |
| `50_roundtrip/` | **write-path** sandbox: edited `.gd` → GDRE-compiled `.gdc` (rev 101) → `--pck-patch`ed pack → `--list-files`/hash proof → ready-to-launch `launch_test/MidgardSurvivorsRT/` fixture. VERBATIM recipe + all measurements: `50_roundtrip/REPORT.md` | `re/bin/gdre_tools --compile/--decompile/--pck-patch/--pck-create`, `re/bin/rea extract-artifact` | re-run the command list in `50_roundtrip/REPORT.md` |

`20_extracted/` is left empty **on purpose**: raw `--extract` reproduces a large fraction of the
557 MB PCK and the space here is tight (`/media/jang/free` is the 24 GB partition — see plan
§7 F-SPACE). The two `--recover` passes give us usable `.gd`/`.tscn` output directly, so the raw
extraction is skipped until someone actually needs original bytes (e.g. to hexdump a `.gdc`
header — for that we extract a single member into `logs/one-gdc/` instead of the whole archive).

## Pipeline command block

Run from `/media/jang/free/MidgardSurvivors/zen-rea` — never from inside the TARGET dir
(plan §7 F-SELF). `PCK` and `W` below:

```sh
PCK=/media/jang/free/MidgardSurvivors/midgard-survivors-midgard-survivors-linux/MidgardSurvivors.pck
W=/media/jang/free/MidgardSurvivors/zen-rea/work
G=/media/jang/home/PortableApp/re/bin

# 1. inventory / evidence (REA layer). Timestamped: --evidence_output never overwrites.
"$G/rea" inspect-artifact "$PCK" --detail summary --json \
    --evidence_output "$W/10_evidence/pck-$(date -u +%Y%m%dT%H%M%S).json" \
    > "$W/logs/rea-inspect-1.log" 2>&1

# 2. full archive listing (GDRE layer)
"$G/gdre_tools" --list-files="$PCK" > "$W/logs/pck-files.txt" 2>&1

# 3. bytecode-version probe — derive the real int from one member, not from GDRE's table.
#    rea extract-artifact has NO --members/--extracted_only/--output: selection is by
#    --occurrence-id (repeatable) and the destination is --output-root, which must NOT exist.
#    Occurrence IDs come from the evidence JSON, keyed by logical_path:
 jq -r '.records[0].normalized_result.occurrences[]
       | select(.logical_path|test("\\.gdc$"))
       | [(.declared_size|tostring), .occurrence_id, .logical_path] | @tsv' \
     "$W"/10_evidence/pck-*.json | sort -k1,1nr | head
"$G/rea" extract-artifact "$PCK" \
    --occurrence-id occ_<...> --output-root "$W/logs/one-gdc" \
    > "$W/logs/rea-extract-one.log" 2>&1
od -A d -t x1 -N 16 "$W/logs/one-gdc/scripts/core/main.gdc"
#   47 44 53 43 | 65 00 00 00  ->  magic 'GDSC', then LE int32 = bytecode version = 101

# 4. scripts-only decompile (cheap, always runs first)
"$G/gdre_tools" --recover="$PCK" --scripts-only --output="$W/25_scripts" \
    > "$W/logs/gdre-scripts-only.log" 2>&1

# 5. full recovery (space-gated, staged)
df -B1M --output=avail /media/jang/free | tail -1
"$G/gdre_tools" --recover="$PCK" --output="$W/30_recovered.tmp" \
    > "$W/logs/gdre-recover.log" 2>&1; rc=$?
# GOTCHA (measured here): plain `mv A B` NESTS A inside B when B already exists as a
# directory — and step 10 pre-creates 30_recovered/, so the naive form buries the
# project at 30_recovered/30_recovered/. Remove the (empty) destination first.
if [ "$rc" -eq 0 ]; then rmdir "$W/30_recovered" && mv "$W/30_recovered.tmp" "$W/30_recovered"; \
else rm -rf "$W/30_recovered.tmp"; fi

# 6. mod baseline (only if free space > 2 x du(30_recovered))
cp -a "$W/30_recovered/." "$W/40_mod/"
git -C "$W/40_mod" init -b main
git -C "$W/40_mod" add -A
git -C "$W/40_mod" -c user.name=rea -c user.email=rea@local commit -q \
    -m "baseline: GDRE 2.7.4 recovery of MidgardSurvivors.pck"
```

If step 4 produces garbage because the `.gdc` bytecode revision is newer than GDRE 2.7.4's
table, re-run it with `--force-bytecode-version=<REV>` — where `<REV>` is a **version string
or commit hash** (`4.5.0`, `ebc36a7`), *not* the raw int32: `--force-bytecode-version=101`
fails with `Error: failed to create decompiler for commit 101!` (exit 1).

## Status after the first real run (measured 2026-11-18, GDRE 2.7.4 / REA 6.9.0)

| Item | Result |
| --- | --- |
| Bytecode version in the artifact | magic `GDSC` + LE int32 **101** (offset 4) → GDRE's newest table entry `4.5.0-stable (ebc36a7 / Bytecode version: 101)`; GDRE auto-detected it, no `--force-bytecode-version` needed |
| `25_scripts` | 131/131 `.gd`, `Scripts not decompiled: 0`, `Failed conversions: 0`, 8.7 MB |
| `30_recovered` | exit 0 in 84 s, `Extracted 14383 files`, 131 `.gd`, 1 `.tscn` (`scenes/main.tscn`), 2 `.tres`, 74 `.scn`, 5438 `.png` **plus** the 5439 original `.ctex` (both kept — this is what makes it 2.0 GB: 2,143,784,960 B allocated), 6112 `.import` + 6112 `.md5`, `project.godot` present |
| `40_mod` | **EMPTY — step 11.6 skipped**: free space after the recovery is 4,178,792,448 B, which is **not** > 2 × `du(30_recovered)` = 4,287,569,920 B (short by ~109 MB). Re-run step 11.6 (the `cp -a` + `git init` block) once ≥ 2.1 GB has been freed or the partition grown |
| GDRE per-run log | written **inside the output dir** as `gdre_export.log`, not under `re/profile/.../logs/` |
| REA on a loose `.gdc` | rejected: `code=target_unavailable / "Cannot open artifact: unsupported binary format."`, exit 1 — the bytecode probe must extract from the PCK (as above), never inspect a standalone `.gdc` |

`20_extracted/` is still intentionally empty (see the note above); the original `.gdc` bytecode
is preserved by GDRE itself under `25_scripts/.autoconverted/` and `30_recovered/.autoconverted/`.
