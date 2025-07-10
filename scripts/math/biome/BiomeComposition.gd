# scripts/math/biome/BiomeComposition.gd
class_name BiomeComposition
extends Resource

# Mathematical composition of biome from icon influences

var icon_composition: Dictionary = {}
var dominant_icons: Array[String] = []
var parametric_modifiers: Dictionary = {}
var blended_matrix: Array[Array] = []

func _init():
	_initialize_default_composition()

func _initialize_default_composition():
	"""Initialize with default composition"""
	icon_composition = {
		"imperium": 0.4,
		"biotic_flux": 0.3,
		"entropy_garden": 0.2,
		"masquerade_court": 0.1
	}
	
	dominant_icons = ["imperium", "biotic_flux"]
	parametric_modifiers = {}
	_generate_blended_matrix()

func setup_from_icons(icons: Dictionary, modifiers: Dictionary = {}):
	"""Setup composition from icon data"""
	icon_composition = icons.duplicate()
	parametric_modifiers = modifiers.duplicate()
	
	# Determine dominant icons
	dominant_icons.clear()
	var sorted_icons = []
	for icon_name in icon_composition:
		var weight = icon_composition[icon_name]
		sorted_icons.append({"name": icon_name, "weight": weight})
	
	sorted_icons.sort_custom(func(a, b): return a.weight > b.weight)
	
	# Take top 3 as dominant
	for i in range(min(3, sorted_icons.size())):
		dominant_icons.append(sorted_icons[i].name)
	
	_generate_blended_matrix()

func _generate_blended_matrix():
	"""Generate blended transformation matrix from icons"""
	var dimension = 7
	blended_matrix.clear()
	
	# Initialize matrix
	for i in range(dimension):
		var row = []
		for j in range(dimension):
			row.append(0.0)
		blended_matrix.append(row)
	
	# Blend matrices from each icon
	for icon_name in icon_composition:
		var icon_weight = icon_composition[icon_name]
		var icon_matrix = _get_icon_matrix(icon_name)
		
		for i in range(dimension):
			for j in range(dimension):
				blended_matrix[i][j] += icon_matrix[i][j] * icon_weight
	
	# Normalize and add stability
	for i in range(dimension):
		for j in range(dimension):
			if i == j:
				blended_matrix[i][j] = 0.98  # Diagonal stability
			else:
				blended_matrix[i][j] = clamp(blended_matrix[i][j], -0.1, 0.1)

func _get_icon_matrix(icon_name: String) -> Array[Array]:
	"""Get transformation matrix for specific icon"""
	# Don't need to initialize matrix since _create_*_matrix() functions create it from scratch
	var matrix: Array[Array] = []
	
	match icon_name:
		"imperium":
			matrix = _create_imperium_matrix()
		"biotic_flux":
			matrix = _create_biotic_matrix()
		"entropy_garden":
			matrix = _create_entropy_matrix()
		"masquerade_court":
			matrix = _create_masquerade_matrix()
		_:
			matrix = _create_default_matrix()
	
	return matrix

func _create_imperium_matrix() -> Array[Array]:
	"""Create Imperial transformation matrix"""
	var matrix: Array[Array] = []  # Fixed: explicitly typed as Array[Array]
	for i in range(7):
		var row: Array = []  # Fixed: explicitly typed as Array
		for j in range(7):
			if i == j:
				row.append(0.98)  # Stability
			elif j == 0 or j == 1:  # Authority/Military influence
				row.append(0.02)
			else:
				row.append(0.0)
		matrix.append(row)
	return matrix

func _create_biotic_matrix() -> Array[Array]:
	"""Create Biotic transformation matrix"""
	var matrix: Array[Array] = []  # Fixed: explicitly typed as Array[Array]
	for i in range(7):
		var row: Array = []  # Fixed: explicitly typed as Array
		for j in range(7):
			if i == j:
				row.append(0.96)  # Less stable, more dynamic
			elif (i + j) % 2 == 0:  # Symbiotic connections
				row.append(0.01)
			else:
				row.append(-0.005)  # Some antagonistic effects
		matrix.append(row)
	return matrix

func _create_entropy_matrix() -> Array[Array]:
	"""Create Entropy transformation matrix"""
	var matrix: Array[Array] = []  # Fixed: explicitly typed as Array[Array]
	for i in range(7):
		var row: Array = []  # Fixed: explicitly typed as Array
		for j in range(7):
			if i == j:
				row.append(0.95)  # Decay
			else:
				row.append(randf_range(-0.01, 0.01))  # Random connections
		matrix.append(row)
	return matrix

func _create_masquerade_matrix() -> Array[Array]:
	"""Create Masquerade transformation matrix"""
	var matrix: Array[Array] = []  # Fixed: explicitly typed as Array[Array]
	for i in range(7):
		var row: Array = []  # Fixed: explicitly typed as Array
		for j in range(7):
			if i == j:
				row.append(0.97)
			elif abs(i - j) == 1:  # Adjacent connections
				row.append(0.015)
			else:
				row.append(0.0)
		matrix.append(row)
	return matrix

func _create_default_matrix() -> Array[Array]:
	"""Create default transformation matrix"""
	var matrix: Array[Array] = []  # Fixed: explicitly typed as Array[Array]
	for i in range(7):
		var row: Array = []  # Fixed: explicitly typed as Array
		for j in range(7):
			if i == j:
				row.append(0.98)
			else:
				row.append(0.0)
		matrix.append(row)
	return matrix

func get_composition_data() -> Dictionary:
	"""Get composition data"""
	return {
		"icon_composition": icon_composition,
		"dominant_icons": dominant_icons,
		"parametric_modifiers": parametric_modifiers,
		"total_icons": icon_composition.size()
	}

func get_blended_matrix() -> Array[Array]:
	"""Get blended transformation matrix"""
	return blended_matrix

func get_dominant_icons() -> Array[String]:
	"""Get dominant icons"""
	return dominant_icons

func update_node_influence(node_index: int, influence_data: Dictionary):
	"""Update node influence in composition"""
	var icon_name = influence_data.get("icon_name", "")
	var strength = influence_data.get("strength", 0.0)
	
	if icon_name in icon_composition:
		icon_composition[icon_name] += strength * 0.1
	else:
		icon_composition[icon_name] = strength * 0.1
	
	# Recalculate after update
	_generate_blended_matrix()

func serialize() -> Dictionary:
	"""Serialize composition"""
	return {
		"icon_composition": icon_composition,
		"dominant_icons": dominant_icons,
		"parametric_modifiers": parametric_modifiers,
		"blended_matrix": blended_matrix
	}

func deserialize(data: Dictionary):
	"""Deserialize composition"""
	icon_composition = data.get("icon_composition", {})
	dominant_icons = data.get("dominant_icons", [])
	parametric_modifiers = data.get("parametric_modifiers", {})
	blended_matrix = data.get("blended_matrix", [])
	
	if blended_matrix.is_empty():
		_generate_blended_matrix()
