extends Node

# ── Overclock state ──
var overclock_stacks: int = 0
var overclock_max_stacks: int = 5
var overclock_decay_timer: float = 0.0
const OVERCLOCK_DECAY_TIME: float = 1.0
const OVERCLOCK_RATE_PER_STACK: float = 0.06

# ── Volatile Kill constants ──
const VK_BASE_RADIUS: float = 50.0
const VK_RADIUS_PER_LEVEL: float = 5.0
const VK_DAMAGE_RATIO_BASE: float = 0.15
const VK_DAMAGE_RATIO_PER_LEVEL: float = 0.03
const VK_KNOCKBACK_FORCE: float = 80.0

# ── Magnetism constants ──
const MAG_PULL_BASE: float = 15.0
const MAG_PULL_PER_LEVEL: float = 2.5
const MAG_PULL_RADIUS: float = 80.0
const MAG_MIN_DISTANCE: float = 12.0

# ── Ricochet constants ──
const RICO_BASE_BOUNCES: int = 1
const RICO_BOUNCES_PER_LEVEL: int = 1
const RICO_MAX_BOUNCES: int = 3
const RICO_DAMAGE_MULT: float = 0.60
const RICO_SEARCH_RADIUS: float = 120.0

# ── Shrapnel constants ──
const SHRAP_BASE_COUNT: int = 2
const SHRAP_COUNT_PER_LEVEL: int = 1
const SHRAP_MAX_COUNT: int = 4
const SHRAP_DAMAGE_MULT: float = 0.30
const SHRAP_SPEED: float = 200.0
const SHRAP_CONE_ANGLE: float = 60.0

# ── Phantom Echo constants ──
const ECHO_DELAY: float = 0.3
const ECHO_DAMAGE_BASE: float = 0.40
const ECHO_DAMAGE_PER_LEVEL: float = 0.03

func _ready() -> void:
	SignalBus.enemy_killed.connect(_on_enemy_killed)
	SignalBus.damage_dealt.connect(_on_damage_dealt)

func _process(delta: float) -> void:
	if not GameManager.is_game_active:
		return
	# Overclock decay
	if overclock_stacks > 0:
		overclock_decay_timer += delta
		if overclock_decay_timer >= OVERCLOCK_DECAY_TIME:
			overclock_stacks = 0
			overclock_decay_timer = 0.0

func reset() -> void:
	overclock_stacks = 0
	overclock_decay_timer = 0.0

# ── Public API for combat systems ──

func get_overclock_fire_rate_bonus() -> float:
	if not GameManager.has_passive("overclock"):
		return 0.0
	return overclock_stacks * OVERCLOCK_RATE_PER_STACK

func get_ricochet_bounces() -> int:
	var level = GameManager.get_passive_level("ricochet")
	if level <= 0:
		return 0
	return mini(RICO_BASE_BOUNCES + RICO_BOUNCES_PER_LEVEL * (level - 1), RICO_MAX_BOUNCES)

func get_shrapnel_count() -> int:
	var level = GameManager.get_passive_level("shrapnel")
	if level <= 0:
		return 0
	return mini(SHRAP_BASE_COUNT + SHRAP_COUNT_PER_LEVEL * (level - 1), SHRAP_MAX_COUNT)

func get_echo_damage_mult() -> float:
	var level = GameManager.get_passive_level("phantom_echo")
	if level <= 0:
		return 0.0
	return ECHO_DAMAGE_BASE + ECHO_DAMAGE_PER_LEVEL * (level - 1)

func get_magnetism_pull(level: int) -> float:
	return MAG_PULL_BASE + MAG_PULL_PER_LEVEL * (level - 1)

# ── Magnetism: pull enemies on hit ──

func apply_magnetism(hit_position: Vector2) -> void:
	var level = GameManager.get_passive_level("magnetism")
	if level <= 0:
		return
	var pull_strength = get_magnetism_pull(level)
	var enemies = _get_enemies_in_radius(hit_position, MAG_PULL_RADIUS)
	for enemy in enemies:
		var to_center = hit_position - enemy.global_position
		var dist = to_center.length()
		if dist < MAG_MIN_DISTANCE:
			continue
		var pull = to_center.normalized() * pull_strength
		enemy.global_position += pull

# ── Volatile Kill: corpse pop ──

func _on_enemy_killed(enemy_position: Vector2) -> void:
	var level = GameManager.get_passive_level("volatile_kill")
	if level <= 0:
		return
	var radius = VK_BASE_RADIUS + VK_RADIUS_PER_LEVEL * (level - 1)
	var base_damage = 10
	var pop_damage = int(base_damage * (VK_DAMAGE_RATIO_BASE + VK_DAMAGE_RATIO_PER_LEVEL * (level - 1)))
	pop_damage = maxi(pop_damage, 3)
	var enemies = _get_enemies_in_radius(enemy_position, radius)
	for enemy in enemies:
		enemy.take_damage(pop_damage)
		# Knockback
		var dir = (enemy.global_position - enemy_position).normalized()
		enemy.global_position += dir * VK_KNOCKBACK_FORCE * 0.1
	# VFX: spawn a quick AoE effect
	var aoe = PoolManager.acquire("aoe_effect")
	if aoe:
		aoe.reset(enemy_position, radius, Color(1.0, 0.3, 0.2, 0.8))

# ── Overclock: stack tracking ──

func _on_damage_dealt(_pos: Vector2, _amount: int) -> void:
	if not GameManager.has_passive("overclock"):
		return
	overclock_decay_timer = 0.0
	if overclock_stacks < overclock_max_stacks:
		overclock_stacks += 1

# ── Ricochet: bounce projectile to nearby enemy ──

func try_ricochet(hit_position: Vector2, hit_enemy: Node2D, damage: int, _color: Color) -> void:
	var bounces = get_ricochet_bounces()
	if bounces <= 0:
		return
	var bounce_damage = int(damage * RICO_DAMAGE_MULT)
	if bounce_damage < 1:
		return
	var enemies = _get_enemies_in_radius(hit_position, RICO_SEARCH_RADIUS)
	var targets_hit: Array[Node2D] = []
	if hit_enemy and is_instance_valid(hit_enemy):
		targets_hit.append(hit_enemy)
	for i in bounces:
		var next_target = _find_nearest_excluding(enemies, hit_position, targets_hit)
		if next_target == null:
			break
		next_target.take_damage(bounce_damage)
		targets_hit.append(next_target)
		hit_position = next_target.global_position

# ── Shrapnel: spawn fragments on projectile impact ──

func try_shrapnel(hit_position: Vector2, direction: Vector2, damage: int, color: Color) -> void:
	var count = get_shrapnel_count()
	if count <= 0:
		return
	var frag_damage = int(damage * SHRAP_DAMAGE_MULT)
	if frag_damage < 1:
		return
	var base_angle = direction.angle()
	var cone_rad = deg_to_rad(SHRAP_CONE_ANGLE)
	for i in count:
		var t = float(i) / float(count - 1) if count > 1 else 0.5
		var angle = base_angle - cone_rad * 0.5 + cone_rad * t
		var frag_dir = Vector2(cos(angle), sin(angle))
		var proj = PoolManager.acquire("projectile")
		if proj == null:
			break
		proj.global_position = hit_position
		proj.direction = frag_dir
		proj.speed = SHRAP_SPEED
		proj.damage = frag_damage
		proj.pierce = 1
		proj._hits_remaining = 1
		proj._lifetime = 0.0
		proj._max_lifetime = 0.5
		proj._ignore_enemy = null
		proj._is_fragment = true
		proj.rotation = frag_dir.angle()
		proj.color_rect.color = color * Color(1.0, 1.0, 1.0, 0.6)
		proj.hit_area.add_to_group("projectiles")

# ── Utility ──

# ── Phantom Echo: delayed projectile copy ──

func try_echo_projectile(player_pos: Vector2, direction: Vector2, data: WeaponData, level: int) -> void:
	var echo_mult = get_echo_damage_mult()
	if echo_mult <= 0.0:
		return
	get_tree().create_timer(ECHO_DELAY).timeout.connect(func():
		var proj = PoolManager.acquire("projectile")
		if proj == null:
			return
		proj.reset(player_pos, direction, data, level)
		proj.damage = int(proj.damage * echo_mult)
		proj._is_echo = true
		proj._is_fragment = true # Echoes cannot proc on-hit passives
		proj.color_rect.color = proj.color_rect.color * Color(1.0, 1.0, 1.0, 0.5)
	)

# ── Utility ──

func _get_enemies_in_radius(pos: Vector2, radius: float) -> Array:
	var result: Array = []
	var r2 = radius * radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_squared_to(pos) <= r2:
			result.append(enemy)
	return result

func _find_nearest_excluding(enemies: Array, from: Vector2, exclude: Array[Node2D]) -> Node2D:
	var best: Node2D = null
	var best_dist2 := INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy in exclude:
			continue
		var d2 = enemy.global_position.distance_squared_to(from)
		if d2 < best_dist2:
			best_dist2 = d2
			best = enemy
	return best
