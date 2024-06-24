# reworked_default_controller.gd 
# 4/2/24
# reworked abstract controller class to be inherited by unique character controllers
# defines horizontal movement and dash, double jump
# loads data from file which defines movement

'''
PLEASE READ!!!!
reworked_default_controller.gd controls the base character
it is an abstract class that is intended to be inherited by different
player powerup scenes.

It loads the player movement data which controls things like 
acceleration, air control, jump height, and more.

Be sure to document and voice any changes to the default controller data from
now on, as they will impact all future characters

You are free to modify the controller data of INDIVIDUAL characters

This controller currently supports movement, gravity, dashes,
jumps, and double jumps

This file is probably the most complicated so please dm me if you have
any questions. I tried my best to document what I did but its still
a bit complex.

- dieter whittingham
'''


class_name ReworkedDefaultController

# need to add parry and then should be done

extends CharacterBody2D

# after leaving the ground (not from jumping), increase the coyote value
# then decrease by 1 for each subsequent frame until 0
# if the player is in the air with coyote > 0, 
# the player can jump even though they are not on the ground
var current_coyote : int = 0
# variable for if jump is still valid
var used_jump : bool = true
# new - dashing
var used_double_jump = true
var dashing = false
var dash_stopping = false
var dash_timer : int = 0
var dash_friction_timer : int = 0
var dash_friction : float = 0
var apply_down_gravity = true
# new - dropping
var drop_timer : int = 0
# value for drop timer
const drop_delay: int = 3
# when jumping in air, increase jump buffer
# then decrease it by 1 for each subsequent frame until 0
# then if the player is on the ground with the timer > 0,
# jump even if the jump key was not pressed in that frame
var current_jump_buffer : int = 0
var on_floor : bool = false
# direction: -1, 0, 1
# represents the CURRENT input direction (left, none, right)
var direction : int = 0
# new - parrying
#var parrying = false
# for animation: to determine when to start jump animation
var just_jumped = false
#var dying = false # when playing death animation
# to disable input (physics still applies), ex. after ability usage
@export var receive_input : bool = true
# variable for print debug statements
@export var debug = false
# dependent on subclass: 
# underscore indicates must define in subclass
# var _sprite : Sprite2D # may not need anymore due to new flip
var _animation_tree : AnimationTree
var _state_machine : AnimationNodeStateMachinePlayback

# need to give the player an area as well for aoe detection (ex. curse)
# need to add temporary effects (temporary movedata multipliers)


# using move data resource. must be added in inspector or will crash
@export_file var MoveDataResourceFile
@onready var MoveData : MoveDataResource = load(MoveDataResourceFile)

# to be added: temporary movedata multipliers
# inner class definition for multiplier object
class Multiplier:
	var movedata : MoveDataResource
	var attribute : String # accessing movedata resource fields using bracket notation
	var value : float
	var timer : int
	# constructor
	func _init(movedata, attribute, value, timer):
		self.movedata = movedata
		self.attribute = attribute
		self.value = value
		self.timer = timer
		
	# tick
	func tick():
		self.timer -= 1
		if self.timer == 0:
			self.timeout()
			
	# timer runs out: undo multiplier and delete self
	func timeout():
		print("active multiplier timed out")
		self.movedata[attribute] /= self.value
		# self.free() freeing causing issues due to freeing movedata reference
	
	# applies multiplier
	func apply():
		print("applying %sx multiplier on %s for %s frames" % [value, attribute, timer])
		self.movedata[attribute] *= self.value
		
# array of multipliers (active multipliers)
var movedata_multipliers : Array = []

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
	update_multipliers()
	
	update_dash(delta)
	if not dashing:
		apply_gravity(delta)
		apply_x_accel(delta)
		
	apply_jump()
	check_drop()
	
	# handling animations
	_update_animation()
	
	_print_debug()
	# subclasses: define unique movement
	# run move and slide (in subclass)
	# move_and_slide()

func update_direction():
	if receive_input:
		# -1, 0, 1
		direction = Input.get_axis("left", "right")

# updating movedata multipliers
func update_multipliers():
	# tick all multipliers
	for multiplier in movedata_multipliers:
		multiplier.tick()
	# filter all timed out multipliers (timer = 0)
	movedata_multipliers = movedata_multipliers.filter(func(x): return x.timer > 0)

# creates a new multiplier and adds it to the array of multipliers
func add_multiplier(attribute : String, value : float, timer : int):
	print("creating new multiplier with timer %s" % timer)
	var new_multiplier = Multiplier.new(MoveData, attribute, value, timer)
	# apply it
	new_multiplier.apply()
	movedata_multipliers.append(new_multiplier)

func apply_gravity(delta):
	# apply gravity if the player is in the air and 
	# below terminal velocity
	# apply the down gravity multiplier if used jump and are on the way down
	# i.e the user already jumped and is now falling
	var down_multiplier = 1
	if used_jump and velocity.y > 0 and apply_down_gravity:
		down_multiplier = MoveData.DOWN_MULTIPLIER
	
	# apply gravity
	if not on_floor and velocity.y < MoveData.TERMINAL_Y:
		velocity.y += MoveData.GRAVITY * down_multiplier * delta
	
	# cap at terminal (falling speed only!)
	# do not cap if dash_stopping
	if not dash_stopping:
		velocity.y = min(velocity.y, MoveData.TERMINAL_Y)

# handles logic for when to accelerate/decelerate player
func apply_x_accel(delta):	
	# logic: 
	# above input terminal: apply friction, ignore input
	# below or equal input terminal : apply player input, cap at input terminal
	# apply friction if no input OR input in opposite direction (product is negative)
	# cap at total terminal
	
	# new: momentum friction
	if abs(velocity.x) > MoveData.INPUT_TERMINAL and (direction * velocity.x > 0):
		# speed above input terminal and player moving in that direction: 
		# apply special "momentum friction"
		# make speed boosts more satisfying (in theory)
		apply_friction(delta, MoveData.MOMENTUM_MULTIPLIER)
	elif (not receive_input or abs(velocity.x) > MoveData.INPUT_TERMINAL 
			or direction == 0 or (direction * velocity.x < 0)):
		# standard friction
		apply_friction(delta, 1)
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

# new: allowing custom friction multiplier for special cases
func apply_friction(delta, multiplier):
	if not on_floor:
		multiplier *= MoveData.AIR_DECEL_MULTIPLIER
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
		used_double_jump = false
		# also reset down gravity to true
		apply_down_gravity = true

func apply_jump():
	just_jumped = false
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
		#regular jump
		velocity.y = MoveData.JUMP_VELOCITY
		used_jump = true
		just_jumped = true
		# cancel dash
		dashing = false
		dash_stopping = false
	elif not used_double_jump and receive_input and Input.is_action_just_pressed("jump"):
		# double jump
		# future consideration: short ray scan to ground
		# determines whether to buffer or double jump
		velocity.y = MoveData.DOUBLE_JUMP_VELOCITY
		used_double_jump = true
		just_jumped = true
		# cancel dash
		dashing = false
		dash_stopping = false

# dropping ledges
# checks for "s" input then temporarily disables collisions with
# one-way physics layer (layer 6)
func check_drop():
	if drop_timer > 0:
		drop_timer -= 1
	else:
		# timer at 0: set collision layer for one-way
		set_collision_mask_value(6, true)
		# user just dropped
		if Input.is_action_just_pressed("down"):
			# remove mask for one-way layer
			set_collision_mask_value(6, false)
			drop_timer = drop_delay

func dash(direction : Vector2, dash_frames : int, dash_velocity : 
			float, friction_frames : int, friction_decel : float):
	dashing = true
	dash_stopping = false
	# give back double jump
	used_double_jump = false
	# disable down gravity until next full jump
	apply_down_gravity = false
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

func update_curse():
	# updates the current curse status of the player
	# player needs area2d
	# check if player area interesect with area2d in group "curse"
	# if yes increment player curse tick and if it meets target curse tick,
	# increment curse stage and call specific curse function
	# kill player at curse stage 8
	
	# if there is no curse
	# reduce curse tick/stage
	pass

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
	if direction > 0:
		transform.x.x = 1
	elif direction < 0:
		transform.x.x = -1
		

func update_parry():
	if Input.is_action_just_pressed("parry") and receive_input:
		_state_machine.start("parry")
		# important: parry animation sets parry to false at the end

func _update_animation():
	# subclass can override
	# changes animations - subclass must use AnimationNodeStateMachine
	# handles idle-run, jump, parry, fall
	flip()
	# all players can parry
	#update_parry() # possibly combine into choose animation
	_choose_animation()

# function for choosing the animation to play/travel to
# subclasses with unique animations can override to adjust logic
func _choose_animation():
	if Input.is_action_just_pressed("parry") and receive_input:
		_state_machine.start("parry")
	elif just_jumped:
		# jump: and start from beginning
		_state_machine.start("jump")
	elif not on_floor:
		# fall
		_state_machine.travel("fall")
	elif not on_floor and used_jump or used_double_jump:
		# jump animation again
		_state_machine.travel("jump")
	elif on_floor:
		# set blend
		_animation_tree.set("parameters/idle-run/blend_position", direction)
		# idle-run
		_state_machine.travel("idle-run")

func kill():
	# kills player
	# _state_machine.travel("death")
	# get level manager parent and respawn player
	# level manager MUST be a parent of player!!!
	get_parent().respawn_player()
