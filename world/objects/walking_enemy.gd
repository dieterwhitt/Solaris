extends CharacterBody2D

# gravity - 670
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# speed
var speed = 30
# direction - start facing right, may change
var direction = 1

@onready var left = $RayCast2DLeft
@onready var right = $RayCast2DRight

func _ready():
	# ignore self in raycast checks
	left.add_exception(self)
	right.add_exception(self)

func _physics_process(delta):
	# apply gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# update direction
	if is_on_wall() or not left.is_colliding() or not right.is_colliding():
		direction *= -1
	# update velocity
	velocity.x = speed * direction
	move_and_slide()


func _on_area_2d_body_entered(body):
	print("enemy collision")
	# check for player entered damage box
	if body.is_in_group("Player"):
		body.kill()
