extends Node

@onready var level_1 : PackedScene = preload("res://Scenes/Level1.tscn")
@onready var main_menu : PackedScene = preload("res://Scenes/MainMenu.tscn")

#Highscore
var timer : float
var actual_time : float
#Game Variables
var current_level : int
var enemy_count : int
#Settings
var Mouse_Sensitivity : float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	SignalManager.enemy_killed.connect(enemy_killed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	highscore_timer()
	
	if (Input.is_action_just_pressed("Escape")):
		get_tree().paused = true

func highscore_timer() -> void:
	timer += 1.0
	actual_time = snappedf((timer/60.0), 0.001)

func enemy_killed() -> void:
	enemy_count -= 1
	if(enemy_count <= 0):
		stage_cleared()

func stage_cleared() -> void:
	SignalManager.stage_cleared.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().physics_frame
	get_tree().paused = true

func death() -> void:
	SignalManager.death.emit()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().physics_frame
	get_tree().paused = true

func start() -> void:
	get_tree().paused = false
	timer = 0.0

func load_level(scene : PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
	await get_tree().scene_changed
	await get_tree().process_frame
	get_tree().paused = true
	
