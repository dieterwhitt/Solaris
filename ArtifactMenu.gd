extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass
	
func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		get_parent().manage_artifacts()
