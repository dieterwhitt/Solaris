# glass_cloud.gd

extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	# randomly choose which sprite to play
	var rng = RandomNumberGenerator.new()
	var sprite_option = rng.randi_range(0, 1)
	if sprite_option == 1:
		sprite.animation = "cloud1"
	else:
		sprite.animation = "cloud2"
	sprite.play()
	# choose random animatino player speed (hover animation)
	animation_player.speed_scale = rng.randf_range(0.7, 1.3)
	var reverse_float = rng.randi_range(0, 1)
	if reverse_float == 1:
		animation_player.speed_scale *= -1
	# possible future option: randomly choose between foreground and background
	# or some type of fg/bg variants. bg are smaller, darker, slower

func _process(delta):
	pass
