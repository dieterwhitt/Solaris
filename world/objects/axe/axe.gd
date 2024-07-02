# axe.gd
# pendulum axe

extends RigidBody2D

const GRAVITY : float = 670

# todo: adjustable length and initial angle (set start position).

@export var length : int = 32 # length of rope in pixels
@export var initial_force_x : float = 100

@onready var pivot = get_parent().get_node("Pivot")
@onready var line = get_parent().get_node("Line2D")

func _ready():
	apply_impulse(Vector2(initial_force_x, 0))


func _physics_process(delta):
	# update line
	line.set_point_position(1, self.position)
	
	'''
	Fnet = Fcentripetal + Ftangential
	Fnet = T - mgcos(theta) + Ftangential
	so on any given frame
	Fcent = 1(v)^2/L = T - mgcos(theta)
	T = v^2/L + mgcos(theta)
	(T is scalar)
	'''
	# get tension direction
	var tension_direction = Vector2(pivot.global_position - self.global_position).normalized()
	var centrifugal_force : float = abs(GRAVITY * tension_direction.y) # mgcos(theta)
	var f_cent = (linear_velocity.length() ** 2) / float(length)
	# apply forces
	var tension : Vector2 = tension_direction * (centrifugal_force + f_cent)
	var gravity : Vector2 = Vector2(0, GRAVITY)
	apply_force(tension + gravity)
