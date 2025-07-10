# scripts/ui/canvas/ArtisticSubstrate.gd
class_name ArtisticSubstrate
extends Control

# Artistic substrate for visual effects
var substrate_texture: ImageTexture
var substrate_color: Color = Color.WHITE
var substrate_opacity: float = 1.0

func _ready():
	pass

func set_substrate_texture(texture: ImageTexture):
	substrate_texture = texture

func set_substrate_color(color: Color):
	substrate_color = color
	modulate = color

func set_substrate_opacity(opacity: float):
	substrate_opacity = clamp(opacity, 0.0, 1.0)
	modulate.a = substrate_opacity
