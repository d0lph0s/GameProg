extends Control

func _on_start_pressed() -> void:
	GameManager.load_level(GameManager.level_1)

func _on_exit_pressed() -> void:
	get_tree().quit(0)
