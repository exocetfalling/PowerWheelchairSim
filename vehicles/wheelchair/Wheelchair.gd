extends VehicleBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var input_joystick : Vector2 = Vector2.ZERO

var linear_velocity_local : Vector3 = Vector3.ZERO
var angular_velocity_local : Vector3 = Vector3.ZERO

var steering_angle_target : float = 0.00

var wheel_speed_rear_left = 0.00
var wheel_speed_rear_right = 0.00

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "input_joystick", "round")
	DebugOverlay.stats.add_property(self, "angular_velocity_local", "round")
	DebugOverlay.stats.add_property(self, "steering_angle_target", "round")
	pass # Replace with function body.

func interpolate_linear(value_current, value_target, rate, delta_time):
	if (abs(value_current - value_target) > delta_time):
		if (value_current < value_target):
			return value_current + rate * delta_time
		if (value_current > value_target):
			return value_current - rate * delta_time
		else:
			return value_target
	else:
		return value_target

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	
	linear_velocity_local = self.transform.basis.xform_inv(linear_velocity)
	angular_velocity_local = global_transform.basis.z * (angular_velocity)
	
#	steering_angle = atan2((linear_velocity_local.x - angular_velocity.y * 0.22), -linear_velocity_local.z)
#	steering_angle = atan2(angular_velocity.y * 0.22, -linear_velocity_local.z)

	# Simulate castering front wheels
	steering_angle_target = \
			( \
			rad2deg(atan2((-linear_velocity_local.x + \
			angular_velocity.y * 0.22), -linear_velocity_local.z)) \
			)
	# Ensures steering target ranges from -180 to +180 instead of 0 to 360
	# For better interpolation
	if (steering_angle_target > 180):
		steering_angle_target - 360
	
#	$WheelRearLeft.engine_force = -40 * input_joystick.y - 40 * input_joystick.x
#	$WheelRearRight.engine_force = -40 * input_joystick.y + 40 * input_joystick.x
	
	$WheelRearLeft.engine_force = -40 * \
			$PIDCalcWheelLeft.calc_PID_output(2 * input_joystick.y, -linear_velocity_local.z) \
			- 40 * input_joystick.x
	$WheelRearRight.engine_force = -40 * \
			$PIDCalcWheelRight.calc_PID_output(2 * input_joystick.y, -linear_velocity_local.z) \
			+ 40 * input_joystick.x
	
	
	# Interpolate steering angles
	steering = lerp_angle(steering, steering_angle_target, 0.5)
	
#	steering = interpolate_linear(steering, steering_angle_target, 60, delta)
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animations 
	$Model/WheelRearLeft.rotation = $WheelRearLeft.rotation
	$Model/WheelRearRight.rotation = $WheelRearRight.rotation
	
	$Model/CastorLeft.rotation.y = deg2rad(steering)
	$Model/CastorRight.rotation.y = deg2rad(steering)
	
	$Model/CastorLeft/WheelFrontLeft.rotation.x = $WheelFrontLeft.rotation.x
	$Model/CastorRight/WheelFrontRight.rotation.x = $WheelFrontRight.rotation.x
	
	pass

func get_input(delta):
	# Joystick input as axes
	input_joystick.x = Input.get_axis("ui_left", "ui_right")
	input_joystick.y = Input.get_axis("ui_down", "ui_up")
