class_name AggressiveBehavior extends Node

const UPDATE_FREQUENCY = 0.3
var update_timer: float = 0.1 # Nudged to just above zero to cover potential weird edge-case (I want to think of a better solution, or rule out needing this)
var current_position: Vector2 = Vector2.ZERO
var player_ship: ShipEntity


signal position_updated(new_position: Vector2)


func _is_behind() -> bool:
	return true if owner.mover.global_position.x < Registry.ship.mover.global_position.x else false


func _reset_update_timer():
	update_timer = UPDATE_FREQUENCY


func _get_base_tracking_position() -> Vector2:
	return player_ship.global_position


func _process(delta):
	if _is_behind():
		return
	
	update_timer -= delta
	
	if update_timer > 0.0:
		return
	
	_reset_update_timer()
	position_updated.emit(_get_base_tracking_position())


func _ready():
	_reset_update_timer()
