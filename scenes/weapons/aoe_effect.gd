extends Node2D

var _radius: float = 80.0
var _color: Color = Color.WHITE
var _lifetime: float = 0.0
var _max_lifetime: float = 0.4

var _aura_burst: GPUParticles2D

func _ready() -> void:
	_aura_burst = _create_aura_burst()
	add_child(_aura_burst)

func reset(pos: Vector2, radius: float, color: Color) -> void:
	global_position = pos
	_radius = radius
	_color = color
	_lifetime = 0.0
	visible = true

	# Update burst color and fire
	var mat = _aura_burst.process_material as ParticleProcessMaterial
	var grad = (mat.color_ramp as GradientTexture1D).gradient
	grad.set_color(0, Color(minf(color.r * 1.3, 1.0), minf(color.g * 1.3, 1.0), minf(color.b * 1.3, 1.0), 1.0))
	grad.set_color(1, Color(color.r, color.g, color.b, 0.6))
	_aura_burst.restart()
	_aura_burst.emitting = true

	queue_redraw()

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_release()
		return
	queue_redraw()

func _draw() -> void:
	var progress = _lifetime / _max_lifetime
	var current_radius = _radius * lerp(0.3, 1.0, progress)
	var alpha = lerp(0.8, 0.0, progress)

	# ── 0. FILLED PULSE FLASH ──
	draw_circle(Vector2.ZERO, current_radius,
		Color(_color.r, _color.g, _color.b, alpha * 0.12))

	# ── 1. MAIN RING ARC ──
	var draw_color = Color(_color.r, _color.g, _color.b, alpha)
	var line_width = lerp(4.0, 1.5, progress)
	draw_arc(Vector2.ZERO, current_radius, 0.0, TAU, 48, draw_color, line_width)

	# ── 2. BLOCKY RING SEGMENTS ──
	var block_count = 12
	var block_size = lerp(4.0, 2.0, progress)
	for i in block_count:
		var a = TAU * float(i) / block_count
		var bp = Vector2(cos(a), sin(a)) * current_radius
		var half = block_size / 2.0
		draw_rect(Rect2(bp.x - half, bp.y - half, block_size, block_size),
			Color(_color.r, _color.g, _color.b, alpha * 0.7))

	# ── 3. CARDINAL CROSS ──
	var cross_alpha = alpha * 0.5
	var ext = current_radius * 1.15
	for angle in [0.0, PI / 2.0, PI, 3.0 * PI / 2.0]:
		var dir_vec = Vector2(cos(angle), sin(angle))
		var start_pos = dir_vec * current_radius
		var end_pos = dir_vec * ext
		draw_line(start_pos, end_pos,
			Color(1.0, 1.0, 1.0, cross_alpha), 2.0)

func _release() -> void:
	_aura_burst.emitting = false
	PoolManager.release(self)

func _create_aura_burst() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 12
	p.lifetime = 0.35
	p.one_shot = true
	p.explosiveness = 1.0
	p.emitting = false
	p.texture = null
	p.local_coords = false
	p.z_index = 1
	p.visibility_rect = Rect2(-200, -200, 400, 400)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 8.0
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 80.0
	mat.initial_velocity_max = 140.0
	mat.damping_min = 2.0
	mat.damping_max = 4.0
	mat.scale_min = 3.0
	mat.scale_max = 5.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	grad.colors = PackedColorArray([
		Color(1.0, 1.0, 0.8, 1.0),
		Color(1.0, 0.85, 0.3, 0.6),
		Color(1.0, 0.85, 0.3, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p
