extends Node2D

var _start: Vector2 = Vector2.ZERO
var _end: Vector2 = Vector2.ZERO
var _width: float = 8.0
var _color: Color = Color.WHITE
var _lifetime: float = 0.0
var _max_lifetime: float = 0.2

var _beam_burst: GPUParticles2D

func _ready() -> void:
	_beam_burst = _create_beam_burst()
	add_child(_beam_burst)

func reset(start: Vector2, end: Vector2, width: float, color: Color) -> void:
	global_position = Vector2.ZERO
	_start = start
	_end = end
	_width = width
	_color = color
	_lifetime = 0.0
	visible = true

	_beam_burst.position = end
	var mat = _beam_burst.process_material as ParticleProcessMaterial
	var grad = (mat.color_ramp as GradientTexture1D).gradient
	grad.set_color(0, Color(minf(color.r * 1.3, 1.0), minf(color.g * 1.3, 1.0), minf(color.b * 1.3, 1.0), 1.0))
	grad.set_color(1, Color(color.r, color.g, color.b, 0.0))
	_beam_burst.restart()
	_beam_burst.emitting = true
	queue_redraw()

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_release()
		return
	queue_redraw()

func _draw() -> void:
	var progress = _lifetime / _max_lifetime
	var alpha = lerpf(0.9, 0.0, progress)
	var current_width = _width * lerpf(1.0, 0.4, progress)

	# Glow backing
	draw_line(_start, _end, Color(_color.r, _color.g, _color.b, alpha * 0.15), current_width * 3.0)

	# Core beam
	draw_line(_start, _end, Color(_color.r, _color.g, _color.b, alpha), current_width)

	# Bright center
	draw_line(_start, _end, Color(1.0, 1.0, 1.0, alpha * 0.8), current_width * 0.3)

	# Blocky nodes along beam
	var beam_dir = _end - _start
	var beam_len = beam_dir.length()
	if beam_len > 0:
		var num_blocks = int(beam_len / 30.0)
		for i in range(1, num_blocks + 1):
			var t = float(i) / (num_blocks + 1)
			var bp = lerp(_start, _end, t)
			var half = lerpf(3.0, 1.5, progress)
			draw_rect(Rect2(bp.x - half, bp.y - half, half * 2, half * 2),
				Color(1.0, 1.0, 1.0, alpha * 0.6))

func _release() -> void:
	_beam_burst.emitting = false
	PoolManager.release(self)

func _create_beam_burst() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 8
	p.lifetime = 0.15
	p.one_shot = true
	p.explosiveness = 1.0
	p.emitting = false
	p.texture = null
	p.local_coords = false
	p.z_index = 1
	p.visibility_rect = Rect2(-300, -300, 600, 600)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 50.0
	mat.initial_velocity_max = 90.0
	mat.damping_min = 4.0
	mat.damping_max = 7.0
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	grad.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 1.0),
		Color(0.4, 0.6, 1.0, 0.5),
		Color(0.4, 0.6, 1.0, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p
