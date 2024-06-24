# reworked_default_controller_data.gd
# 4/2/24

# DONT TOUCH ANYTHING IN THIS FILE!!!

extends Resource
# player data resource with default values

class_name MoveData

# gravity
@export var GRAVITY : float = 670.0 # 670
# acceleration and deceleration (velocity/s)
# added: acceleration in opposite direction -> apply friction instead 
@export var ACCELERATION : float = 1000.0 # 900
@export var DECELERATION : float = 1500.0 # 1425 1400

# jump height and air time (pixels, seconds) used to calculate jump velocity with kinematic eqns
# currently: 0.3s to peak (0.6s total), 30px jump
@export var JUMP_VELOCITY = -207.0 # -200
# down gravity multiplier
@export var DOWN_MULTIPLIER : float = 1.2 # 1.2
# air acceleration and deceleration multiplier (air control and air brake)
@export var AIR_ACCEL_MULTIPLIER : float = 0.85 # 0.8
@export var AIR_DECEL_MULTIPLIER : float = 0.35 # 0.35
# terminal x and y velocity
@export var TERMINAL_X : float = 400.0 # 400
# falling only
@export var TERMINAL_Y : float = 250.0 # 250
# max velocity reachable by input alone
@export var INPUT_TERMINAL : float = 105.0 # 105
# number of coyote and jump buffer frames
@export var COYOTE_TIME : int = 5 # 5
@export var JUMP_BUFFER : int = 5 # 5
# new stuff
@export var DOUBLE_JUMP_VELOCITY = -125 # -150
@export var MOMENTUM_MULTIPLIER = 0.8 # friction multiplier at high speeds
