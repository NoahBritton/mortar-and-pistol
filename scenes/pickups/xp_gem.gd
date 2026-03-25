extends Node2D

var xp_value: int = 5
var _attracted: bool = false
var _attraction_target: Node2D = null
var _attraction_speed: float = 400.0
var _idle_bob_time: float = 0.0

# Vortex state
var _vortex_angle: float = 0.0
var _vortex_radius: float = 0.0
var _vortex_speed_mult: float = 1.0
var _vortex_radius_offset: float = 0.0

# Trail state
var _trail_positions: Array[Vector2] = []
var _trail_timer: float = 0.0
const TRAIL_INTERVAL: float = 0.02
const TRAIL_LENGTH: int = 6

# Size tiers
var _gem_size: float = 4.0
var _core_color: Color = Color(0.55, 1.0, 0.3)
var _edge_color: Color = Color(0.15, 0.5, 0.1)

@onready var pickup_area: Area2D = $PickupArea

func _ready() -> void:
	pickup_area.add_to_group("pickups")

func reset(pos: Vector2, value: int = 5) -> void:
	global_position = pos
	xp_value = value
	_attracted = false
	_attraction_target = null
	_idle_bob_time = 0.0
	_vortex_angle = 0.0
	_vortex_radius = 0.0
	_trail_positions.clear()
	_trail_timer = 0.0
	pickup_area.add_to_group("pickups")

	# Size scales with value (like Minecraft XP orbs)
	if value >= 50:
		_gem_size = 8.0
		_core_color = Color(0.7, 1.0, 0.2)
		_edge_color = Color(0.2, 0.6, 0.05)
	elif value >= 20:
		_gem_size = 6.5
		_core_color = Color(0.55, 1.0, 0.3)
		_edge_color = Color(0.15, 0.55, 0.08)
	elif value >= 10:
		_gem_size = 5.0
		_core_color = Color(0.4, 0.9, 0.3)
		_edge_color = Color(0.12, 0.45, 0.1)
	else:
		_gem_size = 3.5
		_core_color = Color(0.35, 0.8, 0.3)
		_edge_color = Color(0.1, 0.4, 0.12)

	visible = true
	queue_redraw()

func start_attraction(target: Node2D) -> void:
	_attracted = true
	_attraction_target = target
	# Initialize vortex from current offset
	var offset = global_position - target.global_position
	_vortex_radius = offset.length()
	_vortex_angle = offset.angle()
	# Stagger so gems don't orbit in a rigid sheet
	_vortex_speed_mult = randf_range(0.7, 1.4)
	_vortex_radius_offset = randf_range(-15.0, 15.0)

func _process(delta: float) -> void:
	if _attracted and is_instance_valid(_attraction_target):
		var target_pos = _attraction_target.global_position
		var dist = global_position.distance_to(target_pos)

		if dist < 16.0:
			_collect()
			return

		# Vortex spiral: shrink radius while rotating (staggered per gem)
		_vortex_radius = move_toward(_vortex_radius, 0.0, _attraction_speed * delta)
		_vortex_angle += delta * (8.0 + (1.0 / maxf(dist / 60.0, 0.3))) * _vortex_speed_mult
		var r = maxf(_vortex_radius + _vortex_radius_offset, 0.0)
		global_position = target_pos + Vector2(cos(_vortex_angle), sin(_vortex_angle)) * r

		# Trail
		_trail_timer += delta
		if _trail_timer >= TRAIL_INTERVAL:
			_trail_timer = 0.0
			_trail_positions.append(global_position)
			if _trail_positions.size() > TRAIL_LENGTH:
				_trail_positions.remove_at(0)
	else:
		_idle_bob_time += delta
		_trail_positions.clear()

	queue_redraw()

func _draw() -> void:
	var s = _gem_size
	var bob_y = 0.0
	if not _attracted:
		bob_y = sin(_idle_bob_time * 4.0) * 2.0

	# Trail (when attracted)
	if _trail_positions.size() > 1:
		for i in range(_trail_positions.size() - 1):
			var t = float(i) / _trail_positions.size()
			var alpha = t * 0.3
			var trail_size = s * t * 0.6
			var local_pos = _trail_positions[i] - global_position
			draw_rect(Rect2(local_pos.x - trail_size * 0.5, local_pos.y - trail_size * 0.5,
				trail_size, trail_size),
				Color(_core_color.r, _core_color.g, _core_color.b, alpha))

	# Diamond shape drawn as rotated square layers
	var center = Vector2(0, bob_y)

	# Outer edge (dark green)
	var outer_pts = PackedVector2Array([
		center + Vector2(0, -s), # top
		center + Vector2(s, 0), # right
		center + Vector2(0, s), # bottom
		center + Vector2(-s, 0), # left
	])
	draw_colored_polygon(outer_pts, _edge_color)

	# Inner core (bright lime) — slightly smaller
	var inner = s * 0.6
	var inner_pts = PackedVector2Array([
		center + Vector2(0, -inner),
		center + Vector2(inner, 0),
		center + Vector2(0, inner),
		center + Vector2(-inner, 0),
	])
	draw_colored_polygon(inner_pts, _core_color)

	# Highlight (white specular dot) — top-left of center
	var hl = s * 0.25
	var hl_offset = center + Vector2(-s * 0.15, -s * 0.3)
	draw_rect(Rect2(hl_offset.x - hl * 0.5, hl_offset.y - hl * 0.5, hl, hl),
		Color(1.0, 1.0, 1.0, 0.6))

	# Subtle pulse glow
	var pulse = 0.5 + 0.5 * sin(_idle_bob_time * 5.0 if not _attracted else _vortex_angle * 2.0)
	var glow_s = s * 1.4
	var glow_pts = PackedVector2Array([
		center + Vector2(0, -glow_s),
		center + Vector2(glow_s, 0),
		center + Vector2(0, glow_s),
		center + Vector2(-glow_s, 0),
	])
	draw_colored_polygon(glow_pts, Color(_core_color.r, _core_color.g, _core_color.b, 0.08 + pulse * 0.06))

func _collect() -> void:
	GameManager.add_xp(xp_value)
	AudioManager.play(AudioManager.sfx_pickup)
	if pickup_area.is_in_group("pickups"):
		pickup_area.remove_from_group("pickups")
	_trail_positions.clear()
	PoolManager.release(self )
