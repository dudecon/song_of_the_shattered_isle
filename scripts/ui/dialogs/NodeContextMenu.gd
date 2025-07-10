# scripts/ui/dialogs/NodeContextMenu.gd
class_name NodeContextMenu
extends PopupMenu

# Context menu for node operations
var target_node_index: int = -1

signal node_action_requested(action: String, node_index: int)

func _ready():
	_setup_menu_items()

func _setup_menu_items():
	"""Setup context menu items"""
	add_item("Analyze Node", 0)
	add_item("Compress Node", 1)
	add_item("Deploy Tool", 2)
	add_item("Apply Influence", 3)
	add_separator()
	add_item("Node Details", 4)
	
	id_pressed.connect(_on_item_selected)

func show_for_node(node_index: int, position: Vector2):
	"""Show context menu for specific node"""
	target_node_index = node_index
	popup_on_parent(Rect2(position, Vector2.ZERO))

func _on_item_selected(index: int):
	var actions = ["analyze", "compress", "deploy", "influence", "details"]
	if index < actions.size():
		node_action_requested.emit(actions[index], target_node_index)
