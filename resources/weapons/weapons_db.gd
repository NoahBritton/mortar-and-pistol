class_name WeaponsDB

static var _weapons: Dictionary = {}
static var _initialized: bool = false

static func _ensure_init() -> void:
	if _initialized:
		return
	_initialized = true

	# ── Base Pool Weapons (archived — kept in code but not in level-up pool) ──

	var bayonet_rush = WeaponData.new()
	bayonet_rush.weapon_id = "bayonet_rush"
	bayonet_rush.weapon_name = "Bayonet Rush"
	bayonet_rush.description = "Sweeps a blade through nearby enemies."
	bayonet_rush.icon_color = Color(0.75, 0.75, 0.75)
	bayonet_rush.weapon_type = WeaponData.WeaponType.MELEE
	bayonet_rush.max_level = 5
	bayonet_rush.is_archived = true
	bayonet_rush.base_damage = 14
	bayonet_rush.damage_per_level = 4
	bayonet_rush.base_fire_rate = 1.2
	bayonet_rush.fire_rate_per_level = 0.2
	bayonet_rush.spread_angle = 120.0
	bayonet_rush.effect_radius = 90.0
	bayonet_rush.attack_range = 300.0
	bayonet_rush.used_stats = ["area_mult"]
	_weapons["bayonet_rush"] = bayonet_rush

	var mortar_burst = WeaponData.new()
	mortar_burst.weapon_id = "mortar_burst"
	mortar_burst.weapon_name = "Mortar Burst"
	mortar_burst.description = "Pulses explosive damage around you."
	mortar_burst.icon_color = Color(1.0, 0.85, 0.3)
	mortar_burst.weapon_type = WeaponData.WeaponType.AOE
	mortar_burst.max_level = 5
	mortar_burst.is_archived = true
	mortar_burst.base_damage = 8
	mortar_burst.damage_per_level = 3
	mortar_burst.base_fire_rate = 0.5
	mortar_burst.fire_rate_per_level = 0.05
	mortar_burst.effect_radius = 80.0
	mortar_burst.used_stats = ["area_mult"]
	_weapons["mortar_burst"] = mortar_burst

	var arc_discharge = WeaponData.new()
	arc_discharge.weapon_id = "arc_discharge"
	arc_discharge.weapon_name = "Arc Discharge"
	arc_discharge.description = "Zaps enemies and arcs between them."
	arc_discharge.icon_color = Color(0.4, 0.6, 1.0)
	arc_discharge.weapon_type = WeaponData.WeaponType.CHAIN
	arc_discharge.max_level = 5
	arc_discharge.is_archived = true
	arc_discharge.base_damage = 12
	arc_discharge.damage_per_level = 4
	arc_discharge.base_fire_rate = 0.8
	arc_discharge.fire_rate_per_level = 0.1
	arc_discharge.base_pierce = 2
	arc_discharge.pierce_per_level = 1
	arc_discharge.attack_range = 350.0
	arc_discharge.effect_radius = 120.0
	arc_discharge.used_stats = ["pierce_bonus"]
	_weapons["arc_discharge"] = arc_discharge

	var ember_shells = WeaponData.new()
	ember_shells.weapon_id = "ember_shells"
	ember_shells.weapon_name = "Ember Shells"
	ember_shells.description = "Fireballs orbit around you."
	ember_shells.icon_color = Color(1.0, 0.4, 0.1)
	ember_shells.weapon_type = WeaponData.WeaponType.ORBIT
	ember_shells.max_level = 5
	ember_shells.is_archived = true
	ember_shells.base_damage = 7
	ember_shells.damage_per_level = 2
	ember_shells.base_fire_rate = 1.0
	ember_shells.fire_rate_per_level = 0.0
	ember_shells.base_projectile_count = 2
	ember_shells.projectile_count_per_level = 1
	ember_shells.projectile_speed = 180.0
	ember_shells.effect_radius = 60.0
	ember_shells.used_stats = ["proj_speed_mult", "area_mult", "proj_count_bonus"]
	_weapons["ember_shells"] = ember_shells

	var blight_flask = WeaponData.new()
	blight_flask.weapon_id = "blight_flask"
	blight_flask.weapon_name = "Blight Flask"
	blight_flask.description = "Throws a poison zone that damages over time."
	blight_flask.icon_color = Color(0.4, 1.0, 0.4)
	blight_flask.weapon_type = WeaponData.WeaponType.DOT
	blight_flask.max_level = 5
	blight_flask.is_archived = true
	blight_flask.base_damage = 5
	blight_flask.damage_per_level = 2
	blight_flask.base_fire_rate = 0.4
	blight_flask.fire_rate_per_level = 0.05
	blight_flask.effect_radius = 70.0
	blight_flask.tick_interval = 0.5
	blight_flask.effect_duration = 3.0
	blight_flask.attack_range = 250.0
	blight_flask.used_stats = ["area_mult"]
	_weapons["blight_flask"] = blight_flask

	var seeker_rounds = WeaponData.new()
	seeker_rounds.weapon_id = "seeker_rounds"
	seeker_rounds.weapon_name = "Seeker Rounds"
	seeker_rounds.description = "Launches homing missiles at random enemies."
	seeker_rounds.icon_color = Color(0.8, 0.4, 1.0)
	seeker_rounds.weapon_type = WeaponData.WeaponType.BARRAGE
	seeker_rounds.max_level = 5
	seeker_rounds.is_archived = true
	seeker_rounds.base_damage = 15
	seeker_rounds.damage_per_level = 3
	seeker_rounds.base_fire_rate = 0.4
	seeker_rounds.fire_rate_per_level = 0.05
	seeker_rounds.base_projectile_count = 2
	seeker_rounds.projectile_count_per_level = 1
	seeker_rounds.projectile_speed = 200.0
	seeker_rounds.effect_radius = 30.0
	seeker_rounds.attack_range = 500.0
	seeker_rounds.used_stats = ["proj_speed_mult", "area_mult", "proj_count_bonus"]
	_weapons["seeker_rounds"] = seeker_rounds

	# ── Evolved Pool Weapons (archived) ──

	var reapers_bayonet = WeaponData.new()
	reapers_bayonet.weapon_id = "reapers_bayonet"
	reapers_bayonet.weapon_name = "Reaper's Bayonet"
	reapers_bayonet.description = "A 360-degree devastating sweep."
	reapers_bayonet.icon_color = Color(0.9, 0.3, 1.0)
	reapers_bayonet.weapon_type = WeaponData.WeaponType.MELEE
	reapers_bayonet.max_level = 1
	reapers_bayonet.is_evolution = true
	reapers_bayonet.is_archived = true
	reapers_bayonet.base_damage = 40
	reapers_bayonet.base_fire_rate = 2.5
	reapers_bayonet.spread_angle = 360.0
	reapers_bayonet.effect_radius = 120.0
	reapers_bayonet.attack_range = 300.0
	reapers_bayonet.used_stats = ["area_mult"]
	_weapons["reapers_bayonet"] = reapers_bayonet

	var carpet_bomber = WeaponData.new()
	carpet_bomber.weapon_id = "carpet_bomber"
	carpet_bomber.weapon_name = "Carpet Bomber"
	carpet_bomber.description = "Massive explosion around you."
	carpet_bomber.icon_color = Color(1.0, 1.0, 0.6)
	carpet_bomber.weapon_type = WeaponData.WeaponType.AOE
	carpet_bomber.max_level = 1
	carpet_bomber.is_evolution = true
	carpet_bomber.is_archived = true
	carpet_bomber.base_damage = 30
	carpet_bomber.base_fire_rate = 1.5
	carpet_bomber.effect_radius = 150.0
	carpet_bomber.used_stats = ["area_mult"]
	_weapons["carpet_bomber"] = carpet_bomber

	var storm_conduit = WeaponData.new()
	storm_conduit.weapon_id = "storm_conduit"
	storm_conduit.weapon_name = "Storm Conduit"
	storm_conduit.description = "Lightning arcs through 8 enemies."
	storm_conduit.icon_color = Color(0.8, 0.9, 1.0)
	storm_conduit.weapon_type = WeaponData.WeaponType.CHAIN
	storm_conduit.max_level = 1
	storm_conduit.is_evolution = true
	storm_conduit.is_archived = true
	storm_conduit.base_damage = 25
	storm_conduit.base_fire_rate = 1.2
	storm_conduit.base_pierce = 8
	storm_conduit.attack_range = 500.0
	storm_conduit.effect_radius = 180.0
	storm_conduit.used_stats = ["pierce_bonus"]
	_weapons["storm_conduit"] = storm_conduit

	var inferno_ring = WeaponData.new()
	inferno_ring.weapon_id = "inferno_ring"
	inferno_ring.weapon_name = "Inferno Ring"
	inferno_ring.description = "6 fireballs in a blazing ring."
	inferno_ring.icon_color = Color(1.0, 0.2, 0.0)
	inferno_ring.weapon_type = WeaponData.WeaponType.ORBIT
	inferno_ring.max_level = 1
	inferno_ring.is_evolution = true
	inferno_ring.is_archived = true
	inferno_ring.base_damage = 18
	inferno_ring.base_projectile_count = 6
	inferno_ring.projectile_speed = 270.0
	inferno_ring.effect_radius = 90.0
	inferno_ring.used_stats = ["proj_speed_mult", "area_mult", "proj_count_bonus"]
	_weapons["inferno_ring"] = inferno_ring

	var plague_barrage = WeaponData.new()
	plague_barrage.weapon_id = "plague_barrage"
	plague_barrage.weapon_name = "Plague Barrage"
	plague_barrage.description = "A massive toxic vortex. Ticks fast, lasts long."
	plague_barrage.icon_color = Color(0.0, 0.9, 0.46)
	plague_barrage.weapon_type = WeaponData.WeaponType.DOT
	plague_barrage.max_level = 1
	plague_barrage.is_evolution = true
	plague_barrage.is_archived = true
	plague_barrage.base_damage = 12
	plague_barrage.base_fire_rate = 0.6
	plague_barrage.effect_radius = 120.0
	plague_barrage.tick_interval = 0.3
	plague_barrage.effect_duration = 6.0
	plague_barrage.attack_range = 300.0
	plague_barrage.used_stats = ["area_mult"]
	_weapons["plague_barrage"] = plague_barrage

	var bullet_storm = WeaponData.new()
	bullet_storm.weapon_id = "bullet_storm"
	bullet_storm.weapon_name = "Bullet Storm"
	bullet_storm.description = "Rains 6 massive projectiles across the screen."
	bullet_storm.icon_color = Color(1.0, 0.25, 0.5)
	bullet_storm.weapon_type = WeaponData.WeaponType.BARRAGE
	bullet_storm.max_level = 1
	bullet_storm.is_evolution = true
	bullet_storm.is_archived = true
	bullet_storm.base_damage = 35
	bullet_storm.base_fire_rate = 0.6
	bullet_storm.base_projectile_count = 6
	bullet_storm.projectile_speed = 250.0
	bullet_storm.effect_radius = 60.0
	bullet_storm.attack_range = 600.0
	bullet_storm.used_stats = ["proj_speed_mult", "area_mult", "proj_count_bonus"]
	_weapons["bullet_storm"] = bullet_storm

	# ── Character Weapons (exclusive starters, not in level-up pool) ──

	var bolt_rifle = WeaponData.new()
	bolt_rifle.weapon_id = "bolt_rifle"
	bolt_rifle.weapon_name = "Bolt Rifle"
	bolt_rifle.description = "Fires a pulsed energy beam that pierces through enemies in a line."
	bolt_rifle.icon_color = Color(0.4, 0.6, 1.0)
	bolt_rifle.weapon_type = WeaponData.WeaponType.BEAM
	bolt_rifle.max_level = 5
	bolt_rifle.is_character_weapon = true
	bolt_rifle.base_damage = 20
	bolt_rifle.damage_per_level = 5
	bolt_rifle.base_fire_rate = 0.8
	bolt_rifle.fire_rate_per_level = 0.1
	bolt_rifle.base_pierce = 3
	bolt_rifle.pierce_per_level = 1
	bolt_rifle.attack_range = 500.0
	bolt_rifle.projectile_speed = 500.0
	bolt_rifle.used_stats = ["pierce_bonus", "area_mult"]
	_weapons["bolt_rifle"] = bolt_rifle

	var scatter_flask = WeaponData.new()
	scatter_flask.weapon_id = "scatter_flask"
	scatter_flask.weapon_name = "Scatter Flask"
	scatter_flask.description = "A flask shatters on impact, spraying shrapnel."
	scatter_flask.icon_color = Color(0.4, 1.0, 0.4)
	scatter_flask.weapon_type = WeaponData.WeaponType.BURST
	scatter_flask.max_level = 5
	scatter_flask.is_character_weapon = true
	scatter_flask.base_damage = 14
	scatter_flask.damage_per_level = 3
	scatter_flask.base_fire_rate = 0.7
	scatter_flask.fire_rate_per_level = 0.075
	scatter_flask.base_projectile_count = 4
	scatter_flask.projectile_count_per_level = 1
	scatter_flask.attack_range = 250.0
	scatter_flask.projectile_speed = 250.0
	scatter_flask.effect_radius = 40.0
	scatter_flask.used_stats = ["proj_speed_mult", "proj_count_bonus"]
	_weapons["scatter_flask"] = scatter_flask

	var powder_keg = WeaponData.new()
	powder_keg.weapon_id = "powder_keg"
	powder_keg.weapon_name = "Powder Keg"
	powder_keg.description = "Drops an explosive barrel that detonates after a short fuse."
	powder_keg.icon_color = Color(1.0, 0.4, 0.1)
	powder_keg.weapon_type = WeaponData.WeaponType.MINE
	powder_keg.max_level = 5
	powder_keg.is_character_weapon = true
	powder_keg.base_damage = 25
	powder_keg.damage_per_level = 8
	powder_keg.base_fire_rate = 0.5
	powder_keg.fire_rate_per_level = 0.05
	powder_keg.effect_radius = 90.0
	powder_keg.effect_duration = 0.8
	powder_keg.used_stats = ["area_mult", "proj_count_bonus", "pierce_bonus", "proj_speed_mult"]
	_weapons["powder_keg"] = powder_keg

	var twin_barrels = WeaponData.new()
	twin_barrels.weapon_id = "twin_barrels"
	twin_barrels.weapon_name = "Twin Barrels"
	twin_barrels.description = "Fires two rapid shots in quick succession."
	twin_barrels.icon_color = Color(0.7, 0.9, 1.0)
	twin_barrels.weapon_type = WeaponData.WeaponType.BURST_FIRE
	twin_barrels.max_level = 5
	twin_barrels.is_character_weapon = true
	twin_barrels.base_damage = 10
	twin_barrels.damage_per_level = 3
	twin_barrels.base_fire_rate = 1.2
	twin_barrels.fire_rate_per_level = 0.15
	twin_barrels.attack_range = 300.0
	twin_barrels.projectile_speed = 450.0
	twin_barrels.burst_delay = 0.1
	twin_barrels.used_stats = ["proj_speed_mult", "pierce_bonus"]
	_weapons["twin_barrels"] = twin_barrels

static func get_weapon(weapon_id: String) -> WeaponData:
	_ensure_init()
	return _weapons.get(weapon_id)

static func get_all_base_weapons() -> Array[WeaponData]:
	_ensure_init()
	var result: Array[WeaponData] = []
	for w in _weapons.values():
		if not w.is_evolution and not w.is_archived and not w.is_character_weapon:
			result.append(w)
	return result
