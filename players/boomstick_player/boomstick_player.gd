# dieter whittingham
# june 1st 2024
# boomstick_player.gd

extends ReworkedDefaultController

# var direction2d = Vector2.ZERO
const RECOIL_VELOCITY = 240
const COOLDOWN_FRAMES = 45 # cooldown time in frames
var cooldown_timer = 0
@onready var pellets : PackedScene = preload("res://players/boomstick_player/boomstick_pellets.tscn")
@onready var killcasts = $KillCasts

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
	check_shoot()
	# move and slide
	move_and_slide()

# shoots pellets, killing all non-bulletproof enemies
# currently shoots left and right with 25 deg spread
# applies recoil in opposite direction.
# need to add cooldown, for now just shoots infinite amount
func check_shoot():
	if cooldown_timer > 0:
		# sitll on cooldown
		cooldown_timer -= 1
	elif Input.is_action_just_pressed("special") and cooldown_timer == 0:
		# set recoil to opposite current x facing direction
		var recoil_direction = -transform.x.x
		# apply recoil
		velocity.x = RECOIL_VELOCITY * recoil_direction
		# restarting using subemitters doesn't work: need to resort to adding child scene
		var new_pellets = pellets.instantiate()
		add_child(new_pellets)
		new_pellets.emitting = true
		# set cooldown
		cooldown_timer = COOLDOWN_FRAMES
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
		# lastly delete new pellets after 1 second
		await get_tree().create_timer(1.0).timeout
		remove_child(new_pellets)
	
