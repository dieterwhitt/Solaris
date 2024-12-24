# abstract decorator for artifacts

extends AbstractPlayer

class_name AbstractPlayerDecorator

var component : Player

func _init(component : Player):
	self.component = component
