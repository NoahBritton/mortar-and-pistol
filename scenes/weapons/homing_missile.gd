extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 200.0
var damage: int = 15
var splash_radius: float = 30.0
var _target: Node2D = null
var _lifetime: float = 0.0
var _max_lifetime: float = 4.0
var _homing_strength: float = 4.0
var _color: Color = Color(0.8, 0.4, 1.0)

var _missile_trail: GPUParticles2D

@onready var color_rect: ColorRect = $ColorRect
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	_missile_trail = _create_missile_trail()
	add_child(_missile_trail)

func reset(pos: Vector2, target: Node2D, weapon_data: WeaponData, level: int) -> void:
	global_position = pos
	_target = target
	speed = weapon_data.projectile_speed * GameManager.proj_speed_mult
	damage = int(weapon_data.get_damage(level) * GameManager.damage_mult)
	splash_radius = weapon_data.effect_radius * GameManager.area_mult
	_color = weapon_data.icon_color
	_lifetime = 0.0

	if is_instance_valid(target):
		direction = (target.global_position - pos).normalized()
	else:
		direction = Vector2.RIGHT.rotated(randf() * TAU)

	rotation = direction.angle()
	color_rect.color = _color
	hit_area.add_to_group("projectiles")

	# Update trail color and start
	var mat = _missile_trail.process_material as ParticleProcessMaterial
	var grad = (mat.color_ramp as GradientTexture1D).gradient
	grad.set_color(0, Color(_color.r, _color.g, _color.b, 0.7))
	grad.set_color(1, Color(_color.r, _color.g, _color.b, 0.0))
	_missile_trail.restart()
	_missile_trail.emitting = true
	queue_redraw()

func _process(delta: float) -> void:
	if is_instance_valid(_target) and _target.is_in_group("enemies"):
		var desired = (_target.global_position - global_position).normalized()
		var angle_diff = direction.angle_to(desired)
		var max_turn = _homing_strength * delta
		angle_diff = clampf(angle_diff, -max_turn, max_turn)
		direction = direction.rotated(angle_diff)

	global_position += direction * speed * delta
	rotation = direction.angle()
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_release()
		return
	queue_redraw()

func _draw() -> void:
	# Glow rect behind body
	draw_rect(Rect2(-5, -5, 10, 10),
		Color(_color.r, _color.g, _color.b, 0.25))
	# Bright nose block
	draw_rect(Rect2(3, -1, 3, 2),
		Color(1.0, 1.0, 1.0, 0.8))

func on_hit(hit_enemy: Node2D = null) -> void:
	if splash_radius > 0.0:
		var splash_sq = splash_radius * splash_radius
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(enemy):
				continue
			if enemy == hit_enemy:
				continue
			if global_position.distance_squared_to(enemy.global_position) <= splash_sq:
				enemy.take_damage(damage)
	_release()

func _release() -> void:
	_missile_trail.emitting = false
	if hit_area.is_in_group("projectiles"):
		hit_area.remove_from_group("projectiles")
	PoolManager.release(self)

func _create_missile_trail() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 6
	p.lifetime = 0.3
	p.one_shot = false
	p.explosiveness = 0.0
	p.emitting = false
	p.texture = null
	p.local_coords = false
	p.z_index = -1
	p.visibility_rect = Rect2(-400, -400, 800, 800)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	mat.direction = Vector3(-1, 0, 0)
	mat.spread = 20.0
	mat.initial_velocity_min = 10.0
	mat.initial_velocity_max = 25.0
	mat.damping_min = 2.0
	mat.damping_max = 3.0
	mat.scale_min = 2.0
	mat.scale_max = 3.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	grad.colors = PackedColorArray([
		Color(0.8, 0.4, 1.0, 0.7),
		Color(0.8, 0.4, 1.0, 0.3),
		Color(0.8, 0.4, 1.0, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p
