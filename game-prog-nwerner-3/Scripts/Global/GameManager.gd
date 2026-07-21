extends Node

@onready var level_1 : PackedScene = preload("res://Scenes/Level1.tscn")
@onready var main_menu : PackedScene = preload("res://Scenes/MainMenu.tscn")
@onready var weapon_menu : PackedScene = load("res://Scenes/Weapons.tscn")

#Highscore
var timer : float
var actual_time : float
var timing : bool
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
	if(timing):
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
	var weapon_node : Node3D = WeaponManager.weapon_scene.instantiate()
	weapon_node.get_child(6).hide()
	weapon_node.get_child(0).queue_free()
	weapon_node.get_child(3).queue_free()
	weapon_node.get_child(4).queue_free()
	get_tree().paused = false
	print(get_tree().root)
	#why does this get called when wincondition
	get_tree().root.get_child(-1).find_child("Player").find_child("WeaponOriginPistol").add_child(weapon_node)
	weapon_node.show()
	weapon_node.load_weapon()

func load_level(scene : PackedScene) -> void:
	GameManager.enemy_count = 0
	GameManager.timer = 0
	get_tree().change_scene_to_packed(scene)
	await get_tree().scene_changed
	await get_tree().process_frame
	get_tree().paused = true
	if(scene == level_1):
		timing = true
		await get_tree().process_frame
		start()
	else:
		timing = false
