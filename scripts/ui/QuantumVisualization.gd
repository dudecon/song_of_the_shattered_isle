# scripts/ui/QuantumVisualization.gd
class_name QuantumVisualization
extends Control

@export var update_interval: float = 0.1
@export var animation_speed: float = 1.0
@export var show_connections: bool = true
@export var show_phases: bool = true
@export var auto_scale: bool = true

var conductor: QuantumConductor
var component_displays: Array[ComponentDisplay] = []
var connection_lines: Array[ConnectionLine] = []
var center_point: Vector2
var display_radius: float = 150.0
var setup_complete: bool = false
var last_update_time: float = 0.0

# Animation and visual state
var tween: Tween
var background_particle_system: GPUParticles2D
var energy_visualization: EnergyVisualization

func _ready():
	_setup_visual_elements()
	_find_conductor()
	
	# Create update timer
	var timer = Timer.new()
	timer.wait_time = update_interval
	timer.timeout.connect(_update_displays)
	timer.autostart = true
	add_child(timer)

func _setup_visual_elements():
	# Create tween for smooth animations
	tween = create_tween()
	
	# Create background particle system
	background_particle_system = GPUParticles2D.new()
	add_child(background_particle_system)
	_setup_background_particles()
	
	# Create energy visualization
	energy_visualization = EnergyVisualization.new()
	add_child(energy_visualization)

func _setup_background_particles():
	if background_particle_system:
		background_particle_system.emitting = true
		background_particle_system.amount = 50
		background_particle_system.lifetime = 5.0

func _find_conductor():
	# Look for conductor in parent hierarchy
	var parent = get_parent()
	while parent:
		conductor = parent.get_node_or_null("QuantumConductor")
		if conductor:
			print("QuantumVisualization found conductor: ", conductor.name)
			conductor.icon_loaded.connect(_on_icon_loaded)
			conductor.evolution_step_completed.connect(_on_evolution_step)
			conductor.system_energy_changed.connect(_on_system_energy_changed)
			conductor.phase_coherence_changed.connect(_on_phase_coherence_changed)
			conductor.critical_transition_detected.connect(_on_critical_transition)
			break
		parent = parent.get_parent()
	
	if not conductor:
		push_error("QuantumVisualization: No QuantumConductor found!")
		return
	
	_setup_component_displays()

func _setup_component_displays():
	if not conductor or not conductor.current_icon:
		return
	
	print("Setting up component displays for: ", conductor.current_icon.name)
	
	# Clear existing displays
	_clear_displays()
	
	var icon = conductor.current_icon
	center_point = size / 2
	
	# Adjust radius based on number of components
	display_radius = min(size.x, size.y) * 0.3
	if auto_scale:
		display_radius *= sqrt(7.0 / icon.dimension)  # Scale based on dimension
	
	# Create displays for each component
	for i in range(icon.dimension):
		var display = ComponentDisplay.new()
		var info = icon.get_component_info(i)
		display.setup(i, info, icon.visualization_config)
		add_child(display)
		component_displays.append(display)
	
	# Create connection lines if enabled
	if show_connections:
		_create_connection_lines()
	
	_arrange_displays()
	setup_complete = true
	
	print("Setup complete. Created ", component_displays.size(), " displays")

func _clear_displays():
	# Clear existing displays
	for display in component_displays:
		if display and is_instance_valid(display):
			display.queue_free()
	component_displays.clear()
	
	# Clear connection lines
	for line in connection_lines:
		if line and is_instance_valid(line):
			line.queue_free()
	connection_lines.clear()

func _create_connection_lines():
	if not conductor or not conductor.current_icon:
		return
	
	var icon = conductor.current_icon
	
	# Create connection lines for significant matrix elements
	for i in range(icon.dimension):
		var connections = icon.get_dominant_connections(i)
		for conn in connections:
			if conn.type == "outgoing" and abs(conn.strength) > 0.2:
				var line = ConnectionLine.new()
				line.setup(i, conn.target, conn.strength)
				add_child(line)
				connection_lines.append(line)

func _arrange_displays():
	if component_displays.size() == 0:
		return
	
	# Arrange displays in a circle
	for i in range(component_displays.size()):
		var angle = (i / float(component_displays.size())) * TAU
		var pos = center_point + Vector2(cos(angle), sin(angle)) * display_radius
		
		# Smooth animation to new position
		if tween and is_instance_valid(component_displays[i]):
			tween.tween_property(component_displays[i], "position", pos, 0.5)

func _update_displays():
	if not conductor or not setup_complete:
		return
	
	#var current_time = Time.get_time_dict_from_system().get("unix", 0)
	#if current_time - last_update_time < update_interval:
		#return
	#
	#last_update_time = current_time
	
	# Update each component display
	for i in range(component_displays.size()):
		if i < component_displays.size() and is_instance_valid(component_displays[i]):
			var magnitude = conductor.get_component_magnitude(i)
			var phase = conductor.get_component_phase(i)
			var real_part = conductor.get_component_real(i)
			var imag_part = conductor.get_component_imaginary(i)
			
			component_displays[i].update_values(magnitude, phase, real_part, imag_part)
	
	# Update connection lines
	_update_connection_lines()
	
	# Update energy visualization
	if energy_visualization:
		energy_visualization.update_energy(conductor.get_system_energy())

func _update_connection_lines():
	if not show_connections:
		return
	
	for line in connection_lines:
		if line and is_instance_valid(line):
			line.update_flow_animation()

func _on_icon_loaded(icon_name: String):
	print("QuantumVisualization: Icon loaded - ", icon_name)
	setup_complete = false
	_setup_component_displays()

func _on_evolution_step(state: PackedVector2Array):
	# Evolution step handled by timer-based updates
	pass

func _on_system_energy_changed(energy: float):
	# Update background particles based on energy
	if background_particle_system:
		background_particle_system.amount = int(20 + energy * 30)

func _on_phase_coherence_changed(coherence: float):
	# Update visual coherence effects
	modulate = Color.WHITE.lerp(Color.CYAN, coherence * 0.3)

func _on_critical_transition(transition_type: String):
	# Visual feedback for critical transitions
	match transition_type:
		"energy_spike":
			_flash_effect(Color.YELLOW)
		"phase_lock":
			_flash_effect(Color.CYAN)

func _flash_effect(color: Color):
	if tween:
		tween.kill()  # Stop any existing tween
	tween = create_tween()  # Create new tween
	var original_modulate = modulate
	tween.tween_property(self, "modulate", color, 0.1)
	tween.tween_property(self, "modulate", original_modulate, 0.3)

func set_visualization_mode(mode: String):
	match mode:
		"minimal":
			show_connections = false
			show_phases = false
		"standard":
			show_connections = true
			show_phases = true
		"connections_only":
			show_connections = true
			show_phases = false
		"phases_only":
			show_connections = false
			show_phases = true
	
	# Refresh display
	if setup_complete:
		_setup_component_displays()

func get_component_at_position(pos: Vector2) -> int:
	"""Get component index at screen position"""
	for i in range(component_displays.size()):
		if is_instance_valid(component_displays[i]):
			var display_pos = component_displays[i].position
			var display_size = component_displays[i].size
			var rect = Rect2(display_pos, display_size)
			if rect.has_point(pos):
				return i
	return -1

func highlight_component(component_index: int, highlight: bool = true):
	"""Highlight a specific component"""
	if component_index >= 0 and component_index < component_displays.size():
		if is_instance_valid(component_displays[component_index]):
			component_displays[component_index].set_highlighted(highlight)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var component = get_component_at_position(event.position)
			if component >= 0:
				_on_component_clicked(component)

func _on_component_clicked(component_index: int):
	"""Handle component click events"""
	if conductor:
		print("Component clicked: ", component_index)
		# Add a small perturbation to demonstrate interactivity
		conductor.add_perturbation(component_index, 0.05)
		
		# Highlight the component briefly
		highlight_component(component_index, true)
		if tween:
			tween.tween_callback(highlight_component.bind(component_index, false)).set_delay(0.5)

# Inner classes for visual components
class ComponentDisplay extends Control:
	var component_index: int
	var component_info: Dictionary
	var visualization_config: Dictionary
	
	var emoji_label: Label
	var magnitude_label: Label
	var phase_label: Label
	var magnitude_bar: ProgressBar
	var background: ColorRect
	var oscillation_indicator: Control
	
	var is_highlighted: bool = false
	var base_color: Color = Color.WHITE
	
	func setup(index: int, info: Dictionary, vis_config: Dictionary = {}):
		component_index = index
		component_info = info
		visualization_config = vis_config
		
		size = Vector2(80, 100)
		
		# Background
		background = ColorRect.new()
		background.color = Color(0.1, 0.1, 0.1, 0.8)
		background.size = size
		add_child(background)
		
		# Emoji
		emoji_label = Label.new()
		emoji_label.text = info.get("emoji", "❓")
		emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_label.position = Vector2(0, 5)
		emoji_label.size = Vector2(80, 25)
		emoji_label.add_theme_font_size_override("font_size", 18)
		add_child(emoji_label)
		
		# Magnitude
		magnitude_label = Label.new()
		magnitude_label.text = "0.00"
		magnitude_label.position = Vector2(0, 30)
		magnitude_label.size = Vector2(80, 15)
		magnitude_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		magnitude_label.add_theme_font_size_override("font_size", 10)
		add_child(magnitude_label)
		
		# Phase
		phase_label = Label.new()
		phase_label.text = "0.0°"
		phase_label.position = Vector2(0, 45)
		phase_label.size = Vector2(80, 15)
		phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		phase_label.add_theme_font_size_override("font_size", 9)
		add_child(phase_label)
		
		# Magnitude bar
		magnitude_bar = ProgressBar.new()
		magnitude_bar.position = Vector2(10, 65)
		magnitude_bar.size = Vector2(60, 8)
		magnitude_bar.min_value = 0.0
		magnitude_bar.max_value = 1.0
		add_child(magnitude_bar)
		
		# Oscillation indicator
		oscillation_indicator = Control.new()
		oscillation_indicator.position = Vector2(35, 80)
		oscillation_indicator.size = Vector2(10, 10)
		add_child(oscillation_indicator)
		
		# Set base color from visualization config
		if vis_config.has("primary_color"):
			base_color = vis_config.primary_color
		
		# Make interactive
		mouse_filter = Control.MOUSE_FILTER_PASS
		
		z_index = 1  # Make the whole component visible
	
	func update_values(magnitude: float, phase: float, real_part: float, imag_part: float):
		# Update magnitude
		magnitude_label.text = "%.2f" % magnitude
		magnitude_bar.value = magnitude
		
		# Update phase
		var phase_degrees = rad_to_deg(phase)
		phase_label.text = "%.1f°" % phase_degrees
		
		# Update visual appearance
		var intensity = magnitude
		var color = base_color.lerp(Color.WHITE, intensity * 0.5)
		
		# Add oscillation coloring
		if abs(imag_part) > 0.1:
			color = color.lerp(Color.CYAN, abs(imag_part) * 2.0)
		
		# Apply highlight
		if is_highlighted:
			color = color.lerp(Color.YELLOW, 0.7)
		
		modulate = color
		
		# Update oscillation indicator
		if abs(imag_part) > 0.1:
			oscillation_indicator.modulate = Color.CYAN
			# Animate oscillation
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(oscillation_indicator, "modulate:a", 0.3, 0.5)
			tween.tween_property(oscillation_indicator, "modulate:a", 1.0, 0.5)
		else:
			oscillation_indicator.modulate = Color.TRANSPARENT
		
		# Scale based on magnitude
		var scale_factor = 0.8 + (magnitude * 0.4)
		scale = Vector2(scale_factor, scale_factor)
	
	func set_highlighted(highlight: bool):
		is_highlighted = highlight
		if highlight:
			background.color = Color(0.3, 0.3, 0.2, 0.9)
		else:
			background.color = Color(0.1, 0.1, 0.1, 0.8)

class ConnectionLine extends Line2D:
	var from_component: int
	var to_component: int
	var strength: float
	var flow_animation_time: float = 0.0
	
	func setup(from_comp: int, to_comp: int, line_strength: float):
		from_component = from_comp
		to_component = to_comp
		strength = line_strength
		
		# Set line properties
		width = abs(strength) * 10.0 + 2.0
		if strength > 0:
			default_color = Color.GREEN
		else:
			default_color = Color.RED
		
		default_color.a = min(abs(strength), 0.8)
	
	func update_positions(from_pos: Vector2, to_pos: Vector2):
		clear_points()
		add_point(from_pos)
		add_point(to_pos)
	
	func update_flow_animation():
		flow_animation_time += 0.1
		# Animate flow direction with color pulsing
		var pulse = sin(flow_animation_time * 3.0) * 0.3 + 0.7
		modulate = Color.WHITE * pulse

class EnergyVisualization extends Control:
	var energy_level: float = 0.0
	var energy_particles: Array[EnergyParticle] = []
	var max_particles: int = 20
	
	func _ready():
		# Create energy particles
		for i in range(max_particles):
			var particle = EnergyParticle.new()
			add_child(particle)
			energy_particles.append(particle)
	
	func update_energy(energy: float):
		energy_level = energy
		
		# Update particle count based on energy
		var active_particles = int(energy * max_particles)
		
		for i in range(energy_particles.size()):
			if i < active_particles:
				energy_particles[i].activate(energy)
			else:
				energy_particles[i].deactivate()
	
	class EnergyParticle extends Control:
		var active: bool = false
		var velocity: Vector2
		var lifetime: float = 0.0
		var max_lifetime: float = 2.0
		var particle_color: Color = Color.WHITE
		
		func _ready():
			size = Vector2(4, 4)
			
		func _process(delta):
			if not active:
				return
			
			position += velocity * delta
			lifetime += delta
			
			if lifetime >= max_lifetime:
				_reset_particle()
			
			# Fade out over lifetime
			var alpha = 1.0 - (lifetime / max_lifetime)
			modulate = Color(particle_color.r, particle_color.g, particle_color.b, alpha)
		
		func activate(energy: float):
			if not active:
				active = true
				_reset_particle()
				particle_color = Color.WHITE.lerp(Color.YELLOW, energy)
		
		func deactivate():
			active = false
			modulate = Color.TRANSPARENT
		
		func _reset_particle():
			var parent_size = get_parent().size
			position = Vector2(
				randf_range(0, parent_size.x),
				randf_range(0, parent_size.y)
			)
			velocity = Vector2(
				randf_range(-50, 50),
				randf_range(-50, 50)
			)
			lifetime = 0.0
