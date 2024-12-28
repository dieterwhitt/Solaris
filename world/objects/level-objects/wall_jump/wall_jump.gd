# wall_jump.gd
# lets the player wall jump when in contact.
# logic added as part of player jump elig check.

extends Node2D

@onready var particles = $GPUParticles2D
@onready var line = $Line2D

func _ready():
	pulse()

# pulse animation
func pulse():
	var tween = create_tween().set_loops() # linear looping tween
	tween.tween_property(line, "default_color", Color8(255, 244, 211, 255), 1)
	tween.tween_property(line, "default_color", Color8(255, 244, 211, 0), 1)
	
