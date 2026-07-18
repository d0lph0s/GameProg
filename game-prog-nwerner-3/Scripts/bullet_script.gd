extends RigidBody3D

var regular_hit_color : Color = Color(0.773, 0.0, 0.0, 1.0)
var bonus_hit_color : Color = Color(0.532, 0.0, 1.552, 1.0)
var timer : Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.add_child(timer)
	self.body_entered.connect(_collision)
	timer.wait_time = 1.25
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
	var current_position = global_position
	if(body.has_meta("Enemy")):
		var bonus : int
		var final_damage : int = int(WeaponManager.damage() - body.armor)
		body.take_damage(final_damage)
		body.display_damage(final_damage, current_position, regular_hit_color)
		if body.get_meta("Type") == WeaponManager.ammunition_type:
			bonus = 5
			body.take_damage(bonus)
			body.display_damage(bonus, current_position, bonus_hit_color)
		
		
	elif body.has_meta("Player"):
		pass
	else:
		pass
	queue_free()
