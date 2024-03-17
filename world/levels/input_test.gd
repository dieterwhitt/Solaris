extends Node2D

var d
# Called when the node enters the scene tree for the first time.
func _ready():
	print("input test")
	# hide mouse
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	'''
	print("-----frame-----")
	# 60fps - higher on higher refresh rates
	if Input.is_action_pressed("left"):
		print("left")
	if Input.is_action_pressed("right"):
		print("right")
	if Input.is_action_pressed("up"):
		print("up")
	if Input.is_action_pressed("down"):
		print("down")
	if Input.is_action_pressed("attack"):
		print("k")
	if Input.is_action_pressed("lmb"):
		print("click")
	'''
	d = Input.get_vector("left", "right", "up", "down").snapped(Vector2.ONE)
	#print(d)
	
