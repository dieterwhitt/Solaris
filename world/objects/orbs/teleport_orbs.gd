# apr 12 2024
# teleport orbs

# REWORKED DEC 2024
@tool
extends Orb

@onready var exit = $VisualParent/Exit
@onready var enter = $VisualParent/Enter

@export var exit_delta : Vector2 = Vector2(0, 8):
	set(new_exit_delta):
		# editor only
		if Engine.is_editor_hint():
			exit.position = enter.position + new_exit_delta
		exit_delta = new_exit_delta

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	# in-game only (since exit, enter don't exist before ready)
	if not Engine.is_editor_hint():
		exit.position = enter.position + exit_delta

func _orb_function(body):
	body.global_position = exit.global_position
