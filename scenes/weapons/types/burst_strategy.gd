class_name BurstStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()
	var flask = PoolManager.acquire("scatter_flask")
	if flask:
		flask.reset(player_pos, target, target.global_position, data, level)
