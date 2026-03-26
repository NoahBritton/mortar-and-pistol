class_name BurstFireStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()
	var direction = (target.global_position - player_pos).normalized()
	# First shot
	var proj1 = PoolManager.acquire("projectile")
	if proj1:
		proj1.reset(player_pos, direction, data, level)
	# Second shot after burst_delay
	var delay = data.burst_delay
	get_scene_tree().create_timer(delay).timeout.connect(func():
		var p = weapon_manager.get_parent()
		if not is_instance_valid(p):
			return
		var proj2 = PoolManager.acquire("projectile")
		if proj2:
			proj2.reset(p.global_position, direction, data, level)
	)
	# Phantom Echo (fires echo of the burst)
	PassiveEffects.try_echo_projectile(player_pos, direction, data, level)
