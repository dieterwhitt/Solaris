# generic killbox for things like spikes, enemies, etc.
# kills player on contact
# must add collision shape when used

# todo: check player area instead of body

extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	print("killbox player collision at %v" % global_position)
	# kill player
	if body is Player:
		body.kill()
