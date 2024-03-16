# player_ability.gd
# 3/14/24

extends DefaultController

func _ready():
	# update movedata
	MoveData = load("res://players/player_ability/player_ability_data.gd").new()
	DefaultDataReference = MoveData.duplicate()
	# update sprite, tree, statemachine
	_animation_tree = $AnimationTree2
	_animation_tree.active = true
	_sprite = $Sprite2D
	_state_machine = _animation_tree.get("parameters/playback")
	print("created clone")
	
func _physics_process(delta):
	# apply default controller
	super._physics_process(delta)
	# define additional capabilities
	move_and_slide()

func _process(delta):
	super._process(delta)

func _update_animation():
	# override
	if not on_floor and used_jump:
		# jump
		_state_machine.travel("jump")
	elif not on_floor:
		# fall
		pass
	else:
		# set blend
		_animation_tree.set("parameters/run-idle/blend_position", direction)
		# idle-run
		_state_machine.travel("run-idle")
