extends CharacterBody2D

# Constants for movement
const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback

# State variables
var direction = 0
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree = $AnimationTree
	animation_tree.active = true
	state_machine = animation_tree.get("parameters/playback")
	print("Ready function called. AnimationTree active:", animation_tree.active)

# Called every frame, delta is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_dead:
		return
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle collisions and state changes
	handle_collisions()

	# Update the enemy's animation based on its state
	update_animation()

	# Handle movement direction (AI or predefined path)
	handle_movement(delta)
	# Apply movement
	move_and_slide()

# Handle the enemy's movement logic
func handle_movement(delta):
	# Example: simple horizontal patrol
	if direction == 0:
		direction = 1
	# Move in the current direction
	velocity.x = direction * SPEED

# Handle collisions and state changes
func handle_collisions():
	if is_on_wall():
		# Change direction on wall collision
		flip()

# Update the enemy's animation based on its state
func update_animation():
	if velocity.x != 0:
		state_machine.travel("roll")
	else:
		state_machine.travel("idle")

func flip():
	direction = -direction
	transform.x.x *= -1
		
# Example: Enemy death
func die():
	is_dead = true
	queue_free()  # Remove the enemy from the scene after death animation
