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
	[ 	# 00 indicates no level
		# testing with a 5x3 matrix
		[00, 02, 02, 05, 00],
		[00, 03, 04, 05, 00],
		[01, 02, 02, 00, 00],
	]
	


