extends CharacterBody3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var sight : ShapeCast3D = $Sight

@export_category("Enemy Stats")
@export var health : int
@export var max_health : int
@export var walk_speed : float
@export var sprint_speed : float

var sight_just_broken : bool = false
var state
var player = null
var nav_agent : NavigationAgent3D
var enemy_mesh : PackedScene = preload("res://Art/3D/Characters/Enemies/Character31/Character_31.fbx")
var speed = 5.0

func _ready() -> void:
	nav_agent = get_node("./NavigationAgent")
	player = get_node("../Player")
	state = animation_tree.get("parameters/playback")
	
	
	'''var enemy : Node = enemy_mesh.instantiate()
	enemy.remove_child(enemy.get_child(-1))
	var new_animation_player_scene : PackedScene = load("res://Scenes/EnemyAnimationPlayer.tscn")
	var new_animation_player : AnimationPlayer = new_animation_player_scene.instantiate()
	enemy.add_child(new_animation_player)
	new_animation_player_scene = null
	var mesh : MeshInstance3D = enemy.find_children("Character" + "*", "MeshInstance3D")[0]
	mesh.set_surface_override_material(0, load("res://Art/3D/Characters/Enemies/Character_31.material"))
	enemy.scale = Vector3(0.5, 0.5, 0.5)
	add_child(enemy)
	
	animation_tree.anim_player = enemy.get_child(-1).get_path()'''
	animation_tree.active = true
	

func take_damage(damage : int) -> void:
	health -= damage
	if(health > 0):
		return
	if(health >= 0):
		queue_free()

func follow_last_point(next_nav_point : Vector3) -> void:
	
	velocity = (next_nav_point - global_position).normalized() * speed
	if(!sight_just_broken):
		sight_just_broken = true
		await get_tree().create_timer(0.5).timeout
		print("timeout")
		aaaaaaa irgendwie fängt der an zu wobblen, wenn man nach dem timeout wieder in den sight geht
		if(!sight.is_colliding()):
			animation_tree.set("parameters/conditions/walk", false)
			animation_tree.set("parameters/conditions/idle", true)
		sight_just_broken = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var next_nav_point : Vector3
	if(player == null):
		return
	match state.get_current_node():
		"Idle Undetected":
			if sight.is_colliding():
				animation_tree.set("parameters/conditions/init", true)
		"Idle":
			if(sight.is_colliding()):
				animation_tree.set("parameters/conditions/walk", true)
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
		"walk":
			pass
	if(animation_tree.get("parameters/conditions/walk")):
		look_at(player.global_position, Vector3.UP)
		if(sight.is_colliding()):
			nav_agent.target_position = player.global_position
			next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * speed
		else:
			follow_last_point(next_nav_point)
		
	move_and_slide()
	
	
	
	

	
