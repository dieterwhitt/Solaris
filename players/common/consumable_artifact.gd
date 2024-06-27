# dieter whittingham
# june 26
# consumable artifact player

extends ReworkedDefaultController

# essentially just a regular player but keeps track of a cooldown timer and
# number of remaining charges

class_name ConsumableArtifact

# there must always be a cooldown timer
@export_node_path("Timer") var _cooldown_timer_path
# null means no cooldown - instant use
@onready var _cooldown_timer = get_node(_cooldown_timer_path)
# -1 means infinite charges
var _charges_left : int = -1
