# player_manager.gd
# 3/15/24

# Node2D that manages all player scenes and controlls the rendering of each one

extends Node2D

# instances of player and ability scenes
@onready var player_unpowered : CharacterBody2D = \
		preload("res://players/player_unpowered/player_unpowered.tscn").instantiate()
@onready var player_ability : CharacterBody2D = \
		preload("res://players/player_ability/player_ability.tscn").instantiate()

# arrays to store variants
# idk if its better to declare here or in constructor oop wise
@onready var players : Array = [player_unpowered]
@onready var abilities : Array = [player_ability]

@onready var current_player : CharacterBody2D = players[0]
@onready var current_ability : CharacterBody2D = abilities[0]

@onready var ability_active : bool = false

func _ready():
	add_child(current_player)

func _process(delta):
	ability()

# i wanna handle abilities here instead of in each scene - makes more sense
# modifying positions in _process rather than _physics_process is acceptable since
# the position of a 2d node is considered spatial data and not physics data
func ability():
	if Input.is_action_just_pressed("ability"):
		# check ability status
		if not ability_active:
			# summon ability
			add_child(current_ability)
			current_ability.global_position = current_player.global_position
			current_ability._sprite.flip_h = current_player._sprite.flip_h
			# stop input on character
			current_player.receive_input = false
			# reset
			current_ability.queue_reset = true
			current_player.queue_reset = true
			
			# signal to singleton to slow world
		
		else:
			# remove ability
			current_player.global_position = current_ability.global_position
			current_player.receive_input = true
			remove_child(current_ability)
			# disable jump - no double jump
			current_ability.queue_reset = true
			current_player.queue_reset = true
		# toggle local status
		ability_active = not ability_active
	elif Input.is_action_just_pressed("cancel") and ability_active:
		# remove ability but keep player location
		current_player.receive_input = true
		remove_child(current_ability)
		current_ability.queue_reset = true
		current_player.queue_reset = true
		# toggle local status
		ability_active = not ability_active
