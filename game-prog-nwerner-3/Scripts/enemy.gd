extends CharacterBody3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var sight : ShapeCast3D = $Sight
@onready var true_sight: RayCast3D = $TrueSight


@export_category("Enemy Stats")
@export var health : int
@export var max_health : int
@export var walk_speed : float
@export var sprint_speed : float
@export var patrole_speed : float

#patrole
var patrole_points : PackedVector3Array = [null, null, null, null, null]
var current_patrole_point : int = 0
var patroling : bool = true
var stopping : bool = false
var sighted : bool = false
@onready var scout_point: Node3D = $"../ScoutPoint"

#misc
var pre_hit_position : Vector3
var sight_just_broken : bool = false
var state
var player = null
var nav_agent : NavigationAgent3D
@onready var nav_mesh_node : NavigationRegion3D = $"../Level"
var nav_map: RID
var enemy_mesh : PackedScene = preload("res://Art/3D/Characters/Enemies/Character31/Character_31.fbx")
var speed : float = 5.0

func _ready() -> void:
	GameManager.enemy_count += 1
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	nav_agent = get_node("./NavigationAgent")
	nav_map = nav_agent.get_navigation_map()
	print(NavigationServer3D.map_get_regions(nav_map).size())
	player = get_node("../Player")
	state = animation_tree.get("parameters/playback")
	
	if nav_mesh_node == null:
		nav_mesh_node = get_tree().root.find_child("Level")
	
	patrole_points = [global_position, $PatrolPoints/Point1.global_position, $PatrolPoints/Point2.global_position, $PatrolPoints/Point3.global_position, $PatrolPoints/Point4.global_position]
	#var nav_mesh = nav_mesh_node.navigation_mesh.get_vertices()
	#print(nav_mesh)
	
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
	
	true_sight.target_position = Vector3(0.0, 0.0, -abs(global_position.distance_to(player.global_position)))
	true_sight.global_position = self.global_position + Vector3(0.0, 1.65, 0.0)
	true_sight.look_at(Vector3(player.global_position.x, player.global_position.y + 1.5, player.global_position.z), Vector3.UP)
	
	sighted = sight.is_colliding() && is_true_sight()
	print(sighted)
	
	match state.get_current_node():
		"Idle Undetected":
			if sighted:
				animation_tree.set("parameters/conditions/init", true)
				speed = walk_speed
			else:
				animation_tree.set("parameters/conditions/patroling", true)
				patroling = true
				patrole()
		"Idle":
			if(sighted):
				speed = walk_speed
				animation_tree.set("parameters/conditions/idle", false)
				animation_tree.set("parameters/conditions/walk", true)
			elif stopping:
				return
			elif !patroling:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
			else:
				animation_tree.set("parameters/conditions/idle", false)
				animation_tree.set("parameters/conditions/init", false)
				animation_tree.set("parameters/conditions/patroling", true)
				patrole()
		"Walk":
			if sighted:
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
		"Patrole":
			if sighted:
				if(!animation_tree.get("parameters/conditions/walk")):
					animation_tree.set("parameters/conditions/init", true)
					animation_tree.set("parameters/conditions/patroling", false)
					animation_tree.set("parameters/conditions/idle", false)
					animation_tree.set("parameters/conditions/walk", true)
					return
			else:
				patrole()
			
			#WHY DOES IT NOT WALK ANYMORE
	
	if(animation_tree.get("parameters/conditions/walk")):
		if(animation_tree.get("parameters/conditions/hit")):
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			return
		if(!is_true_sight()):
			follow_last_point(next_nav_point)
			return
		
		if(sighted):
			patroling = false
			look_at(player.global_position, Vector3.UP)
			nav_agent.target_position = player.global_position
			next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * speed
		elif !patroling:
			print("follow_last_point")
			follow_last_point(next_nav_point)
	
	'if(animation_tree.get("parameters/conditions/patroling")):
		if(animation_tree.get("parameters/conditions/hit")):
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			return
			
		if(!is_true_sight()):
			follow_last_point(next_nav_point)
			return
		
		if(sight.is_colliding() && is_true_sight()):
			patroling = false
			walk_toggle_undetected(false)
			walk_toggle(true)'
	
	rotation_degrees.x = 0.0
	rotation_degrees.z = 0.0
	
	if not is_on_floor():
		velocity.y = get_gravity().y
	move_and_slide()

func follow_last_point(next_nav_point : Vector3) -> void:
	print("sight just broken")
	velocity = (next_nav_point - global_position).normalized() * speed
	if(!sight_just_broken):
		sight_just_broken = true
		await get_tree().create_timer(2.25).timeout
		
		animation_tree.set("parameters/conditions/walk", false)
		animation_tree.set("parameters/conditions/idle", true)
		print("returned to idle")
		
		sight_just_broken = false
		await get_tree().create_timer(1.0).timeout
		animation_tree.set("parameters/conditions/init", false)
		patroling = true
		return
	return
		
func patrole() -> void:
	var next_nav_point
	speed = patrole_speed
	if stopping:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		walk_toggle_undetected(false)
		return
	if (global_position.x > patrole_points[current_patrole_point].x - 0.1 && global_position.x < patrole_points[current_patrole_point].x + 0.1 && global_position.z > patrole_points[current_patrole_point].z - 0.1 && global_position.z < patrole_points[current_patrole_point].z + 0.1):
		if(current_patrole_point == 0 && stopping == false):
			stopping = true
			await get_tree().create_timer(4.5).timeout
			stopping = false
			walk_toggle_undetected(true)
			pass
		if(patrole_points[current_patrole_point] == scout_point.global_position && stopping == false):
			stopping = true
			await get_tree().create_timer(7.5).timeout
			stopping = false
			walk_toggle_undetected(true)
			pass
		current_patrole_point += 1
		if(current_patrole_point >= patrole_points.size()):
			current_patrole_point = 0
		return
	
	next_nav_point = nav_agent.get_next_path_position()
	var target_transform = global_transform.looking_at(next_nav_point, Vector3.UP)
	
	# Smoothly interpolate between the current basis and the target basis
	var current_quat = Quaternion(global_transform.basis)
	var target_quat = Quaternion(target_transform.basis)
	var slerped_quat = current_quat.slerp(target_quat, 0.08)
	global_transform.basis = Basis(slerped_quat)
	
	nav_agent.target_position = patrole_points[current_patrole_point]
	print(nav_agent.target_position)
	
	velocity = (next_nav_point - global_position).normalized() * speed

func walk_toggle(ver : bool):
	if(ver):
		if !sight.is_colliding():
			animation_tree.set("parameters/conditions/patroling", false)
			animation_tree.set("parameters/conditions/idle", false)
			animation_tree.set("parameters/conditions/walk", true)
	else:
		if !sight.is_colliding():
			animation_tree.set("parameters/conditions/patroling", false)
			animation_tree.set("parameters/conditions/walk", false)
			animation_tree.set("parameters/conditions/idle", true)

func walk_toggle_undetected(ver : bool):
	if(ver):
		if !sight.is_colliding():
			animation_tree.set("parameters/conditions/walk", false)
			animation_tree.set("parameters/conditions/init", false)
			animation_tree.set("parameters/conditions/patroling", true)
			animation_tree.set("parameters/conditions/idle", false)
	else:
		if !sight.is_colliding():
			animation_tree.set("parameters/conditions/walk", false)
			animation_tree.set("parameters/conditions/patroling", false)
			animation_tree.set("parameters/conditions/init", false)
			animation_tree.set("parameters/conditions/idle", true)

func is_true_sight() -> bool:
	if sight_just_broken:
		return true
	return !true_sight.is_colliding()
