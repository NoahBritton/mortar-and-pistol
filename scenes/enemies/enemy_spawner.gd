extends Node

@export var spawn_interval: float = 1.0
@export var spawn_distance: float = 600.0
@export var max_enemies: int = 200

var _spawn_timer: float = 0.0
var _player: Node2D = null

func _ready() -> void:
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]

func _process(delta: float) -> void:
	if not GameManager.is_game_active or _player == null:
		return

	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer -= spawn_interval
		_spawn_batch()

func _spawn_batch() -> void:
	var current_count = get_tree().get_nodes_in_group("enemies").size()
	var to_spawn = _get_enemies_per_spawn()

	for i in to_spawn:
		if current_count + i >= max_enemies:
			break
		_spawn_single()

func _spawn_single() -> void:
	var enemy = PoolManager.acquire("enemy")
	if enemy:
		var spawn_pos = _get_random_spawn_position()
		enemy.reset(spawn_pos, _get_enemy_data())

func _get_enemies_per_spawn() -> int:
	var minutes = GameManager.elapsed_time / 60.0
	return int(1 + minutes * 0.5)

func _get_enemy_data() -> Dictionary:
	var minutes = GameManager.elapsed_time / 60.0
	return {
		"hp": int(30 + minutes * 10),
		"speed": 60.0 + minutes * 5.0,
		"damage": int(10 + minutes * 3),
		"xp": int(5 + minutes * 2),
	}

func _get_random_spawn_position() -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	return _player.global_position + offset
