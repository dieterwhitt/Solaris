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
	sprite.speed_scale = rng.randf_range(0.3, 0.7)
	# random scale and opacity
	sprite.scale.x = rng.randf_range(2.5, 3.5)
	sprite.modulate = Color8(255, 255, 255, rng.randi_range(20, 50))
	# whether to reverse float animation
	var reverse_float = rng.randi_range(0, 1)
	if reverse_float == 1:
		animation_player.speed_scale *= -1
	# possible future option: randomly choose between foreground and background
	# or some type of fg/bg variants. bg are smaller, darker, slower

func _process(delta):
	pass
