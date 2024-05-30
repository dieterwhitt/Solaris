# 4/2/2024
# dash orb

extends Node2D

# problem: gravity is naturally weaker than air friction
# standard gravity - 670
# standard friction - 525

# dash velocity
var DASH_VELOCITY = 300 # 275 250 #300
# number of frames into dash before applying friction
var DASH_FRAMES : int = 6 #6
# dash deceleration
var DASH_FRICTION : float = 950 # 1600 100 #2750
var FRICTION_FRAMES : int = 5 # 4 #3

# allowing setting glass in inspector when making levels
@export var GLASS = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GLASS:
		# delete glass sprite if not glass
		$Glass.queue_free()
	else:
		# otherwise show glass
		$Glass.show()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if glass, check for player attack on every frame
	if GLASS:
		check_activate()

func check_activate():
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Player") and Input.is_action_just_pressed("attack"):
			print("collision with dash orb")
			dash_body(body)


func _on_area_2d_body_entered(body):
	# dash player upon entering if not glass.
	if body.is_in_group("Player") and not GLASS:
		dash_body(body)
		
			
func dash_body(body):
	print("collision with dash orb")
	# calculate direction vector
	var direction : Vector2 = Vector2.ZERO
	if int(round(rotation_degrees)) % 45 == 0:
		# direction vector based on angle
		direction = Vector2(sin(rotation), -cos(rotation))
		# check diagonal: reduce friction (divide by root 2)
		var mult = 1
		if int(round(rotation_degrees)) % 90 != 0:
			mult = 1/sqrt(2)
		body.dash(direction, DASH_FRAMES, DASH_VELOCITY, 
				FRICTION_FRAMES, DASH_FRICTION * mult)
	else:
		print("invalid jump orb rotation")
	

