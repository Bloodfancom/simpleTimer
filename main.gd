extends Control
@onready var timer: Timer = %Timer
@onready var hours_input: LineEdit = %hours_input
@onready var minutes_input: LineEdit = %minutes_input
@onready var seconds_input: LineEdit = %seconds_input

@onready var pause_button: Button = %PauseButton
@onready var reset_button: Button = %ResetButton
@onready var new_button: Button = %NewButton
@onready var time_out_sound_player: AudioStreamPlayer = %TimeOutSoundPlayer
@onready var exit_button: Button = %ExitButton

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
	
	hours_input.text_changed.connect(func(input_text) ->void:
		sanitize_timer_time(input_text,hours_input)
	)
	minutes_input.text_changed.connect(func(input_text) -> void:
		sanitize_timer_time(input_text,minutes_input)
	)
	seconds_input.text_changed.connect(func(input_text) -> void:
		sanitize_timer_time(input_text,seconds_input)
	)
	exit_button.pressed.connect(get_tree().quit)
	timer.timeout.connect(func() ->void:
		time_out_sound_player.play()
	)
	time_out_sound_player.finished.connect(reset_timer)
	pause_button.pressed.connect(func() ->void:
		match current_state:
			STATES.RESET,STATES.SET:
				if (hours_input.text != "00" or
					minutes_input.text != "00" or
					seconds_input.text != "00"
					):
					set_timer_time("")
			STATES.PLAY:
				timer.paused = true
				current_state =STATES.PAUSE
			STATES.PAUSE:
				timer.paused = false
				current_state = STATES.PLAY
		)
	
	new_button.pressed.connect(func() -> void:
		timer_time = 0
		timer.stop()
		current_state = STATES.SET
		display_time(0)
		hours_input.editable = true
		minutes_input.editable = true
		seconds_input.editable = true
		)
	
	reset_button.pressed.connect(reset_timer)
	

func char_is_not_number(character) -> bool:
	return character not in "0123456789 "

#This is stupid but it works
func sanitize_numbers(input_field :LineEdit) ->void:
	for i in input_field.text.length():
		print(input_field.text)
		if char_is_not_number(input_field.text[i]):
			input_field.text[i] = " "
	input_field.text = input_field.text.strip_edges()
			
func sanitize_timer_time(input_char,input_field) ->void:
	if char_is_not_number(input_char):
		sanitize_numbers(input_field)

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
	timer.paused = false
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
		STATES.SET:
			pause_button.text = "Start"
			reset_button.visible = false
			new_button.visible = false
		STATES.PLAY:
			display_time(timer.time_left)
			pause_button.text = "Pause"
			reset_button.visible = true
			new_button.visible = true
		STATES.RESET:
			pause_button.text = "Start"
			display_time(timer_time)
			reset_button.visible = false
			new_button.visible = true
		STATES.PAUSE:
			display_time(timer.time_left)
			pause_button.text = "Play"
			reset_button.visible = true
			new_button.visible = true
