extends VBoxContainer

const BAR_HEIGHT: float = 20.0

func update_fuel(fuels: Array[int]):
	#prints("fuels sent to fuel display:", str(fuels))
	var total_fuel: int = fuels[0] + fuels[1] + fuels[2]
	var ratios: Array[float] = [
		float(fuels[0]) / float(total_fuel),
		float(fuels[1]) / float(total_fuel),
		float(fuels[2]) / float(total_fuel)
		]
	var width = get_rect().size.x
	
	#prints("Sizes are:\n", str(ratios[0] * width), "\n", str(ratios[1] * width), "\n", str(ratios[2] * width))
	
	%EterneonFuel.set_custom_minimum_size(Vector2(ratios[0] * width, BAR_HEIGHT))
	%MalneonFuel.set_custom_minimum_size(Vector2(ratios[1] * width, BAR_HEIGHT))
	%VolanteonFuel.set_custom_minimum_size(Vector2(ratios[2] * width, BAR_HEIGHT))
	
	%EterneonFuel.force_update_transform()
	%MalneonFuel.force_update_transform()
	%MalneonFuel.force_update_transform()
	
	%EterneonFuel.label.text = str(fuels[0])
	%MalneonFuel.label.text = str(fuels[1])
	%VolanteonFuel.label.text = str(fuels[2])


func _ready():
	Registry.fuel_display = self


func burning(type: Registry.ElementType):
	var panels: Array[PanelContainer] = [%EterneonFuel, %MalneonFuel, %VolanteonFuel]
	
	for p in range(panels.size()):
		if p == (type as int):
			panels[p].gradient.show()
		else:
			panels[p].gradient.hide()
			
	
	
