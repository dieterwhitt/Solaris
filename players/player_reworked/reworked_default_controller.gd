# reworked_default_controller.gd 
# 4/2/24
# reworked abstract controller class to be inherited by unique character controllers
# defines horizontal movement and dash, double jump
# loads data from file which defines movement

class_name ReworkedDefaultController

extends CharacterBody2D

# after leaving the ground (not from jumping), increase the coyote value
# then decrease by 1 for each subsequent frame until 0
# if the player is in the air with coyote > 0, 
# the player can jump even though they are not on the ground
var current_coyote : int = 0
# variable for if jump is still valid
var used_jump : bool = true
# new
var used_double_jump = true
var dashing = false
var dash_stopping = false
var dash_timer : int = 0
var dash_friction_timer : int = 0
var dash_friction : float = 0
# when jumping in air, increase jump buffer
# then decrease it by 1 for each subsequent frame until 0
# then if the player is on the ground with the timer > 0,
# jump even if the jump key was not pressed in that frame
var current_jump_buffer : int = 0
var on_floor : bool = false
# direction: -1, 0, 1
# represents the CURRENT input direction (left, none, right)
var direction : int = 0
# to disable input (physics still applies), ex. after ability usage
@export var receive_input : bool = true

# variable for print debug statements
@export var debug = false
# dependent on subclass: 
# underscore indicates must define in subclass
var _sprite : Sprite2D
var _animation_tree : AnimationTree
var _state_machine : AnimationNodeStateMachinePlayback

# using move data: one to keep a reference to the default, one active
# that way we can change active data while still having the default available
@onready var MoveData : Resource = \
		preload("res://players/player_reworked/reworked_default_controller_data.gd").new()
@onready var DefaultDataReference : Resource = MoveData.duplicate()

func _ready():
	# subclasses define children HERE
	# NOT in _init since children aren't loaded yet!!!
	pass

# runs every physics frame
# for updating physics
func _physics_process(delta):
	# in general: multiply by delta whenever velocity changes, except jump
	# velocity means 'how much to move the character next frame'
	# pre calculate on floor
	on_floor = is_on_floor()
	update_direction()
	update_dash(delta)
	if not dashing:
		apply_gravity(delta)
		apply_x_accel(delta)
	apply_jump()
	
	# handling animations
	# common animations: run/idle, jump
	_update_animation()
	
	_print_debug()
	# subclasses: define unique movement
	# run move and slide (in subclass)
	# move_and_slide()
	

func update_direction():
	if receive_input:
		# -1, 0, 1
		direction = Input.get_axis("left", "right")

func apply_gravity(delta):
	# apply gravity if the player is in the air and 
	# below terminal velocity
	# apply the down gravity multiplier if used jump and are on the way down
	# i.e the user already jumped and is now falling
	var down_multiplier = 1
	if used_jump and velocity.y > 0:
		down_multiplier = MoveData.DOWN_MULTIPLIER
	
	# apply gravity
	if not on_floor and velocity.y < MoveData.TERMINAL_Y:
		velocity.y += MoveData.GRAVITY * down_multiplier * delta
	
	# cap at terminal (falling speed only!)
	velocity.y = min(velocity.y, MoveData.TERMINAL_Y)

# handles logic for when to accelerate/decelerate player
func apply_x_accel(delta):	
	# logic: 
	# above input terminal: apply friction, ignore input
	# below or equal input terminal : apply player input, cap at input terminal
	# apply friction if no input OR input in opposite direction (product is negative)
	# cap at total terminal
	if (not receive_input or abs(velocity.x) > MoveData.INPUT_TERMINAL 
			or direction == 0 or (direction * velocity.x < 0)):
		apply_friction(delta)
	else:
		apply_input(delta)
	# cap at total x terminal
		velocity.x = clamp(velocity.x, -1 * MoveData.TERMINAL_X, MoveData.TERMINAL_X)
		
# moves the player in the current direction
func apply_input(delta):
	var multiplier = 1
	if not on_floor:
		multiplier = MoveData.AIR_ACCEL_MULTIPLIER
	# adjust velocity and cap at input velocity
	velocity.x += direction * MoveData.ACCELERATION * multiplier * delta
	# cap at input terminal
	velocity.x = clamp(velocity.x, -1 * MoveData.INPUT_TERMINAL, MoveData.INPUT_TERMINAL)

func apply_friction(delta):
	var multiplier = 1
	if not on_floor:
		multiplier = MoveData.AIR_DECEL_MULTIPLIER
	# decelerate
	velocity.x = move_toward(velocity.x, 0, MoveData.DECELERATION * multiplier * delta)

func update_coyote():
	# set timer to the coyote time when on the ground
	if on_floor:
		current_coyote = MoveData.COYOTE_TIME
	elif current_coyote > 0:
		# decrease the coyote timer for each frame off the ground
		current_coyote -= 1

func update_buffer():
	# queue buffer
	if Input.is_action_just_pressed("jump") and not on_floor:
		current_jump_buffer = MoveData.JUMP_BUFFER
	elif current_jump_buffer > 0:
		current_jump_buffer -= 1
	
		
func update_jump_elig():
	# replenish jump when on the floor
	if on_floor and current_jump_buffer == 0:
		used_jump = false
		used_double_jump = false

func apply_jump():
	update_coyote()
	update_buffer()
	update_jump_elig()
	# jump if the user can jump and the user just pressed space and is 
	# still on the floor or in coyote time
	# pressed space <-> buffer > 0
	# on floor <-> coyote > 0
	if ((not used_jump and receive_input) 
			and (Input.is_action_just_pressed("jump") or current_jump_buffer > 0)
			 and (on_floor or current_coyote > 0)):
		velocity.y = MoveData.JUMP_VELOCITY
		used_jump = true
		# cancel dash
		dashing = false
		dash_stopping = false
	elif not used_double_jump and receive_input and Input.is_action_just_pressed("jump"):
		# double jump
		# future consideration: short ray scan to ground
		# determines whether to buffer or double jump
		velocity.y = MoveData.DOUBLE_JUMP_VELOCITY
		used_double_jump = true
		# cancel dash
		dashing = false
		dash_stopping = false

func dash(direction : Vector2, dash_frames : int, dash_velocity : 
			float, friction_frames : int, friction_decel : float):
	dashing = true
	dash_stopping = false
	# give back double jump
	used_double_jump = false
	# set timer
	dash_timer = dash_frames
	# applies velocity using the direction vector
	velocity = dash_velocity * direction.normalized()
	dash_friction = friction_decel
	dash_friction_timer = friction_frames
	
func update_dash(delta):
	if dashing and dash_timer > 0:
		# preserve velocity
		dash_timer -= 1
	elif dashing and dash_timer == 0:
		# just hit 0: switch to stopping (friction)
		dashing = false
		dash_stopping = true
	# applying friction
	if dash_stopping and dash_friction_timer > 0:
		# apply friction and decrease timer
		velocity.x = move_toward(velocity.x, 0, dash_friction * delta)
		velocity.y = move_toward(velocity.y, 0, dash_friction * delta)
		dash_friction_timer -= 1
	elif dash_stopping and dash_friction_timer == 0:
		# apply regular physics again
		dash_stopping = false
	

# debug function which prints data on the character
# subclasses may override to print additional data
func _print_debug():
	if debug:
		print("-------frame-------")
		print("address: %s" % self)
		print("velocity: %v" % velocity)
		print("direction: %d" % direction)
		print("recieve input: %s" % receive_input)
		

func _process(delta):
	pass

func flip():
	if _sprite != null:
		if direction > 0:
			_sprite.flip_h = false
		elif direction < 0:
			_sprite.flip_h = true
		
func _update_animation():
	# subclass must override
	# changes animations - subclass must use AnimationNodeStateMachine
	flip()
