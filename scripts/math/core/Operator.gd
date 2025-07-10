# scripts/math/core/Operator.gd
class_name Operator
extends Resource

var name: String
var node_index: int
var operator_type: String
var properties: Dictionary = {}
var is_active: bool = false

func setup_from_definition(definition: ToolDefinition, target_node_index: int):
	name = definition.name
	node_index = target_node_index
	operator_type = definition.properties.get("type", "generator")
	properties = definition.properties.duplicate()

func start_continuous_operation():
	is_active = true

func stop_continuous_operation():
	is_active = false

func process_continuous_effect(delta_time: float) -> Dictionary:
	if not is_active:
		return {"has_effect": false}
	
	var effect = {"has_effect": true}
	
	match operator_type:
		"generator":
			effect["type"] = "energy_generation"
			effect["amount"] = properties.get("output_rate", 0.1) * delta_time
		"converter":
			effect["type"] = "resource_conversion"
			effect["input_consumed"] = properties.get("input_rate", 0.1) * delta_time
			effect["output_generated"] = properties.get("output_rate", 0.05) * delta_time
		"amplifier":
			effect["type"] = "signal_amplification"
			effect["multiplier"] = properties.get("amplification_factor", 1.2)
		"stabilizer":
			effect["type"] = "stability_enhancement"
			effect["damping"] = properties.get("damping_factor", 0.1)
	
	return effect

func serialize() -> Dictionary:
	return {
		"name": name,
		"node_index": node_index,
		"operator_type": operator_type,
		"properties": properties,
		"is_active": is_active
	}

func deserialize(data: Dictionary):
	name = data.get("name", "")
	node_index = data.get("node_index", 0)
	operator_type = data.get("operator_type", "generator")
	properties = data.get("properties", {})
	is_active = data.get("is_active", false)
