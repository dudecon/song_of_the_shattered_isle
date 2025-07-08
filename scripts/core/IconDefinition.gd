# scripts/core/IconDefinition.gd
class_name IconDefinition
extends Resource

@export var name: String = ""
@export var dimension: int = 7
@export var initial_state: Array[Vector2] = []
@export var transformation_matrix: Array[Array] = []
@export var parameter_labels: Array[String] = []
@export var emoji_mapping: Dictionary = {}
@export var evolution_rate: float = 0.02
@export var description: String = ""

func _init():
	if initial_state.is_empty():
		_generate_default_state()
	if transformation_matrix.is_empty():
		_generate_identity_matrix()

func _generate_default_state():
	initial_state.clear()
	for i in range(dimension):
		var random_magnitude = randf_range(0.1, 0.8)
		var random_phase = randf_range(-PI, PI)
		initial_state.append(Vector2(random_magnitude * cos(random_phase), random_magnitude * sin(random_phase)))

func _generate_identity_matrix():
	transformation_matrix.clear()
	for i in range(dimension):
		var row: Array = []
		for j in range(dimension):
			row.append(0.05 if i == j else 0.0)  # Small self-reinforcement
		transformation_matrix.append(row)

func get_component_info(index: int) -> Dictionary:
	if index >= 0 and index < parameter_labels.size():
		return {
			"label": parameter_labels[index],
			"emoji": emoji_mapping.get(index, "❓"),
			"magnitude": initial_state[index].length() if index < initial_state.size() else 0.0,
			"phase": initial_state[index].angle() if index < initial_state.size() else 0.0
		}
	return {}
