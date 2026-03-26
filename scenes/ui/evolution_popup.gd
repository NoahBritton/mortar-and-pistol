extends Control

@onready var cards_row: HBoxContainer = $Panel/VBox/CardsRow

var _current_rules: Array[EvolutionData] = []

const _SCRIBBLE_DIR = "res://assets/textures/kenney_scribble-platformer/PNG/Default/"
const _PARTICLE_DIR = "res://assets/textures/kenney_particle-pack/PNG (Transparent)/"
const _NINJA_DIR = "res://assets/superpowers-asset-packs-master/ninja-adventure/"

func _ready() -> void:
	visible = false
	theme = UiTheme.game_theme
	UiTheme.add_ornate_panel($Panel)

func show_evolution_choices(rules: Array[EvolutionData]) -> void:
	_current_rules = rules
	AudioManager.play(AudioManager.sfx_ui_open)
	_build_cards()
	visible = true

func _build_cards() -> void:
	for child in cards_row.get_children():
		cards_row.remove_child(child)
		child.queue_free()
	for i in _current_rules.size():
		var card = _create_card(_current_rules[i], i)
		cards_row.add_child(card)

func _create_card(rule: EvolutionData, index: int) -> Button:
	var evolved = WeaponsDB.get_weapon(rule.evolved_weapon_id)
	var passive = PassivesDB.get_passive(rule.required_passive_id)
	var card = Button.new()
	card.custom_minimum_size = Vector2(220, 280)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.clip_text = false
	card.text = ""
	card.pressed.connect(_on_card_pressed.bind(index))
	AudioManager.wire_button_sfx(card)

	var evo_color = evolved.icon_color if evolved else Color(0.8, 0.5, 1.0)

	card.add_theme_stylebox_override("normal", UiTheme.make_card_style(Color(0.14, 0.1, 0.2)))
	card.add_theme_stylebox_override("hover", UiTheme.make_card_style(Color(0.25, 0.15, 0.35)))
	card.add_theme_stylebox_override("pressed", UiTheme.make_card_style(Color(0.1, 0.07, 0.14)))
	card.add_theme_stylebox_override("focus", UiTheme.make_card_style(Color(0.25, 0.15, 0.35)))

	var ornate_border = NinePatchRect.new()
	ornate_border.texture = load(UiTheme.TEX_CARD_BORDER)
	ornate_border.patch_margin_left = 16
	ornate_border.patch_margin_right = 16
	ornate_border.patch_margin_top = 16
	ornate_border.patch_margin_bottom = 16
	ornate_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ornate_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ornate_border.modulate = evo_color
	card.add_child(ornate_border)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	# "EVOLUTION" tag
	var tag = Label.new()
	tag.add_theme_font_size_override("font_size", 11)
	tag.add_theme_color_override("font_color", evo_color)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.text = "EVOLUTION"
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(tag)

	# Evolved weapon name
	var name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text = evolved.weapon_name if evolved else "???"
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	vbox.add_child(UiTheme.create_divider(evo_color * Color(1, 1, 1, 0.6)))

	# Description
	var desc = Label.new()
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.text = evolved.description if evolved else ""
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(spacer)

	# Requirements line
	var base_weapon = WeaponsDB.get_weapon(rule.base_weapon_id)
	var req_label = Label.new()
	req_label.add_theme_font_size_override("font_size", 9)
	req_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	req_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var base_name = base_weapon.weapon_name if base_weapon else rule.base_weapon_id
	var passive_name = passive.passive_name if passive else rule.required_passive_id
	req_label.text = "%s + %s" % [base_name, passive_name]
	req_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(req_label)

	return card

func _on_card_pressed(index: int) -> void:
	if index >= _current_rules.size():
		return
	SignalBus.evolution_chosen.emit(_current_rules[index])
	visible = false
