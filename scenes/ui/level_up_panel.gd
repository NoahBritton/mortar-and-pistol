extends Control

@onready var cards_row: HBoxContainer = $Panel/VBox/CardsRow
@onready var reroll_button: Button = $Panel/VBox/RerollButton

var _current_choices: Array[Dictionary] = []
var _card_buttons: Array[Button] = []

func _ready() -> void:
	visible = false
	theme = UiTheme.game_theme

	UiTheme.add_ornate_panel($Panel)

	reroll_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reroll_button.custom_minimum_size = Vector2(160, 28)
	reroll_button.pressed.connect(_on_reroll_pressed)
	AudioManager.wire_button_sfx(reroll_button)

func show_upgrades() -> void:
	AudioManager.play(AudioManager.sfx_ui_open, -3.0)
	_current_choices = _generate_choices(3)
	_build_cards()
	_update_reroll_button()
	visible = true

func has_upgrades_available() -> bool:
	return _generate_choices(1).size() > 0

func _build_cards() -> void:
	for child in cards_row.get_children():
		cards_row.remove_child(child)
		child.queue_free()
	_card_buttons.clear()

	for i in _current_choices.size():
		var card = _create_card(_current_choices[i], i)
		cards_row.add_child(card)
		_card_buttons.append(card)

func _create_card(choice: Dictionary, index: int) -> Button:
	var card = Button.new()
	card.custom_minimum_size = Vector2(200, 260)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.clip_text = false
	card.text = ""
	card.pressed.connect(_on_button_pressed.bind(index))
	AudioManager.wire_button_sfx(card)

	# Card background — textured with all states overridden (no old hover bleed-through)
	var border_color = _get_border_color(choice)
	card.add_theme_stylebox_override("normal", UiTheme.make_card_style(Color(0.14, 0.13, 0.2)))
	card.add_theme_stylebox_override("hover", UiTheme.make_card_style(Color(0.22, 0.2, 0.3)))
	card.add_theme_stylebox_override("pressed", UiTheme.make_card_style(Color(0.1, 0.09, 0.14)))
	card.add_theme_stylebox_override("focus", UiTheme.make_card_style(Color(0.22, 0.2, 0.3)))

	# Ornate border overlay — different texture than main panels, tinted by choice type
	var ornate_border = NinePatchRect.new()
	ornate_border.texture = load(UiTheme.TEX_CARD_BORDER)
	ornate_border.patch_margin_left = 16
	ornate_border.patch_margin_right = 16
	ornate_border.patch_margin_top = 16
	ornate_border.patch_margin_bottom = 16
	ornate_border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ornate_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ornate_border.modulate = border_color
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
	vbox.add_theme_constant_override("separation", 8)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	# Icon (70×70 texture icon)
	var icon_center = CenterContainer.new()
	icon_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.custom_minimum_size = Vector2(0, 100)
	vbox.add_child(icon_center)

	var icon_rect = TextureRect.new()
	var icon_path = _get_choice_icon(choice)
	if icon_path:
		icon_rect.texture = load(icon_path)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.custom_minimum_size = Vector2(70, 70)
	icon_rect.modulate = border_color
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_center.add_child(icon_rect)

	# Type tag (e.g. "NEW WEAPON", "WEAPON LV 2 > 3")
	var type_label = Label.new()
	type_label.add_theme_font_size_override("font_size", 11)
	type_label.add_theme_color_override("font_color", border_color)
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.text = _get_type_tag(choice)
	type_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(type_label)

	# Name
	var name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text = _get_choice_name(choice)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	# Decorative divider (tinted to match card type)
	vbox.add_child(UiTheme.create_divider(border_color * Color(1, 1, 1, 0.6)))

	# Description
	var desc_label = Label.new()
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.text = _get_choice_description(choice)
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(desc_label)

	return card

func _get_border_color(choice: Dictionary) -> Color:
	match choice.type:
		"new_weapon":
			return Color(0.7, 0.7, 0.7) # Silver for new weapons
		"upgrade_weapon":
			return Color(0.8, 0.8, 0.3) # Gold for weapon upgrades
		"new_passive":
			return Color(0.5, 0.8, 0.5) # Green for new passives
		"upgrade_passive":
			return Color(1.0, 0.5, 0.8) # Magenta for passive upgrades
	return Color(0.5, 0.5, 0.5)

const _SCRIBBLE_DIR = "res://assets/textures/kenney_scribble-platformer/PNG/Default/"
const _PARTICLE_DIR = "res://assets/textures/kenney_particle-pack/PNG (Transparent)/"
const _NINJA_DIR = "res://assets/superpowers-asset-packs-master/ninja-adventure/"

func _get_choice_icon(choice: Dictionary) -> String:
	match choice.type:
		"new_weapon", "upgrade_weapon":
			var weapon_id = choice.data.weapon_id.to_lower()
			var icons = {
				"bayonet_rush": _SCRIBBLE_DIR + "item_sword.png",
				"reapers_bayonet": _NINJA_DIR + "weapons/katana.png",
				"mortar_burst": _PARTICLE_DIR + "circle_05.png",
				"carpet_bomber": _PARTICLE_DIR + "magic_04.png",
				"arc_discharge": _PARTICLE_DIR + "spark_05.png",
				"storm_conduit": _PARTICLE_DIR + "spark_07.png",
				"ember_shells": _PARTICLE_DIR + "flame_02.png",
				"inferno_ring": _PARTICLE_DIR + "fire_01.png",
				"blight_flask": _PARTICLE_DIR + "scorch_02.png",
				"plague_barrage": _PARTICLE_DIR + "smoke_07.png",
				"seeker_rounds": _SCRIBBLE_DIR + "item_bow.png",
				"bullet_storm": _PARTICLE_DIR + "flare_01.png",
				"bolt_rifle": _SCRIBBLE_DIR + "item_rod.png",
				"scatter_flask": _PARTICLE_DIR + "circle_05.png",
				"powder_keg": _SCRIBBLE_DIR + "tile_crate.png",
				"twin_barrels": _SCRIBBLE_DIR + "item_blaster.png",
				"implosion_flask": _PARTICLE_DIR + "circle_05.png",
				"chain_detonation_keg": _SCRIBBLE_DIR + "tile_crate.png",
				"ghost_barrage": _SCRIBBLE_DIR + "item_blaster.png",
				"refraction_beam": _SCRIBBLE_DIR + "item_rod.png",
				"cluster_salvo": _SCRIBBLE_DIR + "item_bow.png",
				"storm_engine": _PARTICLE_DIR + "spark_05.png",
			}
			return icons.get(weapon_id, _SCRIBBLE_DIR + "item_sword.png")
		"new_passive", "upgrade_passive":
			var passive_id = choice.data.passive_id.to_lower()
			var icons = {
				"gunpowder": _SCRIBBLE_DIR + "tile_heart.png",
				"clockwork": _NINJA_DIR + "items/scroll-empty.png",
				"quicksilver": _SCRIBBLE_DIR + "item_shieldRound.png",
				"birdshot": _SCRIBBLE_DIR + "tile_coin.png",
				"wind_vents": _SCRIBBLE_DIR + "tile_flag.png",
				"lodestone": _PARTICLE_DIR + "twirl_02.png",
				"focusing_lens": _PARTICLE_DIR + "light_01.png",
				"extra_powder": _SCRIBBLE_DIR + "tile_gem.png",
				"magnetism": _PARTICLE_DIR + "twirl_02.png",
				"volatile_kill": _PARTICLE_DIR + "scorch_02.png",
				"phantom_echo": _PARTICLE_DIR + "smoke_07.png",
				"ricochet": _PARTICLE_DIR + "spark_05.png",
				"shrapnel": _PARTICLE_DIR + "flare_01.png",
				"overclock": _PARTICLE_DIR + "flame_02.png",
			}
			return icons.get(passive_id, _SCRIBBLE_DIR + "tile_coin.png")
	return _SCRIBBLE_DIR + "tile_cog.png"

func _get_type_tag(choice: Dictionary) -> String:
	match choice.type:
		"new_weapon":
			return "NEW WEAPON"
		"upgrade_weapon":
			var entry = GameManager.get_weapon_entry(choice.data.weapon_id)
			var cur_level = entry.level if not entry.is_empty() else 1
			return "WEAPON LV %d > %d" % [cur_level, cur_level + 1]
		"new_passive":
			return "NEW PASSIVE"
		"upgrade_passive":
			var entry = _get_passive_entry(choice.data.passive_id)
			var cur_level = entry.level if not entry.is_empty() else 1
			return "PASSIVE LV %d > %d" % [cur_level, cur_level + 1]
	return "???"

func _get_choice_name(choice: Dictionary) -> String:
	match choice.type:
		"new_weapon", "upgrade_weapon":
			return choice.data.weapon_name
		"new_passive", "upgrade_passive":
			return choice.data.passive_name
	return "???"

func _get_choice_description(choice: Dictionary) -> String:
	match choice.type:
		"new_weapon", "upgrade_weapon":
			return choice.data.description
		"new_passive", "upgrade_passive":
			return choice.data.description
	return ""

func _update_reroll_button() -> void:
	if GameManager.god_mode:
		reroll_button.text = "Reroll (inf)"
		reroll_button.disabled = false
	elif GameManager.rerolls_remaining > 0:
		reroll_button.text = "Reroll (%d)" % GameManager.rerolls_remaining
		reroll_button.disabled = false
	else:
		reroll_button.text = "Reroll (0)"
		reroll_button.disabled = true

func _on_reroll_pressed() -> void:
	if not GameManager.god_mode:
		if GameManager.rerolls_remaining <= 0:
			return
		GameManager.rerolls_remaining -= 1
	show_upgrades()

func _on_button_pressed(index: int) -> void:
	if index >= _current_choices.size():
		return
	var chosen = _current_choices[index]
	SignalBus.upgrade_chosen.emit(chosen)
	visible = false

func _get_passive_entry(passive_id: String) -> Dictionary:
	for entry in GameManager.passive_inventory:
		if entry.data.passive_id == passive_id:
			return entry
	return {}

func _is_passive_relevant(passive: PassiveData) -> bool:
	if passive.is_universal():
		return true
	for entry in GameManager.weapon_inventory:
		if passive.stat_key in entry.data.used_stats:
			return true
	return false

func _generate_choices(count: int) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []

	# ── Weapon upgrades (owned, below max level) ──
	for entry in GameManager.weapon_inventory:
		if entry.level < entry.data.max_level:
			pool.append({"type": "upgrade_weapon", "data": entry.data, "weight": 10.0})

	# ── New weapons (if slots available) ──
	if GameManager.weapon_inventory.size() < GameManager.MAX_WEAPON_SLOTS:
		for w in WeaponsDB.get_all_base_weapons():
			if GameManager.has_weapon(w.weapon_id):
				continue
			# Skip if we already own any evolved form of this weapon
			var dominated = false
			for rule in EvolutionDB.get_rules_for_weapon(w.weapon_id):
				if GameManager.has_weapon(rule.evolved_weapon_id):
					dominated = true
					break
			if dominated:
				continue
			pool.append({"type": "new_weapon", "data": w, "weight": 8.0})

	# ── Passive upgrades (owned, below max level) ──
	for entry in GameManager.passive_inventory:
		if entry.level < entry.data.max_level:
			pool.append({"type": "upgrade_passive", "data": entry.data, "weight": 10.0})

	# ── New passives (if slots available, filtered by relevancy) ──
	if GameManager.passive_inventory.size() < GameManager.MAX_PASSIVE_SLOTS:
		for p in PassivesDB.get_all_passives():
			if GameManager.has_passive(p.passive_id):
				continue
			if not _is_passive_relevant(p):
				continue
			var w = 6.0
			# Boost passives that would unlock an evolution for an owned weapon
			if _passive_enables_evo(p.passive_id):
				w = 12.0
			pool.append({"type": "new_passive", "data": p, "weight": w})

	# ── Bias: empty slot filling ──
	var weapons_empty = GameManager.weapon_inventory.size() < GameManager.MAX_WEAPON_SLOTS
	var passives_empty = GameManager.passive_inventory.size() < GameManager.MAX_PASSIVE_SLOTS
	if weapons_empty:
		for entry in pool:
			if entry.type == "new_weapon":
				entry.weight *= 1.5
	if passives_empty:
		for entry in pool:
			if entry.type == "new_passive":
				entry.weight *= 1.5

	# ── Weighted shuffle and pick ──
	var result: Array[Dictionary] = []
	var remaining = pool.duplicate()
	for i in mini(count, remaining.size()):
		var choice = _weighted_pick(remaining)
		if choice.is_empty():
			break
		result.append(choice)
		remaining.erase(choice)
	return result

func _weighted_pick(pool: Array[Dictionary]) -> Dictionary:
	if pool.is_empty():
		return {}
	var total = 0.0
	for entry in pool:
		total += entry.get("weight", 1.0)
	var roll = randf() * total
	var sum = 0.0
	for entry in pool:
		sum += entry.get("weight", 1.0)
		if roll <= sum:
			return entry
	return pool.back()

func _passive_enables_evo(passive_id: String) -> bool:
	for rule in EvolutionDB.get_all_rules():
		if rule.required_passive_id != passive_id:
			continue
		var entry = GameManager.get_weapon_entry(rule.base_weapon_id)
		if not entry.is_empty():
			return true
	return false
