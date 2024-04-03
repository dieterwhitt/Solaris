# 4/2/2024
# dash orb

extends Node2D

var DOUBLE_JUMP_VELOCITY = -150.0
# dash velocity
var DASH_VELOCITY = 400.0
# number of frames into dash before applying friction
var DASH_FRAMES : int = 10
# dash deceleration
var DASH_FRICTION = 800.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	print("collision with dash orb")
	# dash player
	if body.get_name() == "PlayerReworked":
		body.dash(Vector2(0, -1), 8, 250, 4, 2750)
			
		
