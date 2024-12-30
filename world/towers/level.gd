# apr 26 2024
# abstract level class
# contains data for borders, subclasses may have data for statuses like
# if an item has been collected or if a boss has been killed

extends Node

class_name Level

# reworked may 19 2024

# rework:

const SCREEN_WIDTH : int = 320
const SCREEN_HEIGHT : int = 180

# whether level contains checkpoint
@export var checkpoint = false

# width and height default values (# of screens)
# must be > 0
@export var width : int = 1
@export var height : int = 1

@onready var borders = {
	"top" : 0, # y = 0
	"bottom" : height * SCREEN_HEIGHT,
	"left" : 0, # x = 0
	"right" : width * SCREEN_WIDTH,
}

func _ready():
	print("level added to tree for the first time: " + name)

# returns the current screen segment of posn as a vector2 [x, y]
# relative to top left screen (0,0)
# if out of bounds, return the nearest screen
# i.e clamp x and y to the borders of the room
func get_screen(posn : Vector2) -> Vector2:
	var screen = Vector2.ZERO
	
	screen.x = posn.x / SCREEN_WIDTH
	screen.y = posn.y / SCREEN_HEIGHT
	# clamp & floor
	screen.x = floor(clamp(screen.x, 0, width - 1))
	screen.y = floor(clamp(screen.y, 0, height - 1))
	
	return screen

# returns the x coordinate relative to its screen segment
# gives an error if x is out of bounds
func get_relative_x(x):
	assert(borders["left"] <= x and x <= borders["right"])
	var diff = x - int(x)
	return (int(x) % SCREEN_WIDTH) + diff

# returns the y coordinate relative to its screen segment
# error if y is out of bounds
func get_relative_y(y):
	assert(borders["top"] <= y and y <= borders["bottom"])
	var diff = y - int(y)
	return (int(y) % SCREEN_HEIGHT) + diff

# given a screen's relative coordinates and a screen destination,
# return the coordinates to that screen.
# ex. adjust_coords([0, 0], [1, 0]) -> [320, 0]
# i.e top left corner (origin) on screen [1, 0] is located at [320, 0]
func adjust_coords(posn : Vector2, screen : Vector2) -> Vector2:
	return Vector2(posn.x + (screen.x * SCREEN_WIDTH), \
			posn.y + (screen.y * SCREEN_HEIGHT))
