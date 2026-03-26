# Mortar & Pistol — Combat Build System
## Target Design Document

## Purpose

Define the target combat build system for Mortar & Pistol. This document describes the intended run structure, upgrade model, passive philosophy, evolution rules, content requirements, and implementation priorities for the next major systems pass.

This document is not primarily an audit of the old system. It is the specification for the system the game should become.

---

## 1. Product Goal

Mortar & Pistol should feel like a game where the player **authors a build during the run**, not a game where the player simply upgrades damage output over time.

The target experience is:

- a strong starter identity through an exclusive character weapon,
- meaningful build expansion through secondary weapons,
- real planning tension through passive selection,
- and memorable power spikes through weapon evolutions.

The current game already has working slot infrastructure, functioning level-up UI, strong character weapons, and solid technical foundations, but it does not yet produce enough mid-run planning or late-run transformation because passives are absent from the draft pool and evolutions are effectively inactive.

---

## 2. Core Design Outcome

The intended model is:

- **6 active slots**
- **6 passive slots**
- **1 locked starter weapon**
- **5 additional active slots filled during the run**
- **passives drafted from the same level-up ecosystem as weapons**
- **weapons and passives upgraded by duplicates**
- **max-level weapon + qualifying passive = evolution**
- **some weapons support multiple passive pairings and therefore multiple evolutions**

This structure is the core of the system. Everything else exists to support it.

---

## 3. Player Experience Goals

The system must create four feelings over the course of a run:

### 3.1 Early uncertainty
The player is improvising from incomplete information and trying to stabilize.

### 3.2 Mid-run intention
The player begins making choices that point toward a future build rather than only immediate survival.

### 3.3 Evolution payoff
The player reaches a threshold where preparation turns into a noticeable transformation.

### 3.4 Late-run mastery
The player feels that the build has become coherent, expressive, and stronger in a way that reflects previous choices.

---

## 4. System Pillars

### 4.1 Starter identity matters
Each character begins with a distinctive weapon that defines early play feel and remains relevant throughout the run.

### 4.2 Passives are full build pieces
Passives are not filler. They must provide immediate gameplay value, visible impact, and evolution relevance.

### 4.3 Slot pressure creates build identity
Because active and passive slots are limited, every pick closes some doors while opening others.

### 4.4 Evolutions are earned spikes
An evolution should feel like a milestone, not a routine stat bump.

### 4.5 Build paths should be understandable
Players should be able to recognize how their choices are shaping the run without needing external documentation.

---

## 5. Run Structure

### 5.1 Start of run
The player begins with a character weapon in Active Slot 1.

### 5.2 Draft loop
Each level-up presents three choices. Choices may include:
- a new weapon,
- a weapon duplicate,
- a new passive,
- or a passive duplicate.

### 5.3 Capacity pressure
If a slot type is full, future choices skew toward upgrades rather than acquisitions.

### 5.4 Build development
As the run progresses, the player chooses between:
- immediate survival,
- passive setup for future evolutions,
- and broader build identity.

### 5.5 Evolution point
When a weapon reaches max level and the player owns one or more qualifying passives, an evolution becomes available.

### 5.6 End-state build
The final build should reflect a sequence of tradeoffs, not a random pile of upgrades.

---

## 6. Active Weapons

### 6.1 Character Weapons

The following four character weapons are working and remain core to the design:

- **Bolt Rifle** — long-range beam / piercing identity
- **Scatter Flask** — lobbed burst / spread identity
- **Powder Keg** — planted explosive / area denial identity
- **Twin Barrels** — rapid aggressive burst-fire identity

These weapons already have strong implementation value and should stay. The required change is not replacement but integration into the shared evolution model so character weapons evolve the same way pool weapons do.

#### Character weapon requirements
Each character weapon needs:
- 2 evolution branches minimum,
- a distinct role per branch,
- paired passive support,
- and a visual payoff moment.

### 6.2 Pool Weapons

The pool weapon roster should support complementary combat fantasies rather than overlap with starter identities.

#### Keep
- **Arc Discharge** — chain-lightning fantasy
- **Seeker Rounds** — homing barrage fantasy

#### Replace
- Bayonet Rush
- Mortar Burst
- Ember Shells
- Blight Flask

The reasoning is to remove weapons that overlap too much with stronger starter identities or lack enough mechanical personality, while preserving distinct combat categories worth keeping.

#### New pool targets
- **Gravity Lash** — spacing / knockback / enemy-collision weapon
- **Sawblade Launcher** — return-path boomerang weapon
- **Magma Geyser** — eruption weapon that still needs a final role definition
- **Phantom Sentry** — mobile drone companion weapon

These should not move to implementation until each has a full spec covering cadence, range, scaling, area behavior, and intended evo routes.

---

## 7. Passive System

### 7.1 Passive design mandate

The passive system must be rebuilt from scratch.

The old passive model was dominated by flat stat boosts such as damage, fire rate, projectile speed, pickup range, and area, with only a small number of standouts that produced a visibly different feel. That kind of passive design is too shallow to carry the build layer.

### 7.2 Passive requirements

Every passive must satisfy all four of these conditions:

#### Immediate value
The player should feel a difference immediately after taking it.

#### Visible impact
The passive should alter something noticeable in combat, not just backend efficiency.

#### Evolution role
The passive should unlock or influence one or more evolution routes.

#### Identity contribution
The passive should support a recognizable build fantasy.

### 7.3 Passive philosophy

A good passive is not “+x% to a stat.”

A good passive is a **build-shaping rule** that may also carry some stat value.

Examples of good passive behavior categories:
- extra instances
- modified targeting
- chain extension
- return-path enhancement
- impact conversion
- conditional bursts
- enemy grouping
- overflow or duplication behavior
- synergy with owned weapon types

### 7.4 Passive content requirement

The target roster should include:
- **8–12 launch passives**
- at least **one visible effect path per passive**
- at least **1–2 linked evolutions per passive**
- at least **one passive per major weapon family or combat fantasy**

---

## 8. Evolution System

### 8.1 Base rule

A weapon evolution requires:
- a max-level weapon,
- a qualifying passive,
- and an evolution trigger.

### 8.2 Branching rule

A weapon may support multiple evolutions.

If the player owns multiple qualifying passives when the weapon is eligible, the player chooses which evolution to take.

### 8.3 Evolution standard

Every evolution should:
- produce a significant power spike,
- alter behavior, not just damage,
- reinforce a combat fantasy,
- and remain readable onscreen.

### 8.4 Evolution trigger recommendation

**Use “next level-up after requirements met” as the default trigger.**

Why:
- easier than adding full boss-chest pacing right now,
- gives anticipation that instant auto-trigger lacks,
- and reuses existing draft UI structure.

---

## 9. Drafting Rules

### 9.1 Offer composition

The level-up system must offer both actives and passives.

Weapon-only drafting is no longer acceptable for the target design.

### 9.2 Weighting principles

The system should bias offers based on state:

- if active slots are low, surface more new actives
- if passive slots are low, surface more new passives
- if many owned items are below cap, surface more duplicates
- if an owned weapon is one step away from evolution, slightly increase supporting passive visibility
- once a branch is already strongly signaled, avoid overflooding irrelevant options

### 9.3 Forced choice stays

No skip remains correct. Forced choice preserves commitment pressure.

### 9.4 Banish and reroll

Reroll and banish should be treated as run-shaping support tools, not solutions for weak content.

---

## 10. Content Scope for First Playable Target

Do not build the full dream version first.

The first truly useful target is:

- 4 character weapons
- 2 restored pool weapons
- 4 redesigned passives
- 1 evolution branch per active in first pass
- mixed actives/passives in the draft pool
- one simple evolution choice flow
- no codex required yet
- minimal celebration VFX acceptable

---

## 11. Keep / Rewrite / Drop

### 11.1 Keep
- character weapons
- 6+6 slot model
- forced 3-choice level-ups
- XP gem loop
- dash system
- weapon strategy pattern
- object pools
- signal bus
- current VFX style

### 11.2 Rewrite
- passive roster
- level-up pool generation
- evolution data structure
- evolution choice flow
- archived pool weapon roster
- weapon/passive content definitions

### 11.3 Drop
- unlimited trait model
- artifact middle-layer model
- separate special-case character-weapon evo logic
- universal always-weapon-aware trait philosophy from earlier workshop versions

---

## 12. Open Design Decisions

These must be resolved before full production:

### 12.1 Evolution trigger timing
Recommendation: next level-up after requirements met.

### 12.2 Evolution choice UI
Recommendation: use a level-up style pop-up to minimize new UX complexity.

### 12.3 Initial pool availability
Decide how many pool weapons are available from run 1 versus unlock-gated later.

### 12.4 Magma Geyser role
Define whether this is:
- area denial,
- repeated vertical burst,
- delayed lane-clear,
- or knockup/eruption control.

### 12.5 Passive launch roster
Finalize the first 4–6 actual passives before building the complete data architecture.

### 12.6 Character weapon branches
Define at least one evolution for each starter weapon before expanding pool-weapon ambition.

---

## 13. Production Priorities

### Phase 1 — Re-enable buildcraft
- redesign first passive batch
- return passives to level-up pool
- re-enable Arc Discharge and Seeker Rounds
- implement mixed offer generation
- implement one-branch evo support

### Phase 2 — Prove build identity
- add first evolution branches for all starter weapons
- add evolution choice flow
- tune weighting
- tune passive usefulness without evolutions

### Phase 3 — Expand roster
- implement Gravity Lash
- implement Sawblade Launcher
- finalize Magma Geyser
- implement Phantom Sentry
- add more passives
- expand multi-branch evo coverage

### Phase 4 — Polish and surface knowledge
- evo VFX celebration
- evo hinting UI
- discovered-evolution codex
- reroll/banish balancing
- content cleanup and numerical tuning

---

## 14. Creative Content Framework

The purpose of this section is to support content invention, not just system integrity. The earlier sections define how the system should function. This section defines how new weapons, supports, and build paths should be generated in a way that preserves identity, variety, and creative momentum during development.

A strong combat system can still produce weak content if new additions are created ad hoc without a consistent invention framework. This section is intended to reduce blank-page design and provide a repeatable method for generating original, high-value content.

### 14.1 Content Pillars

Content should be designed to express a small set of repeated creative pillars. These pillars should act as filters when evaluating whether a new Active, Passive, or Evolution belongs in the game.

Recommended content pillars:

**Improvised escalation**  
Weapons and supports should feel like unstable or escalating tools that become more dangerous, more specialized, or more visually intense over the course of a run.

**Readable chaos**  
The game should support dense, exciting combat states without losing legibility. Builds should feel powerful and dramatic, but their core behavior should still be readable by the player.

**Distinct build fantasies**  
Different runs should feel like meaningfully different combat identities, not simply different numerical loadouts.

**Transformation as reward**  
Evolutions and fusions should feel like earned moments of payoff rather than passive stat inflation.

**Mechanical personality**  
Each weapon or support should have a recognizable gameplay attitude, such as precise, reckless, oppressive, unstable, surgical, greedy, or controlling.

These pillars should be used as creative constraints. A new piece of content does not need to satisfy all of them equally, but it should contribute clearly to at least one.

### 14.2 Content Generation Matrix

New content should be generated by combining a small number of design axes rather than beginning from an empty concept space. This allows ideation to remain structured while still producing a wide range of outcomes.

Each new Active Skill can be created by selecting across the following dimensions:

**Delivery**
- projectile
- beam
- wave
- orbit
- trap
- summon
- burst
- chain

**Targeting**
- nearest target
- random target
- aimed direction
- sweeping arc
- returning path
- self-centered
- delayed lock-on
- area-marked

**Damage Pattern**
- direct hit
- pierce
- splash
- damage over time
- ricochet
- pulse
- detonation
- chaining

**Utility**
- knockback
- pull
- slow
- stun
- shielding
- mark application
- resource gain
- zone denial

**Source Fantasy**
- improvised tech
- energy
- industrial
- biological
- occult
- elemental
- corrupted
- cosmic

A new Active concept should ideally be describable in one sentence using these dimensions.

Example:
An improvised-tech orbital that pulses outward and pulls enemies inward.

This is already enough structure to begin shaping:
- visual identity,
- role,
- support pairings,
- transformation routes,
- and archetype tags.

Passive Skills can be generated through a similar matrix:

**Stat Axis**
- rate
- size
- count
- duration
- velocity
- crit
- status chance
- range

**Rule-Bending Axis**
- split
- echo
- duplicate
- convert
- overflow
- chain
- delay
- consume

**Build Role**
- enabler
- amplifier
- stabilizer
- converter
- payoff multiplier
- conditional scaler

This approach makes ideation more repeatable and makes it easier to intentionally fill content gaps.

### 14.3 Target Build Fantasies

The system should intentionally support multiple successful play fantasies. These should be defined early so that new content is not evaluated only on damage potential.

Recommended target fantasies include:

**Precision build**  
A build that feels surgical, efficient, and deliberate.

**Domination build**  
A build that overwhelms the screen through area control, persistent effects, or oppressive coverage.

**Volatile build**  
A build that feels unstable, explosive, and high-variance.

**Control build**  
A build that slows, groups, redirects, or contains enemies more than it directly bursts them down.

**Greed build**  
A build that scales slowly, asks the player to invest early, and pays off heavily later.

**Engine build**  
A build that feels like it is assembling moving parts into a self-sustaining machine.

Each archetype does not need to be equally represented at the start of development, but the project should aim to support multiple fantasies so that runs develop unique emotional texture.

### 14.4 Creative Evaluation Questions

When reviewing a new Active, Passive, or Evolution, use the following questions:

- What is the fantasy of this content?
- What makes it feel different from existing options?
- Does it create a new decision, or only a bigger number?
- Is its value visible to the player in moment-to-moment play?
- Does it strengthen a build identity or blur one?
- Would a player remember this content after a run?
- Does it open new transformation routes, or only serve existing ones?
- If its optimal pairing is missed, is it still satisfying?

These questions should be used during ideation and review, especially when deciding whether a concept deserves implementation.

### 14.5 Content Gap Tracking

As the content pool expands, the team should track missing or underrepresented areas such as:

- underused delivery types,
- missing source fantasies,
- archetypes with too few supports,
- play fantasies with too few viable builds,
- and transformations that do not yet have compelling alternatives.

This prevents content growth from clustering too heavily around only the easiest or most obvious ideas.

### 14.6 Implementation Guidance

For early production, new content should be created in small batches with intentional spread across fantasy, function, and complexity.

Recommended early batch structure:
- 3 to 5 starter-style actives,
- 5 to 8 secondary actives,
- 8 to 12 passives,
- and at least 1 to 2 branching or conditional transformations.

This ensures that the first playable version can already demonstrate contrast between build identities rather than only proving out the base rules.

---

## 15. UX and Readability Notes

The player should never feel that the system is only understandable through external charts.

Recommended UI features:

- support icons visually linked to compatible actives,
- codex entries once combinations are discovered,
- silhouette previews for locked evolutions,
- simple requirement phrasing,
- progress markers like “2 requirements met,”
- and hover text or popups that remind the player what a support currently benefits.

A modernized version should externalize more of this information directly in the UI.

---

## 16. Success Criteria

This system pass is successful if:

- passives are exciting enough to draft even before an evo payoff,
- runs develop a visible mid-game plan,
- evolutions feel earned and memorable,
- the player can describe their build in words, not just numbers,
- and late-run combat looks meaningfully different depending on draft choices.

---

## 17. Immediate Next-Step Checklist

### Content
- [ ] Finalize first 4 redesigned passive concepts
- [ ] Finalize 1 evolution branch for each starter weapon
- [ ] Write full combat specs for Arc Discharge and Seeker Rounds
- [ ] Decide whether Gravity Lash or Sawblade Launcher is the next new pool weapon

### Systems
- [ ] Return passives to the level-up pool
- [ ] Add mixed active/passive offer generation
- [ ] Implement one-branch evolution eligibility check
- [ ] Implement “next level-up” evolution trigger flow

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

Mortar & Pistol already has the technical bones for a strong buildcraft game: distinctive character weapons, slot infrastructure, level-up UI, and solid combat presentation. What it lacks is a real build layer. Right now the absence of passives from the draft pool and the inactivity of the evolution system flatten the run into a narrower weapon-upgrade loop.

The correct target is a unified run structure where passives return as meaningful picks, actives and passives compete for player planning attention, and evolved weapons act as payoff moments for earlier decisions. The old passive model should not be restored; it should be replaced. The archived weapon roster should not be blindly re-enabled; it should be curated. And the branching evolution model should be introduced in a smaller playable slice before the full content dream is attempted.

The single biggest lever remains the same:

**Get compelling passives back into the level-up pool and make them matter.**