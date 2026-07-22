extends Control

func _ready() -> void:
	SignalManager.death.connect(died)

func died() -> void:
	show()
	%GIF.process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().process_frame

	%GIF.speed = 0.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_pressed() -> void:
	%GIF.process_mode = Node.PROCESS_MODE_DISABLED
	GameManager.load_level(GameManager.level_1)


func _on_home_pressed() -> void:
	%GIF.process_mode = Node.PROCESS_MODE_DISABLED
	GameManager.load_level(GameManager.main_menu)
