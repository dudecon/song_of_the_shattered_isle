# scripts/ui/controls/ToolPalette.gd
class_name ToolPalette
extends VBoxContainer

var active_tool: Tool = null
var tool_buttons: Array[Button] = []
var tools: Array[Tool] = []

signal tool_selected(tool: Tool)

func setup_tools(available_tools: Array[Tool]):
	tools = available_tools
	_create_tool_buttons()

func _create_tool_buttons():
	for tool in tools:
		var button = Button.new()
		button.text = tool.symbol + " " + tool.name
		button.pressed.connect(_on_tool_button_pressed.bind(tool))
		button.custom_minimum_size = Vector2(150, 40)
		
		tool_buttons.append(button)
		add_child(button)

func _on_tool_button_pressed(tool: Tool):
	set_active_tool(tool)
	tool_selected.emit(tool)

func set_active_tool(tool: Tool):
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

class Tool:
	var name: String
	var symbol: String
	var is_single_use: bool = false
	var cursor_shape: Input.CursorShape = Input.CURSOR_ARROW
	
	func _init(tool_name: String, tool_symbol: String):
		name = tool_name
		symbol = tool_symbol
