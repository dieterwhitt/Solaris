# boss fight room

extends Level


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func _physics_process(delta):
	pass
		


func _on_warmadillo_started_rolling():
	pass # Replace with function body.


func _on_warmadillo_started_staggering():
	get_node("+20_FG/Boss1Acid/AnimationPlayer").current_animation = "rise-sequence"
