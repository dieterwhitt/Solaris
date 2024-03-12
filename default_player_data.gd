extends Resource
# default player data resource
# not a node because i want it seperate from nodes since it's not a 'game object'

# gravity
@export var GRAVITY : float = 300.0
# acceleration and deceleration (60*pixels/frame^2)
@export var ACCELERATION : float = 100.0
@export var DECELERATION : float = 100.0
# jump height and air time (pixels, seconds) used to calculate jump velocity
@export var JUMP_HEIGHT : int = 32
@export var AIR_TIME : float = 2.5
@export var JUMP_VELOCITY : float = -150
# down gravity multiplier
@export var DOWN_MULTIPLIER : float = 1.2
# air acceleration and deceleration multiplier (air control and air brake)
@export var AIR_ACCEL_MULTIPLIER : float= 1.0
@export var AIR_DECEL_MULTIPLIER : float = 1.0
# terminal x and y velocity
@export var TERMINAL_X : float = 300.0
@export var TERMINAL_Y : float = 1200
# max velocity reachable by input alone
@export var INPUT_TERMINAL : float = 150.0 
# coyote and jump buffer frames
@export var COYOTE_TIME : int = 20
@export var JUMP_BUFFER : int = 20
