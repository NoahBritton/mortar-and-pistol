extends Control

signal closed

@onready var master_slider: HSlider = $Panel/VBox/MasterRow/MasterSlider
@onready var sfx_slider: HSlider = $Panel/VBox/SFXRow/SFXSlider
@onready var res_option: OptionButton = $Panel/VBox/ResolutionRow/ResOption
@onready var fullscreen_check: CheckBox = $Panel/VBox/FullscreenRow/FullscreenCheck
@onready var god_mode_check: CheckBox = $Panel/VBox/GodModeRow/GodModeCheck
@onready var back_button: Button = $Panel/VBox/BackButton
@onready var vbox: VBoxContainer = $Panel/VBox

const RESOLUTIONS = [
	{"label": "960x540", "w": 960, "h": 540},
	{"label": "1280x720", "w": 1280, "h": 720},
	{"label": "1920x1080", "w": 1920, "h": 1080},
	{"label": "2560x1440", "w": 2560, "h": 1440},
]

const SETTINGS_PATH = "user://settings.cfg"

func _ready() -> void:
	visible = false
	theme = UiTheme.game_theme

	# Add ornate border overlay
	UiTheme.add_ornate_panel($Panel)

	# Set up proper VBox padding/margin management (prevents padding loss on fullscreen toggle)
	vbox.add_theme_constant_override("margin_left", 16)
	vbox.add_theme_constant_override("margin_right", 16)
	vbox.add_theme_constant_override("margin_top", 8)
	vbox.add_theme_constant_override("margin_bottom", 12)
	vbox.add_theme_constant_override("separation", 10)

	# Populate resolution dropdown
	for r in RESOLUTIONS:
		res_option.add_item(r.label)
	_select_current_resolution()

	# Set initial slider values from current audio
	var master_idx = AudioServer.get_bus_index("Master")
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_idx)) * 100.0
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_idx)) * 100.0
	else:
		sfx_slider.value = 80.0

	# Fullscreen state
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	# God Mode state
	god_mode_check.button_pressed = GameManager.god_mode

	# Connect signals
	master_slider.value_changed.connect(_on_master_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	res_option.item_selected.connect(_on_resolution_selected)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	god_mode_check.toggled.connect(_on_god_mode_toggled)
	back_button.pressed.connect(_on_back_pressed)

	AudioManager.wire_button_sfx(back_button)
	AudioManager.wire_button_sfx(fullscreen_check)
	AudioManager.wire_button_sfx(god_mode_check)

	# Load saved settings (overrides defaults above)
	_load_settings()

func show_settings() -> void:
	AudioManager.play(AudioManager.sfx_ui_open, -3.0)
	_select_current_resolution()
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	god_mode_check.button_pressed = GameManager.god_mode
	visible = true

func _on_master_changed(value: float) -> void:
	var db = linear_to_db(value / 100.0) if value > 0.0 else -80.0
	var idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(idx, db)
	_save_settings()

func _on_sfx_changed(value: float) -> void:
	var db = linear_to_db(value / 100.0) if value > 0.0 else -80.0
	var idx = AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, db)
	_save_settings()

func _on_resolution_selected(index: int) -> void:
	if index < 0 or index >= RESOLUTIONS.size():
		return
	var r = RESOLUTIONS[index]
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_size(Vector2i(r.w, r.h))
		# Center the window
		var screen_size = DisplayServer.screen_get_size()
		var win_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(Vector2i(
			(screen_size.x - win_size.x) / 2,
			(screen_size.y - win_size.y) / 2
		))
	_save_settings()

func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# Restore selected resolution
		_on_resolution_selected(res_option.selected)
	_save_settings()

func _on_god_mode_toggled(enabled: bool) -> void:
	GameManager.god_mode = enabled
	if enabled and GameManager.is_game_active:
		# Heal to full when enabling god mode mid-game
		var effective_max = GameManager.player_max_hp + GameManager.max_hp_bonus
		GameManager.player_current_hp = effective_max
		SignalBus.player_health_changed.emit(effective_max, effective_max)

func _on_back_pressed() -> void:
	visible = false
	closed.emit()

func _select_current_resolution() -> void:
	var win_size = DisplayServer.window_get_size()
	for i in RESOLUTIONS.size():
		if RESOLUTIONS[i].w == win_size.x and RESOLUTIONS[i].h == win_size.y:
			res_option.selected = i
			return
	# Default to 1920x1080 if no match
	res_option.selected = 2

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master", master_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.set_value("video", "resolution_index", res_option.selected)
	config.set_value("video", "fullscreen", fullscreen_check.button_pressed)
	config.save(SETTINGS_PATH)

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	master_slider.value = config.get_value("audio", "master", 80.0)
	sfx_slider.value = config.get_value("audio", "sfx", 80.0)
	var res_idx = config.get_value("video", "resolution_index", 2)
	res_option.selected = res_idx
	_on_resolution_selected(res_idx)
	var fs = config.get_value("video", "fullscreen", false)
	fullscreen_check.button_pressed = fs
	_on_fullscreen_toggled(fs)
