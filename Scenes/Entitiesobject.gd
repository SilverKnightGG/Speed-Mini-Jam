class_name Entity extends Node2D


@onready var mover: MovementArea = %Mover
@onready var sprite: Sprite2D = %MoverSprite
@onready var moving_nodes: MovingNodes = %MovingNodes


func _ready():
	if has_node("InputMovement"): # fast, easy, gross
		get_node("InputMovement").movement_area = mover


func _process(delta):
	moving_nodes.target_position = mover.global_position
