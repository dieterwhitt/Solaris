# file containing multipliers and effects classes

extends Script

# inner class definition for multiplier object
class Multiplier:
	extends Node2D # needs to extend node to have timer and progress bar child
	var timer : Timer 
	var progress_bar = null
	
	# constructor variables
	var movedata : MoveDataResource
	var attribute : String # accessing movedata resource fields using bracket notation
	var value : float
	var time_s : float
	var total_time_s : float # total time from the beginning (for progress bar)
	var between_players : bool # whether the multiplier stays after switching players
	var show_progress_bar : bool # whether to show progress bar
	var progress_bar_color : Color
	
	# constructor
	func _init(movedata, attribute, value, time_s, total_time_s, between_players = false, 
	show_progress_bar = false, progress_bar_color = Color.WHITE):
		self.movedata = movedata
		self.attribute = attribute
		self.value = value
		self.time_s = time_s
		self.total_time_s = total_time_s
		self.between_players = between_players
		self.show_progress_bar = show_progress_bar
		self.progress_bar_color = progress_bar_color
		
	func _ready():
		# set up timer and progress bar
		# connect timer to timeout function and start it
		timer = Timer.new()
		timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		timer.timeout.connect(self._on_timer_timeout)
		add_child(timer)
		timer.start(time_s)
		# check progress bar
		if show_progress_bar:
			progress_bar = load("res://players/common/progress_bar.tscn").instantiate()
			progress_bar._init(timer.get_path(), progress_bar_color, true, total_time_s)
			add_child(progress_bar)
			
	func _on_timer_timeout():
		# remove and free itself
		self.remove()
		

	# timer runs out: undo multiplier and delete self
	func remove():
		print("removing active multiplier")
		self.movedata[attribute] /= self.value
		self.queue_free()
	
	# applies multiplier
	func apply():
		print("applying %sx multiplier on %s for %s seconds" % [value, attribute, timer.time_left])
		self.movedata[attribute] *= self.value

# need to track temporary effects too
# non-movedata multipliers – do not touch movedata or it will cause scaling issues
# the lambda functions apply and remove MUST ORIGINATE FROM A RESOURCE
# OTHERWISE YOU MAY REFERENCE A FREED FUNCTION POINTER
class Effect:
	extends Node2D
	var timer : Timer 
	var progress_bar = null
	
	# constructor
	var apply_func : Callable # takes player as param
	var remove_func : Callable
	var player : Node
	var time_s : int
	var total_time_s : float # total time from the beginning (for progress bar)
	var between_players : bool # whether the multiplier stays after switching players
	var show_progress_bar : bool # whether to show progress bar
	var progress_bar_color : Color
	
	func _init(player, apply_func, remove_func, time_s, total_time_s, between_players = false, 
	show_progress_bar = false, progress_bar_color = Color.WHITE):
		self.player = player
		self.apply_func = apply_func
		self.remove_func = remove_func
		self.time_s = time_s
		self.total_time_s = total_time_s
		self.between_players = between_players
		self.show_progress_bar = show_progress_bar
		self.progress_bar_color = progress_bar_color
	
	func _ready():
		# set up timer and progress bar
		# connect timer to timeout function and start it
		timer = Timer.new()
		timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		timer.timeout.connect(self._on_timer_timeout)
		add_child(timer)
		timer.start(time_s)
		# check progress bar
		if show_progress_bar:
			progress_bar = load("res://players/common/progress_bar.tscn").instantiate()
			progress_bar._init(timer.get_path(), progress_bar_color, true, total_time_s)
			add_child(progress_bar)
			
	# wrapper for apply function
	func apply():
		self.apply_func.call(player)
	
	# wrapper for removal
	func remove():
		self.remove_func.call(player)
		self.queue_free()
		
	func _on_timer_timeout():
		# remove and free itself
		self.remove()
