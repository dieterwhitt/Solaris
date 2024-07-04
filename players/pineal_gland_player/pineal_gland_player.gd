# player template
# for any artifact script NOT including consumable artifacts / weapon artifacts
# pineal gland player

extends ConsumableArtifact

# create new class for rework
# pineal gland effect: remove collision layer (maybe put on custom layer), 
# modulate golden color, emit golden particles from entire body
# probably for 5 ish seconds

# this ones chill cuz no cooldown

const WARP_TIME = 5
const BAR_COLOR : Color = Color8(215, 203, 108, 255)

@onready var warp_effect = preload("res://players/pineal_gland_player/warp_effect.gd")

func _ready():
	super()
	print("creating player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	_state_machine = _animation_tree.get("parameters/playback")
	
	_charges_left = 1 # total charges remaining
	_cooldown_length = -1 # no cooldown

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# call any unique functions here
	check_warp()
	# move and slide
	move_and_slide()

func check_warp():
	# warps into another dimension (loaded in effect)
	if Input.is_action_just_pressed("special") and _charges_left > 0:
		_charges_left -= 1
		add_effect(self, warp_effect.apply, warp_effect.remove, 
		WARP_TIME, WARP_TIME, true, true, BAR_COLOR)
		# very slight speed boost (1.15x)
		add_multiplier("INPUT_TERMINAL", 1.1, WARP_TIME, WARP_TIME, true, false)
	elif _charges_left == 0:
		var item_particle = $GlandItemParticle
		if item_particle:
			item_particle.queue_free()

