extends Control
@onready var timer: Timer = %Timer
@onready var hours_input: LineEdit = %hours_input
@onready var minutes_input: LineEdit = %minutes_input
@onready var seconds_input: LineEdit = %seconds_input
@onready var time_out_sound_player: AudioStreamPlayer = $TimeOutSoundPlayer

@onready var pause_button: Button = %PauseButton
@onready var reset_button: Button = %ResetButton
@onready var new_button: Button = %NewButton

var timer_time:int = 0

enum STATES {PLAY,PAUSE,SET,RESET,FINISHED}

var current_state = STATES.SET

var hours :=  0
var minutes := 0
var seconds := 0

# 1 20 30




func _ready() -> void:
	current_state = STATES.SET
	hours_input.text = "00"
	minutes_input.text = "00"
	minutes_input.text = "00"
	hours_input.text_submitted.connect(set_timer_time)
	minutes_input.text_submitted.connect(set_timer_time)
	seconds_input.text_submitted.connect(set_timer_time)
	timer.timeout.connect(func() ->void:
		time_out_sound_player.play()
		reset_timer()
	)
	pause_button.pressed.connect(func() ->void:
		match current_state:
			STATES.RESET:
				timer.start(timer_time)
				current_state = STATES.PLAY
			STATES.PLAY:
				timer.paused = true
				current_state =STATES.PAUSE
			STATES.PAUSE:
				timer.paused = false
				current_state = STATES.PLAY
		)
	
	new_button.pressed.connect(func() -> void:
		timer_time = 0
		current_state = STATES.RESET
		)
	
	reset_button.pressed.connect(reset_timer)
	

func reset_timer() ->void:
	match current_state:
			STATES.PLAY,STATES.PAUSE:
				timer.stop()
				current_state = STATES.RESET
			STATES.FINISHED:
				current_state = STATES.RESET

func set_timer_time(_text) -> void:
	timer_time = 3600 * int(hours_input.text) + 60 * int(minutes_input.text) + int(seconds_input.text)
	timer.start(timer_time)
	current_state = STATES.PLAY
	hours_input.editable =false
	minutes_input.editable =false
	seconds_input.editable =false
	
func display_time(time:int) -> void:
	hours = int(time) / 3600
	minutes = int(time) / 60 - hours * 60
	seconds = int(time) % 60
	hours_input.text = "%02d" % hours
	minutes_input.text = "%02d" % minutes
	seconds_input.text = "%02d" % seconds
	
func _process(_delta: float) -> void:
	match current_state:
		STATES.RESET:
			display_time(timer_time)
		STATES.PAUSE,STATES.PLAY:
			display_time(timer.time_left)
			
