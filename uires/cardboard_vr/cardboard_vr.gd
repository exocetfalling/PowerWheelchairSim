class_name CardboardVR extends Node3D

@export_category("Controls")
@export var use_gyroscope : bool = true
@export var gyro_factor : float = 1

@export_category("Eyes")
@export_range(0.001, 0.1) var eye_distance : float = 0.063
@export_range(0, 5.0) var eye_height : float =  0.8
@export_range(-360, 360) var eye_convergence_angle : float = 0

var gyroscope_rates: Vector3 = Vector3.ZERO


func get_input(delta):
	if Input.is_action_just_pressed("gyro_toggle"):
		gyroscope_rates = Vector3.ZERO
		use_gyroscope = not use_gyroscope
	
	if Input.is_action_just_pressed("cam_align_fwd"):
		rotation = Vector3.ZERO
	
	if use_gyroscope:
		gyroscope_rates = Input.get_gyroscope()
		
		rotate_x(gyroscope_rates.x * gyro_factor * delta)
		rotate_y(gyroscope_rates.y * gyro_factor * delta)
		rotate_z(gyroscope_rates.z * gyro_factor * delta)
	else:
		rotation.x = Input.get_axis("cam_down", "cam_up")
		rotation.y = Input.get_axis("cam_left", "cam_right")


func _ready() -> void:
	$CardboardView.SetViewPorts($SubViewportL, $SubViewportR)


func _physics_process(delta: float) -> void:
	get_input(delta)
