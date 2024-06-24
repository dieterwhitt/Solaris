# dieter whittingham
# june 24 2024
# adrenaline_player.gd

extends ReworkedDefaultController

const DURATION_S : int = 5 # duration in seconds per charge, must *60 to convert to frames
const RUN_SPEED_MULT : float = 1.35
const ACCEL_MULT : float = 2
const DECEL_MULT : float = 1.8
var charges : int = 3 # total charges remaining

# cooldown timer
var COOLDOWN_LENGTH_S = 8 # cooldown in seconds
var cooldown_timer = 0 # frames

@export_file var particle_scene
@onready var adrenaline_effect = preload("res://players/adrenaline_player/adrenaline_effect.tres")

func _ready():
	# override
	print("creating adrenaline shot player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# sprite and state machine (sprite not needed anymore)
	# _sprite = $Sprite2D
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
		add_multiplier("ACCELERATION", ACCEL_MULT, frame_duration)
		add_multiplier("INPUT_TERMINAL", RUN_SPEED_MULT, frame_duration)
		add_multiplier("DECELERATION", DECEL_MULT, frame_duration)
		cooldown_timer = COOLDOWN_LENGTH_S * 60
		# apply and remove moved to another file to prevent dangling function pointers
		'''
		var apply = func apply_particles(player):
			print("applying adrenaline particles")
			# add particles (effect)
			var particles = load(particle_scene).instantiate()
			player.add_child(particles)
			particles.name = "AdrenalineParticles"
			particles.emitting = true
		
		var remove = func remove_particles(player):
			# remove particels (effect)
			print("removing adrenaline particles")
			player.remove_child($AdrenalineParticles)
		'''
		add_effect(self, frame_duration, adrenaline_effect.apply, adrenaline_effect.remove)

# updates the cooldown
func update_cooldown(delta):
	if cooldown_timer <= 0:
		cooldown_timer = 0
	else:
		# decrease
		cooldown_timer -= delta * 60
		
