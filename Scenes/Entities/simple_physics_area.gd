class_name MovementArea extends Area2D

const MIN_WEIGHT_FACTOR := 0.1
const MAX_WEIGHT_FACTOR := 40.0
const DEFAULT_WEIGHT_FACTOR := 1.0
const DEFAULT_SHUNT_WEIGHT := 10.0
const RADIUS_TO_WEIGHT := 1.6
const MAX_EXTERNAL_VELOCITIES_LENGTH := 200.0
const MAX_SHUNT_VELOCITY_LENGTH := 120.0
const SHUNT_DURING_KNOCKBACK_FACTOR := 0.5
const EXTERNAL_ACCELERATION_FACTOR := 80.0
const WEIGHT_FACTOR_CURVE := [2.0, 1.7, 1.445, 1.228, 1.0, 0.772, 0.555, 0.3, 0.1]
const KNOCKBACK_EXPONENT := 2.0
const DEFAULT_RADIUS := 200.0 # 200 for testing
const USE_DEFAULT_VALUE := Vector2(-9999.999, -9999.999)
const FORCE_VALUE_DEFAULTS = {
	Force.GRAVITY: Vector2(0.0, 9.8),
	Force.WIND: Vector2.ZERO,
	Force.ATTRACTIONS: Vector2.ZERO,
	Force.REPULSIONS: Vector2.ZERO
	}


## Applied to the calculation for shunting as a multiplier to allow fine-tuning.
@export_range(MIN_WEIGHT_FACTOR, MAX_WEIGHT_FACTOR, MIN_WEIGHT_FACTOR) var weight_factor = DEFAULT_WEIGHT_FACTOR

## Class for tracking shunt source data so it doesn't have to be re-calculated per-frame.
class ShuntSourceProfile:
	var area: MovementArea
	var shunt_power: float

class ExternalForce:
	var type: Force
	var velocity: Vector2
	var target: Node2D

var stored_shunt_sources: Dictionary[int, ShuntSourceProfile] = {}
var shunt_weight: float = DEFAULT_SHUNT_WEIGHT
var current_velocity: Vector2 = Vector2.ZERO
var external_forces: Array[ExternalForce] = []
var desired_vector2: Vector2 = Vector2.ZERO
var target_node2d: Node2D
var target_direction: Vector2 = Vector2.ZERO
var knockback_velocity: Vector2 = Vector2.ZERO

enum State {STOPPED, IDLE, MOVING, KNOCKBACK, _FLIP_}
var state: State = State.MOVING:
	set(new_state):
		last_state = state
		state = new_state
		state_changed.emit(state, last_state)

@onready var last_state: State = state

signal state_changed(new_state: State)

enum Navigation {TARGETED, DIRECTIONAL, POSITIONAL, UN_DRIVEN}
@export var navigation: Navigation = Navigation.TARGETED:
	set(new_navigation):
		last_navigation = navigation
		navigation = new_navigation
		navigation_changed.emit(navigation)

@onready var last_navigation: Navigation = navigation

signal navigation_changed(new_navigation: Navigation)

## Allows adjusting the child CollisionShape2D's shape radius without having to de-instance the MovementArea scene.
@export_range(1.0, 1920.0, 1.0) var radius: float = DEFAULT_RADIUS:
	set(value):
		radius = value

@export var using_shunting: bool = true

enum Force {WIND, GRAVITY, ATTRACTIONS, REPULSIONS}
@export_subgroup("Using Forces", "using_")
@export var using_wind: bool = true
@export var using_gravity: bool = true
@export var using_attractions: bool = true
@export var using_repulsions: bool = true
var forces_used: Array[Force] = []

## For ballsitic or linear constant speed, set acceleration to a very high value.
@export var base_max_speed: float = 100.0
@onready var max_speed: float = base_max_speed

@export var base_acceleration: float = 100.0
@onready var acceleration: float = base_acceleration


@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var knockback_timer: Timer = %KnockbackTimer

signal offscreen(is_offscreen: bool)


func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if state == State.STOPPED: return
	
	_movement(delta)


func _movement(delta):
	var total_external_velocity: Vector2 = Vector2.ZERO
	
	for force in external_forces:
		if not force.type in forces_used:
			continue
			
		if force.target:
			force.velocity = (force.target.global_position - global_position).normalized() * force.velocity.length()
		
		total_external_velocity += force.velocity
	
	var external_acceleration: float = clampf(total_external_velocity.length(), 0.0, EXTERNAL_ACCELERATION_FACTOR)
	var current_shunt_velocity: Vector2 = _calculate_shunt(delta).limit_length(MAX_SHUNT_VELOCITY_LENGTH) if using_shunting else Vector2.ZERO
	var current_external_velocity = _increase_toward_vector2(Vector2.ZERO, total_external_velocity, external_acceleration * delta).limit_length(MAX_EXTERNAL_VELOCITIES_LENGTH)
	
	match state:
		State.KNOCKBACK:
			var time_remaining: float = knockback_timer.get_time_left()
			var time_factor: float = pow(time_remaining / knockback_timer.get_wait_time(), KNOCKBACK_EXPONENT)
			var current_knockback_velocity: Vector2 = knockback_velocity * time_factor
			
			current_shunt_velocity *= SHUNT_DURING_KNOCKBACK_FACTOR
			current_velocity = current_external_velocity + current_knockback_velocity
	
		State.IDLE:
			current_velocity = current_external_velocity
		
		State.MOVING:
			var velocity_increase: Vector2 = Vector2.ZERO
			
			match navigation:
				Navigation.TARGETED:
					if is_instance_valid(target_node2d):
						velocity_increase = _increase_toward_vector2(current_velocity, target_node2d.global_position, acceleration * delta)
						
				Navigation.DIRECTIONAL:
					velocity_increase = _increase_in_direction(current_velocity, desired_vector2, acceleration * delta)
					
				Navigation.POSITIONAL:
					velocity_increase = _increase_toward_vector2(current_velocity, desired_vector2, acceleration * delta)
				
				Navigation.UN_DRIVEN:
					pass
			
			
			
			var new_movement_velocity: Vector2 = Vector2(velocity_increase).limit_length(max_speed)
			current_velocity = new_movement_velocity + current_external_velocity
	
	global_position += (current_velocity + current_shunt_velocity) * delta


func _calculate_shunt(delta) -> Vector2:
	var incoming_shunt_velocity := Vector2.ZERO
	
	for source in stored_shunt_sources.values():
		if !is_instance_valid(source.area): continue
		
		var direction: Vector2 = global_position - source.area.global_position
		var distance: float = direction.length()
		var shunt_power: float = source.shunt_power
		var overlap: float = shunt_power - distance
		if overlap <= 0.0:
			continue
		
		var time_factor: float = overlap / shunt_power
		var curve_index: int = floori(time_factor * (WEIGHT_FACTOR_CURVE.size() - 1))
		var distance_factor: float = WEIGHT_FACTOR_CURVE[curve_index]
		
		incoming_shunt_velocity += direction.normalized() * distance_factor * source.area.shunt_weight
	
	return incoming_shunt_velocity * delta


func _increase_in_direction(input_velocity: Vector2, direction_vector2: Vector2, acceleration_rate: float) -> Vector2:
	return input_velocity + (direction_vector2.normalized() * acceleration_rate)


func _increase_toward_vector2(input_velocity: Vector2, target_vector2: Vector2, acceleration_rate: float) -> Vector2:
	var delta_vector2: Vector2 = target_vector2 - input_velocity
	
	if delta_vector2.is_zero_approx():
		return input_velocity
	
	return input_velocity + (delta_vector2.normalized() * acceleration_rate)


func _on_knockback_begin(new_knockback_velocity: Vector2):
	if not state == State.KNOCKBACK:
		state = State.KNOCKBACK
	
	knockback_velocity = new_knockback_velocity
	knockback_timer.start()


func _on_end_knockback():
	state = last_state
	knockback_timer.stop()


func _on_receive_new_target_node2d(new_target_node2d: Node2D):
	target_node2d = new_target_node2d
	if not navigation == Navigation.TARGETED:
		navigation = Navigation.TARGETED


func _on_receive_new_desired_vector2(new_desired_vector2: Vector2):
	desired_vector2 = new_desired_vector2
	if not navigation == Navigation.POSITIONAL:
		navigation = Navigation.POSITIONAL
	target_node2d = null


func _on_receive_new_desired_direction(new_desired_direction: Vector2):
	desired_vector2 = new_desired_direction
	if not navigation == Navigation.DIRECTIONAL:
		navigation = Navigation.DIRECTIONAL
	target_node2d = null


func _on_receive_new_trajectory(new_trajectory: Vector2, force_changes: Dictionary):
	current_velocity = new_trajectory * max_speed
	if not navigation == Navigation.UN_DRIVEN:
		navigation = Navigation.UN_DRIVEN
	target_node2d = null


func get_shunt_power(shunting_mover: MovementArea) -> float:
	return collision_shape.shape.radius + shunting_mover.collision_shape.shape.radius


func _add_shunt_source(area: MovementArea):
	if not area.tree_exiting.is_connected(_on_area_tree_exiting):
		area.tree_exiting.connect(_on_area_tree_exiting)
	var profile := ShuntSourceProfile.new()
	profile.area = area
	profile.shunt_power = get_shunt_power(area)
	stored_shunt_sources[area.get_instance_id()] = profile


func _remove_shunt_source(area: MovementArea):
	stored_shunt_sources.erase(area.get_instance_id())


func _on_area_entered(area: Area2D):
	if not area is MovementArea: return
	
	_add_shunt_source(area as MovementArea)


func _on_area_exited(area: Area2D):
	if area is MovementArea:
		_remove_shunt_source(area as MovementArea)
		return
	# we just know it's a pickup, then
	


func _on_area_tree_exiting(area: Node):
	if not area is MovementArea: return
	
	_remove_shunt_source(area as MovementArea)


## Wrapper for add_external_forces for things to not need to know about the internal class ExternalForce.
## Yeah, it's redundant, but it's a happens-once kind of thing it wont hurt to have redundancy for in this way.
func apply_external_force(type: Force, force_velocity: Vector2, target: Node2D = null) -> bool:
	if not type in forces_used:
		return false
	
	var new_external_force: ExternalForce = ExternalForce.new()
	
	new_external_force.type = type
	new_external_force.velocity = force_velocity
	new_external_force.target = target
	
	return add_external_force(new_external_force)


## Thing may be able to add forces directly by referencing our internal class.  If this proves to be so, the wrapper may be of less use, since
## this is the only class that will be using anything like an ExternalForce, so it wont hurt to have another class know about it directly.
func add_external_force(new_force: ExternalForce) -> bool:
	if not new_force.type in forces_used:
		return false
	
	var velocities_included: Array[Vector2] = []
	
	for force in external_forces:
		velocities_included.append(force.velocity)
	
	if not new_force.velocity in velocities_included or not new_force.type == Force.WIND or not new_force.type == Force.GRAVITY:
		external_forces.append(new_force)
		return true
	
	return false


func remove_external_force(force_removing: ExternalForce):
	# Make sure not accidentally removing gravity without authority
	if Force.GRAVITY in forces_used and force_removing.type == Force.GRAVITY:
		print(name, ".remove_external_force -> tried to remove Force.GRAVITY force without authority...")
		print_stack()
		return
	external_forces.erase(force_removing)


func update_type_used_with_optional_value(type: Force, used: bool, new_value: Vector2 = USE_DEFAULT_VALUE):
	if not used:
		forces_used.erase(type)
	elif not type in forces_used:
		forces_used.append(type)
	
	var has_type := false
	for force in external_forces:
		if force.type == type:
			has_type = true
	
	if not ((type == Force.GRAVITY or type == Force.WIND) and has_type):
		var new_force: ExternalForce = ExternalForce.new()
		new_force.type = type
		new_force.velocity = new_value if not new_value == USE_DEFAULT_VALUE else FORCE_VALUE_DEFAULTS[type]
		external_forces.append(new_force)


func update_forces_used(new_forces_used: Array[Force]):
	forces_used = new_forces_used


func _ready():
	if Engine.is_editor_hint(): return
	shunt_weight = collision_shape.shape.radius * RADIUS_TO_WEIGHT * weight_factor
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)
	
	if using_wind: forces_used.append(Force.WIND)
	if using_gravity: forces_used.append(Force.GRAVITY)
	if using_attractions: forces_used.append(Force.ATTRACTIONS)
	if using_repulsions: forces_used.append(Force.REPULSIONS)
	
	# Sibling/Cousin connections
	var entity: Entity = get_parent() # Should error if it's not


func _on_notify_offscreen():
	offscreen.emit(true)


func _on_notify_onscreen():
	offscreen.emit(false)


func _process(_delta):
	if not Engine.is_editor_hint(): return
	if not is_node_ready(): return
	
	var root = get_tree().get_edited_scene_root()
	
	if root == self: return
	
	collision_shape.shape.set_radius(radius)


func set_state(new_state : State = State._FLIP_):
	if new_state == State._FLIP_:
		state = last_state
		return
	
	state = new_state
