# Rune Siege TD — Terrain Asset Catalog

This catalog covers the authored terrain visuals described in
`DESIGN_TERRAINS.md`. Each terrain pack contains the same 16 runtime-sized
exports plus its original 4×4 source sheet.

## Asset contract

- Exported assets are RGBA PNGs at 128×128.
- `sheet.png` is the 1254×1254 RGB source/reference sheet and is not a
  runtime tile.
- Terrain packs live under `assets/terrain/<terrain-slug>/`.
- The current executable uses the Grasslands pack for the first nine campaign
  maps and retains the shared `assets/sprite_atlas.png` plus primitive
  fallbacks for the remaining terrain chapters. The other packs remain ready
  for later map-specific selection.
- Road artwork is authored vertically; the map renderer can rotate
  `road_straight.png` and `road_corner.png` for the route direction.
- Landmark exports are opaque terrain composites so they can be placed on a
  tile without requiring a separate blocked-tile or decoration system.

## Shared file names

Every pack contains these files:

| File | Purpose |
| --- | --- |
| `sheet.png` | Original 4×4 art-reference sheet |
| `base.png` | Seamless-style terrain surface tile |
| `road_straight.png` | Straight road tile, authored vertically |
| `road_corner.png` | 90-degree road corner, authored for rotation |
| `spawn.png` | Terrain-specific enemy spawn treatment |
| `exit.png` | Terrain-specific exit treatment |
| `landmark_01.png` … `landmark_07.png` | Landmark families listed below |
| `hearth.png` | Hearth, anchorstone, or chapter landmark |
| `accent.png` | Small decorative accent family |
| `crossing.png` | Bridge, crossing, or route landmark |
| `road_edge.png` | Optional road-edge treatment |

## Terrain packs

### 1. Grasslands — `assets/terrain/grasslands/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Farm plot |
| `landmark_02.png` | Broken fence fragment |
| `landmark_03.png` | Standing stones |
| `landmark_04.png` | Hay cart |
| `landmark_05.png` | Stone well |
| `landmark_06.png` | Small bridge |
| `landmark_07.png` | Old watchtower |
| `hearth.png` | Hearth anchorstone |
| `accent.png` | White and yellow flower patch |
| `crossing.png` | Drainage-ditch bridge |
| `road_edge.png` | Stone-edged packed dirt |

Base, roads, spawn, and exit use warm flowered grass, ochre dirt, a blue
crystal marker, and a red bannered marker respectively.

Grasslands is the first runtime-connected terrain pack. Its nine maps use
explicit tile decorations from the pack; landmarks are cosmetic, while
`crossing.png` and `road_edge.png` replace selected straight route tiles.

### 2. Forest Pass — `assets/terrain/forest_pass/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Ancient tree |
| `landmark_02.png` | Root arch |
| `landmark_03.png` | Mossy stone |
| `landmark_04.png` | Rope bridge |
| `landmark_05.png` | Scout platform |
| `landmark_06.png` | Shrine circle |
| `landmark_07.png` | Fallen log |
| `hearth.png` | Forest lantern hearth |
| `accent.png` | Forest lantern |
| `crossing.png` | Stone crossing |
| `road_edge.png` | Leaf-covered road edge |

Base, roads, spawn, and exit use deep moss, root-cracked paving, an old trail
beacon, and a carved rune post respectively.

### 3. Frozen Road — `assets/terrain/frozen_road/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Ruined waystation |
| `landmark_02.png` | Snow-buried wagon |
| `landmark_03.png` | Frozen banner |
| `landmark_04.png` | Ice arch |
| `landmark_05.png` | Cairn |
| `landmark_06.png` | Windbreak wall |
| `landmark_07.png` | Abandoned campfire |
| `hearth.png` | Warm hearth stone |
| `accent.png` | Evergreen cluster |
| `crossing.png` | Ice bridge |
| `road_edge.png` | Snowy road edge |

Base, roads, spawn, and exit use blue-white snow, cracked ice paving, a blue
crystal, and a warm red-orange waystation marker respectively.

### 4. Ruined City — `assets/terrain/ruined_city/`

This pack serves the Ruined Outskirts, Ruined Market, and Ruined Keep maps.

| File | Asset |
| --- | --- |
| `landmark_01.png` | Collapsed wall |
| `landmark_02.png` | Market stall |
| `landmark_03.png` | Broken cart |
| `landmark_04.png` | Cracked statue |
| `landmark_05.png` | Black root cluster |
| `landmark_06.png` | Cracked fountain |
| `landmark_07.png` | Guard post |
| `hearth.png` | Rune hearth |
| `accent.png` | Brazier |
| `crossing.png` | Broken bridge |
| `road_edge.png` | Rubble road edge |

Base, roads, spawn, and exit use broken masonry, dark cobbles, a blue breach
portal, and a red keep gate respectively.

### 5. Sunken Fen — `assets/terrain/sunken_fen/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Tall reeds |
| `landmark_02.png` | Cypress roots |
| `landmark_03.png` | Half-submerged shrine |
| `landmark_04.png` | Small boat |
| `landmark_05.png` | Stilt house |
| `landmark_06.png` | Lantern post |
| `landmark_07.png` | Rope bridge |
| `hearth.png` | Drowned statue hearth |
| `accent.png` | Cattails |
| `crossing.png` | Fish trap |
| `road_edge.png` | Wet causeway edge |

Base, roads, spawn, and exit use waterlogged mud, raised timber causeways, a
lantern post, and a dry-bank shrine respectively.

### 6. Stonefang Mountains — `assets/terrain/stonefang_mountains/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Mine entrance |
| `landmark_02.png` | Crane |
| `landmark_03.png` | Ore cart |
| `landmark_04.png` | Rope bridge |
| `landmark_05.png` | Smithy door |
| `landmark_06.png` | Forge chimney |
| `landmark_07.png` | Warning flag |
| `hearth.png` | Carved anchorstone |
| `accent.png` | Cliffside village |
| `crossing.png` | Stone bridge |
| `road_edge.png` | Mine-track road edge |

Base, roads, spawn, and exit use rocky ground, worn mountain paving, a
rune-carved marker, and a forge or lift marker respectively.

### 7. Ashen Barrens — `assets/terrain/ashen_barrens/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Volcanic vent |
| `landmark_02.png` | Red thorn |
| `landmark_03.png` | Burned watchtower |
| `landmark_04.png` | Ash-covered statue |
| `landmark_05.png` | Charred wagon |
| `landmark_06.png` | Exposed anchorstone |
| `landmark_07.png` | Smoke column |
| `hearth.png` | Cracked-earth hearth |
| `accent.png` | Ember accent |
| `crossing.png` | Basalt crossing |
| `road_edge.png` | Cinder road edge |

Base, roads, spawn, and exit use cracked basalt, dark cinder paving, an
ember-lit marker, and an obsidian hearth marker respectively.

### 8. Glass Desert — `assets/terrain/glass_desert/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Broken mirror |
| `landmark_02.png` | Buried observatory dome |
| `landmark_03.png` | Obelisk |
| `landmark_04.png` | Half-exposed glass road |
| `landmark_05.png` | Glass dune |
| `landmark_06.png` | Sun pillar |
| `landmark_07.png` | Rune lens |
| `hearth.png` | Star-chart hearth |
| `accent.png` | Reflected-light accent |
| `crossing.png` | Glass crossing |
| `road_edge.png` | Sand road edge |

Base, roads, spawn, and exit use sand and blue-white glass, a crystal
sunburst, and a buried observatory marker respectively. Reflections are
decorative and never represent enemies.

### 9. Tempest Coast — `assets/terrain/tempest_coast/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Lighthouse |
| `landmark_02.png` | Signal fire |
| `landmark_03.png` | Dock |
| `landmark_04.png` | Wrecked ship |
| `landmark_05.png` | Rope bridge |
| `landmark_06.png` | Tide pool |
| `landmark_07.png` | Warning bell |
| `hearth.png` | Beacon hearth |
| `accent.png` | Salt-marsh reeds |
| `crossing.png` | Sea cave |
| `road_edge.png` | Wet cliff road edge |

Base, roads, spawn, and exit use dark wet cliff ground, salt-stained stone,
a beacon marker, and a lighthouse marker respectively.

### 10. Moonvale — `assets/terrain/moonvale/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Observatory dome |
| `landmark_02.png` | Star chart |
| `landmark_03.png` | Standing stone |
| `landmark_04.png` | Moonwell |
| `landmark_05.png` | Silver tree |
| `landmark_06.png` | Brass instrument |
| `landmark_07.png` | Broken lens |
| `hearth.png` | Constellation hearth |
| `accent.png` | Moonflower |
| `crossing.png` | Geometric crossing |
| `road_edge.png` | Rune road edge |

Base, roads, spawn, and exit use silver meadow, pale rune stone, a star-glow
marker, and a moonwell marker respectively.

### 11. Crownspire and the First Gate — `assets/terrain/crownspire/`

| File | Asset |
| --- | --- |
| `landmark_01.png` | Crownspire terrace |
| `landmark_02.png` | First Gate |
| `landmark_03.png` | Anchorstone monument |
| `landmark_04.png` | Allied banners |
| `landmark_05.png` | Broken siege engine |
| `landmark_06.png` | Rescued village cart |
| `landmark_07.png` | Forge brazier |
| `hearth.png` | Final hearth |
| `accent.png` | Forest-root motif |
| `crossing.png` | Glass lens motif |
| `road_edge.png` | Fortress road edge |

Base, roads, spawn, and exit use Crownstone, reinforced Crownline paving, an
allied-banner marker, and the First Gate respectively.

## Source and validation

The packs were generated as terrain-specific painted fantasy RTS sheets and
exported from their 4×4 source sheets. Before using a pack in a map, inspect
the exported tile at the game's 40-pixel tile size and preserve the existing
readability rules: road direction must be visible, decoration must not mimic
placement feedback, and optional decorations must never be required for route
traversal.
