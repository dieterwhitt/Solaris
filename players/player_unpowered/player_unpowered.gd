# player_unpowered.gd
# 3/13/24
# controller for the default unpowered character

extends DefaultController

@export var swinging : bool = false
var initial_position = Vector2(100, 100)

# get child nodes for animation
func _ready():
	# override
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# sprite and state machine
	_sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")
	initial_position = position
	
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
		_state_machine.travel("swing1")
		swinging = true
	elif Input.is_action_just_pressed("heavy") and receive_input:
		_state_machine.travel("swing2")
		swinging = true
	else:
		# update swing status
		# weird since .travel only changes current node at end of the process
		swinging = (_state_machine.get_current_node() == "swing1"  
				or _state_machine.get_current_node() == "swing2")

# handling non-physics processes
func _process(delta):
	# define extra options
	
	#if character is off screen, just set position to initial position.
	if abs(position.y) > get_viewport_rect().size.y:
		reset_position()
	super._process(delta)

func reset_position():
	# Reset the character's position to the initial position
	position = initial_position
	
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
		
		

	


