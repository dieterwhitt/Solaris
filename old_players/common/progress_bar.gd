# progress_bar.gd

extends Node2D

# 20 pixels, 1px for every 5% interval. 0% is empty.
# 0-5% - 0px, 6-10% - 1px, ... 100% - 20px
# each 2px on the progress bar is represented by reducing scale by .05 and doing position x -= 0.5

# timer node to track progress of
@export_node_path("Timer") var timer_path
@export var color : Color # color of bar
@export var show_empty : bool = true # whether to show the bar when at 0%
@onready var bar = $Bar
@onready var base = $Base
@export var total_time_override : float = 0
var timer : Timer
const BASE_COLOR = Color8(125, 125, 125, 255)

# can init before adding to tree
func _init(timer_path = "", color = Color.BLACK, show_empty = true, total_time_override = 0):
	self.timer_path = timer_path
	self.color = color
	self.show_empty = show_empty
	self.total_time_override = total_time_override

func _ready():
	if timer_path:
		timer = get_node(timer_path)
	if color:
		bar.default_color = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_height()
	# set global transform so it isn't flipped
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
		if total_time_override > 0:
			# incase manual quotient was set
			quotient = total_time_override
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
