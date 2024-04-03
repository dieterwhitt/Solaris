# reworked_default_controller_data.gd
# 4/2/24

extends Resource
# default player data resource
# not a node because i want it seperate from nodes since it's not a 'game object'

# gravity
var GRAVITY : float = 670.0 # 670
# acceleration and deceleration (velocity/s)
# added: acceleration in opposite direction -> apply friction instead 
var ACCELERATION : float = 1000.0 # 1000
var DECELERATION : float = 1500.0 # 1500

# jump height and air time (pixels, seconds) used to calculate jump velocity with kinematic eqns
# currently: 0.3s to peak (0.6s total), 30px jump
var JUMP_VELOCITY = -200.0 # -200
# down gravity multiplier
var DOWN_MULTIPLIER : float = 1.2 # 1.2
# air acceleration and deceleration multiplier (air control and air brake)
var AIR_ACCEL_MULTIPLIER : float = 0.9 # 0.9
var AIR_DECEL_MULTIPLIER : float = 0.5 # 0.5
# terminal x and y velocity
var TERMINAL_X : float = 200.0 # 200
# falling only
var TERMINAL_Y : float = 250.0 # 250
# max velocity reachable by input alone
var INPUT_TERMINAL : float = 120.0 # 120
# number of coyote and jump buffer frames
var COYOTE_TIME : int = 5 # 5
var JUMP_BUFFER : int = 5 # 5
# new stuff
var DOUBLE_JUMP_VELOCITY = -150
