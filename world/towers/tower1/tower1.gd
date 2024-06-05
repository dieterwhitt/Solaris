# dieter whittingham
# June 5 2024
# tower 1

extends Tower

func _init():
	# constructor
	_id = 0
	_name = "Tower 1 Placeholder Name"
	_prefix = "res://world/towers/tower1/levels/1-"
	# define matrix (y, x) 
	# lower y index is UP IN GAME
	_level_matrix = \
	[ 	# "  " indicates no level
		# testing with a 5x3 matrix
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "11", "12"],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "09", "10", "  "],
		["  ", "  ", "  ", "04", "05", "06", "07", "08", "  ", "  "],
		["01", "02", "03", "03", "  ", "  ", "  ", "  ", "  ", "  "],
	]
	_height = len(_level_matrix)
	_width = len(_level_matrix[0])
