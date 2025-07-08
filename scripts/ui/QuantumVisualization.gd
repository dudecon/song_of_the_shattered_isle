# scripts/ui/QuantumVisualization.gd
class_name QuantumVisualization
extends Control

@export var update_interval: float = 0.1

var conductor: QuantumConductor
var component_displays: Array[ComponentDisplay] = []
var update_timer: float = 0.0
var setup_complete: bool = false

func _ready():
	# PULL-BASED: Actively find the mathematical center
	_find_conductor()
	
func _find_conductor():
	# Look for conductor in parent hierarchy
	var parent = get_parent()
	while parent:
		conductor = parent.get_node_or_null("QuantumConductor")
		if conductor:
			print("Found conductor: ", conductor.name)
			break
		parent = parent.get_parent()
	
	if not conductor:
		print("ERROR: No QuantumConductor found!")
		return
	
	# Force immediate setup
	_setup_component_displays()

func _process(delta):
	if not conductor:
		return
		
	update_timer += delta
	if update_timer >= update_interval:
		update_timer = 0.0
		
		# PULL-BASED: Always check if we need to setup displays
		if not setup_complete:
			_setup_component_displays()
		
		# PULL-BASED: Always update from current mathematical state
		_update_displays()

func _setup_component_displays():
	print("Setting up component displays...")
	
	# Clear existing displays
	for display in component_displays:
		if display:
			display.queue_free()
	component_displays.clear()
	
	if not conductor or not conductor.current_icon:
		print("No conductor or icon available for setup")
		return
	
	print("Creating ", conductor.current_icon.dimension, " component displays")
	
	# Create displays for each component
	for i in range(conductor.current_icon.dimension):
		var display = ComponentDisplay.new()
		var info = conductor.current_icon.get_component_info(i)
		display.setup(i, info)
		add_child(display)
		component_displays.append(display)
		print("Created display ", i, " with emoji: ", info.get("emoji", "❓"))
	
	_arrange_displays()
	setup_complete = true
	print("Setup complete. Display count: ", component_displays.size())

func _arrange_displays():
	if component_displays.size() == 0:
		return
		
	# Arrange displays in a circle
	var radius = 150
	var center = size / 2
	
	for i in range(component_displays.size()):
		var angle = (i / float(component_displays.size())) * TAU
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		component_displays[i].position = pos

func _update_displays():
	if not conductor or component_displays.size() == 0:
		return
	
	# PULL-BASED: Direct mathematical interrogation
	for i in range(component_displays.size()):
		var magnitude = conductor.get_component_magnitude(i)
		var phase = conductor.get_component_phase(i)
		component_displays[i].update_values(magnitude, phase)

class ComponentDisplay extends Control:
	var component_index: int
	var component_info: Dictionary
	var magnitude_label: Label
	var phase_label: Label
	var emoji_label: Label
	var magnitude_bar: ProgressBar
	
	func setup(index: int, info: Dictionary):
		component_index = index
		component_info = info
		
		size = Vector2(100, 80)
		
		# Create UI elements
		emoji_label = Label.new()
		emoji_label.text = info.get("emoji", "❓")
		emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_label.size = Vector2(100, 25)
		emoji_label.add_theme_font_size_override("font_size", 20)
		add_child(emoji_label)
		
		magnitude_label = Label.new()
		magnitude_label.text = "0.00"
		magnitude_label.position = Vector2(0, 25)
		magnitude_label.size = Vector2(100, 15)
		magnitude_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		magnitude_label.add_theme_font_size_override("font_size", 10)
		add_child(magnitude_label)
		
		magnitude_bar = ProgressBar.new()
		magnitude_bar.position = Vector2(10, 45)
		magnitude_bar.size = Vector2(80, 10)
		magnitude_bar.min_value = 0.0
		magnitude_bar.max_value = 1.0
		add_child(magnitude_bar)
		
		# Add a background for visibility
		var bg = ColorRect.new()
		bg.color = Color(0.1, 0.1, 0.1, 0.8)
		bg.size = size
		bg.z_index = -1
		add_child(bg)
	
	func update_values(magnitude: float, phase: float):
		magnitude_label.text = "%.2f" % magnitude
		magnitude_bar.value = magnitude
		
		# Color based on magnitude
		var color = Color.WHITE.lerp(Color.CYAN, magnitude)
		modulate = color
