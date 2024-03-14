# player_unpowered.gd
# 3/13/24
# controller for the default unpowered character

extends DefaultController

@onready var Sprite = $Sprite2D

func _init():
	super._init()

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# define non-movement physics
	
	# move and slide
	move_and_slide()

# handling non-physics processes
func _process(delta):
	# define extra animatiion options
	super._process(delta)
	
	


