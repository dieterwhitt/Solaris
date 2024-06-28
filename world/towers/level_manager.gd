# apr 26 2024
# level manager - manages levels and player

extends Node

'''
PLEASE READ!!!
level_manager.gd is responsible for controlling the changing of levels and 
managing the player.
By copying the level_template scene, you'll be able to create levels,
and this file controls loading & switching between them

level_manager:
	- loads levels
	- moves the player across levels when they exit the screen
	- spawns the player in on intial load
	- handle player powerup scenes
	- save checkpoints and respawn player on death
'''

# this will probably be the longest file in the game
# needs to control level switching, player position/scene, and camera
# child node - player manager - will handle switching player
# and keeping track of which artifacts are collected
# in a different file to improve readability

# loaded scenes (deleted on checkpoint)
# keep all the loaded levels in here so that we aren't loading things twice
# level id (string) : node
var loaded = {}
# current tower rewource
var tower : Tower = load("res://world/towers/tower1/tower1.gd").new()
var spawn_lvl : String = "54" # current spawn level id (checkpoint)
# kindling bonfires (setting checkpoints) not established yet (need checkpoint scene)
# for now just auto-set checkpoint when screen loads
# current scene being rendered
var current : Node = null
var current_lvl : String = "" # current level id
# active player and other available players (not implemented yet)
# switch to checking value in player manager instead
var active_player : String = "res://players/boomstick_player/boomstick_player.tscn"
var backup_player : String # other equipped powerup
# player (node)
# 
var player : Node = null

# new - camera settings
@onready var camera : Camera2D = Camera2D.new()
# to control camera movement
@onready var cam_transform : RemoteTransform2D = RemoteTransform2D.new()

# number of invincibility frames on scene change
var invince_frames = 1
var invince_timer = 0

# snapping camera
var camera_smooth_timer = 0
var camera_smooth_delay = 3

func _ready():
	# initialize camera settings
	initialize_camera()
	# read save file and adjust current, checkpoint
	respawn_player()

# one-time initialization of camera
func initialize_camera():
	add_child(camera)
	camera.name = "Camera" # rename camera in tree
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
	# teleport camera to avoid screen lag issue
	camera.position = player.position
	# apply limits of current level
	camera.limit_left = current.borders["left"]
	camera.limit_right = current.borders["right"]
	camera.limit_top = current.borders["top"]
	camera.limit_bottom = current.borders["bottom"]
	
	# reset smoothing
	camera.reset_smoothing()

# snaps camera to player
func snap_camera():
	camera.position_smoothing_enabled = false
	camera_smooth_timer = camera_smooth_delay


# starts the current level by adding it to the tree and loading its
# adjacent levels. does NOT spawn player
func start_current_level():
	# now add current to tree
	add_child(current)
	# check if it's a checkpoint to auto-set spawn (will change later)
	if current.checkpoint:
		spawn_lvl = current_lvl
		print("set new checkpoint: " + current_lvl)
	# now we want to load all adjacent levels (smooth transitions)

	# matrix rework, june 2:
	# for each screen in the level, check all 4 adjacent screens
	# if that screen is in the level matrix and not blank ("  ") and not
	# part of the current level, load it
	var matrix_posn = get_level_matrix_posn(current_lvl)
	for row in range(current.height):
		for col in range(current.width):
			var scan_posn = matrix_posn
			scan_posn.y += row
			scan_posn.x += col
			# scan all 4 adjacent
			load_lvl(Vector2(scan_posn.x - 1, scan_posn.y)) # left
			load_lvl(Vector2(scan_posn.x + 1, scan_posn.y)) # right
			load_lvl(Vector2(scan_posn.x, scan_posn.y - 1)) # up
			load_lvl(Vector2(scan_posn.x, scan_posn.y + 1)) # down

# loads level
# checks if in bounds & non blank & not already loaded
func load_lvl(matrix_posn : Vector2):
	if matrix_posn.x >= 0 and matrix_posn.x < tower._width and \
	matrix_posn.y >= 0 and matrix_posn.y < tower._height:
		var lvl_id = tower._level_matrix[matrix_posn.y][matrix_posn.x]
		# check non blank and not already loaded
		if lvl_id != "  " and lvl_id not in loaded:
			var packed_lvl : PackedScene = load(tower._prefix + lvl_id + ".tscn")
			if packed_lvl:
				loaded.merge({lvl_id : packed_lvl.instantiate()})
				print("level " + lvl_id + " loaded")
			else:
				print("level " + lvl_id + " not found")

# returns the (x, y) coordinates of a level in the level matrix
func get_level_matrix_posn(lvl_id : String):
	# get top left coordinates
	# levels can only be rectangles, so scan top to bottom left to right

	for y in range(tower._height):
		for x in range(tower._width):
			if tower._level_matrix[y][x] == lvl_id:
				return Vector2(x, y)
	# not found
	print("level " + lvl_id + " not found in " + tower._name)

# spawns/respawns player
func respawn_player():
	# rework:
	# free player, then create new player based on active player path
	# make sure to preserve cam transform
	if player:
		player.queue_free()
		player.remove_child(cam_transform)
	player = load(active_player).instantiate()
	# delete all loaded scenes and switch current scene to checkpoint
	for level in loaded:
		loaded[level].queue_free()
	loaded = {}
	# load new current
	print("loading respawn level " + spawn_lvl)
	current = load(tower._prefix + spawn_lvl + ".tscn").instantiate()
	current_lvl = spawn_lvl
	loaded.merge({spawn_lvl : current})
	# start current scene
	var Spawn = current.get_node("Spawn")
	start_current_level()
	# load in player
	if Spawn:
		player.position = Spawn.position
		invince_timer = invince_frames
		add_child(player)
		# calibrate camera for new room
		calibrate_camera()
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
			
# check borders reworked for matrix representation
# add some kind of error checking for going in blank levels so the game doesnt
# crash
func check_borders():
	var posn = player.position
	# check left, right, top, bottom border
	var target_posn_relative = Vector2.ZERO
	# direction of what screen to travel to on matrix
	var target_dir = Vector2.ZERO
	if posn.y < current.borders["top"]:
		target_dir.y = -1
		# keep relative x, set y to bottom of screen
		target_posn_relative = Vector2(current.get_relative_x(posn.x),
				 current.SCREEN_HEIGHT)
	elif posn.y > current.borders["bottom"]:
		target_dir.y = 1
		# keep relative x, set y to top of screen
		target_posn_relative = Vector2(current.get_relative_x(posn.x), 0)
	elif posn.x < current.borders["left"]:
		target_dir.x = -1
		# keep relative y, set x to left of screen
		target_posn_relative = Vector2(current.SCREEN_WIDTH, current.get_relative_y(posn.y),)
	elif posn.x > current.borders["right"]:
		target_dir.x = 1
		# keep relative y, set x to right of screen
		target_posn_relative = Vector2(0, current.get_relative_y(posn.y))
	
	# exited: now need to insert at correct position
	if target_dir != Vector2.ZERO:
		print("player exited level " + current_lvl)
		# current screen on level matrix
		var current_matrix_posn = \
				get_level_matrix_posn(current_lvl) + current.get_screen(posn)
		print("current matrix position: %v" % current_matrix_posn)
		# destination screen on level matrix
		var dest_matrix_posn = current_matrix_posn + target_dir
		print("target matrix position: %v" % dest_matrix_posn)
		# destination level id
		var dest_lvl_id = tower._level_matrix[dest_matrix_posn.y][dest_matrix_posn.x]
		print("target level: " + dest_lvl_id)
		# destination screen relative to destination level
		print(dest_matrix_posn)
		print(get_level_matrix_posn(dest_lvl_id))
		var target_local_screen = dest_matrix_posn - get_level_matrix_posn(dest_lvl_id)
		print("target screen: %v" % target_local_screen)
		# target position in target level
		var target_position = current.adjust_coords(target_posn_relative, target_local_screen)
		print("target position: %v" % target_position)
		
		# account for extra 4 pixls on screen - adjust
		# don't adjust on the same x level (only horizontal transitions)
		var current_local_y_screen = int(current.get_screen(posn).y)
		var target_local_y_screen = int(target_local_screen.y)
		if current_local_y_screen % 2 != target_local_y_screen % 2 and \
				current_matrix_posn.x != dest_matrix_posn.x:
			# misaligned screens
			if current_local_y_screen % 2 == 1:
				# odd to even: shift up 4 pixels
				print("shifting player up 4 pixels")
				target_position.y -= 4
			elif target_local_y_screen % 2 == 1:
				# even to odd: shift down 4 pixels
				print("shifting player down 4 pixels")
				target_position.y += 4		
		# insert player
		enter_border(dest_lvl_id, target_position)

# function for entering a border
func enter_border(lvl_id : String, posn : Vector2):
	print("crossing level border to level " + lvl_id)
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
	
	# fail safe: kill player on undefined levels
	if lvl_id == "  ":
		print("player entered undefined level")
		respawn_player()
	else:
		current = loaded[lvl_id]
		current_lvl = lvl_id
		
		start_current_level()
		calibrate_camera()
		print("adding player at %v" % posn)
