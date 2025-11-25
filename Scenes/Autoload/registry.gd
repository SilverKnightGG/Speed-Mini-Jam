extends Node

# autload
const CLEAR_DISTANCE: float = 800.0

enum ElementType {ETERNEON, MALNEON, VOLANTEON, ALL}

var main: Node = null
var ship: ShipEntity = null
var death_vignette: TextureRect = null

var depleted: bool = false
var fuel_amounts: Dictionary[ElementType, int] = {
	ElementType.ETERNEON: 10,
	ElementType.MALNEON: 10,
	ElementType.VOLANTEON: 10
	}:
		set(new_fuel_amounts):
			fuel_amounts = new_fuel_amounts
			depleted = true
			for amount in fuel_amounts.values():
				if amount > 0:
					depleted = false
					ship.mover.set_stalling(false)
					return
			ship.mover.set_stalling(true)

var burning_fuel_type: ElementType = ElementType.ETERNEON:
	set(new_type):
		burning_fuel_type = new_type
		
		ship.mover.set_max_speed(burning_fuel_type)


func use_fuel():
	fuel_amounts[burning_fuel_type] = clampi(fuel_amounts[burning_fuel_type] - 1, 0, INF)
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
	main.get_tree().reload_current_scene()
