# dieter whittingham
# may 30 2024
# abstract orb class
# inherited by all orbs

extends Node2D

# loading the glass scene
@onready var glass_scene
# getting the orb hitbox
@onready var hitbox = $Area2D
# allowing setting glass in inspector when making levels
@export var glass = false
# time for orbs to come back after being hit
const RESET_TIME = 15
# Called when the node enters the scene tree for the first time.
func _ready():
	if not glass:
		# delete glass sprite if not glass
		$Glass.queue_free()
	else:
		# otherwise show glass
		$Glass.show()

func _process(delta):
	# check collision
	pass

func _activate(body):
	pass
