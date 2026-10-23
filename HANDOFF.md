# Echo Technology — Handoff (READ THIS FIRST)

Single source of truth for continuing this project. Any assistant (v0, Claude, ChatGPT, ...) must read
this whole file before editing code, then continue from **Next step**.
Update it at the **start** of every checkpoint (mark `IN PROGRESS` + files you plan to touch) and at the
**end** (mark `DONE` + date + one-line build result). That way an interrupted session — for example,
credits running out mid-turn — is always visible to the next assistant.

## Resume prompt (user: paste this into the next chat)

> Continue the Echo Technology Minecraft mod. First read `HANDOFF.md` in the project root, run
> `bash scripts/setup-java.sh`, verify the last checkpoint still builds, then continue from "Next step".
> Update HANDOFF.md after every checkpoint. Do not change the Minecraft version, loader, mod ID, or package.

## Project in one paragraph

Fabric mod for Minecraft Java **1.21.1**, mod ID `echo_technology`, package `com.echotechnology`.
Dark sculk-tech style with cyan energy. Core loop: craft the **Echo Reactor** -> burn fuel -> **Echo Energy (EE)**
-> pushed into adjacent machines -> **Echo Fabricator** makes components -> **tools** and **upgrades**.
The user has **no PC** and plays Java Edition through a mobile launcher, so every checkpoint must end with a
downloadable `.jar`. The credit budget is small: work in verified steps, avoid redundant builds.

## Verified configuration (checked 2026-10-23 against meta.fabricmc.net / maven.fabricmc.net)

| Component | Version | Notes |
|---|---|---|
| Minecraft | 1.21.1 | fixed |
| Java | 21 | sandbox: Amazon Corretto 21.0.12.1 installed by `scripts/setup-java.sh` |
| Yarn mappings | 1.21.1+build.3 | latest for 1.21.1 |
| Fabric Loader (dev) | 0.19.5 | latest stable; `fabric.mod.json` should require `>=0.16.0` so older launcher installs work |
| Fabric API | 0.116.17+1.21.1 | latest build for 1.21.1 |
| Fabric Loom | 1.11.8 | its Gradle module metadata requires Gradle API 8.14 |
| Gradle wrapper | 8.14.3 | distribution URL responds 200 |

The Loom 1.11.8 + Gradle 8.14.3 pair has not yet been proven by a real build; CP1 confirms it.

## Checkpoints

A checkpoint is `DONE` only after `scripts/build-mod.sh` succeeds and the JAR is in `public/downloads/`.
Mod version = `0.<checkpoint>.0` (CP1 -> 0.1.0), so the newest JAR is obvious on the phone. CP7 ships 1.0.0.

| # | Scope | Status |
|---|---|---|
| CP0 | Handoff system, sandbox inspection, version verification, JDK setup script | DONE (2026-10-23) |
| CP1 | Gradle project + wrapper, `fabric.mod.json`, entrypoints, one item + one block with textures, texture generator, `scripts/build-mod.sh`, first JAR, mobile download page | TODO <- next |
| CP2 | Energy API (`EnergyStorage` + interfaces, unit tests); Echo Reactor block entity: fuel slot, generation, NBT, screen with synced energy bar | TODO |
| CP3 | Push transfer to adjacent receivers; Echo Fabricator: inventory, 3+ recipes, energy per tick, progress bar, output-space checks, NBT, screen, tests | TODO |
| CP4 | Echo Drill + Echo Scanner (item energy, cooldowns, server-side checks); Echo Charger as the second powered machine | TODO |
| CP5 | Efficiency + Capacity upgrades wired into reactor/fabricator logic; all crafting recipes; upgrade tests | TODO |
| CP6 | Visual polish: final textures, GUI art, particles, lang, mod icon | TODO |
| CP7 | README, CHANGELOG, manual in-game checklist, final engineering report, version 1.0.0 | TODO |

Budget priority if credits run low: CP1 -> CP2 -> CP3 (minimum playable loop) -> CP4 -> CP5 -> CP6 -> CP7.

## Next step

CP1:
1. Create `echo-technology/` with `settings.gradle`, `build.gradle`, and `gradle.properties` using the versions
   above, plus `org.gradle.jvmargs=-Xmx2G` (sandbox has 2 CPUs and 4 GB RAM).
2. Generate the wrapper outside the project: download Gradle 8.14.3 into `/tmp`, run
   `gradle wrapper --gradle-version 8.14.3` in an empty temp dir containing an empty `settings.gradle`, then
   copy `gradlew`, `gradlew.bat`, and `gradle/wrapper/*` into `echo-technology/`.
3. Add `fabric.mod.json`, `EchoTechnology` (main) and `EchoTechnologyClient` entrypoints, one item and one
   block with generated textures, models, blockstate, lang, and loot table.
4. Write `scripts/build-mod.sh` (see "Build rule"), build, fix errors, publish the JAR, add the download page.

## Locked design decisions (change only with a written reason here)

- **Energy unit:** Echo Energy (EE), stored as `long`, always clamped to `[0, capacity]`. Own minimal API in
  `com.echotechnology.energy`; no Team Reborn Energy dependency, so the player only needs Fabric API.
- **Transfer:** push-based. Each server tick, a provider offers energy to adjacent receivers:
  `min(provider extract limit, receiver insert limit, stored)`. Simulate first, then commit, so energy is never
  created or destroyed. Skip neighbours in unloaded chunks or with removed block entities.
- **Server authority:** all machine processing runs in the server-side block entity tick; tools validate energy
  and cooldowns on the server.
- **Persistence:** every machine saves energy, inventory, progress, burn time, and upgrades in NBT.
- **Textures:** original 16x16 pixel art produced by a Node script (`echo-technology/tools/gen-textures.mjs`,
  created in CP1; uses only built-in `zlib`). Palette: slate `#0b1418`, sculk teal `#0f3b44`,
  metal `#2a3a40`, cyan energy `#29dfeb`, highlight `#b8fbff`. Generated PNGs are committed.
- **Build rule:** never run Gradle inside the saved project folder. `scripts/build-mod.sh` rsyncs
  `echo-technology/` to `/tmp/echo-build` (excluding `build/`, `.gradle/`, `run/`), runs
  `./gradlew build` there, then copies back only the JAR and a short test summary. This keeps thousands of
  Gradle cache files out of v0's saved versions.

## Minecraft 1.21.1 pitfalls (avoid mixing APIs from other versions)

- Use `Identifier.of("echo_technology", "name")`; the `Identifier` constructor is private since 1.21.
- Data folders are singular since 1.21: `data/<ns>/recipe/`, `loot_table/blocks/`, `tags/block/`, `tags/item/`.
- Recipe results use `"id"`: `"result": { "id": "echo_technology:echo_reactor", "count": 1 }`.
- Item stack data (for example tool energy) uses data components (a custom `ComponentType` with codec + packet
  codec registered in `Registries.DATA_COMPONENT_TYPE`), not raw stack NBT.
- Block entity `writeNbt`/`readNbt` and `Inventories.writeNbt`/`readNbt` take a `RegistryWrapper.WrapperLookup`.
- Screen property sync packets are 16-bit: send energy as low/high 16-bit halves through the
  `PropertyDelegate` (or custom data), never as one raw int.
- Fabric `ExtendedScreenHandlerType` takes a `PacketCodec` for opening data (for example `BlockPos.PACKET_CODEC`).
- Blocks need a loot table to drop themselves and a `minecraft:mineable/pickaxe` tag entry.
- Tutorials that use `new Identifier(...)`, plural `recipes/` folders, or `"item"` in recipe results target
  older versions; do not copy them as-is.

## Getting the JAR onto the phone

- Every checkpoint copies the JAR to `public/downloads/echo_technology-<version>.jar`; the page at `/` shows a
  download button. Open the v0 preview on the phone, or publish the project for a permanent link.
- The player also needs Fabric Loader for 1.21.1 (installed through the mobile launcher) and
  Fabric API 0.116.17+1.21.1 (from Modrinth) in the same `mods` folder.

## Where progress is saved

1. **v0 versions:** v0 saves the project after every turn in this chat. Returning to this chat (even after
   credits refill) continues exactly where work stopped.
2. **This file:** what is done, what is next, decisions, and pitfalls, for any assistant.
3. **v0 memory:** a note in the user's v0 memory points future v0 chats to this project and protocol.
4. **Off-platform backup (optional):** connect a GitHub repository in v0 Settings so every change is pushed,
   or use "Download ZIP". A GitHub Actions workflow could be added later to build the JAR in the cloud.
5. **Last good JAR:** `public/downloads/` always keeps the latest working build, so an unfinished checkpoint never
   costs the user a playable version.

## Rules for every assistant

1. Keep MC 1.21.1, Fabric, mod ID `echo_technology`, package `com.echotechnology`.
2. One checkpoint at a time; update this file at its start and end (status board, file map, session log).
3. Report status only as: Implemented / Compiled / Unit-tested / Tested in-game / Not tested.
   Never invent build output. The mod has not been launched in Minecraft unless the session log says so.
4. Build only with `scripts/build-mod.sh` (from CP1). Read the full error, fix the root cause, rerun.
   After 3 failed attempts on one issue, simplify that feature and record exactly what changed.
5. Never silently drop a required feature; record any reduction under Known issues.
6. Use targeted edits and short reports — the user's budget is small.

## File map

| Path | Purpose | Status |
|---|---|---|
| `HANDOFF.md` | This file | exists |
| `scripts/setup-java.sh` | Idempotent JDK 21 install; run at the start of every session | exists, tested |
| `.gitignore` | Ignores `echo-technology/` Gradle outputs | exists |
| `scripts/build-mod.sh` | Build in `/tmp`, run tests, copy JAR to `public/downloads/` | CP1 |
| `echo-technology/` | The Fabric mod Gradle project | CP1 |
| `public/downloads/` | Latest built JAR for phone download | CP1 |
| `app/page.tsx` | Mobile download page (the root is a Next.js app) | CP1 |

## Known issues / blockers

- None yet. Loom 1.11.8 + Gradle 8.14.3 is unproven until the CP1 build.

## Session log (newest first)

- 2026-10-23 — CP0 — Inspected sandbox: Amazon Linux 2023 x86_64, 2 CPUs, 4 GB RAM, 61 GB free disk, sudo + dnf
  available, network to Fabric, Mojang, Gradle, and Adoptium OK, Java missing. Verified versions above.
  Added `scripts/setup-java.sh` (installed Corretto 21.0.12.1; a second run confirmed it is idempotent) and
  Gradle ignores in `.gitignore`. No mod code exists yet.
