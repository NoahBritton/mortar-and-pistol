extends Control

@onready var start_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/StartButton
@onready var settings_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/Panel/VBoxContainer/ButtonContainer/QuitButton
@onready var settings_panel: Control = $SettingsPanel

func _ready() -> void:
	theme = UiTheme.game_theme
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	for btn in [start_button, settings_button, quit_button]:
		AudioManager.wire_button_sfx(btn)

	UiTheme.add_ornate_panel($CenterContainer/Panel)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select/character_select.tscn")

func _on_settings_pressed() -> void:
	settings_panel.show_settings()

func _on_quit_pressed() -> void:
	get_tree().quit()
