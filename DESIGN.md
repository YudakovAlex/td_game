# Game Design Plan: Odin PC Tower Defense

## 1. Core Concept

**Working title:** *Rune Siege TD*

A traditional PC tower defense inspired by old-school Warcraft 3 custom TD maps:

* Top-down fantasy battlefield
* Grid-based building
* Creeps follow paths toward exits
* Player builds and upgrades towers between and during waves
* 10 levels/maps
* 30–50 waves per level
* 5–10 tower families with branching upgrades
* Strong emphasis on readable mechanics, satisfying tower synergies, and replayable difficulty

Primary target: **single-player PC**, built in **Odin**, likely with a lightweight renderer/game framework such as Raylib, SDL2, or custom OpenGL later.

---

# 2. Design Pillars

## 2.1 Old-School TD Feel

The game should feel closer to Warcraft 3 custom TD maps than modern mobile TD:

* Clear waves
* Clear creep types
* Towers placed on a grid
* Strong upgrade paths
* Gold economy
* Lives/base health
* Simple rules, deep optimization
* Minimal meta-progression initially

## 2.2 Readability Over Visual Complexity

Every tower, projectile, and creep should be readable at a glance.

Good:

* Distinct projectile colors
* Clear attack ranges
* Obvious slow/stun/burn effects
* Simple creep silhouettes

Avoid:

* Particle clutter
* Excessive screen shake
* Ambiguous damage types

## 2.3 Data-Driven Balancing

Tower stats, wave data, level layouts, enemy stats, and upgrades should eventually live in external data files.

Suggested format:

```text
/data
  towers.json
  enemies.json
  waves/
    level_01.json
    level_02.json
  maps/
    level_01.map.json
```

Even if the first prototype hardcodes data, the design should assume data-driven content.

---

# 3. Core Gameplay Loop

## Per Level

1. Player sees map layout and available buildable tiles.
2. Player starts with gold and lives.
3. Player builds starting towers.
4. Wave begins.
5. Creeps spawn and move toward exit.
6. Towers auto-attack.
7. Player earns gold from kills.
8. Player upgrades/sells/builds towers.
9. Next wave starts.
10. After final wave, level is cleared.
11. Score/stars are awarded.

## Win Condition

Clear all waves while keeping lives above 0.

## Lose Condition

Lives reach 0.

## Scoring

Suggested scoring factors:

| Factor                      | Effect           |
| --------------------------- | ---------------- |
| Remaining lives             | Higher score     |
| Gold saved                  | Small bonus      |
| Waves cleared without leaks | Bonus            |
| Difficulty modifier         | Score multiplier |
| Time/speed-up usage         | Optional         |

---

# 4. Map Design

## Map Type

Use **fixed-path maps with grid-based tower placement** for the first version.

Reason: easier to implement and balance than free-maze pathing.

Later optional mode: **maze-building TD**, where towers block movement but path validity must be preserved.

## Level Count

Target: **10 levels**

Each level introduces one new constraint or enemy pattern.

| Level | Theme         | Waves | Main Twist                      |
| ----: | ------------- | ----: | ------------------------------- |
|     1 | Grasslands    |    30 | Basic path, tutorial difficulty |
|     2 | Forest Pass   |    35 | Split path                      |
|     3 | Frozen Road   |    35 | Fast enemies                    |
|     4 | Ruined City   |    40 | Armored enemies                 |
|     5 | Swamp         |    40 | Regenerating enemies            |
|     6 | Mountain Pass |    40 | Flying waves introduced         |
|     7 | Desert Ruins  |    45 | Magic-resistant enemies         |
|     8 | Necropolis    |    45 | Summoner enemies                |
|     9 | Lava Fortress |    50 | Boss waves every 10 waves       |
|    10 | Demon Gate    |    50 | Mixed elite/boss/flying waves   |

---

# 5. Player Resources

## Primary Resources

| Resource     | Purpose                   |
| ------------ | ------------------------- |
| Gold         | Build and upgrade towers  |
| Lives        | Health of player base     |
| Mana / Power | Optional active abilities |
| Score        | Post-level rating         |

For the first version, use only:

* **Gold**
* **Lives**
* **Score**

Add mana later only if active abilities are needed.

## Economy

Suggested initial economy:

| Event             |      Reward |
| ----------------- | ----------: |
| Small creep kill  |    1–3 gold |
| Medium creep kill |    4–8 gold |
| Elite creep kill  |  10–20 gold |
| Boss kill         | 50–150 gold |
| Wave clear bonus  |  10–50 gold |

Optional interest mechanic:

```text
At end of wave, player gains +5% of current gold, capped at 50.
```

This is very WC3 TD-like but may be harder to balance. Good for advanced players.

---

# 6. Tower System

Target: **8 tower families**.

Each tower has:

* Base cost
* Damage
* Attack speed
* Range
* Projectile type
* Damage type
* Targeting rules
* Upgrade path
* Optional special effect

## Damage Types

Keep simple:

| Damage Type | Strong Against           | Weak Against     |
| ----------- | ------------------------ | ---------------- |
| Physical    | Light, Fast              | Armored          |
| Pierce      | Flying, Swarm            | Heavy            |
| Magic       | Armored, Regenerating    | Magic Resistant  |
| Siege       | Boss, Structures/Summons | Fast             |
| Elemental   | Utility/special          | Depends on tower |

## Tower Families

### 1. Arrow Tower

Basic reliable single-target tower.

| Stat        |                             Value |
| ----------- | --------------------------------: |
| Cost        |                                50 |
| Role        |              Cheap early-game DPS |
| Damage Type |                            Pierce |
| Strength    | Fast attack, good vs light/flying |
| Weakness    |                     Poor vs armor |

Upgrade path:

```text
Arrow Tower
  ├─ Ranger Tower: faster attack, longer range
  └─ Sniper Tower: high range, high crit, slower attack
```

Final upgrade ideas:

* **Ranger Captain**: attacks two targets
* **Deadeye Tower**: high crit chance, prioritizes strongest enemy

---

### 2. Cannon Tower

Splash physical damage.

| Stat        |                                   Value |
| ----------- | --------------------------------------: |
| Cost        |                                      90 |
| Role        |                          AoE anti-swarm |
| Damage Type |                                   Siege |
| Strength    |                Groups of ground enemies |
| Weakness    | Cannot hit flying, poor vs fast enemies |

Upgrade path:

```text
Cannon Tower
  ├─ Mortar Tower: larger splash, slower fire
  └─ Bombard Tower: smaller splash, armor shred
```

Special effects:

* Splash radius
* Armor reduction debuff
* Ground-only targeting

---

### 3. Frost Tower

Low damage, slows enemies.

| Stat        |         Value |
| ----------- | ------------: |
| Cost        |            80 |
| Role        | Crowd control |
| Damage Type |         Magic |
| Strength    | Slowing waves |
| Weakness    |       Low DPS |

Upgrade path:

```text
Frost Tower
  ├─ Glacial Tower: stronger slow, AoE chill
  └─ Ice Lance Tower: single-target slow + bonus damage to chilled enemies
```

Rules:

* Slow effects should not stack infinitely.
* Use strongest slow or diminishing returns.

Example:

```text
Slow cap: 70%
Duration refreshes, magnitude does not stack.
```

---

### 4. Flame Tower

Damage over time and cone/AoE damage.

| Stat        |                                   Value |
| ----------- | --------------------------------------: |
| Cost        |                                     100 |
| Role        |        Anti-regeneration, sustained AoE |
| Damage Type |                               Elemental |
| Strength    | Regenerating enemies, clustered enemies |
| Weakness    |                  Fire-resistant enemies |

Upgrade path:

```text
Flame Tower
  ├─ Inferno Tower: stronger burn, AoE splash
  └─ Dragon Tower: cone attack, short range, high DPS
```

Special effects:

* Burn DoT
* Burn disables regeneration
* Later upgrade spreads burn to nearby enemies

---

### 5. Arcane Tower

Magic single-target anti-armor.

| Stat        |                      Value |
| ----------- | -------------------------: |
| Cost        |                        110 |
| Role        | Anti-armored and anti-boss |
| Damage Type |                      Magic |
| Strength    |                Heavy armor |
| Weakness    |    Magic-resistant enemies |

Upgrade path:

```text
Arcane Tower
  ├─ Sorcerer Tower: mana burst, bonus vs armored
  └─ Void Tower: ignores partial resistance, expensive
```

Special effects:

* Magic amplification debuff
* Resistance penetration
* Bonus damage to shielded enemies

---

### 6. Lightning Tower

Chain damage.

| Stat        |                  Value |
| ----------- | ---------------------: |
| Cost        |                    120 |
| Role        |     Multi-target burst |
| Damage Type |              Elemental |
| Strength    |    Medium-sized groups |
| Weakness    | Single targets, bosses |

Upgrade path:

```text
Lightning Tower
  ├─ Storm Tower: longer chain, lower falloff
  └─ Tesla Tower: faster attack, shorter range
```

Rules:

```text
Chain damage falls off by 20% per jump.
Max jumps: 3–7 depending on upgrade.
```

---

### 7. Poison Tower

Damage over time and weakening effects.

| Stat        |                                     Value |
| ----------- | ----------------------------------------: |
| Cost        |                                        85 |
| Role        |        Long-duration damage, anti-high-HP |
| Damage Type |                         Physical / Nature |
| Strength    |                             Bosses, tanks |
| Weakness    | Poison-immune enemies, weak immediate DPS |

Upgrade path:

```text
Poison Tower
  ├─ Venom Tower: stronger poison, stacks up to N times
  └─ Plague Tower: poison spreads on death
```

Special effects:

* Poison DoT
* Healing reduction
* Death spread

Important balance rule:

```text
Poison should stack only from specific upgrades.
Base poison should refresh duration only.
```

---

### 8. Support Tower

Buffs nearby towers.

| Stat        |                   Value |
| ----------- | ----------------------: |
| Cost        |                     150 |
| Role        |  Economy/DPS multiplier |
| Damage Type |                    None |
| Strength    | Improves tower clusters |
| Weakness    |         Does not attack |

Upgrade path:

```text
Support Tower
  ├─ War Drum Tower: attack speed aura
  └─ Focus Crystal: damage/range aura
```

Rules:

* Auras of the same type do not stack.
* Different aura types can stack.
* Expensive but powerful in optimized builds.

Example aura:

```text
Tier 1: +10% attack speed
Tier 2: +18% attack speed
Tier 3: +25% attack speed
```

---

# 7. Tower Upgrade Model

## Upgrade Depth

Each tower family should have:

```text
Base Tower
  ├─ Path A Tier 1
  │   ├─ Path A Tier 2
  │   └─ Path A Tier 3
  └─ Path B Tier 1
      ├─ Path B Tier 2
      └─ Path B Tier 3
```

Simpler first version:

```text
Base Tower
  ├─ Upgrade 1
  ├─ Upgrade 2
  └─ Upgrade 3
```

Recommended approach:

* Prototype with **linear upgrades**
* Expand to **branching upgrades** once base loop is fun

## Upgrade Costs

Suggested rough formula:

```text
Tier 1 cost = base cost × 0.8
Tier 2 cost = base cost × 1.6
Tier 3 cost = base cost × 3.2
Final cost = base cost × 6.0
```

## Sell Value

```text
Sell refund = 70% of total invested gold
```

Possible difficulty modifiers:

| Difficulty | Sell Refund |
| ---------- | ----------: |
| Easy       |         85% |
| Normal     |         70% |
| Hard       |         50% |

---

# 8. Enemy Design

## Enemy Attributes

Each enemy type should have:

* HP
* Speed
* Armor type
* Resistance type
* Gold reward
* Lives lost on leak
* Special trait

## Enemy Types

| Enemy    | Role               | Special                  |
| -------- | ------------------ | ------------------------ |
| Grunt    | Basic creep        | None                     |
| Runner   | Fast creep         | Low HP, high speed       |
| Brute    | Tank               | High HP, slow            |
| Armored  | Physical-resistant | Weak to magic            |
| Shaman   | Regenerating       | Weak to fire/poison      |
| Wraith   | Magic-resistant    | Weak to physical         |
| Flyer    | Flying             | Only some towers can hit |
| Splitter | Splits on death    | Spawns small units       |
| Summoner | Spawns minions     | Priority target          |
| Boss     | High HP            | Special wave enemy       |

## Armor/Resistance

Keep the first version simple:

```text
Damage multiplier = tower_damage × enemy_resistance_multiplier
```

Example:

| Enemy Type      | Physical | Pierce | Magic | Siege | Elemental |
| --------------- | -------: | -----: | ----: | ----: | --------: |
| Light           |      1.0 |   1.25 |   1.0 |   0.8 |       1.0 |
| Armored         |     0.65 |   0.75 |  1.35 |   1.0 |       1.0 |
| Flying          |      0.8 |    1.3 |   1.0 |   0.0 |       1.0 |
| Magic Resistant |      1.0 |    1.0 |  0.55 |   1.0 |       0.8 |
| Boss            |     0.85 |   0.85 |  0.85 |  1.15 |      0.85 |

---

# 9. Wave Design

## Wave Count

Use:

* Early levels: **30 waves**
* Mid levels: **35–40 waves**
* Late levels: **45–50 waves**

## Wave Structure

Each wave has:

```text
wave_id
enemy_type
count
spawn_interval
hp_multiplier
speed_multiplier
gold_multiplier
special_modifiers
boss_flag
```

## Example Wave Progression Pattern

| Wave Range | Purpose                                 |
| ---------- | --------------------------------------- |
| 1–5        | Basic creeps, tutorial economy          |
| 6–10       | First fast/swarms                       |
| 11–15      | Armor introduced                        |
| 16–20      | Regeneration/magic resistance           |
| 21–25      | Mixed waves                             |
| 26–30      | First boss and combined threats         |
| 31–40      | Stronger mixed waves                    |
| 41–50      | Elite/boss/flying/splitter combinations |

## Boss Waves

Every 10 waves:

```text
10, 20, 30, 40, 50
```

Bosses should have:

* High HP
* Reduced CC effectiveness
* High gold reward
* Unique visual
* Possibly one mechanic

Example boss mechanics:

| Boss           | Mechanic                   |
| -------------- | -------------------------- |
| Stone Golem    | High armor                 |
| Demon Hound    | Fast boss                  |
| Lich           | Summons skeletons          |
| Ancient Dragon | Flying boss                |
| Demon Lord     | Periodic resistance shield |

---

# 10. Level Progression

## Unlock Model

Recommended:

```text
Level 1 unlocked by default.
Each completed level unlocks the next.
```

Optional star system:

| Stars | Requirement              |
| ----: | ------------------------ |
|     1 | Complete level           |
|     2 | Complete with 50%+ lives |
|     3 | Complete with 90%+ lives |

Avoid permanent power progression in the first version. It complicates balancing.

Better first version:

* Level unlocks
* Difficulty modes
* Score/stars
* No RPG-like tower upgrades outside levels

---

# 11. Difficulty Modes

| Difficulty | Enemy HP | Enemy Speed | Starting Gold | Lives |
| ---------- | -------: | ----------: | ------------: | ----: |
| Easy       |      80% |         95% |          130% |    30 |
| Normal     |     100% |        100% |          100% |    20 |
| Hard       |     130% |        110% |           90% |    15 |
| Nightmare  |     170% |        120% |           75% |    10 |

First version should implement:

* Easy
* Normal
* Hard

Nightmare can come later.

---

# 12. Player Controls

## Mouse

| Input                        | Action                 |
| ---------------------------- | ---------------------- |
| Left-click tower button      | Select tower to build  |
| Left-click tile              | Place tower            |
| Left-click existing tower    | Select tower           |
| Right-click                  | Cancel build/selection |
| Mouse wheel                  | Zoom camera            |
| Drag middle mouse / edge pan | Move camera            |

## Keyboard

| Key      | Action                     |
| -------- | -------------------------- |
| Space    | Start next wave            |
| 1–8      | Select tower type          |
| U        | Upgrade selected tower     |
| S        | Sell selected tower        |
| Esc      | Cancel/close               |
| F1/F2/F3 | Speed 1x/2x/3x             |
| Tab      | Cycle tower targeting mode |

## Tower Targeting Modes

Useful and simple:

* First
* Last
* Strongest
* Weakest
* Closest
* Flying only, where applicable

---

# 13. UI Layout

## Main Screen

```text
+--------------------------------------------------+
| Lives | Gold | Wave X/Y | Score | Speed          |
+--------------------------------------------------+
|                                                  |
|                    Game Map                      |
|                                                  |
|                                                  |
+----------------------+---------------------------+
| Tower Build Panel    | Selected Tower Panel      |
| Arrow  Cannon Frost  | Name / Damage / Range     |
| Flame  Arcane etc.   | Upgrade / Sell / Target   |
+----------------------+---------------------------+
```

## Required UI Panels

| Panel                 | Purpose                  |
| --------------------- | ------------------------ |
| Top HUD               | Lives, gold, wave, score |
| Build Panel           | Tower selection          |
| Tower Info Panel      | Stats, upgrade, sell     |
| Wave Preview          | Upcoming enemy type      |
| Pause Menu            | Resume, restart, quit    |
| Level Select          | Choose unlocked level    |
| Victory/Defeat Screen | Score, stars, retry/next |

---

# 14. Visual Style

## Direction

Old-school fantasy RTS-inspired but not a Warcraft clone.

Use:

* Pixel-art or low-res painted sprites
* Top-down orthographic map
* Strong silhouettes
* Clear attack effects

## Tile Types

| Tile                  | Function             |
| --------------------- | -------------------- |
| Path                  | Enemies move here    |
| Buildable grass/stone | Towers can be placed |
| Blocked terrain       | Cannot build or path |
| Decoration            | Trees, ruins, rocks  |
| Spawn                 | Enemy entry          |
| Exit/base             | Enemy destination    |

---

# 15. Audio Design

Minimal but useful:

| Sound           | Purpose          |
| --------------- | ---------------- |
| Tower placement | Confirmation     |
| Upgrade         | Reward           |
| Sell            | Feedback         |
| Enemy leak      | Warning          |
| Wave start      | State transition |
| Boss spawn      | Threat signal    |
| Victory/defeat  | Level result     |
| Projectile hits | Combat feedback  |

Music can be added late. Do not prioritize music before core gameplay.

---

# 16. Technical Design Direction for Odin

No code yet, but design around simple, explicit systems.

## Suggested Tech Stack

| Layer              | Recommendation                       |
| ------------------ | ------------------------------------ |
| Language           | Odin                                 |
| Window/input/audio | Raylib bindings or SDL2              |
| Rendering          | 2D sprite batching                   |
| Data               | JSON/TOML/custom text format         |
| Builds             | Native Windows first                 |
| Editor             | Simple internal map/wave tools later |

Raylib is likely the fastest route for a first playable version.

## Main Runtime Systems

| System               | Responsibility                         |
| -------------------- | -------------------------------------- |
| Game State           | Menu, playing, paused, victory, defeat |
| Map System           | Tiles, paths, build zones              |
| Enemy System         | Spawning, movement, HP, status effects |
| Tower System         | Placement, upgrades, targeting         |
| Projectile System    | Movement, collision, damage            |
| Status Effect System | Slow, burn, poison, armor shred        |
| Economy System       | Gold, rewards, selling                 |
| Wave System          | Wave definitions and timers            |
| UI System            | HUD, buttons, tower panels             |
| Save System          | Unlocked levels, scores, settings      |
| Asset System         | Textures, sounds, configs              |

## Recommended Internal Architecture

Use a **simple data-oriented architecture**, not a heavy OOP-style hierarchy.

Example conceptual entities:

```text
Tower {
  type_id
  position
  level
  upgrade_path
  cooldown
  targeting_mode
}

Enemy {
  type_id
  path_index
  hp
  speed
  status_effects
}

Projectile {
  type_id
  position
  target_enemy_id
  damage
}
```

Avoid over-engineering ECS for the first version unless you specifically want that exercise.

---

# 17. Data Design

## Tower Definition

Conceptual schema:

```text
TowerDef:
  id
  name
  cost
  damage
  damage_type
  range
  attack_cooldown
  projectile_speed
  can_hit_ground
  can_hit_air
  splash_radius
  status_effect
  upgrades
```

## Enemy Definition

```text
EnemyDef:
  id
  name
  hp
  speed
  armor_type
  gold_reward
  lives_damage
  flags
  resistances
```

## Wave Definition

```text
WaveDef:
  wave_number
  enemy_id
  count
  spawn_interval
  hp_multiplier
  speed_multiplier
  gold_multiplier
  modifiers
```

## Level Definition

```text
LevelDef:
  id
  name
  map_file
  wave_file
  starting_gold
  lives
  unlocked_towers
  difficulty_modifiers
```

---

# 18. Balance Model

## Initial Tower Balance Targets

A normal level should be tuned so that:

* Basic towers handle waves 1–5.
* Player needs splash by waves 6–10.
* Player needs anti-armor by waves 10–15.
* Player needs slow/support by waves 15–25.
* Player needs specialized upgrade paths by waves 25+.

## Basic Formulas

Enemy HP growth:

```text
enemy_hp = base_hp × level_multiplier × wave_multiplier
```

Suggested wave multiplier:

```text
wave_multiplier = 1.12 ^ wave_number
```

This may grow too aggressively over 50 waves, so cap or tune manually.

Alternative safer progression:

```text
wave_multiplier = 1.0 + wave_number * 0.12 + floor(wave_number / 10) * 0.5
```

Tower upgrade scaling:

```text
DPS increase per upgrade tier: 1.6x to 2.2x
Cost increase per tier: 1.8x to 2.8x
```

A tower upgrade should usually be more efficient than building another base tower, but less flexible.

---

# 19. Content Scope

## Minimum Playable Version

Target this first:

| Feature          | Included |
| ---------------- | -------- |
| 1 map            | Yes      |
| 10 waves         | Yes      |
| 3 towers         | Yes      |
| 3 enemy types    | Yes      |
| Basic upgrades   | Yes      |
| Gold/lives       | Yes      |
| Win/lose state   | Yes      |
| UI               | Minimal  |
| Save progression | No       |
| Audio            | Optional |

## Vertical Slice

Then expand to:

| Feature          | Included       |
| ---------------- | -------------- |
| 1 complete level | 30 waves       |
| 5 towers         | Basic upgrades |
| 6 enemy types    | Including boss |
| Full HUD         | Yes            |
| Pause/restart    | Yes            |
| Basic sound      | Yes            |
| Score screen     | Yes            |

## Full Version 1.0

| Feature          |   Target |
| ---------------- | -------: |
| Levels           |       10 |
| Waves per level  |    30–50 |
| Tower families   |        8 |
| Enemy types      |       10 |
| Difficulty modes |        3 |
| Save progression |      Yes |
| Audio            |    Basic |
| Map editor       | Optional |
| Wave editor      | Optional |

---

# 20. Development Milestones

## Milestone 1: Core Loop Prototype

Goal: prove the game loop.

Includes:

* Window
* Map rendering
* Fixed enemy path
* Enemy spawning
* One tower
* Tower targeting
* Projectile hits
* Gold/lives
* Win/lose

## Milestone 2: Real TD Mechanics

Includes:

* 3–5 towers
* Tower upgrades
* Multiple enemy types
* 10–15 waves
* Build/sell UI
* Basic balancing

## Milestone 3: Vertical Slice Level

Includes:

* 1 polished level
* 30 waves
* 5+ towers
* Boss wave
* Score screen
* Audio feedback
* Save result

## Milestone 4: Content Expansion

Includes:

* 10 levels
* 8 towers
* 10 enemy types
* 30–50 waves per level
* Difficulty modes
* Better visual effects

## Milestone 5: Polish

Includes:

* Menus
* Settings
* Hotkeys
* Tooltips
* Improved path visuals
* Performance cleanup
* Balance pass

---

# 21. Key Design Risks

| Risk                             | Why It Matters                           | Mitigation                                  |
| -------------------------------- | ---------------------------------------- | ------------------------------------------- |
| Too much content before fun loop | 10 levels × 50 waves is large            | Build 1 excellent level first               |
| Balance explosion                | 8 towers × upgrades × enemies is complex | Use data-driven configs and simple formulas |
| Poor readability                 | TD becomes hard to parse                 | Keep visual effects restrained              |
| Maze-building pathing complexity | Can become a technical sink              | Start with fixed paths                      |
| UI takes longer than expected    | TD needs many controls                   | Keep UI functional, not fancy               |
| Weak enemy variety               | Waves feel repetitive                    | Use modifiers and mixed waves               |
| Overly complex progression       | Hard to balance                          | No permanent upgrades in v1                 |

---

# 22. Recommended Design Decisions

For the first serious version:

| Area             | Decision                                   |
| ---------------- | ------------------------------------------ |
| Perspective      | 2D top-down                                |
| Map              | Fixed paths, grid-based build zones        |
| Towers           | 8 families                                 |
| Upgrades         | Linear first, branching later              |
| Levels           | 10 total, but build 1 polished level first |
| Waves            | 30 early, 50 late                          |
| Economy          | Gold + lives only                          |
| Difficulty       | Easy/Normal/Hard                           |
| Meta-progression | Level unlocks and stars only               |
| Engine approach  | Odin + Raylib-style 2D stack               |
| Data             | External configs as early as practical     |

---

# 23. First Content Set

## First Prototype Towers

Start with only these:

| Tower        | Purpose             |
| ------------ | ------------------- |
| Arrow Tower  | Basic single-target |
| Cannon Tower | Splash AoE          |
| Frost Tower  | Slow utility        |

## First Prototype Enemies

| Enemy  | Purpose                        |
| ------ | ------------------------------ |
| Grunt  | Baseline creep                 |
| Runner | Tests targeting and fast leaks |
| Brute  | Tests single-target DPS        |

## First Prototype Level

```text
Level 1: Grasslands
Waves: 10 initially, then expand to 30
Path: one winding path
Build zones: generous
Starting gold: 200
Lives: 20
Available towers: Arrow, Cannon, Frost
Boss: wave 10 prototype brute boss
```

This gives enough mechanics to test whether the core TD loop works before expanding content.
