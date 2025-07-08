# scripts/ui/NumberedTarget.gd
class_name NumberedTarget
extends Control

var target_number: int = 1
var is_highlighted: bool = false
var background: ColorRect
var number_label: Label

signal target_selected(target_num: int)

func _init():
	size = Vector2(60, 60)
	
	# Create background
	background = ColorRect.new()
	background.size = size
	background.color = Color(0.2, 0.2, 0.3, 0.8)
	add_child(background)
	
	# Create number label
	number_label = Label.new()
	number_label.size = size
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number_label.add_theme_font_size_override("font_size", 20)
	add_child(number_label)

func _ready():
	number_label.text = str(target_number)
	
	# Make clickable
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_selected.emit(target_number)

func _on_mouse_entered():
	if is_highlighted:
		background.color = Color(0.4, 0.6, 0.8, 0.9)

func _on_mouse_exited():
	_update_visual_state()

func set_highlighted(highlighted: bool):
	is_highlighted = highlighted
	_update_visual_state()

func _update_visual_state():
	if is_highlighted:
		background.color = Color(0.3, 0.5, 0.7, 0.8)
		number_label.modulate = Color.WHITE
	else:
		background.color = Color(0.2, 0.2, 0.3, 0.5)
		number_label.modulate = Color(0.6, 0.6, 0.6, 0.8)
