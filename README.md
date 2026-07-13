# Rune Siege TD

Rune Siege TD is a single-player, fantasy tower-defense prototype written in [Odin](https://odin-lang.org/) with Raylib. Build towers on the grid, stop enemies before they reach the exit, and clear a six-level campaign.

![Rune Siege TD sprite atlas](assets/sprite_atlas.png)

## Current features

- Six sequential maps: **Grasslands**, **Forest Pass**, **Frozen Road**, **Ruined Outskirts**, **Ruined Market**, and **Ruined Keep**.
- 115 hand-authored waves, including fast, armored, brute, wraith, siege beast, and boss enemies, with sequential mixed-enemy groups.
- Four tower families:
  - **Arrow** — quick physical single-target damage.
  - **Cannon** — physical splash damage.
  - **Frost** — magic damage that slows enemies.
  - **Flame** — elemental splash damage with burn.
- Seven enemy families: Grunt, Runner, Brute, Armored, Wraith, Siege Beast, and Boss.
- Three tower levels, 70% sell refunds, gold rewards, lives, and 1×–3× game speed.
- Deterministic run scores and best score/lives records saved per completed level.
- Minimal generated sound cues for actions, combat impacts, waves, bosses, leaks, and results.
- Pause menu, restart flow, victory/defeat screens, high-DPI support, and a resizable letterboxed window.
- A painted fantasy sprite atlas with safe primitive-rendering fallbacks when the atlas is unavailable.

## Requirements

- [Odin](https://odin-lang.org/docs/install/) with its Raylib vendor package available.
- A desktop environment capable of running Raylib applications.

## Build and run

From the repository root:

```sh
odin check src
odin build src -out:build/game
./build/game
```

For a free-build tester executable, compile with
`-define:RUNE_SIEGE_TESTER_MODE=true`. Page Up and Page Down switch levels;
the tester build labels itself in-game and does not alter normal saved results.

On Windows, run `build/game.exe` instead.

The sprite atlas is embedded into the executable at compile time. The built
executable still requires the repository's `data/` directory at runtime. Keep
the working directory at the repository root, or copy `data/` alongside the
executable's working directory. The destination PC must still have a
compatible Windows architecture and graphics support.

Completed runs are appended to `playtest_runs.txt` beside the saved results
in the platform user-data directory, including final resources and every
tower's tile and level.

## How to play

Enemies travel along the brown paths from blue spawn tiles to red exit tiles. Select a tower, then left-click an empty green tile to build it. Click an existing tower to inspect it and upgrade or sell it.

| Action | Keyboard | Mouse |
| --- | --- | --- |
| Choose Arrow / Cannon / Frost / Flame | `1` / `2` / `3` / `4` | Tower cards in the side panel |
| Place or select a tower | — | Left-click a map tile |
| Start a wave | `Space` | **Start Wave** button |
| Win the current wave | `Ctrl` + `Shift` + `W` | — |
| Win the current level | `Ctrl` + `Shift` + `L` | — |
| Change game speed | `-` / `=` | Speed buttons |
| Upgrade selected tower | `U` | **U** button |
| Sell selected tower | `S` | **S** button |
| Cycle selected tower targeting | `Tab` | **Target** button |
| Clear selection | — | Right-click |
| Open or close pause menu | `Esc` | **Menu** button / menu controls |
| Restart from pause menu | `R` | **Restart** button |
| Quit from pause menu | `Q` | **Quit** button |

Each completed wave awards gold and starts a short countdown to the next one. A level is won when all waves are cleared and lost when lives reach zero. Press `Enter` or click the result button to retry after defeat or continue after a non-final level victory.

## Project layout

```text
src/
  main.odin         Application setup and game loop
  game.odin         Shared types, state, input, and update orchestration
  map.odin          Map tiles, paths, and placement preview
  waves.odin        Levels, waves, spawning, and level reset
  towers.odin       Tower placement, upgrades, targeting, and rendering
  enemies.odin      Movement, health, damage resistance, and status effects
  projectiles.odin  Projectile behavior and splash hits
  effects.odin      Temporary combat visual effects
  ui.odin           HUD, menus, and virtual-resolution rendering
  save.odin         Local result serialization and persistence
  save_test.odin    Focused scoring and save-format tests
  content.odin      JSON content loading and validation
  content_test.odin Content schema and capacity tests
  assets.odin       Sprite-atlas loading and lookup
data/
  towers.json       Tower definitions
  enemies.json      Enemy definitions and resistances
  maps/             Level metadata and fixed routes
  waves/             Per-level wave definitions
assets/
  sprite_atlas.png  Runtime art atlas
  ART_GUIDE.md      Atlas layout and replacement guidance
```

## Development notes

The project is an intentionally compact prototype. Tower, enemy, wave, and
level map definitions are loaded from versioned JSON files in `data/`; music,
settings, additional targeting policies, and broader campaign systems remain
in code or are not yet implemented. Results are saved in the platform user
data directory rather than in the project folder.

See [DESIGN.md](DESIGN.md) for the broader game design direction, [PROGRESS.md](PROGRESS.md) for the current implementation status, [BACKLOG.md](BACKLOG.md) for open visual and content work, and [assets/ART_GUIDE.md](assets/ART_GUIDE.md) for artwork replacement instructions.

The complete authored terrain pack is cataloged in
[DESIGN_ASSETS.md](DESIGN_ASSETS.md), with one reusable asset directory for
each of the eleven terrain chapters.
