extends Node

# Inventory limits
const MAX_WEAPON_SLOTS: int = 6
const MAX_PASSIVE_SLOTS: int = 6

# Character definitions
enum CharacterID { WIZARD, ALCHEMIST, BOMBARDIER, ASSASSIN }

const CHARACTER_DATA: Dictionary = {
	CharacterID.WIZARD: {
		"name": "Wizard",
		"description": "Arcane scholar. Fires a piercing bolt of energy.",
		"weapon_id": "bolt_rifle",
		"color": Color(0.4, 0.6, 1.0),
		"stat_key": "fire_rate_mult",
		"stat_bonus": 0.10,
		"stat_label": "+10% Fire Rate",
	},
	CharacterID.ALCHEMIST: {
		"name": "Alchemist",
		"description": "Potion master. Throws flasks that shatter into shrapnel.",
		"weapon_id": "scatter_flask",
		"color": Color(0.4, 1.0, 0.4),
		"stat_key": "area_mult",
		"stat_bonus": 0.12,
		"stat_label": "+12% AoE Radius",
	},
	CharacterID.BOMBARDIER: {
		"name": "Bombardier",
		"description": "Explosives expert. Drops powder kegs that detonate.",
		"weapon_id": "powder_keg",
		"color": Color(1.0, 0.4, 0.1),
		"stat_key": "damage_mult",
		"stat_bonus": 0.15,
		"stat_label": "+15% Damage",
	},
	CharacterID.ASSASSIN: {
		"name": "Assassin",
		"description": "Swift rogue. Fires twin shots in rapid bursts.",
		"weapon_id": "twin_barrels",
		"color": Color(0.7, 0.9, 1.0),
		"stat_key": "move_speed_mult",
		"stat_bonus": 0.15,
		"stat_label": "+15% Move Speed",
	},
}

var selected_character: int = CharacterID.WIZARD

# Debug
var god_mode: bool = false

# Run state
var kill_count: int = 0
var elapsed_time: float = 0.0
var is_game_active: bool = false
var rerolls_remaining: int = 3
var pending_levels: int = 0

# Player core stats
var player_level: int = 1
var player_xp: int = 0
var player_max_hp: int = 100
var player_current_hp: int = 100
var xp_base: int = 10
var xp_exponent: float = 1.3

# Weapon & passive inventories
var weapon_inventory: Array[Dictionary] = []  # { "data": WeaponData, "level": int }
var passive_inventory: Array[Dictionary] = []  # { "data": PassiveData, "level": int }

# Resolved stat multipliers (recalculated from passives)
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var move_speed_mult: float = 1.0
var proj_speed_mult: float = 1.0
var pickup_range_mult: float = 1.0
var area_mult: float = 1.0
var xp_mult: float = 1.0
var pierce_bonus: int = 0
var proj_count_bonus: int = 0
var max_hp_bonus: int = 0

# ── XP / Leveling ──

func xp_to_next_level() -> int:
	return int(xp_base * pow(player_level, xp_exponent))

func add_xp(amount: int) -> void:
	var xp = int(amount * xp_mult)
	if god_mode:
		xp = max(1, xp_to_next_level() / 2)
	player_xp += xp
	SignalBus.xp_gained.emit(xp)
	while player_xp >= xp_to_next_level():
		player_xp -= xp_to_next_level()
		player_level += 1
		pending_levels += 1
	if pending_levels > 0:
		SignalBus.player_leveled_up.emit(player_level)

func add_kill() -> void:
	kill_count += 1

func take_damage(amount: int) -> void:
	if god_mode or not is_game_active:
		return
	var effective_max = player_max_hp + max_hp_bonus
	player_current_hp = max(0, player_current_hp - amount)
	SignalBus.player_health_changed.emit(player_current_hp, effective_max)
	if player_current_hp <= 0:
		is_game_active = false
		SignalBus.player_died.emit()

func heal(amount: int) -> void:
	var effective_max = player_max_hp + max_hp_bonus
	player_current_hp = mini(player_current_hp + amount, effective_max)
	SignalBus.player_health_changed.emit(player_current_hp, effective_max)

# ── Weapon Inventory ──

func add_weapon(weapon_data: WeaponData) -> bool:
	if weapon_inventory.size() >= MAX_WEAPON_SLOTS:
		return false
	if has_weapon(weapon_data.weapon_id):
		return false
	weapon_inventory.append({"data": weapon_data, "level": 1})
	SignalBus.inventory_changed.emit()
	return true

func upgrade_weapon(weapon_id: String) -> void:
	for entry in weapon_inventory:
		if entry.data.weapon_id == weapon_id and entry.level < entry.data.max_level:
			entry.level += 1
			SignalBus.inventory_changed.emit()
			break

func has_weapon(weapon_id: String) -> bool:
	for entry in weapon_inventory:
		if entry.data.weapon_id == weapon_id:
			return true
	return false

func get_weapon_entry(weapon_id: String) -> Dictionary:
	for entry in weapon_inventory:
		if entry.data.weapon_id == weapon_id:
			return entry
	return {}

func evolve_weapon(base_weapon_id: String, evolved_weapon: WeaponData) -> void:
	for i in weapon_inventory.size():
		if weapon_inventory[i].data.weapon_id == base_weapon_id:
			weapon_inventory[i] = {"data": evolved_weapon, "level": 1}
			SignalBus.inventory_changed.emit()
			break

# ── Passive Inventory ──

func add_passive(passive_data: PassiveData) -> bool:
	if passive_inventory.size() >= MAX_PASSIVE_SLOTS:
		return false
	if has_passive(passive_data.passive_id):
		return false
	passive_inventory.append({"data": passive_data, "level": 1})
	_recalculate_stats()
	SignalBus.inventory_changed.emit()
	return true

func upgrade_passive(passive_id: String) -> void:
	for entry in passive_inventory:
		if entry.data.passive_id == passive_id and entry.level < entry.data.max_level:
			entry.level += 1
			break
	_recalculate_stats()
	SignalBus.inventory_changed.emit()

func has_passive(passive_id: String) -> bool:
	for entry in passive_inventory:
		if entry.data.passive_id == passive_id:
			return true
	return false

# ── Choice Application ──

func apply_choice(choice: Dictionary) -> void:
	match choice.type:
		"new_weapon":
			add_weapon(choice.data)
		"upgrade_weapon":
			upgrade_weapon(choice.data.weapon_id)
		"new_passive":
			add_passive(choice.data)
		"upgrade_passive":
			upgrade_passive(choice.data.passive_id)

# ── Evolution Checking ──

func check_evolutions() -> Array[EvolutionData]:
	var available: Array[EvolutionData] = []
	for rule in EvolutionDB.get_all_rules():
		if has_weapon(rule.evolved_weapon_id):
			continue
		var entry = get_weapon_entry(rule.base_weapon_id)
		if entry.is_empty():
			continue
		if entry.level < entry.data.max_level:
			continue
		if not has_passive(rule.required_passive_id):
			continue
		available.append(rule)
	return available

# ── Stat Resolution ──

func _recalculate_stats() -> void:
	damage_mult = 1.0
	fire_rate_mult = 1.0
	move_speed_mult = 1.0
	proj_speed_mult = 1.0
	pickup_range_mult = 1.0
	area_mult = 1.0
	xp_mult = 1.0
	pierce_bonus = 0
	proj_count_bonus = 0
	var old_hp_bonus = max_hp_bonus
	max_hp_bonus = 0

	for entry in passive_inventory:
		var value = entry.data.value_per_level * entry.level
		match entry.data.stat_key:
			"damage_mult": damage_mult += value
			"fire_rate_mult": fire_rate_mult += value
			"move_speed_mult": move_speed_mult += value
			"proj_speed_mult": proj_speed_mult += value
			"pickup_range_mult": pickup_range_mult += value
			"area_mult": area_mult += value
			"xp_mult": xp_mult += value
			"pierce_bonus": pierce_bonus += int(value)
			"proj_count_bonus": proj_count_bonus += int(value)
			"max_hp_bonus": max_hp_bonus += int(value)

	if max_hp_bonus != old_hp_bonus:
		var new_max = player_max_hp + max_hp_bonus
		player_current_hp += max_hp_bonus - old_hp_bonus
		player_current_hp = clampi(player_current_hp, 1, new_max)
		SignalBus.player_health_changed.emit(player_current_hp, new_max)

	_apply_character_bonus()

# ── Run Reset ──

func reset_run() -> void:
	kill_count = 0
	elapsed_time = 0.0
	player_level = 1
	player_xp = 0
	player_max_hp = 100
	player_current_hp = 100
	is_game_active = true
	rerolls_remaining = 3
	pending_levels = 0
	weapon_inventory.clear()
	passive_inventory.clear()
	_recalculate_stats()

func _apply_character_bonus() -> void:
	var char_data = CHARACTER_DATA[selected_character]
	var bonus = char_data.stat_bonus
	match char_data.stat_key:
		"damage_mult": damage_mult += bonus
		"fire_rate_mult": fire_rate_mult += bonus
		"move_speed_mult": move_speed_mult += bonus
		"area_mult": area_mult += bonus

func get_dash_cooldown_reduction() -> float:
	for entry in passive_inventory:
		if entry.data.passive_id == "wind_vents":
			return entry.level * 0.3
	return 0.0
