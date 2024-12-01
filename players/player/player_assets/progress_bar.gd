# progress_bar.gd

# player progress bar. can be added by code or scene editor

extends Node2D

# 20 pixels, 1px for every 5% interval. 0% is empty.
# 0-5% - 0px, 6-10% - 1px, ... 100% - 20px
# each 2px on the progress bar is represented by reducing scale by .05 and doing position x -= 0.5

# timer node to track progress of
@export_node_path("Timer") var timer_path
@export var color : Color # color of bar
@export var show_empty : bool # whether to show the bar when at 0%
var timer : Timer

@onready var bar = $Bar
@onready var base = $Base
const BASE_COLOR = Color8(125, 125, 125, 255)

# can init before adding to tree
func _init(color = Color.WHITE, show_empty: bool = true, 
		timer: Timer = null):
	self.color = color
	self.show_empty = show_empty
	self.timer = timer

func _ready():
	if timer == null:
		if timer_path:
			timer = get_node(timer_path)
		else:
			queue_free()
	if color:
		bar.default_color = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_height()
	# set global transform so it isn't flipped by parent
	global_transform.x.x = 1
	# check if timer actually still exists
	if not timer:
		print("progress bar: timer not found, deleting")
		queue_free()
	# first handle edge case: 0 sec wait time (avoid div by 0)
	elif timer and timer.wait_time == 0:
		print("timer wait time at 0, can't render progress bar. deleting")
		queue_free()
	else:
		# percent already progressed
		var quotient = timer.wait_time
		var percent : float = 1 - timer.time_left / quotient
		# set bar accordingly
		var bar_length : int = floor(percent * 20) # 0-20 pixels
		bar.set_point_position(1, Vector2(bar_length - 10, 0))
		
		# below: avoiding show/hide to avoid external interference
		if bar_length == 0 and not show_empty:
			base.default_color = Color8(0, 0, 0, 0) # make base invisible
		elif timer.is_stopped():
			# make bar invisible when timeout
			base.default_color = Color8(0, 0, 0, 0)
			bar.default_color = Color8(0, 0, 0, 0)
		else:
			base.default_color = BASE_COLOR
			bar.default_color = color

func update_height():
	# get array of bars
	var bars = get_tree().get_nodes_in_group("ProgressBar")
	# based on index of current, shift up 4px
	var count = 0 # number of bars before self
	for bar in bars:
		if bar == self:
			# shift up
			self.position.y = -4 * count
			break
		else:
			if bar:
				# bar exists
				count += 1
