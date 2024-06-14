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
# glass particles (freed if glass disabled)
@onready var glass_particle = load("res://world/particles/small_burst_1.tscn").instantiate()
# getting the orb hitbox
@onready var hitbox = $Area2D
# time for orbs to come back after being hit
const RESET_TIME = 4.5
# Called when the node enters the scene tree for the first time.

func _ready():
	# connect area2d using code
	if not glass:
		# delete
		$Glass.queue_free()
	else:
		# otherwise show glass
		$Glass.show()
		# experimenting: add small particles
		add_child(glass_particle)

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
	# hide all children except particles
	for node in get_children():
		if node != glass_particle:
			node.hide()
	# pause after removing
	await get_tree().create_timer(RESET_TIME).timeout
	# show all children
	for node in get_children():
		node.show()
	used = false
	
# full orb function and removal
# eventually will need a consume animation for orb & glass 
# - for now just disappears
func activate(body):
	_orb_function(body)
	# messing around with particles
	if glass:
		glass_particle.emitting = true
	remove()

