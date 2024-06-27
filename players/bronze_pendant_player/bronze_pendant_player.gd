# dieter whittingham
# june 25 2024
# bronze pendant player

extends ReworkedDefaultController

const INPUT_TERMINAL_MULT = 1.2
const ACCEL_MULT = 1.4
const MOMENTUM_MULT = 0.7 # increase momentum

# switch to using timer
const CHARGE_S = 0.8 # number of frames at top speed to enter overdrive
const COOLDOWN_S = 0.4 # cools down when not at top speed

@onready var timer : Timer = $Timer
@onready var progress_bar = $ProgressBar

var charge_timer : int
var cooldown_timer : int
var top_speed : bool = false # whether the player is a top speed
var overdrive : bool = false # whether the player is currently in overdrive

func _ready():
	# override
	print("bronze pendant player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	_state_machine = _animation_tree.get("parameters/playback")
	# set timers
	#charge_timer = CHARGE_FRAMES
	#cooldown_timer = COOLDOWN_FRAMES

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	update_overdrive()
	# move and slide
	move_and_slide()

func update_overdrive():
	top_speed = abs(velocity.x) == MoveData.INPUT_TERMINAL
	if debug:
		print("------------\noverdrive: %s \ntop speed: %s\ntimer: %s " %
		[overdrive, top_speed, charge_timer, cooldown_timer])
	# update charge
	if top_speed:
		if overdrive: 
			# in overdrive and still at top speed
			# pause cooldown
			timer.paused = true
		else:
			# check charge timer timeout
			if timer.time_left == 0:
				enter_overdrive()
	else:
		# not top speed
		if overdrive:
			# print("in overdrive, cooling down")
			# on cooldown: timer ticking cooldown
			timer.paused = false
			if timer.time_left == 0:
				exit_overdrive()
		else:
			# not overdrive, not top speed, reset timer
			timer.start(CHARGE_S)

func enter_overdrive():
	print("entering overdrive")
	overdrive = true
	MoveData.INPUT_TERMINAL *= INPUT_TERMINAL_MULT
	MoveData.ACCELERATION *= ACCEL_MULT
	# increase momentum
	MoveData.MOMENTUM_MULTIPLIER *= MOMENTUM_MULT
	# reset cooldown
	timer.start(COOLDOWN_S)
	# hide progress bar
	progress_bar.hide()
	# can add an effect here (orangey copper tint)
	self.modulate = Color8(249, 174, 136, 255)

func exit_overdrive():
	print("exiting overdrive")
	overdrive = false
	# reset all buffs
	MoveData.MOMENTUM_MULTIPLIER /= MOMENTUM_MULT
	MoveData.INPUT_TERMINAL /= INPUT_TERMINAL_MULT
	MoveData.ACCELERATION /= ACCEL_MULT
	# reset all timers, timer back to charge mode
	timer.start(CHARGE_S)
	# show progress bar
	progress_bar.show()
	self.modulate = Color8(255, 255, 255, 255)
