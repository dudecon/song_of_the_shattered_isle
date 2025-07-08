# scripts/core/IconDefinition.gd
class_name IconDefinition
extends Resource

@export var name: String = ""
@export var dimension: int = 7
@export var initial_state: PackedVector2Array = PackedVector2Array()
@export var transformation_matrix: Array[Array] = []
@export var parameter_labels: PackedStringArray = PackedStringArray()
@export var emoji_mapping: Dictionary = {}
@export var evolution_rate: float = 0.02
@export var description: String = ""
@export var visualization_config: Dictionary = {}

func _init():
	if initial_state.is_empty():
		_generate_default_state()
	if transformation_matrix.is_empty():
		_generate_identity_matrix()

func _generate_default_state():
	var temp_state: Array[Vector2] = []
	for i in range(dimension):
		var random_magnitude = randf_range(0.1, 0.8)
		var random_phase = randf_range(-PI, PI)
		var real = random_magnitude * cos(random_phase)
		var imag = random_magnitude * sin(random_phase)
		temp_state.append(Vector2(real, imag))
	initial_state = PackedVector2Array(temp_state)

func _generate_identity_matrix():
	transformation_matrix.clear()
	for i in range(dimension):
		var row: Array = []
		for j in range(dimension):
			row.append(0.05 if i == j else 0.0)  # Small self-reinforcement
		transformation_matrix.append(row)

func get_component_info(index: int) -> Dictionary:
	if index < 0 or index >= dimension:
		return {}
	
	var info = {
		"index": index,
		"label": "",
		"emoji": "❓",
		"magnitude": 0.0,
		"phase": 0.0
	}
	
	# Get label
	if index < parameter_labels.size():
		info["label"] = parameter_labels[index]
	else:
		info["label"] = "component_" + str(index)
	
	# Get emoji
	if emoji_mapping.has(index):
		info["emoji"] = emoji_mapping[index]
	
	# Get initial values
	if index < initial_state.size():
		info["magnitude"] = initial_state[index].length()
		info["phase"] = initial_state[index].angle()
	
	return info

func get_all_component_info() -> Array[Dictionary]:
	var info_array: Array[Dictionary] = []
	for i in range(dimension):
		info_array.append(get_component_info(i))
	return info_array

func get_matrix_coupling_strength() -> float:
	"""Calculate overall system coupling strength"""
	var total_coupling = 0.0
	for i in range(transformation_matrix.size()):
		for j in range(transformation_matrix[i].size()):
			if i != j:  # Off-diagonal elements
				total_coupling += abs(transformation_matrix[i][j])
	return total_coupling

func get_dominant_connections(component: int) -> Array[Dictionary]:
	"""Get the strongest connections for a component"""
	var connections: Array[Dictionary] = []
	
	if component < 0 or component >= transformation_matrix.size():
		return connections
	
	# Outgoing connections (this component affects others)
	var row = transformation_matrix[component]
	for j in range(row.size()):
		if j != component and abs(row[j]) > 0.1:
			connections.append({
				"type": "outgoing",
				"target": j,
				"strength": row[j],
				"target_emoji": emoji_mapping.get(j, "❓"),
				"target_label": parameter_labels[j] if j < parameter_labels.size() else "component_" + str(j)
			})
	
	# Incoming connections (other components affect this one)
	for i in range(transformation_matrix.size()):
		if i != component and i < transformation_matrix.size():
			var incoming_row = transformation_matrix[i]
			if component < incoming_row.size() and abs(incoming_row[component]) > 0.1:
				connections.append({
					"type": "incoming",
					"source": i,
					"strength": incoming_row[component],
					"source_emoji": emoji_mapping.get(i, "❓"),
					"source_label": parameter_labels[i] if i < parameter_labels.size() else "component_" + str(i)
				})
	
	# Sort by strength
	connections.sort_custom(func(a, b): return abs(a.strength) > abs(b.strength))
	
	return connections

func validate_icon_data() -> Dictionary:
	"""Validate icon data integrity"""
	var issues: Array[String] = []
	var warnings: Array[String] = []
	
	# Check dimensions
	if dimension <= 0:
		issues.append("Invalid dimension: " + str(dimension))
	
	# Check initial state
	if initial_state.size() != dimension:
		issues.append("Initial state size mismatch: expected %d, got %d" % [dimension, initial_state.size()])
	
	# Check transformation matrix
	if transformation_matrix.size() != dimension:
		issues.append("Matrix rows mismatch: expected %d, got %d" % [dimension, transformation_matrix.size()])
	else:
		for i in range(transformation_matrix.size()):
			var row = transformation_matrix[i]
			if row.size() != dimension:
				issues.append("Matrix row %d size mismatch: expected %d, got %d" % [i, dimension, row.size()])
	
	# Check labels
	if parameter_labels.size() != dimension:
		warnings.append("Parameter labels size mismatch: expected %d, got %d" % [dimension, parameter_labels.size()])
	
	# Check emoji mapping
	for i in range(dimension):
		if not emoji_mapping.has(i):
			warnings.append("Missing emoji mapping for component %d" % i)
	
	# Check for NaN or infinite values
	for i in range(initial_state.size()):
		var vec = initial_state[i]
		if not is_finite(vec.x) or not is_finite(vec.y):
			issues.append("Invalid initial state value at component %d" % i)
	
	for i in range(transformation_matrix.size()):
		var row = transformation_matrix[i]
		for j in range(row.size()):
			if not is_finite(row[j]):
				issues.append("Invalid matrix value at [%d, %d]" % [i, j])
	
	return {
		"valid": issues.is_empty(),
		"issues": issues,
		"warnings": warnings
	}

func create_variant(name_suffix: String, mutation_strength: float = 0.1) -> IconDefinition:
	"""Create a mutated variant of this icon"""
	var variant = IconDefinition.new()
	variant.name = name + " " + name_suffix
	variant.dimension = dimension
	variant.parameter_labels = parameter_labels.duplicate()
	variant.emoji_mapping = emoji_mapping.duplicate()
	variant.evolution_rate = evolution_rate
	variant.description = description + " (Variant: " + name_suffix + ")"
	
	# Mutate initial state
	var temp_state: Array[Vector2] = []
	for i in range(initial_state.size()):
		var original = initial_state[i]
		var mutation = Vector2(
			randf_range(-mutation_strength, mutation_strength),
			randf_range(-mutation_strength, mutation_strength)
		)
		var mutated = original + mutation
		# Keep within bounds
		mutated.x = clampf(mutated.x, 0.01, 1.0)
		mutated.y = clampf(mutated.y, -0.5, 0.5)
		temp_state.append(mutated)
	variant.initial_state = PackedVector2Array(temp_state)
	
	# Mutate transformation matrix
	variant.transformation_matrix = []
	for i in range(transformation_matrix.size()):
		var row: Array = []
		for j in range(transformation_matrix[i].size()):
			var original = transformation_matrix[i][j]
			var mutation = randf_range(-mutation_strength, mutation_strength)
			var mutated = original + mutation
			# Keep within reasonable bounds
			mutated = clampf(mutated, -2.0, 2.0)
			row.append(mutated)
		variant.transformation_matrix.append(row)
	
	return variant

func get_oscillating_components() -> Array[int]:
	"""Get components with significant imaginary parts (oscillating behavior)"""
	var oscillating: Array[int] = []
	for i in range(initial_state.size()):
		if abs(initial_state[i].y) > 0.1:
			oscillating.append(i)
	return oscillating

func get_stable_components() -> Array[int]:
	"""Get components with minimal imaginary parts (stable behavior)"""
	var stable: Array[int] = []
	for i in range(initial_state.size()):
		if abs(initial_state[i].y) <= 0.1:
			stable.append(i)
	return stable

func export_to_dictionary() -> Dictionary:
	"""Export icon data to dictionary format"""
	return {
		"name": name,
		"dimension": dimension,
		"description": description,
		"evolution_rate": evolution_rate,
		"initial_state": initial_state,
		"transformation_matrix": transformation_matrix,
		"parameter_labels": parameter_labels,
		"emoji_mapping": emoji_mapping,
		"visualization_config": visualization_config
	}

func import_from_dictionary(data: Dictionary) -> bool:
	"""Import icon data from dictionary format"""
	if not data.has("name") or not data.has("dimension"):
		return false
	
	name = data.get("name", "")
	dimension = data.get("dimension", 7)
	description = data.get("description", "")
	evolution_rate = data.get("evolution_rate", 0.02)
	
	# Import arrays with validation
	if data.has("initial_state") and data["initial_state"] is PackedVector2Array:
		initial_state = data["initial_state"]
	
	if data.has("transformation_matrix") and data["transformation_matrix"] is Array:
		transformation_matrix = data["transformation_matrix"]
	
	if data.has("parameter_labels") and data["parameter_labels"] is PackedStringArray:
		parameter_labels = data["parameter_labels"]
	
	if data.has("emoji_mapping") and data["emoji_mapping"] is Dictionary:
		emoji_mapping = data["emoji_mapping"]
	
	if data.has("visualization_config") and data["visualization_config"] is Dictionary:
		visualization_config = data["visualization_config"]
	
	# Validate after import
	var validation = validate_icon_data()
	if not validation.valid:
		push_error("Failed to import icon data: " + str(validation.issues))
		return false
	
	return true
