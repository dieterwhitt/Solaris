extends Node

var current_checkpoint: String = ""
var current_level: String = ""
var collected_artifacts: Array = []
var equipped_artifacts: Array = ["", ""]  # Two slots

const SAVE_PATH = "user://game_save.dat"
const ARTIFACTS_PATH = "res://world/artifacts/"  # Adjust this path as needed

var all_artifacts: Array = []

func _ready():
	load_artifacts()
	load_game()

func load_artifacts():
	_recursive_load(ARTIFACTS_PATH)

func _recursive_load(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				_recursive_load(path + file_name + "/")
			elif file_name.ends_with(".tres"):
				var artifact = load(path + file_name)
				all_artifacts.append(artifact)
			file_name = dir.get_next()
		dir.list_dir_end()

func save_game():
	var save_data = {
		"current_checkpoint": current_checkpoint,
		"current_level": current_level,
		"collected_artifacts": collected_artifacts,
		"equipped_artifacts": equipped_artifacts
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var save_data = file.get_var()
		file.close()
		
		current_checkpoint = save_data.get("current_checkpoint", "")
		current_level = save_data.get("current_level", "")
		collected_artifacts = save_data.get("collected_artifacts", [])
		equipped_artifacts = save_data.get("equipped_artifacts", ["", ""])
		
		update_game()

func update_game():
	# Update the game state based on loaded data
	# This function should be called after loading the game
	pass

func collect_artifact(artifact_name: String):
	if not artifact_name in collected_artifacts:
		collected_artifacts.append(artifact_name)
		save_game()

func equip_artifact(artifact_name: String, slot: int):
	if slot in [0, 1] and artifact_name in collected_artifacts:
		equipped_artifacts[slot] = artifact_name
		save_game()
