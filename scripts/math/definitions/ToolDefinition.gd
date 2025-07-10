# scripts/math/definitions/ToolDefinition.gd
class_name ToolDefinition
extends Resource

var name: String
var symbol: String
var description: String
var properties: Dictionary = {}

func setup(tool_name: String, tool_symbol: String, tool_description: String, tool_properties: Dictionary = {}):
	name = tool_name
	symbol = tool_symbol
	description = tool_description
	properties = tool_properties

func get_resource_cost() -> Dictionary:
	return properties.get("resource_cost", {})

func serialize() -> Dictionary:
	return {
		"name": name,
		"symbol": symbol,
		"description": description,
		"properties": properties
	}

func deserialize(data: Dictionary):
	name = data.get("name", "")
	symbol = data.get("symbol", "")
	description = data.get("description", "")
	properties = data.get("properties", {})
