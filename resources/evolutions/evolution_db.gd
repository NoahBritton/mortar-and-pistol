class_name EvolutionDB

static var _rules: Array[EvolutionData] = []
static var _initialized: bool = false

static func _ensure_init() -> void:
	if _initialized:
		return
	_initialized = true

	# Bayonet Rush + Gunpowder → Reaper's Bayonet
	var evo1 = EvolutionData.new()
	evo1.base_weapon_id = "bayonet_rush"
	evo1.required_passive_id = "gunpowder"
	evo1.evolved_weapon_id = "reapers_bayonet"
	_rules.append(evo1)

	# Mortar Burst + Clockwork → Carpet Bomber
	var evo2 = EvolutionData.new()
	evo2.base_weapon_id = "mortar_burst"
	evo2.required_passive_id = "clockwork"
	evo2.evolved_weapon_id = "carpet_bomber"
	_rules.append(evo2)

	# Arc Discharge + Birdshot → Storm Conduit
	var evo3 = EvolutionData.new()
	evo3.base_weapon_id = "arc_discharge"
	evo3.required_passive_id = "birdshot"
	evo3.evolved_weapon_id = "storm_conduit"
	_rules.append(evo3)

	# Ember Shells + Quicksilver → Inferno Ring
	var evo4 = EvolutionData.new()
	evo4.base_weapon_id = "ember_shells"
	evo4.required_passive_id = "quicksilver"
	evo4.evolved_weapon_id = "inferno_ring"
	_rules.append(evo4)

	# Blight Flask + Focusing Lens → Plague Barrage
	var evo5 = EvolutionData.new()
	evo5.base_weapon_id = "blight_flask"
	evo5.required_passive_id = "focusing_lens"
	evo5.evolved_weapon_id = "plague_barrage"
	_rules.append(evo5)

	# Seeker Rounds + Extra Powder → Bullet Storm
	var evo6 = EvolutionData.new()
	evo6.base_weapon_id = "seeker_rounds"
	evo6.required_passive_id = "extra_powder"
	evo6.evolved_weapon_id = "bullet_storm"
	_rules.append(evo6)

static func get_all_rules() -> Array[EvolutionData]:
	_ensure_init()
	return _rules

static func get_rule_for_weapon(weapon_id: String) -> EvolutionData:
	_ensure_init()
	for rule in _rules:
		if rule.base_weapon_id == weapon_id:
			return rule
	return null
