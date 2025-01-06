# apr 12 2024
# teleport orbs

# REWORKED DEC 2024
# don't touch this file...

@tool
extends Orb

@onready var exit = $VisualParent/Exit
@onready var enter = $VisualParent/Enter

@export var exit_delta : Vector2 = Vector2(0, -8):
	set(new_exit_delta):
		# editor only
		exit_delta = new_exit_delta
		if Engine.is_editor_hint():
			exit.position = enter.position + exit_delta

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	exit.position = enter.position + exit_delta

func _orb_function(body):
	body.global_position = exit.global_position
