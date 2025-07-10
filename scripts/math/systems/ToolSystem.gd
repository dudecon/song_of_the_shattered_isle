# scripts/math/systems/ToolSystem.gd
class_name ToolSystem
extends Resource

# Pure mathematical tool deployment system

var available_tools: Dictionary = {}
var tool_definitions: Dictionary = {}
var resource_manager: ResourceManager

func _init():
	resource_manager = ResourceManager.new()
	_initialize_base_tools()

func _initialize_base_tools():
	"""Initialize the base set of tools"""
	# ➕ Spark Tool - Instant energy injection
	var spark_tool = ToolDefinition.new()
	spark_tool.setup("spark", "➕", "Instant energy injection", {
		"type": "additive",
		"effect": "instant",
		"energy_range": {"min": -1.0, "max": 1.0},
		"resource_cost": {"energy": 5}
	})
	tool_definitions["spark"] = spark_tool
	
	# ✖️ Druid Tool - Temporary matrix modification
	var druid_tool = ToolDefinition.new()
	druid_tool.setup("druid", "✖️", "Temporary matrix modification", {
		"type": "multiplicative",
		"effect": "temporary",
		"duration": 30.0,
		"matrix_modifier": {"amplification": 1.5},
		"resource_cost": {"energy": 10}
	})
	tool_definitions["druid"] = druid_tool
	
	# ➕ Operator Tool - Continuous factory construction
	var operator_tool = ToolDefinition.new()
	operator_tool.setup("operator", "➕", "Continuous factory construction", {
		"type": "additive",
		"effect": "continuous",
		"factory_types": ["generator", "converter", "amplifier"],
		"resource_cost": {"materials": 20, "energy": 15}
	})
	tool_definitions["operator"] = operator_tool
	
	# ✖️ Icon Paintbrush - Persistent influence painting
	var paintbrush_tool = ToolDefinition.new()
	paintbrush_tool.setup("icon_paintbrush", "✖️", "Paint icon influence", {
		"type": "multiplicative",
		"effect": "persistent",
		"influence_strength": {"min": 0.1, "max": 1.0},
		"resource_cost": {"influence": 1}
	})
	tool_definitions["icon_paintbrush"] = paintbrush_tool
	
	# Analysis Tool - Investigation and discovery
	var analysis_tool = ToolDefinition.new()
	analysis_tool.setup("analysis", "🔍", "Investigate node properties", {
		"type": "informational",
		"effect": "instant",
		"analysis_depth": {"surface": 1, "deep": 3},
		"resource_cost": {"energy": 2}
	})
	tool_definitions["analysis"] = analysis_tool
	
	# Captain Tool - Deploy subsidiary captain
	var captain_tool = ToolDefinition.new()
	captain_tool.setup("captain", "👨‍💼", "Deploy subsidiary captain", {
		"type": "management",
		"effect": "persistent",
		"management_types": ["automation", "optimization", "monitoring"],
		"resource_cost": {"favor": 50, "materials": 30}
	})
	tool_definitions["captain"] = captain_tool

func setup_for_biome(biome_composition: BiomeComposition):
	"""Setup tools for a specific biome"""
	available_tools.clear()
	
	# Add all base tools
	for tool_name in tool_definitions:
		available_tools[tool_name] = tool_definitions[tool_name]
	
	# Add biome-specific tools
	_add_biome_specific_tools(biome_composition)

func _add_biome_specific_tools(biome_composition: BiomeComposition):
	"""Add tools specific to the biome composition"""
	var dominant_icons = biome_composition.get_dominant_icons()
	
	for icon_name in dominant_icons:
		var icon_tools = _get_icon_specific_tools(icon_name)
		for tool_name in icon_tools:
			available_tools[tool_name] = icon_tools[tool_name]

func _get_icon_specific_tools(icon_name: String) -> Dictionary:
	"""Get tools specific to an icon"""
	var tools = {}
	
	match icon_name:
		"imperium":
			tools["imperial_decree"] = _create_imperial_decree_tool()
			tools["military_deployment"] = _create_military_deployment_tool()
		"biotic_flux":
			tools["mutation_catalyst"] = _create_mutation_catalyst_tool()
			tools["symbiosis_enhancer"] = _create_symbiosis_enhancer_tool()
		"constellation_shepherd":
			tools["stellar_alignment"] = _create_stellar_alignment_tool()
			tools["cosmic_lens"] = _create_cosmic_lens_tool()
		"entropy_garden":
			tools["decay_accelerator"] = _create_decay_accelerator_tool()
			tools["renewal_seed"] = _create_renewal_seed_tool()
		"masquerade_court":
			tools["intrigue_weaver"] = _create_intrigue_weaver_tool()
			tools["mirror_reflection"] = _create_mirror_reflection_tool()
	
	return tools

func can_deploy_tool(tool_name: String, node_index: int) -> bool:
	"""Check if a tool can be deployed at a specific node"""
	if not available_tools.has(tool_name):
		return false
	
	var tool = available_tools[tool_name]
	
	# Check resource requirements
	if not resource_manager.has_resources(tool.get_resource_cost()):
		return false
	
	# Check tool-specific deployment conditions
	return _check_tool_specific_conditions(tool, node_index)

func _check_tool_specific_conditions(tool: ToolDefinition, node_index: int) -> bool:
	"""Check tool-specific deployment conditions"""
	match tool.name:
		"spark":
			return true  # Can always deploy spark
		"druid":
			return true  # Can always deploy druid
		"operator":
			return _can_deploy_operator(node_index)
		"icon_paintbrush":
			return _can_paint_influence(node_index)
		"analysis":
			return true  # Can always analyze
		"captain":
			return _can_deploy_captain(node_index)
	
	return true

func _can_deploy_operator(node_index: int) -> bool:
	"""Check if operator can be deployed at node"""
	# Check if node already has maximum operators
	# This would require reference to node graph, which we'll handle via dependency injection
	return true

func _can_paint_influence(node_index: int) -> bool:
	"""Check if influence can be painted at node"""
	# Check influence budget
	return true

func _can_deploy_captain(node_index: int) -> bool:
	"""Check if captain can be deployed at node"""
	# Check if node is suitable for captain deployment
	return true

func deploy_tool(tool_name: String, node_index: int) -> Dictionary:
	"""Deploy a tool at a specific node"""
	if not can_deploy_tool(tool_name, node_index):
		return {"success": false, "error": "Cannot deploy tool"}
	
	var tool = available_tools[tool_name]
	var deployment_result = _execute_tool_deployment(tool, node_index)
	
	if deployment_result.success:
		# Consume resources
		resource_manager.consume_resources(tool.get_resource_cost())
	
	return deployment_result

func _execute_tool_deployment(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Execute the actual tool deployment"""
	var effects = _calculate_tool_effects(tool, node_index)
	
	return {
		"success": true,
		"effects": effects,
		"tool_name": tool.name,
		"node_index": node_index
	}

func _calculate_tool_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate the effects of tool deployment"""
	var effects = {}
	
	match tool.name:
		"spark":
			effects = _calculate_spark_effects(tool, node_index)
		"druid":
			effects = _calculate_druid_effects(tool, node_index)
		"operator":
			effects = _calculate_operator_effects(tool, node_index)
		"icon_paintbrush":
			effects = _calculate_paintbrush_effects(tool, node_index)
		"analysis":
			effects = _calculate_analysis_effects(tool, node_index)
		"captain":
			effects = _calculate_captain_effects(tool, node_index)
	
	return effects

func _calculate_spark_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate spark tool effects"""
	var energy_injection = randf_range(-0.5, 0.5)  # Random energy injection
	
	return {
		"type": "spark_injection",
		"energy_delta": Vector2(energy_injection, 0.0),
		"node_index": node_index
	}

func _calculate_druid_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate druid tool effects"""
	var amplification = 1.5
	var duration = 30.0
	
	return {
		"type": "druid_matrix_modification",
		"amplification": amplification,
		"duration": duration,
		"target_node": node_index,
		"matrix_modifier": {
			"type": "amplification",
			"strength": amplification,
			"duration": duration
		}
	}

func _calculate_operator_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate operator tool effects"""
	# Select random operator type
	var operator_types = ["generator", "converter", "amplifier"]
	var operator_type = operator_types[randi() % operator_types.size()]
	
	return {
		"type": "operator_construction",
		"operator_name": operator_type + "_operator",
		"operator_type": operator_type,
		"node_index": node_index,
		"continuous_effect": _get_operator_continuous_effect(operator_type)
	}

func _get_operator_continuous_effect(operator_type: String) -> Dictionary:
	"""Get continuous effect for operator type"""
	match operator_type:
		"generator":
			return {"type": "energy_generation", "rate": 0.1}
		"converter":
			return {"type": "resource_conversion", "input": "energy", "output": "materials", "rate": 0.05}
		"amplifier":
			return {"type": "signal_amplification", "multiplier": 1.2}
	
	return {}

func _calculate_paintbrush_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate icon paintbrush effects"""
	var influence_strength = 0.3
	
	return {
		"type": "influence_painting",
		"influence_data": {
			"strength": influence_strength,
			"icon_type": "spouse",  # Default to spouse icon
			"node_index": node_index
		},
		"influence_cost": influence_strength
	}

func _calculate_analysis_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate analysis tool effects"""
	return {
		"type": "analysis_performed",
		"analysis_data": {
			"node_index": node_index,
			"depth": "surface",
			"timestamp": Time.get_time_dict_from_system()
		}
	}

func _calculate_captain_effects(tool: ToolDefinition, node_index: int) -> Dictionary:
	"""Calculate captain deployment effects"""
	return {
		"type": "captain_deployment",
		"captain_data": {
			"node_index": node_index,
			"management_type": "automation",
			"efficiency_bonus": 1.1
		}
	}

# Icon-specific tool creators
func _create_imperial_decree_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("imperial_decree", "👑", "Issue imperial decree", {
		"type": "multiplicative",
		"effect": "persistent",
		"authority_bonus": 2.0,
		"resource_cost": {"favor": 10}
	})
	return tool

func _create_military_deployment_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("military_deployment", "⚔️", "Deploy military forces", {
		"type": "additive",
		"effect": "temporary",
		"protection_bonus": 1.5,
		"resource_cost": {"materials": 15}
	})
	return tool

func _create_mutation_catalyst_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("mutation_catalyst", "🧬", "Accelerate mutation", {
		"type": "multiplicative",
		"effect": "temporary",
		"mutation_rate": 2.0,
		"resource_cost": {"energy": 8}
	})
	return tool

func _create_symbiosis_enhancer_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("symbiosis_enhancer", "🤝", "Enhance symbiotic relationships", {
		"type": "multiplicative",
		"effect": "persistent",
		"cooperation_bonus": 1.3,
		"resource_cost": {"energy": 12}
	})
	return tool

func _create_stellar_alignment_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("stellar_alignment", "⭐", "Align stellar influences", {
		"type": "multiplicative",
		"effect": "temporary",
		"cosmic_harmony": 1.8,
		"resource_cost": {"energy": 20}
	})
	return tool

func _create_cosmic_lens_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("cosmic_lens", "🔭", "Focus cosmic energies", {
		"type": "multiplicative",
		"effect": "persistent",
		"focus_amplification": 1.5,
		"resource_cost": {"materials": 25}
	})
	return tool

func _create_decay_accelerator_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("decay_accelerator", "🍂", "Accelerate natural decay", {
		"type": "multiplicative",
		"effect": "temporary",
		"decay_rate": 2.5,
		"resource_cost": {"energy": 6}
	})
	return tool

func _create_renewal_seed_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("renewal_seed", "🌱", "Plant renewal seed", {
		"type": "additive",
		"effect": "persistent",
		"renewal_strength": 1.2,
		"resource_cost": {"materials": 10}
	})
	return tool

func _create_intrigue_weaver_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("intrigue_weaver", "🕸️", "Weave court intrigue", {
		"type": "multiplicative",
		"effect": "temporary",
		"intrigue_complexity": 1.7,
		"resource_cost": {"favor": 8}
	})
	return tool

func _create_mirror_reflection_tool() -> ToolDefinition:
	var tool = ToolDefinition.new()
	tool.setup("mirror_reflection", "🪞", "Create mirror reflection", {
		"type": "multiplicative",
		"effect": "persistent",
		"reflection_strength": 1.4,
		"resource_cost": {"materials": 18}
	})
	return tool

func serialize() -> Dictionary:
	"""Serialize tool system state"""
	return {
		"available_tools": _serialize_tools(available_tools),
		"tool_definitions": _serialize_tools(tool_definitions),
		"resource_manager": resource_manager.serialize()
	}

func deserialize(data: Dictionary):
	"""Deserialize tool system state"""
	available_tools = _deserialize_tools(data.get("available_tools", {}))
	tool_definitions = _deserialize_tools(data.get("tool_definitions", {}))
	resource_manager.deserialize(data.get("resource_manager", {}))

func _serialize_tools(tools: Dictionary) -> Dictionary:
	var serialized = {}
	for tool_name in tools:
		serialized[tool_name] = tools[tool_name].serialize()
	return serialized

func _deserialize_tools(data: Dictionary) -> Dictionary:
	var deserialized = {}
	for tool_name in data:
		var tool = ToolDefinition.new()
		tool.deserialize(data[tool_name])
		deserialized[tool_name] = tool
	return deserialized
