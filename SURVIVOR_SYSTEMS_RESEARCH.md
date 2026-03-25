# Survivor-Like Game Systems Research
### For Mortar and Pistol — Upgrade & Progression Rework

> Comprehensive analysis of how top survivor-like and run-based games handle weapons, passives, upgrades, meta progression, and character design.

---

## Table of Contents
1. [Vampire Survivors](#vampire-survivors)
2. [HoloCure](#holocure)
3. [Survivor.io](#survivorio)
4. [Brotato](#brotato)
5. [20 Minutes Till Dawn](#20-minutes-till-dawn)
6. [Halls of Torment](#halls-of-torment)
7. [Risk of Rain 2](#risk-of-rain-2)
8. [Hades](#hades)
9. [Cross-Game Comparison Matrix](#cross-game-comparison-matrix)
10. [Stats Under the Hood](#stats-under-the-hood)
11. [Key Patterns & Takeaways](#key-patterns--takeaways)
12. [Recommendations for Mortar and Pistol](#recommendations-for-mortar-and-pistol)

---

## Vampire Survivors

### Character System
- **50+ characters**, each with a unique starting weapon and stat bonuses
- Starting weapon is exclusive — no other character can obtain it
- Stat bonuses range from +10% MoveSpeed to +30% Might, etc.
- Characters cost gold to unlock (meta currency)
- Some characters have innate passives (e.g., bonus revival, enemy debuffs)

**Example Characters:**
| Character | Starting Weapon | Bonus |
|-----------|----------------|-------|
| Antonio | Whip | +20% Might, +0.5 Might/level |
| Imelda | Magic Wand | +10% EXP, +5%/10 levels |
| Gennaro | Knife | +1 Projectile |
| Arca | Fire Wand | -15% Cooldown |
| Mortaccio | Bone | +3 Projectile (at levels 20, 40, 60) |

### Weapons (Active Items)
- **Max 6 weapon slots**
- Weapons level from **Lv1 → Lv8** (8 levels)
- At Lv8 + correct passive + chest = **Evolution** (evolved weapon)
- Evolution replaces the base weapon; passive is consumed

**Weapon Categories:**
- Projectile (Knife, Magic Wand)
- Whip/Melee (Whip, Phiera Der Tuphello)
- Orbit (King Bible, Garlic)
- Area/Bomb (Santa Water, Lightning Ring)
- Beam (Runetracer)
- Retaliatory (Laurel — not quite, but defensive)
- Summon/Companion (Peachone, Ebony Wings)

### Passive Items
- **Max 6 passive slots**
- Passives level from **Lv1 → Lv5** (5 levels)
- Each passive affects a single stat

**All Passives:**
| Passive | Stat | Per Level |
|---------|------|-----------|
| Spinach | Might (damage) | +10% |
| Armor | Flat Damage Reduction | +1 |
| Hollow Heart | Max HP | +20% |
| Pummarola | HP Recovery | +0.2/sec |
| Empty Tome | Cooldown Reduction | -8% |
| Candelabrador | Area | +10% |
| Bracer | Projectile Speed | +10% |
| Spellbinder | Duration | +10% |
| Duplicator | Amount (projectile count) | +1 |
| Wings | Move Speed | +10% |
| Attractorb | Pickup Range | Flat increase |
| Crown | EXP Bonus | +8% |
| Luck | Luck | +10% |
| Greed | Greed (gold bonus) | +10% |
| Curse | Curse (enemy speed/HP/spawn) | +10% |
| Revival | Extra Lives | +1 |
| Tiragisu | Revives | +1 |
| Torrona's Box | Curse multiplier | special |

### Evolution System
- **Trigger:** Weapon at Lv8 + specific Passive at any level + open a Treasure Chest
- The chest performs the fusion automatically
- Evolved weapon replaces the base weapon; the passive is **not consumed** (keeps passive slot)
- Wait — CORRECTION: In VS, the passive IS kept (not consumed). The evolution just happens on top.

**Key Evolutions:**
| Weapon | + Passive | = Evolution |
|--------|-----------|-------------|
| Whip | Hollow Heart | Bloody Tear |
| Magic Wand | Empty Tome | Holy Wand |
| Knife | Bracer | Thousand Edge |
| King Bible | Spellbinder | Unholy Vespers |
| Fire Wand | Spinach | Hellfire |
| Garlic | Pummarola | Soul Eater |
| Santa Water | Attractorb | La Borra |
| Lightning Ring | Duplicator | Thunder Loop |
| Peachone + Ebony Wings | (both Lv8) | Vandalier |
| Phiera+Eight The Sparrow | Tiragisu | Phieraggi |

### Level-Up System
- On level up: **3 choices** (4 with Arcana or Crown bonus)
- Choices drawn from: new weapons, weapon upgrades, new passives, passive upgrades
- **Banish** — permanently remove an item from the pool (limited uses per run)
- **Reroll** — reshuffle the 3 choices (limited uses per run)
- **Skip** — take nothing (limited uses per run)
- Banish/Reroll/Skip use counts are upgradeable via meta progression
- Once all 6+6 slots are full, only level-up options for already-owned items appear
- At truly max (everything at max level), level-ups give gold instead

### Stats Under the Hood
| Stat | Description |
|------|-------------|
| **Might** | Damage multiplier (100% base) |
| **Armor** | Flat damage reduction |
| **Max HP** | Hit points |
| **Recovery** | HP/second regen |
| **Cooldown** | Weapon fire rate (lower = faster) |
| **Area** | Weapon hitbox/radius size |
| **Speed** | Projectile speed |
| **Duration** | How long effects last |
| **Amount** | Extra projectiles per attack |
| **MoveSpeed** | Character movement |
| **Luck** | Affects chest quality, item rarity |
| **Growth** | EXP multiplier |
| **Greed** | Gold multiplier |
| **Curse** | Enemy difficulty multiplier (more enemies, faster, more HP — but more drops) |
| **Magnet** | Pickup range |
| **Revival** | Extra lives |
| **Reroll/Banish/Skip** | Uses per run |

### Meta Progression (PowerUps)
- **Gold** earned during runs is spent on permanent stat bonuses
- Each stat can be upgraded multiple times (costs scale)
- Purchased from the main menu between runs

**PowerUps:**
| PowerUp | Max Level | Effect |
|---------|-----------|--------|
| Might | 5 | +5% per level (up to +25%) |
| Armor | 3 | +1 per level |
| Max HP | 3 | +10% per level |
| Recovery | 5 | +0.1/sec per level |
| Cooldown | 2 | -3% per level |
| Area | 2 | +5% per level |
| Speed | 2 | +5% per level |
| Duration | 2 | +5% per level |
| Amount | 1 | +1 projectile |
| MoveSpeed | 2 | +5% per level |
| Growth | 5 | +3% per level |
| Greed | 5 | +5% per level |
| Luck | 3 | +10% per level |
| Curse | variable | +10% per level |
| Reroll | 5 | +1 reroll per level |
| Banish | 5 | +1 banish per level |
| Skip | 5 | +1 skip per level |
| Revival | 1 | +1 extra life |

### Arcanas
- Special modifiers selected at the start of a run (and at 11-minute intervals)
- 22 Arcanas total, each fundamentally changes how a mechanic works
- Examples:
  - **Game Killer (I)**: Halves enemy HP but doubles enemy speed
  - **Tragic Princess (II)**: Hold movement to power up; stop to fire
  - **Awake (IV)**: Revival gives +10% Might per revive
  - **Slash (IX)**: Critical hits deal 3x damage
  - **Wicked Season (XI)**: Greed, Curse, Luck, Growth swap bonuses each minute
  - **Disco of Gold (XIV)**: Picking up gold heals 1 HP

### Treasure Chests
- Dropped by bosses and elite enemies at fixed time intervals
- Chest quality determined by luck and enemy tier
- Contains: gold, item level-ups, or triggers evolution if conditions are met
- Boss schedule: every 60 seconds a mini-boss wave, every 5 minutes a major boss

---

## HoloCure

### Character System
- **50+ characters** (Hololive VTubers), each with:
  - **Unique starting weapon** (exclusive, goes to Lv7)
  - **Special Attack** (active ability on ~30-60s cooldown)
  - **Base stat variations** (HP, ATK, SPD, CRT, Haste)
  - **Some have innate passives**

### Weapons
- **Max 6 weapon slots**
- Weapons level from **Lv1 → Lv7** (7 levels)
- Pool weapons available to all characters
- Starting weapons are character-exclusive

**Pool Weapon Types:**
- Orbit (Psycho Axe, BL Book)
- Projectile (Spider Cooking, CEO's Tears, Wamy Water)
- AOE/Bomb (Holo Bomb)
- Beam (Fan Beam)
- Ground/DOT (Plug Type Asacoco, Elite Lava Bucket)
- Boomerang (Cutting Board)
- Aura (Idol Song)
- Homing (Super Chat)
- Rain/Area (Credits)
- Bouncing (Bounce Ball)

### Stamps (Passives)
- **Max 6 stamp slots**
- Stamps level from **Lv1 → Lv7** (7 levels, same as weapons)

**Stamps:**
| Stamp | Stat |
|-------|------|
| Headphones | ATK (damage) |
| Study Glasses | SPD (proj speed) |
| Gorilla's Paw | CRT (crit chance) |
| Sake | Haste (cooldown) |
| Membership | HP Regen |
| Super Chatto | Pickup Range |
| Energy Drink | Haste (attack speed) |
| Uber Sheep | Move Speed |
| Piki Piki Piman | ATK (alt scaling) |
| Body Pillow | HP/DEF |
| Credit Card | EXP gain |
| Chicken's Feather | Knockback |
| Bandaid | Max HP |
| Injection Type Asacoco | ATK + Haste |
| Full Meal | Size (weapon area) |

### Collab (Evolution) System
- **Weapon Lv7 + Stamp Lv7 + Collab Chest** = Collab weapon
- Collab Chests appear at ~10:00 and periodically after
- The stamp is consumed (frees slot); weapon is replaced by Collab
- Each weapon has one specific stamp partner
- Starting weapons also have Collab partners

### Level-Up System
- **3 choices** (4 with meta upgrade)
- Same pool approach: new weapons, upgrades, new stamps, stamp upgrades
- Once all slots full and maxed, you get coins
- Anvil mechanic: guaranteed level-up for one item

### Meta Progression
- **HoloCoins** earned during runs
- Permanent stat upgrades (ATK, SPD, CRT, Haste, HP, Regen, Pickup, MoveSpeed)
- Each has ~10 levels with increasing cost
- **Enhanced Level-Up** (one-time): 4 choices instead of 3
- **Starting Weapon Level**: Start at Lv2 or Lv3
- **GachaPon**: Cosmetic gacha machine (outfits, backgrounds)
- Character unlocks via coins or achievements

### Unique Mechanics
- **Special Attacks** (active abilities per character) — adds skill expression
- **Super Collabs** (two Collabs fuse further — endgame power spike)
- **Stage-specific modifiers** and difficulty modes

---

## Survivor.io

### Core Differences
Survivor.io is a **mobile-first** bullet heaven with simplified controls (auto-aim, joystick movement only).

### Skill System (Weapons)
- **Active Skills**: Weapons that fire automatically. Max ~6 slots.
- **Passive Skills**: Stat modifiers. Max ~6 slots.
- Skills level up during the run via level-up choices
- Skills can be **merged/evolved** when two specific skills are both at max level

**Active Skill Types:**
- Guardian (orbit shield)
- Molotov Cocktail (area DOT)
- Lightning Emitter (chain lightning)
- Forcefield (expanding ring)
- Spinning Drone (orbit projectile)
- Boomerang, Soccer Ball, Brick, etc.

### Evolution/Merge
- Two specific skills at max level → auto-merges into evolved form
- No chest trigger needed (automatic on level-up)
- Some evolutions merge two active skills, others merge active + passive

### Equipment (Permanent Gear)
- **Equipment slots**: Weapon, Armor, 2 Accessories
- Equipment has rarity tiers (Common → Mythic)
- Equipment provides permanent stat bonuses for all runs
- Upgraded with currency/duplicates
- This is a key differentiator: equipment is semi-permanent meta gear

### Level-Up Choices
- **3 choices** per level
- Heavily weighted toward skills you can still level up
- At max equipment, choices include: skill level-ups, temporary buffs, healing

### Meta Progression
- Equipment upgrading (main progression)
- Talent tree (passive stat tree)
- Hero levels (EXP-based between runs)
- Multiple currencies: gold, gems (premium), gear materials

---

## Brotato

### Character System
- **40+ characters**, each with a unique passive effect and stat modifications
- Characters fundamentally change playstyle (e.g., "Crazy" starts with +25% damage but HP decreases each wave)
- No character-exclusive weapons

### Weapon System (Unique: Shop-Based)
- **Max 6 weapon slots**
- Weapons are **purchased from a shop** between waves (not level-up choices)
- Weapons can be the same type multiple times (stack 6 shotguns!)
- Weapons have **tiers** (Tier 1-4) — higher tiers are rarer and more powerful
- Weapons scale from their base stats + character stats

**Weapon Types (40+):**
- Melee: Fist, Sword, Spear, Hammer, Scythe, Shiv
- Ranged: Pistol, SMG, Shotgun, Sniper, Rocket Launcher, Flamethrower
- Magic: Wand, Staff, Lightning Shiv, Ghostly
- Thrown: Shuriken, Stick, Torch, Stone
- Special: Wrench (heals structures), Plank (pushes), Chopper (bouncing)

### Item System (Passive)
- Items are also **purchased from the shop** between waves
- No hard cap on items (can buy many)
- Items provide stat bonuses, similar to passives
- Items have **rarity tiers** (Common, Uncommon, Rare, Legendary)
- Some items have synergistic effects ("if you have 3+ melee weapons, +20% damage")

### Wave-Based + Shop
- Runs are wave-based (20 waves), not time-based
- Between waves: **shop screen** with 4 items for sale
- Can reroll shop (increasing cost per reroll)
- Can recycle/sell items for partial refund
- **Gold economy** is central to the run — kill enemies → earn gold → buy upgrades

### Stats
| Stat | Description |
|------|-------------|
| Max HP | Hit points |
| HP Regen | Per second |
| Life Steal | % of damage healed |
| Damage | Flat bonus |
| Melee Damage | % bonus to melee |
| Ranged Damage | % bonus to ranged |
| Elemental Damage | % bonus to elemental |
| Attack Speed | % bonus |
| Crit Chance | % |
| Engineering | Turret/structure bonus |
| Range | Weapon range |
| Armor | Flat reduction |
| Dodge | % chance to avoid damage |
| Speed | Movement speed |
| Luck | Better shop items, more drops |
| Harvesting | More materials |

### Meta Progression
- **Unlock characters** by meeting run conditions
- **Danger levels** (difficulty modifiers, increase rewards)
- **No permanent stat upgrades** — all progression is skill/knowledge-based
- Each run is self-contained (items/weapons don't carry over)
- Meta progression is primarily **character unlocks** and **difficulty levels**

---

## 20 Minutes Till Dawn

### Character System
- ~10 characters, each with a unique passive ability and stat variations
- Examples: Shana (starts with fire dash), Diamond (more HP), Abby (starts with extra summons)

### Weapon System
- **Choose 1 weapon at the start** (from ~10 options)
- Weapon levels up automatically during the run
- Weapons are: Shotgun, Revolver, Dual SMGs, Grenade Launcher, Crossbow, Batgun, Flame Cannon, etc.
- Each weapon has unique firing pattern and base stats

### Upgrade System (Unique: Skill Tree)
- On level up: **3 choices** from an **upgrade tree / skill web**
- Upgrades are **not item pickups** — they're permanent skill nodes
- Skill nodes form branching paths with tiers
- Categories: Bullet upgrades, Fire, Ice, Lightning, Dark, Summoner, General

**Skill Examples:**
- Multishot (bullets per shot)
- Haste (fire rate)
- Power Shot (damage)
- Freeze Chance, Burn Chance, Lightning Strike
- Reroll (adds reroll to level-up)
- Light Bullets (pierce), Heavy Bullets (damage), Bouncing Bullets
- Summon Bats, Summon Dragons
- Frost Nova, Fire Trail

### Key Differentiator
- No passive items or equipment — everything is the skill tree
- Creates deep build paths: "fire shotgun" vs "ice sniper" vs "summon army"
- Skill combinations can create powerful synergies
- Much more RPG-like talent tree feeling

### Meta Progression
- Character and weapon unlocks
- Rune system (unlock runes that modify runs)
- No permanent stat bonuses

---

## Halls of Torment

### Character System
- ~7 characters (Swordsman, Archer, Warlock, Cleric, Shield Maiden, etc.)
- Each has a unique primary attack pattern
- Characters level up during the run

### Ability System (Unique: Ability Slots + Traits)
- **Abilities** are active/weapon skills (orbiting shields, lightning bolts, flame walls)
- **Max 5 ability slots**
- **Traits** are passive bonuses picked on level-up
- Traits come in tiers (higher traits require prerequisite traits)

### Level-Up
- **3 choices** — mix of new abilities and trait upgrades
- Trait tree has dependency chains (must pick Trait A before Trait B unlocks)
- Creates meaningful build decisions

### Quest-Based Meta Progression
- **Quests** unlock new abilities, characters, and traits
- "Kill 1000 skeletons" → unlocks Flame Wall ability in the pool
- "Reach wave 10 with Archer" → unlocks new character
- Much more goal-oriented progression than simple currency

### Blessings (Meta Upgrades)
- Permanent stat upgrades purchased between runs
- Similar to VS PowerUps but with a quest-gate (must complete X to unlock the upgrade slot)

---

## Risk of Rain 2

### Item System (Unique: Stacking)
- Items are **not capped** — you can hold unlimited items
- Items **stack** — picking up a second Soldier's Syringe gives double the attack speed
- Item rarity: White (Common), Green (Uncommon), Red (Legendary), Yellow (Boss), Lunar (double-edged), Equipment (active)
- 100+ items total

**Item Categories:**
| Category | Effect |
|----------|--------|
| Damage | Damage boosts, crit, bleed |
| Healing | Regen, leech, barriers |
| Utility | Move speed, cooldown, jump |
| Defensive | Armor, shields, damage reduction |
| On-Kill | Effects on enemy death |
| On-Hit | Proc effects on dealing damage |

### Equipment (Active Items)
- **1 active equipment slot** (can swap)
- Powerful abilities on cooldown (missile barrage, healing zone, dash, etc.)
- Found as drops, can be swapped with new finds

### Character System
- ~14 Survivors, each with:
  - 4 active abilities (Primary, Secondary, Utility, Special)
  - Completely different playstyles
  - Abilities can be swapped via **alternate skills** (unlocked via challenges)

### Key Mechanic: Difficulty Timer
- Difficulty increases continuously over time
- Faster you loot, more time you spend, harder it gets
- Creates tension: spend time looting for better build vs. rush to boss

### Meta Progression
- **Character unlocks** via challenges
- **Alternate skills** unlocked per-character
- **Artifacts** (run modifiers, similar to Arcanas)
- **Lunar coins** (persistent currency for Lunar items/shops)
- No permanent stat upgrades — runs are self-contained

---

## Hades

### Boon System (Unique: God Boons)
- **Boons** are upgrades offered by Olympian gods at room rewards
- Each god has a themed set (Zeus = lightning, Artemis = crit, Aphrodite = weaken, etc.)
- **Boon rarity**: Common, Rare, Epic, Heroic, Legendary
- Boons modify: attack, special, cast, dash, or passive call
- **Duo Boons**: Combine two gods' themes for unique effects (require boons from both)

### Weapon System (Infernal Arms)
- **6 weapons**, each with **4 Aspects** (variants that change the weapon's behavior)
- Weapon chosen before the run
- **Daedalus Hammer** upgrades: 2 per run, fundamentally alter weapon behavior (e.g., "your attack now fires 3 shots" or "your special pulls enemies")

### Meta Progression (Mirror of Night)
- **Mirror upgrades**: ~24 permanent passive bonuses, dual-choice per slot
  - Death Defiance (extra lives) vs Stubborn Defiance (revive once per room)
  - Fiery Presence (bonus damage on first hit) vs Dark Foresight (better boon chances)
- **Titan Blood**: Used to unlock weapon Aspects (4 per weapon × 6 weapons)
- **Darkness**: Primary currency for Mirror upgrades
- **Keys**: Unlock weapons and other shortcuts
- **Diamonds**: Used for House of Hades renovations (cosmetic + minor gameplay)
- **Nectar/Ambrosia**: Given to NPCs for **Keepsakes** (equipped passive bonuses) and companisons

### Keepsakes (Equipped Passives)
- **1 active keepsake**, can be swapped between biomes
- Each provides a run-long passive (e.g., +25% chance for a specific god's boons, +bonus HP, +damage)
- Keepsakes upgraded by using them across multiple runs

### Key Patterns
- Run progression is **room-by-room choices** (pick which room reward to pursue)
- Rich narrative integration with progression
- Meaningful choices between gods/boons create replayability

---

## Cross-Game Comparison Matrix

| Feature | Vampire Survivors | HoloCure | Survivor.io | Brotato | 20 Min Till Dawn | Halls of Torment | Risk of Rain 2 | Hades |
|---------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **Weapon Slots** | 6 | 6 | ~6 | 6 | 1 | 5 | Unlimited | 1 (aspects) |
| **Passive Slots** | 6 | 6 | ~6 | Unlimited | 0 (tree) | Unlimited traits | Unlimited | 1 keepsake |
| **Weapon Max Level** | 8 | 7 | Varies | Tiers | Auto | 5 | N/A (stacking) | N/A |
| **Evolution System** | Weapon+Passive+Chest | Weapon+Stamp+Chest | Auto-merge | No | No | No | No | Aspects |
| **Level-Up Choices** | 3-4 | 3-4 | 3 | Shop (4) | 3 (tree) | 3 | N/A (drops) | Room choice |
| **Reroll** | Yes (limited) | No | No | Yes (gold) | Yes | No | No | Yes (Fated Authority) |
| **Banish** | Yes (limited) | No | No | Sell | No | No | Scrapper | No |
| **Character Start Weapon** | Yes (exclusive) | Yes (exclusive) | No | No (passive only) | Choose 1 | Yes | 4 abilities | Choose 1 |
| **Meta Stat Upgrades** | Yes (gold) | Yes (coins) | Yes (equip+talents) | No | No | Yes (blessings) | No | Yes (mirror) |
| **Meta Currency** | Gold | HoloCoins | Multiple | None | Runes | Gold | Lunar Coins | Darkness/Keys |
| **Run Duration** | 30 min | 20 min | ~10 min | 20 waves | 20 min | ~15 min | Variable | ~30 min |
| **Active Abilities** | No | Yes (Special) | Auto | No | No | No | Yes (4) | Yes (attack/special/cast/dash) |

---

## Stats Under the Hood

### Universal Stats Across the Genre
These stats appear in virtually every survivor-like:

| Stat | Found In | Purpose |
|------|----------|---------|
| **Damage/Might/ATK** | All | Base damage multiplier |
| **Max HP** | All | Survivability |
| **HP Recovery/Regen** | All | Sustain |
| **Move Speed** | All | Mobility/survival |
| **Attack Speed/Cooldown/Haste** | All | DPS scaling |
| **Pickup Range/Magnet** | VS, HC, Survivor.io | QoL + EXP efficiency |
| **Area/Size** | VS, HC, HoT | Weapon coverage |
| **Projectile Count/Amount** | VS, HC, Brotato | DPS + coverage |
| **Projectile Speed** | VS, HC, Brotato | Range effectiveness |
| **Pierce** | VS, Brotato, 20MTD | Multi-target efficiency |
| **Crit Chance** | HC, Brotato, 20MTD, Hades | Burst damage |
| **Duration** | VS, HoT | Effect uptime |
| **EXP Growth** | VS, HC | Snowball scaling |
| **Luck** | VS, Brotato | Quality/variance |
| **Knockback** | HC, RoR2 | Crowd control |
| **Armor/Defense** | VS, Brotato, RoR2 | Flat reduction |
| **Dodge** | Brotato | Avoidance |
| **Lifesteal** | Brotato, RoR2 | Sustain |

### M&P Current Stats
| Stat | Key |
|------|-----|
| Damage | `damage_mult` |
| Fire Rate | `fire_rate_mult` |
| Projectile Speed | `proj_speed_mult` |
| Pierce | `pierce_bonus` |
| Move Speed | `move_speed_mult` |
| Pickup Range | `pickup_range_mult` |
| Area | `area_mult` |
| Projectile Count | `proj_count_bonus` |

**Missing from M&P (common in the genre):**
- Max HP scaling
- HP Recovery/Regen
- Crit Chance + Crit Damage
- Duration
- Cooldown (separate from fire rate)
- EXP Growth
- Luck
- Knockback
- Armor/Defense

---

## Key Patterns & Takeaways

### 1. The 6+6 Slot Model Is Standard
Nearly every game caps at 6 weapons + 6 passives. This creates meaningful choices:
- Early: "Do I pick a new weapon or level my existing one?"
- Mid: "Do I grab this passive for the evolution combo or one that helps me now?"
- Late: "All slots full, just need to max levels for evolutions"

### 2. Evolution as the Build Puzzle
VS and HoloCure make evolutions the central build motivator:
- Players plan backwards from desired evolutions
- "I want Bloody Tear, so I need to pick up Whip and Hollow Heart"
- This creates **intentional** building, not random accumulation
- The **chest trigger** adds excitement (a moment of payoff)

### 3. Three Tiers of Progression
Almost every successful survivor-like has three tiers:

| Tier | Scope | Examples |
|------|-------|---------|
| **In-Run** | Resets each run | Weapons, passives, levels |
| **Meta (Between Runs)** | Permanent upgrades | Stat bonuses, extra rerolls |
| **Unlocks** | One-time | Characters, weapons, abilities |

### 4. Skill Expression Beyond RNG
The best games give players tools to fight RNG:
- **Rerolls**: Shuffle choices (limited resource)
- **Banish**: Remove unwanted items permanently from pool
- **Skip**: Take nothing (save for better options later)
- **Shop** (Brotato): Direct purchase with meaningful economy
- **Room choice** (Hades): Pick your reward type

### 5. Character Identity Through Exclusivity
Characters feel distinct when they have:
- Exclusive starting weapon (VS, HoloCure) — **M&P already does this**
- Stat bonuses that steer toward specific builds
- Unique active ability (HoloCure's Specials, Hades' weapons)
- Exclusive evolution paths

### 6. Passive Acquisition Approaches

| Approach | Games | Pros | Cons |
|----------|-------|------|------|
| Level-up pool (mixed with weapons) | VS, HoloCure | Simple, familiar | Can feel like filler choices |
| Shop purchase | Brotato | Player agency, economy | Requires shop system |
| Skill tree | 20 Minutes Till Dawn | Deep builds, branching | Complex UI, overwhelming |
| Drops from enemies/chests | RoR2 | Exciting moment-to-moment | Pure RNG, no agency |
| Quest-gated | Halls of Torment | Goal-oriented | Slower meta progression |
| Equipment (permanent) | Survivor.io | Persistent progress | P2W concerns |

### 7. Weapon Upgrade Depth
How games make weapon leveling interesting:

- **Stat scaling only** (VS, HoloCure): Each level = more damage/projectiles/area. Simple but can feel flat.
- **Behavior changes** (20MTD, Hades Hammers): Upgrades fundamentally change how the weapon works. More exciting.
- **Branching paths** (not yet common in survivor-likes): Choose between Path A or Path B at certain levels. Huge potential for replayability.

### 8. The Shop Model (Brotato) as an Alternative
Brotato's between-wave shop is notable:
- No randomized level-up choices
- Pure economic decision-making
- Can buy duplicates (6 of the same weapon)
- Reroll costs gold (opportunity cost)
- Creates a fundamentally different feel: "earning and spending" vs "being offered and choosing"

---

## Recommendations for Mortar and Pistol

Based on this research, here are potential directions for the upgrade rework:

### Option A: "VS Classic" (Conservative)
Keep the level-up pool but add depth:
- Weapons + passives in the same pool (restore passives)
- Add Reroll/Banish/Skip
- Passives paired with weapons for Transmutations
- Players build toward specific evolution combos

### Option B: "Branching Weapons" (Innovative)
Weapon-focused with branching upgrades:
- On level-up: only weapon upgrades offered
- At key levels (3 and 5), weapon branches into 2 paths (choose one)
- Passives acquired via **drops** (Lodestone Pulses, chests, boss kills) instead of level-up pool
- Transmutations require maxed weapon + specific passive

### Option C: "The Forge" (Hybrid)
Combine elements from multiple games:
- Level-up pool offers weapon upgrades + **traits** (smaller bonuses, not full passives)
- Full passives obtained from **boss drops** and **milestone chests** (at 3:00, 6:00, 9:00)
- Traits are minor buffs (+5% damage, +1 pierce) that stack
- Keeps the moment-to-moment choices interesting while making passives feel like earned rewards

### Option D: "Gunsmith's Table" (Shop-Inspired)
Between-wave/rest-stop shop system:
- Every 2-3 minutes, a brief shop phase
- Buy weapon upgrades, passives, consumables with in-run currency (scrap/cogs?)
- Enemies drop currency instead of (or alongside) XP
- More player agency, less RNG
- Reroll shop for cost

### Stats to Consider Adding
| Stat | Priority | Reasoning |
|------|----------|-----------|
| Crit Chance | High | Universally exciting, adds burst variance |
| Max HP / HP Regen | High | Survivability options beyond "kill faster" |
| Duration | Medium | For DOT, orbit, and AOE weapons |
| Cooldown (distinct from fire rate) | Medium | Different from fire rate — affects ability timing |
| Knockback | Low | CC stat, useful for survival builds |
| Luck | Low | Meta stat for upgrade quality |
| EXP Growth | Medium | Snowball stat, speeds up runs |
