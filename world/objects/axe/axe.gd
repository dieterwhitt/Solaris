# axe.gd
# pendulum axe

extends Node2D

const GRAVITY : float = 670

# todo: adjustable length and initial angle (set start position).

@export var length : int = 32 # length of rope in pixels
@export var max_angle : float = 45

@onready var pivot = $Pivot
@onready var line = $Line2D
@onready var axe_body = $AxeBody

# velocity at bottom of oscillation
var max_velocity

func _ready():
	# give it an initial direction (will be boosted)
	axe_body.linear_velocity = Vector2(1, 0)
	# use angle to calculate height, convert gravitational potential
	# to kinetic energy to get max speed at the bottom
	max_velocity = sqrt(2 * GRAVITY * length * (1 - cos(deg_to_rad(max_angle))))
	print("new pendulum with max velocity %s" % max_velocity)
	# set height (also set in child)
	axe_body.position.y = length

func _physics_process(delta):
	print(axe_body.position.y)
	# update line
	line.set_point_position(1, axe_body.position)
	
	# get tension direction
	var tension_direction = Vector2(pivot.global_position - axe_body.global_position)
	
	# speed boost (at bottom, since physics innaccuracies lose speed over time)
	if abs(tension_direction.x) < 1:
		axe_body.linear_velocity = max_velocity * axe_body.linear_velocity.normalized()
	
	axe_body.apply_force(Vector2(0, GRAVITY))
