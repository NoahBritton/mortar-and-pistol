extends CharacterBody2D

var max_hp: int = 30
var current_hp: int = 30
var move_speed: float = 60.0
var contact_damage: int = 10
var xp_value: int = 5
var _target: Node2D = null
var _is_dead: bool = false

@onready var color_rect: ColorRect = $ColorRect
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_bar_bg: ColorRect = $HealthBarBG
@onready var health_bar_fill: ColorRect = $HealthBarFill

const HEALTH_BAR_WIDTH: float = 24.0

func _ready() -> void:
	hitbox_area.area_entered.connect(_on_hitbox_area_entered)

func reset(pos: Vector2, data: Dictionary = {}) -> void:
	global_position = pos
	max_hp = data.get("hp", 30)
	current_hp = max_hp
	move_speed = data.get("speed", 60.0)
	contact_damage = data.get("damage", 10)
	xp_value = data.get("xp", 5)
	color_rect.color = Color(1.0, 0.2, 0.2)
	color_rect.self_modulate = Color.WHITE
	_is_dead = false
	add_to_group("enemies")
	_update_health_bar()

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_target = players[0]

func _physics_process(_delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	var direction = (_target.global_position - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	current_hp -= amount
	SignalBus.damage_dealt.emit.call_deferred(global_position + Vector2(0, -20), amount)
	_update_health_bar()

	# Flash white
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color.WHITE, 0.0)
	tween.tween_property(color_rect, "color", Color(1.0, 0.2, 0.2), 0.1)

	if current_hp <= 0:
		die()

func die() -> void:
	_is_dead = true
	var pos = global_position
	remove_from_group("enemies")
	PoolManager.release.call_deferred(self)
	SignalBus.enemy_killed.emit.call_deferred(pos)

func get_contact_damage() -> int:
	return contact_damage

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectiles"):
		var projectile = area.get_parent()
		if "_ignore_enemy" in projectile and projectile._ignore_enemy == self:
			return
		take_damage(projectile.damage)
		projectile.on_hit(self)

func _update_health_bar() -> void:
	var ratio = clampf(float(current_hp) / float(max_hp), 0.0, 1.0)
	health_bar_fill.offset_right = -12.0 + HEALTH_BAR_WIDTH * ratio
	# Hide health bar at full HP
	health_bar_bg.visible = ratio < 1.0
	health_bar_fill.visible = ratio < 1.0
