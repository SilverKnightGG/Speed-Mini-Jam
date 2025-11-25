class_name VoidfireWall extends Node2D

const ACCELERATION: float = 0.01
const MIN_VIGNETTE_RADIUS: float = 0.0
const MAX_VIGNETTE_RADIUS: float = 3.0
const COOKING_DISTANCE: float = 680.0
const COOKING_RATIO: float = 390.0


var speed: float = 50.0

var cooking: bool = false
var is_cooked: bool = false
var cooked_amount: float = 1.7
var cookoff_speed: float = 6.0



func _ready():
	%WarningArea.area_entered.connect(Registry._on_ship_entered_warning_area)
	%DeathArea.area_entered.connect(Registry._on_ship_entered_death_area)



func _process(delta):
	speed += ACCELERATION
	position.x += speed * delta
	var ship_position_x: float = Registry.ship.mover.global_position.x
	
	if is_cooked:
		cooked_amount += delta * cookoff_speed
		cookoff_speed += delta
		Registry.death_vignette.set_instance_shader_parameter("radius", cooked_amount)
		return
	
	if cooking:
		Registry.death_vignette.set_instance_shader_parameter(
			"radius",
			((%WarningShape.global_position.x + COOKING_DISTANCE) - ship_position_x) / COOKING_RATIO
		)
	


func _on_warning_area_area_entered(area):
	cooking = true


func _on_death_area_area_entered(area):
	is_cooked = true
	Registry.main.game_over()


func _on_warning_area_area_exited(area):
	if is_cooked:
		return
	cooking = false
	var ship_position_x: float = Registry.ship.mover.global_position.x
	Registry.death_vignette.set_instance_shader_parameter("radius", 0.0)
