extends Node3D

@export var max_ammo : int

@onready var muzzle_flash_scene : PackedScene = preload("res://Art/2D/VFX/BinbunVFX/muzzle_flash/effects/short_flash/short_flash_04.tscn")
@onready var bullet_scene : PackedScene = preload("res://Scenes/Bullet.tscn")
var muzzle_flash_node : Node3D

var ammo : int
var active : bool = false
var can_shoot : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammo = max_ammo
	PlayerManager.current_ammo = ammo
	SignalManager.ammo_used.emit()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!active):
		return
	if(Input.is_action_pressed("Aim")):
		can_shoot = true
	else:
		can_shoot = false
	
	if Input.is_action_just_pressed("Reload"):
		ammo = 0
		reload()
	
	if(can_shoot):
		if (Input.is_action_just_pressed("Shoot")):
			printerr("shoot")
			if(ammo <= 0):
				return
			ammo -= 1
			PlayerManager.current_ammo -= 1
			SignalManager.ammo_used.emit()
			if has_node("../../.."):
				var useful_parent_node : Node3D = get_parent().get_parent().get_parent()
				var player_node : Node3D = get_node("../../../..")
				if(useful_parent_node.has_meta("Player")):
					useful_parent_node.rotation_degrees.x = lerpf(useful_parent_node.rotation_degrees.x, useful_parent_node.rotation_degrees.x + randf_range(0.45, 3.1), 0.21)
					player_node.rotation_degrees.y = lerpf(player_node.rotation_degrees.y, player_node.rotation_degrees.y + randf_range(-3.1, 3.1), 0.21)
			$"../AudioStreamPlayer3D".play()
			muzzle_flash()
			var bullet : RigidBody3D = bullet_scene.instantiate()
			var bullet_mesh : Node3D = PlayerManager.current_ammuniton.instantiate()
			bullet_mesh.get_child(0).owner = null
			bullet_mesh.get_child(0).reparent(get_tree().root)
			var bullet_helper : MeshInstance3D = get_tree().root.get_child(-1)
			bullet_helper.reparent(bullet)
			bullet_mesh.queue_free()
			bullet.get_child(get_child_count()-1).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			var weapon_origin = find_parent("Player").find_child("WeaponOriginPistol")
			var direction : Vector3 = (weapon_origin.global_transform.basis.z + Vector3(randf_range(-0.01, 0.01) * WeaponManager.accuracy(), randf_range(-0.01, 0.01) * WeaponManager.accuracy(), randf_range(-0.01, 0.01) * WeaponManager.accuracy())).normalized()
			bullet.look_at_from_position(position, direction)
			bullet.global_transform = weapon_origin.global_transform
			bullet.mass = 0.02
			bullet.gravity_scale = 0.0
			bullet.rotation.x += deg_to_rad(90.0)
			bullet.linear_velocity = direction * 40.0
			bullet.set_script(load("res://Scripts/bullet_script.gd"))
			get_tree().root.add_child(bullet)
			if(ammo <= 0):
				reload()
				return
			
			#bullet.get_child(0).scale = bullet.get_child(0).scale * 1.5
			
			#region deprecated
			'''var rigidbody : RigidBody3D
			var collider : CollisionShape3D
			
			var bullet : Node3D = PlayerManager.current_ammuniton.instantiate()
			bullet.get_child(0).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			var weapon_origin = find_parent("Player").find_child("WeaponOriginPistol")
			bullet.look_at_from_position(position, weapon_origin.global_transform.basis.z)
			bullet.global_transform = weapon_origin.global_transform
			bullet.rotation.x += deg_to_rad(90.0)
			bullet.scale = bullet.scale * 1.5
			
			rigidbody = RigidBody3D.new()
			rigidbody.mass = 0.02
			rigidbody.gravity_scale = 0.0
			#shit
			
			 #die masken scheinen nicht zu stimmen
			rigidbody.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
			rigidbody.contact_monitor = true
			rigidbody.set_script(load("res://Scripts/bullet_script.gd"))
			rigidbody.collision_layer = (1 << 2 -1)
			rigidbody.collision_mask = (1 << 3 - 1)
			
			rigidbody.add_child(bullet)
			
			rigidbody.linear_velocity = weapon_origin.global_transform.basis.z * 0.0
			
			get_tree().root.add_child(rigidbody)'''
			#endregion

func reload() -> void:
	await get_tree().create_timer(WeaponManager.reload_time()).timeout
	ammo = max_ammo
	PlayerManager.current_ammo = max_ammo
	SignalManager.ammo_used.emit()

func muzzle_flash() -> void:
	print(muzzle_flash_node.get_children())
	muzzle_flash_node.speed_scale = 2.0
	muzzle_flash_node.play()

func load_muzzle_flash() -> void:
	var muzzle_flash : Node3D = muzzle_flash_scene.instantiate()
	print(muzzle_flash.get_child(4))
	muzzle_flash.name = "MuzzleFlash"
	muzzle_flash.rotation_degrees.y = (-90.0)
	muzzle_flash.position = WeaponManager.calculate_muzzle_point()
	add_sibling(muzzle_flash)
	muzzle_flash_node = muzzle_flash

func _on_confirm_pressed() -> void:
	#active = true
	#load_muzzle_flash()
	pass
