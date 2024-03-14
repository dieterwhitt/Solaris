# default_controller_data.gd
# 3/13/24

extends Resource
# default player data resource
# not a node because i want it seperate from nodes since it's not a 'game object'

# gravity
const GRAVITY : float = 670.0
# acceleration and deceleration (velocity/s)
# possible improvement: acceleration in opposite direction -> apply friction instead
const ACCELERATION : float = 1000.0
const DECELERATION : float = 1500.0

# jump height and air time (pixels, seconds) used to calculate jump velocity with kinematic eqns
# currently: 0.3s to peak (0.6s total), 30px jump
const JUMP_VELOCITY = -200.0 
# down gravity multiplier
const DOWN_MULTIPLIER : float = 1.2
# air acceleration and deceleration multiplier (air control and air brake)
const AIR_ACCEL_MULTIPLIER : float = 0.9
const AIR_DECEL_MULTIPLIER : float = 0.5
# terminal x and y velocity
const TERMINAL_X : float = 200.0
const TERMINAL_Y : float = 600.0
# max velocity reachable by input alone
const INPUT_TERMINAL : float = 120.0 
# number of coyote and jump buffer frames
const COYOTE_TIME : int = 5
const JUMP_BUFFER : int = 5



