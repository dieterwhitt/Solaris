# march 26 2024
# jump_pad.gd

extends Node2D

const pad_velocity = -300
var state_machine
@onready var tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	tree.active = true
	state_machine = tree.get("parameters/playback")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# called whenever a body enteres the jump pad area
func _on_area_2d_body_entered(body):
	print("jump pad collision with %s" %body)
	if body.is_in_group("Player"):
		body.velocity.y = pad_velocity
		body.used_jump = true
		body.can_hold_jump = false
		body.state_machine.start("jump")
		# play jump pad animation
		state_machine.start("spring")
		

