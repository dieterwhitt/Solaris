extends Resource
# default player data resource
# not a node because i want it seperate from nodes since it's not a 'game object'

# gravity
const GRAVITY : float = 300.0
# acceleration and deceleration (velocity/s)
const ACCELERATION : float = 600.0
const DECELERATION : float = 600.0
# jump height and air time (pixels, seconds) used to calculate jump velocity
const JUMP_HEIGHT : float = 50
const AIR_TIME : float = 2.0
const JUMP_VELOCITY = -150.0
# down gravity multiplier
const DOWN_MULTIPLIER : float = 1.0
# air acceleration and deceleration multiplier (air control and air brake)
const AIR_ACCEL_MULTIPLIER : float = 1.0
const AIR_DECEL_MULTIPLIER : float = 1.0
# terminal x and y velocity
const TERMINAL_X : float = 300.0
const TERMINAL_Y : float = 1200.0
# max velocity reachable by input alone
const INPUT_TERMINAL : float = 150.0 
# number of coyote and jump buffer frames
const COYOTE_TIME : int = 20
const JUMP_BUFFER : int = 20



