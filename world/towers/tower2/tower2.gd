# dieter whittingham
# tower 2

extends Tower

func _init():
	# constructor
	_id = 0
	_name = "Tower 2 Placeholder Name"
	_prefix = "res://world/towers/tower2/levels/2-"
	# define matrix (y, x) 
	# lower y index is UP IN GAME
	_level_matrix = \
	[ 	# "  " indicates no level (player dies upon entering)
		["  ", "  ", "  "],
		["  ", "  ", "  "],
		["  ", "  ", "  "],
		["  ", "  ", "  "],
		["  ", "  ", "  "],
		["  ", "03", "  "],
		["  ", "02", "  "],
		["  ", "02", "  "],
		["  ", "01", "  "],
	]
	_height = len(_level_matrix)
	_width = len(_level_matrix[0]) 
