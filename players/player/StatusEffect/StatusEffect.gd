# ABC status effect class definition (see UML)
# decorators will have to create their own status effect nested classes, then
# add it here. works for any status effect, cooldown, etc.
# status effects will always be direct children of player.
class_name StatusEffect
extends Timer
var id : String
var duration : float
var show_bar : bool
var bar_color : Color
var player : Player # player to apply effect to
var bar : Bar

@onready var bar_scene = preload("res://players/player/player_assets/progress_bar.tscn")

# constructor - not on tree yet
# if player not provided: will check immediate parent for a player.
func _init(duration: float, id: String = "Effect", player: Player = null, show_bar : bool = true, 
		bar_color: Color = Color.WHITE):
	self.one_shot = true
	self.id = id
	self.duration = duration
	self.wait_time = duration
	self.player = player
	self.show_bar = show_bar
	self.bar_color = bar_color
	
func _ready():
	add_to_group("StatusEffect")
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
	# add progress bar
	if show_bar:
		bar = bar_scene.instantiate()
		bar.build(bar_color, false, self)
		player.add_child(bar)
	self.start()

# virtual
func _remove():
	bar.queue_free()

# call remove() and free self from tree
func _on_timeout():
	_remove()
	# orphan the effect, rather than remove it, so it can be reused. _ready will be re-called
	player.remove_child(self)
	self.wait_time = duration



