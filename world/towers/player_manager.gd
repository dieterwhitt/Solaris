# dieter whittingham
# june 3 2024
# player_manager.gd

# handles player as a child to level manager
# artifact swap, changing player, set equipped artifacts

extends Node

# null -> use default player
var active_artifact : Artifact = null
var backup_artifact : Artifact = null
@onready var level_manager : Node = get_parent()

# on swap:
# switch active and backup artifact
func _physics_process(delta):
	# check swap
	if Input.is_action_just_pressed("swap-artifact"):
		print("swapping artifacts")
		var temp = active_artifact
		active_artifact = backup_artifact
		backup_artifact = temp
		update_player()

# change "player" node in parent
# instantiate new player and update initial data
# transfer position, velocity, used double jump, dash status, 
# drop status, coyote & buffer status
# remove cam transform child from player and free current player
# play player "pullout" animation
# re-calibrate camera
# possibly: give an i frame
func update_player():
	print("updating player scene")
	var player_path = ""
	if active_artifact:
		# artifact is defined
		player_path = active_artifact.playerScenePath
	else:
		player_path = "res://players/player_reworked/player_reworked.tscn"
	# instantiate
	var new_player = load(player_path).instantiate()
	var old_player = level_manager.player
	if old_player:
		new_player.position = old_player.position
		new_player.velocity = old_player.velocity
		new_player.used_double_jump = old_player.used_double_jump
		new_player.dashing = old_player.dashing
		new_player.dash_stopping = old_player.dash_stopping
		new_player.dash_timer = old_player.dash_timer
		new_player.dash_friction_timer = old_player.dash_friction_timer
		new_player.dash_friction = old_player.dash_friction
		new_player.current_coyote = old_player.current_coyote
		new_player.current_jump_buffer = old_player.current_jump_buffer
		new_player.drop_timer = old_player.drop_timer
		# in the future: also transfer temporary movedata multipliers
		# detach camera transform and free old player
		old_player.remove_child(level_manager.cam_transform)
		old_player.queue_free()
	# update player
	level_manager.add_child(new_player)
	level_manager.player = new_player
	# in the future: play player pull out animation
	# calibrate camera
	level_manager.calibrate_camera
	
	
	

# set equipped artifacts
func set_artifacts(a1 : Artifact, a2 : Artifact):
	pass

