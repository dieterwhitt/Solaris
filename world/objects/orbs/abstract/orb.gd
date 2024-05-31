# dieter whittingham
# may 30 2024
# abstract orb class
# inherited by all orbs

extends Node2D

class_name Orb

# hidden and non-interactable
var used = false
# allowing setting glass in inspector when making levels
@export var glass = false
# loading the glass scene
@onready var glass_scene
# getting the orb hitbox
@onready var hitbox = $Area2D
# time for orbs to come back after being hit
const RESET_TIME = 4
# Called when the node enters the scene tree for the first time.

func _ready():
	print(glass)
	# connect area2d using code
	if not glass:
		# hide glass
		$Glass.hide()
	else:
		# otherwise show glass
		$Glass.show()

func _physics_process(delta):
	# check collision
	check_activate()

func check_activate():
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("Player") and not used and \
		(Input.is_action_just_pressed("parry") or not glass):
			print("collision with dash orb")
			activate(body)

# override in subclass
func _orb_function(body):
	pass
	
# removes self and adds back after reset time
func remove():
	used = true
	hide()
	# pause after removing
	await get_tree().create_timer(RESET_TIME).timeout
	# add back
	show()
	used = false
	
# full orb function and removal
# eventually will need a consume animation for orb & glass 
# - for now just disappears
func activate(body):
	_orb_function(body)
	remove()

