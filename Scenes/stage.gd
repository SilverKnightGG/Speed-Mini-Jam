class_name Stage extends Node2D

const MIN_ENTITY_SPAWN_TIME: float = 0.25
const MAX_ENTITY_SPAWN_TIME: float = 10.0
const ENTITY_SPAWN_CURVE: float = 3.8

const MIN_PICKUP_SPAWN_TIME: float = 1.0
const MAX_PICKUP_SPAWN_TIME: float = 20.0
const PICKUP_SPAWN_CURVE: float = 2.4

const PROGRESS_ZENITH: float = 1000.0 # seconds (So, game considers this to be a pivotal point, beyond which things begine getting much harder)
const BASE_ALLOWED_X_OFFSET: float = 1000.0
const SPAWN_OFFSET_VARIANCE: float = 100.0
const VERTICAL_SPAWN_OFFSET_RANGE: float = 324.0

@onready var entity_spawn_timer: Timer = %EntitySpawnTimer
@onready var pickup_spawn_timer: Timer = %PickupSpawnTimer

var progress: float = 0.0


func _process(delta):
	progress += delta


func _on_entity_spawn_timer_timeout():
	entity_spawn_timer.start(ease(randf_range(MIN_ENTITY_SPAWN_TIME, MAX_ENTITY_SPAWN_TIME), ENTITY_SPAWN_CURVE))
	_spawn_entity()


func _on_pickup_spawn_timer_timeout():
	pickup_spawn_timer.start(ease(randf_range(MIN_PICKUP_SPAWN_TIME, MAX_PICKUP_SPAWN_TIME), PICKUP_SPAWN_CURVE))
	_spawn_pickup()


func _spawn_entity():
	var new_entity: Entity = EntityTable.get_entity(progress)
	
	new_entity.global_position = Registry.ship.mover.global_position + Vector2(
		randf_range(BASE_ALLOWED_X_OFFSET, BASE_ALLOWED_X_OFFSET + SPAWN_OFFSET_VARIANCE),
		randf_range(-VERTICAL_SPAWN_OFFSET_RANGE, VERTICAL_SPAWN_OFFSET_RANGE)
		)
	
	add_child(new_entity)


func _spawn_pickup():
	var new_fuel_pickup: FuelPickup = FuelPickup.PACKEDSCENE.instantiate()
	
	new_fuel_pickup.global_position = Registry.ship.mover.global_position + Vector2(
		randf_range(BASE_ALLOWED_X_OFFSET, BASE_ALLOWED_X_OFFSET + SPAWN_OFFSET_VARIANCE),
		randf_range(-VERTICAL_SPAWN_OFFSET_RANGE, VERTICAL_SPAWN_OFFSET_RANGE)
		)
	
	add_child(new_fuel_pickup)


func _ready():
	Registry.stage = self
