extends VehicleBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var input_joystick : Vector2 = Vector2.ZERO

var linear_velocity_local : Vector3 = Vector3.ZERO
var angular_velocity_local : Vector3 = Vector3.ZERO

var steering_angle : float = 0.00

var wheel_speed_rear_left = 0.00
var wheel_speed_rear_right = 0.00

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "input_joystick", "round")
	DebugOverlay.stats.add_property(self, "angular_velocity_local", "round")
	DebugOverlay.stats.add_property(self, "steering_angle", "")
	pass # Replace with function body.

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	
	linear_velocity_local = self.transform.basis.xform_inv(linear_velocity)
	angular_velocity_local = global_transform.basis.z * (angular_velocity)
	
#	steering_angle = atan2((linear_velocity_local.x - angular_velocity.y * 0.22), -linear_velocity_local.z)
	steering_angle = atan2(angular_velocity.y * 0.22, -linear_velocity_local.z)
	
	$WheelRearLeft.engine_force = -20 * input_joystick.y - 20 * input_joystick.x
	$WheelRearRight.engine_force = -20 * input_joystick.y + 20 * input_joystick.x
	
	steering = rad2deg(steering_angle)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Model/WheelRearLeft.rotation = $WheelRearLeft.rotation
	$Model/WheelRearRight.rotation = $WheelRearRight.rotation
	
	$Model/CastorLeft.rotation.y = deg2rad(steering_angle)
	$Model/CastorRight.rotation.y = deg2rad(steering_angle)
	
	$Model/CastorLeft/WheelFrontLeft.rotation.x = $WheelFrontLeft.rotation.x
	$Model/CastorRight/WheelFrontRight.rotation.x = $WheelFrontRight.rotation.x
	
	pass

func get_input(delta):
	# Joystick input as axes
	input_joystick.x = Input.get_axis("ui_left", "ui_right")
	input_joystick.y = Input.get_axis("ui_down", "ui_up")
