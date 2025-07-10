# scripts/ui/canvas/EmojiLattice.gd
class_name EmojiLattice
extends Control

# Force-directed emoji node visualization - replaces QuantumVisualization

var emoji_nodes: Array[EmojiNodeDisplay] = []
var ley_lines: Array[LeyLineDisplay] = []
var force_layout: ForceDirectedLayout
var node_graph: NodeGraph

# Visual settings
var node_size: float = 40.0
var line_width: float = 2.0
var animation_speed: float = 5.0
var zoom_level: float = 1.0

# Colors
var node_colors: Dictionary = {
	"default": Color.WHITE,
	"selected": Color.YELLOW,
	"compressed": Color.CYAN,
	"influenced": Color.MAGENTA
}

var line_colors: Dictionary = {
	"weak": Color(0.5, 0.5, 0.5, 0.3),
	"medium": Color(0.7, 0.7, 0.9, 0.6),
	"strong": Color(0.9, 0.9, 1.0, 0.9)
}

signal node_clicked(node_index: int)
signal node_right_clicked(node_index: int)
signal node_hovered(node_index: int)

func _ready():
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_PASS

func setup_from_node_graph(graph: NodeGraph):
	"""Initialize lattice from node graph"""
	node_graph = graph
	force_layout = graph.force_layout
	
	_create_emoji_nodes()
	_create_ley_lines()
	_setup_animations()

func _create_emoji_nodes():
	"""Create visual emoji nodes"""
	_clear_existing_nodes()
	
	for i in range(node_graph.get_node_count()):
		var graph_node = node_graph.get_node(i)
		var emoji_node = EmojiNodeDisplay.new()
		emoji_node.setup_from_graph_node(graph_node, i)
		emoji_node.node_clicked.connect(_on_node_clicked)
		emoji_node.node_right_clicked.connect(_on_node_right_clicked)
		emoji_node.node_hovered.connect(_on_node_hovered)
		
		emoji_nodes.append(emoji_node)
		add_child(emoji_node)

func _create_ley_lines():
	"""Create visual connections between nodes"""
	_clear_existing_lines()
	
	var connections = node_graph.node_connections
	for i in range(connections.size()):
		for j in range(i + 1, connections.size()):
			var strength = connections[i][j]
			if strength > 0.1:  # Only show significant connections
				var ley_line = LeyLineDisplay.new()
				ley_line.setup(i, j, strength)
				ley_lines.append(ley_line)

func _setup_animations():
	"""Setup smooth animations for node movement"""
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_update_node_positions, 0.0, 1.0, 0.1)

func _clear_existing_nodes():
	for node in emoji_nodes:
		node.queue_free()
	emoji_nodes.clear()

func _clear_existing_lines():
	ley_lines.clear()

func update_from_node_graph(graph: NodeGraph):
	"""Update visualization from node graph changes"""
	if graph != node_graph:
		node_graph = graph
		setup_from_node_graph(graph)
	else:
		_update_node_states()
		_update_ley_line_strengths()

func update_from_math_state(state: PackedVector2Array):
	"""Update from quantum state evolution"""
	if force_layout:
		force_layout.update_forces(state, node_graph.node_connections)
	
	# Update node visual states based on vector magnitudes
	for i in range(min(state.size(), emoji_nodes.size())):
		var magnitude = state[i].length()
		emoji_nodes[i].set_energy_level(magnitude)

func _update_node_positions(progress: float):
	"""Update node positions from force layout"""
	if not force_layout:
		return
	
	var positions = force_layout.get_node_positions()
	for i in range(min(positions.size(), emoji_nodes.size())):
		var target_pos = positions[i] * zoom_level + size * 0.5
		emoji_nodes[i].animate_to_position(target_pos)

func _update_node_states():
	"""Update node visual states"""
	for i in range(emoji_nodes.size()):
		var graph_node = node_graph.get_node(i)
		emoji_nodes[i].update_from_graph_node(graph_node)

func _update_ley_line_strengths():
	"""Update ley line visual strengths"""
	var connections = node_graph.node_connections
	for ley_line in ley_lines:
		var strength = connections[ley_line.from_node][ley_line.to_node]
		ley_line.set_strength(strength)

func _draw():
	"""Draw ley lines between nodes"""
	if not force_layout:
		return
	
	var positions = force_layout.get_node_positions()
	var center_offset = size * 0.5
	
	for ley_line in ley_lines:
		var from_idx = ley_line.from_node
		var to_idx = ley_line.to_node
		
		if from_idx < positions.size() and to_idx < positions.size():
			var from_pos = positions[from_idx] * zoom_level + center_offset
			var to_pos = positions[to_idx] * zoom_level + center_offset
			
			var color = _get_line_color(ley_line.strength)
			var width = line_width * ley_line.strength * zoom_level
			
			draw_line(from_pos, to_pos, color, width)

func _get_line_color(strength: float) -> Color:
	"""Get color for connection strength"""
	if strength > 0.5:
		return line_colors.strong
	elif strength > 0.2:
		return line_colors.medium
	else:
		return line_colors.weak

func set_node_selected(node_index: int, selected: bool):
	"""Set node selection state"""
	if node_index >= 0 and node_index < emoji_nodes.size():
		emoji_nodes[node_index].set_selected(selected)

func update_node_from_math(node_index: int, modification_data: Dictionary):
	"""Update specific node from math changes"""
	if node_index >= 0 and node_index < emoji_nodes.size():
		emoji_nodes[node_index].update_from_modification(modification_data)

func update_node_influence_display(node_index: int, influence_data: Dictionary):
	"""Update node influence visualization"""
	if node_index >= 0 and node_index < emoji_nodes.size():
		emoji_nodes[node_index].update_influence_display(influence_data)

func set_zoom_level(new_zoom: float):
	"""Set zoom level for detail adjustment"""
	zoom_level = new_zoom
	
	# Adjust node sizes
	for node in emoji_nodes:
		node.set_zoom_scale(zoom_level)
	
	queue_redraw()

func _on_node_clicked(node_index: int):
	node_clicked.emit(node_index)

func _on_node_right_clicked(node_index: int):
	node_right_clicked.emit(node_index)

func _on_node_hovered(node_index: int):
	node_hovered.emit(node_index)

# Individual emoji node display
class EmojiNodeDisplay extends Control:
	var node_index: int
	var emoji_label: Label
	var background: ColorRect
	var selection_ring: ColorRect
	var influence_indicator: ColorRect
	var operator_indicators: Array[TextureRect] = []
	
	var is_selected: bool = false
	var is_compressed: bool = false
	var energy_level: float = 0.0
	var target_position: Vector2
	var current_zoom: float = 1.0
	
	signal node_clicked(index: int)
	signal node_right_clicked(index: int)
	signal node_hovered(index: int)
	
	func setup_from_graph_node(graph_node: BiomeGraphNode, index: int):
		node_index = index
		
		# Create visual elements
		_create_background()
		_create_selection_ring()
		_create_emoji_label(graph_node.emoji)
		_create_influence_indicator()
		
		# Setup interaction
		mouse_filter = Control.MOUSE_FILTER_PASS
		gui_input.connect(_on_gui_input)
		mouse_entered.connect(_on_mouse_entered)
		
		# Update from graph node
		update_from_graph_node(graph_node)
	
	func _create_background():
		background = ColorRect.new()
		background.size = Vector2(40, 40)
		background.color = Color(0.2, 0.2, 0.3, 0.8)
		add_child(background)
	
	func _create_selection_ring():
		selection_ring = ColorRect.new()
		selection_ring.size = Vector2(44, 44)
		selection_ring.position = Vector2(-2, -2)
		selection_ring.color = Color.YELLOW
		selection_ring.visible = false
		add_child(selection_ring)
	
	func _create_emoji_label(emoji: String):
		emoji_label = Label.new()
		emoji_label.text = emoji
		emoji_label.size = Vector2(40, 40)
		emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		emoji_label.add_theme_font_size_override("font_size", 24)
		add_child(emoji_label)
	
	func _create_influence_indicator():
		influence_indicator = ColorRect.new()
		influence_indicator.size = Vector2(8, 8)
		influence_indicator.position = Vector2(32, 0)
		influence_indicator.color = Color.MAGENTA
		influence_indicator.visible = false
		add_child(influence_indicator)
	
	func _on_gui_input(event):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				node_clicked.emit(node_index)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				node_right_clicked.emit(node_index)
	
	func _on_mouse_entered():
		node_hovered.emit(node_index)
	
	func update_from_graph_node(graph_node: BiomeGraphNode):
		is_compressed = graph_node.is_compressed
		
		# Update visual state
		if is_compressed:
			background.color = Color(0.3, 0.6, 0.8, 0.8)
		else:
			background.color = Color(0.2, 0.2, 0.3, 0.8)
		
		# Update operator indicators
		_update_operator_indicators(graph_node.get_operators())
	
	func _update_operator_indicators(operators: Array):
		# Clear existing indicators
		for indicator in operator_indicators:
			indicator.queue_free()
		operator_indicators.clear()
		
		# Add new indicators
		for i in range(min(operators.size(), 3)):  # Max 3 indicators
			var indicator = TextureRect.new()
			indicator.size = Vector2(12, 12)
			indicator.position = Vector2(28, 28 - i * 6)
			indicator.modulate = Color.GREEN
			operator_indicators.append(indicator)
			add_child(indicator)
	
	func set_selected(selected: bool):
		is_selected = selected
		selection_ring.visible = selected
	
	func set_energy_level(energy: float):
		energy_level = energy
		
		# Pulse based on energy
		var pulse_scale = 1.0 + energy * 0.1
		scale = Vector2(pulse_scale, pulse_scale)
		
		# Color intensity based on energy
		var intensity = clamp(energy, 0.0, 1.0)
		emoji_label.modulate = Color.WHITE.lerp(Color.YELLOW, intensity)
	
	func animate_to_position(target_pos: Vector2):
		target_position = target_pos
		
		var tween = create_tween()
		tween.tween_property(self, "position", target_pos, 0.1)
	
	func update_from_modification(modification_data: Dictionary):
		# Handle various modification types
		match modification_data.get("type", ""):
			"tool_deployed":
				_show_tool_effect(modification_data)
			"influence_painted":
				_show_influence_effect(modification_data)
			"operator_added":
				_show_operator_effect(modification_data)
	
	func _show_tool_effect(data: Dictionary):
		# Flash effect for tool deployment
		var flash = ColorRect.new()
		flash.size = size
		flash.color = Color.WHITE
		flash.modulate.a = 0.5
		add_child(flash)
		
		var tween = create_tween()
		tween.tween_property(flash, "modulate:a", 0.0, 0.5)
		tween.tween_callback(flash.queue_free)
	
	func _show_influence_effect(data: Dictionary):
		influence_indicator.visible = true
		influence_indicator.color = Color.MAGENTA
	
	func _show_operator_effect(data: Dictionary):
		# Add operator indicator
		var indicator = TextureRect.new()
		indicator.size = Vector2(12, 12)
		indicator.position = Vector2(28, 28)
		indicator.modulate = Color.GREEN
		add_child(indicator)
	
	func update_influence_display(influence_data: Dictionary):
		var has_influence = influence_data.get("has_influence", false)
		influence_indicator.visible = has_influence
		
		if has_influence:
			var strength = influence_data.get("combined_strength", 0.0)
			influence_indicator.modulate.a = clamp(strength, 0.2, 1.0)
	
	func set_zoom_scale(zoom: float):
		current_zoom = zoom
		
		# Adjust font size based on zoom
		var font_size = int(24 * zoom)
		emoji_label.add_theme_font_size_override("font_size", font_size)

# Ley line connection display
class LeyLineDisplay extends RefCounted:
	var from_node: int
	var to_node: int
	var strength: float
	
	func setup(from: int, to: int, connection_strength: float):
		from_node = from
		to_node = to
		strength = connection_strength
	
	func set_strength(new_strength: float):
		strength = new_strength
