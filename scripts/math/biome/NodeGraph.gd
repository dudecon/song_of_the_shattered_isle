# scripts/math/biome/NodeGraph.gd
class_name NodeGraph
extends Resource

# Node graph for positioning and connections
# Maps quantum system components to spatial positions

var nodes: Array[BiomeGraphNode] = []
var connections: Array[Array] = []
var layout_bounds: Rect2 = Rect2(0, 0, 800, 600)

func _init():
	_initialize_default_nodes()

func _initialize_default_nodes():
	"""Initialize default 7-node configuration"""
	nodes.clear()
	
	# Create 7 default nodes in circular layout
	var center = Vector2(400, 300)
	var radius = 150
	
	for i in range(7):
		var angle = (i * 2 * PI) / 7.0
		var position = center + Vector2(cos(angle), sin(angle)) * radius
		
		var node = BiomeGraphNode.new()
		node.setup(i, position, "Component " + str(i), "🔹")
		nodes.append(node)
	
	# Initialize connections matrix
	connections.clear()
	for i in range(7):
		var row = []
		for j in range(7):
			row.append(0.0)  # No connections by default
		connections.append(row)

func setup_from_quantum_system(quantum_system: DynamicalSystem):
	"""Setup nodes from quantum system"""
	var dimension = quantum_system.dimension
	
	# Ensure we have enough nodes
	while nodes.size() < dimension:
		var node = BiomeGraphNode.new()
		node.setup(nodes.size(), Vector2.ZERO, "Node " + str(nodes.size()), "⚪")
		nodes.append(node)
	
	# Update node positions based on quantum state
	var state_snapshot = quantum_system.get_state_snapshot()
	if state_snapshot:
		_update_node_positions(state_snapshot)

func _update_node_positions(state_vector: Array):
	"""Update node positions based on quantum state"""
	var center = Vector2(layout_bounds.size.x / 2, layout_bounds.size.y / 2)
	
	for i in range(min(nodes.size(), state_vector.size())):
		var component = state_vector[i]
		if component is Vector2:
			var magnitude = component.length()
			var angle = component.angle()
			
			# Base position in circular layout
			var base_angle = (i * 2 * PI) / nodes.size()
			var base_radius = min(layout_bounds.size.x, layout_bounds.size.y) * 0.3
			
			# Modify position based on quantum state
			var dynamic_radius = base_radius * (0.5 + magnitude * 0.5)
			var dynamic_angle = base_angle + angle * 0.1
			
			var position = center + Vector2(cos(dynamic_angle), sin(dynamic_angle)) * dynamic_radius
			
			# Keep within bounds
			position.x = clamp(position.x, 50, layout_bounds.size.x - 50)
			position.y = clamp(position.y, 50, layout_bounds.size.y - 50)
			
			nodes[i].position = position

func get_node_count() -> int:
	"""Get number of nodes"""
	return nodes.size()

func get_node(index: int) -> BiomeGraphNode:
	"""Get node by index"""
	if index >= 0 and index < nodes.size():
		return nodes[index]
	return null

func get_node_info(index: int) -> Dictionary:
	"""Get node info by index"""
	if index >= 0 and index < nodes.size():
		return nodes[index].get_node_info()
	return {}

func get_connections(node_index: int) -> Array:
	"""Get connections for a node"""
	if node_index >= 0 and node_index < connections.size():
		return connections[node_index]
	return []

func modify_node_matrix(node_index: int, modification: Dictionary):
	"""Modify node transformation matrix"""
	if node_index >= 0 and node_index < nodes.size():
		var node = nodes[node_index]
		# Apply modification to node
		if modification.has("influence_strength"):
			node.influence_strength = modification.influence_strength
		if modification.has("icon_type"):
			node.icon_type = modification.icon_type

func compress_node(node_index: int) -> Dictionary:
	"""Compress a node to simplified state"""
	if node_index < 0 or node_index >= nodes.size():
		return {"success": false, "error": "Invalid node index"}
	
	var node = nodes[node_index]
	node.is_compressed = true
	
	# Generate compression result
	var compression_result = {
		"success": true,
		"compressed_state": {
			"magnitude": 1.0,
			"phase": 0.0,
			"simplified": true
		},
		"node_index": node_index
	}
	
	return compression_result

func decompress_node(node_index: int) -> Dictionary:
	"""Decompress a node back to full complexity"""
	if node_index < 0 or node_index >= nodes.size():
		return {"success": false, "error": "Invalid node index"}
	
	var node = nodes[node_index]
	node.is_compressed = false
	
	# Generate decompression result
	var decompression_result = {
		"success": true,
		"expanded_system": {
			"dimension": 7,
			"complexity": "full"
		},
		"node_index": node_index
	}
	
	return decompression_result

func serialize() -> Dictionary:
	"""Serialize node graph"""
	var serialized_nodes = []
	for node in nodes:
		serialized_nodes.append(node.serialize())
	
	return {
		"nodes": serialized_nodes,
		"connections": connections,
		"layout_bounds": {
			"x": layout_bounds.position.x,
			"y": layout_bounds.position.y,
			"w": layout_bounds.size.x,
			"h": layout_bounds.size.y
		}
	}

func deserialize(data: Dictionary):
	"""Deserialize node graph"""
	# Deserialize nodes
	var node_data = data.get("nodes", [])
	nodes.clear()
	for node_dict in node_data:
		var node = BiomeGraphNode.new()
		node.deserialize(node_dict)
		nodes.append(node)
	
	# Deserialize connections
	connections = data.get("connections", [])
	
	# Deserialize layout bounds
	var bounds_data = data.get("layout_bounds", {})
	if bounds_data.has("x"):
		layout_bounds = Rect2(
			bounds_data.x, bounds_data.y,
			bounds_data.w, bounds_data.h
		)
