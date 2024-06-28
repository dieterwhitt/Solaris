# boomstick_effect.gd

extends Script

class_name BoomstickEffect

static var pellets_path = "res://players/boomstick_player/boomstick_pellets.tscn"

static func apply(player):
	print("adding pellet particles")
	var new_pellets = load(pellets_path).instantiate()
	player.add_child(new_pellets)
	new_pellets.emitting = true

static func remove(player):
	print("removing pellet particles")
	for node in player.get_children():
		if node.is_in_group("BoomstickPellets"):
			node.queue_free()
