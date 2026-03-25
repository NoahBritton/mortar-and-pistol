extends Control

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var main_menu_button: Button = $Panel/VBox/MainMenuButton
@onready var settings_panel: Control = $SettingsPanel

var _is_open: bool = false

func _ready() -> void:
	visible = false
	theme = UiTheme.game_theme

	UiTheme.add_ornate_panel($Panel)

	resume_button.pressed.connect(_on_resume)
	settings_button.pressed.connect(_on_settings)
	main_menu_button.pressed.connect(_on_main_menu)
	settings_panel.closed.connect(_on_settings_closed)
	for btn in [resume_button, settings_button, main_menu_button]:
		AudioManager.wire_button_sfx(btn)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if settings_panel.visible:
			settings_panel.visible = false
			$Panel.visible = true
			get_viewport().set_input_as_handled()
			return
		if _is_open:
			_close()
		else:
			_open()
		get_viewport().set_input_as_handled()

func _open() -> void:
	# Don't open if level-up or game-over panels are showing
	if get_tree().paused and not _is_open:
		return
	AudioManager.play(AudioManager.sfx_ui_open, -3.0)
	_is_open = true
	get_tree().paused = true
	$Panel.visible = true
	settings_panel.visible = false
	visible = true

func _close() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false

func _on_resume() -> void:
	_close()

func _on_settings() -> void:
	$Panel.visible = false
	settings_panel.show_settings()

func _on_settings_closed() -> void:
	$Panel.visible = true

func _on_main_menu() -> void:
	_is_open = false
	get_tree().paused = false
	PoolManager.clear_all_pools()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
