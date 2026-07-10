# Rune Siege TD — Progress and Current State

Last updated: July 9, 2026

## Project status

Rune Siege TD is a working single-player tower-defense prototype built in Odin with Raylib. The core loop and the Cycle 3 visual/content expansion are implemented. The project now sits between the design document's **Milestone 2: Real TD Mechanics** and **Milestone 3: Vertical Slice Level**.

The game currently compiles successfully with:

```sh
odin check src
odin build src
```

## Playable content

- One fixed-path Grasslands map on a 24×14 building grid.
- 15 waves, ending with an enhanced boss.
- Four buildable tower families:
  - Arrow: reliable physical single-target damage.
  - Cannon: physical splash damage.
  - Frost: magic damage and slowing.
  - Flame: elemental splash damage and non-stacking burn.
- Five enemy families:
  - Grunt, Runner, Brute, Armored, and Boss.
- Three linear tower levels, upgrades, 70% selling refunds, gold rewards, lives, adjustable 1×–3× speed, and victory/defeat states.
- Physical, Magic, and Elemental damage types with centralized resistance multipliers.
- Strongest-slow replacement and refresh behavior, reduced boss slow effectiveness, and one refreshable burn instance per enemy.

## Visual and interface state

- Original low-resolution painted fantasy sprite atlas for terrain, towers, enemies, projectiles, and HUD icons.
- Centralized asset loading and unloading with primitive fallbacks if the atlas is absent.
- Textured terrain, deterministic grass/rock decoration, distinct spawn and exit tiles, shadows, enemy scale differences, health bars, status tints, and damage flashes.
- Tower foundations, directional aiming, recoil, level badges, selected range overlays, and placement ghosts.
- Placement feedback distinguishes valid, invalid, occupied, and unaffordable tiles.
- Fixed-size visual-effect pool for sparks, explosions, frost bursts, flame impacts, and burn embers.
- Restyled right-hand HUD with resource icons, tower cards, affordability feedback, selected-tower statistics, upgrade/sell values, and next-wave previews.
- Artwork conventions and replacement instructions are documented in `assets/ART_GUIDE.md`.

## Runtime architecture

The implementation remains intentionally small and data-oriented:

- `game.odin`: shared types, definitions, state, input, and main update orchestration.
- `map.odin`: fixed path, tile state, battlefield rendering, and placement preview.
- `towers.odin`: placement, upgrades, targeting, firing, and tower rendering.
- `enemies.odin`: movement, damage/resistances, slow/burn state, and enemy rendering.
- `projectiles.odin`: homing projectiles, direct/splash hits, and combat effect creation.
- `waves.odin`: the current 15-wave sequence and spawning state machine.
- `assets.odin`: sprite-atlas lifecycle and asset-ID lookup.
- `effects.odin`: bounded transient visual effects.
- `ui.odin`: virtual-resolution rendering and the in-game HUD.

The game renders to a fixed 1280×720 target and letterboxes it into a resizable, high-DPI-aware window. Mouse input is converted back into logical game coordinates.

## Validation completed

- Odin static check passes.
- Native executable build passes.
- The committed sprite atlas is a valid 1536×1024 RGBA PNG.
- Asset ownership has one load and one matching unload.
- Missing atlas data falls back to primitive rendering rather than preventing play.

## Known gaps and risks

- A complete interactive playthrough and visual review at all target window sizes is still required.
- Wave balance is provisional; waves 11–15 and the Flame/Armored matchup need playtesting.
- Waves contain only one enemy type each because the current `Wave_Def` has a single spawn group.
- There is no pause/restart flow despite `Paused` existing in the game-mode enum.
- Victory and defeat screens are overlays only; retry, next-level, score, and persistence are not implemented.
- No audio, settings, menus, saved progression, difficulty selection, or external data files exist yet.
- Towers support only one targeting policy: enemy furthest along the path.
- Sprites are static; motion comes from rotation, bobbing, tinting, recoil, and procedural effects.
- Fixed-capacity arrays are appropriate for the current slice but failures at capacity are mostly silent.

## Recommended next cycle

Complete the first true vertical slice rather than expanding to another level:

1. Playtest and balance all 15 waves, tower costs, upgrades, rewards, and resistances.
2. Add pause, restart, retry, and a proper result screen with score.
3. Add essential sound feedback for placement, firing/hits, wave start, leaks, boss spawn, and results.
4. Support multi-group waves so later waves can combine enemy roles.
5. Add two more towers and one additional enemy only after the current economy and counters are proven.
6. Move tower, enemy, and wave definitions into external data once their schemas stabilize.

The immediate release criterion is a polished, balanced 15-wave Grasslands run that can be started, paused, completed, failed, and retried without restarting the executable.
