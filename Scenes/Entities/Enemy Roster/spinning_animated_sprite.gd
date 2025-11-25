class_name SpinningAnimatedSprite extends AnimatedSprite2D

const MIN_ROTATION: float = -6.0
const MAX_ROTATION: float = 6.0
const LOW_THRESHOLD: float = 2.0

const ANIMATIONS: Array[String] = ["spin0", "spin1", "spin2", "spin3"]


func _on_change_rotation(_area = null):
	var new_speed_scale: float = randf_range(MIN_ROTATION, MAX_ROTATION)
	while abs(new_speed_scale) < LOW_THRESHOLD:
		new_speed_scale *= 1.1
	set_speed_scale(new_speed_scale)


func _ready():
	set_animation(ANIMATIONS.pick_random())
	_on_change_rotation()
	play()
