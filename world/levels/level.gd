# apr 26 2024
# abstract level class
# contains data for borders, subclasses may have data for statuses like
# if an item has been collected or if a boss has been killed

extends Node

class_name Level

# borders (default values)
@export var top_y : int = -88
@export var bottom_y : int = 88
@export var left_x : int = 160
@export var right_x : int = -160

@export var top_path : String = ""
@export var bottom_path : String = ""
@export var left_path : String = ""
@export var right_path : String = ""

@onready var adjacent = {
	"top" : load(top_path),
	"bottom" : load(bottom_path),
	"left" : load(left_path),
	"right" : load(right_path),
}

func _ready():
	print("ready")
	# attempt to instantiate each adjacent node
	for key in adjacent:
		print("instantiating")
		if adjacent[key]:
			# non null
			adjacent[key] = adjacent[key].instantiate()
		else:
			# path doesn't exist: keep it null
			pass

func _process(delta):
	pass

