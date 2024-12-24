extends CharacterBody2D

class_name AbstractPlayer

# inherited by concrete player and decorators

# just need some nested classes and stuff :3

var _held_item_filepath : String = "" # set in decorator

# ABC status effect class definition (see UML)
# decorators will have to create their own status effect nested classes, then
# add it here. works for any status effect, cooldown, etc.
# status effects will always be direct children of player.
class StatusEffect:
	extends Timer
	var duration : float
	var show_bar : bool
	var bar_color : Color
	var player : Player # player to apply effect to
	
	# constructor - not on tree yet
	# if player not provided: will check immediate parent for a player.
	func _init(duration: float, player: Player = null, show_bar : bool = true, 
			bar_color: Color = Color.WHITE):
		self.one_shot = true
		self.duration = duration
		self.wait_time = duration
		self.player = player
		self.show_bar = show_bar
		self.bar_color = bar_color
		
	func _ready():
		if player == null:
			# search for player in parent. free if no parent or not player type.
			var parent : Node = get_parent()
			if parent == null or !parent.is_class("Player"):
				queue_free()
			else:
				player = parent
		elif self not in player.get_children():
			# player was given but the effect is not a direct child: add it
			player.add_child(self)
		# connect timeout signal
		self.timeout.connect(_on_timeout)
	
	# virtual
	func _apply():
		self.start()
	
	# virtual
	func _remove():
		pass
	
	# call remove() and free self from tree
	func _on_timeout():
		_remove()
		# orphan the effect, rather than remove it, so it can be reused. _ready will be re-called
		player.remove_child(self)
		self.wait_time = duration

# generic cooldown
class BasicCooldown:
	extends StatusEffect
	# override init to set common gray color
	func _init(duration, player = null, show_bar = true, 
			bar_color = Color8(170, 170, 170)):
		super(duration, player, show_bar, bar_color)

