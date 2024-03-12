extends Resource
# default player data resource
# not a node because i want it seperate from nodes since it's not a 'game object'

# gravity
@export var GRAVITY : float = 300.0
# acceleration and deceleration (60*pixels/frame^2)
@export var ACCELERATION : float = 70.0
@export var DECELERATION : float = 70.0
# jump height and air time (pixels, seconds) used to calculate jump force
@export var JUMP_HEIGHT : int = 32
@export var AIR_TIME : float = 2.5
@export var JUMP_FORCE : float = 0.0
# down gravity multiplier
@export var DOWN_MULTIPLIER : float = 1.2
# air acceleration and deceleration multiplier (air control and air brake)
@export var AIR_ACCEL_MULTIPLIER : float= 1.0
@export var AIR_DECEL_MULTIPLIER : float = 1.0
# terminal x and y velocity
@export var TERMINAL_X : float = 300.0
@export var TERMINAL_Y : float = 1200
# velocity at which player input no longer adds acceleration
@export var VELOCITY_INPUT_BOUND_X : float = 140.0 
# coyote and jump buffer frames
@export var COYOTE_TIME : int = 2
@export var JUMP_BUFFER : int = 2
