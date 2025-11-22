class_name BackgroundTile extends Sprite2D

const WRAP_FACTOR: float = 3.0

var width: float = 0.0


func _ready():
	width = texture.get_width()


func _process(_delta):
	if Registry.ship.mover.global_position.x > global_position.x + (width * WRAP_FACTOR) - width:
		global_position.x += (width * WRAP_FACTOR) + width
	elif Registry.ship.mover.global_position.x < global_position.x - (width * WRAP_FACTOR) + width:
		global_position.x -= (width * WRAP_FACTOR) + width
