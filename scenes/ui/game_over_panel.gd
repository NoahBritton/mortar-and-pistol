extends Control

@onready var stats_label: Label = $Panel/VBox/StatsLabel
@onready var retry_button: Button = $Panel/VBox/RetryButton
@onready var menu_button: Button = $Panel/VBox/MenuButton

func _ready() -> void:
	visible = false
	theme = UiTheme.game_theme

	UiTheme.add_ornate_panel($Panel)

	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)
	AudioManager.wire_button_sfx(retry_button)
	AudioManager.wire_button_sfx(menu_button)

func show_results() -> void:
	AudioManager.play(AudioManager.sfx_ui_open, -3.0)
	var minutes = int(GameManager.elapsed_time) / 60
	var seconds = int(GameManager.elapsed_time) % 60
	stats_label.text = "Survived: %02d:%02d\nKills: %d\nLevel: %d" % [
		minutes, seconds, GameManager.kill_count, GameManager.player_level
	]
	visible = true

func _on_retry() -> void:
	get_tree().paused = false
	PoolManager.clear_all_pools()
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_menu() -> void:
	get_tree().paused = false
	PoolManager.clear_all_pools()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
