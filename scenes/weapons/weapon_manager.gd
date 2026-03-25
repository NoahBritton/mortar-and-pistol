extends Node

# ── Strategy Registry ──

const _STRATEGY_SCRIPTS: Dictionary = {
	WeaponData.WeaponType.PROJECTILE: preload("res://scenes/weapons/types/projectile_strategy.gd"),
	WeaponData.WeaponType.AOE: preload("res://scenes/weapons/types/aoe_strategy.gd"),
	WeaponData.WeaponType.CHAIN: preload("res://scenes/weapons/types/chain_strategy.gd"),
	WeaponData.WeaponType.ORBIT: preload("res://scenes/weapons/types/orbit_strategy.gd"),
	WeaponData.WeaponType.MELEE: preload("res://scenes/weapons/types/melee_strategy.gd"),
	WeaponData.WeaponType.DOT: preload("res://scenes/weapons/types/dot_strategy.gd"),
	WeaponData.WeaponType.BARRAGE: preload("res://scenes/weapons/types/barrage_strategy.gd"),
	WeaponData.WeaponType.PIERCING: preload("res://scenes/weapons/types/piercing_strategy.gd"),
	WeaponData.WeaponType.BURST: preload("res://scenes/weapons/types/burst_strategy.gd"),
	WeaponData.WeaponType.MINE: preload("res://scenes/weapons/types/mine_strategy.gd"),
	WeaponData.WeaponType.BURST_FIRE: preload("res://scenes/weapons/types/burst_fire_strategy.gd"),
	WeaponData.WeaponType.BEAM: preload("res://scenes/weapons/types/beam_strategy.gd"),
}

var _weapon_timers: Dictionary = {}
var _weapon_types: Dictionary = {}
var _strategies: Dictionary = {}
var last_move_direction: Vector2 = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	var parent_velocity = get_parent().velocity
	if parent_velocity.length_squared() > 0.01:
		last_move_direction = parent_velocity.normalized()

# ── Weapon Lifecycle ──

func add_weapon(weapon_data: WeaponData) -> void:
	var timer = Timer.new()
	timer.wait_time = 1.0 / (weapon_data.get_fire_rate(1) * GameManager.fire_rate_mult)
	timer.autostart = true
	timer.timeout.connect(_on_weapon_fire.bind(weapon_data.weapon_id))
	add_child(timer)
	_weapon_timers[weapon_data.weapon_id] = timer
	_weapon_types[weapon_data.weapon_id] = weapon_data.weapon_type

	var strategy = _get_strategy(weapon_data.weapon_type)
	strategy.on_weapon_added(weapon_data)

func remove_weapon(weapon_id: String) -> void:
	if _weapon_timers.has(weapon_id):
		_weapon_timers[weapon_id].queue_free()
		_weapon_timers.erase(weapon_id)
	if _weapon_types.has(weapon_id):
		var strategy = _get_strategy(_weapon_types[weapon_id])
		strategy.on_weapon_removed(weapon_id)
		_weapon_types.erase(weapon_id)

func replace_weapon(old_id: String, new_data: WeaponData) -> void:
	remove_weapon(old_id)
	add_weapon(new_data)

# ── Fire Dispatch ──

func _on_weapon_fire(weapon_id: String) -> void:
	var entry = GameManager.get_weapon_entry(weapon_id)
	if entry.is_empty():
		return
	var data: WeaponData = entry.data
	var level: int = entry.level

	var rate_mult = GameManager.fire_rate_mult
	# Quicksilver synergy: for MINE weapons, proj_speed_mult boosts fire rate
	if data.weapon_type == WeaponData.WeaponType.MINE:
		rate_mult *= GameManager.proj_speed_mult
	_weapon_timers[weapon_id].wait_time = 1.0 / (data.get_fire_rate(level) * rate_mult)

	var strategy = _get_strategy(data.weapon_type)
	strategy.fire(data, level)

# ── Strategy Resolution ──

func _get_strategy(weapon_type: WeaponData.WeaponType) -> WeaponStrategy:
	if not _strategies.has(weapon_type):
		if not _STRATEGY_SCRIPTS.has(weapon_type):
			push_error("No strategy registered for weapon type: " + str(weapon_type))
			return null
		_strategies[weapon_type] = _STRATEGY_SCRIPTS[weapon_type].new(self)
	return _strategies[weapon_type]
