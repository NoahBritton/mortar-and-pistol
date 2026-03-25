extends Node2D

var tile_size: int = 64
var grid_extent: int = 20  # tiles in each direction from center
var color_a: Color = Color(0.12, 0.12, 0.16)
var color_b: Color = Color(0.15, 0.15, 0.20)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var cam_pos = global_position
	var base_x = int(floor(cam_pos.x / tile_size)) - grid_extent
	var base_y = int(floor(cam_pos.y / tile_size)) - grid_extent
	var count = grid_extent * 2 + 1
	for ix in count:
		for iy in count:
			var gx = base_x + ix
			var gy = base_y + iy
			var color = color_a if (gx + gy) % 2 == 0 else color_b
			var rect = Rect2(
				Vector2(gx * tile_size, gy * tile_size) - cam_pos,
				Vector2(tile_size, tile_size)
			)
			draw_rect(rect, color)
