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
	update_direction()
	# update velocity
	velocity.x = speed * direction
	move_and_slide()

func update_direction():
	if is_on_wall():
		direction *= -1
	elif not left.is_colliding() and not right.is_colliding():
		# in air
		pass
	elif not left.is_colliding():
		# left side over edge: move right
		direction = 1
	elif not right.is_colliding():
		# right side over edge
		direction = -1
	
	# flip sprite 
	if direction < 0:
		#facing left
		$Sprite2D.flip_h = false
	else:
		# facing right
		$Sprite2D.flip_h = true
