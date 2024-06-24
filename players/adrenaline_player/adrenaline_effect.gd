extends Resource

class_name AdrenalineEffect

var particle_scene = "res://players/adrenaline_player/adrenaline_particles.tscn"

func apply(player : Node):
	print("applying adrenaline particles")
	# add particles (effect)
	var particles = load(particle_scene).instantiate()
	player.add_child(particles)
	particles.name = "AdrenalineParticles"
	particles.emitting = true
		
func remove(player : Node):
	# remove particels (effect)
	print("removing adrenaline particles")
	player.remove_child(player.get_node("AdrenalineParticles"))
