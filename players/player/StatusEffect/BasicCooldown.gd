# generic class for cooldowns
class_name BasicCooldown
extends StatusEffect
# override init to set common gray color
func _init(duration, player = null, show_bar = true, 
		bar_color = Color8(170, 170, 170)):
	super(duration, player, show_bar, bar_color)
