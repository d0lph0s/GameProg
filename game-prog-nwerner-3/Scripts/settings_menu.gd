extends Control


# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Settings"):
		flip_visibility()

func _on_sensitivity_drag_ended(value_changed: bool) -> void:
	GameManager.Mouse_Sensitivity = %Sensitivity.value

func _on_master_value_changed(value: float) -> void:
	GameManager.Master_Volume = %Master.value
	AudioServer.set_bus_volume_linear(0, GameManager.Master_Volume)

func _on_music_value_changed(value: float) -> void:
	GameManager.Music_Volume = %Music.value
	AudioServer.set_bus_volume_linear(2, GameManager.Music_Volume)

func _on_sfx_drag_ended(value_changed: bool) -> void:
	GameManager.Sfx_Volume = %Sfx.value
	AudioServer.set_bus_volume_linear(1, GameManager.Sfx_Volume)

func flip_visibility() -> void:
	visible = !visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await get_tree().process_frame
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		
	else:
		if(get_tree().current_scene.name == "MainMenu"):
			return
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_exit_pressed() -> void:
	flip_visibility()
