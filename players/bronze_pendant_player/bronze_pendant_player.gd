# dieter whittingham
# june 25 2024
# aeramen pendant player

extends ReworkedDefaultController

const INPUT_TERMINAL_MULT = 1.2
const ACCEL_MULT = 1.4
const MOMENTUM_MULT = 0.5 # double momentum, on cooldown

const CHARGE_FRAMES = 50 # number of frames at top speed to enter overdrive
const COOLDOWN_FRAMES = 25 # cools down when not at top speed

var charge_timer : int
var cooldown_timer : int
var top_speed : bool = false # whether the player is a top speed
var overdrive : bool = false # whether the player is currently in overdrive

func _ready():
	# override
	print("aeramen pendant player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	_state_machine = _animation_tree.get("parameters/playback")
	# set timers
	charge_timer = CHARGE_FRAMES
	cooldown_timer = COOLDOWN_FRAMES

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	update_overdrive()
	# move and slide
	move_and_slide()

func update_overdrive():
	top_speed = abs(velocity.x) == MoveData.INPUT_TERMINAL
	if debug:
		print("------------\noverdrive: %s \ntop speed: %s\ncharge timer: %s \
		\ncooldown timer: %s \n" % [overdrive, top_speed, charge_timer, cooldown_timer])
	# update charge
	if top_speed:
		if overdrive: 
			# in overdrive and still at top speed
			pass
		else:
			# reduce charge timer
			charge_timer -= 1
			if charge_timer == 0:
				enter_overdrive()
	else:
		# not top speed
		if overdrive:
			# print("in overdrive, cooling down")
			# on cooldown: reduce cooldown timer
			cooldown_timer -= 1
			
			if cooldown_timer == 0:
				exit_overdrive()
		else:
			# not overdrive, not top speed, reset timers
			charge_timer = CHARGE_FRAMES
			cooldown_timer = COOLDOWN_FRAMES

func enter_overdrive():
	print("entering overdrive")
	overdrive = true
	MoveData.INPUT_TERMINAL *= INPUT_TERMINAL_MULT
	MoveData.ACCELERATION *= ACCEL_MULT
	# increase momentum
	MoveData.MOMENTUM_MULTIPLIER *= MOMENTUM_MULT
	# reset cooldown
	cooldown_timer = COOLDOWN_FRAMES
	# can add an effect here (orangey copper tint)
	self.modulate = Color8(249, 174, 136, 255)

func exit_overdrive():
	print("exiting overdrive")
	overdrive = false
	# reset all buffs
	MoveData.MOMENTUM_MULTIPLIER /= MOMENTUM_MULT
	MoveData.INPUT_TERMINAL /= INPUT_TERMINAL_MULT
	MoveData.ACCELERATION /= ACCEL_MULT
	# reset all timers
	charge_timer = CHARGE_FRAMES
	cooldown_timer = COOLDOWN_FRAMES
	self.modulate = Color8(255, 255, 255, 255)
