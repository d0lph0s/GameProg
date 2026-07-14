extends Node

#Game Variables
var current_level : int
var enemy_count : int
#Settings
var Mouse_Sensitivity : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Escape")):
		get_tree().paused = true
