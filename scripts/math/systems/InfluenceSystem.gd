# scripts/math/systems/InfluenceSystem.gd
class_name InfluenceSystem
extends Resource

# Icon painting and influence management system

var biome_composition: BiomeComposition
var influence_budget: InfluenceBudget
var node_influences: Dictionary = {}
var spouse_icon: IconDefinition
var available_icons: Array[String] = []

signal influence_painted(node_index: int, influence_data: Dictionary)
signal influence_budget_changed(new_budget: Dictionary)

func setup_for_biome(biome_comp: BiomeComposition, budget: InfluenceBudget):
	"""Setup influence system for a biome"""
	biome_composition = biome_comp
	influence_budget = budget
	
	# Setup available icons for painting
	_setup_available_icons()
	
	# Initialize node influences
	_initialize_node_influences()

func _setup_available_icons():
	"""Setup icons available for painting"""
	available_icons.clear()
	
	# Always available: spouse icon
	available_icons.append("spouse")
	
	# Add dominant biome icons
	var dominant_icons = biome_composition.get_dominant_icons()
	for icon in dominant_icons:
		if icon not in available_icons:
			available_icons.append(icon)

func _initialize_node_influences():
	"""Initialize node influence tracking"""
	node_influences.clear()
	# Will be populated as influences are painted

func paint_influence(node_index: int, influence_data: Dictionary) -> Dictionary:
	"""Paint icon influence at a specific node"""
	var icon_name = influence_data.get("icon_name", "spouse")
	var strength = influence_data.get("strength", 0.3)
	
	# Calculate influence cost
	var influence_cost = _calculate_influence_cost(icon_name, strength)
	
	# Check if we can afford it
	if not influence_budget.can_afford(influence_cost):
		return {
			"success": false,
			"error": "Insufficient influence budget"
		}
	
	# Get the icon's transformation matrix
	var icon_matrix = _get_icon_matrix(icon_name)
	if icon_matrix.is_empty():
		return {
			"success": false,
			"error": "Invalid icon"
		}
	
	# Calculate matrix modification
	var matrix_modification = _calculate_matrix_modification(icon_matrix, strength)
	
	# Apply influence
	_apply_influence_to_node(node_index, {
		"icon_name": icon_name,
		"strength": strength,
		"matrix_modification": matrix_modification,
		"influence_cost": influence_cost
	})
	
	return {
		"success": true,
		"influence_cost": influence_cost,
		"matrix_modification": matrix_modification
	}

func _calculate_influence_cost(icon_name: String, strength: float) -> float:
	"""Calculate the influence cost for painting"""
	var base_cost = strength * 10.0  # Base cost
	
	# Icon-specific multipliers
	var icon_multiplier = 1.0
	match icon_name:
		"spouse":
			icon_multiplier = 1.0  # Spouse icon is most efficient
		"imperium":
			icon_multiplier = 1.5  # Imperial influence is expensive
		"biotic_flux":
			icon_multiplier = 1.2  # Biotic influence is moderately expensive
		"constellation_shepherd":
			icon_multiplier = 1.8  # Cosmic influence is very expensive
		"entropy_garden":
			icon_multiplier = 1.1  # Garden influence is cheap
		"masquerade_court":
			icon_multiplier = 1.6  # Court influence is expensive
	
	return base_cost * icon_multiplier

func _get_icon_matrix(icon_name: String) -> Array[Array]:
	"""Get transformation matrix for an icon"""
	if icon_name == "spouse":
		return _get_spouse_icon_matrix()
	else:
		var icon_definition = IconLibrary.get_icon_by_name(icon_name)
		if icon_definition:
			return icon_definition.transformation_matrix
	
	return []

func _get_spouse_icon_matrix() -> Array[Array]:
	"""Get the current spouse icon matrix"""
	if spouse_icon:
		return spouse_icon.transformation_matrix
	
	# Return default spouse matrix if not set
	return _create_default_spouse_matrix()

func _create_default_spouse_matrix() -> Array[Array]:
	"""Create default spouse transformation matrix"""
	var matrix = []
	for i in range(7):  # Default 7x7 matrix
		var row = []
		for j in range(7):
			if i == j:
				row.append(0.1)  # Small self-reinforcement
			else:
				row.append(0.0)
		matrix.append(row)
	return matrix

func _calculate_matrix_modification(icon_matrix: Array[Array], strength: float) -> Dictionary:
	"""Calculate how to modify the transformation matrix"""
	return {
		"type": "icon_influence",
		"influence_data": {
			"icon_matrix": icon_matrix,
			"strength": strength
		}
	}

func _apply_influence_to_node(node_index: int, influence_data: Dictionary):
	"""Apply influence to a specific node"""
	# Store influence data
	if not node_influences.has(node_index):
		node_influences[node_index] = []
	
	node_influences[node_index].append(influence_data)
	
	# Emit signal
	influence_painted.emit(node_index, influence_data)

func get_influence_for_node(node_index: int) -> Dictionary:
	"""Get influence data for a specific node"""
	var influences = node_influences.get(node_index, [])
	
	if influences.is_empty():
		return {"has_influence": false}
	
	# Calculate combined influence
	var combined_influence = _calculate_combined_influence(influences)
	
	return {
		"has_influence": true,
		"influences": influences,
		"combined_strength": combined_influence.strength,
		"dominant_icon": combined_influence.dominant_icon
	}

func _calculate_combined_influence(influences: Array) -> Dictionary:
	"""Calculate combined influence from multiple paintings"""
	var icon_strengths = {}
	var total_strength = 0.0
	
	for influence in influences:
		var icon_name = influence.get("icon_name", "spouse")
		var strength = influence.get("strength", 0.0)
		
		if not icon_strengths.has(icon_name):
			icon_strengths[icon_name] = 0.0
		
		icon_strengths[icon_name] += strength
		total_strength += strength
	
	# Find dominant icon
	var dominant_icon = ""
	var max_strength = 0.0
	for icon_name in icon_strengths:
		if icon_strengths[icon_name] > max_strength:
			max_strength = icon_strengths[icon_name]
			dominant_icon = icon_name
	
	return {
		"strength": total_strength,
		"dominant_icon": dominant_icon,
		"icon_strengths": icon_strengths
	}

func can_paint_influence(node_index: int, icon_name: String, strength: float) -> bool:
	"""Check if influence can be painted"""
	# Check if icon is available
	if icon_name not in available_icons:
		return false
	
	# Check influence budget
	var cost = _calculate_influence_cost(icon_name, strength)
	if not influence_budget.can_afford(cost):
		return false
	
	# Check node-specific constraints
	return _check_node_constraints(node_index, icon_name, strength)

func _check_node_constraints(node_index: int, icon_name: String, strength: float) -> bool:
	"""Check node-specific constraints for painting"""
	# Check if node already has too much influence
	var current_influence = get_influence_for_node(node_index)
	if current_influence.has_influence:
		var combined_strength = current_influence.combined_strength
		if combined_strength + strength > 2.0:  # Max influence limit
			return false
	
	return true

func get_available_icons() -> Array[String]:
	"""Get icons available for painting"""
	return available_icons

func set_spouse_icon(icon: IconDefinition):
	"""Set the spouse icon"""
	spouse_icon = icon
	
	# Update available icons
	if "spouse" not in available_icons:
		available_icons.append("spouse")

func get_influence_budget_info() -> Dictionary:
	"""Get current influence budget information"""
	return influence_budget.get_budget_data()

func recharge_influence_budget(amount: float):
	"""Recharge influence budget (called between seasons)"""
	influence_budget.recharge(amount)
	influence_budget_changed.emit(influence_budget.get_budget_data())

func serialize() -> Dictionary:
	"""Serialize influence system state"""
	return {
		"node_influences": node_influences,
		"available_icons": available_icons,
		"spouse_icon": spouse_icon.serialize() if spouse_icon else {},
		"influence_budget": influence_budget.serialize()
	}

func deserialize(data: Dictionary):
	"""Deserialize influence system state"""
	node_influences = data.get("node_influences", {})
	available_icons = data.get("available_icons", [])
	
	var spouse_data = data.get("spouse_icon", {})
	if not spouse_data.is_empty():
		spouse_icon = IconDefinition.new()
		spouse_icon.deserialize(spouse_data)
	
	influence_budget.deserialize(data.get("influence_budget", {}))
