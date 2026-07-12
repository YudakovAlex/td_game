# Rune Siege TD — Backlog

Visual and content issues collected from playtesting. Items are ordered by
priority within the current polish cycle.

## Side-menu review — 2026-07-11

The current side-menu pass resolves the entries marked complete below, gives
wave status its own non-action treatment, labels the selected-tower actions,
and separates the selected-tower and next-wave sections. The remaining
unchecked issues should be carried into the next polish pass.

The checked entries describe code-level work that has been completed. The
unchecked upgrade-label and text-readability entries still require interactive
visual verification at the supported render sizes before they can be closed.

### [x] Start with a window sized to the full game-and-panel area

**Problem:** The initial window leaves black areas at the sides because its
starting aspect ratio does not match the logical game canvas, including the
side panel.

**Work:** Set the startup window dimensions to the full logical canvas aspect
ratio, including the map and side panel. Preserve the existing resize,
high-DPI, and letterboxing behavior for later window sizes.

**Done when:** A newly launched game fills the initial window with the full
game-and-panel layout and does not show avoidable side bars, while supported
non-matching window sizes remain safely letterboxed.

### [ ] Keep upgrade-button text inside its bounds — TO IGNORE / NOT REQUIRED

**Status:** To ignore / not required. Do not schedule this item.

**Problem:** The `Upgrade` label and price run beyond the button boundary at
the current side-panel size.

**Work:** Fit the action label within the existing button, using a shorter
layout or smaller readable text as needed. Keep the full action meaning and
price visible.

**Done when:** The complete upgrade label is contained within the button with
consistent padding and no overlap or clipping.

### [x] Center the Speed button labels

**Problem:** The `-` and `+` labels in the Speed controls are not visually
centered within their buttons.

**Work:** Center each label horizontally and vertically using the button
rectangle rather than fixed text offsets.

**Done when:** Both Speed labels remain centered at the supported render sizes.

### [x] Make disabled states explain why an action is unavailable

**Problem:** Unaffordable tower cards and the unavailable `Upgrade` action are
shown mainly through dimmed colors. A player cannot immediately tell whether
an action is unavailable because of insufficient gold, a maximum tower level,
or another state.

**Work:** Keep the distinct disabled styling, but add concise supporting
feedback such as `Need $20 more` or `MAX LEVEL` where it fits. Preserve the
normal price and action label so the economy remains scannable.

**Done when:** A player can identify the reason an unavailable tower or
selected-tower action cannot be used without guessing or trying the click.

### [x] Improve countdown and active-wave wording

**Problem:** `Start Wave 2s` can be read as an action with a price or duration,
and the current waiting/active state is not equally explicit in every state.
The wave number and remaining-wave count are clear, but active enemy progress
is only available in the lower status area.

**Work:** Use explicit wording such as `Starting in 2s` for the automatic
countdown and define a compact, consistent status pattern for waiting,
spawning, and clearing. Include current enemies remaining when that value is
useful, without duplicating the next-wave preview.

**Done when:** Players can distinguish an available action, an automatic
countdown, and active-wave progress at a glance.

### [ ] Raise contrast and minimum size for side-panel body text — TO IGNORE / NOT REQUIRED

**Status:** To ignore / not required. Do not schedule this item.

**Problem:** The 14–15 px labels, disabled prices, wave-preview rows, and
secondary tower statistics remain difficult to read against the dark panel,
especially with the decorative display font. The screenshot also shows a
large contrast gap between prominent headings and supporting information.

**Work:** Establish a minimum readable body size and contrast for panel text.
Use the decorative treatment for headings and retain the fantasy identity in
colors, borders, and larger labels. Check the result at the smallest
supported window size and for unaffordable states.

**Done when:** Costs, stats, status text, and wave-preview rows are readable
without enlarging the window or relying on memorized shortcuts.

### [ ] Reduce side-panel density and improve scan order — TO IGNORE / NOT REQUIRED

**Status:** To ignore / not required. Do not schedule this item.

**Problem:** The panel contains level context, resources, wave state, four
tower cards, speed controls, selected-tower details, and a next-wave preview
in one narrow vertical column. The current grouping is better, but the lower
sections still compete for attention and leave little room for longer role or
status text.

**Work:** Prioritize the order of information during preparation versus active
combat, add a small amount of breathing room where possible, and keep the
selected tower's action row and the next-wave preview visually subordinate to
the current decision. Do not hide essential state behind a new interaction.

**Done when:** A player can locate resources, the next available action, the
selected tower's key decision, and the next wave in that order within a quick
scan.

### [ ] Balance right-panel spacing and usable width — TO IGNORE / NOT REQUIRED

**Status:** To ignore / not required. Do not schedule this item.

**Problem:** The right panel does not distribute its contents evenly. In the
current layout, the four tower cards form a relatively narrow centered stack
with substantial unused space beside them, while the selected-tower and
next-wave sections use a different width and leave less breathing room for
their text. The vertical gaps also change noticeably between the header, tower
cards, speed controls, and lower information sections, making the panel feel
top-heavy in places and cramped in others.

**Work:** Review the panel as one layout rather than tuning each section in
isolation. Either spread the existing sections and their internal content more
evenly across the available panel area, or reduce the panel width to match the
actual content. Keep consistent horizontal margins, section widths, and
vertical spacing, while reserving enough room for the longest supported labels,
selected-tower stats, and next-wave preview.

**Done when:** The panel has a consistent visual rhythm from top to bottom,
its sections align to a clear content width, and there is no conspicuous unused
area beside the tower cards or crowding in the lower sections. The full layout
still fits without clipping or overlap at every supported render size.

### [ ] Add direct feedback for side-menu controls — TO IGNORE / NOT REQUIRED

**Status:** To ignore / not required. Do not schedule this item.

**Problem:** Mouse hover is available, but important controls have limited
feedback for focus, keyboard navigation, or the reason a click had no effect.
This is most noticeable on disabled tower cards, speed limits, and selected
tower actions.

**Work:** Standardize hover, selected, disabled, and keyboard-focus states;
where a control is disabled, pair the visual state with the reason already
logged above. Keep the current mouse and keyboard shortcuts unchanged.

**Done when:** Every side-menu control has a visibly distinct state for
available, hovered, selected, disabled, and focused interaction where
applicable.

## High priority

### [x] Make road sprites follow road direction

**Problem:** Road sprites are always vertical, regardless of the route's
direction.

**Work:** Add or select horizontal, vertical, and turn-aware road artwork (or
rotate a suitable sprite at render time) based on each route segment.

**Done when:** Every road segment visually aligns with the route, including
horizontal sections, vertical sections, and corners, without changing enemy
movement or map logic.

**Status:** Route connectivity is stored on map tiles; straight roads rotate
the existing path asset and corners use the atlas turn asset.

### [x] Make Wraith and Siege Beast sprites visible in compiled builds

**Problem:** Wraith and Siege Beast sprites are missing or not visible in the
compiled game.

**Work:** Verify their asset IDs, atlas regions, lookup paths, draw scale, and
fallback rendering in a compiled build.

**Done when:** Both enemy types have distinct, clearly visible in-game visuals
at normal gameplay scale, and still render safely when atlas artwork is
unavailable.

**Status:** Dedicated atlas cells and JSON asset mappings are present; the
existing primitive color fallback remains active when the texture is unavailable.

### [ ] Improve readability of small text

**Problem:** Smaller text is difficult to read. The current special style is
visually interesting but not suitable at small sizes.

**Work:** Choose a more legible display/body text treatment, then update the
small side-panel labels, tower roles and stats, wave previews, buttons, and
result-screen details. Preserve the fantasy feel through color, framing, or
larger headings rather than sacrificing letter clarity.

**Done when:** Small text remains readable during normal play and at supported
window sizes, with no clipped or ambiguous labels.

### [x] Fix the wave header and Menu collision

**Problem:** The Menu button overlaps the wave number and secondary wave-status
text in the side panel.

**Work:** Give the level title, resource summary, wave summary, and Menu button
non-overlapping layout space. Keep the layout within the existing panel width.

**Done when:** The full current-wave label, remaining-wave information, and
Menu button are visible simultaneously at every supported window size.

### [x] Separate wave progress from wave action status

**Problem:** The header reports active-wave progress while the large
`Enemies: N left` control repeats that information. During combat, the control
looks like a disabled Start Wave button even though it is not actionable.

**Work:** Define one clear wave-progress display and one clear wave action or
status display. Use button styling only when starting a wave is possible; use a
non-interactive progress/status treatment while a wave is spawning or clearing.

**Done when:** Players can immediately tell the current wave, enemy progress,
and whether an action is available, without duplicate status text.

### [x] Clarify selected-tower actions

**Problem:** The selected-tower controls show `U` and `S` with prices, which
requires players to already know that they mean Upgrade and Sell.

**Work:** Label the actions with their names and retain the keyboard shortcuts
as secondary text. Make unaffordable and unavailable actions visibly distinct.

**Done when:** A player can understand both actions without consulting the
controls reference, and their availability is obvious before clicking.

### [x] Organize selected-tower and next-wave sections

**Problem:** Selected-tower details, the targeting control, and the next-wave
preview are packed together. The target control nearly touches the next-wave
heading, and the preview has no clear visual container.

**Work:** Add clear spacing and section grouping. Reserve enough vertical space
for the maximum supported next-wave group count, including enemy icons and
labels, without hiding or overlapping selected-tower information.

**Done when:** The selected-tower section and upcoming-wave preview read as
separate sections, and a three-group preview fits without clipping at supported
window sizes.

### [x] Strengthen tower-card selection feedback

**Problem:** The four build cards have similar visual treatment, so the active
tower choice is easy to miss.

**Work:** Add a stronger selected state that remains distinct from hover,
unaffordable, and disabled states while preserving the tower icon and cost.

**Done when:** The active build choice is immediately identifiable and all card
states remain distinguishable.

## Medium priority

### [x] Distinguish Ruined Outskirts from Forest Pass

**Problem:** Ruined Outskirts currently looks too similar to Forest Pass.

**Work:** Give Ruined Outskirts a distinct terrain palette and road treatment.
Add a restrained set of ruined-city elements, such as building remnants,
rubble, walls, dead plants, or other map decorations that occupy selected
squares without obscuring routes or buildable tiles.

**Done when:** The level is identifiable as Ruined Outskirts at a glance, its
road design is visibly different from Forest Pass, and decorations do not
reduce path or tower-placement readability.

**Status:** Ruined Outskirts now uses a darker desaturated palette, a darker
route treatment, and deterministic rubble/wall details on buildable tiles.

## Testing and tooling

### [ ] Add a tester-mode build

**Problem:** Testing a specific level or tower setup currently requires
progressing through the campaign and obeying the normal starting-gold and
tower-cost rules.

**Work:** Add a compile-time tester mode that lets a tester select any level
directly and place or upgrade any number of towers without gold restrictions.
Keep the mode out of normal campaign builds, and make its active state clear
when launching the game so test results are not mistaken for normal balance
results.

**Done when:** A tester can launch the tester build, choose any available
level, freely construct and upgrade towers, and exercise waves without
changing normal campaign rules or saved player results.

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

1. Start with a window sized to the full game-and-panel aspect ratio.
2. Center Speed button labels.
3. Clarify countdown and active-wave wording.
4. Fix the missing Wraith and Siege Beast visuals.
5. Make road artwork directional.
6. Redesign Ruined Outskirts terrain and decorations.

The visual items in this sequence are now implemented; the remaining work is
interactive verification at the supported render sizes.

Long-term systems should follow campaign polish and use the simulator and level
constructor to support expansion:

8. Add a compile-time tester-mode build.
9. Define difficulty and complexity tiers.
10. Design more varied route layouts.
11. Build the level-balance simulator.
12. Create the level constructor.
13. Plan the 99-level, 11-terrain campaign structure.
14. Add the AI-adversary mode.
