# dieter whittingham
# june 3 2024
# player_manager.gd

# handles player as a child to level manager
# artifact swap, changing player, set equipped artifacts

extends Node

# null -> use default player
var active_artifact : Artifact = null
var backup_artifact : Artifact = null

# on swap:
# switch active and backup artifact
func _physics_process(delta):
	# check swap
	if Input.is_action_just_pressed("swap-artifact"):
		var temp = active_artifact
		active_artifact = backup_artifact
		backup_artifact = temp
		update_player()

# change "player" node in parent
# remove cam transform child from player and free current player
# instantiate new player and update initial data
# re-calibrate camera
# possibly: give an i frame
func update_player():
	pass

# set equipped artifacts
func set_artifacts(a1 : Artifact, a2 : Artifact):
	pass

