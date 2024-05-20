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

