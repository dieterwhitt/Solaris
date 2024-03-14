# player_unpowered.gd
# 3/13/24
# controller for the default unpowered character

extends DefaultController


# get tree state machine
#var state_machine = $AnimationTree.get("parameters/playback")


func _ready():
	# override
	# activate animation tree
	animation_tree = $AnimationTree
	animation_tree.active = true
	# sprite and state machine
	sprite = $Sprite2D
	state_machine = animation_tree.get("parameters/playback")
	
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
	
func _update_animation():
	# override
	if not on_floor and used_jump:
		# jump
		state_machine.travel("jump")
	elif not on_floor:
		# fall
		pass
	else:
		# set blend
		animation_tree.set("parameters/idle-run/blend_position", direction)
		# idle-run
		state_machine.travel("idle-run")
	


