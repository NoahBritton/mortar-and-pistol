class_name MeleeStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var player_pos = get_player_pos()
	var reach = data.effect_radius * GameManager.area_mult
	var arc_deg = data.spread_angle
	var damage = int(data.get_damage(level) * GameManager.damage_mult)

	# Swing toward nearest enemy, fallback to movement direction
	var swing_dir: Vector2
	var nearest = find_nearest_enemy(data.attack_range)
	if nearest:
		swing_dir = (nearest.global_position - player_pos).normalized()
	else:
		swing_dir = get_last_move_direction()

	var swing_angle = swing_dir.angle()

	AudioManager.play(AudioManager.sfx_shoot)

	var effect = PoolManager.acquire("melee_effect")
	if effect:
		effect.reset(player_pos, reach, arc_deg, swing_angle, data.icon_color, damage)

	# Reaper's Bayonet afterimage: delayed half-damage sweep
	if data.spread_angle >= 360.0 and data.is_evolution:
		_fire_afterimage(player_pos, reach, arc_deg, swing_angle, data, level)

func _fire_afterimage(pos: Vector2, reach: float, arc_deg: float, angle: float, data: WeaponData, level: int) -> void:
	var half_damage = int(data.get_damage(level) * GameManager.damage_mult * 0.5)
	var timer = get_scene_tree().create_timer(0.15)
	timer.timeout.connect(func():
		var aftereffect = PoolManager.acquire("melee_effect")
		if aftereffect:
			aftereffect.reset(pos, reach * 1.1, arc_deg, angle, Color(data.icon_color, 0.5), half_damage, true)
	)
