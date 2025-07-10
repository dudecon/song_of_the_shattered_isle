# scripts/ui/canvas/SpriteLayer.gd
class_name SpriteLayer
extends Control

var sprite_composer: SpriteComposer
var active_sprites: Array[Node2D] = []
var sprite_pools: Dictionary = {}
var detail_level: float = 1.0

func setup_composer(composer: SpriteComposer):
	sprite_composer = composer
	sprite_composer.sprite_composition_changed.connect(_on_composition_changed)

func update_from_sprite_state(sprite_state: Dictionary):
	if not sprite_composer:
		return
	
	var compositions = sprite_state.get("compositions", {})
	for component_index in compositions:
		_update_component_sprites(component_index, compositions[component_index])

func _on_composition_changed(component_index: int, sprite_data: Array):
	_update_component_sprites(component_index, sprite_data)

func _update_component_sprites(component_index: int, composition: Array):
	# Clear existing sprites for this component
	_clear_component_sprites(component_index)
	
	# Create new sprites
	for sprite_group in composition:
		var sprite_def = sprite_group.get("sprite_definition")
		var count = sprite_group.get("count", 1)
		
		_spawn_sprites(component_index, sprite_def, count)

func _clear_component_sprites(component_index: int):
	for sprite in active_sprites:
		if sprite.has_method("get_component_index") and sprite.get_component_index() == component_index:
			sprite.queue_free()
	
	active_sprites = active_sprites.filter(func(s): return s != null and not s.is_queued_for_deletion())

func _spawn_sprites(component_index: int, sprite_def: SpriteDefinition, count: int):
	for i in range(count):
		var sprite = _create_sprite(sprite_def, component_index)
		active_sprites.append(sprite)
		add_child(sprite)

func _create_sprite(sprite_def: SpriteDefinition, component_index: int) -> Node2D:
	var sprite = Label.new()  # Simple emoji sprite
	sprite.text = sprite_def.emoji
	sprite.add_theme_font_size_override("font_size", 16)
	sprite.position = Vector2(randf_range(0, size.x), randf_range(0, size.y))
	sprite.set_meta("component_index", component_index)
	sprite.set_meta("sprite_definition", sprite_def)
	
	# Add movement behavior
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_move_sprite.bind(sprite), 0.0, 1.0, 2.0)
	
	return sprite

func _move_sprite(sprite: Node2D, progress: float):
	if not sprite or sprite.is_queued_for_deletion():
		return
	
	var movement = Vector2(sin(progress * PI * 2), cos(progress * PI * 2)) * 20
	sprite.position += movement * 0.1

func set_detail_level(level: float):
	detail_level = level
	
	# Adjust sprite visibility based on detail level
	for sprite in active_sprites:
		sprite.visible = level > 0.5

func update_node_sprites(node_index: int, modification_data: Dictionary):
	# Update sprites for specific node changes
	pass

func update_sprite_library(composition_data: Dictionary):
	# Update available sprites based on biome changes
	pass
