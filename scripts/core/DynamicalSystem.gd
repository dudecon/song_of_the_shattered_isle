# scripts/core/DynamicalSystem.gd
class_name DynamicalSystem
extends Resource

@export var state_vector: Array[Vector2] = []
@export var transformation_matrix: Array[Array] = []
@export var dimension: int = 7
@export var evolution_rate: float = 0.02
@export var name: String = "Unnamed System"

signal state_evolved(new_state: Array[Vector2])

func _init(dim: int = 7):
	dimension = dim
	_initialize_default_state()

func _initialize_default_state():
	state_vector.clear()
	for i in range(dimension):
		var random_real = randf_range(0.1, 0.8)
		var random_imag = randf_range(-0.3, 0.3)
		state_vector.append(Vector2(random_real, random_imag))

func evolve(delta_time: float):
	var new_state: Array[Vector2] = []
	
	# Apply transformation matrix evolution
	for i in range(dimension):
		var real_sum: float = 0.0
		var imag_sum: float = 0.0
		
		for j in range(dimension):
			if i < transformation_matrix.size() and j < transformation_matrix[i].size():
				# Complex evolution: state[i] += matrix[i][j] * state[j] * dt
				real_sum += transformation_matrix[i][j] * state_vector[j].x
				imag_sum += transformation_matrix[i][j] * state_vector[j].y * 0.1  # Damped imaginary
		
		var new_real = state_vector[i].x + real_sum * delta_time * evolution_rate
		var new_imag = state_vector[i].y + imag_sum * delta_time * evolution_rate
		
		# Bound the values to prevent explosion
		new_real = clamp(new_real, 0.01, 1.0)
		new_imag = clamp(new_imag, -0.5, 0.5)
		
		new_state.append(Vector2(new_real, new_imag))
	
	state_vector = new_state
	state_evolved.emit(state_vector.duplicate())

func get_state_snapshot() -> Array[Vector2]:
	return state_vector.duplicate()

func get_magnitude(component: int) -> float:
	if component >= 0 and component < state_vector.size():
		return state_vector[component].length()
	return 0.0

func get_phase(component: int) -> float:
	if component >= 0 and component < state_vector.size():
		return state_vector[component].angle()
	return 0.0

func load_icon_configuration(icon: IconDefinition):
	if icon:
		dimension = icon.dimension
		state_vector = icon.initial_state.duplicate()
		transformation_matrix = _deep_copy_matrix(icon.transformation_matrix)
		evolution_rate = icon.evolution_rate
		name = icon.name

func _deep_copy_matrix(matrix: Array[Array]) -> Array[Array]:
	var copy: Array[Array] = []
	for row in matrix:
		var new_row: Array = []
		for value in row:
			new_row.append(value)
		copy.append(new_row)
	return copy
