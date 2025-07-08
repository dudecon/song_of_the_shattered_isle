# scripts/ui/IconSwitcher.gd
class_name IconSwitcher
extends Control

@onready var icon_list: VBoxContainer = $IconPanel/ScrollContainer/IconList
@onready var icon_panel: Panel = $IconPanel
@onready var current_icon_label: Label = $CurrentIconDisplay/IconName
@onready var icon_description: Label = $CurrentIconDisplay/IconDescription
@onready var dimension_label: Label = $CurrentIconDisplay/DimensionLabel

var conductor: QuantumConductor
var available_icons: Array[IconDefinition] = []
var current_icon_index: int = 0

signal icon_switched(icon_name: String)

func _ready():
	_load_available_icons()
	_setup_ui()
	_find_conductor()

func _find_conductor():
	# Find the QuantumConductor in the scene
	var root = get_tree().root
	conductor = root.get_node_or_null("Main/QuantumConductor")
	if not conductor:
		# Try alternative path
		conductor = get_parent().get_node_or_null("QuantumConductor")
	
	if conductor:
		conductor.icon_loaded.connect(_on_icon_loaded)
		_update_current_icon_display()

func _load_available_icons():
	available_icons = IconLibrary.get_all_icons()

func _setup_ui():
	# Create icon selection buttons
	for i in range(available_icons.size()):
		var icon = available_icons[i]
		var button = Button.new()
		button.text = icon.name
		button.custom_minimum_size = Vector2(0, 40)
		button.pressed.connect(_on_icon_selected.bind(i))
		
		# Add visual flair
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
		style.border_width_left = 3
		style.border_color = Color(0.4, 0.6, 1.0, 0.8)
		button.add_theme_stylebox_override("normal", style)
		
		# Add emoji and description
		var emoji = _get_primary_emoji(icon)
		button.text = emoji + " " + icon.name
		
		icon_list.add_child(button)
	
	# Initially hide the panel
	icon_panel.visible = false

func _get_primary_emoji(icon: IconDefinition) -> String:
	if icon.emoji_mapping.has(0):
		return icon.emoji_mapping[0]
	return "🔹"

func _on_icon_selected(index: int):
	if index >= 0 and index < available_icons.size():
		current_icon_index = index
		var selected_icon = available_icons[index]
		
		if conductor:
			conductor.load_icon(selected_icon)
			icon_switched.emit(selected_icon.name)
		
		# Hide the selection panel
		icon_panel.visible = false
		
		print("Switched to icon: ", selected_icon.name)

func _on_icon_loaded(icon_name: String):
	_update_current_icon_display()

func _update_current_icon_display():
	if conductor and conductor.current_icon:
		var icon = conductor.current_icon
		var emoji = _get_primary_emoji(icon)
		current_icon_label.text = emoji + " " + icon.name
		icon_description.text = icon.description
		dimension_label.text = "Dimensions: " + str(icon.dimension)

func toggle_icon_panel():
	icon_panel.visible = not icon_panel.visible

func _input(event):
	if event is InputEventKey and event.pressed:
		# Quick icon switching with number keys
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var index = event.keycode - KEY_1
			if index < available_icons.size():
				_on_icon_selected(index)
		
		# Tab key toggles icon panel
		elif event.keycode == KEY_TAB:
			toggle_icon_panel()
			get_viewport().set_input_as_handled()

# Scene structure for this UI component:
# IconSwitcher (Control)
# ├── CurrentIconDisplay (VBoxContainer)
# │   ├── IconName (Label)
# │   ├── IconDescription (Label)
# │   └── DimensionLabel (Label)
# └── IconPanel (Panel)
#     └── ScrollContainer (ScrollContainer)
#         └── IconList (VBoxContainer)

func _create_ui_structure():
	# This function shows how to create the UI structure programmatically
	# if not using the scene editor
	
	# Current icon display
	var current_display = VBoxContainer.new()
	current_display.name = "CurrentIconDisplay"
	current_display.anchors_preset = Control.PRESET_TOP_LEFT
	current_display.position = Vector2(20, 20)
	current_display.size = Vector2(300, 100)
	
	current_icon_label = Label.new()
	current_icon_label.name = "IconName"
	current_icon_label.text = "🔹 Loading..."
	current_icon_label.add_theme_font_size_override("font_size", 18)
	current_display.add_child(current_icon_label)
	
	icon_description = Label.new()
	icon_description.name = "IconDescription"
	icon_description.text = "Initializing mathematical system..."
	icon_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	icon_description.add_theme_font_size_override("font_size", 12)
	current_display.add_child(icon_description)
	
	dimension_label = Label.new()
	dimension_label.name = "DimensionLabel"
	dimension_label.text = "Dimensions: 0"
	dimension_label.add_theme_font_size_override("font_size", 10)
	current_display.add_child(dimension_label)
	
	add_child(current_display)
	
	# Icon selection panel
	icon_panel = Panel.new()
	icon_panel.name = "IconPanel"
	icon_panel.anchors_preset = Control.PRESET_CENTER
	icon_panel.size = Vector2(400, 300)
	icon_panel.position = Vector2(-200, -150)
	
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.anchors_preset = Control.PRESET_FULL_RECT
	scroll.size = icon_panel.size
	
	icon_list = VBoxContainer.new()
	icon_list.name = "IconList"
	scroll.add_child(icon_list)
	icon_panel.add_child(scroll)
	add_child(icon_panel)
