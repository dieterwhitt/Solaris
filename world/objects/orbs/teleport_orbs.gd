# apr 12 2024
# teleport orbs

extends Node

@onready var enter = $Enter
@onready var exit = $Exit

# allowing setting glass in inspector when making levels
@export var GLASS = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GLASS:
		# delete glass sprite if not glass
		enter.get_node("Glass").queue_free()
	else:
		# otherwise show glass
		enter.get_node("Glass").show()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if glass, check for player attack on every frame
	if GLASS:
		check_activate()

func check_activate():
	for body in enter.get_node("Area2D").get_overlapping_bodies():
		if body.is_in_group("Player") and Input.is_action_just_pressed("attack"):
			teleport_body(body)

func _on_area_2d_body_entered(body):
	print("hit teleport orb")
	# body entered the entrance orb
	if body.is_in_group("Player") and not GLASS:
		teleport_body(body)
		

func teleport_body(body):
	# this should work i think... may need to find a better way
	body.position = exit.position
