class_name BeamStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)

	var player_pos = get_player_pos()
	var direction = (target.global_position - player_pos).normalized()
	var beam_length = data.attack_range
	var beam_end = player_pos + direction * beam_length
	var max_hits = data.get_pierce(level) + GameManager.pierce_bonus
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var beam_width = 8.0 * GameManager.area_mult

	# Hitscan: find all enemies along the beam line
	var enemies = get_scene_tree().get_nodes_in_group("enemies")
	var hits: Array[Node2D] = []

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var to_enemy = enemy.global_position - player_pos
		var proj_length = to_enemy.dot(direction)
		if proj_length < 0.0 or proj_length > beam_length:
			continue
		var perp_dist = absf(to_enemy.cross(direction))
		if perp_dist <= beam_width + 12.0:
			hits.append(enemy)

	# Sort by distance, apply damage to nearest first
	hits.sort_custom(func(a, b):
		return player_pos.distance_squared_to(a.global_position) < player_pos.distance_squared_to(b.global_position)
	)

	var actual_hits = mini(hits.size(), max_hits)
	for i in actual_hits:
		hits[i].take_damage(damage)

	# Spawn beam visual
	var effect = PoolManager.acquire("beam_effect")
	if effect:
		effect.reset(player_pos, beam_end, beam_width, data.icon_color)

	# Refraction Beam: side-beams from hit points toward nearby enemies
	if data.is_evolution and data.weapon_id == "refraction_beam":
		_fire_refractions(data, level, player_pos, direction, hits, actual_hits, damage, beam_width)

# ── Refraction Beam: side-beams toward nearby enemies ──
const _REFRACT_SIDE_RANGE: float = 180.0
const _REFRACT_SIDE_DAMAGE_MULT: float = 0.5
const _REFRACT_MAX_SIDE_BEAMS: int = 4
const _REFRACT_SIDE_LENGTH: float = 150.0
const _REFRACT_MIN_ANGLE: float = 0.4  # ~23 degrees minimum deviation from main beam

func _fire_refractions(data: WeaponData, _level: int, _player_pos: Vector2,
		main_dir: Vector2, hits: Array[Node2D], hit_count: int,
		damage: int, beam_width: float) -> void:
	var side_damage = int(damage * _REFRACT_SIDE_DAMAGE_MULT)
	if side_damage < 1:
		return
	var enemies = get_scene_tree().get_nodes_in_group("enemies")
	var refract_targets_used: Array[Node2D] = []
	# Collect hit enemies to exclude
	for i in hit_count:
		refract_targets_used.append(hits[i])

	var side_beams_spawned := 0

	# From each hit point, find a nearby enemy not on the main beam
	for i in hit_count:
		if side_beams_spawned >= _REFRACT_MAX_SIDE_BEAMS:
			break
		var hit_pos = hits[i].global_position
		# Find nearest enemy not already hit by main beam or previous refraction
		var best_enemy: Node2D = null
		var best_dist_sq := INF
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			if enemy in refract_targets_used:
				continue
			var d2 = hit_pos.distance_squared_to(enemy.global_position)
			if d2 > _REFRACT_SIDE_RANGE * _REFRACT_SIDE_RANGE:
				continue
			# Ensure side beam angles away from main beam enough
			var side_dir = (enemy.global_position - hit_pos).normalized()
			var angle_from_main = absf(side_dir.angle_to(main_dir))
			if angle_from_main < _REFRACT_MIN_ANGLE:
				continue
			if d2 < best_dist_sq:
				best_dist_sq = d2
				best_enemy = enemy
		if best_enemy == null:
			continue
		refract_targets_used.append(best_enemy)
		side_beams_spawned += 1

		# Damage the refraction target
		best_enemy.take_damage(side_damage)
		SignalBus.damage_dealt.emit(best_enemy.global_position, side_damage)

		# Side beam VFX
		var side_end = hit_pos + (best_enemy.global_position - hit_pos).normalized() * _REFRACT_SIDE_LENGTH
		var side_vfx = PoolManager.acquire("beam_effect")
		if side_vfx:
			side_vfx.reset(hit_pos, side_end, beam_width * 0.6,
				Color(data.icon_color.r * 0.8, data.icon_color.g * 1.1, data.icon_color.b * 1.1, 0.7))
