extends RigidBody2D


# for some reason doesn't like setting height from parent, do it here
func _ready():
	position.y = get_parent().length

