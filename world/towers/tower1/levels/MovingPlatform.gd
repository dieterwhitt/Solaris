extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	tween.tween_property(self, "position", Vector2(position.x + 120, position.y), 3)
	tween.tween_property(self, "position", position, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
