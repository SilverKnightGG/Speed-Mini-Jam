extends CenterContainer


@onready var start: TextureRect = %Start
@onready var click_or_enter: TextureRect = %ClickOrEnter
@onready var flash_timer: Timer = %FlashTimer


func _ready():
	flash_timer.start()


func _on_flash_timer_timeout():
	flash_timer.start()
	
	if start.visible:
		start.hide()
		click_or_enter.show()
	else:
		click_or_enter.hide()
		start.show()
