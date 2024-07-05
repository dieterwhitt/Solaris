# dart.gd

# script for dart
# passes through walls

# "collide" animation? could use particles as well

extends CharacterBody2D

@onready var timer = $Timer
var top_speed = 60
const ACCEL_FACTOR = 25

func _ready():
	# kill on timer timeout (autostarted)
	await timer.timeout
	kill()

func _physics_process(delta):
	# very light acceleration to player
	var player_accel = Vector2.ZERO
	var level_manager = get_node("/root/LevelManager")
	if level_manager:
		var player = level_manager.player
		if player:
			# aim at players stomach, not chest
			var to_player = \
				self.position.direction_to(player.position + Vector2(0, 6))
			# only accel when velocity and player within 120 deg
			# print(rad_to_deg(velocity.angle_to(to_player)))
			if abs(rad_to_deg(velocity.angle_to(to_player))) <= 60:
				player_accel = to_player
	# adjust velocity
	velocity += player_accel * ACCEL_FACTOR * delta
	velocity = velocity.normalized() * top_speed
	# set rotation (look at)
	look_at(global_position + velocity)
	move_and_slide()

func kill():
	# end dart (collide/timeout animation)
	# hide, free killbox, stop emitting, particle burst, then free after a few moments
	# for now just free
	queue_free()
