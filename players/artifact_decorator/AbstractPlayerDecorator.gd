# abstract decorator for artifacts

extends Node

class_name AbstractPlayerDecorator

var component : Player

func _init(component : Player):
	self.component = component
