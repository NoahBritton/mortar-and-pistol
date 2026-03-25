class_name MineStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var radius = data.effect_radius * GameManager.area_mult

	# Fuse scales from 1.5s at Lv1 to 0.8s at Lv5
	var fuse = lerpf(1.5, 0.8, clampf(float(level - 1) / 4.0, 0.0, 1.0))

	# Extra Powder synergy: drop additional kegs
	var keg_count = 1 + GameManager.proj_count_bonus
	var shrapnel_count = GameManager.pierce_bonus

	for i in keg_count:
		var mine = PoolManager.acquire("powder_keg")
		if mine:
			if i == 0:
				# First keg drops at feet (no arc)
				mine.reset(player_pos, damage, radius, fuse, data.icon_color, shrapnel_count, data)
			else:
				# Extra kegs are thrown in an arc to random nearby positions
				var angle = randf() * TAU
				var dist = randf_range(60.0, 120.0)
				var target_pos = player_pos + Vector2(cos(angle), sin(angle)) * dist
				mine.reset(player_pos, damage, radius, fuse, data.icon_color, shrapnel_count, data, target_pos)
