extends Node

#Game Variables
var current_level : int
var enemy_count : int
#Settings
var Mouse_Sensitivity : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.enemy_killed.connect(enemy_killed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("Escape")):
		get_tree().paused = true

func enemy_killed() -> void:
	enemy_count -= 1
	if(enemy_count <= 0):
		stage_cleared()

func stage_cleared() -> void:
	SignalManager.stage_cleared.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().physics_frame
	get_tree().paused = true
