# Mortar & Pistol — Core System Design

## Purpose

This document describes M&P's current and planned combat upgrade system, formatted to mirror the Survivor.io Core System Design reference so you can directly compare the two. Each section includes an **audit** noting what exists, what's planned, and what needs to be rewritten or dropped to align with the survivor.io-inspired direction.

---

## 1. System Model — Where We Are vs Where We're Going

### Current Implementation (What's In the Code)

```
Character Weapon (1)          Pool Weapons (6, all archived)
        │                              │
    Level 1-5                     Level 1-5
    (via level-up)               (via level-up, if unarchived)
        │                              │
    [no branching]              Max Lv + Passive = Transmutation
```

- 4 character weapons (Bolt Rifle, Scatter Flask, Powder Keg, Twin Barrels)
- 6 pool weapons (all soft-archived — exist in code but hidden from level-up)
- 8 passives (removed from level-up pool, pending rework)
- 6 transmutation recipes (pool weapon + passive = evolved weapon)
- Level-up offers weapon upgrades only (passives stripped out)

### Target Model (Survivor.io-Inspired)

```
6 Active Skill Slots                    6 Passive Skill Slots
┌─────────────────────┐                ┌─────────────────────┐
│ Character Weapon    │                │ Passive A           │
│ Pool Weapon 2      │                │ Passive B           │
│ Pool Weapon 3      │                │ Passive C           │
│ Pool Weapon 4      │                │ Passive D           │
│ Pool Weapon 5      │                │ Passive E           │
│ Pool Weapon 6      │                │ Passive F           │
└────────┬────────────┘                └────────┬────────────┘
         │                                      │
         └──────────────┬───────────────────────┘
                        │
              Active (Max Lv) + Paired Passive = Evolution
              (Multiple passives can pair → player CHOOSES evo)
```

**Key differences from current:**
- Passives return to the level-up pool as full citizens, not afterthoughts
- Each passive has standalone value AND serves as an evolution key
- One weapon can have 2-3 possible evolutions depending on which passive is paired
- Player choosing which evo when multiple passives qualify = the big decision moment

---

## 2. Active Skills (Weapons)

### 2.1 Character Weapons — Starter Actives

Each hero begins with an exclusive weapon that occupies Active Slot 1 and cannot be replaced.

| Hero | Weapon | Type | Base DPS | Identity |
|---|---|---|---|---|
| Wizard | Bolt Rifle | BEAM | ~20 | Hitscan line through enemies. Piercing, long range, clean. |
| Alchemist | Scatter Flask | BURST | ~14 | Lobbed flask shatters into shrapnel cone. Short range, high spread. |
| Bombardier | Powder Keg | MINE | ~25 | Drops explosive barrel at feet. Fuse timer, AoE blast, screen shake. |
| Assassin | Twin Barrels | BURST_FIRE | ~10×2 | Two rapid shots in quick succession. Fast, aggressive, mobile. |

**Audit:** All 4 character weapons are **fully implemented** with unique VFX, strategy scripts, and pool-managed effects. These are solid and stay.

**What changes under the new model:** Character weapons now follow the same evolution rules as pool weapons. Max level + paired passive = evolution. This means we need to design evolution paths for each character weapon.

**What needs to be built:**
- [ ] 2-3 evolution paths per character weapon
- [ ] Passive pairings for each path

### 2.2 Pool Weapons — Secondary Actives

Pool weapons fill Active Slots 2-6. They appear in the level-up pool during a run.

#### Keeping (2 weapons)

| Weapon | Type | Identity | Why Keep |
|---|---|---|---|
| Arc Discharge | CHAIN | Lightning arcs between enemies. | Unique chain mechanic, flashy, scales well. |
| Seeker Rounds | BARRAGE | Homing missiles track random enemies. | Homing is a distinct category, satisfying auto-aim fantasy. |

**Audit:** Both exist in code, are **soft-archived** (hidden from pool). Need to be un-archived and their transmutation recipes updated for the new evolution system.

#### Dropping (4 weapons)

| Weapon | Type | Why Drop |
|---|---|---|
| Bayonet Rush | MELEE | Generic melee sweep. Doesn't feel unique next to character weapons. |
| Mortar Burst | AOE | Generic pulse AoE. Too similar to Powder Keg's blast identity. |
| Ember Shells | ORBIT | Orbiting fireballs. Functional but visually boring, no interesting mechanic. |
| Blight Flask | DOT | Poison zone. Too similar to Scatter Flask's throwing identity. |

#### Replacing With (4 new weapons — workshop-decided, specs in progress)

| Weapon | Type | Identity | Status |
|---|---|---|---|
| Gravity Lash | WHIP | Wide arc knockback. Pushes enemies away, enemies collide with each other for bonus damage. Defensive spacing tool. | **NEEDS FULL SPEC** |
| Sawblade Launcher | ARC | Arcing throw + return boomerang. Thrown blade arcs out and comes back, hitting on both trips. | **NEEDS FULL SPEC** |
| Magma Geyser | ERUPTION | Brick-style weapon (survivor.io-inspired). Specifics TBD — user pivoted from mouse-aim to a different reference. | **NEEDS FULL SPEC + CREATIVE DIRECTION** |
| Phantom Sentry | DRONE | Floaty drone that auto-fires (survivor.io-style). Changed from stationary turret to mobile companion. | **NEEDS FULL SPEC** |

**What needs to be built:**
- [ ] Full weapon specs for all 4 replacements (damage, fire rate, scaling, behavior)
- [ ] WeaponData entries in weapons_db.gd
- [ ] Strategy scripts for new weapon types (WHIP, ARC, ERUPTION, DRONE)
- [ ] VFX for each weapon
- [ ] Pool manager registration + scenes
- [ ] 2-3 evolution paths per new weapon

---

## 3. Passive Skills

### 3.1 The Problem With the Current System

The original 8 passives were **pure stat sticks**:

| Passive | Effect | Problem |
|---|---|---|
| Gunpowder | +damage% | No gameplay change, just a number. |
| Clockwork | +fire rate% | Same. |
| Quicksilver | +proj speed% | Same. |
| Birdshot | +pierce | Slightly interesting but still just a number. |
| Wind Vents | +move speed% | Same. |
| Lodestone | +pickup range% | Same. |
| Focusing Lens | +area% | Same. |
| Extra Powder | +proj count | Best of the bunch — visibly changes weapon behavior. |

These are the exact "one-note stat sticks" the Survivor.io reference doc warns against in Section 19 ("Avoid"). They have no gameplay personality, create no decisions, and exist only as numbers on an upgrade card.

### 3.2 What the Survivor.io Model Requires

From the reference doc:

> "Each passive must feel worth taking even if the linked transformation is never completed." (Section 9.3)

> "If a passive is only selected to unlock an evo, it is not carrying enough standalone value." (Section 9.3, Risk)

This means every passive needs:
1. **Immediate value** — you feel it the moment you pick it up
2. **Visible impact** — the player can see or feel the difference in gameplay
3. **Evolution role** — it's the key that unlocks a specific weapon evolution
4. **Identity** — it contributes to a build fantasy, not just a bigger number

### 3.3 What Needs to Happen

**The entire passive system needs to be redesigned from scratch.**

The old 8 passives should be treated as a starting point for stat coverage but completely reworked in design philosophy. Each new passive needs:

- A name with personality (not just "Gunpowder = damage")
- A mechanical effect beyond flat stats (Extra Powder was the only one that visibly changed gameplay)
- Clear pairing with 1-2 weapon evolutions
- The "weapon-aware" trait concept from workshops (bonuses adapt to your loadout)

**Workshop context:** The user explored three different directions across workshops:
1. Original 8 stat-stick passives (implemented, removed from pool)
2. Traits (unlimited, weapon-aware) + Artifacts (6 slots, from bosses) — workshop C8/D7-D9
3. Survivor.io model (6 passive slots, level via duplicates, paired to evolutions) — workshop E10

**Direction 3 is the current target.** Directions 1 and 2 should be considered superseded, though individual ideas (weapon-aware bonuses, tiered scaling) can be folded into the new design.

**What needs to be built:**
- [ ] Complete passive redesign — new passives with mechanical effects, not just stats
- [ ] Evolution pairing chart (which passive + which weapon = which evo)
- [ ] Multi-evo support (one weapon paired with different passives → different evolutions)
- [ ] Passive weapon-awareness (bonuses that adapt based on owned weapons)
- [ ] Late-run scaling model (tiered passives? stacking? diminishing returns?)

---

## 4. Evolution / Transmutation

### 4.1 Current System (Implemented but Frozen)

6 recipes exist in code:

| Active (Lv5) | + Passive | = Evolution | DPS Change |
|---|---|---|---|
| Bayonet Rush | Gunpowder | Reaper's Bayonet | ~2.5x |
| Mortar Burst | Clockwork | Carpet Bomber | ~3x |
| Arc Discharge | Birdshot | Storm Conduit | ~2x |
| Ember Shells | Quicksilver | Inferno Ring | ~2x |
| Blight Flask | Focusing Lens | Plague Barrage | ~2.5x |
| Seeker Rounds | Extra Powder | Bullet Storm | ~2x |

**Audit:** These are 1:1 pairings (one weapon → one passive → one evolution). This is the simplest form of the survivor.io model. It works but creates the "solved-build risk" the reference doc warns about in Section 17.1.

### 4.2 Target Evolution System

The new model should support **branching evolutions** — the reference doc's Section 12.4 and M&P's stated direction from workshop E10.

```
Arc Discharge (Max Lv)
    ├── + Passive A → Storm Conduit (chain density)
    ├── + Passive B → Split Current (forking arcs)
    └── + Passive C → Plasma Surge (burn + explosions)
```

**Key rules from workshops:**
- Character weapons evolve via passives (same system as pool weapons)
- If you have multiple qualifying passives, you **choose** which evolution
- Evolutions should feel like 2-3x power spikes
- Evolutions should change functionality, not just increase numbers
- Visual moment: transmutation should be flashy and memorable

**What needs to be built:**
- [ ] Branching evolution tree for every weapon (character + pool)
- [ ] Evolution trigger logic (max level weapon + any qualifying passive)
- [ ] Choice UI when multiple evolutions are available
- [ ] Evolution VFX flash/celebration moment
- [ ] New EvolutionData structure to support multiple routes per weapon

---

## 5. Slot Constraints

### Survivor.io Reference

- 6 Active Skill slots
- 6 Passive Skill slots
- Strict slot limit creates build pressure and identity

### M&P Current

- 6 weapon slots (implemented)
- 6 passive slots (implemented but passives removed from pool)
- 1 element slot (implemented in data, not in gameplay)

### M&P Target

| Resource | Slots | Source |
|---|---|---|
| Active Skills (weapons) | 6 | 1 character weapon (locked) + 5 from level-up pool |
| Passive Skills | 6 | All from level-up pool |
| Element | 1 | Chosen at character select (not a slot — a modifier) |

**Audit:** The slot system itself is fine. 6+6 matches survivor.io's proven formula. The infrastructure exists in GameManager. What's missing is the content to fill those slots meaningfully.

**Important constraint from workshops:** No skip on level-up — forced choice. This aligns with the survivor.io model where every pick matters for build identity.

---

## 6. Level-Up / Drafting

### Current Implementation

- XP curve: `10 * level^1.3`
- 3 choices per level-up card
- Currently only offers: weapon upgrades (new weapons if slots open)
- Rerolls: 3 per run (infinite in god mode)
- Banish: not implemented

### Target Implementation

Level-up should offer a mix of:
- **New weapons** (if slots open)
- **Weapon upgrades** (duplicate = level up, like survivor.io star system)
- **New passives** (if slots open)
- **Passive upgrades** (duplicate = level up)

**Key decisions still needed:**
- What's the weighting? (How often do weapons vs passives appear?)
- Should evolution trigger automatically when conditions are met, or at a trigger event (chest/boss)?
- How visible should evolution requirements be during the run?

**What already works:**
- Level-up panel UI (3 choices, forced pick) ✓
- XP curve and gem collection ✓
- Weapon slot tracking ✓
- Passive slot tracking ✓

**What needs to be rewritten:**
- [ ] Level-up pool generation (currently weapon-only, needs to mix weapons + passives)
- [ ] Smart weighting (balance weapon/passive offerings based on what player has)
- [ ] Banish system (unlock via Forge, start at 1, upgrade to max 5)
- [ ] Reroll system (start at 0, earned via Forge)
- [ ] Evolution trigger check after each level-up

---

## 7. Comparison Matrix — M&P vs Survivor.io Model

| Feature | Survivor.io | M&P Current | M&P Target | Gap |
|---|---|---|---|---|
| Active slots | 6 | 6 | 6 | None |
| Passive slots | 6 | 6 (empty) | 6 | **Passive redesign needed** |
| Starter weapon | 1 (equipped) | 1 (character) | 1 (character) | None |
| Leveling actives | Star system (duplicates) | Level 1-5 via level-up | Same | None |
| Leveling passives | Star system (duplicates) | Level 1-5 via level-up | Same | **Passives need to exist first** |
| Evolution formula | Active max + Passive = Evo | Weapon Lv5 + Passive = Transmute | Same, but branching | **Branching logic needed** |
| Evolution trigger | Boss chest | Auto on conditions met | TBD | **Decision needed** |
| Branching evos | Limited (some combo skills) | None (1:1 only) | Multi-path per weapon | **Major new system** |
| Passive standalone value | Mixed (some are stat sticks) | All stat sticks | Weapon-aware, mechanical | **Full redesign needed** |
| Build identity | Strong (slot pressure) | Weak (no passives in pool) | Strong (slot pressure + elements) | **Passives must return to pool** |
| Forced choice | Yes (no skip) | Yes (implemented) | Yes | None |
| Slot pressure | High | Low (only weapons compete) | High (weapons + passives) | **Passives must return to pool** |

---

## 8. What We Keep

These systems are solid and align with the survivor.io model:

| System | Status | Notes |
|---|---|---|
| 4 character weapons | Implemented | Unique, flashy, well-VFX'd. Stay as-is. |
| 6+6 slot constraint | Implemented | Matches survivor.io. Infrastructure works. |
| XP gem system | Implemented | Spiral vortex collection, Lodestone Pulse vacuum. |
| Level-up UI (3 choices, forced pick) | Implemented | Core loop works. |
| Dash (Alchemical Blink) | Implemented | Per-hero variations designed. |
| Weapon strategy pattern | Implemented | Clean architecture, easy to add new types. |
| Object pool system | Implemented | 12 pools, lifecycle management. |
| Signal bus pattern | Implemented | Decoupled communication. |
| Weapon VFX (blocky pixel aesthetic) | Implemented | GPUParticles2D + draw_rect. Looks good. |

---

## 9. What We Rewrite

These systems exist but need significant changes:

| System | Current State | What Changes | Effort |
|---|---|---|---|
| Pool weapons (4 of 6) | Archived, generic | Replace with Gravity Lash, Sawblade, Geyser, Drone | **High** — 4 new weapon types |
| Passives (all 8) | Removed from pool, stat sticks | Full redesign with mechanical effects + evo pairing | **High** — new design + code |
| Evolution system | 1:1 recipes in evolution_db.gd | Branching multi-path, choice UI | **Medium** — new data structure + UI |
| Level-up pool generation | Weapon-only | Mixed weapons + passives with smart weighting | **Medium** — rewrite pool logic |
| WeaponData / PassiveData | Basic stat containers | Add evo pairing fields, weapon-aware flags | **Low** — extend existing Resources |

---

## 10. What We Drop

These concepts from workshops should be abandoned as they conflict with the survivor.io model:

| Concept | Source | Why Drop |
|---|---|---|
| Traits (unlimited minor buffs) | Workshop C8, D7 | Replaced by the 6-slot passive system. Unlimited buffs undermine slot pressure. |
| Artifacts (6 slots from bosses) | Workshop C8, D8 | Replaced by passives-as-evo-keys. Artifacts were a middleman layer that's no longer needed. |
| Character weapon branching at Lv3/Lv5 | Workshop F1 | Conflicts with the unified evo model. Character weapons should evolve the same way as pool weapons (max level + passive). |
| All-weapon-aware traits | Workshop D9, E10-E12 | The "all traits are weapon-aware" concept was for the Traits system which is now dropped. Individual passives can still be weapon-aware. |
| Tiered trait scaling | Workshop E12 | Was designed for the unlimited-traits model. Passives now have levels (like survivor.io stars). |

---

## 11. What's Undefined (Open Questions)

These need answers before implementation:

### 11.1 Evolution Trigger
**When does evolution happen?** Survivor.io uses boss chests. Our current system auto-triggers. Options:
- Auto-trigger on conditions met (current — simple, instant gratification)
- Next level-up after conditions met (slight delay, feels earned)
- Boss chest / milestone event (survivor.io style, biggest anticipation)

### 11.2 Evolution Choice UI
**When multiple passives qualify for different evos, how does the player choose?**
- Pop-up card choice (like level-up but for evos)
- Special "forge" interaction
- Auto-offer at next level-up

### 11.3 Passive Design
**What should the new passives actually be?** The redesign is stated but no specific passives have been designed. We need:
- 8-12 passives to fill the 6 slots with variety
- Each with a mechanical effect (not just +X%)
- Each paired to 1-2 weapon evolutions
- Each carrying standalone value

### 11.4 Pool Weapon Availability
**How many pool weapons are free from run 1?** Conflicting answers exist:
- "2 free, 4 unlock" (workshop D12)
- "I'd like more than 2 free, VS has lots off rip" (workshop D12 note)
- This is unresolved

### 11.5 New Weapon Specs
**The 4 replacement weapons have identities but no numbers.** Need:
- Base damage, scaling per level
- Fire rate, range, AoE radius
- Unique mechanic parameters (knockback distance, boomerang arc, drone AI, etc.)

### 11.6 Character Weapon Evolutions
**No evolution paths exist for the 4 character weapons.** These need:
- 2-3 evolution paths each
- Paired passives for each path
- Evolution weapon designs (behavior + VFX)

### 11.7 Magma Geyser Identity
**User pivoted from "mouse-controlled geyser" to "brick weapon from survivor.io" without specifying what that means.** This weapon needs a creative direction pass.

---

## 12. Recommended Implementation Order

Based on the reference doc's Section 14.6 guidance ("small batches with intentional spread"):

### Phase 1: Foundation (Upgrade Rework)
1. Redesign passives (8-12 new passives with mechanical effects)
2. Return passives to level-up pool with smart weighting
3. Define evolution pairing chart (which passive + which weapon = which evo)
4. Implement branching evolution logic + choice UI
5. Un-archive Arc Discharge and Seeker Rounds with new evolution paths

### Phase 2: New Weapons
6. Spec and implement the 4 replacement pool weapons
7. Design character weapon evolution paths
8. Wire up all evolution recipes

### Phase 3: Polish
9. Evolution VFX celebration moments
10. UI for showing evolution requirements during run
11. Codex / collection screen for discovered evolutions
12. Balance pass on all weapons, passives, and evolutions

---

## 13. The Emotional Arc (From Survivor.io Reference, Section 6)

The reference doc describes the ideal player experience as:

> * uncertainty at the start,
> * intention in the middle,
> * transformation at the spike,
> * mastery near the end.

**M&P currently delivers:**
- Uncertainty at the start ✓ (which weapons will I be offered?)
- Intention in the middle ✗ (no passives = no planning = no "I'm building toward X")
- Transformation at the spike ✗ (no evolutions active = no power spike moments)
- Mastery near the end ✗ (build doesn't change enough to feel like mastery)

**After the rework, M&P should deliver all four.** The passive system is the missing piece that turns "pick weapons, get bigger numbers" into "author a build."

---

## 14. Summary

M&P has strong bones: 4 unique character weapons, clean architecture, solid VFX, working core loop. But its upgrade system is currently gutted — passives removed, evolutions frozen, pool weapons archived. The game is running on character weapons only, which means the middle and late run feel flat.

The survivor.io-inspired model (6 actives + 6 passives + branching evolutions) is the right target. It creates slot pressure, meaningful decisions, and power spike moments. Most of the infrastructure exists (slots, level-up UI, evolution data). What's missing is the **content and design** to populate that infrastructure:

- **New passives** with mechanical identity (not stat sticks)
- **New pool weapons** that feel as flashy as the character weapons
- **Branching evolutions** that give players reason to care about passive choices
- **A level-up pool** that mixes weapons and passives with smart weighting

The single biggest lever for making M&P feel like a real game is getting passives back into the level-up pool with evolution pairings. Everything else is secondary.
