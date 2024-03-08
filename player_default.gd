extends CharacterBody2D
# prototype default character controller

const SPEED : float = 70.0
const JUMP_VELOCITY : float = -300.0
var direction : float = 0.0
var swinging : bool = false
var heavy : bool = false

func _ready():
	print('charcter created')
	$AnimationTree.active = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# handle swing animation
	swinging = Input.is_action_just_pressed("ui_attack")
	heavy = Input.is_action_just_pressed("ui_heavy")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	update_animation()
	flip()
	
	move_and_slide()


func flip():
	if direction > 0:
		$Sprite2D.flip_h = false
	elif direction < 0:
		$Sprite2D.flip_h = true
		
func update_animation():
	if swinging:
		$AnimationTree.set('parameters/conditions/swinging', true)
		$AnimationTree.set('parameters/conditions/jumping', false)
		swinging = false
	elif heavy:
		$AnimationTree.set('parameters/conditions/heavy', true)
		$AnimationTree.set('parameters/conditions/jumping', false)
		heavy = false
	elif not is_on_floor():
		$AnimationTree.set('parameters/conditions/swinging', false)
		$AnimationTree.set('parameters/conditions/heavy', false)
		$AnimationTree.set('parameters/conditions/grounded', false)
		$AnimationTree.set('parameters/conditions/jumping', true)
	else:
		$AnimationTree.set('parameters/conditions/grounded', true)
		$AnimationTree.set('parameters/conditions/jumping', false)
		$AnimationTree.set('parameters/conditions/swinging', false)
		$AnimationTree.set('parameters/conditions/heavy', false)
		$AnimationTree.set('parameters/run-idle/blend_position', direction)

func test_print():
	print('testing')
