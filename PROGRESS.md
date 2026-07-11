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

- Three sequential 24×18 levels: Grasslands, dual-route Forest Pass, and fast-enemy-focused Frozen Road.
- Grasslands has 15 waves; Forest Pass and Frozen Road have 20 waves each.
- Four buildable tower families:
  - Arrow: reliable physical single-target damage.
  - Cannon: physical splash damage.
  - Frost: magic damage and slowing.
  - Flame: elemental splash damage and non-stacking burn.
- Five enemy families:
  - Grunt, Runner, Brute, Armored, and Boss.
- Three linear tower levels, upgrades, 70% selling refunds, gold rewards, lives, adjustable 1×–3× speed, and victory/defeat states.
- Level-complete continuation, campaign completion, and current-level retry flows with fresh resources per level.
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
- Placement ghosts display tower range before construction, and HUD buttons provide mouse-accessible speed control.
- Wave progress now reports the active wave and remaining-wave count without overflowing after the final wave.
- Wave progress and a Menu button live in the right panel, keeping the battlefield unobstructed; the menu offers resume, confirmation-protected restart, and quit actions.
- Victory and defeat overlays report waves cleared, enemies defeated and leaked, remaining lives, and gold.
- Artwork conventions and replacement instructions are documented in `assets/ART_GUIDE.md`.

## Runtime architecture

The implementation remains intentionally small and data-oriented:

- `game.odin`: shared types, definitions, state, input, and main update orchestration.
- `map.odin`: level-driven routes, tile state, full-height battlefield rendering, and placement preview.
- `towers.odin`: placement, upgrades, targeting, firing, and tower rendering.
- `enemies.odin`: movement, damage/resistances, slow/burn state, and enemy rendering.
- `projectiles.odin`: homing projectiles, direct/splash hits, and combat effect creation.
- `waves.odin`: bounded level/route definitions, three wave sets, level reset, and spawning state machine.
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
- Waves support up to three sequential enemy groups; Grasslands uses mixed groups on waves 6, 8, 11, and 13 while Forest Pass and Frozen Road retain single-group definitions.
- Result screens show deterministic scores and best scores; completed-level best score and best remaining lives are persisted in a versioned user-data text file.
- No audio, settings, level-select menus, difficulty selection, or external data files exist yet.
- Towers support only one targeting policy: enemy furthest along the path.
- Sprites are static; motion comes from rotation, bobbing, tinting, recoil, and procedural effects.
- Fixed-capacity arrays are appropriate for the current slice but failures at capacity are mostly silent.

## Recommended next cycle

Playtest and polish the completed vertical-slice mechanics before adding new systems:

1. Playtest and balance Grasslands mixed waves, tower costs, upgrades, rewards, and resistances.
2. Add essential sound feedback for placement, firing/hits, wave start, leaks, boss spawn, and results.
3. Move tower, enemy, and wave definitions into external data once their schemas stabilize.
4. Add towers and enemies only after mixed-wave composition and balance are stable.

The immediate release criterion is a polished, balanced Grasslands run with mixed enemy roles, a visible score, and a persisted best result. Audio remains the next focused polish pass.
