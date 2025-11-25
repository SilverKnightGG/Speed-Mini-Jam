extends Node

# autload
const CLEAR_DISTANCE: float = 800.0

enum ElementType {ETERNEON, MALNEON, VOLANTEON, ALL}

var main: Node = null
var ship: ShipEntity = null
var death_vignette: TextureRect = null
var is_cooked: bool = false
var cooked_amount: float = 1.7
var cookoff_speed: float = 6.0

var depleted: bool = false
var fuel_amounts: Dictionary[ElementType, int] = {
	ElementType.ETERNEON: 10,
	ElementType.MALNEON: 10,
	ElementType.VOLANTEON: 10
	}:
		set(new_fuel_amounts):
			fuel_amounts = new_fuel_amounts
			depleted = true
			if not is_instance_valid(ship):
				return
			for amount in fuel_amounts.values():
				if amount > 0:
					depleted = false
					ship.mover.set_stalling(false)
					return
			ship.mover.set_stalling(true)

var burning_fuel_type: ElementType = ElementType.ETERNEON:
	set(new_type):
		burning_fuel_type = new_type
		if not is_instance_valid(ship):
			return
		ship.mover.set_max_speed(burning_fuel_type)


func use_fuel():
	fuel_amounts[burning_fuel_type] = clampi(fuel_amounts[burning_fuel_type] - 1, 0, 9999)
	if fuel_amounts[burning_fuel_type] < 1:
		ship.mover._toggle_fuel(ShipMover.TOGGLE_UP)


func add_fuel(type: ElementType, amount: int):
	if type == ElementType.ALL:
		for ftype in [ElementType.ETERNEON, ElementType.MALNEON, ElementType.VOLANTEON]:
			fuel_amounts[ftype] += amount
	else:
		fuel_amounts[type] += amount


func _on_ship_entered_warning_area(_area):
	pass


func _on_ship_entered_death_area(_area):
	pass


func out_of_fuel():
	pass


func restart():
	fuel_amounts = {
	ElementType.ETERNEON: 10,
	ElementType.MALNEON: 10,
	ElementType.VOLANTEON: 10
	}
	depleted = false
	burning_fuel_type = ElementType.ETERNEON
	is_cooked = false
	main.get_tree().reload_current_scene()


func _process(delta):
	if is_cooked:
		cooked_amount += delta * cookoff_speed
		cookoff_speed += delta
		death_vignette.set_instance_shader_parameter("radius", cooked_amount)
