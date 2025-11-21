class_name InputMovement extends Node

var move_velocity: Vector2 = Vector2.ZERO

var movement_area: MovementArea

signal flip(scale_to: Vector2)


func _process(delta):
	if not is_instance_valid(movement_area):
		return
	
	var vector_pressed: Vector2 = Vector2.ZERO
	
	match movement_area.state:
		MovementArea.State.IDLE, MovementArea.State.STOPPED:
			move_velocity = Vector2.ZERO
		MovementArea.State.MOVING:
			vector_pressed = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN").round() # always needs 1.0 or 0.0 value in each component
			prints("input vector_pressed =", str(vector_pressed))
			if not vector_pressed.x == 0.0:
				flip.emit(Vector2(vector_pressed.x / abs(vector_pressed.x), 1.0))

	movement_area._on_receive_new_desired_direction(vector_pressed)
