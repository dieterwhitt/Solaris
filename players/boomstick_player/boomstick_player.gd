# dieter whittingham
# june 1st 2024
# boomstick_player.gd

extends ReworkedDefaultController

var direction2d = Vector2.ZERO
const SHOTGUN_VELOCITY = 225

func _ready():
	# override
	print("creating boomstick player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# sprite and state machine
	_sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	update_direction_2d()
	check_shoot()
	# move and slide
	move_and_slide()
	
func update_direction_2d():
	direction2d.x = Input.get_axis("left", "right")
	direction2d.y = Input.get_axis("up", "down")

func check_shoot():
	var recoil_direction = Vector2.ZERO
	if Input.is_action_just_pressed("special"):
		recoil_direction.x = -direction2d.x
		recoil_direction.y = -direction2d.y
		if recoil_direction == Vector2.ZERO:
			if (_sprite.flip_h): recoil_direction.x = 1 
			else: recoil_direction.x = -1
		recoil_direction = recoil_direction.normalized()
		# recoil_direction.x = _sprite.flip_h
		velocity = SHOTGUN_VELOCITY * recoil_direction
		# emitting particles
		var pellet_direction = Vector3.ZERO
		pellet_direction.x = -recoil_direction.x
		pellet_direction.y = -recoil_direction.y
		$BoomstickPellets.process_material.direction = pellet_direction
		$BoomstickPellets.emitting = true
		
