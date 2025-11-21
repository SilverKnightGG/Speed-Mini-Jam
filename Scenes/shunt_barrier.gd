class_name ShuntBarrier extends Area2D

const MIN_WEIGHT_FACTOR: float = 10.0
const MAX_WEIGHT_FACTOR: float = 400.0
const DEFAULT_WEIGHT_FACTOR: float = 10.0
const DEFAULT_SHUNT_POWER: float = 50.0


## Applied to the calculation for shunting as a multiplier to allow fine-tuning.
@export_range(MIN_WEIGHT_FACTOR, MAX_WEIGHT_FACTOR, MIN_WEIGHT_FACTOR) var weight_factor = DEFAULT_WEIGHT_FACTOR
@export var shunt_power: float = 0.0

class ShuntSourceProfile:
	var area: MovementArea
	var combined_radii: float

var stored_shunt_sources: Dictionary[int, ShuntSourceProfile] = {}

@onready var collision_shape: CollisionShape2D = %CollisionShape2D


func _on_area_tree_exiting():
	pass


func get_shunt_power(shunting_mover: MovementArea) -> float:
	return (shunt_power if shunt_power > 0.0 else DEFAULT_SHUNT_POWER) + shunting_mover.collision_shape.shape.radius


func _add_shunt_source(area: MovementArea):
	if not area.tree_exiting.is_connected(_on_area_tree_exiting):
		area.tree_exiting.connect(_on_area_tree_exiting)
	var profile := ShuntSourceProfile.new()
	profile.area = area
	profile.combined_radii = collision_shape.shape.radius + area.collision_shape.shape.radius
	stored_shunt_sources[area.get_instance_id()] = profile


func _remove_shunt_source(area: MovementArea):
	stored_shunt_sources.erase(area.get_instance_id())


func _on_area_entered(area: Area2D):
	if not area is MovementArea: return
	
	_add_shunt_source(area as MovementArea)
