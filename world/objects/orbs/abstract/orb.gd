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
# for animation
@export_node_path("Node2D") var visual_parent_path = null
var visual_parent: Node2D

# time for orbs to come back after being hit
const RESET_TIME = 4.5
# Called when the node enters the scene tree for the first time.

func _ready():
	visual_parent = get_node(visual_parent_path)
	if visual_parent == null:
		print("orb error: visual parent not provided")
		queue_free()
	# connect area2d using code
	if not bubble:
		# delete
		bubble_scene.queue_free()
		bubble_scene = null
	else:
		visual_parent.add_child(bubble_scene)
	hover() # hover tween animation

func hover():
	# go up 2, down 2, repeat
	var tween = visual_parent.create_tween().set_loops().set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	# be sure to NOT move hitbox (gameplay consistency)
	# move all non-hitbox children to new node, tween that
	var dur1 = randf_range(0.8, 1.2)
	var dur2 = randf_range(0.8, 1.2)
	tween.tween_property(visual_parent, "position", 
		Vector2(visual_parent.position.x, visual_parent.position.y + 1), dur1)
	tween.tween_property(visual_parent, "position", 
		Vector2(visual_parent.position.x, visual_parent.position.y - 1), dur2)
	
# override in subclass
func _orb_function(body):
	pass
	
# removes self and adds back after reset time
func remove():
	used = true
	if bubble:
		bubble_scene.pop()
	# hide all children except particles and bubble
	for node in visual_parent.get_children():
		if not node is GPUParticles2D and not node == bubble_scene:
			node.hide()
	# pause after removing
	await get_tree().create_timer(RESET_TIME).timeout
	# show all children
	for node in visual_parent.get_children():
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

