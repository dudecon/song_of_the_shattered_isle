# scripts/ui/canvas/InfluenceInterface.gd
class_name InfluenceInterface
extends Control

# Interface for managing influence painting and effects
var influence_strength: float = 1.0
var influence_radius: float = 50.0
var influence_type: String = "attract"
var active_influence: bool = false

signal influence_applied(position: Vector2, strength: float, radius: float, type: String)
signal influence_stopped()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_influence(event.position)
			else:
				stop_influence()
	elif event is InputEventMouseMotion and active_influence:
		continue_influence(event.position)

func start_influence(position: Vector2):
	"""Start applying influence at position"""
	active_influence = true
	apply_influence(position)

func continue_influence(position: Vector2):
	"""Continue applying influence at position"""
	if active_influence:
		apply_influence(position)

func stop_influence():
	"""Stop applying influence"""
	active_influence = false
	influence_stopped.emit()

func apply_influence(position: Vector2):
	"""Apply influence at position"""
	influence_applied.emit(position, influence_strength, influence_radius, influence_type)

func set_influence_strength(strength: float):
	"""Set influence strength"""
	influence_strength = clamp(strength, 0.1, 10.0)

func set_influence_radius(radius: float):
	"""Set influence radius"""
	influence_radius = clamp(radius, 5.0, 200.0)

func set_influence_type(type: String):
	"""Set influence type"""
	influence_type = type

func get_influence_settings() -> Dictionary:
	"""Get current influence settings"""
	return {
		"strength": influence_strength,
		"radius": influence_radius,
		"type": influence_type,
		"active": active_influence
	}

func is_influence_active() -> bool:
	"""Check if influence is currently active"""
	return active_influence
