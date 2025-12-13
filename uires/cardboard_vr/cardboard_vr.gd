class_name CardboardVR extends Node3D

@export_category("Controls")
@export var use_gyroscope : bool = true
@export var mouse_sensitivity : float = 0.003
@export var gyro_factor : float = 0.2
@export var handle_mouse_capture : bool = true
@export var input_event_free_mouse : String  = "ui_cancel"

@export_category("Eyes")
@export_range(0.001, 0.1) var eye_distance : float = 0.063
@export_range(0, 5.0) var eye_height : float =  0.8
@export_range(-360, 360) var eye_convergence_angle : float = 0


func _input(event):
	pass


func _ready() -> void:
	$CardboardView.SetViewPorts($SubViewportL, $SubViewportR)


func _process(delta: float) -> void:
	pass
