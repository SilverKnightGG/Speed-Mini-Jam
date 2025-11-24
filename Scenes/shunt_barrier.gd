class_name ShuntBarrier extends Area2D

const MIN_WEIGHT_FACTOR: float = 10.0
const MAX_WEIGHT_FACTOR: float = 400.0
const DEFAULT_WEIGHT_FACTOR: float = 10.0
const DEFAULT_SHUNT_POWER: float = 50.0


## Applied to the calculation for shunting as a multiplier to allow fine-tuning.
@export_range(MIN_WEIGHT_FACTOR, MAX_WEIGHT_FACTOR, MIN_WEIGHT_FACTOR) var weight_factor = DEFAULT_WEIGHT_FACTOR
@export var shunt_power: float = 0.0
var shunt_weight: float = 85.0

class ShuntSourceProfile:
	var area: Area2D
	var combined_radii: float

var stored_shunt_sources: Dictionary[int, ShuntSourceProfile] = {}

@onready var collision_shape: CollisionShape2D = %CollisionShape2D


func _on_area_tree_exiting():
	pass


func get_perpendicular_offset(origin: Vector2, axis_y: bool = true) -> Vector2:
	if axis_y:
		return Vector2(origin.x, global_position.y)
	else:
		return Vector2(global_position.x, origin.y)


func get_shunt_power() -> float:
	return (shunt_power if shunt_power > 0.0 else DEFAULT_SHUNT_POWER) + (collision_shape.shape.size.y / 2.0)


func _add_shunt_source(area: MovementArea):
	if not area.tree_exiting.is_connected(_on_area_tree_exiting):
		area.tree_exiting.connect(_on_area_tree_exiting)
	var profile := ShuntSourceProfile.new()
	profile.area = area
	profile.combined_radii = get_shunt_power() + area.get_shunt_power()
	stored_shunt_sources[area.get_instance_id()] = profile


func _remove_shunt_source(area: MovementArea):
	stored_shunt_sources.erase(area.get_instance_id())


func _on_area_entered(area: Area2D):
	if not area is MovementArea: return
	
	prints("collision detected")
	
	_add_shunt_source(area as MovementArea)
