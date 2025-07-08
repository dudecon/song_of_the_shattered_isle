# scripts/Main.gd
class_name Main
extends Control

@onready var conductor: QuantumConductor = $QuantumConductor
@onready var visualization: QuantumVisualization = $QuantumVisualization
@onready var controls: VBoxContainer = $UI/Controls

var time_scale_slider: HSlider
var pause_button: Button
var info_label: Label

func _ready():
	_setup_ui()
	visualization.conductor = conductor

func _setup_ui():
	# Time scale control
	var time_label = Label.new()
	time_label.text = "Time Scale"
	controls.add_child(time_label)
	
	time_scale_slider = HSlider.new()
	time_scale_slider.min_value = 0.0
	time_scale_slider.max_value = 3.0
	time_scale_slider.value = 1.0
	time_scale_slider.step = 0.1
	time_scale_slider.value_changed.connect(_on_time_scale_changed)
	controls.add_child(time_scale_slider)
	
	# Pause/Resume button
	pause_button = Button.new()
	pause_button.text = "Pause"
	pause_button.pressed.connect(_on_pause_pressed)
	controls.add_child(pause_button)
	
	# Info display
	info_label = Label.new()
	info_label.text = "Quantum Singularity - Mathematical Foundation"
	controls.add_child(info_label)

func _on_time_scale_changed(value: float):
	conductor.set_time_scale(value)

func _on_pause_pressed():
	if conductor.auto_evolution:
		conductor.pause_evolution()
		pause_button.text = "Resume"
	else:
		conductor.resume_evolution()
		pause_button.text = "Pause"
