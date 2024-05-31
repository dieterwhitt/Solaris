# apr 12 2024
# teleport orbs

extends Orb

@onready var exit = $Exit

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
		

func _physics_process(delta):
	super(delta)
		

func _orb_function(body):
	body.global_position = exit.global_position
