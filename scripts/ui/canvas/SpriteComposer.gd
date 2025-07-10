# scripts/ui/canvas/SpriteComposer.gd
class_name SpriteComposer
extends Control

# Sprite composer for creating and managing sprites
var sprite_layers: Array[Dictionary] = []
var composition_size: Vector2 = Vector2(256, 256)
var background_color: Color = Color.TRANSPARENT

signal sprite_composed(sprite_data: Dictionary)
signal layer_added(layer_data: Dictionary)
signal layer_removed(layer_index: int)

func _ready():
	pass

func add_sprite_layer(layer_data: Dictionary):
	"""Add a sprite layer"""
	sprite_layers.append(layer_data)
	layer_added.emit(layer_data)

func remove_sprite_layer(layer_index: int):
	"""Remove a sprite layer"""
	if layer_index >= 0 and layer_index < sprite_layers.size():
		sprite_layers.remove_at(layer_index)
		layer_removed.emit(layer_index)

func compose_sprite() -> Dictionary:
	"""Compose final sprite from layers"""
	var sprite_data = {
		"size": composition_size,
		"background_color": background_color,
		"layers": sprite_layers.duplicate(),
		"timestamp": Time.get_time_dict_from_system()
	}
	
	sprite_composed.emit(sprite_data)
	return sprite_data

func set_composition_size(size: Vector2):
	"""Set composition size"""
	composition_size = size

func set_background_color(color: Color):
	"""Set background color"""
	background_color = color

func get_layer_count() -> int:
	"""Get number of layers"""
	return sprite_layers.size()

func get_layer(index: int) -> Dictionary:
	"""Get layer at index"""
	if index >= 0 and index < sprite_layers.size():
		return sprite_layers[index]
	return {}

func clear_layers():
	"""Clear all layers"""
	sprite_layers.clear()

func duplicate_layer(layer_index: int):
	"""Duplicate a layer"""
	if layer_index >= 0 and layer_index < sprite_layers.size():
		var layer_copy = sprite_layers[layer_index].duplicate()
		sprite_layers.append(layer_copy)
		layer_added.emit(layer_copy)

func move_layer(from_index: int, to_index: int):
	"""Move layer from one position to another"""
	if from_index >= 0 and from_index < sprite_layers.size() and to_index >= 0 and to_index < sprite_layers.size():
		var layer = sprite_layers[from_index]
		sprite_layers.remove_at(from_index)
		sprite_layers.insert(to_index, layer)
