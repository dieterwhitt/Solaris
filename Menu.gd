extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass


func _on_resume_pressed():
	get_parent().toggle_pause()


func _on_quit_pressed():
	get_tree().quit()
