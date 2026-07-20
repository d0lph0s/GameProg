class_name Enemy
extends CharacterBody3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var sight : ShapeCast3D = $Sight
@onready var true_sight: RayCast3D = $TrueSight
@onready var weapon_scene : PackedScene = preload("res://Scenes/EnemyPlaceholderWeapon.tscn")
var muzzle_flash_node : Node3D
var weapon_sound_node : AudioStreamPlayer3D

@export_category("Enemy Movement Stats")
@export var health : int
@export var max_health : int
@export var walk_speed : float
@export var sprint_speed : float
@export var patrole_speed : float
@export_category("Enemy Combat Stats")
@export var armor : int 
@export var ammunition_scene : PackedScene
@export_range(0.0, 100.0, 1.0) var accuracy : float


#patrole
var patrole_points : PackedVector3Array = [null, null, null, null, null]
var scout_points : PackedVector3Array = []
var current_patrole_point : int = 0
var patroling : bool = true
var stopping : bool = false
var sighted : bool = false
@onready var scout_point: Node3D = $"../ScoutPoint"

#misc
var shot_timer : Timer
var shooting : bool
var label_font = preload("res://Art/2D/UI/SyneMono-Regular.ttf")
var hit : bool = false
var next_nav_point : Vector3
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
	instantiate_weapon()
	shot_timer = Timer.new()
	
	#PLACEHOLDER
	var label3d : Label3D = Label3D.new()
	label3d.text = "Arschhaare"
	label3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label3d.position = Vector3(0.0, 1.0, 0.0)
	$DamageFeedback.add_child(label3d)
	
	GameManager.enemy_count += 1
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	#region assigning+nav
	nav_agent = get_node("./NavigationAgent")
	nav_map = nav_agent.get_navigation_map()
	#print(NavigationServer3D.map_get_regions(nav_map).size())
	player = get_node("../Player")
	state = animation_tree.get("parameters/playback")
	
	if nav_mesh_node == null:
		nav_mesh_node = get_tree().root.find_child("Level")
	
	var scout_points_raw = get_parent().find_children("ScoutPoint" + "*")
	for i : int in range(0, scout_points_raw.size()):
		scout_points.append(scout_points_raw[i].global_position)
	scout_points.sort()
	
	#print(scout_points)
	patrole_points = [global_position, $PatrolPoints/Point1.global_position, $PatrolPoints/Point2.global_position, $PatrolPoints/Point3.global_position, $PatrolPoints/Point4.global_position]
	#endregion
	
	#OPTIONAL MODULAR MESH LOADING
	#region meshloading
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
	#endregion
	
	animation_tree.active = true

func take_damage(damage : int) -> void:
	pre_hit_position = global_position
	animation_tree.set("parameters/conditions/hit", true)
	health -= damage
	print(health)
	if(health > 0):
		return
	if(health <= 0):
		animation_tree.set("parameters/conditions/dead", true)
		for i : int in range(get_child_count()):
			if(i == 1):
				disable_while_dying()
				return
			if(i == 2):
				return
			get_child(i).process_mode = Node.PROCESS_MODE_DISABLED


func disable_while_dying() -> void:
	for i in 8:
		await get_tree().process_frame
	SignalManager.enemy_killed.emit()
	self.set_script(null)

func display_damage(damage : int, hit_position : Vector3, color : Color) -> void:
	var damage_label : Label3D = Label3D.new()
	damage_label.text = str(damage)
	damage_label.outline_size = 8
	damage_label.modulate = color
	damage_label.font = label_font
	damage_label.font_size = 64
	damage_label.position = (global_position - hit_position).normalized() * 0.5 + Vector3(randf_range(-0.15, 0.15), randf_range(-0.15, 0.15) + 0.5, randf_range(-0.15, 0.15))
	damage_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	damage_label.alpha_cut = Label3D.ALPHA_CUT_OPAQUE_PREPASS
	
	#damage_label.look_at(Vector3(player.global_position.x, damage_label.global_position.y, player.global_position.z), Vector3.UP)
	$DamageFeedback.add_child(damage_label)
	var tween = create_tween()
	var evil_tween = create_tween()
	evil_tween.set_trans(Tween.TRANS_CUBIC)
	#fix mal den tween color, ainfach nur alpha fade out
	tween.tween_property(damage_label, "position", (global_position - hit_position).normalized() * 0.5 + Vector3(randf_range(-0.5, 0.5), 1.5, 0.0), 1.25)
	evil_tween.tween_property(damage_label, "modulate", Color(color.r, color.g, color.b, 0.0), 1.5)
	evil_tween.tween_property(damage_label, "outline_modulate", Color(0.0, 0.0, 0.0, 0.0), 1.5)
	await tween.finished
	damage_label.queue_free()

func _physics_process(delta: float) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
	if(player == null):
		return
	
	true_sight.target_position = Vector3(0.0, 0.0, -abs(global_position.distance_to(player.global_position)))
	true_sight.global_position = self.global_position + Vector3(0.0, 1.65, 0.0)
	true_sight.look_at(Vector3(player.global_position.x, player.global_position.y + 1.5, player.global_position.z), Vector3.UP)
	
	sighted = sight.is_colliding() && is_true_sight()
	#print(sighted)
	
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
			if shooting:
				return
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
			if shooting:
				return
			if hit:
				follow_player()
			elif sighted:
				pass
			else:
				patrole()
		"Hit":
			hit = true
			await animation_tree.animation_finished
			animation_tree.set("parameters/conditions/patroling", false)
			animation_tree.set("parameters/conditions/hit", false)
			animation_tree.set("parameters/conditions/walk", true)
			global_position = pre_hit_position
			just_hit()
			follow_player()
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
		"Pistol Shoot":
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		"Death":
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			
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
			follow_player()
		elif !patroling:
			print("follow_last_point")
			follow_last_point(next_nav_point)
			
	if(animation_tree.get("parameters/conditions/patroling")):
		if(animation_tree.get("parameters/conditions/hit")):
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
			return
	
	rotation_degrees.x = 0.0
	rotation_degrees.z = 0.0
	
	if not is_on_floor():
		velocity.y = get_gravity().y
	if not stopping:
		move_and_slide()

func just_hit() -> void:
	if hit:
		speed = sprint_speed + patrole_speed
		await get_tree().create_timer(2.0).timeout
		hit = false
		speed = walk_speed
	
func follow_player() -> void:
	if shooting:
		return
	look_at(player.global_position, Vector3.UP)
	var richtung : Vector3 = (global_position - player.global_position).normalized()
	nav_agent.target_position = player.global_position + richtung * 9.5
	if global_position.distance_to(player.global_position + richtung * 9.5) <= 0.05 && shot_timer.timeout:
		if(!shooting):
			shot_timer.start(randf_range(5.0, 6.9))
			shooting = true
			shoot_player()
			#find fix for timer!!!!!!!!!!!!!!!!!!!!!!!!!
		return
	next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * speed


func shoot_player() -> void:
	if(!shooting):
		return
	walk_toggle(false)
	await get_tree().create_timer(0.5).timeout
	look_at(player.global_position, Vector3.UP)
	shoot()
	animation_tree.set("parameters/conditions/shoot", true)
	print("shoot")
	await animation_tree.animation_finished
	await get_tree().create_timer(0.1).timeout
	animation_tree.set("parameters/conditions/shoot", false)
	print("finished")
	shooting = false

func shoot() -> void:
	await get_tree().physics_frame
	muzzle_flash_node.play()
	weapon_sound_node.pitch_scale = randf_range(3.0, 3.69)
	weapon_sound_node.play()
	var bullet_scene : PackedScene = load("res://Scenes/Bullet.tscn")
	var bullet : RigidBody3D = bullet_scene.instantiate()
	var bullet_mesh : Node3D = ammunition_scene.instantiate()
	bullet_mesh.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
	bullet_mesh.get_child(0).owner = null
	bullet_mesh.get_child(0).reparent(get_tree().root)
	var bullet_helper : MeshInstance3D = get_tree().root.get_child(-1)
	bullet_helper.reparent(bullet)
	bullet_mesh.queue_free()
	#bullet.get_children()[get_children().size()-1].set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
	var weapon_origin : Node3D = $WeaponOrigin
	bullet.set_collision_mask_value(5, false)
	bullet.set_collision_mask_value(7, true)
	bullet.get_child(0).set_collision_mask_value(5, false)
	bullet.get_child(0).set_collision_mask_value(7, true)
	var direction : Vector3 = (weapon_origin.global_transform.basis.z + Vector3(randf_range(-0.02, 0.02) * WeaponManager.calc_accuracy(accuracy), randf_range(-0.02, 0.02) * WeaponManager.calc_accuracy(accuracy), randf_range(-0.02, 0.02) * WeaponManager.calc_accuracy(accuracy))).normalized()
	bullet.look_at_from_position(position, direction)
	bullet.global_transform = weapon_origin.global_transform
	bullet.mass = 0.02
	bullet.gravity_scale = 0.0
	bullet.rotation.x += deg_to_rad(90.0)
	bullet.linear_velocity = -direction * 32.5
	bullet.set_script(load("res://Scripts/bullet_script.gd"))
	get_tree().root.add_child(bullet)

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
	speed = patrole_speed
	if stopping:
		if(scout_points.has(patrole_points[current_patrole_point])):
			$Sight.scale = lerp($Sight.scale, Vector3(1.0, 1.0, 3.0), 0.1)
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		walk_toggle_undetected(false)
		return
	if (global_position.x > patrole_points[current_patrole_point].x - 0.1 && global_position.x < patrole_points[current_patrole_point].x + 0.1 && global_position.z > patrole_points[current_patrole_point].z - 0.1 && global_position.z < patrole_points[current_patrole_point].z + 0.1):
		if(current_patrole_point == 0 && stopping == false):
			stopping = true
			await get_tree().create_timer(4.5).timeout
			stopping = false
			if !sighted:
				walk_toggle_undetected(true)
			pass
		elif(scout_points.has(patrole_points[current_patrole_point]) && stopping == false):
			stopping = true
			await get_tree().create_timer(7.5).timeout
			stopping = false
			if !sighted:
				walk_toggle_undetected(true)
		else:
			stopping = true
			await get_tree().create_timer(1.25).timeout
			stopping = false
			if !sighted:
				walk_toggle_undetected(true)
		current_patrole_point += 1
		if(current_patrole_point >= patrole_points.size()):
			current_patrole_point = 0
		return
		
	$Sight.scale = Vector3.ONE
	next_nav_point = nav_agent.get_next_path_position()
	var target_transform = global_transform.looking_at(next_nav_point, Vector3.UP)
	
	# Smoothly interpolate between the current basis and the target basis
	var current_quat = Quaternion(global_transform.basis)
	var target_quat = Quaternion(target_transform.basis)
	var slerped_quat = current_quat.slerp(target_quat, 0.08)
	global_transform.basis = Basis(slerped_quat)
	
	nav_agent.target_position = patrole_points[current_patrole_point]
	
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

func instantiate_weapon() -> void:
	#randomize this shit at some point if developed further
	var weapon = weapon_scene.instantiate()
	weapon.rotation_degrees.y = 180.0
	$WeaponOrigin.add_child(weapon)
	weapon_sound_node = weapon.find_child("WeaponSound")
	muzzle_flash_node = weapon.find_child("ShortFlash" + "*")
	muzzle_flash_node.rotation_degrees.y = -90.0
