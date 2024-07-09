# boss fight room

extends Level


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func _physics_process(delta):
	if Input.is_action_just_pressed("interact"):
		get_node("+20_FG/Boss1Acid/AnimationPlayer").current_animation = "rise-sequence"
