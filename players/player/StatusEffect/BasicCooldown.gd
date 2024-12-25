# generic class for cooldowns
class_name BasicCooldown
extends StatusEffect
# override init to set common gray color
func _init(duration, id = "BasicCooldown", player = null, show_bar = true, 
		bar_color = Color8(170, 170, 170)):
	super(duration, id, player, show_bar, bar_color)
