# default_controller.gd 
# 3/13/24
# abstract controller class to be inherited by unique character controllers
# defines horizontal movement and jump
# loads data from file which defines movement

extends CharacterBody2D
# prototype default character controller
# abstract class to handle physics of controllable characters only
# capabilities: left, right, jump
# players with extended capabilities must extend (inherit) this script and define their
# own unique capabilities locally

class_name DefaultController

# after leaving the ground (not from jumping), increase the coyote value
# then decrease by 1 for each subsequent frame until 0
# if the player is in the air with coyote > 0, 
# the player can jump even though they are not on the ground
var current_coyote : int = 0
# variable for if jump is still valid
var used_jump : bool = false
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
var recieve_input : bool = true

# dependent on subclass: must define
@onready var MoveData : Resource = preload("res://players/common_physics_controller/default_controller_data.gd")
var sprite : Sprite2D
var animation_tree : AnimationTree
var state_machine : AnimationNodeStateMachinePlayback

func _ready():
	# subclasses define children HERE
	# NOT in _init since children aren't loaded yet!!!
	pass

# set receiving input ex. ability usage
func set_input(val : bool):
	recieve_input = val

# runs every physics frame
# for updating physics
func _physics_process(delta):
	# in general: multiply by delta whenever velocity changes, except jump
	# velocity means 'how much to move the character next frame'
	# pre calculate on floor
	on_floor = is_on_floor()
	apply_gravity(delta)
	apply_x_accel(delta)
	apply_jump()
	
	# subclasses: define unique movement
	# run move and slide (in subclass)
	# move_and_slide()

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
	
	# cap at terminal
	if velocity.y < -1 * MoveData.TERMINAL_Y:
		velocity.y = -1 * MoveData.TERMINAL_Y
	elif velocity.y > MoveData.TERMINAL_Y:
		velocity.y = MoveData.TERMINAL_Y

# handles logic for when to accelerate/decelerate player
func apply_x_accel(delta):
	# -1, 0, 1
	if recieve_input:
		direction = Input.get_axis("left", "right")
	# before adjusting velocity determine air accleration multiplier
	
	# logic: 
	# above input terminal: apply friction, ignore input
	# below or equal input terminal : apply player input, cap at input terminal
	# apply friction if no input OR input in opposite direction (product is negative)
	# cap at total terminal
	if (not recieve_input or abs(velocity.x) > MoveData.INPUT_TERMINAL 
			or direction == 0 or (direction * velocity.x < 0)):
		apply_friction(delta)
	else:
		apply_input(delta)
	# cap at total x terminal
	if velocity.x < -1 * MoveData.TERMINAL_X:
		velocity.x = -1 * MoveData.TERMINAL_X
	elif velocity.x > MoveData.TERMINAL_X:
		velocity.x = MoveData.TERMINAL_X
		
# moves the player in the current direction
func apply_input(delta):
	var multiplier = 1
	if not on_floor:
		multiplier = MoveData.AIR_ACCEL_MULTIPLIER
	# adjust velocity and cap at input velocity
	velocity.x += direction * MoveData.ACCELERATION * multiplier * delta
	# cap at input terminal
	if velocity.x < -1 * MoveData.INPUT_TERMINAL:
		velocity.x = -1 * MoveData.INPUT_TERMINAL
	elif velocity.x > MoveData.INPUT_TERMINAL:
		velocity.x = MoveData.INPUT_TERMINAL

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
	if on_floor:
		used_jump = false

func apply_jump():
	update_coyote()
	update_buffer()
	update_jump_elig()
	# jump if the user can jump and the user just pressed space and is 
	# still on the floor or in coyote time
	# pressed space <-> buffer > 0
	# on floor <-> coyote > 0
	if ((not used_jump and recieve_input) 
			and (Input.is_action_just_pressed("jump") or current_jump_buffer > 0)
			 and (on_floor or current_coyote > 0)):
		velocity.y = MoveData.JUMP_VELOCITY
		used_jump = true

func _process(delta):
	# handling animations
	# common animations: run/idle, jump
	_update_animation()
	# common flip function
	flip()

func flip():
	if sprite != null:
		if direction > 0:
			sprite.flip_h = false
		elif direction < 0:
			sprite.flip_h = true
		
func _update_animation():
	# subclass must override
	# changes animations - subclass must use AnimationNodeStateMachine
	pass