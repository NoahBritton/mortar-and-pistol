class_name BeamStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)

	var player_pos = get_player_pos()
	var direction = (target.global_position - player_pos).normalized()
	var beam_length = data.attack_range
	var beam_end = player_pos + direction * beam_length
	var max_hits = data.get_pierce(level) + GameManager.pierce_bonus
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var beam_width = 8.0 * GameManager.area_mult

	# Hitscan: find all enemies along the beam line
	var enemies = get_scene_tree().get_nodes_in_group("enemies")
	var hits: Array[Node2D] = []

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var to_enemy = enemy.global_position - player_pos
		var proj_length = to_enemy.dot(direction)
		if proj_length < 0.0 or proj_length > beam_length:
			continue
		var perp_dist = absf(to_enemy.cross(direction))
		if perp_dist <= beam_width + 12.0:
			hits.append(enemy)

	# Sort by distance, apply damage to nearest first
	hits.sort_custom(func(a, b):
		return player_pos.distance_squared_to(a.global_position) < player_pos.distance_squared_to(b.global_position)
	)

	var actual_hits = mini(hits.size(), max_hits)
	for i in actual_hits:
		hits[i].take_damage(damage)

	# Spawn beam visual
	var effect = PoolManager.acquire("beam_effect")
	if effect:
		effect.reset(player_pos, beam_end, beam_width, data.icon_color)
