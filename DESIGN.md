# Mortar and Pistol — Design Reference

Quick-reference design doc. Adapted from the original bullet heaven design with **Mortar and Pistol** theming: medieval-era magic-powered guns, alchemical weapons, elemental affinities. See `archive/` for the original design docs.

---

## Setting & Tone

Medieval fantasy world where magic exists — but instead of wands, staffs, and swords, the heroes use **wooden and iron guns powered by magic and alchemy**. Each weapon is purpose-built to channel a specific type of magic through its barrel, chamber, or payload system. The guns aren't just firearms with spells bolted on — they're designed from the ground up as magical instruments that happen to shoot.

**Visual Direction**: Pixelated blocky aesthetic. GPUParticles2D with scaled-up 1x1 white pixels. Enhanced `_draw()` with draw_rect layers. Chunky blocks (6-12px) for cores, fine pixels (2-4px) for trails. No smooth textures.

**Audio Direction**: Alchemical and arcane — bubbling, crackling, thumping. Heavy wooden and metal impacts. Magic should sound physical, not ethereal.

---

## V1 Scope: Game Loop Completion

**Win Condition**: Survive **15 minutes**. At 15:00, waves stop and a "Victory!" screen displays with final stats (time, enemies killed, XP collected, rerolls used). Player can see run stats and return to main menu.

**Progression Difficulty Scaling** (applied per 5-min bracket):
- **0-5m**: Warm-up (1-2 enemies/spawn, low DPS requirement)
- **5-10m**: Ramp (3-4 enemies/spawn, moderate scaling)
- **10-15m**: Peak (4-6 enemies/spawn, high DPS check)

**First Impression & Boot**:
- Game boots to **Main Menu** (Start Game, Settings, Exit)
- Start Game → **Character Select** (pick one of 4 heroes, each with unique starting weapon + passive)
- In-game HUD displays: Player HP, level, time, enemy count, XP bar, equipped element indicator
- Paused state works (UI visible, gameplay frozen via PROCESS_MODE_ALWAYS)

**Game Over / Loss Condition**:
- Player HP ≤ 0 triggers **Game Over Panel**
- Shows: Time elapsed, Enemies killed, XP gained, Level reached, Rerolls used
- Buttons: Retry (new run), Main Menu

**Settings (v1 Minimum)**:
- Master / SFX / Music volume sliders
- Difficulty toggle: Normal / God Mode
- Persist to `user://settings.cfg`

**Performance Targets (v1)**:
- 60 FPS on mid-range laptop
- Max 200 enemies on-screen
- Memory < 400MB at end of run

**Known Limitations (Acceptable for v1)**:
- No persistence between runs
- No boss encounters (simple wave scaling)
- No music (SFX only)
- Single arena map

---

## Characters (4 Heroes)

Each hero has a **unique starting weapon** (exclusive to that hero), a **base elemental affinity**, and a **unique passive**. All heroes can pick up any pool weapon during runs — the starting weapon sets the hero's identity.

| Hero | Class Fantasy | Starting Weapon | Base Element | Passive |
|---|---|---|---|---|
| **The Wizard** | Mid-range precision | Bolt Rifle (piercing line) | Lightning | +10% fire rate |
| **The Alchemist** | AoE & debuffs | Scatter Flask (burst-on-impact) | Poison | +12% AoE radius |
| **The Bombardier** | Heavy explosions | Powder Keg (delayed mine) | Fire | +15% damage |
| **The Assassin** | Speed & burst | Twin Barrels (burst-fire) | Wind | +15% move speed |

### Character Flavor

**The Wizard** — Carries an enchanted long-barrel rifle. Arcane formulas etched along the barrel focus raw magic into a single devastating bolt that punches through anything in its path. Calm, calculated, always at the right distance.

**The Alchemist** — Modified blunderbuss that fires unstable alchemical flasks. On impact, the flask shatters into volatile shrapnel that sprays in all directions. The weapon hisses, bubbles, and smells faintly of sulphur.

**The Bombardier** — Wields a massive iron-banded mortar launcher that drops primed explosive kegs. The fuse burns down, then everything nearby goes up. Half the character's size, reinforced with alchemical seals.

**The Assassin** — Dual-wields compact pistols with wind vents along the barrels. Fires both barrels in rapid succession — a one-two punch that drops targets before they can react. Smoke and speed.

### Character Weapons (4 Exclusive Starters)

These weapons are **exclusive to their hero** — they don't appear in the level-up pool. Each hero starts with theirs at Lv1. They scale to Lv5 but do NOT transmute (transmutations are for pool weapons).

| Weapon | Hero | Type | Color | Damage | Rate | Mechanic |
|---|---|---|---|---|---|---|
| **Bolt Rifle** | Wizard | PIERCING | #44aaff | 20-40 | 0.8-1.2/s | Single fast bolt that pierces ALL enemies in a line. Long range (500px). 3-7 pierce. Precision sniper. |
| **Scatter Flask** | Alchemist | BURST | #33dd33 | 10+4×shrapnel | 0.7-1.0/s | Flask hits nearest enemy, shatters into 4-8 shrapnel projectiles spraying outward from impact. Short range (250px). |
| **Powder Keg** | Bombardier | MINE | #ff4400 | 25-60 | 0.5-0.7/s | Drops explosive barrel at player position. 0.8s fuse delay, then detonates (90px radius). Requires positioning. High risk, high reward. |
| **Twin Barrels** | Assassin | BURST-FIRE | #aaeeff | 10-22 ×2 | 1.2-1.8 bursts/s | Fires 2 rapid shots (0.1s apart) at nearest enemy. Fast projectiles (450 speed). 300px range. Dual-pistol double-tap. |

All stats are L1→L5 ranges.

**Design Note**: Character weapons are intentionally simpler than pool weapons — they define your hero's playstyle at the start but the 6 pool weapons (plus passives and elements) are where the build variety comes from.

---

## Pool Weapons (6 Archetypes)

These are the weapons available to ALL heroes through the level-up pool. They are distinct from character-exclusive starters. All weapons are **guns or gun-adjacent tools** — magic comes from the weapon, not the wielder.

| Weapon | Type | Flavor | Color | Damage | Rate | Special | Mechanic |
|---|---|---|---|---|---|---|---|
| Bayonet Rush | MELEE | Rifle-mounted blade, point-blank burst | #c0c0c0 | 14-30 | 1.2-2.0/s | 120° arc, 90px reach | Close-range magic-blade conjured from the barrel. Cone sweep. |
| Mortar Burst | AOE | Potion shell lobbed straight down | #ffd94d | 8-20 | 0.5-0.7/s | 80px radius | Explosive alchemical shell detonates around the player. |
| Arc Discharge | CHAIN | Lightning-infused rounds that arc between targets | #6699ff | 12-28 | 0.8-1.2/s | 2-6 chains, 120px hop | Bullet hits one target, arcs to nearby enemies. |
| Ember Shells | ORBIT | Fire-enchanted ammunition orbiting as a shield | #ff6619 | 7-15 | — | 2-6 orbiters, 60px radius | Burning rounds circle the player at 180°/s. |
| Blight Flask | DOT | Alchemist's thrown poison vial | #66ff66 | 5-13/tick | 0.4-0.6/s | 70px radius, 3-5s duration | Thrown zone, ticks every 0.5s. Lingers. |
| Seeker Rounds | BARRAGE | Enchanted homing bullets | #cc66ff | 15-27 | 0.4-0.6/s | 2-4 missiles, 30px splash | Bullets curve toward targets. Magic-guided. |

All stats are L1→L5 ranges.

### Gun Design Philosophy

All magic comes FROM the weapons. The weapons are designed to channel their specific type of magic — a mortar launcher can't fire seeker rounds, and a pair of pistols can't lob potion shells. The gun's physical construction (vents, chambers, barrel etchings, payload systems) determines what magic it can channel.

---

## Elemental Affinities

Adapted from the original M&P loadout system. In bullet heaven, elements appear as **weapon modifiers** gained during level-up. When you pick an elemental affinity, it applies to ALL your current weapons, changing their behavior.

Only one affinity can be active at a time. Picking a new one replaces the old one. Affinities are offered alongside weapons and passives in the level-up pool.

| Element | Color | Damage Mod | Fire Rate Mod | Special Effect |
|---|---|---|---|---|
| **Fire** | #ff4400 | -15% | +25% | Attacks apply burn DoT (3 dmg/s for 3s) |
| **Earth** | #8b6914 | +25% | -20% | Projectiles +30% larger, AoE +20% radius |
| **Lightning** | #44aaff | -10% | +15% | Attacks pierce +2 targets, chain hop +40px |
| **Wind** | #aaeeff | -25% | +40% | Player move speed +20%, attacks apply Suffocate (halves enemy healing/regen) |
| **Poison** | #33dd33 | -20% | — | All attacks apply poison DoT (5 dmg/s for 4s, stacks) |
| **Void** | #9933ff | -30% | -15% | Damage reduces enemy max HP instead of current HP. Max HP returns after 5s without Void damage |
| **Light** | #ffeeaa | -10% | — | All projectiles move 2x faster (near-instant), +30% reload speed |

### Affinity Interactions with Weapons

Each weapon type responds differently to the active element:

**Character Weapons:**
- **Bolt Rifle + Lightning**: Bolt forks into 2 secondary bolts on the last enemy pierced
- **Bolt Rifle + Light**: Near-instant bolt speed, leaves a bright damage trail behind the bolt
- **Scatter Flask + Poison**: Shrapnel pieces leave tiny DOT puddles where they land
- **Scatter Flask + Earth**: Flask doesn't burst — instead creates one large slow zone on impact
- **Powder Keg + Fire**: Detonation leaves a burning ground zone for 2s after explosion
- **Powder Keg + Void**: Explosion pulls enemies inward before detonating (vacuum + blast)
- **Twin Barrels + Wind**: Third shot added to burst (triple-tap instead of double-tap)
- **Twin Barrels + Lightning**: Shots chain to 1 nearby enemy after hitting primary target

**Pool Weapons:**
- **Bayonet Rush + Fire**: Leaves a burning trail on the sweep path
- **Bayonet Rush + Wind**: Sweep pushes enemies back (knockback)
- **Mortar Burst + Earth**: Massively increased blast radius, heavy screen shake
- **Mortar Burst + Void**: Blast vacuums enemies inward before detonating
- **Arc Discharge + Lightning**: Double chain count, faster arc speed
- **Arc Discharge + Light**: Instant arc (no travel time), extended range
- **Ember Shells + Fire**: Orbiters leave fire trails, burning anything they pass
- **Ember Shells + Poison**: Orbiters emit poison clouds in their wake
- **Blight Flask + Poison**: Doubled tick rate, poison clouds linger 2x longer
- **Blight Flask + Earth**: Zone is 50% larger with a slow effect
- **Seeker Rounds + Lightning**: Missiles arc between 2 extra targets after impact
- **Seeker Rounds + Void**: On kill, explodes into a void singularity that pulls enemies in

*(Not all combinations need unique interactions in v1 — the stat modifiers alone make each element play differently. Unique interactions are stretch goals.)*

---

## Evolutions (6 Rules)

Evolutions are re-themed as **Transmutations** — the alchemical transformation of a base weapon into something greater. Requires the base weapon at Lv5 + the paired passive at any level.

| Base Weapon (Lv5) | + Passive | = Transmutation | Key Stats |
|---|---|---|---|
| Bayonet Rush | Gunpowder (damage) | **Reaper's Bayonet** #e64dff | 360° scythe sweep, 120px reach, 40 dmg, 2.5/s |
| Mortar Burst | Clockwork (fire rate) | **Carpet Bomber** #ffff99 | 150px radius, 30 dmg, 1.5/s, multiple detonation points |
| Arc Discharge | Birdshot (pierce) | **Storm Conduit** #cce6ff | 8 chains, 180px hop, 25 dmg, 1.2/s |
| Ember Shells | Quicksilver (proj speed) | **Inferno Ring** #ff3300 | 6 orbiters, 90px radius, 18 dmg, 270°/s |
| Blight Flask | Focusing Lens (area) | **Plague Barrage** #00e676 | 120px zone, 12/tick, 6s, ticks/0.3s, toxic trail |
| Seeker Rounds | Extra Powder (proj count) | **Bullet Storm** #ff4081 | 6 seekers, 60px splash, 35 dmg, screen-wide targeting |

Auto-transmutes when base weapon reaches Lv5 and paired passive is owned (any level).

---

## Passives (8 Items, 6 Slots)

Re-themed as **gun modifications and alchemical supplies**.

| Passive | Flavor | Color | Stat Key | Effect/Level | Max (Lv5) |
|---|---|---|---|---|---|
| Gunpowder | Higher caliber rounds | #33cc33 | damage_mult | +10% damage | +50% |
| Clockwork | Faster mechanism | #996633 | fire_rate_mult | +8% attack speed | +40% |
| Quicksilver | Mercury-laced barrel | #cc9933 | proj_speed_mult | +10% weapon speed | +50% |
| Birdshot | Split ammunition | #66ccff | pierce_bonus (flat) | +1 pierce/chain | +5 |
| Wind Vents | Pistol barrel vents | #b3e6ff | move_speed_mult | +8% move speed | +40% |
| Lodestone | Magnetic attraction | #8033cc | pickup_range_mult | +15% pickup range | +75% |
| Focusing Lens | Wider blast scattering | #ffab40 | area_mult | +8% AOE/orbit radius | +40% |
| Extra Powder | More shots per volley | #7cb342 | proj_count_bonus (flat) | +1 proj/orbiter/missile | +5 |

---

## DPS Balance & Metrics

Same balance targets as original — weapon archetypes feel distinct, no single weapon trivializes all phases.

**DPS Targets (L5, Solo, no passives)**:

*Character Starters:*
- **Bolt Rifle (PIERCING)**: ~30 DPS (high per-shot, moderate rate, pierces groups in a line)
- **Scatter Flask (BURST)**: ~22 DPS (flask + shrapnel combined, scales with density near impact)
- **Powder Keg (MINE)**: ~35 DPS (massive damage IF positioned well, wasted if enemies dodge)
- **Twin Barrels (BURST-FIRE)**: ~28 DPS (consistent double-tap, reliable single-target)

*Pool Weapons:*
- **Bayonet Rush (MELEE)**: ~35 DPS (high risk, high reward)
- **Mortar Burst (AOE)**: ~12 DPS (scales with density)
- **Arc Discharge (CHAIN)**: ~20 DPS (scales with chains)
- **Ember Shells (ORBIT)**: ~15 DPS (consistent field)
- **Blight Flask (DOT)**: ~18 DPS (zone control)
- **Seeker Rounds (BARRAGE)**: ~28 DPS (reliable homing)

**Testing Checklist**:
- Solo weapon should NOT trivialize first 5m
- Solo weapon SHOULD require synergy by 10m (2-3 passives)
- Transmutations should feel like power spikes (2-3x DPS from base)
- 2-weapon combos + 3+ passives: winnable but challenging

---

## Stat Resolution

All in `GameManager._recalculate_stats()`. Same system — percentage passives: `1.0 + level * per_level`. Flat passives: `0 + level * per_level`. Applied at fire time. Elemental affinity mods applied multiplicatively on top.

| Multiplier | Default | Passive | Affects |
|---|---|---|---|
| damage_mult | 1.0 | Gunpowder | All weapon damage |
| fire_rate_mult | 1.0 | Clockwork | All fire/pulse rates |
| proj_speed_mult | 1.0 | Quicksilver | Projectile speed, orbit spin |
| pierce_bonus | 0 | Birdshot | Pierce count, chain hops |
| move_speed_mult | 1.0 | Wind Vents | Player movement |
| pickup_range_mult | 1.0 | Lodestone | XP gem attraction radius |
| area_mult | 1.0 | Focusing Lens | AOE radius, orbit radius |
| proj_count_bonus | 0 | Extra Powder | Extra projectiles/orbiters |
| element_id | null | (affinity system) | Active elemental modifier |

---

## Enemy Scaling

Same linear-with-minutes system.

| Stat | Base (0m) | 5m | 10m | Formula |
|---|---|---|---|---|
| Per spawn | 1 | 3-4 | 6 | `1 + min * 0.5` |
| HP | 30 | 80 | 130 | `30 + min * 10` |
| Speed | 60 | 85 | 110 | `60 + min * 5` |
| Contact Dmg | 10 | 25 | 40 | `10 + min * 3` |
| XP Value | 5 | 15 | 25 | `5 + min * 2` |

Max enemies: 200. Spawn distance: 600px. Spawn interval: 1.0s.

### Enemy Flavor (Future)

*( Enemies are creatures/constructs that exist in this magical medieval world — not soldiers. The heroes are defending against hordes, not fighting an army. )*

- **Husks**: Basic shambling enemies. Former creatures corrupted by raw magic runoff. (current base enemy)
- **Ironclads**: Slow, armored. Alchemically hardened shells. (tank variant)
- **Wisps**: Fast, fragile, come in swarms. Pure magic fragments. (swarmer variant)
- **Hexborn**: Ranged attackers. Shoot bolts of unstable magic. (ranged variant)
- **Splitters**: Mid-size enemies that burst into 2-3 smaller Wisps on death. (splitting variant)

---

## XP & Leveling

Same system with one addition — **elemental affinities appear in the level-up pool**.

- **Curve**: `10 * level^1.3`
- **Level-up choices**: 3 random from: new weapon, weapon upgrade, new passive, passive upgrade, elemental affinity
- **Rerolls**: 3/run (infinite in god mode)
- **Inventory**: 6 weapon slots, 6 passive slots, 1 element slot

### Elemental Affinity in Level-Up Pool

- Affinities appear as a 7th category alongside weapons/passives
- Picking an affinity replaces any existing one (only 1 active)
- Each affinity shows its stat modifiers and special effect on the card
- Affinity cards have a distinct visual treatment (elemental color border + icon)
- Lower weight in pool than weapons/passives (should show up every ~3 levels on average)

### Transmutation Auto-Trigger

Same as before: weapon reaches L5 AND paired passive is owned (any level). Weapon replaces itself in inventory with transmuted version.

---

## Architecture

Same autoload + signal bus architecture. No changes to core systems needed for the re-theme — it's cosmetic, narrative, and the affinity system is the only new mechanic.

| Name | Purpose |
|---|---|
| SignalBus | Global event bus |
| GameManager | State, HP, XP, leveling, inventories, stat mults, god mode, **active affinity** |
| PoolManager | Generic object pooling |
| AudioManager | SFX playback, UI button sound wiring |
| UiTheme | Code-built game-wide Theme |

### Physics Layers
1=Player, 2=Enemies, 3=Player Projectiles, 4=Pickups, 5=Enemy Projectiles (reserved)

### Pools
| Name | Scene | Count |
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

### Key Patterns
- `distance_squared_to` for nearest-enemy searches
- UI panels use `PROCESS_MODE_ALWAYS` to work while paused
- Enemy spawner uses manual delta accumulator
- Tweens for flash effects (not await)
- Pooled entities: `process_mode=DISABLED`, `visible=false` when released
- Entities removed from groups on release, re-added on acquire

---

## UI/UX Flows

### Main Menu
- Title: "Mortar and Pistol"
- Buttons: `Start Game`, `Settings`, `Exit`

### Character Select (NEW)
- 4 hero cards arranged horizontally
- Each shows: portrait area, name, starting weapon, element icon, passive description
- Click to select, confirm button starts run
- Visual style: same pixel-border card treatment as website

### HUD (In-Game)
- **Top-left**: Player HP bar with current/max
- **Top-center**: Timer (MM:SS)
- **Top-right**: Level + XP bar
- **Bottom-left**: Active element indicator (icon + color border, "None" if no affinity)
- **Bottom-center**: Inventory preview (6 weapons, 6 passives)
- **Bottom-right**: Rerolls remaining

### Level-Up Panel
- Same 3-card layout
- **New**: Affinity cards have a distinct border color matching the element
- **New**: Affinity cards show "+Fire" / "+Earth" etc. with stat breakdown

### Game Over / Victory Panels
- Same as before but title reads "Mortar and Pistol" branding

---

## Roadmap

| Phase | Status | Summary |
|---|---|---|
| A1: Core Loop | DONE | Movement, auto-weapons, spawning, XP/leveling, game over |
| A2: Weapon Archetypes | DONE | 4 types, 6 passives, 4 evolutions, HUD, rerolls |
| A3a: New Weapons | DONE | 6 base weapons, 8 passives, 6 evolutions |
| A3a-fix: Core Audit | DONE | 17-bug audit and fix pass |
| A3b-UI: UI Polish | PARTIAL (~40%) | Ornate Kenney panels/buttons/slots, icons, color-coded cards, dividers |
| A3b-VFX: Gameplay Visuals | PARTIAL (~50%) | Base weapon VFX done (6/6). Entity sprites still planned. |
| **R1: Re-Theme** | **DONE** | Renamed all weapons/passives/evolutions to M&P theming. Updated UI text, menu title, card descriptions. |
| **R2: Character Select** | **DONE** | 4 heroes with exclusive weapons. Character select screen. Soft-archived pool weapons. Hero-specific color tint. |
| **R3: Elemental Affinities** | **PLANNED** | Element system in GameManager, affinity cards in level-up pool, stat modifiers applied to weapons. Stretch: unique weapon×element interactions. |
| **A3c: Movement & Arena** | **PLANNED** | Dodge/dash mechanic, breakable crates, alchemical braziers, arena improvements |
| **A3d: Bosses & Elites** | **PLANNED** | Elite enemy variants, Iron Warden (5:00), Storm Weaver (10:00) |
| **A3e: Audio Overhaul** | **PLANNED** | Per-weapon SFX, pitch ramping, kill variants, boss audio, dash sound |
| **A4: Stats & Balance** | **PLANNED** | End-of-run stats screen, per-weapon DPS tracking, DPS balance, win condition |
| **A5: VFX Clarity** | **PLANNED** | VFX budget system, z-index layering, screen shake budget, visual clarity rules |
| B1: Art & Effects | FUTURE | Pixel art, entity sprites, evolution VFX, screen juice |
| **B2: Meta Progression (The Forge)** | **FUTURE** | Arcane Dust currency, permanent upgrades, achievement unlocks, forge UI |
| B3: Maps & Variants | FUTURE | Multiple arenas, environmental hazards, map-specific mechanics |

### R1: Re-Theme (Estimated Scope)

**Pure rename pass — no gameplay changes.** Can be done in one session.

- `weapons_db.gd`: Rename all weapon names and descriptions
- `passives_db.gd`: Rename all passive names and descriptions
- `evolution_db.gd`: Rename all evolution names
- `main_menu.gd` / main menu scene: Update title to "Mortar and Pistol"
- `level_up_panel.gd`: Update card text generation if hardcoded
- `DESIGN.md`: Already done (this document)
- HUD weapon/passive labels: Should auto-update from resource names

### R2: Character Select (Estimated Scope)

- New `CharacterData` resource class (name, starting_weapon_id, passive_id, element, color, description)
- `characters_db.gd` with 4 hero definitions
- 4 new `WeaponData` entries for character-exclusive weapons (Bolt Rifle, Scatter Flask, Powder Keg, Twin Barrels)
- New weapon behaviors in `weapon_manager.gd`: PIERCING (line pierce), BURST (split-on-hit), MINE (delayed positional AOE), BURST-FIRE (rapid sequential shots)
- New `character_select.tscn` and `character_select.gd` scene
- GameManager: store selected character, apply starting weapon + passive + color on run start
- Main menu → character select → game flow
- New pool registrations for character weapon effects (if needed)

### R3: Elemental Affinities (Estimated Scope)

- `ElementData` resource class (name, color, damage_mod, fire_rate_mod, special_effect description)
- `elements_db.gd` with 7 element definitions
- GameManager: `active_element: ElementData`, applied in `_recalculate_stats()`
- Level-up panel: Element cards in the pool (lower weight, distinct visual)
- HUD: Element indicator widget
- Stretch: unique weapon×element interaction code in each weapon type

---

## Future Content Ideas

### Weapons
- **Blunderbuss Spread** (SHOTGUN) — wide-angle burst, high close-range damage, evo: Dragon's Breath
- **Grapple Hook** (UTILITY) — pulls XP gems and damages enemies on retract, evo: Chain Whip
- **Mine Layer** (TRAP) — drops alchemical mines at player position, evo: Cluster Mine
- **Wind Cannon** (KNOCKBACK) — pushes enemies away in a cone, evo: Hurricane

### Passives
- **Crown** (xp_mult) +10%/level, max +50%
- **Iron Plating** (max_hp_bonus) +20/level, max +100
- **Alchemist's Flask** (heal_on_kill) small HP on kill
- **Smoke Charge** (dodge) brief invincibility on dash (if dash is added)

### Enemy Variants
See "Enemy Flavor" section above.

### Bosses (Every 5 Min)
- **The Iron Warden** (5:00) — summons Ironclad minions, ground slam AoE
- **The Storm Weaver** (10:00) — dash-and-trail attacks, spawns Wisps
- **The Hive Mother** (15:00 — final boss before victory) — spawns Splitters, poison clouds, vacuum pull

---

## Asset Inventory

*(Same assets available — re-theming doesn't require new assets, just different use of existing ones.)*

### Audio — Currently In Use

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
| sfx_ui_close | kenney_digital-audio/Audio/lowDown.ogg | Panel close |

### Textures — In Use
- **kenney_fantasy-ui-borders** (5 of 282): Panel borders, buttons, slot frames, dividers
- **kenney_particle-pack** (~10 of 193): Weapon/passive icons
- **kenney_scribble-platformer** (~7 of 212): Weapon/passive icons
- **superpowers/ninja-adventure** (2 of 253): Weapon/passive icons

### Textures — Available for M&P Theme
- **kenney_board-game-icons** (513 files): Swords, shields, potions, guns, crowns — ideal for M&P weapon/passive icons
- **kenney_rune-pack** (667 files): Rune glyphs — potential element affinity icons
- **kenney_tiny-dungeon** (136 files): 16x16 medieval tiles — potential entity sprites
- **kenney_splat-pack** (73 files): Tintable splats — AoE zones, death effects

---

## Edge Cases & Safety

*(Same as original — all fixes from A3a-fix audit still apply. See `archive/DESIGN_archive.md` for full details.)*

Key guards: `_is_dead` flag, pool double-release check, `pending_levels` counter, `on_hit(hit_enemy)` splash exclusion, settings persistence via ConfigFile.

---

## Known Issues (Resolved — A3a-fix)

See `archive/DESIGN_archive.md` for the full 17-item audit table. All fixes remain in place.

---

## Workshop: Character Weapons & Upgrade Synergy (DECIDED)

*Design decisions finalized from playtest feedback. Answers locked in — ready for implementation.*

---

### W1: Wizard's Bolt Rifle is boring

**Problem**: The Bolt Rifle is functionally just a projectile with high pierce. It looks and feels like a faster version of any other projectile weapon. There's no visual or mechanical identity.

**Proposed Change**: Rework to a **BEAM** weapon type — a continuous or pulsed laser-like line instead of a projectile.

**Decisions**:

> **Q1**: **Pulsed** — brief flash/line ~0.2s, hits everything in the line, then cooldown. Fire rate controls DPS.
>
> **Q2**: **Pierce count** (3-7 enemies). Not infinite — keeps scaling meaningful.
>
> **Q3**: **Fixed direction** — fires toward nearest enemy's position at fire time. Can miss if enemy moves. Rewards positioning.

---

### W2: Scatter Flask is broken — needs lobbing arc & on-impact detonation

**Current Bug**: The flask flies in a straight line to the enemy's *position at fire time*. It has no collision detection — it only shatters when it reaches that coordinate (or times out). If the enemy moves, the flask passes through them and detonates in empty space. The shrapnel then sprays from the wrong location.

**Proposed Fix (2 parts)**:

1. **On-impact detonation**: Add a collision `Area2D` to the flask so it shatters when it actually *hits* an enemy, not when it reaches a coordinate.

2. **Lobbing arc**: Instead of flying in a straight line, the flask follows a parabolic arc (like a grenade). This would make it visually distinct from every projectile in the game and match the "thrown flask" fantasy. Mechanically: the flask's Y position follows a sine/parabola curve while the X/Z path travels toward the target. A shadow/circle stays on the ground to show where it will land.

**Decisions**:

> **Q4**: **Both** — flask shatters on first enemy touch AND flies to target area if it misses. Collision detection for direct hits, with tracking of enemy's current position (not snapshot) for the fallback flight path.
>
> **Q5**: **Yes, build a reusable lob system.** Parabolic arc, ground shadow/indicator, reusable for future thrown weapons (grenades, potions, etc).
>
> **Q6**: **360° burst** — shrapnel sprays evenly around the shatter point.

---

### W3: Powder Keg — fuse visual & AOE clarity

**Current Issue**: The fuse technically works (0.8s timer) but the visual feedback is a tiny 12x2px yellow bar pulsing with a sine wave — nearly invisible at game scale. The detonation radius (90px) is unclear — enemies don't know to avoid it and the player doesn't know how close they need to be.

**Proposed Improvements**:
- **Fuse countdown ring**: A shrinking circle around the keg that closes in over the fuse duration, then flashes white on detonation
- **Ground danger zone**: A translucent red/orange circle showing the blast radius while the fuse is active (so the player can see exactly what the keg will hit)
- **Screen shake on detonation** (small, proportional to damage)

**Decisions**:

> **Q7**: **Scaling** — start at 1.5s, reduce per upgrade level to 0.8s at Lv5. Gives early-game visual clarity, late-game speed.
>
> **Q8**: **Yes, multi-keg** — Extra Powder drops 2+ kegs at once.

---

### W4: Upgrade Synergy — passives should always matter

**Core Problem**: The current 8 passives are designed around projectile-centric weapons. When the character weapons have different mechanics (MINE, BEAM, BURST), many passives become "dead picks." Currently:

| Passive | Bolt Rifle | Scatter Flask | Powder Keg | Twin Barrels |
|---------|:----------:|:-------------:|:----------:|:------------:|
| Gunpowder (damage) | YES | YES | YES | YES |
| Clockwork (fire rate) | YES | YES | YES | YES |
| Quicksilver (proj speed) | YES | YES | **NO** | YES |
| Birdshot (pierce) | YES | **NO** | **NO** | YES |
| Wind Vents (move speed) | YES | YES | YES | YES |
| Lodestone (pickup range) | YES | YES | YES | YES |
| Focusing Lens (area) | **NO** | **NO** | YES | **NO** |
| Extra Powder (proj count) | **NO** | YES | **NO** | **NO** |

Bombardier is the worst case — 3 of 6 weapon-affecting passives do literally nothing.

**Two approaches (not mutually exclusive)**:

**Approach A — Make every passive do SOMETHING for every weapon:**
- Quicksilver on Powder Keg: faster fuse countdown (burn faster = detonate sooner)
- Birdshot on Scatter Flask: shrapnel pierces 1 enemy each instead of dying on contact
- Birdshot on Powder Keg: keg explosion sends out piercing shrapnel fragments
- Focusing Lens on Bolt Rifle/Twin Barrels: wider hitbox on projectiles, or for beam: wider beam
- Extra Powder on Bolt Rifle: fires 2 beams in a V pattern (or 2 sequential bolts)
- Extra Powder on Powder Keg: drops 2 kegs side by side
- Extra Powder on Twin Barrels: adds a 3rd shot to the burst (triple-tap)

**Approach B — Smart pool filtering:**
Only offer passives that actually affect your current loadout. If you have no weapons that use `proj_speed_mult`, don't offer Quicksilver. Guarantee at least 1 of the 3 choices is relevant to your weapons.

**Decisions**:

> **Q9**: **Both A+B** — Add creative synergies so every passive does something for every weapon (Approach A), AND use smart filtering to guarantee at least 1 relevant choice (Approach B).
>
> **Q10**: Approved synergies:
> - Extra Powder on Powder Keg: drops 2+ kegs — **YES, great**
> - Birdshot on Powder Keg: post-explosion shrapnel — **YES, decent**
> - Quicksilver on Powder Keg: decreases time between drops — **YES** (reframed from "faster fuse" to "faster drop rate")
> - Focusing Lens on beam weapon: wider beam — **YES, obvious**
>
> **Design philosophy**: Come up with weapons first, then add passives that make those weapons more fun. Passives should be the *result* of making weapons fun, not the other way around.

---

### W5: Level-Up Pool — guaranteeing meaningful choices

**Current State**: Since all pool weapons are archived, the level-up only offers:
- Character weapon upgrades (1 option, until it hits Lv5)
- New passives (8 options, filling 6 slots)
- Passive upgrades (for owned passives)

Once the character weapon is maxed and you have 6 passives, the only choices are passive upgrades. This gets stale and there's no build variety between runs of the same character.

**Decisions**:

> **Q11**: **Universal** — all heroes access all pool weapons when they get un-archived. More variety per run.
>
> **Q12**: **Yes, weapon talents** — unique weapon-specific upgrades in the level-up pool (e.g., "Bolt Rifle: Forked Shot", "Powder Keg: Cluster Charge"). These are like mini-evolutions that only appear for your character weapon.
>
> **Q13**: **No skip option** — forced to pick from the 3 choices. No gold/currency alternative.

---

### W6: XP Vacuum Pickup

**Request**: A dropped item that vacuums up all XP orbs currently on the map.

**Current State**: XP gems never despawn on their own (no lifetime timer). However, the pool has 100 slots — if more than 100 gems exist on-screen, the pool manager may recycle the oldest ones to service new drops. This can look like gems "disappearing."

**Proposed Implementation**:
- New pickup type: **Lodestone Pulse** (or "XP Magnet")
- Spawns periodically (like heal pickups, random interval 30-60s) or from special enemies
- On collection: instantly attracts ALL XP gems on the map toward the player
- Implementation: iterate all nodes in `"pickups"` group, call `start_attraction(player)` on each XP gem

**Decisions**:

> **Q14**: **Ground pickup** — walk over it to trigger, like heal pickups. Spawns periodically from special enemies or random interval.
>
> **Q15**: **Yes, increase pool + vacuum** — increase XP gem pool size (prevent disappearing) AND add the vacuum pickup to help clear the field.

---

### W7: Future-proofing for "a metric ass load of weapons"

**Context**: The current system has 10 weapons (4 character + 6 pool). The plan is to add many more. Some architecture questions worth deciding now:

**Decisions**:

> **Q16**: **Class-per-type** — each weapon type gets its own script/class that handles its own firing logic. The enum stays for identification but the match statement dispatch is replaced by polymorphism. More scalable for 20+ weapon types.
>
> **Q17**: **New types freely** — keep adding new weapon types as needed. No need to force weapons into existing categories. The class-per-type architecture (Q16) makes this painless.
>
> **Q18**: **Data-driven** — passives declare which stat_keys they affect, weapons declare which stat_keys they use, synergy is automatic. Makes adding new passives and weapons trivial.

---

*Implementation priority: W7 architecture refactor (class-per-type + data-driven synergy) should come FIRST since it changes the foundation. Then W2 (fix Scatter Flask with lob system), W1 (Wizard beam), W3 (Powder Keg visual), W4 (synergy), W6 (XP vacuum).*

---

## Dodge / Dash Mechanic

**Why**: The genre's most meaningful extra mechanic for skill expression. Currently the game has zero movement abilities beyond base speed — this limits the skill ceiling and makes positioning less interesting. A dash lets the game include more threatening attacks (ranged enemies, boss telegraphs) without feeling unfair.

**Input**: `Space` / controller bumper. One input, no complexity.

### Alchemical Blink

A short, fast positional dash that fits the M&P theming. The player's character briefly dissolves into alchemical smoke, reappears a short distance ahead. Not a teleport — the player moves through the space (can still be hit mid-dash unless invincibility frames are active).

| Stat | Value | Notes |
|---|---|---|
| Distance | 100px | ~2x character width, enough to escape a ring but not cross the screen |
| Duration | 0.12s | Fast enough to feel instant, slow enough to animate |
| Cooldown | 2.0s | Prevents spam, rewards timing |
| I-frames | First 0.08s | Brief invincibility window — skilled players can dash through attacks |

### Character Variations

Each hero's dash has a subtle twist that matches their identity (cosmetic + minor mechanical):

| Hero | Dash Name | Twist |
|---|---|---|
| Wizard | Arc Step | Leaves a brief lightning trail that damages enemies passed through (5 dmg) |
| Alchemist | Caustic Roll | Drops a small poison puddle at the start position (2 dmg/tick, 1.5s) |
| Bombardier | Blast Jump | Small knockback on enemies near start position (no damage, just pushback) |
| Assassin | Smoke Dash | 30% longer dash distance (130px). No extra effect — pure speed |

### Passive Interaction

- **Wind Vents**: -0.3s cooldown per level (min 0.5s at Lv5)
- **Smoke Charge** (future passive): Adds full invincibility during dash + 0.5s after

### Implementation Notes

- Direction: toward mouse cursor / right-stick direction / movement direction (fallback)
- Cannot dash while paused or during level-up
- Collision: player physics body moves along the dash vector, not teleported (preserves wall collisions if walls are added)
- Animation: scale.x squeeze on start (0.6x), stretch at end (1.3x), tween back. Spawn 3-4 afterimage sprites along path that fade over 0.3s
- Signal: `SignalBus.player_dashed` for future interactions

---

## Boss & Elite Encounters

**Why**: The 15-minute run has no pacing punctuation. Boss encounters create milestone moments that test the build, reward players, and break up the wave monotony. Elites add micro-challenges between bosses.

### Elites

Elites are modified regular enemies with enhanced stats and a single extra mechanic. They spawn naturally mixed into waves starting at 3:00.

| Stat | Modifier |
|---|---|
| HP | 5x base |
| Speed | 0.8x base (slower, more deliberate) |
| Size | 1.5x scale |
| XP Value | 10x base |
| Contact Dmg | 1.5x base |

**Elite Types** (one mechanic each):

| Type | Visual | Mechanic |
|---|---|---|
| Shielded | Gold border glow | Takes 50% reduced damage from the front. Must be flanked or use AoE |
| Volatile | Pulsing red | Explodes on death (80px radius, 15 dmg). Rewards keeping distance |
| Spawner | Green particle trail | Spawns 2 Wisps every 3s while alive. Kill fast or get swarmed |
| Magnetic | Purple vortex effect | Pulls nearby XP gems toward itself (steals your XP if you don't kill it) |

**Spawn Rules**:
- 3:00-7:00: 1 elite per wave, random type
- 7:00-12:00: 1-2 elites per wave
- 12:00-15:00: 2-3 elites per wave
- Elites always drop a guaranteed heal pickup on death

### Bosses

Bosses spawn at 5:00 and 10:00. They pause regular wave spawning for the duration of the fight. A boss health bar appears at the top of the screen.

**Critical design rule**: Bosses ALWAYS spawn support enemies so that horde-focused builds (AoE, chain, orbit) remain effective. No pure single-target DPS checks.

#### The Iron Warden (5:00)

| Stat | Value |
|---|---|
| HP | 800 + (enemies_killed * 0.5) |
| Speed | 40 (slow, lumbering) |
| Contact Dmg | 30 |
| Size | 3x enemy scale |

**Attacks** (cycles every 8s):
1. **Ground Slam**: Telegraphed 1.5s (red circle), 120px radius AoE around self, 25 dmg. Spawns 4 Ironclad minions from the slam point
2. **Shield Wall**: Raises shield for 3s, 75% damage reduction. Minions become aggressive (speed +50%) during this phase
3. **Charge**: Dashes toward player at 200 speed for 0.5s. Leaves a damage trail (10 dmg/tick, 2s)

**Drop**: Guaranteed Lodestone Pulse + bonus XP (200 flat)

#### The Storm Weaver (10:00)

| Stat | Value |
|---|---|
| HP | 1500 + (enemies_killed * 0.5) |
| Speed | 80 (fast, erratic) |
| Contact Dmg | 20 |
| Size | 2.5x enemy scale |

**Attacks** (cycles every 6s):
1. **Wisp Burst**: Spawns 8 Wisps in a ring around itself
2. **Lightning Trail**: Dashes in a zigzag pattern (3 zags), leaving damaging lightning zones (8 dmg/tick, 3s duration, 40px wide)
3. **Static Field**: 2s charge-up, then 200px radius pulse that pushes player outward and deals 15 dmg. Brief stun (0.3s)

**Drop**: Guaranteed Lodestone Pulse + bonus XP (400 flat) + free level-up

### Boss Implementation Notes

- Boss HP scales with `enemies_killed` so builds that farmed well face a tougher check (prevents trivializing)
- Regular wave spawning resumes when boss HP reaches 0
- Boss arena: no walls, same infinite space, but a visual border ring appears (cosmetic only) to mark the fight zone
- If player dies during boss, normal Game Over — no special treatment

---

## End-of-Run Stats

**Why**: Players can't tell which upgrades actually worked during the chaos. Detailed stats improve player understanding, satisfaction, and learning. The video calls this "one of the strongest practical recommendations."

### Stats Tracked (Per Run)

**Combat Stats**:
- Total damage dealt
- Total enemies killed
- Damage taken
- Healing received
- Highest hit (single biggest damage number)
- Kill streak (most kills in 5s window)

**Per-Weapon Breakdown** (the key feature):
- Damage dealt by each weapon (with % of total)
- Kills attributed to each weapon
- Displayed as a ranked list: #1 weapon at top, bar chart showing relative contribution
- Transmuted weapons show pre/post transmutation stats separately

**Per-Passive Breakdown**:
- Which passives were equipped and at what level
- Estimated stat contribution (e.g., "Gunpowder Lv3: +30% damage")

**Build Summary**:
- Active element (if any)
- Final weapon loadout (with levels)
- Final passive loadout (with levels)
- Rerolls used / total

**Progression Stats**:
- Time survived
- Final level reached
- Total XP collected
- XP gems lost (pool recycled before pickup)
- Bosses defeated (0/1/2)
- Elites killed

### UI Layout

The Game Over / Victory panel expands into a tabbed view:

**Tab 1 — Summary** (default): Time, level, kills, damage dealt (the quick glance)

**Tab 2 — Weapons**: Per-weapon damage bar chart. Each bar labeled with weapon name, total damage, kill count. Color-coded to weapon color. Sorted by damage descending

**Tab 3 — Build**: Full loadout display — weapons, passives, element. With stat contribution breakdown

### Implementation Notes

- `GameManager` accumulates stats in a `run_stats: Dictionary` updated via signals
- Each weapon strategy emits damage dealt through `SignalBus.damage_dealt(weapon_id, amount)`
- Kill attribution: the weapon that dealt the killing blow gets the kill credit
- Stats dictionary reset on run start, persisted to `run_stats` on run end
- No persistence between runs (for v1) — stats are session-only
- Future: best-run leaderboard per character (local only)

---

## Meta Progression — The Forge

**Why**: The core loop is inherently repetitive. Without between-run progression, players exhaust novelty in a handful of runs. Meta progression makes every run feel meaningful, even losses.

### Currency: Arcane Dust

Earned at the end of every run (win or lose). Amount based on performance:

| Source | Amount |
|---|---|
| Base (per run) | 10 |
| Per minute survived | 5 |
| Per 100 enemies killed | 3 |
| Per boss defeated | 25 |
| Victory bonus | 50 |
| First victory (per character) | 100 |

Typical payout: loss at 5min = ~45 dust, loss at 10min = ~80 dust, victory = ~150-200 dust.

### The Forge (Between-Run Shop)

Accessible from the main menu. A grid of permanent upgrades purchased with Arcane Dust. Upgrades apply to ALL future runs on ALL characters.

**Stat Enhancements** (5 levels each):

| Enhancement | Per Level | Max | Cost/Level |
|---|---|---|---|
| Tempered Barrels | +5% damage | +25% | 20 / 40 / 70 / 110 / 160 |
| Oiled Mechanisms | +4% fire rate | +20% | 20 / 40 / 70 / 110 / 160 |
| Alchemist's Vigor | +10 max HP | +50 HP | 15 / 30 / 50 / 80 / 120 |
| Swift Boots | +4% move speed | +20% | 15 / 30 / 50 / 80 / 120 |
| Magnetic Core | +10% pickup range | +50% | 10 / 20 / 35 / 55 / 80 |
| Lucky Loadout | +1 reroll per run | +5 | 25 / 50 / 80 / 120 / 170 |
| XP Attunement | +5% XP gain | +25% | 15 / 30 / 50 / 80 / 120 |

Total cost to max everything: ~2,800 Arcane Dust (~15-20 runs)

### Unlockables (Achievement-Based)

These unlock new content, not stat boosts. Achieved through gameplay milestones:

| Unlock | Requirement | Reward |
|---|---|---|
| Pool Weapons | Complete 1 run (any result) with each hero | Un-archives all 6 pool weapons into the level-up pool |
| Weapon Talents | Reach Lv5 on character weapon 3 times | Unlock talent upgrades for that weapon in the level-up pool |
| Hard Mode | Win with any character | Unlocks Hard difficulty (1.5x enemy HP/speed/damage, 1.5x Arcane Dust) |
| The Alchemist's Journal | Kill 1000 total enemies | Unlocks per-weapon damage stats in the end-of-run screen |
| Elemental Mastery | Win a run with each element active | Unlocks dual-element attunement (pick 2 elements, halved effects each) |
| True Ending | Defeat Storm Weaver on Hard Mode | Unlocks a 20-minute run option with a third boss at 15:00 |

### Implementation Notes

- Arcane Dust stored in `user://save.cfg` via ConfigFile (same pattern as settings)
- Forge enhancements applied in `GameManager._recalculate_stats()` as a base modifier layer (before passives)
- Unlockables tracked as a `Dictionary` of `achievement_id: bool` in save file
- Achievement checks run at end-of-run via a simple conditions list
- The Forge UI: new scene accessible from main menu, grid of upgrade cards with level indicators and buy buttons
- God Mode runs do NOT earn Arcane Dust (prevents farming)

---

## Arena & Map Design

**Why**: Players need reasons to move beyond dodging and picking up XP. A single empty arena gets monotonous. Environmental features add decision-making and exploration incentive.

### V1 Arena Improvements

The arena remains a single open space (no map transitions), but gains interactive elements:

#### Breakable Crates

Scattered across the arena. Destructible by player weapons.

| Property | Value |
|---|---|
| Count | 8-12 on map at once |
| HP | 15 (dies in 1-2 hits from most weapons) |
| Respawn | New crate spawns 15-20s after one is destroyed |
| Visual | Small wooden crate, 16x16px, slight pixel wobble when hit |

**Drop Table**:
- 60%: XP cluster (3-5 gems)
- 20%: Heal pickup
- 15%: Lodestone Pulse (XP vacuum)
- 5%: Arcane Dust bonus (+5, only if meta progression is active)

#### Alchemical Braziers

Stationary environmental objects that provide a temporary buff when walked into. Consume on use, respawn elsewhere after 45s.

| Brazier | Color | Effect | Duration |
|---|---|---|---|
| Speed Brazier | Cyan glow | +30% move speed | 8s |
| Power Brazier | Red glow | +20% damage | 8s |
| Shield Brazier | Gold glow | Block next hit (any damage) | Until hit or 15s |

**Spawn Rules**:
- 2 braziers active at once (random type)
- Always spawn at least 200px from player, 300px from each other
- Visual: small animated flame on a stone pedestal (8x16px, 2-frame flicker)

#### Environmental Hazards (Stretch)

- **Corrupted Zones**: Slow-moving purple patches that deal 3 dmg/s if stood in. Spawn at 8:00+. 1-2 on map, drift slowly. Force player to reposition
- **Ley Lines**: Glowing floor lines that appear briefly (3s visible, 10s hidden). Standing on one while it's active boosts fire rate +15%

### Map Boundaries

Currently the arena is effectively infinite (enemies spawn at 600px). For v1:
- Keep the infinite space (no walls)
- Add a subtle radial vignette that darkens at ~800px from center to gently guide the player toward the action
- Crates and braziers only spawn within 500px of center

### Future: Multiple Arenas (B2+)

- **The Workshop**: Tight corridors, more crates, favors melee/AoE builds
- **The Wasteland**: Wide open, fewer obstacles, favors ranged/homing
- **The Ley Nexus**: Many ley lines, environmental buffs are stronger and more frequent

---

## Audio Feedback Design

**Why**: Audio is half the "juice." Current placeholder jsfxr sounds are functional but flat. Good audio makes kills satisfying, pickups rewarding, and the power fantasy tangible.

### Audio Escalation Principles

1. **Pitch ramping on rapid XP pickup**: When collecting XP gems in rapid succession (<0.3s apart), each successive pickup plays at a higher pitch. Reset after 0.5s gap. Cap at +8 semitones (about 1.6x pitch). Creates a satisfying ascending tone cascade during magnet/vacuum effects
2. **Kill sound variation**: 3-4 variants of the kill sound, randomly selected. Prevents repetitive single-sound fatigue
3. **Overkill feedback**: When a single hit deals 3x+ an enemy's remaining HP, play a beefier death sound (louder, lower pitch, slight reverb). Makes transmuted weapons feel devastating
4. **Per-weapon fire sounds**: Each weapon type should have a distinct fire SFX that matches its fantasy. Currently all weapons share `sfx_shoot`

### Weapon-Specific SFX (Target)

| Weapon | Fire Sound | Hit Sound |
|---|---|---|
| Bolt Rifle | Sharp electric crack | Sizzling zap |
| Scatter Flask | Glass shatter + liquid splash | Wet splat per shrapnel |
| Powder Keg | Heavy thud (drop) + deep boom (detonate) | Crunch/debris |
| Twin Barrels | Quick double pop | Light metallic ping |
| Bayonet Rush | Blade whoosh | Slash/cut |
| Mortar Burst | Hollow thump | Low rumble |
| Arc Discharge | Electric buzz | Chain crackle |
| Ember Shells | Persistent low hum (loop) | Fire hiss on contact |
| Blight Flask | Acid sizzle (throw) | Bubbling (zone tick) |
| Seeker Rounds | Whistling launch | Impact thud |

### Audio Events to Add

| Event | Sound Design | Priority |
|---|---|---|
| Dash | Quick whoosh + fabric flutter | High |
| Boss spawn | Deep horn/rumble + screen effect | High |
| Boss defeat | Triumphant brass stab + shatter | High |
| Elite spawn | Low growl/roar (brief) | Medium |
| Transmutation | Ascending magical chime + metallic ring | High |
| Brazier pickup | Warm harmonic tone | Medium |
| Crate break | Wood splinter crack | Medium |
| Level milestone (5/10) | Subtle gong or deep tone | Low |

### Implementation Notes

- `AudioManager` gains a `play_pitched(sfx_key, pitch_scale)` method
- XP pitch tracking: `_xp_chain_count` counter, incremented on pickup, reset by a 0.5s timer
- Kill variants: store arrays of AudioStreamWAV per SFX key, random index selection
- Per-weapon sounds: add `fire_sfx` and `hit_sfx` fields to `WeaponData` resource
- All sounds generated with jsfxr or sfxr (consistent with existing audio pipeline)
- Volume ducking: when >10 sounds play in one frame, reduce volume by 3dB per extra sound to prevent clipping

---

## VFX Priority & Visual Clarity

**Why**: With 3-4 weapons firing simultaneously + 200 enemies + transmuted VFX, the screen can become unreadable visual noise. Need a system to keep chaos readable.

### VFX Budget System

Each VFX effect has a **priority tier**. When the total active particle count exceeds a threshold, lower-priority effects are culled or simplified.

| Tier | Examples | Culling Behavior |
|---|---|---|
| Critical (never cull) | Player character, boss, health bars, HUD | Always visible |
| High | Active weapon projectiles, dash trail, boss attacks | Reduce particle count by 50% at budget cap |
| Medium | Weapon impact effects, enemy death bursts | Skip entirely when budget exceeded |
| Low | Ambient particles, orbiter trails, passive glow effects | First to be culled |

**Budget Threshold**: 150 active GPUParticles2D emitters. Above this, start culling from Low tier up.

### Visual Clarity Rules

1. **Player visibility**: Player character always renders on top (z-index above all effects). A subtle dark circle (8px radius, 30% opacity) under the player ensures visibility against any background
2. **Enemy readability**: Enemy ColorRects (or future sprites) render above weapon effect particles but below projectile sprites. Enemies should never be fully obscured by friendly VFX
3. **Damage flash priority**: Enemy hit flash (white tween) always shows regardless of VFX budget
4. **Color separation**: Player weapons use warm/bright colors. Enemy attacks (future) use red/dark colors. Environmental hazards use purple. Pickups use green/gold. No overlap in color families between hostiles and friendlies
5. **Screen shake budget**: Maximum 3px displacement. Simultaneous shake sources don't stack — highest magnitude wins. Shake decays over 0.15s

### Z-Index Layering

| Layer | Z-Index | Contents |
|---|---|---|
| Ground effects | 0 | Toxic zones, fire patches, ley lines, shadows |
| Pickups | 5 | XP gems, heal pickups, lodestone pulse, crate drops |
| Enemies | 10 | All enemy types, elites, boss |
| Player | 15 | Player character, dash afterimages |
| Projectiles | 20 | All weapon projectiles, shrapnel, seekers |
| Overhead effects | 25 | Damage numbers, level-up flash, boss HP bar |
| HUD | 100 | All UI elements |

### Implementation Notes

- `VFXManager` autoload (new) tracks active emitter count via signal callbacks
- Each GPUParticles2D registers with VFXManager on `emitting = true`, deregisters on `finished`
- At budget cap, VFXManager emits `vfx_budget_exceeded` signal; low-tier emitters listen and skip/simplify
- Alternative simple approach for v1: just reduce `amount` property on GPUParticles2D when enemy count > 150
