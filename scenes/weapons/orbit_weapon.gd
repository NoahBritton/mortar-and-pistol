extends Node2D

var _orbiters: Array[Node2D] = []
var _angle: float = 0.0
var _rotation_speed: float = 180.0  # degrees per second
var _orbit_radius: float = 60.0
var _damage: int = 7
var _color: Color = Color(1.0, 0.4, 0.1)
var _weapon_id: String = ""

func setup(data: WeaponData, level: int) -> void:
	_weapon_id = data.weapon_id
	_update_stats(data, level)
	_sync_orbiter_count(data.get_projectile_count(level) + GameManager.proj_count_bonus)

func refresh(data: WeaponData, level: int) -> void:
	_update_stats(data, level)
	_sync_orbiter_count(data.get_projectile_count(level) + GameManager.proj_count_bonus)

func _update_stats(data: WeaponData, level: int) -> void:
	_damage = int(data.get_damage(level) * GameManager.damage_mult)
	_orbit_radius = data.effect_radius * GameManager.area_mult
	_rotation_speed = data.projectile_speed * GameManager.proj_speed_mult
	_color = data.icon_color

func _sync_orbiter_count(target_count: int) -> void:
	# Add orbiters if needed
	while _orbiters.size() < target_count:
		_create_orbiter()
	# Remove extras if needed
	while _orbiters.size() > target_count:
		var orbiter = _orbiters.pop_back()
		var hit_area = orbiter.get_node_or_null("HitArea")
		if hit_area and hit_area.is_in_group("projectiles"):
			hit_area.remove_from_group("projectiles")
		orbiter.queue_free()
	# Update damage and color on all orbiters
	for orbiter in _orbiters:
		orbiter.damage = _damage
		orbiter._color = _color
		orbiter.get_node("ColorRect").color = _color
		# Update trail particle color
		var trail = orbiter.get_node_or_null("OrbiterTrail")
		if trail:
			var mat = trail.process_material as ParticleProcessMaterial
			var grad = (mat.color_ramp as GradientTexture1D).gradient
			grad.set_color(0, Color(_color.r, _color.g, _color.b, 0.8))
			grad.set_color(1, Color(_color.r * 0.6, _color.g * 0.3, _color.b * 0.2, 0.0))

func _create_orbiter() -> void:
	var orbiter = Node2D.new()
	orbiter.set_script(preload("res://scenes/weapons/orbiter.gd"))
	orbiter.damage = _damage
	orbiter._color = _color

	var trail = _create_orbiter_trail()
	trail.name = "OrbiterTrail"
	orbiter.add_child(trail)

	var rect = ColorRect.new()
	rect.name = "ColorRect"
	rect.custom_minimum_size = Vector2(10, 10)
	rect.size = Vector2(10, 10)
	rect.position = Vector2(-5, -5)
	rect.color = _color
	orbiter.add_child(rect)

	var hit_area = Area2D.new()
	hit_area.name = "HitArea"
	hit_area.collision_layer = 4  # player_projectiles
	hit_area.collision_mask = 2   # enemies
	hit_area.add_to_group("projectiles")
	orbiter.add_child(hit_area)

	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 7.0
	shape.shape = circle
	hit_area.add_child(shape)

	add_child(orbiter)
	_orbiters.append(orbiter)

func _process(delta: float) -> void:
	_angle += _rotation_speed * delta
	if _angle >= 360.0:
		_angle -= 360.0

	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var center = player.global_position
	var count = _orbiters.size()
	for i in count:
		var angle_offset = (360.0 / count) * i
		var rad = deg_to_rad(_angle + angle_offset)
		_orbiters[i].global_position = center + Vector2(cos(rad), sin(rad)) * _orbit_radius

func cleanup() -> void:
	for orbiter in _orbiters:
		if is_instance_valid(orbiter):
			var hit_area = orbiter.get_node_or_null("HitArea")
			if hit_area and hit_area.is_in_group("projectiles"):
				hit_area.remove_from_group("projectiles")
			orbiter.queue_free()
	_orbiters.clear()

func _create_orbiter_trail() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 4
	p.lifetime = 0.25
	p.one_shot = false
	p.explosiveness = 0.0
	p.emitting = true
	p.texture = null
	p.local_coords = false
	p.z_index = -1
	p.visibility_rect = Rect2(-300, -300, 600, 600)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3.ZERO
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 5.0
	mat.damping_min = 1.0
	mat.damping_max = 2.0
	mat.scale_min = 2.0
	mat.scale_max = 4.0
	mat.lifetime_randomness = 0.3

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	grad.colors = PackedColorArray([
		Color(_color.r, _color.g, _color.b, 0.8),
		Color(_color.r * 0.8, _color.g * 0.4, _color.b * 0.2, 0.4),
		Color(_color.r * 0.6, _color.g * 0.3, _color.b * 0.2, 0.0)
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p
