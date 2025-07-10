# scripts/ui/dialogs/OperatorManagerDialog.gd
class_name OperatorManagerDialog
extends AcceptDialog

# Dialog for managing operators
var available_operators: Array[String] = []
var selected_operator: String = ""

func _ready():
	title = "Operator Manager"
	_setup_dialog_content()

func _setup_dialog_content():
	"""Setup dialog UI"""
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Available Operators:"
	vbox.add_child(label)
	
	var operator_list = ItemList.new()
	operator_list.custom_minimum_size = Vector2(300, 200)
	vbox.add_child(operator_list)
	
	add_child(vbox)

func show_operator_manager():
	"""Show operator manager dialog"""
	popup_centered()
