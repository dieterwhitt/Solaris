# dieter whittingham
# june 25 2024
# gas_mask_player.gd

extends ReworkedDefaultController

const CURSE_MULTIPLIER = 0.5

func _ready():
	# override
	print("creating adrenaline shot player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	_state_machine = _animation_tree.get("parameters/playback")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# move and slide
	move_and_slide()

func update_curse():
	# override: adjust the logic
	# can't do this until curse system is set up, all good
	pass
