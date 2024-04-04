# 4/2/2024
# dash orb

extends Node2D

# dash velocity
var DASH_VELOCITY = 300.0 #300
# number of frames into dash before applying friction
var DASH_FRAMES : int = 6 #6
# dash deceleration
var DASH_FRICTION : float = 2750.0 #2750
var FRICTION_FRAMES : int = 3 #3

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
		# calculate direction vector
		var direction : Vector2 = Vector2.ZERO
		if int(round(rotation_degrees)) % 45 == 0:
			# direction vector based on angle
			direction = Vector2(sin(rotation), -cos(rotation))
			# check diagonal: reduce friction (divide by root 2)
			var mult = 1
			if int(round(rotation_degrees)) % 90 != 0:
				mult = 1/sqrt(2)
			body.dash(direction, DASH_FRAMES, DASH_VELOCITY, 
					FRICTION_FRAMES, DASH_FRICTION * mult)
		else:
			print("invalid jump orb rotation")

