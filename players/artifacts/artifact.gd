# dieter whittingham
# may 30 2024
# artifact class (abstract interface)
# for artifact resource

extends Resource

class_name Artifact

enum Type {
	RELIC,
	ARTIFACT
}

@export var type : Type
@export var id : String
@export var name : String
@export_multiline var description : String
@export_file var icon8 : String # path to 8px icon resource
@export_file var icon32 : String # path to 32 px icon resource
@export var equippable : bool
@export_file var player_scene_path : String # path to associated player scene (decorator)
