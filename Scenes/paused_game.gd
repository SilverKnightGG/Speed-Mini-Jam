extends CenterContainer


func paused_toggle(is_paused: bool):
	if is_paused:
		show()
	else:
		hide()
