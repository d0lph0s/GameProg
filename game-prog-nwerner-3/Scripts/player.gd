extends CharacterBody3D

@onready var head : Node3D = $CameraHead
@onready var hands : Node3D = $Mesh/PlayerHands
@onready var hands_fix : Node3D = $CameraHead/HandOriginFix

@onready var mesh : Node3D = $Mesh


var direction : Vector3
var speed : float
const JUMP_VELOCITY : float = 2.75

func _unhandled_input(event: InputEvent) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		var mouse_sens : float = GameManager.Mouse_Sensitivity
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, -1.1, 1.4)
	
func _physics_process(delta: float) -> void:
	#sprint
	speed = 6.5
	if Input.is_action_pressed("Run") and is_on_floor():
		speed = 8.75
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#aiming
	#animation has its ows things in player_hands_animation
	if Input.is_action_just_pressed("Aim"): #eventual addition for automatic fire
		hands.reparent(hands_fix)
	if Input.is_action_just_released("Aim"):
		hands.reparent(mesh)
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
