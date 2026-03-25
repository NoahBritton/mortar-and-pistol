extends Node2D

var _positions: Array[Vector2] = []
var _color: Color = Color.WHITE
var _lifetime: float = 0.0
var _max_lifetime: float = 0.3

var _chain_impact: GPUParticles2D

func _ready() -> void:
	_chain_impact = _create_chain_impact()
	add_child(_chain_impact)

func reset(positions: Array[Vector2], color: Color) -> void:
	global_position = Vector2.ZERO
	_positions = positions
	_color = color
	_lifetime = 0.0
	visible = true

	# Position impact burst at first enemy hit
	if _positions.size() > 1:
		_chain_impact.position = _positions[1]
		var mat = _chain_impact.process_material as ParticleProcessMaterial
		var grad = (mat.color_ramp as GradientTexture1D).gradient
		grad.set_color(1, Color(color.r, color.g, color.b, 0.5))
		_chain_impact.restart()
		_chain_impact.emitting = true

	queue_redraw()

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_release()
		return
	queue_redraw()

func _draw() -> void:
	if _positions.size() < 2:
		return
	var progress = _lifetime / _max_lifetime
	var alpha = lerp(0.9, 0.0, progress)
	var draw_color = Color(_color.r, _color.g, _color.b, alpha)
	var line_width = lerp(3.0, 1.5, progress)

	# ── 0. GLOW BACKING: wide soft lines behind lightning ──
	var glow_width = line_width * 3.5
	var glow_color = Color(_color.r, _color.g, _color.b, alpha * 0.2)
	for i in range(_positions.size() - 1):
		draw_line(_positions[i], _positions[i + 1], glow_color, glow_width)

	# ── 1. JAGGED LIGHTNING SEGMENTS (core visual) ──
	for i in range(_positions.size() - 1):
		var from = _positions[i]
		var to = _positions[i + 1]
		var perp = (to - from).normalized().rotated(PI / 2.0)
		var jag_amount = from.distance_to(to) * 0.25
		var mid1 = lerp(from, to, 0.33) + perp * randf_range(-jag_amount, jag_amount)
		var mid2 = lerp(from, to, 0.66) + perp * randf_range(-jag_amount, jag_amount)
		draw_line(from, mid1, draw_color, line_width)
		draw_line(mid1, mid2, draw_color, line_width)
		draw_line(mid2, to, draw_color, line_width)

	# ── 2. NODE IMPACT BLOCKS at each chain junction ──
	for i in range(1, _positions.size()):
		var np = _positions[i]
		var node_alpha = alpha * 0.8
		draw_rect(Rect2(np.x - 3, np.y - 3, 6, 6),
			Color(1.0, 1.0, 1.0, node_alpha))
		draw_rect(Rect2(np.x + 3, np.y - 4, 3, 3),
			Color(_color.r, _color.g, _color.b, node_alpha * 0.6))
		draw_rect(Rect2(np.x - 5, np.y + 2, 3, 3),
			Color(_color.r, _color.g, _color.b, node_alpha * 0.6))

	# ── 3. BRANCH FORKS ──
	for i in range(_positions.size() - 1):
		if i % 2 == 0:
			var mid = (_positions[i] + _positions[i + 1]) * 0.5
			var seg_dir = (_positions[i + 1] - _positions[i]).normalized()
			var perp_dir = seg_dir.rotated(PI / 2.0 * (1.0 if i % 4 == 0 else -1.0))
			var branch_end = mid + perp_dir * randf_range(8, 16)
			draw_line(mid, branch_end,
				Color(_color.r, _color.g, _color.b, alpha * 0.4), line_width * 0.7)

func _release() -> void:
	_chain_impact.emitting = false
	PoolManager.release(self)

func _create_chain_impact() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 6
	p.lifetime = 0.2
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
	mat.initial_velocity_min = 40.0
	mat.initial_velocity_max = 70.0
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
