# scripts/ui/canvas/ZoomController.gd
class_name ZoomController
extends Control

# Zoom controller for canvas navigation
var zoom_level: float = 1.0
var min_zoom: float = 0.1
var max_zoom: float = 10.0
var zoom_speed: float = 0.1
var pan_offset: Vector2 = Vector2.ZERO

signal zoom_changed(new_zoom: float)
signal pan_changed(new_offset: Vector2)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out(event.position)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				# Start panning
				pass
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			pan(event.relative)

func zoom_in(focus_point: Vector2 = Vector2.ZERO):
	"""Zoom in towards focus point"""
	var old_zoom = zoom_level
	zoom_level = clamp(zoom_level + zoom_speed, min_zoom, max_zoom)
	_apply_zoom(old_zoom, focus_point)

func zoom_out(focus_point: Vector2 = Vector2.ZERO):
	"""Zoom out from focus point"""
	var old_zoom = zoom_level
	zoom_level = clamp(zoom_level - zoom_speed, min_zoom, max_zoom)
	_apply_zoom(old_zoom, focus_point)

func set_zoom(new_zoom: float, focus_point: Vector2 = Vector2.ZERO):
	"""Set zoom level"""
	var old_zoom = zoom_level
	zoom_level = clamp(new_zoom, min_zoom, max_zoom)
	_apply_zoom(old_zoom, focus_point)

func _apply_zoom(old_zoom: float, focus_point: Vector2):
	"""Apply zoom change"""
	scale = Vector2(zoom_level, zoom_level)
	
	# Adjust pan offset to zoom towards focus point
	if focus_point != Vector2.ZERO:
		var zoom_factor = zoom_level / old_zoom
		pan_offset = (pan_offset - focus_point) * zoom_factor + focus_point
		position = pan_offset
	
	zoom_changed.emit(zoom_level)

func pan(delta: Vector2):
	"""Pan the view"""
	pan_offset += delta
	position = pan_offset
	pan_changed.emit(pan_offset)

func reset_view():
	"""Reset zoom and pan to defaults"""
	zoom_level = 1.0
	pan_offset = Vector2.ZERO
	scale = Vector2.ONE
	position = Vector2.ZERO
	zoom_changed.emit(zoom_level)
	pan_changed.emit(pan_offset)

func get_zoom_level() -> float:
	"""Get current zoom level"""
	return zoom_level

func get_pan_offset() -> Vector2:
	"""Get current pan offset"""
	return pan_offset
