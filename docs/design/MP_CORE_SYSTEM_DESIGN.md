# Mortar & Pistol — Core System Design

## Purpose

Define the target combat build system for Mortar & Pistol. This document describes the intended run structure, upgrade model, passive philosophy, evolution rules, and implementation priorities for the next major systems pass.

This is the specification for the system the game should become. Current-state audits and gap analysis are included where they inform the path forward, but the primary function of this document is to specify what to build.

---

## 1. Product Goal

Mortar & Pistol should feel like a game where the player **authors a build during the run**, not a game where the player simply upgrades damage output over time.

The target experience is:

- a strong starter identity through an exclusive character weapon,
- meaningful build expansion through secondary weapons,
- real planning tension through passive selection,
- and memorable power spikes through weapon evolutions.

The game already has working slot infrastructure, functioning level-up UI, strong character weapons, and solid technical foundations. It does not yet produce enough mid-run planning or late-run transformation because passives are absent from the draft pool and evolutions are effectively inactive.

---

## 2. Player Experience Goals

The system must create four feelings over the course of a run:

### 2.1 Early uncertainty
The player is improvising from incomplete information and trying to stabilize.

### 2.2 Mid-run intention
The player begins making choices that point toward a future build rather than only immediate survival.

### 2.3 Evolution payoff
The player reaches a threshold where preparation turns into a noticeable transformation.

### 2.4 Late-run mastery
The player feels that the build has become coherent, expressive, and stronger in a way that reflects previous choices.

**Current state:** The game delivers 2.1 (which weapons will I be offered?) but fails at 2.2 through 2.4. No passives means no planning. No active evolutions means no power spike moments. The build doesn't change enough to feel like mastery.

---

## 3. System Pillars

### 3.1 Starter identity matters
Each character begins with a distinctive weapon that defines early play feel and remains relevant throughout the run.

### 3.2 Passives are full build pieces
Passives are not filler. They must provide immediate gameplay value, visible impact, and evolution relevance.

### 3.3 Slot pressure creates build identity
Because active and passive slots are limited, every pick closes some doors while opening others.

### 3.4 Evolutions are earned spikes
An evolution should feel like a milestone, not a routine stat bump.

### 3.5 Build paths should be understandable
Players should be able to recognize how their choices are shaping the run without needing external documentation.

---

## 4. System Model

### 4.1 Current Implementation

```
Character Weapon (1)          Pool Weapons (6, all archived)
        |                              |
    Level 1-5                     Level 1-5
    (via level-up)               (via level-up, if unarchived)
        |                              |
    [no evolution]              Max Lv + Passive = Transmutation
```

- 4 character weapons (Bolt Rifle, Scatter Flask, Powder Keg, Twin Barrels) — implemented
- 6 pool weapons (all soft-archived, hidden from level-up) — 4 being replaced
- 8 passives (removed from level-up pool) — all being redesigned
- 6 transmutation recipes (1:1 weapon+passive pairings) — frozen
- Level-up offers weapon upgrades only

### 4.2 Target Model

```
6 Active Skill Slots                    6 Passive Skill Slots
+---------------------+                +---------------------+
| Character Weapon    |                | Passive A           |
| Pool Weapon 2      |                | Passive B           |
| Pool Weapon 3      |                | Passive C           |
| Pool Weapon 4      |                | Passive D           |
| Pool Weapon 5      |                | Passive E           |
| Pool Weapon 6      |                | Passive F           |
+--------+------------+                +--------+------------+
         |                                      |
         +------------------+-------------------+
                            |
              Active (Max Lv) + Paired Passive = Evolution
              (Multiple passives can pair -> player CHOOSES evo)
```

**Core rules:**

- **6 active slots** + **6 passive slots**
- **1 locked starter weapon** (character weapon, slot 1)
- **5 additional active slots** filled during the run
- Passives drafted from the same level-up ecosystem as weapons
- Weapons and passives upgraded by duplicates
- Max-level weapon + qualifying passive = evolution
- Some weapons support multiple passive pairings and therefore multiple evolutions

---

## 5. Active Weapons

### 5.1 Character Weapons — Starter Actives

Each hero begins with an exclusive weapon that occupies Active Slot 1 and cannot be replaced.

| Hero | Weapon | Type | Base DPS | Identity |
|---|---|---|---|---|
| Wizard | Bolt Rifle | BEAM | ~20 | Hitscan line through enemies. Piercing, long range, clean. |
| Alchemist | Scatter Flask | BURST | ~14 | Lobbed flask shatters into shrapnel cone. Short range, high spread. |
| Bombardier | Powder Keg | MINE | ~25 | Drops explosive barrel at feet. Fuse timer, AoE blast, screen shake. |
| Assassin | Twin Barrels | BURST_FIRE | ~10x2 | Two rapid shots in quick succession. Fast, aggressive, mobile. |

**Status:** All 4 fully implemented with unique VFX, strategy scripts, and pool-managed effects. These are solid and stay.

**Required change:** Character weapons must integrate into the shared evolution model (max level + paired passive = evolution). Each needs 2+ evolution branches.

### 5.2 Pool Weapons — Secondary Actives

Pool weapons fill Active Slots 2-6 and appear in the level-up pool during a run. The pool weapon roster should support complementary combat fantasies rather than overlap with starter identities.

#### Keeping

| Weapon | Type | Identity | Why Keep |
|---|---|---|---|
| Arc Discharge | CHAIN | Lightning arcs between enemies. | Unique chain mechanic, flashy, scales well. |
| Seeker Rounds | BARRAGE | Homing missiles track random enemies. | Homing is a distinct category, satisfying auto-aim fantasy. |

Both exist in code (soft-archived). Need to be un-archived and given new evolution routes.

#### Dropping

| Weapon | Type | Why Drop |
|---|---|---|
| Bayonet Rush | MELEE | Generic melee sweep. Doesn't feel unique next to character weapons. |
| Mortar Burst | AOE | Generic pulse AoE. Too similar to Powder Keg's blast identity. |
| Ember Shells | ORBIT | Orbiting fireballs. Functional but visually boring, no interesting mechanic. |
| Blight Flask | DOT | Poison zone. Too similar to Scatter Flask's throwing identity. |

#### Replacing With

| Weapon | Type | Identity | Status |
|---|---|---|---|
| Gravity Lash | WHIP | Wide arc knockback. Pushes enemies away, collision damage between enemies. | Needs full spec |
| Sawblade Launcher | ARC | Arcing throw + return boomerang. Hits on both trips. | Needs full spec |
| Magma Geyser | ERUPTION | Brick-style weapon (survivor.io-inspired). Role TBD — area denial, vertical burst, or eruption control. | Needs spec + creative direction |
| Phantom Sentry | DRONE | Floaty drone that auto-fires (survivor.io-style mobile companion). | Needs full spec |

These should not move to implementation until each has a full spec covering cadence, range, scaling, area behavior, and intended evolution routes.

---

## 6. Passive System

### 6.1 Design Mandate

The passive system must be rebuilt from scratch.

A good passive is not "+x% to a stat." A good passive is a **build-shaping rule** that may also carry some stat value.

### 6.2 Why the Old System Failed

The original 8 passives were pure stat sticks:

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

These have no gameplay personality, create no decisions, and exist only as numbers on an upgrade card.

### 6.3 Passive Requirements

Every passive must satisfy all four conditions:

**Immediate value** — The player should feel a difference immediately after taking it.

**Visible impact** — The passive should alter something noticeable in combat, not just backend efficiency.

**Evolution role** — The passive should unlock or influence one or more evolution routes.

**Identity contribution** — The passive should support a recognizable build fantasy.

### 6.4 Passive Behavior Categories

Examples of good passive behavior (not exhaustive):

- Extra instances or duplicates
- Modified targeting or chain extension
- Return-path or ricochet enhancement
- Impact conversion (damage type changes)
- Conditional bursts (on kill, on crit, on dash)
- Enemy grouping or displacement
- Overflow or echo behavior
- Synergy with owned weapon types

### 6.5 Content Requirement

The target roster for launch:

- **8-12 passives** (more than 6 so not every passive appears every run)
- At least **one visible gameplay effect per passive**
- At least **1-2 linked evolutions per passive**
- At least **one passive per major weapon family or combat fantasy**

### 6.6 Dropped Directions

The following passive concepts from earlier workshops are superseded by the survivor.io model:

| Concept | Workshop Source | Why Dropped |
|---|---|---|
| Traits (unlimited minor buffs, no slot cap) | C8, D7 | Undermines slot pressure. Replaced by 6-slot passive system. |
| Artifacts (6 slots, boss drops, evo keys) | C8, D8 | Replaced by passives-as-evo-keys. Artifacts were a middleman layer. |
| All-weapon-aware traits | D9, E10-E12 | Was designed for the Traits system. Individual passives can still adapt to loadout. |
| Tiered trait scaling | E12 | Was for the unlimited-traits model. Passives now have levels. |

---

## 7. Evolution System

### 7.1 Base Rule

A weapon evolution requires:
- a max-level weapon,
- a qualifying passive,
- and an evolution trigger.

### 7.2 Branching Rule

A weapon may support multiple evolutions. If the player owns multiple qualifying passives when the weapon is eligible, the player **chooses** which evolution to take.

```
Arc Discharge (Max Lv)
    +-- + Passive A -> Storm Conduit (chain density)
    +-- + Passive B -> Split Current (forking arcs)
    +-- + Passive C -> Plasma Surge (burn + explosions)
```

### 7.3 Evolution Standard

Every evolution should:
- produce a significant power spike (2-3x DPS),
- alter behavior, not just damage,
- reinforce a combat fantasy,
- and remain readable onscreen.

### 7.4 Evolution Trigger

**Recommendation: next level-up after requirements met.**

Why:
- Easier than adding boss-chest pacing right now
- Gives anticipation that instant auto-trigger lacks
- Reuses existing draft UI structure

### 7.5 Current State (Audit)

6 recipes exist in code, all 1:1 pairings:

| Active (Lv5) | + Passive | = Evolution | DPS Change |
|---|---|---|---|
| Bayonet Rush | Gunpowder | Reaper's Bayonet | ~2.5x |
| Mortar Burst | Clockwork | Carpet Bomber | ~3x |
| Arc Discharge | Birdshot | Storm Conduit | ~2x |
| Ember Shells | Quicksilver | Inferno Ring | ~2x |
| Blight Flask | Focusing Lens | Plague Barrage | ~2.5x |
| Seeker Rounds | Extra Powder | Bullet Storm | ~2x |

These are the simplest form of the model. 1:1 pairings create the "solved-build risk" where every weapon has one obvious best passive. Branching evolutions fix this.

### 7.6 Dropped Direction

**Character weapon branching at Lv3/Lv5** (Workshop F1) — conflicts with the unified evolution model. Character weapons should evolve the same way as pool weapons: max level + passive.

---

## 8. Drafting Rules

### 8.1 Offer Composition

The level-up system must offer both actives and passives. Weapon-only drafting is no longer acceptable.

Each level-up presents 3 choices. Choices may include:
- a new weapon,
- a weapon duplicate (level up),
- a new passive,
- or a passive duplicate (level up).

### 8.2 Weighting Principles

The system should bias offers based on state:

- If active slots are low, surface more new actives
- If passive slots are low, surface more new passives
- If many owned items are below cap, surface more duplicates
- If an owned weapon is one step away from evolution, slightly increase supporting passive visibility
- Once a branch is already strongly signaled, avoid overflooding irrelevant options

### 8.3 Forced Choice

No skip remains correct. Forced choice preserves commitment pressure.

### 8.4 Banish and Reroll

Reroll and banish should be treated as run-shaping tools, not solutions for weak content.

- **Banish:** Unlock via Forge (meta progression), start at 1, upgradable to max 5
- **Reroll:** Start at 0 per run, earned entirely through Forge

### 8.5 Current State

- XP curve: `10 * level^1.3` — working
- 3 choices per level-up — working
- Forced choice — working
- Level-up pool generation — **needs rewrite** (currently weapon-only)
- Rerolls: 3 per run default — **needs rework** (should start at 0, earned via Forge)
- Banish: not implemented

---

## 9. Comparison Matrix — M&P vs Survivor.io

| Feature | Survivor.io | M&P Current | M&P Target | Gap |
|---|---|---|---|---|
| Active slots | 6 | 6 | 6 | None |
| Passive slots | 6 | 6 (empty) | 6 | **Passive redesign needed** |
| Starter weapon | 1 (equipped) | 1 (character) | 1 (character) | None |
| Leveling actives | Star system (duplicates) | Level 1-5 via level-up | Same | None |
| Leveling passives | Star system (duplicates) | Level 1-5 via level-up | Same | **Passives need to exist first** |
| Evolution formula | Active max + Passive = Evo | Weapon Lv5 + Passive = Transmute | Same, but branching | **Branching logic needed** |
| Evolution trigger | Boss chest | Auto on conditions met | Next level-up | **Implementation needed** |
| Branching evos | Limited (some combo skills) | None (1:1 only) | Multi-path per weapon | **Major new system** |
| Passive standalone value | Mixed (some are stat sticks) | All stat sticks | Mechanical, build-shaping | **Full redesign needed** |
| Build identity | Strong (slot pressure) | Weak (no passives in pool) | Strong (slot pressure + elements) | **Passives must return to pool** |
| Forced choice | Yes (no skip) | Yes (implemented) | Yes | None |
| Slot pressure | High | Low (only weapons compete) | High (weapons + passives) | **Passives must return to pool** |

---

## 10. Keep / Rewrite / Drop

### 10.1 Keep

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

### 10.2 Rewrite

| System | Current State | What Changes | Effort |
|---|---|---|---|
| Pool weapons (4 of 6) | Archived, generic | Replace with Gravity Lash, Sawblade, Geyser, Drone | **High** |
| Passives (all 8) | Removed from pool, stat sticks | Full redesign with mechanical effects + evo pairing | **High** |
| Evolution system | 1:1 recipes in evolution_db.gd | Branching multi-path, choice UI | **Medium** |
| Level-up pool generation | Weapon-only | Mixed weapons + passives with smart weighting | **Medium** |
| WeaponData / PassiveData | Basic stat containers | Add evo pairing fields, weapon-aware flags | **Low** |

### 10.3 Drop

| Concept | Workshop Source | Why Drop |
|---|---|---|
| Traits (unlimited minor buffs) | C8, D7 | Replaced by 6-slot passive system. Unlimited buffs undermine slot pressure. |
| Artifacts (6 slots from bosses) | C8, D8 | Replaced by passives-as-evo-keys. Middleman layer no longer needed. |
| Character weapon branching at Lv3/Lv5 | F1 | Conflicts with unified evo model. Character weapons evolve via max level + passive. |
| All-weapon-aware traits | D9, E10-E12 | Was for the Traits system which is dropped. Individual passives can still adapt. |
| Tiered trait scaling | E12 | Was for the unlimited-traits model. Passives now have levels. |

---

## 11. Content Scope — First Playable Target

Do not build the full dream version first.

The first truly useful target is:

- 4 character weapons (existing)
- 2 restored pool weapons (Arc Discharge, Seeker Rounds)
- 4 redesigned passives (new, mechanical, with evo pairings)
- 1 evolution branch per active in first pass
- Mixed actives/passives in the draft pool
- One simple evolution choice flow
- No codex required yet
- Minimal celebration VFX acceptable

This is enough to prove that the system produces build identity and meaningful planning. Everything else scales from this foundation.

---

## 12. Open Design Decisions

These must be resolved before full production:

### 12.1 Evolution choice UI
Recommendation: use a level-up style pop-up to minimize new UX complexity.

### 12.2 Initial pool availability
How many of the 6 pool weapons are available from run 1?
- "2 free, 4 unlock progressively" (workshop D12)
- "I'd like more than 2 free, VS has lots off rip" (workshop D12 note)
- Unresolved.

### 12.3 Magma Geyser role
Define whether this is: area denial, repeated vertical burst, delayed lane-clear, or knockup/eruption control.

### 12.4 Passive launch roster
Finalize the first 4-6 actual passives before building the complete data architecture.

### 12.5 Character weapon evolutions
Define at least one evolution for each starter weapon before expanding pool-weapon ambition.

### 12.6 New weapon specs
The 4 replacement weapons have identities but no numbers. Each needs: base damage, scaling per level, fire rate, range, AoE radius, and unique mechanic parameters.

---

## 13. Production Priorities

### Phase 1 — Re-enable Buildcraft
- Redesign first passive batch (4-6 passives)
- Return passives to level-up pool
- Re-enable Arc Discharge and Seeker Rounds
- Implement mixed active/passive offer generation
- Implement one-branch evolution support

### Phase 2 — Prove Build Identity
- Add first evolution branches for all starter weapons
- Add evolution choice flow UI
- Tune offer weighting
- Tune passive usefulness without evolutions (must feel worth taking solo)

### Phase 3 — Expand Roster
- Implement Gravity Lash
- Implement Sawblade Launcher
- Finalize and implement Magma Geyser
- Implement Phantom Sentry
- Add more passives
- Expand multi-branch evolution coverage

### Phase 4 — Polish and Surface Knowledge
- Evolution VFX celebration
- Evolution-ready hinting UI
- Discovered-evolution codex
- Reroll/banish balancing
- Content cleanup and numerical tuning

---

## 14. Creative Content Framework

### 14.1 Content Pillars

Content should express these creative constraints:

**Improvised escalation** — Weapons and supports should feel like unstable or escalating tools that become more dangerous, more specialized, or more visually intense over the course of a run.

**Readable chaos** — The game should support dense, exciting combat states without losing legibility. Builds should feel powerful and dramatic, but their core behavior should still be readable by the player.

**Distinct build fantasies** — Different runs should feel like meaningfully different combat identities, not simply different numerical loadouts.

**Transformation as reward** — Evolutions should feel like earned moments of payoff rather than passive stat inflation.

**Mechanical personality** — Each weapon or support should have a recognizable gameplay attitude: precise, reckless, oppressive, unstable, surgical, greedy, or controlling.

### 14.2 Content Generation Matrix

New active skills can be created by selecting across these dimensions:

**Delivery:** projectile, beam, wave, orbit, trap, summon, burst, chain

**Targeting:** nearest, random, aimed, sweeping arc, returning path, self-centered, delayed lock-on, area-marked

**Damage Pattern:** direct hit, pierce, splash, DoT, ricochet, pulse, detonation, chaining

**Utility:** knockback, pull, slow, stun, shielding, mark, resource gain, zone denial

New passive skills can be generated through:

**Stat Axis:** rate, size, count, duration, velocity, crit, status chance, range

**Rule-Bending Axis:** split, echo, duplicate, convert, overflow, chain, delay, consume

**Build Role:** enabler, amplifier, stabilizer, converter, payoff multiplier, conditional scaler

A new concept should be describable in one sentence using these dimensions.

### 14.3 Target Build Fantasies

The system should intentionally support multiple play fantasies:

- **Precision** — surgical, efficient, deliberate
- **Domination** — area control, persistent effects, oppressive coverage
- **Volatile** — explosive, high-variance, unstable
- **Control** — slows, groups, redirects, contains
- **Greed** — invests early, pays off heavily later
- **Engine** — assembles moving parts into a self-sustaining machine

### 14.4 Creative Evaluation Questions

When reviewing new content:

- What is the fantasy of this content?
- What makes it feel different from existing options?
- Does it create a new decision, or only a bigger number?
- Is its value visible to the player in moment-to-moment play?
- Does it strengthen a build identity or blur one?
- Would a player remember this content after a run?
- Does it open new transformation routes, or only serve existing ones?
- If its optimal pairing is missed, is it still satisfying?

---

## 15. UX and Readability

The player should never feel that the system is only understandable through external charts.

Recommended UI features:

- Support icons visually linked to compatible actives
- Codex entries once combinations are discovered
- Silhouette previews for locked evolutions
- Simple requirement phrasing ("Needs: Arc Discharge Lv5 + [Passive]")
- Progress markers ("2/2 requirements met")
- Hover text or popups that remind the player what a passive currently benefits

---

## 16. Success Criteria

This system pass is successful if:

- Passives are exciting enough to draft even before an evolution payoff
- Runs develop a visible mid-game plan
- Evolutions feel earned and memorable
- The player can describe their build in words, not just numbers
- Late-run combat looks meaningfully different depending on draft choices

---

## 17. Immediate Next-Step Checklist

### Content
- [ ] Finalize first 4 redesigned passive concepts
- [ ] Finalize 1 evolution branch for each starter weapon
- [ ] Write full combat specs for Arc Discharge and Seeker Rounds (un-archive)
- [ ] Decide whether Gravity Lash or Sawblade Launcher is the first new pool weapon

### Systems
- [ ] Return passives to the level-up pool
- [ ] Add mixed active/passive offer generation
- [ ] Implement one-branch evolution eligibility check
- [ ] Implement "next level-up" evolution trigger flow

### UX
- [ ] Add simple evolution-ready UI indicator
- [ ] Add first-pass evolution choice pop-up
- [ ] Add temporary requirement text for debugging and playtests

### Validation
- [ ] Run a vertical slice with 4 starter weapons, 2 pool weapons, and 4 passives
- [ ] Check whether passives feel worth taking before evo payoff
- [ ] Check whether players can describe their build direction by mid-run
- [ ] Check whether late-run builds differ in play texture, not just damage output

---

## 18. Summary

Mortar & Pistol already has the technical bones for a strong buildcraft game: distinctive character weapons, slot infrastructure, level-up UI, and solid combat presentation. What it lacks is a real build layer. The absence of passives from the draft pool and the inactivity of the evolution system flatten the run into a narrow weapon-upgrade loop.

The correct target is a unified run structure where passives return as meaningful picks, actives and passives compete for player planning attention, and evolved weapons act as payoff moments for earlier decisions. The old passive model should not be restored — it should be replaced. The archived weapon roster should not be blindly re-enabled — it should be curated. And the branching evolution model should be introduced in a smaller playable slice before the full content dream is attempted.

The single biggest lever remains:

**Get compelling passives back into the level-up pool and make them matter.**
