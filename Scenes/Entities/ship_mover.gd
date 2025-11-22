class_name ShipMover extends MovementArea

const FUEL_SPEEDS = {
	Registry.ElementType.ETERNEON: 0.75,
	Registry.ElementType.MALNEON: 1.5,
	Registry.ElementType.VOLANTEON: 1.0
	}

const TOGGLE_UP: int = 1
const TOGGLE_DOWN: int = -1

var stalling: bool = false:
	set(new_stalling):
		stalling = new_stalling
		
		if stalling:
			state = State.IDLE
			# a switch for allowing Knockback to continue while keeping IDLE as last_state
			if last_state == State.KNOCKBACK:
				state = State.KNOCKBACK
		else:
			state = last_state

@onready var fuel_timer: Timer = %FuelConsumptionTimer


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
		Registry.burning_fuel_type = type


func _toggle_fuel(toggle_sign: int):
	var toggled: bool = false
	var times_checked: int = 0
	while toggled == false:
		Registry.burning_fuel_type = wrapi(Registry.burning_fuel_type + toggle_sign, 0, FUEL_SPEEDS.size()) as Registry.ElementType
		if Registry.fuel_amounts[Registry.burning_fuel_type] > 0:
			toggled = true
		times_checked += 1
		if times_checked > FUEL_SPEEDS.size() - 1:
			Registry.out_of_fuel()


func exhaust_fuel(type: Registry.ElementType):
	if Registry.burning_fuel_type == type:
		_toggle_fuel(TOGGLE_UP)


func set_stalling(value: bool):
	stalling = value


func set_max_speed(type: Registry.ElementType):
	max_speed = base_max_speed * FUEL_SPEEDS[type]
	acceleration = base_acceleration * FUEL_SPEEDS[type]


func _on_fuel_consumption_timer_timeout():
	Registry.use_fuel()
	fuel_timer.start()


func set_phased_out(phased: bool):
	set_collision_layer_value(0, phased)
