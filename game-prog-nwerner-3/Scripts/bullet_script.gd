extends RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_shape_entered.connect(_collision)
	death_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func death_timer() -> void:
	await get_tree().create_timer(6.5).timeout
	queue_free()

func _collision() -> void:
	queue_free()
