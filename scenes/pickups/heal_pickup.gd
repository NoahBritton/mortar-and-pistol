extends Node2D

var heal_amount: int = 20
var _attracted: bool = false
var _attraction_target: Node2D = null
var _attraction_speed: float = 350.0
var _idle_bob_time: float = 0.0

@onready var color_rect: ColorRect = $ColorRect
@onready var pickup_area: Area2D = $PickupArea

func reset(pos: Vector2, amount: int = 20) -> void:
	global_position = pos
	heal_amount = amount
	_attracted = false
	_attraction_target = null
	_idle_bob_time = 0.0
	pickup_area.add_to_group("pickups")
	color_rect.color = Color(1.0, 0.3, 0.3)

func start_attraction(target: Node2D) -> void:
	_attracted = true
	_attraction_target = target

func _process(delta: float) -> void:
	if _attracted and is_instance_valid(_attraction_target):
		var dir = (_attraction_target.global_position - global_position).normalized()
		global_position += dir * _attraction_speed * delta
		if global_position.distance_to(_attraction_target.global_position) < 16.0:
			_collect()
	else:
		_idle_bob_time += delta
		color_rect.position.y = -6 + sin(_idle_bob_time * 3.0) * 3.0

func _collect() -> void:
	GameManager.heal(heal_amount)
	AudioManager.play(AudioManager.sfx_pickup)
	if pickup_area.is_in_group("pickups"):
		pickup_area.remove_from_group("pickups")
	PoolManager.release(self)
