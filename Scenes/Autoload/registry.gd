extends Node

enum ElementType {ETERNEON, MALNEON, VOLANTEON, ALL}

var main: Node = null
var ship: ShipEntity = null

var depleted: bool = false
var fuel_amounts: Dictionary[ElementType, int] = {
	ElementType.ETERNEON: 0,
	ElementType.MALNEON: 0,
	ElementType.VOLANTEON: 0
	}:
		set(new_fuel_amounts):
			fuel_amounts = new_fuel_amounts
			depleted = true
			for amount in fuel_amounts.values():
				if amount > 0:
					depleted = false
					ship.mover.stalling(false)
					return
			ship.mover.stalling(true)


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
