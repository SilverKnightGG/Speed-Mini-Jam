extends Node

enum Fuel {ETERNEON, MALNEON, VOLANTEON, ALL}

var main: Node = null
var ship: ShipEntity = null

var fuel_amounts: Dictionary[Fuel, int] = {
	Fuel.ETERNEON: 0,
	Fuel.MALNEON: 0,
	Fuel.VOLANTEON: 0
	}


func add_fuel(type: Fuel):
	if type == Fuel.ALL:
		f


func _on_ship_entered_warning_area(_area):
	pass


func _on_ship_entered_death_area(_area):
	pass
