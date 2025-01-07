# checkpoint scene
# need to add menu popup, select artifacts

extends Node2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var area = $Area2D
@onready var label = $Label
var reached # eventually load

# Called when the node enters the scene tree for the first time.
func _ready():
	var reached = false # eventually will need to load from file
	animation_tree.active = true
	# checked already reached (value loaded from file)
	if reached:
		state_machine.start("reached")

func _physics_process(delta):
	# check if player is in area
	for body in area.get_overlapping_bodies():
		if body.is_in_group("Player") and Input.is_action_just_pressed("interact"):
			# display menu to swap artifacts, warp
			pass
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		if not reached:
			# set checkpoint
			set_checkpoint()
		fade_label(true)

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		fade_label(false)

func fade_label(show: bool):
	var tween = create_tween().set_trans(Tween.TRANS_QUART)
	var current_color = label.modulate
	var alpha = 255 if show else 0
	tween.tween_property(label, "modulate", 
		Color8(current_color.r8, current_color.g8, current_color.b8, alpha), 0.15)

func set_checkpoint():
	# play animation
	state_machine.travel("growing")
	# set spawn in level manager
	var level_manager = get_node("/root/LevelManager")
	if level_manager:
		level_manager.spawn_lvl = level_manager.current_lvl
	# save to file
	reached = true
