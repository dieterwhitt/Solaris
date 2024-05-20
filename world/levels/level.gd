# apr 26 2024
# abstract level class
# contains data for borders, subclasses may have data for statuses like
# if an item has been collected or if a boss has been killed

'''
PLEASE READ!!!
level.gd is a base script for a level.
it is an ABSTRACT class meant to be inherited by an individual level's script
it dictates the level's borders and the filepaths of adjacent levels (scenes).
these can be edited in the inspector (export variables) for easy level linking
i got the idea for this structure after doing some graph problems on leetcode :)

important things that haven't been implemented yet:
	- larger screens/camera controls: right now the camera is static on
	every level. we'll need to add camera movement for levels that are 
	2+ screens long or 2+ screens tall.
	- multiple borders: for large levels (rooms), you might want
	to have two levels share a long border. this isn't supported yet.
	right now this structure only supports single-screen levels.

Another important thing: any levels with unique level mechanics (ex. boss fight)
will have to handle their logic in their respective level scripts,
NOT in this file and NOT in level_manager

DOCUMENTATION FOR LEVEL_TEMPLATE
this is the documentation for the level_template scene
please communicate when you modify abstract things like classes
that are inherited by a lot of scripts or scene templates

also the structure for Level_00 - Level_04 are outdated as they were
prototype levels. from now on use the level template.

Layers: the level template is separated into layers from back to front;
-2 (backgrounds), -1 (level), 0 (player layer ONLY), +1 (foreground)
note* HUD (+2) and Player (0) are to be handled in level_manager.
OUTDATED AS OF MAY 19 - SEE DESIGN DOC

Borders: the border objects that enclose the world. may be toggled
to block the player from passing through. blocks entities by default
labels are to indicate in editor what levels are adjacent in which direction.

Camera2D: the level's camera

Tilemaps: the tilemaps for the level. includes layout tiles, deco tiles,
and scene tiles for 0/90/180/270 degrees. scene tiles are for static scenes like spikes,
allowing you to easily paint spikes in the editor. the only problem is that
scene tiles can't be rotated, which is why we have 4 scene tilemaps for each 90 degree
rotation

LevelObjects: any other level objects like dash orbs, collectibles, whatever

Entities: any moving scene, with its own logic. ex. enemies, npcs, etc.

again lmk if you have any questions. Thanks for taking the time to read this info
- dieter whittingham
'''

extends Node

class_name Level

# need to update for multi-screen levels

# reworked may 19 2024

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

# rework:

const SCREEN_WIDTH = 320
const SCREEN_HEIGHT = 180

# whether level contains checkpoint
@export var checkpoint = false

# width and height default values (# of screens)
# must be > 0
@export var width = 1
@export var height = 1

# below: arrays of strings (filepaths to levels)

# left to right
# these arrays must have length (width)
# empty string means no connection
@export var top_paths : Array[String] = [""]
@export var bottom_paths : Array[String] = [""]

# top to bottom
# these arrays must have length (height)
@export var left_paths : Array[String] = [""]
@export var right_paths : Array[String] = [""]

@onready var adjacent0 = {
	"top" : top_paths,
	"bottom" : bottom_paths,
	"left" : left_paths,
	"right" : right_paths,
}

@onready var borders = {
	"top" : 0, # y = 0
	"bottom" : height * SCREEN_HEIGHT,
	"left" : 0, # x = 0
	"right" : width * SCREEN_WIDTH,
}

func _ready():
	print("current level: " + name)
	print(adjacent)

func _process(delta):
	pass

# returns the current screen segment of posn as a vector2 [x, y]
# if out of bounds, return the nearest screen
# i.e clamp x and y to the borders of the room
func get_posn_screen(posn : Vector2) -> Vector2:
	return Vector2.ZERO

# given a filepath from the adjacent levels dictionary, and a screen in the
# current level, return the corresponding screen in the NEW level
# need to determine length of shared border and how far along the border the
# current screen is, then find the corresponding screen in the next level
# that is equally far along
# leetcode medium-hard?
# also maybe this should be done in level_manager instead since it involves 2 levels
func get_dest_screen(path : String) -> Vector2:
	return Vector2.ZERO

# returns the x coordinate relative to its screen segment
# gives an error if x is out of bounds
func get_relative_x(x) -> int:
	return 0

# returns the y coordinate relative to its screen segment
# error if y is out of bounds
func get_relative_y(y) -> int:
	return 0

# given a screen's relative coordinates and a screen destination,
# return the coordinates to that screen.
# ex. adjust_coords([0, 0], [2, 1]) -> [320, 0]
# i.e top left corner (origin) on screen [2, 1] is located at [320, 0]
func adjust_coords(posn : Vector2, screen : Vector2) -> Vector2:
	return Vector2.ZERO
