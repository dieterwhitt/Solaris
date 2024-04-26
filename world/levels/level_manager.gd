# apr 26 2024
# level manager - manages levels and player

extends Node

# starting the system, need to fix it to make it better
# good start though

# loaded scenes (deleted on checkpoint)
var loaded = []
# current scene
@onready var current : Node = \
	preload("res://world/levels/level_02.tscn").instantiate()
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
	if current not in loaded:
		loaded.append(current)
	# now add current to tree
	add_child(current)
	for border in current.adjacent:
		# border: top, bottom, left, right
		var adj = current.adjacent[border]
		if adj and adj not in loaded:
			# if non-null and hasn't been loaded
			print("loaded level added to cache")
			loaded.append(adj)

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
	if posn.y < current.top_y:
		# over top border
		if current.adjacent["top"]:
			enter_border(current.adjacent["top"], 
					Vector2(posn.x, current.adjacent["top"].bottom_y))
	elif posn.y > current.bottom_y:
		# below bottom border
		if current.adjacent["bottom"]:
			enter_border(current.adjacent["bottom"], 
					Vector2(posn.x, current.adjacent["bottom"].top_y))
	elif posn.x < current.left_x:
		# left of left border
		if current.adjacent["left"]:
			enter_border(current.adjacent["left"], 
					Vector2(current.adjacent["left"].right_x, posn.y))
	elif posn.x > current.right_x:
		# right of right border
		if current.adjacent["right"]:
			enter_border(current.adjacent["right"], 
					Vector2(current.adjacent["right"].left_x, posn.y))
	

# function for entering a border
func enter_border(level, posn):
	print("crossing level border")
	remove_child(current)
	current = level
	start_current_level()
	# move player
	player.position = posn
