# dieter whittingham
# may 30 2024
# artifact class (abstract interface)
# for artifact resource

extends Resource

class_name Artifact

@export var id : String
@export var name : String
@export_multiline var description : String
@export_file var icon8 : String # path to 16px icon resource
@export_file var icon64 : String # path to 64 px icon resource
@export var equippable : bool
@export_file var playerScenePath : String # path to associated player scene
