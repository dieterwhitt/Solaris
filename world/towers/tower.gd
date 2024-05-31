# dieter whittingham
# may 31 2024
# tower.gd

# tower class (abstract)

extends Resource

class_name Tower

# all variables must be defined in subclass
var _id : int
var _name : String
# level filepath prefix (.../levels/{id}-)
var _prefix : String
# level matrix: lower y index indicates UP!!!!
# ex. (2,2) -> up -> (1, 2)
var _level_matrix : Array[Array] # (y, x)
var _start : Vector2 # start position (must have checkpoint) (y, x)

func _init(): # init instead of _ready() since it's resource derived
	pass

