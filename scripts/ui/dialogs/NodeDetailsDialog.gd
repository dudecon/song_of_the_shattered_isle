# scripts/ui/dialogs/NodeDetailsDialog.gd
class_name NodeDetailsDialog
extends AcceptDialog

# Dialog for showing detailed node information
var node_data: Dictionary = {}

func _ready():
	title = "Node Details"
	_setup_dialog_content()

func _setup_dialog_content():
	"""Setup dialog UI"""
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(400, 300)
	
	var vbox = VBoxContainer.new()
	scroll.add_child(vbox)
	add_child(scroll)

func show_node_details(node_index: int, data: Dictionary):
	"""Show details for specific node"""
	node_data = data
	_update_display()
	popup_centered()

func _update_display():
	"""Update the display with node data"""
	# Implementation would populate the dialog with node information
	pass
