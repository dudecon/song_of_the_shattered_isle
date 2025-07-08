# scripts/Main.gd
class_name Main
extends Control

@onready var conductor: QuantumConductor = $QuantumConductor
@onready var visualization: QuantumVisualization = $QuantumVisualization
@onready var time_slider: HSlider = $UI/Controls/TimeSlider
@onready var pause_button: Button = $UI/Controls/PauseButton
@onready var status_label: Label = $UI/Controls/StatusLabel

func _ready():
    visualization.conductor = conductor
    
    # Connect the working UI elements
    time_slider.value_changed.connect(_on_time_scale_changed)
    pause_button.pressed.connect(_on_pause_pressed)
    
    # Update status periodically
    var timer = Timer.new()
    timer.wait_time = 0.5
    timer.timeout.connect(_update_status)
    timer.autostart = true
    add_child(timer)

func _on_time_scale_changed(value: float):
    conductor.set_time_scale(value)
    $UI/Controls/TimeLabel.text = "Time Scale: %.1f" % value

func _on_pause_pressed():
    if conductor.auto_evolution:
        conductor.pause_evolution()
        pause_button.text = "Resume"
    else:
        conductor.resume_evolution()
        pause_button.text = "Pause Evolution"

func _update_status():
    var time_text = "Status: %s\nTime: %.1fs" % [
        "Running" if conductor.auto_evolution else "Paused",
        Time.get_time_dict_from_system()["second"]
    ]
    status_label.text = time_text