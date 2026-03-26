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

	if data.is_evolution and data.weapon_id == "cluster_salvo":
		_fire_cluster_salvo(data, level, player_pos, valid_targets, missile_count)
		return

	for i in missile_count:
		var target = valid_targets[randi() % valid_targets.size()]
		var missile = PoolManager.acquire("homing_missile")
		if missile:
			missile.reset(player_pos, target, data, level)

# ── Cluster Salvo: missiles burst into submunitions on hit ──
const _CLUSTER_SUB_COUNT: int = 4
const _CLUSTER_SUB_DAMAGE_MULT: float = 0.35
const _CLUSTER_SUB_SPEED: float = 160.0
const _CLUSTER_SUB_LIFETIME: float = 0.6

func _fire_cluster_salvo(data: WeaponData, level: int, player_pos: Vector2,
		valid_targets: Array[Node2D], missile_count: int) -> void:
	for i in missile_count:
		var target = valid_targets[randi() % valid_targets.size()]
		var missile = PoolManager.acquire("homing_missile")
		if missile:
			missile.reset(player_pos, target, data, level)
			# Tag the missile to spawn submunitions when it hits
			missile.set_meta("cluster_salvo", true)
			missile.set_meta("cluster_data", data)
			missile.set_meta("cluster_level", level)
