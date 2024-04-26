# apr 25 2024
# level_border.gd
# level border controls how levels move from one to the next

extends Node

# filepath to next level
@export var next_level_path : String = ""
# name of target matching border
@export var next_border_name : String = ""
# top, bottom, left, right
@export var type : String = ""
@onready var level_manager = get_node("/root/LevelManager")
@onready var next_level : Node = load(next_level_path).instantiate()
@onready var next_border : Node = next_level.find_child(next_border_name)

# no collision shape 2d: in level editor, make local then add to get custom shape

# Called when the node enters the scene tree for the first time.
func _ready():
	'''
	if next_level_path == "":
		print("level border not connected to another level")
	if next_border_path == "":
		print("level border not connected to another border")
		'''
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# check that player exited AND is out of bounds
# bounds checked based on if it's top, bottom, left, right
func _on_area_2d_body_exited(body):
	print("exited")
	if body.is_in_group("Player"):
		print("player crossed border")
		# want to signal to level manager to switch scenes
		# may switch signaling to singleton, for now use level manager
		level_manager.border_cross(self)


func _on_area_2d_body_entered(body):
	print("kill yourself")
