class_name WeaponStrategy
extends RefCounted

var weapon_manager: Node

func _init(manager: Node) -> void:
	weapon_manager = manager

func on_weapon_added(_data: WeaponData) -> void:
	pass

func on_weapon_removed(_weapon_id: String) -> void:
	pass

func fire(_data: WeaponData, _level: int) -> void:
	pass

# ── Shared Helpers ──

func get_player_pos() -> Vector2:
	return weapon_manager.get_parent().global_position

func get_scene_tree() -> SceneTree:
	return weapon_manager.get_tree()

func get_last_move_direction() -> Vector2:
	return weapon_manager.last_move_direction

func find_nearest_enemy(max_range: float) -> Node2D:
	var enemies = weapon_manager.get_tree().get_nodes_in_group("enemies")
	var player_pos = get_player_pos()
	var nearest: Node2D = null
	var nearest_dist_sq: float = max_range * max_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist_sq = player_pos.distance_squared_to(enemy.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = enemy
	return nearest

func find_nearest_enemy_from(pos: Vector2, max_range: float, exclude: Array) -> Node2D:
	var enemies = weapon_manager.get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist_sq: float = max_range * max_range
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy in exclude:
			continue
		var dist_sq = pos.distance_squared_to(enemy.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = enemy
	return nearest
