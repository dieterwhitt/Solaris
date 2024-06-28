# dieter whittingham
# may 30 2024
# artifact class (abstract interface)
# for artifact resource

extends Resource

class_name Artifact

@export var id : String
@export var name : String
@export_multiline var description : String
@export_file var icon16 : String # path to 16px icon
@export_file var icon64 : String # path to 64 px icon
@export_file var playerScenePath : String # path to associated player scene
