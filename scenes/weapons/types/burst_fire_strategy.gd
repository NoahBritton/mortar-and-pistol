class_name BurstFireStrategy
extends WeaponStrategy

var _ghost_fire_count: int = 0  # Tracks shots for periodic dense burst

func fire(data: WeaponData, level: int) -> void:
	var target = find_nearest_enemy(data.attack_range)
	if target == null:
		return
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()
	var direction = (target.global_position - player_pos).normalized()

	if data.is_evolution and data.weapon_id == "ghost_barrage":
		_fire_ghost_barrage(data, level, player_pos, direction, target)
		return

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

# ── Ghost Barrage: spectral crossfire from offset positions ──
const _GHOST_OFFSET: float = 50.0  # Perpendicular offset for ghost guns
const _GHOST_VOLLEY_DELAY: float = 0.15  # Delay for ghost volleys
const _GHOST_DAMAGE_MULT: float = 0.6
const _GHOST_DENSE_EVERY: int = 4  # Every Nth shot is a dense burst
const _GHOST_DENSE_COUNT: int = 6  # Projectiles in dense burst

func _fire_ghost_barrage(data: WeaponData, level: int, player_pos: Vector2,
		direction: Vector2, _target: Node2D) -> void:
	_ghost_fire_count += 1
	var perp = direction.rotated(PI / 2.0)
	var ghost_damage = int(data.get_damage(level) * GameManager.damage_mult * _GHOST_DAMAGE_MULT)

	# Main burst: 2 rapid shots from player position
	var proj1 = PoolManager.acquire("projectile")
	if proj1:
		proj1.reset(player_pos, direction, data, level)
	get_scene_tree().create_timer(data.burst_delay).timeout.connect(func():
		var p = weapon_manager.get_parent()
		if not is_instance_valid(p):
			return
		var proj2 = PoolManager.acquire("projectile")
		if proj2:
			proj2.reset(p.global_position, direction, data, level)
	)

	# Ghost volleys: delayed shots from offset positions, slightly angled inward
	var left_pos = player_pos + perp * _GHOST_OFFSET
	var right_pos = player_pos - perp * _GHOST_OFFSET
	# Angle ghost shots inward toward the center line
	var left_dir = direction.rotated(-0.15)  # ~8.6 degrees inward
	var right_dir = direction.rotated(0.15)

	get_scene_tree().create_timer(_GHOST_VOLLEY_DELAY).timeout.connect(func():
		var gl = PoolManager.acquire("projectile")
		if gl:
			gl.reset(left_pos, left_dir, data, level)
			gl.damage = ghost_damage
			gl._is_fragment = true  # Ghost shots don't proc passives
			gl.color_rect.color = data.icon_color * Color(1.0, 1.0, 1.0, 0.5)
		var gr = PoolManager.acquire("projectile")
		if gr:
			gr.reset(right_pos, right_dir, data, level)
			gr.damage = ghost_damage
			gr._is_fragment = true
			gr.color_rect.color = data.icon_color * Color(1.0, 1.0, 1.0, 0.5)
	)

	# Periodic dense spectral burst: spray of ghost shots in a cone
	if _ghost_fire_count % _GHOST_DENSE_EVERY == 0:
		get_scene_tree().create_timer(_GHOST_VOLLEY_DELAY * 2).timeout.connect(func():
			var base_angle = direction.angle()
			var cone = deg_to_rad(60.0)
			for i in _GHOST_DENSE_COUNT:
				var t = float(i) / float(_GHOST_DENSE_COUNT - 1) if _GHOST_DENSE_COUNT > 1 else 0.5
				var angle = base_angle - cone * 0.5 + cone * t
				var d = Vector2(cos(angle), sin(angle))
				var proj = PoolManager.acquire("projectile")
				if proj:
					proj.reset(player_pos, d, data, level)
					proj.damage = ghost_damage
					proj._is_fragment = true
					proj.color_rect.color = data.icon_color * Color(0.8, 0.6, 1.0, 0.4)
		)
