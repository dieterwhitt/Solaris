# axe.gd
# pendulum axe

extends RigidBody2D

const GRAVITY : float = 670

# todo: adjustable length and initial angle (set start position).

@export var length : int = 32 # length of rope in pixels
@export var max_angle : float = 45

@onready var pivot = get_parent().get_node("Pivot")
@onready var line = get_parent().get_node("Line2D")

var max_velocity

var boosting = true
func _ready():
	# give it an initial direction (will be boosted)
	linear_velocity = Vector2(1, 0)
	max_velocity = sqrt(2 * GRAVITY * length * (1 - cos(deg_to_rad(max_angle))))
	print("new pendulum with max velocity %s" % max_velocity)
	# set height
	position.y = length

func _physics_process(delta):
	# update line
	line.set_point_position(1, self.position)
	
	# get tension direction
	var tension_direction = Vector2(pivot.global_position - self.global_position)
	
	# speed boost?
	if abs(tension_direction.x) < 1 and boosting:
		linear_velocity = max_velocity * linear_velocity.normalized()

