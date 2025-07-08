# scripts/RTSQuantumMain.gd
class_name RTSQuantumMain
extends Control

@onready var rts_interface: RTSInterface = $RTSInterface
@onready var conductor: QuantumConductor = $QuantumConductor
@onready var visualization: QuantumVisualization = $RTSInterface/CanvasArea/MathVisualization

var current_icon_index: int = 0
var available_icons: Array[IconDefinition] = []

func _ready():
	_load_icons()
	_setup_connections()
	_load_default_icon()

func _load_icons():
	available_icons = IconLibrary.get_all_icons()

func _setup_connections():
	# Connect RTS interface to quantum system
	rts_interface.verb_executed.connect(_on_verb_executed)
	conductor.evolution_step_completed.connect(_on_evolution_step)
	conductor.icon_loaded.connect(_on_icon_loaded)
	
	# Connect visualization to conductor
	visualization.conductor = conductor

func _load_default_icon():
	if available_icons.size() > 0:
		conductor.load_icon(available_icons[0])

func _input(event):
	if event is InputEventKey and event.pressed:
		# Icon switching (Tab cycles through icons)
		if event.keycode == KEY_TAB:
			_cycle_icon()
		# Quick icon selection (1-4 for different icons)
		elif event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var icon_index = event.keycode - KEY_1
			if icon_index < available_icons.size():
				_switch_icon(icon_index)

func _cycle_icon():
	current_icon_index = (current_icon_index + 1) % available_icons.size()
	_switch_icon(current_icon_index)

func _switch_icon(index: int):
	current_icon_index = index
	conductor.load_icon(available_icons[index])

func _on_verb_executed(verb: String, target: int):
	print("Executing mathematical operation: ", verb, " on target ", target)
	
	# Execute the verb based on type
	match verb:
		"Q":  # Deploy
			_execute_deploy(target)
		"E":  # Modulate
			_execute_modulate(target)
		"R":  # Transform
			_execute_transform(target)
		"F":  # Observe
			_execute_observe(target)
		"C":  # Couple
			_execute_couple(target)

func _execute_deploy(target: int):
	# Deploy a nexus or mathematical operation
	if conductor and conductor.quantum_core:
		var state = conductor.get_current_state()
		if target <= state.size():
			# Inject energy into the target component
			var boost = Vector2(0.1, 0.05)  # Small energy boost
			conductor.quantum_core.state_vector[target - 1] += boost
			print("Deployed energy to component ", target)

func _execute_modulate(target: int):
	# Modulate the transformation matrix
	if conductor and conductor.quantum_core:
		var matrix = conductor.quantum_core.transformation_matrix
		if target <= matrix.size():
			# Slightly modify the self-coupling of the target
			matrix[target - 1][target - 1] += 0.01
			print("Modulated component ", target, " transformation")

func _execute_transform(target: int):
	# Apply a transformation to the target component
	if conductor and conductor.quantum_core:
		var state = conductor.get_current_state()
		if target <= state.size():
			# Apply a phase shift
			var component = state[target - 1]
			var angle = component.angle() + PI/4
			var magnitude = component.length()
			conductor.quantum_core.state_vector[target - 1] = Vector2(
				magnitude * cos(angle),
				magnitude * sin(angle)
			)
			print("Transformed component ", target, " phase")

func _execute_observe(target: int):
	# Observe detailed state of target component
	if conductor and conductor.quantum_core:
		var state = conductor.get_current_state()
		if target <= state.size():
			var component = state[target - 1]
			var magnitude = component.length()
			var phase = component.angle()
			
			# Update detail panel with observation
			var detail_text = """COMPONENT %d OBSERVATION:
Magnitude: %.3f
Phase: %.3f radians (%.1f degrees)
Real: %.3f
Imaginary: %.3f
Energy: %.3f

Current oscillations: %s
Coupling strength: %s""" % [
				target,
				magnitude,
				phase,
				phase * 180.0 / PI,
				component.x,
				component.y,
				magnitude * magnitude,
				"Active" if abs(component.y) > 0.1 else "Stable",
				"High" if magnitude > 0.5 else "Low"
			]
			
			rts_interface.get_node("DetailPanel/DetailContent").text = detail_text
			print("Observed component ", target, ": mag=", magnitude, " phase=", phase)

func _execute_couple(target: int):
	# Create coupling between components
	if conductor and conductor.quantum_core:
		var matrix = conductor.quantum_core.transformation_matrix
		if target < matrix.size():
			# Create coupling with adjacent component
			var next_target = (target % matrix.size())
			matrix[target - 1][next_target] += 0.05
			matrix[next_target][target - 1] += 0.05
			print("Coupled component ", target, " with component ", next_target + 1)

func _on_evolution_step(state: Array[Vector2]):
	# Update RTS interface with new state
	pass

func _on_icon_loaded(icon_name: String):
	# Update numbered targets based on new icon
	_update_numbered_targets()

func _update_numbered_targets():
	# Update the numbered targets to match the current icon's components
	if conductor and conductor.current_icon:
		var icon = conductor.current_icon
		var numbered_targets = rts_interface.numbered_targets
		
		# Position targets based on icon components
		for i in range(min(numbered_targets.size(), icon.dimension)):
			var target = numbered_targets[i]
			if target:
				# Position in a circle around the math visualization
				var angle = (i / float(icon.dimension)) * TAU
				var radius = 100
				var center = Vector2(200, 150)  # Center of canvas area
				target.position = center + Vector2(cos(angle), sin(angle)) * radius
				
				# Update target with icon information
				if i < icon.emoji_mapping.size():
					var emoji = icon.emoji_mapping.get(i, "❓")
					target.number_label.text = emoji
