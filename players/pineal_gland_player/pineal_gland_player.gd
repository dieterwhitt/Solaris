# player template
# for any artifact script NOT including consumable artifacts / weapon artifacts
# pineal gland player

extends ReworkedDefaultController

# create new class for rework
# pineal gland effect: remove collision layer (maybe put on custom layer), 
# modulate golden color, emit golden particles from entire body
# probably for 5 ish seconds

func _ready():
	# override
	print("creating player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	_state_machine = _animation_tree.get("parameters/playback")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# call any unique functions here
	# move and slide
	move_and_slide()

