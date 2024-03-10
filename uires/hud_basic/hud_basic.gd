extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_speed: float = 0.00
var current_range: float = 0.00

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Display/Speed.text = "SPEED: " + ("%4.1f" % [current_speed])
