class_name Stage extends Node2D

const MIN_ENTITY_SPAWN_TIME: float = 0.25
const MAX_ENTITY_SPAWN_TIME: float = 15.0
const ENTITY_SPAWN_CURVE: float = 3.8

const MIN_PICKUP_SPAWN_TIME: float = 1.0
const MAX_PICKUP_SPAWN_TIME: float = 25.0
const PICKUP_SPAWN_CURVE: float = 5.0

@onready var entity_spawn_timer: Timer = %EntitySpawnTimer
@onready var pickup_spawn_timer: Timer = %PickupSpawnTimer


func _on_entity_spawn_timer_timeout():
	entity_spawn_timer.start(ease(randf_range(MIN_ENTITY_SPAWN_TIME, MAX_ENTITY_SPAWN_TIME), ENTITY_SPAWN_CURVE))
	_spawn_entity()


func _on_pickup_spawn_timer_timeout():
	pickup_spawn_timer.start(ease(randf_range(MIN_PICKUP_SPAWN_TIME, MAX_PICKUP_SPAWN_TIME), PICKUP_SPAWN_CURVE))
	_spawn_pickup()


func _spawn_entity():
	pass


func _spawn_pickup():
	pass
