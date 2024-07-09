# player template
# for any artifact script NOT including consumable artifacts / weapon artifacts

extends ReworkedDefaultController

func _ready():
	super()
	print("creating player")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# call any unique functions here
	# move and slide
	move_and_slide()
