# dieter whittingham
# may 31 2024
# tower.gd

# tower class (abstract)

extends Resource

class_name Tower

# todo: add background specification
# so level manager knows what background each level should have

# all variables must be defined in subclass
var _id : int
var _name : String
# level filepath prefix (.../levels/{id}-)
var _prefix : String
# level matrix: lower y index indicates UP!!!!
# ex. (2,2) -> up -> (2, 1)
var _level_matrix : Array[Array] # (row, col)
# level matrix height and width
var _height : int
var _width : int
var _backgrounds : Dictionary # background scene : [level ids]
var _locations: Dictionary # level id of new location : location name 

func _init(): # init instead of _ready() since it's resource derived
	pass

