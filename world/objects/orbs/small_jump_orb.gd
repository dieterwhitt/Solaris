# applies a small jump

extends Orb

const SMALL_JUMP_VELOCITY = -185 


func _ready():
	super()

func _orb_function(body):
	if body.is_in_group("Player"):
		body.velocity.y = SMALL_JUMP_VELOCITY
