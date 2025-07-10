# scripts/ui/canvas/EffectLayer.gd
class_name EffectLayer
extends Control

# Effect layer for visual effects and overlays
var layer_opacity: float = 1.0
var layer_blend_mode: String = "normal"
var effects: Array[Dictionary] = []

func _ready():
	pass

func add_effect(effect_data: Dictionary):
	"""Add an effect to this layer"""
	effects.append(effect_data)

func remove_effect(effect_index: int):
	"""Remove an effect from this layer"""
	if effect_index >= 0 and effect_index < effects.size():
		effects.remove_at(effect_index)

func clear_effects():
	"""Clear all effects from this layer"""
	effects.clear()

func set_layer_opacity(opacity: float):
	"""Set layer opacity"""
	layer_opacity = clamp(opacity, 0.0, 1.0)
	modulate.a = layer_opacity

func set_blend_mode(mode: String):
	"""Set blend mode"""
	layer_blend_mode = mode
	# Implementation would depend on specific blend mode support

func get_effect_count() -> int:
	"""Get number of effects"""
	return effects.size()

func get_effect(index: int) -> Dictionary:
	"""Get effect at index"""
	if index >= 0 and index < effects.size():
		return effects[index]
	return {}
