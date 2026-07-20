extends CharacterBody3D

@onready var head : Node3D = $CameraHead
@onready var hands : Node3D = $Mesh/PlayerHands
@onready var mesh : Node3D = $Mesh


@export_category("Player Stats")
@export var health : int
@export var max_health : int
@export var walk_speed : float
@export var sprint_speed : float
@export var crouch_speed : float
@export var aim_speed : float

var speed : float
var direction : Vector3
const JUMP_VELOCITY : float = 2.75

func _ready() -> void:

	health = max_health

	SignalManager.ammo_used.emit()
	PlayerManager.current_health = health
	SignalManager.damage_taken.emit()


func take_damage(damage : int) -> void:
	health -= damage
	PlayerManager.current_health = health
	SignalManager.damage_taken.emit()
	if(health > 0):
		return
	if(health >= 0):
		SignalManager.death.emit()


func _unhandled_input(event: InputEvent) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		var mouse_sens : float = GameManager.Mouse_Sensitivity
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, -1.1, 1.4)
	

	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("Crouch") and is_on_floor():
		speed = crouch_speed
		head.position = lerp(head.position, Vector3(0.0, 1.023, -0.114), 0.1)
		$CollisionShape3D.shape.height = 1.0
		$CollisionShape3D.position = Vector3(0.0, 0.584, 0.0)
		$HeadScan.position = Vector3(0.0, 1.023, 0.0)
	elif Input.is_action_pressed("Run") and is_on_floor() and speed != crouch_speed:
		if $HeadScan.is_colliding():
			return
		speed = sprint_speed
		if Input.is_action_pressed("Aim"):
			speed = aim_speed
		#hands.position = lerp(hands.position, Vector3.ZERO, 0.1)
		head.position = lerp(head.position, Vector3(0.0, 1.723, -0.114), 0.1)
		$HeadScan.position = Vector3(0.0, 1.723, 0.0)
	else:
		if $HeadScan.is_colliding():
			return
		$CollisionShape3D.shape.height = 1.735
		$CollisionShape3D.position = Vector3(0.0, 0.968, 0.0)
		speed = walk_speed
		if Input.is_action_pressed("Aim"):
			speed = aim_speed
		head.position = lerp(head.position, Vector3(0.0, 1.723, -0.114), 0.1)
		$HeadScan.position = Vector3(0.0, 1.723, 0.0)
		
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#aiming
	#animation has its ows things in player_hands_animation
	
	if Input.is_action_just_pressed("Aim"): #eventual addition for automatic fire
		hands.reparent(head)
		if Input.is_action_pressed("Crouch"):
			hands.position = lerp(hands.position, Vector3(0.0, -0.5, 0.0), 0.1)
		else:
			hands.position = Vector3(0.0, -0.9, 0.0)#Vector3(0.0, -0.933, 0.022)
		hands.rotation_degrees = Vector3(0.0, -180.0, 0.0)
		#basis
		
		
	if Input.is_action_just_released("Aim"):
		hands.reparent(mesh)
		hands.position = Vector3(0.0, 0.0, 0.0)
		hands.rotation = Vector3(0.0, 0.0, 0.0)
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	if is_on_floor():
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		if(velocity.length() == 0.0):
			SignalManager.movement.emit(0)

	move_and_slide()
