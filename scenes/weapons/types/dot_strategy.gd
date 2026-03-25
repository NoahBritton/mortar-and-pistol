class_name DotStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return

	AudioManager.play(AudioManager.sfx_shoot)

	var zone_pos = target.global_position
	var radius = data.effect_radius * GameManager.area_mult
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var tick_interval = data.tick_interval
	var duration = data.effect_duration + 0.5 * (level - 1)

	var zone = PoolManager.acquire("toxic_zone")
	if zone:
		zone.reset(zone_pos, radius, damage, tick_interval, duration, data.icon_color)
