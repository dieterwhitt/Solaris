# dieter whittingham
# may 30 2024
# abstract orb class
# inherited by all orbs

# REWORKED DEC 2024 (i got aids)

extends Node2D

class_name Orb

# hidden and non-interactable
var used = false
# allowing setting glass in inspector when making levels
@export var bubble : bool:
	set(new_bubble):
		bubble = new_bubble
		if Engine.is_editor_hint():
			# do through ready in game
			# since requires touching other node
			update_bubble_visibility() 
# getting the orb hitbox
@export_node_path("Area2D") var orb_area_path = null
@onready var hitbox = get_node(orb_area_path)
# for animation
@export_node_path("Node2D") var visual_parent_path = null
@onready var visual_parent: Node2D = get_node(visual_parent_path)

# get bubble
@export_node_path("Node2D") var bubble_path = null
@onready var bubble_scene: Node2D = get_node(bubble_path)
# time for orbs to come back after being hit
const RESET_TIME = 4.5
# Called when the node enters the scene tree for the first time.

func _ready():
	if visual_parent == null:
		print("orb error: visual parent not provided")
		queue_free()
		return
	if not bubble:
		bubble_scene.hide()
	update_bubble_visibility()
	if not Engine.is_editor_hint():
		hover() # hover tween animation

func update_bubble_visibility():
	# hide/show instead of add/free
	if bubble:
		bubble_scene.show()
	else:
		bubble_scene.hide()
	
	
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

func _consume():
	# default behaviour: hide all visual children except particles and bubble
	for node in visual_parent.get_children():
		if not node is GPUParticles2D and not node == bubble_scene:
			node.hide()

func _respawn():
	# default behaviour: show all children
	for node in visual_parent.get_children():
		if bubble or node != bubble_scene:
			node.show()
	

# removes self and adds back after reset time
func consume_and_respawn():
	used = true
	if bubble:
		bubble_scene.pop()
	_consume()
	# pause after removing
	await get_tree().create_timer(RESET_TIME).timeout
	_respawn()
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
	consume_and_respawn()

