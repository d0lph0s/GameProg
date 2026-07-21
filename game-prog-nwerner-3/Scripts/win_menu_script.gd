extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.stage_cleared.connect(win)


func win() -> void:
		show()
		%Time.text = "Time: " + str(GameManager.actual_time) + " s"

func _on_restart_pressed() -> void:
	GameManager.load_level(GameManager.level_1)


func _on_home_pressed() -> void:
	GameManager.load_level(GameManager.main_menu)
