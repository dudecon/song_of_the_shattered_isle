# scripts/math/systems/SpriteState.gd
class_name SpriteState
extends Resource

# Sprite state management system

var total_sprite_count: int = 0
var sprites_per_component: Array[int] = []
var target_energy_per_component: Array[float] = []
var current_sprite_composition: Dictionary = {}
var biome_sprite_sets: Dictionary = {}
var sprite_library: SpriteLibrary

func _init():
	sprite_library = SpriteLibrary.new()
	_initialize_default_state()

func _initialize_default_state():
	"""Initialize default sprite state"""
	total_sprite_count = 0
	sprites_per_component = [0, 0, 0, 0, 0, 0, 0]  # 7 components
	target_energy_per_component = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	current_sprite_composition = {}
	biome_sprite_sets = {}

func setup_from_quantum_system(quantum_system: DynamicalSystem):
	"""Setup sprite state from quantum system"""
	var dimension = quantum_system.dimension
	
	# Ensure arrays match dimension
	sprites_per_component.resize(dimension)
	target_energy_per_component.resize(dimension)
	
	# Fill with defaults
	for i in range(dimension):
		sprites_per_component[i] = 0
		target_energy_per_component[i] = 1.0

func initialize_from_quantum_system(quantum_system: DynamicalSystem):
	"""Initialize from quantum system"""
	setup_from_quantum_system(quantum_system)

func update_from_quantum_state(state_vector: Array):
	"""Update sprite state from quantum state"""
	if state_vector.size() != sprites_per_component.size():
		return
	
	total_sprite_count = 0
	
	# Update sprite count based on component energy
	for i in range(state_vector.size()):
		var component_energy = state_vector[i].length()
		var target_sprites = int(component_energy * target_energy_per_component[i] * 10)
		sprites_per_component[i] = max(0, target_sprites)
		total_sprite_count += sprites_per_component[i]
	
	# Update composition
	_update_sprite_composition()

func _update_sprite_composition():
	"""Update sprite composition based on current state"""
	current_sprite_composition.clear()
	
	for i in range(sprites_per_component.size()):
		var sprite_count = sprites_per_component[i]
		if sprite_count > 0:
			var component_key = "component_" + str(i)
			current_sprite_composition[component_key] = sprite_count

func get_state_data() -> Dictionary:
	"""Get sprite state data"""
	return {
		"total_sprite_count": total_sprite_count,
		"sprites_per_component": sprites_per_component,
		"target_energy_per_component": target_energy_per_component,
		"current_sprite_composition": current_sprite_composition,
		"biome_sprite_sets": biome_sprite_sets
	}

func compress_node(node_index: int):
	"""Compress sprites for a node"""
	if node_index >= 0 and node_index < sprites_per_component.size():
		# Compress to single sprite
		sprites_per_component[node_index] = min(1, sprites_per_component[node_index])
		_update_sprite_composition()

func serialize() -> Dictionary:
	"""Serialize sprite state"""
	return {
		"total_sprite_count": total_sprite_count,
		"sprites_per_component": sprites_per_component,
		"target_energy_per_component": target_energy_per_component,
		"current_sprite_composition": current_sprite_composition,
		"biome_sprite_sets": biome_sprite_sets,
		"sprite_library": sprite_library.serialize()
	}

func deserialize(data: Dictionary):
	"""Deserialize sprite state"""
	total_sprite_count = data.get("total_sprite_count", 0)
	sprites_per_component = data.get("sprites_per_component", [])
	target_energy_per_component = data.get("target_energy_per_component", [])
	current_sprite_composition = data.get("current_sprite_composition", {})
	biome_sprite_sets = data.get("biome_sprite_sets", {})
	
	if sprite_library:
		sprite_library.deserialize(data.get("sprite_library", {}))

# Supporting class for sprite library management
class SpriteLibrary:
	var component_sprites: Dictionary = {}
	var biome_specific_sprites: Dictionary = {}
	var compressed_sprites: Dictionary = {}
	
	func get_sprites_for_component(component_index: int) -> Array:
		"""Get available sprites for a component"""
		var sprites = []
		
		# Add base sprites
		if component_sprites.has(component_index):
			sprites.append_array(component_sprites[component_index])
		
		# Add biome-specific sprites
		if biome_specific_sprites.has(component_index):
			sprites.append_array(biome_specific_sprites[component_index])
		
		return sprites
	
	func load_biome_sprites(biome_composition: Dictionary):
		"""Load biome-specific sprites"""
		biome_specific_sprites.clear()
		
		# Load sprites based on biome icons
		for icon_name in biome_composition.get("icons", []):
			var icon_sprites = _load_sprites_for_icon(icon_name)
			_merge_sprite_sets(biome_specific_sprites, icon_sprites)
	
	func _load_sprites_for_icon(icon_name: String) -> Dictionary:
		"""Load sprites for a specific icon"""
		var sprites = {}
		
		match icon_name:
			"imperium":
				sprites = _create_imperium_sprites()
			"biotic_flux":
				sprites = _create_biotic_sprites()
			"entropy_garden":
				sprites = _create_garden_sprites()
			"masquerade_court":
				sprites = _create_court_sprites()
		
		return sprites
	
	func _create_imperium_sprites() -> Dictionary:
		"""Create Imperial-themed sprites"""
		return {
			0: ["👑", "⚔️", "🏰"],
			1: ["🛡️", "⚔️", "👑"],
			2: ["🏭", "⚙️", "🔧"],
			3: ["💰", "📜", "🎭"]
		}
	
	func _create_biotic_sprites() -> Dictionary:
		"""Create Biotic-themed sprites"""
		return {
			0: ["🌱", "🧬", "🍄"],
			1: ["🐛", "🌿", "💧"],
			2: ["🔄", "⚡", "🌊"],
			3: ["🦋", "🌺", "🌸"]
		}
	
	func _create_garden_sprites() -> Dictionary:
		"""Create Garden-themed sprites"""
		return {
			0: ["🌱", "🌿", "🌺"],
			1: ["🍂", "💀", "🍃"],
			2: ["💧", "🌊", "💦"],
			3: ["🌸", "🌼", "🌻"]
		}
	
	func _create_court_sprites() -> Dictionary:
		"""Create Court-themed sprites"""
		return {
			0: ["👑", "🎭", "🗣️"],
			1: ["💎", "🏛️", "👗"],
			2: ["🪞", "🎪", "🎨"],
			3: ["🎯", "🎲", "🃏"]
		}
	
	func _merge_sprite_sets(target: Dictionary, source: Dictionary):
		"""Merge sprite sets"""
		for key in source:
			if not target.has(key):
				target[key] = []
			target[key].append_array(source[key])
	
	func serialize() -> Dictionary:
		"""Serialize sprite library"""
		return {
			"component_sprites": component_sprites,
			"biome_specific_sprites": biome_specific_sprites,
			"compressed_sprites": compressed_sprites
		}
	
	func deserialize(data: Dictionary):
		"""Deserialize sprite library"""
		component_sprites = data.get("component_sprites", {})
		biome_specific_sprites = data.get("biome_specific_sprites", {})
		compressed_sprites = data.get("compressed_sprites", {})
