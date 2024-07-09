# player_reworked.gd
# 4/3/24
# controller for the reworked character

# DEFAULT CHARACTER (NO POWERUPS)

extends ReworkedDefaultController

# get child nodes for animation
func _ready():
	super()
	print("creating reworked player")
	
func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# move and slide
	move_and_slide()




