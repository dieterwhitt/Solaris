# dieter whittingham
# june 25 2024
# gas_mask_player.gd

extends ReworkedDefaultController

const CURSE_MULTIPLIER = 0.5

func _ready():
	super()
	print("creating adrenaline shot player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	_state_machine = _animation_tree.get("parameters/playback")
	curse_speed_mult = 0.4 # curse takes 2.5x longer
	curse_decay_mult = 4 # recover from curse faster

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# move and slide
	move_and_slide()

