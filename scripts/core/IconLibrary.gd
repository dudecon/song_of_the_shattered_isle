# scripts/core/IconLibrary.gd
class_name IconLibrary
extends Resource

static func create_imperium_icon() -> IconDefinition:
	var icon = IconDefinition.new()
	icon.name = "The Imperium"
	icon.dimension = 7
	icon.description = "Political machine where power flows through military might, draining treasury while court intrigue provides friction"
	icon.evolution_rate = 0.02
	
	# 🏰⚔️🏭🛡️💰🎭📜
	var labels = PackedStringArray(["throne", "military", "industry", "control", "treasury", "court", "bureaucracy"])
	icon.parameter_labels = labels
	icon.emoji_mapping = {
		0: "🏰", 1: "⚔️", 2: "🏭", 3: "🛡️", 
		4: "💰", 5: "🎭", 6: "📜"
	}
	
	# Initial state - empire in tension
	var temp_state: Array[Vector2] = [
		Vector2(0.3, 0.1),   # 🏰 Throne - oscillating authority
		Vector2(0.2, 0.0),   # ⚔️ Military - stable power
		Vector2(0.4, 0.0),   # 🏭 Industry - productive
		Vector2(0.15, 0.05), # 🛡️ Control - slight surveillance rhythm
		Vector2(0.25, 0.0),  # 💰 Treasury - under pressure
		Vector2(0.1, 0.2),   # 🎭 Court - high intrigue oscillation
		Vector2(0.05, 0.0)   # 📜 Bureaucracy - minimal and decaying
	]
	icon.initial_state = PackedVector2Array(temp_state)
	
	# The actual Imperium transformation matrix from documents
	var matrix: Array[Array] = [
		[0.0,   0.3,    0.4,   -0.1,   -0.8,    0.0,    0.0 ],  # 🏰 Throne
		[0.15,  0.0,    0.0,    0.5,   -0.4,    0.0,   -0.2 ],  # ⚔️ Military
		[0.0,   0.2,   -0.05,   0.1,    0.9,    0.0,    0.3 ],  # 🏭 Industry
		[0.4,   0.8,    0.0,    0.0,    0.0,   -0.5,    0.4 ],  # 🛡️ Control
		[0.0,  -0.6,    0.7,   -0.3,    0.02,   0.0,    0.1 ],  # 💰 Treasury
		[0.0,   0.0,    0.0,   -0.2,    0.4,    0.0,    0.0 ],  # 🎭 Court
		[0.0,   0.0,    0.1,    0.2,    0.0,    0.0,   -0.1 ]   # 📜 Bureaucracy
	]
	icon.transformation_matrix = matrix
	
	# Visualization config
	icon.visualization_config = {
		"primary_color": Color(0.8, 0.6, 0.2),  # Imperial gold
		"secondary_color": Color(0.6, 0.2, 0.2), # Imperial red
		"style": "imperial",
		"arrangement": "hierarchy"
	}
	
	return icon

static func create_biotic_flux_icon() -> IconDefinition:
	var icon = IconDefinition.new()
	icon.name = "The Biotic Flux"
	icon.dimension = 8
	icon.description = "Living ecosystem where bio-intent guides mutation and time composts itself"
	icon.evolution_rate = 0.03
	
	# 🌱🧬🍄🐛🌿💧🔄⚡
	var labels = PackedStringArray(["biointent", "mutation", "fungal", "autopoietic", "substrate", "timeflow", "regenerative", "entropy"])
	icon.parameter_labels = labels
	icon.emoji_mapping = {
		0: "🌱", 1: "🧬", 2: "🍄", 3: "🐛", 
		4: "🌿", 5: "💧", 6: "🔄", 7: "⚡"
	}
	
	# Initial state - system in growth phase
	var temp_state: Array[Vector2] = [
		Vector2(0.2, 0.1),   # 🌱 Bio-Intent - oscillating growth
		Vector2(0.3, 0.0),   # 🧬 Mutation - active adaptation
		Vector2(0.25, 0.05), # 🍄 Fungal - network building
		Vector2(0.15, 0.0),  # 🐛 Autopoietic - self-creating
		Vector2(0.35, 0.0),  # 🌿 Substrate - stable foundation
		Vector2(0.2, 0.1),   # 💧 Time-Flow - composting rhythm
		Vector2(0.1, 0.0),   # 🔄 Regenerative - cycling
		Vector2(0.05, 0.0)   # ⚡ Entropy - minimal but present
	]
	icon.initial_state = PackedVector2Array(temp_state)
	
	# The actual Biotic Flux transformation matrix from documents
	var matrix: Array[Array] = [
		[0.04,  0.3,    0.4,    0.0,    0.3,    0.1,    0.2,    0.0 ],  # 🌱 Bio-Intent
		[0.2,   0.07,   0.5,    0.3,    0.0,    0.0,    0.0,    0.4 ],  # 🧬 Mutation
		[0.3,   0.4,    0.06,   0.5,    0.2,    0.3,    0.0,    0.0 ],  # 🍄 Fungal
		[0.0,   0.4,    0.6,    0.02,   0.3,    0.0,    0.4,    0.0 ],  # 🐛 Autopoietic
		[0.4,   0.0,    0.2,    0.3,    0.03,   0.6,    0.0,    0.0 ],  # 🌿 Substrate
		[0.2,   0.0,    0.4,    0.0,    0.5,    0.05,   0.3,    0.0 ],  # 💧 Time-Flow
		[0.3,   0.0,    0.0,    0.7,    0.0,    0.4,    0.08,   0.2 ],  # 🔄 Regenerative
		[0.0,   0.5,    0.0,    0.0,    0.0,    0.0,    0.3,   -0.02]   # ⚡ Entropy
	]
	icon.transformation_matrix = matrix
	
	# Visualization config
	icon.visualization_config = {
		"primary_color": Color(0.2, 0.8, 0.4),  # Living green
		"secondary_color": Color(0.6, 0.4, 0.8), # Fungal purple
		"style": "organic",
		"arrangement": "network"
	}
	
	return icon

static func create_constellation_shepherd_icon() -> IconDefinition:
	var icon = IconDefinition.new()
	icon.name = "The Constellation Shepherd"
	icon.dimension = 8
	icon.description = "Semantic gravity where meaning has mass and stars collapse into black holes"
	icon.evolution_rate = 0.025
	
	# ⭐🌟💫✨🌙🕳️🔭🎆
	var labels = PackedStringArray(["starseeds", "brightstars", "shootingstars", "stardust", "lunartides", "blackholes", "observation", "supernova"])
	icon.parameter_labels = labels
	icon.emoji_mapping = {
		0: "⭐", 1: "🌟", 2: "💫", 3: "✨", 
		4: "🌙", 5: "🕳️", 6: "🔭", 7: "🎆"
	}
	
	# Initial state - cosmic dance beginning
	var temp_state: Array[Vector2] = [
		Vector2(0.25, 0.1),  # ⭐ Star Seeds - gentle oscillation
		Vector2(0.4, 0.2),   # 🌟 Bright Stars - active and oscillating
		Vector2(0.15, 0.05), # 💫 Shooting Stars - flowing
		Vector2(0.3, 0.0),   # ✨ Stardust - scattered
		Vector2(0.2, 0.15),  # 🌙 Lunar Tides - strong rhythm
		Vector2(0.05, 0.0),  # 🕳️ Black Holes - small but dangerous
		Vector2(0.1, 0.05),  # 🔭 Observation - watching
		Vector2(0.08, 0.0)   # 🎆 Supernova - potential energy
	]
	icon.initial_state = PackedVector2Array(temp_state)
	
	# The actual Constellation Shepherd transformation matrix from documents
	var matrix: Array[Array] = [
		[0.0,   0.3,    0.0,    0.2,   -0.1,    0.0,    0.0,    0.0 ],  # ⭐ Star Seeds
		[0.4,   0.0,    0.5,    0.0,    0.0,   -0.2,    0.3,    0.0 ],  # 🌟 Bright Stars
		[0.0,   0.6,    0.0,    0.3,    0.0,    0.0,    0.0,   -0.1 ],  # 💫 Shooting Stars
		[0.2,   0.0,    0.4,   -0.02,   0.0,   -0.3,    0.0,    0.0 ],  # ✨ Stardust
		[-0.15, 0.0,    0.0,    0.0,   0.0,    0.4,   -0.2,    0.0 ],  # 🌙 Lunar Tides
		[0.0,   0.7,    0.0,    0.5,    0.3,   -0.05,   0.0,   -0.8 ],  # 🕳️ Black Holes
		[0.0,   0.2,    0.3,    0.0,    0.1,    0.0,   0.0,    0.4 ],  # 🔭 Observation
		[0.3,   0.0,   -0.5,    0.0,    0.0,    0.2,    0.5,   -0.1 ]   # 🎆 Supernova
	]
	icon.transformation_matrix = matrix
	
	# Visualization config
	icon.visualization_config = {
		"primary_color": Color(0.9, 0.9, 0.3),  # Starlight yellow
		"secondary_color": Color(0.2, 0.2, 0.8), # Deep space blue
		"style": "cosmic",
		"arrangement": "stellar"
	}
	
	return icon

static func create_entropy_garden_icon() -> IconDefinition:
	var icon = IconDefinition.new()
	icon.name = "The Entropy Garden"
	icon.dimension = 6
	icon.description = "Death as generative force - paradise where decay feeds new growth"
	icon.evolution_rate = 0.04
	
	# 🌱🌿🌺🍂💀💧
	var labels = PackedStringArray(["germination", "navigation", "flowering", "decay", "death", "memory"])
	icon.parameter_labels = labels
	icon.emoji_mapping = {
		0: "🌱", 1: "🌿", 2: "🌺", 3: "🍂", 4: "💀", 5: "💧"
	}
	
	# Initial state - garden in seasonal cycle
	var temp_state: Array[Vector2] = [
		Vector2(0.2, 0.0),   # 🌱 Germination - potential
		Vector2(0.3, 0.1),   # 🌿 Navigation - active growth
		Vector2(0.25, 0.0),  # 🌺 Flowering - peak beauty
		Vector2(0.15, 0.0),  # 🍂 Decay - beginning decline
		Vector2(0.1, 0.0),   # 💀 Death - minimal but present
		Vector2(0.4, 0.05)   # 💧 Memory - rich with experience
	]
	icon.initial_state = PackedVector2Array(temp_state)
	
	# The actual Entropy Garden transformation matrix from documents
	var matrix: Array[Array] = [
		[-0.02,  0.8,    0.0,    0.0,    0.4,    0.3 ],  # 🌱 Germination
		[0.0,   0.04,   0.7,    0.0,    0.0,    0.2 ],  # 🌿 Navigation
		[0.0,   0.0,   -0.03,   0.9,    0.0,    0.0 ],  # 🌺 Flowering
		[0.0,   0.0,    0.0,   -0.08,   0.6,    0.4 ],  # 🍂 Decay
		[0.2,   0.0,    0.0,    0.0,   -0.15,   0.5 ],  # 💀 Death
		[0.4,   0.3,    0.0,    0.6,    0.7,   0.05]   # 💧 Memory
	]
	icon.transformation_matrix = matrix
	
	# Visualization config
	icon.visualization_config = {
		"primary_color": Color(0.8, 0.4, 0.6),  # Garden pink
		"secondary_color": Color(0.4, 0.2, 0.1), # Earth brown
		"style": "garden",
		"arrangement": "cycle"
	}
	
	return icon

static func create_masquerade_court_icon() -> IconDefinition:
	var icon = IconDefinition.new()
	icon.name = "The Masquerade Court"
	icon.dimension = 8
	icon.description = "Political intrigue as performative mathematics where identity is fluid"
	icon.evolution_rate = 0.035
	
	# 👑🎭🗣️💋🗡️🪞💎👁️
	var labels = PackedStringArray(["crown", "masks", "rumors", "seduction", "assassination", "reflection", "wealth", "surveillance"])
	icon.parameter_labels = labels
	icon.emoji_mapping = {
		0: "👑", 1: "🎭", 2: "🗣️", 3: "💋", 
		4: "🗡️", 5: "🪞", 6: "💎", 7: "👁️"
	}
	
	# Initial state - court in session
	var temp_state: Array[Vector2] = [
		Vector2(0.4, 0.2),   # 👑 Crown - authority oscillating
		Vector2(0.3, 0.15),  # 🎭 Masks - identity fluidity
		Vector2(0.2, 0.0),   # 🗣️ Rumors - spreading
		Vector2(0.25, 0.0),  # 💋 Seduction - alluring
		Vector2(0.15, 0.0),  # 🗡️ Assassination - lurking
		Vector2(0.2, 0.1),   # 🪞 Reflection - recursive
		Vector2(0.35, 0.0),  # 💎 Wealth - stable power
		Vector2(0.1, 0.05)   # 👁️ Surveillance - watching
	]
	icon.initial_state = PackedVector2Array(temp_state)
	
	# The actual Masquerade Court transformation matrix from documents
	var matrix: Array[Array] = [
		[0.0,   0.4,    0.3,    0.0,   -0.2,    0.0,    0.0,    0.0 ],  # 👑 Crown
		[0.2,   0.0,    0.0,    0.3,    0.0,    0.5,   -0.1,    0.0 ],  # 🎭 Masks
		[0.0,   0.0,   0.02,    0.4,    0.3,    0.0,    0.0,    0.6 ],  # 🗣️ Rumors
		[0.3,   0.4,    0.2,   -0.05,   0.0,    0.0,    0.5,    0.0 ],  # 💋 Seduction
		[-0.4,  0.0,    0.5,    0.0,   0.0,    0.0,    0.0,    0.2 ],  # 🗡️ Assassination
		[0.0,   0.6,    0.0,    0.0,    0.0,   0.0,   0.3,   -0.2 ],  # 🪞 Reflection
		[0.5,   0.0,    0.0,    0.6,   -0.3,    0.2,   -0.02,   0.0 ],  # 💎 Wealth
		[0.1,  -0.3,    0.7,    0.0,    0.4,    0.0,    0.0,   0.0]   # 👁️ Surveillance
	]
	icon.transformation_matrix = matrix
	
	# Visualization config
	icon.visualization_config = {
		"primary_color": Color(0.8, 0.2, 0.8),  # Royal purple
		"secondary_color": Color(0.9, 0.7, 0.2), # Gold
		"style": "court",
		"arrangement": "intrigue"
	}
	
	return icon

static func get_all_icons() -> Array[IconDefinition]:
	return [
		create_imperium_icon(),
		create_biotic_flux_icon(),
		create_constellation_shepherd_icon(),
		create_entropy_garden_icon(),
		create_masquerade_court_icon()
	]

static func get_icon_by_name(name: String) -> IconDefinition:
	for icon in get_all_icons():
		if icon.name == name:
			return icon
	return null

static func get_icon_names() -> PackedStringArray:
	var names = PackedStringArray()
	for icon in get_all_icons():
		names.append(icon.name)
	return names

static func create_random_icon_variant(base_icon: IconDefinition, mutation_strength: float = 0.1) -> IconDefinition:
	"""Create a random variant of any icon"""
	var suffix = "Variant " + str(randi() % 100)
	return base_icon.create_variant(suffix, mutation_strength)

static func validate_all_icons() -> Dictionary:
	"""Validate all icons in the library"""
	var results = {}
	var all_valid = true
	
	for icon in get_all_icons():
		var validation = icon.validate_icon_data()
		results[icon.name] = validation
		if not validation.valid:
			all_valid = false
	
	return {
		"all_valid": all_valid,
		"individual_results": results
	}

static func get_icon_statistics() -> Dictionary:
	"""Get statistics about all icons in the library"""
	var icons = get_all_icons()
	var stats = {
		"count": icons.size(),
		"dimensions": {},
		"evolution_rates": [],
		"oscillating_components": 0,
		"stable_components": 0,
		"total_coupling": 0.0
	}
	
	for icon in icons:
		# Dimension distribution
		var dim = icon.dimension
		if not stats.dimensions.has(dim):
			stats.dimensions[dim] = 0
		stats.dimensions[dim] += 1
		
		# Evolution rates
		stats.evolution_rates.append(icon.evolution_rate)
		
		# Component behavior
		stats.oscillating_components += icon.get_oscillating_components().size()
		stats.stable_components += icon.get_stable_components().size()
		
		# Coupling strength
		stats.total_coupling += icon.get_matrix_coupling_strength()
	
	return stats
