Here’s a more “internal design doc” version.

# Weapon Evolution and Support Skill System

## Purpose

Define a run-based combat upgrade system in which players assemble temporary builds through active weapons, passive support skills, and transformation rules that reward planning, synergy, and adaptation.

---

## 1. Background

This document outlines a combat progression model inspired by games like Survivor.io, where the player builds power during a single run by selecting offensive and supportive upgrades from randomized or semi-randomized choices. The reference model distinguishes between **Active Skills** and **Passive Skills**, with certain passives acting as prerequisites for weapon evolutions. Community documentation for Survivor.io describes skills as run-based, split between active and passive categories, with active skills reaching an EVO state when paired with the correct support requirement. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Skills)) The associated evolution guide further frames evolved skills as stronger end states that may increase damage and/or change functionality. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Weapon_Skill_Evolution_Guide))

The goal of this design is not to replicate that structure one-for-one, but to formalize the parts of it that create strong player decision-making and satisfying pacing.

---

## 2. Purpose

The purpose of this system is to:

* create meaningful run-to-run build variety,
* make upgrade drafting strategically interesting,
* produce recognizable mid-run and late-run power spikes,
* encourage player planning without overcomplicating the rules,
* and support a wide range of combat identities through modular combinations.

This system should make players feel that they are gradually **authoring a build**, not simply accumulating raw stats.

---

## 3. Scope

This document covers:

* active weapon acquisition and progression,
* passive support acquisition and progression,
* transformation and evolution rules,
* build-slot constraints,
* progression triggers,
* system readability,
* and recommended extensions for originality.

This document does **not** cover:

* enemy design,
* encounter pacing,
* monetization systems,
* permanent metaprogression,
* character rosters,
* or economy tuning outside the run.

---

## 4. Design Pillars

### 4.1 Immediate readability

The player should quickly understand what each picked upgrade does in the moment.

### 4.2 Delayed payoff

The system should reward planning by allowing present decisions to unlock future spikes.

### 4.3 Dual-purpose support choices

Support upgrades should always provide immediate value while also enabling future synergy.

### 4.4 Constrained commitment

The player should not be able to take everything. Build identity should emerge because slots, offerings, and timing force tradeoffs.

### 4.5 Expressive variety

Different runs should feel functionally different, not just numerically different.

---

## 5. Definitions

### Active Skill

A weapon or combat ability that directly affects gameplay through attack, defense, control, utility, or summon behavior.

### Passive Skill

A support upgrade that modifies stats, timing, targeting, area, utility, or transformation eligibility.

### Evolution

A powered-up state of an Active Skill unlocked after satisfying defined requirements.

### Fusion

A special transformation produced by combining two actives or other uncommon rule sets.

### Trigger Event

The gameplay event that finalizes a transformation once its requirements are met.

### Build

The total set of Active and Passive Skills currently owned by the player in a run.

### Archetype Tag

A design classification assigned to content for cross-system synergy, such as projectile, burn, electric, summon, orbit, tech, curse, or aura.

---

## 6. Player Fantasy

The player should feel like they are:

* improvising under pressure,
* chasing combinations,
* gradually discovering a build identity,
* and being rewarded for setting up a payoff before the game explicitly hands it to them.

The emotional arc should be:

* uncertainty at the start,
* intention in the middle,
* transformation at the spike,
* mastery near the end.

---

## 7. System Summary

The player begins a run with a starter weapon or equivalent baseline active. As the run progresses, the player earns upgrade choices. These choices can award either new Active Skills, upgrades to existing Active Skills, Passive Skills, or upgrades to existing Passive Skills. Actives are the main source of visible combat expression. Passives improve the efficiency, scale, or behavior of these systems and can also unlock evolutions.

The reference model in Survivor.io uses five standard upgrade levels plus EVO for applicable skills. The community documentation also notes that specific passives are linked to specific actives for transformation purposes. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Skills))

A generalized formula is:

**Active at max base rank + required support state + trigger event = transformed active**

This transformation should be powerful enough to feel meaningful, but not so overwhelming that it invalidates other build choices.

---

## 8. Functional Goals

The system should:

1. reward planning without requiring memorization-only play,
2. make support picks feel like real decisions rather than taxes,
3. preserve tension by limiting slots and choice availability,
4. provide clear milestones during the run,
5. allow designers to author both reliable synergies and surprising exceptions,
6. and scale well as more content is added.

---

## 9. Core Components

## 9.1 Starter Weapon

The player begins with a baseline combat tool. In the Survivor.io model, the equipped weapon functions as one of the run’s actives. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Skills))

**Responsibilities**

* establish initial play feel,
* provide the first build anchor,
* and shape early drafting incentives.

**Design note**
The starter should be viable enough to matter, but not so self-sufficient that it removes interest from later upgrades.

---

## 9.2 Active Skills

Active Skills define most of the run’s visible gameplay. They may include:

* projectiles,
* beams,
* orbitals,
* summoned entities,
* traps,
* explosions,
* area control effects,
* reactive shields,
* or mobility-linked offense.

**Responsibilities**

* provide the main combat identity,
* produce visually readable changes as the build develops,
* and create combinatorial relationships with supports and other actives.

**Good active design should include**

* a clear role,
* a recognizable growth pattern,
* compatibility with more than one support philosophy,
* and at least one satisfying transformation path.

---

## 9.3 Passive Skills

Passive Skills provide the second half of the build. In the reference model, they improve stats such as range, cooldown, health, duration, movement, or projectile-related behavior, while also acting as evo prerequisites. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Skills))

**Responsibilities**

* make the current build better immediately,
* signal intended future direction,
* and act as structural glue between build pieces.

**Risk**
If passives exist only as unlock keys, they become taxes.

**Requirement**
Each passive must feel worth taking even if the linked transformation is never completed.

---

## 9.4 Evolutions

An evolution is a transformed state of an active that is unlocked after prerequisites are met. The Survivor.io evolution guide states that evolutions are stronger final forms and may alter function in addition to damage. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Weapon_Skill_Evolution_Guide))

**Responsibilities**

* provide a reward for planning,
* create pacing peaks,
* reinforce build identity,
* and visually/mechanically communicate advancement.

**Good evolutions should**

* clearly feel stronger,
* meaningfully alter texture or utility,
* and preserve room for the rest of the build to matter.

---

## 10. System Flow

### 10.1 Start of run

Player begins with a starter weapon and no or few supports.

### 10.2 Early drafting

Upgrade choices prioritize survival and initial identity formation.

### 10.3 Mid-run commitment

The player starts choosing between:

* immediate raw power,
* support pieces for planned evolutions,
* and broader synergy shaping.

### 10.4 Requirement completion

The player caps an active and acquires its linked support or equivalent condition.

### 10.5 Trigger event

A chest, shrine, forge, boss reward, wave-end interaction, or similar event finalizes the transformation. BlueStacks’ explanation of Survivor.io describes boss chests as the event that triggers evolution after requirements are met. ([bluestacks.com](https://www.bluestacks.com/blog/game-guides/survivor-io/sio-skills-evolution-guide-en.html))

### 10.6 Late-run optimization

The player refines the remaining slots around evolved or soon-to-evolve pieces.

---

## 11. Decision Model

Each choice should operate on at least one of three time horizons.

### 11.1 Tactical horizon

“What keeps me alive right now?”

### 11.2 Synergy horizon

“What gets me closer to a transformation or meaningful interaction?”

### 11.3 Identity horizon

“What kind of run am I building overall?”

The strongest version of this system makes players feel tension between these horizons rather than letting one dominate every decision.

---

## 12. Transformation Models

A stronger original game should support multiple transformation types.

### 12.1 Standard Evolution

**Active + Passive**

Most readable and should form the backbone of the system.

### 12.2 Fusion Evolution

**Active + Active**

Higher novelty, rarer, and useful for signature or “wow” moments. Survivor.io’s combination skills provide precedent for this structure, such as drone combinations and modular mine combinations. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Weapon_Skill_Evolution_Guide))

### 12.3 Conditional Evolution

**Active + Environment / State / Resource Condition**

Examples:

* while cursed,
* at max heat,
* after X elite kills,
* while under shield,
* while low health,
* in a specific biome,
* with enough combo meter.

### 12.4 Branching Evolution

**One active + multiple possible support routes**

This is one of the best opportunities to improve on the reference model.

---

## 13. Content Authoring Rules

To keep the system scalable, each active should be authored with the following fields:

* role,
* base behavior,
* upgrade path,
* transformation routes,
* archetype tags,
* priority stats,
* visual language,
* intended synergies,
* and failure-state usefulness.

Each passive should be authored with:

* immediate effect,
* scaling behavior,
* linked evolutions,
* archetype tags,
* possible mechanical conversions,
* and anti-tax justification.

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

* projectile
* beam
* wave
* orbit
* trap
* summon
* burst
* chain

**Targeting**

* nearest target
* random target
* aimed direction
* sweeping arc
* returning path
* self-centered
* delayed lock-on
* area-marked

**Damage Pattern**

* direct hit
* pierce
* splash
* damage over time
* ricochet
* pulse
* detonation
* chaining

**Utility**

* knockback
* pull
* slow
* stun
* shielding
* mark application
* resource gain
* zone denial

**Source Fantasy**

* improvised tech
* energy
* industrial
* biological
* occult
* elemental
* corrupted
* cosmic

A new Active concept should ideally be describable in one sentence using these dimensions.

Example:
An improvised-tech orbital that pulses outward and pulls enemies inward.

This is already enough structure to begin shaping:

* visual identity,
* role,
* support pairings,
* transformation routes,
* and archetype tags.

Passive Skills can be generated through a similar matrix:

**Stat Axis**

* rate
* size
* count
* duration
* velocity
* crit
* status chance
* range

**Rule-Bending Axis**

* split
* echo
* duplicate
* convert
* overflow
* chain
* delay
* consume

**Build Role**

* enabler
* amplifier
* stabilizer
* converter
* payoff multiplier
* conditional scaler

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

* What is the fantasy of this content?
* What makes it feel different from existing options?
* Does it create a new decision, or only a bigger number?
* Is its value visible to the player in moment-to-moment play?
* Does it strengthen a build identity or blur one?
* Would a player remember this content after a run?
* Does it open new transformation routes, or only serve existing ones?
* If its optimal pairing is missed, is it still satisfying?

These questions should be used during ideation and review, especially when deciding whether a concept deserves implementation.

### 14.5 Content Gap Tracking

As the content pool expands, the team should track missing or underrepresented areas such as:

* underused delivery types,
* missing source fantasies,
* archetypes with too few supports,
* play fantasies with too few viable builds,
* and transformations that do not yet have compelling alternatives.

This prevents content growth from clustering too heavily around only the easiest or most obvious ideas.

### 14.6 Implementation Guidance

For early production, new content should be created in small batches with intentional spread across fantasy, function, and complexity.

Recommended early batch structure:

* 3 to 5 starter-style actives,
* 5 to 8 secondary actives,
* 8 to 12 passives,
* and at least 1 to 2 branching or conditional transformations.

This ensures that the first playable version can already demonstrate contrast between build identities rather than only proving out the base rules.

---

## 15. UX and Readability Notes

The player should never feel that the system is only understandable through external charts.

Recommended UI features:

* support icons visually linked to compatible actives,
* codex entries once combinations are discovered,
* silhouette previews for locked evolutions,
* simple requirement phrasing,
* progress markers like “2 requirements met,”
* and hover text or popups that remind the player what a support currently benefits.

The reference model is memorable partly because the pairings are concrete and repeated, but a modernized version should externalize more of that information in the UI. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Weapon_Skill_Evolution_Guide))

---

## 16. Example Reference Pairing Logic

The Survivor.io evolution guide demonstrates the core logic clearly through examples such as:

* Kunai + Koga Ninja Scroll = Spirit Shuriken
* Shotgun + Hi-Power Bullet = Gatling
* Lightning Emitter + Energy Cube = Supercell
* Guardian + Exo-Bracer = Defender ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Weapon_Skill_Evolution_Guide))

What makes these useful reference examples is not the specific content names, but the structure:

* clear one-to-one relationships,
* thematic pairing,
* sensible support relevance,
* and noticeable payoff.

These qualities should be preserved even if your game uses a broader branching system.

---

## 17. Risks

### 17.1 Solved-build risk

If every active has one obvious best pairing, the system becomes repetitive.

### 17.2 Support-tax risk

If a passive is only selected to unlock an evo, it is not carrying enough standalone value.

### 17.3 Visual-noise risk

If too many actives and effects overlap, evolved states lose clarity and impact.

### 17.4 Memorization burden

If required pairings are too opaque, players may disengage or rely on external references.

### 17.5 Snowball collapse

If the first evolution is too dominant, the rest of the run’s choices stop mattering.

---

## 18. Open Questions

These are good questions to answer during implementation:

* How many active and passive slots should a player have?
* Should every active have one transformation, multiple transformations, or none?
* Are transformations permanent once triggered?
* How visible should recipe information be before first discovery?
* Should passives stack linearly, multiplicatively, or through mechanic changes?
* How often should trigger events appear?
* Should fusion evolutions replace one or both source actives?
* How much of the system should be deterministic versus random?
* Should some transformations depend on broader archetype totals instead of exact pairings?

---

## 19. Recommendations for Original Implementation

To preserve the strengths of the reference model while making your own system feel fresher, I’d recommend:

### Keep

* starter weapon as part of run identity,
* active/passive split,
* support skills with dual purpose,
* transformation trigger moments,
* slot-based pressure.

### Expand

* branching evolutions,
* archetype tags,
* intermediate breakpoints,
* more expressive passives,
* conditional transformation types.

### Avoid

* one-note stat sticks,
* fully hidden recipes,
* mandatory passives with no independent value,
* and evolutions that are only bigger numbers.

---

## 21. Example Original System Spec

### Active

**Arc Node**
Role: chain damage / crowd control
Tags: electric, projectile, tech

### Supports

**Capacitor**
Effect: lower interval between pulses
Also enables: Overload Core

**Prism Lens**
Effect: additional bounce target
Also enables: Split Current

**Reactor Gel**
Effect: arc hits apply burn buildup
Also enables: Plasma Surge

### Evolutions

**Overload Core**
Arc frequency increase, higher chain density

**Split Current**
Each chain forks into secondary arcs

**Plasma Surge**
Arc damage ignites enemies and triggers delayed explosions

This example shows how a single active can support multiple destinies instead of only one “correct” support key.

---

## 22. Summary

This system works because it combines readable upgrades with layered payoff timing. The player makes frequent choices among immediate survival, future synergy, and broader build identity. Active Skills define the visible combat texture. Passive Skills provide both utility and transformational structure. Evolutions create anticipation, payoff, and pacing peaks. Community documentation for Survivor.io shows this model in a relatively simple form, with active/passive separation, max-rank skill growth, and support-gated evolutions. ([survivorio.fandom.com](https://survivorio.fandom.com/wiki/Skills))

For your own project, the best path is to preserve the structure of:

* **temporary run buildcrafting**
* **dual-purpose support upgrades**
* **planned transformation payoffs**
* **slot-limited decision pressure**

while improving the formula through:

* branching outcomes,
* stronger passive identity,
* better UI communication,
* and more flexible transformation logic.
