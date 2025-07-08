# scripts/core/QuantumConductor.gd
class_name QuantumConductor
extends Node

@export var time_scale: float = 1.0
@export var auto_evolution: bool = true

var quantum_core: DynamicalSystem
var current_icon: IconDefinition

signal icon_loaded(icon_name: String)
signal evolution_step_completed(state: Array[Vector2])

func _ready():
	_initialize_quantum_core()
	_load_default_icon()

func _physics_process(delta):
	if auto_evolution and quantum_core:
		quantum_core.evolve(delta * time_scale)
		evolution_step_completed.emit(quantum_core.get_state_snapshot())
		print("Evolution step: ", quantum_core.get_magnitude(0))

func _initialize_quantum_core():
	quantum_core = DynamicalSystem.new(7)
	quantum_core.state_evolved.connect(_on_state_evolved)

func _load_default_icon():
	# Create a simple test icon
	var test_icon = IconDefinition.new()
	test_icon.name = "Test System"
	test_icon.dimension = 7
	var labels: Array[String] = ["A", "B", "C", "D", "E", "F", "G"]
	test_icon.parameter_labels = labels
	test_icon.emoji_mapping = {
		0: "🔴", 1: "🟠", 2: "🟡", 3: "🟢", 
		4: "🔵", 5: "🟣", 6: "⚫"
	}
	
	# Create a simple transformation matrix with some coupling
	var matrix: Array[Array] = []
	for i in range(7):
		var row: Array = []
		for j in range(7):
			if i == j:
				row.append(0.05)  # Self-reinforcement
			elif abs(i - j) == 1:
				row.append(0.1)   # Neighbor coupling
			else:
				row.append(0.0)
		matrix.append(row)
	
	test_icon.transformation_matrix = matrix
	load_icon(test_icon)

func load_icon(icon: IconDefinition):
	current_icon = icon
	quantum_core.load_icon_configuration(icon)
	icon_loaded.emit(icon.name)

func get_current_state() -> Array[Vector2]:
	return quantum_core.get_state_snapshot()

func get_component_magnitude(index: int) -> float:
	return quantum_core.get_magnitude(index)

func get_component_phase(index: int) -> float:
	return quantum_core.get_phase(index)

func pause_evolution():
	auto_evolution = false

func resume_evolution():
	auto_evolution = true

func set_time_scale(scale: float):
	time_scale = clamp(scale, 0.0, 10.0)

func _on_state_evolved(_new_state: Array[Vector2]):
	pass  # Handle state evolution events
