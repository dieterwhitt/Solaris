# player template
# for any artifact script NOT including consumable artifacts / weapon artifacts
# pan flute player

extends ReworkedDefaultController

const TUNE_DURATION = 10 # length of the tune for how long the animation will play
var playing : bool = false
@onready var timer = $Timer
@onready var progress_bar = $ProgressBar

func _ready():
	super()
	print("creating pan flute player")

func _physics_process(delta):
	# apply physics controller
	super._physics_process(delta)
	# call any unique functions here
	play_flute()
	# move and slide
	move_and_slide()

func play_flute():
	if Input.is_action_just_pressed("special"):
		# play flute animation
		# _animation_tree.travel("play")
		# animation will be a looping animation and particles will be emitted.
		timer.start(TUNE_DURATION)
		# show progress bar
		progress_bar.show()
		await timer.timeout
		if playing:
			# when timer runs out, stops playing if hasn't been stopped yet
			stop_playing()
	elif playing:
		# currently playing
		for input in ["left", "right", "up", "down", "jump", "parry"]:
			# any input stops flute animation
			if Input.is_action_just_pressed(input):
				stop_playing()
				break

func stop_playing():
	# stops playing the flute whether the timer ran out or the player moved
	playing = false
	_animation_tree.travel("idle")
	# stop music
	# hide progress bar
	progress_bar.hide()
