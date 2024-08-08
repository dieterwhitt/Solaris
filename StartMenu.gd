extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://world/towers/level_manager.tscn")
	pass # Replace with function body.
	

func _on_options_pressed():
	var options = load('res://Menu.tscn').instance() # change later? ideally want it to pull up options screen
	get_tree().current_scene.add_child(options) # change later, same reason as above
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
	pass # Replace with function body.
