extends Script

class_name AdrenalineEffect

# all static functions to be accessed without instance of class (i think)
static var particle_scene = "res://players/adrenaline_player/adrenaline_particles.tscn"

static func apply(player : Node):
	print("applying adrenaline particles")
	# add particles (effect)
	var particles = load(particle_scene).instantiate()
	player.add_child(particles)
	particles.add_to_group("AdrenalineParticles") 
	particles.emitting = true
		
static func remove(player : Node):
	# remove particels (effect)
	print("removing adrenaline particles")
	for node in player.get_children():
		if node.is_in_group("AdrenalineParticles"):
			node.emitting = false
