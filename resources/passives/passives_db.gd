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

static func get_passive(passive_id: String) -> PassiveData:
	_ensure_init()
	return _passives.get(passive_id)

static func get_all_passives() -> Array[PassiveData]:
	_ensure_init()
	var result: Array[PassiveData] = []
	for p in _passives.values():
		result.append(p)
	return result
