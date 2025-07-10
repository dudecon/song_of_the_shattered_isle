# scripts/math/definitions/SpriteDefinition.gd
class_name SpriteDefinition
extends Resource

# Definition of a sprite with its mathematical properties

var name: String
var energy_weight: float
var emoji: String
var visual_properties: Dictionary = {}
var behavior_properties: Dictionary = {}
var biome_affinity: Array[String] = []

func _init(sprite_name: String = "", weight: float = 1.0, sprite_emoji: String = "❓"):
	name = sprite_name
	energy_weight = weight
	emoji = sprite_emoji

func setup(sprite_name: String, weight: float, sprite_emoji: String, properties: Dictionary = {}):
	"""Setup sprite definition with properties"""
	name = sprite_name
	energy_weight = weight
	emoji = sprite_emoji
	visual_properties = properties.get("visual", {})
	behavior_properties = properties.get("behavior", {})
	biome_affinity = properties.get("biome_affinity", [])

func get_display_name() -> String:
	"""Get display name for this sprite"""
	return emoji + " " + name

func get_energy_per_sprite() -> float:
	"""Get energy weight of individual sprite"""
	return energy_weight

func is_suitable_for_biome(biome_name: String) -> bool:
	"""Check if sprite is suitable for a specific biome"""
	return biome_affinity.is_empty() or biome_name in biome_affinity

func get_visual_scale() -> float:
	"""Get visual scale multiplier"""
	return visual_properties.get("scale", 1.0)

func get_movement_speed() -> float:
	"""Get movement speed multiplier"""
	return behavior_properties.get("speed", 1.0)

func get_color_tint() -> Color:
	"""Get color tint for this sprite"""
	var color_data = visual_properties.get("color", [1.0, 1.0, 1.0, 1.0])
	return Color(color_data[0], color_data[1], color_data[2], color_data[3])

func serialize() -> Dictionary:
	"""Serialize sprite definition"""
	return {
		"name": name,
		"energy_weight": energy_weight,
		"emoji": emoji,
		"visual_properties": visual_properties,
		"behavior_properties": behavior_properties,
		"biome_affinity": biome_affinity
	}

func deserialize(data: Dictionary):
	"""Deserialize sprite definition"""
	name = data.get("name", "")
	energy_weight = data.get("energy_weight", 1.0)
	emoji = data.get("emoji", "❓")
	visual_properties = data.get("visual_properties", {})
	behavior_properties = data.get("behavior_properties", {})
	biome_affinity = data.get("biome_affinity", [])
