# scripts/utils/ResourceManager.gd
class_name ResourceManager
extends Resource

# Simple resource management for tool deployment costs

var resources: Dictionary = {}

func _init():
	_initialize_resources()

func _initialize_resources():
	"""Initialize default resources"""
	resources = {
		"energy": 100.0,
		"materials": 50.0,
		"favor": 25.0,
		"influence": 75.0
	}

func has_resources(cost: Dictionary) -> bool:
	"""Check if we have enough resources"""
	for resource_type in cost:
		var required = cost[resource_type]
		var available = resources.get(resource_type, 0.0)
		if available < required:
			return false
	return true

func consume_resources(cost: Dictionary):
	"""Consume resources"""
	for resource_type in cost:
		var required = cost[resource_type]
		var current = resources.get(resource_type, 0.0)
		resources[resource_type] = max(0.0, current - required)

func get_resource(resource_type: String) -> float:
	"""Get specific resource amount"""
	return resources.get(resource_type, 0.0)

func add_resource(resource_type: String, amount: float):
	"""Add resource"""
	var current = resources.get(resource_type, 0.0)
	resources[resource_type] = current + amount

func serialize() -> Dictionary:
	"""Serialize resources"""
	return {"resources": resources}

func deserialize(data: Dictionary):
	"""Deserialize resources"""
	resources = data.get("resources", {})
	if resources.is_empty():
		_initialize_resources()
