# scripts/ui/controls/HotkeyBindings.gd
class_name HotkeyBindings
extends Resource

var key_mappings: Dictionary = {}
var default_mappings: Dictionary = {}

func load_from_layer3_settings():
	# Load from user settings (stub for now)
	pass

func set_default_bindings(bindings: Dictionary):
	default_mappings = bindings
	key_mappings = bindings.duplicate()

func get_tool_for_key(keycode: int) -> String:
	var key_string = OS.get_keycode_string(keycode)
	return key_mappings.get(key_string, "")

func set_binding(key: String, tool_name: String):
	key_mappings[key] = tool_name

func get_bindings() -> Dictionary:
	return key_mappings.duplicate()
