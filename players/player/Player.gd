# Player.gd 
# 11/30/24
# Base Player class using simplified decorator pattern. see UML

# todo (eventually) add support for higher fps

class_name Player

# need to add parry and then should be done

extends CharacterBody2D

# jump options
var current_coyote : int = 0 # number of frames remaining
var used_jump : bool = true
var apply_down_gravity = true
var current_jump_buffer : int = 0
var on_floor : bool = false
# for animation: to determine when to start jump animation
var just_jumped = false
var jump_hold_frames: int = 0 # number of frames currently holding jump
var can_hold_jump = false

# dashing
var dashing = false
var dash_stopping = false
var dash_timer : int = 0
var dash_friction_timer : int = 0
var dash_friction : float = 0

# dropping ledges
var drop_timer : int = 0
const DROP_DELAY: int = 3


# direction: -1, 0, 1
# represents the current INPUT direction (left, none, right)
var direction : int = 0

# var dying = false # when playing death animation
# to disable input (physics still applies), ex. after ability usage
@export var receive_input : bool = true

# variable for print debug statements
@export var debug = false


''' outdated
@export_node_path("AnimationTree") var animation_tree_path : NodePath
@onready var animation_tree : AnimationTree = get_node(animation_tree_path)
'''

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = \
		animation_tree.get("parameters/playback")

# need to give the player an area as well for aoe detection (ex. curse)

# using move data resource. must be added in inspector or will crash
@export_file var move_data_resource_file

# duplicating to not effect original file when making modifications
@onready var MoveData : MoveDataResource = load(move_data_resource_file).duplicate()

# @onready var multipliers_effects = load("res://players/common/multipliers_effects.gd")

# player area & accumulated status effects (curse, etc.)
@onready var player_area : Area2D = $PlayerArea
@onready var curse_bar : Node2D = load("res://players/player/player_assets/curse_bar.tscn").instantiate()
var curse_stage : float = 0
const CURSE_DEATH : int = 480 # total number of frames until curse death
var curse_speed_mult : float = 1 # multiplier on curse speed
var curse_decay_mult : float = 2 # how much slower/faster curse decays

const FPS = 60

# ABC status effect class definition (see UML)
# decorators will have to create their own status effect nested classes, then
# add it here. works for any status effect, cooldown, etc.
# status effects will always be direct children of player.
class StatusEffect:
	extends Timer
	var duration : float
	var show_bar : bool
	var bar_color : Color
	var player : Player # player to apply effect to
	
	# constructor - not on tree yet
	# if player not provided: will check immediate parent for a player.
	func _init(duration: float, show_bar : bool = true, 
			bar_color: Color = Color.WHITE, player: Player = null):
		self.one_shot = true
		self.duration = duration
		self.wait_time = duration
		self.player = player
		self.show_bar = show_bar
		self.bar_color = bar_color
		
	func _ready():
		if player == null:
			# search for player in parent. free if no parent or not player type.
			var parent : Node = get_parent()
			if parent == null or !parent.is_class("Player"):
				queue_free()
			else:
				player = parent
		elif self not in player.get_children():
			# player was given but the effect is not a direct child: add it
			player.add_child(self)
		# connect timeout signal
		self.timeout.connect(_on_timeout)
	
	# virtual
	func apply():
		self.start()
	
	# virtual
	func remove():
		pass
	
	# call remove() and free self from tree
	func _on_timeout():
		remove()
		# orphan the effect, rather than remove it, so it can be reused. _ready will be re-called
		player.remove_child(self)
		self.wait_time = duration


'''antigravity - scrapped
# antigravity status from PREVIOUS frame
var prev_antigravity = false
# antigravity cooldown to ignore down gravity
var antigrav_cooldown = false
'''

func _ready():
	# adding player area and curse bar for detecting curse/aoe effects
	add_child(player_area)
	add_child(curse_bar)
	curse_bar.total = CURSE_DEATH
	# common stuff - 
	animation_tree.active = true

# runs every physics frame
# for updating physics
func _physics_process(delta):
	# in general: multiply by delta whenever velocity changes, except jump
	# velocity means 'how much to move the character next frame'
	# pre calculate on floor
	on_floor = is_on_floor()
	update_direction()
	update_curse(delta)
	update_dash(delta)
	if not dashing:
		apply_gravity(delta)
		apply_x_accel(delta)
		
	apply_jump(delta)
	check_drop()
	
	# handling animations
	_update_animation()
	
	_print_debug()
	# subclasses: define unique movement
	# run move and slide (logic can be changedin subclass)
	complete_default_physics()

func complete_default_physics():
	move_and_slide()

func update_direction():
	if receive_input:
		# -1, 0, 1
		direction = Input.get_axis("left", "right")

func apply_gravity(delta):
	# apply gravity if the player is in the air and below terminal velocity
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

func update_coyote(delta):
	# set timer to the coyote time when on the ground
	if on_floor:
		current_coyote = MoveData.COYOTE_TIME
	elif current_coyote > 0:
		# decrease the coyote timer for each frame off the ground
		current_coyote -= round(delta * FPS) # 1 frame on 60fps

func update_buffer(delta):
	# queue buffer
	if Input.is_action_just_pressed("jump") and not on_floor:
		current_jump_buffer = MoveData.JUMP_BUFFER
	elif current_jump_buffer > 0:
		current_jump_buffer -= round(delta * FPS) # 1 frame on 60fps
	
		
func update_jump_elig():
	# replenish jump when on the floor
	if on_floor:
		used_jump = false
		# also reset down gravity and jump holding status
		apply_down_gravity = true
		jump_hold_frames = 0 

func apply_jump(delta):
	just_jumped = false
	update_coyote(delta)
	update_buffer(delta)
	update_jump_elig()
	# jump if the user can jump and the user just pressed space and is 
	# still on the floor or in coyote time
	# pressed space <-> buffer > 0
	# on floor <-> coyote > 0
	if ((not used_jump and receive_input) 
			and (Input.is_action_just_pressed("jump") or current_jump_buffer > 0)
			 and (on_floor or current_coyote > 0)):
		# regular jump
		velocity.y = MoveData.JUMP_VELOCITY
		used_jump = true
		just_jumped = true
		can_hold_jump = true
		# reset buffers
		current_jump_buffer = 0
		current_coyote = 0
	elif used_jump and Input.is_action_pressed("jump") and \
			jump_hold_frames <= MoveData.JUMP_DURATION and can_hold_jump:
		# jump hold
		jump_hold_frames += (round(delta * FPS))
		velocity.y = MoveData.JUMP_VELOCITY
	elif used_jump and Input.is_action_just_released("jump"):
		# jump release: max out timer (can't re-hold)
		can_hold_jump = false


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
			drop_timer = DROP_DELAY

func dash(direction : Vector2, dash_frames : int, dash_velocity : 
			float, friction_frames : int, friction_decel : float):
	dashing = true
	dash_stopping = false
	# disable jump
	can_hold_jump = false
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
		dash_timer -= round(delta * FPS)
	elif dashing and dash_timer <= 0:
		# just hit 0: switch to stopping (friction)
		dashing = false
		dash_stopping = true
	# applying friction
	if dash_stopping and dash_friction_timer > 0:
		# apply friction and decrease timer
		velocity.x = move_toward(velocity.x, 0, dash_friction * delta)
		velocity.y = move_toward(velocity.y, 0, dash_friction * delta)
		dash_friction_timer -= round(delta * FPS)
	elif dash_stopping and dash_friction_timer <= 0:
		# apply regular physics again
		dash_stopping = false

# interface for adding statuseffect objects
func add_effect(effect: StatusEffect):
	self.add_child(effect)
	effect.apply()

func update_curse(delta):
	# updates the current curse status of the player
	# player needs area2d
	# check if player area interesect with area2d in group "Curse"
	# we will have a paused timer with a progress bar that we will manually
	# manipulate
	var cursed = false
	for node in player_area.get_overlapping_areas():
		if node.is_in_group("Curse"):
			cursed = true
			break
	if cursed:
		# increase timer
		curse_stage += 1 * curse_speed_mult * round(delta * FPS)
		if curse_stage > CURSE_DEATH:
			kill()
	elif curse_stage > 0:
		# decrease timer
		curse_stage -= 1 * curse_decay_mult * round(delta * FPS)
		if curse_stage < 0:
			curse_stage = 0
	# update curse bar
	curse_bar.stage = curse_stage

# debug function which prints data on the character
# subclasses may override to print additional data
func _print_debug():
	if debug:
		print("-------frame-------")
		print("address: %s" % self)
		print("velocity: %v" % velocity)
		print("direction: %d" % direction)
		print("recieve input: %s" % receive_input)
		# to do: print multipliers &effects as well
		

func _process(delta):
	pass

func flip():
	if direction > 0:
		transform.x.x = 1
	elif direction < 0:
		transform.x.x = -1
		

func update_parry():
	if Input.is_action_just_pressed("parry") and receive_input:
		state_machine.start("parry")
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
		state_machine.start("parry")
	elif just_jumped:
		# jump: and start from beginning
		state_machine.start("jump")
	elif not on_floor:
		# fall
		state_machine.travel("fall")
	elif not on_floor and used_jump:
		# jump animation again
		state_machine.travel("jump")
	elif on_floor:
		# set blend
		animation_tree.set("parameters/idle-run/blend_position", direction)
		# idle-run
		state_machine.travel("idle-run")

func kill():
	# state_machine.travel("death")
	# [play transition animation]
	
	# get level manager parent and respawn player
	var level_manager = get_node("/root/LevelManager")
	level_manager.respawn_player()

