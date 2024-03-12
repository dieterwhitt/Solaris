extends CharacterBody2D
# prototype default character controller
# player collision layer on layer 2 to avoid collisions with clone (layer 3)

@export var MoveData = preload('res://default_player_data.gd').new()

# after leaving the ground (not from jumping), increase the coyote value
# then decrease by 1 for each subsequent frame until 0
# if the player is in the air with coyote > 0, 
# the player can jump even though they are not on the ground
var current_coyote : int = 0
# when jumping in air, increase jump buffer
# then decrease it by 1 for each subsequent frame until 0
# then if the player is on the ground with the timer > 0,
# jump even if the jump key was not pressed in that frame
var current_jump_buffer : int = 0
var on_floor : bool = false


# runs upon character instantiation
func _ready():
	pass

# runs every physics frame
# for updating physics
func _physics_process(delta):
	# pre calculate on floor
	on_floor = is_on_floor()

func apply_gravity(delta, on_floor):
	# apply gravity if the player is in the air and 
	# below terminal velocity
	if not is_on_floor() and velocity.y < MoveData.TERMINAL_Y:
		velocity.y += MoveData.GRAVITY

func apply_input_accel(delta):
	pass
	
func apply_jump():
	pass
	
func apply_friction(delta):
	pass


# runs every frame
# for updating animations
func _process(delta):
	pass
