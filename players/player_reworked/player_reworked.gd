# player_reworked.gd
# 4/3/24
# controller for the reworked character

extends ReworkedDefaultController

@export var swinging : bool = false

# get child nodes for animation
func _ready():
	# override
	print("creating reworked player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# sprite and state machine
	_sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")
	
func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# define non-movement physics
	swing_animation()
	# move and slide
	move_and_slide()

# handles swing
# animation keyframes spawn damage hitbox
func swing_animation():
	if Input.is_action_just_pressed("attack") and receive_input:
		_state_machine.start("swing1", true)
		swinging = true
	elif Input.is_action_just_pressed("heavy") and receive_input:
		_state_machine.start("swing2", true)
		swinging = true
	else:
		# update swing status
		# weird since .travel only changes current node at end of the process
		swinging = (_state_machine.get_current_node() == "swing1"  
				or _state_machine.get_current_node() == "swing2")

func kill():
	# kills the player and handles logic
	# eventually will need to rig it up to reset the level
	# for now just reset player position
	# eventually we'll also have to define every level's 
	# reset position/checkpoint position.
	
	#HARDCODED!!
	get_tree().reload_current_scene()

# handling non-physics processes
func _process(delta):
	# define extra options
	super._process(delta)

func _update_animation():
	super._update_animation()
	# override
	if swinging:
		pass
	elif not on_floor and used_jump:
		# jump
		_state_machine.travel("jump")
	elif not on_floor:
		# fall
		pass
	else:
		# set blend
		_animation_tree.set("parameters/idle-run/blend_position", direction)
		# idle-run
		_state_machine.travel("idle-run")
		
		

	



