class_name AoeStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var player_pos = get_player_pos()
	var radius = data.effect_radius * GameManager.area_mult
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var hit_any = false

	for enemy in get_scene_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if player_pos.distance_squared_to(enemy.global_position) <= radius * radius:
			enemy.take_damage(damage)
			hit_any = true

	if hit_any:
		AudioManager.play(AudioManager.sfx_shoot)

	var effect = PoolManager.acquire("aoe_effect")
	if effect:
		effect.reset(player_pos, radius, data.icon_color)
