# dieter whittingham
# june 1st 2024
# boomstick_player.gd

extends ConsumableArtifact

# var direction2d = Vector2.ZERO
const RECOIL_VELOCITY = 240
# const COOLDOWN_FRAMES = 45 # cooldown time in frames
# var cooldown_timer = 0
const COOLDOWN_TIME = 0.75 # s

@onready var killcasts = $KillCasts
@onready var boomstick_effect = load("res://players/boomstick_player/boomstick_effect.gd")

func _ready():
	# override
	print("creating boomstick player")
	# activate animation tree
	_animation_tree = $AnimationTree
	_animation_tree.active = true
	# sprite and state machine (sprite not needed anymore)
	# _sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")
	_charges_left = -1 # infinite charges
	_cooldown_length = COOLDOWN_TIME # setting cooldown length variable

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	check_shoot()
	# move and slide
	move_and_slide()

# rework: use effect system to spawn pellets

# shoots pellets, killing all non-bulletproof enemies
# currently shoots left and right with 25 deg spread
# applies recoil in opposite direction.
func check_shoot():
	if Input.is_action_just_pressed("special") and _cooldown_timer.time_left == 0:
		# set recoil to opposite current x facing direction
		var recoil_direction = -transform.x.x
		# apply recoil
		velocity.x = RECOIL_VELOCITY * recoil_direction
		# set cooldown
		_cooldown_timer.start(COOLDOWN_TIME)
		# play shooting animation
		
		# check raycasts for enemies and kill all non-bulletproof ones
		# if a bulletproof enemy is encountered, stop scanning the rest of the cast
		# ie. penetrate all enemies that are not bulletproof
		# right now, each raycast scans collision layer 1 (walls) and 5 (entity layer)
		for raycast in killcasts.get_children():
			# right now raycasts can only detect the first colliding object.
			# we scan first object, add it as excpetion, and force raycast update until
			# it is no longer colliding with anything.
			while raycast.is_colliding():
				var body = raycast.get_collider()
				if body.is_in_group("Bulletproof") or body is TileMap:
					# bulletproof entity or wall/floor
					# play collision sound
					
					# stop scanning
					break
				elif body.is_in_group("Enemy"):
					# non-bulletproof enemy: all enemies have kill function
					body.kill()
				
				# bullet passes through: ignore the body from now on
				raycast.add_exception(body)
				# update raycast for next iteration
				raycast.force_raycast_update()
			# done scanning for this raycast: clear its exceptions
			raycast.clear_exceptions()
		# shooting effect
		add_effect(self, boomstick_effect.apply, boomstick_effect.remove, 1, 1, true, false)
	
