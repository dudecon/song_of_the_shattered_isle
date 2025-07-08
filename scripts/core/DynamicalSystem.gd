# scripts/core/DynamicalSystem.gd
class_name DynamicalSystem
extends Resource

@export var state_vector: PackedVector2Array = PackedVector2Array()
@export var transformation_matrix: Array[Array] = []
@export var dimension: int = 7
@export var evolution_rate: float = 0.02
@export var name: String = "Unnamed System"

signal state_evolved(new_state: PackedVector2Array)

func _init(dim: int = 7):
	dimension = dim
	_initialize_default_state()

func _initialize_default_state():
	var temp_state: Array[Vector2] = []
	for i in range(dimension):
		var random_real = randf_range(0.1, 0.8)
		var random_imag = randf_range(-0.3, 0.3)
		temp_state.append(Vector2(random_real, random_imag))
	state_vector = PackedVector2Array(temp_state)

func evolve(delta_time: float):
	var new_state: Array[Vector2] = []
	
	# Apply transformation matrix evolution
	for i in range(dimension):
		var real_sum: float = 0.0
		var imag_sum: float = 0.0
		
		for j in range(dimension):
			# Robust bounds checking
			if i >= transformation_matrix.size():
				continue
			var row = transformation_matrix[i]
			if j >= row.size():
				continue
			
			# Complex evolution: state[i] += matrix[i][j] * state[j] * dt
			real_sum += transformation_matrix[i][j] * state_vector[j].x
			imag_sum += transformation_matrix[i][j] * state_vector[j].y * 0.1  # Damped imaginary
		
		# Euler integration with bounds
		var new_real = state_vector[i].x + real_sum * delta_time * evolution_rate
		var new_imag = state_vector[i].y + imag_sum * delta_time * evolution_rate
		
		# Bound the values to prevent explosion
		new_real = clampf(new_real, 0.01, 1.0)
		new_imag = clampf(new_imag, -0.5, 0.5)
		
		new_state.append(Vector2(new_real, new_imag))
	
	# Update state and emit signal
	state_vector = PackedVector2Array(new_state)
	state_evolved.emit(state_vector)

func get_state_snapshot() -> PackedVector2Array:
	return state_vector.duplicate()

func get_magnitude(component: int) -> float:
	if component >= 0 and component < state_vector.size():
		return state_vector[component].length()
	return 0.0

func get_phase(component: int) -> float:
	if component >= 0 and component < state_vector.size():
		return state_vector[component].angle()
	return 0.0

func get_real(component: int) -> float:
	if component >= 0 and component < state_vector.size():
		return state_vector[component].x
	return 0.0

func get_imaginary(component: int) -> float:
	if component >= 0 and component < state_vector.size():
		return state_vector[component].y
	return 0.0

func get_system_energy() -> float:
	var total_energy = 0.0
	for i in range(state_vector.size()):
		var magnitude = state_vector[i].length()
		total_energy += magnitude * magnitude
	return total_energy

func get_phase_coherence() -> float:
	var coherence = 0.0
	for i in range(state_vector.size()):
		coherence += cos(state_vector[i].angle())
	return coherence / state_vector.size()

func load_icon_configuration(icon: IconDefinition):
	if not icon:
		push_error("Cannot load null icon configuration")
		return
	
	dimension = icon.dimension
	evolution_rate = icon.evolution_rate
	name = icon.name
	
	# Load initial state - fix the zero initialization
	if icon.initial_state.size() > 0:
		state_vector = icon.initial_state.duplicate()
	else:
		_initialize_default_state()
	
	# Load transformation matrix
	transformation_matrix = _deep_copy_matrix(icon.transformation_matrix)
	_validate_matrix()
	
	# Force immediate signal emission
	state_evolved.emit(state_vector)

func _deep_copy_matrix(matrix: Array[Array]) -> Array[Array]:
	var copy: Array[Array] = []
	for row in matrix:
		var new_row: Array = []
		for value in row:
			new_row.append(value)
		copy.append(new_row)
	return copy

func _validate_matrix():
	# Ensure matrix is properly sized
	if transformation_matrix.size() != dimension:
		push_warning("Transformation matrix size mismatch with dimension")
		_resize_matrix()
	
	# Check for valid numeric values
	for i in range(transformation_matrix.size()):
		var row = transformation_matrix[i]
		if row.size() != dimension:
			push_warning("Matrix row size mismatch")
			_resize_matrix()
			return
		
		for j in range(row.size()):
			if not is_finite(row[j]):
				push_warning("Invalid matrix value at [%d, %d]" % [i, j])
				transformation_matrix[i][j] = 0.0

func _resize_matrix():
	# Resize matrix to match dimension
	transformation_matrix.resize(dimension)
	for i in range(dimension):
		if transformation_matrix[i] == null:
			transformation_matrix[i] = []
		transformation_matrix[i].resize(dimension)
		for j in range(dimension):
			if transformation_matrix[i][j] == null:
				transformation_matrix[i][j] = 0.05 if i == j else 0.0

func add_perturbation(component: int, perturbation: Vector2):
	"""Add a small perturbation to a specific component"""
	if component >= 0 and component < state_vector.size():
		var new_state = state_vector.duplicate()
		new_state[component] += perturbation
		# Clamp to valid range
		new_state[component].x = clampf(new_state[component].x, 0.01, 1.0)
		new_state[component].y = clampf(new_state[component].y, -0.5, 0.5)
		state_vector = new_state

func modify_matrix_element(i: int, j: int, delta: float):
	"""Modify a specific matrix element"""
	if i >= 0 and i < dimension and j >= 0 and j < dimension:
		if i < transformation_matrix.size() and j < transformation_matrix[i].size():
			transformation_matrix[i][j] += delta
			# Prevent excessive values
			transformation_matrix[i][j] = clampf(transformation_matrix[i][j], -2.0, 2.0)
