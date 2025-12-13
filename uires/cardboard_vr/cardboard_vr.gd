class_name CardboardVR extends Node3D

@export_category("Controls")
@export var use_gyroscope : bool = true
@export var gyro_factor : float = 1

@export_category("Eyes")
@export_range(0.001, 0.1) var eye_distance : float = 0.063
@export_range(0, 5.0) var eye_height : float =  0.8
@export_range(-360, 360) var eye_convergence_angle : float = 0

var rotation_sensor: Vector3 = Vector3.ZERO

var pitch: float = 0.0
var roll: float = 0.0
var yaw: float = 0.0

var magnet: Vector3 = Input.get_magnetometer()
var gravity: Vector3 = Input.get_gravity()
var roll_acc = atan2(-gravity.x, -gravity.y) 
var pitch_acc = atan2(gravity.z, -gravity.y)
var yaw_magnet = atan2(-magnet.x, magnet.z)

var gyroscope: Vector3 = Input.get_gyroscope().rotated(-Vector3.FORWARD, roll)

var initial_yaw : float = 0.0

var k : float = 0.98


func get_input(delta):
	if Input.is_action_just_pressed("gyro_toggle"):
		rotation_sensor = Vector3.ZERO
		use_gyroscope = not use_gyroscope
	
	if Input.is_action_just_pressed("cam_align_fwd"):
		rotation = Vector3.ZERO
		initial_yaw = atan2(-magnet.x, magnet.z)
		
	if use_gyroscope:
		rotation = rotation_sensor
	else:
		rotation.x = Input.get_axis("cam_down", "cam_up")
		rotation.y = Input.get_axis("cam_left", "cam_right")


func _ready() -> void:
	$CardboardView.SetViewPorts($SubViewportL, $SubViewportR)
	await get_tree().physics_frame
	magnet = Input.get_magnetometer()
	initial_yaw = atan2(-magnet.x, magnet.z)

func _physics_process(delta: float) -> void:
	get_input(delta)
	
	magnet = Input.get_magnetometer().rotated(-Vector3.FORWARD, rotation.z).rotated(Vector3.RIGHT, rotation.x)
	gravity = Input.get_gravity()
	roll_acc = atan2(-gravity.x, -gravity.y) 
	gravity = gravity.rotated(-Vector3.FORWARD, rotation.z)
	pitch_acc = atan2(gravity.z, -gravity.y)
	yaw_magnet = atan2(-magnet.x, magnet.z)
	
	gyroscope = Input.get_gyroscope().rotated(-Vector3.FORWARD, roll)
	pitch = lerp_angle(pitch_acc, pitch + gyroscope.x * delta, k)
	yaw = lerp_angle(yaw_magnet, yaw + gyroscope.y * delta, k)
	roll = lerp_angle(roll_acc, roll + gyroscope.z * delta, k) 
	
	rotation_sensor = Vector3(pitch, yaw - initial_yaw, roll)
