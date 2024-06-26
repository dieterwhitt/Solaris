# dieter whittingham
# june 26 2024
# censer.gd

extends Sprite2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var timer = $Timer
@onready var rng = RandomNumberGenerator.new()
var emitting = false
var first_cycle = true

func _ready():
	print("loading censer")
	animation_tree.active = true

func idle():
	emitting = false
	if first_cycle:
		# first cycle idle interval
		timer.start(rng.randf_range(0, 15))
		first_cycle = false
	else:
		# regular idle interval
		timer.start(rng.randf_range(10, 15))
	await timer.timeout
	state_machine.travel("start")
	# print("emitting censer")

func emit():
	if not emitting:
		emitting = true
		timer.start(rng.randf_range(2, 3))
		await timer.timeout
		state_machine.travel("stop")
		# print("stopping censer")
