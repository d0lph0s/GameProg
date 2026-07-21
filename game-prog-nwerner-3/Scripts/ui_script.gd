extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.stage_cleared.connect(_on_stage_cleared)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Escape")):
		visible = false


func _on_confirm_pressed() -> void:
	visible = true
	$PlayerUI.enemy_killed()

func _on_stage_cleared() -> void:
	$PlayerUI.hide()
