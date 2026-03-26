## Epic: Phase 1 passive + evolution vertical slice

### Goal

Implement the first playable passive/evolution slice for Mortar & Pistol using:

* 6 Phase 1 passives
* 6 matching evolutions
* mixed active/passive level-up offers
* next-level-up evolution trigger
* evo choice popup
* restored Arc Discharge and Seeker Rounds

### Non-goals

* no Phase 3+ passives yet
* no new pool weapons yet
* no codex/polish-heavy UX yet
* no final balance pass yet
* no permanent meta systems tied to this work

---

## Issue 1: Add passive support to run state

### Summary

Add passive slots, passive ownership, passive levels, and passive upgrade handling to run state.

### Tasks

* [ ] Add passive slot container to run state
* [ ] Support max passive slot count
* [ ] Add passive ownership tracking
* [ ] Add passive level tracking
* [ ] Support passive duplicate upgrades
* [ ] Expose passive data to combat systems
* [ ] Expose passive data to UI
* [ ] Add debug print/overlay for owned passives and levels

### Acceptance criteria

* [ ] Player can own passives during a run
* [ ] Passive duplicates increase passive level
* [ ] Passive data is readable by weapons/evo logic/UI
* [ ] Debug output shows current passive state

---

## Issue 2: Add mixed level-up offer generation

### Summary

Allow level-up choices to include both actives and passives.

### Tasks

* [ ] Update offer generator to include passives
* [ ] Preserve existing weapon offer flow
* [ ] Add weighting for new passive vs passive duplicate
* [ ] Add weighting for new weapon vs weapon duplicate
* [ ] Bias offers based on empty active/passive slots
* [ ] Bias offers based on owned non-max items
* [ ] Add light support-weighting for near-evo weapons
* [ ] Keep forced-choice behavior
* [ ] Add debug output showing why each offer was selected

### Acceptance criteria

* [ ] Level-up offers can contain passives
* [ ] Offer pool respects active/passive slot state
* [ ] Forced choice still works
* [ ] Debug output can explain offer composition

---

## Issue 3: Implement passive 01 — Magnetism

### Summary

Hits pull enemies slightly toward the impact point. Pull scales by level and must not pixel-stack enemies.

### Tasks

* [ ] Add passive data entry
* [ ] Implement hit-based pull
* [ ] Scale pull strength by passive level
* [ ] Add anti-overlap / anti-pixel-stack cap
* [ ] Ensure effect works across eligible weapon types
* [ ] Add basic VFX/readability feedback
* [ ] Add debug toggle for pull radius/strength

### Acceptance criteria

* [ ] Hits visibly reposition enemies
* [ ] Enemies do not collapse into one point
* [ ] Passive is useful without its evo pairing
* [ ] Effect is readable in dense hordes

---

## Issue 4: Implement passive 02 — Volatile Kill

### Summary

Killed enemies pop for AoE damage and small knockback. Damage scales partly from the killing hit. Elite kills produce larger pops.

### Tasks

* [ ] Add passive data entry
* [ ] Trigger corpse pop on kill
* [ ] Scale pop radius/damage by passive level
* [ ] Add small knockback on pop
* [ ] Scale pop damage partly from killing hit
* [ ] Add elite kill variant
* [ ] Add cap/falloff safeguards for chain-heavy scenarios
* [ ] Add debug counters for pop damage source

### Acceptance criteria

* [ ] Corpse pops are visible and satisfying
* [ ] Passive remains useful against tankier enemies
* [ ] Elite kills create bigger punctuation moments
* [ ] Performance/readability holds in dense fights

---

## Issue 5: Implement passive 03 — Phantom Echo

### Summary

Projectile and burst attacks fire an echo 0.3s later at reduced damage. Echoes cannot re-echo and cannot proc on-hit effects.

### Tasks

* [ ] Add passive data entry
* [ ] Restrict eligibility to projectile and burst attacks
* [ ] Spawn delayed echo shot
* [ ] Apply reduced damage
* [ ] Disable recursive echoing
* [ ] Disable on-hit proc inheritance
* [ ] Exclude beams, AoEs, mines, and other non-eligible attack classes
* [ ] Add translucent/afterimage VFX
* [ ] Add debug logging for eligible vs blocked attacks

### Acceptance criteria

* [ ] Echoes only appear on intended attack classes
* [ ] Echoes cannot recurse
* [ ] Echoes do not duplicate on-hit proc logic
* [ ] Effect reads clearly as a delayed afterimage attack

---

## Issue 6: Implement passive 04 — Ricochet

### Summary

Projectile hits bounce to nearby enemies for reduced damage. Bounce count scales by level.

### Tasks

* [ ] Add passive data entry
* [ ] Implement bounce target acquisition
* [ ] Scale bounce count by passive level
* [ ] Apply reduced damage to bounced hits
* [ ] Prevent infinite loops / same-target abuse
* [ ] Add readable bounce VFX
* [ ] Add debug display for bounce chains

### Acceptance criteria

* [ ] Ricochet turns precision/projectile hits into visible crowd conversion
* [ ] Bounce targeting is readable and stable
* [ ] No looping or broken retarget behavior
* [ ] Passive is useful outside its favored evo pairing

---

## Issue 7: Implement passive 05 — Shrapnel

### Summary

Projectile impacts split into a cone of reduced-damage fragments. Fragments cannot re-fragment.

### Tasks

* [ ] Add passive data entry
* [ ] Restrict to projectile impacts only
* [ ] Spawn fragment cone on hit
* [ ] Apply reduced fragment damage
* [ ] Prevent re-fragmenting
* [ ] Exclude beams/AoEs/non-projectile sources
* [ ] Tune cone width, count, and travel behavior
* [ ] Add debug display for active fragment counts

### Acceptance criteria

* [ ] Impact-to-fragment behavior is clear
* [ ] Rules are consistent across eligible projectiles
* [ ] Fragments do not recurse
* [ ] Visual effect feels messy but readable

---

## Issue 8: Implement passive 06 — Overclock

### Summary

Consecutive hits build visible heat stacks. Max stacks grant fire rate bonus plus an extra payoff behavior. Stacks reset after downtime.

### Tasks

* [ ] Add passive data entry
* [ ] Implement consecutive-hit stack gain
* [ ] Implement timeout/reset after 1s without hits
* [ ] Add visible heat pips / glow / audio ramp
* [ ] Apply fire-rate ramp at stack thresholds
* [ ] Add max-stack bonus behavior hook
* [ ] Add debug overlay for stack count and uptime
* [ ] Verify effect on fast vs slow weapons

### Acceptance criteria

* [ ] Players can see and feel heat ramping
* [ ] Max-stack state is meaningfully different
* [ ] Reset behavior is understandable
* [ ] Passive reads as momentum, not invisible DPS

---

## Issue 9: Restore pool weapons for Phase 1

### Summary

Un-archive Arc Discharge and Seeker Rounds for the Phase 1 slice.

### Tasks

* [ ] Restore Arc Discharge to offer pool
* [ ] Restore Seeker Rounds to offer pool
* [ ] Verify both can appear in mixed drafting
* [ ] Verify both can level correctly
* [ ] Verify both can qualify for their Phase 1 evo
* [ ] Add debug confirmation for evo eligibility

### Acceptance criteria

* [ ] Both weapons are draftable
* [ ] Both weapons level correctly
* [ ] Both weapons can evolve in the new system

---

## Issue 10: Add evolution eligibility system

### Summary

Support weapon evolution eligibility based on maxed weapon + qualifying passive.

### Tasks

* [ ] Add evolution data model
* [ ] Add weapon-to-passive evo mapping
* [ ] Check weapon max-level state
* [ ] Check passive ownership/qualification
* [ ] Support multiple qualifying passives per weapon
* [ ] Expose eligible evolutions to UI/debug systems
* [ ] Add debug panel listing current evo-ready weapons

### Acceptance criteria

* [ ] Weapon becomes evo-eligible only when rules are met
* [ ] Multiple valid branches can be detected
* [ ] Eligibility is inspectable in debug tools

---

## Issue 11: Add next-level-up evolution trigger flow

### Summary

Evolutions should trigger on the next level-up after requirements are met.

### Tasks

* [ ] Detect evo-ready state during run
* [ ] Queue evo selection for next level-up
* [ ] Prevent premature auto-trigger
* [ ] Resolve evo choice before normal level-up picks when needed
* [ ] Consume/replace correct weapon state on evolution
* [ ] Preserve passive state after evolution
* [ ] Add debug logs for evo queue timing

### Acceptance criteria

* [ ] Evo does not trigger instantly on qualification
* [ ] Evo appears reliably on next level-up
* [ ] Evo resolution is stable and repeatable

---

## Issue 12: Add evolution choice popup

### Summary

Show a level-up-style popup when a weapon has one or more valid evolution branches.

### Tasks

* [ ] Build simple popup UI
* [ ] Show weapon ready to evolve
* [ ] Show one or more valid evolution options
* [ ] Show passive requirement satisfied
* [ ] Allow player selection
* [ ] Apply evolved weapon state cleanly
* [ ] Add temporary requirement text for debugging
* [ ] Add placeholder VFX/audio hook

### Acceptance criteria

* [ ] Player can choose between valid evolution branches
* [ ] UI is readable with minimal polish
* [ ] Chosen evo replaces/updates the correct weapon
* [ ] Debug info is available during testing

---

## Issue 13: Implement evolution — Implosion Flask

### Summary

Scatter Flask evo. Creates a short suction window, then detonates.

### Tasks

* [ ] Preserve base lobbed/flask identity
* [ ] Add suction phase before detonation
* [ ] Pull enemies continuously during suction window
* [ ] Add enemy-count bonus with hard cap
* [ ] Detonate after suction delay
* [ ] Tune suction duration and radius
* [ ] Add debug value for enemies caught

### Acceptance criteria

* [ ] Players notice and anticipate the suction window
* [ ] Evo feels like setup + payoff, not just bigger splash
* [ ] Bonus scaling is capped and stable

---

## Issue 14: Implement evolution — Chain-Detonation Keg

### Summary

Powder Keg evo. Kills create unstable corpses that propagate blasts.

### Tasks

* [ ] Preserve keg/area-denial identity
* [ ] Add unstable corpse state on qualifying kills
* [ ] Trigger delayed corpse detonation
* [ ] Allow controlled propagation to nearby kegs/corpses
* [ ] Add elite-sized variant
* [ ] Add chain depth cap and damage falloff
* [ ] Add debug chain-depth display

### Acceptance criteria

* [ ] Corpse propagation is visible and intentional
* [ ] Evo is readable in dense fights
* [ ] Chain behavior is capped and stable

---

## Issue 15: Implement evolution — Ghost Barrage

### Summary

Twin Barrels evo. Becomes spectral crossfire, not just duplicate shots.

### Tasks

* [ ] Preserve Twin Barrels burst identity
* [ ] Add delayed ghost volleys
* [ ] Fire ghost volleys from offset or mirrored positions/angles
* [ ] Prefer untargeted or nearby alternate enemies when possible
* [ ] Add periodic denser spectral burst
* [ ] Add readable spectral VFX
* [ ] Add debug output for ghost target selection

### Acceptance criteria

* [ ] Players read this as crossfire, not simple duplication
* [ ] Evo increases coverage, not just raw volume
* [ ] Ghost targeting behaves predictably enough to tune

---

## Issue 16: Implement evolution — Refraction Beam

### Summary

Bolt Rifle evo. Must stay hitscan/line-based and emit refracted side-beams.

### Tasks

* [ ] Preserve Bolt Rifle hitscan identity
* [ ] Do not convert to projectile behavior
* [ ] Allow main beam to continue through target
* [ ] Emit weaker side-beams toward nearby enemies
* [ ] Tune side-beam count, angle, and range
* [ ] Add beam-web VFX
* [ ] Add debug readout for side-beam spawn counts

### Acceptance criteria

* [ ] Players still describe this as Bolt Rifle
* [ ] Evo feels geometrically amplified, not like a different weapon class
* [ ] Side-beam behavior is readable and tunable

---

## Issue 17: Implement evolution — Cluster Salvo

### Summary

Seeker Rounds evo. Missiles burst into short-lived submunitions.

### Tasks

* [ ] Preserve homing missile identity
* [ ] Burst missile into submunitions on hit/expiry
* [ ] Reacquire nearby targets aggressively
* [ ] Give submunitions short lifetime
* [ ] Prevent overlong homing / autopilot behavior
* [ ] Add submunition VFX/readability treatment
* [ ] Add debug count for active submunitions

### Acceptance criteria

* [ ] Evo feels like guided swarm pressure
* [ ] Submunitions do not linger excessively
* [ ] Visual noise stays manageable

---

## Issue 18: Implement evolution — Storm Engine

### Summary

Arc Discharge evo. Must feel like a maintained overload state, not a flat always-on buff.

### Tasks

* [ ] Preserve Arc Discharge chain-lightning identity
* [ ] Tie enhanced state to Overclock heat/max-stack state
* [ ] Add forked secondary branches during overload
* [ ] Increase arc count/range in overload
* [ ] Add periodic overload pulse
* [ ] Collapse extra behavior when heat drops
* [ ] Add debug overlay for overload uptime and branch counts

### Acceptance criteria

* [ ] Players feel ramp → peak → loss rhythm
* [ ] Evo is not permanently maxed without upkeep
* [ ] Overload state is readable and tuneable

---

## Issue 19: Add programmer debug overlay

### Summary

Expose run-critical systems for fast tuning and bug detection.

### Tasks

* [ ] Show owned weapons + levels
* [ ] Show owned passives + levels
* [ ] Show evo-ready weapons
* [ ] Show qualifying passives per evo-ready weapon
* [ ] Show Overclock stacks
* [ ] Show Ghost Barrage target selection
* [ ] Show Cluster Salvo active child count
* [ ] Show Chain-Detonation chain depth
* [ ] Show recent offer-generation reasoning

### Acceptance criteria

* [ ] All core state is inspectable in a test run
* [ ] Debug info speeds up tuning and bug isolation

---

## Issue 20: Phase 1 validation pass

### Summary

Run focused playtests on the vertical slice before expanding content.

### Tasks

* [ ] Run tests with 4 starter weapons, 2 pool weapons, 6 passives
* [ ] Check whether passives feel worth taking before evo payoff
* [ ] Check whether players form a build plan by mid-run
* [ ] Check whether first evo creates too much snowball
* [ ] Check whether evolved weapons change texture, not just damage
* [ ] Check whether visual clarity holds in dense hordes
* [ ] Identify dominant passive if one emerges too quickly
* [ ] Record tuning issues before adding new content

### Acceptance criteria

* [ ] Team can name which passives are fun vs weak
* [ ] Team can identify whether mixed drafting creates real tension
* [ ] Expansion work is blocked until this review is complete

---

## Nice-to-have label suggestions

* `combat`
* `systems`
* `passives`
* `evolutions`
* `ui`
* `debug`
* `phase-1`
* `vertical-slice`
* `needs-tuning`

## Suggested milestone name

**Phase 1 — Re-enable Buildcraft**
