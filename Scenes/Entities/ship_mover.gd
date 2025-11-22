class_name ShipMover extends MovementArea

const FUEL_SPEEDS = {
	Registry.ElementType.ETERNEON: 0.75,
	Registry.ElementType.MALNEON: 1.5,
	Registry.ElementType.VOLANTEON: 1.0
	}

var burning_fuel_type: Registry.ElementType = Registry.ElementType.ETERNEON:
	set(new_type):
		burning_fuel_type = new_type
		
		max_speed


const TOGGLE_UP: int = 1
const TOGGLE_DOWN: int = -1

func _unhandled_input(event):
	if event.is_action_released("FUEL_TOGGLE_UP"):
		_toggle_fuel(TOGGLE_UP)
	if event.is_action_released("FUEL_TOGGLE_DOWN"):
		_toggle_fuel(TOGGLE_DOWN)
	if event.is_action_released("FUEL_ETERNEON"):
		_switch_fuel(Registry.ElementType.ETERNEON)
	if event.is_action_released("FUEL_MALNEON"):
		_switch_fuel(Registry.ElementType.MALNEON)
	if event.is_action_released("FUEL_VOLANTEON"):
		_switch_fuel(Registry.ElementType.VOLANTEON)


func _switch_fuel(type: Registry.ElementType):
	if Registry.fuel_amounts[type] > 0:
		burning_fuel_type = type


func _toggle_fuel(toggle_sign: int):
	var toggled: bool = false
	var times_checked: int = 0
	while toggled == false:
		burning_fuel_type = wrapi(burning_fuel_type + toggle_sign, 0, FUEL_SPEEDS.size())
		if Registry.fuel_amounts[burning_fuel_type] > 0:
			toggled = true
		times_checked += 1
		if times_checked > FUEL_SPEEDS.size() - 1:
			Registry.out_of_fuel()


func exhaust_fuel(type: Registry.ElementType):
	if burning_fuel_type == type:
		_toggle_fuel(TOGGLE_UP)
