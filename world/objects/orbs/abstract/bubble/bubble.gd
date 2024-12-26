extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pop():
	$AnimationPlayer.current_animation = "pop"
	$BubbleBurst.emitting = true
	
func reform():
	$AnimationPlayer.current_animation = "reform"
