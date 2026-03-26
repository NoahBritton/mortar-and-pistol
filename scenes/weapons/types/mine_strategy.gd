class_name MineStrategy
extends WeaponStrategy

func fire(data: WeaponData, level: int) -> void:
	AudioManager.play(AudioManager.sfx_shoot)
	var player_pos = get_player_pos()
	var damage = int(data.get_damage(level) * GameManager.damage_mult)
	var radius = data.effect_radius * GameManager.area_mult

	if data.is_evolution and data.weapon_id == "chain_detonation_keg":
		_fire_chain_keg(data, level, player_pos, damage, radius)
		return

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

# ── Chain-Detonation Keg: kills propagate corpse explosions ──
const _CHAIN_FUSE: float = 0.6
const _CHAIN_PROPAGATE_DELAY: float = 0.25
const _CHAIN_PROPAGATE_RADIUS: float = 100.0
const _CHAIN_DAMAGE_FALLOFF: float = 0.7  # Each chain deals 70% of previous
const _CHAIN_MAX_DEPTH: int = 4

func _fire_chain_keg(data: WeaponData, _level: int, player_pos: Vector2,
		damage: int, radius: float) -> void:
	var keg_count = 1 + GameManager.proj_count_bonus
	var color = data.icon_color

	for i in keg_count:
		var mine = PoolManager.acquire("powder_keg")
		if mine == null:
			continue
		if i == 0:
			mine.reset(player_pos, damage, radius, _CHAIN_FUSE, color, 0, data)
			mine.set_meta("chain_depth", 0)
			mine.set_meta("chain_data", data)
			mine.set_meta("chain_base_damage", damage)
		else:
			var angle = randf() * TAU
			var dist = randf_range(60.0, 120.0)
			var target_pos = player_pos + Vector2(cos(angle), sin(angle)) * dist
			mine.reset(player_pos, damage, radius, _CHAIN_FUSE, color, 0, data, target_pos)
			mine.set_meta("chain_depth", 0)
			mine.set_meta("chain_data", data)
			mine.set_meta("chain_base_damage", damage)

# Static method callable from detonation to propagate chain
static func spawn_chain_explosion(pos: Vector2, base_damage: int, data: WeaponData,
		depth: int, tree: SceneTree) -> void:
	if depth >= _CHAIN_MAX_DEPTH:
		return
	var chain_damage = int(base_damage * _CHAIN_DAMAGE_FALLOFF)
	if chain_damage < 1:
		return
	var radius = data.effect_radius * GameManager.area_mult

	# Find enemies killed by this blast
	tree.create_timer(_CHAIN_PROPAGATE_DELAY).timeout.connect(func():
		var killed_positions: Array[Vector2] = []
		var enemies = tree.get_nodes_in_group("enemies")
		var r2 = _CHAIN_PROPAGATE_RADIUS * _CHAIN_PROPAGATE_RADIUS

		for enemy in enemies:
			if not is_instance_valid(enemy):
				continue
			if enemy.global_position.distance_squared_to(pos) > r2:
				continue
			# Check if enemy would die from this damage
			if enemy.has_method("get_health") and enemy.get_health() <= chain_damage:
				killed_positions.append(enemy.global_position)
			enemy.take_damage(chain_damage)
			SignalBus.damage_dealt.emit(enemy.global_position, chain_damage)

		# VFX
		var effect = PoolManager.acquire("aoe_effect")
		if effect:
			effect.reset(pos, radius * 0.8, Color(data.icon_color.r, data.icon_color.g, data.icon_color.b, 0.7))
		SignalBus.screen_shake_requested.emit(3.0, 0.1)

		# Propagate from killed positions
		for kpos in killed_positions:
			spawn_chain_explosion(kpos, chain_damage, data, depth + 1, tree)
	)
