# player_unpowered.gd
# 3/13/24
# controller for the default unpowered character

extends DefaultController

var swinging : bool = false

# get child nodes for animation
func _ready():
	# override
	# activate animation tree
	animation_tree = $AnimationTree
	animation_tree.active = true
	# sprite and state machine
	sprite = $Sprite2D
	state_machine = animation_tree.get("parameters/playback")
	
func _physics_process(delta):
	# freeze input on swing
	recieve_input = not swinging
		
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
		
	# handle swing
	swing_animation()
		
func swing_animation():
	if Input.is_action_just_pressed("attack"):
		state_machine.travel("swing1")
	elif Input.is_action_just_pressed("heavy"):
		state_machine.travel("swing2")
	
	# update swing status
	swinging = state_machine.get_current_node() == "swing2" 
	


