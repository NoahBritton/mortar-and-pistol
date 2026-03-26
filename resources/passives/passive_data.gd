class_name PassiveData
extends Resource

enum PassiveType { STAT, BEHAVIOR }

const UNIVERSAL_STAT_KEYS: PackedStringArray = [
	"damage_mult", "fire_rate_mult", "move_speed_mult", "pickup_range_mult"
]

@export var passive_id: String = ""
@export var passive_name: String = ""
@export var description: String = ""
@export var icon_color: Color = Color.WHITE
@export var max_level: int = 5
@export var stat_key: String = ""
@export var value_per_level: float = 0.0
@export var is_percentage: bool = true
@export var passive_type: PassiveType = PassiveType.STAT

func is_universal() -> bool:
	if passive_type == PassiveType.BEHAVIOR:
		return true
	return stat_key in UNIVERSAL_STAT_KEYS
