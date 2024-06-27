# illusory_wall_highlight.gd
# hides itself ear not equipped

extends Node2D

@onready var particles = $GPUParticles2D
@onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	particles.emitting = false
	line.hide()

# checks if player is severed ear
func _physics_process(delta):
	var level_manager = get_node("/root/LevelManager")
	if level_manager:
		var player = level_manager.player
		if player and player.is_in_group("SeveredEarPlayer"):
			particles.emitting = true
			line.show()
		else:
			particles.emitting = false
			line.hide()
