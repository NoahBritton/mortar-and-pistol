class_name BarrageStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var enemies = get_scene_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	var player_pos = get_player_pos()
	var range_sq = data.attack_range * data.attack_range

	var valid_targets: Array[Node2D] = []
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if player_pos.distance_squared_to(enemy.global_position) <= range_sq:
			valid_targets.append(enemy)

	if valid_targets.is_empty():
		return

	AudioManager.play(AudioManager.sfx_shoot)

	var missile_count = data.get_projectile_count(level) + GameManager.proj_count_bonus
	for i in missile_count:
		var target = valid_targets[randi() % valid_targets.size()]
		var missile = PoolManager.acquire("homing_missile")
		if missile:
			missile.reset(player_pos, target, data, level)
