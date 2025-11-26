extends Node

# autload
const CLEAR_DISTANCE: float = 800.0

enum ElementType {ETERNEON, MALNEON, VOLANTEON, ALL}

const ELEMENT_COLORS: Dictionary[ElementType, Color] = {
	ElementType.ETERNEON: Color.YELLOW,
	ElementType.MALNEON: Color.MAGENTA,
	ElementType.VOLANTEON: Color.CYAN
	}

var main: Node = null
var ship: ShipEntity = null
var death_vignette: TextureRect = null
var stage: Node2D = null
var fuel_display: Control = null
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
	
	if is_instance_valid(fuel_display):
		fuel_display.update_fuel(fuel_amounts.values())


func add_fuel(type: ElementType, amount: int):
	if type == ElementType.ALL:
		for ftype in [ElementType.ETERNEON, ElementType.MALNEON, ElementType.VOLANTEON]:
			fuel_amounts[ftype] += amount
	else:
		fuel_amounts[type] += amount
	
	if is_instance_valid(fuel_display):
		fuel_display.update_fuel(fuel_amounts.values())
	
	if not ship.mover.state == MovementArea.State.MOVING:
		if not ship.mover.state == MovementArea.State.KNOCKBACK:
			ship.mover.state = MovementArea.State.MOVING
		else:
			ship.mover.last_state = MovementArea.State.MOVING # instead of idle


func out_of_fuel():
	if not ship.mover.state == MovementArea.State.KNOCKBACK:
		ship.mover.state = MovementArea.State.IDLE
	else:
		ship.mover.last_state = MovementArea.State.IDLE


func set_new_burning_fuel_type(type: ElementType):
	burning_fuel_type = type
	if is_instance_valid(fuel_display):
		fuel_display.burning(type)
	ship.start_color = ELEMENT_COLORS[type]
	ship.fade_to_color = Color(ELEMENT_COLORS[type], 0.0)


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
