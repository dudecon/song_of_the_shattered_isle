# scripts/utils/ForceDirectedLayout.gd
class_name ForceDirectedLayout
extends Resource

var nodes: Array[BiomeGraphNode] = []
var node_positions: Array[Vector2] = []
var node_velocities: Array[Vector2] = []
var connections: Array[Array] = []

# Layout parameters
var repulsion_strength: float = 500.0
var attraction_strength: float = 0.01
var damping: float = 0.95
var center_force: float = 0.001
var bounds_size: Vector2 = Vector2(400, 400)

func setup_nodes_and_connections(node_array: Array[BiomeGraphNode], connection_matrix: Array[Array]):
	nodes = node_array
	connections = connection_matrix
	
	# Initialize positions and velocities
	node_positions.clear()
	node_velocities.clear()
	
	for i in range(nodes.size()):
		# Start with circular arrangement
		var angle = i * 2.0 * PI / nodes.size()
		var radius = min(bounds_size.x, bounds_size.y) * 0.3
		var pos = Vector2(cos(angle) * radius, sin(angle) * radius)
		node_positions.append(pos)
		node_velocities.append(Vector2.ZERO)

func update_forces(quantum_state: PackedVector2Array, connection_matrix: Array[Array]):
	if nodes.size() != node_positions.size():
		return
	
	# Calculate forces
	var forces: Array[Vector2] = []
	for i in range(nodes.size()):
		forces.append(Vector2.ZERO)
	
	# Repulsion forces (nodes push each other away)
	for i in range(nodes.size()):
		for j in range(i + 1, nodes.size()):
			var diff = node_positions[i] - node_positions[j]
			var distance = diff.length()
			if distance > 0.1:  # Avoid division by zero
				var force = diff.normalized() * repulsion_strength / (distance * distance)
				forces[i] += force
				forces[j] -= force
	
	# Attraction forces (connected nodes pull each other)
	for i in range(nodes.size()):
		for j in range(nodes.size()):
			if i != j and j < connections.size() and i < connections[j].size():
				var connection_strength = connections[i][j]
				if connection_strength > 0.1:  # Significant connection
					var diff = node_positions[j] - node_positions[i]
					var distance = diff.length()
					if distance > 0.1:
						var force = diff.normalized() * attraction_strength * connection_strength * distance
						forces[i] += force
	
	# Center force (pull toward center)
	for i in range(nodes.size()):
		var center_diff = Vector2.ZERO - node_positions[i]
		forces[i] += center_diff * center_force
	
	# Update velocities and positions
	for i in range(nodes.size()):
		node_velocities[i] += forces[i] * 0.01  # Time step
		node_velocities[i] *= damping
		node_positions[i] += node_velocities[i] * 0.01
		
		# Keep within bounds
		node_positions[i] = node_positions[i].clamp(
			-bounds_size * 0.5, bounds_size * 0.5
		)

func get_node_positions() -> Array[Vector2]:
	return node_positions

func get_node_position(index: int) -> Vector2:
	if index >= 0 and index < node_positions.size():
		return node_positions[index]
	return Vector2.ZERO

func serialize() -> Dictionary:
	return {
		"node_positions": node_positions,
		"node_velocities": node_velocities,
		"repulsion_strength": repulsion_strength,
		"attraction_strength": attraction_strength,
		"damping": damping,
		"center_force": center_force,
		"bounds_size": var_to_str(bounds_size)
	}

func deserialize(data: Dictionary):
	node_positions = data.get("node_positions", [])
	node_velocities = data.get("node_velocities", [])
	repulsion_strength = data.get("repulsion_strength", 500.0)
	attraction_strength = data.get("attraction_strength", 0.01)
	damping = data.get("damping", 0.95)
	center_force = data.get("center_force", 0.001)
	
	var bounds_str = data.get("bounds_size", "")
	if bounds_str != "":
		bounds_size = str_to_var(bounds_str)
	else:
		bounds_size = Vector2(400, 400)
