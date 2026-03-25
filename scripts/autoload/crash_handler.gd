extends Node

## Crash Handler — saves game state periodically so crashes leave a debug trail.
## Writes to user://crash_log.txt on startup if previous session didn't exit cleanly.
## State is dumped to user://last_state.dat every 2 seconds.

const STATE_PATH = "user://last_state.dat"
const LOG_PATH = "user://crash_log.txt"
const HEARTBEAT_INTERVAL: float = 2.0

var _heartbeat_timer: float = 0.0
var _session_start: String = ""
var _clean_exit: bool = false
var _error_buffer: Array[String] = []
const MAX_ERRORS: int = 30

func _ready() -> void:
	_session_start = Time.get_datetime_string_from_system()
	process_mode = Node.PROCESS_MODE_ALWAYS # run even when paused

	# Check if previous session crashed (state file exists without CLEAN prefix)
	if FileAccess.file_exists(STATE_PATH):
		var prev_state = FileAccess.get_file_as_string(STATE_PATH)
		if not prev_state.begins_with("CLEAN"):
			_write_crash_report(prev_state)
			print("[CrashHandler] Previous session crashed! Log saved to: ", LOG_PATH)

	_write_state("STARTING: " + _session_start)

func _process(delta: float) -> void:
	_heartbeat_timer += delta
	if _heartbeat_timer >= HEARTBEAT_INTERVAL:
		_heartbeat_timer = 0.0
		_save_heartbeat()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_clean_exit = true
			_write_state("CLEAN: " + Time.get_datetime_string_from_system())
		NOTIFICATION_CRASH:
			_save_heartbeat()

## Call this from anywhere to log an error: CrashHandler.log_error("something broke")
func log_error(msg: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var entry = "[%s] %s" % [timestamp, msg]
	_error_buffer.append(entry)
	if _error_buffer.size() > MAX_ERRORS:
		_error_buffer.remove_at(0)
	push_error(entry)

func _save_heartbeat() -> void:
	_write_state(_build_state_string())

func _build_state_string() -> String:
	var lines: PackedStringArray = []
	lines.append("=== GAME STATE HEARTBEAT ===")
	lines.append("Session Start: " + _session_start)
	lines.append("Timestamp: " + Time.get_datetime_string_from_system())
	lines.append("Engine: Godot " + Engine.get_version_info().string)
	lines.append("FPS: " + str(Engine.get_frames_per_second()))
	lines.append("")

	# Game Manager state
	lines.append("--- GAME STATE ---")
	lines.append("is_game_active: " + str(GameManager.is_game_active))
	lines.append("elapsed_time: %.1fs" % GameManager.elapsed_time)
	lines.append("player_level: " + str(GameManager.player_level))
	lines.append("player_hp: %d/%d" % [GameManager.player_current_hp, GameManager.player_max_hp + GameManager.max_hp_bonus])
	lines.append("kill_count: " + str(GameManager.kill_count))
	lines.append("pending_levels: " + str(GameManager.pending_levels))
	lines.append("selected_character: " + str(GameManager.selected_character))
	lines.append("god_mode: " + str(GameManager.god_mode))
	lines.append("")

	# Stat multipliers
	lines.append("--- STAT MULTIPLIERS ---")
	lines.append("damage_mult: %.2f" % GameManager.damage_mult)
	lines.append("fire_rate_mult: %.2f" % GameManager.fire_rate_mult)
	lines.append("move_speed_mult: %.2f" % GameManager.move_speed_mult)
	lines.append("proj_speed_mult: %.2f" % GameManager.proj_speed_mult)
	lines.append("area_mult: %.2f" % GameManager.area_mult)
	lines.append("pickup_range_mult: %.2f" % GameManager.pickup_range_mult)
	lines.append("pierce_bonus: " + str(GameManager.pierce_bonus))
	lines.append("proj_count_bonus: " + str(GameManager.proj_count_bonus))
	lines.append("")

	# Inventory
	lines.append("--- WEAPONS (%d) ---" % GameManager.weapon_inventory.size())
	for entry in GameManager.weapon_inventory:
		lines.append("  %s (Lv%d) type=%s" % [entry.data.weapon_id, entry.level, str(entry.data.weapon_type)])

	lines.append("--- PASSIVES (%d) ---" % GameManager.passive_inventory.size())
	for entry in GameManager.passive_inventory:
		lines.append("  %s (Lv%d) stat=%s" % [entry.data.passive_id, entry.level, entry.data.stat_key])
	lines.append("")

	# Pool stats
	lines.append("--- POOL COUNTS ---")
	if PoolManager.has_method("get_pool_stats"):
		var stats = PoolManager.get_pool_stats()
		for pool_name in stats:
			lines.append("  %s: %d available / %d total" % [pool_name, stats[pool_name].available, stats[pool_name].total])
	else:
		# Fallback: count active nodes in key groups
		var tree = get_tree()
		if tree:
			lines.append("  enemies: " + str(tree.get_nodes_in_group("enemies").size()) + " active")
			lines.append("  projectiles: " + str(tree.get_nodes_in_group("projectiles").size()) + " active")
			lines.append("  pickups: " + str(tree.get_nodes_in_group("pickups").size()) + " active")
	lines.append("")

	# Player position
	var player_nodes = get_tree().get_nodes_in_group("player") if get_tree() else []
	if player_nodes.size() > 0:
		var p = player_nodes[0]
		lines.append("--- PLAYER ---")
		lines.append("position: " + str(p.global_position))
		lines.append("velocity: " + str(p.velocity))
		if "_is_dashing" in p:
			lines.append("is_dashing: " + str(p._is_dashing))
			lines.append("dash_cooldown: %.2f" % p._dash_cooldown_remaining)
	lines.append("")

	# Scene tree info
	if get_tree():
		lines.append("--- SCENE ---")
		lines.append("paused: " + str(get_tree().paused))
		var current = get_tree().current_scene
		lines.append("current_scene: " + (current.name if current else "null"))
		lines.append("node_count: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
		lines.append("orphan_nodes: " + str(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)))
	lines.append("")

	# Recent errors
	if _error_buffer.size() > 0:
		lines.append("--- RECENT ERRORS (%d) ---" % _error_buffer.size())
		for err in _error_buffer:
			lines.append("  " + err)
		lines.append("")

	# Memory
	lines.append("--- MEMORY ---")
	lines.append("static_memory: %.1f MB" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0))
	lines.append("video_memory: %.1f MB" % (Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0))

	return "\n".join(lines)

func _write_state(content: String) -> void:
	var f = FileAccess.open(STATE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(content)

func _write_crash_report(prev_state: String) -> void:
	# Append to crash log (preserves history of all crashes)
	var existing = ""
	if FileAccess.file_exists(LOG_PATH):
		existing = FileAccess.get_file_as_string(LOG_PATH)

	var report = "==============================\n"
	report += "CRASH DETECTED\n"
	report += "Recovered: " + Time.get_datetime_string_from_system() + "\n"
	report += "==============================\n"
	report += prev_state + "\n\n"

	var f = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if f:
		f.store_string(report + existing)
