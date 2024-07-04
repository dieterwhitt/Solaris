# progress bar for curse

extends Node2D

@onready var bar = $Bar
var total : int = 480 # total curse length (frames)
var stage : int = 0 # current curse stage

func _ready():
	pass

func _process(delta):
	# set global transform so it isn't flipped
	global_transform.x.x = 1
	# percent already progressed
	var percent : float = float(stage) / float(total)
	# set bar accordingly
	var bar_length : int = floor(percent * 20) # 0-20 pixels
	bar.set_point_position(1, Vector2(bar_length - 10, 0))
	
	if stage == 0 or stage > total:
		hide()
	else:
		show()

