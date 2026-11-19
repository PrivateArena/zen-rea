# rea_conv.json
*Created: 11/17/2026, 9:18:48 PM*
*Exported: 11/17/2026, 9:18:48 PM*

---

## 1. User

CraftAnything or REA, what is the better options for reverse engineering a Godot game that I like to play, it's free and called Midgard Survivors but the owner added a lot of unfun changes to it, I want to develop it on my own and add my features

---

## 2. AI

**REA (Reverse Engineer Anything)** is the better fit if your goal is to inspect, modify, and build on top of an existing Godot build (`Midgard Survivors`), whereas **CraftAnything** is designed for clean-room recreation rather than extracting or modifying existing binaries.

### Why REA Fits Better Here

- **Actual Binary & Archive Extraction:** REA operates as an MCP server and CLI tool (`morluto/rea`) that inspects existing compiled targets directly. It includes built-in static parsing for Godot `.pck` archives (formats 2, 3, and 4) to inventory and extract embedded files, headers, and directory structures without needing the Godot editor installed.   GitHub+ 1
- **Clean-Room Restriction in CraftAnything:** CraftAnything (`storytold/craft-anything`) explicitly avoids true binary decompilation to steer clear of copyright issues. Instead, it observes how an application behaves and prompts an LLM to write a fresh, approximate clone from scratch—which means you lose the original game's exact tuning, assets, and physics feel rather than patching what is already there.   Reddit

### Comparison for a Godot Workflow

| | **Feature** | | **REA (`morluto/rea`)** | | **CraftAnything (`storytold/craft-anything`)** |
| :--- | :--- | :--- |
| | **Core Approach** | | Static & dynamic binary inspection with evidence mapping | | Behavioral observation + clean-room rewrite |
| | **Godot `.pck` Support** | | Built-in static unpacking & archive inventory (PCK v2/v3/v4) | | Focused on behavioral recreation rather than unpacking |
| | **Output** | | Extracted assets, structures, and code evidence you can rebuild | | Newly generated project inspired by the target |
| | **Best Use Case** | | Modding, reverting unwanted updates, or inspecting exact game logic | | Building a legally distinct clone inspired by an app's UX |

### Practical Caveat for Godot Projects

While REA handles `.pck` inventory and extraction out of the box, full Godot project reconstruction (converting binary `.scn`/`.res` scenes back to `.tscn`/`.tres`, decompiling `.gdc` GDScript bytecode, and rebuilding the `project.godot` file) is still maturing in general-purpose AI RE harnesses.   GitHub

In practice, the cleanest workflow is to let **REA** map out the specific mechanics or changes you want to revert, or pair it with a dedicated Godot decompiler like **GDRE Tools (Godot RE Tools)** to export the `.pck` directly into a runnable Godot project folder, and then use your coding agent to modify the scripts and add your own features. *(Note: Keep modified builds strictly for personal offline use, as redistributing extracted assets or modified commercial/freeware binaries still infringes on the original developer's copyright.)*

For a quick breakdown of how REA's inspection and evidence-mapping workflow operates in practice, see [Reverse Engineer Anything (REA) Explained](https://www.youtube.com/watch?v=Xu-mG1D8ix4).

---

## 3. User

I wonder for Linux, are all the RE engines like Ghidra are pretty much the same with Ghidra being slower, not in capabilities ?

---

## 4. AI

No — on Linux, reverse engineering engines are **not** all the same under the hood, and the difference goes well beyond Ghidra's JVM startup and analysis overhead. While Ghidra's decompiler (which itself is written in native C++ and can be run headless without the Swing GUI) matches or beats commercial tools on exotic CPU architectures, the major Linux engines differ fundamentally in **intermediate representation (IR) architecture, decompiler heuristics, and runtime speed**.

### How the Major Linux RE Engines Actually Differ

| | **Engine** | | **Core Architecture** | | **Speed & Memory Profile** | | **Where It Differs in Capability** |
| :--- | :--- | :--- | :--- |
| | **Ghidra** | | Java Swing UI + native C++ SLEIGH decompiler | | Slow initial auto-analysis and high RAM footprint on massive binaries | | Widest free CPU architecture support; strong collaborative multi-user server |
| | **IDA Pro** | | Native C++ core + Hex-Rays decompiler | | Substantially faster initial pass and lower memory overhead on huge x86/ARM binaries | | Slightly cleaner C pseudocode on heavily optimized C++ (vtables, templates, exceptions) and stronger live debugger integration |
| | **Binary Ninja** | | Native C++ core with a multi-tiered IR stack (LLIL → MLIL → HLIL) | | Fast, multi-threaded analysis with a lightweight native UI | | Designed around programmatic static analysis—querying dataflow and value-set analysis across its IR layers is much cleaner than Ghidra's P-Code API |
| | **Rizin / Cutter** | | Native C core (`rizin`) + Qt GUI (`cutter`), often embedding Ghidra's decompiler (`rz-ghidra`) | | Near-instant CLI startup; ideal for quick binary triage, patching, and batch scripting | | Much lighter project database and weaker deep type propagation compared to Ghidra or IDA on large binaries |
| | **angr** | | Python + C/Rust (`vex` IR) symbolic execution engine | | Computationally heavy (path explosion risk), built for automation rather than interactive browsing | | Solves constraints mathematically (e.g., finding inputs that reach a specific branch) rather than just displaying decompiled C |

### Where Ghidra Is Actually Slower vs. Where It's Just Different

- **The "Slow" Reputation Comes from Two Things:** First, the Java GUI and database serialization overhead when opening multi-megabyte binaries. Second, Ghidra runs aggressive, exhaustive analysis passes by default (like full decompiler parameter ID across every function). If you strip out unnecessary analyzers or run `analyzeHeadless` (which tools like **REA** do when calling Ghidra as a backend), the native C++ decompiler itself is fairly quick.   Medium
- **Decompiler Output Differences:** On standard C code, Ghidra, IDA, and Binary Ninja produce very similar output. The real capability gap shows up in **heavily optimized C++, Rust, or Go binaries**—where IDA's Hex-Rays and Binary Ninja's HLIL often handle inlined functions, struct recovery, and control-flow flattening with fewer manual type fixes than Ghidra.
- **For Godot Specifically:** None of these native binary engines are the primary tool for a standard Godot game unless the developer compiled custom GDExtension/C++ modules. Godot's actual game logic lives in **GDScript bytecode (`.gdc`)** or **C# assemblies (`.dll`)** inside the `.pck` archive—which require bytecode decompilers (`gdre_tools` or `ILSpy`/`AvaloniaILSpy` on Linux) rather than a native machine-code decompiler like Ghidra.

---

## 5. User

So for Linux, is Ghidra the only free (no nag, no shareware) option ?

---

## 6. AI

No—Ghidra is by far the most complete free all-in-one suite, but there are several **100% free, open-source (no nagware, no time limits, no paywalled decompiler)** alternatives on Linux, each targeting a slightly different workflow:

### 1. Native Machine-Code RE Engines (Fully Free & Open-Source)

- **Rizin + Cutter (`GPL-3.0` / `LGPL-3.0`):** The actively maintained, clean fork of Radare2 (`rizin` is the fast native C CLI/library; `cutter` is its native Qt desktop GUI). It has zero nag screens and integrates Ghidra's native C++ decompiler (`rz-ghidra`) directly inside a fast, lightweight C/C++ interface without needing Java.
- **Radare2 + iaito (`LGPL-3.0`):** The original Unix-style CLI reverse engineering framework and its official Qt frontend (`iaito`). Very fast startup and scriptable in Python/JS/C, though steeper to learn than Cutter.
- **angr (`BSD-2-Clause`):** A Python-driven binary analysis and symbolic execution framework (with an optional GUI called `angr-management`). Better suited for automated static analysis, control-flow graph extraction, and constraint solving than manual point-and-click browsing.
- **REDasm (`GPL-3.0`):** A lightweight, native C++/Qt interactive disassembler for Linux that feels closer to classic IDA in layout, though it focuses on disassembly/graphing rather than high-level C decompilation.

### 2. Freeware / Limited Tiers (Important Distinction)

- **IDA Freeware:** Free to download on Linux, **not** open-source, and comes with restrictions (only x86/x64 architectures, cloud-only Hex-Rays decompiler, no commercial use, and no plugin SDK).
- **Binary Ninja Free:** Free tier on Linux, but intentionally strips out the Medium/High-Level IL decompiler views, headless API, and plugin support (those require the paid license).

### 3. What You Actually Need for *Midgard Survivors* (Godot on Linux)

Because *Midgard Survivors* is a **Godot** game, native disassemblers like Ghidra or Rizin are mostly unnecessary unless the game ships native C++ GDExtension libraries (`.so` / `.dll`). Instead, the standard free/open-source Linux stack for Godot is:

- **GDRE Tools (`gdsdecomp`, `MIT` license):** Native Linux CLI and GUI tool built specifically for Godot. It unpacks `.pck` archives, decompiles `.gdc` GDScript bytecode back into readable `.gd` source files, reconstructs binary `.scn`/`.res` scenes into `.tscn`/`.tres`, and regenerates a runnable `project.godot` you can open straight in the official Linux Godot editor.
- **AvaloniaILSpy / ILSpy (`MIT` license):** Only needed if the game was built with Godot Mono/C# (if you see `.dll` files like `Midgard Survivors.dll` inside the extracted files). It decompiles C# assemblies back into clean C# projects on Linux.

In short: if you want a fast, zero-Java, completely free native binary tool on Linux, **Rizin + Cutter (with `rz-ghidra`)** is the closest counterpart to Ghidra—and for Godot games specifically, **GDRE Tools** will get you straight to editable source code in minutes.

---

## 7. User

How much space do you expect those RE tools will take ? I wonder should I just point the README of REA to my Q38FN and let it install everything, I prefer them to be portable, 1 install, even after wiping OS I can still use them

---

## 8. AI

The storage footprint is tiny compared to full native RE suites—especially if you skip Ghidra for now and stick to Godot-specific + lightweight tools.

### Disk Footprint & Portability Breakdown

| | **Tool** | | **Unpacked Size** | | **Dependencies / Runtime** | | **OS-Wipe Portability (on a separate `/home` or data drive)** |
| :--- | :--- | :--- | :--- |
| | **GDRE Tools (`gdsdecomp`)** | | ~60–110 MB | | Self-contained C++ Linux binary (zero external runtime) | | **100% Portable** — drop the extracted folder on your persistent drive and run `./gdre_tools` directly |
| | **REA (`rea-agents`)** | | ~40–80 MB | | Node.js (22+ / 24+ / 26+) | | **Portable if installed locally** (`pnpm add` into a dedicated folder on your persistent drive rather than global `/usr`) |
| | **Rizin + Cutter (AppImage)** | | ~180–250 MB | | Self-contained AppImage (includes `rz-ghidra` + Qt) | | **100% Portable** — single executable file, survives any OS wipe |
| | **Ghidra + OpenJDK 21** | | ~1.2–1.6 GB | | Requires JDK 21+ (`~350 MB`) + Ghidra (`~900 MB`) | | **Portable** — unpack both JDK and Ghidra into a folder on your persistent drive and point `JAVA_HOME` to it |

### Should You Let Your Local Model Run REA's Setup Automatically?

Be careful with `npx rea-agents setup` if you want a **clean, self-contained, OS-wipe-proof setup**:   GitHub

- **What `setup` does by default:** It writes MCP server registrations into global agent config paths under `~/.config` or `~/.claude` / `~/.pi` and caches packages in `~/.npm`. If you wipe your OS partition (or forget to symlink those dotfiles), your agent loses the registration, and default `npm` installs scatter files into system paths.
- **Better approach for portability:** Keep everything inside a single directory on your persistent data partition (for example, `/mnt/home/tools/re/`):

1. **Grab GDRE Tools first:** Download the Linux release archive from `GDRETools/gdsdecomp` and unpack it into `/mnt/home/tools/re/gdre/`. For a Godot game like *Midgard Survivors*, GDRE Tools alone will unpack the `.pck` and decompile the `.gdc` scripts into a full Godot project without needing Ghidra or Node at all.
2. **Install REA locally (no global pollution):** Inside `/mnt/home/tools/re/rea/`, run `pnpm init && pnpm add rea-agents` (or `npm install rea-agents`). That puts the binary at `/mnt/home/tools/re/rea/node_modules/.bin/rea` with zero reliance on `~/.npm` caches.
3. **Wire it into your agent config manually:** Point your agent's MCP config directly to `/mnt/home/tools/re/rea/node_modules/.bin/rea` instead of letting the setup wizard auto-detect and modify multiple dotfiles.
4. **Skip Ghidra until you actually need it:** Unless *Midgard Survivors* has custom native C++ `.so`/`.dll` GDExtension libraries that you need to disassemble, skipping Ghidra saves ~1.5 GB and avoids Java environment setup entirely.

For a walkthrough on setting up and using REA's local MCP workflow with coding agents, see [REA: How AI Agents Read Apps Without Source Code (Full Setup)](https://www.youtube.com/watch?v=aaSQVqEa6U4).
