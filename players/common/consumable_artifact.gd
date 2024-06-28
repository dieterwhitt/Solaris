# dieter whittingham
# june 26
# consumable artifact player

extends ReworkedDefaultController

# essentially just a regular player but keeps track of a cooldown timer and
# number of remaining charges

class_name ConsumableArtifact

# progress bar path and node (for setting cooldown override)
@export_node_path("Node2D") var _cooldown_bar_path
@onready var _cooldown_bar = get_node(_cooldown_bar_path)

# there must always be a cooldown timer
@export_node_path("Timer") var _cooldown_timer_path
# null means no cooldown - instant use
@onready var _cooldown_timer = get_node(_cooldown_timer_path)
var _cooldown_length: float = 0 # progress bar override
# -1 means infinite charges
var _charges_left : int = -1
