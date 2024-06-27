# progress_bar.gd

extends Node2D

# 20 pixels, 1px for every 5% interval. 0% is empty.
# 0-5% - 0px, 6-10% - 1px, ... 100% - 20px
# each 2px on the progress bar is represented by reducing scale by .05 and doing position x -= 0.5

# timer node to track progress of
@export_node_path("Timer") var timer_path
@export var color : Color # color of bar
@onready var bar = $Bar
var timer : Timer

func _ready():
	if timer_path:
		timer = get_node(timer_path)
	if color:
		bar.default_color = color
	# check all siblings for a progress bar. for each one, shift this one up 4px
	var parent = get_parent()
	if parent:
		for node in parent.get_children():
			# all other progress bars
			if node != self and node.is_in_group("ProgressBar"):
				print("progress bar sibling found")
				self.position.y -= 4
				


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# check if timer actually still exists
	if not timer:
		print("progress bar: timer not found, deleting")
		queue_free()
	# first handle edge case: 0 sec wait time (avoid div by 0)
	if timer.wait_time == 0:
		print("timer wait time at 0, can't render progress bar. deleting")
		queue_free()
	# percent already progressed
	var percent : float = 1 - timer.time_left / timer.wait_time
	# set bar accordingly
	var bar_length : int = floor(percent * 20) # 0-20 pixels
	var bar_scale : float = float(bar_length) / 20.0
	var bar_shift : float = -10 + bar_scale * 10
	
	bar.scale.x = bar_scale
	bar.position.x = bar_shift
	
