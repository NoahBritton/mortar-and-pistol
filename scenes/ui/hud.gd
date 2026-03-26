extends Control

@onready var hp_label: Label = $HealthBarContainer/HPLabel
@onready var hp_bar: ProgressBar = $HealthBarContainer/HPBar
@onready var timer_label: Label = $TopBar/TimerLabel
@onready var level_label: Label = $BottomBar/LevelLabel
@onready var xp_bar: ProgressBar = $BottomBar/XPBar
@onready var weapons_grid: GridContainer = $InventoryPanel/WeaponsGrid
@onready var passives_grid: GridContainer = $InventoryPanel/PassivesGrid
@onready var dash_bar: ProgressBar = $DashCooldownBar

# Icon texture paths for weapons and passives
const _SCRIBBLE_DIR = "res://assets/textures/kenney_scribble-platformer/PNG/Default/"
const _PARTICLE_DIR = "res://assets/textures/kenney_particle-pack/PNG (Transparent)/"
const _NINJA_DIR = "res://assets/superpowers-asset-packs-master/ninja-adventure/"

var weapon_icons = {
	"bayonet_rush": _SCRIBBLE_DIR + "item_sword.png",
	"mortar_burst": _PARTICLE_DIR + "circle_05.png",
	"arc_discharge": _PARTICLE_DIR + "spark_05.png",
	"ember_shells": _PARTICLE_DIR + "flame_02.png",
	"blight_flask": _PARTICLE_DIR + "scorch_02.png",
	"seeker_rounds": _SCRIBBLE_DIR + "item_bow.png",
	"reapers_bayonet": _NINJA_DIR + "weapons/katana.png",
	"carpet_bomber": _PARTICLE_DIR + "magic_04.png",
	"storm_conduit": _PARTICLE_DIR + "spark_07.png",
	"inferno_ring": _PARTICLE_DIR + "fire_01.png",
	"plague_barrage": _PARTICLE_DIR + "smoke_07.png",
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

var passive_icons = {
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

func _ready() -> void:
	theme = UiTheme.game_theme
	# Color HP bar red, XP bar green
	var hp_fill = StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.85, 0.2, 0.2)
	hp_fill.set_corner_radius_all(3)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	var xp_fill = StyleBoxFlat.new()
	xp_fill.bg_color = Color(0.3, 0.85, 0.4)
	xp_fill.set_corner_radius_all(3)
	xp_bar.add_theme_stylebox_override("fill", xp_fill)
	SignalBus.player_health_changed.connect(_on_health_changed)
	SignalBus.xp_gained.connect(_on_xp_changed)
	SignalBus.player_leveled_up.connect(_on_level_up)
	SignalBus.wave_timer_updated.connect(_on_timer_updated)
	SignalBus.inventory_changed.connect(_refresh_inventory)
	SignalBus.player_dashed.connect(_on_player_dashed)
	# Style dash cooldown bar (cyan)
	var dash_fill = StyleBoxFlat.new()
	dash_fill.bg_color = Color(0.3, 0.85, 0.95)
	dash_fill.set_corner_radius_all(2)
	dash_bar.add_theme_stylebox_override("fill", dash_fill)
	var dash_bg = StyleBoxFlat.new()
	dash_bg.bg_color = Color(0.15, 0.15, 0.2)
	dash_bg.set_corner_radius_all(2)
	dash_bar.add_theme_stylebox_override("background", dash_bg)
	_refresh_all()

func _refresh_all() -> void:
	_on_health_changed(GameManager.player_current_hp, GameManager.player_max_hp)
	_on_level_up(GameManager.player_level)
	_on_xp_changed(0)
	_refresh_inventory()

func _on_health_changed(current: int, max_hp: int) -> void:
	hp_label.text = "HP: %d/%d" % [current, max_hp]
	hp_bar.max_value = max_hp
	hp_bar.value = current

func _on_xp_changed(_amount: int) -> void:
	xp_bar.max_value = GameManager.xp_to_next_level()
	xp_bar.value = GameManager.player_xp

func _on_level_up(new_level: int) -> void:
	level_label.text = "Lv. %d" % new_level
	xp_bar.max_value = GameManager.xp_to_next_level()
	xp_bar.value = GameManager.player_xp

func _on_timer_updated(elapsed: float) -> void:
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

# ── Inventory Display ──

func _refresh_inventory() -> void:
	_rebuild_weapon_slots()
	_rebuild_passive_slots()

func _rebuild_weapon_slots() -> void:
	for child in weapons_grid.get_children():
		weapons_grid.remove_child(child)
		child.queue_free()
	for entry in GameManager.weapon_inventory:
		var slot = _create_slot(entry.data.icon_color, entry.data.weapon_name, entry.level, entry.data.max_level)
		if not entry.data.is_evolution:
			var rules = EvolutionDB.get_rules_for_weapon(entry.data.weapon_id)
			for rule in rules:
				var passive = PassivesDB.get_passive(rule.required_passive_id)
				if passive:
					var hint = Label.new()
					hint.text = "+" + passive.passive_name
					hint.add_theme_font_size_override("font_size", 7)
					hint.add_theme_color_override("font_color", passive.icon_color)
					hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					slot.add_child(hint)
		weapons_grid.add_child(slot)
	for i in range(GameManager.weapon_inventory.size(), GameManager.MAX_WEAPON_SLOTS):
		weapons_grid.add_child(_create_empty_slot())

func _rebuild_passive_slots() -> void:
	for child in passives_grid.get_children():
		passives_grid.remove_child(child)
		child.queue_free()
	for entry in GameManager.passive_inventory:
		var slot = _create_slot(entry.data.icon_color, entry.data.passive_name, entry.level, entry.data.max_level)
		passives_grid.add_child(slot)
	for i in range(GameManager.passive_inventory.size(), GameManager.MAX_PASSIVE_SLOTS):
		passives_grid.add_child(_create_empty_slot())

func _create_slot(color: Color, item_name: String, level: int, max_level: int) -> VBoxContainer:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(36, 0)
	container.add_theme_constant_override("separation", 2)

	# Create icon container (forced square via shrink flag)
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(42, 42)
	icon_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Create icon texture
	var icon_tex = TextureRect.new()
	var icon_path = _get_icon_for_item(item_name)
	if icon_path:
		icon_tex.texture = load(icon_path)
	icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_tex.modulate = color
	icon_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Create level badge (bottom-right corner)
	var badge = Label.new()
	badge.text = str(level) if level < max_level else "M"
	badge.add_theme_font_size_override("font_size", 9)
	badge.add_theme_color_override("font_color", Color.WHITE)
	badge.custom_minimum_size = Vector2(14, 14)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Position badge in bottom-right
	var badge_pos = MarginContainer.new()
	badge_pos.add_theme_constant_override("margin_left", 26)
	badge_pos.add_theme_constant_override("margin_top", 26)
	badge_pos.add_child(badge)

	icon_container.add_child(icon_tex)
	icon_container.add_child(badge_pos)

	# Ornate slot frame tinted to item color
	UiTheme.add_slot_frame(icon_container, Color(color.r, color.g, color.b, 0.7))

	container.add_child(icon_container)

	var name_lbl = Label.new()
	name_lbl.text = item_name
	name_lbl.add_theme_font_size_override("font_size", 7)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	container.add_child(name_lbl)

	container.tooltip_text = "%s (Lv %d/%d)" % [item_name, level, max_level]
	return container

func _get_icon_for_item(item_name: String) -> String:
	var item_id = item_name.to_lower().replace(" ", "_").replace("'", "")
	if weapon_icons.has(item_id):
		return weapon_icons[item_id]
	elif passive_icons.has(item_id):
		return passive_icons[item_id]
	return ""

func _create_empty_slot() -> VBoxContainer:
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(36, 0)
	container.add_theme_constant_override("separation", 2)

	# Create empty icon container (forced square via shrink flag)
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(42, 42)
	icon_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var question_label = Label.new()
	question_label.text = "?"
	question_label.add_theme_font_size_override("font_size", 22)
	question_label.add_theme_color_override("font_color", Color(0.35, 0.35, 0.4))
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	question_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	question_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	icon_container.add_child(question_label)

	# Dim ornate slot frame for empty slots
	UiTheme.add_slot_frame(icon_container, Color(0.3, 0.3, 0.35, 0.4))

	container.add_child(icon_container)

	var name_lbl = Label.new()
	name_lbl.text = "Empty"
	name_lbl.add_theme_font_size_override("font_size", 7)
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(name_lbl)

	return container

func _on_player_dashed(cooldown_duration: float) -> void:
	dash_bar.value = 0.0
	var tween = create_tween()
	tween.tween_property(dash_bar, "value", 1.0, cooldown_duration)
