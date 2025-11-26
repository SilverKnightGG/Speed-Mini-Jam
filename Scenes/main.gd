extends Node


const STAGE_SCENE: PackedScene = preload("uid://ctwu80l76nigy")
const GAME_OVER_TIME: float = 2.0
const GAME_OVER_FADE_IN_FACTOR: float = 0.33
const CREDITS_TIME: float = 4.0

var current_stage: Stage = null
var is_game_over: bool = false
var continue_credits: bool = false

@onready var splash: CenterContainer = %Splash
@onready var paused_game: CenterContainer = %PausedGame


#region State
enum State {SPLASH, STAGE, PAUSED, GAME_OVER, CREDITS}
var state: State = State.SPLASH:
	set(new_state):
		last_state = state
		state = new_state
		
		match last_state:
			State.SPLASH:
				_leave_splash()
			State.STAGE:
				_leave_stage()
			State.CREDITS:
				_leave_credits()
			State.PAUSED:
				_leave_paused()
			State.GAME_OVER:
				_leave_game_over()
		
		match state:
			State.SPLASH:
				_enter_splash()
			State.STAGE:
				_enter_stage()
			State.CREDITS:
				_enter_credits()
			State.PAUSED:
				_enter_paused()
			State.GAME_OVER:
				_enter_game_over()
		
var last_state: State = State.SPLASH


func _enter_stage():
	if current_stage == null:
		current_stage = STAGE_SCENE.instantiate()
		add_child(current_stage)
		%StageAudioStreamPlayer.play()


func _leave_stage():
	if not state == State.PAUSED:
		if is_instance_valid(current_stage):
			current_stage.queue_free()
			%StageAudioStreamPlayer.stop()


func _enter_splash():
	splash.show()
	%MainAudioStreamPlayer.play()


func _enter_paused():
	get_tree().set_pause(true)
	paused_game.paused_toggle(true)


func _leave_paused():
	get_tree().set_pause(false)
	paused_game.paused_toggle(false)


func _leave_splash():
	splash.hide()
	%MainAudioStreamPlayer.stop()


func _enter_credits():
	%GameOverTimer.start(CREDITS_TIME)
	%Credits.show()


# Academic...should never enter, because scene is reloaded
func _leave_credits():
	pass


func _enter_game_over():
	is_game_over = true
	%GameOverTimer.start(GAME_OVER_TIME)
	%MainAudioStreamPlayer.play()


func _leave_game_over():
	continue_credits = false
	%GameOver.hide()


#endregion State


func _input(event):
	if event.is_action_released("ui_accept") or event.is_action_released("MOUSE_CLICK"):
		match state:
			State.STAGE:
				state = State.PAUSED
			State.PAUSED:
				state = State.STAGE
			State.SPLASH:
				state = State.STAGE
			State.GAME_OVER:
				if continue_credits:
					state = State.CREDITS
			State.CREDITS:
				if continue_credits:
					Registry.restart()
	
	if event.is_action_released("ui_cancel"):
		match state:
			State.PAUSED:
				Registry.restart()
			State.SPLASH:
				get_tree().quit()
			State.CREDITS:
				get_tree().quit()


func _ready():
	Registry.main = self
	Registry.death_vignette = %DeathVignette
	state = State.SPLASH


func _process(delta):
	if not is_game_over:
		return
	
	%GameOver.modulate.a = clampf(%GameOver.modulate.a + delta * GAME_OVER_FADE_IN_FACTOR, 0.0, 1.0)


func game_over():
	state = State.GAME_OVER


func _on_game_over_timer_timeout():
	print("game over timer timeout")
	continue_credits = true
	if state == State.CREDITS:
		%RestartIndicator.show()
	if state == State.GAME_OVER:
		%ContinueToCreditsIndicator.show()
