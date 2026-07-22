extends Control

func _ready() -> void:
	if WeaponManager.weapon_scene == PackedScene.new():
		%Start.disabled = true
	else:
		%Start.disabled = false

func _on_start_pressed() -> void:
	if(!WeaponManager.weapon_scene.get_meta("edited")):
		$AcceptDialog.show()
		return
	GameManager.load_level(GameManager.level_1)

func _on_exit_pressed() -> void:
	get_tree().quit(0)

func _on_weapon_pressed() -> void:
	GameManager.load_level(GameManager.weapon_menu)
