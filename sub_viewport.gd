extends Node

func _ready():
	var subviewport = %SubViewport # Adjust path to your SubViewport
	var material = %WaterPlane.get_surface_override_material(0) # Adjust path to your plane
	if subviewport and material:
		var depth_texture = subviewport.get_texture().get_depth_texture()
		if depth_texture:
			material.set_shader_parameter("depth_texture", depth_texture)
		else:
			print("Error: Depth texture not available from SubViewport.")
