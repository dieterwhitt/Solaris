# player_ability.gd
# 3/14/24

# script for the player ability

extends DefaultController

func _ready():
	# update movedata
	MoveData = load("res://players/player_ability/player_ability_data.gd").new()
	DefaultDataReference = MoveData.duplicate()
	# update sprite, tree, statemachine
	_animation_tree = $AnimationTree2
	_animation_tree.active = true
	_sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")
	print("created clone")
	
func _physics_process(delta):
	# want to maintain original jump, but fall at slowed speed
	jump_adjust()
	# apply default controller
	super._physics_process(delta)
	# define additional capabilities
	teleport()
	move_and_slide()

# adjusts move data to apply regular gravity when jumping
# releasing input in midair will slow gravity, allowing for teleports
func jump_adjust():
	# reset before calculating
	slow_physics(1.0)
	if velocity.y <= 0 or direction != 0:
		# not moving or moving up (before apex), or input in mid air:
		# regular gravity (remove magic number : factor^2, in this case 10)
		MoveData.GRAVITY = DefaultDataReference.GRAVITY * 100
		MoveData.TERMINAL_Y = DefaultDataReference.TERMINAL_Y * 10

# function for clone teleport
# idea: teleport on both input and action button (probably k)
# that way there are 3 ways to teleport: hold k then input, hold input then k, or both at once
# another idea: add a 1-2 frame delay/buffer so that it's easier to hit both at once
# i.e go 1-2 frames into animation (24fps) BEFORE moving player
# if k is pressed with no input, use those frames as a buffer for a direction
# should probably keep buffer period <= 5 frames (60fps) to stay responsive
func teleport():
	pass
		

func _process(delta):
	super._process(delta)

func _update_animation():
	# override
	if not on_floor and used_jump:
		# jump
		_state_machine.travel("jump")
	elif not on_floor:
		# fall
		pass
	else:
		# set blend
		_animation_tree.set("parameters/run-idle/blend_position", direction)
		# idle-run
		_state_machine.travel("run-idle")
