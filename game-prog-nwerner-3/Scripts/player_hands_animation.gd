extends Node3D
@onready var tree : AnimationTree = $AnimationTree

func _ready() -> void:
	tree.active = true
	#SignalManager.animation_state.connect(swap_animation_state)

func _process(delta : float) -> void:
	if Input.is_action_just_pressed("Aim"): #eventual addition for automatic fire
		swap_animation_state("idle", false)
		swap_animation_state("pistol", true)
	if Input.is_action_just_released("Aim"):
		swap_animation_state("idle", true)
		swap_animation_state("pistol", false)

func swap_animation_state(parameter : String, x : bool) -> void:
	printerr(parameter + " " + str(x))
	tree["parameters/conditions/"+parameter] = x
