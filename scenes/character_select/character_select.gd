extends Control

var _card_buttons: Array[Button] = []

func _ready() -> void:
	theme = UiTheme.game_theme
	_build_ui()

func _build_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.1, 1)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main layout
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 40)
	add_child(vbox)

	# Top spacer
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer_top)

	# Title
	var title = Label.new()
	title.text = "CHOOSE YOUR HERO"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", UiTheme.CLR_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title)

	# Divider
	vbox.add_child(UiTheme.create_divider(UiTheme.CLR_GOLD * Color(1, 1, 1, 0.6)))

	# Cards row
	var cards_row = HBoxContainer.new()
	cards_row.add_theme_constant_override("separation", 16)
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(cards_row)

	for char_id in GameManager.CHARACTER_DATA:
		var char_data = GameManager.CHARACTER_DATA[char_id]
		var card = _create_character_card(char_id, char_data)
		cards_row.add_child(card)
		_card_buttons.append(card)

	# Back button
	var back_button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(160, 38)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(_on_back_pressed)
	AudioManager.wire_button_sfx(back_button)
	vbox.add_child(back_button)

	# Bottom spacer
	var spacer_bottom = Control.new()
	spacer_bottom.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer_bottom)

func _create_character_card(char_id: int, char_data: Dictionary) -> Button:
	var card = Button.new()
	card.custom_minimum_size = Vector2(200, 300)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.clip_text = false
	card.text = ""
	card.pressed.connect(_on_character_selected.bind(char_id))
	AudioManager.wire_button_sfx(card)

	var color: Color = char_data.color

	card.add_theme_stylebox_override("normal", UiTheme.make_card_style(Color(0.14, 0.13, 0.2)))
	card.add_theme_stylebox_override("hover", UiTheme.make_card_style(Color(0.22, 0.2, 0.3)))
	card.add_theme_stylebox_override("pressed", UiTheme.make_card_style(Color(0.1, 0.09, 0.14)))
	card.add_theme_stylebox_override("focus", UiTheme.make_card_style(Color(0.22, 0.2, 0.3)))

	# Ornate border tinted to character color
	var ornate_border = NinePatchRect.new()
	ornate_border.texture = load(UiTheme.TEX_CARD_BORDER)
	ornate_border.patch_margin_left = 16
	ornate_border.patch_margin_right = 16
	ornate_border.patch_margin_top = 16
	ornate_border.patch_margin_bottom = 16
	ornate_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ornate_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ornate_border.modulate = color
	card.add_child(ornate_border)

	# Content margin
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(content)

	# Character name
	var name_label = Label.new()
	name_label.text = char_data.name
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", color)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(name_label)

	# Divider
	content.add_child(UiTheme.create_divider(color * Color(1, 1, 1, 0.6)))

	# Description
	var desc_label = Label.new()
	desc_label.text = char_data.description
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(desc_label)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	# Weapon name
	var weapon_data = WeaponsDB.get_weapon(char_data.weapon_id)
	var weapon_label = Label.new()
	weapon_label.text = "Weapon: " + weapon_data.weapon_name
	weapon_label.add_theme_font_size_override("font_size", 12)
	weapon_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(weapon_label)

	# Weapon description
	var wdesc_label = Label.new()
	wdesc_label.text = weapon_data.description
	wdesc_label.add_theme_font_size_override("font_size", 10)
	wdesc_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
	wdesc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wdesc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	wdesc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(wdesc_label)

	# Stat bonus
	var stat_label = Label.new()
	stat_label.text = char_data.stat_label
	stat_label.add_theme_font_size_override("font_size", 12)
	stat_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stat_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(stat_label)

	return card

func _on_character_selected(char_id: int) -> void:
	GameManager.selected_character = char_id
	GameManager.reset_run()
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
