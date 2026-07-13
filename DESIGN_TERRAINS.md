# Rune Siege TD — Terrain Design Bible

This document defines the long-term terrain direction for the eleven-terrain
campaign in `STORY.md`. It is a content and production guide, not a promise
that every described feature already exists in the runtime.

The campaign target is eleven terrain chapters with nine defenses each: 99
hand-authored levels in total. Terrain should change the player's positioning,
coverage, timing, or matchup decisions while preserving the game's readable
fixed-route tower-defense rules.

## How to read this document

- **Implemented** means supported by the current 99-level campaign or current
  data model.
- **Planned content** means maps, waves, art, or presentation that can use the
  current systems.
- **Optional future support** means a possible engine or content extension. It
  must not be treated as a requirement for the terrain to be fun or shippable.

The current implementation provides four towers—Arrow, Cannon, Frost, and
Flame—and seven enemy families—Grunt, Runner, Brute, Armored, Wraith, Siege
Beast, and Boss. Maps use fixed orthogonal routes on a 24×18 grid, with
buildable tiles separated from path tiles. Waves contain up to three ordered
enemy groups. Terrain design should use that vocabulary first.

## Campaign structure

Every terrain follows the same nine-defense rhythm:

1. Introduce the terrain's visual language and route idea.
2. Reinforce the relevant existing enemy or tower decision.
3. Present the first terrain-specific pressure.
4. Combine that pressure with a familiar enemy role.
5. Complicate coverage through a bend, split, bottleneck, or timing choice.
6. Test a damage-type or targeting matchup.
7. Deliver the terrain's strongest mixed wave.
8. Give the player a readable preparation wave before the boss.
9. End with a named boss identity using the current generic Boss fallback when
   no unique runtime behavior exists.

The nine defenses are a pacing and authoring pattern, not nine identical wave
counts or a requirement for nine new mechanics. Each level still needs its own
route geometry and strategic reason to exist.

## Campaign progression

| Terrain | Strategic identity | Route progression | Enemy emphasis | Story movement |
| --- | --- | --- | --- | --- |
| Grasslands | Learn coverage, economy, and tower roles | One forgiving route with readable bends | Grunt, Runner, Brute, first Armored | The Crownline wakes in public view |
| Forest Pass | Divide coverage between routes | Two routes with shared central coverage | Runner pressure and early Brute combinations | Forest folk decide whether to help |
| Frozen Road | Control long exposed lanes | Long route with alternating straightaways | Runner timing, Brute durability, first Wraith | The dead are being stolen from history |
| Ruined City | Build around urban obstruction | Outskirts, Market, and Keep gradually tighten space | Armored, Wraith, Siege Beast, Boss | The Hollow King was the first Warden |
| Sunken Fen | Protect causeways and islands | Raised roads, islands, and readable crossings | Runners, Wraiths, mixed low-visibility atmosphere | The Crownline runs through water |
| Stonefang Mountains | Exploit bottlenecks without losing villages | Passes, bridges, and mine approaches | Brutes, Armored, Siege Beasts | Mountain forges restore the defenses |
| Ashen Barrens | Manage exposed routes and heavy pressure | Long open lanes broken by vent-side anchors | Brutes, Siege Beasts, elemental-matchup tests | The first seal-breaking scar is revealed |
| Glass Desert | Make good use of bends and mirrored sightlines | Sparse, exposed routes around observatories | Runners, Wraiths, Boss combinations | The hearths are being used as a key |
| Tempest Coast | Cover cliff roads and separated approaches | Coast road, marsh road, and cave exits | Runners, Siege Beasts, Wraiths | The lighthouse chain calls across the sea |
| Moonvale | Prepare for the final alignment | Calm, geometric routes with deceptive visual framing | Wraiths, Armored, mixed elite waves | The fallen star's purpose becomes clear |
| Crownspire and the First Gate | Combine every learned decision | Converging roads and final fortress lanes | Every existing enemy family | The Crownline seals the Hollow King again |

## Terrain specifications

### 1. The Grasslands

**Role and tone:** The welcoming beginning: broad, bright, practical, and
slightly untidy. The player should immediately understand where enemies travel
and where towers can be placed. The danger comes from having little shelter
for a poor decision, not from surprise rules.

**Visual language:** Warm green grass, ochre soil, blue sky highlights, and
small white or yellow flowers. Use warm upper-left lighting and keep the road
one value darker than the field.

**Surface and road set:** Flowered grass base tile; packed tan dirt road;
distinct blue spawn marker; red bannered exit; simple straight and corner road
tiles. The existing Grasslands map and atlas are the reference implementation.

**Artifacts:** Farms, fence fragments, standing stones, hay carts, wells,
small bridges over drainage ditches, and old watchtowers. Decorations must not
cover buildable tile feedback or make a blocked tile resemble a valid tile.

**Route and placement identity:** One route with readable bends and several
strong but not mandatory tower positions. Early maps should teach that Arrow is
reliable, Cannon likes groups, Frost buys time, and Flame rewards clustered
traffic.

**Enemy and boss direction:** Grunts establish the baseline; Runners teach
coverage; Brutes teach sustained damage; Armored introduces the physical-versus
magic decision. The named boss is **The Broken Standard**, a former royal
captain represented initially by the current Boss family.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts on the basic bend | Learn route reading and first tower placement |
| 2 | Grunts with a longer approach | Upgrade versus second tower |
| 3 | First Runners | Keep both long and short sections covered |
| 4 | Runners followed by Grunts | Targeting and timing under mixed traffic |
| 5 | First Brutes | Add sustained damage without abandoning speed control |
| 6 | Brutes with Runners | Pair Frost or Arrow coverage with splash damage |
| 7 | First Armored units | Use magic damage against a physical-resistant threat |
| 8 | Mixed Armored, Brute, and Runner wave | Preserve economy flexibility before the boss |
| 9 | The Broken Standard with support Grunts | Apply the complete opening toolkit |

**Audio and feedback:** Clear road footsteps, a warning bell at the village
exit, and a warm hearth cue on victory. Avoid heavy ambient effects that hide
combat sounds.

**Implementation notes:** This terrain is represented by
`data/maps/grasslands_01.json` through `data/maps/grasslands_09.json` and the
matching wave files. Keep it as the balance reference for later chapters.

### 2. The Forest Pass

**Role and tone:** Ancient, watchful, and quietly skeptical. The forest should
feel alive without hiding information from the player.

**Visual language:** Deep moss, blue-green shadow, muted brown road, pale mist,
and occasional warm lantern light. Use tree masses as a frame around the map,
not as random obstruction over the route.

**Surface and road set:** Root-cracked paving and leaf-covered path tiles;
straight and corner pieces must preserve route direction. Spawn markers can be
old trail beacons; exits can be carved rune posts.

**Artifacts:** Ancient trees, root arches, mossy stones, rope bridges,
scout platforms, shrine circles, fallen logs, and forest lanterns. Trees are
decorative unless a future map format explicitly marks them as blocked.

**Route and placement identity:** Two routes create an allocation problem.
Central buildable positions should cover both routes but be less efficient than
dedicated positions, making tower distribution meaningful without requiring a
new targeting system.

**Enemy and boss direction:** Runners become a recurring threat, while Brutes
arrive on one route to pull coverage away from the other. The named boss is
**The Rootbound Huntsman**, a forest guardian forced into service. It can use
the current Boss family with Runner support.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | One route teaches the forest palette | Read the road through dense decoration |
| 2 | Second route opens with Grunts | Divide early towers or build central coverage |
| 3 | Runners alternate between routes | Decide which lane needs immediate control |
| 4 | Brutes pressure one route | Use damage efficiently without abandoning the other |
| 5 | Sequential Runner groups | Favor range and central overlap |
| 6 | Brutes followed by Runners | Prepare for a tempo change, not just more health |
| 7 | First Armored units on separate routes | Split physical and magic coverage |
| 8 | Mixed routes with staggered timing | Use wave order and targeting policy deliberately |
| 9 | The Rootbound Huntsman | Hold both routes while preserving the central response |

**Audio and feedback:** Bird calls, creaking wood, soft chimes at shrines, and
a low drum when the second route activates. Mist must remain cosmetic and
never obscure enemies, paths, or tower ranges.

**Implementation notes:** `data/maps/forest_pass_01.json` through
`data/maps/forest_pass_09.json` establish the
two-route pattern. New forest maps should vary route length and overlap rather
than add hidden-path or vision rules.

### 3. The Frozen Road

**Role and tone:** Lonely, exposed, and haunted. The visual calm should make
fast enemy movement easy to notice.

**Visual language:** Blue-white snow, desaturated stone, dark evergreen accents,
and bright hearth orange. The road should read as frozen blue-gray paving with
clear edge contrast.

**Surface and road set:** Snowfield base tile; cracked ice-road tiles; icy
corners with visible direction; blue crystal spawn; warm red-orange waystation
exit. Avoid excessive white effects around enemies.

**Artifacts:** Ruined waystations, snow-buried wagons, frozen banners, ice
arches, cairns, windbreak walls, abandoned campfires, and distant mountain
silhouettes.

**Route and placement identity:** Long exposed straightaways alternate with
deep turns. The player gets excellent range positions but must plan for Runners
that cross open ground quickly.

**Enemy and boss direction:** Runners dominate tempo; Brutes and Armored units
punish insufficient sustained damage; Wraiths introduce the story of stolen
dead. The named boss is **Marshal Whitewake**, an armored spirit represented
initially by the generic Boss family with Wraith support.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Slow Grunts on the exposed road | Learn the longer firing windows |
| 2 | Runner burst on a straightaway | Place for early contact, not only the exit |
| 3 | Brutes on the long lane | Invest in damage before control becomes necessary |
| 4 | Runner groups behind Brutes | Prevent fast units from slipping past the heavy screen |
| 5 | First Wraiths | Use physical towers against magic-resistant dead |
| 6 | Wraiths with Runners | Protect physical coverage from being overcommitted |
| 7 | Armored and Brute combination | Make magic damage and splash compete for gold |
| 8 | Long mixed wave with staggered groups | Balance early and late route coverage |
| 9 | Marshal Whitewake | Survive a sustained boss approach with Wraith escorts |

**Audio and feedback:** Wind, distant ice strain, muffled footsteps, and a
single clear spectral cue when Wraiths enter. Snow particles are optional
presentation and must not reduce silhouette readability.

**Implementation notes:** `data/maps/frozen_road_01.json` through
`data/maps/frozen_road_09.json` provide the
long alternating route. Its difficulty should come from timing and spacing,
not from an unannounced slippery-road rule.

### 4. The Ruined City

**Role and tone:** The campaign's revelation chapter: crowded, broken, and
full of evidence that the old kingdom failed from within. It contains three
sub-areas—Ruined Outskirts, Ruined Market, and Ruined Keep—with a clear climb
from open debris fields to fortified final lanes.

**Visual language:** Desaturated stone, charcoal roots, faded banners, dusty
gold, and restrained ember or rune accents. Ruins must frame the playable road
and never make buildable space ambiguous.

**Surface and road set:** Broken masonry base tiles; dark cobbled roads;
collapsed-wall corners; blue portal-like breach spawns; red keep or gate exits.
The current Ruined Outskirts tint and rubble treatment are the minimum
reference, not a complete city tile set.

**Artifacts:** Collapsed walls, market stalls, carts, statues, black roots,
cracked fountains, guard posts, broken bridges, braziers, and keep towers.
Structures are visual landmarks unless explicitly represented as blocked map
tiles.

**Route and placement identity:** Outskirts uses one route with debris framing;
Market uses two routes through separate districts; Keep compresses space into
long fortified lanes. The challenge is dense mixed coverage, not maze-building.

**Enemy and boss direction:** Armored, Wraith, and Siege Beast become the
city's signature threats. The named boss is **The Hollow Castellan**, the old
capital's final commander. Use the current Boss family with a late mixed wave;
the optional future version could have a visible phase change without changing
path rules.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Outskirts: Grunts through rubble | Relearn route readability in a darker palette |
| 2 | Outskirts: Runners on broken bends | Cover interrupted sightlines |
| 3 | Outskirts: First Wraiths | Protect physical damage positions |
| 4 | Outskirts: Brutes and Armored | Build a complete damage-type spread |
| 5 | Market: Two-route mixed traffic | Allocate towers between districts |
| 6 | Market: Siege Beasts with Wraith escorts | Combine elemental pressure with physical coverage |
| 7 | Market: staggered route groups | Make timing and target selection matter |
| 8 | Keep: dense pre-boss defense | Convert the city setup into a fortress |
| 9 | The Hollow Castellan | End the chapter with every city threat in one readable test |

**Audio and feedback:** Distant bells, loose masonry, market creaks, and a
muted rune hum near the hearth. Boss presentation should use the existing boss
cue and a strong entrance effect rather than a large overlay.

**Implementation notes:** The three current map and wave files are the first
implemented terrain arc. Preserve their role as the bridge from the early
campaign to Wraith and Siege Beast content.

### 5. The Sunken Fen

**Role and tone:** Suspicious, wet, and disorienting without becoming unfair.
The player should feel surrounded by water while always knowing where the road
and enemies are.

**Visual language:** Murky green water, dark teal shadows, warm lanterns,
ochre causeways, and pale fog accents. Keep enemies brighter than the marsh.

**Surface and road set:** Waterlogged mud base tile; raised timber or stone
causeway road; plank and stone corner variants; lantern-post spawn; shrine or
dry-bank exit. Fog is a layer behind gameplay objects.

**Artifacts:** Reeds, cypress roots, half-submerged shrines, boats, stilt
houses, lantern posts, rope bridges, cattails, fish traps, and drowned statues.
Use landmarks to orient the player instead of relying on minimaps.

**Route and placement identity:** Routes cross dry islands and raised causeways.
Buildable islands provide strong range but limited placement count. Crossings
should create overlap decisions; there is no need for actual water movement or
path switching.

**Enemy and boss direction:** Runners exploit narrow causeways, Wraiths fit the
drowned-history theme, and Siege Beasts create slow pressure on the longest
raised roads. The named boss is **The Mire Bell-Keeper**, a marsh clan elder
twisted into a herald. The first version uses Boss with Runner and Wraith
support.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts across a single causeway | Learn island placement limits |
| 2 | Runners through a narrow crossing | Cover the approach rather than only the exit |
| 3 | Two visible causeways | Choose a strong island or split coverage |
| 4 | Brutes on the longer route | Make sustained damage work across water gaps |
| 5 | Wraiths near shrine landmarks | Use physical damage without losing lane coverage |
| 6 | Runners and Wraiths in ordered groups | Adapt to speed and resistance together |
| 7 | Siege Beast crossing | Concentrate damage while keeping an escape lane covered |
| 8 | Mixed routes with staggered arrivals | Use route overlap and wave order |
| 9 | The Mire Bell-Keeper | Hold the hearth island against a full marsh procession |

**Audio and feedback:** Insects, distant frogs, lantern crackle, and a low bell
for wave starts. Keep fog, ripples, and fireflies below the contrast level of
paths, enemies, and placement previews.

**Implementation notes:** Planned content can be expressed with ordinary fixed
routes and blocked/buildable tiles. Actual fog-of-war, hidden routes, water
movement, or enemy ambushes are optional future support and are not required.

### 6. The Stonefang Mountains

**Role and tone:** Industrious, dangerous, and physical. This chapter should
make every bridge and mine entrance feel earned.

**Visual language:** Slate, iron gray, cold blue shadow, forge orange, and
muted red banners. Use strong cliff edges to make the route geometry legible.

**Surface and road set:** Rocky ground; worn mountain road; stone bridge and
mine-track road variants; rune-carved spawn; forge or lift exit. Roads should
contrast with cliffs even in dark scenes.

**Artifacts:** Mine entrances, cranes, ore carts, rope bridges, smithy doors,
forge chimneys, warning flags, carved anchorstones, and cliffside villages.
Keep decorative bridges visually separate from traversable bridge tiles.

**Route and placement identity:** Narrow passes and bridge crossings produce
strong tower positions, but isolated villages and alternate mine approaches
prevent one universal kill zone. Use bottlenecks as opportunities, not traps.

**Enemy and boss direction:** Brutes and Armored units test sustained and magic
damage. Siege Beasts are the chapter's signature threat. The named boss is
**The Forge-Eater**, a grave-iron siege creature represented by Boss or Siege
Beast data until a dedicated boss asset is justified.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts through a broad pass | Learn cliff framing and safe placements |
| 2 | Runners across a bridge | Cover the bridge approach and landing |
| 3 | Brutes at a bottleneck | Decide whether to stack damage or extend control |
| 4 | Armored mining guard | Use magic against an entrenched target |
| 5 | Two pass entrances | Protect the village-facing route |
| 6 | First Siege Beasts | Exploit their elemental weakness with Flame |
| 7 | Siege Beast followed by Runners | Avoid overinvesting in slow-target positions |
| 8 | Dense mine-and-bridge mixed wave | Keep both the bottleneck and exit relevant |
| 9 | The Forge-Eater | Endure a heavy approach while supporting the forge relight |

**Audio and feedback:** Hammer strikes, chain lifts, wind through ravines, and
a rising forge tone when a boss enters. Effects should not obscure small bridge
corners or tower bases.

**Implementation notes:** The chapter needs new tiles, decorations, maps, and
waves, but no new tower or enemy family is required for its first pass.

### 7. The Ashen Barrens

**Role and tone:** A scarred, hostile plain where warmth is both resource and
threat. The player should see danger everywhere without needing environmental
damage rules.

**Visual language:** Charcoal soil, red-orange vents, black grass, dusty gray
ash, and occasional bright hearth gold. Keep ash overlays sparse near combat.

**Surface and road set:** Cracked basalt and ash base tiles; dark cinder road;
vent-side corner tiles; ember-lit spawn; obsidian or warm hearth exit.

**Artifacts:** Volcanic vents, red thorn, burned watchtowers, ash-covered
statues, charred wagons, exposed anchorstones, smoke columns, and cracked
earth. Vents are decorative in the initial implementation; they should not
damage towers or enemies without a separately designed system.

**Route and placement identity:** Long open lanes are interrupted by vent-side
curves and anchorstone clearings. Strong positions are obvious, but the player
must choose whether to improve early damage or reserve gold for heavy late
waves.

**Enemy and boss direction:** Brutes and Siege Beasts dominate the visual and
strategic pressure; Runners punish slow, overly concentrated builds. The named
boss is **The Cinder Colossus**, a living echo of the first failed seal break.
Use Boss with Siege Beast and Brute support initially.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts across open ash | Establish long-range coverage |
| 2 | Runners through vent gaps | Keep a fast-response position |
| 3 | Brutes on the central bend | Invest in sustained damage |
| 4 | Brutes with Runners | Preserve both damage and control |
| 5 | Armored units near an anchorstone | Make magic damage relevant again |
| 6 | Siege Beast introduction | Use Flame's elemental advantage |
| 7 | Heavy mixed wave | Choose between splash density and single-target finish |
| 8 | Pre-boss wave with sequential heavies | Make the economy survive repeated pressure |
| 9 | The Cinder Colossus | Test heavy-target preparation without surprise damage |

**Audio and feedback:** Low rumbles, dry wind, vent pops, and a deep ignition
cue for the hearth. Red lighting must never make enemy health bars or route
edges disappear.

**Implementation notes:** The primary work is a coherent surface/decor set and
carefully spaced routes. Environmental damage, spreading fire, and heat meters
are optional future support only.

### 8. The Glass Desert

**Role and tone:** Beautiful, sparse, and unsettling. Reflections suggest
armies that are not there, but the real battle remains completely readable.

**Visual language:** Pale sand, blue-white glass, rose and gold sunrise light,
dark observatory interiors, and sharp reflected highlights. Reflections are
decorative silhouettes or decals, never fake enemies.

**Surface and road set:** Sand-and-glass base tile; translucent pale road with
dark edge; mirrored corner pieces; crystal or sunburst spawn; buried-observatory
exit.

**Artifacts:** Broken mirrors, buried domes, obelisks, half-exposed roads,
glass dunes, sun pillars, rune lenses, and old star charts. Artifacts should
provide orientation through repeated silhouettes.

**Route and placement identity:** Sparse buildable space and long sightlines
make range and firing order valuable. Curves around mirror clusters create
overlap positions; no fake path or decoy enemy is needed.

**Enemy and boss direction:** Runners exploit open space, Wraiths echo the
desert's false armies, and Armored units force magic coverage. The named boss
is **The Mirror Warden**, an observatory guardian. Use Boss with Wraith and
Runner groups; reflected images remain presentation-only initially.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts on a glass road | Read the high-contrast route |
| 2 | Runners on an exposed straight | Value early range and coverage |
| 3 | Armored caravan | Build magic damage before the desert tightens |
| 4 | Wraiths among mirror landmarks | Use physical damage against the spectral threat |
| 5 | Two visible route approaches | Choose central overlap or dedicated lanes |
| 6 | Runners after Wraiths | Retain a fast-target answer after a resistance check |
| 7 | Siege Beast across the observatory approach | Use Flame and concentrated fire |
| 8 | Full mixed reflection-themed wave | Stay focused on actual enemy silhouettes |
| 9 | The Mirror Warden | Defeat the observatory guardian before alignment completes |

**Audio and feedback:** Glass chimes, dry wind, distant metal, and short
reflected tones. Keep screen flashes restrained so projectile colors remain
distinct.

**Implementation notes:** Reflection decals and false silhouettes are art-only.
Actual illusions, cloning, or hidden enemy information are optional future
support and should not be prerequisites for the terrain.

### 9. The Tempest Coast

**Role and tone:** Exposed, dramatic, and urgent. The player is defending the
last lights of a coast while the sea answers with the dead.

**Visual language:** Black cliffs, slate-blue sea, gray storm sky, salt marsh
green, lighthouse gold, and red emergency pennants. Use lightning as a distant
background accent, not a gameplay obstruction.

**Surface and road set:** Wet dark soil and cliff grass; salt-stained stone
road; cliff-edge and sea-cave corner tiles; beacon spawn; lighthouse or cave
exit.

**Artifacts:** Lighthouses, signal fires, docks, sea caves, wrecked ships,
rope bridges, tide pools, gullies, salt-marsh reeds, and warning bells.
Lighthouse chains are landmarks and victory presentation unless a later level
explicitly models them as objectives.

**Route and placement identity:** Coast roads run beside cliffs, marsh routes
cut inland, and caves create readable alternate exits. Use two-route maps to
make lighthouse-side towers and inland towers compete for coverage.

**Enemy and boss direction:** Runners represent raiding crews, Wraiths are dead
 sailors, and Siege Beasts are ship-borne heavy units. The named boss is
**Admiral Drown**, a dead fleet commander represented initially by Boss with
Wraith and Siege Beast support.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts along the cliff road | Establish the coast's open sightlines |
| 2 | Runners from the marsh | Cover inland approaches |
| 3 | Two routes: cliff and marsh | Divide towers without losing overlap |
| 4 | Wraiths from a sea cave | Maintain physical damage coverage |
| 5 | Brutes on the cliff road | Hold the longer lane while supporting the marsh |
| 6 | Siege Beasts at the lighthouse | Use Flame against the heavy threat |
| 7 | Staggered cave and shore groups | Respond to route timing rather than only composition |
| 8 | Full storm procession | Keep both beacon approaches alive |
| 9 | Admiral Drown | Defend the lighthouse chain against the dead fleet |

**Audio and feedback:** Surf, bells, wind gusts, distant thunder, and a strong
beacon flare when a wave begins. Lightning should be short, infrequent, and
behind the battlefield.

**Implementation notes:** The coast can use current dual-route support. Tide
cycles, knockback, projectile deflection, and naval units are optional future
support, not baseline requirements.

### 10. The Moonvale

**Role and tone:** Quiet, sacred, and increasingly alarming. This is the pause
before the final ascent, where the player understands the scale of the seal.

**Visual language:** Silver grass, pale stone, moon blue, violet shadow, and
small warm hearth accents. Keep the battlefield calm enough for careful setup.

**Surface and road set:** Silver meadow tile; pale rune-stone road; geometric
observatory corners; star-glow spawn; moonwell or Crownline exit.

**Artifacts:** Observatory domes, star charts, standing stones, moonwells,
silver trees, brass instruments, broken lenses, constellation markers, and
quiet camp sites left by previous Wardens.

**Route and placement identity:** Routes are geometric and easy to trace, but
buildable positions are arranged so the player must prepare for both long and
short engagements. The challenge is compositional discipline, not surprise.

**Enemy and boss direction:** Wraiths become central, with Armored and Siege
Beast groups ensuring that physical, magic, and elemental damage all remain
relevant. The named boss is **The Starved Astronomer**, a rune-smith who has
turned the observatory toward the Hollow King's beacon. Use Boss with Wraith
support initially.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Calm Grunt route | Learn the final chapter's clean geometry |
| 2 | Wraith introduction in moonlight | Keep physical damage intentional |
| 3 | Armored units at an observatory bend | Rebuild magic coverage |
| 4 | Runners through a short lane | Prevent the quiet map from encouraging complacency |
| 5 | Wraith and Brute sequence | Balance resistance against sustained damage |
| 6 | Siege Beast approach | Use elemental pressure and long firing windows |
| 7 | Mixed route timing | Prepare both early and late defenses |
| 8 | Alignment pre-boss wave | Preserve enough gold and coverage for the final test |
| 9 | The Starved Astronomer | Hold the observatory while the last route is revealed |

**Audio and feedback:** Sparse wind, glass instruments, soft choral tones, and
a rising star-alignment sound at the end of each boss preparation wave. Keep
the moon glow below enemy and tower contrast.

**Implementation notes:** Constellation lines and alignment animations can be
presentation effects. Actual line-of-sight, time-of-day, or moon-phase rules
are optional future support.

### 11. The Crownspire and the First Gate

**Role and tone:** A final gathering of every road, ally, and lesson. The
terrain should feel conclusive without becoming visually chaotic.

**Visual language:** Central mountain stone, blue-white Crownline runes,
hearth gold, black roots, red banners, and a dark gate below the spire. Reuse
small visual motifs from earlier terrains so the finale feels earned.

**Surface and road set:** Crownstone base tile; reinforced road made from
every earlier stone tradition; monumental corners; allied-banner spawn; First
Gate exit. The final hearth must be a prominent landmark, not a buildable tile.

**Artifacts:** Crownspire terraces, the First Gate, eleven anchorstone motifs,
allied banners, broken siege engines, rescued village carts, forge braziers,
forest roots, frozen stones, glass lenses, lighthouse beacons, and the final
hearth.

**Route and placement identity:** Several authored roads converge toward the
gate. Early defenses test dedicated lanes; later defenses use central overlap
and route timing. The map should offer recovery positions so one imperfect
opening does not make the finale unwinnable.

**Enemy and boss direction:** All current enemy families return in a readable
sequence: Grunts and Runners establish tempo, Armored and Wraiths force damage
choices, Brutes and Siege Beasts create heavy pressure, and Boss groups mark
the final stages. The named boss is **The Hollow King**, represented by the
current Boss family in the first implementation. The story, audio, sprite,
and wave composition provide identity before unique boss mechanics exist.

| Defense | Design beat | Main decision |
| --- | --- | --- |
| 1 | Grunts on the outer road | Re-establish the converging route layout |
| 2 | Runners on a second approach | Protect early lanes while building central coverage |
| 3 | Armored and Wraith sequence | Maintain both physical and magic answers |
| 4 | Brute pressure on the central road | Spend on sustained damage without abandoning side lanes |
| 5 | Siege Beast procession | Use elemental damage and high-value firing positions |
| 6 | Mixed enemy groups across routes | Apply targeting and wave-order knowledge |
| 7 | First Boss escort wave | Test whether the whole defense has a clear priority |
| 8 | All-role pre-final wave | Give a final readable economy and placement check |
| 9 | The Hollow King at the First Gate | Bring every learned role together as the Crownline aligns |

**Audio and feedback:** Layered motifs from earlier terrains, a unified hearth
hum, fortress bells, and a restrained final alignment cue. Victory should focus
on the eleven flames and the people beneath the banner rather than only on the
boss's defeat.

**Implementation notes:** The first version can use one or more fixed routes,
current enemy families, ordinary wave groups, and the generic Boss definition.
The final map should remain readable at the existing 1280×720 render target.

## Asset and presentation direction

### Required terrain asset set

Each terrain should plan for the smallest complete set of authored visuals:

- One seamless 128×128 base surface tile.
- One road tile and one road-corner tile, with rotation-safe directional
  artwork.
- A distinct spawn treatment and exit treatment.
- Two to four decorative landmark families.
- One hearth or anchorstone landmark.
- Optional blocked-terrain pieces only when the map layout needs them.

The atlas currently uses a fixed 6×5 layout and the art guide requires strong
silhouettes, transparent entity padding, warm upper-left lighting, and detail
that survives at roughly 32–52 logical pixels. New terrain art should follow
those rules and be inspected at gameplay size.

### Readability rules

- Road direction must be visible at every straight, corner, spawn, and exit
  tile.
- Decorative color must not mimic buildable green, route brown, spawn blue, or
  exit red.
- Enemy silhouettes and health bars must remain distinct from the terrain.
- Fog, ash, snow, glass highlights, lightning, and moon glow stay behind the
  gameplay layer or use restrained opacity.
- A landmark may frame a decision, but must not hide a tower, route, enemy, or
  placement preview.
- Decorative artifacts are not gameplay objects unless the map data explicitly
  supports their behavior.

### Fallback behavior

Missing terrain art must fall back to the existing primitive rendering style:
flat but distinct surface colors, readable road connectors, and visible spawn
and exit markers. No terrain should become unplayable because an optional
decoration or boss illustration is unavailable.

## Enemy and boss policy

The existing enemy families are sufficient for the first pass of all eleven
terrains. A new enemy is justified only when the design can state:

1. Which player decision it creates.
2. Which existing tower or combination answers it.
3. How the player learns the answer before the threat becomes severe.

Bosses should first be differentiated through name, silhouette, entrance cue,
supporting wave groups, health/speed multipliers, leak cost, route position,
and terrain presentation. A boss-specific behavior is optional future support,
not an excuse to make an encounter unreadable or unavoidable.

## Implementation boundary

The document describes future content but does not require immediate changes to
the engine. The current production order should be:

1. Balance and polish the six existing maps.
2. Add terrain surface and decoration assets using the existing atlas rules.
3. Add new maps and waves using fixed orthogonal routes and current enemy and
   tower definitions.
4. Playtest each nine-defense terrain arc before adding another terrain.
5. Add a new enemy or terrain mechanic only when the current vocabulary cannot
   express a recurring, measurable design need.

No new currency, permanent progression, tower family, hidden-information rule,
or generic terrain framework is required by this design.

## Validation checklist

- All eleven terrains match the names and narrative order in `STORY.md`.
- Every terrain contains visual, surface, road, artifact, route, enemy, boss,
  audio, implementation, and nine-defense guidance.
- The campaign accounts for exactly 99 defenses.
- Grasslands, Forest Pass, Frozen Road, Ruined Outskirts, Ruined Market, and
  Ruined Keep remain identifiable within the complete campaign.
- Current tower, enemy, route, wave, asset, and fallback constraints are not
  contradicted.
- Proposed mechanics are marked optional when the current runtime does not
  support them.
- Terrain decoration improves identity without reducing route or placement
  readability.
- Each terrain changes a meaningful positioning, timing, economy, targeting,
  or matchup decision rather than only changing its palette.
