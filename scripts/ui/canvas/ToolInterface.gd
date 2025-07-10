# scripts/ui/canvas/ToolInterface.gd
class_name ToolInterface
extends Control

# Tool interface for biome canvas manipulation
var current_tool: BiomeTool
var tool_palette: Array[BiomeTool] = []
var tool_size: float = 10.0
var tool_strength: float = 1.0

signal tool_selected(tool: BiomeTool)
signal tool_applied(position: Vector2, tool: BiomeTool)

func _ready():
	_initialize_default_tools()

func _initialize_default_tools():
	"""Initialize default tool set"""
	# Create basic tools
	var brush_tool = BiomeTool.new()
	brush_tool.tool_name = "Brush"
	brush_tool.tool_type = "paint"
	brush_tool.tool_icon = "🖌️"
	tool_palette.append(brush_tool)
	
	var eraser_tool = BiomeTool.new()
	eraser_tool.tool_name = "Eraser"
	eraser_tool.tool_type = "erase"
	eraser_tool.tool_icon = "🧹"
	tool_palette.append(eraser_tool)
	
	var spark_tool = BiomeTool.new()
	spark_tool.tool_name = "Spark"
	spark_tool.tool_type = "additive"
	spark_tool.tool_icon = "➕"
	tool_palette.append(spark_tool)
	
	var druid_tool = BiomeTool.new()
	druid_tool.tool_name = "Druid"
	druid_tool.tool_type = "multiplicative"
	druid_tool.tool_icon = "✖️"
	tool_palette.append(druid_tool)
	
	var analysis_tool = BiomeTool.new()
	analysis_tool.tool_name = "Analysis"
	analysis_tool.tool_type = "informational"
	analysis_tool.tool_icon = "🔍"
	tool_palette.append(analysis_tool)
	
	# Set default tool
	if tool_palette.size() > 0:
		current_tool = tool_palette[0]

func select_tool(tool: BiomeTool):
	"""Select a tool for use"""
	current_tool = tool
	tool_selected.emit(tool)

func get_tool(tool_name: String) -> BiomeTool:
	"""Get tool by name"""
	for tool in tool_palette:
		if tool.tool_name == tool_name:
			return tool
	return null

func apply_tool(position: Vector2):
	"""Apply current tool at position"""
	if current_tool:
		tool_applied.emit(position, current_tool)

func get_current_tool() -> BiomeTool:
	"""Get currently selected tool"""
	return current_tool

func set_tool_size(size: float):
	"""Set tool size"""
	tool_size = clamp(size, 1.0, 100.0)

func set_tool_strength(strength: float):
	"""Set tool strength"""
	tool_strength = clamp(strength, 0.1, 10.0)

func get_tool_palette() -> Array[BiomeTool]:
	"""Get available tools"""
	return tool_palette

func add_tool_from_definition(definition: ToolDefinition):
	"""Add tool from ToolDefinition"""
	var biome_tool = BiomeTool.new()
	biome_tool = biome_tool.create_from_definition(definition)
	tool_palette.append(biome_tool)

func setup_from_tool_definitions(definitions: Array[ToolDefinition]):
	"""Setup tools from ToolDefinitions"""
	tool_palette.clear()
	for definition in definitions:
		add_tool_from_definition(definition)
	
	# Set default tool
	if tool_palette.size() > 0:
		current_tool = tool_palette[0]

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			apply_tool(event.position)
