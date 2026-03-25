extends Node2D

@onready var label: Label = $Label

var _velocity: Vector2 = Vector2.ZERO
var _lifetime: float = 0.0
var _max_lifetime: float = 0.6

func reset(pos: Vector2, amount: int) -> void:
	global_position = pos
	label.text = str(amount)
	label.modulate = Color.WHITE
	if not label.has_theme_font_override("font"):
		label.add_theme_font_override("font", UiTheme.game_theme.default_font)
	_velocity = Vector2(randf_range(-30, 30), -80)
	_lifetime = 0.0
	scale = Vector2.ONE

func _process(delta: float) -> void:
	_lifetime += delta
	global_position += _velocity * delta
	_velocity.y += 100 * delta

	var progress = _lifetime / _max_lifetime
	label.modulate.a = 1.0 - progress
	scale = Vector2.ONE * (1.0 + progress * 0.3)

	if _lifetime >= _max_lifetime:
		PoolManager.release(self)
