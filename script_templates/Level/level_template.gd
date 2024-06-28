# level template.

extends Level

# use this file to define any level-specific logic.

func _ready():
	super()

func _physics_process(delta):
	# sample – getting player
	# get_player()
	pass

func get_player():
	var level_manager = get_node("/root/LevelManager")
	if level_manager:
		var player = level_manager.player
		return player
	return null
