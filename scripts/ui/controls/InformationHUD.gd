# scripts/ui/controls/InformationHUD.gd
class_name InformationHUD
extends Control

@onready var system_status: Label = $SystemStatus
@onready var node_details: Label = $NodeDetails
@onready var resource_display: Label = $ResourceDisplay
@onready var influence_meter: ProgressBar = $InfluenceMeter

func show_node_details(node_info: Dictionary):
	if not node_details:
		return
	
	var text = "%s %s\n" % [node_info.get("emoji", "❓"), node_info.get("label", "Unknown")]
	text += "Energy: %.2f\n" % node_info.get("magnitude", 0.0)
	text += "Stability: %.2f\n" % node_info.get("stability", 0.0)
	
	if node_info.get("has_operators", false):
		text += "Operators: %d\n" % node_info.get("operators", []).size()
	
	node_details.text = text

func update_system_status(state: Dictionary):
	if not system_status:
		return
	
	var text = "Energy: %.1f\n" % state.get("total_energy", 0.0)
	text += "Stability: %.1f\n" % state.get("stability_metric", 0.0)
	text += "Dominant: %s" % state.get("dominant_component", "None")
	
	system_status.text = text

func update_system_metrics(state: Array):
	if not system_status:
		return
	
	var total_energy = 0.0
	for component in state:
		if component is Vector2:
			total_energy += component.length_squared()
	
	system_status.text = "Total Energy: %.2f" % total_energy

func set_information_density(zoom: float):
	# Show more/less info based on zoom
	var show_details = zoom > 0.7
	if node_details:
		node_details.visible = show_details

func _ready():
	# Create UI elements if not in scene
	if not system_status:
		system_status = Label.new()
		system_status.text = "System: Starting..."
		add_child(system_status)
	
	if not node_details:
		node_details = Label.new()
		node_details.text = "Select a node..."
		node_details.position = Vector2(0, 60)
		add_child(node_details)
	
	if not resource_display:
		resource_display = Label.new()
		resource_display.text = "Resources: Loading..."
		resource_display.position = Vector2(0, 120)
		add_child(resource_display)
	
	if not influence_meter:
		influence_meter = ProgressBar.new()
		influence_meter.position = Vector2(0, 160)
		influence_meter.size = Vector2(200, 20)
		add_child(influence_meter)
