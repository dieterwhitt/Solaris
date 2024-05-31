# april 23 2024
# boost orb

extends Orb

const BOOST_MULT = 1.4

# possibility: instead of scaling velocity, 
# take direction vector and scale to fixed length
const BOOST_MAGNITUDE = 300
# or.... choose the max between both options.

# also need to increase momentum temporarily.

# Called when the node enters the scene tree for the first time.
func _ready():
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)

func _orb_function(body):
	print("collision with boost orb")
	if body.is_in_group("Player") and not body.on_floor:
		if body.velocity != Vector2.ZERO:
			var min = body.velocity.normalized() * BOOST_MAGNITUDE
			var scaled = body.velocity * BOOST_MULT
			# choose max option
			if min.length() > scaled.length():
				body.velocity = min
			else:
				body.velocity = scaled
