# scripts/math/definitions/IconDefinition.gd
class_name IconDefinition
extends Resource

# Definition of an icon with its mathematical properties

var name: String
var emoji: String
var description: String
var transformation_matrix: Array[Array] = []
var initial_state: Array[Vector2] = []
var parameter_labels: Array[String] = []
var properties: Dictionary = {}

func _init():
	pass

func setup(icon_name: String, icon_emoji: String, icon_description: String, icon_properties: Dictionary = {}):
	"""Setup icon definition"""
	name = icon_name
	emoji = icon_emoji
	description = icon_description
	properties = icon_properties
	
	# Setup default parameter labels
	parameter_labels = [
		"Authority", "Military", "Economy", "Culture", 
		"Technology", "Diplomacy", "Stability"
	]
	
	# Initialize transformation matrix
	_initialize_transformation_matrix()
	
	# Initialize initial state
	_initialize_initial_state()

func _initialize_transformation_matrix():
	"""Initialize transformation matrix based on icon type"""
	transformation_matrix.clear()
	
	var dimension = 7
	for i in range(dimension):
		var row = []
		for j in range(dimension):
			if i == j:
				row.append(0.98)  # Base stability
			else:
				row.append(0.0)
		transformation_matrix.append(row)
	
	# Modify matrix based on icon properties
	_apply_icon_specific_matrix()

func _apply_icon_specific_matrix():
	"""Apply icon-specific matrix modifications"""
	match name:
		"imperium":
			_apply_imperium_matrix()
		"biotic_flux":
			_apply_biotic_matrix()
		"entropy_garden":
			_apply_entropy_matrix()
		"masquerade_court":
			_apply_masquerade_matrix()

func _apply_imperium_matrix():
	"""Apply Imperial matrix modifications"""
	# Authority influences military and economy
	transformation_matrix[1][0] = 0.02  # Authority -> Military
	transformation_matrix[2][0] = 0.015  # Authority -> Economy
	transformation_matrix[6][0] = 0.01   # Authority -> Stability

func _apply_biotic_matrix():
	"""Apply Biotic matrix modifications"""
	# Symbiotic relationships
	transformation_matrix[0][1] = 0.01  # Military -> Authority (resistance)
	transformation_matrix[3][4] = 0.015  # Culture -> Technology
	transformation_matrix[4][3] = 0.015  # Technology -> Culture

func _apply_entropy_matrix():
	"""Apply Entropy matrix modifications"""
	# Decay and renewal cycles
	for i in range(7):
		transformation_matrix[i][i] = 0.95  # Faster decay
		if i < 6:
			transformation_matrix[i][i+1] = 0.005  # Cascade effects

func _apply_masquerade_matrix():
	"""Apply Masquerade matrix modifications"""
	# Intrigue and hidden influences
	transformation_matrix[3][5] = 0.02  # Culture -> Diplomacy
	transformation_matrix[5][3] = 0.015  # Diplomacy -> Culture
	transformation_matrix[6][3] = -0.005  # Culture -> Stability (tension)

func _initialize_initial_state():
	"""Initialize initial state vector"""
	initial_state.clear()
	
	# Default state based on icon type
	match name:
		"imperium":
			initial_state = [
				Vector2(1.0, 0.0),    # Authority
				Vector2(0.8, 0.1),    # Military
				Vector2(0.6, 0.0),    # Economy
				Vector2(0.4, 0.0),    # Culture
				Vector2(0.5, 0.0),    # Technology
				Vector2(0.3, 0.0),    # Diplomacy
				Vector2(0.7, 0.0)     # Stability
			]
		"biotic_flux":
			initial_state = [
				Vector2(0.3, 0.2),    # Authority
				Vector2(0.2, 0.3),    # Military
				Vector2(0.8, 0.1),    # Economy
				Vector2(0.9, 0.2),    # Culture
				Vector2(1.0, 0.0),    # Technology
				Vector2(0.6, 0.1),    # Diplomacy
				Vector2(0.4, 0.3)     # Stability
			]
		"entropy_garden":
			initial_state = [
				Vector2(0.2, 0.1),    # Authority
				Vector2(0.1, 0.2),    # Military
				Vector2(0.3, 0.4),    # Economy
				Vector2(0.8, 0.3),    # Culture
				Vector2(0.4, 0.2),    # Technology
				Vector2(0.2, 0.1),    # Diplomacy
				Vector2(0.1, 0.5)     # Stability
			]
		"masquerade_court":
			initial_state = [
				Vector2(0.6, 0.2),    # Authority
				Vector2(0.3, 0.1),    # Military
				Vector2(0.5, 0.3),    # Economy
				Vector2(1.0, 0.1),    # Culture
				Vector2(0.4, 0.0),    # Technology
				Vector2(0.9, 0.2),    # Diplomacy
				Vector2(0.3, 0.4)     # Stability
			]
		_:
			# Default balanced state
			for i in range(7):
				initial_state.append(Vector2(0.5, 0.0))

func serialize() -> Dictionary:
	"""Serialize icon definition"""
	var serialized_matrix = []
	for row in transformation_matrix:
		serialized_matrix.append(row.duplicate())
	
	var serialized_state = []
	for component in initial_state:
		serialized_state.append({"x": component.x, "y": component.y})
	
	return {
		"name": name,
		"emoji": emoji,
		"description": description,
		"transformation_matrix": serialized_matrix,
		"initial_state": serialized_state,
		"parameter_labels": parameter_labels,
		"properties": properties
	}

func deserialize(data: Dictionary):
	"""Deserialize icon definition"""
	name = data.get("name", "")
	emoji = data.get("emoji", "")
	description = data.get("description", "")
	parameter_labels = data.get("parameter_labels", [])
	properties = data.get("properties", {})
	
	# Deserialize transformation matrix
	var matrix_data = data.get("transformation_matrix", [])
	transformation_matrix.clear()
	for row_data in matrix_data:
		transformation_matrix.append(row_data.duplicate())
	
	# Deserialize initial state
	var state_data = data.get("initial_state", [])
	initial_state.clear()
	for component_data in state_data:
		initial_state.append(Vector2(component_data.x, component_data.y))
