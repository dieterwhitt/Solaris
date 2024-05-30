# dieter whittingham
# may 30 2024
# artifact class (abstract interface)
# for artifact resource

extends Resource

class_name Artifact

@export var id : int
@export var name : String
@export var description : String
@export var icon16 : String # path to 16px icon
@export var icon64 : String # path to 64 px icon
@export var playerScenePath : String # path to associated player scene
