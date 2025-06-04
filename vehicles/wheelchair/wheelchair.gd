extends VehicleBody3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var WHEELBASE_WIDTH: float = 1
@export var WHEEL_RADIUS_REAR: float = 1

var input_joystick : Vector2 = Vector2.ZERO

var linear_velocity_local : Vector3 = Vector3.ZERO
var angular_velocity_local : Vector3 = Vector3.ZERO

var steering_angle_target_l : float = 0.00
var steering_angle_target_r : float = 0.00

var steering_lerp_factor : float = 0.2

var wheel_speed_rear_left = 0.00
var wheel_speed_rear_right = 0.00

var turn_radius: float = 0.00
var wheel_velocity_ratio: float = 0.00

var wheel_speed_rear_left_tgt: float = 0.00
var wheel_speed_rear_right_tgt: float = 0.00

@export_range(0.1, 2, 0.1) var speed_limit: float = 1.5

@export_range(0.1, 2, 0.1) var turn_rate_scalar: float = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	#DebugOverlay.stats.add_property(self, "input_joystick", "round")
#	DebugOverlay.stats.add_property(self, "angular_velocity_local", "round")
#	DebugOverlay.stats.add_property(self, "steering_angle_target", "round")
#	DebugOverlay.stats.add_property(self, "steering", "round")
#	DebugOverlay.stats.add_property(self, "wheel_velocity_ratio", "")
#	DebugOverlay.stats.add_property(self, "turn_radius", "")
	#DebugOverlay.stats.add_property(self, "linear_velocity_local", "round")
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
	
	linear_velocity_local = (linear_velocity) * self.transform.basis
	angular_velocity_local = global_transform.basis.z * (angular_velocity)
	
#	steering_angle = atan2((linear_velocity_local.x - angular_velocity.y * 0.22), -linear_velocity_local.z)
#	steering_angle = atan2(angular_velocity.y * 0.22, -linear_velocity_local.z)

	# Simulate castering front wheels
	steering_angle_target_l = atan2(0.391, (turn_radius + $WheelFrontLeft.position.x))
	steering_angle_target_r = atan2(0.391, (turn_radius + $WheelFrontRight.position.x))
	
	wheel_speed_rear_left_tgt = \
		-(+input_joystick.x * turn_rate_scalar + input_joystick.y) * speed_limit / WHEEL_RADIUS_REAR
	
	wheel_speed_rear_right_tgt = \
		-(-input_joystick.x * turn_rate_scalar + input_joystick.y) * speed_limit / WHEEL_RADIUS_REAR
	
	$WheelRearLeft.engine_force = \
		$PIDCalcWheelLeft.calc_PID_output(wheel_speed_rear_left_tgt, wheel_speed_rear_left)
	$WheelRearRight.engine_force = \
		$PIDCalcWheelRight.calc_PID_output(wheel_speed_rear_right_tgt, wheel_speed_rear_right)
	
	
	# Increase caster turn rate as velocity increases
	# Clamping from 0 to 1
	steering_lerp_factor = clamp((linear_velocity_local.length()), 0, 1)
#	steering_lerp_factor = 0.5
	
	wheel_speed_rear_left = $WheelRearLeft.get_rpm() * 0.1047
	wheel_speed_rear_right = $WheelRearRight.get_rpm() * 0.1047
	
	if (wheel_speed_rear_left - wheel_speed_rear_right) != 0:
		wheel_velocity_ratio = \
			(wheel_speed_rear_left + wheel_speed_rear_right) / \
			(wheel_speed_rear_left - wheel_speed_rear_right)
	else:
		wheel_velocity_ratio = INF
	
	turn_radius = -wheel_velocity_ratio * WHEEL_RADIUS_REAR
	
	$WheelFrontLeft.steering = rad_to_deg(lerp_angle( \
		deg_to_rad($WheelFrontLeft.steering), \
		steering_angle_target_l, \
		steering_lerp_factor
		))
	$WheelFrontRight.steering = rad_to_deg(lerp_angle( \
		deg_to_rad( $WheelFrontRight.steering), \
		steering_angle_target_r, \
		steering_lerp_factor
		))
	
	
#	$CSGSphere.translation.x = turn_radius
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Animations 
	$Model/WheelRearLeft.rotation = $WheelRearLeft.rotation
	$Model/WheelRearRight.rotation = $WheelRearRight.rotation
	$Model/WheelRearLeft.position = $WheelRearLeft.position
	$Model/WheelRearRight.position = $WheelRearRight.position
	
	# Fix inverted rims
	$Model/WheelRearLeft.rotation.x = -$WheelRearLeft.rotation.x
	$Model/WheelRearLeft.rotation.y = $WheelRearLeft.rotation.y + PI
	$Model/WheelRearRight.rotation.x = -$WheelRearRight.rotation.x
	$Model/WheelRearRight.rotation.y = $WheelRearRight.rotation.y + PI
	
	$Model/CastorLeft.rotation.y = deg_to_rad($WheelFrontLeft.steering)
	$Model/CastorRight.rotation.y = deg_to_rad($WheelFrontRight.steering)
	
	$Model/CastorLeft/WheelFrontLeft.rotation.x = $WheelFrontLeft.rotation.x
	$Model/CastorRight/WheelFrontRight.rotation.x = $WheelFrontRight.rotation.x
	
	$HUDBasic.current_speed = linear_velocity.length()
	pass

func get_input(delta):
	# Joystick input as axes
	input_joystick.x = Input.get_axis("joystick_left", "joystick_right")
	input_joystick.y = Input.get_axis("joystick_down", "joystick_up")
