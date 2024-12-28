# 4/2/2024
# dash orb

# REWORKED DEC 2024
# don't touch this file...

@tool
extends Orb
# export rotation, rotate start in _ready

# dash velocity
const DASH_VELOCITY = 300 # 275 250 #300
# number of frames into dash before applying friction
const DASH_FRAMES : int = 6 #6
# dash deceleration
const DASH_FRICTION : float = 950 # 1600 100 #2750
const FRICTION_FRAMES : int = 5 # 4 #3

@onready var dash_particles = $VisualParent/RotateParent/DashParticles
@onready var rotate_parent =  $VisualParent/RotateParent

enum direction {
	NORTH = 0,
	NORTHEAST = 1,
	EAST = 2,
	SOUTHEAST = 3,
	SOUTH = 4,
	SOUTHWEST = 5,
	WEST = 6,
	NORTHWEST = 7
}

@export var dir : direction:
	set(new_dir):
		dir = new_dir
		if Engine.is_editor_hint():
			update_rotate_parent()
		# bubble stays at 0

func _ready():
	super()
	update_rotate_parent()
	print("created dash orb")

func update_rotate_parent():
	rotate_parent.rotation_degrees = dir * 45

# have to override cuz added rotate parent
func _consume():
	for node in rotate_parent.get_children():
		if not node is GPUParticles2D and not node == bubble_scene:
			node.hide()

func _respawn():
	for node in rotate_parent.get_children():
		node.show()

func _orb_function(body):
	# calculate direction vector
	var direction : Vector2 = Vector2.ZERO
	# direction vector based on angle
	direction = Vector2(sin(rotate_parent.rotation), -cos(rotate_parent.rotation))
	# check diagonal: reduce friction (divide by root 2)
	var mult = 1
	if int(round(rotate_parent.rotation_degrees)) % 90 != 0:
		mult = 1/sqrt(2)
	body.dash(direction, DASH_FRAMES, DASH_VELOCITY, 
			FRICTION_FRAMES, DASH_FRICTION * mult)
	dash_particles.emitting = true
