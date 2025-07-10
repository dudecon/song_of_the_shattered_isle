# scripts/math/systems/InfluenceBudget.gd
class_name InfluenceBudget
extends Resource

# Resource management for influence painting and tool deployment

var resources: Dictionary = {}
var resource_limits: Dictionary = {}
var regeneration_rates: Dictionary = {}
var time_accumulator: float = 0.0

func _init():
	_initialize_default_budget()

func _initialize_default_budget():
	"""Initialize default resource budget"""
	resources = {
		"influence": 100.0,
		"energy": 50.0,
		"materials": 25.0,
		"favor": 20.0
	}
	
	resource_limits = {
		"influence": 150.0,
		"energy": 100.0,
		"materials": 50.0,
		"favor": 30.0
	}
	
	regeneration_rates = {
		"influence": 2.0,  # per second
		"energy": 1.0,
		"materials": 0.5,
		"favor": 0.3
	}

func can_afford(cost: float) -> bool:
	"""Check if we can afford a generic influence cost"""
	return resources.get("influence", 0.0) >= cost

func can_afford_resources(cost_dict: Dictionary) -> bool:
	"""Check if we can afford specific resource costs"""
	for resource_type in cost_dict:
		var cost = cost_dict[resource_type]
		var available = resources.get(resource_type, 0.0)
		if available < cost:
			return false
	return true

func spend(cost: float):
	"""Spend generic influence cost"""
	resources["influence"] = max(0.0, resources["influence"] - cost)

func spend_resources(cost_dict: Dictionary):
	"""Spend specific resources"""
	for resource_type in cost_dict:
		var cost = cost_dict[resource_type]
		var current = resources.get(resource_type, 0.0)
		resources[resource_type] = max(0.0, current - cost)

func regenerate(delta_time: float):
	"""Regenerate resources over time"""
	time_accumulator += delta_time
	
	# Regenerate every 0.1 seconds
	if time_accumulator >= 0.1:
		var regen_delta = time_accumulator
		time_accumulator = 0.0
		
		for resource_type in resources:
			var current = resources[resource_type]
			var limit = resource_limits.get(resource_type, 100.0)
			var rate = regeneration_rates.get(resource_type, 1.0)
			
			if current < limit:
				var regen_amount = rate * regen_delta
				resources[resource_type] = min(limit, current + regen_amount)

func get_budget_data() -> Dictionary:
	"""Get budget data"""
	return {
		"resources": resources,
		"resource_limits": resource_limits,
		"regeneration_rates": regeneration_rates
	}

func get_resource(resource_type: String) -> float:
	"""Get specific resource amount"""
	return resources.get(resource_type, 0.0)

func add_resource(resource_type: String, amount: float):
	"""Add resource amount"""
	var current = resources.get(resource_type, 0.0)
	var limit = resource_limits.get(resource_type, 100.0)
	resources[resource_type] = min(limit, current + amount)

func serialize() -> Dictionary:
	"""Serialize budget"""
	return {
		"resources": resources,
		"resource_limits": resource_limits,
		"regeneration_rates": regeneration_rates
	}

func deserialize(data: Dictionary):
	"""Deserialize budget"""
	resources = data.get("resources", {})
	resource_limits = data.get("resource_limits", {})
	regeneration_rates = data.get("regeneration_rates", {})
	
	if resources.is_empty():
		_initialize_default_budget()
