# apr 26 2024
# abstract level class
# contains data for borders, subclasses may have data for statuses like
# if an item has been collected or if a boss has been killed

extends Node

class_name Level

# borders (default values)
@export var top_y : int = 0
@export var bottom_y : int = 180
@export var left_x : int = 0
@export var right_x : int = 320

@export var top_path : String = ""
@export var bottom_path : String = ""
@export var left_path : String = ""
@export var right_path : String = ""

@onready var adjacent = {
	"top" : top_path,
	"bottom" : bottom_path,
	"left" : left_path,
	"right" : right_path,
}

func _ready():
	print("current level: " + name)
	print(adjacent)

func _process(delta):
	pass

