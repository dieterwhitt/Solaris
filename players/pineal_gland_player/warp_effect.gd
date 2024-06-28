# warp effect for fucking gland

extends Script

class_name WarpEffect

static var particle_path = "res://players/pineal_gland_player/warp_particles.tscn"

static func apply(player):
	# change physics layer (layer 7)
	player.set_collision_layer_value(2, false)
	player.set_collision_layer_value(7, true)
	# set color
	player.modulate = Color8(255, 209, 94, 140)
	# add particles
	var particles = load(particle_path).instantiate()
	player.add_child(particles)
	particles.emitting = true

static func remove(player):
	player.modulate = Color8(255, 255, 255, 255)
	player.set_collision_layer_value(2, true)
	player.set_collision_layer_value(7, false)
	# also get rid of item holding particles
	for node in player.get_children():
		if node.is_in_group("WarpParticles"):
			node.emitting = false
