extends DefaultController

func _init():
	super._init()

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	move_and_slide()
	
