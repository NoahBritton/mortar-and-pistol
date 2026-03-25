class_name PiercingStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()
	var direction = (target.global_position - player_pos).normalized()
	var proj = PoolManager.acquire("projectile")
	if proj:
		proj.reset(player_pos, direction, data, level)
