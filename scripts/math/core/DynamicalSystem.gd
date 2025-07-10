# scripts/math/core/DynamicalSystem.gd
class_name DynamicalSystem
extends Resource

# Pure mathematical quantum system engine
# No UI dependencies - pure mathematical evolution

var state_vector: Array[Vector2] = []
var transformation_matrix: Array[Array] = []
var dimension: int = 7
var evolution_rate: float = 0.02
var time_accumulator: float = 0.0

signal state_evolved(new_state: Array)

func _init():
	_initialize_default_system()

func _initialize_default_system():
	"""Initialize with default 7D system"""
	dimension = 7
	state_vector = []
	transformation_matrix = []
	
	# Create default state vector
	for i in range(dimension):
		state_vector.append(Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)))
	
	# Create default transformation matrix
	for i in range(dimension):
		var row = []
		for j in range(dimension):
			if i == j:
				row.append(0.98)  # Slight decay
			else:
				row.append(randf_range(-0.02, 0.02))  # Small coupling
		transformation_matrix.append(row)

func setup_from_composition(composition_data: Dictionary):
	"""Setup system from biome composition"""
	if composition_data.has("dimension"):
		dimension = composition_data.dimension
	
	# Initialize state based on composition
	if composition_data.has("icons"):
		_setup_from_icons(composition_data.icons)
	else:
		_initialize_default_system()

func load_from_biome_composition(biome_composition: BiomeComposition):
	"""Load system from BiomeComposition object - called by BiomeMathCore"""
	if not biome_composition:
		print("Warning: BiomeComposition is null, using default system")
		_initialize_default_system()
		return
	
	# Get composition data
	var composition_data = biome_composition.get_composition_data()
	if not composition_data:
		print("Warning: No composition data found, using default system")
		_initialize_default_system()
		return
	
	# Setup from composition
	var icon_composition = composition_data.get("icon_composition", {})
	var dominant_icons = composition_data.get("dominant_icons", [])
	
	# Initialize state vector based on icon composition
	_setup_from_icon_composition(icon_composition, dominant_icons)
	
	# Get the blended matrix from composition
	var blended_matrix = biome_composition.get_blended_matrix()
	if blended_matrix and blended_matrix.size() > 0:
		transformation_matrix = blended_matrix.duplicate()
	else:
		print("Warning: No blended matrix found, using default matrix")
		_create_default_matrix()

func load_icon_configuration(icon: IconDefinition):
	"""Load configuration from an icon definition"""
	if not icon:
		print("Warning: Icon is null, using default configuration")
		_initialize_default_system()
		return
	
	# Set dimension from icon
	dimension = icon.dimension
	
	# Load transformation matrix from icon
	if icon.transformation_matrix and icon.transformation_matrix.size() > 0:
		transformation_matrix = icon.transformation_matrix.duplicate()
	else:
		_create_default_matrix()
	
	# Initialize state vector
	state_vector.clear()
	for i in range(dimension):
		var initial_magnitude = icon.get_parameter_value(i)
		var initial_phase = icon.get_parameter_phase(i)
		state_vector.append(Vector2(
			initial_magnitude * cos(initial_phase),
			initial_magnitude * sin(initial_phase)
		))

func _setup_from_icon_composition(icon_composition: Dictionary, dominant_icons: Array):
	"""Setup state vector from icon composition"""
	state_vector.clear()
	
	# Create state vector based on icon composition
	for i in range(dimension):
		var initial_magnitude = 1.0
		var initial_phase = 0.0
		
		# If we have dominant icons, use them to influence initial state
		if i < dominant_icons.size():
			var icon_name = dominant_icons[i]
			var icon_strength = icon_composition.get(icon_name, 1.0)
			initial_magnitude = icon_strength
			initial_phase = hash(icon_name) % 360 * PI / 180.0  # Convert to radians
		else:
			# Use random small values for non-dominant components
			initial_magnitude = randf_range(0.1, 0.5)
			initial_phase = randf_range(0.0, 2.0 * PI)
		
		# Create complex number as Vector2
		var real_part = initial_magnitude * cos(initial_phase)
		var imag_part = initial_magnitude * sin(initial_phase)
		state_vector.append(Vector2(real_part, imag_part))

func _create_default_matrix():
	"""Create default transformation matrix"""
	transformation_matrix.clear()
	for i in range(dimension):
		var row = []
		for j in range(dimension):
			if i == j:
				row.append(0.98)  # Slight decay
			else:
				row.append(randf_range(-0.02, 0.02))  # Small coupling
		transformation_matrix.append(row)

func _setup_from_icons(icons: Array):
	"""Setup system from icon data"""
	dimension = max(7, icons.size())
	state_vector.clear()
	
	for i in range(dimension):
		if i < icons.size():
			# Use icon properties to set initial state
			var icon_data = icons[i]
			var magnitude = icon_data.get("magnitude", 1.0)
			var phase = icon_data.get("phase", 0.0)
			state_vector.append(Vector2(magnitude * cos(phase), magnitude * sin(phase)))
		else:
			state_vector.append(Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)))

func evolve(delta_time: float):
	"""Evolve the mathematical system"""
	time_accumulator += delta_time
	
	# Don't evolve too frequently
	if time_accumulator < 0.016:  # ~60 FPS
		return
	
	var evolution_delta = time_accumulator * evolution_rate
	time_accumulator = 0.0
	
	# Apply matrix transformation
	var new_state = []
	for i in range(dimension):
		var new_component = Vector2.ZERO
		for j in range(dimension):
			var matrix_val = transformation_matrix[i][j]
			new_component += state_vector[j] * matrix_val
		new_state.append(new_component)
	
	# Apply evolution and maintain stability
	for i in range(dimension):
		state_vector[i] = new_state[i]
		
		# Clamp to prevent explosion
		var magnitude = state_vector[i].length()
		if magnitude > 5.0:
			state_vector[i] = state_vector[i].normalized() * 5.0
	
	# Emit evolution signal
	state_evolved.emit(state_vector.duplicate())

func get_state_snapshot() -> PackedVector2Array:
	"""Get current state snapshot as PackedVector2Array"""
	var packed_state = PackedVector2Array()
	for component in state_vector:
		packed_state.append(component)
	return packed_state

func get_component_state(component_index: int) -> Vector2:
	"""Get state of specific component"""
	if component_index >= 0 and component_index < state_vector.size():
		return state_vector[component_index]
	return Vector2.ZERO

# ADDED: Missing methods that QuantumConductor expects
func get_magnitude(index: int) -> float:
	"""Get magnitude of component at index"""
	if index >= 0 and index < state_vector.size():
		return state_vector[index].length()
	return 0.0

func get_phase(index: int) -> float:
	"""Get phase of component at index"""
	if index >= 0 and index < state_vector.size():
		return state_vector[index].angle()
	return 0.0

func get_real(index: int) -> float:
	"""Get real part of component at index"""
	if index >= 0 and index < state_vector.size():
		return state_vector[index].x
	return 0.0

func get_imaginary(index: int) -> float:
	"""Get imaginary part of component at index"""
	if index >= 0 and index < state_vector.size():
		return state_vector[index].y
	return 0.0

func add_perturbation(component: int, perturbation: Vector2):
	"""Add perturbation to specific component"""
	if component >= 0 and component < state_vector.size():
		state_vector[component] += perturbation

func modify_matrix_element(row: int, col: int, delta: float):
	"""Modify a specific matrix element"""
	if row >= 0 and row < transformation_matrix.size() and col >= 0 and col < transformation_matrix[row].size():
		transformation_matrix[row][col] += delta

func inject_energy(component_index: int, energy_delta: Vector2):
	"""Inject energy into specific component"""
	if component_index >= 0 and component_index < state_vector.size():
		state_vector[component_index] += energy_delta

func get_system_energy() -> float:
	"""Get total system energy"""
	var total_energy = 0.0
	for component in state_vector:
		total_energy += component.length_squared()
	return total_energy

func get_phase_coherence() -> float:
	"""Get system phase coherence"""
	if state_vector.size() == 0:
		return 0.0
	
	var avg_phase = 0.0
	for component in state_vector:
		avg_phase += component.angle()
	avg_phase /= state_vector.size()
	
	var coherence = 0.0
	for component in state_vector:
		var phase_diff = abs(component.angle() - avg_phase)
		coherence += cos(phase_diff)
	
	return coherence / state_vector.size()

func get_dominant_component() -> int:
	"""Get index of component with highest magnitude"""
	var max_magnitude = 0.0
	var dominant_index = 0
	
	for i in range(state_vector.size()):
		var magnitude = state_vector[i].length()
		if magnitude > max_magnitude:
			max_magnitude = magnitude
			dominant_index = i
	
	return dominant_index

func add_temporary_modifier(modifier):
	"""Add temporary matrix modifier"""
	# Simple implementation - could be expanded
	print("Added temporary modifier: ", modifier)

func compress_component(component_index: int, compressed_state: Dictionary):
	"""Compress a component to simplified state"""
	if component_index >= 0 and component_index < state_vector.size():
		var compressed_magnitude = compressed_state.get("magnitude", 1.0)
		var compressed_phase = compressed_state.get("phase", 0.0)
		state_vector[component_index] = Vector2(
			compressed_magnitude * cos(compressed_phase),
			compressed_magnitude * sin(compressed_phase)
		)

func serialize() -> Dictionary:
	"""Serialize system state"""
	var serialized_state = []
	for component in state_vector:
		serialized_state.append({"x": component.x, "y": component.y})
	
	return {
		"dimension": dimension,
		"state_vector": serialized_state,
		"transformation_matrix": transformation_matrix,
		"evolution_rate": evolution_rate
	}

func deserialize(data: Dictionary):
	"""Deserialize system state"""
	dimension = data.get("dimension", 7)
	evolution_rate = data.get("evolution_rate", 0.02)
	
	# Deserialize state vector
	var serialized_state = data.get("state_vector", [])
	state_vector.clear()
	for component_data in serialized_state:
		state_vector.append(Vector2(component_data.x, component_data.y))
	
	# Deserialize matrix
	transformation_matrix = data.get("transformation_matrix", [])
	
	# Ensure we have valid data
	if state_vector.is_empty():
		_initialize_default_system()
