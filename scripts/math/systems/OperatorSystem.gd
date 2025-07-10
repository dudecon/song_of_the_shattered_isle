# scripts/math/systems/OperatorSystem.gd
class_name OperatorSystem
extends Resource

# Continuous factory (➕) operator management system

var active_operators: Array[Operator] = []
var node_operators: Dictionary = {}
var operator_definitions: Dictionary = {}
var biome_composition: BiomeComposition

signal operator_deployed(operator_name: String, node_index: int)
signal operator_effect_applied(operator_name: String, node_index: int, effect: Dictionary)
signal operator_removed(operator_name: String, node_index: int)

func _init():
	_initialize_operator_definitions()

func _initialize_operator_definitions():
	"""Initialize base operator definitions"""
	# Generator operators (create resources from nothing)
	var energy_generator = OperatorDefinition.new()
	energy_generator.setup("energy_generator", "⚡ Energy Generator", "generator", {
		"output_type": "energy",
		"output_rate": 0.1,
		"efficiency": 1.0,
		"resource_cost": {"materials": 10, "energy": 5}
	})
	operator_definitions["energy_generator"] = energy_generator
	
	# Converter operators (transform one resource to another)
	var wheat_converter = OperatorDefinition.new()
	wheat_converter.setup("wheat_converter", "🌾 Wheat Converter", "converter", {
		"input_type": "energy",
		"input_rate": 0.2,
		"output_type": "wheat",
		"output_rate": 0.1,
		"efficiency": 0.5,
		"resource_cost": {"materials": 15, "energy": 10}
	})
	operator_definitions["wheat_converter"] = wheat_converter
	
	# Amplifier operators (multiply existing effects)
	var signal_amplifier = OperatorDefinition.new()
	signal_amplifier.setup("signal_amplifier", "📡 Signal Amplifier", "amplifier", {
		"amplification_factor": 1.5,
		"range": 2,  # Affects nearby nodes
		"efficiency": 0.8,
		"resource_cost": {"materials": 20, "energy": 15}
	})
	operator_definitions["signal_amplifier"] = signal_amplifier
	
	# Stabilizer operators (reduce chaos and oscillations)
	var chaos_stabilizer = OperatorDefinition.new()
	chaos_stabilizer.setup("chaos_stabilizer", "🛡️ Chaos Stabilizer", "stabilizer", {
		"damping_factor": 0.3,
		"stability_bonus": 0.2,
		"efficiency": 0.9,
		"resource_cost": {"materials": 12, "energy": 8}
	})
	operator_definitions["chaos_stabilizer"] = chaos_stabilizer

func setup_for_biome(biome_comp: BiomeComposition):
	"""Setup operator system for a specific biome"""
	biome_composition = biome_comp
	
	# Add biome-specific operators
	_add_biome_specific_operators()

func _add_biome_specific_operators():
	"""Add operators specific to the biome composition"""
	var dominant_icons = biome_composition.get_dominant_icons()
	
	for icon_name in dominant_icons:
		var icon_operators = _get_icon_specific_operators(icon_name)
		for op_name in icon_operators:
			operator_definitions[op_name] = icon_operators[op_name]

func _get_icon_specific_operators(icon_name: String) -> Dictionary:
	"""Get operators specific to an icon"""
	var operators = {}
	
	match icon_name:
		"imperium":
			operators["imperial_mobilizer"] = _create_imperial_mobilizer()
			operators["bureaucratic_processor"] = _create_bureaucratic_processor()
		"biotic_flux":
			operators["mutation_chamber"] = _create_mutation_chamber()
			operators["symbiosis_network"] = _create_symbiosis_network()
		"constellation_shepherd":
			operators["stellar_collector"] = _create_stellar_collector()
			operators["cosmic_amplifier"] = _create_cosmic_amplifier()
		"entropy_garden":
			operators["decay_processor"] = _create_decay_processor()
			operators["renewal_catalyst"] = _create_renewal_catalyst()
		"masquerade_court":
			operators["intrigue_weaver"] = _create_intrigue_weaver()
			operators["influence_multiplier"] = _create_influence_multiplier()
	
	return operators

func add_operator(operator: Operator, node_index: int):
	"""Add an operator to a specific node"""
	active_operators.append(operator)
	
	# Track operators by node
	if not node_operators.has(node_index):
		node_operators[node_index] = []
	node_operators[node_index].append(operator)
	
	# Start continuous operation
	operator.start_continuous_operation()
	
	# Emit signal
	operator_deployed.emit(operator.name, node_index)

func remove_operator(operator: Operator, node_index: int):
	"""Remove an operator from a node"""
	active_operators.erase(operator)
	
	if node_operators.has(node_index):
		node_operators[node_index].erase(operator)
		if node_operators[node_index].is_empty():
			node_operators.erase(node_index)
	
	# Stop continuous operation
	operator.stop_continuous_operation()
	
	# Emit signal
	operator_removed.emit(operator.name, node_index)

func get_operators_for_node(node_index: int) -> Array[Operator]:
	"""Get all operators for a specific node"""
	return node_operators.get(node_index, [])

func get_active_operators() -> Array[Operator]:
	"""Get all active operators"""
	return active_operators

func process_continuous_effects(delta_time: float):
	"""Process continuous effects from all operators"""
	for operator in active_operators:
		var effect = operator.process_continuous_effect(delta_time)
		if effect.has_effect:
			operator_effect_applied.emit(operator.name, operator.node_index, effect)

func can_deploy_operator(operator_name: String, node_index: int) -> bool:
	"""Check if an operator can be deployed at a node"""
	if not operator_definitions.has(operator_name):
		return false
	
	var operator_def = operator_definitions[operator_name]
	
	# Check node capacity
	var current_operators = get_operators_for_node(node_index)
	if current_operators.size() >= 3:  # Max 3 operators per node
		return false
	
	# Check for conflicting operators
	for existing_op in current_operators:
		if _operators_conflict(operator_name, existing_op.name):
			return false
	
	return true

func _operators_conflict(op1_name: String, op2_name: String) -> bool:
	"""Check if two operators conflict"""
	# Some operators can't coexist
	var conflicts = {
		"energy_generator": ["chaos_stabilizer"],  # Generators create instability
		"signal_amplifier": ["chaos_stabilizer"],  # Amplifiers increase chaos
	}
	
	if conflicts.has(op1_name) and op2_name in conflicts[op1_name]:
		return true
	if conflicts.has(op2_name) and op1_name in conflicts[op2_name]:
		return true
	
	return false

func deploy_operator(operator_name: String, node_index: int) -> Dictionary:
	"""Deploy an operator at a node"""
	if not can_deploy_operator(operator_name, node_index):
		return {"success": false, "error": "Cannot deploy operator"}
	
	var operator_def = operator_definitions[operator_name]
	var operator = Operator.new()
	operator.setup_from_definition(operator_def, node_index)
	
	add_operator(operator, node_index)
	
	return {
		"success": true,
		"operator": operator,
		"node_index": node_index
	}

func get_operator_definition(operator_name: String) -> OperatorDefinition:
	"""Get operator definition"""
	return operator_definitions.get(operator_name, null)

func get_available_operators() -> Array[String]:
	"""Get names of all available operators"""
	var keys = operator_definitions.keys()
	var result: Array[String] = []
	for key in keys:
		result.append(key)
	return result

# Icon-specific operator creators
func _create_imperial_mobilizer() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("imperial_mobilizer", "⚔️ Imperial Mobilizer", "converter", {
		"input_type": "materials",
		"input_rate": 0.3,
		"output_type": "military_power",
		"output_rate": 0.2,
		"efficiency": 0.8,
		"resource_cost": {"materials": 25, "favor": 10}
	})
	return op

func _create_bureaucratic_processor() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("bureaucratic_processor", "📜 Bureaucratic Processor", "amplifier", {
		"amplification_factor": 1.3,
		"efficiency_bonus": 0.1,
		"stability_bonus": 0.15,
		"resource_cost": {"materials": 15, "favor": 5}
	})
	return op

func _create_mutation_chamber() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("mutation_chamber", "🧬 Mutation Chamber", "converter", {
		"input_type": "organic_matter",
		"input_rate": 0.2,
		"output_type": "enhanced_organisms",
		"output_rate": 0.15,
		"mutation_chance": 0.1,
		"resource_cost": {"materials": 20, "energy": 12}
	})
	return op

func _create_symbiosis_network() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("symbiosis_network", "🤝 Symbiosis Network", "amplifier", {
		"amplification_factor": 1.4,
		"network_range": 3,
		"cooperation_bonus": 0.2,
		"resource_cost": {"materials": 18, "energy": 15}
	})
	return op

func _create_stellar_collector() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("stellar_collector", "⭐ Stellar Collector", "generator", {
		"output_type": "cosmic_energy",
		"output_rate": 0.15,
		"stellar_affinity": 1.5,
		"resource_cost": {"materials": 30, "energy": 20}
	})
	return op

func _create_cosmic_amplifier() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("cosmic_amplifier", "🌌 Cosmic Amplifier", "amplifier", {
		"amplification_factor": 2.0,
		"cosmic_resonance": 1.8,
		"range": 4,
		"resource_cost": {"materials": 35, "energy": 25}
	})
	return op

func _create_decay_processor() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("decay_processor", "🍂 Decay Processor", "converter", {
		"input_type": "organic_waste",
		"input_rate": 0.4,
		"output_type": "fertile_soil",
		"output_rate": 0.3,
		"decay_acceleration": 1.5,
		"resource_cost": {"materials": 12, "energy": 8}
	})
	return op

func _create_renewal_catalyst() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("renewal_catalyst", "🌱 Renewal Catalyst", "generator", {
		"output_type": "life_force",
		"output_rate": 0.12,
		"renewal_factor": 1.3,
		"resource_cost": {"materials": 15, "energy": 10}
	})
	return op

func _create_intrigue_weaver() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("intrigue_weaver", "🕸️ Intrigue Weaver", "converter", {
		"input_type": "information",
		"input_rate": 0.25,
		"output_type": "political_power",
		"output_rate": 0.18,
		"intrigue_complexity": 1.4,
		"resource_cost": {"materials": 14, "favor": 8}
	})
	return op

func _create_influence_multiplier() -> OperatorDefinition:
	var op = OperatorDefinition.new()
	op.setup("influence_multiplier", "👁️ Influence Multiplier", "amplifier", {
		"amplification_factor": 1.6,
		"influence_range": 2,
		"persuasion_bonus": 0.25,
		"resource_cost": {"materials": 22, "favor": 12}
	})
	return op

func serialize() -> Dictionary:
	"""Serialize operator system state"""
	return {
		"active_operators": _serialize_operators(active_operators),
		"node_operators": _serialize_node_operators(),
		"operator_definitions": _serialize_operator_definitions()
	}

func deserialize(data: Dictionary):
	"""Deserialize operator system state"""
	active_operators = _deserialize_operators(data.get("active_operators", []))
	node_operators = _deserialize_node_operators(data.get("node_operators", {}))
	
	# Operator definitions are recreated on setup
	var saved_definitions = data.get("operator_definitions", {})
	_merge_operator_definitions(saved_definitions)

func _serialize_operators(operators: Array[Operator]) -> Array:
	var serialized = []
	for operator in operators:
		serialized.append(operator.serialize())
	return serialized

func _deserialize_operators(data: Array) -> Array[Operator]:
	var operators: Array[Operator] = []
	for operator_data in data:
		var operator = Operator.new()
		operator.deserialize(operator_data)
		operators.append(operator)
	return operators

func _serialize_node_operators() -> Dictionary:
	var serialized = {}
	for node_index in node_operators:
		serialized[node_index] = _serialize_operators(node_operators[node_index])
	return serialized

func _deserialize_node_operators(data: Dictionary) -> Dictionary:
	var deserialized = {}
	for node_index in data:
		deserialized[node_index] = _deserialize_operators(data[node_index])
	return deserialized

func _serialize_operator_definitions() -> Dictionary:
	var serialized = {}
	for op_name in operator_definitions:
		serialized[op_name] = operator_definitions[op_name].serialize()
	return serialized

func _merge_operator_definitions(saved_definitions: Dictionary):
	"""Merge saved operator definitions with current ones"""
	for op_name in saved_definitions:
		if not operator_definitions.has(op_name):
			var op_def = OperatorDefinition.new()
			op_def.deserialize(saved_definitions[op_name])
			operator_definitions[op_name] = op_def
