class_name ChainStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return

	AudioManager.play(AudioManager.sfx_shoot)
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var chain_count = data.get_pierce(level) + GameManager.pierce_bonus
	var chain_range = data.effect_radius

	if data.is_evolution and data.weapon_id == "storm_engine":
		_fire_storm_engine(data, level, target, damage, chain_count, chain_range)
		return

	var hit_positions: Array[Vector2] = []
	var hit_enemies: Array = []

	var current = target
	for i in chain_count:
		if current == null or not is_instance_valid(current):
			break
		current.take_damage(damage)
		hit_positions.append(current.global_position)
		hit_enemies.append(current)
		current = find_nearest_enemy_from(current.global_position, chain_range, hit_enemies)

	if hit_positions.size() > 0:
		var player_pos = get_player_pos()
		hit_positions.insert(0, player_pos)
		var effect = PoolManager.acquire("chain_effect")
		if effect:
			effect.reset(hit_positions, data.icon_color)

# ── Storm Engine: forking arcs during Overclock ──
const _STORM_FORK_DAMAGE_MULT: float = 0.4
const _STORM_FORK_RANGE: float = 100.0
const _STORM_MAX_FORKS_PER_NODE: int = 1
const _STORM_OVERLOAD_THRESHOLD: int = 3  # Overclock stacks needed for overload mode
const _STORM_OVERLOAD_BONUS_CHAINS: int = 3
const _STORM_OVERLOAD_PULSE_RADIUS: float = 120.0
const _STORM_OVERLOAD_PULSE_DAMAGE_MULT: float = 0.25

func _fire_storm_engine(data: WeaponData, level: int, target: Node2D,
		damage: int, chain_count: int, chain_range: float) -> void:
	var player_pos = get_player_pos()
	var is_overloaded = PassiveEffects.overclock_stacks >= _STORM_OVERLOAD_THRESHOLD

	# Overload: bonus chain count
	if is_overloaded:
		chain_count += _STORM_OVERLOAD_BONUS_CHAINS

	var hit_positions: Array[Vector2] = []
	var hit_enemies: Array = []
	var fork_targets: Array[Vector2] = []  # Positions where forks emanate from

	var current = target
	for i in chain_count:
		if current == null or not is_instance_valid(current):
			break
		current.take_damage(damage)
		hit_positions.append(current.global_position)
		hit_enemies.append(current)

		# During overload, mark every other hit node for forking
		if is_overloaded and i % 2 == 0:
			fork_targets.append(current.global_position)

		current = find_nearest_enemy_from(current.global_position, chain_range, hit_enemies)

	# Main chain VFX
	if hit_positions.size() > 0:
		hit_positions.insert(0, player_pos)
		var effect = PoolManager.acquire("chain_effect")
		if effect:
			effect.reset(hit_positions, data.icon_color)

	# Forking branches: from each fork point, zap a nearby unhit enemy
	if is_overloaded:
		var fork_damage = int(damage * _STORM_FORK_DAMAGE_MULT)
		if fork_damage < 1:
			fork_damage = 1
		for fork_pos in fork_targets:
			var fork_enemy = _find_fork_target(fork_pos, _STORM_FORK_RANGE, hit_enemies)
			if fork_enemy == null:
				continue
			fork_enemy.take_damage(fork_damage)
			SignalBus.damage_dealt.emit(fork_enemy.global_position, fork_damage)
			hit_enemies.append(fork_enemy)
			# Fork VFX: mini chain effect
			var fork_vfx = PoolManager.acquire("chain_effect")
			if fork_vfx:
				var fork_positions: Array[Vector2] = [fork_pos, fork_enemy.global_position]
				fork_vfx.reset(fork_positions,
					Color(data.icon_color.r, data.icon_color.g * 1.2, data.icon_color.b * 0.5, 0.7))

		# Overload pulse: AoE damage around player
		var pulse_damage = int(damage * _STORM_OVERLOAD_PULSE_DAMAGE_MULT)
		var pulse_r2 = _STORM_OVERLOAD_PULSE_RADIUS * _STORM_OVERLOAD_PULSE_RADIUS
		var enemies = get_scene_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			if player_pos.distance_squared_to(enemy.global_position) <= pulse_r2:
				enemy.take_damage(pulse_damage)
		var pulse_vfx = PoolManager.acquire("aoe_effect")
		if pulse_vfx:
			pulse_vfx.reset(player_pos, _STORM_OVERLOAD_PULSE_RADIUS,
				Color(data.icon_color.r, data.icon_color.g * 1.1, data.icon_color.b * 0.3, 0.5))

func _find_fork_target(from: Vector2, max_range: float, exclude: Array) -> Node2D:
	var enemies = get_scene_tree().get_nodes_in_group("enemies")
	var best: Node2D = null
	var best_d2 := INF
	var r2 = max_range * max_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy in exclude:
			continue
		var d2 = from.distance_squared_to(enemy.global_position)
		if d2 < r2 and d2 < best_d2:
			best_d2 = d2
			best = enemy
	return best
