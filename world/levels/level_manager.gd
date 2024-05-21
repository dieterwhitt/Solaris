# apr 26 2024
# level manager - manages levels and player

extends Node

'''
PLEASE READ!!!
level_manager.gd is responsible for controlling the changing of levels and 
managing the player.
By copying the level_template scene, you'll be able to create levels,
and this file controls loading & switching between them

as of may 6 2024:
level_manager:
	- loads levels
	- moves the player across levels when they exit the screen
	- spawns the player in on intial load

level_manager DOES NOT YET:
	- handle player powerup scenes
	- save checkpoints and respawn player on death

(the unadded features above will be necessary but I 
haven't implemented them yet)

If you have any questions dm me on discord.
- dieter whittingham
'''

# this will probably be the longest file in the game
# needs to control level switching, player position/scene, and camera
# maybe try splitting them into 3 files? idk if its worth it unless this file
# goes >1000 lines
# also a lot of stuff will need to be read from a save file like
# current spawn, spawnpoints visited, active player, etc.

# loaded scenes (deleted on checkpoint)
# keep all the loaded levels in here so that we aren't loading things twice
# path (string) : node
var loaded = {}
# current level path
var current_path : String = ""
# current level checkpoint path
# intial value: starting spawn point
var spawn_path : String = "res://world/levels/long_level_00.tscn"
# current scene being rendered
var current : Node = null
# active player and other available players (not implemented yet)
var active_player : String = "res://players/player_reworked/player_reworked.tscn"
# player
var player : Node = null

# new - camera settings
var camera : Camera2D = Camera2D.new()
# to control camera movement
var cam_transform : RemoteTransform2D = RemoteTransform2D.new()

# number of invincibility frames on scene change
var invince_frames = 1
var invince_timer = 0

func _ready():
	# read save file and adjust current, checkpoint
	respawn_player()
	# initialize camera settings
	initialize_camera()
	# calibrate camera according to current level
	calibrate_camera()

# one-time initialization of camera
func initialize_camera():
	add_child(camera)
	camera.name = "Camera" # rename camera in tree
	# enable smoothing (or maybe not? it's kinda buggy)
	# probably will need to add some kind of damping eventually
	# to make it less jarring
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.limit_smoothed = false
	# connect camera control to camera
	cam_transform.remote_path = camera.get_path()
	print("connecting remote transform to camera")

# calibrating camera settings for the current level
func calibrate_camera():
	# attach camera control to player
	if cam_transform not in player.get_children():
		print("adding remote camera transform to player")
		player.add_child(cam_transform)
	# set camera drag margins & limits
	# current level dimensions must be considereed
	camera.limit_left = current.borders["left"]
	camera.limit_right = current.borders["right"]
	camera.limit_top = current.borders["top"]
	camera.limit_bottom = current.borders["bottom"]

# starts the current level by adding it to the tree and loading its
# adjacent levels. does NOT spawn player
func start_current_level():
	# now add current to tree
	add_child(current)
	# now we want to load all adjacent levels (smooth transitions)
	# below: reworked may 20 - multi screen levels rework
	for direction in current.adjacent0:
		for adj_path in current.adjacent0[direction]:
			if adj_path != "" and adj_path not in loaded:
				print("attempting to load " + adj_path)
				# if path was given and hasn't been loaded
				var packed_lvl : PackedScene = load(adj_path)
				if packed_lvl:
					loaded.merge({adj_path : packed_lvl.instantiate()})
					print("level loaded")
				else:
					print("level not found")

# spawns/respawns player
func respawn_player():
	# rework:
	# free player, then create new player based on active player path
	if player:
		player.queue_free()
	player = load(active_player).instantiate()
	# delete all loaded scenes and switch current scene to checkpoint
	for level in loaded:
		loaded[level].queue_free()
	loaded = {}
	if current:
		current.queue_free()
	# load new current
	current = load(spawn_path).instantiate()
	current_path = spawn_path
	loaded.merge({spawn_path : current})
	# start current scene
	var Spawn = current.get_node("Spawn")
	start_current_level()
	# load in player
	if Spawn:
		player.position = Spawn.position
		invince_timer = invince_frames
		add_child(player)
	else:
		print("spawn point not found, unable to spawn player")
	

func _physics_process(delta):
	update_invincibility()
	check_borders()

func update_invincibility():
	if invince_timer > 0:
		invince_timer -= 1
		print("i frame")
		if invince_timer == 0:
			# re-enable player
			player.set_collision_layer_value(2, true)
			player.set_collision_mask_value(1, true)
			player.set_physics_process(true)
			
# warning: basically all of the code below is fucking cancer (i tried my best)
# probably just shouldnt even touch it tbh
'''
# check if the player is out of bounds
func check_borders():
	var posn = player.position
	# you want to keep the position in the dimension that remains unchanged
	# also need to fix this kinda shitty code
	if posn.y < current.top_y:
		# over top border
		if current.adjacent["top"] in loaded:
			# string key exists in loaded dict
			var top_lvl = loaded[current.adjacent["top"]]
			enter_border(top_lvl, 
					Vector2(posn.x, top_lvl.bottom_y))
	elif posn.y > current.bottom_y:
		# below bottom border
		if current.adjacent["bottom"] in loaded:
			var btm_lvl = loaded[current.adjacent["bottom"]]
			enter_border(btm_lvl, 
					Vector2(posn.x, btm_lvl.top_y))
	elif posn.x < current.left_x:
		# left of left border
		if current.adjacent["left"] in loaded:
			var lft_lvl = loaded[current.adjacent["left"]]
			enter_border(lft_lvl, 
					Vector2(lft_lvl.right_x, posn.y))
	elif posn.x > current.right_x:
		# right of right border
		if current.adjacent["right"] in loaded:
			var right_lvl = loaded[current.adjacent["right"]]
			enter_border(right_lvl, 
					Vector2(right_lvl.left_x, posn.y))
'''
# check borders reworked
# get current screen, find target position, find target screen, adjust screen, insert player
func check_borders():
	var posn = player.position
	var screen = current.get_screen(posn)
	var target_data = get_target_posn(screen)
	if not target_data[0]:
		# player is in bounds
		return
	else:
		# player went out of bounds
		if target_data[1] == "":
			# no level connected
			print("no level path to change to")
		elif target_data[1] not in loaded:
			print("error: path specified was never loaded - check spelling")
		else:
			var target_screen = get_dest_screen(current_path, target_data[1], screen)
			var insert_posn = current.adjust_coords(target_data[0], target_screen)
			print("crossing border")
			enter_border(target_data[1], insert_posn)

# gets target position (relative to target screen) and path
# if player is out of bounds
# returns null target if player is not out of bounds
# screen is to determine what the target level is
func get_target_posn(screen : Vector2): # [relative coords, level path]
	var target = Vector2.ZERO
	var level = ""
	var posn = player.position
	if posn.x < current.borders["left"]:
		# left of left border (spawn on right side)
		target.x = current.SCREEN_WIDTH
		target.y = current.get_relative_y(posn.y)
		level = current.adjacent0["left"][screen.y]
	elif posn.x > current.borders["right"]:
		# right of right border (spawn on left side)
		target.x = 0
		target.y = current.get_relative_y(posn.y)
		level = current.adjacent0["right"][screen.y]
	elif posn.y < current.borders["top"]:
		# above top border (spawn on bottom)
		target.x = current.get_relative_x(posn.x)
		target.y = current.SCREEN_HEIGHT
		level = current.adjacent0["top"][screen.x]
	elif posn.y > current.borders["bottom"]:
		# below bottom border (spawn on top)
		target.x = current.get_relative_x(posn.x)
		target.y = 0
		level = current.adjacent0["bottom"][screen.y]
	else:
		target = null
	return [target, level]
	
# function for entering a border
func enter_border(path : String, posn : Vector2):
	print("crossing level border")
	# possible future improvement: short timer (like 2s) to keep running before removal
	# so stuff like moving platforms still run for a moment off screen
	remove_child(current)
	# move player
	player.position = posn
	
	# need to disable collision layer (invincibility frame on scene change)
	# this also avoids bugs with 1-frame misalignment, so 
	# you don't die to a spike on the other side when you change levels
	# also MAKE SURE TO EXTEND LEVELs BY 1 TILE AT EDGES TO HELP PREVENT CLIPPING
	# OUT OF THE WORLD!
	player.set_collision_layer_value(2, false)
	player.set_collision_mask_value(1, false)
	# freeze physics during i frame to prevent clipping
	player.set_physics_process(false)
	invince_timer = invince_frames
	
	current = loaded[path]
	current_path = path
	
	start_current_level()
	calibrate_camera()
	print("adding player at %v" % posn)
	
	
# given a filepath from the adjacent levels dictionary, and a screen in the
# from level, return the corresponding screen in the dest level
# need to determine length of shared border and how far along the border the
# from screen is, then find the corresponding screen in the dest level
# that is equally far along
# requires screen to be on the border and for its corresponding border level and
# they both have to be loaded
# to match path
# leetcode medium-hard? were gonna need to test like crazy
func get_dest_screen(from_path : String, dest_path : String, screen : Vector2) -> Vector2:
	var from = loaded[from_path]
	var dest = loaded[dest_path]
	# how far along the shared border the screen is
	var border_position_from = 0
	var found = false
	# current screen as we scan the edge
	var current_screen = Vector2.ZERO
	# edge data: border key, starting screen, scan direction
	var edges_from = [["left", Vector2.ZERO, "down"], 
			["right", Vector2(from.borders["right"], 0), "down"], 
			["top", Vector2.ZERO, "right"], 
			["bottom", Vector2(0, from.borders["bottom"]), "right"]]
	for edge in edges_from:
		current_screen = edge[1]
		for adj in from.adjacent0[edge[0]]:
			if adj == from_path:
				# match found
				border_position_from += 1
				# check if screen matches
				if current_screen == screen:
					# found correct border position
					found = true
					break
				else:
					# update current screen based on scan direction
					if edge[2] == "down":
						current_screen.y += 1
					elif edge[2] == "right":
						current_screen.x += 1
		# break nested loop
		if found:
			break
	
	# we now have the position on the shared border of our screen (starting at 1)
	# now need to scan dest for that same position
	# cancer, i actually dont know how to refactor this code
	var border_position_dest = 0
	found = false
	var edges_dest = [["left", Vector2.ZERO, "down"], 
			["right", Vector2(dest.borders["right"], 0), "down"], 
			["top", Vector2.ZERO, "right"], 
			["bottom", Vector2(0, dest.borders["bottom"]), "right"]]
	for edge in edges_dest:
		current_screen = edge[1]
		for adj in dest.adjacent0[edge[0]]:
			if adj == dest_path:
				# match found
				border_position_dest += 1
				# check if border position matches
				if border_position_dest == border_position_from:
					# found correct border position
					found = true
					break
				else:
					# update current screen based on scan direction
					if edge[2] == "down":
						current_screen.y += 1
					elif edge[2] == "right":
						current_screen.x += 1
		# break nested loop
		if found:
			break
	# current screen should be the screen in dest that has the same shared border
	# position as the screen given as the parameter
	return current_screen

