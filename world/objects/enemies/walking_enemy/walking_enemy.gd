# new charging enemy

extends CharacterBody2D

# gravity - 670
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# idle speed
var idle_speed = 30
var charge_speed = 110
var charge_decel = 200
# direction - start facing left
var direction = 1
var growing : bool = false

@onready var back = $RayCast2DBack
@onready var front = $RayCast2DFront
@onready var scan = $Scan

@onready var coll_boxes = [$SmallCollisionBox, $BigCollisionBox]
@onready var kill_boxes = [$SmallKillbox, $BigKillbox]

@onready var animation_state_machine = \
		$AnimationTree.get("parameters/playback")



func _ready():
	# start in idle mode: remove large collision and damage box
	remove_child(coll_boxes[1])
	remove_child(kill_boxes[1])

func _physics_process(delta):
	# apply gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# update direction
	update_direction()

	# check charge
	var collider = scan.get_collider()
	if collider and collider.is_in_group("Player") and \
			animation_state_machine.get_current_node() == "idle":
		# scan colliding with player and idle
		# first collider is player
		print("player detected")
		play_aggro()
	
	update_velocity(delta)
		
	move_and_slide()

func update_velocity(delta):
	if abs(velocity.x) > idle_speed:
		# moving faster than idle speed
		# decelerate
		velocity.x = move_toward(velocity.x, 0, charge_decel * delta)
	else:
		# set idle speed
		velocity.x = idle_speed * direction


func update_direction():
	# does not check ledges if charging
	if is_on_wall():
		direction *= -1
	elif not back.is_colliding() and not front.is_colliding():
		# in air
		pass
	elif (not front.is_colliding() or not back.is_colliding()):
		# right side over edge
		direction *= -1
	
	# flip sprite and scan direction
	if direction < 0:
		#facing left
		transform.x.x = -1
	else:
		# facing right
		transform.x.x = 1

func play_aggro():
	# play grow animation (animation player goes to charge automatically)
	animation_state_machine.travel("aggro")
	growing = true
	# plays charge animation (animation player ends at end)
