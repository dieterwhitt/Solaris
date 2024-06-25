# dieter whittingham
# june 25 2024
# severed_ear_player.gd

extends ReworkedDefaultController

# the ear shows illusory walls when held. that logic will be done in the wall
# glow scene.

func _ready():
	# override
	print("creating severed ear player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# state machine
	_state_machine = _animation_tree.get("parameters/playback")
	# set name so can be detected by highlight
	name = "SeveredEarPlayer"
	
func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# move and slide
	move_and_slide()
