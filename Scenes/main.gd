extends Node


const STAGE_SCENE: PackedScene = preload("uid://ctwu80l76nigy")

var current_stage: Stage = null

@onready var splash: CenterContainer = %Splash
@onready var paused_game: CenterContainer = %PausedGame


#region State
enum State {SPLASH, STAGE, PAUSED, CREDITS}
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
		
		match state:
			State.SPLASH:
				_enter_splash()
			State.STAGE:
				_enter_stage()
			State.CREDITS:
				_enter_credits()
			State.PAUSED:
				_enter_paused()
		
var last_state: State = State.SPLASH


func _enter_stage():
	if current_stage == null:
		current_stage = STAGE_SCENE.instantiate()
		add_child(current_stage)


func _leave_stage():
	if not state == State.PAUSED:
		if is_instance_valid(current_stage):
			current_stage.queue_free()


func _enter_splash():
	splash.show()


func _enter_paused():
	get_tree().set_pause(true)
	paused_game.paused_toggle(true)


func _leave_paused():
	get_tree().set_pause(false)
	paused_game.paused_toggle(false)


func _leave_splash():
	splash.hide()


func _enter_credits():
	pass


func _leave_credits():
	pass
#endregion State


func _input(event):
	if event.is_action_released("ui_accept") or event is InputEventMouseButton:
		state = State.STAGE if state == State.SPLASH else State.PAUSED


func _ready():
	Registry.main = self
