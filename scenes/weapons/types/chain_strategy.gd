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
