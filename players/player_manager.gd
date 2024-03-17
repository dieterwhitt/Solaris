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
var players : Array 
var abilities : Array 

var current_player : CharacterBody2D
var current_ability : CharacterBody2D

var ability_active : bool

func _ready():
	# constructor - declare here...? i know i normally declare above
	# set defaults
	players = [player_unpowered]
	abilities = [player_ability]
	current_player = players[0]
	current_ability = abilities[0]
	# add default player to tree
	ability_active = false
	add_child(current_player)

func _process(delta):
	ability()

# i wanna handle abilities here instead of in each scene - makes more sense
func ability():
	if Input.is_action_just_pressed("ability"):
		# check ability status
		if not ability_active:
			# summon ability
			add_child(current_ability)
			current_ability.global_position = current_player.global_position
			# stop input on character
			current_player.receive_input = false
			# reset direction
			current_player.direction = 0
			
			# signal to singleton to slow world
		
		else:
			# remove ability
			current_player.global_position = current_ability.global_position
			current_player.receive_input = true
			remove_child(current_ability)
		# toggle local status
		ability_active = not ability_active
			
