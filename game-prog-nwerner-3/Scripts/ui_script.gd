extends Control


func _on_confirm_pressed() -> void:
	visible = true
	$PlayerUI.enemy_killed()
