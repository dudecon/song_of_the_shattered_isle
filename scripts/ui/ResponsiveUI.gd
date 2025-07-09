# scripts/ui/ResponsiveUI.gd
class_name ResponsiveUI
extends RefCounted

# UI parameters based on screen size
class UIParameters:
	var screen_size: Vector2
	var ui_scale: float
	var font_base: int
	var margin_base: float
	var panel_width: float
	var visualization_size: float
	
	func _init(screen: Vector2):
		screen_size = screen
		ui_scale = min(screen.x / 1920.0, screen.y / 1080.0)
		font_base = int(12 * ui_scale)
		margin_base = 20 * ui_scale
		panel_width = 240 * ui_scale
		visualization_size = 300 * ui_scale

static func setup_responsive_ui(main_control: Control):
	var params = UIParameters.new(main_control.get_viewport().get_visible_rect().size)
	
	# Setup visualization (with null check)
	var viz = main_control.get_node_or_null("QuantumVisualization")
	if viz:
		viz.size = Vector2(params.visualization_size, params.visualization_size)
		viz.position = (main_control.size - viz.size) / 2
	
	# Setup controls panel (with null check)
	var controls = main_control.get_node_or_null("UI/Controls")
	if controls:
		controls.offset_left = -params.panel_width
		controls.offset_right = -params.margin_base
		controls.offset_top = params.margin_base
	
	# Setup fonts (with null checks)
	_setup_fonts(main_control, params)
	
	# Setup icon display (with null check)
	var icon_display = main_control.get_node_or_null("IconSwitcher/CurrentIconDisplay")
	if icon_display:
		icon_display.offset_left = params.margin_base
		icon_display.offset_right = params.panel_width * 1.5
		icon_display.offset_top = -120 * params.ui_scale
		icon_display.offset_bottom = -params.margin_base

static func _setup_fonts(control: Control, params: UIParameters):
	var font_sizes = {
		"title": params.font_base * 2,
		"subtitle": params.font_base * 1.2,
		"normal": params.font_base,
		"small": params.font_base * 0.8,
		"tiny": params.font_base * 0.6
	}
	
	# Apply font sizes with null checks
	var title = control.get_node_or_null("Title")
	if title:
		title.add_theme_font_size_override("font_size", font_sizes.title)
	
	var subtitle = control.get_node_or_null("Subtitle")
	if subtitle:
		subtitle.add_theme_font_size_override("font_size", font_sizes.subtitle)
	
	var time_label = control.get_node_or_null("UI/Controls/TimeLabel")
	if time_label:
		time_label.add_theme_font_size_override("font_size", font_sizes.normal)
	
	var status_label = control.get_node_or_null("UI/Controls/StatusLabel")
	if status_label:
		status_label.add_theme_font_size_override("font_size", font_sizes.small)
	
	var math_info = control.get_node_or_null("UI/Controls/MathematicalInfo")
	if math_info:
		math_info.add_theme_font_size_override("font_size", font_sizes.tiny)
	
	var instructions = control.get_node_or_null("UI/InstructionPanel/Instructions")
	if instructions:
		instructions.add_theme_font_size_override("font_size", font_sizes.small)
