# scripts/math/biome/BiomeGraphNode.gd
class_name BiomeGraphNode
extends Resource

# Individual node in the biome graph system
# Renamed from GraphNode to avoid collision with Godot's built-in GraphNode

var index: int = 0
var position: Vector2 = Vector2.ZERO
var label: String = ""
var emoji: String = "🔹"
var is_compressed: bool = false
var influence_strength: float = 0.0
var icon_type: String = ""

func _init():
	pass

func setup(node_index: int, node_position: Vector2, node_label: String, node_emoji: String):
	"""Setup node with initial data"""
	index = node_index
	position = node_position
	label = node_label
	emoji = node_emoji
	is_compressed = false
	influence_strength = 0.0
	icon_type = ""

func get_node_info() -> Dictionary:
	"""Get node information"""
	return {
		"index": index,
		"position": position,
		"label": label,
		"emoji": emoji,
		"is_compressed": is_compressed,
		"influence_strength": influence_strength,
		"icon_type": icon_type
	}

func serialize() -> Dictionary:
	"""Serialize node data"""
	return {
		"index": index,
		"position": {"x": position.x, "y": position.y},
		"label": label,
		"emoji": emoji,
		"is_compressed": is_compressed,
		"influence_strength": influence_strength,
		"icon_type": icon_type
	}

func deserialize(data: Dictionary):
	"""Deserialize node data"""
	index = data.get("index", 0)
	label = data.get("label", "")
	emoji = data.get("emoji", "🔹")
	is_compressed = data.get("is_compressed", false)
	influence_strength = data.get("influence_strength", 0.0)
	icon_type = data.get("icon_type", "")
	
	var pos_data = data.get("position", {"x": 0, "y": 0})
	position = Vector2(pos_data.x, pos_data.y)
