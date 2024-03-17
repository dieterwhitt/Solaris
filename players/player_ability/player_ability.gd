# player_ability.gd
# 3/14/24

# script for the player ability

extends DefaultController

var input_queue = []
var direction_2d : Vector2 = Vector2.ZERO

# *** currently no cooldown for teleports yet ***
# decrement buffer during teleportation process
const teleport_buffer : int = 1
var buffer_timer : int = teleport_buffer
# boolean for if in the teleport stage/buffering (see doc)
var teleporting : bool = false
# boolean for if in the holding stage (frame 4+ in doc)
var holding_teleport : bool = false
# indicates that the current frame will teleport
var teleport_frame : bool = false
# vector to store the teleport transformation after checking destination
var transformation : Vector2 = Vector2.ZERO

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var area_hitbox : Area2D = Area2D.new()

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
	if teleport_frame:
		execute_teleport()
		teleport_frame = false
	# reset teleport status
	# want to maintain original jump, but fall at slowed speed
	jump_adjust(20) # 20x slower
	# get 2d direction
	update_direction_2d()
	# apply default controller
	super._physics_process(delta)
	# define additional capabilities
	if not teleport_frame:
		# queue teleport
		queue_teleport()
		move_and_slide()

	
	

# adjusts move data to apply regular gravity when jumping
# releasing input in midair will slow gravity, allowing for teleports
func jump_adjust(factor):
	# reset before calculating
	slow_physics(1.0)
	if recieve_input and (velocity.y <= 0 or direction != 0):
		# not moving or moving up (before apex), or input in mid air:
		# regular gravity (remove magic number : factor^2, in this case 10)
		MoveData.GRAVITY = DefaultDataReference.GRAVITY
		MoveData.TERMINAL_Y = DefaultDataReference.TERMINAL_Y
	else:
		# slow down gravity and terminal
		MoveData.GRAVITY = DefaultDataReference.GRAVITY / (factor ** 2)
		MoveData.TERMINAL_Y = DefaultDataReference.TERMINAL_Y / factor
		
# updating 2d direction
func update_direction_2d():
	# entries snapped to -1, 0, 1
	direction_2d = Input.get_vector("left", "right", "up", "down").snapped(Vector2.ONE)

# function for clone teleport
# will update this wall of text - for now look at google doc for documentation
# idea: teleport on both input and action button (probably k)
# that way there are 3 ways to teleport: hold k then input, hold input then k, or both at once
# another idea: add a 1-2 frame delay/buffer so that it's easier to hit both at once
# i.e go 1-2 frames into animation (24fps) BEFORE moving player
# if k is pressed, use those frames as a buffer for a direction
# so if the direction changes during those 2 buffer frames, use that instead
# in fact any input recieved in those frames will just be added to the queued direction
# another thing would be to not count the frame where k is pressed for direction
# since it's very hard to press a key for only 1 frame - chances are if a key was only
# on the frame where they pressed k and not in the next 2 buffer frames, they meant to let go
# should probably keep buffer period <= 3 frames (60fps) to stay responsive
# it's a trade off between responsiveness and making input easier for the player
func queue_teleport():
	if Input.is_action_just_pressed("teleport") and not teleporting:
		print("frame 1")
		# frame 1
		# stop physics input
		recieve_input = false
		teleporting = true
		# add input vector to queue
		input_queue.append(direction_2d)
		
		# implement - set teleportation animation frame (teleport indicator)
		
	elif teleporting and not holding_teleport and buffer_timer != 0:
		print("frame 2")
		# buffer frames
		input_queue.append(direction_2d)
		# decrement buffer
		buffer_timer -= 1
	elif teleporting and not holding_teleport and buffer_timer == 0:
		print("frame 3")
		# teleportation frame
		# gather input
		input_queue.append(direction_2d)
		# check for non-zero direction
		var tp_dir = vector_or()
		print(tp_dir)
		if tp_dir != Vector2.ZERO:
			start_teleport(tp_dir)
		
		# after successful or unsuccessful teleport continue to holding phase
		holding_teleport = true
		# reset
		queue_reset()
	elif holding_teleport and Input.is_action_pressed("teleport"):
		print("frame 4+")
		# holding frame (4+)
		# wait for any input, then teleport on next frame
		# reset queue
		if not teleporting:
			queue_reset()
		# stop physics
		recieve_input = false
		# check if any wasd was JUST pressed. just pressed since we don't want them
		# to be able to hold teleport and wasd and spam. see doc
		var instant_direction : Vector2 = Vector2.ZERO
		var instant_recieved : bool = false
		if Input.is_action_just_pressed("left"):
			instant_direction.x -= 1
			instant_recieved = true
			# will teleport on next frame
		if Input.is_action_just_pressed("right"):
			instant_direction.x += 1
			instant_recieved = true
		if Input.is_action_just_pressed("up"):
			instant_direction.y -= 1
			instant_recieved = true
		if Input.is_action_just_pressed("down"):
			instant_direction.y += 1
			instant_recieved = true
		# add to queue
		input_queue.append(instant_direction)
		# lastly: if teleporting, then teleport (no queue)
		# otherwise, set teleporting
		if teleporting:
			var tp_dir = vector_or()
			if tp_dir != Vector2.ZERO:
				start_teleport(tp_dir)
			# reset queue, but STAY in holding
			queue_reset()
			# also keep not receiving input incase staying in 4+
			recieve_input = false
		elif instant_recieved:
			teleporting = true
			# will teleport next frame
			
	else:
		queue_reset()
		# prevent going back to holding frame
		holding_teleport = false
	
# returns a vector based on the queue
# each non-zero direction in the array is added
# ex. f([0,1], [1,1]) -> [1,1]
func vector_or() -> Vector2:
	var left : int = 0
	var right : int = 0
	var up : int = 0
	var down : int = 0
	print(input_queue)
	
	for input in input_queue:
		# x axis
		if input.x == -1:
			left = 1
		elif input.x == 1:
			right = 1
		# y axis
		if input.y == -1:
			up = 1
		elif input.y == 1:
			down = 1
	
	# now use variables to construct new vector
	return Vector2((right - left), (down - up))
	
func queue_reset():
	# not teleporting - reset everything except holding teleport
	teleporting = false
	recieve_input = true
	buffer_timer = teleport_buffer
	input_queue = []

# checks teleport destination then prepares for teleport execution on next frame
func start_teleport(tp_dir):
	print("checking teleport")
	# 1. duplicate player hitbox and attempt to send it to destination
	# 2. if no collision at destination, delete the duplicated hitbox and set player
	# 		location to that position
	# 3. if there is a collision at destination, move_and_collide the player along the direction vector
	# diagonal: 5 tiles (40px) x, 5 tiles y
	# axis: 7 tiles (56 px)
	var scale : int = 40
	if tp_dir.x == 0 or tp_dir.y == 0:
		# not diagonal
		scale = 56
	
	transformation = scale * tp_dir
	print(transformation)
	# checking destination using area 2d
	
	# var area_hitbox : Area2D = Area2D.new()
	var dupe_collision : CollisionShape2D = collision.duplicate()
	# add child
	area_hitbox.add_child(dupe_collision)
	# then bring it into the current tree (necessary?) and set mask
	# set no layer, set mask to 1
	add_sibling(area_hitbox)
	area_hitbox.set_collision_mask_value(1, true)
	area_hitbox.set_collision_layer_value(1, false)
	
	# 
	
	# MUST USE SIGNALS - overlaps are only detected in each physics process
	# calls _on_body_entered when a body enters
	# area_hitbox.connect("body_entered", _on_body_entered)
	# move it to destination
	print("moving area hitbox")
	area_hitbox.global_position = \
			Vector2(self.global_position + transformation)
	
	# set teleport on next frame
	teleport_frame = true
		
func execute_teleport():
	# finally... move the player
	var can_teleport = not area_hitbox.has_overlapping_bodies()
	print(can_teleport)
	print(area_hitbox.get_children())
	# finally we can teleport
	if can_teleport:
		print("teleporting")
		# move player
		self.global_position = area_hitbox.global_position
	else:
		# move and collide along transformation
		print("can't teleport there")
		move_and_collide(transformation)
	# delete areas associated collision shape
	for node in area_hitbox.get_children():
			node.queue_free()
		

		
'''
# signal callback
func _on_body_entered(body):
	# modify global variable
	can_teleport = false
		
'''





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
