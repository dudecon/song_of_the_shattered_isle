# scripts/ui/RTSInterface.gd
class_name RTSInterface
extends Control

# Core systems
var conductor: QuantumConductor
var visualization: QuantumVisualization
var ui_params: ResponsiveUI.UIParameters

# RTS State
var current_verb: String = ""
var selected_target: int = -1
var available_targets: Array[int] = []
var mathematical_targets: Array[MathematicalTarget] = []

# UI Components
var command_palette: CommandPalette
var target_overlay: TargetOverlay
var analysis_panel: AnalysisPanel
var status_crown: StatusCrown

# Signals
signal mathematical_operation_executed(verb: String, target: int, result: Dictionary)
signal target_selected(target_index: int)
signal system_analysis_requested(component_index: int)
signal verb_executed(verb: String, target: int)

func _ready():
	_setup_responsive_ui()
	_initialize_components()
	_find_quantum_systems()
	_setup_input_handling()

func _setup_responsive_ui():
	ui_params = ResponsiveUI.UIParameters.new(get_viewport().get_visible_rect().size)
	
	# Set up main layout
	size = get_viewport().get_visible_rect().size
	position = Vector2.ZERO

func _initialize_components():
	# Command palette (bottom)
	command_palette = CommandPalette.new()
	command_palette.verb_selected.connect(_on_verb_selected)
	command_palette.position = Vector2(0, size.y - 100)
	command_palette.size = Vector2(size.x, 100)
	add_child(command_palette)
	
	# Target overlay (center)
	target_overlay = TargetOverlay.new()
	target_overlay.target_clicked.connect(_on_target_clicked)
	target_overlay.position = Vector2(0, 0)
	target_overlay.size = size
	add_child(target_overlay)
	
	# Analysis panel (right)
	analysis_panel = AnalysisPanel.new()
	analysis_panel.position = Vector2(size.x - 300, 60)
	analysis_panel.size = Vector2(300, size.y - 160)
	add_child(analysis_panel)
	
	# Status crown (top)
	status_crown = StatusCrown.new()
	status_crown.position = Vector2(0, 0)
	status_crown.size = Vector2(size.x, 60)
	add_child(status_crown)

func _find_quantum_systems():
	# Find conductor
	conductor = get_node_or_null("../QuantumConductor")
	if not conductor:
		var search_paths = ["../../QuantumConductor", "../../../QuantumConductor"]
		for path in search_paths:
			conductor = get_node_or_null(path)
			if conductor:
				break
	
	# Find visualization
	visualization = get_node_or_null("../QuantumVisualization")
	if not visualization:
		var search_paths = ["../../QuantumVisualization", "../../../QuantumVisualization"]
		for path in search_paths:
			visualization = get_node_or_null(path)
			if visualization:
				break
	
	if conductor:
		_connect_conductor_signals()
		_setup_mathematical_targets()
		print("RTSInterface: Connected to quantum systems")
	else:
		push_error("RTSInterface: Could not find QuantumConductor!")

func _connect_conductor_signals():
	conductor.icon_loaded.connect(_on_icon_loaded)
	conductor.evolution_step_completed.connect(_on_evolution_step)
	conductor.system_energy_changed.connect(_on_system_energy_changed)
	conductor.phase_coherence_changed.connect(_on_phase_coherence_changed)

func _setup_mathematical_targets():
	if not conductor or not conductor.current_icon:
		return
	
	# Clear existing targets
	for target in mathematical_targets:
		if target and is_instance_valid(target):
			target.queue_free()
	mathematical_targets.clear()
	
	var icon = conductor.current_icon
	
	# Create targets for each component
	for i in range(icon.dimension):
		var target = MathematicalTarget.new()
		target.setup(i, icon.get_component_info(i))
		target.target_activated.connect(_on_target_activated)
		
		# Position around visualization center
		var angle = (i / float(icon.dimension)) * TAU
		var radius = 180 * ui_params.ui_scale
		var center = Vector2(size.x / 2, size.y / 2)
		target.position = center + Vector2(cos(angle), sin(angle)) * radius
		
		target_overlay.add_child(target)
		mathematical_targets.append(target)

func _setup_input_handling():
	# Handle keyboard shortcuts
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Q: _on_verb_selected("DEPLOY")
			KEY_E: _on_verb_selected("MODULATE")
			KEY_R: _on_verb_selected("TRANSFORM")
			KEY_F: _on_verb_selected("ANALYZE")
			KEY_C: _on_verb_selected("COUPLE")
			KEY_ESCAPE: _cancel_current_operation()
		
		# Number keys for target selection
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var target_num = event.keycode - KEY_1
			if target_num < mathematical_targets.size():
				_on_target_activated(target_num)

func _on_verb_selected(verb: String):
	current_verb = verb
	selected_target = -1
	
	# Calculate available targets for this verb
	available_targets = _get_available_targets_for_verb(verb)
	
	# Update UI state
	command_palette.set_active_verb(verb)
	target_overlay.highlight_available_targets(available_targets)
	analysis_panel.show_verb_description(verb)
	
	print("RTSInterface: Selected verb ", verb, " - Available targets: ", available_targets)

func _get_available_targets_for_verb(verb: String) -> Array[int]:
	if not conductor or not conductor.current_icon:
		return []
	
	var targets: Array[int] = []
	var icon = conductor.current_icon
	var state = conductor.get_current_state()
	
	match verb:
		"DEPLOY":
			# Can deploy to any component
			for i in range(icon.dimension):
				targets.append(i)
		"MODULATE":
			# Can modulate components with significant activity
			for i in range(min(state.size(), icon.dimension)):
				if state[i].length() > 0.1:
					targets.append(i)
		"TRANSFORM":
			# Can transform any component
			for i in range(icon.dimension):
				targets.append(i)
		"ANALYZE":
			# Can analyze any component
			for i in range(icon.dimension):
				targets.append(i)
		"COUPLE":
			# Can couple components with connections
			for i in range(icon.dimension):
				var connections = icon.get_dominant_connections(i)
				if connections.size() > 0:
					targets.append(i)
	
	return targets

func _on_target_activated(target_index: int):
	if target_index not in available_targets:
		return
	
	if selected_target == target_index and current_verb != "":
		# Second click - execute operation
		_execute_mathematical_operation()
	else:
		# First click - select target
		selected_target = target_index
		target_overlay.set_selected_target(target_index)
		analysis_panel.show_component_analysis(target_index)
		
		# Show operation preview
		var preview = _generate_operation_preview(current_verb, target_index)
		analysis_panel.show_operation_preview(preview)
		
		target_selected.emit(target_index)

func _execute_mathematical_operation():
	if current_verb == "" or selected_target == -1:
		return
	
	var result = {}
	
	match current_verb:
		"DEPLOY":
			result = _execute_deploy(selected_target)
		"MODULATE":
			result = _execute_modulate(selected_target)
		"TRANSFORM":
			result = _execute_transform(selected_target)
		"ANALYZE":
			result = _execute_analyze(selected_target)
		"COUPLE":
			result = _execute_couple(selected_target)
	
	# Emit signals
	mathematical_operation_executed.emit(current_verb, selected_target, result)
	verb_executed.emit(current_verb, selected_target)
	analysis_panel.show_operation_result(result)
	
	# Clear selection
	_cancel_current_operation()

func _execute_deploy(target: int) -> Dictionary:
	if conductor and conductor.quantum_core:
		var perturbation = Vector2(0.15, 0.05 * randf_range(-1, 1))
		conductor.add_perturbation(target, perturbation.length())
		return {
			"success": true,
			"operation": "Quantum nexus deployed",
			"target": target,
			"perturbation": perturbation
		}
	return {"success": false, "error": "No quantum core available"}

func _execute_modulate(target: int) -> Dictionary:
	if conductor and conductor.quantum_core:
		var delta = 0.02 * randf_range(0.5, 1.5)
		conductor.modify_coupling(target, target, delta)
		return {
			"success": true,
			"operation": "Matrix element modulated",
			"target": target,
			"delta": delta
		}
	return {"success": false, "error": "No quantum core available"}

func _execute_transform(target: int) -> Dictionary:
	if conductor and conductor.quantum_core:
		var state = conductor.get_current_state()
		if target < state.size():
			var component = state[target]
			var phase_shift = PI / 4 * randf_range(0.5, 2.0)
			var new_angle = component.angle() + phase_shift
			var magnitude = component.length()
			var new_component = Vector2(magnitude * cos(new_angle), magnitude * sin(new_angle))
			conductor.quantum_core.state_vector[target] = new_component
			return {
				"success": true,
				"operation": "Phase transformation applied",
				"target": target,
				"phase_shift": phase_shift
			}
	return {"success": false, "error": "Transform failed"}

func _execute_analyze(target: int) -> Dictionary:
	if conductor and conductor.current_icon:
		var magnitude = conductor.get_component_magnitude(target)
		var phase = conductor.get_component_phase(target)
		var real_part = conductor.get_component_real(target)
		var imag_part = conductor.get_component_imaginary(target)
		var connections = conductor.current_icon.get_dominant_connections(target)
		
		system_analysis_requested.emit(target)
		
		return {
			"success": true,
			"operation": "Deep analysis performed",
			"target": target,
			"magnitude": magnitude,
			"phase": phase,
			"real": real_part,
			"imaginary": imag_part,
			"connections": connections.size(),
			"behavior": "Oscillating" if abs(imag_part) > 0.1 else "Stable"
		}
	return {"success": false, "error": "Analysis failed"}

func _execute_couple(target: int) -> Dictionary:
	if conductor and conductor.quantum_core:
		var matrix = conductor.quantum_core.transformation_matrix
		if target < matrix.size():
			var next_target = (target + 1) % matrix.size()
			var coupling_strength = 0.03 * randf_range(0.8, 1.2)
			conductor.modify_coupling(target, next_target, coupling_strength)
			conductor.modify_coupling(next_target, target, coupling_strength)
			return {
				"success": true,
				"operation": "Bidirectional coupling created",
				"target": target,
				"coupled_with": next_target,
				"strength": coupling_strength
			}
	return {"success": false, "error": "Coupling failed"}

func _generate_operation_preview(verb: String, target: int) -> Dictionary:
	var preview = {"verb": verb, "target": target}
	
	if conductor and conductor.current_icon:
		var info = conductor.current_icon.get_component_info(target)
		var magnitude = conductor.get_component_magnitude(target)
		var phase = conductor.get_component_phase(target)
		
		preview["component"] = info
		preview["current_magnitude"] = magnitude
		preview["current_phase"] = phase
		
		# Add verb-specific preview
		match verb:
			"DEPLOY":
				preview["description"] = "Inject quantum energy into " + info.get("emoji", "❓") + " component"
				preview["expected_effect"] = "Magnitude increase by ~0.15"
			"MODULATE":
				preview["description"] = "Modify transformation matrix for " + info.get("emoji", "❓") + " component"
				preview["expected_effect"] = "Enhanced self-reinforcement"
			"TRANSFORM":
				preview["description"] = "Apply phase transformation to " + info.get("emoji", "❓") + " component"
				preview["expected_effect"] = "Phase shift by 45-90 degrees"
			"ANALYZE":
				preview["description"] = "Perform deep mathematical analysis of " + info.get("emoji", "❓") + " component"
				preview["expected_effect"] = "Detailed state report"
			"COUPLE":
				preview["description"] = "Create coupling between " + info.get("emoji", "❓") + " and adjacent components"
				preview["expected_effect"] = "Bidirectional influence"
	
	return preview

func _cancel_current_operation():
	current_verb = ""
	selected_target = -1
	available_targets.clear()
	
	command_palette.clear_active_verb()
	target_overlay.clear_highlights()
	analysis_panel.clear_displays()

func _on_target_clicked(target_index: int):
	_on_target_activated(target_index)

func _on_icon_loaded(icon_name: String):
	_setup_mathematical_targets()
	analysis_panel.show_icon_info(icon_name)

func _on_evolution_step(state: PackedVector2Array):
	# Update target appearances based on current state
	for i in range(mathematical_targets.size()):
		if i < state.size() and is_instance_valid(mathematical_targets[i]):
			mathematical_targets[i].update_from_state(state[i])

func _on_system_energy_changed(energy: float):
	status_crown.update_energy_display(energy)

func _on_phase_coherence_changed(coherence: float):
	status_crown.update_coherence_display(coherence)

# Enhanced UI Component Classes
class CommandPalette extends Control:
	var verb_buttons: Array[Button] = []
	var active_verb: String = ""
	
	signal verb_selected(verb: String)
	
	func _ready():
		_create_verb_buttons()
	
	func _create_verb_buttons():
		var verbs = ["DEPLOY", "MODULATE", "TRANSFORM", "ANALYZE", "COUPLE"]
		var keys = ["Q", "E", "R", "F", "C"]
		var button_width = size.x / verbs.size()
		
		for i in range(verbs.size()):
			var button = Button.new()
			button.text = keys[i] + " - " + verbs[i]
			button.size = Vector2(button_width - 10, 60)
			button.position = Vector2(i * button_width + 5, 20)
			button.pressed.connect(func(): verb_selected.emit(verbs[i]))
			add_child(button)
			verb_buttons.append(button)
	
	func set_active_verb(verb: String):
		active_verb = verb
		for button in verb_buttons:
			if verb in button.text:
				button.modulate = Color.CYAN
			else:
				button.modulate = Color.WHITE
	
	func clear_active_verb():
		active_verb = ""
		for button in verb_buttons:
			button.modulate = Color.WHITE

class TargetOverlay extends Control:
	var highlighted_targets: Array[int] = []
	var selected_target: int = -1
	
	signal target_clicked(target_index: int)
	
	func highlight_available_targets(targets: Array[int]):
		highlighted_targets = targets
		# Update visual highlighting
		for child in get_children():
			if child is MathematicalTarget:
				child.set_available(child.component_index in targets)
	
	func set_selected_target(target_index: int):
		selected_target = target_index
		for child in get_children():
			if child is MathematicalTarget:
				child.set_selected(child.component_index == target_index)
	
	func clear_highlights():
		highlighted_targets.clear()
		selected_target = -1
		for child in get_children():
			if child is MathematicalTarget:
				child.set_available(false)
				child.set_selected(false)

class AnalysisPanel extends Control:
	var title_label: Label
	var content_label: Label
	var preview_label: Label
	
	func _ready():
		_create_ui_elements()
	
	func _create_ui_elements():
		var background = ColorRect.new()
		background.color = Color(0.1, 0.1, 0.1, 0.8)
		background.size = size
		add_child(background)
		
		title_label = Label.new()
		title_label.text = "MATHEMATICAL ANALYSIS"
		title_label.position = Vector2(10, 10)
		title_label.size = Vector2(size.x - 20, 30)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(title_label)
		
		content_label = Label.new()
		content_label.position = Vector2(10, 50)
		content_label.size = Vector2(size.x - 20, size.y - 120)
		content_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(content_label)
		
		preview_label = Label.new()
		preview_label.position = Vector2(10, size.y - 60)
		preview_label.size = Vector2(size.x - 20, 50)
		preview_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(preview_label)
	
	func show_verb_description(verb: String):
		var descriptions = {
			"DEPLOY": "Deploy quantum energy nexus to selected component",
			"MODULATE": "Modify transformation matrix coefficients",
			"TRANSFORM": "Apply phase transformation to component",
			"ANALYZE": "Perform deep mathematical analysis",
			"COUPLE": "Create bidirectional coupling between components"
		}
		content_label.text = descriptions.get(verb, "Unknown operation")
	
	func show_component_analysis(target_index: int):
		# This would show detailed component analysis
		content_label.text = "Component " + str(target_index) + " analysis"
	
	func show_operation_preview(preview: Dictionary):
		preview_label.text = preview.get("description", "No preview available")
	
	func show_operation_result(result: Dictionary):
		if result.get("success", false):
			content_label.text = "SUCCESS: " + result.get("operation", "Unknown operation")
		else:
			content_label.text = "FAILED: " + result.get("error", "Unknown error")
	
	func show_icon_info(icon_name: String):
		content_label.text = "Icon loaded: " + icon_name
	
	func clear_displays():
		content_label.text = ""
		preview_label.text = ""

class StatusCrown extends Control:
	var energy_label: Label
	var coherence_label: Label
	
	func _ready():
		_create_ui_elements()
	
	func _create_ui_elements():
		var background = ColorRect.new()
		background.color = Color(0.05, 0.05, 0.15, 0.8)
		background.size = size
		add_child(background)
		
		energy_label = Label.new()
		energy_label.text = "Energy: 0.0"
		energy_label.position = Vector2(10, 10)
		energy_label.size = Vector2(200, 40)
		add_child(energy_label)
		
		coherence_label = Label.new()
		coherence_label.text = "Coherence: 0.0"
		coherence_label.position = Vector2(size.x - 210, 10)
		coherence_label.size = Vector2(200, 40)
		coherence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		add_child(coherence_label)
	
	func update_energy_display(energy: float):
		energy_label.text = "Energy: %.3f" % energy
	
	func update_coherence_display(coherence: float):
		coherence_label.text = "Coherence: %.3f" % coherence

class MathematicalTarget extends Control:
	var component_index: int
	var component_info: Dictionary
	var is_available: bool = false
	var is_selected: bool = false
	
	signal target_activated(target_index: int)
	
	func setup(index: int, info: Dictionary):
		component_index = index
		component_info = info
		size = Vector2(60, 60)
		
		# Create visual representation
		var background = ColorRect.new()
		background.color = Color(0.2, 0.2, 0.2, 0.8)
		background.size = size
		add_child(background)
		
		var emoji_label = Label.new()
		emoji_label.text = info.get("emoji", "❓")
		emoji_label.size = size
		emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(emoji_label)
	
	func set_available(available: bool):
		is_available = available
		modulate = Color.WHITE if available else Color.GRAY
	
	func set_selected(selected: bool):
		is_selected = selected
		modulate = Color.CYAN if selected else Color.WHITE
	
	func update_from_state(state: Vector2):
		# Update visual based on quantum state
		var intensity = state.length()
		modulate = Color.WHITE.lerp(Color.YELLOW, intensity * 0.5)
	
	func _gui_input(event):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				target_activated.emit(component_index)
