# dieter whittingham
# May 31 2024
# test tower

# test tower using matrix representation system

extends Tower

func _init():
	# constructor
	_id = 0
	_name = "Test Tower"
	_prefix = "res://world/towers/test-tower/levels/0-"
	# define matrix (y, x)
	# lower y index is UP IN GAME
	_level_matrix = \
	[ 	# "  " indicates no level
		# testing with a 5x3 matrix
		["  ", "  ", "  ", "05", "  "],
		["  ", "03", "04", "05", "  "],
		["01", "02", "02", "  ", "  "],
	]
	_height = len(_level_matrix)
	_width = len(_level_matrix[0])
	


