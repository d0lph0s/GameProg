extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true
	SignalManager.movement.connect(movement)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func movement(type : int):
	match type:
		0:
			animation_tree.set("parameters/conditions/idle", true)
			animation_tree.set("parameters/conditions/walk", false)
		1:
			animation_tree.set("parameters/conditions/idle", false)
			animation_tree.set("parameters/conditions/walk", true)
		_:
			pass
