# dieter whittingham
# june 1st 2024
# boomstick_player.gd

extends ReworkedDefaultController

# var direction2d = Vector2.ZERO
const RECOIL_VELOCITY = 240
@onready var pellets = $BoomstickPellets

func _ready():
	# override
	print("creating boomstick player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# sprite and state machine (sprite not needed anymore)
	# _sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# update_direction_2d()
	check_shoot()
	# move and slide
	move_and_slide()

# shoots pellets, killing all non-bulletproof enemies
# currently shoots left and right with 25 deg spread
# applies recoil in opposite direction.
# need to add cooldown, for now just shoots infinite amount
func check_shoot():
	if Input.is_action_just_pressed("special"):
		# set recoil to opposite current x facing direction
		var recoil_direction = -transform.x.x
		# apply recoil
		velocity.x = RECOIL_VELOCITY * recoil_direction
		# restarting using subemitters doesn't work: need to resort to adding child scene
		pellets.restart()
		pellets.get_child(0).restart()
		pellets.emitting = true
		# play shooting animation
		
		
		# check raycasts for enemies and kill all non-bulletproof ones
		for raycast in $KillCasts.get_children():
			pass
		
		
'''

func update_direction_2d():
	direction2d.x = Input.get_axis("left", "right")
	direction2d.y = Input.get_axis("up", "down")

func check_shoot():
	var recoil_direction = Vector2.ZERO
	if Input.is_action_just_pressed("special"):
		recoil_direction = -direction2d
		if recoil_direction == Vector2.ZERO:
			if transform.x.x == 1: recoil_direction.x = -1
			else: recoil_direction.x = 1
		recoil_direction = recoil_direction.normalized()
		# recoil_direction.x = _sprite.flip_h
		velocity = RECOIL_VELOCITY * recoil_direction
		# emitting particles
		var pellet_direction = Vector3.ZERO
		# abs val because want to always shoot right, will be flipped by parent
		pellet_direction.x = abs(recoil_direction.x)
		pellet_direction.y = -recoil_direction.y
		pellets.process_material.direction = pellet_direction
		pellets.emitting = true
'''
