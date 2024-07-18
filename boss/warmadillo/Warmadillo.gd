extends CharacterBody2D

# Constants for movement
const SPEED = 60.0
var speed_mult = 4
var accel_val = 50
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback

# State variables
var phase = "build" # 0 - idle - 1 - build/spit, 2 - roll, 3 - stagger
var direction : int = 0
var is_dead = false # load from save
# boolean to keep track of rolling state
var is_rolling = 0

# counter for how many times has hit wall while rolling
var wall_counter = 0
# Reference to the player node
var player: CharacterBody2D

# ref to timer
var attack_timer: Timer

@onready var col_boxes = [$CollisionShape2D, $RollCollisionShape2D]
@onready var kill_boxes = [$Killbox, $Killbox2]

# spitting
var aggro = false
var spits_left = 40
@onready var spit_timer : Timer = $SpitTimer

const SPIT_VELO = 70
@onready var spit : PackedScene = load("res://boss/warmadillo/spit.tscn")
@onready var spit_spawn = $SpitSpawn

var rng = RandomNumberGenerator.new()

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
	remove_child(col_boxes[1])
	remove_child(kill_boxes[1])
	if phase == "build":
		direction = -1

# Called every frame, delta is the elapsed time since the previous frame.
func _physics_process(delta):
	player = get_node("/root/LevelManager").player
	
	if wall_counter == 5:
		print('lava starts rising. cue scene')
	if is_dead:
		queue_free()
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	update_flip()
	
	if phase == "build":
		# spit. when timer times out, switch to roll
		build()
	elif phase == "roll":
		# Handle collisions and state changes
		handle_collisions()
		# Update the enemy's animation based on its state
		# Handle movement direction (AI or predefined path)
		handle_movement(delta)
	elif phase == "stagger":
		pass
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
		velocity.x += delta * accel_val * direction
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
		# if boss reaches other side, then hes ready to attack again
		if is_rolling == 1:
			is_rolling = 2
			state_machine.travel("roll")
			var direction_to_player = global_position.direction_to(player.global_position)
			# Move towards the player
			velocity.x = direction_to_player.x * SPEED * speed_mult
			remove_child(col_boxes[0])
			add_child(col_boxes[1])
			remove_child(kill_boxes[0])
			add_child(kill_boxes[1])
		# if he's running, add 1 to counter
		elif is_rolling == 2:
			state_machine.travel("idle")
			
			wall_counter += 1
			is_rolling = 0
			
			await get_tree().create_timer(0.3).timeout
			remove_child(col_boxes[1])
			add_child(col_boxes[0])
			remove_child(kill_boxes[1])
			add_child(kill_boxes[0])
		
		await get_tree().create_timer(1.0).timeout
		# add conditional to check if wall_counter is = to ... for animations

func build():
	if not aggro and position.distance_to(player.position) < 150:
		aggro = true
		# start building spit phase when player in range (start spitting)
		print("starting spitting")
		spit_timer.start()
	elif spits_left == 0:
		# stop spitting
		spit_timer.paused = true
		# wait, then go to roll
		await get_tree().create_timer(5)
		phase = "roll"
		

func spit_func():
	# print("spitting")
	spits_left -= 1
	# spitting to the left.
	var proj_direction = Vector2(-1, 0)
	# add some y variance
	proj_direction.y = rng.randf_range(-0.05, 0.15)
	var proj = spit.instantiate()
	add_sibling(proj)
	# set spit projectil position and velocity
	proj.global_position = spit_spawn.global_position
	proj.velocity = SPIT_VELO * proj_direction

# Update the enemy's animation based on its state
func update_flip():
	if direction > 0:
		transform.x.x = 1
	else:
		transform.x.x = -1

# Example: Enemy death
func die():
	is_dead = true
	queue_free()  # Remove the enemy from the scene after death animation

func _on_sneeze_timer_timeout():
	# only in roll phase
	if phase != "roll":
		return
	var rng = RandomNumberGenerator.new()
	$SneezeTimer.start(rng.randf_range(4, 6))
	if is_rolling == 0:
		state_machine.travel("attack")
		# aoe code
	

func _on_roll_timer_timeout():
	# only in roll phase
	if phase != "roll":
		return
	var rng = RandomNumberGenerator.new()
	$RollTimer.start(rng.randf_range(5, 8))
	#prepare_to_roll()
	if is_rolling == 0 and get_node("/root/LevelManager").player.global_position.y > 480:
		is_rolling = 1

func _on_spit_timer_timeout():
	if phase == "build":
		spit_func()
		# spits more often as it spits more
		# 40 -> 1, 1 -> 3
		var speed_factor : float = (-float(spits_left) / 20.0) + 3.0
		print(speed_factor)
		var next = rng.randf_range(2, 3) / speed_factor
		spit_timer.start(next)
