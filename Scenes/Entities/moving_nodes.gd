class_name MovingNodes extends Node2D


const JITTER_CORRECTION_DISTANCE := 150.0
const JITTER_CURVE := preload("uid://t3qh5yb1qjje")

var target_position: Vector2 = Vector2.ZERO


func _on_flip(new_flip_scale: Vector2):
	scale = new_flip_scale


func _process(_delta):
	if target_position == Vector2.ZERO: return
	
	var distance = global_position.distance_to(target_position)
	
	var correction = clampf(distance / JITTER_CORRECTION_DISTANCE, 0.0, 1.0)
	var correction_factor = JITTER_CURVE.sample(correction)
	
	global_position = global_position.lerp(target_position, correction_factor)


func _ready():
	pass
	#%FlipSprite.play("default") # NOTE replace with more robust animation handling.
