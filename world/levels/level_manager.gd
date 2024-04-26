# apr 26 2024
# level manager - manages levels and player

extends Node

# starting the system, need to fix it to make it better
# good start though

# loaded scenes (deleted on checkpoint)
# path (string) : node
# keep all the loaded levels in here so that we aren't loading things twice
var loaded = {}
# current level path
@onready var curr_path : String = "res://world/levels/level_02.tscn"
# current scene
@onready var current : Node = \
	load(curr_path).instantiate()
# player
@onready var player : Node = \
	preload("res://players/player_reworked/player_reworked.tscn").instantiate()

func _ready():
	# read save file and adjust current, checkpoint
	start_current_level()
	add_child(player)
	spawn_player_default()

# starts the current level by adding it to the tree and loading its
# adjacent levels. does NOT spawn player
func start_current_level():
	if curr_path not in loaded:
		loaded.merge({curr_path : current})
	# now add current to tree
	add_child(current)
	for border in current.adjacent:
		# border: top, bottom, left, right
		var adj_path : String = current.adjacent[border]
		if adj_path != "" and adj_path not in loaded:
			print("attempting to load " + adj_path)
			# if path was given and hasn't been loaded
			var packed_lvl : PackedScene = load(adj_path)
			if packed_lvl:
				loaded.merge({adj_path : packed_lvl.instantiate()})
				print("level loaded")
			else:
				print("level not found")

# spawns the player in the default spawnpoint
func spawn_player_default():
	var spawnpoint = current.get_node("Spawn").position
	player.position = spawnpoint
	
func _process(delta):
	check_borders()
	
# check if the player is out of bounds
# for now we are limited to single screen levels
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
	

# function for entering a border
func enter_border(level : Node, posn : Vector2):
	print("crossing level border")
	remove_child(current)
	current = level
	start_current_level()
	# move player
	player.position = posn
