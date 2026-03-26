class_name ProjectileStrategy
extends WeaponStrategy

var _weapon_angles: Dictionary = {}

func on_weapon_added(data: WeaponData) -> void:
	_weapon_angles[data.weapon_id] = 0.0

func on_weapon_removed(weapon_id: String) -> void:
	_weapon_angles.erase(weapon_id)

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return

	AudioManager.play(AudioManager.sfx_shoot)

	var player_pos = get_player_pos()
	var direction = (target.global_position - player_pos).normalized()
	var proj_count = data.get_projectile_count(level) + GameManager.proj_count_bonus

	# 360° weapons fire one projectile at a time in a rotating spiral
	if data.spread_angle >= 360.0:
		var step = 360.0 / proj_count
		var angle = _weapon_angles.get(data.weapon_id, 0.0)
		var proj = PoolManager.acquire("projectile")
		if proj:
			var dir = Vector2.RIGHT.rotated(deg_to_rad(angle))
			proj.reset(player_pos, dir, data, level)
		_weapon_angles[data.weapon_id] = fmod(angle + step, 360.0)
		return

	for i in proj_count:
		var angle_offset = 0.0
		if proj_count > 1:
			angle_offset = lerp(
				-data.spread_angle / 2.0,
				data.spread_angle / 2.0,
				float(i) / (proj_count - 1)
			)
		var dir = direction.rotated(deg_to_rad(angle_offset))
		var proj = PoolManager.acquire("projectile")
		if proj:
			proj.reset(player_pos, dir, data, level)
		PassiveEffects.try_echo_projectile(player_pos, dir, data, level)
