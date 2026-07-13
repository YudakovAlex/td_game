# Rune Siege TD — Progress and Current State

Last updated: July 12, 2026

## Project status

Rune Siege TD is a working single-player tower-defense game built in Odin with Raylib. The core loop, authored terrain packs, and complete 99-level campaign are implemented.

The game currently compiles successfully with:

```sh
odin check src
odin build src
```

## Playable content

- Ninety-nine sequential 24×18 levels across eleven terrain chapters, with nine levels and nine waves per chapter.
- Every chapter follows its terrain design beats, introduces the intended enemy roles in order, and ends with a named boss represented by the current generic Boss family.
- Four buildable tower families:
  - Arrow: reliable physical single-target damage.
  - Cannon: physical splash damage.
  - Frost: magic damage and slowing.
  - Flame: elemental splash damage and non-stacking burn.
- Seven enemy families:
  - Grunt, Runner, Brute, Armored, Wraith, Siege Beast, and Boss.
- Three linear tower levels, upgrades, 70% selling refunds, gold rewards, lives, adjustable 1×–3× speed, and victory/defeat states.
- Level-complete continuation, campaign completion, and current-level retry flows with fresh resources per level.
- Physical, Magic, and Elemental damage types with centralized resistance multipliers.
- Strongest-slow replacement and refresh behavior, reduced boss slow effectiveness, and one refreshable burn instance per enemy.
- Minimal runtime-generated sound cues for actions, impacts, wave starts, bosses, leaks, and results, with safe fallback when audio is unavailable.

## Visual and interface state

- Original low-resolution painted fantasy sprite atlas for terrain, towers, enemies, projectiles, and HUD icons.
- Centralized asset loading and unloading with primitive fallbacks if the atlas is absent.
- Grasslands terrain pack connected to the first nine maps, including directional roads, endpoint markers, and explicit cosmetic landmark placement.
- Textured terrain, deterministic grass/rock decoration, distinct spawn and exit tiles, shadows, enemy scale differences, health bars, status tints, and damage flashes.
- Tower foundations, directional aiming, recoil, level badges, selected range overlays, and placement ghosts.
- Placement feedback distinguishes valid, invalid, occupied, and unaffordable tiles.
- Fixed-size visual-effect pool for sparks, explosions, frost bursts, flame impacts, and burn embers.
- Restyled right-hand HUD with resource icons, tower cards, affordability feedback, selected-tower statistics, upgrade/sell values, and next-wave previews.
- Placement ghosts display tower range before construction, and HUD buttons provide mouse-accessible speed control.
- Road tiles now follow route direction, with rotated straight segments and turn-aware corner artwork.
- Road corners share the terrain road treatment with straight segments, with visible connectors for every route orientation.
- Ruined Outskirts enemy movement consumes route segments directly, including turns crossed in a single update.
- HUD text uses stronger contrast and fitting labels for small controls and status displays.
- A compile-time tester build can switch levels with Page Up/Page Down and bypass tower gold restrictions; completed runs are logged with tower layouts.
- Wraith and Siege Beast use dedicated atlas visuals with primitive fallbacks when artwork is unavailable.
- Ruined Outskirts has a distinct desaturated ruined palette, darker roads, and restrained deterministic rubble details.
- Wave progress now reports the active wave and remaining-wave count without overflowing after the final wave.
- Wave action/status labels now distinguish starting, countdown, spawning, clearing, finished, and paused states; active spawning reports remaining enemies.
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
- `waves.odin`: bounded level/route definitions, campaign wave sets, level reset, and spawning state machine.
- `assets.odin`: sprite-atlas and Grasslands terrain lifecycle with asset-ID lookup.
- `effects.odin`: bounded transient visual effects.
- `ui.odin`: virtual-resolution rendering and the in-game HUD.
- `content.odin`: versioned JSON loading and validation for towers, enemies, maps, and waves.

The game renders to a fixed 1280×720 target and letterboxes it into a resizable, high-DPI-aware window. Mouse input is converted back into logical game coordinates.

## Validation completed

- Odin static check passes.
- Odin test suite passes with 41 tests, including route-connectivity rendering cases, Grasslands terrain decoration validation, Ruined Outskirts traversal, wave-status presentation states, Grasslands wave-curve, Ruined City content, campaign continuation, save compatibility, and tower/enemy matchup regression coverage.
- Native executable build passes.
- A native launch was attempted, but the current environment could not open its X11 display or initialize audio; no interactive playthrough was completed here.
- The committed sprite atlas is a valid 1536×1280 RGBA PNG with dedicated Wraith, Siege Beast, and turn-road cells.
- Asset ownership has one load and one matching unload.
- Missing atlas data falls back to primitive rendering rather than preventing play.

## Known gaps and risks

- A complete interactive playthrough and visual review at all target window sizes is still required. Runtime graphics and audio could not be exercised in this environment because no X11 display or audio device is available.
- Wave balance is provisional across the expanded campaign and needs interactive playtesting.
- Waves support up to three sequential enemy groups; the authored campaign uses that limit for mixed-role defenses.
- Result screens show deterministic scores and best scores; completed-level best score and best remaining lives are persisted in a versioned user-data text file.
- No music/settings, level-select menus, or difficulty selection exist yet. Tower, enemy, wave, and level map definitions load from versioned JSON files in `data/`; campaign order remains fixed in code.
- Towers support only one targeting policy: enemy furthest along the path.
- Sprites are static; motion comes from rotation, bobbing, tinting, recoil, and procedural effects.
- Fixed-capacity arrays are appropriate for the current slice but failures at capacity are mostly silent.

## Recommended next cycle

Playtest and polish the expanded campaign before adding new systems:

1. Playtest and balance all eleven chapter arcs, especially late Wraith/Siege Beast matchups.
2. Add new mechanics only after the 99-level campaign's economy and wave pacing are stable.

The immediate release criterion is a polished, balanced 99-level run with mixed enemy roles, a visible score, persisted best results, and restrained feedback audio.

The campaign content follows the terrain tables in `DESIGN_TERRAINS.md`; a complete interactive playthrough and visual review remain the next validation step when a graphical/audio runtime is available.
