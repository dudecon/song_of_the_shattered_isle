# scripts/ui/canvas/BiomeTool.gd
class_name BiomeTool
extends Resource

# Renamed from Tool to avoid conflicts with Godot's built-in Tool class
@export var tool_name: String = ""
@export var tool_type: String = ""
@export var tool_icon: String = "🔧"
@export var tool_size: float = 10.0
@export var tool_strength: float = 1.0
@export var tool_color: Color = Color.WHITE

# Tool properties
var tool_properties: Dictionary = {}
var cursor_shape: Input.CursorShape = Input.CURSOR_ARROW

func _init():
	pass

func get_tool_info() -> Dictionary:
	"""Get tool information"""
	return {
		"name": tool_name,
		"type": tool_type,
		"icon": tool_icon,
		"size": tool_size,
		"strength": tool_strength,
		"color": tool_color,
		"properties": tool_properties
	}

func apply_tool(canvas: Control, position: Vector2) -> bool:
	"""Apply tool to canvas at position"""
	match tool_type:
		"paint":
			return _apply_paint(canvas, position)
		"erase":
			return _apply_erase(canvas, position)
		"modify":
			return _apply_modify(canvas, position)
		"additive":
			return _apply_additive(canvas, position)
		"multiplicative":
			return _apply_multiplicative(canvas, position)
		"informational":
			return _apply_informational(canvas, position)
		_:
			return false

func _apply_paint(canvas: Control, position: Vector2) -> bool:
	"""Apply paint tool"""
	print("Paint tool applied at: ", position)
	return true

func _apply_erase(canvas: Control, position: Vector2) -> bool:
	"""Apply erase tool"""
	print("Erase tool applied at: ", position)
	return true

func _apply_modify(canvas: Control, position: Vector2) -> bool:
	"""Apply modify tool"""
	print("Modify tool applied at: ", position)
	return true

func _apply_additive(canvas: Control, position: Vector2) -> bool:
	"""Apply additive tool (like spark)"""
	print("Additive tool applied at: ", position)
	return true

func _apply_multiplicative(canvas: Control, position: Vector2) -> bool:
	"""Apply multiplicative tool (like druid)"""
	print("Multiplicative tool applied at: ", position)
	return true

func _apply_informational(canvas: Control, position: Vector2) -> bool:
	"""Apply informational tool (like analysis)"""
	print("Informational tool applied at: ", position)
	return true

func set_property(key: String, value):
	"""Set tool property"""
	tool_properties[key] = value

func get_property(key: String, default_value = null):
	"""Get tool property"""
	return tool_properties.get(key, default_value)

func duplicate_tool() -> BiomeTool:
	"""Create a copy of this tool"""
	var new_tool = BiomeTool.new()
	new_tool.tool_name = tool_name
	new_tool.tool_type = tool_type
	new_tool.tool_icon = tool_icon
	new_tool.tool_size = tool_size
	new_tool.tool_strength = tool_strength
	new_tool.tool_color = tool_color
	new_tool.tool_properties = tool_properties.duplicate()
	new_tool.cursor_shape = cursor_shape
	return new_tool

func create_from_definition(definition: ToolDefinition) -> BiomeTool:
	"""Create BiomeTool from ToolDefinition"""
	var biome_tool = BiomeTool.new()
	biome_tool.tool_name = definition.name
	biome_tool.tool_icon = definition.symbol
	biome_tool.tool_type = definition.properties.get("type", "modify")
	biome_tool.tool_properties = definition.properties.duplicate()
	
	# Set cursor based on tool type
	match biome_tool.tool_type:
		"additive":
			biome_tool.cursor_shape = Input.CURSOR_POINTING_HAND
		"multiplicative":
			biome_tool.cursor_shape = Input.CURSOR_CROSS
		"informational":
			biome_tool.cursor_shape = Input.CURSOR_HELP
		_:
			biome_tool.cursor_shape = Input.CURSOR_ARROW
	
	return biome_tool
