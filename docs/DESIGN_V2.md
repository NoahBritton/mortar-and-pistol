# Mortar and Pistol — Design Document V2

> Consolidated design reference. Combines implemented game state, FPS-era lore, survivor genre research, and design principles into one source of truth. Previous docs preserved in `docs/` and `archive/`.

---

## 1. Identity

**Mortar and Pistol** is a bullet heaven (horde-like / vampire survivors-like) built in **Godot 4.5** with GDScript.

**Setting**: Medieval fantasy world where magic exists — but instead of wands and staffs, heroes use **wooden and iron guns powered by magic and alchemy**. Each weapon is purpose-built to channel a specific type of magic through its barrel, chamber, or payload system. The guns aren't just firearms with spells bolted on — they're designed from the ground up as magical instruments that happen to shoot.

**Genre Identity** (from video research):
- Fight large hordes with automated attacks and simple controls
- Fast-paced short runs with frequent meaningful upgrades
- Power fantasy: feel overwhelmed AND empowered simultaneously
- Readable chaos — screen should look insane but stay parsable
- The defining fantasy is *surviving and destroying hordes*, not precision combat

**Visual Direction**: Pixelated blocky aesthetic. GPUParticles2D with scaled-up 1x1 white pixels. Enhanced `_draw()` with draw_rect layers. Chunky blocks (6-12px) for cores, fine pixels (2-4px) for trails. No smooth textures.

**Audio Direction**: Alchemical and arcane — bubbling, crackling, thumping. Heavy wooden and metal impacts. Magic should sound physical, not ethereal.

**Viewport**: 960x540 stretched to 1920x1080 (2x pixel scale). GL Compatibility renderer.

---

## 2. Design Principles

Distilled from genre research (8 games analyzed) and video breakdown. These guide every design decision.

### Core Rules

1. **Simple controls first** — Movement + dash + upgrade selection. That's it. One extra input (dash) max.
2. **Fast fun onset** — Interesting build choices within the first 2-3 level-ups. No boring warm-up phase.
3. **Earned power growth** — Strong builds should feel achieved through smart choices, not handed out.
4. **Readable chaos** — Effects must look good alone and in groups. Player position must always be clear.
5. **Meaningful reward loops** — Upgrades, unlocks, stats screens, and meta progression all reinforce the growth fantasy.
6. **Enemy simplicity with paced variation** — Most enemies are walking health bars. Special types introduced gradually.
7. **Build systems that transform the run** — Weapons should feel different by the end compared to how they start.
8. **Three tiers of progression** — In-run (weapons/passives/levels), meta (permanent stat bonuses), and unlocks (characters/content).

### Balance Philosophy

The ideal power curve:
1. Start somewhat vulnerable
2. Slowly assemble a build through deliberate choices
3. Hit a satisfying power spike
4. Still stay challenged through enemy scaling

**Bad outcomes**: Too weak = slow and frustrating. Too strong too early = boring because nothing matters.

### Upgrade Design

Three categories of upgrades (all must exist):
- **Attack upgrades**: Weapons, abilities — the core build
- **Mechanical upgrades**: Status effects, on-kill effects, dash interactions — build identity
- **Numerical upgrades**: Stat boosts — bullet heavens uniquely make these fun because they scale chaos

Rarity systems are good when they add excitement and support balance, bad when "pick highest rarity" becomes the only strategy.

### Skill Expression Tools

Players need tools to fight RNG:
- **Rerolls**: Shuffle choices (limited per run)
- **Banish**: Remove unwanted items permanently from pool (future)
- **Skip**: Take nothing (not currently planned — forced choice)

### Post-Run Feedback

End-of-run stats are critical. Players can't track what worked during chaos. Detailed stats improve understanding, satisfaction, and learning.

---

## 3. Game Loop

### Run Structure

**Format**: Time-based (not wave-based). Continuous enemy stream for 15 minutes.

**Win Condition**: Survive 15 minutes. Victory screen with final stats.

**Difficulty Brackets**:
| Period | Enemies/Spawn | Pressure |
|---|---|---|
| 0–5m | 1-2 | Warm-up — establish build |
| 5–10m | 3-4 | Ramp — synergies needed |
| 10–15m | 4-6 | Peak — full build required |

**Flow**: Main Menu → Character Select → Run (15m) → Game Over / Victory → Stats → Main Menu

### Controls

- **Move**: WASD / arrow keys / left stick
- **Dash**: Space / bumper (Alchemical Blink — see Section 9)
- **Level-up**: Click card / navigate + confirm
- **Everything else**: Automatic (weapons fire at nearest enemies)

---

## 4. Heroes

Four playable heroes. Each has an exclusive starting weapon and a stat bonus that steers their build.

| Hero | Weapon | Type | Color | Stat Bonus | Description |
|---|---|---|---|---|---|
| **Wizard** | Bolt Rifle | BEAM | `#6699ff` | +10% Fire Rate | Arcane scholar. Precise energy beam. |
| **Alchemist** | Scatter Flask | BURST | `#66ff66` | +12% AoE Radius | Potion master. Shrapnel on impact. |
| **Bombardier** | Powder Keg | MINE | `#ff6619` | +15% Damage | Explosives expert. Delayed detonation. |
| **Assassin** | Twin Barrels | BURST_FIRE | `#b3e6ff` | +15% Move Speed | Swift rogue. Rapid double-tap. |

### Character Weapon Details

**Bolt Rifle** (Wizard) — BEAM
- Pulsed energy beam (~0.2s flash) that hits everything in a line
- Fires toward nearest enemy at fire time (fixed direction, can miss if enemy moves)
- 3–7 pierce across levels, 500px range
- Rewards positioning and anticipation

**Scatter Flask** (Alchemist) — BURST
- Flask follows a lobbing arc toward the target with ground shadow indicator
- Shatters on first enemy hit OR at target position (whichever comes first)
- 4–8 shrapnel spray 360° from impact point, 250px range
- Reusable lob system (parabolic arc, ground shadow)

**Powder Keg** (Bombardier) — MINE
- First keg drops at player position. Extra kegs (from Extra Powder passive) thrown in arcs to nearby positions
- 0.8s fuse with shrinking countdown ring + ground danger zone
- 90px detonation radius, shrapnel fragments on explode
- Extra Powder drops multiple kegs simultaneously

**Twin Barrels** (Assassin) — BURST_FIRE
- 2 rapid shots (0.1s apart) at nearest enemy
- 300px range, 450 projectile speed
- Consistent single-target DPS, rewards tracking

### Character Dash Variations (Alchemical Blink)

| Hero | Dash Name | Twist |
|---|---|---|
| Wizard | Arc Step | Lightning trail damages enemies (5 dmg) |
| Alchemist | Caustic Roll | Poison puddle at start position (2 dmg/tick, 1.5s) |
| Bombardier | Blast Jump | Small knockback at start position |
| Assassin | Smoke Dash | 30% longer distance (130px vs 100px) |

---

## 5. Weapons

### Gun Design Philosophy

All magic comes FROM the weapons. A mortar launcher can't fire seeker rounds. A pair of pistols can't lob potion shells. The gun's physical construction (vents, chambers, barrel etchings, payload systems) determines what magic it can channel.

### Pool Weapons (6 Archetypes)

Available to all heroes through the level-up pool. Currently **soft-archived** (exist in code, excluded from pool until un-archived via meta progression).

| Weapon | Type | Color | Description | Key Mechanic |
|---|---|---|---|---|
| Bayonet Rush | MELEE | `#c0c0c0` | Rifle-mounted blade | 120° sweep, 90px reach |
| Mortar Burst | AOE | `#ffd94d` | Alchemical shell | 80px radius pulse around player |
| Arc Discharge | CHAIN | `#6699ff` | Lightning-infused rounds | 2-6 chain arcs, 120px hop |
| Ember Shells | ORBIT | `#ff6619` | Fire-enchanted ammunition | 2-6 orbiters, 60px radius |
| Blight Flask | DOT | `#66ff66` | Thrown poison vial | 70px zone, 0.5s ticks, 3-5s duration |
| Seeker Rounds | BARRAGE | `#cc66ff` | Enchanted homing bullets | 2-4 homing missiles, 30px splash |

All pool weapons scale from Lv1→Lv5.

### Transmutations (Evolutions)

Alchemical transformation of a base weapon into something greater. Requires base weapon at Lv5 + paired passive at any level. Auto-triggers when conditions are met.

| Base (Lv5) | + Passive | = Transmutation | Key Change |
|---|---|---|---|
| Bayonet Rush | Gunpowder | **Reaper's Bayonet** | 360° sweep, 120px, 40 dmg |
| Mortar Burst | Clockwork | **Carpet Bomber** | 150px radius, multiple detonations |
| Arc Discharge | Birdshot | **Storm Conduit** | 8 chains, 180px hop |
| Ember Shells | Quicksilver | **Inferno Ring** | 6 orbiters, 90px, 270°/s |
| Blight Flask | Focusing Lens | **Plague Barrage** | 120px, 6s, 0.3s ticks |
| Seeker Rounds | Extra Powder | **Bullet Storm** | 6 seekers, 60px splash, screen-wide |

### DPS Targets (Lv5, Solo, No Passives)

*Character Starters*:
- Bolt Rifle: ~30 DPS (precision pierce)
- Scatter Flask: ~22 DPS (scales with density)
- Powder Keg: ~35 DPS (positioning-dependent)
- Twin Barrels: ~28 DPS (consistent single-target)

*Pool Weapons*:
- Bayonet Rush: ~35 DPS (high risk/reward melee)
- Mortar Burst: ~12 DPS (density scaling)
- Arc Discharge: ~20 DPS (chain scaling)
- Ember Shells: ~15 DPS (consistent field)
- Blight Flask: ~18 DPS (zone control)
- Seeker Rounds: ~28 DPS (reliable homing)

### Testing Checklist

- Solo weapon should NOT trivialize first 5m
- Solo weapon SHOULD require synergy by 10m
- Transmutations should feel like power spikes (2-3x DPS)
- 2-weapon combos + 3+ passives: winnable but challenging

---

## 6. Passives

Gun modifications and alchemical supplies. 8 passives, max 6 slots. All scale Lv1→Lv5.

**Status: Removed from level-up pool** — upgrade system rework pending. Passives exist in code but aren't offered during level-up. See Section 12 for rework plans.

| Passive | Flavor | Stat Key | Per Level | Max (Lv5) |
|---|---|---|---|---|
| Gunpowder | Higher caliber rounds | `damage_mult` | +10% | +50% |
| Clockwork | Faster mechanism | `fire_rate_mult` | +8% | +40% |
| Quicksilver | Mercury-laced barrel | `proj_speed_mult` | +10% | +50% |
| Birdshot | Split ammunition | `pierce_bonus` | +1 (flat) | +5 |
| Wind Vents | Pistol barrel vents | `move_speed_mult` | +8% | +40% |
| Lodestone | Magnetic attraction | `pickup_range_mult` | +15% | +75% |
| Focusing Lens | Wider blast scattering | `area_mult` | +8% | +40% |
| Extra Powder | More shots per volley | `proj_count_bonus` | +1 (flat) | +5 |

### Passive Synergies (Designed)

Every passive should do something for every weapon. Creative reinterpretations:

| Passive | Bolt Rifle | Scatter Flask | Powder Keg | Twin Barrels |
|---|---|---|---|---|
| Gunpowder | +damage | +damage | +damage | +damage |
| Clockwork | +fire rate | +fire rate | +fire rate | +fire rate |
| Quicksilver | +proj speed | +proj speed | Faster fuse | +proj speed |
| Birdshot | +pierce | Shrapnel pierces | Post-explosion shrapnel | +pierce |
| Wind Vents | +move speed | +move speed | +move speed | +move speed |
| Lodestone | +pickup range | +pickup range | +pickup range | +pickup range |
| Focusing Lens | Wider beam | +shatter radius | +blast radius | Wider hitbox |
| Extra Powder | 2 beams (V pattern) | +shrapnel count | +keg count | 3rd burst shot |

### Smart Pool Filtering

Level-up only shows passives whose `stat_key` is in at least one owned weapon's `used_stats` array. Guarantees relevance.

---

## 7. Elemental Affinities

Adapted from the original M&P FPS loadout system. In bullet heaven, elements are **weapon modifiers** gained during level-up. Only one active at a time — picking a new one replaces the old.

**Status: PLANNED** (R3 milestone)

| Element | Color | Damage | Fire Rate | Special Effect |
|---|---|---|---|---|
| **Fire** | `#ff4400` | -15% | +25% | Burn DoT (3 dmg/s, 3s) |
| **Earth** | `#8b6914` | +25% | -20% | +30% proj size, +20% AoE radius |
| **Lightning** | `#44aaff` | -10% | +15% | +2 pierce, +40px chain hop |
| **Wind** | `#aaeeff` | -25% | +40% | +20% move speed, Suffocate debuff |
| **Poison** | `#33dd33` | -20% | — | Poison DoT (5 dmg/s, 4s, stacks) |
| **Void** | `#9933ff` | -30% | -15% | Reduces max HP instead of current HP |
| **Light** | `#ffeeaa` | -10% | — | 2x proj speed, +30% reload speed |

### Element × Weapon Interactions (Stretch Goals)

Each weapon type responds uniquely to elements. Examples:

**Character Weapons**:
- Bolt Rifle + Lightning: Bolt forks into 2 secondary bolts on last pierced enemy
- Scatter Flask + Poison: Shrapnel leaves tiny DoT puddles
- Powder Keg + Void: Explosion creates vacuum pull before detonating
- Twin Barrels + Wind: Third shot added (triple-tap)

**Pool Weapons**:
- Bayonet Rush + Fire: Burning trail on sweep path
- Arc Discharge + Lightning: Double chain count
- Ember Shells + Poison: Orbiters emit poison clouds
- Seeker Rounds + Void: On-kill void singularity pull

*(Stat modifiers alone make each element play differently. Unique interactions are stretch goals.)*

---

## 8. Stats System

### Current Stats (Implemented)

| Stat | Key | Default | Source |
|---|---|---|---|
| Damage | `damage_mult` | 1.0 | Gunpowder passive, character bonus |
| Fire Rate | `fire_rate_mult` | 1.0 | Clockwork passive, character bonus |
| Proj Speed | `proj_speed_mult` | 1.0 | Quicksilver passive |
| Pierce | `pierce_bonus` | 0 | Birdshot passive (flat) |
| Move Speed | `move_speed_mult` | 1.0 | Wind Vents passive, character bonus |
| Pickup Range | `pickup_range_mult` | 1.0 | Lodestone passive |
| Area | `area_mult` | 1.0 | Focusing Lens passive, character bonus |
| Proj Count | `proj_count_bonus` | 0 | Extra Powder passive (flat) |
| XP Mult | `xp_mult` | 1.0 | (reserved) |
| Max HP Bonus | `max_hp_bonus` | 0 | (reserved) |

### Stats to Add (From Research)

These appear across virtually every successful survivor-like:

| Stat | Priority | Reasoning |
|---|---|---|
| Crit Chance + Crit Damage | High | Universal excitement, burst variance |
| Max HP / HP Regen | High | Survivability beyond "kill faster" |
| Duration | Medium | For DOT, orbit, and AOE weapons |
| Cooldown (distinct from fire rate) | Medium | Ability timing, dash cooldown |
| EXP Growth | Medium | Snowball stat, speeds up runs |
| Knockback | Low | CC stat for survival builds |
| Luck | Low | Meta stat for upgrade quality |

### Stat Resolution

All resolved in `GameManager._recalculate_stats()`. Percentage passives: `1.0 + level × per_level`. Flat passives: `0 + level × per_level`. Character bonus applied on top. Elemental modifiers (future) applied multiplicatively.

---

## 9. Dash — Alchemical Blink

**Why**: The genre's most meaningful extra mechanic for skill expression. Without movement abilities, positioning is limited and the skill ceiling is low.

| Stat | Value |
|---|---|
| Distance | 100px (~2x character width) |
| Duration | 0.12s |
| Cooldown | 2.0s |
| I-frames | First 0.08s |

**Status: Implemented**

- Direction: toward mouse cursor / movement direction (fallback)
- Cannot dash while paused or during level-up
- Animation: scale.x squeeze on start (0.6x), stretch at end (1.3x), afterimage sprites along path
- Wind Vents passive: -0.3s cooldown per level (min 0.5s at Lv5)
- Signal: `SignalBus.player_dashed`

---

## 10. Enemies

### Scaling Formula

| Stat | Base (0m) | 5m | 10m | Formula |
|---|---|---|---|---|
| Per spawn | 1 | 3-4 | 6 | `1 + min × 0.5` |
| HP | 30 | 80 | 130 | `30 + min × 10` |
| Speed | 60 | 85 | 110 | `60 + min × 5` |
| Contact Dmg | 10 | 25 | 40 | `10 + min × 3` |
| XP Value | 5 | 15 | 25 | `5 + min × 2` |

Max enemies: 200. Spawn distance: 600px. Spawn interval: 1.0s.

### Enemy Types (Planned)

Most enemies are walking health bars — the genre doesn't need complex AI. Special types add one mechanic each, introduced gradually.

| Type | Flavor | Mechanic |
|---|---|---|
| **Husks** | Corrupted creatures (current base) | Walk toward player |
| **Ironclads** | Alchemically hardened shells | Slow, armored |
| **Wisps** | Pure magic fragments | Fast, fragile, swarms |
| **Hexborn** | Unstable magic casters | Ranged bolts |
| **Splitters** | Mid-size burst enemies | Split into 2-3 Wisps on death |

### Elites (Planned)

Modified regular enemies: 5x HP, 0.8x speed, 1.5x size, 10x XP, guaranteed heal drop.

| Elite | Mechanic |
|---|---|
| Shielded | 50% reduced frontal damage |
| Volatile | Explodes on death (80px, 15 dmg) |
| Spawner | Spawns 2 Wisps every 3s |
| Magnetic | Pulls nearby XP gems toward itself |

Spawn rules: 1 elite per wave from 3:00, scaling to 2-3 by 12:00.

### Bosses (Planned)

Spawn at 5:00 and 10:00. Pause regular waves. Always spawn support enemies (horde-focused builds must remain viable).

**The Iron Warden** (5:00) — 800+ HP, slow, heavy hits. Ground Slam (AoE + spawns Ironclads), Shield Wall (75% DR, minion aggro), Charge (dash + damage trail).

**The Storm Weaver** (10:00) — 1500+ HP, fast, erratic. Wisp Burst (8 ring spawn), Lightning Trail (zigzag damage zones), Static Field (push + stun).

Both scale HP with `enemies_killed`. Drop: Lodestone Pulse + bonus XP + free level-up (Storm Weaver).

---

## 11. XP & Leveling

- **Curve**: `10 × level^1.3`
- **Level-up choices**: 3 cards
- **Rerolls**: 3 per run (infinite in god mode)
- **Inventory**: 6 weapon slots, 6 passive slots, 1 element slot

### XP Gems

- Diamond (Minecraft-style) shape, pixelated gradient
- Vortex attraction: spiral toward player with per-gem staggered speed (0.7-1.4x) and radius offset (-15 to +15px)
- Lodestone Pulse pickup: vacuums all on-screen gems

### Current Level-Up Pool

Currently only offers:
- Weapon upgrades (upgrade existing weapons)
- New weapons (if slots open and non-archived weapons available)
- Passives temporarily removed — rework pending (see Section 12)

---

## 12. Upgrade System Rework (OPEN)

Passives have been removed from the level-up pool pending a rework. Research from 8 games informs the direction.

### Research Findings — How Other Games Handle It

**6+6 Slot Model** (VS, HoloCure): 6 weapons + 6 passives. Evolution puzzle: plan backwards from desired combos. Industry standard.

**Wave-Based Shop** (Brotato): No level-up pool at all. Between-wave shop with gold economy. Can stack 6 of the same weapon. More player agency.

**Skill Tree** (20 Minutes Till Dawn): No items. All upgrades are skill nodes in a branching tree. Deep builds ("fire shotgun" vs "ice sniper"). RPG feel.

**Stacking Items** (Risk of Rain 2): Unlimited items that stack. 2nd Syringe = double attack speed. Pure excitement from drops.

**God Boons** (Hades): Themed upgrade sets from different gods. Duo Boons for cross-god synergies. Room-choice for reward type.

### Options Under Consideration

**Option A — VS Classic**: Restore passives to pool. Add Reroll/Banish/Skip. Standard model.

**Option B — Branching Weapons**: On level-up, only weapon upgrades. At key levels (3, 5), weapon branches into 2 paths. Passives from drops/chests only.

**Option C — The Forge Hybrid**: Level-up pool has weapons + minor traits (small buffs). Full passives from boss drops and milestone chests (3:00, 6:00, 9:00).

**Option D — Gunsmith's Table**: Periodic shop phases (every 2-3m). Buy upgrades with in-run currency (scrap/cogs). More agency, less RNG.

### Design Principles for the Rework

From research and video analysis:
- Choices should feel meaningful, not filler
- Every option in a level-up should be tempting in at least some situations
- The system should support intentional building, not random accumulation
- Passives shouldn't feel like "worse weapon upgrades"
- End-game (all slots full) needs to stay interesting

---

## 13. Meta Progression — The Forge (Planned)

### Currency: Arcane Dust

Earned every run (win or lose):

| Source | Dust |
|---|---|
| Base per run | 10 |
| Per minute survived | 5 |
| Per 100 kills | 3 |
| Per boss defeated | 25 |
| Victory bonus | 50 |
| First victory (per hero) | 100 |

Typical: loss at 5m ≈ 45, loss at 10m ≈ 80, victory ≈ 150-200.

### Permanent Stat Enhancements

| Enhancement | Per Level | Max (Lv5) | Total Cost |
|---|---|---|---|
| Tempered Barrels | +5% damage | +25% | 400 |
| Oiled Mechanisms | +4% fire rate | +20% | 400 |
| Alchemist's Vigor | +10 max HP | +50 HP | 295 |
| Swift Boots | +4% move speed | +20% | 295 |
| Magnetic Core | +10% pickup range | +50% | 200 |
| Lucky Loadout | +1 reroll | +5 | 445 |
| XP Attunement | +5% XP gain | +25% | 295 |

~2,800 total dust to max everything (~15-20 runs).

### Achievement Unlocks

| Unlock | Requirement |
|---|---|
| Pool Weapons | Complete 1 run with each hero (un-archives all 6 pool weapons) |
| Weapon Talents | Reach Lv5 on character weapon 3 times |
| Hard Mode | Win with any character (1.5x enemy stats, 1.5x dust) |
| Alchemist's Journal | Kill 1000 total enemies (unlocks per-weapon damage stats) |
| Elemental Mastery | Win with each element (unlocks dual-element attunement) |
| True Ending | Defeat Storm Weaver on Hard (20-minute run, third boss) |

God Mode runs do NOT earn Arcane Dust.

---

## 14. Arena & Environment (Planned)

Arena remains open space (no walls, infinite), with interactive elements:

### Breakable Crates
- 8-12 on map, 15 HP (1-2 hits), respawn 15-20s
- Drops: 60% XP cluster, 20% heal, 15% Lodestone Pulse, 5% Arcane Dust

### Alchemical Braziers
- 2 active at once, consume on touch, respawn 45s elsewhere
- Speed Brazier (cyan, +30% speed, 8s), Power Brazier (red, +20% damage, 8s), Shield Brazier (gold, block 1 hit, 15s)

### Environmental Hazards (Stretch)
- Corrupted Zones: slow purple patches, 3 dmg/s, spawn at 8:00+
- Ley Lines: floor glow, +15% fire rate when standing on active line

### Map Boundaries
- Infinite space, subtle darkening vignette at ~800px from center
- Crates and braziers spawn within 500px of center

---

## 15. End-of-Run Stats (Planned)

### Tracked Per Run

**Combat**: Total damage, kills, damage taken, healing, highest hit, kill streak (5s window)

**Per-Weapon Breakdown**: Damage dealt + % of total, kills attributed. Ranked bar chart. Transmuted weapons show pre/post separately.

**Build Summary**: Element, weapons with levels, passives with levels, rerolls used

**Progression**: Time survived, final level, XP collected, bosses defeated, elites killed

### UI: Tabbed View
- Tab 1 — Summary (quick glance)
- Tab 2 — Weapons (damage bar chart)
- Tab 3 — Build (full loadout + stat contributions)

---

## 16. Audio Design (Planned)

### Principles
1. **Pitch ramp on XP pickup**: Ascending pitch on rapid collection, reset after 0.5s gap, cap at +8 semitones
2. **Kill variation**: 3-4 variants, random selection
3. **Overkill feedback**: 3x+ overkill = beefier death sound
4. **Per-weapon fire sounds**: Each type gets a distinct SFX

### Target SFX

| Weapon | Fire | Hit |
|---|---|---|
| Bolt Rifle | Electric crack | Sizzling zap |
| Scatter Flask | Glass shatter + splash | Wet splat |
| Powder Keg | Heavy thud + deep boom | Crunch/debris |
| Twin Barrels | Quick double pop | Metallic ping |
| Bayonet Rush | Blade whoosh | Slash |
| Mortar Burst | Hollow thump | Low rumble |
| Arc Discharge | Electric buzz | Chain crackle |
| Ember Shells | Low hum (loop) | Fire hiss |
| Blight Flask | Acid sizzle | Bubbling |
| Seeker Rounds | Whistling launch | Impact thud |

### Key Audio Events
- Dash: whoosh + fabric flutter
- Boss spawn: deep horn + screen darkening
- Boss defeat: triumphant stab + shatter
- Transmutation: ascending chime + metallic ring

---

## 17. VFX & Visual Clarity (Planned)

### VFX Budget Tiers

| Tier | Examples | Culling |
|---|---|---|
| Critical | Player, boss, HUD | Never cull |
| High | Projectiles, dash trail, boss attacks | Reduce 50% at cap |
| Medium | Impacts, death bursts | Skip at cap |
| Low | Ambient, orbiter trails, passive glow | First culled |

Budget threshold: 150 active GPUParticles2D emitters.

### Z-Index Layering

| Layer | Z | Contents |
|---|---|---|
| Ground | 0 | Toxic zones, shadows, ley lines |
| Pickups | 5 | XP gems, heals, lodestone pulse |
| Enemies | 10 | All enemies, elites, boss |
| Player | 15 | Character, dash afterimages |
| Projectiles | 20 | All weapon projectiles |
| Overhead | 25 | Damage numbers, boss HP |
| HUD | 100 | All UI |

### Clarity Rules
- Player always on top with dark circle underneath
- Enemy hit flash always shows regardless of VFX budget
- Warm/bright = friendly, red/dark = hostile, purple = hazard, green/gold = pickup
- Screen shake: max 3px, no stacking, 0.15s decay

---

## 18. Architecture

### Autoloads (5)

| Name | Purpose |
|---|---|
| SignalBus | Global event bus (decoupled communication) |
| GameManager | State, HP, XP, leveling, inventories, stat multipliers, god mode |
| PoolManager | Generic object pooling (12 pool types) |
| AudioManager | SFX playback, button sound wiring |
| UiTheme | Code-built Kenney-textured game theme |

### Data Architecture

- **WeaponData** / **PassiveData** / **EvolutionData**: Custom Resource classes
- **WeaponsDB** / **PassivesDB** / **EvolutionDB**: Static databases with lazy init
- **Weapon Strategy Pattern**: Each WeaponType has a RefCounted strategy script in `scenes/weapons/types/`. WeaponManager lazy-creates one instance per type, calls `strategy.fire(data, level)`. No match dispatch.
- **Data-Driven Passive Synergy**: WeaponData has `used_stats: Array[String]`. PassiveData has `UNIVERSAL_STAT_KEYS`. Level-up panel filters by relevance.

### Physics Layers
1=Player, 2=Enemies, 3=Player Projectiles, 4=Pickups, 5=Enemy Projectiles (reserved)

### Object Pools

| Pool | Scene | Count |
|---|---|---|
| enemy | base_enemy.tscn | 50 |
| projectile | base_projectile.tscn | 100 |
| xp_gem | xp_gem.tscn | 100 |
| damage_number | damage_number.tscn | 50 |
| aoe_effect | aoe_effect.tscn | 10 |
| chain_effect | chain_effect.tscn | 10 |
| melee_effect | melee_effect.tscn | 10 |
| toxic_zone | toxic_zone.tscn | 15 |
| homing_missile | homing_missile.tscn | 30 |
| heal_pickup | heal_pickup.tscn | — |
| scatter_flask | scatter_flask.tscn | — |
| powder_keg | powder_keg.tscn | — |

### Key Implementation Patterns
- `distance_squared_to` for nearest-enemy (no sqrt)
- UI panels: `process_mode = PROCESS_MODE_ALWAYS` (works while paused)
- Enemy spawner: manual delta accumulator (not Timer nodes)
- Tweens for flash effects (avoids pool lifecycle issues)
- Pool lifecycle: `_is_dead` guard, remove from groups on release, re-add on acquire
- Settings: `user://settings.cfg` via ConfigFile
- `GameManager.pending_levels` queues multi-level-ups
- `on_hit(hit_enemy)` pattern prevents splash self-damage
- GPUParticles2D: `texture=null` (1x1 white pixel scaled), `particle_flag_disable_z=true`, `gravity=Vector3.ZERO`
- GL Compatibility: `emit_particle()` does NOT work — standard emission only

---

## 19. Roadmap

| Phase | Status | Summary |
|---|---|---|
| A1: Core Loop | **DONE** | Movement, auto-weapons, spawning, XP/leveling, game over |
| A2: Weapon Archetypes | **DONE** | 4 types, 6 passives, 4 evolutions, HUD, rerolls |
| A3a: New Weapons | **DONE** | 6 base weapons, 8 passives, 6 evolutions |
| A3a-fix: Core Audit | **DONE** | 17-bug audit and fix pass |
| A3b-UI: UI Polish | **PARTIAL** | Ornate Kenney panels, color-coded cards |
| A3b-VFX: Gameplay Visuals | **PARTIAL** | Base weapon VFX, XP gem overhaul, keg lob arc |
| R1: Re-Theme | **DONE** | All IDs renamed to M&P theming |
| R2: Character Select | **DONE** | 4 heroes, exclusive weapons, character select screen |
| R2.5: Workshop Fixes | **DONE** | Beam weapon, scatter flask fix, keg overhaul, passive synergy, XP vortex, dash |
| **R3: Elemental Affinities** | **PLANNED** | Element system, affinity cards, stat modifiers |
| **Upgrade Rework** | **IN PROGRESS** | Passives removed from pool, system redesign underway |
| A3c: Arena | **PLANNED** | Breakable crates, braziers, arena improvements |
| A3d: Bosses & Elites | **PLANNED** | Elite variants, Iron Warden, Storm Weaver |
| A3e: Audio Overhaul | **PLANNED** | Per-weapon SFX, pitch ramping, boss audio |
| A4: Stats & Balance | **PLANNED** | End-of-run stats, per-weapon DPS tracking, win condition |
| A5: VFX Clarity | **PLANNED** | VFX budget, z-index layering, clarity rules |
| B1: Art & Effects | **FUTURE** | Pixel art, entity sprites, evolution VFX |
| B2: Meta Progression | **FUTURE** | The Forge, Arcane Dust, permanent upgrades |
| B3: Maps & Variants | **FUTURE** | Multiple arenas, environmental hazards |

---

## 20. Future Content Ideas

### Weapons
- **Blunderbuss Spread** (SHOTGUN) — wide burst, close-range, evo: Dragon's Breath
- **Grapple Hook** (UTILITY) — pulls XP + damages on retract, evo: Chain Whip
- **Mine Layer** (TRAP) — drops alchemical mines, evo: Cluster Mine
- **Wind Cannon** (KNOCKBACK) — pushes enemies in a cone, evo: Hurricane

### Passives
- **Crown** (`xp_mult`) — +10%/level, max +50%
- **Iron Plating** (`max_hp_bonus`) — +20/level, max +100
- **Alchemist's Flask** — small HP on kill
- **Smoke Charge** — full invincibility during dash + 0.5s after

### Arena Variants
- **The Workshop**: Tight corridors, favors melee/AoE
- **The Wasteland**: Wide open, favors ranged/homing
- **The Ley Nexus**: Many ley lines, stronger environmental buffs

---

## 21. Asset Inventory

### Audio (Currently In Use)

| SFX Key | File | Use |
|---|---|---|
| sfx_shoot | jsfxr/laserShoot_short.wav | Weapon fire |
| sfx_hit | jsfxr/hitHurt.wav | Enemy hit |
| sfx_kill | jsfxr/explosion.wav | Enemy death |
| sfx_pickup | jsfxr/pickupCoin.wav | XP pickup |
| sfx_level_up | jsfxr/powerUp.wav | Level up |
| sfx_player_hurt | jsfxr/deathSound.wav | Player damage |
| sfx_ui_hover | jsfxr/menuHover.wav | Button hover |
| sfx_ui_click | jsfxr/menuConfirm.wav | Button press |
| sfx_ui_open | jsfxr/uiOpen.wav | Panel open |
| sfx_ui_close | kenney_digital-audio/lowDown.ogg | Panel close |

### Textures

**In Use**:
- kenney_fantasy-ui-borders (5/282): Panel borders, buttons, slots
- kenney_particle-pack (~10/193): Weapon/passive icons
- kenney_scribble-platformer (~7/212): Weapon/passive icons
- superpowers/ninja-adventure (2/253): Icons

**Available for M&P Theme**:
- kenney_board-game-icons (513): Swords, shields, potions, guns — ideal for icons
- kenney_rune-pack (667): Rune glyphs — element affinity icons
- kenney_tiny-dungeon (136): 16x16 medieval tiles — entity sprites
- kenney_splat-pack (73): Tintable splats — AoE zones, death effects

---

## Appendix A: Cross-Game Research Summary

Full research in `docs/SURVIVOR_SYSTEMS_RESEARCH.md`. Key findings:

| Feature | VS | HoloCure | Brotato | 20MTD | Hades |
|---|---|---|---|---|---|
| Weapon Slots | 6 | 6 | 6 | 1 | 1 (aspects) |
| Passive Slots | 6 | 6 | Unlimited | 0 (tree) | 1 keepsake |
| Evolution | Weapon+Passive+Chest | Weapon+Stamp+Chest | No | No | Aspects |
| Level-Up Model | 3-4 choices | 3-4 choices | Shop | 3 (tree) | Room choice |
| Meta Stats | Yes (gold) | Yes (coins) | No | No | Yes (mirror) |
| Run Time | 30m | 20m | 20 waves | 20m | ~30m |

## Appendix B: Lore Origins

Characters and elemental affinities adapted from an original FPS concept ("Mortar and Pistol" — a hero shooter with magic-powered guns). See `docs/scrapped_game_document.md` for the full FPS design. Key elements carried over:
- Gun-as-magic-catalyst philosophy
- Wizard / Alchemist / Assassin class identities
- 7 elemental affinities with the same thematic design
- Movement abilities channeled through weapons (adapted to Alchemical Blink)

---

*V2 written 2026-03-25. Previous design docs preserved in `docs/DESIGN.md` and `archive/`.*
