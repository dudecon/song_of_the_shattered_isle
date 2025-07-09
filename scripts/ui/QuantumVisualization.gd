# scripts/ui/QuantumVisualization.gd - Enhanced with proper layout
class_name QuantumVisualization
extends Control

@export var auto_scale: bool = true
@export var animation_speed: float = 1.0
@export var show_connections: bool = true
@export var debug_positioning: bool = false

var conductor: QuantumConductor
var component_displays: Array[ComponentDisplay] = []
var connection_lines: Array[ConnectionLine] = []
var setup_complete: bool = false

# Layout management
var center_point: Vector2
var display_radius: float
var ui_params: ResponsiveUI.UIParameters

func _ready():
	_setup_layout()
	_find_conductor()
	_setup_update_timer()

func _setup_layout():
	# Calculate responsive parameters
	ui_params = ResponsiveUI.UIParameters.new(get_viewport().get_visible_rect().size)
	
	# Set visualization area to proper size
	var viz_size = Vector2(ui_params.visualization_size, ui_params.visualization_size)
	size = viz_size
	
	# Position in center of parent
	if get_parent():
		var parent_size = get_parent().size
		position = (parent_size - size) / 2
	
	# Calculate layout parameters
	center_point = size / 2
	display_radius = size.x * 0.35  # 35% of width for component circle
	
	if debug_positioning:
		print("QuantumViz Layout - Size: ", size, " Center: ", center_point, " Radius: ", display_radius)

func _find_conductor():
	# Enhanced conductor finding with better error handling
	var search_paths = [
		"../QuantumConductor",
		"../../QuantumConductor", 
		"../../../QuantumConductor",
		"QuantumConductor"
	]
	
	for path in search_paths:
		conductor = get_node_or_null(path)
		if conductor:
			break
	
	if conductor:
		_connect_conductor_signals()
		_setup_component_displays()
		print("QuantumVisualization: Connected to conductor")
	else:
		push_error("QuantumVisualization: Could not find QuantumConductor!")

func _connect_conductor_signals():
	conductor.icon_loaded.connect(_on_icon_loaded)
	conductor.evolution_step_completed.connect(_on_evolution_step)
	conductor.system_energy_changed.connect(_on_system_energy_changed)
	conductor.phase_coherence_changed.connect(_on_phase_coherence_changed)

func _setup_update_timer():
	var timer = Timer.new()
	timer.wait_time = 0.05  # 20 FPS updates
	timer.timeout.connect(_update_displays)
	timer.autostart = true
	add_child(timer)

func _setup_component_displays():
	if not conductor or not conductor.current_icon:
		return
	
	print("Setting up displays for: ", conductor.current_icon.name)
	_clear_displays()
	
	var icon = conductor.current_icon
	
	# Adjust radius for different icon dimensions
	if auto_scale:
		display_radius = (size.x * 0.35) * sqrt(7.0 / icon.dimension)
	
	# Create component displays
	for i in range(icon.dimension):
		var display = ComponentDisplay.new()
		var info = icon.get_component_info(i)
		display.setup(i, info, icon.visualization_config)
		
		# Position in perfect circle
		var angle = (i / float(icon.dimension)) * TAU
		var pos = center_point + Vector2(cos(angle), sin(angle)) * display_radius
		display.position = pos - display.size / 2  # Center the display
		
		add_child(display)
		component_displays.append(display)
		
		if debug_positioning:
			print("Display ", i, " (", info.emoji, ") at ", pos)
	
	# Create connection lines after displays are positioned
	_create_connection_lines()
	setup_complete = true

func _clear_displays():
	for display in component_displays:
		if display and is_instance_valid(display):
			display.queue_free()
	component_displays.clear()
	
	for line in connection_lines:
		if line and is_instance_valid(line):
			line.queue_free()
	connection_lines.clear()

func _create_connection_lines():
	if not conductor or not conductor.current_icon or not show_connections:
		return
	
	var icon = conductor.current_icon
	
	# Create lines for strong connections
	for i in range(icon.dimension):
		var connections = icon.get_dominant_connections(i)
		for conn in connections:
			if conn.type == "outgoing" and abs(conn.strength) > 0.2:
				var line = ConnectionLine.new()
				line.setup(i, conn.target, conn.strength, component_displays)
				add_child(line)
				connection_lines.append(line)

func _update_displays():
	if not conductor or not setup_complete:
		return
	
	# Update component displays
	for i in range(component_displays.size()):
		if i < component_displays.size() and is_instance_valid(component_displays[i]):
			var magnitude = conductor.get_component_magnitude(i)
			var phase = conductor.get_component_phase(i)
			var real_part = conductor.get_component_real(i)
			var imag_part = conductor.get_component_imaginary(i)
			
			component_displays[i].update_values(magnitude, phase, real_part, imag_part)
	
	# Update connection lines
	for line in connection_lines:
		if line and is_instance_valid(line):
			line.update_flow_animation()

func _on_icon_loaded(icon_name: String):
	print("QuantumVisualization: Icon loaded - ", icon_name)
	setup_complete = false
	_setup_component_displays()

func _on_evolution_step(state: PackedVector2Array):
	# Handled by update timer
	pass

func _on_system_energy_changed(energy: float):
	# Subtle background energy effect
	modulate = Color.WHITE.lerp(Color(1.2, 1.1, 1.0), energy * 0.1)

func _on_phase_coherence_changed(coherence: float):
	# Add coherence glow effect
	if coherence > 0.8:
		modulate = Color.WHITE.lerp(Color.CYAN, (coherence - 0.8) * 2.0)

# Enhanced ComponentDisplay with better layout
class ComponentDisplay extends Control:
	var component_index: int
	var component_info: Dictionary
	var visualization_config: Dictionary
	
	var background: ColorRect
	var emoji_label: Label
	var magnitude_label: Label
	var phase_indicator: Control
	var magnitude_bar: ProgressBar
	
	var base_color: Color = Color.WHITE
	var current_tween: Tween
	
	func setup(index: int, info: Dictionary, vis_config: Dictionary = {}):
		component_index = index
		component_info = info
		visualization_config = vis_config
		
		# Set consistent size
		size = Vector2(70, 90)
		
		# Create styled background
		background = ColorRect.new()
		background.size = size
		background.color = Color(0.1, 0.1, 0.1, 0.8)
		add_child(background)
		
		# Emoji display
		emoji_label = Label.new()
		emoji_label.text = info.get("emoji", "❓")
		emoji_label.size = Vector2(70, 30)
		emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		emoji_label.add_theme_font_size_override("font_size", 20)
		add_child(emoji_label)
		
		# Magnitude display
		magnitude_label = Label.new()
		magnitude_label.text = "0.00"
		magnitude_label.position = Vector2(0, 30)
		magnitude_label.size = Vector2(70, 20)
		magnitude_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		magnitude_label.add_theme_font_size_override("font_size", 10)
		add_child(magnitude_label)
		
		# Phase indicator (small rotating line)
		phase_indicator = Control.new()
		phase_indicator.position = Vector2(30, 55)
		phase_indicator.size = Vector2(10, 10)
		add_child(phase_indicator)
		
		# Magnitude bar
		magnitude_bar = ProgressBar.new()
		magnitude_bar.position = Vector2(10, 70)
		magnitude_bar.size = Vector2(50, 6)
		magnitude_bar.min_value = 0.0
		magnitude_bar.max_value = 1.0
		add_child(magnitude_bar)
		
		# Set visualization colors
		if vis_config.has("primary_color"):
			base_color = vis_config.primary_color
		
		# Create persistent tween
		current_tween = create_tween()
		current_tween.set_loops()
		current_tween.tween_callback(func(): pass)
	
	func update_values(magnitude: float, phase: float, real_part: float, imag_part: float):
		# Update text displays
		magnitude_label.text = "%.2f" % magnitude
		magnitude_bar.value = magnitude
		
		# Update visual styling
		var intensity = clamp(magnitude, 0.0, 1.0)
		var color = base_color.lerp(Color.WHITE, intensity * 0.3)
		
		# Add oscillation coloring
		if abs(imag_part) > 0.1:
			color = color.lerp(Color.CYAN, abs(imag_part) * 1.5)
		
		modulate = color
		
		# Update phase indicator rotation
		phase_indicator.rotation = phase
		
		# Scale based on magnitude
		var scale_target = Vector2(0.8 + magnitude * 0.4, 0.8 + magnitude * 0.4)
		
		# Smooth scaling animation
		if current_tween and current_tween.is_valid():
			current_tween.parallel().tween_property(self, "scale", scale_target, 0.2)

# Enhanced ConnectionLine with better positioning
class ConnectionLine extends Line2D:
	var from_component: int
	var to_component: int
	var strength: float
	var displays: Array[ComponentDisplay]
	var flow_time: float = 0.0
	
	func setup(from_comp: int, to_comp: int, line_strength: float, component_displays: Array[ComponentDisplay]):
		from_component = from_comp
		to_component = to_comp
		strength = line_strength
		displays = component_displays
		
		# Configure line appearance
		width = clamp(abs(strength) * 8.0, 2.0, 12.0)
		if strength > 0:
			default_color = Color.GREEN
		else:
			default_color = Color.RED
		
		default_color.a = clamp(abs(strength), 0.3, 0.7)
		
		# Update line position
		_update_line_position()
	
	func _update_line_position():
		if from_component < displays.size() and to_component < displays.size():
			var from_pos = displays[from_component].position + displays[from_component].size / 2
			var to_pos = displays[to_component].position + displays[to_component].size / 2
			
			clear_points()
			add_point(from_pos)
			add_point(to_pos)
	
	func update_flow_animation():
		flow_time += 0.05
		
		# Animated flow effect
		var pulse = sin(flow_time * 4.0) * 0.2 + 0.8
		modulate = Color.WHITE * pulse
		
		# Update line position in case displays moved
		_update_line_position()
