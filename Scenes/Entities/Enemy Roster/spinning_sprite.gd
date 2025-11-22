class_name SpinningSprite extends Sprite2D

const MIN_ROTATION: float = -16.0
const MAX_ROTATION: float = 16.0
const ROTATE_INCREMENT: float = TAU / 8.0
const SHEET_FRAME_XorY: Array[int] = [0, 1, 2, 3]

const TEXTURES: Dictionary[Texture, float] = { # [Sheet: frame size]
	preload("uid://dxln0654duf5u"): 64.0,
	preload("uid://c2hpf5845temy"): 64.0,
	preload("uid://s7d43f5a2u0x"): 32.0,
	}

var rotation_rate: float = 0.0
var frame_time: float = 1.0


func _on_change_rotation(_area = null):
	rotation_rate = round(randf_range(MIN_ROTATION, MAX_ROTATION))


func _on_choose_sprite():
	var texture_to_use: Texture = TEXTURES.keys().pick_random()
	var size: float = TEXTURES[texture_to_use] # gives size value
	var row: int = SHEET_FRAME_XorY.pick_random()
	var column: int = SHEET_FRAME_XorY.pick_random()
	
	set_region_rect(Rect2(Vector2(size * column, size * row), Vector2(size, size)))


func _process(delta):
	frame_time -= delta * abs(rotation_rate)
	if frame_time < 0.0:
		frame_time += 1.0
		rotation = rotation + ROTATE_INCREMENT if rotation_rate > 0.0 else rotation - ROTATE_INCREMENT


func _ready():
	_on_change_rotation()
	_on_choose_sprite()
