# generic killbox for things like spikes, enemies, etc.
# kills player on contact
# must add collision shape when used

extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print("killbox collision")
	# kill player
	if body.is_in_group("Player"):
		body.kill()
