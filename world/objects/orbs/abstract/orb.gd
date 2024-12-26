# dieter whittingham
# may 30 2024
# abstract orb class
# inherited by all orbs

extends Node2D

class_name Orb

# hidden and non-interactable
var used = false
# allowing setting glass in inspector when making levels
@export var bubble = false
# loading the glass scene
@onready var bubble_scene = preload("res://world/objects/orbs/abstract/bubble/bubble.tscn").instantiate()
# getting the orb hitbox
@onready var hitbox = $OrbArea
# time for orbs to come back after being hit
const RESET_TIME = 4.5
# Called when the node enters the scene tree for the first time.

func _ready():
	hover() # hover tween animation
	# connect area2d using code
	if not bubble:
		# delete
		bubble_scene.queue_free()
		bubble_scene = null
	else:
		# otherwise show glass
		add_child(bubble_scene)

func hover():
	position.y -= 1
	# go up 2, down 2, repeat
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", Vector2(position.x, position.y + 1), 1)
	tween.tween_property(self, "position", Vector2(position.x, position.y - 1), 1)
	
# override in subclass
func _orb_function(body):
	pass
	
# removes self and adds back after reset time
func remove():
	used = true
	if bubble:
		bubble_scene.pop()
	# hide all children except particles and bubble
	for node in get_children():
		if not node is GPUParticles2D and not node == bubble_scene:
			node.hide()
	# pause after removing
	await get_tree().create_timer(RESET_TIME).timeout
	# show all children
	for node in get_children():
		node.show()
	if bubble:
		bubble_scene.reform()
	used = false
	
# full orb function and removal
# eventually will need a consume animation for orb & bubble 
# - for now just disappears
func activate(body):
	if used:
		return
	_orb_function(body)
	remove()

