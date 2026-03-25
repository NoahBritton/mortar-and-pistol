extends Node2D

var damage: int = 0
var _color: Color = Color(1.0, 0.4, 0.1)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Glow rect behind body
	draw_rect(Rect2(-7, -7, 14, 14),
		Color(_color.r, _color.g, _color.b, 0.2))
	# Hot bright center
	draw_rect(Rect2(-3, -3, 6, 6),
		Color(1.0, 1.0, 0.8, 0.9))

func on_hit(_hit_enemy: Node2D = null) -> void:
	# Orbiters don't disappear on hit - they persist
	pass
