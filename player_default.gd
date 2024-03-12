extends CharacterBody2D
# prototype default character controller
# player collision layer on layer 2 to avoid collisions with clone (layer 3)

@export var MoveData : Resource = preload("res://default_player_data.gd").new()
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


# runs upon character instantiation
func _ready():
	pass

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
	
	move_and_slide()

func apply_gravity(delta):
	# apply gravity if the player is in the air and 
	# below terminal velocity
	# apply the down gravity multiplier if can jump is false and are on the way down
	# i.e the user already jumped and is now falling
	var down_multiplier = 1
	if used_jump and velocity.y > 0:
		down_multiplier = MoveData.DOWN_MULTIPLIER
	
	if not on_floor and velocity.y < MoveData.TERMINAL_Y:
		velocity.y += MoveData.GRAVITY * down_multiplier * delta

# handles logic for when to accelerate/decelerate player
func apply_x_accel(delta):
	# -1, 0, 1
	direction = Input.get_axis("left", "right")
	# before adjusting velocity determine air accleration multiplier
	
	# logic: 
	# above input terminal: apply friction, ignore input
	# below or equal input terminal : apply player input, cap at input terminal
	# apply friction if no input
	# cap at total terminal
	
	if abs(velocity.x) > MoveData.INPUT_TERMINAL or direction == 0:
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
	# still on the floor in coyote time
	# pressed space <-> buffer > 0
	# on floor <-> coyote > 0
	if (not used_jump and (Input.is_action_just_pressed("jump") or current_jump_buffer > 0)
			 and (on_floor or current_coyote > 0)):
		velocity.y = MoveData.JUMP_VELOCITY
		used_jump = true

# runs every frame
# for updating animations
func _process(delta):
	pass
