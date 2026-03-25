extends Node2D

var _reach: float = 90.0
var _arc_deg: float = 120.0
var _direction: float = 0.0
var _color: Color = Color.WHITE
var _lifetime: float = 0.0
var _max_lifetime: float = 0.3
var _is_afterimage: bool = false
var _damage: int = 0
var _hit_enemies: Array = []

var _slash_sparks: GPUParticles2D
var _slash_dust: GPUParticles2D

func _ready() -> void:
	_slash_sparks = _create_slash_sparks()
	add_child(_slash_sparks)
	_slash_dust = _create_slash_dust()
	add_child(_slash_dust)

func reset(pos: Vector2, reach: float, arc_deg: float, direction_rad: float, color: Color, damage: int = 0, afterimage: bool = false) -> void:
	global_position = pos
	_reach = reach
	_arc_deg = arc_deg
	_direction = direction_rad
	_color = color
	_lifetime = 0.0
	_is_afterimage = afterimage
	_max_lifetime = 0.4 if afterimage else 0.3
	_damage = damage
	_hit_enemies.clear()
	visible = true

	# Update particle colors and activate
	if _arc_deg < 360.0 and not _is_afterimage:
		_update_particle_color(_slash_sparks, _color)
		_update_particle_color(_slash_dust, _color)
		var start_a = _direction - deg_to_rad(_arc_deg / 2.0)
		_slash_sparks.position = Vector2(cos(start_a), sin(start_a)) * (_reach * 1.08)
		_slash_sparks.restart()
		_slash_sparks.emitting = true
		_slash_dust.restart()
		_slash_dust.emitting = true
	else:
		_slash_sparks.emitting = false
		_slash_dust.emitting = false

	queue_redraw()

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_release()
		return
	var player = get_tree().get_first_node_in_group("player")
	if player and not _is_afterimage:
		global_position = player.global_position
	if _damage > 0:
		_check_hits()

	# Track blade tip with spark emitter
	if _arc_deg < 360.0 and not _is_afterimage:
		var p = _lifetime / _max_lifetime
		var s = clampf(p / 0.4, 0.0, 1.0)
		var arc_r = deg_to_rad(_arc_deg)
		var ha = arc_r / 2.0
		var ba = lerp(_direction - ha, _direction + ha, s)
		_slash_sparks.position = Vector2(cos(ba), sin(ba)) * (_reach * 1.08)
		if s >= 1.0:
			_slash_sparks.emitting = false

	queue_redraw()

func _draw() -> void:
	var progress = _lifetime / _max_lifetime
	var base_alpha = 0.15 if _is_afterimage else 1.0

	if _arc_deg >= 360.0:
		_draw_full_sweep(progress, base_alpha)
	else:
		_draw_sword_slash(progress, base_alpha)

func _draw_sword_slash(progress: float, base_alpha: float) -> void:
	var arc_rad = deg_to_rad(_arc_deg)
	var half_arc = arc_rad / 2.0
	var start_angle = _direction - half_arc
	var end_angle = _direction + half_arc

	# Blade sweeps across the arc in the first 40% of lifetime
	var sweep = clampf(progress / 0.4, 0.0, 1.0)
	var blade_angle = lerp(start_angle, end_angle, sweep)

	# Fade out after the sweep finishes
	var fade = clampf(1.0 - (progress - 0.3) / 0.7, 0.0, 1.0)
	var alpha = base_alpha * fade

	if alpha < 0.01 or blade_angle <= start_angle + 0.01:
		return

	var outer_r = _reach
	var mid_r = _reach * 0.55
	var inner_r = _reach * 0.15
	var seg = 24

	# ── 1. SWOOSH BODY: thick filled crescent covering the damage area ──
	var body = PackedVector2Array()
	for i in range(seg + 1):
		var a = lerp(start_angle, blade_angle, float(i) / seg)
		body.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in range(seg, -1, -1):
		var a = lerp(start_angle, blade_angle, float(i) / seg)
		body.append(Vector2(cos(a), sin(a)) * inner_r)
	if body.size() >= 3:
		draw_colored_polygon(body, Color(_color.r, _color.g, _color.b, alpha * 0.25))

	# ── 2. BRIGHT OUTER CRESCENT: the visible slash trail ──
	var slash = PackedVector2Array()
	for i in range(seg + 1):
		var a = lerp(start_angle, blade_angle, float(i) / seg)
		slash.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in range(seg, -1, -1):
		var a = lerp(start_angle, blade_angle, float(i) / seg)
		slash.append(Vector2(cos(a), sin(a)) * mid_r)
	if slash.size() >= 3:
		draw_colored_polygon(slash, Color(_color.r, _color.g, _color.b, alpha * 0.4))

	# ── 2b. PIXELATED CRESCENT FILL: blocky texture inside the slash body ──
	var fill_count = 8
	for i in fill_count:
		var t = float(i + 1) / (fill_count + 1)
		var a = lerp(start_angle, blade_angle, t)
		var r = lerp(mid_r, outer_r, 0.3 + 0.4 * sin(t * PI))
		var px_pos = Vector2(cos(a), sin(a)) * r
		var px_alpha = alpha * 0.5 * (1.0 - t * 0.3)
		draw_rect(Rect2(px_pos.x - 1, px_pos.y - 1, 2, 2),
			Color(1.0, 1.0, 1.0, px_alpha))

	# ── 3. OUTER EDGE GLOW: bright arc at the slash rim ──
	var glow_color = Color(_color.r, _color.g, _color.b, alpha * 0.6)
	draw_arc(Vector2.ZERO, outer_r, start_angle, blade_angle, seg, glow_color, 5.0)
	var white_edge = Color(1.0, 1.0, 1.0, alpha * 0.8)
	draw_arc(Vector2.ZERO, outer_r, start_angle, blade_angle, seg, white_edge, 2.0)

	# ── 4. LEADING BLADE EDGE: radial line at the blade tip ──
	if sweep < 1.0 or progress < 0.5:
		var edge_alpha = alpha * clampf(1.0 - (progress - 0.4) / 0.3, 0.0, 1.0)
		var tip_in = Vector2(cos(blade_angle), sin(blade_angle)) * inner_r
		var tip_out = Vector2(cos(blade_angle), sin(blade_angle)) * (outer_r * 1.08)
		# Colored glow behind
		draw_line(tip_in, tip_out, Color(_color.r, _color.g, _color.b, edge_alpha * 0.5), 8.0)
		# White core
		draw_line(tip_in, tip_out, Color(1.0, 1.0, 1.0, edge_alpha), 3.0)
		# Blocky tip cluster
		draw_rect(Rect2(tip_out.x - 2, tip_out.y - 2, 4, 4),
			Color(1.0, 1.0, 1.0, edge_alpha * 0.9))
		draw_rect(Rect2(tip_out.x + 2, tip_out.y - 3, 2, 2),
			Color(_color.r, _color.g, _color.b, edge_alpha * 0.6))
		draw_rect(Rect2(tip_out.x - 4, tip_out.y + 1, 2, 2),
			Color(_color.r, _color.g, _color.b, edge_alpha * 0.6))

	# ── 5. TRAILING PIXEL WAKE: fading blocks behind the sweep ──
	var wake_count = 4
	for i in wake_count:
		var t = float(i) / wake_count
		var trail_angle = lerp(start_angle, blade_angle, t * 0.7)
		var trail_r = outer_r * (0.85 + t * 0.1)
		var trail_pos = Vector2(cos(trail_angle), sin(trail_angle)) * trail_r
		var wake_alpha = alpha * 0.3 * (1.0 - t)
		draw_rect(Rect2(trail_pos.x - 1.5, trail_pos.y - 1.5, 3, 3),
			Color(_color.r, _color.g, _color.b, wake_alpha))

func _draw_full_sweep(progress: float, base_alpha: float) -> void:
	# Phantom Reaper: expanding ring slash
	var fade = clampf(1.0 - progress, 0.0, 1.0)
	var alpha = base_alpha * fade
	var expand = 1.0 + progress * 0.15
	var outer_r = _reach * expand
	var mid_r = _reach * 0.55 * expand
	var inner_r = _reach * 0.15 * expand

	# Full ring body
	var seg = 36
	var body = PackedVector2Array()
	for i in range(seg + 1):
		var a = TAU * float(i) / seg
		body.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in range(seg, -1, -1):
		var a = TAU * float(i) / seg
		body.append(Vector2(cos(a), sin(a)) * inner_r)
	if body.size() >= 3:
		draw_colored_polygon(body, Color(_color.r, _color.g, _color.b, alpha * 0.2))

	# Bright outer crescent ring
	var slash = PackedVector2Array()
	for i in range(seg + 1):
		var a = TAU * float(i) / seg
		slash.append(Vector2(cos(a), sin(a)) * outer_r)
	for i in range(seg, -1, -1):
		var a = TAU * float(i) / seg
		slash.append(Vector2(cos(a), sin(a)) * mid_r)
	if slash.size() >= 3:
		draw_colored_polygon(slash, Color(_color.r, _color.g, _color.b, alpha * 0.35))

	# Ring edge glow
	draw_arc(Vector2.ZERO, outer_r, 0.0, TAU, seg,
		Color(_color.r, _color.g, _color.b, alpha * 0.6), 5.0)
	draw_arc(Vector2.ZERO, outer_r, 0.0, TAU, seg,
		Color(1.0, 1.0, 1.0, alpha * 0.7), 2.0)

	# Spinning blade lines
	var num_blades = 4
	for i in range(num_blades):
		var angle = TAU * float(i) / num_blades + progress * TAU * 0.7
		var b_in = Vector2(cos(angle), sin(angle)) * inner_r
		var b_out = Vector2(cos(angle), sin(angle)) * (outer_r * 1.05)
		draw_line(b_in, b_out, Color(1.0, 1.0, 1.0, alpha * 0.6), 2.5)
		draw_line(b_in, b_out, Color(_color.r, _color.g, _color.b, alpha * 0.4), 5.0)

func _check_hits() -> void:
	var progress = _lifetime / _max_lifetime
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy in _hit_enemies:
			continue
		var to_enemy = enemy.global_position - global_position
		var dist_sq = to_enemy.length_squared()

		if _arc_deg >= 360.0:
			# Full sweep grows over time — match the visual expand
			var expand = 1.0 + progress * 0.15
			var r = _reach * expand
			if dist_sq <= r * r:
				enemy.take_damage(_damage)
				_hit_enemies.append(enemy)
		else:
			# Arc slash — check distance and angle
			if dist_sq > _reach * _reach:
				continue
			var angle_diff = abs(angle_difference(_direction, to_enemy.angle()))
			if angle_diff <= deg_to_rad(_arc_deg / 2.0):
				enemy.take_damage(_damage)
				_hit_enemies.append(enemy)

func _release() -> void:
	_slash_sparks.emitting = false
	_slash_dust.emitting = false
	PoolManager.release(self)

func _create_slash_sparks() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 6
	p.lifetime = 0.2
	p.one_shot = false
	p.explosiveness = 0.0
	p.emitting = false
	p.texture = null
	p.local_coords = false
	p.z_index = 1
	p.visibility_rect = Rect2(-200, -200, 400, 400)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 60.0
	mat.initial_velocity_max = 100.0
	mat.damping_min = 5.0
	mat.damping_max = 8.0
	mat.scale_min = 2.0
	mat.scale_max = 3.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	grad.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 1.0),
		Color(0.75, 0.75, 0.75, 0.6),
		Color(0.75, 0.75, 0.75, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p

func _create_slash_dust() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 8
	p.lifetime = 0.3
	p.one_shot = true
	p.explosiveness = 1.0
	p.emitting = false
	p.texture = null
	p.local_coords = true
	p.z_index = -1
	p.visibility_rect = Rect2(-150, -150, 300, 300)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 20.0
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 15.0
	mat.initial_velocity_max = 30.0
	mat.damping_min = 2.0
	mat.damping_max = 4.0
	mat.scale_min = 2.0
	mat.scale_max = 3.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	grad.colors = PackedColorArray([
		Color(0.75, 0.75, 0.75, 0.4),
		Color(0.75, 0.75, 0.75, 0.15),
		Color(0.75, 0.75, 0.75, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p

func _update_particle_color(particles: GPUParticles2D, color: Color) -> void:
	var mat = particles.process_material as ParticleProcessMaterial
	if not mat or not mat.color_ramp:
		return
	var grad = (mat.color_ramp as GradientTexture1D).gradient
	var bright = Color(minf(color.r * 1.3, 1.0), minf(color.g * 1.3, 1.0), minf(color.b * 1.3, 1.0), grad.get_color(0).a)
	var mid = Color(color.r, color.g, color.b, grad.get_color(1).a)
	grad.set_color(0, bright)
	grad.set_color(1, mid)
