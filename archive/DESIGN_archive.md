# Bullet Heaven — Design Reference

Quick-reference design doc. Use this for **implementation context**. The visual overview is `DESIGN_IDEAS.html`.

---

## V1 Scope: Game Loop Completion

**Win Condition**: Survive **15 minutes**. At 15:00, waves stop and a "Victory!" screen displays with final stats (time, enemies killed, XP collected, rerolls used). Player can see runs stats and return to main menu.

**Progression Difficulty Scaling** (applied per 5-min bracket):
- **0-5m**: Warm-up (1-2 enemies/spawn, low DPS requirement)
- **5-10m**: Ramp (3-4 enemies/spawn, moderate scaling)
- **10-15m**: Peak (4-6 enemies/spawn, high DPS check)

**First Impression & Boot**:
- Game boots to **Main Menu** (Start Game, Settings, Exit)
- Start Game → **New Run** immediately (no character select for v1)
- In-game HUD displays: Player HP, level, time, enemy count, XP bar, next level preview
- Paused state works (UI visible, gameplay frozen via PROCESS_MODE_ALWAYS)

**Game Over / Loss Condition**:
- Player HP ≤ 0 triggers **Game Over Panel** (not mid-gameplay; waits for cleanup)
- Shows: Time elapsed, Enemies killed, XP gained, Level reached, Rerolls used
- Buttons: Retry (new run), Main Menu
- No run stats persistence for v1 (runs don't save)

**Settings (v1 Minimum)**:
- Master Volume slider (0–100%, default 80%)
- SFX Volume slider
- Music Volume slider (music not yet in v1, reserved)
- Difficulty toggle: Normal / God Mode (god mode = infinite health, instant rerolls, stat multiplier display)
- Persist to `user://settings.cfg` (already implemented)

**Accessibility (v1)**:
- UI text minimum 16px
- Color palette verified readable at low contrast (dark+bright)
- No flashing/seizure risks (tweens max 0.3s, no screen shake in v1)
- Input labels shown in menus (WASD, Space for pause, ESC for menu)
- Colorblind support: Reserved for v2 (tracked but not implemented)

**Performance Targets (v1)**:
- Target 60 FPS on mid-range laptop (Intel i5, GTX 960 equivalent)
- Max 200 enemies on-screen (hard cap in spawner)
- Stable frames during 15m run (no GC pauses > 16ms)
- Memory footprint < 400MB at end of run

**Known Limitations (Acceptable for v1)**:
- No persistence between runs (stats don't save)
- No character select (single avatar)
- No boss encounters (simple wave scaling instead)
- Spectral Slash visual needs polish (marked in A3a-fix) — **RESOLVED** via A3b-VFX pixelated particle pass
- No music (SFX only)
- No destructible environment or map variety (1 arena only)

---

## DPS Balance & Metrics

**Philosophy**: Weapon archetypes should feel distinct and scale differently to allow playstyle variance. No single weapon should dominate all phases.

**DPS Targets (L5, Solo, no passives)**:
- **Spectral Slash (MELEE)**: ~35 DPS at 0m (baseline)
- **Holy Aura (AOE)**: ~12 DPS at 0m (scales with enemy count)
- **Chain Lightning (CHAIN)**: ~20 DPS at 0m (scales with chains/pierce)
- **Flame Guard (ORBIT)**: ~15 DPS at 0m (consistent field, scales with area)
- **Toxic Nova (DOT)**: ~18 DPS at 0m (zone-based, delayed)
- **Arcane Missiles (BARRAGE)**: ~28 DPS at 0m (homing, scales with enemies)

**Passive Scaling Impact**:
- Spinach (damage): ~+10% per level = 50% at L5 (multiplicative with all weapons)
- Empty Tome (fire_rate): ~+8% per level = 40% at L5 (affects Spectral Slash, Aura, Nova, Missiles)
- Bracer (speed): ~+10% per level = 50% at L5 (affects Chain, Missiles)
- Duplicator (pierce): Linear +1 per level = +5 total (multiplicative effect on Chain)
- Attractorb (pickup): +15% per level = +75% = faster XP → faster levels (indirect DPS)
- Candelabra (area): +8% per level = 40% at L5 (affects Aura, Nova, Flame Guard radius)
- Clover (proj_count): +1 per level = +5 total (multiplicative on Missiles, Orbiters)

**Expected Endgame Combo** (15min, optimized):
- E.g., Phantom Reaper (Spectral Slash + Spinach L5) + Storm Caller (Chain + Duplicator L5) = estimated ~150 combined DPS with synergy
- At 15m, enemy contact damage is 40/hit; player should have 150+ HP to tank 3-4 hits safely

**Testing Checklist**:
- Solo any weapon should NOT trivialize first 5m (too early to win)
- Solo any weapon SHOULD require synergy by 10m (2-3 passives to stay alive)
- Evolutions should feel like power spikes (2-3x DPS bump from base)
- 2-weapon combos + 3+ passives should be winnable but challenging (not guaranteed win)

---

## Weapons (6 Archetypes)

| Weapon | Type | Color | Damage | Rate | Special Stat | Special Value | Mechanic |
|---|---|---|---|---|---|---|---|
| Spectral Slash | MELEE | #c0c0c0 | 14-30 | 1.2-2.0/s | Arc / Reach | 120° / 90px | Cone sweep, instant, hits all in arc |
| Holy Aura | AOE | #ffd94d | 8-20 | 0.5-0.7/s | Radius | 80px | Pulse around player, bypasses physics |
| Chain Lightning | CHAIN | #6699ff | 12-28 | 0.8-1.2/s | Chains / Hop | 2-6 / 120px | Arcs enemy-to-enemy, pierce = chains |
| Flame Guard | ORBIT | #ff6619 | 7-15 | — | Orbiters / Radius | 2-6 / 60px | Physics-based orbiting Area2Ds, 180°/s |
| Toxic Nova | DOT | #66ff66 | 5-13/tick | 0.4-0.6/s | Radius / Duration | 70px / 3-5s | Thrown zone, ticks every 0.5s |
| Arcane Missiles | BARRAGE | #cc66ff | 15-27 | 0.4-0.6/s | Missiles / Splash | 2-4 / 30px | Homing missiles, random target each |

All stats are L1→L5 ranges.

---

## Evolutions (6 Rules)

| Base Weapon (Lv5) | + Passive | = Evolution | Key Stats |
|---|---|---|---|
| Spectral Slash | Spinach | **Phantom Reaper** #e64dff | 360° scythe, 120px reach, 40 dmg, 2.5/s, afterimage |
| Holy Aura | Empty Tome | **Divine Nova** #ffff99 | 150px radius, 30 dmg, 1.5/s |
| Chain Lightning | Duplicator | **Storm Caller** #cce6ff | 8 chains, 180px hop, 25 dmg, 1.2/s |
| Flame Guard | Bracer | **Inferno Ring** #ff3300 | 6 orbiters, 90px radius, 18 dmg, 270°/s |
| Toxic Nova | Candelabra | **Plague Storm** #00e676 | 120px zone, 12/tick, 6s, ticks/0.3s, toxic trail |
| Arcane Missiles | Clover | **Meteor Shower** #ff4081 | 6 meteors, 60px splash, 35 dmg, screen-wide |

Auto-evolves when base weapon reaches Lv5 and paired passive is owned (any level).

---

## Passives (8 Items, 6 Slots)

| Passive | Color | Stat Key | Effect/Level | Max (Lv5) |
|---|---|---|---|---|
| Spinach | #33cc33 | damage_mult | +10% damage | +50% |
| Empty Tome | #996633 | fire_rate_mult | +8% attack speed | +40% |
| Bracer | #cc9933 | proj_speed_mult | +10% weapon speed | +50% |
| Duplicator | #66ccff | pierce_bonus (flat) | +1 pierce/chain | +5 |
| Wings | #b3e6ff | move_speed_mult | +8% move speed | +40% |
| Attractorb | #8033cc | pickup_range_mult | +15% pickup range | +75% |
| Candelabra | #ffab40 | area_mult | +8% AOE/orbit radius | +40% |
| Clover | #7cb342 | proj_count_bonus (flat) | +1 proj/orbiter/missile | +5 |

---

## Stat Resolution

All in `GameManager._recalculate_stats()`. Percentage passives: `1.0 + level * per_level`. Flat passives: `0 + level * per_level`. Applied at fire time.

| Multiplier | Default | Passive | Affects |
|---|---|---|---|
| damage_mult | 1.0 | Spinach | All weapon damage |
| fire_rate_mult | 1.0 | Empty Tome | All fire/pulse rates |
| proj_speed_mult | 1.0 | Bracer | Projectile speed, orbit spin |
| pierce_bonus | 0 | Duplicator | Pierce count, chain hops |
| move_speed_mult | 1.0 | Wings | Player movement |
| pickup_range_mult | 1.0 | Attractorb | XP gem attraction radius |
| area_mult | 1.0 | Candelabra | AOE radius, orbit radius |
| xp_mult | 1.0 | (unused) | XP gain |
| proj_count_bonus | 0 | Clover | Extra projectiles/orbiters |
| max_hp_bonus | 0 | (unused) | Player max HP |

---

## Enemy Scaling (Linear with Minutes)

| Stat | Base (0m) | 5m | 10m | Formula |
|---|---|---|---|---|
| Per spawn | 1 | 3-4 | 6 | `1 + min * 0.5` |
| HP | 30 | 80 | 130 | `30 + min * 10` |
| Speed | 60 | 85 | 110 | `60 + min * 5` |
| Contact Dmg | 10 | 25 | 40 | `10 + min * 3` |
| XP Value | 5 | 15 | 25 | `5 + min * 2` |

- Max enemies: 200, Spawn distance: 600px, Spawn interval: 1.0s

---

## XP & Leveling

- **Curve**: `10 * level^1.3`
- **Level-up choices**: 3 random from: new weapon, weapon upgrade, new passive, passive upgrade
- **Rerolls**: 3/run (infinite in god mode)
- **Inventory**: 6 weapon slots, 6 passive slots

### Upgrade Logic in Detail

**When player levels up:**
1. Pause gameplay (via `get_tree().paused = true`, UI stays visible with PROCESS_MODE_ALWAYS)
2. Pool 3 random from available options:
   - All unowned weapons (random without repeats)
   - All owned weapons at < L5 (random)
   - All unowned passives (random)
   - All owned passives at < L5 (random)
3. Show Level-Up Panel with 3 buttons, each showing icon/name/effect
4. Player picks 1; apply upgrade immediately
5. If `pending_levels > 0`, panel re-shows with fresh pool. Otherwise, resume gameplay.

**Edge Cases Handled**:
- **Inventory full (6 weapons)**: Only show weapon upgrades if no slots. Skip new weapon options.
- **All weapons owned at L5**: Only show passive options (prevents dead picks)
- **All passives owned at L5**: Only show weapon options
- **Both full at L5**: Deadlock protection — show cheapest reroll (should never occur in normal play)

### Evolution Auto-Trigger

- **Condition**: Weapon reaches L5 AND passive is owned (any level)
- **Effect**: Weapon replaces itself in inventory with evolved version (same slot)
- **Name**: Base weapon name changes to evolution name (e.g., "Spectral Slash" → "Phantom Reaper")
- **Signal**: Emit `weapon_evolved(weapon_id)` for feedback/sound

---

## Game State Transitions

**Game States (enum in GameManager)**:
1. **MENU** — Main Menu active, no game running
2. **RUNNING** — Gameplay active, time advancing, enemies spawning
3. **PAUSED** — Gameplay paused via Space, Panel visible
4. **LEVEL_UP** — Level-up panel showing, awaiting player choice
5. **GAME_OVER** — Player HP = 0, Game Over panel showing
6. **VICTORY** — Timer reached 15:00, Victory panel showing

**State Flow**:
```
MENU → (Start Game) → RUNNING
  ↓ (Pause)
PAUSED ↔ RUNNING
  ↓ (Level up)
LEVEL_UP → (Pick upgrade) → RUNNING
  ↓ (Multiple levels)
LEVEL_UP → (Pick upgrade) → LEVEL_UP (if pending > 0) → RUNNING
  ↓ (HP ≤ 0)
GAME_OVER → (Retry/Menu)
  ↓ (Timer ≥ 15:00)
VICTORY → (Retry/Menu)
```

**Paused Behavior**:
- All gameplay `_process()` paused via `get_tree().paused = true`
- UI uses `PROCESS_MODE_ALWAYS` to stay interactive
- Player can see inventory, re-read level-up choices
- Pressing Space or ESC resumes or opens menu

---

## UI/UX Flows

### Main Menu
- Title: "Bullet Heaven"
- Buttons: `Start Game`, `Settings`, `Exit`
- Keyboard shortcuts: Enter = Start, S = Settings, ESC = Exit (optional)

### HUD (In-Game, Always Visible)
- **Top-left**: Player HP bar (red) with current/max
- **Top-center**: Timer (MM:SS format, yellow)
- **Top-right**: Level + XP bar (purple progress with next level hint)
- **Bottom-left**: Enemy count (text)
- **Bottom-center**: Inventory preview (icon grid: 6 weapons, 6 passives, upgrade highlights)
- **Bottom-right**: Rerolls remaining (text + button if > 0)

### Pause Menu (Over HUD)
- Panel with translucent dark overlay
- Centered buttons: `Resume`, `Settings`, `Main Menu`
- Shows current run stats: Time, Level, Enemies Killed (read-only)

### Level-Up Panel
- Modal overlay, centered
- **Header**: "Level Up!" with sound effect (sfx_ui_open)
- **3 Cards** (horizontal layout):
  - Card 1: Icon + Name + Effect text
  - Card 2: Icon + Name + Effect text
  - Card 3: Icon + Name + Effect text
- **Hover**: Card scales +5%, sound (sfx_ui_hover)
- **Click**: Sound (sfx_ui_click), apply upgrade, panel closes
- If `pending_levels > 0`, re-show with fresh pool (same header)

### Game Over Panel
- Modal overlay, centered (red tint)
- **Header**: "Game Over" (sfx_ui_open)
- **Stats** (readout):
  - Time: MM:SS
  - Level: N
  - Enemies Killed: N
  - Total XP: N
  - Rerolls Used: N
- **Buttons**: `Retry` (starts new run), `Main Menu`

### Victory Panel
- Modal overlay, centered (gold tint, celebratory tone)
- **Header**: "Victory!" (sfx_level_up)
- **Stats** (readout):
  - Time: 15:00 ✓
  - Level: N
  - Enemies Killed: N
  - Total XP: N
  - Rerolls Used: N
- **Buttons**: `Retry` (starts new run), `Main Menu`

### Settings Menu
- **Master Volume** slider (0–100, default 80%)
- **SFX Volume** slider (0–100, default 100%)
- **Music Volume** slider (0–100, default 80%) — label "[Reserved for v2]"
- **Difficulty** toggle: Normal ⟷ God Mode
  - When God Mode: Show label "*God Mode Active*" in menu and in-game HUD
  - Effect: `player.hp = ∞`, `rerolls = ∞`, show damage multipliers in HUD
- **Back** button to return (saves settings to disk)

---

## UI Accessibility (v1)

**Text Requirements**:
- All UI text: minimum 16px font size
- HUD elements: 18–24px (larger for visibility during gameplay)
- Menu text: 20–28px
- Font: Aldo the Apache (clean, high contrast, already integrated)

**Color Contrast**:
- Background (#0f0f13, dark) + Text (#e0e0e8, bright) = WCAG AAA compliant
- UI elements verified with color contrast checkers
- Accent color (#7c6ff7) readable on both dark and light overlays

**Input Clarity**:
- Main Menu shows input hints: "Press ENTER", "Press ESC"
- Pause screen shows: "SPACE = Resume", "ESC = Menu"
- Level-up cards: Show click prompt or highlight active card

**No Seizure Risk**:
- Tweens: Max 0.3s duration (slow, readable)
- No flashing (screen flash reserved for v2)
- No rapid color changes
- Damage numbers: Fade duration 1.0s (readable)

**Reserved for v2**:
- Colorblind mode (tracked, not implemented)
- Keybind remapping (hardcoded for v1)
- Text-to-speech for UI labels
- Screen reader compatibility (complex, post-v1)

---

## Edge Cases & Safety

### Enemy Death & Double-Damage Prevention
- **Issue**: Concurrent projectiles hitting same enemy could trigger `take_damage()` multiple times
- **Fix**: `_is_dead` flag in base_enemy.gd guards all damage infliction
  ```gdscript
  func take_damage(dmg, hit_enemy):
    if _is_dead or not is_alive:
      return
    _is_dead = true
    # ... apply damage, die animation, emit signals
  ```

### Pool Double-Release
- **Issue**: Enemy release() called twice (e.g., despawn + death) corrupts pool state
- **Fix**: release() checks if already in pool array before re-adding
  ```gdscript
  func release():
    if self in PoolManager._all_instances[pool_name]["idle"]:
      return  # Already released, skip
    # ... standard release logic
  ```

### Multi-Level-Up Panel Overwrite
- **Issue**: 2+ levels gained before player picks upgrade loses choices
- **Fix**: `GameManager.pending_levels` counter; panel re-shows fresh after each pick
  ```gdscript
  func _on_upgrade_picked():
    pending_levels -= 1
    if pending_levels > 0:
      level_up_panel.show()  # Re-open with new pool
  ```

### Level-Up During Game Over
- **Issue**: Projectile kills last enemy, XP triggers level-up mid-death animation
- **Fix**: Guard level-up in GameManager: if `not is_game_active`, skip emit
  ```gdscript
  if is_game_active and xp_gained >= next_level_xp:
    level_up()
  ```

### Player HP Overflow
- **Issue**: Heal passive applied multiple times per level
- **Fix**: `GameManager.add_passive()` applies flat HP bonuses only once on add
  - Passive upgrades apply incremental bonus, not full bonus again

### Homing Missile Splash Double-Damage
- **Issue**: Homing missile hits primary target + included in splash radius (2x damage on primary)
- **Fix**: `on_hit(hit_enemy)` receives primary target, splash loop excludes it
  ```gdscript
  func on_hit(hit_enemy):
    hit_enemy.take_damage(damage, self)
    for nearby in area.get_overlapping_bodies():
      if nearby != hit_enemy:
        nearby.take_damage(splash_dmg, self)
  ```

### Settings Not Persisting
- **Issue**: Volume/god mode settings lost on restart
- **Fix**: Load/save via ConfigFile to `user://settings.cfg` in `_ready()` / `_exit_tree()`
  ```gdscript
  var cfg = ConfigFile.new()
  cfg.load("user://settings.cfg")
  master_vol = cfg.get_value("audio", "master_vol", 0.8)
  ```

### Damage Numbers on Heal Triggered Hurt Sound
- **Issue**: Passive HP boost plays hurt SFX even though player isn't damaged
- **Fix**: Track `_prev_player_hp` in GameManager; only play sfx_player_hurt on decrease
  ```gdscript
  func _on_hp_changed(new_hp):
    if new_hp < _prev_player_hp:
      AudioManager.play_sfx("sfx_player_hurt")
    _prev_player_hp = new_hp
  ```

### Xp Gems Not Magnetizing Properly
- **Issue**: XP gem pickup_range scales with Attractorb but gems released at center, too far to attract
- **Fix**: Attractorb scales range in xp_gem's `_process()` using GameManager.pickup_range_mult
  ```gdscript
  var mag_range = 120 * GameManager.pickup_range_mult
  if player.global_position.distance_to(global_position) < mag_range:
    # Magnetize
  ```

---

## Architecture
| Name | Purpose |
|---|---|
| SignalBus | Global event bus |
| GameManager | State, HP, XP, leveling, inventories, stat mults, god mode |
| PoolManager | Generic object pooling |
| AudioManager | SFX playback, UI button sound wiring |
| UiTheme | Code-built game-wide Theme (Aldo the Apache font, Kenney fantasy-ui-borders textures, ornate panels/buttons/slot frames/dividers) |

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

## Roadmap

| Phase | Status | Summary |
|---|---|---|
| A1: Core Loop | DONE | Movement, auto-weapons, spawning, XP/leveling, game over |
| A2: Weapon Archetypes | DONE | 4 types, 6 passives, 4 evolutions, HUD, rerolls |
| A3a: New Weapons | DONE | 6 base weapons (MELEE/DOT/BARRAGE added), 8 passives, 6 evolutions. |
| A3a-fix: Core Audit | DONE | 17-bug audit and fix pass (pool, enemy death, level-up, UI, settings) |
| A3b-UI: UI Polish | PARTIAL | Ornate Kenney fantasy-ui-borders on panels/buttons/slot frames, particle-pack + scribble-platformer icons for weapons/passives, color-coded level-up cards, dividers. See below for remaining work. |
| A3b-VFX: Gameplay Visuals | PARTIAL | Base weapon VFX done (6/6 GPUParticles2D + draw_rect upgrades). Entity sprites + floor tilemap still planned. |
| A3c: Content Expansion | PLANNED | Enemy variants, first boss, Crown + Armor passives |
| A4: Balance & Polish | PLANNED | DPS balance, win condition, sound/music |
| B1: Art & Effects | FUTURE | Pixel art, particles, screen shake, juice effects |
| B2: Meta Progression | FUTURE | Permanent upgrades, characters, achievements, maps |

### A3b-UI Details (Partial — ~40% done)

**Done:**
- Ornate NinePatchRect borders on all major panels (main menu, pause, level-up, game over) via `UiTheme.add_ornate_panel()`
- Textured buttons using Kenney `panel-004.png` with tinted StyleBoxTexture
- Slot frames on HUD weapon/passive grids via `UiTheme.add_slot_frame()`
- Decorative gold dividers in level-up cards via `UiTheme.create_divider()`
- Weapon/passive icons from kenney_particle-pack and kenney_scribble-platformer textures (70×70 in cards, 28×28 in HUD slots)
- Color-coded level-up cards (silver=new weapon, gold=upgrade weapon, green=new passive, magenta=upgrade passive)
- Level badges ("M" for max) on HUD inventory slots
- Evolution hint labels in HUD

**Remaining:**
- Player visual: still a blue ColorRect (no sprite)
- Enemy visual: still a red ColorRect (no sprite)
- Projectile visuals: still colored ColorRects
- XP gem and heal pickup: still colored ColorRects
- Checkered floor: `_draw()` procedural pattern (no tilemap)

### A3b-VFX Details (Partial — Base Weapon VFX Done)

**Design Theory:** Pixelated blocky aesthetic using GPUParticles2D (texture=null, 1x1 white pixel scaled up) + enhanced `_draw()` with draw_rect layers. No smooth textures — crisp pixel blocks only. Mixed particle sizes: chunky blocks (6-12px) for core shapes, small pixels (2-4px) for trails/sparkles.

**Done — Base Weapon VFX (6/6):**
- **Spectral Slash** (melee_effect.gd): GPUParticles2D slash sparks + dust, pixelated crescent fill (8 draw_rects), blocky tip cluster, trailing pixel wake
- **Holy Aura** (aoe_effect.gd): GPUParticles2D aura burst (12 particles, one_shot), filled pulse flash, 12 blocky ring segments, cardinal cross lines
- **Chain Lightning** (chain_effect.gd): GPUParticles2D chain impact (6 particles, burst), glow backing lines, node impact blocks (6x6 + 3x3), branch forks
- **Toxic Nova** (toxic_zone.gd): GPUParticles2D toxic bubbles (10 particles, continuous, sphere emission), inner concentric pulse, toxic bubble rects, inner ring
- **Arcane Missiles** (homing_missile.gd): GPUParticles2D missile trail (6 particles, continuous, local_coords=false), glow rect + nose block draw
- **Flame Guard** (orbit_weapon.gd + orbiter.gd): GPUParticles2D orbiter trail (4 particles, continuous), glow rect + hot center draw on each orbiter

**Remaining:**
- Evolution weapon visual overhaul (6 evolutions — separate pass planned)
- Entity sprite replacements (player, enemies, projectiles, pickups — still ColorRects)
- Hit burst effects on enemy damage
- Death effects on enemy kill
- Floor tilemap or background texture

---

## Characters (Future)

| Character | Starting Weapon | Bonus |
|---|---|---|
| Reaper | Spectral Slash | +15% damage |
| Paladin | Holy Aura | +20% max HP |
| Stormcaller | Chain Lightning | +10% attack speed |
| Pyromancer | Flame Guard | +15% area |
| Druid | Toxic Nova | +12% AOE radius |
| Warlock | Arcane Missiles | +10% projectile count |

---

## Future Content Ideas

### Weapons
- **Beam** (BEAM) — sustained laser on nearest enemy, evo: Prismatic Beam (multi-target)
- **Landmine** (TRAP) — drops mines at player pos, evo: Cluster Bomb
- **Boomerang** (PROJECTILE) — out-and-back, evo: Glaive Storm
- **Summon** (SUMMON) — AI familiars, evo: Legion
- **Shockwave** (AOE variant) — expanding ring outward, evo: Earthquake

### Passives
- **Crown** (xp_mult) +10%/level, max +50%
- **Armor** (max_hp_bonus) +20/level, max +100

### Enemies
- Swarmers (fast, low HP, packs of 8-10), Tanks (slow, high HP), Ranged (projectiles), Phasing (blink), Splitting (spawn children)
- Bosses every 5min: The Warden (summons), The Storm (dash+trail), The Hive (spawns swarmers)
- Elite system: random mods (Fast, Armored, Regen, Explosive), tinted, more XP

---

## Asset Inventory

### Audio — Currently In Use (`assets/sfx/`)

**Primary SFX source: custom jsfxr .wav files** (not Kenney).

| SFX Key | File | Use |
|---|---|---|
| sfx_shoot | jsfxr/laserShoot_short.wav | Weapon fire |
| sfx_hit | jsfxr/hitHurt.wav | Enemy hit |
| sfx_kill | jsfxr/explosion.wav | Enemy death |
| sfx_pickup | jsfxr/pickupCoin.wav | XP gem collect |
| sfx_level_up | jsfxr/powerUp.wav | Level up fanfare |
| sfx_player_hurt | jsfxr/deathSound.wav | Player takes damage |
| sfx_ui_hover | jsfxr/menuHover.wav | Button hover |
| sfx_ui_click | jsfxr/menuConfirm.wav | Button press |
| sfx_ui_open | jsfxr/uiOpen.wav | Panel open (level-up, game-over) |
| sfx_ui_close | kenney_digital-audio/Audio/lowDown.ogg | Panel close (only Kenney audio file in use) |

### Audio — Available But Unused

| Pack | Files | Description |
|---|---|---|
| kenney_digital-audio | 62 .ogg (of 63) | Lasers, peps, phasers, powerups, tones — only lowDown.ogg is used |
| kenney_impact-sounds | ~130 .ogg | Footsteps (carpet/concrete/grass/snow/wood), impacts (bell/glass/metal/plate/punch/wood) |
| kenney_interface-sounds | ~100 .ogg | UI clicks, bongs, confirms, errors, glitches, scrolls, switches, ticks |
| kenney_rpg-audio | ~51 .ogg | Book sounds, belt handles, door open/close, knife slice, metal clicks, footsteps |
| kenney_sci-fi-sounds | ~73 .ogg | Explosions, force fields, lasers, space engines, zapElectric |

### Fonts (`assets/fonts/`)

**In use:** `Aldo the Apache` (`aldo_the_apache/AldotheApache.ttf`) — applied via UiTheme autoload.

**Available but unused:** `kenney_kenney-fonts/` — 12 .ttf fonts (Kenney Pixel, Mini, Blocks, High, Rocket, and their Square variants).

### Textures — Currently In Use (`assets/textures/`)

| Pack | Files Used | What They Do |
|---|---|---|
| **kenney_fantasy-ui-borders** | 5 of 282 PNGs | `panel-border-010` (panel border), `panel-border-015` (card border), `panel-004` (button texture), `panel-transparent-center-000` (slot frame), `divider-fade-002` (decorative divider). All loaded by UiTheme autoload. |
| **kenney_particle-pack** | ~10 of 193 PNGs | `circle_05`, `spark_05`, `flame_02`, `scorch_02`, `magic_04`, `spark_07`, `fire_01`, `smoke_07`, `flare_01`, `twirl_02`, `light_01` — used as weapon/passive icons in HUD and level-up cards |
| **kenney_scribble-platformer** | ~7 of 212 PNGs | `item_sword`, `item_bow`, `item_shieldRound`, `tile_heart`, `tile_coin`, `tile_flag`, `tile_gem`, `tile_cog` — used as weapon/passive icons |
| **superpowers/ninja-adventure** | 2 of 253 files | `weapons/katana.png`, `items/scroll-empty.png` — weapon/passive icons |

### Textures — Available But Unused

| Pack | Files | Useful For |
|---|---|---|
| **kenney_fantasy-ui-borders** | 277 unused PNGs | 30+ panel borders, 60+ panels, 60+ transparent-center panels, 20+ dividers — all in Default + Double sizes. White on transparent (tintable). |
| **kenney_particle-pack** | ~183 unused PNGs | `slash_01-04` (melee trails!), `fire_01-02`, `flame_01-06`, `spark_01-07`, `magic_01-05`, `circle_01-05`, `smoke_01-10`, `muzzle_01-05`, `star_01-09`, `trace_01-07`, `twirl_01-03`, `scorch_01-03`, `light_01-03`. Black + Transparent variants. |
| **kenney_scribble-platformer** | ~205 unused PNGs | Characters, effects (blast/shot/trail), items (arrow, blaster, bow, helmet, spear, etc.), tiles (block, castle, chest, cog, coin, gem, heart, key, ladder), UI elements. |
| **kenney_tiny-dungeon** | ~136 PNGs | 16×16 pixel dungeon tiles — characters, monsters, weapons, potions, walls, floors. Retro style. Potential player/enemy sprites. |
| **kenney_splat-pack** | ~73 PNGs | Splat shapes at 256px + 512px, white on transparent (tintable). Ideal for AOE zone visuals, death effects, impact marks. |
| **kenney_rune-pack** | ~667 PNGs | Rune/glyph symbols in circle/rectangle/square shapes, black + white variants. Potential passive/evolution icons. |
| **kenney_board-game-icons** | ~513 PNGs + SVGs | 200+ icons at 64px + 128px: swords, shields, skulls, potions, hearts, arrows, dice, crowns, gems, lightning, scrolls, wands. Potential HUD/inventory icons. |
| **kenney_ui-pack-space-expansion** | ~742 PNGs | Complete sci-fi UI widget set (bars, buttons, checkboxes, dropdowns, panels, sliders, windows) in Blue/Green/Grey/Red themes. Default + Double sizes. |
| **kenney_1-bit-input-prompts-pixel-16** | ~1,637 PNGs | 16×16 pixel 1-bit input prompt icons for keyboard/mouse/gamepad. Useful for control hints. |
| **kenney_abstract-platformer** | ~382 PNGs | Backgrounds, enemies, items, tiles. Abstract art style. |
| **kenney_space-shooter-extension** | ~561 PNGs | Space-themed sprites, ships, effects. Not relevant to fantasy theme. |
| **kenney_pattern-pack** | ~171 PNGs | Tileable pattern textures. Potential backgrounds/floor tiles. |
| **kenney_cursor-pixel-pack** | ~223 PNGs | Pixel-art mouse cursors. |
| **kenney_development-essentials** | ~19 PNGs | Basic dev placeholders (UV grids, test textures). |
| **flare_items-mumu** | 2 PNGs | RPG item icon spritesheets (potions, weapons, armor, scrolls). |
| **superpowers/ninja-adventure** | 251 unused files | Characters, FX, HUD, items, monsters, music, sounds. Only 2/253 files used. |
| **superpowers (6 other packs)** | ~1,477 files | medieval-fantasy, prehistoric-platformer, rpg-battle-system, space-shooter, top-down-shooter, western-fps-2d, backgrounds. Mostly not relevant to bullet heaven theme. |

**Asset disk usage:** ~179 MB total, ~142 MB (79%) unused.

---

## Known Issues (Resolved — A3a-fix)

| # | Severity | Issue | Fix |
|---|----------|-------|-----|
| 1 | HIGH | Double-death: concurrent projectile hits corrupted pool state | `_is_dead` flag in base_enemy.gd guards take_damage/die |
| 2 | HIGH | Pool double-release had no guard | release() checks if instance already in pool array |
| 3 | HIGH | clear_all_pools() leaked active instances on retry/menu | Track all instances in `_all_instances` dict, free everything on clear |
| 4 | HIGH | Homing missile splash double-damaged primary target (2x damage) | Pass hit_enemy to on_hit(), exclude from splash loop |
| 5 | HIGH | Multi-level-up overwrote upgrade panel, losing choices | `pending_levels` counter; panel re-shows after each pick |
| 6 | MED | xp_gained signal emitted raw amount, not boosted | Emit `xp` (multiplied) instead of `amount` |
| 7 | MED | take_damage() could emit player_died multiple times | Guard with `not is_game_active` |
| 8 | MED | Hurt sound played on heal and passive HP changes | Track _prev_player_hp, only play on decrease |
| 9 | MED | add_passive() had no duplicate check | Added has_passive() guard (mirrors add_weapon) |
| 10 | MED | register_pool() overwrote without freeing old instances | Return early if pool already registered |
| 11 | LOW | HSlider/OptionButton missing theme styles | Added HSlider, OptionButton, PopupMenu styles to ui_theme.gd |
| 12 | LOW | Damage numbers used default font | Apply UiTheme font in damage_number.gd reset() |
| 13 | LOW | queue_free + add_child same frame caused layout flicker | remove_child() before queue_free() in hud.gd and level_up_panel.gd |
| 14 | LOW | Dead code: unreachable spread_angle >= 360 branch | Removed from weapon_manager.gd |
| 15 | LOW | Dead code: unused PANEL_PATH/BORDER_PATH constants | Removed from ui_theme.gd |
| 16 | LOW | Settings not persisted to disk | Save/load via ConfigFile to user://settings.cfg |
| 17 | LOW | DESIGN.md said "Kenney Future" but code uses "Aldo the Apache" | Updated docs to match |
