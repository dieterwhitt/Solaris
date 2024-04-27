# dieter apr 27
# charging enemy

extends CharacterBody2D

# gravity - 670
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# idle speed
var idle_speed = 30
var charge_speed = 130
var charge_decel = 200
# direction - start facing left
var direction = -1
var charging : bool = false
var growing : bool = false

@onready var left = $RayCast2DLeft
@onready var right = $RayCast2DRight
@onready var scan = $Scan

@onready var coll_boxes = [$SmallCollisionBox, $BigCollisionBox]
@onready var kill_boxes = [$SmallKillbox, $BigKillbox]

@onready var animation_state_machine = \
		$AnimationTree.get("parameters/playback")



func _ready():
	# ignore self in raycast checks
	left.add_exception(self)
	right.add_exception(self)
	scan.add_exception(self)
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
	if scan.is_colliding() and \
			animation_state_machine.get_current_node() == "idle":
		# scan colliding with player and idle
		print("player detected")
		queue_charge()
	
	update_velocity(delta)
		
	move_and_slide()

func update_velocity(delta):
	# lastly update velocity
	if charging:
		# no acceleration, just set velocity
		velocity.x = charge_speed * direction
	elif abs(velocity.x) > idle_speed:
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
	elif not left.is_colliding() and not right.is_colliding():
		# in air
		pass
	elif not charging and not growing and not left.is_colliding():
		# left side over edge: move right
		direction = 1
	elif not charging and not growing and not right.is_colliding():
		# right side over edge
		direction = -1
	
	# flip sprite and scan direction
	if direction < 0:
		#facing left
		scan.rotation_degrees = 0
		$Sprite2D.flip_h = false
	else:
		# facing right
		scan.rotation_degrees = 180
		$Sprite2D.flip_h = true

func queue_charge():
	print("queueing charge")
	# play grow animation (animation player goes to charge automatically)
	animation_state_machine.travel("grow")
	growing = true
	
	
func start_charge():
	print("starting charge")
	# change to big hitbox
	add_child(coll_boxes[1])
	add_child(kill_boxes[1])
	# set charging
	charging = true
	growing = false
	# plays charge animation (animation player ends at end)
	
func end_charge():
	print("ending charge")
	# back to idle
	charging = false
	remove_child(coll_boxes[1])
	remove_child(kill_boxes[1])
