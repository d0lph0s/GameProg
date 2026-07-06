extends CharacterBody3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var sight : ShapeCast3D = $Sight

@export_category("Enemy Stats")
@export var health : int
@export var max_health : int
@export var walk_speed : float
@export var sprint_speed : float
@export var parole_speed : float

#parole
var parole_points : PackedVector3Array = [null, null, null, null, null]
var current_parole_point : int = 0
var patroling : bool = true

#misc
var pre_hit_position : Vector3
var sight_just_broken : bool = false
var state
var player = null
var nav_agent : NavigationAgent3D
var enemy_mesh : PackedScene = preload("res://Art/3D/Characters/Enemies/Character31/Character_31.fbx")
var speed = 5.0

func _ready() -> void:
	for i in range(0, parole_points.size()):
		match i:
			0:
				parole_points[i] = global_position
			_: 
				parole_points[i] = Vector3(global_position.x + randf_range(-10.0, 10.0), global_position.y, global_position.z + randf_range(-10.0, 10.0))
		print(parole_points[i])
	
	
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
	pre_hit_position = global_position
	animation_tree.set("parameters/conditions/hit", true)
	health -= damage
	if(health > 0):
		return
	if(health >= 0):
		queue_free()



func _physics_process(delta: float) -> void:
	var next_nav_point : Vector3
	if(player == null):
		return
	match state.get_current_node():
		"Idle Undetected":
			if sight.is_colliding():
				animation_tree.set("parameters/conditions/init", true)
				speed = walk_speed
			else:
				animation_tree.set("parameters/conditions/init", true)
				animation_tree.set("parameters/conditions/paroling", true)
				patroling = true
				patrole()
		"Idle":
			if(sight.is_colliding()):
				speed = walk_speed
				animation_tree.set("parameters/conditions/idle", false)
				animation_tree.set("parameters/conditions/walk", true)
			elif !patroling:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
			else:
				animation_tree.set("parameters/conditions/idle", false)
				animation_tree.set("parameters/conditions/paroling", true)
				patrole()
		"Walk":
			if sight.is_colliding():
				pass
			else:
				patrole()
		"Hit":
			await animation_tree.animation_finished
			animation_tree.set("parameters/conditions/hit", false)
			global_position = pre_hit_position
		"Kneel":
			pass
		"Kneel Hit":
			pass
		"Parole":
			'if sight.is_colliding():
				animation_tree.set("parameters/conditions/paroling", false)
				animation_tree.set("parameters/conditions/idle", true)
				animation_tree.set("parameters/conditions/walk", true)
			else:'
			patrole()
			
			WHY DOES IT NOT WALK ANYMORE
			
	if(animation_tree.get("parameters/conditions/walk")):
		if(animation_tree.get("parameters/conditions/hit")):
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			return
		
		if(sight.is_colliding()):
			patroling = false
			look_at(player.global_position, Vector3.UP)
			nav_agent.target_position = player.global_position
			next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * speed
		elif !patroling:
			follow_last_point(next_nav_point)
	
	rotation_degrees.x = 0.0
	rotation_degrees.z = 0.0
	
	if not is_on_floor():
		velocity.y = get_gravity().y
	move_and_slide()

func follow_last_point(next_nav_point : Vector3) -> void:
	
	velocity = (next_nav_point - global_position).normalized() * speed
	if(!sight_just_broken):
		sight_just_broken = true
		await get_tree().create_timer(0.5).timeout
		if(!sight.is_colliding()):
			animation_tree.set("parameters/conditions/walk", false)
			animation_tree.set("parameters/conditions/idle", true)
			print("returned to idle")
		sight_just_broken = false
		await get_tree().create_timer(1.5).timeout
		patroling = true
		
func patrole() -> void:
	var next_nav_point
	var speed = parole_speed
	if (global_position.x > parole_points[current_parole_point].x - 0.1 && global_position.x < parole_points[current_parole_point].x + 0.1 && global_position.z > parole_points[current_parole_point].z - 0.1 && global_position.z < parole_points[current_parole_point].z + 0.1):
		'if(current_parole_point == 0):
			await get_tree().create_timer(2.5).timeout
			pass'
		current_parole_point += 1
		if(current_parole_point >= parole_points.size()):
			current_parole_point = 0
		return
	
	look_at(parole_points[current_parole_point], Vector3.UP)
	nav_agent.target_position = parole_points[current_parole_point]
	print(global_position)
	print(nav_agent.target_position)
	next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * speed
	
