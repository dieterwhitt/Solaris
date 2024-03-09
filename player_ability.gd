extends CharacterBody2D


const SPEED : float = 70.0
const JUMP_VELOCITY : float = -300.0
const TERMINAL_VELOCITY : float = 30.0
var direction : float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	print('clone created')
	$AnimationTree2.active = true

func _physics_process(delta):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	print(velocity.y)
	
	# Add the gravity.
	if not is_on_floor() and velocity.y < TERMINAL_VELOCITY:
		velocity.y = min(velocity.y + gravity * delta, TERMINAL_VELOCITY)
	
	if velocity.y > TERMINAL_VELOCITY:
		velocity.y = TERMINAL_VELOCITY
	
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	flip()
	update_animation()
	move_and_slide()
	
func flip():
	if direction > 0:
		$Sprite2DAbility.flip_h = false
	elif direction < 0:
		$Sprite2DAbility.flip_h = true
		
func update_animation():
	if is_on_floor():
		$AnimationTree2.set('parameters/conditions/grounded', true)
		$AnimationTree2.set('parameters/conditions/jumping', false)
		$AnimationTree2.set('parameters/run-idle/blend_position', direction)
	else:
		$AnimationTree2.set('parameters/conditions/grounded', false)
		$AnimationTree2.set('parameters/conditions/jumping', true)
