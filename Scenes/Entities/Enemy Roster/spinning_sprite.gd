class_name SpinningSprite extends AnimatedSprite2D

const MIN_ROTATION: float = -16.0
const MAX_ROTATION: float = 16.0

const ANIMATIONS: Array[String] = ["spin0", "spin1", "spin2", "spin3"]



func _on_change_rotation(_area = null):
	set_speed_scale(randf_range(MIN_ROTATION, MAX_ROTATION))


func _ready():
	set_animation(ANIMATIONS.pick_random())
	_on_change_rotation()
	play()
