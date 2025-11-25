class_name FuelPickup extends Area2D

const FUEL_AMOUNT_MIN: int = 1
const FUEL_AMOUNT_MAX: int = 10
const FUEL_RANDOM_CURVE: float = 4.0 # ease-in (lower = more common, higher = more rare)
const PACKEDSCENE: PackedScene = preload("uid://b2ro5xkrlswat")


const FUEL_TEXTURE_SIZE: Vector2 = Vector2(64.0, 64.0)
const TEXTURE_REGIONS = {
	Registry.ElementType.ETERNEON: Rect2(Vector2.ZERO, FUEL_TEXTURE_SIZE),
	Registry.ElementType.MALNEON:  Rect2(Vector2(64.0, 0.0), FUEL_TEXTURE_SIZE),
	Registry.ElementType.VOLANTEON:  Rect2(Vector2(0.0, 64.0), FUEL_TEXTURE_SIZE),
	Registry.ElementType.ALL:  Rect2(FUEL_TEXTURE_SIZE, FUEL_TEXTURE_SIZE)
	}

@onready var fuel_sprite: Sprite2D = %FuelSprite
var fuel_amount: int = 1


var type: Registry.ElementType:
	set(new_type):
		type = new_type
		if not is_instance_valid(fuel_sprite):
			return
		
		fuel_sprite.set_region_rect(TEXTURE_REGIONS[type])


func _ready():
	if not fuel_sprite.region_enabled:
		fuel_sprite.set_region_enabled(true)
	
	type = (Registry.ElementType.values().pick_random()) as int
	# fast and dirty reroll to make ALL more rare to actually happen (so, it's a 6.25% chance)
	#if type == Registry.ElementType.ALL:
		#type = (Registry.ElementType.values().pick_random())
	if type == Registry.ElementType.ALL:
		fuel_sprite.set_instance_shader_parameter("all_colors", true);
		fuel_sprite.get_child(0).show()
	
	fuel_amount = ceili(ease(randf(), FUEL_RANDOM_CURVE) * FUEL_AMOUNT_MAX)


func _on_area_entered(_ship_area: Area2D):
	Registry.add_fuel(type, fuel_amount)
	queue_free()
