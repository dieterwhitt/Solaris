# dieter whittingham
# june 24 2024
# adrenaline_player.gd

extends ReworkedDefaultController

# switch to using timers instead of frame timers (for progress bar)
# prolly will have to rework the effect/movedata multipliers for timers too

const DURATION_S : int = 5 # duration in seconds per charge, must *60 to convert to frames
const RUN_SPEED_MULT : float = 1.35
const ACCEL_MULT : float = 2
const DECEL_MULT : float = 1.8
var charges : int = 3 # total charges remaining

# cooldown timer
var COOLDOWN_LENGTH_S = 8 # cooldown in seconds
var cooldown_timer = 0 # frames

@export_file var particle_scene
# loading script containing effect apply/remove functions
@onready var adrenaline_effect = preload("res://players/adrenaline_player/adrenaline_effect.gd")

func _ready():
	# override
	print("creating adrenaline shot player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# state machine
	_state_machine = _animation_tree.get("parameters/playback")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	update_cooldown(delta)
	check_adrenaline()
	# move and slide
	move_and_slide()

# function that applies adrenaline boost
func check_adrenaline():
	if charges > 0 and Input.is_action_just_pressed("special") and cooldown_timer == 0:
		charges -= 1
		var frame_duration = DURATION_S * 60
		# apply speed boost
		add_multiplier("ACCELERATION", ACCEL_MULT, DURATION_S, DURATION_S, true, false)
		add_multiplier("INPUT_TERMINAL", RUN_SPEED_MULT, DURATION_S, DURATION_S, true, false)
		add_multiplier("DECELERATION", DECEL_MULT, DURATION_S, DURATION_S, true, false)
		cooldown_timer = COOLDOWN_LENGTH_S * 60
		
		# apply and remove moved to another file to prevent dangling function pointers
		add_effect(self, adrenaline_effect.apply, adrenaline_effect.remove, 
		DURATION_S, DURATION_S, true, true, Color8(235, 48, 96, 255))

# updates the cooldown
func update_cooldown(delta):
	if cooldown_timer <= 0:
		cooldown_timer = 0
	else:
		# decrease
		cooldown_timer -= delta * 60
		
