# scripts/ui/controls/ToolPalette.gd
class_name ToolPalette
extends VBoxContainer

var active_tool: BiomeTool = null
var tool_buttons: Array[Button] = []
var tools: Array[BiomeTool] = []

signal tool_selected(tool: BiomeTool)

func _ready():
	_initialize_default_tools()

func _initialize_default_tools():
	"""Initialize with default tools"""
	var spark_tool = BiomeTool.new()
	spark_tool.tool_name = "Spark"
	spark_tool.tool_icon = "➕"
	spark_tool.tool_type = "additive"
	tools.append(spark_tool)
	
	var druid_tool = BiomeTool.new()
	druid_tool.tool_name = "Druid"
	druid_tool.tool_icon = "✖️"
	druid_tool.tool_type = "multiplicative"
	tools.append(druid_tool)
	
	var analysis_tool = BiomeTool.new()
	analysis_tool.tool_name = "Analysis"
	analysis_tool.tool_icon = "🔍"
	analysis_tool.tool_type = "informational"
	tools.append(analysis_tool)
	
	_create_tool_buttons()

func setup_tools(available_tools: Array[BiomeTool]):
	"""Setup palette with specific tools"""
	tools = available_tools
	_clear_buttons()
	_create_tool_buttons()

func setup_from_tool_definitions(definitions: Array[ToolDefinition]):
	"""Setup tools from ToolDefinitions"""
	tools.clear()
	for definition in definitions:
		var biome_tool = BiomeTool.new()
		biome_tool = biome_tool.create_from_definition(definition)
		tools.append(biome_tool)
	
	_clear_buttons()
	_create_tool_buttons()

func _clear_buttons():
	"""Clear existing buttons"""
	for button in tool_buttons:
		if button and is_instance_valid(button):
			button.queue_free()
	tool_buttons.clear()

func _create_tool_buttons():
	"""Create buttons for tools"""
	for tool in tools:
		var button = Button.new()
		button.text = tool.tool_icon + " " + tool.tool_name
		button.pressed.connect(_on_tool_button_pressed.bind(tool))
		button.custom_minimum_size = Vector2(150, 40)
		
		tool_buttons.append(button)
		add_child(button)

func _on_tool_button_pressed(tool: BiomeTool):
	set_active_tool(tool)
	tool_selected.emit(tool)

func set_active_tool(tool: BiomeTool):
	active_tool = tool
	
	# Update button states
	for i in range(tool_buttons.size()):
		var button = tool_buttons[i]
		if i < tools.size() and tools[i] == tool:
			button.modulate = Color.YELLOW
		else:
			button.modulate = Color.WHITE

func clear_active_tool():
	active_tool = null
	for button in tool_buttons:
		button.modulate = Color.WHITE

func get_active_tool() -> BiomeTool:
	return active_tool

func get_tool_count() -> int:
	return tools.size()

func get_tool(index: int) -> BiomeTool:
	if index >= 0 and index < tools.size():
		return tools[index]
	return null

func get_tool_by_name(tool_name: String) -> BiomeTool:
	"""Get tool by name"""
	for tool in tools:
		if tool.tool_name == tool_name:
			return tool
	return null

func add_tool(tool: BiomeTool):
	"""Add a tool to the palette"""
	tools.append(tool)
	_clear_buttons()
	_create_tool_buttons()

func remove_tool(tool: BiomeTool):
	"""Remove a tool from the palette"""
	var index = tools.find(tool)
	if index >= 0:
		tools.remove_at(index)
		_clear_buttons()
		_create_tool_buttons()

func has_tool(tool_name: String) -> bool:
	"""Check if palette has tool"""
	return get_tool_by_name(tool_name) != null
