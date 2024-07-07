extends CharacterBody2D

# Constants for movement
const SPEED = 70.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback

# State variables
var direction = 0
var is_dead = false
# boolean to keep track of rolling state
var is_rolling = 0

# counter for how many times has hit wall while rolling
var wall_counter = 0
# Reference to the player node
var player: CharacterBody2D

# ref to timer
var attack_timer: Timer



# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree = $AnimationTree
	animation_tree.active = true
	state_machine = animation_tree.get("parameters/playback")
	print("Ready function called. AnimationTree active:", animation_tree.active)
	# Find and start the attack timer
	attack_timer = $SneezeTimer
	attack_timer.start()
	state_machine.travel("idle")

# Called every frame, delta is the elapsed time since the previous frame.
func _physics_process(delta):
	player = get_node("/root/LevelManager").player
	
	if wall_counter == 5:
		print('lava starts rising. cue scene')
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
	if is_rolling == 0:
		velocity.x = direction * SPEED
		
	if is_rolling == 1:
		# walk away first, then roll
		var direction_to_player = global_position.direction_to(player.global_position)
		velocity.x =  - direction_to_player.x * SPEED
		
	if is_rolling == 2:
		velocity.x = velocity.x
	# change this to a conditional to chase after player only after a certain time
	if velocity.x < 0:
		direction = -1
	else:
		direction = 1
	
# Handle collisions and state changes
func handle_collisions():
	if is_on_wall():
		direction = -direction
		# Change direction on wall collision
		#flip()
		# if boss reaches other side, then hes ready to attack again
		if is_rolling == 1:
			is_rolling = 2
			state_machine.travel("roll")
			var direction_to_player = global_position.direction_to(player.global_position)
			# Move towards the player
			velocity.x = direction_to_player.x * SPEED * 2
		# if he's running, add 1 to counter
		elif is_rolling == 2:
			state_machine.travel("idle")
			wall_counter += 1
			is_rolling = 0
		
		await get_tree().create_timer(1.0).timeout
		# add conditional to check if wall_counter is = to ... for animations

# Update the enemy's animation based on its state
func update_animation():
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
		
	#state_machine.travel("idle")

func flip():
	direction = -direction
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
		
	
# Example: Enemy death
func die():
	is_dead = true
	queue_free()  # Remove the enemy from the scene after death animation

func _on_sneeze_timer_timeout():
	state_machine.travel("attack")

func _on_roll_timer_timeout():
	#prepare_to_roll()
	if is_rolling == 0 and get_node("/root/LevelManager").player.global_position.y > 480:
		is_rolling = 1
	
