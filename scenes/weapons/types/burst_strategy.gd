class_name BurstStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()

	if data.is_evolution and data.weapon_id == "implosion_flask":
		_fire_implosion(data, level, player_pos, target)
		return

	var flask = PoolManager.acquire("scatter_flask")
	if flask:
		flask.reset(player_pos, target, target.global_position, data, level)

# ── Implosion Flask: suction vortex → delayed detonation ──
const _IMPLOSION_SUCTION_TIME: float = 0.5
const _IMPLOSION_SUCTION_RADIUS: float = 120.0
const _IMPLOSION_PULL_STRENGTH: float = 3.0
const _IMPLOSION_BONUS_PER_ENEMY: float = 0.08  # 8% bonus damage per caught enemy
const _IMPLOSION_BONUS_CAP: int = 8  # Max enemies for bonus scaling

func _fire_implosion(data: WeaponData, level: int, player_pos: Vector2, target: Node2D) -> void:
	var target_pos = target.global_position
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var radius = data.effect_radius * GameManager.area_mult
	var suction_radius = _IMPLOSION_SUCTION_RADIUS * GameManager.area_mult
	var color = data.icon_color

	# Lob the flask to target
	var flask = PoolManager.acquire("scatter_flask")
	if flask == null:
		return
	# Disable the flask's normal shatter — we'll handle detonation ourselves
	flask.reset(player_pos, target, target_pos, data, level)
	# Override: suppress normal shatter by marking weapon data
	# Instead, we use a timer approach: wait for flask to land, then suction phase
	var tree = get_scene_tree()
	if tree == null:
		return

	# Phase 1: Wait for the flask to reach target (~travel time), then suction
	var travel_dist = player_pos.distance_to(target_pos)
	var travel_time = travel_dist / (data.projectile_speed * GameManager.proj_speed_mult)
	travel_time = maxf(travel_time, 0.1)

	# We'll do the suction + detonation at the impact position after travel time
	# The flask will shatter normally on impact, so we add suction AoE on top
	# Approach: create an independent suction vortex at target_pos
	tree.create_timer(travel_time + 0.05).timeout.connect(func():
		_spawn_suction_vortex(target_pos, damage, radius, suction_radius, color, data, level)
	)

func _spawn_suction_vortex(pos: Vector2, damage: int, blast_radius: float,
		suction_radius: float, color: Color, data: WeaponData, level: int) -> void:
	var tree = get_scene_tree()
	if tree == null:
		return

	# Pull enemies toward the impact point over suction_time
	var steps = 5
	var step_time = _IMPLOSION_SUCTION_TIME / steps
	for i in steps:
		tree.create_timer(step_time * i).timeout.connect(func():
			var enemies = tree.get_nodes_in_group("enemies")
			for enemy in enemies:
				if not is_instance_valid(enemy):
					continue
				var dist = enemy.global_position.distance_to(pos)
				if dist > suction_radius or dist < 8.0:
					continue
				var pull = (pos - enemy.global_position).normalized() * _IMPLOSION_PULL_STRENGTH
				enemy.global_position += pull
		)

	# Show VFX: pulsing suction ring
	var vfx = PoolManager.acquire("aoe_effect")
	if vfx:
		vfx.reset(pos, suction_radius, Color(color.r, color.g, color.b, 0.4))

	# Phase 2: Detonation after suction completes
	tree.create_timer(_IMPLOSION_SUCTION_TIME).timeout.connect(func():
		# Count enemies caught for bonus
		var caught := 0
		var enemies = tree.get_nodes_in_group("enemies")
		var r2 = blast_radius * blast_radius
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			if enemy.global_position.distance_squared_to(pos) <= r2:
				caught += 1

		# Bonus damage from enemy density, capped
		var bonus_mult = 1.0 + _IMPLOSION_BONUS_PER_ENEMY * mini(caught, _IMPLOSION_BONUS_CAP)
		var final_damage = int(damage * bonus_mult)

		# Detonate — damage all in radius
		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			if enemy.global_position.distance_squared_to(pos) <= r2:
				enemy.take_damage(final_damage)
				SignalBus.damage_dealt.emit(enemy.global_position, final_damage)

		# Explosion VFX
		var effect = PoolManager.acquire("aoe_effect")
		if effect:
			effect.reset(pos, blast_radius, color)
		SignalBus.screen_shake_requested.emit(5.0, 0.2)

		# Shrapnel burst
		var shrapnel_count = data.get_projectile_count(level) + GameManager.proj_count_bonus
		for i in shrapnel_count:
			var angle = TAU * float(i) / shrapnel_count
			var dir = Vector2(cos(angle), sin(angle))
			var proj = PoolManager.acquire("projectile")
			if proj:
				proj.reset(pos + dir * 14.0, dir, data, level)
				proj.speed = data.projectile_speed * 0.8
				proj._hits_remaining = 1
				proj._is_fragment = true
	)
