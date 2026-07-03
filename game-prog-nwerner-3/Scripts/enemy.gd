extends CharacterBody3D

@export_category("Enemy Stats")
@export var health : int
@export var max_health : int
@export var walk_speed : float
@export var sprint_speed : float

var enemy_mesh : PackedScene = preload("res://Art/3D/Characters/Enemies/Character_31.fbx")
var speed = 5.0

func _ready() -> void:
	var enemy : Node = enemy_mesh.instantiate()
	var mesh : MeshInstance3D = enemy.find_children("Character" + "*", "MeshInstance3D")[0]
	mesh.set_surface_override_material(0, load("res://Art/3D/Characters/Enemies/Character_31.material"))
	enemy.scale = Vector3(0.5, 0.5, 0.5)
	add_child(enemy)

func take_damage(damage : int) -> void:
	health -= damage
	if(health > 0):
		return
	if(health >= 0):
		queue_free()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
