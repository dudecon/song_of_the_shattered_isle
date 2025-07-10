# scripts/core/QuantumConductor.gd
class_name QuantumConductor
extends Node

@export var time_scale: float = 1.0
@export var auto_evolution: bool = true
@export var debug_mode: bool = false

var quantum_core: DynamicalSystem
var current_icon: IconDefinition
var evolution_history: Array[PackedVector2Array] = []
var max_history_size: int = 100

# Performance tracking
var frame_count: int = 0
var total_evolution_time: float = 0.0
var last_fps_update: float = 0.0

# Signals for the quantum singularity
signal icon_loaded(icon_name: String)
signal evolution_step_completed(state: PackedVector2Array)
signal system_energy_changed(energy: float)
signal phase_coherence_changed(coherence: float)
signal critical_transition_detected(transition_type: String)

func _ready():
	_initialize_quantum_core()
	_load_default_icon()
	_setup_performance_monitoring()

func _physics_process(delta):
	if auto_evolution and quantum_core:
		var start_time = Time.get_time_dict_from_system()
		
		# Evolve the quantum core
		quantum_core.evolve(delta * time_scale)
		
		# Track evolution history
		_record_evolution_step()
		
		# Emit signals for system state
		evolution_step_completed.emit(quantum_core.get_state_snapshot())
		
		# Check for critical transitions
		_check_critical_transitions()
		
		# Performance tracking
		_update_performance_tracking(delta)
		
		# Debug output
		if debug_mode and frame_count % 60 == 0:
			_debug_output()

func _initialize_quantum_core():
	quantum_core = DynamicalSystem.new(7)
	quantum_core.state_evolved.connect(_on_state_evolved)
	
	if debug_mode:
		print("Quantum core initialized with dimension: ", quantum_core.dimension)

func _load_default_icon():
	# Load the Imperium as the default icon
	var imperium_icon = IconLibrary.create_imperium_icon()
	load_icon(imperium_icon)

func _setup_performance_monitoring():
	# Create a timer for regular performance updates
	var timer = Timer.new()
	timer.wait_time = 1.0  # Update every second
	timer.timeout.connect(_emit_performance_signals)
	timer.autostart = true
	add_child(timer)

func load_icon(icon: IconDefinition):
	if not icon:
		push_error("Cannot load null icon")
		return
	
	# Validate icon before loading
	var validation = icon.validate_icon_data()
	if not validation.valid:
		push_error("Icon validation failed: " + str(validation.issues))
		return
	
	current_icon = icon
	quantum_core.load_icon_configuration(icon)
	
	# Clear history when switching icons
	evolution_history.clear()
	
	# Emit signals
	icon_loaded.emit(icon.name)
	
	if debug_mode:
		print("Icon loaded: ", icon.name)
		print("Dimension: ", icon.dimension)
		print("Evolution rate: ", icon.evolution_rate)

func get_current_state() -> PackedVector2Array:
	if quantum_core:
		return quantum_core.get_state_snapshot()
	return PackedVector2Array()

func get_component_magnitude(index: int) -> float:
	if quantum_core:
		return quantum_core.get_magnitude(index)
	return 0.0

func get_component_phase(index: int) -> float:
	if quantum_core:
		return quantum_core.get_phase(index)
	return 0.0

func get_component_real(index: int) -> float:
	if quantum_core:
		return quantum_core.get_real(index)
	return 0.0

func get_component_imaginary(index: int) -> float:
	if quantum_core:
		return quantum_core.get_imaginary(index)
	return 0.0

func get_system_energy() -> float:
	if quantum_core:
		return quantum_core.get_system_energy()
	return 0.0

func get_phase_coherence() -> float:
	if quantum_core:
		return quantum_core.get_phase_coherence()
	return 0.0

func get_evolution_history() -> Array[PackedVector2Array]:
	return evolution_history.duplicate()

func get_dominant_component() -> Dictionary:
	if not quantum_core or not current_icon:
		return {}
	
	var state = quantum_core.get_state_snapshot()
	var max_magnitude = 0.0
	var dominant_index = 0
	
	for i in range(state.size()):
		var magnitude = state[i].length()
		if magnitude > max_magnitude:
			max_magnitude = magnitude
			dominant_index = i
	
	return {
		"index": dominant_index,
		"magnitude": max_magnitude,
		"emoji": current_icon.emoji_mapping.get(dominant_index, "❓"),
		"label": current_icon.parameter_labels[dominant_index] if dominant_index < current_icon.parameter_labels.size() else "Unknown"
	}

func pause_evolution():
	auto_evolution = false
	if debug_mode:
		print("Evolution paused")

func resume_evolution():
	auto_evolution = true
	if debug_mode:
		print("Evolution resumed")

func set_time_scale(scale: float):
	time_scale = clampf(scale, 0.0, 10.0)
	if debug_mode:
		print("Time scale set to: ", time_scale)

func reset_system():
	"""Reset the system to initial state"""
	if current_icon:
		quantum_core.load_icon_configuration(current_icon)
		evolution_history.clear()
		if debug_mode:
			print("System reset to initial state")

func add_perturbation(component: int, strength: float = 0.1):
	"""Add a perturbation to a specific component"""
	if quantum_core:
		var perturbation = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		quantum_core.add_perturbation(component, perturbation)
		if debug_mode:
			print("Perturbation added to component ", component, ": ", perturbation)

func modify_coupling(from_component: int, to_component: int, delta: float):
	"""Modify coupling between components"""
	if quantum_core:
		quantum_core.modify_matrix_element(to_component, from_component, delta)
		if debug_mode:
			print("Coupling modified: ", from_component, " -> ", to_component, " by ", delta)

func get_system_diagnostics() -> Dictionary:
	"""Get comprehensive system diagnostics"""
	var diagnostics = {
		"quantum_core_active": quantum_core != null,
		"current_icon": current_icon.name if current_icon else "None",
		"auto_evolution": auto_evolution,
		"time_scale": time_scale,
		"frame_count": frame_count,
		"evolution_history_size": evolution_history.size(),
		"system_energy": get_system_energy(),
		"phase_coherence": get_phase_coherence(),
		"dominant_component": get_dominant_component(),
		"performance": {
			"avg_evolution_time": total_evolution_time / max(frame_count, 1),
			"fps": Engine.get_frames_per_second()
		}
	}
	
	if current_icon:
		diagnostics["icon_info"] = {
			"dimension": current_icon.dimension,
			"evolution_rate": current_icon.evolution_rate,
			"oscillating_components": current_icon.get_oscillating_components().size(),
			"stable_components": current_icon.get_stable_components().size(),
			"coupling_strength": current_icon.get_matrix_coupling_strength()
		}
	
	return diagnostics

func _record_evolution_step():
	evolution_history.append(quantum_core.get_state_snapshot())
	
	# Limit history size for memory management
	while evolution_history.size() > max_history_size:
		evolution_history.pop_front()

func _check_critical_transitions():
	if evolution_history.size() < 10:  # Need more history
		return
	
	var current_energy = get_system_energy()
	var coherence = get_phase_coherence()
	
	# Only check every 60 frames to avoid spam
	if frame_count % 60 != 0:
		return
	
	# More restrictive thresholds
	if coherence > 0.95:  # Very high coherence only
		critical_transition_detected.emit("phase_lock")

func _update_performance_tracking(delta: float):
	frame_count += 1
	total_evolution_time += delta

func _emit_performance_signals():
	"""Emit performance-related signals"""
	system_energy_changed.emit(get_system_energy())
	phase_coherence_changed.emit(get_phase_coherence())

func _debug_output():
	"""Debug output for system state"""
	var diagnostics = get_system_diagnostics()
	print("=== QUANTUM CONDUCTOR DEBUG ===")
	print("Icon: ", diagnostics.current_icon)
	print("Energy: ", "%.3f" % diagnostics.system_energy)
	print("Coherence: ", "%.3f" % diagnostics.phase_coherence)
	print("Dominant: ", diagnostics.dominant_component.emoji, " ", diagnostics.dominant_component.label)
	print("FPS: ", diagnostics.performance.fps)
	print("===============================")

func _on_state_evolved(new_state: PackedVector2Array):
	# Handle state evolution events
	if debug_mode and frame_count % 120 == 0:
		print("State evolved - Energy: ", get_system_energy())

# Icon management functions
func load_icon_by_name(icon_name: String) -> bool:
	"""Load an icon by name from the library"""
	var icon = IconLibrary.get_icon_by_name(icon_name)
	if icon:
		load_icon(icon)
		return true
	return false

func get_available_icons() -> Array[IconDefinition]:
	"""Get all available icons from the library"""
	return IconLibrary.get_all_icons()

func create_icon_variant(mutation_strength: float = 0.1) -> IconDefinition:
	"""Create a variant of the current icon"""
	if current_icon:
		return current_icon.create_variant("Evolved", mutation_strength)
	return null

# Experimental features
func enable_debug_mode():
	debug_mode = true
	print("Debug mode enabled")

func disable_debug_mode():
	debug_mode = false

func get_component_connections(component: int) -> Array[Dictionary]:
	"""Get connections for a specific component"""
	if current_icon:
		return current_icon.get_dominant_connections(component)
	return []

func simulate_future_states(steps: int = 10) -> Array[PackedVector2Array]:
	"""Simulate future states without affecting the current system"""
	var future_states: Array[PackedVector2Array] = []
	
	if not quantum_core:
		return future_states
	
	# Create a temporary copy of the quantum core
	var temp_core = DynamicalSystem.new(quantum_core.dimension)
	temp_core.load_icon_configuration(current_icon)
	
	# Set the current state
	var current_state = quantum_core.get_state_snapshot()
	var temp_state: Array[Vector2] = []
	for vec in current_state:
		temp_state.append(vec)
	temp_core.state_vector = PackedVector2Array(temp_state)
	
	# Simulate future steps
	for i in range(steps):
		temp_core.evolve(1.0 / 60.0 * time_scale)  # Assume 60 FPS
		future_states.append(temp_core.get_state_snapshot())
	
	return future_states
