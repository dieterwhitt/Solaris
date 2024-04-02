# 4/2/2024
# dash orb

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	print("collision with dash orb")
	# dash player
	if body.get_name() == "PlayerUnpowered":
		# SHITTY CODE!!!
		if int(self.rotation_degrees) % 360 == 0:
			body.velocity.y = -250
		elif int(self.rotation_degrees) % 360 == 90:
			body.velocity.x = 250
		elif int(self.rotation_degrees) % 360 == 180:
			body.velocity.y = 250
		elif int(self.rotation_degrees) % 360 == 270:
			body.velocity.x = -250
			
		
