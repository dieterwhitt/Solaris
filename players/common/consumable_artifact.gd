# dieter whittingham
# june 26
# consumable artifact player

extends ReworkedDefaultController

# essentially just a regular player but keeps track of a cooldown timer and
# number of remaining charges

class_name ConsumableArtifact

# there must always be a cooldown timer
@export_node_path("Timer") var cooldown_timer
var charges_left : int
