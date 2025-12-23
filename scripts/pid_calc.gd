extends Node

class_name PIDCalc

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var value_setpoint: float = 0
var value_current: float = 0

var value_previous: float = 0
var value_delta: float = 0
var time_delta: float = 0.0167

var proportional: float = 0
var integral: float = 0
var derivative: float = 0

var value_error_current: float = 0
var value_error_previous: float = 0
var value_error_delta: float = 0

@export var term_P: float = 0
@export var term_I: float = 0
@export var term_D: float = 0

# Maximum integral value, beyond whick clamping occurs
@export var integral_max = 100.00

var output_P: float = 0
var output_I: float = 0
var output_D: float = 0
var output_total: float = 0

var reset_integral : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta): 
	# Output for proportional term 
	value_error_current = value_setpoint - value_current
	proportional = value_error_current
	output_P = term_P * proportional
	
	value_previous = value_current
	value_current = value_current
	
	value_delta = (value_current - value_previous)
	
	# Output for integral term 
	integral += value_error_current * time_delta
	integral = clamp(integral, -integral_max, integral_max)
	output_I = term_I * integral

	# Output for derivative term 
	value_error_delta = (value_error_current - value_error_previous)
	value_error_previous = value_error_current
	derivative = value_error_delta / time_delta

	output_D = term_D * derivative
	
	output_total = output_P + output_I + output_D


func calc_PID_output(setpoint, current):
	value_setpoint = setpoint
	value_current = current
	
	return output_total
