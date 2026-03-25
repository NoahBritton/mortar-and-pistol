extends Node2D

var speed: float = 250.0
var damage: int = 10
var _target_node: Node2D = null
var _target_pos: Vector2
var _weapon_data: WeaponData
var _level: int = 1
var _lifetime: float = 0.0
var _max_lifetime: float = 3.0
var _initial_distance: float = 0.0
var _distance_traveled: float = 0.0
var _arc_height: float = 50.0
var _shattered: bool = false

@onready var hit_area: Area2D = $HitArea
@onready var flask_visual: Node2D = $FlaskVisual
@onready var color_rect: ColorRect = $FlaskVisual/ColorRect

var _trail: GPUParticles2D

func _ready() -> void:
	_trail = _create_trail()
	flask_visual.add_child(_trail)

func reset(pos: Vector2, target_node: Node2D, target_pos: Vector2,
		weapon_data: WeaponData, level: int) -> void:
	global_position = pos
	_target_node = target_node
	_target_pos = target_pos
	_weapon_data = weapon_data
	_level = level

	speed = weapon_data.projectile_speed * GameManager.proj_speed_mult
	damage = int(weapon_data.get_damage(level) * GameManager.damage_mult)
	_initial_distance = pos.distance_to(target_pos)
	_distance_traveled = 0.0
	_arc_height = clampf(_initial_distance * 0.25, 30.0, 80.0)

	_lifetime = 0.0
	_shattered = false
	rotation = 0.0
	flask_visual.position.y = 0.0
	flask_visual.rotation = 0.0
	color_rect.color = weapon_data.icon_color
	visible = true

	hit_area.add_to_group("projectiles")

	_trail.restart()
	_trail.emitting = true
	queue_redraw()

func _process(delta: float) -> void:
	if _shattered:
		return

	# Track target
	if is_instance_valid(_target_node) and _target_node.is_in_group("enemies"):
		_target_pos = _target_node.global_position

	# Move toward target on ground plane
	var to_target = _target_pos - global_position
	var dist = to_target.length()
	if dist < 10.0:
		_shatter()
		return

	global_position += (to_target / dist) * speed * delta

	# Arc offset
	_distance_traveled += speed * delta
	var progress = clampf(_distance_traveled / maxf(_initial_distance, 1.0), 0.0, 1.0)
	flask_visual.position.y = -_arc_height * sin(progress * PI)
	flask_visual.rotation += delta * 8.0

	_lifetime += delta
	if _lifetime >= _max_lifetime or progress >= 1.0:
		_shatter()
		return

	queue_redraw()

func on_hit(_hit_enemy: Node2D = null) -> void:
	if _shattered:
		return
	_shatter(_hit_enemy)

func _shatter(hit_enemy: Node2D = null) -> void:
	_shattered = true
	_trail.emitting = false
	AudioManager.play(AudioManager.sfx_hit)

	# Burst VFX
	var effect = PoolManager.acquire("aoe_effect")
	if effect:
		effect.reset(global_position, _weapon_data.effect_radius * GameManager.area_mult,
				_weapon_data.icon_color)

	# 360° shrapnel (ignore the enemy that triggered the shatter)
	var shrapnel_count = _weapon_data.get_projectile_count(_level) + GameManager.proj_count_bonus
	for i in shrapnel_count:
		var angle = TAU * float(i) / shrapnel_count
		var dir = Vector2(cos(angle), sin(angle))
		var proj = PoolManager.acquire("projectile")
		if proj:
			proj.reset(global_position + dir * 14.0, dir, _weapon_data, _level)
			proj.speed = speed * 0.8
			proj._hits_remaining = 1
			if hit_enemy:
				proj._ignore_enemy = hit_enemy

	_release()

func _release() -> void:
	_trail.emitting = false
	if hit_area.is_in_group("projectiles"):
		hit_area.remove_from_group("projectiles")
	PoolManager.release(self)

func _draw() -> void:
	if _shattered:
		return
	var progress = 0.0
	if _initial_distance > 0.0:
		progress = clampf(_distance_traveled / _initial_distance, 0.0, 1.0)
	var shadow_scale = 1.0 + 0.3 * sin(progress * PI)
	var sw = 5.0 * shadow_scale
	var sh = 3.0 * shadow_scale
	draw_rect(Rect2(-sw, -sh, sw * 2.0, sh * 2.0), Color(0.0, 0.0, 0.0, 0.25))

func _create_trail() -> GPUParticles2D:
	var p = GPUParticles2D.new()
	p.amount = 4
	p.lifetime = 0.25
	p.one_shot = false
	p.explosiveness = 0.0
	p.emitting = false
	p.texture = null
	p.local_coords = false
	p.z_index = -1
	p.visibility_rect = Rect2(-400, -400, 800, 800)

	var mat = ParticleProcessMaterial.new()
	mat.particle_flag_disable_z = true
	mat.gravity = Vector3(0, 40, 0)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 5.0
	mat.initial_velocity_max = 15.0
	mat.scale_min = 2.0
	mat.scale_max = 3.0

	var grad = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	grad.colors = PackedColorArray([
		Color(0.4, 1.0, 0.4, 0.6),
		Color(0.4, 1.0, 0.4, 0.0),
	])
	var tex = GradientTexture1D.new()
	tex.gradient = grad
	mat.color_ramp = tex
	p.process_material = mat
	return p
