# scripts/ui/dialogs/DecompressionDialog.gd
class_name DecompressionDialog
extends AcceptDialog

# Dialog for node decompression operations
var target_node_index: int = -1
var decompression_options: Dictionary = {}

func _ready():
	title = "Node Decompression"
	_setup_dialog_content()

func _setup_dialog_content():
	"""Setup dialog UI"""
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Select decompression method:"
	vbox.add_child(label)
	
	var option_group = ButtonGroup.new()
	
	var gentle_radio = CheckBox.new()
	gentle_radio.text = "Gentle Decompression"
	gentle_radio.button_pressed = true
	vbox.add_child(gentle_radio)
	
	var aggressive_radio = CheckBox.new()
	aggressive_radio.text = "Aggressive Decompression"
	vbox.add_child(aggressive_radio)
	
	add_child(vbox)

func show_for_node(node_index: int):
	"""Show decompression dialog for node"""
	target_node_index = node_index
	popup_centered()
