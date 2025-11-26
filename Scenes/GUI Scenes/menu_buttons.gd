extends VBoxContainer


func _on_back_pressed():
	_go_back()


func _on_exit_pressed():
	_quit()


func _go_back():
	Registry.restart()


func _quit():
	get_tree().quit()
