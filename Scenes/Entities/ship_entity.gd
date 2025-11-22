class_name ShipEntity extends Entity

const FREE_THRESHOLD = 0.05
const COLORS: Dictionary = {
	Registry.ElementType.ETERNEON: Color.YELLOW,
	Registry.ElementType.MALNEON: Color.MAGENTA,
	Registry.ElementType.VOLANTEON: Color.CYAN
	}

@export var frame_source: AnimatedSprite2D
@export var scale_source: Node2D
@export_range(0.05, 5.0, 0.05) var effect_length_factor: float = 1.0
@export_range(1, 50, 1) var number_of_after_images: int = 12
@export var start_color: Color = Color.WHITE
@export var fade_to_color: Color = Color(1.0, 1.0, 1.0, 0.0)
@export_range(0.1, 2.5, 0.01) var speed_fade_exponent: float = 0.95
@export_range(0.0, 1.0, 0.01) var speed_fade_threshold: float = 0.05
@export var drawing_after_image: bool = false
@export var use_speed_as_alpha: bool = false
@export_range(-5, 5, 1) var relative_z_index: int = 0
var after_images: Array[Sprite2D] = []
var after_image_timers: Array[float] = []
var after_image_durations: Array[float] = []
var after_image_speeds: Array[float] = []
var frames_timer: float = 0.0
var source_speed: float = 0.0
var source_top_speed: float = 0.0
var current_atlas_texture: AtlasTexture
@onready var after_image_duration: float = effect_length_factor
@onready var after_image_separation_time: float = effect_length_factor / number_of_after_images
@onready var speed_lines: Sprite2D = %SpeedLines


# Connect this to a signal that emits when the SpriteFrames' animation changes.
func _on_update_current_animation():
	current_atlas_texture = frame_source.sprite_frames.get_frame_texture(frame_source.animation, frame_source.get_frame())


func _on_update_speed_references(current_speed: float, max_speed: float):
	source_speed = current_speed
	source_top_speed = max_speed


func _process(delta):
	super._process(delta)
	_adjust_after_image_properties(delta)
	speed_lines.material.set_shader_parameter("f_alpha", clampf(mover.current_velocity.x / mover.base_max_speed, 0.0, 0.9))
	if not drawing_after_image: return
	frames_timer -= delta
	if frames_timer <= 0.0:
		frames_timer += after_image_separation_time
		_instantiate_new_after_image()
	
	


func _adjust_after_image_properties(delta: float):
	for i in range(after_images.size()):
		after_image_timers[i] -= delta
		if after_image_timers[i] <= 0.0:
			_remove_last_after_image()
			return # Last index should be the only one to ever return.
		after_images[i].modulate = start_color.lerp(fade_to_color, 1.0 - (after_image_timers[i] / after_image_durations[i]))
		if use_speed_as_alpha:
			after_images[i].modulate.a *= after_image_speeds[i] / pow(source_top_speed, speed_fade_exponent)
			after_images[i].modulate.a -= speed_fade_threshold


func _remove_last_after_image():
	var removing_index: int = after_images.size() - 1
	after_images[removing_index].queue_free()
	after_images.erase(after_images[removing_index])
	after_image_timers.resize(after_images.size())
	after_image_durations.resize(after_images.size())
	after_image_speeds.resize(after_images.size())


func _instantiate_new_after_image():
	var new_after_image: Sprite2D = Sprite2D.new()
	var stage = get_tree().get_first_node_in_group("game stage")
	
	if not is_instance_valid(stage): return
	
	new_after_image.texture = ImageTexture.create_from_image(current_atlas_texture.get_image())
	stage.add_child(new_after_image)
	new_after_image.global_position = global_position
	after_images.push_front(new_after_image)
	after_image_timers.push_front(after_image_duration)
	after_image_durations.push_front(after_image_duration)
	after_image_speeds.push_front(source_speed)
	new_after_image.scale.x = scale_source.scale.x
	new_after_image.z_index = relative_z_index
	new_after_image.modulate.a = 0.0


func _on_stop_drawing_after_images():
	drawing_after_image = false


func _on_start_drawing_after_images():
	drawing_after_image = true


func _on_fuel_changed(new_fuel: Registry.ElementType):
	start_color = COLORS[new_fuel]
	fade_to_color = Color(COLORS[new_fuel], 0.0)


func _ready():
	super._ready()
	Registry.ship = self
	#frame_source.animation_changed.connect(_on_update_current_animation)
	#_on_update_current_animation()
