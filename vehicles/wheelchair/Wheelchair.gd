extends VehicleBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var input_joystick : Vector2 = Vector2.ZERO

var linear_velocity_local : Vector3 = Vector3.ZERO
var angular_velocity_local : Vector3 = Vector3.ZERO

var steering_angle_target : float = 0.00
var steering_lerp_factor : float = 0.2

var wheel_speed_rear_left = 0.00
var wheel_speed_rear_right = 0.00

var turn_radius: float = 0.00
var wheel_velocity_ratio: float = 0.00
export var wheelbase_width: float = 0.49

# Called when the node enters the scene tree for the first time.
func _ready():
	DebugOverlay.stats.add_property(self, "input_joystick", "round")
	DebugOverlay.stats.add_property(self, "angular_velocity_local", "round")
	DebugOverlay.stats.add_property(self, "steering_angle_target", "round")
	DebugOverlay.stats.add_property(self, "steering", "round")
	DebugOverlay.stats.add_property(self, "wheel_velocity_ratio", "")
	DebugOverlay.stats.add_property(self, "turn_radius", "")
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
#	if (steering_angle_target > 180):
#		steering_angle_target - 360
	
#	$WheelRearLeft.engine_force = -40 * input_joystick.y - 40 * input_joystick.x
#	$WheelRearRight.engine_force = -40 * input_joystick.y + 40 * input_joystick.x
	
	$WheelRearLeft.engine_force = -40 * \
			$PIDCalcWheelLeft.calc_PID_output(4 * input_joystick.y, -linear_velocity_local.z) \
			- 40 * input_joystick.x
	$WheelRearRight.engine_force = -40 * \
			$PIDCalcWheelRight.calc_PID_output(4 * input_joystick.y, -linear_velocity_local.z) \
			+ 40 * input_joystick.x
	
	# Increase caster turn rate as velocity increases
	# Clamping from 0 to 1
	steering_lerp_factor = clamp((linear_velocity_local.length()), 0, 1)
	
	# Interpolate steering angles
	# Convert to rad. for proper use of lerp_angle()
	# Convert back to deg. for steering
#	steering = rad2deg(lerp_angle(deg2rad(steering), deg2rad(steering_angle_target), steering_lerp_factor))
	
#	steering = interpolate_linear(steering, steering_angle_target, 60, delta)
#	steering = rad2deg(atan2(0.391, turn_radius))
	
	wheel_speed_rear_left = $WheelRearLeft.get_rpm() * 0.1047
	wheel_speed_rear_right = $WheelRearRight.get_rpm() * 0.1047
	
	if (wheel_speed_rear_left - wheel_speed_rear_right) != 0:
		wheel_velocity_ratio = \
			(wheel_speed_rear_left + wheel_speed_rear_right) / \
			(wheel_speed_rear_left - wheel_speed_rear_right)
	else:
		wheel_velocity_ratio = INF
	
	turn_radius = -wheel_velocity_ratio * 0.4
	
	$WheelFrontLeft.steering = rad2deg(atan2(0.391, (turn_radius + $WheelFrontLeft.translation.x)))
	$WheelFrontRight.steering = rad2deg(atan2(0.391, (turn_radius + $WheelFrontRight.translation.x)))
	
	
#	$CSGSphere.translation.x = turn_radius
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animations 
	$Model/WheelRearLeft.rotation = $WheelRearLeft.rotation
	$Model/WheelRearRight.rotation = $WheelRearRight.rotation
	
	$Model/CastorLeft.rotation.y = deg2rad($WheelFrontLeft.steering)
	$Model/CastorRight.rotation.y = deg2rad($WheelFrontRight.steering)
	
	
	$Model/CastorLeft/WheelFrontLeft.rotation.x = $WheelFrontLeft.rotation.x
	$Model/CastorRight/WheelFrontRight.rotation.x = $WheelFrontRight.rotation.x
	
	pass

func get_input(delta):
	# Joystick input as axes
	input_joystick.x = Input.get_axis("joystick_left", "joystick_right")
	input_joystick.y = Input.get_axis("joystick_down", "joystick_up")
