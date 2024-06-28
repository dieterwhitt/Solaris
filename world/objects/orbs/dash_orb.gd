# 4/2/2024
# dash orb

extends Orb

# export rotation, rotate start in _ready

# dash velocity
const DASH_VELOCITY = 300 # 275 250 #300
# number of frames into dash before applying friction
const DASH_FRAMES : int = 6 #6
# dash deceleration
const DASH_FRICTION : float = 950 # 1600 100 #2750
const FRICTION_FRAMES : int = 5 # 4 #3

func _ready():
	super()

func _physics_process(delta):
	super(delta)

func _orb_function(body):
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
