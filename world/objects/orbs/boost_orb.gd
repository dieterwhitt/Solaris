# april 23 2024
# boost orb

extends Node2D

var BOOST_MULT = 1.4

# possibility: instead of scaling velocity, 
# take direction vector and scale to fixed length
var BOOST_MAGNITUDE = 300

#or.... choose the max between both options.


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# need to check for player in air on every frame
	pass


func _on_area_2d_body_entered(body):
	print("collision with boost orb")
	# dash player upon entering if not glass.
	if body.is_in_group("Player") and not body.on_floor:
		if body.velocity != Vector2.ZERO:
			var min = body.velocity.normalized() * BOOST_MAGNITUDE
			var scaled = body.velocity * BOOST_MULT
			# choose max option
			if min.length() > scaled.length():
				body.velocity = min
			else:
				body.velocity = scaled
