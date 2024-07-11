extends Node2D

@onready var radius = sqrt(pow(position.x, 2) + pow(position.y, 2))
# Called when the node enters the scene tree for the first time.
func _ready():
	print('radius is ' + str(radius))
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
