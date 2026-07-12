# Rune Siege TD — Backlog

Visual and content issues collected from playtesting. Items are ordered by
priority within the current polish cycle.

## High priority

### [ ] Make road sprites follow road direction

**Problem:** Road sprites are always vertical, regardless of the route's
direction.

**Work:** Add or select horizontal, vertical, and turn-aware road artwork (or
rotate a suitable sprite at render time) based on each route segment.

**Done when:** Every road segment visually aligns with the route, including
horizontal sections, vertical sections, and corners, without changing enemy
movement or map logic.

### [ ] Make Wraith and Siege Beast sprites visible in compiled builds

**Problem:** Wraith and Siege Beast sprites are missing or not visible in the
compiled game.

**Work:** Verify their asset IDs, atlas regions, lookup paths, draw scale, and
fallback rendering in a compiled build.

**Done when:** Both enemy types have distinct, clearly visible in-game visuals
at normal gameplay scale, and still render safely when atlas artwork is
unavailable.

### [ ] Improve readability of small text

**Problem:** Smaller text is difficult to read. The current special style is
visually interesting but not suitable at small sizes.

**Work:** Choose a more legible display/body text treatment, then update the
small side-panel labels, tower roles and stats, wave previews, buttons, and
result-screen details. Preserve the fantasy feel through color, framing, or
larger headings rather than sacrificing letter clarity.

**Done when:** Small text remains readable during normal play and at supported
window sizes, with no clipped or ambiguous labels.

### [ ] Fix the wave header and Menu collision

**Problem:** The Menu button overlaps the wave number and secondary wave-status
text in the side panel.

**Work:** Give the level title, resource summary, wave summary, and Menu button
non-overlapping layout space. Keep the layout within the existing panel width.

**Done when:** The full current-wave label, remaining-wave information, and
Menu button are visible simultaneously at every supported window size.

### [ ] Separate wave progress from wave action status

**Problem:** The header reports active-wave progress while the large
`Enemies: N left` control repeats that information. During combat, the control
looks like a disabled Start Wave button even though it is not actionable.

**Work:** Define one clear wave-progress display and one clear wave action or
status display. Use button styling only when starting a wave is possible; use a
non-interactive progress/status treatment while a wave is spawning or clearing.

**Done when:** Players can immediately tell the current wave, enemy progress,
and whether an action is available, without duplicate status text.

### [ ] Clarify selected-tower actions

**Problem:** The selected-tower controls show `U` and `S` with prices, which
requires players to already know that they mean Upgrade and Sell.

**Work:** Label the actions with their names and retain the keyboard shortcuts
as secondary text. Make unaffordable and unavailable actions visibly distinct.

**Done when:** A player can understand both actions without consulting the
controls reference, and their availability is obvious before clicking.

### [ ] Organize selected-tower and next-wave sections

**Problem:** Selected-tower details, the targeting control, and the next-wave
preview are packed together. The target control nearly touches the next-wave
heading, and the preview has no clear visual container.

**Work:** Add clear spacing and section grouping. Reserve enough vertical space
for the maximum supported next-wave group count, including enemy icons and
labels, without hiding or overlapping selected-tower information.

**Done when:** The selected-tower section and upcoming-wave preview read as
separate sections, and a three-group preview fits without clipping at supported
window sizes.

### [ ] Strengthen tower-card selection feedback

**Problem:** The four build cards have similar visual treatment, so the active
tower choice is easy to miss.

**Work:** Add a stronger selected state that remains distinct from hover,
unaffordable, and disabled states while preserving the tower icon and cost.

**Done when:** The active build choice is immediately identifiable and all card
states remain distinguishable.

## Medium priority

### [ ] Distinguish Ruined Outskirts from Forest Pass

**Problem:** Ruined Outskirts currently looks too similar to Forest Pass.

**Work:** Give Ruined Outskirts a distinct terrain palette and road treatment.
Add a restrained set of ruined-city elements, such as building remnants,
rubble, walls, dead plants, or other map decorations that occupy selected
squares without obscuring routes or buildable tiles.

**Done when:** The level is identifiable as Ruined Outskirts at a glance, its
road design is visibly different from Forest Pass, and decorations do not
reduce path or tower-placement readability.

## Long-term features

### [ ] Increase campaign difficulty and introduce complexity levels

**Problem:** The current campaign is easy to complete without much planning or
adaptation.

**Work:** Rebalance enemy waves, tower economy, and level constraints. Define
clear complexity or difficulty tiers that increase meaningful decision-making
without relying only on larger enemy health pools.

**Done when:** The default campaign requires active tower placement and upgrade
decisions, and any additional difficulty tiers have distinct, documented
effects and can be balanced independently.

### [ ] Add more convoluted and distinctive path layouts

**Problem:** Some routes are too straight or mechanically simple to create
interesting placement decisions.

**Work:** Design routes with more twists, turns, loops, bottlenecks, and unusual
shapes where they fit the level theme. Keep each route readable and preserve
valid pathing and reasonable tower-placement space.

**Done when:** Appropriate levels contain visibly varied route shapes that
create different tower coverage and targeting decisions without feeling
random or unfair.

### [ ] Build an automated level-balance simulator

**Problem:** Manual playtesting alone is too slow for estimating level
difficulty across many tower and wave combinations.

**Work:** Create a simulation tool that can generate or test tower-build plans,
run waves without rendering, record leaks, gold, lives, and tower performance,
and report an estimated difficulty range for a level. Use it to compare
balance changes rather than treating its output as a replacement for human
playtesting.

**Done when:** A level designer can run repeatable simulations against a level
and receive enough summary data to identify overtuned or undertuned waves and
tower strategies.

### [ ] Add an AI-adversary game mode

**Problem:** The current game only tests the player's static preparation
against authored waves.

**Work:** Add a mode where an adversary observes the player's tower families,
placement patterns, and upgrades, then selects or composes subsequent enemy
waves that exploit likely weaknesses. Establish limits so the AI remains
challenging, understandable, and capable of producing recoverable games.

**Done when:** The AI reacts to meaningful player choices, communicates enough
of its threat pattern to feel fair, and produces repeatable results suitable
for balancing and playtesting.

### [ ] Create a level constructor

**Problem:** Level creation currently requires editing project data directly,
which limits access for designers and potential user-created content.

**Work:** Provide an editor for terrain, buildable tiles, routes, spawns,
exits, decorations, waves, and level metadata. Start with designer tooling and
define a safe format for saving and loading created levels before exposing
user-generated levels.

**Done when:** A designer can create, validate, save, reopen, and playtest a
complete level without manually editing source files.

### [ ] Expand the campaign to 99 levels across 11 terrain sets

**Problem:** The long-term campaign target needs a clear structure for content
and visual progression.

**Work:** Plan 99 levels as 11 groups of 9 levels. Give each terrain set a
distinct tiling design, lighting, road surface, and environmental artifacts
such as buildings, plants, rocks, or ruins. Define a reusable content structure
so the campaign can grow without duplicating level logic.

**Done when:** The campaign has an approved 11-terrain visual/content plan,
each terrain set has a distinct identity, and all 99 level slots have defined
themes and progression roles before full production begins.

## Suggested sequence

1. Fix the wave header/Menu collision and clarify wave status.
2. Improve side-panel text readability and selected-tower action labels.
3. Separate the selected-tower and next-wave sections, including overflow space.
4. Strengthen tower-card selection feedback.
5. Fix the missing Wraith and Siege Beast visuals.
6. Make road artwork directional.
7. Redesign Ruined Outskirts terrain and decorations.

Long-term systems should follow campaign polish and use the simulator and level
constructor to support expansion:

8. Define difficulty and complexity tiers.
9. Design more varied route layouts.
10. Build the level-balance simulator.
11. Create the level constructor.
12. Plan the 99-level, 11-terrain campaign structure.
13. Add the AI-adversary mode.
