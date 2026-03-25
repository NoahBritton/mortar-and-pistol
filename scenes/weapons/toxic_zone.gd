extends Node2D

var _radius: float = 70.0
var _damage: int = 5
var _tick_interval: float = 0.5
var _duration: float = 3.0
var _color: Color = Color(0.4, 1.0, 0.4)

var _elapsed: float = 0.0
var _tick_accum: float = 0.0

var _toxic_bubbles: GPUParticles2D

func _ready() -> void:
	_toxic_bubbles = _create_toxic_bubbles()
	add_child(_toxic_bubbles)

func reset(pos: Vector2, radius: float, damage: int, tick_interval: float, duration: float, color: Color) -> void:
	global_position = pos
	_radius = radius
	_damage = damage
	_tick_interval = tick_interval
	_duration = duration
	_color = color
	_elapsed = 0.0
	_tick_accum = 0.0
	visible = true

	# Update bubble emission radius and color
	var mat = _toxic_bubbles.process_material as ParticleProcessMaterial
	mat.emission_sphere_radius = _radius * 0.8
	var grad = (mat.color_ramp as GradientTexture1D).gradient
	grad.set_color(0, Color(color.r, color.g, color.b, 0.6))
	grad.set_color(1, Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.0))
	_toxic_bubbles.restart()
	_toxic_bubbles.emitting = true

	queue_redraw()
	_deal_tick_damage()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		_release()
		return
	_tick_accum += delta
	while _tick_accum >= _tick_interval:
		_tick_accum -= _tick_interval
		_deal_tick_damage()
	queue_redraw()

func _deal_tick_damage() -> void:
	var radius_sq = _radius * _radius
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if global_position.distance_squared_to(enemy.global_position) <= radius_sq:
			enemy.take_damage(_damage)

func _draw() -> void:
	var progress = _elapsed / _duration
	var tick_progress = _tick_accum / _tick_interval
	var pulse = 0.3 + 0.2 * sin(tick_progress * TAU)
	var fade = lerp(1.0, 0.3, progress)
	var alpha = pulse * fade

	# ── 0. MAIN FILL ──
	var draw_color = Color(_color.r, _color.g, _color.b, alpha)
	draw_circle(Vector2.ZERO, _radius, draw_color)

	# ── 0b. INNER CONCENTRIC PULSE ──
	var inner_pulse = 0.25 + 0.15 * sin((tick_progress + 0.5) * TAU)
	var inner_alpha = inner_pulse * fade
	draw_circle(Vector2.ZERO, _radius * 0.55,
		Color(_color.r, _color.g, _color.b, inner_alpha * 0.8))

	# ── 1. OUTER RING ──
	var ring_color = Color(_color.r, _color.g, _color.b, min(alpha * 1.5, 1.0))
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 48, ring_color, 2.0)

	# ── 2. TOXIC BUBBLE RECTS ──
	var bubble_count = 8
	for i in bubble_count:
		var angle_base = TAU * float(i) / bubble_count
		var drift = sin(_elapsed * 1.5 + float(i) * 0.7) * 0.2
		var a = angle_base + drift
		var r = _radius * (0.3 + 0.4 * abs(sin(_elapsed * 0.8 + float(i) * 1.3)))
		var bpos = Vector2(cos(a), sin(a)) * r
		var bsize = 3.0 + sin(_elapsed * 2.0 + float(i)) * 1.0
		var balpha = alpha * 0.5 * (0.5 + 0.5 * sin(_elapsed * 1.2 + float(i) * 0.9))
		draw_rect(Rect2(bpos.x - bsize / 2, bpos.y - bsize / 2, bsize, bsize),
			Color(_color.r * 0.7, _color.g, _color.b * 0.7, balpha))

	# ── 3. INNER RING ──
	var inner_ring_alpha = min(inner_alpha * 1.3, 1.0)
	draw_arc(Vector2.ZERO, _radius * 0.55, 0.0, TAU, 32,
		Color(_color.r, _color.g, _color.b, inner_ring_alpha), 1.5)

func _release() -> void:
	_toxic_bubbles.emitting = false
	PoolManager.release(self)

func _create_toxic_bubbles() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 10
	p.lifetime = 0.8
	p.one_shot = false
	p.explosiveness = 0.0
	p.emitting = false
	p.texture = null
	p.local_coords = true
	p.z_index = 1
	p.visibility_rect = Rect2(-150, -150, 300, 300)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 50.0
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 8.0
	mat.initial_velocity_max = 18.0
	mat.damping_min = 1.0
	mat.damping_max = 2.0
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	grad.colors = PackedColorArray([
		Color(0.4, 1.0, 0.4, 0.6),
		Color(0.2, 0.7, 0.2, 0.3),
		Color(0.1, 0.5, 0.1, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p
