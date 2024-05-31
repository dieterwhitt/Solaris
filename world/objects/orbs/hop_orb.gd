# hop orb
# applies a small jump (slightly larger than double jump)

extends Orb

const JUMP_VELOCITY = -135


func _ready():
	super()

func _physics_process(delta):
	super(delta)

func _orb_function(body):
	if body.is_in_group("Player"):
		body.velocity.y = JUMP_VELOCITY
