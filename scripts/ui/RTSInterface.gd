# scripts/ui/RTSInterface.gd
class_name RTSInterface
extends Control

# UI Components
@onready var resource_crown: Control = $ResourceCrown
@onready var verb_palette: Control = $VerbPalette
@onready var detail_panel: Control = $DetailPanel
@onready var canvas_area: Control = $CanvasArea
@onready var context_popup: Control = $ContextPopup
@onready var math_visualization: QuantumVisualization = $CanvasArea/MathVisualization

# Resource display (using patterns from EnhancedMain)
@onready var quantum_energy_label: Label = $ResourceCrown/QuantumEnergy
@onready var phase_coherence_label: Label = $ResourceCrown/PhaseCoherence
@onready var current_icon_label: Label = $ResourceCrown/CurrentIcon
@onready var system_status_label: Label = $ResourceCrown/SystemStatus

# Verb buttons
@onready var q_button: Button = $VerbPalette/QButton
@onready var e_button: Button = $VerbPalette/EButton
@onready var r_button: Button = $VerbPalette/RButton
@onready var f_button: Button = $VerbPalette/FButton
@onready var c_button: Button = $VerbPalette/CButton

# Detail panel elements
@onready var detail_title: Label = $DetailPanel/DetailTitle
@onready var detail_content: Label = $DetailPanel/DetailContent
@onready var mathematical_analysis: Label = $DetailPanel/MathematicalAnalysis

# Context popup elements
@onready var context_title: Label = $ContextPopup/Panel/VBox/Title
@onready var context_description: Label = $ContextPopup/Panel/VBox/Description
@onready var context_confirm: Button = $ContextPopup/Panel/VBox/ConfirmButton

# State management
var current_verb: String = ""
var selected_target: int = -1
var available_targets: Array[int] = []
var numbered_targets: Array[NumberedTarget] = []

# Connection to quantum system
var conductor: QuantumConductor
var performance_monitor: PerformanceMonitor

# Icon management
var current_icon_index: int = 0
var available_icons: Array[IconDefinition] = []

signal verb_executed(verb: String, target: int)
signal component_selected(component_index: int)

func _ready():
	_load_available_icons()
	_setup_components()
	_setup_performance_monitoring()

func _load_available_icons():
	available_icons = IconLibrary.get_all_icons()

func _setup_components():
	_setup_verb_buttons()
	_setup_context_popup()
	_find_conductor()
	_create_numbered_targets()

func _setup_verb_buttons():
	# Connect verb buttons with enhanced feedback
	q_button.pressed.connect(_on_verb_selected.bind("DEPLOY"))
	e_button.pressed.connect(_on_verb_selected.bind("MODULATE"))
	r_button.pressed.connect(_on_verb_selected.bind("TRANSFORM"))
	f_button.pressed.connect(_on_verb_selected.bind("OBSERVE"))
	c_button.pressed.connect(_on_verb_selected.bind("COUPLE"))
	
	# Set button text with descriptions
	q_button.text = "Q - Deploy Nexus"
	e_button.text = "E - Modulate Matrix"
	r_button.text = "R - Transform Reality"
	f_button.text = "F - Observe State"
	c_button.text = "C - Couple Components"
	
	# Add tooltips (using the pattern from your enhanced system)
	q_button.tooltip_text = "Deploy quantum nexus to sample coordinates"
	e_button.tooltip_text = "Modulate transformation matrix elements"
	r_button.tooltip_text = "Apply reality transformation to components"
	f_button.tooltip_text = "Observe detailed mathematical state"
	c_button.tooltip_text = "Create coupling between components"

func _setup_context_popup():
	context_popup.visible = false
	context_confirm.pressed.connect(_on_context_confirmed)

func _find_conductor():
	# Enhanced conductor finding with error handling
	conductor = get_node_or_null("../QuantumConductor")
	if not conductor:
		# Try multiple paths
		var possible_paths = [
			"../QuantumConductor",
			"../../QuantumConductor", 
			"../../../QuantumConductor"
		]
		
		for path in possible_paths:
			conductor = get_node_or_null(path)
			if conductor:
				break
	
	if conductor:
		_connect_conductor_signals()
		print("Enhanced RTS: Connected to QuantumConductor")
	else:
		push_error("Enhanced RTS: Could not find QuantumConductor!")

func _connect_conductor_signals():
	# Using the enhanced signal system from your project
	conductor.icon_loaded.connect(_on_icon_loaded)
	conductor.evolution_step_completed.connect(_on_evolution_step)
	conductor.system_energy_changed.connect(_on_system_energy_changed)
	conductor.phase_coherence_changed.connect(_on_phase_coherence_changed)
	conductor.critical_transition_detected.connect(_on_critical_transition)

func _setup_performance_monitoring():
	# Using the performance monitoring pattern from EnhancedMain
	performance_monitor = PerformanceMonitor.new()
	add_child(performance_monitor)
	
	# Create update timer
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_update_displays)
	timer.autostart = true
	add_child(timer)

func _create_numbered_targets():
	# Enhanced target creation with better positioning
	if not conductor or not conductor.current_icon:
		return
	
	var icon = conductor.current_icon
	var center = Vector2(300, 200)  # Center of canvas area
	var radius = 120
	
	# Clear existing targets
	for target in numbered_targets:
		if target and is_instance_valid(target):
			target.queue_free()
	numbered_targets.clear()
	
	# Create targets based on icon dimension
	for i in range(icon.dimension):
		var target = NumberedTarget.new()
		target.target_number = i + 1
		
		# Position in circle around center
		var angle = (i / float(icon.dimension)) * TAU
		target.position = center + Vector2(cos(angle), sin(angle)) * radius
		
		# Set up with icon information
		var emoji = icon.emoji_mapping.get(i, "❓")
		target.number_label.text = emoji
		
		target.target_selected.connect(_on_target_selected)
		canvas_area.add_child(target)
		numbered_targets.append(target)

func _input(event):
	if event is InputEventKey and event.pressed:
		# Enhanced input handling
		match event.keycode:
			KEY_Q: _on_verb_selected("DEPLOY")
			KEY_E: _on_verb_selected("MODULATE")
			KEY_R: _on_verb_selected("TRANSFORM")
			KEY_F: _on_verb_selected("OBSERVE")
			KEY_C: _on_verb_selected("COUPLE")
			KEY_ESCAPE: _cancel_selection()
			KEY_TAB: _cycle_icon()
		
		# Number hotkeys for target selection
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var target_num = event.keycode - KEY_1 + 1
			if target_num in available_targets:
				_on_target_selected(target_num)
		
		# Icon switching hotkeys
		if event.keycode >= KEY_F1 and event.keycode <= KEY_F4:
			var icon_index = event.keycode - KEY_F1
			if icon_index < available_icons.size():
				_switch_icon(icon_index)

func _cycle_icon():
	current_icon_index = (current_icon_index + 1) % available_icons.size()
	_switch_icon(current_icon_index)

func _switch_icon(index: int):
	current_icon_index = index
	conductor.load_icon(available_icons[index])

func _on_verb_selected(verb: String):
	current_verb = verb
	selected_target = -1
	
	# Enhanced target availability logic
	available_targets = _get_available_targets_for_verb(verb)
	
	# Update visual state with animations
	_update_verb_button_states()
	_update_target_highlights()
	
	# Clear detail panel
	_clear_detail_panel()
	
	print("Enhanced RTS: Selected verb ", verb, " - Available targets: ", available_targets)

func _get_available_targets_for_verb(verb: String) -> Array[int]:
	if not conductor or not conductor.current_icon:
		return []
	
	var icon = conductor.current_icon
	var targets: Array[int] = []
	
	match verb:
		"DEPLOY":
			# Can deploy to any component
			for i in range(icon.dimension):
				targets.append(i + 1)
		"MODULATE":
			# Can modulate any component with significant magnitude
			var state = conductor.get_current_state()
			for i in range(min(state.size(), icon.dimension)):
				if state[i].length() > 0.1:
					targets.append(i + 1)
		"TRANSFORM":
			# Can transform any component
			for i in range(icon.dimension):
				targets.append(i + 1)
		"OBSERVE":
			# Can observe any component
			for i in range(icon.dimension):
				targets.append(i + 1)
		"COUPLE":
			# Can couple components with existing connections
			for i in range(icon.dimension):
				var connections = icon.get_dominant_connections(i)
				if connections.size() > 0:
					targets.append(i + 1)
	
	return targets

func _update_verb_button_states():
	# Reset all buttons
	for button in [q_button, e_button, r_button, f_button, c_button]:
		button.modulate = Color.WHITE
		button.flat = false
	
	# Highlight selected verb with animation
	var selected_button: Button
	match current_verb:
		"DEPLOY": selected_button = q_button
		"MODULATE": selected_button = e_button
		"TRANSFORM": selected_button = r_button
		"OBSERVE": selected_button = f_button
		"COUPLE": selected_button = c_button
	
	if selected_button:
		selected_button.modulate = Color.CYAN
		selected_button.flat = true

func _update_target_highlights():
	# Update all numbered targets with smooth transitions
	for target in numbered_targets:
		if target.target_number in available_targets:
			target.set_highlighted(true)
		else:
			target.set_highlighted(false)

func _on_target_selected(target_num: int):
	if target_num not in available_targets:
		return
	
	if selected_target == target_num:
		# Second click - confirm action
		_execute_verb_on_target()
	else:
		# First click - show enhanced context
		selected_target = target_num
		_show_enhanced_context_popup()
		_update_detail_panel()

func _show_enhanced_context_popup():
	var verb_name = _get_verb_name(current_verb)
	var target_info = _get_target_info(selected_target)
	
	context_title.text = "%s → %s" % [verb_name, target_info.name]
	context_description.text = _get_enhanced_action_description(current_verb, selected_target)
	context_confirm.text = "Click %s again to confirm" % target_info.emoji
	
	# Position popup intelligently
	var target_position = _get_target_screen_position(selected_target)
	context_popup.position = target_position + Vector2(70, -50)
	context_popup.visible = true

func _get_target_info(target: int) -> Dictionary:
	var info = {"name": "Component %d" % target, "emoji": str(target)}
	
	if conductor and conductor.current_icon:
		var icon = conductor.current_icon
		if target <= icon.dimension:
			var emoji = icon.emoji_mapping.get(target - 1, "❓")
			var label = ""
			if target - 1 < icon.parameter_labels.size():
				label = icon.parameter_labels[target - 1]
			info = {"name": "%s %s" % [emoji, label], "emoji": emoji}
	
	return info

func _get_enhanced_action_description(verb: String, target: int) -> String:
	var target_info = _get_target_info(target)
	var current_state = ""
	
	if conductor:
		var magnitude = conductor.get_component_magnitude(target - 1)
		var phase = conductor.get_component_phase(target - 1)
		current_state = "\nCurrent: Mag=%.3f, Phase=%.1f°" % [magnitude, phase * 180.0 / PI]
	
	match verb:
		"DEPLOY":
			return "Deploy quantum nexus to sample %s coordinates and inject energy%s" % [target_info.name, current_state]
		"MODULATE":
			return "Modulate transformation matrix affecting %s component%s" % [target_info.name, current_state]
		"TRANSFORM":
			return "Apply phase transformation to %s component%s" % [target_info.name, current_state]
		"OBSERVE":
			return "Observe detailed mathematical state of %s%s" % [target_info.name, current_state]
		"COUPLE":
			return "Create coupling between %s and adjacent components%s" % [target_info.name, current_state]
		_:
			return "Execute %s on %s%s" % [verb, target_info.name, current_state]

func _get_target_screen_position(target: int) -> Vector2:
	if target <= numbered_targets.size():
		return numbered_targets[target - 1].global_position
	return Vector2.ZERO

func _update_detail_panel():
	if not conductor or selected_target == -1:
		return
	
	var target_info = _get_target_info(selected_target)
	var component_idx = selected_target - 1
	
	detail_title.text = "COMPONENT ANALYSIS"
	
	# Get comprehensive component information
	var magnitude = conductor.get_component_magnitude(component_idx)
	var phase = conductor.get_component_phase(component_idx)
	var real_part = conductor.get_component_real(component_idx)
	var imag_part = conductor.get_component_imaginary(component_idx)
	
	detail_content.text = """TARGET: %s
Index: %d
Magnitude: %.4f
Phase: %.4f rad (%.1f°)
Real: %.4f
Imaginary: %.4f
Energy: %.4f

Status: %s
Coupling: %s""" % [
		target_info.name,
		selected_target,
		magnitude,
		phase,
		phase * 180.0 / PI,
		real_part,
		imag_part,
		magnitude * magnitude,
		"Oscillating" if abs(imag_part) > 0.1 else "Stable",
		"Strong" if magnitude > 0.5 else "Weak"
	]
	
	# Add mathematical analysis
	mathematical_analysis.text = _analyze_component_behavior(component_idx)
	
	# Emit signal for other systems
	component_selected.emit(component_idx)

func _analyze_component_behavior(component_idx: int) -> String:
	if not conductor or not conductor.current_icon:
		return "No analysis available"
	
	var behaviors = []
	var icon = conductor.current_icon
	
	# Get connections for this component
	var connections = icon.get_dominant_connections(component_idx)
	
	if connections.size() > 0:
		behaviors.append("CONNECTIONS:")
		for conn in connections.slice(0, 3):  # Show top 3 connections
			var type_symbol = "→" if conn.type == "outgoing" else "←"
			behaviors.append("  %s %s %.3f" % [type_symbol, conn.get("target_emoji", "❓"), conn.strength])
	
	# Add emergent behavior analysis
	var magnitude = conductor.get_component_magnitude(component_idx)
	if magnitude > 0.7:
		behaviors.append("HIGH ENERGY STATE")
	elif magnitude < 0.2:
		behaviors.append("LOW ENERGY STATE")
	
	var imag_part = conductor.get_component_imaginary(component_idx)
	if abs(imag_part) > 0.1:
		behaviors.append("OSCILLATORY BEHAVIOR")
	
	return behaviors.join("\n") if behaviors.size() > 0 else "Stable component"

func _clear_detail_panel():
	detail_title.text = "SYSTEM OVERVIEW"
	detail_content.text = "Select a component to view detailed analysis..."
	mathematical_analysis.text = ""

func _execute_verb_on_target():
	if current_verb == "" or selected_target == -1:
		return
	
	print("Enhanced RTS: Executing ", current_verb, " on target ", selected_target)
	
	# Execute enhanced mathematical operations
	match current_verb:
		"DEPLOY": _execute_enhanced_deploy(selected_target)
		"MODULATE": _execute_enhanced_modulate(selected_target)
		"TRANSFORM": _execute_enhanced_transform(selected_target)
		"OBSERVE": _execute_enhanced_observe(selected_target)
		"COUPLE": _execute_enhanced_couple(selected_target)
	
	# Emit signal for other systems
	verb_executed.emit(current_verb, selected_target)
	
	# Clear selection with animation
	_cancel_selection()

func _execute_enhanced_deploy(target: int):
	if conductor and conductor.quantum_core:
		var component_idx = target - 1
		var boost = Vector2(0.15, 0.05)  # Enhanced energy boost
		conductor.add_perturbation(component_idx, boost)
		print("Enhanced RTS: Deployed nexus to component ", target)

func _execute_enhanced_modulate(target: int):
	if conductor and conductor.quantum_core:
		var component_idx = target - 1
		conductor.modify_matrix_element(component_idx, component_idx, 0.02)
		print("Enhanced RTS: Modulated component ", target, " self-coupling")

func _execute_enhanced_transform(target: int):
	if conductor and conductor.quantum_core:
		var component_idx = target - 1
		var state = conductor.get_current_state()
		if component_idx < state.size():
			var component = state[component_idx]
			var new_angle = component.angle() + PI/6  # 30 degree phase shift
			var magnitude = component.length()
			var new_component = Vector2(magnitude * cos(new_angle), magnitude * sin(new_angle))
			conductor.quantum_core.state_vector[component_idx] = new_component
			print("Enhanced RTS: Transformed component ", target, " phase")

func _execute_enhanced_observe(target: int):
	# Enhanced observation updates the detail panel
	_update_detail_panel()
	print("Enhanced RTS: Observed component ", target, " in detail")

func _execute_enhanced_couple(target: int):
	if conductor and conductor.quantum_core:
		var component_idx = target - 1
		var matrix = conductor.quantum_core.transformation_matrix
		if component_idx < matrix.size():
			# Create bidirectional coupling with next component
			var next_idx = (component_idx + 1) % matrix.size()
			conductor.modify_matrix_element(component_idx, next_idx, 0.05)
			conductor.modify_matrix_element(next_idx, component_idx, 0.05)
			print("Enhanced RTS: Coupled component ", target, " with component ", next_idx + 1)

func _cancel_selection():
	current_verb = ""
	selected_target = -1
	available_targets.clear()
	
	context_popup.visible = false
	_update_verb_button_states()
	_update_target_highlights()
	_clear_detail_panel()

func _get_verb_name(verb: String) -> String:
	match verb:
		"DEPLOY": return "Deploy Nexus"
		"MODULATE": return "Modulate Matrix"
		"TRANSFORM": return "Transform Reality"
		"OBSERVE": return "Observe State"
		"COUPLE": return "Couple Components"
		_: return "Unknown"

# Signal handlers using enhanced patterns
func _on_icon_loaded(icon_name: String):
	print("Enhanced RTS: Icon loaded - ", icon_name)
	_create_numbered_targets()
	_update_displays()

func _on_evolution_step(state: PackedVector2Array):
	# Update handled by timer
	pass

func _on_system_energy_changed(energy: float):
	quantum_energy_label.text = "Energy: %.3f" % energy

func _on_phase_coherence_changed(coherence: float):
	phase_coherence_label.text = "Coherence: %.3f" % coherence

func _on_critical_transition(transition_type: String):
	system_status_label.text = "⚠️ %s" % transition_type.to_upper()
	
	# Flash effect for critical transitions
	var original_color = system_status_label.modulate
	system_status_label.modulate = Color.YELLOW
	var tween = create_tween()
	tween.tween_property(system_status_label, "modulate", original_color, 1.0)

func _on_context_confirmed():
	_execute_verb_on_target()

func _update_displays():
	if not conductor:
		return
	
	# Update resource crown
	var diagnostics = conductor.get_system_diagnostics()
	
	if conductor.current_icon:
		var emoji = conductor.current_icon.emoji_mapping.get(0, "🔹")
		current_icon_label.text = "%s %s" % [emoji, conductor.current_icon.name]
	
	system_status_label.text = "Running" if conductor.auto_evolution else "Paused"
	
	# Update mathematical visualization integration
	if math_visualization:
		math_visualization.conductor = conductor

# Performance monitoring class (simplified from your system)
class PerformanceMonitor extends Node:
	var statistics: Dictionary = {}
	
	func get_statistics() -> Dictionary:
		return {
			"fps": Engine.get_frames_per_second(),
			"memory_mb": OS.get_static_memory_peak_usage() / 1024.0 / 1024.0
		}
