class_name PassivesDB

static var _passives: Dictionary = {}
static var _initialized: bool = false

static func _ensure_init() -> void:
	if _initialized:
		return
	_initialized = true

	var gunpowder = PassiveData.new()
	gunpowder.passive_id = "gunpowder"
	gunpowder.passive_name = "Gunpowder"
	gunpowder.description = "+10% Damage per level"
	gunpowder.icon_color = Color(0.2, 0.8, 0.2)
	gunpowder.max_level = 5
	gunpowder.stat_key = "damage_mult"
	gunpowder.value_per_level = 0.10
	_passives["gunpowder"] = gunpowder

	var clockwork = PassiveData.new()
	clockwork.passive_id = "clockwork"
	clockwork.passive_name = "Clockwork"
	clockwork.description = "+8% Attack Speed per level"
	clockwork.icon_color = Color(0.6, 0.4, 0.2)
	clockwork.max_level = 5
	clockwork.stat_key = "fire_rate_mult"
	clockwork.value_per_level = 0.08
	_passives["clockwork"] = clockwork

	var quicksilver = PassiveData.new()
	quicksilver.passive_id = "quicksilver"
	quicksilver.passive_name = "Quicksilver"
	quicksilver.description = "+10% Weapon Speed per level"
	quicksilver.icon_color = Color(0.8, 0.6, 0.2)
	quicksilver.max_level = 5
	quicksilver.stat_key = "proj_speed_mult"
	quicksilver.value_per_level = 0.10
	_passives["quicksilver"] = quicksilver

	var birdshot = PassiveData.new()
	birdshot.passive_id = "birdshot"
	birdshot.passive_name = "Birdshot"
	birdshot.description = "+1 Pierce/Chain per level"
	birdshot.icon_color = Color(0.4, 0.8, 1.0)
	birdshot.max_level = 5
	birdshot.stat_key = "pierce_bonus"
	birdshot.value_per_level = 1.0
	birdshot.is_percentage = false
	_passives["birdshot"] = birdshot

	var wind_vents = PassiveData.new()
	wind_vents.passive_id = "wind_vents"
	wind_vents.passive_name = "Wind Vents"
	wind_vents.description = "+8% Move Speed per level"
	wind_vents.icon_color = Color(0.7, 0.9, 1.0)
	wind_vents.max_level = 5
	wind_vents.stat_key = "move_speed_mult"
	wind_vents.value_per_level = 0.08
	_passives["wind_vents"] = wind_vents

	var lodestone = PassiveData.new()
	lodestone.passive_id = "lodestone"
	lodestone.passive_name = "Lodestone"
	lodestone.description = "+15% Pickup Range per level"
	lodestone.icon_color = Color(0.5, 0.2, 0.8)
	lodestone.max_level = 5
	lodestone.stat_key = "pickup_range_mult"
	lodestone.value_per_level = 0.15
	_passives["lodestone"] = lodestone

	var focusing_lens = PassiveData.new()
	focusing_lens.passive_id = "focusing_lens"
	focusing_lens.passive_name = "Focusing Lens"
	focusing_lens.description = "+8% Area per level"
	focusing_lens.icon_color = Color(1.0, 0.67, 0.25)
	focusing_lens.max_level = 5
	focusing_lens.stat_key = "area_mult"
	focusing_lens.value_per_level = 0.08
	_passives["focusing_lens"] = focusing_lens

	var extra_powder = PassiveData.new()
	extra_powder.passive_id = "extra_powder"
	extra_powder.passive_name = "Extra Powder"
	extra_powder.description = "+1 Projectile per level"
	extra_powder.icon_color = Color(0.49, 0.7, 0.26)
	extra_powder.max_level = 5
	extra_powder.stat_key = "proj_count_bonus"
	extra_powder.value_per_level = 1.0
	extra_powder.is_percentage = false
	_passives["extra_powder"] = extra_powder

	# ── Phase 1 Behavioral Passives ──

	var magnetism = PassiveData.new()
	magnetism.passive_id = "magnetism"
	magnetism.passive_name = "Magnetism"
	magnetism.description = "Hits pull enemies toward the impact point."
	magnetism.icon_color = Color(0.3, 0.5, 0.9)
	magnetism.max_level = 5
	magnetism.passive_type = PassiveData.PassiveType.BEHAVIOR
	_passives["magnetism"] = magnetism

	var volatile_kill = PassiveData.new()
	volatile_kill.passive_id = "volatile_kill"
	volatile_kill.passive_name = "Volatile Kill"
	volatile_kill.description = "Killed enemies pop for AoE damage."
	volatile_kill.icon_color = Color(1.0, 0.3, 0.2)
	volatile_kill.max_level = 5
	volatile_kill.passive_type = PassiveData.PassiveType.BEHAVIOR
	_passives["volatile_kill"] = volatile_kill

	var phantom_echo = PassiveData.new()
	phantom_echo.passive_id = "phantom_echo"
	phantom_echo.passive_name = "Phantom Echo"
	phantom_echo.description = "Projectiles and bursts fire a delayed echo."
	phantom_echo.icon_color = Color(0.6, 0.4, 0.9)
	phantom_echo.max_level = 5
	phantom_echo.passive_type = PassiveData.PassiveType.BEHAVIOR
	_passives["phantom_echo"] = phantom_echo

	var ricochet = PassiveData.new()
	ricochet.passive_id = "ricochet"
	ricochet.passive_name = "Ricochet"
	ricochet.description = "Projectile hits bounce to nearby enemies."
	ricochet.icon_color = Color(0.2, 0.8, 0.7)
	ricochet.max_level = 5
	ricochet.passive_type = PassiveData.PassiveType.BEHAVIOR
	_passives["ricochet"] = ricochet

	var shrapnel = PassiveData.new()
	shrapnel.passive_id = "shrapnel"
	shrapnel.passive_name = "Shrapnel"
	shrapnel.description = "Projectile impacts split into fragments."
	shrapnel.icon_color = Color(0.9, 0.6, 0.2)
	shrapnel.max_level = 5
	shrapnel.passive_type = PassiveData.PassiveType.BEHAVIOR
	_passives["shrapnel"] = shrapnel

	var overclock = PassiveData.new()
	overclock.passive_id = "overclock"
	overclock.passive_name = "Overclock"
	overclock.description = "Consecutive hits build heat stacks, boosting fire rate."
	overclock.icon_color = Color(1.0, 0.8, 0.1)
	overclock.max_level = 5
	overclock.passive_type = PassiveData.PassiveType.BEHAVIOR
	_passives["overclock"] = overclock

static func get_passive(passive_id: String) -> PassiveData:
	_ensure_init()
	return _passives.get(passive_id)

static func get_all_passives() -> Array[PassiveData]:
	_ensure_init()
	var result: Array[PassiveData] = []
	for p in _passives.values():
		result.append(p)
	return result
