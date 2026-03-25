extends Node2D

var _damage: int = 25
var _radius: float = 90.0
var _fuse_time: float = 0.8
var _elapsed: float = 0.0
var _detonated: bool = false
var _color: Color = Color(1.0, 0.4, 0.1)
var _shrapnel_count: int = 0
var _weapon_data: WeaponData = null

# Lob arc state
var _throwing: bool = false
var _throw_start: Vector2 = Vector2.ZERO
var _throw_target: Vector2 = Vector2.ZERO
var _throw_distance: float = 0.0
var _throw_traveled: float = 0.0
var _throw_speed: float = 350.0
var _arc_height: float = 50.0
var _arc_y: float = 0.0

@onready var color_rect: ColorRect = $ColorRect
var _color_rect_rest_y: float = 0.0

func _ready() -> void:
	_color_rect_rest_y = color_rect.position.y

func reset(pos: Vector2, damage: int, radius: float, fuse_time: float,
		color: Color, shrapnel_count: int = 0, weapon_data: WeaponData = null,
		throw_target: Vector2 = Vector2.ZERO) -> void:
	global_position = pos
	_damage = damage
	_radius = radius
	_fuse_time = fuse_time
	_color = color
	_shrapnel_count = shrapnel_count
	_weapon_data = weapon_data
	_elapsed = 0.0
	_detonated = false
	color_rect.color = color
	color_rect.visible = true
	color_rect.rotation = 0.0
	_arc_y = 0.0
	visible = true

	# Set up throw arc if target differs from position
	if throw_target != Vector2.ZERO and throw_target.distance_to(pos) > 5.0:
		_throwing = true
		_throw_start = pos
		_throw_target = throw_target
		_throw_distance = pos.distance_to(throw_target)
		_throw_traveled = 0.0
		_arc_height = clampf(_throw_distance * 0.3, 20.0, 60.0)
	else:
		_throwing = false

	queue_redraw()

func _process(delta: float) -> void:
	if _throwing:
		# Lob arc phase — move along ground toward target with sine arc on visual
		var to_target = _throw_target - global_position
		var dist = to_target.length()
		if dist < 5.0:
			# Landed
			global_position = _throw_target
			_throwing = false
			_arc_y = 0.0
			color_rect.position.y = _color_rect_rest_y
			color_rect.rotation = 0.0
			return
		global_position += (to_target / dist) * _throw_speed * delta
		_throw_traveled += _throw_speed * delta
		var progress = clampf(_throw_traveled / maxf(_throw_distance, 1.0), 0.0, 1.0)
		_arc_y = -_arc_height * sin(progress * PI)
		color_rect.position.y = _color_rect_rest_y + _arc_y
		color_rect.rotation += delta * 6.0
		queue_redraw()
		return

	_elapsed += delta
	if not _detonated and _elapsed >= _fuse_time:
		_detonate()
	elif _detonated and _elapsed >= _fuse_time + 0.4:
		PoolManager.release(self)
		return
	queue_redraw()

func _draw() -> void:
	# Ground shadow during throw arc
	if _throwing:
		var progress = clampf(_throw_traveled / maxf(_throw_distance, 1.0), 0.0, 1.0)
		var shadow_scale = 1.0 + 0.3 * sin(progress * PI)
		var sw = 5.0 * shadow_scale
		var sh = 3.0 * shadow_scale
		draw_rect(Rect2(-sw, -sh, sw * 2.0, sh * 2.0), Color(0.0, 0.0, 0.0, 0.25))
		return

	if _detonated:
		var det_progress = clampf((_elapsed - _fuse_time) / 0.4, 0.0, 1.0)
		var alpha = lerpf(0.8, 0.0, det_progress)
		var r = _radius * lerpf(0.3, 1.0, det_progress)
		draw_circle(Vector2.ZERO, r, Color(_color.r, _color.g, _color.b, alpha * 0.3))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(_color.r, _color.g, _color.b, alpha), 3.0)
	else:
		var fuse_progress = clampf(_elapsed / _fuse_time, 0.0, 1.0)

		# Translucent danger zone showing blast radius
		var danger_alpha = lerpf(0.04, 0.12, fuse_progress)
		draw_circle(Vector2.ZERO, _radius, Color(_color.r, _color.g, _color.b, danger_alpha))
		# Dashed danger circle edge
		var dash_count = 16
		for i in dash_count:
			if i % 2 == 0:
				var a0 = TAU * float(i) / dash_count
				var a1 = TAU * float(i + 1) / dash_count
				draw_arc(Vector2.ZERO, _radius, a0, a1, 4,
					Color(_color.r, _color.g, _color.b, 0.2 + 0.2 * fuse_progress), 1.5)

		# Shrinking countdown ring
		var ring_radius = lerpf(18.0, 6.0, fuse_progress)
		var ring_alpha = 0.5 + 0.3 * sin(_elapsed * 10.0)
		var ring_sweep = TAU * (1.0 - fuse_progress)
		draw_arc(Vector2.ZERO, ring_radius, -PI / 2.0, -PI / 2.0 + ring_sweep, 24,
			Color(1.0, 0.8, 0.2, ring_alpha), 2.0)

		# Spark blocks along countdown arc
		for i in 4:
			var t = float(i + 1) / 5.0  # evenly spread along remaining arc
			var a = -PI / 2.0 + ring_sweep * t
			var sp = Vector2(cos(a), sin(a)) * ring_radius
			draw_rect(Rect2(sp.x - 1, sp.y - 1, 2, 2),
				Color(1.0, 1.0, 0.6, ring_alpha * 0.7))

func _detonate() -> void:
	_detonated = true
	color_rect.visible = false
	AudioManager.play(AudioManager.sfx_hit)
	var radius_sq = _radius * _radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_squared_to(enemy.global_position) <= radius_sq:
			enemy.take_damage(_damage)
			SignalBus.damage_dealt.emit(enemy.global_position, _damage)
	var effect = PoolManager.acquire("aoe_effect")
	if effect:
		effect.reset(global_position, _radius, _color)

	# Screen shake
	SignalBus.screen_shake_requested.emit(4.0, 0.15)

	# Birdshot synergy: post-explosion shrapnel
	if _shrapnel_count > 0 and _weapon_data:
		var frag_count = _shrapnel_count * 2
		for i in frag_count:
			var angle = TAU * float(i) / frag_count
			var dir = Vector2(cos(angle), sin(angle))
			var proj = PoolManager.acquire("projectile")
			if proj:
				proj.reset(global_position + dir * 10.0, dir, _weapon_data, 1)
				proj.speed = 200.0
				proj.damage = _damage / 2
				proj._hits_remaining = 1
