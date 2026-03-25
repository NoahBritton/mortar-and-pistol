extends Node

## Builds and provides a project-wide UI theme using Kenney assets.
## Applied by UI scenes in their _ready() via:  theme = UiTheme.game_theme

var game_theme: Theme

const FONT_PATH = "res://assets/fonts/aldo_the_apache/AldotheApache.ttf"

# ── Texture paths for different UI element types ──
const TEX_PANEL_BORDER = "res://assets/textures/kenney_fantasy-ui-borders/PNG/Double/Border/panel-border-010.png"
const TEX_CARD_BORDER = "res://assets/textures/kenney_fantasy-ui-borders/PNG/Default/Border/panel-border-015.png"
const TEX_BUTTON = "res://assets/textures/kenney_fantasy-ui-borders/PNG/Default/Panel/panel-004.png"
const TEX_SLOT_FRAME = "res://assets/textures/kenney_fantasy-ui-borders/PNG/Default/Transparent center/panel-transparent-center-000.png"
const TEX_DIVIDER = "res://assets/textures/kenney_fantasy-ui-borders/PNG/Default/Divider Fade/divider-fade-002.png"

# ── Shared color palette ──
const CLR_GOLD = Color(1.0, 0.85, 0.55)
const CLR_ACCENT = Color(0.4, 0.75, 1.0)

func _ready() -> void:
	game_theme = Theme.new()
	var font = load(FONT_PATH) as Font

	# ── Default font ──
	game_theme.default_font = font
	game_theme.default_font_size = 14

	# ── Colors ──
	var white = Color.WHITE
	var grey = Color(0.7, 0.7, 0.8)

	# ── Panel ──
	# PanelContainer is transparent — visual bg + border added by add_ornate_panel()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0)
	panel_style.set_content_margin_all(12)
	game_theme.set_stylebox("panel", "PanelContainer", panel_style)

	# ── Button ── (textured with Kenney fantasy-ui panel)
	game_theme.set_stylebox("normal", "Button", _make_btn_style(Color(0.22, 0.2, 0.32)))
	game_theme.set_stylebox("hover", "Button", _make_btn_style(Color(0.38, 0.32, 0.50)))
	game_theme.set_stylebox("pressed", "Button", _make_btn_style(Color(0.14, 0.12, 0.2)))
	game_theme.set_stylebox("disabled", "Button", _make_btn_style(Color(0.15, 0.14, 0.2, 0.6)))
	game_theme.set_stylebox("focus", "Button", _make_btn_style(Color(0.40, 0.35, 0.55)))
	game_theme.set_color("font_color", "Button", white)
	game_theme.set_color("font_hover_color", "Button", CLR_ACCENT)
	game_theme.set_color("font_pressed_color", "Button", grey)
	game_theme.set_color("font_disabled_color", "Button", Color(0.4, 0.4, 0.5))

	# ── CheckBox ── (clean flat style — textured panels don't suit small toggles)
	var chk_base = StyleBoxFlat.new()
	chk_base.bg_color = Color(0.18, 0.16, 0.26, 0.9)
	chk_base.border_color = CLR_GOLD * Color(1, 1, 1, 0.3)
	chk_base.set_border_width_all(1)
	chk_base.set_corner_radius_all(3)
	chk_base.set_content_margin_all(4)

	var chk_hov = chk_base.duplicate()
	chk_hov.bg_color = Color(0.25, 0.22, 0.35, 0.95)
	chk_hov.border_color = CLR_GOLD * Color(1, 1, 1, 0.5)

	var chk_press = chk_base.duplicate()
	chk_press.bg_color = Color(0.12, 0.1, 0.18, 0.95)

	game_theme.set_stylebox("normal", "CheckBox", chk_base)
	game_theme.set_stylebox("hover", "CheckBox", chk_hov)
	game_theme.set_stylebox("pressed", "CheckBox", chk_press)
	game_theme.set_color("font_color", "CheckBox", grey)
	game_theme.set_color("font_hover_color", "CheckBox", CLR_ACCENT)

	# ── ProgressBar ──
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.1, 0.1, 0.18, 0.8)
	bar_bg.set_corner_radius_all(3)
	bar_bg.set_border_width_all(1)
	bar_bg.border_color = Color(0.3, 0.3, 0.4, 0.5)

	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = CLR_ACCENT
	bar_fill.set_corner_radius_all(3)

	game_theme.set_stylebox("background", "ProgressBar", bar_bg)
	game_theme.set_stylebox("fill", "ProgressBar", bar_fill)
	game_theme.set_color("font_color", "ProgressBar", white)

	# ── Label ──
	game_theme.set_color("font_color", "Label", white)
	game_theme.set_font("font", "Label", font)

	# ── HSlider ──
	var slider_bg = StyleBoxFlat.new()
	slider_bg.bg_color = Color(0.1, 0.1, 0.18, 0.8)
	slider_bg.set_corner_radius_all(3)
	slider_bg.set_content_margin_all(4)

	var slider_fill = StyleBoxFlat.new()
	slider_fill.bg_color = CLR_ACCENT
	slider_fill.set_corner_radius_all(3)
	slider_fill.set_content_margin_all(4)

	game_theme.set_stylebox("slider", "HSlider", slider_bg)
	game_theme.set_stylebox("grabber_area", "HSlider", slider_fill)
	game_theme.set_stylebox("grabber_area_highlight", "HSlider", slider_fill)
	game_theme.set_icon("grabber", "HSlider", _create_grabber_icon(white))
	game_theme.set_icon("grabber_highlight", "HSlider", _create_grabber_icon(CLR_ACCENT))

	# ── OptionButton ── (clean flat style — textured panels don't suit dropdowns)
	var opt_base = StyleBoxFlat.new()
	opt_base.bg_color = Color(0.18, 0.16, 0.26, 0.9)
	opt_base.border_color = CLR_GOLD * Color(1, 1, 1, 0.3)
	opt_base.set_border_width_all(1)
	opt_base.set_corner_radius_all(3)
	opt_base.set_content_margin_all(6)

	var opt_hov = opt_base.duplicate()
	opt_hov.bg_color = Color(0.25, 0.22, 0.35, 0.95)
	opt_hov.border_color = CLR_GOLD * Color(1, 1, 1, 0.5)

	var opt_press = opt_base.duplicate()
	opt_press.bg_color = Color(0.12, 0.1, 0.18, 0.95)

	var opt_focus = opt_hov.duplicate()

	game_theme.set_stylebox("normal", "OptionButton", opt_base)
	game_theme.set_stylebox("hover", "OptionButton", opt_hov)
	game_theme.set_stylebox("pressed", "OptionButton", opt_press)
	game_theme.set_stylebox("focus", "OptionButton", opt_focus)
	game_theme.set_color("font_color", "OptionButton", white)
	game_theme.set_color("font_hover_color", "OptionButton", CLR_ACCENT)

	# ── PopupMenu (OptionButton dropdown) ──
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.08, 0.08, 0.14, 0.95)
	popup_style.border_color = CLR_GOLD * Color(1, 1, 1, 0.4)
	popup_style.set_border_width_all(1)
	popup_style.set_corner_radius_all(4)
	popup_style.set_content_margin_all(4)

	var popup_hover = StyleBoxFlat.new()
	popup_hover.bg_color = Color(0.25, 0.22, 0.35)
	popup_hover.set_corner_radius_all(2)

	game_theme.set_stylebox("panel", "PopupMenu", popup_style)
	game_theme.set_stylebox("hover", "PopupMenu", popup_hover)
	game_theme.set_color("font_color", "PopupMenu", white)
	game_theme.set_color("font_hover_color", "PopupMenu", CLR_ACCENT)

func _make_btn_style(tint: Color) -> StyleBoxTexture:
	var s = StyleBoxTexture.new()
	s.texture = load(TEX_BUTTON)
	s.texture_margin_left = 16
	s.texture_margin_right = 16
	s.texture_margin_top = 16
	s.texture_margin_bottom = 16
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	s.modulate_color = tint
	return s

func _create_grabber_icon(color: Color) -> ImageTexture:
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

## Adds a dark backdrop + ornate NinePatchRect border to a PanelContainer.
## Wraps existing content in a MarginContainer for inner padding from border.
func add_ornate_panel(panel: Control, tint: Color = CLR_GOLD) -> void:
	# 1. Dark background (behind everything)
	var backdrop = ColorRect.new()
	backdrop.name = "PanelBackdrop"
	backdrop.color = Color(0.08, 0.08, 0.14, 0.95)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(backdrop)
	panel.move_child(backdrop, 0)

	# 2. Wrap existing content children in MarginContainer for inner padding
	var content_children: Array[Node] = []
	for child in panel.get_children():
		if child != backdrop:
			content_children.append(child)

	var padding = MarginContainer.new()
	padding.name = "PanelPadding"
	padding.add_theme_constant_override("margin_left", 12)
	padding.add_theme_constant_override("margin_right", 12)
	padding.add_theme_constant_override("margin_top", 12)
	padding.add_theme_constant_override("margin_bottom", 12)
	padding.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(padding)

	for child in content_children:
		child.reparent(padding)

	# 3. Ornate border (on top of everything)
	var border = NinePatchRect.new()
	border.name = "PanelBorder"
	border.texture = load(TEX_PANEL_BORDER)
	border.patch_margin_left = 32
	border.patch_margin_right = 32
	border.patch_margin_top = 32
	border.patch_margin_bottom = 32
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.modulate = tint
	panel.add_child(border)

## Creates a StyleBoxTexture for level-up card button states.
func make_card_style(tint: Color) -> StyleBoxTexture:
	var s = StyleBoxTexture.new()
	s.texture = load(TEX_BUTTON)
	s.texture_margin_left = 16
	s.texture_margin_right = 16
	s.texture_margin_top = 16
	s.texture_margin_bottom = 16
	s.modulate_color = tint
	return s

## Adds an ornate NinePatchRect frame around a slot icon container.
func add_slot_frame(icon_container: Control, tint: Color = Color.WHITE) -> void:
	var frame = NinePatchRect.new()
	frame.name = "SlotFrame"
	frame.texture = load(TEX_SLOT_FRAME)
	frame.patch_margin_left = 16
	frame.patch_margin_right = 16
	frame.patch_margin_top = 16
	frame.patch_margin_bottom = 16
	frame.custom_minimum_size = icon_container.custom_minimum_size
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.modulate = tint
	icon_container.add_child(frame)

## Creates a decorative divider TextureRect (horizontal ornament line).
func create_divider(tint: Color = CLR_GOLD) -> TextureRect:
	var divider = TextureRect.new()
	divider.texture = load(TEX_DIVIDER)
	divider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	divider.stretch_mode = TextureRect.STRETCH_SCALE
	divider.custom_minimum_size = Vector2(0, 6)
	divider.modulate = tint
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return divider
