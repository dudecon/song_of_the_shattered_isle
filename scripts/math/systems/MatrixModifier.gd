# scripts/math/systems/MatrixModifier.gd
class_name MatrixModifier
extends Resource

# Temporary matrix modifications for tool effects

var modifier_type: String = ""
var strength: float = 1.0
var duration: float = 0.0
var target_nodes: Array[int] = []
var matrix_delta: Array[Array] = []
var is_active: bool = false
var remaining_time: float = 0.0

func _init():
	pass

func setup_from_effects(effects: Dictionary):
	"""Setup modifier from tool effects"""
	modifier_type = effects.get("type", "amplification")
	strength = effects.get("amplification", 1.0)
	duration = effects.get("duration", 30.0)
	target_nodes = effects.get("target_nodes", [])
	
	remaining_time = duration
	is_active = true
	
	_generate_matrix_delta()

func _generate_matrix_delta():
	"""Generate matrix modification delta"""
	matrix_delta.clear()
	
	var dimension = 7
	for i in range(dimension):
		var row = []
		for j in range(dimension):
			row.append(0.0)
		matrix_delta.append(row)
	
	# Apply modification based on type
	match modifier_type:
		"amplification":
			_apply_amplification_delta()
		"stabilization":
			_apply_stabilization_delta()
		"chaos":
			_apply_chaos_delta()

func _apply_amplification_delta():
	"""Apply amplification matrix delta"""
	var amplification = (strength - 1.0) * 0.1
	
	for i in range(7):
		for j in range(7):
			if i == j:
				matrix_delta[i][j] = amplification
			else:
				matrix_delta[i][j] = amplification * 0.1

func _apply_stabilization_delta():
	"""Apply stabilization matrix delta"""
	var stabilization = strength * 0.05
	
	for i in range(7):
		matrix_delta[i][i] = stabilization

func _apply_chaos_delta():
	"""Apply chaos matrix delta"""
	var chaos_strength = strength * 0.02
	
	for i in range(7):
		for j in range(7):
			if i != j:
				matrix_delta[i][j] = randf_range(-chaos_strength, chaos_strength)

func update(delta_time: float) -> bool:
	"""Update modifier, return true if still active"""
	if not is_active:
		return false
	
	remaining_time -= delta_time
	
	if remaining_time <= 0.0:
		is_active = false
		return false
	
	return true

func get_matrix_contribution() -> Array[Array]:
	"""Get matrix contribution for current frame"""
	if not is_active:
		return []
	
	# Scale by remaining time for fade-out effect
	var time_factor = remaining_time / duration
	var scaled_delta = []
	
	for i in range(matrix_delta.size()):
		var row = []
		for j in range(matrix_delta[i].size()):
			row.append(matrix_delta[i][j] * time_factor)
		scaled_delta.append(row)
	
	return scaled_delta

func serialize() -> Dictionary:
	"""Serialize modifier"""
	return {
		"modifier_type": modifier_type,
		"strength": strength,
		"duration": duration,
		"target_nodes": target_nodes,
		"matrix_delta": matrix_delta,
		"is_active": is_active,
		"remaining_time": remaining_time
	}

func deserialize(data: Dictionary):
	"""Deserialize modifier"""
	modifier_type = data.get("modifier_type", "")
	strength = data.get("strength", 1.0)
	duration = data.get("duration", 0.0)
	target_nodes = data.get("target_nodes", [])
	matrix_delta = data.get("matrix_delta", [])
	is_active = data.get("is_active", false)
	remaining_time = data.get("remaining_time", 0.0)
