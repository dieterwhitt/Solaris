# progress bar for curse

# july 8 2024 - reworked into 6 skulls

extends Node2D

var total : int = 480 # total curse length (frames)
var stage : int = 0 # current curse stage

@onready var skulls = [$Skulls/Skull, $Skulls/Skull2, $Skulls/Skull3, \
$Skulls/Skull4, $Skulls/Skull5, $Skulls/Skull6]

func _ready():
	pass

func _process(delta):
	# set global transform so it isn't flipped
	global_transform.x.x = 1
	# percent already progressed
	var percent : float = float(stage) / float(total)
	# set skulls accordingly
	# 6 skulls, each skull represents a full 1/7
	var index = 1
	for skull in skulls:
		var state_machine = skull.get_node("AnimationTree").get("parameters/playback")
		if percent >= float(index) / 7:
			state_machine.travel("visible")
			index += 1
		else:
			state_machine.travel("invisible")
	
	if stage == 0 or stage > total:
		# make all skulls fade out
		for skull in skulls:
			var state_machine = skull.get_node("AnimationTree").get("parameters/playback")
			state_machine.travel("invisible")
	else:
		show()
		

