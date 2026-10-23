# Echo Technology — Handoff (READ THIS FIRST)

Single source of truth for continuing this project. Any assistant (v0, Claude, ChatGPT, ...) must read
this whole file before editing code, then continue from **Next step**.
Update it at the **start** of every checkpoint (mark `IN PROGRESS` + files you plan to touch) and at the
**end** (mark `DONE` + date + one-line build result). That way an interrupted session — for example,
credits running out mid-turn — is always visible to the next assistant.

## Resume prompt (user: paste this into the next chat)

> Continue the Echo Technology Minecraft mod from GitHub repo `krushnahon99-netizen/echo-8n`, branch
> `v0/echo-technology` (https://github.com/krushnahon99-netizen/echo-8n/tree/v0/echo-technology).
> First read `HANDOFF.md` in the project root, run `bash scripts/setup-java.sh`, verify the last checkpoint
> still builds, then continue from "Next step". Update HANDOFF.md after every checkpoint.
> Do not change the Minecraft version, loader, mod ID, or package.

## Repositories

| Repo | Role |
|---|---|
| `krushnahon99-netizen/echo-8n` (public) | **This project**, connected to the v0 chat. v0 never commits to `main`; all work goes to branch `v0/echo-technology`. `main` changes only when the user merges a PR, so always check `v0/echo-technology` first. |
| `krushnahon99-netizen/echo` (public) | Earlier attempt from 2026-10-22, **not connected**. Source for the CP1 import. Do not delete it until the import is done. |

### Earlier attempt (`krushnahon99-netizen/echo`, folder `echo-technology/`)

- 44 Java files in the same architecture: `registry/`, `block/`, `block/entity/`, `energy/` (`EchoEnergyStorage`,
  `EnergyTransfer`, `EnergyNode`, `EnergyDistribution`), `machine/` (`ReactorCore`, `FabricatorCore`,
  `ChargerCore`), `recipe/`, `screen/` handlers, client screens, `item/` (`EchoDrillItem`, `EchoScannerItem`,
  `UpgradeItem`, `ChargeableItem`), `upgrade/`, `config/`, and an `EchoConduitBlock`. Includes a Gradle 8.14.3
  wrapper. No tests.
- Its own handoff says the skeleton built once; everything after that was written but never compiled, and the
  build was left **broken** (missing referenced classes). Resources contain only `fabric.mod.json`: no textures,
  models, blockstates, lang, recipes, or loot tables. No JAR was produced.
- Its versions: Loom 1.11.8, Gradle 8.14.3, Yarn 1.21.1+build.3, Loader 0.16.14, Fabric API 0.116.7+1.21.1.
  Not reviewed in this repo yet; treat all of it as unverified.

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

The earlier attempt reports one successful skeleton build with Loom 1.11.8 + Gradle 8.14.3 in a v0 sandbox;
CP1 confirms the pair in this repo.

## Checkpoints

A checkpoint is `DONE` only after `scripts/build-mod.sh` succeeds and the JAR is in `public/downloads/`.
Mod version = `0.<checkpoint>.0` (CP1 -> 0.1.0), so the newest JAR is obvious on the phone. CP7 ships 1.0.0.

| # | Scope | Status |
|---|---|---|
| CP0 | Handoff system, sandbox inspection, version verification, JDK setup script | DONE (2026-10-23) |
| CP1 | Import `echo-technology/` from the earlier attempt, align versions, `scripts/build-mod.sh`, fix compile errors, minimum models/textures/lang for every registered block and item, first JAR, mobile download page | TODO <- next |
| CP2 | Energy API (`EnergyStorage` + interfaces, unit tests); Echo Reactor block entity: fuel slot, generation, NBT, screen with synced energy bar | TODO |
| CP3 | Push transfer to adjacent receivers; Echo Fabricator: inventory, 3+ recipes, energy per tick, progress bar, output-space checks, NBT, screen, tests | TODO |
| CP4 | Echo Drill + Echo Scanner (item energy, cooldowns, server-side checks); Echo Charger as the second powered machine | TODO |
| CP5 | Efficiency + Capacity upgrades wired into reactor/fabricator logic; all crafting recipes; upgrade tests | TODO |
| CP6 | Visual polish: final textures, GUI art, particles, lang, mod icon | TODO |
| CP7 | README, CHANGELOG, manual in-game checklist, final engineering report, version 1.0.0 | TODO |

Budget priority if credits run low: CP1 -> CP2 -> CP3 (minimum playable loop) -> CP4 -> CP5 -> CP6 -> CP7.

Code for CP2-CP5 partly exists in the imported earlier attempt. For those checkpoints, review, complete, and
unit-test that code instead of rewriting it.

## Next step

CP1 (revised 2026-10-23: reuse the earlier attempt instead of writing from scratch):
1. Copy `echo-technology/` from `krushnahon99-netizen/echo` (branch `main`) into this repo, including its
   Gradle wrapper. Do not copy its `HANDOFF.md` (this file supersedes it), but read its
   "Yarn 1.21.1 API reminders" section once.
2. Align `gradle.properties` with the verified table (Fabric API 0.116.17+1.21.1, Loader 0.19.5) and set
   `org.gradle.jvmargs=-Xmx2G` (sandbox has 2 CPUs and 4 GB RAM; the import uses 2560m).
3. Write `scripts/build-mod.sh` (see "Build rule"), build, and fix compile errors from the real output.
   Check Yarn names with `javap` instead of guessing. After 3 failed rounds on one class, simplify it and log it.
4. Add the minimum resources so every registered block and item has a model, texture, and lang entry, then
   publish the JAR and add the download page.

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
4. **GitHub (connected 2026-10-23):** public repo `krushnahon99-netizen/echo-8n`; v0 pushes every turn to branch
   `v0/echo-technology`. Anyone can read it without logging in, so any assistant can continue from it.
   A GitHub Actions workflow could be added later to build the JAR in the cloud.
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

- Loom 1.11.8 + Gradle 8.14.3 is unproven in this repo until the CP1 build (the earlier attempt built a skeleton
  with it once).
- The code to import in CP1 was never compiled as a whole; expect compile errors and missing classes.

## Session log (newest first)

- 2026-10-23 — GitHub check — User connected public repo `krushnahon99-netizen/echo-8n`. Verified without
  logging in: the repo is public, `main` @ 65a9026 matches v0, raw `HANDOFF.md` returns HTTP 200, no `.env` or
  secret files are tracked (`.env*.local` is ignored), and v0 memory is not in the repo. Found the earlier
  attempt in `krushnahon99-netizen/echo` and revised CP1 to import it. Work continues on branch `v0/echo-technology`.
- 2026-10-23 — CP0 — Inspected sandbox: Amazon Linux 2023 x86_64, 2 CPUs, 4 GB RAM, 61 GB free disk, sudo + dnf
  available, network to Fabric, Mojang, Gradle, and Adoptium OK, Java missing. Verified versions above.
  Added `scripts/setup-java.sh` (installed Corretto 21.0.12.1; a second run confirmed it is idempotent) and
  Gradle ignores in `.gitignore`. No mod code exists yet.
