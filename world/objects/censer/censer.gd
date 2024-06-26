# dieter whittingham
# june 26 2024
# censer.gd

extends Sprite2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var timer = $Timer

func _ready():
	print("loading censer")
	animation_tree.active = true

