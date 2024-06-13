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
	[ 	# "  " indicates no level (player dies upon entering)
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "23", "28"],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "20", "21", "22", "23", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "20", "26", "22", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "20", "25", "27", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "24", "19", "  ", "  ", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "18", "15", "14", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "16", "14", "17", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "16", "14", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "12", "13", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "  ", "09", "10", "11", "  ", "  ", "  "],
		["  ", "  ", "  ", "  ", "  ", "  ", "07", "08", "  ", "  ", "  ", "  ", "  "],
		["  ", "  ", "  ", "04", "05", "06", "06", "  ", "  ", "  ", "  ", "  ", "  "],
		["01", "02", "03", "03", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "],
	]
	_height = len(_level_matrix)
	_width = len(_level_matrix[0])
