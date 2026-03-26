# Passives & Evolutions — Phase 1 Spec

## Status: APPROVED FOR PROTOTYPE — REVISED WITH DESIGN FIXES

This document contains the finalized passive roster and evolution specs for Phase 1 (Re-enable Buildcraft), with additional mechanical guardrails and clarity fixes added after review. The core roster remains the same, but several evolutions and tuning notes have been sharpened to preserve weapon identity, reduce overlap, and improve standalone passive value. 

---

## 1. Passive Roster

### Design Rules (Apply to All)

- Every passive is a **verb**, not a number. It changes how combat looks and feels.
- Every passive must pass the test: **"Would I still be happy to draft this if its evo target never showed up?"**
- Every passive has: immediate value, visible impact, evolution role, identity contribution.
- All Phase 1 passives are deliberately offense/spectacle-forward. Future phases should add control, survivability, economy, reliability, and zone-shaping passives.
- Every passive should have a **clear eligible weapon scope** if its effect would otherwise become universal or degenerate.
- Every evolution should answer one question clearly: **what changes besides damage?**

---

### 1.1 Magnetism

**Fantasy:** Spatial setup — your hits pull enemies together, creating kill zones.

**Mechanic:** Weapon hits pull enemies toward the impact point.

| Property            | Value                                                 |
| ------------------- | ----------------------------------------------------- |
| Pull distance (Lv1) | 15px                                                  |
| Pull distance (Lv5) | 25px                                                  |
| Pull cap            | Enemies cannot be pulled into overlapping positions   |
| Applies to          | All weapon types (projectile, beam, AoE, mine, chain) |

**Why it works standalone:** Grouping enemies makes every weapon in your build more effective — splash weapons hit more targets, line weapons pierce more bodies, mines catch more in the blast. It improves the rest of the build even when Scatter Flask is absent.

**Evolution pairing:** Scatter Flask → **Implosion Flask**

**Build fantasy:** Control / Setup

**Design note:** This is one of the healthiest passives in the batch because it improves spatial outcomes rather than merely increasing output.

---

### 1.2 Volatile Kill

**Fantasy:** Corpse pops — enemies explode on death, creating chain reactions in hordes.

**Mechanic:** On kill, enemies deal AoE damage in a radius around their corpse. Small knockback on pop.

| Property         | Value                           |
| ---------------- | ------------------------------- |
| Pop damage (Lv1) | 15% of the killing hit's damage |
| Pop damage (Lv5) | 30% of the killing hit's damage |
| Pop radius (Lv1) | 40px                            |
| Pop radius (Lv5) | 65px                            |
| Knockback        | Small (15-20px push)            |
| Elite bonus      | 1.5x radius, 2x damage          |

**Anti-win-more:** Damage scales from the killing hit, not a flat value. Killing a tanky enemy with a big hit produces a big pop. Killing trash with chip damage produces a small pop. This keeps it relevant at all stages.

**Why it works standalone:** Instant crowd-thinning in dense hordes. The knockback adds defensive utility even when pops are not chaining. Visible, satisfying, understandable.

**Evolution pairing:** Powder Keg → **Chain-Detonation Keg**

**Build fantasy:** Volatile / Explosive

**Design note:** VFX density should be capped carefully in large hordes so corpse-pop builds stay readable.

---

### 1.3 Phantom Echo

**Fantasy:** Ghostly afterimages — your attacks fire delayed spectral repeats.

**Mechanic:** After a weapon fires, a translucent echo fires the same attack 0.3s later at reduced damage.

| Property          | Value                                              |
| ----------------- | -------------------------------------------------- |
| Echo delay        | 0.3s                                               |
| Echo damage       | 40% of original                                    |
| Applies to        | Projectile and burst attacks ONLY                  |
| Does NOT apply to | Beams, AoEs, mines, lingering zones, chain effects |
| Recursive echo    | No — echoes cannot trigger further echoes          |
| On-hit procs      | No — echoes do not trigger on-hit effects          |
| Scaling per level | Echo damage: 40% → 55% at Lv5                      |

**Restrictions are critical.** Without them, this passive becomes a universal god-pick that doubles every weapon's output. The projectile/burst restriction keeps it strong but scoped.

**Why it works standalone:** Doubles visual presence. Makes burst and projectile weapons feel dramatically more aggressive. The delayed timing creates a rhythmic combat feel.

**Evolution pairing:** Twin Barrels → **Ghost Barrage**

**Build fantasy:** Domination / Spectacle

**Tuning note:** This is likely the strongest passive in the roster. Level scaling should be moderate and it should compete with other high-value picks. The evo should add **crossfire geometry**, not just a second copy of the same attack.

---

### 1.4 Ricochet

**Fantasy:** Precision crowd conversion — single-target shots bounce to nearby enemies.

**Mechanic:** Projectile hits bounce to a nearby enemy within range.

| Property          | Value                                                                             |
| ----------------- | --------------------------------------------------------------------------------- |
| Bounces (Lv1)     | 1                                                                                 |
| Bounces (Lv5)     | 3                                                                                 |
| Bounce damage     | 60% of original per bounce (not compounding)                                      |
| Bounce range      | 80px from hit target                                                              |
| Applies to        | Projectile impacts                                                                |
| Does NOT apply to | Beams (but evo Refraction Beam adds a beam-specific branch behavior), AoEs, lingering zones |

**Why it works standalone:** Turns any single-target projectile weapon into a multi-target weapon. Your precision picks gain crowd-clearing capability. Very visible — you see shots ping-ponging between targets.

**Evolution pairing:** Bolt Rifle → **Refraction Beam**

**Build fantasy:** Precision / Network

**Design note:** The passive remains projectile-scoped, but its paired evolution preserves Bolt Rifle's **hitscan beam identity** instead of converting it into a projectile weapon.

---

### 1.5 Shrapnel

**Fantasy:** Messy fragmentation — projectiles burst into shards on impact.

**Mechanic:** Projectile hits split into fragments that fly outward in a cone.

| Property             | Value                                                  |
| -------------------- | ------------------------------------------------------ |
| Fragment count (Lv1) | 2                                                      |
| Fragment count (Lv5) | 4                                                      |
| Fragment damage      | 30% of original hit                                    |
| Fragment spread      | ~90 degree cone behind impact point                    |
| Fragment range       | 60-80px travel distance                                |
| Applies to           | Projectile impacts ONLY                                |
| Re-fragment          | No — fragments cannot split further                    |
| Fragment procs       | Reduced — fragments do not trigger full on-hit effects |
| Fragment homing      | None (straight-line scatter)                           |

**Why it works standalone:** One hit becomes several. Even without the evo pairing, Shrapnel turns every projectile weapon into a wider-coverage version of itself. Rewards hitting enemies that are near other enemies.

**"Clean rule, messy visual."** The rules are tight but the on-screen effect is gloriously unruly. Not every passive should be elegant.

**Evolution pairing:** Seeker Rounds → **Cluster Salvo**

**Build fantasy:** Volatile / Swarm

**Tuning note:** Fragment spread cone and travel distance need testing. Too narrow = fake spectacle that rarely hits secondary targets. Too wide = unreliable.

---

### 1.6 Overclock

**Fantasy:** Momentum engine — consecutive hits ramp your attack tempo, building toward overload.

**Mechanic:** Each consecutive hit builds a visible heat stack. Stacks increase fire rate and trigger bonus effects at max.

| Property                  | Value                                                                 |
| ------------------------- | --------------------------------------------------------------------- |
| Max stacks                | 5                                                                     |
| Stack gain                | +1 per hit                                                            |
| Stack decay               | Reset after 1.0s without hitting                                      |
| Fire rate bonus per stack | +6% (total +30% at max)                                               |
| Max stack bonus           | Periodic micro-burst (piercing spike or small AoE pulse)              |
| Visual: stacks            | Heat pips around player, muzzle glow intensifies                      |
| Visual: max stacks        | Sustained glow, particle aura, audio pitch ramp                       |
| Scaling per level         | Stack decay timer: 1.0s → 1.5s at Lv5. Max stack bonus damage scales. |

**Why it works standalone:** Rewards aggression and accuracy. The visible heat state makes it feel like a build identity — you are not just "dealing damage," you are "running hot." The tempo ramp is audible and visible.

**Evolution pairing:** Arc Discharge → **Storm Engine**

**Build fantasy:** Engine / Momentum

**Tuning note:** Uptime is the balance lever. Fast-hitting weapons (Twin Barrels, Arc Discharge) will maintain stacks more easily than slow weapons (Powder Keg). This is intentional — Overclock rewards sustained pressure — but Storm Engine should feel like a **maintained overload state**, not a permanent flat buff.

---

## 2. Evolution Pairing Chart

| Passive       | + Max Level Weapon            | = Evolution              |
| ------------- | ----------------------------- | ------------------------ |
| Magnetism     | Scatter Flask (BURST) Lv5     | **Implosion Flask**      |
| Volatile Kill | Powder Keg (MINE) Lv5         | **Chain-Detonation Keg** |
| Phantom Echo  | Twin Barrels (BURST_FIRE) Lv5 | **Ghost Barrage**        |
| Ricochet      | Bolt Rifle (BEAM) Lv5         | **Refraction Beam**      |
| Shrapnel      | Seeker Rounds (BARRAGE) Lv5   | **Cluster Salvo**        |
| Overclock     | Arc Discharge (CHAIN) Lv5     | **Storm Engine**         |

**Evolution trigger:** Next level-up after requirements are met (not instant, not boss-gated).

**If multiple passives qualify:** Player gets a choice pop-up (level-up style UI).

---

## 3. Evolution Specs

### 3.1 Implosion Flask

**Mechanical thesis:** Scatter Flask stops being a simple splash burst and becomes a two-stage crowd compressor.

**Base weapon:** Scatter Flask (BURST) — lobbed flask shatters into shrapnel cone.

**Evolution trigger:** Scatter Flask Lv5 + Magnetism

**Behavior:**
1. Flask lands at target position
2. Creates a visible vacuum field for 0.5-0.8s
3. Enemies in radius are pulled inward continuously during suction phase
4. After suction, detonates in a burst
5. Detonation damage scales with number of enemies caught in the vacuum

| Property          | Value                                                |
| ----------------- | ---------------------------------------------------- |
| Vacuum duration   | 0.5-0.8s                                             |
| Vacuum radius     | 80-100px                                             |
| Pull strength     | Strong — enemies visibly dragged inward              |
| Detonation damage | Base + bonus per enemy caught (e.g., +15% per enemy) |
| Bonus cap         | Cap bonus at a sane target count (e.g., 6-8 enemies) |
| Shrapnel          | Still produces fragments post-detonation             |

**Key rule:** The pull is NOT instant. A short visible suction phase is what sells the fantasy. The player sees enemies sliding inward, anticipates the boom, then gets payoff.

**Texture change from base:** Base Scatter Flask is a lobber that sprays on impact. Implosion Flask is a setup-and-payoff weapon — throw, vacuum, detonate.

---

### 3.2 Chain-Detonation Keg

**Mechanical thesis:** Powder Keg stops being a single planted explosion and becomes a propagating hazard field.

**Base weapon:** Powder Keg (MINE) — drops barrel at feet, fuse timer, AoE blast.

**Evolution trigger:** Powder Keg Lv5 + Volatile Kill

**Behavior:**
1. Kegs explode as normal
2. Enemies killed by keg blasts become **unstable corpses**
3. Unstable corpses detonate after a short delay (~0.3s)
4. Corpse detonations can ignite nearby kegs or prime additional corpse pops
5. Elites produce a larger delayed secondary blast

| Property                 | Value                                                 |
| ------------------------ | ----------------------------------------------------- |
| Corpse instability delay | ~0.3s after death                                     |
| Corpse detonation radius | 50px (regular), 80px (elite)                          |
| Corpse detonation damage | 40% of original keg damage                            |
| Chain depth              | Max 2 generations (keg → corpse → corpse, then stops) |
| Damage falloff           | Each generation deals 60% of previous                 |

**Key rule:** Cap chain depth and add damage falloff. Without this, dense hordes become unreadable chain-reaction soup. Two generations is enough to feel like "battlefield contamination" without becoming noise.

**Texture change from base:** Base Powder Keg is a planted explosive. Chain-Detonation Keg turns the battlefield into a cascading chain of secondary hazards.

---

### 3.3 Ghost Barrage

**Mechanical thesis:** Twin Barrels stops being pure forward burst and becomes layered spectral crossfire.

**Base weapon:** Twin Barrels (BURST_FIRE) — two rapid shots in quick succession.

**Evolution trigger:** Twin Barrels Lv5 + Phantom Echo

**Behavior:**
1. Twin Barrels fires its normal 2-shot burst
2. Ghost volleys fire 0.2-0.3s later from offset / mirrored phantom positions
3. Ghost shots prefer nearby enemies NOT hit by the original volley
4. Every Nth volley (e.g., every 3rd), a denser spectral burst fires
5. If no alternate targets are available, the ghost volley mirrors the original target line as fallback

| Property               | Value                              |
| ---------------------- | ---------------------------------- |
| Ghost volley delay     | 0.2-0.3s                           |
| Ghost shot count       | 2 (matching base burst)            |
| Ghost shot damage      | 50% of base shot                   |
| Ghost targeting        | Prefers un-hit nearby enemies      |
| Dense burst frequency  | Every 3rd volley                   |
| Dense burst shot count | 4-6 spectral shots                 |
| Ghost visual           | Translucent, offset, spectral tint |

**Key rule:** Ghost volleys come from offset phantom positions or mirrored firing angles, NOT from the player's exact position. This avoids "same attack twice" and creates a **layered crossfire** effect.

**Texture change from base:** Base Twin Barrels is focused forward aggression. Ghost Barrage is screen coverage through spectral overlap — phantom gunners flanking your shots from offset angles.

---

### 3.4 Refraction Beam

**Mechanical thesis:** Bolt Rifle keeps its instant line identity, but each hit turns precision into branching beam geometry.

**Base weapon:** Bolt Rifle (BEAM) — hitscan line through enemies.

**Evolution trigger:** Bolt Rifle Lv5 + Ricochet

**Behavior:**
1. Bolt Rifle fires as normal (hitscan line)
2. Beam continues THROUGH the target (enhanced pierce)
3. Each hit enemy emits 1-2 refracted side-beams toward nearby enemies
4. Side-beams are weaker and shorter than the main beam
5. Repeated hits create a visible beam web across the enemy cluster

| Property                | Value                                           |
| ----------------------- | ----------------------------------------------- |
| Main beam               | Unchanged (hitscan, full damage, full range)    |
| Side-beam count per hit | 1 at base, 2 at higher evo investment           |
| Side-beam damage        | 35% of main beam                                |
| Side-beam range         | 80-100px                                        |
| Side-beam targeting     | Nearest enemy not already hit by main beam      |
| Visual                  | Bright main beam with dimmer refracted branches |

**Key rule:** Keep it hitscan. Do NOT turn it into a bouncing projectile. The identity of Bolt Rifle is instant precision line fire. Refraction Beam adds geometric crowd-clear on top of that identity, not instead of it.

**Naming note:** If the final visual does not read as optical splitting or prism behavior, consider a rename later (e.g. **Prism Rail**, **Relay Beam**, **Lattice Beam**).

**Texture change from base:** Base Bolt Rifle hits in a line. Refraction Beam creates a web — one beam lights up an entire cluster through refracted branches.

---

### 3.5 Cluster Salvo

**Mechanical thesis:** Seeker Rounds stop being a few precise missiles and become a guided swarm.

**Base weapon:** Seeker Rounds (BARRAGE) — homing missiles track random enemies.

**Evolution trigger:** Seeker Rounds Lv5 + Shrapnel

**Behavior:**
1. Seeker Rounds fire and home toward targets as normal
2. On hit or expiry, each missile bursts into several mini-seekers
3. Mini-seekers aggressively reacquire nearby targets
4. Mini-seekers have short lifetime and low base damage
5. If no targets are available, mini-seekers spiral out and fizzle quickly

| Property                      | Value                                                   |
| ----------------------------- | ------------------------------------------------------- |
| Mini-seeker count per missile | 3-4                                                     |
| Mini-seeker damage            | 25% of parent missile                                   |
| Mini-seeker lifetime          | 1.0-1.5s                                                |
| Mini-seeker homing strength   | Aggressive but imperfect (slight wobble)                |
| Mini-seeker on no target      | Spiral outward, fizzle after lifetime                   |
| Visual                        | Smaller, dimmer versions of parent with trail particles |

**Key rule:** Mini-seekers must NOT live too long or home too perfectly. Short lifetime + imperfect tracking keeps it feeling like a swarm rather than autopilot soup.

**Texture change from base:** Base Seeker Rounds sends a few precise homing missiles. Cluster Salvo turns each hit into a seed for a short-lived missile bloom.

---

### 3.6 Storm Engine

**Mechanical thesis:** Arc Discharge stops being a fixed chain pattern and becomes a maintained overload state.

**Base weapon:** Arc Discharge (CHAIN) — lightning arcs between enemies.

**Evolution trigger:** Arc Discharge Lv5 + Overclock

**Behavior:**
1. Arc Discharge builds Overclock heat stacks through sustained hits
2. At max heat, arcs fork into secondary branches
3. Max heat also increases total arc count and chain range
4. Periodic overload pulses discharge around the player or the last struck target
5. Losing heat collapses the extra branches back to normal

| Property                      | Value                                                      |
| ----------------------------- | ---------------------------------------------------------- |
| Heat integration              | Shares Overclock's stack system                            |
| Forked arcs at max heat       | Each chain has 30-40% chance to fork                       |
| Arc count bonus at max heat   | +2 additional chain targets                                |
| Chain range bonus at max heat | +40% hop distance                                          |
| Overload pulse                | Every 2-3s at max heat, AoE discharge around player (60px) |
| Heat loss behavior            | Branches collapse, arc count returns to base, pulse stops  |

**Key rule:** The evo should NOT be "always twice as much lightning." It should feel like a machine entering and maintaining overload. Build heat → enter storm state → maintain storm state → lose it and rebuild.

**Texture change from base:** Base Arc Discharge chains between enemies in a fixed pattern. Storm Engine escalates into a branching electrical storm with a real tempo: ramp, peak, pulse, sustain or lose it.

---

## 4. Implementation Priorities

Per the Core System Design doc, Phase 1 (First Playable Target):

1. Implement 4-6 new passives with the specs above
2. Return passives to the level-up pool with mixed weapon/passive offer generation
3. Un-archive Arc Discharge and Seeker Rounds
4. Implement one-branch evolution eligibility check
5. Implement "next level-up" evolution trigger
6. Implement evolution choice UI (level-up style pop-up)
7. Implement 6 evolution weapons with the specs above
8. Validate: do players develop mid-run plans? Do evolutions feel earned?

**Validation focus additions:**
- Do players understand what changed besides damage after each evo?
- Are Ghost Barrage and Storm Engine readable enough in dense combat?
- Does Implosion Flask create satisfying setup windows without feeling sluggish?
- Does Refraction Beam still feel like Bolt Rifle, not a totally different weapon?

---

## 5. Future Passive Directions (Phase 3+)

The current roster is entirely offense/spectacle-forward. Future passives should cover:

- **Control:** Slow, freeze, root, displacement
- **Survivability:** Shields, regen triggers, damage reduction on conditions
- **Economy:** XP gain, dust gain, gem magnetism, lucky drops
- **Consistency:** Reduced variance, guaranteed procs, cooldown effects
- **Zone shaping:** Persistent ground effects, area denial, territorial control

These should follow the same design rules: verbs not numbers, visible effects, evo pairings, standalone value.

### Example future passive concepts

#### Anchor Field
Hits briefly slow enemies and reduce their movement inertia. Repeated hits deepen the drag effect.

**Role:** Control / Zone shaping  
**Potential pairings:** Gravity Lash, Magma Geyser, Phantom Sentry

#### Target Painter
Hits mark enemies. Marked enemies take priority from homing, chain, fragment, or echo behaviors.

**Role:** Consistency / Reliability  
**Potential pairings:** Phantom Sentry, Seeker Rounds, Arc Discharge, Bolt Rifle

These are not Phase 1 requirements, but they represent the kinds of quieter, smarter passives the system will need once the spectacle-first core is stable.
