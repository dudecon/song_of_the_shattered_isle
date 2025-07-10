# scripts/ui/canvas/BiomeCanvas.gd
class_name BiomeCanvas
extends Control

# Layer 2: UI Interface to the Mathematical Core
# This class has NO mathematical logic - it's pure interface

# Core Math Systems (external dependencies)
var math_core: BiomeMathCore
var tool_interface: ToolInterface
var influence_interface: InfluenceInterface

# Visual Layers (pure presentation)
var artistic_substrate: ArtisticSubstrate
var emoji_lattice: EmojiLattice
var sprite_layer: SpriteLayer
var effect_layer: EffectLayer

# UI Components (pure interface)
var tool_palette: ToolPalette
var hotkey_bindings: HotkeyBindings
var information_hud: InformationHUD
var zoom_controller: ZoomController

# UI State (no mathematical state)
var selected_node_indices: Array[int] = []
var active_tool: BiomeTool = null
var ui_zoom_level: float = 1.0

signal node_selected(node_index: int)
signal tool_deployed(tool_name: String, target_node_index: int)

func _ready():
	_initialize_visual_layers()
	_setup_ui_components()
	_connect_to_math_core()
	# REMOVED: _setup_interaction_handling() call - this method doesn't exist

func setup_for_biome(core: BiomeMathCore):
	"""Initialize this UI to display and interface with a specific math core"""
	math_core = core
	# FIXED: Remove constructor arguments
	tool_interface = ToolInterface.new()
	influence_interface = InfluenceInterface.new()
	
	# UI responds to math, never drives it
	_connect_to_math_core()
	_initialize_visual_from_math()

func _initialize_visual_layers():
	# Pure visual layers - no math logic
	artistic_substrate = ArtisticSubstrate.new()
	add_child(artistic_substrate)
	
	emoji_lattice = EmojiLattice.new()
	emoji_lattice.node_clicked.connect(_on_node_clicked)
	emoji_lattice.node_right_clicked.connect(_on_node_right_clicked)
	add_child(emoji_lattice)
	
	sprite_layer = SpriteLayer.new()
	add_child(sprite_layer)
	
	effect_layer = EffectLayer.new()
	add_child(effect_layer)

func _setup_ui_components():
	tool_palette = ToolPalette.new()
	tool_palette.tool_selected.connect(_on_tool_selected)
	add_child(tool_palette)
	
	hotkey_bindings = HotkeyBindings.new()
	hotkey_bindings.load_from_layer3_settings()
	
	information_hud = InformationHUD.new()
	add_child(information_hud)
	
	zoom_controller = ZoomController.new()
	zoom_controller.zoom_changed.connect(_on_zoom_changed)
	add_child(zoom_controller)

func _connect_to_math_core():
	"""Connect to math core signals - UI responds to math changes"""
	if math_core:
		math_core.state_evolved.connect(_on_math_state_evolved)
		math_core.node_modified.connect(_on_math_node_modified)
		math_core.biome_composition_changed.connect(_on_math_biome_changed)
		math_core.tool_deployed.connect(_on_math_tool_deployed)
		math_core.influence_painted.connect(_on_math_influence_painted)

func _initialize_visual_from_math():
	"""Initialize all visual elements from current math state"""
	if not math_core:
		return
	
	# Update visual layers from math state
	artistic_substrate.update_from_biome_composition(math_core.get_biome_composition())
	emoji_lattice.update_from_node_graph(math_core.get_node_graph())
	sprite_layer.update_from_sprite_state(math_core.get_sprite_state())
	information_hud.update_from_system_state(math_core.get_system_state())

func _input(event):
	if event is InputEventKey and event.pressed:
		var tool_name = hotkey_bindings.get_tool_for_key(event.keycode)
		if tool_name:
			_select_tool(tool_name)

func _select_tool(tool_name: String):
	if tool_interface:
		active_tool = tool_interface.get_tool(tool_name)
		if active_tool:
			tool_palette.set_active_tool(active_tool)
			_update_cursor_for_tool()

func _on_tool_selected(tool: BiomeTool):
	active_tool = tool
	_update_cursor_for_tool()

func _on_node_clicked(node_index: int):
	if active_tool == null:
		# Selection mode
		_select_node(node_index)
	else:
		# Tool deployment mode
		_deploy_tool_on_node(node_index)

func _on_node_right_clicked(node_index: int):
	_show_node_context_menu(node_index)

func _select_node(node_index: int):
	# Clear previous selection
	for prev_index in selected_node_indices:
		emoji_lattice.set_node_selected(prev_index, false)
	
	# Set new selection
	selected_node_indices = [node_index]
	emoji_lattice.set_node_selected(node_index, true)
	
	# Show node information
	var node_info = math_core.get_node_info(node_index)
	information_hud.show_node_details(node_info)
	
	node_selected.emit(node_index)

func _deploy_tool_on_node(node_index: int):
	if active_tool and math_core:
		# Check if tool can be deployed
		if math_core.can_deploy_tool(active_tool.tool_name, node_index):
			# Deploy tool via math core
			var deployment_result = math_core.deploy_tool(active_tool.tool_name, node_index)
			
			if deployment_result.success:
				tool_deployed.emit(active_tool.tool_name, node_index)
				# Visual feedback handled by signal from math core
			else:
				_show_deployment_error(deployment_result.error)
		else:
			_show_deployment_error("Cannot deploy " + active_tool.tool_name + " on this node")

func _show_deployment_error(error_message: String):
	var error_dialog = AcceptDialog.new()
	error_dialog.dialog_text = error_message
	add_child(error_dialog)
	error_dialog.popup_centered()

func _show_node_context_menu(node_index: int):
	var context_menu = NodeContextMenu.new()
	context_menu.node_action_requested.connect(_on_node_action_requested)
	add_child(context_menu)
	
	var mouse_pos = get_global_mouse_position()
	context_menu.show_for_node(node_index, mouse_pos)

func _on_node_action_requested(action: String, node_index: int):
	match action:
		"analyze":
			_analyze_node(node_index)
		"compress":
			_compress_node(node_index)
		"deploy":
			_select_tool("Spark")  # Default tool
		"influence":
			_start_influence_painting(node_index)
		"details":
			_show_node_details(node_index)

func _analyze_node(node_index: int):
	if math_core:
		var analysis_result = math_core.analyze_node(node_index)
		information_hud.show_detailed_analysis(analysis_result)

func _compress_node(node_index: int):
	# Confirm with user
	var confirmation = DecompressionDialog.new()
	confirmation.setup_for_node(node_index)
	confirmation.confirmed.connect(func(): _perform_compression(node_index))
	add_child(confirmation)

func _perform_compression(node_index: int):
	if math_core:
		var compression_result = math_core.compress_node(node_index)
		if compression_result.success:
			# Update visuals
			emoji_lattice.set_node_compressed(node_index, true)
		else:
			_show_deployment_error(compression_result.error)

func _start_influence_painting(node_index: int):
	if influence_interface:
		influence_interface.start_influence_painting(node_index)

func _decompress_node(node_index: int):
	# Confirm with user
	var confirmation = DecompressionDialog.new()
	confirmation.setup_for_node(node_index)
	confirmation.confirmed.connect(func(): _perform_decompression(node_index))
	add_child(confirmation)

func _perform_decompression(node_index: int):
	# Request decompression from math core
	var decompression_result = math_core.decompress_node(node_index)
	
	if decompression_result.success:
		# Create new BiomeCanvas for subsystem
		var subsystem_canvas = BiomeCanvas.new()
		subsystem_canvas.setup_for_biome(decompression_result.expanded_core)
		
		# Navigate to deeper layer
		var navigation_manager = get_node("/root/NavigationManager")
		navigation_manager.push_layer(subsystem_canvas, "Subsystem: " + str(node_index))
	else:
		# Show error
		var error_dialog = AcceptDialog.new()
		error_dialog.dialog_text = decompression_result.error_message
		add_child(error_dialog)
		error_dialog.popup_centered()

# Math Core Signal Handlers (UI responds to math changes)
func _on_math_state_evolved(new_state: Array):
	"""Math core evolved - update all visual elements"""
	emoji_lattice.update_from_math_state(new_state)
	sprite_layer.update_from_math_state(new_state)
	information_hud.update_system_metrics(new_state)

func _on_math_node_modified(node_index: int, modification_data: Dictionary):
	"""Math core modified a specific node - update visuals"""
	emoji_lattice.update_node_from_math(node_index, modification_data)
	sprite_layer.update_node_sprites(node_index, modification_data)
	
	# Update info if this node is selected
	if node_index in selected_node_indices:
		var node_info = math_core.get_node_info(node_index)
		information_hud.show_node_details(node_info)

func _on_math_biome_changed(composition_data: Dictionary):
	"""Math core changed biome composition - update visuals"""
	artistic_substrate.update_from_biome_composition(composition_data)
	sprite_layer.update_sprite_library(composition_data)
	emoji_lattice.update_influence_visualization(composition_data)

func _on_math_tool_deployed(tool_name: String, node_index: int, effect_data: Dictionary):
	"""Math core deployed a tool - show visual feedback"""
	effect_layer.show_tool_effect(node_index, tool_name, effect_data)
	
	# Update node visualization
	emoji_lattice.update_node_from_math(node_index, effect_data)

func _on_math_influence_painted(node_index: int, influence_data: Dictionary):
	"""Math core painted influence - update visuals"""
	emoji_lattice.update_node_influence_display(node_index, influence_data)
	effect_layer.show_influence_painting_effect(node_index, influence_data)

func _on_zoom_changed(new_zoom: float, focus_point: Vector2):
	"""Handle zoom changes - pure UI state"""
	ui_zoom_level = new_zoom
	
	# Update visual detail levels
	sprite_layer.set_detail_level(new_zoom)
	emoji_lattice.set_zoom_level(new_zoom)
	information_hud.set_information_density(new_zoom)

func _update_cursor_for_tool():
	"""Update cursor appearance based on active tool"""
	if active_tool:
		Input.set_default_cursor_shape(active_tool.cursor_shape)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _show_node_details(node_index: int):
	"""Show detailed node information dialog"""
	var node_info = math_core.get_node_info(node_index)
	var details_dialog = NodeDetailsDialog.new()
	details_dialog.setup_for_node(node_info)
	add_child(details_dialog)
	details_dialog.popup_centered()

func _manage_operators(node_index: int):
	"""Show operator management interface"""
	var operator_manager = OperatorManagerDialog.new()
	operator_manager.setup_for_node(node_index, math_core)
	add_child(operator_manager)
	operator_manager.popup_centered()

# Navigation support
func get_navigation_title() -> String:
	if math_core:
		return math_core.get_display_name()
	return "Unknown Biome"

func can_navigate_back() -> bool:
	return get_node("/root/NavigationManager").can_go_back()

func navigate_back():
	get_node("/root/NavigationManager").go_back()
