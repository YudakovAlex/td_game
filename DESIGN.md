# Rune Siege TD — Game Design Direction

## 1. Purpose and current direction

*Rune Siege TD* is a single-player, top-down fantasy tower-defense game for
PC. Its intended feel is an authored, old-school TD campaign: readable maps,
deliberate tower placement, recognizable enemy roles, and waves that reward
adaptation without requiring a permanent progression system.

The project is currently a playable six-level campaign slice. The immediate
design goal is to make that slice coherent, legible, and well balanced before
adding more systems or content. New features should support one of three
outcomes:

1. Players make clearer tower, upgrade, targeting, or economy decisions.
2. Designers can author and balance more varied levels efficiently.
3. The campaign gains a distinct visual and strategic identity.

Anything that does not support one of these outcomes should wait.

## 2. Design pillars

### Readable decisions

Players should understand the state of the battlefield quickly:

- which enemies are dangerous and why;
- which tower is selected and what it can do;
- whether a wave can be started or is already in progress;
- what the next wave asks the player to prepare for;
- why a placement, upgrade, or target choice is good or bad.

Readability takes priority over decorative effects, dense text, and elaborate
visual treatment. Fantasy character comes from palette, framing, silhouettes,
terrain decoration, and sound—not from making small labels difficult to read.

### Positioning and adaptation

The core skill is placing a limited set of towers around fixed routes, then
adjusting the build as enemy roles change. Maps should create meaningful
coverage and targeting decisions through bends, lanes, bottlenecks, and route
intersections while remaining easy to follow.

The game is not initially a maze-building game. Players should solve the
authored map rather than spend their attention maintaining path validity.

### Simple rules, layered interactions

The rules should remain small enough to learn in one level:

- gold pays for towers and upgrades;
- lives are lost when enemies reach an exit;
- towers attack automatically according to a targeting policy;
- damage types and a small number of status effects create matchups;
- waves escalate through composition, sequencing, and pacing.

Depth should come from combinations of these rules, not from a large catalog
of exceptions.

### Authored content with measurable balance

Every level, wave, tower, and enemy should have a clear purpose. Human
playtesting remains the final authority, but repeatable simulation and
versioned data should make it practical to compare balance changes and find
obvious failures early.

## 3. Product scope

### Current playable baseline

The current slice establishes the foundation that future design must preserve:

| Area | Current direction |
| --- | --- |
| Platform | Single-player PC |
| Presentation | 2D top-down, fixed-resolution render target in a resizable window |
| Maps | Six sequential, hand-authored levels with grid-based placement |
| Routes | Fixed paths, including a dual-route level; waves can contain up to three sequential enemy groups |
| Towers | Arrow, Cannon, Frost, and Flame |
| Tower progression | Three linear levels, with build, upgrade, sell, and targeting controls |
| Enemies | Grunt, Runner, Brute, Armored, Wraith, Siege Beast, and Boss |
| Waves | Hand-authored waves with up to three sequential enemy groups |
| Resources | Gold and lives during a run; score recorded on completion |
| Persistence | Best score and best remaining lives per completed level |
| Feedback | Sprite atlas with safe primitive fallbacks, restrained effects, and generated action/combat cues |
| Content format | Versioned JSON for tower, enemy, map, and wave definitions |

The baseline is a product direction, not a promise that every current value is
final. Balance values remain provisional until the campaign has been played
through at supported window sizes and on a normal desktop runtime.

### Near-term success criterion

The next release-quality milestone is a polished six-level run in which:

- each level is visually identifiable;
- the HUD is readable and never overlaps or hides important state;
- all current enemy types are visible and understandable;
- wave pacing, gold income, tower costs, and matchups support active decisions;
- the result screen and saved records make replay worthwhile;
- no new tower family or meta-progression is required to enjoy the campaign.

## 4. Player experience

### Run loop

1. The player enters a level with a fixed amount of gold and lives.
2. The map, buildable tiles, route(s), exit(s), and next-wave information are visible.
3. The player selects and places towers on buildable tiles.
4. The player starts a wave or waits for the short transition countdown.
5. Enemies spawn in authored groups and travel toward an exit.
6. Towers automatically fire, apply their limited effects, and earn gold when enemies are defeated.
7. The player builds, upgrades, sells, changes targeting, and prepares for the next wave while the battle continues.
8. The level ends in victory after the final wave is cleared or in defeat when lives reach zero.
9. The result screen reports the run and updates the best record when appropriate.

The player should be able to make decisions during combat, but should not be
punished by hidden timers or unclear controls. Starting a wave is an explicit
action when available; active-wave progress is status, not a disabled-looking
button.

### Win, loss, and replay

- **Victory:** all authored waves are cleared.
- **Defeat:** lives reach zero.
- **Replay value:** improve lives, score, economy, and build efficiency; later
  replay levels on higher complexity settings when those settings exist.
- **Progression:** completing a level unlocks the next level. Permanent tower
  power is not part of the initial campaign balance model.

The score should reward survival and efficient play without making the HUD
harder to read. The existing deterministic score and best-result records are
the foundation; score formulas should remain stable while content is being
balanced.

## 5. Map and campaign design

### Map rules

The initial map model is a fixed route on a 24×18 logical grid:

- path tiles are never buildable;
- buildable tiles are deliberately placed to create coverage choices;
- spawn and exit tiles are visually distinct;
- blocked terrain and decoration provide theme without obscuring routes or
  placement;
- route direction must be visible in the road artwork at every segment and
  corner;
- multiple routes are allowed when they create a readable allocation problem,
  not merely more enemies.

Loops, bottlenecks, turns, and route splits are valuable when they change
which tower locations or targeting modes are effective. They should be
introduced with clear visual language and sufficient buildable space. Random
path generation is not a goal.

### Campaign progression

The six current maps form the first campaign arc:

| Level | Identity and teaching role |
| --- | --- |
| Grasslands | Establishes the basic loop, economy, and tower roles on a forgiving route. |
| Forest Pass | Introduces a dual-route coverage problem. |
| Frozen Road | Increases the importance of fast-enemy control and readable spacing. |
| Ruined Outskirts | Introduces the Ruined City visual identity and more demanding mixed threats. |
| Ruined Market | Extends the ruined-city palette and asks for stronger multi-role coverage. |
| Ruined Keep | Acts as the current campaign capstone with the densest late-wave tests and a final boss. |

Each level should have a strategic identity in addition to a new palette. A
new level is not justified by more waves alone; it should alter route geometry,
available preparation space, enemy timing, or the value of a tower role.

### Long-term campaign target

The eventual content target is 99 levels arranged as 11 terrain sets of nine
levels. This is a planning frame, not the next production milestone. Before
full production, each terrain set should define:

- a distinct palette, road surface, lighting treatment, and decoration set;
- a strategic identity and progression role;
- a nine-level arc with introduction, combination, challenge, and capstone
  beats;
- reusable data and art conventions that do not duplicate game logic.

The six-level campaign must first establish the content and balance standards
that make this expansion sustainable.

## 6. Towers

The current four tower families are the game's initial vocabulary. They should
be made strategically distinct before more families are added.

| Tower | Primary role | Strength | Limitation |
| --- | --- | --- | --- |
| Arrow | Reliable single-target damage | Consistent damage and flexible placement | Does not solve dense groups efficiently |
| Cannon | Ground splash damage | Punishes clustered enemies | Poor against spread or fast threats |
| Frost | Control and magic damage | Creates time for other towers to work | Low direct damage |
| Flame | Elemental splash and burn | Sustained pressure on groups and heavy targets | Damage profile is less efficient against resistant matchups |

All towers currently have three linear levels. This is the correct complexity
for the current campaign: upgrades should improve a tower's stated role rather
than introduce four new rules at once. Branching upgrades and additional tower
families are later options, not requirements for the six-level release.

### Tower interaction rules

- A tower has a clear role visible in its card and selected-tower panel.
- Targeting modes are explicit and readable. The current modes are First,
  Weakest, and Strongest; additional modes need a demonstrated level-design
  use case.
- Slow effects use strongest-slow replacement and refresh duration rather than
  unlimited stacking. Bosses can have reduced control effectiveness.
- Burn has one refreshable instance per enemy in the current rules.
- Unaffordable, unavailable, selected, hovered, and active-action states must
  remain visually distinct.
- Upgrade and sell actions show their names as well as keyboard shortcuts.

New tower families should be added only when the existing four cannot express
a recurring strategic need in authored waves. Support, chain-lightning,
poison, flying-only, and other ideas remain a candidate pool rather than a
committed feature list.

## 7. Enemies and waves

### Enemy roles

Enemy variety should be communicated through role, movement, silhouette,
resistance, and reward—not through opaque special-case rules.

| Enemy | Role in the current campaign |
| --- | --- |
| Grunt | Baseline unit used to teach the route and economy. |
| Runner | Fast pressure that tests coverage and targeting. |
| Brute | Durable, slower unit that tests sustained damage. |
| Armored | Physical-resistant unit that creates a damage-type matchup. |
| Wraith | Magic-resistant, physically vulnerable unit with a distinct threat profile. |
| Siege Beast | Heavy unit with its own resistance profile and high leak cost. |
| Boss | High-value milestone threat that tests the level's complete toolkit. |

The Wraith and Siege Beast must remain visibly distinct at normal gameplay
scale, including in compiled builds. If artwork is missing, primitive fallback
rendering must preserve their identity and never make them invisible.

Additional enemies such as flyers, summoners, splitters, or regenerators are
appropriate only after the current roles are balanced. Each new enemy must
answer three questions before implementation:

1. What player decision does it create?
2. Which existing tower or combination responds to it?
3. How is its behavior communicated before the player is expected to counter it?

### Wave structure

Waves are authored as ordered groups. The current format supports up to three
sequential groups, which is enough to create combinations such as a durable
opening followed by runners or a swarm after a heavy unit. Keep group order
meaningful: timing and attention are part of the challenge.

Wave design should follow this rhythm:

- introduce a role in a low-pressure wave;
- repeat it so the player can learn its counter;
- combine it with an existing role;
- use a boss or capstone wave to test the level's complete demands.

Boss waves should be memorable but recoverable. A boss may be durable, costly
to leak, or paired with supporting groups, but should not invalidate a run
through an unexplained resistance or an unavoidable burst.

The wave preview should show the next wave's groups in a bounded, unclipped
container. During an active wave, the UI should show current-wave progress and
status separately from the next-wave preview.

## 8. Economy, difficulty, and balance

### Economy

Gold is earned primarily from defeating enemies and from the existing
between-wave reward. It is spent on construction and upgrades; selling returns
70% of invested gold in the current baseline.

The economy should create recurring choices:

- build another role now or upgrade an existing tower;
- invest in the next wave or preserve flexibility;
- sell and reposition at a known loss;
- favor a safe, efficient setup or a higher-scoring low-leak run.

Do not add mana, interest, permanent currencies, or tower unlock currencies
until the gold-and-lives economy has been balanced across all six levels.

### Complexity levels

The next major systems feature is difficulty/complexity selection. Tiers must
change decision-making, not only inflate enemy health. Each tier should have
documented, independently balanceable effects such as:

- altered enemy composition or pacing;
- tighter starting resources or lives;
- less forgiving sell refunds;
- stronger resistance combinations;
- additional route or wave constraints.

Normal should remain the reference balance. Easy may provide more room to learn;
Hard should demand tighter placement and economy. A tier must be understandable
before play and should not hide information from the player.

### Balance targets

Balance is judged across a full level, not a single wave. A healthy level
should:

- make the starting tower choice meaningful without requiring a single correct
  opening;
- introduce each enemy before relying on it as a counter check;
- provide enough gold to recover from a reasonable mistake;
- reward upgrading without making new placement irrelevant;
- create different strong positions on maps with different route shapes;
- end with pressure that tests preparation rather than surprise.

The automated balance simulator is a support tool for this work. It should run
headless, test repeatable tower plans against authored levels, and report leaks,
lives, gold, tower performance, and a difficulty range. Its output identifies
questions for human playtesting; it does not define fun or replace playtests.

## 9. Interface and feedback direction

The HUD is part of the game design because players make decisions from it.
The side panel must reserve non-overlapping space for:

1. level title and resource summary;
2. current-wave number and remaining-wave information;
3. the Menu button;
4. tower cards and their costs;
5. wave action or active-wave status;
6. speed controls;
7. selected-tower information and targeting;
8. the next-wave preview.

Specific requirements from the current polish cycle:

- small body text and labels remain legible at supported window sizes;
- current-wave progress is not duplicated as a misleading action button;
- `Upgrade` and `Sell` are written out, with `U` and `S` as secondary hints;
- selected-tower details and next-wave preview are visibly separate sections;
- a three-group next-wave preview fits without clipping;
- the selected tower card has a strong state distinct from hover and
  unaffordable states;
- victory and defeat screens show the run's important outcomes without
  requiring the player to infer them from the battlefield.

The game uses a fixed logical canvas with letterboxing and high-DPI support.
Layouts should be tested at the supported window sizes rather than assuming a
single desktop resolution.

## 10. Visual and audio direction

### Visual identity

Use a restrained, painted low-resolution fantasy style with strong silhouettes
and readable tile values. Terrain sets should be distinct at a glance:

- Grasslands: open, welcoming, and high-contrast;
- Forest Pass: enclosed, green, and route-focused;
- Frozen Road: cool, sparse, and speed-readable;
- Ruined City: broken stone, muted earth, rubble, walls, dead plants, and
  architectural remnants;
- later terrain sets: each receives its own palette, road treatment, lighting,
  and limited decoration vocabulary.

Decorations occupy selected squares and frame the map; they must not obscure
paths, spawn/exit markers, buildable tiles, tower silhouettes, or enemy health
bars. Road artwork follows route direction and makes corners explicit.

Effects should communicate impact, slow, burn, boss presence, and leaks while
leaving enemies and routes visible. Static sprites are acceptable when motion,
rotation, tint, recoil, and procedural effects provide enough feedback.

### Audio

Short generated or authored cues should cover placement, upgrade, sell, wave
start, boss arrival, projectile impact, leak, victory, defeat, and menu actions.
Music and settings are later polish. Audio must fail safely when unavailable
and must never block a playable run.

## 11. Content and technical direction

The implementation should remain small, explicit, and data-oriented in Odin.
The existing split is appropriate:

| System | Responsibility |
| --- | --- |
| Game state | Playing, paused, victory, defeat, input, and orchestration |
| Map | Tiles, routes, placement validation, road and terrain rendering |
| Waves | Level loading, wave state, group sequencing, spawning, and reset |
| Towers | Placement, upgrade, targeting, firing, and rendering |
| Enemies | Movement, health, damage multipliers, slow, burn, and rendering |
| Projectiles/effects | Homing, splash hits, impacts, and bounded transient feedback |
| UI | HUD, menus, wave preview, selected tower, and result screens |
| Content | Versioned JSON parsing and validation |
| Save | Per-level completed records and best results |

JSON is the source of truth for authored towers, enemies, maps, and waves.
Schemas should remain simple and validated at load time. New content should
not require code changes when it can be represented by existing definitions.
The level constructor will eventually build and validate these same data
structures rather than creating a parallel format.

### Level constructor

The level constructor is a designer tool before it is a user-content feature.
It should support editing and validation for:

- terrain and buildable tiles;
- routes, spawns, and exits;
- decorations;
- wave groups and enemy parameters;
- level metadata and starting resources.

A designer must be able to create, validate, save, reopen, and playtest a
complete level without manually editing source files. User-generated levels
come later, after the format and validation rules are stable.

### AI-adversary mode

An AI-adversary mode is an optional long-term mode, not part of the campaign
foundation. It should observe tower families, placement patterns, upgrades,
and leaks, then choose or compose later threats within authored limits. It must
show enough of its pressure pattern to remain fair, avoid hard counters that
make recovery impossible, and produce repeatable results for balancing.

## 12. Roadmap and sequencing

The backlog is the priority order for design and implementation:

### Phase 1 — Campaign readability and polish

1. Fix the wave header/Menu collision and separate progress from wave action.
2. Improve small-text readability and clarify selected-tower actions.
3. Separate selected-tower and next-wave sections, including three-group
   preview space.
4. Strengthen tower-card selection feedback.
5. Make Wraith and Siege Beast visuals visible and safe in compiled builds.
6. Make road artwork directional.
7. Give Ruined Outskirts a distinct ruined-city palette and decoration set.

### Phase 2 — Balance and authored variety

8. Playtest and rebalance the six-level campaign, especially the Ruined City
   levels and Flame/Armored and Wraith/Siege Beast matchups.
9. Define and implement complexity tiers with documented effects.
10. Add more convoluted and distinctive route layouts where they create fair
    placement decisions.
11. Keep JSON schemas stable while balancing and add focused validation where
    content mistakes are otherwise hard to see.

### Phase 3 — Tools for sustainable expansion

12. Build the headless level-balance simulator and compare its output against
    human playtests.
13. Create the designer-first level constructor using the validated content
    format.
14. Plan the 99-level, 11-terrain campaign structure and approve the visual
    and progression role of every terrain set before production.

### Phase 4 — Optional long-term modes

15. Add the AI-adversary mode only after authored waves, difficulty tiers, and
    balance tooling provide a stable reference.
16. Expand tower and enemy vocabulary only when a content plan demonstrates a
    real strategic gap.

## 13. Guardrails and non-goals

The following are deliberately deferred:

- maze-building and dynamic path validation;
- permanent RPG-style tower power;
- a large tower roster before the current four are balanced;
- hidden damage categories or uncommunicated enemy immunities;
- procedural maps as a substitute for authored level design;
- music/settings before the campaign and HUD are polished;
- user-generated content before the level format and constructor are reliable;
- AI waves before the authored campaign can serve as a fair baseline.

The main risks are content scale, balance complexity, and visual/UI clutter.
The mitigations are a campaign-first release, a small ruleset, readable
feedback, stable data schemas, bounded runtime collections, and a simulator
used alongside—not instead of—human playtesting.

## 14. Success criteria for the next major release

The next major release is successful when a new player can complete the six
current levels with no external explanation of the HUD, can identify why a
tower or enemy matters, and can replay a level to improve the result. A
designer should be able to explain each level's route identity, enemy
introductions, tower demands, and balance target in a short content note.

Only after those conditions are met should the project spend significant scope
on the 99-level campaign, a level constructor, or an AI-adversary mode.
