# scripts/core/BiomeMathCore.gd
class_name BiomeMathCore
extends Resource

# Pure mathematical system - no UI dependencies
# This is the single source of truth for all biome behavior

# Core Mathematical State
var quantum_system: DynamicalSystem
var node_graph: NodeGraph
var biome_composition: BiomeComposition
var sprite_state: SpriteState
var influence_budget: InfluenceBudget

# Tool Systems
var tool_system: ToolSystem
var operator_system: OperatorSystem
var influence_system: InfluenceSystem

# Simulation State
var evolution_rate: float = 1.0
var time_scale: float = 1.0
var auto_evolution: bool = true

# Signals (for UI to respond to math changes)
signal state_evolved(new_state: Array)
signal node_modified(node_index: int, modification_data: Dictionary)
signal biome_composition_changed(composition_data: Dictionary)
signal tool_deployed(tool_name: String, node_index: int, effect_data: Dictionary)
signal influence_painted(node_index: int, influence_data: Dictionary)
signal operator_deployed(operator_name: String, node_index: int)
signal compression_completed(node_index: int, compression_data: Dictionary)

func _init():
	_initialize_systems()

func _initialize_systems():
	# Core mathematical systems
	quantum_system = DynamicalSystem.new()
	node_graph = NodeGraph.new()
	biome_composition = BiomeComposition.new()
	sprite_state = SpriteState.new()
	influence_budget = InfluenceBudget.new()
	
	# Tool and interaction systems
	tool_system = ToolSystem.new()
	operator_system = OperatorSystem.new()
	influence_system = InfluenceSystem.new()
	
	# Connect internal systems
	_connect_internal_systems()

func _connect_internal_systems():
	# Quantum system drives everything
	quantum_system.state_evolved.connect(_on_quantum_state_evolved)
	
	# Node graph responds to quantum changes
	node_graph.setup_from_quantum_system(quantum_system)
	
	# Sprite state responds to quantum changes
	sprite_state.setup_from_quantum_system(quantum_system)

func setup_for_biome(icon_composition: Dictionary, parametric_modifiers: Dictionary = {}):
	"""Initialize the math core for a specific biome"""
	# Setup biome composition
	biome_composition.setup_from_icons(icon_composition, parametric_modifiers)
	
	# Initialize quantum system from composition
	quantum_system.load_from_biome_composition(biome_composition)
	
	# Setup node graph - USE THE ACTUAL METHOD NAME
	node_graph.setup_from_quantum_system(quantum_system)
	
	# Setup sprite state - USE THE ACTUAL METHOD NAME
	sprite_state.setup_from_quantum_system(quantum_system)
	
	# Setup tool systems
	tool_system.setup_for_biome(biome_composition)
	operator_system.setup_for_biome(biome_composition)
	influence_system.setup_for_biome(biome_composition, influence_budget)

func evolve(delta_time: float):
	"""Advance the mathematical simulation"""
	if not auto_evolution:
		return
	
	# Evolve quantum system
	quantum_system.evolve(delta_time * time_scale * evolution_rate)
	
	# Process continuous operators
	operator_system.process_continuous_effects(delta_time)
	
	# Update sprite state
	sprite_state.update_from_quantum_state(quantum_system.get_state_snapshot())
	
	# Emit evolution signal
	state_evolved.emit(quantum_system.get_state_snapshot())

func get_node_info(node_index: int) -> Dictionary:
	"""Get comprehensive information about a specific node"""
	if node_index < 0 or node_index >= node_graph.get_node_count():
		return {}
	
	var node = node_graph.get_node(node_index)
	var quantum_state = quantum_system.get_component_state(node_index)
	var operators = operator_system.get_operators_for_node(node_index)
	var influence = influence_system.get_influence_for_node(node_index)
	
	return {
		"index": node_index,
		"emoji": node.emoji,
		"label": node.label,
		"magnitude": quantum_state.length(),
		"phase": quantum_state.angle(),
		"real": quantum_state.x,
		"imaginary": quantum_state.y,
		"is_compressed": node.is_compressed,
		"has_operators": operators.size() > 0,
		"operators": operators,
		"influence_data": influence,
		"connections": node_graph.get_connections(node_index),
		"stability": _calculate_node_stability(node_index)
	}

func get_system_state() -> Dictionary:
	"""Get overall system state information"""
	return {
		"total_energy": quantum_system.get_system_energy(),
		"phase_coherence": quantum_system.get_phase_coherence(),
		"dominant_component": quantum_system.get_dominant_component(),
		"stability_metric": _calculate_system_stability(),
		"biome_composition": biome_composition.get_composition_data(),
		"influence_budget": influence_budget.get_budget_data(),
		"active_operators": operator_system.get_active_operators(),
		"time_scale": time_scale,
		"evolution_rate": evolution_rate
	}

func get_sprite_state() -> Dictionary:
	"""Get current sprite generation state"""
	return sprite_state.get_state_data()

func get_node_graph() -> NodeGraph:
	"""Get the node graph for UI positioning"""
	return node_graph

func get_biome_composition() -> BiomeComposition:
	"""Get the biome composition for UI theming"""
	return biome_composition

# Tool Interface Methods
func can_deploy_tool(tool_name: String, node_index: int) -> bool:
	"""Check if a tool can be deployed at a node"""
	return tool_system.can_deploy_tool(tool_name, node_index)

func deploy_tool(tool_name: String, node_index: int) -> Dictionary:
	"""Deploy a tool at a specific node"""
	var result = tool_system.deploy_tool(tool_name, node_index)
	
	if result.success:
		# Apply the tool's effects to the mathematical system
		_apply_tool_effects(result.effects, node_index)
		
		# Emit signal for UI feedback
		tool_deployed.emit(tool_name, node_index, result.effects)
	
	return result

func _apply_tool_effects(effects: Dictionary, node_index: int):
	"""Apply tool effects to the mathematical system"""
	match effects.type:
		"spark_injection":
			# ➕ Instant energy injection
			quantum_system.inject_energy(node_index, effects.energy_delta)
			
		"druid_matrix_modification":
			# ✖️ Temporary matrix modification
			var modifier = MatrixModifier.new()
			modifier.setup_from_effects(effects)
			quantum_system.add_temporary_modifier(modifier)
			
		"operator_construction":
			# ➕ Build continuous factory
			var operator = Operator.new()
			operator.setup_from_effects(effects)
			operator_system.add_operator(operator, node_index)
			operator_deployed.emit(effects.operator_name, node_index)
			
		"influence_painting":
			# ✖️ Paint icon influence
			influence_system.paint_influence(node_index, effects.influence_data)
			influence_painted.emit(node_index, effects.influence_data)

# Influence Interface Methods
func can_paint_influence(node_index: int, influence_cost: float) -> bool:
	"""Check if influence can be painted at a node"""
	return influence_budget.can_afford(influence_cost)

func paint_influence(node_index: int, icon_influence: Dictionary) -> Dictionary:
	"""Paint icon influence at a specific node"""
	var result = influence_system.paint_influence(node_index, icon_influence)
	
	if result.success:
		# Modify the node's transformation matrix
		node_graph.modify_node_matrix(node_index, result.matrix_modification)
		
		# Update biome composition
		biome_composition.update_node_influence(node_index, icon_influence)
		
		# Consume influence budget
		influence_budget.spend(result.influence_cost)
		
		# Emit signals
		influence_painted.emit(node_index, icon_influence)
		node_modified.emit(node_index, result.matrix_modification)
	
	return result

# Compression Methods
func compress_node(node_index: int) -> Dictionary:
	"""Compress a node into a stable, simplified state"""
	var compression_result = node_graph.compress_node(node_index)
	
	if compression_result.success:
		# Update quantum system
		quantum_system.compress_component(node_index, compression_result.compressed_state)
		
		# Update sprite state
		sprite_state.compress_node(node_index)
		
		# Emit signal
		compression_completed.emit(node_index, compression_result)
	
	return compression_result

func decompress_node(node_index: int) -> Dictionary:
	"""Decompress a node back to full mathematical complexity"""
	var safety_check = check_decompression_safety(node_index)
	if not safety_check.is_safe:
		return {"success": false, "error_message": safety_check.warning}
	
	var decompression_result = node_graph.decompress_node(node_index)
	
	if decompression_result.success:
		# Create new BiomeMathCore for the expanded system
		var expanded_core = BiomeMathCore.new()
		expanded_core.setup_from_decompressed_system(decompression_result.expanded_system)
		
		return {
			"success": true,
			"expanded_core": expanded_core
		}
	
	return decompression_result

func check_decompression_safety(node_index: int) -> Dictionary:
	"""Check if decompression is safe given current biome context"""
	var node = node_graph.get_node(node_index)
	if not node.is_compressed:
		return {"is_safe": false, "warning": "Node is not compressed"}
	
	var original_context = node.get_compression_context()
	var current_context = biome_composition.get_context()
	var compatibility = current_context.calculate_compatibility(original_context)
	
	if compatibility < 0.7:
		return {"is_safe": false, "warning": "Context mismatch - high instability risk"}
	elif compatibility < 0.9:
		return {"is_safe": true, "warning": "Minor context differences"}
	else:
		return {"is_safe": true, "warning": ""}

# Utility Methods
func _calculate_node_stability(node_index: int) -> float:
	"""Calculate stability metric for a specific node"""
	var node = node_graph.get_node(node_index)
	var quantum_state = quantum_system.get_component_state(node_index)
	
	# Simple stability metric based on magnitude oscillation
	var magnitude = quantum_state.length()
	var phase_stability = 1.0 - abs(quantum_state.y) / max(magnitude, 0.01)
	
	return clamp(phase_stability, 0.0, 1.0)

func _calculate_system_stability() -> float:
	"""Calculate overall system stability"""
	var total_stability = 0.0
	var node_count = node_graph.get_node_count()
	
	for i in range(node_count):
		total_stability += _calculate_node_stability(i)
	
	return total_stability / max(node_count, 1)

func _on_quantum_state_evolved(new_state: PackedVector2Array):
	"""Handle quantum system evolution"""
	# Update dependent systems
	sprite_state.update_from_quantum_state(new_state)
	
	# Check for emergent behaviors
	_check_for_emergent_behaviors(new_state)

func _check_for_emergent_behaviors(state: PackedVector2Array):
	"""Detect and respond to emergent mathematical behaviors"""
	# Check for phase synchronization
	var coherence = quantum_system.get_phase_coherence()
	if coherence > 0.95:
		# Emit special event
		pass
	
	# Check for energy concentration
	var energy_distribution = []
	for component in state:
		energy_distribution.append(component.length_squared())
	
	# Check for instabilities
	for i in range(state.size()):
		if state[i].length() > 2.0:  # Instability threshold
			# Trigger emergency stabilization
			_emergency_stabilize_node(i)

func _emergency_stabilize_node(node_index: int):
	"""Emergency stabilization for unstable nodes"""
	var stabilization_modifier = MatrixModifier.new()
	stabilization_modifier.setup_stabilization(node_index, 0.5)  # Damping factor
	quantum_system.add_temporary_modifier(stabilization_modifier)
	
	# Emit warning
	node_modified.emit(node_index, {"emergency_stabilization": true})

# Pause/Resume Controls
func pause_evolution():
	auto_evolution = false

func resume_evolution():
	auto_evolution = true

func set_time_scale(scale: float):
	time_scale = clamp(scale, 0.0, 10.0)

func set_evolution_rate(rate: float):
	evolution_rate = clamp(rate, 0.0, 5.0)

# Save/Load Support
func serialize_state() -> Dictionary:
	"""Serialize the complete mathematical state"""
	return {
		"quantum_system": quantum_system.serialize(),
		"node_graph": node_graph.serialize(),
		"biome_composition": biome_composition.serialize(),
		"sprite_state": sprite_state.serialize(),
		"influence_budget": influence_budget.serialize(),
		"operators": operator_system.serialize(),
		"time_scale": time_scale,
		"evolution_rate": evolution_rate
	}

func deserialize_state(data: Dictionary):
	"""Restore from serialized state"""
	quantum_system.deserialize(data.get("quantum_system", {}))
	node_graph.deserialize(data.get("node_graph", {}))
	biome_composition.deserialize(data.get("biome_composition", {}))
	sprite_state.deserialize(data.get("sprite_state", {}))
	influence_budget.deserialize(data.get("influence_budget", {}))
	operator_system.deserialize(data.get("operators", {}))
	time_scale = data.get("time_scale", 1.0)
	evolution_rate = data.get("evolution_rate", 1.0)
	
	# Reconnect systems
	_connect_internal_systems()

func get_display_name() -> String:
	"""Get display name for this biome"""
	return biome_composition.get_display_name()

func setup_from_decompressed_system(system_data: Dictionary):
	"""Setup this core from decompressed system data"""
	deserialize_state(system_data)
