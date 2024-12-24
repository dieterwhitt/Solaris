# adrenaline player

extends AbstractPlayerDecorator

class_name AdrenalinePlayer

var charges_left = 3 
const DURATION_S : int = 5 # duration in seconds

class AdrenalineEffect:
	extends StatusEffect
	
	# nested cooldown effect class
	class AdrenalineCooldown:
		extends BasicCooldown
	
	const INPUT_TERMINAL_MULT : float = 1.35
	const ACCEL_MULT : float = 2
	const DECEL_MULT : float = 1.8
	const COOLDOWN_TIME = 8
	
	@onready var particles = \
			preload("res://players/artifacts/adrenaline_shot/adrenaline_particles.tscn")
	
	func _ready():
		super()
		player.add_child(particles.instantiate())
	
	func _apply():
		super()
		print("applying adrenaline")
		particles.emitting = true
		# movedata multipliers
		player.MoveData.INPUT_TERMINAL *= INPUT_TERMINAL_MULT
		player.MoveData.ACCELERATION *= ACCEL_MULT
		player.MoveData.DECELERATION *= DECEL_MULT
		
		
	func _remove():
		super()
		print("removing adrenaline")
		if particles:
			particles.emitting = false
		player.add_effect(AdrenalineCooldown.new(COOLDOWN_TIME, player))
		player.MoveData.INPUT_TERMINAL /= INPUT_TERMINAL_MULT
		player.MoveData.ACCELERATION /= ACCEL_MULT
		player.MoveData.DECELERATION /= DECEL_MULT
		
func _ready():
	component._held_item_filepath = "placeholder" # set later

func _physics_process(delta):
	if Input.is_action_just_pressed("special") and \
			not component.has_effect("AdrenalineCooldown") and \
			not component.has_effect("AdrenalineEffect"):
		component.add_effect(AdrenalineEffect.new(DURATION_S, component, true, 
				Color8(235, 48, 96, 255)))
