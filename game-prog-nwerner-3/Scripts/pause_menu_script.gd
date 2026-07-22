extends Control

func _ready() -> void:
	SignalManager.pause.connect(_paused)
	SignalManager.reset_audio.emit(false)
	#WARUM WIRST DU NICHT ANGEZEIGT

func _on_continue_pressed() -> void:
	GameManager.pause_flip()

func _on_restart_pressed() -> void:
	GameManager.load_level(GameManager.level_1)

func _on_main_menu_pressed() -> void:
	GameManager.load_level(GameManager.main_menu)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _paused(variant : bool) -> void:
	if(variant):
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		hide()
