extends Node

enum ElementType {ETERNEON, MALNEON, VOLANTEON, ALL}

var main: Node = null
var ship: ShipEntity = null

var fuel_amounts: Dictionary[ElementType, int] = {
	ElementType.ETERNEON: 0,
	ElementType.MALNEON: 0,
	ElementType.VOLANTEON: 0
	}


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
