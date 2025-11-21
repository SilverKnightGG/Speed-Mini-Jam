extends Node

#region State
enum State {SPLASH, STAGE, CREDITS}
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
		
		match state:
			State.SPLASH:
				_enter_splash()
			State.STAGE:
				_enter_stage()
			State.CREDITS:
				_enter_credits()
		
var last_state: State = State.SPLASH


func _enter_stage():
	pass


func _leave_stage():
	pass


func _enter_splash():
	pass


func _leave_splash():
	pass


func _enter_credits():
	pass


func _leave_credits():
	pass
#endregion State


func _input(event):
	pass


func _ready():
	Registry.main = self
