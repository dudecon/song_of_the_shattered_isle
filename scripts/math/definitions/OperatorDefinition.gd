# scripts/math/definitions/OperatorDefinition.gd
class_name OperatorDefinition
extends Resource

# Definition of an operator with its properties

var name: String
var display_name: String
var operator_type: String
var properties: Dictionary = {}

func _init():
	pass

func setup(op_name: String, op_display_name: String, op_type: String, op_properties: Dictionary = {}):
	"""Setup operator definition"""
	name = op_name
	display_name = op_display_name
	operator_type = op_type
	properties = op_properties

func get_resource_cost() -> Dictionary:
	"""Get resource cost for this operator"""
	return properties.get("resource_cost", {})

func get_output_rate() -> float:
	"""Get output rate for this operator"""
	return properties.get("output_rate", 0.1)

func get_efficiency() -> float:
	"""Get efficiency for this operator"""
	return properties.get("efficiency", 1.0)

func serialize() -> Dictionary:
	"""Serialize operator definition"""
	return {
		"name": name,
		"display_name": display_name,
		"operator_type": operator_type,
		"properties": properties
	}

func deserialize(data: Dictionary):
	"""Deserialize operator definition"""
	name = data.get("name", "")
	display_name = data.get("display_name", "")
	operator_type = data.get("operator_type", "")
	properties = data.get("properties", {})
