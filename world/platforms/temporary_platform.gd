extends Node2D

var player : CharacterBody2D
var is_broken = false
@onready var platform = $Area2D
@onready var tiles = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the player variable
	player = get_node("/root/LevelManager").player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for node in platform.get_overlapping_bodies():
		if node.is_in_group('Player') and node.global_position.y < global_position.y and node.velocity.y == 0:
			_start_platform_removal()


# Coroutine to handle the platform removal
func _start_platform_removal():
	$AnimationPlayer.play("shake")
	await get_tree().create_timer(0.5).timeout
	remove_child(platform)
	remove_child(tiles)
	_start_platform_readdition()


# Coroutine to handle the platform readdition
func _start_platform_readdition():
	await get_tree().create_timer(4).timeout
	add_child(platform)
	add_child(tiles)
	$AnimationPlayer.play("reappear")


