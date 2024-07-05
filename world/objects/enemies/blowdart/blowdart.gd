# blowdart.gd

extends CharacterBody2D

const DART_SPEED = 60

var player_direction = Vector2(1, 0) # relative to self
@onready var timer = $Timer
@onready var spawn = $Spawn
@onready var dart : PackedScene = preload("res://world/objects/enemies/blowdart/dart.tscn")
var aggro : bool = false
# detection/aggro angle: 30-180
# animated angles: 15, 30, 45, 60, 75

func _ready():
	check_timer()
	timer.wait_time = 3 # set wait time after first shot

func _physics_process(delta):
	update_player_direction()
	flip()
	# apply gravity
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	move_and_slide()

# function called once, stays in a loop awaiting timeout. shoots when times out.
func check_timer():
	while(true):
		await timer.timeout
		shoot()

func update_player_direction():
	# update player position
	var level_manager = get_node("/root/LevelManager")
	if level_manager:
		var player = level_manager.player
		if player:
			player_direction = self.position.direction_to(player.position)
			# get angle to player and update aggro accordingly
			var angle_to_player = rad_to_deg(self.position.angle_to_point(player.position))
			# print(angle_to_player)
			if (abs(angle_to_player) <= 60) or (abs(angle_to_player) >= 120):
				# 30-150, 210-330
				# and ray cast does not collide with a wall
				aggro = true
				timer.paused = false
			else:
				timer.paused = true
				

func flip():
	if player_direction.x < 0:
		transform.x.x = -1
	else:
		transform.x.x = 1

func shoot():
	# instantiate sibling dart
	var dart = dart.instantiate()
	add_sibling(dart)
	# set dart velocity and position
	dart.global_position = spawn.global_position
	dart.velocity = player_direction * DART_SPEED
	dart.top_speed = DART_SPEED
	
