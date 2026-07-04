extends Node3D

@onready var bullet_scene : PackedScene = preload("res://Scenes/Bullet.tscn")
var active : bool = false
var can_shoot : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!active):
		return
	if(Input.is_action_pressed("Aim")):
		can_shoot = true
	else:
		can_shoot = false
		
	if(can_shoot):
		if (Input.is_action_just_pressed("Shoot")):
			var bullet : RigidBody3D = bullet_scene.instantiate()
			var bullet_mesh : Node3D = PlayerManager.current_ammuniton.instantiate()
			bullet_mesh.get_child(0).owner = null
			bullet_mesh.get_child(0).reparent(get_tree().root)
			var bullet_helper : MeshInstance3D = get_tree().root.get_child(-1)
			bullet_helper.reparent(bullet)
			bullet_mesh.queue_free()
			bullet.get_child(1).set_surface_override_material(0, load("res://Art/3D/Weapons/Master_Material.material"))
			var weapon_origin = find_parent("Player").find_child("WeaponOriginPistol")
			bullet.look_at_from_position(position, weapon_origin.global_transform.basis.z)
			bullet.global_transform = weapon_origin.global_transform
			bullet.mass = 0.02
			bullet.gravity_scale = 0.0
			bullet.rotation.x += deg_to_rad(90.0)
			bullet.linear_velocity = weapon_origin.global_transform.basis.z * 50.0
			bullet.set_script(load("res://Scripts/bullet_script.gd"))
			get_tree().root.add_child(bullet)
			
			#bullet.get_child(0).scale = bullet.get_child(0).scale * 1.5
			
			
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



func _on_confirm_pressed() -> void:
	active = true
