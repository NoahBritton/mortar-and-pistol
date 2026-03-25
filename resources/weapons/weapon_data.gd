class_name WeaponData
extends Resource

enum WeaponType { PROJECTILE, AOE, ORBIT, CHAIN, MELEE, DOT, BARRAGE, PIERCING, BURST, MINE, BURST_FIRE, BEAM }

@export var weapon_id: String = ""
@export var weapon_name: String = ""
@export var description: String = ""
@export var icon_color: Color = Color.WHITE
@export var max_level: int = 5
@export var is_evolution: bool = false
@export var is_archived: bool = false
@export var is_character_weapon: bool = false
@export var weapon_type: WeaponType = WeaponType.PROJECTILE
@export var used_stats: PackedStringArray = []

# Base stats (at level 1)
@export var base_damage: int = 10
@export var base_fire_rate: float = 1.0
@export var base_projectile_count: int = 1
@export var projectile_speed: float = 300.0
@export var base_pierce: int = 1
@export var attack_range: float = 400.0
@export var spread_angle: float = 0.0
@export var effect_radius: float = 0.0
@export var tick_interval: float = 0.5    # DOT: seconds between ticks
@export var effect_duration: float = 0.0  # DOT: zone lifetime in seconds / MINE: fuse delay
@export var burst_delay: float = 0.1      # BURST_FIRE: seconds between shots in a burst

# Per-level scaling
@export var damage_per_level: int = 3
@export var fire_rate_per_level: float = 0.1
@export var projectile_count_per_level: int = 0
@export var pierce_per_level: int = 0

func get_damage(level: int) -> int:
	return base_damage + damage_per_level * (level - 1)

func get_fire_rate(level: int) -> float:
	return base_fire_rate + fire_rate_per_level * (level - 1)

func get_projectile_count(level: int) -> int:
	return base_projectile_count + projectile_count_per_level * (level - 1)

func get_pierce(level: int) -> int:
	return base_pierce + pierce_per_level * (level - 1)
