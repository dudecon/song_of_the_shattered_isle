# scripts/EnhancedMain.gd
class_name EnhancedMain
extends Control

@onready var conductor: QuantumConductor = $QuantumConductor
@onready var visualization: QuantumVisualization = $QuantumVisualization
@onready var icon_switcher: IconSwitcher = $IconSwitcher
@onready var time_slider: HSlider = $UI/Controls/TimeSlider
@onready var pause_button: Button = $UI/Controls/PauseButton
@onready var reset_button: Button = $UI/Controls/ResetButton
@onready var status_label: Label = $UI/Controls/StatusLabel
@onready var mathematical_info: Label = $UI/Controls/MathematicalInfo
@onready var debug_panel: Control = $UI/DebugPanel
@onready var debug_label: Label = $UI/DebugPanel/DebugLabel

var evolution_time: float = 0.0
var is_debug_visible: bool = false

# Game state
var game_session: GameSession
var performance_monitor: PerformanceMonitor

func _ready():
	_initialize_game_session()
	_setup_connections()
	_setup_ui()
	_start_monitoring()
	_setup_debug_panel()

func _initialize_game_session():
	game_session = GameSession.new()
	performance_monitor = PerformanceMonitor.new()
	add_child(performance_monitor)

func _setup_connections():
	# Connect conductor signals
	if conductor:
		conductor.icon_loaded.connect(_on_icon_loaded)
		conductor.evolution_step_completed.connect(_on_evolution_step)
		conductor.system_energy_changed.connect(_on_system_energy_changed)
		conductor.phase_coherence_changed.connect(_on_phase_coherence_changed)
		conductor.critical_transition_detected.connect(_on_critical_transition)
	
	# Connect icon switcher
	if icon_switcher:
		icon_switcher.icon_switched.connect(_on_icon_switched)
	
	# Connect UI controls
	if time_slider:
		time_slider.value_changed.connect(_on_time_scale_changed)
		time_slider.value = 1.0
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

func _setup_ui():
	# Set initial UI state
	if time_slider:
		time_slider.value = 1.0
	if pause_button:
		pause_button.text = "Pause Evolution"
	if reset_button:
		reset_button.text = "Reset System"
	
	# Setup initial labels
	_update_mathematical_display()

func _setup_debug_panel():
	if debug_panel:
		debug_panel.visible = is_debug_visible
		
		# Create debug toggle button
		var debug_toggle = Button.new()
		debug_toggle.text = "Debug"
		debug_toggle.size = Vector2(60, 30)
		debug_toggle.position = Vector2(10, 10)
		debug_toggle.pressed.connect(_toggle_debug_panel)
		add_child(debug_toggle)

func _start_monitoring():
	# Create update timer
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_update_displays)
	timer.autostart = true
	add_child(timer)
	
	# Create performance timer
	var perf_timer = Timer.new()
	perf_timer.wait_time = 1.0
	perf_timer.timeout.connect(_update_performance_display)
	perf_timer.autostart = true
	add_child(perf_timer)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				_on_pause_pressed()
			KEY_R:
				if Input.is_key_pressed(KEY_CTRL):
					_on_reset_pressed()
			KEY_LEFT:
				if time_slider:
					time_slider.value = max(0.0, time_slider.value - 0.1)
					_on_time_scale_changed(time_slider.value)
			KEY_RIGHT:
				if time_slider:
					time_slider.value = min(3.0, time_slider.value + 0.1)
					_on_time_scale_changed(time_slider.value)
			KEY_F1:
				_toggle_debug_panel()
			KEY_F2:
				_save_system_state()
			KEY_F3:
				_load_system_state()
			KEY_P:
				_add_random_perturbation()
			KEY_ESCAPE:
				_show_quit_dialog()

func _on_icon_loaded(icon_name: String):
	print("Main: Icon loaded - ", icon_name)
	game_session.record_icon_change(icon_name)
	_update_mathematical_display()

func _on_icon_switched(icon_name: String):
	print("Main: Icon switched to - ", icon_name)
	evolution_time = 0.0  # Reset evolution timer
	game_session.record_icon_change(icon_name)
	_update_mathematical_display()

func _on_evolution_step(state: PackedVector2Array):
	evolution_time += get_process_delta_time()
	game_session.record_evolution_step(state)

func _on_system_energy_changed(energy: float):
	game_session.record_energy_change(energy)

func _on_phase_coherence_changed(coherence: float):
	game_session.record_coherence_change(coherence)

func _on_critical_transition(transition_type: String):
	print("Critical transition detected: ", transition_type)
	game_session.record_critical_event(transition_type)
	_show_transition_notification(transition_type)

func _on_time_scale_changed(value: float):
	if conductor:
		conductor.set_time_scale(value)
	var time_label = get_node_or_null("UI/Controls/TimeLabel")
	if time_label:
		time_label.text = "Time Scale: %.1f" % value

func _on_pause_pressed():
	if conductor:
		if conductor.auto_evolution:
			conductor.pause_evolution()
			pause_button.text = "Resume Evolution"
		else:
			conductor.resume_evolution()
			pause_button.text = "Pause Evolution"

func _on_reset_pressed():
	if conductor:
		conductor.reset_system()
		evolution_time = 0.0
		game_session.record_system_reset()
		print("System reset to initial state")

func _update_displays():
	_update_mathematical_display()
	_update_status_display()
	if is_debug_visible:
		_update_debug_display()

func _update_mathematical_display():
	if not conductor or not conductor.current_icon or not mathematical_info:
		return
	
	var icon = conductor.current_icon
	var state = conductor.get_current_state()
	var diagnostics = conductor.get_system_diagnostics()
	
	# Calculate additional metrics
	var total_energy = conductor.get_system_energy()
	var phase_coherence = conductor.get_phase_coherence()
	var dominant = conductor.get_dominant_component()
	
	# Update mathematical info display
	mathematical_info.text = """🧮 MATHEMATICAL STATE:
System: %s
Dimensions: %d
Evolution Rate: %.3f
Time Scale: %.1f

⚡ ENERGY ANALYSIS:
Total Energy: %.3f
Phase Coherence: %.3f
Dominant: %s %s (%.3f)

🔄 SYSTEM DYNAMICS:
Coupling Strength: %.3f
Oscillating Components: %d
Stable Components: %d
Evolution Time: %.1fs

🎯 EMERGENT BEHAVIORS:
%s""" % [
		icon.name,
		icon.dimension,
		icon.evolution_rate,
		conductor.time_scale,
		total_energy,
		phase_coherence,
		dominant.get("emoji", "❓"),
		dominant.get("label", "Unknown"),
		dominant.get("magnitude", 0.0),
		icon.get_matrix_coupling_strength(),
		icon.get_oscillating_components().size(),
		icon.get_stable_components().size(),
		evolution_time,
		_analyze_emergent_behaviors()
	]

func _update_status_display():
	if not conductor or not status_label:
		return
	
	var fps = Engine.get_frames_per_second()
	var memory_usage = OS.get_static_memory_peak_usage()
	
	status_label.text = """📊 STATUS:
State: %s
FPS: %d
Memory: %.1f MB
Session: %s

🎮 CONTROLS:
SPACE - Pause/Resume
R - Add Perturbation  
CTRL+R - Reset System
F1 - Toggle Debug
← → - Time Scale
ESC - Quit""" % [
		"Running" if conductor.auto_evolution else "Paused",
		fps,
		memory_usage / 1024.0 / 1024.0,
		game_session.get_session_summary()
	]

func _update_debug_display():
	if not conductor or not debug_label:
		return
	
	var diagnostics = conductor.get_system_diagnostics()
	var perf_stats = performance_monitor.get_statistics()
	
	debug_label.text = """🔍 DEBUG INFORMATION:
Frame Count: %d
Evolution History: %d entries
Avg Evolution Time: %.4f ms
Peak Memory: %.1f MB

🎛️ SYSTEM INTERNALS:
Matrix Validation: %s
State Vector Size: %d
Transform Matrix Size: %dx%d
Signal Connections: Active

⚙️ PERFORMANCE METRICS:
%s

🧪 EXPERIMENTAL FEATURES:
Future Simulation: Available
Perturbation System: Active
State Serialization: Ready""" % [
		diagnostics.get("frame_count", 0),
		diagnostics.get("evolution_history_size", 0),
		diagnostics.get("performance", {}).get("avg_evolution_time", 0.0) * 1000,
		perf_stats.get("peak_memory_mb", 0.0),
		"Valid" if conductor.current_icon else "Invalid",
		conductor.quantum_core.state_vector.size() if conductor.quantum_core else 0,
		conductor.quantum_core.dimension if conductor.quantum_core else 0,
		conductor.quantum_core.dimension if conductor.quantum_core else 0,
		_format_performance_metrics(perf_stats)
	]

func _analyze_emergent_behaviors() -> String:
	if not conductor or not conductor.current_icon:
		return "• System initializing..."
	
	var behaviors = []
	var state = conductor.get_current_state()
	var icon = conductor.current_icon
	
	# Analyze oscillations
	var oscillating_components = 0
	var max_oscillation = 0.0
	for i in range(state.size()):
		var imag_part = abs(state[i].y)
		if imag_part > 0.1:
			oscillating_components += 1
			max_oscillation = max(max_oscillation, imag_part)
	
	if oscillating_components > 0:
		behaviors.append("• %d components oscillating (max: %.2f)" % [oscillating_components, max_oscillation])
	
	# Analyze energy distribution
	var energy_distribution = []
	for i in range(state.size()):
		energy_distribution.append(state[i].length_squared())
	
	energy_distribution.sort()
	var energy_entropy = _calculate_entropy(energy_distribution)
	behaviors.append("• Energy entropy: %.2f" % energy_entropy)
	
	# Icon-specific behaviors
	match icon.name:
		"The Imperium":
			var treasury_state = conductor.get_component_magnitude(4)  # Treasury component
			if treasury_state < 0.2:
				behaviors.append("• Treasury crisis detected!")
			behaviors.append("• Imperial stability: %.1f%%" % (treasury_state * 100))
		
		"The Biotic Flux":
			var growth_rate = conductor.get_component_magnitude(0)  # Bio-intent
			var entropy_level = conductor.get_component_magnitude(7)  # Entropy
			behaviors.append("• Growth rate: %.1f%%" % (growth_rate * 100))
			behaviors.append("• Entropy level: %.1f%%" % (entropy_level * 100))
		
		"The Constellation Shepherd":
			var stellar_activity = conductor.get_component_magnitude(1)  # Bright stars
			var black_hole_risk = conductor.get_component_magnitude(5)  # Black holes
			behaviors.append("• Stellar activity: %.1f%%" % (stellar_activity * 100))
			if black_hole_risk > 0.3:
				behaviors.append("• Black hole formation risk!")
		
		"The Entropy Garden":
			var life_death_ratio = conductor.get_component_magnitude(1) / max(conductor.get_component_magnitude(4), 0.01)
			behaviors.append("• Life/Death ratio: %.2f" % life_death_ratio)
		
		"The Masquerade Court":
			var intrigue_level = conductor.get_component_magnitude(1)  # Masks
			var surveillance_level = conductor.get_component_magnitude(7)  # Surveillance
			behaviors.append("• Court intrigue: %.1f%%" % (intrigue_level * 100))
			behaviors.append("• Surveillance: %.1f%%" % (surveillance_level * 100))
	
	return "\n".join(behaviors) if behaviors.size() > 0 else "• System stabilizing..."

func _calculate_entropy(values: Array) -> float:
	"""Calculate Shannon entropy of a value distribution"""
	if values.size() == 0:
		return 0.0
	
	var total = 0.0
	for v in values:
		total += v
	
	if total == 0.0:
		return 0.0
	
	var entropy = 0.0
	for v in values:
		if v > 0:
			var p = v / total
			entropy -= p * log(p) / log(2.0)
	
	return entropy

func _format_performance_metrics(stats: Dictionary) -> String:
	var metrics = []
	for key in stats.keys():
		if key != "history":
			metrics.append("%s: %.3f" % [key, stats[key]])
	return metrics.join("\n")

func _update_performance_display():
	if performance_monitor:
		performance_monitor.update_statistics()

func _toggle_debug_panel():
	is_debug_visible = !is_debug_visible
	if debug_panel:
		debug_panel.visible = is_debug_visible

func _show_transition_notification(transition_type: String):
	# Create a temporary notification
	var notification = Label.new()
	notification.text = "🌟 CRITICAL TRANSITION: " + transition_type.to_upper()
	notification.size = Vector2(400, 50)
	notification.position = Vector2(size.x / 2 - 200, 100)
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification.add_theme_font_size_override("font_size", 16)
	notification.modulate = Color.YELLOW
	
	add_child(notification)
	
	# Auto-remove after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.timeout.connect(func(): 
		notification.queue_free()
		timer.queue_free()
	)
	timer.autostart = true
	add_child(timer)

func _add_random_perturbation():
	if conductor and conductor.current_icon:
		var random_component = randi() % conductor.current_icon.dimension
		var perturbation_strength = randf_range(0.05, 0.2)
		conductor.add_perturbation(random_component, perturbation_strength)
		print("Added perturbation to component ", random_component, " with strength ", perturbation_strength)

func _save_system_state():
	if conductor and conductor.current_icon:
		var state_data = {
			"icon_name": conductor.current_icon.name,
			"state_vector": conductor.get_current_state(),
			"time_scale": conductor.time_scale,
			"evolution_time": evolution_time,
			"timestamp": Time.get_datetime_string_from_system()
		}
		
		var file = FileAccess.open("user://quantum_state.json", FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(state_data))
			file.close()
			print("System state saved successfully")

func _load_system_state():
	var file = FileAccess.open("user://quantum_state.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var state_data = json.data
			# Load the saved state
			if conductor:
				conductor.load_icon_by_name(state_data.get("icon_name", "The Imperium"))
				conductor.set_time_scale(state_data.get("time_scale", 1.0))
				evolution_time = state_data.get("evolution_time", 0.0)
				print("System state loaded successfully")
		else:
			print("Failed to parse saved state")
	else:
		print("No saved state found")

func _show_quit_dialog():
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Are you sure you want to quit?\nUnsaved progress will be lost."
	dialog.title = "Quit Quantum Singularity"
	dialog.confirmed.connect(func(): get_tree().quit())
	add_child(dialog)
	dialog.popup_centered()

# Helper classes
class GameSession extends RefCounted:
	var session_start_time: float
	var icons_used: Array[String] = []
	var evolution_steps: int = 0
	var critical_events: Array[String] = []
	var energy_history: Array[float] = []
	var max_history_size: int = 100
	
	func _init():
		session_start_time = Time.get_time_dict_from_system().get("unix", 0)
	
	func record_icon_change(icon_name: String):
		if not icons_used.has(icon_name):
			icons_used.append(icon_name)
	
	func record_evolution_step(state: PackedVector2Array):
		evolution_steps += 1
	
	func record_critical_event(event_type: String):
		critical_events.append(event_type)
	
	func record_energy_change(energy: float):
		energy_history.append(energy)
		while energy_history.size() > max_history_size:
			energy_history.pop_front()
	
	func record_coherence_change(coherence: float):
		# Could track coherence history here
		pass
	
	func record_system_reset():
		critical_events.append("system_reset")
	
	func get_session_summary() -> String:
		var duration = Time.get_time_dict_from_system().get("unix", 0) - session_start_time
		return "%d icons, %d events, %.0fs" % [icons_used.size(), critical_events.size(), duration]

class PerformanceMonitor extends Node:
	var statistics: Dictionary = {}
	var history: Array[Dictionary] = []
	var max_history_size: int = 60  # Keep 60 seconds of history
	
	func update_statistics():
		var current_stats = {
			"fps": Engine.get_frames_per_second(),
			"memory_mb": OS.get_static_memory_peak_usage() / 1024.0 / 1024.0,
			"timestamp": Time.get_time_dict_from_system().get("unix", 0)
		}
		
		history.append(current_stats)
		while history.size() > max_history_size:
			history.pop_front()
		
		# Calculate averages
		if history.size() > 0:
			var avg_fps = 0.0
			var peak_memory = 0.0
			
			for stats in history:
				avg_fps += stats.get("fps", 0)
				peak_memory = max(peak_memory, stats.get("memory_mb", 0))
			
			statistics = {
				"avg_fps": avg_fps / history.size(),
				"peak_memory_mb": peak_memory,
				"current_fps": current_stats.fps,
				"current_memory_mb": current_stats.memory_mb,
				"history_size": history.size()
			}
	
	func get_statistics() -> Dictionary:
		return statistics
