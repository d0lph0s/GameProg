extends Control

func _ready() -> void:
	SignalManager.death.connect(died)

func died() -> void:
	show()
	$HBoxContainer/VBoxContainer/TextureRect.speed = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_pressed() -> void:
	GameManager.load_level(GameManager.level_1)


func _on_home_pressed() -> void:
	GameManager.load_level(GameManager.main_menu)
