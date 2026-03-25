extends Node2D

var _attracted: bool = false
var _attraction_target: Node2D = null
var _attraction_speed: float = 350.0
var _idle_bob_time: float = 0.0
var _pulse_time: float = 0.0

@onready var pickup_area: Area2D = $PickupArea

func reset(pos: Vector2) -> void:
	global_position = pos
	_attracted = false
	_attraction_target = null
	_idle_bob_time = 0.0
	_pulse_time = 0.0
	pickup_area.add_to_group("pickups")
	visible = true
	queue_redraw()

func start_attraction(target: Node2D) -> void:
	_attracted = true
	_attraction_target = target

func _process(delta: float) -> void:
	_pulse_time += delta
	if _attracted and is_instance_valid(_attraction_target):
		var dir = (_attraction_target.global_position - global_position).normalized()
		global_position += dir * _attraction_speed * delta
		if global_position.distance_to(_attraction_target.global_position) < 16.0:
			_collect()
			return
	else:
		_idle_bob_time += delta
	queue_redraw()

func _collect() -> void:
	AudioManager.play(AudioManager.sfx_pickup)
	# Vacuum: attract ALL pickups on the map toward the player
	var target = _attraction_target
	for node in get_tree().get_nodes_in_group("pickups"):
		var pickup_parent = node.get_parent()
		if pickup_parent != self and pickup_parent.has_method("start_attraction"):
			pickup_parent.start_attraction(target)
	if pickup_area.is_in_group("pickups"):
		pickup_area.remove_from_group("pickups")
	PoolManager.release(self)

func _draw() -> void:
	var pulse = 0.5 + 0.5 * sin(_pulse_time * 4.0)
	var bob_y = 0.0
	if not _attracted:
		bob_y = sin(_idle_bob_time * 3.0) * 3.0
	var center = Vector2(0, bob_y)

	# Outer glow circle
	var glow_radius = 10.0 + pulse * 3.0
	draw_circle(center, glow_radius, Color(0.5, 0.2, 0.8, 0.08 + pulse * 0.06))

	# Main circle (purple, solid)
	draw_circle(center, 6.0, Color(0.4, 0.15, 0.65))

	# Inner bright core
	draw_circle(center, 3.5, Color(0.6, 0.3, 0.9))

	# Specular highlight
	draw_circle(center + Vector2(-1.5, -2.0), 1.5, Color(0.85, 0.6, 1.0, 0.7))

	# Orbiting magnetic ring
	var ring_radius = 12.0 + pulse * 4.0
	draw_arc(center, ring_radius, 0.0, TAU, 16,
		Color(0.5, 0.2, 0.8, 0.3 + pulse * 0.2), 1.5)

	# Orbiting pixel blocks
	for i in 3:
		var a = _pulse_time * 2.0 + TAU * float(i) / 3.0
		var op = center + Vector2(cos(a), sin(a)) * (ring_radius + 2.0)
		draw_rect(Rect2(op.x - 1, op.y - 1, 2, 2),
			Color(0.7, 0.4, 1.0, 0.5 + pulse * 0.3))
