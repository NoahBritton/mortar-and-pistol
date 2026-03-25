extends Node2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0
var damage: int = 10
var pierce: int = 1
var _hits_remaining: int = 1
var _lifetime: float = 0.0
var _max_lifetime: float = 3.0
var _ignore_enemy: Node2D = null

@onready var color_rect: ColorRect = $ColorRect
@onready var hit_area: Area2D = $HitArea

func reset(pos: Vector2, dir: Vector2, weapon_data: WeaponData, level: int = 1) -> void:
	global_position = pos
	direction = dir
	speed = weapon_data.projectile_speed * GameManager.proj_speed_mult
	damage = int(weapon_data.get_damage(level) * GameManager.damage_mult)
	pierce = weapon_data.get_pierce(level) + GameManager.pierce_bonus
	_hits_remaining = pierce
	_lifetime = 0.0
	_ignore_enemy = null
	rotation = dir.angle()
	color_rect.color = weapon_data.icon_color
	hit_area.add_to_group("projectiles")

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	_lifetime += delta
	if _lifetime >= _max_lifetime:
		_release()

func on_hit(_hit_enemy: Node2D = null) -> void:
	_hits_remaining -= 1
	if _hits_remaining <= 0:
		_release()

func _release() -> void:
	if hit_area.is_in_group("projectiles"):
		hit_area.remove_from_group("projectiles")
	PoolManager.release(self)
