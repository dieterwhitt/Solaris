# Player.gd 
# 11/30/24
# ABC Player class using decorator pattern. see UML

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

# ABC status effect class definition (see UML)
# decorators will have to create their own status effect nested classes, then
# add it here.
class StatusEffect:
	extends Timer
	var player : Player # player to apply effect to
	var show_bar : bool
	var bar_color : Color
	
	# constructor - not on tree yet
	# if player not provided: will check immediate parent for a player.
	func _init(duration: float, show_bar : bool = true, 
			bar_color: Color = Color.WHITE, player: Player = null):
		self.one_shot = true
		self.wait_time = duration
		self.player = player
		self.show_bar = show_bar
		self.bar_color = bar_color
		# connect timeout signal
		self.timeout.connect(_on_timeout)
	
	func _ready():
		if player == null:
			# search for player in parent. free if no parent or not player type.
			var parent : Node = get_parent()
			if parent == null or !parent.is_class("Player"):
				queue_free()
			else:
				player = parent
	
	func apply():
		pass
	
	func remove():
		pass
	
	# call remove() and free self from tree
	func _on_timeout():
		remove()
		queue_fr


# regular status effect
var status_effects : Array[StatusEffect] = []

'''antigravity removal
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
	update_multipliers_effects()
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
	# run move and slide (in subclass)
	# move_and_slide()

func update_direction():
	if receive_input:
		# -1, 0, 1
		direction = Input.get_axis("left", "right")

# updating movedata multipliers and temporary effects
func update_multipliers_effects():
	# filter all timed out multipliers (timer = 0)
	movedata_multipliers = movedata_multipliers.filter(func(x): return x != null)
	# print(movedata_multipliers)
	# filter all timed out effects (timer = 0)
	effects = effects.filter(func(x): return x != null)
	# print(effects)

# creates a new multiplier and adds it to the array of multipliers
func add_multiplier(attribute : String, value : float, time_s : float, total_time_s : float, 
		between_players : bool = false, show_progress_bar : bool = false, 
		progress_bar_color : Color = Color.WHITE ):
	print("creating new multiplier with timer %s" % time_s)
	var new_multiplier = multipliers_effects.Multiplier.new(MoveData, attribute, value, time_s, 
	total_time_s, between_players, show_progress_bar, progress_bar_color)
	# add child
	add_child(new_multiplier)
	# apply it
	new_multiplier.apply()
	movedata_multipliers.append(new_multiplier)

func add_effect(player : Node, apply_func, remove_func, 
		time_s : float, total_time_s : float, 
		between_players : bool = false, show_progress_bar : bool = false, 
		progress_bar_color : Color = Color.WHITE ):
	print("creating new effect with timer %s" % time_s)
	var new_effect = multipliers_effects.Effect.new(player, apply_func, remove_func, time_s, 
	total_time_s, between_players, show_progress_bar, progress_bar_color)
	# add child
	add_child(new_effect)
	# apply it
	new_effect.apply()
	effects.append(new_effect)

func apply_gravity(delta):
	# apply gravity if the player is in the air and 
	# below terminal velocity
	# apply the down gravity multiplier if used jump and are on the way down
	# i.e the user already jumped and is now falling
	var down_multiplier = 1
	if used_jump and velocity.y > 0 and apply_down_gravity and not antigrav_cooldown:
		down_multiplier = MoveData.DOWN_MULTIPLIER
	# update antigravity status
	var antigravity : bool = false
	for area in player_area.get_overlapping_areas():
		if area.is_in_group("GravityField"):
			antigravity = true
	
	# adjustments based on entering/exiting gravity field
	if antigravity != prev_antigravity:
		if antigravity:
			# just entered
			# print("entering gravity field")
			# cap y velocity for consistency
			if velocity.y < -50:
				velocity.y = -50
				print("capping upwards")
			elif velocity.y >= 0 and velocity.y < 50:
				# give boost when going down
				print("downwards boost")
				velocity.y = 50
		else:
			# just exited
			# print("exiting gravity field")
			pass
	
	# apply gravity
	if antigravity and velocity.y > -MoveData.TERMINAL_Y:
		# anti-gravity addition
		velocity.y -= MoveData.GRAVITY * delta
	elif not on_floor and velocity.y < MoveData.TERMINAL_Y:
		velocity.y += MoveData.GRAVITY * down_multiplier * delta
	
	# cap at terminal (falling speed only!)
	# do not cap if dash_stopping
	if not dash_stopping:
		velocity.y = min(velocity.y, MoveData.TERMINAL_Y)
		
	prev_antigravity = antigravity
	# antigravity cooldown
	if antigravity:
		antigrav_cooldown = true
	elif on_floor:
		antigrav_cooldown = false

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
		current_coyote -= delta * 60 # 1 frame on 60fps

func update_buffer(delta):
	# queue buffer
	if Input.is_action_just_pressed("jump") and not on_floor:
		current_jump_buffer = MoveData.JUMP_BUFFER
	elif current_jump_buffer > 0:
		current_jump_buffer -= delta * 60 # 1 frame on 60fps
	
		
func update_jump_elig():
	# replenish jump when on the floor
	if on_floor:
		used_jump = false
		used_double_jump = false
		# also reset down gravity to true
		apply_down_gravity = true

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
		dash_timer -= delta * 60
	elif dashing and dash_timer <= 0:
		# just hit 0: switch to stopping (friction)
		dashing = false
		dash_stopping = true
	# applying friction
	if dash_stopping and dash_friction_timer > 0:
		# apply friction and decrease timer
		velocity.x = move_toward(velocity.x, 0, dash_friction * delta)
		velocity.y = move_toward(velocity.y, 0, dash_friction * delta)
		dash_friction_timer -= delta * 60
	elif dash_stopping and dash_friction_timer <= 0:
		# apply regular physics again
		dash_stopping = false

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
		curse_stage += 1 * curse_speed_mult * delta * 60
		if curse_stage > CURSE_DEATH:
			kill()
	elif curse_stage > 0:
		# decrease timer
		curse_stage -= 1 * curse_decay_mult * delta * 60
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
		animation_tree.set("parameters/idle-run/blend_position", direction)
		# idle-run
		_state_machine.travel("idle-run")

func kill():
	# kills player
	# erase backup data
	var player_manager = get_node("/root/LevelManager/PlayerManager")
	if player_manager:
		player_manager.backup_consumable = false
	# need to remove all effects and multipliers upon death. new player scene will still have
	# the same movedata
	for multiplier in movedata_multipliers:
		if multiplier != null:
			multiplier.remove()
	for effect in effects:
		if effect != null:
			effect.remove()
	
	# reset backup data in player manager
	
	# _state_machine.travel("death")
	# get level manager parent and respawn player
	# level manager MUST be a parent of player!!!
	
	get_parent().respawn_player()

