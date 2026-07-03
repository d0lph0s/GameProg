extends RigidBody3D

var timer : Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_child(timer)
	self.body_entered.connect(_collision)
	timer.wait_time = 6.5
	sleeping = false
	death_timer()
	
	#LAYER DEPENDING ON ENEMY OR PLAYER ORIGIN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func death_timer() -> void:
	timer.start()
	await timer.timeout
	queue_free()

func _collision(body : Node) -> void:
	if(body.has_meta("Enemy")):
		body.take_damage(20)
	queue_free()
