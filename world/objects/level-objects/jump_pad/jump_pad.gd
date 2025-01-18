# march 26 2024
# jump_pad.gd

@tool

extends Node2D

const pad_velocity = 300
var state_machine
@onready var tree = $AnimationTree

# improvement: rotation
enum direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var dir : direction = direction.UP:
	set(new_dir):
		dir = new_dir
		if Engine.is_editor_hint():
			var converter = {
			direction.UP : 0,
			direction.RIGHT : 90,
			direction.DOWN : 180,
			direction.LEFT : 270
			}
			rotation_degrees = converter[dir]

# Called when the node enters the scene tree for the first time.
func _ready():
	tree.active = true
	state_machine = tree.get("parameters/playback")
	# set rotation based on direction
	

# called whenever a body enteres the jump pad area
func _on_area_2d_body_entered(body):
	print("jump pad collision with %s" %body)
	if body.is_in_group("Player"):
		var velocities = {
			# multiplier, dimension (x = 0, y = 1)
			direction.DOWN : [1, 1],
			direction.RIGHT : [1, 0],
			direction.UP : [-1, 1],
			direction.LEFT : [-1, 0]
		}
		var pair = velocities[dir]
		body.velocity[pair[1]] = pair[0] * pad_velocity
		body.used_jump = true
		body.can_hold_jump = false
		body.state_machine.start("jump")
		# play jump pad animation
		state_machine.start("spring")
		

