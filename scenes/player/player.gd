extends CharacterBody2D

@export var base_move_speed: float = 200.0

# Dash constants
const DASH_DISTANCE_DEFAULT: float = 100.0
const DASH_DISTANCE_ASSASSIN: float = 130.0
const DASH_DURATION: float = 0.12
const DASH_COOLDOWN_BASE: float = 2.0
const DASH_COOLDOWN_MIN: float = 0.5
const DASH_IFRAMES_DURATION: float = 0.08
const AFTERIMAGE_COUNT: int = 4
const AFTERIMAGE_FADE_TIME: float = 0.25

@onready var color_rect: ColorRect = $ColorRect
@onready var pickup_area: Area2D = $PickupArea
@onready var hurt_area: Area2D = $HurtArea
@onready var damage_timer: Timer = $DamageTimer

var can_take_damage: bool = true
var _base_color: Color = Color(0.2, 0.4, 1.0)

# Dash state
var _is_dashing: bool = false
var _dash_elapsed: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT
var _dash_speed: float = 0.0
var _dash_cooldown_remaining: float = 0.0
var _dash_cooldown_total: float = 2.0
var _last_move_direction: Vector2 = Vector2.RIGHT
var _afterimage_interval: float = 0.0

func _ready() -> void:
	add_to_group("player")
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	pickup_area.area_entered.connect(_on_pickup_area_entered)
	# Center pivot so squash/stretch scales from middle
	color_rect.pivot_offset = color_rect.size / 2.0
	# Register dash input if not in InputMap
	if not InputMap.has_action("dash"):
		InputMap.add_action("dash")
		var ev = InputEventKey.new()
		ev.keycode = KEY_SPACE
		InputMap.action_add_event("dash", ev)

func _physics_process(delta: float) -> void:
	# Tick dash cooldown
	if _dash_cooldown_remaining > 0.0:
		_dash_cooldown_remaining -= delta

	# Dash state — early return while dashing
	if _is_dashing:
		_dash_elapsed += delta
		if _dash_elapsed >= DASH_DURATION:
			_end_dash()
		else:
			velocity = _dash_direction * _dash_speed
			move_and_slide()
			# Lerp alpha during dash for "blink" effect
			var progress = _dash_elapsed / DASH_DURATION
			color_rect.modulate.a = 0.3 + progress * 0.7
			# Spawn afterimages at intervals
			_afterimage_interval -= delta
			if _afterimage_interval <= 0.0:
				_afterimage_interval = DASH_DURATION / AFTERIMAGE_COUNT
				_spawn_afterimage()
			return

	# Normal movement
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()

	if input_dir.length_squared() > 0.01:
		_last_move_direction = input_dir

	velocity = input_dir * base_move_speed * GameManager.move_speed_mult
	move_and_slide()

	# Dash input check
	if Input.is_action_just_pressed("dash") and _can_dash():
		_start_dash()
		return

	# Continuous damage check: enemies phase through player
	if can_take_damage and not _is_dash_invulnerable():
		for body in hurt_area.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				var damage = body.get_contact_damage() if body.has_method("get_contact_damage") else 10
				GameManager.take_damage(damage)
				can_take_damage = false
				damage_timer.start()
				color_rect.color = Color.RED
				var tween = create_tween()
				tween.tween_property(color_rect, "color", _base_color, 0.15)
				break

# ── Dash ──

func _can_dash() -> bool:
	return not _is_dashing and _dash_cooldown_remaining <= 0.0 and GameManager.is_game_active

func _start_dash() -> void:
	_is_dashing = true
	_dash_elapsed = 0.0

	# Direction: current input, or last move direction if idle
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()
	_dash_direction = input_dir if input_dir.length_squared() > 0.01 else _last_move_direction

	# Hero-specific distance
	var distance = DASH_DISTANCE_DEFAULT
	if GameManager.selected_character == GameManager.CharacterID.ASSASSIN:
		distance = DASH_DISTANCE_ASSASSIN

	_dash_speed = distance / DASH_DURATION

	# Effective cooldown (Wind Vents reduces it)
	var reduction = GameManager.get_dash_cooldown_reduction()
	_dash_cooldown_total = maxf(DASH_COOLDOWN_MIN, DASH_COOLDOWN_BASE - reduction)
	_dash_cooldown_remaining = _dash_cooldown_total

	# Visual: squeeze horizontally at start
	color_rect.scale = Vector2(0.6, 1.2)
	color_rect.modulate.a = 0.3
	_afterimage_interval = 0.0  # spawn first one immediately

	SignalBus.player_dashed.emit(_dash_cooldown_total)

	# TODO: Hero variant effects
	# match GameManager.selected_character:
	#     GameManager.CharacterID.WIZARD:     _spawn_lightning_trail()
	#     GameManager.CharacterID.ALCHEMIST:  _spawn_poison_puddle(global_position)
	#     GameManager.CharacterID.BOMBARDIER: _knockback_nearby_enemies(global_position)
	#     GameManager.CharacterID.ASSASSIN:   pass  # handled by distance

func _end_dash() -> void:
	_is_dashing = false
	_dash_elapsed = 0.0
	velocity = Vector2.ZERO

	# Visual: stretch at end, then tween back to normal
	color_rect.scale = Vector2(1.3, 0.8)
	color_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(color_rect, "scale", Vector2.ONE, 0.15)

func _is_dash_invulnerable() -> bool:
	return _is_dashing and _dash_elapsed < DASH_IFRAMES_DURATION

func _spawn_afterimage() -> void:
	var ghost = ColorRect.new()
	ghost.size = color_rect.size
	ghost.color = _base_color
	ghost.modulate.a = 0.5
	ghost.global_position = global_position + color_rect.position
	get_parent().add_child(ghost)
	var tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, AFTERIMAGE_FADE_TIME)
	tween.tween_callback(ghost.queue_free)

# ── Callbacks ──

func _on_damage_timer_timeout() -> void:
	can_take_damage = true

func _on_pickup_area_entered(area: Area2D) -> void:
	if area.is_in_group("pickups"):
		area.get_parent().start_attraction(self)
